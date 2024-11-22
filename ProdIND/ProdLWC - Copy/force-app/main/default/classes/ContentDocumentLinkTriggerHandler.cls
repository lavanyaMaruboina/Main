/*------------------------------------------------------------
Author:        Sushil B
Company:       Manureva Solutions
Description:   Handler class for on ContentDocumentLinkTrigger.
Inputs:        None 
Test Classes:  ContentDocumentLinkTriggerHandlerTest
History
Date            Author              Comments
-------------------------------------------------------------
28-06-2022      Sushil B            Created
------------------------------------------------------------*/
public class ContentDocumentLinkTriggerHandler {
    /*
    * @Method:      handleBeforeInsert
    * @Created by:  Sushil B
    * @Description: handles all the before insert operations for ContentDocumentLink object
    * @Param:       List<ContentDocumentLink> contDocLinkList
    * @Return:      Void   
	*/
    public static void handleBeforeInsert(List<ContentDocumentLink> contDocLinkList){
        //set visibility to AllUsers
        for(ContentDocumentLink contDocLink : contDocLinkList){
            contDocLink.Visibility = 'AllUsers';
        }
    }

    /*
    * @Method:      handleAfterInsert
    * @Created by:  Sanketkumar Patil
    * @Description: Handles all the after insert operations for ContentDocumentLink object
    * @Param:       Content Document Link List
    * @Return:      Void   
	*/
    public static void handleAfterInsert(List<ContentDocumentLink> contDocLinkList){
        ContentDocumentLinkTriggerHandler.updateDocumentCount(contDocLinkList);
    }

