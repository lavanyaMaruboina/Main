trigger CreateDealNumberBeforeInsert on Deal_Number__c(before insert,before update)
{
    if(RecursiveTriggerHandler.isFirstTime && trigger.isInsert) {   
        RecursiveTriggerHandler.isFirstTime = false;
        for(Deal_Number__c bjdl : Trigger.New) {
            Deal_Number_Setting__c dealNumberSetting = bjdl.ProductCode__c == 'C' ? Deal_Number_Setting__c.getValues(System.Label.PassengerVehicles) : bjdl.ProductCode__c == 'H' ? Deal_Number_Setting__c.getValues(System.Label.TwoWheeler) : bjdl.ProductCode__c == 'T' ? Deal_Number_Setting__c.getValues(System.Label.Tractor) : null;
            bjdl.DNField1__c = dealNumberSetting.MDNField1__c;
            bjdl.DNField2__c = String.valueof(Integer.valueOf(dealNumberSetting.MDNField2__c));
            if(bjdl.ProductCode__c == 'T' && trigger.isbefore) //SFTRAC-395
            bjdl.Deal_Number_Tractor__c = bjdl.DNField1__c + bjdl.DNField2__c + bjdl.ProductCode__c + bjdl.DNField3__c;
        }
    }    
    if(trigger.isUpdate && trigger.isbefore){ //SFTRAC-395
        for(Deal_Number__c bjdl : Trigger.New) {
            if(bjdl.ProductCode__c == 'T'){
            if(bjdl.DNField1__c != trigger.oldmap.get(bjdl.id).DNField1__c || bjdl.DNField2__c != trigger.oldmap.get(bjdl.id).DNField2__c || bjdl.DNField3__c != trigger.oldmap.get(bjdl.id).DNField3__c)
            bjdl.Deal_Number_Tractor__c = bjdl.DNField1__c + bjdl.DNField2__c + bjdl.ProductCode__c + bjdl.DNField3__c;
            }
        }
    }
}