/*------------------------------------------------------------
Author:        Rohan Saxena
Company:       Salesforce
Description:   This class is helper class for Opportunity
Test Class:    OpportunityTriggerTest
History
Date            Author              Comments
-------------------------------------------------------------
16-12-2022      Rohan Saxena         Created
------------------------------------------------------------*/
public without sharing class OpportunityTriggerHelper {
    /*
     * @Method:      updateSubStageField
     * @Created by:  Rohan Saxena
     * @Description: Show custom stage field in DSA
     * @Param:String, String
     * @Return:Map<Id,String>
     */
    public static void updateSubStageField(Map<Id,Opportunity> mapNewOpp,Map<Id,Opportunity> lstOldOpp){
        try{
            for(Opportunity opp: mapNewOpp.values()){
                if(opp.Sub_Stage__c != lstOldOpp.get(opp.Id).Sub_Stage__c && opp.LeadSource=='DSA'){
                    opp.DSA_Sub_Stage__c=IND_Constant.subStageMap.get(opp.Sub_Stage__c);   
                }
            }
            
        }
        catch(Exception e){
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('OpportunityTriggerHelper', ' updateSubStageField ', System.Label.Apex, e);
            insert errorLogRecord;
        }
    }  
    /*
     * @Method:      updateOppTeamMember
     * @Created by:  Rohan Saxena
     * @Description: Show disbursed lead to DSA //SFD2C-187
     * @Param:String, String
     * @Return:Map<Id,String>
     */
    public static void updateOppTeamMember(Map<Id,Opportunity> mapNewOpp,Map<Id,Opportunity> lstOldOpp){
        try{
            List<OpportunityTeamMember> lstOppTeamMemb= new List<OpportunityTeamMember>();
            for(Opportunity opp: mapNewOpp.values()){
                if(opp.OwnerId  != lstOldOpp.get(opp.Id).OwnerId  && opp.LeadSource=='DSA'){
                    OpportunityTeamMember objOppTeamMemb = new OpportunityTeamMember();
                    objOppTeamMemb.UserId=opp.CreatedById;
                    objOppTeamMemb.OpportunityId=opp.Id;
                    objOppTeamMemb.TeamMemberRole='DSA';
                    objOppTeamMemb.OpportunityAccessLevel='Edit';
                    lstOppTeamMemb.add(objOppTeamMemb);
                }
            }
            insert lstOppTeamMemb;
        }
        catch(Exception e){
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('OpportunityTriggerHelper', ' updateOppTeamMember ', System.Label.Apex, e);
            insert errorLogRecord;
        }
    }
    /*
     * @Method:      updateSubStageFieldD2C
     * @Created by:  Rohan Saxena
     * @Description: Remove Vehicle Dedupe value CFDI-514
     * @Param:String, String
     * @Return:Map<Id,String>
     */
    public static void updateSubStageFieldD2C(Map<Id,Opportunity> mapNewOpp,Map<Id,Opportunity> lstOldOpp){
        try{
            for(Opportunity opp: mapNewOpp.values()){
                if(opp.Sub_Stage__c == 'Vehicle Dedupe' && opp.LeadSource=='D2C' && opp.LeadSource=='New'){
                    opp.Sub_Stage__c=lstOldOpp.get(opp.Id).Sub_Stage__c;   
                }
            }
            
        }
        catch(Exception e){
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('OpportunityTriggerHelper', ' updateSubStageFieldD2C ', System.Label.Apex, e);
            insert errorLogRecord;
        }
    }

    public static void publishOlaLeadInsertedEvent(list<Opportunity> newOpp){
        List<Low_Payload_Request__e> lprList1 = new List<Low_Payload_Request__e>();
        List<Integration_Log__c> intLogList = new List<Integration_Log__c>();
        try{
            for(Opportunity opp : newOpp){
                if(opp.LeadSource=='OLA' || opp.LeadSource=='Hero'){
                    String loanAppNo = opp.Lead_number__c;
                    String originalRequest1 = '{"Lead_Id": "'+loanAppNo+'", "CallType": "offer_engine"}';
                    String originalRequest2 = '{"Lead_Id": "'+loanAppNo+'", "CallType": "gating_Screening"}';
                    String originalRequest3 = '{"Lead_Id": "'+loanAppNo+'", "CallType": "LTV"}';
                    String originalRequest4 = '{"Lead_Id": "'+loanAppNo+'", "CallType": "Pricing"}';
                    String originalRequest5 = '{"Lead_Id": "'+loanAppNo+'", "CallType": "ScoreCard"}';

                    String encryptedRequest1 = '{"JData": "'+IntegrationUtilities.getEncryptedRequest(originalRequest1,System.Label.privateKey,System.Label.ivkey)+'" }';
                    String encryptedRequest2 = '{"JData": "'+IntegrationUtilities.getEncryptedRequest(originalRequest2,System.Label.privateKey,System.Label.ivkey)+'" }';
                    String encryptedRequest3 = '{"JData": "'+IntegrationUtilities.getEncryptedRequest(originalRequest3,System.Label.privateKey,System.Label.ivkey)+'" }';
                    String encryptedRequest4 = '{"JData": "'+IntegrationUtilities.getEncryptedRequest(originalRequest4,System.Label.privateKey,System.Label.ivkey)+'" }';
                    String encryptedRequest5 = '{"JData": "'+IntegrationUtilities.getEncryptedRequest(originalRequest5,System.Label.privateKey,System.Label.ivkey)+'" }';

                    Low_Payload_Request__e lPay1 = new Low_Payload_Request__e(Reference_Id__c=opp.Id+'offer_engine', SVC_Name__c='FICO Response', Request__c =encryptedRequest1);
                    Low_Payload_Request__e lPay2 = new Low_Payload_Request__e(Reference_Id__c=opp.Id+'gating_Screening', SVC_Name__c='FICO Response', Request__c =encryptedRequest2);
                    Low_Payload_Request__e lPay3 = new Low_Payload_Request__e(Reference_Id__c=opp.Id+'ltv_engine', SVC_Name__c='FICO Response', Request__c =encryptedRequest3);
                    Low_Payload_Request__e lPay4 = new Low_Payload_Request__e(Reference_Id__c=opp.Id+'pricing_engine', SVC_Name__c='FICO Response', Request__c =encryptedRequest4);
                    Low_Payload_Request__e lPay5 = new Low_Payload_Request__e(Reference_Id__c=opp.Id+'ScoreCard', SVC_Name__c='FICO Response', Request__c =encryptedRequest5);

                    Integration_Log__c intObj1=new Integration_Log__c(Original_request__c=originalRequest1, Encrypted_request__c=encryptedRequest1, ReferenceId__c=opp.Id+'offer_engine', Service_Name__c='offer_engine', isSync__c=false, targetRecordId__c=opp.id, Loan_Application__c=opp.id);
                    Integration_Log__c intObj2=new Integration_Log__c(Original_request__c=originalRequest2, Encrypted_request__c=encryptedRequest2, ReferenceId__c=opp.Id+'gating_Screening', Service_Name__c='gating_Screening', isSync__c=false, targetRecordId__c=opp.id, Loan_Application__c=opp.id);
                    Integration_Log__c intObj3=new Integration_Log__c(Original_request__c=originalRequest3, Encrypted_request__c=encryptedRequest3, ReferenceId__c=opp.Id+'ltv_engine', Service_Name__c='ltv_engine', isSync__c=false, targetRecordId__c=opp.id, Loan_Application__c=opp.id);
                    Integration_Log__c intObj4=new Integration_Log__c(Original_request__c=originalRequest4, Encrypted_request__c=encryptedRequest4, ReferenceId__c=opp.Id+'pricing_engine', Service_Name__c='pricing_engine', isSync__c=false, targetRecordId__c=opp.id, Loan_Application__c=opp.id);
                    Integration_Log__c intObj5=new Integration_Log__c(Original_request__c=originalRequest5, Encrypted_request__c=encryptedRequest5, ReferenceId__c=opp.Id+'ScoreCard', Service_Name__c='ScoreCard', isSync__c=false, targetRecordId__c=opp.id, Loan_Application__c=opp.id);

                    lprList1.add(lPay1);
                    lprList1.add(lPay2);
                    lprList1.add(lPay3);
                    lprList1.add(lPay4);
                    lprList1.add(lPay5);

                    intLogList.add(intObj1);
                    intLogList.add(intObj2);
                    intLogList.add(intObj3);
                    intLogList.add(intObj4);
                    intLogList.add(intObj5);
                }

                if(lprList1.size()>0){
                    EventBus.publish(lprList1);
                }
                if(intLogList.size()>0){
                    insert intLogList;
                }
            }
        } catch(Exception e){
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('OpportunityTriggerHelper', ' updateSubStageFieldD2C ', System.Label.Apex, e);
            insert errorLogRecord;
        }
    }
}