@isTest
public class IND_VehicleDedupeRequestTest {
    
    @isTest
    public static void verifyIND_VehicleDedupeRequest(){
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.customerCode = 'CU00011';
        reqWrapper.oldDealNo = 'L0001';
        reqWrapper.vehicleRegisterationNumber = 'MH12-9898989898';
        reqWrapper.product = 'testProduct';
        reqWrapper.category = 'TestCategory';
        reqWrapper.subCategory = 'TestSubCategory';
        
        
        IND_VehicleDedupeRequest result = new IND_VehicleDedupeRequest(reqWrapper);
        Boolean isValid = result.validate(System.Label.Vehicle_Dedupe);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty()); 
        
    }
}