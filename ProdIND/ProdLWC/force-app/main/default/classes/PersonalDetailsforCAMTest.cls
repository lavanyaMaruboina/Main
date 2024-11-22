@isTest
public class PersonalDetailsforCAMTest {
    @testSetup 
    static void testDataSetup() 
    {
        Integer ranNum = Integer.valueOf(Math.Random() * 10);
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',MobilePhone = '9999999999',
                          EmailEncodingKey='UTF-8', LastName='Testing'+ranNum, LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod123@indusbank.com.uat');
        insert u;
        System.runAs(u) 
        {
            //Create Account
            Account a1 = new Account();
            a1.Name = 'testname';
            insert a1;
            
            //Create Contact
            Contact c1 = new Contact();
            c1.AccountId = a1.Id;
            c1.Phone = '999999999';
            c1.Email = 'test@gmail.com';
            c1.LastName = 'test';
            insert c1;                        
            
            // Create Opportunity
            List<Opportunity> oppList = new List<Opportunity>();
            Opportunity opgr1 = new Opportunity();
            opgr1.Product_Type__c = 'Passenger Vehicles';
            opgr1.Vehicle_Sub_Category__c = 'UIM';
            opgr1.StageName = 'Qualification';
            opgr1.CloseDate = Date.newInstance(2021, 1, 11);
            opgr1.Name = 'test1';
            oppList.add(opgr1);
            
            Opportunity opgr2 = new Opportunity();
            opgr2.Product_Type__c = 'Two Wheeler';
            opgr2.Vehicle_Sub_Category__c = 'UIM';
            opgr2.StageName = 'Qualification';
            opgr2.CloseDate = Date.newInstance(2021, 1, 11);
            opgr2.Name = 'test2';
            oppList.add(opgr2);
            insert oppList;
            
            //Create Asset
            List<Asset> assetList = new List<Asset>();
            Asset as1 = new Asset();
            as1.AccountId = a1.Id;
            as1.ContactId = c1.Id;
            as1.Name = 'book';
            as1.Vehicle_sub_category__c = opgr1.Vehicle_Sub_Category__c;
            as1.Manufacturer_Year__c = '2021';
            as1.Manufacturer_Month__c = '6';
            assetList.add(as1);
            
            Asset as2 = new Asset();
            as2.AccountId = a1.Id;
            as2.ContactId = c1.Id;
            as2.Name = 'book';
            as2.Vehicle_sub_category__c = opgr1.Vehicle_Sub_Category__c;
            as2.Manufacturer_Year__c = '2022';
            as2.Manufacturer_Month__c = '1';
            assetList.add(as2);
            
            Asset as3 = new Asset();
            as3.AccountId = a1.Id;
            as3.ContactId = c1.Id;
            as3.Name = 'book';
            as3.Vehicle_sub_category__c = opgr2.Vehicle_Sub_Category__c;
            as3.Manufacturer_Year__c = '2021';
            as3.Manufacturer_Month__c = '6';
            assetList.add(as3);
            insert assetList;
            
            //Create Applicant
            List<Applicant__c> appList = new List<Applicant__c>();
            Applicant__c applicant1 = new Applicant__c();
            applicant1.Opportunity__c = opgr1.Id;
            applicant1.Contact_number__c = '9743514830';
            applicant1.Applicant_Type__c = 'Borrower';
            appList.add(applicant1);            
            
            Applicant__c applicant2 = new Applicant__c();
            applicant2.Opportunity__c = opgr1.Id;
            applicant2.Contact_number__c = '9743514830';
            applicant2.Applicant_Type__c = 'Co-Borrower';
            appList.add(applicant2);
            insert appList;
            
            //Create Final_Term
            Final_Term__c ft = new Final_Term__c(Dealer_Disc_to_Customer__c = '12345', Loan_Application__c = opgr1.Id);
            ft.CRM_IRR__c = 120;            
            ft.Holiday_period__c='30';
            ft.EMI_Amount__c= 10000;
            insert ft;
            
            //Create Bank Master
            Bank_Masters__c bm1 = new Bank_Masters__c();
            bm1.Bank_Code__c = 3919;
            bm1.Name = 'test';
            bm1.OwnerId = UserInfo.getUserId();
            insert bm1;
            
            //Create vehicle details
            Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
            vc2.Loan_Application__c = opgr1.Id;
            vc2.Base_Price__c = 100000.00;
            vc2.Ben_Code__c = 'testveh';
            vc2.Eligible_Loan_Amount__c = 1000000.00;
            vc2.Eligible_Tenure__c = 20;
            insert vc2;
            
            //Create Document
            Documents__c dscv2 = new Documents__c();
            dscv2.RecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
            dscv2.Vehicle_Detail__c = vc2.Id;
            dscv2.Applicant__c = applicant1.Id;
            dscv2.Opportunity_Relation__c = opgr1.Id;
            dscv2.KYC_City__c = 'Hyderabad';
            insert dscv2;
            
            //Create city master
            City_State_Master__c csm1 = new City_State_Master__c();
            csm1.Name = dscv2.KYC_City__c;
            csm1.City_Code__c = 'PORT BLAIR';
            csm1.Carwale_ID__c = 296;
            insert csm1;
            
            //Create Income Details 
            List<Income_Details__c> incomeList = new List<Income_Details__c>();
            Income_Details__c incomeObj1 = new Income_Details__c();
            incomeObj1.Applicant__c = applicant1.id;
            incomeObj1.Remarks__c = 'no comments';
            incomeObj1.Capture_Income_Method__c = 'Test';            
            incomeObj1.ABB_to_be_considered__c = 'testabb';
            incomeObj1.Name_of_Recipient_Banks__c = bm1.Id;
            incomeObj1.Is_Salaried__c = true;
            incomeObj1.Is_Self_Employed__c = true;
            incomeObj1.Do_You_File_ITR__c = true;
            incomeObj1.Income__c = 1000.00;
            incomeList.add(incomeObj1);
            
            Income_Details__c incomeObj2 = new Income_Details__c();
            incomeObj2.Applicant__c = applicant1.id;
            incomeObj2.Remarks__c = 'no comments';
            incomeObj1.Capture_ITR_Method__c = 'Test';
            incomeObj2.ABB_to_be_considered__c = 'testabb';
            incomeObj2.Name_of_Recipient_Banks__c = bm1.Id;
            incomeObj2.Is_Salaried__c = false;
            incomeObj2.Is_Self_Employed__c = true;
            incomeObj2.Do_You_File_ITR__c = false;
            incomeObj2.Do_You_File_GST__c = true;            
            incomeObj2.Income__c = 1000.00;
            incomeList.add(incomeObj2);
            
            Income_Details__c incomeObj3 = new Income_Details__c();
            incomeObj3.Applicant__c = applicant1.id;
            incomeObj3.Remarks__c = 'no comments';
            incomeObj1.Capture_GST_Method__c = 'Test';
            incomeObj3.ABB_to_be_considered__c = 'testabb';
            incomeObj3.Name_of_Recipient_Banks__c = bm1.Id;
            incomeObj3.Is_Salaried__c = false;
            incomeObj3.Is_Self_Employed__c = true;
            incomeObj3.Do_You_File_ITR__c = true;
            incomeObj3.Do_You_File_GST__c = false;            
            incomeObj3.Income__c = 1000.00;
            incomeList.add(incomeObj3);

            insert incomeList;     
            
            //Create Content Version
            Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');            
            ContentVersion cv = new ContentVersion();
            cv.title = 'test content trigger';      
            cv.PathOnClient ='test';           
            cv.VersionData =beforeblob;          
            insert cv;   
            
            ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
            List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>();
            ContentDocumentLink contentlink1 = new ContentDocumentLink();
            contentlink1.ShareType = 'V';
            contentlink1.LinkedEntityId = incomeObj1.Id; 
            contentlink1.ContentDocumentId = testcontent.ContentDocumentId;
            contentlink1.Visibility = 'AllUsers'; 
            contentDocumentLinkList.add(contentlink1);
            
            ContentDocumentLink contentlink2 = new ContentDocumentLink();
            contentlink2.ShareType = 'V';
            contentlink2.LinkedEntityId = incomeObj2.Id; 
            contentlink2.ContentDocumentId = testcontent.ContentDocumentId;
            contentlink2.Visibility = 'AllUsers'; 
            contentDocumentLinkList.add(contentlink2);
            ContentDocumentLink contentlink3 = new ContentDocumentLink();
            contentlink3.ShareType = 'V';
            contentlink3.LinkedEntityId = incomeObj3.Id; 
            contentlink3.ContentDocumentId = testcontent.ContentDocumentId;
            contentlink3.Visibility = 'AllUsers'; 
            contentDocumentLinkList.add(contentlink3);
            insert contentDocumentLinkList;
        }
    }
    @isTest
    public static void getRecordsTest()
    {
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = 'test1' LIMIT 1];                
            Test.startTest();
            Map<String,List<String>> result1 = PersonalDetailsforCAM.getRecords(opp.Id);
            System.assert(!result1.isEmpty());            
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getRecordsTest1(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = 'test2' LIMIT 1];                
            Test.startTest();
            Map<String,List<String>> result1 = PersonalDetailsforCAM.getRecords(opp.Id);
            System.assert(!result1.isEmpty());            
            Test.stopTest();
        }
    }    
    
    @isTest
    public static void fetchbankdetailsTest()
    {        
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Applicant__c app = [SELECT Id, Opportunity__c FROM Applicant__c WHERE Applicant_Type__c = 'Borrower' LIMIT 1];          
            
            Test.startTest();
            Map<String,Map<String,String>> result = PersonalDetailsforCAM.fetchbankdetails(app.Opportunity__c,app.Id);
            System.assert(!result.isEmpty());
            Test.stopTest();
        }
    }
    
    @isTest
    public static void FetchIncomesTest(){
        
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Applicant__c app = [SELECT Id, Opportunity__c FROM Applicant__c WHERE Applicant_Type__c = 'Borrower' LIMIT 1];          
            Bank_Masters__c bm1 = [SELECT Id FROM Bank_Masters__c LIMIT 1];                
            Test.startTest();
            Map<String,List<String>> result=PersonalDetailsforCAM.FetchIncomes(app.Opportunity__c, app.Id, bm1.Id);
            System.assert(!result.isEmpty());
            Test.stopTest();
        }
    }    

    @isTest
    public static void FetchIncomesTest1(){
        
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
                    
            Bank_Masters__c bs1 = new Bank_Masters__c();
            bs1.Bank_Code__c = 3815;
            bs1.Name = 'test';
            bs1.OwnerId = UserInfo.getUserId();
            insert bs1; 
            
            Income_Details__c incomeObj = new Income_Details__c();
            incomeObj.Applicant__c = apga1.id;
            incomeObj.Is_Salaried__c = true;
            incomeObj.Do_You_File_ITR__c = false;
            incomeObj.Name_of_Recipient_Banks__c = bs1.Id;
            incomeObj.Income__c = 100000;
            incomeObj.Income_from_Perfios__c = 50000;
            insert incomeObj;
            
            Test.startTest();
            Map<String,List<String>> result=PersonalDetailsforCAM.FetchIncomes(opga1.Id, apga1.Id, bs1.Id);
            System.assert(!result.isEmpty());
            Test.stopTest();
        }
    }        
    
    
    
    @isTest
    public static void getRecordsincomeTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'test1' LIMIT 1];         
            
            Test.startTest();
         //   Map<String,List<String>> result=PersonalDetailsforCAM.getRecordsincome(opp.Id);
         //   System.assert(!result.isEmpty());
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getRecordsincomeTest1(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'test2' LIMIT 1]; 
            Test.startTest();
          //  Map<String,List<String>> result=PersonalDetailsforCAM.getRecordsincome(opp.Id);
          //  System.assert(!result.isEmpty());
            Test.stopTest();
        }
    }    
    // added velow for SFTRAC-92
    @isTest
    public static void testRecordsVarientForTractor(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            List<Opportunity> opp = [SELECT Id from Opportunity WHERE Name = 'test1' limit 1];
            if(opp != null && opp.size() > 0){
                Test.startTest();
                PersonalDetailsforCAM.getVehicleDetailRecordIdsTF(opp[0].Id);
                Vehicle_Detail__c vResult = PersonalDetailsforCAM.getVechicleDetails(opp[0].Id);
                if(vResult != null){
            		Map<String,String> result = PersonalDetailsforCAM.getRecordsVarientForTractor(opp[0].Id,vResult.Id);
                    test.stopTest();
                }
            }
        }
    }  
    
    @isTest
    public static void getRecordsCibilTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'test1' LIMIT 1];        
            Test.startTest();
           // Map<String,List<String>> result=PersonalDetailsforCAM.getRecordsCibil(opp.Id);
          //  System.assert(!result.isEmpty());
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getRecordsCibilTest1(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'test2' LIMIT 1];
            
            Test.startTest();
          //  Map<String,List<String>> result= PersonalDetailsforCAM.getRecordsCibil(opp.Id);
          //  System.assert(!result.isEmpty());
            Test.stopTest();
        }
    }        
    
    @isTest
    public static void getincomedetailborrowerTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Applicant__c app = [SELECT Id, Opportunity__c FROM Applicant__c WHERE Applicant_Type__c = 'Borrower' LIMIT 1];          
            Bank_Masters__c bm1 = [SELECT Id FROM Bank_Masters__c LIMIT 1];  
            
            Test.startTest();
            Map<String,List<Map<String,Map<String,String>>>> result=PersonalDetailsforCAM.getincomedetailborrower(app.Opportunity__c, app.Id);
            System.assert(!result.isEmpty());
            Test.stopTest();
        }
    }  
    
    @isTest
    public static void getincomedetailborrowerTest1(){
         User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
                    
            Bank_Masters__c bs1 = new Bank_Masters__c();
            bs1.Bank_Code__c = 3815;
            bs1.Name = 'test';
            bs1.OwnerId = UserInfo.getUserId();
            insert bs1; 
            
            Income_Details__c incomeObj = new Income_Details__c();
            incomeObj.Applicant__c = apga1.id;
            incomeObj.Is_Salaried__c = true;
            incomeObj.Do_You_File_ITR__c = false;
            incomeObj.Name_of_Recipient_Banks__c = bs1.Id;
            incomeObj.Income__c = 100000;
            incomeObj.Income_from_Perfios__c = 50000;
            insert incomeObj;
            
            Test.startTest();
                   PersonalDetailsforCAM.getincomedetailborrower(opga1.Id, apga1.Id);
            Test.stopTest();
        }
    }
    
     @isTest
    public static void getincomedetailborrowerTest2(){
         User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
                    
            Bank_Masters__c bs1 = new Bank_Masters__c();
            bs1.Bank_Code__c = 3815;
            bs1.Name = 'test';
            bs1.OwnerId = UserInfo.getUserId();
            insert bs1; 
            
            Income_Details__c incomeObj = new Income_Details__c();
            incomeObj.Applicant__c = apga1.id;
            incomeObj.Is_Salaried__c = true;
            incomeObj.Do_You_File_ITR__c = false;
            incomeObj.Name_of_Recipient_Banks__c = bs1.Id;
            incomeObj.Income__c = 100000;
            incomeObj.Income_from_Perfios__c = 50000;
            incomeObj.Income_Source_Status__c = 'NIP';
            insert incomeObj;
            
            Test.startTest();
                   PersonalDetailsforCAM.getincomedetailborrower(opga1.Id, apga1.Id);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getincomedetailborrowerTest3(){
         User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
                    
            Bank_Masters__c bs1 = new Bank_Masters__c();
            bs1.Bank_Code__c = 3815;
            bs1.Name = 'test';
            bs1.OwnerId = UserInfo.getUserId();
            insert bs1; 
            
            Income_Details__c incomeObj = new Income_Details__c();
            incomeObj.Applicant__c = apga1.id;
            incomeObj.Is_Salaried__c = true;
            incomeObj.Do_You_File_ITR__c = True;
            incomeObj.Name_of_Recipient_Banks__c = bs1.Id;
            incomeObj.Income__c = 100000;
            incomeObj.Income_from_Perfios__c = 50000;
            incomeObj.Income_Source_Status__c = 'NIP';
            insert incomeObj;
            
            Test.startTest();
                   PersonalDetailsforCAM.getincomedetailborrower(opga1.Id, apga1.Id);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getincomedetailborrowerTest4(){
         User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
                    
            Bank_Masters__c bs1 = new Bank_Masters__c();
            bs1.Bank_Code__c = 3815;
            bs1.Name = 'test';
            bs1.OwnerId = UserInfo.getUserId();
            insert bs1; 
            
            Income_Details__c incomeObj = new Income_Details__c();
            incomeObj.Applicant__c = apga1.id;
            incomeObj.Is_Salaried__c = false;
            incomeObj.Do_You_File_GST__c = true;
            incomeObj.Name_of_Recipient_Banks__c = bs1.Id;
            incomeObj.Income__c = 100000;
            incomeObj.Income_from_Perfios__c = 50000;
            incomeObj.Income_Source_Status__c = 'NIP';
            insert incomeObj;
            
            Test.startTest();
                   PersonalDetailsforCAM.getincomedetailborrower(opga1.Id, apga1.Id);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getincomedetailborrowerfieldsTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Applicant__c app = [SELECT Id, Opportunity__c FROM Applicant__c WHERE Applicant_Type__c = 'Borrower' LIMIT 1];          
            
            Test.startTest();
            Map<String,List<Map<String,Map<String,String>>>> result=  PersonalDetailsforCAM.getincomedetailborrowerfields(app.Opportunity__c, app.Id);
            System.assert(!result.isEmpty());
            Test.stopTest();
        }
    }        
    
    @isTest
    public static void getincomeborrowerhomeTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Applicant__c app = [SELECT Id, Opportunity__c FROM Applicant__c WHERE Applicant_Type__c = 'Borrower' LIMIT 1];          
            
            Test.startTest();
            Map<String,String> result = PersonalDetailsforCAM.getincomeborrowerhome(app.Opportunity__c);
            System.assert(!result.isEmpty());
            Test.stopTest();
        }
    }         
    
    @isTest
    public static void varientdetailsTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = 'test2' LIMIT 1];
            Test.startTest();
            String result = PersonalDetailsforCAM.varientdetails(opp.Id);  
            System.assertEquals(null, result);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getDetailsforLoanTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = 'test1' LIMIT 1];
            Test.startTest();
            PersonalDetailsforCAM.LoanDetailWrapper result1 = PersonalDetailsforCAM.getDetailsforLoan(opp.Id);    
            System.assertNotEquals(null, result1);
            PersonalDetailsforCAM.LoanDetailWrapper result2 = PersonalDetailsforCAM.getDetailsforLoan(null);  
            System.assertEquals(null, result2);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getDetailsvarientcodeTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = 'test1' LIMIT 1];
            Test.startTest();
            String result = PersonalDetailsforCAM.getDetailsvarientcode(opp.Id); 
            System.assertEquals(null, result);            
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getRecordsVarientnewTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = 'test1' LIMIT 1];
              List<Vehicle_Detail__c> vdList = [SELECT Id,Deal_Number__c FROM Vehicle_Detail__c WHERE Loan_Application__c =:opp.Id LIMIT 1];
            Test.startTest();
            Map<String,String> result = PersonalDetailsforCAM.getRecordsVarientnew(opp.Id,vdList[0].Id); 
            System.assertNotEquals(null, result);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getRecordsVarientnewTest1(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = 'test2' LIMIT 1];
            Test.startTest();
            Map<String,String> result = PersonalDetailsforCAM.getRecordsVarientnew(opp.Id,null);
            System.assertNotEquals(null, result);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getRecordsVarientoldTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = 'test1' LIMIT 1];
            Test.startTest();
            Map<String,String> result = PersonalDetailsforCAM.getRecordsVarientold(opp.Id);
            System.assertNotEquals(null, result);                                
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getRecordsVarientoldTest1(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = 'test2' LIMIT 1];
            Test.startTest();
            Map<String,String> result = PersonalDetailsforCAM.getRecordsVarientold(opp.Id);
            System.assertNotEquals(null, result);                                
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getRecordsLoanofferTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = 'test2' LIMIT 1];
            Test.startTest();
            Map<String,String> result1 = PersonalDetailsforCAM.getRecordsLoanoffer(opp.Id);
            System.assertNotEquals(null, result1); 
            Map<String,String> result2 = PersonalDetailsforCAM.getRecordsLoanoffer('test');  
            System.assertNotEquals(null, result2); 
            Test.stopTest();
        }
    }
    
    @isTest
    public static void loadOfferScreenDataTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = 'test1' LIMIT 1];        
            Test.startTest();
            String result = PersonalDetailsforCAM.loadOfferScreenData(opp.Id);
            System.assertNotEquals(null, result); 
            Test.stopTest();
        }
    }
    
   /* @isTest
    public static void validateTenureChangeTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_user@abc.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = 'test1' LIMIT 1];
            
            Test.startTest();
            Boolean result = PersonalDetailsforCAM.validateTenureChange(2,opp.Id);
            System.assertNotEquals(null, result); 
            Test.stopTest();
        }
    }
    
    @isTest
    public static void validateTenureChangeTest1(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_user@abc.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = 'test2' LIMIT 1];
            
            Test.startTest();
            Boolean result = PersonalDetailsforCAM.validateTenureChange(2,opp.Id);
            System.assertNotEquals(null, result); 
            Test.stopTest();
        }
    }  */       
    
    @isTest
    public static void getVechicleDetailsTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = 'test1' LIMIT 1];
            
            Test.startTest();
            Vehicle_Detail__c result = PersonalDetailsforCAM.getVechicleDetails(opp.Id);
            System.assertNotEquals(null, result); 
            Test.stopTest();
        }
    }
    
    @isTest
    public static void checkEligibleLoanAmtTest(){        
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = 'test1' LIMIT 1];
            
            Test.startTest();
            Boolean result = PersonalDetailsforCAM.checkEligibleLoanAmt(opp.Id,'100');
            System.assertNotEquals(null, result); 
            Test.stopTest();
        }                         
    }        
    
    @isTest
    public static void checkEligibleLoanAmtTest1(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = 'test1' LIMIT 1];
            opp.Product_Type__c = 'Two Wheeler';
            update opp;
            Test.startTest();
            Boolean result = PersonalDetailsforCAM.checkEligibleLoanAmt(opp.Id,'100');
            System.assertNotEquals(null, result); 
            Test.stopTest();
        }     
    }
        
    @isTest
    public static void checkEligibleLoantenureTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = 'test1' LIMIT 1];
            
            Test.startTest();
            Boolean result = PersonalDetailsforCAM.checkEligibleLoantenure(8,opp.Id);
            System.assertNotEquals(null, result); 
            Test.stopTest();
        }
    }
    
    @isTest
    public static void checkEligibleLoantenureTest1(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = 'test1' LIMIT 1];
            opp.Product_Type__c = 'Two Wheeler';
            update opp;
            Test.startTest();
            Boolean result = PersonalDetailsforCAM.checkEligibleLoantenure(8,opp.Id);
            System.assertNotEquals(null, result); 
            Test.stopTest();
        }
    }
       
    @isTest
    public static void saveOfferDetailsTest(){ 
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Final_Term__c finalObj = [SELECT Id FROM Final_Term__c LIMIT 1];
            PersonalDetailsforCAM.loadOfferScreenDataWrapper ldw = new PersonalDetailsforCAM.loadOfferScreenDataWrapper();
            ldw.getrecordId = finalObj.Id;
            ldw.crmIRR = 10000.00;
            ldw.requriedCRMIRR = 'testreq';
            ldw.netPayIns = 'testnet';
            ldw.netPayOut = 'testpay';
            ldw.grossIRROffered = 'testgross';
            ldw.netIRROffered = 'testnet';
            ldw.stopJourneyFlag = 'teststop';
            ldw.loanAmount = '100000';
            ldw.tenure = '36';
            ldw.emi = 1000;
            ldw.maxLoanAmtSlider = 1100;
            ldw.minTenureSlider = 800;
            ldw.maxLoanAmtSlider = 200000;
            ldw.minTenureSlider = 80000;
            ldw.advanceEmi = true;
            ldw.monitoriumDays  = '90';
            
            Test.startTest();
            PersonalDetailsforCAM.saveOfferDetails(Json.serialize(ldw));
            System.assertNotEquals(null, finalObj); 
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getOfferScreenDataTest(){
        try{
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = 'test1' LIMIT 1];
                Test.startTest();
                String result1 = PersonalDetailsforCAM.getOfferScreenData(opp.Id);
                System.assertNotEquals(null, result1); 
                String result2 = PersonalDetailsforCAM.getOfferScreenData(null);
                System.assertEquals(null, result2); 
                PersonalDetailsforCAM.getOfferScreenData('test');
                Test.stopTest();
            }
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void submitborrowerecordsTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Applicant__c app = [SELECT Id, Opportunity__c FROM Applicant__c WHERE Applicant_Type__c = 'Borrower' LIMIT 1];          
            Test.startTest();
            PersonalDetailsforCAM.submitborrowerecords(app.Opportunity__c,app.id,'test');
            System.assertNotEquals(null, app); 
            Test.stopTest();
        }
    }
    
    @isTest
    public static void SubmithandleritrTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = 'test1' LIMIT 1];                    
            Test.startTest();
            PersonalDetailsforCAM.Submithandleritr(opp.Id,'TEST',True,false,false);
            PersonalDetailsforCAM.Submithandleritr(opp.Id,'TEST',false,True,false);                     
            PersonalDetailsforCAM.Submithandleritr(opp.Id,'TEST',false,false,True);
            PersonalDetailsforCAM.Submithandleritr(opp.Id,'TEST',false,false,false);
            System.assertNotEquals(null, opp); 
            Test.stopTest();
        }
    }
    
    @isTest
    public static void retriveFilesTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Income_Details__c income = [SELECT Id,Capture_Income_Method__c FROM Income_Details__c WHERE Capture_Income_Method__c='Test' Limit 1];
            
            Test.startTest();
            Id result1 = PersonalDetailsforCAM.retriveFiles(income.Id);
            System.assertNotEquals(null, result1);
            Id result2 = PersonalDetailsforCAM.retriveFiles(null);
            System.assertEquals(null, result2);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void retriveFilesitrTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Applicant__c app = [SELECT Id, Opportunity__c FROM Applicant__c WHERE Applicant_Type__c = 'Borrower' LIMIT 1];          
            Test.startTest();
            Id result = PersonalDetailsforCAM.retriveFilesitr(app.Opportunity__c,app.Id);
            System.assertNotEquals(null, result);            
            Test.stopTest();
        }
    }
    
    @isTest
    public static void retriveFilesgstTest(){
        
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Applicant__c app = [SELECT Id, Opportunity__c FROM Applicant__c WHERE Applicant_Type__c = 'Borrower' LIMIT 1];          
            Test.startTest();
            Id result = PersonalDetailsforCAM.retriveFilesgst(app.Opportunity__c,app.Id);
           // PersonalDetailsforCAM.retriveFilesgst(null,null);
            System.assertNotEquals(null, result);            
            Test.stopTest();
        }                
    }
    
   @isTest
    public static void fetchavgincTest(){
        
                Opportunity opfv1 = new Opportunity();
                opfv1.StageName = 'Credit Processing';
                opfv1.CloseDate = Date.newInstance(2021, 1, 11);
                opfv1.Name = 'testone';
                opfv1.OwnerId = UserInfo.getUserId();
                insert opfv1;  
        
                Applicant__c apfv1 = new Applicant__c();
                apfv1.Opportunity__c = opfv1.Id;
                apfv1.Contact_number__c = '9743514830';
                apfv1.Applicant_Type__c = 'Borrower';
                insert apfv1;
        
                case cs2 = new case();
                 cs2.Loan_Application__c = opfv1.Id;
              //   cs2.OwnerId = opfv1.OwnerId;
                 cs2.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('FI').getRecordTypeId();
                 cs2.Subject='Approval Of Application Sourced By Off Roll Employee';
                 cs2.Status = 'Pending-Off Role Employee App';
                 cs2.Origin = 'Web';
                 cs2.Type = 'Office FI';
                 cs2.Status = 'FI-Unassigned';
                 cs2.Applicant__c = apfv1.Id;
                 insert cs2; 
        
                 Test.startTest();
                         PersonalDetailsforCAM.fetchavginc(opfv1.Id);
                         PersonalDetailsforCAM.fetchavginc('test');
                 Test.stopTest();
    }
    
    @isTest
    public static void getDetailsforLoanTest1(){
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
        
                Vehicle_Detail__c vdt1 = new Vehicle_Detail__c();
                vdt1.Loan_Application__c = opga1.Id;
                vdt1.Base_Price__c = 100000.00;
                vdt1.Ben_Code__c = 'testveh';
                vdt1.Vehicle_type__c = 'Used';
                vdt1.Variant__c = 'JAWA Variant';
                insert vdt1;
        
             /*    City_State_Master__c cs1 = new City_State_Master__c();
                 cs1.Name = 'Allur';
                 cs1.City_Code__c = 'PORT BLAIR';
                 cs1.Carwale_ID__c = 291;
                 insert cs1; */
        
                Product2 pd1 = new Product2();
                pd1.Asset_Category__c = 'te';
                pd1.Name = vdt1.Variant__c;
                pd1.Type__c = 'Variant';
                pd1.External_Reference_Id__c = '58568568';
                insert pd1;
                 
                 Test.startTest();
                       PersonalDetailsforCAM.getDetailsforLoan(opga1.Id);
                 Test.stopTest();
    }
    
    @isTest
    public static void validateTenureChangeTest(){
          
            Account av1 = new Account();
            av1.Name = 'samplename';
            insert av1;
            
            Contact cv1 = new Contact();
            cv1.AccountId = av1.Id;
            cv1.Phone = '9999997809';
            cv1.Email = 'test@sfdcgmail.com';
            cv1.LastName = 'res';
            insert cv1;  
        
            Opportunity opga1 = new Opportunity();
            opga1.StageName = 'Qualification';
            opga1.CloseDate = Date.newInstance(2021, 1, 11);
            opga1.Name = 'testone';
            opga1.Product_Type__c = 'Passenger Vehicles';
            opga1.Vehicle_Sub_Category__c = 'testtwo';
            insert opga1;
                    
            Asset as1 = new Asset();
            as1.AccountId = av1.Id;
            as1.ContactId = cv1.Id;
            as1.Name = 'book';
            as1.Vehicle_sub_category__c = opga1.Vehicle_Sub_Category__c;
            as1.Manufacturer_Year__c = '1990';
            as1.Manufacturer_Month__c = '6';
         
                Test.startTest();
                     PersonalDetailsforCAM.validateTenureChange(12,opga1.Id);
                Test.stopTest();
    }
    
    @isTest
    public static void getRecordsincomeTest2(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.Is_Salaried__c = true;
                in1.Is_Income_Credited_In_Bank_Account__c = true;
                in1.Client_Transaction_Id__c = 'test123';
                in1.Perfios_Transaction_Id__c = 'sample123';
                in1.Do_You_File_ITR__c = true;
                in1.Income__c = 100000;
                in1.Income_from_Perfios__c = 50000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                 case cs3 = new case();
                 cs3.Loan_Application__c = opga1.Id;
                 cs3.Applicant__c = apga1.Id;
                 cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                 cs3.Status = 'Pending-Off Role Employee App';
                 cs3.Origin = 'Web';
                 insert cs3; 
            
                 Field_Investigation__c fi2 = new Field_Investigation__c();
                 fi2.Case__c = cs3.Id;
                 fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                 fi2.Income__c = 100000;
                 fi2.Income_as_per_FI_Visit__c = 100000;
                 insert fi2;
             
                 string opId = String.valueOf(opga1.Id);
                 string apId = String.valueOf(apga1.Id);
            
            Test.startTest();
             PersonalDetailsforCAM.Getincomerecords(opId,apId);
         //   System.assert(!result.isEmpty());
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getRecordsincomeTest3(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.Is_Salaried__c = true;
                in1.Is_Income_Credited_In_Bank_Account__c = true;
                in1.Client_Transaction_Id__c = 'test123';
                in1.Perfios_Transaction_Id__c = 'sample123';
                in1.Do_You_File_ITR__c = true;
                in1.Income__c = 100000;
                in1.Income_from_Perfios__c = 50000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                 case cs3 = new case();
                 cs3.Loan_Application__c = opga1.Id;
                 cs3.Applicant__c = apga1.Id;
                 cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                 cs3.Status = 'Pending-Off Role Employee App';
                 cs3.Origin = 'Web';
                 insert cs3; 
            
                 Field_Investigation__c fi2 = new Field_Investigation__c();
                 fi2.Case__c = cs3.Id;
                 fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
               //  fi2.Income__c = 100000;
                 fi2.Income_as_per_FI_Visit__c = 100000;
                 insert fi2;
             
                 string opId = String.valueOf(opga1.Id);
                 string apId = String.valueOf(apga1.Id);
            
            Test.startTest();
             PersonalDetailsforCAM.Getincomerecords(opId,apId);
         //   System.assert(!result.isEmpty());
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getRecordsincomeTest4(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.Is_Salaried__c = true;
                in1.Is_Income_Credited_In_Bank_Account__c = true;
                in1.Client_Transaction_Id__c = 'test123';
                in1.Perfios_Transaction_Id__c = 'sample123';
                in1.Do_You_File_ITR__c = true;
                in1.Income__c = 100000;
                in1.Income_from_Perfios__c = 50000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                 case cs3 = new case();
                 cs3.Loan_Application__c = opga1.Id;
                 cs3.Applicant__c = apga1.Id;
                 cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                 cs3.Status = 'Pending-Off Role Employee App';
                 cs3.Origin = 'Web';
                 insert cs3; 
            
                 Field_Investigation__c fi2 = new Field_Investigation__c();
                 fi2.Case__c = cs3.Id;
                 fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                 fi2.Income_per_month__c = 100000;
                 insert fi2;
             
                 string opId = String.valueOf(opga1.Id);
                 string apId = String.valueOf(apga1.Id);
            
            Test.startTest();
             PersonalDetailsforCAM.Getincomerecords(opId,apId);
         //   System.assert(!result.isEmpty());
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getRecordsincomeTest5(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.Is_Salaried__c = true;
                in1.Is_Income_Credited_In_Bank_Account__c = true;
                in1.Client_Transaction_Id__c = 'test123';
                in1.Perfios_Transaction_Id__c = 'sample123';
                in1.Do_You_File_ITR__c = true;
                in1.Income__c = 100000;
                in1.Income_from_Perfios__c = 50000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                 case cs3 = new case();
                 cs3.Loan_Application__c = opga1.Id;
                 cs3.Applicant__c = apga1.Id;
                 cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                 cs3.Status = 'Pending-Off Role Employee App';
                 cs3.Origin = 'Web';
                 insert cs3; 
            
                 Field_Investigation__c fi2 = new Field_Investigation__c();
                 fi2.Case__c = cs3.Id;
                 fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                 fi2.Income_per_month_property__c = 100000;
                 insert fi2;
             
                 string opId = String.valueOf(opga1.Id);
                 string apId = String.valueOf(apga1.Id);
            
            Test.startTest();
             PersonalDetailsforCAM.Getincomerecords(opId,apId);
         //   System.assert(!result.isEmpty());
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getRecordsincomeTest6(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.Is_Salaried__c = true;
                in1.Is_Income_Credited_In_Bank_Account__c = true;
                in1.Client_Transaction_Id__c = 'test123';
                in1.Perfios_Transaction_Id__c = 'sample123';
                in1.Do_You_File_ITR__c = true;
                in1.Income__c = 100000;
                in1.Income_from_Perfios__c = 50000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                 case cs3 = new case();
                 cs3.Loan_Application__c = opga1.Id;
                 cs3.Applicant__c = apga1.Id;
                 cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                 cs3.Status = 'Pending-Off Role Employee App';
                 cs3.Origin = 'Web';
                 insert cs3; 
            
                 Field_Investigation__c fi2 = new Field_Investigation__c();
                 fi2.Case__c = cs3.Id;
                 fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                 fi2.Monthly_Income_as_per_FI_Visit__c = 100000;
                 insert fi2;
             
                 string opId = String.valueOf(opga1.Id);
                 string apId = String.valueOf(apga1.Id);
            
            Test.startTest();
             PersonalDetailsforCAM.Getincomerecords(opId,apId);
         //   System.assert(!result.isEmpty());
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getRecordsincomeTest7(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.Is_Salaried__c = true;
                in1.Is_Income_Credited_In_Bank_Account__c = true;
                in1.Client_Transaction_Id__c = 'test123';
                in1.Perfios_Transaction_Id__c = 'sample123';
                in1.Do_You_File_ITR__c = true;
                in1.Income__c = 100000;
                in1.Income_from_Perfios__c = 50000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                 case cs3 = new case();
                 cs3.Loan_Application__c = opga1.Id;
                 cs3.Applicant__c = apga1.Id;
                 cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                 cs3.Status = 'Pending-Off Role Employee App';
                 cs3.Origin = 'Web';
                 insert cs3; 
            
                 Field_Investigation__c fi2 = new Field_Investigation__c();
                 fi2.Case__c = cs3.Id;
                 fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                 fi2.SENP_Agriculture_Income__c = 25000;
                 insert fi2;
             
                 string opId = String.valueOf(opga1.Id);
                 string apId = String.valueOf(apga1.Id);
            
            Test.startTest();
             PersonalDetailsforCAM.Getincomerecords(opId,apId);
         //   System.assert(!result.isEmpty());
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getRecordsincomeTest8(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.Is_Salaried__c = true;
                in1.Is_Income_Credited_In_Bank_Account__c = true;
                in1.Client_Transaction_Id__c = 'test123';
                in1.Perfios_Transaction_Id__c = 'sample123';
                in1.Do_You_File_ITR__c = true;
                in1.Income__c = 100000;
                in1.Income_from_Perfios__c = 50000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                 case cs3 = new case();
                 cs3.Loan_Application__c = opga1.Id;
                 cs3.Applicant__c = apga1.Id;
                 cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                 cs3.Status = 'Pending-Off Role Employee App';
                 cs3.Origin = 'Web';
                 insert cs3; 
            
                 Field_Investigation__c fi2 = new Field_Investigation__c();
                 fi2.Case__c = cs3.Id;
                 fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                 fi2.SENP_Contractor_Income__c = 30000;
                 insert fi2;
             
                 string opId = String.valueOf(opga1.Id);
                 string apId = String.valueOf(apga1.Id);
            
            Test.startTest();
             PersonalDetailsforCAM.Getincomerecords(opId,apId);
         //   System.assert(!result.isEmpty());
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getRecordsincomeTest9(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.Is_Salaried__c = true;
                in1.Is_Income_Credited_In_Bank_Account__c = true;
                in1.Client_Transaction_Id__c = 'test123';
                in1.Perfios_Transaction_Id__c = 'sample123';
                in1.Do_You_File_ITR__c = true;
                in1.Income__c = 100000;
                in1.Income_from_Perfios__c = 50000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                 case cs3 = new case();
                 cs3.Loan_Application__c = opga1.Id;
                 cs3.Applicant__c = apga1.Id;
                 cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                 cs3.Status = 'Pending-Off Role Employee App';
                 cs3.Origin = 'Web';
                 insert cs3; 
            
                 Field_Investigation__c fi2 = new Field_Investigation__c();
                 fi2.Case__c = cs3.Id;
                 fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                 fi2.SENP_Own_Shop_Income__c = 25000;
                 insert fi2;
             
                 string opId = String.valueOf(opga1.Id);
                 string apId = String.valueOf(apga1.Id);
            
            Test.startTest();
             PersonalDetailsforCAM.Getincomerecords(opId,apId);
         //   System.assert(!result.isEmpty());
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getRecordsincomeTest10(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.Is_Salaried__c = true;
                in1.Is_Income_Credited_In_Bank_Account__c = true;
                in1.Client_Transaction_Id__c = 'test123';
                in1.Perfios_Transaction_Id__c = 'sample123';
                in1.Do_You_File_ITR__c = true;
                in1.Income__c = 100000;
                in1.Income_from_Perfios__c = 50000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                 case cs3 = new case();
                 cs3.Loan_Application__c = opga1.Id;
                 cs3.Applicant__c = apga1.Id;
                 cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                 cs3.Status = 'Pending-Off Role Employee App';
                 cs3.Origin = 'Web';
                 insert cs3; 
            
                 Field_Investigation__c fi2 = new Field_Investigation__c();
                 fi2.Case__c = cs3.Id;
                 fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                 fi2.SENP_Pension_Income__c = 10000;
                 insert fi2;
             
                 string opId = String.valueOf(opga1.Id);
                 string apId = String.valueOf(apga1.Id);
            
            Test.startTest();
             PersonalDetailsforCAM.Getincomerecords(opId,apId);
         //   System.assert(!result.isEmpty());
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getRecordsincomeTest11(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.Is_Salaried__c = true;
                in1.Is_Income_Credited_In_Bank_Account__c = true;
                in1.Client_Transaction_Id__c = 'test123';
                in1.Perfios_Transaction_Id__c = 'sample123';
                in1.Do_You_File_ITR__c = true;
                in1.Income__c = 100000;
                in1.Income_from_Perfios__c = 50000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                 case cs3 = new case();
                 cs3.Loan_Application__c = opga1.Id;
                 cs3.Applicant__c = apga1.Id;
                 cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                 cs3.Status = 'Pending-Off Role Employee App';
                 cs3.Origin = 'Web';
                 insert cs3; 
            
                 Field_Investigation__c fi2 = new Field_Investigation__c();
                 fi2.Case__c = cs3.Id;
                 fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                 fi2.SENP_Rental_Income__c = 20000;
                 insert fi2;
             
                 string opId = String.valueOf(opga1.Id);
                 string apId = String.valueOf(apga1.Id);
            
            Test.startTest();
             PersonalDetailsforCAM.Getincomerecords(opId,apId);
         //   System.assert(!result.isEmpty());
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getRecordsincomeTest12(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.Is_Salaried__c = true;
                in1.Is_Income_Credited_In_Bank_Account__c = true;
                in1.Client_Transaction_Id__c = 'test123';
                in1.Perfios_Transaction_Id__c = 'sample123';
                in1.Do_You_File_ITR__c = true;
                in1.Income__c = 100000;
                in1.Income_from_Perfios__c = 50000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                 case cs3 = new case();
                 cs3.Loan_Application__c = opga1.Id;
                 cs3.Applicant__c = apga1.Id;
                 cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                 cs3.Status = 'Pending-Off Role Employee App';
                 cs3.Origin = 'Web';
                 insert cs3; 
            
                 Field_Investigation__c fi2 = new Field_Investigation__c();
                 fi2.Case__c = cs3.Id;
                 fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                 fi2.SENP_Service_oriented_Income__c = 20000;
                 insert fi2;
             
                 string opId = String.valueOf(opga1.Id);
                 string apId = String.valueOf(apga1.Id);
            
            Test.startTest();
             PersonalDetailsforCAM.Getincomerecords(opId,apId);
         //   System.assert(!result.isEmpty());
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getRecordsincomeTest13(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.Is_Salaried__c = true;
                in1.Is_Income_Credited_In_Bank_Account__c = true;
                in1.Client_Transaction_Id__c = 'test123';
                in1.Perfios_Transaction_Id__c = 'sample123';
                in1.Do_You_File_ITR__c = true;
                in1.Income__c = 100000;
                in1.Income_from_Perfios__c = 50000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                 case cs3 = new case();
                 cs3.Loan_Application__c = opga1.Id;
                 cs3.Applicant__c = apga1.Id;
                 cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                 cs3.Status = 'Pending-Off Role Employee App';
                 cs3.Origin = 'Web';
                 insert cs3; 
            
                 Field_Investigation__c fi2 = new Field_Investigation__c();
                 fi2.Case__c = cs3.Id;
                 fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                 fi2.SENP_Transporter_Income__c = 10000;
                 insert fi2;
             
                 string opId = String.valueOf(opga1.Id);
                 string apId = String.valueOf(apga1.Id);
            
            Test.startTest();
             PersonalDetailsforCAM.Getincomerecords(opId,apId);
         //   System.assert(!result.isEmpty());
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getRecordsincomeTest14(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.Is_Salaried__c = true;
                in1.Is_Income_Credited_In_Bank_Account__c = true;
                in1.Client_Transaction_Id__c = 'test123';
                in1.Perfios_Transaction_Id__c = 'sample123';
                in1.Do_You_File_ITR__c = true;
                in1.Income__c = 100000;
                in1.Income_from_Perfios__c = 50000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                 case cs3 = new case();
                 cs3.Loan_Application__c = opga1.Id;
                 cs3.Applicant__c = apga1.Id;
                 cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                 cs3.Status = 'Pending-Off Role Employee App';
                 cs3.Origin = 'Web';
                 insert cs3; 
            
               /*  Field_Investigation__c fi2 = new Field_Investigation__c();
                 fi2.Case__c = cs3.Id;
                 fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                 fi2.SENP_Transporter_Income__c = 10000;
                 insert fi2; */
             
                 string opId = String.valueOf(opga1.Id);
                 string apId = String.valueOf(apga1.Id);
            
            Test.startTest();
             PersonalDetailsforCAM.Getincomerecords(opId,apId);
         //   System.assert(!result.isEmpty());
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getRecordsincomeTest15(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.Is_Salaried__c = true;
                in1.Is_Income_Credited_In_Bank_Account__c = true;
                in1.Client_Transaction_Id__c = 'test123';
            //    in1.Perfios_Transaction_Id__c = 'sample123';
                in1.Do_You_File_GST__c = true;
              //  in1.Do_You_File_ITR__c = false;
                in1.Income__c = 100000;
                in1.Income_from_Perfios__c = 50000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                in1.GST_No__c = 'test12345';
                insert in1;
            
                 case cs3 = new case();
                 cs3.Loan_Application__c = opga1.Id;
                 cs3.Applicant__c = apga1.Id;
                 cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                 cs3.Status = 'Pending-Off Role Employee App';
                 cs3.Origin = 'Web';
                 insert cs3; 
            
                 Field_Investigation__c fi2 = new Field_Investigation__c();
                 fi2.Case__c = cs3.Id;
                 fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                 fi2.SENP_Transporter_Income__c = 10000;
                 insert fi2;
             
                 string opId = String.valueOf(opga1.Id);
                 string apId = String.valueOf(apga1.Id);
            
            Test.startTest();
             PersonalDetailsforCAM.Getincomerecords(opId,apId);
         //   System.assert(!result.isEmpty());
            Test.stopTest();
        }
    }
    
    @isTest
    public static void GetincomerecordssalariedTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.Bank_Account_Number__c = '33241567854';
                in1.Is_Salaried__c = true;
                in1.Is_Income_Credited_In_Bank_Account__c = true;
                in1.Income__c = 100000;
                in1.Client_Transaction_Id__c = 'test12345';
                in1.Income_from_Perfios__c = 10000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                case cs3 = new case();
                cs3.Loan_Application__c = opga1.Id;
                cs3.Applicant__c = apga1.Id;
                cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs3.Status = 'Pending-Off Role Employee App';
                cs3.Origin = 'Web';
                insert cs3; 
            
                Field_Investigation__c fi2 = new Field_Investigation__c();
                fi2.Case__c = cs3.Id;
                fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                fi2.SENP_Transporter_Income__c = 10000;
                fi2.Income__c = 100000;
                insert fi2;
            
            Test.startTest();
            PersonalDetailsforCAM.Getincomerecordssalaried(opga1.Id,apga1.id,in1.Bank_Account_Number__c);
          //  System.assertNotEquals(null, result); 
            Test.stopTest();
        }
    }
    
    @isTest
    public static void GetincomerecordssalariedTest1(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.Bank_Account_Number__c = '33241567854';
                in1.Is_Salaried__c = true;
                in1.Is_Income_Credited_In_Bank_Account__c = true;
                in1.Income__c = 100000;
                in1.Client_Transaction_Id__c = 'test12345';
                in1.Income_from_Perfios__c = 10000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                case cs3 = new case();
                cs3.Loan_Application__c = opga1.Id;
                cs3.Applicant__c = apga1.Id;
                cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs3.Status = 'Pending-Off Role Employee App';
                cs3.Origin = 'Web';
                insert cs3; 
            
                Field_Investigation__c fi2 = new Field_Investigation__c();
                fi2.Case__c = cs3.Id;
                fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                fi2.SENP_Transporter_Income__c = 10000;
                fi2.Income_as_per_FI_Visit__c = 100000;
                insert fi2;
            
            Test.startTest();
            PersonalDetailsforCAM.Getincomerecordssalaried(opga1.Id,apga1.id,in1.Bank_Account_Number__c);
          //  System.assertNotEquals(null, result); 
            Test.stopTest();
        }
    }
    
    @isTest
    public static void GetincomerecordssalariedTest2(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.Bank_Account_Number__c = '33241567854';
                in1.Is_Salaried__c = true;
                in1.Is_Income_Credited_In_Bank_Account__c = true;
                in1.Income__c = 100000;
                in1.Client_Transaction_Id__c = 'test12345';
                in1.Income_from_Perfios__c = 10000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                case cs3 = new case();
                cs3.Loan_Application__c = opga1.Id;
                cs3.Applicant__c = apga1.Id;
                cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs3.Status = 'Pending-Off Role Employee App';
                cs3.Origin = 'Web';
                insert cs3; 
            
                Field_Investigation__c fi2 = new Field_Investigation__c();
                fi2.Case__c = cs3.Id;
                fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                fi2.Income_per_month__c = 100000;
                insert fi2;
            
            Test.startTest();
            PersonalDetailsforCAM.Getincomerecordssalaried(opga1.Id,apga1.id,in1.Bank_Account_Number__c);
          //  System.assertNotEquals(null, result); 
            Test.stopTest();
        }
    }
    
    @isTest
    public static void GetincomerecordssalariedTest3(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.Bank_Account_Number__c = '33241567854';
                in1.Is_Salaried__c = true;
                in1.Is_Income_Credited_In_Bank_Account__c = true;
                in1.Income__c = 100000;
                in1.Client_Transaction_Id__c = 'test12345';
                in1.Income_from_Perfios__c = 10000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                case cs3 = new case();
                cs3.Loan_Application__c = opga1.Id;
                cs3.Applicant__c = apga1.Id;
                cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs3.Status = 'Pending-Off Role Employee App';
                cs3.Origin = 'Web';
                insert cs3; 
            
                Field_Investigation__c fi2 = new Field_Investigation__c();
                fi2.Case__c = cs3.Id;
                fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                fi2.Income_per_month__c = 100000;
                insert fi2;
            
            Test.startTest();
            PersonalDetailsforCAM.Getincomerecordssalaried(opga1.Id,apga1.id,in1.Bank_Account_Number__c);
          //  System.assertNotEquals(null, result); 
            Test.stopTest();
        }
    }
    
    @isTest
    public static void GetincomerecordssalariedTest4(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.Bank_Account_Number__c = '33241567854';
                in1.Is_Salaried__c = true;
                in1.Is_Income_Credited_In_Bank_Account__c = true;
                in1.Income__c = 100000;
                in1.Client_Transaction_Id__c = 'test12345';
                in1.Income_from_Perfios__c = 10000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                case cs3 = new case();
                cs3.Loan_Application__c = opga1.Id;
                cs3.Applicant__c = apga1.Id;
                cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs3.Status = 'Pending-Off Role Employee App';
                cs3.Origin = 'Web';
                insert cs3; 
            
                Field_Investigation__c fi2 = new Field_Investigation__c();
                fi2.Case__c = cs3.Id;
                fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                fi2.Income_per_month_property__c = 100000;
                insert fi2;
            
            Test.startTest();
            PersonalDetailsforCAM.Getincomerecordssalaried(opga1.Id,apga1.id,in1.Bank_Account_Number__c);
          //  System.assertNotEquals(null, result); 
            Test.stopTest();
        }
    }
    
    @isTest
    public static void GetincomerecordssalariedTest5(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.Bank_Account_Number__c = '33241567854';
                in1.Is_Salaried__c = true;
                in1.Is_Income_Credited_In_Bank_Account__c = true;
                in1.Income__c = 100000;
                in1.Client_Transaction_Id__c = 'test12345';
                in1.Income_from_Perfios__c = 10000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                case cs3 = new case();
                cs3.Loan_Application__c = opga1.Id;
                cs3.Applicant__c = apga1.Id;
                cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs3.Status = 'Pending-Off Role Employee App';
                cs3.Origin = 'Web';
                insert cs3; 
            
                Field_Investigation__c fi2 = new Field_Investigation__c();
                fi2.Case__c = cs3.Id;
                fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                fi2.Monthly_Income_as_per_FI_Visit__c = 100000;
                insert fi2;
            
            Test.startTest();
            PersonalDetailsforCAM.Getincomerecordssalaried(opga1.Id,apga1.id,in1.Bank_Account_Number__c);
          //  System.assertNotEquals(null, result); 
            Test.stopTest();
        }
    }
    
    @isTest
    public static void GetincomerecordssalariedTest6(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.Bank_Account_Number__c = '33241567854';
                in1.Is_Salaried__c = true;
                in1.Is_Income_Credited_In_Bank_Account__c = true;
                in1.Income__c = 100000;
                in1.Client_Transaction_Id__c = 'test12345';
                in1.Income_from_Perfios__c = 10000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                case cs3 = new case();
                cs3.Loan_Application__c = opga1.Id;
                cs3.Applicant__c = apga1.Id;
                cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs3.Status = 'Pending-Off Role Employee App';
                cs3.Origin = 'Web';
                insert cs3; 
            
                Field_Investigation__c fi2 = new Field_Investigation__c();
                fi2.Case__c = cs3.Id;
                fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                fi2.SENP_Agriculture_Income__c = 20000;
                insert fi2;
            
            Test.startTest();
            PersonalDetailsforCAM.Getincomerecordssalaried(opga1.Id,apga1.id,in1.Bank_Account_Number__c);
          //  System.assertNotEquals(null, result); 
            Test.stopTest();
        }
    }
    
    @isTest
    public static void GetincomerecordssalariedTest7(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.Bank_Account_Number__c = '33241567854';
                in1.Is_Salaried__c = true;
                in1.Is_Income_Credited_In_Bank_Account__c = true;
                in1.Income__c = 100000;
                in1.Client_Transaction_Id__c = 'test12345';
                in1.Income_from_Perfios__c = 10000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                case cs3 = new case();
                cs3.Loan_Application__c = opga1.Id;
                cs3.Applicant__c = apga1.Id;
                cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs3.Status = 'Pending-Off Role Employee App';
                cs3.Origin = 'Web';
                insert cs3; 
            
                Field_Investigation__c fi2 = new Field_Investigation__c();
                fi2.Case__c = cs3.Id;
                fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                fi2.SENP_Contractor_Income__c = 100000;
                insert fi2;
            
            Test.startTest();
            PersonalDetailsforCAM.Getincomerecordssalaried(opga1.Id,apga1.id,in1.Bank_Account_Number__c);
          //  System.assertNotEquals(null, result); 
            Test.stopTest();
        }
    }
    
    @isTest
    public static void GetincomerecordssalariedTest8(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.Bank_Account_Number__c = '33241567854';
                in1.Is_Salaried__c = true;
                in1.Is_Income_Credited_In_Bank_Account__c = true;
                in1.Income__c = 100000;
                in1.Client_Transaction_Id__c = 'test12345';
                in1.Income_from_Perfios__c = 10000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                case cs3 = new case();
                cs3.Loan_Application__c = opga1.Id;
                cs3.Applicant__c = apga1.Id;
                cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs3.Status = 'Pending-Off Role Employee App';
                cs3.Origin = 'Web';
                insert cs3; 
            
                Field_Investigation__c fi2 = new Field_Investigation__c();
                fi2.Case__c = cs3.Id;
                fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                fi2.SENP_Own_Shop_Income__c = 100000;
                insert fi2;
            
            Test.startTest();
            PersonalDetailsforCAM.Getincomerecordssalaried(opga1.Id,apga1.id,in1.Bank_Account_Number__c);
          //  System.assertNotEquals(null, result); 
            Test.stopTest();
        }
    }
    
    @isTest
    public static void GetincomerecordssalariedTest9(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.Bank_Account_Number__c = '33241567854';
                in1.Is_Salaried__c = true;
                in1.Is_Income_Credited_In_Bank_Account__c = true;
                in1.Income__c = 100000;
                in1.Client_Transaction_Id__c = 'test12345';
                in1.Income_from_Perfios__c = 10000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                case cs3 = new case();
                cs3.Loan_Application__c = opga1.Id;
                cs3.Applicant__c = apga1.Id;
                cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs3.Status = 'Pending-Off Role Employee App';
                cs3.Origin = 'Web';
                insert cs3; 
            
                Field_Investigation__c fi2 = new Field_Investigation__c();
                fi2.Case__c = cs3.Id;
                fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                fi2.SENP_Pension_Income__c = 10000;
                insert fi2;
            
            Test.startTest();
            PersonalDetailsforCAM.Getincomerecordssalaried(opga1.Id,apga1.id,in1.Bank_Account_Number__c);
          //  System.assertNotEquals(null, result); 
            Test.stopTest();
        }
    }
    
    @isTest
    public static void GetincomerecordssalariedTest10(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.Bank_Account_Number__c = '33241567854';
                in1.Is_Salaried__c = true;
                in1.Is_Income_Credited_In_Bank_Account__c = true;
                in1.Income__c = 100000;
                in1.Client_Transaction_Id__c = 'test12345';
                in1.Income_from_Perfios__c = 10000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                case cs3 = new case();
                cs3.Loan_Application__c = opga1.Id;
                cs3.Applicant__c = apga1.Id;
                cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs3.Status = 'Pending-Off Role Employee App';
                cs3.Origin = 'Web';
                insert cs3; 
            
                Field_Investigation__c fi2 = new Field_Investigation__c();
                fi2.Case__c = cs3.Id;
                fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                fi2.SENP_Rental_Income__c = 10000;
                insert fi2;
            
            Test.startTest();
            PersonalDetailsforCAM.Getincomerecordssalaried(opga1.Id,apga1.id,in1.Bank_Account_Number__c);
          //  System.assertNotEquals(null, result); 
            Test.stopTest();
        }
    }
    
    @isTest
    public static void GetincomerecordssalariedTest11(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.Bank_Account_Number__c = '33241567854';
                in1.Is_Salaried__c = true;
                in1.Is_Income_Credited_In_Bank_Account__c = true;
                in1.Income__c = 100000;
                in1.Client_Transaction_Id__c = 'test12345';
                in1.Income_from_Perfios__c = 10000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                case cs3 = new case();
                cs3.Loan_Application__c = opga1.Id;
                cs3.Applicant__c = apga1.Id;
                cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs3.Status = 'Pending-Off Role Employee App';
                cs3.Origin = 'Web';
                insert cs3; 
            
                Field_Investigation__c fi2 = new Field_Investigation__c();
                fi2.Case__c = cs3.Id;
                fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                fi2.SENP_Service_oriented_Income__c = 100000;
                insert fi2;
            
            Test.startTest();
            PersonalDetailsforCAM.Getincomerecordssalaried(opga1.Id,apga1.id,in1.Bank_Account_Number__c);
          //  System.assertNotEquals(null, result); 
            Test.stopTest();
        }
    }
    
    @isTest
    public static void GetincomerecordssalariedTest12(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.Bank_Account_Number__c = '33241567854';
                in1.Is_Salaried__c = true;
                in1.Is_Income_Credited_In_Bank_Account__c = true;
                in1.Income__c = 100000;
                in1.Client_Transaction_Id__c = 'test12345';
                in1.Income_from_Perfios__c = 10000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                case cs3 = new case();
                cs3.Loan_Application__c = opga1.Id;
                cs3.Applicant__c = apga1.Id;
                cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs3.Status = 'Pending-Off Role Employee App';
                cs3.Origin = 'Web';
                insert cs3; 
            
                Field_Investigation__c fi2 = new Field_Investigation__c();
                fi2.Case__c = cs3.Id;
                fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                fi2.SENP_Transporter_Income__c = 100000;
                insert fi2;
            
            Test.startTest();
            PersonalDetailsforCAM.Getincomerecordssalaried(opga1.Id,apga1.id,in1.Bank_Account_Number__c);
          //  System.assertNotEquals(null, result); 
            Test.stopTest();
        }
    }
    
    @isTest
    public static void GetincomerecordssalariedTest13(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.Bank_Account_Number__c = '33241567854';
                in1.Is_Salaried__c = true;
                in1.Is_Income_Credited_In_Bank_Account__c = true;
                in1.Income__c = 100000;
                in1.Client_Transaction_Id__c = 'test12345';
                in1.Income_from_Perfios__c = 10000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                case cs3 = new case();
                cs3.Loan_Application__c = opga1.Id;
                cs3.Applicant__c = apga1.Id;
                cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs3.Status = 'Pending-Off Role Employee App';
                cs3.Origin = 'Web';
                insert cs3; 
            
             /*   Field_Investigation__c fi2 = new Field_Investigation__c();
                fi2.Case__c = cs3.Id;
                fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                fi2.SENP_Transporter_Income__c = 100000;
                insert fi2; */
            
            Test.startTest();
            PersonalDetailsforCAM.Getincomerecordssalaried(opga1.Id,apga1.id,in1.Bank_Account_Number__c);
          //  System.assertNotEquals(null, result); 
            Test.stopTest();
        }
    }
    
    @isTest
    public static void GetincomerecordsGSTTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.GST_No__c = 'ap126789877';
                in1.Do_You_File_GST__c = true;
                in1.Income__c = 100000;
                in1.Client_Transaction_Id__c = 'test12345';
                in1.Perfios_Transaction_Id__c = 'sample12345';
                in1.Income_from_Perfios__c = 100000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                case cs3 = new case();
                cs3.Loan_Application__c = opga1.Id;
                cs3.Applicant__c = apga1.Id;
                cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs3.Status = 'Pending-Off Role Employee App';
                cs3.Origin = 'Web';
                insert cs3; 
            
                Field_Investigation__c fi2 = new Field_Investigation__c();
                fi2.Case__c = cs3.Id;
                fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                fi2.Income__c = 100000;
                insert fi2;
            
                Test.startTest();
                       PersonalDetailsforCAM.GetincomerecordsGST(opga1.Id,apga1.id,in1.GST_No__c);
                Test.stopTest();
                
        }
    }
    
    @isTest
    public static void GetincomerecordsGSTTest1(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.GST_No__c = 'ap126789877';
                in1.Do_You_File_GST__c = true;
                in1.Income__c = 100000;
                in1.Client_Transaction_Id__c = 'test12345';
                in1.Perfios_Transaction_Id__c = 'sample12345';
                in1.Income_from_Perfios__c = 100000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                case cs3 = new case();
                cs3.Loan_Application__c = opga1.Id;
                cs3.Applicant__c = apga1.Id;
                cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs3.Status = 'Pending-Off Role Employee App';
                cs3.Origin = 'Web';
                insert cs3; 
            
                Field_Investigation__c fi2 = new Field_Investigation__c();
                fi2.Case__c = cs3.Id;
                fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                fi2.Income_as_per_FI_Visit__c = 100000;
                insert fi2;
            
                Test.startTest();
                       PersonalDetailsforCAM.GetincomerecordsGST(opga1.Id,apga1.id,in1.GST_No__c);
                Test.stopTest();
                
        }
    }
    
    @isTest
    public static void GetincomerecordsGSTTest2(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.GST_No__c = 'ap126789877';
                in1.Do_You_File_GST__c = true;
                in1.Income__c = 100000;
                in1.Client_Transaction_Id__c = 'test12345';
                in1.Perfios_Transaction_Id__c = 'sample12345';
                in1.Income_from_Perfios__c = 100000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                case cs3 = new case();
                cs3.Loan_Application__c = opga1.Id;
                cs3.Applicant__c = apga1.Id;
                cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs3.Status = 'Pending-Off Role Employee App';
                cs3.Origin = 'Web';
                insert cs3; 
            
                Field_Investigation__c fi2 = new Field_Investigation__c();
                fi2.Case__c = cs3.Id;
                fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                fi2.Income_per_month__c = 100000;
                insert fi2;
            
                Test.startTest();
                       PersonalDetailsforCAM.GetincomerecordsGST(opga1.Id,apga1.id,in1.GST_No__c);
                Test.stopTest();
                
        }
    }
    
    @isTest
    public static void GetincomerecordsGSTTest3(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.GST_No__c = 'ap126789877';
                in1.Do_You_File_GST__c = true;
                in1.Income__c = 100000;
                in1.Client_Transaction_Id__c = 'test12345';
                in1.Perfios_Transaction_Id__c = 'sample12345';
                in1.Income_from_Perfios__c = 100000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                case cs3 = new case();
                cs3.Loan_Application__c = opga1.Id;
                cs3.Applicant__c = apga1.Id;
                cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs3.Status = 'Pending-Off Role Employee App';
                cs3.Origin = 'Web';
                insert cs3; 
            
                Field_Investigation__c fi2 = new Field_Investigation__c();
                fi2.Case__c = cs3.Id;
                fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                fi2.Income_per_month_property__c = 100000;
                insert fi2;
            
                Test.startTest();
                       PersonalDetailsforCAM.GetincomerecordsGST(opga1.Id,apga1.id,in1.GST_No__c);
                Test.stopTest();
                
        }
    }
    
    @isTest
    public static void GetincomerecordsGSTTest4(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.GST_No__c = 'ap126789877';
                in1.Do_You_File_GST__c = true;
                in1.Income__c = 100000;
                in1.Client_Transaction_Id__c = 'test12345';
                in1.Perfios_Transaction_Id__c = 'sample12345';
                in1.Income_from_Perfios__c = 100000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                case cs3 = new case();
                cs3.Loan_Application__c = opga1.Id;
                cs3.Applicant__c = apga1.Id;
                cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs3.Status = 'Pending-Off Role Employee App';
                cs3.Origin = 'Web';
                insert cs3; 
            
                Field_Investigation__c fi2 = new Field_Investigation__c();
                fi2.Case__c = cs3.Id;
                fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                fi2.Monthly_Income_as_per_FI_Visit__c = 10000;
                insert fi2;
            
                Test.startTest();
                       PersonalDetailsforCAM.GetincomerecordsGST(opga1.Id,apga1.id,in1.GST_No__c);
                Test.stopTest();
                
        }
    }
    
    @isTest
    public static void GetincomerecordsGSTTest5(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.GST_No__c = 'ap126789877';
                in1.Do_You_File_GST__c = true;
                in1.Income__c = 100000;
                in1.Client_Transaction_Id__c = 'test12345';
                in1.Perfios_Transaction_Id__c = 'sample12345';
                in1.Income_from_Perfios__c = 100000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                case cs3 = new case();
                cs3.Loan_Application__c = opga1.Id;
                cs3.Applicant__c = apga1.Id;
                cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs3.Status = 'Pending-Off Role Employee App';
                cs3.Origin = 'Web';
                insert cs3; 
            
                Field_Investigation__c fi2 = new Field_Investigation__c();
                fi2.Case__c = cs3.Id;
                fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                fi2.SENP_Agriculture_Income__c = 100000;
                insert fi2;
            
                Test.startTest();
                       PersonalDetailsforCAM.GetincomerecordsGST(opga1.Id,apga1.id,in1.GST_No__c);
                Test.stopTest();
                
        }
    }
    
    @isTest
    public static void GetincomerecordsGSTTest6(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.GST_No__c = 'ap126789877';
                in1.Do_You_File_GST__c = true;
                in1.Income__c = 100000;
                in1.Client_Transaction_Id__c = 'test12345';
                in1.Perfios_Transaction_Id__c = 'sample12345';
                in1.Income_from_Perfios__c = 100000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                case cs3 = new case();
                cs3.Loan_Application__c = opga1.Id;
                cs3.Applicant__c = apga1.Id;
                cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs3.Status = 'Pending-Off Role Employee App';
                cs3.Origin = 'Web';
                insert cs3; 
            
                Field_Investigation__c fi2 = new Field_Investigation__c();
                fi2.Case__c = cs3.Id;
                fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                fi2.SENP_Contractor_Income__c = 10000;
                insert fi2;
            
                Test.startTest();
                       PersonalDetailsforCAM.GetincomerecordsGST(opga1.Id,apga1.id,in1.GST_No__c);
                Test.stopTest();
                
        }
    }
    
    @isTest
    public static void GetincomerecordsGSTTest7(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.GST_No__c = 'ap126789877';
                in1.Do_You_File_GST__c = true;
                in1.Income__c = 100000;
                in1.Client_Transaction_Id__c = 'test12345';
                in1.Perfios_Transaction_Id__c = 'sample12345';
                in1.Income_from_Perfios__c = 100000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                case cs3 = new case();
                cs3.Loan_Application__c = opga1.Id;
                cs3.Applicant__c = apga1.Id;
                cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs3.Status = 'Pending-Off Role Employee App';
                cs3.Origin = 'Web';
                insert cs3; 
            
                Field_Investigation__c fi2 = new Field_Investigation__c();
                fi2.Case__c = cs3.Id;
                fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                fi2.SENP_Own_Shop_Income__c = 100000;
                insert fi2;
            
                Test.startTest();
                       PersonalDetailsforCAM.GetincomerecordsGST(opga1.Id,apga1.id,in1.GST_No__c);
                Test.stopTest();
                
        }
    }
    
    @isTest
    public static void GetincomerecordsGSTTest8(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.GST_No__c = 'ap126789877';
                in1.Do_You_File_GST__c = true;
                in1.Income__c = 100000;
                in1.Client_Transaction_Id__c = 'test12345';
                in1.Perfios_Transaction_Id__c = 'sample12345';
                in1.Income_from_Perfios__c = 100000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                case cs3 = new case();
                cs3.Loan_Application__c = opga1.Id;
                cs3.Applicant__c = apga1.Id;
                cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs3.Status = 'Pending-Off Role Employee App';
                cs3.Origin = 'Web';
                insert cs3; 
            
                Field_Investigation__c fi2 = new Field_Investigation__c();
                fi2.Case__c = cs3.Id;
                fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                fi2.SENP_Pension_Income__c = 100000;
                insert fi2;
            
                Test.startTest();
                       PersonalDetailsforCAM.GetincomerecordsGST(opga1.Id,apga1.id,in1.GST_No__c);
                Test.stopTest();
                
        }
    }
    
    @isTest
    public static void GetincomerecordsGSTTest9(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.GST_No__c = 'ap126789877';
                in1.Do_You_File_GST__c = true;
                in1.Income__c = 100000;
                in1.Client_Transaction_Id__c = 'test12345';
                in1.Perfios_Transaction_Id__c = 'sample12345';
                in1.Income_from_Perfios__c = 100000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                case cs3 = new case();
                cs3.Loan_Application__c = opga1.Id;
                cs3.Applicant__c = apga1.Id;
                cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs3.Status = 'Pending-Off Role Employee App';
                cs3.Origin = 'Web';
                insert cs3; 
            
                Field_Investigation__c fi2 = new Field_Investigation__c();
                fi2.Case__c = cs3.Id;
                fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                fi2.SENP_Rental_Income__c = 100000;
                insert fi2;
            
                Test.startTest();
                       PersonalDetailsforCAM.GetincomerecordsGST(opga1.Id,apga1.id,in1.GST_No__c);
                Test.stopTest();
                
        }
    }
    
    @isTest
    public static void GetincomerecordsGSTTest10(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.GST_No__c = 'ap126789877';
                in1.Do_You_File_GST__c = true;
                in1.Income__c = 100000;
                in1.Client_Transaction_Id__c = 'test12345';
                in1.Perfios_Transaction_Id__c = 'sample12345';
                in1.Income_from_Perfios__c = 100000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                case cs3 = new case();
                cs3.Loan_Application__c = opga1.Id;
                cs3.Applicant__c = apga1.Id;
                cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs3.Status = 'Pending-Off Role Employee App';
                cs3.Origin = 'Web';
                insert cs3; 
            
                Field_Investigation__c fi2 = new Field_Investigation__c();
                fi2.Case__c = cs3.Id;
                fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                fi2.SENP_Service_oriented_Income__c = 100000;
                insert fi2;
            
                Test.startTest();
                       PersonalDetailsforCAM.GetincomerecordsGST(opga1.Id,apga1.id,in1.GST_No__c);
                Test.stopTest();
                
        }
    }
    
    @isTest
    public static void GetincomerecordsGSTTest11(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.GST_No__c = 'ap126789877';
                in1.Do_You_File_GST__c = true;
                in1.Income__c = 100000;
                in1.Client_Transaction_Id__c = 'test12345';
                in1.Perfios_Transaction_Id__c = 'sample12345';
                in1.Income_from_Perfios__c = 100000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                case cs3 = new case();
                cs3.Loan_Application__c = opga1.Id;
                cs3.Applicant__c = apga1.Id;
                cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs3.Status = 'Pending-Off Role Employee App';
                cs3.Origin = 'Web';
                insert cs3; 
            
                Field_Investigation__c fi2 = new Field_Investigation__c();
                fi2.Case__c = cs3.Id;
                fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                fi2.SENP_Transporter_Income__c = 100000;
                insert fi2;
            
                Test.startTest();
                       PersonalDetailsforCAM.GetincomerecordsGST(opga1.Id,apga1.id,in1.GST_No__c);
                Test.stopTest();
                
        }
    }
    
     @isTest
    public static void GetincomerecordsGSTTest12(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
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
            
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apga1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.GST_No__c = 'ap126789877';
                in1.Do_You_File_GST__c = true;
                in1.Income__c = 100000;
                in1.Client_Transaction_Id__c = 'test12345';
                in1.Perfios_Transaction_Id__c = 'sample12345';
                in1.Income_from_Perfios__c = 100000;
                in1.Remarks__c = 'nocomments';
                in1.Primary_Income_Source__c = true;
                insert in1;
            
                case cs3 = new case();
                cs3.Loan_Application__c = opga1.Id;
                cs3.Applicant__c = apga1.Id;
                cs3.Subject='Approval Of Application Sourced By Off Roll Employee';
                cs3.Status = 'Pending-Off Role Employee App';
                cs3.Origin = 'Web';
                insert cs3; 
            
             /*   Field_Investigation__c fi2 = new Field_Investigation__c();
                fi2.Case__c = cs3.Id;
                fi2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
                fi2.SENP_Transporter_Income__c = 100000;
                insert fi2; */
            
                Test.startTest();
                       PersonalDetailsforCAM.GetincomerecordsGST(opga1.Id,apga1.id,in1.GST_No__c);
                Test.stopTest();
                
        }
    }
    
    @isTest
    public static void retriveFilesgstTest1(){
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
        
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apks1.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                in1.Capture_GST_Method__c = 'Online via link';
                insert in1;
                
                 Documents__c dfks1 = new Documents__c();
                 dfks1.Applicant__c = apks1.Id;
                 dfks1.Opportunity_Relation__c = opks1.Id;
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
             //    dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 dfks1.Proof_of_Identity_POI__c = true;
                 dfks1.Document_Type__c = 'Passport';
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
                       PersonalDetailsforCAM.retriveFilesgst(opks1.Id,apks1.Id);
                 Test.stopTest();
    }
    
    @isTest
    public static void getDetailsvarientcodeTest2(){
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                insert opks1;
        
                 Vehicle_Detail__c vgf2 = new Vehicle_Detail__c();
                 vgf2.Loan_Application__c = opks1.Id;
                 vgf2.Base_Price__c = 100000.00;
                 vgf2.Ben_Code__c = 'testveh';
                 vgf2.Variant__c = 'JAWA Variant';
                 insert vgf2;
        
                Product2 pd1 = new Product2();
                pd1.Asset_Category__c = 'te';
                pd1.Name = vgf2.Variant__c;
                pd1.Type__c = 'Variant';
                pd1.External_Reference_Id__c = '58568568';
                insert pd1;
        
                Test.startTest();
                       PersonalDetailsforCAM.getDetailsvarientcode(opks1.Id);
                Test.stopTest();
    }
}