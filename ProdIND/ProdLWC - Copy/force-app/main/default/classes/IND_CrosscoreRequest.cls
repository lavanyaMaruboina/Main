/*------------------------------------------------------------
Author: Gaurav Rawat
Description: This class is wrapper class for the Crosscore api request
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
------------------------------------------------------------*/

public class IND_CrosscoreRequest extends ParentAPIRequest {
    
        public final Header header{get;set;}
        public final Payload payload{get;set;}
    
        public class Header {
            public String tenantId{get;set;}
            public String clientReferenceId{get;set;}
            public String messageTime{get;set;}
            public String requestType{get;set;}
            public Options options{get;set;}
        }
    
        public class Options {
            public String version{get;set;}
        }
    
        public class Payload {
            public String source{get;set;}
            public List<Contact> contacts{get;set;}
            public Application application{get;set;}
        }
    
        public class Contact {
            public String id{get;set;}
            public String personIdentifier{get;set;}
            public Person person{get;set;}
            public Organization organization{get;set;}
            public List<IdentityDocument> identityDocuments{get;set;}
            public List<Income> incomes{get;set;}
            public List<EmploymentHistory> employmentHistory{get;set;}
            public List<Address> addresses{get;set;}
            public List<Telephone> telephones{get;set;}
            public List<Email> emails{get;set;}
        }
    
        public class Person {
            public String id{get;set;}
            public String typeOfPerson{get;set;}
            public PersonDetails personDetails{get;set;}
            public List<Name> names{get;set;}
        }

        public class Organization {
            public String id{get;set;}
            public String typeOfOrganization{get;set;}
            public String orgName{get;set;}
            public String companyType{get;set;}
            public String companyRegistrationNumber{get;set;}
            public String tradingAsName{get;set;}
            public String miscReference{get;set;}
        }
    
        public class PersonDetails {
            public String dateOfBirth{get;set;}
            public Integer age{get;set;}
            public String gender{get;set;}
            public String nationalityCountryCode{get;set;}
            public String occupancyStatus{get;set;}
        }
    
        public class Name {
            public String id{get;set;}
            public String type{get;set;}
            public String firstName{get;set;}
            public String initials{get;set;}
            public String surName{get;set;}
        }
    
        public class IdentityDocument {
            public String id{get;set;}
            public String documentNumber{get;set;}
            public String documentType;
            public String documentDateOfBirth{get;set;}
            public String placeOfIssue{get;set;}
            public String issueCountryCode{get;set;}
            public String validFromDate{get;set;}
            public String expiresDate{get;set;}
        }       
    
        public class Application {
            public String sourceOfIntroduction{get;set;}
            public String originalRequestTime{get;set;}
            public String status{get;set;}
            public Boolean notificationRequired{get;set;}
            public ProductDetails productDetails{get;set;}
            public List<Applicant> applicants{get;set;}
            public List<ApplicationEntity> applicationEntities;
        }

        public class Applicant {
            public String id{get;set;}
            public String contactId{get;set;}
            public String type{get;set;}
            public String applicantType{get;set;}
            public String knownCustomer{get;set;}
            public Boolean consent{get;set;}
        }

        public class ApplicationEntity {
            public String id{get;set;}
            public String entityType{get;set;}
            public String contactId{get;set;}
        }

        public class ProductDetails {
            public String productType{get;set;}
            public ProductAmount productAmount{get;set;}
            public LendingTerm lendingTerm{get;set;}
            public String purposeOfLoan{get;set;}
            public String productCode{get;set;}
            public AssetValue assetValue{get;set;}
            public OriginalAssetValue originalAssetValue{get;set;}
        }
    
        public class ProductAmount {
            public String amount{get;set;}
            public String currencyCode{get;set;}
        }
    
        public class LendingTerm {
            public Integer duration{get;set;}
            public String unit{get;set;}
        }
    
        public class AssetValue {
            public Integer amount{get;set;}
            public String currencyCode{get;set;}
        }
        public class OriginalAssetValue {
            public Integer amount{get;set;}
            public String currencyCode{get;set;}
        }
    
