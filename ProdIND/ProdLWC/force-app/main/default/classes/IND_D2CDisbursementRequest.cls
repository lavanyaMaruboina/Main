public with sharing class IND_D2CDisbursementRequest extends ParentAPIRequest{
    
    public final String leadNumber { get; set; }
    public final String disbursedLoanAmount { get; set; }
    public final String disbursedEMI { get; set; }
    public final String disbursedIRR { get; set; }
    public final String disbursedTenure { get; set; }
    public final String loanStatus { get; set; }
    
    public IND_D2CDisbursementRequest(String loanAppId) {
        List<Final_Term__c> finalTerms = [SELECT Id, Loan_Application__r.Lead_number__c, Tenure__c, Loan_Amount__c, EMI_Amount__c, Net_IRR__c FROM Final_Term__c WHERE Loan_Application__c =: loanAppId WITH SECURITY_ENFORCED];
        List<Applicant__c> app = [Select Id, applicant_number__c FROM Applicant__c WHERE Opportunity__c =: loanAppId];
        if(finalTerms != null && !finalTerms.isEmpty()){
            this.leadNumber =finalTerms[0].Loan_Application__r.Lead_number__c+'_'+app[0].applicant_number__c;
            this.disbursedLoanAmount =finalTerms[0].Loan_Amount__c;
            this.disbursedEMI =String.valueOf(Integer.valueOf(finalTerms[0].EMI_Amount__c));
            this.disbursedIRR =String.valueOf(Integer.valueOf(finalTerms[0].Net_IRR__c));
            this.disbursedTenure =finalTerms[0].Tenure__c;
            this.loanStatus ='Disbursed';
        }
        validate(System.Label.D2CDisbursement);

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
        if (String.isBlank(this.disbursedLoanAmount)) {
            throw new IND_Exception('disbursed Loan Amount in Blank');
        }
        if (String.isBlank(this.disbursedEMI)) {
            throw new IND_Exception('disbursed EMI in Blank');
        }
        if (String.isBlank(this.disbursedIRR)) {
            throw new IND_Exception('disbursed IRR in Blank');
        }
        if (String.isBlank(this.disbursedTenure)) {
            throw new IND_Exception('disbursed Tenure Months in Blank');
        }
        if (String.isBlank(this.loanStatus)) {
            throw new IND_Exception('loan Status in Blank');
        }
        return true;
    }
}