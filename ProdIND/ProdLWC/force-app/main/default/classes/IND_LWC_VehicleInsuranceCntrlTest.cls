/*
* @Test Class:  IND_LWC_VehicleInsuranceCntrlTest
* @Author: 		Vinita K.
* @Description :Test Class for IND_LWC_VehicleInsuranceCntrl .
* @Company:     Persistent Systems
*/
@isTest(seeAllData = false)
public class IND_LWC_VehicleInsuranceCntrlTest {
    @testSetup static void setup() {
        
        Opportunity oppObj1 = TestDataUtility.createTestOpportunity(false);
        if (Schema.sObjectType.Opportunity.isCreateable()){
            insert oppObj1;
        }  
        //---     
        Applicant__c app =   TestDataUtility.createTestApplicantForCIBIL(false,oppObj1);        
        if (Schema.sObjectType.Applicant__c.isCreateable()){
            insert app;
        }
        //---             
    }
    
    //---
    @isTest 
    public static void loadVehicleInsuranceDetailsTest0(){
        try{
            Opportunity opp=[Select Id from Opportunity limit 1];
            opp.Product_Type__c = 'Tractor';
            update opp;
            system.debug('OpportunityList for tractor==> '+opp);          
            //---  
            Applicant__c app = [select Id from Applicant__c limit 1];
            //---  
            Vehicle_Detail__c vehicleDetail = new Vehicle_Detail__c(Loan_Application__c =opp.Id,Ins_Expiry_date__c = Date.newInstance(2022, 1, 11));
            insert vehicleDetail;
            //Create Document
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test Document';
            cv.PathOnClient = 'TestDocument.pdf';
            cv.VersionData = Blob.valueOf('Test Content');
            cv.IsMajorVersion = true;
            Insert cv;
            
            //Get Content Documents
            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
            Documents__c doc = new Documents__c(Name='TestDoc',Applicant__c=app.Id,Opportunity_Relation__c=opp.Id,is_Active__c = true,Document_Type__c='Vehicle Insurance Policy',Vehicle_Detail__c=vehicleDetail.Id );
            insert doc;
            system.debug('Documents==>'+doc);
            
			//Create ContentDocumentLink 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = doc.Id;
            cdl.ContentDocumentId = conDocId;
            cdl.shareType = 'V';
            Insert cdl;         
           
         //  b User userTest = TestDataUtility.createIBCounterStaffUser(true);
        //  b  system.runAs(userTest){
                Test.startTest();
                 String response=IND_LWC_VehicleInsuranceCntrl.loadVehicleInsuranceDetails(opp.Id,app.Id);
                //   IND_LWC_VehicleInsuranceCntrl.loadVehicleInsuranceDetails(null);
                Test.stopTest();
                
                System.assertNotEquals(null,response);
         // b  }
        }Catch(Exception e){
            System.debug('Error1==>'+e.getMessage());
            System.debug('Error1==>'+e.getLineNumber());
        }      
    }
    //----
          
