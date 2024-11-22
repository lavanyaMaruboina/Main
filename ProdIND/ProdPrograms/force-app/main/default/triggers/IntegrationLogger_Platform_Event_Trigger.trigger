trigger IntegrationLogger_Platform_Event_Trigger on Integration_Logger_Event__e (after insert) {
    List<Integration_Log__c> intgLogList = new List<Integration_Log__c>();
    
    for(Integration_Logger_Event__e evtInt: trigger.new){
        //system.debug('evtInt.uidRefId__c ----:'+evtInt.uidRefId__c);
        //if(evtInt.uidRefId__c !=null){
        Integration_Log__c intObj=new Integration_Log__c();
        intObj.Original_request__c = evtInt.Request__c;
        intObj.Original_response__c = evtInt.Response__c;     
        intObj.Encrypted_request__c = evtInt.EncryptedRequest__c;
        intObj.Encrypted_response__c = evtInt.EncryptedResponse__c;  
        intObj.Service_Name__c = evtInt.ServiceName__c; 
        intObj.Elapsed_Time__c = evtInt.Elapsed_Time__c;
        intObj.Loan_Application__c = evtInt.Loan_Application_ID__c;
        intObj.ProCredit_Deals__c = evtInt.ProCredit_Deal__c; 
        intObj.RequestExt__c= evtInt.Request_Ext__c; 
        intObj.ResponseExt__c= evtInt.Response_Ext__c;
        intObj.Status__c = evtInt.Status__c;
        if(String.isNotBlank(evtInt.uidRefId__c)){
            intObj.targetRecordId__c = evtInt.uidRefId__c;
        }
        if(String.isNotBlank(evtInt.Reference_Id__c)){
            intObj.ReferenceId__c = evtInt.Reference_Id__c;
        }
        intgLogList.add(intObj);  
        /*}
        else{
        Integration_Log__c intObj = [Select id, Original_response__c, Encrypted_response__c from Integration_Log__c where Uuid__c =: evtInt.uidRefId__c ];
        intObj.Original_response__c = evtInt.Response__c; 
        intObj.Encrypted_response__c = evtInt.EncryptedResponse__c;  
        intObj.Service_Name__c = evtInt.ServiceName__c; 
        intgLogList.add(intObj);  
        }*/
          
    }
    upsert intgLogList;
}