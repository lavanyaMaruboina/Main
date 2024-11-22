/**
* Test class for CaptureStructureEMI
*/
@IsTest
public class CaptureStructureEMITest {
    
    @testSetup
    static void setup(){
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL CVO'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod123#@indusbank.com',MobilePhone = '9089078967');
        insert u;
        System.runAs(u) 
        {
            //create Oppty records
            List<Opportunity> opptyList = new List<Opportunity>();
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Name = 'VDR Test';
            opp.Product_Type__c = System.Label.Tractor;
            opptyList.add(opp);
            Opportunity opp2 = TestDataUtility.createTestOpportunity1(false);
            opp2.Name = 'VDR Negative Test';
            opp2.Product_Type__c = System.Label.Tractor;
            opp2.CloseDate = Date.today();
            opptyList.add(opp2);
            Opportunity opp3 = TestDataUtility.createTestOpportunity1(false);
            opp3.Name = 'Oppty 3';
            opp3.CloseDate = Date.today();
            opptyList.add(opp3);
            if(Schema.sObjectType.Opportunity.isCreateable()){
                insert opptyList;
            }
            
            Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
            dlNumberSetting.Name = System.Label.Tractor;
            dlNumberSetting.MDNField1__c ='AB';
            dlNumberSetting.MDNField2__c = 2.0;
            insert dlNumberSetting;
            
            //Create Deal_Number__c record for 'VDR Test'
            Deal_Number__c dl=new Deal_Number__c();
            dl.Loan_Application__c = opp.Id;
            dl.DNField1__c = dlNumberSetting.MDNField1__c;
            dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c.round());
            dl.Sub_Stage__c = 'RC Upload';
            insert dl;
            
