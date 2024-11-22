@isTest
public class IND_VoterIdRequestTest {

    @isTest
    public static void verifyIND_VoterIdRequest(){
        
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        insert opgd1;
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.applicantId = opgd1.Id;
        reqWrapper.telephoneNumber = '01212008';
        reqWrapper.kycNo = '00991dd';
        reqWrapper.leadId = 'L000122';
        List<Applicant__c> appList = new List<Applicant__c>();
        
      //  IND_VoterIdRequest result = new IND_VoterIdRequest(reqWrapper);
     //   Boolean isValid = result.validate(System.Label.VoterIdAPI);
     //   System.assert(isValid);
        
     //   Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
     //   System.assert(!resultHeadersMap.isEmpty()); 
    }
    
}