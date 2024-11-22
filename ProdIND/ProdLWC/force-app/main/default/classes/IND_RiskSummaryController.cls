/**
* @Name         IND_RiskSummaryController
* @Author       Sivakumar Gudipati
* @Company      Persistent Systems
* @Description  This class contains all methods related to Risk Summary
* Test Class:   IND_RiskSummaryController_Test
* History:     
*/

public with sharing class IND_RiskSummaryController {
    
    /*
    * @Method:      getApplicants
    * @Created by:  Sivakumar Gudipati
    * @Description: This method will return the applicant record containing the remark feild value.
    * @Param:       String -  Applicantion ID
    * @Param:       String - Applicant Type
    * @Return:      object of applicant record.
    */
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getApplicants(String loanAppId){
        
        List<Opportunity> loanApplications = new List<Opportunity>();
        String productType = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanAppId LIMIT 1].Product_Type__c;

        if(productType == System.Label.Tractor){
            loanApplications = [
                SELECT Id, On_Road_price_carwale__c,Basic_Price__c,Selling_Price__c,Grid_value__c,Imputed_IRR__c,Net_IRR__c,Funding_on_ORP__c,Total_Funded_Premium__c,
                Funding_on_Ex_Showroom__c,On_Road_price__c,Ex_showroom_price__c,Received_AML_API_response__c,Sub_Stage__c,Vehicle_Type__c,Product_Type__c,Is_Revoked__c,
                    (SELECT Id, Scorecard_Decision__c, Check_Eligibility_Message__c, Applicant_Type__c FROM Applicants__r where In_Active_Applicant__c = false),
                    (SELECT Id ,FIwaiver_presentAddress__c , Tenure__c ,PricingEngine_thresholdNetrr__c ,CRM_IRR__c ,Inputted_IRR__c,Net_IRR__c,
                        LtvEngine_Ltv__c ,OfferengineMaxTenure__c ,OfferengineMinTenure__c ,Loan_Amount__c ,Fi_Score_Band__c,
                        OfferengineMaxLoanAmount__c ,OfferengineMinLoanAmount__c ,FIwaiver_currentAddress__c,
                        FIwaiver_offAddress__c ,Current_Residence_FI__c,FIwaiver_co_currentAddress__c,FIwaiver_co_offAddress__c,
                        FIwaiver_co_presentAddress__c,Required_CRM_IRR__c,Vehicle_Detail__r.Variant__c
                    FROM Final_Terms__r WHERE Vehicle_Detail__c != null ORDER BY Vehicle_Detail__r.CreatedDate ASC), (SELECT Id, Valuation_price__c, Selling_Price__c, Grid_value__c,Base_Prices__c FROM Vehicle_Details__r)
                FROM Opportunity 
                WHERE Id = :loanAppId
            ];
        }
        else{
            loanApplications = [
                SELECT Id, On_Road_price_carwale__c,Basic_Price__c,Selling_Price__c,Grid_value__c,Imputed_IRR__c,Net_IRR__c,Funding_on_ORP__c,Total_Funded_Premium__c,
                Funding_on_Ex_Showroom__c,On_Road_price__c,Ex_showroom_price__c,Received_AML_API_response__c,Sub_Stage__c,Vehicle_Type__c,Product_Type__c,Is_Revoked__c,
                    (SELECT Id, Scorecard_Decision__c, Check_Eligibility_Message__c, Applicant_Type__c FROM Applicants__r where In_Active_Applicant__c = false),
                    (SELECT Id ,FIwaiver_presentAddress__c , Tenure__c ,PricingEngine_thresholdNetrr__c ,CRM_IRR__c ,Inputted_IRR__c,Net_IRR__c,
                        LtvEngine_Ltv__c ,OfferengineMaxTenure__c ,OfferengineMinTenure__c ,Loan_Amount__c ,
                        OfferengineMaxLoanAmount__c ,OfferengineMinLoanAmount__c ,FIwaiver_currentAddress__c,
                        FIwaiver_offAddress__c ,Current_Residence_FI__c,FIwaiver_co_currentAddress__c,FIwaiver_co_offAddress__c,
                        FIwaiver_co_presentAddress__c,Required_CRM_IRR__c
                    FROM Final_Terms__r), (SELECT Id, Valuation_price__c, Selling_Price__c, Grid_value__c,Base_Prices__c FROM Vehicle_Details__r)
                FROM Opportunity 
                WHERE Id = :loanAppId
            ];//CISP-2735 - Is_Revoked__c // CISP-2877 - Total_Funded_Premium__c
        }
         
        return loanApplications;
    }
    
    // Update Risk Summary data
    @AuraEnabled
    public static String updateRiskSummaryData(String finalTerm, String loanApps){
        try {
            Final_Term__c ft = (Final_Term__c) JSON.deserialize(finalTerm, Final_Term__c.class);
            update ft;
            Opportunity opp = (Opportunity) JSON.deserialize(loanApps, Opportunity.class);
            update opp;
            return 'Success';
        } catch(Exception ex){
            return ex.getMessage();
        }
        
    }
    
    @AuraEnabled
    public static boolean retryAttemptsExasted(String loanApplicationId){
        boolean retryExasted =false;
        
        try{
            System_Constant_custom_metadata__mdt metadata = System_Constant_custom_metadata__mdt.getInstance('AML'); 
            Retry_Count__c retryCount = new Retry_Count__c();
            List<Retry_Count__c> retryCountList = new List<Retry_Count__c>();
            retryCountList = [select Loan_Application_Id__c from Retry_Count__c where Loan_Application_Id__c =: loanApplicationId and Service_Name__c = 'AML' WITH SECURITY_ENFORCED limit 1];
            System.debug('retryCountList '+retryCountList);
            if(retryCountList.isEmpty()) {
                retryCount.Loan_Application_Id__c = loanApplicationId;
                retryCount.Service_Name__c = 'AML';
                retryCount.Count__c = 1;
                if(Schema.sObjectType.Retry_Count__c.isCreateable())
                {
                  //  insert retryCount;
                }
                retryExasted =false;
            }
            else{               
                //If number of attempts are greater than predefined number of attempts.
                Retry_Count__c  count = [select Count__c from Retry_Count__c where Loan_Application_Id__c =: loanApplicationId and Service_Name__c ='AML' WITH SECURITY_ENFORCED];
                if(count.Count__c >= metadata.Number_Of_Attempts__c)
                {                     
                    retryExasted =true;                    
                }else{
                    retryCount.Loan_Application_Id__c = loanApplicationId;
                    retryCount.Service_Name__c = 'AML';
                    retryCount.Count__c = retryCountList[0].Count__c+1;
                    // if(Schema.sObjectType.Retry_Count__c.isUpdatable())
                    // {
                   // update retryCount;
                    //  }
                }
            }
            
        }catch(exception ex){
            system.debug('Exception '+ex.getMessage() +'  '+ ex.getLineNumber() +'  '+ ex.getCause()) ;
        }
        
        return retryExasted;
    }
    
    }