@isTest
public class PincodeBasedSearchResponseTest {

	@isTest
    public static void createReferenceCustomersTest(){
        try
        {
            // Create Opportunity
            Opportunity oppUsed = TestDataUtility.createTestOpportunityForOcr(true); 
            
            // Create Applicant__c
            Applicant__c applicant = TestDataUtility.createTestApplicantForMFCValuation(true, oppUsed);
            
            PincodeBasedSearchResponse pincodeResponse = new PincodeBasedSearchResponse();
            pincodeResponse.status = 'test';
            pincodeResponse.respDesc = 'test';
            
            List<PincodeBasedSearchResponse.CustomerInfo> customerInfolList = new List<PincodeBasedSearchResponse.CustomerInfo>();
            PincodeBasedSearchResponse.CustomerInfo customerInfo = new PincodeBasedSearchResponse.CustomerInfo();
            customerInfo.Customer_Name = 'test';
            customerInfo.SurName = 'test';
            customerInfo.Customer_Code = '12345';
            customerInfo.Address_Line_1 = 'testAddress1';
            customerInfo.Address_Line_2 = 'testAddress2';
            customerInfo.Address_Line_3 = 'testAddress3';
            customerInfo.Address_Line_4 = 'testAddress4';
            customerInfo.City = 'test';
            customerInfo.District = 'test';
            customerInfo.State = 'test';
            customerInfo.Landmark = 'tets';
            customerInfo.Address_Flag = 'test';
            customerInfo.Mobile_Number = '1234567890';
            customerInfo.Maker_Date = String.valueOf(Date.toDay().addDays(10));
            customerInfo.Product = 'Test';
            customerInfo.Exposure = 'tets';
            
            customerInfolList.add(customerInfo);                
           	pincodeResponse.content = customerInfolList; 
            
            Test.startTest();
            	IntegrationEngine.createReferenceCustomers(pincodeResponse,oppUsed.Id,applicant.Id);
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }    
}