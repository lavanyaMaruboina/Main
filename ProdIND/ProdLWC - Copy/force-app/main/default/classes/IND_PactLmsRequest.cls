/*------------------------------------------------------------
Author: Satyam More 
Company: Persistent Systems
Description: This class is wrapper class for the Pact Lms Request
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
19-01-2022    Satyam More            Created
16-02-2022    Santhosh Mothe         updated two fields as per latest version v3
------------------------------------------------------------*/

public class IND_PactLmsRequest extends ParentAPIRequest{
    public String loanAppId {get;set;}
    public class ObjPRPDList {
        public String Deal_No{get;set;}
        public String Category{get;set;}
        public Decimal Prm{get;set;}
        public Decimal IDV{get;set;}
        public Integer Year_No{get;set;}
        public String RSD{get;set;}
    }
    
    public ObjReqPR objReqPR{get;set;}
    
    public class ObjPRAList {
        public String Deal_No{get;set;}
        public String Adjust_Deal_No{get;set;}
        public Decimal Amount{get;set;}
        public String Customer_code{get;set;}
    }
    public class objDocumentInfo {
        public String Document_Type{get;set;}
        public String Record_Id{get;set;}
    }
    public class ObjReqPR {
        public List<PactLmsRequestHelper.ObjRFDList> objRFDList;
        public List<PactLmsRequestHelper.ObjPRList> objPRList;
        public List<PactLmsRequestHelper.ObjPROList> objPROList;
        public List<PactLmsRequestHelper.ObjPayInOutList> objPayInOutList;
        public List<PactLmsRequestHelper.ObjPRIList> objPRIList;
        public List<PactLmsRequestHelper.ObjPUIMList> objPUIMList;
        public List<PactLmsRequestHelper.ObjPRBList> objPRBList;// Change For CISP-3564.
        public List<PactLmsRequestHelper.ObjPRInsList> objPRInsList;
        public List<ObjPRAList> objPRAList;
        public List<ObjPRPDList> objPRPDList;
        public List<PactLmsRequestHelper.ObjGPRList> objGPRList;
        public List<PactLmsRequestHelper.ObjPRBDTList> objPRBDTList;
        public List<PactLmsRequestHelper.ObjDRLList> objDRLList;
        public List<PactLmsRequestHelper.ObjPRPList> objPRPList;
        public List<PactLmsRequestHelper.ObjSANDList> objSANDList;
        public List<objDocumentInfo> objDocumentInfo;
        public List<PactLmsRequestHelper.ObjConsentInfo> ObjConsentInfo;
        public List<PactLmsRequestHelper.ObjRequestLead> objRequestLead;
    }
    //constructor
    public  IND_PactLmsRequest(String loanAppId, String dealId){
        if( loanAppId != null){
            Boolean isTractor = false;
            String dealNumber;
            this.loanAppId = loanAppId;
            this.ObjReqPR=new ObjReqPR();
            List<Applicant__c> aepsApplicants = new List<Applicant__c>();
            //get Opportunity Details
            Opportunity opptyDetails = [Select Id,IModuleId__c,Employee_No__c,DSM_Incentive1__c,Agent_BL_code__c,DSM_Name1__c,DSM_Incentive2__c,DSM_Name2__c,DSA_pay__c, Deal_Number__c, Customer_Code__c, Application_number__c, Vehicle_Type__c, LTV__c, Invoice__c,Vehicle_Sub_Category__c, Funding_on_Ex_Showroom__c, Funding_on_ORP__c, Required_ROI__c,Advance_EMI__c, Imputed_IRR__c, Net_LTV__c, Gross_LTV__c, Basic_Price__c,RTO_Road_Tax__c, RTO_Road_Tax_New__c, X1st_yr_Insurance_Premium__c, Other_Charges__c, GST_Amount__c, NOC_Number__c,Finance_Amount__c, Product_Type__c, Discount_on_Basic_Price__c, Total_Funded_Premium__c, Parent_Deal_number__c, LeadSource,Lead_number__c,Performance_Upgrade__c,FAME_Subsidy__c,Existing_Motor_Insurance_Premium__c,Insurance_business_done_by__c,Application_Type__c,CreatedBy.EmployeeNumber From Opportunity Where Id =:loanAppId LIMIT 1 ];// added LeadSource,Lead_number__c for Ola Integration changes & OLA-107 & OLA-124
            List<Applicant__c> proposalList = [SELECT Applicant_Type__c,AepS_Info__c,Who_will_repay_the_loan__c FROM Applicant__c WHERE Opportunity__c =: loanAppId AND Who_will_repay_the_loan__c != null AND In_Active_Applicant__c = false]; 
            if(proposalList.size() > 0){
                aepsApplicants = [SELECT Applicant_Type__c,AepS_Info__c FROM Applicant__c WHERE Opportunity__c =: loanAppId AND Applicant_Type__c=:proposalList[0].Who_will_repay_the_loan__c AND In_Active_Applicant__c = false LIMIT 1]; 
            }
            isTractor = opptyDetails != null ? (opptyDetails.Product_Type__c == System.Label.Tractor ? true : false) : false; 
            //get Applicant__c details
            List<Applicant__c> applicantDetailsList = PactLmsRequestHelper.getApplicantsDetails(loanAppId, dealId, isTractor);
            Applicant__c borrowerDetails = new Applicant__c();
            Applicant__c coBorrowerDetails = new Applicant__c();
            Applicant__c guarantorDetails = new Applicant__c();     //SFTRAC-1964
            List<Applicant__c> coBorrowerDetailList = new List<Applicant__c>();     //SFTRAC-1964
            PactLmsRequestHelper.objRequestLead objRequestLeadRec = new PactLmsRequestHelper.objRequestLead();
            dealNumber = PactLmsRequestHelper.getDealNumber(opptyDetails, dealId, isTractor);
            objRequestLeadRec.Deal_no = dealNumber;
            objRequestLeadRec.Application_No = opptyDetails.Application_number__c;
            objRequestLeadRec.Lead_No = opptyDetails.Lead_number__c;
            if(opptyDetails.LeadSource == 'OLA'){
                objRequestLeadRec.Subsidy_Amt = String.valueOf(opptyDetails.FAME_Subsidy__c);//OLA-124
                }else{
                    objRequestLeadRec.Subsidy_Amt ='';//OLA-124 
                }

            List<PactLmsRequestHelper.objRequestLead> objRequestLead = new List<PactLmsRequestHelper.objRequestLead>();
            objRequestLead.add(objRequestLeadRec);
            //objRequestLead = objRequestLead;
            this.ObjReqPR.objRequestLead = objRequestLead;
            List<PactLmsRequestHelper.ObjConsentInfo> objConsentInfoList = new List<PactLmsRequestHelper.ObjConsentInfo>();
            objConsentInfoList = PactLmsRequestHelper.getObjConsentInfoList(applicantDetailsList, opptyDetails, isTractor); //SFTRAC-1964 added isTractor
            for(Applicant__c applicant : applicantDetailsList){
                if(applicant.Applicant_Type__c == Label.Borrower){
                    borrowerDetails = applicant;
                }else if(applicant.Applicant_Type__c == Label.CoBorrower){
                    coBorrowerDetails = applicant;
                    coBorrowerDetailList.add(applicant);    //SFTRAC-1964
                }else if(applicant.Applicant_Type__c == Label.Guarantor && isTractor == true){ //SFTRAC-1964
                    guarantorDetails = applicant;
                }//SFTRAC-1964 end
            }
            this.ObjReqPR.ObjConsentInfo = objConsentInfoList;
            //end - CISP-135
            
            //get Vehicle_Detail__c
            List<Vehicle_Detail__c> vehDetailList = PactLmsRequestHelper.getVehicleDetails(loanAppId, dealId, isTractor);

            
            //get LoanDisbursementDetails__c
            List<LoanDisbursementDetails__c> loanDisbursDetailList = new List<LoanDisbursementDetails__c>([Select Id,Total_Adjustment_Amount__c,Borrower_Name__c,CoBorrower_Name__c,Borrower_DOB__c,CoBorrower_DOB__c,Borrower_Relationship__c,CoBorrower_Relationship__c,Borrower_Address__c,Vehicle_Sold_By__c, CoBorrower_Address__c,RSD__c,Borrower_Mother_DOB__c,CoBorrower_Mother_DOB__c, Marked_On__c, CoBorrower_Father_DOB__c,CoBorrower_X3rd_Child_Name__c,CoBorrower_X3rd_Child_Gender__c, Bank_Ben_Code__c, CoBorrower_X3rd_Child_DOB__c,Insurer__c,CoBorrower_X2nd_Child_Name__c,CoBorrower_X2nd_Child_Gender__c,CoBorrower_X2nd_Child_DOB__c,CoBorrower_Spouse_Gender__c,CoBorrower_Spouse_DOB__c,CoBorrower_X1st_Child_Name__c,CoBorrower_X1st_Child_Gender__c,CoBorrower_X1st_Child_DOB__c,Borrower_Father_DOB__c,Borrower_X3rd_Child_Name__c,Borrower_X3rd_Child_Gender__c,Borrower_X3rd_Child_DOB__c,Borrower_X2nd_Child_Name__c,Borrower_X2nd_Child_Gender__c,Borrower_X2nd_Child_DOB__c,Borrower_Spouse_Gender__c,Borrower_Spouse_DOB__c,Borrower_X1st_Child_Name__c,Borrower_X1st_Child_Gender__c,Borrower_X1st_Child_DOB__c,Beneficiary_1_Account_Number__c,Beneficiary_1__c,Beneficiary_1_Amount__c,Beneficiary_2__c,Beneficiary_2_Account_Number__c,Beneficiary_2_Amount__c,Beneficiary_3__c,Beneficiary_3_Account_Number__c,Beneficiary_3_Amount__c,Payment_Originated_From__c,Total_beneficiary_amount__c,DSA_Name__c,Vehicle_Delivered__c,RTA_taxes_remitted_upto__c,Fund_End_Use__c, Business_Sourced_By__c, Business_Done_By__c,Balance_Transfer_Amount_in_Rs__c,Do_To_be_authorized_by__c,Collection_Executive__c,Purchase_doc_catq__c,X1st_Yr_Insurance_premium_paid_by__c,Seller_Bank_Branch_Name__c,Seller_Bank_Branch_Pincode__c,Name_transferred__c,Current_vehicle_owner__c,Lien_marked_IBL__c,Engine_no__c,Chassis_no__c,Vehicle_Registered_in_Name__c,Long_term_policy_Own_Damage_Yrs__c,Dealer_Payment__c, Do_To_be_authorized_by__r.Ben_Code__c,Borrower_Insurance_business_done_by__c,FI_Done_By__c,Long_term_policy_available__c,Customer_code1__c,Customer_code2__c,Customer_code3__c,Customer_code4__c,Customer_code5__c,Customer_code6__c,Customer_code7__c,Customer_code8__c, Now_lien_in_the_name_of__c,Adjustment_Amount1__c,Adjustment_Amount2__c,Adjustment_Amount3__c,Adjustment_Amount4__c,Adjustment_Amount5__c,Adjustment_Amount6__c,Adjustment_Amount7__c,Adjustment_Amount8__c,Adjustment_Deal_Number1__c,Adjustment_Deal_Number2__c,Adjustment_Deal_Number3__c,Adjustment_Deal_Number4__c,Adjustment_Deal_Number5__c,Adjustment_Deal_Number6__c,Adjustment_Deal_Number7__c,Adjustment_Deal_Number8__c,FifthYr_Own_Damage_Premium__c,FirstYr_Own_Damage_Premium__c,FourthYr_Own_Damage_Premium__c,SecondYr_Own_Damage_Premium__c,ThirdYr_Own_Damage_Premium__c,FifthYr_Third_Party_Premium__c,FirstYr_Third_Party_Premium__c,FourthYr_Third_Party_Premium__c,SecondYr_Third_Party_Premium__c,ThirdYr_Third_Party_Premium__c,GST__c,Seller_Bank_name__c,Seller_Account_number__c,Seller_Bank_IFSC_Code__c,Beneficiary_1_Type__c, Beneficiary_2_Type__c, Beneficiary_3_Type__c,Payment_to_co_borrower__c,Registration_Number__c From LoanDisbursementDetails__c Where Parent_Loan_Application__c =:loanAppId AND  Deal_Number__c=:dealId ]);
            
            List<Documents__c> loanDocumentList = new List<Documents__c>();
            if(isTractor){
                loanDocumentList = [Select Id, Applicant__c, Document_Type__c, Invoice_amount__c, Opportunity_Relation__c,Invoice_number__c,Invoice_date__c,Seller_Bank_name__c,Seller_Account_number__c,IHM_amount_as_per_receipt__c,IHM_receipt_date__c,IHM_receipt_number__c From Documents__c Where Opportunity_Relation__c =:loanAppId AND Opportunity_Relation__c =:loanAppId AND Document_Type__c != null AND is_Active__c = true AND (Vehicle_Detail__c = null OR Vehicle_Detail__r.Deal_Number__c =: dealId)];
            }else{
                loanDocumentList = [Select Id, Applicant__c, Document_Type__c, Invoice_amount__c, Opportunity_Relation__c,Invoice_number__c,Invoice_date__c,Seller_Bank_name__c,Seller_Account_number__c,IHM_amount_as_per_receipt__c,IHM_receipt_date__c,IHM_receipt_number__c From Documents__c Where Opportunity_Relation__c =:loanAppId AND Opportunity_Relation__c =:loanAppId AND Document_Type__c != null AND is_Active__c = true];
            }
            
            Documents__c invoiceDoc = new Documents__c();
            Documents__c sellerBankDoc = new Documents__c();
            List<Documents__c> IHMRecieptDoc = new List<Documents__c>();
            Set<Id> docIdSet = new Set<Id>();
            for(Documents__c loanDoc : loanDocumentList){
                docIdSet.add(loanDoc.Id);
                if(loanDoc.Document_Type__c == 'Invoice'){
                    invoiceDoc = loanDoc;
                } else if(loanDoc.Document_Type__c != null && loanDoc.Document_Type__c.contains('Seller')){
                    sellerBankDoc = loanDoc;
                } else if(loanDoc.Document_Type__c == 'IHM Receipt'){
                    IHMRecieptDoc.add(loanDoc);
                }
            }
            //get Final_Term__c
            List<Final_Term__c> finalTermList =  PactLmsRequestHelper.getFinalTermDetails(loanAppId, dealId, isTractor);
            
            //get Loan_Agreement__c
            List<Loan_Agreement__c> loanAgreementList =  new List<Loan_Agreement__c>([Select Id,Total_Loan_Agreement_Stamp_Value__c,Ist_EMI_Due_Date__c,Geo_State_Code__c,Agreement_Type__c, X2nd_EMI_Due_Date__c, Agreement_Booklet_Num__c From Loan_Agreement__c Where Loan_Application__c =:loanAppId AND Deal_Number__c =: dealId]); 
            //get Invoice_Details__c
            List<Invoice_Details__c> invoiceDetailsList =  new List<Invoice_Details__c>([Select Id,Type_of_Invoice__c,CGST__c,SGST__c,UTGST__c,IGST__c,CESS__c,HSN_No__c, Dealer_Name__c, Main_Dealer__c,Payment_to_be_made__c,Invoice_Amount_incl_discounts__c, Ben_Code_Of_Main_dealer__c From Invoice_Details__c Where Loan_Application__c =:loanAppId AND Deal_Number__c =: dealId ]); 
            PactLmsRequestHelper pacthelp=new PactLmsRequestHelper(loanAppId,opptyDetails,vehDetailList,loanDisbursDetailList,applicantDetailsList,finalTermList,invoiceDetailsList,borrowerDetails,coBorrowerDetails,dealNumber); //For The CISP-3564 Called Here.                                                                
            //get IHM__c
            List<IHM__c> IHMList =  new List<IHM__c>([Select Id,SA_Account_Opening_Charges__c,Total_amount_paid_to_bank__c,Margin_money_to_be_deducted_from_disburs__c,Total_amount_to_be_paid_by_customer_G__c, Valuation_charges_D__c, IHM_Recovery__c, Valuation_Charges_Borne_By__c, Total_IHM_paid_to_dealer_A__c From IHM__c Where Loan_Application__c =:loanAppId AND Deal_Number__c =: dealId]); 
            //get CASA_Bank_Form__c
            List<CASA_Bank_Form__c> casaBankFormList =  new List<CASA_Bank_Form__c>([Select Id,Nominee_available__c,Applicant__c, Applicant__r.Applicant_Type__c, Applicant__r.Name, Nominee_name__c,Relationship_with_borrower__c,Nominee_address__c,Nominee_City__c,Nominee_State__c,Nominee_pin_code__c,Nominee_DOB__c,Saving_Account_opening_form_No__c,Finacle_City__c,Finacle_City__r.Name,Geo_State_Master__c,Geo_State_Master__r.Name  From CASA_Bank_Form__c Where Loan_Application__c =:loanAppId ]);
            List<CASA_Bank_Form__c> cobcasaBankFormList =  new List<CASA_Bank_Form__c>();
            if (coBorrowerDetails != null)
                cobcasaBankFormList = [Select Id,Nominee_name__c,Saving_Account_opening_form_No__c  From CASA_Bank_Form__c Where Applicant__c =:coborrowerDetails.Id ];
            
            //get repaymentsList
            List<Repayments__c> repaymentsList =  new List<Repayments__c>([Select Id,IFSC_Code__c,Account_Number__c,Bank_Master__r.Name,Repayment_Method__c  From Repayments__c Where Loan_Application__c =:loanAppId AND Deal_Number__c=:dealId]);//CISP-2400
            
            //get TeleVerificationList
            List<TeleVerification__c> TeleVerificationList =  new List<TeleVerification__c>([Select Id,Is_customer_using_Aadhar_Linked_Mob_No__c,Is_customer_s_Mob_No_linked_to_Aadhar__c  From TeleVerification__c Where Applicant__c =:borrowerDetails.Id ]);
            List<TeleVerification__c> cobTeleVerificationList =  new List<TeleVerification__c>();
            if (coborrowerDetails != null)
                cobTeleVerificationList = [Select Id,Is_customer_using_Aadhar_Linked_Mob_No__c,Is_customer_s_Mob_No_linked_to_Aadhar__c  From TeleVerification__c Where Applicant__c =:coborrowerDetails.id ];
            
            //get InsuranceDetails__c
            List<InsuranceDetails__c> insuranceDetailsList =  new List<InsuranceDetails__c>();
            if(isTractor){
                insuranceDetailsList = [Select Id,Name, Amount__c,Applicant__r.Name,Applicant__r.Applicant_Type__c,Funded_Non_funded__c,Product_Type__c,Funded_Premium__c,Insurance_Plan__c,Combo_LI_Premium__c,Combo_EMI_Premium__c,EMI_Passed_in_API__c,Applicant__r.Nominee_address__c,Applicant__r.Nominee_Relationship__c,Applicant__r.Nominee_DOB__c,Applicant__r.Nominee_name__c From InsuranceDetails__c Where Loan_Application__c =:loanAppId AND Vehicle_Detail__r.Deal_Number__c =: dealId];
            }else{
                insuranceDetailsList = [Select Id,Name, Amount__c,Applicant__r.Name,Applicant__r.Applicant_Type__c,Funded_Non_funded__c,Product_Type__c,Funded_Premium__c,Insurance_Plan__c,Combo_LI_Premium__c,Combo_EMI_Premium__c,EMI_Passed_in_API__c From InsuranceDetails__c Where Loan_Application__c =:loanAppId];
            }
            Decimal fundedPremium = 0; 
            for(InsuranceDetails__c insDet : insuranceDetailsList){
                if(insDet.Funded_Non_funded__c == 'Funded'){
                    fundedPremium = fundedPremium + insDet.Amount__c;
                }
            }

            String hasGPA = 'N';
            String hasHealthInsu = 'N';
            String hasComboInsu = 'N';
            String hasMotorInsu = 'N';
            String hasFlexiInsu = 'N';
            String hasLIEMIInsu = 'N';
            String hasTATAEMIInsu = 'N';
            String hasLIInsu = 'N';
            InsuranceDetails__c GPAInsurance = new InsuranceDetails__c();
            InsuranceDetails__c healthInsurance = new InsuranceDetails__c();
            InsuranceDetails__c comboInsurance = new InsuranceDetails__c();
            InsuranceDetails__c motorInsurance = new InsuranceDetails__c();
            InsuranceDetails__c flexiInsurance = new InsuranceDetails__c();
            InsuranceDetails__c liEMIInsurance = new InsuranceDetails__c();
            InsuranceDetails__c tataEMIInsurance = new InsuranceDetails__c();
            InsuranceDetails__c liInsurance = new InsuranceDetails__c();
            String hasGPAForCob = 'N';
            String hasHealthInsuForCob = 'N';
            String hasComboInsuForCob = 'N';
            String hasMotorInsuForCob = 'N';
            String hasFlexiInsuForCob = 'N';
            String hasLIEMIInsuForCob = 'N';
            String hasTATAEMIInsuForCob = 'N';
            String hasLIInsuForCob = 'N';
            InsuranceDetails__c GPAInsuranceForCob = new InsuranceDetails__c();
            InsuranceDetails__c healthInsuranceForCob = new InsuranceDetails__c();
            InsuranceDetails__c comboInsuranceForCob = new InsuranceDetails__c();
            InsuranceDetails__c motorInsuranceForCob = new InsuranceDetails__c();
            InsuranceDetails__c flexiInsuranceForCob = new InsuranceDetails__c();
            InsuranceDetails__c liEMIInsuranceForCob = new InsuranceDetails__c();
            InsuranceDetails__c tataEMIInsuranceForCob = new InsuranceDetails__c();
            InsuranceDetails__c liInsuranceForCob = new InsuranceDetails__c();
            Boolean insurer = false;
            Boolean insurerG = false;
            for(InsuranceDetails__c loanIns : insuranceDetailsList){
                if(loanIns.Applicant__r.Applicant_Type__c == Label.Borrower || loanIns.Applicant__r.Applicant_Type__c == Label.Beneficiary){
                    if(loanIns.Name == 'GPA'){
                        hasGPA = 'Y';
                        GPAInsurance = loanIns;
                    } else if(loanIns.name == 'HEALTH'){
                        hasHealthInsu = 'Y';
                        healthInsurance = loanIns;
                    } else if(loanIns.name == 'COMBO'){
                        hasComboInsu = 'Y';
                        comboInsurance = loanIns;
                    } else if(loanIns.name == 'MOTOR'){
                        hasMotorInsu = 'Y';
                        motorInsurance = loanIns;
                    }else if(loanIns.name == 'FLEXI'){
                        hasFlexiInsu = 'Y';
                        flexiInsurance = loanIns;
                    }else if(loanIns.name == 'LI_EMI'){
                        hasLIEMIInsu = 'Y';
                        liEMIInsurance = loanIns;
                    }else if(loanIns.name == 'TATA_EMI'){
                        hasTATAEMIInsu = 'Y';
                        tataEMIInsurance = loanIns;
                    }else if(loanIns.name == 'LI'){
                        hasLIInsu = 'Y';
                        liInsurance = loanIns;
                    }
                    if(isTractor && (loanIns.Insurance_Plan__c == 'LI_GPA_5L4Y' || loanIns.Insurance_Plan__c == 'LI_GPA_2L4Y' || loanIns.Insurance_Plan__c == 'LI_EMI' || loanIns.Insurance_Plan__c == 'LI_SHUBH' || loanIns.Insurance_Plan__c == 'LI')){
                        insurer = true;
                    }
                } else if(loanIns.Applicant__r.Applicant_Type__c == Label.CoBorrower){
                    if(loanIns.Name == 'GPA'){
                        hasGPAForCob = 'Y';
                        GPAInsuranceForCob = loanIns;
                    } else if(loanIns.name == 'HEALTH'){
                        hasHealthInsuForCob = 'Y';
                        healthInsuranceForCob = loanIns;
                    } else if(loanIns.name == 'COMBO'){
                        hasComboInsuForCob = 'Y';
                        comboInsuranceForCob = loanIns;
                    } else if(loanIns.name == 'MOTOR'){
                        hasMotorInsuForCob = 'Y';
                        motorInsuranceForCob = loanIns;
                    }else if(loanIns.name == 'FLEXI'){
                        hasFlexiInsuForCob = 'Y';
                        flexiInsuranceForCob = loanIns;
                    }else if(loanIns.name == 'LI_EMI'){
                        hasLIEMIInsuForCob = 'Y';
                        liEMIInsuranceForCob = loanIns;
                    }else if(loanIns.name == 'TATA_EMI'){
                        hasTATAEMIInsuForCob = 'Y';
                        tataEMIInsuranceForCob = loanIns;
                    }else if(loanIns.name == 'LI'){
                        hasLIInsuForCob = 'Y';
                        liInsuranceForCob = loanIns;
                    }
                    if(isTractor && (loanIns.Insurance_Plan__c == 'LI_GPA_5L4Y' || loanIns.Insurance_Plan__c == 'LI_GPA_2L4Y' || loanIns.Insurance_Plan__c == 'LI_EMI' || loanIns.Insurance_Plan__c == 'LI_SHUBH' || loanIns.Insurance_Plan__c == 'LI')){
                        insurerG = true;
                    }
                }
            }
            
            //get cibilDetailsList
            List<CIBIL_Details__c> cibilDetailsList =  new List<CIBIL_Details__c>([Select Id,CIC_No__c From CIBIL_Details__c Where Applicant__c =:borrowerDetails.Id ]);
            
            //get cobcibilDetailsList
            List<CIBIL_Details__c> cobcibilDetailsList = new List<CIBIL_Details__c>();
            if (coborrowerDetails != null)
             cobcibilDetailsList = [Select Id,CIC_No__c From CIBIL_Details__c Where Applicant__c =:coborrowerDetails.Id ];
            List<Structered_EMI__c> structuredEmiList= new List<Structered_EMI__c>();
            if(isTractor){
               structuredEmiList=new List<Structered_EMI__c>([Select Id,From_Month__c,To_Month__c,Number_of_Installments__c,EMI_Amount__c,Opening_Principal__c,Closing_Principal__c,Interest_Component__c,EMI_Due_Date__c,Principal_Component__c From Structered_EMI__c Where Loan_Application__c =:loanAppId AND Vehicle_Detail__c=:vehDetailList[0].Id]);
            }else{
                structuredEmiList =  new List<Structered_EMI__c>([Select Id,From_Month__c,To_Month__c,Number_of_Installments__c,EMI_Amount__c,Opening_Principal__c,Closing_Principal__c,Interest_Component__c,EMI_Due_Date__c,Principal_Component__c From Structered_EMI__c Where Loan_Application__c =:loanAppId ]);
            }
            List<Case> caseList = new List<Case>([Select Id, OwnerId, Subject From Case Where Loan_Application__c =:loanAppId ]);
            
            List<PactLmsRequestHelper.ObjRFDList> objRFDList = new List<PactLmsRequestHelper.ObjRFDList>();
            PactLmsRequestHelper.ObjRFDList ObList = new PactLmsRequestHelper.ObjRFDList();
            ObList.Reference_No= dealNumber;
            ObList.Reference_Description= borrowerDetails.Name;
            ObList.Customer_Code= borrowerDetails.Customer_Code__c;
            ObList.Reference_Type='H';
            ObList.Product= vehDetailList.size() > 0 && vehDetailList[0].Loan_Application__r.Product_Type__c == 'Two Wheeler' ? 'H' : vehDetailList[0].Loan_Application__r.Product_Type__c == System.Label.Tractor ? 'T' : 'C';
            ObList.Bl_Code= opptyDetails.Agent_BL_code__c;
            ObList.Active_Flag='Y';
            ObList.Maker_Id = Integer.valueOf(IntegrationUtilities.getMakerId()) ;
            ObList.Maker_Date= String.valueOf(Datetime.now());
            objRFDList.add(ObList);
            ObjRFDList=objRFDList;
            this.ObjReqPR.ObjRFDList=ObjRFDList;
            Map<string,string> vehType = new Map<string,string>{
                'New' => 'N',
                'Used' => 'U',
                'Refinance' => 'R'
            };
            //mapping for ObjPRList
            List<PactLmsRequestHelper.ObjPRList> ObjPRList = new List<PactLmsRequestHelper.ObjPRList>();
            PactLmsRequestHelper.ObjPRList ObprList = new PactLmsRequestHelper.ObjPRList();
            ObprList.Deal_No = dealNumber;
            ObprList.Product= vehDetailList.size() > 0 && vehDetailList[0].Loan_Application__r.Product_Type__c == 'Two Wheeler' ? 'H' : vehDetailList[0].Loan_Application__r.Product_Type__c == System.Label.Tractor ? 'T' : 'C';
            ObprList.Application_No = opptyDetails.Application_number__c;
            ObprList.Payment_Source = loanDisbursDetailList.size() > 0 ? loanDisbursDetailList[0].Payment_Originated_From__c : '';
            ObprList.Customer_Code = borrowerDetails.Customer_Code__c;
            ObprList.Guarantor_Available = applicantDetailsList.size() > 1 ? 'Y' : 'N';
            //ObprList.Guarantor_Name= applicantDetailsList.size() > 1 ? coBorrowerDetails.Name : '';
            if(isTractor && !coBorrowerDetailList.isEmpty()){   //SFTRAC-1964
                ObprList.Guarantor_Name = coBorrowerDetailList[0].Name;
            }else{
            ObprList.Guarantor_Name= applicantDetailsList.size() > 1 ? coBorrowerDetails.Name : '';
            }
            if(aepsApplicants.size() > 0 && aepsApplicants[0].AepS_Info__c!=null){
                if(aepsApplicants[0].AepS_Info__c=='Yes'){
                    ObprList.AEPS = 'E';
                }else{
                    ObprList.AEPS = 'D';
                }
            }else{
                ObprList.AEPS ='';
            }
            List<Product2> prodList = new List<Product2>();    
            if(vehDetailList.size() > 0 && (vehDetailList[0].Variant__c != null || vehDetailList[0].Variant_Code__c != null)){//CISP-2794
                prodList = [Select Id, Variant_Code__c from Product2 where IsActive = true and (Name =: vehDetailList[0].Variant__c OR Variant_Code__c =:vehDetailList[0].Variant_Code__c ) and Type__c = 'Variant'] ;//CISP-2794
            }           
            ObprList.Product_Variant=  prodList.size() > 0 && prodList[0].Variant_Code__c != null ? prodList[0].Variant_Code__c : '';
            ObprList.Fully_Built= 'Y';
            ObprList.RTO_Registered= '';
            ObprList.Vehicle_Category = vehType.get(opptyDetails.Vehicle_Type__c);
            ObprList.Vehicle_Sub_Category= opptyDetails.Vehicle_Type__c == 'New' ? 'New' : (isTractor == true &&  vehDetailList.size() > 0) ? vehDetailList[0].Vehicle_SubCategory__c : opptyDetails.Vehicle_Sub_Category__c;
            ObprList.Old_Deal_No= (isTractor == true &&  vehDetailList.size() > 0) ? vehDetailList[0].Parent_Deal_Number__c == null ? '' : vehDetailList[0].Parent_Deal_Number__c : opptyDetails.Parent_Deal_number__c!=null ? opptyDetails.Parent_Deal_number__c : '';
            String soldByDealer = '';
            if(opptyDetails.Vehicle_Type__c == 'New' || ObprList.Vehicle_Sub_Category == 'UPD' || ObprList.Vehicle_Sub_Category == 'UEB'){
                soldByDealer = vehDetailList.size() > 0 &&  vehDetailList[0].Ben_Code__c != null ? vehDetailList[0].Ben_Code__c : '';
            }
            else if(ObprList.Vehicle_Sub_Category == 'RLN' || ObprList.Vehicle_Sub_Category == 'RLY' || ObprList.Vehicle_Sub_Category == 'UIM'){
                soldByDealer = 'PAYTOCUST';
            }
            else if(ObprList.Vehicle_Sub_Category == 'UPO' || ObprList.Vehicle_Sub_Category == 'UPB' || ObprList.Vehicle_Sub_Category == 'UOM' || ObprList.Vehicle_Sub_Category == 'UOB' || ObprList.Vehicle_Sub_Category == 'URS' || ObprList.Vehicle_Sub_Category == 'URV'){
                soldByDealer = 'UVHSELLER';
            }

            String mainDealerBenCode = PactLmsRequestHelper.getMainDealerBenCode(invoiceDetailsList,opptyDetails);
            
            ObprList.Sold_By_Dealer= soldByDealer;            
            ObprList.Main_Dealer= mainDealerBenCode;
            string bSourceMakerId= '';
            id bSourceById = loanDisbursDetailList.size() > 0 ? loanDisbursDetailList[0].Business_Sourced_By__c : null;
            if(bSourceById != null && bSourceById.getSObjectType().getDescribe().getName() == 'User'){
                List<User> sourceByUserList = new List<User>([Select Id, UserName, EmployeeNumber, Maker_Id__c From User Where Id =:bSourceById WITH SECURITY_ENFORCED]);
                bSourceMakerId =  sourceByUserList.size() > 0 && sourceByUserList[0].EmployeeNumber != null ? sourceByUserList[0].EmployeeNumber : '';//CISP-2680
            }
            ObprList.Business_Sourced_By= bSourceMakerId;
            string bDoneMakerId= '';
            id bDoneById = loanDisbursDetailList.size() > 0 ? loanDisbursDetailList[0].Business_Done_By__c : null;
            if(bDoneById != null && bDoneById.getSObjectType().getDescribe().getName() == 'User'){
                List<User> busDoneByUserList = new List<User>([Select Id, UserName, EmployeeNumber, Maker_Id__c From User Where Id =:bDoneById WITH SECURITY_ENFORCED]);
                bDoneMakerId =  busDoneByUserList.size() > 0 && busDoneByUserList[0].EmployeeNumber != null ? busDoneByUserList[0].EmployeeNumber : '';//CISP-2680
            }
            ObprList.Business_Done_By= bDoneMakerId;
            string fiDoneMakerId= '';
            id fiDoneById = loanDisbursDetailList.size() > 0 ? loanDisbursDetailList[0].FI_Done_By__c : null;
            if(fiDoneById != null && fiDoneById.getSObjectType().getDescribe().getName() == 'User'){
                List<User> fiDoneByUserList = new List<User>([Select Id, UserName, EmployeeNumber, Maker_Id__c From User Where Id =:fiDoneById WITH SECURITY_ENFORCED]);
                fiDoneMakerId = fiDoneByUserList.size() > 0 && fiDoneByUserList[0].EmployeeNumber != null ? fiDoneByUserList[0].EmployeeNumber : '';//CISP-2680
            }
            ObprList.FI_Done_By= fiDoneMakerId;
            ObprList.Approved_By= '';
            ObprList.Approval_No= dealNumber;
            if(isTractor){
                ObprList.Invoice_Category = 'O';
            }else{
                ObprList.Invoice_Category= opptyDetails.Funding_on_Ex_Showroom__c ? 'B' : opptyDetails.Funding_on_ORP__c ? 'O' : '';
            }
            Double invoiceAmo  = 0;
            if(invoiceDetailsList.size() > 0){
                invoiceAmo = invoiceDetailsList[0].Invoice_Amount_incl_discounts__c == null ? 0 : invoiceDetailsList[0].Invoice_Amount_incl_discounts__c; // + ( opptyDetails.Other_charges__c == null ? 0 : opptyDetails.Other_charges__c);
            }
            ObprList.Invoice_Amt = invoiceAmo;
            if(isTractor && opptyDetails.Application_Type__c == 'Build Body and Chassis Funding'){
                ObprList.Invoice_Amt_Chasis = finalTermList.size() > 0 && finalTermList[0].Funding_for_Chassis__c != null ? (Integer)finalTermList[0].Funding_for_Chassis__c : 0;
                ObprList.Invoice_Amt_Body= finalTermList.size() > 0 && finalTermList[0].Funding_for_Body__c != null ? (Integer)finalTermList[0].Funding_for_Body__c : 0;
            }else{
                ObprList.Invoice_Amt_Chasis = invoiceAmo;
                ObprList.Invoice_Amt_Body= 0;
            }
            ObprList.Sales_Value= vehDetailList.size() > 0 &&   vehDetailList[0].Selling_Price__c != null ? vehDetailList[0].Selling_Price__c : 0;
            if(opptyDetails.Vehicle_Type__c == 'New'){
                ObprList.Market_Value= 0;
            }
            else{
                ObprList.Market_Value= vehDetailList.size() > 0 && vehDetailList[0].Base_Prices__c!=null ? Integer.valueOf(vehDetailList[0].Base_Prices__c):0;
            } 
            
            ObprList.Balance_Transfer_Amt= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Balance_Transfer_Amount_in_Rs__c != null ? loanDisbursDetailList[0].Balance_Transfer_Amount_in_Rs__c : 0;
            ObprList.Mfg_Month= vehDetailList.size() > 0 && vehDetailList[0].Manufacturer_Year_Month__c != null ? Integer.valueOf(vehDetailList[0].Manufacturer_Year_Month__c.split('-')[1]) : 0;
            ObprList.Mfg_Year= vehDetailList.size() > 0  && vehDetailList[0].Manufacturer_Year_Month__c != null ? Integer.valueOf(vehDetailList[0].Manufacturer_Year_Month__c.split('-')[0]) : 0;
            ObprList.Fin_Amt= finalTermList.size() > 0 && finalTermList[0].Loan_Amount__c != null ? Decimal.valueOf(finalTermList[0].Loan_Amount__c) + fundedPremium : 0;
            if(isTractor && opptyDetails.Application_Type__c == 'Build Body and Chassis Funding'){
                ObprList.Fin_Amt_Chasis = finalTermList.size() > 0 && finalTermList[0].Funding_for_Chassis__c != null ? (Integer)finalTermList[0].Funding_for_Chassis__c : 0;
                ObprList.Fin_Amt_Body= finalTermList.size() > 0 && finalTermList[0].Funding_for_Body__c != null ? (Integer)finalTermList[0].Funding_for_Body__c : 0;
            }else{
                ObprList.Fin_Amt_Chasis= finalTermList.size() > 0 && finalTermList[0].Loan_Amount__c != null ? Decimal.valueOf(finalTermList[0].Loan_Amount__c) : 0;
                ObprList.Fin_Amt_Body= 0;
            }
            ObprList.GPA_Available= hasGPA;
            ObprList.Hospital_Cash_Available= 'N';
            Decimal allInstSum = 0;
            Decimal financeAmount = 0;
            Integer moratorium = Integer.valueOf(finalTermList[0].Holiday_period__c);
            Integer noOfInstalments = 0;
            if(isTractor){
                noOfInstalments = finalTermList.size() > 0  && finalTermList[0].Tenure__c != null ? (Integer)finalTermList[0].No_of_Installment__c : 0;
            }else{
                if(moratorium != null && moratorium != 0 && opptyDetails.LeadSource!='OLA'){
                    noOfInstalments = finalTermList.size() > 0  && finalTermList[0].Tenure__c != null ? Integer.valueOf(finalTermList[0].Tenure__c) - 1 : 0;
                }
                else{
                    noOfInstalments = finalTermList.size() > 0  && finalTermList[0].Tenure__c != null ? Integer.valueOf(finalTermList[0].Tenure__c) : 0;
                }
            }
            financeAmount = finalTermList.size() > 0 && finalTermList[0].Loan_Amount__c != null ? Decimal.valueOf(finalTermList[0].Loan_Amount__c) + fundedPremium : 0 ;
            if(isTractor){
                allInstSum = finalTermList.size() > 0  && finalTermList[0].Offer_Agreement_Amount__c != null ? (Integer)finalTermList[0].Offer_Agreement_Amount__c : 0;
            }else{
                if(finalTermList.size() > 0 && finalTermList[0].Installment_Type__c == 'Structured'){
                    for(Structered_EMI__c structuredEmi : structuredEmiList){
                        allInstSum= allInstSum + (structuredEmi.EMI_Amount__c != null && structuredEmi.Number_of_Installments__c != null ? structuredEmi.EMI_Amount__c * structuredEmi.Number_of_Installments__c : 0);
                    }
                } else {
                    if(finalTermList.size() > 0){
                        allInstSum = allInstSum + (finalTermList[0].EMI_Amount__c != null ? finalTermList[0].EMI_Amount__c * noOfInstalments : 0);
                    }
                }
            }
            //Decimal interestCharges = allInstSum - financeAmount;
            ObprList.Interest_Rate= finalTermList.size() > 0 ? isTractor ? Double.valueof(finalTermList[0].Required_CRM_IRR__c) : finalTermList[0].CRM_IRR__c : 0;
            ObprList.Interest_Comp_Method= 'F';
            if(isTractor){
                ObprList.Periodicity = finalTermList.size() > 0 ? finalTermList[0].Installment_Frequency__c == 'Monthly' ? 'M' : finalTermList[0].Installment_Frequency__c == 'Quarterly' ? 'Q' : finalTermList[0].Installment_Frequency__c == 'Half yearly' ? 'H' : '' : '';
            }else{
                ObprList.Periodicity= 'M';
            }
            ObprList.Deal_Period= finalTermList.size() > 0 && finalTermList[0].Tenure__c != null ? Integer.valueOf(finalTermList[0].Tenure__c) : 0;
            
            
            ObprList.Instalment_Nos= noOfInstalments;
            ObprList.Moratorium= finalTermList.size() > 0 && finalTermList[0].Holiday_period__c != null ? Integer.valueOf(finalTermList[0].Holiday_period__c) : 0;
            ObprList.Advance_EMI_Nos= finalTermList.size() > 0 && finalTermList[0].Advance_EMI__c==true ? 1 : 0;
            ObprList.EMI_13_Free= 'N';
            ObprList.Rebate_Available= 'N';
            ObprList.Rebate_Per= 0;
            ObprList.Credit_Available= 'N';
            ObprList.Sec_Dep_Available= 'N';
            ObprList.IHM_Computed= IHMList.size() > 0 && opptyDetails.Vehicle_Type__c == 'New' ? IHMList[0].Total_amount_to_be_paid_by_customer_G__c : IHMList[0].Margin_money_to_be_deducted_from_disburs__c;
            ObprList.Finance_Charges= allInstSum - financeAmount; 
            ObprList.Agreement_Value= allInstSum;
            ObprList.Total_Disburse_Amt= loanDisbursDetailList.size() > 0 ? loanDisbursDetailList[0].Dealer_Payment__c : 0;
            ObprList.CRM_IRR= finalTermList.size() > 0 ? isTractor ? Double.valueof(finalTermList[0].Required_CRM_IRR__c) : finalTermList[0].CRM_IRR__c : 0;
            ObprList.Bank_IRR= finalTermList.size() > 0 && finalTermList[0].Net_IRR__c != null ? Double.valueOf(finalTermList[0].Net_IRR__c) : 0;
            ObprList.Gross_IRR= finalTermList.size() > 0 && finalTermList[0].Gross_IRR__c != null ? finalTermList[0].Gross_IRR__c : 0;
            ObprList.Imputed_IRR= finalTermList.size() > 0 && finalTermList[0].Inputted_IRR__c != null ? Double.valueOf(finalTermList[0].Inputted_IRR__c) : 0.00;
            //calculate Net LTV & Gross LTV
            Decimal grossLTV = finalTermList.size() > 0 && finalTermList[0].Calculated_Gross_LTV__c != null ? finalTermList[0].Calculated_Gross_LTV__c : 0.00;
            Decimal netLTV = finalTermList.size() > 0 && finalTermList[0].Calculated_Net_LTV__c != null ? finalTermList[0].Calculated_Net_LTV__c : 0.00; 
            Decimal basePrice = vehDetailList.size() > 0 && vehDetailList[0].Base_Prices__c!=null ? vehDetailList[0].Base_Prices__c:0;
            Decimal roadTax = opptyDetails.RTO_Road_Tax_New__c!=null?opptyDetails.RTO_Road_Tax_New__c:0;
            Decimal istInsurancePremium = opptyDetails.X1st_yr_Insurance_Premium__c!=null?opptyDetails.X1st_yr_Insurance_Premium__c:0;
            Decimal otherCharges = opptyDetails.Other_charges__c!=null?opptyDetails.Other_charges__c:0;
            Decimal PerformanceUpgrade = opptyDetails.Performance_Upgrade__c!=null?opptyDetails.Performance_Upgrade__c:0;//OLA-107
            Decimal gstAmount = opptyDetails.GST_Amount__c!=null?opptyDetails.GST_Amount__c:0;
            Decimal discount = opptyDetails.Discount_on_Basic_Price__c!=null?opptyDetails.Discount_on_Basic_Price__c:0;
            Decimal totalFundedInsurancePremium = opptyDetails.Total_Funded_Premium__c!=null?opptyDetails.Total_Funded_Premium__c:0;
            Decimal finalLoanAmount = finalTermList[0].Loan_Amount__c!=null?Decimal.valueOf(finalTermList[0].Loan_Amount__c)+totalFundedInsurancePremium:totalFundedInsurancePremium;
            ObprList.Net_LTV= finalTermList.size() > 0 && finalTermList[0].Calculated_Net_LTV__c != null ? finalTermList[0].Calculated_Net_LTV__c : 0.00;
            ObprList.Gross_LTV=finalTermList.size() > 0 && finalTermList[0].Calculated_Gross_LTV__c != null ? finalTermList[0].Calculated_Gross_LTV__c : 0.00;
            //ObprList.Gross_LTV= opptyDetails.Gross_LTV__c != null ? opptyDetails.Gross_LTV__c : 0.00 ;
             //CISP:2494
            ObprList.Payment_To= loanDisbursDetailList[0].Payment_to_co_borrower__c==true ? 'G': 'C';
            ObprList.Maker_ID= Integer.valueOf(IntegrationUtilities.getMakerId());
            ObprList.Maker_Date= String.valueOf(system.today());
            if(isTractor == true){
                //SFTRAC-1964 start
                if ((guarantorDetails.Id != null) && (coBorrowerDetailList == null || coBorrowerDetailList.isEmpty())) {
                    ObprList.Gurantor_code = guarantorDetails.Customer_Code__c != null ? guarantorDetails.Customer_Code__c : '';
                }/*else if ((guarantorDetails.Id == null) && (coBorrowerDetailList != null) && coBorrowerDetailList.size() == 1) {
                    ObprList.Gurantor_code = coBorrowerDetailList[0].Customer_Code__c != null ? coBorrowerDetailList[0].Customer_Code__c : '';
                }else if ((guarantorDetails.Id == null) && (coBorrowerDetailList != null) && coBorrowerDetailList.size() >= 2) {
                    ObprList.Gurantor_code = coBorrowerDetailList[0].Customer_Code__c != null ? coBorrowerDetailList[0].Customer_Code__c : '';
                }*/
                else if ((guarantorDetails == null) && (coBorrowerDetailList.size() > 0)) {
                    ObprList.Gurantor_code = coBorrowerDetailList[0].Customer_Code__c != null ? coBorrowerDetailList[0].Customer_Code__c : '';
                }else if ((guarantorDetails != null) && (coBorrowerDetailList.size() > 0)) {
                    ObprList.Gurantor_code = coBorrowerDetailList[0].Customer_Code__c != null ? coBorrowerDetailList[0].Customer_Code__c : '';
                }
                //SFTRAC-1964 end
            }else{
            ObprList.Gurantor_code= applicantDetailsList.size() > 1 ? coBorrowerDetails.Customer_Code__c : '';
            } 
            ObprList.Net_Disburse_Amt= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Dealer_Payment__c != null ? Integer.valueOf(loanDisbursDetailList[0].Dealer_Payment__c) : 0;
            ObprList.NOC_Status= '';
            ObprList.Waiver_Scheme_500= '';
            ObprList.Health_Available= '';
            ObprList.Deal_Date= String.valueOf(system.today());
            ObprList.First_EMI_Date= loanAgreementList.size() > 0 && loanAgreementList[0].Ist_EMI_Due_Date__c != null ? String.valueOf(loanAgreementList[0].Ist_EMI_Due_Date__c) : '';
            ObprList.Second_EMI_Date= loanAgreementList.size() > 0 && loanAgreementList[0].X2nd_EMI_Due_Date__c != null ? String.valueOf(loanAgreementList[0].X2nd_EMI_Due_Date__c) : '';
            if(isTractor){
                ObprList.Basic_Price = vehDetailList.size() > 0 && vehDetailList[0].Basic_Price__c == null ? 0 : vehDetailList[0].Basic_Price__c;
            }else{
                ObprList.Basic_Price= opptyDetails.Basic_Price__c;
            }
            ObprList.RTO_Road_Tax=  opptyDetails.RTO_Road_Tax_New__c;
            if(isTractor){
                ObprList.IYear_Ins_Prm = vehDetailList.size() > 0 && vehDetailList[0].X1st_yr_Insurance_Premium__c == null ? 0 : vehDetailList[0].X1st_yr_Insurance_Premium__c;
            }else{
                ObprList.IYear_Ins_Prm= opptyDetails.X1st_yr_Insurance_Premium__c!=null ? opptyDetails.X1st_yr_Insurance_Premium__c : 0;
            }
            if(opptyDetails.LeadSource == 'OLA'){
                ObprList.Other_Charges= opptyDetails.Other_Charges__c + PerformanceUpgrade ;  //OLA-107
            }else{
            ObprList.Other_Charges= opptyDetails.Other_Charges__c;
            }
            ObprList.Guarantor_Relation_Type= applicantDetailsList.size() > 1 ? coBorrowerDetails.Relationship_with_borrower__c : '';
            String schemeName = finalTermList.size() > 0 ? finalTermList[0].Scheme_Bank_offers__c : '';
            String schemeInfo = '';
            if(schemeName != ''){
                List<Schemes__c> schemeInfoObjList = new List<Schemes__c>([Select Id, Unique_Identifier__c From Schemes__c Where Name =:schemeName WITH SECURITY_ENFORCED]);
                schemeInfo = schemeInfoObjList.size() > 0 ? schemeInfoObjList[0].Unique_Identifier__c : '';
            }
            ObprList.Scheme_Info= schemeInfo;
            if(isTractor){
                ObprList.VAT = vehDetailList.size() > 0 && vehDetailList[0].GST_Amount__c == null ? 0 : vehDetailList[0].GST_Amount__c;
            }else{
                ObprList.VAT= opptyDetails.GST_Amount__c;
            }
            ObprList.Permit_Amt= 0;
            ObprList.ROI_perc= finalTermList.size() > 0 ? isTractor == true ? Double.valueof(finalTermList[0].Required_CRM_IRR__c) : finalTermList[0].CRM_IRR__c : 0;
            ObprList.Approval_Status= 'A';
            String collnExecDLCode = '';
            Id collnTBLMasterCodeId = loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Collection_Executive__c != null ? loanDisbursDetailList[0].Collection_Executive__c : null;
            if(collnTBLMasterCodeId != null){
                List<TBM_DL_Master__c> tbmMasterCodeList = new List<TBM_DL_Master__c>([Select Id, DL_Code__c From TBM_DL_Master__c Where Id =:collnTBLMasterCodeId WITH SECURITY_ENFORCED]);
                collnExecDLCode = tbmMasterCodeList.size() > 0 ? tbmMasterCodeList[0].DL_Code__c : '';
            }
            ObprList.Colln_Exec= collnExecDLCode;
            //SFTRAC-1964 start
            if ((guarantorDetails.Id == null) && !coBorrowerDetailList.isEmpty() && coBorrowerDetailList.size() >= 2 && isTractor == true) {
                ObprList.Addl_CB_Code = coBorrowerDetailList[1].Customer_Code__c != null ? coBorrowerDetailList[1].Customer_Code__c : '';
                ObprList.Addl_CB_Available= 'Y';
                ObprList.Addl_CB_Name= coBorrowerDetailList[1].Name != null ? coBorrowerDetailList[1].Name : '';
            }else if ((guarantorDetails.Id != null) && !coBorrowerDetailList.isEmpty() && (coBorrowerDetailList.size() == 1) && isTractor == true) {
                ObprList.Addl_CB_Code = guarantorDetails.Customer_Code__c != null ? guarantorDetails.Customer_Code__c : '';
                ObprList.Addl_CB_Available= 'Y';
                ObprList.Addl_CB_Name= guarantorDetails.Name != null ? guarantorDetails.Name : '';
            }else if ((guarantorDetails.Id != null) && !coBorrowerDetailList.isEmpty() && (coBorrowerDetailList.size() >= 2) && isTractor == true) {
                if (guarantorDetails.CreatedDate < coBorrowerDetailList[1].CreatedDate) {
                    ObprList.Addl_CB_Code = guarantorDetails.Customer_Code__c != null ? guarantorDetails.Customer_Code__c : '';
                    ObprList.Addl_CB_Available= 'Y';
                    ObprList.Addl_CB_Name= guarantorDetails.Name != null ? guarantorDetails.Name : '';
                } else if (guarantorDetails.CreatedDate > coBorrowerDetailList[1].CreatedDate) {
                    ObprList.Addl_CB_Code = coBorrowerDetailList[1].Customer_Code__c != null ? coBorrowerDetailList[1].Customer_Code__c : '';
                    ObprList.Addl_CB_Available= 'Y';
                    ObprList.Addl_CB_Name= coBorrowerDetailList[1].Name != null ? coBorrowerDetailList[1].Name : '';
                }
            }else{
            ObprList.Addl_CB_Available= '';
            ObprList.Addl_CB_Code= '';
            ObprList.Addl_CB_Name= '';
            }//SFTRAC-1964 end
            ObprList.Invoice_Type= invoiceDetailsList.size() > 0 && invoiceDetailsList[0].Type_of_Invoice__c != null ? string.valueOf(invoiceDetailsList[0].Type_of_Invoice__c) : '';
            ObprList.Invoice_No= invoiceDoc != null && invoiceDoc.Invoice_number__c != null ? string.valueOf(invoiceDoc.Invoice_number__c) : '';
            ObprList.Invoice_Date= invoiceDoc != null && invoiceDoc.Invoice_date__c != null ? string.valueOf(invoiceDoc.Invoice_date__c) : '';
            ObprList.CGST= invoiceDetailsList.size() > 0 ? invoiceDetailsList[0].CGST__c : 0;
            ObprList.SGST= invoiceDetailsList.size() > 0 ? invoiceDetailsList[0].SGST__c : 0;
            ObprList.UTGST= invoiceDetailsList.size() > 0 ? invoiceDetailsList[0].UTGST__c : 0;
            ObprList.IGST= invoiceDetailsList.size() > 0 ? invoiceDetailsList[0].IGST__c : 0;
            ObprList.CESS= invoiceDetailsList.size() > 0 ? invoiceDetailsList[0].CESS__c : 0;   
            ObprList.Sale_Date= '';
            ObprList.HSN_No= invoiceDetailsList.size() > 0 && invoiceDetailsList[0].HSN_No__c != null ? String.valueOf(invoiceDetailsList[0].HSN_No__c) : '';   
            ObprList.Purchase_Doc_Catq= opptyDetails.Vehicle_Type__c != null && opptyDetails.Vehicle_Type__c == 'New' ? '' :
                loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Purchase_doc_catq__c != null ? String.valueOf(loanDisbursDetailList[0].Purchase_doc_catq__c) : ''; 
            ObprList.Org_Sale_Value= vehDetailList.size() > 0 && vehDetailList[0].Selling_Price__c != null ? vehDetailList[0].Selling_Price__c : 0; 
            ObprList.Date1= String.valueOf(System.today());
            ObprList.ROC_ID= '';
            ObprList.Version_no= '';
            ObprList.Repayment_LeadNo= proposalList.size() > 0 && proposalList[0].Who_will_repay_the_loan__c == 'Borrower' && borrowerDetails !=null ? opptyDetails.Lead_number__c + '_'+ borrowerDetails.applicant_number__c : proposalList.size() > 0 && proposalList[0].Who_will_repay_the_loan__c == 'Co-borrower' && coBorrowerDetails !=null ? opptyDetails.Lead_number__c + '_'+ coBorrowerDetails.applicant_number__c : '';
            ObprList.Repayment_By= proposalList.isEmpty() == true ? '' : proposalList[0].Who_will_repay_the_loan__c == 'Borrower' ? 'Borrower' : 'Co Borrower';
            String repaymentMode = repaymentsList.size() > 0 ? repaymentsList[0].Repayment_Method__c : '';
            ObprList.Repayment_Mode= repaymentMode;
            ObprList.Table_Code = PactLmsRequestHelper.getFinalTermsData(loanAppId,'tableCode');
            ObprList.Interest_Version_No = PactLmsRequestHelper.getFinalTermsData(loanAppId,'InterestVersionNo');
            String drInterest = PactLmsRequestHelper.getFinalTermsData(loanAppId,'DrPenalInterest');
            ObprList.Dr_Penal_Interest = drInterest != null ? Decimal.valueof(drInterest) : 0;
            ObprList.MCLR = PactLmsRequestHelper.getFinalTermsData(loanAppId,'mclrRate') != null ? Decimal.valueof(PactLmsRequestHelper.getFinalTermsData(loanAppId,'mclrRate')) : 0;
            ObjPRList.add(ObprList);
            ObjPRList=ObjPRList;
            this.ObjReqPR.ObjPRList=ObjPRList;
            
            //mapping for objPROList
            List<PactLmsRequestHelper.objPROList> objPROList = new List<PactLmsRequestHelper.objPROList>();
            PactLmsRequestHelper.objPROList ObproList = new PactLmsRequestHelper.objPROList();
            ObproList.Deal_No = dealNumber;
            //Get from Insuarnce Details
            String GPAType = hasGPA != '' && GPAInsurance.Funded_Non_funded__c == 'Funded' ? 'B' : hasGPA != '' && GPAInsurance.Funded_Non_funded__c == 'Non-Funded' ? 'C' : '';
            String gpaBusinessDoneBy = insuranceDetailsList.size() > 0 ?  loanDisbursDetailList.size() > 0 ? loanDisbursDetailList[0].Borrower_Insurance_business_done_by__c!=null ? loanDisbursDetailList[0].Borrower_Insurance_business_done_by__c.containsAny('|') ? loanDisbursDetailList[0].Borrower_Insurance_business_done_by__c.substringAfter('|').trim() : loanDisbursDetailList[0].Borrower_Insurance_business_done_by__c : null : null : '';
            if(isTractor){
                ObproList.GPA_Business_done_By = opptyDetails.CreatedBy.EmployeeNumber == null ? '' : opptyDetails.CreatedBy.EmployeeNumber;
            }else{
                ObproList.GPA_Business_done_By = opptyDetails.Product_Type__c =='Passenger Vehicles' && insuranceDetailsList.size() > 0 && opptyDetails.Insurance_business_done_by__c!=null ? opptyDetails.Insurance_business_done_by__c : gpaBusinessDoneBy;
            }
            ObproList.Credit_Days = 0;
            ObproList.Credit_Amount = 0;
            ObproList.Credit_ROI = 0;
            ObproList.Install_Pattern_Type = finalTermList.size() > 0 && finalTermList[0].Installment_Type__c == 'Structured' ? 'S' : 'A';
            ObproList.Ins_Prm_Paid_I = PactLmsRequestHelper.getInsPrePaid(loanDisbursDetailList,isTractor, hasMotorInsu, hasMotorInsuForCob);
            ObproList.Ins_Dep_Recovery_Type = '';
            if(isTractor){
                ObproList.Ins_Prm_I = hasMotorInsu == 'Y' && motorInsurance.Amount__c!=null ? motorInsurance.Amount__c : hasMotorInsuForCob == 'Y' && motorInsuranceForCob.Amount__c!=null ? motorInsuranceForCob.Amount__c : 0;   
            }else{
                ObproList.Ins_Prm_I = hasMotorInsu == 'Y' && motorInsurance.Amount__c!=null ? motorInsurance.Amount__c : 0;    
            }
            ObproList.Ins_Prm_Dep_II = 0;
            ObproList.Ins_Prm_Dep_III = 0;
            ObproList.Ins_Prm_Dep_IV = 0;
            ObproList.Ins_Prm_Dep_V = 0;
            // Decimal ihmAmt = 0;
            if(opptyDetails.Vehicle_Type__c == 'New' || opptyDetails.Vehicle_Sub_Category__c == 'UPD'){
                ObproList.IHM_Dealer_Rec_No = IHMRecieptDoc.size() > 0 && IHMRecieptDoc[0].IHM_receipt_number__c != null ? String.valueOf(IHMRecieptDoc[0].IHM_receipt_number__c) : '';
                ObproList.IHM_Dealer_Rec_Dt = IHMRecieptDoc.size() > 0 && IHMRecieptDoc[0].IHM_receipt_date__c != null ? String.valueOf(IHMRecieptDoc[0].IHM_receipt_date__c) : '';
                ObproList.IHM_Dealer_Amt = IHMList.size() > 0 ? IHMList[0].Total_IHM_paid_to_dealer_A__c : 0;
            }
            else{
                ObproList.IHM_Dealer_Amt = 0;
                ObproList.IHM_Dealer_Rec_No = '';
                ObproList.IHM_Dealer_Rec_Dt = '';
            }            
            ObproList.IHM_IBL_Rct_Amt =IHMList.size() > 0 ? IHMList[0].Total_amount_paid_to_bank__c : 0;
            ObproList.IHM_IBL_Rct_No = '0';
            ObproList.IHM_IBL_Rct_Date = '';
            ObproList.IHM_Recovery_Payment = IHMList.size() > 0 && opptyDetails.Vehicle_Type__c == 'New' ? IHMList[0].Margin_money_to_be_deducted_from_disburs__c : IHMList[0].IHM_Recovery__c;
            ObproList.PDC_Bank = '0';
            ObproList.PDC_Bank_Branch = '0';
            ObproList.PDC_ACC_No = '0';
            ObproList.PDC_Bank_PinCode = '0';
            ObproList.Seller_Bank = loanDisbursDetailList.size() > 0  ? loanDisbursDetailList[0].Seller_Bank_name__c : '';
            ObproList.Seller_Bank_Branch = loanDisbursDetailList.size() > 0 ? (loanDisbursDetailList[0].Seller_Bank_Branch_Name__c) : '';
            ObproList.Seller_Acc_No =  loanDisbursDetailList.size() > 0 != null && loanDisbursDetailList[0].Seller_Account_number__c != null ? loanDisbursDetailList[0].Seller_Account_number__c : '';
            ObproList.Seller_Bank_PinCode = loanDisbursDetailList.size() > 0 ? (loanDisbursDetailList[0].Seller_Bank_Branch_Pincode__c  ) : '';
            ObproList.Seller_IFSC_Code = loanDisbursDetailList.size() > 0 ? (loanDisbursDetailList[0].Seller_Bank_IFSC_Code__c) : '';//CISP-2553
            ObproList.GPA_Customer_Name = hasGPA == 'Y' ? loanDisbursDetailList[0].Borrower_Name__c : '';
            ObproList.GPA_Customer_DOB = hasGPA == 'Y' && loanDisbursDetailList[0].Borrower_DOB__c != null ? String.valueOf(loanDisbursDetailList[0].Borrower_DOB__c) : '';
            ObproList.Sort_Code = '';
            if(isTractor){
                ObproList.Vehicle_Reg_No = loanDisbursDetailList.size() > 0 ? (loanDisbursDetailList[0].Registration_Number__c) : '';
            }else{
                ObproList.Vehicle_Reg_No = vehDetailList.size() > 0 ? (vehDetailList[0].Vehicle_Registration_number__c) : ''; 
            }
            ObproList.Name_Transferred = loanDisbursDetailList.size() > 0 ? (loanDisbursDetailList[0].Name_transferred__c) : '';
            ObproList.Current_Owner = loanDisbursDetailList.size() > 0 ? (loanDisbursDetailList[0].Current_vehicle_owner__c) : '';
            ObproList.Lien_Marked = opptyDetails.Vehicle_Type__c != null && opptyDetails.Vehicle_Type__c == 'New' ? '' :
                loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Lien_marked_IBL__c ? 'Y' : 'N';
            ObproList.Lien_Marked_On = loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Marked_On__c != null ? String.valueOf(loanDisbursDetailList[0].Marked_On__c) : '';
            ObproList.Lien_Marked_for =  loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Now_lien_in_the_name_of__c != null ? loanDisbursDetailList[0].Now_lien_in_the_name_of__c : '';
            String policyType = '';
            if(opptyDetails.Vehicle_Type__c != null && opptyDetails.Vehicle_Type__c == 'New'){
                policyType = '';
            }
            else if(vehDetailList.size() > 0 && vehDetailList[0].Insurance_type__c != null){
                if(vehDetailList[0].Insurance_type__c == 'Comprehensive'){
                    policyType = 'CP';
                }
                else if(vehDetailList[0].Insurance_type__c == 'Third Party'){
                    policyType = 'TP';
                }
            }
            ObproList.Ins_Policy_Type = policyType;
            ObproList.IDV = vehDetailList.size() > 0 && vehDetailList[0].Insurance_declared_value__c != null ? vehDetailList[0].Insurance_declared_value__c : 0;    
            ObproList.Ins_Premium = opptyDetails.Existing_Motor_Insurance_Premium__c !=  null ? opptyDetails.Existing_Motor_Insurance_Premium__c : 0;
            ObproList.RSD = opptyDetails.Vehicle_Type__c != null && opptyDetails.Vehicle_Type__c == 'New' && loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].RSD__c != null ? String.valueOF(loanDisbursDetailList[0].RSD__c) : '';
            ObproList.RED = opptyDetails.Vehicle_Type__c != null && opptyDetails.Vehicle_Type__c == 'New' && vehDetailList.size() > 0 && vehDetailList[0].Ins_Expiry_date__c != null ? String.valueOF(vehDetailList[0].Ins_Expiry_date__c) : '';
            if(isTractor){
                ObproList.Insurer = insuranceDetailsList.size() > 0 ? insuranceDetailsList[0].Applicant__r.Name : '';
            }else{
                ObproList.Insurer = opptyDetails.Vehicle_Type__c != null && opptyDetails.Vehicle_Type__c == 'New' && loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Insurer__c != null ? String.valueOF(loanDisbursDetailList[0].Insurer__c) : '';
            }
            ObproList.Health_Product = healthInsurance.Insurance_Plan__c != null ?  healthInsurance.Insurance_Plan__c : '';
            ObproList.Health_Premium = healthInsurance.Amount__c != null ? healthInsurance.Amount__c : 0;
            ObproList.Health_Renewal = 'N';
            ObproList.Health_Renewal_Years = 0;
            ObproList.Health_Spouse_Name = '';
            ObproList.Health_Spouse_Gender = '';
            ObproList.Health_Spouse_DOB = '';
            ObproList.Health_Child1_Name = '';
            ObproList.Health_Child1_Gender = '';
            ObproList.Health_Child1_DOB = '';
            ObproList.Health_Child2_Name = '';
            ObproList.Health_Child2_Gender = '';
            ObproList.Health_Child2_DOB = '';
            ObproList.Combo_Renewal = 'N';
            ObproList.Combo_Renewal_Years = 0;
            ObproList.Enquiry_Number = '';
            ObproList.CIC_No = cibilDetailsList.size() > 0 ? String.valueOF(cibilDetailsList[0].CIC_No__c) : '';
            ObproList.Letter_Ref = isTractor == false ? String.valueOf(opptyDetails.NOC_Number__c) : vehDetailList.size() > 0 ? String.valueOf(vehDetailList[0].NOC_Number__c) : null;
            String productCode = String.isNotBlank(opptyDetails.Product_Type__c) ? opptyDetails.Product_Type__c.equals('Two Wheeler') ? 'H':opptyDetails.Product_Type__c.equals('Passenger Vehicles') ? 'C': opptyDetails.Product_Type__c == System.Label.Tractor ? 'T' : '' : '';
            String agentBLCode = opptyDetails.Agent_BL_code__c;
            List<BankBranchDetails__c> bankBranchDetail = new List<BankBranchDetails__c>([SELECT Id,Geo_State_Code__c,Geo_State_Master__c,Geo_State_Master__r.Name FROM BankBranchDetails__c WHERE Bl_Code__c = :agentBLCode AND Geo_State_Code__c!=NULL AND Product__c = :productCode]);
           
            ObproList.Deal_Geo_State_Code = bankBranchDetail.size() > 0 ? bankBranchDetail[0].Geo_State_Code__c : '';
            ObproList.Customer_Geo_State_Code = '';
            ObproList.Guarantor_Geo_State_Code = '';
            ObproList.Future_Period = 0;
            ObproList.BSR_Code = '95012';
            ObproList.Evaluation_Method = '';
            ObproList.Enquiry_Number_Guar = '';
            ObproList.CIC_No_Guar = cobcibilDetailsList.size() > 0 ? String.valueOF(cobcibilDetailsList[0].CIC_No__c) : '';
            ObproList.Asset_Usage_By = '';
            ObproList.TopUp_Refin = '';
            ObproList.IBL_Account_No = '';
            ObproList.SA_Application_No = casaBankFormList.size() > 0 ? casaBankFormList[0].Saving_Account_opening_form_No__c : '';
            ObproList.SA_Acc_Open_Charges = casaBankFormList.size() > 0 && IHMList.size() > 0 ? IHMList[0].SA_Account_Opening_Charges__c : 0;  
            //SFTRAC-1715
            if(isTractor == true){
                ObproList.Amount_Hold = vehDetailList.size() > 0 && vehDetailList[0].RC_Hold_Amount__c != null ? (vehDetailList[0].RC_Hold_Amount__c) : 0;
            }else{
            ObproList.Amount_Hold = finalTermList.size() > 0 && finalTermList[0].RCU_Retention_Charges__c != null ? Decimal.valueOf(finalTermList[0].RCU_Retention_Charges__c) : 0; 
            }//SFTRAC-1715 
            ObproList.GPA_Insured_Gender = '';
            if(isTractor){
                if(insuranceDetailsList.size() > 0 && (insuranceDetailsList[0].Applicant__r.Applicant_Type__c == Label.Borrower || insuranceDetailsList[0].Applicant__r.Applicant_Type__c == Label.Beneficiary)){
                    ObproList.Nominee_Name = insuranceDetailsList.size() > 0 && insuranceDetailsList[0].Applicant__r.Nominee_name__c != null ? insuranceDetailsList[0].Applicant__r.Nominee_name__c : '';
                    ObproList.Nominee_DOB = insuranceDetailsList.size() > 0 && insuranceDetailsList[0].Applicant__r.Nominee_DOB__c != null ? String.valueOf(insuranceDetailsList[0].Applicant__r.Nominee_DOB__c) : '';
                    ObproList.Nominee_Relation =  insuranceDetailsList.size() > 0 && insuranceDetailsList[0].Applicant__r.Nominee_Relationship__c != null ? insuranceDetailsList[0].Applicant__r.Nominee_Relationship__c : '';
                    ObproList.Nominee_Address = insuranceDetailsList.size() > 0 && insuranceDetailsList[0].Applicant__r.Nominee_address__c != null ? insuranceDetailsList[0].Applicant__r.Nominee_address__c : '';
                }else{
                    ObproList.Nominee_Name = '';
                    ObproList.Nominee_DOB = '';
                    ObproList.Nominee_Relation =  '';
                    ObproList.Nominee_Address = '';
                }

                if(insuranceDetailsList.size() > 0 && insuranceDetailsList[0].Applicant__r.Applicant_Type__c == Label.CoBorrower){
                    ObproList.Nominee_Name_G = insuranceDetailsList.size() > 0 && insuranceDetailsList[0].Applicant__r.Nominee_name__c != null ? insuranceDetailsList[0].Applicant__r.Nominee_name__c : '';
                    ObproList.Nominee_DOB_G = insuranceDetailsList.size() > 0 && insuranceDetailsList[0].Applicant__r.Nominee_DOB__c != null ? String.valueOf(insuranceDetailsList[0].Applicant__r.Nominee_DOB__c) : '';
                    ObproList.Nominee_Relation_G =  insuranceDetailsList.size() > 0 && insuranceDetailsList[0].Applicant__r.Nominee_Relationship__c != null ? insuranceDetailsList[0].Applicant__r.Nominee_Relationship__c : '';
                    ObproList.Nominee_Address_G = insuranceDetailsList.size() > 0 && insuranceDetailsList[0].Applicant__r.Nominee_address__c != null ? insuranceDetailsList[0].Applicant__r.Nominee_address__c : '';
                }else{
                    ObproList.Nominee_Name_G =  '';
                    ObproList.Nominee_DOB_G =  '';
                    ObproList.Nominee_Relation_G =  '';
                    ObproList.Nominee_Address_G =  '';
                }
            }else{
                ObproList.Nominee_Name = loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Borrower_Name__c != null ? String.valueOf(loanDisbursDetailList[0].Borrower_Name__c) : '';
                ObproList.Nominee_DOB =  loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Borrower_DOB__c != null ? String.valueOf(loanDisbursDetailList[0].Borrower_DOB__c) : '';
                ObproList.Nominee_Relation =  loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Borrower_Relationship__c != null ? String.valueOf(loanDisbursDetailList[0].Borrower_Relationship__c) : '';
                ObproList.Nominee_Address =  loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Borrower_Address__c != null ? String.valueOf(loanDisbursDetailList[0].Borrower_Address__c) : '';

                ObproList.Nominee_Name_G =  loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].CoBorrower_Name__c != null ? String.valueOf(loanDisbursDetailList[0].CoBorrower_Name__c) : '';
                ObproList.Nominee_DOB_G =  loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].CoBorrower_DOB__c != null? String.valueOf(loanDisbursDetailList[0].CoBorrower_DOB__c) : '';
                ObproList.Nominee_Relation_G =  loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].CoBorrower_Relationship__c != null ? String.valueOf(loanDisbursDetailList[0].CoBorrower_Relationship__c) : '';
                ObproList.Nominee_Address_G =  loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].CoBorrower_Address__c != null ? String.valueOf(loanDisbursDetailList[0].CoBorrower_Address__c) : '';
            }
            ObproList.GPA_Insured = '';
            ObproList.SA_Nominee_Available =casaBankFormList.size() > 0 && casaBankFormList[0].Nominee_available__c != null ? String.valueOf(casaBankFormList[0].Nominee_available__c) : '';    
            ObproList.DLP_Price = 0;
            //Get from Insuarnce Details
            String GPATypeG = hasGPAForCob == 'Y' ? (GPAInsuranceForCob.Funded_Non_funded__c == 'Funded' ? 'B' : 'C') : '';
            String helathFundTypeG = hasHealthInsuForCob == 'Y' ? (healthInsuranceForCob.Funded_Non_funded__c == 'Funded' ? 'B' :  'C') : '';
            String helathFundType = hasHealthInsu == 'Y' ? (healthInsurance.Funded_Non_funded__c == 'Funded' ? 'B' : 'C') : '';
            String comboType = hasComboInsu == 'Y' ? (comboInsurance.Funded_Non_funded__c == 'Funded' ? 'B' : 'C') : '';
            String comboTypeG = hasComboInsuForCob == 'Y' ? (comboInsuranceForCob.Funded_Non_funded__c == 'Funded' ? 'B' : 'C') : '';
            String motorType = '';
            if(isTractor){
                motorType = hasMotorInsu == 'Y' ? (motorInsurance.Funded_Non_funded__c == 'Funded' ? 'B' : 'C') : hasMotorInsuForCob == 'Y' ? (motorInsuranceForCob.Funded_Non_funded__c == 'Funded' ? 'B' : 'C') : '';
            }else{
                motorType = hasMotorInsu == 'Y' ? (motorInsurance.Funded_Non_funded__c == 'Funded' ? 'B' : 'C') : '';
            }
            String liEMIType = hasLIEMIInsu == 'Y' ? (liEMIInsurance.Funded_Non_funded__c == 'Funded' ? 'B' : 'C') : '';
            String liEMITypeG = hasLIEMIInsuForCob == 'Y' ? (liEMIInsuranceForCob.Funded_Non_funded__c == 'Funded' ? 'B' : 'C') : '';
            String tataEMIType = hasTATAEMIInsu == 'Y' ? (tataEMIInsurance.Funded_Non_funded__c == 'Funded' ? 'B' : 'C') : '';
            String flexiType = hasFlexiInsu == 'Y' ? (flexiInsurance.Funded_Non_funded__c == 'Funded' ? 'B' : 'C') : '';
            String flexiTypeG = hasFlexiInsuForCob == 'Y' ? (flexiInsuranceForCob.Funded_Non_funded__c == 'Funded' ? 'B' : 'C') : '';
            String liType = hasLIInsu == 'Y' ? (liInsurance.Funded_Non_funded__c == 'Funded' ? 'B' : 'C') : '';
            String liTypeG = hasLIInsuForCob == 'Y' ? (liInsuranceForCob.Funded_Non_funded__c == 'Funded' ? 'B' : 'C') : '';
            
            ObproList.GPA_Available_G = hasGPAForCob;
            ObproList.Health_Fund_Type = helathFundType;
            ObproList.Health_Fund_Type_G = helathFundTypeG;
            ObproList.Health_Product_G = hasHealthInsuForCob == 'Y' && healthInsuranceForCob.Insurance_Plan__c != null ?  healthInsuranceForCob.Insurance_Plan__c : '';//CISP-3615
            ObproList.Health_Premium_G = hasHealthInsuForCob == 'Y' ? healthInsuranceForCob.Amount__c : 0;
            ObproList.Health_Spouse_Name_G = '';
            ObproList.Health_Spouse_Gender_G = '';
            ObproList.Health_Spouse_DOB_G = '';
            ObproList.Health_Child1_Name_G = '';
            ObproList.Health_Child1_Gender_G = '';
            ObproList.Health_Child1_DOB_G = '';
            ObproList.Health_Child2_Name_G = '';
            ObproList.Health_Child2_Gender_G = '';
            ObproList.Health_Child2_DOB_G = '';
            ObproList.SA_Security_Cheque_No = '';
            ObproList.SA_Acc_Holder_Type = casaBankFormList.size() > 0 ? casaBankFormList[0].Applicant__r.Applicant_Type__c == 'Borrower' ? 'B' : 'C' : '';
            ObproList.SA_Acc_Holder = casaBankFormList.size() > 0 && casaBankFormList[0].Applicant__c != null ? casaBankFormList[0].Applicant__r.Name : '';
            ObproList.Motor_Fund_Type = motorType;
            ObproList.Valuer_Catq = '';
            ObproList.Valuer_Code = '';
            ObproList.Valuer_Name = '';
            if(isTractor && (opptyDetails.Vehicle_Type__c == 'Used' || opptyDetails.Vehicle_Type__c == 'Refinance')){
                ObproList.SLA_No = (vehDetailList.size() > 0 && vehDetailList[0].SLA_Number__c != null) ? vehDetailList[0].SLA_Number__c + '' : '';
            }else{
                ObproList.SLA_No = '';
            }
            ObproList.Valuation_Report_No = '';
            ObproList.Valuation_Done_On = '';
            ObproList.Valuation_Charges = IHMList.size() > 0 && IHMList[0].Valuation_charges_D__c != null ? IHMList[0].Valuation_charges_D__c : 0;
            String valuationChargesBorneBy = '';
            if(IHMList.size() > 0 ){
                if(IHMList[0].Valuation_Charges_Borne_By__c == 'IBL'){
                    valuationChargesBorneBy = 'IBL';
                }
                else if(IHMList[0].Valuation_Charges_Borne_By__c == 'Customer'){
                    valuationChargesBorneBy = 'CUS';
                }
                else{
                    valuationChargesBorneBy = '';
                }
            }
            ObproList.Valuation_Charges_Borne_By = valuationChargesBorneBy;
            ObproList.Combo_Product = hasComboInsu == 'Y' && comboInsurance.Insurance_Plan__c != null ? String.valueOf(comboInsurance.Insurance_Plan__c) : hasLIEMIInsu == 'Y' && liEMIInsurance.Insurance_Plan__c != null ? String.valueOf(liEMIInsurance.Insurance_Plan__c) : '';
            ObproList.Combo_Product_G = hasComboInsuForCob == 'Y' && comboInsuranceForCob.Insurance_Plan__c != null ? String.valueOf(comboInsuranceForCob.Insurance_Plan__c) : '';
            ObproList.Valuation_Request_id = 0;
            ObproList.Ins_Prm_Dep_VI = 0;
            ObproList.Ins_Prm_Dep_VII = 0;
            ObproList.Engine_No = loanDisbursDetailList.size() > 0 ? (loanDisbursDetailList[0].Engine_no__c ) : '';
            ObproList.Chassis_no =loanDisbursDetailList.size() > 0 ? (loanDisbursDetailList[0].Chassis_no__c    ) : '';
            ObproList.Vehicle_Register_Name = borrowerDetails != null ? borrowerDetails.Name : '';
            ObproList.IFSC_Code = repaymentsList.size() > 0 ? (repaymentsList[0].IFSC_Code__c) : '';
            ObproList.PDC_ACC_No = repaymentsList.size() > 0 ? (repaymentsList[0].Account_Number__c) : '';//CISP-2400
            ObproList.PDC_Bank = repaymentsList.size() > 0 ? (repaymentsList[0].Bank_Master__r.Name) : '';//CISP-2400
            ObproList.Phy_Mandate_Despatched_YN = '';
            ObproList.DO_Type = '';
            ObproList.DO_Authorised_By = '';
            ObproList.Chola_LP_Premium = 0;
            ObproList.Chola_LP_Fund_Type = '';
            ObproList.AP_Premium = 0;
            ObproList.AP_Fund_Type = '';
            ObproList.DO_Date = '';
            ObproList.VAS_Premium = 0;
            ObproList.VAS_Fund_Type = '';
            ObproList.LHC_Amt = 0;
            ObproList.LHC_Flag = '';
            ObproList.Deal_Date_Flag = '';
            ObproList.Telematics_Premium = 0;
            ObproList.Telematics_Fund_Type = '';
            ObproList.Telematics_Device_At = '';
            ObproList.Account_Holder_Name = '';
            ObproList.Combo_Insurer = insurer ? 'ICICI' : '';
            ObproList.Combo_Insurer_G = insurerG ? 'ICICI' : '';
            ObproList.Long_Term_Policy_Yrs = loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Long_term_policy_Own_Damage_Yrs__c != null ? Integer.valueOf(loanDisbursDetailList[0].Long_term_policy_Own_Damage_Yrs__c) : 0;
            ObproList.No_Of_CoBorrowers = applicantDetailsList.size() - 1;
            ObproList.LI_LHC = 0;
            ObproList.Usage = vehDetailList.size() > 0 ? vehDetailList[0].Purpose_of_purchase__c : '';
            ObproList.OD_Premium = 0;
            ObproList.TP_Premium = 0;
            ObproList.UniqueTransactionID = 0;
            ObproList.LI_LHC_G = 0;
            ObproList.RD_Amount = 0;
            ObproList.Dep_Type = '';
            ObproList.HP_Available = '';
            ObproList.HP_Premium = 0;
            ObproList.HP_Available_G = '';
            ObproList.HP_Premium_G = 0;
            ObproList.RD_Start_Date = '';
            ObproList.RD_Years = 0;
            ObproList.Tractor_Deal_No = '';
            ObproList.Covid_Cover_YN = '';
            ObproList.Covid_Cover_Amt = 0;
            ObproList.Trade_Certificate_YN = finalTermList.size() > 0 && finalTermList[0].Trade_certificate__c != null ? String.valueOf(finalTermList[0].Trade_certificate__c) : '';
            ObproList.Trade_Certificate_Fee = finalTermList.size() > 0 && finalTermList[0].Trade_certificate__c != null ? Decimal.valueOf(finalTermList[0].Trade_certificate__c) : 0;
            ObproList.RTO_Prefix = finalTermList.size() > 0 && finalTermList[0].RTO_prefix__c != null ? String.valueOf(finalTermList[0].RTO_prefix__c) : '';
            ObproList.Delivered_YN =loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Vehicle_Delivered__c != null ? String.valueOf(loanDisbursDetailList[0].Vehicle_Delivered__c) : '';
            ObproList.MCLR = 7.50;
            ObproList.Borr_Mobile_Aadhar = TeleVerificationList.size() > 0 && TeleVerificationList[0].Is_customer_s_Mob_No_linked_to_Aadhar__c != null && TeleVerificationList[0].Is_customer_s_Mob_No_linked_to_Aadhar__c ? 'Y' : 'N';
            ObproList.CoBorr_Mobile_Aadhar =cobTeleVerificationList.size() > 0 && cobTeleVerificationList[0].Is_customer_s_Mob_No_linked_to_Aadhar__c != null && cobTeleVerificationList[0].Is_customer_s_Mob_No_linked_to_Aadhar__c ? 'Y' : 'N';
            ObproList.Addl_CobBorr_Mobile_Aadhar = cobTeleVerificationList.size() > 0 && cobTeleVerificationList[0].Is_customer_using_Aadhar_Linked_Mob_No__c != null && cobTeleVerificationList[0].Is_customer_using_Aadhar_Linked_Mob_No__c == true  ? 'Y' : 'N';
            ObproList.Enable_Eagreement = loanAgreementList.size() > 0 && loanAgreementList[0].Agreement_Type__c != null && loanAgreementList[0].Agreement_Type__c == 'e-agreement' ? 'Y' : 'N';
            ObproList.RTA_Taxes_Upto =loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].RTA_taxes_remitted_upto__c != null ? String.valueOf(loanDisbursDetailList[0].RTA_taxes_remitted_upto__c) : '';
            ObproList.Fund_End_Use = loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Fund_End_Use__c != null ? String.valueOf(loanDisbursDetailList[0].Fund_End_Use__c) : '';
            ObproList.SOC_Version_No = '2';
            ObproList.Arogya_Product = '';
            ObproList.Arogya_SI = 0;
            ObproList.Arogya_Premium = 0;
            ObproList.Arogya_Fund_Type = '';
            ObproList.Disc_Connect_Premium = 0;
            ObproList.Disc_Connect_Fund_Type = '';
            if(isTractor){
                ObproList.GPA_Premium = hasComboInsu == 'Y' && comboInsurance.Combo_EMI_Premium__c != null && comboInsurance.Insurance_Plan__c != 'LI_EMI' && comboInsurance.Insurance_Plan__c != 'LI_SHUBH' ? Integer.valueof(comboInsurance.Combo_EMI_Premium__c) : 0;
                ObproList.GPA_Type = hasComboInsu == 'Y' && comboInsurance.Insurance_Plan__c != 'LI_EMI' && comboInsurance.Insurance_Plan__c != 'LI_SHUBH' ? comboType : '';
                ObproList.GPA_Premium_G = hasComboInsuForCob == 'Y' && comboInsuranceForCob.Combo_EMI_Premium__c != null && comboInsuranceForCob.Insurance_Plan__c != 'LI_EMI' && comboInsuranceForCob.Insurance_Plan__c != 'LI_SHUBH'? Integer.valueof(comboInsuranceForCob.Combo_EMI_Premium__c) : 0;
                ObproList.GPA_Type_G = hasComboInsuForCob == 'Y' && comboInsuranceForCob.Insurance_Plan__c != 'LI_EMI' && comboInsuranceForCob.Insurance_Plan__c != 'LI_SHUBH' ? comboTypeG : '';

                ObproList.Combo_Fund_Type = comboType;
                ObproList.Combo_Fund_Type_G = comboTypeG;
                ObproList.Combo_Premium = hasComboInsu == 'Y' ? comboInsurance.Amount__c : 0;
                ObproList.Combo_Premium_G = hasComboInsuForCob == 'Y' ? comboInsuranceForCob.Amount__c : 0;

                ObproList.LI_Prm = hasComboInsu == 'Y' && comboInsurance.Combo_LI_Premium__c != null ? Integer.valueof(comboInsurance.Combo_LI_Premium__c) : hasLIInsu == 'Y' && liInsurance.Amount__c != null ? Integer.valueof(liInsurance.Amount__c) : 0;
                ObproList.LI_Prm_G = hasComboInsuForCob == 'Y' && comboInsuranceForCob.Combo_LI_Premium__c != null ? Integer.valueof(comboInsuranceForCob.Combo_LI_Premium__c) : hasLIInsuForCob == 'Y' && liInsuranceForCob.Amount__c != null ? Integer.valueof(liInsuranceForCob.Amount__c) : 0;
                ObproList.LI_Fund_Type = comboType != '' ? comboType : liType;
                ObproList.LI_Fund_Type_G = comboTypeG != '' ? comboTypeG : liTypeG;

                ObproList.Subh_Raksha_Prm = hasComboInsu == 'Y' && comboInsurance.Combo_EMI_Premium__c != null && comboInsurance.Insurance_Plan__c == 'LI_SHUBH' ? Integer.valueof(comboInsurance.Combo_EMI_Premium__c) : 0;
                ObproList.Subh_Raksha_Prm_G = hasComboInsu == 'Y' && comboInsuranceForCob.Combo_EMI_Premium__c != null && comboInsuranceForCob.Insurance_Plan__c == 'LI_SHUBH' ? Integer.valueof(comboInsuranceForCob.Combo_EMI_Premium__c) : 0;

                ObproList.TATA_EMI_Amount = hasComboInsu == 'Y' && comboInsurance.EMI_Passed_in_API__c != null && comboInsurance.Insurance_Plan__c == 'LI_EMI' ? Integer.valueof(comboInsurance.EMI_Passed_in_API__c) : 0;
                ObproList.TATA_EMI_Premium = hasComboInsu == 'Y' && comboInsurance.Combo_EMI_Premium__c != null && comboInsurance.Insurance_Plan__c == 'LI_EMI' ? Integer.valueof(comboInsurance.Combo_EMI_Premium__c) : hasComboInsuForCob == 'Y' && comboInsuranceForCob.Combo_EMI_Premium__c != null && comboInsuranceForCob.Insurance_Plan__c == 'LI_EMI' ? Integer.valueOf(comboInsuranceForCob.Combo_EMI_Premium__c) : 0;

                ObproList.TATA_EMI_Fund_Type = hasComboInsu == 'Y' && comboInsurance.Insurance_Plan__c == 'LI_EMI' ? comboType : hasComboInsuForCob == 'Y' && comboInsuranceForCob.Insurance_Plan__c == 'LI_EMI' ? comboTypeG  : '';
                ObproList.TATA_EMI_Amount_G = hasComboInsuForCob == 'Y' && comboInsuranceForCob.EMI_Passed_in_API__c != null && comboInsuranceForCob.Insurance_Plan__c == 'LI_EMI' ? String.valueof(comboInsuranceForCob.EMI_Passed_in_API__c) : '0';
            }else{
                ObproList.GPA_Premium = GPAInsurance.Amount__c != null ? GPAInsurance.Amount__c : 0;
                ObproList.GPA_Type = GPAType;
                ObproList.GPA_Premium_G = GPAInsuranceForCob.Amount__c != null ? GPAInsuranceForCob.Amount__c : 0;
                ObproList.GPA_Type_G = GPATypeG;

                ObproList.Combo_Fund_Type = comboType !='' ? comboType : liEMIType;
                ObproList.Combo_Fund_Type_G = comboTypeG;
                ObproList.Combo_Premium = hasComboInsu == 'Y' ? comboInsurance.Amount__c : hasLIEMIInsu == 'Y' ? liEMIInsurance.Amount__c : 0;
                ObproList.Combo_Premium_G = hasComboInsuForCob == 'Y' ? comboInsuranceForCob.Amount__c : 0;

                ObproList.LI_Prm = hasLIInsu == 'Y' && liInsurance.Amount__c!=null ? Integer.valueOf(liInsurance.Amount__c) : hasLIEMIInsu == 'Y' && liEMIInsurance.Combo_LI_Premium__c != null ? Integer.valueOf(liEMIInsurance.Combo_LI_Premium__c) : 0;
                ObproList.LI_Prm_G = hasLIInsuForCob == 'Y' && liInsuranceForCob.Amount__c!=null ? Integer.valueOf(liInsuranceForCob.Amount__c) : hasLIEMIInsuForCob == 'Y' && liEMIInsuranceForCob.Combo_LI_Premium__c != null ? Integer.valueOf(liEMIInsuranceForCob.Combo_LI_Premium__c) : 0;
                ObproList.LI_Fund_Type = liType != '' ? liType : liEMIType;
                ObproList.LI_Fund_Type_G = liTypeG != '' ? liTypeG : liEMITypeG;

                ObproList.Subh_Raksha_Prm = 0;
                ObproList.Subh_Raksha_Prm_G = 0;

                ObproList.TATA_EMI_Amount = hasTATAEMIInsu == 'Y' && tataEMIInsurance.EMI_Passed_in_API__c != null ? Integer.valueOf(tataEMIInsurance.EMI_Passed_in_API__c) : hasLIEMIInsu == 'Y' && liEMIInsurance.EMI_Passed_in_API__c != null ? Integer.valueOf(liEMIInsurance.EMI_Passed_in_API__c) : 0;
                ObproList.TATA_EMI_Premium = hasTATAEMIInsu == 'Y' && tataEMIInsurance.Amount__c != null ? Integer.valueOf(tataEMIInsurance.Amount__c) : hasLIEMIInsu == 'Y' && liEMIInsurance.Combo_EMI_Premium__c != null ? Integer.valueOf(liEMIInsurance.Combo_EMI_Premium__c) : 0;
                ObproList.TATA_EMI_Fund_Type = tataEMIType !='' ? tataEMIType : liEMIType != '' ? liEMIType : '';
                ObproList.TATA_EMI_Amount_G = '';
            }
            ObproList.Arogya_Product_G = '';
            ObproList.Arogya_SI_G = 0;
            ObproList.Arogya_Premium_G = 0;
            ObproList.Arogya_Fund_Type_G = '';
            ObproList.Disc_Connect_Premium_G = 0;
            ObproList.Disc_Connect_Fund_Type_G = '';
            ObproList.Flexi_Prm = hasFlexiInsu == 'Y' && flexiInsurance.Amount__c != null ? Integer.valueOf(flexiInsurance.Amount__c) : 0;
            ObproList.Flexi_Plan = hasFlexiInsu == 'Y' && flexiInsurance.Insurance_Plan__c != null ? flexiInsurance.Insurance_Plan__c : '';
            ObproList.Flexi_Fund_Type = flexiType;
            ObproList.Flexi_Prm_G = hasFlexiInsuForCob == 'Y' && flexiInsuranceForCob.Amount__c != null ? Integer.valueOf(flexiInsuranceForCob.Amount__c) : 0;
            ObproList.Flexi_Plan_G = hasFlexiInsuForCob == 'Y' && flexiInsuranceForCob.Insurance_Plan__c != null ?  flexiInsuranceForCob.Insurance_Plan__c : '';
            ObproList.Flexi_Fund_Type_G = flexiTypeG;
            
            objPROList.add(ObproList);
            objPROList=objPROList;
            this.ObjReqPR.objPROList=objPROList;    
            
            this.ObjReqPR.objPayInOutList= PactLmsRequestHelper.getPayInPayOut(finalTermList, isTractor,opptyDetails, dealNumber);
            this.ObjReqPR.ObjPRIList=PactLmsRequestHelper.getInstallments(structuredEmiList, finalTermList, isTractor, dealNumber, fundedPremium, allInstSum, noOfInstalments);  
            
            List<PactLmsRequestHelper.ObjPUIMList> ObjPUIMList = new List<PactLmsRequestHelper.ObjPUIMList>();
            PactLmsRequestHelper.ObjPUIMList ObpuimList = new PactLmsRequestHelper.ObjPUIMList();
            
            ObpuimList.Customer_Code= '';
            ObpuimList.Product= '';
            ObpuimList.Pay_Source= '';
            ObpuimList.Inv_Amt= 0;
            ObpuimList.Fin_Amt= 0;
            ObpuimList.IHM= 0;
            ObpuimList.Term= 0;
            ObpuimList.Emi_Nos= 0;
            ObpuimList.Adv_Emi_Nos= 0;
            ObpuimList.ROI= 0;
            ObpuimList.Incen_Amt= 0;
            ObpuimList.Incen_Type= '';
            ObpuimList.Dsa_Amt= 0;
            ObpuimList.Dsa_Name= finalTermList.size() > 0 && finalTermList[0].Referrer_Ben_Code__c != null ? finalTermList[0].Referrer_Ben_Code__c : '';
            ObpuimList.Serv_Chrgs= 0;
            ObpuimList.Channel_Cost= 0;
            ObpuimList.Insurance= 0;
            ObpuimList.First_Pdc_Amt= 0;
            ObpuimList.Gross_Irr= 0;
            ObpuimList.Net_Irr= 0;
            ObpuimList.Disburse_Amt= 0;
            ObpuimList.Beneficiary= '';
            ObpuimList.Enter_Dt= '';
            ObpuimList.IHM_BY_IBL= 0;
            ObpuimList.Gpayn= '';
            ObpuimList.Gpprm= 0;
            ObpuimList.Gparef= '';
            ObpuimList.Ltv= 0;
            ObpuimList.dlrincent= 0;
            ObpuimList.dlrinctype= '';
            ObpuimList.delinqamt= 0;
            ObpuimList.delinqtype= '';
            ObpuimList.iblrctref= '';
            ObpuimList.dlrrctref= '';
            ObpuimList.Ma_code= '';
            ObpuimList.Doc_Chrgs= 0;
            ObpuimList.Approved_IRR= 0;
            ObpuimList.Gross_LTV= 0;
            ObpuimList.InvPrice_Category= '';
            ObpuimList.GPA_Sourced_By= '';
            ObpuimList.Market_Value= 0;
            ObpuimList.Main_Dealer= mainDealerBenCode;
            ObpuimList.Sub_dealer= vehDetailList.size() > 0 ? vehDetailList[0].Dealer_Sub_dealer_name__c : '';
            ObpuimList.Deal_No= dealNumber;
            ObpuimList.Mfg_Month= 0;
            ObpuimList.Mfg_Year= 0;
            ObpuimList.Maker_ID= 0;
            ObpuimList.Mfg_Incentive= 0;
            ObpuimList.Finance_Charges = integer.valueOf(allInstSum) - integer.valueOf(financeAmount);
            ObpuimList.Gift_Amt= 0;
            ObpuimList.Gift_Type= '';
            ObpuimList.Collection_Mode= '';
            ObpuimList.ECS_Verification_By= '';
            ObpuimList.ECS_Verification_Charges= 0;
            ObpuimList.Periodicity= '';
            ObpuimList.Moratorium= 0;
            ObpuimList.Vehicle_Category= vehDetailList.size() > 0 && vehDetailList[0].Vehicle_Category__c !=  null ? vehDetailList[0].Vehicle_Category__c : '';
            ObpuimList.Vehicle_Sub_Category= '';
            ObpuimList.Hospital_Cash_Premium= 0;
            ObpuimList.FI_Done_By= fiDoneMakerId;
            ObpuimList.Health_Premium= 0;
            ObpuimList.Health_Renewal= '';
            ObpuimList.Health_Renewal_Years= 0;
            ObpuimList.Health_Spouse_Name= '';
            ObpuimList.Health_Spouse_Gender= '';
            ObpuimList.Health_Spouse_DOB= '';
            ObpuimList.Health_Child1_Name= '' ;
            ObpuimList.Health_Child1_Gender= '' ;
            ObpuimList.Health_Child1_DOB= '';
            ObpuimList.Health_Child2_Name= '' ;
            ObpuimList.Health_Child2_Gender= '' ;
            ObpuimList.Health_Child2_DOB= '';
            ObpuimList.Health_Product= '' ;
            ObpuimList.GPA_Type= '';
            ObpuimList.Sub_Dlr_Incentive_Amt= 0;
            ObpuimList.Sub_Dlr_Incentive_Type= '' ;
            ObpuimList.Stamping_Charges= 0;
            ObpuimList.POSB_Charges_By= '';
            ObpuimList.POSB_Charges= 0;
            String longTermPolicy = '';
            if(loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Long_term_policy_available__c == 'Yes'){
                longTermPolicy = 'Y';
            } else if (loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Long_term_policy_available__c == 'No'){
                longTermPolicy = 'N';
            }
            if(opptyDetails.LeadSource == 'OLA'){//OLA-196
                ObpuimList.Long_Term_Policy_Flag= 'Y';   
                }else{
            ObpuimList.Long_Term_Policy_Flag= longTermPolicy;
                }//OLA-196
            ObjPUIMList.add(ObpuimList);
            ObjPUIMList=ObjPUIMList;
            this.ObjReqPR.ObjPUIMList=ObjPUIMList;  
            
            this.ObjReqPR.ObjPRBList=pacthelp.ObjReqPR.ObjPRBList;// This changes for CISP-3564
            pacthelp.ObjReqPR.ObjPRInsList[0].Deal_No= dealNumber;
            this.ObjReqPR.ObjPRInsList=pacthelp.ObjReqPR.ObjPRInsList;
            List<ObjPRAList> ObjPRAList = new List<ObjPRAList>();
            if(loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Adjustment_Deal_Number1__c != '' 
               && loanDisbursDetailList[0].Adjustment_Deal_Number1__c != null && loanDisbursDetailList[0].Adjustment_Amount1__c!=null && loanDisbursDetailList[0].Adjustment_Amount1__c!= 0){//CISP-2972
                ObjPRAList ObpraList1 = new ObjPRAList();
                ObpraList1.Deal_No= dealNumber;
                ObpraList1.Adjust_Deal_No= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Adjustment_Deal_Number1__c != null ? String.valueOf(loanDisbursDetailList[0].Adjustment_Deal_Number1__c) : '';
                ObpraList1.Amount= loanDisbursDetailList.size() > 0 ? loanDisbursDetailList[0].Adjustment_Amount1__c : 0;
                ObpraList1.Customer_code= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Customer_code1__c != null ? loanDisbursDetailList[0].Customer_code1__c : '';//CISP-2629
                ObjPRAList.add(ObpraList1);
            }
            
            if(loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Adjustment_Deal_Number2__c != '' 
               && loanDisbursDetailList[0].Adjustment_Deal_Number2__c != null && loanDisbursDetailList[0].Adjustment_Amount2__c!=null && loanDisbursDetailList[0].Adjustment_Amount2__c!= 0){//CISP-2972
                ObjPRAList ObpraList2 = new ObjPRAList();
                ObpraList2.Deal_No= dealNumber;
                ObpraList2.Adjust_Deal_No= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Adjustment_Deal_Number2__c != null ? String.valueOf(loanDisbursDetailList[0].Adjustment_Deal_Number2__c) : '';
                ObpraList2.Amount= loanDisbursDetailList.size() > 0 ? loanDisbursDetailList[0].Adjustment_Amount2__c : 0;
                ObpraList2.Customer_code= loanDisbursDetailList.size() > 0 ? loanDisbursDetailList[0].Customer_code2__c : '';//CISP-2629
                ObjPRAList.add(ObpraList2);
            }
            if(loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Adjustment_Deal_Number3__c != '' 
               && loanDisbursDetailList[0].Adjustment_Deal_Number3__c != null && loanDisbursDetailList[0].Adjustment_Amount3__c!=null && loanDisbursDetailList[0].Adjustment_Amount3__c!= 0){//CISP-2972
                ObjPRAList ObpraList3 = new ObjPRAList();
                ObpraList3.Deal_No= dealNumber;
                ObpraList3.Adjust_Deal_No= loanDisbursDetailList.size() > 0 ? String.valueOf(loanDisbursDetailList[0].Adjustment_Deal_Number3__c) : '';
                ObpraList3.Amount= loanDisbursDetailList.size() > 0 ? loanDisbursDetailList[0].Adjustment_Amount3__c : 0;
                ObpraList3.Customer_code= loanDisbursDetailList.size() > 0 ? loanDisbursDetailList[0].Customer_code3__c : '';//CISP-2629
                ObjPRAList.add(ObpraList3);
            }
            if(loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Adjustment_Deal_Number4__c != '' 
               && loanDisbursDetailList[0].Adjustment_Deal_Number4__c != null && loanDisbursDetailList[0].Adjustment_Amount4__c!=null && loanDisbursDetailList[0].Adjustment_Amount4__c!= 0){//CISP-2972
                ObjPRAList ObpraList4 = new ObjPRAList();
                ObpraList4.Deal_No= dealNumber;
                ObpraList4.Adjust_Deal_No= loanDisbursDetailList.size() > 0 ? String.valueOf(loanDisbursDetailList[0].Adjustment_Deal_Number4__c) : '';
                ObpraList4.Amount= loanDisbursDetailList.size() > 0 ? loanDisbursDetailList[0].Adjustment_Amount4__c : 0;
                ObpraList4.Customer_code= loanDisbursDetailList.size() > 0 ? loanDisbursDetailList[0].Customer_code4__c : '';//CISP-2629
                ObjPRAList.add(ObpraList4);
            }
            if(loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Adjustment_Deal_Number5__c != '' 
               && loanDisbursDetailList[0].Adjustment_Deal_Number5__c != null && loanDisbursDetailList[0].Adjustment_Amount5__c!=null && loanDisbursDetailList[0].Adjustment_Amount5__c!= 0){//CISP-2972
                ObjPRAList ObpraList5 = new ObjPRAList();
                ObpraList5.Deal_No= dealNumber;
                ObpraList5.Adjust_Deal_No= loanDisbursDetailList.size() > 0 ? String.valueOf(loanDisbursDetailList[0].Adjustment_Deal_Number5__c) : '';
                ObpraList5.Amount= loanDisbursDetailList.size() > 0 ? loanDisbursDetailList[0].Adjustment_Amount5__c : 0;
                ObpraList5.Customer_code= loanDisbursDetailList.size() > 0 ? loanDisbursDetailList[0].Customer_code5__c : '';//CISP-2629
                ObjPRAList.add(ObpraList5);
            }
            if(loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Adjustment_Deal_Number6__c != '' 
               && loanDisbursDetailList[0].Adjustment_Deal_Number6__c != null && loanDisbursDetailList[0].Adjustment_Amount6__c!=null && loanDisbursDetailList[0].Adjustment_Amount6__c!= 0){//CISP-2972
                ObjPRAList ObpraList6 = new ObjPRAList();
                ObpraList6.Deal_No= dealNumber;
                ObpraList6.Adjust_Deal_No= loanDisbursDetailList.size() > 0 ? String.valueOf(loanDisbursDetailList[0].Adjustment_Deal_Number6__c) : '';
                ObpraList6.Amount= loanDisbursDetailList.size() > 0 ? loanDisbursDetailList[0].Adjustment_Amount6__c : 0;
                ObpraList6.Customer_code= loanDisbursDetailList.size() > 0 ? loanDisbursDetailList[0].Customer_code6__c : '';//CISP-2629
                ObjPRAList.add(ObpraList6);
            }
            if(loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Adjustment_Deal_Number7__c != '' 
               && loanDisbursDetailList[0].Adjustment_Deal_Number7__c != null && loanDisbursDetailList[0].Adjustment_Amount7__c!=null && loanDisbursDetailList[0].Adjustment_Amount7__c!= 0){//CISP-2972
                ObjPRAList ObpraList7 = new ObjPRAList();
                ObpraList7.Deal_No= dealNumber;
                ObpraList7.Adjust_Deal_No= loanDisbursDetailList.size() > 0 ? String.valueOf(loanDisbursDetailList[0].Adjustment_Deal_Number7__c) : '';
                ObpraList7.Amount= loanDisbursDetailList.size() > 0 ? loanDisbursDetailList[0].Adjustment_Amount7__c : 0;
                ObpraList7.Customer_code= loanDisbursDetailList.size() > 0 ? loanDisbursDetailList[0].Customer_code7__c : '';//CISP-2629
                ObjPRAList.add(ObpraList7);
            }
            if(loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Adjustment_Deal_Number8__c != '' 
               && loanDisbursDetailList[0].Adjustment_Deal_Number8__c != null && loanDisbursDetailList[0].Adjustment_Amount8__c!=null && loanDisbursDetailList[0].Adjustment_Amount8__c!= 0){//CISP-2972
                ObjPRAList ObpraList8 = new ObjPRAList();
                ObpraList8.Deal_No= dealNumber;
                ObpraList8.Adjust_Deal_No= loanDisbursDetailList.size() > 0 ? String.valueOf(loanDisbursDetailList[0].Adjustment_Deal_Number8__c) : '';
                ObpraList8.Amount= loanDisbursDetailList.size() > 0 ? loanDisbursDetailList[0].Adjustment_Amount8__c : 0;
                ObpraList8.Customer_code= loanDisbursDetailList.size() > 0 ? loanDisbursDetailList[0].Customer_code8__c : '';//CISP-2629
                ObjPRAList.add(ObpraList8);
            }
            
            if(ObjPRAList != null && ObjPRAList.size() > 0){//Start CISP-2972
            ObjPRAList=ObjPRAList;
            this.ObjReqPR.ObjPRAList=ObjPRAList;
            }//End CISP-2972
            List<ObjPRPDList> ObjPRPDList = new List<ObjPRPDList>();
            ObjPRPDList ObprpdListGst1 = new ObjPRPDList();
            ObprpdListGst1.Deal_No= dealNumber;
            ObprpdListGst1.Category= 'GST';
            ObprpdListGst1.Prm= loanDisbursDetailList[0].GST__c != null ? loanDisbursDetailList[0].GST__c : 0;
            ObprpdListGst1.IDV= vehDetailList.size() > 0 && vehDetailList[0].Insurance_declared_value__c != null ? vehDetailList[0].Insurance_declared_value__c : 0;
            ObprpdListGst1.Year_No= 1;
            ObprpdListGst1.RSD= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].RSD__c != null ? String.valueOf(loanDisbursDetailList[0].RSD__c) : '';
            ObjPRPDList.add(ObprpdListGst1);
            if(loanDisbursDetailList[0].FirstYr_Own_Damage_Premium__c != null){
                ObjPRPDList ObprpdListOD1 = new ObjPRPDList();
                ObprpdListOD1.Deal_No= dealNumber;
                ObprpdListOD1.Category= 'OD';
                ObprpdListOD1.Prm= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].FirstYr_Own_Damage_Premium__c != null ? loanDisbursDetailList[0].FirstYr_Own_Damage_Premium__c : 0;
                ObprpdListOD1.IDV= vehDetailList.size() > 0 && vehDetailList[0].Insurance_declared_value__c != null  ? vehDetailList[0].Insurance_declared_value__c : 0;
                ObprpdListOD1.Year_No= 1;
                ObprpdListOD1.RSD= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].RSD__c != null ? String.valueOf(loanDisbursDetailList[0].RSD__c) : '';
                ObjPRPDList.add(ObprpdListOD1);
            }
            if(loanDisbursDetailList[0].SecondYr_Own_Damage_Premium__c != null){
                ObjPRPDList ObprpdListOD2 = new ObjPRPDList();
                ObprpdListOD2.Deal_No= dealNumber;
                ObprpdListOD2.Category= 'OD';
                ObprpdListOD2.Prm= loanDisbursDetailList[0].SecondYr_Own_Damage_Premium__c != null ? loanDisbursDetailList[0].SecondYr_Own_Damage_Premium__c : 0;
                ObprpdListOD2.IDV= vehDetailList.size() > 0 && vehDetailList[0].Insurance_declared_value__c != null  ? vehDetailList[0].Insurance_declared_value__c : 0;
                ObprpdListOD2.Year_No= 2;
                ObprpdListOD2.RSD= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].RSD__c != null ? String.valueOf(loanDisbursDetailList[0].RSD__c) : '';
                ObjPRPDList.add(ObprpdListOD2);
            }
            if(loanDisbursDetailList[0].ThirdYr_Own_Damage_Premium__c != null){
                ObjPRPDList ObprpdListOD3 = new ObjPRPDList();
                ObprpdListOD3.Deal_No= dealNumber;
                ObprpdListOD3.Category= 'OD';
                ObprpdListOD3.Prm= loanDisbursDetailList[0].ThirdYr_Own_Damage_Premium__c != null ? loanDisbursDetailList[0].ThirdYr_Own_Damage_Premium__c : 0;
                ObprpdListOD3.IDV= vehDetailList.size() > 0  && vehDetailList[0].Insurance_declared_value__c != null  ? vehDetailList[0].Insurance_declared_value__c : 0;
                ObprpdListOD3.Year_No= 3;
                ObprpdListOD3.RSD= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].RSD__c != null ? String.valueOf(loanDisbursDetailList[0].RSD__c) : '';
                ObjPRPDList.add(ObprpdListOD3);
            }
            if(loanDisbursDetailList[0].FourthYr_Own_Damage_Premium__c != null){
                ObjPRPDList ObprpdListOD4 = new ObjPRPDList();
                ObprpdListOD4.Deal_No= dealNumber;
                ObprpdListOD4.Category= 'OD';
                ObprpdListOD4.Prm= loanDisbursDetailList[0].FourthYr_Own_Damage_Premium__c != null ? loanDisbursDetailList[0].FourthYr_Own_Damage_Premium__c : 0;
                ObprpdListOD4.IDV= vehDetailList.size() > 0 && vehDetailList[0].Insurance_declared_value__c != null  ? vehDetailList[0].Insurance_declared_value__c : 0;
                ObprpdListOD4.Year_No= 4;
                ObprpdListOD4.RSD= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].RSD__c != null ? String.valueOf(loanDisbursDetailList[0].RSD__c) : '';
                ObjPRPDList.add(ObprpdListOD4);
            }
            if(loanDisbursDetailList[0].FifthYr_Own_Damage_Premium__c != null){
                ObjPRPDList ObprpdListOD5 = new ObjPRPDList();
                ObprpdListOD5.Deal_No= dealNumber;
                ObprpdListOD5.Category= 'OD';
                ObprpdListOD5.Prm= loanDisbursDetailList[0].FifthYr_Own_Damage_Premium__c != null ? loanDisbursDetailList[0].FifthYr_Own_Damage_Premium__c : 0;
                ObprpdListOD5.IDV= vehDetailList.size() > 0 && vehDetailList[0].Insurance_declared_value__c != null ? vehDetailList[0].Insurance_declared_value__c : 0;
                ObprpdListOD5.Year_No= 5;
                ObprpdListOD5.RSD= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].RSD__c != null ? String.valueOf(loanDisbursDetailList[0].RSD__c) : '';
                ObjPRPDList.add(ObprpdListOD5);
            }
            if(loanDisbursDetailList[0].FirstYr_Third_Party_Premium__c != null){
                ObjPRPDList ObprpdListTP1 = new ObjPRPDList();
                ObprpdListTP1.Deal_No= dealNumber;
                ObprpdListTP1.Category= 'TP';
                ObprpdListTP1.Prm= loanDisbursDetailList[0].FirstYr_Third_Party_Premium__c != null ? loanDisbursDetailList[0].FirstYr_Third_Party_Premium__c : 0; 
                ObprpdListTP1.IDV= vehDetailList.size() > 0 && vehDetailList[0].Insurance_declared_value__c != null ? vehDetailList[0].Insurance_declared_value__c : 0;
                ObprpdListTP1.Year_No= 1;
                ObprpdListTP1.RSD= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].RSD__c != null ? String.valueOf(loanDisbursDetailList[0].RSD__c) : '';
                ObjPRPDList.add(ObprpdListTP1);
            }
            if(loanDisbursDetailList[0].SecondYr_Third_Party_Premium__c != null){
                ObjPRPDList ObprpdListTP2 = new ObjPRPDList();
                ObprpdListTP2.Deal_No= dealNumber;
                ObprpdListTP2.Category= 'TP';
                ObprpdListTP2.Prm= loanDisbursDetailList[0].SecondYr_Third_Party_Premium__c != null ? loanDisbursDetailList[0].SecondYr_Third_Party_Premium__c : 0;
                ObprpdListTP2.IDV= vehDetailList.size() > 0 && vehDetailList[0].Insurance_declared_value__c != null ? vehDetailList[0].Insurance_declared_value__c : 0;
                ObprpdListTP2.Year_No= 2;
                ObprpdListTP2.RSD= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].RSD__c != null ? String.valueOf(loanDisbursDetailList[0].RSD__c) : '';
                ObjPRPDList.add(ObprpdListTP2);
            }
            if(loanDisbursDetailList[0].ThirdYr_Third_Party_Premium__c != null){
                ObjPRPDList ObprpdListTP3 = new ObjPRPDList();
                ObprpdListTP3.Deal_No= dealNumber;
                ObprpdListTP3.Category= 'TP';
                ObprpdListTP3.Prm= loanDisbursDetailList[0].ThirdYr_Third_Party_Premium__c != null ? loanDisbursDetailList[0].ThirdYr_Third_Party_Premium__c : 0;
                ObprpdListTP3.IDV= vehDetailList.size() > 0 && vehDetailList[0].Insurance_declared_value__c != null ? vehDetailList[0].Insurance_declared_value__c : 0;
                ObprpdListTP3.Year_No= 3;
                ObprpdListTP3.RSD= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].RSD__c != null ? String.valueOf(loanDisbursDetailList[0].RSD__c) : '';
                ObjPRPDList.add(ObprpdListTP3);
            }
            if(loanDisbursDetailList[0].FourthYr_Third_Party_Premium__c != null){
                ObjPRPDList ObprpdListTP4 = new ObjPRPDList();
                ObprpdListTP4.Deal_No= dealNumber;
                ObprpdListTP4.Category= 'TP';
                ObprpdListTP4.Prm= loanDisbursDetailList[0].FourthYr_Third_Party_Premium__c != null ? loanDisbursDetailList[0].FourthYr_Third_Party_Premium__c : 0;
                ObprpdListTP4.IDV= vehDetailList.size() > 0 && vehDetailList[0].Insurance_declared_value__c != null ? vehDetailList[0].Insurance_declared_value__c : 0;
                ObprpdListTP4.Year_No= 4;
                ObprpdListTP4.RSD= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].RSD__c != null ? String.valueOf(loanDisbursDetailList[0].RSD__c) : '';
                ObjPRPDList.add(ObprpdListTP4);
            }
            if(loanDisbursDetailList[0].FifthYr_Third_Party_Premium__c != null){
                ObjPRPDList ObprpdListTP5 = new ObjPRPDList();
                ObprpdListTP5.Deal_No= dealNumber;
                ObprpdListTP5.Category= 'TP';
                ObprpdListTP5.Prm= loanDisbursDetailList[0].FifthYr_Third_Party_Premium__c != null ? loanDisbursDetailList[0].FifthYr_Third_Party_Premium__c : 0;
                ObprpdListTP5.IDV= vehDetailList.size() > 0 && vehDetailList[0].Insurance_declared_value__c != null ? vehDetailList[0].Insurance_declared_value__c : 0;
                ObprpdListTP5.Year_No= 5;
                ObprpdListTP5.RSD= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].RSD__c != null ? String.valueOf(loanDisbursDetailList[0].RSD__c) : '';
                ObjPRPDList.add(ObprpdListTP5);
            }
            ObjPRPDList=ObjPRPDList;
            this.ObjReqPR.ObjPRPDList=ObjPRPDList;
            
            List<PactLmsRequestHelper.ObjGPRList> ObjGPRList = new List<PactLmsRequestHelper.ObjGPRList>();
            if(IHMList.size() > 0 && IHMList[0].SA_account_opening_charges__c != null && IHMList[0].SA_account_opening_charges__c > 0){
                PactLmsRequestHelper.ObjGPRList ObgprListSA = new PactLmsRequestHelper.ObjGPRList();
                ObgprListSA.Document_Code= ''; //dealNumber'';
                ObgprListSA.GST_Effect_Date= '';
                ObgprListSA.Deal_No= dealNumber;
                ObgprListSA.Nature= 'SA_AC_CHRGS';
                ObgprListSA.GL_Entry_Code= 'S106XC';
                ObgprListSA.Total_Value= IHMList[0].SA_account_opening_charges__c;
                //CISP: 2568
                Decimal gstValue = IHMList[0].SA_account_opening_charges__c*18.0/118;
                gstValue = gstValue.setScale(2);
                Decimal docAmount = IHMList[0].SA_account_opening_charges__c - gstValue;
                                
                ObgprListSA.GST_Value= gstValue;
                ObgprListSA.Document_Value= docAmount;                
                ObgprListSA.Maker_Id= Integer.valueOf(IntegrationUtilities.getMakerId()) ;
                ObgprListSA.Maker_Date= String.valueOf(Date.today());
                ObgprListSA.CESS_Value= 0;
                ObjGPRList.add(ObgprListSA);               
            }
            if(finalTermList.size() > 0 && finalTermList[0].Service_charges__c !='' && finalTermList[0].Service_charges__c != null
              && finalTermList[0].Service_charges__c != '0'){
                PactLmsRequestHelper.ObjGPRList ObgprListSC = new PactLmsRequestHelper.ObjGPRList();
                ObgprListSC.Document_Code= ''; //dealNumber;
                ObgprListSC.GST_Effect_Date= '';
                ObgprListSC.Deal_No= dealNumber;
                ObgprListSC.Nature= 'SERV_CHRGS';
                ObgprListSC.GL_Entry_Code= 'S103XC';
                ObgprListSC.Total_Value= Decimal.valueOf(finalTermList[0].Service_charges__c);
               //CISP: 2568
                  Decimal gstValue = Decimal.valueOf(finalTermList[0].Service_charges__c)*18.0/118;
                   gstValue = gstValue.setScale(2);
                   Decimal docAmount = Decimal.valueOf(finalTermList[0].Service_charges__c) - gstValue;                  
                ObgprListSC.GST_Value= gstValue;
                ObgprListSC.Document_Value= docAmount;
                  
                ObgprListSC.Maker_Id= Integer.valueOf(IntegrationUtilities.getMakerId()) ;
                ObgprListSC.Maker_Date= String.valueOf(Date.today());
                ObgprListSC.CESS_Value= 0;
                ObjGPRList.add(ObgprListSC);
            }
            if(finalTermList.size() > 0 && finalTermList[0].Due_date_shift_charges__c !='' && finalTermList[0].Due_date_shift_charges__c != null
              && finalTermList[0].Due_date_shift_charges__c != '0'){
                PactLmsRequestHelper.ObjGPRList ObgprListDD = new PactLmsRequestHelper.ObjGPRList();
                ObgprListDD.Document_Code= ''; //dealNumber;
                ObgprListDD.GST_Effect_Date= '';
                ObgprListDD.Deal_No= dealNumber;
                ObgprListDD.Nature= 'DUE_DT_CHRGS';
                ObgprListDD.GL_Entry_Code= 'COMCHG';
                ObgprListDD.Total_Value= Decimal.valueOf(finalTermList[0].Due_date_shift_charges__c);
                  
                  //CISP: 2568
                   Decimal gstValue =  Decimal.valueOf(finalTermList[0].Due_date_shift_charges__c)*18.0/118;
                   gstValue = gstValue.setScale(2);
                    Decimal docAmount = Decimal.valueOf(finalTermList[0].Due_date_shift_charges__c) - gstValue;
                
                ObgprListDD.GST_Value= gstValue;
                ObgprListDD.Document_Value= docAmount;
                ObgprListDD.Maker_Id= Integer.valueOf(IntegrationUtilities.getMakerId()) ;
                ObgprListDD.Maker_Date= String.valueOf(Date.today());
                ObgprListDD.CESS_Value= 0;
                ObjGPRList.add(ObgprListDD);
            }
            if(finalTermList.size() > 0 && finalTermList[0].Documentation_charges__c !='' && finalTermList[0].Documentation_charges__c != null
              && finalTermList[0].Documentation_charges__c != '0'){
                PactLmsRequestHelper.ObjGPRList ObgprListDC = new PactLmsRequestHelper.ObjGPRList();
                ObgprListDC.Document_Code= ''; //dealNumber;
                ObgprListDC.GST_Effect_Date= '';
                ObgprListDC.Deal_No= dealNumber;
                ObgprListDC.Nature= 'DOC_CHRGS';
                ObgprListDC.GL_Entry_Code= 'DOCCHG';
                ObgprListDC.Total_Value= Decimal.valueOf(finalTermList[0].Documentation_charges__c);
                  
                  //CISP: 2468
                   Decimal gstValue =  Decimal.valueOf(finalTermList[0].Documentation_charges__c)*18.0/118;
                   gstValue = gstValue.setScale(2);
                    Decimal docAmount = Decimal.valueOf(finalTermList[0].Documentation_charges__c) - gstValue;
                  
                ObgprListDC.GST_Value= gstValue;
                ObgprListDC.Document_Value= docAmount;
                ObgprListDC.Maker_Id= Integer.valueOf(IntegrationUtilities.getMakerId()) ;
                ObgprListDC.Maker_Date= String.valueOf(Date.today());
                ObgprListDC.CESS_Value= 0;
                ObjGPRList.add(ObgprListDC);
            }
            if(finalTermList.size() > 0 && finalTermList[0].Verification_charges__c !='' && finalTermList[0].Verification_charges__c != null
              && finalTermList[0].Verification_charges__c !='0'){
                PactLmsRequestHelper.ObjGPRList ObgprListVC = new PactLmsRequestHelper.ObjGPRList();
                ObgprListVC.Document_Code= ''; //dealNumber;
                ObgprListVC.GST_Effect_Date= '';
                ObgprListVC.Deal_No= dealNumber;
                ObgprListVC.Nature= 'ECS_CHRGS';
                ObgprListVC.GL_Entry_Code= 'ECSCHGRS';
                ObgprListVC.Total_Value= Decimal.valueOf(finalTermList[0].Verification_charges__c);
                  
                  //CISP: 2468
                   Decimal gstValue =  Decimal.valueOf(finalTermList[0].Verification_charges__c)*18.0/118;
                   gstValue = gstValue.setScale(2);
                    Decimal docAmount = Decimal.valueOf(finalTermList[0].Verification_charges__c) - gstValue;
                  
                ObgprListVC.GST_Value= gstValue;
                ObgprListVC.Document_Value= docAmount;
                ObgprListVC.Maker_Id= Integer.valueOf(IntegrationUtilities.getMakerId()) ;
                ObgprListVC.Maker_Date= String.valueOf(Date.today());
                ObgprListVC.CESS_Value= 0;
                ObjGPRList.add(ObgprListVC);
            }
            if(finalTermList.size() > 0 && finalTermList[0].Trade_certificate__c !='' && finalTermList[0].Trade_certificate__c != null
              && finalTermList[0].Trade_certificate__c !='0'){
                PactLmsRequestHelper.ObjGPRList ObgprListTC = new PactLmsRequestHelper.ObjGPRList();
                ObgprListTC.Document_Code= ''; //dealNumber;
                ObgprListTC.GST_Effect_Date= '';
                ObgprListTC.Deal_No= dealNumber;
                ObgprListTC.Nature= 'TRADE_FEE';
                ObgprListTC.GL_Entry_Code= 'STAMPCR';
                ObgprListTC.Total_Value= Decimal.valueOf(finalTermList[0].Trade_certificate__c);
                
                ObgprListTC.GST_Value= 0 ;//CISP-9813
                ObgprListTC.Document_Value=  Decimal.valueOf(finalTermList[0].Trade_certificate__c);//CISP-9813
                ObgprListTC.Maker_Id= Integer.valueOf(IntegrationUtilities.getMakerId()) ;
                ObgprListTC.Maker_Date= String.valueOf(Date.today());
                ObgprListTC.CESS_Value= 0;
                ObjGPRList.add(ObgprListTC);
            }
            ObjGPRList=ObjGPRList;
            this.ObjReqPR.ObjGPRList=ObjGPRList;
            
            List<PactLmsRequestHelper.objPRBDTList> objPRBDTList = new List<PactLmsRequestHelper.objPRBDTList>();
            PactLmsRequestHelper.objPRBDTList ObprbdtList = new PactLmsRequestHelper.objPRBDTList();
            
            ObprbdtList.Deal_No= dealNumber;
            ObprbdtList.PV_Number= '';
            ObprbdtList.Beneficiary_Code= '';
            ObprbdtList.Amount_Paid= 0;
            
            objPRBDTList.add(ObprbdtList);
            objPRBDTList=objPRBDTList;
            this.ObjReqPR.objPRBDTList=objPRBDTList; 
            
            List<PactLmsRequestHelper.objDRLList> objDRLList = new List<PactLmsRequestHelper.objDRLList>();
            if(opptyDetails.LeadSource == 'OLA' || opptyDetails.LeadSource == 'D2C' || vehDetailList[0].RC_limit_enabled_Dealer__c){
                PactLmsRequestHelper.objDRLList ObdrlList = new PactLmsRequestHelper.objDRLList(); 
                ObdrlList.Deal_No= dealNumber;
                ObdrlList.Pay_Req_Date= String.valueOf(Date.today());
                ObdrlList.Ben_Code= vehDetailList.size() > 0 && vehDetailList[0].Ben_Code__c != null ? String.valueOf(vehDetailList[0].Ben_Code__c) : ' 0';
                ObdrlList.IBL_Lien_Marked= 'N';
                objDRLList.add(ObdrlList);
            }

            if(finalTermList[0].RC_limit_enabled_DSA__c == true && opptyDetails.Vehicle_Type__c != 'New' && opptyDetails.Product_Type__c == 'Passenger Vehicles' && (opptyDetails.LeadSource != 'OLA' && opptyDetails.LeadSource != 'D2C')){
                PactLmsRequestHelper.objDRLList ObdsalList = new PactLmsRequestHelper.objDRLList();
                ObdsalList.Deal_No= dealNumber;
                ObdsalList.Pay_Req_Date= String.valueOf(Date.today());
                ObdsalList.Ben_Code= finalTermList.size() > 0 && finalTermList[0].Referrer_Ben_Code__c != null ? finalTermList[0].Referrer_Ben_Code__c : '0';
                ObdsalList.IBL_Lien_Marked= 'N';
                objDRLList.add(ObdsalList);
            }
            objDRLList=objDRLList;
            this.ObjReqPR.objDRLList=objDRLList;
            
            List<PactLmsRequestHelper.objPRPList> objPRPList = new List<PactLmsRequestHelper.objPRPList>();
            PactLmsRequestHelper.objPRPList ObprpList = new PactLmsRequestHelper.objPRPList();
            
            ObprpList.Deal_No= dealNumber;
            ObprpList.Permit_Nature= '' ;
            ObprpList.Permit_No= '' ;
            ObprpList.Permit_Date= '';
            ObprpList.Permit_Expired_On= '';
            ObprpList.Permit_Regn_No= '' ;
            ObprpList.Permit_Holder_Name= '' ;
            ObprpList.RTO= '';
            ObprpList.Seats_Tonnage= 0;
            ObprpList.Maker_Date= '';
            ObprpList.Permit_Type= '' ;
            ObprpList.Stamping_Agr_No= loanAgreementList.size() > 0 && loanAgreementList[0].Agreement_Booklet_Num__c != null ? String.valueOf(loanAgreementList[0].Agreement_Booklet_Num__c) : '';
            //get first 3 records and send value
            if(loanAgreementList.size() > 0){
                List<Stamp_Detail__c> stampDetailList = new List<Stamp_Detail__c>([Select Id, Stamp_Printed_Location_BlName__c, Stamp_Value__c, Stamp_Type__c From Stamp_Detail__c Where Loan_Agreement__c=:loanAgreementList[0].Id]);
                if(stampDetailList.size() >= 1){
                    ObprpList.Stamping_Done_At_1= stampDetailList.size() > 0 && stampDetailList[0].Stamp_Printed_Location_BlName__c != null ? stampDetailList[0].Stamp_Printed_Location_BlName__c : '';
                    ObprpList.Stamping_Amt_1= stampDetailList.size() > 0 && stampDetailList[0].Stamp_Value__c != null ? stampDetailList[0].Stamp_Value__c : 0.00;
                    ObprpList.Stamping_Type_1= stampDetailList.size() > 0 && stampDetailList[0].Stamp_Type__c != null ? stampDetailList[0].Stamp_Type__c : '';
                }
                if(stampDetailList.size() >= 2){
                    ObprpList.Stamping_Done_At_2= stampDetailList.size() > 0 && stampDetailList[1].Stamp_Printed_Location_BlName__c != null ? stampDetailList[1].Stamp_Printed_Location_BlName__c : '';
                    ObprpList.Stamping_Amt_2= stampDetailList.size() > 0 && stampDetailList[1].Stamp_Value__c != null ? stampDetailList[1].Stamp_Value__c: 0.00;
                    ObprpList.Stamping_Type_2= stampDetailList.size() > 0 && stampDetailList[1].Stamp_Type__c != null ? stampDetailList[1].Stamp_Type__c: '';
                }
                if(stampDetailList.size() > 2){
                    ObprpList.Stamping_Done_At_3= stampDetailList.size() > 0 && stampDetailList[2].Stamp_Printed_Location_BlName__c != null ? stampDetailList[2].Stamp_Printed_Location_BlName__c : '';
                    ObprpList.Stamping_Amt_3= stampDetailList.size() > 0 && stampDetailList[2].Stamp_Value__c != null ? stampDetailList[2].Stamp_Value__c : 0.00;
                    ObprpList.Stamping_Type_3= stampDetailList.size() > 0 && stampDetailList[2].Stamp_Value__c != null ? stampDetailList[2].Stamp_Type__c : '';
                }
            }
            ObprpList.Stamping_Done_At_1 = ObprpList.Stamping_Done_At_1 == null ? '':ObprpList.Stamping_Done_At_1;
            ObprpList.Stamping_Amt_1 =  ObprpList.Stamping_Amt_1 == null ? 0.00 : ObprpList.Stamping_Amt_1;
            ObprpList.Stamping_Type_1 = ObprpList.Stamping_Type_1 == null ? '' : ObprpList.Stamping_Type_1;
            ObprpList.Stamping_Done_At_2 = ObprpList.Stamping_Done_At_2 == null ? '' : ObprpList.Stamping_Done_At_2;
            ObprpList.Stamping_Amt_2 = ObprpList.Stamping_Amt_2 == null ? 0.00 : ObprpList.Stamping_Amt_2;
            ObprpList.Stamping_Type_2 = ObprpList.Stamping_Type_2 == null ? '' : ObprpList.Stamping_Type_2;
            ObprpList.Stamping_Done_At_3 = ObprpList.Stamping_Done_At_3 == null ? '' : ObprpList.Stamping_Done_At_3;
            ObprpList.Stamping_Amt_3 = ObprpList.Stamping_Amt_3 == null ? 0.00 : ObprpList.Stamping_Amt_3;
            ObprpList.Stamping_Type_3 = ObprpList.Stamping_Type_3 == null ? '' : ObprpList.Stamping_Type_3;
            objPRPList.add(ObprpList);
            objPRPList=objPRPList;
            this.ObjReqPR.objPRPList=objPRPList;
            
            List<PactLmsRequestHelper.objSANDList> objSANDList = new List<PactLmsRequestHelper.objSANDList>();
            PactLmsRequestHelper.objSANDList ObsandList = new PactLmsRequestHelper.objSANDList();
            
            ObsandList.Deal_No= dealNumber;
            ObsandList.Nominee_Name=  casaBankFormList.size() > 0 && casaBankFormList[0].Nominee_name__c != null ? String.valueOf(casaBankFormList[0].Nominee_name__c) : '';
            ObsandList.Nominee_Relationship= casaBankFormList.size() > 0 && casaBankFormList[0].Relationship_with_borrower__c != null ? String.valueOf(casaBankFormList[0].Relationship_with_borrower__c) : '';
            ObsandList.Nominee_Addr1=  casaBankFormList.size() > 0 && casaBankFormList[0].Nominee_address__c != null ? String.valueOf(casaBankFormList[0].Nominee_address__c) : '';
            ObsandList.Nominee_Addr2= '';
            ObsandList.Nominee_Addr3= '';
            ObsandList.Nominee_City_Code= '';
            ObsandList.Nominee_City=  casaBankFormList.size() > 0 && casaBankFormList[0].Finacle_City__c != null ? String.valueOf(casaBankFormList[0].Finacle_City__r.Name) : '';
            ObsandList.Nominee_State=  casaBankFormList.size() > 0 && casaBankFormList[0].Geo_State_Master__c != null ? String.valueOf(casaBankFormList[0].Geo_State_Master__r.Name) : '';
            ObsandList.Nominee_PinCode=  casaBankFormList.size() > 0 && casaBankFormList[0].Nominee_pin_code__c != null ? String.valueOf(casaBankFormList[0].Nominee_pin_code__c) : '';
            if(isTractor){
                ObsandList.Nominee_DOB=  casaBankFormList.size() > 0 && casaBankFormList[0].Nominee_DOB__c != null ? String.valueof(Date.valueOf(casaBankFormList[0].Nominee_DOB__c)) : '';
            }else{
                ObsandList.Nominee_DOB=  casaBankFormList.size() > 0 && casaBankFormList[0].Nominee_DOB__c != null ? casaBankFormList[0].Nominee_DOB__c.format() : '';
            }
            ObsandList.Guardian_Name= '';
            ObsandList.Guardian_Code= '' ;
            ObsandList.Guardian_Addr1= '' ;
            ObsandList.Guardian_Addr2= '' ;
            ObsandList.Guardian_Addr3= '' ;
            ObsandList.Guardian_City_Code= '' ;
            ObsandList.Guardian_City= '' ;
            ObsandList.Guardian_State= '' ;
            ObsandList.Guardian_PinCode= '' ;
            ObsandList.SA_Account_BarCodeNo= casaBankFormList.size() > 0 && casaBankFormList[0].Saving_Account_opening_form_No__c != null ? casaBankFormList[0].Saving_Account_opening_form_No__c : '';//CISP-4468
            ObsandList.Nominee_Available= casaBankFormList.size() > 0 && casaBankFormList[0].Nominee_available__c == true ? 'Y' : casaBankFormList.size() > 0 && casaBankFormList[0].Nominee_available__c == false ? 'N' : '';
            
            objSANDList.add(ObsandList);
            objSANDList=objSANDList;
            this.ObjReqPR.objSANDList=objSANDList;
            
            //create DocumentObjectInfo
            //get contentVersion details
            this.ObjReqPR.objDocumentInfo = Utilities.getDocumentInfo(loanAppId,TeleVerificationList,loanDocumentList);
            
        }
        validate(System.Label.TextMatch);
    }
    
    //Method to get the HTTP request header data
    public override Map<String,String> getHttpRequestHeaders(){    
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }
    
    //Method to validate the request data
    public override boolean validate(String serviceName){
        List<String> errorMessageList = new List<String>();
       if(String.isBlank(this.loanAppId)){
            ErrorLoggerUtil.logErrorEvent('IND_TextMatchRequest', 'validate', System.Label.Apex, new AuraHandledException(System.Label.LeadId));
            throw new IND_Exception(System.Label.LeadId);
        }
        return true;
    }
}