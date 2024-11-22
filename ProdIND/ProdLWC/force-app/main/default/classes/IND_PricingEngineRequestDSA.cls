public class IND_PricingEngineRequestDSA extends ParentAPIRequest {
    public final string Lead_Id { get; set; }
    public final string Maker_Id { get; set; }
    public final string Product { get; set; }
    public final string RiskBand { get; set; }
    public final string Applicant_ETC { get; set; } 
    public final string Category { get; set; }
    public final string VehicleType { get; set; }
    public final string StateCode { get; set; }
    public final string Proposal_Based_On { get; set; }
    public final string Bl_Code { get; set; }
    //Added by Rohan for new DSA API
    public final String Channel { get; set; }

    public IND_PricingEngineRequestDSA(Opportunity opp, String loanAppId, RequestWrapper requestWrapper) {
        List<Income_Details__c> profileList = [SELECT id, Profile__r.code__c, Profile__r.Category__c FROM Income_Details__c WHERE Applicant__c = :requestWrapper.applicantId WITH SECURITY_ENFORCED];

        List<BankBranchDetails__c> stateList = [SELECT Id, Geo_State_Master__r.State_Code__c FROM BankBranchDetails__c WHERE Bl_Code_Details__r.Bl_Code__c = :opp.Agent_BL_code__c WITH SECURITY_ENFORCED];

        if (stateList.isEmpty()) {
            this.StateCode = '';
        } else {
            this.StateCode = stateList.isEmpty() == true ? '' : stateList[0].Geo_State_Master__r.State_Code__c;
        }

        this.Lead_Id = opp.Lead_number__c + '_' + requestWrapper.applicantNumber;
        this.Maker_Id = IntegrationUtilities.getMakerId();
        this.Product = opp.Product_Type__c == 'Two Wheeler' ? 'H' : opp.Product_Type__c == 'Passenger Vehicles' ? 'C' : '';
        if ((!String.IsBlank(requestWrapper.scoreCardDecision)) && requestWrapper.scoreCardDecision != null && requestWrapper.scoreCardDecision.equalsIgnoreCase('Dark Green')) {
            this.RiskBand = '01';
        } else if ((!String.IsBlank(requestWrapper.scoreCardDecision)) && requestWrapper.scoreCardDecision != null && requestWrapper.scoreCardDecision.equalsIgnoreCase('Light Green')) {
            this.RiskBand = '02';
        } else if ((!String.IsBlank(requestWrapper.scoreCardDecision)) && requestWrapper.scoreCardDecision != null && requestWrapper.scoreCardDecision.equalsIgnoreCase('Yellow')) {
            this.RiskBand = '03';
        } else if ((!String.IsBlank(requestWrapper.scoreCardDecision)) && requestWrapper.scoreCardDecision != null && requestWrapper.scoreCardDecision.equalsIgnoreCase('Orange')) {
            this.RiskBand = '04';
        } else if ((!String.IsBlank(requestWrapper.scoreCardDecision)) && requestWrapper.scoreCardDecision != null && requestWrapper.scoreCardDecision.equalsIgnoreCase('Red')) {
            this.RiskBand = '05';
        } else {
            this.RiskBand = '';
        }
        this.Applicant_ETC = 'Yes';
        this.Category = profileList.isEmpty() == true ? '' : profileList[0].Profile__r.Category__c;
        this.VehicleType = opp.Vehicle_Type__c == 'New' ? 'N' : opp.Vehicle_Type__c == 'Used' ? 'U' : opp.Vehicle_Type__c == 'Refinance' ? 'R' : '';
        this.Proposal_Based_On = requestWrapper.proposalBasedOn;
        this.Bl_Code = opp.Agent_BL_code__c;
        //Added by Rohan for new DSA API
        this.Channel = opp.LeadSource == 'D2C' ? 'IndusMobile' : opp.LeadSource;

        validate(System.Label.PricingEngine);
    }

    public override Map<String, String> getHttpRequestHeaders() {
        Map<String, String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }

    public override boolean validate(String serviceName) {
        if (this.Lead_Id == null || String.isBlank(this.Lead_Id)) {
            throw new IND_Exception(System.Label.Lead_IDError);
        }
        if (this.Maker_Id == null || String.isBlank(this.Maker_Id)) {
            throw new IND_Exception(System.Label.Maker_IdError);
        }
        if (this.Product == null || String.isBlank(this.Product)) {
            throw new IND_Exception(System.Label.ProductId);
        }
        if (this.RiskBand == null || String.isBlank(this.RiskBand)) {
            throw new IND_Exception(System.Label.RiskBand);
        }
        if (this.Applicant_ETC == null || String.isBlank(this.Applicant_ETC)) {
            throw new IND_Exception(System.Label.ApplicantError);
        }
        if (this.Category == null || String.isBlank(this.Category)) {
            throw new IND_Exception(System.Label.Category);
        }
        if (this.VehicleType == null || String.isBlank(this.VehicleType)) {
            throw new IND_Exception(System.Label.VehicleType);
        }
        if (this.StateCode == null || String.isBlank(this.StateCode)) {
            throw new IND_Exception(System.Label.StateCodeError);
        }
        if (this.Bl_Code == null || String.isBlank(this.Bl_Code)) {
            throw new IND_Exception(System.Label.BLCode);
        }

        return true;
    }
}