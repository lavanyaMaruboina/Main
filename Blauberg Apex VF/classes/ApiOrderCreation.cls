public class ApiOrderCreation {
    @future(callout=true)
    public static void createOrderFromInvoice(Id invoiceId) {
        String authToken = ApiOrderCreationToken.getToken();
        if (authToken == null) {
            System.debug('Failed to obtain authentication token. Exiting order creation process.');
            return;
        }
        fw1__Invoice__c invoice = [SELECT Id, Name, fw1__Contact__c,fw1__Contact__r.Name,fw1__Contact__r.Salutation,fw1__Contact__r.Phone,fw1__Contact__r.Email,fw1__Contact__r.MobilePhone, fw1__Invoice_Date__c,fw1__Total_Invoice_Amount__c, fw1__Total_Paid_Amount__c,fw1__Account__r.Id, fw1__Total_Invoice_Discount_Amount__c, fw1__Total_Additional_Charges__c, fw1__Account__r.Billing_Address__c,fw1__Account__r.Name,fw1__Shipping_And_Handling__c,fw1__Tax_Amount__c,
                                  (SELECT Id, Name, fw1__Quantity__c, fw1__Unit_Price__c, fw1__Total_Discount_Amount__c, fw1__Amount__c, fw1__Product2__r.Name, fw1__Product2__r.StockKeepingUnit,fw1__Product2__r.Description FROM fw1__Invoice_Lines__r)
                            FROM fw1__Invoice__c WHERE Id = :invoiceId];
        system.debug('Invoice details'+invoice);

        // Build the request body dynamically
        Map<String, Object> requestBody = new Map<String, Object>();
        
        // Add customer information from Invoice +++++ If required in Future you can enable it ++++++++++++++++++
  
        Map<String, Object> customerInfo = new Map<String, Object>();
        //customerInfo.put('id', 10);
        customerInfo.put('accountNumber', invoice.fw1__Account__r.Id);
        customerInfo.put('statementName', invoice.fw1__Contact__r.Name);
		customerInfo.put('statementAddress1', invoice.fw1__Account__r.Billing_Address__c.getStreet());
		customerInfo.put('statementTown', invoice.fw1__Account__r.Billing_Address__c.getCity());
		customerInfo.put('statementPostcode', invoice.fw1__Account__r.Billing_Address__c.getPostalCode());
		customerInfo.put('statementCountry', invoice.fw1__Account__r.Billing_Address__c.getCountry());
		customerInfo.put('statementCountryCode', invoice.fw1__Account__r.Billing_Address__c.getCountryCode());
		customerInfo.put('statementEmail', invoice.fw1__Contact__r.Email);
		customerInfo.put('statementTelephone', invoice.fw1__Contact__r.Phone);
		customerInfo.put('invoiceName', invoice.Name);
		customerInfo.put('invoiceAddress1',  invoice.fw1__Account__r.Billing_Address__c.getStreet());
		customerInfo.put('invoiceTown', invoice.fw1__Account__r.Billing_Address__c.getCity());
		customerInfo.put('invoicePostcode', invoice.fw1__Account__r.Billing_Address__c.getPostalCode());
		customerInfo.put('invoiceCountry', invoice.fw1__Account__r.Billing_Address__c.getCountry());
		customerInfo.put('invoiceCountryCode', invoice.fw1__Account__r.Billing_Address__c.getCountryCode());
		customerInfo.put('invoiceEmail', invoice.fw1__Contact__r.Email);
		customerInfo.put('invoiceTelephone',  invoice.fw1__Contact__r.Phone);
        requestBody.put('customer', customerInfo);
        system.debug('This is customer details'+customerInfo);
            
        
        // Add customer contact information from Invoice
        Map<String, Object> customerContact = new Map<String, Object>();
        //customerContact.put('id', 0);
        customerContact.put('salutation', invoice.fw1__Contact__r.Salutation);
        customerContact.put('name', invoice.fw1__Contact__r.Name);
        customerContact.put('telephone', invoice.fw1__Contact__r.Phone);
        customerContact.put('email', invoice.fw1__Contact__r.Email);
         customerContact.put('mobile', invoice.fw1__Contact__r.MobilePhone);
        requestBody.put('customerContact', customerContact);
         system.debug('customerContact--'+customerContact);
        
        // Add order header information from Invoice
        Map<String, Object> orderHeader = new Map<String, Object>();
        orderHeader.put('eCommerceOrderNumber', invoice.Name);
        orderHeader.put('customerOrderReference', invoice.Name);
        //orderHeader.put('eCommerceOrderNumber', 'Order-9199291x1');
        //orderHeader.put('customerOrderReference', 'Order-919999'); 
        orderHeader.put('systemOrderType', 1);
        orderHeader.put('deliveryMethodId', 1); 
        orderHeader.put('orderGross', invoice.fw1__Total_Invoice_Amount__c); 
        orderHeader.put('deliveryGross', invoice.fw1__Shipping_And_Handling__c);
        //orderHeader.put('deliveryTax', invoice.fw1__Tax_Amount__c); 
       	Datetime requiredDate = DateTime.newInstance(invoice.fw1__Invoice_Date__c.year(), invoice.fw1__Invoice_Date__c.month(), invoice.fw1__Invoice_Date__c.day());
		orderHeader.put('orderDate',requiredDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''));
        orderHeader.put('requiredDate', requiredDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')); // Invoice Date
        orderHeader.put('promisedDate', requiredDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')); // Invoice Date
        requestBody.put('orderHeader', orderHeader);
        system.debug('orderHeader--'+orderHeader);
        
        // Add customer delivery address information from Invoice's custom address field
        Map<String, Object> customerDeliveryAddress = new Map<String, Object>();
        customerDeliveryAddress.put('deliveryName', invoice.fw1__Account__r.Name);
        customerDeliveryAddress.put('contactName', invoice.fw1__Contact__r.Name);
        customerDeliveryAddress.put('address1',invoice.fw1__Account__r.Billing_Address__c.getStreet());
        customerDeliveryAddress.put('town', invoice.fw1__Account__r.Billing_Address__c.getCity());
        customerDeliveryAddress.put('country', invoice.fw1__Account__r.Billing_Address__c.getCountry());
        customerDeliveryAddress.put('countryCode',invoice.fw1__Account__r.Billing_Address__c.getCountryCode());
        customerDeliveryAddress.put('postcode', invoice.fw1__Account__r.Billing_Address__c.getPostalCode());
        //customerDeliveryAddress.put('deliveryMethodId', 1); 
        requestBody.put('customerDeliveryAddress', customerDeliveryAddress);
        system.debug('customerDeliveryAddress--'+customerDeliveryAddress);
        
        // Add order lines from Invoice Lines
        List<Map<String, Object>> orderLines = new List<Map<String, Object>>();
        for(fw1__Invoice_Line__c lineItem : invoice.fw1__Invoice_Lines__r) {
            Map<String, Object> orderLine = new Map<String, Object>();
            orderLine.put('variantCode',  lineItem.fw1__Product2__r.StockKeepingUnit);
            orderLine.put('itemNumber', lineItem.fw1__Product2__r.Name);
           	//orderLine.put('description', lineItem.fw1__Product2__r.Description);
            orderLine.put('quantity', lineItem.fw1__Quantity__c);
            Decimal roundedSalesPrice = lineItem.fw1__Unit_Price__c.setScale(2);
            Decimal roundedListPrice = lineItem.fw1__Amount__c.setScale(2);
            orderLine.put('itemGross',roundedSalesPrice);
            orderLine.put('itemNet',roundedListPrice); 
           // orderLine.put('taxRateId', 2); 
            orderLine.put('promisedDate', requiredDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')); // Invoice Date
            orderLine.put('requiredDate', requiredDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')); // Invoice Date
            orderLine.put('stockLocationId', 1);
            orderLines.add(orderLine);
        }
        requestBody.put('orderLines', orderLines);
        system.debug('orderLines--'+orderLines);
        
        // Add order discounts (if needed)
       /* List<Map<String, Object>> orderDiscounts = new List<Map<String, Object>>();
        Map<String, Object> orderDiscount = new Map<String, Object>();
        orderDiscount.put('description', 'Standard Discount');
        orderDiscount.put('amount', invoice.fw1__Total_Invoice_Discount_Amount__c); 
        orderDiscounts.add(orderDiscount);
        requestBody.put('orderDiscounts', orderDiscounts); 
        system.debug('orderDiscounts--'+orderDiscounts);*/ // ++++++++++++++++ For this bussiness model not required++++++++++++

        String requestBodyJSON = JSON.serialize(requestBody);

        HttpRequest request = new HttpRequest();
        String endpoint = 'http://195.224.7.134:8443/OWAPI-Sandbox/sales/order?session_id=31';
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + authToken);
        request.setHeader('Content-Type', 'application/json');
        request.setBody(requestBodyJSON);

        Http http = new Http();
        HttpResponse response = http.send(request);

        if (response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
            System.debug('Order created successfully.');
            System.debug('Response Status Code: ' + response.getStatusCode());
    		System.debug('Response Body: ' + response.getBody());
            Task task = new Task();
                task.WhatId = invoice.Id;
                task.Subject = 'Sales order has been created on Otherwise ERP system successfully.';
                task.Description = 'Sales order has been created on Otherwise ERP system successfully.';
                task.Priority = 'Normal';
                task.ActivityDate = system.today();
                task.Status = 'Completed';
                task.OwnerId = UserInfo.getUserId();
                System.debug ('task created' +task);
             try {
                insert task;
             } catch(Exception e) {
                System.debug('Error: ' + e.getMessage());
            }
        } else {
            System.debug('Error creating order: ' + response.getStatusCode() + ' - ' + response.getStatus());
            System.debug('Response body: ' + response.getBody());
            Task task = new Task();
                task.WhatId = invoice.Id;
                task.Subject = 'Failed';
                task.Description = response.getBody();
                task.Priority = 'Normal';
                task.ActivityDate = system.today();
                task.Status = 'Completed';
                task.OwnerId = UserInfo.getUserId();
                System.debug ('task created' +task);
             try {
                insert task;
             } catch(Exception e) {
                System.debug('Error: ' + e.getMessage());
            }
        }
    }
}