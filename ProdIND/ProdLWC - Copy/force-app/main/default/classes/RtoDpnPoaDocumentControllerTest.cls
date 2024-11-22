@isTest 
public class RtoDpnPoaDocumentControllerTest {
    @testSetup
    static void setup(){
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod123@indusbank.com.uat',MobilePhone = '9089078967');
        insert u;
        //List<Account> accList=new List<Account>();
        System.runAs(u) 
        {
            Account accgrandParent=TestDataUtility.createTestAccount(false);
            accgrandParent.Type='PV';
            insert accgrandParent;
            
            Account accparent=TestDataUtility.createTestAccount(false);
            accparent.Type='PV';
            accparent.ParentId = accgrandParent.Id;
            insert accparent;
            
            Account acc=TestDataUtility.createTestAccount(false);
            acc.Type='PV';
            acc.ParentId = accparent.Id;
            insert acc;
            
            AccountTeamMember accTeam=TestDataUtility.createAccountTeamMember(false,'CVO');
            accTeam.AccountId=acc.Id;
            insert accTeam;
            
            AccountTeamMember accTeam1=TestDataUtility.createAccountTeamMember(false,'CVO');
            accTeam1.AccountId=accgrandParent.Id;
            insert accTeam1;
            
            
            List<Opportunity> opptyList = new List<Opportunity>();
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Name = 'VDR Test';
            opp.StageName='Post Sanction Checks and Documentation';
            opp.AccountId=acc.Id;
            opp.Product_Type__c='Passenger Vehicles';
            opptyList.add(opp);
            Opportunity opp2 = TestDataUtility.createTestOpportunity1(false);
            opp2.Name = 'VDR Negative Test';
            opp2.StageName='Post Sanction Checks and Documentation';
            //opp2.StageName='Pre Disbursement Check';
            opp2.Product_Type__c='Passenger Vehicles';
            opp2.CloseDate = Date.today();
            opptyList.add(opp2);
            Opportunity opp3 = TestDataUtility.createTestOpportunity1(false);
            opp3.Name = 'Oppty 3';
            // opp3.StageName='Pre Disbursement Check';
            opp3.CloseDate = Date.today();
            opptyList.add(opp3);
            if(Schema.sObjectType.Opportunity.isCreateable()){
                insert opptyList;
            }
            //Create Applicant__c Data
            List<Applicant__c> applicantList = new List<Applicant__c>();
            Applicant__c applicant1 = TestDataUtility.createTestApplicatnt1(false);
            applicant1.Opportunity__c = opp.Id;
            applicant1.Who_will_repay_the_loan__c = 'Borrower';
            applicant1.Scorecard_Decision__c = 'Light Red';
            applicantList.add(applicant1);
            Applicant__c applicant2 = TestDataUtility.createTestApplicatnt2(false);
            applicant2.Opportunity__c = opp.Id;
            applicantList.add(applicant2);
            if(Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicantList;
            }
            //create Vehicle_Detail__c record
            List<Vehicle_Detail__c> vdList = new List<Vehicle_Detail__c>();
            Vehicle_Detail__c  vehicleDetail = TestDataUtility.createTestVehicleDetailForIbb(false, opp);
            
            vdList.add(vehicleDetail);
            if (Schema.sObjectType.Vehicle_Detail__c.isCreateable()){
                insert vdList;
            }
            
            
            //Create Documents__c records
            List<Documents__c> docList = new List<Documents__c>();
            Documents__c doc1 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc1.Vehicle_Detail__c = vehicleDetail.Id;
            doc1.Opportunity_Relation__c = opp.Id;
            doc1.Is_active__c = true;
            doc1.Applicant__c=applicant1.Id;
            doc1.Name='RTO '+opp.Id;
            //doc1.Document_Type__c = 'RTO';
            docList.add(doc1);
            Documents__c doc2 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc2.Vehicle_Detail__c = vehicleDetail.Id;
            doc2.Opportunity_Relation__c = opp.Id;
            doc2.Is_active__c = true;
            doc2.Applicant__c=applicant1.Id;
            //doc2.Document_Type__c = 'DPN';
            docList.add(doc2);
            Documents__c doc4 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc4.Vehicle_Detail__c = vehicleDetail.Id;
            doc4.Opportunity_Relation__c = opp.Id;
            doc4.Is_active__c = true;
            doc4.Applicant__c=applicant1.Id;
            //doc4.Document_Type__c = 'Agreement Wrapper Booklet';
            docList.add(doc4);
            Documents__c doc5 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc5.Vehicle_Detail__c = vehicleDetail.Id;
            doc5.Opportunity_Relation__c = opp.Id;
            doc5.Is_active__c = true;
            doc5.Applicant__c=applicant1.Id;
            //doc5.Document_Type__c = 'Agreement 1st Schedule';
            docList.add(doc5);
            Documents__c doc6 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc6.Vehicle_Detail__c = vehicleDetail.Id;
            doc6.Opportunity_Relation__c = opp.Id;
            doc6.Is_active__c = true;
            doc6.Applicant__c=applicant1.Id;
            //doc6.Document_Type__c = 'Agreement 2nd Schedule';
            docList.add(doc6);
            Documents__c doc7 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc7.Vehicle_Detail__c = vehicleDetail.Id;
            doc7.Opportunity_Relation__c = opp.Id;
            doc7.Is_active__c = true;
            doc7.Applicant__c=applicant1.Id;
            //doc7.Document_Type__c = 'DPR'; 
            docList.add(doc7);
            if(Schema.sObjectType.Documents__c.isCreateable()){
                insert docList;
            }
            ContentVersion content=new ContentVersion(); 
            content.Title='Header_Picture1'; 
            content.PathOnClient='/' + content.Title + '.jpg'; 
            Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
            content.VersionData=bodyBlob; 
            content.origin = 'H';
            insert content;
            
            ContentDocumentLink contentlink=new ContentDocumentLink();
            contentlink.LinkedEntityId=docList[0].id;
            contentlink.ShareType= 'I';
            contentlink.ContentDocumentId =  [SELECT id, ContentDocumentId FROM ContentVersion where Id = :content.Id].ContentDocumentId;
            contentlink.Visibility = 'AllUsers'; 
            insert contentlink;
            
            //Create Loan_Application_Transaction_History__c
            List<Loan_Application_Transaction_History__c> laptHistList = new List<Loan_Application_Transaction_History__c>();
            Loan_Application_Transaction_History__c lth1 = new Loan_Application_Transaction_History__c();
            lth1.Loan_Application_ID__c = opp.Id;
            lth1.Module__c = 'Post Sanction Checks and Documentation';
            lth1.Screen__c = 'Vehicle Inspection and RC Check';
            lth1.Module_Name__c = 'FI';
            lth1.Submitted_Flag__c = true;
            laptHistList.add(lth1);
            
            Loan_Application_Transaction_History__c lth2 = new Loan_Application_Transaction_History__c();
            lth2.Loan_Application_ID__c = opp.Id;
            lth2.Module__c = 'Post Sanction Checks and Documentation';
            lth2.Screen__c = 'Security Mandate';
            lth2.Module_Name__c = 'FI';
            lth2.Submitted_Flag__c = true;
            laptHistList.add(lth2);
            
            Loan_Application_Transaction_History__c lth3 = new Loan_Application_Transaction_History__c();
            lth3.Loan_Application_ID__c = opp.Id;
            lth3.Module__c = 'Post Sanction Checks and Documentation';
            lth3.Screen__c = 'IHM';
            lth3.Module_Name__c = 'FI';
            lth3.Submitted_Flag__c = true;
            laptHistList.add(lth3);
            
            Loan_Application_Transaction_History__c lth4 = new Loan_Application_Transaction_History__c();
            lth4.Loan_Application_ID__c = opp.Id;
            lth4.Module__c = 'Post Sanction Checks and Documentation';
            lth4.Screen__c = 'Loan Agreement';
            lth4.Module_Name__c = 'FI';
            lth4.Submitted_Flag__c = true;
            laptHistList.add(lth4);
            
            Loan_Application_Transaction_History__c lth5 = new Loan_Application_Transaction_History__c();
            lth5.Loan_Application_ID__c = opp.Id;
            lth5.Module__c = 'Post Sanction Checks and Documentation';
            lth5.Screen__c = 'Repayment Mandate';
            lth5.Module_Name__c = 'FI';
            lth5.Submitted_Flag__c = true;
            laptHistList.add(lth5);
            
            Loan_Application_Transaction_History__c lth6 = new Loan_Application_Transaction_History__c();
            lth6.Loan_Application_ID__c = opp.Id;
            lth6.Module__c = 'Post Sanction Checks and Documentation';
            lth6.Screen__c = 'Additional Documents';
            lth6.Module_Name__c = 'FI';
            lth6.Submitted_Flag__c = true;
            laptHistList.add(lth6);
            
            Loan_Application_Transaction_History__c lth7 = new Loan_Application_Transaction_History__c();
            lth7.Loan_Application_ID__c = opp.Id;
            lth7.Module__c = 'Pre Disbursement Check';
            lth7.Screen__c = 'Additional Documents';
            lth7.Module_Name__c = 'FI';
            lth7.Submitted_Flag__c = false;
            laptHistList.add(lth7);
            
            Loan_Application_Transaction_History__c lth8 = new Loan_Application_Transaction_History__c();
            lth8.Loan_Application_ID__c = opp.Id;
            lth8.Module__c = 'Post Sanction Checks and Documentation';
            lth8.Screen__c = 'RTO, DPN, POA Documents Upload';
            lth8.Module_Name__c = 'FI';
            lth8.Submitted_Flag__c = false;
            laptHistList.add(lth8);
            
            Loan_Application_Transaction_History__c lth9 = new Loan_Application_Transaction_History__c();
            lth9.Loan_Application_ID__c = opp.Id;
            lth9.Module__c = 'Post Sanction Checks and Documentation';
            lth9.Screen__c = 'Structured EMI';
            lth9.Module_Name__c = 'FI';
            lth9.Submitted_Flag__c = true;
            laptHistList.add(lth9);
            
            Loan_Application_Transaction_History__c lth10 = new Loan_Application_Transaction_History__c();
            lth10.Loan_Application_ID__c = opp.Id;
            lth10.Module__c = 'Post Sanction Checks and Documentation';
            lth10.Screen__c = 'Invoice';
            lth10.Module_Name__c = 'FI';
            lth10.Submitted_Flag__c = true;
            laptHistList.add(lth10);
            
            if(Schema.sObjectType.Loan_Application_Transaction_History__c.isCreateable()){
                insert laptHistList;
            }
            
            Final_Term__c ft = new Final_Term__c();
            ft.Loan_Application__c = opp.Id;
            ft.Loan_Amount__c='100000';
            ft.Installment_Type__c = 'Structured';
            insert ft;
            
        }
    }
    
