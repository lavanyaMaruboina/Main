/*------------------------------------------------------------
Author:        kranthi makkena
Company:       Persistent Systems
Description:   This class is wrapper class for the Customer Master Creation API request
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-28-2021      kranthi makkena       Created
12-28-2021      Thilak Bondiga       modified       Changed - V3 Document - added two fields in request 1.Disability, 2.CKYC_ID
------------------------------------------------------------*/
public class IND_CustomerMasterCreationRequest extends ParentAPIRequest{
    
    
    Public TBMCustomer TBMCustomer{get;set;}
    public  List<CustomerDt>  customerDt{get;set;}
    public  List<DocumentInfo>  objDocumentInfo{get;set;}
    public Boolean isPreApprovedJourney;
    public Boolean isD2C;
    public Boolean isNonIndividualTractor; //SFTRAC-395
    public class TBMCustomer{ 
        public string Customer_Code {get;set;} 
        public string Customer_Type {get;set;}
        public string Customer_Salutation {get;set;}
        public string Customer_Name {get;set;}
        public string Customer_sex {get;set;}
        public string Customer_profile {get;set;}
        public string Communication_Language  {get;set;}
        public string Customer_Qualification  {get;set;}
        public string Father_Husband_Name  {get;set;}
        public string Mother_Name  {get;set;}
        public string Date_of_Birth  {get;set;}
        public string Spouse_Name  {get;set;}
        public string Base_Location  {get;set;}
        public string Maker_Id  {get;set;}
        public string Aadhaar_No  {get;set;}
        public string Aadhaar_Verified  {get;set;}
        public string Aadhaar_Verified_On  {get;set;}
        public string Aadhaar_Verified_By  {get;set;}
        public string PAN_GIR_Number  {get;set;}
        public string PAN_Holder_Name   {get;set;}
        public string PAN_Verified   {get;set;}
        public string PAN_Verified_On  {get;set;}
        public string PAN_Verified_By  {get;set;}
        public string eAadhaar_Verified   {get;set;}
        public string eAadhaar_Verified_On   {get;set;}
        public string eAadhaar_Verified_By   {get;set;}
        public string Aadhaar_Enrolment_ID   {get;set;}
        public string Aadhaar_EnrollID_Verified   {get;set;}
        public string Aadhaar_EnrollID_Verified_On  {get;set;}
        public string Aadhaar_EnrollID_Verified_By  {get;set;}
        public string Passport_Number   {get;set;}
        public datetime Passport_Expiry_Date   {get;set;}
        public string Passport_Verified   {get;set;}
        public String Passport_Verified_On   {get;set;}
        public string Passport_Verified_By    {get;set;}
        public string Voter_ID_Number    {get;set;}
        public string VoterID_Verified    {get;set;}
        public string VoterID_Verified_On    {get;set;}
        public string VoterID_Verified_By    {get;set;}
        public string Driving_License_Number    {get;set;}
        public string Driving_License_Type    {get;set;}
        public string Driving_License_Expiry_Date    {get;set;}
        public string DrvLic_Verified    {get;set;}
        public string DrvLic_Verified_On    {get;set;}
        public string DrvLic_Verified_By    {get;set;}
        public string Ration_Card_No    {get;set;}
        public string RationCard_Verified    {get;set;}
        public string RationCard_Verified_On    {get;set;}
        public string RationCard_Verified_By    {get;set;}
        public string Post_Office_Iden_No    {get;set;}
        public string FORM60    {get;set;}
        public string FORM60_Verified     {get;set;}
        public string FORM60_Verified_On     {get;set;}
        public string FORM60_Verified_By    {get;set;}
        public string APP_Page_Verified    {get;set;}
        public string APP_Page_Verified_On     {get;set;}
        public string APP_Page_Verified_By    {get;set;}
        public string BSR_Code     {get;set;}
        public string Active_Flag     {get;set;}
        public string Off_Applicable     {get;set;}
        public string Off_Name     {get;set;}
        public string Emp_No     {get;set;}
        public string Per_Address_Flag    {get;set;}
        public string Contact_Person     {get;set;}
        public string Nature_Resi_proof     {get;set;}
        public string Resi_Proof     {get;set;}
        public string Nature_ID_proof     {get;set;}
        public string Nature_Age_proof    {get;set;}
        public string SurName    {get;set;}
        public string Department    {get;set;}
        public string Designation     {get;set;}
        public string Place_Of_Posting     {get;set;}
        public string Date_Of_Joining     {get;set;}
        public string Date_Of_Retirement     {get;set;}
        public string Salary_Date   {get;set;}
        public string Referal_no  {get;set;}
        public string Referal_date  {get;set;}
        public string Report_score  {get;set;}
        public string Religion   {get;set;}
        public string Caste {get;set;}
        public string Commn_Address_Flag {get;set;}
        public string Credit_score    {get;set;}
        public string Source   {get;set;}
        public string Marital_Status   {get;set;}
        public string CIN   {get;set;}
        public String Regn_Incorp_Date  {get;set;}
        public string Estimated_Annual_Income   {get;set;}
        public string Average_Annual_Turnover  {get;set;}
        public string Disability  {get;set;}
        public string CKYC_ID  {get;set;}
        //CISP-3338 -- start
        public String Product {get;set;}
        public String Address_Decl_Approved_On {get;set;} //CISP-3338 Application_Consent_SMS_Sent_Time__c
        public String Lead_No  {get;set;}
        public string CIB_feedback {get;set;}
        public string Trans_Gender {get;set;}
        public string Deemed_OVD {get;set;}
        public string Deemed_OVD_Doc_Type {get;set;}
        public string Current_Address_Matched_OVD {get;set;}
        public string EKYC_Biometric {get;set;}
        public string Deemed_OVD_Doc_Date {get;set;}
        public string Deemed_OVD_Approved_Status {get;set;}
        public string Deemed_OVD_Approved_By {get;set;}
        public String Deemed_OVD_Approved_On {get;set;}
        public string Aadhaar_Token_No {get;set;}
        //CISP-3338 -- end
        public string Customer_Category {get;set;}
        public string PAN_Aadhaar_Seeding_Flag {get;set;}
        public string VKYC_Status {get;set;} //SFTRAC-235
        public string VKYC_Doc_Download {get;set;}//SFTRAC-235
        public string VKYC_Doc_Url {get;set;}//SFTRAC-235
    } 
    public class CustomerDt {
        public string Customer_Code {get;set;} 
        public string Address_Line_1      {get;set;}
        public string Address_Line_2      {get;set;}
        public string Address_Line_3       {get;set;}
        public string Address_Line_4       {get;set;}
        public string City       {get;set;}
        public string District       {get;set;}
        public string State       {get;set;} 
        public string Pin_code       {get;set;} 
        public string ISD_STD       {get;set;}
        public string Phone_Number       {get;set;}
        public string Extn       {get;set;} 
        public string Mobile_Number       {get;set;}
        public string Fax_ISD_STD       {get;set;} 
        public string Fax_No       {get;set;}
        public string Email_Address       {get;set;}
        public string Address_Flag {get;set;}
        public string Commn_Address_Flag    {get;set;} 
        public string Landmark       {get;set;}
        public string Distance       {get;set;}
        public string Alternate_Mobile        {get;set;}
        public string Whatsapp_Mobile_Number       {get;set;}
        
    }
    public class DocumentInfo {
        public string Document_Type {get;set;} 
        public string Record_Id {get;set;}
    }
    /*
    @Method:      IND_CustomerMasterCreationRequest
    @Created by:  Kranthi Makkena
    @Description: Method to get the HTTP request header data
    @Param:       ''
    // @Return:      Header required to callout the service. */
    public IND_CustomerMasterCreationRequest(Applicant__c app, String religion, String caste,String district){ 
        this.isNonIndividualTractor = false;
        if(app != null){
            this.isPreApprovedJourney = app.Opportunity__r.Is_Pre_Approved__c;
            this.isD2C = app.Opportunity__r.LeadSource == 'D2C' ? true : false;
            if(app.Opportunity__r.Product_Type__c == 'Tractor' && app.Opportunity__r.Customer_Type__c == 'Non-Individual' && app.Applicant_Type__c == 'Borrower'){ //SFTRAC-395
            this.isNonIndividualTractor = true;
            }
            List<ProofMaster__mdt> proofMasters = [SELECT Id,Label,Code__c,Proof_Type__c FROM ProofMaster__mdt WITH SECURITY_ENFORCED];
            
            Map<String,String> proofCodes = new Map<String,String>();
            if(!proofMasters.isEmpty()){
                for(ProofMaster__mdt proof : proofMasters){
                    if(proof.Label.toLowerCase() == 'PARTNERSHIP REGISTRATION CERT/PARTNERSHI'.toLowerCase()){
                        proofCodes.put('PARTNERSHIP REGISTRATION CERT/PARTNERSHIP LETTER'.toLowerCase(),proof.Code__c);
                    }else{
                        proofCodes.put(proof.Label.toLowerCase(),proof.Code__c);
                    }
                }
            }
            list<Income_Details__c> incdetails = [Select Id,Income__c,Salaried_Self_employed__c,Profile__r.Code__c,Office_Address_Line_1__c,Office_Address_Line_2__c,Office_City__c,Office_District__c,Office_State__c,Office_PinCode__c,Profile__r.Category__c from Income_Details__c where Applicant__c =: app.Id WITH SECURITY_ENFORCED LIMIT 1];
            Map<Id,Documents__c> documents = new Map<Id,Documents__c>([SELECT Salutation__c,Masked_KYC_No__c,Aadhar_Source__c,Document_Side__c,KYC_No__c,KYC_DOB__c,PAN_No__c,KYC_Name__c,KYC_Address_Line_1__c,Applicant__r.Application_Consent_SMS_Sent_Time__c,Applicant__r.Current_Same_As_Permanent__c,
                                                                       KYC_Address_Line_2__c,IND_Aadhaar_Vault_Token_ID__c,KYC_Address_Line_3__c,KYC_Address_Line_4__c,KYC_City__c,KYC_District__c,KYC_State__c,KYC_Pin_Code__c,Current_Residential_Address_Proof__c,
                                                                       Document_Type__c, Case__c,Gender__c, Case__r.OwnerId, Case__r.ClosedDate, RecordType.Name,Permanent_Residential_Address_Proof__c,Case__r.IsClosed,Name,
                                                                       Proof_of_Address_POA__c, Proof_of_Identity_POI__c, Passport_No__c, KYC_Expiry_Date__c,CreatedById,createdDate,Aadhaar_Enrollment_Number__c,DL_Type__c,Case__r.RecordType.Name,documentApprovedDate__c,AadhaarSeedingStatus__c
                                                                       FROM Documents__c WHERE Applicant__c = :app.Id and is_Active__c = true AND Document_Type__c != null WITH SECURITY_ENFORCED]); //CISP-2343 Added Document Type not equals to NUll
            list<string> kycList = new list<string>();
            Map<string,list<string>> cdDocMap = new Map<string,list<string>>(); 
            Map<string,ContentVersion> cvMap = new Map<string,ContentVersion>();
            Set<Id> userIds = new Set<Id>();
            list<String> cdIds = new list<String>();
            Map<string,string> deemedovdmap = new Map<string,string>();
            deemedovdmap.put('Electronic Bill',System.label.Electricity_Bill); //CISP-3900
            deemedovdmap.put('6',System.label.Property_or_Municipal_Tax_Receipt);
            deemedovdmap.put('Property or Municipal Tax Receipt',System.label.Property_or_Municipal_Tax_Receipt);
            deemedovdmap.put('Gas bill',System.label.Gas_bill_within_2_months);
            deemedovdmap.put('Post paid mobile bill',System.label.Post_paid_mobile_bill_within_2_months);
            deemedovdmap.put('3',System.label.Telephone_bill);
            deemedovdmap.put('Water Bill',System.label.Water_Bill_within_2_months);
            deemedovdmap.put('Address Declaration',System.label.AddressDeclaration);

            for(Documents__c doc : documents.values()) {
                if(doc.RecordType.Name.contains('KYC Document') || doc.Document_Type__c=='Customer Image') {
                    kycList.add(doc.Id);
                }
                userIds.add(doc.Case__r.OwnerId);
                userIds.add(doc.CreatedById);
            }
            for(ContentDocumentLink cdl: [Select Id,ContentDocumentId,LinkedEntityId from ContentDocumentLink where LinkedEntityId = :kycList]) {
                cdIds.add(cdl.ContentDocumentId);
                if(cdDocMap.containsKey(cdl.LinkedEntityId)) {
                    cdDocMap.get(cdl.LinkedEntityId).add(cdl.ContentDocumentId);
                } else {
                    cdDocMap.put(cdl.LinkedEntityId,new list<String>());
                    cdDocMap.get(cdl.LinkedEntityId).add(cdl.ContentDocumentId);
                }
            }
            for(ContentVersion cv : [Select Id,ContentDocumentId,Document_Side_fileupload__c from ContentVersion where ContentDocumentId = :cdIds and IsLatest=true]) {
               cvMap.put(cv.ContentDocumentId,cv);
            }
            
            userIds.add(app.Opportunity__r.OwnerId);
            Map<Id,User> userMap = new Map<Id,User>([SELECT Id,Maker_Id__c,Username,User_Id__c FROM User WHERE Id IN :userIds]);
            List<CIBIL_Details__c> cibil = [SELECT CIC_No__c,CreatedDate,Score__c FROM CIBIL_Details__c WHERE Applicant__c = :app.Id WITH SECURITY_ENFORCED];
            
            List<OpportunityHistory> oppsHistory = [Select StageName,CreatedDate from OpportunityHistory where OpportunityId =: app.Opportunity__r.Id and StageName ='Asset Details' limit 1];
            List<Final_Term__c> finalTerm = [SELECT Emp_No__c FROM Final_Term__c WHERE Loan_Application__c=:app.Opportunity__c WITH SECURITY_ENFORCED LIMIT 1];
            this.TBMCustomer = new TBMCustomer();
            this.TBMCustomer.Lead_No  = app.Opportunity__r.Lead_number__c != null ? app.Opportunity__r.Lead_number__c +'_'+app.applicant_number__c :'';
            //SFTRAC-235 start
            if(app.Opportunity__r.VKYC_status__c != null){
                this.TBMCustomer.VKYC_Status = app.Opportunity__r.VKYC_status__c != null ? app.Opportunity__r.VKYC_status__c != 'Not Required' ? app.Opportunity__r.VKYC_status__c : 'NA' : '';
                this.TBMCustomer.VKYC_Doc_Download = app.Opportunity__r.VKYC_Doc_Downloaded__c == true ? 'True' : 'false' ;
                this.TBMCustomer.VKYC_Doc_Url = app.Opportunity__r.VKYC_Doc_Urls__c != null ? app.Opportunity__r.VKYC_Doc_Urls__c: '';
            }else{
                this.TBMCustomer.VKYC_Status = '';
                this.TBMCustomer.VKYC_Doc_Download = '';
                this.TBMCustomer.VKYC_Doc_Url = '';
            }//SFTRAC-235 end
            CustomerDt = new list<CustomerDt>();
            objDocumentInfo = new list<DocumentInfo>();
            
            this.TBMCustomer.CIN='';    
            if(!app.Customer_Dedupe_Response__r.isEmpty()){
                this.TBMCustomer.CIN=app.Customer_Dedupe_Response__r[0].CIN_No__c;    
            }
            if(app.Opportunity__r.Product_Type__c == System.Label.Tractor && app.Opportunity__r.Customer_Type__c == 'Non-Individual' &&  app.Applicant_Type__c != 'Borrower' && app.Preferred_address_for_communication__c =='Office Address') {
                CustomerDt dt = new CustomerDt();
                dt.Customer_Code= app.Customer_Code__c;//CISP-4263            
                dt.Address_Line_1 =app.Beneficiary_Office_Address_Line_1__c;
                dt.Address_Line_2 =app.Beneficiary_Office_Address_Line_2__c;
                dt.Address_Line_3 =app.Beneficiary_Office_Address_Line_2__c;
                dt.Address_Line_4 =app.Beneficiary_Office_City__c;
                dt.City = app.Beneficiary_Office_City__c;
                dt.District = app.Beneficiary_Office_District__c;
                dt.State = app.Beneficiary_Office_State__c; 
                dt.Pin_code =app.Beneficiary_Office_Pincode__c; 
                dt.Address_Flag = 'O';
                if(app.Preferred_address_for_communication__c == 'Office Address'){
                    dt.Commn_Address_Flag ='C';
                }
                dt.Mobile_Number = app.Contact_number__c;  
                dt.Email_Address =app.Email_Id__c;  
                dt.Whatsapp_Mobile_Number =app.Whatsapp_number__c;  
                CustomerDt.add(dt);
            }
            else if(app.Opportunity__r.Product_Type__c != System.Label.Tractor && !incdetails.isEmpty()) {
                CustomerDt dt = new CustomerDt();
                dt.Customer_Code= app.Customer_Code__c;//CISP-4263
                dt.Address_Line_1 = incdetails[0].Office_Address_Line_1__c;
                dt.Address_Line_2 = incdetails[0].Office_Address_Line_2__c;
                dt.Address_Line_3 = incdetails[0].Office_Address_Line_2__c;
                dt.Address_Line_4 = incdetails[0].Office_City__c;
                dt.City = incdetails[0].Office_City__c;
                dt.District = incdetails[0].Office_District__c;
                dt.State = incdetails[0].Office_State__c; 
                dt.Pin_code = incdetails[0].Office_PinCode__c;   
                dt.Address_Flag = 'O';
                if(app.Preferred_address_for_communication__c == 'Office Address'){
                    dt.Commn_Address_Flag ='C';
                }
                dt.Mobile_Number = app.Contact_number__c;  
                dt.Email_Address =app.Email_Id__c;  
                dt.Whatsapp_Mobile_Number =app.Whatsapp_number__c;  
                CustomerDt.add(dt);
            }
            this.TBMCustomer.Aadhaar_Verified='' ;
            this.TBMCustomer.Aadhaar_Verified_On=null;
            this.TBMCustomer.Aadhaar_Verified_By='';
            this.TBMCustomer.PAN_Verified='' ;
            this.TBMCustomer.PAN_Verified_On=null;
            this.TBMCustomer.PAN_Verified_By= null ;
            this.TBMCustomer.PAN_GIR_Number='';
            this.TBMCustomer.PAN_Holder_Name='';
            this.TBMCustomer.PAN_Aadhaar_Seeding_Flag ='';
            this.TBMCustomer.Voter_ID_Number='' ;
            this.TBMCustomer.VoterID_Verified='' ;
            this.TBMCustomer.VoterID_Verified_On=null ;
            this.TBMCustomer.VoterID_Verified_By ='';
            this.TBMCustomer.Post_Office_Iden_No='' ;
            this.TBMCustomer.FORM60 ='';
            this.TBMCustomer.FORM60_Verified =''; 
            this.TBMCustomer.FORM60_Verified_On =null; 
            this.TBMCustomer.FORM60_Verified_By='' ;
            this.TBMCustomer.APP_Page_Verified ='';
            this.TBMCustomer.APP_Page_Verified_On=null; 
            this.TBMCustomer.APP_Page_Verified_By='';
            this.TBMCustomer.Nature_Resi_proof='';            
            this.TBMCustomer.Nature_ID_proof=''; 
            if(app.Is_Address_Declaration__c){
                this.TBMCustomer.Address_Decl_Approved_On = app.Application_Consent_SMS_Sent_Time__c != null ? app.Application_Consent_SMS_Sent_Time__c.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS') : '';
            }else{
                this.TBMCustomer.Address_Decl_Approved_On = '';
            }
            this.TBMCustomer.Product = app.Opportunity__r.Product_Type__c == 'Two Wheeler'?'H':app.Opportunity__r.Product_Type__c==System.Label.Tractor ? 'T' :'C';
            this.TBMCustomer.CIB_feedback = 'U';
            this.TBMCustomer.Current_Address_Matched_OVD = 'N';
            this.TBMCustomer.EKYC_Biometric = null; //CISP-3900
            this.TBMCustomer.Deemed_OVD = 'N'; //CISP-3821
            Boolean currentResidentialProof = false;
            Boolean permanentResidentialProof = false;
            if(!documents.isEmpty()){
                for(Documents__c doc : documents.values()){
                    if(doc.Document_Type__c.equals('PAN')){
                        //this.TBMCustomer.PAN_GIR_Number=doc.PAN_No__c;
                        //CISP-3038 --start
                        String decrypt = null;
                        if(app.Opportunity__r.LeadSource == 'D2C') {
                            decrypt = doc.PAN_No__c;
                        } else {
                            decrypt = IntegrationUtilities.getDecryptedResponse(doc.PAN_No__c,System.Label.privateKey,System.Label.ivkey);
                        }
                         
                        System.debug('decrypted res in pan is: '+decrypt);//CISP-3038 --end
                        this.TBMCustomer.PAN_GIR_Number=decrypt.toUpperCase();//CISP-15686
                        this.TBMCustomer.PAN_Holder_Name=doc.KYC_Name__c;
                        this.TBMCustomer.PAN_Verified='Y' ;
                        this.TBMCustomer.PAN_Aadhaar_Seeding_Flag = doc.AadhaarSeedingStatus__c != null ? doc.AadhaarSeedingStatus__c : '';
                        if(String.isNotBlank(doc.Case__c) && doc.Case__c!=null){
                            this.TBMCustomer.PAN_Verified_On = doc.documentApprovedDate__c?.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');//CISP-2940
                            if(doc.Case__r.OwnerId.getSObjectType().getDescribe().getName().equals('User')){
                                this.TBMCustomer.PAN_Verified_By = userMap.get(doc.Case__r.OwnerId).User_Id__c != null ? userMap.get(doc.Case__r.OwnerId).User_Id__c.substringBefore('_') : '';
                            }else{
                                this.TBMCustomer.PAN_Verified_By = '';    
                            }
                        }else{
                            this.TBMCustomer.PAN_Verified_On = doc.createdDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
                            this.TBMCustomer.PAN_Verified_By = userMap.get(doc.CreatedById).User_Id__c != null ? userMap.get(doc.CreatedById).User_Id__c.substringBefore('_') : '';
                        }
                    }
                    if(doc.Document_Type__c.equals('Voter Id')){
                        //this.TBMCustomer.Voter_ID_Number=doc.KYC_No__c;
                        //CISP-3038 --start
                        String decrypt = IntegrationUtilities.getDecryptedResponse(doc.KYC_No__c,System.Label.privateKey,System.Label.ivkey);
                        System.debug('decrypted res in voter is: '+decrypt);//CISP-3038 --end
                        this.TBMCustomer.Voter_ID_Number=decrypt;
                        this.TBMCustomer.VoterID_Verified='Y' ;
                        if(String.isNotBlank(doc.Case__c) && doc.Case__c!=null){
                            this.TBMCustomer.VoterID_Verified_On= doc.documentApprovedDate__c?.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');//CISP-2940
                            if(doc.Case__r.OwnerId.getSObjectType().getDescribe().getName().equals('User')){
                                this.TBMCustomer.VoterID_Verified_By = userMap.get(doc.Case__r.OwnerId).User_Id__c != null ? userMap.get(doc.Case__r.OwnerId).User_Id__c.substringBefore('_') : '';
                            }else{
                                this.TBMCustomer.VoterID_Verified_By = '';    
                            }
                        }else{
                            this.TBMCustomer.VoterID_Verified_On = doc.createdDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
                            this.TBMCustomer.VoterID_Verified_By = userMap.get(doc.CreatedById).User_Id__c != null ? userMap.get(doc.CreatedById).User_Id__c.substringBefore('_') : '';
                        }
                    }
                    if(doc.Document_Type__c.equals('Form 60')){
                        this.TBMCustomer.FORM60 = 'FORM60';
                        this.TBMCustomer.FORM60_Verified ='Y'; 
                        if(String.isNotBlank(doc.Case__c) && doc.Case__c!=null){
                            this.TBMCustomer.FORM60_Verified_On= doc.documentApprovedDate__c?.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');//CISP-2940
                            if(doc.Case__r.OwnerId.getSObjectType().getDescribe().getName().equals('User')){
                                this.TBMCustomer.FORM60_Verified_By = userMap.get(doc.Case__r.OwnerId).User_Id__c != null ? userMap.get(doc.Case__r.OwnerId).User_Id__c.substringBefore('_') : '';
                            }else{
                                this.TBMCustomer.FORM60_Verified_By = '';    
                            }
                        }else{
                            this.TBMCustomer.FORM60_Verified_On = doc.createdDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
                            this.TBMCustomer.FORM60_Verified_By = userMap.get(doc.CreatedById).User_Id__c != null ? userMap.get(doc.CreatedById).User_Id__c.substringBefore('_') : '';
                        }
                        
                    }
                    System.debug('Document_Type__c..'+doc.Document_Type__c);
                    if(doc.Document_Type__c == System.Label.AadhaarCard){ //Aadhaar
                        this.TBMCustomer.Aadhaar_Token_No =doc.IND_Aadhaar_Vault_Token_ID__c;
                        this.TBMCustomer.Aadhaar_No=doc.Masked_KYC_No__c ;
                        this.TBMCustomer.Aadhaar_Enrolment_ID =doc.Aadhaar_Enrollment_Number__c == null ? '' : doc.Aadhaar_Enrollment_Number__c;
                        if(doc.Aadhar_Source__c == 'Scan and Upload') {
                        this.TBMCustomer.Aadhaar_Verified='Y' ;
                        this.TBMCustomer.Aadhaar_EnrollID_Verified ='Y';
                        if(String.isNotBlank(doc.Case__c) && doc.Case__c!=null){
                            this.TBMCustomer.Aadhaar_Verified_On = doc.documentApprovedDate__c?.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');//CISP-2940
                            this.TBMCustomer.Aadhaar_EnrollID_Verified_On = doc.Aadhaar_Enrollment_Number__c != null ? doc.Case__r.ClosedDate?.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS') : '';
                            if(doc.Case__r.OwnerId.getSObjectType().getDescribe().getName().equals('User')){
                                this.TBMCustomer.Aadhaar_Verified_By = userMap.containsKey(doc.Case__r.OwnerId) && userMap.get(doc.Case__r.OwnerId).User_Id__c != null ? userMap.get(doc.Case__r.OwnerId).User_Id__c.substringBefore('_') : '';
                                this.TBMCustomer.Aadhaar_EnrollID_Verified_By = doc.Aadhaar_Enrollment_Number__c != null && userMap.containsKey(doc.Case__r.OwnerId) && userMap.get(doc.Case__r.OwnerId).User_Id__c != null ? userMap.get(doc.Case__r.OwnerId).User_Id__c.substringBefore('_') : '';
                            }else{
                                this.TBMCustomer.Aadhaar_Verified_By = '';    
                                this.TBMCustomer.Aadhaar_EnrollID_Verified_By = '';
                            }
                        }else{
                            this.TBMCustomer.Aadhaar_Verified_On = doc.createdDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
                            this.TBMCustomer.Aadhaar_EnrollID_Verified_On = doc.Aadhaar_Enrollment_Number__c != null ? doc.createdDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS') : '';
                            this.TBMCustomer.Aadhaar_Verified_By = userMap.containsKey(doc.CreatedById) && userMap.get(doc.CreatedById).User_Id__c != null ? userMap.get(doc.CreatedById).User_Id__c.substringBefore('_') : '';
                            this.TBMCustomer.Aadhaar_EnrollID_Verified_By = doc.Aadhaar_Enrollment_Number__c != null && userMap.containsKey(doc.CreatedById) && userMap.get(doc.CreatedById).User_Id__c != null ? userMap.get(doc.CreatedById).User_Id__c.substringBefore('_') : '';
                        } 
                    } else {
                        if(doc.Aadhar_Source__c == 'Biometric'){
                            this.TBMCustomer.EKYC_Biometric = 'Y';
                        }else if(doc.Aadhar_Source__c == 'OTP'){
                            this.TBMCustomer.EKYC_Biometric = 'N';
                        }
                        this.TBMCustomer.eAadhaar_Verified='Y' ;
                        this.TBMCustomer.Aadhaar_EnrollID_Verified ='Y';
                        if(String.isNotBlank(doc.Case__c) && doc.Case__c!=null){
                            this.TBMCustomer.eAadhaar_Verified_On = doc.documentApprovedDate__c?.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');//CISP-2940
                            this.TBMCustomer.Aadhaar_EnrollID_Verified_On = doc.Aadhaar_Enrollment_Number__c != null ? doc.Case__r.ClosedDate?.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS') : '';//CISP-2940
                            if(doc.Case__r.OwnerId.getSObjectType().getDescribe().getName().equals('User')){
                                this.TBMCustomer.eAadhaar_Verified_By = userMap.get(doc.Case__r.OwnerId).User_Id__c != null ? userMap.get(doc.Case__r.OwnerId).User_Id__c.substringBefore('_') : '';
                                this.TBMCustomer.Aadhaar_EnrollID_Verified_By = doc.Aadhaar_Enrollment_Number__c != null && userMap.get(doc.Case__r.OwnerId).User_Id__c != null ? userMap.get(doc.Case__r.OwnerId).User_Id__c.substringBefore('_') : '';
                            }else{
                                this.TBMCustomer.eAadhaar_Verified_By = '';
                                this.TBMCustomer.Aadhaar_EnrollID_Verified_By ='';  
                            }
                        }else{
                            this.TBMCustomer.Aadhaar_EnrollID_Verified_On = doc.Aadhaar_Enrollment_Number__c != null ? doc.createdDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS') : '';
                            this.TBMCustomer.eAadhaar_Verified_On = doc.createdDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
                            this.TBMCustomer.eAadhaar_Verified_By = userMap.get(doc.CreatedById).User_Id__c != null ? userMap.get(doc.CreatedById).User_Id__c.substringBefore('_') : '';
                            this.TBMCustomer.Aadhaar_EnrollID_Verified_By = doc.Aadhaar_Enrollment_Number__c != null && userMap.get(doc.CreatedById).User_Id__c != null ? userMap.get(doc.CreatedById).User_Id__c.substringBefore('_') : '';
                        }                        
                    }                                               
                    }
                    if(doc.Document_Type__c == System.Label.DrivingLicences){ //Driving License
                        String decrypt = IntegrationUtilities.getDecryptedResponse(doc.KYC_No__c,System.Label.privateKey,System.Label.ivkey);
                        this.TBMCustomer.Driving_License_Number=decrypt;
                        this.TBMCustomer.DrvLic_Verified ='Y';
                        this.TBMCustomer.Driving_License_Expiry_Date = doc.KYC_Expiry_Date__c == null ? '' : doc.KYC_Expiry_Date__c + '';
                        this.TBMCustomer.Driving_License_Type= doc.DL_Type__c == null ? '' : doc.DL_Type__c;
                        if(String.isNotBlank(doc.Case__c) && doc.Case__c != null){
                            this.TBMCustomer.DrvLic_Verified_On =doc.documentApprovedDate__c?.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');//CISP-2940
                            if(doc.Case__r.OwnerId.getSObjectType().getDescribe().getName().equals('User')){
                                this.TBMCustomer.DrvLic_Verified_By = userMap.containsKey(doc.Case__r.OwnerId) && userMap.get(doc.Case__r.OwnerId).User_Id__c != null ? userMap.get(doc.Case__r.OwnerId).User_Id__c.substringBefore('_') : '';
                            }else{
                                this.TBMCustomer.DrvLic_Verified_By = '';    
                            }
                        }else{

                            this.TBMCustomer.DrvLic_Verified_On =null;
                            this.TBMCustomer.DrvLic_Verified_By='';
                        }
                    }
                    if(doc.Document_Type__c == System.Label.PassportCard){ // Passport
                        //this.TBMCustomer.Passport_Number=doc.Passport_No__c ;
                        //CISP-3038 --start
                        String decrypt = IntegrationUtilities.getDecryptedResponse(doc.Passport_No__c,System.Label.privateKey,System.Label.ivkey);
                        System.debug('decrypted res passport is: '+decrypt);//CISP-3038 --end
                        this.TBMCustomer.Passport_Number=decrypt;
                        this.TBMCustomer.Passport_Verified ='Y';
                        this.TBMCustomer.Passport_Expiry_Date = doc.KYC_Expiry_Date__c;
                        if(String.isNotBlank(doc.Case__c) && doc.Case__c != null){
                            this.TBMCustomer.Passport_Verified_On =doc.documentApprovedDate__c?.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');//CISP-2940
                            if(doc.Case__r.OwnerId.getSObjectType().getDescribe().getName().equals('User')){
                                this.TBMCustomer.Passport_Verified_By = userMap.get(doc.Case__r.OwnerId).User_Id__c != null ? userMap.get(doc.Case__r.OwnerId).User_Id__c.substringBefore('_') : '';
                            }else{
                                this.TBMCustomer.Passport_Verified_By = '';    
                            }
                        }else{
                            this.TBMCustomer.Passport_Verified_On = null;
                            this.TBMCustomer.Passport_Verified_By = '';
                        }
                    }
                    // if(doc.Document_Type__c == System.label.CustomerImageDocumentType){ // Customer Image
                    if(String.isBlank(this.TBMCustomer.APP_Page_Verified)){
                        if(String.isNotBlank(doc.Case__c) && doc.Case__c != null && doc.Case__r.RecordType.Name == 'CMU Request'){
                        this.TBMCustomer.APP_Page_Verified ='Y';
                                this.TBMCustomer.App_Page_Verified_On =doc.documentApprovedDate__c?.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
                                if(doc.Case__r.OwnerId.getSObjectType().getDescribe().getName().equals('User')){
                                    this.TBMCustomer.App_Page_Verified_By = userMap.get(doc.Case__r.OwnerId).User_Id__c != null ? userMap.get(doc.Case__r.OwnerId).User_Id__c.substringBefore('_') : '';
                                }else{
                                    this.TBMCustomer.App_Page_Verified_By = '';    
                                }
                            }
                        }
                        
                    // }
                     if((doc.Permanent_Residential_Address_Proof__c || (doc.Current_Residential_Address_Proof__c && doc.Applicant__r.Current_Same_As_Permanent__c)) && !permanentResidentialProof && doc.KYC_Address_Line_1__c !=null && doc.KYC_State__c !=null){
                            permanentResidentialProof = true;
                        CustomerDt dt = new CustomerDt();
                        dt.Address_Line_1 = doc.KYC_Address_Line_1__c;
                        dt.Address_Line_2 = doc.KYC_Address_Line_2__c;
                        //CISP-148 -- START
                        dt.Address_Line_3 = doc.KYC_Address_Line_3__c == null ? doc.KYC_Address_Line_2__c : doc.KYC_Address_Line_3__c;
                        dt.Address_Line_4 = doc.KYC_Address_Line_4__c == null ? doc.KYC_City__c : doc.KYC_Address_Line_4__c;
                        //CISP-148 -- END
                        dt.City = doc.KYC_City__c;
                        dt.District = district;
                        dt.State = doc.KYC_State__c; 
                        dt.Pin_code = doc.KYC_Pin_Code__c;   
                        dt.Address_Flag = 'P';
                        if(app.Preferred_address_for_communication__c == 'Permanent Address'){
                            dt.Commn_Address_Flag ='C';
                        }
                        dt.Mobile_Number = app.Contact_number__c;  
                        dt.Email_Address =app.Email_Id__c;  
                        dt.Whatsapp_Mobile_Number =app.Whatsapp_number__c;  
                        CustomerDt.add(dt); 
                        
                        if(app.Opportunity__r.Product_Type__c == System.Label.Tractor && app.Opportunity__r.Customer_Type__c == 'Non-Individual' &&  app.Applicant_Type__c == 'Borrower' && app.Preferred_address_for_communication__c =='Office Address') {
                          CustomerDt dt1 = new CustomerDt();
                          dt1.Customer_Code= app.Customer_Code__c;          
                          dt1.Address_Line_1 =doc.KYC_Address_Line_1__c;
                          dt1.Address_Line_2 =doc.KYC_Address_Line_2__c;
                          dt1.Address_Line_3 =doc.KYC_Address_Line_3__c == null ? doc.KYC_Address_Line_2__c : doc.KYC_Address_Line_3__c;
                          dt1.Address_Line_4 =doc.KYC_Address_Line_4__c == null ? doc.KYC_City__c : doc.KYC_Address_Line_4__c;
                          dt1.City = doc.KYC_City__c;
                          dt1.District = district;
                          dt1.State = doc.KYC_State__c; 
                          dt1.Pin_code =doc.KYC_Pin_Code__c; 
                          dt1.Address_Flag = 'O';
                        if(app.Preferred_address_for_communication__c == 'Office Address'){
                         dt1.Commn_Address_Flag ='C';
                       }
                       dt1.Mobile_Number = app.Contact_number__c;  
                       dt1.Email_Address =app.Email_Id__c;  
                       dt1.Whatsapp_Mobile_Number =app.Whatsapp_number__c;  
                       CustomerDt.add(dt1);
                      }           
                    }
                    if((doc.Current_Residential_Address_Proof__c || (doc.Permanent_Residential_Address_Proof__c && doc.Applicant__r.Current_Same_As_Permanent__c)) && !currentResidentialProof && doc.KYC_Address_Line_1__c !=null && doc.KYC_State__c !=null){
                        currentResidentialProof = true;
                        CustomerDt dt = new CustomerDt();
                        dt.Address_Line_1 = doc.KYC_Address_Line_1__c;
                        dt.Address_Line_2 = doc.KYC_Address_Line_2__c;
                        //CISP-148 -- START
                        dt.Address_Line_3 = doc.KYC_Address_Line_3__c == null ? doc.KYC_Address_Line_2__c : doc.KYC_Address_Line_3__c;
                        dt.Address_Line_4 = doc.KYC_Address_Line_4__c == null ? doc.KYC_City__c : doc.KYC_Address_Line_4__c;
                        //CISP-148 -- END
                        dt.City = doc.KYC_City__c;
                        dt.District = district;
                        dt.State = doc.KYC_State__c; 
                        dt.Pin_code = doc.KYC_Pin_Code__c;   
                        dt.Address_Flag = 'R';
                        if(app.Preferred_address_for_communication__c == 'Residence Address'){
                            dt.Commn_Address_Flag = 'C';
                        }
                        dt.Mobile_Number = app.Contact_number__c;  
                        dt.Email_Address =app.Email_Id__c;  
                        dt.Whatsapp_Mobile_Number =app.Whatsapp_number__c;  
                        CustomerDt.add(dt);            
                        if(!deemedovdmap.containsKey(doc.Document_Type__c))  {      
                            this.TBMCustomer.Current_Address_Matched_OVD = 'Y';
                        }          
                    }
                    if(doc.Proof_of_Identity_POI__c){
                        
                        this.TBMCustomer.Customer_sex =doc.Gender__c=='MALE'?'M':'F';
                        this.TBMCustomer.Trans_Gender = doc.Gender__c=='TRANSGENDER'?'Y':'N';
                        if(this.isNonIndividualTractor){                    
                            this.TBMCustomer.Regn_Incorp_Date=doc.KYC_DOB__c!=null?DateTime.newInstance(doc.KYC_DOB__c.year(), doc.KYC_DOB__c.month(), doc.KYC_DOB__c.day()).format('yyyy-MM-dd'):'';
                        }
                        else{
                            this.TBMCustomer.Date_of_Birth=doc.KYC_DOB__c!=null?DateTime.newInstance(doc.KYC_DOB__c.year(), doc.KYC_DOB__c.month(), doc.KYC_DOB__c.day()).format('yyyy-MM-dd'):'';

                        }
                        //Salutation changes start
                        if(String.isNotBlank(doc.Salutation__c)){
                            this.TBMCustomer.Customer_Salutation = doc.Salutation__c.toUpperCase().removeEnd('.');
                        }
                        else{
                            if(doc.Gender__c == 'MALE'){
                                this.TBMCustomer.Customer_Salutation = 'Mr';
                            }
                            else if(doc.Gender__c == 'FEMALE'){
                                if(app.Marital_Status__c == 'MARR'){
                                    this.TBMCustomer.Customer_Salutation = 'Mrs';
                                }
                                else{
                                    this.TBMCustomer.Customer_Salutation = 'Ms';
                                }
                            }
                            else{
                                this.TBMCustomer.Customer_Salutation = '';
                            }
                        }
                        //Salutation changes end
                    }
                    if(!proofCodes.isEmpty()){
                        for(String proof : proofCodes.keySet()){
                            if(doc.Proof_of_Address_POA__c){
                                this.TBMCustomer.Nature_Resi_proof=proofCodes.get(doc.Document_Type__c.toLowerCase());            
                            }
                            if(doc.Proof_of_Identity_POI__c){
                                this.TBMCustomer.Nature_ID_proof=proofCodes.get(doc.Document_Type__c.toLowerCase());            
                            }
                        }
                    }
                    if((doc.RecordType.Name.contains('KYC Document') || doc.Document_Type__c=='Customer Image') && cdDocMap.containsKey(doc.Id)){//CISP: 3204
                        if(!cdDocMap.get(doc.Id).isEmpty()){
                            System.debug('contentdoc..'+cdDocMap.get(doc.Id));
                            for(String cd : cdDocMap.get(doc.Id)){
                                DocumentInfo di = new DocumentInfo();
                                ContentVersion ver = cvMap.get(cd);
                                if(ver.Document_Side_fileupload__c != null){
                                    di.Document_Type = doc.Document_Type__c + '_' + ver.Document_Side_fileupload__c;
                                    di.Record_Id = ver.Id;
                                    objDocumentInfo.add(di);
                                }else {
                                    di.Document_Type = doc.Document_Type__c;
                                    di.Record_Id = ver.Id;
                                    objDocumentInfo.add(di);
                                }
                        }}
                        System.debug('objDocumentInfo..'+objDocumentInfo);
                    }
                    //CISP-3338 -- start
                    
                    //this.TBMCustomer.Deemed_OVD_Doc_Type = deemedovdmap.get(doc.Document_Type__c);
                    
                    if(deemedovdmap.containsKey(doc.Document_Type__c) && doc.Document_Type__c != 'Address Declaration') {
                        this.TBMCustomer.Deemed_OVD_Doc_Date = oppsHistory != null ? DateTime.newInstance(oppsHistory[0].CreatedDate.year(), oppsHistory[0].CreatedDate.month(), oppsHistory[0].CreatedDate.day()).format('yyyy-MM-dd') : '';
                        this.TBMCustomer.Deemed_OVD_Doc_Type = deemedovdmap.get(doc.Document_Type__c);
                        this.TBMCustomer.Deemed_OVD = 'Y';
                        if(String.isNotBlank(doc.Case__c) && doc.Case__c!=null)
                            {
                                this.TBMCustomer.Deemed_OVD_Approved_Status = doc.Case__r.ClosedDate != null && doc.Case__r.IsClosed == true ? 'Y' : 'N';
                                this.TBMCustomer.Deemed_OVD_Approved_By = userMap.containsKey(doc.Case__r.OwnerId) && userMap.get(doc.Case__r.OwnerId).User_Id__c != null ? userMap.get(doc.Case__r.OwnerId).User_Id__c.substringBefore('_') : '';
                                this.TBMCustomer.Deemed_OVD_Approved_On = doc.Case__r.ClosedDate != null ? DateTime.newInstance(doc.Case__r.ClosedDate.year(), doc.Case__r.ClosedDate.month(), doc.Case__r.ClosedDate.day()).format('yyyy-MM-dd') : '';
                            }
                        else {
                            this.TBMCustomer.Deemed_OVD_Approved_Status = 'N';
                            this.TBMCustomer.Deemed_OVD_Approved_By = userMap.containsKey(doc.CreatedById) && userMap.get(doc.CreatedById).User_Id__c != null ? userMap.get(doc.CreatedById).User_Id__c.substringBefore('_') : '';
                            this.TBMCustomer.Deemed_OVD_Approved_On = doc.CreatedDate != null ? DateTime.newInstance(doc.CreatedDate.year(), doc.CreatedDate.month(), doc.CreatedDate.day()).format('yyyy-MM-dd') : '';
                            }
                    }
                    
                    //CISP-3338 -- end
                    //CISP-3821
                    if(doc.Document_Type__c == 'Address Declaration') {
                        this.TBMCustomer.Nature_Resi_proof = deemedovdmap.get(doc.Document_Type__c);

                    }
                }
            }else{
                throw new IND_Exception(System.Label.AddTheRequiredDocuments);
            }
            //TBMCustomer tbm= new TBMCustomer();
            this.TBMCustomer.Customer_Code= app.Customer_Code__c;//CISP-4263
            this.TBMCustomer.Customer_Type = System.Label.Customer_Type_Code_Individual;
            if(isNonIndividualTractor){
                this.TBMCustomer.Customer_Type = app.opportunity__r.Entity_Code__c;
            }
            else if(String.isNotBlank(app.Legal_Entity_Identifier__c) && app.Legal_Entity_Identifier__c.equals('Individual')){
                this.TBMCustomer.Customer_Type = System.Label.Customer_Type_Code_Individual;
            }
            
            this.TBMCustomer.Customer_Name=app.Name;
            this.TBMCustomer.Communication_Language =app.Communication_language__c;
            this.TBMCustomer.Customer_Qualification=app.Customer_Qualification__c;
            this.TBMCustomer.Father_Husband_Name=app.Father_s_name__c;
            this.TBMCustomer.Mother_Name=app.Mother_s_name__c;
            
            this.TBMCustomer.Spouse_Name=app.Spouse_Name__c ;
            this.TBMCustomer.Base_Location=app.Opportunity__r.Agent_BL_code__c;
            //this.TBMCustomer.Maker_Id=userMap.get(app.Opportunity__r.CreatedById).User_Id__c != null ? userMap.get(app.Opportunity__r.CreatedById).User_Id__c.substringBefore('_') : '' ;
        
            if(app.Opportunity__r.LeadSource == 'TAFE'){
                this.TBMCustomer.Maker_Id=userMap.get(app.Opportunity__r.OwnerId).User_Id__c != null ? userMap.get(app.Opportunity__r.OwnerId).User_Id__c.substringBefore('_') : '' ;
            }else{
                this.TBMCustomer.Maker_Id=userMap.get(app.Opportunity__r.OwnerId).User_Id__c != null ? userMap.get(app.Opportunity__r.OwnerId).User_Id__c.substringBefore('_') : '' ;  
            }
            this.TBMCustomer.Ration_Card_No='' ;
            this.TBMCustomer.RationCard_Verified ='';
            this.TBMCustomer.RationCard_Verified_On=null ;
            this.TBMCustomer.RationCard_Verified_By='' ;
            this.TBMCustomer.BSR_Code='95012' ;
            this.TBMCustomer.Active_Flag ='Y'; 
            this.TBMCustomer.Off_Applicable='Y' ;
            this.TBMCustomer.Off_Name=null;
            this.TBMCustomer.Emp_No = '';
            if(!finalTerm.isEmpty()){
                this.TBMCustomer.Emp_No=finalTerm[0].EMP_No__c ;    
            }
            this.TBMCustomer.Per_Address_Flag='R' ;
            this.TBMCustomer.Contact_Person=app.Name;
            this.TBMCustomer.Resi_Proof='0' ;
            this.TBMCustomer.Nature_Age_proof='10' ;
            //CISP-2940-START
            if(String.isNotBlank(app.Customer_Last_Name__c)){
                this.TBMCustomer.SurName=app.Customer_Last_Name__c ;
            }else{
                this.TBMCustomer.SurName = String.isBlank(app.Father_s_name__c) ? '' : app.Father_s_name__c;
            }
            // CISP-2940-END
            this.TBMCustomer.Department='';
            this.TBMCustomer.Designation='';
            this.TBMCustomer.Place_Of_Posting='' ;
            this.TBMCustomer.Date_Of_Joining='' ;
            this.TBMCustomer.Date_Of_Retirement='';
            this.TBMCustomer.Salary_Date='';
            if(!cibil.isEmpty()){
                this.TBMCustomer.Referal_no=cibil[0].CIC_No__c ;
                this.TBMCustomer.Referal_date=cibil[0].CreatedDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
                
                this.TBMCustomer.Credit_score=cibil[0].Score__c;
            }else{
                if(!((app.Opportunity__r.Is_Pre_Approved__c && app.Opportunity__r.LeadSource == 'D2C') || (app.Opportunity__r.Product_Type__c == 'Tractor' && app.Opportunity__r.Customer_Type__c == 'Non-Individual'))) { //SFTRAC-395
                    throw new IND_Exception(System.Label.CIBILDetailsDataMissing);
                }
                //throw new IND_Exception(System.Label.CIBILDetailsDataMissing);
            }
            this.TBMCustomer.Report_score='1.000';    
            this.TBMCustomer.Religion=religion;
            this.TBMCustomer.Caste=caste;
            String preferedAddress = app.Preferred_address_for_communication__c == null ? '' : app.Preferred_address_for_communication__c;
            this.TBMCustomer.Commn_Address_Flag= preferedAddress == 'Permanent Address' ? 'P' : preferedAddress == 'Residence Address' ? 'R' : preferedAddress == 'Office Address' ? 'O' : '';
            
            this.TBMCustomer.Source=System.Label.Salesforce ;
            this.TBMCustomer.Marital_Status=app.Marital_status__c ;
           if(!this.isNonIndividualTractor){  
            this.TBMCustomer.Regn_Incorp_Date=null ;
           }
            if(app.Opportunity__r.Product_Type__c == 'Tractor'){
                 if(!incdetails.isEmpty()) {
                    this.TBMCustomer.Estimated_Annual_Income= String.valueof(incdetails[0].Income__c) ;
                } else {
                    this.TBMCustomer.Estimated_Annual_Income = '0'; 
                }
               this.TBMCustomer.Customer_profile = app.Profile__c !=null ? Utilities.getProfileCode(app.Profile__c) : '';
            }
            else{
                if(!incdetails.isEmpty()) {
                    this.TBMCustomer.Estimated_Annual_Income= String.valueof(incdetails[0].Income__c) ;
                    this.TBMCustomer.Customer_profile = incdetails[0].Profile__r.Code__c;
                } else {
                    this.TBMCustomer.Estimated_Annual_Income = '0'; 
                    this.TBMCustomer.Customer_profile = app.Profile__c; //CISP-2456,CISP-2438,CISP-2380
                }
                
            }
            this.TBMCustomer.Average_Annual_Turnover='' ;
            this.TBMCustomer.Disability='' ;
            this.TBMCustomer.CKYC_ID='' ;
            this.TBMCustomer.Customer_Category = incdetails.isEmpty() == true ? 'NE' : incdetails[0].Profile__r.Category__c;
            //dt.Customer_Code='CW4897914';
             //CISP-13605 start
             if(this.TBMCustomer.PAN_Verified=='' || this.TBMCustomer.PAN_Verified != 'Y'){ // CISP-20540 // Added check to not override Active PAN data.
            Map<Id,Documents__c> inactivePanDocuments = new Map<Id,Documents__c>([SELECT KYC_No__c,PAN_No__c,KYC_Name__c,Document_Type__c,AadhaarSeedingStatus__c,createdDate
                                                                       FROM Documents__c WHERE Applicant__c = :app.Id and is_Active__c = false AND Document_Type__c != null and Document_Type__c = 'PAN' WITH SECURITY_ENFORCED]);
            
            if(!inactivePanDocuments.isEmpty()){
                for(Documents__c doc : inactivePanDocuments.values()){
                    this.TBMCustomer.PAN_GIR_Number= '';
                    this.TBMCustomer.PAN_Holder_Name= '';
                    this.TBMCustomer.PAN_Aadhaar_Seeding_Flag =  '';   
                    this.TBMCustomer.PAN_Verified_By = '';
                    this.TBMCustomer.PAN_Verified_On = '';

                }
            }//CISP-13605 end
        }
            
            
            

            if(this.isNonIndividualTractor){
                this.TBMCustomer.Customer_Salutation = 'MR';
                this.TBMCustomer.Customer_Qualification = '';
                this.TBMCustomer.Marital_Status='UNMAR';
                if(String.isBlank(this.TBMCustomer.Customer_profile)){
                    this.TBMCustomer.Customer_profile =app.Opportunity__r.Profile__c !=null ? Utilities.getProfileCode(app.Opportunity__r.Profile__c) : '';
                }
                this.TBMCustomer.Customer_sex = 'M';
            }       
            if(app.Opportunity__r.Product_Type__c == 'Tractor' && (String.isBlank(this.TBMCustomer.Customer_profile))){
                this.TBMCustomer.Customer_profile = app.Profile__c !=null ? Utilities.getProfileCode(app.Profile__c) : ''; 
            }    
            
            validate(System.Label.CustomerMasterCreation);    
        }
    }
    /*
    @Method:      getHttpRequestHeaders
    @Created by:  Kranthi Makkena
    @Description: Method to get the HTTP request header data
    @Param:       ''
    @Return:      Header required to callout the service.*/
    