            //Create Deal_Number__c record for 'VDR Negative Test'
            Deal_Number__c dl2=new Deal_Number__c();
            dl2.Loan_Application__c = opp2.Id;
            dl2.DNField1__c = dlNumberSetting.MDNField1__c;
            dl2.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c.round());
            dl2.Sub_Stage__c = 'Payment Request';
            insert dl2;
            
            //create Vehicle_Detail__c record
            List<Vehicle_Detail__c> vdList = new List<Vehicle_Detail__c>();
            Vehicle_Detail__c  vehicleDetail1 = TestDataUtility.createTestVehicleDetailForIbb(false, opp);
            vehicleDetail1.Deal_Number__c = dl.Id;
            vdList.add(vehicleDetail1);
            Vehicle_Detail__c  vehicleDetail2 = TestDataUtility.createTestVehicleDetailForIbb(false, opp2);
            vehicleDetail2.Deal_Number__c = dl2.Id;
            vdList.add(vehicleDetail2);
            if (Schema.sObjectType.Vehicle_Detail__c.isCreateable()){
                insert vdList;
            }
            
            //create Final_Term__c record
            List<Final_Term__c> ftList = new List<Final_Term__c>();
            Final_Term__c ft = new Final_Term__c();
            ft.CRM_IRR__c = 120;
            ft.Loan_Application__c = opp2.Id;
            ft.Holiday_period__c='30';
            ft.EMI_Amount__c= 10000;
            ft.FIwaiver_offAddress__c = 'Not Waived';
            ft.Installment_Type__c ='Structured';
            ft.Vehicle_Detail__c = vehicleDetail2.Id;
            ftList.add(ft);
            Final_Term__c ft2 = new Final_Term__c();
            ft2.CRM_IRR__c = 120;
            ft2.Loan_Application__c = opp3.Id;
            ft2.Holiday_period__c='30';
            ft2.EMI_Amount__c= 10000;
            ft2.FIwaiver_offAddress__c = 'Not Waived';
            ft2.Loan_Amount__c = '1500000345';
            ftList.add(ft2);
            if(Schema.sObjectType.Final_Term__c.isCreateable()){
                insert ftList;
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
            
            //Create Loan_Application_Transaction_History__c
            List<Loan_Application_Transaction_History__c> laptHistList = new List<Loan_Application_Transaction_History__c>();
            Loan_Application_Transaction_History__c lth1 = new Loan_Application_Transaction_History__c();
            lth1.Loan_Application_ID__c = opp.Id;
            //lth1.Name ='Vehicle Inspection and RC Check';
            lth1.Module__c = 'Pre Disbursement Check';
            lth1.Screen__c = 'Vehicle Inspection and RC Check';
            lth1.Module_Name__c = 'FI';
            lth1.Submitted_Flag__c = true;
            laptHistList.add(lth1);
            Loan_Application_Transaction_History__c lth2 = new Loan_Application_Transaction_History__c();
            lth2.Loan_Application_ID__c = opp.Id;
            lth2.Module__c = 'Post Sanction Checks and Documentation';
            lth2.Screen__c = 'Structured EMI';
            lth2.Module_Name__c = 'FI';
            lth2.Submitted_Flag__c = true;
            laptHistList.add(lth2);
            if(Schema.sObjectType.Loan_Application_Transaction_History__c.isCreateable()){
                insert laptHistList;
            }
            
            //Create Documents__c records
            List<Documents__c> docList = new List<Documents__c>();
            Documents__c doc1 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc1.Vehicle_Detail__c = vehicleDetail1.Id;
            doc1.Opportunity_Relation__c = opp.Id;
            doc1.Is_active__c = true;
            doc1.Document_Type__c = 'Chassis Number uploaded during verification';
            docList.add(doc1);
            if(Schema.sObjectType.Documents__c.isCreateable()){
                insert docList;
            }
            
            //Create Retry_Count__c records
            List<Retry_Count__c> rtCountList = new List<Retry_Count__c>();
            Retry_Count__c retryCount = new Retry_Count__c();
            retryCount.Service_Name__c = 'RC Limit Check';
            retryCount.Count__c = 0;
            retryCount.Loan_Application_Id__c = opp.Id;
            rtCountList.add(retryCount);
            if(Schema.sObjectType.Retry_Count__c.isCreateable()){
                insert rtCountList;
            }
            
            //Create Structered_EMI__c records
            List<Structered_EMI__c> semiList = new List<Structered_EMI__c>();
            Structered_EMI__c semi = new Structered_EMI__c();
            semi.From_Month__c = 1;
            semi.To_Month__c = 9;
            semi.EMI_Amount__c = 45000;
            semi.Number_of_Installments__c = 9;
            semi.Loan_Application__c = opp.Id;
            semi.Vehicle_Detail__c = vehicleDetail1.Id;
            semiList.add(semi);
            Structered_EMI__c semi2 = new Structered_EMI__c();
            semi2.From_Month__c = 5;
            semi2.To_Month__c = 9;
            semi2.EMI_Amount__c = 50000;
            semi2.Number_of_Installments__c = 4;
            semi2.Loan_Application__c = opp.Id;
            semiList.add(semi2);
            if(Schema.sObjectType.Structered_EMI__c.isCreateable()){
                insert semiList;
            }
        }
    }
    
    @IsTest
    public static void test_isFTStructuredType(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName = 'test_userprod123#@indusbank.com' AND IsActive = true LIMIT 1];
        System.runAs(u)
        {
            Opportunity opp =[Select Id, Name From Opportunity Where Name ='VDR Negative Test' LIMIt 1];
            
            Deal_Number__c dealNumberRec = [SELECT Id FROM Deal_Number__c where Loan_Application__c =:opp.Id LIMIT 1];
            
            Boolean ftsReturn = CaptureStructureEMI.isFTStructuredType(opp.Id,dealNumberRec.Id);
            System.debug('ftsReturn-'+ftsReturn);
           // System.assertEquals(true, ftsReturn);
            //negative
            Opportunity oppNeg =[Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
            Deal_Number__c dealNumberRecNeg = [SELECT Id FROM Deal_Number__c where Loan_Application__c =:oppNeg.Id LIMIT 1];

            Boolean ftsReturnNeg = CaptureStructureEMI.isFTStructuredType(oppNeg.Id,dealNumberRecNeg.Id);
            //System.assertEquals(false, ftsReturnNeg);
            System.debug('ftsReturnNeg-'+ftsReturnNeg);
            //negative 2
            try {
                Boolean ftsReturnNeg2 = CaptureStructureEMI.isFTStructuredType('yfydkhgkf','w21212');
                 System.debug('ftsReturnNeg2-'+ftsReturnNeg2);
                System.assertEquals(true, ftsReturnNeg2);
            } catch(Exception ex){
               // System.assert(ex.getMessage().contains('Invalid id'));
            }
        }        
        Test.stopTest();
    }
    
    @IsTest
    public static void test_getLADetails(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123#@indusbank.com' AND IsActive = true LIMIT 1];
        System.runAs(u)
        {
            Opportunity opp =[Select Id, Finance_Amount__c, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
            Opportunity oppRet = CaptureStructureEMI.getLADetails(opp.Id);
            System.assertNotEquals(null, oppRet);
            System.assertEquals(opp.Id, oppRet.Id);
            //negative
            try {
                Opportunity opptyNeg = CaptureStructureEMI.getLADetails('yfydkhgkf');
                System.assertEquals(null, opptyNeg);
            } catch(Exception ex){
                system.debug('error '+ ex.getMessage());
            }
            Test.stopTest();
        }
    }
    
    @IsTest
    public static void test_getFinalTermRecord(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123#@indusbank.com' AND IsActive = true LIMIT 1];
        Opportunity opp =[Select Id, Finance_Amount__c, Name From Opportunity Where Name ='VDR Negative Test' LIMIt 1];
        
        Deal_Number__c dealNumberRec = [SELECT Id FROM Deal_Number__c where Loan_Application__c=:opp.Id LIMIT 1];
        
        
        System.runAs(u)
        {
            Vehicle_Detail__c vdRec = [Select Id from Vehicle_Detail__c where Loan_Application__c=:opp.Id LIMIT 1];
            
            
            Final_Term__c ft = CaptureStructureEMI.getFinalTermRecord(opp.Id,dealNumberRec.Id,vdRec.Id,true);
            System.assertNotEquals(null, ft); 
            
            Final_Term__c ft2 = CaptureStructureEMI.getFinalTermRecord(opp.Id,dealNumberRec.Id,vdRec.Id,false);
            System.assertNotEquals(null, ft2); 
            
            //negative
            try {
                Final_Term__c ft1 = CaptureStructureEMI.getFinalTermRecord('yfydkhgkf','asa','asas',true);
                System.assertEquals(null, ft1);
            } catch(Exception ex){
                system.debug('error '+ ex.getMessage());
            }
        }
        Test.stopTest();
    }
        
    @IsTest
    public static void test_getFinalTermRecord2(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123#@indusbank.com' AND IsActive = true LIMIT 1];
        Opportunity opp =[Select Id, Finance_Amount__c, Name From Opportunity Where Name ='Oppty 3' LIMIt 1];
        
        Deal_Number__c dealNumberRec = [SELECT Id FROM Deal_Number__c LIMIT 1];
        
        System.runAs(u)
        {
            Vehicle_Detail__c vdRec = [Select Id from Vehicle_Detail__c LIMIT 1];
            Final_Term__c ft = CaptureStructureEMI.getFinalTermRecord(opp.Id,dealNumberRec.Id,vdRec.Id,false);
            System.assertNotEquals(null, ft); 
        }
        Test.stopTest();
    }
    
    @IsTest
    public static void test_getFirstMonthStructeredEMI(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123#@indusbank.com' AND IsActive = true LIMIT 1];
        Opportunity opp =[Select Id, Finance_Amount__c, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
        
        Deal_Number__c dealNumberRec = [SELECT Id FROM Deal_Number__c where Loan_Application__c=:opp.Id LIMIT 1];

        System.runAs(u)
        {
            Vehicle_Detail__c vdRec = [Select Id from Vehicle_Detail__c where Loan_Application__c=:opp.Id LIMIT 1];
            
            Structered_EMI__c semi = CaptureStructureEMI.getFirstMonthStructeredEMI(opp.Id,dealNumberRec.Id,vdRec.Id,true);
            System.assertNotEquals(null, semi);
            System.assertEquals(45000, semi.EMI_Amount__c);
            //negative
            try {
                Opportunity oppNeg =[Select Id, Name From Opportunity Where Name ='VDR Negative Test' LIMIt 1];
                Structered_EMI__c semNeg = CaptureStructureEMI.getFirstMonthStructeredEMI(oppNeg.Id,dealNumberRec.Id,vdRec.Id,true);
                System.assertEquals(null, semNeg);
            } catch(Exception ex){
                system.debug('error '+ ex.getMessage());
            }
        }
        Test.stopTest();
    }
    
    
    @IsTest
    public static void test_getStructeredEMIexceptFirst(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123#@indusbank.com' AND IsActive = true LIMIT 1];
        System.runAs(u)
        {
            Opportunity opp =[Select Id, Finance_Amount__c, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
            List<Structered_EMI__c> semiList = CaptureStructureEMI.getStructeredEMIexceptFirst(opp.Id,'','',true);
            System.assertNotEquals(null, semiList);
            //System.assertEquals(50000, semiList[0].EMI_Amount__c);
            //negative
            try {
                Opportunity oppNeg =[Select Id, Name From Opportunity Where Name ='VDR Negative Test' LIMIt 1];
                List<Structered_EMI__c> semiListNeg = CaptureStructureEMI.getStructeredEMIexceptFirst(oppNeg.Id,'','',true);
                System.assertEquals(new List<Structered_EMI__c>(), semiListNeg);
            } catch(Exception ex){
                System.assert(ex.getMessage().contains('Script-thrown exception'));
            }
        }
        Test.stopTest();
    }
    
    @IsTest
    public static void test_addupdateStructuredEMI(){
        List<Object> itemList = new List<Object>();
        Map<String, Object> itemMap1 = new Map<String, Object>();
        Map<String, Object> itemMap2 = new Map<String, Object>();
        Map<String, Object> itemMap3 = new Map<String, Object>();
        itemMap1.put('fromMonth', '2');
        itemMap2.put('fromMonth', 2);
        itemMap3.put('fromMonth', 2.0);
        itemMap1.put('toMonth', '5');
        itemMap2.put('toMonth', 5);
        itemMap3.put('toMonth', Double.valueOf(5));
        itemMap1.put('installments', '3');
        itemMap2.put('installments', 3);
        itemMap3.put('installments', Double.valueOf(3));
        itemMap1.put('emi', '3');
        itemMap2.put('emi', 3);
        itemMap3.put('emi', 3.0);
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123#@indusbank.com' AND IsActive = true LIMIT 1];
        System.runAs(u)
        {
            Opportunity opp =[Select Id, Finance_Amount__c, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
            itemList.add(itemMap1);
            itemList.add(itemMap2);
            itemList.add(itemMap3);
            String itemString = JSON.serialize(itemList);
             
            Vehicle_Detail__c vdRec = [Select Id from Vehicle_Detail__c LIMIT 1];
            
            Deal_Number__c dealNumberRec = [SELECT Id FROM Deal_Number__c where Loan_Application__c =:opp.Id LIMIT 1];

            Boolean addRet = CaptureStructureEMI.addupdateStructuredEMI(itemString, opp.Id, true,dealNumberRec.Id,vdRec.Id);
            System.assertEquals(true, addRet);
            
            List<Structered_EMI__c> stRecord = [Select ID from Structered_EMI__c LIMIT 1];
            List<Object> itemList1 = new List<Object>();
            Map<String, Object> itemMapTest = new Map<String, Object>();
            itemMapTest.put('sfId',stRecord[0].Id);
            itemList1.add(itemMapTest);
            String itemString1 = JSON.serialize(itemList1);
            Boolean addRet1 = CaptureStructureEMI.addupdateStructuredEMI(itemString1, opp.Id, true,dealNumberRec.Id,vdRec.id);
            //scen 2
            Opportunity opp2 =[Select Id, Name From Opportunity Where Name ='VDR Negative Test' LIMIt 1];
            Deal_Number__c dealNumberRec2 = [SELECT Id FROM Deal_Number__c where Loan_Application__c =:opp2.Id LIMIT 1];

            Boolean addRet2 = CaptureStructureEMI.addupdateStructuredEMI(itemString, opp2.Id, true,dealNumberRec2.Id,vdRec.Id);
            CaptureStructureEMI.updateStructuredEMI(itemString, opp2.Id);

            //negative
            try {
                List<Object> itemList2 = new List<Object>();
                Map<String, Object> itemMapTest1 = new Map<String, Object>();
                itemMapTest1.put('sfId',new List<String>{'test'});
                itemList2.add(itemMapTest1);
                String itemStringNeg = JSON.serialize(itemList2);
                Boolean addRetNeg = CaptureStructureEMI.addupdateStructuredEMI(itemStringNeg, opp.Id, true,'','');
            } catch(Exception ex){
                system.debug('error '+ ex.getMessage());
            }
        }
        Test.stopTest();
    }
    
    @IsTest
    public static void test_checkIfReadOnly(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123#@indusbank.com' AND IsActive = true LIMIT 1];
        System.runAs(u)
        {
            Opportunity opp =[Select Id, Finance_Amount__c, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
            Deal_Number__c dealNumberRec = [SELECT Id FROM Deal_Number__c where Loan_Application__c =:opp.Id LIMIT 1];

            Boolean checkRet = CaptureStructureEMI.checkIfReadOnly(opp.Id,dealNumberRec.id);
            //System.assertEquals(true, checkRet);
            //negative
            try {
                Opportunity oppNeg =[Select Id, Name From Opportunity Where Name ='VDR Negative Test' LIMIt 1];
                Deal_Number__c dealNumberRecNeg = [SELECT Id FROM Deal_Number__c where Loan_Application__c =:oppNeg.Id LIMIT 1];

                Boolean checkRetNeg = CaptureStructureEMI.checkIfReadOnly(oppNeg.Id,dealNumberRecNeg.Id);
                System.assertEquals(false, checkRetNeg);
            } catch(Exception ex){
                //System.assert(ex.getMessage().contains('Script-thrown exception'));
            }
        }
        Test.stopTest();
    }
}