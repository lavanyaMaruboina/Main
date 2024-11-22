/*Class description: Created this class for without sharing components in DSA */

public with sharing class IND_DSAControllerWithoutSharing {

    /* Adding for CISP-12436 - Start */
    @AuraEnabled
    public static List<MIS_RC_Limit_Dt__c> getRCLimitTableData() {
            try{
                String currentUserBenCode;
                List<MIS_RC_Limit_Dt__c> MisRCLimit = new List<MIS_RC_Limit_Dt__c>();
                List<User> currUser = [SELECT UserName FROM User WHERE Id =:userInfo.getUserId() LIMIT 1];
                if(currUser != null && currUser.size() > 0){
                    currentUserBenCode = currUser[0].UserName.subStringBefore('@');
                    system.debug('currentUserBenCode> '+currentUserBenCode);
                }
                MisRCLimit = [SELECT Id, Deal_No__c, Bl_Name__c, State_Name__c, Customer_Name__c, Deal_Status__c, Fin_Amt__c, Disbursed_Date__c, IBL_Lien_Marked_On__c
                    FROM MIS_RC_Limit_Dt__c
                    WHERE Ben_Code__c = :currentUserBenCode];
                    system.debug('MisRCLimit> '+MisRCLimit);
                if(MisRCLimit != null && MisRCLimit.size() > 0){
                    system.debug('Have Data> '+MisRCLimit);
                    return MisRCLimit;
                }else{
                    system.debug('No Data> '+MisRCLimit);
                    return null;
                }
            }catch (Exception e){
                throw new AuraHandledException(e.getMessage());
            }
    }
    /* Adding for CISP-12436 - End */
    
}