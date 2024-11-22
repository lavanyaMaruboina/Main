/**
* @Name         CAMController
* @Author       Divya J
* @Company      Persistent Systems
* @Description  This class contains all methods related to CAM Screen
* Inputs:       None
* Test Class:   
* History:      None
*/
public with sharing class CAMController {
    
    /*
* @Method:      getRelatedCAM
* @Created by:  Rajat Jaiswal
* @Description: This method will return the wrapper containing camId, valid profile check, loan app transaction history
* @Param:       Id - loanAppId
* @Return:      DataWrapper
*/
    @AuraEnabled
    public static DataWrapper getRelatedCAM(Id loanAppId, String dealId){
        try{
            if(loanAppId != null){
                DataWrapper dataWrapperObj = new DataWrapper();
                List<CAM__c> camList = [SELECT Id, Loan_Application__c, Loan_Application__r.Product_Type__c, CAM_Conditional_approval_remarks__c, CAM_conditional_approval_requirement__c FROM CAM__c WHERE Loan_Application__c =:loanAppId WITH SECURITY_ENFORCED LIMIT 1];
                String productType = '';
                if(camList!=null && camList.size()>0){
                    dataWrapperObj.camObj = camList[0];
                    productType = camList[0].Loan_Application__r.Product_Type__c;
                }
                List<Loan_Application_Transaction_History__c> lATList = new List<Loan_Application_Transaction_History__c>([Select id, Name, Submitted_Flag__c
                                                                                                                           from Loan_Application_Transaction_History__c
                                                                                                                           where Loan_Application_ID__c = :loanAppId And Screen__c = 'CAM and Conditional Approval' And Module__c = 'Pre Disbursement Check' AND Deal_Number__c =: dealId
                                                                                                                           WITH SECURITY_ENFORCED]);
                if(lATList!=null && lATList.size()>0){
                    dataWrapperObj.transactionHistoryList = lATList;
                }
                List<IBL_Configuration__mdt> iblConfigurationList = [SELECT Id,PreDisbursementCheckProfiles__c FROM IBL_Configuration__mdt WHERE DeveloperName = 'default' WITH SECURITY_ENFORCED LIMIT 1000];
                if(iblConfigurationList.size()>0){
                    IBL_Configuration__mdt iblConfigObj = iblConfigurationList[0];
                    string accessibleProfiles = iblConfigObj.PreDisbursementCheckProfiles__c;
                    string currentUserProfileId = UserInfo.getProfileId();
                    if(accessibleProfiles!=null && currentUserProfileId!=null){
                        List<Profile> profileList = [SELECT Id,Name FROM Profile WHERE Id=:currentUserProfileId LIMIT 1];
                        List<Opportunity> opportunityList = [SELECT Id, OwnerId FROM Opportunity WHERE Id=:loanAppId LIMIT 1];
                        for (String profileName : accessibleProfiles.split(',')) {
                            if((profileName.equalsIgnoreCase(profileList[0].Name) || ((profileList[0].Name == 'IBL TF Payment Executive' || profileList[0].Name == 'IBL TF Internal Payment Executive') && productType == System.Label.Tractor)) && opportunityList[0].OwnerId == UserInfo.getUserId()){
                                dataWrapperObj.checkProfile = true;
                            }
                        }
                    }
                }
                return dataWrapperObj;
            }
            return null;
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('CAMController', 'getRelatedCAM', e.getTypeName(), e, loanAppId);
            return null;
        }
    }
    /*
* @class:      DataWrapper
* @Created by:  Rajat Jaiswal
* @Description: This wrapper used to store the camid, transaction history, valid profile check
*/
    public class DataWrapper{
        @auraenabled public CAM__c camObj;
        @auraenabled public List<Loan_Application_Transaction_History__c> transactionHistoryList;
        @auraenabled public Boolean checkProfile;
    }
    /*
* @Method:      updateCAM
* @Created by:  Rajat Jaiswal
* @Description: This method will update the cam with requirement and remarks and update the loan app transaction history submit true
* @Param:       Id - camId,string - approvalRequirement,string - remarks,string - loanApplicationId
* @Return:      Boolean
*/
    @AuraEnabled
    public static Boolean updateCAM(Id camId,String approvalRequirement, String remarks, string loanApplicationId, String dealId){
        try{
            if(camId!=null){
                CAM__C camObj = new CAM__C(Id=camId);
                camObj.CAM_Conditional_approval_remarks__c = remarks!=null?remarks:null;
                camObj.CAM_conditional_approval_requirement__c = approvalRequirement!=null?approvalRequirement:null; 
                update camObj;   
                List<Loan_Application_Transaction_History__c> lATList = new List<Loan_Application_Transaction_History__c>([Select id, Name,Screen__c, Submitted_Flag__c
                                                                                                                           from Loan_Application_Transaction_History__c
                                                                                                                           where Loan_Application_ID__c = :loanApplicationId And Screen__c = 'CAM and Conditional Approval' And Module__c = 'Pre Disbursement Check' AND Deal_Number__c =: dealId
                                                                                                                           WITH SECURITY_ENFORCED]);
                List<Loan_Application_Transaction_History__c> transactionHistroyList = new List<Loan_Application_Transaction_History__c>();
                if (lATList.size() > 0){
                    for (Loan_Application_Transaction_History__c history : lATList) {
                        if(!history.Submitted_Flag__c){
                            history.Submitted_Flag__c = true;
                            transactionHistroyList.add(history);
                        }
                    }
                }
                if(transactionHistroyList.size()>0){
                    update transactionHistroyList;
                }
                return true; 
            }
            return false;
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('CAMController', 'updateCAM', e.getTypeName(), e, [SELECT Loan_Application__c FROM CAM__c WHERE Id=:camId LIMIT 1].Loan_Application__c);
            return null;
        }      
    }   
}