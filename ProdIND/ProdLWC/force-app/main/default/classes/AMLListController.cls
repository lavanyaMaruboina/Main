/*------------------------------------------------------------
Author:        Daksh Mandowara
Class Name:    AmlCheckData
Description:   This class is used show AML List in CAM summary screen to approve or reject.
------------------------------------------------------------*/
public class AMLListController {
    public list <AML_Check__c> amlCheckList{get;set;}
    public boolean isAMLVisible{get;set;}
    public boolean disableButton{get;set;}
    public static Id camRecordId;
    public static Id recordId;
    public String data{get;set;}
    
    public boolean amlChecksAvailable{get;set;} 
    public List<String> redProposalLst{get;set;}
    public Boolean isRedPoposalAvailable{get;set;}
    //variable refers to the async service name
    //variable refers to the async ParentAPIRequest
    // Test variable used for holding a reference to the Continuation Request
    @TestVisible
    public String continuationLabel;
    
    // Test variable used for holding the value of the Continuation.state attribute
    @TestVisible
    public Object continuationState;
    
    public String loanApplicationRef;
    public AMLListController(){
        Profile prof = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
        if(prof.Name.equals('IBL Credit Head')){
            try {
                camRecordId = ApexPages.currentPage().getParameters().get('id');
                recordId = ApexPages.currentPage().getParameters().get('c_loanappid');
                if(camRecordId!=null){
                    recordId = [SELECT Loan_Application__c FROM CAM__c WHERE Id=:camRecordId LIMIT 1].Loan_Application__c;
                }
                amlCheckList = [SELECT Id, Matched_base__c,List_Name__c,Name__c,Name_Score__c,
                                ML_Id__c,Nationality__c,Nationality_Score__c,ML_Address__c,
                                ML_City__c,ML_Date_Of_Birth__c,ML_Description__c,CA_Decision__c,
                                Remarks_Credit_Analyst__c,CH_Decision__c,Remarks_Credit_Head__c,Documents__c,
                                CMU_Decision__c,Remarks_CMU__c,BE_CVO_Decision__c,Remarks_BE_CVO__c, Score__c,
                                Case__c,Case__r.Status,Content_Document_Id__c FROM AML_Check__c WHERE 
                                CA_Decision__c = 'Positive' AND Case__r.Status =: System.label.Pendingcredithead AND Loan_Application__c =: recordId WITH SECURITY_ENFORCED];
                if(!amlCheckList.isEmpty()){
                    amlChecksAvailable = true;
                }else{
                    amlChecksAvailable = false;
                }
            }catch(Exception e){
                ErrorLoggerUtil.logErrorEvent('LoanDisbursementController', 'AMLListController', System.Label.Apex, e);
                throw new AuraHandledException(e.getMessage() + e.getStackTraceString());
            }
        }
    }
    /*@Method Name: getAmlCheckList
    * @Created by:  Daksh Mandowara
    * @description: To get AML data.
    * @Return:      AML records
    */
    public List<AML_Check__c> getAmlCheckList(){
        if(String.isNotBlank(recordId)){
            List<AML_Check__c> amls = [SELECT Id, Matched_base__c,List_Name__c,Name__c,Name_Score__c,
                            ML_Id__c,Nationality__c,Nationality_Score__c,ML_Address__c,
                            ML_City__c,ML_Date_Of_Birth__c,ML_Description__c,CA_Decision__c,
                            Remarks_Credit_Analyst__c,CH_Decision__c,Remarks_Credit_Head__c,Documents__c,
                            CMU_Decision__c,Remarks_CMU__c,BE_CVO_Decision__c,Remarks_BE_CVO__c, Score__c,
                            Case__c,Case__r.Status FROM AML_Check__c WHERE 
                            CA_Decision__c = 'Positive' AND Case__r.Status =: System.label.Pendingcredithead AND Loan_Application__c =: recordId WITH SECURITY_ENFORCED];
            if(!amls.isEmpty()){
                amlChecksAvailable = true;
            }else{
                amlChecksAvailable = false;
            }
            return amls;
        }else{
            amlChecksAvailable = false;
            return null;
        }
    }

