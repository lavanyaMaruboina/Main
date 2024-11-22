@isTest
public class IND_RCLimitCheckRequestTest {
    @testSetup
    static void setup()
    {        
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL CVO'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',MobilePhone = '9999999999',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod123@indusbank11.com');
        insert u;
        System.runAs(u) 
        {
            //create Oppty records
            Opportunity opgd1 = new Opportunity();
            opgd1.StageName = 'Qualification';
            opgd1.CloseDate = Date.newInstance(2021, 1, 11);
            opgd1.Name = 'testone';
            opgd1.Product_Type__c = 'Two Wheeler';
            opgd1.Vehicle_Type__c = 'New';
            opgd1.Application_number__c ='A29032200002';
            if(Schema.sObjectType.Opportunity.isCreateable()){
                insert opgd1;
            }
            
            Opportunity opgd2 = new Opportunity();
            opgd2.StageName = 'Qualification';
            opgd2.CloseDate = Date.newInstance(2021, 1, 11);
            opgd2.Name = 'testone1';
            opgd2.Product_Type__c = 'Tractor';
            opgd2.Vehicle_Type__c = 'New';
            opgd2.Application_number__c ='A29032200003';
            if(Schema.sObjectType.Opportunity.isCreateable()){
                insert opgd2;
            }
            
            Deal_Number__c dealNumber = TestDataUtility.createDealNumber(true,opgd2);
            
            //Create Applicant__c Data
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c = opgd1.Id;
            applicant.Applicant_Type__c  = null;
            applicant.Scorecard_Decision__c = 'Red';
            applicant.Opportunity__r = opgd1; 
            if(Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }                       
            
            Applicant__c applicant1 = TestDataUtility.createTestApplicantForSMS(false);
            applicant1.Opportunity__c = opgd2.Id;
            applicant1.Applicant_Type__c  = null;
            applicant1.Scorecard_Decision__c = 'Orange';
            applicant1.Opportunity__r = opgd2; 
            if(Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant1;
            }     
            
            //create Vehicle_Detail__c record
            Vehicle_Detail__c  vehicleDetail =  TestDataUtility.createTestVehicleDetailForIbb(false, opgd1);
            vehicleDetail.Loan_Application__c = opgd1.Id;
            vehicleDetail.Product__c = 'Two Wheeler';
            vehicleDetail.Ben_Code__c ='testveh';
            vehicleDetail.Variant__c = 'JAWA Variant';
            if (Schema.sObjectType.Vehicle_Detail__c.isCreateable()){
                insert vehicleDetail;
            }        
            
            Final_Term__c  finalDetails =  new Final_Term__c();
            finalDetails.Loan_Application__c = opgd1.Id;
            finalDetails.Referrer_Ben_Code__c ='Ben10101';
            finalDetails.Loan_Amount__c = '100000';
            
            insert finalDetails; 
            
            Product2 pd1 = new Product2();
            pd1.Asset_Category__c = '';
            pd1.Name = 'JAWA Variant';
            pd1.Type__c = 'variant';
            pd1.External_Reference_Id__c = '58568568';
            pd1.Variant_Code__c = 'xyz';
            insert pd1;
        }
    }
    
