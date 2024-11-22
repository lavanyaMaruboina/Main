/*
Author:        Pravallika K
Company:       Persistent Systems
Description:   Final Offer Class for IND_LWC_FinalOfferpage
Test Class: 

History
Date            Author              Comments
-------------------------------------------------------------
22-02-2022      Pravallika K        Created
------------------------------------------------------------*/
public class IND_GetFinalOfferRecords { 
    
    public final static String JOURENY_STATUS_STP = 'Non-STP';
    public final static String JOURENY_STAUS_STOP = 'stop';
    public final static String GREEN = 'GREEN'; 
    public final static String LOADING = 'LOADING';
    
    public final static String DARK_GREEN = 'Dark Green';
    public final static String LIGHT_GREEN = 'Light Green';
    public final static String YELLOW = 'YELLOW';
    public final static String LIGHT_RED = 'Light Red';
    public final static String DARK_RED = 'Dark Red';
    public final static String Green1 = 'Green';
    public final static String Yellow1 = 'Yellow';
    public final static String Red = 'Red';
    
    public final static String CLOSED_LOST = 'Closed Lost';
    
    
    public static void errorMethod(String clsName, String methodname, String apex, Exception e){
        ErrorLoggerUtil.logErrorEvent(clsName, methodname, apex, e); 
    }
    
