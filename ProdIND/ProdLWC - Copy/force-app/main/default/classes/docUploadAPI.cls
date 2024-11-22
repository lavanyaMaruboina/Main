@RestResource(urlMapping='/v1/docUploadAPI/')
global without sharing class docUploadAPI { 
    @HttpPost
    global static void uploadLoanDocument(){
        
        RestRequest req  = RestContext.request;
        String docUpload=req.requestBody.toString();
        system.debug('*****docUpload*****' +docUpload);
        String loanApplicationId;
        String base64EncodedImage;
        String documentType;
        String imageName;
        String caseID;
        String documentSide;
        String opportunityRelation;
        
        try{
            Id d;
            system.debug( JSON.deserializeUntyped(docUpload)); 
            requestWrapper jsonParsed =(requestWrapper) JSON.deserialize(docUpload,requestWrapper.class);
            
            loanApplicationId = jsonParsed.loanApplicationId;
            base64EncodedImage = jsonParsed.base64EncodedImage;
            documentType = jsonParsed.documentType; 
            imageName = jsonParsed.imageName;
            caseID = jsonParsed.caseID;
            documentSide=jsonParsed.documentSide;  
            
            String applicantRelation;
            //Start :To check the extension validation :IND-401 raj gupta
            /*  set<string> extension = new Set<String>{'.jpeg', '.jpg', '.png'};
			Boolean result;
			result = extension.contains(documentType);
			//End : IND-401 raj gupta */
			
            if(String.isNotBlank(base64EncodedImage))
            {                
                List<Documents__c> existingdocObject;
                Documents__c docObject= new Documents__c(Name = documentType);
                if(documentType != System.Label.AadhaarCard && documentType != System.Label.PassportCard && documentType != System.Label.VoterIdCard && documentType != System.Label.DrivingLicences && documentType != System.Label.PanCards && documentType != System.Label.Form60DocumentType && documentType != System.label.GST_CERT && documentType != System.label.CIN_CERT){
                    docObject.is_Active__c=true;
                }
                switch on documentType {
                    when 'Vehicle Insurance Policy', 'Vehicle RC Copy', 'Vehicle Image', 'Valuation Report' {
                        opportunityRelation=loanApplicationId;
                        Opportunity oppRecord=[Select id,(Select Id,Applicant_Type__c from Applicants__r where Applicant_Type__c='Borrower') from Opportunity where Id=:loanApplicationId];
                        system.debug('oppRecord.Applicants__r.Id '+oppRecord.Applicants__r[0].Id);
                        existingdocObject= [Select Id,Document_Side__c,RecordTypeId from Documents__c where Document_Type__c=:documentType And Opportunity_Relation__c=:loanApplicationId ORDER BY CreatedDate DESC limit 1 ];
                        applicantRelation=oppRecord.Applicants__r[0].Id;
                    }
                    when else {
                        Applicant__c opp= [Select Id,   Opportunity__c from Applicant__c where Id=:loanApplicationId];
                        opportunityRelation=opp.Opportunity__c;
                        if(caseID !=null && caseID !=''){
                            existingdocObject= [Select Id,Document_Side__c,RecordTypeId from Documents__c where Document_Type__c=:documentType And Applicant__c=:loanApplicationId AND Case__c=:caseID ORDER BY CreatedDate DESC limit 1];
                        }else{
                             existingdocObject= [Select Id,Document_Side__c,RecordTypeId from Documents__c where Document_Type__c=:documentType And Applicant__c=:loanApplicationId ORDER BY CreatedDate DESC limit 1];
                        }
                        
                        applicantRelation=loanApplicationId;
                    }
                }
                
                ID personAccountRecordType = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get(System.Label.KYCDocument).getRecordTypeId();
                
                // Documents__c docObject= new Documents__c(Name = documentType,Applicant__c=loanApplicationId);
                // docObject.Opportunity_Relation__c=opp.Opportunity__c;
                docObject.Applicant__c=applicantRelation;
                docObject.Opportunity_Relation__c=opportunityRelation;
                docObject.RecordTypeId = personAccountRecordType;
                docObject.Document_Type__c=documentType;
                docObject.Document_Side__c=documentSide;                
                if(documentType=='Residence Front View' || documentType =='Office Front View' || documentType == 'Land Photo' || (documentType != system.label.PanCards && documentType != system.label.AadhaarCard && documentType != system.label.DrivingLicences && documentType != system.label.PassportCard && documentType != system.label.VoterIdCard && documentType != System.Label.CustomerImageDocumentType && documentType != System.Label.Form60DocumentType )){
                    if(String.isNotBlank(caseID)){
                        docObject.Case__c=caseID;
                    }
                    docObject.RecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get(System.Label.Other_Document_Record_Type).getRecordTypeId();
                }                
                system.debug( 'here    '+existingdocObject);
                if(existingdocObject.isEmpty()){
                    insert docObject;
                    d=docObject.Id;
                }else{                   
                    System.debug('existingdocObject '+existingdocObject.get(0).Id);
                    existingdocObject.get(0).Document_Side__c=documentSide;   
                    if(documentType == system.label.PanCards || 
                      documentType == system.label.AadhaarCard ||
                      documentType == system.label.DrivingLicences ||
                      documentType == system.label.PassportCard ||
                      documentType == system.label.VoterIdCard || 
                      documentType == System.Label.CustomerImageDocumentType ||
                      documentType == System.Label.Form60DocumentType ){
                        existingdocObject.get(0).RecordTypeId = personAccountRecordType;
                    }else{
                        Id assetVerification = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('Asset Verification Documents').getRecordTypeId();
                        if(assetVerification != existingdocObject.get(0).RecordTypeId){
                            existingdocObject.get(0).RecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get(System.Label.Other_Document_Record_Type).getRecordTypeId();
                        }
                    }
                    if(caseID  != null && caseID !=''){
                        existingdocObject.get(0).Case__c=caseID;                        
                    }                 
                    
                    update existingdocObject;
                    d=existingdocObject.get(0).Id;                    
                    System.debug('existingdocObject d : '+d);
                }
                
                Set<Id> docIdSet = new Set<Id>();
                for(ContentDocumentLink contentdoc : [Select ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId =: d ]){
                    docIdSet.add(contentdoc.ContentDocumentId);
                }
                List<ContentVersion> cv=[SELECT Id,Document_Side_fileupload__c,ContentDocumentId from Contentversion where ContentDocumentId IN : docIdSet  AND Document_Side_fileupload__c =: documentSide ORDER BY CreatedDate ASC ];
                system.debug('cv '+cv);
                if(!cv.isEmpty()){
                    system.debug('here 2 '+cv[0].ContentDocumentId);
                    for(ContentVersion conV : cv){
                        LwcLOSLoanApplicationCntrl.kycContentDocDelete(d, false, true, conV.ContentDocumentId);
                        
                    }
                    if(documentType == system.label.DrivingLicences || documentType == system.label.PassportCard || documentType == system.label.VoterIdCard){
                        if(documentSide == 'Front'){
                            existingdocObject.get(0).isFrontDocReplaced__c = true;
                        }else if(documentSide == 'Back'){
                            existingdocObject.get(0).isBackDocReplaced__c = true;
                        }
                        update existingdocObject;
                    }
                }
                
                
                
                Blob body = EncodingUtil.base64Decode(base64EncodedImage);
                ContentVersion cVersion = new ContentVersion();
                cVersion.ContentLocation = 'S'; 
                cVersion.PathOnClient = d+'.JPEG';
                cVersion.Origin = 'C';//CISP-2906
                cVersion.Document_Side_fileupload__c=documentSide;
                cVersion.OwnerId = UserInfo.getUserId();
                cVersion.Title = documentSide+'_'+imageName+'_'+documentType+'_'+DateTime.now().millisecond()+'.JPEG';
                
                cVersion.VersionData = body;
                //cVersion.Document_Type__c = documentType;
                Insert cVersion;
                
                //After saved the Content Verison, get the ContentDocumentId
                Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
                
                //Insert ContentDocumentLink
                ContentDocumentLink cDocLink = new ContentDocumentLink();
                cDocLink.ContentDocumentId = conDocument;
                cDocLink.LinkedEntityId = d;
                cDocLink.ShareType = 'I';
                cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
                Insert cDocLink;
                
                ContentDistribution cd = new ContentDistribution();
                cd.Name = cVersion.Title;
                cd.ContentVersionId = cVersion.id;
                cd.PreferencesAllowViewInBrowser= false;
                cd.PreferencesLinkLatestVersion=true;
                cd.PreferencesNotifyOnVisit=false;
                cd.PreferencesPasswordRequired=false;
                cd.PreferencesAllowOriginalDownload= true;
                Insert cd; 
                UploadDataCustomResponse[] res = new UploadDataCustomResponse[]{ 
                    new UploadDataCustomResponse('SUCCESS', String.valueof(conDocument))
                        };
                            RestContext.response.statusCode = 200;
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize('Document uploaded successfully'));
                
                system.debug('*****RestContext*****' +RestContext.response);
                if (loanApplicationId!=Null)
                {
                    //list<Opportunity>  applicationDetails = [SELECT Id,Document_upload_status__c From Opportunity WHERE Id=:loanApplicationId];
                    //applicationDetails[0].Document_upload_status__c= True;
                    //update applicationDetails[0];
                }
                // }
            }
            else
            {
                if (loanApplicationId!=Null){
                    //list<Opportunity>  applicationDetails = [SELECT Id,Document_upload_status__c From Opportunity WHERE Id=:loanApplicationId];
                    //applicationDetails[0].Document_upload_status__c= True;
                    //update applicationDetails[0];
                }
                UploadDataCustomResponse[] res = new UploadDataCustomResponse[]{ 
                    new UploadDataCustomResponse('Failure', 'bitmap not coming properly')
                        };
                            RestContext.response.statusCode = 201;
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize('bitmap not coming properly'));
            }
            
          try{
                IntegrationUtilities.createIntegrationLogger('', '', docUpload, '', 'DocUploadAPI', '', opportunityRelation,System.Label.Success);
            }catch(Exception e){
                System.debug(e.getMessage());
                String errString = e.getMessage()  + ' :: ' + e.getLineNumber() + ' :: ' + e.getCause();
                ErrorLoggerUtil.logErrorEvent('docUploadAPI', 'uploadLoanDocument', System.Label.Apex, new IND_Exception(errString), opportunityRelation);
            }  
        } 
        
        catch(Exception e) {
            system.debug('exc '+e.getMessage());
            system.debug('exc '+e.getLineNumber());
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize('Something went wrong'));
            System.debug(e.getMessage());
            String errString = e.getMessage()  + ' :: ' + e.getLineNumber() + ' :: ' + e.getCause();
            ErrorLoggerUtil.logErrorEvent('docUploadAPI', 'uploadLoanDocument', System.Label.Apex, new IND_Exception(errString));
            
        }
    }
    Public class requestWrapper{
        Public String loanApplicationId;
        Public String documentType;
        Public String base64EncodedImage;
        Public String imageName;
        Public String caseID;
        Public String documentSide;
    }
}