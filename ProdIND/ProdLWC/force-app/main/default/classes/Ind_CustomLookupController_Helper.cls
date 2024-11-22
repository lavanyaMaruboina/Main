/**
* @Name         Ind_CustomLookupController
* @Author       Manish Baldota	
* @Company      Persistent Systems
* @Description  This class is helper to the Ind_CustomLookupController class, to open up the access for the Custom Lookup component.
				We are facing issues with AccountTeamMember for Community users, so using this class to give access.
* Inputs:       None
* Test Class:   Ind_CustomLookupCntrlTest
*/
public without sharing class Ind_CustomLookupController_Helper {
	/*
    * @Method:      searchLookup
    * @Created by:  Manish Baldota
    * @Description: This method is generic method that will return the data based on input parameters provided.
    * @Param:       String - Query (field name that needs to be fetched).
    * @Return:      List of sObjects.
    */
    @AuraEnabled(Cacheable=true)
    public static List<sObject> searchLookupHelper(String query){
        List<sObject> lookUpList = database.query(query); 
        return lookUpList;
    }
}