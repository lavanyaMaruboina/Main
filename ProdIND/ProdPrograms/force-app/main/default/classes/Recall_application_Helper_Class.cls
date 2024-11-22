/**
* @Name         Recall_application_Helper_Class
* @Author       Saloni Jadhav	
* @Company      Persistent Systems
* @Description  This class is helper to the Recall_application class, to open up the access for the Custom Lookup component.
				We are facing issues with User for Community users, so using this class to give access.
* Inputs:       None
* Test Class:   
*/

public without sharing class Recall_application_Helper_Class {
    /*
    * @Method:      searchUser
    * @Created by:  Saloni Jadhav
    * @Description: This method is generic method that will return the data based on input parameters provided.
    * @Param:       String - Query (field name that needs to be fetched).
    * @Return:      String.
    */
    @AuraEnabled(Cacheable=true)
    public static String searchUserHelper(String new_owner){
        UserRole rol = [SELECT Name FROM UserRole WHERE Id IN (SELECT UserRoleId FROM User WHERE Id=:new_owner)]; 
        return rol.Name;
    }
}