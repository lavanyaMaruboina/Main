@isTest
public class IND_DrivingLicenseRequestTest {
    
    @isTest
    public static void verifyIND_DrivingLicenseRequest(){
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.leadId = 'L0001';
        reqWrapper.dateOfBirth = '01-01-1990';
        reqWrapper.dlNumber = 'DL0001';
        reqWrapper.dlNumber = 'DL0001';
        
        IND_DrivingLicenseRequest result = new IND_DrivingLicenseRequest(reqWrapper);
     //   Boolean isValid = result.validate(System.Label.Driving_License);
     //   System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
       // System.assert(!resultHeadersMap.isEmpty());  
    }
    
    
    
}