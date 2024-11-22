@isTest
private class IND_PricingEngineResponseDSATest {

    @isTest
    static void testIND_PricingEngineResponseDSA() {
        
        IND_PricingEngineResponseDSA.ApplicationDecision decision = new IND_PricingEngineResponseDSA.ApplicationDecision();
        decision.prescribedRate = 'Test Rate';

        IND_PricingEngineResponseDSA.Application application = new IND_PricingEngineResponseDSA.Application();
        application.applicationDecision = decision;

        IND_PricingEngineResponseDSA response = new IND_PricingEngineResponseDSA();
        response.application = application;

        System.assertEquals('Test Rate', response.application.applicationDecision.prescribedRate,'Prescribed rate should be set correctly');

        IND_PricingEngineResponseDSA.ApplicationDecision newDecision = new IND_PricingEngineResponseDSA.ApplicationDecision();
        newDecision.prescribedRate = 'New Test Rate';

        IND_PricingEngineResponseDSA.Application newApplication = new IND_PricingEngineResponseDSA.Application();
        newApplication.applicationDecision = newDecision;

        response.application = newApplication;
        System.assertEquals('New Test Rate', response.application.applicationDecision.prescribedRate,'Prescribed rate should be updated correctly');
    }
}