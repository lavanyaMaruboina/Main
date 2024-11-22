/*------------------------------------------------------------
Author:        Satyam More
Company:       Persistent Systems
Description:   Test class created to validate the IND_DocAuthDocumentReportRequest
History
Date            Author              Comments
-------------------------------------------------------------
13-1-2022      Satyam More       Created
------------------------------------------------------------*/

@isTest(SeeAllData=false)
public class IND_DocAuthReport_Test {
@isTest
    public static void testDocAuthDocumentReportService(){
        
        try{
            
             Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
            system.debug('p'+ p);
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles',MobilePhone = '9701498575',Maker_Id__c='100001',
                              UserName='standarduser4@testorg.com.psdev1');
            insert u;
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            Documents__c backDoc = TestDataUtility.createTestKYCDocs(false, applicant, opp);
          //  backDoc.Is_Back__c = true;
            backDoc.Document_Type__c = 'PAN';
            backDoc.Document_Side__c ='Back';
         //   backDoc.Current_Residential_Address_Proof__c = true;
            insert backDoc;
            
                       system.runAs(u){
            Test.startTest();
            
            IND_DocAuthDocumentReportRequest docauthDocumentReportRequest = new IND_DocAuthDocumentReportRequest (String.valueOf(applicant.id));
            docauthDocumentReportRequest.getHttpRequestHeaders();
            IntegrationEngine.doDocAuthReportAsyncCallout( String.valueOf(applicant.id), String.valueOf(backDoc.id), String.valueOf(opp.Id));
 
            Test.stopTest();
                       }
        } catch(Exception ex){system.debug('exceptio is:'+ex.getLineNumber()+'&'+ex.getCause()+'&'+ex.getMessage()+'&'+ex.getStackTraceString());
            //System.assertEquals(ex.getMessage(),'Insufficient permissions: secure query included inaccessible field');
        }
    }
    
    @isTest
    public static void testDocAuthDocumentReportService2(){
        
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
             Documents__c backDoc = TestDataUtility.createTestKYCDocs(false, applicant, opp);
            backDoc.Is_Back__c = true;
            backDoc.Document_Type__c = 'PAN';
            backDoc.Document_Side__c ='Back';
            backDoc.Current_Residential_Address_Proof__c = true;
            //insert backDoc;
            
            
            Test.startTest();
            
            IND_DocAuthDocumentReportRequest docauthDocumentReportRequest = new IND_DocAuthDocumentReportRequest (String.valueOf(applicant.id));
            docauthDocumentReportRequest.getHttpRequestHeaders();
            IntegrationEngine.doDocAuthReportAsyncCallout( String.valueOf(applicant.id), String.valueOf(backDoc.id), String.valueOf(opp.Id));
 
            Test.stopTest();
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Script-thrown exception', 'Exception');
        }
    }
}