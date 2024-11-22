/*------------------------------------------------------------
Author:        Nagendra pindipolu
Company:       Persistent Systems
Description:   This class is wrapper class for the Perfios IBL BRE API request 
Test Class:     
History
Date            Author               Comments 
-------------------------------------------------------------
12-28-2021      Nagendra pindipolu   Created
03-14-2022      Satyam More          Modified
------------------------------------------------------------*/
public class IND_BREscoreCardRequest extends ParentAPIRequest {
    //request paramaters for BREscoreCard request
    public final string Lead_Id {get;set;}
    public final string product {get;set;}
    public final string vehicleType{get;set;}
    public final string mobileNumber {get;set;}
    public final string applicantType{get;set;}
    public final string dateOfBirth {get;set;}
    public final string pinCode {get;set;}
    public final string gender {get;set;}
    public final string category {get;set;}
    public final string maritalStatus {get;set;}
    public final string state {get;set;}
    public final string country{get;set;}
    public final string profile {get;set;}
    public final string Maker_Id {get;set;}
    public final string purposeOfPurchase {get;set;}
    
    // @Method:      IND_BREscoreCardRequest
    // @Created by:  Nagendra pindipolu
    // @Description: Contructor to initialize the details
    // @Param:       Object applicant Record
    // @Return:      ''
    public IND_BREscoreCardRequest(Applicant__c app,Documents__c doc,String loanAppId){ 

        List<Income_Details__c> profileList = [SELECT id, Profile__r.code__c, Profile__r.Category__c 
                                               FROM Income_Details__c 
                                               WHERE Applicant__c =: app.id WITH SECURITY_ENFORCED];

        List<BankBranchDetails__c> stateList = [SELECT Id, Geo_State_Master__r.State_Code__c 
                                                FROM BankBranchDetails__c 
                                                WHERE Bl_Code_Details__r.Bl_Code__c =:app.Opportunity__r.Agent_BL_code__c  WITH SECURITY_ENFORCED];    

         List<Vehicle_Detail__c> vehicleDetails = [SELECT Purpose_of_Purchase__c 
                                                  FROM Vehicle_Detail__c 
                                                  WHERE Loan_Application__c = :app.Opportunity__c LIMIT 1];   
        if (!vehicleDetails.isEmpty()) {
            this.purposeOfPurchase = vehicleDetails[0].Purpose_of_Purchase__c;
        } else {
            this.purposeOfPurchase = '';  
        }  

        if(stateList.isEmpty()){
        this.state = '';
        } else {
        this.state = stateList.isEmpty() == true ? '' : stateList[0].Geo_State_Master__r.State_Code__c;
        }
                                     
        this.Lead_Id = app.Opportunity__r.Lead_number__c + '_' + app.applicant_number__c; 
        this.product = app.Opportunity__r.Product_Type__c != null && app.Opportunity__r.Product_Type__c == 'Two Wheeler' ?'H': app.Opportunity__r.Product_Type__c == 'Passenger Vehicles' ?'C' : app.Opportunity__r.Product_Type__c == System.Label.Tractor ? 'T' : '';
        this.vehicleType = app.Opportunity__r.Vehicle_Type__c == 'New'?'N' : app.Opportunity__r.Vehicle_Type__c == 'Used' ?'U' : app.Opportunity__r.Vehicle_Type__c == 'Refinance' ?'R' : '';
        this.mobileNumber = app.Contact_number__c;
        this.applicantType = app.Applicant_Type__c;
        this.dateOfBirth = String.valueOf(doc.KYC_DOB__c); 
        this.pinCode = String.valueOf(doc.KYC_Pin_Code__c);
        this.gender= app.Gender__c != null && app.Gender__c == 'FEMALE'?'1': app.Gender__c == 'MALE'?'2' : app.Gender__c == 'TRANSGENDER'?'3': '';
        this.category = profileList.isEmpty() == true ? 'NE' : profileList[0].Profile__r.Category__c; 
        this.maritalStatus = app?.Marital_status__c ==null?'':String.valueOf(app?.Marital_status__c);
        this.country = app.Residence_country__c == null ? 'India' : app.Residence_country__c;
        if(app.Opportunity__r.Product_Type__c == System.Label.Tractor){
            this.profile = profileList.isEmpty() == true ? String.isNotBlank(app.Profile__c) ? app.Profile__c : 'Agriculture' : profileList[0].Profile__r.code__c; 
        }else{
            this.profile = profileList.isEmpty() == true ? app.Profile__c : profileList[0].Profile__r.code__c; 
        }
        this.Maker_Id= IntegrationUtilities.getMakerId();       
        
        validate(System.Label.BREscorecardAPI);
    }
    // @Method:      getHttpRequestHeaders
    // @Created by:  Nagendra pindipolu
    // @Description: Method to get the HTTP request header data
    // @Param:       ''
    // @Return:      Header required to callout the service.
    public override Map<String,String> getHttpRequestHeaders(){    
        //Map to store HTTP request header data
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }
    // @Method:      validate
    // @Created by:  Nagendra pindipolu
    // @Description: Method to validate the required input details
    // @Param:       Service name
    // @Return:      True - If all the validations are passed.
    public override boolean validate(String serviceName){
    
        if(this.Lead_Id== null && String.isBlank(this.Lead_Id)){
            throw new IND_Exception(System.Label.Lead_IDError);
        }
        if(this.product== null && String.isBlank(this.product)){
            throw new IND_Exception(System.Label.product);
        }
        if(this.vehicleType == null && String.isBlank(this.vehicleType)){
            throw new IND_Exception(System.Label.vehicleType);
        }
        if(this.mobileNumber== null && String.isBlank(this.mobileNumber)){
            throw new IND_Exception(System.Label.mobileNumber);
        }
        if(this.applicantType == null && String.isBlank(this.applicantType)){
            throw new IND_Exception(System.Label.applicantType);
        }        
        if(this.dateOfBirth== null && String.isBlank(this.dateOfBirth)){
            throw new IND_Exception(System.Label.dateOfBirth);
        }
        if(this.pinCode== null && String.isBlank(this.pinCode)){
            throw new IND_Exception('Pincode is Missing');
        }
        if(this.gender== null && String.isBlank(this.gender)){
            throw new IND_Exception(System.Label.gender);
        } 
        if(this.category== null && String.isBlank(this.category)){
            throw new IND_Exception(System.Label.category);
        }
        if(this.maritalStatus== null && String.isBlank(this.maritalStatus)){
            throw new IND_Exception(System.Label.maritalStatus);
        }
        if(this.state== null && String.isBlank(this.state)){
            throw new IND_Exception(System.Label.state);
        }
        if(this.country== null && String.isBlank(this.country)){
            throw new IND_Exception(System.Label.country);
        }
        if(this.profile== null && String.isBlank(this.profile)){
            throw new IND_Exception(System.Label.profile);
        }
        if(this.Maker_Id== null && String.isBlank(this.Maker_Id)){
            throw new IND_Exception(System.Label.Maker_IdError);
        }
        
        return true;
    }
}