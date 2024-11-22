/**
* @Name         UserTriggerHandler
* @Author       Rajat Jaiswal
* @Description  This trigger handler is used to give CAM screen read access when a user inserted or updated.
**/
public with sharing class UserTriggerHandler {
    public static final Set<String> PROFILE_NAMES = new Set<String>();
    public static final Set<String> INCIDENT_PROFILE_NAMES = new Set<String>();
    
    public static void userAccessPermission(List<User> userList) {
        try {
            PROFILE_NAMES.addAll([SELECT Profile_Name_for_CAM_Access__c FROM IBL_Configuration__mdt WHERE DeveloperName = 'default'].Profile_Name_for_CAM_Access__c.split(','));
            INCIDENT_PROFILE_NAMES.addAll([SELECT Incident_Access_Profile_List__c FROM IBL_Configuration__mdt WHERE DeveloperName = 'default'].Incident_Access_Profile_List__c.split(','));
            Id permissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'CAM_Screen_Read_Access'].Id;
              //CISP:2482
            Id permissionSetIdSSO = [SELECT Id FROM PermissionSet WHERE Name =:System.label.SSO_Permission_Set].Id;
            List<PermissionSetAssignment> existingPSAList = [SELECT Id, AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId = :permissionSetId AND AssigneeId IN :userList];
            //CISP:2482
            List<User> licenseListTwo = [SELECT Id,Name,Profile.Name,Profile.UserLicense.Name FROM User WHERE Id IN :userList and Profile.Name!='System Administrator'];
            List<User> licenseList = [SELECT Id,Name,Profile.Name,Profile.UserLicense.Name FROM User WHERE Id IN :userList];
            List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
            if (!licenseList.isEmpty()) {
                Id permissionSetInternalId = [SELECT Id FROM PermissionSet WHERE Name = 'IBL_Incident_Management_PS_Business_Executiv'].Id;
                List<PermissionSetAssignment> existingInternalList = [SELECT Id, AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId = :permissionSetInternalId AND AssigneeId IN :licenseList];
                Id permissionSetExternalId = [SELECT Id FROM PermissionSet WHERE Name = 'Incident_Management_Partner_user_PS'].Id;
                List<PermissionSetAssignment> existingExternalList = [SELECT Id, AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId = :permissionSetExternalId AND AssigneeId IN :licenseList];
                
                Set<Id> existingAssigneeInternalIdSet = new Set<Id>();
                if (!existingInternalList.isEmpty()) {
                    for (PermissionSetAssignment psaRecord : existingInternalList) {
                        existingAssigneeInternalIdSet.add(psaRecord.AssigneeId);
                    }
                }
                Set<Id> existingAssigneeExternalIdSet = new Set<Id>();
                if (!existingExternalList.isEmpty()) {
                    for (PermissionSetAssignment psaRecord : existingExternalList) {
                        existingAssigneeExternalIdSet.add(psaRecord.AssigneeId);
                    }
                }
                Set<Id> incidentProfileIdSet = getIncidentProfileId();
                for (User userObj : licenseList) {
                    if (userObj.Profile.UserLicense.Name == 'Salesforce') {
                        //for Internal Access
                        if (!existingAssigneeInternalIdSet.contains(userObj.Id) && incidentProfileIdSet.contains(userObj.ProfileId)) {
                            psaList.add(new PermissionSetAssignment(PermissionSetId = permissionSetInternalId, AssigneeId = userObj.Id));
                        }
                    } else if(userObj.Profile.UserLicense.Name == 'Partner Community'){
                        //for External Access
                        if (!existingAssigneeExternalIdSet.contains(userObj.Id) && incidentProfileIdSet.contains(userObj.ProfileId)) {
                            psaList.add(new PermissionSetAssignment(PermissionSetId = permissionSetExternalId, AssigneeId = userObj.Id));
                        }
                    }
                }
            }

             //CISP:2482
            if(!licenseListTwo.isEmpty())
            {
                   Set<Id> existingAssigneeSSOSet = new Set<Id>();
              List<PermissionSetAssignment> existingSSOListUser = [SELECT Id, AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId = :permissionSetIdSSO AND AssigneeId IN :licenseListTwo];
                if (!existingSSOListUser.isEmpty()) {
                    for (PermissionSetAssignment psaRecord : existingSSOListUser) {
                        existingAssigneeSSOSet.add(psaRecord.AssigneeId);// Add all existing users
                    }
                }
               for(user SsoPer:licenseListTwo )
               {
                    if (!existingAssigneeSSOSet.contains(SsoPer.Id))//check not present
                    psaList.add(new PermissionSetAssignment(PermissionSetId = permissionSetIdSSO, AssigneeId = SsoPer.id));
               }
            }
            
            Set<Id> existingAssigneeIdSet = new Set<Id>();
            if (!existingPSAList.isEmpty()) {
                for(PermissionSetAssignment psaRecord : existingPSAList) {
                    existingAssigneeIdSet.add(psaRecord.AssigneeId);
                }
            }
            Set<Id> profileIdSet = getProfileId();
            
            for (User userRecord : userList) {
                if(!existingAssigneeIdSet.contains(userRecord.Id) && profileIdSet.contains(userRecord.ProfileId)){
                    psaList.add(new PermissionSetAssignment(PermissionSetId = permissionSetId, AssigneeId = userRecord.Id));
                }
            }
            if (psaList.size() > 0) {
                Database.SaveResult[] results = Database.insert(psaList,false);
            }
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('UserTriggerHandler', 'userAccessPermission', e.getTypeName(), e, '');
        }
    }
    
    private static Set<Id> getProfileId() {
        return new Map<Id, Profile>([SELECT Id, Name FROM Profile WHERE Name IN :PROFILE_NAMES]).keySet();
    }
    private static Set<Id> getIncidentProfileId() {
        return new Map<Id, Profile>([SELECT Id, Name FROM Profile WHERE Name IN :INCIDENT_PROFILE_NAMES]).keySet();
    }
}