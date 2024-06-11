trigger DistanceCalTriggerOnCheckINOUT on Check_IN_Out__c (before insert) {
    if(Trigger.isInsert){
        if(Trigger.isAfter){
           // DistanceCalCon.desCalcon(Trigger.New);
      }
    }

}