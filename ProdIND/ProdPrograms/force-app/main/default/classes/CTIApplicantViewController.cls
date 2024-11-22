/*
 * @Class:      DSA_DataTableController
 * @Created by:  Raman Raj Saxena
 * @Description: For CTI Applicant View page data
 * @testclass:  testCTIApplicantViewController
 */ 
public with sharing class CTIApplicantViewController {

    public static final String AADHAR_DOCUMENT_TYPE = 'Aadhaar';

    /*
     * @Method:      getApplicantData
     * @Created by:  Raman Raj Saxena
     * @Description: Generic component for Data Table for DSA functionality
     * @Param:       recordId (String) - Applicant record Id.
     * @Return:      applicantData (ApplicantDataWrapper) - Applicant data containing data for different sections
     History
     Date            Author              Comments
     -------------------------------------------------------------
     26-07-2022      Raman Raj Saxena        Created
     01-08-2022      Haarika Chodisetti      Modified to call new methods and query extra fields
     ------------------------------------------------------------*/    
    @AuraEnabled(cacheable = true)
    public static ApplicantDataWrapper getApplicantData(String recordId){
        try {
            ApplicantDataWrapper applicantData = new ApplicantDataWrapper();
            Applicant__c applicant = [SELECT Id, Name, Customer_First_Name__c, Customer_Last_Name__c, Contact_Number__c, PAN_No__c, Email_Id__c,applicant_number__c,
                                      Consent_Received__c, Aadhar_No__c, Whatsapp_Number__c, Gender__c, toLabel(Marital_Status__c), Opportunity__c, Aadhar_OTP_or_Biometric__c,
                                      Income_Ca__c,Profile__c,Declared_income__c,Is_this_current_residence_cum_office__c,Employer_Business_Name__c,
                                      Office_Address_Line_1__c,Office_Address_Line_2__c,Office_PinCode__c, Office_City__c, Office_District__c, Office_State__c,
                                      Father_s_name__c, Mother_s_name__c, Spouse_Name__c, Customer_Qualification__c,Current_Same_As_Permanent__c, Customer_Code__c,
                                      Opportunity__r.Loan_amount__c, Opportunity__r.Requested_tenure_Required_tenure__c, Opportunity__r.Required_ROI__c, Opportunity__r.EMI_Amount__c,Opportunity__r.Application_number__c,
                                      Opportunity__r.Product_Type__c, Opportunity__r.Vehicle_type__c,Opportunity__r.On_Road_price__c,Opportunity__r.Vehicle_Pincode__c,Opportunity__r.Requested_loan_amount__c,Opportunity__r.IO_Loan_Amount__c,Opportunity__r.IO_Required_ROI__c,
                                      Opportunity__r.Ex_showroom_price_carwale__c,Opportunity__r.Discount_on_Basic_Price__c,Opportunity__r.RTO_Road_Tax__c,Opportunity__r.On_Road_price_carwale__c,
                                      Opportunity__r.Required_Tenure__c,Opportunity__r.Name,Opportunity__r.Aggregator_Source__c,Opportunity__r.Motor_Insurance_Premium__c,Opportunity__r.Dealer_Quoted_On_Road_Price__c,Opportunity__r.Sanction_Status__c,
                                      Opportunity__r.Total_Funded_premium_amount__c,Opportunity__r.X1st_yr_Insurance_Premium__c,Opportunity__r.Total_Funded_Premium__c,Opportunity__r.Funded__c,Opportunity__r.Non_Funded__c,Opportunity__r.Lead_number__c,
                                      (SELECT Gender__c,KYC_Address_Line_1__c, KYC_Address_Line_2__c, KYC_City__c, KYC_District__c, KYC_State__c, 
                                      KYC_Pin_Code__c, KYC_DOB__c, Document_Type__c, Masked_KYC_No__c, Re_KYC__c, Is_Address_As_per_Bank__c,
                                      KYC_name__c,Address_line_CR_1__c,Address_line_CR_2__c,Pin_code_CR__c,City_CR__c,District_CR__c,State_CR__c, Proof_of_Address_POA__c,
                                      Address_line_1_PR__c,Address_line_2_PR__c,Pin_code_PR__c,City_PR__c,District_PR__c,State_PR__c,Current_Residential_Address_Proof__c,Permanent_Residential_Address_Proof__c
                                      FROM Documents__r)
                                      FROM Applicant__c WHERE Id =: recordId];
            applicantData.applicant = applicant;
       
            if(applicant.Documents__r != null && !applicant.Documents__r.isEmpty()){
                applicantData.aadharAddressDetails = getAadharAddressDetails(applicant);
                applicantData.poaDetails = getPOADetails(applicant);
    
            }

            if(applicant.Income_Ca__c != null && applicant.Profile__c != null){
                applicantData.incomeDetails = getIncomeDetails(applicant.Id);
                applicantData.existingEMIDetails = getexistingEMIDetails(applicant.Id);
            }
            if(String.isNotBlank(applicant.Opportunity__c)){
                applicantData.vehicleDetails = getVehicleDetails(applicant);
                applicantData.initialOfferDetails = getInitialOfferDetails(applicant);
            } 
            applicantData.insuranceDetails = getInsuranceDetails(applicant);
            applicantData.finalTermDetails = getfinalTermDetails(applicant);
            applicantData.currentAddressDetails = getCurrentAddressDetails(applicant.Id);
            applicantData.permanentAddressDetails = getPermanentAddressDetails(applicant.Id);
            
            return applicantData;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent(
                CTIApplicantViewController.class.getName(),
                ' getApplicantData ',
                System.Label.Apex,
                e
            );
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    /*
     * @Method:      getRefreshedApplicantData
     * @Created by:  Haarika Chodisetti
     * @Description: fetches the updated data
     * @Param:       recordId (String) - Applicant record Id.
     * @Return:      applicantData (ApplicantDataWrapper) - Applicant data containing data for different sections
     History
     Date            Author              Comments
     -------------------------------------------------------------
     01-08-2022      Haarika Chodisetti         Created
     ------------------------------------------------------------*/
    @AuraEnabled
    public static ApplicantDataWrapper getRefreshedApplicantData(String recordId){
        return getApplicantData(recordId);
    }
    
    /*
     * @Method:      getAadharAddressDetails
     * @Created by:  Raman Raj Saxena
     * @Description: fetches the Aadhar document of Applicant
     * @Param:       applicant (Applicant__c) - Applicant record.
     * @Return:      Documents__c - Documents__c data of passed Applicant
     History
     Date            Author              Comments
     -------------------------------------------------------------
     26-07-2022      Raman Raj Saxena        Created
     ------------------------------------------------------------*/
    public static Documents__c getAadharAddressDetails(Applicant__c applicant){
        Documents__c aadharDocument;
        for(Documents__c doc : applicant.Documents__r){
            if(AADHAR_DOCUMENT_TYPE.equals(doc.Document_Type__c)){
                if(doc.Masked_KYC_No__c != null && !doc.Masked_KYC_No__c?.contains('*')){
                    doc.Masked_KYC_No__c = doc.Masked_KYC_No__c.leftPad(12, '*');
                }
                aadharDocument = doc;
            }
        }
        return aadharDocument;
    }

    /*
     * @Method:      getPOADetails
     * @Created by:  Haarika Chodisetti
     * @Description: fetches the Aadhar document of Applicant
     * @Param:       applicant (Applicant__c) - Applicant record.
     * @Return:      Documents__c - Documents__c data of passed Applicant
     History
     Date            Author              Comments
     -------------------------------------------------------------
     01-08-2022      Haarika Chodisetti         Created
     ------------------------------------------------------------*/
     public static Documents__c getPOADetails(Applicant__c applicant){
        Documents__c poaDocument;
        for(Documents__c doc : applicant.Documents__r){
            if(doc.Proof_of_Address_POA__c == true){
                poaDocument = doc;
            }
        }
        return poaDocument;
    }

    /*
     * @Method:      getCurrentAddressDetails
     * @Created by:  Haarika Chodisetti
     * @Description: fetches the Current document of Applicant
     * @Param:       applicant (Applicant__c) - Applicant record.
     * @Return:      Documents__c - Documents__c data of passed Applicant
     History
     Date            Author              Comments
     -------------------------------------------------------------
     01-08-2022      Haarika Chodisetti         Created
     ------------------------------------------------------------*/
     public static Documents__c getCurrentAddressDetails(String applicantId){
        List<Documents__c> currentAddress = [SELECT Id,KYC_Address_Line_1__c, KYC_Address_Line_2__c, KYC_City__c, KYC_District__c, KYC_State__c, 
                                                KYC_Pin_Code__c, KYC_DOB__c, Document_Type__c,Current_Residential_Address_Proof__c,Permanent_Residential_Address_Proof__c FROM Documents__c WHERE Current_Residential_Address_Proof__c = true AND Applicant__c =: applicantId];
        return (currentAddress != null && !currentAddress.isEmpty())?currentAddress[0]:null;
    }

    /*
     * @Method:      getPermanentAddressDetails
     * @Created by:  Haarika Chodisetti
     * @Description: fetches the Permanent address of Applicant
     * @Param:       applicant (Applicant__c) - Applicant record.
     * @Return:      Documents__c - Documents__c data of passed Applicant
     History
     Date            Author              Comments
     -------------------------------------------------------------
     01-08-2022      Haarika Chodisetti         Created
     ------------------------------------------------------------*/
     public static Documents__c getPermanentAddressDetails(String applicantId){
        List<Documents__c> permanentAddress = [SELECT Id,KYC_Address_Line_1__c, KYC_Address_Line_2__c, KYC_City__c, KYC_District__c, KYC_State__c, 
                                                KYC_Pin_Code__c, KYC_DOB__c, Document_Type__c,Current_Residential_Address_Proof__c,Permanent_Residential_Address_Proof__c FROM Documents__c WHERE Permanent_Residential_Address_Proof__c = true AND Applicant__c =: applicantId];
        return (permanentAddress != null && !permanentAddress.isEmpty())?permanentAddress[0]:null;
    }


    /*
     * @Method:      getVehicleDetails
     * @Created by:  Raman Raj Saxena
     * @Description: fetches the vehicle details of Applicant
     * @Param:       applicant (Applicant__c) - Applicant record.
     * @Return:      Vehicle_Detail__c - Vehicle_Detail__c data of passed Applicant
     History
     Date            Author              Comments
     -------------------------------------------------------------
     26-07-2022      Raman Raj Saxena         Created
     ------------------------------------------------------------*/
    public static Vehicle_Detail__c getVehicleDetails(Applicant__c applicant){
        Vehicle_Detail__c loanVehicle;
        List<Vehicle_Detail__c> vehicles = [SELECT City__c, Make__c, Model__c, Variant__c,Vehicle_type__c,Executive_Name__c,Executive_Contact_Number__c,Dealer_Sub_dealer_name__c,Vehicle_Registration_number__c FROM Vehicle_Detail__c WHERE Loan_Application__c = :applicant.Opportunity__c];
        if(vehicles != null && !vehicles.isEmpty()){
            loanVehicle = vehicles[0];
        }
        return loanVehicle;
    }

    /*
     * @Method:      getInsuranceDetails
     * @Created by:  Haarika Chodisetti
     * @Description: fetches the Insurance details of Applicant
     * @Param:       applicant (Applicant__c) - Applicant record.
     * @Return:      List<InsuranceDetails__c> - List of Insurance Details data of passed Applicant
     History
     Date            Author              Comments
     -------------------------------------------------------------
     01-08-2022      Haarika Chodisetti         Created
     ------------------------------------------------------------*/
    public static List<InsuranceDetails__c> getInsuranceDetails(Applicant__c applicant){
        List<InsuranceDetails__c> insurances = [SELECT Name,Insurance_Plan__c,Amount__c,Funded_Non_funded__c FROM InsuranceDetails__c WHERE Loan_Application__c = :applicant.Opportunity__c];
        return insurances;
    }

    /*
     * @Method:      getfinalTermDetails
     * @Created by:  Haarika Chodisetti
     * @Description: fetches the final term details of Applicant
     * @Param:       applicant (Applicant__c) - Applicant record.
     * @Return:      Final_Term__c - Final_Term__c data of passed Applicant
     History
     Date            Author              Comments
     -------------------------------------------------------------
     01-08-2022      Haarika Chodisetti         Created
     ------------------------------------------------------------*/
    public static Final_Term__c getfinalTermDetails(Applicant__c applicant){
        Final_Term__c finalTerm;
        List<Final_Term__c> finalTerms = [SELECT Name, IO_Loan_Amount__c, IO_Tenure__c, Net_IRR__c, IO_EMI_Amount__c, IO_OfferengineMaxLoanAmount__c, IO_OfferengineMaxTenure__c,
                                            Documentation_charges__c, Service_charges__c
                                            FROM Final_Term__c WHERE Loan_Application__c = :applicant.Opportunity__c];
        if(finalTerms != null && !finalTerms.isEmpty()){
            finalTerm = finalTerms[0];
        }
        return finalTerm;
    }

    /*
     * @Method:      getIncomeDetails
     * @Created by:  Haarika Chodisetti
     * @Description: fetches the income details of Applicant
     * @Param:       appId (String) - Applicant record Id.
     * @Return:      Income_Details__c - Income Details data of passed Applicant Id
     History
     Date            Author              Comments
     -------------------------------------------------------------
     01-08-2022      Haarika Chodisetti         Created
     ------------------------------------------------------------*/
    public static Income_Details__c getIncomeDetails(String appId){
        Income_Details__c income;
        List<Income_Details__c> incomes = [SELECT Is_Income_Credited_In_Bank_Account__c,Do_You_File_ITR__c,Do_You_File_GST__c,GST_No__c,Balance_Account_Exists__c,
                                            Avg_Income__c,Is_Salaried__c,Is_Self_Employed__c,Employer_Business_Name__c,Office_Address_Line_1__c,Office_Address_Line_2__c,
                                            Office_City__c,Is_this_Current_Residence_Cum_office__c,Is_this_Permanent_Residence_Cum_office__c,Office_District__c,
                                            Capture_GST_Method__c, Capture_Income_Method__c, Capture_ITR_Method__c, ABB_Method__c,
                                            Office_PinCode__c,Office_State__c FROM Income_Details__c WHERE Applicant__c = :appId];
        if(incomes != null && !incomes.isEmpty()){
            income = incomes[0];
        }
        return income;
    }

    /*
     * @Method:      getexistingEMIDetails
     * @Created by:  Haarika Chodisetti
     * @Description: fetches the existing EMI details of Applicant
     * @Param:       appId (String) - Applicant record Id.
     * @Return:      Existing_EMI__c - Existing EMI Details data of passed Applicant Id
     History
     Date            Author              Comments
     -------------------------------------------------------------
     01-08-2022      Haarika Chodisetti         Created
     ------------------------------------------------------------*/
    public static Existing_EMI__c getexistingEMIDetails(String appId){
        Existing_EMI__c exem;
        List<Existing_EMI__c> exems = [SELECT EMI__c,Outstanding_Amount__c FROM Existing_EMI__c WHERE Applicant_Id__c = :appId WITH SECURITY_ENFORCED];
        if(exems != null && !exems.isEmpty()){
            exem = exems[0];
        }
        return exem;
    }

    /*
     * @Method:      getInitialOfferDetails
     * @Created by:  Raman Raj Saxena
     * @Description: fetches the Initial Offer(Opportunity) details of Applicant
     * @Param:       applicant (Applicant__c) - Applicant record.
     * @Return:      Opportunity - Initial Offer(Opportunity) Details data of passed Applicant Id
     History
     Date            Author              Comments
     -------------------------------------------------------------
     26-07-2022      Raman Raj Saxena         Created
     ------------------------------------------------------------*/
    public static Opportunity getInitialOfferDetails(Applicant__c applicant){
        return applicant.Opportunity__r;
    }

    
    //Raman Raj Saxena- 26-07-2022 - To store different objects data related to an applicant
    //Haarika - 01-08-2022 - Updated wrapper class to store income and Existing EMI details as well
    public class ApplicantDataWrapper {
        @AuraEnabled
        public Applicant__c applicant { get; set; }
        @AuraEnabled
        public Documents__c aadharAddressDetails { get; set; }
        @AuraEnabled
        public Documents__c poaDetails { get; set; }
        @AuraEnabled
        public Documents__c currentAddressDetails { get; set; }
        @AuraEnabled
        public Documents__c permanentAddressDetails { get; set; }
        @AuraEnabled
        public Vehicle_Detail__c vehicleDetails { get; set; }
        @AuraEnabled
        public Opportunity initialOfferDetails { get; set; }
        @AuraEnabled
        public Income_Details__c incomeDetails { get; set; }
        @AuraEnabled
        public Existing_EMI__c existingEMIDetails { get; set; }
        /*@AuraEnabled
        public Documents__c documentDetails { get; set; }*/
        @AuraEnabled
        public List<InsuranceDetails__c> insuranceDetails { get; set; }
        @AuraEnabled
        public Final_Term__c finalTermDetails { get; set; }
    }

}