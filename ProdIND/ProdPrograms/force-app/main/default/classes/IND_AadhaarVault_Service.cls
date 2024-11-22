public class IND_AadhaarVault_Service{
 
        public static IND_AadhaarVault_Request getAadhaarVault(String docNo, String AadhaarNo){
            try
            {
                IND_AadhaarVault_Request request = new IND_AadhaarVault_Request(docNo,AadhaarNo);            
                return request;
            }
            catch(Exception ex){
                ErrorLoggerUtil.logErrorEvent('IND_AadhaarVault_Service', 'getAadhaarVault', System.Label.Apex, ex,docNo);
                throw new IND_Exception(ex.getMessage());          
            }  
        }
}