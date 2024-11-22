Public class IND_ReverseStatusCalloutOLAQueueable implements Queueable, Database.AllowsCallouts  {
    Public String loanAppId;
    Public String status;
    
    public IND_ReverseStatusCalloutOLAQueueable(String loanAppId,String status){
        this.loanAppId = loanAppId;
        this.status = status;
    }

    Public void execute(QueueableContext context) { 
        String encryptedResponse = '';
        String jdataRequest = '"JData":';
        String jsonBody;
        RequestDataWrapper req =new RequestDataWrapper();
        RequestDataWrapperHero reqhero = new RequestDataWrapperHero();
        InnerData reqData =new InnerData();
        InnerDataHero reqDataHero = new InnerDataHero();
        List<Opportunity> oppList = [SELECT Id,LeadSource,Sanction_Date__c,Total_Funded_Premium__c,Withdrawal_Reason__c,Hero_Disbursed_Date__c,(SELECT Id,Loan_amount__c,Tenure__c,EMI_Amount__c FROM Final_Terms__r),(SELECT Id,BE_CVO_Remark__c FROM CAMs__r),(SELECT Id,CMU_Rejection_Reason__c FROM Documents__r WHERE CMU_Rejection_Reason__c != null) FROM Opportunity WHERE Lead_Number__c=:loanAppId order by CreatedDate DESC limit 1];//OLA-301
        //List<Final_Term__c> finalTermList = [SELECT Id,Loan_amount__c,Total_Funded_Premium__c,Tenure__c,EMI_Amount__c FROM Final_Term__c WHERE Lead_Number__c=:loanAppId];
        Decimal offerLoanAmount = oppList[0].Total_Funded_Premium__c +  Decimal.valueOf(oppList[0].Final_Terms__r[0].Loan_amount__c);
        String oppId = oppList.size()>0 ? oppList.get(0).Id : null; 
        Date dt = oppList[0].Sanction_Date__c;
        Datetime dtime = dt;
        try{
            NamedCredential myNamedCredential1 = [SELECT Id, Endpoint, DeveloperName FROM NamedCredential WHERE DeveloperName = 'Hero_API'];  
            NamedCredential myNamedCredential2 = [SELECT Id, Endpoint, DeveloperName FROM NamedCredential WHERE DeveloperName = 'OLA_API'];
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            If(oppList[0].LeadSource == 'Hero'){
                request.setEndpoint(myNamedCredential1.Endpoint);
            }else{
                request.setEndpoint(myNamedCredential2.Endpoint);
            }
            request.setMethod('POST');
            request.setTimeout(50000);//OLA-301
            if(oppList[0].LeadSource == 'Hero'){
                reqDataHero.financier_id = '19';
                reqDataHero.financier_name = 'INDUSIND';
                reqDataHero.channel_type = 'HERO';
                reqDataHero.loan_application_number = loanAppId;
                reqDataHero.status = status;
                if(status == 'Sanctioned'){
                reqDataHero.sanctioned_amount = offerLoanAmount;
                reqDataHero.sanctioned_tenure = String.ValueOf(oppList[0].Final_Terms__r[0].Tenure__c);
                reqDataHero.sanctioned_date = String.ValueOf(dtime);
                reqDataHero.sanctioned_emi = String.ValueOf(oppList[0].Final_Terms__r[0].EMI_Amount__c);
                reqDataHero.sanctioned_processing_fee = '0';
                reqDataHero.sanctioned_roi = '0';
                }else{
                    reqDataHero.sanctioned_amount = null;
                    reqDataHero.sanctioned_tenure = '';
                    reqDataHero.sanctioned_date = '';
                    reqDataHero.sanctioned_emi = '';
                    reqDataHero.sanctioned_processing_fee = '';
                    reqDataHero.sanctioned_roi = '';    
                }
                if(status == 'Disbursed'){
                    reqDataHero.disbursed_amount = offerLoanAmount;
                    reqDataHero.disbursed_tenure = String.ValueOf(oppList[0].Final_Terms__r[0].Tenure__c);
                    reqDataHero.disbursed_date = String.ValueOf(oppList[0].Hero_Disbursed_Date__c);
                    reqDataHero.disbursed_emi = String.ValueOf(oppList[0].Final_Terms__r[0].EMI_Amount__c);
                    reqDataHero.disbursed_roi = '0';
                    reqDataHero.disbursed_processing_fee = '0';
                    reqDataHero.dealer_payout = '0';
                }else{
                    reqDataHero.disbursed_amount = null;
                    reqDataHero.disbursed_tenure = '';
                    reqDataHero.disbursed_emi = '';
                    reqDataHero.disbursed_date = '';
                reqDataHero.disbursed_roi = '';
                reqDataHero.disbursed_processing_fee = '';
                reqDataHero.dealer_payout = '';
                }
                if(status == 'Rejected'){
                reqDataHero.reject_rsn = oppList[0].Documents__r[0].CMU_Rejection_Reason__c != null ? oppList[0].Documents__r[0].CMU_Rejection_Reason__c : oppList[0].CAMs__r[0].BE_CVO_Remark__c != null ? oppList[0].CAMs__r[0].BE_CVO_Remark__c : '';
                }else if(status == 'Withdrawn'){
                reqDataHero.reject_rsn = oppList[0].Withdrawal_Reason__c;
                }else{
                reqDataHero.reject_rsn = '';
                }
               reqhero.request_data = JSON.serialize(reqDataHero);
               reqhero.action = 'indusind_status_update';
               reqhero.api_code = 'prdbk03888bzds31531ls@kk';
               String originalReq1 = JSON.serialize(reqhero);
               reqhero.request_data = IBMEncryption.getEncryptedRequestHero(JSON.serialize(reqDataHero),System.Label.privateKey,System.Label.ivkey);
               String encryptedReqBody1 = JSON.serialize(reqhero);
            request.setHeader( 'Content-Type', 'application/json' );
            request.setBody(JSON.serialize(reqhero));
            system.debug('JSON.serialize(reqhero) - '+JSON.serialize(reqhero) );
            HttpResponse response = http.send(request);
            system.debug('Response - '+response );
            IntegrationUtilities.createIntegrationLogger(originalReq1, encryptedReqBody1, JSON.serialize(response.getBody()), JSON.serialize(response.getBody()), 'Hero_Reverse_Call', null, oppId); 
            }else{
            reqData.leadId = loanAppId;
            reqData.status = status;
            req.requestType = 'status';
            req.data = JSON.serialize(reqData);
            String originalReq2 = JSON.serialize(req);
            req.data = IntegrationUtilities.getEncryptedRequest(JSON.serialize(reqData),System.Label.privateKey,System.Label.ivkey);
            String encryptedReqBody2 = JSON.serialize(req); 
            request.setHeader( 'Content-Type', 'application/json' );
            request.setBody(JSON.serialize(req));
            system.debug('JSON.serialize(req) - '+JSON.serialize(req) );
            HttpResponse response = http.send(request);
            system.debug('Response - '+response );
            IntegrationUtilities.createIntegrationLogger(originalReq2, encryptedReqBody2, JSON.serialize(response.getBody()), JSON.serialize(response.getBody()), 'OLA_Reverse_Call', null, oppId); 
        }
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_ReverseStatusCalloutOLAQueueable', 'execute', System.Label.Apex, ex,oppId);
        }
    }

    Public class RequestDataWrapper{
        Public String data;
        Public String requestType;
    }
    Public class RequestDataWrapperHero{
        Public String request_data;
        Public String api_code;
        Public String action;
    }
    Public class InnerData{
        Public String leadId;
        Public String status;
    }
    Public class InnerDataHero{
        Public String status;
        Public String financier_id;
        Public String financier_name;
        Public String channel_type;
        Public String loan_application_number;
        Public Decimal sanctioned_amount;
        Public String sanctioned_roi;
        Public String sanctioned_tenure;
        Public String sanctioned_processing_fee;
        Public String sanctioned_emi;
        Public String sanctioned_date;
        Public Decimal disbursed_amount;
        Public String disbursed_roi;
        Public String disbursed_tenure;
        Public String disbursed_processing_fee;
        Public String disbursed_emi;
        Public String dealer_payout;
        Public String disbursed_date;
        Public String reject_rsn;
    }
}