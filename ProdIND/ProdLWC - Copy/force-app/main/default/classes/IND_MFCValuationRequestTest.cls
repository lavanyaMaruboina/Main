@isTest
public class IND_MFCValuationRequestTest {
    
    @isTest
    public static void verifyIND_MFCValuationRequest(){
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
            system.debug('p'+ p);
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='1002',User_Id__c = '29927_MO',
                              TimeZoneSidKey='America/Los_Angeles', MobilePhone = '9701498575',
                              UserName='standarduser4@testorg.com.psdev1');
         insert u;
         System.runAs(u){
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        opgd1.Vehicle_Sub_Category__c = 'UIM';
        opgd1.Parent_Deal_number__c = 'DL109939';
        opgd1.Lead_number__c = 'L109939';
        opgd1.Deal_Number__c = 'L109939';
        opgd1.Application_number__c = 'L109939';
        opgd1.Agent_BL_code__c = 'AG-00';
        opgd1.Employee_Name__c = 'Test';
        opgd1.Employee_No__c = 'L109939';
        opgd1.OwnerId= u.Id;
        insert opgd1;
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opgd1.Id;
        applicant.Applicant_Type__c  = null;
        applicant.Scorecard_Decision__c = 'Red';
        insert applicant;
        applicant.Opportunity__r = opgd1;  
        
        
        Vehicle_Detail__c vg3 = new Vehicle_Detail__c();
        vg3.Loan_Application__c = opgd1.Id;
        vg3.Base_Price__c = 100000.00;
        vg3.Ben_Code__c = 'testveh';
        vg3.Valuer_code__c = 'BEN000871';
        vg3.Variant__c  = 'M&M KUV100 NXT K8 DIESEL';
        vg3.Make__c = 'TVS';
        vg3.Model__c = 'MAHINDRA MARAZZO';
        vg3.Engine_number__c  = 'TBH1H79814';
        vg3.Chassis_number__c  = 'MA1ZN2TBKH65317';
        vg3.Vehicle_Registration_number__c  = 'MH14GV9526';
        vg3.Product__c='Two Wheeler';
        insert vg3; 
        
        Vehicle_Detail__c vg4 = new Vehicle_Detail__c();
        vg4.Loan_Application__c = opgd1.Id;
        vg4.Base_Price__c = 100000.00;
        vg4.Ben_Code__c = 'testveh';
        vg4.Valuer_code__c = 'BEN000871';
        vg4.Variant__c  = 'M&M KUV300 NXT K8 DIESEL';
        vg4.Make__c = 'TVS';
        vg4.Model__c = 'MAHINDRA MARAZZO';
        vg4.Engine_number__c  = 'TBH1H79814';
        vg4.Chassis_number__c  = 'MA1ZN2TBKH65317';
        vg4.Vehicle_Registration_number__c  = 'MH14GV9526';
        vg4.Product__c='Two Wheeler';
        insert vg4; 
        
        Product2 pd1 = new Product2();
        pd1.Asset_Category__c = 'A';
        pd1.Name = 'M&M KUV100 NXT K8 DIESEL';
        pd1.Type__c = 'variant';
        pd1.External_Reference_Id__c = '58568568';
        pd1.Variant_Code__c = 'xyz';
        insert pd1;
        
        Product2 pd2 = new Product2();
        pd2.Asset_Category__c = 'te';
        pd2.Name = 'Two Wheeler';
        pd2.Type__c = 'Class Of Vehicle';
        pd2.External_Reference_Id__c = 'Model-P1069';
        insert pd2;
        
       
        
        
        RequestWrapper requestWrapper = new RequestWrapper();
        requestWrapper.loanApplicationId = opgd1.Id;
        requestWrapper.valuerCategory = 'valuerCategory';
        requestWrapper.placeOfInspection = 'placeOfInspection';
        requestWrapper.locationOfVehicle = 'locationOfVehicle';
        requestWrapper.city = 'Chennai';
        requestWrapper.state = 'TL';
        requestWrapper.Variant = pd1.Variant_Code__c;
        requestWrapper.vehicleId=vg3.Id;
        


        
        
        IND_MFCValuationRequest result = new IND_MFCValuationRequest(requestWrapper);
        Boolean isValid = result.validate(System.Label.MFCValuationAPI);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty());
         }
    }
    @isTest
    public static void verifyIND_MFCValuationRequest2(){
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
            system.debug('p'+ p);
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='1002',User_Id__c = '29927_MO',
                              TimeZoneSidKey='America/Los_Angeles', MobilePhone = '9701498575',
                              UserName='standarduser4@testorg.com.psdev1');
         insert u;
        System.runAs(u){
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        opgd1.Vehicle_Sub_Category__c = 'UIM';
        opgd1.Parent_Deal_number__c = 'DL109939';
        opgd1.Lead_number__c = 'L109939';
        opgd1.Deal_Number__c = 'L109939';
        opgd1.Application_number__c = 'L109939';
        opgd1.Agent_BL_code__c = '';
        opgd1.Employee_Name__c = 'Test';
        opgd1.Employee_No__c = 'L109939';
        opgd1.OwnerId= u.Id;
        insert opgd1;
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opgd1.Id;
        applicant.Applicant_Type__c  = null;
        applicant.Scorecard_Decision__c = 'Red';
        insert applicant;
        applicant.Opportunity__r = opgd1;  
        
        
        Vehicle_Detail__c vg3 = new Vehicle_Detail__c();
        vg3.Loan_Application__c = opgd1.Id;
        vg3.Base_Price__c = 100000.00;
        vg3.Ben_Code__c = 'testveh';
        vg3.Valuer_code__c = 'BEN000871';
        vg3.Variant__c  = 'M&M KUV100 NXT K8 DIESEL';
        vg3.Make__c = 'TVS';
        vg3.Model__c = 'MAHINDRA MARAZZO';
        vg3.Engine_number__c  = 'TBH1H79814';
        vg3.Chassis_number__c  = 'MA1ZN2TBKH65317';
        vg3.Vehicle_Registration_number__c  = 'MH14GV9526';
        vg3.Product__c='Two Wheeler';
        insert vg3; 
        
        Vehicle_Detail__c vg4 = new Vehicle_Detail__c();
        vg4.Loan_Application__c = opgd1.Id;
        vg4.Base_Price__c = 100000.00;
        vg4.Ben_Code__c = 'testveh';
        vg4.Valuer_code__c = 'BEN000871';
        vg4.Variant__c  = 'M&M KUV300 NXT K8 DIESEL';
        vg4.Make__c = 'TVS';
        vg4.Model__c = 'MAHINDRA MARAZZO';
        vg4.Engine_number__c  = 'TBH1H79814';
        vg4.Chassis_number__c  = 'MA1ZN2TBKH65317';
        vg4.Vehicle_Registration_number__c  = 'MH14GV9526';
        vg4.Product__c='Two Wheeler';
        insert vg4; 
        
        Product2 pd1 = new Product2();
        pd1.Asset_Category__c = 'A';
        pd1.Name = 'M&M KUV100 NXT K8 DIESEL';
        pd1.Type__c = 'variant';
        pd1.External_Reference_Id__c = '58568568';
        pd1.Variant_Code__c = 'xyz';
        insert pd1;
        
        Product2 pd2 = new Product2();
        pd2.Asset_Category__c = 'te';
        pd2.Name = 'Two Wheeler';
        pd2.Type__c = 'Class Of Vehicle';
        pd2.External_Reference_Id__c = 'Model-P1069';
        insert pd2;
        
       
        RequestWrapper requestWrapper = new RequestWrapper();
        requestWrapper.loanApplicationId = opgd1.Id;
        requestWrapper.valuerCategory = 'valuerCategory';
        requestWrapper.placeOfInspection = 'placeOfInspection';
        requestWrapper.locationOfVehicle = 'locationOfVehicle';
        requestWrapper.city = 'Chennai';
        requestWrapper.state = 'TL';
        requestWrapper.Variant = pd1.Variant_Code__c;
        requestWrapper.vehicleId=vg3.Id;
        
        try {
            IND_MFCValuationRequest result = new IND_MFCValuationRequest(requestWrapper);
             Boolean isValid = result.validate(System.Label.MFCValuationAPI);
             Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        	System.assert(!resultHeadersMap.isEmpty());
        }catch(Exception ex){
            System.assertEquals('Please enter the branch location.', ex.getMessage());
        }
    } 
    }
    @isTest
    public static void verifyIND_MFCValuationRequest3(){
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
            system.debug('p'+ p);
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='1002',User_Id__c = '29927_MO',
                              TimeZoneSidKey='America/Los_Angeles', MobilePhone = '9701498575',
                              UserName='standarduser4@testorg.com.psdev1');
         insert u;
        System.runAs(u){
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        opgd1.Vehicle_Sub_Category__c = 'UIM';
        opgd1.Parent_Deal_number__c = 'DL109939';
        opgd1.Lead_number__c = 'L109939';
        opgd1.Deal_Number__c = 'L109939';
        opgd1.Application_number__c = 'L109939';
        opgd1.Agent_BL_code__c = 'AG-00';
        opgd1.Employee_Name__c = 'Test';
        opgd1.Employee_No__c = 'L109939';
        opgd1.OwnerId= u.Id;
        insert opgd1;
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opgd1.Id;
        applicant.Applicant_Type__c  = null;
        applicant.Scorecard_Decision__c = 'Red';
        insert applicant;
        applicant.Opportunity__r = opgd1;  
        
        
        Vehicle_Detail__c vg3 = new Vehicle_Detail__c();
        vg3.Loan_Application__c = opgd1.Id;
        vg3.Base_Price__c = 100000.00;
        vg3.Ben_Code__c = 'testveh';
        vg3.Valuer_code__c = 'BEN000871';
        vg3.Variant__c  = 'M&M KUV100 NXT K8 DIESEL';
        vg3.Make__c = 'TVS';
        vg3.Model__c = 'MAHINDRA MARAZZO';
        vg3.Engine_number__c  = 'TBH1H79814';
        vg3.Chassis_number__c  = 'MA1ZN2TBKH65317';
        vg3.Vehicle_Registration_number__c  = '';
        vg3.Product__c='Two Wheeler';
        insert vg3; 
        
        Vehicle_Detail__c vg4 = new Vehicle_Detail__c();
        vg4.Loan_Application__c = opgd1.Id;
        vg4.Base_Price__c = 100000.00;
        vg4.Ben_Code__c = 'testveh';
        vg4.Valuer_code__c = 'BEN000871';
        vg4.Variant__c  = 'M&M KUV300 NXT K8 DIESEL';
        vg4.Make__c = 'TVS';
        vg4.Model__c = 'MAHINDRA MARAZZO';
        vg4.Engine_number__c  = 'TBH1H79814';
        vg4.Chassis_number__c  = 'MA1ZN2TBKH65317';
        vg4.Vehicle_Registration_number__c  = '';
        vg4.Product__c='Two Wheeler';
        insert vg4; 
        
        Product2 pd1 = new Product2();
        pd1.Asset_Category__c = 'A';
        pd1.Name = 'M&M KUV100 NXT K8 DIESEL';
        pd1.Type__c = 'variant';
        pd1.External_Reference_Id__c = '58568568';
        pd1.Variant_Code__c = 'xyz';
        insert pd1;
        
        Product2 pd2 = new Product2();
        pd2.Asset_Category__c = 'te';
        pd2.Name = 'Two Wheeler';
        pd2.Type__c = 'Class Of Vehicle';
        pd2.External_Reference_Id__c = 'Model-P1069';
        insert pd2;
        
       
        RequestWrapper requestWrapper = new RequestWrapper();
        requestWrapper.loanApplicationId = opgd1.Id;
        requestWrapper.valuerCategory = 'valuerCategory';
        requestWrapper.placeOfInspection = 'placeOfInspection';
        requestWrapper.locationOfVehicle = 'locationOfVehicle';
        requestWrapper.city = 'Chennai';
        requestWrapper.state = 'TL';
        requestWrapper.Variant = pd1.Variant_Code__c;
         requestWrapper.vehicleId=vg3.Id;
        
        try {
            IND_MFCValuationRequest result = new IND_MFCValuationRequest(requestWrapper);
             Boolean isValid = result.validate(System.Label.MFCValuationAPI);
             Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        	System.assert(!resultHeadersMap.isEmpty());
        }catch(Exception ex){
            System.assertEquals('Please enter vehicle registration number.', ex.getMessage());
        }
        }
    }
    
    @isTest
    public static void verifyIND_MFCValuationRequest4(){
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
            system.debug('p'+ p);
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='1002',User_Id__c = '29927_MO',
                              TimeZoneSidKey='America/Los_Angeles', MobilePhone = '9701498575',
                              UserName='standarduser4@testorg.com.psdev1');
         insert u;
        System.runAs(u){
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        opgd1.Vehicle_Sub_Category__c = 'UIM';
        opgd1.Parent_Deal_number__c = 'DL109939';
        opgd1.Lead_number__c = 'L109939';
        opgd1.Deal_Number__c = 'L109939';
        opgd1.Application_number__c = 'L109939';
        opgd1.Agent_BL_code__c = 'AG-00';
        opgd1.Employee_Name__c = 'Test';
        opgd1.Employee_No__c = 'L109939';
        opgd1.OwnerId= u.Id;
        insert opgd1;
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opgd1.Id;
        applicant.Applicant_Type__c  = null;
        applicant.Scorecard_Decision__c = 'Red';
        insert applicant;
        applicant.Opportunity__r = opgd1;  
        
        
        Vehicle_Detail__c vg3 = new Vehicle_Detail__c();
        vg3.Loan_Application__c = opgd1.Id;
        vg3.Base_Price__c = 100000.00;
        vg3.Ben_Code__c = 'testveh';
        vg3.Valuer_code__c = 'BEN000871';
        vg3.Variant__c  = 'M&M KUV100 NXT K8 DIESEL';
        vg3.Make__c = 'TVS';
        vg3.Model__c = 'MAHINDRA MARAZZO';
        vg3.Engine_number__c  = 'TBH1H79814';
        vg3.Chassis_number__c  = 'MA1ZN2TBKH65317';
        vg3.Vehicle_Registration_number__c  = 'MH14GV9526';
        vg3.Product__c='Two Wheeler';
        insert vg3; 
        
        Vehicle_Detail__c vg4 = new Vehicle_Detail__c();
        vg4.Loan_Application__c = opgd1.Id;
        vg4.Base_Price__c = 100000.00;
        vg4.Ben_Code__c = 'testveh';
        vg4.Valuer_code__c = 'BEN000871';
        vg4.Variant__c  = 'M&M KUV300 NXT K8 DIESEL';
        vg4.Make__c = 'TVS';
        vg4.Model__c = 'MAHINDRA MARAZZO';
        vg4.Engine_number__c  = 'TBH1H79814';
        vg4.Chassis_number__c  = 'MA1ZN2TBKH65317';
        vg4.Vehicle_Registration_number__c  = 'MH14GV9526';
        vg4.Product__c='Two Wheeler';
        insert vg4; 
        
        Product2 pd1 = new Product2();
        pd1.Asset_Category__c = '';
        pd1.Name = 'M&M KUV100 NXT K8 DIESEL';
        pd1.Type__c = 'variant';
        pd1.External_Reference_Id__c = '58568568';
        pd1.Variant_Code__c = 'xyz';
        insert pd1;
        
        Product2 pd2 = new Product2();
        pd2.Asset_Category__c = '';
        pd2.Name = 'Two Wheeler';
        pd2.Type__c = 'Class Of Vehicle';
        pd2.External_Reference_Id__c = 'Model-P1069';
        insert pd2;
        
       
        
        
        RequestWrapper requestWrapper = new RequestWrapper();
        requestWrapper.loanApplicationId = opgd1.Id;
        requestWrapper.valuerCategory = 'valuerCategory';
        requestWrapper.placeOfInspection = 'placeOfInspection';
        requestWrapper.locationOfVehicle = 'locationOfVehicle';
        requestWrapper.city = 'Chennai';
        requestWrapper.state = 'TL';
        requestWrapper.Variant = pd1.Variant_Code__c;
         requestWrapper.vehicleId=vg3.Id;

        IND_MFCValuationRequest result = new IND_MFCValuationRequest(requestWrapper);
        Boolean isValid = result.validate(System.Label.MFCValuationAPI);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty());
    }
    }   
     @isTest
    public static void verifyIND_MFCValuationRequestForState(){
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
            system.debug('p'+ p);
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='1002',User_Id__c = '29927_MO',
                              TimeZoneSidKey='America/Los_Angeles', MobilePhone = '9701498575',
                              UserName='standarduser4@testorg.com.psdev1');
         insert u;
        System.runAs(u){
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        opgd1.Vehicle_Sub_Category__c = 'UIM';
        opgd1.Parent_Deal_number__c = 'DL109939';
        opgd1.Lead_number__c = 'L109939';
        opgd1.Deal_Number__c = 'L109939';
        opgd1.Application_number__c = 'L109939';
        opgd1.Agent_BL_code__c = 'AG-00';
        opgd1.Employee_Name__c = 'Test';
        opgd1.Employee_No__c = 'L109939';
        opgd1.OwnerId= u.Id;
        insert opgd1;
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opgd1.Id;
        applicant.Applicant_Type__c  = null;
        applicant.Scorecard_Decision__c = 'Red';
        insert applicant;
        applicant.Opportunity__r = opgd1;  
        
        
        Vehicle_Detail__c vg3 = new Vehicle_Detail__c();
        vg3.Loan_Application__c = opgd1.Id;
        vg3.Base_Price__c = 100000.00;
        vg3.Ben_Code__c = 'testveh';
        vg3.Valuer_code__c = 'BEN000871';
        vg3.Variant__c  = 'M&M KUV100 NXT K8 DIESEL';
        vg3.Make__c = 'TVS';
        vg3.Model__c = 'MAHINDRA MARAZZO';
        vg3.Engine_number__c  = 'TBH1H79814';
        vg3.Chassis_number__c  = 'MA1ZN2TBKH65317';
        vg3.Vehicle_Registration_number__c  = 'MH14GV9526';
        vg3.Product__c='Two Wheeler';
        insert vg3; 
        
        Vehicle_Detail__c vg4 = new Vehicle_Detail__c();
        vg4.Loan_Application__c = opgd1.Id;
        vg4.Base_Price__c = 100000.00;
        vg4.Ben_Code__c = 'testveh';
        vg4.Valuer_code__c = 'BEN000871';
        vg4.Variant__c  = 'M&M KUV300 NXT K8 DIESEL';
        vg4.Make__c = 'TVS';
        vg4.Model__c = 'MAHINDRA MARAZZO';
        vg4.Engine_number__c  = 'TBH1H79814';
        vg4.Chassis_number__c  = 'MA1ZN2TBKH65317';
        vg4.Vehicle_Registration_number__c  = 'MH14GV9526';
        vg4.Product__c='Two Wheeler';
        insert vg4; 
        
        Product2 pd1 = new Product2();
        pd1.Asset_Category__c = 'A';
        pd1.Name = 'M&M KUV100 NXT K8 DIESEL';
        pd1.Type__c = 'variant';
        pd1.External_Reference_Id__c = '58568568';
        pd1.Variant_Code__c = 'xyz';
        insert pd1;
        
        Product2 pd2 = new Product2();
        pd2.Asset_Category__c = 'te';
        pd2.Name = 'Two Wheeler';
        pd2.Type__c = 'Class Of Vehicle';
        pd2.External_Reference_Id__c = 'Model-P1069';
        insert pd2;
        
       
        
        
        RequestWrapper requestWrapper = new RequestWrapper();
        requestWrapper.loanApplicationId = opgd1.Id;
        requestWrapper.valuerCategory = 'valuerCategory';
        requestWrapper.placeOfInspection = 'placeOfInspection';
        requestWrapper.locationOfVehicle = 'locationOfVehicle';
        requestWrapper.city = 'Chennai';
        requestWrapper.state = '';
        requestWrapper.Variant = pd1.Variant_Code__c;
		 requestWrapper.vehicleId=vg3.Id;
        try {
            IND_MFCValuationRequest result = new IND_MFCValuationRequest(requestWrapper);
             Boolean isValid = result.validate(System.Label.MFCValuationAPI);
             Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        	System.assert(!resultHeadersMap.isEmpty());
        }catch(Exception ex){
            System.assertEquals('Please enter State.', ex.getMessage());
        }
    }
    }
    
     @isTest
    public static void verifyIND_MFCValuationRequestForCity(){
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
            system.debug('p'+ p);
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='1002',User_Id__c = '29927_MO',
                              TimeZoneSidKey='America/Los_Angeles', MobilePhone = '9701498575',
                              UserName='standarduser4@testorg.com.psdev1');
         insert u;
        System.runAs(u){
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        opgd1.Vehicle_Sub_Category__c = 'UIM';
        opgd1.Parent_Deal_number__c = 'DL109939';
        opgd1.Lead_number__c = 'L109939';
        opgd1.Deal_Number__c = 'L109939';
        opgd1.Application_number__c = 'L109939';
        opgd1.Agent_BL_code__c = 'AG-00';
        opgd1.Employee_Name__c = 'Test';
        opgd1.Employee_No__c = 'L109939';
        opgd1.OwnerId= u.Id;
        insert opgd1;
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opgd1.Id;
        applicant.Applicant_Type__c  = null;
        applicant.Scorecard_Decision__c = 'Red';
        insert applicant;
        applicant.Opportunity__r = opgd1;  
        
        
        Vehicle_Detail__c vg3 = new Vehicle_Detail__c();
        vg3.Loan_Application__c = opgd1.Id;
        vg3.Base_Price__c = 100000.00;
        vg3.Ben_Code__c = 'testveh';
        vg3.Valuer_code__c = 'BEN000871';
        vg3.Variant__c  = 'M&M KUV100 NXT K8 DIESEL';
        vg3.Make__c = 'TVS';
        vg3.Model__c = 'MAHINDRA MARAZZO';
        vg3.Engine_number__c  = 'TBH1H79814';
        vg3.Chassis_number__c  = 'MA1ZN2TBKH65317';
        vg3.Vehicle_Registration_number__c  = 'MH14GV9526';
        vg3.Product__c='Two Wheeler';
        insert vg3; 
        
        Vehicle_Detail__c vg4 = new Vehicle_Detail__c();
        vg4.Loan_Application__c = opgd1.Id;
        vg4.Base_Price__c = 100000.00;
        vg4.Ben_Code__c = 'testveh';
        vg4.Valuer_code__c = 'BEN000871';
        vg4.Variant__c  = 'M&M KUV300 NXT K8 DIESEL';
        vg4.Make__c = 'TVS';
        vg4.Model__c = 'MAHINDRA MARAZZO';
        vg4.Engine_number__c  = 'TBH1H79814';
        vg4.Chassis_number__c  = 'MA1ZN2TBKH65317';
        vg4.Vehicle_Registration_number__c  = 'MH14GV9526';
        vg4.Product__c='Two Wheeler';
        insert vg4; 
        
        Product2 pd1 = new Product2();
        pd1.Asset_Category__c = 'A';
        pd1.Name = 'M&M KUV100 NXT K8 DIESEL';
        pd1.Type__c = 'variant';
        pd1.External_Reference_Id__c = '58568568';
        pd1.Variant_Code__c = 'xyz';
        insert pd1;
        
        Product2 pd2 = new Product2();
        pd2.Asset_Category__c = 'te';
        pd2.Name = 'Two Wheeler';
        pd2.Type__c = 'Class Of Vehicle';
        pd2.External_Reference_Id__c = 'Model-P1069';
        insert pd2;
        
       
        
        
        RequestWrapper requestWrapper = new RequestWrapper();
        requestWrapper.loanApplicationId = opgd1.Id;
        requestWrapper.valuerCategory = 'valuerCategory';
        requestWrapper.placeOfInspection = 'placeOfInspection';
        requestWrapper.locationOfVehicle = 'locationOfVehicle';
        requestWrapper.city = '';
        requestWrapper.state = 'TL';
        requestWrapper.Variant = pd1.Variant_Code__c;
         requestWrapper.vehicleId=vg3.Id;

        
        try {
            IND_MFCValuationRequest result = new IND_MFCValuationRequest(requestWrapper);
             Boolean isValid = result.validate(System.Label.MFCValuationAPI);
             Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        	System.assert(!resultHeadersMap.isEmpty());
        }catch(Exception ex){
            System.assertEquals('City', ex.getMessage());
        }
    }
    }
     @isTest
    public static void verifyIND_MFCValuationRequestforValuarCat(){
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
            system.debug('p'+ p);
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='1002',User_Id__c = '29927_MO',
                              TimeZoneSidKey='America/Los_Angeles', MobilePhone = '9701498575',
                              UserName='standarduser4@testorg.com.psdev1');
         insert u;
        System.runAs(u){
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        opgd1.Vehicle_Sub_Category__c = 'UIM';
        opgd1.Parent_Deal_number__c = 'DL109939';
        opgd1.Lead_number__c = 'L109939';
        opgd1.Deal_Number__c = 'L109939';
        opgd1.Application_number__c = 'L109939';
        opgd1.Agent_BL_code__c = 'AG-00';
        opgd1.Employee_Name__c = 'Test';
        opgd1.Employee_No__c = 'L109939';
        opgd1.OwnerId= u.Id;
        insert opgd1;
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opgd1.Id;
        applicant.Applicant_Type__c  = null;
        applicant.Scorecard_Decision__c = 'Red';
        insert applicant;
        applicant.Opportunity__r = opgd1;  
        
        
        Vehicle_Detail__c vg3 = new Vehicle_Detail__c();
        vg3.Loan_Application__c = opgd1.Id;
        vg3.Base_Price__c = 100000.00;
        vg3.Ben_Code__c = 'testveh';
        vg3.Valuer_code__c = 'BEN000871';
        vg3.Variant__c  = 'M&M KUV100 NXT K8 DIESEL';
        vg3.Make__c = 'TVS';
        vg3.Model__c = 'MAHINDRA MARAZZO';
        vg3.Engine_number__c  = 'TBH1H79814';
        vg3.Chassis_number__c  = 'MA1ZN2TBKH65317';
        vg3.Vehicle_Registration_number__c  = 'MH14GV9526';
        vg3.Product__c='Two Wheeler';
        insert vg3; 
        
        Vehicle_Detail__c vg4 = new Vehicle_Detail__c();
        vg4.Loan_Application__c = opgd1.Id;
        vg4.Base_Price__c = 100000.00;
        vg4.Ben_Code__c = 'testveh';
        vg4.Valuer_code__c = 'BEN000871';
        vg4.Variant__c  = 'M&M KUV300 NXT K8 DIESEL';
        vg4.Make__c = 'TVS';
        vg4.Model__c = 'MAHINDRA MARAZZO';
        vg4.Engine_number__c  = 'TBH1H79814';
        vg4.Chassis_number__c  = 'MA1ZN2TBKH65317';
        vg4.Vehicle_Registration_number__c  = 'MH14GV9526';
        vg4.Product__c='Two Wheeler';
        insert vg4; 
        
        Product2 pd1 = new Product2();
        pd1.Asset_Category__c = 'A';
        pd1.Name = 'M&M KUV100 NXT K8 DIESEL';
        pd1.Type__c = 'variant';
        pd1.External_Reference_Id__c = '58568568';
        pd1.Variant_Code__c = 'xyz';
        insert pd1;
        
        Product2 pd2 = new Product2();
        pd2.Asset_Category__c = 'te';
        pd2.Name = 'Two Wheeler';
        pd2.Type__c = 'Class Of Vehicle';
        pd2.External_Reference_Id__c = 'Model-P1069';
        insert pd2;
        
       
        
        
        RequestWrapper requestWrapper = new RequestWrapper();
        requestWrapper.loanApplicationId = opgd1.Id;
        requestWrapper.valuerCategory = '';
        requestWrapper.placeOfInspection = 'placeOfInspection';
        requestWrapper.locationOfVehicle = 'locationOfVehicle';
        requestWrapper.city = 'Chennai';
        requestWrapper.state = 'TL';
        requestWrapper.Variant = pd1.Variant_Code__c;
         requestWrapper.vehicleId=vg3.Id;

        
        IND_MFCValuationRequest result = new IND_MFCValuationRequest(requestWrapper);
        Boolean isValid = result.validate(System.Label.MFCValuationAPI);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty());
    }
    }
    
     @isTest
    public static void verifyIND_MFCValuationRequestForInspection(){
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
            system.debug('p'+ p);
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='1002',User_Id__c = '29927_MO',
                              TimeZoneSidKey='America/Los_Angeles', MobilePhone = '9701498575',
                              UserName='standarduser4@testorg.com.psdev1');
         insert u;
        System.runAs(u){
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        opgd1.Vehicle_Sub_Category__c = 'UIM';
        opgd1.Parent_Deal_number__c = 'DL109939';
        opgd1.Lead_number__c = 'L109939';
        opgd1.Deal_Number__c = 'L109939';
        opgd1.Application_number__c = 'L109939';
        opgd1.Agent_BL_code__c = 'AG-00';
        opgd1.Employee_Name__c = 'Test';
        opgd1.Employee_No__c = 'L109939';
        opgd1.OwnerId= u.Id;
        insert opgd1;
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opgd1.Id;
        applicant.Applicant_Type__c  = null;
        applicant.Scorecard_Decision__c = 'Red';
        insert applicant;
        applicant.Opportunity__r = opgd1;  
        
        
        Vehicle_Detail__c vg3 = new Vehicle_Detail__c();
        vg3.Loan_Application__c = opgd1.Id;
        vg3.Base_Price__c = 100000.00;
        vg3.Ben_Code__c = 'testveh';
        vg3.Valuer_code__c = 'BEN000871';
        vg3.Variant__c  = 'M&M KUV100 NXT K8 DIESEL';
        vg3.Make__c = 'TVS';
        vg3.Model__c = 'MAHINDRA MARAZZO';
        vg3.Engine_number__c  = 'TBH1H79814';
        vg3.Chassis_number__c  = 'MA1ZN2TBKH65317';
        vg3.Vehicle_Registration_number__c  = 'MH14GV9526';
        vg3.Product__c='Two Wheeler';
        insert vg3; 
        
        Vehicle_Detail__c vg4 = new Vehicle_Detail__c();
        vg4.Loan_Application__c = opgd1.Id;
        vg4.Base_Price__c = 100000.00;
        vg4.Ben_Code__c = 'testveh';
        vg4.Valuer_code__c = 'BEN000871';
        vg4.Variant__c  = 'M&M KUV300 NXT K8 DIESEL';
        vg4.Make__c = 'TVS';
        vg4.Model__c = 'MAHINDRA MARAZZO';
        vg4.Engine_number__c  = 'TBH1H79814';
        vg4.Chassis_number__c  = 'MA1ZN2TBKH65317';
        vg4.Vehicle_Registration_number__c  = 'MH14GV9526';
        vg4.Product__c='Two Wheeler';
        insert vg4; 
        
        Product2 pd1 = new Product2();
        pd1.Asset_Category__c = 'A';
        pd1.Name = 'M&M KUV100 NXT K8 DIESEL';
        pd1.Type__c = 'variant';
        pd1.External_Reference_Id__c = '58568568';
        pd1.Variant_Code__c = 'xyz';
        insert pd1;
        
        Product2 pd2 = new Product2();
        pd2.Asset_Category__c = 'te';
        pd2.Name = 'Two Wheeler';
        pd2.Type__c = 'Class Of Vehicle';
        pd2.External_Reference_Id__c = 'Model-P1069';
        insert pd2;
        
       
        
        
        RequestWrapper requestWrapper = new RequestWrapper();
        requestWrapper.loanApplicationId = opgd1.Id;
        requestWrapper.valuerCategory = 'valuerCategory';
        requestWrapper.placeOfInspection = '';
        requestWrapper.locationOfVehicle = 'locationOfVehicle';
        requestWrapper.city = 'Chennai';
        requestWrapper.state = 'TL';
        requestWrapper.Variant = pd1.Variant_Code__c;
		 requestWrapper.vehicleId=vg3.Id;


        
        
        try {
            IND_MFCValuationRequest result = new IND_MFCValuationRequest(requestWrapper);
             Boolean isValid = result.validate(System.Label.MFCValuationAPI);
             Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        	System.assert(!resultHeadersMap.isEmpty());
        }catch(Exception ex){
            System.assertEquals('Please enter Place Of Inspection.', ex.getMessage());
        }
    }
    }
     @isTest
    public static void verifyIND_MFCValuationRequestForLOV(){
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
            system.debug('p'+ p);
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='1002',User_Id__c = '29927_MO',
                              TimeZoneSidKey='America/Los_Angeles', MobilePhone = '9701498575',
                              UserName='standarduser4@testorg.com.psdev1');
         insert u;
        System.runAs(u){
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        opgd1.Vehicle_Sub_Category__c = 'UIM';
        opgd1.Parent_Deal_number__c = 'DL109939';
        opgd1.Lead_number__c = 'L109939';
        opgd1.Deal_Number__c = 'L109939';
        opgd1.Application_number__c = 'L109939';
        opgd1.Agent_BL_code__c = 'AG-00';
        opgd1.Employee_Name__c = 'Test';
        opgd1.Employee_No__c = 'L109939';
        opgd1.OwnerId= u.Id;
        insert opgd1;
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opgd1.Id;
        applicant.Applicant_Type__c  = null;
        applicant.Scorecard_Decision__c = 'Red';
        insert applicant;
        applicant.Opportunity__r = opgd1;  
        
        
        Vehicle_Detail__c vg3 = new Vehicle_Detail__c();
        vg3.Loan_Application__c = opgd1.Id;
        vg3.Base_Price__c = 100000.00;
        vg3.Ben_Code__c = 'testveh';
        vg3.Valuer_code__c = 'BEN000871';
        vg3.Variant__c  = 'M&M KUV100 NXT K8 DIESEL';
        vg3.Make__c = 'TVS';
        vg3.Model__c = 'MAHINDRA MARAZZO';
        vg3.Engine_number__c  = 'TBH1H79814';
        vg3.Chassis_number__c  = 'MA1ZN2TBKH65317';
        vg3.Vehicle_Registration_number__c  = 'MH14GV9526';
        vg3.Product__c='Two Wheeler';
        insert vg3; 
        
        Vehicle_Detail__c vg4 = new Vehicle_Detail__c();
        vg4.Loan_Application__c = opgd1.Id;
        vg4.Base_Price__c = 100000.00;
        vg4.Ben_Code__c = 'testveh';
        vg4.Valuer_code__c = 'BEN000871';
        vg4.Variant__c  = 'M&M KUV300 NXT K8 DIESEL';
        vg4.Make__c = 'TVS';
        vg4.Model__c = 'MAHINDRA MARAZZO';
        vg4.Engine_number__c  = 'TBH1H79814';
        vg4.Chassis_number__c  = 'MA1ZN2TBKH65317';
        vg4.Vehicle_Registration_number__c  = 'MH14GV9526';
        vg4.Product__c='Two Wheeler';
        insert vg4; 
        
        Product2 pd1 = new Product2();
        pd1.Asset_Category__c = 'A';
        pd1.Name = 'M&M KUV100 NXT K8 DIESEL';
        pd1.Type__c = 'variant';
        pd1.External_Reference_Id__c = '58568568';
        pd1.Variant_Code__c = 'xyz';
        insert pd1;
        
        Product2 pd2 = new Product2();
        pd2.Asset_Category__c = 'te';
        pd2.Name = 'Two Wheeler';
        pd2.Type__c = 'Class Of Vehicle';
        pd2.External_Reference_Id__c = 'Model-P1069';
        insert pd2;
        
       
        
        
        RequestWrapper requestWrapper = new RequestWrapper();
        requestWrapper.loanApplicationId = opgd1.Id;
        requestWrapper.valuerCategory = 'valuerCategory';
        requestWrapper.placeOfInspection = 'placeOfInspection';
        requestWrapper.locationOfVehicle = 'locationOfVehicle';
        requestWrapper.city = 'Chennai';
        requestWrapper.state = 'TL';
        requestWrapper.Variant = pd1.Variant_Code__c;
         requestWrapper.vehicleId=vg3.Id;



        
        
        IND_MFCValuationRequest result = new IND_MFCValuationRequest(requestWrapper);
        Boolean isValid = result.validate(System.Label.MFCValuationAPI);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty());
    }
    }
}