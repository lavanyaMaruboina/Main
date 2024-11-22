trigger TaskTrigger on Task (after insert) {
    
    Map<Id, Applicant__c> appUpdateMap = new Map<Id, Applicant__c>();
    if(Trigger.isAfter && Trigger.isInsert){
        Set<Id> applicantIdSet = new Set<Id>();
        for(Task t : Trigger.new){
            if(t.WhatId != null && String.valueOf(t.WhatId.getsobjecttype()) == 'Applicant__c'){
                applicantIdSet.add(t.WhatId);
            }
        }
        if(!applicantIdSet.isEmpty()){
            Map<Id, Applicant__c> appMap = new Map<Id,Applicant__c>([SELECT Id, Disposition__c, Sub_Disposition__c, Agents__c from Applicant__c WHERE Id IN: applicantIdSet]);
            for(Task t : Trigger.new){
                if(t.WhatId != null && appMap.containsKey(t.WhatId)){
                    Applicant__c app = appMap.get(t.WhatId);
                    app.Disposition__c = t.Disposition__c;
                    app.Sub_Disposition__c = t.Sub_Disposition__c;
                    app.Comments__c = t.Remarks__c;
                    app.Latest_Task_Created_Date__c = DateTime.now();
                    if(app.Agents__c == null){
                        app.Agents__c = t.OwnerId;
                    }
                    else{
                        String[] agentIds = app.Agents__c.split(',');
                        if(!agentIds.contains(t.OwnerId)){
                            app.Agents__c += ','+t.OwnerId;
                        }
                    }
                    appUpdateMap.put(app.Id, app);
                }
            }
            if(!appUpdateMap.isEmpty() && Schema.SObjectType.Applicant__c.isUpdateable()){
                update appUpdateMap.values();
            }
        }
    }
}