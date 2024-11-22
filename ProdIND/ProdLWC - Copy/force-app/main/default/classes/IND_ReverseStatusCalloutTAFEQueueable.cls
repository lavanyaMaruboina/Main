/*
* @Class Name:  IND_ReverseStatusCalloutTAFEQueueable
* @Created by:  Aakash J
* @Description: Queueable API class to send Loan Application status(Sanction, Rejection, Withdrawn and Disbursed) back to TAFE
*/

public class IND_ReverseStatusCalloutTAFEQueueable implements Queueable, Database.AllowsCallouts  {   
    public String loanAppId;
    public String status;
    public String dealNumber;   //SFTRAC-1916
    
    public IND_ReverseStatusCalloutTAFEQueueable(String loanAppId,String status, String dealNumber){
        this.loanAppId = loanAppId;
        this.status = status;
        this.dealNumber = dealNumber;   //SFTRAC-1916
    }
    
    public void execute(QueueableContext context) { 
        RequestDataSRWWrapper reqSRW = new RequestDataSRWWrapper();
        RequestDataDisbursWrapper reqDb = new RequestDataDisbursWrapper();
        List<Opportunity> oppList = [SELECT Id,LeadSource,Lead_number__c, (Select Id,Loan_amount__c,Tenure__c,EMI_Amount__c, CRM_IRR__c, Vehicle_Detail__r.Payment_requested__c,Vehicle_Detail__r.Deal_Number__c FROM Final_Terms__r) FROM Opportunity WHERE Lead_Number__c=:loanAppId];
        system.debug('+++++oppList '+oppList);
        system.debug('+++++oppList Final Term '+oppList[0].Final_Terms__r.size());
        Decimal loanAmount;
        Date dt;
        Datetime dtime;
        String dealId;
        String oppId = oppList.size()>0 ? oppList.get(0).Id : null; 
        String requestToEncrypt;
        String responseBody;
        
        if(oppList[0].Final_Terms__r.size()>0){
            loanAmount = Decimal.valueOf(oppList[0].Final_Terms__r[0].Loan_amount__c);
            dt = oppList[0].Final_Terms__r[0].Vehicle_Detail__r.Payment_requested__c;
            dtime = dt;
            //dealId = oppList[0].Final_Terms__r[0].Vehicle_Detail__r.Deal_Number__c;
            dealId = dealNumber;    //SFTRAC-1916
        }
        
        List<LoanDisbursementDetails__c> loanDisBursList =[Select Id, Name, Parent_Loan_Application__c, Dealer_Payment__c, Deal_Number__c, Deal_Number__r.Deal_Number__c From LoanDisbursementDetails__c Where Dealer_Payment__c !=null And Parent_Loan_Application__r.Product_Type__c ='Tractor' AND Deal_Number__c =: dealId LIMIT 1];
        system.debug('+++++loanDisBursList '+loanDisBursList);
        try{
            Integration_Configuration__mdt apiConfiguration = new Integration_Configuration__mdt();
            if(status == 'Disbursed'){
                apiConfiguration = IntegrationUtilities.getAPIConfiguration('TAFEReverseStatusDisbursAPI');
            }else{
                apiConfiguration = IntegrationUtilities.getAPIConfiguration('TAFEReverseStatusSRWAPI');
            }
            
            if(apiConfiguration != null){
                if(!apiConfiguration.IsActive_Integration__c){
                    ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'TAFE', System.Label.Apex, new AuraHandledException('Integration is not Active'));
                    throw new AuraHandledException('Integration is not Active');       
                }
                
                String methodType = apiConfiguration.Rest_Method__c.trim();
                String endpoint =apiConfiguration.Endpoint_URL__c;
                
                String accessToken = getAccessToken();
                if (accessToken == null) {
                    System.debug('Failed to obtain access token');
                    return;
                }
                
                if(status == 'Disbursed'){
                    //Mandatory fields
                    reqDb.lead_no = oppList.size()>0 ? oppList[0].Lead_number__c : '' ;
                    reqDb.status = 'F';
                    reqDb.loan_acc_no = loanDisBursList.size()>0 ? loanDisBursList[0].Deal_Number__r.Deal_Number__c : '';
                    reqDb.disburse_id = 0;
                    reqDb.disbursed_date = String.valueof(dtime) ;
                    reqDb.disburse_amt = loanDisBursList.size()>0 ? loanDisBursList[0].Dealer_Payment__c : null ;
                    reqDb.disbursed_totamt = loanAmount ;
                    reqDb.utr_no = '' ; //Aakash Need to update the mapping
                    
                    requestToEncrypt = JSON.serialize(reqDb);
                    system.debug('++requestToEncrypt'+requestToEncrypt);
                }else{
                    //Mandatory fields
                    reqSRW.lead_no = oppList.size()>0 ? oppList[0].Lead_number__c : '' ;
                    reqSRW.status = status == 'Sanctioned' ? 'S' : status == 'Rejected' ? 'R' : status == 'Withdrawn' ? 'W' : '';
                    reqSRW.loan_amount = loanAmount;
                    reqSRW.rate_of_interest = oppList[0].Final_Terms__r.size()>0 ? oppList[0].Final_Terms__r[0].CRM_IRR__c : null ;
                    reqSRW.tenor = oppList[0].Final_Terms__r.size()>0 ? Integer.valueof(oppList[0].Final_Terms__r[0].Tenure__c) : null ;
                    reqSRW.emi = oppList[0].Final_Terms__r.size()>0 ? oppList[0].Final_Terms__r[0].EMI_Amount__c : null ;
                    //Non-Mandatory fields that is why sending as blank for now
                    reqSRW.repay_mode = '';
                    reqSRW.roi_type = '';
                    reqSRW.margin_amount = null;
                    reqSRW.deal_value = null;
                    reqSRW.ltv = null;
                    reqSRW.fi_date_time = null; 
                    reqSRW.fi_status = '';
                    reqSRW.rejection_remarks = '';
                    reqSRW.case_ref_on = null;
                    reqSRW.process_fee = null;
                    
                    requestToEncrypt = JSON.serialize(reqSRW);
                    system.debug('++requestToEncrypt'+requestToEncrypt);
                }
                
                //Encrypting the Request
                //String encryptedRequest = IntegrationUtilities.getEncryptedRequest(requestToEncrypt,System.Label.privateKey,System.Label.ivkey);
                
                //HTTP method
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(endpoint);
                request.setMethod(methodType);
                request.setHeader('Authorization', 'Bearer ' + accessToken);
                request.setHeader('Content-Type', 'application/json');
                request.setHeader('financier_code', 'INDUSIND'); 
                //request.setBody('{"JData": "'+encryptedRequest+'"}'); //Encrypted Request
                request.setBody(requestToEncrypt);
                system.debug('++++request '+request);
                
                HttpResponse response = new HttpResponse();
                response = http.send(request); 
                System.debug('++++ getStatusCode' +response.getStatusCode()+'+getStatus ' +response.getStatus()+'+getBody ' +response.getBody());
                
                //Response handle logic
                if (response.getStatusCode() == 200) {
                    responseBody = response.getBody();
                    System.debug('++++ responseBody 200 ' +responseBody);
                } else {
                    System.debug('++++ response.getStatusCode()' +response.getStatusCode());
                    responseBody = response.getBody();
                    System.debug('++++ responseBody else ' +responseBody);
                }  
                //IntegrationUtilities.createIntegrationLogger(requestToEncrypt, encryptedRequest, JSON.serialize(responseBody), JSON.serialize(responseBody), 'TAFE_Reverse_Call', null, oppId); 
                IntegrationUtilities.createIntegrationLogger(requestToEncrypt, '', JSON.serialize(responseBody), JSON.serialize(responseBody), 'TAFE_Reverse_Call', null, oppId);
            }
            
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_ReverseStatusCalloutTAFEQueueable', 'execute', System.Label.Apex, ex,oppId);
        }
        
    }
    
    // Method to get the access token
    public static String getAccessToken() {
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration('TAFEStatusAccessTokenAPI');
        String accessToken='';
        if(apiConfiguration != null){
            if(!apiConfiguration.IsActive_Integration__c){
                ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'TAFE', System.Label.Apex, new AuraHandledException('Integration is not Active'));
                throw new AuraHandledException('Integration is not Active');       
            }

            /*String endpoint = 'https://uatunnatiapi.tafe.com/lendperfect/auth/access-token';
            String username = 'indusind'; 
            String password = 'tafe@1234'; 
            String clientSecret = 'RrUGxwYUzArPTZ2JylQmk9lNuDcBA4XW';*/

            String methodType = apiConfiguration.Rest_Method__c.trim();
            String endpoint =apiConfiguration.Endpoint_URL__c;
            String username = apiConfiguration.Username__c; 
            String password = apiConfiguration.Password__c ; 
            String clientSecret = apiConfiguration.Auth_Token__c;
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod(methodType);
            req.setHeader('Content-Type', 'application/json');
            
            // Set the request body
            String body = '{"username": "' + username + '", "password": "' + password + '", "client_secret": "' + clientSecret + '"}';
            req.setBody(body);
            
            Http http = new Http();
            HttpResponse res;
            try {
                res = http.send(req);
                if (res.getStatusCode() == 200) {
                    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    accessToken = (String) responseMap.get('access_token');
                    system.debug('+++++accessToken '+accessToken);
                    //return accessToken;
                } else {
                    System.debug('Error: ' + res.getStatusCode() + ' ' + res.getStatus());
                    return null;
                }   
            } catch (Exception ex) {
                System.debug('Error: ' + ex.getMessage());
                //ErrorLoggerUtil.logErrorEvent('IND_ReverseStatusCalloutTAFEQueueable getAccessToken', 'execute', System.Label.Apex, ex,oppId);
                return null;
            }
        }
        return accessToken;
    }
    
    //Wrapper for Sanction, Rejection and Withdrawn
    Public class RequestDataSRWWrapper{
        public String lead_no;
        public String status;
        public Decimal loan_amount;
        public Decimal rate_of_interest;
        public Integer tenor;
        public Decimal emi;
        public String repay_mode;
        public String roi_type;
        public Decimal margin_amount;
        public Decimal deal_value;
        public Decimal ltv; 
        public Decimal project_cost;
        public Decimal margin_per;
        public String fi_date_time;
        public String fi_status;
        public String rejection_remarks;
        public String case_ref_on;
        public Decimal process_fee;
    }
    
    //Wrapper for Disbursement
    Public class RequestDataDisbursWrapper{
        public String lead_no;
        public String status;
        public String loan_acc_no;
        public Integer disburse_id;
        public String disbursed_date;
        public Decimal disburse_amt;
        public Decimal disbursed_totamt;
        public String utr_no;
    }
    
    
}