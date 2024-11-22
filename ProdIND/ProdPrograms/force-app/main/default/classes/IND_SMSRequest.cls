/*------------------------------------------------------------
Author:        Divya Jawale
Company:       Persistent Systems
Description:   This class is wrapper class for the SMS Getway request 
Test Class:    IND_SMSRequest_Test 
History
Date            Author              Comments
-------------------------------------------------------------
7-10-2021      Divya Jawale       Created
15-12-2021     Bhushan Charde     Modified
------------------------------------------------------------*/
public class IND_SMSRequest extends ParentAPIRequest{
    
    public final String Reference_Id{get;set;}
    public final String mobile_number{get;set;}
    public final String Message{get;set;}

    public IND_SMSRequest(RequestWrapper requestWrapper){
   
        if( requestWrapper != null){
            this.Reference_Id = requestWrapper.leadId;
            if(requestWrapper.flag.equalsIgnoreCase('KFS')){
                this.mobile_number = requestWrapper.mobileNumber;
            }else if(requestWrapper.contactNumber != null && requestWrapper.flag.equalsIgnoreCase('OTP')){
                this.mobile_number = requestWrapper.contactNumber;
            }
            else{
                this.mobile_number = requestWrapper.whatsappNo==null?requestWrapper.contactNumber:requestWrapper.whatsappNo;
            }
            if(requestWrapper.leadId != null && requestWrapper.otpForBorrower != null && requestWrapper.flag.equalsIgnoreCase('OTP') && requestWrapper.otpForBorrower != null){  //CISP-2927
                List<String> leadNumberList = requestWrapper.leadId.split('_');
                String leadNumber = '';
                if (leadNumberList.size() > 1) {
                    leadNumberList.remove(leadNumberList.size() - 1);
                    leadNumber = String.join(leadNumberList, '_');
                }
                String url = Consent_Url_Setting__mdt.getInstance(System.Label.LoanConsentLink).Consent_Url__c;
                String messageWithoutEncoding = String.format(System.Label.LoanConsentMsg, 
                                         new List<Object>{requestWrapper.otpForBorrower,
										 String.format(url, new List<Object>{requestWrapper.applicantId,requestWrapper.otpForBorrower}),//CISP-2927
										 leadNumber, System.Label.TollFreeNumber});    
                this.Message = EncodingUtil.urlEncode(messageWithoutEncoding, 'UTF-8');
            } else if(requestWrapper.flag.equalsIgnoreCase('INC')){
                 String url = Consent_Url_Setting__mdt.getInstance(System.Label.InsConsentLink).Consent_Url__c;
                 String messageWithoutEncoding = String.format(System.Label.InsConsentMessage, 
                                         new List<Object>{String.format(url, 
                                         new List<Object>{requestWrapper.applicantId, requestWrapper.otpForInsConsent})});                       
            	this.Message = EncodingUtil.urlEncode(messageWithoutEncoding, 'UTF-8');
            } else if(requestWrapper.flag.equalsIgnoreCase('LAS')) {
                 String url = Consent_Url_Setting__mdt.getInstance(System.Label.LoanAppSignConsentLink).Consent_Url__c;
                 String messageWithoutEncoding = String.format(System.Label.LoanAppSignConsentMessage, 
                                         new List<Object>{String.format(url, 
                                         new List<Object>{requestWrapper.applicantId, requestWrapper.otpForAppSignConsent})});
                 this.Message = EncodingUtil.urlEncode(messageWithoutEncoding, 'UTF-8');
            }else if(requestWrapper.flag.equalsIgnoreCase('CASA')) {
                 String url = Consent_Url_Setting__mdt.getInstance(System.Label.CasaConsentLink).Consent_Url__c;
                 String messageWithoutEncoding = String.format(System.Label.CasaConsentMessage, 
                                         new List<Object>{String.format(url, 
                                         new List<Object>{requestWrapper.applicantId, requestWrapper.otpForCasaConsent})});
                 this.Message = EncodingUtil.urlEncode(messageWithoutEncoding, 'UTF-8');
            } else if(requestWrapper.flag.equalsIgnoreCase('ENACH')){ //ENACH Link 
                this.Message=String.format(System.Label.ENACH_Registration,new List<Object>{requestWrapper.url,requestWrapper.accountNumEnd});
            }  else if(requestWrapper.flag.equalsIgnoreCase('SI_Online')){ // SI Online Link
                this.Message=String.format(System.Label.Online_SI_SMS,new List<Object>{requestWrapper.name,requestWrapper.url});
            } else if(requestWrapper.flag.equalsIgnoreCase('ENH')) {
                String url = Consent_Url_Setting__mdt.getInstance(System.Label.LoanAppSignConsentLink).Consent_Url__c;
                this.Message = String.format(System.Label.LoanConsentMsg, //testing only
                                         new List<Object>{url, requestWrapper.leadId});
            } else if(requestWrapper.flag.equalsIgnoreCase('SA')) { // for the sended the sms when loan sanction approved.
                this.Message = String.format(System.Label.LoanSanctionMsg,new List<Object>{requestWrapper.applicationNo});
            }else if(requestWrapper.flag.equalsIgnoreCase('AML')){ 
                this.Message=String.format(System.Label.SanctionRejected,new List<Object>{requestWrapper.leadId,requestWrapper.vehicleType});
            }else if(requestWrapper.flag.equalsIgnoreCase('LTS')) {//CISP-6945 start
                this.Message = String.format(System.Label.LeadTransferSMSforMOorBE,new List<Object>{requestWrapper.leadId,requestWrapper.name});
            }else if(requestWrapper.flag.equalsIgnoreCase('KFS')){
                String url = Consent_Url_Setting__mdt.getInstance('KFS_Consent').Consent_Url__c;
                
                String messageWithoutEncoding ='';
                if(requestWrapper.fromproCredit){
                    Key_Fact_Statement__c pcd = [SELECT Id,Lead_Number__c FROM Key_Fact_Statement__c WHERE ProCredit_Deal__c=:requestWrapper.pcdId LIMIT 1];
                    String loanApplicatioNumber = pcd.Lead_Number__c;
                    String urlLink = String.format(url, new List<Object>{requestWrapper.kfsId, requestWrapper.kfsOtp}); 
                    messageWithoutEncoding = String.format(System.Label.KFSConsentMessagetwo, new List<Object>{urlLink, loanApplicatioNumber});
                }else{
                    Opportunity opp = [SELECT Id,Name FROM Opportunity WHERE id=:requestWrapper.loanApplicationId LIMIT 1];
                    String loanApplicatioNumber = opp.Name;
                    String urlLink = String.format(url, new List<Object>{requestWrapper.kfsId, requestWrapper.kfsOtp}); 
                     messageWithoutEncoding = String.format(System.Label.KFSConsentMessagetwo, new List<Object>{urlLink, loanApplicatioNumber});
                }
                
               
               
                
                /*
                 String messageWithoutEncoding = String.format(System.Label.KFSConsentMessage, 
                                         new List<Object>{String.format(url, 
                                         new List<Object>{requestWrapper.kfsId, requestWrapper.kfsOtp})});
                                          */
                 this.Message = EncodingUtil.urlEncode(messageWithoutEncoding, 'UTF-8');
                
            }//CISP-6945 end  
            /*OLA-204-START - Added Else-if for cutomer_intimation */
            else if(requestWrapper.flag.equalsIgnoreCase('cutomer_intimation')) {
                this.Message = String.format(System.Label.CustomerInitmationOnLeadAssignment ,new List<Object>{requestWrapper.leadName,requestWrapper.leadOwnerName,requestWrapper.leadOwnerContact});  
            }
            /*OLA-204-END */    
        }
        validate(System.Label.SMSGateway);
    }
    
    //Method to get the HTTP request header data
    public override Map<String,String> getHttpRequestHeaders(){    
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }
    
      /*
    * @Method:      validate
    * @Created by:  Divya
    * @Description: This method will returns valid request SMS Gateway API
    * @Param:       String - serviceName
    * @Return:      boolean - true/false
    */
    public override boolean validate(String serviceName){
        if(String.isBlank(this.mobile_number)){
            throw new IND_Exception(System.Label.EnterMobileNumber);
        } 
        if(String.isBlank(this.Message)){
            throw new IND_Exception(System.Label.Message);
        }
        return true;
    }
}