    @isTest
    public static void verifyIND_RCLimitCheckRequest(){
        try
        {            
            Applicant__c applicant = [SELECT Id, Opportunity__c, Opportunity__r.Application_number__c, Scorecard_Decision__c FROM Applicant__c WHERE Scorecard_Decision__c = 'Red' LIMIT 1]; 
            Deal_Number__c dealNum = [SELECT Id,Loan_Application__c from Deal_Number__c where Loan_Application__c =:applicant.Opportunity__c ];
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank11.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                IND_RCLimitCheckRequest result = new IND_RCLimitCheckRequest(applicant, applicant.Opportunity__c,dealNum.Id);
                Boolean isValid = result.validate(System.Label.RCLimitCheck);
                System.assert(isValid);
                
                Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
                System.assert(!resultHeadersMap.isEmpty());
                
                result = new IND_RCLimitCheckRequest(applicant,applicant.Opportunity__c,dealNum.Id);
                System.assert(result != null);
            }
            Test.stopTest();
        }
        catch(Exception ex){
            System.debug('error '+ex.getMessage());
        }        
    }
    
    @isTest
    public static void verifyIND_RCLimitCheckRequest1(){
        try{
            Applicant__c applicant = [SELECT Id, Opportunity__c, Opportunity__r.Application_number__c, Scorecard_Decision__c FROM Applicant__c WHERE Scorecard_Decision__c = 'Red' LIMIT 1]; 
            Deal_Number__c dealNum = [SELECT Id,Loan_Application__c from Deal_Number__c where Loan_Application__c =:applicant.Opportunity__c ];
            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank11.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                IND_RCLimitCheckRequest result = new IND_RCLimitCheckRequest(applicant, applicant.Opportunity__c,dealNum.Id);
                Boolean isValid = result.validate(System.Label.RCLimitCheck);
                System.assert(isValid);
                
                Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
                System.assert(!resultHeadersMap.isEmpty());
                
                result = new IND_RCLimitCheckRequest(applicant,applicant.Opportunity__c,dealNum.Id);
                System.assert(result != null);
            }
            Test.stopTest();
        }
        catch(Exception ex){
          	System.debug('error '+ex.getMessage());
        }
        
    }
    
    @isTest
    public static void verifyIND_RCLimitCheckRequestBenCodeNull(){
        try{
            Applicant__c applicant = [SELECT Id, Opportunity__c, Opportunity__r.Application_number__c, Scorecard_Decision__c FROM Applicant__c WHERE Scorecard_Decision__c = 'Red' LIMIT 1]; 
            Deal_Number__c dealNum = [SELECT Id,Loan_Application__c from Deal_Number__c LIMIT 1];
            dealNum.Loan_Application__c = applicant.Opportunity__c;
            update dealNum;
            
            Vehicle_Detail__c  vehicleDetail =  [SELECT Id,Loan_Application__c FROM Vehicle_Detail__c WHERE Loan_Application__c=:applicant.Opportunity__c];
            vehicleDetail.Deal_Number__c = dealNum.Id;
            update vehicleDetail;
            
            Final_Term__c  finalDetails = [SELECT Id,Loan_Application__c FROM Final_Term__c WHERE Loan_Application__c=:applicant.Opportunity__c];
            finalDetails.Vehicle_Detail__c = vehicleDetail.Id;
			update finalDetails;
            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank11.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                IND_RCLimitCheckRequest result = new IND_RCLimitCheckRequest(applicant, applicant.Opportunity__c,'Dealer',dealNum.Id);
                Boolean isValid = result.validate(System.Label.RCLimitCheck);
                System.assert(isValid);
                
                Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
                System.assert(!resultHeadersMap.isEmpty());
                
                result = new IND_RCLimitCheckRequest(applicant,applicant.Opportunity__c,'test','test');
                System.assert(result != null);
            }
            Test.stopTest();
        }
        catch(Exception ex){
            System.debug('error '+ex.getMessage());
        }
    }
    
    @isTest
    public static void verifyIND_RCLimitCheckRequestProdNull(){
        try{
             Applicant__c applicant = [SELECT Id, Opportunity__c, Opportunity__r.Application_number__c, Scorecard_Decision__c FROM Applicant__c WHERE Scorecard_Decision__c = 'Orange' LIMIT 1]; 
            Deal_Number__c dealNum = [SELECT Id,Loan_Application__c from Deal_Number__c where Loan_Application__c =:applicant.Opportunity__c ];
            
            Vehicle_Detail__c  vehicleDetail =  new Vehicle_Detail__c();
            vehicleDetail.Loan_Application__c = applicant.Opportunity__c;
            vehicleDetail.Product__c = 'Two Wheeler';
            vehicleDetail.Variant__c = 'JAWA Variant';
            vehicleDetail.Deal_Number__c = dealNum.Id;
            insert vehicleDetail;
            
            Final_Term__c  finalDetails =  new Final_Term__c();
            finalDetails.Loan_Application__c = applicant.Opportunity__c;
            finalDetails.Referrer_Ben_Code__c ='Ben10101';
            finalDetails.Loan_Amount__c = '100000';
            finalDetails.Vehicle_Detail__c = vehicleDetail.Id;
            insert finalDetails;
            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank11.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                IND_RCLimitCheckRequest result = new IND_RCLimitCheckRequest(applicant,applicant.Opportunity__c,'DSA',dealNum.Id);
                Boolean isValid = result.validate(System.Label.RCLimitCheck);
                System.assert(isValid);
                
                Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
                System.assert(!resultHeadersMap.isEmpty());
                
                result = new IND_RCLimitCheckRequest(applicant,applicant.Opportunity__c,'test','test');
                System.assert(result != null);
            }
            Test.stopTest();
        }
        catch(Exception ex){
            System.debug('error '+ex.getMessage());
        }
        
    }
    @isTest
    public static void verifyIND_RCLimitCheckRequestForCallType(){
        try
        {            
            Applicant__c applicant = [SELECT Id, Opportunity__c, Opportunity__r.Application_number__c, Scorecard_Decision__c FROM Applicant__c WHERE Scorecard_Decision__c = 'Red' LIMIT 1]; 
            Deal_Number__c dealNum = [SELECT Id,Loan_Application__c from Deal_Number__c LIMIT 1];
            dealNum.Loan_Application__c = applicant.Opportunity__c;
            update dealNum;
            
            Vehicle_Detail__c  vehicleDetail =  [SELECT Id,Loan_Application__c FROM Vehicle_Detail__c WHERE Loan_Application__c=:applicant.Opportunity__c];
            vehicleDetail.Deal_Number__c = dealNum.Id;
            update vehicleDetail;
            
            Final_Term__c  finalDetails = [SELECT Id,Loan_Application__c FROM Final_Term__c WHERE Loan_Application__c=:applicant.Opportunity__c];
            finalDetails.Vehicle_Detail__c = vehicleDetail.Id;
			update finalDetails;
            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank11.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                IND_RCLimitCheckRequest result = new IND_RCLimitCheckRequest(applicant, applicant.Opportunity__c,dealNum.Id);
                Boolean isValid = result.validate(System.Label.RCLimitCheck);
                System.assert(isValid);
                
                Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
                System.assert(!resultHeadersMap.isEmpty());
                
                result = new IND_RCLimitCheckRequest(applicant,applicant.Opportunity__c,'test');
                System.assert(result != null);
            }
            Test.stopTest();
        }
        catch(Exception ex){
            System.debug('error '+ex.getMessage());
        }        
    }
    
     @isTest
    public static void verifyIND_RCLimitCheckRequestForCallType1(){
        try
        {       
            Applicant__c applicant = [SELECT Id, Opportunity__c, Opportunity__r.Application_number__c, Scorecard_Decision__c FROM Applicant__c WHERE Scorecard_Decision__c = 'Orange' LIMIT 1]; 
            Deal_Number__c dealNum = [SELECT Id,Loan_Application__c from Deal_Number__c where Loan_Application__c =:applicant.Opportunity__c ];
            
            Vehicle_Detail__c  vehicleDetail =  new Vehicle_Detail__c();
            vehicleDetail.Loan_Application__c = applicant.Opportunity__c;
            vehicleDetail.Product__c = 'Two Wheeler';
            vehicleDetail.Variant__c = 'JAWA Variant';
            vehicleDetail.Deal_Number__c = dealNum.Id;
            insert vehicleDetail;
            
            Final_Term__c  finalDetails =  new Final_Term__c();
            finalDetails.Loan_Application__c = applicant.Opportunity__c;
            finalDetails.Referrer_Ben_Code__c ='Ben10101';
            finalDetails.Loan_Amount__c = '100000';
            finalDetails.Vehicle_Detail__c = vehicleDetail.Id;
            insert finalDetails;
            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank11.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                IND_RCLimitCheckRequest result = new IND_RCLimitCheckRequest(applicant,applicant.Opportunity__c,dealNum.Id);
                Boolean isValid = result.validate(System.Label.RCLimitCheck);
                System.assert(isValid);
                
                Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
                System.assert(!resultHeadersMap.isEmpty());
                
                result = new IND_RCLimitCheckRequest(applicant,applicant.Opportunity__c,'test');
                System.assert(result != null);
            }
            Test.stopTest();
        }
        catch(Exception ex){
            System.debug('error '+ex.getMessage());
        }        
    }
    
    
}