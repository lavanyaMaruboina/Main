/**
 * @Name         IND_LWC_ChangeCaseOwner
 * @Author       Udit Singhal
 * @Company      Salesforce
 * @Description  This class contains all methods related to Change Case Owner LWC component
 * Test Class:   IND_LWC_ChangeCaseOwnerTest
 */
public without sharing class IND_LWC_ChangeCaseOwner{
    static final String GROUP_TYPE = 'Queue';
    static final String QUEUE_NAME = 'CMU';
    static final String VALID_CASE_RECORDTYPE_NAME = 'CMU_Request';
    
    /*
    * @Method:      getCMUQueueId
    * @Created by:  Udit Singhal
    * @Description: This method will return the Id of CMU Queue
    * @Return:      Id
    */
    @AuraEnabled(Cacheable = true)
    public static Id getCMUQueueId(){
        try{
            List<Group> groupList = new List<Group>();

            groupList = [SELECT Id
                         FROM Group
                         WHERE Type = :GROUP_TYPE  
                         AND Name = :QUEUE_NAME 
                         WITH SECURITY_ENFORCED]; 
            if (groupList.size() < 1){
                throw new AuraHandledException('CMU Queue not found.');
            } else{
                return groupList[0].Id;
            }
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
    * @Method:      getUsersFromQueue
    * @Created by:  Udit Singhal
    * @Description: This method will return the the list of users from queue based on input parameters provided
    * @Param:       Id - queueId (queue from where users will be fetched)
    * @Param:       String - searchField (field name against which query condition will be checked)
    * @Param:       String - searchTerm (value which will be checked against searchTerm)
    * @Return:      List of sObjects
    */
    @AuraEnabled(Cacheable = true)
    public static List<sObject> getUsersFromQueue(Id queueId, String searchField, String searchTerm){
        try{
            String myQuery = '';
            myQuery = 'SELECT Id, Name FROM User WHERE IsActive = true AND ';

            if (searchField != null && searchTerm != null){
                myQuery += '' + searchField + ' Like  \'' + searchTerm + '%\' AND ';
            }

            myQuery += 'Id IN (SELECT UserOrGroupId FROM GroupMember WHERE GroupId =\'' + queueId + '\') WITH SECURITY_ENFORCED ORDER BY Name ASC';

            List<sObject> lookUpList = Ind_CustomLookupController_Helper.searchLookupHelper(myQuery);

            return lookUpList;
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
    * @Method:      validateCaseRecordType
    * @Created by:  Udit Singhal
    * @Description: This method will check all the cases from input parameters provided and verify if they belong to CMU_Request recordtype
    * @Param:       List<Id> - selectedCaseList (Ids of cases selected from list view)
    * @Return:      Boolean
    */
    @AuraEnabled(Cacheable = true)
    public static Boolean validateCaseRecordType(List<Id> selectedCaseList){
        Boolean isAllSelectedCasesValid = true;
        try{
            List<Case> caseList = [SELECT Id, RecordType.DeveloperName  
                                   FROM Case 
                                   WHERE Id  
                                   IN:selectedCaseList 
                                   WITH SECURITY_ENFORCED]; 

            for (Case caseRecord : caseList){
                if (caseRecord.RecordType.DeveloperName != VALID_CASE_RECORDTYPE_NAME){
                    isAllSelectedCasesValid = false;
                    break;
                }
            }
            return isAllSelectedCasesValid;
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
    * @Method:      changeCaseOwner
    * @Created by:  Udit Singhal
    * @Description: This method will change the owner of selected cases based on the input parameter
    * @Param:       List<Id> - queueId (queue from where users will be fetched)
    * @Param:       Id - Id of the user who will be the the owner of selected cases
    * @Return:      String
    */
    @AuraEnabled
    public static String changeCaseOwner(List<Id> selectedCaseList, Id newOwnerId){
        Savepoint sp = null;
        try{
            sp = Database.setSavepoint();
            List<Case> caseToUpdateList = new List<Case>();

            for (Id caseId : selectedCaseList){
                Case caseRecord = new Case();
                caseRecord.Id = caseId;
                caseRecord.OwnerId = newOwnerId;

                caseToUpdateList.add(caseRecord); 
            }
            
            SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, caseToUpdateList); 
            Database.update (securityDecision.getRecords(), true); 

            return 'Success';
        } catch (Exception e){
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
    }
}