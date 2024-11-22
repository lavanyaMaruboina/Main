/**
* @Name         Demographic
* @Author       Nidhi Dhote
* @Company      Persistent Systems
* @Description  This class contains all methods related to Additonal Details initiation
* Inputs:       None
* Test Class:   DemographicTest
*/
public with sharing class Demographic {
    
    /*
* @Method:      docDemographicDetails
* @Created by:  Nidhi Dhote
* @Description: Method to insert all demographics details
* @Param:       String - demoGraphicDataString
* @Return:      String
*/
    @AuraEnabled
    public static String docDemographicDetails(String demoGraphicDataString){
        DemographicWrapper demoGraphicData;
        try{	
            demoGraphicData = (DemographicWrapper)JSON.deserialize(demoGraphicDataString, DemographicWrapper.class);
            System.debug('the data is '+ demoGraphicData);
            System.debug('the data is '+ demoGraphicData);
            Applicant__c docObject= new Applicant__c(Id=demoGraphicData.applicantId, Preferred_address_for_communication__c = demoGraphicData.preferredAddressForCommunication,
                                                     of_family_members_residing_with_you__c = demoGraphicData.ofFamilyMembersResidingWithYou,
                                                     Residence_country__c = demoGraphicData.residenceCountry,
                                                     Who_will_repay_the_loan__c = demoGraphicData.whoWillPayTheLoan,
                                                     Relationship_with_borrower__c = demoGraphicData.relationshipWithBorrower,
                                                     Marital_status__c = demoGraphicData.maritalStatus,
                                                     Spouse_Name__c = demoGraphicData.spouseName,
                                                     Father_s_name__c = demoGraphicData.fatherName,
                                                     Mother_s_name__c = demoGraphicData.motherName,
                                                     Communication_language__c = demoGraphicData.communicationLang,
                                                     Customer_Qualification__c = demoGraphicData.customerQualification,
                                                     Email_Id__c = demoGraphicData.emailId,
                                                     Contact_number__c = demoGraphicData.contactNumber
                                                    );
            
            if(Schema.sObjectType.Applicant__c.isUpdateable())
            {
                update docObject;
            }
            
        }
        catch(Exception e){
            System.debug('the exception'+e.getMessage() +e.getStackTraceString());
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('Demographic', ' docDemographicDetails ', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable())
            {
                insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        } 
        return demoGraphicData.applicantId; 
    }
    
    public class DemographicWrapper {
        public String applicantId { get; set; }
        public String preferredAddressForCommunication { get; set; }
        public String ofFamilyMembersResidingWithYou { get; set; }
        public String residenceCountry { get; set; }
        public String whoWillPayTheLoan { get; set; } 
        public String maritalStatus { get; set; }
        public String communicationLang { get; set; }
        public String customerQualification { get; set; }
        public String emailId { get; set; }
        public String spouseName { get; set; }
        public String fatherName { get; set; }
        public String motherName { get; set; }
        public String contactNumber { get; set; }
        public String relationshipWithBorrower { get; set; }
    }
    //End: docDemographicDetails function By Nidhi Dhote.
    
    /*
* @Method:      getDemographicDetails
* @Created by:  Nidhi Dhote
* @Description: Method to return  all demographics details
* @Param:       String - opportunityId , String -applicantType
* @Return:      Map<String, Object>
*/
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getDemographicDetails(String opportunityId, String applicantType){
        Map<String,Object> demographicDetails = new Map<String, Object>(); 
            List<Applicant__c> applicantList = new List<Applicant__c>();
            if (Schema.sObjectType.Applicant__c.isAccessible()) {
                applicantList = [SELECT Id, Preferred_address_for_communication__c, of_family_members_residing_with_you__c, Residence_country__c,  
                                 Who_will_repay_the_loan__c, Marital_status__c, Spouse_Name__c, Father_s_name__c, Mother_s_name__c, 
                                 Communication_language__c, Customer_Qualification__c, Email_Id__c,Contact_number__c, Relationship_with_borrower__c,
                                 Income_source_available__c, Email_Fail_Count__c FROM Applicant__c 
                                 WHERE Applicant_Type__c =: applicantType AND Opportunity__c =:opportunityId WITH SECURITY_ENFORCED LIMIT 1];
            }
            
            if(!applicantList.isEmpty()){
                demographicDetails.put('isApplicantPresent', true);
                demographicDetails.put('applicantRecord',applicantList[0]);
            } else {
                demographicDetails.put('isApplicantPresent', false);
            }
        
       
        return demographicDetails;
    }
    //End: getDemographicDetails function By Nidhi Dhote.
    
    
    /*
* @Method:      getDemographicDetails
* @Created by:  Nidhi Dhote
* @Description: Method to return  all demographics details
* @Param:       String - opportunityId , String -applicantType
* @Return:      Map<String, Object>
*/
    @AuraEnabled(cacheable=true)
    public static List<Applicant__c> getApplicantDetails(String opportunityId, String applicantType){ 
            List<Applicant__c> applicantList = new List<Applicant__c>();
            if (Schema.sObjectType.Applicant__c.isAccessible()) {
                applicantList = [SELECT ID,Income_source_available__c,Bureau_Pull_Message__c FROM Applicant__c 
                                 WHERE Applicant_Type__c =: applicantType AND Opportunity__c =:opportunityId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED];
            }
            return applicantList;
    }

    /*
* @Method:      validateBeneficiaryCount
* @Created by:  Gaurav Rawat
* @Description: Method to return  true if  beneficary added as per the customer type
* @Param:       String - opportunityId
* @Return:      BeneficiaryCountWrapper
*/
    @AuraEnabled
    public static BeneficiaryCountWrapper validateBeneficiaryCount(String opportunityId){
        Boolean  isValid = false;
        Integer  beneficiaryCount = 0;
        BeneficiaryCountWrapper  benifWrap = new BeneficiaryCountWrapper();
        Opportunity opp = [SELECT Entity_Type__c,(Select Id from Applicants__r WHERE Applicant_Type__c = 'Beneficiary' AND In_Active_Applicant__c = false) FROM Opportunity Where Id =: opportunityId  WITH SECURITY_ENFORCED LIMIT 1];
        List<Required_Beneficiary_Counts__mdt> requiredBenCountList = Required_Beneficiary_Counts__mdt.getAll().values();
        for (Required_Beneficiary_Counts__mdt benCountObj : requiredBenCountList) {
            if(benCountObj.MasterLabel == opp.Entity_Type__c){
                beneficiaryCount = Integer.valueOf(benCountObj.Beneficiary_Count__c);
                if(opp.Applicants__r.size() >= benCountObj.Beneficiary_Count__c){ isValid = true;}
                break;
            }
        }
        benifWrap.isValid = isValid;
        benifWrap.beneficiaryCount = beneficiaryCount;
        return benifWrap;
    }
    public class BeneficiaryCountWrapper{
        @AuraEnabled public Boolean isValid {get;set;}
        @AuraEnabled public Integer beneficiaryCount {get;set;}
    }
        /*
* @Method:      getApplicantDetail
* @Created by:  Gaurav Rawat
* @Description: Method to return  other than borrrower applicants
* @Param:       String - opportunityId
* @Return:      List<Applicant__c>
*/
    @AuraEnabled
    public static List<Applicant__c> getApplicantDetail(String opportunityId){ 
        List<Applicant__c> applicantList = new List<Applicant__c>();
        if (Schema.sObjectType.Applicant__c.isAccessible()) {
            applicantList = [SELECT Id,Bureau_Pull_Message__c,Applicant_Type__c,Bureau_Pull_Match__c FROM Applicant__c WHERE Opportunity__c =:opportunityId AND In_Active_Applicant__c = false AND Applicant_Type__c !=: System.Label.Borrower WITH SECURITY_ENFORCED];
        }
        return applicantList;
    }
}