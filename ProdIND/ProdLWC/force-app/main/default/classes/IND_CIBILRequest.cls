/*------------------------------------------------------------
Author:        Divya Jawale
Company:       Salesforce
Description:   This class is wrapper class for the CIBIL request 
Test Class:    IND_CIBILRequestTest 
History
Date            Author              Comments
-------------------------------------------------------------
27-10-2021      Divya Jawale       Created
------------------------------------------------------------*/
public class IND_CIBILRequest extends ParentAPIRequest {
    //request paramaters for CIBIL request
    public String CIC_No ='';
    public String Report_To_Be_Generated_For ='';
    public String Company_Name ='';
    public String PAN_Valid ='';
    public String Lead_Id  ='';
    public String Old_Lead_Id  ='';
    public String Name  ='';
    public String DOB  ='';
    public String Gender  ='';
    public String Enquiry_Amount  ='';
    public String Enquiry_Purpose ='';
    public String PAN  ='';
    public String Passport  ='';
    public String VoterId  ='';
    public String Driver_License  ='';
    public String Ration_Card  ='';
    public String TU_Score  ='';
    public String PL_Score  ='';
    public String Phone_1  ='';
    public String Phone_1_Type  ='';
    public String Phone_1_Extn  ='';
    public String Phone_2  ='';
    public String Phone_2_Type  ='';
    public String Phone_2_Extn  ='';
    public String Curr_Add  ='';
    public String Curr_Add1  ='';
    public String Curr_Location  ='';
    public String Curr_Add_State  ='';
    public String Curr_Add_PinCode  ='';
    public String Curr_Add_Category  ='';
    public String Curr_Add_Res_Code  ='';
    public String Curr_Per_Add_Same  ='';
    public String Per_Add  ='';
    public String Per_Add1  ='';
    public String Per_Location  ='';
    public String Per_Add_State  ='';
    public String Per_Add_PinCode  ='';
    public String Per_Add_Category  ='';
    public String Per_Add_Res_Code  ='';
    public String User_Id  ='';
    public String Customer_Type  ='';
    public String Existing_Customer_Code  ='';
    public String Enquiry_For  ='';
    public String Product  ='';
    public String Channel_Type  ='';
    public String Base_Location  ='';
    public String Customer_Salutation  ='';
    public String Last_Name  ='';
    public String Father_Name  ='';
    public String Mother_Name  ='';
    public String Spouse_Name  ='';
    public String Religion  ='';
    public String Caste  ='';
    public String Email  ='';
    public String Curr_Add2  ='';
    public String Curr_Add3  ='';
    public String Curr_Add_District  ='';
    public String Per_Add2  ='';
    public String Per_Curr_Add3  ='';
    public String Per_Curr_Add_District  ='';
    public String Phone_1_STD  ='';
    public String Phone_2_STD  ='';
    public String PAN_Holder_Name  ='';
    public String Aadhar_No  ='';
    public String Account_Number_1  ='';
    public String Account_Number_2  ='';
    public String Account_Number_3  ='';
    public String Account_Number_4  ='';
    public String Request_Source  ='';
    public String Post_Office_ID  ='';
    
