@isTest
public class IND_BREscoreCardRequestTest {
    
    @isTest
    public static void verifyINDBREscoreCardRequest(){
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        opgd1.Agent_BL_code__c = 'AG-01';
        insert opgd1;
        
        List<Applicant__c> appList = new List<Applicant__c>();
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opgd1.Id;
        applicant.Applicant_Type__c  = 'Borrower';
        applicant.Scorecard_Decision__c = 'Red';
        applicant.Contact_number__c = '9898989898';
        applicant.Gender__c = 'MALE';
        applicant.Marital_status__c = 'UNMAR';
        applicant.Residence_country__c = 'India';
        appList.add(applicant);
        insert appList;
        applicant.Opportunity__r = opgd1;  
        
        
        Bl_Code_Details__c bcd1 = new Bl_Code_Details__c();
        bcd1.Bl_Code__c = opgd1.Agent_BL_code__c;
        bcd1.Name = 'test';
        insert bcd1;
        
        Geo_State_Masters__c gm1 = new Geo_State_Masters__c();
        gm1.NeSL_State_Code__c = 'test';
        gm1.OwnerId = UserInfo.getUserId();
        gm1.Pincode_Starting_Max__c = 524;
        gm1.Pincode__c = 315;
        gm1.Name = 'allur';
        gm1.State_Code__c = '01';
        insert gm1;
        
        
        BankBranchDetails__c bd1 = new BankBranchDetails__c();
        bd1.Bl_Code_Details__c = bcd1.Id;
        bd1.Geo_State_Master__c = gm1.Id;
        bd1.Address_1__c = 'testad1';
        bd1.Address_2__c = 'testad2';
        bd1.UniqueIdentifier__c = '201';
        bd1.District__c = 'nellore';
        insert bd1; 
        
        Profile_Master__c obj1 = new Profile_Master__c();
        obj1.code__c = '1';
        obj1.Category__c  = '121';
        obj1.Name='test';
        insert obj1;
        
        Income_Details__c incomeObj = new Income_Details__c();
        incomeObj.Applicant__c = applicant.id;
        incomeObj.Profile__c = obj1.Id;
        insert incomeObj;
        
        
        Documents__c doc = TestDataUtility.createTestDLDocs(false, applicant, opgd1);
        doc.KYC_DOB__c = System.today().addDays(-9343);
        doc.KYC_Pin_Code__c = '600122';
        insert doc;
        
        IND_BREscoreCardRequest objResult = new IND_BREscoreCardRequest(applicant, doc, opgd1.Id);
        Map<String,String> resultHeadersMap = objResult.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty());
        
     }
    
    @isTest
    public static void verifyINDBREscoreCardRequest1(){
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        opgd1.Agent_BL_code__c = 'AG-01';
        insert opgd1;
        
        List<Applicant__c> appList = new List<Applicant__c>();
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opgd1.Id;
        applicant.Applicant_Type__c  = 'Borrower';
        applicant.Scorecard_Decision__c = 'Red';
        applicant.Contact_number__c = '9898989898';
        applicant.Gender__c = 'MALE';
        applicant.Marital_status__c = 'UNMAR';
        applicant.Residence_country__c = 'India';
        appList.add(applicant);
        insert appList;
        applicant.Opportunity__r = opgd1;  
        
        Documents__c doc = TestDataUtility.createTestDLDocs(false, applicant, opgd1);
        doc.KYC_DOB__c = System.today().addDays(-9343);
        doc.KYC_Pin_Code__c = '600122';
        insert doc;
        
        IND_BREscoreCardRequest objResult = new IND_BREscoreCardRequest(applicant, doc, opgd1.Id);
       // Map<String,String> resultHeadersMap = objResult.getHttpRequestHeaders();
      //  System.assert(!resultHeadersMap.isEmpty());
        
     }
}