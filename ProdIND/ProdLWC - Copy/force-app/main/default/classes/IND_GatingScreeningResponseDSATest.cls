@isTest
public class IND_GatingScreeningResponseDSATest {
    @isTest
    static void testApplicationDecision() {
        // Create test data
        IND_GatingScreeningResponseDSA.ApplicationDecision decision = new IND_GatingScreeningResponseDSA.ApplicationDecision();
        decision.gatingScreeningOutcome = 'Approved';
        
        IND_GatingScreeningResponseDSA.Application application = new IND_GatingScreeningResponseDSA.Application();
        application.applicationDecision = decision;
        
        IND_GatingScreeningResponseDSA response = new IND_GatingScreeningResponseDSA();
        response.application = application;
        
        // Assert
        System.assertEquals('Approved', response.application.applicationDecision.gatingScreeningOutcome);
    }
}