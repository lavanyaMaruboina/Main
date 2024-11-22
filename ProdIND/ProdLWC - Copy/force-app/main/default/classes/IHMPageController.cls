/*------------------------------------------------------------
 Author:        Gaurav Rawat
 Company:       Manras
 Description:   This class is used for the IHM page LWC component.
 Apex Class :   IHMPageController
 Test Class:    IHMPageControllerTest
 History
 Date            Author              Comments
 -------------------------------------------------------------
 05-02-2022       Gaurav Rawat      Created

 06-15-2022      Gaurav Rawat   Modified
 ------------------------------------------------------------*/
 public with sharing class IHMPageController{
    /*
* @Method:      getIHMDetails
* @Created by:  Gaurav Rawat 
* @Description: Method to return Wrapper class object for IHM page.
* @Param:       String - loanAppId
* @Return:      IHMWrapper
*/
@AuraEnabled
public static IHMWrapper getIHMDetails(String loanAppId, String dealId){
    try{
        Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanAppId WITH SECURITY_ENFORCED];
        IHMWrapper iHMwrapper = new IHMWrapper();
        IHMRecordWrapper iHMRecWrapper = new IHMRecordWrapper(oppRec); //SFTRAC-1676 added oppRec Parameter in wapper
        FinalTermWrapper finalTermObj = new FinalTermWrapper();
        ReadOnlyWrapper readOnlyWrapperObj = IHMPageController.checkIfReadOnly(loanAppId,dealId);
        readOnlyWrapperObj.readOnly = (readOnlyWrapperObj.stageName == System.Label.Post_Sanction_Checks_and_Documentation && !readOnlyWrapperObj.readOnly) ? false : true;
        Double totalNonFundedAmount = 0;
        Double saAccountOpeningCharges = 0;
        List<IHM__c> ihmList = new List<IHM__c>();

        if(oppRec.Product_Type__c == System.Label.Tractor){
            ihmList = [SELECT Id,Loan_Application__r.Vehicle_Type__c,Total_IHM_paid_to_dealer_A__c,Is_motor_insurance_funded__c,Xst_Year_Motor_Insurance_Premium_X__c,Exshoroom_price__c,On_Road_Price__c,Invoice_price_B__c,Pay_ins_Service_charges__c,Pay_ins_Documentation_charges__c,Pay_ins_Stamping_charges__c,Pay_ins_Trade_certificate_fee__c,Pay_ins_Due_date_shift_charges__c,Total_of_above_Pay_ins_D__c,Total_nonfunded_insurance_B__c,EMI_amount__c,Valuation_charges_D__c,SA_account_opening_charges__c,Margin_money_to_be_deducted_from_disburs__c,Total_Non_funded_insurance_amount__c,Total_nonfunded_insurance_C__c,Has_customer_opted_for_Advance_EMI__c,Total_EMI_to_be_considered_for_IHM_I__c,Total_amount_paid_to_bank__c,Loan_amt_sanctioned_F_excl_fund_insu__c,Total_amount_to_be_paid_by_customer_G__c,Total_amount_customer_paid_to_bank_E__c,Customer_need_to_pay_additional_amount__c,Additional_IHM_amount_to_be_paid__c,Remarks__c,Select_Yes_if_IHM_details_are_correct__c,CVO_Remarks__c,IHM_Recovery__c,Valuation_Charges_Borne_By__c 
                        FROM IHM__c 
                        WHERE Loan_Application__c = :loanAppId AND Deal_Number__c =: dealId
                        WITH SECURITY_ENFORCED 
                        LIMIT 1];
        }else{
            ihmList = [SELECT Id,Loan_Application__r.Vehicle_Type__c,Total_IHM_paid_to_dealer_A__c,Is_motor_insurance_funded__c,Xst_Year_Motor_Insurance_Premium_X__c,Exshoroom_price__c,On_Road_Price__c,Invoice_price_B__c,Pay_ins_Service_charges__c,Pay_ins_Documentation_charges__c,Pay_ins_Stamping_charges__c,Pay_ins_Trade_certificate_fee__c,Pay_ins_Due_date_shift_charges__c,Total_of_above_Pay_ins_D__c,Total_nonfunded_insurance_B__c,EMI_amount__c,Valuation_charges_D__c,SA_account_opening_charges__c,Margin_money_to_be_deducted_from_disburs__c,Total_Non_funded_insurance_amount__c,Total_nonfunded_insurance_C__c,Has_customer_opted_for_Advance_EMI__c,Total_EMI_to_be_considered_for_IHM_I__c,Total_amount_paid_to_bank__c,Loan_amt_sanctioned_F_excl_fund_insu__c,Total_amount_to_be_paid_by_customer_G__c,Total_amount_customer_paid_to_bank_E__c,Customer_need_to_pay_additional_amount__c,Additional_IHM_amount_to_be_paid__c,Remarks__c,Select_Yes_if_IHM_details_are_correct__c,CVO_Remarks__c,IHM_Recovery__c,Valuation_Charges_Borne_By__c 
                        FROM IHM__c 
                        WHERE Loan_Application__c = :loanAppId 
                        WITH SECURITY_ENFORCED 
                        LIMIT 1];
        }

        if(readOnlyWrapperObj.readOnly && ihmList.size() > 0){
            iHMRecWrapper.marginTobeDeducted = ihmList[0].Margin_money_to_be_deducted_from_disburs__c;
            iHMRecWrapper.totalAmountToBeByG = ihmList[0].Total_amount_to_be_paid_by_customer_G__c;
            iHMRecWrapper.totalNonFundedInsC = ihmList[0].Total_nonfunded_insurance_C__c;
            iHMRecWrapper.totalOfAbovePayD = ihmList[0].Total_of_above_Pay_ins_D__c;
            iHMRecWrapper.customerNeedToPay = ihmList[0].Customer_need_to_pay_additional_amount__c;
            iHMRecWrapper.additionalIHMAmount = ihmList[0].Additional_IHM_amount_to_be_paid__c;

            iHMRecWrapper.cvoRemarks = ihmList[0].CVO_Remarks__c;
            iHMRecWrapper.eMIAmount = ihmList[0].EMI_amount__c;
            iHMRecWrapper.exshoroomPrice = ihmList[0].Exshoroom_price__c;
            iHMRecWrapper.hasCustomerOptedForAdvanceEMI = ihmList[0].Has_customer_opted_for_Advance_EMI__c;
            iHMRecWrapper.invoicePrice = ihmList[0].Invoice_price_B__c;
            iHMRecWrapper.isMotorInsuranceFunded = ihmList[0].Is_motor_insurance_funded__c == 'Yes' ? 'Yes' : 'No';
            iHMRecWrapper.loanAmtSanctionedFexclFundInsu = ihmList[0].Loan_amt_sanctioned_F_excl_fund_insu__c;
            iHMRecWrapper.onRoadPrice = ihmList[0].On_Road_Price__c;
            iHMRecWrapper.remarks = ihmList[0].Remarks__c;
            iHMRecWrapper.selectYesIfIHMdetailsAreCorrect = ihmList[0].Select_Yes_if_IHM_details_are_correct__c ? 'Yes' : 'No';
            iHMRecWrapper.toalAmountPaidToBank = ihmList[0].Total_amount_paid_to_bank__c;
            iHMRecWrapper.totalIHMpaidToDealer = ihmList[0].Total_IHM_paid_to_dealer_A__c;
            iHMRecWrapper.totalNonfundedInsurance = ihmList[0].Total_nonfunded_insurance_B__c;
            iHMRecWrapper.valuationCharge = ihmList[0].Valuation_charges_D__c;
            iHMRecWrapper.xstYearMotorInsurancePremium = ihmList[0].Xst_Year_Motor_Insurance_Premium_X__c;
            iHMRecWrapper.vehicleType  = ihmList[0].Loan_Application__r.Vehicle_Type__c == null ? '' : ihmList[0].Loan_Application__r.Vehicle_Type__c;
            iHMRecWrapper.ihmRecoveryValue  = ihmList[0].IHM_Recovery__c;

            finalTermObj.documentationCharges = ihmList[0].Pay_ins_Documentation_charges__c;
            finalTermObj.dueDateShiftCharges = ihmList[0].Pay_ins_Due_date_shift_charges__c;
            finalTermObj.serviceCharges = ihmList[0].Pay_ins_Service_charges__c;
            finalTermObj.totalEmiToConsider = ihmList[0].Total_EMI_to_be_considered_for_IHM_I__c;
            finalTermObj.tradeCertificate = ihmList[0].Pay_ins_Trade_certificate_fee__c;
            finalTermObj.stampingCharges = ihmList[0].Pay_ins_Stamping_charges__c;

            saAccountOpeningCharges = ihmList[0].SA_account_opening_charges__c;
            totalNonFundedAmount = ihmList[0].Total_Non_funded_insurance_amount__c;
        }
        else{
            String productType = '';

            List<Final_Term__c> finaltermsList = new List<Final_Term__c>();
            List<InsuranceDetails__c> insuranceList = new List<InsuranceDetails__c>();

            if(oppRec.Product_Type__c == System.Label.Tractor){
                List<Vehicle_Detail__c> VehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
                finaltermsList = [SELECT Id,Emi_Amount__c,Advance_EMI__c,Loan_Amount__c,Documentation_charges__c, Due_date_shift_charges__c, Trade_certificate__c, Stamping_charges__c,Service_charges__c,Installment_Type__c FROM Final_Term__c WHERE Loan_Application__c = :loanAppId AND Vehicle_Detail__c =: VehicleLst[0].Id WITH SECURITY_ENFORCED LIMIT 1];
                insuranceList = [SELECT Id,Amount__c,Funded_Non_funded__c FROM InsuranceDetails__c WHERE Loan_Application__c=:loanAppId AND Name = 'MOTOR' AND Vehicle_Detail__c =: VehicleLst[0].Id WITH SECURITY_ENFORCED LIMIT 1];
            }else{
                finaltermsList = [SELECT Id,Emi_Amount__c,Advance_EMI__c,Loan_Amount__c,Documentation_charges__c, Due_date_shift_charges__c, Trade_certificate__c, Stamping_charges__c,Service_charges__c,Installment_Type__c 
                                    FROM Final_Term__c 
                                    WHERE Loan_Application__c = :loanAppId 
                                    WITH SECURITY_ENFORCED  
                                    LIMIT 1];
            }

            if(oppRec.Product_Type__c != System.Label.Tractor){
                insuranceList = [SELECT Id,Amount__c,Funded_Non_funded__c FROM InsuranceDetails__c WHERE Loan_Application__c=:loanAppId AND Name = 'MOTOR' WITH SECURITY_ENFORCED LIMIT 1];
            }

            for(Opportunity loanApplication : [Select id,Total_Funded_Premium__c,Other_Charges__c,Funded__c,Product_Type__c,Vehicle_Type__c,X1st_yr_Insurance_Premium__c,Advance_EMI__c,EMI_Amount__c,Ex_showroom_price__c,On_Road_price__c From Opportunity Where id = :loanAppId WITH SECURITY_ENFORCED  LIMIT 1]){
                productType = loanApplication.Product_Type__c;
                iHMRecWrapper.isMotorInsuranceFunded = insuranceList.size() > 0 ? insuranceList[0].Funded_Non_funded__c == 'Funded' ? 'Yes' : insuranceList[0].Funded_Non_funded__c == 'Non-Funded' ?'No' : 'No' : 'No';
                iHMRecWrapper.xstYearMotorInsurancePremium = insuranceList.size() > 0 ? insuranceList[0].Amount__c : 0;
                iHMRecWrapper.hasCustomerOptedForAdvanceEMI = !finaltermsList.isEmpty() ? finaltermsList[0].Advance_EMI__c == true  ? 'Yes' : 'No' : 'No';
                iHMRecWrapper.emiAmount = finaltermsList.isEmpty() ? 0 : finaltermsList[0].EMI_Amount__c == null ? 0 : finaltermsList[0].EMI_Amount__c;
                iHMRecWrapper.exshoroomPrice = loanApplication.Ex_showroom_price__c == null ? 0 : loanApplication.Ex_showroom_price__c;
                iHMRecWrapper.onRoadPrice = loanApplication.On_Road_price__c == null ? 0 : loanApplication.On_Road_price__c;
                iHMRecWrapper.loanAmtSanctionedFexclFundInsu = !finaltermsList.isEmpty() ? finaltermsList[0].Loan_amount__c == null ? 0 : Decimal.valueOf(finaltermsList[0].Loan_amount__c) : 0 ;

                if(ihmList.size() > 0 && ihmList[0].Total_IHM_paid_to_dealer_A__c > 0){
                    iHMRecWrapper.totalIHMpaidToDealer = ihmList[0].Total_IHM_paid_to_dealer_A__c == null ? 0 : ihmList[0].Total_IHM_paid_to_dealer_A__c;
                }
                iHMRecWrapper.vehicleType = loanApplication.Vehicle_Type__c == null ? '' : loanApplication.Vehicle_Type__c;
            }
            
            List<IHM__c> ihmObjList = new List<IHM__c>();
            if(oppRec.Product_Type__c == System.Label.Tractor){
                ihmObjList = [SELECT Id,Select_Yes_if_IHM_details_are_correct__c,Total_amount_customer_paid_to_bank_E__c,Remarks__c,CVO_Remarks__c,IHM_Recovery__c 
                                FROM IHM__c
                                WHERE Loan_Application__c = :loanAppId AND Deal_Number__c =: dealId
                                WITH SECURITY_ENFORCED LIMIT 1];
            }else{
                ihmObjList = [SELECT Id,Select_Yes_if_IHM_details_are_correct__c,Total_amount_customer_paid_to_bank_E__c,Remarks__c,CVO_Remarks__c,IHM_Recovery__c 
                                FROM IHM__c
                                WHERE Loan_Application__c = :loanAppId 
                                WITH SECURITY_ENFORCED LIMIT 1];
            }

            for(IHM__c ihmObj : ihmObjList){
                iHMRecWrapper.toalAmountPaidToBank = ihmObj.Total_amount_customer_paid_to_bank_E__c == null ? 0 : ihmObj.Total_amount_customer_paid_to_bank_E__c;
                iHMRecWrapper.remarks = ihmObj.Remarks__c == null ? '' : ihmObj.Remarks__c;
                iHMRecWrapper.cvoRemarks = ihmObj.CVO_Remarks__c == null ? '' : ihmObj.CVO_Remarks__c;
                //iHMRecWrapper.selectYesIfIHMdetailsAreCorrect = ihmObj.Select_Yes_if_IHM_details_are_correct__c == false ? 'No' : 'Yes';
                if(oppRec.Product_Type__c == System.Label.Tractor){//SFTRAC-1676
                    iHMRecWrapper.selectYesIfIHMdetailsAreCorrect = 'Yes';
                }else{
                iHMRecWrapper.selectYesIfIHMdetailsAreCorrect = ihmObj.Select_Yes_if_IHM_details_are_correct__c == false ? 'No' : 'Yes';
                }
                iHMRecWrapper.ihmRecoveryValue = ihmObj.IHM_Recovery__c;
            }

            if(opprec.Product_Type__c == System.Label.Tractor){
                for(Invoice_Details__c invoiceDetail : [Select id,Invoice_Amount_incl_discounts__c From Invoice_Details__c Where Loan_Application__c = :loanAppId AND Deal_Number__c =: dealId WITH SECURITY_ENFORCED LIMIT 1]){
                    iHMRecWrapper.invoicePrice = invoiceDetail.Invoice_Amount_incl_discounts__c == null ? 0 : invoiceDetail.Invoice_Amount_incl_discounts__c;
                }
            }else{
                for(Invoice_Details__c invoiceDetail : [Select id,Invoice_Amount_incl_discounts__c From Invoice_Details__c Where Loan_Application__c = :loanAppId WITH SECURITY_ENFORCED LIMIT 1]){
                    iHMRecWrapper.invoicePrice = invoiceDetail.Invoice_Amount_incl_discounts__c == null ? 0 : invoiceDetail.Invoice_Amount_incl_discounts__c;
                }
            }

            for (Final_Term__c ft : finaltermsList){
                finalTermObj.totalEmiToConsider = ft.Advance_EMI__c == false ? 0 : Integer.valueOf(ft.EMI_Amount__c);
                finalTermObj.serviceCharges = ft.Service_charges__c == null ? 0 : (Integer)Decimal.valueof(ft.Service_charges__c);//CISP-3188/CISP-3220
                finalTermObj.documentationCharges = ft.Documentation_charges__c == null ? 0 : (Integer)Decimal.valueof(ft.Documentation_charges__c);//CISP-3188/CISP-3220
                finalTermObj.stampingCharges = ft.Stamping_charges__c == null ? 0 : (Integer)Decimal.valueof(ft.Stamping_charges__c);//CISP-3188/CISP-3220
                finalTermObj.tradeCertificate = ft.Trade_certificate__c == null ? 0 : (Integer)Decimal.valueof(ft.Trade_certificate__c);//CISP-3188/CISP-3220
                finalTermObj.dueDateShiftCharges = ft.Due_date_shift_charges__c == null ? 0 : (Integer)Decimal.valueof(ft.Due_date_shift_charges__c);//CISP-3188/CISP-3220
            }
            if(opprec.Product_Type__c == System.Label.Tractor){
                for (InsuranceDetails__c insuranceObj : [Select id, Amount__c,Funded_Non_funded__c From InsuranceDetails__c Where  Loan_Application__c = :loanAppId AND Funded_Non_funded__c = :System.Label.NonFunded AND Name != :System.Label.MOTOR AND  Vehicle_Detail__r.Deal_Number__c =:dealId WITH SECURITY_ENFORCED LIMIT 100]){
                    totalNonFundedAmount += Double.valueof(insuranceObj.Amount__c);
                }
            }else {
            for (InsuranceDetails__c insuranceObj : [Select id, Amount__c,Funded_Non_funded__c From InsuranceDetails__c Where  Loan_Application__c = :loanAppId AND Funded_Non_funded__c = :System.Label.NonFunded AND Name != :System.Label.MOTOR WITH SECURITY_ENFORCED LIMIT 100]){
                totalNonFundedAmount += Double.valueof(insuranceObj.Amount__c);
                }
            }

            List<CASA_Bank_Form__c> casaList = new List<CASA_Bank_Form__c>([            Select Id From CASA_Bank_Form__c Where Loan_Application__c =:loanAppId 
            ]);
            Boolean isAccountWithIbl = false;
            for (Applicant__c applicant : [Select id, Would_you_like_to_open_a_bank_account__c From Applicant__c Where Opportunity__c = :loanAppId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED LIMIT 10]){
                if (applicant.Would_you_like_to_open_a_bank_account__c  == true && casaList.size() > 0){
                    isAccountWithIbl = true;
                }
            }

            Double saAmountCharge = 0;

            Opportunity opp = [Select Product_Type__c From Opportunity Where id = :loanAppId];
            String productCode = '';
            if(opp.Product_Type__c == System.Label.PassengerVehicles){
                productCode = 'C';
            }else if(opp.Product_Type__c == System.Label.TwoWheeler){
                productCode = 'H';
            }else if(opp.Product_Type__c == System.Label.Tractor){
                productCode = 'T';
            }

            SA_Opening_Charge__mdt[] saOpeningChargesMdt = [Select AC_Open_Charges__c From SA_Opening_Charge__mdt WHERE Product_Code__c =: productCode LIMIT 1];
            if(saOpeningChargesMdt.size() > 0){
                            saAmountCharge = saOpeningChargesMdt.size() > 0 && saOpeningChargesMdt[0].AC_Open_Charges__c == null ? 0 : Double.valueof(saOpeningChargesMdt[0].AC_Open_Charges__c);
            }

            if(opprec.Product_Type__c == System.Label.Tractor){
                List<IHM__c> ihmListforSAOpening = [Select Id, SA_account_opening_charges__c from IHM__c where SA_account_opening_charges__c =:saAmountCharge and Loan_Application__c =: loanAppId Limit 1];
                
                if(ihmListforSAOpening.size() > 0){
                    saAccountOpeningCharges = 0;
                } else{
                    saAccountOpeningCharges = isAccountWithIbl == true ? saAmountCharge : 0;
                }
            }else{
                saAccountOpeningCharges = isAccountWithIbl == true ? saAmountCharge : 0;
            }

            //CISP-2414 - START
            Double serviceCharge = 0;
            Double documentationCharge = 0;
            Double stampingCharge = 0;
            Double tradeCertificate = 0;
            Double dueDateCharge = 0;

            if(finaltermsList.size() > 0){
                serviceCharge = finaltermsList[0].Service_charges__c == null ? 0 : Double.valueof(finaltermsList[0].Service_charges__c);
                documentationCharge = finaltermsList[0].Documentation_charges__c == null ? 0 : Double.valueof(finaltermsList[0].Documentation_charges__c);
                stampingCharge = finaltermsList[0].Stamping_charges__c == null ? 0 : Double.valueof(finaltermsList[0].Stamping_charges__c);
                tradeCertificate = finaltermsList[0].Trade_certificate__c == null ? 0 : Double.valueof(finaltermsList[0].Trade_certificate__c);
                dueDateCharge = finaltermsList[0].Due_date_shift_charges__c == null ? 0 : Double.valueof(finaltermsList[0].Due_date_shift_charges__c);
            }

            iHMRecWrapper.totalOtherCharges = serviceCharge + documentationCharge + stampingCharge + tradeCertificate + dueDateCharge + saAccountOpeningCharges;
            //CISP-2414 - END
        }

        iHMwrapper.iHMRec = iHMRecWrapper;
        iHMwrapper.finalTermRec = finalTermObj;
        iHMwrapper.totalNonFundedAmount = totalNonFundedAmount;
        iHMwrapper.saAccountOpeningCharges = saAccountOpeningCharges;
        return iHMwrapper;
    } catch (Exception e){
        ErrorLoggerUtil.logErrorEvent('IHMPageController', 'getIHMDetails', System.Label.Apex, e, loanAppId);
        throw new AuraHandledException(System.Label.ExceptionMessage);
    }
}

 /*
* @Method:      documentFiles
* @Created by:  Gaurav Rawat 
* @Description: Method to return the document files for the given loan application
* @Param:       String - loanAppId
* @Return:      List<Documents__c>
*/
@AuraEnabled
public static List<Documents__c> documentFiles(String loanAppId, String dealId){
    Opportunity opp = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanAppId WITH SECURITY_ENFORCED];
    if(opp.Product_Type__c == System.Label.Tractor){
        List<Vehicle_Detail__c> VehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
        return [SELECT Id, IHM_receipt_number__c, IHM_receipt_date__c, IHM_amount_as_per_receipt__c, Is_IHM_Receipt_legible__c, Payment_Receipt_Remarks__c,Document_Type__c 
                    FROM Documents__c 
                    WHERE Opportunity_Relation__c = :loanAppId AND Document_Type__c = :System.Label.IHM_Receipt AND Is_Active__c = true AND Vehicle_Detail__c =: VehicleLst[0].Id
                    WITH SECURITY_ENFORCED 
                    LIMIT 100];
    }
    return [Select id, IHM_receipt_number__c, IHM_receipt_date__c, IHM_amount_as_per_receipt__c, Is_IHM_Receipt_legible__c, Payment_Receipt_Remarks__c,Document_Type__c From Documents__c Where Opportunity_Relation__c = :loanAppId AND Document_Type__c = :System.Label.IHM_Receipt AND Is_Active__c = true With SECURITY_ENFORCED LIMIT 100];
}

 /*
* @Method:      insertDocument
* @Created by:  Gaurav Rawat 
* @Description: Method to insert and update document files for the given loan application
* @Param:       String - documentString
* @Return:      String - documentId
*/
@AuraEnabled
public static String insertDocument(String documentString, String loanId, String dealId){
    try{
        Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanId WITH SECURITY_ENFORCED];
        Documents__c document = new Documents__c();
        document = (Documents__c)JSON.deserialize(documentString, Documents__c.class);
        String documentId = '';

        if (Schema.sObjectType.Documents__c.isCreateable() || Schema.sObjectType.Documents__c.isUpdateable()){
            if(oppRec.Product_Type__c == System.Label.Tractor){
                List<Vehicle_Detail__c> VehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId AND Loan_Application__c =: loanId WITH SECURITY_ENFORCED];
                if(String.isBlank(document.Vehicle_Detail__c)){
                    document.Vehicle_Detail__c = VehicleLst[0].Id;
                }
            }
            upsert document;
            documentId = document.Id;

            document.Name = System.Label.IHM_Receipt + ' ' + documentId;
            update document;
        }
        System.debug(documentId);
        return documentId;
    } catch (Exception e){
        ErrorLoggerUtil.logErrorEvent('IHMPageController', 'insertDocument', System.Label.Apex, e, loanId);
        throw new AuraHandledException(System.Label.ExceptionMessage);
    }
}

 /*
* @Method:      deleteDocument
* @Created by:  Gaurav Rawat 
* @Description: Method for the delete document files for the given documentId
* @Param:       String - documentId, String loanId
* @Return:      Boolean
*/
@AuraEnabled
public static Boolean deleteDocument(String documentId, String loanId, String dealId){
    try{
        Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanId WITH SECURITY_ENFORCED];
        List<Documents__c> documents = new List<Documents__c>();
        if(oppRec.Product_Type__c == System.Label.Tractor){
            List<Vehicle_Detail__c> VehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
            documents = [SELECT Id FROM Documents__c WHERE Id = :documentId AND Vehicle_Detail__c =: VehicleLst[0].Id WITH SECURITY_ENFORCED LIMIT 100];
        }else{
            documents = [SELECT Id FROM Documents__c WHERE Id = :documentId WITH SECURITY_ENFORCED LIMIT 100];
        }

        if (Schema.sObjectType.Documents__c.isDeletable()){
            delete documents;
            return true;
        }
        return false;
    } catch (Exception e){
        ErrorLoggerUtil.logErrorEvent('IHMPageController', 'deleteDocument', System.Label.Apex, e, loanId);
        throw new AuraHandledException(System.Label.ExceptionMessage);
    }
}

 /*
* @Method:      validateScreenVisiblity
* @Created by:  Gaurav Rawat 
* @Description: Method to validate the screen visiblity for the given loan application
* @Param:       String - loanAppId
* @Return:      ValidateWrapper - validateWrapperObj
*/
@AuraEnabled
public static ValidateWrapper validateScreenVisiblity(String loanAppId, String dealId){
    try {
        boolean screenVisible = true;
        String stageName = null;
        ValidateWrapper validateWrapperObj = new ValidateWrapper();
        List<Opportunity> oppList = new List<Opportunity>([Select id,StageName From Opportunity Where id =: loanAppId With SECURITY_ENFORCED]);
        if(oppList.size() > 0){
            stageName = oppList[0].stageName;
        }
        if(stageName != null && stageName == System.Label.Post_Sanction_Checks_and_Documentation){
            for(Loan_Application_Transaction_History__c loanHistory : [Select Id,Submitted_Flag__c From Loan_Application_Transaction_History__c Where 
                Module__c =: stageName AND 
                Screen__c =: System.Label.Invoice AND
                Loan_Application_ID__c =: loanAppId AND
                Deal_Number__c =: dealId With SECURITY_ENFORCED LIMIT 100]){
                    if(!loanHistory.Submitted_Flag__c){
                        screenVisible = false;
                    }
            }
        }
        List<Vehicle_Detail__c> vehicleList = new List<Vehicle_Detail__c>();
        if(String.isNotBlank(dealId)){
            vehicleList = [Select Id,Vehicle_SubCategory__c from Vehicle_Detail__c Where Deal_Number__c =: dealId AND Loan_Application__c = :loanAppId LIMIT 1];
        }
        for(Opportunity oppObj : [Select Id,Vehicle_Sub_Category__c,Vehicle_Type__c,Product_Type__c From Opportunity Where id =: loanAppId With SECURITY_ENFORCED LIMIT 1]){
            if((oppObj.Product_Type__c == System.Label.PassengerVehicles || oppObj.Product_Type__c == System.Label.Tractor) && (oppObj.Vehicle_Type__c == System.Label.used || oppObj.Vehicle_Type__c == System.Label.Refinance)){
                validateWrapperObj.isUsedRefinancePV = true;
                if(oppObj.Product_Type__c == System.Label.Tractor){
                    validateWrapperObj.isUsedRefinanceUPD = vehicleList.size() > 0 && vehicleList[0].Vehicle_SubCategory__c == 'UPD' ? true : false;
                    validateWrapperObj.isIHMReceiptShow = vehicleList.size() > 0 && vehicleList[0].Vehicle_SubCategory__c == 'UPD' ? true : false;
                }else{
                    validateWrapperObj.isUsedRefinanceUPD = oppObj.Vehicle_Sub_Category__c == 'UPD' ? true : false;
                    validateWrapperObj.isIHMReceiptShow = oppObj.Vehicle_Sub_Category__c == 'UPD' ? true : false;
                }
            }else{
                validateWrapperObj.isUsedRefinancePV = false;
                validateWrapperObj.isUsedRefinanceUPD = false;
                validateWrapperObj.isIHMReceiptShow = true;
            }
            if(oppObj.Product_Type__c == System.Label.TwoWheeler && oppObj.Vehicle_Type__c == System.Label.new){
                validateWrapperObj.isNewTwoWheeler = true;
            }
        }
        validateWrapperObj.screenName = stageName;
        validateWrapperObj.screenVisible = screenVisible;
        
        return validateWrapperObj;
    } catch (Exception e) {
        ErrorLoggerUtil.logErrorEvent('IHMPageController', 'validateScreenVisiblity', System.Label.Apex, e, loanAppId);
        throw new AuraHandledException(System.Label.ExceptionMessage);
    }
}

