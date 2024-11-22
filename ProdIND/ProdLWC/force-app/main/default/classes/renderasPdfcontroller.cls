public class renderasPdfcontroller {
    public String currentRecordId {get;set;}
    public Applicant__c app{get;set;}
        public List<Applicant__c> Records {get; set;}
       //public Opportunity opp {get; set;}

    public List<Vehicle_Detail__c> vehiclelist{get;set;}
    public List<Documents__c> KycList{get;set;}
    public List<Income_Details__c> IncomeDetList{get;set;}
    public List<Final_Term__c> FinalTermList{get;set;}
    public List<InsuranceDetails__c> InsurenceDetList{get;set;}
    //public List<Applicant__c> DocumentsdocList{get;set;}
    //public list<appWrapper> lst_appWrapper{get;set;}
    public list<Documents__c> lst_document{get;set;} 
    
    // public boolean FourWheeler{get;set;} // true -> show pb2
   //  public boolean Twowheeler {get;set;} // true -> show pb3
    public boolean isSubmitted{get;set;}
    public boolean linkExpired;
    public  boolean  getlinkExpired() {
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        // system.debug('current record is '+currentRecordId);
        Applicant__c applicant=[Select id,	Application_Form_SMS_Sent__c from Applicant__c where id =: currentRecordId WITH SECURITY_ENFORCED]; 
        Long currentDateTime = DateTime.now().getTime();
        if(applicant.Application_Form_SMS_Sent__c!=null){
            Long consentSentOnDate = applicant.Application_Form_SMS_Sent__c.getTime();
            Long difference = (currentDateTime-consentSentOnDate)/60000;                
            if(difference > 4320){ 
                system.debug('it is '+true);
                return true;
            } 
            else{
                system.debug('it is '+false);
                return false;
            }
        }
        return false;
    }
    
    public String loanapId;
    
    public renderasPdfcontroller(ApexPages.StandardController controller) {
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        app = [select id , Opportunity__r.Product_Type__c,Opportunity__c,Opportunity__r.Lead_Name__c,Opportunity__r.Lead_number__c,
               Opportunity__r.Lead_Number_Sequence__c,Opportunity__r.LeadSource,Opportunity__r.Required_Loan_amount__c,
               Opportunity__r.Loan_Application_Number__c,Opportunity__r.Required_ROI__c,Opportunity__r.Required_Tenure__c
               ,Opportunity__r.X1st_yr_Insurance_Premium__c,Opportunity__r.Is_customer_interested_in_a_motor_insura__c,Opportunity__r.Application_number__c,
               Opportunity__r.Address__c,Opportunity__r.Customer_Last_Name__c,Application_Consent_Received__c
               from Applicant__c where id =: currentRecordId ];
        
      // opp=[select id,Opportunity__r.Product_Type__c from Opportunity where Applicant__c =:currentRecordId];
        isSubmitted = true;
        if(app.Application_Consent_Received__c == true){
            isSubmitted = false;
        }
        
       Applicant__c appp =[select id, Opportunity__c from Applicant__c where id=:app.Id];
        if( appp.Opportunity__c != null)
        {
            loanapId = appp.Opportunity__c;
        }
        vehiclelist =  [select Vehicle_type__c,
                        Product__c, Make__c, Model__c,
                        Variant__c,Ins_Issuance_date__c,
                        Insurance_declared_value__c,
                        Insurance_number__c,Insurer_name__c,
                        Insurance_type__c from Vehicle_Detail__c where Loan_Application__c=:loanapId];  
        
        
        KycList= [select id, KYC_name__c, Gender__c,
                  First_Name__c, KYC_No__c from Documents__c where Applicant__c =: app.Id];
        
        IncomeDetList =[select Id ,name, Legal__c, Income_Source__c ,  Name_of_Recipient_Bank__c, Employer_Business_Name__c,
                                    Current_Years_in_employment_business__c from Income_Details__c where Applicant__c =: app.Id];
        
        
        Applicant__c apppfinalTerm =[select id, Opportunity__c from Applicant__c where id=:app.Id];
        if( apppfinalTerm.Opportunity__c != null)
        {
            loanapId = apppfinalTerm.Opportunity__c;
        }
        FinalTermList =  [select EMI_Amount__c,
                          Loan_Amount__c,
                          CRM_IRR__c,
                          Tenure__c,
                          Required_CRM_IRR__c from Final_Term__c where Loan_Application__c=:loanapId];
        
        InsurenceDetList= [select Id, Amount__c,
                           Product_Type__c, 
                           Funded_Non_funded__c,
                           Insurance_Plan__c,
                           Applicant__c from InsuranceDetails__c where Applicant__c =: app.Id];
        
        //Id OppId = [select id,Opportunity__c from Applicant__c where id = :app.Id].Opportunity__c;
        
        lst_document = [select id,name,Applicant__r.Opportunity__c,Applicant__r.Name,Applicant__r.Applicant_Type__c  from Documents__c where Applicant__c = : app.Id];
    }
    
    //@AuraEnabled 
    /*public static String renderasPdfcontroller() {
PageReference pdfPage = Page.render_as_pdf;
Blob pdfBlob = pdfPage.getContent();
String base64Pdf = EncodingUtil.base64Encode(pdfBlob);
return base64Pdf;
}*/
    
    public PageReference acceptandRender(){
        
        Applicant__c applObj= [SELECT Id, Application_Consent_Received__c, Application_Consent_SMS_Sent_Time__c                                    
                               FROM Applicant__c
                               WHERE Id =: currentRecordId
                               WITH SECURITY_ENFORCED];
        applObj.Application_Consent_Received__c = true;
        applObj.Application_Consent_SMS_Sent_Time__c = DateTime.Now();
        if(Schema.sObjectType.Applicant__c.isCreateable()){
            update applObj;
        }
        PageReference pageRef = new PageReference('/apex/render_as_page1?id='+currentRecordId);
        pageRef.setRedirect(true);
        return pageRef;
    }
}