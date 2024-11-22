/*------------------------------------------------------------
Author:        Bharath
Company:       Persistent
Description:   This class is  Offer screen controller
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
1-8-2022      Bharath Moka      Created
22/2/2022     Raj Gupta         Modified
------------------------------------------------------------*/

public without sharing class IND_OfferScreenController {
    
    // @Method:      fetchIloadOfferScreenDatansuranceDetailsRecords
    // @Created by:   Anji_Yeruva
    // @Description: 
    /*
1)  Create a LWC component getOfferScreenDetails which will be rendered for the Offer screen indicator screen for the Opportunity. 
2)  On load of this component, loadOfferScreenData method will be called which will return a wrapper response of preset fields.
*/
    // @Param:      String 
    // @Return:     String 
    @AuraEnabled //(Cacheable=true)
    public static String loadOfferScreenData(String loanApplicationId, String vehicleId){
        Opportunity opp=[select id,Total_Funded_Premium__c,On_Road_price__c,Ex_showroom_price__c,Vehicle_Type__c,Product_Type__c,Funding_on_ORP__c,Funding_on_Ex_Showroom__c from Opportunity where Id=: loanApplicationId WITH SECURITY_ENFORCED];// CISP-2522    
        Final_Term__c finaltemrsObj = new Final_Term__c();
        Vehicle_Detail__c vechDetailObj = new Vehicle_Detail__c();

        if(opp.Product_Type__c == System.Label.Tractor){
            finaltemrsObj = [SELECT id,CRM_IRR__c,Tenure__c,Loan_Amount__c,
            Loan_Application__c,Required_CRM_IRR__c,ChangeVariantOfferCalled__c,
            OfferengineMaxLoanAmount__c,
            OfferengineMinLoanAmount__c,
            OfferengineMaxTenure__c,
            OfferengineMinTenure__c,
            PricingEngine_thresholdNetrr__c,
            Offerengine_StopJourney_Flag__c,
            Advance_EMI__c,
            Holiday_period__c,
            First_EMI_Date__c,
            EMI_Amount__c,
            Loan_Deal_Date__c,
            Gross_IRR__c,
            Vehicle_Detail__r.Total_Funded_Amount__c, //SFTRAC-898 -- Total_Funded_Amount__c
            Net_IRR__c,Schemes__c,Installment_type__c,Installment_Frequency__c,
            IsOfferEngineApiFailed__c,Approving_Authority_Loan_Amount__c,Second_EMI_Date__c,Structured_L1_Call__c,No_of_Installment__c,Offer_Agreement_Amount__c,L1_L2_Final_Terms_Changed__c,
            L1_Offer_Engine_Completed__c,L1_Structured_Records_Submitted__c,L2_Offer_Engine_Completed__c,L2_Structured_Records_Submitted__c //SFTRAC-570
            FROM Final_Term__c 
            WHERE Loan_Application__c=:loanApplicationId AND Vehicle_Detail__c =:vehicleId
            WITH SECURITY_ENFORCED LIMIT 1];
            
        vechDetailObj=[SELECT Vehicle_Category__c,id,Loan_Application__c,Base_Prices__c
         FROM Vehicle_Detail__c 
         WHERE Loan_Application__c=:loanApplicationId AND Id=:vehicleId
         WITH SECURITY_ENFORCED];  
        }
        else{
            finaltemrsObj = [SELECT id,CRM_IRR__c,Tenure__c,Loan_Amount__c,
                                       Loan_Application__c,Required_CRM_IRR__c,
                                       OfferengineMaxLoanAmount__c,
                                       OfferengineMinLoanAmount__c,
                                       OfferengineMaxTenure__c,
                                       OfferengineMinTenure__c,
                                       PricingEngine_thresholdNetrr__c,
                                       Offerengine_StopJourney_Flag__c,
                                       Advance_EMI__c,
                                       Holiday_period__c,
                                       EMI_Amount__c,
                                       Gross_IRR__c,
                                       Net_IRR__c,Schemes__c,
                                       IsOfferEngineApiFailed__c,Approving_Authority_Loan_Amount__c
                                       FROM Final_Term__c 
                                       WHERE Loan_Application__c=:loanApplicationId 
                                       WITH SECURITY_ENFORCED LIMIT 1];
          vechDetailObj=[SELECT Vehicle_Category__c,id,Loan_Application__c,Base_Prices__c
                                    FROM Vehicle_Detail__c 
                                    WHERE Loan_Application__c=:loanApplicationId 
                                    WITH SECURITY_ENFORCED LIMIT 1];   // CISP-2522 
        }
       
        LoadOfferScreenDataWrapper ldscDataWrpObj = new LoadOfferScreenDataWrapper();
        if(opp.On_Road_price__c != 0 && opp.On_Road_price__c != null)
        {
            ldscDataWrpObj.orp = opp.On_Road_price__c;
        }
        ldscDataWrpObj.totalFundedPremium = opp.Total_Funded_Premium__c;
        ldscDataWrpObj.crmIRR =finaltemrsObj.CRM_IRR__c;
        ldscDataWrpObj.requriedCRMIRR =finaltemrsObj.Required_CRM_IRR__c;
        ldscDataWrpObj.loanAmount= finaltemrsObj.Loan_Amount__c;
        ldscDataWrpObj.tenure =finaltemrsObj.Tenure__c;
        ldscDataWrpObj.emi = finaltemrsObj.EMI_Amount__c;
        ldscDataWrpObj.getrecordId = finaltemrsObj.Id;
        ldscDataWrpObj.stopJourneyFlag = finaltemrsObj.Offerengine_StopJourney_Flag__c;
        ldscDataWrpObj.minTenureSlider = finaltemrsObj.OfferengineMinTenure__c;
        ldscDataWrpObj.maxTenureSlider = finaltemrsObj.OfferengineMaxTenure__c;
        ldscDataWrpObj.maxLoanAmtSlider = finaltemrsObj.OfferengineMaxLoanAmount__c;
        ldscDataWrpObj.minLoanAmtSlider = finaltemrsObj.OfferengineMinLoanAmount__c;
        ldscDataWrpObj.advanceEmi = finaltemrsObj.Advance_EMI__c;
        ldscDataWrpObj.monitoriumDays = finaltemrsObj.Holiday_period__c;
        ldscDataWrpObj.priceingEngineNetIrr = finaltemrsObj.PricingEngine_thresholdNetrr__c;
        ldscDataWrpObj.netIRR = String.valueof(finaltemrsObj.Net_IRR__c);
        ldscDataWrpObj.grossIRR = String.valueof(finaltemrsObj.Gross_IRR__c);
        ldscDataWrpObj.schemeId = finaltemrsObj.Schemes__c;
        ldscDataWrpObj.oppRecord = opp;//CISP-2522
        ldscDataWrpObj.vehRecord = vechDetailObj;//CISP-2522
        ldscDataWrpObj.IsOfferEngineApiFailed = finaltemrsObj.IsOfferEngineApiFailed__c;
        ldscDataWrpObj.approvingAuthorityLoanAmount = finaltemrsObj.Approving_Authority_Loan_Amount__c;
        if(opp.Product_Type__c == System.Label.Tractor){
            ldscDataWrpObj.isChangeVariantOfferCalled =finaltemrsObj.ChangeVariantOfferCalled__c; //SFTRAC-1526
            ldscDataWrpObj.firstEMI = finaltemrsObj.First_EMI_Date__c;
            ldscDataWrpObj.secondEMI = finaltemrsObj.Second_EMI_Date__c;
            ldscDataWrpObj.dealDate = finaltemrsObj.Loan_Deal_Date__c;
            ldscDataWrpObj.installmentType = finaltemrsObj.Installment_type__c; //SFTRAC-570
            ldscDataWrpObj.installmentFrequency = finaltemrsObj.Installment_Frequency__c; //SFTRAC-570
            ldscDataWrpObj.structuredL1Call = finaltemrsObj.Structured_L1_Call__c;
            ldscDataWrpObj.totalInstallment = finaltemrsObj.No_of_Installment__c;
            ldscDataWrpObj.totalFundedPremium = Integer.valueOf(finaltemrsObj.Vehicle_Detail__r.Total_Funded_Amount__c != null ? finaltemrsObj.Vehicle_Detail__r.Total_Funded_Amount__c : 0);
            ldscDataWrpObj.loanAgreementAmount = finaltemrsObj.Offer_Agreement_Amount__c;
            ldscDataWrpObj.isFinalTermChanged = finaltemrsObj.L1_L2_Final_Terms_Changed__c;
            ldscDataWrpObj.isL1OfferEngineCompleted = finaltemrsObj.L1_Offer_Engine_Completed__c;
            ldscDataWrpObj.isL1StructuredRecordsCreated = finaltemrsObj.L1_Structured_Records_Submitted__c;
            ldscDataWrpObj.isL2OfferEngineCompleted = finaltemrsObj.L2_Offer_Engine_Completed__c;
            ldscDataWrpObj.isL2StructuredRecordsCreated = finaltemrsObj.L2_Structured_Records_Submitted__c;
        }
       /*  if(roimaster.size()>0){
            ldscDataWrpObj.mincrm=roimaster[0].Min_Value__c;
            ldscDataWrpObj.maxcrm=roimaster[0].Max_Value__c;
        } */
        return JSON.serialize(ldscDataWrpObj);
    }  
    // @Method:      checkEligibleLoanAmt
    // @Created by:  Anji
    // @Description: 
    // @Param:       
    // @Return:      Boolean
    @AuraEnabled
    public static Vehicle_Detail__c getVechicleDetails(String loanApplicationId, String vehicleId){
        Vehicle_Detail__c vechDetail; 
        for(Vehicle_Detail__c vechDetailObj:[SELECT Id,Eligible_Tenure__c,Manufacturer_Year_Month__c,Product_Segment__c, 
                                             Loan_Application__r.Vehicle_Sub_Category__c,
                                             Loan_Application__r.Vehicle_Type__c, Loan_Application__r.LeadSource, //D2C Swapnil Added LeadSource 
                                             Loan_Application__r.LastStageName__c,
                                             Loan_Application__r.StageName,
                                             Loan_Application__r.Product_Type__c,Eligible_Loan_Amount__c,
                                             Loan_Application__r.Total_Exposures_Amount__c, 
                                             Loan_Application__r.Total_Funded_Premium__c, Deal_Number__c,Variant__c,
                                              Loan_Application__r.Existing_Borrowers_Exposure_Amt__c , 
                                             Loan_Application__r.Existing_Co_Borrowers_Exposure_Amt__c, 
                                             Loan_Application__r.Existing_Others_Exposure_Amt__c,
                                             Loan_Application__r.Total_Bank_Exposure__c
                                             FROM Vehicle_Detail__c 
                                             WHERE Loan_Application__c=:loanApplicationId 
                                             WITH SECURITY_ENFORCED])/* //Ola Integration changes */
        {
            if(vechDetailObj.Loan_Application__r.Product_Type__c == System.Label.Tractor && vechDetailObj.Id ==vehicleId){
                vechDetail = vechDetailObj;
                break;
            }
            else{
                vechDetail = vechDetailObj;
            }
        }
        return vechDetail;
    }
    
    // @Method:      getPurchaseprice //SFTRAC-901
    // @Created by:  Aakash J
    // @Description: return getPurchaseprice of Vehicle
    // @Param:       Loan Application Id and Vehicle ID
    // @Return:      Boolean
    @AuraEnabled
    public static Integer getPurchaseprice(String loanApplicationId , String vehicleId){
        Integer orpValue;
        Opportunity loanAppRec = [Select Id, Name, Lead_number__c, StageName, Sub_Stage__c, Product_Type__c, Vehicle_Type__c, Requested_loan_amount__c, 
                                    Customer_Type__c From Opportunity Where Id =: loanApplicationId Limit 1];
        
        
        List<Documents__c> docLst = [SELECT Id,Proof_of_Identity_POI__c, Proof_of_Address_POA__c, KYC_DOB__c, PAN_No__c, Applicant__c ,KYC_City__c,KYC_Pin_Code__c,KYC_State__c,Addresss_Type__c,Document_Type__c,
                                                KYC_Address_Line_1__c, KYC_Address_Line_2__c, KYC_District__c FROM Documents__c 
                                                WHERE Applicant__c IN (SELECT Id FROM Applicant__c WHERE Opportunity__c =:loanApplicationId AND Applicant_Type__c = 'Borrower') AND Proof_of_Address_POA__c = true];
        String cfdStateCode = Utilities.getCFDStateCode([SELECT Id,Agent_BL_code__c FROM Opportunity WHERE Id =: loanApplicationId LIMIT 1].Agent_BL_code__c, 'T');

        List<TBM_Product_Variant_dt__c> dlpMasterList = [SELECT Id, State_Code__c, Product_Variant_Code__c,Dealer_Landed_Price__c, Segment_Grade__c,Unique_State_Code__c FROM TBM_Product_Variant_dt__c Where State_Code__c =: cfdStateCode];
		Map<String,Decimal> dlpMasterMAP = new Map<String,Decimal>();
        
        for(TBM_Product_Variant_dt__c dlpMasterRec: dlpMasterList){
            if(!dlpMasterMAP.containsKey(dlpMasterRec.Product_Variant_Code__c)){
                dlpMasterMAP.put(dlpMasterRec.Product_Variant_Code__c,dlpMasterRec.Dealer_Landed_Price__c);
            }
        }
        
        List<Vehicle_Detail__c> vehicleDetailList = [SELECT Id, Variant_Code__c, Valuation_price__c,Insurance_declared_value__c, Grid_value__c, Vehicle_type__c, Total_Funded_Amount__c, Deal_Number__c, Invoice_Price__c, Loan_tenure__c, Loan_Amount__c, What_is_thePrice_of_TractorHarvester__c, Required_CRM_IRR__c From Vehicle_Detail__c where Id =: vehicleId LIMIT 1];
        
        if(loanAppRec.Vehicle_Type__c == 'New'){
           Integer orpValueInvoice = vehicleDetailList[0].Invoice_Price__c != null ? Integer.valueOf(vehicleDetailList[0].Invoice_Price__c) : 0;
           Integer orpValueDLP = (dlpMasterMAP != null && vehicleDetailList[0].Variant_Code__c != null && dlpMasterMAP.containsKey(vehicleDetailList[0].Variant_Code__c)) ? Integer.valueOf(dlpMasterMAP.get(vehicleDetailList[0].Variant_Code__c)) : 0;
           System.debug('++++++orpValueInvoice ' + orpValueInvoice + ' orpValueDLP ' + orpValueDLP);
           
            Integer minOrpValue = 999999999; // Set initial max to the maximum possible integer value
            if (orpValueInvoice > 0) minOrpValue = Math.min(minOrpValue, orpValueInvoice);
            if (orpValueDLP > 0) minOrpValue = Math.min(minOrpValue, orpValueDLP);        
            
            orpValue = minOrpValue;
            System.debug('++++++orpValue ' + orpValue);
        }else{
            Decimal valuationPriceDecimal = vehicleDetailList[0].Valuation_price__c != null ? (vehicleDetailList[0].Valuation_price__c).setScale(0) : 0.0;
            Decimal insuranceDeclaredDecimal = vehicleDetailList[0].Insurance_declared_value__c != null ? (vehicleDetailList[0].Insurance_declared_value__c).setScale(0) : 0.0;
            Decimal gridValueDecimal = vehicleDetailList[0].Grid_value__c != null ? (vehicleDetailList[0].Grid_value__c).setScale(0): 0.0;
            system.debug('+++++DECIMAL valuationPriceDecimal '+valuationPriceDecimal+' insuranceDeclaredDecimal '+insuranceDeclaredDecimal+' gridValueDecimal '+gridValueDecimal);
            Decimal minOrpValueUR = 999999999;
            //Decimal minOrpValueUR = Decimal.valueOf('99999999999999999'); // Set initial max to the maximum possible decimal value
            if (valuationPriceDecimal > 0) minOrpValueUR = Math.min(minOrpValueUR, valuationPriceDecimal);
            if (insuranceDeclaredDecimal > 0) minOrpValueUR = Math.min(minOrpValueUR, insuranceDeclaredDecimal);
            if (gridValueDecimal > 0) minOrpValueUR = Math.min(minOrpValueUR, gridValueDecimal);
            
            System.debug('+++++maxDecimal ' + minOrpValueUR);
            orpValue = minOrpValueUR.intValue();
            System.debug('+++++orpValue ' + orpValue);
         }
        return orpValue;
    }

    @AuraEnabled //(Cacheable=true)
    public static String roiMaster(String loanApplicationId,String productType, Integer tenure, String vehicleCategory){
        try{
        String product;
        String vehicle;
        String cusType;//CISP-18765
        if(vehicleCategory == 'New'){
            vehicle = 'N';
        }
        if(vehicleCategory == 'Used'){
            vehicle = 'U';
        }
        if(vehicleCategory == 'Refinance'){
            vehicle = 'R';
        }
        /*CISP-18765 start*/
        List<CIBIL_Details__c> cibliList = [Select Id,Score__c from CIBIL_Details__c where Applicant__r.Opportunity__c =: loanApplicationId AND Applicant__r.Applicant_Type__c = 'Borrower' LIMIT 1];

        if(cibliList.size() > 0){
            if(cibliList[0]?.Score__c == '-1' || cibliList[0]?.Score__c == '0')
                cusType = 'NTB';
            else
                cusType = 'ETB';
        }else{
            cusType = 'NTB'; //CISP-19214 when cibil is failure
        } 
        //CISP-18765 end

        LoadOfferScreenDataWrapper ldscDataWrpObj = new LoadOfferScreenDataWrapper();
        List<ROI_Master__c> roimaster = new List<ROI_Master__c>();//Start CISP-2702
        if(productType == 'Passenger Vehicles')
        {
            product = 'C';
            roimaster=[Select id, Max_Value__c,Min_Value__c,Product__r.Name,Product_Segment__c,Tenure_Max__c,Tenure_Min__c,Vehicle_Category__c,Description__c from ROI_Master__c
                           where Description__c ='CRM_IRR' AND Tenure_Max__c >=: tenure AND Tenure_Min__c<=: tenure AND Product__r.ProductCode =: product AND Vehicle_Category__c =: vehicle AND Application_Type__c = '10' AND Customer_Type__c =:cusType WITH SECURITY_ENFORCED limit 1];
        }
        if(productType == 'Two Wheeler')
        {
            product = 'H';
            roimaster=[Select id, Max_Value__c,Min_Value__c,Product__r.Name,Product_Segment__c,Tenure_Max__c,Tenure_Min__c,Vehicle_Category__c,Description__c from ROI_Master__c
                           where Description__c ='CRM_IRR' AND Tenure_Max__c >=: tenure AND Tenure_Min__c<=: tenure AND Product__r.ProductCode =: product AND Vehicle_Category__c =: vehicle AND Product_Segment__c = 'TWO_WHEELER' WITH SECURITY_ENFORCED limit 1];
        }//End CISP-2702
        if(roimaster.size()>0){
            ldscDataWrpObj.mincrm=roimaster[0].Min_Value__c;
            ldscDataWrpObj.maxcrm=roimaster[0].Max_Value__c;
        }
        return JSON.serialize(ldscDataWrpObj);
    }
    catch (Exception e) {
        ErrorLoggerUtil.logErrorEvent('IND_OfferScreenController', 'roiMaster', System.Label.Apex, e,loanApplicationId);
        throw new AuraHandledException(System.Label.ExceptionMessage);
        
    }
    }

    //CISP-5977
    @AuraEnabled //(Cacheable=true)
    public static String roiMasterForImputedIRR(String loanApplicationId,String productType, Integer tenure, String vehicleCategory){
        try{
        String product;
        String vehicle;
        String cusType;
        if(vehicleCategory == 'New'){
            vehicle = 'N';
        }
        if(vehicleCategory == 'Used'){
            vehicle = 'U';
        }
        if(vehicleCategory == 'Refinance'){
            vehicle = 'R';
        }
        /*CISP-18765 start*/
         List<CIBIL_Details__c> cibliList = [Select Id,Score__c from CIBIL_Details__c where Applicant__r.Opportunity__c =: loanApplicationId AND Applicant__r.Applicant_Type__c = 'Borrower' LIMIT 1];

        if(cibliList.size() > 0){
            if(cibliList[0]?.Score__c == '-1' || cibliList[0]?.Score__c == '0')
                cusType = 'NTB';
            else
                cusType = 'ETB';
        }else{
            cusType = 'NTB'; //CISP-19214 when cibil is failure
        }  //CISP-18765 end

        LoadOfferScreenDataWrapper ldscDataWrpObj = new LoadOfferScreenDataWrapper();
        List<ROI_Master__c> roimaster = new List<ROI_Master__c>();//Start CISP-2702
        List<AggregateResult> mclrMaster = new List<AggregateResult>();
        if(productType == 'Passenger Vehicles')
        {
            product = 'C';
            if(tenure >=1 && tenure <=36){
                mclrMaster = [SELECT min(Period__c) minValue ,Flag__c,Nature__c,Rate_Type__c from MCLR_Master__c where Nature__c = 'FXD' and Flag__c = 'L' and Rate_Type__c = 'MCLR' and Period__c >=: tenure and Eff_from_date__c <= TODAY  group by Flag__c ,Nature__c ,Rate_Type__c];
                roimaster=[Select id, Max_Value__c,Min_Value__c,Product__r.Name,Product_Segment__c,Tenure_Max__c,Tenure_Min__c,Vehicle_Category__c,Description__c from ROI_Master__c
                where Description__c ='NET_IRR' AND Tenure_Max__c >=: tenure AND Tenure_Min__c<=: tenure AND Product__r.ProductCode =: product AND Vehicle_Category__c =: vehicle AND Application_Type__c = '10' AND Customer_Type__c =:cusType WITH SECURITY_ENFORCED limit 1];
                if(roimaster.size()>0){
                    ldscDataWrpObj.maxcrm=roimaster[0].Max_Value__c;
                }
                if(mclrMaster.size()>0){
                    Decimal minValue =Decimal.valueOf(String.valueOf(mclrMaster[0].get('minValue')));
                    List<MCLR_Master__c> mclrList = [Select MCLR__c,Nature__c ,Period__c,Rate_Type__c ,Eff_from_date__c   From MCLR_Master__c  Where Period__c =:minValue and Nature__c = 'FXD' and Flag__c = 'L' and Rate_Type__c = 'MCLR'  and Eff_from_date__c <= TODAY limit 1];
                    if(mclrList.size()>0){
                        if(roimaster.size()>0){
                            Decimal maxvalue = Math.max(mclrList[0].MCLR__c ,roimaster[0].Min_Value__c);
                            ldscDataWrpObj.mincrm = maxvalue;
                        }else{
                                ldscDataWrpObj.mincrm = mclrList[0].MCLR__c;
                        } 
                    } 
                }
            }else{
                roimaster=[Select id, Max_Value__c,Min_Value__c,Product__r.Name,Product_Segment__c,Tenure_Max__c,Tenure_Min__c,Vehicle_Category__c,Description__c from ROI_Master__c
                where Description__c ='NET_IRR' AND Tenure_Max__c >=: tenure AND Tenure_Min__c<=: tenure AND Product__r.ProductCode =: product AND Vehicle_Category__c =: vehicle AND Application_Type__c = '10' AND Customer_Type__c =:cusType WITH SECURITY_ENFORCED limit 1];
                if(roimaster.size()>0){
                    ldscDataWrpObj.mincrm=roimaster[0].Min_Value__c;
                    ldscDataWrpObj.maxcrm=roimaster[0].Max_Value__c;
                }
            }
            
        }
        if(productType == 'Two Wheeler')
        {
            product = 'H';
            roimaster=[Select id, Max_Value__c,Min_Value__c,Product__r.Name,Product_Segment__c,Tenure_Max__c,Tenure_Min__c,Vehicle_Category__c,Description__c from ROI_Master__c
                           where Description__c ='IMPUTED_IRR' AND Tenure_Max__c >=: tenure AND Tenure_Min__c<=: tenure AND Product__r.ProductCode =: product AND Vehicle_Category__c =: vehicle AND Product_Segment__c = 'TWO_WHEELER' WITH SECURITY_ENFORCED limit 1];
            if(roimaster.size()>0){
            ldscDataWrpObj.mincrm=roimaster[0].Min_Value__c;
            ldscDataWrpObj.maxcrm=roimaster[0].Max_Value__c;
            }
        }//End CISP-2702
        
        return JSON.serialize(ldscDataWrpObj);
    }
    catch (Exception e) {
        ErrorLoggerUtil.logErrorEvent('IND_OfferScreenController', 'roiMasterForImputedIRR', System.Label.Apex, e,loanApplicationId);
        throw new AuraHandledException(System.Label.ExceptionMessage);
        
    }
    }
    @AuraEnabled //(Cacheable=true)
    public static String roiMasterForImputedIRR(String loanApplicationId,String productType, Integer tenure, String vehicleCategory,String queryBased){
        try{
        String product;
        String vehicle;
        String cusType;
        if(vehicleCategory == 'New'){
            vehicle = 'N';
        }
        if(vehicleCategory == 'Used'){
            vehicle = 'U';
        }
        if(vehicleCategory == 'Refinance'){
            vehicle = 'R';
        }
         /*CISP-18765 start*/
         List<CIBIL_Details__c> cibliList = [Select Id,Score__c from CIBIL_Details__c where Applicant__r.Opportunity__c =: loanApplicationId AND Applicant__r.Applicant_Type__c = 'Borrower' LIMIT 1];

        if(cibliList.size() > 0){
            if(cibliList[0]?.Score__c == '-1' || cibliList[0]?.Score__c == '0')
                cusType = 'NTB';
            else
                cusType = 'ETB';
        } else{
            cusType = 'NTB'; //CISP-19214 when cibil is failure
        } //CISP-18765 end

        LoadOfferScreenDataWrapper ldscDataWrpObj = new LoadOfferScreenDataWrapper();
        List<ROI_Master__c> roimaster = new List<ROI_Master__c>();//Start CISP-2702
        List<AggregateResult> mclrMaster = new List<AggregateResult>();
        if(productType == 'Passenger Vehicles')
        {
            product = 'C';
            if(tenure >=1 && tenure <=36){
                mclrMaster = [SELECT min(Period__c) minValue ,Flag__c,Nature__c,Rate_Type__c from MCLR_Master__c where Nature__c = 'FXD' and Flag__c = 'L' and Rate_Type__c = 'MCLR' and Period__c >=: tenure and Eff_from_date__c <= TODAY  group by Flag__c ,Nature__c ,Rate_Type__c];
                roimaster=[Select id, Max_Value__c,Min_Value__c,Product__r.Name,Product_Segment__c,Tenure_Max__c,Tenure_Min__c,Vehicle_Category__c,Description__c from ROI_Master__c
                where Description__c =:queryBased AND Tenure_Max__c >=: tenure AND Tenure_Min__c<=: tenure AND Product__r.ProductCode =: product AND Vehicle_Category__c =: vehicle AND Application_Type__c = '10' AND Customer_Type__c =:cusType WITH SECURITY_ENFORCED limit 1];
                if(roimaster.size()>0){
                    ldscDataWrpObj.maxcrm=roimaster[0].Max_Value__c;
                }
                if(mclrMaster.size()>0){
                    Decimal minValue =Decimal.valueOf(String.valueOf(mclrMaster[0].get('minValue')));
                    List<MCLR_Master__c> mclrList = [Select MCLR__c,Nature__c ,Period__c,Rate_Type__c ,Eff_from_date__c   From MCLR_Master__c  Where Period__c =:minValue and Nature__c = 'FXD' and Flag__c = 'L' and Rate_Type__c = 'MCLR'  and Eff_from_date__c <= TODAY limit 1];
                    if(mclrList.size()>0){
                        if(roimaster.size()>0){
                        Decimal maxvalue = Math.max(mclrList[0].MCLR__c ,roimaster[0].Min_Value__c);
                        ldscDataWrpObj.mincrm = maxvalue;
                        }else{
                            ldscDataWrpObj.mincrm = mclrList[0].MCLR__c;
                        }      
                    }
                }
            }else{
                roimaster=[Select id, Max_Value__c,Min_Value__c,Product__r.Name,Product_Segment__c,Tenure_Max__c,Tenure_Min__c,Vehicle_Category__c,Description__c from ROI_Master__c
                where Description__c =:queryBased AND Tenure_Max__c >=: tenure AND Tenure_Min__c<=: tenure AND Product__r.ProductCode =: product AND Vehicle_Category__c =: vehicle AND Application_Type__c = '10' AND Customer_Type__c =:cusType WITH SECURITY_ENFORCED limit 1];
                if(roimaster.size()>0){
                    ldscDataWrpObj.mincrm=roimaster[0].Min_Value__c;
                    ldscDataWrpObj.maxcrm=roimaster[0].Max_Value__c;
                }
            }
            
        }
        if(productType == 'Two Wheeler')
        {
            product = 'H';
            roimaster=[Select id, Max_Value__c,Min_Value__c,Product__r.Name,Product_Segment__c,Tenure_Max__c,Tenure_Min__c,Vehicle_Category__c,Description__c from ROI_Master__c
                           where Description__c ='IMPUTED_IRR' AND Tenure_Max__c >=: tenure AND Tenure_Min__c<=: tenure AND Product__r.ProductCode =: product AND Vehicle_Category__c =: vehicle AND Product_Segment__c = 'TWO_WHEELER' WITH SECURITY_ENFORCED limit 1];
            if(roimaster.size()>0){
            ldscDataWrpObj.mincrm=roimaster[0].Min_Value__c;
            ldscDataWrpObj.maxcrm=roimaster[0].Max_Value__c;
            }
        }//End CISP-2702
        
        return JSON.serialize(ldscDataWrpObj);
    }
    catch (Exception e) {
        ErrorLoggerUtil.logErrorEvent('IND_OfferScreenController', 'roiMasterForImputedIRR', System.Label.Apex, e,loanApplicationId);
        throw new AuraHandledException(System.Label.ExceptionMessage);
        
    }
    }

    @AuraEnabled //(Cacheable=true) CISP-20504
    public static String roiMasterForGrossIRR(String loanApplicationId,String productType,String productSegment,String vehicleCategory){
        try{
        String product;
        String vehicle;
        if(vehicleCategory == 'New'){
            vehicle = 'N';
        }
        if(vehicleCategory == 'Used'){
            vehicle = 'U';
        }
        if(vehicleCategory == 'Refinance'){
            vehicle = 'R';
        }
        LoadOfferScreenDataWrapper ldscDataWrpObj = new LoadOfferScreenDataWrapper();
        List<ROI_Master__c> roimaster = new List<ROI_Master__c>();
        if(productType == 'Two Wheeler')
        {
            product = 'H';
        if(productSegment == 'ESCOOTER'){
            roimaster=[Select id, Max_Value__c,Min_Value__c,Product__r.Name,Product_Segment__c,Vehicle_Category__c,Description__c from ROI_Master__c
                           where Description__c ='GROSS_IRR' AND Product__r.ProductCode =: product AND Vehicle_Category__c =: vehicle AND Product_Segment__c = 'ESCOOTER' WITH SECURITY_ENFORCED limit 1];
            
        }
            roimaster=[Select id, Max_Value__c,Min_Value__c,Product__r.Name,Product_Segment__c,Vehicle_Category__c,Description__c from ROI_Master__c
            where Description__c ='GROSS_IRR' AND Product__r.ProductCode =: product AND Vehicle_Category__c =: vehicle AND Product_Segment__c = 'TWO_WHEELER' WITH SECURITY_ENFORCED limit 1];
        }
        if(roimaster.size()>0){
            ldscDataWrpObj.mingross=roimaster[0].Min_Value__c;
            ldscDataWrpObj.maxgross=roimaster[0].Max_Value__c;
        }
        return JSON.serialize(ldscDataWrpObj);
    }
    catch (Exception e) {
        ErrorLoggerUtil.logErrorEvent('IND_OfferScreenController', 'roiMasterForGrossIRR', System.Label.Apex, e,loanApplicationId);
        throw new AuraHandledException(System.Label.ExceptionMessage);
        
    }
    }//CISP-20504
    
    public class LoadOfferScreenDataWrapper{
        @AuraEnabled public String getrecordId; 
        @AuraEnabled public Decimal crmIRR;
        @AuraEnabled public Decimal orp;
        @AuraEnabled public Decimal totalFundedPremium = 0;
        @AuraEnabled public Decimal mincrm;
        @AuraEnabled public Decimal maxcrm;
        @AuraEnabled public Decimal mingross;//CISP-20504
        @AuraEnabled public Decimal maxgross;//CISP-20504
        @AuraEnabled public String requriedCRMIRR;
        @AuraEnabled public String netPayIns;
        @AuraEnabled public String netPayOut;
        @AuraEnabled public String grossIRROffered;
        @AuraEnabled public String netIRROffered;
        @AuraEnabled public Boolean stopJourneyFlag;
        @AuraEnabled public string loanAmount;
        @AuraEnabled public String tenure;
        @AuraEnabled public Decimal emi;
        @AuraEnabled public Decimal maxTenureSlider;
        @AuraEnabled public Decimal minTenureSlider;
        @AuraEnabled public Decimal minLoanAmtSlider;
        @AuraEnabled public Decimal maxLoanAmtSlider;
        @AuraEnabled public Boolean advanceEmi;
        @AuraEnabled public String monitoriumDays;
        @AuraEnabled public Decimal priceingEngineNetIrr;
        @AuraEnabled public String netIRR;
        @AuraEnabled public String grossIRR;
        @AuraEnabled public String schemeId;
        @AuraEnabled public Opportunity oppRecord;//CISP-2522
        @AuraEnabled public Vehicle_Detail__c vehRecord;//CISP-2522
        @AuraEnabled public Boolean IsOfferEngineApiFailed;
        @AuraEnabled public String approvingAuthorityLoanAmount;
        @AuraEnabled public String installmentType;
        @AuraEnabled public String installmentFrequency;
        @AuraEnabled public Boolean structuredL1Call;    
        @AuraEnabled public Date firstEMI;
        @AuraEnabled public Date secondEMI;
        @AuraEnabled public Date dealDate;         
        @AuraEnabled public Decimal totalInstallment;       
        @AuraEnabled public Decimal loanAgreementAmount; 
        @AuraEnabled public Boolean isFinalTermChanged;
        @AuraEnabled public Boolean isL1OfferEngineCompleted;
        @AuraEnabled public Boolean isL1StructuredRecordsCreated;
        @AuraEnabled public Boolean isL2OfferEngineCompleted;
        @AuraEnabled public Boolean isL2StructuredRecordsCreated;
        @AuraEnabled public Boolean isChangeVariantOfferCalled; //SFTRAC-1526
    }
    
    
    /*
* @Method:      getOfferScreenData
* @Created by:  Raj Gupta
* @Description: This method fetch data from previous modules.
* @Param:       String - loan Applicantion ID
* @Return:      data
*/
    @AuraEnabled
    public static String getOfferScreenData(String loanApplicationId) {
        try
        {
            //Null Check 
            if(loanApplicationId != null){
                ResponseWrapper responseJSON = new ResponseWrapper();
                Opportunity opp=[select id,Required_Loan_amount__c,Required_Tenure__c,Required_ROI__c from Opportunity where Id=: loanApplicationId WITH SECURITY_ENFORCED];
                responseJSON.tenure = opp.Required_Tenure__c;
                responseJSON.loanAmount = opp.Required_Loan_amount__c;
                responseJSON.roi = opp.Required_ROI__c;
                String serializedResonponse = JSON.serialize(responseJSON);
                return serializedResonponse;   
            }
            return null;
        }
        catch (Exception e) {
        ErrorLoggerUtil.logErrorEvent('IND_OfferScreenController', 'getOfferScreenData', System.Label.Apex, e,loanApplicationId);
        throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
      /*
    * @Method:      updateTransactionRecord
    * @Created by:  Santhosh Guhan 
    * @Description: This method is used to update loan application transaction history record for post sanction module.
    * @Param:       String - Loan Application ID.  
    * @Return:      void
    */
    @AuraEnabled
    public static void updateTransactionRecord(String loanApplicationId, String dealId){
        try{
            List<Loan_Application_Transaction_History__c> lATList=[Select id,Name,Submitted_Flag__c from Loan_Application_Transaction_History__c where Loan_Application_ID__c=:loanApplicationId  and Name='Structured EMI' And Module__c = 'Post Sanction Checks and Documentation' And Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
            if(!lATList.isEmpty()){
                lATList[0].Submitted_Flag__c = true;
                update lATList;
            }
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_OfferScreenController', 'updateTransactionRecord', System.Label.Apex, ex,loanApplicationId);
            throw new IND_Exception(ex.getMessage());   
        }
    }  

    /*
    * @Method:      getTransactionRecord
    * @Created by:  Santhosh Guhan 
    * @Description: This method is used to get submitted flag loan application transaction history record for post sanction module.
    * @Param:       String - Loan Application ID.  
    * @Return:      void
    */
    @AuraEnabled
    public static Boolean getTransactionRecord(String loanApplicationId, String dealId){
        try{
            List<Loan_Application_Transaction_History__c> lATList=[Select id,Name,Submitted_Flag__c from Loan_Application_Transaction_History__c where Loan_Application_ID__c=:loanApplicationId  and Name='Structured EMI' And Module__c = 'Post Sanction Checks and Documentation' And Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
            if(!lATList.isEmpty()){
                return lATList[0].Submitted_Flag__c;
            }
            return null;
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_OfferScreenController', 'updateTransactionRecord', System.Label.Apex, ex,loanApplicationId);
            throw new IND_Exception(ex.getMessage());   
        }
    } 
    //Wrapper Class 
    public class ResponseWrapper {
        decimal tenure {get;set;} 
        Decimal loanAmount {get;set;}
        Decimal roi {get;set;}
        //constructor
        responseWrapper() {            
            this.tenure = 0;
            this.loanAmount = 0;
            this.roi = 0;
        }
    }
    
       /*
* @Method:      updateRetryCount
* @Created by:  Raj Gupta
* @Description: This method will Update Retry count when change pay in pay out click
* @Param:       String - current Applicantion ID
* @Return:      Na
*/
    @AuraEnabled
    public static string updateRetryCount(String loanApplicationId){
        try{
            if(loanApplicationId != null){
                List<Retry_Count__c> retryCounts = [select id,Count__c from Retry_Count__c where Loan_Application_Id__c =: loanApplicationId and Service_Name__c = 'FinalTermApi' WITH SECURITY_ENFORCED Order by createddate DESC LIMIT 1];
                if(retryCounts.size() > 0){
                    retryCounts[0].Count__c = 0;
                }
            if (Schema.sObjectType.Retry_Count__c.isUpdateable() && retryCounts.size() > 0){
                update retryCounts;
            } 
            }
            return null;
        }
        //Catch block 
         catch (Exception e) {
        ErrorLoggerUtil.logErrorEvent('IND_OfferScreenController', 'updateRetryCount', System.Label.Apex, e,loanApplicationId);
        throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    /*
* @Method:      checkRetryExhausted
* @Created by:  Raj Gupta
* @Description: This method will check retry attemps
* @Param:       String - current Applicantion ID
* @Return:      json -check the retry attemps
*/
    
    @AuraEnabled
    public static String checkRetryExhausted(String loanApplicationId){
        try{
            FinalTermApiWrapper responseJSON = new FinalTermApiWrapper();
            //Null Check 
            if(loanApplicationId != null){
                Retry_Count__c retryCount = new Retry_Count__c();
                List<Retry_Count__c> retryCountList = new List<Retry_Count__c>();
                retryCountList = [select Loan_Application_Id__c from Retry_Count__c where Loan_Application_Id__c =: loanApplicationId and Service_Name__c =: 'OfferScreenApiCount' WITH SECURITY_ENFORCED];
                if(retryCountList.isEmpty()) {
                    retryCount.Loan_Application_Id__c = loanApplicationId;
                    retryCount.Service_Name__c = 'OfferScreenApiCount';
                    retryCount.Count__c = 0;
                    if(Schema.sObjectType.Retry_Count__c.isCreateable())
                    {
                        insert retryCount;
                    }
                }
                else{
                    System_Constant_custom_metadata__mdt metadata = System_Constant_custom_metadata__mdt.getInstance('offer_engine'); 
                    //If number of attempts are greater than predefined number of attempts.
                    Retry_Count__c  count = [select Count__c from Retry_Count__c where Loan_Application_Id__c =: loanApplicationId and Service_Name__c =: 'OfferScreenApiCount' WITH SECURITY_ENFORCED];
                    if(count.Count__c >= metadata.Number_Of_Attempts__c)
                    {
                        System.debug('hi');
                        responseJSON.message = System.Label.Retry_Exhausted;
                        String serializedResponse = JSON.serialize(responseJSON);
                        return serializedResponse;
                    }
                }
            }
            String serializedResponse = JSON.serialize(responseJSON);
            if(Test.isRunningTest())
            {
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
            return serializedResponse;
        }
        //Catch block 
         catch (Exception e) {
        ErrorLoggerUtil.logErrorEvent('IND_OfferScreenController', 'checkRetryExhausted', System.Label.Apex, e,loanApplicationId);
        throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    //Wrapper Class
    public class FinalTermApiWrapper {
        public String message {get;set;}
        //constructor
        public FinalTermApiWrapper(){
            this.message = NUll;
        }
    }
    
    /*
* @Method:      retryCountIncrease
* @Created by:  Raj Gupta
* @Description: This method increment the retry attemps count.
* @Param:       String - loan Applicantion ID
* @Return:      NA
*/
    @AuraEnabled
    public static void retryCountIncrease(String loanApplicationId){
        try{
            Retry_Count__c  count = [select Count__c from Retry_Count__c where Loan_Application_Id__c =: loanApplicationId and Service_Name__c =: 'OfferScreenApiCount' WITH SECURITY_ENFORCED];
            count.Count__c += 1;
            if (Schema.sObjectType.Retry_Count__c.isUpdateable()){
                update count;
            } 
        }
        //Catch block 
        catch (Exception e) {
        ErrorLoggerUtil.logErrorEvent('IND_OfferScreenController', 'retryCountIncrease', System.Label.Apex, e,loanApplicationId);
        throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
     /*
* @Method:      loadSelectedSchemeData
* @Created by:  Rajat Jaiswal
* @Description: This method used for get selected scheme record.
* @Param:       String - scheme Id
* @Return:      Scheme Record
*/
@AuraEnabled
public static Schemes__c loadSelectedSchemeData(String selectedSchemeId){
    try{
        Schemes__c  schemeRec = [SELECT Id, Name, FromDate__c, ToDate__c, Product__c, SubProduct__c, UsedVehicleProductCode__c, MinimumAge__c, MaximumAge__c, MinimumCIBILScore__c, MaximumCIBILScore__c, ExistingCustomer__c, RiskBand__c, ServiceCharges__c, DocCharges__c, ProductCode__c, Unique_Identifier__c, Scheme_Code__c, Products__c, Scheme_Expiry__c, Vehicle_Type__c, Manufacturer_Code_Make__c, Agent_BL_code__c, Stamping_Charges__c, Due_Date_Shift_Charges__c, ECS_verification_by_Bank_customer__c, Verification_charges__c, Delinquency_Fund__c, Deliquency_Fund_type__c, RTO_Prefix__c, Trade_Certificate__c, Dlr_Exp_Reimburse_Amt__c, Dlr_Exp_Reimbursement__c, ECS_verification_Not_Applicable__c, Mfr_Exp_Reimburse_Amt__c, Mfr_Exp_Reimburse__c, Mfr_Exp_Reimburse_Type__c, Dealer_incentive_amount_main_dealer__c, Dealer_incentive_amount_sub_dealer__c, Dealer_incentive_amount_main_dealer_p__c, Dealer_incentive_amount_sub_dealer_p__c, Dealer_discount_to_Customer__c, Gift_through_dealer_amount__c, Gift_through_dealer_amount_p__c, Mfr_incentive__c, Mfr_incentive_p__c, DSM_Name1__c, DSM_Incentive1__c, DSM_Incentive1_p__c, DSM_Name2__c, DSM_Incentive2__c, DSM_Incentive2_p__c, Referred_By__c, Referrer_Incetive__c, Referrer_Name__c, Branch__c, Emp_No__c, Emp_Name__c, Deal_no__c, Provision_Channel_Cost__c, DSA_Pay__c, RCU_Retention_Charges__c, Dlr_Exp_Reimburse_Type__c, Moratorium_Days__c, Model__c, State__c, Dealer_Sub_dealer_name__c, Advance_EMI__c, Payout_Cap__c, Loan_Amount_Min__c, Min_Loan_Amount_Not_Applicable__c, Loan_amount_Max__c, Max_Loan_amount_Not_Applicable__c, Tenure_Min_in_months__c, Min_Tenure_Not_Applicable__c, Tenure_Max_in_months__c, Max_Tenure_Not_Applicable__c, Low_IRR_Scheme__c, Imputed_IRR_for_Low_IRR_Scheme__c FROM Schemes__c WHERE Id =: selectedSchemeId WITH SECURITY_ENFORCED];
        if (schemeRec != null) {
            return schemeRec;
        }
    }
    catch (Exception e) {
    ErrorLoggerUtil.logErrorEvent('IND_OfferScreenController', 'loadSelectedSchemeData', System.Label.Apex, e, selectedSchemeId);
    throw new AuraHandledException(System.Label.ExceptionMessage);
    }
    return null;
}

    /*
    * @Method:      getVehicleRecords
    * @Created by:  Gaurav Rawat
    * @Description: This method fetch data of vehicle
    * @Param:       String - loan Applicantion ID
    * @Return:      data
    */
    @AuraEnabled
    public static List<Vehicle_Detail__c> getVehicleRecords(String loanApplicationId){

        List<Vehicle_Detail__c> vehicleList = new List<Vehicle_Detail__c>();
            
        vehicleList = [SELECT Id,Variant__c,Change_Pay_IN_Pay_OUT__c,Loan_Application__r.Loan_Amount__c,(Select Id,Loan_Amount__c from Final_Terms__r), Installment_Type__c FROM Vehicle_Detail__c WHERE Loan_Application__c=:loanApplicationId WITH SECURITY_ENFORCED ORDER BY CreatedDate ASC];
        
        return vehicleList;
    }
     /*
    * @Method:      updateChangePayinouts
    * @Created by:  Santhosh Guhan
    * @Description: This method is used to update the change pay in pay out flag in vehicle detail
    * @Param:       String - loan Applicantion ID
    * @Return:      data
    */
    @AuraEnabled
    public static void updateChangePayinouts(String loanApplicationId){

        List<Vehicle_Detail__c> vehicleList = new List<Vehicle_Detail__c>();
        List<Vehicle_Detail__c> updVehicleList = new List<Vehicle_Detail__c>();

            
        vehicleList = [SELECT Id,Variant__c,Change_Pay_IN_Pay_OUT__c FROM Vehicle_Detail__c WHERE Loan_Application__c=:loanApplicationId WITH SECURITY_ENFORCED ORDER BY CreatedDate ASC];
        
        for(Vehicle_Detail__c vdc : vehicleList){
            if(vdc.Change_Pay_IN_Pay_OUT__c == true){
                vdc.Change_Pay_IN_Pay_OUT__c = false;
                updVehicleList.add(vdc);
            }
        }
        if(!updVehicleList.isEmpty()){
            update updVehicleList;
        }
    }
    @AuraEnabled
    public static List<Final_Term__c> checkL1OfferScreenSubmitted(String loanApplicationId, String vehicleId){

        List<Final_Term__c> finaltermList = new List<Final_Term__c>();
        
        String query = 'SELECT Id,L1_Offer_Screen_Submitted__c,No_of_Installment__c, Holiday_period__c,Vehicle_Detail__r.Vehicle_type__c,Vehicle_Detail__r.Vehicle_SubCategory__c,Loan_Application__r.Product_Type__c,Loan_Application__r.StageName,Loan_Application__r.LastStageName__c From Final_Term__c WHERE Loan_Application__c =: loanApplicationId';
        if(String.isNotBlank(vehicleId)){
            query += ' AND Vehicle_Detail__c =: vehicleId WITH SECURITY_ENFORCED';
            finaltermList = Database.query(query);
        }else {
            query += ' WITH SECURITY_ENFORCED';
            finaltermList = Database.query(query);
        }
        
        return finaltermList;
    }
    //SFTRAC-570
    @AuraEnabled 
    public static List<Structered_EMI__c> getStructedEMI(String loanAppId, String vehicleId){
        try {
            List<Structered_EMI__c> str = new List<Structered_EMI__c>();
            str = [Select Id,From_Month__c,To_Month__c,EMI_Amount__c FROM Structered_EMI__c WHERE Loan_Application__c=:loanAppId AND Vehicle_Detail__c=:vehicleId WITH SECURITY_ENFORCED];
            if(!str.isEmpty()){
                return str;
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    //SFTRAC-714
    @AuraEnabled
    public static List<RepaymentWrapper> emiRepaymentSchedule(Decimal principal , String irr, Date loanDate, Integer increment, Integer day, String frequency, Date repaymentDate, Date secondEMI, Boolean advanceEMI) 
    {
        try{ 
            Integer days = loanDate.daysBetween(repaymentDate);
            Integer excessDays;
            Integer frequencyDays;
            List<RepaymentWrapper> lstCom = new List<RepaymentWrapper>();
            Decimal interest; 
            Decimal brokenInterest;
            Decimal secondLastClosingBalance;
            Date nextdue;
            Date lastDueDate;
            Integer x;
            Decimal toRound;
            Decimal iRRInterest = Decimal.valueof(irr);
            switch on frequency {
                when '1' {	
                    frequencyDays = 30;	
                }	
                when '2' {	
                    frequencyDays = 60;	
                }
                when '3' {
                    frequencyDays = 90;	
                }
                when '6' {
                    frequencyDays = 180;		
                }
            }
            if(advanceEMI == true){
                x = 0;
            } else {
                x = 1;
            }
            if(frequency == '1'){
              double finalResult1 = calculateMonthlyPayment( Principal,  iRRInterest,  Increment-x);
                for(integer i = 1 ; i<=(Increment-x) ; i++)
                {
                    RepaymentWrapper ap = new RepaymentWrapper();
                    ap.instalmentAmount = string.valueof(Math.round(finalResult1));
                    if(i==1){
                        ap.days = days;
                        ap.dueDate = repaymentDate;
                        repaymentDate = secondEMI;
                        //repaymentDate = repaymentDate.addMonths(1); 
                            excessDays = days - frequencyDays;
                            brokenInterest = (iRRInterest*Principal*excessDays)/36000;
                            toRound = Integer.Valueof(ap.instalmentAmount) + brokenInterest;
                            ap.instalmentAmount = string.valueof(toRound.round(roundingMode.UP));
                            interest = (iRRInterest*Principal*ap.days)/36500;
                            ap.interestComp = interest.setScale(2);
                    // }
                    }
                    else{
                        ap.days=30;
                        ap.dueDate = repaymentDate;
                        nextdue = repaymentDate.addMonths(1); 
                        repaymentDate = repaymentDate.addMonths(1); 
                        Integer diff = lastDueDate.daysBetween(ap.dueDate);
                        interest = (iRRInterest*Principal*diff)/36500;
                        ap.interestComp = interest.setScale(2);
                    }      
                    
                    if(i == (Increment-x)){
                       ap.closingPrinciple=secondLastClosingBalance;
                       ap.openingPrinciple = ap.closingPrinciple;
                       ap.principalComp = ap.closingPrinciple;
                       toRound = ap.interestComp + ap.principalComp;
                       ap.instalmentAmount = String.valueof(toRound.round(roundingMode.UP));  
                       ap.closingPrinciple = Principal-ap.principalComp;
                    }
                    else{
                        ap.principalComp = Integer.Valueof(ap.instalmentAmount)-ap.interestComp;
                        ap.closingPrinciple = Principal-ap.principalComp;
                        ap.openingPrinciple = ap.closingPrinciple + ap.principalComp;
                        if(i == (Increment-x-1))
                        {
                            secondLastClosingBalance = ap.closingPrinciple;
                        }                 
                    }
                    ap.irr = iRRInterest;
                    Principal = ap.closingPrinciple;
                    ap.instalmentNo = i;
                    lastDueDate = ap.dueDate;
                    lstCom.add(ap);
                }
            }else{
            decimal finalResult1 = calculateMonthlyPayment( Principal,  iRRInterest*integer.valueof(frequency),  Increment/integer.valueof(frequency));
            for(integer i = 1 ; i<=Increment/integer.valueof(frequency) ; i++)
            {
                RepaymentWrapper ap = new RepaymentWrapper();
                ap.instalmentAmount = string.valueof(Math.round(finalResult1));
                if(i==1){
                        ap.days = days;
                        ap.dueDate = repaymentDate;
                        repaymentDate = secondEMI;
                        //repaymentDate = repaymentDate.addMonths(integer.valueof(frequency)); 
                            excessDays = days - frequencyDays;
                            brokenInterest = (iRRInterest*Principal*excessDays)/36000;
                            toRound = Integer.Valueof(ap.instalmentAmount) + brokenInterest;
                            ap.instalmentAmount = string.valueof(toRound.round(roundingMode.UP));
                            interest = (iRRInterest*Principal*ap.days)/36500;
                            ap.interestComp = interest.setScale(2);
                    //}
                }
                else{
                    if(frequency == '2'){
                        ap.days=60;
                    }
                    else if(frequency == '3'){
                        ap.days=90;
                    }
                    else if(frequency == '6'){
                        ap.days=180;
                    }
                    ap.dueDate = repaymentDate;
                        nextdue = repaymentDate.addMonths(integer.valueof(frequency)); 
                        repaymentDate = repaymentDate.addMonths(integer.valueof(frequency)); 
                        Integer diff = lastDueDate.daysBetween(ap.dueDate);
                        interest = (iRRInterest*Principal*diff)/36500;
                        ap.interestComp = interest.setScale(2);
                }      

                if(i == Increment/integer.valueof(frequency)){
                    ap.closingPrinciple=secondLastClosingBalance;
                    ap.openingPrinciple = ap.closingPrinciple;
                    ap.principalComp = ap.closingPrinciple;
                    toRound = ap.interestComp + ap.principalComp;
                    ap.instalmentAmount = String.valueof(toRound.round(roundingMode.UP));
                    ap.closingPrinciple = Principal-ap.principalComp;
                }
                else{
                    ap.principalComp = Integer.Valueof(ap.instalmentAmount)-ap.interestComp;
                    //ap.openingPrinciple = ap.principalComp;
                    ap.closingPrinciple = Principal-ap.principalComp;
                    ap.openingPrinciple = ap.closingPrinciple + ap.principalComp;
                    if(i == Increment/integer.valueof(frequency)-1)
                    {
                        secondLastClosingBalance = ap.closingPrinciple;
                    }                 
                }
                ap.irr = iRRInterest;
                Principal = ap.closingPrinciple;
                lastDueDate = ap.dueDate;
                ap.instalmentNo = i;
                lstCom.add(ap);
            }
        }
            return lstCom;
        }
        catch(DmlException e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    Public static Decimal calculateMonthlyPayment(Decimal principalAmount, Decimal interestRate, Double loanTermMonths) {
        Double monthlyInterestRate = interestRate / 12 / 100;
        Decimal numerator = principalAmount * monthlyInterestRate;
        Decimal denominator = 1 - (1 / Math.pow(1 + monthlyInterestRate, loanTermMonths));
        return numerator / denominator;
    }

    @AuraEnabled
    public static offerResponseContentVersion getOfferResponse(String loanApplicationId,String vehicleId){
        try {
            List<Integration_Log__c> intLog = new List<Integration_Log__c>();
            offerResponseContentVersion offerRes = new offerResponseContentVersion();
            intLog = [SELECT Id,Original_response__c FROM Integration_Log__c WHERE Loan_Application__c =:loanApplicationId AND Service_Name__c = 'TF Offer Engine' AND ReferenceId__c =:vehicleId order by createddate desc LIMIT 1];
            if(!intLog.isEmpty()){
                if(!intLog[0].Original_response__c.contains('Please refer related list for response file')){
                    offerRes.response = intLog[0].Original_response__c;
                    offerRes.contentVersion = false;
                }
                else {
                ContentDocumentLink cdlList = new ContentDocumentLink();
                cdlList= [SELECT ContentDocumentId 
                            FROM ContentDocumentLink 
                            WHERE LinkedEntityId =: intLog[0].Id AND ContentDocument.Title = 'ResponseFile'
                            LIMIT 1];
                ContentVersion conv = [Select Id,versionData from ContentVersion where ContentDocumentId =:cdlList.ContentDocumentId];
               offerRes.response = EncodingUtil.base64Encode(conv.versionData);
               offerRes.contentVersion = true; 
            }
            return offerRes;
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static ROIMasterWrapper roiMasterTractor(String loanApplicationId){
        ROIMasterWrapper roiMasterWrapper = new ROIMasterWrapper();
        List<Opportunity> oppList = new List<Opportunity>();
        oppList =  [Select Id,Vehicle_Type__c,Customer_Type__c From Opportunity Where Id=: loanApplicationId WITH SECURITY_ENFORCED LIMIT 1 ];

        if(oppList.size() > 0 && oppList[0].Customer_Type__c == 'Non-Individual'){
            roiMasterWrapper.isNonIndividual = true;
            return roiMasterWrapper;
        }else{
            roiMasterWrapper.isNonIndividual = false;
        }

        if(oppList.size() > 0){
            String vehicleCode;
            if(oppList[0].Vehicle_Type__c == 'New'){
                vehicleCode = 'N';
            }
            if(oppList[0].Vehicle_Type__c == 'Used'){
                vehicleCode = 'U';
            }
            if(oppList[0].Vehicle_Type__c == 'Refinance'){
                vehicleCode = 'R';
            }

            /*SFTRAC-1705 start*/
            String cusType;
            List<CIBIL_Details__c> cibliList = [Select Id,Score__c from CIBIL_Details__c where Applicant__r.Opportunity__c =: loanApplicationId AND Applicant__r.Applicant_Type__c = 'Borrower' LIMIT 1];

            if(cibliList.size() > 0){
                if(cibliList[0]?.Score__c == '-1' || cibliList[0]?.Score__c == '0'){
                    cusType = 'NTB';
                }else{
                    cusType = 'ETB';
                }
            }else{
                cusType = 'NTB';
            } 
            //SFTRAC-1705 end

            for(ROI_Master__c roiMaster : [Select id,Description__c, Max_Value__c,Min_Value__c from ROI_Master__c where Product__r.ProductCode = 'T' AND Vehicle_Category__c =: vehicleCode AND (Description__c = 'GROSS_IRR' OR Description__c = 'CRM_IRR' OR Description__c = 'TENURE') AND Customer_Type__c =: cusType WITH SECURITY_ENFORCED]){//SFTRAC-1705 - Added - Customer_Type__c =: cusType
                if(roiMaster.Description__c == 'GROSS_IRR'){
                    roiMasterWrapper.GROSS_IRR_MIN = roiMaster.Min_Value__c;
                    roiMasterWrapper.GROSS_IRR_MAX = roiMaster.Max_Value__c;
                }else if(roiMaster.Description__c == 'CRM_IRR'){
                    roiMasterWrapper.CRM_IRR_MIN = roiMaster.Min_Value__c;
                    roiMasterWrapper.CRM_IRR_MAX = roiMaster.Max_Value__c;
                }else if(roiMaster.Description__c == 'TENURE'){
                    roiMasterWrapper.TENURE_MIN = roiMaster.Min_Value__c;
                    roiMasterWrapper.TENURE_MAX = roiMaster.Max_Value__c;
                }
            }
        }
        return roiMasterWrapper;
    }

    public Class RepaymentWrapper{
        
        @AuraEnabled
        public Boolean inputError {
            get;
            set;
        }
        @AuraEnabled
        public Integer instalmentNo {
            get;
            set;
        }
        @AuraEnabled
        public String instalmentAmount {
            get;
            set;
        }
        
        @AuraEnabled
        public decimal principalComp
        {
            get;
            set;
        }
        @AuraEnabled
        public decimal interestComp {
            get;
            set;
        }
        @AuraEnabled
        public decimal irr {
            get;
            set;
        }
        @AuraEnabled
        public decimal openingPrinciple {
            get;
            set;
        }
        @AuraEnabled
        public decimal  closingPrinciple {
            get;
            set;
        }
        @AuraEnabled
        public Date dueDate {
            get;
            set;
        }
        @AuraEnabled
        public Integer days {
            get;
            set;
        }        
    }

    public class ROIMasterWrapper{
        @AuraEnabled public Decimal CRM_IRR_MIN;
        @AuraEnabled public Decimal CRM_IRR_MAX;
        @AuraEnabled public Decimal GROSS_IRR_MIN;
        @AuraEnabled public Decimal GROSS_IRR_MAX;
        @AuraEnabled public Decimal TENURE_MAX;
        @AuraEnabled public Decimal TENURE_MIN;
        @AuraEnabled public Boolean isNonIndividual;
    }

    public class offerResponseContentVersion{
        @AuraEnabled public Boolean contentVersion;
        @AuraEnabled public String response;
    }
    @AuraEnabled
    public static Boolean isPayInPayOutCompleted(String finalTermId){
        return [SELECT id FROM Final_Term__c Where Id =: finalTermId AND Is_Change_PayIn_PayOut_Completed__c = true].size() > 0 ? true : false;
    }
}