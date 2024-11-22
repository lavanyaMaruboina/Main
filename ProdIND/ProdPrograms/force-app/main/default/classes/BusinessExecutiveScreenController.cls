/**
* @Name         BusinessExecutiveScreenController
* @Author       Raman Raj Saxena
* @Company      Salesforce
* @Description  This class is the controller class of Business Executive Screen LWC Component
* Inputs:       None
* Test Class:   BusinessExecutiveScreenControllerTest
*/
public with sharing class BusinessExecutiveScreenController {
    /*
    * @Method:      getApplicantId
    * @Created by:  Raman Raj Saxena
    * @Description: Method to return id of the applicant
    * @Param:       String - loanApplication ID
    * @Return:      String applicantId
    */
    @AuraEnabled(cacheable=true)
    public static String getApplicantId(String loanApplicationId){
        try{
            Applicant__c applicant = [SELECT Id FROM Applicant__c WHERE Opportunity__c =: loanApplicationId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED ORDER BY CreatedDate ASC LIMIT 1];
            return applicant.Id;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent(
                BusinessExecutiveScreenController.class.getName(),
                ' getApplicantId ',
                System.Label.Apex,
                e
            );
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    @AuraEnabled
    public static ApplicationDetails fetchApplicationDetails(String loanApplicationId){
        try{
            ApplicationDetails details = new ApplicationDetails();
            Applicant__c applicant = [SELECT Id, Opportunity__r.Is_ETB__c,  Opportunity__r.Product_Type__c, Opportunity__r.Vehicle_Verified__c, Opportunity__r.Vehicle_Registration_Number__c,
                Opportunity__r.VKYC_Doc_Urls__c, Opportunity__r.VKYC_Doc_Downloaded__c, Opportunity__r.LastStageName__c,
                Opportunity__r.Vehicle_Type__c, Opportunity__r.StageName, Opportunity__r.Sub_Stage__c, Opportunity__r.Sanction_Status__c, 
                Opportunity__r.Is_Pre_Approved__c,Opportunity__r.AccountId FROM Applicant__c WHERE Opportunity__c =: loanApplicationId AND 
                In_Active_Applicant__c = false WITH SECURITY_ENFORCED ORDER BY CreatedDate ASC LIMIT 1];
                
            List<Vehicle_Detail__c> vehicleDetail = new List<Vehicle_Detail__c>();
            vehicleDetail = [SELECT Id, Ins_Expiry_date__c, Insurance_declared_value__c, Engine_number__c, Insurance_expiring_within_60_days__c FROM Vehicle_Detail__c WHERE Loan_Application__c=: loanApplicationId WITH SECURITY_ENFORCED ORDER BY CreatedDate ASC LIMIT 1];
            List < InsuranceDetails__c > insProdLst = new List < InsuranceDetails__c > ();
            insProdLst = [SELECT id, Name, Amount__c, Applicant__c, Funded_Non_funded__c, Funded_Premium__c, Insurance_Plan__c, Loan_Application__c, 
                            Loan_Application__r.StageName, Loan_Application__r.Sub_Stage__c,Applicant__r.LTV_with_Insurance__c,
                            Applicant__r.LTV_without_insurance__c,Applicant__r.Total_Insurance_Payable__c
                            FROM InsuranceDetails__c
                            WHERE Loan_Application__c =: loanApplicationId
                            AND Applicant__c =: applicant.Id
                            WITH SECURITY_ENFORCED];
            if(insProdLst != null && !insProdLst.isEmpty()){
                details.insDetials = insProdLst[0];
            }
            details.applicant = applicant;
            details.vehicleDetail = !vehicleDetail.isEmpty() ? vehicleDetail[0] : null;
            System.debug('details-->'+details);
            return details;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent(
                BusinessExecutiveScreenController.class.getName(),
                ' fetchApplicationDetails ',
                System.Label.Apex,
                e
            );
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }


    @AuraEnabled
    public static String moveToCreditProcessing(String loanApplicationId){
        String MOVEMENT_SUCCESSFUL = 'success';
        try {

            List<Opportunity> loanApplication = [SELECT id, Product_Type__c,Vehicle_type__c, RTO_Road_Tax__c, Other_charges__c,X1st_yr_Insurance_Premium__c, (SELECT id, Income_source_available__c,Check_Eligibility_Message__c, Check_Eligibility_Match__c, Preferred_address_for_communication__c from Applicants__r ), (SELECT id, Applicant__c,Name, Amount__c, Funded_Premium__c, Funded_Non_funded__c FROM Insurance_Details__r ) FROM Opportunity WHERE id=: loanApplicationId ];
            Decimal motorPremim;
            Boolean motorFunded = false;
            if(loanApplication.size() > 0 && loanApplication[0].Applicants__r.size() > 0) {
                List<Applicant__c> applicants = loanApplication[0].Applicants__r;
                List<InsuranceDetails__c> insuranceRecords = loanApplication[0].Insurance_Details__r;
                Decimal fundedPremium = 0;
                Decimal totalInsurance = 0;
                
                for(InsuranceDetails__c insurance : insuranceRecords) {
                    insurance.Applicant__c = applicants[0].Id;

                    totalInsurance += insurance.Amount__c;
                    if(insurance.Funded_Non_funded__c == 'Funded'){
                        fundedPremium += insurance.Amount__c;
                    }
                    if(insurance.Name == 'MOTOR'){
                        motorPremim = insurance.Amount__c;
                        if(insurance.Funded_Non_funded__c == 'Funded'){
                            motorFunded = true;
                        }
                    }
                }
                for(InsuranceDetails__c insurance : insuranceRecords) {
                    insurance.Funded_Premium__c = fundedPremium;
                }

                if(insuranceRecords.size() > 0) {
                    update insuranceRecords;
                }
                Applicant__c applicant = applicants[0];
                applicant.Income_source_available__c = true;
                applicant.Total_Insurance_Payable__c = totalInsurance;
                applicant.Preferred_address_for_communication__c = 'Residence Address';
                
                if(String.isNotBlank(applicant.Check_Eligibility_Message__c)) {
                    applicant.Check_Eligibility_Match__c = true;
                }
                applicant.Bureau_Pull_Match__c = true;
                update applicant;

                List<Income_Details__c> incomeRecords = [SELECT Id, BSR_Occupation__c,Primary_Income_Source__c FROM Income_Details__c WHERE Applicant__c =: applicant.Id ];
                if(incomeRecords.size() > 0) {
                    incomeRecords[0].BSR_Occupation__c = '95012';
                    incomeRecords[0].Primary_Income_Source__c = true;
                    incomeRecords[0].Legal__c = 'Individual';
                    update incomeRecords;
                }


            }
            Vehicle_Detail__c vdRecord = [SELECT Id, Vehicle_Registration_number__c FROM Vehicle_Detail__c WHERE Loan_Application__c =:loanApplicationId LIMIT 1];
            vdRecord.Vehicle_Type__c = loanApplication[0].Vehicle_type__c;
            update vdRecord;
            Final_Term__c finalTerms = [   SELECT Id, RTO_prefix__c, Loan_Application__r.Required_ROI__c, Loan_Application__r.Required_Tenure__c, Loan_Application__r.Loan_Amount__c, Required_CRM_IRR__c, CRM_IRR__c
                                    FROM Final_Term__c
                                    WHERE Loan_Application__c =:loanApplicationId
                                    WITH SECURITY_ENFORCED];
            Opportunity oppty = new Opportunity(Id=loanApplicationId);
            oppty.StageName = 'Credit Processing';
            oppty.Sub_Stage__c = 'View Application Details';
            
            if(loanApplication[0].Other_charges__c == null || loanApplication[0].Other_charges__c < 0) {
                oppty.Other_charges__c = 0;
            }
            if(loanApplication[0].X1st_yr_Insurance_Premium__c == null || loanApplication[0].X1st_yr_Insurance_Premium__c < 0 )  {
                oppty.X1st_yr_Insurance_Premium__c = 0;
            }
            if(motorPremim != null){
                oppty.Motor_Insurance_Premium__c = motorPremim;
                oppty.Funded__c = motorFunded;
                oppty.Non_Funded__c = !motorFunded;
            }else{
                oppty.Funded__c = false;
                oppty.Non_Funded__c = false;
            }
            
            oppty.Funding_on_ORP__c = true;
            oppty.Funding_on_Ex_Showroom__c = false;
            oppty.RTO_Road_Tax_New__c = loanApplication[0].RTO_Road_Tax__c;
            // if(loanApplication[0].Product_Type__c == 'Two Wheeler' && loanApplication[0].Vehicle_type__c == 'New') {
            //     oppty.RTO_Road_Tax_New__c = oppty.RTO_Road_Tax__c;
            // }
            if(String.isNotBlank(finalTerms.Loan_Application__r.Loan_Amount__c)){
                if(finalTerms.Loan_Application__r.Loan_Amount__c.contains('.')){
                    oppty.Required_Loan_amount__c = Integer.valueOf(finalTerms.Loan_Application__r.Loan_Amount__c.substringBefore('.'));
                }else{
                    oppty.Required_Loan_amount__c = Integer.valueOf(finalTerms.Loan_Application__r.Loan_Amount__c);
                }
            }
            update oppty;
            // Final_Term__c finalTerms = [   SELECT Id, Loan_Application__r.Required_ROI__c, Loan_Application__r.Required_Tenure__c, Loan_Application__r.Loan_Amount__c
            //                         FROM Final_Term__c
            //                         WHERE Loan_Application__c =:loanApplicationId
            //                         WITH SECURITY_ENFORCED];
            finalTerms.Loan_Amount__c = finalTerms.Loan_Application__r.Loan_Amount__c;
            //finalTerms.EMI_Amount__c = finalTerms.Loan_Application__r.Loan_Amount__c;
            finalTerms.Tenure__c = String.valueOf(finalTerms.Loan_Application__r.Required_Tenure__c);
            finalTerms.Installment_Type__c = 'Equated';
            finalTerms.Required_CRM_IRR__c = String.valueOf(finalTerms.CRM_IRR__c);
            if(vdRecord != null && String.isNotBlank(vdRecord.Vehicle_Registration_number__c)) {
                String rto_prefix = vdRecord.Vehicle_Registration_number__c.subString(0, 4);

                finalTerms.RTO_prefix__c = rto_prefix;
            }
            update finalTerms;
            // try{
                // Populating Gender field on Pan record from Applicant
                Documents__c aadharDocument = [SELECT Id, Gender__c, First_Name__c, Last_Name__c, KYC_DOB__c FROM Documents__c WHERE Opportunity_Relation__c =:loanApplicationId AND Document_Type__c != 'PAN' AND Gender__c != null AND KYC_DOB__c != null LIMIT 1];
                Documents__c panDocument = [SELECT Id FROM Documents__c WHERE Opportunity_Relation__c =:loanApplicationId AND Document_Type__c = 'PAN' LIMIT 1];
                panDocument.Gender__c = aadharDocument.Gender__c;
                panDocument.KYC_DOB__c = aadharDocument.KYC_DOB__c;
                update panDocument;

                List<Documents__c> addressDocuments = [SELECT Id, Document_Type__c, Current_Residential_Address_Proof__c, Permanent_Residential_Address_Proof__c FROM Documents__c 
                    WHERE Opportunity_Relation__c =:loanApplicationId 
                    AND (Current_Residential_Address_Proof__c = TRUE OR Permanent_Residential_Address_Proof__c = TRUE)];
                    
                for(Documents__c addressDoc : addressDocuments) {
                    if(addressDoc.Current_Residential_Address_Proof__c == true) {
                        addressDoc.Addresss_Type__c = 'Current Residential Address';
                    } else if(addressDoc.Permanent_Residential_Address_Proof__c == true) {
                        addressDoc.Addresss_Type__c = 'Permanent Residential Address';
                    }
                    if(String.isBlank(addressDoc.Document_Type__c)) {
                        addressDoc.Document_Type__c = 'Other';
                    } 
                }
                update addressDocuments;

            // }catch(Exception e){
            //     System.debug(e);
            // }

            FinalTermscontroller.callCreateFI(loanApplicationId, 'Pre-FI');
            if(loanApplication[0].Product_Type__c == 'Two Wheeler'){
                Boolean isMORefinance = FIAssignmentController.checkUserRole(loanApplicationId);
                System.debug('isMORefinance-'+isMORefinance);
                FIAssignmentController.applicationAssignmentTW(loanApplicationId,isMORefinance);
            }
            
            return MOVEMENT_SUCCESSFUL;
        } catch (Exception e) {
            system.debug('Failed getMessage: '+e.getMessage());
            return e.getMessage();
        }
    }
    /* CISP- 9783 START*/
    /*
    * @Method:      cvoUserExists
    * @Created by:  Nikhil Somvanshi
    * @Description: Check if an active CVO User exists in the org
    * @Param:       String - loanApplication ID
    * @Return:      Boolean 
    */
    @AuraEnabled(cacheable=true)
    public static Boolean cvoUserExists(String loanApplicationId){
        try{
            Opportunity loanApplication = [Select AccountId From Opportunity 
                                            where Id=: loanApplicationId LIMIT 1 ];
             if(loanApplication!=null) {
                    List<AccountTeamMember> teamMemberCVO = new List<AccountTeamMember>([Select AccountId,userId
                                                        From AccountTeamMember
                                                        Where teammemberrole = 'CVO'
                                                        AND AccountId = :loanApplication.AccountId AND User.IsActive = true
                                                        Limit 1]);
                    if(teamMemberCVO != null && !teamMemberCVO.isEmpty()){
                        return true;
                    }else{
                        return false;
                    }
            }
            return null; 
        }catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent(
                BusinessExecutiveScreenController.class.getName(),
                'cvoUserExists',
                System.Label.Apex,
                e
            );
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    /* CISP- 9783 END*/

    public class ApplicationDetails{
        @AuraEnabled public Applicant__c applicant;
        @AuraEnabled public Vehicle_Detail__c vehicleDetail;
        @AuraEnabled public InsuranceDetails__c insDetials;
    }
}