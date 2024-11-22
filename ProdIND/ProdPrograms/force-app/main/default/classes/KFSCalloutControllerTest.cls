@isTest
private class KFSCalloutControllerTest {

    @isTest
    static void doKFSt_SMSTest(){
        try{
                    Opportunity oppp = new Opportunity(Name='Test Opportunity', Product_Type__c='Two Wheeler',Deal_Number__c='12345',CloseDate=Date.today(), StageName='Prospecting');
insert oppp;
                Key_Fact_Statement__c kfsParent = new Key_Fact_Statement__c(Name = 'Test KFS Parent', Deal_Number__c = '12345');
insert kfsParent;


                    // String kfsRequestString = '{"pcdId":"","loanApplicationId"::"'+oppp.Id+',"fromProCredit":false,"Unique_Id":"123","dealId":""}';
           String kfsRequestString =  JSON.serialize(new Map<String, Object>{'pcdId' => '','mobileNumber'=>'999999999', 'loanApplicationId' => oppp.Id,'fromProCredit' => false,'kfsId'=>kfsParent.Id,'kfsOtp'=>'1234','flag'=> 'KFS','dealId' => ''});
            
                    Test.startTest();
           
                    KFSCalloutController.doKFSSmsGatewayAPI(kfsRequestString);
            
            HttpResponse response = new HttpResponse();
response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5njZcJY00rL9wJSIMpbrzEBGczzs/qwlKFOA2/srolJ6l1djQPyCsWPhGnh7CqucCWPqwsLVYtyAskLBb8ekrCuV0I6EWnt6casm2A8pwPwYHxSL8yywIJdbrxEST5SXCk89YNYIsjy2D9FbOnFDumHX7HlvBul4+CmM9EX+8hBXhQ=="}');
response.setStatusCode(200);
         
            Test.stopTest();  
             } catch(Exception ex){
System.debug('error ---> ' + ex.getMessage());
System.debug('error ---> ' + ex.getLineNumber());
    }     
    }
   
@isTest
    static void testIsPaymentRequestGeneratedd() {
        
        
        Opportunity oppp = new Opportunity(Name='Test Opportunity', CloseDate=Date.today(), StageName='Prospecting');
        insert oppp;

        // Create vehicle details with no payment requests
        Vehicle_Detail__c vehicleDetaill = new Vehicle_Detail__c(Loan_Application__c = oppp.Id, Payment_requested__c=Date.today());
        insert vehicleDetaill;


        Test.startTest();
        
        
        Boolean resultt = KFSCalloutController.isPaymentRequestGenerated(oppp.Id);
     
        Test.stopTest();
    }

    @isTest
    static void testIsPaymentRequestGenerated() {
        Opportunity opp = new Opportunity(Name='Test Opportunity', CloseDate=Date.today(), StageName='Prospecting');
        insert opp;

        // Create vehicle details with no payment requests
        Vehicle_Detail__c vehicleDetail = new Vehicle_Detail__c(Loan_Application__c = opp.Id,Payment_requested__c=null);
        insert vehicleDetail;
        
        


        Test.startTest();
        
        Boolean result = KFSCalloutController.isPaymentRequestGenerated(opp.Id);
       
     
        Test.stopTest();
    }
    
    
    
/*
    @isTest
    static void testGetVehicleRecordId() {
        Opportunity opp = new Opportunity(Name='Test Opportunity', CloseDate=Date.today(), StageName='Prospecting');
        insert opp;

        Vehicle_Detail__c vehicleDetail = new Vehicle_Detail__c(Loan_Application__c = opp.Id, Deal_Number__c = 'dealId123');
        insert vehicleDetail;

        Test.startTest();
        
        String vehicleId = KFSCalloutController.getVehicleRecordId(opp.Id, 'dealId123');
       
        
        Test.stopTest();
    }
*/

