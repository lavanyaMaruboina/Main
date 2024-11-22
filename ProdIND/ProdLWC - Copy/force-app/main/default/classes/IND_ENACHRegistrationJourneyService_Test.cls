/*------------------------------------------------------------
Author:        Bondiga Thilak
Company:       Persistent Systems ss
Description:   Test class for IND_LTVEngineRequest class 
Apex Class:    IND_LTVEngineRequest
History
Date            Author              Comments
-------------------------------------------------------------
12-22-2021      Bondiga Thilak       Created
------------------------------------------------------------*/
@isTest
public class IND_ENACHRegistrationJourneyService_Test {
    @TestSetup
    public static void createTestData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          MobilePhone = '9701498575', IsActive = true,
                          UserName='standarduser4@testorg.com.psdev1',Maker_Id__c='10002');
        insert u;
        System.runAs(u) 
        {
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }        
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            Bank_Masters__c bankMaster = new Bank_Masters__c();
            bankMaster.Name='BANK OF BARODA';
            bankMaster.Bank_Code__c=12;
            if (Schema.sObjectType.Bank_Masters__c.isCreateable()){
                insert bankMaster;
            }
            Repayments__c repayment = TestDataUtility.createTestRepayments(false,opp);
            repayment.Bank_Master__c = bankMaster.Id;
            repayment.Is_Netbanking_available_with_customer__c = 'yes';
            if (Schema.sObjectType.Repayments__c.isCreateable()){
                insert repayment;
            }
            
            Repayments__c repayment1 = TestDataUtility.createTestRepayments1(false,opp);
            repayment1.Bank_Master__c = bankMaster.Id;
            repayment1.Is_Netbanking_available_with_customer__c = 'no';
            if (Schema.sObjectType.Repayments__c.isCreateable()){
                insert repayment1;
            }
            
            Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
            dlNumberSetting.Name = System.Label.TwoWheeler;
            dlNumberSetting.MDNField1__c ='AB';
            dlNumberSetting.MDNField2__c = 2.0;
            insert dlNumberSetting;
            
            Deal_Number__c dl=new Deal_Number__c();
            dl.Loan_Application__c = opp.Id;
            dl.DNField1__c = dlNumberSetting.MDNField1__c;
            dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c.round());
            dl.Sub_Stage__c = 'RC Upload'; 
            insert dl;
            
            List<Exposure__c> lstExp = new List<Exposure__c>();
            lstExp.add(new Exposure__c(Name = 'expName',
                                           Loan_Application__c = opp.id,
                                           Applicant__c = applicant.id,
                                           CIF_ID__c ='3534534',
                                           Deal_No__c = 'something1'
                                          ));
            insert lstExp;
        }
    }
    
    // @Method:     TestServiceMetthod
    // @Created by: Bondiga Thilak
    // @Description:Test setup method to create the test data for IND_LTVEngineRequest classs
    // @Param:      ''  
    // @Return:     ''  
    @isTest
    public static void testENACHRegistrationJourney(){
        try{
            //Test.setMock(HttpCalloutMock.class, new SMSHttpCalloutMock());
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {                
                Applicant__c applicant = [SELECT Id, Opportunity__c FROM Applicant__c LIMIT 1];                 
                Deal_Number__c dealNumber = [SELECT Id FROM Deal_Number__c LIMIT 1];
                IND_ENACHRegistrationJourneyRequest.Payload reqPayload=new IND_ENACHRegistrationJourneyRequest.Payload();
                
                Continuation con = (Continuation)IntegrationEngine.doRegistrationJourneyCallout(applicant.Id,applicant.Opportunity__c,dealNumber.Id);
                
                // Map<String, HttpRequest> requests = con.getRequests();
                //system.assert(requests.size() == 1);
                // Create a mock response
                HttpResponse response = new HttpResponse();
                response.setBody('JData":"hq4eMrxnKLz2HfgB9zv+2eX6uBjGx2BRTHdxw2pnBpIYyMbJ9wqFTCMmhtItLSRA9jXYa0CSfGne1pI31MfjOJi/tKpT2oYP6d0yUNTKtNRkszrwrRvaDZScz8QZ3oZOgOg2zebV8fmgRvBvHSeCYpqt/Yfi6fAowyHf9tawBMboqy+qFrvBnIRByrum/7U1chyRLBLeUm9lf2po9pPV6x7mPALc3GfbJpCTYs3VG8lZtRIF4JPz5R56p+LG06BwsNSX3dB8amhlXMOENfymjYZjqjLB/QnWbfVMvjx4AfR26FmDKc3j4xVtj3R6JQtrR228TnnnfcLYSLUr4fzfawx2VFQio7l5cl5z3BRQebiWc86CcHVamOUzqRJ/kKIjVx/buSq46AuQGKdkXZg1BCAh/J54rKYHYiJU4nGOD7BcVAJjGh/ES9iKRzkFPaGVn8YFhHWZzFytnfp4rJ4Bg2nA6/KM3akymF08qXNWrBz5zCd0NZ7F+WozMI7Tzjdm6RzI4SoIyTJlQJKLErGmj1QOQgEe8JtWnpq/DjYZhJtrSFAuZXJjyO40G8NmgtFJssCMb0MveRhhmQE3nCO/hQEpgDxsmVoQ1NxnFhxWbYQijMKgp5ISnXlg0wf0zf22KfcQXaUei3apA7gIa/sOF0segSo4kCNqptQpIKoJ3MLCn0xuWc2Cwu8rQvthdhLqC/qTOivZDAXW1T48EopO1BsC4Lopo/56ZKFLSQaMOoLCfQCwztBWnnwVtm+Hd8Vpno4q6LdUHmevGx7jUphL1nPggyjOGTKQXJR2stNgwk7tFTPpZ3+yq86kwfEXsP++iJBBVNhF9PTTXkXordtNQmxyVIKL7cA/bm/u1ujkdNkRc80/HwKbA1qOb1XRYnxlCoJ9U0bs9+8f1aKsRYZPIr6JgPpBQdIQ0Q+5/wK743pM2rtWFRbpG/M4iQmHFUg54hlBB6OMUpykNotvSzfEU4ubRxE2lvV1LYpNL635s3UUNiMa9YnnVt4RvMIayEt4RFTWG/F21f47R4rSXds/sJ258PPVAHA005s6qRqb72dzLwdRxC1VpHrOTJ1rgwZk');            
                response.setStatusCode(200);
                
                String continuationLabel = IntegrationEngine.continuationLabel;
                List<String> labels = new List<String>{continuationLabel};
                    Object continuationState= IntegrationEngine.continuationState;   
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                String membershipResponse = (String)IntegrationEngine.processRegistrationJourneyAPIResponse(labels, IntegrationEngine.continuationState);
                Test.stopTest();
                String responseExpected ='{ "Session_Id": "06012022165122436", "Resp_Code": "200", "Resp_Message": "DB Action Success", "Registration_Url": "http://bankuat.indusind.com/content/cfdenach/sso/06012022165122436" }';
                System.assertEquals(responseExpected, membershipResponse);
            }
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Script-thrown exception');
        }
    }
    @isTest
    public static void testENACHRegistrationJourney2(){
        try{
            //Test.setMock(HttpCalloutMock.class, new SMSHttpCalloutMock());
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {                
                Applicant__c applicant = [SELECT Id, Opportunity__c FROM Applicant__c LIMIT 1];   
                 Deal_Number__c dealNumber = [SELECT Id FROM Deal_Number__c LIMIT 1];
                Continuation con = (Continuation)IntegrationEngine.doRegistrationJourneyCallout(applicant.Id,applicant.Opportunity__c,dealNumber.Id);
                
                //Map<String, HttpRequest> requests = con.getRequests();
                //system.assert(requests.size() == 1);
                // Create a mock response
                HttpResponse response = new HttpResponse();
                response.setBody('JData":"hq4eMrxnKLz2HfgB9zv+2eX6uBjGx2BRTHdxw2pnBpIYyMbJ9wqFTCMmhtItLSRA9jXYa0CSfGne1pI31MfjOJi/tKpT2oYP6d0yUNTKtNRkszrwrRvaDZScz8QZ3oZOgOg2zebV8fmgRvBvHSeCYpqt/Yfi6fAowyHf9tawBMboqy+qFrvBnIRByrum/7U1chyRLBLeUm9lf2po9pPV6x7mPALc3GfbJpCTYs3VG8lZtRIF4JPz5R56p+LG06BwsNSX3dB8amhlXMOENfymjYZjqjLB/QnWbfVMvjx4AfR26FmDKc3j4xVtj3R6JQtrR228TnnnfcLYSLUr4fzfawx2VFQio7l5cl5z3BRQebiWc86CcHVamOUzqRJ/kKIjVx/buSq46AuQGKdkXZg1BCAh/J54rKYHYiJU4nGOD7BcVAJjGh/ES9iKRzkFPaGVn8YFhHWZzFytnfp4rJ4Bg2nA6/KM3akymF08qXNWrBz5zCd0NZ7F+WozMI7Tzjdm6RzI4SoIyTJlQJKLErGmj1QOQgEe8JtWnpq/DjYZhJtrSFAuZXJjyO40G8NmgtFJssCMb0MveRhhmQE3nCO/hQEpgDxsmVoQ1NxnFhxWbYQijMKgp5ISnXlg0wf0zf22KfcQXaUei3apA7gIa/sOF0segSo4kCNqptQpIKoJ3MLCn0xuWc2Cwu8rQvthdhLqC/qTOivZDAXW1T48EopO1BsC4Lopo/56ZKFLSQaMOoLCfQCwztBWnnwVtm+Hd8Vpno4q6LdUHmevGx7jUphL1nPggyjOGTKQXJR2stNgwk7tFTPpZ3+yq86kwfEXsP++iJBBVNhF9PTTXkXordtNQmxyVIKL7cA/bm/u1ujkdNkRc80/HwKbA1qOb1XRYnxlCoJ9U0bs9+8f1aKsRYZPIr6JgPpBQdIQ0Q+5/wK743pM2rtWFRbpG/M4iQmHFUg54hlBB6OMUpykNotvSzfEU4ubRxE2lvV1LYpNL635s3UUNiMa9YnnVt4RvMIayEt4RFTWG/F21f47R4rSXds/sJ258PPVAHA005s6qRqb72dzLwdRxC1VpHrOTJ1rgwZk');            
                response.setStatusCode(200);
                
                String continuationLabel = IntegrationEngine.continuationLabel;
                List<String> labels = new List<String>{continuationLabel};
                    Object continuationState= IntegrationEngine.continuationState;   
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                String membershipResponse = (String)IntegrationEngine.processRegistrationJourneyAPIResponse(labels, IntegrationEngine.continuationState);
                Test.stopTest();
                String responseExpected ='{"body":null,"response":null}';
                System.assertEquals(responseExpected, membershipResponse);
            }
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Script-thrown exception');
        }
    }
    
    @isTest
    public static void testENACHRegistrationJourney3(){
        try{
            //Test.setMock(HttpCalloutMock.class, new SMSHttpCalloutMock());
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {                
                Applicant__c applicant = [SELECT Id, Opportunity__c FROM Applicant__c LIMIT 1];   
                 Deal_Number__c dealNumber = [SELECT Id FROM Deal_Number__c LIMIT 1];
                Continuation con = (Continuation)IntegrationEngine.doRegistrationJourneyCallout(applicant.Id,applicant.Opportunity__c,dealNumber.Id);
                
                //Map<String, HttpRequest> requests = con.getRequests();
                //system.assert(requests.size() == 1);
                // Create a mock response
                HttpResponse response = new HttpResponse();
                response.setBody('JData":"hq4eMrxnKLz2HfgB9zv+2eX6uBjGx2BRTHdxw2pnBpIYyMbJ9wqFTCMmhtItLSRA9jXYa0CSfGne1pI31MfjOJi/tKpT2oYP6d0yUNTKtNRkszrwrRvaDZScz8QZ3oZOgOg2zebV8fmgRvBvHSeCYpqt/Yfi6fAowyHf9tawBMboqy+qFrvBnIRByrum/7U1chyRLBLeUm9lf2po9pPV6x7mPALc3GfbJpCTYs3VG8lZtRIF4JPz5R56p+LG06BwsNSX3dB8amhlXMOENfymjYZjqjLB/QnWbfVMvjx4AfR26FmDKc3j4xVtj3R6JQtrR228TnnnfcLYSLUr4fzfawx2VFQio7l5cl5z3BRQebiWc86CcHVamOUzqRJ/kKIjVx/buSq46AuQGKdkXZg1BCAh/J54rKYHYiJU4nGOD7BcVAJjGh/ES9iKRzkFPaGVn8YFhHWZzFytnfp4rJ4Bg2nA6/KM3akymF08qXNWrBz5zCd0NZ7F+WozMI7Tzjdm6RzI4SoIyTJlQJKLErGmj1QOQgEe8JtWnpq/DjYZhJtrSFAuZXJjyO40G8NmgtFJssCMb0MveRhhmQE3nCO/hQEpgDxsmVoQ1NxnFhxWbYQijMKgp5ISnXlg0wf0zf22KfcQXaUei3apA7gIa/sOF0segSo4kCNqptQpIKoJ3MLCn0xuWc2Cwu8rQvthdhLqC/qTOivZDAXW1T48EopO1BsC4Lopo/56ZKFLSQaMOoLCfQCwztBWnnwVtm+Hd8Vpno4q6LdUHmevGx7jUphL1nPggyjOGTKQXJR2stNgwk7tFTPpZ3+yq86kwfEXsP++iJBBVNhF9PTTXkXordtNQmxyVIKL7cA/bm/u1ujkdNkRc80/HwKbA1qOb1XRYnxlCoJ9U0bs9+8f1aKsRYZPIr6JgPpBQdIQ0Q+5/wK743pM2rtWFRbpG/M4iQmHFUg54hlBB6OMUpykNotvSzfEU4ubRxE2lvV1LYpNL635s3UUNiMa9YnnVt4RvMIayEt4RFTWG/F21f47R4rSXds/sJ258PPVAHA005s6qRqb72dzLwdRxC1VpHrOTJ1rgwZk');            
                response.setStatusCode(200);
                
                String continuationLabel = IntegrationEngine.continuationLabel;
                List<String> labels = new List<String>{continuationLabel};
                    Object continuationState= IntegrationEngine.continuationState;   
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                String membershipResponse = (String)IntegrationEngine.processRegistrationJourneyAPIResponse(labels, IntegrationEngine.continuationState);
                Test.stopTest();
                String responseExpected ='{ "Session_Id": "06012022165122436", "Resp_Code": "200", "Resp_Message": "DB Action Success", "Registration_Url": "http://bankuat.indusind.com/content/cfdenach/sso/06012022165122436" }';
                System.assertEquals(responseExpected, membershipResponse);
            }
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Script-thrown exception');
        }
    }
    @isTest
    public static void getENACHRegistrationRequest1(){        
        try{
            Opportunity opgd1 = new Opportunity();
            opgd1.StageName = 'Qualification';
            opgd1.CloseDate = Date.newInstance(2021, 1, 11);
            opgd1.Name = 'testone';
            insert opgd1;
            
            RequestWrapper reqWrapper = new RequestWrapper();
            reqWrapper.applicantId = opgd1.Id;
            
            List<Applicant__c> appList = new List<Applicant__c>();
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opgd1.Id;
            appList.add(applicant);
            insert appList;
            IND_CAMPortfolioService.getCAMPortfolioRequest(appList[0],opgd1.id);
        }
        catch(Exception e){}
        
    }
    
    @isTest
    public static void validateException(){
        try{
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {  
                IND_ENACHRegistrationJourneyService.getRegiJourneyCallOutRequest(null, null,null);
            }
        }catch(Exception pEx){
            System.assert(pEx.getMessage() != null);
        }
        
    }
    
    @isTest
    public static void getENACHRegistrationRequest3(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {  
            Test.startTest();
            IND_ENACHRegistrationJourneyRequest.Api_mandate reqApi_mandate=new IND_ENACHRegistrationJourneyRequest.Api_mandate();
            System.assertEquals(reqApi_mandate.cifid, null);
            System.assertEquals(reqApi_mandate.accountnoordealno, null);
            System.assertEquals(reqApi_mandate.appid, null);
            System.assertEquals(reqApi_mandate.autopayfactor, null);
            System.assertEquals(reqApi_mandate.click2edit, null);
            System.assertEquals(reqApi_mandate.detcustomeracc, null);
            System.assertEquals(reqApi_mandate.detcustomerbank, null);
            System.assertEquals(reqApi_mandate.detcustomerifsc, null);
            System.assertEquals(reqApi_mandate.detcustomername, null);
            System.assertEquals(reqApi_mandate.emailid, null);
            System.assertEquals(reqApi_mandate.emiamount, null);
            System.assertEquals(reqApi_mandate.enddate, null);
            System.assertEquals(reqApi_mandate.frequency, null);
            System.assertEquals(reqApi_mandate.mobileno, null);
            System.assertEquals(reqApi_mandate.redirectURL, null);
            System.assertEquals(reqApi_mandate.referralCode, null);
            System.assertEquals(reqApi_mandate.startdate, null);
            
            IND_ENACHRegistrationJourneyRequest.Payload reqPayload=new IND_ENACHRegistrationJourneyRequest.Payload();
            System.assertEquals(reqPayload.api_mandate, null);
            Test.stopTest();
        }
    }    
}