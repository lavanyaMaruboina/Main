public with sharing class KFSCalloutController {

    @AuraEnabled
    public static List<Opportunity> getOppRecord(String loanId){
        return [Select Product_Type__c,KFS_URL__c From Opportunity Where Id = :loanId WITH SECURITY_ENFORCED LIMIT 1];
    }
    
    @AuraEnabled
    public static Map<String,String> doKFSSmsGatewayAPI(String smsRequestString){
        
        if(String.isBlank(smsRequestString)){
            throw new IND_Exception(System.Label.Retry);
        }
        Map<String,String> resp = new Map<String,String>();
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.SMSGateway);
        Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
        
        
        //if stubs checked in Integration_Configuration then stubs will return
        if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){
            String stubData = IntegrationUtilities.getStubResponse(System.Label.SMSGateway);
            //return stubData == null ? System.Label.EmptyStubs : stubData;
        }
        
        if(!apiConfiguration.IsActive_Integration__c){
            throw new IND_Exception(System.Label.ServiceDown);
        }
        
        //String resp = '';
        String serviceName = System.Label.SMSGateway  ; // Gaurav : Changes for the Service Name.
        String elapseTime;
        String pcdId = '';
        Boolean fromproCredit = false;
        String loanAppId = '';
        String flag;
        String dealId;
        HttpRequest request;
        try{
            RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(smsRequestString,'RequestWrapper');
            loanAppId = requestWrapper.loanApplicationId;
            pcdId = requestWrapper.pcdId;
            fromproCredit = requestWrapper.fromProCredit;
            flag = requestWrapper.flag;
            dealId = requestWrapper.dealId;
            if(!fromproCredit){
               // requestWrapper.leadId = applicant.Opportunity__r.Lead_Number__c + '_' + applicant.applicant_number__c;
               requestWrapper.leadId = loanAppId;
            }else{
                requestWrapper.leadId = pcdId;
            }
            
            IND_SMSRequest smsRequest = IND_SMSService.getSmsCallOutRequest(requestWrapper); 
            String url = Consent_Url_Setting__mdt.getInstance('KFS_Consent').Consent_Url__c;
            String returnUrl = String.format(url,  new List<Object>{requestWrapper.kfsId, requestWrapper.kfsOtp});
    
            CalloutProcessor processor = new CalloutProcessor(System.Label.SMSGateway, smsRequest);
            request = processor.createHttpRequest();
            request.setTimeout(12000);
            
            Long startTime = DateTime.now().getTime();
           String requestfortesting = returnUrl;
           resp.put('status','SUCCESS'); 
           resp.put('requestfortesting',requestfortesting); 
           Key_Fact_Statement__c kfssms = [SELECT Id,Keyfact_Form_SMS_Sent__c FROM Key_Fact_Statement__c WHERE Id=:requestWrapper.kfsId];
            kfssms.Keyfact_Form_SMS_Sent__c = datetime.now();
            update kfssms;          
        } catch(Exception ex){
            if(!fromproCredit){
                IntegrationUtilities.createIntegrationLogger(IntegrationUtilities.getPlainTextForLog(request.getBody()), request.getBody(), '', '', serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doSmsGatewayAPI', System.Label.Apex, ex,loanAppId);
            }else{
                IntegrationUtilities.createIntegrationLogger(IntegrationUtilities.getPlainTextForLog(request.getBody()), request.getBody(), '', '', 'ProCredit_SMS', elapseTime, pcdId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEventProCreditDeal('IntegrationEngine', 'doSmsGatewayAPI', System.Label.Apex, ex,pcdId);
            }
            throw new IND_Exception(ex.getMessage());
        }
        return resp;
    }
    

    @AuraEnabled
    public static Boolean isPaymentRequestGenerated(String oppId){
        try {
            List<Vehicle_Detail__c> vehicleList = new List<Vehicle_Detail__c>([Select Id From Vehicle_Detail__c WHERE Loan_Application__c =:oppId AND Payment_requested__c = null]);
            if(vehicleList.size() > 0){
                return false;
            }else{
                return true;
            }
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('KFSCalloutController', 'isPaymentRequestGenerated', System.Label.Apex, e, oppId);
        }
        return false;
    }

    @AuraEnabled
    public static Vehicle_Detail__c getVehicleRecordId(String oppId, String dealId){
        try{
                
                List<Vehicle_Detail__c> vehicleList = [Select id,KFS_URL__c from Vehicle_Detail__c Where Loan_Application__c =: oppId AND Deal_Number__c=:dealId WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1];

                return vehicleList[0];
        }catch(Exception e){
                ErrorLoggerUtil.logErrorEvent('KFSCalloutController', 'getVehicleRecordId', System.Label.Apex, e,oppId);
                throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    @AuraEnabled
    public static string createDocument(String vehicleDetailId,String oppId,Boolean isTractor){
         try {
                
                   ID personAccountRecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('Other Documents').getRecordTypeId();
                   Applicant__c app = [SELECT Id FROM Applicant__c WHERE Opportunity__c =:oppId AND In_Active_Applicant__c = false AND Applicant_Type__c='Borrower' LIMIT 1];
                   if(isTractor){
                    List<Documents__c> docList = new List<Documents__c>([Select Id From Documents__c Where Vehicle_Detail__c =: vehicleDetailId AND Opportunity_Relation__c =: oppId AND Is_Active__c=true AND Document_Type__c = 'KFS']);
                    if(docList.size() > 0){
                        return docList[0].Id;
                    }else{
                        Documents__c docObject= new Documents__c(Vehicle_Detail__c=vehicleDetailId,Opportunity_Relation__c=oppId);
                   docObject.RecordTypeId = personAccountRecordTypeId;
                   docObject.is_Active__c = true;
                   docObject.Document_Type__c = 'KFS';
                   docObject.Applicant__c = app.Id;
                   docObject.Name = 'KFS';
 
                   if (Schema.sObjectType.Documents__c.isCreateable()){
                        insert docObject;
                   }
                   return docObject.Id;
                    }
                   }else{
                    List<Documents__c> docList = new List<Documents__c>([Select Id From Documents__c Where Opportunity_Relation__c =: oppId AND Is_Active__c=true AND Document_Type__c = 'KFS']);
                    if(docList.size() > 0){
                        return docList[0].Id;
                    }else{
                    Documents__c docObject= new Documents__c(Opportunity_Relation__c=oppId);
                   docObject.RecordTypeId = personAccountRecordTypeId;
                   docObject.is_Active__c = true;
                   docObject.Document_Type__c = 'KFS';
                   docObject.Applicant__c = app.Id;
                   docObject.Name = 'KFS';
 
                   if (Schema.sObjectType.Documents__c.isCreateable()){
                        insert docObject;
                   }
                   return docObject.Id;
                    }   
                   }
              } catch(Exception e){
                    ErrorLoggerUtil.logErrorEvent('KFSCalloutController', 'createDocument ', System.Label.Apex, e);
                    throw new AuraHandledException(System.Label.ExceptionMessage);  
              }
    }

    @AuraEnabled(cacheable = true)
    public static FinalOfferDetails getFinalOfferDetails(String loanId, String dealId){
      try{
        Opportunity loanApplication = [select Journey_Status__c,Journey_Stop_Reason__c,Product_Type__c,LeadSource from Opportunity where Id =:loanId WITH SECURITY_ENFORCED LIMIT 1];
        if(loanApplication.Product_Type__c == 'Tractor'){

            FinalOfferDetails finalOfferDetails = new FinalOfferDetails();
            List<Final_Term__c> finaltermsList = new List<Final_Term__c>([SELECT id,Loan_Amount__c, Loan_Application__c,Loan_Application__r.Application_number__c,Tenure__c, CRM_IRR__c, EMI_Amount__c,Loan_Application__r.Total_Funded_Premium__c,Gross_IRR__c,Net_IRR__c,Required_CRM_IRR__c,No_of_Installment__c, Vehicle_Detail__r.Make__c, Vehicle_Detail__r.Model__c, Vehicle_Detail__r.Variant__c, Vehicle_Detail__r.Approval_Status__c,Vehicle_Detail__r.Total_Funded_Amount__c  FROM Final_Term__c WHERE Loan_Application__c=:loanId AND Vehicle_Detail__r.Deal_Number__c =:dealId WITH SECURITY_ENFORCED ORDER BY Vehicle_Detail__r.CreatedDate ASC LIMIT 10]);  
            for(Applicant__c applicant : [Select Id,Contact_Number__c,Opportunity__r.Application_number__c,Name From Applicant__c Where Opportunity__c = :loanId AND Applicant_Type__c = : System.Label.Borrower AND In_Active_Applicant__c = false  WITH SECURITY_ENFORCED LIMIT 10]){
              finalOfferDetails.loanApplicationName = applicant.Name;
              finalOfferDetails.loanApplicationContactNumber = applicant.Contact_number__c;
              finalOfferDetails.loanApplicationNumber = applicant.Opportunity__r.Application_number__c;
            }
            if(finaltermsList.size() == 1){
              finalOfferDetails.offerLoanAmount = Decimal.valueOf(finaltermsList[0].Loan_amount__c) + (finaltermsList[0].Vehicle_Detail__r.Total_Funded_Amount__c == null ? 0 : finaltermsList[0].Vehicle_Detail__r.Total_Funded_Amount__c);
                finalOfferDetails.offerTenure = finaltermsList[0].Tenure__c;
                finalOfferDetails.offerIRR = finaltermsList[0].Required_CRM_IRR__c !=null? Decimal.valueof(finaltermsList[0].Required_CRM_IRR__c ): null;
                finalOfferDetails.offerEMI = finaltermsList[0].EMI_Amount__c;
                finalOfferDetails.numberOfInstallmentValue = finaltermsList[0].No_of_Installment__c == null ? '' : String.valueOf(finaltermsList[0].No_of_Installment__c);
                finalOfferDetails.netIRRValue = String.valueOf(finaltermsList[0].Net_IRR__c);
                finalOfferDetails.grossIRRValue = finaltermsList[0].Gross_IRR__c;
    
                String makeModelVariantStr = finaltermsList[0].Vehicle_Detail__r.Variant__c;
                finalOfferDetails.makeModelVariant = makeModelVariantStr.trim();
            }
            finalOfferDetails.JourneyStatus = loanApplication.Journey_Status__c;
            return finalOfferDetails;
        }else{
            FinalOfferDetails finalOfferDetails = new FinalOfferDetails();

        List<Final_Term__c> finaltermsList = new List<Final_Term__c>([SELECT id,Loan_Amount__c, Loan_Application__c,Loan_Application__r.Application_number__c,Tenure__c, CRM_IRR__c, EMI_Amount__c,Loan_Application__r.Total_Funded_Premium__c,Gross_IRR__c,Net_IRR__c,Holiday_period__c FROM Final_Term__c WHERE Loan_Application__c=:loanId WITH SECURITY_ENFORCED LIMIT 1]);
  
        for(Applicant__c applicant : [Select Id,Contact_Number__c,Name From Applicant__c Where Opportunity__c = :loanId AND Applicant_Type__c = : System.Label.Borrower AND In_Active_Applicant__c = false  WITH SECURITY_ENFORCED LIMIT 10]){
          finalOfferDetails.loanApplicationName = applicant.Name;
          finalOfferDetails.loanApplicationContactNumber = applicant.Contact_number__c;
        }
        if(finaltermsList.size() == 1){
          finalOfferDetails.loanApplicationNumber = finaltermsList[0].Loan_Application__r.Application_number__c;
          finalOfferDetails.offerLoanAmount = Decimal.valueOf(finaltermsList[0].Loan_amount__c) + finaltermsList[0].Loan_Application__r.Total_Funded_Premium__c;
            finalOfferDetails.offerTenure = finaltermsList[0].Tenure__c;
            finalOfferDetails.offerIRR = finaltermsList[0].CRM_IRR__c;
            finalOfferDetails.offerEMI = finaltermsList[0].EMI_Amount__c;
            finalOfferDetails.numberOfInstallmentValue = finaltermsList[0].Holiday_period__c == '30' ? String.valueof(Integer.valueOf(finaltermsList[0].Tenure__c) - 1) : finaltermsList[0].Holiday_period__c == '0' ? finaltermsList[0].Tenure__c : '';
            if(loanApplication.LeadSource=='OLA'){finalOfferDetails.numberOfInstallmentValue = finaltermsList[0].Tenure__c;}//OLA-139
            finalOfferDetails.netIRRValue = String.valueOf(finaltermsList[0].Net_IRR__c);
            finalOfferDetails.grossIRRValue = finaltermsList[0].Gross_IRR__c;
        }
        finalOfferDetails.isProductTypePV = loanApplication.Product_Type__c == 'Passenger Vehicles' ? true : false;
        finalOfferDetails.JourneyStatus = loanApplication.Journey_Status__c;
        List<Vehicle_Detail__c> vehicleList = new List<Vehicle_Detail__c>([Select id, Make__c, Model__c, Variant__c From Vehicle_Detail__c Where Loan_Application__c = :loanId With SECURITY_ENFORCED LIMIT 1]);
       
          if (vehicleList.size() > 0){
          String makeModelVariantStr = vehicleList[0].Variant__c;//CISP-2744 - removed the Make and Model from Concatenation
          finalOfferDetails.makeModelVariant = makeModelVariantStr.trim();
        }
          return finalOfferDetails;
        }
      }
        catch (Exception e){
        ErrorLoggerUtil.logErrorEvent('IND_GetFinalOfferDetails', 'getFinalOfferDetails', System.Label.Apex, e, loanId);
        throw new AuraHandledException(System.Label.ExceptionMessage);
      }
    }


    public class FinalOfferDetails{
        @AuraEnabled
        public String loanApplicationName{ get; set; }
        @AuraEnabled
        public String loanApplicationNumber{ get; set; }
        @AuraEnabled
        public String loanApplicationContactNumber{ get; set; }
        @AuraEnabled
        public String makeModelVariant{ get; set; }
        @AuraEnabled
        public Decimal offerLoanAmount{ get; set; }
        @AuraEnabled
        public String offerTenure{ get; set; }
        @AuraEnabled
        public Decimal offerIrr{ get; set; }
        @AuraEnabled
        public Decimal offerEmi{ get; set; }
        @AuraEnabled
        public String numberOfInstallmentValue{ get; set; }
        @AuraEnabled
        public String netIRRValue{ get; set; }
        @AuraEnabled
        public Decimal grossIRRValue{ get; set; }
        @AuraEnabled
        public Boolean isProductTypePV{ get; set; }
        @AuraEnabled
        public String JourneyStatus{ get; set; }
        
    
      }
}