/**
* @author Khushiram
* @company Persistent Systems
* @description A  Test class for the Utilites class
* Inputs: None
* History:
* 2/09/2021 Khushiram
*/
@isTest(SeeAllData=false)
public with sharing class UtilitesTest { 
    
    @testSetup static void setup(){
        String headerInfo='Unit Test ContentVersion Body to be insert in test class for testing the';
		TestDataUtility.createContentVersion(headerInfo, true);
        TestDataUtility.createSequenceNumber(true);  
        
        Opportunity oppObj = TestDataUtility.createTestOpportunity(true);
        
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c = oppObj.Id;
        insert applicantObj;
        
        //Document object for front side image testing.
        Documents__c frontDoc =  TestDataUtility.createTestKYCDocs(false, applicantObj, oppObj);
        insert frontDoc;   
        
        //Document object for Back side image testing.
        Documents__c backDoc = TestDataUtility.createTestKYCDocs(false, applicantObj, oppObj);
        backDoc.Is_Back__c = true;
        backDoc.Document_Type__c = 'PAN';
        backDoc.Document_Side__c ='Back';
        insert backDoc;
        
        Documents__c PAN = TestDataUtility.createTestKYCDocs(false, applicantObj, oppObj);
        PAN.Is_Back__c = true;
        PAN.Document_Type__c = 'Voter Id';
        PAN.Document_Side__c ='Back';
        insert PAN;
        
        Documents__c Voter = TestDataUtility.createTestKYCDocs(false, applicantObj, oppObj);
        Voter.Is_Back__c = true;
        Voter.Document_Type__c = 'Voter Id';
        Voter.Document_Side__c ='Back';
        insert Voter;
        
        Documents__c DL = TestDataUtility.createTestKYCDocs(false, applicantObj, oppObj);
        DL.Is_Back__c = true;
        DL.Document_Type__c = 'Driving Licence';
        DL.Document_Side__c ='Back';
        insert DL;
        
        
        Geo_State_Masters__c geoobj= new Geo_State_Masters__c();
         
           geoobj.Pincode__c = 531022.000;
           geoobj.Pincode_Starting_Max__c=6.0; 
         //  insert geoobj;
      }
    
    @isTest 
    public static void testEncryptToBase64(){
        try{
            ContentVersion uploadedImage = [SELECT Id,ContentDocumentId,VersionData 
                                               FROM ContentVersion WHERE  Title = 'IndusIndLogo'];
            Test.startTest();
            String expectedValue = EncodingUtil.base64Encode(uploadedImage.VersionData);
            String encryptedBase64 = Utilities.encryptToBase64(uploadedImage.VersionData);
            String encryptedBase64Exception = Utilities.encryptToBase64(null);
            Test.stopTest();
            system.assertEquals(expectedValue,encryptedBase64);
        }
        Catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest 
    public static void testGenerateUniqueNumber(){
        try{
        	Test.startTest();
            Integer randomNumberTest  = Utilities.generateUniqueNumber(4);
            system.debug('Random Number test ' +randomNumberTest);
            String randomNumberLength = string.ValueOf(randomNumberTest);
            Integer randomNumberTestException  = Utilities.generateUniqueNumber(-4);
             
            Test.stopTest();
            system.assertEquals(4 , randomNumberLength.length());
        }
        Catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest 
    public static void testStateMasterData(){
        
        try{
        	Test.startTest();
            List<Geo_State_Masters__c> stateMastersData=Utilities.getStateMasterData();
             
            Test.stopTest();
            
        }
         Catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
        
    }
    
    @isTest 
    public static void testCityMasterData(){
        
        try{
        	Test.startTest();
           // List<City_State_Master__c> cityMastersData=Utilities.getCityStateMaster('Telangana');
             Utilities.getCityStateMaster(null);
            Test.stopTest();
            
        }
         Catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
        
    }
    
     @isTest 
    public static void getDistrictsbyState(){
        
        try{
        	Test.startTest();
            List <District_Master__c> DistrictsByState=Utilities.getDistrictsByState('Hyderabad');
             
            Test.stopTest();
            
        }
         Catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
        
    }
   

   
    // Added By Nidhi Dhote start //
    @isTest 
    public static void testvalidateContactNumber(){
        try{
        Test.startTest();
        Boolean isNumberAvailable  = Utilities.validateContactNumber('93252344');
        Test.stopTest();
        system.assertEquals(false , isNumberAvailable);
       }
        Catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    // Added By Nidhi Dhote start //
    @isTest 
    public static void testInvalidContactNumber(){
        try{
      
        Test.startTest();
        Boolean isNumberAvailable  = Utilities.validateContactNumber('93252344');
        Test.stopTest();
        system.assertEquals(false , isNumberAvailable);
      }Catch(Exception e){
         system.assertEquals('Script-thrown exception', e.getMessage());
      }
    }
    // Ended By Nidhi Dhote start //

	// Added By Naga Puppala IND-288 start //    
    @isTest
    public static void testGeneratePDFfromResponse(){
        try{
      
        Account acc = TestDataUtility.createTestAccount(true);
       
        Test.startTest();
        Utilities.generatePDFfromResponse('Test Response', acc.Id);
        List<Attachment> attList = [select Id from Attachment where parentID = :acc.Id];
        Test.stopTest();
           
        system.assertEquals(1, attList.size());
        }
        Catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
           
       }
    }
    // Added By Naga Puppala IND-288 end //
    
    @isTest 
    public static void testGenerateApplicationNumber(){
        Test.startTest();
        Integer applicationNumber = Utilities.generateApplicationNumber();
        Test.stopTest();
        system.debug('Application Number test ' +applicationNumber);
        system.assertEquals(123456, applicationNumber);
    }
        
    @isTest 
    public static void testGenerateApplicationNumberNew(){
       try{
           System_Configuration__c sysConfig = new System_Configuration__c();
           sysConfig.Name = 'System Configuration';
           sysConfig.Eligible_Roles_for_BE_Assignment__c = 'BE,CS';
           sysConfig.Eligible_Roles_for_CS_Assignment__c = 'CS,MA';
           sysConfig.Eligible_Roles_for_MA_Assignment__c = 'MA,MO';
           sysConfig.Eligible_Roles_for_MO_Assignment__c = 'BE,CS,MA,MO';
           sysConfig.Lead_Sequence_No__c='984935';
           sysConfig.Application_Date__c = System.today();
           insert sysConfig;  
           Test.startTest();
           String leadNumberResponses = Utilities.generateUniqueLeadNumber();
           Test.stopTest();
           //system.assertEquals(13, leadNumberResponses.length());
       }
       Catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
       }
    }
    
    @isTest
    public static void getRetryCountTest(){
        try{
                Opportunity opgr1 = new Opportunity();
                opgr1.StageName = 'Qualification';
                opgr1.CloseDate = Date.newInstance(2021, 1, 11);
                opgr1.Name = 'testone';
                insert opgr1;
               
                Applicant__c apgr1 = new Applicant__c();
                apgr1.Opportunity__c = opgr1.Id;
                apgr1.Contact_number__c = '9743514830';
                apgr1.Applicant_Type__c = 'Borrower';
                insert apgr1;
            
                Retry_Count__c rc1 = new Retry_Count__c();
                rc1.Loan_Application_Id__c = opgr1.Id;
                rc1.Applicant__c = apgr1.Id;
                rc1.Applicant_Type__c = 'Borrower';
                rc1.Count__c = 1;
                rc1.Customer_Dedupe__c = 1;
                rc1.Module__c = 'testmodule';
                insert rc1;
            
                Test.startTest();
                      Utilities.getRetryCount(opgr1.Id,rc1.Applicant_Type__c,'Count__c','Customer_Dedupe_Attempts');
                Test.stopTest();
                
                
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getRetryCountTest1(){
        try{
                Opportunity opgr1 = new Opportunity();
                opgr1.StageName = 'Qualification';
                opgr1.CloseDate = Date.newInstance(2021, 1, 11);
                opgr1.Name = 'testone';
                insert opgr1;
               
                Applicant__c apgr1 = new Applicant__c();
                apgr1.Opportunity__c = opgr1.Id;
                apgr1.Contact_number__c = '9743514830';
                apgr1.Applicant_Type__c = 'Borrower';
                insert apgr1;
            
                Retry_Count__c rc1 = new Retry_Count__c();
                rc1.Loan_Application_Id__c = opgr1.Id;
                rc1.Applicant__c = apgr1.Id;
                rc1.Applicant_Type__c = 'Borrower';
                rc1.Count__c = 1;
                rc1.Customer_Dedupe__c = 1;
                rc1.Module__c = 'testmodule';
                insert rc1;
            
                Test.startTest();
                      Utilities.getRetryCount(opgr1.Id,'','Count__c','Customer_Dedupe_Attempts');
                Test.stopTest();
                
                
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void createPersonAccountTest(){
                Opportunity opgr1 = new Opportunity();
                opgr1.StageName = 'Qualification';
                opgr1.CloseDate = Date.newInstance(2021, 1, 11);
                opgr1.Name = 'testone';
                insert opgr1;
               
                Applicant__c apgr1 = new Applicant__c();
        
               // apgr1.Account__c = null;
                apgr1.Opportunity__c = opgr1.Id;
                apgr1.Contact_number__c = '9743514830';
                apgr1.Applicant_Type__c = 'Borrower';
                apgr1.Customer_First_Name__c = 'testone';
                apgr1.Customer_Last_Name__c = 'testlast';
                insert apgr1;
        
                Account a1 = new Account();
                a1.Name = 'testname';
             //   a1.FirstName = apgr1.Customer_First_Name__c;
            //    a1.LastName = apgr1.Customer_Last_Name__c;
                a1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
                insert a1;
                
                    
     
              Customer_Dedupe_Response__c cdr1 = new Customer_Dedupe_Response__c();
              cdr1.Applicant__c = apgr1.Id;
              cdr1.CIC_No__c = '545667';
              cdr1.CIN_No__c = '34455';
              insert cdr1;
             
                Test.startTest();
                    //  Utilities.createPersonAccount(apgr1.Id);
                Test.stopTest();
    }
    
 
    
    @isTest
    public static void createContentDocumentFromApexTest(){
        try{
                Opportunity opgr1 = new Opportunity();       
                opgr1.StageName = 'Qualification';
                opgr1.CloseDate = Date.newInstance(2021, 1, 11);
                opgr1.Name = 'testone';
                insert opgr1;
        
                Blob b1 =  Blob.valueOf('This is version data');
        
               ContentVersion cv1 = new ContentVersion();
               cv1.Title = 'Aadhar';
               cv1.VersionData = b1;
               cv1.IsMajorVersion = true;
               cv1.PathOnClient = 'test';
               insert cv1;
        
               Id conDocId1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv1.Id].ContentDocumentId;
            
            
            ContentDocumentLink cdl1 = New ContentDocumentLink();
            cdl1.LinkedEntityId = opgr1.Id;
            cdl1.ContentDocumentId = conDocId1;
            cdl1.shareType = 'V';
            insert cdl1;
        
            Test.startTest();
                 Utilities.createContentDocumentFromApex(opgr1.Id,cv1.Title,b1,cv1.PathOnClient);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     
    
    @isTest
    public static void pidblockTest(){
        
         String response = '<PidData><Resp errCode="0" errInfo="SUCCESS" nmPoints="37" fType = "0" fCount = "1" qScore="74" /><DeviceInfo dpId="SECUGEN.SGI" rdsId="SGI.AND.001" rdsVer="1.0.2" dc="d2620fa5-0cb8-11e8-b92d-1418775b2036" mi="HU20" mc="MIIDoTCCAomgAwIBAgIEBBlSYjANBgkqhkiG9w0BAQUFADCBvzEmMCQGCSqGSIb3DQEJARYXa3VuZGFqQHNlY3VnZW5pbmRpYS5jb20xDzANBgNVBAcTBk11bWJhaTEsMCoGA1UEAxMjRFMgU0VDVUdFTiBJTkRJQSBQUklWQVRFIExJTUlURUQgMDQxJjAkBgNVBAoTHVNFQ1VHRU4gSU5ESUEgUFJJVkFURSBMSU1JVEVEMQswCQYDVQQLEwJJVDEUMBIGA1UECBMLTWFoYXJhc2h0cmExCzAJBgNVBAYTAklOMB4XDTIxMD-EyMTEwNDY1NVoXDTIxMDIyMDEwNDY1NVowZTEZMBcGA1UEAxMQc2dpcmRzc3Vic2NyaWJlcjENMAsGA1UECxMEQVVUSDEMMAoGA1UEChMDQVVBMQ4wDAYDVQQHEwVJbmRpYTEOMAwGA1UECBMFU3RhdGUxCzAJBgNVBAYTAklOMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsXz3GViGd780Rl5+WcVwtZQCh6A6T4Ee53tRYbi5cGxqRhaw31QHKtXudAUjXh/ZhD4J8X091vawBxqN9aI0fgGe377g7TnUoYS0luLynvhbzgee8KWf5bV+CpDrUeTPNvN5IzpsmD5KsNdUoOG/nAjc2IXoRZp6HyX6ZJigaieJ+WmZFL28wtWQJ/KU26ckbdYUWZ3drBXmhUxobWi2/k3vgiCVP5kUZm27kdte2UBkrD71sfUJpH37JgP5ailsy8R+TPGAvrCERUNCyif3AqfX5VtUv9+dI4khqta6utKAK8kxgcmdO+9qGue1h8npngSRBOQS26hwK9j23sfsGQIDAQABMA0GCSqGSIb3DQEBBQUAA4IBAQAjqySQzvrQ2sBm+dJZmN2KodfrZxwCnMVH/TuEBQsdv/Gvql2oQKLmnbL1o4i1H2N2HosMb8BFM/7R/0ze92HgwNqY0TxU45PnrPHjlCCVTt3POmneZGiEitc04aSZIOT96u7uYdqRgQ+NQhcsheI6iwy4Mf4bzVBr2JpaduvaF6UlP8488e/ROIUDYZdtEj8CtB43ZUWuhdk13Tynu0nM4/0Wcya2dwrKvASS1+eIYFx/qBKe8NtkMPwD+5s/9q5W9h/zbZwBPKPdnzB67itif+PUE36XRYAEqfZ4w8cd4VyrQQ8u0qPyrvNe3MSgA7Ndfw2kZe3+EtFxk6t3dpi/" ><additional_info><Param name="version" value="v1.0.2(0178)" /><Param name="camera" value="0" /><Param name="srno" value="H54201219107" /><Param name="pass" value="N" /></additional_info></DeviceInfo><Skey ci="20221023" >e5Pn3SM7OlHyBGRScN7wE9RAKU1w1VcQtpa8Z3up8sNwz3Y6JvR0Df4JOr+YtrKl44rBkG0rtb2cN6TpqYt5LJh6eyCLVTgoMkt61aSVVMS4ulkRXiBk3TNTeeujg+iSRwMIMNW7Cezgz+wUXgTIJ9iwaRorb3pV0ELWS7W4GugBSyfWpRUvs2B2U7bEg1m4igR7wYgP8/4e8JLEqy/tURgzRdoXFi2D33BgNCRyBPIl17p4LSHI5W9WhkOgT99/nsPRUcnuL7LmzcSQw1FYKewquE6njIfR2UL87Ck9LGP9Z78o2XvfhXDbupV2vMUOm95LEwApKrvO2IGM+vNo7g==</Skey><Hmac>UWxnwQulzeD6JniR0Rd0XXcWtl6nRSldK79FKufac4Bf4ifQikblrkJA+za8mozE</Hmac><Data type="X">MjAyMS0wMi0xMFQxNjoxOTo1NNX8A6e5eEtaXQ+TzCMoDHXjFbNy0heMFlAm0PWZFPwJEMfW09h/erSVV7nXTwEkmpHwzgxqFYrlbX1BTAFGVyxHIUkbGIbmjcWAHvMAWK/AWoa7WOO73Eba8IXReWnO374WQq/HAWt0uJUVyVWjkP8L/8Jj9kvnEx5t6BfeSRe1e9w2XNk4tf+HLlIPiwVf1qe/+iBpXA63aW08BB9fCCHxK7nHOt7pD0tileTXhwv+ryxbxObLREYDAB4myt9dFeEsHJS5M6KaJf0y8uDgN6vh83kvzxBOA6j8q3A66smmwQs2AURAADk/6qpAH01vzOhcZ3+LBUAst6oohmK3e2RlCtwGzwlfHbxPFhcvrhbX8fuQvK9/koXjpYfG2a95u7scH4YfhUFBTjv4WWnhE2lHBzuvjRL6DOJnu4fQJ/VVJQ6xD+0lePuu1ZppW0OWWyV9y1tcDI7NaDY3auj4w6z25+HuLxVG7F+U/vNKKtcE2VOwtPrytgPj764E0X5LUtymkRYoTbUAc3Q+p8MyVCI7rIn3oXuOV0aLh6i8oWKhPm/1asS+BUS4QKF9N8TpXB7kSe6pr8qKUPDDLIlMXb5WeEfTCUMpF+tC4EIQ7Tc7WNABYkapkXEcEIGszRXVsGNmXYx7CuZMvCiv5bSMRLpAOX3peXtB+nxMiwbzUpvOG4FF2Bw/4kwD3yQJoDdHk5McvZaZQAOx/AG27XOlN1jyU0/9RCEVDb2ZjVmFXUAlbl0e2eLBXf1jXTixvGPFNQ7lEk1oIiNhpUYGJCr91QyShpd/b2GLVc7q/g8SSZGQpsT+ESpAjTS0ai9AbuFjzIZH2k/TVf800ZjeAIEdWYju9/S0tHsmPzWFNihk55iQOuYKAdz/MsFxqc+CD03ICiGD9LdV39FBr46caaF2ldfFziQzJKVZvp8mFBvYP08UR1T/c8xIVM4lE22/1oauSddUgiPNt2h8lHBYezSLSW29Shv96oY9uv7I/lIse2boddm3Muev+ocXJiuctlkDVeQr679+KndMgzRMJmOwxsb/OJMi3ht1yWy4RRJmjW5z3iQM4GuY9jc/i/M0tkyNo35WHzsfZciPaaiJQ7+OnqnJxj652fqTbVDlvZ5E3PdjS0Hu1vCzF7J50VJZpUTm8pISPNZlrPm6u7L05OtmUeZUbJz8KWXPZta/Dawvjk5Ad5XySp9vMWWYwwzixX5Wqko=</Data></PidData>';
        
          Test.startTest();
                Utilities.pidblock(response);
          Test.stopTest();
        
    } 

     @isTest
    public static void listContainsTest(){
                Opportunity opgr1 = new Opportunity();       
                opgr1.StageName = 'Qualification';
                opgr1.CloseDate = Date.newInstance(2021, 1, 11);
                opgr1.Name = 'testone';
                insert opgr1;
        
                List<Opportunity> opList = new List<Opportunity>();
                opList.add(opgr1);
                
                 Test.startTest();
                     Utilities.listContains(opList, opgr1);
                 Test.stopTest();
    }
    
    @isTest
    public static void getHeadersTest(){
        Test.startTest();
            Utilities.getHeaders();
        Test.stopTest();
    }
    
    @isTest
    public static void getApplicantIdTest(){
        try{
                Opportunity opg1 = new Opportunity();
                opg1.StageName = 'Qualification';
                opg1.CloseDate = Date.newInstance(2021, 1, 11);
                opg1.Name = 'testone';
                insert opg1;
                
                Applicant__c apg1 = new Applicant__c();
                apg1.Opportunity__c = opg1.Id;
                apg1.Contact_number__c = '9743514830';
                apg1.Applicant_Type__c = 'Borrower';
                apg1.In_Active_Applicant__c = false;
                insert apg1;
            
            Test.startTest();
                  Utilities.getApplicantId(opg1.Id,apg1.Applicant_Type__c);
                  Utilities.getApplicantId('test','test');
                  Utilities.getApplicantId(null,null);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void fetchCustomerCodeTest(){
        try{
            Account af1 = new Account();
            af1.Name = 'test';
            af1.Customer_Code__c = 'test123';
            af1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
            insert af1;
            
                Opportunity opg2 = new Opportunity();
                opg2.StageName = 'Qualification';
                opg2.CloseDate = Date.newInstance(2021, 1, 11);
                opg2.Name = 'testone';
                insert opg2;
                
                Applicant__c apg2 = new Applicant__c();
                apg2.Account__c = af1.Id;
                apg2.Opportunity__c = opg2.Id;
                apg2.Contact_number__c = '9743514830';
                apg2.Applicant_Type__c = 'Borrower';
                insert apg2;
                
                Test.startTest();
                    Utilities.fetchCustomerCode(apg2.Id);
                Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void fetchCustomerCodeTest1(){
        try{
                       
                Opportunity opg3 = new Opportunity();
                opg3.StageName = 'Qualification';
                opg3.CloseDate = Date.newInstance(2021, 1, 11);
                opg3.Name = 'testone';
                insert opg3;
                
                Applicant__c apg3 = new Applicant__c();
                apg3.Opportunity__c = opg3.Id;
                apg3.Contact_number__c = '9743514830';
                apg3.Applicant_Type__c = 'Borrower';
                insert apg3;
                
                Test.startTest();
                  //  Utilities.fetchCustomerCode(opg3.Id);
                Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getCityStateMaster2Test(){
        try{
                Geo_State_Masters__c gm4 = new Geo_State_Masters__c();
                gm4.NeSL_State_Code__c = 'test';
                gm4.OwnerId = UserInfo.getUserId();
                gm4.Pincode_Starting_Max__c = 524;
                gm4.Pincode__c = 315;
                gm4.Name = 'ap';
                gm4.State_Code__c = '01';
                insert gm4;
            
                City_State_Master__c csm4 = new City_State_Master__c();
                csm4.City_Code__c = 'PORT BLAIR';
                csm4.Carwale_ID__c = 296;
                csm4.State__c = gm4.Id;
                insert csm4;
            
                Test.startTest();
                     Utilities.getCityStateMaster2(gm4.Name);
                     Utilities.getCityStateMaster2(null);
                Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void getCityStateMaster2Test1(){
        try{
                Geo_State_Masters__c gm5 = new Geo_State_Masters__c();
                gm5.NeSL_State_Code__c = 'test';
                gm5.OwnerId = UserInfo.getUserId();
                gm5.Pincode_Starting_Max__c = 524;
                gm5.Pincode__c = 315;
                gm5.Name = 'ap';
                gm5.State_Code__c = '01';
                insert gm5;
            
                Test.startTest();
                     Utilities.getCityStateMaster2(gm5.Name);
                Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getMFCCityMasterBasedOnStateCode1(){
        try{
                MFC_City_Master__c gm5 = new MFC_City_Master__c();
            	gm5.State_Code__c = '123';
                insert gm5;
            
                Test.startTest();
                     Utilities.getMFCCityMasterBasedOnStateCode(gm5.State_Code__c);
                Test.stopTest();
            
        }catch(Exception e){
            System.debug('getCityStateMaster2Test2 '+ e.getMessage());
        }
    }
    
    @isTest
    public static void getMFCStateMasterDataTest1(){
        try{
                Test.startTest();
                     Utilities.getMFCStateMasterData();
                Test.stopTest();
            
        }catch(Exception e){
            System.debug('getCityStateMaster2Test2 '+ e.getMessage());
        }
    }
    
    @isTest
    public static void getIntegrationLogsTest1(){
        try{
            Opportunity opp = [Select Id From Opportunity LIMIT 1];
                Test.startTest();
                     Utilities.getIntegrationLogs('',opp.Id);
                Test.stopTest();
            
        }catch(Exception e){
            System.debug('getIntegrationLogs '+ e.getMessage());
        }
    }
    
    @isTest
    public static void getIntegrationLogTest2(){
        try{
            Opportunity opp = [Select Id From Opportunity LIMIT 1];
                Test.startTest();
                     Utilities.getIntegrationLog(new List<String>(),opp.Id);
                Test.stopTest();
            
        }catch(Exception e){
            System.debug('getIntegrationLog '+ e.getMessage());
        }
    }
    
    @isTest
    public static void getCustDedupeBasedOnCICNumberTest1(){
        try{
            Opportunity opp = [Select Id From Opportunity LIMIT 1];
                Test.startTest();
                     Utilities.getCustDedupeBasedOnCICNumber(new Set<String>(),'Two Wheeler',opp.Id);
                Test.stopTest();
            
        }catch(Exception e){
            System.debug('getCustDedupeBasedOnCICNumber '+ e.getMessage());
        }
    }
    
   @isTest
    public static void isFiCasesAvailableTest(){
        try{
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                opks1.OwnerId = UserInfo.getUserId();
                insert opks1;
        
                Applicant__c apks1 = new Applicant__c();
                apks1.Opportunity__c = opks1.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                insert apks1;
        
                 case cs2 = new case();
                 cs2.Loan_Application__c = opks1.Id;
                 cs2.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('FI').getRecordTypeId();
                 cs2.Subject='Approval Of Application Sourced By Off Roll Employee';
                 cs2.Status = 'Pending-Off Role Employee App';
                 cs2.Origin = 'Web';
                 cs2.Type = 'Problem';
                 cs2.Status = 'New';
                 cs2.Applicant__c = apks1.Id;
                 insert cs2; 
                  
                 Test.startTest();
                      Utilities.isFiCasesAvailable(opks1.Id,apks1.Id);
                      Utilities.isFiCasesAvailable('test','test');
                      Utilities.isFiCasesAvailable(null,null);
                 Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getIntegrationLogTest(){
        try{
            Opportunity opil1 = TestDataUtility.createTestOpportunity(false);
        if (Schema.sObjectType.Opportunity.isCreateable()){
            insert opil1;
        }
        Applicant__c apil1 = TestDataUtility.createTestApplicant(false);
        apil1.Opportunity__c = opil1.Id;
        if (Schema.sObjectType.Applicant__c.isCreateable()){
            insert apil1;
        }
        
        Integration_Log__c ilog2 = new Integration_Log__c();
        ilog2.Loan_Application__c = opil1.Id;
        ilog2.Encrypted_response__c = 'encryptedres';
        ilog2.Encrypted_request__c = 'encryptedsample';
        ilog2.RequestExt__c = 'reqres';
        ilog2.ResponseExt__c = 'ressample';
        ilog2.Original_request__c = 'req';
     //   ilog2.Original_response__c = '{"RequestId":"03102021204513966","ResponseData":{"Status":"Success","ResponseInfo":{"ApplicationId":22546137,"SolutionSetInstanceId":"cb894105-318c-4c0c-b5da-71b66366624b"},"Fields":{"Applicants":{"Applicant":{"ApplicantFirstName":"Karthi","ApplicantMiddleName":"","ApplicantLastName":"M","Services":{"Service":[{"Id":"","Name":"DocumentAuthentication","Operations":{"Operation":[{"Id":"","Name":"DocumentReport","Params":{"Param":[{"Name":"DocumentCheckId","Value":"ab579ec7-81d7-49ca-8fe7-f4764c87b957"},{"Name":"DocumentCheckId","Value":"ab579ec7-81d7-49ca-8fe7-f4764c87b957"}]},"Data":{"Response":{"RawResponse":{\"reports\":[{\"created_at\":\"2021-10-03T14:11:07Z\",\"documents\":[{\"id\":\"5f1fdef3-083a-4229-bb89-176c79fbb725\"}],\"href\":\"/v2/checks/ab579ec7-81d7-49ca-8fe7-f4764c87b957/reports/3c35eb2a-6759-44a2-ad4d-18155d8daeae\",\"id\":\"3c35eb2a-6759-44a2-ad4d-18155d8daeae\",\"name\":\"document\",\"properties\":{\"first_name\":\"KARTHI\",\"last_name\":\"M\",\"issuing_country\":\"IND\",\"document_numbers\":[{\"type\":\"document_number\",\"value\":\"BYOPK0288D\"}],\"document_type\":\"tax_id\",\"date_of_birth\":\"1988-03-27\"},\"result\":\"consider\",\"status\":\"complete\",\"sub_result\":\"caution\",\"variant\":\"standard\",\"breakdown\":{\"data_comparison\":{\"result\":null,\"breakdown\":{\"date_of_expiry\":{\"result\":null,\"properties\":{}},\"issuing_country\":{\"result\":null,\"properties\":{}},\"document_type\":{\"result\":null,\"properties\":{}},\"document_numbers\":{\"result\":null,\"properties\":{}},\"gender\":{\"result\":null,\"properties\":{}},\"date_of_birth\":{\"result\":null,\"properties\":{}},\"last_name\":{\"result\":null,\"properties\":{}},\"first_name\":{\"result\":null,\"properties\":{}}}},\"data_consistency\":{\"result\":null,\"breakdown\":{\"date_of_expiry\":{\"result\":null,\"properties\":{}},\"document_type\":{\"result\":null,\"properties\":{}},\"nationality\":{\"result\":null,\"properties\":{}},\"issuing_country\":{\"result\":null,\"properties\":{}},\"document_numbers\":{\"result\":null,\"properties\":{}},\"gender\":{\"result\":null,\"properties\":{}},\"date_of_birth\":{\"result\":null,\"properties\":{}},\"last_name\":{\"result\":null,\"properties\":{}},\"first_name\":{\"result\":null,\"properties\":{}}}},\"data_validation\":{\"result\":\"clear\",\"breakdown\":{\"document_expiration\":{\"result\":null,\"properties\":{}},\"gender\":{\"result\":null,\"properties\":{}},\"document_numbers\":{\"result\":\"clear\",\"properties\":{\"document_number\":\"clear\"}},\"expiry_date\":{\"result\":null,\"properties\":{}},\"date_of_birth\":{\"result\":\"clear\",\"properties\":{}},\"mrz\":{\"result\":null,\"properties\":{}}}},\"compromised_document\":{\"result\":\"clear\"},\"image_integrity\":{\"result\":\"consider\",\"breakdown\":{\"conclusive_document_quality\":{\"result\":\"consider\",\"properties\":{\"missing_back\":\"clear\",\"digital_document\":\"clear\",\"punctured_document\":\"clear\",\"corner_removed\":\"clear\",\"watermarks_digital_text_overlay\":\"clear\",\"abnormal_document_features\":\"clear\",\"obscured_security_features\":\"consider\",\"obscured_data_points\":\"clear\"}},\"colour_picture\":{\"result\":\"clear\",\"properties\":{}},\"supported_document\":{\"result\":\"clear\",\"properties\":{}},\"image_quality\":{\"result\":\"clear\",\"properties\":{}}}},\"age_validation\":{\"result\":\"clear\",\"breakdown\":{\"minimum_accepted_age\":{\"result\":\"clear\",\"properties\":{}}}},\"police_record\":{\"result\":null},\"visual_authenticity\":{\"result\":\"clear\",\"breakdown\":{\"other\":{\"result\":\"clear\",\"properties\":{}},\"digital_tampering\":{\"result\":null,\"properties\":{}},\"fonts\":{\"result\":null,\"properties\":{}},\"security_features\":{\"result\":null,\"properties\":{}},\"template\":{\"result\":null,\"properties\":{}},\"picture_face_integrity\":{\"result\":null,\"properties\":{}},\"face_detection\":{\"result\":\"clear\",\"properties\":{}},\"original_document_present\":{\"result\":\"clear\",\"properties\":{\"scan\":\"clear\",\"document_on_printed_paper\":\"clear\",\"screenshot\":\"clear\",\"photo_of_screen\":\"clear\"}}}}}}]}}},"Status":"Pass"}]},"Status":"Pass"}]},"ApplicantIdentifier":"c17f1c3d-00f4-4cd2-b28a-50b541ebd85e"}},"ApplicationData":{"Services":{"Service":{"Id":"","Name":"DocumentAuthentication","Skip":"N","Consent":"true","EnableSimulation":"False"}}},"Decision":"Pass","ApplicationId":"22546137"}}}';
        ilog2.Service_Name__c = 'Passport';
     //   ilog.targetRecordId__c = applicant.id+''+backDoc.id;
        insert ilog2;
            
        List<String> serviceNameList = new List<String>();
        serviceNameList.add(ilog2.Service_Name__c);
            
        Test.startTest();
            Utilities.getIntegrationLog(serviceNameList,opil1.Id);
        Test.stopTest();
            
        }catch(Exception e){
           // System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void deleteOpportunityTeamMemberRecordTest(){
        try{
            Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                insert opks1;
                
                Applicant__c apks1 = new Applicant__c();
                apks1.Opportunity__c = opks1.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                insert apks1;
                
                List<OpportunityTeamMember> optList = new List<OpportunityTeamMember>();
                OpportunityTeamMember optm1 = new OpportunityTeamMember();
                optm1.OpportunityId = opks1.Id;
                optm1.UserId = UserInfo.getUserId();
                optm1.TeamMemberRole = 'BE';
                insert optm1;
                optList.add(optm1);
            
                Test.startTest();
                      Utilities.deleteOpportunityTeamMemberRecord(optList);
                      Utilities.deleteOpportunityTeamMemberRecord(null);
                Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getSiteUrlTest(){
        try{
            Test.startTest();
                  Utilities.getSiteUrl();
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getDocumentInfoTest(){
        Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                insert opks1;
                
                Applicant__c apks1 = new Applicant__c();
                apks1.Opportunity__c = opks1.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                insert apks1;
        
                Id amlRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('AML Check').getRecordTypeId();
            
            Case case_s = new Case();
            case_s.RecordTypeId = amlRecordTypeId;
            case_s.Origin = 'Email';
            case_s.Subject = 'disableInitiateAML';
            case_s.Loan_Application__c = opks1.Id;
            case_s.Status = 'Pending with Credit Head';
          //  case_s.OwnerId = u.Id;
            insert case_s;
                
                 List<Documents__c> dcList = new List<Documents__c>();
                 Documents__c dfks1 = new Documents__c();
                 dfks1.Applicant__c = apks1.Id;
                 dfks1.Opportunity_Relation__c = opks1.Id;
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 dfks1.Document_Type__c = 'Aadhaar';
                 insert dfks1;
                 dcList.add(dfks1);
        
                 AML_Check__c amlCheck = new AML_Check__c();
            amlCheck.Matched_base__c = 'MatchBase';
            amlCheck.List_Name__c = 'amlList';
            amlCheck.Name__c = 'amlName';
            amlCheck.Name_Score__c = 5;
            amlCheck.ML_Id__c = '45678';
            amlCheck.Nationality__c = 'IND';
            amlCheck.Nationality_Score__c = 90;
            amlCheck.ML_Address__c = 'Mumbai';
            amlCheck.ML_City__c = 'Mumbai';
            amlCheck.ML_Date_Of_Birth__c = String.valueOf(System.today());
            amlCheck.ML_Description__c = 'Creating aml Data';
            amlCheck.CA_Decision__c = '';
            amlCheck.Remarks_Credit_Analyst__c = '';
            amlCheck.CH_Decision__c = '';
            amlCheck.Remarks_Credit_Head__c = '';
            amlCheck.CMU_Decision__c = '';
            amlCheck.Remarks_CMU__c = '';
            amlCheck.BE_CVO_Decision__c = '';
            amlCheck.Remarks_BE_CVO__c = '';
            amlCheck.Score__c = 90;
            amlCheck.Loan_Application__c = opks1.Id;
            amlCheck.Case__c = case_s.Id;
            insert amlCheck;
            
            List<TeleVerification__c> tvrList = new List<TeleVerification__c>();
            TeleVerification__c objTVR1 = new TeleVerification__c(); 
            objTVR1.Name = '_TVR';
            objTVR1.Case__c = case_s.Id;         
            objTVR1.RecordTypeId = Schema.SObjectType.TeleVerification__c.getRecordTypeInfosByName().get('Post-Sanction').getRecordTypeId();               
            objTVR1.Applicant__c = apks1.id;
            objTVR1.Loan_Application__c = opks1.Id;
            insert objTVR1;
            tvrList.add(objTVR1);
        
           Blob beforeblob1 = Blob.valueOf('Unit Test Attachment Body');

                 ContentVersion cvt1 = new ContentVersion();
                 cvt1.title = 'test content trigger';      
                 cvt1.PathOnClient ='test';           
                 cvt1.VersionData = beforeblob1;
                 cvt1.Document_Side_fileupload__c = 'Selfie';
                 insert cvt1;  
        
                 ContentVersion testContent1 = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cvt1.Id];

                 ContentDocumentLink contentlink1 = new ContentDocumentLink();
                 contentlink1.ShareType = 'V';
                 contentlink1.LinkedEntityId = dfks1.Id; 
                 contentlink1.ContentDocumentId = testContent1.ContentDocumentId;
                 contentlink1.Visibility = 'AllUsers'; 
                 insert contentlink1;
        
            Test.startTest();
                   Utilities.getDocumentInfo(opks1.Id,tvrList,dcList);
            Test.stopTest();
    }
    
     @isTest
    public static void getDocumentInfoTest1(){
        Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                insert opks1;
                
                Applicant__c apks1 = new Applicant__c();
                apks1.Opportunity__c = opks1.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                insert apks1;
        
                Id amlRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('AML Check').getRecordTypeId();
            
            Case case_s = new Case();
            case_s.RecordTypeId = amlRecordTypeId;
            case_s.Origin = 'Email';
            case_s.Subject = 'disableInitiateAML';
            case_s.Loan_Application__c = opks1.Id;
            case_s.Status = 'Pending with Credit Head';
          //  case_s.OwnerId = u.Id;
            insert case_s;
                
                 List<Documents__c> dcList = new List<Documents__c>();
                 Documents__c dfks1 = new Documents__c();
                 dfks1.Applicant__c = apks1.Id;
                 dfks1.Opportunity_Relation__c = opks1.Id;
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 dfks1.Document_Type__c = 'Aadhaar';
                 insert dfks1;
                 dcList.add(dfks1);
        
                 AML_Check__c amlCheck = new AML_Check__c();
            amlCheck.Matched_base__c = 'MatchBase';
            amlCheck.List_Name__c = 'amlList';
            amlCheck.Name__c = 'amlName';
            amlCheck.Name_Score__c = 5;
            amlCheck.ML_Id__c = '45678';
            amlCheck.Nationality__c = 'IND';
            amlCheck.Nationality_Score__c = 90;
            amlCheck.ML_Address__c = 'Mumbai';
            amlCheck.ML_City__c = 'Mumbai';
            amlCheck.ML_Date_Of_Birth__c = String.valueOf(System.today());
            amlCheck.ML_Description__c = 'Creating aml Data';
            amlCheck.CA_Decision__c = '';
            amlCheck.Remarks_Credit_Analyst__c = '';
            amlCheck.CH_Decision__c = '';
            amlCheck.Remarks_Credit_Head__c = '';
            amlCheck.CMU_Decision__c = '';
            amlCheck.Remarks_CMU__c = '';
            amlCheck.BE_CVO_Decision__c = '';
            amlCheck.Remarks_BE_CVO__c = '';
            amlCheck.Score__c = 90;
            amlCheck.Loan_Application__c = opks1.Id;
            amlCheck.Case__c = case_s.Id;
            insert amlCheck;
            
            List<TeleVerification__c> tvrList = new List<TeleVerification__c>();
            TeleVerification__c objTVR1 = new TeleVerification__c(); 
            objTVR1.Name = '_TVR';
            objTVR1.Case__c = case_s.Id;         
            objTVR1.RecordTypeId = Schema.SObjectType.TeleVerification__c.getRecordTypeInfosByName().get('Post-Sanction').getRecordTypeId();               
            objTVR1.Applicant__c = apks1.id;
            objTVR1.Loan_Application__c = opks1.Id;
            insert objTVR1;
            tvrList.add(objTVR1);
        
           Blob beforeblob1 = Blob.valueOf('Unit Test Attachment Body');

                 ContentVersion cvt1 = new ContentVersion();
                 cvt1.title = 'test content trigger';      
                 cvt1.PathOnClient ='test';           
                 cvt1.VersionData = beforeblob1;
                 cvt1.Document_Side_fileupload__c = 'Selfie';
                 insert cvt1;  
        
                 ContentVersion testContent1 = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cvt1.Id];

                 ContentDocumentLink contentlink1 = new ContentDocumentLink();
                 contentlink1.ShareType = 'V';
                 contentlink1.LinkedEntityId = amlCheck.Id; 
                 contentlink1.ContentDocumentId = testContent1.ContentDocumentId;
                 contentlink1.Visibility = 'AllUsers'; 
                 insert contentlink1;
        
            Test.startTest();
                   Utilities.getDocumentInfo(opks1.Id,tvrList,dcList);
            Test.stopTest();
    }
    
     @isTest
    public static void getDocumentInfoTest2(){
        Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                insert opks1;
                
                Applicant__c apks1 = new Applicant__c();
                apks1.Opportunity__c = opks1.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                insert apks1;
        
                Id amlRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('AML Check').getRecordTypeId();
            
            Case case_s = new Case();
            case_s.RecordTypeId = amlRecordTypeId;
            case_s.Origin = 'Email';
            case_s.Subject = 'disableInitiateAML';
            case_s.Loan_Application__c = opks1.Id;
            case_s.Status = 'Pending with Credit Head';
          //  case_s.OwnerId = u.Id;
            insert case_s;
                
                 List<Documents__c> dcList = new List<Documents__c>();
                 Documents__c dfks1 = new Documents__c();
                 dfks1.Applicant__c = apks1.Id;
                 dfks1.Opportunity_Relation__c = opks1.Id;
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 dfks1.Document_Type__c = 'Aadhaar';
                 insert dfks1;
                 dcList.add(dfks1);
        
                 AML_Check__c amlCheck = new AML_Check__c();
            amlCheck.Matched_base__c = 'MatchBase';
            amlCheck.List_Name__c = 'amlList';
            amlCheck.Name__c = 'amlName';
            amlCheck.Name_Score__c = 5;
            amlCheck.ML_Id__c = '45678';
            amlCheck.Nationality__c = 'IND';
            amlCheck.Nationality_Score__c = 90;
            amlCheck.ML_Address__c = 'Mumbai';
            amlCheck.ML_City__c = 'Mumbai';
            amlCheck.ML_Date_Of_Birth__c = String.valueOf(System.today());
            amlCheck.ML_Description__c = 'Creating aml Data';
            amlCheck.CA_Decision__c = '';
            amlCheck.Remarks_Credit_Analyst__c = '';
            amlCheck.CH_Decision__c = '';
            amlCheck.Remarks_Credit_Head__c = '';
            amlCheck.CMU_Decision__c = '';
            amlCheck.Remarks_CMU__c = '';
            amlCheck.BE_CVO_Decision__c = '';
            amlCheck.Remarks_BE_CVO__c = '';
            amlCheck.Score__c = 90;
            amlCheck.Loan_Application__c = opks1.Id;
            amlCheck.Case__c = case_s.Id;
            insert amlCheck;
            
            List<TeleVerification__c> tvrList = new List<TeleVerification__c>();
            TeleVerification__c objTVR1 = new TeleVerification__c(); 
            objTVR1.Name = '_TVR';
            objTVR1.Case__c = case_s.Id;         
            objTVR1.RecordTypeId = Schema.SObjectType.TeleVerification__c.getRecordTypeInfosByName().get('Post-Sanction').getRecordTypeId();               
            objTVR1.Applicant__c = apks1.id;
            objTVR1.Loan_Application__c = opks1.Id;
            insert objTVR1;
            tvrList.add(objTVR1);
        
           Blob beforeblob1 = Blob.valueOf('Unit Test Attachment Body');

                 ContentVersion cvt1 = new ContentVersion();
                 cvt1.title = 'test content trigger';      
                 cvt1.PathOnClient ='test';           
                 cvt1.VersionData = beforeblob1;
                 cvt1.Document_Side_fileupload__c = 'Selfie';
                 insert cvt1;  
        
                 ContentVersion testContent1 = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cvt1.Id];

                 ContentDocumentLink contentlink1 = new ContentDocumentLink();
                 contentlink1.ShareType = 'V';
                 contentlink1.LinkedEntityId = objTVR1.Id; 
                 contentlink1.ContentDocumentId = testContent1.ContentDocumentId;
                 contentlink1.Visibility = 'AllUsers'; 
                 insert contentlink1;
        
            Test.startTest();
                   Utilities.getDocumentInfo(opks1.Id,tvrList,dcList);
            Test.stopTest();
    }
    
    @isTest 
    public static void generateUniqueNumberAsyncTest(){
        Test.startTest();
        Integer uniqueNumber = Utilities.generateUniqueNumberAsync(5);
        Test.stopTest();
        system.assertEquals(5, string.valueOf(uniqueNumber).length());
    }
    
    @isTest 
    public static void generateUniqueNumberAsyncCalloutTest(){
        Test.startTest();
        Integer uniqueNumber = Utilities.generateUniqueNumberAsyncCallout(5);

        Test.stopTest();
        system.assertEquals(5, string.valueOf(uniqueNumber).length());
    }

    
    @isTest 
    public static void createCaseTeamMembertest(){
        Opportunity opks1 = new Opportunity();
        opks1.StageName = 'Qualification';
        opks1.CloseDate = Date.newInstance(2021, 1, 11);
        opks1.Name = 'testone';
        opks1.OwnerId = UserInfo.getUserId();
        insert opks1;
        
        Applicant__c apks1 = new Applicant__c();
        apks1.Opportunity__c = opks1.Id;
        apks1.Contact_number__c = '9743514830';
        apks1.Applicant_Type__c = 'Borrower';
        insert apks1;
        
        case cs2 = new case();
        cs2.Loan_Application__c = opks1.Id;
        cs2.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('FI').getRecordTypeId();
        cs2.Subject='Approval Of Application Sourced By Off Roll Employee';
        cs2.Status = 'Pending-Off Role Employee App';
        cs2.Origin = 'Web';
        cs2.Type = 'Problem';
        cs2.Status = 'New';
        cs2.Applicant__c = apks1.Id;
        insert cs2; 
        
        Test.startTest();
        Boolean res = Utilities.createCaseTeamMember(cs2.Id);
        Test.stopTest();
        system.assertEquals(true, res);
    }
    
    @isTest 
    public static void deleteCaseTeamMembertest(){
        Opportunity opks1 = new Opportunity();
        opks1.StageName = 'Qualification';
        opks1.CloseDate = Date.newInstance(2021, 1, 11);
        opks1.Name = 'testone';
        opks1.OwnerId = UserInfo.getUserId();
        insert opks1;
        
        Applicant__c apks1 = new Applicant__c();
        apks1.Opportunity__c = opks1.Id;
        apks1.Contact_number__c = '9743514830';
        apks1.Applicant_Type__c = 'Borrower';
        insert apks1;
        
        case cs2 = new case();
        cs2.Loan_Application__c = opks1.Id;
        cs2.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('CMU Request').getRecordTypeId();
        cs2.Subject='Approval Of Application Sourced By Off Roll Employee';
        cs2.Status = 'Pending-Off Role Employee App';
        cs2.Origin = 'Web';
        cs2.Type = 'Problem';
        cs2.Status = 'New';
        cs2.Applicant__c = apks1.Id;
        insert cs2; 
        Utilities.createCaseTeamMember(cs2.Id);
        
        Test.startTest();
        Boolean res = Utilities.deleteCaseTeamMember( opks1.Id);
        Test.stopTest();
        system.assertEquals(true, res);
    }
    
    @isTest 
    public static void manufacturingDateAndYearDecoderTest(){
        Opportunity opks1 = new Opportunity();
        opks1.StageName = 'Qualification';
        opks1.CloseDate = Date.newInstance(2021, 1, 11);
        opks1.Name = 'testone';
        opks1.OwnerId = UserInfo.getUserId();
        insert opks1;
        Test.startTest();
        String manufactureDateESCORTS = Utilities.manufacturingDateAndYearDecoder(opks1.Id,'ESCORTS','912873ighas','');
        String manufactureDateSONALIKA = Utilities.manufacturingDateAndYearDecoder(opks1.Id,'SONALIKA','912873ighas','');
        String manufactureDateEICHER = Utilities.manufacturingDateAndYearDecoder(opks1.Id,'EICHER','912873ighas','');
        String manufactureDateSWARAJ = Utilities.manufacturingDateAndYearDecoder(opks1.Id,'SWARAJ','912873ighas','SWARAJ');

        Test.stopTest();
    }
    
    @isTest 
    public static void getMakeListTest(){
        
        Product2 parentpd = TestDataUtility.createTestProduct2(false);
        parentpd.Make_Code__c = 'xz';
        parentpd.Name='TRACTORS AND FARM EQUIPMENT';
        insert parentpd;
        
        Product2 pd = TestDataUtility.createTestProduct2(false);
        pd.Parent_Product__c = parentpd.Id;
        pd.External_Reference_Id__c = '58568569';
        pd.Name = 'PASSENGER VEHICLES1';
        pd.Type__c = 'Make';
        pd.Make_Code__c = 'xz';
        pd.IsActive = true;
        insert pd;
        Test.startTest();
        List<Utilities.OptionsWrapper> OptionsWrapper = Utilities.getMakeList();
        Test.stopTest();
    }
    
    @isTest 
    public static void getTalukaByDistrictAndStateTest(){
        Geo_State_Masters__c state = new Geo_State_Masters__c();
        state.Name = 'State Name';
        state.Pincode_Starting_Max__c = 66;
        state.Pincode__c = 53;
        state.State_Code__c = '33';
        insert state;
        
        District_Master__c district = new District_Master__c();
        district.Name = 'district Name';
        district.Geo_State_Master__c = state.id;
        district.District_Code__c = 23;
        insert district;
        
        Taluka_Master__c taluqa = new Taluka_Master__c();
        taluqa.Name = 'Test';
        taluqa.Per_Acre_Cost__c = 100;
        taluqa.State__c = state.id;
        taluqa.District__c = district.id;
        insert taluqa;
        
        Test.startTest();
        List<Taluka_Master__c> talukaMasterList = Utilities.getTalukaByDistrictAndState(state.id);
        Test.stopTest();
        system.assertEquals('Test', talukaMasterList[0].Name);
    }
    @isTest
    public static void createContentDocumentDownloadFromApexTest(){
        try{
            Opportunity opgr1 = new Opportunity();       
            opgr1.StageName = 'Qualification';
            opgr1.CloseDate = Date.newInstance(2021, 1, 11);
            opgr1.Name = 'testone';
            insert opgr1;
            
            Blob b1 =  Blob.valueOf('This is version data');
            
            ContentVersion cv1 = new ContentVersion();
            cv1.Title = 'Aadhar';
            cv1.VersionData = b1;
            cv1.IsMajorVersion = true;
            cv1.PathOnClient = 'test';
            insert cv1;
            
            Id conDocId1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv1.Id].ContentDocumentId;
            Opportunity opgr2 = new Opportunity();       
            opgr2.StageName = 'Qualification';
            opgr2.CloseDate = Date.newInstance(2021, 1, 11);
            opgr2.Name = 'testone';
            insert opgr2;
            
            ContentDocumentLink cdl1 = New ContentDocumentLink();
            cdl1.LinkedEntityId = opgr1.Id;
            cdl1.ContentDocumentId = conDocId1;
            cdl1.shareType = 'V';
            insert cdl1;
            
            Test.startTest();
            String conDocId=  Utilities.createContentDocumentDownloadFromApex(opgr1.Id,cv1.Title,b1,cv1.PathOnClient,opgr2.Id);
            Test.stopTest();
            List<ContentDocument> conDoc = [SELECT Id FROM ContentDocument WHERE Id =:conDocId];
            System.assertEquals(false, conDoc.isEmpty());
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest 
    public static void getRelatedModelListTest(){
        Manufacturer__c mf = new Manufacturer__c();
        mf.Manufacturer_code__c = 'xz';
        insert mf;
        
        Product2 parentpd = TestDataUtility.createTestProduct2(false);
        parentpd.Manufacturer__c = mf.Id;
        parentpd.Make_Code__c = 'xz';
        insert parentpd;
        
        Segment__c seg = new Segment__c();
        seg.segment_code__c = 'TRACFEQ';
        seg.Name = 'Test';
        insert seg;
        
        Product2 pd = TestDataUtility.createTestProduct2(false);
        pd.Parent_Product__c = parentpd.Id;
        pd.Segment__c =seg.Id;
        pd.External_Reference_Id__c = '58568569';
        pd.Name = 'PASSENGER VEHICLES1';
        pd.Type__c = 'Model';
        pd.Make_Code__c = 'xz';
        pd.IsActive = true;
        insert pd;
        Test.startTest();
        List<Utilities.OptionsWrapper> OptionsWrapperTRACTOR = Utilities.getRelatedModelList('xz','TRACTOR');
        List<Utilities.OptionsWrapper> OptionsWrapperHARVESTER = Utilities.getRelatedModelList('xz','HARVESTER');
        List<Utilities.OptionsWrapper> OptionsWrapperElse = Utilities.getRelatedModelList('xz','Test');

        Test.stopTest();
    }
    
    @isTest 
    public static void getRelatedVariantListTest(){
        
        Opportunity opgr2 = new Opportunity();       
        opgr2.StageName = 'Qualification';
        opgr2.CloseDate = Date.newInstance(2021, 1, 11);
        opgr2.Name = 'testone';
        opgr2.Agent_BL_code__c='A2';
        insert opgr2;
        
        Manufacturer__c mf = new Manufacturer__c();
        mf.Manufacturer_code__c = 'xz';
        insert mf;
        
        TBM_Product_Variant_dt__c tbm= new TBM_Product_Variant_dt__c();
        tbm.Product_Variant_Code__c='test1';
        tbm.State_Code__c='S';
        insert tbm;
        
        TBM_Business_Location_Dt__c  businessLocationList =new TBM_Business_Location_Dt__c();
       ///   [select Id,State_Code__c,Product__c,Bl_Code__c from TBM_Business_Location_Dt__c where Bl_Code__c=:blcode AND Product__c=:productCode]);
        businessLocationList.State_Code__c='S';
        businessLocationList.Product__c='T';
        businessLocationList.Bl_Code__c='A2';
        businessLocationList.BL_Name__c='test';
        insert businessLocationList;
        
        Product2 parentpd = TestDataUtility.createTestProduct2(false);
        parentpd.Manufacturer__c = mf.Id;
        parentpd.Make_Code__c = 'xz';
        insert parentpd;
        
        Segment__c seg = new Segment__c();
        seg.segment_code__c = 'TRACFEQ';
        seg.Name = 'Test';
        insert seg;
        
        Product2 pd = TestDataUtility.createTestProduct2(false);
        pd.Parent_Product__c = parentpd.Id;
        pd.Segment__c =seg.Id;
        pd.External_Reference_Id__c = '58568569';
        pd.Name = 'PASSENGER VEHICLES1';
        pd.Type__c = 'Variant';
        pd.Make_Code__c = 'xz';
        pd.IsActive = true;
        insert pd;
        
        Test.startTest();
        List<Product2> prodList = Utilities.getRelatedVariantList('xz',opgr2.Id);
        Test.stopTest();
    }
        
    @isTest 
    public static void getDealerSubDealerDetailsTest(){
        
        Opportunity opgr2 = new Opportunity();       
        opgr2.StageName = 'Qualification';
        opgr2.CloseDate = Date.newInstance(2021, 1, 11);
        opgr2.Name = 'testone';
        opgr2.Vehicle_Type__c='New';
        opgr2.Agent_BL_code__c='A2';
        insert opgr2;
        
        Manufacturer__c mf = new Manufacturer__c();
        mf.Manufacturer_code__c = 'xz';
        insert mf;
        
        TBM_Product_Variant_dt__c tbm= new TBM_Product_Variant_dt__c();
        tbm.Product_Variant_Code__c='test1';
        tbm.State_Code__c='S';
        insert tbm;
        
        TBM_Business_Location_Dt__c  businessLocationList =new TBM_Business_Location_Dt__c();
       ///   [select Id,State_Code__c,Product__c,Bl_Code__c from TBM_Business_Location_Dt__c where Bl_Code__c=:blcode AND Product__c=:productCode]);
        businessLocationList.State_Code__c='S';
        businessLocationList.Product__c='T';
        businessLocationList.Bl_Code__c='A2';
        businessLocationList.BL_Name__c='test';
        insert businessLocationList;
        
        Product2 parentpd = TestDataUtility.createTestProduct2(false);
        parentpd.Manufacturer__c = mf.Id;
        parentpd.Make_Code__c = 'xz';
        insert parentpd;
        
        Segment__c seg = new Segment__c();
        seg.segment_code__c = 'TRACFEQ';
        seg.Name = 'Test';
        insert seg;
        
        Product2 pd = TestDataUtility.createTestProduct2(false);
        pd.Parent_Product__c = parentpd.Id;
        pd.Segment__c =seg.Id;
        pd.External_Reference_Id__c = '58568569';
        pd.Name = 'Test';
        pd.Type__c = 'Model';
        pd.Make_Code__c = 'xz';
        pd.IsActive = true;
        insert pd;
        
        Test.startTest();
        String res = Utilities.getDealerSubDealerDetails('Test','A2',opgr2.Id,'UPD');
        opgr2.Vehicle_Type__c='Used';
        update opgr2;
        Utilities.getDealerSubDealerDetails('Test','A2',opgr2.Id,'UPD');
        Test.stopTest();
    }
  
    @isTest 
    public static void getFIDetailsTest(){
        Opportunity opgr1 = new Opportunity();       
        opgr1.StageName = 'Qualification';
        opgr1.CloseDate = Date.newInstance(2021, 1, 11);
        opgr1.Name = 'testone';
        insert opgr1;
        
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c = opgr1.Id;
        insert applicantObj;
        
        case cs2 = new case();
        cs2.Loan_Application__c = opgr1.Id;
        cs2.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('FI').getRecordTypeId();
        cs2.Subject='Approval Of Application Sourced By Off Roll Employee';
        cs2.Status = 'Pending-Off Role Employee App';
        cs2.Origin = 'Web';
        cs2.Type = 'Problem';
        cs2.Status = 'New';
        cs2.Applicant__c = applicantObj.Id;
        insert cs2; 
        Test.startTest();
        List<Case> CaseList = Utilities.getFIDetails(applicantObj.Id);
        Test.stopTest();
    }
    
        
    @isTest 
    public static void getAssetCategoryTest(){
        
        Opportunity opgr2 = new Opportunity();       
        opgr2.StageName = 'Qualification';
        opgr2.CloseDate = Date.newInstance(2021, 1, 11);
        opgr2.Name = 'testone';
        opgr2.Agent_BL_code__c='A2';
        insert opgr2;
        
        Manufacturer__c mf = new Manufacturer__c();
        mf.Manufacturer_code__c = 'xz';
        insert mf;
        
        TBM_Product_Variant_dt__c tbm= new TBM_Product_Variant_dt__c();
        tbm.Product_Variant_Code__c='test1';
        tbm.State_Code__c='S';
        insert tbm;
        
        TBM_Business_Location_Dt__c  businessLocationList =new TBM_Business_Location_Dt__c();
       ///   [select Id,State_Code__c,Product__c,Bl_Code__c from TBM_Business_Location_Dt__c where Bl_Code__c=:blcode AND Product__c=:productCode]);
        businessLocationList.State_Code__c='S';
        businessLocationList.Product__c='T';
        businessLocationList.Bl_Code__c='A2';
        businessLocationList.BL_Name__c='test';
        insert businessLocationList;
        
        Product2 parentpd = TestDataUtility.createTestProduct2(false);
        parentpd.Manufacturer__c = mf.Id;
        parentpd.Make_Code__c = 'xz';
        insert parentpd;
        
        Segment__c seg = new Segment__c();
        seg.segment_code__c = 'TRACFEQ';
        seg.Name = 'Test';
        insert seg;
        
        Product2 pd = TestDataUtility.createTestProduct2(false);
        pd.Parent_Product__c = parentpd.Id;
        pd.Segment__c =seg.Id;
        pd.External_Reference_Id__c = '58568569';
        pd.Name = 'PASSENGER VEHICLES1';
        pd.Type__c = 'Variant';
        pd.Make_Code__c = 'xz';
        pd.IsActive = true;
        insert pd;
        
        Vehicle_Detail__c veh = new Vehicle_Detail__c();
        veh.Make__c = 'Make 1';
        veh.Model__c = 'Model 1';
        veh.Loan_Application__c = opgr2.id;
        veh.Variant_Code__c= 'test1';
        insert veh;
        
        Test.startTest();
        String res = Utilities.getAssetCategory(opgr2,veh);
        Test.stopTest();
    }

    @isTest 
    public static void getRetryCountNew(){
        
        Opportunity opgr2 = new Opportunity();       
        opgr2.StageName = 'Qualification';
        opgr2.CloseDate = Date.newInstance(2021, 1, 11);
        opgr2.Name = 'testone';
        opgr2.Agent_BL_code__c='A2';
        insert opgr2;
        
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c = opgr2.Id;
        insert applicantObj;
        
        Retry_Count__c retryCount = new Retry_Count__c();
        retryCount.Service_Name__c = 'RC Limit Check';
        retryCount.Count__c = 1;
        retryCount.Loan_Application_Id__c = opgr2.Id;
        retryCount.Applicant__c = applicantObj.Id;
        retryCount.Applicant_Type__c ='Borrower';
        Insert retryCount;
        List<Retry_count__c> retryCountCheckList = [select id from Retry_Count__c where Loan_Application_Id__c = :opgr2.id and Applicant_Type__c = 'Borrower' AND Applicant__c =: applicantObj.Id WITH SECURITY_ENFORCED];
        System.debug('retryCountCheckList: :'+retryCountCheckList);
        Test.startTest();
        
        Decimal res = Utilities.getRetryCountNew(opgr2.id,'Borrower','Count__c','Aadhar_OCR_Attempts', applicantObj.Id);
        Utilities.getRetryCountNew(opgr2.id,'Co-borrower','Count__c','Aadhar_OCR_Attempts', applicantObj.Id);

        Test.stopTest();
    }
    @isTest
    public static void calculateMedianPayoutsTest(){
        try{
            Opportunity opft1 = new Opportunity();
            opft1.StageName = 'Credit Processing';
            opft1.CloseDate = Date.newInstance(2021, 1, 11);
            opft1.Name = 'testone';
            opft1.Vehicle_Type__c = 'New';
            opft1.Product_Type__c = 'Two Wheeler';
            opft1.RTO_Road_Tax_New__c = 1000.00;
            opft1.Other_charges__c = 500.00;
            opft1.X1st_yr_Insurance_Premium__c = 200.00;
            opft1.View_Application_Sub_Stages__c ='Final Terms';
            opft1.Required_Tenure__c = 8.0;
            opft1.Sub_Stage__c ='Final Terms';
            opft1.Basic_Price__c = 1000.00;
            opft1.GST_Amount__c=500.00;
            opft1.Discount_on_Basic_Price__c=10;
            opft1.Funding_on_Ex_Showroom__c = true;
            opft1.Funding_on_Ex_Showroom__c = true;
            opft1.X1st_yr_Insurance_Premium__c = 700.00;
            opft1.Payment_Request_Generation_Date__c = System.today();
            
            insert opft1;
            
            Applicant__c apft1 = new Applicant__c();
            apft1.Opportunity__c = opft1.Id;
            apft1.Contact_number__c = '9743514830';
            apft1.Applicant_Type__c = 'Borrower';
            apft1.In_Active_Applicant__c = false;
            insert apft1;
            
            Final_Term__c ftd1 = new Final_Term__c();
            ftd1.CRM_IRR__c = 120;
            ftd1.Loan_Application__c = opft1.Id;
            ftd1.Holiday_period__c='30';
            ftd1.EMI_Amount__c= 10000;
            ftd1.Loan_Amount__c = '50000.00';
            ftd1.Service_charges__c = '1000.00';
            ftd1.Documentation_charges__c = '5000';
            ftd1.Dlr_Exp_Reimburse_Amt__c = '10000';
            ftd1.Rreferrer_Incentive__c = '100000';
            ftd1.Dlr_Exp_Reimbursement_percent__c = '20000';
            ftd1.Mfr_Exp_Reimburse_percent__c = '30000';
            insert ftd1;
            
            Test.startTest();
            Map<String,Decimal> resultMap = Utilities.calculateMedianPayouts(opft1.Id);
            Test.stopTest();
            System.assert(resultMap.size()!=0);
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    public static void checkOwnerTest(){
        try{
            Opportunity opft1 = new Opportunity();
            opft1.StageName = 'Credit Processing';
            opft1.CloseDate = Date.newInstance(2021, 1, 11);
            opft1.Name = 'testone';
            opft1.Vehicle_Type__c = 'New';
            opft1.Product_Type__c = 'Tractor';
            opft1.RTO_Road_Tax_New__c = 1000.00;
            opft1.Other_charges__c = 500.00;
            opft1.X1st_yr_Insurance_Premium__c = 200.00;
            opft1.View_Application_Sub_Stages__c ='Final Terms';
            opft1.Required_Tenure__c = 8.0;
            opft1.Sub_Stage__c ='Final Terms';
            opft1.Basic_Price__c = 1000.00;
            opft1.GST_Amount__c=500.00;
            opft1.Discount_on_Basic_Price__c=10;
            opft1.Funding_on_Ex_Showroom__c = true;
            opft1.Funding_on_Ex_Showroom__c = true;
            opft1.X1st_yr_Insurance_Premium__c = 700.00;
            opft1.Payment_Request_Generation_Date__c = System.today();
            
            insert opft1;
            Utilities.checkOwner(opft1.Id);
            Utilities.checkOwner(null);
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    public static void uploadTractorDocumentTest(){
        try{
             Opportunity opft1 = new Opportunity();
            opft1.StageName = 'Credit Processing';
            opft1.CloseDate = Date.newInstance(2021, 1, 11);
            opft1.Name = 'testone';
            opft1.Vehicle_Type__c = 'New';
            opft1.Product_Type__c = 'Two Wheeler';
            opft1.RTO_Road_Tax_New__c = 1000.00;
            
            insert opft1;
            
            Applicant__c apft1 = new Applicant__c();
            apft1.Opportunity__c = opft1.Id;
            apft1.Contact_number__c = '9743514830';
            apft1.Applicant_Type__c = 'Borrower';
            apft1.In_Active_Applicant__c = false;
            insert apft1;
            Utilities.DocumentWrapper docObj= new Utilities.DocumentWrapper();
            docObj.AppId = apft1.Id;
            docObj.OppId = opft1.Id;
            
            Utilities.uploadTractorDocument(docObj);
            Utilities.uploadTractorDocument(null);
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    public static void getProfileCodeTest(){
        try{
            Profile_Master__c pm1 = new Profile_Master__c();
            pm1.Category__c = 'SAL';
            pm1.Code__c = '115';
            pm1.OwnerId = UserInfo.getUserId();
            pm1.Name = 'test';
            pm1.Sub_Bucket_Desc__c = 'SERVICE ORIENTED';
            insert pm1;
            
            Utilities.getProfileCode('test');
            Utilities.getProfileCode(null);
            
            
            Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive']; 
        User u = new User(Alias = 'IBLBE', Email='NANDLAL1@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='NANDLAL', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Kolkata', UserName='Utilities@testorg.com.test',EmployeeNumber = '1000', MobilePhone ='7217470708', Maker_Id__c = '1001');
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
            Utilities.updateAccountTeamMembers(new List<AccountTeamMember>{atm});
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
        
}