    public override Map<String,String> getHttpRequestHeaders(){    
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }

    /*
    @Method:      validate
    @Created by:  Kranthi Makkena 
    @Description: Method to validate the required input details
    @Param:       Service name
    @Return:      True - If all the validations are passed.*/
    public override boolean validate(String serviceName){
        /*
if(String.isBlank(this.TBMCustomer.Customer_Code)){
throw new IND_Exception(System.Label.CustomerCode);
}*/
        if(String.isBlank(this.TBMCustomer.Customer_Type)){
            throw new IND_Exception(System.Label.CustomerType);
        } 
        if(String.isBlank(this.TBMCustomer.Customer_Salutation) && !(this.isNonIndividualTractor)){ //SFTRAC-395
            throw new IND_Exception(System.Label.CustomerSalutation);
        }
        if(String.isBlank(this.TBMCustomer.Customer_Name )){
            throw new IND_Exception(System.Label.CustomerName);
        }
        if(String.isBlank(this.TBMCustomer.Customer_sex) && !(this.isNonIndividualTractor)){ //SFTRAC-395
            throw new IND_Exception(System.Label.Gender);
        }
        if(String.isBlank(this.TBMCustomer.Communication_Language)){
            throw new IND_Exception(System.Label.Language );
        }
        if(String.isBlank(this.TBMCustomer.Customer_Qualification) && !(this.isNonIndividualTractor)){ //SFTRAC-395
            throw new IND_Exception(System.Label.CustomerQualification );
        }
        if(String.isBlank(this.TBMCustomer.Father_Husband_Name) && !(this.isNonIndividualTractor)){ //SFTRAC-395
            throw new IND_Exception(System.Label.FatherName );
        }
        if(String.isBlank(this.TBMCustomer.Mother_Name) && !(this.isNonIndividualTractor)){ //SFTRAC-395
            throw new IND_Exception(System.Label.MotherName);
        }
        if(String.isBlank(this.TBMCustomer.Date_of_Birth) && !(this.isNonIndividualTractor)){ //SFTRAC-395
            throw new IND_Exception(System.Label.DateOfBirth );
        }
        
        if(String.isBlank(this.TBMCustomer.Base_Location)){
            throw new IND_Exception(System.Label.BaseLocation );
        }
        if(String.isBlank(this.TBMCustomer.Maker_Id)){
            throw new IND_Exception(System.Label.MakerId);
        } 
        if(String.isBlank(this.TBMCustomer.BSR_Code)){
            throw new IND_Exception(System.Label.BSR_Code );
        }
        if(String.isBlank(this.TBMCustomer.Active_Flag)){
            throw new IND_Exception(System.Label.Active_Flag );
        }
        if(String.isBlank(this.TBMCustomer.Per_Address_Flag)){
            throw new IND_Exception(System.Label.Per_Address_Flag );
        }
        if(String.isBlank(this.TBMCustomer.Contact_Person)){
            throw new IND_Exception(System.Label.ContactPerson );
        }
        if(String.isBlank(this.TBMCustomer.Nature_Resi_proof) && !((this.isPreApprovedJourney && this.isD2C) || this.isNonIndividualTractor)){

            throw new IND_Exception(System.Label.Nature_Resi_proof );
        }
        if(String.isBlank(this.TBMCustomer.Resi_Proof) && !(this.isNonIndividualTractor)){ //SFTRAC-395
            throw new IND_Exception(System.Label.Resi_Proof );
        }
        if(String.isBlank(this.TBMCustomer.Nature_ID_proof) && !((this.isPreApprovedJourney && this.isD2C) || this.isNonIndividualTractor)){ //SFTRAC-395
            throw new IND_Exception(System.Label.Nature_ID_proof );
        }
        if(String.isBlank(this.TBMCustomer.Nature_Age_proof) && !(this.isNonIndividualTractor)){ //SFTRAC-395
            throw new IND_Exception(System.Label.Nature_Age_proof );
        }
        if(String.isBlank(this.TBMCustomer.SurName) && !(this.isNonIndividualTractor)){ //SFTRAC-395
            throw new IND_Exception(System.Label.SurName );
        }
        if(String.isBlank(this.TBMCustomer.Referal_no) && !((this.isPreApprovedJourney && this.isD2C) || this.isNonIndividualTractor)){ //SFTRAC-395
            throw new IND_Exception(System.Label.Referal_no );
        }
        if(String.isBlank(this.TBMCustomer.Referal_date) && !((this.isPreApprovedJourney && this.isD2C) || this.isNonIndividualTractor)){ //SFTRAC-395
            throw new IND_Exception(System.Label.Referal_date );
        }
        if(String.isBlank(this.TBMCustomer.Report_score) && !((this.isPreApprovedJourney && this.isD2C) || this.isNonIndividualTractor)){ //SFTRAC-395
            throw new IND_Exception(System.Label.Report_score );
        }
        if(String.isBlank(this.TBMCustomer.Religion) && !(this.isNonIndividualTractor)){ //SFTRAC-395
            throw new IND_Exception(System.Label.Religion );
        }
        if(String.isBlank(this.TBMCustomer.Caste) && !(this.isNonIndividualTractor)){ //SFTRAC-395
            throw new IND_Exception(System.Label.Caste );
        }
        if(String.isBlank(this.TBMCustomer.Commn_Address_Flag)){
            throw new IND_Exception(System.Label.Commn_Address_Flag );
        }
        if(String.isBlank(this.TBMCustomer.Credit_score) && !((this.isPreApprovedJourney && this.isD2C) || this.isNonIndividualTractor)){ //SFTRAC-395
            throw new IND_Exception(System.Label.Credit_score );
        }
        if(String.isBlank(this.TBMCustomer.Source)){
            throw new IND_Exception(System.Label.Source );
        }
        if(String.isBlank(this.TBMCustomer.Marital_Status) && !(this.isNonIndividualTractor)){ //SFTRAC-395
            throw new IND_Exception(System.Label.MarriageStatusError);
        }
        /*for(Integer i=0;i<CustomerDt.size();i++){
            if(String.isBlank(this.CustomerDt[i].Address_Line_1)){
                throw new IND_Exception(System.Label.Address_Line_1 );
            }
            if(String.isBlank(this.CustomerDt[i].Address_Line_2)){
                throw new IND_Exception(System.Label.Address_Line_2 );
            }
            if(String.isBlank(this.CustomerDt[i].Address_Line_3)){
                throw new IND_Exception(System.Label.Address_Line_3 );
            }
            if(String.isBlank(this.CustomerDt[i].Address_Line_4)){
                throw new IND_Exception(System.Label.Address_Line_4 );
            }
            if(String.isBlank(this.CustomerDt[i].City)){
                throw new IND_Exception(System.Label.City );
            }
            if(String.isBlank(this.CustomerDt[i].District)){
                throw new IND_Exception(System.Label.District );
            } 
            if(String.isBlank(this.CustomerDt[i].State)){
                throw new IND_Exception(System.Label.State );
            }  
            if(String.isBlank(this.CustomerDt[i].Pin_code)){
                throw new IND_Exception(System.Label.Pin_code );
            }
            
        }*/
        return true;
        
    }
    
}