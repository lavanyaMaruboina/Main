/*------------------------------------------------------------
Author:        Rohan Saxena
Company:       Salesforce
Description:   This class is Request Wrapper Class of IBM Reverse Vehicle Dedupe API
Test Class:    
History
Date            Author              Comments
-------------------------------------------------------------
07-12-2022      Rohan Saxena         Created
------------------------------------------------------------*/
public with sharing class IND_D2CVehicleDedupeRequest extends ParentAPIRequest{
    public String SFVehicleCategory { get; set; }
    public String leadNumber { get; set; }
    public String journeyStatus { get; set; }

    public IND_D2CVehicleDedupeRequest(String loanAppId, String status) {
        List<Opportunity> loanApplications = [SELECT Id, Lead_number__c, Vehicle_Sub_Category__c, (Select Id, applicant_number__c FROM Applicants__r) FROM Opportunity WHERE Id =: loanAppId WITH SECURITY_ENFORCED];
        if(loanApplications != null && !loanApplications.isEmpty()){
            this.leadNumber =loanApplications[0].Lead_number__c+'_'+loanApplications[0].Applicants__r[0].applicant_number__c;
            this.SFVehicleCategory =loanApplications[0].Vehicle_Sub_Category__c;
            this.journeyStatus =status;
        }
        validate(System.Label.D2CVehicleDedupe);

    }


    public override Map<String, String> getHttpRequestHeaders() {
        //Map to store HTTP request header data
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);

        Map<String, String> requestHeaderMap = new Map<String, String>();
        requestHeaderMap.put(IntegrationConstants.CONTENT_TYPE , IntegrationConstants.CONTENT_TYPE_JSON);
        requestHeaderMap.put('X-IBM-Client-Id', System.Label.IBMClientId);
        requestHeaderMap.put('X-IBM-Client-Secret', System.Label.IBMClientSecret);
        requestHeaderMap.put('UUID', guid);
        requestHeaderMap.put('Origin', URL.getSalesforceBaseUrl().toExternalForm());
        return requestHeaderMap;
    }

    public override boolean validate(String serviceName) {
        if (String.isBlank(this.SFVehicleCategory)) {
            throw new IND_Exception('Vehicle Category is blank');
        }
        if (String.isBlank(this.leadNumber)) {
            throw new IND_Exception(System.Label.LeadId);
        }
        if (String.isBlank(this.journeyStatus)) {
            throw new IND_Exception('Journey Status in Blank');
        }
        return true;
    }
}