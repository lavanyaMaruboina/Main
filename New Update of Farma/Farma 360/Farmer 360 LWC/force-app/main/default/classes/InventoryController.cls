public class InventoryController {
	@AuraEnabled
    public static void createInventory(String name, Boolean active, String contactId, String productId, String streetaddress){
        try{
            Inventory__c invDetails = new Inventory__c();
            invDetails.Name = name;
            invDetails.Active__c = active;
            invDetails.Contact__c = contactId;
            invDetails.Product__c = productId;
			invDetails.Address__Street__s =  streetaddress;  
            
            insert invDetails;
            System.debug('Inventory Details Record created with Id: ' + invDetails.Id);
        }catch(Exception e) {
            System.debug('Error creating Inventory Details Record: ' + e.getMessage());
    }
}
}