/*------------------------------------------------------------
Author:        Gaurav Rawat
Description:   Wrapper class for IHM page screen Name and screen visibile fields
Apex Class :   ValidateWrapper
------------------------------------------------------------*/
public class ValidateWrapper{
    @AuraEnabled
    public Boolean screenVisible{get;set;}
    @AuraEnabled
    public String screenName{get;set;}
    @AuraEnabled
    public Boolean isUsedRefinancePV{get;set;}
    @AuraEnabled
    public Boolean isUsedRefinanceUPD{get;set;}
    @AuraEnabled
    public Boolean isNewTwoWheeler{get;set;}
    @AuraEnabled
    public Boolean isIHMReceiptShow{get;set;}
    public ValidateWrapper(){
        screenVisible = true;
        screenName = '';
        isNewTwoWheeler = false;
    }
}

 /*
* @Method:      checkIfReadOnly
* @Created by:  Gaurav Rawat 
* @Description: Method to check if the screen is read only for the given loan application
* @Param:       String - loanId
* @Return:      ReadOnlyWrapper
*/
@AuraEnabled
public static ReadOnlyWrapper checkIfReadOnly(String loanId, String dealId){
    try{
        ReadOnlyWrapper readOnlyWrapperObj = new ReadOnlyWrapper();
        String stageName = null;
        List<Opportunity> oppList = new List<Opportunity>([Select id,StageName From Opportunity Where id =: loanid With SECURITY_ENFORCED LIMIT 1]);
        if(oppList.size() > 0){
            stageName = oppList[0].stageName;
            readOnlyWrapperObj.stageName = stageName;
        }
        List<Loan_Application_Transaction_History__c> lATList = new List<Loan_Application_Transaction_History__c>([Select id, Name, Submitted_Flag__c from Loan_Application_Transaction_History__c where Loan_Application_ID__c = :loanId And Screen__c = :System.Label.IHM And Module__c =: stageName And Deal_Number__c =: dealId WITH SECURITY_ENFORCED LIMIT 100]);
        
        if(stageName == System.Label.Pre_Disbursement_Check){
            readOnlyWrapperObj.readOnly = true;
            return readOnlyWrapperObj;
        }else if (lATList.size() > 0){
            readOnlyWrapperObj.readOnly = lATList[0].Submitted_Flag__c;
            return readOnlyWrapperObj;
        }
        return readOnlyWrapperObj;
    } catch (Exception e){
        ErrorLoggerUtil.logErrorEvent('IHMPageController', 'checkIfReadOnly', System.Label.Apex, e, loanId);
        throw new AuraHandledException(System.Label.ExceptionMessage);
    }
}

