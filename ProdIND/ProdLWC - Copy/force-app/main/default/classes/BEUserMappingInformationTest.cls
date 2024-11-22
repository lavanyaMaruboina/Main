/**
 * @Class: BEUserMappingInformationTest
 * @Description: Test class for BEUserMappingInformation
 * @author: Prashanth Kumar
 * */
@isTest
public class BEUserMappingInformationTest {
    /**
     * Method: testBEAssignment
     * Description: test class for BEAssignment
     * */
	@isTest
    static void testBEAssignment(){
        String orgId = UserInfo.getOrganizationId(); 
        String dateString =   
        String.valueof(Datetime.now()).replace(' ' ,'').replace(':','').replace('-','');  
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));  
        String uniqueName = orgId + dateString + randomInt;
        if(uniqueName.length() > 20 ){
            uniqueName = uniqueName.substring(0, 20);
        }
        System.debug(uniqueName);
        //create BE master record
        D2C_BE_Master__c beMaster = new D2C_BE_Master__c();
        beMaster.Pin_Code__c = 131302;
        beMaster.BL_Code__c = 'HDT';
        beMaster.Employee_Id__c = uniqueName;
        beMaster.Name = 'NANDLAL';
        beMaster.State__c = 'HARYANA';
        beMaster.Product_Type__c = 'Passenger Vehicles';
        beMaster.Vehicle_Type__c = 'New';
        insert beMaster;
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Is_ETB__c = true,
            IO_Loan_Amount__c = '700000',
            Vehicle_Type__c = 'New'
        );
        insert opp;
        
        Account acc = new Account(
        	Name = 'Test Account',
            Type = 'PV',
            Product_Type__c = 'New',
            BranchBLCode__c = 'HDT'
        );
        insert acc;
        
        //create a user record with matching employeeId as username.
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive']; 
        User u = new User(Alias = 'IBLBE', Email='NANDLAL1@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='NANDLAL', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Kolkata', UserName=uniqueName+'@testorg.com.test',EmployeeNumber = uniqueName, MobilePhone ='7217470708', Maker_Id__c = '1001');
        insert u;
        AccountTeamMember atm = new AccountTeamMember(
        	AccountId = acc.Id,
            UserId = u.Id,
            TeamMemberRole = 'BE'
        );
        insert atm;
        Opportunity opp2 = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Is_ETB__c = true,
            IO_Loan_Amount__c = '700000',
            Vehicle_Type__c = 'New',
            mapped_BE__c = u.Id,
            BE_mapping_date__c = Date.today()
        );
        insert opp2;
        System.debug('u.Username--:'+u.UserName);
        //call the Rest service
        BEUserMappingInformation.PincodeRequestData requestWrapper = new BEUserMappingInformation.PincodeRequestData();
        requestWrapper.pincode = '131302';
        requestWrapper.productType = 'Passenger Vehicles';
        requestWrapper.loanApplicationId =  opp.Id;
        
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/getBEUserInfo/';
        request.httpMethod = 'POST';
        system.debug('Before request.requestBody -->'+blob.valueof(Json.serialize(requestWrapper)));
        request.requestBody = blob.valueof(JSON.serialize(requestWrapper));
        RestContext.request = request;
        RestResponse res = new RestResponse();
        RestContext.response= res;
        system.debug('res-->'+res);
        BEUserMappingInformation.getBEInformation();
        Test.stopTest();
    }
    
    @isTest
    static void testBEAssignment11(){
        String orgId = UserInfo.getOrganizationId(); 
        String dateString =   
        String.valueof(Datetime.now()).replace(' ' ,'').replace(':','').replace('-','');  
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));  
        String uniqueName = orgId + dateString + randomInt;
        if(uniqueName.length() > 20 ){
            uniqueName = uniqueName.substring(0, 20);
        }
        System.debug(uniqueName);
        //create BE master record
        D2C_BE_Master__c beMaster = new D2C_BE_Master__c();
        beMaster.Pin_Code__c = 131302;
        beMaster.BL_Code__c = 'HDT';
        beMaster.Employee_Id__c = uniqueName;
        beMaster.Name = 'NANDLAL';
        beMaster.State__c = 'HARYANA';
        beMaster.Product_Type__c = 'Passenger Vehicles';
        beMaster.Vehicle_Type__c = 'New';
        insert beMaster;
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Is_ETB__c = true,
            IO_Loan_Amount__c = '700000',
            Vehicle_Type__c = 'New'
        );
        insert opp;
        
        Account acc = new Account(
        	Name = 'Test Account',
            Type = 'PV',
            Product_Type__c = 'New',
            BranchBLCode__c = 'HDT'
        );
        insert acc;
        
        //create a user record with matching employeeId as username.
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive']; 
        User u = new User(Alias = 'IBLBE', Email='NANDLAL1@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='NANDLAL', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Kolkata', UserName=uniqueName+'@testorg.com.test',EmployeeNumber = uniqueName, MobilePhone ='7217470708', Maker_Id__c = '1001');
        insert u;
        AccountTeamMember atm = new AccountTeamMember(
        	AccountId = acc.Id,
            UserId = u.Id,
            TeamMemberRole = 'BE'
        );
        insert atm;
        Opportunity opp2 = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Is_ETB__c = true,
            IO_Loan_Amount__c = '700000',
            Vehicle_Type__c = 'New',
            mapped_BE__c = u.Id,
            BE_mapping_date__c = Date.today()
        );
        insert opp2;
        Applicant__c apdt2 = new Applicant__c();
        apdt2.Opportunity__c = opp2.Id;
        apdt2.Contact_number__c = '9743514830';
        apdt2.Applicant_Type__c = 'Borrower';
        insert apdt2;
        
        Documents__c dsdt1 = new Documents__c();
        dsdt1.Applicant__c = apdt2.Id;
        dsdt1.Opportunity_Relation__c = opp2.Id;
        dsdt1.Document_Type__c = System.label.PanCards;
        dsdt1.Document_Side__c ='Back';
        dsdt1.PAN_No__c ='123456578';
        insert dsdt1;
        System.debug('u.Username--:'+u.UserName);
        //call the Rest service
        BEUserMappingInformation.PincodeRequestData requestWrapper = new BEUserMappingInformation.PincodeRequestData();
        requestWrapper.pincode = '131302';
        requestWrapper.productType = 'Passenger Vehicles';
        requestWrapper.loanApplicationId =  opp2.Id;
        
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/getBEUserInfo/';
        request.httpMethod = 'POST';
        system.debug('Before request.requestBody -->'+blob.valueof(Json.serialize(requestWrapper)));
        request.requestBody = blob.valueof(JSON.serialize(requestWrapper));
        RestContext.request = request;
        RestResponse res = new RestResponse();
        RestContext.response= res;
        system.debug('res-->'+res);
        BEUserMappingInformation.getBEInformation();
        Test.stopTest();
    }
    
    @isTest
    static void testBEAssignment12(){
        String orgId = UserInfo.getOrganizationId(); 
        String dateString =   
        String.valueof(Datetime.now()).replace(' ' ,'').replace(':','').replace('-','');  
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));  
        String uniqueName = orgId + dateString + randomInt;
        if(uniqueName.length() > 20 ){
            uniqueName = uniqueName.substring(0, 20);
        }
        System.debug(uniqueName);
        //create BE master record
        D2C_BE_Master__c beMaster = new D2C_BE_Master__c();
        beMaster.Pin_Code__c = 131302;
        beMaster.BL_Code__c = 'HDT';
        beMaster.Employee_Id__c = uniqueName;
        beMaster.Name = 'NANDLAL';
        beMaster.State__c = 'HARYANA';
        beMaster.Product_Type__c = 'Passenger Vehicles';
        beMaster.Vehicle_Type__c = 'New';
        insert beMaster;
        
        //create a user record with matching employeeId as username.
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive']; 
        User u = new User(Alias = 'IBLBE', Email='NANDLAL1@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='NANDLAL', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Kolkata', UserName=uniqueName+'@testorg.com.test',EmployeeNumber = uniqueName, MobilePhone ='7217470708', Maker_Id__c = '1001');
        insert u;
        Account acc = new Account(
        	Name = 'Test Account',
            Type = 'PV',
            Product_Type__c = 'New',
            BranchBLCode__c = 'HDT'
        );
        insert acc;
        AccountTeamMember atm = new AccountTeamMember(
        	AccountId = acc.Id,
            UserId = u.Id,
            TeamMemberRole = 'BE'
        );
        insert atm;
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Is_ETB__c = true,
            IO_Loan_Amount__c = '700000',
            Vehicle_Type__c = 'New',
            Ownerid = u.id
        );
        insert opp;        
        
        Opportunity opp2 = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Is_ETB__c = true,
            IO_Loan_Amount__c = '700000',
            Vehicle_Type__c = 'New',
            mapped_BE__c = u.Id,
            BE_mapping_date__c = Date.today(),
            Ownerid = u.id
        );
        insert opp2;
        Applicant__c apdt2 = new Applicant__c();
        apdt2.Opportunity__c = opp2.Id;
        apdt2.Contact_number__c = '9743514830';
        apdt2.Applicant_Type__c = 'Borrower';
        insert apdt2;
        
        Documents__c dsdt1 = new Documents__c();
        dsdt1.Applicant__c = apdt2.Id;
        dsdt1.Opportunity_Relation__c = opp2.Id;
        dsdt1.Document_Type__c = System.label.PanCards;
        dsdt1.Document_Side__c ='Back';
        dsdt1.PAN_No__c ='123456578';
        insert dsdt1;
        Documents__c dsdt2 = new Documents__c();
        dsdt2.Applicant__c = apdt2.Id;
        dsdt2.Opportunity_Relation__c = opp.Id;
        dsdt2.Document_Type__c = System.label.PanCards;
        dsdt2.Document_Side__c ='Back';
        dsdt2.PAN_No__c ='123456578';
        insert dsdt2;
        System.debug('u.Username--:'+u.UserName);
        //call the Rest service
        BEUserMappingInformation.PincodeRequestData requestWrapper = new BEUserMappingInformation.PincodeRequestData();
        requestWrapper.pincode = '131302';
        requestWrapper.productType = 'Passenger Vehicles';
        requestWrapper.loanApplicationId =  opp2.Id;
        
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/getBEUserInfo/';
        request.httpMethod = 'POST';
        system.debug('Before request.requestBody -->'+blob.valueof(Json.serialize(requestWrapper)));
        request.requestBody = blob.valueof(JSON.serialize(requestWrapper));
        RestContext.request = request;
        RestResponse res = new RestResponse();
        RestContext.response= res;
        system.debug('res-->'+res);
        BEUserMappingInformation.getBEInformation();
        Test.stopTest();
    }
    
    @isTest
    static void testBEAssignment2(){
        String orgId = UserInfo.getOrganizationId(); 
        String dateString =   
        String.valueof(Datetime.now()).replace(' ' ,'').replace(':','').replace('-','');  
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));  
        String uniqueName = orgId + dateString + randomInt;
        if(uniqueName.length() > 20 ){
            uniqueName = uniqueName.substring(0, 20);
        }
        System.debug(uniqueName);
        //create BE master record
        D2C_BE_Master__c beMaster = new D2C_BE_Master__c();
        beMaster.Pin_Code__c = 131302;
        beMaster.BL_Code__c = 'HDT';
        beMaster.Employee_Id__c = uniqueName;
        beMaster.Name = 'NANDLAL';
        beMaster.State__c = 'HARYANA';
        beMaster.Product_Type__c = 'Two Wheeler';
        beMaster.Vehicle_Type__c = 'New';
        insert beMaster;
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Is_ETB__c = true,
            IO_Loan_Amount__c = '700000',
            Vehicle_Type__c = 'New'
        );
        insert opp;
        
        Account acc = new Account(
        	Name = 'Test Account',
            Type = 'TW',
            Product_Type__c = 'New',
            BranchBLCode__c = 'HDT',
            State__c = 'HARYANA'
        );
        insert acc;
        Account acc2 = new Account(
        	Name = 'Test Account',
            Type = 'TW',
            Product_Type__c = 'New',
            State__c = 'HARYANA'
        );
        insert acc2;
        
        //create a user record with matching employeeId as username.
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive']; 
        User u = new User(Alias = 'IBLBE', Email='NANDLAL1@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='NANDLAL', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, isActive = true,
            TimeZoneSidKey='Asia/Kolkata', UserName=uniqueName+'@testorg.com.test',EmployeeNumber = uniqueName, MobilePhone ='7217470708', Maker_Id__c = '1001');
        insert u;
        AccountTeamMember atm = new AccountTeamMember(
        	AccountId = acc.Id,
            UserId = u.Id,
            TeamMemberRole = 'MA'
        );
        insert atm;
        AccountTeamMember atm2 = new AccountTeamMember(
        	AccountId = acc2.Id,
            UserId = u.Id,
            TeamMemberRole = 'MO'
        );
        insert atm2;
        Opportunity opp2 = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Is_ETB__c = true,
            IO_Loan_Amount__c = '700000',
            Vehicle_Type__c = 'New',
            mapped_BE__c = u.Id,
            BE_mapping_date__c = Date.today()
        );
        insert opp2;
        Applicant__c apdt1 = new Applicant__c();
        apdt1.Opportunity__c = opp.Id;
        apdt1.Contact_number__c = '9743514830';
        apdt1.Applicant_Type__c = 'Borrower';
        insert apdt1;
        
        Applicant__c apdt2 = new Applicant__c();
        apdt2.Opportunity__c = opp2.Id;
        apdt2.Contact_number__c = '9743514830';
        apdt2.Applicant_Type__c = 'Borrower';
        insert apdt2;
        
        Documents__c dsdt1 = new Documents__c();
        dsdt1.Applicant__c = apdt1.Id;
        dsdt1.Opportunity_Relation__c = opp.Id;
        dsdt1.Document_Type__c = System.label.PanCards;
        dsdt1.Document_Side__c ='Back';
        insert dsdt1;
        
        Documents__c dsdt2 = new Documents__c();
        dsdt2.Opportunity_Relation__c = opp2.Id;
        dsdt2.Applicant__c = apdt2.Id;
        dsdt2.Document_Type__c = System.label.PanCards;
        dsdt2.Document_Side__c ='Back';
        insert dsdt2;
        
        System.debug('u.Username--:'+u.UserName);
        //call the Rest service
        BEUserMappingInformation.PincodeRequestData requestWrapper = new BEUserMappingInformation.PincodeRequestData();
        requestWrapper.pincode = '131302';
        requestWrapper.productType = 'Two Wheeler';
        requestWrapper.loanApplicationId =  opp.Id;
        
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/getBEUserInfo/';
        request.httpMethod = 'POST';
        system.debug('Before request.requestBody -->'+blob.valueof(Json.serialize(requestWrapper)));
        request.requestBody = blob.valueof(JSON.serialize(requestWrapper));
        RestContext.request = request;
        RestResponse res = new RestResponse();
        RestContext.response= res;
        system.debug('res-->'+res);
        BEUserMappingInformation.getBEInformation();
        Test.stopTest();
    }
    
    @isTest
    static void testBEAssignment22(){
        String orgId = UserInfo.getOrganizationId(); 
        String dateString =   
        String.valueof(Datetime.now()).replace(' ' ,'').replace(':','').replace('-','');  
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));  
        String uniqueName = orgId + dateString + randomInt;
        if(uniqueName.length() > 20 ){
            uniqueName = uniqueName.substring(0, 20);
        }
        System.debug(uniqueName);
        //create BE master record
        D2C_BE_Master__c beMaster = new D2C_BE_Master__c();
        beMaster.Pin_Code__c = 131302;
        beMaster.BL_Code__c = 'HDT';
        beMaster.Employee_Id__c = uniqueName;
        beMaster.Name = 'NANDLAL';
        beMaster.State__c = 'HARYANA';
        beMaster.Product_Type__c = 'Passenger Vehicles';
        beMaster.Vehicle_Type__c = 'New';
        insert beMaster;
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Is_ETB__c = true,
            IO_Loan_Amount__c = '700000',
            Vehicle_Type__c = 'New'
        );
        insert opp;
        
        Account acc = new Account(
        	Name = 'Test Account',
            Type = 'PV',
            Product_Type__c = 'Used',
            BranchBLCode__c = 'HDT',
            State__c = 'HARYANA'
        );
        insert acc;
        Account acc2 = new Account(
        	Name = 'Test Account',
            Type = 'PV',
            Product_Type__c = 'Used',
            State__c = 'HARYANA'
        );
        insert acc2;
        
        //create a user record with matching employeeId as username.
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive']; 
        User u = new User(Alias = 'IBLBE', Email='NANDLAL1@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='NANDLAL', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, isActive = true,
            TimeZoneSidKey='Asia/Kolkata', UserName=uniqueName+'@testorg.com.test',EmployeeNumber = uniqueName, MobilePhone ='7217470708', Maker_Id__c = '1001');
        insert u;
        AccountTeamMember atm = new AccountTeamMember(
        	AccountId = acc.Id,
            UserId = u.Id,
            TeamMemberRole = 'BE'
        );
        insert atm;
        AccountTeamMember atm2 = new AccountTeamMember(
        	AccountId = acc2.Id,
            UserId = u.Id,
            TeamMemberRole = 'BE'
        );
        insert atm2;
        Opportunity opp2 = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Is_ETB__c = true,
            IO_Loan_Amount__c = '700000',
            Vehicle_Type__c = 'Refinance',
            IO_Vehicle_Pincode__c = '23456',
            mapped_BE__c = u.Id,
            BE_mapping_date__c = Date.today()
        );
        insert opp2;
        Applicant__c apdt1 = new Applicant__c();
        apdt1.Opportunity__c = opp.Id;
        apdt1.Contact_number__c = '9743514830';
        apdt1.Applicant_Type__c = 'Borrower';
        insert apdt1;
        
        Applicant__c apdt2 = new Applicant__c();
        apdt2.Opportunity__c = opp2.Id;
        apdt2.Contact_number__c = '9743514830';
        apdt2.Applicant_Type__c = 'Borrower';
        insert apdt2;
        
        Documents__c dsdt1 = new Documents__c();
        dsdt1.Applicant__c = apdt1.Id;
        dsdt1.Opportunity_Relation__c = opp.Id;
        dsdt1.Document_Type__c = System.label.PanCards;
        dsdt1.Document_Side__c ='Back';
        insert dsdt1;
        
        Documents__c dsdt2 = new Documents__c();
        dsdt2.Opportunity_Relation__c = opp2.Id;
        dsdt2.Applicant__c = apdt2.Id;
        dsdt2.Document_Type__c = System.label.PanCards;
        dsdt2.Document_Side__c ='Back';
        insert dsdt2;
        
        System.debug('u.Username--:'+u.UserName);
        //call the Rest service
        BEUserMappingInformation.PincodeRequestData requestWrapper = new BEUserMappingInformation.PincodeRequestData();
        requestWrapper.pincode = '131302';
        requestWrapper.productType = 'Passenger Vehicles';
        requestWrapper.loanApplicationId =  opp.Id;
        
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/getBEUserInfo/';
        request.httpMethod = 'POST';
        system.debug('Before request.requestBody -->'+blob.valueof(Json.serialize(requestWrapper)));
        request.requestBody = blob.valueof(JSON.serialize(requestWrapper));
        RestContext.request = request;
        RestResponse res = new RestResponse();
        RestContext.response= res;
        system.debug('res-->'+res);
        BEUserMappingInformation.getBEInformation();
        Test.stopTest();
    }
    
    @isTest
    static void testBEAssignment23(){
        String orgId = UserInfo.getOrganizationId(); 
        String dateString =   
        String.valueof(Datetime.now()).replace(' ' ,'').replace(':','').replace('-','');  
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));  
        String uniqueName = orgId + dateString + randomInt;
        if(uniqueName.length() > 20 ){
            uniqueName = uniqueName.substring(0, 20);
        }
        System.debug(uniqueName);
        //create BE master record
        D2C_BE_Master__c beMaster = new D2C_BE_Master__c();
        beMaster.Pin_Code__c = 131302;
        beMaster.BL_Code__c = 'HDT';
        beMaster.Employee_Id__c = uniqueName;
        beMaster.Name = 'NANDLAL';
        beMaster.State__c = 'HARYANA';
        beMaster.Product_Type__c = 'Passenger Vehicles';
        beMaster.Vehicle_Type__c = 'New';
        insert beMaster;
        Account acc = new Account(
        	Name = 'Test Account',
            Type = 'PV',
            Product_Type__c = 'New',
            BranchBLCode__c = 'HDT',
            State__c = 'HARYANA'
        );
        insert acc;
        Account acc2 = new Account(
        	Name = 'Test Account',
            Type = 'PV',
            Product_Type__c = 'New',
            State__c = 'HARYANA'
        );
        insert acc2;
        
        //create a user record with matching employeeId as username.
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive']; 
        User u = new User(Alias = 'IBLBE', Email='NANDLAL1@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='NANDLAL', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, isActive = true,
            TimeZoneSidKey='Asia/Kolkata', UserName=uniqueName+'@testorg.com.test',EmployeeNumber = uniqueName, MobilePhone ='7217470708', Maker_Id__c = '1001');
        insert u;
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Is_ETB__c = true,
            IO_Loan_Amount__c = '700000',
            Vehicle_Type__c = 'New',
            ownerId=u.id
        );
        insert opp;
        
        
        AccountTeamMember atm = new AccountTeamMember(
        	AccountId = acc.Id,
            UserId = u.Id,
            TeamMemberRole = 'BE'
        );
        insert atm;
        AccountTeamMember atm2 = new AccountTeamMember(
        	AccountId = acc2.Id,
            UserId = u.Id,
            TeamMemberRole = 'BE'
        );
        insert atm2;
        Opportunity opp2 = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Is_ETB__c = true,
            IO_Loan_Amount__c = '700000',
            Vehicle_Type__c = 'New',
            mapped_BE__c = u.Id,
            BE_mapping_date__c = Date.today(),
            OwnerId = u.Id
        );
        insert opp2;
        Applicant__c apdt1 = new Applicant__c();
        apdt1.Opportunity__c = opp.Id;
        apdt1.Contact_number__c = '9743514830';
        apdt1.Applicant_Type__c = 'Borrower';
        insert apdt1;
        
        Applicant__c apdt2 = new Applicant__c();
        apdt2.Opportunity__c = opp2.Id;
        apdt2.Contact_number__c = '9743514830';
        apdt2.Applicant_Type__c = 'Borrower';
        insert apdt2;
        
        Documents__c dsdt1 = new Documents__c();
        dsdt1.Applicant__c = apdt1.Id;
        dsdt1.Opportunity_Relation__c = opp.Id;
        dsdt1.Document_Type__c = System.label.PanCards;
        dsdt1.Document_Side__c ='Back';
        insert dsdt1;
        
        Documents__c dsdt2 = new Documents__c();
        dsdt2.Opportunity_Relation__c = opp2.Id;
        dsdt2.Applicant__c = apdt2.Id;
        dsdt2.Document_Type__c = System.label.PanCards;
        dsdt2.Document_Side__c ='Back';
        insert dsdt2;
        
        System.debug('u.Username--:'+u.UserName);
        //call the Rest service
        BEUserMappingInformation.PincodeRequestData requestWrapper = new BEUserMappingInformation.PincodeRequestData();
        requestWrapper.pincode = '131302';
        requestWrapper.productType = 'Passenger Vehicles';
        requestWrapper.loanApplicationId =  opp.Id;
        requestWrapper.isAggregator =  true;
        
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/getBEUserInfo/';
        request.httpMethod = 'POST';
        system.debug('Before request.requestBody -->'+blob.valueof(Json.serialize(requestWrapper)));
        request.requestBody = blob.valueof(JSON.serialize(requestWrapper));
        RestContext.request = request;
        RestResponse res = new RestResponse();
        RestContext.response= res;
        system.debug('res-->'+res);
        BEUserMappingInformation.getBEInformation();
        Test.stopTest();
    }
    

    @isTest
    static void testBEAssignment1(){
        String orgId = UserInfo.getOrganizationId(); 
        String dateString = String.valueof(Datetime.now()).replace(' ' ,'').replace(':','').replace('-','');  
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));  
        String uniqueName = orgId + dateString + randomInt;
        if(uniqueName.length() > 20 ){
            uniqueName = uniqueName.substring(0, 20);
        }
        System.debug(uniqueName);
        
        //create BE master record
        D2C_BE_Master__c beMaster = new D2C_BE_Master__c();
        beMaster.Pin_Code__c = 131302;
        beMaster.BL_Code__c = 'HDT';
        beMaster.Employee_Id__c = '1'+uniqueName;
        beMaster.Name = 'NANDLAL';
        beMaster.State__c = 'HARYANA';
        beMaster.Product_Type__c = 'Passenger Vehicles';
        
        D2C_BE_Master__c beMaster1 = new D2C_BE_Master__c();
        beMaster1.Pin_Code__c = 131303;
        beMaster1.BL_Code__c = 'HDT';
        beMaster1.Employee_Id__c = uniqueName;
        beMaster1.Name = 'ANANDLAL';
        beMaster1.State__c = 'HARYANA';
        beMaster1.Product_Type__c = 'Passenger Vehicles';
        
        insert new List<D2C_BE_Master__c>{beMaster, beMaster1};
        
        //create a user record with matching employeeId as username.
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive']; 
        User u = new User(Alias = 'IBLBE', Email='NANDLAL1@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='NANDLAL', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Kolkata', UserName=uniqueName+'@testorg.com.test',EmployeeNumber = uniqueName, MobilePhone ='7217470708', Maker_Id__c = '1001');
        insert u;
        System.debug('u.Username--:'+u.UserName);
        //call the Rest service
        BEUserMappingInformation.PincodeRequestData requestWrapper = new BEUserMappingInformation.PincodeRequestData();
        requestWrapper.pincode = '';
        requestWrapper.productType = 'Passenger Vehicles';
        
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/getBEUserInfo/';
        request.httpMethod = 'POST';
        system.debug('Before request.requestBody -->'+blob.valueof(Json.serialize(requestWrapper)));
        request.requestBody = blob.valueof(JSON.serialize(requestWrapper));
        RestContext.request = request;
        RestResponse res = new RestResponse();
        RestContext.response= res;
        system.debug('res-->'+res);
        BEUserMappingInformation.getBEInformation();
        Test.stopTest();
    }
}