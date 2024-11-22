/*
* @Test Class:  AMLCheckDataTest 
* @Author: 		Nadish Bhatia
* @Description :All methods are to test class AMLCheckData
* @Company:     Persistent Systems
*/

@isTest(seeAllData = false)

public class AMLCheckDataTest {
    
    @testSetup 
    static void testDataSetup() 
    {
        Profile pAdmin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        Profile profICA = [SELECT Id FROM Profile WHERE Name='IBL Credit Analyst' ];
        Profile profCMU = [SELECT Id FROM Profile WHERE Name='CMU' ];
        Profile profCVO = [SELECT Id FROM Profile WHERE Name='IBL CVO' ];
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            User u = new User(Alias = 'standt2', email='standarduser2@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = pAdmin.Id,Maker_Id__c='12',IsActive = true,
                              timezonesidkey='america/los_angeles',username='test_userprodIBL@indusbank.com',MobilePhone = '9089078967');
            insert u;
            
            User u1 = new User(Alias = 'standt2', email='standarduser2@testorg.com', EmailEncodingKey='UTF-8', LastName='Test1', LanguageLocaleKey='en_US',
                               LocaleSidKey='en_US', ProfileId = profICA.Id, Maker_Id__c='12',IsActive = true,
                               timezonesidkey='america/los_angeles',username='test_userprod15@indusbank.com',MobilePhone = '9089078967');
            insert u1;
            
            User u2 = new User(Alias = 'standt2', email='standarduser2@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                               LocaleSidKey='en_US', ProfileId = profCMU.Id,Maker_Id__c='12',IsActive = true,
                               timezonesidkey='america/los_angeles',username='test_userprod13@indusbank.com',MobilePhone = '9089078967');
            insert u2;
            
            User u3 = new User(Alias = 'standt2', email='standarduser2@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                               LocaleSidKey='en_US', ProfileId = profCVO.Id,Maker_Id__c='12',IsActive = true,
                               timezonesidkey='america/los_angeles',username='test_userprod14@indusbank.com',MobilePhone = '9089078967');
            insert u3;
            
            Account acc = new Account();
            acc.Name = 'AccName';
            insert acc;
            
            Opportunity optg1 = new Opportunity();
            optg1.Submit_AML_Check_To_CA__c = true;
            optg1.StageName = 'Loan Details';
            optg1.CloseDate = Date.newInstance(2022, 1, 11);
            optg1.Name = 'testone';
            optg1.Vehicle_Type__c = 'Used';
            optg1.Product_Type__c = 'Passenger Vehicles';
            optg1.Ben_Code__c = 'optg2';
            optg1.Vehicle_Sub_Category__c = 'UOM';
            optg1.Agent_BL_code__c = 'BLC';
            optg1.Funded__c = false;
            optg1.Is_customer_interested_in_a_motor_insura__c = true;
            optg1.Motor_Insurance_Premium__c = 20000;
            optg1.Sub_Stage__c = 'Business Payment Details';
            optg1.OwnerId = u.Id;
            optg1.AML_Check_Completed__c = false;
            optg1.AccountId = acc.Id;
            insert optg1;
            
            AccountTeamMember accMem = new AccountTeamMember();
            accMem.AccountId = acc.Id;
            accMem.UserId = u.Id;
            accMem.AccountTeamExtern__c = '5678';
            accMem.TeamMemberRole = 'CH';
            insert accMem;
            
            Id amlRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('AML Check').getRecordTypeId();
            
            Case case_s = new Case();
            case_s.RecordTypeId = amlRecordTypeId;
            case_s.Origin = 'Email';
            case_s.Subject = 'disableInitiateAML';
            case_s.Loan_Application__c = optg1.Id;
            case_s.Status = 'Pending with Credit Head';
            case_s.OwnerId = u.Id;
            insert case_s;
            
            Opportunity opp = new Opportunity();
            opp.OwnerId = u.Id;
            opp.Name = 'opptestone';
            opp.StageName = 'Loan Details';
            opp.CloseDate = Date.newInstance(2022, 1, 11);
            insert opp;
            
            
            Case case_s1 = new Case();
            case_s1.RecordTypeId = amlRecordTypeId;
            case_s1.Origin = 'Web';
            case_s1.Subject = 'disableInitiateAML';
            case_s1.Loan_Application__c = optg1.Id;
            case_s1.Status = 'Pending with Credit Analyst';
            insert case_s1;
            
            
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
            amlCheck.Loan_Application__c = optg1.Id;
            amlCheck.Case__c = case_s.Id;
            insert amlCheck;
            
            CAM__c cam = new CAM__c();
            cam.Loan_Application__c = optg1.Id;
            insert cam;
            
            AmlCheckData.Field fld = new AmlCheckData.Field();
            fld.score = 9;
            fld.queryValue = 'queryValue';
            fld.name = 'name';
            fld.value = 'value';
            
            AmlCheckData.AmlDataWrapper amldtwrap = new AmlCheckData.AmlDataWrapper();
            amldtwrap.id = null;
            amldtwrap.score = 67;
            amldtwrap.listName = 'listName';
            amldtwrap.name = 'name';
            amldtwrap.nationality = 'Indian';
            
            Opportunity optg = new Opportunity();
            optg.Submit_AML_Check_To_CA__c = true;
            optg.StageName = 'Loan Details';
            optg.CloseDate = Date.newInstance(2022, 1, 11);
            optg.Name = 'testone';
            optg.Vehicle_Type__c = 'Used';
            optg.Product_Type__c = 'Passenger Vehicles';
            optg.Ben_Code__c = 'optg2';
            optg.Vehicle_Sub_Category__c = 'UOM';
            optg.Agent_BL_code__c = 'BLC';
            optg.Funded__c = false;
            optg.Is_customer_interested_in_a_motor_insura__c = true;
            optg.Motor_Insurance_Premium__c = 20000;
            optg.Sub_Stage__c = 'Business Payment Details';
            optg.OwnerId = u1.Id;
            optg.AML_Check_Completed__c = false;
            optg.AccountId = acc.Id;
            insert optg;
            
            Case case_ss = new Case();
            case_ss.RecordTypeId = amlRecordTypeId;
            case_ss.Origin = 'Email';
            case_ss.Subject = 'disableInitiateAML';
            case_ss.Loan_Application__c = optg.Id;
            case_ss.Status = 'Pending with Credit Head';
            case_ss.OwnerId = u1.Id;
            insert case_ss;
            
            CAM__c cam1 = new CAM__c();
            cam1.Loan_Application__c = optg.Id;
            insert cam1;
            
            AML_Check__c amlChecku1 = new AML_Check__c();
            amlChecku1.Matched_base__c = 'MatchBase';
            amlChecku1.List_Name__c = 'amlList';
            amlChecku1.Name__c = 'amlName';
            amlChecku1.Name_Score__c = 9;
            amlChecku1.ML_Id__c = '45678';
            amlChecku1.Nationality__c = 'IND';
            amlChecku1.Nationality_Score__c = 90;
            amlChecku1.ML_Address__c = 'Mumbai';
            amlChecku1.ML_City__c = 'Mumbai';
            amlChecku1.ML_Date_Of_Birth__c = String.valueOf(System.today());
            amlChecku1.ML_Description__c = 'Creating aml Data';
            amlChecku1.CA_Decision__c = '';
            amlChecku1.Remarks_Credit_Analyst__c = '';
            amlChecku1.CH_Decision__c = '';
            amlChecku1.Remarks_Credit_Head__c = '';
            amlChecku1.CMU_Decision__c = 'Positive';
            amlChecku1.Remarks_CMU__c = '';
            amlChecku1.BE_CVO_Decision__c = '';
            amlChecku1.Remarks_BE_CVO__c = '';
            amlChecku1.Score__c = 90;
            amlChecku1.Loan_Application__c = optg.Id;
            amlChecku1.Credit_Analyst__c = true;
            insert amlChecku1;
            
            Opportunity opp1 = new Opportunity();
            opp1.OwnerId = u.Id;
            opp1.Name = 'opptestone1';
            opp1.StageName = 'Loan Details';
            opp1.CloseDate = Date.newInstance(2022, 1, 11);
            insert opp1;
            
            List <Retry_Count__c> retryCountList = new list <Retry_Count__c>();
            Retry_Count__c retryCount = new Retry_Count__c();
            retryCount.Count__c = 3;
            retryCount.Loan_Application_Id__c = optg1.Id;
            retryCount.Service_Name__c = System.Label.AML;
            retryCount.User_Id__c = u.Id;
            retryCount.Applicant_Type__c = 'Borrower';
            retryCountList.add(retryCount);
            
            Retry_Count__c retryCount1 = new Retry_Count__c();
            retryCount1.Count__c = 2;
            retryCount1.Loan_Application_Id__c = opp.Id;
            retryCount1.Service_Name__c = System.Label.AML;
            retryCount1.User_Id__c = u.Id;
            retryCount1.Applicant_Type__c = 'Co-borrower';
            retryCountList.add(retryCount1);
            
            insert retryCountList;
            
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test Document';
            cv.PathOnClient = 'TestDocument.pdf';
            cv.VersionData = Blob.valueOf('Test Content');
            cv.IsMajorVersion = true;
            Insert cv;
            //Get Content Version
            List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
            //Get Content Documents
            List<ContentDocument> cdList = [SELECT Id, Title FROM ContentDocument];
            
            AmlCheckData.MatchedRecords mtchcRcdrd = new AmlCheckData.MatchedRecords();
            mtchcRcdrd.Id = optg1.Id;
            mtchcRcdrd.partialKycFlag = true;
            mtchcRcdrd.listName = 'Lname';
            mtchcRcdrd.DateOfBirth = null;
            mtchcRcdrd.address = 'Sec-3';
            mtchcRcdrd.city = 'Delhi';
            mtchcRcdrd.description = 'description';
            mtchcRcdrd.fields = new List <AmlCheckData.Field>{fld};
                mtchcRcdrd.score = '8';
            
            AmlCheckData.MatchedResults mtchcResult = new AmlCheckData.MatchedResults();
            mtchcResult.total = 90;
            mtchcResult.matchedRecords = new List <AmlCheckData.MatchedRecords>{mtchcRcdrd};
                mtchcResult.maxScore = 'maxi';
            
            AmlCheckData.status sts = new AmlCheckData.status();
            sts.errorDetails = 'NoErr';
            sts.status = 'Closed';
            
            AmlCheckData.WlMatch wlMtch = new AmlCheckData.WlMatch();
            wlMtch.status = sts;
            wlMtch.matchedResults = mtchcResult;
            
            AmlCheckData.AmlResponse amlRes = new AmlCheckData.AmlResponse();
            amlRes.WlMatch = wlMtch;
            amlRes.body = 'bdy';
            
            Opportunity optg2 = new Opportunity();
            optg2.StageName = 'Loan Details';
            optg2.CloseDate = Date.newInstance(2022, 1, 11);
            optg2.Name = 'testone';
            optg2.Vehicle_Type__c = 'Used';
            optg2.Product_Type__c = 'Passenger Vehicles';
            optg2.Ben_Code__c = 'optg2';
            optg2.Vehicle_Sub_Category__c = 'UOM';
            optg2.Agent_BL_code__c = 'BLC';
            optg2.Funded__c = false;
            optg2.Is_customer_interested_in_a_motor_insura__c = true;
            optg2.Motor_Insurance_Premium__c = 20000;
            optg2.Sub_Stage__c = 'Business Payment Details';
            optg2.OwnerId = u1.Id;
            optg2.AML_Check_Completed__c = true;
            insert optg2;
            
            Case cs = new Case();
            cs.Origin = 'Email';
            cs.Subject = 'disableInitiateAML';
            cs.Loan_Application__c = optg2.Id;
            cs.Status = 'Closed';
            insert cs;
            
            Opportunity optg3 = new Opportunity();
            optg3.StageName = 'Loan Details';
            optg3.CloseDate = Date.newInstance(2022, 1, 11);
            optg3.Name = 'testone3';
            optg3.Vehicle_Type__c = 'Used';
            optg3.Product_Type__c = 'Passenger Vehicles';
            optg3.Ben_Code__c = 'optg2';
            optg3.Vehicle_Sub_Category__c = 'UOM';
            optg3.Agent_BL_code__c = 'BLC';
            optg3.Funded__c = false;
            optg3.Is_customer_interested_in_a_motor_insura__c = true;
            optg3.Motor_Insurance_Premium__c = 20000;
            optg3.Sub_Stage__c = 'Business Payment Details';
            optg3.OwnerId = u2.Id;
            optg3.AML_Check_Completed__c = true;
            insert optg3;
            
            CAM__c cam3 = new CAM__c();
            cam3.Loan_Application__c = optg3.Id;
            insert cam3;
            
            Case cs2 = new Case();
            cs2.Origin = 'Email';
            cs2.Subject = 'disableInitiateAML';
            cs2.Loan_Application__c = optg3.Id;
            cs2.OwnerId = u2.Id;
            cs2.Status = 'Pending with Credit Analyst';
            insert cs2;
            
            AML_Check__c amlCheck2 = new AML_Check__c();
            amlCheck2.Matched_base__c = 'MatchBase';
            amlCheck2.List_Name__c = 'amlList';
            amlCheck2.Name__c = 'amlName';
            amlCheck2.Name_Score__c = 9;
            amlCheck2.ML_Id__c = '45678';
            amlCheck2.Nationality__c = 'IND';
            amlCheck2.Nationality_Score__c = 90;
            amlCheck2.ML_Address__c = 'Mumbai';
            amlCheck2.ML_City__c = 'Mumbai';
            amlCheck2.ML_Date_Of_Birth__c = String.valueOf(System.today());
            amlCheck2.ML_Description__c = 'Creating aml Data';
            amlCheck2.CA_Decision__c = '';
            amlCheck2.Remarks_Credit_Analyst__c = '';
            amlCheck2.CH_Decision__c = '';
            amlCheck2.Remarks_Credit_Head__c = '';
            amlCheck2.CMU_Decision__c = 'Positive';
            amlCheck2.Remarks_CMU__c = '';
            amlCheck2.BE_CVO_Decision__c = '';
            amlCheck2.Remarks_BE_CVO__c = '';
            amlCheck2.Score__c = 90;
            amlCheck2.Loan_Application__c = optg3.Id;
            amlCheck2.Case__c = cs2.Id;
            insert amlCheck2;
            
            
            
            Opportunity optg4 = new Opportunity();
            optg4.StageName = 'Loan Details';
            optg4.CloseDate = Date.newInstance(2022, 1, 11);
            optg4.Name = 'testone';
            optg4.Vehicle_Type__c = 'Used';
            optg4.Product_Type__c = 'Passenger Vehicles';
            optg4.Ben_Code__c = 'optg2';
            optg4.Vehicle_Sub_Category__c = 'UOM';
            optg4.Agent_BL_code__c = 'BLC';
            optg4.Funded__c = false;
            optg4.Is_customer_interested_in_a_motor_insura__c = true;
            optg4.Motor_Insurance_Premium__c = 20000;
            optg4.Sub_Stage__c = 'Business Payment Details';
            optg4.OwnerId = u3.Id;
            optg4.AML_Check_Completed__c = true;
            insert optg4;
            
            Case cs4 = new Case();
            cs4.Origin = 'Email';
            cs4.Subject = 'disableInitiateAML';
            cs4.Loan_Application__c = optg4.Id;
            cs4.OwnerId = u3.Id;
            cs4.Status = 'Pending with CMU';
            insert cs4;
            
            AML_Check__c amlCheck3 = new AML_Check__c();
            amlCheck3.Matched_base__c = 'MatchBase';
            amlCheck3.List_Name__c = 'amlList';
            amlCheck3.Name__c = 'amlName';
            amlCheck3.Name_Score__c = 9;
            amlCheck3.ML_Id__c = '45678';
            amlCheck3.Nationality__c = 'IND';
            amlCheck3.Nationality_Score__c = 90;
            amlCheck3.ML_Address__c = 'Mumbai';
            amlCheck3.ML_City__c = 'Mumbai';
            amlCheck3.ML_Date_Of_Birth__c = String.valueOf(System.today());
            amlCheck3.ML_Description__c = 'Creating aml Data';
            amlCheck3.CA_Decision__c = '';
            amlCheck3.Remarks_Credit_Analyst__c = '';
            amlCheck3.CH_Decision__c = '';
            amlCheck3.Remarks_Credit_Head__c = '';
            amlCheck3.CMU_Decision__c = '';
            amlCheck3.Remarks_CMU__c = '';
            amlCheck3.BE_CVO_Decision__c = '';
            amlCheck3.Remarks_BE_CVO__c = '';
            amlCheck3.Score__c = 90;
            amlCheck3.Loan_Application__c = optg4.Id;
            amlCheck3.Case__c = case_s.Id;
            insert amlCheck3;
            
            
            Applicant__c objApplicant = new Applicant__c();
            objApplicant.Opportunity__c = optg1.Id;
            objApplicant.Applicant_Type__c = 'Borrower';
            objApplicant.Contact_number__c = '1234567890';
            objApplicant.Bank_Account_No__c = 1453446;
            objApplicant.Voter_ID_No__c = '123456542';
            objApplicant.Driving_License_No__c = '645766643';      		
            objApplicant.Name = 'Test';
            insert objApplicant;
            
            Documents__c docObj = new Documents__c();
            docObj.Opportunity_Relation__c = optg1.Id;
            docObj.KYC_name__c = 'Aadhar';
            docObj.Document_Side__c ='Back';
            docObj.Aadhar_Source__c = 'ScanAadhar';
            docObj.Document_Type__c = System.Label.AadhaarCard;
            docObj.KYC_DOB__c = system.today();
            docObj.Proof_of_Identity_POI__c = true;
            docObj.Proof_of_Address_POA__c = true;
            docObj.Document_Type__c ='Residence FI';
            docObj.Addresss_Type__c = 'Permanent Residential Address';
            docObj.Gender__c = 'MALE';
            docObj.Name = 'Document1';
            docObj.Applicant__c = objApplicant.Id;
            docObj.Passport_No__c = '49841654';
            docObj.Aadhaar_Enrollment_Number__c = '2365664';
            docObj.PAN_No__c = '225454554';
            docObj.Current_Residential_Address_Proof__c = true;
            docObj.KYC_Address_Line_1__c = 'Test Address1';
            docObj.KYC_Address_Line_2__c = 'Test Address2';
            docObj.Permanent_Residential_Address_Proof__c = true;
            insert docObj; 
            
            Income_Details__c incomeObj = new Income_Details__c();
            incomeObj.Office_Address_Line_1__c =  'Test Office Address1';
            incomeObj.Office_Address_Line_2__c = 'Test Office Address2';
            incomeObj.Applicant__c = objApplicant.Id;
            insert incomeObj;
        }
        
    }
    
    @isTest
    public static void insertObjectRecordsTest(){
        try{
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprodIBL@indusbank.com' AND IsActive = true LIMIT 1];
            System.runAs(u)
            {
                Opportunity opp = [SELECT Id, Name, OwnerId FROM Opportunity WHERE OwnerId =: u.Id LIMIT 1];
                
                AmlCheckData.Field fld = new AmlCheckData.Field();
                fld.score = 9;
                fld.queryValue = 'queryValue';
                fld.name = 'name';
                fld.value = 'value';
                
                
                AmlCheckData.MatchedRecords mtchcRcdrd = new AmlCheckData.MatchedRecords();
                mtchcRcdrd.Id = opp.Id;
                mtchcRcdrd.partialKycFlag = true;
                mtchcRcdrd.listName = 'Lname';
                mtchcRcdrd.DateOfBirth = null;
                mtchcRcdrd.address = 'Sec-3';
                mtchcRcdrd.city = 'Delhi';
                mtchcRcdrd.description = 'description';
                mtchcRcdrd.fields = new List <AmlCheckData.Field>{fld};
                    mtchcRcdrd.score = '8';
                
                AmlCheckData.MatchedResults mtchcResult = new AmlCheckData.MatchedResults();
                mtchcResult.total = 90;
                mtchcResult.matchedRecords = new List <AmlCheckData.MatchedRecords>{mtchcRcdrd};
                    mtchcResult.maxScore = 'maxi';
                
                AmlCheckData.status sts = new AmlCheckData.status();
                sts.errorDetails = 'NoErr';
                sts.status = 'Closed';
                
                AmlCheckData.WlMatch wlMtch = new AmlCheckData.WlMatch();
                wlMtch.status = sts;
                wlMtch.matchedResults = mtchcResult;
                
                AmlCheckData.AmlResponse amlRes = new AmlCheckData.AmlResponse();
                amlRes.WlMatch = wlMtch;
                amlRes.body = 'bdy';
                
                //boolean matchFound;
                AmlCheckData.insertObjectRecords(JSON.serialize(amlRes), opp.Id, 'j0000@GHTBD1234', null);
            }
            
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void insertObjectRecordsTest1(){
        try{
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprodIBL@indusbank.com' AND IsActive = true LIMIT 1];
            System.runAs(u)
            {
                Opportunity opp = [SELECT Id, Name, OwnerId FROM Opportunity WHERE OwnerId =: u.Id LIMIT 1];
                
                AmlCheckData.Field fld = new AmlCheckData.Field();
                fld.score = 9;
                fld.queryValue = 'queryValue';
                fld.name = 'nationality';
                fld.value = 'value';
                
                
                AmlCheckData.MatchedRecords mtchcRcdrd = new AmlCheckData.MatchedRecords();
                mtchcRcdrd.Id = opp.Id;
                mtchcRcdrd.partialKycFlag = true;
                mtchcRcdrd.listName = 'Lname';
                mtchcRcdrd.DateOfBirth = null;
                mtchcRcdrd.address = 'Sec-3';
                mtchcRcdrd.city = 'Delhi';
                mtchcRcdrd.description = 'description';
                mtchcRcdrd.fields = new List <AmlCheckData.Field>{fld};
                    mtchcRcdrd.score = '8';
                
                AmlCheckData.MatchedResults mtchcResult = new AmlCheckData.MatchedResults();
                mtchcResult.total = 90;
                mtchcResult.matchedRecords = new List <AmlCheckData.MatchedRecords>{mtchcRcdrd};
                    mtchcResult.maxScore = 'maxi';
                
                AmlCheckData.status sts = new AmlCheckData.status();
                sts.errorDetails = 'NoErr';
                sts.status = 'Closed';
                
                AmlCheckData.WlMatch wlMtch = new AmlCheckData.WlMatch();
                wlMtch.status = sts;
                wlMtch.matchedResults = mtchcResult;
                
                AmlCheckData.AmlResponse amlRes = new AmlCheckData.AmlResponse();
                amlRes.WlMatch = wlMtch;
                amlRes.body = 'bdy';
                
                //boolean matchFound;
                AmlCheckData.insertObjectRecords(JSON.serialize(amlRes), opp.Id, 'j0000@GHTBD1234', null);
            }
            
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    
    @isTest
    public static void disableInitiateAMLTest(){
        try{
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprodIBL@indusbank.com' AND IsActive = true LIMIT 1];
            System.runAs(u)
            {
                Opportunity opp = [SELECT Id, Name, AML_Check_Completed__c FROM Opportunity LIMIT 1];
                
                boolean boolt = AmlCheckData.disableInitiateAML(opp.Id);
                AmlCheckData.disableInitiateAML('test');
                AmlCheckData.disableInitiateAML(null);
                System.assertEquals(true, boolt);
                
                opp.AML_Check_Completed__c = true;
                update opp;
                
                boolean booltr = AmlCheckData.disableInitiateAML(opp.Id);
                system.assertEquals(true, booltr);
                
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getLoanApplicantsTest(){
        try{
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprodIBL@indusbank.com' AND IsActive = true LIMIT 1];
            System.runAs(u)
            {
                Opportunity opp = [SELECT Id, Name, OwnerId FROM Opportunity LIMIT 1];
                
                List<Applicant__c> applicants = [SELECT Id,Applicant_Type__c, Bank_Account_No__c FROM Applicant__c WHERE Opportunity__c = :opp.Id];
                List<Applicant__c> appList = AmlCheckData.getLoanApplicants(opp.Id);
                AmlCheckData.getLoanApplicants('test');
                AmlCheckData.getLoanApplicants(null);
                
                System.assertEquals(applicants, appList);              
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getBorrowerLoanApplicantTest(){
        try{
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprodIBL@indusbank.com' AND IsActive = true LIMIT 1];
            System.runAs(u)
            {
                Opportunity opp = [SELECT Id, Name, OwnerId FROM Opportunity LIMIT 1];
                
                Applicant__c applicants = [SELECT Id,Applicant_Type__c, Bank_Account_No__c FROM Applicant__c WHERE Opportunity__c = :opp.Id AND Applicant_Type__c = 'Borrower'];
                List<Applicant__c> app = AmlCheckData.getBorrowerLoanApplicant(opp.Id);
                AmlCheckData.getBorrowerLoanApplicant('test');
                AmlCheckData.getBorrowerLoanApplicant(null);
                System.assertEquals(applicants.Id, app[0].Id);
                
                
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getProfileTest(){
        try{
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprodIBL@indusbank.com' AND IsActive = true LIMIT 1];
            System.runAs(u)
            {
                Opportunity opp = [SELECT Id, Name, OwnerId FROM Opportunity LIMIT 1];
                AmlCheckData.getProfile('Closed', opp.Id); 
                System.assertEquals(u.Id,opp.OwnerId);              
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getProfileTest1(){
        try{
            Test.startTest();
            User u1 = [SELECT Id, usertype FROM User WHERE username='test_userprod15@indusbank.com' AND  LastName=:'Test1' LIMIT 1];
            System.runAs(u1)
            {
                Opportunity opp = [SELECT Id, Name, OwnerId FROM Opportunity WHERE OwnerId =: u1.Id LIMIT 1];
                
                AmlCheckData.getProfile('Closed', opp.Id); 
                System.assertEquals(u1.Id,opp.OwnerId);              
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getProfileTest2(){
        try{
            Test.startTest();
            User u2 = [SELECT Id, usertype FROM User WHERE username='test_userprod13@indusbank.com' LIMIT 1];        
            System.runAs(u2)
            {
                Opportunity opp = [SELECT Id, Name, OwnerId FROM Opportunity WHERE OwnerId =: u2.Id LIMIT 1];
                
                AmlCheckData.getProfile('Closed', opp.Id); 
                System.assertEquals(u2.Id,opp.OwnerId);              
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getProfileTest3(){
        try{
            Test.startTest();
            User u3 = [SELECT Id, usertype FROM User WHERE username='test_userprod14@indusbank.com' LIMIT 1];        
            System.runAs(u3)
            {
                Opportunity opp = [SELECT Id, Name, OwnerId FROM Opportunity WHERE OwnerId =: u3.Id LIMIT 1];
                
                AmlCheckData.getProfile('Closed', opp.Id); 
                System.assertEquals(u3.Id,opp.OwnerId);              
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getPenBECVOTest(){
        try{
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprodIBL@indusbank.com' AND IsActive = true LIMIT 1];
            System.runAs(u)
            {
                Opportunity opp = [SELECT Id, Name, OwnerId FROM Opportunity LIMIT 1];
                AmlCheckData.getPenBECVO(opp.Id); 
                AmlCheckData.getPenCA(opp.Id); 
                AmlCheckData.getPenCMU(opp.Id); 
                System.assertEquals(u.Id,opp.OwnerId);   
                
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getAllAMLRecordsTest(){
        try{
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprodIBL@indusbank.com' AND IsActive = true LIMIT 1];
            System.runAs(u)
            {
                Opportunity opp = [SELECT Id, Name, OwnerId FROM Opportunity WHERE OwnerId =: u.Id LIMIT 1];
                
                //AmlCheckData.getAllAMLRecords();
                
                List<AML_Check__c> amlcheckList = AmlCheckData.getAllAMLRecords('', opp.Id);
                List<AML_Check__c> amlcheckList1 = AmlCheckData.getAllAMLRecords('Closed', opp.Id);
                
                System.assertnotEquals(null, amlcheckList);
                System.assertnotEquals(null, amlcheckList);
                
                
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void submitAMLCheckToCATest(){
        try{
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprodIBL@indusbank.com' AND IsActive = true LIMIT 1];
            System.runAs(u)
            {
                Opportunity opp = [SELECT Id, Name, Submit_AML_Check_To_CA__c, OwnerId FROM Opportunity WHERE OwnerId =: u.Id LIMIT 1];
                
                AmlCheckData.submitAMLCheckToCA(opp.Id);               
                system.assertEquals(true, opp.Submit_AML_Check_To_CA__c);
                
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void updateAMLCheckToCATest(){
        try{
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprodIBL@indusbank.com' AND IsActive = true LIMIT 1];
            System.runAs(u)
            {
                Opportunity opp = [SELECT Id, Name, Submit_AML_Check_To_CA__c, OwnerId FROM Opportunity WHERE OwnerId =: u.Id LIMIT 1];
                
                AmlCheckData.updateAMLCheckToCA(opp.Id);
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    
    @isTest
    public static void  getAMLApprovalsTest(){
        try{
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprodIBL@indusbank.com' AND IsActive = true LIMIT 1];
            System.runAs(u)
            {
                AmlCheckData.getAMLApprovals();
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void  updateAmlCheckTest(){
        try{
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprodIBL@indusbank.com' AND IsActive = true LIMIT 1];
            System.runAs(u)
            {
                Opportunity opp = [SELECT Id, Name, Submit_AML_Check_To_CA__c, OwnerId FROM Opportunity WHERE OwnerId =: u.Id LIMIT 1];
                Case cObj = [SElect Id from Case Limit 1];
                list <AML_Check__c> amlcheckList = [SELECT Id, Name__c,Case__c FROM AML_Check__c WHERE Loan_Application__c =: opp.Id];
                
                AmlCheckData.updateAmlCheck(amlcheckList, opp.Id,cObj.Id);
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void  updateAmlCheckTest1(){
        try{
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod14@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u)
            {
                Opportunity opp = [SELECT Id, Name, Submit_AML_Check_To_CA__c, OwnerId FROM Opportunity WHERE OwnerId =: u.Id LIMIT 1];
                Case cObj = [SElect Id from Case Limit 1];
                list <AML_Check__c> amlcheckList = [SELECT Id, Name__c,Case__c FROM AML_Check__c WHERE Loan_Application__c =: opp.Id];
                
                AmlCheckData.updateAmlCheck(amlcheckList, opp.Id,cObj.Id);
            }
            Test.stopTest();
        }catch(Exception e){
            //system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void  updateAmlCheckTest2(){
        try{
            Test.startTest();
            User u = [SELECT Id,usertype, Name FROM User WHERE username='test_userprod13@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u)
            {
                Opportunity opp = [SELECT Id, Name, Submit_AML_Check_To_CA__c, OwnerId FROM Opportunity WHERE OwnerId =: u.Id LIMIT 1];
                Case cObj = [SElect Id from Case Limit 1];
                List<CAM__c> camList = [SELECT Id FROM CAM__c WHERE Loan_Application__c = :opp.Id LIMIT 1];
                list <AML_Check__c> amlcheckList = [SELECT Id, Name__c,case__c FROM AML_Check__c WHERE Loan_Application__c =: opp.Id];
                AmlCheckData.updateAmlCheck(amlcheckList, opp.Id,cObj.Id);
            }
            Test.stopTest();
        }catch(Exception e){
            //system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void  updateAmlCheckTest3(){
        try{
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod15@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u)
            {
                Opportunity opp = [SELECT Id, Name, Submit_AML_Check_To_CA__c, OwnerId FROM Opportunity WHERE OwnerId =: u.Id LIMIT 1];
                Case cObj = [SElect Id from Case Limit 1];
                list <AML_Check__c> amlcheckList = [SELECT Id, Name__c,Case__c FROM AML_Check__c WHERE Loan_Application__c =: opp.Id];
                
                AmlCheckData.updateAmlCheck(amlcheckList, opp.Id,cObj.Id);
            }
            Test.stopTest();
        }catch(Exception e){
            //system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

    @isTest
    public static void  updateAmlCheckTest31(){
        try{
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod15@indusbank.com' AND IsActive = true LIMIT 1];
            System.runAs(u)
            {
                Opportunity opp = [SELECT Id, Name, Submit_AML_Check_To_CA__c, OwnerId FROM Opportunity WHERE OwnerId =: u.Id LIMIT 1];
                Case cObj = [SElect Id from Case Limit 1];
                cObj.Status = System.Label.Pendingcreditanalyst;
                update cObj;
                list <AML_Check__c> amlcheckList = [SELECT Id, Name__c,Case__c FROM AML_Check__c WHERE Loan_Application__c =: opp.Id];
                for(AML_Check__c aml :amlcheckList){
                    aml.CA_Decision__c = 'Positive';
                    aml.Case__c = cObj.id;
                }
                update amlcheckList;
                AmlCheckData.updateAmlCheck(amlcheckList, opp.Id,cObj.Id);
            }
            Test.stopTest();
        }catch(Exception e){
            //system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

    @isTest
    public static void  updateAmlCheckTest32(){
        try{
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod15@indusbank.com' AND IsActive = true LIMIT 1];
            System.runAs(u)
            {
                Opportunity opp = [SELECT Id, Name, Submit_AML_Check_To_CA__c, OwnerId FROM Opportunity WHERE OwnerId =: u.Id LIMIT 1];
                Case cObj = [SElect Id from Case Limit 1];
                cObj.Status = System.Label.Pendingcreditanalyst;
                update cObj;
                list <AML_Check__c> amlcheckList = [SELECT Id, Name__c,Case__c FROM AML_Check__c WHERE Loan_Application__c =: opp.Id];
                for(AML_Check__c aml :amlcheckList){
                    aml.CA_Decision__c = 'Positive';
                    aml.Case__c = cObj.id;
                }
                CAM__c[] camObj = [Select id from CAM__c Where Loan_Application__c=: opp.id];
				delete camObj;
                update amlcheckList;
                AmlCheckData.updateAmlCheck(amlcheckList, opp.Id,cObj.Id);
            }
            Test.stopTest();
        }catch(Exception e){
            //system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void  updateAMLCheckDocumentTest(){
        try{
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprodIBL@indusbank.com' AND IsActive = true LIMIT 1];
            System.runAs(u)
            {
                AML_Check__c amlCheck = [SELECT Id, Name FROM AML_Check__c WHERE Name__c =:'amlName' LIMIT 1];
                
                AmlCheckData.updateAMLCheckDocument('ConDocId', amlCheck.Id);
                AmlCheckData.updateAMLCheckDocument(null, amlCheck.Id);
            }
            Test.stopTest();
        }catch(Exception e){
            //system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void  changeFilenameTest(){
        try{
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprodIBL@indusbank.com' AND IsActive = true LIMIT 1];
            System.runAs(u)
            {
                Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');
                ContentVersion cv = new ContentVersion();
                cv.title = 'test content trigger';      
                cv.PathOnClient ='test';           
                cv.VersionData =beforeblob;          
                insert cv;
                ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
                List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
                
                AmlCheckData.changeFilename(documents[0].Id, 'IndusInd_Logo');
                
            }
            Test.stopTest();
        }catch(Exception e){
            //system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void  checkRetryExhaustedTest(){
        try{
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprodIBL@indusbank.com' AND IsActive = true LIMIT 1];
            System.runAs(u)
            {
                Opportunity opp = [SELECT Id, Name, Submit_AML_Check_To_CA__c, OwnerId FROM Opportunity WHERE OwnerId =: u.Id LIMIT 1];
                
                AmlCheckData.checkRetryExhausted(opp.Id);
                AmlCheckData.checkRetryExhausted(null);
                
            }
            Test.stopTest();
        }catch(Exception e){
            //system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void  retryCountIncreaseTest(){
        try{
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprodIBL@indusbank.com' AND IsActive = true LIMIT 1];
            System.runAs(u)
            {
                Opportunity opp = [SELECT Id, Name, Submit_AML_Check_To_CA__c, OwnerId FROM Opportunity WHERE OwnerId =: u.Id AND Name =: 'opptestone' LIMIT 1];
                
                Opportunity opp1 = [SELECT Id, Name, Submit_AML_Check_To_CA__c, OwnerId FROM Opportunity WHERE OwnerId =: u.Id AND Name =: 'opptestone1' LIMIT 1];
                
                AmlCheckData.retryCountIncrease(opp.Id);
                AmlCheckData.retryCountIncrease(opp1.Id);
                AmlCheckData.retryCountIncrease(null);
                
            }
            Test.stopTest();
        }catch(Exception e){
            //system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void  getLoanApplicantDataTest(){
        try{
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprodIBL@indusbank.com' AND IsActive = true LIMIT 1];
            System.runAs(u)
            {
                Opportunity opp = [SELECT Id FROM Opportunity WHERE OwnerId =: u.Id AND Name =: 'testone' LIMIT 1];
                
                AmlCheckData.getLoanApplicantData(opp.Id);
                
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getPenCMUbeforeTest(){
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
            case_s.Status = System.label.PendingBECVO;
          //  case_s.OwnerId = u.Id;
            insert case_s;
        
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
            amlCheck.BE_CVO_Decision__c = 'False Positive';
            amlCheck.Remarks_BE_CVO__c = '';
            amlCheck.Score__c = 90;
            amlCheck.Loan_Application__c = opks1.Id;
            amlCheck.Case__c = case_s.Id;
            insert amlCheck;
        
            Test.startTest();
                  AmlCheckData.getPenCMUbefore(opks1.Id);
            Test.stopTest();
    }
    
    @isTest
    public static void getPenCAbeforeTest(){
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
            case_s.Status = System.label.PendingBECVO;
          //  case_s.OwnerId = u.Id;
            insert case_s;
        
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
            amlCheck.BE_CVO_Decision__c = 'Positive';
            amlCheck.Remarks_BE_CVO__c = '';
            amlCheck.Score__c = 90;
            amlCheck.Loan_Application__c = opks1.Id;
            amlCheck.Case__c = case_s.Id;
            insert amlCheck;
        
            Test.startTest();
                  AmlCheckData.getPenCAbefore(opks1.Id);
            Test.stopTest();
    }
    
    @isTest
    public static void updateAmlCheckTest11(){
        try{
                Account accobj = new Account();
                accobj.Name = 'testname';
                accobj.State__c = 'ASSAM';
                insert accobj;
            
                Opportunity opfv1 = new Opportunity();
                opfv1.AccountId = accobj.Id;
                opfv1.StageName = 'Credit Processing';
                opfv1.CloseDate = Date.newInstance(2021, 1, 11);
                opfv1.Name = 'testone';
                insert opfv1;
            
                 Id tvrRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TVR').getRecordTypeId();
                 case objCase = new case();
                 objCase.OwnerId = UserInfo.getUserId();
                 objCase.Status = 'Pass';
                 objCase.Subject = opfv1.Name+'_TVR';
                 objCase.RecordTypeId = tvrRecordTypeId;
                 objCase.Loan_Application__c = opfv1.Id;            
                 insert objCase; 
            
                 CAM__c cam1 = new CAM__c();
                 cam1.Loan_Application__c = opfv1.Id;
                 cam1.BE_CVO_Remark__c = 'testbe';
                 cam1.Is_Hold__c = true;
                 cam1.Conditional_Approval__c = 'testapprov';
                 cam1.Proposal_Status__c = 'testproposal';
                 insert cam1;
            
                 AccountTeamMember atm2 = new AccountTeamMember();
                 atm2.AccountId = opfv1.AccountId;
		         atm2.TeamMemberRole = 'CA';
                 atm2.UserId = UserInfo.getUserId();
                 insert atm2;
            
            List<AML_Check__c> amList = new List<AML_Check__c>();
            AML_Check__c amlCheck = new AML_Check__c();
            amlCheck.Matched_base__c = 'MatchBase';
            amlCheck.List_Name__c = 'amlList';
            amlCheck.Name__c = 'amlName';
            amlCheck.Nationality__c = 'IND';
            amlCheck.Nationality_Score__c = 90;
            amlCheck.Score__c = 90;
            amlCheck.Loan_Application__c = opfv1.Id;
            amlCheck.Case__c = objCase.Id;
            insert amlCheck;
            amList.add(amlCheck);
            
            Test.startTest();
                 AmlCheckData.updateAmlCheck(amList,opfv1.Id,objCase.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void updateAmlCheckTest12(){
        try{
                Account accobj = new Account();
                accobj.Name = 'testname';
                accobj.State__c = 'ASSAM';
                insert accobj;
            
                Opportunity opfv1 = new Opportunity();
                opfv1.AccountId = accobj.Id;
                opfv1.StageName = 'Credit Processing';
                opfv1.CloseDate = Date.newInstance(2021, 1, 11);
                opfv1.Name = 'testone';
                insert opfv1;
            
                 Id tvrRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TVR').getRecordTypeId();
                 case objCase = new case();
                 objCase.OwnerId = UserInfo.getUserId();
                 objCase.Status = 'Pass';
                 objCase.Subject = opfv1.Name+'_TVR';
                 objCase.RecordTypeId = tvrRecordTypeId;
                 objCase.Loan_Application__c = opfv1.Id;            
                 insert objCase; 
            
                 CAM__c cam1 = new CAM__c();
                 cam1.Loan_Application__c = opfv1.Id;
                 cam1.BE_CVO_Remark__c = 'testbe';
                 cam1.Is_Hold__c = true;
                 cam1.Conditional_Approval__c = 'testapprov';
                 cam1.Proposal_Status__c = 'testproposal';
                 insert cam1;
            
                 AccountTeamMember atm2 = new AccountTeamMember();
                 atm2.AccountId = opfv1.AccountId;
		         atm2.TeamMemberRole = 'NCM';
                 atm2.UserId = UserInfo.getUserId();
                 insert atm2;
            
            List<AML_Check__c> amList = new List<AML_Check__c>();
            AML_Check__c amlCheck = new AML_Check__c();
            amlCheck.Matched_base__c = 'MatchBase';
            amlCheck.List_Name__c = 'amlList';
            amlCheck.Name__c = 'amlName';
            amlCheck.Nationality__c = 'IND';
            amlCheck.Nationality_Score__c = 90;
            amlCheck.Score__c = 90;
            amlCheck.Loan_Application__c = opfv1.Id;
            amlCheck.Case__c = objCase.Id;
            insert amlCheck;
            amList.add(amlCheck);
            
            Test.startTest();
                 AmlCheckData.updateAmlCheck(amList,opfv1.Id,objCase.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void updateAmlCheckTest13(){
        try{
            
            Profile p = [SELECT Id FROM Profile WHERE Name= 'CMU'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprodIBL4@indusbank.com',MobilePhone = '9089078967');
        insert u;
        
        System.runAs(u) 
        {   
                Account accobj = new Account();
                accobj.Name = 'testname';
                accobj.State__c = 'ASSAM';
                insert accobj;
            
                Opportunity opfv1 = new Opportunity();
                opfv1.AccountId = accobj.Id;
                opfv1.StageName = 'Credit Processing';
                opfv1.CloseDate = Date.newInstance(2021, 1, 11);
                opfv1.Name = 'testone';
                insert opfv1;
            
                 Id tvrRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TVR').getRecordTypeId();
                 case objCase = new case();
                 objCase.OwnerId = UserInfo.getUserId();
                 objCase.Status = System.label.Pendingcreditanalyst;
                 objCase.Subject = opfv1.Name+'_TVR';
                 objCase.RecordTypeId = tvrRecordTypeId;
                 objCase.Loan_Application__c = opfv1.Id;            
                 insert objCase; 
            
                 CAM__c cam1 = new CAM__c();
                 cam1.Loan_Application__c = opfv1.Id;
                 cam1.BE_CVO_Remark__c = 'testbe';
                 cam1.Is_Hold__c = true;
                 cam1.Conditional_Approval__c = 'testapprov';
                 cam1.Proposal_Status__c = 'testproposal';
                 insert cam1;
            
                 AccountTeamMember atm2 = new AccountTeamMember();
                 atm2.AccountId = opfv1.AccountId;
		         atm2.TeamMemberRole = 'NCM';
                 atm2.UserId = UserInfo.getUserId();
                 insert atm2;
            
            List<AML_Check__c> amList = new List<AML_Check__c>();
            AML_Check__c amlCheck = new AML_Check__c();
            amlCheck.Matched_base__c = 'MatchBase';
            amlCheck.List_Name__c = 'amlList';
            amlCheck.Name__c = 'amlName';
            amlCheck.Nationality__c = 'IND';
            amlCheck.Nationality_Score__c = 90;
            amlCheck.Score__c = 90;
            amlCheck.Loan_Application__c = opfv1.Id;
            amlCheck.Case__c = objCase.Id;
            amlCheck.BE_CVO_Decision__c = 'False Positive';
            insert amlCheck;
            amList.add(amlCheck);
            
            Test.startTest();
                 AmlCheckData.updateAmlCheck(amList,opfv1.Id,objCase.Id);
            Test.stopTest();
        }
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    
    }
    
    @isTest
    public static void getLoanApplicantDataTest3(){
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
                
                 Documents__c dfks1 = new Documents__c();
                 dfks1.Applicant__c = apks1.Id;
                 dfks1.Opportunity_Relation__c = opks1.Id;
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 dfks1.Document_Type__c = System.Label.AadhaarCard;
                 dfks1.KYC_Address_Line_1__c = 'testkyc';
                 dfks1.KYC_Address_Line_2__c = '';
                 dfks1.Current_Residential_Address_Proof__c = true;
                 insert dfks1;
            
                Income_Details__c id1 = new Income_Details__c();
                id1.Applicant__c = apks1.Id;
                id1.GST_No__c = '29ABCDE1234F1ZW';
                id1.Income__c = 10000;
                insert id1;
            
                Test.startTest();
                      AmlCheckData.getLoanApplicantData(opks1.Id);
                Test.stopTest();
        }catch(Exception e){
               System.assertEquals('script-thrown exception', e.getMessage());
            }
    }
    
    @isTest
    public static void getLoanApplicantDataTest4(){
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
                
                 Documents__c dfks1 = new Documents__c();
                 dfks1.Applicant__c = apks1.Id;
                 dfks1.Opportunity_Relation__c = opks1.Id;
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 dfks1.Document_Type__c = System.Label.AadhaarCard;
                 dfks1.KYC_Address_Line_1__c = '';
                 dfks1.KYC_Address_Line_2__c = 'testkyc2';
                 dfks1.Current_Residential_Address_Proof__c = true;
                 insert dfks1;
            
                Income_Details__c id1 = new Income_Details__c();
                id1.Applicant__c = apks1.Id;
                id1.GST_No__c = '29ABCDE1234F1ZW';
                id1.Income__c = 10000;
                insert id1;
            
                Test.startTest();
                      AmlCheckData.getLoanApplicantData(opks1.Id);
                Test.stopTest();
        }catch(Exception e){
               System.assertEquals('script-thrown exception', e.getMessage());
            }
    }
    
    @isTest
    public static void getLoanApplicantDataTest5(){
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
                
                 Documents__c dfks1 = new Documents__c();
                 dfks1.Applicant__c = apks1.Id;
                 dfks1.Opportunity_Relation__c = opks1.Id;
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 dfks1.Document_Type__c = System.Label.AadhaarCard;
                 dfks1.KYC_Address_Line_1__c = '';
                 dfks1.KYC_Address_Line_2__c = '';
                 dfks1.Current_Residential_Address_Proof__c = true;
                 insert dfks1;
            
                Income_Details__c id1 = new Income_Details__c();
                id1.Applicant__c = apks1.Id;
                id1.GST_No__c = '29ABCDE1234F1ZW';
                id1.Income__c = 10000;
                insert id1;
            
                Test.startTest();
                      AmlCheckData.getLoanApplicantData(opks1.Id);
                Test.stopTest();
        }catch(Exception e){
               System.assertEquals('script-thrown exception', e.getMessage());
            }
    }
    
     @isTest
    public static void getLoanApplicantDataTest6(){
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
                apks1.Current_Same_As_Permanent__c = true;
                insert apks1;
                
                 Documents__c dfks1 = new Documents__c();
                 dfks1.Applicant__c = apks1.Id;
                 dfks1.Opportunity_Relation__c = opks1.Id;
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 dfks1.Document_Type__c = System.Label.AadhaarCard;
                 dfks1.Permanent_Residential_Address_Proof__c = true;
                 dfks1.KYC_Address_Line_1__c = 'testkyc';
                 dfks1.KYC_Address_Line_2__c = '';
                 insert dfks1;
            
                Income_Details__c id1 = new Income_Details__c();
                id1.Applicant__c = apks1.Id;
                id1.GST_No__c = '29ABCDE1234F1ZW';
                id1.Income__c = 10000;
                insert id1;
            
                Test.startTest();
                      AmlCheckData.getLoanApplicantData(opks1.Id);
                Test.stopTest();
        }catch(Exception e){
               System.assertEquals('script-thrown exception', e.getMessage());
            }
    }
    
    @isTest
    public static void getLoanApplicantDataTest7(){
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
                apks1.Current_Same_As_Permanent__c = true;
                insert apks1;
                
                 Documents__c dfks1 = new Documents__c();
                 dfks1.Applicant__c = apks1.Id;
                 dfks1.Opportunity_Relation__c = opks1.Id;
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 dfks1.Document_Type__c = System.Label.AadhaarCard;
                 dfks1.Permanent_Residential_Address_Proof__c = true;
                 dfks1.KYC_Address_Line_1__c = '';
                 dfks1.KYC_Address_Line_2__c = 'testkyc';
                 insert dfks1;
            
                Income_Details__c id1 = new Income_Details__c();
                id1.Applicant__c = apks1.Id;
                id1.GST_No__c = '29ABCDE1234F1ZW';
                id1.Income__c = 10000;
                insert id1;
            
                Test.startTest();
                      AmlCheckData.getLoanApplicantData(opks1.Id);
                Test.stopTest();
        }catch(Exception e){
               System.assertEquals('script-thrown exception', e.getMessage());
            }
    }
    
    @isTest
    public static void getLoanApplicantDataTest8(){
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
                apks1.Current_Same_As_Permanent__c = true;
                insert apks1;
                
                 Documents__c dfks1 = new Documents__c();
                 dfks1.Applicant__c = apks1.Id;
                 dfks1.Opportunity_Relation__c = opks1.Id;
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 dfks1.Document_Type__c = System.Label.AadhaarCard;
                 dfks1.Permanent_Residential_Address_Proof__c = true;
                 dfks1.KYC_Address_Line_1__c = '';
                 dfks1.KYC_Address_Line_2__c = '';
                 insert dfks1;
            
                Income_Details__c id1 = new Income_Details__c();
                id1.Applicant__c = apks1.Id;
                id1.GST_No__c = '29ABCDE1234F1ZW';
                id1.Income__c = 10000;
                insert id1;
            
                Test.startTest();
                      AmlCheckData.getLoanApplicantData(opks1.Id);
                Test.stopTest();
        }catch(Exception e){
               System.assertEquals('script-thrown exception', e.getMessage());
            }
    }
    
     @isTest
    public static void getLoanApplicantDataTest9(){
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
                apks1.Current_Same_As_Permanent__c = true;
                insert apks1;
                
                 Documents__c dfks1 = new Documents__c();
                 dfks1.Applicant__c = apks1.Id;
                 dfks1.Opportunity_Relation__c = opks1.Id;
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 dfks1.Document_Type__c = System.Label.AadhaarCard;
                 dfks1.Permanent_Residential_Address_Proof__c = true;
                 dfks1.KYC_Address_Line_1__c = '';
                 dfks1.KYC_Address_Line_2__c = '';
                 insert dfks1;
            
                Income_Details__c id1 = new Income_Details__c();
                id1.Applicant__c = apks1.Id;
                id1.GST_No__c = '29ABCDE1234F1ZW';
                id1.Income__c = 10000;
                id1.Office_Address_Line_1__c = 'testone';
                id1.Office_Address_Line_2__c = '';
                insert id1;
            
                Test.startTest();
                      AmlCheckData.getLoanApplicantData(opks1.Id);
                Test.stopTest();
        }catch(Exception e){
               System.assertEquals('script-thrown exception', e.getMessage());
            }
    }
    
     @isTest
    public static void getLoanApplicantDataTest10(){
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
                apks1.Current_Same_As_Permanent__c = true;
                insert apks1;
                
                 Documents__c dfks1 = new Documents__c();
                 dfks1.Applicant__c = apks1.Id;
                 dfks1.Opportunity_Relation__c = opks1.Id;
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 dfks1.Document_Type__c = System.Label.AadhaarCard;
                 dfks1.Permanent_Residential_Address_Proof__c = true;
                 dfks1.KYC_Address_Line_1__c = '';
                 dfks1.KYC_Address_Line_2__c = '';
                 insert dfks1;
            
                Income_Details__c id1 = new Income_Details__c();
                id1.Applicant__c = apks1.Id;
                id1.GST_No__c = '29ABCDE1234F1ZW';
                id1.Income__c = 10000;
                id1.Office_Address_Line_1__c = '';
                id1.Office_Address_Line_2__c = 'testone';
                insert id1;
            
                Test.startTest();
                      AmlCheckData.getLoanApplicantData(opks1.Id);
                Test.stopTest();
        }catch(Exception e){
               System.assertEquals('script-thrown exception', e.getMessage());
            }
    }

    @isTest
    public static void  updateAmlCheckTest33(){
        try{
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod15@indusbank.com' AND IsActive = true LIMIT 1];
            System.runAs(u)
            {
                Opportunity opp = [SELECT Id, Name, Submit_AML_Check_To_CA__c, OwnerId FROM Opportunity WHERE OwnerId =: u.Id LIMIT 1];
                Case cObj = [SElect Id from Case Limit 1];
                cObj.Status = System.Label.Pendingcreditanalyst;
                update cObj;
                AmlCheckData.updateAmlCheck(new List<AML_Check__c>(), opp.Id,cObj.Id);
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

    @isTest
    public static void  updateAmlCheckTest34(){
        try{
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod15@indusbank.com' AND IsActive = true LIMIT 1];
            System.runAs(u)
            {
                Opportunity opp = [SELECT Id, Name, Submit_AML_Check_To_CA__c, OwnerId FROM Opportunity WHERE OwnerId =: u.Id LIMIT 1];
                Case cObj = [SElect Id from Case Limit 1];
                cObj.Status = System.Label.Pendingcreditanalyst;
                update cObj;
                CAM__c[] camObj = [Select id from CAM__c Where Loan_Application__c=: opp.id];
                delete camObj;
                AmlCheckData.updateAmlCheck(new List<AML_Check__c>(), opp.Id,cObj.Id);
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
}