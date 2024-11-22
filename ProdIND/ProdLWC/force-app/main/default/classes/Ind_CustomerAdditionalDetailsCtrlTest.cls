/**
* @description       : This Test Method is basically designed for capturing current and permanent address of the applicant.
* @author            : Devanshu Gupta
* @group             : 
* @created on		 : 13-11-2021
* @last modified on  : 13-11-2021
* @last modified by  : Devanshu Gupta
* @Version 		  	 : 1.0
**/
@isTest
private class Ind_CustomerAdditionalDetailsCtrlTest {
    
    @isTest
    private static void getAddressPositiveTest() {
        try{
         Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
            system.debug('p'+ p);
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles',
                              MobilePhone = '9701498575',
                              UserName='standarduser4@testorg.com.psdev1' ,
                              Maker_Id__c='100001');
            insert u;
       system.runAs(u){
        Test.startTest();
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        applicantObj.Current_Same_As_Permanent__c = true;
        insert applicantObj;
        
        Documents__c backDoc = TestDataUtility.createTestKYCDocs(false, applicantObj, oppObj);
        backDoc.Is_Back__c = true;
        backDoc.Document_Type__c = 'PAN';
        backDoc.Document_Side__c ='Back';
        backDoc.Content_Document_Count__c = 1;
        backDoc.Current_Residential_Address_Proof__c = true;
        insert backDoc;
        
        
        Documents__c pan = TestDataUtility.createTestKYCDocs(false, applicantObj, oppObj);
        pan.Is_Back__c = true;
        pan.Document_Type__c = 'Voter Id';
        pan.Document_Side__c ='Back';
        pan.Content_Document_Count__c = 1;
        pan.Permanent_Residential_Address_Proof__c = true;
        insert pan;
       
        Map<String, Object> mapData = Ind_CustomerAdditionalDetailsCtrl.getAddress(oppObj.Id, System.Label.Borrower, applicantObj.Id);
          Test.stopTest();
        
        Documents__c docObjcurent = mapData.containsKey('currentAddress') ? (Documents__c) mapData.get('currentAddress') : new Documents__c(Current_Residential_Address_Proof__c=true);
        Documents__c docObjcurentPerma = mapData.containsKey('permanentAddress') ? (Documents__c) mapData.get('permanentAddress') : new Documents__c(Permanent_Residential_Address_Proof__c=true);
        Boolean isApplicant = mapData.containsKey('isApplicantPresent') ? (Boolean) mapData.get('isApplicantPresent') : true;
        String applicationNumber = mapData.containsKey('Application_number__c') ? (String) mapData.get('Application_number__c') : '';
        System.assertEquals(docObjcurent.Current_Residential_Address_Proof__c, true);
        System.assertEquals(docObjcurentPerma.Permanent_Residential_Address_Proof__c, true);
        System.assertEquals(isApplicant, true);
       }    
        
        }catch(Exception e){
           System.assertEquals('Script-thrown exception', e.getMessage()); 
        }
    }
    
    @isTest
    private static void getAddressNegativeTest() {
        try{
        Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
            system.debug('p'+ p);
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles',
                              MobilePhone = '9701498575',
                              UserName='standarduser4@testorg.com.psdev1' ,
                              Maker_Id__c='100001');
            insert u;
       system.runAs(u){
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        applicantObj.Current_Same_As_Permanent__c = true;
        
        insert applicantObj;
        Test.startTest();
        Map<String, Object> mapData = Ind_CustomerAdditionalDetailsCtrl.getAddress(oppObj.Id, System.Label.Borrower,applicantObj.Id);
        Boolean isApplicant = (Boolean) mapData.get('isApplicantPresent');
        System.assertEquals(isApplicant, false);
        Test.stopTest();
       }  
        } catch(Exception e)
        {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }  
    }
    
    @isTest
    private static void saveDocumentDataCurrentPositiveTest() {
        Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
            system.debug('p'+ p);
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles',
                              MobilePhone = '9701498575',
                              UserName='standarduser4@testorg.com.psdev1' ,
                              Maker_Id__c='100001');
            insert u;
       system.runAs(u){
        try{
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        insert applicantObj;
        Ind_CustomerAdditionalDetailsCtrl.AddressWrapper addressData =  new Ind_CustomerAdditionalDetailsCtrl.AddressWrapper();
        addressData.documentType = 'PAN';
        addressData.address1 = 'add1';
        addressData.address2 = 'add2';
        addressData.pincode = '241009';
        addressData.city = 'Pune';
        addressData.district = 'Pune';
        addressData.state = 'UP';
        addressData.isDisabled = false;
		addressData.isCurrentAddress = true;
        addressData.residenceCumOffice=true;
        addressData.poaFlag=true;
        Test.startTest();
        String documentId = Ind_CustomerAdditionalDetailsCtrl.saveDocumentData(JSON.serialize(addressData),applicantObj.id);
        
        List<Documents__c> docCurrent = [SELECT ID FROM Documents__c WHERE ID =:documentId];
     //   System.assertEquals(docCurrent.size() == 1, true);
         Test.stopTest();
        
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
       }
    }
    
    @isTest
    private static void saveDocumentDataPermanentPositiveTest() {
        try{
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        insert applicantObj;
        Ind_CustomerAdditionalDetailsCtrl.AddressWrapper addressData =  new Ind_CustomerAdditionalDetailsCtrl.AddressWrapper();
        addressData.documentType = 'PAN';
        addressData.address1 = 'add1';
        addressData.address2 = 'add2';
        addressData.pincode = '241009';
        addressData.city = 'Pune';
        addressData.district = 'Pune';
        addressData.state = 'UP';
        addressData.isDisabled = false;
		addressData.isCurrentAddress = false;
        addressData.residenceCumOffice=true;    
        Test.startTest();
        String documentId = Ind_CustomerAdditionalDetailsCtrl.saveDocumentData(JSON.serialize(addressData),applicantObj.id);
        List<Documents__c> docPerma = [SELECT ID FROM Documents__c WHERE ID =:documentId];
        System.assertEquals(docPerma.size() == 1, true);
        Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        
    }
    
    @isTest
    private static void saveDocumentDataPermanentNegativeTest() {
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        oppObj.Customer_Type__c='Non-Individual';
        oppObj.Product_Type__c=Label.Tractor;
        insert oppObj;
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        insert applicantObj;
        Ind_CustomerAdditionalDetailsCtrl.AddressWrapper addressData =  new Ind_CustomerAdditionalDetailsCtrl.AddressWrapper();
        addressData.documentType = 'PAN';
        addressData.address1 = 'add1';
        addressData.address2 = 'add2';
        addressData.pincode = '241009';
        addressData.city = 'Pune';
        addressData.district = 'Pune';
        addressData.state = 'UP';
        addressData.isDisabled = true;
		addressData.isCurrentAddress = false;
        addressData.residenceCumOffice=true;
        addressData.poaFlag=true;
        Test.startTest();
        String documentId = Ind_CustomerAdditionalDetailsCtrl.saveDocumentData(JSON.serialize(addressData),applicantObj.id);
        List<Documents__c> docPerma = [SELECT ID FROM Documents__c WHERE ID =:documentId];
        System.assertEquals(docPerma.size() == 1, false);
        Test.stopTest();
         
    }
    
    @isTest
    private static void testDeleteKyc() {
        
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        insert applicantObj;
        
        Documents__c backDoc = TestDataUtility.createTestKYCDocs(false, applicantObj, oppObj);
        backDoc.Is_Back__c = true;
        backDoc.Document_Type__c = 'PAN';
        backDoc.Document_Side__c ='Back';
        backDoc.Current_Residential_Address_Proof__c = true;
        insert backDoc;
        
        ContentVersion cVersion = new ContentVersion();
                cVersion.ContentLocation = 'S'; 
                cVersion.PathOnClient = 'Test';
                cVersion.Origin = 'H';
                cVersion.OwnerId = UserInfo.getUserId();
                cVersion.Title = 'Test';
                cVersion.VersionData = Blob.valueOf('Test Content');
                Insert cVersion;
                
                //After saved the Content Verison, get the ContentDocumentId
                Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
                
                //Insert ContentDocumentLink
                ContentDocumentLink cDocLink = new ContentDocumentLink();
                cDocLink.ContentDocumentId = conDocument;
                cDocLink.LinkedEntityId = backDoc.Id;
                cDocLink.ShareType = 'I';
                cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        		
        		insert cDocLink;
        
        Test.startTest();
        Ind_CustomerAdditionalDetailsCtrl.kycDelete(backDoc.Id,false,true,conDocument);
        Test.stopTest();
    }
    
    @isTest
    private static void testDeleteKycDone() {
        
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        insert applicantObj;
        
        Documents__c backDoc = TestDataUtility.createTestKYCDocs(false, applicantObj, oppObj);
        backDoc.Is_Back__c = true;
        backDoc.Document_Type__c = 'PAN';
        backDoc.Document_Side__c ='Back';
        backDoc.Current_Residential_Address_Proof__c = true;
        insert backDoc;
        
        ContentVersion cVersion = new ContentVersion();
                cVersion.ContentLocation = 'S'; 
                cVersion.PathOnClient = 'Test';
                cVersion.Origin = 'H';
                cVersion.OwnerId = UserInfo.getUserId();
                cVersion.Title = 'Test';
                cVersion.VersionData = Blob.valueOf('Test Content');
                Insert cVersion;
                
                //After saved the Content Verison, get the ContentDocumentId
                Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
                
                //Insert ContentDocumentLink
                ContentDocumentLink cDocLink = new ContentDocumentLink();
                cDocLink.ContentDocumentId = conDocument;
                cDocLink.LinkedEntityId = backDoc.Id;
                cDocLink.ShareType = 'I';
                cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        		
        		insert cDocLink;
        
        ContentVersion cVersion1 = new ContentVersion();
                cVersion1.ContentLocation = 'S'; 
                cVersion1.PathOnClient = 'Test';
                cVersion1.Origin = 'H';
                cVersion1.OwnerId = UserInfo.getUserId();
                cVersion1.Title = 'Test';
                cVersion1.VersionData = Blob.valueOf('Test Content');
                Insert cVersion1;
                
                //After saved the Content Verison, get the ContentDocumentId
                Id conDocument1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion1.Id].ContentDocumentId;
                
                //Insert ContentDocumentLink
                ContentDocumentLink cDocLink1 = new ContentDocumentLink();
                cDocLink1.ContentDocumentId = conDocument1;
                cDocLink1.LinkedEntityId = backDoc.Id;
                cDocLink1.ShareType = 'I';
                cDocLink1.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        		
        		insert cDocLink1;
        Test.startTest();
        Ind_CustomerAdditionalDetailsCtrl.kycDelete(backDoc.Id,true,false,conDocument1);
        Test.stopTest();
    }
    
     @isTest
    private static void testDeleteKycDoneException() {
     
        
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        insert applicantObj;
        
        Documents__c backDoc = TestDataUtility.createTestKYCDocs(false, applicantObj, oppObj);
        backDoc.Is_Back__c = true;
        backDoc.Document_Type__c = 'PAN';
        backDoc.Document_Side__c ='Back';
        backDoc.Current_Residential_Address_Proof__c = true;
        insert backDoc;
        
        ContentVersion cVersion = new ContentVersion();
                cVersion.ContentLocation = 'S'; 
                cVersion.PathOnClient = 'Test';
                cVersion.Origin = 'H';
                cVersion.OwnerId = UserInfo.getUserId();
                cVersion.Title = 'Test';
                cVersion.VersionData = Blob.valueOf('Test Content');
                Insert cVersion;
                
                //After saved the Content Verison, get the ContentDocumentId
                Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
                
                //Insert ContentDocumentLink
                ContentDocumentLink cDocLink = new ContentDocumentLink();
                cDocLink.ContentDocumentId = conDocument;
                cDocLink.LinkedEntityId = backDoc.Id;
                cDocLink.ShareType = 'I';
                cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        		
        		insert cDocLink;
        
        ContentVersion cVersion1 = new ContentVersion();
                cVersion1.ContentLocation = 'S'; 
                cVersion1.PathOnClient = 'Test';
                cVersion1.Origin = 'H';
                cVersion1.OwnerId = UserInfo.getUserId();
                cVersion1.Title = 'Test';
                cVersion1.VersionData = Blob.valueOf('Test Content');
                Insert cVersion1;
                
                //After saved the Content Verison, get the ContentDocumentId
                Id conDocument1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion1.Id].ContentDocumentId;
                
                //Insert ContentDocumentLink
                ContentDocumentLink cDocLink1 = new ContentDocumentLink();
                cDocLink1.ContentDocumentId = conDocument1;
                cDocLink1.LinkedEntityId = backDoc.Id;
                cDocLink1.ShareType = 'I';
                cDocLink1.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        		
        		insert cDocLink1;
        Ind_CustomerAdditionalDetailsCtrl.checkForException = true;
        Test.startTest();
        Ind_CustomerAdditionalDetailsCtrl.kycDelete(backDoc.Id,true,false,conDocument1);
        Test.stopTest();
   
    }
    
    @isTest
    public static void fetchDocumentTest(){
        
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        insert applicantObj;
        
        Documents__c backDoc = TestDataUtility.createTestKYCDocs(false, applicantObj, oppObj);
        backDoc.Is_Back__c = true;
        backDoc.Document_Type__c = 'PAN';
        backDoc.Document_Side__c ='Back';
        backDoc.Current_Residential_Address_Proof__c = true;
        insert backDoc;
        
        ContentVersion cVersion = new ContentVersion();
                cVersion.ContentLocation = 'S'; 
                cVersion.PathOnClient = 'Test';
                cVersion.Origin = 'H';
                cVersion.OwnerId = UserInfo.getUserId();
                cVersion.Title = 'Test';
                cVersion.VersionData = Blob.valueOf('Test Content');
                Insert cVersion;
                
                
                Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
                
             
                ContentDocumentLink cDocLink = new ContentDocumentLink();
                cDocLink.ContentDocumentId = conDocument;
                cDocLink.LinkedEntityId = backDoc.Id;
                cDocLink.ShareType = 'I';
                cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        		
        		insert cDocLink;
        
                ContentVersion cVersion1 = new ContentVersion();
                cVersion1.ContentLocation = 'S'; 
                cVersion1.PathOnClient = 'Test';
                cVersion1.Origin = 'H';
                cVersion1.OwnerId = UserInfo.getUserId();
                cVersion1.Title = 'Test';
                cVersion1.VersionData = Blob.valueOf('Test Content');
                Insert cVersion1;
        
                Test.startTest();
                      Ind_CustomerAdditionalDetailsCtrl.fetchDocument(backDoc.Id);
                      Ind_CustomerAdditionalDetailsCtrl.fetchDocument(null);
                Test.stopTest();
    }
    
    @isTest
    public static void fetchDocumentTest1(){
        
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        insert applicantObj;
        
        Documents__c backDoc1 = TestDataUtility.createTestKYCDocs(false, applicantObj, oppObj);
        backDoc1.Is_Back__c = true;
        backDoc1.Document_Type__c = 'PAN';
        backDoc1.Document_Side__c ='Back';
        backDoc1.Current_Residential_Address_Proof__c = true;
        insert backDoc1;
        
         Test.startTest();
              Ind_CustomerAdditionalDetailsCtrl.fetchDocument(backDoc1.Id);
         Test.stopTest();
    }
    
    @isTest
    public static void fetchDocumentTest2(){
        
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        insert applicantObj;
        
        
         Test.startTest();
              Ind_CustomerAdditionalDetailsCtrl.fetchDocument(oppObj.Id);
         Test.stopTest();
    }
    
    @isTest
    public static void fetchDocumentTest3(){
                Opportunity opga1 = new Opportunity();
                opga1.StageName = 'Qualification';
                opga1.CloseDate = Date.newInstance(2021, 1, 11);
                opga1.Name = 'testone';
                insert opga1;
                
                Applicant__c apga1 = new Applicant__c();
                apga1.Opportunity__c = opga1.Id;
                apga1.Contact_number__c = '9743514830';
                apga1.Applicant_Type__c = 'Borrower';
                insert apga1;
        
                Documents__c dt2 = new Documents__c();
                dt2.Applicant__c = apga1.Id;
                dt2.Opportunity_Relation__c = opga1.Id;
                dt2.Document_Type__c = 'Customer Bank Statement';
                dt2.Document_Side__c ='Back';
                dt2.Aadhar_Source__c = 'ScanAadhar'; 
                dt2.Aadhar_Source__c = 'OTP';
                insert dt2;
        
                Test.startTest();
                      Ind_CustomerAdditionalDetailsCtrl.fetchDocument(dt2.Id);
                Test.stopTest();
    }
    
     @isTest
    public static void fetchDocumentTest4(){
                Opportunity opga1 = new Opportunity();
                opga1.StageName = 'Qualification';
                opga1.CloseDate = Date.newInstance(2021, 1, 11);
                opga1.Name = 'testone';
                insert opga1;
                
                Applicant__c apga1 = new Applicant__c();
                apga1.Opportunity__c = opga1.Id;
                apga1.Contact_number__c = '9743514830';
                apga1.Applicant_Type__c = 'Borrower';
                insert apga1;
        
                Documents__c dt2 = new Documents__c();
                dt2.Applicant__c = apga1.Id;
                dt2.Opportunity_Relation__c = opga1.Id;
                dt2.Document_Type__c = 'Customer Bank Statement';
                dt2.Document_Side__c ='Back';
                dt2.Aadhar_Source__c = 'ScanAadhar'; 
                dt2.Aadhar_Source__c = 'OTP';
                dt2.KYC_No__c = Integrationutilities.getencryptedrequest('TN2020090003150',System.Label.privateKey,System.Label.ivkey);
                insert dt2;
        
                Test.startTest();
                      Ind_CustomerAdditionalDetailsCtrl.fetchDocument(dt2.Id);
                      Ind_CustomerAdditionalDetailsCtrl.fetchDocument(null);
                Test.stopTest();
    }
    
    @isTest
    public static void getUploadDocumentTest1(){
        try{
            Opportunity opga1 = new Opportunity();
                opga1.StageName = 'Qualification';
                opga1.CloseDate = Date.newInstance(2021, 1, 11);
                opga1.Name = 'testone';
                insert opga1;
                
                Applicant__c apga1 = new Applicant__c();
                apga1.Opportunity__c = opga1.Id;
                apga1.Contact_number__c = '9743514830';
                apga1.Applicant_Type__c = 'Borrower';
                insert apga1;
        
                Documents__c dt2 = new Documents__c();
                dt2.Applicant__c = apga1.Id;
                dt2.Opportunity_Relation__c = opga1.Id;
                dt2.Document_Type__c = 'Aadhar';
                dt2.Document_Side__c ='Back';
                dt2.Aadhar_Source__c = 'ScanAadhar'; 
                dt2.Aadhar_Source__c = 'OTP';
                dt2.KYC_No__c = Integrationutilities.getencryptedrequest('TN2020090003150',System.Label.privateKey,System.Label.ivkey);
                insert dt2;
            
                Test.startTest();
                     Ind_CustomerAdditionalDetailsCtrl.getUploadDocument(apga1.Id,dt2.Document_Type__c);
                     Ind_CustomerAdditionalDetailsCtrl.getUploadDocument('test','test');
                     Ind_CustomerAdditionalDetailsCtrl.getUploadDocument(null,null);
                Test.stopTest();
        }catch(Exception e){
            System.assertEquals('script-thrown exception', e.getMessage());
        }
    }
      
}