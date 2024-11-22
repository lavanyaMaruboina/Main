/*------------------------------------------------------------
Author:        Manish Baldota
Company:       Persistent Systems
Description:   This class is wrapper class for the Perfios Bank Statement genrate link API request 
Test Class:    
History
Date            Author              Comments
-------------------------------------------------------------
12-21-2021      Manish Baldota      Created
01-11-2022		Manish Baldota 		Request format changes based on revised document
------------------------------------------------------------*/
public class IND_PerfiosBSGenerateLinkRequest extends ParentAPIRequest {
    public payload payload {get;set;}   
    // @Method:      IND_PerfiosBSGenerateLinkRequest
    // @Created by:  Manish Baldota
    // @Description: Contructor to initialize the details
    // @Param:       ''
    // @Return:      ''
    public IND_PerfiosBSGenerateLinkRequest(RequestWrapper requestWrapper, string executivemobileno){  
        if(requestWrapper != null){
            payload payloadElement = new payload();
            payloadElement.Lead_Id =  requestWrapper.incomeDetails.Applicant__r.Opportunity__r.Lead_number__c + '_' + requestWrapper.incomeDetails.Applicant__r.applicant_number__c;//CISP-2879
            payloadElement.emailId = requestWrapper.incomeDetails.Applicant__r.Email_Id__c;
            //payloadElement.MobileNumber = requestWrapper.incomeDetails.Applicant__r.Contact_number__c;
            payloadElement.MobileNumber = executivemobileno!=null && !string.isEmpty(executivemobileno)? executivemobileno:requestWrapper.incomeDetails.Applicant__r.Contact_number__c; //CISP 2973: Added executivemobileno as a parameter
             system.debug('The mobile no sending in paramente'+ payloadElement.MobileNumber);
            payloadElement.loanDuration = String.valueOf(requestWrapper.incomeDetails.Applicant__r.Opportunity__r.Required_Tenure__c);
            String amt = requestWrapper.incomeDetails.Applicant__r.Opportunity__r.Loan_amount__c;
            if(amt != null){
                Decimal strToDec = decimal.valueOf(amt);
                Integer iAmt = strToDec.intValue();
                payloadElement.loanAmount = String.valueOf(iAmt);
            } else {
                payloadElement.loanAmount = '';
            }
            
            payloadElement.loanType = System.label.VehicleLoanType;
            payloadElement.acceptancePolicy = 'atLeastOneTransactionInRange';
            payloadElement.destination = requestWrapper.bankType;
            payloadElement.productType = 'CV';
            payloadElement.Unit = 'CFD'; 
            payloadElement.Sub_Unit = 'CV';
            payloadElement.Is_SMS_Required = 'No';
            payloadElement.Maker_Id = IntegrationUtilities.getMakerId();
            payloadElement.yearMonthFrom = requestWrapper.incomeDetails.From_Month__c; 
            payloadElement.yearMonthTo = requestWrapper.incomeDetails.To_Month__c;
            payloadElement.employmentType = requestWrapper.incomeDetails.Is_Salaried__c ? System.label.salaried : requestWrapper.incomeDetails.Is_Self_Employed__c ? system.label.SelfEmployed:'';//This should be come from Applicant Object
            payloadElement.employerName = requestWrapper.incomeDetails.Employer_Business_Name__c;
            payloadElement.returnUrl = 'https://www.indusind.com/in/en/personal.html';
            payloadElement.Source = 'Salesforce';
            this.payload = payloadElement;
            
            validate(System.label.PerfiosBSGenerateLink);
        }else{
            throw new IND_Exception('Please provide applicant details/ fetching method.');
        }    
    }
    // @Method:      getHttpRequestHeaders
    // @Created by:  Manish Baldota
    // @Description: Method to get the HTTP request header data
    // @Param:       ''
    // @Return:      Header required to callout the service.
    public override Map<String,String> getHttpRequestHeaders(){    
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }
    
    // @Method:      validate
    // @Created by:  Manish Baldota
    // @Description: abstract Method to validate the required input details
    // @Param:       Service name
    // @Return:      True - If all the validations are passed.
    public override boolean validate(String serviceName){
        if(String.isBlank(this.payload.emailId)){
            throw new IND_Exception(System.Label.emailIdError);
        }
        if(String.isBlank(this.payload.loanDuration)){
            throw new IND_Exception(System.Label.LoanDuration_Error);
        }
        if(String.isBlank(this.payload.loanAmount)){
            throw new IND_Exception(System.Label.Amountmessage);
        }
        if(String.isBlank(this.payload.destination)){
            throw new IND_Exception('Please provide Netbanking/Upload option to fetch the bank statement details.');
        }
        if(String.isBlank(this.payload.yearMonthFrom)){
            throw new IND_Exception(System.Label.year_month_Error);
        }
        if(String.isBlank(this.payload.yearMonthTo)){
            throw new IND_Exception(System.Label.year_month_Error);
        }
        if(String.isBlank(this.payload.employmentType)){
            throw new IND_Exception(System.Label.Employment_Details_Error);
        }
        if(String.isBlank(this.payload.employerName)){
            throw new IND_Exception(System.Label.Employment_Details_Error);
        }
        if(String.isBlank(this.payload.returnUrl)){
            throw new IND_Exception(System.Label.Lead_IDError);
        }
        return true;
    }
    
    public class payload{
        public string Lead_Id {get;set;}
        public String emailId {get;set;}
        public String MobileNumber {get;set;}
        public String loanDuration {get;set;}
        public String loanAmount {get;set;}
        public String loanType {get;set;}
        public String acceptancePolicy {get;set;}
        public String destination {get;set;}
        public String productType {get;set;}
        public String Unit {get;set;}
        public String Sub_Unit {get;set;}
        public String Is_SMS_Required {get;set;}
        public String Maker_Id {get;set;}
        public String yearMonthFrom {get;set;}
        public String yearMonthTo {get;set;}
        public String employmentType {get;set;}
        public String employerName {get;set;}
        public String returnUrl {get;set;}
        public String Source {get;set;}
    }
}