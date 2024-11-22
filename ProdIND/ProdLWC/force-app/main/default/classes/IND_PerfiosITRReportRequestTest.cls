@isTest
public class IND_PerfiosITRReportRequestTest {
    
    @isTest
    public static void verifyIND_PerfiosITRReportRequest(){
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        opgd1.Lead_number__c = 'L18012200011';
        insert opgd1;
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opgd1.Id;
        applicant.Applicant_Type__c  = null;
        applicant.Scorecard_Decision__c = 'Red';
        insert applicant;
        applicant.Opportunity__r = opgd1; 
        
        Income_Details__c objIncomingDetails = new Income_Details__c();
        objIncomingDetails.Applicant__r = applicant;
        objIncomingDetails.From_Month__c = '2022-03';
        objIncomingDetails.To_Month__c = '2022-09';
        objIncomingDetails.Is_Salaried__c = true;
        objIncomingDetails.Employer_Business_Name__c = 'Test';
        objIncomingDetails.Capture_GST_Method__c = 'Online via link';
        
        IND_PerfiosITRReportRequest result = new IND_PerfiosITRReportRequest(objIncomingDetails, opgd1, 'perfiosId', 'reportFormat');
     /*   Boolean isValid = result.validate(System.Label.GSTReport);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty());
        
        result = new IND_PerfiosITRReportRequest(applicant);
        System.assert(result != null); */
    }
    
}