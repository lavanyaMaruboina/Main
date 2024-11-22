@isTest
public class IND_ReverseStatusCalloutOLAQueueableTest {
	static HttpResponse response;
    Static String successData= 'Success';
    Static String failureData= 'Failed';
    
    @testSetup static void testData() { 
    }
    
    public class MockSuccess implements HttpcalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
                    response = new HttpResponse();
                    response.setbody(successData);
                    response.setstatuscode(200);
                    return response;
            }
    }
    
    static testmethod void testForSuccess(){
        Opportunity opp = new Opportunity();
        opp.Lead_number__c = 'L123456789';
        opp.Name = 'Test';
        opp.StageName = 'Loan Initiation';
        opp.Withdrawal_Reason__c ='Null';
        opp.CloseDate =Date.newInstance(2023, 4, 17);
        opp.Sanction_Date__c =Date.newInstance(2023, 4, 17);
        opp.LeadSource = 'Hero';
        insert opp;
             Final_Term__c ft = new Final_Term__c();
                     ft.CRM_IRR__c = 120;
                     ft.Loan_Application__c = opp.Id;
                     ft.Holiday_period__c='30';
                     ft.EMI_Amount__c= 10000;
                     ft.FIwaiver_offAddress__c = 'Not Waived';
                     ft.Loan_amount__c= '120000';
                     ft.Tenure__c ='30';
                     insert ft;
            Applicant__c apfu1 = new Applicant__c();
             apfu1.Opportunity__c = opp.Id;
              apfu1.Contact_number__c = '9743514830';
              //apfu1.Applicant_Type__c = 'Borrower';
              insert apfu1;
              Documents__c dfu1 = new Documents__c();
              dfu1.Applicant__c = apfu1.Id;
              dfu1.Opportunity_Relation__c = opp.Id;
              dfu1.Document_Type__c = '36';
              dfu1.Document_Side__c ='Back';
              dfu1.Aadhar_Source__c = 'OTP';
              dfu1.CMU_Accept_Reject__c = 'Reject';
              dfu1.CMU_Rejection_Reason__c ='Incorrect fields';
              dfu1.Rejection_Fields__c ='Gender;Salutation';
              insert dfu1;
              CAM__c cam = new CAM__c();
              cam.Loan_Application__c = opp.Id;
              cam.BE_CVO_Remark__c ='null';
               insert cam;
            Decimal offeramount = Decimal.ValueOf(ft.Loan_amount__c);
        Test.setMock(HttpCalloutMock.class, new MockSuccess());
        Test.startTest();
        System.enqueueJob(new IND_ReverseStatusCalloutOLAQueueable('L123456789','Sanctioned'));
        System.enqueueJob(new IND_ReverseStatusCalloutOLAQueueable('L123456789','Disbursed'));
        System.debug('Response::'+response);
        Test.stopTest();
    }
}