    @isTest
    static void testCreateDocument() {
        Opportunity opp = new Opportunity(Name='Test Opportunity', CloseDate=Date.today(), StageName='Credit Processing');
        insert opp;
        
        Vehicle_Detail__c vehicleDetail = new Vehicle_Detail__c(Loan_Application__c = opp.Id);
        insert vehicleDetail;
                
	Applicant__c apfu1 = new Applicant__c();
                apfu1.Opportunity__c = opp.Id;
                apfu1.Contact_number__c = '9743514830';
                apfu1.Applicant_Type__c = 'Borrower';
                insert apfu1;
                
        
        Documents__c dfu1 = new Documents__c();
               dfu1.RecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('Other Documents').getRecordTypeId();
                 dfu1.Opportunity_Relation__c = opp.Id;
                 dfu1.Document_Type__c = 'KFS';
        dfu1.Applicant__c = apfu1.Id;
       dfu1.Is_Active__c=true;
        
        dfu1.Vehicle_Detail__c = vehicleDetail.id;
                 insert dfu1;
        
        

        

        Test.startTest();
        
        String docId = KFSCalloutController.createDocument(vehicleDetail.Id, opp.Id, true);
        //String doccId = KFSCalloutController.createDocument(vehicleDetail.Id, opp.Id, false);
        //System.assertNotEquals(null, docId);
        
        Test.stopTest();
    }

    
    
