@isTest
public class IND_AMLCheckRequestTest {
    
    @testSetup
    public static void createTestData(){       
        //Create User     
        Contact con = TestDataUtility.createTestContact(true);
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Partner Community Counter Staff'];     
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles', ContactId = con.Id,
                          UserName='test1_userprod123@indusbank.com',MobilePhone = '9089078967');
        insert u;
        System.runAs(u)
        {
            Opportunity opp = new Opportunity();
            opp.StageName = 'Qualification';
            opp.CloseDate = Date.newInstance(2021, 1, 11);
            opp.Lead_number__c = '12345';
            opp.Name = 'testone';
            opp.Product_Type__c = 'Two Wheeler';
            opp.Vehicle_Type__c = 'New';
            insert opp;
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c = opp.Id;
            applicant.Applicant_Type__c  = null;
            applicant.DocAuth_Application_Id__c = 'AC12313244_13423';
            insert applicant;
            applicant.Opportunity__r = opp; 
            
            List<Documents__c> docList = new List<Documents__c>();
            Documents__c doc1 = TestDataUtility.createTestDocumentITR(false, applicant, opp);        
            doc1.Name = 'KYC '+opp.Id;
            doc1.Opportunity_Relation__c = opp.Id;
            doc1.Is_active__c = true;
            doc1.KYC_DOB__c = System.today();
            doc1.KYC_City__c = 'Jaipur';
            doc1.Proof_of_Identity_POI__c = true;
            doc1.Document_Type__c = 'Chassis Number uploaded during verification';
            docList.add(doc1);
            
            Documents__c doc2 = TestDataUtility.createTestDocumentITR(false, applicant, opp);        
            doc2.Name = 'KYC '+opp.Id;
            doc2.KYC_DOB__c = System.today();
            doc2.KYC_City__c = 'Jaipur';
            doc2.Opportunity_Relation__c = opp.Id;
            doc2.Is_active__c = true;
            doc2.Proof_of_Address_POA__c = true;
            doc2.Document_Type__c = 'Chassis Number uploaded during verification';
            docList.add(doc2);
            if(Schema.sObjectType.Documents__c.isCreateable()){
                insert docList;
            }
            
        }        
    }
    @isTest
    public static void verifyIND_AMLCheckRequest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test1_userprod123@indusbank.com' AND IsActive = true LIMIT 1];                             
            
        Applicant__c applicant = [SELECT Id, Opportunity__c, Applicant_Number__c, Name, Opportunity__r.Lead_number__c,Opportunity__r.Product_Type__c,
                                  (SELECT Id, Proof_of_Identity_POI__c, KYC_DOB__c, Proof_of_Address_POA__c, KYC_City__c FROM Documents__r ) 
                                  FROM Applicant__c LIMIT 1];
        Boolean isValid;
        IND_AMLCheckRequest result;
        Test.startTest();
        System.runAs(u)
        {
            result = new IND_AMLCheckRequest(applicant);
       	    isValid = result.validate(System.Label.AMLCheck);
        }        
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty()); 
    }  
}