    /*
@Method:      IND_CIBILRequest
@Created by:  Divya Jawale
@Description: Contructor to initialize the details
@Param:       Object - Applicant__c and Documents__c
@Return:      '' 
*/
    public IND_CIBILRequest(Applicant__c app, List<Documents__c> docs, String loanAppId, List<CIBIL_Details__c> cibilDetails, String customer_Code, String cicNo){
       
        if( app != null && docs != null){
            if(String.isNotBlank(cicNo)){
                this.CIC_No = cicNo;
            }else{
                this.CIC_No =IntegrationUtilities.getCicNo();
            }
            
            if(cibilDetails != null && !cibilDetails.isEmpty()){
                System.debug('inside if!!');
                for(CIBIL_Details__c cibildtl : cibilDetails){
                    System.debug('inside for!!');
            this.Report_To_Be_Generated_For =(cibildtl.CIBIL_Report_URl__c != null && cibildtl.Equifax_Report_URl__c != null) ? 'CIBIL_EQUIFAX': cibildtl.CIBIL_Report_URl__c != null ? 'EQUIFAX':cibildtl.Equifax_Report_URl__c != null ? 'CIBIL' : 'CIBIL_EQUIFAX' ;
             }
            }
           else{
               System.debug('inside else!!');
            this.Report_To_Be_Generated_For =  'CIBIL_EQUIFAX';
           }    
            this.Company_Name ='';
            this.PAN_Valid ='Y';
            //this.Lead_Id  = app.Opportunity__r.Lead_number__c != null ? app.Opportunity__r.Lead_number__c :'';
            this.Lead_Id  = app.Opportunity__r.Lead_number__c != null ? app.Opportunity__r.Lead_number__c +'_'+app.applicant_number__c :'';
            Opportunity opp = [Select Id,Parent_Loan_Application__c,Parent_Loan_Application__r.Lead_Number__c From Opportunity Where Id =: loanAppId WITH SECURITY_ENFORCED LIMIT 1];
            if(opp.Parent_Loan_Application__c != null && app.Name != null){
                List<Applicant__c> appList = new List<Applicant__c>([Select Id,applicant_number__c From Applicant__c WHERE Opportunity__c =: opp.Parent_Loan_Application__c AND Name =: app.Name AND Applicant_Type__c =: app.Applicant_Type__c WITH SECURITY_ENFORCED LIMIT 1]);
                if(appList.size() > 0){
                    this.Old_Lead_Id = opp.Parent_Loan_Application__r.Lead_number__c != null ? opp.Parent_Loan_Application__r.Lead_number__c +'_' + appList[0].applicant_number__c : '';
                }
            }
            if(app.Customer_First_Name__c != null && app.Customer_First_Name__c.length() <= 26){
                this.Name  =app.Customer_First_Name__c;
            }else if(app.Customer_First_Name__c != null && app.Customer_Last_Name__c.length() > 26){
                this.Name  =app.Customer_First_Name__c.left(26);
            }else{
                this.Name  = app.Customer_First_Name__c != null ? app.Customer_First_Name__c : '' ;
            }
            
             for(Documents__c doc:docs){
               //CISP-4027
                if(doc.recordtype.name == 'KYC Document' && doc.Proof_of_Identity_POI__c==true){
                    if(String.isBlank(this.DOB) && doc.KYC_DOB__c !=null){
                        Datetime dOBDate = (Datetime)doc.KYC_DOB__c;
                        this.DOB  = dOBDate != null ? dOBDate.format('ddMMyyyy') : '' ;
                    }
                }
                //CISP-4027
                if( (doc.Document_Type__c == System.Label.PanCard ||  doc.Document_Type__c == System.Label.DrivingLicences) || (doc.Document_Type__c == System.Label.PassportCard ||  doc.Document_Type__c == System.Label.VoterIdCard) || doc.Document_Type__c== System.Label.AadhaarCard ){    
                    if(String.isBlank(this.Gender)){ 
                        this.Gender = (doc.Gender__c != null && doc.Gender__c == 'FEMALE'?'1': doc.Gender__c == 'MALE'?'2' : doc.Gender__c == 'TRANSGENDER'?'3': '' );
                    }
                    if( String.isBlank(this.Curr_Add)){ 
                        this.Curr_Add = doc.KYC_Address_Line_1__c != null ? doc.KYC_Address_Line_1__c.toUppercase() : '' ;
						Integer maxSize = 40;
                        Integer minSize = 4;//CISP-2923
						if(doc.KYC_Address_Line_1__c != null && doc.KYC_Address_Line_1__c.length() > maxSize){
                           this.Curr_Add =  doc.KYC_Address_Line_1__c.substring(0, maxSize);
                        }
                        //CISP-2923-START
                        else if(doc.KYC_Address_Line_1__c != null && doc.KYC_Address_Line_1__c.length() < minSize){
                            this.Curr_Add = ('House No. : ' + (String.isBlank(doc.KYC_Address_Line_1__c) ? '' : doc.KYC_Address_Line_1__c)).trim();
                        }
                        //CISP-2923-END
                    }
                    if(String.isBlank(this.Curr_Add1)){
                        this.Curr_Add1 =doc.KYC_Address_Line_2__c != null ? doc.KYC_Address_Line_2__c.toUppercase() :'' ;
						Integer maxSize = 40;
                        Integer minSize = 4;//CISP-2923
						if(doc.KYC_Address_Line_2__c != null && doc.KYC_Address_Line_2__c.length() > maxSize){
                           this.Curr_Add1 =  doc.KYC_Address_Line_2__c.substring(0, maxSize);
                        }
                        //CISP-2923-START
                        else if(doc.KYC_Address_Line_2__c != null &&  doc.KYC_Address_Line_2__c.length() < minSize){
                            this.Curr_Add1 = ('Apartment Name : ' + (String.isBlank(doc.KYC_Address_Line_2__c) ? '' : doc.KYC_Address_Line_2__c)).trim();
                        }
                        //CISP-2923-END
                    }
                    if(String.isBlank(this.Curr_Location)){   
                        this.Curr_Location = doc.KYC_City__c != null ? doc.KYC_City__c.toUppercase() :'';
                    }
                    if(String.isBlank(this.Curr_Add_State))
                    { 
                        //Bug CISP 2: TW - CIBIL - Not able to generate CIBIL
                        if(doc.KYC_State__c != null && doc.KYC_State__c =='PUDUCHERRY')
                        {
                            this.Curr_Add_State ='PONDICHERRY';  
                        }
                        else
                        {
                            this.Curr_Add_State = doc.KYC_State__c != null ? doc.KYC_State__c.toUppercase() :'';
                        }
                    }
                    if(String.isBlank(this.Curr_Add_PinCode)){  
                        this.Curr_Add_PinCode = doc.KYC_Pin_Code__c != null ? doc.KYC_Pin_Code__c :'';
                    }
                    if(String.isBlank(this.Customer_Salutation)){    
                        this.Customer_Salutation = doc.Salutation__c != null ? doc.Salutation__c.remove('.') : '';  
                    }
                     if( String.isBlank(this.Per_Add)){ 
                        this.Per_Add = doc.KYC_Address_Line_1__c != null ? doc.KYC_Address_Line_1__c.toUppercase() :'';
						Integer maxSize = 40;
						if(doc.KYC_Address_Line_1__c != null && doc.KYC_Address_Line_1__c.length() > maxSize){
                           this.Per_Add =  doc.KYC_Address_Line_1__c.substring(0, maxSize);
                        }
                    }
                     if(String.isBlank(this.Per_Add1)){
                        this.Per_Add1 =doc.KYC_Address_Line_2__c != null ? doc.KYC_Address_Line_2__c.toUppercase() :'' ;
						Integer maxSize = 40;
						if(doc.KYC_Address_Line_2__c != null && doc.KYC_Address_Line_2__c.length() > maxSize){
                           this.Per_Add1 =  doc.KYC_Address_Line_2__c.substring(0, maxSize);
                        }
                    }
                    if(String.isBlank(this.Per_Location)){   
                        this.Per_Location = doc.KYC_City__c != null ? doc.KYC_City__c.toUppercase() :'';
                    }
                     if(String.isBlank(this.Per_Add_State))  
                    {  
                          ////Bug CISP 2: TW - CIBIL - Not able to generate CIBIL
                        
                        if(doc.KYC_State__c != null && doc.KYC_State__c =='PUDUCHERRY')
                        {
                            this.Per_Add_State ='PONDICHERRY';
                        }
                        else
                        {
                            this.Per_Add_State = doc.KYC_State__c !=null ? doc.KYC_State__c.toUppercase() :'';
                        }
                        
                    }
                    if(String.isBlank(this.Per_Add_PinCode)){  
                        this.Per_Add_PinCode = doc.KYC_Pin_Code__c != null ? doc.KYC_Pin_Code__c :'';
                    }
                    if((doc.Document_Type__c == System.Label.PanCard && String.isBlank(this.PAN))){
                    //this.PAN =  doc.PAN_No__c != null ? doc.PAN_No__c : '';
                    this.PAN =  doc.PAN_No__c != null ? IntegrationUtilities.getDecryptedResponse(doc.PAN_No__c,System.Label.privateKey,System.Label.ivkey) : '';//CISP-3038
                     }
                    else if(doc.Document_Type__c == System.Label.PassportCard && String.isBlank(this.Passport)){
                    //this.Passport = doc.Passport_No__c != null ? doc.Passport_No__c : '' ;
                    this.Passport = doc.Passport_No__c != null ? IntegrationUtilities.getDecryptedResponse(doc.Passport_No__c,System.Label.privateKey,System.Label.ivkey) : '' ;//CISP-3038
                    }
                    else if(doc.Document_Type__c == System.Label.DrivingLicences && String.isBlank(this.Driver_License)){
                    //this.Driver_License = doc.KYC_No__c != null ? doc.KYC_No__c : '' ;
                    this.Driver_License = doc.KYC_No__c != null ? IntegrationUtilities.getDecryptedResponse(doc.KYC_No__c,System.Label.privateKey,System.Label.ivkey) : '' ;//CISP-3038
                    }
                    else if(doc.Document_Type__c == System.Label.VoterIdCard && String.isBlank(this.VoterId)){//CISP-3162
                     //this.VoterId =  doc.Document_Type__c == System.Label.VoterIdCard && doc.KYC_No__c != null ? doc.KYC_No__c : '' ;
                     this.VoterId =  doc.Document_Type__c == System.Label.VoterIdCard && doc.KYC_No__c != null ? IntegrationUtilities.getDecryptedResponse(doc.KYC_No__c,System.Label.privateKey,System.Label.ivkey) : '' ;//CISP-3038
                    }
                    else if(doc.Document_Type__c== System.Label.AadhaarCard && String.isBlank(this.Aadhar_No)){
                        //this.Aadhar_No = doc.KYC_No__c != null ? doc.KYC_No__c : '' ;
                        this.Aadhar_No = doc.KYC_No__c != null ? IntegrationUtilities.getDecryptedResponse(doc.KYC_No__c,System.Label.privateKey,System.Label.ivkey) : '' ;//CISP-3038
                    }
                    if(doc.Document_Type__c == System.Label.PanCard && doc.KYC_name__c != null){
                        this.PAN_Holder_Name =  (String.isNotBlank(this.PAN)) && String.isBlank(this.PAN_Holder_Name) ? doc.KYC_name__c : '';
                    }
                    
                }
            }   
          
            this.Enquiry_Amount  =String.valueOf(app.Opportunity__r.Loan_amount__c) != null ? String.valueOf(app.Opportunity__r.Loan_amount__c) : '' ;
            this.Enquiry_Purpose  =app.Opportunity__r.Product_Type__c == 'Two Wheeler'?'13' : app.Opportunity__r.Product_Type__c == 'Passenger Vehicles' ?'01' : app.Opportunity__r.Product_Type__c == System.Label.Tractor ? '34' : '' ;
            this.Ration_Card ='';
            this.TU_Score  ='True'; 
            this.PL_Score  ='False'; 
            this.Phone_1  =app.Contact_number__c != null ? app.Contact_number__c :'';
            this.Phone_1_Type  ='2'; 
            this.Phone_1_Extn  ='0';
            this.Phone_2  =''; 
            this.Phone_2_Type  ='2';
            this.Phone_2_Extn  ='0';
            this.Curr_Add_Category  ='0'; 
            this.Curr_Add_Res_Code  ='0'; 
            this.Curr_Per_Add_Same  =app.Current_Same_As_Permanent__c ?'Yes':'No';
            this.Per_Add_Category  ='0';
            this.Per_Add_Res_Code  ='0';
            this.User_Id  =IntegrationUtilities.getMakerId();
            this.Customer_Type  =(app.Is_Existing_Customer__c != null && app.Is_Existing_Customer__c ? 'Existing Customer' :'New Customer');
            this.Existing_Customer_Code  =customer_Code;
            this.Enquiry_For  = app.Applicant_Type__c != null ? app.Applicant_Type__c :'';
            this.Product  = app.Opportunity__r.Product_Type__c == 'Two Wheeler'?'H' : app.Opportunity__r.Product_Type__c == 'Passenger Vehicles' ?'C' : app.Opportunity__r.Product_Type__c == System.Label.Tractor ? 'T' : '' ;
            this.Channel_Type  ='MA';
            this.Base_Location  =app.Opportunity__r.account.name != null ? app.Opportunity__r.account.name :''; 
            if(app.Customer_Last_Name__c != null && app.Customer_Last_Name__c.length() <= 26){
                this.Last_Name  =app.Customer_Last_Name__c;
            }else if(app.Customer_Last_Name__c != null && app.Customer_Last_Name__c.length() > 26){
                this.Last_Name  =app.Customer_Last_Name__c.left(26);
            }else{
                this.Last_Name  =app.Customer_Last_Name__c != null ? app.Customer_Last_Name__c :'';
            }
            this.Father_Name  =app.Father_s_name__c != null ? app.Father_s_name__c : '';
            this.Mother_Name  =app.Mother_s_name__c != null ? app.Mother_s_name__c : '';
            this.Spouse_Name  =app.Spouse_Name__c != null ? app.Spouse_Name__c : '';
            this.Religion  =''; 
            this.Caste ='';
            this.Email =app.Email_Id__c !=null ? app.Email_Id__c : '';
            this.Curr_Add2 ='';
            this.Curr_Add3  =''; 
            this.Curr_Add_District  =''; 
            this.Per_Add2  =''; 
            this.Per_Curr_Add3  ='';
            this.Per_Curr_Add_District  =''; 
            this.Phone_1_STD  ='0';
            this.Phone_2_STD  ='0';
            this.Account_Number_1  ='';
            this.Account_Number_2  ='';
            this.Account_Number_3 ='';
            this.Account_Number_4  ='';
            this.Request_Source ='SF';
            this.Post_Office_ID  ='';

            if(String.isBlank(this.Curr_Add1)){
                this.Curr_Add1 = this.Curr_Add;
            }
        }
       validate(System.Label.GetCIBILReportAPI);
    }
    
/*Method to get the HTTP request header data
@Method:      getHttpRequestHeaders
@Created by:  Divya Jawale
@Description: Method to get the HTTP request header data
@Param:       ''
@Return:      Header required to callout the service.
*/
    public override Map<String,String> getHttpRequestHeaders(){    
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }
    
