trigger OpportunityTrigger on Opportunity (before insert,before update) {
  if(trigger.isBefore &&((Trigger.isInsert) || (Trigger.isUpdate)))
      for(Opportunity opp:Trigger.new)
  {
      if(opp.StageName == 'TO-Onboard')
      {
          opp.Activity_Status__c='To-Onboard';
      }
  }
}