        public class EmploymentHistory {
            public String id{get;set;}
            public String employerName{get;set;}
            public EmployerAddress employerAddress{get;set;}
            public List<EmployerTelephone> employerTelephones{get;set;}
            public String employmentType{get;set;}
            public String employmentStatus{get;set;}
            public TimeWithEmployer timeWithEmployer{get;set;}
            public String empStartDate{get;set;}
            public String employeeNumber{get;set;}
            public String jobType{get;set;}
            public String typeOfOrganization{get;set;}
            public String employerIndustry{get;set;}
            public List<Email> emails{get;set;}
        }

        public class TimeWithEmployer {
            public Integer duration{get;set;}
            public String unit{get;set;}
        }

        public class EmployerAddress {
            public String addressType{get;set;}
            public String poBoxNumber{get;set;}
            public String buildingName{get;set;}
            public String street{get;set;}
            public String street2{get;set;}
            public String locality{get;set;}
            public String postTown{get;set;}
            public String postal{get;set;}
            public String stateProvinceCode{get;set;}
            public String countryCode{get;set;}
        }
    
        public class EmployerTelephone {
            public String number1{get;set;}
            public String stdCode{get;set;}
            public String extension{get;set;}
        }

        public class Address {
            public String id{get;set;}
            public String addressType{get;set;}
            public String buildingName{get;set;}
            public String street{get;set;}
            public String street2{get;set;}
            public String locality{get;set;}
            public String postTown{get;set;}
            public String county{get;set;}
            public String postal{get;set;}
            public String stateProvinceCode{get;set;}
            public String countryCode{get;set;}
            public TimeAtAddress timeAtAddress{get;set;}
            public String propertyType{get;set;}
        }
    
        public class TimeAtAddress {
            public String unit{get;set;}
        }
    
        public class Telephone {
            public String id{get;set;}
            public String number1{get;set;}
            public String stdCode{get;set;}
            public String type{get;set;}
        }
    
        public class Email {
            public String id{get;set;}
            public String type{get;set;}
            public String email{get;set;}
        }

        public class Income {}
    
