/**
* @author: Raj Gupta.
* @company: Persistent Systems
* @description: this trigger class handler is use to update two fields on Document object according to condition.
* Test Class: DocumentTriggerTest
* History:
* 28/10/2012  Added by Raj for Initial (IND-309). 
*/
public with sharing class DocumentTriggerHandler extends TriggerHandler{ 
    //Global Variable for to be used for Casting the Sobject details
    @TestVisible
    List<Documents__c> newDocumentList;
    @TestVisible
    List<Documents__c> oldDocumentList;
    @TestVisible
    Map<Id,Documents__c> newDocumentMap;
    @TestVisible
    Map<Id,Documents__c> oldDocumentMap;
    public DocumentTriggerHandler(){
        newDocumentList = (List<Documents__c>)Trigger.new;
        oldDocumentList = (List<Documents__c>)Trigger.old;
        newDocumentMap  = (MAP<Id,Documents__c>)Trigger.newMap;
        oldDocumentMap  = (MAP<Id,Documents__c>)Trigger.oldMap;
    }
    
    public override void beforeInsert(){
        /*Added by Nikhil Somvanshi JIRA Ref: CISP-7051 : START*/
        try{
            if(boolean.valueOf(system.label.RunDSAPanEncryption)){
                STRING DSA_SOURCE = 'DSA';
                Map<Id,documents__c> oppIdVsDocument = new Map<Id,documents__c>();
                for(documents__c doc : newDocumentList){
                    if(doc.Opportunity_Relation__c != null && doc.PAN_No__c != null){
                        oppIdVsDocument.put(doc.Opportunity_Relation__c, doc);
                    }
                }

                if(!oppIdVsDocument.isEmpty()){
                    for(Opportunity opp : [SELECT Name,LeadSource,Parent_Loan_Application__c FROM Opportunity WHERE Id in:oppIdVsDocument.keySet()]){
                        if(opp.LeadSource == DSA_SOURCE && oppIdVsDocument.containsKey(opp.Id) && opp.Parent_Loan_Application__c == null){
                            oppIdVsDocument.get(opp.Id).PAN_No__c = IntegrationUtilities.getEncryptedRequest(oppIdVsDocument.get(opp.Id).PAN_No__c,System.Label.privateKey,System.Label.ivkey);
                        }
                    }
                }
            }
           // SFTRAC-1036  
           Map<Id,documents__c> oppDoc = new Map<Id,documents__c>();
           Map<Id,documents__c> niTractorDocs = new Map<Id,documents__c>();
           for(Documents__c doc: newDocumentList){
               if(doc.Opportunity_Relation__c != null){
                   oppDoc.put(doc.Opportunity_Relation__c, doc);
               }
           }
           if(!oppDoc.isEmpty()){
               Map<Id,Integer> mapRelation = new Map<Id,Integer>();
               Map<Id,String> mapBONames = new Map<Id,String>();
               Map<Id,String> mapASNames = new Map<Id,String>();
               List<Opportunity> oppList = [Select Id,Customer_Type__c,Product_Type__c, (Select Id,Beneficial_Owner_Category__c,Name from Applicants__r WHERE Applicant_Type__c = 'Beneficiary' AND In_Active_Applicant__c = false) FROM Opportunity WHERE ID IN:oppDoc.keySet() AND Product_Type__c = 'Tractor' AND Customer_Type__c = 'Non-Individual'];
               for(Opportunity opp :oppList){
                        niTractorDocs.put(opp.Id,oppDoc.get(opp.Id));
                        mapRelation.put(opp.Id,opp.Applicants__r.size());
                        String BONames = '';
                        String ASNames = '';
                        for(Applicant__c appList :opp.Applicants__r){
                           if(appList.Beneficial_Owner_Category__c == 'Beneficial Owner'){
                             if(BONames == ''){
                             BONames = appList.Name;
                             } else {
                             BONames += ',' + appList.Name; }
                             mapBONames.put(opp.Id,BONames);
                           }
                           else if(appList.Beneficial_Owner_Category__c == 'Authorised Signatory'){
                               if(ASNames == ''){
                               ASNames = appList.Name;
                               } else {
                               ASNames += ',' + appList.Name; 
                            }
                               mapASNames.put(opp.Id,ASNames);
                           }
                       }
                   }
           for(Documents__c doc: niTractorDocs.values()){
               //doc.Is_Active__c = true; 
               doc.Salutation__c = 'M/s.';
               if(mapRelation.containsKey(doc.Opportunity_Relation__c)){
               doc.No_of_Relations__c = mapRelation.get(doc.Opportunity_Relation__c);}
               if(mapBONames.containsKey(doc.Opportunity_Relation__c)){
               doc.Name_of_Beneficial_Owners__c = mapBONames.get(doc.Opportunity_Relation__c);}
               if(mapASNames.containsKey(doc.Opportunity_Relation__c)){
               doc.Names_Of_Person_Authorized__c = mapASNames.get(doc.Opportunity_Relation__c);}
           }
        }
        // END-1036  
            
        } Catch(Exception e){
            System.debug('***Exception '+e.getMessage()+' occurred at line number '+e.getLineNumber());
            ErrorLoggerUtil.logErrorEvent(System.Label.documentTriggerHandler, ' beforeInsert ', System.Label.Apex, e);
            throw new TriggerHandler.TriggerHandlerException(System.Label.ExceptionMessage);
        }
        /*Added by Nikhil Somvanshi JIRA Ref: CISP-7051 : END*/
    }

    public override void afterInsert() {
       /*  try{
            set<id> loanIds = new set<id>();
            System.debug('newDocumentList ==>'+newDocumentList);
            for(Documents__c documentElement : newDocumentList){
                if(documentElement.Opportunity_Relation__c != null){
                    loanIds.add(documentElement.Opportunity_Relation__c);
                }
            }
            if(loanIds.size()>0){
                list<opportunity> loanAppList = new list<opportunity>();
                for(opportunity loanApp: [select id,Journey_Status__c,(select id,Document_Type__c from Documents__r where Document_Type__c='RC Copy' OR Document_Type__c='Vehicle Insurance Policy') from opportunity where ID IN: loanIds WITH SECURITY_ENFORCED]){
                    if(loanApp.Journey_Status__c != 'Non STP' && loanApp.Documents__r.size()>0){
                        loanApp.Journey_Status__c = 'Non STP';
                        loanAppList.add(loanApp);
                    }
                }
                if(loanAppList.size()>0){
                    UPDATE loanAppList;
                }
            }
        }
        Catch(Exception e){
            ErrorLoggerUtil.logErrorEvent(System.Label.documentTriggerHandler, ' afterUpdate ', System.Label.Apex, e);
            throw new TriggerHandler.TriggerHandlerException(System.Label.ExceptionMessage);
        }   */   
    }
    
    public override void afterUpdate() {
       try{ 
           //To create the Aadhar PDF in case of Aadhar upload from OTP and Biometric
           System.debug('Doc Trigger - List:: '+ newDocumentList);
           for(Documents__c docObj : newDocumentList){
                Documents__c oldValDoc = oldDocumentMap.get(docObj.Id);

                if( oldValDoc.Aadhar_Source__c != docObj.Aadhar_Source__c && (docObj.Aadhar_Source__c =='OTP' || docObj.Aadhar_Source__c =='Biometric')){
                    AadharReportController.createAadharReportPdf(docObj.id);
                }
           }
           /*set<Id> applicantIds = new set<Id>();
            LIST<Case> cmuCaseToUpdate = new LIST<Case>();
            
            //Map to handle all CMU Cases
            MAP<Id,Documents__c> cmuCaseDocumentMap = new MAP<Id,Documents__c>();
            MAP<Id,List<Documents__c>> cmuCaseDocumentCountMap = new MAP<Id,List<Documents__c>>();
            
            for(Documents__c documentElement : newDocumentList){   
                if(documentElement.Proof_of_Identity_POI__c != oldDocumentMap.get(documentElement.ID).Proof_of_Identity_POI__c && documentElement.Proof_of_Identity_POI__c==true)
                {
                    applicantIds.add(documentElement.Applicant__c);
                }
                
                if(!String.isBlank(documentElement.Case__c) && oldDocumentMap.get(documentElement.ID).CMU_Accept_Reject__c != documentElement.CMU_Accept_Reject__c ){
                    cmuCaseDocumentMap.put(documentElement.Case__c,documentElement);                       
                }
            }
            
            for(Documents__c document : [SELECT ID,Case__C,CMU_Accept_Reject__c,Document_Type__c FROM Documents__c WHERE Case__c IN:cmuCaseDocumentMap.KeySet()] ){
                // Integer count = cmuCaseDocumentCountMap.get(document.Case__C) != null? cmuCaseDocumentCountMap.get(document.Case__C)+1 : 1;
               if(!cmuCaseDocumentCountMap.containsKey(document.Case__c)){
                cmuCaseDocumentCountMap.put(document.Case__c,new List<Documents__c>());
                cmuCaseDocumentCountMap.get(document.Case__c).add(document);
                }else{
                    cmuCaseDocumentCountMap.get(document.Case__c).add(document);
                } 
              
            }
            if(cmuCaseDocumentMap.keySet().size() > 0){
               
                for(String cmuCaseId : cmuCaseDocumentMap.keySet()){         
                    Case cmuCase = new Case(Id=cmuCaseId);                           
                    for(Documents__c docElement : cmuCaseDocumentCountMap.get(cmuCaseId)){
                        system.debug('docElement.CMU_Accept_Reject__c::'+docElement.CMU_Accept_Reject__c);
                        if(cmuCaseDocumentMap.get(cmuCaseId).CMU_Accept_Reject__c == 'Accept' && docElement.CMU_Accept_Reject__c != 'Accept' && docElement.Document_Type__c <> 'Customer Image'){
                            cmuCase.Status = 'Pending With CMU';
                        }
                        else if(cmuCaseDocumentMap.get(cmuCaseId).CMU_Accept_Reject__c == 'Accept'){
                            cmuCase.Status = 'Closed';
                        }else{
                            cmuCase.Status = 'Pending With CMU';
                        }                    
                    }  
                    cmuCaseToUpdate.add(cmuCase);                                          
                }
            }
            if(!cmuCaseToUpdate.isEmpty() && Schema.sObjectType.Case.isUpdateable() ){
                Update cmuCaseToUpdate;
            }   
           /*  List<Documents__c> docs = [select Name_Mismatch_Pass__c,Name_Mismatch_Percentage__c from Documents__c where Applicant__c IN :applicantIds And Proof_of_Identity_POI__c = false WITH SECURITY_ENFORCED];
            for(Documents__c doc : docs)
            {
                doc.Name_Mismatch_Pass__c = true;
                doc.Name_Mismat
                ch_Percentage__c = 80;       		
            } 
            
            if (Schema.sObjectType.Documents__c.isUpdateable())
            {
                update docs;
            }*/
        } Catch(Exception e){
            System.debug('***Exception '+e.getMessage()+' occurred at line number '+e.getLineNumber());
            ErrorLoggerUtil.logErrorEvent(System.Label.documentTriggerHandler, ' afterUpdate ', System.Label.Apex, e);
            throw new TriggerHandler.TriggerHandlerException(System.Label.ExceptionMessage);
        }    
    }
    //CISP-4635
    public override void beforeUpdate() {
        try{    
            for(Documents__c objDoc : newDocumentList){
                //Added by Rajasekar as part of CISP-22987 - Starts
				if(objDoc.Document_Type__c == Label.PanCards && (objDoc.PAN_No__c != oldDocumentMap.get(objDoc.Id).PAN_No__c) && objDoc.PAN_No__c != null && objDoc.PAN_No__c.length() == 10){
					objDoc.PAN_No__c = IntegrationUtilities.getEncryptedRequest(objDoc.PAN_No__c,System.Label.privateKey,System.Label.ivkey);
				}
				//Added by Rajasekar as part of CISP-22987 - Ends
                /*Added by Nikhil Somvanshi JIRA Ref: CISP-7051 : START*/
                system.debug('oldDocumentMap data ' + oldDocumentMap.get(objDoc.Id)?.PAN_No__c);
                if(oldDocumentMap.get(objDoc.Id)?.PAN_No__c != null){
                    if((objDoc.PAN_No__c != oldDocumentMap.get(objDoc.Id)?.PAN_No__c) && objDoc.PAN_No__c.length() == 10 &&
                    oldDocumentMap.get(objDoc.Id)?.PAN_No__c.length() > 10){
                        objDoc.PAN_No__c = oldDocumentMap.get(objDoc.Id).PAN_No__c;
                    }
                }
                /*Added by Nikhil Somvanshi JIRA Ref: CISP-7051 : END*/
                system.debug('objDoc.Proof_of_Identity_POI__c> '+objDoc.Proof_of_Identity_POI__c);
                system.debug('objDoc.Rejection_Fields__c> '+objDoc.Rejection_Fields__c);
                system.debug('oldDocumentMap.get(objDoc.Id).Rejection_Fields__c> '+oldDocumentMap.get(objDoc.Id).Rejection_Fields__c);
                if(objDoc.CMU_Accept_Reject__c == 'Reject' && objDoc.CMU_Rejection_Reason__c != oldDocumentMap.get(objDoc.Id).CMU_Rejection_Reason__c){
                    objDoc.Rejected_DateTime__c = DateTime.now();
                    objDoc.Reject_Count__c = objDoc.Reject_Count__c==null ? 1: objDoc.Reject_Count__c + 1;
                }
                if(objDoc.Proof_of_Identity_POI__c == false && objDoc.Rejection_Fields__c != oldDocumentMap.get(objDoc.Id).Rejection_Fields__c && !String.isBlank(objDoc.Rejection_Fields__c)){
                    List<String> rejectedFields = objDoc.Rejection_Fields__c.split(';');
                    for(String rejectField : rejectedFields){
                            if(rejectField == 'Gender'){
                                objDoc.Rejection_Fields__c = objDoc.Rejection_Fields__c + ';Salutation';
                                break;
                            }
                    }
                }
            }

        } Catch(Exception e){
            System.debug('***Exception '+e.getMessage()+' occurred at line number '+e.getLineNumber());
            ErrorLoggerUtil.logErrorEvent(System.Label.documentTriggerHandler, ' afterUpdate ', System.Label.Apex, e);
            throw new TriggerHandler.TriggerHandlerException(System.Label.ExceptionMessage);
        }        
    }

    /*public override void beforeUpdate() {
        try{    
            LIST<ID> cmuCaseToUpdate = new LIST<ID>();
            
            for(Documents__c documentElement : oldDocumentList){   
               if(  documentElement.CMU_Accept_Reject__c=='Accept' || documentElement.CMU_Accept_Reject__c=='Reject' ){
                system.debug('oldDocumentMap val  '+oldDocumentMap.get(documentElement.Id).Case__c);
                cmuCaseToUpdate.add(oldDocumentMap.get(documentElement.Id).Case__c);
                system.debug('cmuCaseToUpdate 1 '+cmuCaseToUpdate);
                system.debug('documentElement.CMU_Accept_Reject__c 1 '+documentElement.CMU_Accept_Reject__c);
               }
            }
            
            MAP<Id,Boolean> cmuCaseDocumentMap = new MAP<Id,Boolean>();

            if(!cmuCaseToUpdate.isEmpty()){
                for(Documents__c docRecs: [Select Id,Case__c,Document_type__C, Selfie_report_Pass__c,Case__r.Id from Documents__c where  Case__c IN : cmuCaseToUpdate AND Document_type__C!='Customer Image']){
                    
                        if(cmuCaseDocumentMap.containsKey(docRecs.Case__r.Id) && !cmuCaseDocumentMap.get(docRecs.Case__r.Id)){
                            continue;
                        }else{
                            cmuCaseDocumentMap.put(docRecs.Case__r.Id,docRecs.Selfie_report_Pass__c);
                            system.debug('cmuCaseDocumentMap 1 '+cmuCaseDocumentMap);
                        }

                    }
                    system.debug('cmuCaseDocumentMap 2 '+cmuCaseDocumentMap);
                for(Documents__c customerImageDocument: [Select Id,Case__c,Document_type__C, Selfie_report_Pass__c,Case__r.Id from Documents__c where  Case__c IN : cmuCaseToUpdate AND Document_type__C='Customer Image']){
                    
                    if(cmuCaseDocumentMap.get(customerImageDocument.Case__c)==true){
                        customerImageDocument.addError('You cannot Accept/Reject CMU');
                    }
                }
            }
        } Catch(Exception e){
            System.debug('***Exception '+e.getMessage()+' occurred at line number '+e.getLineNumber());
            ErrorLoggerUtil.logErrorEvent(System.Label.documentTriggerHandler, ' afterUpdate ', System.Label.Apex, e);
            throw new TriggerHandler.TriggerHandlerException(System.Label.ExceptionMessage);
        }        
    }*/
}