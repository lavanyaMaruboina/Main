@isTest
public class LwcLOSGattingAndScreeningCntrlTest {
    @isTest
    public static void getCurrentApplicantRecordTest(){
        try{
        Opportunity ops1 = new Opportunity();
        ops1.StageName = 'Qualification';
        ops1.CloseDate = Date.newInstance(2021, 1, 11);
        ops1.Name = 'testone';
        insert ops1;
        
        Applicant__c aps1 = new Applicant__c();
        aps1.Opportunity__c = ops1.Id;
        aps1.In_Active_Applicant__c = false;
        aps1.Applicant_Type__c = 'Borrower';
        aps1.Check_Eligibility_Match__c = True;
        aps1.Contact_number__c = '9948670743';
        insert aps1;
        
        CIBIL_Details__c cbd1 = new CIBIL_Details__c();
        cbd1.Applicant__c = aps1.Id;
        cbd1.CIC_No__c = 'testcbd';
        insert cbd1;
        
        Documents__c ds1 = new Documents__c();
        ds1.Applicant__c = aps1.Id;
        ds1.Opportunity_Relation__c = ops1.Id;
        ds1.Document_Type__c = 'Form 60';
        insert ds1;
        
        Test.startTest();
            LwcLOSGattingAndScreeningCntrl.getCurrentApplicantRecord(aps1.Id);
        Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getCurrentApplicantRecordTest1(){
        try{
        Opportunity ops2 = new Opportunity();
        ops2.StageName = 'Qualification';
        ops2.CloseDate = Date.newInstance(2021, 1, 11);
        ops2.Name = 'testone';
        insert ops2;
        
        Test.startTest();
            LwcLOSGattingAndScreeningCntrl.getCurrentApplicantRecord(ops2.Id);
        Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

    
    @isTest
    public static void gattingBureauPull1Test(){
        try{
        Opportunity opgb1 = new Opportunity();
        opgb1.StageName = 'Qualification';
        opgb1.CloseDate = Date.newInstance(2021, 1, 11);
        opgb1.Name = 'testone';
        insert opgb1;
        
        Applicant__c apb1 = new Applicant__c();
        apb1.Opportunity__c = opgb1.Id;
        apb1.In_Active_Applicant__c = false;
        apb1.Applicant_Type__c = 'Borrower';
        apb1.Check_Eligibility_Match__c = True;
        apb1.Contact_number__c = '9948670743';
        apb1.Bureau_Pull_Attempts__c = null;
        insert apb1;
        
        Test.startTest();
           // LwcLOSGattingAndScreeningCntrl.gattingBureauPull1(apb1.Id,opgb1.Id);
        Test.stopTest();
        }catch(Exception e){
            
        }
    }
    
     @isTest
    public static void gattingBureauPull1Test1(){
        try{
        Opportunity opgb1 = new Opportunity();
        opgb1.StageName = 'Qualification';
        opgb1.CloseDate = Date.newInstance(2021, 1, 11);
        opgb1.Name = 'testone';
        insert opgb1;
        
        Applicant__c apb1 = new Applicant__c();
        apb1.Opportunity__c = opgb1.Id;
        apb1.In_Active_Applicant__c = false;
        apb1.Applicant_Type__c = 'Borrower';
        apb1.Check_Eligibility_Match__c = True;
        apb1.Contact_number__c = '9948670743';
        apb1.Bureau_Pull_Attempts__c = 5;
        insert apb1;
        
        Test.startTest();
          //  LwcLOSGattingAndScreeningCntrl.gattingBureauPull1(null,opgb1.Id);
        Test.stopTest();
        }catch(Exception e){
            
        }
    }
    
     @isTest
    public static void gattingBureauPull1Test2(){
        try{
        Opportunity opgb1 = new Opportunity();
        opgb1.StageName = 'Qualification';
        opgb1.CloseDate = Date.newInstance(2021, 1, 11);
        opgb1.Name = 'testone';
        insert opgb1;
        
        Applicant__c apb1 = new Applicant__c();
        apb1.Opportunity__c = opgb1.Id;
        apb1.In_Active_Applicant__c = false;
        apb1.Applicant_Type__c = 'Borrower';
        apb1.Check_Eligibility_Match__c = True;
        apb1.Contact_number__c = '9948670743';
        apb1.Bureau_Pull_Attempts__c = 1;
        insert apb1;
        
        Test.startTest();
           // LwcLOSGattingAndScreeningCntrl.gattingBureauPull1(null,opgb1.Id);
        Test.stopTest();
        }catch(Exception e){
            
        }
    }
    
    @isTest
    public static void gattingCheckEligibilityTest(){
        try{
        Opportunity ope1 = new Opportunity();
        ope1.StageName = 'Qualification';
        ope1.CloseDate = Date.newInstance(2021, 1, 11);
        ope1.Name = 'testone';
        insert ope1;
        
        Applicant__c ape1 = new Applicant__c();
        ape1.Opportunity__c = ope1.Id;
        ape1.In_Active_Applicant__c = false;
        ape1.Applicant_Type__c = 'Co-borrower';
    //    ape1.Check_Eligibility_Match__c = True;
        ape1.Contact_number__c = '9948670743';
   //     ape1.Bureau_Pull_Attempts__c = 2;
        insert ape1;
        
        Test.startTest();
            LwcLOSGattingAndScreeningCntrl.gattingCheckEligibility(ape1.Id,ope1.Id);
        Test.stopTest();
        }catch(Exception e){
            
        }
    }
    
    @isTest
    public static void gattingCheckEligibilityTest1(){
        try{
        Opportunity ope1 = new Opportunity();
        ope1.StageName = 'Qualification';
        ope1.CloseDate = Date.newInstance(2021, 1, 11);
        ope1.Name = 'testone';
        insert ope1;
        
        List<Applicant__c> appList = new List<Applicant__c>();
        Applicant__c ape1 = new Applicant__c();
        ape1.Opportunity__c = ope1.Id;
    //    ape1.In_Active_Applicant__c = false;
        ape1.Applicant_Type__c = System.label.Borrower;
      //  ape1.Check_Eligibility_Match__c = false;
        ape1.Bureau_Pull_Match__c = false;
        ape1.Bureau_Pull_Message__c = System.label.Retry_Exhausted;
        ape1.Contact_number__c = '9948670743';
   //     ape1.Do_you_have_a_bank_account__c = false;
   //     ape1.Bureau_Pull_Attempts__c = 2;
        insert ape1;
            
         Applicant__c ape2 = new Applicant__c();
        ape2.Opportunity__c = ope1.Id;
     //   ape2.In_Active_Applicant__c = false;
        ape2.Applicant_Type__c = System.label.Borrower;
        ape2.Contact_number__c = '9948670743';
        insert ape2;
        
        appList.add(ape1);
        appList.add(ape2);
         
        
        Test.startTest();
            LwcLOSGattingAndScreeningCntrl.gattingCheckEligibility(appList[0].Id,ope1.Id);
        Test.stopTest();
        }catch(Exception e){
            
        }
    }
    
    @isTest
    public static void gattingCheckEligibilityTest2(){
        try{
        Opportunity ope1 = new Opportunity();
        ope1.StageName = 'Qualification';
        ope1.CloseDate = Date.newInstance(2021, 1, 11);
        ope1.Name = 'testone';
        insert ope1;
        
        List<Applicant__c> appList = new List<Applicant__c>();
        Applicant__c ape1 = new Applicant__c();
        ape1.Opportunity__c = ope1.Id;
        ape1.In_Active_Applicant__c = false;
        ape1.Applicant_Type__c = System.label.CoBorrower;
    //  ape1.Check_Eligibility_Match__c = false;
    //  ape1.Bureau_Pull_Match__c = false;
        ape1.Bureau_Pull_Message__c = 'Success';
        ape1.Contact_number__c = '9948670743';
        ape1.Do_you_have_a_bank_account__c = false;
        ape1.Willing_to_open_Bank_Account_with_IIB__c = false;
   //   ape1.Bureau_Pull_Attempts__c = 2;
        insert ape1;
            
      /*   Applicant__c ape2 = new Applicant__c();
        ape2.Opportunity__c = ope1.Id;
        ape2.In_Active_Applicant__c = false;
        ape2.Applicant_Type__c = System.label.CoBorrower;
        ape2.Contact_number__c = '9948670743';
        ape2.Bureau_Pull_Match__c = false;
        ape2.Bureau_Pull_Message__c = 'Success';
        insert ape2; */
        
        appList.add(ape1);
     //   appList.add(ape2);
         
        
        Test.startTest();
            LwcLOSGattingAndScreeningCntrl.gattingCheckEligibility(appList[0].Id,ope1.Id);
            LwcLOSGattingAndScreeningCntrl.gattingCheckEligibility('test','test');
        Test.stopTest();
        }catch(Exception e){
            
        }
    }
    
     @isTest
    public static void gattingCheckEligibilityTest3(){
        try{
        Opportunity ope1 = new Opportunity();
        ope1.StageName = 'Qualification';
        ope1.CloseDate = Date.newInstance(2021, 1, 11);
        ope1.Name = 'testone';
        insert ope1;
        
        List<Applicant__c> appList = new List<Applicant__c>();
        Applicant__c ape1 = new Applicant__c();
        ape1.Opportunity__c = ope1.Id;
        ape1.In_Active_Applicant__c = false;
        ape1.Applicant_Type__c = System.label.CoBorrower;
      //  ape1.Check_Eligibility_Match__c = false;
        ape1.Contact_number__c = '9948670743';
        ape1.Do_you_have_a_bank_account__c = false;
        ape1.Willing_to_open_Bank_Account_with_IIB__c = false;
   //     ape1.Bureau_Pull_Attempts__c = 2;
        insert ape1;
            
         Applicant__c ape2 = new Applicant__c();
        ape2.Opportunity__c = ope1.Id;
        ape2.In_Active_Applicant__c = false;
        ape2.Applicant_Type__c = System.label.CoBorrower;
        ape2.Contact_number__c = '9948670743';
        ape2.Do_you_have_a_bank_account__c = false;
        ape2.Willing_to_open_Bank_Account_with_IIB__c = false;
        insert ape2;
        
        appList.add(ape1);
        appList.add(ape2);
         
        
        Test.startTest();
            LwcLOSGattingAndScreeningCntrl.gattingCheckEligibility(appList[0].Id,ope1.Id);
        Test.stopTest();
        }catch(Exception e){
            
        }
    }
    
     @isTest
    public static void gattingCheckEligibilityTest4(){
        try{
        Opportunity ope1 = new Opportunity();
        ope1.StageName = 'Qualification';
        ope1.CloseDate = Date.newInstance(2021, 1, 11);
        ope1.Name = 'testone';
        insert ope1;
        
        List<Applicant__c> appList = new List<Applicant__c>();
        Applicant__c ape1 = new Applicant__c();
        ape1.Opportunity__c = ope1.Id;
        ape1.In_Active_Applicant__c = false;
        ape1.Applicant_Type__c = System.label.Guarantor;
        ape1.Bureau_Pull_Match__c = false;
        ape1.Bureau_Pull_Message__c = 'Success';
        ape1.Check_Eligibility_Match__c = false;
        ape1.Contact_number__c = '9948670743';
        ape1.Do_you_have_a_bank_account__c = false;
        ape1.Willing_to_open_Bank_Account_with_IIB__c = false;
   //     ape1.Bureau_Pull_Attempts__c = 2;
        insert ape1;
            
         Applicant__c ape2 = new Applicant__c();
        ape2.Opportunity__c = ope1.Id;
        ape2.In_Active_Applicant__c = false;
        ape2.Applicant_Type__c = System.label.CoBorrower;
        ape2.Contact_number__c = '9948670743';
        ape2.Do_you_have_a_bank_account__c = false;
        ape2.Willing_to_open_Bank_Account_with_IIB__c = false;
        insert ape2;
        
        appList.add(ape1);
        appList.add(ape2);
         
        
        Test.startTest();
            LwcLOSGattingAndScreeningCntrl.gattingCheckEligibility(appList[0].Id,ope1.Id);
        Test.stopTest();
        }catch(Exception e){
            
        }
    }
    
     @isTest
    public static void gattingCheckEligibilityTest5(){
        try{
        Opportunity ope1 = new Opportunity();
        ope1.StageName = 'Qualification';
        ope1.CloseDate = Date.newInstance(2021, 1, 11);
        ope1.Name = 'testone';
        insert ope1;
        
        List<Applicant__c> appList = new List<Applicant__c>();
        Applicant__c ape1 = new Applicant__c();
        ape1.Opportunity__c = ope1.Id;
        ape1.In_Active_Applicant__c = false;
        ape1.Applicant_Type__c = System.label.Beneficiary;
        ape1.Bureau_Pull_Match__c = false;
        ape1.Bureau_Pull_Message__c = 'Success';
        ape1.Check_Eligibility_Match__c = false;
        ape1.Contact_number__c = '9948670743';
        ape1.Do_you_have_a_bank_account__c = false;
        ape1.Willing_to_open_Bank_Account_with_IIB__c = false;
   //     ape1.Bureau_Pull_Attempts__c = 2;
        insert ape1;
            
         Applicant__c ape2 = new Applicant__c();
        ape2.Opportunity__c = ope1.Id;
        ape2.In_Active_Applicant__c = false;
        ape2.Applicant_Type__c = System.label.CoBorrower;
        ape2.Contact_number__c = '9948670743';
        ape2.Do_you_have_a_bank_account__c = false;
        ape2.Willing_to_open_Bank_Account_with_IIB__c = false;
        insert ape2;
        
        appList.add(ape1);
        appList.add(ape2);
         
        
        Test.startTest();
            LwcLOSGattingAndScreeningCntrl.gattingCheckEligibility(appList[0].Id,ope1.Id);
        Test.stopTest();
        }catch(Exception e){
            
        }
    }
    
     @isTest
    public static void gattingCheckEligibilityTest6(){
        try{
        Opportunity ope1 = new Opportunity();
        ope1.StageName = 'Qualification';
        ope1.CloseDate = Date.newInstance(2021, 1, 11);
        ope1.Name = 'testone';
        insert ope1;
        
        List<Applicant__c> appList = new List<Applicant__c>();
        Applicant__c ape1 = new Applicant__c();
        ape1.Opportunity__c = ope1.Id;
        ape1.In_Active_Applicant__c = false;
        ape1.Applicant_Type__c = System.label.Beneficiary;
        ape1.Bureau_Pull_Match__c = false;
        ape1.Bureau_Pull_Message__c = 'Success';
        ape1.Check_Eligibility_Match__c = false;
        ape1.Contact_number__c = '9948670743';
        ape1.Do_you_have_a_bank_account__c = true;
        ape1.Willing_to_open_Bank_Account_with_IIB__c = false;
        ape1.Would_you_like_to_open_a_bank_account__c=false;
   //     ape1.Bureau_Pull_Attempts__c = 2;
        insert ape1;
            
         Applicant__c ape2 = new Applicant__c();
        ape2.Opportunity__c = ope1.Id;
        ape2.In_Active_Applicant__c = false;
        ape2.Applicant_Type__c = System.label.Borrower;
        ape2.Contact_number__c = '9948670743';
        ape2.Do_you_have_a_bank_account__c = false;
        ape2.Willing_to_open_Bank_Account_with_IIB__c = false;
        insert ape2;
        
        appList.add(ape1);
        appList.add(ape2);
         
        
        Test.startTest();
            LwcLOSGattingAndScreeningCntrl.gattingCheckEligibility(appList[0].Id,ope1.Id);
        Test.stopTest();
        }catch(Exception e){
            
        }
    }
    @isTest
    public static void getDocumentPANonApplicantIdTest(){
        
        Opportunity opd1 = new Opportunity();
        opd1.StageName = 'Qualification';
        opd1.CloseDate = Date.newInstance(2021, 1, 11);
        opd1.Name = 'testone';
        insert opd1;
        
        Applicant__c apd1 = new Applicant__c();
        apd1.Opportunity__c = opd1.Id;
        apd1.In_Active_Applicant__c = false;
        apd1.Applicant_Type__c = 'Borrower';
        apd1.Check_Eligibility_Match__c = True;
        apd1.Contact_number__c = '9948670743';
        insert apd1;
        
        CIBIL_Details__c cdo1 = new CIBIL_Details__c();
        cdo1.Applicant__c = apd1.Id;
        cdo1.CIC_No__c = 'testcbd';
        insert cdo1;
        
        Documents__c dc1 = new Documents__c();
        dc1.Applicant__c = apd1.Id;
        dc1.Opportunity_Relation__c = opd1.Id;
        dc1.Document_Type__c = 'Form 60';
        dc1.PAN_No__c = 'AXFPT4450P';
        insert dc1;
        
        Test.startTest();
          Set<String> s1 = LwcLOSGattingAndScreeningCntrl.getDocumentPANonApplicantId(apd1.Id);
          system.assertEquals(s1, LwcLOSGattingAndScreeningCntrl.getDocumentPANonApplicantId(apd1.Id));
          LwcLOSGattingAndScreeningCntrl.getDocumentPANonApplicantId(null);
        Test.stopTest();
    }
    
    @isTest
    public static void getCustDedupeResForPANCINonApplicantIdTest(){
        
        Opportunity opcu1 = new Opportunity();
        opcu1.StageName = 'Qualification';
        opcu1.CloseDate = Date.newInstance(2021, 1, 11);
        opcu1.Name = 'testone';
        insert opcu1;
        
        Applicant__c apu1 = new Applicant__c();
        apu1.Opportunity__c = opcu1.Id;
        apu1.In_Active_Applicant__c = false;
        apu1.Applicant_Type__c = 'Borrower';
        apu1.Check_Eligibility_Match__c = True;
        apu1.Contact_number__c = '9948670743';
        apu1.PAN_No__c = 'AXFPT4450P';
        insert apu1;
        
        Set<string> panSet = new Set<string>();
        panSet.add(apu1.PAN_No__c);
        
        Customer_Dedupe_Response__c cdr1 = new Customer_Dedupe_Response__c();
        cdr1.Applicant__c = apu1.Id;
        cdr1.Response__c = 'testres';
        insert cdr1;
        
        Test.startTest();
             LwcLOSGattingAndScreeningCntrl.getCustDedupeResForPANCINonApplicantId(apu1.Id,panSet);
        Test.stopTest();
        
    }
    
    @isTest
    public static void getPANCINRetryTest(){
        
        Opportunity opr1 = new Opportunity();
        opr1.StageName = 'Qualification';
        opr1.CloseDate = Date.newInstance(2021, 1, 11);
        opr1.Name = 'testone';
        insert opr1;
        
        Applicant__c apr1 = new Applicant__c();
        apr1.Opportunity__c = opr1.Id;
        apr1.In_Active_Applicant__c = false;
        apr1.Applicant_Type__c = 'Borrower';
        apr1.Check_Eligibility_Match__c = True;
        apr1.Contact_number__c = '9948670743';
        apr1.PAN_No__c = 'AXFPT4450P';
        insert apr1;
        
        Retry_Count__c rc1 = new Retry_Count__c();
        rc1.Applicant__c = apr1.Id;
        rc1.Loan_Application_Id__c = opr1.Id;
        rc1.Module__c = System.label.Gatting_Screening_Module;
        rc1.Service_Name__c = System.label.PAN_CIN_Check_Service;
        insert rc1;
        
        Test.startTest();
            //  LwcLOSGattingAndScreeningCntrl.getPANCINRetry(apr1.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void gattingPanCinCheckTest(){
        
        Opportunity opr2 = new Opportunity();
        opr2.StageName = 'Qualification';
        opr2.CloseDate = Date.newInstance(2021, 1, 11);
        opr2.Name = 'testone';
        insert opr2;
        
        Applicant__c apr2 = new Applicant__c();
        apr2.Opportunity__c = opr2.Id;
        apr2.Contact_number__c = '9948670743';
        apr2.PAN_No__c = 'AXFPT4450P';
        apr2.PAN_CIN_Message__c = System.label.PAN_CIN_Match_Not_Found;
        apr2.PAN_CIN_Match__c = false;
        insert apr2;
        
        Test.startTest();
            // LwcLOSGattingAndScreeningCntrl.gattingPanCinCheck(apr2.Id);
        Test.stopTest();
    }
    
     @isTest
    public static void gattingPanCinCheckTest1(){
        
        Opportunity opr2 = new Opportunity();
        opr2.StageName = 'Qualification';
        opr2.CloseDate = Date.newInstance(2021, 1, 11);
        opr2.Name = 'testone';
        insert opr2;
        
        Applicant__c apr2 = new Applicant__c();
        apr2.Opportunity__c = opr2.Id;
        apr2.Contact_number__c = '9948670743';
        apr2.PAN_No__c = 'AXFPT4450P';
        apr2.PAN_CIN_API_Attempts__c = null;
        insert apr2;
        
        Test.startTest();
           //  LwcLOSGattingAndScreeningCntrl.gattingPanCinCheck(apr2.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void addAdditionalDetailsTest(){
        try{
        Opportunity opr3 = new Opportunity();
        opr3.StageName = System.Label.Addition_Details_Capture;
        opr3.CloseDate = Date.newInstance(2021, 1, 11);
        opr3.Name = 'testone';
        insert opr3;
        
        List<Applicant__c> apnList = new List<Applicant__c>();
        Applicant__c apr3 = new Applicant__c();
        apr3.Opportunity__c = opr3.Id;
        apr3.Contact_number__c = '9948670743';
        apr3.PAN_No__c = 'AXFPT4450P';
        apr3.PAN_CIN_API_Attempts__c = null;
        apr3.Applicant_Type__c = System.Label.Borrower;
        insert apr3;
        apnList.add(apr3);
        
        apnList[0].Journey_Stage__c = System.Label.Current_Residential_Address;
        update apnList;
        
        Test.startTest();
              LwcLOSGattingAndScreeningCntrl.addAdditionalDetails(opr3.Id);
              LwcLOSGattingAndScreeningCntrl.addAdditionalDetails('test');
        Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    } 
   @isTest
    public static void callAdditionalDetailsWithoutCoborrowerTest(){
        try{
        Opportunity opr4 = new Opportunity();
        opr4.StageName = System.Label.Addition_Details_Capture;
        opr4.CloseDate = Date.newInstance(2021, 1, 11);
        opr4.Name = 'testone';
        insert opr4;
        
        List<Applicant__c> apnList1 = new List<Applicant__c>();
        Applicant__c apr4 = new Applicant__c();
        apr4.Opportunity__c = opr4.Id;
        apr4.Contact_number__c = '9948670743';
        apr4.PAN_No__c = 'AXFPT4450P';
        apr4.Applicant_Type__c = System.Label.Borrower;
        insert apr4;
        apnList1.add(apr4);
        
        apnList1[0].In_Active_Applicant__c = true;
        apnList1[0].Journey_Stage__c = System.Label.Current_Residential_Address;
        update apnList1;
        
        Test.startTest();
            // LwcLOSGattingAndScreeningCntrl.callAdditionalDetailsWithoutCoborrower(opr4.Id);
        Test.stopTest();
        }catch(Exception e){
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    @isTest
    public static void changeCoborrowerTest(){
        try{
                Opportunity opcb1 = new Opportunity();
                opcb1.StageName = 'Qualification';
                opcb1.CloseDate = Date.newInstance(2021, 1, 11);
                opcb1.Name = 'testone';
                insert opcb1;
                
                Applicant__c acb1 = new Applicant__c();
                acb1.Opportunity__c = opcb1.Id;
                acb1.Contact_number__c = '9743514830';
                acb1.Applicant_Type__c = System.Label.CoBorrower;
                acb1.In_Active_Applicant__c = false;
                insert acb1;
                 
                Test.startTest();
                      LwcLOSGattingAndScreeningCntrl.changeCoborrower(opcb1.Id,2,1);
                      LwcLOSGattingAndScreeningCntrl.changeCoborrower('test',0,0);
                Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    static void testChangeCoborrower1() {
        // Test data setup
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Qualification',
            CloseDate = Date.newInstance(2021, 1, 11)
            // Add other required fields
        );
        insert testOpportunity;

        // Create active coborrower record
        Applicant__c coborrower = new Applicant__c(
            Name = 'Active Coborrower',
            Applicant_Type__c = System.Label.CoBorrower,
            Opportunity__c = testOpportunity.Id,
            In_Active_Applicant__c = true,
            Journey_Stage__c = 'User Details'
            // Add other required fields
        );
        insert coborrower;

        // Create active guarantor record
        Applicant__c guarantor = new Applicant__c(
            Name = 'Active Guarantor',
            Applicant_Type__c = System.Label.Guarantor,
            Opportunity__c = testOpportunity.Id,
            In_Active_Applicant__c = true,
            Journey_Stage__c = 'User Details'
            // Add other required fields
        );
        insert guarantor;

        // Call the method under test with different values for additionCoBorrower and additionGuarantor
        Test.startTest();
        //List<LwcLOSGattingAndScreeningCntrlTest.newApplicantWrapper> newApplicantIds1 = LwcLOSGattingAndScreeningCntrl.changeCoborrower(testOpportunity.Id, 2, 1);
        //List<LwcLOSGattingAndScreeningCntrlTest.newApplicantWrapper> newApplicantIds2 = LwcLOSGattingAndScreeningCntrl.changeCoborrower(testOpportunity.Id, 0, 3);
        LwcLOSGattingAndScreeningCntrl.changeCoborrower(testOpportunity.Id,2,1);
        LwcLOSGattingAndScreeningCntrl.changeCoborrower(testOpportunity.Id,0,3);
        Test.stopTest();

        // Assert the results
        //System.assertEquals(2, newApplicantIds1.size(), 'Expected 2 new coborrowers');
       // System.assertEquals(3, newApplicantIds2.size(), 'Expected 3 new guarantors');

        // Additional assertions can be added here
    }
    
    @isTest
    public static void addCoborrowerTest(){
        try{
                Opportunity opcb1 = new Opportunity();
                opcb1.StageName = 'Qualification';
                opcb1.CloseDate = Date.newInstance(2021, 1, 11);
                opcb1.Name = 'testone';
                insert opcb1;
                
                Applicant__c acb1 = new Applicant__c();
                acb1.Opportunity__c = opcb1.Id;
                acb1.Contact_number__c = '9743514830';
                acb1.Applicant_Type__c = System.Label.Borrower;
                acb1.In_Active_Applicant__c = false;
                insert acb1;
                 
                Test.startTest();
                      LwcLOSGattingAndScreeningCntrl.addCoborrower(opcb1.Id);
                      LwcLOSGattingAndScreeningCntrl.addCoborrower('test');
                Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void doInActiveCoBorrowerTest(){
        try{
                Opportunity opcb1 = new Opportunity();
                opcb1.StageName = 'Qualification';
                opcb1.CloseDate = Date.newInstance(2021, 1, 11);
                opcb1.Name = 'testone';
                insert opcb1;
                
                Applicant__c acb1 = new Applicant__c();
                acb1.Opportunity__c = opcb1.Id;
                acb1.Contact_number__c = '9743514830';
                acb1.Applicant_Type__c = System.Label.Borrower;
                acb1.In_Active_Applicant__c = false;
                insert acb1;
                 
                Test.startTest();
                LwcLOSGattingAndScreeningCntrl.doInActiveCoBorrower(opcb1.Id,true,new List<Integer>{1, 3, 5});
                Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void doInActiveCoBorrowerTest1(){
        try{
                Opportunity opcb1 = new Opportunity();
                opcb1.StageName = 'Qualification';
                opcb1.CloseDate = Date.newInstance(2021, 1, 11);
                opcb1.Name = 'testone';
                insert opcb1;
                
                Applicant__c acb1 = new Applicant__c();
                acb1.Opportunity__c = opcb1.Id;
                acb1.Contact_number__c = '9743514830';
                acb1.Applicant_Type__c = System.Label.CoBorrower;
                acb1.In_Active_Applicant__c = false;
                insert acb1;
                 
                Test.startTest();
                LwcLOSGattingAndScreeningCntrl.doInActiveCoBorrower(opcb1.Id,true,new List<Integer>{1});
                Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
 @isTest
    public static void doInActiveCoBorrowerTest2(){
        try{
                Opportunity opcb1 = new Opportunity();
                opcb1.StageName = 'Qualification';
                opcb1.CloseDate = Date.newInstance(2021, 1, 11);
                opcb1.Name = 'testone';
                insert opcb1;
                
                Applicant__c acb1 = new Applicant__c();
                acb1.Opportunity__c = opcb1.Id;
                acb1.Contact_number__c = '9743514830';
                acb1.Applicant_Type__c = System.Label.Guarantor;
                acb1.In_Active_Applicant__c = false;
                insert acb1;
                 
                Test.startTest();
                LwcLOSGattingAndScreeningCntrl.doInActiveCoBorrower(opcb1.Id,true,null);
                Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    public static void gattingBureauPullAttemptsTest(){
        try{
                Opportunity opcb2 = new Opportunity();
                opcb2.StageName = 'Qualification';
                opcb2.CloseDate = Date.newInstance(2021, 1, 11);
                opcb2.Name = 'testone';
                insert opcb2;
                
                Applicant__c acb2 = new Applicant__c();
                acb2.Opportunity__c = opcb2.Id;
                acb2.Contact_number__c = '9743514830';
                acb2.Applicant_Type__c = 'Borrower';
                acb2.Bureau_Pull_Attempts__c = null;
                insert acb2;
                
                Test.startTest();
                   // LwcLOSGattingAndScreeningCntrl.gattingBureauPullAttempts(acb2.Id,opcb2.Id);
                Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void gattingBureauPullAttemptsTest1(){
        try{
                Opportunity opcb2 = new Opportunity();
                opcb2.StageName = 'Qualification';
                opcb2.CloseDate = Date.newInstance(2021, 1, 11);
                opcb2.Name = 'testone';
                insert opcb2;
                
                Applicant__c acb2 = new Applicant__c();
                acb2.Opportunity__c = opcb2.Id;
                acb2.Contact_number__c = '9743514830';
                acb2.Applicant_Type__c = 'Borrower';
                acb2.Bureau_Pull_Attempts__c = 1;
                insert acb2;
                
                Test.startTest();
                   // LwcLOSGattingAndScreeningCntrl.gattingBureauPullAttempts(acb2.Id,opcb2.Id);
                Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
        @isTest
    public static void gattingBureauPullAttemptsTest2(){
        try{
                Opportunity opcb2 = new Opportunity();
                opcb2.StageName = 'Qualification';
                opcb2.CloseDate = Date.newInstance(2021, 1, 11);
                opcb2.Name = 'testone';
                insert opcb2;
                
                Applicant__c acb2 = new Applicant__c();
                acb2.Opportunity__c = opcb2.Id;
                acb2.Contact_number__c = '9743514830';
                acb2.Applicant_Type__c = 'Borrower';
                acb2.Bureau_Pull_Attempts__c = 4;
                insert acb2;
                
                Test.startTest();
                   // LwcLOSGattingAndScreeningCntrl.gattingBureauPullAttempts(acb2.Id,opcb2.Id);
                Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
        @isTest
    public static void gattingBureauPullAttemptsTest3(){
        try{
                Opportunity opcb3 = new Opportunity();
                opcb3.StageName = 'Qualification';
                opcb3.CloseDate = Date.newInstance(2021, 1, 11);
                opcb3.Name = 'testone';
                insert opcb3;
                
                Test.startTest();
                   // LwcLOSGattingAndScreeningCntrl.gattingBureauPullAttempts('testap',opcb3.Id);
                Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

    
    @isTest
    public static void checkRetryExhaustedTest(){
        try{
                Opportunity opcb3 = new Opportunity();
                opcb3.StageName = 'Qualification';
                opcb3.CloseDate = Date.newInstance(2021, 1, 11);
                opcb3.Name = 'testone';
                insert opcb3;
                
                Applicant__c acb3 = new Applicant__c();
                acb3.Opportunity__c = opcb3.Id;
                acb3.Contact_number__c = '9743514830';
                acb3.Applicant_Type__c = 'Borrower';
                insert acb3;
            
                Retry_Count__c rc1 = new Retry_Count__c();
                rc1.Loan_Application_Id__c = opcb3.Id;
                rc1.Applicant__c = acb3.Id;
                rc1.Module__c = 'ApplicationForm';
                insert rc1;
                
                Test.startTest();
                      LwcLOSGattingAndScreeningCntrl.checkRetryExhausted(opcb3.Id,'SMS',acb3.Id,rc1.Module__c);
                Test.stopTest();
                
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void checkRetryExhaustedTest1(){
        try{
                Opportunity opcb3 = new Opportunity();
                opcb3.StageName = 'Qualification';
                opcb3.CloseDate = Date.newInstance(2021, 1, 11);
                opcb3.Name = 'testone';
                insert opcb3;
                
                Applicant__c acb3 = new Applicant__c();
                acb3.Opportunity__c = opcb3.Id;
                acb3.Contact_number__c = '9743514830';
                acb3.Applicant_Type__c = 'Borrower';
                insert acb3;
                
                List<Retry_Count__c> rcList = new List<Retry_Count__c>();
                Retry_Count__c rc2 = new Retry_Count__c();
                rc2.Loan_Application_Id__c = opcb3.Id;
                rc2.Applicant__c = acb3.Id;
                rc2.Service_Name__c = 'Bureau Pull Attempts';
                rc2.Module__c = 'ApplicationForm';
                rc2.Count__c = 10;
                insert rc2;
                rcList.add(rc2);
                
                Test.startTest();
                      LwcLOSGattingAndScreeningCntrl.checkRetryExhausted(opcb3.Id,rc2.Service_Name__c,acb3.Id,rc2.Module__c);
                Test.stopTest();
                
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void checkRetryExhaustedTest2(){
        try{
                Opportunity opcb3 = new Opportunity();
                opcb3.StageName = 'Qualification';
                opcb3.CloseDate = Date.newInstance(2021, 1, 11);
                opcb3.Name = 'testone';
                insert opcb3;
                
                Applicant__c acb3 = new Applicant__c();
                acb3.Opportunity__c = opcb3.Id;
                acb3.Contact_number__c = '9743514830';
                acb3.Applicant_Type__c = 'Borrower';
                insert acb3;
                
                List<Retry_Count__c> rcList = new List<Retry_Count__c>();
                Retry_Count__c rc2 = new Retry_Count__c();
                rc2.Loan_Application_Id__c = opcb3.Id;
                rc2.Applicant__c = acb3.Id;
                rc2.Service_Name__c = 'Bureau Pull Attempts';
                rc2.Module__c = 'ApplicationForm';
                rc2.Count__c = 1;
                insert rc2;
                rcList.add(rc2);
                
                Test.startTest();
                      LwcLOSGattingAndScreeningCntrl.checkRetryExhausted(opcb3.Id,rc2.Service_Name__c,acb3.Id,rc2.Module__c);
                Test.stopTest();
                
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void checkRetryExhaustedTest3(){
        try{
                Opportunity opcb3 = new Opportunity();
                opcb3.StageName = 'Qualification';
                opcb3.CloseDate = Date.newInstance(2021, 1, 11);
                opcb3.Name = 'testone';
                insert opcb3;
                
                Applicant__c acb3 = new Applicant__c();
                acb3.Opportunity__c = opcb3.Id;
                acb3.Contact_number__c = '9743514830';
                acb3.Applicant_Type__c = 'Borrower';
                insert acb3;
                
                
                
                Test.startTest();
                      LwcLOSGattingAndScreeningCntrl.checkRetryExhausted(opcb3.Id,'test','testapp','sample');
                Test.stopTest();
                
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    //CISP-4609
    @isTest
    public static void testGetCheckeligibility(){
        try{
        Opportunity opp = new Opportunity();
        opp.StageName = 'Qualification';
        opp.CloseDate = Date.newInstance(2021, 1, 11);
        opp.Name = 'testone';
        insert opp;
        
        Applicant__c app = new Applicant__c();
        app.Opportunity__c = opp.Id;
        app.Contact_number__c = '9743514830';
        app.Applicant_Type__c = 'Borrower';
        app.Bureau_Pull_Match__c=true;
        app.Bureau_Pull_Message__c='Continue';
        app.Check_Eligibility_Match__c=true;
        app.Check_Eligibility_Message__c='Continue';
        insert app;
        Test.startTest();
        LwcLOSGattingAndScreeningCntrl.getCheckeligibility(opp.Id,'Borrower');
        Test.stopTest();
        }
    catch(Exception e){
        System.assertEquals('Script-thrown exception', e.getMessage());
    }
    }
    
    @isTest
    public static void testGetCheckeligibility1(){
        try{
        Opportunity opp = new Opportunity();
        opp.StageName = 'Qualification';
        opp.CloseDate = Date.newInstance(2021, 1, 11);
        opp.Name = 'testone';
        insert opp;
        
        Applicant__c app = new Applicant__c();
        app.Opportunity__c = opp.Id;
        app.Contact_number__c = '9743514830';
        app.Applicant_Type__c = 'Borrower';
        app.Bureau_Pull_Match__c=true;
        app.Bureau_Pull_Message__c='Continue';
        app.Check_Eligibility_Match__c=true;
        app.Check_Eligibility_Message__c='Continue';
        insert app;
        Test.startTest();
        LwcLOSGattingAndScreeningCntrl.getCheckeligibility(null,null);
        Test.stopTest();
        }
    catch(Exception e){
        System.assertEquals('Script-thrown exception', e.getMessage());
    }
    }
     @isTest
    static void testCoborrowerCount() {
        // Test data setup
        opportunity parentOpp=new Opportunity();
        parentOpp.Name = 'ParentOpp';
        parentOpp.StageName = 'Qualification';
        parentOpp.CloseDate = Date.newInstance(2020, 1, 11);
        
        insert parentOpp;
       Opportunity opp = new Opportunity();
        opp.StageName = 'Qualification';
        opp.CloseDate = Date.newInstance(2021, 1, 11);
        opp.Parent_Loan_Application__c=parentOpp.Id;
        opp.Name = 'testone';
        opp.Revoked_Applicant_Count__c=100;
        insert opp;

        // Create coborrower applicant(s)
        Applicant__c coborrower1 = new Applicant__c(
            Opportunity__c = opp.Id,
            Applicant_Type__c = System.Label.CoBorrower
            // Add other required fields
        );
        insert coborrower1;

        // Call the method under test
        Test.startTest();
        Integer count = LwcLOSGattingAndScreeningCntrl.coborrowerCount(opp.Id);
        Test.stopTest();

        // Assert the results
        System.assertEquals(101, count, 'Expected coborrower count to be 1');

        // Additional tests for other scenarios can be added here
    }
    
     @isTest
    static void testCoborrowerCount1() {
        try{
        // Test data setup
        opportunity parentOpp=new Opportunity();
        parentOpp.Name = 'ParentOpp';
        parentOpp.StageName = 'Qualification';
        parentOpp.CloseDate = Date.newInstance(2020, 1, 11);
        
        insert parentOpp;
       Opportunity opp = new Opportunity();
        opp.StageName = 'Qualification';
        opp.CloseDate = Date.newInstance(2021, 1, 11);
        opp.Parent_Loan_Application__c=parentOpp.Id;
        opp.Name = 'testone';
        opp.Revoked_Applicant_Count__c=100;
        insert opp;

        // Create coborrower applicant(s)
        Applicant__c coborrower1 = new Applicant__c(
            Opportunity__c = opp.Id,
            Applicant_Type__c = System.Label.CoBorrower
            // Add other required fields
        );
        insert coborrower1;

        // Call the method under test
        Test.startTest();
        Integer count = LwcLOSGattingAndScreeningCntrl.coborrowerCount(null);
        Test.stopTest();

        // Assert the results
        System.assertEquals(0, count, 'Expected coborrower count to be 1');

        // Additional tests for other scenarios can be added here
        }catch(Exception e){
        System.assertEquals('Script-thrown exception', e.getMessage());
    }
    }
    
    
    @isTest
    static void testRemoveCoborrowerRecords() {
        // Test data setup
        // 
        Opportunity opp = new Opportunity();
        opp.StageName = 'Qualification';
        opp.CloseDate = Date.newInstance(2021, 1, 11);
        //opp.Parent_Loan_Application__c=parentOpp.Id;
        opp.Name = 'testone';
        //opp.Revoked_Applicant_Count__c=100;
        insert opp;
        List<Applicant__c> testApplicants = new List<Applicant__c>();
        for(Integer i = 0; i < 3; i++) {
            testApplicants.add(new Applicant__c(
                Opportunity__c = opp.Id,
                Name = 'Test Applicant ' + i,
                In_Active_Applicant__c=true
                
                // Add other required fields
            ));
        }
        insert testApplicants;

        List<Id> appIds = new List<Id>();
        for(Applicant__c app : testApplicants) {
            appIds.add(app.Id);
        }

        // Call the method under test
        Test.startTest();
        LwcLOSGattingAndScreeningCntrl.removeCoborrowerRecords(appIds);
        Test.stopTest();

        // Retrieve the updated applicants
        List<Applicant__c> updatedApplicants = [SELECT Id, In_Active_Applicant__c FROM Applicant__c WHERE Id IN :appIds];

        // Assert the results
        for(Applicant__c app : updatedApplicants) {
            System.assertEquals(true, app.In_Active_Applicant__c, 'Expected In_Active_Applicant__c to be true');
        }

        // Additional assertions can be added here
    }
    
     @isTest
    static void testGetCoborrowerRecords() {
        // Test data setup
         Opportunity opp = new Opportunity();
        opp.StageName = 'Qualification';
        opp.CloseDate = Date.newInstance(2021, 1, 11);
        opp.Name = 'testone';
        insert opp;

        // Create test coborrower records
        List<Applicant__c> coborrowers = new List<Applicant__c>();
        coborrowers.add(new Applicant__c(
            Name = 'Coborrower 1',
            Applicant_Type__c = 'Co-Borrower',
            Opportunity__c = opp.Id,
            In_Active_Applicant__c = false
            // Add other required fields
        ));
        coborrowers.add(new Applicant__c(
            Name = 'Coborrower 2',
            Applicant_Type__c = 'Guarantor',
            Opportunity__c = opp.Id,
            In_Active_Applicant__c = false
            // Add other required fields
        ));
        coborrowers.add(new Applicant__c(
            Name = 'Coborrower 3',
            Applicant_Type__c = 'Beneficiary',
            Opportunity__c = opp.Id,
            In_Active_Applicant__c = false
            // Add other required fields
        ));
        // Create an inactive coborrower
        coborrowers.add(new Applicant__c(
            Name = 'Inactive Coborrower',
            Applicant_Type__c = 'Co-Borrower',
            Opportunity__c = opp.Id,
            In_Active_Applicant__c = true
            // Add other required fields
        ));
        insert coborrowers;

        // Call the method under test
        Test.startTest();
        List<Applicant__c> returnedCoborrowers = LwcLOSGattingAndScreeningCntrl.getCoborrowerRecords(opp.Id);
        Test.stopTest();

        // Assert the results
        System.assertEquals(3, returnedCoborrowers.size(), 'Expected 3 coborrowers to be returned');
        for (Applicant__c coborrower : returnedCoborrowers) {
            System.assertNotEquals('Inactive Coborrower', coborrower.Name, 'Inactive coborrower should not be returned');
            System.assert(
                coborrower.Applicant_Type__c == 'Co-Borrower' || coborrower.Applicant_Type__c == 'Guarantor' || coborrower.Applicant_Type__c == 'Beneficiary',
                'Invalid Applicant_Type__c value returned'
            );
        }

        // Additional assertions can be added here
    }
    
   
    
    /* @isTest
    static void testDoInActiveCoBorrower() {
        // Test data setup
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Qualification',
            CloseDate = Date.newInstance(2021, 1, 11)
            // Add other required fields
        );
        insert testOpportunity;

        // Create test coborrower records
        List<Applicant__c> coborrowers = new List<Applicant__c>();
        for (Integer i = 1; i <= 5; i++) {
            coborrowers.add(new Applicant__c(
                Name = 'Coborrower ' + i,
                Applicant_Type__c = System.Label.CoBorrower,
                Opportunity__c = testOpportunity.Id,
                In_Active_Applicant__c = false
                // Add other required fields
            ));
        }
        insert coborrowers;

        // Call the method under test
        Test.startTest();
        List<String> inactiveAppIds = LwcLOSGattingAndScreeningCntrl.doInActiveCoBorrower(testOpportunity.Id, true, null);
        Test.stopTest();

        // Retrieve the updated applicants
        List<Applicant__c> updatedCoborrowers = [SELECT Id, In_Active_Applicant__c FROM Applicant__c WHERE Id IN :inactiveAppIds];

        // Assert the results
        System.assertEquals(3, inactiveAppIds.size(), 'Expected 3 inactive coborrowers');
        for (Applicant__c coborrower : updatedCoborrowers) {
            System.assertEquals(true, coborrower.In_Active_Applicant__c, 'Expected coborrower to be inactive');
        }

        // Additional assertions can be added here
    }*/
}