/**
* @Name         UserTrigger
* @Author       Rajat Jaiswal
* @Description  This trigger is used to give CAM screen read access when a user inserted or updated.
**/
trigger UserTrigger on User (after insert, after update) {
    if((trigger.isInsert || trigger.isUpdate) && trigger.isAfter){      
        UserTriggerHandler.userAccessPermission(trigger.new);
    }
}