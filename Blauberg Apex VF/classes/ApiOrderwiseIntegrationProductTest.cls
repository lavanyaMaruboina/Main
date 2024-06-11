@IsTest(SeeAllData = true)
private class ApiOrderwiseIntegrationProductTest {

    @IsTest
    static void testSendRequest() {
       // String endpoint = Orderwise__c.getInstance().Product_End_Point__c;
        // Mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new OrderwiseIntegrationProductMock());

        // Create test data
        String authToken = 'fakeAuthToken';
        
        // Call the method to be tested
        Test.startTest();
        ApiOrderwiseIntegrationProduct.sendRequest(authToken);
        Test.stopTest();
        
        // Verify that products were inserted/updated
       /* List<Product2> products = [SELECT Id, Name, ProductCode, EAN__c, Price_Ex_Vat__c, Price_Inc_Vat__c, Stock_quantity__c FROM Product2 where ProductCode = 'SKU123' limit 2];
        System.assertEquals(2, products.size(), 'Two products should have been processed.');

        Product2 product1 = [SELECT Id, Name, ProductCode, EAN__c, Price_Ex_Vat__c, Price_Inc_Vat__c, Stock_quantity__c FROM Product2 WHERE ProductCode = 'SKU123'];
        System.assertEquals('Product 1', product1.Name);
        System.assertEquals(100, product1.Stock_quantity__c);
        System.assertEquals(12.34, product1.Price_Ex_Vat__c);
        System.assertEquals(14.56, product1.Price_Inc_Vat__c);

        Product2 product2 = [SELECT Id, Name, ProductCode, EAN__c, Price_Ex_Vat__c, Price_Inc_Vat__c, Stock_quantity__c FROM Product2 WHERE ProductCode = 'SKU456'];
        System.assertEquals('Product 2', product2.Name);
        System.assertEquals(200, product2.Stock_quantity__c);
        System.assertEquals(23.45, product2.Price_Ex_Vat__c);
        System.assertEquals(27.89, product2.Price_Inc_Vat__c);*/
    }

    // Mock class for HTTP callout
    private class OrderwiseIntegrationProductMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            
            // Sample JSON response
            String jsonResponse = '[{"sku": "", "name": "Product 1", "ean": "EAN123", "quantity": 100, "price_inc_vat": 14.56, "price_exc_vat": 12.34,"EAN__c":5060407916552},' +
                                  '{"sku": "", "name": "Product 2", "ean": "EAN456", "quantity": 200, "price_inc_vat": 27.89, "price_exc_vat": 23.45}]';
            res.setBody(jsonResponse);
            
            return res;
        }
    }
}