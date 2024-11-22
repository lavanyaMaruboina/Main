/*------------------------------------------------------------
Author:        Anji_Yeruva
Company:       Persistent Systems
Description:   Insurance Details
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-20-2021      Anji_Yeruva      Created
------------------------------------------------------------*/
public with sharing class IND_InsuranceDetailsLWC_controller {
    
    /*
    * @Method:      enableCheckbox
    * @Created by:  
    * @Description: method for enabling checkbox.
    * @Param:      String appId
    * @Return:     String
    */
    @AuraEnabled
    public static String enableCheckbox(String appId) {
        String successMessage;
        String isConsentbln;
        try {
            List < Applicant__c > updateApplicantLst = new List < Applicant__c > ();
            for (Applicant__c applObj: [SELECT Id, Insurance_Consent_Received__c,Insurance_consent_sent_on__c FROM Applicant__c WHERE Id =: appId AND In_Active_Applicant__c = false AND Insurance_Consent_Received__c != true WITH SECURITY_ENFORCED]) {
                applObj.Insurance_Consent_Received__c = true;
                applObj.Insurance_consent_sent_on__c = DateTime.Now();
                updateApplicantLst.add(applObj);
            }
            
            if (updateApplicantLst.size() > 0 && Schema.sObjectType.Applicant__c.isupdateable()) {
                update updateApplicantLst;
                return 'true';
            } else {
                return 'false';
            }
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('InsuranceConsentDateTimeHandle', 'enableCheckbox', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    //wrapper class
    public class VehicleDetailsWrp {
        @AuraEnabled public String vehicleName;
        @AuraEnabled public String Premium;
        @AuraEnabled public String applicatnName;
        @AuraEnabled public String appId;
    }

         /*
* @Method:      fetchOppourtunity details
* @Created by:  Nidhi Dhote
* @Description: This method will return data from fetch Oppourtunity object.
* @Param:       Current Opportunity Id
* @Return:      return Opportunity code data from Oppourtunity object.   
*/
@AuraEnabled
public static List<Opportunity> fetchOppourtunityData(String loanApplicantionId){
    try {
        if(String.isNotBlank(loanApplicantionId)){
            List<Opportunity> listOpp = [SELECT Id, Vehicle_Type__c, StageName,LastStageName__c,LeadSource,Product_Type__c,Submitted_Tabs__c,Loan_amount__c,Required_Loan_amount__c,Total_Exposures_Amount__c,Sub_Stage__c,Existing_Borrowers_Exposure_Amt__c,Existing_Co_Borrowers_Exposure_Amt__c,Existing_Others_Exposure_Amt__c,Total_Bank_Exposure__c,Customer_Type__c,(Select Id,Name,IsPrimary__c FROM Applicants__r Where Applicant_Type__c = 'Beneficiary' AND In_Active_Applicant__c=false  AND IsPrimary__c = true LIMIT 1),(Select Id,Vehicle_Detail__c,Applicant__c from Insurance_Details__r) FROM Opportunity WHERE Id =: loanApplicantionId WITH SECURITY_ENFORCED];//Ola Integration changes //CISP-3194 added Product_Type__c // LeadSource for D2C
            return listOpp;
        }
        System.debug('line error '+ loanApplicantionId);
        return null;
    } catch (Exception e) {
        ErrorLoggerUtil.logErrorEvent('IND_InsuranceDetailsLWC_controller', ' fetchOppourtunityData ', System.Label.Apex, e);
        throw new AuraHandledException(System.Label.ExceptionMessage);
    }
}
    
    /*
    * @Method:      getMotorVechileDetails
    * @Created by:  
    * @Description: method for getting motor vehicle details.
    * @Param:      String appId
    * @Return:     VehicleDetailsWrp
    */
    @AuraEnabled
    public static VehicleDetailsWrp getMotorVechileDetails(String appId) {
        VehicleDetailsWrp vewrp = new VehicleDetailsWrp();
        Set < String > oppIDs = new Set < String > ();
        System.debug('APPID @@@@' + appId);
        for (Applicant__c app: [SELECT Id, Name, Opportunity__r.Motor_Insurance_Premium__c,DocAuth_Application_Id__c FROM Applicant__c WHERE Id =: appId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED]) {
            system.debug('QUERY>>>>>>' + app);
            vewrp.appId = app.DocAuth_Application_Id__c;
            vewrp.applicatnName = app.Name;
            vewrp.Premium =app.Opportunity__r.Motor_Insurance_Premium__c!=null ? String.valueof(app.Opportunity__r.Motor_Insurance_Premium__c):null;
            oppIDs.add(app.Opportunity__c);
        }
        
        for (Vehicle_Detail__c veDeObj: [SELECT id, Name FROM Vehicle_Detail__c WHERE Loan_Application__c IN: oppIDs WITH SECURITY_ENFORCED LIMIT 1]) {
            vewrp.vehicleName = veDeObj.Name;
        }
        return vewrp;
    }
    //wrapper class
    public class Ins_Product {
        @AuraEnabled public String Ins_Product;
        @AuraEnabled public String Plan_Code;
        @AuraEnabled public String Plan_Name;
        @AuraEnabled public String Premium;
        @AuraEnabled public String Sum_Insured;
        @AuraEnabled public String LHC;
        @AuraEnabled public String Plan_Recommend;
        @AuraEnabled public String Disable_Funding;
        @AuraEnabled public String Funding_Option;
        @AuraEnabled public String Stage;
        @AuraEnabled public String Sub_Stage;
        @AuraEnabled public Decimal ltvWithInsurance;
        @AuraEnabled public Decimal ltvWithoutInsurance;
        @AuraEnabled public Decimal totalInsurancePayable;
        @AuraEnabled public Double premiumFunded;
        @AuraEnabled public Double proposalLtv;
        @AuraEnabled public Double bmi;
        @AuraEnabled public Double height;
        @AuraEnabled public Double weight;
    }
    
    /*
    * @Method:      fetchDataFromApplicatntObj
    * @Created by:  
    * @Description: method for fetching data from Applicant details object.
    * @Param:       String loanAppID, String appType
    * @Return:     Applicant__c
    */
    @AuraEnabled
    public static Applicant__c fetchDataFromApplicatntObj(String loanAppID, String appType, String applicantId) {
        Applicant__c appObj;
        if(String.isNotBlank(applicantId)){
            for (Applicant__c app: [SELECT Id, Gender__c, Applicant_Type__c,DocAuth_Application_Id__c, Opportunity__r.Submitted_Tabs__c,Height__c,Weight__c,BMI__c FROM Applicant__c WHERE Applicant_Type__c =: appType AND In_Active_Applicant__c = false AND Opportunity__c =: loanAppID AND Id=:applicantId WITH SECURITY_ENFORCED]) {
                appObj = app;
            }
        }else{
            for (Applicant__c app: [SELECT Id, Gender__c, Applicant_Type__c,DocAuth_Application_Id__c, Opportunity__r.Submitted_Tabs__c,Height__c,Weight__c,BMI__c FROM Applicant__c WHERE Applicant_Type__c =: appType AND In_Active_Applicant__c = false AND Opportunity__c =: loanAppID WITH SECURITY_ENFORCED]) {
                appObj = app;
            }
        }
        return appObj;
    }
    
    /*
    * @Method:      fetchDataFromLoanApplication
    * @Created by:  nandini
    * @Description: method for fetching data from opportunity details object.
    * @Param:       String loanAppID
    * @Return:     Opportunity
    */
    @AuraEnabled
    public static Opportunity fetchDataFromLoanApplication(String loanAppID) {
        opportunity loanoppObj;
        for (Opportunity loanapp: [SELECT Id, Vehicle_Type__c, Is_customer_interested_in_a_motor_insura__c,Application_number__c,
                                   Required_Tenure__c,
                                   Age__c, Variant__c, Funded__c, Non_Funded__c,
                                   Motor_Insurance_Premium__c, Agreement_Amount__c,
                                   Insurance_Expiry_date__c,
                                   Insurance_expiring_within_90_days__c,X1st_yr_Insurance_Premium__c,
                                   Loan_amount__c,
                                   Vehicle_Sub_Category__c
                                   FROM Opportunity
                                   WHERE id =: loanAppID
                                   WITH SECURITY_ENFORCED
                                  ]) {
                                      loanoppObj = loanapp;
                                  }
        return loanoppObj;
    }
    
    /*
    * @Method:      fetchAgeFromDocument
    * @Created by:  nandini
    * @Description: method for fetching data from Documents details object.
    * @Param:       String loanAppID
    * @Return:     Documents__c
    */
    private static Documents__c fetchAgeFromDocument(String loanAppID,String applicantId) {
        Documents__c docObj;
        //docObj=
        System.debug('app id and application id => '+ loanAppID + ' '+applicantId);
        for(Documents__c dcObj: [SELECT Id,Proof_of_Identity_POI__c, Opportunity_Relation__c,Applicant__c, Age__c,KYC_DOB__c,Gender__c
                                 FROM Documents__c 
                                 WHERE Proof_of_Identity_POI__c =true AND Opportunity_Relation__c =:loanAppID AND Applicant__c =:applicantId
                                 WITH SECURITY_ENFORCED]){
                                     if(dcObj.KYC_DOB__c!=null){
                                     docObj =dcObj;
                                     }
                                 }
        System.debug('doc obj => '+docObj);
        return docObj;
    }
    
    /*
    * @Method:      fetchAgreementFromFinalTerm
    * @Created by:  nandini
    * @Description: method for fetching data from FinalTerm  object.
    * @Param:       String loanAppID
    * @Return:     Final_Term__c
    */
    private static Final_Term__c fetchAgreementFromFinalTerm(String loanAppID) {
        return fetchAgreementFromFinalTerm(loanAppID,'');
    }

    //SFTRAC-176 related changes - Method Overloading
    private static Final_Term__c fetchAgreementFromFinalTerm(String loanAppID, String assetId) {
        Final_Term__c finalTermObj;
        
        if(String.isBlank(assetId)){
            for(Final_Term__c ftObj: [SELECT Id,Agreement_Amount__c,Loan_Amount__c,Tenure__c, Installment_Frequency__c
                                        FROM Final_Term__c 
                                        WHERE Loan_Application__c =: loanAppID 
                                        WITH SECURITY_ENFORCED]){
                                            finalTermObj =ftObj;
                                        }
        }else{
            for(Final_Term__c ftObj: [SELECT Id,Agreement_Amount__c,Loan_Amount__c,Tenure__c, Installment_Frequency__c
                                        FROM Final_Term__c 
                                        WHERE Loan_Application__c =: loanAppID AND Vehicle_Detail__c =: assetId
                                        WITH SECURITY_ENFORCED]){
                                            finalTermObj =ftObj;
                                        }
        }
        
        return finalTermObj;
    }
    
    /*
    * @Method:      fetchDataFromvehicleDetailsObj
    * @Created by:  
    * @Description: method for fetching data from vehicle details object.
    * @Param:       String loanAppID
    * @Return:     Vehicle_Detail__c
    */
    @AuraEnabled
    public static Vehicle_Detail__c fetchDataFromvehicleDetailsObj(String loanAppID) {
        return fetchDataFromvehicleDetailsObj(loanAppID,'');
    }

    //SFTRAC-176 related changes - Method Overloading
    @AuraEnabled
    public static Vehicle_Detail__c fetchDataFromvehicleDetailsObj(String loanAppID, String assetId) {
        Vehicle_Detail__c vechDetailObj;
        if(String.isBlank(assetId)){
            for (Vehicle_Detail__c vedObj: [SELECT ID, Product__c, Loan_Application__c,
                                        Variant__c,
                                        Ins_Expiry_date__c,
                                        Vehicle_type__c,
                                        Insurance_expiring_within_60_days__c,//D2C Change //CFDI-1164
                                        Loan_Application__r.Product_Type__c,
                                        Loan_Application__r.Vehicle_Type__c,
                                        Loan_Application__r.Basic_Price__c, 
                                        Loan_Application__r.GST_Amount__c,
                                        Loan_Application__r.Dealer_Disc_to_Customer__c,
                                        Loan_Application__r.RTO_Road_Tax_New__c,
                                        Loan_Application__r.RTO_Road_Tax__c,
                                        Loan_Application__r.Other_charges__c,
                                        Loan_Application__r.X1st_yr_Insurance_Premium__c,
                                        Loan_Application__r.Required_Loan_amount__c,
                                        Loan_Application__r.Total_Funded_Premium__c,
                                        Loan_Application__r.Funding_on_Ex_Showroom__c,
                                        Loan_Application__r.Funding_on_ORP__c
                                        FROM Vehicle_Detail__c
                                        WHERE Loan_Application__c =: loanAppID
                                        WITH SECURITY_ENFORCED
                                       ]) {
                                           vechDetailObj = vedObj;
                                       }
        }else{
            for (Vehicle_Detail__c vedObj: [SELECT ID, Product__c, Loan_Application__c, Is_Customer_Interested_in_MotorInsurance__c,
                                        X1st_yr_Insurance_Premium__c,
                                        Variant__c,
                                        Ins_Expiry_date__c,
                                        Vehicle_type__c,
                                        Insurance_expiring_within_60_days__c,//D2C Change //CFDI-1164
                                        Loan_Application__r.Product_Type__c,
                                        Loan_Application__r.Vehicle_Type__c,
                                        Loan_Application__r.Basic_Price__c, 
                                        Loan_Application__r.GST_Amount__c,
                                        Loan_Application__r.Dealer_Disc_to_Customer__c,
                                        Loan_Application__r.RTO_Road_Tax_New__c,
                                        Loan_Application__r.RTO_Road_Tax__c,
                                        Loan_Application__r.Other_charges__c,
                                        Loan_Application__r.X1st_yr_Insurance_Premium__c,
                                        Loan_Application__r.Required_Loan_amount__c,
                                        Loan_Application__r.Total_Funded_Premium__c,
                                        Loan_Application__r.Funding_on_Ex_Showroom__c,
                                        Loan_Application__r.Funding_on_ORP__c
                                        FROM Vehicle_Detail__c
                                        WHERE Loan_Application__c =: loanAppID AND Id =: assetId
                                        WITH SECURITY_ENFORCED
                                       ]) {
                                           vechDetailObj = vedObj;
                                       }
        }
        
        return vechDetailObj;
    }
    
    /*
    * @Method:      existInsuranceDetailsMethod
    * @Created by:  
    * @Description: On page load,Query the Insurance Details object for the current loan application record.
    If there is a record which means 
    User had already submitted the insurance details and consent is received 
    and is revisiting the page. Pull the relevant details and render on the page and make the page read only
    * @Param:      String loanAppID, String applicantId
    * @Return:          List < Ins_Product >
    */
    @AuraEnabled
    public static List < Ins_Product > existInsuranceDetailsMethod(String loanAppID, String applicantId) {
        List < Ins_Product > insProdLst = new List < Ins_Product > ();
        for (InsuranceDetails__c insurDetailObj: [SELECT id, Name, Amount__c, Applicant__c,
                                                  Funded_Non_funded__c, Funded_Premium__c, Insurance_Plan__c, Loan_Application__c, 
                                                  Loan_Application__r.StageName, Loan_Application__r.Sub_Stage__c,Applicant__r.LTV_with_Insurance__c,
                                                  Applicant__r.LTV_without_insurance__c,Applicant__r.Total_Insurance_Payable__c
                                                  FROM InsuranceDetails__c
                                                  WHERE Loan_Application__c =: loanAppID
                                                  AND Applicant__c =: applicantId
                                                  WITH SECURITY_ENFORCED
                                                 ]) {
                                                     Ins_Product insprodObj = new Ins_Product();
                                                     insprodObj.Ins_Product = insurDetailObj.Name;
                                                     insprodObj.Plan_Code = insurDetailObj.Insurance_Plan__c;
                                                     insprodObj.Plan_Name = insurDetailObj.Insurance_Plan__c;
                                                     insprodObj.Sum_Insured = '';
                                                     insprodObj.Premium =insurDetailObj.Amount__c!=null ? String.valueof(insurDetailObj.Amount__c):null;
                                                     insprodObj.LHC = insurDetailObj.Amount__c!= null ? String.valueof(insurDetailObj.Amount__c):null;
                                                     insprodObj.Plan_Recommend = 'Y';
                                                     insprodObj.Disable_Funding = insurDetailObj.Funded_Non_funded__c == 'Funded' ? 'Y' : 'N';
                                                     insprodObj.Funding_Option = insurDetailObj.Funded_Non_funded__c == 'Funded' ? 'Y' : 'N';
                                                     insprodObj.Stage = insurDetailObj.Loan_Application__r.StageName;
                                                     insprodObj.Sub_Stage = insurDetailObj.Loan_Application__r.Sub_Stage__c;
                                                     insprodObj.ltvWithInsurance =insurDetailObj.Applicant__r.LTV_with_Insurance__c;
                                                     insprodObj.ltvWithoutInsurance =insurDetailObj.Applicant__r.LTV_without_insurance__c;
                                                     insprodObj.totalInsurancePayable=insurDetailObj.Applicant__r.Total_Insurance_Payable__c;
                                                     insprodObj.premiumFunded = insurDetailObj.Funded_Premium__c;
                                                     insProdLst.add(insprodObj);
                                                 }
        return insProdLst;
    }

    /*
    * @Method:      existTFInsuranceDetailsMethod
    * @Created by:  Chaynnitt Agarwal
    * @Description: method for getting insurance details
    * @Param:       String loanAppID, String applicantId, String assetId
    * @Return:      String
    */
    @AuraEnabled
    public static List <Ins_Product> existTFInsuranceDetailsMethod(String loanAppID, String applicantId, String assetId) {
        List <Ins_Product> insProdLst = new List <Ins_Product> ();
        List<InsuranceDetails__c> insuranceDetailLst = new List<InsuranceDetails__c>();
        insuranceDetailLst = [SELECT Id, Name, Amount__c, Applicant__c, Loan_Application__r.StageName, Loan_Application__r.Sub_Stage__c,Funded_Non_funded__c, Insurance_Plan__c, Loan_Application__c, Proposal_LTV__c, EMI_Passed_in_API__c,Vehicle_Detail__r.L1_Insurance_Submitted__c,Vehicle_Detail__r.L2_Insurance_Submitted__c,Vehicle_Detail__r.LTV_With_Insurance__c,Vehicle_Detail__r.LTV_Without_Insurance__c,Vehicle_Detail__r.Total_Insurance_Payable__c,Vehicle_Detail__r.Funded_Premium__c,Applicant__r.BMI__c,Applicant__r.Height__c,Applicant__r.Weight__c FROM InsuranceDetails__c WHERE Loan_Application__c =: loanAppID AND Applicant__c =: applicantId AND Vehicle_Detail__c =:assetId WITH SECURITY_ENFORCED];
        for (InsuranceDetails__c insurDetailObj: insuranceDetailLst) {
            Ins_Product insprodObj = new Ins_Product();
            insprodObj.Ins_Product = insurDetailObj.Name;
            insprodObj.Plan_Code = insurDetailObj.Insurance_Plan__c;
            insprodObj.Plan_Name = insurDetailObj.Insurance_Plan__c;
            insprodObj.Plan_Name = insurDetailObj.Insurance_Plan__c;
            insprodObj.Sum_Insured = '';
            insprodObj.Premium =insurDetailObj.Amount__c!=null ? String.valueof(insurDetailObj.Amount__c):null;
            insprodObj.LHC = insurDetailObj.Amount__c!= null ? String.valueof(insurDetailObj.Amount__c):null;
            insprodObj.Plan_Recommend = 'Y';
            insprodObj.Disable_Funding = insurDetailObj.Funded_Non_funded__c == 'Funded' ? 'Y' : 'N';
            insprodObj.Funding_Option = insurDetailObj.Funded_Non_funded__c == 'Funded' ? 'Y' : 'N';
            insprodObj.Stage = insurDetailObj.Loan_Application__r.StageName;
            insprodObj.Sub_Stage = insurDetailObj.Loan_Application__r.Sub_Stage__c;
            insprodObj.ltvWithInsurance =insurDetailObj.Vehicle_Detail__r.LTV_With_Insurance__c;
            insprodObj.ltvWithoutInsurance =insurDetailObj.Vehicle_Detail__r.LTV_Without_Insurance__c;
            insprodObj.totalInsurancePayable=insurDetailObj.Vehicle_Detail__r.Total_Insurance_Payable__c;
            insprodObj.premiumFunded = insurDetailObj.Vehicle_Detail__r.Funded_Premium__c;
            insprodObj.proposalLtv = insurDetailObj.Proposal_LTV__c;
            insprodObj.bmi = insurDetailObj.Applicant__r.BMI__c;
            insprodObj.height = insurDetailObj.Applicant__r.Height__c;
            insprodObj.weight = insurDetailObj.Applicant__r.Weight__c;

            insProdLst.add(insprodObj);
        }
        return insProdLst;
    }

    /*
    * @Method:      isL1L2InsuranceSubmitted
    * @Created by:  Gaurav
    * @Description: method for getting insurance details
    * @Param:       String assetId
    * @Return:      Vehicle_Detail__c
    */
    @AuraEnabled
    public static Vehicle_Detail__c isL1L2InsuranceSubmitted(String assetId) {
        List<Vehicle_Detail__c> vehicleList = [Select Id,L1_Insurance_Submitted__c,L2_Insurance_Submitted__c from Vehicle_Detail__c Where Id=:assetId  WITH SECURITY_ENFORCED LIMIT 1];
        return vehicleList .size() > 0 ? vehicleList[0] : null;
    }


    /*
    * @Method:      getMotorInsurancePreimum
    * @Created by:  
    * @Description: method for getting motor insurance premium
    * @Param:       String Ins_Product, String Plan_Code
    * @Return:          String
    */
    @AuraEnabled
    public static String getMotorInsurancePreimum(String Ins_Product, String Plan_Code) {
        String getPremim;
        for (Insurance_Premium_details__c insuranceMster: [SELECT id, Ins_Product__c, Insurance_Plan_Code__c,
                                                           Premium__c, Disable_Funding__c, Sum_Insured__c
                                                           FROM Insurance_Premium_details__c
                                                           WHERE Insurance_Master__r.Name = 'Cholamandalam MS General Insurance Company Ltd.'
                                                           AND Ins_Product__c =: Ins_Product
                                                           AND Insurance_Plan_Code__c =: Plan_Code
                                                           WITH SECURITY_ENFORCED
                                                          ]) {
                                                              getPremim =insuranceMster.Premium__c!=null ? String.valueof(insuranceMster.Premium__c) :null;
                                                          }
        return getPremim;
    }
    
    /*
    * @Method:      callInuranceRecAPI
    * @Created by:  
    * @Description:  If there is no record returned from the Insurance details object for the current loan application 
    or if there is no consent received, call the API – API1(Insurance Recommendation API). 
    * @Param:       String loanapplicationId, String appType
    * @Return:          RequestWrapper
    */   
    @AuraEnabled
    public static RequestWrapper callInuranceRecAPI(String appType, String loanAppID) {  
        return callInuranceRecAPI(appType,loanAppID,'','');
    }

    //SFTRAC-176 Method Overloading
    @AuraEnabled
    public static RequestWrapper callInuranceRecAPI(String appType, String loanAppID, String assetId, String applicantId) {  
        List<Opportunity> oppRecLst = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanAppID WITH SECURITY_ENFORCED];

        RequestWrapper reqWrap = new RequestWrapper();
        //Application Object Data..
        Applicant__c app = fetchDataFromApplicatntObj(loanAppID, appType,applicantId);
        // reqWrap.applicationNo = app.DocAuth_Application_Id__c;
        
            reqWrap.Borrower_Type = app.Applicant_Type__c;
        System.debug('app.Id' + app.Id);
        //Query the document object to retrieve the age, DOB
        Documents__c doc = fetchAgeFromDocument(loanAppID, app.Id);
        Final_Term__c fnTerm =fetchAgreementFromFinalTerm(loanAppID, assetId);
        
        //Loan Application Data
        Opportunity loanapp = fetchDataFromLoanApplication(loanAppID);
            reqWrap.Vehicle_Category = loanapp.Vehicle_Type__c;
        reqWrap.Tenure = String.isNotBlank(fnTerm.Tenure__c) ? fnTerm.Tenure__c : null;
        reqWrap.applicationNo = loanapp.Application_number__c;
        
        if(doc != null){
            if(doc.Age__c!= null){
                reqWrap.age = String.valueof(doc.Age__c);
            }else if(doc.KYC_DOB__c != null){
                date dt =doc.KYC_DOB__c;
                date todayDate =date.today();
                Integer age = todayDate.year() - dt.year();
                if (todayDate.month() < dt.month() || (todayDate.month() == dt.month() && todayDate.day() < dt.day())) {
                    age--;
                }
                reqWrap.age = String.valueOf(age);

            }        
            reqWrap.gender = doc.Gender__c;
        }
        
        reqWrap.Agreement_Value = fnTerm.Agreement_Amount__c!=null ? String.valueof(fnTerm.Agreement_Amount__c) :'0';
        
        if(oppRecLst[0].Product_Type__c != System.Label.Tractor){
            if (loanapp.Insurance_expiring_within_90_days__c == true || loanapp.Is_customer_interested_in_a_motor_insura__c == true) {
                reqWrap.Motor_Premium =loanapp.Motor_Insurance_Premium__c!=null ? String.valueof(loanapp.Motor_Insurance_Premium__c):null;
            } else {
                reqWrap.Motor_Premium = '0';
            }
            reqWrap.Periodicity = '';//SFTRAC-629
        }
        
        // Vehicle Detail Object Data..
        Vehicle_Detail__c vedObj = fetchDataFromvehicleDetailsObj(loanAppID,assetId);
        if(oppRecLst[0].Product_Type__c == System.Label.Tractor){
            if (isExpiring90Days(vedObj.Ins_Expiry_date__c) == true || vedObj.Is_Customer_Interested_in_MotorInsurance__c == true) {
                reqWrap.Motor_Premium =vedObj.X1st_yr_Insurance_Premium__c!=null ? String.valueof(vedObj.X1st_yr_Insurance_Premium__c):'0';
            } else {
                reqWrap.Motor_Premium = '0';
            }
            reqWrap.Periodicity = String.isNotBlank(fnTerm.Installment_Frequency__c) && fnTerm.Installment_Frequency__c == 'Monthly' ? 'M' : fnTerm.Installment_Frequency__c == 'Quarterly' ? 'Q' : fnTerm.Installment_Frequency__c == 'Half yearly' ? 'H' : '';//SFTRAC-629
        }

            reqWrap.Product = vedObj.Product__c;
        //reqWrap.vehicleId = '4';
        reqWrap.Fin_Amount = fnTerm.Loan_Amount__c!=null ? String.valueof(fnTerm.Loan_Amount__c) : '';
        Decimal amount =0;
        decimal rtoRoadTax = 0;
        decimal basicPrice = vedObj.Loan_Application__r.Basic_Price__c != null?vedObj.Loan_Application__r.Basic_Price__c:0;
        decimal gst = vedObj.Loan_Application__r.GST_Amount__c != null? vedObj.Loan_Application__r.GST_Amount__c:0;
        decimal dealerDisc = vedObj.Loan_Application__r.Dealer_Disc_to_Customer__c != null ? Decimal.valueOf(vedObj.Loan_Application__r.Dealer_Disc_to_Customer__c):0;
        if(vedObj.Loan_Application__r.Product_Type__c == 'Two Wheeler' && vedObj.Loan_Application__r.Vehicle_Type__c == 'New'){
            rtoRoadTax = vedObj.Loan_Application__r.RTO_Road_Tax_New__c != null? vedObj.Loan_Application__r.RTO_Road_Tax_New__c:0;
        }else{
            rtoRoadTax = vedObj.Loan_Application__r.RTO_Road_Tax__c != null? vedObj.Loan_Application__r.RTO_Road_Tax__c:0;
        }
        decimal othercharges = vedObj.Loan_Application__r.Other_charges__c != null? vedObj.Loan_Application__r.Other_charges__c:0;
        decimal firstYrPrem = vedObj.Loan_Application__r.X1st_yr_Insurance_Premium__c != null? vedObj.Loan_Application__r.X1st_yr_Insurance_Premium__c:0;
        decimal requiredLoanAmt = vedObj.Loan_Application__r.Required_Loan_amount__c != null? vedObj.Loan_Application__r.Required_Loan_amount__c:0;
        decimal totalFundPrem = vedObj.Loan_Application__r.Total_Funded_Premium__c != null? vedObj.Loan_Application__r.Total_Funded_Premium__c:0;
        
        if(vedObj.Vehicle_type__c == 'New' && vedObj.Loan_Application__r.Funding_on_ORP__c){
            reqWrap.vehicleId = '1';
            //Basic Price + GST – Dealer Discount + RTO Road Tax + Other Charges + 1st year insurance premium
            amount = basicPrice+gst+rtoRoadTax+othercharges+firstYrPrem-dealerDisc-requiredLoanAmt;
        }else if(vedObj.Vehicle_type__c == 'New' && vedObj.Loan_Application__r.Funding_on_Ex_Showroom__c){
            reqWrap.vehicleId = '1';
            amount = basicPrice - requiredLoanAmt;
        }else if(vedObj.Vehicle_type__c != null && vedObj.Vehicle_type__c != 'New' ){           
            reqWrap.vehicleId = '4';
            amount = basicPrice - requiredLoanAmt;
        }else if( vedObj.Vehicle_type__c == 'New'){
            reqWrap.vehicleId = '1';
        }
        reqWrap.Balance_Available = string.valueOf(amount);
        reqWrap.Variant = vedObj.Variant__c;
        reqWrap.Motor_Expiry_Date =vedObj.Ins_Expiry_date__c!=null ? String.valueof(vedObj.Ins_Expiry_date__c):null;
        if(oppRecLst[0].Product_Type__c != System.Label.Tractor){
            reqWrap.expiringWithin60Days = vedObj.Insurance_expiring_within_60_days__c; //CFDI-1164
        }
        return reqWrap;
    }

    //SFTRAC-176 : Chaynnitt Agarwal
    private static Boolean isExpiring90Days(Date expiryDate){
        Boolean isExpiring = false;
        if(expiryDate == null){
            return isExpiring;
        }
        Date startDate = System.today();
        Date dueDate = expiryDate;
        Integer numberDaysDue = startDate.daysBetween(dueDate);
        if(numberDaysDue <=90 ){
            isExpiring = true;
        }
        return isExpiring;
    }
    
    @AuraEnabled(Cacheable = true)
    public static Opportunity getmotorfromopp(String opportunityId) {
        try {
            if (opportunityId != null) {
                Opportunity appObj = [SELECT Id,Funded__c,Motor_Insurance_Premium__c FROM Opportunity WHERE Id =: opportunityId WITH SECURITY_ENFORCED limit 1];
                return appObj;
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    /*
    * @Method:      getApplicantId
    * @Created by:  
    * @Description: method for getting applicant id 
    * @Param:       String loanapplicationId, String appType
    * @Return:          String
    */
    @AuraEnabled(Cacheable = true)
    public static string getApplicantId(String opportunityId, String applicantType) {
        try {
            if (opportunityId != null && applicantType != null) {
                Applicant__c appObj = [SELECT Id FROM Applicant__c WHERE Opportunity__c =: opportunityId AND Applicant_Type__c =: applicantType AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED limit 1];
                return appObj.id;
            }
            return null;
        } catch (Exception e) {
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(' IND_InsuranceDetailsWrapper ', ' getApplicantId ', 'System.Label.Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    /*
    * @Method:      getBorrowerDocument
    * @Created by:  
    * @Description: method for getting Document Detail of borrower 
    * @Param:       String loanapplicationId
    * @Return:          Documents__c
    */
    @AuraEnabled(Cacheable = true)
    public static Documents__c getBorrowerDocument(String opportunityId) {
        try {
            if (opportunityId != null) {
                Documents__c appObj = [SELECT id,KYC_DOB__c  FROM Documents__c WHERE Opportunity_Relation__c =:opportunityId AND applicant_Type__c = 'Borrower' AND Proof_of_Identity_POI__c = true limit 1];
                return appObj;
            }
            return null;
        } catch (Exception e) {
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(' IND_InsuranceDetailsWrapper ', ' getBorrowerDocument ', 'System.Label.Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    /*
    * @Method:      sendInsuranceConsent
    * @Created by:  
    * @Description: method for sending insurance consent 
    * @Param:       String loanapplicationId, String appType
    * @Return:          String
    */ 
    @AuraEnabled(Cacheable = true)
    public static String sendInsuranceConsent(String loanapplicationId, String appType) {
        Applicant__c appObj = [SELECT Id FROM Applicant__c WHERE Opportunity__c =: loanapplicationId AND Applicant_Type__c =: appType AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED LIMIT 1];
        return appObj.id;
    }
    
    /*
    * @Method:      getInsuranceDetailsFromMaster
    * @Created by:  
    * @Description: .If response from API1 is not received even after configured number of tries then system should
    fetch insurance products and plans from the insurance master. 
    * @Param:       None
    * @Return:          List < Ins_Product >
    */
    @AuraEnabled
    public static List < Ins_Product > getInsuranceDetailsFromMaster(String recordId) {
        try {
            List < Ins_Product > insProductWrapperLst = new List < Ins_Product > ();
            String prod;
            
            Opportunity opp =[SELECT Id, Product_Type__c FROM Opportunity WHERE Id=:recordId ];
            if(opp.Product_Type__c==System.Label.TwoWheeler){
                prod = 'H';
            }else if(opp.Product_Type__c==System.Label.PassengerVehicles){
                prod = 'C'; 
            }
            
            for (Insurance_Premium_details__c insuranceMster: [SELECT id, Ins_Product__c, Insurance_Plan_Code__c,
                                                               Premium__c, Disable_Funding__c, Sum_Insured__c
                                                               FROM Insurance_Premium_details__c
                                                               WHERE Insurance_Master__r.Name = 'Cholamandalam MS General Insurance Company Ltd.'
                                                               AND Loan_Product__c =: prod AND Active_Flag__c = 'Y'
                                                               WITH SECURITY_ENFORCED
                                                              ])  {
                                                                  Ins_Product insuranceMsterObj = new Ins_Product();
                                                                  insuranceMsterObj.Ins_Product = insuranceMster.Ins_Product__c;
                                                                  insuranceMsterObj.Plan_Code = insuranceMster.Insurance_Plan_Code__c;
                                                                  insuranceMsterObj.Plan_Name = insuranceMster.Insurance_Plan_Code__c;
                                                                  insuranceMsterObj.Sum_Insured = '';
                                                                  insuranceMsterObj.Premium = insuranceMster.Premium__c!=null ? String.valueof(insuranceMster.Premium__c) :null;
                                                                  insuranceMsterObj.LHC = insuranceMster.Ins_Product__c;
                                                                  insuranceMsterObj.Plan_Recommend = 'Y';
                                                                  insuranceMsterObj.Disable_Funding = insuranceMster.Disable_Funding__c;
                                                                  insuranceMsterObj.Funding_Option = insuranceMster.Disable_Funding__c;
                                                                  InsProductWrapperLst.add(insuranceMsterObj);
                                                              }
            return InsProductWrapperLst;
        } catch (Exception e) {
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(' IND_InsuranceDetailsWrapper ', ' IND_loadInsuranceDetails ', 'System.Label.Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    /*
    * @Method:      getMotorInsuranceFromLoanDetailsTf
    * @Created by:  Gaurav Rawat
    * @Description: If there is no response for API1, and if in Loan details 'is Customer requested in Motor insurance ' 
    option was selected for Motor insurance product, call the method getMotorInsuranceFromLoanDetailsTf.
    If the above option is not selected, motor insurance will be disabled.
    Return a boolean flag for the same and freeze the motor insurance section
    * @Param:       String loanAppID, vehicleId
    * @Return:         true or false
    */
    @AuraEnabled
    public static Ins_Product getMotorInsuranceFromLoanDetailsTf(String loanAppID, String vehicleId) {
        List<Vehicle_Detail__c> vehicleObj = new List<Vehicle_Detail__c>([SELECT id, Is_Customer_Interested_in_MotorInsurance__c,X1st_yr_Insurance_Premium__c,Funded__c FROM Vehicle_Detail__c WHERE Loan_Application__c =: loanAppID AND id =: vehicleId WITH SECURITY_ENFORCED LIMIT 1]);

        if (vehicleObj.size() > 0 && vehicleObj[0].Is_Customer_Interested_in_MotorInsurance__c == true) {
            Ins_Product getmtrloanDet = new Ins_Product();
            getmtrloanDet.Ins_Product = 'MOTOR';
            getmtrloanDet.Plan_Code = 'MOTOR';
            getmtrloanDet.Plan_Name = 'MOTOR';
            getmtrloanDet.Sum_Insured = '';
            getmtrloanDet.LHC = '';
            getmtrloanDet.Plan_Recommend = 'Y';
            getmtrloanDet.Disable_Funding = '';
            getmtrloanDet.Premium = vehicleObj[0].X1st_yr_Insurance_Premium__c != null ? String.valueof(vehicleObj[0].X1st_yr_Insurance_Premium__c) :null;

            getmtrloanDet.Funding_Option = vehicleObj[0].Funded__c == true ? 'Y' : 'N';
            return getmtrloanDet;
        } else {
            return null;
        }
    }
    
    /*
    * @Method:      isCustomerrequestedinMotorinsurance
    * @Created by:  
    * @Description: If there is no response for API1, and if in Loan details 'is Customer requested in Motor insurance ' 
    option was selected for Motor insurance product, call the method getMotorInsuranceFromLoanDetails.
    If the above option is not selected, motor insurance will be disabled.
    Return a boolean flag for the same and freeze the motor insurance section
    * @Param:       String loanAppID
    * @Return:         true or false
    */
    @AuraEnabled
    public static Boolean isCustomerrequestedinMotorinsurance(String loanappID) {
        
        Boolean iscureMtrInsuBln = false;
        for (Opportunity opp: [SELECT id, Is_customer_interested_in_a_motor_insura__c FROM Opportunity WHERE id =: loanappID WITH SECURITY_ENFORCED LIMIT 1]) {
            iscureMtrInsuBln = opp.Is_customer_interested_in_a_motor_insura__c;
        }
        return iscureMtrInsuBln;
    }
    
    /*
    * @Method:      getMotorInsuranceFromLoanDetails
    * @Created by:  
    * @Description:    getMotorInsuranceFromLoanDetails
    a.  Query for below 2 fields from the Loan Details section of the loan application
    i. Premium Amount
    ii.    Funded/NonFunded
    * @Param:      String loanAppID
    * @Return:      Ins_Product
    */
    @AuraEnabled
    public static Ins_Product getMotorInsuranceFromLoanDetails(String loanAppID) {
        
        if (isCustomerrequestedinMotorinsurance(loanappID)) {
            opportunity loanobj = fetchDataFromLoanApplication(loanAppID);
            Ins_Product getmtrloanDet = new Ins_Product();
            getmtrloanDet.Ins_Product = 'MOTOR';
            getmtrloanDet.Plan_Code = 'MOTOR';
            getmtrloanDet.Plan_Name = 'MOTOR';
            getmtrloanDet.Sum_Insured = '';
            getmtrloanDet.LHC = '';
            getmtrloanDet.Plan_Recommend = 'Y';
            getmtrloanDet.Disable_Funding = '';
            
            if(loanobj.Vehicle_Type__c == System.Label.new){
                getmtrloanDet.Premium = loanobj.X1st_yr_Insurance_Premium__c!=null ? String.valueof(loanobj.X1st_yr_Insurance_Premium__c) :null;
            } else {
                getmtrloanDet.Premium = loanobj.Motor_Insurance_Premium__c!=null ? String.valueof(loanobj.Motor_Insurance_Premium__c) :null;
            }
            getmtrloanDet.Funding_Option = loanobj.Funded__c == true ? 'Y' : 'N';
            return getmtrloanDet;
        } else {
            return null;
        }
    }
    
    //Wrapper class for Insurance Premium API response.
    //public for attributes added by Hemanth Thikka
    public class InsurancePremiumAPIResponseWrapper {
        public String applicationNo {get;set;}
        public String vehicleID {get;set;}
        public Decimal premium {get;set;}
        public Decimal lhc {get;set;}
        public String statusFlag {get;set;}
        public Integer errorCode {get;set;}
        public String errorDescription {get;set;}
    }
    
    /*
    * @Method:      submitInsuranceDetails
    * @Created by:  Khushiram
    * @Description: This method will save the details captured on UI in application and applicant object.
    * @Param:       String - json object containing all the details captured on UI.
    * @Return:         None
    */
    @AuraEnabled
    public static String submitInsuranceDetails(String payload) {
        try {
            if (payload != null) {
                //perform the saving of data  here.
                SubmitInsuranceRequestWrapper payloadObject = (SubmitInsuranceRequestWrapper) JSON.deserialize(payload, SubmitInsuranceRequestWrapper.class);
                System.debug('line 495' +payloadObject);
                
                
                List<Applicant__c> listOfApplicant = [Select Id, Applicant_Type__c, Insurance_Consent_Received__c From Applicant__c where Opportunity__c =: payloadObject.loanApplicationId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED];
                Opportunity opp = [SELECT Id,Product_Type__c From Opportunity WHERE id =: payloadObject.loanApplicationId WITH SECURITY_ENFORCED];
                //To check whether the consent for coborrower is received or not.
                /* if(listOfApplicant.size() > 1){
                for(Applicant__c applicant : listOfApplicant){
                if(applicant.Applicant_Type__c == System.label.CoBorrower && applicant.Insurance_Consent_Received__c == false){
                return system.Label.CoborrowerConsentNotReceived;                     
                }
                }
                }*/
                List <InsuranceDetails__c> listToInsert = new List<InsuranceDetails__c>();
                //update.
                
                List<InsuranceDetails__c> insurancePresentDetails = [SELECT Id, Name FROM InsuranceDetails__c where Applicant__c=: payloadObject.applicantId WITH SECURITY_ENFORCED];
                
                // Loop through the list and update the Name field
                Set<String> idsTobeDeleted  = new Set<String>();
                Set<String> selectProductName = new Set<String>();
                if (payloadObject.insProductDetails != null && payloadObject.insProductDetails.size() > 0) {
                    for (InsuranceWrapper insProdObj : payloadObject.insProductDetails) {
                        selectProductName.add(insProdObj.selectedProduct);
                        InsuranceDetails__c insObj = new InsuranceDetails__c();
                        insObj.Name = insProdObj.selectedProduct;
                        insObj.Insurance_Plan__c = insProdObj.selectedPlan;
                        if (insProdObj.isFunded != null && insProdObj.isFunded) {
                            insObj.Funded_Non_funded__c = System.Label.Funded;
                        } else {
                            insObj.Funded_Non_funded__c = System.Label.NonFunded;
                        }
                        insObj.Amount__c = insProdObj.premium;
                        insObj.Applicant__c = payloadObject.applicantId;
                        insObj.Loan_Application__c = payloadObject.loanApplicationId;
                        insObj.Product_Type__c = opp.Product_Type__c;
                        insObj.Funded_Premium__c = payloadObject.premiumFunded;
                        if (insProdObj.selectedProduct == 'LI_EMI' || insProdObj.selectedProduct =='TATA_EMI') {
                            insObj.Combo_LI_Premium__c = insProdObj.comboLIPremium;
                            insObj.Combo_EMI_Premium__c = insProdObj.comboEMIPremium;
                            insObj.EMI_Passed_in_API__c = insProdObj.eMIPassedinAPI;
                        }
                        listToInsert.add(insObj);
                    }
                }                
                if (payloadObject.insProductDetails != null && payloadObject.insProductDetails.size() > 0 && selectProductName != null) {
                    for(InsuranceDetails__c ins : insurancePresentDetails){
                        idsTobeDeleted.add(ins.Id);
                    }
                }        
                if (idsTobeDeleted != null && Schema.sObjectType.InsuranceDetails__c.isDeletable()) {
                    for(String loanAppId : idsTobeDeleted){
                        InsuranceDetails__c insDetail = [SELECT Id, Name FROM InsuranceDetails__c where Id=: loanAppId WITH SECURITY_ENFORCED];
                        delete insDetail;
                    }
                }
                
                Applicant__c appObj = [Select id,LTV_with_Insurance__c,LTV_without_insurance__c,Total_Insurance_Payable__c,Proposal_LTV__c from Applicant__c where id =: payloadObject.applicantId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED];
                appObj.LTV_with_Insurance__c = payloadObject.ltvWithInsurance!= null ? Integer.ValueOf(payloadObject.ltvWithInsurance):0;
                appObj.LTV_without_insurance__c =payloadObject.ltvWithoutInsurance!=null ? Integer.ValueOf(payloadObject.ltvWithoutInsurance):0;
                appObj.Total_Insurance_Payable__c = payloadObject.totalInsurancePayable;
                appObj.Proposal_LTV__c = payloadObject.proposalLtv;
                if(payloadObject.height != null && payloadObject.weight != null && payloadObject.bmi != null){
                    appObj.Height__c = payloadObject.height;
                    appObj.Weight__c = payloadObject.weight;
                    appObj.BMI__c = payloadObject.bmi;
                }
                //Creating the records for selected insurance product           
                if (Schema.sObjectType.InsuranceDetails__c.isCreateable()) {
                    insert listToInsert;
                }
                //Updating the Applicant Object
                if (Schema.sObjectType.Applicant__c.isUpdateable()) {
                    update appObj;
                }
                Opportunity opportunityObj = [Select id,StageName,LastStageName__c,Submitted_Tabs__c from Opportunity where id =: payloadObject.loanApplicationId WITH SECURITY_ENFORCED];
                if(opportunityObj.StageName != System.Label.Credit_Processing){
                    opportunityObj.StageName = payloadObject.nextStage;
                    opportunityObj.LastStageName__c = payloadObject.nextStage; // CISP-2530 last stage also update
                    if(String.isNotBlank(payloadObject.submittedTabs)){
                        opportunityObj.Submitted_Tabs__c = payloadObject.submittedTabs;
                    }

                    
                    if (Schema.sObjectType.Opportunity.isUpdateable()) {
                        update opportunityObj;
                    }
                }
                
                return System.Label.Success;
            }
            
            return System.Label.Failure;
        } catch (Exception e) {
            System.debug(e.getCause() + '' + e.getLineNumber() + '' + e.getMessage());
            ErrorLoggerUtil.logErrorEvent('IND_InsuranceDetailsLWC_controller', ' submitInsuranceDetails ', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }  
        
    }

    /*
    * @Method:      fetchApplicants
    * @Created by: Gaurav Rawat
    * @Description: This method will return the applicantlist
    * @Param:       loanApplicationId
    */

    @AuraEnabled
    public static List<Applicant__c> fetchApplicants(String loanApplicationId) {
        Opportunity  opty = [SELECT Id,Product_Type__c,Customer_Type__c,Entity_Type__c FROM Opportunity WHERE Id =:loanApplicationId];
        if(opty != null && opty.Product_Type__c == Label.Tractor && opty.Customer_Type__c == 'Non-Individual' && opty.Entity_Type__c == 'Proprietorship'){
            return [select id from Applicant__c where Opportunity__r.Id = :loanApplicationId and In_Active_Applicant__c =false AND ((Applicant_Type__c = 'Borrower') OR (Applicant_Type__c = 'Beneficiary' AND IsPrimary__c = true)) AND Application_Consent_Received__c = false];
        }else if(opty != null && opty.Product_Type__c == Label.Tractor && opty.Customer_Type__c == 'Non-Individual'){
            return [select id from Applicant__c where Opportunity__r.Id = :loanApplicationId and In_Active_Applicant__c =false AND Applicant_Type__c = 'Beneficiary' AND IsPrimary__c = true AND Application_Consent_Received__c = false];
        }
        return [Select Id From Applicant__c WHERE Opportunity__c =: loanApplicationId AND In_Active_Applicant__c = false AND Application_Consent_Received__c = false WITH SECURITY_ENFORCED LIMIT 100];
    }
    //SFTRAC-1076 - START - fetchInsurance
    @AuraEnabled
    public static List<InsuranceDetails__c> fetchInsurance(String loanApplicationId) {
        return [SELECT id, Applicant__c FROM InsuranceDetails__c WHERE Loan_Application__c =: loanApplicationId];
    }
    //SFTRAC-1076 - END - fetchInsurance

    /*
    * @Method:      finalSubmitTFInsuranceDetails
    * @Created by: Gaurav Rawat
    * @Description: This method will save the Insurance details captured in L1 Journey.
    * @Param:       String - json object containing all the details captured on UI.
    * @Return:         None
    */
    @AuraEnabled
    public static String finalSubmitTFInsuranceDetails(String payload) {
        try {
            if (payload != null) {
                //perform the saving of data  here.
                SubmitInsuranceRequestWrapper payloadObject = (SubmitInsuranceRequestWrapper) JSON.deserialize(payload, SubmitInsuranceRequestWrapper.class);
                System.debug('line 495' +payloadObject);
            
                Opportunity opp = [SELECT Id,Product_Type__c FROM Opportunity WHERE id =: payloadObject.loanApplicationId WITH SECURITY_ENFORCED];

                Vehicle_Detail__c vehicleObj = new Vehicle_Detail__c();
                vehicleObj.Id = payloadObject.assetId;
                if(payloadObject.journeyOfLead == 'L1'){
                    vehicleObj.L1_Insurance_Submitted__c = true;
                }else if(payloadObject.journeyOfLead == 'L2'){
                    vehicleObj.L2_Insurance_Submitted__c = true;
                    vehicleObj.L1_InsuranceChanged__c = false;
                }
                update vehicleObj;
                    
                List<Vehicle_Detail__c> vehiclelist = new List<Vehicle_Detail__c>();
                if(payloadObject != null && payloadObject.journeyOfLead == 'L1'){
                    vehiclelist = new List<Vehicle_Detail__c>([Select Id from Vehicle_Detail__c WHERE L1_Insurance_Submitted__c = false AND Loan_Application__c =: payloadObject.loanApplicationId ]);
                }else if(payloadObject != null && payloadObject.journeyOfLead == 'L2'){
                    vehiclelist = new List<Vehicle_Detail__c>([Select Id from Vehicle_Detail__c WHERE L2_Insurance_Submitted__c = false AND Loan_Application__c =: payloadObject.loanApplicationId ]);
                }
                
                if(vehiclelist.size() == 0){
                    Opportunity opportunityObj = [SELECT Id,StageName,LastStageName__c,Submitted_Tabs__c FROM Opportunity WHERE id =: payloadObject.loanApplicationId WITH SECURITY_ENFORCED];
                    if(opportunityObj.StageName != System.Label.Credit_Processing){
                        opportunityObj.StageName = 'Final Offer';
                        opportunityObj.LastStageName__c = 'Final Offer';
                        update opportunityObj;
                        return 'Final Submit';
                    }else if(opportunityObj.StageName == System.Label.Credit_Processing){
                        opportunityObj.Sub_Stage__c = 'Risk Summary';                        
                        update opportunityObj;
                        return System.Label.Success;
                    }
                }else{
                    return 'Submitted';
                }
            }
            return System.Label.Failure;
        } catch (Exception e) {
            System.debug(e.getCause() + '' + e.getLineNumber() + '' + e.getMessage()+ '' +e.getStackTraceString());
            ErrorLoggerUtil.logErrorEvent('IND_InsuranceDetailsLWC_controller', ' finalSubmitTFInsuranceDetails ', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }   
    }
    @AuraEnabled
    public static String submitTFInsuranceDetails(String payload) {
        try {
            if (payload != null) {
                //perform the saving of data  here.
                SubmitInsuranceRequestWrapper payloadObject = (SubmitInsuranceRequestWrapper) JSON.deserialize(payload, SubmitInsuranceRequestWrapper.class);
                System.debug('line 495' +payloadObject);
            
                Opportunity opp = [SELECT Id,Product_Type__c FROM Opportunity WHERE id =: payloadObject.loanApplicationId WITH SECURITY_ENFORCED];
                
                List <InsuranceDetails__c> listToInsert = new List<InsuranceDetails__c>();
                
                List<InsuranceDetails__c> insurancePresentDetails = [SELECT Id, Name FROM InsuranceDetails__c WHERE Applicant__c=: payloadObject.applicantId AND Vehicle_Detail__c =: payloadObject.assetId WITH SECURITY_ENFORCED];
                Set<String> idsTobeDeleted  = new Set<String>();

                Set<String> selectProductName = new Set<String>();

                double totalFundedAmount = 0;
                if (payloadObject.insProductDetails != null && payloadObject.insProductDetails.size() > 0) {
                    for (InsuranceWrapper insProdObj : payloadObject.insProductDetails) {
                        selectProductName.add(insProdObj.selectedProduct);
                        InsuranceDetails__c insObj = new InsuranceDetails__c();
                        insObj.Name = insProdObj.selectedProduct;
                        insObj.Insurance_Plan__c = insProdObj.selectedPlan;
                        if (insProdObj.isFunded != null && insProdObj.isFunded) {
                            insObj.Funded_Non_funded__c = System.Label.Funded;
                            totalFundedAmount += insProdObj.premium;
                        } else {
                            insObj.Funded_Non_funded__c = System.Label.NonFunded;
                        }
                        insObj.Amount__c = insProdObj.premium;
                        insObj.Applicant__c = payloadObject.applicantId;
                        insObj.Loan_Application__c = payloadObject.loanApplicationId;
                        insObj.Vehicle_Detail__c = payloadObject.assetId;
                        insObj.Product_Type__c = opp.Product_Type__c;
                        if (insProdObj.selectedProduct == 'LI_EMI' || insProdObj.selectedProduct =='TATA_EMI' || insprodObj.selectedProduct == 'COMBO'|| insprodObj.selectedProduct == 'LI_SHUBH' || insprodObj.selectedProduct == 'LI' || insprodObj.selectedProduct == 'HEALTH') {
                            insObj.Combo_LI_Premium__c = insProdObj.comboLIPremium;
                            insObj.Combo_EMI_Premium__c = insProdObj.comboEMIPremium;
                            if(insProdObj.selectedProduct == 'LI_EMI' || insProdObj.selectedPlan == 'LI_EMI'){
                                insObj.EMI_Passed_in_API__c = insProdObj.eMIPassedinAPI;
                            }
                        }
                        listToInsert.add(insObj);
                        }
                    }
                    if (payloadObject.insProductDetails != null && payloadObject.insProductDetails.size() > 0 && selectProductName != null) {
                        for(InsuranceDetails__c ins : insurancePresentDetails){
                            idsTobeDeleted.add(ins.Id);
                        }
                    }        
                    if (idsTobeDeleted != null && Schema.sObjectType.InsuranceDetails__c.isDeletable()) {
                        List<InsuranceDetails__c> insDetail = new List<InsuranceDetails__c>([SELECT Id, Name FROM InsuranceDetails__c WHERE Id IN : idsTobeDeleted WITH SECURITY_ENFORCED]);
                        delete insDetail;
                    }
                
                //Creating the records for selected insurance product           
                if (Schema.sObjectType.InsuranceDetails__c.isCreateable()) {
                    insert listToInsert;
                }
                if(payloadObject.height != null && payloadObject.weight != null && payloadObject.bmi != null){
                    Applicant__c appObj = new Applicant__c();
                    appObj.Id = payloadObject.applicantId;
                    appObj.Height__c = payloadObject.height;
                    appObj.Weight__c = payloadObject.weight;
                    appObj.BMI__c = payloadObject.bmi;
                    update appObj;
                }

                Opportunity opportunityObj = [SELECT Id,StageName,LastStageName__c,Submitted_Tabs__c FROM Opportunity WHERE id =: payloadObject.loanApplicationId WITH SECURITY_ENFORCED];
                if(opportunityObj.StageName != System.Label.Credit_Processing){
                    if(String.isNotBlank(payloadObject.submittedTabs)){
                        opportunityObj.Submitted_Tabs__c = payloadObject.submittedTabs;
                    }
                    
                    if (Schema.sObjectType.Opportunity.isUpdateable()) {
                        update opportunityObj;
                    }
                }

                Vehicle_Detail__c vehicleObj = new Vehicle_Detail__c();
                vehicleObj.Id = payloadObject.assetId;
                vehicleObj.Total_Funded_Amount__c = totalFundedAmount;
                vehicleObj.LTV_Without_Insurance__c = payloadObject.ltvWithoutInsurance;
                vehicleObj.LTV_With_Insurance__c = payloadObject.ltvWithInsurance;
                vehicleObj.Total_Insurance_Payable__c = payloadObject.totalInsurancePayable;
                vehicleObj.Funded_Premium__c = payloadObject.premiumFunded;
                if(payloadObject.isCalledFromL2 == true){
                    vehicleObj.L1_InsuranceChanged__c = true; 
                }
                update vehicleObj;

                return System.Label.Success;              
                
            }
            
            return System.Label.Failure;
        } catch (Exception e) {
            System.debug(e.getCause() + '' + e.getLineNumber() + '' + e.getMessage()+ '' +e.getStackTraceString());
            ErrorLoggerUtil.logErrorEvent('IND_InsuranceDetailsLWC_controller', ' submitTFInsuranceDetails ', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }   
    }

    @AuraEnabled
    public static Boolean isL1InsuranceChanged(String vehicleId) {
        Vehicle_Detail__c vehicleObj = [Select Id,L1_InsuranceChanged__c from Vehicle_Detail__c WHERE Id =: vehicleId LIMIT 1];
        return vehicleObj.L1_InsuranceChanged__c;
    }
    
    //Wrapper class for SubmitInsuranceDetails
    public class SubmitInsuranceRequestWrapper {
        @AuraEnabled public String applicantId {get;set;}
        @AuraEnabled public String loanApplicationId {get;set;}
        @AuraEnabled public Decimal ltvWithInsurance {get;set;}
        @AuraEnabled public Decimal ltvWithoutInsurance {get;set;}
        @AuraEnabled public Decimal totalInsurancePayable {get;set;}
        @AuraEnabled public Decimal proposalLtv {get;set;}
        @AuraEnabled public List<InsuranceWrapper> insProductDetails {get;set;}
        @AuraEnabled public String nextStage{get;set;}
        @AuraEnabled public Double premiumFunded{get;set;}
        @AuraEnabled public String submittedTabs{get;set;}
        @AuraEnabled public Decimal height{get;set;}
        @AuraEnabled public Decimal weight{get;set;}
        @AuraEnabled public Decimal bmi{get;set;}
        @AuraEnabled public String assetId{get;set;}
        @AuraEnabled public String journeyOfLead{get;set;}
        @AuraEnabled public Boolean isCalledFromL2 {get;set;}
    }
    
    /*
    * @Method:      getFundingAvailibility
    * @Created by:  Khushiram
    * @Description: This function will perform the calculation and return the response back to LWC
    * @Param:       String - json object containing all the selected products along with application id.
    * @Return:      Json Object containing all the required details.
    */
    @AuraEnabled
    public static String getFundingAvailibility(String payload) {
        try {
            if (payload != null) {
                //Variable to store the total premium funding for all the selected product's plans
                Decimal premiumFunding = 0;
                //Variable to store the funding available
                Decimal fundingAvailable = 0;
                //Variable to store the total insurance payable
                Decimal totalInsurancePayable = 0;
                
                GetFundingAvailabiltyResponseWrapper responseJSON = new GetFundingAvailabiltyResponseWrapper();
                
                GetFundingAvailabiltyRequestWrapper payloadObject = (GetFundingAvailabiltyRequestWrapper) JSON.deserialize(payload, GetFundingAvailabiltyRequestWrapper.class);
                Opportunity oppObject = [select isTopUpLoan__c, Loan_amount__c, Ex_showroom_price__c, On_Road_price__c, LeadSource, Required_Loan_amount__c, Vehicle_Type__c, Vehicle_Sub_Category__c, Funding_on_Ex_Showroom__c, Funding_on_ORP__c,Product_Type__c from Opportunity where id =: payloadObject.loanApplicationId WITH SECURITY_ENFORCED];//D2C Change added LeadSource
                
                Vehicle_Detail__c vehicleDetailObject = new Vehicle_Detail__c();
                
                if(oppObject.Product_Type__c == System.Label.Tractor){
                    vehicleDetailObject = [SELECT Base_Prices__c,Eligible_Loan_Amount__c,Grid_value__c,Valuation_price__c,Insurance_declared_value__c, Invoice_Price__c, Selling_Price__c, Variant_Code__c
                                            FROM Vehicle_Detail__c 
                                            WHERE Loan_Application__c =: payloadObject.loanApplicationId AND Id =: payloadObject.assetId
                                            WITH SECURITY_ENFORCED 
                                            LIMIT 1];
                }else{
                    vehicleDetailObject = [SELECT Base_Prices__c,Eligible_Loan_Amount__c,Grid_value__c,Valuation_price__c,Insurance_declared_value__c 
                                            FROM Vehicle_Detail__c 
                                            WHERE Loan_Application__c =: payloadObject.loanApplicationId
                                            WITH SECURITY_ENFORCED 
                                            LIMIT 1];
                }

                List<Exposure__c> expoList = [SELECT Id,SOH__c,Type__c  from Exposure__c where Loan_Application__c =:payloadObject.loanApplicationId and Type__c = 'Borrower Exposure' limit 1];

                Final_Term__c finaltermobj = new Final_Term__c();
                if(oppObject.Product_Type__c == System.Label.Tractor){
                    finaltermobj = [SELECT Loan_Amount__c,Vehicle_Detail__r.Grid_value__c,Vehicle_Detail__r.Valuation_price__c,Vehicle_Detail__r.Insurance_declared_value__c
                                        FROM Final_Term__c 
                                        WHERE Loan_Application__c=:payloadObject.loanApplicationId AND Vehicle_Detail__c =:payloadObject.assetId
                                        WITH SECURITY_ENFORCED 
                                        LIMIT 1];
                }else{
                    finaltermobj = [SELECT Loan_Amount__c,Vehicle_Detail__r.Grid_value__c,Vehicle_Detail__r.Valuation_price__c,Vehicle_Detail__r.Insurance_declared_value__c
                                        FROM Final_Term__c 
                                        WHERE Loan_Application__c=:payloadObject.loanApplicationId
                                        WITH SECURITY_ENFORCED 
                                        LIMIT 1];
                }

                for (InsuranceWrapper insProdObj : payloadObject.insProductDetails) {
                    totalInsurancePayable += insProdObj?.premium;
                    if (insProdObj.isFunded) {
                        premiumFunding += insProdObj.premium;
                    }
                }
                Decimal loanAmount = finaltermobj != null ? Decimal.valueOf(finaltermobj.Loan_Amount__c) : oppObject.Required_Loan_amount__c;
                if (oppObject.Vehicle_Type__c == system.Label.new && oppObject.Funding_on_Ex_Showroom__c) {
                    fundingAvailable = oppObject.Ex_showroom_price__c - (loanAmount + premiumFunding);
                } else if (oppObject.Vehicle_Type__c == system.Label.new && oppObject.Funding_on_ORP__c) {
                    fundingAvailable = oppObject.On_Road_price__c - (loanAmount + premiumFunding);
                } else if ((oppObject.Vehicle_Type__c == System.Label.used || oppObject.Vehicle_Type__c == System.Label.externalRefinance || oppObject.Vehicle_Type__c == System.Label.InternalRefinance || oppObject.Vehicle_Type__c == System.Label.Refinance) && oppObject.Vehicle_Sub_Category__c != System.Label.UIM) {
                    fundingAvailable = vehicleDetailObject.Base_Prices__c - (loanAmount + premiumFunding);
                } else if ((oppObject.Vehicle_Type__c == System.Label.used || oppObject.Vehicle_Type__c == System.Label.externalRefinance || oppObject.Vehicle_Type__c == System.Label.InternalRefinance || oppObject.Vehicle_Type__c == System.Label.Refinance) && oppObject.Vehicle_Sub_Category__c == System.Label.UIM) {
                    fundingAvailable = vehicleDetailObject.Eligible_Loan_Amount__c - (loanAmount + premiumFunding);
                }
                
                if (fundingAvailable >= 0) {                    
                    if(oppObject.Product_Type__c == 'Tractor'){
                        Double loanAmountValue = finaltermobj.Loan_amount__c != '' ? Double.valueOf(finaltermobj.Loan_Amount__c) : 0;

                        if(oppObject.isTopUpLoan__c){
                            Double sohValue = expoList.size() > 0 && expoList[0]?.SOH__c != null ? expoList[0].SOH__c : 0;
                            Double rsvValue = vehicleDetailObject.Grid_value__c != null ? vehicleDetailObject.Grid_value__c : 0;
                            Double idvValue = vehicleDetailObject.Insurance_declared_value__c != null ? vehicleDetailObject.Insurance_declared_value__c : 0;
                            Double valuationAmount = vehicleDetailObject.Valuation_price__c != null ? vehicleDetailObject.Valuation_price__c : 0;
                            Double minValue = 0;

                            List<Double> doubleList = new List<Double>();
                            if(rsvValue != 0){
                                doubleList.add(rsvValue);
                            } 
                            if(idvValue != 0){
                                doubleList.add(idvValue);
                            }
                            if(valuationAmount != 0){
                                doubleList.add(valuationAmount);
                            }
                            minValue = IND_CAMWithoutSharing.getMinimumValue(doubleList);
                            if(minValue != null && minValue != 0){
                                responseJSON.ltvWithInsurance = String.valueOf(((sohValue+loanAmountValue+premiumFunding)/minValue).setScale(2)*100);
                                Decimal result = (sohValue+loanAmountValue)/(minValue);
                                responseJSON.ltvWithoutInsurance = String.valueOf((result).setScale(2)*100);
                            }
                        } else if(oppObject.Vehicle_Type__c != System.Label.new){
                            Decimal minimumValue = 0;
                            if(vehicleDetailObject?.Grid_value__c == null){vehicleDetailObject.Grid_value__c = 0;}
                            if(vehicleDetailObject?.Valuation_price__c == null){vehicleDetailObject.Valuation_price__c = 0;}
                            if(vehicleDetailObject?.Insurance_declared_value__c == null){vehicleDetailObject.Insurance_declared_value__c = 0;}
                            
                            List<Double> doubleList = new List<Double>();
                            if(finalTermObj.Vehicle_Detail__r.Grid_value__c != 0){
                                doubleList.add(finalTermObj.Vehicle_Detail__r.Grid_value__c);
                            } 
                            if(finalTermObj.Vehicle_Detail__r.Valuation_price__c != 0){
                                doubleList.add(finalTermObj.Vehicle_Detail__r.Valuation_price__c);
                            }
                            if(finalTermObj.Vehicle_Detail__r.Insurance_declared_value__c != 0){
                                doubleList.add(finalTermObj.Vehicle_Detail__r.Insurance_declared_value__c);
                            }
                            minimumValue = IND_CAMWithoutSharing.getMinimumValue(doubleList);
                            if(minimumValue != null && minimumValue != 0){
                                responseJSON.ltvWithInsurance = ((loanAmountValue + premiumFunding) / minimumValue).setScale(2)!=null ? String.valueOf(((loanAmountValue + premiumFunding) / minimumValue).setScale(2)*100):null;
                                responseJSON.ltvWithoutInsurance =(loanAmountValue / minimumValue).setScale(2)!= null ? String.valueOf((loanAmountValue  / minimumValue).setScale(2)*100) :null;
                            }
                        }else if(oppObject.Vehicle_Type__c == System.Label.new){
                            Map<String,Decimal> dlpMasterMAP = new Map<String,Decimal>();
                            String loanAppId = payloadObject.loanApplicationId;
                           
                            String cfdStateCode = Utilities.getCFDStateCode([SELECT Id,Agent_BL_code__c FROM Opportunity WHERE Id =: loanAppId LIMIT 1].Agent_BL_code__c, 'T');
                            List<TBM_Product_Variant_dt__c> dlpMasterList = [SELECT Id, State_Code__c, Product_Variant_Code__c, Dealer_Landed_Price__c, Segment_Grade__c, 
                            Unique_State_Code__c FROM TBM_Product_Variant_dt__c Where State_Code__c =: cfdStateCode AND Product_Variant_Code__c =: vehicleDetailObject.Variant_Code__c];
                            
                            for(TBM_Product_Variant_dt__c dlpMasterRec: dlpMasterList){
                                if(!dlpMasterMAP.containsKey(dlpMasterRec.Product_Variant_Code__c)){
                                    dlpMasterMAP.put(dlpMasterRec.Product_Variant_Code__c, dlpMasterRec.Dealer_Landed_Price__c);
                                }
                            }
                            
                            Decimal minInvDlp = dlpMasterMAP.containsKey(vehicleDetailObject.Variant_Code__c) ? dlpMasterMAP.get(vehicleDetailObject.Variant_Code__c) : 0;
                            Double invoicePrice = vehicleDetailObject.Invoice_Price__c != null ? vehicleDetailObject.Invoice_Price__c : 0;

                            Decimal minOrpValue = 0;
                            if(minInvDlp != 0) {
                                minOrpValue = Math.min(minInvDlp, invoicePrice);
                            } else {
                                minOrpValue = invoicePrice;
                            }

                            responseJSON.ltvWithInsurance = String.valueOf(((loanAmountValue+premiumFunding)/(minOrpValue)).setScale(2)*100);
                            Decimal result = (loanAmountValue)/(minOrpValue);
                            responseJSON.ltvWithoutInsurance = String.valueOf((result.setScale(2))*100);
                        }
                    }else{
                        //Calculating LTV with Insurance & LTV without Insurance
                        if (oppObject.Vehicle_Type__c == System.Label.new && oppObject.Funding_on_Ex_Showroom__c) {
                            responseJSON.ltvWithInsurance =((Integer.valueOf(finaltermobj.Loan_Amount__c) + premiumFunding) / oppObject.Ex_showroom_price__c).setScale(2)!=null ? String.valueOf(((Integer.valueOf(finaltermobj.Loan_Amount__c) + premiumFunding) / oppObject.Ex_showroom_price__c).setScale(2)*100) :null;
                            //responseJSON.ltvWithInsurance = String.valueOf((oppObject.Required_Loan_amount__c + premiumFunding) / oppObject.Ex_showroom_price__c);
                            responseJSON.ltvWithoutInsurance =(Integer.valueOf(finaltermobj.Loan_Amount__c) / oppObject.Ex_showroom_price__c).setScale(2)!=null ? String.valueOf((Integer.valueOf(finaltermobj.Loan_Amount__c)  / oppObject.Ex_showroom_price__c).setScale(2)*100):null;
                        } else if (oppObject.Vehicle_Type__c == System.Label.new && oppObject.Funding_on_ORP__c) {
                            responseJSON.ltvWithInsurance = ((Integer.valueOf(finaltermobj.Loan_Amount__c) + premiumFunding) / oppObject.On_Road_price__c).setScale(2)!=null ? String.valueOf(((Integer.valueOf(finaltermobj.Loan_Amount__c) + premiumFunding) / oppObject.On_Road_price__c).setScale(2)*100):null;
                            responseJSON.ltvWithoutInsurance =(Integer.valueOf(finaltermobj.Loan_Amount__c) / oppObject.On_Road_price__c).setScale(2)!= null ? String.valueOf((Integer.valueOf(finaltermobj.Loan_Amount__c)  / oppObject.On_Road_price__c).setScale(2)*100) :null;
                        } else if (oppObject.Vehicle_Type__c == System.Label.used || oppObject.Vehicle_Type__c == System.Label.externalRefinance || oppObject.Vehicle_Type__c == System.Label.InternalRefinance || oppObject.Vehicle_Type__c == System.Label.Refinance) {
                            responseJSON.ltvWithInsurance =((Integer.valueOf(finaltermobj.Loan_Amount__c) + premiumFunding) / vehicleDetailObject.Base_Prices__c).setScale(2)!=null ?  String.valueOf(((Integer.valueOf(finaltermobj.Loan_Amount__c) + premiumFunding) / vehicleDetailObject.Base_Prices__c).setScale(2)*100) :null;
                            responseJSON.ltvWithoutInsurance =(Integer.valueOf(finaltermobj.Loan_Amount__c) / vehicleDetailObject.Base_Prices__c).setScale(2)!=null ?  String.valueOf((Integer.valueOf(finaltermobj.Loan_Amount__c)  / vehicleDetailObject.Base_Prices__c).setScale(2)*100) :null;
                        }
                        if (oppObject.Vehicle_Type__c == System.Label.new) {
                            responseJSON.proposalLtv = (loanAmount + premiumFunding) / oppObject.On_Road_price__c;
                        } else {
                            responseJSON.proposalLtv = (loanAmount + premiumFunding) / vehicleDetailObject.Base_Prices__c;
                        }
                    }
                    responseJSON.totalPremiumFunded = premiumFunding;
                    responseJSON.totalInsurancePayable = totalInsurancePayable;
                    responseJSON.responseStatus = true;
                    String serializedResponse = JSON.serialize(responseJSON);
                    System.debug('response 1= > ' + serializedResponse);
                    if(oppObject.LeadSource == 'D2C'){ // D2C Change
                        updateDetailsForD2C(responseJSON, payloadObject.loanApplicationId);
                    }
                    return serializedResponse;
                } else {
                    responseJSON.responseStatus = false;
                    responseJSON.totalPremiumFunded = premiumFunding;
                    String serializedResponse = JSON.serialize(responseJSON);
                    System.debug('response 2= > ' + serializedResponse);
                    if(oppObject.LeadSource == 'D2C'){//D2C Change
                        updateDetailsForD2C(responseJSON, payloadObject.loanApplicationId);
                    }
                    return serializedResponse;
                }
            }
            return null;
        } catch (Exception e) {
            System.debug(e.getCause() + ' ' + e.getLineNumber() + ' ' + e.getMessage());
            ErrorLoggerUtil.logErrorEvent('IND_InsuranceDetailsLWC_controller', ' getFundingAvailibility ', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    //Method Added for D2C
    public static void updateDetailsForD2C(GetFundingAvailabiltyResponseWrapper payloadObject, String loanAppId){
        Applicant__c appObj = [SELECT Id FROM Applicant__c WHERE Opportunity__c =:loanAppId];
        appObj.LTV_with_Insurance__c = payloadObject.ltvWithInsurance!= null ? Integer.ValueOf(payloadObject.ltvWithInsurance):0;
        appObj.LTV_without_insurance__c =payloadObject.ltvWithoutInsurance!=null ? Integer.ValueOf(payloadObject.ltvWithoutInsurance):0;
        appObj.Total_Insurance_Payable__c = payloadObject.totalInsurancePayable;
        appObj.Proposal_LTV__c = payloadObject.proposalLtv;
        update appObj;
    }
    
    //nandini
    @AuraEnabled(Cacheable = true)
    public static Applicant__c getInsuranceConsentCheckboxValue(String loanapplicationId, String appType) {
        Applicant__c appObj = [SELECT Id, Insurance_Consent_Received__c FROM Applicant__c WHERE Opportunity__c =: loanapplicationId AND Applicant_Type__c =: appType AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED LIMIT 1];
        return appObj;
    }
    
    @AuraEnabled
    public static String updateInsuranceConsentReceived(Boolean checked,String loanapplicationId, String appType) {
        try {
            if (checked != null && appType != null && loanapplicationId != null) {
                
                Applicant__c appObj = [SELECT Id, Insurance_Consent_Received__c FROM Applicant__c WHERE Opportunity__c =: loanApplicationId AND Applicant_Type__c =: appType AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED LIMIT 1];
                
                appObj.Insurance_Consent_Received__c = checked;
                
                if (Schema.sObjectType.Opportunity.isUpdateable()) {
                    update appObj;
                }
                
                return System.Label.Success;
            }
            
            return System.Label.Failure;
        } catch (Exception e) {
            
            System.debug(e.getCause() + '' + e.getLineNumber() + '' + e.getMessage());
            ErrorLoggerUtil.logErrorEvent('IND_InsuranceDetailsLWC_controller', ' submitInsuranceDetails ', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
            // return System.Label.Failure;
        }
    }
    
    @AuraEnabled
    public static String updateInsuranceConsent(String loanapplicationId, String flag) {
        try {
            if (loanapplicationId != null) {
                System.debug('loanapplicationId'+loanapplicationId);
                System.debug('flag'+flag); 
                Applicant__c appObj = [SELECT Id, Insurance_Consent_OTP__c,Application_Consent_OTP__c FROM Applicant__c WHERE Id =: loanApplicationId WITH SECURITY_ENFORCED];
                
                if(flag == 'LAS'){                                                         
                    appObj.Application_Consent_OTP__c = string.valueOf(Utilities.generateUniqueNumber(5));
                    System.debug('appObj.Application_Consent_OTP__c'+appObj.Application_Consent_OTP__c);
                }
                if(flag == 'INC'){  
                    appObj.Insurance_Consent_OTP__c = string.valueOf(Utilities.generateUniqueNumber(5));
                    System.debug('appObj.Insurance_Consent_OTP__c'+appObj.Insurance_Consent_OTP__c);
                }  
                  
                if (Schema.sObjectType.Opportunity.isUpdateable()) {
                    update appObj;
                }
                
                return System.Label.Success;
            }
            
            return System.Label.Failure;
        } catch (Exception e) {
            
            System.debug(e.getCause() + '' + e.getLineNumber() + '' + e.getMessage());
            ErrorLoggerUtil.logErrorEvent('IND_InsuranceDetailsLWC_controller', ' updateInsuranceConsent ', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
            // return System.Label.Failure;
        }
    }
    
    //Wrapper class for Funding Availability Request.
    public class GetFundingAvailabiltyRequestWrapper {
        @AuraEnabled public String loanApplicationId {get;set;}
        @AuraEnabled public String assetId {get;set;}
        @AuraEnabled public List<InsuranceWrapper> insProductDetails {get;set;}
    }
    
    //Wrapper class for Funding Availability Response.
    public class GetFundingAvailabiltyResponseWrapper {
        public Double totalInsurancePayable {get;set;}
        public String ltvWithInsurance {get;set;}
        public String ltvWithoutInsurance {get;set;}
        public Double proposalLtv {get;set;}
        public Double totalPremiumFunded {get;set;}
        public Boolean responseStatus {get;set;}
    }
    
    //Wrapper class
    public class InsuranceWrapper {
        @AuraEnabled public string selectedProduct {get;set;}
        @AuraEnabled public string selectedPlan {get;set;}
        @AuraEnabled public Boolean isFunded {get;set;}
        @AuraEnabled public Decimal premium {get;set;}
        @AuraEnabled public Decimal comboLIPremium {get;set;}
        @AuraEnabled public Decimal comboEMIPremium {get;set;}
        @AuraEnabled public Decimal eMIPassedinAPI {get;set;}

        //Below wrapper fields are specific to Tractor product type | SFTRAC-176
        @AuraEnabled public Decimal proposalLtv {get;set;}
        @AuraEnabled public Decimal ltvWithoutInsurance {get;set;}
        @AuraEnabled public Decimal ltvWithInsurance {get;set;}
        @AuraEnabled public Decimal totalInsurancePayable {get;set;}
        @AuraEnabled public Decimal premiumFunded {get;set;}
    }
    
    
    /*
    * @Method:      getCurrentSubStage
    * @Created by:  
    * @Description: method for fetching the sub stage.
    * @Param:       String loanapplicationId
    * @Return:      String - SubStage
    */
    @AuraEnabled(Cacheable = true)
    public static String getCurrentSubStage(String opportunityId) {
        try {
            if (opportunityId != null) {
                Opportunity oppObj = [SELECT Sub_Stage__c FROM Opportunity WHERE id =: opportunityId WITH SECURITY_ENFORCED];
                return oppObj.Sub_Stage__c;
            }
            return null;
        } catch (Exception e) {
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(' IND_InsuranceDetailsWrapper ', ' getCurrentSubStage ', 'System.Label.Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    @AuraEnabled
    public static boolean checkInsuranseExpWith60Days(String loanApplicationId) {
        try {
            if (loanApplicationId != null) {
                List<Vehicle_Detail__c> vehicleList = [SELECT Insurance_expiring_within_60_days__c FROM Vehicle_Detail__c WHERE Loan_Application__c =: loanApplicationId LIMIT 1];
                if(vehicleList.size() > 0 && vehicleList[0].Insurance_expiring_within_60_days__c == true){
                    return true;
                }
            }
            return false;
        } catch (Exception e) {
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(' IND_InsuranceDetailsWrapper ', ' getCurrentSubStage ', 'System.Label.Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getProductTypeFromOpp(String recordId) {
        return [SELECT Id,Product_Type__c,LeadSource,Submitted_Tabs__c,Total_Exposures_Amount__c,Loan_amount__c,Existing_Borrowers_Exposure_Amt__c,Existing_Co_Borrowers_Exposure_Amt__c,Existing_Others_Exposure_Amt__c,Total_Bank_Exposure__c From Opportunity where id=:recordId]; //OLA-70 here Added Leadsource //D2C Change
    } 
        

    @AuraEnabled(cacheable=true)
    public static List<Final_Term__c> getFinalTermLoanAmount(String recordId) {
        return [Select Id, Loan_Amount__c,Loan_Application__r.Total_Funded_Premium__c, EMI_Amount__c,Installment_Type__c from Final_Term__c where Loan_Application__c =:recordId]; //OLA-70 here Added Leadsource //D2C Change 
    } 
        
    
    /*
    * @Method:      checkRetryExhausted
    * @Created by:  Khushiram
    * @Description: This method will check No of api triggered attempts for applicant (Borrower/Co-borrower)
    * @Param:       String - current Applicant ID
    * @Param:       String - loanApplication ID
    * @Param:       String - attemptFor : For which api number of attempts need to checked
    * @Return:      String - Success/Failure
    */ 
    @AuraEnabled
    public static String checkRetryExhausted(String loanApplicationId,String attemptFor,String applicantId){
        try{
            System.debug('Loan Appliation id :'+loanApplicationId+', attemptFor : '+attemptFor+', applicantId :');
            //Null Check 
            if(loanApplicationId != null && attemptFor != null){
                Retry_Count__c retryCount = new Retry_Count__c();
                List<Retry_Count__c> retryCountList = new List<Retry_Count__c>();
                retryCountList = [select Loan_Application_Id__c from Retry_Count__c where Loan_Application_Id__c =: loanApplicationId AND Applicant__c =:applicantId AND Service_Name__c =:attemptFor WITH SECURITY_ENFORCED];
                system.debug('retryCountList::'+retryCountList);
                if(retryCountList.isEmpty()) {
                    retryCount.Loan_Application_Id__c = loanApplicationId;
                    retryCount.Service_Name__c = attemptFor;
                    retryCount.Applicant__c = applicantId;
                    retryCount.Count__c = 1;
                    if(Schema.sObjectType.Retry_Count__c.isCreateable()){
                        insert retryCount;
                    }
                    return System.Label.SuccessMessage;
                }
                else{
                    System_Constant_custom_metadata__mdt metadata = System_Constant_custom_metadata__mdt.getInstance('InsuranceDetailsAPI1'); 
                    //If number of attempts are greater than predefined number of attempts.
                    Retry_Count__c  count = [select Count__c from Retry_Count__c where Loan_Application_Id__c =: loanApplicationId AND Applicant__c =:applicantId AND Service_Name__c =:attemptFor WITH SECURITY_ENFORCED limit 1];
                    system.debug('count::'+count.Count__c);
                    system.debug('count::'+metadata.Number_Of_Attempts__c);
                    if(count.Count__c >= metadata.Number_Of_Attempts__c){
                        return System.Label.Retry_Exhausted;
                    }
                    //If number of attempts are Less than predefined number of attempts.
                    else{
                        count.Count__c += 1;
                        if (Schema.sObjectType.Retry_Count__c.isUpdateable()){
                            update count;
                        }                    
                        return System.label.SuccessMessage;
                    }
                }
            }
            return System.label.FailureMessage;
        }
        //Catch block 
        catch(Exception e){
            System.debug('error line no => '+ e.getCause() + '  '+ e.getLineNumber() +' '+e.getMessage());
            ErrorLoggerUtil.logErrorEvent('IND_InsuranceDetailsLWC_controller' ,'checkRetryExhausted', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    @AuraEnabled
    public static void deleteExistingPlans(String loanApplicationId,String applicantId){
        try{
            delete [SELECT id FROM InsuranceDetails__c WHERE Loan_Application__c =: loanApplicationId AND Applicant__c =: applicantId WITH SECURITY_ENFORCED];
        }
        catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_InsuranceDetailsLWC_controller' ,'deleteExistingPlans', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }    
    @AuraEnabled
    public static void deleteExistingPlansTf(String loanApplicationId,String vehicleId,Boolean isCalledFromL2){
        try{
            delete [SELECT id FROM InsuranceDetails__c WHERE Loan_Application__c =: loanApplicationId AND Vehicle_Detail__c =: vehicleId WITH SECURITY_ENFORCED];
            Vehicle_Detail__c vehicleObj = new Vehicle_Detail__c();
            vehicleObj.Id = vehicleId;
            vehicleObj.Total_Funded_Amount__c = null;
            vehicleObj.LTV_Without_Insurance__c = null;
            vehicleObj.LTV_With_Insurance__c = null;
            vehicleObj.Total_Insurance_Payable__c = null;
            vehicleObj.Funded_Premium__c = null;
            if(isCalledFromL2 == true){
                vehicleObj.L1_InsuranceChanged__c = true; 
            }
            update vehicleObj;
        }
        catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_InsuranceDetailsLWC_controller' ,'deleteExistingPlanstf', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }    
    
    /*
    * @Method:      getEligibleApplicantTabList
    * @Created by:  
    * @Description: method for fetching appropriate applicant TabList.
    * @Param:       String loanapplicationId
    * @Return:      List<TabListWrapper>
    */
    @AuraEnabled(Cacheable = true)
    public static List<TabListWrapper> getEligibleApplicantTabList(String opportunityId) {
        List<TabListWrapper> tabWrapperLst = new List<TabListWrapper>();
        try {
            if (opportunityId != null) {
                String coborrowerRelation = System.Label.Insurance_CoBorrower_Relationship;
                List<String> coborrowerRelationList = coborrowerRelation.split(',');
                Map<String,String> coborrowerRelationMap = new Map<String,String>();
                for(String rel: coborrowerRelationList){
                    coborrowerRelationMap.put(rel.toUppercase(),rel.toUppercase());
                }
                List<Applicant__c> appLst = [SELECT Id, Applicant_Type__c, IsPrimary__c, Relationship_with_borrower__c 
                                                FROM Applicant__c 
                                                WHERE Opportunity__c =: opportunityId  AND In_Active_Applicant__c = false
                                                WITH SECURITY_ENFORCED];
                for(Applicant__c app: appLst){
                    String appRelation = app.Relationship_with_borrower__c != null ? app.Relationship_with_borrower__c.toUppercase() : '';
                    if(app.Applicant_Type__c == System.Label.Borrower){
                        tabWrapperLst.add(new TabListWrapper(app.Id,app.Applicant_Type__c));
                    }else if(app.Applicant_Type__c == System.Label.CoBorrower && app.IsPrimary__c == true && coborrowerRelationMap.containsKey(appRelation) ){
                        tabWrapperLst.add(new TabListWrapper(app.Id,app.Applicant_Type__c));
                    }
                }
            }
        } catch (Exception e) {
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(' IND_InsuramceDetailsLWC_Controller ', ' getEligibleApplicantTabList ', 'System.Label.Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        return tabWrapperLst;
    }

    class TabListWrapper{

        @AuraEnabled
        public string applicantId{get;set;}
        @AuraEnabled
        public string applicantType{get;set;}
        
        public TabListWrapper(String id, String type){
            this.applicantId = id;
            this.applicantType = type;
        }
    }

    /*
    * @Method:      getAssetTabList
    * @Created by:  Chaynnitt Agarwal
    * @Description: method for fetching list of Asset TabList.
    * @Param:       String loanapplicationId
    * @Return:      List<AssetTabListWrapper>
    * @Story:       SFTRAC-176
    */
    @AuraEnabled
    public static List<AssetTabListWrapper> getAssetTabList(String opportunityId) {
        List<AssetTabListWrapper> tabWrapperLst = new List<AssetTabListWrapper>();
        try {
            if (opportunityId != null) {
                List<Vehicle_Detail__c> assetLst = [SELECT Id,Variant__c, L1_Insurance_Submitted__c, L2_Insurance_Submitted__c, Loan_Application__r.Product_Type__c, Loan_Application__r.StageName FROM Vehicle_Detail__c WHERE Loan_Application__c =: opportunityId WITH SECURITY_ENFORCED ORDER BY CreatedDate ASC];
                for(Vehicle_Detail__c veh: assetLst){
                    tabWrapperLst.add(new AssetTabListWrapper(veh));
                }
            }
        } catch (Exception e) {
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(' IND_InsuramceDetailsLWC_Controller ', ' getAssetTabList ', 'System.Label.Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }

        return tabWrapperLst;
    }

    class AssetTabListWrapper{

        @AuraEnabled
        public string id{get;set;}
        @AuraEnabled
        public string label{get;set;}
        @AuraEnabled
        public boolean l1Submitted{get;set;} //SFTRAC-1007
        @AuraEnabled
        public boolean l2Submitted{get;set;}//SFTRAC-1007
        
        public AssetTabListWrapper(Vehicle_Detail__c veh){
            this.id = veh.id;
            //this.label = veh.Variant__c;
            //SFTRAC-1007 Starts
            String tickSymbol = '\u2713';
            String stageL1orL2 = (veh.Loan_Application__r.StageName == 'Insurance Details' || veh.Loan_Application__r.StageName =='Final Offer') ? 'L1' : (veh.Loan_Application__r.StageName == 'Credit Processing' || veh.Loan_Application__r.StageName =='Disbursement Request Preparation' || veh.Loan_Application__r.StageName =='Disbursement Request Preparation') ? 'L2' : '';
            if(veh.Loan_Application__r.Product_Type__c == 'Tractor'){
                if(stageL1orL2 == 'L1' && veh.L1_Insurance_Submitted__c == true){
                    this.label = veh.Variant__c+' '+tickSymbol;
                }else if(stageL1orL2 == 'L2' && veh.L2_Insurance_Submitted__c == true){
                    this.label = veh.Variant__c+' '+tickSymbol;
                }else{
            this.label = veh.Variant__c;
                }    
            }else{//SFTRAC-1007 Ends
                this.label = veh.Variant__c;
            }
            this.l1Submitted = veh.L1_Insurance_Submitted__c;//SFTRAC-1007
            this.l2Submitted = veh.L2_Insurance_Submitted__c;//SFTRAC-1007
        }
    }

    /*
    * @Method:      isApplicantInsuranceApplicable
    * @Created by:  Chaynnitt Agarwal
    * @Description: method for checking if applicant is eligible for Insurance.
    * @Param:       String loanapplicationId, String applicantId
    * @Return:      Boolean
    * @Story:       SFTRAC-176
    */
    @AuraEnabled
    public static Boolean isApplicantInsuranceApplicable(String loanapplicationId, String applicantId) {
        Boolean isApplicable = true;
        try {
           List<InsuranceDetails__c> insList = [Select id from InsuranceDetails__c where Loan_Application__c =: loanapplicationId AND Applicant__c !=: applicantId AND Loan_Application__r.Customer_Type__c = 'Individual'];
           if(insList.size() > 0){
                return true;
           }
        } catch (Exception e) {
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(' IND_InsuramceDetailsLWC_Controller ', ' isApplicantInsuranceApplicable ', 'System.Label.Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        return false;
    }

     /*
    * @Method:      updateVehicleDetails
    * @Created by:  Santhosh Guhan
    * @Description: method for updating the vehicle details for non individual tractor application.
    * @Param:       String loanapplicationId, String leadStage
    * @Return:      void
    */
    @AuraEnabled
    public static void updateVehicleDetails(String loanApp,String leadStage) {
        try {
            if (loanApp != null) {
                List<Vehicle_Detail__c> vehicleList = [SELECT Id,L1_Insurance_Submitted__c,L2_Insurance_Submitted__c FROM Vehicle_Detail__c WHERE Loan_Application__c =:loanApp];
                List<Vehicle_Detail__c> updVehicleList = new List<Vehicle_Detail__c>();
                if(vehicleList.size() > 0){
                    for(Vehicle_Detail__c vd:vehicleList){
                        if(leadStage == 'L1'){
                            vd.L1_Insurance_Submitted__c = true;
                        } else if(leadStage == 'L2'){
                            vd.L2_Insurance_Submitted__c = true;
                        }
                        updVehicleList.add(vd);
                    }
                }
                if(!updVehicleList.isEmpty()){
                    update updVehicleList;
                }
                    Opportunity opportunityObj = [SELECT Id,StageName,LastStageName__c,Submitted_Tabs__c,Sub_Stage__c FROM Opportunity WHERE id =:loanApp WITH SECURITY_ENFORCED];
                    if(leadStage == 'L1'){
                        opportunityObj.StageName = 'Final Offer';
                        opportunityObj.LastStageName__c = 'Final Offer';
                        update opportunityObj;
                    }else if(leadStage == 'L2'){
                        opportunityObj.Sub_Stage__c = 'Risk Summary';                        
                        update opportunityObj;
                }
            }
        } catch (Exception e) {
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('IND_InsuranceDetailsWrapper', 'updateVehicleDetails', 'System.Label.Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    /*SFTRAC-1453
    * @Method:      deleteStructeredEMIRec
    * @Created by:  Aakash J 
    * @Description: This method is used to delete Structered EMI Records.
    * @Param:       String - vehicle ID.
    * @Return:      void 
    */
    @AuraEnabled
    public static void deleteStructeredEMIRec(String vehicleRecId, String loanAppId){
        try {
            
            List<Structered_EMI__c> strList = new List<Structered_EMI__c>();
            strList = [SELECT Id FROM Structered_EMI__c WHERE Loan_Application__c=:loanAppId AND Vehicle_Detail__c =:vehicleRecId WITH SECURITY_ENFORCED];
            system.debug('+++++strList '+strList);
            if(!strList.isEmpty()){
                delete strList;
            }
            
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
}