    @isTest
    static void testCreateDocument2() {
        Opportunity opp = new Opportunity(Name='Test Opportunity', CloseDate=Date.today(), StageName='Credit Processing');
        insert opp;
        
        Vehicle_Detail__c vehicleDetail = new Vehicle_Detail__c(Loan_Application__c = opp.Id);
        insert vehicleDetail;
                
	Applicant__c apfu1 = new Applicant__c();
                apfu1.Opportunity__c = opp.Id;
                apfu1.Contact_number__c = '9743514830';
                apfu1.Applicant_Type__c = 'Borrower';
                insert apfu1;
                
        
     
         Documents__c dfu1 = new Documents__c();
               dfu1.RecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('Other Documents').getRecordTypeId();
                 dfu1.Opportunity_Relation__c = opp.Id;
                 dfu1.Document_Type__c = 'KFS';
        dfu1.Applicant__c = apfu1.Id;
       dfu1.Is_Active__c=true;
        
                 insert dfu1;

        

        Test.startTest();
        
        String docId = KFSCalloutController.createDocument(vehicleDetail.Id, opp.Id, false);
        //String doccId = KFSCalloutController.createDocument(vehicleDetail.Id, opp.Id, false);
        //System.assertNotEquals(null, docId);
        
        Test.stopTest();
    }
    
    
    
    
    @isTest
    static void testGetFinalOfferDetails() {
        Opportunity opp = new Opportunity(Application_number__c='3y7y27',Name='Test Opportunity', Journey_Status__c='Stop',CloseDate=Date.today(), StageName='Prospecting', Product_Type__c='Tractor');
        insert opp;
        
        Applicant__c apfu1 = new Applicant__c();
                apfu1.Opportunity__c = opp.Id;
                apfu1.Contact_number__c = '9743514830';
                apfu1.Applicant_Type__c = 'Borrower';
            apfu1.Name='test';
                insert apfu1;
        
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
           // dl.Sub_Stage__c = 'test';
            insert dl;
        
        Vehicle_Detail__c vehicleDetail = new Vehicle_Detail__c(Variant__c='Test',Loan_Application__c = opp.Id,Deal_Number__c=dl.id);
        insert vehicleDetail;
		
        
        Final_Term__c ft = new Final_Term__c();
            ft.CRM_IRR__c = 120;
        ft.Loan_amount__c='111111';
        ft.Required_CRM_IRR__c='20';
            ft.Loan_Application__c = opp.Id;
            ft.Holiday_period__c='30';
        ft.No_of_Installment__c=1;
        ft.Net_IRR__c=1;
        ft.Gross_IRR__c=1;
            ft.EMI_Amount__c= 10000;
            ft.FIwaiver_offAddress__c = 'Not Waived';
        ft.Vehicle_Detail__c = vehicleDetail.id;
            ft.Installment_Type__c ='Structured';
        insert ft;
        Test.startTest();
        
        KFSCalloutController.FinalOfferDetails details = KFSCalloutController.getFinalOfferDetails(opp.Id, dl.id);
        //System.assertNotEquals(null, details);
        
        Test.stopTest();
    }
    
    
    @isTest
    static void testGetFinalOfferDetails2() {
        Opportunity opp = new Opportunity(LeadSource='OLA',Application_number__c='3y7y27',Name='Test Opportunity', Journey_Status__c='Stop',CloseDate=Date.today(), StageName='Prospecting', Product_Type__c='Two Wheeler');
        insert opp;
        
        Applicant__c apfu1 = new Applicant__c();
                apfu1.Opportunity__c = opp.Id;
                apfu1.Contact_number__c = '9743514830';
                apfu1.Applicant_Type__c = 'Borrower';
            apfu1.Name='test';
                insert apfu1;
        
       
		
        
        Final_Term__c ft = new Final_Term__c();
            ft.CRM_IRR__c = 120;
        ft.Loan_amount__c='111111';
        ft.Required_CRM_IRR__c='20';
            ft.Loan_Application__c = opp.Id;
            ft.Holiday_period__c='30';
        ft.No_of_Installment__c=1;
        ft.Net_IRR__c=1;
        ft.Gross_IRR__c=1;
            ft.EMI_Amount__c= 10000;
            ft.FIwaiver_offAddress__c = 'Not Waived';
   ft.Tenure__c='12';
            ft.Installment_Type__c ='Structured';
        insert ft;
        Test.startTest();
        
        KFSCalloutController.FinalOfferDetails details = KFSCalloutController.getFinalOfferDetails(opp.Id,'');
        //System.assertNotEquals(null, details);
        
        Test.stopTest();
    }

@isTest
    static void testCreateDocumennnttt() {
        Opportunity opp = new Opportunity(Name='Test Opportunity', CloseDate=Date.today(), StageName='Credit Processing');
        insert opp;
        
        Vehicle_Detail__c vehicleDetail = new Vehicle_Detail__c(Loan_Application__c = opp.Id);
        insert vehicleDetail;
                
	Applicant__c apfu1 = new Applicant__c();
                apfu1.Opportunity__c = opp.Id;
                apfu1.Contact_number__c = '9743514830';
                apfu1.Applicant_Type__c = 'Borrower';
        apfu1.In_Active_Applicant__c=false;
                insert apfu1;
                
        
 
        
        

        

        Test.startTest();
        
        String docId = KFSCalloutController.createDocument(vehicleDetail.Id, opp.Id, false);
        //String doccId = KFSCalloutController.createDocument(vehicleDetail.Id, opp.Id, false);
        //System.assertNotEquals(null, docId);
        
        Test.stopTest();
    }
    
      @isTest
    static void testCreateDocumennnt() {
        Opportunity opp = new Opportunity(Name='Test Opportunity', CloseDate=Date.today(), StageName='Credit Processing');
        insert opp;
        
        Vehicle_Detail__c vehicleDetail = new Vehicle_Detail__c(Loan_Application__c = opp.Id);
        insert vehicleDetail;
                
	Applicant__c apfu1 = new Applicant__c();
                apfu1.Opportunity__c = opp.Id;
                apfu1.Contact_number__c = '9743514830';
                apfu1.Applicant_Type__c = 'Borrower';
        apfu1.In_Active_Applicant__c=false;
                insert apfu1;
                
        
 
        
        

        

        Test.startTest();
        
        String docId = KFSCalloutController.createDocument(vehicleDetail.Id, opp.Id, true);
        //String doccId = KFSCalloutController.createDocument(vehicleDetail.Id, opp.Id, false);
        //System.assertNotEquals(null, docId);
        
        Test.stopTest();
    }
}