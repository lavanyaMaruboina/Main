/**
* @Name         IND_CibilEquifaxReportController
* @Author       Sivakumar.
* @Company      Persistent Systems
* @Description  This class contains all methods related to CIBIL Equifax M4 Module.
* Inputs:       None
* Test Class:   IND_CibilEquifaxReportController_Test
*/
public with sharing class IND_CibilEquifaxReportController {  
    
    /*
    * @Method:      getCibilRecord
    * @Created by:  Sivakumar.
    * @Description: This method will return the required details.
    * @Param:       String -  Applicantion ID
    * @Return:      JSON object containing all the required details.
    */
    @AuraEnabled(cacheable=true)
    public static CibilEquifaxWrapper getCibilRecord(String loanApplicationId){
        try{      
            CibilEquifaxWrapper cibilwrapper = new CibilEquifaxWrapper();
            List<String> applicantTypes = new List<String>();
            for(Applicant__c applicant : [select Id,Applicant_Type__c,Check_Eligibility_Message__c,Check_Eligibility_Match__c, Bureau_Pull_Match__c, Opportunity__r.LeadSource, //D2C Change
                                          Scorecard_Decision__c,ScoreCard_Description__c,opportunity__r.Sub_Stage__c, Name,
                                          (select Id, CIC_No__c, Score__c,CIBIL_Report_URl__c,Maker_Date__c,
                                           Equifax_Report_URl__c from CIBIL_Details__r limit 1)
                                          from Applicant__c where opportunity__c =:loanApplicationId and In_Active_Applicant__c=false WITH SECURITY_ENFORCED 
                                         ])
            {
                if(applicant.opportunity__r.Sub_Stage__c != null){
                    cibilwrapper.loanApplicationSubStage = applicant.opportunity__r.Sub_Stage__c;
                }
                
                if(!applicantTypes.contains(applicant.Applicant_Type__c)  && applicant.Applicant_Type__c == System.label.Borrower){ 
                    cibilwrapper.showBorrowerTab =true; 
                    cibilwrapper.borrowerId =applicant.Id;
                    cibilwrapper.borrowerName = applicant.Name;
                    if(applicant.Scorecard_Decision__c !=null && (applicant.ScoreCard_Description__c!=null || applicant.Opportunity__r.LeadSource == 'D2C')){ //D2C Change, description condition bypassed for d2c
                        cibilwrapper.isBorrowerScoreCardEngTgr =true;
                    }
                    if(!applicant.CIBIL_Details__r.isEmpty()){                                 
                        cibilwrapper.borrower = applicant?.CIBIL_Details__r[0];
                    }                                
                } 
                else if(!applicantTypes.contains(applicant.Applicant_Type__c)  && applicant.Applicant_Type__c == System.label.CoBorrower){
                    cibilwrapper.showCoborrowerTab =true;
                    cibilwrapper.CoborrowerId =applicant.Id;
                    cibilwrapper.coBorrowerName = applicant.Name;
                    if(applicant.Scorecard_Decision__c !=null && applicant.ScoreCard_Description__c !=null){
                        cibilwrapper.isCoBorrowerScoreCardEngTgr =true;
                    }
                    if(!applicant.CIBIL_Details__r.isEmpty()){                  
                        cibilwrapper.coborrower = applicant.CIBIL_Details__r[0];
                    }     
                }           
            }  
            
            for(Final_Term__c finalterms: [select Id, LtvEngine_Ltv__c,PricingEngine_thresholdNetrr__c from Final_Term__c where
                                           Loan_Application__c =:loanApplicationId WITH SECURITY_ENFORCED]){
                cibilwrapper.finalTermsId = finalterms.Id;
                if(finalterms.LtvEngine_Ltv__c !=null ){
                    cibilwrapper.isLtvengineTriggered = true;
                }  
                if(finalterms.PricingEngine_thresholdNetrr__c != null){
                    cibilwrapper.isPricingEngineTriggered =true;
                }            
            }       
            return cibilwrapper;
        }
        catch(Exception e){           
            ErrorLoggerUtil.logErrorEvent('IND_CibilEquifaxReportController', 'getCibilRecord', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    //Wrapper class for getCibilRecord Response
    public class CibilEquifaxWrapper{
        @AuraEnabled
        public  CIBIL_Details__c borrower;
        @AuraEnabled
        public CIBIL_Details__c coborrower;
        @AuraEnabled
        public Boolean showCoborrowerTab = false;
        @AuraEnabled
        public Boolean isLtvengineTriggered =false;
        @AuraEnabled
        public Boolean isPricingEngineTriggered= false;
        @AuraEnabled
        public String CoborrowerId;
        @AuraEnabled
        public Boolean isBorrowerScoreCardEngTgr=false;
        @AuraEnabled
        public Boolean isCoBorrowerScoreCardEngTgr=false;
        @AuraEnabled
        public String finalTermsId{get;set;}    
        
        @AuraEnabled
        public String borrowerId;
        @AuraEnabled
        public Boolean showBorrowerTab = false;
        @AuraEnabled
        public string loanApplicationSubStage;
        
        @AuraEnabled
        public string borrowerName;
        @AuraEnabled
        public string coBorrowerName;
    }

    /*
    * @Method:      getCibilRecordTF
    * @Created by:  Chaynnitt Agarwal.
    * @Description: This method will return the required details. (Specific to Product Type - Tractor)
    * @Param:       String -  Applicantion ID
    * @Return:      JSON object containing all the required details.
    */
    @AuraEnabled(cacheable=true)
    public static CibilEquifaxWrapperTF getCibilRecordTF(String loanApplicationId, String applicantId){
        try{      
            CibilEquifaxWrapperTF cibilwrapper = new CibilEquifaxWrapperTF();
            List<String> applicantTypes = new List<String>();
            List<ApplicantCibilWrapper> applicantCibilWrap = new List<ApplicantCibilWrapper>();
            for(Applicant__c applicant : [select Id,Applicant_Type__c,CRIFF_Report_URL__c, Check_Eligibility_Message__c,Check_Eligibility_Match__c, Bureau_Pull_Match__c, Opportunity__r.LeadSource, //D2C Change
                                          Scorecard_Decision__c,ScoreCard_Description__c,opportunity__r.Sub_Stage__c, Name,opportunity__r.Customer_Type__c,opportunity__r.CRIFF_Report_Initiated__c,
                                          (select Id, CIC_No__c, Score__c,CIBIL_Report_URl__c,Maker_Date__c,
                                           Equifax_Report_URl__c, LastModifiedDate,L2flag__c from CIBIL_Details__r limit 1)
                                          from Applicant__c where opportunity__c =:loanApplicationId and In_Active_Applicant__c=false and Id =: applicantId WITH SECURITY_ENFORCED 
                                         ])
            {
                if(applicant.opportunity__r.Sub_Stage__c != null){
                    cibilwrapper.loanApplicationSubStage = applicant.opportunity__r.Sub_Stage__c;
                }
                
                cibilwrapper.loanApplicationCustomerType = applicant.opportunity__r.Customer_Type__c != null ? applicant.opportunity__r.Customer_Type__c : '';
                cibilwrapper.criffReportInitiated = applicant.opportunity__r.CRIFF_Report_Initiated__c;
                cibilwrapper.criffReportURL = applicant.Applicant_Type__c == 'Borrower' && applicant.CRIFF_Report_URL__c != null ? applicant.CRIFF_Report_URL__c :'';
                ApplicantCibilWrapper wrap = new ApplicantCibilWrapper(applicant.Id,applicant.Name);
                
                if(!applicant.CIBIL_Details__r.isEmpty()){                  
                    wrap.cibil = applicant.CIBIL_Details__r[0];
                    Integer dt = Date.valueOf(wrap.cibil.LastModifiedDate).daysBetween(Date.valueOf(system.today()));
                    if(dt > 30){
                        wrap.isCibilDaysExceeded = true;
                    }
                } 
                
                // if(applicant.Applicant_Type__c == System.label.Borrower){
                //     if(applicant.Scorecard_Decision__c !=null && (applicant.ScoreCard_Description__c!=null || applicant.Opportunity__r.LeadSource == 'D2C')){ //D2C Change, description condition bypassed for d2c
                //         wrap.scoreCardEngTgr =true;
                //     }                               
                // }else{
                    if(applicant.Scorecard_Decision__c !=null && applicant.ScoreCard_Description__c !=null){
                        wrap.scoreCardEngTgr =true;
                    }    
                // }           

                applicantCibilWrap.add(wrap);
            }  
            
            List<FinalTermVehicleDeWrapper> ftvdWrapList = new List<FinalTermVehicleDeWrapper>();
            

            for(Final_Term__c finalterms: [select Id, Vehicle_Detail__c, LtvEngine_Ltv__c,PricingEngine_thresholdNetrr__c, Installment_To_Income_Ratio__c, Fi_Score_Band__c from Final_Term__c where
                                           Loan_Application__c =:loanApplicationId WITH SECURITY_ENFORCED]){

                
                //SFTRAC-121
                FinalTermVehicleDeWrapper ftvdWrap = new FinalTermVehicleDeWrapper();
                ftvdWrap.fianlTermId = finalterms.Id;
                ftvdWrap.vehicleDetailId = finalterms.Vehicle_Detail__c;
                ftvdWrapList.add(ftvdWrap);
                //SFTRAC-121

                cibilwrapper.finalTermsId = finalterms.Id;

                //Check LTV value on Final Term
                if(finalterms.LtvEngine_Ltv__c !=null ){
                    cibilwrapper.isLtvengineTriggered = true;
                }else{
                    cibilwrapper.isLtvengineTriggered = false;
                }  

                //Check Price Engine value on Final Term
                if(finalterms.PricingEngine_thresholdNetrr__c != null){
                    cibilwrapper.isPricingEngineTriggered =true;
                }else{
                    cibilwrapper.isPricingEngineTriggered = false;
                }

                //Check Score Card API value on Final Term
                if(finalterms.Fi_Score_Band__c != null){
                    cibilwrapper.isScoreCardAPITriggered =true;
                }else{
                    cibilwrapper.isScoreCardAPITriggered = false;
                }

                //Check Viablity API value on Final Term
                if(finalterms.Installment_To_Income_Ratio__c != null){
                    cibilwrapper.isViabilityAPITriggered =true;
                }else{
                    cibilwrapper.isViabilityAPITriggered = false;
                }
                
                
            }

            cibilwrapper.finalTermVDIdList = ftvdWrapList; //SFTARC-121
            system.debug('cibilwrapper.finalTermVDIdList '+cibilwrapper.finalTermVDIdList);
            //SFTRAC-121 Start
            cibilwrapper.vehicleDetailID = new List<String>();
            List<Vehicle_Detail__c> vehicleDetailIdList = [SELECT Id FROM Vehicle_Detail__c WHERE Loan_Application__c = :loanApplicationId];
            for (Vehicle_Detail__c vehicleDetailRec : vehicleDetailIdList) {
                if (!cibilwrapper.vehicleDetailID.contains(vehicleDetailRec.Id)) {
                    cibilwrapper.vehicleDetailID.add(vehicleDetailRec.Id);
                }
            }
            //SFTRAC-121 End
            
            cibilwrapper.applicant = applicantCibilWrap;

            return cibilwrapper;
        }
        catch(Exception e){           
            ErrorLoggerUtil.logErrorEvent('IND_CibilEquifaxReportController', 'getCibilRecord', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    //Wrapper class for getCibilRecord Response for product type Tractor
    public class CibilEquifaxWrapperTF{
        @AuraEnabled
        public  List<ApplicantCibilWrapper> applicant;
        @AuraEnabled
        public Boolean isLtvengineTriggered =false;
        @AuraEnabled
        public Boolean isPricingEngineTriggered= false;
        @AuraEnabled
        public Boolean isScoreCardAPITriggered= false;
        @AuraEnabled
        public Boolean isViabilityAPITriggered= false;
        @AuraEnabled
        public String finalTermsId{get;set;}    
        @AuraEnabled
        public string loanApplicationSubStage;
        @AuraEnabled
        public Boolean criffReportInitiated= false;
        @AuraEnabled
        public string loanApplicationCustomerType;
        @AuraEnabled
        public string criffReportURL;
        @AuraEnabled
        public List<String> vehicleDetailID;

        @AuraEnabled
        public  List<FinalTermVehicleDeWrapper> finalTermVDIdList;

        public CibilEquifaxWrapperTF(){
            //Default Constructor
        }
    }

    public class FinalTermVehicleDeWrapper{
        @AuraEnabled
        public String fianlTermId;
        @AuraEnabled
        public String vehicleDetailId;

        public FinalTermVehicleDeWrapper(){
        }
    }

    public class ApplicantCibilWrapper{
        @AuraEnabled
        public  CIBIL_Details__c cibil;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String id;
        @AuraEnabled
        public Boolean scoreCardEngTgr = false;
        @AuraEnabled
        public Boolean isCibilDaysExceeded = false;


        public ApplicantCibilWrapper(String id, String name){
            this.id = id;
            this.name = name;
        }
    }
    
    /*
    * @Method:      getCIBILDetails
    * @Created by:  Sivakumar.
    * @Description: This method will return the cibil details.
    * @Param:       String -  cibil record id
    * @Return:      CIBIL_Details__c object containing all the required details.
    */
    @AuraEnabled(cacheable=true)
    public static CIBIL_Details__c getCIBILDetails(string cibilId){
        try{
            List<CIBIL_Details__c> cibilRecord  = [select Id, CIC_No__c,Maker_Date__c,Score__c, Applicant__r.Applicant_Type__c,CIBIL_Report_URl__c,Equifax_Report_URl__c
                           from CIBIL_Details__c where Id =:cibilId limit 1];
            if(!cibilRecord.isEmpty()){
                return cibilRecord[0];
            }  
            else{
                return null;
            }              
        } catch(exception e){
            ErrorLoggerUtil.logErrorEvent('IND_CibilEquifaxReportController', 'getCIBILDetails', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        } 
    }
}