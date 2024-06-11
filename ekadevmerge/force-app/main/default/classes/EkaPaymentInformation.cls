public class EkaPaymentInformation {
    
    private static final String CALLOUT_URL = 'https://axon.eka.care/salesforce/doctor/161419272566611/request-payment';
    
    @future(callout=true)
    public static void sendDoctorPayment(String jsonString) {
        try {
            List<Eka_Payment__c> payList = (List<Eka_Payment__c>) JSON.deserialize(jsonString, List<Eka_Payment__c>.class);
            System.debug('payment object=> ' + payList);
            
            for (Eka_Payment__c pay : payList) {
                //System.debug('dynamic=> '+pay.name+' '+pay.HIC_ShopifySync__Total_Price__c+' '+pay.HIC_ShopifySync__Total_Tax__c);
                
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(CALLOUT_URL);
                //System.debug('EndPoint=> '+CALLOUT_URL + '/admin/api/2023-10/orders.json');
                request.setMethod('POST');
                request.setHeader('Content-Type', 'application/json');
                //request.setHeader('X-Shopify-Access-Token', CALLOUT_ACCESS_TOKEN);
                
                String subscriptionPlan = String.valueOf(pay.Subscription_Plan__c);
                System.debug(subscriptionPlan);
                String discount = String.valueOf(pay.Discount_Rate__c);
                System.debug(discount);
                String salesId = String.valueOf(pay.Name);
                System.debug(salesId);
                
                String myRequestBody = '{"Eka_Payment__c": {"line_items": [{"title": "' + salesId + '","Subscription Plan":"' + subscriptionPlan + '","Discount Rate":"' + discount + '","transactions": [{"kind": "sale","status": "success"}],"Subscription plan":"' + subscriptionPlan + '","discount":"' + discount + '"}],"Eka_Payment__c": {"line_items": [{"title": "Payment ","[{"title": "Eka Payment"}]}],"transactions": [{"kind": "sale","status": "success"}]}}';
                
                System.debug('myRequestBody=> ' + myRequestBody);
                request.setBody(myRequestBody);
                
                HttpResponse response = http.send(request);
                System.debug('POST response code: ' + response.getStatusCode());
                
                if (response.getStatusCode() == 201) {
                    System.debug('POST response: ' + response.getBody());
                } else {
                    System.debug('Error=> ' + response.getBody());
                }
            }
        } catch(Exception e) {
            System.debug('Line=> ' + e.getLineNumber() + ' Exception=> ' + e.getMessage());
        }
    }
}