    @IsTest
    public static void test_getApplicantRecord(){
        test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try{
                Opportunity opp = [Select id, name from opportunity limit 1];
                Applicant__c app1 = RtoDpnPoaDocumentController.getApplicantRecord(opp.Id);
                System.assertNotEquals(null,app1);
                Applicant__c app2 = RtoDpnPoaDocumentController.getApplicantRecord(null);
                System.assertEquals(null,app2);
            }catch (AuraHandledException e){
                System.debug(e.getMessage());
            }
            test.stopTest();
        }        
    }
    @IsTest
    public static void updatePriorityFlagLoanAppTest(){
        test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try{
                Opportunity opp = [Select id, name from opportunity limit 1];
                String app1 = RtoDpnPoaDocumentController.updatePriorityFlagLoanApp(opp.Id);
                System.assertNotEquals(null,app1);
                String app2 = RtoDpnPoaDocumentController.updatePriorityFlagLoanApp(null);
                System.assertEquals(null,app2);
            }catch (AuraHandledException e){
                System.debug(e.getMessage());
            }
            test.stopTest();
        }        
    }
    @isTest
    public static void fetchDetailsTest(){
        Opportunity opp =[Select Id, Name,Applicant__c,Product_Type__c From Opportunity Where Name ='VDR Test' LIMIt 1];
        Applicant__c apsd2=[Select Id,Contact_number__c From Applicant__c Where Contact_number__c='9743514830' LIMIT 1];
        Applicant__c apsd=[Select Id,Contact_number__c,Who_will_repay_the_loan__c,Opportunity__c From Applicant__c Where Opportunity__c=:opp.Id limit 1];
        opp.Applicant__c=apsd.Id;
        opp.Product_Type__c = System.Label.Tractor;
        update opp;
        
        Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
        dlNumberSetting.Name = System.Label.Tractor;
        dlNumberSetting.MDNField1__c ='AB';
        dlNumberSetting.MDNField2__c =2;
        insert dlNumberSetting;
        system.debug('Deal Setting'+ dlNumberSetting);
        
        Deal_Number__c dl = new Deal_Number__c();
        dl.Loan_Application__c = opp.Id;
        dl.DNField1__c = dlNumberSetting.MDNField1__c;
        dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c);
        dl.Sub_Stage__c = 'RC Upload';
        //insert dl;
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            RtoDpnPoaDocumentController.WrapperData resultWrapper = RtoDpnPoaDocumentController.fetchDetails(opp.Id,dl.id);
            System.assertNotEquals(null,resultWrapper);
        }
        Test.stopTest();
    }
    @isTest
    public static void fetchDetailsTest_sucess2(){
        Opportunity opp =[Select Id, Name,Applicant__c From Opportunity Where Name ='VDR Test' LIMIt 1];
        Applicant__c apsd2=[Select Id,Contact_number__c From Applicant__c Where Contact_number__c='9743514830' LIMIT 1];
        opp.StageName = 'Pre Disbursement Check';
        opp.Product_Type__c = System.Label.Tractor;
        update opp;
        
        Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
        dlNumberSetting.Name = System.Label.Tractor;
        dlNumberSetting.MDNField1__c ='AB';
        dlNumberSetting.MDNField2__c =2;
        insert dlNumberSetting;
        system.debug('Deal Setting'+ dlNumberSetting);
        
        Deal_Number__c dl = new Deal_Number__c();
        dl.Loan_Application__c = opp.Id;
        dl.DNField1__c = dlNumberSetting.MDNField1__c;
        dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c);
        dl.Sub_Stage__c = 'RC Upload';
        //insert dl;
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            RtoDpnPoaDocumentController.WrapperData resultWrapper = RtoDpnPoaDocumentController.fetchDetails(opp.Id,dl.Id);
            System.assertNotEquals(null,resultWrapper);
        }
        Test.stopTest();
    }
    
     @isTest
    public static void fetchDetailsTest_sucess3(){
        Opportunity opp =[Select Id, Name,Applicant__c From Opportunity Where Name ='VDR Test' LIMIt 1];
        Applicant__c apsd2=[Select Id,Contact_number__c From Applicant__c Where Contact_number__c='9743514830' LIMIT 1];
        opp.StageName = 'Pre Disbursement Check';
        opp.Product_Type__c = System.Label.TwoWheeler;
        update opp;
        
        Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
        dlNumberSetting.Name = System.Label.TwoWheeler;
        dlNumberSetting.MDNField1__c ='AB';
        dlNumberSetting.MDNField2__c =2;
        insert dlNumberSetting;
        system.debug('Deal Setting'+ dlNumberSetting);
        
        Deal_Number__c dl = new Deal_Number__c();
        dl.Loan_Application__c = opp.Id;
        dl.DNField1__c = dlNumberSetting.MDNField1__c;
        dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c);
        dl.Sub_Stage__c = 'RC Upload';
        //insert dl;
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            RtoDpnPoaDocumentController.WrapperData resultWrapper = RtoDpnPoaDocumentController.fetchDetails(opp.Id,dl.Id);
            System.assertNotEquals(null,resultWrapper);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void submitDocumentsTest(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try{
                Opportunity opp =[Select Id, Name,StageName From Opportunity Where Name ='VDR Test' LIMIt 1];
                List<Documents__c> docList=[SELECT Id,Document_Type__c FROM Documents__c Where Document_Type__c='RTO' LIMIT 1];
                List<Final_Term__c> finalList = [Select Id, Loan_Amount__c from Final_Term__c LIMIT 1];
                
                opp.Product_Type__c = System.Label.Tractor;
                update opp;
                Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
                dlNumberSetting.Name = System.Label.Tractor;
                dlNumberSetting.MDNField1__c ='AB';
                dlNumberSetting.MDNField2__c =2;
                insert dlNumberSetting;
                system.debug('Deal Setting'+ dlNumberSetting);
                
                Deal_Number__c dl = new Deal_Number__c();
                dl.Loan_Application__c = opp.Id;
                dl.DNField1__c = dlNumberSetting.MDNField1__c;
                dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c);
                dl.Sub_Stage__c = 'RC Upload';
                //insert dl;
                String result = RtoDpnPoaDocumentController.submitDocuments(opp.Id,opp.StageName,JSON.serialize(docList),dl.Id);
                
                opp.stageName = 'Pre Disbursement Check';
                update opp;
                system.debug('opp stage --' + opp);
                String result1 = RtoDpnPoaDocumentController.submitDocuments(opp.Id,opp.StageName,JSON.serialize(docList),dl.Id);
                System.assertEquals('Success',result1);
            }catch(Exception e){
                System.debug('submitDocumentsTest-->'+e.getMessage());
            }
        }
        Test.stopTest();
    }
    @isTest
    public static void submitDocumentsTest_2(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try{
                Opportunity opp =[Select Id, Name,StageName From Opportunity Where Name ='VDR Test' LIMIt 1];
                List<Documents__c> docList=[SELECT Id,Document_Type__c FROM Documents__c Where Document_Type__c='RTO' LIMIT 1];
                List<Final_Term__c> finalList = [Select Id, Loan_Amount__c from Final_Term__c LIMIT 1];
                List<AccountTeamMember> accountTeamList = [Select Id, accountId, TeamMemberRole, UserId,account.Account_Type__c, account.parent.parentId from AccountTeamMember];
                System.debug('account team list --' + accountTeamList);
                opp.stageName = 'Pre Disbursement Check';
                opp.Product_Type__c = System.Label.Tractor;
                update opp;
                
                Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
                dlNumberSetting.Name = System.Label.Tractor;
                dlNumberSetting.MDNField1__c ='AB';
                dlNumberSetting.MDNField2__c =2;
                insert dlNumberSetting;
                system.debug('Deal Setting'+ dlNumberSetting);
                
                Deal_Number__c dl = new Deal_Number__c();
                dl.Loan_Application__c = opp.Id;
                dl.DNField1__c = dlNumberSetting.MDNField1__c;
                dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c);
                dl.Sub_Stage__c = 'RC Upload';
                insert dl;
                system.debug('opp stage --' + opp);
                String result1 = RtoDpnPoaDocumentController.submitDocuments(opp.Id,opp.StageName,JSON.serialize(docList),dl.Id);
                System.assertEquals('Success',result1);
            }catch(Exception e){
                System.debug(e.getMessage());
            }
        }
        Test.stopTest();
    }
    
    @isTest
    public static void createDocumentsTest(){
        try{
            Opportunity opp =[Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
            Vehicle_Detail__c vehDet = [Select Id, Variant__c From Vehicle_Detail__c Where Variant__c = 'ALSTILELE' LIMIT 1];
            Applicant__c apsd2=[Select Id,Contact_number__c From Applicant__c Where Contact_number__c='9743514830' LIMIT 1];
            Documents__c doc=[SELECT Id,Document_Type__c FROM Documents__c Where Document_Type__c='RTO' LIMIT 1];
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                RtoDpnPoaDocumentController.createDocuments(doc.Document_Type__c, vehDet.Id, apsd2.Id, opp.Id);
            }
            Test.stopTest();
        }
        catch(Exception e){
            ///System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void validateDocumentTest(){
        try{
            Opportunity oppObj = [Select Id From Opportunity LIMIT 1];
            Vehicle_Detail__c vehiDetails = [Select id From Vehicle_Detail__c Where Loan_Application__c =: oppObj.Id LIMIT 1];
            Applicant__c applicant = [Select Id From Applicant__c Where Applicant_Type__c =: System.Label.Borrower AND Opportunity__c =: oppObj.Id LIMIT 1];
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            System.runAs(u){
                RtoDpnPoaDocumentController.validateDocument(vehiDetails.Id, applicant.Id, oppObj.Id);
                RtoDpnPoaDocumentController.validateDocument('test',null,null);
            }
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
    @isTest
    public static void updateContentDocumentTest(){
        try{
            Opportunity oppObj = [Select Id From Opportunity LIMIT 1];
            Documents__c document = [Select Id,Document_Type__c From Documents__c Where Opportunity_Relation__c =: oppObj.id AND Document_Type__c LIKE '%RTO%' LIMIT 1];
            ContentDocumentLink conLink = [Select Id,ContentDocumentId From ContentDocumentLink Where LinkedEntityId =:document.Id LIMIT 1];
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            System.runAs(u){
                String returnValue = RtoDpnPoaDocumentController.updateContentDocument(conLink.ContentDocumentId, oppObj.Id, document.Id, document.Document_Type__c);
                System.assertEquals('Failure', returnValue);
            }
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
    @isTest
    public static void deleteContentDocumentTest(){
        try{
            Opportunity oppObj = [Select Id From Opportunity LIMIT 1];
            Documents__c document = [Select Id,Document_Type__c From Documents__c Where Opportunity_Relation__c =: oppObj.id AND Document_Type__c LIKE '%RTO%' LIMIT 1];
            ContentDocumentLink conLink = [Select Id,ContentDocumentId From ContentDocumentLink Where LinkedEntityId =:document.Id LIMIT 1];
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            System.runAs(u){
                RtoDpnPoaDocumentController.deleteContentDocument(document.Id, oppObj.Id, conLink.ContentDocumentId);
            }
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    @isTest
    public static void changeOwnerOfLATest(){
        try{
            Opportunity opp =[Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                RtoDpnPoaDocumentController.changeOwnerOfLA(opp.Id);
                RtoDpnPoaDocumentController.changeOwnerOfLA('test');
                RtoDpnPoaDocumentController.changeOwnerOfLA(null);
            }
            Test.stopTest();
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
    @isTest
    public static void getLoanAmountfromFOTest1(){
        try{     
            Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            insert opks1;
            opks1.Product_Type__c = System.Label.Tractor;
            
            Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
            dlNumberSetting.Name = System.Label.Tractor;
            dlNumberSetting.MDNField1__c ='AB';
            dlNumberSetting.MDNField2__c =2;
            insert dlNumberSetting;
            system.debug('Deal Setting'+ dlNumberSetting);
            
            Deal_Number__c dl = new Deal_Number__c();
            dl.Loan_Application__c = opks1.Id;
            dl.DNField1__c = dlNumberSetting.MDNField1__c;
            dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c);
            dl.Sub_Stage__c = 'RC Upload';
            insert dl;
            
            Final_Term__c fgd3 = new Final_Term__c();
            fgd3.CRM_IRR__c = 120;
            fgd3.Loan_Application__c = opks1.Id;
            fgd3.Holiday_period__c='30';
            fgd3.EMI_Amount__c= 10000;
            fgd3.Loan_Amount__c = null;
            insert fgd3;
            
            Test.startTest();
            RtoDpnPoaDocumentController.getLoanAmountfromFO(opks1.Id,dl.Id);
            RtoDpnPoaDocumentController.getLoanAmountfromFO('test','test1');
            RtoDpnPoaDocumentController.getLoanAmountfromFO(null,null);
            Test.stopTest();
            
        }catch(Exception e){
            // System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getValidApplicantsTest1(){
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
            apga1.Scorecard_Decision__c = 'Orange';
            apga1.In_Active_Applicant__c = false;
            insert apga1;
            
            Test.startTest();
            RtoDpnPoaDocumentController.getValidApplicants(opga1.Id);
            RtoDpnPoaDocumentController.getValidApplicants('test');
            RtoDpnPoaDocumentController.getValidApplicants(null);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void validateDocumentTest3(){
        try{
            Opportunity opds1 = new Opportunity();
            opds1.StageName = 'Qualification';
            opds1.CloseDate = Date.newInstance(2021, 1, 11);
            opds1.Name = 'testone';
            insert opds1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opds1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            apks1.Customer_Code__c = '12345';
            insert apks1;
            
            Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
            vc2.Loan_Application__c = opds1.Id;
            vc2.Base_Price__c = 100000.00;
            vc2.Ben_Code__c = 'testveh';
            vc2.Dealer_Sub_dealer_name__c = 'testsubdealer';
            insert vc2; 
            
            Documents__c dfks1 = new Documents__c();
            dfks1.Applicant__c = apks1.Id;
            dfks1.Opportunity_Relation__c = opds1.Id;
            dfks1.Vehicle_Detail__c = vc2.Id;
            dfks1.KYC_name__c = 'Aadhar';
            dfks1.Document_Side__c ='Back';
            dfks1.Aadhar_Source__c = 'ScanAadhar';
            dfks1.Name = 'Aadhar';
            dfks1.is_Active__c = true;
            dfks1.Document_Type__c = 'DPN';
            dfks1.Age__c = 25;
            dfks1.KYC_DOB__c = Date.newInstance(1994, 6, 23);
            insert dfks1;
            
            ContentVersion cvn1 = new ContentVersion();
            cvn1.PathOnClient = 'testpath1';
            cvn1.Title = 'testtitle1';
            cvn1.VersionData = Blob.valueOf('Test Content');
            cvn1.Document_Side_fileupload__c = 'Selfie';
            insert cvn1;
            
            ContentVersion testcd1 = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cvn1.Id];
            
            ContentDocumentLink cdlink1 = new ContentDocumentLink();
            cdlink1.Visibility = 'AllUsers';
            cdlink1.ShareType = 'V';
            cdlink1.LinkedEntityId = dfks1.Id;
            cdlink1.ContentDocumentId = testcd1.ContentDocumentId;
            insert cdlink1; 
            
            Test.startTest();
            RtoDpnPoaDocumentController.validateDocument(vc2.Id,apks1.Id,opds1.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void validateDocumentTest4(){
        try{
            Opportunity opds1 = new Opportunity();
            opds1.StageName = 'Qualification';
            opds1.CloseDate = Date.newInstance(2021, 1, 11);
            opds1.Name = 'testone';
            insert opds1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opds1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            apks1.Customer_Code__c = '12345';
            insert apks1;
            
            Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
            vc2.Loan_Application__c = opds1.Id;
            vc2.Base_Price__c = 100000.00;
            vc2.Ben_Code__c = 'testveh';
            vc2.Dealer_Sub_dealer_name__c = 'testsubdealer';
            insert vc2; 
            
            Documents__c dfks1 = new Documents__c();
            dfks1.Applicant__c = apks1.Id;
            dfks1.Opportunity_Relation__c = opds1.Id;
            dfks1.Vehicle_Detail__c = vc2.Id;
            dfks1.KYC_name__c = 'Aadhar';
            dfks1.Document_Side__c ='Back';
            dfks1.Aadhar_Source__c = 'ScanAadhar';
            dfks1.Name = 'Aadhar';
            dfks1.is_Active__c = true;
            dfks1.Document_Type__c = 'RTO';
            dfks1.Age__c = 25;
            dfks1.KYC_DOB__c = Date.newInstance(1994, 6, 23);
            insert dfks1;
            
            ContentVersion cvn1 = new ContentVersion();
            cvn1.PathOnClient = 'testpath1';
            cvn1.Title = 'testtitle1';
            cvn1.VersionData = Blob.valueOf('Test Content');
            cvn1.Document_Side_fileupload__c = 'Selfie';
            insert cvn1;
            
            ContentVersion testcd1 = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cvn1.Id];
            
            ContentDocumentLink cdlink1 = new ContentDocumentLink();
            cdlink1.Visibility = 'AllUsers';
            cdlink1.ShareType = 'V';
            cdlink1.LinkedEntityId = dfks1.Id;
            cdlink1.ContentDocumentId = testcd1.ContentDocumentId;
            insert cdlink1; 
            
            Test.startTest();
            RtoDpnPoaDocumentController.validateDocument(vc2.Id,apks1.Id,opds1.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void allDealClosedTest(){
        try{
            Opportunity opds1 = new Opportunity();
            opds1.StageName = 'Qualification';
            opds1.CloseDate = Date.newInstance(2021, 1, 11);
            opds1.Name = 'testone';
            insert opds1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opds1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            apks1.Customer_Code__c = '12345';
            insert apks1;
            
            Loan_Application_Transaction_History__c loanAppTranRec = new Loan_Application_Transaction_History__c();
            loanAppTranRec.Loan_Application_ID__c = opds1.Id;
            loanAppTranRec.Submitted_Flag__c = false;
            loanAppTranRec.Module__c = 'Test';
            insert loanAppTranRec;
            
            Test.startTest();
            RtoDpnPoaDocumentController.allDealClosed(opds1.Id,loanAppTranRec.Module__c);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
}