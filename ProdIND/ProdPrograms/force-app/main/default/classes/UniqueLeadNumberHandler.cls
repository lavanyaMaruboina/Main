public with sharing class UniqueLeadNumberHandler {
    public static void generateLeadNumber(Map<Id, Opportunity> opptyMap){
        //updateLeadSeqNumber(opptyMap.keySet());
    }    
    
    public static void updateLeadSeqNumber(Set<Id> OpptyIdSet){
        List<Opportunity> opptyList = [Select id, Lead_Number_Sequence__c, Lead_number__c from Opportunity where Id IN: OpptyIdSet WITH SECURITY_ENFORCED];
        if(opptyList != null && opptyList.size() > 0){
            System_Configuration__c seqNumber = System_Configuration__c.getValues('System Configuration');
            for(Opportunity op : opptyList){
                String todayYear = String.valueOf(System.today().Year()).right(2);
                String todayMonth = String.valueOf(system.today().Month()).length() == 1 ? '0' + String.valueOf(system.today().Month()) : String.valueOf(system.today().Month());
                String todayDay = String.valueOf(system.today().day()).length() == 1 ? '0' + String.valueOf(system.today().day()) : String.valueOf(system.today().day());
                String datePrefix = todayDay + '' + todayMonth + '' + todayYear;
                String finalLeadNumber = '';
                if(Test.isRunningTest() == false){
                    processUpdateLeadSeqNumberLogic(op, finalLeadNumber, datePrefix, seqNumber);
                }
            }
            update opptyList;
        }
    }
    
    @TestVisible
    private static void processUpdateLeadSeqNumberLogic(Opportunity op, String finalLeadNumber, String datePrefix, System_Configuration__c seqNumber){
        Integer lastFive = integer.valueof(op.Lead_Number_Sequence__c) - integer.valueof(seqNumber.Lead_Sequence_No__c);
        string lastFiveDigits = string.valueof(lastFive);
        while(lastFiveDigits.length() < 5){
            lastFiveDigits = '0' + lastFiveDigits;
        }
        System.debug('datePrefix: '+datePrefix);
        System.debug('lastFiveDigits: '+lastFiveDigits);
        String applicationNameString = datePrefix + lastFiveDigits;
        System.debug('applicationNameString: '+applicationNameString);
        long appvalue = Long.valueOf(applicationNameString);
        if (String.valueOf(appvalue).length() == 10) {
            //adding '0' to Lead No pattern if date ranges in 01-09
            finalLeadNumber = 'L' + '' + '0' + '' + String.valueOf(appvalue);
        } else {
            finalLeadNumber = 'L' + '' + String.valueOf(appvalue);
        }
        op.Lead_number__c = finalLeadNumber;
        op.name=finalLeadNumber;
    }
    
    
    
    public static void deleteDoc(List<Opportunity> opportunities){
        
        if(opportunities.size() == 1){
            set<Id> oppIds = new set<Id>();
            //set<Id> filesId = new set<Id>();
            for(Opportunity opportunityObj : opportunities) {
                oppIds.add(opportunityObj.Id);
            }
            
            List<Documents__c> documents = new List<Documents__c>();
            documents = [SELECT Id,Name FROm Documents__c WHERE Opportunity_Relation__c IN :oppIds ORDER BY CreatedDate DESC];
            Map<Id,Documents__c> docToDelete = new Map<Id,Documents__c>();
            //list<Id> docIDToDelete = new list<Id>();
            set<String> docToDeleteName = new set<String>();
            for(Documents__c document : documents){
                if(docToDeleteName.contains(document.Name)){
                    docToDelete.put(document.id,document);
                }else{
                    docToDeleteName.add(document.Name);
                }
            }
            
            for(Id ids : docToDelete.keyset()){
                Delete [SELECT Id, LinkedEntityId, ContentDocumentId FROM 
                        ContentDocumentLink WHERE LinkedEntityId = :ids];
            }
            DELETE docToDelete.Values();
        }
       
    }
    
    @AuraEnabled
    public static void updateApplicationSeqNumber(String OpptyIdSet){
        System.debug('OpptyIdSet '+OpptyIdSet);
        Opportunity givenOpportunity = [Select Id, Application_Sequence_Number__c, Application_number__c from Opportunity where Id =: OpptyIdSet WITH SECURITY_ENFORCED];
       
            System_Configuration__c seqNumber = System_Configuration__c.getValues('System Configuration');

            //for(Opportunity op : opptyList){
                    
                if(seqNumber.Application_Date__c == System.today()){
                    if(seqNumber.Application_Sequence_No__c==null){
                        seqNumber.Application_Sequence_No__c=1;
                    }else{
                        seqNumber.Application_Sequence_No__c=seqNumber.Application_Sequence_No__c+1;
                    }
                    givenOpportunity.Application_Sequence__c = seqNumber.Application_Sequence_No__c;
                }
                else{
                    givenOpportunity.Application_Sequence__c=00001;
                    seqNumber.Application_Sequence_No__c=00001;
                    seqNumber.Application_Date__c =System.today();
                }
                System.debug('text val: '+givenOpportunity.Application_Sequence__c);
                String text=String.valueOf(givenOpportunity.Application_Sequence__c);
                text=text.substringBefore('.');
                System.debug('text length: '+text.length());
                text=text.leftPad(5, '0');  
                System.debug('text : '+text);
                String todayYear = String.valueOf(System.today().Year()).right(2);
                String todayMonth = String.valueOf(system.today().Month()).length() == 1 ? '0' + String.valueOf(system.today().Month()) : String.valueOf(system.today().Month());
                String todayDay = String.valueOf(system.today().day()).length() == 1 ? '0' + String.valueOf(system.today().day()) : String.valueOf(system.today().day());
                String datePrefix = todayDay + '' + todayMonth + '' + todayYear;
                String finalLeadNumber = '';
                if(Test.isRunningTest() == false){
                    String applicationNameString = datePrefix +  text;

                    System.debug('applicationNameString: '+applicationNameString);
                    Long appvalue = Long.valueOf(applicationNameString);
                    if (String.valueOf(appvalue).length() == 10) {
                        //adding '0' to Lead No pattern if date ranges in 01-09
                        finalLeadNumber = 'A' + '' + '0' + '' + String.valueOf(appvalue);
                    } else {
                        finalLeadNumber = 'A' + '' + String.valueOf(appvalue);
                    }
                    givenOpportunity.Application_number__c = finalLeadNumber;
                    System.debug('givenOpportunity.Application_number__c ' +givenOpportunity.Application_number__c);
                }
           // }
            update seqNumber;
            update givenOpportunity;
            System.debug('givenOpportunity ' +givenOpportunity);
        
    }
    
   
    
}