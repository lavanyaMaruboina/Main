@isTest
public class IND_OfferEngineResponseDSATest {
    @isTest
    static void testOfferEngineResponse() {
        IND_OfferEngineResponseDSA response = new IND_OfferEngineResponseDSA();        
        response.requestTime = 'Sample Request Time';
        response.responseTime = 'Sample Response Time';
        response.executionTimeInMS = 100;
        response.version = 'Sample Version';
        response.callType = 'Sample Call Type';
        response.applicationHitCount = 5;
        response.transactionID = 'Sample Transaction ID';
        response.responseStatus=new Account();
        response.error= new Account();
        
        IND_OfferEngineResponseDSA.OfferEngineDecision decision = new IND_OfferEngineResponseDSA.OfferEngineDecision();
        decision.minLoanAmt = 1000.0;
        decision.maxLoanAmt = 5000.0;
        decision.minLoanAmtSlider = 1000.0; 
        decision.maxLoanAmtSlider = 1000.0; 
        decision.displayLoanAmt = 1000.0; 
        decision.minTenure = 1000.0; 
        decision.maxTenure = 1000.0; 
        decision.minTenureSlider = 1000.0; 
        decision.maxTenureSlider = 1000.0; 
        decision.displayTenure = 1000.0; 
        decision.displayEMI = 1000.0; 
        decision.displayCrmIrr = 1000.0; 
        decision.netPayIns = 1000.0; 
        decision.netPayOuts = 1000.0; 
        decision.displayImputedIrr = 1000.0; 
        decision.netIrr = 1000.0; 
        decision.grossIrr = 1000.0; 
        decision.stopJourneyFlag = true; 
        decision.bankCrmIrr = 1000.0; 
        decision.averageCrmIrr = 1000.0; 
        
        
        IND_OfferEngineResponseDSA.OfferEngineDetails details = new IND_OfferEngineResponseDSA.OfferEngineDetails();
        details.offerEngineDecision = decision;
        
        IND_OfferEngineResponseDSA.payins payins = new IND_OfferEngineResponseDSA.payins();
        payins.serviceCharges = 50.0;
        payins.docCharges = 20.0;
        
        IND_OfferEngineResponseDSA.payouts payouts = new IND_OfferEngineResponseDSA.payouts();
        payouts.provisionCost = 100.0;
        payouts.dlrIncentiveAmtMain = 200.0;
        payouts.mfrIncentiveAmt=100.0;
        
        details.payins = payins;
        details.payouts = payouts;
        
         IND_OfferEngineResponseDSA.LoanDetails loanDetail=new IND_OfferEngineResponseDSA.LoanDetails();
         loanDetail.bankingExposureAmount=100.0;
         loanDetail.documentCharge=100.0;
        loanDetail.downPayment=50.0;
        loanDetail.irr=100.0;
        loanDetail.loanAmount=9000.0;
        loanDetail.mclrRate=100.0;
        loanDetail.offerEMI=40.0;
        loanDetail.purposeOfPurchase='purposeOfPurchase';
        loanDetail.serviceCharge=40.0;
        loanDetail.tenure=9000.0;
        
        IND_OfferEngineResponseDSA.Application application = new IND_OfferEngineResponseDSA.Application();
        application.offerEngineDetails = details;
        application.tableCode='TableCode';
        application.loanDetails=loanDetail;
        application.interestVersionNo='interestVersionNo';
        application.drPenalInterest=7000.0;
        
        response.application = application;
        
        System.assertEquals('Sample Request Time', response.requestTime);
        System.assertEquals('Sample Response Time', response.responseTime);
        
        System.assertEquals(1000.0, response.application.offerEngineDetails.offerEngineDecision.minLoanAmt);
        System.assertEquals(50.0, response.application.offerEngineDetails.payins.serviceCharges);
        System.assertEquals(200.0, response.application.offerEngineDetails.payouts.dlrIncentiveAmtMain);        
    }
}