    /*@Method Name: Constructor
    * @Created by:  Daksh Mandowara
    * @description: To show AML data in CAM summary screen.
    */
    public AMLListController(ViewCamController controller){
        System.debug('############ START');
        //SFTRAC-1810 Start
        String camId = ApexPages.currentPage().getParameters().get('id');
        String loanRecId = [SELECT Loan_Application__c FROM CAM__c WHERE Id=:camId LIMIT 1].Loan_Application__c;
        System.debug('###loanRecId: '+loanRecId);
        Map<Id,String> caseIdNumberMap = new Map<Id,String>();
        for(Case c: [SELECT Id, caseNumber FROM Case WHERE Loan_Application__c = :loanRecId]){
            caseIdNumberMap.put(c.Id,c.caseNumber);
        }

        List<Field_Investigation__c> fieldInvestigationList = new List<Field_Investigation__c>();
        fieldInvestigationList = [SELECT Id,Coordinates_Verified__c,Case__c FROM Field_Investigation__c WHERE Case__c IN :caseIdNumberMap.keySet() LIMIT 1000];
        redProposalLst = new List<String>();
        for(Field_Investigation__c fi : fieldInvestigationList){
            if(fi.Coordinates_Verified__c == 'Red'){
                System.debug(' >>>>>>>> '+caseIdNumberMap.get(fi.Case__c));
                if(caseIdNumberMap.containsKey(fi.Case__c)){
                    String caseNum = caseIdNumberMap.get(fi.Case__c);
                    redProposalLst.add(caseNum);
                    isRedPoposalAvailable = true;
                }
            }
        }
        //SFTRAC-1810 End
        System.debug('############ END');
        Profile prof = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
        if(prof.Name.equals('IBL Credit Head')){
            try {
                disableButton = false;
                camRecordId = ApexPages.currentPage().getParameters().get('id');
                recordId = ApexPages.currentPage().getParameters().get('c_loanappid');
                if(camRecordId!=null){
                    recordId = [SELECT Loan_Application__c FROM CAM__c WHERE Id=:camRecordId LIMIT 1].Loan_Application__c;
                }
                amlCheckList = [SELECT Id, Credit_Head__c, Matched_base__c,List_Name__c,Name__c,Name_Score__c,
                                ML_Id__c,Nationality__c,Nationality_Score__c,ML_Address__c,
                                ML_City__c,ML_Date_Of_Birth__c,ML_Description__c,CA_Decision__c,
                                Remarks_Credit_Analyst__c,CH_Decision__c,Remarks_Credit_Head__c,Documents__c, Content_Document_Id__c,
                                CMU_Decision__c,Remarks_CMU__c,BE_CVO_Decision__c,Remarks_BE_CVO__c, Score__c,
                                Case__c,Case__r.Status,Case__r.OwnerId,case__r.Loan_Application__r.AML_Check_Completed__c FROM AML_Check__c WHERE 
                                CA_Decision__c = 'Positive' AND Case__r.Status =: System.label.Pendingcredithead AND Loan_Application__c =: recordId WITH SECURITY_ENFORCED];
                if(!amlCheckList.isEmpty()){
                    Set<Id> contentDocIds = new Set<Id>();
                    if(amlCheckList[0].case__r.Loan_Application__r.AML_Check_Completed__c == true) {
                        disableButton = true;
                    }
                    for(AML_Check__c aml : amlCheckList){
                        if(aml.Case__r.OwnerId.equals(UserInfo.getUserId())){
                            if(prof.Name.contains('Credit Head')){
                                aml.Credit_Head__c = TRUE;
                                isAMLVisible = true;
                            }
                        }
                        contentDocIds.add(aml.Content_Document_Id__c);
                    }
                    if(!contentDocIds.isEmpty()){
                        for(ContentDocument doc : [SELECT Id,LatestPublishedVersionId FROM ContentDocument WHERE Id IN :contentDocIds]){
                            for(AML_Check__c aml : amlCheckList){
                                if(aml.Content_Document_Id__c != null){
                                    if(aml.Content_Document_Id__c.equals(doc.Id)){
                                        aml.Content_Document_Id__c = doc.LatestPublishedVersionId;
                                    }
                                }
                            }
                        }
                    }
                    amlChecksAvailable = true;
                }else{
                    amlChecksAvailable = false;
                }
            }catch(Exception e){
                ErrorLoggerUtil.logErrorEvent('LoanDisbursementController', 'AMLListController', System.Label.Apex, e);
                throw new AuraHandledException(e.getMessage() + e.getStackTraceString());
            }
        }
    }
    /*@Method Name: getItems
    * @Created by:  Daksh Mandowara
    * @description: To show options for final decision column in CAM summary screen.
    * @Return:      List<SelectOption>  -  options
    */
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--Select--'));
        options.add(new SelectOption('Positive','Positive'));
        options.add(new SelectOption('False Positive','False Positive'));
        return options;
    }

    /*@Method Name: approveAML
    * @Created by:  Daksh Mandowara
    * @description: To approve the AML Case.
    * @Return:      void
    */
    public void approveAML() {
        
        try {
            camRecordId = ApexPages.currentPage().getParameters().get('id');
            recordId = ApexPages.currentPage().getParameters().get('c_loanappid');
            List<Opportunity> updLoanList = new List<Opportunity>();
            if(camRecordId!=null){
                recordId = [SELECT Loan_Application__c FROM CAM__c WHERE Id=:camRecordId LIMIT 1].Loan_Application__c;
            }
            List<Opportunity> approveLoanList =[SELECT id,AML_Check_status__c FROM Opportunity WHERE Id=:recordId];
            for(Opportunity loan:approveLoanList){
                loan.AML_Check_status__c = 'Approved';
                loan.AML_Check_Completed__c = TRUE;
                updLoanList.add(loan);
            }
            Id amlRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('AML Check').getRecordTypeId();
            List<Case> cases = [SELECT Id,Status,IsClosed FROM Case WHERE Loan_Application__c = :recordId AND RecordTypeId = :amlRecordTypeId WITH SECURITY_ENFORCED];
            if(!cases.isEmpty()){
                List<Case> updatedCases = new List<Case>();
                for(Case cs:cases ){
                    if(!cs.IsClosed){
                        Case cas = new Case();
                        cas.Id = cs.Id;
                        cas.Status = 'Closed';
                        updatedCases.add(cas);
                    }
                }
                if(!updatedCases.isEmpty()){
                    Update updatedCases;
                }
            }
            if(!amlCheckList.isEmpty()){
                Update amlCheckList;
            }
            if(!updLoanList.isEmpty()){
                Update updLoanList;
            }
            disableButton = true;
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.CONFIRM,
                    System.label.AMLcheckapproved
                )
            );
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('LoanDisbursementController', 'approveAML', System.Label.Apex, e);
            throw new AuraHandledException(e.getMessage() + e.getStackTraceString());
        }
    }

    /*@Method Name: rejectAML
    * @Created by:  Daksh Mandowara
    * @description: To reject the AML Case.
    * @Return:      Continuation value
    */
    public Object rejectAML() {
        Continuation con;
        String loanAppId;
		Boolean redirectToHome = false;
        try {
            camRecordId = ApexPages.currentPage().getParameters().get('id');
            recordId = ApexPages.currentPage().getParameters().get('c_loanappid');
            if(camRecordId!=null){
                recordId = [SELECT Loan_Application__c FROM CAM__c WHERE Id=:camRecordId WITH SECURITY_ENFORCED LIMIT 1].Loan_Application__c;
            }
            System.debug(recordId);
            List<Applicant__c> rejApplicantList =[SELECT Id,Opportunity__c,Opportunity__r.AML_Check_status__c,Opportunity__r.Sanction_Status__c,Contact_number__c, Whatsapp_number__c, Opportunity__r.Lead_number__c FROM Applicant__c WHERE 
                                                  Opportunity__c =:recordId WITH SECURITY_ENFORCED];
            SYstem.debug(rejApplicantList);
            Map<Id,Case> updatedCases = new Map<Id,Case>();
            for(Applicant__c applicant:rejApplicantList){
                if(applicant.Opportunity__r.Sanction_Status__c =='STP'){
                    Map<String,String> smsMapping = new Map<String,String>();
                    smsMapping.put('loanApplicationId',recordId);
                    smsMapping.put('flag','AML');
                    smsMapping.put('applicantId',applicant.Id);
                    String smsStr = JSON.serialize(smsMapping);
                    //con = IntegrationEngine.doSmsGatewayCallout(smsStr);
                    if(String.isBlank(smsStr)){
                        throw new IND_Exception(System.Label.Retry);
                    }
                    //Provide API-wise Integration Name to Custom Metadata Configs
                    Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.SMSGateway);
                    
                    //if stubs checked in Integration_Configuration then stubs will return 
                    if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                        String stubData = IntegrationUtilities.getStubResponse(System.Label.SMSGateway);
                        return stubData == null ? System.Label.EmptyStubs : stubData;
                    }
                    
                    Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
                    System.debug(smsStr);
                    RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(smsStr,'RequestWrapper');
                    List<Applicant__c> app = [SELECT Id,Contact_number__c, Whatsapp_number__c, OTP_for_borrower__c,Opportunity__r.Lead_number__c FROM Applicant__c WHERE Id=:requestWrapper.applicantId WITH SECURITY_ENFORCED LIMIT 1];
                    
                    if(app.isEmpty()){
                        throw new IND_Exception(System.Label.Applicantdatamissing);
                    } else {
                        for(Applicant__c rejApplicant:rejApplicantList){
                            requestWrapper.leadId= rejApplicant.Opportunity__r.Lead_Number__c;
                            requestWrapper.contactNumber= rejApplicant.Contact_number__c;
                            requestWrapper.whatsappNo = rejApplicant.Whatsapp_number__c;
                        }
                    }
                    
                    loanAppId = requestWrapper.loanApplicationId;
                    loanApplicationRef= requestWrapper.loanApplicationId;
                    IND_SMSRequest smsRequest = IND_SMSService.getSmsCallOutRequest(requestWrapper); 
                    CalloutProcessor processor = new CalloutProcessor(System.Label.SMSGateway, smsRequest);
                    HttpRequest request = processor.createHttpRequest();
                    
                    Long startTime = DateTime.now().getTime();
                    
                    Carrier carr = new carrier(System.Label.SMSGateway, processor, request.getBody(), startTime, loanAppId,
                                               IntegrationUtilities.getPlainTextForLog(request.getBody()));
                    
                    //Add callout request to continuation
                    con = new Continuation(timeout);        
                    con.continuationMethod='processSMSGatewayResponse';
                    con.state=carr;
                    con.addHttpRequest(request);
                    system.debug(con);
                    if(Test.isRunningTest()) {
                        this.continuationLabel = con.addHttpRequest(request);
                        this.continuationState = carr; 
                    }             
                    
                    // Send sms to STP LoanApplication's Contact No.
                }
                redirectToHome = true;
                Opportunity opp =  new Opportunity();
                    opp.AML_Check_status__c =  'Rejected';
                    opp.Journey_Status__c = 'Stop';
                    opp.IsRejected__c = TRUE;
                    opp.Id = recordId;
                    if(opp!=null){
                        Update opp;
                    }
                if(!amlCheckList.isEmpty()){
                    Update amlCheckList;    
                }
                Id propRecId = Schema.SObjectType.Proposal_Approval_Log__c.getRecordTypeInfosByName().get('Proposal log').getRecordTypeId();

                Insert new Proposal_Approval_Log__c(RecordTypeId=propRecId,Role__c='CH',Approval_Status__c='Rejected',Approval_Condition__c='AML Rejected',Parent_CAM__c=camRecordId);
                Id amlRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('AML Check').getRecordTypeId();
                List<Case> cases = [SELECT Id,Status,IsClosed FROM Case WHERE Loan_Application__c = :recordId AND RecordTypeId = :amlRecordTypeId WITH SECURITY_ENFORCED];
                System.debug(cases);
                if(!cases.isEmpty()){
                    for(Case cs:cases ){
                        if(!cs.IsClosed){
                            Case cas = new Case();
                            cas.Id = cs.Id;
                            cas.Status = 'Closed';
                            updatedCases.put(cs.Id,cas);
                        }
                    }
                    system.debug(updatedCases);
                }
            }
            if(!updatedCases.keySet().isEmpty()){
                Update updatedCases.values();
            }
            disableButton = true;
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    System.label.caserejected
                )
            );
			if(redirectToHome){
                PageReference pageRef = new PageReference('/');
                pageRef.setRedirect(true);
                return pageRef;
            }
        } catch (Exception ex) {
            ErrorLoggerUtil.logErrorEvent('AMLListController', 'rejectAML', System.Label.Apex, ex, loanAppId);
        }
        return con;
    }

    /*@Method Name: processSMSGatewayResponse
    * @Created by:  Daksh Mandowara
    * @description: To process SMS gateway Response.
    * @Return:      Object
    */
    public Object processSMSGatewayResponse(List<String> labels, Object state){
        IND_SMSResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        HttpResponse response;
        String elapseTime='';
        String loanAppId='';
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();
            if(response != null && response.getStatusCode() == 200) {
                apiResponse = (IND_SMSResponse)processor.getHttpResponse(response, serviceName);
                    if(apiResponse != null && apiResponse.response.status == 'SUCCESS'){
                        this.data= apiResponse.response.status;
                        Opportunity opp =  new Opportunity();
                        opp.AML_Check_status__c =  'Rejected';
                        opp.IsRejected__c = TRUE;
                        opp.Id = loanAppId;
                        if(opp!=null){
                            Update opp;
            			}
                        if(!amlCheckList.isEmpty()){
            				Update amlCheckList;    
            			}
                        Id amlRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('AML Check').getRecordTypeId();
                        List<Case> cases = [SELECT Id,Status,IsClosed FROM Case WHERE Loan_Application__c = :recordId AND RecordTypeId = :amlRecordTypeId WITH SECURITY_ENFORCED];
                        if(!cases.isEmpty()){
                            List<Case> updatedCases = new List<Case>();
                            for(Case cs:cases ){
                                if(!cs.IsClosed){
                                    Case cas = new Case();
                                    cas.Id = cs.Id;
                                    cas.Status = 'Closed- Revoke';
                                    updatedCases.add(cas);
                                }
                            }
                            if(!updatedCases.isEmpty()){
                                Update updatedCases;
                            }
                            disableButton = true;
                            ApexPages.addMessage(
                                new ApexPages.Message(
                                    ApexPages.Severity.ERROR,
                                    System.label.caserejected
                                )
                            );
                        }
                        IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Success);
                    } else {
                        this.data= 'FAIL';
                        IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime, loanAppId, System.Label.Failure);
                    }                  
            } else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                this.data = System.Label.NoResponse;
            } 
            
        } catch (Exception ex){
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime, loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processResponseSMS', System.Label.Apex, ex, loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
        System.debug(this.data);
        PageReference pageRef = new PageReference('/');
		pageRef.setRedirect(true);
		return pageRef;
    }
    public class Carrier {
        public transient string request;
        public transient string encryptedRequest;
        public transient String serviceName;
        public transient CalloutProcessor processor;
        public transient Long startTime;
        public transient String loanApplicationId;
        public transient List<Object> tempObject;
        
        Carrier(){}
        
        Carrier(String serviceName, CalloutProcessor processor, String encryptRequest, Long startTime, String loanAppId, String plainRequest){
            this.serviceName = serviceName;
            this.processor = processor;
            this.encryptedRequest = encryptRequest;
            this.startTime = startTime;
            this.loanApplicationId = loanAppId;
            this.request = plainRequest;
        }
        
        
        
        
       
        public String getRequest(){
            return request;
        }        
              
        public String getEncryptedRequest(){
            return encryptedRequest;
        }
              
        public CalloutProcessor getProcessor(){
            return processor;
        }       
               
        public String getServiceName(){
            return serviceName;
        }
       
        public Long getStartTime(){
            return startTime;
        } 
        
        public String getLoanApplicationId(){
            return loanApplicationId;
        }
    }
}