/*
*@Wrapper Class    ReadOnlyWrapper
*@Created by:     Gaurav Rawat
*@Description:   Wrapper class for IHM page screen Name and screen visibile fields
*@Apex Class :    ReadOnlyWrapper
*/
public class ReadOnlyWrapper{
    @AuraEnabled
    public Boolean readOnly{get;set;}
    @AuraEnabled
    public String stageName{get;set;}
}

 /*
* @Method:      submitIHMRecord
* @Created by:  Gaurav Rawat 
* @Description: Method to submit the IHM record for the given loan application
* @Param:       String - loanId
* @Return:      boolean
*/
@AuraEnabled
public static Boolean submitIHMRecord(String loanId, String dealId){
    try{
        String stageName = null;
        List<Opportunity> oppList = new List<Opportunity>([Select id,StageName From Opportunity Where id =: loanid With SECURITY_ENFORCED LIMIT 1]);
        if(oppList.size() > 0){
            stageName = oppList[0].stageName;
        }
        List<Loan_Application_Transaction_History__c> lATList = new List<Loan_Application_Transaction_History__c>([Select id, Name, Submitted_Flag__c from Loan_Application_Transaction_History__c where Loan_Application_ID__c = :loanId and Screen__c = :System.Label.IHM And Module__c =: stageName And Deal_Number__c =: dealId WITH SECURITY_ENFORCED LIMIT 100]);

        if (lATList.size() > 0){
            Loan_Application_Transaction_History__c loanHistory = lATList[0];
            loanHistory.Submitted_Flag__c = true;
            if(Schema.sObjectType.Loan_Application_Transaction_History__c.isUpdateable()){
                update loanHistory;
                return true;
            }
        }

        return false;
    } catch (Exception e){
        ErrorLoggerUtil.logErrorEvent('IHMPageController', 'submitIHMRecord', System.Label.Apex, e, loanId);
        throw new AuraHandledException(System.Label.ExceptionMessage);
    }
}

 /*
* @Method:      updateLoanAppHistory
* @Created by:  Gaurav Rawat 
* @Description: Method to update the Loan Application Transaction History for the given loan application
* @Param:       String - loanId
* @Return:      boolean
*/
@AuraEnabled
public static Boolean updateLoanAppHistory(String loanId, String dealId){
    try{
        String stageName = System.Label.Post_Sanction_Checks_and_Documentation;

        List<Loan_Application_Transaction_History__c> lATList = new List<Loan_Application_Transaction_History__c>([Select id, Name, Submitted_Flag__c from Loan_Application_Transaction_History__c where Loan_Application_ID__c = :loanId and Screen__c = :System.Label.IHM And Module__c =: stageName And Deal_Number__c =: dealId WITH SECURITY_ENFORCED LIMIT 100]);

        if (lATList.size() > 0){
            Loan_Application_Transaction_History__c loanHistory = lATList[0];
            loanHistory.Submitted_Flag__c = false;
            if(Schema.sObjectType.Loan_Application_Transaction_History__c.isUpdateable()){
                update loanHistory;
                return true;
            }
        }

        return false;
    } catch (Exception e){
        ErrorLoggerUtil.logErrorEvent('IHMPageController', 'updateLoanAppHistory', System.Label.Apex, e, loanId);
        throw new AuraHandledException(System.Label.ExceptionMessage);
    }
}

 /*
* @Method:      loanApplicationRelated
* @Created by:  Gaurav Rawat 
* @Description: Method to check if the loan application is related to the given loan application
* @Param:       String - loanId, String - currentStep
* @Return:      RelatedIdWrapper - relatedIdWrapperObj
*/
@AuraEnabled
public static RelatedIdWrapper loanApplicationRelated(String loanId, String currentStep, String dealId){
    try{
        Opportunity opp = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanId WITH SECURITY_ENFORCED];
        List<Profile> profileList = new List<Profile>([SELECT Id, Name,UserType FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1]);
        String currentProfileName = profileList[0].Name;
        String currentStageName = null;
        String productType = null;

        RelatedIdWrapper relatedIdWrapperObj = new RelatedIdWrapper();
        List<Opportunity> oppList = new List<Opportunity>([Select id,StageName,Product_Type__c,Vehicle_type__c,Vehicle_Sub_Category__c From Opportunity Where id=:loanId WITH SECURITY_ENFORCED LIMIT 1]);
        if(oppList.size() > 0){
            currentStageName = oppList[0].StageName;
            productType = oppList[0].Product_Type__c;
            relatedIdWrapperObj.productType = oppList[0].Product_Type__c;
        }
        if(profileList[0].UserType == 'PowerPartner'){
            relatedIdWrapperObj.isCommunityUser = true;
        }
        List<Loan_Application_Transaction_History__c> lATList = new List<Loan_Application_Transaction_History__c>([Select id, Name, Submitted_Flag__c from Loan_Application_Transaction_History__c where Loan_Application_ID__c = :loanId And Screen__c = :System.Label.IHM And Module__c =: currentStageName And Deal_Number__c =: dealId WITH SECURITY_ENFORCED LIMIT 100]);
        if(lATList.size() > 0){
            relatedIdWrapperObj.cvoEnabledField = lATList[0].Submitted_Flag__c;
        }
        if(((currentProfileName == System.Label.IBL_CVO || currentProfileName == System.Label.IBL_Partner_Community_CVO) || (productType == System.Label.Tractor && (currentProfileName == 'IBL TF Payment Executive' || currentProfileName == 'IBL TF Internal Payment Executive'))) && currentStageName == System.Label.Pre_Disbursement_Check){
            if(lATList.size() > 0){
                relatedIdWrapperObj.cvoEnabledField = lATList[0].Submitted_Flag__c == true ? true : false;
            }
        }else{
            relatedIdWrapperObj.cvoEnabledField = true;
        }
        if(currentStageName == System.Label.Pre_Disbursement_Check && currentStep == System.Label.PostSanction){
            relatedIdWrapperObj.cvoEnabledField = true;
        }
        if(currentStageName == System.Label.Pre_Disbursement_Check){
            relatedIdWrapperObj.preCalSubmitDisabled = true;
        }

        List<IHM__c> iHMList = new List<IHM__c>();
        if(opp.Product_Type__c == System.Label.Tractor){
            iHMList = [SELECT Id,Valuation_charges_D__c,Valuation_Charges_Borne_By__c
                        FROM IHM__c
                        WHERE Loan_Application__c = :loanId AND Deal_Number__c =: dealId
                        WITH SECURITY_ENFORCED
                        LIMIT 1];
        }else{
            iHMList = [SELECT Id,Valuation_charges_D__c,Valuation_Charges_Borne_By__c
                        FROM IHM__c
                        WHERE Loan_Application__c = :loanId
                        WITH SECURITY_ENFORCED
                        LIMIT 1];
        }
        
        if(iHMList.size() == 0){
            IHM__c ihm = new IHM__c();
            ihm.Loan_Application__c = loanId;
            if(opp.Product_Type__c == System.Label.Tractor){
                ihm.Deal_Number__c = dealId;
            }
            if(Schema.sObjectType.IHM__c.isCreateable()){
                insert ihm;
                relatedIdWrapperObj.ihmId = ihm.Id;
            }
        }else{
            for (IHM__c iHMObj : iHMList){
                relatedIdWrapperObj.ihmId = iHMObj.Id;
            }
        }
        for (Applicant__c applicant : [Select id From Applicant__c Where Opportunity__c = :loanId AND Applicant_Type__c = :System.Label.Borrower AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED LIMIT 10]){
            relatedIdWrapperObj.applicantId = applicant.Id;
        }
        
        List<Vehicle_Detail__c> vehicleDetailList = new List<Vehicle_Detail__c>();
        if(opp.Product_Type__c == System.Label.Tractor){
            vehicleDetailList = [SELECT Id ,Valuer_category__c,Loan_Application__r.Product_Type__c,Loan_Application__r.Vehicle_Sub_Category__c,Vehicle_type__c,MFC_valuation_Report_URL__c 
                                    FROM Vehicle_Detail__c 
                                    WHERE Loan_Application__c = :loanId AND Deal_Number__c =: dealId
                                    WITH SECURITY_ENFORCED 
                                    LIMIT 1];
        }else{
            vehicleDetailList = [SELECT Id ,Valuer_category__c,Loan_Application__r.Product_Type__c,Loan_Application__r.Vehicle_Sub_Category__c,Vehicle_type__c,MFC_valuation_Report_URL__c 
                                    FROM Vehicle_Detail__c 
                                    WHERE Loan_Application__c = :loanId
                                    WITH SECURITY_ENFORCED 
                                    LIMIT 1];
        }
        
        for(Vehicle_Detail__c vehicle : vehicleDetailList){
            relatedIdWrapperObj.valuerCategory = vehicle.Valuer_category__c;
            relatedIdWrapperObj.productType = vehicle.Loan_Application__r.Product_Type__c;
            if(vehicle.Loan_Application__r.Product_Type__c == System.Label.PassengerVehicles || vehicle.Loan_Application__r.Product_Type__c == System.Label.Tractor){
                if(vehicle.Valuer_category__c == System.Label.MFC && vehicle.MFC_valuation_Report_URL__c != null){
                    relatedIdWrapperObj.ihmvaluationcharges = 550 + ((550*18)/100);
                    relatedIdWrapperObj.valuationDisabled = true;
                }else if(vehicle.Valuer_category__c == System.Label.Empanelled){
                    relatedIdWrapperObj.borneValue = iHMList.size()>0 ? iHMList[0].Valuation_Charges_Borne_By__c : '';
                    relatedIdWrapperObj.ihmvaluationcharges = iHMList.size()>0 ?  iHMList[0].Valuation_charges_D__c != null ? iHMList[0].Valuation_charges_D__c : null : null;
                    relatedIdWrapperObj.valuationDisabled = false;
                }else{
                    relatedIdWrapperObj.ihmvaluationcharges = 0;
                    relatedIdWrapperObj.valuationDisabled = true;
                }
            }else if(vehicle.Loan_Application__r.Product_Type__c == System.Label.TwoWheeler){
                relatedIdWrapperObj.ihmvaluationcharges = 0;
                relatedIdWrapperObj.valuationDisabled = true;
            }
        }         
        return relatedIdWrapperObj;
    } catch (Exception e){
        ErrorLoggerUtil.logErrorEvent('IHMPageController', 'loanApplicationRelated', System.Label.Apex, e, loanId);
        throw new AuraHandledException(System.Label.ExceptionMessage);
    }
}

