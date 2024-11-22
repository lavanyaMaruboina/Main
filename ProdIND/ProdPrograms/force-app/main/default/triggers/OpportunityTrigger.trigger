trigger OpportunityTrigger on Opportunity (after insert,before insert, before update ,after update) {
    Set<Id> oppIdSet = new Set<Id>();
    Set<Id> moveToAssistedIdSet = new Set<Id>();
    Set<Id> vehicleDedupeOppIdSet = new Set<Id>();

    if(Trigger.isBefore && Trigger.isUpdate) {
        D2C_OpportunityHandler.updateLastDropScreen(Trigger.newMap,Trigger.oldMap);
        OpportunityTriggerHelper.updateSubStageField(Trigger.newMap,Trigger.oldMap);//Added by Rohan for DSA
        OpportunityTriggerHelper.updateSubStageFieldD2C(Trigger.newMap,Trigger.oldMap);//Added by Rohan for D2C CFDI-514
    }


    if(Trigger.isAfter && Trigger.isInsert){
    	   
    	For(Opportunity opp : Trigger.new){
        	if(opp.isOfflineApplication__c == true){
        		oppIdSet.add(opp.Id);
        	}        
    	}    
    	if(!oppIdSet.isEmpty()){
        	UniqueLeadNumberHandler.updateLeadSeqNumber(oppIdSet);
    	}
        OpportunityTriggerHelper.publishOlaLeadInsertedEvent(Trigger.new);//OLA-7
    }
    

    //Haarika - 16/08/22 - To call DATAUPLOAD Api whenever an opp is updated as Initial Offer drop
    if(Trigger.isAfter && Trigger.isUpdate){
        D2C_OpportunityHandler.callConvox(Trigger.newMap,Trigger.oldMap);
        
        for (Opportunity newOpp: Trigger.new) {
			Opportunity oldOpp = Trigger.oldMap.get(newOpp.Id);
            
            if((newOpp.D2C_Journey_Status__c != oldOpp.D2C_Journey_Status__c) 
                && (newOpp.LeadSource == 'D2C' ) ){
                
                if(newOpp.D2C_Journey_Status__c == IntegrationConstants.STATUS_MOVE_TO_ASSISTED){
                    System.debug('move to assisted');
                    moveToAssistedIdSet.add(newOpp.Id);
                }
            }
            if(newOpp.Sub_Stage__c != oldOpp.Sub_Stage__c && newOpp.Sub_Stage__c == 'Vehicle Dedupe' && newOpp.LeadSource == 'D2C'){
                vehicleDedupeOppIdSet.add(newOpp.Id);
            }
        }
        
        if(!moveToAssistedIdSet.isEmpty()){
            D2C_OpportunityHandler.sendMoveToAssistedEmail(moveToAssistedIdSet);
        }
        if(!vehicleDedupeOppIdSet.isEmpty()){
            D2C_OpportunityHandler.sendVehicleDedupeEmail(vehicleDedupeOppIdSet);
        }
        OpportunityTriggerHelper.updateOppTeamMember(Trigger.newMap,Trigger.oldMap);//SFD2C-187
    }
 
}