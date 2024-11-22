/*
* @Name         IND_LWC_LeadAssignmentCtrl
* @Author       Nitin Sehgal
* @Company      Persistent Systems
* @Description  This class contains all the methods related to Lead & Module Assignment/Recall.
* Inputs:       None
* Test Class:   IND_LWC_LeadAssignmentCtrlTest
* History:
*/
							
public with sharing class IND_LWC_LeadAssignmentCtrl {
  
    //This map is used to store the user id, and their role id.
    static Map<Id,UserRole> all_roles;
    
    /*
    * @Method:      recordHierarchyCheck
    * @Created by:  Khushiram
    * @Description: To check the role of current logged in user in the hierarchy.
    * @Param:       String - current logged-in user role id.
    * @Param:       String - record owner id.
    * @Return:      Boolean - True(If current logged-in user is above in the hierarchy of record owner). Otherwise False.
    */
    @AuraEnabled
    public static Boolean recordHierarchyCheck(String checkRoleId, String checkOwnerId){
        try{
            // If we are checking the same role as the logged-in user, it is not considered 'above' unless the user is the owner.
            if( checkRoleId == UserInfo.getUserRoleId() ){ return UserInfo.getUserId() == checkOwnerId; } 
            
            if( all_roles == NULL ){ all_roles = new Map<Id,UserRole>([SELECT Id, ParentRoleId FROM UserRole WITH SECURITY_ENFORCED ]); } // Get the roles.        
            if( !all_roles.containsKey(checkRoleId) ){ return false; } // Return false if an invalid role was provided.
            UserRole role = all_roles.get(checkRoleId); // Otherwise get the role we are checking.
            
            // if there is no parent role, the checked role is the ceo and no one is above them in heirarchy except themselves (which we checked for in the prior step).
            if( role.ParentRoleId == NULL ){ return False; } 
            
            // Loop through them until the end of the hierarchy is reached, or the user's role is found as a parent.
            do {
                role = all_roles.get(role.ParentRoleId); // Advance to the next parent.
            }
            // End the loop when the parent is null (CEO is reached) or the current user's role is reached.
            while ( role.ParentRoleId != NULL && role.Id != UserInfo.getUserRoleId() );
            
            // Now that the loop has ended, either we reached the end of the hierarchy (no match to user) or we found the current user's role (in which case they are above).
            return  role.Id == UserInfo.getUserRoleId();
        }
       	catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_LWC_LeadAssignmentCtrl', 'recordHierarchyCheck', System.Label.Apex, e);
           throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    
    /*
    * @Method:      leadAssignment
    * @Created by:  Khushiram
    * @Description: This method is used for lead assignment.
    * @Param:       String - current opportunity record id.
    * @Param:       String - selected user id from dropdown.
    * @Return:     	Boolean - True(If lead is assigned successfully).Otherwise False.
    */
    @AuraEnabled
    public static Boolean leadAssignment(Id recordId, Id selectedUserId){
        try{
            Opportunity oppObject = new Opportunity();
            oppObject.id = recordId;
            oppObject.Assign_Application_To__c = selectedUserId;
            if (Schema.sObjectType.Opportunity.isUpdateable()){
                update oppObject;
                return true;
            } 
            return false;
        }
        catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_LWC_LeadAssignmentCtrl', 'leadAssignment', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    
    /*
    * @Method:      leadRecall
    * @Created by:  Khushiram
    * @Description: This method is used for lead recall.
    * @Param:       String - current opportunity record id.
    * @Param:       String - selected user id from dropdown.
    * @Return:     	Boolean - True(If lead is recalled successfully).Otherwise False.
    */   
    @AuraEnabled
    public static Boolean leadRecall(Id recordId, Id recordOwnerId){
        try{
            if(UserInfo.getUserId() == recordOwnerId ){
                Opportunity oppObject = new Opportunity();
                oppObject.id = recordId;
                oppObject.Assign_Application_To__c = null;
                if (Schema.sObjectType.Opportunity.isUpdateable()){
                    update oppObject;
                    return true;
                }
            }
            return false;
        }
        catch(Exception e){
           ErrorLoggerUtil.logErrorEvent('IND_LWC_LeadAssignmentCtrl', 'leadRecall', System.Label.Apex, e);
           throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    
    /*
    * @Method:      filterUserList
    * @Created by:  Nitin Sehgal
    * @Description: Method used to retrive the User names based on the opportunity Owner Role.
    * @Param:       String - current opportunity record id.
    * @Param:       String - search term(user name).
    * @Return:     	List of Users.
    */
    @AuraEnabled(cacheable = true)
    Public static List<User> filterUserList(Id oppId, String searchTerm){
        try{
            List<User> userNames = new List<User>();
            searchTerm = searchTerm+'%';
            
            //Get Opporunity Owner Role
            Opportunity opp = new Opportunity();
            opp = [SELECT Id, Name, OwnerId, Owner.UserRole.Name FROM Opportunity WHERE Id = :oppId];
            if(opp?.Id != null){
                //Get User Roles configured in Custom Settings based on Opportunity owner user role
				List<String> elligibleUserRoles = new List<String>();
				Lead_Assignment_Roles__mdt objSysConfig = [select Eligible_Roles__c from Lead_Assignment_Roles__mdt where label =: opp.Owner.UserRole.Name WITH SECURITY_ENFORCED limit 1];
				elligibleUserRoles.addAll(objSysConfig.Eligible_Roles__c.split(','));
                //Trimming the role, in case of extra space is added by mistake in the custom metadata field.
                for(Integer i=0; i < elligibleUserRoles.size(); i++){                   
                    elligibleUserRoles[i] = elligibleUserRoles[i].trim();                    
                }
                //Query All user names based on elligible roles
                for(User usr :[SELECT id, FirstName, LastName, Name FROM User where UserRole.Name in :elligibleUserRoles AND Name like :searchTerm WITH SECURITY_ENFORCED]){
                    userNames.add(usr);
                }
            }
            return userNames;
        }catch(Exception e){
           ErrorLoggerUtil.logErrorEvent('IND_LWC_LeadAssignmentCtrl', 'filterUserList', System.Label.Apex, e);
           throw new AuraHandledException(System.Label.ExceptionMessage);    
        }
    }
}