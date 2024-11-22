/*------------------------------------------------------------
Author: Bhushan Charde 
Company: Persistent Systems
Description: This class is wrapper class for the ENACH Registration Journey Request
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
12-28-2021    Bhushan Charde            Created
------------------------------------------------------------*/
public class IND_ENACHRegistrationJourneyRequest extends ParentAPIRequest {
	
    public Payload payload{get;set;}
	public String api_action{get;set;}
	public String created_at{get;set;}

	public class Payload {
		public Api_mandate api_mandate{get;set;}
	}

	public class Api_mandate {
		public String cifid{get;set;}
		public String accountnoordealno{get;set;}
		public String detcustomername{get;set;}
		public String detcustomerbank{get;set;}
		public String detcustomerifsc{get;set;}
		public String detcustomeracc{get;set;}
		public String startdate{get;set;}
		public String mobileno{get;set;}
		public String emailid{get;set;}
		public String enddate{get;set;}
		public String frequency{get;set;}
		public Decimal emiamount{get;set;}
		public String click2edit{get;set;}
		public String autopayfactor{get;set;}
		public String redirectURL{get;set;}
		public String referralCode{get;set;}
		public String appid{get;set;}
	}
    
    // @Method:      IND_ENACHRegistrationJourneyRequest
    // @Created by:  Bhushan Charde
    // @Description: Contructor to initialize the details
    // @Param:       Object applicant Record
    // @Return:   
     public IND_ENACHRegistrationJourneyRequest(Applicant__c app,String loanAppId, String dealId){
        List<Repayments__c> repayment=[SELECT Id,Repayment_to_be_done_by__c,Bank_Master__r.Name,IFSC_Code__c,Account_Number__c,Created_Date__c,End_Date__c,Frequency__c,EMI_Amount__c,Deal_Number__r.Deal_Number_Tractor__c FROM Repayments__c WHERE Loan_Application__c=:loanAppId AND Deal_Number__c=:dealId WITH SECURITY_ENFORCED];
        List<Opportunity> loanApplication=[SELECT id, Name, StageName, Parent_Loan_Application__c, Parent_Loan_Application__r.Name, Parent_Loan_Application__r.Is_Revoked__c,Parent_Loan_Application__r.StageName, Deal_Number__c, Product_Type__c FROM Opportunity WHERE id=:loanAppId WITH SECURITY_ENFORCED];//CISP-3030
      //  List<Exposure__c> exposure=[SELECT id,CIF_ID__c  FROM Exposure__c WHERE Loan_Application__c =:loanAppId WITH SECURITY_ENFORCED LIMIT 1];                               
        DateTime todaysDate = System.today();
        Boolean isProductTypePV = false;//CISP-3030
        if (loanApplication.size()>0  && loanApplication[0].Product_Type__c == 'Passenger Vehicles') {
            isProductTypePV = true;
        }  //CISP-3030
        String todaysDateStr = todaysDate.format('yyyy-MM-dd'); 
        if(app != null && !repayment.isEmpty() && !loanApplication.isEmpty()){
            this.payload = new Payload();
            this.payload.api_mandate = new Api_mandate();
            this.payload.api_mandate.cifid = app.Customer_Code__c;
            //CISP-4181 Send Loan_Application_Number__c instead of Deal_Number__c if current stage is Final Offer
            if(loanApplication[0].StageName == 'Final Offer') {
                //CISP-4181 If the parent lead is revoked or the parent leads journey is restarted
                if(loanApplication[0].Parent_Loan_Application__r.Is_Revoked__c || loanApplication[0].Parent_Loan_Application__r.StageName == 'Journey Restart') {
                    this.payload.api_mandate.accountnoordealno = loanApplication[0].Parent_Loan_Application__r.Name;
                } else {
                    this.payload.api_mandate.accountnoordealno = loanApplication[0].Name;
                }
            } else if(String.isNotBlank(dealId)){
                this.payload.api_mandate.accountnoordealno = repayment[0].Deal_Number__r.Deal_Number_Tractor__c;
            } else {
                this.payload.api_mandate.accountnoordealno = loanApplication[0].Deal_Number__c;
            }
            this.payload.api_mandate.detcustomername =repayment[0].Repayment_to_be_done_by__c;
            this.payload.api_mandate.detcustomerbank =repayment[0].Bank_Master__r.Name;
            this.payload.api_mandate.detcustomerifsc =repayment[0].IFSC_Code__c;
            this.payload.api_mandate.detcustomeracc =repayment[0].Account_Number__c; 
            this.payload.api_mandate.startdate = repayment[0].Created_Date__c !=null ? String.valueOf (repayment[0].Created_Date__c): null;
            this.payload.api_mandate.mobileno =app.Contact_number__c;
            this.payload.api_mandate.emailid =  String.isBlank(app.Email_Id__c) ? '' : app.Email_Id__c; //CISP-3030
            this.payload.api_mandate.enddate = repayment[0].End_Date__c !=null ? String.valueOf(repayment[0].End_Date__c) : null ;
            this.payload.api_mandate.frequency = (repayment[0].Frequency__c == 'Half yearly') ? 'Semiannually' : repayment[0].Frequency__c;
            this.payload.api_mandate.emiamount = repayment[0].EMI_Amount__c;
            this.payload.api_mandate.click2edit =System.Label.ENACH_Click_To_Edit;
            this.payload.api_mandate.autopayfactor =System.Label.Auto_Pay_Limit_Number;
            this.payload.api_mandate.redirectURL =System.Label.ENACH_Redirect_Url;
            this.payload.api_mandate.referralCode = '';
            this.payload.api_mandate.appid =System.Label.ENACH_App_Id;
            this.api_action = 'insertsession';
            this.created_at =todaysDateStr;
            
        }
        //if(isProductTypePV == true && String.isBlank(this.payload.api_mandate.emailid)){//CISP-3030
            //throw new IND_Exception(System.Label.EnterEmailAddress);
        //}  //CISP-3030 
        validate(System.Label.RegistrationJourney);
    }
    
