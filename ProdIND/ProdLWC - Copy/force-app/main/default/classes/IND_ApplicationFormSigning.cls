/*------------------------------------------------------------    
Company:       Persistent
Description:   This class is controller class for VF page and displaying the application form consent VF page.
this class should be without sharing mode because guest does not have access to the records
Test Class:    IND_RenderAsPDFControllerTest
History
Date            Author              Comments
-------------------------------------------------------------
12-19-2021                   Created
------------------------------------------------------------*/
public without sharing class IND_ApplicationFormSigning
{
    public String panNo { get; set; }    
    public  Boolean isShowUsed { get; set; }
    public String voterNo { get; set; }
    //CISP:74
    public  string ContentVersionId{get;set;}
    public  string MaritalStatus{get;set;}
    public  string CommunicationLan{get;set;}
    public  string LoanAmount{get;set;}
    public  string RequiredROI{get;set;}
    public  string ServiceCharges{get;set;}
    public  string DocumentationCharges{get;set;}
    public  boolean IsSameAsper{get;set;}
    public    String DocID;
    public  String Label;
    public   string CapturedIncomemethod{get;set;}
    public   string AssessmentYear{get;set;}
    public   string DocumentTypeForPDF{get;set;}
    public   string email_id{get;set;}
    public   string FromMonth{get;set;}
    public   string ToMonth{get;set;}
    public  string GSTNumber{get;set;}    
    public    string CaptureITR;
    public  string CaptureGST{get;set;}
    public string RequiredTenure{get;set;}
    public  string DocumentType {get;set;}
    public  string MaximumAvailableTenure{get;set;}
    public  String whoWillPay{get;set;}
    public  string imagecontent {get; set;}
    public  transient string imagecontentOne {get;set;}
    public  String lastname {get; set;}
    public string applicationConsentReceivedTime {get;set;}
    public string applicationConsentSentTime {get;set;}
    public String drivingLicenseNO { get; set; }
    public  String passportNo { get; set; }
    public string dob {get; set;}  
    public  string RelationShipWithBorrower {get;set;}
    public  String currentRecordId {get;set;}
    public  String currentRecordurl {get;set;}
    public  Applicant__c app{get;set;}
    public  List<Applicant__c> Records {get; set;}      
    public  List<Vehicle_Detail__c> vehiclelist{get;set;}
    public Vehicle_Detail__c vehicleobj{get;set;}
    public  List<Documents__c> KycList{get;set;}
    public   List<Documents__c> KycListHeader{get;set;}
    public    List<Income_Details__c> IncomeDetList{get;set;}
    public     List<Income_Details__c> IncomeDetListHeader{get;set;}
    public    List<Final_Term__c> FinalTermList{get;set;}
    public   Final_Term__c FinalTermObj {get;set;}
    public  List<InsuranceDetails__c> InsurenceDetList{get;set;}    
    public  list<Documents__c> lst_document{get;set;}
    public  Documents__c aadhardocument{get;set;}
    public  List<Documents__c> aadhardocumentList{get;set;} //PDF generation VF page using this variable
    public  Documents__c pandocument{get;set;}
    public   List<Documents__c> pandocumentList{get;set;}  //PDF generation VF page using this variable
    public  Documents__c passportdocument{get;set;}
    public  List<Documents__c> passportdocumentList{get;set;}  //PDF generation VF page using this variable
    public  Documents__c voterIddocument{get;set;}
    public  List<Documents__c> voterIddocumentList{get;set;}  //PDF generation VF page using this variable
    public  Documents__c drivingdocument{get;set;}
    public  List<Documents__c> drivingdocumentList{get;set;}  //PDF generation VF page using this variable
    public Documents__c currentResDocument{get;set;}
    public  List<Documents__c> currentResDocumentList{get;set;}  //PDF generation VF page using this variable
    public Documents__c permanentResDocument{get;set;}
    public  List<Documents__c> permanentResDocumentList{get;set;}  //PDF generation VF page using this variable
    public  list<Documents__c> document{get;set;}
    public  List<Vehicle_Detail__c> vehicleobjList {get;set;}
    public  Vehicle_Detail__c assetobj {get;set;}
    public   List<Vehicle_Detail__c> newAssetobjList {get;set;}
    //Asset details
    public  List<Vehicle_Detail__c> usedassetobjList {get;set;}
    public  string applicationCreatedDate {get; set;}
    public string loanApplicationCreatedDate {get; set;}
    public  boolean isSubmitted{get;set;}    
    public string aadharNo {get;set;}    
    public  boolean linkExpired;
    public  String loanapId;
    public    List<String> insuranceIds {get; set;}
    public  boolean showVehicleInsuranceValuation {get; set;}
    public String whatsAppNumberSameContactNum {get; set;}
    public    List<Applicant__c> newVehicleloanDetaillist {get; set;} //PDF page will not support the reder function so using the list to render thesection in PDF page.
    public    List<Applicant__c> usedVehicleloanDetaillist {get; set;} //PDF page will not support the reder function so using the list to render thesection in PDF page.
    public  string currentDistrict {get;set;}
    public  string parmanentDistrict {get;set;}
    public  string fundingBasedOnLabel {get; set;}
    public string fundingbasedonValue {get; set;}
    public List<VehicleRecordsforLoanDetails> VehicleRecordsforLoanDetails{get;set;}
    public List<VehicleRecordsforInsuranceDetails> VehicleRecordsforInsuranceDetails{get;set;}
    /*
* @Method:      getlinkExpired  
* @Description: This method will check the consent is expired or not.
* @Param:       String - current Applicantion ID
* @Return:      JSON object : containing tab names.
*/
    public boolean  getlinkExpired() {
        currentRecordId  =  ApexPages.CurrentPage().getparameters().get('id');
        currentRecordurl  =  ApexPages.CurrentPage().getparameters().get('connum');
        Applicant__c applicant=[Select id,Application_Consent_OTP__c,Application_Form_SMS_Sent__c from Applicant__c
                                where id =: currentRecordId WITH SECURITY_ENFORCED];
        Long currentDateTime = DateTime.now().getTime();
        if(applicant.Application_Form_SMS_Sent__c!=null){
            Long consentSentOnDate = applicant.Application_Form_SMS_Sent__c.getTime();
            Long difference = (currentDateTime-consentSentOnDate)/60000;     
            system.debug('The currentDateTime : '+ currentDateTime+'consentSentOnDate:  '+ consentSentOnDate+'difference: '+difference);
            if(difference > 4320){                
                system.debug('it is '+true);
                return true;
            }
            else{
                system.debug('it is '+false);
                if(currentRecordurl == applicant.Application_Consent_OTP__c){
                    system.debug('update link '+false);
                    return false;
                }
                else if (currentRecordurl != applicant.Application_Consent_OTP__c){
                    system.debug('New link '+false);
                    return true;
                }
                else{
                    return true;
                }
                
            }
        }
        return false;
    }
    
    
    /*
* @Method:      IND_ApplicationFormSigning  
* @Description: constructor will fetch data from different objects and setting to variables.
* @Param:       none
* @Return:      none.
*/
    public IND_ApplicationFormSigning() {
        
        isShowUsed =false;        
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        showVehicleInsuranceValuation =false;
        whatsAppNumberSameContactNum ='No';          
        newVehicleloanDetaillist = new lIst<Applicant__c>();
        usedVehicleloanDetaillist = new list<Applicant__c>();
        app = [select id , Application_Form_SMS_Sent__c,Applicant_Type__c,Opportunity__r.Product_Type__c,Opportunity__c,Opportunity__r.Lead_Name__c,Opportunity__r.Lead_number__c,Createddate,
               Opportunity__r.Required_Loan_amount__c, Opportunity__r.Createddate,
               Opportunity__r.Loan_Application_Number__c,Opportunity__r.Required_ROI__c,Opportunity__r.Required_Tenure__c
               ,Opportunity__r.GST_Amount__c,Opportunity__r.X1st_yr_Insurance_Premium__c,Opportunity__r.Is_customer_interested_in_a_motor_insura__c,Opportunity__r.Application_number__c,
               Opportunity__r.Address__c,Opportunity__r.Customer_Last_Name__c,Application_Consent_Received__c,Customer_Last_Name__c,Name,Customer_First_Name__c,
               Whatsapp_number__c,Contact_number__c,Register_for_WhatsApp_Banking__c,of_family_members_residing_with_you__c,Residence_country__c,
               Opportunity__r.AccountId,Opportunity__r.Account.Name, Opportunity__r.Account.IsPersonAccount, Opportunity__r.Applicant_Name__c,Preferred_address_for_communication__c,
               Marital_status__c,Spouse_Name__c,Father_s_name__c,Who_will_repay_the_loan__c,Email_Id__c,Mother_s_name__c,toLabel(Communication_language__c),
               Customer_Qualification__c, Opportunity__r.Funding_on_Ex_Showroom__c,  Opportunity__r.Funding_on_ORP__c,
               Opportunity__r.Funded__c, Opportunity__r.Ex_showroom_price_carwale__c,Opportunity__r.RTO_Road_Tax__c,Opportunity__r.RTO_Road_Tax_New__c, Opportunity__r.On_Road_price__c,
               Opportunity__r.On_Road_price_carwale__c,LTV_with_Insurance__c,LTV_without_insurance__c,Total_Insurance_Payable__c,
               Opportunity__r.Non_Funded__c, Opportunity__r.Motor_Insurance_Premium__c, Opportunity__r.Basic_Price__c,Opportunity__r.Loan_Created_Date__c,
               Opportunity__r.Discount_on_Basic_Price__c, Opportunity__r.Ex_showroom_price__c,Relationship_with_borrower__c, Opportunity__r.Vehicle_Type__c,
               Opportunity__r.Other_charges__c,  Opportunity__r.Maximum_tenure__c ,Is_Borrower_Relative_Of_Director__c,Is_Borrower_Relative_Of_Senior_Officer__c,Is_CoBorrower_Relative_Of_Director__c,Is_CoBorrower_Relative_Of_Senior_Officer__c,
               Relationship_With_IndusInd_Or_Other_Bank__c,Borrower_Relation_With_IndusInd_Q1__c,Borrower_Relation_With_IndusInd_Q2__c,Borrower_Relation_With_Other_Bank_Q1__c,Borrower_Relation_With_Other_Bank_Q2__c,CoBorrower_Relation_With_IndusInd_Q1__c,CoBorrower_Relation_With_IndusInd_Q2__c,CoBorrower_Relation_With_Other_Bank_Q1__c,CoBorrower_Relation_With_Other_Bank_Q2__c,            
               (select Id,Proof_of_Identity_POI__c, First_Name__c,Last_Name__c,KYC_name__c,Gender__c,KYC_No__c,Aadhaar_Enrollment_Number__c,
                KYC_DOB__c,KYC_Address_Line_1__c,KYC_Address_Line_2__c,KYC_City__c,KYC_State__c,KYC_Pin_Code__c,PAN_No__c,KYC_District__c,
                Applicant__r.Applicant_Type__c,Name,Passport_No__c, Applicant__r.Current_Same_As_Permanent__c,
                Age__c,Document_Type__c,Current_Residential_Address_Proof__c,Permanent_Residential_Address_Proof__c,CreatedDate,Salutation__c  from Documents__r where  Applicant__c=:currentRecordId
                
               )
               from Applicant__c where id =: currentRecordId LIMIT 1];
        
        //cisp:74
        if(app.Marital_status__c!=null)
        {
            MaritalStatus = app.Marital_status__c.toLowerCase();
            MaritalStatus = MaritalStatus.capitalize();  
            //CISP: 3048
            if(MaritalStatus =='UNMAR'){MaritalStatus= 'UN MARRIED';app.Spouse_Name__c = 'Not Applicable';}
            if(MaritalStatus =='DIVOR'){  MaritalStatus= 'DIVORCE';app.Spouse_Name__c = 'Not Applicable';}
              if(MaritalStatus =='DVRCE'){MaritalStatus= 'DIVORCEE';app.Spouse_Name__c = 'Not Applicable';}
              if(MaritalStatus =='MARR'){MaritalStatus= 'MARRIED';}
              if(MaritalStatus =='SINGP'){MaritalStatus= 'SINGLE PARENT';app.Spouse_Name__c = 'Not Applicable';}
            if(MaritalStatus =='WIDOW'){MaritalStatus= 'WIDOW';app.Spouse_Name__c = 'Not Applicable';}
            if(MaritalStatus =='WIDWR'){MaritalStatus= 'WIDOWER';app.Spouse_Name__c = 'Not Applicable';} //CISP: 3048
        }
        
        if(app.Email_Id__c == null) {
            email_id ='Not Furnished';
        }else {
            email_id = app.Email_Id__c;
        }
        
        if(app.Communication_language__c!=null)
        {
            CommunicationLan = app.Communication_language__c.toLowerCase();
            CommunicationLan =  CommunicationLan.capitalize();
        }
        
        //CISP:74
        if(app.Who_will_repay_the_loan__c==null ){ Applicant__c AppOne=[select Who_will_repay_the_loan__c from Applicant__c where Opportunity__c=:app.Opportunity__c and Who_will_repay_the_loan__c!=null and Applicant_Type__c!=:app.Applicant_Type__c ];
            whoWillPay= AppOne.Who_will_repay_the_loan__c;
        }
        else{
            whoWillPay=app.Who_will_repay_the_loan__c;
        }
        
        if(app.Applicant_Type__c == 'Co-borrower')
        {
            RelationShipWithBorrower = app.Relationship_with_borrower__c != null ? app.Relationship_with_borrower__c.toLowerCase() : ''; 
            RelationShipWithBorrower = RelationShipWithBorrower.capitalize();
        }
        
        loanapId = app.Opportunity__c ;
        
        FinalTermList =  [SELECT Id,Tenure__c, Scheme_Bank_offers__c, Service_charges__c, Documentation_charges__c,createdDate,
                          Required_CRM_IRR__c,OfferengineMaxTenure__c,Loan_Amount__c,Stamping_charges__c,Due_date_shift_charges__c,ECS_verification_by__c,Verification_charges__c
                          FROM Final_Term__c where Loan_Application__c =: app.Opportunity__c  LIMIT 1];
        system.debug('The final term list is '+FinalTermList);
        
        
        if(!FinalTermList.isEmpty())
            
        {
            //CISP:74
            if(FinalTermList[0].Loan_Amount__c!=null){ String s = ( Decimal.valueOf(FinalTermList[0].Loan_Amount__c==null||FinalTermList[0].Loan_Amount__c.trim()==''?'0':FinalTermList[0].Loan_Amount__c).setScale(2) + 0.001 ).format();String p = s.substring(0,s.length()-1);LoanAmount='INR '+p;  
            }
            if(FinalTermList[0].Required_CRM_IRR__c!=null)
            {    
                RequiredROI= FinalTermList[0].Required_CRM_IRR__c +' %';  
            }  
            
            if(FinalTermList[0].Tenure__c!=null) {RequiredTenure = FinalTermList[0].Tenure__c +' Months';
            }
       
        }
        
        
        isSubmitted = true;        
        
        applicationCreatedDate =  string.valueof(app.Opportunity__r.Createddate);      
        applicationCreatedDate = applicationCreatedDate.substringBefore(' ');  
        loanApplicationCreatedDate = String.isNotBlank(app.opportunity__r.Loan_Created_Date__c) ? app.opportunity__r.Loan_Created_Date__c : getDateTimeFormat(app.Opportunity__r.Createddate);
        applicationConsentReceivedTime = getDateTimeFormat(DateTime.now());
        applicationConsentSentTime = getDateTimeFormat(app.Application_Form_SMS_Sent__c);
        //checking Product type and updating the flag to true. this flag is used to re-direct the pdf pages.
        
        if(app.Opportunity__r.Vehicle_Type__c != system.label.New){
            isShowUsed =true;
            newVehicleloanDetaillist.add(app);
            
        }else{
            usedVehicleloanDetaillist.add(app);
        }
        
        
        if(app.Application_Consent_Received__c == true){
            isSubmitted = false;
        }
        
        if(app.Opportunity__r.Vehicle_Type__c == system.label.used ||  app.Opportunity__r.Vehicle_Type__c == system.label.Refinance){
            showVehicleInsuranceValuation =true;
        }
        if(app.Whatsapp_number__c == app.Contact_number__c ){
            whatsAppNumberSameContactNum ='Yes';
        }
        
        if(app.Opportunity__r.Funding_on_ORP__c){
            fundingBasedOnLabel = 'Funding Based on ORP';
            fundingBasedOnValue = 'Yes';
        }
        
        if(app.Opportunity__r.Funding_on_Ex_Showroom__c){
            fundingBasedOnLabel = 'Funding Based on Ex-Showroom';
            fundingBasedOnValue = 'Yes';
        }
        
        KycList = new List<Documents__c>();
        KycListHeader = new list<Documents__c>();
        aadhardocumentList = new List<Documents__c>();
        passportdocumentList = new List<Documents__c>();
        pandocumentList =  new List<Documents__c>();
        voterIddocumentList =  new List<Documents__c>();        
        drivingdocumentList = new List<Documents__c>();
        newAssetobjList = new List<Vehicle_Detail__c>();
        usedassetobjList = new List<Vehicle_Detail__c>();
        for(Documents__c doc : app.Documents__r){
            system.debug('doc.CreatedDate :'+doc.CreatedDate);
            system.debug('FinalTermList[0].createdDate :'+FinalTermList);
            //CISP:74
            if(doc.Proof_of_Identity_POI__c!=false){
                Date d = doc.KYC_DOB__c;
                dob = DateTime.newInstance(d.year(),d.month(),d.day()).format('dd-MM-YYYY');
            }
            
            //adding all the applicant associated doc into a list.
            System.debug('suraj1234'+app.Application_Form_SMS_Sent__c+''+doc.CreatedDate);
            if(app.Application_Form_SMS_Sent__c!=null && doc.CreatedDate <=  app.Application_Form_SMS_Sent__c ){KycList.add(doc);
                System.debug('suraj123'+KycList);
                
            }else if(!FinalTermList.isEmpty() && doc.CreatedDate <= FinalTermList[0].createdDate){
                KycList.add(doc);
            }
            
            
            if (doc.Document_Type__c == system.label.AadhaarCard){
                aadhardocument = doc;
                //Aadhar No adding as ** and displaying last 4 digits.
                if(String.isNotBlank(doc.KYC_No__c)){aadharNo ='**** **** '+IntegrationUtilities.getDecryptedResponse(doc.KYC_No__c,System.Label.privateKey,System.Label.ivkey).right(4);//CISP-3038
                }
                
                aadhardocumentList.add(doc);
            }else if(doc.Document_Type__c == system.label.PassportCard){
                //aadharNo = 'Not applicable';
                passportdocument = doc;
                passportdocumentList.add(doc);
                if(doc.Passport_No__c!=null){
                    //passportNo = doc.Passport_No__c;
                    passportNo = '**** **** **** ***';//CISP-3038
                }
                
            }else if(doc.Document_Type__c == system.label.PanCard){
                //  aadharNo = 'Not applicable';
                // passportNo = 'Not applicable';
                if(doc.PAN_No__c != null){
                    //panNo = doc.PAN_No__c;
                    panNo = '**** **** **';//CISP-3038
                }
                pandocument =doc;
                pandocumentList.add(doc);                
            }else if(doc.Document_Type__c == system.label.VoterIdCard){
                // aadharNo = 'Not applicable';
                //passportNo = 'Not applicable';
                //panNo = 'Not applicable';
                voterIddocument = doc;
                voterIddocumentList.add(doc);
                lastname=voterIddocument.Last_Name__c;//change to get lastname
                if(doc.KYC_No__c != null){ voterNo = '**** **** **** ';//CISP-3038
                }
                
            }else if(doc.Document_Type__c == system.label.DrivingLicences){
                drivingdocument =doc;
                drivingdocumentList.add(doc);
                if(doc.KYC_No__c != null){drivingLicenseNO = '**** **** **** ***';//CISP-3038
                }
                //CISP:74
                else
                {
                    // drivingLicenseNO ='Not applicable';
                }
                
            }
            
            else {

            }
            
            //Capturing the Current residentail address
            system.debug('The curremt resi '+doc.Current_Residential_Address_Proof__c);
            if(doc.Current_Residential_Address_Proof__c){
                currentResDocument = doc;
                if(currentResDocument.KYC_District__c !=null ){
                    currentDistrict = currentResDocument.KYC_District__c ;
                }else{
                    currentDistrict = currentResDocument.KYC_City__c ;
                }
            }
            system.debug('The per resi '+doc.Permanent_Residential_Address_Proof__c);
            if(doc.Permanent_Residential_Address_Proof__c){
                permanentResDocument = doc;
                if(permanentResDocument.KYC_District__c !=null ){ parmanentDistrict = permanentResDocument.KYC_District__c ;
                }else{
                    parmanentDistrict = permanentResDocument.KYC_City__c ;
                }
                
            }else if(doc.Applicant__r.Current_Same_As_Permanent__c && doc.Current_Residential_Address_Proof__c){
                currentResDocument = doc;
                if(currentResDocument.KYC_District__c !=null ){
                    currentDistrict = currentResDocument.KYC_District__c ;
                }else{
                    currentDistrict = currentResDocument.KYC_City__c ;
                }
                
            }
            //CISP:74
            
            if(doc.Applicant__r.Current_Same_As_Permanent__c)
            {
                IsSameAsper = true;

            }
        }
        
        //Adding document record into header list.
        if(!KycList.isEmpty()){
            KycListHeader.add(KycList[0]);
        }
        if(app.Opportunity__r.Product_Type__c==System.Label.Tractor){
            VehicleRecordsforLoanDetails = new List<VehicleRecordsforLoanDetails>();
            vehiclelist =  [select Id,Vehicle_type__c,Usage_Type__c,
                            Product__c, Make__c, Model__c,
                            Variant__c,Ins_Issuance_date__c,
                            Insurance_declared_value__c,
                            Insurance_number__c,Insurer_name__c,
                            Purpose_of_purchase__c,
                            Dealer_Sub_dealer_name__c,
                            Invoice_in_the_name_of__c,Engine_number__c,Chassis_number__c,
                            Lien_in_favor_of__c,RC_retention_applicable__c,
                            Vehicle_registered_in_the_name_of__c,
                            Manufacturer_Year_Month__c,Last_owner_name__c,Number_of_ownerships__c,
                            Vehicle_Registration_number__c,
                            Owner_Name__c,Owner_Contact_Number__c,Vehicle_Place_Of_Valuation__c,State__c,City__c,Location_Of_Vehicle__c,
                            Executive_name__c,Executive_Contact_Number__c,Ins_Expiry_date__c,Insurance_expiring_within_60_days__c,
                            Insurance_type__c,
                            Loan_Amount__c,Loan_tenure__c,Required_CRM_IRR__c,Is_Customer_Interested_in_MotorInsurance__c,Funded__c,Non_Funded__c,X1st_yr_Insurance_Premium__c,Basic_Price__c,
                            GST_Amount__c,Invoice_Price__c,(SELECT Service_charges__c,Documentation_charges__c FROM Final_Terms__r)
                            from Vehicle_Detail__c where Loan_Application__c=:loanapId] ;
            for(Vehicle_Detail__c vehicleRec:vehiclelist){
                if(vehicleRec.Vehicle_type__c == system.label.new){
                    vehicleobj = vehicleRec;
                    assetobj = vehicleRec;
                    newAssetobjList.add(vehicleRec);
                }
                
                if(vehicleRec.Vehicle_type__c != system.label.new){
                    vehicleobj = vehicleRec;  
                    assetobj = vehicleRec;
                    usedassetobjList.add(vehicleRec);
        

                }
                List<Final_Term__c> finalTerms = vehicleRec.Final_Terms__r;
                
                VehicleRecordsforLoanDetails vehicleRecWrap = New VehicleRecordsforLoanDetails();
                vehicleRecWrap.Variant=vehicleRec.Variant__c;
                vehicleRecWrap.loanAmount=vehicleRec.Loan_Amount__c;
                vehicleRecWrap.loanTenure=vehicleRec.Loan_tenure__c;
                vehicleRecWrap.requiredCRMIRR=vehicleRec.Required_CRM_IRR__c;
                vehicleRecWrap.isCustomerInterestedInMotorInsurance=vehicleRec.Is_Customer_Interested_in_MotorInsurance__c;
                vehicleRecWrap.funded=vehicleRec.Funded__c;
                vehicleRecWrap.nonFunded=vehicleRec.Non_Funded__c;
                vehicleRecWrap.X1st_yrInsurancePremium=vehicleRec.X1st_yr_Insurance_Premium__c;
                vehicleRecWrap.basicPrice=vehicleRec.Basic_Price__c;
                vehicleRecWrap.gSTAmount=vehicleRec.GST_Amount__c; 
                vehicleRecWrap.invoicePrice=vehicleRec.Invoice_Price__c;
                if(!finalTerms.isEmpty()){
                    String r = ( Decimal.valueOf(finalTerms[0].Service_charges__c==null||finalTerms[0].Service_charges__c.trim()==''?'0':finalTerms[0].Service_charges__c).setScale(2) + 0.001 ).format();
                    String y = r.substring(0,r.length()-1);
                    ServiceCharges = 'INR '+ y ;
                    vehicleRecWrap.serviceCharges=ServiceCharges;
                    String o = ( Decimal.valueOf(finalTerms[0].Documentation_charges__c==null||finalTerms[0].Documentation_charges__c.trim()==''?'0':finalTerms[0].Documentation_charges__c).setScale(2) + 0.001 ).format();
                    String  c = o.substring(0,o.length()-1);
                    DocumentationCharges= 'INR '+ c;
                    vehicleRecWrap.documentationCharges=DocumentationCharges;
                }
                VehicleRecordsforLoanDetails.add(vehicleRecWrap);
            }  
        }
        else{
        vehiclelist =  [select Id,Vehicle_type__c,Usage_Type__c,
                        Product__c, Make__c, Model__c,
                        Variant__c,Ins_Issuance_date__c,
                        Insurance_declared_value__c,
                        Insurance_number__c,Insurer_name__c,
                        Purpose_of_purchase__c,
                        Dealer_Sub_dealer_name__c,
                        Invoice_in_the_name_of__c,Engine_number__c,Chassis_number__c,
                        Lien_in_favor_of__c,RC_retention_applicable__c,
                        Vehicle_registered_in_the_name_of__c,
                        Manufacturer_Year_Month__c,Last_owner_name__c,Number_of_ownerships__c,
                        Vehicle_Registration_number__c,
                        Owner_Name__c,Owner_Contact_Number__c,Vehicle_Place_Of_Valuation__c,State__c,City__c,Location_Of_Vehicle__c,
                        Executive_name__c,Executive_Contact_Number__c,Ins_Expiry_date__c,Insurance_expiring_within_60_days__c,
                        Insurance_type__c from Vehicle_Detail__c where Loan_Application__c=:loanapId limit 1] ;
        system.debug('vehiclelist ::'+ vehiclelist[0].Vehicle_type__c);
        if(!vehiclelist.isEmpty() && vehiclelist[0].Vehicle_type__c == system.label.new){vehicleobj = vehiclelist[0];  assetobj = vehiclelist[0];newAssetobjList.add(vehiclelist[0]);
            System.debug('the new asset detail list is '+newAssetobjList);
        }
        
        if(!vehiclelist.isEmpty() && vehiclelist[0].Vehicle_type__c != system.label.new){
            vehicleobj = vehiclelist[0];  
            assetobj = vehiclelist[0];
            usedassetobjList.add(vehiclelist[0]);
            System.debug('the old  asset detail list is '+usedassetobjList);
            
            }
        }
        if(!FinalTermList.isEmpty()&& !vehiclelist.isEmpty()) //CISP:3017
        {
            
            if(vehiclelist[0].Vehicle_type__c=='Used' && FinalTermList[0].OfferengineMaxTenure__c!=null )
            {MaximumAvailableTenure =  FinalTermList[0].OfferengineMaxTenure__c+ ' Months'; 
            }
        }
        
        IncomeDetListHeader = new list<Income_Details__c>();
        IncomeDetList =[select  Salaried_Self_employed__c,Employer_Business_Name__c,Total_Years_in_employment_business__c,Current_Years_in_employment_business__c,Profile__c,Profile__r.Name,
                        Name_of_Recipient_Banks__r.Name,
                        BSR_Occupation__c,Do_You_File_ITR__c,Do_You_File_GST__c,Is_Salaried__c,Bank_Account_Number__c,Name_of_Recipient_Banks__c,Income__c,Capture_ITR_Method__c,Capture_GST_Method__c,
                        Capture_Income_Method__c,Is_Self_Employed__c,
                        Id ,name, Legal__c, Income_Source__c ,  Name_of_Recipient_Bank__c,Assessment_Year__c,Is_Income_Credited_In_Bank_Account__c,
                        GST_No__c,From_Month__c,To_Month__c,Document_Type__c
                        from Income_Details__c where Applicant__c =: app.Id];
        if(!IncomeDetList.isEmpty()) //CISP: 2738 Added null Check in income detail
        {
            IncomeDetListHeader.add(IncomeDetList[0]);
            //CISP:74
            if(IncomeDetList[0].Capture_Income_Method__c !=null)
            {
                CapturedIncomemethod =  IncomeDetList[0].Capture_Income_Method__c;
            }
            else
            {
                CapturedIncomemethod = 'Not applicable';
            }      
            //CISP:74
            if(IncomeDetList[0].Assessment_Year__c !=null)
            {
                AssessmentYear =  IncomeDetList[0].Assessment_Year__c;
            }
            else
            {
                AssessmentYear = 'Not applicable';
            }
            //CISP:74
            if(IncomeDetList[0].Document_Type__c !=null)
            {
                DocumentType =  IncomeDetList[0].Document_Type__c;
            }
            else
            {
                DocumentType = 'Not applicable';
            }
            
            //CISP:74
            if(IncomeDetList[0].From_Month__c !=null)
            {
                FromMonth =  IncomeDetList[0].From_Month__c;
            }
            else
            {
                FromMonth = 'Not applicable';
            }
            //CISP:74
            if(IncomeDetList[0].To_Month__c !=null)
            {
                ToMonth =  IncomeDetList[0].To_Month__c;
            }
            else
            {
                ToMonth = 'Not applicable';
            }
            
            //CISP:74
            if(IncomeDetList[0].GST_No__c !=null)
            {
                GSTNumber =  IncomeDetList[0].GST_No__c;
            }
            else
            {
                GSTNumber = 'Not applicable';
            }
            
            
            
            
        }
        
        
        
        if(!FinalTermList.isEmpty()){
            FinalTermObj =FinalTermList[0];
            //CISP:74
            String r = ( Decimal.valueOf(FinalTermObj.Service_charges__c==null||FinalTermObj.Service_charges__c.trim()==''?'0':FinalTermObj.Service_charges__c).setScale(2) + 0.001 ).format();
            String y = r.substring(0,r.length()-1);
            ServiceCharges = 'INR '+ y ;
            String o = ( Decimal.valueOf(FinalTermObj.Documentation_charges__c==null||FinalTermObj.Documentation_charges__c.trim()==''?'0':FinalTermObj.Documentation_charges__c).setScale(2) + 0.001 ).format();
            String  c = o.substring(0,o.length()-1);
            DocumentationCharges= 'INR '+ c;
        }
        
        insuranceIds = new List<String>(); //this used to display the insurance header if Insurance record is present in PDF page
        
        InsurenceDetList= [select Id, Amount__c,
                           Name,
                           Product_Type__c,                            
                           Funded_Non_funded__c,
                           Insurance_Plan__c,                                                  
                           Applicant__c, Vehicle_Detail__r.Variant__c from InsuranceDetails__c where Applicant__c =: app.Id];
        if(!InsurenceDetList.isEmpty()){insuranceIds.add(InsurenceDetList[0].id);
        }
        //Added for Insurance Details section start
        VehicleRecordsforInsuranceDetails = new List<VehicleRecordsforInsuranceDetails>();
        for(InsuranceDetails__c insuDetRec : InsurenceDetList){
            VehicleRecordsforInsuranceDetails vehicleInsuranceRecWrap = New VehicleRecordsforInsuranceDetails();
            vehicleInsuranceRecWrap.Variant = insuDetRec.Vehicle_Detail__r.Variant__c;
            vehicleInsuranceRecWrap.InsuranceName = insuDetRec.Name;
            vehicleInsuranceRecWrap.InsurancePlan = insuDetRec.Insurance_Plan__c;
            vehicleInsuranceRecWrap.Amount = insuDetRec.Amount__c;
            vehicleInsuranceRecWrap.FundedNonFunded = insuDetRec.Funded_Non_funded__c;
            VehicleRecordsforInsuranceDetails.add(vehicleInsuranceRecWrap);
        }
        
        //Added for Insurance Details section start
        string linkedEntityId ;
        for(Documents__c doc : [SELECT Id, Name, Document_Type__c FROM Documents__c where Document_Type__c ='Customer Image' and Applicant__c =:app.Id limit 1]){linkedEntityId = doc.Id;
        }
        string contdocLink;
        if(linkedEntityId != null){List<ContentDocumentLink> contdocLink1 = [SELECT ContentDocumentId,Id,IsDeleted,LinkedEntityId FROM ContentDocumentLink where  LinkedEntityId =:linkedEntityId];if(!contdocLink1.isEmpty()  ){contdocLink = contdocLink1[0].ContentDocumentId;
            }
            
            system.debug(' contdocLink ::'+contdocLink);
        }
        
        if(contdocLink != null){for(ContentVersion conVer:  [SELECT id,ContentDocumentId,FileType,Title,VersionData FROM ContentVersion where ContentDocumentId =:contdocLink]){if(conVer.VersionData != null)imagecontent = '/sfc/servlet.shepherd/document/download/'+conVer.ContentDocumentId; imagecontentOne = EncodingUtil.base64Encode(conVer.VersionData);ContentVersionId=conVer.id;
                system.debug(' conVer Version'+imagecontent);
            }
        }
    }    
    
    /*
* @Method:      acceptandRender    
* @Description: This method will update the application consent check when a user provide the consent
* @Param:       none
* @Return:      PageReference.
*/
    public PageReference acceptandRender(){    
        try{
            Applicant__c applObj= [SELECT Id, Application_Consent_Received__c,Applicant_Type__c,Opportunity__c,  Application_Consent_SMS_Sent_Time__c,Application_Consent_OTP__c                                    
                                   FROM Applicant__c
                                   WHERE Id =: currentRecordId
                                   WITH SECURITY_ENFORCED];
            System.debug('I am in accept render');
            applObj.Application_Consent_Received__c = true;
            applObj.Application_Consent_SMS_Sent_Time__c = DateTime.Now();        
            
            PageReference pageRef = new PageReference('/apex/IND_ApplicationFormRenderPage?id='+currentRecordId+'&connum='+applObj.Application_Consent_OTP__c);
            pageRef.setRedirect(true);   
            //CISP: 2587
            String vehicleID =[select Id from Vehicle_Detail__c where Loan_Application__c=:loanapId limit 1].id ;
            system.debug('The vehical id id '+vehicleID);
            
            if(applObj.Applicant_Type__c == 'Borrower')
            {
                Label =system.Label.Application_form_borrower;
            }
            if(applObj.Applicant_Type__c == System.Label.CoBorrower)
            {
                Label=system.Label.Application_form_coborrower;
            }else{
                Label= 'Application form ' + applObj.Applicant_Type__c;
            }
            
            DocID = createOtherDocument(Label,vehicleID,applObj.id , applObj.Opportunity__c);createApplicationFormPdf(DocID,Label,applObj.Opportunity__c);
            update applObj;
            return pageRef;
        }
        catch (exception e){
            ErrorLoggerUtil.logErrorEvent('IND_ApplicationFormSigning', 'acceptandRender', 'Class', e);
            system.debug('The error at line '+e.getLineNumber());
            system.debug('The error at line message  '+e.getMessage());
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    //CISP: 2587
    
    public static void createApplicationFormPdf(String DocID,string Label,string oppId) {
        Blob fileDetails ;
        PageReference PDf =  Page.IND_ApplicationFormPDFpage;
        PDf.getParameters().put('Id',DocID);
        PDf.setRedirect(true);
        Attachment attach = new Attachment();
        if(!test.isRunningTest()){fileDetails = PDf.getContentAsPdf();
        }else{
            fileDetails = blob.valueof('TEST');
        }
        
        Utilities.createContentDocumentDownloadFromApex(DocID,Label, fileDetails, 'pdf',oppId);
    }
    
    /*
* @Method Name: createOtherDocument
* @Created by:  Parimal Shinde
* @description: to create a Document object for 'Other documents'
* @Param:       String - Document Type
* @Param:       String - current Vehicle Record ID
* @Param:       String - Loan Applicant ID
* @Return:      String - loanApplication ID
*/
    
    public static string createOtherDocument(String docType,String vehicleDetailId,String applicantId,String loanApplicationId){
        try {  
            string leadNo;
            list<Documents__c> docUpdList = new list<Documents__c>();
            ID otherDocRecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('Other Documents').getRecordTypeId();
            if(loanApplicationId!=null ){
                list<Opportunity> loanApp= [Select Name from Opportunity where Id =: loanApplicationId WITH SECURITY_ENFORCED];
                if(!loanApp.isEmpty()) {
                    leadNo = loanApp[0].Name;
                    //Deactivate existing Document, if any                      
                    for(Documents__c doc : [Select Id from Documents__c where Document_Type__c = :docType and Opportunity_Relation__c = :loanApplicationId and Applicant__c =:applicantId WITH SECURITY_ENFORCED]) {doc.is_Active__c = false;docUpdList.add(doc);
                    }
                }
                if(!docUpdList.isEmpty()) { update docUpdList;
                }   
                Documents__c docObject= new Documents__c(Name = docType+' '+leadNo,Vehicle_Detail__c=vehicleDetailId,Applicant__c=applicantId,Opportunity_Relation__c=loanApplicationId,Document_Type__c=docType,is_Active__c = true);
                System.debug('docObject'+docObject);
                docObject.RecordTypeId = otherDocRecordTypeId;
                if (Schema.sObjectType.Documents__c.isCreateable())
                    insert docObject;
                
                if(Test.isRunningTest())
                {
                    throw new AuraHandledException(System.Label.ExceptionMessage);
                }
                return docObject.Id;
            }
            return null;
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('GenericUploadController', 'createOtherDocument ', System.Label.Apex, e);
            throw new AuraHandledException(e.getMessage() + ' ' + e.getStackTraceString());  
        }
        
    }
    public static String getDateTimeFormat(DateTime dt){
        String dateTimeString;
        DateTime dtime = dt;
        Integer day = dtime.day();
        Integer month = dtime.month();
        Integer year = dtime.year();
        String formattedDate = String.valueOf(day).leftPad(2, '0') + '/' +
                            String.valueOf(month).leftPad(2, '0') + '/' +
                            String.valueOf(year);
        dateTimeString = formattedDate+' '+string.valueof(dtime).substringAfter(' ');
        return dateTimeString;
    } 
    
    // Wrapper class for vehicle Record for Loan Details data
    public class VehicleRecordsforLoanDetails {
        public String variant{get;set;}
        public Decimal loanAmount{get;set;}
        public Decimal loanTenure{get;set;}
        public Decimal requiredCRMIRR{get;set;}
        public Boolean isCustomerInterestedInMotorInsurance{get;set;}
        public Boolean funded{get;set;}
        public Boolean nonFunded{get;set;}
        public Decimal X1st_yrInsurancePremium{get;set;}
        public Decimal basicPrice{get;set;}
        public Decimal gSTAmount{get;set;}
        public Decimal invoicePrice{get;set;}
        public String serviceCharges{get;set;}
        public String documentationCharges{get;set;}
    }
    
    // Wrapper class for vehicle Record for Insurance Details data
    public class VehicleRecordsforInsuranceDetails {
        public String Variant{get;set;}
        public String InsuranceName{get;set;}
        public String InsurancePlan{get;set;}
        public Decimal Amount{get;set;}
        public String FundedNonFunded{get;set;}
    }
}