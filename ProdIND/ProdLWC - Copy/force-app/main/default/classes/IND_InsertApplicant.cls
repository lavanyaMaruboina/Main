@RestResource(urlMapping='/v1/InsertApplicant/')
global with sharing class IND_InsertApplicant {
    @HttpPost
    global static void InsertApplicant(){
        
        RestRequest req  = RestContext.request;
        String InsertApplicantResponseString=req.requestBody.toString();
        String successMsg = 'Applicant and Loan Application record updated successfully';
        String endpoint = URL.getSalesforceBaseUrl().toExternalForm();
        endpoint += '/services/apexrest/v1/InsertApplicant/';
        String loanApplicationId;
        String base64EncodedImage;
        String documentType;
        String imageName;
        String documentSide;
        
        IND_InsertApplicantWrapper userInsertData = (IND_InsertApplicantWrapper)IND_InsertApplicant.parseJSONRequest(InsertApplicantResponseString, 'IND_InsertApplicantWrapper');
        System.debug('****'+userInsertData.Applicantdata);
        
        List<IND_InsertApplicantWrapper.applicantdata> lstaappdata = (List<IND_InsertApplicantWrapper.applicantdata>) userInsertData.Applicantdata;
        System.debug('****lstaappdata'+lstaappdata);
        Opportunity opp = new Opportunity();
        Applicant__c applcntbrw = new Applicant__c();
        Applicant__c applcntcobrw = new Applicant__c();
        Documents__c document ;
        List<Documents__c> lstDocs = new List<Documents__c>();
        Map<String, Id> mapapplcntid = new Map<String,Id>();
        
        ContentVersion cVersion;
        List<ContentVersion> lstCnctVer = new List<ContentVersion>();
        Map<String, Id> mapDoctypeDocid = new Map<String,Id>();
        
        ContentDocumentLink condoclink ;
        List<ContentDocumentLink> lstCnctDocLink = new List<ContentDocumentLink>();
        Map<String, Id> mapPathOnclentdocid = new Map<String,Id>();
        
        ContentDistribution cd ;
        List<ContentDistribution> lstCnctDis = new List<ContentDistribution>();
        
        Map<String, String> mapDoctypeDocSideBlob = new Map<String,String>();
        Map<String, String> mapDoctypeDocSideImageName = new Map<String,String>();
        ID personAccountRecordType = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get(System.Label.KYCDocument).getRecordTypeId();
        List<Applicant__c> lstapplcnt = new List<Applicant__c>();
        // for(IND_InsertApplicantWrapper.applicantdata  app : lstaappdata){
        // System.debug('****app'+app.loan);
        for(IND_InsertApplicantWrapper.LA  ln : lstaappdata[0].LA){
            System.debug('****ln'+ln);
            //Opportunity opp = new Opportunity();
            //Applicant__c applcnt = new Applicant__c();
            if(ln.type =='LA'){
                opp.name =ln.LoanApplicationName;
                //opp.CloseDate =date.valueOf(ln.CloseDate);
                String[] strDate = ln.CloseDate.split('/');
                Integer mydate = Integer.valueOf(strDate[0]);
                Integer mymonth = Integer.valueOf(strDate[1]);
                Integer myyear = Integer.valueOf(strDate[2]);
                Date dt = Date.newInstance(myyear, mymonth, mydate);
                opp.CloseDate = dt;
                opp.AccountId ='001710000062oBlAAI';
                opp.StageName =ln.Stage;
                opp.Non_Dealer_DSM_Name1__c =ln.NonDealerDSMName1;
                opp.Non_Dealer_DSM_Name2__c =ln.NonDealerDSMName2; 
                
                opp.Vehicle_Type__c =ln.vehicleType;
                opp.Vehicle_Sub_Category__c =ln.vehicleSubCategory;
                opp.Parent_Deal_number__c =ln.parentDealNumber;
                opp.Registration_Number_Format__c =ln.registrationNumberFormat;
                opp.Vehicle_Registration_Number__c =ln.vehicleRegistrationNumber;
                opp.NOC_Number__c =ln.nocRefrenceNumber;
                system.debug('***'+opp);
                
            }
        }
        for(IND_InsertApplicantWrapper.Borrower  ln : lstaappdata[0].Borrower){
            if(ln.type =='Borrower'){
                applcntbrw.Applicant_Type__c ='Borrower';
                applcntbrw.name =ln.name;
                applcntbrw.Contact_number__c =ln.contactNumber;
                applcntbrw.Whatsapp_number__c =ln.waNumber;
                //applcntbrw.name =ln.salutation;
                applcntbrw.Income_source_available__c =ln.incomesourceAvailable;
                applcntbrw.Declared_income__c =ln.declearedIncome;
                applcntbrw.Loan_Amount__c =ln.requiredLoanAmount;
                applcntbrw.Do_you_have_a_bank_account__c =ln.doYouHaveABankAccount;
                applcntbrw.Do_you_have_a_bank_account_with_IBL__c =ln.doYouHaveABankAccountWithIIB;
                applcntbrw.Would_you_like_to_open_a_bank_account__c =ln.wouldYouLiketoOpenBankAccountWithIIB;
                
                
            }
        }
        for(IND_InsertApplicantWrapper.Coborrower  ln : lstaappdata[0].Coborrower){
            if(ln.type =='Co-borrower'){
                applcntcobrw.Applicant_Type__c ='Co-borrower';
                applcntcobrw.name =ln.name;
                applcntcobrw.Contact_number__c =ln.contactNumber;
                applcntcobrw.Whatsapp_number__c =ln.waNumber;
                //applcntcobrw.name =ln.salutation;
                applcntcobrw.Income_source_available__c =ln.incomesourceAvailable;
                applcntcobrw.Declared_income__c =ln.declearedIncome;
                applcntcobrw.Do_you_have_a_bank_account__c =ln.doYouHaveABankAccount;
                applcntcobrw.Do_you_have_a_bank_account_with_IBL__c =ln.doYouHaveABankAccountWithIIB;
                applcntcobrw.Would_you_like_to_open_a_bank_account__c =ln.wouldYouLiketoOpenBankAccountWithIIB; 
            }
        }
        
        
        //}
        
        try{
            Long startTime = DateTime.now().getTime();
            insert opp;
            String loanAppId = opp.id;
            applcntbrw.Opportunity__c =opp.id;
            lstapplcnt.add(applcntbrw);
            applcntcobrw.Opportunity__c = opp.id;
            if(String.isBlank(applcntcobrw.name)){
                
            }
            lstapplcnt.add(applcntcobrw);
            insert lstapplcnt;
            
            List<Applicant__c> lstapplcnts= [Select Id,	Opportunity__c,Applicant_Type__c from Applicant__c where Opportunity__c =:opp.id];
            for( Applicant__c app : lstapplcnts ){
                mapapplcntid.put(app.Applicant_Type__c ,app.id);
            }
            
            
            for(IND_InsertApplicantWrapper.Document  dc : lstaappdata[0].document){
                System.debug('****dc'+dc); 
                document = new Documents__c();
                
                if(dc.Applicanttype =='Borrower'){
                    document.Opportunity_Relation__c = opp.id;
                    document.RecordTypeId = personAccountRecordType;
                    document.Document_Type__c = dc.documentType;
                    document.Document_Side__c = dc.documentSide;
                    document.Name = dc.documentType;
                    document.Applicant__c = mapapplcntid.get(dc.Applicanttype);
                    lstDocs.add(document);
                    mapDoctypeDocSideBlob.put(dc.documentType + dc.documentSide + mapapplcntid.get(dc.Applicanttype) , dc.base64EncodedImage);
                    mapDoctypeDocSideImageName.put(dc.documentType + dc.documentSide + mapapplcntid.get(dc.Applicanttype) , dc.imageName);
                    
                }
                else if(dc.Applicanttype =='Co-borrower'){
                    document.Opportunity_Relation__c = opp.id;
                    document.RecordTypeId = personAccountRecordType;
                    document.Document_Type__c = dc.documentType;
                    document.Document_Side__c = dc.documentSide;
                    document.Name = dc.documentType;
                    document.Applicant__c = mapapplcntid.get(dc.Applicanttype);
                    lstDocs.add(document);
                    mapDoctypeDocSideBlob.put(dc.documentType + dc.documentSide + mapapplcntid.get(dc.Applicanttype) , dc.base64EncodedImage);
                    mapDoctypeDocSideImageName.put(dc.documentType + dc.documentSide + mapapplcntid.get(dc.Applicanttype) , dc.imageName);
                    
                }
            }
            if(lstDocs.size()>0){
                
                insert lstDocs;
            }
            
            List<Documents__c> lstdocuments= [Select Id,Document_Type__c,Document_Side__c,Applicant__c from Documents__c where Applicant__c IN :mapapplcntid.values()];
            for( Documents__c doc : lstdocuments ){
                cVersion = new ContentVersion();
                Blob body = EncodingUtil.base64Decode(mapDoctypeDocSideBlob.get(doc.Document_Type__c + doc.Document_Side__c + doc.Applicant__c));
                cVersion.ContentLocation = 'S'; 
                cVersion.PathOnClient = doc.id+'.JPEG';
                cVersion.Origin = 'H';
                cVersion.Document_Side_fileupload__c=doc.Document_Side__c;
                cVersion.OwnerId = UserInfo.getUserId();
                cVersion.Title = doc.Document_Side__c+'_'+mapDoctypeDocSideImageName.get(doc.Document_Type__c + doc.Document_Side__c + doc.Applicant__c)+'_'+doc.Document_Type__c+'_'+DateTime.now().millisecond()+'.JPEG';
                cVersion.VersionData = body;
                
                lstCnctVer.add(cVersion);
                mapPathOnclentdocid.put(doc.id+'.JPEG',doc.id);
            }
            Insert lstCnctVer;
            
            List<ContentVersion> lstContentVersions= [SELECT id,Title,PathOnClient,ContentDocumentId FROM ContentVersion WHERE Id IN : lstCnctVer];
            for( ContentVersion cnv : lstContentVersions ){
                
                condoclink = new ContentDocumentLink();
                condoclink.ContentDocumentId = cnv.ContentDocumentId;
                condoclink.LinkedEntityId = mapPathOnclentdocid.get(cnv.PathOnClient);
                condoclink.ShareType = 'I';
                condoclink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
                
                lstCnctDocLink.add(condoclink);
                
                cd = new ContentDistribution();
                cd.Name = cnv.Title;
                cd.ContentVersionId = cnv.id;
                cd.PreferencesAllowViewInBrowser= false;
                cd.PreferencesLinkLatestVersion=true;
                cd.PreferencesNotifyOnVisit=false;
                cd.PreferencesPasswordRequired=false;
                cd.PreferencesAllowOriginalDownload= true;
                lstCnctDis.add(cd);
            }
            Insert lstCnctDocLink;
            Insert lstCnctDis; 
            
            Long endTime = DateTime.now().getTime();
            String elapseTime = String.valueOf((endTime - startTime)/1000);
            RestContext.response.statusCode = 200; 
            String sucdec = loanAppId + ' Loan Application Created Successfully';
            String sucmsg = '{ "response": { "status": "SUCCESS", "respDesc": "'+sucdec+'"} }';
            RestContext.response.responseBody = Blob.valueOf(sucmsg);
            IntegrationUtilities.createIntegrationLogger('request', InsertApplicantResponseString, 'Success response', sucmsg, 'InsertApplicant', elapseTime, loanAppId);
            
        }catch(Exception ex){
            RestContext.response.statusCode = 400;
            
            String deserror = 'Something went wrong ---> '+ex.getMessage()+ ' Exception line number-->'+ex.getLineNumber();
            String error = '{ "response": { "status": "FAILED", "respDesc": "'+deserror+'"} }';
            RestContext.response.responseBody = Blob.valueOf(error);
            System.debug('-----ex'+deserror);
            String loanAppId = '';
            IntegrationUtilities.createIntegrationLogger('request', InsertApplicantResponseString, 'Error response',error , 'InsertApplicant', '', '');
            ErrorLoggerUtil.logError('IND_InsertApplicant','InsertApplicant', error, ex);
            
            
        } 
    } 
    
    public static IND_InsertApplicantWrapper parseJSONRequest(String responseBody, String className){
        IND_InsertApplicantWrapper res;
        try{
            JSONParser parser = JSON.createParser(responseBody);
            Type wrapperType = Type.forName(className);
            res = (IND_InsertApplicantWrapper)parser.readValueAs(wrapperType);
        }catch(Exception ex){
            System.debug('Exception-->'+ex.getMessage() + ' Exception line number-->'+
                         ex.getLineNumber()+' Exception stack trace-->'+ ex.getStackTraceString());
            ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'parseJSONRequest', System.Label.Apex, ex);
            throw new CalloutException(ex.getMessage());  
        }
        return res;
    }
    
    
}