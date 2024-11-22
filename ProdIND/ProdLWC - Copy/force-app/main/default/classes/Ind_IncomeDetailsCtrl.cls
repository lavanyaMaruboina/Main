/**
* @description       : This controller is basically designed for income details module.
* @author            : Devanshu Gupta
* @group             : https://indusindbank123--psldev1.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage#
* @created on		 : 21-12-2021
* @last modified on  : 21-12-2021
* @last modified by  : Devanshu Gupta
* @Version 		  	 : 1.0
**/
public with sharing class Ind_IncomeDetailsCtrl { 
    // This method is designed to get input related Applicant income details along with other required data.
 
    @AuraEnabled
    public static Map<String, Object> getInputsForIncomeDetails(String opportunityId, String applicantType, String applicantId) { 
        try {
            
            OppWrapper oppElement = new OppWrapper();
            Opportunity oppObj=[ SELECT Product_Type__c,LastStageName__c, StageName ,Lead_number__c,LeadSource,Customer_Type__c,Entity_Type__c FROM Opportunity WHERE Id =: opportunityId WITH SECURITY_ENFORCED limit 1];//CISP-2664-Added leadsource
            Map<String,Object> incomeRelatedMap = new Map<String, Object>(); 
            if (Schema.sObjectType.Applicant__c.isAccessible()) { //CISP:2974 Addedd SMS_to_be_triggered_to__c,Executive_Mobile_No__c 
                List<Applicant__c> applicantList = new List<Applicant__c>();
                if(String.isNotBlank(applicantId)){
                    applicantList = [SELECT ID,Applicant_Type__c,Income_Details_Count__c,Income_source_available__c,Is_this_current_residence_cum_office__c,Journey_Stage__c, Entity__c, (SELECT ID, Name,Document_Type__c,KYC_name__c, KYC_Address_Line_1__c, KYC_Address_Line_2__c,
                    KYC_Pin_Code__c, KYC_City__c, KYC_State__c, KYC_District__c, Current_Residential_Address_Proof__c FROM Documents__r ),
                    (SELECT ID, Name,Applicant__c,Area_Of_Registration__c,Capture_GST_Method__c,Capture_Income_Method__c,Capture_ITR_Method__c,Profile__r.Name,
                    Do_You_File_GST__c,Do_You_File_ITR__c,Employer_Business_Name__c,From_Month__c,GST_No__c,Income__c,Income_Source__c,Is_ICAI__c,
                    Total_Years_in_employment_business__c,Is_ICWAI__c,Is_Income_Credited_In_Bank_Account__c,Is_MCI__c,Is_Salaried__c,Is_Self_Employed__c,Is_this_Current_Residence_Cum_office__c,Legal__c,
                    Income_Detail_Bank_Master__r.Name,No_of_Loan_Taken_In_Past__c,To_Month__c,Unique_Registration_Number__c,Name_of_Recipient_Banks__r.Name,
                    Current_Years_in_employment_business__c,Password_for_pdf_protected_statement__c,Assessment_Year__c,Document_Type__c,
                    BSR_Occupation__c, Primary_Income_Source__c,Office_Address_Line_1__c, Office_Address_Line_2__c,Salaried_Self_employed__c	,
                    Income_Source_for_Tractor__c, ITR_Last_Year_Date__c, Income_Last_Year__c, Do_you_have_another_ITR__c,
                    Financial_Year__c, Total_Income__c, Total_Expense__c, PBT__c, PAT__c, Cash_Profit__c,Shareholder_funds__c,Secured_Loans__c,Unsecured_Loans__c,Working_Capital__c,Current_Liabilities__c,Current_Assets__c,Non_Current_Assets__c,Sundry_Creditors__c,Sundry_Debtors__c,Fixed_Assets__c,Cash_and_Bank_Balances__c,Account_Number__c,
                    Income_Detail_Bank_Master__c, Account_Opening_Date__c, Bank_Branch__c, Last_Month_Day_1__c, Last_Month_Day_10__c,Last_Month_Day_20__c, Last_2nd_Month_Day_1__c, Last_2nd_Month_Day_10__c, Last_2nd_Month_Day_20__c, Last_3rd_Month_Day_1__c, Last_3rd_Month_Day_10__c, Last_3rd_Month_Day_20__c,
                    Office_PinCode__c, Office_City__c, Office_District__c, Office_State__c,Bank_Account_Number__c,Year_of_Registeration__c,Income_Assesment_Done__c,Document_report_generation_initiated__c,Income_Source_Status__c,SMS_to_be_triggered_to__c,Executive_Mobile_No__c, Applicant__r.Opportunity__r.LeadSource, Saral_date__c, Tax_Return_Filed__c  FROM Income_Details__r),Do_you_have_a_bank_account__c,Do_you_have_a_bank_account_with_IBL__c,Email_Id__c,Customer_First_Name__c,Profile__c, PACS_Member__c, PACS_Name__c FROM Applicant__c WHERE Applicant_Type__c=:applicantType AND In_Active_Applicant__c = false AND Id =: applicantId AND Opportunity__c=:opportunityId LIMIT 1];
                }else{
                    applicantList = [SELECT ID,Applicant_Type__c,Income_Details_Count__c,Income_source_available__c,Is_this_current_residence_cum_office__c,Journey_Stage__c, Entity__c, (SELECT ID, Name,Document_Type__c,KYC_name__c, KYC_Address_Line_1__c, KYC_Address_Line_2__c,
                    KYC_Pin_Code__c, KYC_City__c, KYC_State__c, KYC_District__c, Current_Residential_Address_Proof__c FROM Documents__r ),
                    (SELECT ID, Name,Applicant__c,Area_Of_Registration__c,Capture_GST_Method__c,Capture_Income_Method__c,Capture_ITR_Method__c,Profile__r.Name,
                    Do_You_File_GST__c,Do_You_File_ITR__c,Employer_Business_Name__c,From_Month__c,GST_No__c,Income__c,Income_Source__c,Is_ICAI__c,
                    Total_Years_in_employment_business__c,Is_ICWAI__c,Is_Income_Credited_In_Bank_Account__c,Is_MCI__c,Is_Salaried__c,Is_Self_Employed__c,Is_this_Current_Residence_Cum_office__c,Legal__c,
                    Income_Detail_Bank_Master__r.Name,No_of_Loan_Taken_In_Past__c,To_Month__c,Unique_Registration_Number__c,Name_of_Recipient_Banks__r.Name,
                    Current_Years_in_employment_business__c,Password_for_pdf_protected_statement__c,Assessment_Year__c,Document_Type__c,
                    BSR_Occupation__c, Primary_Income_Source__c,Office_Address_Line_1__c, Office_Address_Line_2__c,Salaried_Self_employed__c	,
                    Income_Source_for_Tractor__c, ITR_Last_Year_Date__c, Income_Last_Year__c, Do_you_have_another_ITR__c,
                    Financial_Year__c, Total_Income__c, Total_Expense__c, PBT__c, PAT__c, Cash_Profit__c,Shareholder_funds__c,Secured_Loans__c,Unsecured_Loans__c,Working_Capital__c,Current_Liabilities__c,Current_Assets__c,Non_Current_Assets__c,Sundry_Creditors__c,Sundry_Debtors__c,Fixed_Assets__c,Cash_and_Bank_Balances__c,Account_Number__c,
                    Income_Detail_Bank_Master__c, Account_Opening_Date__c, Bank_Branch__c, Last_Month_Day_1__c, Last_Month_Day_10__c,Last_Month_Day_20__c, Last_2nd_Month_Day_1__c, Last_2nd_Month_Day_10__c, Last_2nd_Month_Day_20__c, Last_3rd_Month_Day_1__c, Last_3rd_Month_Day_10__c, Last_3rd_Month_Day_20__c,
                    Office_PinCode__c, Office_City__c, Office_District__c, Office_State__c,Bank_Account_Number__c,Year_of_Registeration__c,Income_Assesment_Done__c,Document_report_generation_initiated__c,Income_Source_Status__c,SMS_to_be_triggered_to__c,Executive_Mobile_No__c, Applicant__r.Opportunity__r.LeadSource, Saral_date__c, Tax_Return_Filed__c  FROM Income_Details__r),Do_you_have_a_bank_account__c,Do_you_have_a_bank_account_with_IBL__c,Email_Id__c,Customer_First_Name__c,Profile__c, PACS_Member__c, PACS_Name__c FROM Applicant__c WHERE Applicant_Type__c=:applicantType AND In_Active_Applicant__c = false AND Opportunity__c=:opportunityId LIMIT 1];
                }
                
                for(Applicant__c appLicantObj: applicantList) {//CISP-3092 //D2C Change
                    ApplicantWrapper applicantData = new ApplicantWrapper();
                    if(appLicantObj.Income_Details_Count__c != null) {
                        applicantData.incomeDetailCount = (Integer)appLicantObj.Income_Details_Count__c;
                    }else {
                        applicantData.incomeDetailCount = 0;
                    }
                    if(appLicantObj.Income_source_available__c != null) {
                        applicantData.isIncomeSourcePresent = appLicantObj.Income_source_available__c;
                    }
                    if(appLicantObj.Income_source_available__c != null) {
                        applicantData.isBankAccountPresent = appLicantObj.Do_you_have_a_bank_account__c;
                    }
                    if(appLicantObj.Income_source_available__c != null) {
                        applicantData.isIBLBankAccountPresent = appLicantObj.Do_you_have_a_bank_account_with_IBL__c;
                    }
                    if(appLicantObj.Income_source_available__c != null) {
                        applicantData.currentStage = appLicantObj.Journey_Stage__c;
                    }
                    if(appLicantObj.Email_Id__c != null) {
                        applicantData.emailId = appLicantObj.Email_Id__c;
                    }
                    if(appLicantObj.Customer_First_Name__c != null) {
                        applicantData.firstName = appLicantObj.Customer_First_Name__c;
                    }
                    if(appLicantObj.Entity__c != null) {
                        applicantData.legalEntity = appLicantObj.Entity__c;
                    }

                    incomeRelatedMap.put('applicantData',JSON.serialize(applicantData) );
                    if(appLicantObj.Documents__r != null && appLicantObj.Documents__r.size() > 0 ) {
                        for(Documents__c doc : appLicantObj.Documents__r){
                            if(doc.Document_Type__c == System.Label.PanCards){
                                incomeRelatedMap.put('isPanAvailable',true);
                                break;
                            }else {
                                incomeRelatedMap.put('isPanAvailable',false);
                            }
                        }
                    } 
                    if(appLicantObj.Income_Details__r != null && appLicantObj.Income_Details__r.size() > 0) {
                        
                        incomeRelatedMap.put('incomeDetails',appLicantObj.Income_Details__r);
                    } else {
                        incomeRelatedMap.put('incomeDetails',null);
                    }
                    if(appLicantObj.Id != null) {
                        
                        incomeRelatedMap.put('applicantId',appLicantObj.Id);
                    }
                    incomeRelatedMap.put('applicantDataRecord',appLicantObj);
                }
            }
            
            if(oppObj != null){
                    incomeRelatedMap.put('productType',oppObj.Product_Type__c);
                    incomeRelatedMap.put('lastStage',oppObj.LastStageName__c);
                    incomeRelatedMap.put('currentStageName',oppObj.StageName);
                    incomeRelatedMap.put('leadNumber',oppObj.Lead_number__c);
                    incomeRelatedMap.put('leadSource',oppObj.LeadSource == System.Label.MSIL_Lead_API_Value ? true : oppObj.LeadSource == System.Label.Mahindra_Custom_Lead_API_Value ? true : oppObj.LeadSource == System.Label.Mahindra_PreA_Lead_API_Value ? true : false);//CISP-2664 //CISP-15890
                    incomeRelatedMap.put('leadSourceValue',oppObj.LeadSource);//Ola Integration changes
                    incomeRelatedMap.put('entityType',oppObj.Customer_Type__c);
                    incomeRelatedMap.put('entityCategory',oppObj.Entity_Type__c);
                }
            return incomeRelatedMap;
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('Ind_IncomeDetailsCtrl', ' getInputsForIncomeDetails ', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    @AuraEnabled
    public static Map<String, String> saveIncomeDetails(String incomeDetails , String applicantId, String isTractor) {
        try{
            Map<String, String> updateStatus = New Map<String,String>{'status' => 'fail'};
            List<IncomeDetailWrapper> incomeDetailData = new List<IncomeDetailWrapper>();

            if(incomeDetails != 'null') {
                List<Income_Details__c> listOfIncomeDetails = new List<Income_Details__c>();
                incomeDetailData = (List<IncomeDetailWrapper>)JSON.deserialize(incomeDetails, List<IncomeDetailWrapper>.class);
                
                for(IncomeDetailWrapper wrapperObj : incomeDetailData) {//CISP: 2973 added SMS_to_be_triggered_to__c,Executive_Mobile_No__c
                    if(isTractor == 'true'){
                        Income_Details__c incomeDetailObj = new Income_Details__c();
                        incomeDetailObj.Income_Source_for_Tractor__c = wrapperObj.incomeSource;
                        incomeDetailObj.Name = wrapperObj.name !=null ? wrapperObj.name: 'Income Detail';
                        incomeDetailObj.Applicant__c = applicantId;

                        if(wrapperObj.incomeSource == 'ITR') {
                            incomeDetailObj.Assessment_Year__c = wrapperObj.assessmentYear;
                            incomeDetailObj.ITR_Last_Year_Date__c = Date.valueOf(wrapperObj.iTRLastYearDate);
                            incomeDetailObj.Income_Last_Year__c = Decimal.valueOf(wrapperObj.incomeLastYear);
                            incomeDetailObj.Do_you_have_another_ITR__c = wrapperObj.doYouHaveAnotherITR;
                            incomeDetailObj.Saral_date__c = wrapperObj.saralDate;//SFTRAC-241
                            incomeDetailObj.Tax_Return_Filed__c = wrapperObj.taxReturnsFiled;//SFTRAC-241
                        } else if(wrapperObj.incomeSource == 'Financials'){
                            incomeDetailObj.Financial_Year__c = wrapperObj.financialYear;
                            incomeDetailObj.Total_Income__c = Decimal.valueOf(wrapperObj.totalIncome);
                            incomeDetailObj.Total_Expense__c = Decimal.valueOf(wrapperObj.totalExpense);
                            incomeDetailObj.PBT__c = Decimal.valueOf(wrapperObj.pBT);
                            if(!String.isEmpty(wrapperObj.pAT) && String.isNotBlank(wrapperObj.pAT)){
                                incomeDetailObj.PAT__c = Decimal.valueOf(wrapperObj.pAT);
                            }
                            if(!String.isEmpty(wrapperObj.cashProfit) && String.isNotBlank(wrapperObj.cashProfit)){
                                incomeDetailObj.Cash_Profit__c = Decimal.valueOf(wrapperObj.cashProfit);
                            }
                            incomeDetailObj.Shareholder_funds__c = Decimal.valueOf(wrapperObj.shareholderFunds);
                            incomeDetailObj.Secured_Loans__c = Decimal.valueOf(wrapperObj.securedLoans);
                            incomeDetailObj.Unsecured_Loans__c = Decimal.valueOf(wrapperObj.unsecuredLoans);
                            incomeDetailObj.Working_Capital__c = Decimal.valueOf(wrapperObj.workingCapital);
                            incomeDetailObj.Current_Liabilities__c = Decimal.valueOf(wrapperObj.currentLiabilities);
                            incomeDetailObj.Current_Assets__c = Decimal.valueOf(wrapperObj.currentAssets);
                            incomeDetailObj.Non_Current_Assets__c = Decimal.valueOf(wrapperObj.nonCurrentAssets);
                            incomeDetailObj.Sundry_Creditors__c = Decimal.valueOf(wrapperObj.sundryCreditors);
                            incomeDetailObj.Sundry_Debtors__c = Decimal.valueOf(wrapperObj.sundryDebtors);
                            incomeDetailObj.Fixed_Assets__c = Decimal.valueOf(wrapperObj.fixedAssets);
                            incomeDetailObj.Cash_and_Bank_Balances__c = Decimal.valueOf(wrapperObj.cashAndBankBalances);
                        } else if(wrapperObj.incomeSource == 'Banking') {
                            incomeDetailObj.Income_Detail_Bank_Master__c = wrapperObj.bankName;
                            incomeDetailObj.Account_Opening_Date__c = Date.valueOf(wrapperObj.accountOpetingDate);
                            incomeDetailObj.Bank_Branch__c = wrapperObj.bankBranch;
                            incomeDetailObj.Account_Number__c = wrapperObj.accountNumber;
                            incomeDetailObj.Last_Month_Day_1__c = Decimal.valueOf(wrapperObj.lastMonthDay1);
                            incomeDetailObj.Last_Month_Day_10__c = Decimal.valueOf(wrapperObj.lastMonthDay10);
                            incomeDetailObj.Last_Month_Day_20__c = Decimal.valueOf(wrapperObj.lastMonthDay20);
                            incomeDetailObj.Last_2nd_Month_Day_1__c = Decimal.valueOf(wrapperObj.last2ndMonthDay1);
                            incomeDetailObj.Last_2nd_Month_Day_10__c = Decimal.valueOf(wrapperObj.last2ndMonthDay10);
                            incomeDetailObj.Last_2nd_Month_Day_20__c = Decimal.valueOf(wrapperObj.last2ndMonthDay20);
                            incomeDetailObj.Last_3rd_Month_Day_1__c = Decimal.valueOf(wrapperObj.last3rdMonthDay1);
                            incomeDetailObj.Last_3rd_Month_Day_10__c = Decimal.valueOf(wrapperObj.last3rdMonthDay10);
                            incomeDetailObj.Last_3rd_Month_Day_20__c = Decimal.valueOf(wrapperObj.last3rdMonthDay20);
                        }
                        
                        if(!String.isEmpty(wrapperObj.Id)) {
                            incomeDetailObj.Id = wrapperObj.Id;
                        }

                        System.debug('incomeDetailObj:::'+incomeDetailObj);
                        listOfIncomeDetails.add(incomeDetailObj);
                    } else{
                        Income_Details__c incomeDetailObj = new Income_Details__c(Name=wrapperObj.name !=null ? wrapperObj.name: 'Income Detail',Applicant__c=applicantId,
                                                                                Area_Of_Registration__c=wrapperObj.areaOfRegistration !=null ? wrapperObj.areaOfRegistration : '',
                                                                                BSR_Occupation__c=wrapperObj.bsrOccupation !=null ?wrapperObj.bsrOccupation : '',
                                                                                Capture_GST_Method__c=wrapperObj.gstMetghod !=null ?wrapperObj.gstMetghod : '',
                                                                                Capture_Income_Method__c=wrapperObj.incomeMethod !=null ?wrapperObj.incomeMethod : '',
                                                                                Capture_ITR_Method__c=wrapperObj.itrMethod,Do_You_File_GST__c=wrapperObj.isFileGST,Do_You_File_ITR__c=wrapperObj.isFileITR,
                                                                                Employer_Business_Name__c=wrapperObj.employeeBussinessName !=null ? wrapperObj.employeeBussinessName : '',
                                                                                From_Month__c = wrapperObj.fromMonth !=null ? wrapperObj.fromMonth : '',
                                                                                To_Month__c = wrapperObj.toMonth !=null ? wrapperObj.toMonth : '',
                                                                                GST_No__c=wrapperObj.gstNumber !=null ? wrapperObj.gstNumber : '',
                                                                                Income_Source_Status__c= wrapperObj.incomeSourceStatus !=null ? wrapperObj.incomeSourceStatus : '',
                                                                                Salaried_Self_employed__c= wrapperObj.salariedSelfEmp !=null ? wrapperObj.salariedSelfEmp : '',
                                                                                Income_Source__c=wrapperObj.isIncomeSouce,Is_ICAI__c=wrapperObj.isICAI,Is_ICWAI__c=wrapperObj.isICWAI,
                                                                                Is_Income_Credited_In_Bank_Account__c=wrapperObj.isIncomeCreatedInBank,
                                                                                Is_MCI__c=wrapperObj.isMCI,Is_Salaried__c=wrapperObj.isSalaried,Is_Self_Employed__c=wrapperObj.isSelfEmployed,Is_this_Current_Residence_Cum_office__c=wrapperObj.isCurrentResidenceCumOffice,
                                                                                Legal__c=wrapperObj.legal !=null ? wrapperObj.legal : '',
                                                                                Year_of_Registeration__c=wrapperObj.yearOfRegisteration !=null ? wrapperObj.yearOfRegisteration : '',
                                                                                No_of_Loan_Taken_In_Past__c=wrapperObj.noOfLoanTakenInPast !=null ? wrapperObj.noOfLoanTakenInPast : '',
                                                                                Income__c=wrapperObj.Income,
                                                                                Bank_Account_Number__c=wrapperObj.bankAccountNumber,
                                                                                Document_Type__c=wrapperObj.documentType != null ? wrapperObj.documentType : '' ,
                                                                                Assessment_Year__c= wrapperObj.assessmentYear !=null ? wrapperObj.assessmentYear : '',
                                                                                Current_Years_in_employment_business__c= wrapperObj.currentYearsEmploymentBusiness !=null ? wrapperObj.currentYearsEmploymentBusiness : '',
                                                                                Total_Years_in_employment_business__c= wrapperObj.totalYearsEmploymentBusiness !=null ? wrapperObj.totalYearsEmploymentBusiness : '',
                                                                                Unique_Registration_Number__c=wrapperObj.uniqueRegistrationNumber !=null ? wrapperObj.uniqueRegistrationNumber : '',
                                                                                SMS_to_be_triggered_to__c = wrapperObj.SMSSentTo !=null ? wrapperObj.SMSSentTo:'',
                                                                                Executive_Mobile_No__c = wrapperObj.ExNoofEx !=null? wrapperObj.ExNoofEx:'',
                                                                                Income_Assesment_Done__c=wrapperObj.incomeAssessmentDone,
                                                                                Perfios_Transaction_Id__c=wrapperObj.perfiosId);
                                                                                
                        if(String.isNotBlank(wrapperObj.profile) && !String.isEmpty(wrapperObj.profile)){
                            incomeDetailObj.Profile__c=wrapperObj.profile;
                        }
                        
                        if(wrapperObj.nameOfRecipientBank !=null){
                            incomeDetailObj.Name_of_Recipient_Banks__c=wrapperObj.nameOfRecipientBank ;
                        }                                                    
                        if(!String.isEmpty(wrapperObj.Id)) {
                            incomeDetailObj.Id = wrapperObj.Id;
                        }
                        
                        listOfIncomeDetails.add(incomeDetailObj);
                    }
                }

                if(!listOfIncomeDetails.isEmpty()){
                    if(Schema.sObjectType.Income_Details__c.isCreateable() || Schema.sObjectType.Income_Details__c.isUpdateable()){
                        upsert listOfIncomeDetails;
                        updateStatus.put('recordId', listOfIncomeDetails[0].id);
                        updateStatus.put('status', 'success');
                    } else {
                        updateStatus.put('message', 'Error - Missing Access, Please contact System Administrator');
                    }
                } else {
                    updateStatus.put('message', 'Error - Missing Income Details');
                }
            } else {
                updateStatus.put('message', 'Error - Missing Income Details');
            }

            return updateStatus;
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('Ind_IncomeDetailsCtrl', 'saveIncomeDetails ', System.Label.Apex, e);
            //throw new AuraHandledException(System.Label.ExceptionMessage);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public class ApplicantWrapper {
        public Boolean isIncomeSourcePresent { get; set; }
        public Integer incomeDetailCount { get; set; }
        public Boolean isBankAccountPresent { get; set; }
        public Boolean isIBLBankAccountPresent { get; set; }
        public String currentStage { get; set; }
        public String emailId { get; set; }
        public String firstName { get; set; }
        public String legalEntity { get; set; }

    }
    
    public class IncomeDetailWrapper {
        public String Id { get; set; }
        public Boolean incomeAssessmentDone { get; set; }
        public Boolean documentReportGenInitiated{ get; set;}
        public String perfiosId { get; set; }
        public String name { get; set; }
        public Decimal Income { get; set; }
        public String applicantId { get; set; }
        public String areaOfRegistration { get; set; }
        public String yearOfRegisteration { get; set; }
        public String bsrOccupation { get; set; }
        public String gstMetghod { get; set; }
        public String incomeMethod { get; set; }
        public String itrMethod { get; set; }
        public Boolean isFileGST { get; set; }
        public Boolean isFileITR { get; set; }
        public String employeeBussinessName { get; set; }
        public String fromMonth { get; set; }
        public String gstNumber { get; set; }
        public Boolean 	isIncomeSouce { get; set; }
        public Boolean 	isICAI { get; set; }
        public Boolean 	isICWAI { get; set; }
        public Boolean 	isIncomeCreatedInBank { get; set; }
        public Boolean 	isMCI { get; set; }
        public Boolean 	isSalaried { get; set; }
        public Boolean 	isSelfEmployed { get; set; }
        public String salariedSelfEmp { get; set; }
        public Boolean  isCurrentResidenceCumOffice { get; set; }
        public String legal { get; set; }
        public String nameOfRecipientBank { get; set; }
        public String noOfLoanTakenInPast { get; set; }
        public String toMonth { get; set; }  
        public String uniqueRegistrationNumber { get; set; }
        public String profile { get; set; }
        public String totalYearsEmploymentBusiness { get; set; }
        public String currentYearsEmploymentBusiness { get; set; }
        public String passwordForPdfProtectedStatement { get; set; }
        
        public String documentType { get; set; }
        public String incomeSourceStatus  { get; set; }
        public String bankAccountNumber  { get; set; }
        public string SMSSentTo {get;set;} //CISP:2973
        public string ExNoofEx {get;set;} //CISP:2973
        
        
        public string incomeSource {get;set;}
        public String assessmentYear {get;set;}
        public String iTRLastYearDate {get;set;}
        public String incomeLastYear {get;set;}
        public boolean doYouHaveAnotherITR {get;set;}
       
        public string financialYear {get;set;}
        public string totalIncome {get;set;}
        public string totalExpense {get;set;}
        public string pBT {get;set;}
        public string pAT {get;set;}
        public string cashProfit {get;set;}
        public string shareholderFunds {get;set;}
        public string securedLoans {get;set;}
        public string unsecuredLoans {get;set;}
        public string workingCapital {get;set;}
        public string currentLiabilities {get;set;}
        public string currentAssets {get;set;}
        public string nonCurrentAssets {get;set;}
        public string sundryCreditors {get;set;}
        public string sundryDebtors {get;set;}
        public string fixedAssets {get;set;}
        public string cashAndBankBalances {get;set;}
        public string bankName {get;set;}
        public string bankBranch {get;set;}
        public string accountNumber {get;set;}
        public string accountOpetingDate {get;set;}
        public string lastMonthDay1 {get;set;}
        public String lastMonthDay10 {get;set;}
        public String lastMonthDay20 {get;set;}
        public String last2ndMonthDay1 {get;set;}
       
        public string last2ndMonthDay10 {get;set;}
        public string last2ndMonthDay20 {get;set;}
        public string last3rdMonthDay1 {get;set;}
        public string last3rdMonthDay10 {get;set;}
        public string last3rdMonthDay20 {get;set;}
        public Date saralDate {get;set;}//SFTRAC-241
        public string taxReturnsFiled {get;set;}//SFTRAC-241


    }
    //public added by Hemanth Thikka
    public class OppWrapper{
      public String productType {get;set;}
      public String lastStage {get;set;}
      public String currentStageName {get;set;}
      public String leadNumber {get;set;}
    }
    
  /* @Method:      updateAPICounterAndAccesibility
* @Created by:  Devanshu Gupta
* @Description: Method to update the income details record
* @Param:       String - applicantId , String - apiType, Integer counter , Boolean isUpdateAPIAccebilty
* @Return:      String
*/  
    @AuraEnabled
    public static String updateAPICounterAndAccesibility(String incomeId, String apiType, Integer counter,Boolean isUpdateAPIAccebilty){
        try{
        Income_Details__c  incomeDetailObj = new Income_Details__c();
        incomeDetailObj.Id = incomeId;
        if(apiType== System.Label.GST){ 
            incomeDetailObj.GST_API_Count__c = counter;
            incomeDetailObj.Is_GST_Assessed__c = isUpdateAPIAccebilty;
        }else if(apiType=='GSTUpload'){
            incomeDetailObj.GSTUpload_API_Count__c = counter;
            incomeDetailObj.Is_GST_Assessed__c = isUpdateAPIAccebilty;
        }
        else if(apiType== System.Label.ITR){ 
            system.debug('Marking ITR'+isUpdateAPIAccebilty);
            incomeDetailObj.ITR_API_Count__c = counter;
            incomeDetailObj.Is_ITR_Assessed__c = isUpdateAPIAccebilty;
        }else if(apiType=='ITRUpload'){
            incomeDetailObj.ITRUpload_API_Count__c = counter;
            incomeDetailObj.Is_ITR_Assessed__c = isUpdateAPIAccebilty;
        }
        else if(apiType== System.Label.BANK_STATEMENT){
            incomeDetailObj.Bank_details_API_Count__c = counter;
            incomeDetailObj.set_is_Bank_Details_Assessed__c = isUpdateAPIAccebilty;
        }else if(apiType=='BSUpload'){
            incomeDetailObj.BSUpload_API_Count__c = counter;
            incomeDetailObj.set_is_Bank_Details_Assessed__c = isUpdateAPIAccebilty;
        }
            if (Schema.sObjectType.Income_Details__c.isUpdateable() && Schema.sObjectType.Income_Details__c.isCreateable()) {
        upsert incomeDetailObj;  
            }
        return incomeId;
    }catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('Ind_IncomeDetailsCtrl', ' updateAPICounterAndAccesibility ', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
     }
    }
    
    
    /* @Method:      getProfile
* @Created by:  Devanshu Gupta
* @Description: Method to get profile according to category
* @Param:       String - category
* @Return:      List of Profile Master
*/
    
    @AuraEnabled
    public static List<Profile_Master__c> getProfile(String category) {
        
        try {
      
            List<Profile_Master__c> profileList = new List<Profile_Master__c>();
            List<String> categoryList = new List<String>();
            if(category == 'SAL') {
                categoryList.add(category);
            } else {
                categoryList.add('SEP');
                categoryList.add('SENP');
            }
            if (Schema.sObjectType.Profile_Master__c.isAccessible()) { 
                
                profileList = [SELECT Id, Name , Code__c , Category__c FROM Profile_Master__c WHERE Category__c In :categoryList WITH SECURITY_ENFORCED order by Name ASC];
                
            }
            return profileList;
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('Ind_IncomeDetailsCtrl', ' getProfile ', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

     @AuraEnabled(Cacheable=true)
    public static List<String> getAssessmentYear(String category) {
        
        try {
           	
            Integer currentYear = System.Today().year();
            Integer nextYear;
            String assesmentYear;
            system.debug('year '+currentYear);
            system.debug('month '+Date.today().month());
            if(Date.today().month()<4){
                currentYear=currentYear-1;
            }
            
            List<String> assessmentList = new List<String>();
            for(Integer i=currentYear;i>currentYear-3;i--){
                nextYear=i+1;
                assesmentYear=i+'-'+nextYear;
                assessmentList.add(assesmentYear);
            }
            system.debug('assessmentList '+assessmentList);
            return assessmentList;
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('Ind_IncomeDetailsCtrl', ' getAssessmentYear ', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    @AuraEnabled
    public static map<String,Object> getAPIEligibility(String checkEligibilityData) {
         String gstCounter = 'GSTCOUNTER';
         String itrCounter = 'ITRCOUNTER';
         String bsCounter = 'BSCOUNTER';
        IncomeEligibilityWrapper eligibilityData = new IncomeEligibilityWrapper();
        Map<String,Object> eligiblityMap = new Map<String,Object>();
        try {
            
            if(checkEligibilityData != null){
                eligibilityData = (IncomeEligibilityWrapper)JSON.deserialize(checkEligibilityData, IncomeEligibilityWrapper.class);
                List<Income_Details__c> incomeDetailList = new List<Income_Details__c>();
                Boolean found = false;
                if((eligibilityData.apiType== System.Label.GST || eligibilityData.apiType=='GSTUpload') && eligibilityData.gstNumber !=null && eligibilityData.incomeDetailId !=null && eligibilityData.applicantId !=null){
                    
                    incomeDetailList = [SELECT Id,Is_GST_Assessed__c,GST_API_Count__c,GSTUpload_API_Count__c,GST_No__c,Applicant__c FROM Income_Details__c WHERE GST_No__c =:eligibilityData.gstNumber AND Applicant__c =:eligibilityData.applicantId AND Id =:eligibilityData.incomeDetailId WITH SECURITY_ENFORCED];//CISP-3092
                    System.debug('incomeDetailList '+incomeDetailList[0].GST_API_Count__c);
                    if(!incomeDetailList.isEmpty()) {
                        
                        for(Income_Details__c incomeObj: incomeDetailList) {
                            if(incomeObj.Is_GST_Assessed__c !=null && !incomeObj.Is_GST_Assessed__c) {
                                if(incomeObj.Id == eligibilityData.incomeDetailId) {
                                    System.debug('here ');
                                    if(eligibilityData.apiType=='GSTUpload'){
                                        eligiblityMap.put(gstCounter,incomeObj.GSTUpload_API_Count__c == null ? 0 : incomeObj.GSTUpload_API_Count__c);
                                    }else {
                                        eligiblityMap.put(gstCounter,incomeObj.GST_API_Count__c == null ? 0 : incomeObj.GST_API_Count__c);
                                    }
            
                                    }
                            } else {
                                System.debug('here else');
                                eligiblityMap.put(System.Label.GST,'NotAllowed');
                                found = true;
                            }
                        }
                        if(!found) {
                            eligiblityMap.put(System.Label.GST,'Allowed');
                        }
                        
                    } else {
                        eligiblityMap.put(System.Label.GST,'Allowed');
                        eligiblityMap.put(gstCounter, 0);
                    }
                            
                } 
                if((eligibilityData.apiType ==System.Label.ITR|| eligibilityData.apiType=='ITRUpload') && eligibilityData.incomeDetailId !=null && eligibilityData.applicantId !=null){
                    incomeDetailList = [SELECT Id,Is_ITR_Assessed__c,ITR_API_Count__c,ITRUpload_API_Count__c,Applicant__c FROM Income_Details__c WHERE  Applicant__c=:eligibilityData.applicantId AND Id =:eligibilityData.incomeDetailId WITH SECURITY_ENFORCED];//CISP-3092
                    system.debug('Check ITR List :'+incomeDetailList.isEmpty());
                    if(!incomeDetailList.isEmpty()) {
                        for(Income_Details__c incomeObj : incomeDetailList) {
                            if(incomeObj.Is_ITR_Assessed__c !=null && !incomeObj.Is_ITR_Assessed__c) {
                                if(incomeObj.Id == eligibilityData.incomeDetailId) {
                                     if(eligibilityData.apiType=='ITRUpload'){
                                        eligiblityMap.put(itrCounter,incomeObj.ITRUpload_API_Count__c == null ? 0 : incomeObj.ITRUpload_API_Count__c);
                                     }else {
                                        eligiblityMap.put(itrCounter,incomeObj.ITR_API_Count__c == null ? 0 : incomeObj.ITR_API_Count__c);
                                    }
                                }
                            }else {
                                eligiblityMap.put(System.Label.ITR,'NotAllowed');
                                found = true;
                            }
                        }
                        if(!found) {
                            eligiblityMap.put(System.Label.ITR,'Allowed');
                        }
                    } else {
                        eligiblityMap.put(System.Label.ITR,'Allowed');
                         eligiblityMap.put(itrCounter, 0);
                    }
                  
                }
                if((eligibilityData.apiType== System.Label.BANK_STATEMENT|| eligibilityData.apiType=='BSUpload') && eligibilityData.incomeDetailId !=null && eligibilityData.applicantId !=null){
                    
                    // incomeDetailList = [SELECT Id,set_is_Bank_Details_Assessed__c,Bank_details_API_Count__c,BSUpload_API_Count__c,Applicant__c FROM Income_Details__c WHERE id =:eligibilityData.incomeDetailId ];
                    incomeDetailList = [SELECT Id,set_is_Bank_Details_Assessed__c,Bank_details_API_Count__c,BSUpload_API_Count__c,Applicant__c FROM Income_Details__c WHERE Applicant__c=:eligibilityData.applicantId AND Id =:eligibilityData.incomeDetailId WITH SECURITY_ENFORCED ];//CISP-3092

                    if(!incomeDetailList.isEmpty()) {
                        
                        for(Income_Details__c incomeObj: incomeDetailList) {
                            if(incomeObj.set_is_Bank_Details_Assessed__c !=null && !incomeObj.set_is_Bank_Details_Assessed__c) {
                                if(incomeObj.Id == eligibilityData.incomeDetailId) {
                                    if(eligibilityData.apiType=='BSUpload'){
                                        eligiblityMap.put(bsCounter,incomeObj.BSUpload_API_Count__c == null ? 0 : incomeObj.BSUpload_API_Count__c);
                                     }else {
                                    eligiblityMap.put(bsCounter,incomeObj.Bank_details_API_Count__c == null ? 0 : incomeObj.Bank_details_API_Count__c);
                                     }
                                }
                            } else {
                            system.debug('incomeObj.set_is_Bank_Details_Assessed__c '+incomeObj.set_is_Bank_Details_Assessed__c);
                                eligiblityMap.put(System.Label.BANK_STATEMENT,'NotAllowed');
                                found = true;
                            }
                        }
                        if(!found) {
                            eligiblityMap.put(System.Label.BANK_STATEMENT,'Allowed');
                        }
                        
                    } else {
                        eligiblityMap.put(System.Label.BANK_STATEMENT,'Allowed');
                        eligiblityMap.put(bsCounter, 0);
                    }
                            
                } 
              
                if(eligibilityData.apiType=='BSScanUpload' || eligibilityData.apiType=='ITRScanUpload'){
                    Income_Details__c incomeDetail = [SELECT Id,ScanUpload_BS_Api_Count__c,ScanUpload_ITR_Api_Count__c,Applicant__c FROM Income_Details__c WHERE id =:eligibilityData.incomeDetailId WITH SECURITY_ENFORCED];
                   // if(!incomeDetail.isEmpty()) {
                        if(eligibilityData.apiType=='BSScanUpload'){
                            if(incomeDetail.ScanUpload_BS_Api_Count__c<=3){
                                incomeDetail.ScanUpload_BS_Api_Count__c++;
                                eligiblityMap.put('bsScanUploadCounter', incomeDetail.ScanUpload_BS_Api_Count__c);
                                eligiblityMap.put('BSScanUpload','Allowed');
                            }else{
                                incomeDetail.ScanUpload_BS_Api_Count__c=3;
                                eligiblityMap.put('bsScanUploadCounter',3);
                                eligiblityMap.put('BSScanUpload','NotAllowed');
                            }
                        }else{
                            if(incomeDetail.ScanUpload_ITR_Api_Count__c<=3){
                                incomeDetail.ScanUpload_ITR_Api_Count__c++;
                                eligiblityMap.put('itrScanUploadCounter', incomeDetail.ScanUpload_ITR_Api_Count__c);
                               eligiblityMap.put('ITRScanUpload','Allowed');
                            }else{
                                incomeDetail.ScanUpload_ITR_Api_Count__c=3;
                                eligiblityMap.put('itrScanUploadCounter', 3);
                                eligiblityMap.put('ITRScanUpload','NotAllowed');
                            }
                        }
                        update incomeDetail;
                }
 
                
            }
           return  eligiblityMap;
        }catch (Exception e){
            ErrorLoggerUtil.logErrorEvent('Ind_IncomeDetailsCtrl', ' getAPIRetryEligibility ', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    public class IncomeEligibilityWrapper {    
    public String incomeDetailId { get; set; }
    public String applicantId { get; set; }
    public String gstNumber { get; set; }
    public String accountNumber { get; set; }
    public String apiType { get; set; }
    }
    
    @AuraEnabled
    public static Boolean checkBankIncomeDetails(String applicantId, String bankName , String accountNum){
        try{
            if(applicantId != null){
                List<Income_Details__c> incomeDetailObjectList = new List<Income_Details__c>();
                incomeDetailObjectList = [Select Id,Name_of_Recipient_Banks__r.Name,Bank_Account_Number__c ,Is_Income_Credited_In_Bank_Account__c from Income_Details__c where Applicant__c =:applicantId WITH SECURITY_ENFORCED];                
                if(!incomeDetailObjectList.isEmpty() && incomeDetailObjectList.size()>0){
                    for(Income_Details__c bankDetail : incomeDetailObjectList){
                        if(bankName==bankDetail.Name_of_Recipient_Banks__r.Name && accountNum ==bankDetail.Bank_Account_Number__c && bankDetail.Is_Income_Credited_In_Bank_Account__c){
                            return false;
                        }
                    }
                    return true;
                } else {
                    return true;
                }
            } else {
                return false;
            }
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('Ind_IncomeDetailsCtrl', 'checkBankIncomeDetails', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }   
    

    /* @Method:      fetchDocument
* @Created by:  Ruchi Jain
* @Description: Method to get document if present for particular type
* @Param:       String - applicant id,Document type
* @Return:      String - document id
*/

    @AuraEnabled
    public static String fetchDocument(String applicantId, String docType,String vehicleDetailId){
        try{
            if(applicantId != null){
                List<Documents__c> docObjectList = new List<Documents__c>();
                docObjectList = [Select Id from Documents__c where Applicant__c =:applicantId and Document_Type__c=:docType AND Vehicle_Detail__c =: vehicleDetailId AND Is_Active__c = true WITH SECURITY_ENFORCED];                
                if(!docObjectList.isEmpty() && docObjectList.size()>0){
                    return docObjectList[0].Id;
                } else {
                    return null;
                }
            } else {
                return null;
            }
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('Ind_IncomeDetailsCtrl', 'fetchDocument', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    } 
 
    @AuraEnabled
    public static String fetchDocumentTractorVehicle(String applicantId, String docType, String vehicleId ){
        try{
            if(applicantId != null && vehicleId != null){
                List<Documents__c> docObjectList = new List<Documents__c>();
                docObjectList = [Select Id from Documents__c where Vehicle_Detail__c=: vehicleId and Applicant__c =:applicantId and Document_Type__c=:docType WITH SECURITY_ENFORCED];                
                if(!docObjectList.isEmpty() && docObjectList.size()>0){
                    return docObjectList[0].Id;
                } else {
                    return null;
                }
            } else {
                return null;
            }
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('Ind_IncomeDetailsCtrl', 'fetchDocument', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    } 

    @AuraEnabled
    public static Boolean checkImageExist(String applicantId, String documentType ){
        Boolean imageExistFlag = false;
        try{
            if(applicantId != null){
                List<Documents__c> documentList= [select Id,(SELECT Id FROM ContentDocumentLinks) from Documents__c Where Applicant__c =: applicantId And Document_Type__c =: documentType WITH SECURITY_ENFORCED];
                if(!documentList.isEmpty()){
                    if(documentList[0].ContentDocumentLinks.size() > 0){
                        imageExistFlag=true;
                    }
                }   
            } 
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('Ind_IncomeDetailsCtrl', 'fetchDocument', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        return imageExistFlag;
    }
        
    @AuraEnabled
    public static Boolean checkImageExistForTractorCase(String vehicleId, String documentType ){
        Boolean imageExistFlag = false;
        try{
            if(vehicleId != null){
                List<Documents__c> documentList= [select Id,(SELECT Id FROM ContentDocumentLinks) from Documents__c Where Vehicle_Detail__c =: vehicleId And Name =: documentType WITH SECURITY_ENFORCED];
                if(!documentList.isEmpty()){
                    if(documentList[0].ContentDocumentLinks.size() > 0){
                        imageExistFlag=true;
                    }
                }   
            } 
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('Ind_IncomeDetailsCtrl', 'checkImageExistForTractorCase', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        return imageExistFlag;
    }
    
    /*
    * @Method Name: deleteIncomeDetails
    * @Created by:  Neha Gosavi
    * @description: Takes income detail record id as parameter and deletes that particular record.
    * @Param:       current Income Detail ID
    */
    @AuraEnabled
    public static void deleteIncomeDetails(String incomeDetailId){
        try{
            if(incomeDetailId!=null){
                SObject incomeDetailsObject= [Select Id from Income_Details__c Where Id= :incomeDetailId WITH SECURITY_ENFORCED ];
                if (Schema.sObjectType.Income_Details__c.isAccessible() && Schema.sObjectType.Income_Details__c.isDeletable() ){
                    delete incomeDetailsObject;
                }
            }
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('Ind_IncomeDetailsCtrl', 'deleteIncomeDetails', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }  

    public class ResponseWrapper{
        public Boolean isEarningApplicant {get;set;}
        public Boolean isIncomeSourcesExists {get;set;}
    }

    /*
    * @Method Name: getValidationInputs
    * @Created by:  Sanketkumar Patil
    * @description: Method to return Inputs for validating Income Details navigation to Next Sub-Module.
    * @Param:       Applicant ID
    */
    @AuraEnabled
    public static String getValidationInputs(String applicantId){
        try{
            ResponseWrapper validationInputs = new ResponseWrapper();

            List<Applicant__C> appList = [select id, Income_source_available__c, (select id from Income_Details__r) from Applicant__c where id = :applicantId AND In_Active_Applicant__c =false WITH SECURITY_ENFORCED];//CISP-2752
            
            if(!appList.isEmpty()){
                validationInputs.isEarningApplicant = appList[0].Income_source_available__c;

                if(appList[0].Income_Details__r.size() > 0){
                    validationInputs.isIncomeSourcesExists = true;
                } else {
                    validationInputs.isIncomeSourcesExists = false;
                }
            }

            return JSON.serialize(validationInputs);
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('Ind_IncomeDetailsCtrl', 'deleteIncomeDetails', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    /*
      * @Method:      getContentDocumentId
      * @Created by:  Ruchi Jain
      * @Description: Method to check for image if yes then returns contentdocument id
      * @Param:       id contentdocumentId 
      * @Return:     ID
      */
      @AuraEnabled
    public static ID getContentDocumentId(String documentId ){
        try{
            if(documentId != null){
                Set<Id> docIdSet = new Set<Id>();
                for(ContentDocumentLink contentdoc : [Select ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId =: documentId WITH SECURITY_ENFORCED]){
                    docIdSet.add(contentdoc.ContentDocumentId);
                }
                List<ContentVersion> cv=[SELECT Id,ContentDocumentId from Contentversion where ContentDocumentId IN : docIdSet WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
                System.debug('cv.size()=> '+cv.size());
                if(!cv.isEmpty() && cv.size()>0){
                    System.debug('cv[0].ContentDocumentId => '+cv[0].ContentDocumentId);
                    return cv[0].ContentDocumentId;
                } else {
                    return null;
                }
           } 
           else {
            System.debug('documentId=>  '+documentId);
            return null;
           }
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('Ind_IncomeDetailsCtrl', 'fetchDocument', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    /*
      * @Method:      getCustomerProfileForNE
      * @Created by:  Vishal Gadhave
      * @Description: Method to return the customer profile data when the condition is Non Earning (NE)
      * @Param:       None
      * @Return:      Profile Names (List)
      */
      @AuraEnabled
    public static List<Profile_Master__c> getCustomerProfileForNE() {
        try {
                       List<Profile_Master__c>  profileMaster = [SELECT Name from Profile_Master__c where Category__c = 'NE' WITH SECURITY_ENFORCED];
            //if(!profileMaster.isEmpty() && profileMaster.size() > 0) {
                return profileMaster;
            //}
            
        }
        catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('Ind_IncomeDetailsCtrl', 'getCustomerProfileForNE', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
        //CISP - 18498 - START
    /*
      * @Method:      mapProfileToIncomeDetailsOfNEApplicant
      * @Created by:  Sriram
      * @Description: Method to map the profile to Income Detail of NE Applicant
      * @Param:       App ID, Profile Name
      * @Return:      String
      */
    @AuraEnabled
    public static String mapProfileToIncomeDetailsOfNEApplicant(String applicantId, String profileName) {
        try {
            List<Profile_Master__c> pMList = [SELECT Id, Name FROM Profile_Master__c WHERE Name =: profileName];
            if(!pMList.isEmpty())
            {
                Income_Details__c incomDetailRecord = [SELECT Id,Profile__c FROM Income_Details__c WHERE Applicant__c=: applicantId limit 1];
                if(incomDetailRecord != null)
                {
                    incomDetailRecord.Profile__c = pMList[0].Id;
                    update incomDetailRecord;
                    return 'Successfully mapped Profile to Income Detail of NE Applicant';
                }
                else
                return 'No Income Detail(s) present for the Applicant';
            }
            else
            {
                return 'No profile master record(s) present for selected profile';
            }            
        }
        catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('Ind_IncomeDetailsCtrl', 'mapProfileToIncomeDetailsOfNEApplicant', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    //CISP - 18498 - END
    
    /*
      * @Method:      updateProfileNameOfApplicant
      * @Created by:  Vishal Gadhave
      * @Description: Method to update the Profile Name of Applicant
      * @Param:       App ID
      * @Return:      None
      */
      @AuraEnabled
    public static void updateProfileNameOfApplicant(String applicantId, String profileName) {
        try {
                       List<Applicant__c>  appList = [SELECT Profile__c,Customer_Category__c from Applicant__c where Id =: applicantId WITH SECURITY_ENFORCED];
            if(!appList.isEmpty() && appList.size() > 0) {
                system.debug('appList--' + appList);
                appList[0].Profile__c = profileName;
                appList[0].Customer_Category__c = 'NE';//CISP-2560
                update appList;
                system.debug('appList after update '+appList);
            }            
        }
        catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('Ind_IncomeDetailsCtrl', 'updateProfileNameOfApplicant', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
         /*
      * @Method:      checkAPISatus
      * @Created by:  Rohan Saxena
      * @Description: Method to check the API call status
      * @Param:      String LoanId, String incomeId
      * @Return:     String
      */
      @AuraEnabled
    public static String checkAPISatus(String LoanId, String incomeId ){
        Double apiCount=0;
        Integer TotalCountSUP=0;
        Integer TotalCountSDU=0;
        boolean LastStatusSUP= false;
        boolean LastStatusSDU= false;
        String strVal='';
        try{
        List<Income_Details__c> incomeDetail = [SELECT Id,ScanUpload_BS_Api_Count__c,Applicant__c FROM Income_Details__c WHERE id =:incomeId WITH SECURITY_ENFORCED];
        if(!incomeDetail.isEmpty()){
            apiCount= incomeDetail[0].ScanUpload_BS_Api_Count__c;
        }
        List<Integration_Log__c> ScanUploadProcess = new List<Integration_Log__c>();
        List<Integration_Log__c> Integrdata1  = Utilities.getIntegrationLogs('ScanUploadProcess',LoanId );
        List<Integration_Log__c> Integrdata2 =  Utilities.getIntegrationLogs('ScanDocumentUpload', LoanId); 
        ScanUploadProcess.addAll(Integrdata1);
        ScanUploadProcess.addAll(Integrdata2);
        if(!ScanUploadProcess.isEmpty()){
            for(Integration_Log__c integ: ScanUploadProcess){
                if(integ.Service_Name__c=='ScanUploadProcess'){
                if(integ.Status__c=='Success'){
                    if(TotalCountSUP==0){LastStatusSUP=true;}
                    TotalCountSUP++;
                }else if(integ.Status__c=='Failure'){
                    TotalCountSUP++;
                }
            }
            else if(integ.Service_Name__c=='ScanDocumentUpload'){
                if(integ.Status__c=='Success'){
                    if(TotalCountSDU==0){LastStatusSDU=true;}
                    TotalCountSDU++;
                }else if(integ.Status__c=='Failure'){
                    LastStatusSDU = TotalCountSDU==0 ? false : true;
                    TotalCountSDU++;
                }
            }
            }
            if( LastStatusSUP && LastStatusSDU){
                strVal= 'Success';
            }
            else if((!LastStatusSUP || !LastStatusSDU) && (apiCount==TotalCountSUP && apiCount==TotalCountSDU)){
                if(!LastStatusSUP){
                    strVal= 'ScanUploadProcess API got Failed. Please Retry.';
                } else if(!LastStatusSDU){
                    strVal= 'ScanDocumentUpload API got Failed. Please Retry.';
                }
            }
            else if(apiCount > TotalCountSUP || apiCount > TotalCountSDU){
                strVal= 'Processing';
            }
            else{
                strVal='Something went wrong. Please contact to administrator.';
            }
        }
            return strVal;
    }
    catch(Exception e){
        ErrorLoggerUtil.logErrorEvent('Ind_IncomeDetailsCtrl', 'checkAPISatus', 'Apex', e);
        throw new AuraHandledException(System.Label.ExceptionMessage);
    }
}
    @AuraEnabled
    public static Map<String, String>  incomeLegalEntityPicklist() {
        Map<String, String> incomeLegalEntityOptionsMap = new Map<String, String>();

        List<Schema.PicklistEntry> picklistEntries = Opportunity.sObjectType.getDescribe().fields.getMap().get('Customer_Type__c').getDescribe().getPicklistValues();

        for(Schema.PicklistEntry le : picklistEntries){
            incomeLegalEntityOptionsMap.put(le.value , le.label);
        }
        return incomeLegalEntityOptionsMap;
    }

    

}