/*
* @Class:      RelatedIdWrapper
* @Created by:  Gaurav Rawat
* @Description: Class to store the related Ids
*/
public class RelatedIdWrapper{
    @AuraEnabled
    public String ihmId{ get; set; }
    @AuraEnabled
    public String applicantId{ get; set; }   
    @AuraEnabled
    public Boolean cvoEnabledField{ get; set; }   
    @AuraEnabled
    public Boolean preCalSubmitDisabled{ get; set; }
    @AuraEnabled
    public Boolean valuationDisabled{ get; set; }
    @AuraEnabled
    public Double ihmvaluationcharges{ get; set; }
    @AuraEnabled
    public String borneValue{ get; set; }
    @AuraEnabled
    public String valuerCategory{ get; set; }    
    @AuraEnabled
    public Boolean isCommunityUser{get;set;}
    @AuraEnabled
    public String productType{get;set;}
    RelatedIdWrapper(){
        this.ihmId = '';
        this.applicantId = '';
        this.cvoEnabledField = true;
        this.preCalSubmitDisabled = false;
        this.ihmvaluationcharges = 0;
        this.valuationDisabled = true;
        this.borneValue = '';
        this.valuerCategory = '';
        this.isCommunityUser = false;
        this.productType = '';
    }
} 

/*
* @Class:      IHMWrapper
* @Created by:  Gaurav Rawat
* @Description: Class to store the IHM data
*/
// wrapper to bind IHM record, Term and receipt doc.
public class IHMWrapper{
    @AuraEnabled
    public IHMRecordWrapper iHMRec{ get; set; }
    @AuraEnabled
    public FinalTermWrapper finalTermRec{ get; set; }
    @AuraEnabled
    public Double totalNonFundedAmount{ get; set; }
    @AuraEnabled
    public Double saAccountOpeningCharges{ get; set; }
}
/*
* @Class:      IHMRecordWrapper
* @Created by:  Gaurav Rawat
* @Description: Class to store the Final Term record data
*/
public class FinalTermWrapper{
    @AuraEnabled
    public double serviceCharges{ get; set; }
    @AuraEnabled
    public double totalEmiToConsider{ get; set; }
    @AuraEnabled
    public double documentationCharges{ get; set; }
    @AuraEnabled
    public double stampingCharges{ get; set; }
    @AuraEnabled
    public double tradeCertificate{ get; set; }
    @AuraEnabled
    public double dueDateShiftCharges{ get; set; }
    public FinalTermWrapper(){
        this.serviceCharges = 0;
        this.totalEmiToConsider = 0;
        this.documentationCharges = 0;
        this.stampingCharges = 0;
        this.tradeCertificate = 0;
        this.dueDateShiftCharges = 0;
    }
}
/*
* @Class:      IHMRecordWrapper
* @Created by:  Gaurav Rawat
* @Description: Class to store the IHM record data
*/
public class IHMRecordWrapper{
    @AuraEnabled
    public double exshoroomPrice{ get; set; }
    @AuraEnabled
    public double totalOtherCharges{ get; set; }
    @AuraEnabled
    public double onRoadPrice{ get; set; }
    @AuraEnabled
    public double invoicePrice{ get; set; }
    @AuraEnabled
    public string isMotorInsuranceFunded{ get; set; }
    @AuraEnabled
    public double xstYearMotorInsurancePremium{ get; set; }
    @AuraEnabled
    public string hasCustomerOptedForAdvanceEMI{ get; set; }
    @AuraEnabled
    public double eMIAmount{ get; set; }
    @AuraEnabled
    public double loanAmtSanctionedFexclFundInsu{ get; set; }
    @AuraEnabled
    public string remarks{ get; set; }            
    @AuraEnabled
    public string cvoRemarks{ get; set; }
    @AuraEnabled
    public double marginTobeDeducted{ get; set; }
    @AuraEnabled
    public double totalAmountToBeByG{ get; set; }
    @AuraEnabled
    public double totalNonFundedInsC{ get; set; }
    @AuraEnabled
    public double totalOfAbovePayD{ get; set; }
    @AuraEnabled
    public String customerNeedToPay{ get; set; }
    @AuraEnabled
    public Double additionalIHMAmount{ get; set; }
    @AuraEnabled
    public string selectYesIfIHMdetailsAreCorrect{ get; set; }
    @AuraEnabled
    public double totalNonfundedInsurance{ get; set; }
    @AuraEnabled
    public string loanApplicationId{ get; set; }
    @AuraEnabled
    public string ihmId{ get; set; }
    @AuraEnabled
    public double valuationCharge{ get; set; }    
    @AuraEnabled
    public double toalAmountPaidToBank{ get; set; }
    @AuraEnabled
    public String vehicleType{ get; set; }   
    @AuraEnabled
    public double totalIHMpaidToDealer{ get; set; }
    @AuraEnabled
    public double ihmRecoveryValue{ get; set; }
    public IHMRecordWrapper(Opportunity oppRec){ //SFTRAC-1676 added parameter
        this.exshoroomPrice = 0;
        this.onRoadPrice = 0;
        this.totalOtherCharges = 0;
        this.invoicePrice = 0;
        this.isMotorInsuranceFunded = '';
        this.xstYearMotorInsurancePremium = 0;
        this.hasCustomerOptedForAdvanceEMI = '';
        this.eMIAmount = 0;
        this.loanAmtSanctionedFexclFundInsu = 0;
        this.remarks = '';
        this.cvoRemarks = '';
        this.marginTobeDeducted = 0;
        this.totalAmountToBeByG = 0;
        this.totalNonFundedInsC = 0;
        if(oppRec.Product_Type__c == 'Tractor'){this.selectYesIfIHMdetailsAreCorrect = 'Yes';}else{this.selectYesIfIHMdetailsAreCorrect = 'No';}//SFTRAC-1676
        //this.selectYesIfIHMdetailsAreCorrect = 'No'; //SFTRAC-1676 commented
        this.totalNonfundedInsurance = 0;
        this.loanApplicationId = null;
        this.ihmId = null;
        this.valuationCharge = 0;
        this.toalAmountPaidToBank = 0;
        this.vehicleType = '';
        this.totalIHMpaidToDealer = 0;
        this.ihmRecoveryValue = 0;
    }
}
/*
* @Method:      getDocumentFiles
* @Created by:  Gaurav Rawat 
* @Description: Method to get the document files
* @Param:       String - contentDocId, String loanApplicationId
* @Return:      String - ContentDocumentId
*/
@AuraEnabled
public static String getDocumentFiles(String contentDocId,String loanId){
    try {
        List<ContentDocumentLink> contentDocLinkList = new List<ContentDocumentLink>([Select ContentDocumentId From ContentDocumentLink Where LinkedEntityId =: contentDocId WITH SECURITY_ENFORCED LIMIT 100]);
        if(contentDocLinkList.size() > 0){
            return contentDocLinkList[0].ContentDocumentId;
        }
        return null;
    } catch (Exception e) {
        ErrorLoggerUtil.logErrorEvent('IHMPageController', 'getDocumentFiles', System.Label.Apex, e, loanId);
        throw new AuraHandledException(System.Label.ExceptionMessage);
    }
}

