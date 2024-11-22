/**
* @Name         Ind_CustomLookupController
* @Author       Khushiram
* @Company      Persistent Systems
* @Description  This class contains all methods related to Custom Lookup.
* Inputs:       None
* Test Class:   Ind_CustomLookupCntrlTest
*/
public with sharing class Ind_CustomLookupController {
	/*
    * @Method:      searchLookup
    * @Created by:  Khushiram
    * @Description: This method is generic method that will return the data based on input parameters provided.
    * @Param:       String - fetchField (field name that needs to be fetched).
    * @Param:       String - objectName (object name from which data will be fetched).
    * @Param:       String - searchField (field name against which query condition will be checked)
    * @Param:       String - searchTerm (searchTerm is the text which will be checked in searchField)
    * @Param:       String - filterField (filter field is being used to filter the records)
    * @Param:       String - filterTerm (filter term is used as a condition on the filter field)
    * @Return:      List of sObjects.
    */
    @AuraEnabled(Cacheable=true)
    public static List<sObject> searchLookup(String fetchField,string objectName,String searchField,String searchTerm,String filterField,String filterTerm ) {
        try{
             String myQuery = null;
            if(fetchField != null && objectName != null && searchField != null && searchTerm != null && filterField != null && filterTerm != null){
               
                if(filterField != null && filterTerm != null && filterField != '' && filterTerm != ''){
                    myQuery = 'Select Id,'+fetchField+' from '+objectName+' Where '+searchField+' Like  \'' + searchTerm + '%\' AND '+filterField+' =\''+filterTerm+'\' WITH SECURITY_ENFORCED';
                } 
                else{
                    system.debug('here searchField '+searchField+' searchTerm '+' filterField '+filterField+' filterTerm'+filterTerm);
                    myQuery = 'Select id,'+fetchField+' from '+objectName+' Where '+searchField+' Like  \'' + searchTerm + '%\' WITH SECURITY_ENFORCED';
                } 
               
                List<sObject> lookUpList = Ind_CustomLookupController_Helper.searchLookupHelper(myQuery);
                //List<sObject> lookUpList = database.query(myQuery);        
                return lookUpList;
            }
             else if(fetchField != null && objectName != null && filterField != '' && filterTerm != ''){
                     myQuery = 'Select Id,'+fetchField+' from '+objectName+' Where '+filterField+' =\''+filterTerm+'\' WITH SECURITY_ENFORCED';
                  System.debug('hereeee  '+myQuery);
                  List<sObject> lookUpList = Ind_CustomLookupController_Helper.searchLookupHelper(myQuery);
                  //List<sObject> lookUpList = database.query(myQuery);  
                return lookUpList;
              
            }
            else if(fetchField != null && objectName != null){
                    system.debug('here elif');
                     myQuery = 'Select '+fetchField+' from '+objectName+' WITH SECURITY_ENFORCED';
                     List<sObject> lookUpList = Ind_CustomLookupController_Helper.searchLookupHelper(myQuery);
                     //List<sObject> lookUpList = database.query(myQuery);         
                return lookUpList;
              
                }
           
            return null;
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('Ind_CustomLookupController', 'searchLookup', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage); 
        }
    }

     /*
    * @Method:      searchLookupWithArray
    * @Created by:  Jitendra Sharma
    * @Description: This method is generic method that will return the data based on input parameters provided.
    * @Param:       String - list of fetchField (field name that needs to be fetched).
    * @Param:       String - objectName (object name from which data will be fetched).
    * @Param:       String - searchField (field name against which query condition will be checked)
    * @Param:       String - searchTerm (searchTerm is the text which will be checked in searchField)
    * @Param:       String - list of filterField (filter field is being used to filter the records)
    * @Param:       String - filterTerm (filter term is used as a condition on the filter field)
    * @Return:      List of sObjects.
    */
    @AuraEnabled(Cacheable=true)
    public static List<sObject> searchLookupWithArray(List<String> fetchField,string objectName,String searchField,
    String searchTerm,
        List<String> filterField,List<String> filterTerm, List<String> filterMultipleTerm, String filterMultipleFieldName) {
        try{
            String myQuery = 'Select Id ' ;
                for(Integer counter=0; counter<fetchField.size();counter++) {
                    myQuery += ', '+ fetchField[counter];
                }
                
                if(fetchField != null && objectName != null && searchField != null && searchTerm != null && filterField != null && filterTerm != null){
                
                    if(filterField != null &&  filterField.size()>0){
                        myQuery = myQuery + ' from '+objectName+' Where '+searchField+' Like  \'' + searchTerm + '%\' AND ';
                        for(Integer i=0;i< filterField.size(); i++) {    
                            if(i == filterField.size()-1) {                
                                if(filterMultipleTerm != null && filterMultipleFieldName != null){
                                    myQuery += filterMultipleFieldName + ' IN ' + '(';
                                    for(Integer j=0;j< filterMultipleTerm.size(); j++){
                                        if(j == filterMultipleTerm.size()-1){
                                            myQuery += '\'' +filterMultipleTerm[j]+ '\'';
                                        }
                                        else{
                                            myQuery += '\'' +filterMultipleTerm[j]+ '\'' + ',';
                                        }
                                    }
                                    myQuery += ')' + ' AND ' ;
                                }              
                                myQuery +=  filterField[i]+' =\''+filterTerm[i]+'\'  WITH SECURITY_ENFORCED';
                            } else {
                                myQuery +=  filterField[i]+' =\''+filterTerm[i]+'\'  AND ';
                            }
                        }
                    } 
                    else{
                        myQuery = myQuery + ' from '+objectName+' Where '+searchField+' Like  \'' + searchTerm + '%\' WITH SECURITY_ENFORCED';
                    } 
                    List<sObject> lookUpList = Ind_CustomLookupController_Helper.searchLookupHelper(myQuery);
                    //List<sObject> lookUpList = database.query(myQuery); 
                        
                    return lookUpList;
                }
                else if(fetchField != null && objectName != null ){
                        myQuery = myQuery +' from '+objectName+' Where '+filterField+' =\''+filterTerm+'\' WITH SECURITY_ENFORCED';
                        List<sObject> lookUpList = Ind_CustomLookupController_Helper.searchLookupHelper(myQuery);
                        //List<sObject> lookUpList = database.query(myQuery); 
                    return lookUpList;
                
                }
                else if(fetchField != null && objectName != null){
                        myQuery = myQuery + ' from '+objectName+' WITH SECURITY_ENFORCED';
                        List<sObject> lookUpList = Ind_CustomLookupController_Helper.searchLookupHelper(myQuery);
                        //List<sObject> lookUpList = database.query(myQuery); 
                    return lookUpList;                
                }            
           
            return null;
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('Ind_CustomLookupController', 'searchLookup', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage); 
        }
    }
}