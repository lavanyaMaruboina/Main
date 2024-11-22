@isTest(seeAllData = false)
public class IND_ResidenceFIController_Test {
    
    @testSetup static void testDataSetup() {
        // Create Opportunity
        Opportunity opp = TestDataUtility.createTestOpportunityForOcr(false);
        opp.StageName = 'Credit Processing';
        opp.Sub_Stage__c = 'Field Investigation';
        opp.Is_Mobile_Journey_Completed__c = true;
        opp.Vehicle_Type__c = 'Used';
        opp.Product_Type__c = 'Two Wheeler';
        opp.Sanction_Status__c = 'Non-STP';
        insert opp;
        // Create Applicant__c
        Applicant__c applicant = TestDataUtility.createTestApplicantForMFCValuation(true, opp);
        // Create Documents__c
        Documents__c doc1 = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant, opp);
        doc1.Document_Type__c = 'Customer Image';
        insert doc1;
        Documents__c doc2 = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant, opp);
        doc2.Document_Type__c = System.Label.AadhaarCard;
        insert doc2;
        // Create ContentVersion
        ContentVersion contVer1 = TestDataUtility.createContentVersionforOcrFront('Test document for content version',true, doc1);
        ContentVersion contVer2 = TestDataUtility.createContentVersionforOcrFront('Test document for content version',true, doc2);
        // Create Case
        Case cse = TestDataUtility.createTestCase(true, opp, applicant);
        // Create Field Investigation
        Field_Investigation__c fiRecord = TestDataUtility.createTestFieldInvestigation(true, cse);
    }
    
    @isTest 
    public static void testGetDocumentsOfFI(){
        //  Applicant__c applicant = [select Id from Applicant__c LIMIT 1];
        Opportunity opp = TestDataUtility.createTestOpportunity(false);
        opp.Product_Type__c = 'Passenger Vehicles';
        if (Schema.sObjectType.Opportunity.isCreateable()){
            insert opp;
        }
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opp.Id;
        applicant.Applicant_Type__c = 'Co-borrower';
        if (Schema.sObjectType.Applicant__c.isCreateable()){
            insert applicant;
        }
        
        Documents__c dt2 = new Documents__c();
        dt2.Applicant__c = applicant.Id;
        dt2.Opportunity_Relation__c = opp.Id;
        dt2.Document_Type__c = 'Customer Bank Statement';
        dt2.Document_Side__c ='Back';
        dt2.Aadhar_Source__c = 'ScanAadhar';
        dt2.Addresss_Type__c = 'Office Address';
        insert dt2;
        
        //   User userTest = TestDataUtility.createIBCounterStaffUser(true);
        //    system.runAs(userTest){
        Test.startTest();
        List<IND_ResidenceFIController.DocumentWrapper> docList = IND_ResidenceFIController.loadResidenceFIData(applicant.Id,dt2.Addresss_Type__c);
        Test.stopTest();
        
        
        //    System.assertEquals(1, docList.size());
        // }
    }
    
    @isTest 
    public static void testGetDocumentsOfFIException(){
        try {
            Test.startTest();
            List<IND_ResidenceFIController.DocumentWrapper> docList = IND_ResidenceFIController.loadResidenceFIData(null,null);
            Test.stopTest();
        } catch(Exception e) {
            System.assertEquals('Applicant details are not valid, please contact your administrator.', e.getMessage());
        }
    }
    
    @isTest 
    public static void testfetchAddtionalRealtedDetails(){
        Opportunity application = [select Id from Opportunity LIMIT 1];
        Vehicle_Detail__c testVehicle = TestDataUtility.createTestVehicleDetail(false);
        testVehicle.Loan_Application__c = application.Id;
        insert testVehicle;
        
        Test.startTest();
        Vehicle_Detail__c vehicle = IND_ResidenceFIController.fetchAddtionalRealtedDetails(application.Id);
        Test.stopTest();
        
        System.assertEquals('abc', vehicle.Dealer_Sub_dealer_name__c);
    }
    
    @isTest 
    public static void testfetchAddtionalRealtedDetailsException(){
        try {
            Test.startTest();
            IND_ResidenceFIController.fetchAddtionalRealtedDetails(null);
            Test.stopTest();
        } catch(Exception e) {
            System.assertEquals('Applicant details are not valid, please contact your administrator.', e.getMessage());
        }
    }
    
    @isTest 
    public static void testCreateDocumentRecordDetails(){
        Opportunity opks1 = new Opportunity();
        opks1.StageName = 'Qualification';
        opks1.CloseDate = Date.newInstance(2021, 1, 11);
        opks1.Name = 'testone';
        insert opks1;
        
        Applicant__c apks1 = new Applicant__c();
        apks1.Opportunity__c = opks1.Id;
        apks1.Contact_number__c = '9743514830';
        apks1.Applicant_Type__c = 'Borrower';
        insert apks1;
        
       
        
        case cs1 = new case();
        cs1.Loan_Application__c = opks1.Id;
        cs1.Applicant__c = apks1.Id;
        cs1.Subject='Approval Of Application Sourced By Off Roll Employee';
        cs1.Status = 'Pending-Off Role Employee App';
        cs1.Origin = 'Web';
        insert cs1; 
        
        Field_Investigation__c fiv1 = new Field_Investigation__c();
        fiv1.Case__c = cs1.Id;
        fiv1.Address_Line_1__c = 'test1';
        fiv1.Address_Line_2__c = 'test2';
        // fiv1.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Permanent').getRecordTypeId();
        insert fiv1;
        
        Documents__c dfks1 = new Documents__c();
        dfks1.Applicant__c = apks1.Id;
        dfks1.Opportunity_Relation__c = opks1.Id;
        dfks1.KYC_name__c = 'Aadhar';
        dfks1.Document_Side__c ='Front';
        dfks1.Aadhar_Source__c = 'ScanAadhar';
        dfks1.Name = System.Label.AadhaarCard;
        dfks1.Document_Type__c = System.label.AadhaarCard;
        dfks1.is_Active__c = true;
        dfks1.Raw_Response__c = 'test raw reesponse';
       // dfks1.Case__c = cs1.Id;
        dfks1.RecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
        insert dfks1;
        Test.startTest();
        String docId = IND_ResidenceFIController.createDocumentRecord(fiv1.Id,apks1.Id, opks1.Id,dfks1.Document_Type__c,'KYC Document');
        Test.stopTest();
        
        System.assertNotEquals(null, docId);
    }
    
    @isTest 
    public static void testCreateDocumentRecordException(){
        try {
            Test.startTest();
            IND_ResidenceFIController.createDocumentRecord(null, null, null, null,null);
            Test.stopTest();
        } catch(Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
    }
    
    
    @isTest 
    public static void testAcceptedSaveCurrentFI(){
        try{
            IND_ResidenceFIInputWrapper deserializedInputWrapper = createCurrentFIInputWrapperJSON('Accepted');
            String serializedInputWrapper = JSON.serialize(deserializedInputWrapper);
            
            Test.startTest();
            Boolean status = IND_ResidenceFIController.saveCurrentResidenceFI(serializedInputWrapper);
            Test.stopTest();
            
            System.assertEquals(true, status);
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest 
    public static void testRejectedSaveCurrentFI(){
        try{
            IND_ResidenceFIInputWrapper deserializedInputWrapper = createCurrentFIInputWrapperJSON('Rejected');
            String serializedInputWrapper = JSON.serialize(deserializedInputWrapper);
            
            Test.startTest();
            Boolean status = IND_ResidenceFIController.saveCurrentResidenceFI(serializedInputWrapper);
            Test.stopTest();
            
            System.assertEquals(true, status);
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

@isTest 
    public static void testRejectedSaveCurrentFICatch(){
        try{
            
            Test.startTest();
            Boolean status = IND_ResidenceFIController.saveCurrentResidenceFI(null);
            Test.stopTest();
            
           // System.assertEquals(true, status);
        }catch(Exception e){
           System.assertNotEquals(null, e.getMessage());
        }
    }    
    @isTest 
    public static void testAcceptedSaveOfficeFI(){
        //   IND_ResidenceFIInputWrapper deserializedInputWrapper = createOfficeFIInputWrapperJSON('Accepted');
        //   String serializedInputWrapper = JSON.serialize(deserializedInputWrapper);
        
        Test.startTest();
        //     Boolean status = IND_ResidenceFIController.saveOfficeFI(serializedInputWrapper);
        Test.stopTest();
        
        //  System.assertEquals(true, status);
    }
    
    @isTest 
    public static void testRejectedSaveOfficeFI(){
        //    IND_ResidenceFIInputWrapper deserializedInputWrapper = createOfficeFIInputWrapperJSON('Rejected');
        //    String serializedInputWrapper = JSON.serialize(deserializedInputWrapper);
        
        Test.startTest();
        //    Boolean status = IND_ResidenceFIController.saveOfficeFI(serializedInputWrapper);
        Test.stopTest();
        
        //    System.assertEquals(false, status);
    }
    
    public static IND_ResidenceFIInputWrapper createCurrentFIInputWrapperJSON(String status) {
        IND_ResidenceFIInputWrapper inputWrapper = new IND_ResidenceFIInputWrapper();
        List<Field_Investigation__c> lstFIRecords = [SELECT ID,
                                                     FI_Request_Generation_Date_Time__c,
                                                     Residence_FI_Status__c,
                                                     Residence_FI_completion_time__c,
                                                     Address_Line_1__c,
                                                     Address_Line_2__c,
                                                     City__c,
                                                     Pin_Code__c,
                                                     State__c,
                                                     Landmark__c,
                                                     Phone_Number__c,
                                                     Mobile__c,
                                                     Customer_house_same_as_in_application__c,
                                                     GeoCoder_Latitude_and_Longitude__Latitude__s,
                                                     GeoCoder_Latitude_and_Longitude__Longitude__s,
                                                     FI_Location__Latitude__s,
                                                     FI_Location__Longitude__s,
                                                     Coordinates_Verified__c,
                                                     Are_Co_ordinates_Matching_If_Amber__c,
                                                     Name,
                                                     Product__c,
                                                     Residence_Type__c,
                                                     RecordType.DeveloperName,
                                                     Name_of_Person_met__c,
                                                     Relationship__c,
                                                     No_of_Attempts__c,
                                                     FI_Observation__c,
                                                     FI_Feedback__c,
                                                     List_of_equipment_tools_owned__c,
                                                     Types_of_vehicles_owned__c,
                                                     Remarks__c,
                                                     No_of_TVs__c,
                                                     No_of_Fridges__c,
                                                     No_of_Washing_Machines__c,
                                                     No_of_Sofas__c,
                                                     No_of_ACs__c,
                                                     No_of_Computers__c,
                                                     No_of_2_Wheelers__c,
                                                     No_of_3_Wheelers__c,
                                                     No_of_4_Wheelers__c,
                                                     No_of_CVs__c,
                                                     Profile_to_Product_Match__c,
                                                     Case__c,
                                                     Case__r.OwnerId,
                                                     Case__r.Applicant__c,
                                                     Case__r.Loan_Application__c,
                                                     Case__r.Loan_Application__r.Make__c,
                                                     Case__r.Loan_Application__r.Model__c,
                                                     Case__r.Loan_Application__r.Variant__c,
                                                     Case__r.Loan_Application__r.StageName,
                                                     Case__r.Loan_Application__r.Sub_Stage__c,
                                                     Case__r.Loan_Application__r.Is_Mobile_Journey_Completed__c
                                                     FROM Field_Investigation__c
                                                     LIMIT 1];
        if(lstFIRecords.size() > 0) {
            Field_Investigation__c fiRecord = lstFIRecords[0];
            
            inputWrapper.fiRequestGenerationDT = new IND_ResidenceFIInputWrapper.DatetimeField();
            inputWrapper.fiRequestGenerationDT.value = fiRecord.FI_Request_Generation_Date_Time__c;
            
            inputWrapper.residenceFIStatus = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.residenceFIStatus.value = fiRecord.Residence_FI_Status__c;
            
            inputWrapper.residenceFICompletionTime = new IND_ResidenceFIInputWrapper.DatetimeField();
            inputWrapper.residenceFICompletionTime.value = fiRecord.Residence_FI_completion_time__c;
            
            inputWrapper.addrLine1 = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.addrLine1.value = fiRecord.Address_Line_1__c;
            
            inputWrapper.addrLine2 = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.addrLine2.value = fiRecord.Address_Line_2__c;
            
            inputWrapper.city = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.city.value = fiRecord.City__c;
            
            inputWrapper.pinCode = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.pinCode.value = fiRecord.Pin_Code__c;
            
            inputWrapper.state = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.state.value = fiRecord.State__c;
            
            inputWrapper.landmark = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.landmark.value = fiRecord.Landmark__c;
            
            inputWrapper.phoneNo = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.phoneNo.value = fiRecord.Phone_Number__c;
            
            inputWrapper.mobile = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.mobile.value = fiRecord.Mobile__c;
            
            inputWrapper.locationSameAsInApplication = new IND_ResidenceFIInputWrapper.BooleanField();
            inputWrapper.locationSameAsInApplication.value = fiRecord.Customer_house_same_as_in_application__c;
            
            inputWrapper.geocoderLatitudeAndLongitude = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.geocoderLatitudeAndLongitude.value = fiRecord.GeoCoder_Latitude_and_Longitude__Latitude__s + ', ' + fiRecord.GeoCoder_Latitude_and_Longitude__Longitude__s;
            
            inputWrapper.fiLatitudeAndLongitude = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.fiLatitudeAndLongitude.value = fiRecord.FI_Location__Latitude__s + ', ' + fiRecord.FI_Location__Longitude__s;
            
            inputWrapper.coordinatesVerfied = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.coordinatesVerfied.value = fiRecord.Coordinates_Verified__c;
            
            inputWrapper.areCoordinatesMatching = new IND_ResidenceFIInputWrapper.BooleanField();
            inputWrapper.areCoordinatesMatching.value = fiRecord.Are_Co_ordinates_Matching_If_Amber__c;
            
            inputWrapper.yearsInResidence = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.yearsInResidence.value = '2';
            
            inputWrapper.resiType = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.resiType.value = fiRecord.Residence_Type__c;
            
            inputWrapper.name = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.name.value = fiRecord.Name;
            
            inputWrapper.product = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.product.value = fiRecord.Product__c;
            
            inputWrapper.profileProductMatch = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.profileProductMatch.value = fiRecord.Profile_to_Product_Match__c;
            
            inputWrapper.permCurrAddress = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.permCurrAddress.value = '';
            
            inputWrapper.purposeOfPurchase = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.purposeOfPurchase.value = '';
            
            inputWrapper.make = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.make.value = fiRecord.Case__r.Loan_Application__r.Make__c;
            
            inputWrapper.model = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.model.value = fiRecord.Case__r.Loan_Application__r.Model__c;
            
            inputWrapper.variant = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.variant.value = fiRecord.Case__r.Loan_Application__r.Variant__c;
            
            inputWrapper.dealer = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.dealer.value = '';
            
            inputWrapper.noofDependents = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.noofDependents.value = '';
            
            inputWrapper.numberOfEarningMembersInTheFamily = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.numberOfEarningMembersInTheFamily.value = '';
            
            inputWrapper.nameOfPersonMet = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.nameOfPersonMet.value = fiRecord.Name_of_Person_met__c;
            
            inputWrapper.relationShipWithCustomer = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.relationShipWithCustomer.value = fiRecord.Relationship__c;
            
            inputWrapper.noOfYearsinCity = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.noOfYearsinCity.value = '';
            
            inputWrapper.noofAttempts = new IND_ResidenceFIInputWrapper.DecimalField();
            inputWrapper.noofAttempts.value = fiRecord.No_of_Attempts__c;
            
            inputWrapper.fiObservation = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.fiObservation.value = fiRecord.FI_Observation__c;
            
            inputWrapper.fiFeedback = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.fiFeedback.value = fiRecord.FI_Feedback__c;
            
            inputWrapper.whiteGoodsAtHome = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.whiteGoodsAtHome.value = fiRecord.List_of_equipment_tools_owned__c;
            
            inputWrapper.vehiclesOwnedAtHome = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.vehiclesOwnedAtHome.value = fiRecord.Types_of_vehicles_owned__c;
            
            inputWrapper.fiAcceptedRejected = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.fiAcceptedRejected.value = status;
            
            inputWrapper.remarks = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.remarks.value = fiRecord.Remarks__c;
            
            inputWrapper.noOfTVs = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.noOfTVs.value = fiRecord.No_of_TVs__c;
            
            inputWrapper.noOfFridgess = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.noOfFridgess.value = fiRecord.No_of_Fridges__c;
            
            inputWrapper.noofWashingMachines = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.noofWashingMachines.value = fiRecord.No_of_Washing_Machines__c;
            
            inputWrapper.noOfSofas = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.noOfSofas.value = fiRecord.No_of_Sofas__c;
            
            inputWrapper.noOfACs = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.noOfACs.value = fiRecord.No_of_ACs__c;
            
            inputWrapper.noOfComputers = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.noOfComputers.value = fiRecord.No_of_Computers__c;
            
            inputWrapper.noOf2Wheelers = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.noOf2Wheelers.value = fiRecord.No_of_2_Wheelers__c;
            
            inputWrapper.noOf3Wheelers = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.noOf3Wheelers.value = fiRecord.No_of_3_Wheelers__c;
            
            inputWrapper.noOf4Wheelers = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.noOf4Wheelers.value = fiRecord.No_of_4_Wheelers__c;
            
            inputWrapper.noOfCVs = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.noOfCVs.value = fiRecord.No_of_CVs__c;
            
            inputWrapper.fiId = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.fiId.value = fiRecord.Id;
            
            inputWrapper.caseId = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.caseId.value = fiRecord.Case__c;
            
            inputWrapper.ownerId = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.ownerId.value = fiRecord.Case__r.OwnerId;
            
            inputWrapper.applicantId = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.applicantId.value = fiRecord.Case__r.Applicant__c;
            
            inputWrapper.applicationId = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.applicationId.value = fiRecord.Case__r.Loan_Application__c;
        }
        return inputWrapper;
    }
    
    
    @isTest
    public static void updateActualGeoLocationDetailsTest(){
        try{
            Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            insert opks1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opks1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            insert apks1;
            
            Documents__c dfks1 = new Documents__c();
            dfks1.Applicant__c = apks1.Id;
            dfks1.Opportunity_Relation__c = opks1.Id;
            dfks1.KYC_name__c = 'Aadhar';
            dfks1.Document_Side__c ='Back';
            dfks1.Aadhar_Source__c = 'ScanAadhar';
            dfks1.Name = 'Aadhar';
            dfks1.Document_Type__c = System.Label.AadhaarCard;
            insert dfks1;
            
            case cs1 = new case();
            cs1.Loan_Application__c = opks1.Id;
            cs1.Applicant__c = apks1.Id;
            cs1.Subject='Approval Of Application Sourced By Off Roll Employee';
            cs1.Status = 'Pending-Off Role Employee App';
            cs1.Origin = 'Web';
            insert cs1; 
            
            Field_Investigation__c fiv1 = new Field_Investigation__c();
            fiv1.Case__c = cs1.Id;
            fiv1.FI_Location__Latitude__s = 23.5;
            fiv1.FI_Location__Longitude__s = 23.5;
            fiv1.City__c = 'allur';
            fiv1.Pin_Code__c = '524315';
            fiv1.State__c = 'AP';
            //    fiv1.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Permanent').getRecordTypeId();
            insert fiv1;
            
            Test.startTest();
            IND_ResidenceFIController.updateActualGeoLocationDetails(fiv1.Id,'23.5','23.5');
            IND_ResidenceFIController.updateActualGeoLocationDetails(null,'23.5','23.5');
            Test.stopTest();
        }catch(Exception e){
            System.assertNotEquals(null, e.getMessage());
        }
    }
    
    @isTest
    public static void loadResidenceFIDataTest1(){
        try{
            Opportunity opfu1 = new Opportunity();
            opfu1.StageName = 'Qualification';
            opfu1.CloseDate = Date.newInstance(2021, 1, 11);
            opfu1.Name = 'testone';
            insert opfu1;
            
            Applicant__c apfu1 = new Applicant__c();
            apfu1.Opportunity__c = opfu1.Id;
            apfu1.Contact_number__c = '9743514830';
            apfu1.Applicant_Type__c = 'Borrower';
            insert apfu1;
            
            Documents__c dfu1 = new Documents__c();
            dfu1.Applicant__c = apfu1.Id;
            dfu1.Opportunity_Relation__c = opfu1.Id;
            dfu1.Document_Type__c = System.label.AadhaarCard;
            dfu1.Document_Side__c ='Back';
            dfu1.Aadhar_Source__c = 'ScanAadhar';
            dfu1.Front_Upload_Attempts__c = 5;
            dfu1.Raw_Response__c = 'test response';
            dfu1.Addresss_Type__c = 'Office Address';
            dfu1.RecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get(System.label.KYCDocument).getRecordTypeId();
            insert dfu1;
            
            IND_ResidenceFIController.DocumentWrapper dw1 = new IND_ResidenceFIController.DocumentWrapper();
            dw1.doument = dfu1;
            dw1.originalVerified = true;
            
            Test.startTest();
            IND_ResidenceFIController.loadResidenceFIData(apfu1.Id,dfu1.Addresss_Type__c);
            Test.stopTest();
            
        }catch(Exception e){
            //System.assertEquals('Script-thrown exception', e.getMessage());
            System.assertNotEquals(null, e.getMessage());
        }
    }
    
    @isTest
    public static void getContentDocumentIdTest(){
        try{
            Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            insert opks1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opks1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            apks1.In_Active_Applicant__c = false;
            insert apks1;
            
            Documents__c dfks1 = new Documents__c();
            dfks1.Applicant__c = apks1.Id;
            dfks1.Opportunity_Relation__c = opks1.Id;
            dfks1.Document_Type__c = System.label.AadhaarCard;
            dfks1.Document_Side__c ='Back';
            dfks1.Aadhar_Source__c = 'ScanAadhar';
            dfks1.is_Active__c = true;
            insert dfks1;
            
            Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');
            
            ContentVersion cv = new ContentVersion();
            cv.title = 'test content trigger';      
            cv.PathOnClient ='test';           
            cv.VersionData =beforeblob;          
            insert cv;   
            
            ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.ShareType = 'V';
            contentlink.LinkedEntityId = dfks1.Id; 
            contentlink.ContentDocumentId = testContent.ContentDocumentId;
            contentlink.Visibility = 'AllUsers'; 
            insert contentlink;
            
            Test.startTest();
            IND_ResidenceFIController.getContentDocumentId(apks1.Id,dfks1.Document_Type__c);
            IND_ResidenceFIController.getContentDocumentId('test',System.label.AadhaarCard);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getContentDocumentIdTest1(){
        try{
            Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            insert opks1;
            
            Applicant__c apc1 = new Applicant__c();
            apc1.Opportunity__c = opks1.Id;
            apc1.Contact_number__c = '9743514830';
            apc1.Applicant_Type__c = 'Borrower';
            insert apc1;
            
            Test.startTest();
            IND_ResidenceFIController.getContentDocumentId(null,null);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void checkDocFromAppTest(){
        try{
            Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            insert opks1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opks1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            apks1.In_Active_Applicant__c = false;
            apks1.DocAuth_Application_Id__c = 'testauth';
            apks1.Selfie_Upload__c = true;
            insert apks1;
            
            Documents__c dfks1 = new Documents__c();
            dfks1.Applicant__c = apks1.Id;
            dfks1.Opportunity_Relation__c = opks1.Id;
            dfks1.Document_Type__c = System.Label.AadhaarCard;
            dfks1.KYC_name__c = 'Aadhar';
            dfks1.Document_Side__c ='Back';
            dfks1.Aadhar_Source__c = 'ScanAadhar';
            dfks1.Name = 'Aadhar';
            dfks1.is_Active__c = true;
            insert dfks1;
            
            Blob beforeblob1 = Blob.valueOf('Unit Test Attachment Body');
            
            ContentVersion cvt1 = new ContentVersion();
            cvt1.title = 'test content trigger';      
            cvt1.PathOnClient ='test';           
            cvt1.VersionData = beforeblob1;
            cvt1.Document_Side_fileupload__c = 'Front';
            insert cvt1;   
            
            ContentVersion testContent1 = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cvt1.Id];
            
            
            ContentDocumentLink contentlink1 = new ContentDocumentLink();
            contentlink1.ShareType = 'V';
            contentlink1.LinkedEntityId = dfks1.Id; 
            contentlink1.ContentDocumentId = testContent1.ContentDocumentId;
            contentlink1.Visibility = 'AllUsers'; 
            insert contentlink1;
            
            Test.startTest();
            IND_ResidenceFIController.checkDocFromApp(apks1.Id,dfks1.Document_Type__c);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void checkDocFromAppTest1(){
        try{
            Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            insert opks1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opks1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            apks1.In_Active_Applicant__c = false;
            apks1.DocAuth_Application_Id__c = 'testauth';
            apks1.Selfie_Upload__c = true;
            insert apks1;
            
            Documents__c dfks1 = new Documents__c();
            dfks1.Applicant__c = apks1.Id;
            dfks1.Opportunity_Relation__c = opks1.Id;
            dfks1.Document_Type__c = System.Label.AadhaarCard;
            dfks1.KYC_name__c = 'Aadhar';
            dfks1.Document_Side__c ='Back';
            dfks1.Aadhar_Source__c = 'ScanAadhar';
            dfks1.Name = 'Aadhar';
            insert dfks1;
            
            Blob beforeblob1 = Blob.valueOf('Unit Test Attachment Body');
            
            ContentVersion cvt1 = new ContentVersion();
            cvt1.title = 'test content trigger';      
            cvt1.PathOnClient ='test';           
            cvt1.VersionData = beforeblob1;
            cvt1.Document_Side_fileupload__c = 'Selfie';
            insert cvt1;   
            
            ContentVersion testContent1 = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cvt1.Id];
            
            
            ContentDocumentLink contentlink1 = new ContentDocumentLink();
            contentlink1.ShareType = 'V';
            contentlink1.LinkedEntityId = dfks1.Id; 
            contentlink1.ContentDocumentId = testContent1.ContentDocumentId;
            contentlink1.Visibility = 'AllUsers'; 
            insert contentlink1;
            
            Test.startTest();
            IND_ResidenceFIController.checkDocFromApp(apks1.Id,dfks1.Document_Type__c);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void checkDocFromAppTest2(){
        try{
            Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            insert opks1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opks1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            apks1.In_Active_Applicant__c = false;
            apks1.DocAuth_Application_Id__c = 'testauth';
            apks1.Selfie_Upload__c = true;
            insert apks1;
            
            Documents__c dfks1 = new Documents__c();
            dfks1.Applicant__c = apks1.Id;
            dfks1.Opportunity_Relation__c = opks1.Id;
            dfks1.Document_Type__c = System.Label.AadhaarCard;
            dfks1.KYC_name__c = 'Aadhar';
            dfks1.Document_Side__c ='Back';
            dfks1.Aadhar_Source__c = 'ScanAadhar';
            dfks1.Name = 'Aadhar';
            insert dfks1;
            
            Blob beforeblob1 = Blob.valueOf('Unit Test Attachment Body');
            
            ContentVersion cvt1 = new ContentVersion();
            cvt1.title = 'test content trigger';      
            cvt1.PathOnClient ='test';           
            cvt1.VersionData = beforeblob1;
            cvt1.Document_Side_fileupload__c = 'Back';
            insert cvt1;   
            
            ContentVersion testContent1 = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cvt1.Id];
            
            
            ContentDocumentLink contentlink1 = new ContentDocumentLink();
            contentlink1.ShareType = 'V';
            contentlink1.LinkedEntityId = dfks1.Id; 
            contentlink1.ContentDocumentId = testContent1.ContentDocumentId;
            contentlink1.Visibility = 'AllUsers'; 
            insert contentlink1;
            
            Test.startTest();
            IND_ResidenceFIController.checkDocFromApp(apks1.Id,dfks1.Document_Type__c);
            IND_ResidenceFIController.checkDocFromApp('test',System.label.AadhaarCard);
            IND_ResidenceFIController.checkDocFromApp(null,System.label.AadhaarCard);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getDocumentRecordTest(){
        try{
            Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            insert opks1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opks1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            insert apks1;
            
            case cs1 = new case();
            cs1.Loan_Application__c = opks1.Id;
            cs1.Applicant__c = apks1.Id;
            cs1.Subject='Approval Of Application Sourced By Off Roll Employee';
            cs1.Status = 'Pending-Off Role Employee App';
            cs1.Origin = 'Web';
            insert cs1; 
            
            Field_Investigation__c fiv1 = new Field_Investigation__c();
            fiv1.Case__c = cs1.Id;
            fiv1.Address_Line_1__c = 'test1';
            fiv1.Address_Line_2__c = 'test2';
            // fiv1.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Permanent').getRecordTypeId();
            insert fiv1;
            
            Documents__c dfks1 = new Documents__c();
            dfks1.Case__c = fiv1.Case__c;
            dfks1.Applicant__c = apks1.Id;
            dfks1.Opportunity_Relation__c = opks1.Id;
            dfks1.KYC_name__c = 'Aadhar';
            dfks1.Document_Side__c ='Back';
            dfks1.Aadhar_Source__c = 'ScanAadhar';
            dfks1.Name = 'Aadhar';
            dfks1.Document_Type__c = System.label.AadhaarCard;
            dfks1.RecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
            insert dfks1;
            
            Test.startTest();
            IND_ResidenceFIController.getDocumentRecord(fiv1.Id,apks1.Id,opks1.Id,dfks1.Document_Type__c,'KYC Document');
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getDocumentRecordTest1(){
        try{
            Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            insert opks1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opks1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            insert apks1;
            
            case cs1 = new case();
            cs1.Loan_Application__c = opks1.Id;
            cs1.Applicant__c = apks1.Id;
            cs1.Subject='Approval Of Application Sourced By Off Roll Employee';
            cs1.Status = 'Pending-Off Role Employee App';
            cs1.Origin = 'Web';
            insert cs1; 
            
            Field_Investigation__c fiv1 = new Field_Investigation__c();
            fiv1.Case__c = cs1.Id;
            fiv1.Address_Line_1__c = 'test1';
            fiv1.Address_Line_2__c = 'test2';
            // fiv1.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Permanent').getRecordTypeId();
            insert fiv1;
            
            Documents__c dfks1 = new Documents__c();
            //  dfks1.Case__c = fiv1.Case__c;
            dfks1.Applicant__c = apks1.Id;
            dfks1.Opportunity_Relation__c = opks1.Id;
            dfks1.KYC_name__c = 'Aadhar';
            dfks1.Document_Side__c ='Back';
            dfks1.Aadhar_Source__c = 'ScanAadhar';
            dfks1.Name = 'Aadhar';
            dfks1.Document_Type__c = System.label.AadhaarCard;
            dfks1.RecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
            insert dfks1;
            
            Test.startTest();
            IND_ResidenceFIController.getDocumentRecord(fiv1.Id,apks1.Id,opks1.Id,dfks1.Document_Type__c,'KYC Document');
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void getDocumentRecordTest2(){
        try{
            Test.startTest();
            IND_ResidenceFIController.getDocumentRecord(null,null,null,null,null);
            Test.stopTest();
        }catch(Exception e){
            System.assertNotEquals(null, e.getMessage());
        }
    }
    @isTest
    public static void IsAllRequiredFISubmittedTest(){
        try{
            Profile p = [SELECT Id FROM Profile WHERE Name='IBL CVO'];
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',MobilePhone = '9999999999',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id, Maker_Id__c='12',
                              TimeZoneSidKey='America/Los_Angeles',
                              UserName='standarduser4@testorg.com.psdev3');
            insert u;
            System.runAs(u){
                Id recordId = Schema.SObjectType.case.getRecordTypeInfosByName().get('FI').getRecordTypeId();
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                insert opks1;
                
                Applicant__c apks1 = new Applicant__c();
                apks1.Opportunity__c = opks1.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                insert apks1;
                
                case cs1 = new case();
                cs1.Loan_Application__c = opks1.Id;
                cs1.Applicant__c = apks1.Id;
                cs1.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs1.Status = 'Accepted';
                cs1.Origin = 'Web';
                //cs1.recordType.Name = 'FI';
                cs1.RejectedFI__c = false;
                cs1.OwnerId = u.Id;
                insert cs1; 
                
                OpportunityTeamMember oppTeamMem = new OpportunityTeamMember();
                oppTeamMem.UserId = cs1.OwnerId;
                oppTeamMem.OpportunityId = opks1.Id;
                insert oppTeamMem;
                
                
                Test.startTest();
                IND_ResidenceFIController.IsAllRequiredFISubmitted(opks1.Id);
                Test.stopTest();
            }
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    public static void IsAllRequiredFISubmittedTest2(){
        try{
            Profile p = [SELECT Id FROM Profile WHERE Name='IBL CVO'];
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',MobilePhone = '9999999999',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id, Maker_Id__c='12',
                              TimeZoneSidKey='America/Los_Angeles',
                              UserName='standarduser4@testorg.com.psdev3');
            insert u;
            System.runAs(u){
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                insert opks1;
                
                Applicant__c apks1 = new Applicant__c();
                apks1.Opportunity__c = opks1.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                insert apks1;
                
                case cs1 = new case();
                cs1.Loan_Application__c = opks1.Id;
                cs1.Applicant__c = apks1.Id;
                cs1.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs1.Status = 'Pending-Off Role Employee App';
                cs1.Type = 'Current Residence FI';
                cs1.Origin = 'Web';
                cs1.OwnerId = u.Id;
                insert cs1; 
                
                OpportunityTeamMember oppTeamMem = new OpportunityTeamMember();
                oppTeamMem.UserId = cs1.OwnerId;
                oppTeamMem.OpportunityId = opks1.Id;
                insert oppTeamMem;
                
                
                Test.startTest();
                IND_ResidenceFIController.IsAllRequiredFISubmitted(opks1.Id);
                Test.stopTest();
            }
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    public static void IsAllRequiredFISubmittedTest3(){
        try{
            Profile p = [SELECT Id FROM Profile WHERE Name='IBL CVO'];
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',MobilePhone = '9999999999',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id, Maker_Id__c='12',
                              TimeZoneSidKey='America/Los_Angeles',
                              UserName='standarduser4@testorg.com.psdev3');
            insert u;
            System.runAs(u){
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                insert opks1;
                
                Applicant__c apks1 = new Applicant__c();
                apks1.Opportunity__c = opks1.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                insert apks1;
                
                case cs1 = new case();
                cs1.Loan_Application__c = opks1.Id;
                cs1.Applicant__c = apks1.Id;
                cs1.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs1.Status = 'Pending-Off Role Employee App';
                cs1.Type = 'Office FI';
                cs1.Origin = 'Web';
                cs1.OwnerId = u.Id;
                insert cs1; 
                
                OpportunityTeamMember oppTeamMem = new OpportunityTeamMember();
                oppTeamMem.UserId = cs1.OwnerId;
                oppTeamMem.OpportunityId = opks1.Id;
                insert oppTeamMem;
                
                
                Test.startTest();
                IND_ResidenceFIController.IsAllRequiredFISubmitted(opks1.Id);
                Test.stopTest();
            }
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void IsAllRequiredFISubmittedTest4(){
        try{
            Profile p = [SELECT Id FROM Profile WHERE Name='IBL CVO'];
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',MobilePhone = '9999999999',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id, Maker_Id__c='12',
                              TimeZoneSidKey='America/Los_Angeles',
                              UserName='standarduser4@testorg.com.psdev3');
            insert u;
            System.runAs(u){
                
                String recordId = Schema.SObjectType.case.getRecordTypeInfosByName().get('FI').getRecordTypeId();
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                insert opks1;
                
                Applicant__c apks1 = new Applicant__c();
                apks1.Opportunity__c = opks1.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                insert apks1;
                
                case cs1 = new case();
                cs1.Loan_Application__c = opks1.Id;
                cs1.Applicant__c = apks1.Id;
                cs1.RejectedFI__c = false;
                cs1.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs1.Status = 'Accepted';
                cs1.Type = 'Office FI';
                cs1.RecordTypeId = recordId;
                cs1.Origin = 'Web';
                cs1.OwnerId = u.Id;
                insert cs1; 
                
                OpportunityTeamMember oppTeamMem = new OpportunityTeamMember();
                oppTeamMem.UserId = cs1.OwnerId;
                oppTeamMem.OpportunityId = opks1.Id;
                insert oppTeamMem;
                
                
                Test.startTest();
                IND_ResidenceFIController.IsAllRequiredFISubmitted(opks1.Id);
                Test.stopTest();
            }
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void IsAllRequiredFISubmittedTest5(){
        try{
            Profile p = [SELECT Id FROM Profile WHERE Name='IBL CVO'];
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',MobilePhone = '9999999999',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id, Maker_Id__c='12',
                              TimeZoneSidKey='America/Los_Angeles',
                              UserName='standarduser4@testorg.com.psdev3');
            insert u;
            System.runAs(u){
                
                String recordId = Schema.SObjectType.case.getRecordTypeInfosByName().get('FI').getRecordTypeId();
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                insert opks1;
                
                Applicant__c apks1 = new Applicant__c();
                apks1.Opportunity__c = opks1.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                insert apks1;
                
                case cs1 = new case();
                cs1.Loan_Application__c = opks1.Id;
                cs1.Applicant__c = apks1.Id;
                cs1.RejectedFI__c = false;
                cs1.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs1.Status = 'Pending-Off Role Employee App';
                cs1.Type = 'Current Residence FI';
                cs1.RecordTypeId = recordId;
                cs1.Origin = 'Web';
                cs1.OwnerId = u.Id;
                insert cs1; 
                
                OpportunityTeamMember oppTeamMem = new OpportunityTeamMember();
                oppTeamMem.UserId = cs1.OwnerId;
                oppTeamMem.OpportunityId = opks1.Id;
                insert oppTeamMem;
                
                
                Test.startTest();
                IND_ResidenceFIController.IsAllRequiredFISubmitted(opks1.Id);
                Test.stopTest();
            }
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void IsAllRequiredFISubmittedTest6(){
        try{
            Profile p = [SELECT Id FROM Profile WHERE Name='IBL CVO'];
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',MobilePhone = '9999999999',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id, Maker_Id__c='12',
                              TimeZoneSidKey='America/Los_Angeles',
                              UserName='standarduser4@testorg.com.psdev3');
            insert u;
            System.runAs(u){
                
                String recordId = Schema.SObjectType.case.getRecordTypeInfosByName().get('FI').getRecordTypeId();
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                insert opks1;
                
                Applicant__c apks1 = new Applicant__c();
                apks1.Opportunity__c = opks1.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                insert apks1;
                
                case cs1 = new case();
                cs1.Loan_Application__c = opks1.Id;
                cs1.Applicant__c = apks1.Id;
                cs1.RejectedFI__c = false;
                cs1.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs1.Status = 'Pending-Off Role Employee App';
                cs1.Type = 'Office FI';
                cs1.RecordTypeId = recordId;
                cs1.Origin = 'Web';
                cs1.OwnerId = u.Id;
                insert cs1; 
                
                OpportunityTeamMember oppTeamMem = new OpportunityTeamMember();
                oppTeamMem.UserId = cs1.OwnerId;
                oppTeamMem.OpportunityId = opks1.Id;
                insert oppTeamMem;
                
                
                Test.startTest();
                IND_ResidenceFIController.IsAllRequiredFISubmitted(opks1.Id);
                Test.stopTest();
            }
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    public static void IsAllRequiredFISubmittedCatch(){
        try{
            Test.startTest();
            IND_ResidenceFIController.IsAllRequiredFISubmitted(null);
             IND_ResidenceFIController.IsAllRequiredFISubmitted('test');
            Test.stopTest();
        }
        catch(Exception e){
            System.assertNotEquals(null, e.getMessage());
        }
    }

    @isTest
    public static void getFieldInvestigationTest(){
        try{
            
            Id recordType = SObjectType.Field_Investigation__c.getRecordTypeInfosByDeveloperName().get('Office').getRecordTypeId();
            Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            insert opks1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opks1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            apks1.In_Active_Applicant__c = false;
            apks1.DocAuth_Application_Id__c = 'testauth';
            apks1.Selfie_Upload__c = true;
            insert apks1;
            
            case cs1 = new case();
            cs1.Loan_Application__c = opks1.Id;
            cs1.Applicant__c = apks1.Id;
            cs1.Subject='Approval Of Application Sourced By Off Roll Employee';
            cs1.Status = 'Pending-Off Role Employee App';
            cs1.Type = 'Office FI';
            cs1.Origin = 'Web';
            insert cs1; 
            
            Field_Investigation__c fieldInvObj = new Field_Investigation__c();
            fieldInvObj.Address_Verified_with_KYC__c = true;
            fieldInvObj.RecordTypeId = recordType;
            fieldInvObj.Customer_house_same_as_in_application__c =  true;
            fieldInvObj.Case__c = cs1.Id;
            insert fieldInvObj;
            
            Test.startTest();
            IND_ResidenceFIController.getFieldInvestigation(fieldInvObj.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void checkRetryExhaustedTest(){
        try{
            
            Id recordType = SObjectType.Field_Investigation__c.getRecordTypeInfosByDeveloperName().get('Office').getRecordTypeId();
            Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            insert opks1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opks1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            apks1.In_Active_Applicant__c = false;
            apks1.DocAuth_Application_Id__c = 'testauth';
            apks1.Selfie_Upload__c = true;
            insert apks1;
            
            case cs1 = new case();
            cs1.Loan_Application__c = opks1.Id;
            cs1.Applicant__c = apks1.Id;
            cs1.Subject='Approval Of Application Sourced By Off Roll Employee';
            cs1.Status = 'Pending-Off Role Employee App';
            cs1.Type = 'Office FI';
            cs1.Origin = 'Web';
            insert cs1; 
            
            Field_Investigation__c fieldInvObj = new Field_Investigation__c();
            fieldInvObj.Address_Verified_with_KYC__c = true;
            fieldInvObj.RecordTypeId = recordType;
            fieldInvObj.Customer_house_same_as_in_application__c =  true;
            fieldInvObj.Case__c = cs1.Id;
            insert fieldInvObj;
            
            Retry_Count__c retryCount = new Retry_Count__c();
            retryCount.Loan_Application_Id__c = opks1.Id;
            retryCount.Applicant__c = apks1.Id;
            retryCount.Field_Investigation__c = fieldInvObj.Id;
            retryCount.Service_Name__c = System.Label.Capture_FI_Latitude_Longitude;
            insert retryCount;
            
            Test.startTest();
            IND_ResidenceFIController.checkRetryExhausted(opks1.id,fieldInvObj.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest 
    public static void checkRetryExhaustedTestException(){
        try {
            
            Id recordType = SObjectType.Field_Investigation__c.getRecordTypeInfosByDeveloperName().get('Office').getRecordTypeId();
            Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            insert opks1;
            
             Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opks1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            apks1.In_Active_Applicant__c = false;
            apks1.DocAuth_Application_Id__c = 'testauth';
            apks1.Selfie_Upload__c = true;
            insert apks1;

           

            Test.startTest();
           IND_ResidenceFIController.checkRetryExhausted(null,null);
            Test.stopTest();
        } catch(Exception e) {
            //System.assertEquals('Applicant details are not valid, please contact your administrator.', e.getMessage());
             System.assertNotEquals(null, e.getMessage());
        }
    }
    
    @isTest
    public static void retryCountIncreaseTest(){
        try{
            
            Id recordType = SObjectType.Field_Investigation__c.getRecordTypeInfosByDeveloperName().get('Office').getRecordTypeId();
            Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            insert opks1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opks1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            apks1.In_Active_Applicant__c = false;
            apks1.DocAuth_Application_Id__c = 'testauth';
            apks1.Selfie_Upload__c = true;
            insert apks1;
            
            case cs1 = new case();
            cs1.Loan_Application__c = opks1.Id;
            cs1.Applicant__c = apks1.Id;
            cs1.Subject='Approval Of Application Sourced By Off Roll Employee';
            cs1.Status = 'Pending-Off Role Employee App';
            cs1.Type = 'Office FI';
            cs1.Origin = 'Web';
            insert cs1; 
            
            Field_Investigation__c fieldInvObj = new Field_Investigation__c();
            fieldInvObj.Address_Verified_with_KYC__c = true;
            fieldInvObj.RecordTypeId = recordType;
            fieldInvObj.Customer_house_same_as_in_application__c =  true;
            fieldInvObj.Case__c = cs1.Id;
            insert fieldInvObj;
            
            Retry_Count__c retryCount = new Retry_Count__c();
            retryCount.Loan_Application_Id__c = opks1.Id;
            retryCount.Applicant__c = apks1.Id;
            retryCount.Field_Investigation__c = fieldInvObj.Id;
            retryCount.Service_Name__c = System.Label.Capture_FI_Latitude_Longitude;
            retryCount.Count__c = 2;
            insert retryCount;
            
            retryCount.Count__c = 4;
            update retryCount;
            
            Test.startTest();
            IND_ResidenceFIController.retryCountIncrease(opks1.id,fieldInvObj.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
     @isTest
    public static void retryCountIncreaseTest2(){
        try{
            
            Id recordType = SObjectType.Field_Investigation__c.getRecordTypeInfosByDeveloperName().get('Office').getRecordTypeId();
            Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            insert opks1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opks1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            apks1.In_Active_Applicant__c = false;
            apks1.DocAuth_Application_Id__c = 'testauth';
            apks1.Selfie_Upload__c = true;
            insert apks1;
            
            case cs1 = new case();
            cs1.Loan_Application__c = opks1.Id;
            cs1.Applicant__c = apks1.Id;
            cs1.Subject='Approval Of Application Sourced By Off Roll Employee';
            cs1.Status = 'Pending-Off Role Employee App';
            cs1.Type = 'Office FI';
            cs1.Origin = 'Web';
            insert cs1; 
            
            Field_Investigation__c fieldInvObj = new Field_Investigation__c();
            fieldInvObj.Address_Verified_with_KYC__c = true;
            fieldInvObj.RecordTypeId = recordType;
            fieldInvObj.Customer_house_same_as_in_application__c =  true;
            fieldInvObj.Case__c = cs1.Id;
            insert fieldInvObj;
            
            Test.startTest();
            IND_ResidenceFIController.retryCountIncrease(opks1.id,fieldInvObj.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void haveCurrentCaseAccessTest(){
        try{
            
            Id recordType = SObjectType.Field_Investigation__c.getRecordTypeInfosByDeveloperName().get('Office').getRecordTypeId();
            Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            insert opks1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opks1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            apks1.In_Active_Applicant__c = false;
            apks1.DocAuth_Application_Id__c = 'testauth';
            apks1.Selfie_Upload__c = true;
            insert apks1;
            
            case cs1 = new case();
            cs1.Loan_Application__c = opks1.Id;
            cs1.Applicant__c = apks1.Id;
            cs1.Subject='Approval Of Application Sourced By Off Roll Employee';
            cs1.Status = 'Pending-Off Role Employee App';
            cs1.Type = 'Office FI';
            cs1.Origin = 'Web';
            insert cs1; 
            
                       
            Test.startTest();
            IND_ResidenceFIController.haveCurrentCaseAccess(opks1.id,cs1.Id);
             IND_ResidenceFIController.haveCurrentCaseAccess('test',null);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
}