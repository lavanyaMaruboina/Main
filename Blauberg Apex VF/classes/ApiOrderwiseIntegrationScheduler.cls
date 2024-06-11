global class ApiOrderwiseIntegrationScheduler implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        String ENDPOINT_URL = Orderwise__c.getInstance().Token_End_Point__c;
        String USERNAME = Orderwise__c.getInstance().User_name__c;
        String PASSWORD = Orderwise__c.getInstance().Password__c;
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(ENDPOINT_URL);
        req.setMethod('GET');
        
        String authHeader = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(USERNAME + ':' + PASSWORD));
        req.setHeader('Authorization', authHeader);
                
        // Callout can't be performed directly in scheduled apex, so we will call a future method.
        makeCallout(ENDPOINT_URL, req.getMethod(), authHeader);
    }
    
    @future(callout=true)
    static void makeCallout(String endpointUrl, String method, String authHeader) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpointUrl);
        req.setMethod(method);
        req.setHeader('Authorization', authHeader);

        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            String authToken = (String) JSON.deserializeUntyped(res.getBody());
            System.debug('Authentication token obtained: ' + authToken);
            
            // Call the method to send request with the token
            ApiOrderwiseIntegrationProduct.sendRequest(authToken);
        } else {
            System.debug('Error response: ' + res.getBody());
        }
    }
}