@isTest
public class IND_OfferEngineServiceDSATest {
@isTest
    public static void getMFCValuationRequestCalloutTest(){
        Opportunity opgd1 = TestDataUtility.createTestLoanApplication(false);      
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        opgd1.Vehicle_Sub_Category__c = 'UIM';
        opgd1.Parent_Deal_number__c = 'DL109939';
        opgd1.Lead_number__c = 'L109939';
        opgd1.Deal_Number__c = 'L109939';
        opgd1.Application_number__c = 'L109939';
        opgd1.Agent_BL_code__c = 'AG-00';
        opgd1.Employee_Name__c = 'Test';
        opgd1.Employee_No__c = 'L109939';
        insert opgd1;
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opgd1.Id;
        applicant.Applicant_Type__c  = null;
        applicant.Scorecard_Decision__c = 'Red';
        insert applicant;
        
        
        Vehicle_Detail__c vg3 = TestDataUtility.createTestVehicleDetailForIbb(false,opgd1);
        vg3.Ben_Code__c = 'testveh';
        vg3.Valuer_code__c = 'BEN000871';
        vg3.Variant__c  = 'M&M KUV100 NXT K8 DIESEL';
        vg3.Make__c = 'TVS';
        vg3.Model__c = 'MAHINDRA MARAZZO';
        vg3.Engine_number__c  = 'TBH1H79814';
        vg3.Chassis_number__c  = 'MA1ZN2TBKH65317';
        vg3.Vehicle_Registration_number__c  = 'MH14GV9526';
        vg3.Product__c='Two Wheeler';
        insert vg3; 
        
      
        Product2 pd1 = TestDataUtility.createTestProduct2(false);
        pd1.Asset_Category__c = 'A';
        pd1.Name = 'M&M KUV100 NXT K8 DIESEL';
        pd1.Type__c = 'variant';
        pd1.External_Reference_Id__c = '58568568';
        pd1.Variant_Code__c = 'xyz';
        insert pd1;
        
        
        RequestWrapper requestWrapper = new RequestWrapper();
        requestWrapper.loanApplicationId = opgd1.Id;
        requestWrapper.Channel ='IndusMobile';
        requestWrapper.valuerCategory = 'valuerCategory';
        requestWrapper.placeOfInspection = 'placeOfInspection';
        requestWrapper.locationOfVehicle = 'locationOfVehicle';
        requestWrapper.city = 'Chennai';
        requestWrapper.state = 'TL';
        requestWrapper.Variant = pd1.Variant_Code__c;

        Test.startTest();
          IND_OfferEngineRequestDSA request = IND_OfferEngineServiceDSA.getDSAOfferEngineCallOutRequest(requestWrapper,opgd1.Id);
        Test.stopTest();
        
    }
    @isTest
    public static void getMFCValuationRequestCalloutTest1(){
        
          Test.startTest();
        try{
          IND_OfferEngineRequestDSA request = IND_OfferEngineServiceDSA.getDSAOfferEngineCallOutRequest(null,null);
         }
        catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Attempt to de-reference a null object');
        }
        Test.stopTest();
    }
}