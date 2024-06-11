public class ApiOrderwiseIntegrationProduct {
    
    public static void sendRequest(String authToken) {
        String endpoint = Orderwise__c.getInstance().Product_End_Point__c;
        system.debug('This is newly generated access token---'+authToken);
        system.debug('This is endpoint---'+endpoint);
        String requestBody = '[]';
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + authToken);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(requestBody);
        system.debug('Req---'+req);
        
        Http http = new Http();
        
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            System.debug('Request successful. Response: ' + res.getBody());
            handleResponse(res.getBody());
        } else {
            System.debug('Request failed with status code: ' + res.getStatusCode());
            System.debug('Response: ' + res.getBody());
        }
    }
    
    public static void handleResponse(String jsonResponse) {
        List<Product2> productsToUpdate = new List<Product2>();
        List<Product2> newProductsToInsert = new List<Product2>();
        Set<String> skuSet = new Set<String>();
        Set<String> eanSet = new Set<String>();

        List<Object> productList = (List<Object>) JSON.deserializeUntyped(jsonResponse);
        system.debug('Size---'+productList.size());

        for (Object productObj : productList) {
            Map<String, Object> productData = (Map<String, Object>) productObj;
            String sku = ((String) productData.get('sku')).trim();
            String ean = (String) productData.get('ean');
            skuSet.add(sku);
            eanSet.add(ean);
        }

        // Query existing products based on SKUs and EANs
        Map<String, Product2> existingProductsMap = new Map<String, Product2>();
        for (Product2 product : [SELECT Id, Name, ProductCode, EAN__c, Price_Ex_Vat__c, Price_Inc_Vat__c, Stock_quantity__c, Family, Inventory_QTY_Magento__c, StockKeepingUnit, Brand__c FROM Product2 WHERE StockKeepingUnit IN :skuSet]) {
            existingProductsMap.put(product.StockKeepingUnit, product);
        }

        Map<String, Product2> existingProductsMapByEAN = new Map<String, Product2>();
        for (Product2 product : [SELECT Id, Name, ProductCode, EAN__c, Price_Ex_Vat__c, Price_Inc_Vat__c, Stock_quantity__c, Family, Inventory_QTY_Magento__c, StockKeepingUnit, Brand__c FROM Product2 WHERE EAN__c IN :eanSet]) {
            existingProductsMapByEAN.put(product.EAN__c, product);
        }

        // Iterate through each product in the response
        for (Object productObj : productList) {
            Map<String, Object> productData = (Map<String, Object>) productObj;
            String sku = ((String) productData.get('sku')).trim();
            String name = (String) productData.get('name');
            String ean = (String) productData.get('ean');
            Decimal quantity = (Decimal) productData.get('quantity');
            Decimal priceIncVat = (Decimal) productData.get('price_inc_vat');
            Decimal priceExcVat = (Decimal) productData.get('price_exc_vat');

            // Check if product exists by SKU or EAN
            Product2 existingProductBySKU = existingProductsMap.get(sku);
            Product2 existingProductByEAN = existingProductsMapByEAN.get(ean);

            // Update existing product if found by SKU or EAN
            if (existingProductBySKU != null || existingProductByEAN != null) {
                Product2 existingProductToUpdate = existingProductBySKU != null ? existingProductBySKU : existingProductByEAN;
                existingProductToUpdate.Name = name;
                existingProductToUpdate.ProductCode = sku;
                existingProductToUpdate.StockKeepingUnit = sku;
                existingProductToUpdate.Stock_quantity__c = quantity;
                existingProductToUpdate.Price_Inc_Vat__c = priceIncVat;
                existingProductToUpdate.Price_Ex_Vat__c = priceExcVat;
                productsToUpdate.add(existingProductToUpdate);
            } else {
                // Create new product if not found by SKU or EAN
                try {
                    Product2 newProduct = new Product2(
                        Name = name,
                        EAN__c = ean,
                        ProductCode = sku,
                        StockKeepingUnit = sku,
                        Stock_quantity__c = quantity,
                        Price_Inc_Vat__c = priceIncVat,
                        Price_Ex_Vat__c = priceExcVat
                    );
                    newProductsToInsert.add(newProduct);
                } catch (Exception e) {
                    System.debug('An error occurred while creating a new product: ' + e.getMessage());
                }
            }
        }

        // Perform DML operation for updating existing products
        if (!productsToUpdate.isEmpty()) {
            try {
                system.debug('No of products Going to Update--'+productsToUpdate.size());
                update productsToUpdate;
            } catch (DmlException e) {
        // Handle exception
        for (Integer i = 0; i < e.getNumDml(); i++) {
            Integer failedIndex = e.getDmlIndex(i);
            System.debug('Failed to update record at index: ' + failedIndex);
            // Log the failed record itself for further investigation
            System.debug('Failed Record: ' + productsToUpdate[failedIndex]);
        }
        System.debug('An error occurred while updating existing products: ' + e.getMessage());
    }
        }

        // Perform DML operation for creating new products
        if (!newProductsToInsert.isEmpty()) {
            try {
                system.debug('No of products Going to Insert--'+newProductsToInsert.size());
                insert newProductsToInsert;
            } catch (DmlException e) {
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    Integer failedIndex = e.getDmlIndex(i);
                    System.debug('Failed to insert record at index: ' + failedIndex);
                    // Optionally, you can log the failed record itself
                    System.debug('Failed Record: ' + newProductsToInsert[failedIndex]);
                }
                System.debug('An error occurred while inserting new products: ' + e.getMessage());
            }
        }
    }
}