/**
* @Name         IND_CreditProcessing
* @Author       Karunakar M.
* @Company      Persistent Systems
* @Description  This class contains all methods related to Credit Processing Module.
* Inputs:       None
* Test Class:   IND_CreditProcessingTest https://indusindbank123--psldev1.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage#
*/
public with sharing class IND_CreditProcessing {
    
    /*
    * @Method:      getCreditProcessTabs
    * @Created by:  Karunakar M.
    * @Description: This method will return tabs related to loan Application based on Opp data.
    * @Param:       String - current Applicantion ID
    * @Return:      JSON object : containing tab names.
    */   
    @AuraEnabled
    public static CreditProcessingTabs getCreditProcessTabs(Id loanApplicationId){       
        Opportunity oppRecord;      
        Vehicle_Detail__c insurance;
        List<String> applicantTypesList = new List<String>();
        List<String> webTabsList = new List<String>();
        CreditProcessingTabs creditprocesstab = new CreditProcessingTabs(); 
        Map<Integer, String> creditprossMap =new Map<Integer, String>();
        Map<String, string> nextTabnameMap= new Map<String, string>();
        Map<String, Map<String,String>> fiRecordMap = new Map<String, Map<String,String>>();
        Map<String, Boolean> fiStatusMap = new Map<String, Boolean>();
        List<Id>applicantIds = new List<Id>();
        try {         
            //Querying  the opportunity Stage, Sub stage, Product Type, Sanction status of Loan application Id   
            //prashanth - adding Lead Source, Is Pre Approved fields in thr query 
            for(Opportunity oppty : [select Id,Product_Type__c, Name, StageName, Sub_Stage__c,Vehicle_Type__c, Vehicle_Sub_Category__c,
                                     Valuation_price__c,Selling_Price__c,Grid_value__c,
                                     Sanction_Status__c,View_Application_Sub_Stages__c,LeadSource,Is_Pre_Approved__c,
                                     (select Id, Insurance_number__c, Valuer_category__c, Vehicle_Place_Of_Valuation__c
                                      from Vehicle_Details__r order by Createddate desc limit 1)
                                     ,(select Id, applicant_type__c,Scorecard_Decision__c from applicants__r where In_Active_Applicant__c=false ORDER BY Applicant_Type__c ASC limit 2)
                                     from Opportunity where Id =:loanApplicationId limit 1])
            { 
                System.debug('oppty'+oppty);
                oppRecord = oppty;
                // D2C_CHANGE - Raman
                creditprocesstab.oppty = oppty;
                // EO D2C_CHANGE                
                creditprocesstab.vehicleType = oppRecord.Vehicle_Type__c;//CISP-4116
                if(oppty.Vehicle_Details__r != null && !oppty.Vehicle_Details__r.isEmpty() )
                    insurance = oppty.Vehicle_Details__r[0];
                creditprocesstab.viewAppCurrentTab =  oppty.View_Application_Sub_Stages__c;
                for(Applicant__c appType : oppty.applicants__r){
                    applicantTypesList.add(appType.applicant_type__c);
                    applicantIds.add(appType.Id);
                }
            }
            
            creditprocesstab.applicantTypes = applicantTypesList;
            // Field Investigation
            List<String> caseTypes = new List<String>{System.Label.Case_Current_Residence_FI_Type,System.Label.Case_Permanent_Residence_FI_Type,System.Label.Case_Office_FI_Type};
                for(Field_Investigation__c fiRecord : [SELECT Id, Case__r.Type, Case__r.Applicant__r.Applicant_Type__c, Case__r.Status
                                                       FROM Field_Investigation__c
                                                       WHERE Case__r.Loan_Application__c =: loanApplicationId 
                                                       AND Case__r.Type IN: caseTypes
                                                       AND Case__r.Applicant__r.In_Active_Applicant__c=false
                                                       AND Case__r.Status !=: System.Label.FI_Rejected
                                                       WITH SECURITY_ENFORCED])
            {
                if(fiRecordMap.get(fiRecord.Case__r.Applicant__r.Applicant_Type__c) == null) {
                    fiRecordMap.put(fiRecord.Case__r.Applicant__r.Applicant_Type__c, new Map<String,String>{fiRecord.Id => fiRecord.Case__r.Type});
                }
                else{
                    fiRecordMap.get(fiRecord.Case__r.Applicant__r.Applicant_Type__c).put(fiRecord.Id, fiRecord.Case__r.Type);
                }
                if(String.isNotBlank(fiRecord.Case__r.Status) && fiRecord.Case__r.Status.equalsIgnoreCase(System.Label.FI_Accepted)) {
                    fiStatusMap.put(fiRecord.Id, true);
                } else {
                    fiStatusMap.put(fiRecord.Id, false);
                }
            }
            creditprocesstab.fieldInvestigationsMap = fiRecordMap;
            creditprocesstab.fiStatusMap = fiStatusMap;

            List<case> FIcasesList= [select Id from case where Applicant__c = : applicantIds ];
            System.debug('FIcasesList  -> ' + FIcasesList);
            ///checking Logged in user Profile suppose to see the Loan application stage from custom setting 
            Stage_Profile_visibility_Custom_Setting__c stageCS = Stage_Profile_visibility_Custom_Setting__c.getInstance(userInfo.getProfileId());
            if(stageCS.Loan_Application_Stage__c == oppRecord.StageName && stageCS.Active__c){
                creditprocesstab.showtab =true;
            }           
            
            //Querying the custom metadata based on Loan application stage, Vehicle type, vehicle category
            if(oppRecord != null){   
                List<Webapp_Tab_Settings__mdt> wepappList = new List<Webapp_Tab_Settings__mdt>();
                //system.debug('oppRecord ::'+oppRecord);
                //Integer currentNum;
                integer maxtabsequence=0;
                Map<Integer, String> webtabsmap = new Map<Integer, String>();
                
                for(Webapp_Tab_Settings__mdt webApp : [select Id,Label, Sanction_Status__c,Stage__c,Sub_Stage__c,
                                                       Tab_Sequence__c,Vehicle_Category__c, Product_Type__c                                                       
                                                       from Webapp_Tab_Settings__mdt where 
                                                       Stage__c =: Label.Credit_Processing and
                                                       Vehicle_Category__c =: oppRecord.Vehicle_Type__c and                                                        
                                                       Product_Type__c =: oppRecord.Product_Type__c and
                                                       Sanction_Status__c =: oppRecord.Sanction_Status__c  
                                                       
                                                      ])
                {
                    System.debug(webApp+' '+webApp.Label);
                    if(webApp.Sub_Stage__c == System.label.Field_Investigation ){ 
                        if(!FIcasesList.isEmpty()){ 
                            if(maxtabsequence < Integer.valueOf( webApp.Tab_Sequence__c)){
                                maxtabsequence = Integer.valueOf( webApp.Tab_Sequence__c);
                            }
                            system.debug('metarecord tab name '+webApp.Sub_Stage__c +' : '+webApp.Tab_Sequence__c);
                            //wepappList.add(webApp);
                            webtabsmap.put(integer.valueOf(webApp.Tab_Sequence__c), webApp.Sub_Stage__c);
                        }
                    }else{ 
                        if(maxtabsequence < Integer.valueOf( webApp.Tab_Sequence__c)){
                            maxtabsequence = Integer.valueOf( webApp.Tab_Sequence__c);
                        }
                        system.debug('metarecord tab name '+webApp.Sub_Stage__c +' : '+webApp.Tab_Sequence__c);
                        //wepappList.add(webApp);
                        webtabsmap.put(integer.valueOf(webApp.Tab_Sequence__c), webApp.Sub_Stage__c);
                    }
                }
                string prevTabname = null;
                for(integer i=1; i<=maxtabsequence; i++){
                    if(webtabsmap.containsKey(i)){
                        creditprossMap.put(i , webtabsmap.get(i));
                        string subStage = webtabsmap.get(i);                                                
                        if(prevTabname ==null){
                            nextTabnameMap.put(webtabsmap.get(i), null);
                        }else{
                            nextTabnameMap.put(prevTabname, webtabsmap.get(i));
                        }
                        prevTabname = webtabsmap.get(i);
                    }    
                }
                
                if (oppRecord.Vehicle_Type__c == 'Used' || oppRecord.Vehicle_Type__c == 'Refinance') {
                    creditprocesstab.vehicleValuation = true;
                    creditprocesstab.vehicleInsurance = true;
                }
                
                Boolean previosuTabMatched =false;
                List<Vehicle_Detail__c> vehicleDetailList = new List<Vehicle_Detail__c>([select Id from Vehicle_Detail__c where Loan_Application__c =:loanApplicationId AND Vehicle_SubType__c != 'Implement' WITH SECURITY_ENFORCED limit 10]);
                for(string stage : creditprossMap.values()){                  
                    creditprocesstab.currentTab = oppRecord.Sub_Stage__c; 
                    
                    creditprocesstab.applicantIds =applicantIds;
                    if(stage==System.label.View_Application_Details){
                        creditprocesstab.viewapplicationdetails =true;                        
                    }
                    if(stage ==System.label.CIBIL){
                        creditprocesstab.cibil =true;                         
                    }
                    if(stage == System.label.Field_Investigation && fiRecordMap.size() > 0){
                        creditprocesstab.fieldinvestigation =true;                         
                    }
                    if(stage ==System.label.IncomeTab){
                        creditprocesstab.incomedetails =true;                         
                    }
                    if((stage ==System.label.Valuation_IDV && oppRecord.Product_Type__c != Label.Tractor) || (stage ==System.label.Valuation_IDV && vehicleDetailList.size() > 0 && oppRecord.Product_Type__c == Label.Tractor)){
                        creditprocesstab.valuationidv =true;                         
                    }
                    if(stage==System.label.Risk_Summary){
                        creditprocesstab.risksummary =true;                         
                    }
                    if(stage ==System.label.Final_Terms){
                        creditprocesstab.finalterms =true;                          
                    }                    
                    if(stage ==System.label.Exposure_Analysis){
                        creditprocesstab.exposureanalysis =true;                         
                    }                  
                    if(stage ==System.label.Credit_Assessment){ 
                        creditprocesstab.creditassesment =true;                          
                    }
                    if(stage == System.label.Insurance){
                        creditprocesstab.insurancedetails = true;
                    }
                    if(stage == System.label.CAM_and_Approval_Log){
                        creditprocesstab.camapprovallog =true;
                    } 
                    if(stage == System.label.Sanction_of_Application){ // Gaurav Rawat : Added for Sanction Application tab Visibility
                        creditprocesstab.sanctionofapplication =true;
                    } 
                    if(stage == System.label.Deal_Number_Customer_Code){ // Gaurav Rawat : Added for Deal number and customer code generation tab Visibility
                        creditprocesstab.dealnumberandcodegeneration =true;
                    } 

                }  
                //D2C Changes - Prashanth
                
                if(oppRecord.LeadSource == 'D2C'){
                    if(oppRecord.Sanction_Status__c == 'STP' && oppRecord.Is_Pre_Approved__c == true){
                        creditprocesstab.valuationidv = false;
                        //marked CIBIL false for pre approved and remove tab as well - Rahul
                        creditprocesstab.cibil = false;
                        if(nextTabnameMap.containskey('CIBIL')){
                            nextTabnameMap.remove('CIBIL');
                        }
                        //New Fix
                        if(nextTabnameMap.containskey('Valuation IDV')){
                            nextTabnameMap.remove('Valuation IDV');
                        }
                        //reset the next tab to income from
                        if(nextTabnameMap.containsKey('View Application Details')){
                            nextTabnameMap.put('View Application Details','Income');
                        }
                        // V7 Navigation Changes To Be Tested
                        // if(nextTabnameMap.containskey('Credit Assessment')){
                        //     nextTabnameMap.put('Credit Assessment','Income');
                        // }
                        creditprocesstab.incomedetails = true;
                        nextTabnameMap.put('Income','Final Terms');
                        creditprocesstab.finalterms = true;
                        nextTabnameMap.put('Final Terms','Insurance');
                        creditprocesstab.insurancedetails = true;
                        nextTabnameMap.put('Insurance','Risk Summary');
                        creditprocesstab.risksummary = true;
                        if(creditprocesstab.exposureanalysis == true){
                            nextTabnameMap.put('Risk Summary','Exposure Analysis');
                        }else{
                            nextTabnameMap.put('Risk Summary','CAM and Approval Log');
                        }
                        creditprocesstab.creditassesment = false;
                        //EO V7 Navigation Changes
                        //Navigation in Exposure Analysis 
                        if(nextTabnameMap.containskey('Exposure Analysis')){
                            nextTabnameMap.put('Exposure Analysis','CAM and Approval Log');
                        }
                        
                    }else if(oppRecord.Sanction_Status__c == 'STP' && oppRecord.Is_Pre_Approved__c == false){
                        creditprocesstab.valuationidv = false;
                        if(nextTabnameMap.containskey('Valuation IDV')){
                            nextTabnameMap.remove('Valuation IDV');
                        }

                        if(nextTabnameMap.containsKey('View Application Details')){
                            nextTabnameMap.put('View Application Details','Income');
                        }
                //Rahul - commented CIBIL as CIBIL will be skipped
                //creditprocesstab.cibil = true;
                //nextTabnameMap.put('CIBIL','Income');
                        // V7 Navigation Changes To Be Tested
                        // if(nextTabnameMap.containskey('Credit Assessment')){
                        //     nextTabnameMap.put('Credit Assessment','Income');
                        // }
                        creditprocesstab.incomedetails = true;
                        nextTabnameMap.put('Income','Final Terms');
                        creditprocesstab.finalterms = true;
                        nextTabnameMap.put('Final Terms','Insurance');
                        creditprocesstab.insurancedetails = true;
                        nextTabnameMap.put('Insurance','Risk Summary');
                        creditprocesstab.risksummary = true;
                        if(creditprocesstab.exposureanalysis == true){
                            nextTabnameMap.put('Risk Summary','Exposure Analysis');
                        }else{
                            nextTabnameMap.put('Risk Summary','Credit Assessment');
                        }
                        
                        //EO V7 Navigation Changes
                        //Navigation in Exposure Analysis 
                    }else if(oppRecord.Sanction_Status__c == 'Non-STP' && oppRecord.Is_Pre_Approved__c == true){
                        creditprocesstab.fieldinvestigation =false;
                        creditprocesstab.finalterms = true;
                        creditprocesstab.risksummary = true; 
                        creditprocesstab.cibil = false;
                        if(nextTabnameMap.containskey('View Application Details')) {
                            nextTabnameMap.put('View Application Details', 'Income');
                        } 
                        if(nextTabnameMap.containskey('CIBIL')){
                            nextTabnameMap.remove('CIBIL');
                        }
                        if(creditprocesstab.oppty.Vehicle_Type__c=='New'){
                        //Navigation view application details 
                            //Rahul - commented as CIBIL needs to skip in pre approved
                            /*if(nextTabnameMap.containskey('CIBIL')){
                                nextTabnameMap.put('CIBIL','Income');
                            }*/
                            
                            
                            if(nextTabnameMap.containskey('Income')){
                                nextTabnameMap.put('Income','Final Terms');
                                nextTabnameMap.put('Final Terms','Insurance');
                            }
                            if(nextTabnameMap.containskey('Field Investigation')){
                                nextTabnameMap.remove('Field Investigation');
                            }
                        }else{
                            //Rahul - commented as CIBIL needs to skip in pre approved
                            /*
                            if(nextTabnameMap.containskey('CIBIL')){
                                nextTabnameMap.put('CIBIL','Valuation IDV');
                            }*/
                            if(nextTabnameMap.containskey('Valuation IDV')){
                                nextTabnameMap.put('Valuation IDV','Income');
                }  
                            if(nextTabnameMap.containskey('Income')){
                                nextTabnameMap.put('Income','Final Terms');
                                nextTabnameMap.put('Final Terms','Insurance');
                            }
                            if(nextTabnameMap.containskey('Field Investigation')){
                                nextTabnameMap.remove('Field Investigation');
                            }
                        }
                        //Navigation in valuation IDV 
                        
                        /*if(nextTabnameMap.containskey('Income')){
                            nextTabnameMap.remove('Income');
                        }
                        if(nextTabnameMap.containskey('Final Terms')){
                            nextTabnameMap.remove('Final Terms');
                        }*/
                        //Navigation in Insurance
                        // if(nextTabnameMap.containskey('Insurance')){
                        //     nextTabnameMap.put('Insurance','Exposure Analysis');
                        // }
                        //Navigation in Exposure Analysis
                        creditprocesstab.creditassesment = false; 
                        if(nextTabnameMap.containskey('Exposure Analysis')){
                            nextTabnameMap.put('Exposure Analysis','CAM and Approval Log');
                        }
                        if(creditprocesstab.exposureanalysis == false && nextTabnameMap.containskey('Risk Summary')){
                            nextTabnameMap.put('Risk Summary','CAM and Approval Log');
                        }

                    }else if(oppRecord.Sanction_Status__c == 'Non-STP' && oppRecord.Is_Pre_Approved__c == false){
                        creditprocesstab.finalterms = true;
                        if(nextTabnameMap.containskey('Income')){
                            nextTabnameMap.put('Income','Final Terms');
                            nextTabnameMap.put('Final Terms','Insurance');
                        }

                        //Income Navigation
                       /* if(nextTabnameMap.containskey('Income')){
                            nextTabnameMap.put('Income','Insurance');
                        }*/
   
                    }
                }
                //D2C Changes - Prashanth
                creditprocesstab.nextTabsMap= nextTabnameMap;

                system.debug(' webTabsList ::'+creditprocesstab.nextTabsMap);                 
            }

        } catch (Exception e) {
            system.debug('exception e'+e.getMessage());          
			 throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        return creditprocesstab;
    }

    /*
    * @Class:      CreditProcessingTabs
    * @Created by:  Karunakar M.
    * @Description: Wrapper class have set of parameters to return .
    * @Return:      JSON object : containing tab names.
    */  
    public with sharing class CreditProcessingTabs{   
        @AuraEnabled        
        public String viewAppCurrentTab;
        @AuraEnabled
        public Map<String, String> nextTabsMap {get;set;}
        @AuraEnabled
        public List<String> applicantTypes {get;set;}
        @AuraEnabled
        public String currentTab {get;set;}
        @AuraEnabled
        public Boolean showtab=false;
        @AuraEnabled
        public Boolean viewapplicationdetails =false;
        @AuraEnabled
        public Boolean cibil =false;
        @AuraEnabled
        public Boolean fieldinvestigation =false;
        @AuraEnabled
        public Boolean incomedetails =false;
        @AuraEnabled
        public Boolean valuationidv =false;
        @AuraEnabled
        public Boolean risksummary =false;
        @AuraEnabled
        public Boolean finalterms =false;
        @AuraEnabled
        public Boolean insurancedetails =false;
        @AuraEnabled
        public Boolean exposureanalysis =false;        
        @AuraEnabled
        public Boolean creditassesment = false; 
        @AuraEnabled
        public Boolean vehicleInsurance =false;
        @AuraEnabled
        public Boolean vehicleValuation =false; 
        @AuraEnabled
        public Boolean camapprovallog = false;   
        @AuraEnabled
        public Boolean sanctionofapplication =false; 
        @AuraEnabled
        public Boolean dealnumberandcodegeneration =false;         
        @AuraEnabled
        public Map<String, Map<String,String>> fieldInvestigationsMap;
        @AuraEnabled
        public Map<String, Boolean> fiStatusMap;
        @AuraEnabled
        public List<Id> applicantIds; 
        // D2C_CHANGE - Raman
        @AuraEnabled
        public Opportunity oppty;
        // EO D2C_CHANGE        
        @AuraEnabled
        public String vehicleType;//CISP-4116
    }  
    

    @AuraEnabled
    public static Boolean navigateToViewApplicationData(Id loanApplicationId){
        try {  
            Opportunity oppRecord = [select StageName from Opportunity where Id =:loanApplicationId WITH SECURITY_ENFORCED limit 1];
      
            Stage_Profile_visibility_Custom_Setting__c stageCS = Stage_Profile_visibility_Custom_Setting__c.getInstance(userInfo.getProfileId());
            if(stageCS.Loan_Application_Stage__c == oppRecord.StageName && stageCS.Active__c){
                return true;
            }    
            return false; 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + e.getLineNumber());
        }
    }
    
    /*
    * @Class:      Credit Boolean to disable fields
    * @Created by:  Krishna Chaitany
    * @Description: class have parameter to return .
    * @Return:      boolean : Id stage is credit.
    */  
    /*  
    @AuraEnabled(cacheable=true)
    public static boolean getcreditvalue(Id loanApplicationId){    
    Opportunity loanDetailsList = [SELECT Id,Name,StageName,Product_Type__c,Vehicle_Sub_Category__c,Vehicle_Type__c
    FROM Opportunity WHERE Id =: loanApplicationId WITH SECURITY_ENFORCED LIMIT 1 ];
    boolean credit=false;
    if(loanDetailsList.StageName=='Credit Processing'){
    credit=true;
    }
    return credit;
    }  */
}