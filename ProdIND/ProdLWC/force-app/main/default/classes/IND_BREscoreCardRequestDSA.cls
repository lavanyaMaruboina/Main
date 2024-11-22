public class IND_BREscoreCardRequestDSA extends ParentAPIRequest {
    public final string Lead_Id { get; set; }
    public final string product { get; set; }
    public final string vehicleType { get; set; }
    public final string mobileNumber { get; set; }
    public final string applicantType { get; set; }
    public final string dateOfBirth { get; set; }
    public final string pinCode {get;set;}
    public final string gender { get; set; }
    public final string category { get; set; }
    public final string maritalStatus { get; set; }
    public final string state { get; set; }
    public final string country { get; set; }
    public final string profile { get; set; }
    public final string Maker_Id { get; set; }
    //Added by Rohan for new DSA API 
    public final String Channel { get; set; }

    public IND_BREscoreCardRequestDSA(Applicant__c app, Documents__c doc, String loanAppId) {
        List<Income_Details__c> profileList = [SELECT id, Profile__r.code__c, Profile__r.Category__c FROM Income_Details__c WHERE Applicant__c = :app.id WITH SECURITY_ENFORCED];

        List<BankBranchDetails__c> stateList = [SELECT Id, Geo_State_Master__r.State_Code__c FROM BankBranchDetails__c WHERE Bl_Code_Details__r.Bl_Code__c = :app.Opportunity__r.Agent_BL_code__c WITH SECURITY_ENFORCED];

        if (stateList.isEmpty()) {
            this.state = '';
        } else {
            this.state = stateList.isEmpty() == true ? '' : stateList[0].Geo_State_Master__r.State_Code__c;
        }
        this.Lead_Id = app.Opportunity__r.Lead_number__c + '_' + app.applicant_number__c;
        this.product = app.Opportunity__r.Product_Type__c != null && app.Opportunity__r.Product_Type__c == 'Two Wheeler' ? 'H' : app.Opportunity__r.Product_Type__c == 'Passenger Vehicles' ? 'C' : '';
        this.vehicleType = app.Opportunity__r.Vehicle_Type__c == 'New' ? 'N' : app.Opportunity__r.Vehicle_Type__c == 'Used' ? 'U' : app.Opportunity__r.Vehicle_Type__c == 'Refinance' ? 'R' : '';
        this.mobileNumber = app.Contact_number__c;
        this.applicantType = app.Applicant_Type__c;
        this.dateOfBirth = String.valueOf(doc.KYC_DOB__c);
        this.pinCode = String.valueOf(doc.KYC_Pin_Code__c);        
        this.gender = app.Gender__c != null && app.Gender__c == 'FEMALE' ? '1' : app.Gender__c == 'MALE' ? '2' : app.Gender__c == 'TRANSGENDER' ? '3' : '';
        this.category = profileList.isEmpty() == true ? '' : profileList[0].Profile__r.Category__c;
        this.maritalStatus = app?.Marital_status__c == null ? '' : String.valueOf(app?.Marital_status__c);
        this.country = app.Residence_country__c;
        this.profile = profileList.isEmpty() == true ? '' : profileList[0].Profile__r.code__c;
        this.Maker_Id = IntegrationUtilities.getMakerId();
        //Added by Rohan for new DSA API
        this.Channel = 'DSA';

        validate(System.Label.BREscorecardAPI);
    }

    public override Map<String, String> getHttpRequestHeaders() {
        //Map to store HTTP request header data
        Map<String, String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }

    public override boolean validate(String serviceName) {
        if (this.Lead_Id == null && String.isBlank(this.Lead_Id)) {
            throw new IND_Exception(System.Label.Lead_IDError);
        }
        if (this.product == null && String.isBlank(this.product)) {
            throw new IND_Exception(System.Label.product);
        }
        if (this.vehicleType == null && String.isBlank(this.vehicleType)) {
            throw new IND_Exception(System.Label.vehicleType);
        }
        if (this.mobileNumber == null && String.isBlank(this.mobileNumber)) {
            throw new IND_Exception(System.Label.mobileNumber);
        }
        if (this.applicantType == null && String.isBlank(this.applicantType)) {
            throw new IND_Exception(System.Label.applicantType);
        }
        if (this.dateOfBirth == null && String.isBlank(this.dateOfBirth)) {
            throw new IND_Exception(System.Label.dateOfBirth);
        }
        if(this.pinCode== null && String.isBlank(this.pinCode)){
            throw new IND_Exception('Pincode is Missing');
        }
        if (this.gender == null && String.isBlank(this.gender)) {
            throw new IND_Exception(System.Label.gender);
        }
        if (this.category == null && String.isBlank(this.category)) {
            throw new IND_Exception(System.Label.category);
        }
        if (this.maritalStatus == null && String.isBlank(this.maritalStatus)) {
            throw new IND_Exception(System.Label.maritalStatus);
        }
        if (this.state == null && String.isBlank(this.state)) {
            throw new IND_Exception(System.Label.state);
        }
        if (this.country == null && String.isBlank(this.country)) {
            throw new IND_Exception(System.Label.country);
        }
        if (this.profile == null && String.isBlank(this.profile)) {
            throw new IND_Exception(System.Label.profile);
        }
        if (this.Maker_Id == null && String.isBlank(this.Maker_Id)) {
            throw new IND_Exception(System.Label.Maker_IdError);
        }

        return true;
    }
}