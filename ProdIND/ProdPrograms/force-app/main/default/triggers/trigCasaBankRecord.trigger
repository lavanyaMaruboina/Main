trigger trigCasaBankRecord on CASA_Bank_Form__c (before insert, after insert , after update) {

    if((trigger.isInsert && trigger.isBefore)){      
        CASAbankFormTriggerhandler.generateUniqueFormNumber(trigger.new);
     }
     
    }