    /*Method to validate the request data
@Method:      validate
@Created by:  Divya Jawale
@Description: Method to validate the required input details
@Param:       Service name
@Return:      True - If all the validations are passed.
*/
    public override boolean validate(String serviceName){
        List<String> errorMessageList = new List<String>();
       if(String.isBlank(this.CIC_No )){
            throw new IND_Exception(System.Label.CICNo);
        }
        if(String.isBlank(this.Lead_Id)){
            throw new IND_Exception(System.Label.LeadId);
        }
        if(String.isBlank(this.Name )){
            throw new IND_Exception(System.Label.CustomerName);
        }
        if(String.isBlank(this.DOB)){
            throw new IND_Exception(System.Label.DateOfBirth);
        }
        if(String.isBlank(this.Gender)){
            throw new IND_Exception(System.Label.Gender);
        }
         if(String.isBlank(this.Enquiry_Amount )){
            throw new IND_Exception(System.Label.EnquiryAmount);
        }
        if(String.isBlank(this.Enquiry_Purpose)){
            throw new IND_Exception(System.Label.EnquiryPurpose);
        }
        if(String.isBlank(this.Phone_1 )){
            throw new IND_Exception(System.Label.Phone);
        }
        if(String.isBlank(this.Phone_1_Type)){
            throw new IND_Exception(System.Label.PhoneType);
        }
        if(String.isBlank(this.Curr_Add)){
            throw new IND_Exception(System.Label.CurrAdd);
        }
         if(String.isBlank(this.Curr_Add1 )){
            throw new IND_Exception(System.Label.CurrentAddress1);
        }
        if(String.isBlank(this.Curr_Location)){
            throw new IND_Exception(System.Label.CurrLocation);
        }
        if(String.isBlank(this.Curr_Add_State )){
            throw new IND_Exception(System.Label.CurrentAddressState);
        }
        if(String.isBlank(this.Curr_Add_PinCode)){
            throw new IND_Exception(System.Label.CurrentAddressPinCode);
        }
        if(String.isBlank(this.Curr_Per_Add_Same)){
            throw new IND_Exception(System.Label.CurrPerAddSame);
        }
         if(String.isBlank(this.User_Id)){
            throw new IND_Exception(System.Label.UserId);
        }
        if(String.isBlank(this.Customer_Type)){
            throw new IND_Exception(System.Label.CustomerType);
        }
        if(String.isBlank(this.Enquiry_For)){
            throw new IND_Exception(System.Label.EnquiryFor);
        }
        if(String.isBlank(this.Product)){
            throw new IND_Exception(System.Label.Product);
        }
         if(String.isBlank(this.Channel_Type )){
            throw new IND_Exception(System.Label.ChannelType);
        }
        if(String.isBlank(this.Base_Location)){
            throw new IND_Exception(System.Label.BaseLocation);
        }
        if(String.isBlank(this.Customer_Salutation )){
            throw new IND_Exception(System.Label.CustomerSalutation);
        }
        // CISP-2916-START
        // if(String.isBlank(this.Last_Name)){
        //     throw new IND_Exception(System.Label.LastName);
        // }
        // CISP-2916-END
        if(String.isBlank(this.Report_To_Be_Generated_For)){
            throw new IND_Exception(System.Label.ReportToBeGeneratedFor);
        }
        if(String.isBlank(this.PAN_Holder_Name ) && String.isNotBlank(this.PAN)){ 
            throw new IND_Exception(System.Label.PANHolderName);
        }
       
        return true;
    }
}