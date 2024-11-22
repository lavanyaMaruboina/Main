@isTest
public class IND_PerfiosFicoDeviationResponseTest {
    
  @isTest
    public static void verifyIND_PerfiosFicoDeviationResponse(){
        IND_PerfiosFicoDeviationResponse objResp = new  IND_PerfiosFicoDeviationResponse();

      //  objResp.content = new List<IND_PerfiosFicoDeviationResponse.Content>{objContent};
      
            objResp.deviationId = '';
        objResp.deviationName = '';
        objResp.level = '';
        
       // IND_PerfiosFicoDeviationResponse result = new IND_PerfiosFicoDeviationResponse();
       // result.response = objResp;
        System.assert(objResp.level == '');
    }

}