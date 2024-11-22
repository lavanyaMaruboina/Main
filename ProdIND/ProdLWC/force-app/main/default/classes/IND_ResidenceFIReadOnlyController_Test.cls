/**
* @Name         IND_ResidenceFIReadOnlyController_Test
* @Author       mohammad_shahkomeni
* @Company      Persistent Systems
* @Description  This test class used to test IND_ResidenceFIReadOnlyController
* Inputs:       None
* Test Class:   None
* History:      
* Date            Author              Comments
* -------------------------------------------------------------
* 02-20-2022      mohammad_shahkomeni      Created
* ------------------------------------------------------------
*/
@isTest(seeAllData = false)
public class IND_ResidenceFIReadOnlyController_Test {
    
    @testSetup static void testDataSetup() {
        // Create Opportunity
        Opportunity opp = TestDataUtility.createTestOpportunityForOcr(false);
        opp.StageName = System.Label.Credit_Processing;
        opp.Sub_Stage__c = System.Label.Field_Investigation;
        opp.Is_Mobile_Journey_Completed__c = true;
        opp.Vehicle_Type__c = System.Label.used;
        opp.Product_Type__c = System.Label.TwoWheeler;
        opp.Sanction_Status__c = System.Label.nonStp;
        insert opp;
        // Create Applicant__c
        Applicant__c applicant = TestDataUtility.createTestApplicantForMFCValuation(true, opp);
        // Create Vehicle Detail
        Vehicle_Detail__c vehDet = TestDataUtility.createTestVehicleDetailForMFCValuation(true, opp);
        // Create Documents__c
        Documents__c doc1 = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant, opp);
        doc1.Document_Type__c = System.Label.Signature;
        doc1.Addresss_Type__c = System.Label.Document_Current_Residential_Address_Type;
        insert doc1;
        Documents__c doc2 = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant, opp);
        doc2.Document_Type__c = System.Label.Residence_Front_View;
        doc2.Addresss_Type__c = System.Label.Document_Current_Residential_Address_Type;
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
        try{
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Applicant__c apl = [SELECT Id FROM Applicant__c LIMIT 1];
        
        Test.startTest();
        Map<String, Id> mapDocTypetoId = IND_ResidenceFIReadOnlyController.getDocumentsOfFI(opp.Id, apl.Id, System.Label.Document_Current_Residential_Address_Type);
        IND_ResidenceFIReadOnlyController.getDocumentsOfFI('test', apl.Id, System.Label.Document_Current_Residential_Address_Type);
        Test.stopTest();
        
        System.assertEquals(2, mapDocTypetoId.size());
        }
        catch(Exception e){
            System.debug('Script-thrown exception'+ e.getMessage());
        }
    }
    
    @isTest 
    public static void testGetVehicleDetailsOfFI(){
        try{
            Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
            
            Test.startTest();
            // Vehicle_Detail__c vehicleDetails = IND_ResidenceFIReadOnlyController.getVehicleDetailsOfFI(opp.Id);
            Test.stopTest();
        }
        catch(Exception e){
            System.debug('Script-thrown exception'+ e.getMessage());
        }
        
        //   System.assertNotEquals(null, vehicleDetails);
    }
    
    @isTest 
    public static void testAcceptedSaveCurrentFI(){
        try{
        IND_ResidenceFIInputWrapper deserializedInputWrapper = createCurrentFIInputWrapperJSON(System.Label.FI_Accepted);
        String serializedInputWrapper = JSON.serialize(deserializedInputWrapper);
        
        Test.startTest();
        Boolean status = IND_ResidenceFIReadOnlyController.saveCurrentFI(serializedInputWrapper);
        Test.stopTest();
        
        System.assertEquals(true, status);
            }
        catch(Exception e){
            System.debug('Script-thrown exception'+ e.getMessage());
        }
    }
    
    @isTest 
    public static void testRejectedSaveCurrentFI(){
        try{
        IND_ResidenceFIInputWrapper deserializedInputWrapper = createCurrentFIInputWrapperJSON(System.Label.FI_Rejected);
        String serializedInputWrapper = JSON.serialize(deserializedInputWrapper);
        
        Test.startTest();
        Boolean status = IND_ResidenceFIReadOnlyController.saveCurrentFI(serializedInputWrapper);
        Test.stopTest();
        
        System.assertEquals(false, status);
        }
        catch(Exception e){
            System.debug('Script-thrown exception'+ e.getMessage());
        }
    } 
    
    public static IND_ResidenceFIInputWrapper createCurrentFIInputWrapperJSON(String status) {
        IND_ResidenceFIInputWrapper inputWrapper = new IND_ResidenceFIInputWrapper();
        List<Field_Investigation__c> lstFIRecords = [SELECT ID,
                                                     Address_Line_1__c,
                                                     Address_Line_2__c,
                                                     City__c,
                                                     Pin_Code__c,
                                                     State__c,
                                                     Landmark__c,
                                                     Phone_Number__c,
                                                     Mobile__c,
                                                     Product__c,
                                                     Are_Co_ordinates_Matching_If_Amber__c,
                                                     Remarks__c,
                                                     Case__c,
                                                     Case__r.OwnerId,
                                                     Case__r.Origin,
                                                     Case__r.Type,
                                                     Case__r.Subject,
                                                     Case__r.Applicant__c,
                                                     Case__r.Loan_Application__c
                                                     FROM Field_Investigation__c
                                                     LIMIT 1];
        if(lstFIRecords.size() > 0) {
            Field_Investigation__c fiRecord = lstFIRecords[0];
            
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
            
            inputWrapper.product = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.product.value = fiRecord.Product__c;
            
            inputWrapper.fiId = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.fiId.value = fiRecord.Id;
            
            inputWrapper.caseId = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.caseId.value = fiRecord.Case__c;
            
            inputWrapper.ownerId = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.ownerId.value = fiRecord.Case__r.OwnerId;
            
            inputWrapper.caseId = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.caseId.value = fiRecord.Case__c;
            
            inputWrapper.Origin = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.Origin.value = fiRecord.Case__r.Origin;
            
            inputWrapper.Type = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.Type.value = fiRecord.Case__r.Type;
            
            inputWrapper.Subject = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.Subject.value = fiRecord.Case__r.Subject;
            
            inputWrapper.applicantId = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.applicantId.value = fiRecord.Case__r.Applicant__c;
            
            inputWrapper.applicationId = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.applicationId.value = fiRecord.Case__r.Loan_Application__c;
            
            inputWrapper.applicationId = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.applicationId.value = fiRecord.Case__r.Loan_Application__c;
            
            inputWrapper.Are_Co_ordinates_Matching_If_Amber = new IND_ResidenceFIInputWrapper.BooleanField();
            inputWrapper.Are_Co_ordinates_Matching_If_Amber.value = true;
            
            inputWrapper.Remarks = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.Remarks.value = 'Test Remarks';
            
            inputWrapper.Residence_FI_Accepted_Rejected = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.Residence_FI_Accepted_Rejected.value = status;
            
            inputWrapper.documentAddressType = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.documentAddressType.value = System.Label.Document_Current_Residential_Address_Type;
        }
        return inputWrapper;
           
 
    }
    
    @isTest
    public static void getVehicleDetailsOfFITest(){
        try{
                Opportunity opgv2 = new Opportunity();
                opgv2.StageName = 'Qualification';
                opgv2.CloseDate = Date.newInstance(2021, 1, 11);
                opgv2.Name = 'testone';
                insert opgv2;
                
                Applicant__c apgv2 = new Applicant__c();
                apgv2.Opportunity__c = opgv2.Id;
                apgv2.Contact_number__c = '9743514830';
                apgv2.Applicant_Type__c = 'Borrower';
                insert apgv2;
              
                 Vehicle_Detail__c vg2 = new Vehicle_Detail__c();
                 vg2.Loan_Application__c = opgv2.Id;
                 vg2.Base_Price__c = 100000.00;
                 vg2.Ben_Code__c = 'testveh';
                 insert vg2; 
            
                 Test.startTest();
                       IND_ResidenceFIReadOnlyController.getVehicleDetailsOfFI(opgv2.Id);
                 Test.stopTest();
            
        }catch(Exception e){
            system.assertEquals('Script-thrown Exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getVehicleDetailsOfFITest1(){
        try{
                Opportunity opgv3 = new Opportunity();
                opgv3.StageName = 'Qualification';
                opgv3.CloseDate = Date.newInstance(2021, 1, 11);
                opgv3.Name = 'testone';
                insert opgv3;
                
                
                 Test.startTest();
                       IND_ResidenceFIReadOnlyController.getVehicleDetailsOfFI(opgv3.Id);
                 Test.stopTest();
            
        }catch(Exception e){
           // system.assertEquals('Script-thrown Exception', e.getMessage());
        }
    }
    
    @isTest
    public static void generateCurrentResidenceFIPDFTest(){
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
             //    dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 dfks1.Proof_of_Identity_POI__c = true;
                 dfks1.Document_Type__c = System.Label.Document_Residence_FI_Type;
                 dfks1.Addresss_Type__c = System.Label.Document_Current_Residential_Address_Type;
                 dfks1.RecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByDeveloperName().get(System.Label.Document_Other_Documents_Record_Type).getRecordTypeId();
                 insert dfks1;
                
                 ContentVersion cvn1 = new ContentVersion();
                 cvn1.PathOnClient = 'testpath1';
                 cvn1.Title = 'testtitle1';
                 cvn1.VersionData = Blob.valueOf('Test Content');
                 cvn1.Document_Side_fileupload__c = 'Front';
                 insert cvn1;
                
                 ContentVersion testcd1 = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cvn1.Id];
                
                 ContentDocumentLink cdlink1 = new ContentDocumentLink();
                 cdlink1.Visibility = 'AllUsers';
                 cdlink1.ShareType = 'V';
                 cdlink1.LinkedEntityId = dfks1.Id;
                 cdlink1.ContentDocumentId = testcd1.ContentDocumentId;
                 insert cdlink1; 
            
                 Test.startTest();
                       IND_ResidenceFIReadOnlyController.generateCurrentResidenceFIPDF(opks1.Id,opks1.Id,apks1.Id,dfks1.Addresss_Type__c);
                 Test.stopTest();
        }catch(Exception e){
            // system.assertEquals('Script-thrown Exception', e.getMessage());
        }
    } 
    
     @isTest
    public static void generateCurrentResidenceFIPDFTest1(){
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
             //    dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 dfks1.Proof_of_Identity_POI__c = true;
                 dfks1.Document_Type__c = System.Label.Document_Residence_FI_Type;
                 dfks1.Addresss_Type__c = System.Label.Document_Permanent_Residential_Address_Type;
                 dfks1.RecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByDeveloperName().get(System.Label.Document_Other_Documents_Record_Type).getRecordTypeId();
                 insert dfks1;
                
                 ContentVersion cvn1 = new ContentVersion();
                 cvn1.PathOnClient = 'testpath1';
                 cvn1.Title = 'testtitle1';
                 cvn1.VersionData = Blob.valueOf('Test Content');
                 cvn1.Document_Side_fileupload__c = 'Front';
                 insert cvn1;
                
                 ContentVersion testcd1 = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cvn1.Id];
                
                 ContentDocumentLink cdlink1 = new ContentDocumentLink();
               //  cdlink1.Visibility = 'AllUsers';
                 cdlink1.ShareType = 'V';
                 cdlink1.LinkedEntityId = dfks1.Id;
                 cdlink1.ContentDocumentId = testcd1.ContentDocumentId;
                 insert cdlink1; 
            
                 Test.startTest();
                       IND_ResidenceFIReadOnlyController.generateCurrentResidenceFIPDF(opks1.Id,opks1.Id,apks1.Id,dfks1.Addresss_Type__c);
                 Test.stopTest();
        }catch(Exception e){
            // system.assertEquals('Script-thrown Exception', e.getMessage());
        }
    } 
}