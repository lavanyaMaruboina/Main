@isTest
public class IND_FicoDeviationResponseTest {
    
    @isTest
    public static void verifyIND_FicoDeviationResponse_DefaultValues() {
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive' LIMIT 1];
        User u = new User(
            Alias = 'standt2', 
            Email='standarduser2@testorg.com',
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', 
            ProfileId = p.Id,
            Maker_Id__c='12',
            IsActive = true,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='test_userprod123bank@indusbank.com',
            MobilePhone = '9089078967'
        );
        insert u;

        System.runAs(u) {
            IND_FicoDeviationResponse.ConditionValues conditionValues = new IND_FicoDeviationResponse.ConditionValues();
            System.assertEquals(null, conditionValues.variableName, 'Default value of variableName should be null');
            System.assertEquals(null, conditionValues.variableValue, 'Default value of variableValue should be null');
            
            IND_FicoDeviationResponse.Deviations deviations = new IND_FicoDeviationResponse.Deviations();
            System.assertEquals(null, deviations.DeviationId, 'Default value of DeviationId should be null');
            System.assertEquals(null, deviations.DeviationName, 'Default value of DeviationName should be null');
            System.assertEquals(null, deviations.Level, 'Default value of Level should be null');
            System.assertEquals(null, deviations.displayDeviation, 'Default value of displayDeviation should be null');
            System.assertEquals(null, deviations.conditionValues, 'Default value of conditionValues should be null');
            
            IND_FicoDeviationResponse.Borrower borrower = new IND_FicoDeviationResponse.Borrower();
            System.assertEquals(null, borrower.Deviations, 'Default value of Deviations should be null');
            
            IND_FicoDeviationResponse response = new IND_FicoDeviationResponse();
            System.assertEquals(null, response.Borrower, 'Default value of Borrower should be null');
            System.assertEquals(null, response.CoBorrower, 'Default value of CoBorrower should be null');
            System.assertEquals(null, response.Beneficiary, 'Default value of Beneficiary should be null');
            System.assertEquals(null, response.Guarantor, 'Default value of Guarantor should be null');
            System.assertEquals(null, response.netLTV, 'Default value of netLTV should be null');
            System.assertEquals(null, response.grossltv, 'Default value of grossltv should be null');
        }
    }

    @isTest
    static void testIND_FicoDeviationResponse_Parsing() {
        String jsonResponse = '{"Borrower":{"Deviations":[{"DeviationId":"D1","DeviationName":"Deviation 1","Level":"High","displayDeviation":"Display Deviation","conditionValues":[{"variableName":"Var1","variableValue":"Value1"}]}]},"CoBorrower":{},"Beneficiary":{},"Guarantor":{},"netLTV":"85","grossltv":"90"}';
        IND_FicoDeviationResponse.ConditionValues expectedConditionValues = new IND_FicoDeviationResponse.ConditionValues();
        expectedConditionValues.variableName = 'Var1';
        expectedConditionValues.variableValue = 'Value1';
        
        IND_FicoDeviationResponse.Deviations expectedDeviation = new IND_FicoDeviationResponse.Deviations();
        expectedDeviation.DeviationId = 'D1';
        expectedDeviation.DeviationName = 'Deviation 1';
        expectedDeviation.Level = 'High';
        expectedDeviation.displayDeviation = 'Display Deviation';
        expectedDeviation.conditionValues = new List<IND_FicoDeviationResponse.ConditionValues>{expectedConditionValues};
        
        IND_FicoDeviationResponse.Borrower expectedBorrower = new IND_FicoDeviationResponse.Borrower();
        expectedBorrower.Deviations = new List<IND_FicoDeviationResponse.Deviations>{expectedDeviation};
        
        IND_FicoDeviationResponse expectedResponse = new IND_FicoDeviationResponse();
        expectedResponse.Borrower = expectedBorrower;
        expectedResponse.CoBorrower = new IND_FicoDeviationResponse.Borrower();
        expectedResponse.Beneficiary = new IND_FicoDeviationResponse.Borrower();
        expectedResponse.Guarantor = new IND_FicoDeviationResponse.Borrower();
        expectedResponse.netLTV = '85';
        expectedResponse.grossltv = '90';
        
        Test.startTest();
        IND_FicoDeviationResponse result = IND_FicoDeviationResponse.parse(jsonResponse);
        Test.stopTest();
        System.assertEquals(expectedResponse.Borrower.Deviations.size(), result.Borrower.Deviations.size(), 'Borrower Deviations size should match');
        System.assertEquals(expectedDeviation.DeviationId, result.Borrower.Deviations[0].DeviationId, 'DeviationId should match');
        System.assertEquals(expectedDeviation.DeviationName, result.Borrower.Deviations[0].DeviationName, 'DeviationName should match');
        System.assertEquals(expectedDeviation.Level, result.Borrower.Deviations[0].Level, 'Level should match');
        System.assertEquals(expectedDeviation.displayDeviation, result.Borrower.Deviations[0].displayDeviation, 'displayDeviation should match');
    }
}