/* Created Date : 12-04-2024
 * Decription : This apex is used to make a callout to third party Erp system 'Orderwise'*/

public class ApiOrderwiseIntegration {
    private static final String ENDPOINT_URL = Orderwise__c.getInstance().Token_End_Point__c;
    private static final String USERNAME = Orderwise__c.getInstance().User_name__c;
    private static final String PASSWORD = Orderwise__c.getInstance().Password__c;
    
    @InvocableMethod(label='Oderwise' description='Obtains the authentication token from the endpoint.')
    public static List<String> getToken() {
        List<String> authTokens = new List<String>();
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(ENDPOINT_URL);
        req.setMethod('GET');
        
        String authHeader = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(USERNAME + ':' + PASSWORD));
        req.setHeader('Authorization', authHeader);
                
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            String authToken = (String) JSON.deserializeUntyped(res.getBody());
            System.debug('Authentication token obtained: ' + authToken);
            ApiOrderwiseIntegrationProduct.sendRequest(authToken);
            authTokens.add(authToken);
        } else {
            System.debug('Error response: ' + res.getBody());
        }
        
        return authTokens;
    }
}