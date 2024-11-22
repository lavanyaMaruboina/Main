public class SanctionLetterController {
    public String loanApplicationNo { get; set; }
    public String sanctionDate { get; set; }
    public String customerName { get; set; }
    public String CustomerLastName { get; set; }
    public String productSegment { get; set; }
    public String customerCode { get; set; }
    public String customerCodeCoborrower { get; set; }
    public String nameOfCoborrower { get; set; }
    public String product { get; set; }
    //public String currentResidentialAddress { get; set; }
    //public String variant { get; set; }
    public String vehicleType { get; set; }
    public String engineNo { get; set; }
    public String chassisNo { get; set; }
    public String yearOfManufacture { get; set; }
    public String registrationNumber { get; set; }
    public String dealer { get; set; }
    //public String permanentResidentialAddress { get; set; }
    // public String officeAddress { get; set; }
    public String panNumber { get; set; }
    public String passportNo { get; set; }
    public String passportExpiryDate { get; set; }
    public String drivingLicenseNo { get; set; }
    public String drivingLicenseExpiryDate { get; set; }
    public String aadhaar { get; set; }
    public String dateOfBirth { get; set; }
    public String dateOfBirthNonInd { get; set; }
    public String panNumberGurantor { get; set; }
    public String passportNoGurantor { get; set; }
    public String drivingLicenseNOGurantor { get; set; }
    public String aadhaarGurantor { get; set; }
    public String dateOfBirthGurantor { get; set; }
    public String dateOfBirthGurantorNonInd { get; set; }
    //public String coBorrowerDetails { get; set; }
    //public Decimal sanctionAmount { get; set; }
    public String loanTenure { get; set; }
    //public String noOfInstalments { get; set; }
    public String typeOfEpi { get; set; }
    public String amountOfEachEpi { get; set; }
    public Decimal amountOfEachEpiInteger { get; set; }
    public Decimal amountOfSecondEpiInteger { get; set; }
    public String noOfepis { get; set; }
    public String interestRateOfType { get; set; }
    public String effectiveROI { get; set; }
    public String totalCharges { get; set; }
    public String netDisbuseAmt { get; set; }
    public String annualPercentageRate { get; set; }
    public String grossLoanLTV { get; set; }
    public String advanceEmi { get; set; }
    public String moratoriumDays { get; set; }
    //public String endUseOfFunds { get; set; }
    public Boolean isShowNotNew { get; set; }
    public String offAddress1 {get; set;}
    public String offAddress2 {get; set;}
    public String offAddress3 {get; set;}
    public String offAddress4 {get; set;}
    public String offAddressCity {get; set;}
    public String offAddressPincode {get; set;}
    public String offAddressState {get; set;}
    public String offAddressDistrict {get; set;}
    public Boolean IsSameAsper {get; set;}
    public Documents__c permanentResDocument{get;set;}
    public KFS_Applicant__c currentResDocument{get;set;}
    public Key_Fact_Statement__c keyFactDetails{get;set;}
    public List<Key_Fact_Statement__c> keyFactDealList{get;set;}
    public List<Key_Fact_Statement__c> keyFactEmiDates{get;set;}
    public List<KFS_Applicant__c> keyFactApplicantList{get;set;}
    public List<KFS_Instalment_Schedule__c> keyFactInstalment{get;set;}
    public KFS_Instalment_Schedule__c keyFactInstalmentForMultiDeals{get;set;}
    // public  Applicant__c app{get;set;}
    // public  Vehicle_Detail__c vehdetails{get;set;}
    // public  List<Final_Term__c> FinalTermList{get;set;}
    // public  List<Vehicle_Detail__c> vehiclelist{get;set;}
    // public  List<EMI_Schedule__c> emiScheduleList{get;set;}
    // public  List<InsuranceDetails__c> insuranceAmounts{get;set;}
    public  List<Date> dateList{get;set;}
    public  String currentRecordId {get;set;}
    public  String currentRecordurl {get;set;}
    //public  String currentRecordVehId {get;set;}
    //public  string currentDistrict {get;set;}
    //public  string parmanentDistrict {get;set;}
    public  string LoanAmount {get;set;}
    public  boolean isSubmitted{get;set;}
    public  String proposalMCLR{get;set;}
    //public  String Label;
    public  KFS_Applicant__c currentResDocumentCoBorrower{get;set;}
    public  string currentDistrictCobo {get;set;}
    public  List<Applicant__c> coBorrowerList{get;set;}
    public  Boolean coBorrowerCheck {get;set;}
    public  String loanapId;
    public  String DocID;
    public  Decimal totalChargesDecimal{get;set;}
   // public  Decimal netDisbuseAmtDecimal{get;set;}
    public  String mobileNo{get;set;}
    public String mobileNoGurantor{get;set;}
    public  String mobileNoWithoutMask{get;set;}
    public  Decimal effectiveROIdecimal{get;set;}
    public  String voterNo{get;set;}
    public  String voterNoGurantor{get;set;}
    public  String sanctionConsentSentTime{get;set;}
    public  String sanctionConsentReceivedTime{get;set;}
    //public  Boolean smsTriggerCheck{get;set;}
    public  Boolean acceptCheck{get;set;}
    public  Boolean notAcceptCheck{get;set;}
    public  Boolean needClarification{get;set;}
    public  Boolean isButtonDisabled {get;set;}
    public  String panOpenNumber{get;set;}
    public  String voteropenNumber{get;set;}
    public  Integer tenureInYears{get;set;}
    public  Decimal serviceCharges{get;set;}
    public  Decimal documentationCharges{get;set;}
    public Decimal stampingCharges{get;set;}
    public Decimal valuationPrice{get;set;}
    public  String emailId{get;set;}
    public  Decimal totalIntrestAmount{get;set;}
    public String totalIntrestAmountwithINR{get;set;}
    public Decimal totalAmountPaidByBorrower{get;set;}
    public String totalAmountPaidByBorrowerwithINR{get;set;}
    public String firstEmiDate{get;set;}
    public string dateinString{get;set;}
    public string secondEmiDateString{get;set;}
    public Decimal sanctionNeedClarificationCount{get;set;}
    public boolean hasError {get;set;}
    //public boolean officeAddress {get;set;}
    //public boolean currentAddress {get;set;}
    //public boolean perminentAddress{get;set;}
    public boolean linkExpired {get;set;}
    public Decimal totalInsuranceAmount{get;set;}
    public Boolean SOCtwoWheeler{get;set;}
    public Boolean SOCpvNew{get;set;}
    public Boolean SOCtfNew{get;set;}
    public String totalInterestAmount{get;set;}
    public String totalPaidByBorrower{get;set;}
    public Decimal payableRE {get;set;}
    public String UCIC {get;set;}
    public String CKYCID {get;set;}
    public boolean proAssureDeals{get;set;}
    public Key_Fact_Statement__c KeysParentDeatails {get;set;}
    public String EntityType {get;set;}
    public boolean acceptButtonEnable {get; set;}
        // public boolean  getlinkExpired() {
        // currentRecordId  =  ApexPages.CurrentPage().getparameters().get('id');
        // currentRecordurl  =  ApexPages.CurrentPage().getparameters().get('connum');
        // Key_Fact_Statement__c  kfsdetails = [SELECT id,Keyfact_Consent_OTP__c,Keyfact_Form_SMS_Sent__c,Deal_Number__c from Key_Fact_Statement__c
        // where id =: currentRecordId];
        //String Dealnumber = kfsdetails.Deal_Number__c; 
    //     Applicant__c applicant=[SELECT id,Sanction_Consent_OTP__c,Sanction_Form_SMS_Sent__c from Applicant__c
    //                             where id =: currentRecordId WITH SECURITY_ENFORCED];                 
        // Long currentDateTime = DateTime.now().getTime();
        
       // Key_Fact_Statement__c latestKFS = [SELECT Id,Keyfact_Consent_OTP__c,Keyfact_Form_SMS_Sent__c FROM Key_Fact_Statement__c WHERE Deal_Number__c= 'testc' ORDER BY CreatedDate DESC LIMIT 1];


    //     if(vehdetails.Sanction_Form_SMS_Sent__c!=null && vehdetails.Product__c == 'Tractor'){
    //         Long consentSentOnDate = vehdetails.Sanction_Form_SMS_Sent__c.getTime();
    //         Long difference = (currentDateTime-consentSentOnDate)/60000;     
    //         system.debug('The currentDateTime : '+ currentDateTime+'consentSentOnDate:  '+ consentSentOnDate+'difference: '+difference);
    //         if(difference > 4320){                
    //             system.debug('it is '+true);
    //             return true;
    //         }
    //         else{
    //             system.debug('it is '+false);
    //             if(currentRecordurl == vehdetails.Sanction_Consent_OTP__c){
    //                 system.debug('update link '+false);
    //                 return false;
    //             }
    //             else if (currentRecordurl != vehdetails.Sanction_Consent_OTP__c){
    //                 system.debug('New link '+false);
    //                 return true;
    //             }
    //             else{
    //                 return true;
    //             }
                
    //         }
//    if(currentRecordurl == kfsdetails.Keyfact_Consent_OTP__c){
//         system.debug('update link '+false);
//         if(kfsdetails.Keyfact_Form_SMS_Sent__c != null){
//             Long consentSentOnDate = kfsdetails.Keyfact_Form_SMS_Sent__c.getTime();
//             Long difference = (currentDateTime-consentSentOnDate)/60000;     
//             system.debug('The currentDateTime : '+ currentDateTime+'consentSentOnDate:  '+ consentSentOnDate+'difference: '+difference);
//             if(difference > 4320){                
//                 system.debug('it is '+true);
//                 return true;
//             }
//             else{
//                 system.debug('it is '+false);
//                 return false;
//             }
//         }else{
//             return true;
//         }
//     }
//     else{
//         system.debug('New link '+false);
//         return true;
//     }    
//  }
    
    public SanctionLetterController() {
        isShowNotNew =false; 
        coBorrowerCheck = false; 
        proAssureDeals = false;      
        acceptButtonEnable = false; 
        //entityType = false;   
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id'); 
        isButtonDisabled = false;  linkExpired = false;
    //keyFactInstalmentForMultiDeals = new List<KFS_Instalment_Schedule__c> ();
        KeysParentDeatails = [SELECT id,KFS_Type__c,Keyfact_Consent_Need_Clarification__c,Keyfact_Consent_Not_Accepted__c,Keyfact_Consent_Accepted__c,Keyfact_Form_SMS_Sent__c,Entity_Type__c FROM Key_Fact_Statement__c WHERE id=: currentRecordId limit 1];
      // keyFactDetails = [SELECT id,Type_Of_Instalments__c,Total_Interest_Amount__c,Total_Amount_Paid_By_Borrower__c,APR__c,MCLR__c,Make__c, Model__c,Advance_EMI_Number__c,Chassis_number__c,CRM_IRR__c,Deal_Number__c,Deal_Period__c,Dealer_Sub_dealer_name__c,Document_Charges__c,Engine_Number__c,Valuation_price__c,First_EMI_Date__c,Gross_IRR__c,Gross_LTV__c,Key_Fact_Statement__c,Lead_Number__c,Loan_Amount__c,Mfg_Year__c,Moratorium__c,Net_Disburse_Amount__c,Product__c,Service_Charges__c,Stamping_Charges__c,Vehicle_Registration_number__c,Vehicle_Sub_Category__c,Keyfact_Form_SMS_Sent__c,Keyfact_Consent_Accepted__c,Keyfact_Consent_Not_Accepted__c,Keyfact_Consent_Need_Clarification__c FROM 	Key_Fact_Statement__c where Id=:currentRecordId limit 1];
       keyFactDealList = [SELECT id,Net_Disbursement_APR__c,Deal_Date__c,GST_Number__c,Effetive_From_Date__c,BL_Code__c,	BL_Name__c,IHM_Computed__c,Loan_Amount_Chassis__c,Sold_By_Dealer_Name__c,Installment_Pattern_Type__c,Total_Insurance_Funded_By_Customer__c,Total_Insurance_Funded_By_Bank__c,Entity_Type__c,Insurance_Tata_Emi_Premium__c,Insurance_Tata_Emi_Fund_Type__c,Insurance_Premium_Paid_I__c,Insurance_Premium_I__c,Insurance_Premium__c,Insurance_Subh_Raksha_Premium_G__c,Insurance_Subh_Raksha_Premium__c,Invoice_Amount__c,Insurance_LI_Premium_G__c,Insurance_LI_Premium__c,Insurance_LI_Fund_Type_G__c,Insurance_LI_Fund_Type__c,Insurance_Motor_Fund_Type__c,Insurance_Combo_Fund_Type__c,Insurance_Combo_Fund_Type_G__c,Insurance_Combo_Premium__c,Insurance_Combo_Premium_G__c,Insurance_Combo_Product__c,Insurance_Combo_Product_G__c,Insurance_Flexi_Fund_Type__c,Insurance_Flexi_Premium__c,Insurance_Flexi_Fund_Type_G__c,Insurance_Flexi_Premium_G__c,Insurance_GPA_Type_G__c,Insurance_GPA_Type__c,Insurance_GPA_Premium_G__c,Insurance_GPA_Premium__c,Insurance_Health_Premium_G__c,Insurance_Health_Premium__c,Insurance_Health_Fund_Type_G__c,Insurance_Health_Fund_Type__c,Instalment_Numbers__c,Service_Charges_Without_Gst__c,Service_Charges_Gst_Value__c,Document_Charges_Gst_Value__c,Document_Charges_Without_Gst__c,Vehicle_Category__c,Variant__c,Type_Of_Instalments__c,Total_Interest_Amount__c,Total_Amount_Paid_By_Borrower__c,APR__c,MCLR__c,Make__c, Model__c,Advance_EMI_Number__c,Chassis_number__c,CRM_IRR__c,Deal_Number__c,Deal_Period__c,Dealer_Sub_dealer_name__c,Beneficiary_Code__c,Document_Charges__c,Engine_Number__c,Valuation_price__c,First_EMI_Date__c,Second_EMI_Date__c,Gross_IRR__c,Gross_LTV__c,Key_Fact_Statement__c,Lead_Number__c,Loan_Amount__c,Mfg_Year__c,Moratorium__c,Net_Disburse_Amount__c,Product__c,Service_Charges__c,Stamping_Charges__c,Vehicle_Registration_number__c,Vehicle_Sub_Category__c,Keyfact_Form_SMS_Sent__c,Keyfact_Consent_Accepted__c,Keyfact_Consent_Not_Accepted__c,Keyfact_Consent_Need_Clarification__c ,(SELECT id,Balance__c,Principal__c,Interest__c,EMI_Amount__c,Instal_Date__c,Instal_Number__c FROM KFS_Instalment_Schedule__r)FROM 	Key_Fact_Statement__c where Key_Fact_Statement__c=:currentRecordId];
        
       keyFactEmiDates = [SELECT id,(SELECT id,Balance__c,Principal__c,Interest__c,EMI_Amount__c,Instal_Date__c,Instal_Number__c FROM KFS_Instalment_Schedule__r LIMIT 2)FROM Key_Fact_Statement__c where Key_Fact_Statement__c=:currentRecordId Limit 2];
       keyFactApplicantList = [SELECT id,Customer_Type__c,Form60__c,UCIC__c,CKYC_ID__c,Aadhaar_Number__c,Applicant_Type__c,Customer_Code__c,Customer_Name__c,Salutation__c,Date_of_Birth__c,Driving_License_Expiry_Date__c,Driving_License_Number__c,Key_Fact_Statement__c,Mobile_Number__c,Office_Address_Flag__c,Office_Address_Line_1__c,
       Office_Address_Line_2__c,Office_Address_Line_3__c,Office_Address_Line_4__c,Office_City__c,Office_District__c,Office_Pin_code__c,Office_State__c,PAN_GIR_Number__c,	Passport_Expiry_Date__c,Passport_Number__c,Permanent_Address_Flag__c,Permanent_Address_Line_1__c,Permanent_Address_Line_2__c,
       Permanent_Address_Line_3__c,Permanent_Address_Line_4__c,Permanent_City__c,	Permanent_District__c,Permanent_Pin_code__c,Regn_Incorp_Date__c,Permanent_State__c,Residential_Address_Flag__c,Residential_Address_Line_1__c,Residential_Address_Line_2__c,	Residential_Address_Line_3__c,Residential_Address_Line_4__c,Voter_ID_Number__c,
       SurName__c,Residential_City__c,Residential_District__c,Residential_Pin_code__c,Residential_State__c,Communication_Address_Flag__c FROM KFS_Applicant__c where Key_Fact_Statement__c =: keyFactDealList[0].id ];
      keyFactInstalment = [SELECT id,Principal__c,Interest__c,Balance__c,Combo_Amount__c,Deal_Number__c,EMI_Amount__c,From_Month__c,Health_Amount__c,Hospital_Cash_Amount__c,Instal_Amount__c,Instal_Date__c,Instal_Number__c,	Insur_Amount__c,Key_Fact_Statement__c,POSB_Charges__c,RD_Amount__c,	To_Month__c FROM KFS_Instalment_Schedule__c where Key_Fact_Statement__c =: keyFactDealList[0].id];
            // loanapId = app.Opportunity__c;
if(KeysParentDeatails.Keyfact_Consent_Accepted__c == true){
                    acceptCheck = true;
                      hasError = true;
                   }
                    if(KeysParentDeatails.Keyfact_Consent_Not_Accepted__c == true){
                      notAcceptCheck = true;
                       hasError = true;
                   }
                    if(KeysParentDeatails.Keyfact_Consent_Need_Clarification__c == true){
                        needClarification = true;
                       hasError = true;
                   }else{
                    isSubmitted = true;
                   }
                   if(KeysParentDeatails.Keyfact_Consent_Accepted__c == true || KeysParentDeatails.Keyfact_Consent_Not_Accepted__c == true || KeysParentDeatails.Keyfact_Consent_Need_Clarification__c == true){
                    isSubmitted = false;
                    hasError = true;
                    }
                    if(KeysParentDeatails.KFS_Type__c == 'Digital'){
                        acceptButtonEnable = true;
                    }
                    // if(KeysParentDeatails.Entity_Type__c == 'NON'){
                    //    entityType = true;
                    // }
                   
            if(keyFactApplicantList != null){     
              for(KFS_Applicant__c appData : keyFactApplicantList){
                if(appData.Applicant_Type__c == 'Borrower' ){
                    customerName = appData.Customer_Name__c != null ? appData.Customer_Name__c:'';
                    CustomerLastName =  appData.SurName__c != null ? appData.SurName__c:'';
                    customerCode = appData.Customer_Code__c != null ? appData.Customer_Code__c:'';
                    mobileNoWithoutMask = appData.Mobile_Number__c != null ? appData.Mobile_Number__c:'';
                    UCIC = appData.UCIC__c != null ? appData.UCIC__c:'';
                    CKYCID = appData.CKYC_ID__c != null ? appData.CKYC_ID__c:'';
                                        mobileNo = maskOddCharacters(mobileNoWithoutMask);
                    if(appData.Office_Address_Flag__c != null && appData.Office_Address_Flag__c == 'O'){
                        offAddress1 = appData.Office_Address_Line_1__c != null ? appData.Office_Address_Line_1__c:'';
                        offAddress2 = appData.Office_Address_Line_2__c != null ? appData.Office_Address_Line_2__c:'';
                        offAddress3 = appData.Office_Address_Line_3__c != null ? appData.Office_Address_Line_3__c:'';
                        offAddress4 = appData.Office_Address_Line_4__c != null ? appData.Office_Address_Line_4__c:'';
                        offAddressCity = appData.Office_City__c != null ? appData.Office_City__c:'';
                        offAddressPincode = appData.Office_Pin_code__c != null ? appData.Office_Pin_code__c:'';
                        offAddressState = appData.Office_State__c != null ? appData.Office_State__c:'';
                        offAddressDistrict = appData.Office_District__c != null ? appData.Office_District__c:''; 
                        // officeAddress = true;   
                    }
                    if(appData.Customer_Type__c != null){
                        EntityType = appData.Customer_Type__c;
                    }
                    // else if(appData.Permanent_Address_Flag__c != null && appData.Permanent_Address_Flag__c == 'P'){
                    //     perminentAddress = true;
                    // }else if(appData.Residential_Address_Flag__c != null && appData.Residential_Address_Flag__c == 'R'){
                    //     currentAddress = true;
                    // }
                    if(appData.PAN_GIR_Number__c != null){
                        panOpenNumber = appData.PAN_GIR_Number__c;
                        panNumber = maskOddCharacters(panOpenNumber);
                    }
                    if(appData.Voter_ID_Number__c != null){voteropenNumber = appData.Voter_ID_Number__c;
                        voterNo = maskOddCharacters(voteropenNumber);}
                    if(appData.Aadhaar_Number__c != null){aadhaar ='**** **** '+String.valueof(appData.Aadhaar_Number__c).right(4);//CISP-3038
                } if(appData.Date_of_Birth__c != null){
                    dateOfBirth = (appData.Date_of_Birth__c).substringBefore(' ');
                }if(appData.Regn_Incorp_Date__c != null){
                    dateOfBirthNonInd = (appData.Regn_Incorp_Date__c).substringBefore(' ');
                }
                    passportNo = appData.Passport_Number__c != null ? '**** **** **** ***':'';
                    drivingLicenseNO = appData.Driving_License_Number__c != null ? '**** **** **** ***':'';
                    if(appData.Driving_License_Expiry_Date__c != null){
                        drivingLicenseExpiryDate = appData.Passport_Expiry_Date__c;    
                    }
                    if(appData.Passport_Expiry_Date__c != null){
                        passportExpiryDate = appData.Passport_Expiry_Date__c;    
                    }
                    currentResDocument = appData;
                }
                  if((appData.Applicant_Type__c == 'Co-borrower') || (appData.Applicant_Type__c == 'Guarantor')){
                        coBorrowerCheck = true;
                         String mobileNoWithoutMaskGurantor = appData.Mobile_Number__c != null ? appData.Mobile_Number__c:'';
                         mobileNoGurantor = maskOddCharacters(mobileNoWithoutMaskGurantor);
                        if(appData.PAN_GIR_Number__c != null){
                            String panOpenNumberGurantor = appData.PAN_GIR_Number__c;
                            panNumberGurantor = maskOddCharacters(panOpenNumberGurantor);
                        }
                        if(appData.Voter_ID_Number__c != null){String voteropenNumberGurantor = appData.Voter_ID_Number__c;
                            voterNoGurantor = maskOddCharacters(voteropenNumberGurantor);}
                        if(appData.Aadhaar_Number__c != null){aadhaarGurantor ='**** **** '+String.valueof(appData.Aadhaar_Number__c).right(4);//CISP-3038
                    } if(appData.Date_of_Birth__c != null){
                        dateOfBirthGurantor = (appData.Date_of_Birth__c).substringBefore(' ');
                    }if(appData.Regn_Incorp_Date__c != null){
                        dateOfBirthGurantorNonInd = (appData.Regn_Incorp_Date__c).substringBefore(' ');
                    }

                        passportNoGurantor = appData.Passport_Number__c != null ? '**** **** **** ***':'';
                        drivingLicenseNOGurantor = appData.Driving_License_Number__c != null ? '**** **** **** ***':'';
                        currentResDocumentCoBorrower = appData;
                        customerCodeCoborrower = appData.Customer_Code__c != null ? appData.Customer_Code__c:'' ;
                        nameOfCoborrower = appData.Customer_Name__c != null ? appData.Customer_Name__c:'' ;
                        // if(currentResDocumentCoBorrower.KYC_District__c !=null ){
                        //     currentDistrictCobo = currentResDocumentCoBorrower.KYC_District__c ;
                        // }else{
                        //     currentDistrictCobo = currentResDocumentCoBorrower.KYC_City__c ;
                        // }
                }
              }
            }  
            if(keyFactDealList.size() > 0){
                for(Key_Fact_Statement__c appData : keyFactDealList){
                    String proAssure = appData.Deal_Number__c != null ? appData.Deal_Number__c:'';

                    if(proAssure.startswith('1')){
                        proAssureDeals = true;
                     }
                     system.debug('testting1'+proAssureDeals);
                    typeOfEpi = appData.Type_Of_Instalments__c == 'M' ? 'Monthly' : appData.Type_Of_Instalments__c == 'Q' ? 'Quarterly' : appData.Type_Of_Instalments__c == 'H' ? 'Half yearly':'';
                    totalIntrestAmountwithINR = appData.Total_Interest_Amount__c != null ? 'INR '+appData.Total_Interest_Amount__c:'';  
                    
                       if(appData.Vehicle_Sub_Category__c != 'New'){
                        isShowNotNew = true;
                     }
                    
                     
                    // System.debug(s1.startswith('ThoMas'));
              //totalInterestAmount = keyFactDetails.Total_Interest_Amount__c != null ? keyFactDetails.Total_Interest_Amount__c:'';
              //totalPaidByBorrower = keyFactDetails.Total_Amount_Paid_By_Borrower__c != null ? keyFactDetails.Total_Amount_Paid_By_Borrower__c:'';
              product = appData?.Variant__c;//appData?.Make__c  + '  ' + 
              productSegment = appData?.Product__c == 'H' ? 'Two Wheeler': appData?.Product__c == 'C' ? 'Passenger Vehicles' :appData?.Product__c == 'D' ? 'Commercial Vehicles':appData?.Product__c == 'E' ? 'Construction Equipment':appData?.Product__c == 'G' ? 'Small Commercial Vehicle':appData?.Product__c == 'L' ? 'Light Commercial Vehicle': appData?.Product__c == 'S' ? 'Refinance Two Wheeler':appData?.Product__c == 'T' ? 'Tractors and Farm Equipment':'';
              if(appData?.Product__c == 'H'){
                SOCtwoWheeler = true;
              }else if(appData?.Product__c == 'C'){
                if(appData.Vehicle_Category__c == 'N'){
                SOCpvNew = true;
                }else{
                SOCpvNew = false; 
                }
              }else if(appData?.Product__c == 'T'){
                if(appData.Vehicle_Category__c == 'N'){
                    SOCtfNew = true;
                    }else{
                    SOCtfNew = false; 
                    }
              }
            //    variant = vehdetails.Variant__c != null ? vehdetails.Variant__c:'';
               vehicleType = appData.Vehicle_Sub_Category__c != null ? appData.Vehicle_Sub_Category__c:'';
               engineNo = appData.Engine_number__c != null ? appData.Engine_number__c:'';
               chassisNo = appData.Chassis_number__c != null ? appData.Chassis_number__c:'';
            if(appData.Mfg_Year__c != null){
            yearOfManufacture = appData.Mfg_Year__c;
            }
               registrationNumber = appData.Vehicle_Registration_number__c != null ? appData.Vehicle_Registration_number__c:'';
               dealer =  appData.Dealer_Sub_dealer_name__c+' ' +'|'+' '+appData.Beneficiary_Code__c;//+appData?.Ben_Code__c
                    Decimal serCharge = appData.Service_Charges_Without_Gst__c ;
                    Decimal docCharge = appData.Document_Charges_Without_Gst__c ;
                    Decimal stampCharge = appData.Service_Charges_Gst_Value__c ;
                    Decimal valuationCharge = appData.Service_Charges_Without_Gst__c;
                    payableRE = serCharge + docCharge + stampCharge + valuationCharge;

                    //Decimal verficationCharge = FinalTermList[0]?.Verification_charges__c != null ? Decimal.Valueof(FinalTermList[0]?.Verification_charges__c):0;
                    totalChargesDecimal = serCharge + docCharge + stampCharge + valuationCharge;//valuationPrice
                    totalCharges = 'INR '+(totalChargesDecimal);
                    serviceCharges = serCharge;
                    documentationCharges = docCharge;
                    stampingCharges = stampCharge;
                    valuationPrice = valuationCharge;
                    Decimal  netDisbuseAmtDecimal = appData.Net_Disburse_Amount__c ;
                    netDisbuseAmt ='INR '+netDisbuseAmtDecimal;
                    LoanAmount = 'INR '+appData.Loan_Amount__c;
                   
                    if(appData.CRM_IRR__c!=null)
                    {    
                        effectiveROIdecimal = (appData.CRM_IRR__c).setScale(4);
                        effectiveROI = effectiveROIdecimal+'%';
                    }  
                    if(appData.Deal_Period__c != null){
                        loanTenure = appData.Deal_Period__c +' '+ 'Months';
                    }
                    // loanTenure = 40 +'Months';
                    //noOfepis = '36'; 
                    //amountOfEachEpi = 'INR '+800;
                    
                    // if(FinalTermList[0].Tenure__c!=null) {loanTenure = FinalTermList[0].Tenure__c +' Months';
                    //      tenureInYears = (Integer.valueof(FinalTermList[0].Tenure__c)/ 12);
                    // }
                    if(appData.First_EMI_Date__c !=null) {firstEmiDate = appData.First_EMI_Date__c;
                        dateinString = firstEmiDate.substringBefore(' ');    
               }
                    if(appData.Moratorium__c != null) {moratoriumDays = appData.Moratorium__c +' Days';
                    noOfepis =  appData.Moratorium__c == '30' ? String.valueof(Integer.valueOf(appData.Deal_Period__c) - 1) : appData.Moratorium__c == '0' ? appData.Deal_Period__c : '';
                    }
                // if(keyFactDetails.First_EMI_Date__c!=null) {amountOfEachEpi = 'INR '+800;
                // }
                    Decimal grossltv = appData.Gross_LTV__c != null ? Decimal.Valueof(appData.Gross_LTV__c).setScale(2):0;
                    grossLoanLTV = grossltv +' %';
            if(appData.Advance_EMI_Number__c !=null) {
                if(appData.Advance_EMI_Number__c == '0'){
                    advanceEmi = 'Not Applicable';
                }else{
                    advanceEmi ='true';
                }
        }
        // if(FinalTermList[0].EMI_Amount__c!=null && FinalTermList[0].Holiday_period__c!=null){
        //    Decimal noOFInstal = Decimal.valueOf(FinalTermList[0].Holiday_period__c) == 30 ? Decimal.valueOf(FinalTermList[0].Tenure__c) - 1 : Decimal.valueOf(FinalTermList[0].Holiday_period__c) == 0 ? Decimal.valueOf(FinalTermList[0].Tenure__c) : 0;
        //    Decimal loanamountforCal = Decimal.valueOf(FinalTermList[0].Loan_Amount__c);
        //    Decimal amountofEmi = FinalTermList[0].EMI_Amount__c;
        //    totalIntrestAmount = ((noOFInstal * amountofEmi)-(loanamountforCal));
        //    totalAmountPaidByBorrower = (totalIntrestAmount + loanamountforCal);
           totalAmountPaidByBorrowerwithINR = appData.Total_Amount_Paid_By_Borrower__c != null ? 'INR '+appData.Total_Amount_Paid_By_Borrower__c:'';
           
        // }
        // if(FinalTermList[0].Installment_Type__c != null){
        //         // dateList = new List<Date>();
        //         emiScheduleList = [SELECT Id,EMI_Due_Date__c,Number_of_Installments__c, EMI_Amount__c, Opening_Principal__c, Principal_Component__c, Interest_Component__c, Closing_Principal__c, Installment_Type__c,From_Month__c,To_Month__c,Loan_Application__c FROM EMI_Schedule__c where Loan_Application__c=:app.Opportunity__c];
        //         // for(EMI_Schedule__c emidata : emiScheduleList){
        //         //     if (emidata.EMI_Due_Date__c != null) {
        //         //         dateList.add(emidata.EMI_Due_Date__c.date()); // Convert DateTime to Date
        //         //     }
        //         // }
        // }
        
        if(appData.APR__c !=null) {annualPercentageRate = appData.APR__c +' %';
        }
        if(appData.MCLR__c !=null) {proposalMCLR = appData.MCLR__c +' %';
        }
        // List<MCLR_Master__c > proposalMCLRList = new List<MCLR_Master__c >();
                            
        //                     Decimal tenure = FinalTermList[0].Tenure__c != null ? Decimal.valueOf(FinalTermList[0].Tenure__c) : 0;
        //                     proposalMCLRList = [Select MCLR__c from MCLR_Master__c where Rate_Type__c = 'MCLR' AND Nature__c = 'FXD' AND Flag__c = 'L' AND Eff_from_date__c  <= TODAY And Period__c >= : tenure Order by Period__c ASC LIMIT 1];
        //                     proposalMCLR = proposalMCLRList.size() > 0 && proposalMCLRList[0].MCLR__c != null ? String.valueOf(proposalMCLRList[0].MCLR__c)+' %' : '';
                 sanctionConsentReceivedTime = getDateTimeFormat(DateTime.now());
        //        if(app.Sanction_Consent_Accepted__c == true || app.Sanction_Consent_Not_Accepted__c == true || app.Sanction_Consent_Need_Clarification__c == true){
        //           isSubmitted = false;
        //           hasError = true;
        //         }
                interestRateOfType = 'Fixed';
                loanApplicationNo = appData.Lead_Number__c != null ? appData.Lead_Number__c:'';
                Date todayDate = Date.today();
                sanctionDate = getDateTimeFormat(KeysParentDeatails.Keyfact_Form_SMS_Sent__c);
               // sanctionNeedClarificationCount = app.Sanction_Consent_NeedClarification_Count__c != null ? app.Sanction_Consent_NeedClarification_Count__c:0;
                    // if(doc.Current_Residential_Address_Proof__c){
                    //     currentResDocument = doc;
                    //     if(currentResDocument.KYC_District__c !=null ){
                    //         currentDistrict = currentResDocument.KYC_District__c ;
                    //     }else{
                    //         currentDistrict = currentResDocument.KYC_City__c ;
                    //     }
                    // }
                    // system.debug('The per resi '+doc.Permanent_Residential_Address_Proof__c);
                    // if(doc.Permanent_Residential_Address_Proof__c){
                    //     permanentResDocument = doc;
                    //     if(permanentResDocument.KYC_District__c !=null ){ parmanentDistrict = permanentResDocument.KYC_District__c ;
                    //     }else{
                    //         parmanentDistrict = permanentResDocument.KYC_City__c ;
                    //     }
                        
                    // }else if(doc.Applicant__r.Current_Same_As_Permanent__c && doc.Current_Residential_Address_Proof__c){
                    //     currentResDocument = doc;
                    //     if(currentResDocument.KYC_District__c !=null ){
                    //         currentDistrict = currentResDocument.KYC_District__c ;
                    //     }else{
                    //         currentDistrict = currentResDocument.KYC_City__c ;
                    //     }
                        
                    // }
                    // if(doc.Applicant__r.Current_Same_As_Permanent__c)
                    // {
                        IsSameAsper = false;
                        if(appData.Keyfact_Form_SMS_Sent__c != null){
                        sanctionConsentSentTime =  getDateTimeFormat(appData.Keyfact_Form_SMS_Sent__c);
                        }
                        // for(KFS_Instalment_Schedule__c kfsInstalSchedule : [SELECT id,Combo_Amount__c,Deal_Number__c,EMI_Amount__c,From_Month__c,Health_Amount__c,Hospital_Cash_Amount__c,Instal_Amount__c,Instal_Date__c,Instal_Number__c,	Insur_Amount__c,Key_Fact_Statement__c,POSB_Charges__c,RD_Amount__c,	To_Month__c FROM KFS_Instalment_Schedule__c where Key_Fact_Statement__c =: appData.id]){
                        //     // Decimal amountofepi = keyFactInstalment[0].EMI_Amount__c != null ? Decimal.Valueof(keyFactInstalment[0].EMI_Amount__c).setScale(2):keyFactInstalment[1].EMI_Amount__c != null ? Decimal.Valueof(keyFactInstalment[1].EMI_Amount__c).setScale(2):0;
                        //     // amountOfEachEpi = 'INR'+' '+amountofepi;
                        //     keyFactInstalment.add(kfsInstalSchedule);
                        // }
        
                    // }
                }
            }
    //         currentResDocumentCoBorrower = [SELECT id,CKYC_ID__c,UCIC__c,Aadhaar_Number__c,Applicant_Type__c,Customer_Code__c,Customer_Name__c,Salutation__c,Date_of_Birth__c,Driving_License_Expiry_Date__c,Driving_License_Number__c,Key_Fact_Statement__c,Mobile_Number__c,Office_Address_Flag__c,Office_Address_Line_1__c,
    //    Office_Address_Line_2__c,Office_Address_Line_3__c,Office_Address_Line_4__c,Office_City__c,Office_District__c,Office_Pin_code__c,Office_State__c,PAN_GIR_Number__c,	Passport_Expiry_Date__c,Passport_Number__c,Permanent_Address_Flag__c,Permanent_Address_Line_1__c,Permanent_Address_Line_2__c,
    //    Permanent_Address_Line_3__c,Permanent_Address_Line_4__c,Permanent_City__c,	Permanent_District__c,Permanent_Pin_code__c,Regn_Incorp_Date__c,Permanent_State__c,Residential_Address_Flag__c,Residential_Address_Line_1__c,Residential_Address_Line_2__c,	Residential_Address_Line_3__c,Residential_Address_Line_4__c,Voter_ID_Number__c,
    //    SurName__c,Residential_City__c,Residential_District__c,Residential_Pin_code__c,Residential_State__c,Communication_Address_Flag__c FROM KFS_Applicant__c where Applicant_Type__c != 'Borrower' AND Key_Fact_Statement__c =: keyFactDealList[0].id ];
             // isSubmitted = true;
             totalInsuranceAmount = 0;
             sanctionNeedClarificationCount = 1;
            // valuationPrice = app.Opportunity__r?.Valuation_price__c != null ? app.Opportunity__r?.Valuation_price__c:0; 
        if(keyFactInstalment.size()>0){
            Decimal amountofepi = keyFactInstalment[0].EMI_Amount__c != 0 ? keyFactInstalment[0].EMI_Amount__c:keyFactInstalment[1].EMI_Amount__c != 0 ? keyFactInstalment[1].EMI_Amount__c:0;
            amountOfEachEpiInteger = keyFactInstalment[0].EMI_Amount__c != 0 ? keyFactInstalment[0].EMI_Amount__c:keyFactInstalment[1].EMI_Amount__c != 0 ? keyFactInstalment[1].EMI_Amount__c:0;
            amountOfSecondEpiInteger = keyFactInstalment[1].EMI_Amount__c != 0 ? keyFactInstalment[1].EMI_Amount__c:keyFactInstalment[2].EMI_Amount__c != 0 ? keyFactInstalment[2].EMI_Amount__c:0;
            amountOfEachEpi = 'INR'+' '+amountofepi;
            String secondEmiDate  =  keyFactInstalment[1].Instal_Date__c != null ? keyFactInstalment[1].Instal_Date__c:'';
            secondEmidateString = secondEmiDate.substringBefore(' ');
        }
        // if(!insuranceAmounts.isEmpty()){
        //     Decimal total = 0;
        //     for (InsuranceDetails__c insAmt : insuranceAmounts) {
        //         total += insAmt.Amount__c;
        //     }
        //     totalInsuranceAmount = total;
        // }
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
    
        public static String maskOddCharacters(String input) {
            string newstring = '';
            List<String> newstrin = input.split('');
    
            for (Integer i = 0; i < input.length(); i++) {
                if (Math.Mod(i, 2)== 1) {
                    newstring = newstring+'*';
                }else{
                    newstring = newstring+newstrin[i];  
                }
            }
            
            return newstring;
        }
    public PageReference acceptandRender(){    
        try{
            List<Key_Fact_Statement__c> keyFactAcceptData = [SELECT Id,Lead_Number__c,Keyfact_Consent_Accepted__c,Keyfact_Consent_Not_Accepted__c,Keyfact_Consent_Need_Clarification__c,Keyfact_Consent_Received_Time__c,Keyfact_Form_SMS_Sent__c,Keyfact_Consent_OTP__c,Loan_Application__c,Loan_Application__r.name,Deal_Number__c,ProCredit_Deal__c FROM Key_Fact_Statement__c WHERE Id =:currentRecordId  WITH SECURITY_ENFORCED];
            List<Key_Fact_Statement__c> keyFactAcceptDataApp = [SELECT Id,Lead_Number__c,Keyfact_Consent_Accepted__c,Keyfact_Consent_Not_Accepted__c,Keyfact_Consent_Need_Clarification__c,Keyfact_Consent_Received_Time__c,Keyfact_Form_SMS_Sent__c,Keyfact_Consent_OTP__c,Loan_Application__c,Loan_Application__r.name,Deal_Number__c,ProCredit_Deal__c FROM Key_Fact_Statement__c WHERE Key_Fact_Statement__c =:currentRecordId  WITH SECURITY_ENFORCED];

        
            if(keyFactAcceptData[0].Keyfact_Consent_Accepted__c == true){
            acceptCheck = true;
            hasError = true;
            } else if(keyFactAcceptData[0].Keyfact_Consent_Not_Accepted__c == true){
            notAcceptCheck = true;
            hasError = true;
            }else if(keyFactAcceptData[0].Keyfact_Consent_Need_Clarification__c == true){
            needClarification = true;
            hasError = true;
            }
            sanctionConsentReceivedTime = getDateTimeFormat(DateTime.now());
            //smsTriggerCheck = true;
            Boolean fromProCre = false;
            KFS_Applicant__c appdetailsForAccept = [SELECT Id,Applicant_Type__c,Mobile_Number__c,Key_Fact_Statement__c FROM KFS_Applicant__c WHERE Key_Fact_Statement__c =: keyFactAcceptDataApp[0].Id AND Applicant_Type__c ='Borrower' WITH SECURITY_ENFORCED limit 1];
            keyFactAcceptData[0].Keyfact_Consent_Accepted__c = true;
            keyFactAcceptData[0].Keyfact_Consent_Received_Time__c = DateTime.Now();
            if(!keyFactAcceptData.isEmpty() && keyFactAcceptData[0].ProCredit_Deal__c != null){
            fromProCre = true;
            }
            // Applicant__C kfsApplicant = [SELECT Id,Opportunity__c,Applicant_Type__c from Applicant__C WHERE Opportunity__c =:keyFactAcceptData[0].Loan_Application__c AND Applicant_Type__c ='Borrower' WITH SECURITY_ENFORCED limit 1];
            //String vehicleID =[SELECT Id from Vehicle_Detail__c where Loan_Application__c=:loanapId limit 1].id ;
           // system.debug('The vehical id id '+vehicleID);

           PageReference pageRef = new PageReference('/apex/IND_SanctionFormRenderPage?id='+currentRecordId+'&connum='+keyFactAcceptData[0].Keyfact_Consent_OTP__c);
           pageRef.setRedirect(true);   
            // Label= 'KeyfactStatement BORROWER';
            // DocID = createOtherDocument(Label,keyFactAcceptData[0].Vehicle_Details__r[0].id,kfsApplicant.Id , keyFactAcceptData[0].Loan_Application__c);
            // List<ContentDocumentLink> contentLinkList = [Select id from ContentDocumentLink WHERE LinkedEntityId =: DocID];
            // if(contentLinkList.size() == 0){
            // createApplicationFormPdf(DocID,Label,keyFactAcceptData[0].Loan_Application__c);
            // }
    try{
    smsForConsentResult(keyFactAcceptData[0].ProCredit_Deal__c,keyFactAcceptData[0].Lead_Number__c,fromProCre,'ASC',appdetailsForAccept.Mobile_Number__c);
    system.debug('smsrequest');
    }catch(exception e){
    ErrorLoggerUtil.logErrorEvent('SanctionLetterController', 'smsForConsentResult', System.Label.Apex, e,keyFactAcceptData[0].Loan_Application__c);
    }
        update keyFactAcceptData;
    hasError = true;
            return pageRef;
         }
        catch (exception e){
            ErrorLoggerUtil.logErrorEvent('SanctionLetterController', 'acceptandRender', 'Class', e);
            system.debug('The error at line '+e.getLineNumber());
            system.debug('The error at line message  '+e.getMessage());
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    public PageReference notAcceptandRender(){    
    try{
    List<Key_Fact_Statement__c> keyFactAcceptData = [SELECT Id,Lead_Number__c,Keyfact_Consent_Accepted__c,Keyfact_Consent_Not_Accepted__c,Keyfact_Consent_Need_Clarification__c,Keyfact_Consent_Received_Time__c,Keyfact_Form_SMS_Sent__c,Keyfact_Consent_OTP__c,Loan_Application__c,Loan_Application__r.name,Deal_Number__c,ProCredit_Deal__c FROM Key_Fact_Statement__c WHERE Id =:currentRecordId  WITH SECURITY_ENFORCED];
            List<Key_Fact_Statement__c> keyFactAcceptDataApp = [SELECT Id,Lead_Number__c,Keyfact_Consent_Accepted__c,Keyfact_Consent_Not_Accepted__c,Keyfact_Consent_Need_Clarification__c,Keyfact_Consent_Received_Time__c,Keyfact_Form_SMS_Sent__c,Keyfact_Consent_OTP__c,Loan_Application__c,Loan_Application__r.name,Deal_Number__c,ProCredit_Deal__c FROM Key_Fact_Statement__c WHERE Key_Fact_Statement__c =:currentRecordId  WITH SECURITY_ENFORCED];

    //smsTriggerCheck = true;
            Boolean fromProCre = false;
    KFS_Applicant__c appdetailsForNotAccept = [SELECT Id,Applicant_Type__c,Mobile_Number__c,Key_Fact_Statement__c FROM KFS_Applicant__c WHERE Key_Fact_Statement__c =: keyFactAcceptDataApp[0].Id AND Applicant_Type__c ='Borrower' WITH SECURITY_ENFORCED limit 1];
    keyFactAcceptData[0].Keyfact_Consent_Not_Accepted__c = true;
    keyFactAcceptData[0].Keyfact_Consent_Received_Time__c = DateTime.Now();
    if(keyFactAcceptData[0].ProCredit_Deal__c != null){
    fromProCre = true;
    }
            PageReference pageRef = new PageReference('');
    pageRef.setRedirect(true);  
            // Label= 'KeyfactStatement ' + appdetailsForAccept.Applicant_Type__c;
            // DocID = createOtherDocument(Label,keyFactAcceptData[0].Vehicle_Details__r[0].id,appdetailsForAccept.id , keyFactAcceptData[0].Loan_Application__c);
            // List<ContentDocumentLink> contentLinkList = [Select id from ContentDocumentLink WHERE LinkedEntityId =: DocID];
            // if(contentLinkList.size() == 0){
            //     createApplicationFormPdf(DocID,Label,keyFactAcceptData[0].Loan_Application__c);
            // }
    try{
    smsForConsentResult(keyFactAcceptData[0].ProCredit_Deal__c,keyFactAcceptData[0].Lead_Number__c,fromProCre,'NASC',appdetailsForNotAccept.Mobile_Number__c);
    system.debug('smsrequest');
    }catch(exception e){
    ErrorLoggerUtil.logErrorEvent('SanctionLetterController', 'smsForConsentResult', System.Label.Apex, e,keyFactAcceptData[0].Loan_Application__c);
    }
           update keyFactAcceptData;
    return pageRef;
    }
        catch (exception e){
    ErrorLoggerUtil.logErrorEvent('SanctionLetterController', 'notAcceptandRender', 'Class', e);
    system.debug('The error at line '+e.getLineNumber());
    system.debug('The error at line message  '+e.getMessage());
    throw new AuraHandledException(System.Label.ExceptionMessage);
    }
    }
    public PageReference generatePdf(){ 
        List<Key_Fact_Statement__c> keyFactAcceptData = [SELECT Id,Lead_Number__c,Keyfact_Consent_Accepted__c,Keyfact_Consent_Not_Accepted__c,Keyfact_Consent_Need_Clarification__c,Keyfact_Consent_Received_Time__c,Keyfact_Form_SMS_Sent__c,Keyfact_Consent_OTP__c,Loan_Application__c,Loan_Application__r.name,Deal_Number__c,ProCredit_Deal__c FROM Key_Fact_Statement__c WHERE Id =:currentRecordId  WITH SECURITY_ENFORCED];
        PageReference pageRef = new PageReference('/apex/IND_SanctionFormRenderPage?id='+currentRecordId+'&connum='+keyFactAcceptData[0].Keyfact_Consent_OTP__c);
        pageRef.setRedirect(true); 
        return pageRef;
    }
    // public PageReference needClarificationRender(){
        
    //     PageReference pageRef = new PageReference('/apex/IND_SanctionFormRenderPage?id='+currentRecordId);
    //     pageRef.setRedirect(true);
    //     return pageRef;
        // try{
        //     List<Applicant__c> applObj= [SELECT Id,Applicant_Type__c,Opportunity__c,Sanction_Consent_Need_Clarification__c,Sanction_Consent_NeedClarification_Count__c,Sanction_Form_SMS_Sent__c,Sanction_Consent_OTP__c,Opportunity__r.Lead_number__c                                  
        //                            FROM Applicant__c
        //                            WHERE Id =: currentRecordId
        //                            WITH SECURITY_ENFORCED];
        //     applObj[0].Sanction_Consent_Need_Clarification__c = true;
        //     applObj[0].Sanction_Consent_Received_Time__c = DateTime.Now();
        //     applObj[0].Sanction_Consent_NeedClarification_Count__c = ((applObj[0].Sanction_Consent_NeedClarification_Count__c == null) ? 0 :applObj[0].Sanction_Consent_NeedClarification_Count__c) + 1;
        //     update applObj;
        //     isButtonDisabled = true; 
        //     return null;
        // }
        // catch (exception e){
        //     ErrorLoggerUtil.logErrorEvent('SanctionLetterController', 'acceptandRender', 'Class', e);
        //     system.debug('The error at line '+e.getLineNumber());
        //     system.debug('The error at line message  '+e.getMessage());
        //     throw new AuraHandledException(System.Label.ExceptionMessage);
        // }
   // }
  /*
    public static void createApplicationFormPdf(String DocID,string Label,string oppId) {
        try {
        Blob fileDetails ;
        PageReference PDf =  Page.IND_SanctionFormPDFpage;
        PDf.getParameters().put('Id',DocID);
        PDf.setRedirect(true);
        Attachment attach = new Attachment(); 
            if (!Test.isRunningTest()) {
                System.debug('PDF Blob Size:1233');
                fileDetails = PDf.getContentAsPdf();
                System.debug('PDF Blob Size: ' + fileDetails.size());
            } else {
                fileDetails = Blob.valueOf('TEST');
                System.debug('Running in test context, returning mock Blob.');
            }
        Utilities.createContentDocumentDownloadFromApex(DocID,Label, fileDetails, 'pdf',oppId);
        } catch (Exception e) {
            System.debug('Error generating PDF: ' + e.getMessage());
            throw e; // Re-throw the exception after logging it
        }
    }
    public static string createOtherDocument(String docType,String vehicleDetailId,String applicantId,String loanApplicationId){
        try {  
            string leadNo;
            list<Documents__c> docList = new list<Documents__c>();
            ID otherDocRecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('Other Documents').getRecordTypeId();
            if(loanApplicationId!=null ){
                list<Opportunity> loanApp= [Select Name from Opportunity where Id =: loanApplicationId WITH SECURITY_ENFORCED];
                if(!loanApp.isEmpty()) {
                    leadNo = loanApp[0].Name;
                    docList = [Select Id from Documents__c where Document_Type__c = :docType and Opportunity_Relation__c = :loanApplicationId and Applicant__c =:applicantId AND Vehicle_Detail__c =: vehicleDetailId  and is_Active__c = true WITH SECURITY_ENFORCED];
                }
                if(!docList.isEmpty()) {
                   return docList[0].Id;
                }else{
                   Documents__c docObject= new Documents__c(Name = docType+' '+leadNo,Vehicle_Detail__c=vehicleDetailId,Applicant__c=applicantId,Opportunity_Relation__c=loanApplicationId,Document_Type__c=docType,is_Active__c = true);
                   System.debug('docObject'+docObject);
                   docObject.RecordTypeId = otherDocRecordTypeId;
                   if (Schema.sObjectType.Documents__c.isCreateable()){
                     insert docObject;
                     return docObject.Id;
                   }
                }
                
                if(Test.isRunningTest())
                {
                    throw new AuraHandledException(System.Label.ExceptionMessage);
                }
                return null;
            }
            return null;
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('GenericUploadController', 'createOtherDocument ', System.Label.Apex, e);
            throw new AuraHandledException(e.getMessage() + ' ' + e.getStackTraceString());  
        }     
    }*/  
    public class smsWrapperAccept{
        public string pcdId;
        public string loanApplicationId;
        public Boolean fromProCredit;
        public string flag;
        public string contactNumber;
        public string KFSSmsType;
        
        public smsWrapperAccept(String proId, String oppId, Boolean fromProCre, String flagName, String conNumber){ 
            pcdId = proId;
            loanApplicationId = oppId;
            fromProCredit  = fromProCre;
            flag = flagName;
            contactNumber = conNumber; 
            KFSSmsType = 'Digital';
        }   
    }
      @future(callout=true)
      public static void smsForConsentResult(String proId, String oppId ,Boolean fromProCre, String flagName,String conNumber) {
          //Send SMS Block
          String serialisedSMSWrapper;
          smsWrapperAccept smsWrap = new smsWrapperAccept(proId,oppId,fromProCre,flagName,conNumber);	
          serialisedSMSWrapper = JSON.serialize(smsWrap);
          system.debug('testting000'+serialisedSMSWrapper);
          Object obj= IntegrationEngine.doKFSSmsGatewayAPI(serialisedSMSWrapper);
          //Send SMS Block
      }
}