/*
* @Method:      getIHMDocumentsAmountSum
* @Created by:  Gaurav Rawat 
* @Description: Method to get the IHM documents and return the sum of IHM amount.
* @Param:       String loanApplicationId
* @Return:      Amount of IHM Receipt
*/
@AuraEnabled
public static Decimal getIHMDocumentsAmountSum(String loanId,String dealId){
    Decimal ihmAmount = 0;
    try {
        Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanId WITH SECURITY_ENFORCED];
        List<Documents__c> documentList = new List<Documents__c>();
        if(oppRec.Product_Type__c == System.Label.Tractor){
            List<Vehicle_Detail__c> VehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
            documentList = [SELECT Id, IHM_amount_as_per_receipt__c 
                                FROM Documents__c 
                                WHERE Opportunity_Relation__c =:loanId AND is_Active__c = true AND Document_Type__c = 'IHM Receipt' AND Vehicle_Detail__c =: VehicleLst[0].Id
                                WITH SECURITY_ENFORCED];
        }else{
            documentList = [SELECT Id, IHM_amount_as_per_receipt__c 
                                FROM Documents__c 
                                WHERE Opportunity_Relation__c =:loanId AND is_Active__c = true AND Document_Type__c = 'IHM Receipt'
                                WITH SECURITY_ENFORCED];
        }
        for(Documents__c doc : documentList){
            ihmAmount += doc.IHM_amount_as_per_receipt__c == null ? 0 : doc.IHM_amount_as_per_receipt__c;
        }
    } catch (Exception e) {
        ErrorLoggerUtil.logErrorEvent('IHMPageController', 'getIHMDocumentsAmountSum', System.Label.Apex, e, loanId);
    }
    return ihmAmount;
}
@AuraEnabled
public static Vehicle_Detail__c getVehicleDetailsForIHMPage(String loanAppId, String dealId){
    try {
        List<Vehicle_Detail__c> vehiObj = [SELECT ID, Deal_Number__c ,Loan_Application__c,RC_retention_applicable__c,RC_Hold_Amount__c from Vehicle_Detail__c where
        Deal_Number__c =: dealId and Loan_Application__c =: loanAppId LIMIT 1];
        if(vehiObj.size()>0){
            return vehiObj[0];
        }
        return null;

    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
}
}