    @AuraEnabled
    public static Boolean applicantRejectMethod(String loanId){
        Boolean isdarkbln = false;
        try{
            List<Opportunity> oppLstObj = new List<Opportunity>();
           // Final_Term__c finTermsObj = [SELECT id, Loan_Application__c, Loan_Application__r.Journey_Status__c FROM Final_Term__c WHERE id =: offerid WITH SECURITY_ENFORCED LIMIT 1];
            
            for(Applicant__c appObj:[SELECT id,Scorecard_Decision__c,Applicant_Type__c 
                                     FROM Applicant__c
                                     WHERE Opportunity__c = :loanId and In_Active_Applicant__c = False ])
            {
                String scDesionStr = appObj.Scorecard_Decision__c;
               
                if( scDesionStr.equalsIgnoreCase(DARK_RED) ){
                    
                    isdarkbln = true;
                }
            }
            
            if( isdarkbln == true){
                oppLstObj.add(new Opportunity(stageName=CLOSED_LOST, id=loanId));
            }
            
            if(oppLstObj.size() > 0){
                update oppLstObj;
            }
            return isdarkbln;
        }
        catch(Exception e) {
            errorMethod(System.Label.IND_GetFinalOfferRecords, ' applicantRejectMethod ', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
            
        }
    }
    
    
    /*
* @Method Name: getDetails
* @Created by:     Anji Yeruva
* @Description: 
* @Input:  String - Final Offer Id
* @Return:  String
*/
    @AuraEnabled
    public static string getDetails(String loanId) {
        String getscoreDesionStr;
        String finalofferAccesslevel = null;
        Boolean color;
        Set<String> stcolors= new Set<String>();
        String finalColor;
        try {
           
            string serviceName = 'Offer Engine';
        
        boolean isSuccess=false;        
        for(Integration_Log__c integLog : Utilities.getIntegrationLogs(serviceName,loanId))
            {
                if(integLog.Status__c =='Success'){
                    isSuccess =true;

                }
            }
 			String getJourStats;                   
                    
             for (Applicant__c applcnt: [SELECT Id, Scorecard_Decision__c, opportunity__r.Sanction_Status__c FROM Applicant__c where 
                                                Opportunity__c =: loanId and In_Active_Applicant__c = False  WITH SECURITY_ENFORCED]) {
                        
                    getJourStats = applcnt.opportunity__r.Sanction_Status__c;
                    getscoreDesionStr = applcnt.Scorecard_Decision__c;
                        
                        if(!stcolors.contains(getscoreDesionStr)){
                            stcolors.add(getscoreDesionStr);
                        }
                    }
                    if (stcolors.contains(DARK_GREEN)){
                        finalColor = GREEN; 
                    }
                    if (stcolors.contains(LIGHT_GREEN)){
                        finalColor = GREEN;
                    }
                    if (stcolors.contains(YELLOW)){
                        finalColor = YELLOW;
                    }
                    if (stcolors.contains(LIGHT_RED)){
                        finalColor = Red;
                    }
                    if (stcolors.contains(DARK_RED)){
                        finalColor = Red;
                    }
                
                    if (!isSuccess || finalColor != GREEN)
                    {
                        finalofferAccesslevel = LOADING;
                    }
                    else if(string.isNotBlank(getJourStats)  && getJourStats == system.label.Non_STP && finalColor == GREEN)
                    {
                        finalofferAccesslevel = YELLOW;
                    }
                    else if(string.isNotBlank(getJourStats)  && getJourStats == system.label.STP && finalColor == GREEN)
                    {
                        finalofferAccesslevel = GREEN;
                    }
                    System.debug('color'+finalofferAccesslevel);
                    return finalofferAccesslevel;
                
            
        } catch (Exception e) {
            system.debug('exception e'+e.getLineNumber());
            system.debug('exception e'+e.getMessage() );
            errorMethod(System.Label.IND_GetFinalOfferRecords, ' getDetails ', System.Label.Apex, e);
            
           
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    /*
* @Method Name: getFinalOfferDetailsflag
* @Created by:     Anji Yeruva
* @Description: 
* @Input:  String - Final Offer Id
* @Return:  String
*/
    @AuraEnabled
    public static String getFinalOfferDetailsflag(String loanId) {
        String finalofferAccesslevel;
        try {
            String serviceName = 'FinalTermsEligiblitycheck';
            Retry_Count__c retryObj = [SELECT id, IsAPIFailed__c FROM Retry_Count__c  WHERE id =: loanId and Service_Name__c = :serviceName  WITH SECURITY_ENFORCED ];
            Applicant__c appObj = [SELECT Id, Opportunity__r.Journey_Status__c,Scorecard_Decision__c FROM Applicant__c where Opportunity__c =: loanId and In_Active_Applicant__c = False  WITH SECURITY_ENFORCED LIMIT 1];
            
            String getJourStats = appObj.Opportunity__r.Journey_Status__c;
            String getscoreDesionStr = appObj.Scorecard_Decision__c;
            Boolean darklighGreenbln;
            
            Boolean darkgreenBln = getscoreDesionStr.equalsIgnoreCase(DARK_GREEN);
            Boolean lightgreenBln = getscoreDesionStr.equalsIgnoreCase(LIGHT_GREEN);
            Boolean darkredBln = getscoreDesionStr.equalsIgnoreCase(DARK_RED);
            
            if (String.isNotEmpty(getscoreDesionStr)) {
                
                if (retryObj.IsAPIFailed__c == true && (darkgreenBln == false || lightgreenBln == false || darkredBln == false)) {
                    finalofferAccesslevel = LOADING;
                } else if ((darkgreenBln == true || lightgreenBln == true) && getJourStats == JOURENY_STATUS_STP) {
                    finalofferAccesslevel = GREEN;
                } else if ((darkgreenBln == true || lightgreenBln == true) && getJourStats == JOURENY_STAUS_STOP) {
                    finalofferAccesslevel = LOADING;
                }
            } else {
                finalofferAccesslevel = 'no score desion';
            }
            
            return finalofferAccesslevel;
            
        } catch (Exception e) {
            return String.valueof(e.getLineNumber());
        }
    }
    
    /*
* @Method Name: getFinalTerms
* @Created by:     Pravallika K
* @Description: Method to return Final Offer Details to IND_LWC_FinalOfferpage
* @Input:  List of applicants
* @Return:  Map 
*/
    @AuraEnabled(cacheable = true)
    public static Map < String, String > getFinalOfferRecord(string loanId) {
        Map < String, String > ftmap = new Map < String, String > ();
        try {
                 Final_Term__c finalTerm = [select id, name,Loan_Amount__c,Loan_Application__r.Required_Loan_amount__c, Installment_Type__c,
                                               Loan_Application__r.Required_Tenure__c,Repayment_mode__c,Do_you_want_to_initiate_e_NACH__c,//CISP-4181 Added Repayment_mode__c and Do_you_want_to_initiate_e_NACH__c in fields to query
                                               Tenure__c, CRM_IRR__c, EMI_Amount__c,//, Risk_band__c
                                               Holiday_period__c,Net_IRR__c,Gross_IRR__c FROM Final_Term__c where Loan_Application__c =: loanId 
                                               WITH SECURITY_ENFORCED limit 1
                                              ];                    
                    Applicant__c applicant = [SELECT id, Name, Contact_number__c, DocAuth_Application_Id__c, Opportunity__c
                                              FROM Applicant__c where Opportunity__c =: loanId
                                              AND Applicant_Type__c =: system.Label.Borrower and In_Active_Applicant__c = False 
                                              WITH SECURITY_ENFORCED LIMIT 1
                                             ];
                    system.debug('Applicant : ' + applicant);
                    Opportunity opty=[select Application_number__c,Total_Funded_Premium__c,Id,Name,Product_Type__c,LeadSource from Opportunity where Id=:loanId];//OLA-139
                    Vehicle_Detail__c vdetails;
                    vdetails = [SELECT id, Make__c, Model__c, Variant__c FROM Vehicle_Detail__c
                                WHERE Loan_Application__c =: loanId
                                WITH SECURITY_ENFORCED LIMIT 1
                               ];
                    system.debug('Vehicle Details : ' + vdetails);
                    
                    Map < String, String > ftDetails = new Map < String, String > ();
                    ftmap.put('Name', '' + applicant.Name);
                    ftmap.put('Application Number', '' + opty.Application_number__c);
                    ftmap.put('Contact Number', '' + applicant.Contact_number__c);
                    ftmap.put('Make Model Variant', '' + vdetails.Variant__c); //CISP-4136 Only Variant will be populate from MMV
                    ftmap.put('Final Term RecordId', '' + finalTerm.Id); // CISP-4181 Added finalTerm recordId in Map
                    ftmap.put('EMI', '' + finalTerm.EMI_Amount__c);//SFTRAC-88
                    if((opty.LeadSource =='OLA') || (opty.LeadSource =='Hero') || (opty.LeadSource =='D2C')){
                    ftmap.put('Frequency', '' + 'Monthly');//CISP-19465 && CISH-72
                    }
                    ftmap.put('Installment type', '' + finalTerm.Installment_Type__c);//SFTRAC-88
                    Integer finAmount;
                    if(finalTerm.Loan_Amount__c != null)
                    {
                        finAmount = Integer.valueOf(finalTerm.Loan_Amount__c) + Integer.valueOf(opty.Total_Funded_Premium__c);
                        ftmap.put('Loan Amount', '' + finAmount);
                    }
                    else{
                        if(finalTerm.Loan_Application__r.Required_Loan_amount__c != null){
                            finAmount = Integer.valueOf(finalTerm.Loan_Application__r.Required_Loan_amount__c) + Integer.valueOf(opty.Total_Funded_Premium__c);
                            ftmap.put('Loan Amount', '' + finAmount);
                        }else{
                            ftmap.put('Loan Amount', '' );
                        }
                    }
                    if(finalTerm.Tenure__c != null)
                    {
                        ftmap.put('Tenure', '' + finalTerm.Tenure__c);
                    }
                    else{
                        ftmap.put('Tenure', '' + finalTerm.Loan_Application__r.Required_Tenure__c);
                    }
                    if(finalTerm.CRM_IRR__c != null)
                    {
                        ftmap.put('CRM IRR', '' + finalTerm.CRM_IRR__c);
                    }else{
                        ftmap.put('CRM IRR', '');
                    }
                    //ftmap.put('CRM IRR', '' + finalTerm.CRM_IRR__c);
                    if(finalTerm.Holiday_period__c != null && finalTerm.Tenure__c != null)
                    {
                        String numberOfInstallments = Integer.valueof(finalTerm.Holiday_period__c) == 0 ? finalTerm.Tenure__c : Integer.valueof(finalTerm.Holiday_period__c) == 30 ? String.valueof(Integer.valueof(finalTerm.Tenure__c) - 1) : '';
                        if(opty.LeadSource=='OLA'){numberOfInstallments = finalTerm.Tenure__c;}//OLA-139
                        ftmap.put('No of Instalments', '' + numberOfInstallments);
                    }else{
                        ftmap.put('No of Instalments', '');
                    }
                    if(finalTerm.EMI_Amount__c != null)
                    {
                        ftmap.put('EMI Amount', '' + finalTerm.EMI_Amount__c);
                    }else{
                        ftmap.put('EMI Amount', '');
                    }
                    //CISP-4181 Added Do_you_want_to_initiate_e_NACH__c and Repayment_mode__c in map
                    if(finalTerm.Do_you_want_to_initiate_e_NACH__c == true) {
                        ftmap.put('Do you want to initiate eNACH', 'Yes' );
                    } else {
                        ftmap.put('Do you want to initiate eNACH', 'No');
                    }
                    if(finalTerm.Repayment_mode__c == 'N') {
                        ftmap.put('Is Repayment Mode eNACH', 'Yes');
                    } else {
                        ftmap.put('Is Repayment Mode eNACH', 'No');
                    }
                   // ftmap.put('EMI Amount', '' + finalTerm.EMI_Amount__c);//not null
                    system.debug('Ftmap : ' + ftmap);
                    return ftmap;
                
        } catch (Exception e) {
            errorMethod(System.Label.IND_GetFinalOfferRecords, ' getFinalOfferRecord ', System.Label.Apex, e);
            
            /* Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.IND_GetFinalOfferRecords, ' getFinalTerms ', System.Label.Apex, e);
if (Schema.sObjectType.Error_Log__c.isCreateable()) {
insert errorLogRecord;
}*/
            throw new AuraHandledException(System.Label.ExceptionMessage);
}
    }
        /*
* @Method Name: FinalOfferRecordForTractorWrapper
* @Created by:     Satyam Singh
* @Description: Method to return Final Offer Details as per multiple vehicle details
* @Input:  loanId
* @Return:  FinalOfferRecordForTractorWrapper 
*/
    
    //Added for Final Offer Record for Tractor
    @AuraEnabled(cacheable = true)
    public static FinalOfferRecordForTractorWrapper getFinalOfferRecordForTractor(string loanId) {
        FinalOfferRecordForTractorWrapper finalOffWrap = new FinalOfferRecordForTractorWrapper();
        Map<String, Map<String, String>> ftmapForTractor = new Map<String, Map<String, String>> ();
        try {                  
                Applicant__c applicant = [SELECT id, Name, Contact_number__c, DocAuth_Application_Id__c, Opportunity__c
                                          FROM Applicant__c where Opportunity__c =: loanId
                                          AND Applicant_Type__c =: system.Label.Borrower and In_Active_Applicant__c = False 
                                          WITH SECURITY_ENFORCED LIMIT 1];
                system.debug('Applicant : ' + applicant);
                Opportunity opty=[select Application_number__c,Total_Funded_Premium__c,Id,Name,Product_Type__c,LeadSource from Opportunity where Id=:loanId];//OLA-139
                system.debug('opty : ' + opty);
                List<Vehicle_Detail__c> vdetails;
                vdetails = [SELECT id, Make__c, Model__c, Variant__c,Total_Funded_Amount__c,Required_Tenure__c,Required_CRM_IRR__c, (SELECT id, name,Loan_Amount__c,Loan_Application__r.Required_Loan_amount__c,Installment_Frequency__c, Installment_Type__c,No_of_Installment__c,
                            Loan_Application__r.Required_Tenure__c,Repayment_mode__c,Do_you_want_to_initiate_e_NACH__c,
                            Tenure__c, Required_CRM_IRR__c, EMI_Amount__c, Holiday_period__c, Net_IRR__c, Gross_IRR__c, Derived_CRM_IRR__c FROM Final_Terms__r) FROM Vehicle_Detail__c WHERE Loan_Application__c =: loanId
                            WITH SECURITY_ENFORCED ORDER BY CreatedDate ASC LIMIT 50000];
                system.debug('Vehicle Details: ' + vdetails);
                system.debug('Vehicle Details size: ' + vdetails.size());
                //Integer counterForTractor = 1;
                
                if(vdetails.size() > 0){
                for(Vehicle_Detail__c vehDet : vdetails){
                    if(!ftmapForTractor.containsKey(vehDet.Id)){
                        Map <String, String> ftDetailsForTractor = new Map < String, String > ();
                        ftDetailsForTractor.put('Name', '' + applicant.Name);
                        ftDetailsForTractor.put('Application Number', '' + opty.Application_number__c);
                        ftDetailsForTractor.put('Contact Number', '' + applicant.Contact_number__c);
                        ftDetailsForTractor.put('Make Model Variant', '' + vehDet.Variant__c);
                        List<Final_Term__c> relFinalTearmRec = vehDet.Final_Terms__r;
                    if(relFinalTearmRec.size()>0){
                        ftDetailsForTractor.put('Final Term RecordId', '' + relFinalTearmRec[0].Id); 
                        ftDetailsForTractor.put('Frequency', '' + relFinalTearmRec[0].Installment_Frequency__c);
                        ftDetailsForTractor.put('Installment type', '' + relFinalTearmRec[0].Installment_Type__c);
                    Integer finAmount;
                    if(relFinalTearmRec[0].Loan_Amount__c != null)
                    {
                        finAmount = Integer.valueOf(relFinalTearmRec[0].Loan_Amount__c == null ? '0' : relFinalTearmRec[0].Loan_Amount__c) + Integer.valueOf(vehDet.Total_Funded_Amount__c == null ? 0 : vehDet.Total_Funded_Amount__c);
                        ftDetailsForTractor.put('Loan Amount', '' + finAmount);
                    }
                    else{
                        if(vehDet.Loan_Amount__c != null){
                            finAmount = Integer.valueOf(vehDet.Loan_Amount__c == null ? 0 : vehDet.Loan_Amount__c) + Integer.valueOf(vehDet.Total_Funded_Amount__c == null ? 0 : vehDet.Total_Funded_Amount__c);
                            ftDetailsForTractor.put('Loan Amount', '' + finAmount);
                        }else{
                            ftDetailsForTractor.put('Loan Amount', '' );
                        }
                    }
                    if(relFinalTearmRec[0].Tenure__c != null)
                    {
                        ftDetailsForTractor.put('Tenure', '' + relFinalTearmRec[0].Tenure__c);
                    }
                    else{
                        ftDetailsForTractor.put('Tenure', '' + vehDet.Required_Tenure__c);
                    }
                    if(relFinalTearmRec[0].Required_CRM_IRR__c != null)
                    {
                        ftDetailsForTractor.put('Required CRM IRR', '' + relFinalTearmRec[0].Required_CRM_IRR__c);
                    }else{
                        ftDetailsForTractor.put('Required CRM IRR', String.valueOf(vehDet.Required_CRM_IRR__c));
                    }
                    //SFTRAC-2301 Start
                    if(relFinalTearmRec[0].Derived_CRM_IRR__c != null)
                    {
                        ftDetailsForTractor.put('Derived CRM IRR', '' + relFinalTearmRec[0].Derived_CRM_IRR__c);
                    }else{
                        ftDetailsForTractor.put('Derived CRM IRR', '');
                    }
                    //SFTRAC-2301 End
                    if(relFinalTearmRec[0].No_of_Installment__c != null)
                    {
                        Decimal numberOfInstallments = relFinalTearmRec[0].No_of_Installment__c;
                        ftDetailsForTractor.put('No of Instalments', '' + numberOfInstallments);
                    }else{
                        ftDetailsForTractor.put('No of Instalments', '');
                    }
                    if(relFinalTearmRec[0].EMI_Amount__c != null)
                    {
                        ftDetailsForTractor.put('EMI Amount', '' + relFinalTearmRec[0].EMI_Amount__c);
                    }else{
                        ftDetailsForTractor.put('EMI Amount', '');
                    }
                    if(relFinalTearmRec[0].Do_you_want_to_initiate_e_NACH__c == true) {
                        ftDetailsForTractor.put('Do you want to initiate eNACH', 'Yes' );
                    } else {
                        ftDetailsForTractor.put('Do you want to initiate eNACH', 'No');
                    }
                    if(relFinalTearmRec[0].Repayment_mode__c == 'N') {
                        ftDetailsForTractor.put('Is Repayment Mode eNACH', 'Yes');
                    } else {
                        ftDetailsForTractor.put('Is Repayment Mode eNACH', 'No');
                    }
                  }
                      ftmapForTractor.put(vehDet.Id , ftDetailsForTractor);
                    //ftmapForTractor.put('Final Term Detail '+counterForTractor , ftDetailsForTractor);
                    //counterForTractor++;
                    }
                }
                finalOffWrap.ftmapForTractor = ftmapForTractor;
                if(opty.Product_Type__c == 'Tractor'){
                    finalOffWrap.isProductTypeTractor =  true;
                }else{
                    finalOffWrap.isProductTypeTractor =  false;
                }
            }
                    system.debug('ftmapForTractor : ' + ftmapForTractor);
                    return finalOffWrap;
                
        } catch (Exception e) {
            errorMethod(System.Label.IND_GetFinalOfferRecords, ' getFinalOfferRecord ', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    public class FinalOfferRecordForTractorWrapper{
        @AuraEnabled 
        public Map<String, Map<String, String>> ftmapForTractor {get;set;}
        @AuraEnabled
        public Boolean isProductTypeTractor {get;set;}
    }

     /*
    * @Method:      checkRepaymentRecordAndRetryCount
    * @Created by:  Udit Singhal
    * @Description: This method will return the the repaymentRecordId and retryCount in key value pairs
    * @Param:       String - loanApplicationId (Id of the loan application record)
    * @Return:      String
    */
     @AuraEnabled
    public static string checkRepaymentRecordAndRetryCount(String loanApplicationId) {
        try {
            Map<String,object> mapObj = new Map<String,object>();
            Decimal retryCount = 0;
            if (loanApplicationId != null) {
                List<Repayments__c> repaymentList = new List<Repayments__c>();
                repaymentList = [SELECT Id
                                 FROM Repayments__c
                                 WHERE Loan_Application__c = :loanApplicationId
                                 WITH SECURITY_ENFORCED
                                ];
                if (!repaymentList.isEmpty()) {
                    List<Retry_Count__c> retryCountList = new List<Retry_Count__c>();
                    retryCountList = [SELECT Id, Count__c
                                      FROM Retry_Count__c
                                      WHERE Loan_Application_Id__c = :loanApplicationId
                                      AND Service_Name__c = :System.label.Initiate_ENACH_Attempts
                                      AND User_Id__c =: UserInfo.getUserId()
                                      WITH SECURITY_ENFORCED
                                     ];
                    
                    if(!retryCountList.isEmpty()) {
                        retryCount = retryCountList[0].Count__c;
                    }
                    
                    mapObj.put('repaymentRecordId', repaymentList[0].Id);
                    mapObj.put('retryCount', retryCount);

                    return JSON.serialize(mapObj);
                } else {
                    return null;
                }
            } else {
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    /*
    * @Method:      assingedLeadtoTFCVO
    * @Created by:  Gaurav Rawat
    * @Updated by:  Aakash J added Round Robin method 
    * @Description: Lead assinged to TF CVO by Round Robin method 
    * @Param:       String - loanApplication ID
    * @Return:      Boolean
    */
    @AuraEnabled
    public static Boolean assingedLeadtoTFCVO(String loanApplicationId){
        try{
            if(loanApplicationId !=null ){
                List<Applicant__c> applicantLst = new List<Applicant__c>([Select Id,Opportunity__r.AccountId,Journey_Stage__c FROM Applicant__c Where Opportunity__c =: loanApplicationId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED]);
                if(applicantLst.size() > 0){
                    for(Applicant__c applicant : applicantLst){
                        applicant.Journey_Stage__c = 'User Details';
                    }
                    update applicantLst;
    
                    List<AccountTeamMember> userList = [SELECT Id, UserId, CVO_Counter__c FROM AccountTeamMember WHERE TeamMemberRole = 'CVO' AND AccountId =: applicantLst[0].Opportunity__r.AccountId AND User.isActive = true WITH SECURITY_ENFORCED Order by LastModifiedDate ASC];

                    Map<Id, Integer> mapOfUserIdToCounter = new Map<Id, Integer>();
                    List<AccountTeamMember> listAccountTeamMemberToUpdate = new List<AccountTeamMember>(); 
                    Map<Id, AccountTeamMember> mapOfUserIdToAccountTeamMember = new Map<Id, AccountTeamMember>();

                    System.debug('+++++ userList is: '+userList);
                    if(!userList.isEmpty()) {
                        String userType = UserInfo.getUserType();
                        if(userType == 'PowerPartner'){
                         String result = OffRollEmpApproval.createCase(loanApplicationId,System.Label.Tractor,'');
                        if(result == 'not entered'){
                            throw new AuraHandledException(System.Label.ExceptionMessage);
                        }}

                        for(AccountTeamMember accountTeamMember : userList) {
                            System.debug('+++++ accountTeamMember is: '+accountTeamMember);
                            accountTeamMember.CVO_Counter__c = accountTeamMember.CVO_Counter__c == null ? 0 : accountTeamMember.CVO_Counter__c;//change made for round robin
                            Decimal cvoCount = accountTeamMember.CVO_Counter__c == null ? 0 : accountTeamMember.CVO_Counter__c;
                            mapOfUserIdToCounter.put(accountTeamMember.userId,Integer.valueOf(cvoCount));
                            mapOfUserIdToAccountTeamMember.put(accountTeamMember.userId,accountTeamMember);
                        }
                    }
                    
                    if(!mapOfUserIdToCounter.isEmpty()){
                        Id assignmenedUserId = getLowestCounterCVO(mapOfUserIdToCounter);

                        if(mapOfUserIdToCounter != null && mapOfUserIdToCounter.size()>0) {
                            System.debug('+++++  assignmenedUserId is: '+assignmenedUserId);
                        
                        Opportunity opp = new Opportunity();
                        opp.id = loanApplicationId;
                            opp.OwnerId = assignmenedUserId;
                        opp.StageName = System.Label.Credit_Processing;
                        opp.LastStageName__c = System.Label.Credit_Processing;
                        opp.Sub_Stage__c = System.Label.View_Application_Details;
                        opp.View_Application_Sub_Stages__c = System.Label.Lead_KYC_Details;
                        update opp;

                            //Push the detail to SET of assignmentUserId, declare the Set at top                    
                            mapOfUserIdToCounter.put(assignmenedUserId, mapOfUserIdToCounter.get(assignmenedUserId) + 1);
                            System.debug('+++++ mapOfUserIdToCounter '+mapOfUserIdToCounter);
                        }

                    }

                    // Update counter on FI Executive
                    for(Id assignmentUserId : mapOfUserIdToCounter.keySet()) {
                        AccountTeamMember cvoAccountTeamMember = mapOfUserIdToAccountTeamMember.get(assignmentUserId);
                        System.debug('+++++ cvoAccountTeamMember is '+cvoAccountTeamMember);
                        System.debug('+++++ cvoAccountTeamMember counter '+cvoAccountTeamMember.CVO_Counter__c);
                        if(mapOfUserIdToCounter.get(assignmentUserId) > cvoAccountTeamMember.CVO_Counter__c) {
                            System.debug('+++++ CVO_Counter__c '+cvoAccountTeamMember.CVO_Counter__c+' assignmentUserId '+mapOfUserIdToCounter.get(assignmentUserId));
                            cvoAccountTeamMember.CVO_Counter__c = mapOfUserIdToCounter.get(assignmentUserId);
                            listAccountTeamMemberToUpdate.add(cvoAccountTeamMember);
                        }
                    }
                    System.debug('+++++ list to update '+listAccountTeamMemberToUpdate);
                    if(!listAccountTeamMemberToUpdate.isEmpty()) {
                        //update listAccountTeamMemberToUpdate;
                        Utilities.updateAccountTeamMembers(listAccountTeamMemberToUpdate);//SFTRAC-1339
                        return true;
                    }else{
                        return false;
                    }
                }else{
                    return false;
                }
            }else{
                return false;
            }
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_GetFinalOfferRecords', 'assingedLeadtoTFCVO', System.Label.Apex, e,loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    @Testvisible
    private static Id getLowestCounterCVO(Map<Id, Decimal> mapOfUserIdToCounter) {
        Decimal lowestCounterValue = null;
        Id assignmentUserId = null;
        
        // Iterate through the map entries to find the lowest counter value
        for (Id userId : mapOfUserIdToCounter.keySet()) {
            Decimal counterValue = mapOfUserIdToCounter.get(userId);
            if (lowestCounterValue == null || counterValue < lowestCounterValue) {
                lowestCounterValue = counterValue;
                assignmentUserId = userId;
            }
        }
        return assignmentUserId;
    }
}