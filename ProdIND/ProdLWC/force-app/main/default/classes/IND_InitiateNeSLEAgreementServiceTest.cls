/*------------------------------------------------------------
Author:        Yugandhar
Company:       Persistent Systems
Description:   Test class created to validate the IND_InitiateNeSLEAgreementRequest IND_InitiateNeSLEAgreementService IND_InitiateNeSLEAgreementResponse class
History
Date            Author              Comments
-------------------------------------------------------------
30-12-2021      Yugandhar       Created
------------------------------------------------------------*/

@isTest(SeeAllData=false)
public class IND_InitiateNeSLEAgreementServiceTest {    
    @TestSetup
    public static void createTestData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          MobilePhone = '9701498575', IsActive = true,
                          UserName='standarduser4@testorg.com.psdev1',Maker_Id__c='10002');

             // Create Opportunity            
             Opportunity oppo = new Opportunity();
             oppo.Sub_Stage__c = System.Label.Field_Investigation;
             oppo.Is_Mobile_Journey_Completed__c = true;
             oppo.Vehicle_Type__c = System.Label.used;
             oppo.Product_Type__c = System.Label.TwoWheeler;
             oppo.Sanction_Status__c = 'STP';
             oppo.AML_Check_status__c ='Rejected';
             oppo.Lead_Number__c='L-10122021-1685';
             oppo.Whatsapp_number__c='1231231231';
             oppo.Contact_number__c = '9743514830';
             oppo.Deal_Number__c = 'Deal Number';
             oppo.StageName = 'Closed won';
             oppo.CloseDate = system.today();
             oppo.Name = 'abc';
             insert oppo; 
             //Create Applicant__c Data            
             Applicant__c applicants = new Applicant__c();
             applicants.Contact_number__c = '9876543456' ;
             applicants.OTP_for_borrower__c = '9999';
             applicants.Opportunity__c=oppo.Id;
             applicants.Customer_Code__c = 'CW1330664';
             applicants.Name = 'test';
             applicants.Gender__c = 'MALE';
             applicants.Profile__c = 'Un-Employed';
             applicants.Communication_language__c = 'Hindi';
             applicants.Customer_Qualification__c = 'B1';
             applicants.Father_s_name__c = 'Viraa';
             applicants.Mother_s_name__c = 'Neeta';
             applicants.Spouse_Name__c = 'Sameer';
             applicants.Email_Id__c = 'riya@gmail.com';
             applicants.Aadhar_No__c = '363155436548';
             applicants.Voter_ID_No__c = 'ANDR435435';
             applicants.Driving_License_No__c = 'FDG3435253';
             applicants.Customer_First_Name__c='GOURAB';
             applicants.Customer_Last_Name__c = 'GOSWAMI';
             applicants.Legal_Entity_Identifier__c = 'Individual';
             applicants.Marital_status__c = 'MARR';
             applicants.Whatsapp_number__c = '1231231231';
             insert applicants;
        
             
 

        insert u;
        System.runAs(u) 
        {
            Opportunity opp = TestDataUtility.createTestLoanApplication(false);
            opp.Product_Type__c = 'Tractor';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }  
            
            Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
            dlNumberSetting.Name = System.Label.Tractor;
            dlNumberSetting.MDNField1__c ='AB';
            dlNumberSetting.MDNField2__c =2;
            insert dlNumberSetting;
            system.debug('Deal Setting'+ dlNumberSetting);
            
            Deal_Number__c dl = new Deal_Number__c();
            dl.Loan_Application__c = opp.Id;
            dl.DNField1__c = dlNumberSetting.MDNField1__c;
            dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c);
            dl.Sub_Stage__c = 'Payment Request';
            insert dl;
                
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
        }
    }
    
    
    @isTest
    public static void testIND_InitiateNeSLEAgreementService(){
        
        try{   
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {                 
               // Applicant__c appRec = [SELECT Id, Opportunity__c FROM Applicant__c LIMIT 1]; 
               Applicant__c app = [SELECT Id,Contact_number__c,OTP_for_borrower__c,Opportunity__r.Lead_number__c,
               Customer_Code__c,Name,Gender__c,Profile__c,Communication_language__c,
               Customer_Qualification__c,Father_s_name__c,Mother_s_name__c,Spouse__c,
               Aadhar_No__c,Voter_ID_No__c,Driving_License_No__c,Customer_Last_Name__c,Opportunity__r.CreatedById,
               Marital_status__c,Opportunity__r.Contact_number__c, Opportunity__r.Whatsapp_number__c
               FROM Applicant__c LIMIT 1];
                
                Deal_Number__c dl = [SELECT Id FROM Deal_Number__c LIMIT 1];
                
               // Continuation con = (Continuation)IntegrationEngine.doInitiateNESLCallout(appRec.Id,appRec.Opportunity__c,'Test');
                 Continuation con = (Continuation)IntegrationEngine.doInitiateNESLCallout(app.Id,app.Opportunity__c,'Test',dl.Id);
                // Create a mock response
                HttpResponse response = new HttpResponse();
                response.setBody('{"JData":"ZDZLaZ7+UUMMs4Qd+iREtdWeFfrDRGgw2H+mOgt5vpKuXk32ppIQxD8F4XSCvS7kZrOdcPXjKDWxwDzv9Wc304mRhzB0louiZAuuFedd1Z1YC0Iy3jakQV+C0Zz4LRR57/pPVuRIFIK5Xy4wvUl7NdbqyfaWXQqrwpyHG8R/dqGyo0yIy2RC44CbGU99M5amoAlm9ZGVozmni0P6JsQ1wNrW/HTC/RZcgueHmPFe20SsPhYQmmBPDyqQ8WdCTiAFssun8wTo7qlYFvih7upLDl5TKctReaIVn+UU07IC7m9P/KXJaD5ueaUUiesHeRaRzeM4dcD/nqIHU2PxG50B9GX9ThAku5oXHsRnfH6KpCKdA1myOfTkUCfAHpMOeZqx5+GtvCxNWPY8aOSHoORSg52aQTXI7v8Of5rDzWs1KcwW20OA3ROHbJIZPxDiOBd5I8511x98/Mk3CyBaU916TQ=="}');
                response.setStatusCode(200);
                
                String continuationLabel = IntegrationEngine.continuationLabel;
                List<String> labels = new List<String>{continuationLabel};
                    Object continuationState= IntegrationEngine.continuationState;
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                String initiateNeSLCallOutResponse= (String)IntegrationEngine.processInitiateNESLCalloutAPIResponse(labels, IntegrationEngine.continuationState);
                Test.stopTest();
                String responseExpected ='{"body":null,"response":{"status":"SUCCESS","respDesc":"Initiate NESL-E Agreement","content":[{"Status_Description":null,"Status_Code":null,"ResURL":"https://loans.indusind.com/NeSLApp/NeSL/NeSL?TrnId=G9ZS8cYSa6AcC67WaoUT9vBb1c6yoy_9O9kLgsAs-zR7o2WEiLFFQtMKRCgfYmbW","res":"SUCCESS","Esign_Link":null}]}}';
                System.assertEquals(responseExpected, initiateNeSLCallOutResponse);
            }
            
        } catch(Exception ex){
            System.debug('ex'+ex.getMessage());
        }
    }
    
    @isTest
    public static void testIND_InitiateNeSLEAgreementService2(){
        
        try{   
            
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {                                 
                //Continuation con = (Continuation)IntegrationEngine.doInitiateNESLCallout(applicant.Id,opp.Id);
                // Create a mock response
                HttpResponse response = new HttpResponse();
                response.setBody('{"JData":"ZDZLaZ7+UUMMs4Qd+iREtdWeFfrDRGgw2H+mOgt5vpKuXk32ppIQxD8F4XSCvS7kZrOdcPXjKDWxwDzv9Wc304mRhzB0louiZAuuFedd1Z1YC0Iy3jakQV+C0Zz4LRR57/pPVuRIFIK5Xy4wvUl7NdbqyfaWXQqrwpyHG8R/dqGyo0yIy2RC44CbGU99M5amoAlm9ZGVozmni0P6JsQ1wNrW/HTC/RZcgueHmPFe20SsPhYQmmBPDyqQ8WdCTiAFssun8wTo7qlYFvih7upLDl5TKctReaIVn+UU07IC7m9P/KXJaD5ueaUUiesHeRaRzeM4dcD/nqIHU2PxG50B9GX9ThAku5oXHsRnfH6KpCKdA1myOfTkUCfAHpMOeZqx5+GtvCxNWPY8aOSHoORSg52aQTXI7v8Of5rDzWs1KcwW20OA3ROHbJIZPxDiOBd5I8511x98/Mk3CyBaU916TQ=="}');
                response.setStatusCode(200);
                
                String continuationLabel = IntegrationEngine.continuationLabel;
                List<String> labels = new List<String>{continuationLabel};
                    Object continuationState= IntegrationEngine.continuationState;
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                String initiateNeSLCallOutResponse = (String)IntegrationEngine.processInitiateNESLCalloutAPIResponse(labels, IntegrationEngine.continuationState);
                Test.stopTest();
                String responseExpected ='{"body":null,"response":{"status":"SUCCESS","respDesc":"Initiate NESL-E Agreement","content":[{"Status_Description":null,"Status_Code":null,"ResURL":"https://loans.indusind.com/NeSLApp/NeSL/NeSL?TrnId=G9ZS8cYSa6AcC67WaoUT9vBb1c6yoy_9O9kLgsAs-zR7o2WEiLFFQtMKRCgfYmbW","res":"SUCCESS","Esign_Link":null}]}}';
                System.assertEquals(responseExpected, initiateNeSLCallOutResponse);
            }
        } catch(Exception ex){
             System.debug('ex'+ex.getMessage());
        }
    }        
    
    @isTest
    public static void testIND_InitiateNeSLEAgreementResponse(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {         
            Test.startTest();
            Applicant__c appRec = [SELECT Id, Opportunity__c FROM Applicant__c LIMIT 1];
            IND_InitiateNeSLEAgreementResponse initiateNeSLResponse = new IND_InitiateNeSLEAgreementResponse();
            IND_InitiateNeSLEAgreementResponse.ResponseData response = new IND_InitiateNeSLEAgreementResponse.ResponseData();
            response.status = '200';
            response.respDesc = 'Test';
            IND_InitiateNeSLEAgreementResponse.Content content = new IND_InitiateNeSLEAgreementResponse.Content();
            content.Esign_Link = 'Test';
            content.res = 'Test';
            content.ResURL = 'Test';
            content.Status_Code = 'Test';
            content.Status_Description = 'Test';
            response.content = new List<IND_InitiateNeSLEAgreementResponse.Content>{content};
                initiateNeSLResponse.response = response;
            System.assertEquals(initiateNeSLResponse.response.status, '200');
            Test.stopTest();
        }
    }  
    
    @isTest
    public static void testIND_InitiateNeSLEAgreementServiceExceptionTest(){
        
        User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {                 
            Applicant__c appRec = [SELECT Id, Opportunity__c FROM Applicant__c LIMIT 1];
            Deal_Number__c dl = [Select Id from Deal_Number__c LIMIT 1];
            
            try{   
                Test.startTest();
                IND_InitiateNeSLEAgreementService.induceException = true;
                IND_InitiateNeSLEAgreementService.getInitiateNeSLEAgreementRequest(appRec,appRec.Opportunity__c,'Test',dl.Id);
                Test.stopTest();
            } catch(Exception ex){
                System.debug('ex'+ex.getMessage());
            }
        }
    }
}