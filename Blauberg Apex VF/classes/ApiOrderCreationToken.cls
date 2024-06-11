/* Created Date : 36-04-2024
 * Description : This apex is used to make a callout to third party ERP system 'Orderwise'*/

public class ApiOrderCreationToken {
    private static final String ENDPOINT_URL = Orderwise__c.getInstance().Token_End_Point__c;
    private static final String USERNAME = Orderwise__c.getInstance().User_name__c;
    private static final String PASSWORD = Orderwise__c.getInstance().Password__c;

    // Public method to obtain the authentication token
    public static String getToken() {
        String authToken = null;
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(ENDPOINT_URL);
        req.setMethod('GET');
        
        String authHeader = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(USERNAME + ':' + PASSWORD));
        req.setHeader('Authorization', authHeader);
                
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            authToken = (String) JSON.deserializeUntyped(res.getBody());
            System.debug('Authentication token obtained: ' + authToken);
            // Optionally, you can call another method here if needed
        } else {
            System.debug('Error response: ' + res.getBody());
        }
        
        return authToken;
    }
}