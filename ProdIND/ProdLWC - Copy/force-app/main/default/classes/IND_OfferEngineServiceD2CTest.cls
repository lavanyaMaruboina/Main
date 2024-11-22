@isTest
public class IND_OfferEngineServiceD2CTest {
@isTest
    public static void getD2COfferEngineCallOutRequestTest()
    {
        try{
       RequestWrapper reqWrapper=new RequestWrapper() ;
       reqWrapper.leadId=Null;
        reqWrapper.product='Passenger Vehicles';
        reqWrapper.vehicleType='New';
        reqWrapper.OwnHouseFlag='Test OwnHouseFlag';
        reqWrapper.Channel='Test Channel';
        reqWrapper.EngineBankIrr='Test EngineBankIrr';
        reqWrapper.EngineLTV='Test EngineLTV';
        reqWrapper.scoreCardDecision='Dark Green';
        reqWrapper.isPACustomer=True;
        reqWrapper.DealerCategory='Test DealerCategory';
        reqWrapper.Funded_Insurance='Test Funded_Insurance';
        reqWrapper.Manufacture_Code='Test Manufacture_Code';
        reqWrapper.RequiredLoanAmountFinalOffer='Test RequiredLoanAmountFinalOffer';
        reqWrapper.RequiredTenureFinalOffer='Test RequiredTenureFinalOffer'  ;
        reqWrapper.SliderLoanAmount='Test SliderLoanAmount';
        reqWrapper.SliderTenure='Test SliderTenure';
        reqWrapper.income='Test income';
        reqWrapper.emi='Test emi';
        reqWrapper.AbbFlag='Test AbbFlag';
        reqWrapper.AbbValue='Test AbbValue';
        reqWrapper.finAmount='Test finAmount';
        reqWrapper.DisplayCrmIrr='Test DisplayCrmIrr';
        reqWrapper.DisplayImputedIrr='Test DisplayImputedIrr';
        reqWrapper.DisplayLoanAmount='Test DisplayLoanAmount';
        reqWrapper.DisplayTenure='Test DisplayTenure';
        reqWrapper.NetIrr='Test NetIrr';
        reqWrapper.NetPayIns='Test NetPayIns';
        reqWrapper.NetPayOuts='Test NetPayOuts' ;
        
        
       // String fromScreen = 'insurance';
        String fromScreen = 'finalTerms';
        String loadAppId = NULL;
        
        Test.startTest();
        //RequestWrapper reqWrapper1=new RequestWrapper() ;
        IND_OfferEngineServiceD2C.getD2COfferEngineCallOutRequest(reqWrapper,loadAppId,fromScreen);
      // IND_OfferEngineServiceD2C.getD2COfferEngineCallOutRequest(NULL,NULL,NULL);

        Test.stopTest();
        }catch(Exception e){            
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
}