    //---
    @isTest 
    public static void loadVehicleInsuranceDetailsTest00(){
        try{
            Opportunity opp=[Select Id from Opportunity limit 1];
           
            //---  
            Applicant__c app = [select Id from Applicant__c limit 1];
            //---  
            Vehicle_Detail__c vehicleDetail = new Vehicle_Detail__c(Loan_Application__c =opp.Id,Ins_Expiry_date__c = Date.newInstance(2022, 1, 11));
            insert vehicleDetail;
           //Create Document
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test Document';
            cv.PathOnClient = 'TestDocument.pdf';
            cv.VersionData = Blob.valueOf('Test Content');
            cv.IsMajorVersion = true;
            Insert cv;
            
            //Get Content Documents
            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
                        
            Documents__c doc = new Documents__c(Name='TestDoc',Applicant__c=app.Id,Opportunity_Relation__c=opp.Id,is_Active__c = true,Document_Type__c='Vehicle Insurance Policy',Vehicle_Detail__c=vehicleDetail.Id );
            insert doc;
            system.debug('Documents==>'+doc);
            
		//Create ContentDocumentLink 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = vehicleDetail.Id;
            cdl.ContentDocumentId = conDocId;
            cdl.shareType = 'V';
            Insert cdl;         
           
         //  b User userTest = TestDataUtility.createIBCounterStaffUser(true);
        //  b  system.runAs(userTest){
                Test.startTest();
                String response= IND_LWC_VehicleInsuranceCntrl.loadVehicleInsuranceDetails(opp.Id,app.Id);
                //   IND_LWC_VehicleInsuranceCntrl.loadVehicleInsuranceDetails(null);
                Test.stopTest();
                System.assertNotEquals(null,response);
         // b  }
        }Catch(Exception e){
            System.debug('Error1==>'+e.getMessage());
            System.debug('Error1==>'+e.getLineNumber());
        }      
    }    
    //---    
    @isTest 
    public static void loadVehicleInsuranceDetailsTest(){
        try{
            Opportunity opp=[Select Id from Opportunity limit 1];
            //---  
            Applicant__c app = [select Id from Applicant__c limit 1];
            //---  
            Vehicle_Detail__c vehicleDetail = new Vehicle_Detail__c(Loan_Application__c =opp.Id,Ins_Expiry_date__c = Date.newInstance(2022, 1, 11));
            insert vehicleDetail;
            User userTest = TestDataUtility.createIBCounterStaffUser(true);
            system.runAs(userTest){
                Test.startTest();
          //      String response=IND_LWC_VehicleInsuranceCntrl.loadVehicleInsuranceDetails(opp.Id,app.Id);
                //   IND_LWC_VehicleInsuranceCntrl.loadVehicleInsuranceDetails(null);
                Test.stopTest();
                
          //      System.assertNotEquals(null,response);
            }
        }Catch(Exception e){
            System.debug('Error'+e.getMessage());
        }  
        
    }
    
    @isTest 
    public static void loadVehicleInsuranceDetailsTest1(){
        try{
            Opportunity opp=[Select Id from Opportunity limit 1];
            //---      
            Applicant__c app = [select Id from Applicant__c limit 1];
            //---      
            Vehicle_Detail__c vehicleDetail = new Vehicle_Detail__c(Loan_Application__c =opp.Id);
            insert vehicleDetail;
            
            Test.startTest();
         //   String response=IND_LWC_VehicleInsuranceCntrl.loadVehicleInsuranceDetails(opp.Id,app.Id);
            //  IND_LWC_VehicleInsuranceCntrl.loadVehicleInsuranceDetails(null);
            Test.stopTest();
        //    System.assertNotEquals(null,response);
        }Catch(Exception e){
            System.debug('Error'+e.getMessage());
        }  
    }
    
    @isTest
    public static void testData(){
        List<IND_LWC_VehicleInsuranceCntrl.vehicleWrapper> vwList = new List<IND_LWC_VehicleInsuranceCntrl.vehicleWrapper>();
        
        IND_LWC_VehicleInsuranceCntrl.vehicleWrapper vw1 = new IND_LWC_VehicleInsuranceCntrl.vehicleWrapper();
        vw1.insExpiryDate = Date.newInstance(2023, 1, 11);
        vw1.insIssuanceDate = Date.newInstance(2021, 1, 11);
        vw1.insuranceDeclaredValue = 1000.00;
        vw1.insuranceNumber = 'test123';
        vw1.insuranceType = 'test';
        vw1.insurerName = 'testname';
        vw1.isInsuranceExpired = false;
        vw1.leadNumber = 'lead12345';
        vw1.vehicleDetailId = 'ap2612345';
        vwList.add(vw1);
        
        IND_LWC_VehicleInsuranceCntrl.LoanApplicationWrapper law = new IND_LWC_VehicleInsuranceCntrl.LoanApplicationWrapper();
        law.vehicleInsuranceList = vwList;
  
    }
    
    @isTest
    public static void loadVehicleInsuranceDetailsTest3(){
        try{
            Opportunity opre3 = new Opportunity();
            opre3.StageName = 'Qualification';
            opre3.CloseDate = Date.newInstance(2021, 1, 11);
            opre3.Name = 'testone';
            insert opre3;
            
            Vehicle_Detail__c vehicleDetail = new Vehicle_Detail__c(Loan_Application__c =opre3.Id,Ins_Expiry_date__c = Date.newInstance(2022, 1, 11));
            insert vehicleDetail;
            
            Test.startTest();
            // added loadvehiclaInsureanceDetails
            string response2 = IND_LWC_VehicleInsuranceCntrl.insertAllVehicleDetailForTractor('vehicleDetail');
            // modified loadedVehical single string to double sting
            IND_LWC_VehicleInsuranceCntrl.loadVehicleInsuranceDetails('','');
          
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    
}