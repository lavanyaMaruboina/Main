/*------------------------------------------------------------
Author:        Rohan Saxena
Company:       Salesforce
Description:   This class is Request Wrapper Class of IBM Reverse Sanction API
Test Class:    
History
Date            Author              Comments
-------------------------------------------------------------
07-12-2022      Rohan Saxena         Created
------------------------------------------------------------*/
public without sharing class IND_D2CSanctionRequest extends ParentAPIRequest{

    public final String leadNumber { get; set; }
    public final String finalLoanAmount { get; set; }
    public final String finalEMI { get; set; }
    public final String finalIRR { get; set; }
    public final String finalTenureMonths { get; set; }
    public final String loanStatus { get; set; }

    public IND_D2CSanctionRequest(String loanAppId) {
        List<Final_Term__c> finalTerms = [SELECT Id, Loan_Application__r.Lead_number__c, Tenure__c, Loan_Amount__c, EMI_Amount__c, Net_IRR__c FROM Final_Term__c WHERE Loan_Application__c =: loanAppId WITH SECURITY_ENFORCED];
        List<Applicant__c> app = [Select Id, applicant_number__c FROM Applicant__c WHERE Opportunity__c =: loanAppId];
        
        if(finalTerms != null && !finalTerms.isEmpty()){
            this.leadNumber =finalTerms[0].Loan_Application__r.Lead_number__c+'_'+app[0].applicant_number__c;
            this.finalLoanAmount =finalTerms[0].Loan_Amount__c;
            this.finalEMI =String.valueOf(finalTerms[0].EMI_Amount__c);
            this.finalIRR =String.valueOf(finalTerms[0].Net_IRR__c);
            this.finalTenureMonths =finalTerms[0].Tenure__c;
            this.loanStatus ='Sanctioned';
        }
        validate(System.Label.D2CSanction);
        
    }
    public override Map<String, String> getHttpRequestHeaders() {
        //Map to store HTTP request header data
        Map<String, String> requestHeaderMap = new Map<String, String>();
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        requestHeaderMap.put(IntegrationConstants.CONTENT_TYPE , IntegrationConstants.CONTENT_TYPE_JSON);
        requestHeaderMap.put('X-IBM-Client-Id', System.Label.IBMClientId);
        requestHeaderMap.put('X-IBM-Client-Secret', System.Label.IBMClientSecret);
        requestHeaderMap.put('UUID', guid);
        requestHeaderMap.put('Origin', 'https://indusindbank.my.salesforce.com');
        return requestHeaderMap;
    }
    public override boolean validate(String serviceName) {
        if (String.isBlank(this.leadNumber)) {
            throw new IND_Exception(System.Label.LeadId);
        }
        if (String.isBlank(this.finalLoanAmount)) {
            throw new IND_Exception('final Loan Amount in Blank');
        }
        if (String.isBlank(this.finalEMI)) {
            throw new IND_Exception('final EMI in Blank');
        }
        if (String.isBlank(this.finalIRR)) {
            throw new IND_Exception('final IRR in Blank');
        }
        if (String.isBlank(this.finalTenureMonths)) {
            throw new IND_Exception('final Tenure Months in Blank');
        }
        if (String.isBlank(this.loanStatus)) {
            throw new IND_Exception('loan Status in Blank');
        }
        return true;
    }
}