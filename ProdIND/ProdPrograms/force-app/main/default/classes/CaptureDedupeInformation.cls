/**
* @Name         CaptureDedupeInformation
* @Author       Raman Raj Saxena
* @Company      Salesforce
* @Description  This is a web service class to capture the Dedupe Response sent from IBM D2C App
* Inputs:       None
* Test Class:   CaptureDedupeInformationTest
*/
@RestResource(urlMapping='/captureDedupeResponse/*')
global with sharing class CaptureDedupeInformation {
    /*
    * @Method:      captureDedupeResponse
    * @Created by:  Raman Raj Saxena
    * @Description: Method to parse and store dedupe response.
    * @Param:       None
    * @Return:     String - response
    */
    @HttpPost
    global static void captureDedupeResponse() {
        try {
            //Request
            RestRequest req  = RestContext.request;
            //Encrypted Request String
            String stringEncryptedRequest=req.requestBody.toString();
            
            //Decrypt the encrypted request
            
            String dedupeResponseString = IntegrationUtilities.getPlainTextForLog(stringEncryptedRequest);
            DedupeData jsonParsed =(DedupeData) JSON.deserialize(dedupeResponseString,DedupeData.class);
            
            //Initialize Loan Application
            Opportunity opp = new Opportunity(Id = jsonParsed.LoanApplicationId);
            opp.Is_ETB__c = jsonParsed.IsETB;
            
            //Fetch Applicant
            Applicant__c objApplicant = [SELECT Id, Customer_First_Name__c, Customer_Last_Name__c FROM Applicant__c WHERE Id =:jsonParsed.ApplicantId];
            objApplicant.Customer_Code__c = jsonParsed.CustomerCode;
            objApplicant.Customer_First_Name__c = String.isNotblank(jsonParsed.FirstName)  ? jsonParsed.FirstName : objApplicant.Customer_First_Name__c;
            objApplicant.Customer_Last_Name__c = String.isNotblank(jsonParsed.LastName)  ? jsonParsed.LastName : objApplicant.Customer_Last_Name__c;
            objApplicant.Name = objApplicant.Customer_First_Name__c+' '+objApplicant.Customer_Last_Name__c;        
            
            if(objApplicant.Name.length() > 80){
                objApplicant.Name = objApplicant.Name.substring(0, 80);
            }
            
            //Initialize Customer Dedupe Response
            Customer_Dedupe_Response__c custDedupeObj = new Customer_Dedupe_Response__c();
            custDedupeObj.Applicant__c = objApplicant.Id;
            custDedupeObj.Customer_Code__c = jsonParsed.CustomerCode;
            custDedupeObj.CIF_Id__c = jsonParsed.CIFId;
            custDedupeObj.CIC_No__c = jsonParsed.cic_number;

            Documents__c objDocument = null;
            //Update the document
            if(String.isNotBlank(jsonParsed.documentId)) {
                objDocument = new Documents__c(Id = jsonParsed.documentId);
                objDocument.KYC_name__c = String.isNotBlank(jsonParsed.FirstName) ? jsonParsed.FirstName + ' ' : '';
                objDocument.KYC_name__c += String.isNotBlank(jsonParsed.LastName) ? jsonParsed.LastName : ''; 
            }
             //insert customer dedupe response
             if(Schema.sObjectType.Customer_Dedupe_Response__c.isCreateable()){
                insert custDedupeObj;
            }

            //TODO : process dedupe response
            //Data dataWrapper = processDedupeResponse(jsonParsed.DedupeResponse, objApplicant, opp);
            DedupeToProcessWrapper dedupeObj = new DedupeToProcessWrapper();
            dedupeObj.opp = opp;
            dedupeObj.applicant = objApplicant;
            dedupeObj.dedupe = custDedupeObj;
            dedupeObj.response = jsonParsed.DedupeResponse;
            
            processDedupeResponseFuture(JSON.serialize(dedupeObj));
            
            if(custDedupeObj.Customer_Code__c != null){
                objApplicant = assignPersonAccountOnApplicant(objApplicant,custDedupeObj.Customer_Code__c);
            }

            //update opportunity
            if(Schema.sObjectType.Opportunity.isUpdateable()){
            	update opp;
            }

            //update applicant
            if(Schema.sObjectType.Applicant__c.isUpdateable()){
                update objApplicant;
            }

            //Update the Document
            if(objDocument != null && Schema.sObjectType.Documents__c.isUpdateable()){
                update objDocument;
            }

            //Respose
            ResponseWrapper response = new ResponseWrapper();
            response.result = 'Updated Succesfully';
            
            String decryptedResponse = JSON.serialize(response);
            
            //encrypting the response
            String encryptedResponse = IntegrationUtilities.getEncryptedRequest(decryptedResponse,System.Label.privateKey,System.Label.ivkey); 
            
            //setting the response body
            String jdataRequest1 = '"JData":';                    
            String body1='{'+jdataRequest1 + '"'+encryptedResponse+'"'+'}';
            RestContext.response.responseBody = Blob.valueOf(body1);
            
            RestContext.response.addHeader('Content-Type', 'application/json');

            //create Integration Log
            IntegrationUtilities.createIntegrationLogger(dedupeResponseString, stringEncryptedRequest, decryptedResponse, encryptedResponse, 'captureDedupeResponse', null, jsonParsed.LoanApplicationId);

        } catch (Exception e) {
           ErrorLoggerUtil.logErrorEvent('CaptureDedupeInformation', 'captureDedupeResponse', 'Apex', e);
           throw new CalloutException(e.getMessage());
        }
    }
    
    
    /*
    * @Method:      assignPersonAccountOnApplicant
    * @Created by:  Raman Raj Saxena
    * @Description: Method to return Applicant.
    * @Param:       objApplicant, customercode
    * @Return:     Applicant__c
    */
    private static Applicant__c assignPersonAccountOnApplicant(Applicant__c objApplicant, String customerCode){
        if(String.isNotBlank(customerCode)){
            List<Account> lstpersonAccount = [Select Id, customer_code__c from Account where Recordtype.Name = 'person account' and customer_code__c =: customerCode];
            if(!lstpersonAccount.isEmpty()){
                objApplicant.Account__c = lstpersonAccount[0].Id;
            }else{
                createPersonAccountOnApplicant(objApplicant, customerCode);
            }
        }
        system.debug('Person Account assigned Applicant : '+objApplicant);
        return objApplicant;
    }

    @future
    public static void processDedupeResponseFuture (String dedupeToProcess) {
        DedupeToProcessWrapper wrapper = (DedupeToProcessWrapper) JSON.deserialize(dedupeToProcess, DedupeToProcessWrapper.class);
        Data dataWrapper =  processDedupeResponse(wrapper.response, wrapper.applicant, wrapper.opp);
        wrapper.dedupe.SF_Cust_Dedupe__c = dataWrapper.custDedupeObj.SF_Cust_Dedupe__c;
        wrapper.dedupe.PG_Cust_Dedupe__c = dataWrapper.custDedupeObj.PG_Cust_Dedupe__c;
        wrapper.dedupe.External_Dedupe_Status__c = dataWrapper.custDedupeObj.External_Dedupe_Status__c;
        wrapper.dedupe.Dedupe_Journey_Status__c = dataWrapper.custDedupeObj.Dedupe_Journey_Status__c;
        wrapper.dedupe.Dedupe_Journey_Status_Reason__c = dataWrapper.custDedupeObj.Dedupe_Journey_Status_Reason__c;
        wrapper.dedupe.Response__c = dataWrapper.custDedupeObj.Response__c;
        //insert customer dedupe response
        if(Schema.sObjectType.Customer_Dedupe_Response__c.isUpdateable()){
            update wrapper.dedupe;
        }

        

    }
     /*
    * @Method:      assignPersonAccountOnApplicant
    * @Created by:  Raman Raj Saxena
    * @Description: Method to return Applicant.
    * @Param:       objApplicant, customercode
    * @Return:     Applicant__c
    */

    private static Applicant__c createPersonAccountOnApplicant(Applicant__c objApplicant, String customerCode){
        Id personAccountRecordTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Account newPersonAccount = new Account();

        newPersonAccount.FirstName = objApplicant.Customer_First_Name__c;
        newPersonAccount.LastName = objApplicant.Customer_Last_Name__c;
        newPersonAccount.Customer_Code__c = String.isNotBlank(customerCode) ? customerCode : null;
        newPersonAccount.RecordTypeId = personAccountRecordTypeId;
        
        if (Schema.sObjectType.Account.isCreateable()) {  
            insert newPersonAccount;
        }
        if(newPersonAccount.id != null){
            objApplicant.Account__c = newPersonAccount.id;
        }
           
        return objApplicant;
    }

    
     /*
    * @Method:      processDedupeResponse
    * @Created by:  Raman Raj Saxena
    * @Description: Method to wrapper which contains data about Opportunity, applicant & customer dedupe response.
    * @Param:       response, app, opp
    * @Return:     String - response
    */
    private static Data processDedupeResponse(String response, Applicant__c app, Opportunity opp){
        //decrypt the response
        String custDedupeResponse = IntegrationUtilities.getPlainTextForLog(response);
        set<string> sPostSanctionStageSet=new Set<string>{};
        Set<String> cicNoSet = new Set<String>();
        Boolean externalDedupeCustCodeExists = false;
        Boolean externalDedupeRecentLeadExists  = false;
        Boolean internalDedupeCustCodeExists = false;
        Boolean finnacleDedupeExists = false;
        Integer sSFCustomerDedupeFlag = 1; //If 0 then exist in SF
        Integer sPGCustomerDedupeFlag = 1; //1 By Default
        String sDedupeJourneyStatusReason;
        String sDedupeJourneyStatus;
        String sExternalDedupeStatus = '';
        String sDedupeCalloutStatus = '';
        set<string> sDealStatusFlagSet=new Set<string>{};
        set<string> sCustomerStatusFlagSet=new Set<string>{};
        set<string> sNPATypeSet=new Set<string>{};
        String sSelectedCustCode = '';
        
        Customer_Dedup_Response_Parser parsedResponse = null;

        sPostSanctionStageSet.addAll(Customer_Dedupe_Flags__mdt.getInstance('Post_Sanction_Stages').Flag_Values__c.split(','));
        
        if(String.isNotBlank(custDedupeResponse)){
            parsedResponse= Customer_Dedup_Response_Parser.parse(custDedupeResponse);
        
            //Callout Status Check
            if(parsedResponse?.response?.status != null){
                sDedupeCalloutStatus = parsedResponse?.response?.status;
            }

            if(sDedupeCalloutStatus == 'SUCCESS'){
                //External API Status Check
                if(parsedResponse?.response?.content[0]?.Data?.ExternalDedupeResponse?.DEDUPE_STATUS != null){
                    sExternalDedupeStatus = parsedResponse?.response?.content[0]?.Data?.ExternalDedupeResponse?.DEDUPE_STATUS;
                }

                //External API Recent Lead Empty check
                if(parsedResponse?.response?.content[0]?.Data?.ExternalDedupeResponse?.DtRECENTLEAD != null){
                    externalDedupeRecentLeadExists = true;
                }

                //External API Customer Validate Empty check
                if(parsedResponse?.response?.content[0]?.Data?.ExternalDedupeResponse?.CustomerValidate != null){
                    externalDedupeCustCodeExists = true;
                }
                
                //Internal API Null Check - Customer Validate is null
                if(parsedResponse?.response?.content[0]?.Data?.InternalDedupeResponse[0]?.CustomerValidate[0].CustomerCodeVal != null){
                    internalDedupeCustCodeExists = true;
                }
                if(parsedResponse?.response?.content[0]?.Data?.Customer_Enquire_Dt != null && parsedResponse?.response?.content[0]?.Data?.Customer_Enquire_Dt?.cifId != null ){
                    finnacleDedupeExists = true;
                }
            }        
            
        } else {
            //Callout Error: Null Response
            sDedupeJourneyStatus = 'Skipped';
            sDedupeJourneyStatusReason = 'Dedupe Callout Error, Journey was proceeded as new customer';
        }

        if(sDedupeJourneyStatus != 'Skipped'){

            //Internal Dedupe Non-Customer Code Check - SF Check
            if(sDedupeJourneyStatus != 'Stopped' && externalDedupeRecentLeadExists == true){
                //Get set of Matched CIC No
                for(Customer_Dedup_Response_Parser.cls_DtRECENTLEAD cust : parsedResponse?.response?.content[0]?.Data?.ExternalDedupeResponse?.DtRECENTLEAD){
                    cicNoSet.add(cust.MATCHED_CIC_NO);
                }

                //Check for CIC NO. Match in SF
                List<Customer_Dedupe_Response__c> custDedupeResList = [select id , CIC_No__c, Applicant__r.Opportunity__r.StageName from Customer_Dedupe_Response__c where CIC_No__c in :cicNoSet WITH SECURITY_ENFORCED];
                
                //Validate Matching Lead in SF
                if(!custDedupeResList.isEmpty()){
                    for(Customer_Dedupe_Response__c deupeResponse : custDedupeResList){
                        //If matching record is not in any of the Post Sanction Stage - Journey Stop
                        if(!sPostSanctionStageSet.contains(deupeResponse.Applicant__r.Opportunity__r.StageName)){
                            sSFCustomerDedupeFlag = 0;
                            sDedupeJourneyStatus = 'Stopped';
                            sDedupeJourneyStatusReason = 'This is an existing lead. Please ask the customer to withdraw or continue with the earlier application';
                            break;
                        }
                    }
                }
            }
        }

        if(sDedupeJourneyStatus != 'Skipped' && sDedupeJourneyStatus != 'Stopped' && internalDedupeCustCodeExists == false  && externalDedupeCustCodeExists == false && externalDedupeRecentLeadExists == false) {
            //No Dedupe found Case
            sDedupeJourneyStatus = 'Continued';
            sDedupeJourneyStatusReason = 'No Dedupe Found, Journey was proceeded as new customer';
        } 
                    
        sDealStatusFlagSet.addAll(Customer_Dedupe_Flags__mdt.getInstance('DealStatusFlag').Flag_Values__c.split(','));
        sCustomerStatusFlagSet.addAll(Customer_Dedupe_Flags__mdt.getInstance('CustomerStatusFlag').Flag_Values__c.split(','));
        sNPATypeSet.addAll(Customer_Dedupe_Flags__mdt.getInstance('NPAType').Flag_Values__c.split(','));

        //Create Dedupe Response Object
        Customer_Dedupe_Response__c custDedupeObj = new Customer_Dedupe_Response__c(SF_Cust_Dedupe__c=sSFCustomerDedupeFlag, PG_Cust_Dedupe__c= sPGCustomerDedupeFlag, /*CIC_No__c = cicNo,*/ External_Dedupe_Status__c = sExternalDedupeStatus, Dedupe_Journey_Status__c = sDedupeJourneyStatus, Dedupe_Journey_Status_Reason__c = sDedupeJourneyStatusReason, Response__c = custDedupeResponse);
        
        Set<String> custCodeSet = new Set<String>();
        List<Customer_Dedup_Response_Parser.cls_CustomerValidate[]> dedupeValidateDataList = new List<Customer_Dedup_Response_Parser.cls_CustomerValidate[]>();

        if(parsedResponse?.response?.content[0]?.Data?.ExternalDedupeResponse != null && parsedResponse?.response?.content[0]?.Data?.ExternalDedupeResponse?.DEDUPE_STATUS == 'M'){
            dedupeValidateDataList.add(parsedResponse?.response?.content[0]?.Data?.ExternalDedupeResponse?.CustomerValidate);
        }
        if(parsedResponse?.response?.content[0]?.Data?.InternalDedupeResponse != null){
            dedupeValidateDataList.add(parsedResponse?.response?.content[0]?.Data?.InternalDedupeResponse[0]?.CustomerValidate);
        }

        for(Customer_Dedup_Response_Parser.cls_CustomerValidate[] validateData: dedupeValidateDataList){
            for (Integer i = 0; i<validateData.size(); i++) {

                //Skip if Customer Code already processed
                //populate the custcodeset
                if(custCodeSet.contains(validateData[i].CustomerCodeVal)){
                    continue;
                } else {
                    custCodeSet.add(validateData[i].CustomerCodeVal);
                }

                sSelectedCustCode = validateData[i].CustomerCodeVal;

                //DealStatus
                if(!validateData[i]?.Dealstatus.isEmpty()){
                    for(Customer_Dedup_Response_Parser.cls_Dealstatus status: validateData[i]?.Dealstatus){
                        custDedupeObj.Deal_Status_Flag__c = status.Status_Flag;
                        
                        if(sDealStatusFlagSet.contains(status.Status_Flag)){
                            opp.Journey_Status__c = System.Label.Journey_Status_Stop;
                            sDedupeJourneyStatusReason = 'Customer code tagged as '+ status.Status_Flag + ' flag. Hence cannot proceed.';
                            break;
                        }
                    }
                    if(sDedupeJourneyStatusReason != null){
                        break;
                    }
                }

                //CustomerStatus
                if(!validateData[i]?.CustomerStatus.isEmpty()){
                    for(Customer_Dedup_Response_Parser.cls_CustomerStatus status: validateData[i]?.CustomerStatus){
                        custDedupeObj.Customer_Status_Flag__c = status.Active_Flag;

                        if(sCustomerStatusFlagSet.contains(status.Active_Flag)){
                            opp.Journey_Status__c = System.Label.Journey_Status_Stop;
                            sDedupeJourneyStatusReason = 'Customer code tagged as '+ status.Active_Flag + ' flag. Hence cannot proceed.';
                            break;
                        }
                    }
                    if(sDedupeJourneyStatusReason != null){
                        break;
                    }
                }
                
                //NPA
                if(!validateData[i]?.NPA.isEmpty()){
                   /* for(Customer_Dedup_Response_Parser.cls_NPA status: validateData[i]?.NPA){

                        if(sNPATypeSet.contains(status.NPATYPE)){
                            opp.Journey_Status__c = System.Label.Journey_Status_Stop;
                            sDedupeJourneyStatusReason = 'Customer code tagged as NPA. Hence cannot proceed.';
                            break;
                        }
                    }
                    */
                    opp.Journey_Status__c = System.Label.Journey_Status_Stop;
                    sDedupeJourneyStatusReason = 'Customer code tagged as NPA. Hence cannot proceed.';
                    //if(sDedupeJourneyStatusReason != null){
                        break;
                    //}
                }
                
                //Restructure
                if(!validateData[i]?.Restructure.isEmpty()){
                    for(Customer_Dedup_Response_Parser.cls_Restructure status: validateData[i]?.Restructure){

                        if(status.Deal_Restructured == 'Yes'){
                            opp.Journey_Status__c = System.Label.Journey_Status_Stop;
                            sDedupeJourneyStatusReason = 'Customer code under deal no has availed Restructure(com). Hence cannot proceed.';
                            break;
                        }
                    }
                    if(sDedupeJourneyStatusReason != null){
                        break;
                    }
                }
                
                //PanAlert
                if(!validateData[i]?.PanAlert.isEmpty()){
                    system.debug('Pan Details Exists');
                    for(Customer_Dedup_Response_Parser.cls_PanAlert status: validateData[i]?.PanAlert){
                        opp.Journey_Status__c = System.Label.Journey_Status_Stop;
                        sDedupeJourneyStatusReason = 'This customer/ entity is listed by FIU under '+status.Listing+' '+status.Remarks+' dated '+status.Source_Report_Date;
                        break;
                    }
                    if(sDedupeJourneyStatusReason != null){
                        break;
                    }
                }
                
                //CINAlert
                if(!validateData[i]?.CINAlert.isEmpty()){
                    for(Customer_Dedup_Response_Parser.cls_CINAlert status: validateData[i]?.CINAlert){
                        opp.Journey_Status__c = System.Label.Journey_Status_Stop;
                        sDedupeJourneyStatusReason = 'This customer/ entity is listed by FIU under '+status.Listing+' '+status.Remarks+' dated '+status.Source_Report_Date;
                        break;
                    }
                    if(sDedupeJourneyStatusReason != null){
                        break;
                    }
                }

                //ARC
                if(!validateData[i]?.ARC.isEmpty()){
                    for(Customer_Dedup_Response_Parser.cls_ARC arc: validateData[i]?.ARC){
                        opp.Journey_Status__c = System.Label.Journey_Status_Stop;
                        sDedupeJourneyStatusReason = 'Customer has contract sold to ARC.';
                        break;
                    }
                    if(sDedupeJourneyStatusReason != null){
                        break;
                    }
                }

                //Gecl
                if(!validateData[i]?.Gecl.isEmpty()){
                    for(Customer_Dedup_Response_Parser.cls_Gecl gecl: validateData[i]?.Gecl){
                        opp.Journey_Status__c = System.Label.Journey_Status_Stop;
                        sDedupeJourneyStatusReason = 'Customer code under deal no has availed GECL. Hence cannot proceed.';
                        break;
                    }
                    if(sDedupeJourneyStatusReason != null){
                        break;
                    }
                }

                //BeneficiaryAlert
                if(validateData[i]?.BeneficiaryAlert.PAN_No != null){
                    Customer_Dedup_Response_Parser.cls_BeneficiaryAlert bAlert = validateData[i]?.BeneficiaryAlert;
                    opp.Journey_Status__c = System.Label.Journey_Status_Stop; 
                    sDedupeJourneyStatusReason = 'Customer is part of beneficiary list. Hence cannot proceed.';

                    if(sDedupeJourneyStatusReason != null){
                        break;
                    }
                }
            }
            if(sDedupeJourneyStatusReason != null){
                break;
            }                
        }
        
        if(sDedupeJourneyStatusReason == null || finnacleDedupeExists){
            custDedupeObj.Customer_Code__c = sSelectedCustCode;
            custDedupeObj.Dedupe_Journey_Status__c = 'Continued';
            custDedupeObj.Dedupe_Journey_Status_Reason__c = 'Selected customer is identified as valid';
            app.Customer_Code__c = sSelectedCustCode;
        } else {
            custDedupeObj.Invalid_Customer_Code__c = sSelectedCustCode;
            custDedupeObj.Dedupe_Journey_Status__c = 'Stopped';
            custDedupeObj.Dedupe_Journey_Status_Reason__c = sDedupeJourneyStatusReason;
            app.Invalid_Customer_Code__c = sSelectedCustCode;
        }
        Data dataWrapper = new Data();
        dataWrapper.opp = opp;
        dataWrapper.app = app;
        dataWrapper.custDedupeObj = custDedupeObj;

        return dataWrapper;
    }
    
    /*
    * Name: LoanApplication
    * @Created by:  Raman Raj Saxena
    * @Description: Wrapper class to store data sync API request screen 1.
    */
    public class DedupeData{
        public String LoanApplicationId;
        public String ApplicantId;
        public String DedupeResponse;
        public String CustomerCode;
        public String CIFId;
        public Boolean IsETB;

        public String cic_number;
        public String FirstName;
        public String LastName;
        public Id documentId;
    }

    public class DedupeToProcessWrapper {
        public Opportunity opp;
        public Applicant__c applicant;
        public Customer_Dedupe_Response__c dedupe;
        public String response;
    }

    /*
    * Name: ResponseWrapper
    * @Created by:  Raman Raj Saxena
    * @Description: Wrapper class to send the API response.
    */
    public class ResponseWrapper{
        public String result;
    }
     /*
    * Name: Data
    * @Created by:  Raman Raj Saxena
    * @Description: Wrapper class to store data for opportunity, applicant, cutomer dedupe response.
    */
    public class Data{
        public Opportunity opp;
        public Applicant__c app;
        public Customer_Dedupe_Response__c custDedupeObj;
    }

}