    // @Method:      IND_CrosscoreRequest
    // @Created by:  Gaurav Rawat
    // @Description: Contructor to initialize the details
    // @Param:       Object Request Wrapper
    // @Return:      ''
    // 
    public IND_CrosscoreRequest(String loanApplicationId, List<String> beneficiaryId,String batchIndex){
        Opportunity oppObj = new Opportunity();
        oppObj = [Select Id,Customer_Type__c,Entity_Type__c,Name from Opportunity Where Id =: loanApplicationId WITH SECURITY_ENFORCED LIMIT 1];
        Boolean isIndividual = oppObj.Customer_Type__c == 'Individual' ? true : false;
        List<Documents__c> documentList = new List<Documents__c>([Select id,Salutation__c,Masked_KYC_No__c,Aadhar_Source__c,Document_Side__c,KYC_No__c,KYC_DOB__c,PAN_No__c,KYC_Name__c,KYC_Address_Line_1__c,Applicant__r.Application_Consent_SMS_Sent_Time__c,Permanent_Residential_Address_Proof__c,Current_Residential_Address_Proof__c,Addresss_Type__c,Applicant__r.Applicant_Type__c,
        KYC_Address_Line_2__c,IND_Aadhaar_Vault_Token_ID__c,KYC_Address_Line_3__c,KYC_Address_Line_4__c,KYC_City__c,KYC_District__c,KYC_State__c,KYC_Pin_Code__c,
        Document_Type__c,Gender__c,RecordType.Name,Proof_of_Address_POA__c, Proof_of_Identity_POI__c, Passport_No__c, KYC_Expiry_Date__c,KYC_Issuance_Date__c,CreatedById,createdDate,Aadhaar_Enrollment_Number__c,Applicant__c from Documents__c Where Opportunity_Relation__c =: loanApplicationId and Is_Active__c = true and Applicant__r.In_Active_Applicant__c = false WITH SECURITY_ENFORCED]);

        List<Applicant__c> applicantList = new List<Applicant__c>([Select id,Applicant_Type__c,Name,Customer_First_Name__c,Customer_Last_Name__c,Contact_number__c,Email_Id__c from Applicant__c Where Opportunity__c =: loanApplicationId and In_Active_Applicant__c = false AND Applicant_Type__c !='Beneficiary' WITH SECURITY_ENFORCED]);

        List<Applicant__c> applicantBenefList = new List<Applicant__c>([Select id,Applicant_Type__c,Name,Customer_First_Name__c,Customer_Last_Name__c,Contact_number__c,Email_Id__c from Applicant__c Where Opportunity__c =: loanApplicationId and In_Active_Applicant__c = false And Id IN :beneficiaryId WITH SECURITY_ENFORCED]);
        
        applicantList.addAll(applicantBenefList);
        Map<Id,List<IdentityDocument>> identityDocumentMap = new Map<Id,List<IdentityDocument>>();
        Map<Id,Documents__c> panDocumentMap = new Map<Id,Documents__c>();
        Map<Id,List<Documents__c>> addressDocumentMap = new Map<Id,List<Documents__c>>();
        for(Documents__c doc : documentList){
            if(doc.Document_Type__c != null && doc.Document_Type__c != System.Label.CustomerImageDocumentType){
                IdentityDocument identityDocumentObj = new IdentityDocument();
                identityDocumentObj.id = doc.Id;
                if(doc.Document_Type__c == System.Label.PanCards && String.isNotBlank(doc.PAN_No__c)){
                    identityDocumentObj.documentNumber = IntegrationUtilities.getDecryptedResponse(doc.PAN_No__c,System.Label.privateKey,System.Label.ivkey);
                }else if(doc.Document_Type__c == System.Label.PassportCard && String.isNotBlank(doc.Passport_No__c)){
                    identityDocumentObj.documentNumber = IntegrationUtilities.getDecryptedResponse(doc.Passport_No__c,System.Label.privateKey,System.Label.ivkey);
                }else if((doc.Document_Type__c == System.Label.AadhaarCard || doc.Document_Type__c == System.Label.VoterIdCard) && String.isNotBlank(doc.KYC_No__c)){
                    identityDocumentObj.documentNumber = IntegrationUtilities.getDecryptedResponse(doc.KYC_No__c,System.Label.privateKey,System.Label.ivkey);
                }else{
                    identityDocumentObj.documentNumber ='123456789';
                }
                identityDocumentObj.validFromDate = doc.KYC_Issuance_Date__c == null ? '' : (doc.KYC_Issuance_Date__c + '').split(' ')[0];
                identityDocumentObj.expiresDate = doc.KYC_Expiry_Date__c == null ? '' : (doc.KYC_Expiry_Date__c + '').split(' ')[0];
                identityDocumentObj.placeOfIssue = '';
                identityDocumentObj.issueCountryCode = '';
                identityDocumentObj.documentType = getDocumentType(doc.Document_Type__c);
                identityDocumentObj.documentDateOfBirth = doc.KYC_DOB__c == null ? '' : (doc.KYC_DOB__c + '').split(' ')[0];
                if(identityDocumentMap.containsKey(doc.Applicant__c)){
                    List<IdentityDocument> identityDocumentList = new List<IdentityDocument>();
                    identityDocumentList = identityDocumentMap.get(doc.Applicant__c);
                    identityDocumentList.add(identityDocumentObj);
                    identityDocumentMap.put(doc.Applicant__c,identityDocumentList);
                }else{
                    identityDocumentMap.put(doc.Applicant__c,new List<IdentityDocument>{identityDocumentObj});
                }

                if((doc.Document_Type__c == System.Label.PanCards || doc.Document_Type__c == System.Label.Form60DocumentType) && !panDocumentMap.containsKey(doc.Applicant__c)){
                    panDocumentMap.put(doc.Applicant__c,doc);
                }

                if(addressDocumentMap.containsKey(doc.Applicant__c) && (doc.Current_Residential_Address_Proof__c == true || doc.Permanent_Residential_Address_Proof__c == true)){
                    List<Documents__c> documentListTemp = new List<Documents__c>();
                    documentListTemp = addressDocumentMap.get(doc.Applicant__c);
                    documentListTemp.add(doc);
                    addressDocumentMap.put(doc.Applicant__c,documentListTemp);
                }else if(doc.Current_Residential_Address_Proof__c == true || doc.Permanent_Residential_Address_Proof__c == true){
                    addressDocumentMap.put(doc.Applicant__c, new List<Documents__c>{doc});
                }
            }
        }

        this.header = new Header();
        this.header.tenantId = System.Label.TenantId;
        if(isIndividual){
            this.header.clientReferenceId = oppObj.Name;
        }else {
            this.header.clientReferenceId = oppObj.Name + '_'+batchIndex;
        }
        this.header.messageTime = DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        this.header.requestType = 'HunterOnly';
        this.header.options = new Options();
        this.header.options.version = '1';
        this.payload = new Payload();
        this.payload.source = 'WEB';
        
        List<Contact> contactList = new List<Contact>();

        for(Applicant__c applicant : applicantList){
            Contact contact = new Contact();
            contact.id = 'APPLICANT_' + applicant.Id; 
            
            if((isIndividual == false && applicant.Applicant_Type__c == System.Label.Borrower)){
                contact.organization = new Organization();
                contact.organization.id = applicant.Id;
                contact.organization.orgName = applicant.Name == null ? '' : applicant.Name;
                contact.organization.tradingAsName = applicant.Name == null ? '' : applicant.Name;
                contact.organization.typeOfOrganization = '';
                contact.organization.companyType = getCompanyType(oppObj.Entity_Type__c);
                contact.organization.miscReference = '';
                contact.organization.companyRegistrationNumber = '';
            }else{
                contact.person = new Person();
                contact.person.id = applicant.Id;
                contact.personIdentifier = applicant.Id;
                contact.person.typeOfPerson = getTypeOfPerson(applicant.applicant_type__c);
                contact.person.personDetails = new PersonDetails();

                Documents__c panDocument = panDocumentMap.containsKey(applicant.Id) ? panDocumentMap.get(applicant.Id) : new Documents__c();
                Integer age = 0;
                if(panDocument.KYC_DOB__c != null){
                    Date dt =  panDocumentMap.get(applicant.Id).KYC_DOB__c;
                    Integer days = dt.daysBetween(Date.Today());
                    age = (Integer)days/365;
                }
                 String gender = '';
                if(panDocument.Gender__c != null){
                    gender = panDocument.Gender__c.substring(0, 1);
                }
                if((applicant.applicant_type__c!=System.Label.Beneficiary && !isIndividual)|| (isIndividual && applicant.applicant_type__c!=Label.Guarantor)){
                      contact.person.personDetails.age = age;
                      contact.person.personDetails.dateOfBirth = panDocument.KYC_DOB__c == null ? '' : (panDocument.KYC_DOB__c + '').split(' ')[0];
                      contact.person.personDetails.gender = gender;

                    
                }
                contact.person.personDetails.nationalityCountryCode = '';
                contact.person.personDetails.occupancyStatus = '';
                contact.person.names = new List<Name>();

                Name nameObj = new Name();
                if(isIndividual == true){
                    nameObj.id = applicant.applicant_type__c == System.Label.Borrower ? 'MAINAPPLICANTNAMES_' + applicant.Id : 'JOINTAPPLICANTNAMES_' + applicant.Id;
                }else if(isIndividual == false){
                    nameObj.id = applicant.applicant_type__c == System.Label.Borrower ? 'BROKER_' + applicant.Id : applicant.applicant_type__c == System.Label.Guarantor ? 'MAIN_PROMOTOR_' + applicant.Id : applicant.applicant_type__c == System.Label.coBorrower ? 'CO_PROMOTOR_' + applicant.Id : applicant.applicant_type__c == System.Label.Beneficiary ? 'REF_' + applicant.Id : '';
                }
                nameObj.type = 'CURRENT';
                nameObj.firstName = applicant.Customer_First_Name__c == null ? '' : applicant.Customer_First_Name__c;
                nameObj.initials = gender;
                nameObj.surName = applicant.Customer_Last_Name__c == null ? '' : applicant.Customer_Last_Name__c;
                contact.person.names.add(nameObj);
            }
            contact.identityDocuments = new List<IdentityDocument>();
            if(isIndividual == true && applicant.applicant_type__c!=Label.Guarantor && identityDocumentMap.containsKey(applicant.Id)){
                contact.identityDocuments.addAll(identityDocumentMap.get(applicant.Id));
            }
            contact.addresses = new List<Address>();
            contact.telephones = new List<Telephone>();
            contact.emails = new List<Email>();
            contact.incomes = new List<Income>();
            contact.employmentHistory = new List<EmploymentHistory>();
            if(isIndividual == true && applicant.applicant_type__c == System.Label.Borrower){
                contact.incomes = new List<Income>();
                List<EmployerTelephone> employerTelephoneObjList = new List<EmployerTelephone>();
                List<Email> employerEmailList = new List<Email>();
                EmployerAddress employerAddressObj = new EmployerAddress();
                EmploymentHistory employmentHistoryObj = new EmploymentHistory();
                EmployerTelephone employerTelephoneObj = new EmployerTelephone();
                TimeWithEmployer timeWithEmployerObj = new TimeWithEmployer();
                Email employerEmail = new Email();
                employmentHistoryObj.timeWithEmployer = new TimeWithEmployer();
                employmentHistoryObj.employerTelephones = new List<EmployerTelephone>();
                employmentHistoryObj.emails = new List<Email>();
                employmentHistoryObj.id = '';
                employmentHistoryObj.employerName = '';
                employmentHistoryObj.employmentType = '';
                employmentHistoryObj.employmentStatus = '';
                employerAddressObj.addressType = '';
                employerAddressObj.poBoxNumber = '';
                employerAddressObj.buildingName = '';
                employerAddressObj.street = '';
                employerAddressObj.street2 = '';
                employerAddressObj.locality = '';
                employerAddressObj.postTown = '';
                employerAddressObj.postal = '';
                employerAddressObj.stateProvinceCode = '';
                employerAddressObj.countryCode = '';
                employerEmail.id = '';
                employerEmail.type = '';
                employerEmail.email = '';
                employerTelephoneObj.number1 = '';
                employerTelephoneObj.stdCode = '';
                employerTelephoneObj.extension = '';
                timeWithEmployerObj.duration = 0;
                timeWithEmployerObj.unit = '';
                employmentHistoryObj.emails = employerEmailList;
                employmentHistoryObj.empStartDate = '';
                employmentHistoryObj.employeeNumber = '';
                employmentHistoryObj.jobType = '';
                employmentHistoryObj.typeOfOrganization = '';
                employmentHistoryObj.employerIndustry = '';
                employmentHistoryObj.employerAddress = employerAddressObj;
                employmentHistoryObj.employerTelephones = employerTelephoneObjList;
                employmentHistoryObj.timeWithEmployer = timeWithEmployerObj;
                employerEmailList.add(employerEmail);
                employerTelephoneObjList.add(employerTelephoneObj);
                contact.employmentHistory.add(employmentHistoryObj);
                Telephone telephoneObj = new Telephone();
                telephoneObj.id = 'APPLICANT_1_TEL_' + applicant.Id;
                telephoneObj.number1 = applicant.Contact_number__c == null ? '' : applicant.Contact_number__c;
                telephoneObj.stdCode = '0';
                telephoneObj.type = 'MOBILE';
                contact.telephones.add(telephoneObj);
                Email applicantEmailObj = new Email();
                applicantEmailObj.id = 'Email_1_' + applicant.Id;
                applicantEmailObj.type = 'Personal';
                applicantEmailObj.email = applicant.Email_Id__c == null ? '' : applicant.Email_Id__c;
                contact.emails.add(applicantEmailObj);
            }
            
            if(addressDocumentMap.containsKey(applicant.Id)){
                for(Documents__c document : addressDocumentMap.get(applicant.Id)){
                    if(document.Applicant__r.Applicant_Type__c == System.Label.Borrower && isIndividual == false && document.Current_Residential_Address_Proof__c == true){
                        continue;
                    }
                    Address addressObj = new Address();
                    addressObj.id = 'ADDRESS_' + document.Id;
                    if(document.Applicant__r.Applicant_Type__c == System.Label.Borrower && isIndividual == false && document.Permanent_Residential_Address_Proof__c == true){
                        addressObj.addressType = 'REGISTERED_OFFICE';
                    }else {
                        if(document.Addresss_Type__c == 'Current Residential Address' || document.Current_Residential_Address_Proof__c){
                            addressObj.addressType = 'CURRENT';
                        }
                        else if(document.Addresss_Type__c == 'Permanent Residential Address' || document.Permanent_Residential_Address_Proof__c){
                            addressObj.addressType = 'PRIMARY';
                        }
                        
                    }
                    addressObj.buildingName = document.KYC_Address_Line_1__c == null ? '' : document.KYC_Address_Line_1__c;
                    addressObj.street = document.KYC_Address_Line_2__c == null ? '' : document.KYC_Address_Line_2__c;
                    addressObj.street2 = document.KYC_Address_Line_2__c == null ? '' : document.KYC_Address_Line_2__c;
                    addressObj.locality = document.KYC_Address_Line_1__c == null ? '' : document.KYC_Address_Line_1__c;
                    addressObj.postTown = document.KYC_City__c == null ? '' : document.KYC_City__c;
                    addressObj.county = 'India';
                    addressObj.postal = document.KYC_Pin_Code__c == null ? '' : document.KYC_Pin_Code__c;
                    addressObj.stateProvinceCode = 'IND-BH';
                    addressObj.countryCode = 'IND';
                    addressObj.propertyType = '';
                    addressObj.timeAtAddress = new TimeAtAddress();
                    TimeAtAddress timeAtaddressObj = new TimeAtAddress();
                    timeAtaddressObj.unit = '';
                    addressObj.timeAtAddress = timeAtaddressObj;
                    contact.addresses.add(addressObj);
                }
            }
            contactList.add(contact);
        }
        this.payload.contacts = new List<Contact>();
        this.payload.contacts.addAll(contactList);

        this.payload.application = new Application();
        Application applicationObj = new Application();
        applicationObj.sourceOfIntroduction = '';
        applicationObj.originalRequestTime = DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        applicationObj.status = 'UNKNOWN';
        applicationObj.notificationRequired = true;
        
        applicationObj.productDetails = new ProductDetails();
        ProductDetails productDetailsObj = new ProductDetails();
        productDetailsObj.productType = 'T';
        productDetailsObj.productAmount = new ProductAmount();
        ProductAmount productAmountObj = new ProductAmount();
        productAmountObj.amount = '';
        productAmountObj.currencyCode = '';
        productDetailsObj.productAmount = productAmountObj;
        productDetailsObj.lendingTerm = new LendingTerm();
        LendingTerm lendingTermoobj = new LendingTerm();
        lendingTermoobj.duration = 0;
        lendingTermoobj.unit = '';
        productDetailsObj.lendingTerm = lendingTermoobj;
        productDetailsObj.purposeOfLoan = '';
        productDetailsObj.productCode = isIndividual ? 'T_INDV' : 'T_NINDV';
        productDetailsObj.assetValue = new AssetValue();
        AssetValue assetValueObj = new AssetValue();
        assetValueObj.amount = 0;
        assetValueObj.currencyCode = '';
        productDetailsObj.assetValue = assetValueObj;
        
        productDetailsObj.originalAssetValue = new OriginalAssetValue();
        OriginalAssetValue originalAssetValueObj = new OriginalAssetValue();
        originalAssetValueObj.amount = 0;
        originalAssetValueObj.currencyCode = '';
        productDetailsObj.originalAssetValue = originalAssetValueObj;
        applicationObj.productDetails = productDetailsObj;

        applicationObj.applicants = new List<Applicant>();
        applicationObj.applicationEntities = new List<ApplicationEntity>();
        
        if(isIndividual == true){
            for(Applicant__c applicant : applicantList){
                Applicant applicantObj = new Applicant();
                applicantObj.id = applicant.Id;
                applicantObj.contactId = 'APPLICANT_' + applicant.Id;
                if(applicant.applicant_type__c == System.Label.Borrower){
                    applicantObj.type = 'INDIVIDUAL';
                    applicantObj.applicantType = 'MAIN_APPLICANT';
                }else if(applicant.applicant_type__c == System.Label.coBorrower){
                    applicantObj.type = 'INDIVIDUAL';
                    applicantObj.applicantType = 'JOINT_APPLICANT';
                }else if(applicant.applicant_type__c == System.Label.Guarantor){
                    applicantObj.type = 'INDIVIDUAL';
                    applicantObj.applicantType = 'REFERENCE';
                }
                applicantObj.knownCustomer = '';
                applicantObj.consent = true;
                applicationObj.applicants.add(applicantObj);
            }
        }if(isIndividual == false){
            for(Applicant__c applicant : applicantList){
                if(applicant.applicant_type__c == System.Label.Borrower){
                    ApplicationEntity applicationEntityObj = new ApplicationEntity();
                    applicationEntityObj.id = applicant.Id;
                    applicationEntityObj.entityType = 'SMEORGANIZATION';
                    applicationEntityObj.contactId = 'APPLICANT_' + applicant.Id;
                    applicationObj.applicationEntities.add(applicationEntityObj);
                }else {
                    Applicant applicantObj = new Applicant();
                    applicantObj.id = applicant.Id;
                    applicantObj.contactId = 'APPLICANT_' + applicant.Id;
                    if(applicant.applicant_type__c == System.Label.Guarantor){
                        applicantObj.type = 'INDIVIDUAL';
                        applicantObj.applicantType = 'PROMOTER';
                    }else if(applicant.applicant_type__c == System.Label.coBorrower){
                        applicantObj.type = 'INDIVIDUAL';
                        applicantObj.applicantType = 'COPROMOTER';
                    }else if(applicant.applicant_type__c == System.Label.Beneficiary){
                        applicantObj.type = 'INDIVIDUAL';
                        applicantObj.applicantType = 'REFERENCE';
                    }
                    applicantObj.knownCustomer = '';
                    applicantObj.consent = true;
                    applicationObj.applicants.add(applicantObj);
                }
            }
        }
        this.payload.application = applicationObj;
    }
    public override Map<String,String> getHttpRequestHeaders(){
        return null;
    }

