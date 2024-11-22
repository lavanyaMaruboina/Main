/*------------------------------------------------------------
Author:        Rohan Saxena 
Company:       Salesforce
Description:   This class is Request class for AadhaarVault API
Test Class:    
History
Date            Author              Comments 
-------------------------------------------------------------
28-02-2023      Rohan Saxena         Created 
------------------------------------------------------------*/
public with sharing class IND_AadhaarVault_Request extends ParentAPIRequest {
    public final string DocumentNo { get; set; } //LeadId
    public final string Source { get; set; } //SF
    public final string AadhaarNo { get; set; } //AadharNo from Document
    public final string UserId { get; set; } //Zero default

    public IND_AadhaarVault_Request(String docNo, String AahaarNo) {
        this.Source = 'SF';
        this.UserId = '0';
        this.DocumentNo = docNo;
        this.AadhaarNo = AahaarNo;
        validate(System.label.AadhaarVault);
    }

    public override Map<String, String> getHttpRequestHeaders() {
        Map<String, String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }
    public override boolean validate(String serviceName) {
        if (this.DocumentNo == null || String.isBlank(this.DocumentNo)) {
            throw new IND_Exception('Please provide valid DocumentNo.');
        }
        if (this.Source == null || String.isBlank(this.Source)) {
            throw new IND_Exception('Please provide valid Source.');
        }
        if (this.AadhaarNo == null || String.isBlank(this.AadhaarNo)) {
            throw new IND_Exception('Please provide valid AadhaarNo.');
        }
        if (this.UserId == null) {
            throw new IND_Exception('Please provide valid UserId.');
        }

        return true;
    }
}