    // @Method:      validate
    // @Created by:  Bhushan Charde
    // @Description: Method to validate the required input details
    // @Param:       Service name
    // @Return:      True - If all the validations are passed.
    public override boolean validate(String serviceName){
        //CISP-11260 Removed requirement of Customer_Code__c for e_NACH
        /*if(String.isBlank(this.payload.api_mandate.cifid)){
			throw new IND_Exception('Please Enter cifid');
        }*/
        if(String.isBlank(this.payload.api_mandate.detcustomername)){
            throw new IND_Exception(System.Label.CustomerName);
        }
        if(String.isBlank(this.payload.api_mandate.detcustomerbank)){
            throw new IND_Exception(System.Label.CustomerBank);
        }
        if(String.isBlank(this.payload.api_mandate.detcustomerifsc)){
            throw new IND_Exception(System.Label.IFSCCode);
        }
        if(String.isBlank(this.payload.api_mandate.detcustomeracc)){
            throw new IND_Exception(System.Label.CustomerAccountNumber);
        }        
        if(String.isBlank(this.payload.api_mandate.startdate)){
            throw new IND_Exception(System.Label.StartDateOfEmi);
        }        
        if(String.isBlank(this.payload.api_mandate.mobileno)){
            throw new IND_Exception(System.Label.Mobile_Number_Error_Msg);
        }
        if(String.isBlank(this.payload.api_mandate.enddate)){
            throw new IND_Exception(System.Label.EndDateOfEMI);
        }        
        if(String.isBlank(this.payload.api_mandate.frequency)){
            throw new IND_Exception(System.Label.FrequencyPeriodOfEMI);
        }       
        if(this.payload.api_mandate.emiamount==null){
            throw new IND_Exception(System.Label.EMIAmount);
        }       
        if(String.isBlank(this.payload.api_mandate.redirectURL)){
            throw new IND_Exception('Please enter Redirect URL to where customer have to land');
        }       
        if(String.isBlank(this.payload.api_mandate.appid)){
            throw new IND_Exception('Please enter appid');
        }                              
        if(String.isBlank(this.payload.api_mandate.autopayfactor)){
            throw new IND_Exception('Please enter autopayfactor');
        }                                     
                    
        if(String.isBlank(this.payload.api_mandate.accountnoordealno)){
            throw new IND_Exception(System.Label.AccountDealNumberCustomer);
        }       
        return true;
    }
    
    // @Method:      getHttpRequestHeaders
    // @Created by:  Bhushan Charde
    // @Description: Method to get the HTTP request header data
    // @Param:       ''
    // @Return:      Header required to callout the service.
    public override Map<String,String> getHttpRequestHeaders(){
        Map<String,String> requestHeaderMap = new Map<String,String>();
        requestHeaderMap.put(IntegrationConstants.CONTENT_TYPE , IntegrationConstants.CONTENT_TYPE_JSON);
        requestHeaderMap.put('IBL-Client-Id', System.Label.IBM_Client_ID);
        requestHeaderMap.put('IBL-Client-Secret', System.Label.IBM_Client_Secret);
        return requestHeaderMap;
        //requestheadermap is used to fetch the request from client
    }
}