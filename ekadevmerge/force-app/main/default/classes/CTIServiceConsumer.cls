/***
* Description : CTI Service Consumer
* Author : Maantic
* Date: 21/10/2022
**/

public class CTIServiceConsumer {

    public static boolean isTest = false;
    
    //Method exposed to component
    @AuraEnabled
    public static CTIResponsetWrpper handleCTICall(String recordID){
        CTIResponsetWrpper responseWrapper = new CTIResponsetWrpper();
        HttpResponse htResponse = new HttpResponse();
        try{
           CTIRequestWrpper reqWrapper=new CTIRequestWrpper();
           fetchRecordAndSetReqObj(recordID,reqWrapper);
           htResponse=phoneCallout(reqWrapper);
           responseWrapper=(CTIResponsetWrpper)JSON.deserialize(htResponse.getBody(), CTIResponsetWrpper.class);
           System.debug('Final response '+responseWrapper);
           return responseWrapper;
        }
        
        catch(Exception e){
            System.debug('Exception: ' + e.getMessage() + '- Line: ' + e.getLineNumber());
            responseWrapper.isSaved='N';
            responseWrapper.message=htResponse.getBody();
            return responseWrapper;
        }
    }   
    
    //Method to hit the Service
    private static HttpResponse phoneCallout(CTIRequestWrpper requestWrapper){
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();   
        request.setHeader('Content-Type','application/json;charset=UTF-8');
        request.setEndpoint('callout:EkaOptiMLDialler/api/ekacare/pushlead.php');
        request.setMethod('POST');
        request.setBody('['+JSON.serialize(requestWrapper)+']'); 
        System.debug('Request Object Body :::'+request.getBody());
         HttpResponse response = new HttpResponse();
        try{
            if(Test.isRunningTest() && isTest) {request = null;}
            response = http.send(request);
            System.debug('The response code is :::'+response);            
            if(response.getStatusCode() == 200) {
                System.debug('The response is for 200 Code:::'+response.getBody());
                return response;
            }else{
                System.debug('Invalid response from API ['+response.getStatusCode()+']:'+response.getBody());
                return response;
            }
        }catch(Exception e){
            System.debug('Exception: ' + e.getMessage() + '- Line: ' + e.getLineNumber());
              response.setBody(e.getMessage());
              return response;
        }
    }
    
    
    public static void fetchRecordAndSetReqObj(String recordID,CTIRequestWrpper reqWrapper)
    {
        Opportunity opp=[Select id, phone__c from Opportunity where id=:recordID];
         if(opp !=null)
            {
                reqWrapper.leadSource=recordID;
                reqWrapper.assignedAgentId=UserInfo.getUserId();
                reqWrapper.phoneNumber=opp.phone__c;
                reqWrapper.name='BLANK';
            }     
        
    }
    
    
}