    /*
    * @Method:      updateDocumentCount
    * @Created by:  Sanketkumar Patil
    * @Description: Method to update File count on KYC and Other Type Document Records
    * @Param:       Content Document Link List
    * @Return:      Void   
	*/
    public static void updateDocumentCount(List<ContentDocumentLink> contDocLinkList){
        List<Documents__c> docUpdateList = new List<Documents__c>();
        Set<Id> documentIdSet = new Set<Id>();
        Set<Id> entityIdSet = new Set<Id>();

        for(ContentDocumentLink contDocLink : contDocLinkList){
            entityIdSet.add(contDocLink.LinkedEntityId);
        }

        //Without Security Context as Polymorphic field LinkedEntity reffered in below SOQL
        List<ContentDocumentLink> contDocLinkFieldList = [SELECT Id, LinkedEntityId, LinkedEntity.RecordType.DeveloperName FROM ContentDocumentLink WHERE LinkedEntityId in :entityIdSet];

        for(ContentDocumentLink contDocLink : contDocLinkFieldList){
            if(contDocLink.LinkedEntity.RecordType.DeveloperName == 'Other_Documents' || contDocLink.LinkedEntity.RecordType.DeveloperName == 'KYC'){
                documentIdSet.add(contDocLink.LinkedEntityId);
            }
        }

        System.debug('Log - contDocLinkFieldList:: '+ contDocLinkFieldList);
        System.debug('Log - documentIdSet:: '+ documentIdSet);

        List<Documents__c> docList = [SELECT Id, Content_Document_Count__c FROM Documents__c WHERE Id IN :documentIdSet WITH SECURITY_ENFORCED];        
        System.debug('Log - DocList:: '+ docList);

        if(!docList.isEmpty()){
            for(Documents__c doc : docList){
                if(doc.get('Content_Document_Count__c') != null){
                    doc.Content_Document_Count__c = doc.Content_Document_Count__c + 1;
                    docUpdateList.add(doc);
                }
            }
        }

        System.debug('Log - docUpdateList:: '+ docUpdateList);

        if(!docUpdateList.isEmpty() && Schema.sObjectType.Documents__c.isUpdateable()){ 
            update docUpdateList;
        }
    }
    
    
      /*
    * @Method:      deactivateDuplicateDocument
    * @Created by:  PSL
    * @Description: Method to Deactivate the old document if we have similar document
    * @Param:       Content Document Link List
    * @Return:      Void   
	*/
    public static void deactivateDuplicateDocument(List<ContentDocumentLink> contDocLinkList){
        List<Documents__c> docUpdateList = new List<Documents__c>();
        Set<Id> documentIdSet = new Set<Id>();
        Set<Id> entityIdSet = new Set<Id>();
        List<Documents__c> duplicateDocs = new List< Documents__c>();  
        map<Id, Documents__c> newdocumentRec = new Map<Id, Documents__c>();
        for(ContentDocumentLink contDocLink : contDocLinkList){
            entityIdSet.add(contDocLink.LinkedEntityId);
        }
        //List<Documents__c> docList = new List<Documents__c>();
        Map<String, List<Documents__c>> docmap = new Map<String, List<Documents__c>>();
        Set<Id>applicantIds = new Set<Id>();
        Set<String> docTypes = new Set<String>{'36','5','7','4','3','2','6','8','11','9','12','13','14','15','Customer Image','PAN','Form 60', 'Bank Statement', 'Electronic Bill', 'Telephone bill', 'Post paid mobile bill', 'Gas bill', 'Water Bill', 'Property or municipal tax receipt', 'Govt pension payment order', 'Govt letter of accommodation allotment', 'Customer ITR', 'Customer Bank Statement', 'ITR-Forms', 'ITR-V', 'Form26As' ,'Vehicle Image','Vehicle Insurance Policy', 'Vehicle RC Copy','Valuation Report','RC Document','RC Copy','Rent Agreement/Reciept','RC','Pension Document','Patta Document','Office Front View','Land Photo'};
        //Query the documwent records based on contentDocumentLink.
        Boolean isTractor = false;
        Set<Id> vehicleIdSet = new Set<Id>();
        for(Documents__c doc:  [SELECT Id, Applicant__c, Document_Type__c,Opportunity_Relation__c,Addresss_Type__c,RecordTypeId,Opportunity_Relation__r.Product_Type__c,Vehicle_Detail__c FROM Documents__c where Id IN: entityIdSet and is_Active__c =true and Document_Type__c IN: docTypes])
        {
            if(doc.Opportunity_Relation__r.Product_Type__c == System.Label.Tractor){
                isTractor = true;
                if(doc.Vehicle_Detail__c != null){
                    vehicleIdSet.add(doc.Vehicle_Detail__c);
                }
            }
            newdocumentRec.put(doc.Applicant__c, doc);
            applicantIds.add(doc.Applicant__c);
        }
        
        if(isTractor == true && vehicleIdSet.size() > 0){
            for(Documents__c doc:  [SELECT Id, Applicant__c, Document_Type__c,Opportunity_Relation__c,Addresss_Type__c,RecordTypeId FROM Documents__c where Applicant__c IN: applicantIds  and is_Active__c =true and Document_Type__c IN: docTypes AND Vehicle_Detail__c IN : vehicleIdSet])
            {     
                if(doc.Id !=  newdocumentRec.get(doc.Applicant__c).Id ){ 
                    if(docmap.containsKey(doc.Applicant__c) ){
                        List<Documents__c>  docList= docmap.get(doc.Applicant__c);
                        docList.add(doc);    
                        docmap.put(doc.Applicant__c, docList );
                    }else{
                        docmap.put(doc.Applicant__c, new list<Documents__c>{doc} );
                    }
                }
            }
        }else if(isTractor == false){
            //Query the existing documents associated to Applicant and adding applicant and list of documents
            for(Documents__c doc:  [SELECT Id, Applicant__c, Document_Type__c,Opportunity_Relation__c,Addresss_Type__c,RecordTypeId FROM Documents__c where Applicant__c IN: applicantIds  and is_Active__c =true and Document_Type__c IN: docTypes])
            {     
                if(doc.Id !=  newdocumentRec.get(doc.Applicant__c).Id ){ 
                    if(docmap.containsKey(doc.Applicant__c) ){
                        List<Documents__c>  docList= docmap.get(doc.Applicant__c);
                        docList.add(doc);    
                        docmap.put(doc.Applicant__c, docList );
                    }else{
                        docmap.put(doc.Applicant__c, new list<Documents__c>{doc} );
                    }
                }
            }
        }
        
        //Iterationg the applicants  and iterating the applicant documents and checking if we have any similar document than making that as InActive
        for(Documents__c docAppRec :  newdocumentRec.values()) 
        {
            if( docmap.containskey(docAppRec.Applicant__c) ){
                for(Documents__c doc :  docmap.get(docAppRec.Applicant__c)){
                    if(doc.Document_Type__c == newdocumentRec.get(doc.Applicant__c).Document_Type__c && 
                       doc.Addresss_Type__c ==  newdocumentRec.get(doc.Applicant__c).Addresss_Type__c ){
                           doc.is_Active__c =false;
                           duplicateDocs.add(doc); 
                       }
                }            
            }            
        }
        
        
        system.debug('duplicateDocs ::'+duplicateDocs);
        if(!duplicateDocs.isEmpty() ){
            database.update(duplicateDocs);
        }  
    }
}