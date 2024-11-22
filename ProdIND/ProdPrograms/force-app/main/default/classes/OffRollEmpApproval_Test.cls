@isTest(seeAllData = false)
public class OffRollEmpApproval_Test {	
    
    @testSetup static void testDataSetup() 
    {
        //Create User     
        Contact con = TestDataUtility.createTestContact(true);
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Partner Community Counter Staff'];     
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',MobilePhone = '9999999999',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles', ContactId = con.Id,
                          UserName='test_userprod123987654735353@indusbank.com');
        insert u;
        
        Profile p1 = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];    
        User u1 = new User(Alias = 'standt1', Email='standarduser1@testorg.com',MobilePhone = '9999999999',
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p1.Id,Maker_Id__c='12',IsActive = true,
                           TimeZoneSidKey='America/Los_Angeles',UserName='test_user@abc1.com');
        insert u1;
        
        Profile p2 = [SELECT Id FROM Profile WHERE Name='IBL Marketing Officer'];
        User u2 = new User(Alias = 'standt2', Email='standarduser2@testorg.com',MobilePhone = '9999999999',
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p2.Id,Maker_Id__c='12',IsActive = true,
                           TimeZoneSidKey='America/Los_Angeles',UserName='test_user@abc2.com');
        insert u2;
        
        Profile p3 = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u3 = new User(Alias = 'standt3', Email='standarduser3@testorg.com',MobilePhone = '9999999999',
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p3.Id,Maker_Id__c='12',IsActive = true,
                           TimeZoneSidKey='America/Los_Angeles',UserName='test_user@abc3.com');
        insert u3;
        
        List<AccountTeamMember> acTMList = new List<AccountTeamMember>();
        System.runAs(u) 
        {
            //Create Account
            Account acc = TestDataUtility.createTestAccount(true);           
            
            //Create Account Team Member         
            AccountTeamMember acTM1 = new AccountTeamMember(AccountId = acc.Id, UserId = u1.Id, TeamMemberRole = 'BE');
            AccountTeamMember acTM2 = new AccountTeamMember(AccountId = acc.Id, UserId = u2.Id, TeamMemberRole = 'MO');
            AccountTeamMember acTM3 = new AccountTeamMember(AccountId = acc.Id, UserId = u3.Id, TeamMemberRole = 'PE');
            acTMList.add(acTM1);
            acTMList.add(acTM2);
            acTMList.add(acTM3);         
            
            // Create Opportunity
            Opportunity opp = TestDataUtility.createTestOpportunityForOcr(false);         
            opp.Sub_Stage__c = System.Label.Field_Investigation;
            opp.Is_Mobile_Journey_Completed__c = true;
            opp.Vehicle_Type__c = System.Label.used;
            opp.Product_Type__c = System.Label.TwoWheeler;
            opp.Sanction_Status__c = System.Label.nonStp;         
            opp.AccountId = acc.Id;
            opp.ownerId = u.Id;
            insert opp;
            
            // Create Applicant__c
            Applicant__c applicant = TestDataUtility.createTestApplicantForMFCValuation(true, opp);
            
            // Create Vehicle Detail
            Vehicle_Detail__c vehDet = TestDataUtility.createTestVehicleDetailForMFCValuation(true, opp);
            
            // Create Documents__c
            List<Documents__c> docList = new List<Documents__c>();
            Documents__c doc1 = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant, opp);
            doc1.Document_Type__c = System.Label.AadhaarCard;
            doc1.Addresss_Type__c = System.Label.Document_Office_Address_Type;
            doc1.Aadhar_Source__c = 'OTP';   
            doc1.Opportunity_Relation__c = opp.Id;
            doc1.is_Active__c = true;
            docList.add(doc1);
            
            Documents__c doc2 = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant, opp);
            doc2.Document_Type__c = System.Label.AadhaarCard;
            doc2.Addresss_Type__c = System.Label.Document_Office_Address_Type;
            doc2.Aadhar_Source__c = 'OTP';  
            doc2.Opportunity_Relation__c = opp.Id;
            doc2.is_Active__c = true;
            docList.add(doc2);
            insert docList;
            
            // Create Case
            Case cse = TestDataUtility.createTestCase(false, opp, applicant);
            cse.Type = System.Label.Case_Office_FI_Type;            
            insert cse;
            
            // Create Field Investigation
            Field_Investigation__c fiRecord = TestDataUtility.createTestFieldInvestigation(false, cse);
            fiRecord.FI_Feedback__c = '0';
            insert fiRecord;
        }
        System.runAs(u1) 
        {                            
            // Create Opportunity
            Opportunity opp1 = TestDataUtility.createTestOpportunityForOcr(false);         
            opp1.Sub_Stage__c = System.Label.Field_Investigation;
            opp1.Is_Mobile_Journey_Completed__c = true;
            opp1.Vehicle_Type__c = System.Label.used;
            opp1.Product_Type__c = System.Label.TwoWheeler;
            opp1.Sanction_Status__c = System.Label.nonStp;                     
            insert opp1;
            
            // Create Applicant__c
            Applicant__c applicant1 = TestDataUtility.createTestApplicantForMFCValuation(true, opp1);

            // Create Case
            Case cse = TestDataUtility.createTestCase(false, opp1, applicant1);
            cse.Type = System.Label.Case_Office_FI_Type;            
            insert cse;               
        }
        insert acTMList;
    }     
    
    @isTest 
    public static void UpdateFieldsOnConfirmationTest()
    {
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_user@abc1.com' AND IsActive = true LIMIT 1];         
        System.runAs(u) 
        {
            try
            {                
                Case cse = [SELECT Id, OwnerId FROM Case WHERE OwnerId =: u.Id LIMIT 1];                
                Test.startTest();
                OffRollEmpApproval.UpdateFieldsOnConformation(cse.id);
                Test.stopTest();
                OffRollEmpApproval.UpdateFieldsOnConformation(null); 
                Case cseUpdated = [SELECT Id, Status, OwnerId FROM Case WHERE OwnerId =: u.Id LIMIT 1]; 
                System.assertEquals('Closed', cseUpdated.Status);
            }
            catch(Exception e)
            {
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }        
    } 
    
    @isTest 
    public static void checkCaseTest()
    {
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_user@abc1.com' AND IsActive = true LIMIT 1];         
        System.runAs(u) 
        {
            try
            {                
                Opportunity opp = [SELECT Id, OwnerId FROM Opportunity WHERE OwnerId =: u.Id LIMIT 1];                
                Test.startTest();
                Boolean result1 = OffRollEmpApproval.checkCase(opp.id);   
                Boolean result2 = OffRollEmpApproval.checkCase(null); 
                Test.stopTest();                     
                System.assertEquals(true, result1);
                System.assertEquals(false, result2);
            }
            catch(Exception e)
            {
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }        
    } 
    
    @isTest 
    public static void createCaseTest1()
    {        
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123987654735353@indusbank.com' AND IsActive = true LIMIT 1];
        Opportunity oppRec = [SELECT Id, ownerId, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1];
        AccountTeamMember userMember = [SELECT Id, UserId, User.userType, TeamMemberRole FROM AccountTeamMember WHERE TeamMemberRole = 'PE' AND User.UserType != 'PowerPartner' AND User.isActive = true LIMIT 1];
        System.debug(u);
        System.runAs(u) 
        {
            try
            {                
                Test.startTest();
                OffRollEmpApproval.createCase(oppRec.Id,'Two Wheeler',oppRec.ownerId);
                Test.stopTest();
                userMember.TeamMemberRole = 'RPM';
                update userMember;
                OffRollEmpApproval.createCase(oppRec.Id,'Two Wheeler',oppRec.ownerId);
            }
            catch(Exception e)
            {
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }        
    }
    
    @isTest 
    public static void createCaseTest2()
    {        
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123987654735353@indusbank.com' AND IsActive = true LIMIT 1];
        Opportunity oppRec = [SELECT Id, Vehicle_Type__c,ownerId, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1];
        AccountTeamMember userMember = [SELECT Id, UserId, User.userType, TeamMemberRole FROM AccountTeamMember WHERE TeamMemberRole = 'PE' AND User.UserType != 'PowerPartner' AND User.isActive = true LIMIT 1];
        
        System.runAs(u) 
        {
            try
            {                
                Test.startTest();
                OffRollEmpApproval.createCase(oppRec.Id,'Passenger Vehicles',oppRec.ownerId);
                Test.stopTest();
                userMember.TeamMemberRole = 'SH';
                update userMember;
                OffRollEmpApproval.createCase(oppRec.Id,'Two Wheeler',oppRec.ownerId);
            }
            catch(Exception e)
            {
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }        
    }
    
    @isTest 
    public static void createCaseTest3()
    {        
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123987654735353@indusbank.com' AND IsActive = true LIMIT 1];
        Opportunity oppRec = [SELECT Id, Vehicle_Type__c,ownerId, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1];
        AccountTeamMember userMember = [SELECT Id, UserId, User.userType, TeamMemberRole FROM AccountTeamMember WHERE TeamMemberRole = 'PE' AND User.UserType != 'PowerPartner' AND User.isActive = true LIMIT 1];
        
        System.runAs(u) 
        {
            try
            {                
                Test.startTest();
                OffRollEmpApproval.createCase(oppRec.Id,'Tractor',oppRec.ownerId);
                Test.stopTest();
                userMember.TeamMemberRole = 'SH';
                update userMember;
                OffRollEmpApproval.createCase(oppRec.Id,'Two Wheeler',oppRec.ownerId);
            }
            catch(Exception e)
            {
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }          
    }
         
}