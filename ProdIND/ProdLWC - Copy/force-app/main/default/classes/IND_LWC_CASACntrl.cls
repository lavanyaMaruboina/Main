/** 
* @description       : This controller is designed for CASA module.
* @created on		 : 24-08-2022
* @created by        : Vinita
**/
public without sharing class IND_LWC_CASACntrl {

    public transient String currentRecordId {get;set;}
    public String loanapId; 
    public transient String EMIDateDay{get;set;}
    public transient Applicant__c applicant{get;set;}
    public List<String> docList;
   // public Loan_Agreement__c loanAgreementValue; // CISP:2422
    //CISP 9
    public transient Final_Term__c finalTermValue{get;set;} 
   // public Repayments__c repaymentValue;//CISP:2422
    //public List<Applicant__c> Records //CISP:2422
    public List<Documents__c> KycList; //CISP:2422
    public List<Documents__c> KycListHeader;  //CISP:2422
    public Documents__c aadhardocument; //CISP:2422
    public List<Documents__c> aadhardocumentList; //CISP:2422
    public Documents__c pandocument; //CISP:2422
    public List<Documents__c> pandocumentList; //CISP:2422 
    public Documents__c passportdocument;//CISP:2422
    public List<Documents__c> passportdocumentList;  //CISP:2422
    public Documents__c voterIddocument; //CISP:2422
    public List<Documents__c> voterIddocumentList;  //CISP:2422
    public Documents__c drivingdocument; //CISP:2422
    public List<Documents__c> drivingdocumentList; //CISP:2422
    public transient string currentCity {get;set;}
    public transient string currentState {get;set;}
    public string currentPin {get;set;}
    public string currentAddr1 {get;set;}
    public string currentAddr2 {get;set;}
    public string parmanentCity {get;set;}
    public string parmanentState {get;set;}
    public string parmanentPin {get;set;}
    public string parmanentAddr1 {get;set;}
    public string parmanentAddr2 {get;set;}
    public Documents__c currentResDocument; //CISP:2422
    public Documents__c permanentResDocument; //CISP:2422 
    public transient list<Documents__c> document{get;set;} 
    public transient string dob {get;set;} 
    public transient string gender {get;set;} 
    public transient string salutation {get;set;}
    public transient string aadharNo {get;set;} 
    public transient String panNo { get; set; }    
    public transient String voterNo { get; set; }
    public transient String lastname {get; set;}
    public transient String drivingLicenseNO { get; set; }
    public transient String dlExpiryDate { get; set; }
    public transient String passportNo { get; set; }
    public transient String passportExpiryDate { get; set; }
    public transient string imagecontent {get; set;}
    public transient String createdDate {get; set;}
    public transient Decimal monthlyIncome {get; set;}
    public transient Decimal emiAmount {get; set;}
    // public Decimal loanAmount {get; set;}
    public String tenureInMonths{get; set;}
    public transient CASA_Bank_Form__c casaBankDetails{get; set;}
    public transient Income_Details__c incomeDetails{get; set;}
    public transient String sameAsPermanent{get;set;} //CISP:2422
    public transient String nomineeDob{get; set;}
    public transient Boolean nomineeAvailable; //CISP:2422
    public transient Boolean nomineeFacilityNotAvailable{get; set;}
    public transient Boolean nomineeFacility{get; set;}
    public transient String currentRecordurl ; //CISP:2422
    public transient boolean linkExpired; 
    public transient boolean isForm60{get; set;}
    public Date todayDate; //CISP:2422
    public transient Integer age{get; set;}
    public  Boolean acceptConsent; //CISP 2422
    public transient String consentMessage{get; set;}
    public transient Boolean currentAddrAvailable{get; set;}
    public transient Boolean permanentAddrAvailable{get; set;}
    public transient Boolean OfficeAddrAvailable{get; set;}
    public transient String endDate{get;set;}
    public transient String startDate{get;set;}
    public string acceptDate {get;set;}
    public string acceptedTime {get;set;}
    public string smsSentDate {get;set;}
    public string smsSentTime {get;set;}
    public string mobileNumber {get;set;}
    public String salariedOrSelfEmployed {get;set;}
    public String branchName {get;set;}
    public String branchCode {get;set;}
    public Boolean aepsFacility {get;set;}
    public Boolean noAepsFacility {get;set;}
    public String customerQualification {get;set;}
    
    public IND_LWC_CASACntrl()
    {
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id'); //a06Bl000001Wbf0IAC
        sameAsPermanent ='NO';
        nomineeFacilityNotAvailable=false;
        nomineeFacility=false;
        isForm60=false;
        acceptConsent = false;
        currentAddrAvailable=false;
        permanentAddrAvailable=false;
        OfficeAddrAvailable=false;
        Loan_Agreement__c loanAgreementValue;

        applicant = [SELECT Id,Opportunity__r.Agent_BL_code__c,Opportunity__r.Product_Type__c,AepS_Info__c,Name,CASA_Form_SMS_Sent__c,Opportunity__r.Loan_Created_Date__c,Whatsapp_number__c,Preferred_address_for_communication__c,Customer_Qualification__c,toLabel(Customer_Qualification__c) custQual,Opportunity__c,Customer_First_Name__c,Customer_Last_Name__c,Mother_s_name__c,Father_s_name__c,Marital_status__c,Contact_number__c,Email_Id__c,Declared_income__c,Opportunity__r.Createddate,Opportunity__r.Application_number__c,Opportunity__r.Deal_Number__c,Opportunity__r.Account.Name,Opportunity__r.Account.BranchBLCode__c,Start_Date__c,Loan_Amount__c,Application_Consent_Received__c,
                    (SELECT Id,KYC_District__c,PAN_No__c,Proof_of_Identity_POI__c,Document_Type__c,Current_Residential_Address_Proof__c,Permanent_Residential_Address_Proof__c,Applicant__r.Current_Same_As_Permanent__c,KYC_No__c,KYC_Expiry_Date__c,Salutation__c,First_Name__c, Last_Name__c,KYC_DOB__c,Gender__c ,KYC_City__c,KYC_State__c,KYC_Pin_Code__c,KYC_Address_Line_1__c,KYC_Address_Line_2__c,Passport_No__c FROM Documents__r ),
                    (SELECT Id,Is_Salaried__c,Is_Self_Employed__c,Profile__r.Name,Profile__r.Sub_Bucket_Desc__c,Office_Address_Line_1__c,Office_Address_Line_2__c,Office_City__c,Office_District__c,Office_PinCode__c,Office_State__c,IsOfficeAddressSubmitted__c FROM Income_Details__r WHERE Primary_Income_Source__c = true),
                    (SELECT Id,Nominee_available__c,Nominee_address__c,Nominee_Pin_Code__c,Nominee_State__c,Finacle_City__r.Name,Geo_State_Master__r.Name,Nominee_City__c, Nominee_name__c ,Nominee_DOB__c, Relationship_with_borrower__c,Saving_Account_opening_form_No__c FROM CASA_Bank_Forms__r LIMIT 1)
                    FROM Applicant__c WHERE id =: currentRecordId AND In_Active_Applicant__c = false];

        mobileNumber = applicant.Whatsapp_number__c!=null ? '*** ***'+applicant.Whatsapp_number__c.right(4) : applicant.Contact_number__c!=null ? '*** ***'+applicant.Contact_number__c.right(4) : '';
        smsSentDate = getDateTimeFormat(applicant.CASA_Form_SMS_Sent__c);
        smsSentTime = string.valueof(applicant.CASA_Form_SMS_Sent__c).substringAfter(' ');
        acceptDate = getDateTimeFormat(DateTime.now());
        acceptedTime = string.valueof(DateTime.now()).substringAfter(' ');
        if(applicant.AepS_Info__c!=null && applicant.AepS_Info__c=='Yes'){
            aepsFacility = true;
        }else{
            noAepsFacility = true;
        }
        customerQualification = (String) applicant.get('custQual');
        String productCode = applicant.Opportunity__r.Product_Type__c == 'Two Wheeler' ? 'H' : applicant.Opportunity__r.Product_Type__c == 'Tractor' ? 'T': 'C';

            List<BankBranchDetails__c> bbranchDetails = [SELECT Id,Name,SA_IBL_Branch_Code__c FROM BankBranchDetails__c WHERE Bl_Code__c=:applicant.Opportunity__r.Agent_BL_code__c and Product__c=:productCode];
            if(bbranchDetails.size() > 0){
            branchName = bbranchDetails[0].Name;
            branchCode = bbranchDetails[0].SA_IBL_Branch_Code__c;
        }
        currentAddrAvailable = applicant.Preferred_address_for_communication__c=='Permanent Address'?true:false;   
        permanentAddrAvailable = applicant.Preferred_address_for_communication__c=='Residence Address'?true:false;        
        OfficeAddrAvailable = applicant.Preferred_address_for_communication__c=='Office Address'?true:false;
                
        if(!applicant.CASA_Bank_Forms__r.isEmpty()){
            casaBankDetails = applicant.CASA_Bank_Forms__r[0];
            if(casaBankDetails.Nominee_DOB__c!=null){
                nomineeDob = string.valueOf(casaBankDetails.Nominee_DOB__c.day())+'/'+string.valueOf(casaBankDetails.Nominee_DOB__c.month())+'/'+string.valueOf(casaBankDetails.Nominee_DOB__c.year());
            }
            nomineeAvailable = casaBankDetails.Nominee_available__c;
            system.debug('Check Nominee: '+nomineeAvailable);
            if(nomineeAvailable){
                nomineeFacilityNotAvailable=false;
                nomineeFacility=true;
            }else{
                nomineeFacilityNotAvailable=true;
                nomineeFacility=false;
            }

            todayDate = System.today();
            if(casaBankDetails.Nominee_DOB__c!=null){
                age=(casaBankDetails.Nominee_DOB__c.monthsBetween(todayDate))/12;
            }
        }
        
        if(!applicant.Income_Details__r.isEmpty()){
            incomeDetails = applicant.Income_Details__r[0];
            if(incomeDetails.IsOfficeAddressSubmitted__c){
                //OfficeAddrAvailable=true;
            }
            if(incomeDetails.Is_Salaried__c){
                salariedOrSelfEmployed = 'Salaried';
            }else{
                salariedOrSelfEmployed = 'Self Employed';
            }
        }

        loanapId = applicant.Opportunity__c ;
        system.debug('The loan aaplication id '+loanapId);
        // createdDate = string.valueOf(applicant.Opportunity__r.Createddate);
        // createdDate = createdDate.substring(0,10);
        DateTime dtime = applicant.Opportunity__r.Createddate;
        Integer day = dtime.day();
        Integer month = dtime.month();
        Integer year = dtime.year();
        String formattedDate = String.valueOf(day).leftPad(2, '0') + '/' +
                            String.valueOf(month).leftPad(2, '0') + '/' +
                            String.valueOf(year);
        createdDate = String.isNotBlank(applicant.Opportunity__r.Loan_Created_Date__c) ? applicant.Opportunity__r.Loan_Created_Date__c.substring(0,10) : formattedDate;
        if(applicant.Declared_income__c!=null){
            monthlyIncome = (applicant.Declared_income__c )/12;
        }
        
        // loanAmount = applicant.Loan_Amount__c;

        //CISP 9 141- 143
         finalTermValue =  [SELECT Id,Tenure__c,Loan_Amount__c,EMI_Amount__c
                        FROM Final_Term__c WHERE Loan_Application__c =: loanapId  LIMIT 1];
        system.debug('The final term field'+finalTermValue);

        if(finalTermValue!= null){
            tenureInMonths = finalTermValue.Tenure__c;
            emiAmount =(finalTermValue.EMI_Amount__c)*1.5;
        }
                        
        List<Loan_Agreement__c> loanAgreementList =  [SELECT Id,Ist_EMI_Due_Date__c
                        FROM Loan_Agreement__c WHERE Loan_Application__c =: loanapId  LIMIT 1];
        if(!loanAgreementList.isEmpty())
        {
            //CISP 9
             Date emiDate;
             Date emiEndDate;
             Integer DayOfTheEMI;
             loanAgreementValue = loanAgreementList[0];
             emiDate= loanAgreementList[0].Ist_EMI_Due_Date__c;
             DayOfTheEMI= emiDate.Day();
             EMIDateDay=getOrdinal(DayOfTheEMI);
             //Date dateTypeFormat = repaymentList[0].lst_EMI_Due_Date__c;
             startDate =emiDate.day()+'/'+emiDate.month()+'/'+emiDate.year();
             emiEndDate = emiDate.addMonths(Integer.valueOf(tenureInMonths)+2);// add 3 months buffer
             Date finalEndDate = emiEndDate.addMonths(1).toStartofMonth().addDays(-1); //Get the lastday of month
             endDate = finalEndDate.day()+'/'+finalEndDate.month()+'/'+finalEndDate.year();
        }
        /*
        List<Repayments__c> repaymentList =  [SELECT Id,lst_EMI_Due_Date__c
                        FROM Repayments__c WHERE Loan_Application__c =: loanapId  LIMIT 1];
        if(!repaymentList.isEmpty() && repaymentList[0].lst_EMI_Due_Date__c !=null){
            //endDate = repaymentList[0].lst_EMI_Due_Date__c;
            Date dateTypeFormat = repaymentList[0].lst_EMI_Due_Date__c;
            endDate =dateTypeFormat.month()+'/'+dateTypeFormat.day()+'/'+dateTypeFormat.year();
        }
        */

        KycList = new List<Documents__c>();
        KycListHeader = new list<Documents__c>();
        aadhardocumentList = new List<Documents__c>();
        passportdocumentList = new List<Documents__c>();
        pandocumentList =  new List<Documents__c>();
        voterIddocumentList =  new List<Documents__c>();        
        drivingdocumentList = new List<Documents__c>();
        docList = new List<String>();

        for(Documents__c doc : applicant.Documents__r){
            if(doc.Document_Type__c!=null){
                docList.add(doc.Document_Type__c);
            }
            if(doc.Proof_of_Identity_POI__c){
                dob = string.valueOf(doc.KYC_DOB__c.day())+'/'+string.valueOf(doc.KYC_DOB__c.month())+'/'+string.valueOf(doc.KYC_DOB__c.year());
                lastname=doc.Last_Name__c;
                gender= doc.Gender__c;
                salutation= doc.Salutation__c;
            }

            if (doc.Document_Type__c == system.label.AadhaarCard){
                aadhardocument = doc;
                //Aadhar No adding as ** and displaying last 4 digits.
                if(String.isNotBlank(doc.KYC_No__c)){
                    aadharNo ='**** **** '+IntegrationUtilities.getDecryptedResponse(doc.KYC_No__c,System.Label.privateKey,System.Label.ivkey).right(4);//CISP-3038
                }
                
                aadhardocumentList.add(doc);
            }else if(doc.Document_Type__c == system.label.PassportCard){
                passportdocument = doc;
                passportdocumentList.add(doc);
                if(doc.Passport_No__c!=null){
                    //passportNo = doc.Passport_No__c;
                    passportNo = '**** **** **** ***';//CISP-3038
                    passportExpiryDate = string.valueOf(doc.KYC_Expiry_Date__c);
                }
                
            }else if(doc.Document_Type__c == 'PAN'){
                if(doc.PAN_No__c != null){
                    //panNo = doc.PAN_No__c;
                    //panNo = '**** **** **';//CISP-3038
                    if(!Test.isRunningTest() && doc.PAN_No__c.length() > 15){
                        panNo = '*** ***'+IntegrationUtilities.getDecryptedResponse(doc.PAN_No__c,System.Label.privateKey,System.Label.ivkey).right(4);
                    }else{
                         panNo = '*** ***'+doc.PAN_No__c.right(4);
                    }
                }
                pandocument =doc;
                pandocumentList.add(doc);                
            }else if(doc.Document_Type__c == system.label.VoterIdCard){
                
                voterIddocument = doc;
                voterIddocumentList.add(doc);
                if(doc.KYC_No__c != null){
                    //voterNo = doc.KYC_No__c;
                    //voterNo = '**** **** **** ';//CISP-3038
                    voterNo = '**** ****'+IntegrationUtilities.getDecryptedResponse(doc.KYC_No__c,System.Label.privateKey,System.Label.ivkey).right(4);
                }
                
            }else if(doc.Document_Type__c == system.label.DrivingLicences){
                drivingdocument =doc;
                drivingdocumentList.add(doc);
                if(doc.KYC_No__c != null){
                    //drivingLicenseNO = doc.KYC_No__c;
                    //drivingLicenseNO = '**** **** **** ***';//CISP-3038
                    drivingLicenseNO = '**** **** '+IntegrationUtilities.getDecryptedResponse(doc.KYC_No__c,System.Label.privateKey,System.Label.ivkey).right(4);
                    dlExpiryDate =  string.valueOf(doc.KYC_Expiry_Date__c);
                }
                
            }else if(doc.Document_Type__c == 'Form 60'){
                    isForm60 = true;
            }

            if(doc.Current_Residential_Address_Proof__c){
                //currentAddrAvailable=true;
                currentResDocument = doc;
                if(currentResDocument.KYC_District__c !=null ){
                    currentCity = currentResDocument.KYC_District__c ;
                }else{
                    currentCity = currentResDocument.KYC_City__c ;
                }
                currentState = currentResDocument.KYC_State__c;
                currentPin = currentResDocument.KYC_Pin_Code__c;
                currentAddr1 = currentResDocument.KYC_Address_Line_1__c;
                currentAddr2 = currentResDocument.KYC_Address_Line_2__c;
            }
            
            if(doc.Permanent_Residential_Address_Proof__c && doc.Applicant__r.Current_Same_As_Permanent__c){
                //permanentAddrAvailable=true;
                permanentResDocument = doc;
                sameAsPermanent = 'YES';
                if(permanentResDocument.KYC_District__c !=null ){
                    parmanentCity = permanentResDocument.KYC_District__c ;
                }else{
                    parmanentCity = permanentResDocument.KYC_City__c ;
                }
                parmanentState = permanentResDocument.KYC_State__c;
                parmanentPin = permanentResDocument.KYC_Pin_Code__c;
                parmanentAddr1 = permanentResDocument.KYC_Address_Line_1__c;
                parmanentAddr2 = permanentResDocument.KYC_Address_Line_2__c;
                
            }else if(doc.Permanent_Residential_Address_Proof__c && !doc.Applicant__r.Current_Same_As_Permanent__c){
                //permanentAddrAvailable=true;
                permanentResDocument = doc;
                if(permanentResDocument.KYC_District__c !=null ){
                    parmanentCity = permanentResDocument.KYC_District__c ;
                }else{
                    parmanentCity = permanentResDocument.KYC_City__c ;
                }
                parmanentState = permanentResDocument.KYC_State__c;
                parmanentPin = permanentResDocument.KYC_Pin_Code__c;
                parmanentAddr1 = permanentResDocument.KYC_Address_Line_1__c;
                parmanentAddr2 = permanentResDocument.KYC_Address_Line_2__c;
            }

            if(!KycList.isEmpty()){
                KycListHeader.add(KycList[0]);
            }
        }

        if(docList.size() > 0){
        if(!docList.contains(system.label.DrivingLicences)){
            drivingLicenseNO = 'Not Furnished';
        }
        if(!docList.contains(system.label.VoterIdCard)){
            voterNo = 'Not Furnished';
        }
        if(!docList.contains('PAN')){
            panNo = 'Not Furnished';
        }
        if(!docList.contains(system.label.AadhaarCard)){
            aadharNo = 'Not Furnished';
        }
        if(!docList.contains(system.label.PassportCard)){
            passportNo = 'Not Furnished';
        }
        }

        string linkedEntityId ;
        for(Documents__c doc : [SELECT Id, Name, Document_Type__c FROM Documents__c where Document_Type__c ='Customer Image' and Applicant__c =:applicant.Id limit 1]){
            linkedEntityId = doc.Id;
        }
        string contdocLink;
        if(linkedEntityId != null){
            List<ContentDocumentLink> contdocLink1 = [SELECT ContentDocumentId,Id,IsDeleted,LinkedEntityId FROM ContentDocumentLink where  LinkedEntityId =:linkedEntityId];
            if(!contdocLink1.isEmpty()  ){
                contdocLink = contdocLink1[0].ContentDocumentId;
            }
            system.debug(' contdocLink ::'+contdocLink);
        }
   
        if(contdocLink != null){
            for(ContentVersion conVer:  [SELECT ContentDocumentId,FileType,Title,VersionData FROM ContentVersion where ContentDocumentId =:contdocLink]){
                if(conVer.VersionData != null)
                    imagecontent = EncodingUtil.base64Encode(conVer.VersionData);
                    system.debug(' conVer Version'+conVer.VersionData);
                }
        }
    }

        /*
    * @Method:      acceptandRender    
    * @Description: This method will update the application consent check when a user provide the consent
    * @Param:       none
    */ 
    public void acceptandRender(){    
        try{
            acceptConsent = true;
            Applicant__c applObj= [SELECT Id, CASA_Consent_Received__c , CASA_Consent_Received_Time__c ,CASA_Consent_OTP__c                                     
                                FROM Applicant__c
                                WHERE Id =: currentRecordId
                                WITH SECURITY_ENFORCED];
            applObj.CASA_Consent_Received__c = true;
            applObj.CASA_Consent_Received_Time__c = DateTime.Now();        
            update applObj;
        }catch (exception e){
            ErrorLoggerUtil.logErrorEvent('IND_LWC_CASACntrl', 'acceptandRender', 'Class', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    /*
    * @Method:      getlinkExpired   
    * @Description: This method will check the consent is expired or not.
    * @Param:       String - current Applicantion ID
    * @Return:      JSON object : containing tab names.
    */ 
    public boolean  getlinkExpired() {
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id'); 
        currentRecordurl  = ApexPages.CurrentPage().getparameters().get('connum'); 
        Applicant__c applicant=[Select id,CASA_Consent_OTP__c,CASA_Form_SMS_Sent__c,CASA_Consent_Received__c  from Applicant__c 
                                where id =: currentRecordId WITH SECURITY_ENFORCED]; 
        if(applicant.CASA_Consent_OTP__c !=null){
                if(currentRecordurl == applicant.CASA_Consent_OTP__c){
                    if(applicant.CASA_Consent_Received__c){
                        if(acceptConsent){
                            consentMessage = 'Your Consent is Accepted';
                            return true;
                        } 
                        return false;
                    }else{
                        return false;
                    }
                }
                else if (currentRecordurl != applicant.CASA_Consent_OTP__c){
                    consentMessage='Your link has been expired';
                    return true;
                }
                else{
                    consentMessage='Your link has been expired';
                    return true;
                }
        }
        consentMessage = 'Your Consent is Accepted';
        return true;
    }
    
    
    
    /*
    * @Method:      getOrdinal  
    * @Description: This method will return the ordinal of the day.
    * @Param:       Integer Day of the Date
    * @Return:      String:Day+ordinal.
    */    
    //CISP-9:
   public string getOrdinal(integer i){
        string num = string.valueof(i);
        string suffix = 'th';
        string ordinal = '';
        i = integer.valueof(num.right(2));
        if(10 < i && i < 14) {
            ordinal =  num + suffix;
        }else{
            string onesDigit = num.right(1);
            if(onesDigit == '1'){
                suffix = 'st';
            }else if(onesDigit == '2'){
                suffix = 'nd';
            }else if(onesDigit == '3'){
                suffix = 'rd';
            }
            ordinal = num+suffix;
        }
        return ordinal;
    }

    public static String getDateTimeFormat(DateTime dt){
        DateTime dtime = dt;
        Integer day = dtime.day();
        Integer month = dtime.month();
        Integer year = dtime.year();
        String formattedDate = String.valueOf(day).leftPad(2, '0') + '/' +
                            String.valueOf(month).leftPad(2, '0') + '/' +
                            String.valueOf(year);
        
        return formattedDate;
    }
    
}