    public override boolean validate(String serviceName){
        return true;
    }
    public String getDocumentType(String documentType){
        if(documentType == System.Label.AadhaarCard){
            return 'AADHAR ID';
        }else if(documentType == System.Label.PanCards){
            return 'PAN';
        }else if(documentType == System.Label.VoterIdCard){
            return 'VOTERS CARD';
        }else if(documentType == System.Label.DrivingLicences){
            return 'DRIVING LISENCE';
        }else if(documentType == System.Label.PassportCard){
            return 'PASSPORT';
        }else if(documentType == 'Electronic Bill'){
            return 'ELECTRICITY BILL';
        }else if(documentType == 'Gas bill'){
            return 'GAS BILL';
        }
        return 'OTHER';
    }

    public string getCompanyType(String entityType){
        if(entityType == 'Pvt Ltd'){
            return 'Private Limited Co';
        }else if(entityType == 'Public Ltd'){
            return 'Public Limited Co';
        }else if(entityType == 'Business Entities Created by Statute'){
            return 'SHGS- Direct – Others';
        }else if(entityType == 'Proprietorship'){
            return 'Proprietorship';
        }else if(entityType == 'Partnership'){
            return 'Partnership';
        }else if(entityType == 'Trust'){
            return 'Trust';
        }else if(entityType == 'HUF'){
            return 'SHGS- Direct – Others';
        }else if(entityType == 'Co-Operative Society'){
            return 'SHGS- Direct – Others';
        }else if(entityType == 'Assosiation of Persons'){
            return 'SHGS- Direct – Others';
        }
        return '';
    }

    public string getTypeOfPerson(String applicantType){
        if(applicantType == Label.Borrower){
            return 'APPLICANT';
        }else if(applicantType == Label.CoBorrower){
            return 'CO_APPLICANT';
        }else if(applicantType == Label.Guarantor){
            return 'GUARANTOR';
        }else if(applicantType == Label.Beneficiary){
            return 'POLICY_HOLDER';
        }
        return 'REFERENCE';
    }
}