public class CMURejectComponentController {

    @AuraEnabled
    public static List<Documents__c> getDocumentsList(String oppId){
        String userId = UserInfo.getUserId();
        List<Documents__c> docsList = [SELECT Id,Name,Is_Rejected_By_CMU__c,Rejection_Fields__c 
                                       FROM Documents__c WHERE CMU_Accept_Reject__c = 'Reject' 
                                       AND Opportunity_Relation__r.OwnerId =: userId];
        if(docsList != null && docsList.size() > 0){
            return docsList;
        }
        return null;
    }
  
    @AuraEnabled
    public static List<Documents__c> getDocumentDetails(String docId){
        List<Schema.FieldSetMember> fieldList = readFieldSet('IND_LWC_CMURejectFields', 'Documents__c');
        String docQuery = 'SELECT ';
        for(Schema.FieldSetMember fieldMember : fieldList){
            docQuery += fieldMember.getFieldPath() + ',';
        }
        docQuery += 'Id FROM Documents__c WHERE Id = \''+ docId +'\' LIMIT 1';
        System.debug('docQuery ### ' + docQuery);
        return Database.query(docQuery);
    }

    private static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName){
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields(); 
    }
}