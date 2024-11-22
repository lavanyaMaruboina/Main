trigger StoreMaskedKYCNo on Documents__c (after update, after insert) {
    List<Documents__c> docList = new List<Documents__c>();
    Map<Id, Documents__c> docsMap = new Map<Id, Documents__c>([SELECT Id, Opportunity_Relation__r.LeadSource FROM Documents__c WHERE ID IN: trigger.newMap.keySet()]);
    for(Documents__c docObj : trigger.new){ 
        if(docObj.Document_Type__c == System.label.AadhaarCard && docObj.KYC_No__c != null && docObj.Masked_KYC_No__c==null){
            Documents__c doc = new Documents__c(Id=docObj.Id);
            if(docsMap.get(docObj.Id).Opportunity_Relation__r?.LeadSource != 'D2C'){
                doc.Masked_KYC_No__c = '********'+IntegrationUtilities.getDecryptedResponse(docObj.KYC_No__c,System.Label.privateKey,System.Label.ivkey).right(4);//CISP-3038
            }else{
                doc.Masked_KYC_No__c = '********'+docObj.KYC_No__c.right(4);
            }    
            docList.add(doc);
        }// else if ((docObj.Document_Type__c == System.label.DrivingLicences || docObj.Document_Type__c == System.label.VoterIdCard) && docObj.KYC_No__c != null && docObj.Masked_KYC_No__c==null) {
        //     Documents__c doc = new Documents__c(Id=docObj.Id);
        //     //doc.Masked_KYC_No__c = docObj.KYC_No__c;
        //     // doc.Masked_KYC_No__c = IntegrationUtilities.getDecryptedResponse(docObj.KYC_No__c,System.Label.privateKey,System.Label.ivkey);//CISP-3038
        //     docList.add(doc);
        // }
    }
    if(!docList.isEmpty()){
        update docList;
    }
}