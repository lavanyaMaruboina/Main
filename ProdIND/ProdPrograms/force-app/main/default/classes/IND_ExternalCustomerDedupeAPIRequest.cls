/*------------------------------------------------------------
Author:        Sharad Kathane 
Company:       Persistent Systems
Description:   This class is wrapper class for the External Customer Dedupe API.  
Test Class:    IND_ExternalCustomerDedupeService_Test 
History
Date            Author              Comments
-------------------------------------------------------------
28-10-2021      Sharad Kathane      Created
------------------------------------------------------------*/
public class IND_ExternalCustomerDedupeAPIRequest extends ParentAPIRequest{ 
    
    //Request paramaters for External Customer Dedupe request 
    public  String Application_Id ='';
    public  String Enquiry_Control_No ='';
    public  String Lead_Id ='';
    public  String CIC_No='';
    public  String Customer_Type ='';
    public  String Customer_Code ='';
    public  String Customer_Name ='';
    public  String SurName ='';
    public  String Date_of_Birth ='';
    public  String Customer_Sex ='';
    public  String Address_Line_1 ='';
    public  String Address_Line_2 ='';
    public  String Address_Line_3 ='';
    public  String Address_Line_4 ='';
    public  String City ='';
    public  String District ='';
    public  String State ='';
    public  String Pin_Code ='';
    public  String Address_Flag ='';
    public  String ADDRESS_P ='';
    public  String CITY_P ='';
    public  String PINCODE_P ='';
    public  String ADDRESS_O ='';
    public  String CITY_O ='';
    public  String PINCODE_O ='';
    public  String ADDRESS_R ='';
    public  String CITY_R ='';
    public  String PINCODE_R ='';
    public  String ISD_STD ='';
    public  String Phone_Number ='';
    public  String TELEPHONE2 ='';
    public  String TELEPHONE3 ='';
    public  String Mobile_Number ='';
    public  String MOBILE2 ='';
    public  String MOBILE3 ='';
    public  String Fax_No ='';
    public  String PAN_GIR_Number_1 ='';
    public  String PAN_Holder_Name_1 ='';
    public  String Passport_Number_1 ='';
    public  String Driving_License_Number_1 ='';
    public  String Voter_Id_Number_1 ='';
    public  String Ration_Card_No_1 ='';
    public  String Post_Office_Iden_No_1 ='';
    public  String AADHAR_Number_1 ='';
    public  String PAN_GIR_Number_2 ='';
    public  String PAN_Holder_Name_2 ='';
    public  String Passport_Number_2 ='';
    public  String Driving_License_Number_2 ='';
    public  String Voter_Id_Number_2 ='';
    public  String Ration_Card_No_2 ='';
    public  String Post_Office_Iden_No_2 ='';
    public  String AADHAR_Number_2 ='';
    public  String IBL_Account_No ='';
    public  String Customer_Salutation ='';
    public  String Father_Name ='';
    public  String Mother_Name ='';
    public  String Spouse_Name ='';
    public  String EMail_Address ='';
    public  String Religion ='';
    public  String Caste ='';
    public  String Base_Location ='';
    public  String CFD_Field1 ='';
    public  String CFD_Field2 ='';
    public  String CFD_Field3 ='';
    public  String CFD_Field4 ='';
    public  String CFD_Field5 ='';
    public  String CFD_Field6 ='';
    public  String CIN_Number ='';
    
    
    /*
@Method:      IND_ExternalCustomerDedupeAPIRequest
@Created by:  Divya Jawale
@Description: Contructor to initialize the details
@Param:       Object - Applicant__c ,Documents__c
@Return:      '' 
*/
    public IND_ExternalCustomerDedupeAPIRequest(Applicant__c app, List<Documents__c> docs,String loanAppId){
        
        if(app != null && docs[0] != null){
            String randomString = string.valueof(Math.abs(Crypto.getRandomLong()));
            this.Application_Id =String.valueOf(randomString.substring(0,13));
            String randomString1 = string.valueof(Math.abs(Crypto.getRandomLong()));
            this.Enquiry_Control_No = String.valueOf(randomString1.substring(0,13));
            this.Lead_Id = app.Opportunity__r.Lead_number__c != null ? app.Opportunity__r.Lead_number__c :'';
            this.Lead_Id = this.Lead_Id + '_' + app.applicant_number__c; //CISP-2879
            this.CIC_No =IntegrationUtilities.getCicNo();
            
            this.Customer_Type =app.Applicant_Type__c != null ? app.Applicant_Type__c :'';
            this.Customer_Code =app.Opportunity__r.Customer_Code__c != null ? app.Opportunity__r.Customer_Code__c :'';
            this.Customer_Name = (app.Customer_First_Name__c+ ' ' + app.Customer_Last_Name__c ) != null ? app.Customer_First_Name__c+ ' ' + app.Customer_Last_Name__c : '' ;
            this.SurName = app.Customer_Last_Name__c != null ? app.Customer_Last_Name__c :''; 
            this.AADHAR_Number_1 = '';
            for(Documents__c doc:docs){
                
                if( (doc.Document_Type__c == 'Pan' ||  doc.Document_Type__c == 'Driving Licence') || (doc.Document_Type__c == 'Passport' ||  doc.Document_Type__c == 'Voter Id') || doc.Document_Type__c=='Aadhaar' ){    
                    if(String.isBlank(this.Date_of_Birth)){
                        Datetime dateTimeDOB = (Datetime)doc.KYC_DOB__c;
                        this.Date_of_Birth = dateTimeDOB != null ? dateTimeDOB.format('dd-MM-yyyy') :''; 
                    }
                    if(String.isBlank(this.Customer_Sex)){ 
                        this.Customer_Sex = (doc.Gender__c != null && doc.Gender__c == 'MALE'?'M': doc.Gender__c == 'FEMALE'?'F' : doc.Gender__c == 'TRANSGENDER'?'T': '' );//requestWrapper.kycGender == null?'':requestWrapper.kycGender;//
                    }
                    if( String.isBlank(this.Address_Line_1)){ 
                        this.Address_Line_1 = doc.KYC_Address_Line_1__c != null ? doc.KYC_Address_Line_1__c : '' ;
                    }
                    if(String.isBlank(this.Address_Line_2)){
                        this.Address_Line_2 =doc.KYC_Address_Line_2__c != null ? doc.KYC_Address_Line_2__c :'' ;
                    }
                    if(String.isBlank(this.City)){   
                        this.City = doc.KYC_City__c != null ? doc.KYC_City__c : '' ;
                    }
                    if(String.isBlank(this.District)){  
                        this.District =doc.KYC_District__c != null ? doc.KYC_District__c : '';
                    }
                    if(String.isBlank(this.State)){  
                        this.State = doc.KYC_State__c != null ? doc.KYC_State__c : '';
                    }
                    if(String.isBlank(this.Pin_Code)){  
                        this.Pin_Code = doc.KYC_Pin_Code__c != null ? doc.KYC_Pin_Code__c :'';
                    }
                    if(String.isBlank(this.Customer_Salutation)){    
                        this.Customer_Salutation =doc.Salutation__c != null ? doc.Salutation__c.remove('.') : '';  
                    }
                    if(doc.Document_Type__c == System.Label.PanCards && String.isBlank(this.PAN_GIR_Number_1)){      
                        //this.PAN_GIR_Number_1 = doc.PAN_No__c != null ? doc.PAN_No__c : '';
                        /*CISP-14376: Change Start*/
                        if(doc.PAN_No__c != null && doc.PAN_No__c.length() > 10){
                            this.PAN_GIR_Number_1 = IntegrationUtilities.getDecryptedResponse(doc.PAN_No__c,System.Label.privateKey,System.Label.ivkey);//CISP-3038
                        }else if(doc.PAN_No__c != null && doc.PAN_No__c.length() == 10){
                            this.PAN_GIR_Number_1 = doc.PAN_No__c;
                        }
                        /*CISP-14376: Change End*/
                        
                    } 
                    if(String.isNotBlank(this.PAN_GIR_Number_1) && String.isBlank(this.PAN_Holder_Name_1)){     
                        this.PAN_Holder_Name_1 = doc.KYC_name__c != null ? doc.KYC_name__c : '' ;
                    }
                    if(doc.Document_Type__c == System.Label.PassportCard && String.isBlank(this.Passport_Number_1)){  
                        //this.Passport_Number_1 = doc.Passport_No__c != null ? doc.Passport_No__c : '' ;
                        this.Passport_Number_1 = doc.Passport_No__c != null ? IntegrationUtilities.getDecryptedResponse(doc.Passport_No__c,System.Label.privateKey,System.Label.ivkey) : '' ;//CISP-3038
                    }
                    if(doc.Document_Type__c == System.Label.DrivingLicences && String.isBlank(this.Driving_License_Number_1)){    
                        //this.Driving_License_Number_1 =doc.KYC_No__c != null ? doc.KYC_No__c : '';
                        this.Driving_License_Number_1 =doc.KYC_No__c != null ? IntegrationUtilities.getDecryptedResponse(doc.KYC_No__c,System.Label.privateKey,System.Label.ivkey) : '';//CISP-3038
                    }
                    if(doc.Document_Type__c == System.Label.VoterIdCard && String.isBlank(this.Voter_Id_Number_1)){ 
                        //this.Voter_Id_Number_1 = doc.KYC_No__c != null ? doc.KYC_No__c : '';
                        this.Voter_Id_Number_1 = doc.KYC_No__c != null ? IntegrationUtilities.getDecryptedResponse(doc.KYC_No__c,System.Label.privateKey,System.Label.ivkey) : '';//CISP-3038
                    }
                    /*
                    if(doc.Document_Type__c==System.Label.AadhaarCard && String.isBlank(this.AADHAR_Number_1)){ 
                        //this.AADHAR_Number_1 =  doc.KYC_No__c != null ? doc.KYC_No__c : '';
                        this.AADHAR_Number_1 =  doc.KYC_No__c != null ? IntegrationUtilities.getDecryptedResponse(doc.KYC_No__c,System.Label.privateKey,System.Label.ivkey) : '';//CISP-3038
                    }
                    */
                    if(doc.Document_Type__c=='Aadhaar'){
                        this.CFD_Field2 = doc.IND_Aadhaar_Vault_Token_ID__c != null ? doc.IND_Aadhaar_Vault_Token_ID__c : '';//vault changes
                    }
                }
            } 
            this.Mobile_Number = app.Contact_number__c != null ? app.Contact_number__c : '' ;
            this.Father_Name = app.Father_s_name__c != null ? app.Father_s_name__c :''; 
            this.Mother_Name = app.Mother_s_name__c != null ? app.Mother_s_name__c :'';
            this.Spouse_Name = app.Spouse_Name__c != null ? app.Spouse_Name__c :'';
            this.MOBILE2 = app.Whatsapp_number__c != null ? app.Whatsapp_number__c : '' ;//CISP-12049
			this.CFD_Field1 = app.Opportunity__r.Product_Type__c == 'Two Wheeler'?'H' : (app.Opportunity__r.Product_Type__c == 'Passenger Vehicles' ?'C' :'');
           
        }
        
        validate(System.Label.ExternalCustomerDedupeAPI);
    }
    
    /*Method to validate the request data
@Method:      validate
@Created by:  Divya Jawale
@Description: Method to validate the required input details
@Param:       Service name
@Return:      True - If all the validations are passed.
*/
    public override boolean validate(String serviceName){
        if(String.isBlank(this.Application_Id)){
            throw new IND_Exception(System.Label.ApplicationId);
        }
        if(String.isBlank(this.Enquiry_Control_No)){
            throw new IND_Exception(System.Label.EnquiryControlNo);
        }
        if(String.isBlank(this.Lead_Id)){
            throw new IND_Exception(System.Label.ApplicationNo);
        }
        if(String.isBlank(this.CIC_No)){
            throw new IND_Exception(System.Label.CICNo);
        }
        return true;
    }
    
    /*Method to get the HTTP request header data
@Method:      getHttpRequestHeaders
@Created by:  Divya Jawale
@Description: Method to get the HTTP request header data
@Param:       ''
@Return:      Header required to callout the service.
*/
    public override Map<String,String> getHttpRequestHeaders(){
        //Map to store HTTP request header data
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
        //requestheadermap is used to fetch the request from client
    }
    
}