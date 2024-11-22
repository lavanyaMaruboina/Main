@RestResource(urlMapping='/CaptureAadharInformation/*')
/**
 * Class: CaptureAadhaarInformation
 * Description: Class to capture Aadhar information.
 * Test class: 
 */
global with sharing class CaptureAadharInformation {
    /**
     * Method: getAadhaarDocument
     * Description: Method to create Aadhar related information.
     * return void;
     */
    @HttpPost
    global static void getAadharDocument() {
        //Request
        RestRequest req  = RestContext.request;
        //String stringRequest=req.requestBody.toString();
       // system.debug('stringRequest-->'+stringRequest);
       Opportunity objOpp;
        String stringEncryptedRequest=req.requestBody.toString();
        String stringRequest = IntegrationUtilities.getPlainTextForLog(stringEncryptedRequest);
        AadharRequest request = (AadharRequest) JSON.deserialize(stringRequest, AadharRequest.class);
        Boolean isReKYC = false;
        //update applicant
        system.debug('request.loanApplicationId-->'+request.loanApplicationId);
        if(String.isNotBlank(request.loanApplicationId)){
            objOpp = [SELECT Is_ETB__c, RE_KYC_Stage__c, IO_Loan_Amount__c FROM Opportunity WHERE id=: request.loanApplicationId];
            if(objOpp.Is_ETB__c == true && request.aadharOTPorBiometric != null && request.aadharOTPorBiometric == true){
                if(String.isNotBlank(objOpp.IO_Loan_Amount__c)){
                	objOpp.RE_KYC_Stage__c = 'PostInitialOffer';    
                }else{
                    objOpp.RE_KYC_Stage__c = 'PreInitialOffer';
                }
                
            }
            update objOpp;
            
        }
        if(String.isNotBlank(request.applicantId)){
            Applicant__c applicant = [SELECT Id, Customer_Code__c FROM Applicant__c WHERE Id =:request.applicantId];
            //Haarika - added FirstName, LastName, KYC_name__c
            applicant.Customer_First_Name__c = String.isNotblank(request.FirstName)  ? request.FirstName : applicant.Customer_First_Name__c;
            applicant.Customer_Last_Name__c = String.isNotblank(request.LastName)  ? request.LastName : applicant.Customer_Last_Name__c;
            applicant.Name = applicant.Customer_First_Name__c+' '+applicant.Customer_Last_Name__c;        
            
            if(applicant.Name.length() > 80){
                applicant.Name = applicant.Name.substring(0, 80);
            }
            if(String.isNotBlank(applicant.Customer_Code__c) && request.aadharOTPorBiometric != null && request.aadharOTPorBiometric == true){
                isReKYC = true;
            }

            applicant.Aadhar_No__c = String.isNotBlank(request.aadharNumber) ? request.aadharNumber : applicant.Aadhar_No__c;
            applicant.Aadhar_OTP_or_Biometric__c = request.aadharOTPorBiometric;
            update applicant;
        }

        //update aadhar document
        if(String.isNotBlank(request.aadharDocumentId)){
            Id recordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
            Documents__c objDocument = new Documents__c(Id = request.aadharDocumentId);
            if(objOpp.RE_KYC_Stage__c  == 'PostInitialOffer'){
                Documents__c objDoc = [Select id,Opportunity_Relation__c,Applicant__c,Document_Type__c,Salutation__c,is_Active__c,Name,Gender__c,Proof_of_Address_POA__c,Proof_of_Identity_POI__c,KYC_DOB__C,KYC_Address_Line_1__c ,KYC_Address_Line_2__c ,KYC_City__c ,KYC_District__c ,KYC_Pin_Code__c ,KYC_State__c  from Documents__c where id=:request.aadharDocumentId];
                Documents__c objDocNew = objDoc.clone(false,true,false,false);
                objDocument.Pre_Initial_Address__c = false;
                objDocNew.Pre_Initial_Address__c = true;
                insert objDocNew;
                system.debug('inside if');
              objDocument.recordTypeId = recordTypeId; 
              objDocument.Document_Type__c='Aadhaar';
                objDocument.Name ='Aadhaar';
            }
            else{
                objDocument.recordTypeId = recordTypeId;
                objDocument.Document_Type__c='Aadhaar';
                objDocument.Name ='Aadhaar';
            }
            
            objDocument.KYC_No__c = String.isNotBlank(request.aadharNumber) ? request.aadharNumber : objDocument.KYC_No__c;
            //if(Test.isRunningTest()) {
   			//	objDocument.KYC_No__c =Integrationutilities.getencryptedrequest(request.aadharNumber,System.Label.privateKey,System.Label.ivkey);
			//		}
            //objDocument.Masked_KYC_No__c =  String.isNotBlank(request.aadharNumber) ? request.aadharNumber : objDocument.Masked_KYC_No__c;
            objDocument.Aadhar_Vault_Code__c = String.isNotBlank(request.aadharVaultCode) ? request.aadharVaultCode : objDocument.Aadhar_Vault_Code__c;
            
            //Haarika - added Name
            objDocument.KYC_name__c = String.isNotBlank(request.FirstName) ? request.FirstName+' ': '';
            objDocument.KYC_name__c += String.isNotBlank(request.LastName) ? request.LastName : ''; 
            objDocument.First_Name__c = String.isNotBlank(request.FirstName) ? request.FirstName+' ' : '';
            objDocument.Last_Name__c = String.isNotBlank(request.LastName) ? request.LastName+' ' : '';

            
            if(objDocument.KYC_name__c.length() > 100){
                objDocument.KYC_name__c = objDocument.KYC_name__c.substring(0, 100);
            }
            if(isReKYC){
                objDocument.Re_KYC__c = true;
            }
            
            update objDocument;
            system.debug('objDocument :'+objDocument.Id);
            //create Aadhar Image document
            if(String.isNotBlank(request.aadharBase64EncodedData)){
                createContentVersion('Aadhar Image','Aadhar.jpeg', objDocument.Id, request.aadharBase64EncodedData);
            }
        }
        //Create customer Image document
        if(String.isNotBlank(request.applicantId) && String.isNotBlank(request.loanApplicationId)){
            Documents__c customerImageDocument = new Documents__c();
            customerImageDocument.Document_Type__c = System.Label.CustomerImageDocumentType;
            customerImageDocument.Name = 'Customer Image1';
            customerImageDocument.Applicant__c = request.applicantId;
            customerImageDocument.Opportunity_Relation__c = request.loanApplicationId;
            customerImageDocument.is_Active__c = true;
            insert customerImageDocument;
            if(String.isNotBlank(request.customerImageBase64Data)){
                createContentVersion('Customer Image','CustomerImage.jpeg', customerImageDocument.Id, request.customerImageBase64Data);
            }
        }

        resultWrapper res = new resultWrapper();
        res.Result = 'Updated Succesfully';

        String decryptedResponse = JSON.serialize(res);
        String encryptedResponse = IntegrationUtilities.getEncryptedRequest(decryptedResponse,System.Label.privateKey,System.Label.ivkey); 
        String body=setBody(JSON.serialize(encryptedResponse));
        RestContext.response.responseBody = Blob.valueOf(body);
        //RestContext.response.responseBody = Blob.valueOf(JSON.serialize(res));
        //RestContext.response.responseBody = Blob.valueOf(encryptedResponse);
        RestContext.response.addHeader('Content-Type', 'application/json');

        //Create Integration Log
        IntegrationUtilities.createIntegrationLogger(stringRequest, stringEncryptedRequest, decryptedResponse, encryptedResponse, 'CaptureAadharInformation', null, request.loanApplicationId);
    }

    public static String setBody(String encryptedResponse){
        system.debug('encryptedResponse method :'+encryptedResponse);
        String jdataRequest1 = '"JData":';                    
        String body='{'+jdataRequest1 +encryptedResponse+'}';
        return body;
    }
    
    /**
     * Method: createContentVersion
     * Description: Method to create the document.
     * return void
     */
    private static void createContentVersion(String title, String pathOnClient, Id linkedRecordId, String customerImageBase64Data){
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = title;
        contentVersion.PathOnClient = pathOnClient;
        contentVersion.FirstPublishLocationId = linkedRecordId;
        if(title == 'Customer Image'){
            contentVersion.Document_Side_fileupload__c= 'Selfie';
        }
        
        //UserInfo.getUserId();
        contentVersion.versionData = EncodingUtil.base64Decode(customerImageBase64Data);
        //Blob.valueOf(customerImageBase64Data);
        insert contentVersion;
        contentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id];
        /*List<ContentDocumentLink> cd = [SELECT LinkedEntityId,ShareType,ContentDocumentId from ContentDocumentLink WHERE ContentDocumentId =: contentVersion.ContentDocumentId];
        system.debug('cd : '+cd);
        ContentDocumentLink cdl = new ContentDocumentLink(ContentDocumentId = contentVersion.ContentDocumentId,LinkedEntityId=linkedRecordId, ShareType = 'V');
        insert cdl;*/
    }
    /**
     * Class: AadhaarRequest
     * Description: Wrapper class to store request parameters.
     */
    public class AadharRequest{
        public String FirstName;
        public String LastName;
        public String Salutation;
        public String applicantId;
        public String loanApplicationId;
        public String aadharNumber;
        public Boolean aadharOTPorBiometric;
        public String aadharVaultCode;
        public String aadharBase64EncodedData;
        public String aadharDocumentId;
        public String customerImageBase64Data;
    }
    
    public class resultWrapper{
        public string Result;
    }
}