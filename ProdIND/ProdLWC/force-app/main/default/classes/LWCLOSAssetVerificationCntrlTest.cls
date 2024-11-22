/**
* @description       : This test class is for LWCLOSAssetVerificationCntrl Apex class.
* @author            : Aakash J
* @group             : 
* @created on		 : 08-11-2023
* @Version 		  	 : 1.0
**/
@isTest
public class LWCLOSAssetVerificationCntrlTest {
    
    @testSetup static void createCAMData() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod123@indusbank.com.uat',MobilePhone = '9089078967');
        insert u;
        System.runAs(u) 
        {
            Account au1 = new Account();
            au1.Name = 'test';
            au1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
            insert au1;
            
            List<AccountTeamMember> atmList = new List<AccountTeamMember>();
            AccountTeamMember atm1 = new AccountTeamMember();
            atm1.AccountId = au1.Id;
            atm1.TeamMemberRole = 'RCU_M';
            atm1.UserId = UserInfo.getUserId();
            atm1.FI_Executive_Counter__c = 3;
            insert atm1;
            
            Opportunity opp = TestDataUtility.createTestLoanApplication(true);        
            opp.Sub_Stage__c = System.Label.Field_Investigation;
            opp.Is_Mobile_Journey_Completed__c = true;
            opp.Vehicle_Type__c = System.Label.used;
            opp.Product_Type__c = System.Label.TwoWheeler;
            opp.Sanction_Status__c = System.Label.nonStp;
            opp.AccountId = au1.Id;
            update opp;
            
            Applicant__c applicant = TestDataUtility.createTestApplicantService(true,opp);
            applicant.In_Active_Applicant__c = false;
            applicant.Would_you_like_to_open_a_bank_account__c = true;
            update applicant;
            
            Vehicle_Detail__c vd1 = new Vehicle_Detail__c();
            vd1.Loan_Application__c = opp.Id;
            vd1.Base_Price__c = 100000.00;
            vd1.Ben_Code__c = 'testveh';
            vd1.Variant__c = 'testvariant';
            vd1.Vehicle_Category__c = 'L';
            vd1.Make__c = 'Make 1';
            vd1.Model__c = 'Model 1';
            vd1.Variant__c = 'TATA INDIGO MARINA LX';
            vd1.Engine_number__c = '124567890432345632';
            vd1.Chassis_number__c = 'MZZSY1120011';
            vd1.Serial_number__c = '123456';
            vd1.Vehicle_Registration_Number__c = 'MH12Y2345';
            vd1.KMS_Run__c = '109';
            vd1.Vehicle_Delivered__c = 'Yes';
            insert vd1;
            
            //Get Asset Verification Case recordTypeId
            ID caseAVRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Asset Verification').getRecordTypeId();
            case cs1 = new case();
            cs1.Loan_Application__c = opp.Id;
            cs1.Applicant__c = applicant.Id;
            cs1.Subject='AssetVerification Case';
            cs1.Status = 'New';
            cs1.Priority = 'Medium';
            cs1.RecordTypeId = caseAVRecordType;
            //cs1.OwnerId = opp.OwnerId;
            insert cs1; 
            
            Asset_Verification__c  avRec = new Asset_Verification__c ();
            avRec.Name = vd1.Name;
            avRec.Asset_MMV__c= vd1.Make__c+' '+vd1.Model__c+' '+vd1.Variant__c;
            avRec.Engine_No__c= vd1.Engine_number__c;
            avRec.Chasis_No__c= vd1.Chassis_number__c;
            avRec.Serial_No__c= vd1.Serial_number__c;
            avRec.RC_No__c = vd1.Vehicle_Registration_Number__c;
            avRec.HMR__c = (vd1.KMS_Run__c != null) ? Decimal.valueOf(vd1.KMS_Run__c) : 0;
            avRec.Status__c= 'Completed';
            avRec.Vehicle_Detail__c= vd1.Id;
            avRec.Case__c = cs1.Id;
            avRec.Applicant__c = applicant.Id;
            //avRec.OwnerId = cs1.OwnerId;
            insert avRec; 
            
            //Get Asset Verification Case recordTypeId
            ID docAVRecordType = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('Asset Verification Documents').getRecordTypeId();
            Documents__c backDoc = TestDataUtility.createTestKYCDocs(false, applicant, opp);
            backDoc.Is_Back__c = true;
            backDoc.Document_Type__c = 'PAN';
            backDoc.Document_Side__c ='Back';
            backDoc.Content_Document_Count__c = 1;
            backDoc.Current_Residential_Address_Proof__c = true;
            backDoc.RecordTypeId = docAVRecordType;
            //Insert backDoc;
            
            List<String> documentTypes = new List<String>{
                'Engine Number uploaded during verification', 
                    'Chassis Number uploaded during verification',
                    'Selfie with Vehicle-uploaded during verification',
                    'Vehicle Front-uploaded during verification',
                    'Vehicle Back-uploaded during verification'
                    // 'Capture Vehicle Right Side',
                    //'Capture Vehicle Left Side',
                    // 'Capture HMR',
                    // 'Capture Chassis plate'
                    };
                        
                        List<Documents__c> docLst = new List<Documents__c>();
            
            for(String docType : documentTypes){
                Documents__c docRec = new Documents__c();	
                docRec.Document_Type__c = docType;
                docRec.Asset_Verification__c = avRec.Id;
                docRec.Applicant__c = applicant.Id;
                docRec.Opportunity_Relation__c = opp.Id;
                docLst.add(docRec);
            }
            
            docLst.add(backDoc);
            
            INSERT docLst;
            
            
            ContentVersion cv = new ContentVersion(
                Title = 'Test Document',
                PathOnClient = 'test_document.txt',
                VersionData = Blob.valueOf('Test content')
            );
            insert cv;
            List<ContentDocumentLink> cdlList= new List<ContentDocumentLink>();
            for(Documents__c doc : docLst){
                // Create a ContentDocumentLink record to link the ContentDocument with the related record
                ContentDocumentLink cdl = new ContentDocumentLink(
                    ContentDocumentId = [SELECT Id FROM ContentDocument][0].Id,
                    LinkedEntityId = doc.Id,
                    ShareType = 'V', // 'V' for sharing with the related record's internal users
                    Visibility = 'AllUsers' // 'AllUsers' for visibility to all users
                );
                cdlList.add(cdl);
                
            }
            insert cdlList;
        }
    }
    
    @isTest public static void testClassmethod(){
        User u = [SELECT Id FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        Case caseRec =[Select Id From Case];
        Applicant__c applicantRec =[Select Id From Applicant__c];
        Vehicle_Detail__c vdRec =[Select Id From Vehicle_Detail__c];
        Opportunity oppRec =[Select Id From Opportunity];
        Asset_Verification__c avRec =[Select Id From Asset_Verification__c];
        Documents__c docRec =[Select Id From Documents__c WHERE Document_Type__c = 'PAN'];
        
        System.runAs(u) 
        {
            Test.startTest();
            Opportunity opp1 = TestDataUtility.createTestLoanApplication(true);
            Vehicle_Detail__c vd1 = new Vehicle_Detail__c();
            vd1.Loan_Application__c = opp1.Id;
            vd1.Base_Price__c = 100000.00;
            vd1.Ben_Code__c = 'testveh';
            vd1.Variant__c = 'testvariant';
            vd1.Vehicle_Category__c = 'L';
            vd1.Make__c = 'Make 1';
            vd1.Model__c = 'Model 1';
            vd1.Variant__c = 'TATA INDIGO MARINA LX';
            vd1.Engine_number__c = '124567890432345632';
            vd1.Chassis_number__c = 'MZZSY1120011';
            vd1.Serial_number__c = '123456';
            vd1.Vehicle_Registration_Number__c = 'MH12Y2345';
            vd1.KMS_Run__c = '109';
            vd1.Vehicle_Delivered__c = 'Yes';
            insert vd1;
            LWCLOSAssetVerificationCntrl.getassetVerificationsId(String.valueOf(caseRec.Id),true,null);
            LWCLOSAssetVerificationCntrl.getassetVerificationsId(String.valueOf(caseRec.Id), false,null);
            LWCLOSAssetVerificationCntrl.getassetVerificationsId('fsdfsd', false,null);
            LWCLOSAssetVerificationCntrl.createCaseAVRecords(String.valueOf(opp1.Id),String.valueOf(applicantRec.Id),null);
            LWCLOSAssetVerificationCntrl.createCaseAVRecords(Null,Null,null);
            LWCLOSAssetVerificationCntrl.createCasePDAVRecords(String.valueOf(oppRec.Id),String.valueOf(applicantRec.Id), null);
            LWCLOSAssetVerificationCntrl.checkAssetVerificationStatus(String.valueOf(oppRec.Id));
            LWCLOSAssetVerificationCntrl.checkAssetVerificationStatuspaymentScreen(String.valueOf(oppRec.Id));
            LWCLOSAssetVerificationCntrl.createDocumentRecord(String.valueOf(caseRec.Id),String.valueOf(applicantRec.Id),String.valueOf(vdRec.Id), String.valueOf(avRec.Id), String.valueOf(oppRec.Id),'Engine Number uploaded during verification','Asset Verification Documents');
            try{
                LWCLOSAssetVerificationCntrl.createDocumentRecord(String.valueOf(caseRec.Id), String.valueOf(applicantRec.Id),NULL, String.valueOf(avRec.Id), String.valueOf(oppRec.Id),'Engine Number uploaded during verification','Asset Verification Documents');
            }catch(Exception exc){}
            
            LWCLOSAssetVerificationCntrl.previewDocument(avRec.Id, 'testDocument');
            
            try{
                LWCLOSAssetVerificationCntrl.deleteDocument(docRec.Id);
            }catch(Exception exc){}
            Test.stopTest();   
        }
    }
    @isTest public static void testClassmethod1(){
        User u = [SELECT Id FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        Case caseRec =[Select Id From Case];
        Applicant__c applicantRec =[Select Id From Applicant__c];
        Vehicle_Detail__c vdRec =[Select Id From Vehicle_Detail__c];
        Opportunity oppRec =[Select Id From Opportunity];
        Asset_Verification__c avRec =[Select Id From Asset_Verification__c];
        avRec.Status__c='Inprogress';
        Update avRec;
        Documents__c docRec =[Select Id From Documents__c WHERE Document_Type__c = 'PAN'];
        
        System.runAs(u) 
        {
            Test.startTest();
            Opportunity opp1 = TestDataUtility.createTestLoanApplication(true);
            Vehicle_Detail__c vd1 = new Vehicle_Detail__c();
            vd1.Loan_Application__c = opp1.Id;
            vd1.Base_Price__c = 100000.00;
            vd1.Ben_Code__c = 'testveh';
            vd1.Variant__c = 'testvariant';
            vd1.Vehicle_Category__c = 'L';
            vd1.Make__c = 'Make 1';
            vd1.Model__c = 'Model 1';
            vd1.Variant__c = 'TATA INDIGO MARINA LX';
            vd1.Engine_number__c = '124567890432345632';
            vd1.Chassis_number__c = 'MZZSY1120011';
            vd1.Serial_number__c = '123456';
            vd1.Vehicle_Registration_Number__c = 'MH12Y2345';
            vd1.KMS_Run__c = '109';
            vd1.Vehicle_Delivered__c = 'Yes';
            insert vd1;
           /* List<ContentDocumentLink> cdlList= new List<ContentDocumentLink>();
            for(ContentDocumentLink cdl: [Select Id,LinkedEntityId From ContentDocumentLink Where   ContentDocumentId =:[SELECT Id FROM ContentDocument][0].Id ]){
                cdl.LinkedEntityId= opp1.Id;
                cdlList.add(cdl);
            }*/
           // Update cdlList;
            LWCLOSAssetVerificationCntrl.getassetVerificationsId(String.valueOf(caseRec.Id),true,null);
            LWCLOSAssetVerificationCntrl.getassetVerificationsId(String.valueOf(caseRec.Id), false,null);
            LWCLOSAssetVerificationCntrl.getassetVerificationsId('fsdfsd', false,null);
            
            Test.stopTest();   
        }
    }
    
    @isTest
    static void test_IsDocumentNotUploaded() {
        Asset_Verification__c av = [SELECT ID from Asset_Verification__c LIMIT 1];
        Documents__c backDoc = TestDataUtility.createTestDocument(false);
        backDoc.Asset_Verification__c = av.Id;
        insert backDoc;
        Test.startTest();
        Boolean isUploaded = LWCLOSAssetVerificationCntrl.isDocumentUploaded(av.Id);
        Test.stopTest();
        System.assertEquals(false, isUploaded);
    }
    
    
    @isTest
    static void test_sendNotification() {
        List<Asset_Verification__c> av = [SELECT ID,Case__r.Loan_Application__c from Asset_Verification__c WHERE Case__r.Loan_Application__c != null LIMIT 1];
        if(!av.isEmpty()){
            av[0].Status__c = 'New';
            update av;
            Test.startTest();
            LWCLOSAssetVerificationCntrl.sendNotification(av[0].Id);
            Test.stopTest();
        }
    }
    @isTest
    static void test_updateAVStatus() {
        List<Asset_Verification__c> av = [SELECT ID,Case__r.Loan_Application__c from Asset_Verification__c WHERE Case__r.Loan_Application__c != null LIMIT 1];
        String abc = av[0].Case__r.Loan_Application__c;
        if(!av.isEmpty()){
            av[0].Status__c = 'New';
            update av;
            Test.startTest();
            LWCLOSAssetVerificationCntrl.updateAVStatus(abc);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getRCUSamplerNameTest(){
        case cs1=[Select Id From Case Limit 1];
        LWCLOSAssetVerificationCntrl.getRCUSamplerName(cs1.Id);
    }
    
    
    
}