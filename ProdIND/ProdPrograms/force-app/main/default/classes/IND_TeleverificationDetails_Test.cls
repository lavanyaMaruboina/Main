@isTest
public class IND_TeleverificationDetails_Test {
    
    @TestSetup
    public static void createTestData()
    {
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL CVO'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod123@indusbank.com.uat',MobilePhone = '9089078967');
        insert u;
        System.runAs(u) 
        {
            
            Account acc = new Account(Name='TestAcc1');
            insert acc;
            
            Opportunity opp = TestDataUtility.createTestLoanApplication(true);        
            opp.Sub_Stage__c = System.Label.Field_Investigation;
            opp.Is_Mobile_Journey_Completed__c = true;
            opp.Vehicle_Type__c = System.Label.used;
            opp.Product_Type__c = System.Label.TwoWheeler;
            opp.Sanction_Status__c = System.Label.nonStp;
            
            update opp;
            
            AccountTeamMember testTeamMember = new AccountTeamMember(
                UserId = u.Id,
                AccountId = acc.Id,
                TeamMemberRole = 'CVO'
            );
            insert testTeamMember;
            
            Applicant__c applicant = TestDataUtility.createTestApplicantService(true,opp);
            applicant.In_Active_Applicant__c = false;
            applicant.Would_you_like_to_open_a_bank_account__c = true;
            applicant.Who_will_repay_the_loan__c = 'Borrower';
            applicant.Applicant_Type__c = 'Borrower';
            update applicant;
            Applicant__c coApplicant = TestDataUtility.createTestApplicantForGatingScreeningCoborrower(false);
            coApplicant.In_Active_Applicant__c = false;
            coApplicant.Would_you_like_to_open_a_bank_account__c = true;
            coApplicant.Opportunity__c = opp.Id;
            Insert coApplicant;
            
            Documents__c document = new Documents__c( Name= ' Document',
                                                     Applicant__c =applicant.id,
                                                     DocAuth_Passed__c = true,
                                                     Selfie_report_Pass__c = true,
                                                     Golden_Source_Pass__c = true,
                                                     Proof_of_Identity_POI__c = false,
                                                     Name_Mismatch_Percentage__c = 00,
                                                     Is_Photocopy__c=true,
                                                     Opportunity_Relation__c=opp.Id,
                                                     Document_Type__c='RC Document',
                                                     KYC_name__c = 'Nidhi', 
                                                     KYC_Address_Line_1__c = 'NAGAR',
                                                     KYC_Address_Line_2__c = 'Nagpur', 
                                                     KYC_Pin_Code__c = '440037', 
                                                     KYC_City__c = 'Mumbai', 
                                                     KYC_District__c = 'MAHARASHTRA',
                                                     KYC_State__c = 'MAHARASHTRA',
                                                     Current_Residential_Address_Proof__c = true,
                                                     Permanent_Residential_Address_Proof__c = true,
                                                     Addresss_Type__c = 'Current Residential Address',
                                                     Name_Mismatch_Pass__c = true );
            
            insert document;
            
            Income_Details__c income = TestDataUtility.createTestIncomeDetails(true,applicant);
            
            CASA_Bank_Form__c casa = TestDataUtility.createTestCASADetails(true,opp,applicant);
            
            Id caseFIRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('FI').getRecordTypeId();
            
            Case cse = TestDataUtility.createTestCase(true,opp,applicant);
            cse.RecordTypeId = caseFIRecordTypeId;
            update cse;
            
            // Finacle_City__c finacle = TestDataUtility.createFinacle(true);
            Finacle_City__c finacle = new Finacle_City__c();
            finacle.Name = 'Alabama';
            finacle.City_Code__c = 'DELHI';
            insert finacle;
            
            TeleVerification__c tele = TestDataUtility.createTestTeleverificationDetails(true,opp,applicant,cse,finacle,income);
            Field_Investigation__c fi = TestDataUtility.createTestFieldInvestigation(true,cse);       
            
            Geo_State_Masters__c geoStateMaster = new Geo_State_Masters__c();
            geoStateMaster.Pincode__c = 53;
            geoStateMaster.Pincode_Starting_Max__c = 11;
            geoStateMaster.State_Code__c = '33';
            insert geoStateMaster;
            
            City_State_Master__c cityStateMaster = new City_State_Master__c();
            cityStateMaster.Name= 'Aadityana';
            cityStateMaster.City_Code__c = '5';
            cityStateMaster.Carwale_ID__c=118 ;
            cityStateMaster.State__c = geoStateMaster.Id;
            insert cityStateMaster;
            
            Final_Term__c finalTerm = new Final_Term__c();
            finalTerm.Loan_Application__c = opp.Id;
            finalTerm.Loan_amount__c = '1200';
            insert finalTerm;
            
            Vehicle_Detail__c vehicleDetail = new Vehicle_Detail__c();
            vehicleDetail.Loan_Application__c = opp.Id;
            vehicleDetail.Make__c = 'test';
            vehicleDetail.Model__c = 'test-M';
            insert vehicleDetail;
        }
    }
    
    @isTest
    public static void createRealatedRecordsTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try
            {
                Opportunity opp = [Select Id from Opportunity LIMIT 1];                
                Test.startTest();
                IND_TeleverificationDetails.createRealatedRecords(opp.Id,'Pre-TVR');
                Test.stopTest(); 
            }
            catch(Exception e)
            {
                System.assertEquals('Script-thrown exception', e.getMessage());
            }            
        }
    }
    
    @isTest
    public static void createRealatedRecordsTest2(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try
            {
                //Opportunity opp = [Select Id from Opportunity LIMIT 1];   
                
                Opportunity opp = new Opportunity(); 
                opp.Name = 'Test- P';
                opp.Sub_Stage__c = System.Label.Field_Investigation;
                opp.Is_Mobile_Journey_Completed__c = true;
                opp.Vehicle_Type__c = System.Label.used;
                opp.Product_Type__c = 'Passenger Vehicles';
                opp.StageName = 'Qulification';
                opp.CloseDate = System.today();
                opp.Sanction_Status__c = System.Label.nonStp;
                
                insert opp;
                
                Test.startTest();
                IND_TeleverificationDetails.createRealatedRecords(opp.Id,'Pre-TVR');
                Test.stopTest(); 
            }
            catch(Exception e)
            {
                System.assertEquals('Script-thrown exception', e.getMessage());
            }            
        }
    }
    
    @isTest
    public static void createRealatedRecordsTest3(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try
            {
                //Opportunity opp = [Select Id from Opportunity LIMIT 1];   
                
                Account acc = new Account(Name='TestAcc');
                insert acc;
                
                Opportunity opp = new Opportunity();  
                opp.Name = 'Test- P';
                opp.Sub_Stage__c = System.Label.Field_Investigation;
                opp.Is_Mobile_Journey_Completed__c = true;
                opp.Vehicle_Type__c = System.Label.used;
                opp.Product_Type__c = 'Tractor';
                opp.StageName = 'Qulification';
                opp.CloseDate = System.today();
                opp.Sanction_Status__c = System.Label.nonStp;
                
                insert opp;
                
                Applicant__c applicant = new Applicant__c();
                applicant.Opportunity__c = opp.Id;
                applicant.In_Active_Applicant__c = false;
                applicant.Would_you_like_to_open_a_bank_account__c = true;
                applicant.Who_will_repay_the_loan__c = 'Co-borrower';
                applicant.Applicant_Type__c = 'Co-borrower';
                insert applicant;
                
                AccountTeamMember testTeamMember = new AccountTeamMember(
                    UserId = u.Id,
                    AccountId = acc.Id,
                    TeamMemberRole = 'CVO'
                );
            insert testTeamMember;
                Test.startTest();
                IND_TeleverificationDetails.createRealatedRecords(opp.Id,'Pre-TVR');
                Test.stopTest(); 
            }
            catch(Exception e)
            {
                System.assertEquals('Script-thrown exception', e.getMessage());
            }            
        }
    }
    
    @isTest
    public static void getTVRRecordTest(){
        
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [Select Id from Opportunity LIMIT 1];
            System.debug(opp);
            Applicant__c applicant = [ Select Id,Opportunity__c from  Applicant__c where Opportunity__c=:opp.Id LIMIT 1];
            applicant.In_Active_Applicant__c = false;
            update applicant;
            TeleVerification__c tele = [ Select Id,Loan_Application__c,Applicant__c from TeleVerification__c];
            Case objCase = [Select Id,Loan_Application__c,Applicant__c from Case LIMIT 1];
            Field_Investigation__c fiRecord = [Select Id, Landmark__c,Case__r.Type,Case__r.Applicant__c, Case__r.Applicant__r.Applicant_Type__c,Case__r.RecordTypeId,Address_Verified_with_KYC__c ,recordTypeId, recordType.Name, Customer_house_same_as_in_application__c  
                                               from Field_Investigation__c where Case__c =: objCase.Id];
            Income_Details__c incomDet = [Select id from Income_Details__c limit 1];
            Test.startTest();
            List<IND_TeleverificationDetails.wrpTVR> resultWrapper = IND_TeleverificationDetails.getTVRRecord(objCase.Id);
            System.assertNotEquals(null, resultWrapper);
            Test.stopTest();     
        }
        
    }
    @isTest
    public static void getTVRRecordTest2(){
        
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [Select Id from Opportunity LIMIT 1];
            System.debug(opp);
            Applicant__c applicant = [ Select Id,Opportunity__c from  Applicant__c where Opportunity__c=:opp.Id LIMIT 1];
            applicant.In_Active_Applicant__c = false;
            update applicant;
            TeleVerification__c tele = [ Select Id,Loan_Application__c,Applicant__c from TeleVerification__c];
            Case objCase = [Select Id,Loan_Application__c,Applicant__c from Case LIMIT 1];
            Field_Investigation__c fiRecord = [Select Id, Landmark__c,Case__r.Type,Case__r.Applicant__c, Case__r.Applicant__r.Applicant_Type__c,Case__r.RecordTypeId,Address_Verified_with_KYC__c ,recordTypeId, recordType.Name, Customer_house_same_as_in_application__c  
                                               from Field_Investigation__c where Case__c =: objCase.Id];
            
            CASA_Bank_Form__c casa = [Select id,Applicant__c from CASA_Bank_Form__c where Applicant__c =: applicant.Id];
            Test.startTest();
            List<IND_TeleverificationDetails.wrpTVR> resultWrapper = IND_TeleverificationDetails.getTVRRecord(objCase.Id);
            System.assertNotEquals(null, resultWrapper);
            Test.stopTest();     
        }
        
    }
    
    @isTest
    public static void getTVRRecordTest3(){
        
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [Select Id from Opportunity LIMIT 1];
            
            Applicant__c applicant = [ Select Id,Opportunity__c from  Applicant__c where Opportunity__c=:opp.Id LIMIT 1];
            applicant.In_Active_Applicant__c = false;
            applicant.Applicant_Type__c = 'Borrower';
            update applicant;
            TeleVerification__c tele = [ Select Id,Loan_Application__c,Applicant__c from TeleVerification__c];
            Case objCase = [Select Id,Loan_Application__c,Applicant__c from Case LIMIT 1];
            objCase.Type = 'Current Residence FI';
            update objCase;
            Field_Investigation__c fiRecord = [Select Id, Landmark__c,Case__r.Type,Case__r.Applicant__c, Case__r.Applicant__r.Applicant_Type__c,Case__r.RecordTypeId,Address_Verified_with_KYC__c ,recordTypeId, recordType.Name, Customer_house_same_as_in_application__c  
                                               from Field_Investigation__c where Case__c =: objCase.Id];
            
            CASA_Bank_Form__c casa = [Select id,Applicant__c from CASA_Bank_Form__c where Applicant__c =: applicant.Id];
            Test.startTest();
            List<IND_TeleverificationDetails.wrpTVR> resultWrapper = IND_TeleverificationDetails.getTVRRecord(objCase.Id);
            System.assertNotEquals(null, resultWrapper);
            Test.stopTest();     
        }
        
    }
    
    @isTest
    public static void getTVRRecordTest4(){
        
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [Select Id from Opportunity LIMIT 1];
            
            Applicant__c applicant = [ Select Id,Opportunity__c from  Applicant__c where Opportunity__c=:opp.Id LIMIT 1];
            applicant.In_Active_Applicant__c = false;
            applicant.Applicant_Type__c = 'Co-borrower';
            update applicant;
            TeleVerification__c tele = [ Select Id,Loan_Application__c,Applicant__c from TeleVerification__c];
            Case objCase = [Select Id,Loan_Application__c,Applicant__c from Case LIMIT 1];
            objCase.Type = 'Current Residence FI';
            update objCase;
            Field_Investigation__c fiRecord = [Select Id, Landmark__c,Case__r.Type,Case__r.Applicant__c, Case__r.Applicant__r.Applicant_Type__c,Case__r.RecordTypeId,Address_Verified_with_KYC__c ,recordTypeId, recordType.Name, Customer_house_same_as_in_application__c  
                                               from Field_Investigation__c where Case__c =: objCase.Id];
            
            CASA_Bank_Form__c casa = [Select id,Applicant__c from CASA_Bank_Form__c where Applicant__c =: applicant.Id];
            Test.startTest();
            List<IND_TeleverificationDetails.wrpTVR> resultWrapper = IND_TeleverificationDetails.getTVRRecord(objCase.Id);
            System.assertNotEquals(null, resultWrapper);
            Test.stopTest();     
        }
        
    }
    @isTest
    public static void getTVRRecordTest5(){
        
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [Select Id from Opportunity LIMIT 1];
            
            Applicant__c applicant = [ Select Id,Opportunity__c from  Applicant__c where Opportunity__c=:opp.Id LIMIT 1];
            applicant.In_Active_Applicant__c = false;
            applicant.Applicant_Type__c = 'Co-borrower';
            update applicant;
            TeleVerification__c tele = [ Select Id,Loan_Application__c,Applicant__c from TeleVerification__c];
            Case objCase = [Select Id,Loan_Application__c,Applicant__c from Case LIMIT 1];
            objCase.Type = 'Permanent Residence FI';
            update objCase;
            Field_Investigation__c fiRecord = [Select Id, Landmark__c,Case__r.Type,Case__r.Applicant__c, Case__r.Applicant__r.Applicant_Type__c,Case__r.RecordTypeId,Address_Verified_with_KYC__c ,recordTypeId, recordType.Name, Customer_house_same_as_in_application__c  
                                               from Field_Investigation__c where Case__c =: objCase.Id];
            
            CASA_Bank_Form__c casa = [Select id,Applicant__c from CASA_Bank_Form__c where Applicant__c =: applicant.Id];
            Test.startTest();
            List<IND_TeleverificationDetails.wrpTVR> resultWrapper = IND_TeleverificationDetails.getTVRRecord(objCase.Id);
            System.assertNotEquals(null, resultWrapper);
            Test.stopTest();     
        }
        
    }
    @isTest
    public static void getTVRRecordTest6(){
        
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [Select Id from Opportunity LIMIT 1];
            
            Applicant__c applicant = [ Select Id,Opportunity__c from  Applicant__c where Opportunity__c=:opp.Id LIMIT 1];
            applicant.In_Active_Applicant__c = false;
            applicant.Applicant_Type__c = 'Borrower';
            update applicant;
            TeleVerification__c tele = [ Select Id,Loan_Application__c,Applicant__c from TeleVerification__c];
            Case objCase = [Select Id,Loan_Application__c,Applicant__c from Case LIMIT 1];
            objCase.Type = 'Permanent Residence FI';
            update objCase;
            Field_Investigation__c fiRecord = [Select Id, Landmark__c,Case__r.Type,Case__r.Applicant__c, Case__r.Applicant__r.Applicant_Type__c,Case__r.RecordTypeId,Address_Verified_with_KYC__c ,recordTypeId, recordType.Name, Customer_house_same_as_in_application__c  
                                               from Field_Investigation__c where Case__c =: objCase.Id];
            
            CASA_Bank_Form__c casa = [Select id,Applicant__c from CASA_Bank_Form__c where Applicant__c =: applicant.Id];
            Test.startTest();
            List<IND_TeleverificationDetails.wrpTVR> resultWrapper = IND_TeleverificationDetails.getTVRRecord(objCase.Id);
            System.assertNotEquals(null, resultWrapper);
            Test.stopTest();     
        }
        
    }
    @isTest
    public static void getTVRRecordTest7(){
        
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [Select Id from Opportunity LIMIT 1];
            opp.LeadSource = 'D2C';
            update opp;
            Applicant__c applicant = [ Select Id,Opportunity__c from  Applicant__c where Opportunity__c=:opp.Id LIMIT 1];
            applicant.In_Active_Applicant__c = false;
            applicant.Applicant_Type__c = 'Borrower';
            
            update applicant;
            TeleVerification__c tele = [ Select Id,Loan_Application__c,Applicant__c from TeleVerification__c];
            Case objCase = [Select Id,Loan_Application__c,Applicant__c from Case LIMIT 1];
            objCase.Type = 'Permanent Residence FI';
            update objCase;
            Field_Investigation__c fiRecord = [Select Id, Landmark__c,Case__r.Type,Case__r.Applicant__c, Case__r.Applicant__r.Applicant_Type__c,Case__r.RecordTypeId,Address_Verified_with_KYC__c ,recordTypeId, recordType.Name, Customer_house_same_as_in_application__c  
                                               from Field_Investigation__c where Case__c =: objCase.Id];
            
            CASA_Bank_Form__c casa = [Select id,Applicant__c from CASA_Bank_Form__c where Applicant__c =: applicant.Id];
            Final_Term__c finalTerm = [Select Id,Loan_amount__c From Final_Term__c Limit 1];
            Vehicle_Detail__c vehDetail = [Select Id from Vehicle_Detail__c limit 1];
            Test.startTest();
            List<IND_TeleverificationDetails.wrpTVR> resultWrapper = IND_TeleverificationDetails.getTVRRecord(objCase.Id);
            System.assertNotEquals(null, resultWrapper);
            Test.stopTest();     
        }
        
    }
    @isTest
    public static void updateTVRRecordTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try
            {
                IND_TeleverificationDetails.wrpTVR objWrapper = new IND_TeleverificationDetails.wrpTVR();            
                Opportunity opp = [Select Id from Opportunity];
                Applicant__c applicant = [ Select Id,Opportunity__c from  Applicant__c where Opportunity__c=:opp.Id LIMIT 1];
                applicant.In_Active_Applicant__c = false;
                update applicant;
                TeleVerification__c tele = [ Select Id,Loan_Application__c,Applicant__c from TeleVerification__c LIMIT 1];
                CASA_Bank_Form__c casa = [Select id,Applicant__c,Nominee_available__c from CASA_Bank_Form__c LIMIT 1];
                casa.Nominee_available__c = false;
                update casa;
                objWrapper.casabankId = casa.Id;
                objWrapper.tvrId = tele.Id;
                objWrapper.CB_nomineeAvailable = false;
                objWrapper.nomineeAvailable = false;
                
                Test.startTest();
                IND_TeleverificationDetails.updateTVRRecord(new List< IND_TeleverificationDetails.wrpTVR>{objWrapper}, opp.Id);
                TeleVerification__c updatedTele = [ Select Id,Loan_Application__c,Applicant__c from TeleVerification__c WHERE Applicant__c =: applicant.Id LIMIT 1];
                System.assertNotEquals(null, updatedTele);
                Test.stopTest(); 
            }
            catch(Exception e)
            {
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
    }    
    
    @isTest
    public static void updateTVRRecordTest2(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try
            {
                IND_TeleverificationDetails.wrpTVR objWrapper = new IND_TeleverificationDetails.wrpTVR();            
                Opportunity opp = [Select Id from Opportunity];
                Applicant__c applicant = [ Select Id,Opportunity__c from  Applicant__c where Opportunity__c=:opp.Id LIMIT 1];
                applicant.In_Active_Applicant__c = false;
                update applicant;
                TeleVerification__c tele = [ Select Id,Loan_Application__c,Applicant__c from TeleVerification__c LIMIT 1];
                CASA_Bank_Form__c casa = [Select id,Applicant__c,Nominee_available__c from CASA_Bank_Form__c LIMIT 1];
                casa.Nominee_available__c = false;
                update casa;
                objWrapper.casabankId = casa.Id;
                objWrapper.tvrId = tele.Id;
                objWrapper.CB_nomineeAvailable = false;
                objWrapper.nomineeAvailable = false;
                objWrapper.nomineePinCode = '231';
                objWrapper.CB_nomineePinCode = '11';
                objWrapper.nomineeStateId = '4';
                objWrapper.CB_nomineeStateId = '33';
                objWrapper.residenceCityFinacle = 'test';
                objWrapper.nomineeCityId = '01';
                objWrapper.CB_nomineeCityId = '09';
                Test.startTest();
                IND_TeleverificationDetails.updateTVRRecord(new List< IND_TeleverificationDetails.wrpTVR>{objWrapper}, opp.Id);
                TeleVerification__c updatedTele = [ Select Id,Loan_Application__c,Applicant__c from TeleVerification__c WHERE Applicant__c =: applicant.Id LIMIT 1];
                System.assertNotEquals(null, updatedTele);
                Test.stopTest(); 
            }
            catch(Exception e)
            {
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
    }    
    @isTest
    public static void updateTVRRecordTest3(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try
            {
                IND_TeleverificationDetails.wrpTVR objWrapper = new IND_TeleverificationDetails.wrpTVR();            
                Opportunity opp = [Select Id from Opportunity];
                Applicant__c applicant = [ Select Id,Opportunity__c from  Applicant__c where Opportunity__c=:opp.Id LIMIT 1];
                applicant.In_Active_Applicant__c = false;
                update applicant;
                TeleVerification__c tele = [ Select Id,Loan_Application__c,Applicant__c from TeleVerification__c LIMIT 1];
                tele.TVR_assessment__c = 'High Risk';
                update tele;
                CASA_Bank_Form__c casa = [Select id,Applicant__c,Nominee_available__c from CASA_Bank_Form__c LIMIT 1];
                casa.Nominee_available__c = false;
                update casa;
                objWrapper.casabankId = casa.Id;
                objWrapper.tvrId = tele.Id;
                objWrapper.CB_nomineeAvailable = false;
                objWrapper.nomineeAvailable = false;
                objWrapper.nomineePinCode = '231';
                objWrapper.CB_nomineePinCode = '11';
                objWrapper.nomineeStateId = '4';
                objWrapper.CB_nomineeStateId = '33';
                objWrapper.residenceCityFinacle = 'test';
                objWrapper.nomineeCityId = '01';
                objWrapper.CB_nomineeCityId = '09';
                objWrapper.permanentFinacle = 'test-1';
                objWrapper.officeCityFinacle = 'finacle-Test';
                objWrapper.loanAmountPaid = '230';
                objWrapper.alternateMobileNumber = '5678976543';
                objWrapper.tvrAttempts = 'test_attp';
                Test.startTest();
                IND_TeleverificationDetails.updateTVRRecord(new List< IND_TeleverificationDetails.wrpTVR>{objWrapper}, opp.Id);
                TeleVerification__c updatedTele = [ Select Id,Loan_Application__c,Applicant__c from TeleVerification__c WHERE Applicant__c =: applicant.Id LIMIT 1];
                System.assertNotEquals(null, updatedTele);
                Test.stopTest(); 
            }
            catch(Exception e)
            {
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
    }
    @isTest
    public static void updateTVRRecordTest4(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try
            {
                IND_TeleverificationDetails.wrpTVR objWrapper = new IND_TeleverificationDetails.wrpTVR();            
                Opportunity opp = [Select Id from Opportunity];
                Applicant__c applicant = [ Select Id,Opportunity__c from  Applicant__c where Opportunity__c=:opp.Id LIMIT 1];
                applicant.In_Active_Applicant__c = false;
                update applicant;
                TeleVerification__c tele = [ Select Id,Loan_Application__c,Applicant__c from TeleVerification__c LIMIT 1];
                tele.TVR_assessment__c = 'Pass';
                update tele;
                CASA_Bank_Form__c casa = [Select id,Applicant__c,Nominee_available__c from CASA_Bank_Form__c LIMIT 1];
                casa.Nominee_available__c = false;
                update casa;
                objWrapper.casabankId = casa.Id;
                objWrapper.tvrId = tele.Id;
                objWrapper.CB_nomineeAvailable = false;
                objWrapper.nomineeAvailable = false;
                objWrapper.nomineePinCode = '231';
                objWrapper.CB_nomineePinCode = '11';
                objWrapper.nomineeStateId = '4';
                objWrapper.CB_nomineeStateId = '33';
                objWrapper.residenceCityFinacle = 'test';
                objWrapper.nomineeCityId = '01';
                objWrapper.CB_nomineeCityId = '09';
                objWrapper.permanentFinacle = 'test-1';
                objWrapper.officeCityFinacle = 'finacle-Test';
                objWrapper.loanAmountPaid = '230';
                objWrapper.alternateMobileNumber = '5678976543';
                objWrapper.tvrAttempts = 'test_attp';
                Test.startTest();
                IND_TeleverificationDetails.updateTVRRecord(new List< IND_TeleverificationDetails.wrpTVR>{objWrapper}, opp.Id);
                TeleVerification__c updatedTele = [ Select Id,Loan_Application__c,Applicant__c from TeleVerification__c WHERE Applicant__c =: applicant.Id LIMIT 1];
                System.assertNotEquals(null, updatedTele);
                Test.stopTest(); 
            }
            catch(Exception e)
            {
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
    }    
    
    @isTest
    public static void updateDocCountForApplicantTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try
            {
                Opportunity opp = [Select Id from Opportunity];
                Applicant__c applicant = [ Select Id,Opportunity__c from  Applicant__c where Opportunity__c=:opp.Id LIMIT 1];
                
                Test.startTest();
                IND_TeleverificationDetails.updateDocCountForApplicant(applicant.Id, 5);
                Applicant__c applicantAfter = [ Select Id,Opportunity__c,Document_Count_for_TVR__c from  Applicant__c where Id=:applicant.Id LIMIT 1];
                System.assertNotEquals(null, applicantAfter);
                System.assertEquals(5, applicantAfter.Document_Count_for_TVR__c);
                Test.stopTest(); 
            }
            catch(Exception e)
            {
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
    }
    
    @isTest
    public static void getProductTypeTest(){
        try{
            Opportunity opp = [Select Id from Opportunity LIMIT 1];
            Applicant__c applicant = [ Select Id,Opportunity__c from  Applicant__c where Opportunity__c=:opp.Id LIMIT 1]; 
            TeleVerification__c tele = [ Select Id,Loan_Application__c,Applicant__c,Loan_Application__r.Product_Type__c from TeleVerification__c];
            Test.startTest();
            IND_TeleverificationDetails.getProductType(tele.Id);
            Test.stopTest(); 
        }
        catch(Exception e)
        {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    public static void getTVRIdTest(){
        try{
            
            Opportunity opp = [Select Id from Opportunity LIMIT 1];
            Case caseId  = [Select id from Case limit 1];
            Applicant__c applicant = [ Select Id,Opportunity__c from  Applicant__c where Opportunity__c=:opp.Id LIMIT 1]; 
            TeleVerification__c tele = [ Select Id,Loan_Application__c,Applicant__c,Loan_Application__r.Product_Type__c from TeleVerification__c];
            Test.startTest();
            IND_TeleverificationDetails.getTVRId(caseId.Id);
            Test.stopTest(); 
        }
        catch(Exception e)
        {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    
}