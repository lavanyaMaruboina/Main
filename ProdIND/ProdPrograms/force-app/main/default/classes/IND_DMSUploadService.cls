/*------------------------------------------------------------
Author:        Yugandhar
Company:       Persistent
Description:   This class is service class to IND DMS Upload API
Test Class:    
History
Date            Author              Comments
-------------------------------------------------------------
12-19-2021      Yugandhar             Created
------------------------------------------------------------*/
public class IND_DMSUploadService {
    
    @testVisible
    public static Boolean induceException;
    
    /* @Method:      getDMSUploadRequest
    * @Created by:  Yugandhar
    * @Description: This method will returns valid request for DMS Upload API.
    * @Param:       Object - Applicant
    * @Return:      Object - IND_DMSUploadRequest type reponse */
   
    public static IND_DMSUploadRequest getDMSUploadRequest(String loanAppId,String documentType, String dealId){
        try{
            if(induceException == true) {
                throw new IND_Exception('Test Exception');
            }
            System.debug('loanAppId...'+loanAppId+'documentType'+documentType);
            Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanAppId WITH SECURITY_ENFORCED];
            list<Documents__c> docList = new list<Documents__c>();
            if(oppRec.Product_Type__c == System.Label.Tractor){
                List<Vehicle_Detail__c> VehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
                docList = [SELECT Id,Opportunity_Relation__r.name,Document_Type__c,Document_Side__c 
                            FROM Documents__c 
                            WHERE Opportunity_Relation__c = :loanAppId AND Document_Type__c =:documentType AND is_Active__c = true AND Vehicle_Detail__c =: VehicleLst[0].Id
                            WITH SECURITY_ENFORCED];
            }else{
                docList = [SELECT Id,Opportunity_Relation__r.name,Document_Type__c,Document_Side__c 
                            FROM Documents__c 
                            WHERE Opportunity_Relation__c = :loanAppId AND Document_Type__c =:documentType AND is_Active__c = true 
                            WITH SECURITY_ENFORCED];
            }
            list<ContentDocumentLink> contDocList = new list<ContentDocumentLink>();
            ContentVersion conver = new ContentVersion();
            if(!docList.isEmpty()) {
                contDocList = [Select ContentDocumentId from ContentDocumentLink where LinkedEntityId = :docList[0].Id WITH SECURITY_ENFORCED];
            
                if(!contDocList.isEmpty()) {
                    conver = [Select versionData,Title,FileExtension from ContentVersion where contentDocumentId = :contDocList[0].ContentDocumentId WITH SECURITY_ENFORCED];
                }
                string filename = conver.Title + '.'+conver.FileExtension;
                String base64doc = EncodingUtil.base64Encode(conver.versionData);
                IND_DMSUploadRequest dmsRequest = new IND_DMSUploadRequest(docList[0].Opportunity_Relation__r.name,docList[0].Document_Type__c,docList[0].Document_Side__c,base64doc,filename);
                return dmsRequest;
            }
            else {
                throw new  IND_Exception(System.label.NoRCDocument);
            }
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_DMSUploadService', 'getDMSUploadRequest', System.Label.Apex, ex,loanAppId);
            throw new  IND_Exception(ex.getMessage()); 
       }
    }
}