/*------------------------------------------------------------
Author:        Manish Baldota
Company:       Persistent Systems
Description:   This class is wrapper class for the Membership API request 
Test Class:    IND_MembershipRequest_Test
History
Date            Author              Comments
-------------------------------------------------------------
12-17-2021      Manish Baldota       Created
------------------------------------------------------------*/
public class IND_MembershipRequest extends ParentAPIRequest{
    
    
    public string Application_No;
    public string Maker_Id;
    public string MembershipType;
    public string Consent;
    public string MembershipId;
    public string year_of_reg;
    public string medical_council;
    
    // @Method:      IND_MembershipRequest
    // @Created by:  Manish Baldota
    // @Description: Contructor to initialize the details
    // @Param:       Object applicant Record
    // @Return:      ''
    public IND_MembershipRequest(Applicant__c app,String inputJSONString,String loanAppId){         
        //currently hardcode Id's has been passed these will be changed at the time of handshaking.
        inputRequest request = (inputRequest)JSON.deserialize(inputJSONString,inputRequest.class );
        this.Application_No = app.Opportunity__r.Lead_number__c;
        this.Maker_Id = IntegrationUtilities.getMakerId();
        this.MembershipType = request.MembershipType;//app.Membership_Type__c
        this.Consent = 'Y';
        this.MembershipId = request.MembershipId;//app.Membership_Type__c
        if(this.MembershipType.equalsIgnoreCase(System.label.Membership_mci)){
            this.year_of_reg = request.year_of_reg; //app.Registration_Year__c;
            this.medical_council = request.medical_council;//app.Medical_Council__c; 
        }
        validate(System.Label.Membership);
    }    
    
    // @Method:      getHttpRequestHeaders
    // @Created by:  Manish Baldota
    // @Description: Method to get the HTTP request header data
    // @Param:       ''
    // @Return:      Header required to callout the service.
    public override Map<String,String> getHttpRequestHeaders(){    
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }
    
    // @Method:      getHttpRequestHeaders
    // @Created by:  Manish Baldota
    // @Description: Method to validate the required input details
    // @Param:       Service name
    // @Return:      True - If all the validations are passed.
    
    public override boolean validate(String serviceName){
        if(String.isBlank(this.Application_No)){
            throw new IND_Exception(System.Label.LeadId);
        } 
        if(String.isBlank(this.Maker_Id)){
            throw new IND_Exception(System.Label.Maker_IdError);
        }
        if(String.isBlank(this.MembershipId)){
            throw new IND_Exception(System.Label.Membership_Id_Error);
        }
        if(String.isBlank(this.year_of_reg) && this.MembershipType.equalsIgnoreCase(System.label.Membership_mci)){
            throw new IND_Exception(System.Label.year_of_regError);
        }
        if(String.isBlank(this.medical_council)  && this.MembershipType.equalsIgnoreCase(System.label.Membership_mci) ){
            throw new IND_Exception(System.Label.medical_councilError);
        }		
        return true;
    }
    public class inputRequest{
        public string MembershipType {get;set;}
        public string MembershipId {get;set;}
        public string year_of_reg {get;set;}
        public string medical_council {get;set;}
    }
}