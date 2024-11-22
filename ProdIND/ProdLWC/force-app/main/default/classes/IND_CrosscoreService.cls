/*------------------------------------------------------------
Author: Gaurav Rawat
Description: This class is service class for the Crosscore API
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
------------------------------------------------------------*/

public class IND_CrosscoreService {
    /*
    * @Method:      getCrosscoreCallOutRequest
    * @Created by:  Gaurav Rawat
    * @Description: This method will process Crosscore
    * @Param:       String - loanApplicationId 
    * @Return:      Object - IND_CrosscoreRequest type request
    */
       
        public static IND_CrosscoreRequest getCrosscoreCallOutRequest(String loanApplicationId, List<String> beneficiaryId, String batchIndex){
            try
            {
                IND_CrosscoreRequest crosscoreRequest = new IND_CrosscoreRequest(loanApplicationId,beneficiaryId,batchIndex );
                return crosscoreRequest;
            }
            catch(Exception ex){
                ErrorLoggerUtil.logErrorEvent('IND_CrosscoreService', 'getCrosscoreCallOutRequest', System.Label.Apex, ex,loanApplicationId);
                throw new IND_Exception(ex.getMessage());          
            } 
        }
    }