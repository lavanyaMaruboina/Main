/**
* @Name         Demographic
* @Author       Nidhi Dhote 
* @Company      Persistent Systems
* @Description  This class contains all methods related to Additonal Details initiation
* Inputs:       None
* Test Class:   DemographicTest
*/
public with sharing class Ind_Demographic {
    
    Private final Static String CURRENT_FI = 'FI';
    Private final Static String CURRENT_FI_RECORDTYPE = 'Residence';
    Private final Static String CURRENT_FI_TITLE = System.Label.Case_Current_Residence_FI_Type;
    Private final Static String CURRENT_OFFICE_FI_RECORDTYPE = 'Office';
    Private final Static String CURRENT_OFFICE_FI_TITLE = System.Label.Case_Office_FI_Type;
    Private final Static String CASE_STATUS_FI_UNASSIGNED = 'FI-Unassigned';


    @AuraEnabled
    public static List<Applicant__c> getAllApplicantList(String recordId){
        try {
            return [SELECT Id,Applicant_Type__c,Name,CRIFF_Report_URL__c,Opportunity__r.CRIFF_Report_Initiated__c, Opportunity__r.Entity_Type__c,Opportunity__r.Product_Type__c,Opportunity__r.Customer_Type__c,Do_you_have_a_bank_account__c,(SELECT Id,IND_isNewCustomer__c FROM Customer_Dedupe_Response__r)  FROM Applicant__c WHERE In_Active_Applicant__c = false AND Opportunity__c=:recordId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
      @AuraEnabled
    public static Map<String, Object> getDemographicDetailsForIncome(String opportunityId, String applicantType){
        Map<String,Object> demographicDetails = new Map<String, Object>(); 
            List<Applicant__c> applicantList = new List<Applicant__c>();
            if (Schema.sObjectType.Applicant__c.isAccessible()) {
                applicantList = [SELECT Id, Preferred_address_for_communication__c, of_family_members_residing_with_you__c, Residence_country__c,  
                                 Who_will_repay_the_loan__c, Marital_status__c, Spouse_Name__c, Father_s_name__c, Mother_s_name__c, 
                                 Communication_language__c, Customer_Qualification__c, Email_Id__c,Contact_number__c, Relationship_with_borrower__c,
                                 Income_source_available__c, Email_Fail_Count__c,Is_Email_Valid__c, Is_Additional_Details_Submitted__c, Opportunity__r.LeadSource,
                                 Name_Ref_1__c, Relationship_with_Borrower_Ref_1__c, Address_Line_1_Ref_1__c, Address_Line_2_Ref_1__c, City_Ref_1__c, State_Ref_1__c,
                                 District_Ref_1__c, Pincode_Ref_1__c, Phone_Number_Ref_1__c, Name_Ref_2__c, Relationship_with_Borrower_Ref_2__c, Address_Line_1_Ref_2__c,
                                 Address_Line_2_Ref_2__c, City_Ref_2__c, State_Ref_2__c, District_Ref_2__c, Pincode_Ref_2__c, Phone_Number_Ref_2__c,Opportunity__r.Product_Type__c, Religion__c, Caste__c  FROM Applicant__c 
                                 WHERE Applicant_Type__c =: applicantType AND Opportunity__c =:opportunityId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED LIMIT 1];//Ola integration changes
            }
            
            if(!applicantList.isEmpty()){
                demographicDetails.put('isApplicantPresent', true);
                demographicDetails.put('applicantRecord',applicantList[0]);
            } else {
                demographicDetails.put('isApplicantPresent', false);
            }
        
       
        return demographicDetails;
    } 
    /*
    * @Method:      saveAdditionalDetails
    * @Created by:  Nidhi Dhote
    * @Description: Method to insert all demographics details
    * @Param:       String - demoGraphicDataString
    * @Return:      String
    */
    @AuraEnabled
    public static Boolean saveAdditionalDetails(String demoGraphicDataString){
        Boolean isDetailsSaved = false;
        try{	
            DemographicWrapper demoGraphicData = (DemographicWrapper)JSON.deserialize(demoGraphicDataString, DemographicWrapper.class);
            System.debug('saveAdditionalDetails - Update Data:: '+ demoGraphicData);

            // Query to fetch the Product Type
            List<Applicant__c> applicantRecords = [SELECT Id, Opportunity__r.Product_Type__c,Opportunity__r.Customer_Type__c,Applicant_Type__c  
            FROM Applicant__c 
            WHERE Id = :demoGraphicData.applicantId 
            LIMIT 1];

            Boolean isNonIndividualBorrower = (applicantRecords.size() > 0 && applicantRecords[0].Opportunity__r.Customer_Type__c == 'Non-Individual' && applicantRecords[0].Applicant_Type__c == System.Label.Borrower && applicantRecords[0].Opportunity__r.Product_Type__c == System.Label.Tractor) ? true : false;
            System.debug(isNonIndividualBorrower);

            if((String.isBlank(demoGraphicData.preferredAddressForCommunication) || String.isBlank(demoGraphicData.residenceCountry) ||
            String.isBlank(demoGraphicData.maritalStatus) || String.isBlank(demoGraphicData.fatherName) || String.isBlank(demoGraphicData.motherName) || String.isBlank(demoGraphicData.communicationLang) || String.isBlank(demoGraphicData.ofFamilyMembersResidingWithYou)) && isNonIndividualBorrower == false){
                throw new AuraHandledException('Fill all the demographic details!');
            }

            Applicant__c docObject= new Applicant__c(Id=demoGraphicData.applicantId, Preferred_address_for_communication__c = demoGraphicData.preferredAddressForCommunication,
                                                     of_family_members_residing_with_you__c = demoGraphicData.ofFamilyMembersResidingWithYou,
                                                     Residence_country__c = demoGraphicData.residenceCountry,
                                                     Who_will_repay_the_loan__c = demoGraphicData.whoWillPayTheLoan,
                                                     Repayment_Will_Be_Done_By__c = demoGraphicData.repaymentWillBeDoneBy,
                                                     Relationship_with_borrower__c = demoGraphicData.relationshipWithBorrower,
                                                     Marital_status__c = demoGraphicData.maritalStatus,
                                                     Spouse_Name__c = demoGraphicData.spouseName,
                                                     Father_s_name__c = demoGraphicData.fatherName,
                                                     Mother_s_name__c = demoGraphicData.motherName,
                                                     Communication_language__c = demoGraphicData.communicationLang,
                                                     Customer_Qualification__c = demoGraphicData.customerQualification,
                                                     Email_Id__c = demoGraphicData.emailId,
                                                     Is_Additional_Details_Submitted__c = demoGraphicData.SubmitSuccessfullCheckbox,Name_Ref_1__c = demoGraphicData.nameRef1,
                                                     Relationship_with_Borrower_Ref_1__c = demoGraphicData.relationshipWithBorrowerRef1,Address_Line_1_Ref_1__c = demoGraphicData.addressLine1Ref1,
                                                     Address_Line_2_Ref_1__c = demoGraphicData.addressLine2Ref1,City_Ref_1__c = demoGraphicData.CityRef1,
                                                     State_Ref_1__c = demoGraphicData.StateRef1,District_Ref_1__c = demoGraphicData.DistrictRef1,
                                                     Pincode_Ref_1__c = demoGraphicData.pincodeRef1,Phone_Number_Ref_1__c = demoGraphicData.phoneNumberRef1,
                                                     Name_Ref_2__c = demoGraphicData.nameRef2,Relationship_with_Borrower_Ref_2__c = demoGraphicData.relationshipWithBorrowerRef2,
                                                     Address_Line_1_Ref_2__c = demoGraphicData.addressLine1Ref2,Address_Line_2_Ref_2__c = demoGraphicData.addressLine2Ref2,
                                                     City_Ref_2__c = demoGraphicData.CityRef2,State_Ref_2__c = demoGraphicData.StateRef2,District_Ref_2__c = demoGraphicData.DistrictRef2,
                                                     Pincode_Ref_2__c = demoGraphicData.pincodeRef2,Phone_Number_Ref_2__c = demoGraphicData.phoneNumberRef2, Religion__c = demoGraphicData.religion,
                                                     Caste__c = demoGraphicData.caste,Feedback_Ref_1__c = demoGraphicData.feedbackRef1 , Feedback_Ref_2__c = demoGraphicData.feedbackRef2
                                                    );

            Boolean isNonIndividualLead = false;
            if(applicantRecords.size() > 0 && applicantRecords[0].Opportunity__r.Product_Type__c == System.Label.Tractor){
                docObject.Co_Borrower_Reside_with_borrower__c = demoGraphicData.coborrowerResideBorrower;
                isNonIndividualLead = applicantRecords[0].Opportunity__r.Customer_Type__c == 'Non-Individual' ? true : false;
                if(isNonIndividualLead == false){
                    docObject.Profile__c = 'AGRICULTURIST';
                }else{
                    docObject.Salutation__c = demoGraphicData.salutation;
                    docObject.Gender__c   = demoGraphicData.gender;
                    docObject.Category__c   = demoGraphicData.category;
                    docObject.Employer_Type__c   = demoGraphicData.employerType;
                    docObject.Date_of_Birth__c  = demoGraphicData.dateOfBirth != null ? Date.valueOf(demoGraphicData.dateOfBirth) : null;
                    docObject.Is_Customer_NRI__c   = demoGraphicData.isCustomerNRI;
                    docObject.Work_Permit_No__c   = demoGraphicData.workPermitNo;
                    docObject.Permit_Validity__c   = demoGraphicData.permitvalidity != null ? Date.valueOf(demoGraphicData.permitvalidity) : null;
                    docObject.Work_Visa_Details__c   = demoGraphicData.workVisaDetails;
                    docObject.LegalEntityIdentifier__c  = demoGraphicData.legalEntityIdentifier != null ? demoGraphicData.legalEntityIdentifier : null;
                    docObject.Salaried_Self_employed__c   = demoGraphicData.categoryType != null ? demoGraphicData.categoryType : null;
                    docObject.Co_Borrower_Reside_with_borrower__c = demoGraphicData.coborrowerResideBorrower;
                    docObject.Beneficiary_Office_Address_Line_1__c = demoGraphicData.beneadd1;//SFTRAC-552
                    docObject.Beneficiary_Office_Address_Line_2__c = demoGraphicData.beneadd2;
                    docObject.Beneficiary_Office_City__c = demoGraphicData.benecity;
                    docObject.Beneficiary_Office_Pincode__c = demoGraphicData.benepincode;
                    docObject.Beneficiary_Office_State__c = demoGraphicData.benestate;
                    docObject.Beneficiary_Office_District__c = demoGraphicData.beneDistrict;
                }
            }
           
            if(Schema.sObjectType.Applicant__c.isUpdateable()) {
                update docObject;
                isDetailsSaved = true;
            }
 //Create Case Start
          
 if(String.isNotBlank(demoGraphicData.applicantId) && (demoGraphicData.coborrowerResideBorrower == false || isNonIndividualLead == true)) {
    
    
    List<Applicant__c> applicantList = new List<Applicant__c>();

    applicantList = [select Id,Opportunity__c,Opportunity__r.OwnerId, Opportunity__r.Name, Opportunity__r.AccountId, Opportunity__r.Product_Type__c, Applicant_Type__c,Applicant__c.Name from Applicant__c where Id =: demoGraphicData.applicantId WITH SECURITY_ENFORCED limit 1];

    if(applicantList.size() > 0 && applicantList[0].Opportunity__r.Product_Type__c == System.Label.Tractor){

        String caseRecordType = Schema.SObjectType.CASE.getRecordTypeInfosByName().get(CURRENT_FI).getRecordTypeId();
        List<Case> caseList = new List<Case>([SELECT Id from Case Where Applicant__c =: applicantList[0].Id AND RecordTypeId =: caseRecordType AND Loan_Application__c =:applicantList[0].Opportunity__c]);
                 
        if(caseList.size() == 0){
            List<Documents__c> documentList = new List<Documents__c>([SELECT Id,Opportunity_Relation__c,KYC_Address_Line_1__c,KYC_Address_Line_2__c,KYC_City__c, KYC_Pin_Code__c, KYC_State__c, Document_Type__c,Applicant__r.Current_Same_As_Permanent__c, Image__c,Permanent_Residential_Address_Proof__c,Current_Residential_Address_Proof__c FROM Documents__c WHERE Applicant__c = :applicantList[0].Id AND (Permanent_Residential_Address_Proof__c = true OR Current_Residential_Address_Proof__c = true) AND KYC_Address_Line_1__c != null LIMIT 2]);

            if(isNonIndividualLead == true && applicantList[0].Applicant_Type__c == System.Label.Borrower){    
                Case caseObj = new Case();
                caseObj.RecordTypeId = caseRecordType;
                caseObj.Type = CURRENT_OFFICE_FI_TITLE;
                caseObj.OwnerId = applicantList[0].Opportunity__r.OwnerId;
                caseObj.Loan_Application__c = applicantList[0].Opportunity__c;
                caseObj.Status = CASE_STATUS_FI_UNASSIGNED;
                caseObj.Subject = applicantList[0].Opportunity__r.Name +'_'+ CURRENT_OFFICE_FI_TITLE +'_'+ applicantList[0].Applicant_Type__c;
                caseObj.Applicant__c = applicantList[0].Id;
                caseObj.AccountId = applicantList[0].Opportunity__r.AccountId;
                insert caseObj;
                        
                String fiRecordType = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get(CURRENT_OFFICE_FI_RECORDTYPE).getRecordTypeId();
        
                Field_Investigation__c fieldInvestigation = new Field_Investigation__c();
                fieldInvestigation.Case__c = caseObj.Id;
                for (Documents__c document : documentList) {
                    if(document.Permanent_Residential_Address_Proof__c == true){
                        fieldInvestigation.Address_Line_1__c = document.KYC_Address_Line_1__c;
                        fieldInvestigation.Address_Line_2__c = String.isBlank(document.KYC_Address_Line_2__c) ? document.KYC_Address_Line_1__c : document.KYC_Address_Line_2__c;
                        fieldInvestigation.City__c = document.KYC_City__c;
                        fieldInvestigation.Pin_Code__c = document.KYC_Pin_Code__c;
                        fieldInvestigation.State__c = document.KYC_State__c;
                    }
                }
                fieldInvestigation.RecordTypeId = fiRecordType;
                insert fieldInvestigation;
                List<Case> fiCaseList = [Select id,CaseNumber,OwnerId,Loan_Application__r.Name FROM Case Where Id=: caseObj.Id];
                if(fiCaseList.size() > 0){
                    CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'Notification_to_Onwer'];
                    Messaging.CustomNotification noti = new Messaging.CustomNotification();
            
                    noti.setBody('FI Case is assigned to you for Lead No. ' + fiCaseList[0].Loan_Application__r.Name + '. Click here to take action on this case.' );
                    noti.setTitle('FI Case - ' + fiCaseList[0].CaseNumber);
                    noti.setNotificationTypeId(notificationType.Id);
                    noti.setTargetId(fiCaseList[0].Id);
                    noti.send(new Set<String> { fiCaseList[0].OwnerId });
                }
            }

            Case caseObj = new Case();
            caseObj.RecordTypeId = caseRecordType;
            caseObj.Type = CURRENT_FI_TITLE;
            caseObj.OwnerId = applicantList[0].Opportunity__r.OwnerId;
            caseObj.Loan_Application__c = applicantList[0].Opportunity__c;
            caseObj.Status = CASE_STATUS_FI_UNASSIGNED;
            caseObj.Subject = applicantList[0].Opportunity__r.Name +'_'+ CURRENT_FI_TITLE +'_'+ applicantList[0].Applicant_Type__c;
            caseObj.Applicant__c = applicantList[0].Id;
            caseObj.AccountId = applicantList[0].Opportunity__r.AccountId;
            insert caseObj;

            String fiRecordType = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get(CURRENT_FI_RECORDTYPE).getRecordTypeId();

            Field_Investigation__c fieldInvestigation = new Field_Investigation__c();
            fieldInvestigation.Case__c = caseObj.Id;
            for (Documents__c document : documentList) {
                if(document.Current_Residential_Address_Proof__c == true){
                    fieldInvestigation.Address_Line_1__c = document.KYC_Address_Line_1__c;
                    fieldInvestigation.Address_Line_2__c = String.isBlank(document.KYC_Address_Line_2__c) ? document.KYC_Address_Line_1__c : document.KYC_Address_Line_2__c;
                    fieldInvestigation.City__c = document.KYC_City__c;
                    fieldInvestigation.Pin_Code__c = document.KYC_Pin_Code__c;
                    fieldInvestigation.State__c = document.KYC_State__c;
                }
            }
            fieldInvestigation.RecordTypeId = fiRecordType;
            insert fieldInvestigation;
            List<Case> fiCaseList = [Select id,CaseNumber,OwnerId,Loan_Application__r.Name FROM Case Where Id=: caseObj.Id];
            if(fiCaseList.size() > 0){
                CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'Notification_to_Onwer'];
                Messaging.CustomNotification noti = new Messaging.CustomNotification();
    
                noti.setBody('FI Case is assigned to you for Lead No. ' + fiCaseList[0].Loan_Application__r.Name + '. Click here to take action on this case.' );
                noti.setTitle('FI Case - ' + fiCaseList[0].CaseNumber);
                noti.setNotificationTypeId(notificationType.Id);
                noti.setTargetId(fiCaseList[0].Id);
                noti.send(new Set<String> { fiCaseList[0].OwnerId });

                List<OpportunityTeamMember> opptyTeams = new List<OpportunityTeamMember>([Select id from OpportunityTeamMember Where userId =: applicantList[0].Opportunity__r.OwnerId and OpportunityId =: applicantList[0].Opportunity__c]);
				if(opptyTeams.size() == 0){
                    OpportunityTeamMember oppTeam = new OpportunityTeamMember();
                    oppTeam.OpportunityId= applicantList[0].Opportunity__c;
                    oppTeam.UserId=applicantList[0].Opportunity__r.OwnerId;
                    oppTeam.TeamMemberRole='BE';
                    oppTeam.OpportunityAccessLevel = 'Edit'; 
                    insert oppTeam;
				}
            }
        }
    }          
}
//Create Case End
isDetailsSaved = true;
} catch(Exception e){
ErrorLoggerUtil.logErrorEvent('Demographic', ' saveAdditionalDetails ', System.Label.Apex, e);
isDetailsSaved = false;
throw new AuraHandledException(System.Label.ExceptionMessage);
} 
return isDetailsSaved; 
}
    
    /*
* @Method:      isOpenBankAccountWithIBL
* @Created by:  Prashant Dixit
* @Description: Method will return Boolean based on Condition
* @Param:       String - applicantId
* @Return:      Boolean
*/
    @AuraEnabled
    public static Boolean isOpenBankAccountWithIBL(String applicantId){
        try{	
            List<Applicant__c> applicantList = [SELECT Id,Do_you_have_a_bank_account_with_IBL__c,(SELECT Id,Aadhar_Source__c FROM Documents__r WHERE (Aadhar_Source__c = 'OTP' OR Aadhar_Source__c = 'Biometric') AND Document_Type__c =: Label.AadhaarCard AND is_Active__c = true) FROM Applicant__c Where Id =:applicantId Limit 1];
            List<Customer_Dedupe_Response__c> lstcdr =[SELECT Id,IND_isNewCustomer__c FROM Customer_Dedupe_Response__c where Applicant__c=:applicantId Limit 1];
            if(((!lstcdr.isEmpty() && lstcdr[0].IND_isNewCustomer__c && !applicantList.isEmpty() && !applicantList[0].Do_you_have_a_bank_account_with_IBL__c) || (!applicantList.isEmpty() && !applicantList[0].Do_you_have_a_bank_account_with_IBL__c)) && (applicantList.size() > 0 && applicantList[0].Documents__r.size() > 0)){
                return false;
            }
            return true;
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('Demographic', ' isOpenBankAccountWithIBL ', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        } 
    }
    @AuraEnabled
    public static Boolean isNewApplicant(String applicantId){
        try{
            List<Customer_Dedupe_Response__c> lstcdr =[SELECT Id,IND_isNewCustomer__c,Applicant__r.Do_you_have_a_bank_account__c FROM Customer_Dedupe_Response__c where Applicant__c=:applicantId Limit 1];
            if(!lstcdr.isEmpty() && lstcdr[0].IND_isNewCustomer__c == true && lstcdr[0].Applicant__r.Do_you_have_a_bank_account__c == false){
                return true;
            }
            return false;
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('Demographic', ' isOpenBankAccountWithIBL ', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        } 
    }

    /*
* @Method:      getApplicantDetailWhoWillRepayTheLaon
* @Created by:  Prashant Dixit
* @Description: Method will Applicant Data Who will repay the laon
* @Param:       String - applicantId
* @Return:      Applicant Information
*/
@AuraEnabled
public static Applicant__c getApplicantDetailWhoWillRepayTheLaon(String applicantId){
    try{	
        List<Applicant__c> applicantList = [SELECT Id,Would_you_like_to_open_a_bank_account__c,Nominee_address__c,Nominee_available__c,Nominee_City__c,
        Nominee_DOB__c,Nominee_name__c,Nominee_pin_code__c,Nominee_Relationship__c,Nominee_State__c  FROM Applicant__c Where Id =:applicantId Limit 1];
        if(!applicantList.isEmpty())
            return applicantList[0];
        return null;
    } catch(Exception e){
        ErrorLoggerUtil.logErrorEvent('Demographic', ' getApplicantDetailWhoWillRepayTheLaon ', System.Label.Apex, e);
        throw new AuraHandledException(System.Label.ExceptionMessage);
    } 
}

@AuraEnabled
public static map<string,Object> getApplicantMap (String loanApplicationId){
    try {
        Map<String,Object> applicantMap = new Map<String, Object>();
        List<String> beneficiaryIdSet = new List<String>();
        List<Applicant__c> applicantList = [SELECT Id  FROM Applicant__c Where Opportunity__c =:loanApplicationId AND Applicant_Type__c ='Beneficiary' Limit 10];
        for(Applicant__c  app : applicantList) {
            beneficiaryIdSet.add(app.Id);
        }
        applicantMap.put('beneficiaryId',beneficiaryIdSet);
        return applicantMap;
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
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
        public Boolean SubmitSuccessfullCheckbox { get; set; }
        public String nameRef1 { get; set; }
        public String relationshipWithBorrowerRef1 { get; set; }
        public String addressLine1Ref1 { get; set; }
        public String addressLine2Ref1 { get; set; }
        public String stateRef1 { get; set; }
        public String districtRef1 { get; set; } 
        public String cityRef1 { get; set; }
        public Integer pincodeRef1 { get; set; }
        public String phoneNumberRef1 { get; set; }
        public String nameRef2 { get; set; }
        public String relationshipWithBorrowerRef2 { get; set; }
        public String addressLine1Ref2 { get; set; }
        public String addressLine2Ref2 { get; set; }
        public String StateRef2 { get; set; }
        public String DistrictRef2 { get; set; } 
        public String CityRef2 { get; set; }
        public Integer pincodeRef2 { get; set; }
        public String phoneNumberRef2 { get; set; }
        public String religion { get; set; }
        public String caste { get; set; }
        public String repaymentWillBeDoneBy { get; set; }
        public Boolean coborrowerResideBorrower { get; set; } // Sftrac-94
        public String salutation { get; set; }
        public String gender { get; set; }
        public String category { get; set; }
        public String employerType { get; set; }
        public String dateOfBirth { get; set; }
        public Boolean isCustomerNRI { get; set; }
        public String workPermitNo { get; set; }
        public String permitvalidity { get; set; }
        public String workVisaDetails { get; set; }
        public String legalEntityIdentifier { get; set; }
        public String categoryType { get; set; }
        public String beneadd1 { get; set; }
        public String beneadd2 { get; set; }
        public String benestate { get; set; }
        public String benecity { get; set; }
        public String benedistrict { get; set; }
        public String benepincode { get; set; }
        public String feedbackRef1 {get;set;}
        public String feedbackRef2 {get;set;}
    }
    
    /*
    * @Method:      getDemographicDetails
    * @Created by:  Nidhi Dhote
    * @Description: Method to return  all demographics details
    * @Param:       String - opportunityId , String -applicantType, String applicantId
    * @Return:      Map<String, Object>
    */
    @AuraEnabled
    public static Map<String, Object> getDemographicDetails(String opportunityId, String applicantType, String applicantId){
        Map<String,Object> demographicDetails = new Map<String, Object>(); 
            List<Applicant__c> applicantList = new List<Applicant__c>();
            if (Schema.sObjectType.Applicant__c.isAccessible()) {
                applicantList = [SELECT Id,Scorecard_Decision__c,Do_you_have_a_bank_account_with_IBL__c,Repayment_Will_Be_Done_By__c,Applicant_Type__c,Preferred_address_for_communication__c, of_family_members_residing_with_you__c, Residence_country__c,  
                                 Who_will_repay_the_loan__c, Marital_status__c, Spouse_Name__c, Father_s_name__c, Mother_s_name__c, 
                                 Communication_language__c, Customer_Qualification__c, Email_Id__c,Contact_number__c, Relationship_with_borrower__c,
                                 Income_source_available__c, Email_Fail_Count__c,Is_Email_Valid__c, Is_Additional_Details_Submitted__c, Opportunity__r.LeadSource,
                                 Name_Ref_1__c, Relationship_with_Borrower_Ref_1__c, Address_Line_1_Ref_1__c, Address_Line_2_Ref_1__c, City_Ref_1__c, State_Ref_1__c,
                                 District_Ref_1__c, Pincode_Ref_1__c, Phone_Number_Ref_1__c, Name_Ref_2__c, Relationship_with_Borrower_Ref_2__c, Address_Line_1_Ref_2__c,
                                 Address_Line_2_Ref_2__c, City_Ref_2__c, State_Ref_2__c, District_Ref_2__c, Pincode_Ref_2__c, Phone_Number_Ref_2__c,Opportunity__r.Product_Type__c,Opportunity__r.StageName,Religion__c, Caste__c,Profile__c,Co_Borrower_Reside_with_borrower__c,Salutation__c,Gender__c,Category__c,Employer_Type__c,Date_of_Birth__c,Is_Customer_NRI__c,Work_Permit_No__c,Permit_Validity__c,Work_Visa_Details__c,LegalEntityIdentifier__c,Salaried_Self_employed__c,Feedback_Ref_1__c,Feedback_Ref_2__c  FROM Applicant__c 
                                 WHERE Applicant_Type__c =: applicantType AND Id =: applicantId AND Opportunity__c =:opportunityId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED LIMIT 1];//Ola integration changes
            }
            
            if(!applicantList.isEmpty()){
                demographicDetails.put('isApplicantPresent', true);
                demographicDetails.put('applicantRecord',applicantList[0]);
            } else {
                demographicDetails.put('isApplicantPresent', false);
            }
        
       
        return demographicDetails;
    }
    @AuraEnabled
    public static ApplicantReturnWrapper getRiskBandStatusValue(String opportunityId){
        try {
            ApplicantReturnWrapper applicationWrapper = new ApplicantReturnWrapper();
            List<Applicant__c> applicantList = new List<Applicant__c>();
            if (Schema.sObjectType.Applicant__c.isAccessible()) {
                applicantList = [SELECT ID , Applicant_Type__c, Scorecard_Decision__c FROM Applicant__c Where Opportunity__c =:opportunityId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED];
            }
            applicationWrapper.applicantList = applicantList;
            List<Retry_Count__c> retryCountListBorrower = [select Count__c from Retry_Count__c where Loan_Application_Id__c =:opportunityId AND Applicant__r.Applicant_Type__c='Borrower' AND Service_Name__c ='Risk Band' WITH SECURITY_ENFORCED limit 1];
            System_Constant_custom_metadata__mdt metadata = System_Constant_custom_metadata__mdt.getInstance('Risk_Band');
            if(retryCountListBorrower.size() > 0){
                if (retryCountListBorrower[0].Count__c >= metadata.Number_Of_Attempts__c) {
                    applicationWrapper.borrowerRiskBandCount='Max';
                  }
            }else{
                applicationWrapper.borrowerRiskBandCount='Safe';
            }
            List<Retry_Count__c> retryCountListcoBorrower = [select Count__c from Retry_Count__c where Loan_Application_Id__c =:opportunityId AND Applicant__r.Applicant_Type__c='Co-borrower' AND Service_Name__c ='Risk Band' WITH SECURITY_ENFORCED limit 1];
            if(retryCountListcoBorrower.size() > 0){
                if (retryCountListcoBorrower[0].Count__c >= metadata.Number_Of_Attempts__c) {
                    applicationWrapper.coBorrowerRiskBandCount='Max';
                  }
            }else{
                applicationWrapper.coBorrowerRiskBandCount='Safe';
            }
            return applicationWrapper;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class ApplicantReturnWrapper{
        @AuraEnabled
        public List<Applicant__c> applicantList;
        @AuraEnabled
        public String borrowerRiskBandCount;
        @AuraEnabled
        public String coBorrowerRiskBandCount;
        public ApplicantReturnWrapper(){
            this.coBorrowerRiskBandCount='Safe';
            this.borrowerRiskBandCount='Safe';
        }
    }

    @AuraEnabled(Cacheable=true)
  public static List<Applicant__c> getApplicant (string loanAppId){
    try{
      List<Applicant__c> lstLoanApplicant = new List<Applicant__c>([select Id,Name,Applicant_Type__c from Applicant__c where Opportunity__c =: loanAppId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED]);
      return lstLoanApplicant;
    }catch(Exception e){
      ErrorLoggerUtil.logErrorEvent('Ind_Demographic','getApplicant', System.Label.Apex, e, loanAppId);
      throw new AuraHandledException(System.Label.ExceptionMessage);
    }
  }

    @AuraEnabled
    public static String checkRetryExhausted(String loanApplicationId,String attemptFor,String applicantId){
        try{
            System.debug('Loan Appliation id :'+loanApplicationId+', attemptFor : '+attemptFor+', applicantId :');
            //Null Check 
            if(loanApplicationId != null && attemptFor != null){
                Retry_Count__c retryCount = new Retry_Count__c();
                List<Retry_Count__c> retryCountList = new List<Retry_Count__c>();
                retryCountList = [select Loan_Application_Id__c from Retry_Count__c where Loan_Application_Id__c =: loanApplicationId AND Applicant__c =:applicantId AND Service_Name__c =:attemptFor WITH SECURITY_ENFORCED];
                system.debug('retryCountList::'+retryCountList);
                if(retryCountList.isEmpty()) {
                    retryCount.Loan_Application_Id__c = loanApplicationId;
                    retryCount.Service_Name__c = attemptFor;
                    retryCount.Applicant__c = applicantId;
                    retryCount.Count__c = 1;
                    if(Schema.sObjectType.Retry_Count__c.isCreateable()){
                        insert retryCount;
                    }
                    return System.Label.SuccessMessage;
                }
                else{
                    System_Constant_custom_metadata__mdt metadata = System_Constant_custom_metadata__mdt.getInstance('Risk_Band'); 
                    Retry_Count__c  count = [select Count__c from Retry_Count__c where Loan_Application_Id__c =: loanApplicationId AND Applicant__c =:applicantId AND Service_Name__c =:attemptFor WITH SECURITY_ENFORCED limit 1];
                    if(count.Count__c > metadata.Number_Of_Attempts__c){
                        return System.Label.Retry_Exhausted;
                    }
                    else{
                        count.Count__c += 1;
                        if (Schema.sObjectType.Retry_Count__c.isUpdateable()){
                            update count;
                        }                    
                        return System.label.SuccessMessage;
                    }
                }
            }  
            return System.label.FailureMessage;
    } catch(Exception e){
        ErrorLoggerUtil.logErrorEvent('Ind_Demographic' ,'checkRetryExhausted', System.Label.Apex, e);
        throw new AuraHandledException(System.Label.ExceptionMessage);
    }
}  
    
    /*
    * @Method:      getApplicantDetails
    * @Created by:  Nidhi Dhote
    * @Description: Method to return  all Applicant Details
    * @Param:       String - opportunityId
    * @Return:      List of Applicants
    */
    @AuraEnabled
    public static List<Applicant__c> getApplicantDetails(String opportunityId){ 
            List<Applicant__c> applicantList = new List<Applicant__c>();
            if (Schema.sObjectType.Applicant__c.isAccessible()) {
                applicantList = [SELECT ID , Income_source_available__c,Do_you_have_a_bank_account__c,Do_you_have_a_bank_account_with_IBL__c,Would_you_like_to_open_a_bank_account__c,Contact_number__c, Applicant_Type__c, In_Active_Applicant__c, Opportunity__r.Product_Type__c, Opportunity__r.LeadSource  FROM Applicant__c 
                                 WHERE Opportunity__c =:opportunityId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED];
            }
            return applicantList;
    }
     /*
* @Method:      getBeneOfficeAddress
* @Created by:  Santhosh
* @Description: Method to return  office address of Beneficiary if exists
* @Param:       String - applicantId
* @Return:      List of Applicants
*/
@AuraEnabled
public static List<Applicant__c> getBeneOfficeAddress(String applicantId){
    try {
    List<Applicant__c> applicantList = new List<Applicant__c>();
    if (Schema.sObjectType.Applicant__c.isAccessible()) {
        applicantList = [SELECT ID ,Beneficiary_Office_Address_Line_1__c,Beneficiary_Office_Address_Line_2__c,Beneficiary_Office_City__c,Beneficiary_Office_State__c,Beneficiary_Office_Pincode__c,Beneficiary_Office_District__c  FROM Applicant__c 
                         WHERE Id =:applicantId AND In_Active_Applicant__c = false AND Applicant_Type__c = 'Beneficiary' AND Beneficiary_Office_Address_Line_1__c != null AND Beneficiary_Office_City__c != null AND Beneficiary_Office_State__c != null AND Beneficiary_Office_District__c != null AND Beneficiary_Office_Pincode__c != null WITH SECURITY_ENFORCED];
    }
    if(!applicantList.isEmpty()){
        return applicantList;
    }
    return null;
}
    catch (Exception e) {
    throw new AuraHandledException(e.getMessage());
}
}
     /*
* @Method:      getBorrowerOfficeAddress
* @Created by:  Santhosh
* @Description: Method to return  office address of borrower if exists
* @Param:       String - opportunityId
* @Return:      sObject - Document
*/
@AuraEnabled
public static Documents__c getBorrowerOfficeAddress(String loanId){
    try {
    List<Applicant__c> applicantList = new List<Applicant__c>();
    List<Documents__c> docList = new List<Documents__c>();
    if (Schema.sObjectType.Applicant__c.isAccessible()) {
        applicantList = [SELECT ID ,Beneficiary_Office_Address_Line_1__c,Beneficiary_Office_Address_Line_2__c,Beneficiary_Office_City__c,Beneficiary_Office_State__c,Beneficiary_Office_Pincode__c,Beneficiary_Office_District__c  FROM Applicant__c 
                         WHERE In_Active_Applicant__c = false AND Applicant_Type__c = 'Borrower' AND Opportunity__c =:loanId WITH SECURITY_ENFORCED];
    }
    if(!applicantList.isEmpty()){
       docList = [SELECT Id,KYC_Address_Line_1__c,KYC_Address_Line_2__c,KYC_City__c,KYC_District__c,KYC_State__c,KYC_Pin_Code__c FROM Documents__c WHERE Applicant__c=:applicantList[0].Id AND KYC_Address_Line_1__c!= null AND KYC_City__c != null AND KYC_District__c != null AND KYC_State__c != null AND KYC_Pin_Code__c != null];
    }
    if(!docList.isEmpty()){
        return docList[0];
    }
    return null;
}
    catch (Exception e) {
    throw new AuraHandledException(e.getMessage());
}
}
    @AuraEnabled
    public static List<Applicant__c> getAdditionalDetailsSubmittedValue(String opportunityId){
        try {
            List<Applicant__c> applicantList = new List<Applicant__c>();

            if (Schema.sObjectType.Applicant__c.isAccessible()) {
                applicantList = [SELECT ID , Applicant_Type__c, Is_Additional_Details_Submitted__c FROM Applicant__c Where Opportunity__c =:opportunityId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED];
            }

            system.debug('applicantList:: '+applicantList);

            if(applicantList.isEmpty()){
                return null;
            } else {
                return applicantList;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /*
* @Method:      documentValidation
* @Created by:  Santhosh
* @Description: Method to validate the required documents for the non-individual tractor loan applications
* @Param:       String - borrowerId, String -entityType, Boolean - resicumoffice
* @Return:      String - Validation Message
*/
    @AuraEnabled
    public static string documentValidation(String borrowerId, String entityType, Boolean resicumoffice){
        try {
            Map<String,String> mapDocs = new Map<String,String>();
            List<String> entityProofDocs = new List<String>();
            List<Documents__c> docList = new List<Documents__c>();
            String errorMsg = '';
            entityProofDocs.add('MSME REGISTRATION CERTIFICATE');
            entityProofDocs.add('UDYAM REGISTRATION CERTIFICATE');            
            entityProofDocs.add('REGISTRATION CERTIFICATE - OTHERS');
            entityProofDocs.add('SHOPS AND ESTABLISHMENT CERTIFICATE');
            entityProofDocs.add('TAX/SERVICE TAX/PROFESSIONAL TAX AUTH');
            entityProofDocs.add('FACTORY REGISTRATION CERTIFICATE');
            entityProofDocs.add('CERTIFICATE ISSUED BY STATE/CENTRAL/LOCAL AUTHORITIES');
            entityProofDocs.add('TRADE LICENCE');
            entityProofDocs.add('IMPORT AND EXPORT CERTIFICATE');
            entityProofDocs.add('GST Certificate');
            docList = [Select Id,Document_Type__c FROM Documents__c WHERE Applicant__c=:borrowerId];
            for(Documents__c doc:docList){
                mapDocs.put(doc.Document_Type__c,doc.Id);
            }
            if(entityType == 'Proprietorship'){
                docList = [Select Id,Document_Type__c FROM Documents__c WHERE Applicant__c=:borrowerId and Document_Type__c IN:entityProofDocs];
                if(docList.size()<2){
                    errorMsg = 'Please upload any 2 of these documents- GST,MSME REGISTRATION CERTIFICATE,UDYAM REGISTRATION CERTIFICATE,REGISTRATION CERTIFICATE (ANY),SHOPS & ESTABLISHMENT CERTIFICATE,TAX/SERVICE TAX/PROFESSIONAL TAX AUTH,FACTORY REGISTRATION CERTIFICATE,CERTIFICATE ISSUED BY STATE/CENTRAL/LOCAL AUTHORITIES,TRADE LICENCE,IMPORT & EXPORT CERTIFICATE';
                    return errorMsg;
                }
                /*if(!resicumoffice){ //commented code CISP-23793
                    if(!mapDocs.containsKey('Utility bill in the name of company')){
                        errorMsg = 'Please upload Utlity bill in the name of company document';
                        return errorMsg;
                    }
                }*/
                if(!mapDocs.containsKey('PAN')){
                        errorMsg = 'Please upload PAN Document';
                        return errorMsg;
                    }    
            }
            if(entityType == 'Partnership'){
                Boolean check = false;
                for(String str:entityProofDocs){
                    if(mapDocs.containsKey(str)){
                        check = true;
                    }
                }
                if(!check){
                    errorMsg = 'Please upload any of these documents- GST,MSME REGISTRATION CERTIFICATE,UDYAM REGISTRATION CERTIFICATE,REGISTRATION CERTIFICATE (ANY),SHOPS & ESTABLISHMENT CERTIFICATE,TAX/SERVICE TAX/PROFESSIONAL TAX AUTH,FACTORY REGISTRATION CERTIFICATE,CERTIFICATE ISSUED BY STATE/CENTRAL/LOCAL AUTHORITIES,TRADE LICENCE,IMPORT & EXPORT CERTIFICATE';
                    return errorMsg;
                }
                /*if(!resicumoffice){//commented code CISP-23793
                    if(!mapDocs.containsKey('Utility bill in the name of company')){
                        errorMsg = 'Please upload Utlity bill in the name of company document';
                        return errorMsg;
                    }
                }*/
                if(!mapDocs.containsKey('PARTNERSHIP DEED')){
                    errorMsg = 'Please upload Partnership Deed Document';
                    return errorMsg;
                }
                if(!mapDocs.containsKey('PAN')){
                        errorMsg = 'Please upload PAN Document';
                        return errorMsg;
                    }
                if(!mapDocs.containsKey('List of Partners')){
                        errorMsg = 'Please upload List of Partners Document';
                        return errorMsg;
                    }      
                if(!mapDocs.containsKey('PARTNERSHIP REGISTRATION CERT')){
                    errorMsg = 'Please upload PARTNERSHIP REGISTRATION CERT/PARTNERSHIP LETTER Document';
                    return errorMsg;
                    }  
                if(!mapDocs.containsKey('Beneficial Ownership Declaration')){
                        errorMsg = 'Please upload Beneficial Ownership Declaration Document';
                        return errorMsg;
                    }     	
            }
            if(entityType == 'Pvt Ltd' || entityType == 'Public Ltd'){
                Boolean check = false;
                for(String str:entityProofDocs){
                    if(mapDocs.containsKey(str)){
                        check = true;
                    }
                }
                if(!check){
                    errorMsg = 'Please upload any of these documents- GST,MSME REGISTRATION CERTIFICATE,UDYAM REGISTRATION CERTIFICATE,REGISTRATION CERTIFICATE (ANY),SHOPS & ESTABLISHMENT CERTIFICATE,TAX/SERVICE TAX/PROFESSIONAL TAX AUTH,FACTORY REGISTRATION CERTIFICATE,CERTIFICATE ISSUED BY STATE/CENTRAL/LOCAL AUTHORITIES,TRADE LICENCE,IMPORT & EXPORT CERTIFICATE';
                    return errorMsg;
                }
                /*if(!resicumoffice){
                    if(!mapDocs.containsKey('Utility bill in the name of company')){
                        errorMsg = 'Please upload Utlity bill in the name of company document';
                        return errorMsg;
                    }
                }*/
                if(!mapDocs.containsKey('PAN')){
                    errorMsg = 'Please upload PAN Document';
                    return errorMsg;
                }
                if(!mapDocs.containsKey('CERTIFICATE OF INCORPORATION')){
                    errorMsg = 'Please upload CERTIFICATE OF INCORPORATION Document';
                    return errorMsg;
                }
                if(!mapDocs.containsKey('MEMORANDUM OF ASSOCIATION')){
                    errorMsg = 'Please upload MEMORANDUM OF ASSOCIATION Document';
                    return errorMsg;
                }
                if(!mapDocs.containsKey('ARTICLES OF ASSOCIATION')){
                    errorMsg = 'Please upload ARTICLES OF ASSOCIATION Document';
                    return errorMsg;
                }
                if(!mapDocs.containsKey('Board Resolution')){
                    errorMsg = 'Please upload Board Resolution Document';
                    return errorMsg;
                }
                if(!mapDocs.containsKey('List of Directors')){
                    errorMsg = 'Please upload List of Directors Document';
                    return errorMsg;
                }
                if(!mapDocs.containsKey('Beneficial Ownership Declaration')){
                    errorMsg = 'Please upload Beneficial Ownership Declaration Document';
                    return errorMsg;                
                }  	
            }
            if(entityType == 'Limited Liability Partnership'){
                Boolean check = false;
                for(String str:entityProofDocs){
                    if(mapDocs.containsKey(str)){
                        check = true;
                    }
                }
                if(!check){
                    errorMsg = 'Please upload any of these documents- GST,MSME REGISTRATION CERTIFICATE,UDYAM REGISTRATION CERTIFICATE,REGISTRATION CERTIFICATE (ANY),SHOPS & ESTABLISHMENT CERTIFICATE,TAX/SERVICE TAX/PROFESSIONAL TAX AUTH,FACTORY REGISTRATION CERTIFICATE,CERTIFICATE ISSUED BY STATE/CENTRAL/LOCAL AUTHORITIES,TRADE LICENCE,IMPORT & EXPORT CERTIFICATE';
                    return errorMsg;                
                }
                if(!resicumoffice){
                    if(!mapDocs.containsKey('Utility bill in the name of company')){
                        errorMsg = 'Please upload Utlity bill in the name of company document';
                        return errorMsg;  
                    }
                }
                if(!mapDocs.containsKey('PAN')){
                    errorMsg = 'Please upload PAN Document';
                    return errorMsg;  
                }
                if(!mapDocs.containsKey('CERTIFICATE OF INCORPORATION')){
                    errorMsg = 'Please upload CERTIFICATE OF INCORPORATION Document';
                    return errorMsg;  
                }
                if(!mapDocs.containsKey('LLP Agreement')){
                    errorMsg = 'Please upload LLP Agreement Document';
                    return errorMsg;  
                }
                if(!mapDocs.containsKey('PARTNERSHIP REGISTRATION CERT') && !mapDocs.containsKey('Board Resolution')){
                    errorMsg = 'Please upload Board Resolution/Partnership letter';
                    return errorMsg; 
                }
                if(!mapDocs.containsKey('List of Partners')){
                    errorMsg = 'Please upload List of Partners Document';
                    return errorMsg; 
                }      
                if(!mapDocs.containsKey('Beneficial Ownership Declaration')){
                    errorMsg = 'Please upload Beneficial Ownership Declaration Document';
                    return errorMsg; 
                }     	
                
            }
            if(entityType == 'Trust' || entityType == 'Co-Operative Society' || entityType == 'Assosiation of Persons'){
                if(!mapDocs.containsKey('PAN')){
                    errorMsg = 'Please upload PAN Document';
                    return errorMsg; 
                }
                if(!mapDocs.containsKey('REGISTRATION CERTIFICATE - OTHERS')){
                    errorMsg = 'Please upload REGISTRATION CERTIFICATE (ANY) Document';
                    return errorMsg; 
                }
                if(!mapDocs.containsKey('Board Resolution')){
                    errorMsg = 'Please upload Board Resolution Document';
                    return errorMsg; 
                }
                if(!resicumoffice){
                    if(!mapDocs.containsKey('Utility bill in the name of company')){
                        errorMsg = 'Please upload Utlity bill in the name of company document';
                        return errorMsg; 
                    }
                }
                if(!mapDocs.containsKey('List of Trustees/Office Bearers')){
                    errorMsg = 'Please upload List of Trustees/Office Bearers Document';
                    return errorMsg; 
                }
                if(!mapDocs.containsKey('Beneficial Ownership Declaration')){
                    errorMsg = 'Please upload Beneficial Ownership Declaration Document';
                    return errorMsg; 
                }  
                if(!mapDocs.containsKey('TRUST DEED/BYE LAW')){
                    errorMsg = 'Please upload Trust Deed/Bye law document';
                    return errorMsg; 
                }
            }
            if(entityType=='HUF'){
                Boolean check = false;
                for(String str:entityProofDocs){
                    if(mapDocs.containsKey(str)){
                        check = true;
                    }
                }
                if(!check){
                    errorMsg = 'Please upload any of these documents- GST,MSME REGISTRATION CERTIFICATE,UDYAM REGISTRATION CERTIFICATE,REGISTRATION CERTIFICATE (ANY),SHOPS & ESTABLISHMENT CERTIFICATE,TAX/SERVICE TAX/PROFESSIONAL TAX AUTH,FACTORY REGISTRATION CERTIFICATE,CERTIFICATE ISSUED BY STATE/CENTRAL/LOCAL AUTHORITIES,TRADE LICENCE,IMPORT & EXPORT CERTIFICATE';
                    return errorMsg; 
                }
                if(!mapDocs.containsKey('PAN')){
                    errorMsg = 'Please upload PAN Document';
                    return errorMsg; 
                }
                if(!mapDocs.containsKey('List of Co-Percenters')){
                    errorMsg = 'Please upload List of Co-Percenters Document';
                    return errorMsg; 
                }
                if(!resicumoffice){
                    if(!mapDocs.containsKey('Utility bill in the name of company')){
                        errorMsg = 'Please upload Utlity bill in the name of company document';
                        return errorMsg; 
                    }
                }
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<Applicant__c> checkAllApplicantPhoneNo(String loanAppId){
        try {
            List<Applicant__c> appList = [SELECT ID,Contact_number__c, Applicant_Type__c  from Applicant__c WHERE Opportunity__c =: loanAppId AND In_Active_Applicant__c = false];
            if(appList.size()>0){
                return appList;
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}