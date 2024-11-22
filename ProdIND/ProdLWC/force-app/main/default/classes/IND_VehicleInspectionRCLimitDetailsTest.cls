/**
* Test class for IND_VehicleInspectionRCLimitDetails
*/
@IsTest
public class IND_VehicleInspectionRCLimitDetailsTest {
    @testSetup
    static void setup(){        
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL CVO'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod123@indusbank1.com',MobilePhone = '9089078967');
        insert u;
        System.runAs(u) 
        {
            //create Oppty records
            List<Opportunity> opptyList = new List<Opportunity>();
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Name = 'VDR Test';
            opp.Product_Type__c = 'Tractor';
            opptyList.add(opp);
            Opportunity opp2 = TestDataUtility.createTestOpportunity1(false);
            opp2.Name = 'VDR Negative Test';
            opp2.CloseDate = Date.today();
            opptyList.add(opp2);
            Opportunity opp3 = TestDataUtility.createTestOpportunity1(false);
            opp3.Name = 'Oppty 3';
            opp3.CloseDate = Date.today();
            opptyList.add(opp3);
            if(Schema.sObjectType.Opportunity.isCreateable()){
                insert opptyList;
            }
            //create Deal_Number__c record
            Deal_Number__c createDealNumber = TestDataUtility.createDealNumber(true,opp);
            
            //create Vehicle_Detail__c record
            List<Vehicle_Detail__c> vdList = new List<Vehicle_Detail__c>();
            Vehicle_Detail__c  vehicleDetail = TestDataUtility.createTestVehicleDetailForIbb(false, opp);
            vehicleDetail.Deal_Number__c=createDealNumber.Id;
            vdList.add(vehicleDetail);
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
            applicant1.Applicant_Type__c = 'Borrower';
            applicant1.Scorecard_Decision__c = 'Light Red';
            applicantList.add(applicant1);
            
            Applicant__c applicant2 = TestDataUtility.createTestApplicatnt2(false);
            applicant2.Opportunity__c = opp.Id;
            applicant1.Scorecard_Decision__c = 'Orange';
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
            if(Schema.sObjectType.Loan_Application_Transaction_History__c.isCreateable()){
                insert laptHistList;
            }
            
            //Create Documents__c records
            List<Documents__c> docList = new List<Documents__c>();
            Documents__c doc1 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc1.Vehicle_Detail__c = vehicleDetail.Id;
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
        }
    }
    
    @IsTest
    public static void test_getVehicleDetailsRecord(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank1.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            List<Vehicle_Detail__c> vdList = [SELECT Id,Loan_Application__c,Deal_Number__c FROM Vehicle_Detail__c LIMIT 1];
            Vehicle_Detail__c vehDet = IND_VehicleInspectionRCLimitDetails.getVehicleDetailsRecord(vdList[0].Loan_Application__c,vdList[0].Deal_Number__c);
            IND_VehicleInspectionRCLimitDetails.getVehicleDetailsRecord('test',null);
            IND_VehicleInspectionRCLimitDetails.getVehicleDetailsRecord(null,null);
            System.assertNotEquals(null, vehDet);
        }        
        //negative
        /*Opportunity oppNeg =[Select Id, Name From Opportunity Where Name ='VDR Negative Test' LIMIt 1];
Vehicle_Detail__c vehDetCatchNeg = IND_VehicleInspectionRCLimitDetails.getVehicleDetailsRecord(oppNeg.Id);
System.assertEquals(null, vehDet);*/
        Test.stopTest();
    }
    
    @IsTest
    public static void test_getLoanApplicationDetails(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank1.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp =[Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
            String loanApp = IND_VehicleInspectionRCLimitDetails.getLoanApplicationDetails(opp.Id);
            System.assertNotEquals(null, loanApp);
            //negative
            String loanAppNeg = IND_VehicleInspectionRCLimitDetails.getLoanApplicationDetails('ksdfsd');
            System.assertEquals(null, loanAppNeg);
        }
        Test.stopTest();
    }
    
    @IsTest
    public static void test_getLoanAmountfromFO(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank1.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [Select Id, Name From Opportunity Where Name ='Oppty 3' LIMIt 1];
            Boolean loanAppFO = IND_VehicleInspectionRCLimitDetails.getLoanAmountfromFO(opp.Id,null);
            System.assertEquals(true, loanAppFO);
            //negative 1
            Opportunity oppNeg1 = [Select Id, Name From Opportunity Where Name ='VDR Negative Test' LIMIt 1];
            Boolean loanAppFONeg1 = IND_VehicleInspectionRCLimitDetails.getLoanAmountfromFO(oppNeg1.Id,null);
            System.assertEquals(false, loanAppFONeg1);
            //negative 2
            Opportunity oppNeg2 =[Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
            List<Vehicle_Detail__c> vdList = [SELECT Id,Loan_Application__c,Deal_Number__c FROM Vehicle_Detail__c WHERE Loan_Application__c=:oppNeg2.Id LIMIT 1];
            Boolean loanAppFONeg2 = IND_VehicleInspectionRCLimitDetails.getLoanAmountfromFO(oppNeg2.id,vdList[0].Deal_Number__c);
            System.assertEquals(false, loanAppFONeg2);
        }
        Test.stopTest();
    }
    
    @IsTest
    public static void test_getApplicantId(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank1.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
            String applicantId = IND_VehicleInspectionRCLimitDetails.getApplicantId(opp.Id);
             IND_VehicleInspectionRCLimitDetails.getApplicantId('test');
            System.assertNotEquals(null, applicantId);
            //negative
            Opportunity oppNeg = [Select Id, Name From Opportunity Where Name ='VDR Negative Test' LIMIt 1];
            String applicantIdNeg = IND_VehicleInspectionRCLimitDetails.getApplicantId(oppNeg.Id);
            System.assertEquals(null, applicantIdNeg);
        }
        Test.stopTest();
    }
    
    @IsTest
    public static void test_getApplicantId2(){
        
        Opportunity opp = [Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
        
        Applicant__c applicant1 = TestDataUtility.createTestApplicatnt1(false);
        applicant1.Opportunity__c = opp.Id;
        applicant1.Who_will_repay_the_loan__c = 'Borrower';
        applicant1.Applicant_Type__c = 'Co-Borrower';
        applicant1.Scorecard_Decision__c = 'Light Red';
        insert applicant1;
        
        Test.startTest();
        IND_VehicleInspectionRCLimitDetails.getApplicantId(opp.Id);
        Test.stopTest();
        
    }
    
     @IsTest
    public static void test_getApplicantId3(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank1.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
            
            Applicant__c applicant1 = TestDataUtility.createTestApplicatnt1(false);
            applicant1.Opportunity__c = opp.Id;
            applicant1.Who_will_repay_the_loan__c = 'Borrower';
            //applicant1.Applicant_Type__c = 'Borrower';
            applicant1.Scorecard_Decision__c = 'Orange';
            insert applicant1;
            
           IND_VehicleInspectionRCLimitDetails.getApplicantId(opp.Id); 
           IND_VehicleInspectionRCLimitDetails.getApplicantId('test');
            
        }
        Test.stopTest();
    }
    
    @IsTest
    public static void test_getValidApplicants(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank1.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
            Boolean validApplicant = IND_VehicleInspectionRCLimitDetails.getValidApplicants(opp.Id);
            System.assertEquals(true, validApplicant);
            //negative
            Opportunity oppNeg = [Select Id, Name From Opportunity Where Name ='VDR Negative Test' LIMIt 1];
            Boolean validApplicantNeg = IND_VehicleInspectionRCLimitDetails.getValidApplicants(oppNeg.Id);
            System.assertEquals(false, validApplicantNeg);
        }
        Test.stopTest();
    }
    
    @IsTest
    public static void test_updateVehicleInspectionRCDetails(){
        IND_VehicleInspectionRCLimitDetails.vehicleDetailsWrapper vehWrapper = new IND_VehicleInspectionRCLimitDetails.vehicleDetailsWrapper();
        vehWrapper.chassisNumber = 'KM6758HL0989';
        vehWrapper.engineNumber = 'GS-560T';
        vehWrapper.locationOfVehicle = 'Mumbai';
        vehWrapper.remarks = 'Test Remark';
        vehWrapper.vehicleRegNumber = 'MH-01-AC-1000';
        String vehWrapperString = JSON.serialize(vehWrapper);
        Vehicle_Detail__c vehDet = [Select Id, Variant__c,Deal_Number__c From Vehicle_Detail__c Where Variant__c = 'ALSTILELE' LIMIT 1];
        Opportunity opp = [Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank1.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            IND_VehicleInspectionRCLimitDetails.updateVehicleInspectionRCDetails(opp.Id, vehDet.Id, vehWrapperString,vehDet.Deal_Number__c);
            Vehicle_Detail__c vehDetAfter = [Select Id, Variant__c, Engine_Number_during_Inspection__c, Location_of_Vehicle_Inspection__c, Remarks__c From Vehicle_Detail__c Where Id =: vehDet.id LIMIT 1];
            System.assertNotEquals(null, vehDetAfter);
            System.assertEquals('Mumbai', vehDetAfter.Location_of_Vehicle_Inspection__c);
            System.assertEquals('GS-560T', vehDetAfter.Engine_Number_during_Inspection__c);
            //negative
            try {
                IND_VehicleInspectionRCLimitDetails.updateVehicleInspectionRCDetails(opp.Id, '0987400fhskuh', vehWrapperString,vehDet.Deal_Number__c);
            } catch(Exception ex){
                System.assert(ex.getMessage().contains('Invalid id'));
            }
        }
        Test.stopTest();
    }
    
    @IsTest
    public static void test_saveRCLimitResponseDetails(){
        IND_VehicleInspectionRCLimitDetails.RCLimitCheckResponseWrapper rcLimitWrapper = new IND_VehicleInspectionRCLimitDetails.RCLimitCheckResponseWrapper();
        rcLimitWrapper.No_Of_Proposals_Available = '2';
        rcLimitWrapper.Available_Disbursal_Amount = '1500';
        rcLimitWrapper.Pending_Flag = 'Y';
        rcLimitWrapper.Payment_To_DSA_Flag = 'Y';
        String rcLimitWrapperString = JSON.serialize(rcLimitWrapper);
        Vehicle_Detail__c vehDet = [Select Id, Variant__c From Vehicle_Detail__c Where Variant__c = 'ALSTILELE' LIMIT 1];
        Opportunity opp = [Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank1.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            IND_VehicleInspectionRCLimitDetails.saveRCLimitResponseDetails(opp.Id, vehDet.Id, rcLimitWrapperString);
            Vehicle_Detail__c vehDetAfter = [Select Id, Variant__c, No_Of_Proposals_Available__c, Available_Disbursal_Amount__c, No_of_days_RC_Pending__c From Vehicle_Detail__c Where Id =: vehDet.id LIMIT 1];
            System.assertNotEquals(null, vehDetAfter);
            System.assertEquals(2, vehDetAfter.No_Of_Proposals_Available__c);
            System.assertEquals(1500, vehDetAfter.Available_Disbursal_Amount__c);
            System.assertEquals(true, vehDetAfter.No_of_days_RC_Pending__c);
            //negatiev 1
            IND_VehicleInspectionRCLimitDetails.RCLimitCheckResponseWrapper rcLimitWrapperNeg = new IND_VehicleInspectionRCLimitDetails.RCLimitCheckResponseWrapper();
            rcLimitWrapperNeg.No_Of_Proposals_Available = '';
            rcLimitWrapperNeg.Available_Disbursal_Amount = '';
            rcLimitWrapperNeg.Pending_Flag = 'N';
            rcLimitWrapperNeg.Payment_To_DSA_Flag = 'N';
            String rcLimitWrapperNegString = JSON.serialize(rcLimitWrapperNeg);
            IND_VehicleInspectionRCLimitDetails.saveRCLimitResponseDetails(opp.Id, vehDet.Id, rcLimitWrapperNegString);
            Vehicle_Detail__c vehDetNegAfter = [Select Id, Variant__c, No_Of_Proposals_Available__c, Available_Disbursal_Amount__c, No_of_days_RC_Pending__c From Vehicle_Detail__c Where Id =: vehDet.id LIMIT 1];
            System.assertNotEquals(null, vehDetNegAfter);
            System.assertEquals(0, vehDetNegAfter.No_Of_Proposals_Available__c);
            System.assertEquals(0, vehDetNegAfter.Available_Disbursal_Amount__c);
            System.assertEquals(false, vehDetNegAfter.No_of_days_RC_Pending__c);
            //negative 2
            Boolean rcNeg2 = IND_VehicleInspectionRCLimitDetails.saveRCLimitResponseDetails(opp.Id, vehDet.Id, null);
            System.assertEquals(false, rcNeg2);
            //negative 3
            try {
                IND_VehicleInspectionRCLimitDetails.saveRCLimitResponseDetails(opp.Id, '0987400fhskuh', rcLimitWrapperString);
            } catch(Exception ex){
                System.assert(ex.getMessage().contains('Invalid id'));
            }
        }
        Test.stopTest();
    }
    
    @IsTest
    public static void test_savecontinueWithRCLimitvalue(){
        Vehicle_Detail__c vehDet = [Select Id, Variant__c From Vehicle_Detail__c Where Variant__c = 'ALSTILELE' LIMIT 1];
        Opportunity opp = [Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank1.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            IND_VehicleInspectionRCLimitDetails.savecontinueWithRCLimitvalue(opp.Id, vehDet.Id, true);
            Vehicle_Detail__c vehDetAfter = [Select Id, Variant__c, Can_we_continue_with_above_RC_limit__c From Vehicle_Detail__c Where Id =: vehDet.id LIMIT 1];
            System.assertNotEquals(null, vehDetAfter);
            System.assertEquals(true, vehDetAfter.Can_we_continue_with_above_RC_limit__c);
            //negative
            try {
                IND_VehicleInspectionRCLimitDetails.savecontinueWithRCLimitvalue(opp.Id, '0987400fhskuh', false);
            } catch(Exception ex){
                System.assert(ex.getMessage().contains('Invalid id'));
            }
        }
        Test.stopTest();
    }
    
    @IsTest
    public static void test_saveRCLimitResponseDetailsForDSA(){
        IND_VehicleInspectionRCLimitDetails.RCLimitCheckResponseWrapper rcLimitWrapper = new IND_VehicleInspectionRCLimitDetails.RCLimitCheckResponseWrapper();
        rcLimitWrapper.No_Of_Proposals_Available = '2';
        rcLimitWrapper.Available_Disbursal_Amount = '1500';
        rcLimitWrapper.Pending_Flag = 'Y';
        rcLimitWrapper.Payment_To_DSA_Flag = 'Y';
        String rcLimitWrapperString = JSON.serialize(rcLimitWrapper);
        Final_Term__c finalObj = [Select Id From Final_Term__c LIMIT 1];
        Opportunity opp = [Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank1.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            IND_VehicleInspectionRCLimitDetails.saveRCLimitResponseDetailsForDSA(opp.Id, finalObj.Id, rcLimitWrapperString);
            Final_Term__c finObjAfter = [Select Id, No_Of_Proposals_Available__c, Available_Disbursal_Amount__c, No_of_days_RC_Pending__c From Final_Term__c Where Id =: finalObj.id LIMIT 1];
            System.assertNotEquals(null, finObjAfter);
            System.assertEquals(2, finObjAfter.No_Of_Proposals_Available__c);
            System.assertEquals(1500, finObjAfter.Available_Disbursal_Amount__c);
            System.assertEquals(true, finObjAfter.No_of_days_RC_Pending__c);
            try {
                IND_VehicleInspectionRCLimitDetails.saveRCLimitResponseDetails(opp.Id, '0987400fhskuh', rcLimitWrapperString);
            } catch(Exception ex){
                System.assert(ex.getMessage().contains('Invalid id'));
            }
        }
        Test.stopTest();
    }
    
    
    @IsTest
    public static void test_savecontinueWithRCLimitvalueForDSA(){
        Final_Term__c finalObj = [Select Id From Final_Term__c LIMIT 1];
        Opportunity opp = [Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank1.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            IND_VehicleInspectionRCLimitDetails.savecontinueWithRCLimitvalueForDSA(opp.Id, finalObj.Id, true);
            Final_Term__c finalObjAfter = [Select Id, Can_we_continue_with_above_RC_limit__c From Final_Term__c Where Id =: finalObj.id LIMIT 1];
            System.assertNotEquals(null, finalObjAfter);
            System.assertEquals(true, finalObjAfter.Can_we_continue_with_above_RC_limit__c);
            //negative
            try {
                IND_VehicleInspectionRCLimitDetails.savecontinueWithRCLimitvalue(opp.Id, '0987400fhskuh', false);
            } catch(Exception ex){
                System.assert(ex.getMessage().contains('Invalid id'));
            }
        }
        Test.stopTest();
    }
    
    @IsTest
    public static void updateTransactionRecord(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank1.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity oppRec = [Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
            Deal_Number__c deal = [Select Id from Deal_Number__c limit 1];
            Loan_Application_Transaction_History__c loanAppHis = [Select Id, Submitted_Flag__c, Name, Screen__c, Module__c
                                                                  From Loan_Application_Transaction_History__c Where 
                                                                  Loan_Application_ID__c =: oppRec.Id LIMIT 1];
            loanAppHis.Name = 'Vehicle Inspection and RC Check';
            loanAppHis.Screen__c = 'Vehicle Inspection and RC Check';
            loanAppHis.Module__c = 'Prospecting';
            loanAppHis.Deal_Number__c = deal.Id;
            update loanAppHis; 
            
            IND_VehicleInspectionRCLimitDetails.updateTransactionRecord(oppRec.Id,deal.Id);
            IND_VehicleInspectionRCLimitDetails.updateTransactionRecord(oppRec.Id,null);
        }
        Test.stopTest();
    }
    
    @IsTest
    public static void test_saveFinalButtonStatus(){
        Vehicle_Detail__c vehDet = [Select Id, Variant__c,Deal_Number__c From Vehicle_Detail__c Where Variant__c = 'ALSTILELE' LIMIT 1];
        Opportunity opp = [Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
        Deal_Number__c deal = [SELECT Id from Deal_Number__c limit 1];
        Loan_Application_Transaction_History__c loanAppHis = [Select Id, Submitted_Flag__c, Name, Screen__c, Module__c
                                                              From Loan_Application_Transaction_History__c Where 
                                                              Loan_Application_ID__c =: opp.Id LIMIT 1];
        loanAppHis.Name = 'Vehicle Inspection and RC Check';
        loanAppHis.Screen__c = 'Vehicle Inspection and RC Check';
        loanAppHis.Module__c = 'Post Sanction Checks and Documentation';
        loanAppHis.Deal_Number__c = deal.Id;
        loanAppHis.Submitted_Flag__c = true;
        update loanAppHis;
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank1.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
             IND_VehicleInspectionRCLimitDetails.saveFinalButtonStatus(opp.Id, vehDet.Id, true,deal.Id);
            IND_VehicleInspectionRCLimitDetails.saveFinalButtonStatus(opp.Id, vehDet.Id, true,vehDet.Deal_Number__c);
            Vehicle_Detail__c vehDetAfter = [Select Id, Variant__c, Vehicle_Inspection_RC_Limit_Submitted__c From Vehicle_Detail__c Where Id =: vehDet.id LIMIT 1];
            System.assertNotEquals(null, vehDetAfter);
            System.assertEquals(true, vehDetAfter.Vehicle_Inspection_RC_Limit_Submitted__c);
            //negative
            try {
                IND_VehicleInspectionRCLimitDetails.saveFinalButtonStatus(opp.Id, '0987400fhskuh', false,vehDet.Deal_Number__c);
            } catch(Exception ex){
                System.assert(ex.getMessage().contains('Invalid id'));
            }
        }
        Test.stopTest();
    }
    
    @IsTest
    public static void test_getDocumentData(){
        Vehicle_Detail__c vehDet = [Select Id, Variant__c From Vehicle_Detail__c Where Variant__c = 'ALSTILELE' LIMIT 1];
        Opportunity opp = [Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank1.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            List<Documents__c> docList = IND_VehicleInspectionRCLimitDetails.getDocumentData(opp.Id, vehDet.Id);
            System.assertNotEquals(null, docList);
            System.assertEquals(opp.Id, docList[0].Opportunity_Relation__c);
            //negative 2
            Opportunity oppNeg =[Select Id, Name From Opportunity Where Name ='VDR Negative Test' LIMIt 1];
            List<Documents__c> docListNeg = IND_VehicleInspectionRCLimitDetails.getDocumentData(oppNeg.Id, vehDet.Id);
            System.assertEquals(null, docListNeg);
        }
        Test.stopTest();
    }
    
    @IsTest
    public static void test_updateVehicleDetailsByCVO(){
        List<Vehicle_Detail__c> vehDetList = new List<Vehicle_Detail__c>();
        Vehicle_Detail__c vehDet = [Select Id, Variant__c,Deal_Number__c From Vehicle_Detail__c Where Variant__c = 'ALSTILELE' LIMIT 1];
        vehDet.Chassis_number__c = 'ghgb6579';
        vehDetList.add(vehDet);
        String vehDetListString = JSON.serialize(vehDetList);
        Opportunity opp = [Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank1.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            IND_VehicleInspectionRCLimitDetails.updateVehicleDetailsByCVO(opp.Id, vehDetListString,vehDet.Deal_Number__c);
            Vehicle_Detail__c vehDetAfter = [Select Id, Chassis_number__c From Vehicle_Detail__c Where Id =: vehDet.Id LIMIT 1];
            System.assertNotEquals(null, vehDetAfter);
            System.assertEquals('ghgb6579', vehDetAfter.Chassis_number__c);
            //negative
            try {
                Vehicle_Detail__c vd = new Vehicle_Detail__c();
                vd.Insurance_type__c = 'Personal';
                vehDetList.add(vd);
                String vehDetListStringNeg = JSON.serialize(vehDetList);
                IND_VehicleInspectionRCLimitDetails.updateVehicleDetailsByCVO(opp.Id, vehDetListStringNeg,vehDet.Deal_Number__c);
            } catch(Exception ex){
                System.assert(ex.getMessage().contains('REQUIRED_FIELD_MISSING'));
            }
        }
        Test.stopTest();
    }
    
    @IsTest
    public static void test_retryCountIncrease(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank1.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp =[Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
            Boolean rtCount = IND_VehicleInspectionRCLimitDetails.retryCountIncrease(opp.Id);
            //scenario 2
            Opportunity oppNeg =[Select Id, Name From Opportunity Where Name ='VDR Negative Test' LIMIt 1];
            Boolean rtCount2 = IND_VehicleInspectionRCLimitDetails.retryCountIncrease(opp.Id);
            //negative
            Boolean rtCountNeg = IND_VehicleInspectionRCLimitDetails.retryCountIncrease(null);
            System.assertEquals(false, rtCountNeg);
            //negative 2
            try{
                Boolean rtCountNeg2 = IND_VehicleInspectionRCLimitDetails.retryCountIncrease('kjhgug6745');
            } catch(Exception ex){
                System.assert(ex.getMessage().contains('Script-thrown exception'));
            }
        }
        Test.stopTest();
    }
    
    @IsTest
    public static void test_checkIfReadOnly(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank1.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp =[Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
            
            Deal_Number__c dl = [Select Id from Deal_Number__c limit 1];
            Loan_Application_Transaction_History__c loanAppHis = [Select Id, Submitted_Flag__c, Name, Screen__c, Module__c
                                                                  From Loan_Application_Transaction_History__c Where 
                                                                  Loan_Application_ID__c =: opp.Id LIMIT 1];
            loanAppHis.Name = 'RTO, DPN, POA Documents Upload';
            loanAppHis.Screen__c = 'RTO, DPN, POA Documents Upload';
            loanAppHis.Module__c = 'Post Sanction Checks and Documentation';
            loanAppHis.Submitted_Flag__c = true;
            loanAppHis.Deal_Number__c = dl.Id;
            update loanAppHis; 
            Boolean lthRet = IND_VehicleInspectionRCLimitDetails.checkIfReadOnly(opp.Id,dl.Id);
            System.assertEquals(false, lthRet);
            //Negative
            try{
                Boolean lthRetNeg = IND_VehicleInspectionRCLimitDetails.checkIfReadOnly('ygsdfiuw786',null);
                System.assertEquals(false, lthRetNeg);
            } catch(Exception ex){
                System.debug('Exception :' + ex.getMessage());
            }
        }
        Test.stopTest();
    }
    @IsTest
    public static void reffnamedataTest(){
        try{
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank1.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity opp =[Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
                IND_VehicleInspectionRCLimitDetails.reffnamedata(opp.Id);
                IND_VehicleInspectionRCLimitDetails.updateFinalTermBenCode(opp.Id,'xyz','test');
                IND_VehicleInspectionRCLimitDetails.getFinalTermRecord(opp.Id);
            }
        }
        catch(Exception ex){
            System.debug('Exception :' + ex.getMessage());
        }
    }
    
    @isTest
    public static void updateFinalTermBenCodeTest1(){
        try{
            Opportunity opga1 = new Opportunity();
            opga1.StageName = 'Qualification';
            opga1.CloseDate = Date.newInstance(2021, 1, 11);
            opga1.Name = 'testone';
            insert opga1;
            
            Applicant__c apft1 = new Applicant__c();
            apft1.Opportunity__c = opga1.Id;
            apft1.Contact_number__c = '9743514830';
            apft1.Applicant_Type__c = 'Borrower';
            apft1.In_Active_Applicant__c = false;
            insert apft1;
            
            Final_Term__c ftd1 = new Final_Term__c();
            ftd1.CRM_IRR__c = 120;
            ftd1.Loan_Application__c = opga1.Id;
            ftd1.Holiday_period__c='30';
            ftd1.EMI_Amount__c= 10000;
            ftd1.Loan_Amount__c = '50000.00';
            ftd1.Service_charges__c = '1000.00';
            ftd1.Documentation_charges__c = '5000';
            ftd1.Dlr_Exp_Reimburse_Amt__c = '10000';
            ftd1.Rreferrer_Incentive__c = '100000';
            ftd1.Dlr_Exp_Reimbursement_percent__c = '20000';
            ftd1.Mfr_Exp_Reimburse_percent__c = '30000';
            ftd1.Referrer_Ben_Code__c = 'test';
            ftd1.Referrer_Name__c = 'testres';
            insert ftd1;
            
            Test.startTest();
            IND_VehicleInspectionRCLimitDetails.updateFinalTermBenCode(opga1.Id,ftd1.Referrer_Ben_Code__c,ftd1.Referrer_Name__c);
            IND_VehicleInspectionRCLimitDetails.updateFinalTermBenCode('test','test','test');
            IND_VehicleInspectionRCLimitDetails.updateFinalTermBenCode(null,null,null);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getFinalTermRecordTest3(){
        try{
            Opportunity opga1 = new Opportunity();
            opga1.StageName = 'Qualification';
            opga1.CloseDate = Date.newInstance(2021, 1, 11);
            opga1.Name = 'testone';
            insert opga1;
            
            Applicant__c apft1 = new Applicant__c();
            apft1.Opportunity__c = opga1.Id;
            apft1.Contact_number__c = '9743514830';
            apft1.Applicant_Type__c = 'Borrower';
            apft1.In_Active_Applicant__c = false;
            insert apft1;
            
            Final_Term__c ftd1 = new Final_Term__c();
            ftd1.CRM_IRR__c = 120;
            ftd1.Loan_Application__c = opga1.Id;
            ftd1.Dlr_Exp_Reimbursement_percent__c = '20000';
            ftd1.Mfr_Exp_Reimburse_percent__c = '30000';
            ftd1.Referrer_Ben_Code__c = 'test';
            ftd1.Referrer_Name__c = 'testres';
            insert ftd1;
            
            Test.startTest();
            IND_VehicleInspectionRCLimitDetails.getFinalTermRecord(opga1.Id);
            IND_VehicleInspectionRCLimitDetails.getFinalTermRecord('test');
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getCaseIdTest(){
        try{
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank1.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity opp =[Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
                Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Asset Verification').getRecordTypeId();
                
                Case case_s = new Case();
                case_s.Origin = 'Email';
                case_s.Subject = 'disableInitiateAML';
                case_s.Loan_Application__c = opp.Id;
                case_s.Status = 'Closed';
                case_s.OwnerId = u.Id;
                case_s.RecordTypeId = recordTypeId;
                insert case_s;
                
                Test.startTest();
                try {
                    IND_VehicleInspectionRCLimitDetails.getCaseId(opp.Id);
                    IND_VehicleInspectionRCLimitDetails.getCaseId('test');
                } catch (IND_Exception e) {
                    System.assertNotEquals(null, e.getMessage(), 'Exception message should not be null');
                }
                Test.stopTest();
            }
        }
        catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void checkFinalTermRecordsTest(){
        try{
            
            Opportunity oppRec = new Opportunity();
            oppRec.Name = 'test Opp';
            oppRec.StageName = 'Qualification';
            oppRec.CloseDate = System.today();
            oppRec.Product_Type__c = 'Tractor';
            insert oppRec;
            
            Applicant__c app = new Applicant__c();
            app.Opportunity__c = oppRec.Id;
            insert app;
            
             
            Vehicle_Detail__c vehicleRec = new Vehicle_Detail__c();
            vehicleRec.Loan_Application__c = oppRec.Id;
            vehicleRec.Total_Funded_Amount__c = 3456;
            insert vehicleRec;
            
            Final_Term__c finalTerm = new Final_Term__c();
            finalTerm.Loan_Application__c = oppRec.Id;
            finalTerm.Loan_Amount__c = '12000';
            finalTerm.Vehicle_Detail__c = vehicleRec.Id;
            finalTerm.Installment_Type__c = 'Structured';
            insert finalTerm;
            
            Structered_EMI__c emi = new Structered_EMI__c();
            emi.Loan_Application__c = oppRec.Id;
            emi.Vehicle_Detail__c = vehicleRec.Id;
            insert emi;
                     
            Test.startTest();
            IND_VehicleInspectionRCLimitDetails.checkFinalTermRecords(oppRec.Id);
            IND_VehicleInspectionRCLimitDetails.checkFinalTermRecords('test');
            Test.stopTest();
        }
        catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getDocumentTractorTest(){
        try{
            
            Opportunity oppRec = new Opportunity();
            oppRec.Name = 'test Opp';
            oppRec.StageName = 'Qualification';
            oppRec.CloseDate = System.today();
            oppRec.Product_Type__c = 'Tractor';
            insert oppRec;
            
            Applicant__c app = new Applicant__c();
            app.Opportunity__c = oppRec.Id;
            insert app;
            
            Vehicle_Detail__c vehicleRec = new Vehicle_Detail__c();
            vehicleRec.Loan_Application__c = oppRec.Id;
            insert vehicleRec;
            
            Documents__c dsdt1 = new Documents__c();
            dsdt1.Applicant__c = app.Id;
            dsdt1.Opportunity_Relation__c = oppRec.Id;
            dsdt1.Document_Type__c = 'Invoice';
            dsdt1.Document_Side__c ='Back';
            dsdt1.Aadhar_Source__c = 'Biometric';
            dsdt1.Is_active__c = true;
            insert dsdt1;
            
            Test.startTest();
            IND_VehicleInspectionRCLimitDetails.getDocumentTractor(oppRec.Id,vehicleRec.Id);
            IND_VehicleInspectionRCLimitDetails.getDocumentTractor('test',null);
            Test.stopTest();
        }
        catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void getDocumentDataTractorTest(){
        try{
            
            Opportunity oppRec = new Opportunity();
            oppRec.Name = 'test Opp';
            oppRec.StageName = 'Qualification';
            oppRec.CloseDate = System.today();
            oppRec.Product_Type__c = 'Tractor';
            insert oppRec;
            
            Applicant__c app = new Applicant__c();
            app.Opportunity__c = oppRec.Id;
            insert app;
            
            Vehicle_Detail__c vehicleRec = new Vehicle_Detail__c();
            vehicleRec.Loan_Application__c = oppRec.Id;
            insert vehicleRec;
            
            
            List<String> docStringList = new List<String>{'Engine Number uploaded during verification', 'Chassis Number uploaded during verification', 'Selfie with Vehicle-uploaded during verification', 'Vehicle Front-uploaded during verification', 'Vehicle Back-uploaded during verification', 'Capture Chassis plate', 'Capture Vehicle Right Side', 'Capture Vehicle Left Side', 'Capture HMR'};
            Documents__c dsdt1 = new Documents__c();
            dsdt1.Applicant__c = app.Id;
            dsdt1.Opportunity_Relation__c = oppRec.Id;
            dsdt1.Document_Type__c = docStringList[0];
            dsdt1.Document_Side__c ='Back';
            dsdt1.Aadhar_Source__c = 'Biometric';
            dsdt1.Is_active__c = true;
            insert dsdt1;
            
            Test.startTest();
            IND_VehicleInspectionRCLimitDetails.getDocumentDataTractor(oppRec.Id,vehicleRec.Id);
            IND_VehicleInspectionRCLimitDetails.getDocumentDataTractor('test','test1');
            Test.stopTest();
        }
        catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
}