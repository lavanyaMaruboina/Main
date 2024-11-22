@isTest
public class securityMandateTest{
    
    @testSetup
    static void testDataSetup(){
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL CVO'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod2024@indusbank.com',MobilePhone = '9089078967');
        insert u;
        
        Profile p1 = [SELECT Id FROM Profile WHERE Name='IBL Operation Head'];
        User u1 = new User(Alias = 'standt23', Email='standarduser23@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p1.Id,Maker_Id__c='1256',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod13@indusbank.com',MobilePhone = '9089078967');
        insert u1;
        
        
        System.runAs(u) 
        {
            //create Oppty records
            List<Opportunity> opptyList = new List<Opportunity>();
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Name = 'VDR Test';
            opptyList.add(opp);
            Opportunity opp2 = TestDataUtility.createTestOpportunity1(false);
            opp2.Name = 'VDR Negative Test';
            opp2.Product_Type__c = 'Tractor';
            opp2.CloseDate = Date.today();
            opptyList.add(opp2);
            Opportunity opp3 = TestDataUtility.createTestOpportunity1(false);
            opp3.Name = 'Oppty 3';
            opp3.CloseDate = Date.today();
            opptyList.add(opp3);
            Opportunity opp4 = TestDataUtility.createTestOpportunity1(false);
            opp4.Name='opp4';
            opp4.All_Cheques_are_from_Same_bank__c = true;
            opp4.CVO_Accepts_SPDC_Documents__c = 'cvo';
            opp4.CVO_Remarks_SPDC__c = 'remarks';
            opp4.Number_of_SPDC_collected__c = 25;
            opptyList.add(opp4);
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
            
            List<Deal_Number_Setting__c> settings = new List<Deal_Number_Setting__c>();
            settings.add(new Deal_Number_Setting__c(Name = 'Passenger Vehicles', MDNField1__c = 'AA', MDNField2__c = 1));
            settings.add(new Deal_Number_Setting__c(Name = 'Tractor', MDNField1__c = 'AA', MDNField2__c = 1));
            settings.add(new Deal_Number_Setting__c(Name = 'Two Wheeler', MDNField1__c = 'AA', MDNField2__c = 1));
            insert settings;
            
            Deal_Number__c dl=new Deal_Number__c();
            dl.Loan_Application__c = opp.Id;
            dl.DNField1__c = settings.get(0).MDNField1__c;
            dl.DNField2__c = String.valueOf(settings.get(0).MDNField2__c.round());
           // dl.Sub_Stage__c = 'test'; 
            insert dl;
            
            Deal_Number__c dl2=new Deal_Number__c();
            dl2.Loan_Application__c = opp2.Id;
            dl2.DNField1__c = settings.get(1).MDNField1__c;
            dl2.DNField2__c = String.valueOf(settings.get(1).MDNField2__c.round());
            //dl2.Sub_Stage__c = 'test'; 
            insert dl2;
            
            //create Vehicle_Detail__c record
            List<Vehicle_Detail__c> vdList = new List<Vehicle_Detail__c>();
            Vehicle_Detail__c  vehicleDetail = TestDataUtility.createTestVehicleDetailForIbb(false, opp);
            vdList.add(vehicleDetail);
            
            Vehicle_Detail__c  vehicleDetail2 = TestDataUtility.createTestVehicleDetailForIbb(false, opp);
            vehicleDetail2.Deal_Number__c = dl2.Id;
            vdList.add(vehicleDetail2);
            if (Schema.sObjectType.Vehicle_Detail__c.isCreateable()){
                insert vdList;
            }
            
            
            //Create Documents__c records
            List<Documents__c> docList = new List<Documents__c>();
            Documents__c doc1 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc1.Vehicle_Detail__c = vehicleDetail.Id;
            doc1.Opportunity_Relation__c = opp.Id;
            doc1.Is_active__c = true;
            doc1.Document_Type__c = 'Cheques SPDC';
            docList.add(doc1);
            Documents__c doc2 = docList.get(0);
            Documents__c doc3 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc3.Opportunity_Relation__c = opp.Id;
            doc3.Cheque_legible__c ='chequeLegible';
            doc3.Cheque_Number__c = 3;
            doc3.Remarks__c ='chequeRemarks';
            docList.add(doc3);
            Documents__c doc4 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc4.Opportunity_Relation__c = opp.Id;
            doc4.Name = 'list1';
            doc4.Cheque_Number__c= 2.0;
            docList.add(doc4);
            if(Schema.sObjectType.Documents__c.isCreateable()){
                insert docList;
            }
            //Create Loan_Application_Transaction_History__c
            List<Loan_Application_Transaction_History__c> laptHistList = new List<Loan_Application_Transaction_History__c>();
            Loan_Application_Transaction_History__c lth1 = new Loan_Application_Transaction_History__c();
            lth1.Loan_Application_ID__c = opp.Id;
            lth1.Name ='RTO, DPN, POA Documents Upload';
            lth1.Module__c = 'Post Sanction Checks and Documentation';
            lth1.Screen__c = 'RTO, DPN, POA Documents Upload';
            lth1.Module_Name__c = 'FI';
            lth1.Submitted_Flag__c = true;
            lth1.Deal_Number__c = dl.Id;
            laptHistList.add(lth1); 
            
            Loan_Application_Transaction_History__c lth2 = new Loan_Application_Transaction_History__c();
            lth2.Loan_Application_ID__c = opp.Id;
            lth2.Name ='Security Mandate';
            lth2.Module__c = 'Post Sanction Checks and Documentation';
            lth2.Screen__c = 'Security Mandate';
            lth2.Module_Name__c = 'FI';
            lth2.Submitted_Flag__c = true;
            lth2.Deal_Number__c = dl2.Id;
            laptHistList.add(lth2);
            if(Schema.sObjectType.Loan_Application_Transaction_History__c.isCreateable()){
                insert laptHistList;
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
            
            SecurityMandate.chequeWrapper obj = new SecurityMandate.chequeWrapper();
            obj.chequeLegible = '';
            obj.chequeNo = 0;
            obj.chequePreview = '';
            obj.chequeRemarks = '';
            obj.chequeSeq = '';
            obj.docId = '';
            obj.id = '';
        }
    }
    @IsTest
    public static String test_getDocDetails(){
        try{
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2024@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Deal_Number__c deal = [SELECT id FROM Deal_Number__c LIMIT 1]; 
                Opportunity opp = [Select id, name from opportunity limit 1];
                string doc1 = SecurityMandate.getDocDetails(opp.Id, deal.Id);
                System.assertNotEquals(null,'doc1');
            }
            User u1 = [SELECT Id,usertype FROM User WHERE UserName='test_userprod13@indusbank.com' AND IsActive = true LIMIT 1]; 
            Opportunity opp = [Select id, name from opportunity limit 1];
            System.runAs(u1){
                Deal_Number__c deal = [SELECT id FROM Deal_Number__c LIMIT 1]; 
                string doc1 = SecurityMandate.getDocDetails(opp.Id, deal.Id);  
                //System.assertEquals(null, repayment2);
            }
            Test.stopTest();
            
        }catch(Exception e)
        {
            system.debug('error '+ e.getMessage());
        }
        return 'success';
    }
    
    @IsTest
    public static String test_getDocDetails2(){
        try{
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2024@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity opp = [Select id, name from opportunity WHERE Product_Type__c= 'Tractor' limit 1];
            	Deal_Number__c deal = [SELECT id FROM Deal_Number__c WHERE Loan_Application__c =:opp.Id LIMIT 1]; 
                string doc1 = SecurityMandate.getDocDetails(opp.Id, deal.Id);
                System.assertNotEquals(null,'doc1');
            }
            Test.stopTest();            
        }catch(Exception e)
        {
            system.debug('error '+ e.getMessage() + ' - '+e.getLineNumber());
        }
        return 'success';
    }
    
    @IsTest  
    public static ProductTypeBasedOnCheque__mdt test_getChequeData()
    {
        try{
            test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2024@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity opp = [Select id,Product_Type__c, name from opportunity limit 1];
                ProductTypeBasedOnCheque__mdt metaData = SecurityMandate.getChequeData(opp.Product_Type__c); 
                System.assertNotEquals(null,metaData);
                
            }
            User u1 = [SELECT Id,usertype FROM User WHERE UserName='test_userprod13@indusbank.com' AND IsActive = true LIMIT 1]; 
            Opportunity opp = [Select id,Product_Type__c, name from opportunity limit 1];
            System.runAs(u1){
                
                ProductTypeBasedOnCheque__mdt metaData = SecurityMandate.getChequeData('@#$%^'); 
            }
            
            
            test.stopTest();
        }
        catch(Exception e){
            
        }
        return null;
    }
    
    @IsTest
    public static String test_getApplicantData(){
        try{
            test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2024@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity opp = [Select id, name from opportunity limit 1];
                Applicant__c app1 = SecurityMandate.getApplicantData(opp.Id);
                System.assertNotEquals(null,app1);
                Applicant__c app2 = SecurityMandate.getApplicantData(null);
                System.assertEquals(null,app2);
           	}
            User u1 = [SELECT Id,usertype FROM User WHERE UserName='test_userprod13@indusbank.com' AND IsActive = true LIMIT 1]; 
            Opportunity opp = [Select id,Product_Type__c, name from opportunity limit 1];
            System.runAs(u1){
                Applicant__c app2 = SecurityMandate.getApplicantData('@#$%^'); 
            }
            test.stopTest();
        }
        catch (Exception e){
            System.debug(e.getMessage());
        }  
        
        return 'success';
    }
    
    @IsTest 
    public static Opportunity test_getLADetails(){
        try{
            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2024@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity opp = [Select id, name from opportunity limit 1];
                Deal_Number__c deal = [SELECT id FROM Deal_Number__c LIMIT 1]; 
                String oppRec = SecurityMandate.getLADetails(opp.Id, deal.Id); 
                System.assertNotEquals(null,oppRec);
            }
            User u1 = [SELECT Id,usertype FROM User WHERE UserName='test_userprod13@indusbank.com' AND IsActive = true LIMIT 1]; 
            Opportunity opp = [Select id, name from opportunity limit 1];    
            System.runAs(u1){
                Deal_Number__c deal = [SELECT id FROM Deal_Number__c LIMIT 1]; 
                String oppRec = SecurityMandate.getLADetails('#$%^', deal.Id);
                
            }
            Test.stopTest();
             return null;
        }catch(Exception e){
            return null;
        } 
    }
    @IsTest 
    public static void test_saveOrUpdateLoanApplication(){
        test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2024@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try{
                List<Object> itemList = new List<Object>();
                Opportunity opp = [Select id, name from opportunity where Name ='VDR Test' limit 1];
                List<Documents__c> docList = [Select Id from Documents__c];
                Map<String, Object> itemMap1 = new Map<String, Object>();
                itemMap1.put('docId', docList[0].id);
                itemMap1.put('chequeLegible', 'yes');
                itemMap1.put('chequeNo',2.0);
                itemMap1.put('chequeRemarks','sfdfs');
                itemList.add(itemMap1);
                String itemString = JSON.serialize(itemList);
                Deal_Number__c deal = [SELECT id FROM Deal_Number__c LIMIT 1]; 
                SecurityMandate.saveOrUpdateLoanApplication(opp.id,True,3,'yes','cvo remarks', itemString ,'Post Sanction Checks and Documentation', true, deal.Id); 
            }catch (AuraHandledException e){
                system.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        test.stopTest();
    }
    
    @IsTest 
    public static void test_saveOrUpdateLoanApplication2(){
        test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2024@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try{
                List<Object> itemList = new List<Object>();
                Opportunity opp = [Select id, name from opportunity where Product_Type__c ='Tractor' limit 1];
                List<Documents__c> docList = [Select Id from Documents__c];
                Map<String, Object> itemMap1 = new Map<String, Object>();
                itemMap1.put('docId', docList[0].id);
                itemMap1.put('chequeLegible', 'yes');
                itemMap1.put('chequeNo',2.0);
                itemMap1.put('chequeRemarks','sfdfs');
                itemList.add(itemMap1);
                String itemString = JSON.serialize(itemList);
                Deal_Number__c deal = [SELECT id FROM Deal_Number__c WHERE Loan_Application__c =: opp.Id LIMIT 1]; 
                SecurityMandate.saveOrUpdateLoanApplication(opp.id,True,3,'yes','cvo remarks', itemString ,'Post Sanction Checks and Documentation', true, deal.Id); 
            }catch (AuraHandledException e){
                system.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        test.stopTest();
    }
    
    @IsTest
    public static void test_deleteDocRecord(){
        test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2024@indusbank.com' AND IsActive = true LIMIT 1]; 
        List<Documents__c> docList = [Select Id from Documents__c];
        System.runAs(u) 
        {
            try{
                List<Object> itemList = new List<Object>();
                List<Object> itemList1 = new List<Object>();
                Opportunity opp = [Select id, name from opportunity limit 1];
                Map<String, Object> itemMap1 = new Map<String, Object>();
                itemMap1.put('docId', docList[0].id);
                itemMap1.put('chequeLegible', 'yes');
                itemMap1.put('chequeNo','2.0');
                itemMap1.put('chequeRemarks','sfdfs');
                itemMap1.put('chequePreview','done');
                itemMap1.put('chequeUnique','@bfcgd');
                itemList.add(itemMap1);
                String itemString = JSON.serialize(itemList);
                
                Map<String, Object> itemMap2 = new Map<String, Object>();
                itemMap2.put('docId', docList[1].id);
                itemMap2.put('chequeLegible', 'yes');
                itemMap2.put('chequeNo','2.0');
                itemMap2.put('chequeRemarks','sfdfs');
                itemMap2.put('chequePreview','done');
                itemMap2.put('chequeUnique','@bfcgd');
                itemList1.add(itemMap2);
                String itemString1 = JSON.serialize(itemList1);
                Deal_Number__c deal = [SELECT id FROM Deal_Number__c LIMIT 1]; 
                SecurityMandate.deleteDocRecord(opp.id,itemString,itemString1, deal.Id); 
            }catch (AuraHandledException e){
                system.assertEquals('Script-thrown exception', e.getMessage());
            }	
        }
        test.stopTest();
        
    }
    
    @IsTest
    public static void test_deleteDocRecord2(){
        test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2024@indusbank.com' AND IsActive = true LIMIT 1]; 
        List<Documents__c> docList = [Select Id from Documents__c];
        System.runAs(u) 
        {
            try{
                List<Object> itemList = new List<Object>();
                List<Object> itemList1 = new List<Object>();
                Opportunity opp = [Select id, name from opportunity WHERE Product_Type__c = 'Tractor' limit 1];
                Map<String, Object> itemMap1 = new Map<String, Object>();
                itemMap1.put('docId', docList[0].id);
                itemMap1.put('chequeLegible', 'yes');
                itemMap1.put('chequeNo','2.0');
                itemMap1.put('chequeRemarks','sfdfs');
                itemMap1.put('chequePreview','done');
                itemMap1.put('chequeUnique','@bfcgd');
                itemList.add(itemMap1);
                String itemString = JSON.serialize(itemList);
                
                Map<String, Object> itemMap2 = new Map<String, Object>();
                itemMap2.put('docId', docList[1].id);
                itemMap2.put('chequeLegible', 'yes');
                itemMap2.put('chequeNo','2.0');
                itemMap2.put('chequeRemarks','sfdfs');
                itemMap2.put('chequePreview','done');
                itemMap2.put('chequeUnique','@bfcgd');
                itemList1.add(itemMap2);
                String itemString1 = JSON.serialize(itemList1);
                Deal_Number__c deal = [SELECT id FROM Deal_Number__c WHERE Loan_Application__c =: opp.Id LIMIT 1]; 
                SecurityMandate.deleteDocRecord(opp.id,itemString,itemString1, deal.Id); 
            }catch (AuraHandledException e){
                system.assertEquals('Script-thrown exception', e.getMessage());
            }	
        }
        test.stopTest();
        
    }
    
    @IsTest
    Public static void test_checkIfReadOnly(){
        try{
            test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2024@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                
                Opportunity oppRec = [Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
                Loan_Application_Transaction_History__c loanAppHis = [Select Id, Submitted_Flag__c, Name, Screen__c, Module__c
                                                                      From Loan_Application_Transaction_History__c Where 
                                                                      Loan_Application_ID__c =: oppRec.Id LIMIT 1];
                loanAppHis.Name = 'Security Mandate';
                loanAppHis.Screen__c = 'Security Mandate';
                loanAppHis.Module__c = 'Pre Disbursement Check';
                update loanAppHis; 
                Deal_Number__c deal = [SELECT id FROM Deal_Number__c LIMIT 1]; 
                Boolean result1 = SecurityMandate.checkIfReadOnly(oppRec.id, deal.Id); 
                System.assertEquals(loanAppHis.Submitted_Flag__c,result1);
                Boolean result2 = SecurityMandate.checkIfReadOnly(null, null); 
                System.assertEquals(false, result2);
                
            }
           
            test.stopTest();
        }
        catch (AuraHandledException e){
            System.debug(e.getMessage());
        }
    }
    
        @IsTest
    Public static void test_isSecurityMandateSubmitted(){
        try{
            test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2024@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                
                Opportunity oppRec = [Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
                Loan_Application_Transaction_History__c loanAppHis = [Select Id, Submitted_Flag__c, Name, Screen__c, Module__c
                                                                      From Loan_Application_Transaction_History__c Where 
                                                                      Loan_Application_ID__c =: oppRec.Id LIMIT 1];
                loanAppHis.Name = 'Security Mandate';
                loanAppHis.Screen__c = 'Security Mandate';
                loanAppHis.Module__c = 'Post Sanction Checks and Documentation';
                update loanAppHis; 
                Deal_Number__c deal = [SELECT id FROM Deal_Number__c LIMIT 1]; 
                Boolean result1 = SecurityMandate.isSecurityMandateSubmitted(oppRec.id, deal.Id); 
                System.assertEquals(loanAppHis.Submitted_Flag__c,result1);
                Boolean result2 = SecurityMandate.checkIfReadOnly(null, null); 
                System.assertEquals(false, result2);
                
            }
           
            test.stopTest();
        }
        catch (AuraHandledException e){
            System.debug(e.getMessage());
        }
    }

    @IsTest
    Public static void test_checkIFRTOISSubmitted(){
        try{
            test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2024@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
              Opportunity oppRec = [Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
                List<Loan_Application_Transaction_History__c> loanAppHis = [Select Id, Submitted_Flag__c, Name, Screen__c, Module__c
                                                                            From Loan_Application_Transaction_History__c Where 
                                                                            Loan_Application_ID__c =: oppRec.Id ];
                system.debug('loanAppHis--'+loanAppHis);
                Deal_Number__c deal = [SELECT id FROM Deal_Number__c LIMIT 1]; 
                String result1 = SecurityMandate.checkIFRTOISSubmitted(oppRec.id, deal.Id); 
                System.assertNotEquals(null,result1);
                String result2 = SecurityMandate.checkIFRTOISSubmitted(null, null); 
                System.assertNotEquals(null, result2);
                
            }
            User u1 = [SELECT Id,usertype FROM User WHERE UserName='test_userprod13@indusbank.com' AND IsActive = true LIMIT 1]; 
            Opportunity oppRec = [Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
            List<Loan_Application_Transaction_History__c> loanAppHis = [Select Id, Submitted_Flag__c, Name, Screen__c, Module__c
                                                                        From Loan_Application_Transaction_History__c Where 
                                                                        Loan_Application_ID__c =: oppRec.Id ];
            Deal_Number__c deal = [SELECT id FROM Deal_Number__c LIMIT 1]; 
            System.runAs(u1){
                 String result1 = SecurityMandate.checkIFRTOISSubmitted(oppRec.id, deal.Id);
            }
            test.stopTest();
        }
        catch(Exception e){
            system.debug(e.getMessage());
        }
        
    }
    
    @isTest
    public static void test_getContentVersion(){
        try{
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2024@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
               	ContentDocument con = [Select Id from ContentDocument LIMIT 1];
                 List<ContentVersion> conversionList = SecurityMandate.getContentVersion(con.Id);
            }
        }catch(Exception e){
            system.debug(e.getMessage());
        }
    }
    
    @isTest
    public static void test_updateDealNumber(){
        try{
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2024@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Deal_Number__c deal = [SELECT id FROM Deal_Number__c LIMIT 1]; 
               	SecurityMandate.updateDealNumber(deal.Id, true,true,true);
            }
        }catch(Exception e){
            system.debug(e.getMessage());
        }
    }
    
    @isTest
    public static void test_updateDealNumberNegative(){
        try{
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2024@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Deal_Number__c deal = [SELECT id FROM Deal_Number__c LIMIT 1]; 
               	SecurityMandate.updateDealNumber('', true,true,true);
            }
        }catch(Exception e){
            system.debug(e.getMessage());
        }
    }
    
    @isTest
    public static void test_getDealNumberDetails(){
        try{
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2024@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Deal_Number__c deal = [SELECT id FROM Deal_Number__c LIMIT 1]; 
               	SecurityMandate.getDealNumberDetails(deal.Id);
            }
        }catch(Exception e){
            system.debug(e.getMessage());
        }
    }
    
    @isTest
    public static void test_getDealNumberDetailsNegative(){
        try{
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod2024@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Deal_Number__c deal = [SELECT id FROM Deal_Number__c LIMIT 1]; 
               	SecurityMandate.getDealNumberDetails(null);
            }
        }catch(Exception e){
            //System.assertEquals('script-thrown exception', e.getMessage());
        }
    }
    
    
    
}