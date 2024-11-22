/**
* @Name         LoanApplicationDataManager
* @Author       Prashanth Kumar
* @Company      Salesforce
* @Description  This is a web service class to create the Loan Application record and expose the Lead number that generated.
* Inputs:       None
* Test Class:   LoanApplicationDataManagerTest
*/
@RestResource(urlMapping='/createLoanApplication/*')
global with sharing class LoanApplicationDataManager {
    /*
    * @Method:      createLoanApplication
    * @Created by:  Prashanth Kumar
    * @Description: Method to return Response which contains Loan ApplicationId, Applicant Id, Lean number and DocumentId.
    * @Param:       None
    * @Return:     String - response
    */
    @HttpPost
    global static void createLoanApplication() {
        try {
            System_Configuration__c seqNumber = System_Configuration__c.getValues('System Configuration');
            
            if(seqNumber?.Valid_Lead_Number_Date__c != null && seqNumber?.Valid_Lead_Number_Date__c != Date.Today()) {
                throw new CalloutException(System.Label.An_Error_Occurred_Please_try_again_later);
            }
            
            List<Documents__c> lstDocuments = new List<Documents__c>();
            List<Opportunity> lstOpportunity = new List<Opportunity>();
            
            //Request
            RestRequest req  = RestContext.request;
            //encrypted request
            String stringEncryptedRequest=req.requestBody.toString();
            system.debug('stringEncryptedRequest: '+stringEncryptedRequest);
            
            //decrypt the encrypted request
            String loanApplicationResponseString = IntegrationUtilities.getPlainTextForLog(stringEncryptedRequest);
            //String loanApplicationResponseString = req.requestBody.toString();
            String encryptedResponse = '';
            String decryptedResponse = '';
            LoanApplication jsonParsed =(LoanApplication) JSON.deserialize(loanApplicationResponseString,LoanApplication.class);
            system.debug('jsonParsed: '+jsonParsed);
            
            
            //Respose
            Response response = new Response();
            AggregatorResponse agrResponse = new AggregatorResponse();

            //Create Loan Application
            Opportunity opp = createOpportunity(jsonParsed);

            //create Applicant
            Applicant__c objApplicant = createApplicant(jsonParsed);
            
            //BE assignment for Pre-Approved journey
            if(String.isNotBlank(jsonParsed.BEId)){
                beAssignment(jsonParsed.BEId, opp);
            }

            //BE assignment for Aggregator journey
            if(jsonParsed.LeadSource != 'D2C' && jsonParsed.pincode != null){
                String beMappingResponse = BEUserMappingInformation.getBEInformation(String.valueOf(jsonParsed.pincode), jsonParsed.ProductType,null,false,jsonParsed.VehicleType);
                BEUserMappingInformation.Response beResponse = (BEUserMappingInformation.Response)JSON.deserialize(beMappingResponse, BEUserMappingInformation.Response.class);
                system.debug('beResponse-->'+beResponse);
                agrResponse.BEName = beResponse.beName;
                agrResponse.BEContactNumber = beResponse.contactNumber;
                agrResponse.BEId = beResponse.beId;
                agrResponse.beSFDCId = beResponse.beSFDCId;
                agrResponse.blCode = beResponse.blCode;
                agrResponse.accountId = beResponse.accountId;
                
                if(beResponse.beSFDCId != null){
                    opp.OwnerId = Id.valueOf(beResponse.beSFDCId);
                    opp.Agent_BL_code__c = beResponse.blCode;
                    opp.AccountId = beResponse.accountId;
                }

            }

            //insert opportunity
            if(Schema.sObjectType.Opportunity.isCreateable()){
            	insert opp;
                system.debug('opp : '+opp);
                Set<Id> oppIdSet = new Set<Id>{opp.Id};
                //populate Lead Number
                UniqueLeadNumberHandler.updateLeadSeqNumber(oppIdSet);
                //populate Application Number
                UniqueLeadNumberHandler.updateApplicationSeqNumber(opp.Id);
                lstOpportunity = [Select Id,Lead_number__c,Application_number__c from Opportunity where Id in: oppIdSet];
            }

            //insert applicant
            if(Schema.sObjectType.Applicant__c.isCreateable()){
                objApplicant.Opportunity__c = opp.Id;
                insert objApplicant;
                system.debug('objApplicant : '+objApplicant);
            }

            //* Moved to new API
            //insert customer dedupe response
            // if(Schema.sObjectType.Customer_Dedupe_Response__c.isCreateable()){
            //     custDedupeObj.Applicant__c = objApplicant.Id;
            //     insert custDedupeObj;
            //     system.debug('custDedupeObj : '+custDedupeObj);
            // }

            //insert PAN document
            createDocuments(jsonParsed, lstOpportunity[0].Id, objApplicant.Id, 'PAN');
            //insert Aadhaar document
            Documents__c aadhaarDoc= createDocuments(jsonParsed, lstOpportunity[0].Id, objApplicant.Id, 'Aadhaar');

            //create other records
            if(!lstOpportunity.isEmpty() && objApplicant.Id != null){
                if(jsonParsed.LeadSource != 'D2C'){
                    Income_Details__c incomeDetails = createIncomeDetails(objApplicant.Id, jsonParsed);
                    Existing_EMI__c existingEMI = createExistingEMI(objApplicant.Id, jsonParsed);
                    Vehicle_Detail__c vehicleDetails = createVehicleDetails(lstOpportunity[0].Id, jsonParsed, agrResponse.BEName, agrResponse.BEContactNumber);
                    Final_Term__c finalTerm = createFinalTerm(lstOpportunity[0].Id, jsonParsed);

                    agrResponse.LeadNumber = lstOpportunity[0].Lead_number__c;
                    agrResponse.ApplicantId = String.valueOf(objApplicant.Id).substring(0,15);
                    agrResponse.LoanApplicationId = opp.Id;
                    agrResponse.DocumentId = aadhaarDoc.Id != null ? aadhaarDoc.Id : null;
                    agrResponse.IncomeDetailsId = incomeDetails.Id != null ? incomeDetails.Id : null;
                    agrResponse.ExistingEMIId = existingEMI.Id != null ? existingEMI.Id : null;
                    agrResponse.VehicleDetailsId = vehicleDetails.Id != null ? vehicleDetails.Id : null;
                    agrResponse.FinalTermId = finalTerm.Id != null ? finalTerm.Id : null;
                    agrResponse.ApplicationNumber = lstOpportunity[0].Application_number__c;
                    decryptedResponse = JSON.serialize(agrResponse);
                }else{
                    
                    response.LeadNumber = lstOpportunity[0].Lead_number__c;
                    response.ApplicantId = String.valueOf(objApplicant.Id).substring(0,15);
                    response.LoanApplicationId = opp.Id;
                    response.DocumentId = aadhaarDoc.Id != null ? aadhaarDoc.Id : null;
                    response.ApplicationNumber = lstOpportunity[0].Application_number__c;
                    decryptedResponse = JSON.serialize(response);
                }
            }
            system.debug('decryptedResponse: '+decryptedResponse);
            //encrypting the response
            encryptedResponse = IntegrationUtilities.getEncryptedRequest(decryptedResponse,System.Label.privateKey,System.Label.ivkey); 
            //setting the response body
            String jdataRequest1 = '"JData":';                    
            String body1='{'+jdataRequest1 + '"'+encryptedResponse+'"'+'}';
            RestContext.response.responseBody = Blob.valueOf(body1);
            //RestContext.response.responseBody = Blob.valueOf(decryptedResponse);
            RestContext.response.addHeader('Content-Type', 'application/json');

            //create Integration Log
            IntegrationUtilities.createIntegrationLogger(loanApplicationResponseString, stringEncryptedRequest, decryptedResponse, encryptedResponse, 'createLoanApplication', null,opp.Id);
        } catch (Exception e) {
           ErrorLoggerUtil.logErrorEvent('LoanApplicationDataManager', 'createLoanApplication', 'Apex', e);
           RestContext.response.statusCode = 500;
           String encryptedResponse = IntegrationUtilities.getEncryptedRequest(e.getMessage(),System.Label.privateKey,System.Label.ivkey); 
           //setting the error response body
           String jdataRequest1 = '"JData":';                    
           String body1='{'+jdataRequest1 + '"'+encryptedResponse+'"'+'}';
           RestContext.response.responseBody = Blob.valueOf(body1);
             
            //throw new CalloutException(e.getMessage() + e.getStackTraceString());
        }
    }
    /*
    * @Method:      beAssignment
    * @Created by:  Prashanth Kumar
    * @Description: Method to return opportunity.
    * @Param:       beId, opp
    * @Return:     Opportunity
    */
    private static Opportunity beAssignment(String beId, Opportunity opp){
        try{
            String employeeId = beId+'%';
            User user = [select Id from User where username like: employeeId and IsActive = true limit 1];
            opp.OwnerId = user.Id != null ? user.Id : UserInfo.getUserId();
            if(user != null){
                List<AccountTeamMember> teamMember = [Select Account.BranchBLCode__c,AccountId from AccountTeamMember where UserId=: user.Id Limit 1];
                if(teamMember.isEmpty()){
                    throw new CalloutException('No BE User found in system with provided BE Id.');
                }
                opp.Agent_BL_code__c = !teamMember.isEmpty() ? teamMember[0].Account.BranchBLCode__c : null;
                opp.AccountId = !teamMember.isEmpty() ? teamMember[0].AccountId : null;
                
            }
            
            system.debug('BeAssignedOpp : '+ opp);
            return opp;
		} catch (Exception e) {
           ErrorLoggerUtil.logErrorEvent('LoanApplicationDataManager', 'createLoanApplication', 'Apex', e);
           throw new CalloutException('No BE User found in system with provided BE Id.');
        }
    }
     /*
    * @Method:      createOpportunity
    * @Created by:  Prashanth Kumar
    * @Description: Method to return opportunity.
    * @Param:       jsonParsed
    * @Return:     Opportunity
    */
    private static Opportunity createOpportunity(LoanApplication jsonParsed){
        //temName to be used to replace it with Lead Number as Name in trigger-generateUniqueLeadNumber
        String tempName = 'TempName';
        Opportunity opp = new Opportunity(Name= tempName,StageName = 'Loan Initiation',CloseDate = System.today().addMonths(1));
        opp.Sub_Stage__c = 'User Details';
        opp.LastStageName__c = 'Loan Initiation';
        opp.Contact_number__c = String.isNotblank(jsonParsed.MobileNumber) ? jsonParsed.MobileNumber : null;
        opp.Applicant_Name__c = String.isNotblank(jsonParsed.FirstName) && String.isNotblank(jsonParsed.LastName) ? (jsonParsed.FirstName+' '+jsonParsed.LastName) : null;
        opp.Product_Type__c = String.isNotblank(jsonParsed.ProductType) ? jsonParsed.ProductType : null;
        opp.Vehicle_Type__c = String.isNotblank(jsonParsed.VehicleType) ? jsonParsed.VehicleType : null;
        opp.D2C_UTM_Campaign__c = String.isNotblank(jsonParsed.UtmCampaign) ? jsonParsed.UtmCampaign : null;//CISP-7211
        opp.D2C_UTM_Content__c =  String.isNotblank(jsonParsed.UtmContent) ? jsonParsed.UtmContent : null;//CISP-7211
        opp.D2C_UTM_Medium__c =  String.isNotblank(jsonParsed.UtmMedium) ? jsonParsed.UtmMedium : null;//CISP-7211
        opp.D2C_UTM_Source__c =  String.isNotblank(jsonParsed.UtmSource) ? jsonParsed.UtmSource : null;//CISP-7211
        opp.D2C_UTM_Term__c =  String.isNotblank(jsonParsed.UtmTerm) ? jsonParsed.UtmTerm : null;//CISP-7211
        opp.Sanction_Status__c = '';

        if(jsonParsed.LeadSource != 'D2C' && String.isNotBlank(jsonParsed.LeadSource)){
            opp.Aggregator_Source__c = jsonParsed.LeadSource;
            opp.aggregatorReferenceId__c = jsonParsed.aggregatorReferenceId;
        }
        //Pre approved Journey
        if(String.isNotBlank(jsonParsed.BEId)) {
            opp.Is_Pre_Approved__c = true;
        }
        opp.LeadSource = 'D2C';
        opp.Required_Loan_amount__c = String.isNotBlank(jsonParsed.requestedLoanAmount) ? Decimal.valueOf(jsonParsed.requestedLoanAmount) : null;
        opp.Loan_amount__c = String.isNotBlank(jsonParsed.loanAmount) ? jsonParsed.loanAmount: null;
        opp.Required_ROI__c = String.isNotBlank(jsonParsed.interestRate) ? Decimal.valueOf(jsonParsed.interestRate) : null;
        return opp;
    }
     /*
    * @Method:      createApplicant
    * @Created by:  Prashanth Kumar
    * @Description: Method to return Applicant.
    * @Param:       jsonParsed
    * @Return:     Applicant__c
    */
    private static Applicant__c createApplicant(LoanApplication jsonParsed){
        Applicant__c objApplicant = new Applicant__c();
        objApplicant.Customer_First_Name__c = String.isNotblank(jsonParsed.FirstName)  ? jsonParsed.FirstName : '';
        objApplicant.Customer_Last_Name__c = String.isNotblank(jsonParsed.LastName)  ? jsonParsed.LastName : '';
        objApplicant.Name = objApplicant.Customer_First_Name__c+' '+objApplicant.Customer_Last_Name__c;
        if(objApplicant.Name.length() > 80){
            objApplicant.Name = objApplicant.Name.substring(0, 80);
        }
        objApplicant.Contact_number__c = String.isNotblank(jsonParsed.MobileNumber) ? jsonParsed.MobileNumber : null;
        objApplicant.Email_Id__c = String.isNotblank(jsonParsed.EmailID) ? jsonParsed.EmailID : null;
        objApplicant.PAN_No__c = String.isNotblank(jsonParsed.PANNumber) ? jsonParsed.PANNumber : null;
        objApplicant.Consent_Received__c = true;
        objApplicant.Applicant_Type__c = 'Borrower';
        objApplicant.Is_Email_Valid__c = String.isNotBlank(jsonParsed.EmailIdStatus) && jsonParsed.EmailIdStatus == 'valid' ? TRUE : FALSE;
        objApplicant.Is_Blacklisted_Email_Address__c = String.isNotBlank(jsonParsed.EmailIdStatus) && jsonParsed.EmailIdStatus == 'unverifiable' ? TRUE : FALSE;
        objApplicant.Aadhar_No__c = String.isNotblank(jsonParsed.aadharNumber) ? jsonParsed.aadharNumber : null;
        objApplicant.Gender__c = String.isNotblank(jsonParsed.gender) ? jsonParsed.gender : null;
        objApplicant.Declared_income__c = String.isNotblank(jsonParsed.annualIncome) ? Decimal.valueOf(jsonParsed.annualIncome) : null;
        objApplicant.Journey_Stage__c = 'User Details';
        objApplicant.Residence_country__c = 'India';
        objApplicant.Who_will_repay_the_loan__c = 'Borrower';
        return objApplicant;
    }
    

     /*
    * @Method:      createDocuments
    * @Created by:  Prashanth Kumar
    * @Description: Method to return document.
    * @Param:       jsonParsed, oppId, applicantId, documentType
    * @Return:     Document__c
    */
    private static Documents__c createDocuments(LoanApplication jsonParsed, Id oppId, Id applicantId, String documentType){
        //RecordType Id of the Documents object.
        Id recordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
        Documents__c objDocument = new Documents__c();
        objDocument.Opportunity_Relation__c = oppId;
        objDocument.Applicant__c = applicantId;
        // objDocument.Document_Type__c = documentType;
        objDocument.Salutation__c = String.isNotblank(jsonParsed.Salutation) ? jsonParsed.Salutation : null;
        objDocument.is_Active__c = TRUE;
        objDocument.Name = documentType;
        objDocument.recordTypeId = recordTypeId;
        objDocument.KYC_DOB__C = string.isNotblank(jsonParsed.dateOfBirth) ? Date.valueOf(jsonParsed.dateOfBirth) : null;
        objDocument.Gender__c = String.isNotblank(jsonParsed.gender) ? jsonParsed.gender : null;
        if(documentType == 'PAN'){
            objDocument.Document_Type__c = System.Label.PanCards;
            objDocument.KYC_name__c = String.isNotBlank(jsonParsed.KYCNameAsPerPAN) ? jsonParsed.KYCNameAsPerPAN : null;
            objDocument.PAN_No__c = String.isNotblank(jsonParsed.PANNumber) ? jsonParsed.PANNumber : null;
            objDocument.First_Name__c = String.isNotBlank(jsonParsed.FirstName) ? jsonParsed.FirstName+' ': '';
            objDocument.Last_Name__c = String.isNotBlank(jsonParsed.LastName) ? jsonParsed.LastName : ''; 
        }
        if(documentType == 'Aadhaar'){
            objDocument.Document_Type__c = System.Label.AadhaarCard;
            objDocument.KYC_name__c = String.isNotBlank(jsonParsed.FirstName) ? jsonParsed.FirstName+' ': '';
            objDocument.KYC_name__c += String.isNotBlank(jsonParsed.LastName) ? jsonParsed.LastName : ''; 
            if(objDocument.KYC_name__c.length() > 100){
                objDocument.KYC_name__c = objDocument.KYC_name__c.substring(0, 100);
            }
            objDocument.KYC_No__c = objDocument.Masked_KYC_No__c = String.isNotblank(jsonParsed.aadharNumber) ? jsonParsed.aadharNumber : null;
            objDocument.Proof_of_Address_POA__c = TRUE;
            objDocument.Proof_of_Identity_POI__c = TRUE;
            objDocument.Pre_Initial_Address__c = true;

        }
        
        if(Schema.sObjectType.Documents__c.isCreateable()){
            insert objDocument;
        }
        system.debug('objDocument : '+objDocument);
        return objDocument;
    }


     /*
    * @Method:      createIncomeDetails
    * @Created by:  Prashanth Kumar
    * @Description: Method to create Income_Details__c.
    * @Param:       applicantId, jsonParsed
    * @Return:     Income_Details__c
    */
    private static Income_Details__c createIncomeDetails(Id applicantId, LoanApplication jsonParsed){
        Income_Details__c incomeDetails = new Income_Details__c();
        incomeDetails.Applicant__c = applicantId;
        incomeDetails.Income__c = String.isNotBlank(jsonParsed.annualIncome) ? Decimal.valueOf(jsonParsed.annualIncome) : null;
        if(Schema.sObjectType.Income_Details__c.isCreateable()){
            insert incomeDetails;
        }
        system.debug('incomeDetails : '+incomeDetails);
        return incomeDetails;
    }
    /*
    * @Method:      createExistingEMI
    * @Created by:  Prashanth Kumar
    * @Description: Method to create Existing_EMI__c.
    * @Return:     Existing_EMI__c
    */
    private static Existing_EMI__c createExistingEMI(Id applicantId, LoanApplication jsonParsed){
        Existing_EMI__c existingEMI = new Existing_EMI__c();
        existingEMI.Applicant_Id__c = applicantId;
        existingEMI.EMI__C = String.isNotBlank(jsonParsed.existingEMI) ? Decimal.valueOf(jsonParsed.existingEMI): null;
        if(Schema.sObjectType.Existing_EMI__c.isCreateable()){
            insert existingEMI;
        }
        system.debug('existingEMI : '+existingEMI);
        return existingEMI;
    }
    /*
    * @Method:      createVehicleDetails
    * @Created by:  Prashanth Kumar
    * @Description: Method to return Vehicle_Detail__c.
    * @Return:     Vehicle_Detail__c
    */
    private static Vehicle_Detail__c createVehicleDetails(Id opportunityId, LoanApplication jsonParsed, String executiveName, String executiveContact){
        Vehicle_Detail__c vehicleDetails = new Vehicle_Detail__c();
        vehicleDetails.Loan_Application__c = opportunityId;
        vehicleDetails.Model__c = String.isNotBlank(jsonParsed.vehicleModel) ? jsonParsed.vehicleModel : null;
        vehicleDetails.Selling_Price__c = String.isNotBlank(jsonParsed.sellingPrice) ? Decimal.valueOf(jsonParsed.sellingPrice) : null;
        if(String.isNotBlank(executiveName)){
            vehicleDetails.Executive_name__c = executiveName;
        }
        if(String.isNotBlank(executiveContact)){
            vehicleDetails.Executive_Contact_Number__c = executiveContact;
        }
        if(Schema.sObjectType.Vehicle_Detail__c.isCreateable()){
            insert vehicleDetails;
        }
        system.debug('vehicleDetails : '+vehicleDetails);
        return vehicleDetails;
    }
    /*
    * @Method:      createFinalTerm
    * @Created by:  Prashanth Kumar
    * @Description: Method to return Final_Term__c.
    * @Return:     Final_Term__c
    */
    private static Final_Term__c createFinalTerm(Id opportunityId, LoanApplication jsonParsed){
        Final_Term__c finalTerm = new Final_Term__c();
        finalTerm.Loan_Application__c = opportunityId;
        finalTerm.Loan_amount__c = String.isNotBlank(jsonParsed.loanAmount) ? jsonParsed.loanAmount : null;
        finalTerm.Tenure__c = String.isNotBlank(jsonParsed.loanTenureOffered) ? jsonParsed.loanTenureOffered : null;
        finalTerm.EMI_Amount__c = String.isNotBlank(jsonParsed.emiPerMonth) ? Decimal.valueOf(jsonParsed.emiPerMonth) : null;
        if(Schema.sObjectType.Final_Term__c.isCreateable()){
            insert finalTerm;
        }
        system.debug('finalTerm : '+ finalTerm);
        return finalTerm;
    }
     /*
    * Name: LoanApplication
    * @Created by:  Prashanth Kumar
    * @Description: Wrapper class to store data sync API request screen 1.
    */
    public class LoanApplication{
        public String FirstName;
        public String LastName;
        public String Salutation;
        public String MobileNumber;
        public String PANNumber;
        public String EmailID;
        public String VehicleType;
        public String LeadSource;
        public String dateOfBirth;
        public String ProductType;
        public String EmailIdStatus;
        public String KYCNameAsPerPAN;
        public String DedupeResponse;
        public String BEId;
        public String BEBranchCode;
        public String aadharNumber;
        public String gender;
        public String employmentType;//this is occupational type (or) profile ?
        public String annualIncome;
        public String existingEMI;
        public String pincode;
        public String requestedLoanAmount;
        public String requestedLoanTenureinMonths;
        public String buyingFrom;
        public String interestRate;
        public String emiPerMonth;
        public String loanAmount;
        public String loanTenureOffered;
        public String vehicleModel;//what about make && variant of the vehicle?
        public String sellingPrice;
        public String aggregatorReferenceId;
        public String UtmSource;//CISP-7211
        public String UtmMedium;//CISP-7211
        public String UtmCampaign;//CISP-7211
        public String UtmTerm;//CISP-7211
        public String UtmContent;//CISP-7211
    }
     /*
    * Name: Response
    * @Created by:  Prashanth Kumar
    * @Description: Wrapper class to store the response of data sync API screen 1.
    */
    public class Response{
        public String LeadNumber;
        public String ApplicantId;
        public String LoanApplicationId;
        public String DocumentId;
        public String ApplicationNumber;
    }
    /*
    * Name: AggregatorResponse
    * @Created by:  Prashanth Kumar
    * @Description: Wrapper class to store the response of data sync API screen 1 for aggregator.
    */
    public class AggregatorResponse{
        public String LeadNumber;
        public String ApplicantId;
        public String LoanApplicationId;
        public String DocumentId;
        public String IncomeDetailsId;
        public String ExistingEmiId;
        public String VehicleDetailsId;
        public String FinalTermId;
        public String BEId;
        public String BEName;
        public String BEContactNumber;       
        public String beSFDCId;
        public String blCode;
        public String accountId;
        public String ApplicationNumber;
    }
     /*
    * Name: Data
    * @Created by:  Prashanth Kumar
    * @Description: Wrapper class to store data for opportunity, applicant, cutomer dedupe response.
    */
    public class Data{
        public Opportunity opp;
        public Applicant__c app;
        public Customer_Dedupe_Response__c custDedupeObj;
    }

}