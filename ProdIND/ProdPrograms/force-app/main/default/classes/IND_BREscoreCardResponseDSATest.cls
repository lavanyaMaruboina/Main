@IsTest
public class IND_BREscoreCardResponseDSATest {

    @isTest static void testIND_BREscoreCardResponseDSA() {
// Instantiate the outer class
IND_BREscoreCardResponseDSA response = new IND_BREscoreCardResponseDSA();

// Instantiate the inner Application class
IND_BREscoreCardResponseDSA.Application app = new IND_BREscoreCardResponseDSA.Application();

// Instantiate the inner ApplicationDecision class and set its properties
IND_BREscoreCardResponseDSA.ApplicationDecision appDecision = new IND_BREscoreCardResponseDSA.ApplicationDecision();
appDecision.riskBand = 'Low'; // Example value

// Set the applicationDecision property of the Application instance
app.applicationDecision = appDecision;

// Set the application property of the IND_BREscoreCardResponseDSA instance
response.application = app;

// Perform your assertions here
// For example, check if the riskBand is set correctly
System.assertEquals('Low', response.application.applicationDecision.riskBand, 'The riskBand should be Low.');
}
}