/**
* @Name         IND_LWC_StpChecksCntrl
* @Author       Raj Gupta,Sri Ramadugu
* @Company      Persistent Systems
* @Description  This class contains all methods related to Stp check
* Inputs:       NONE
* Test Class:   not yet created
* History:
*/
public with sharing class IND_LWC_StpChecksCntrl {
    
    /*
    * @Method:      getFinalTermFieldValidationDetails
    * @Created by:  Raj Gupta,Sri Ramadugu
    * @Description: This method will fetch fields FROM Opportunity, vehicle details and metadata.
    * @Param:       String - current Loan Applicantion ID,Applicant ID
    */
    @AuraEnabled
    public static void stpChecks(String opportunityId) {
        try {
            Id recTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
            Boolean isNonStp = false;
            List<String> nonStpReasons = new List<String>();
            List<String> customerCodeFlags = new List<String>();
            Opportunity opp = [SELECT Id, Product_Type__c, Sanction_Status__c, STP_Failure_Reasons__c,Vehicle_Sub_Category__c, Loan_amount__c,
                               Vehicle_Type__c, Ex_showroom_price_carwale__c, Total_Funded_premium_amount__c, On_Road_price_carwale__c, 
                               Ex_showroom_price__c, On_Road_price__c,Total_Funded_Premium__c,
                               (SELECT ID FROM Applicants__r WHERE Applicant_Type__c =: System.Label.Borrower) 
                               FROM Opportunity WHERE Id =: opportunityId WITH SECURITY_ENFORCED];
            Integer fundedPremumium = opp.Total_Funded_Premium__c != null ? Integer.valueOf(opp.Total_Funded_Premium__c) : 0;  
            if (opportunityId != null) {
                Customer_Code__c[] custcodes = [SELECT Id, Name, Flag__c, Loan_Application__c FROM Customer_Code__c 
                                                WHERE Loan_Application__c =: opportunityId WITH SECURITY_ENFORCED];
                for(Customer_Code__c customerCode : custcodes){
                     customerCodeFlags.add(customerCode.Flag__c);
                }
                for(Exposure__c exp : [select id, Status_Flag__c, SOH__c from Exposure__c WHERE Loan_Application__c =: opportunityId WITH SECURITY_ENFORCED] ){
                    customerCodeFlags.add(exp.Status_Flag__c);
                }
                if (!custcodes.isEmpty()) {
                    for(String custcode:customerCodeFlags){
                        if(custcode == 'R' || custcode == 'V' || custcode == 'G' || custcode == 'F'){
                            isNonStp = true;
                            nonStpReasons.add(custcode +' '+ System.Label.R_V_G_F_flag_presence_in_Add_Cust_codes);
                        }
                    }
                }
                Exposure__c[] exposure = [SELECT Id, Name, Type__c, Status_Flag__c, SOH__c, Loan_Application__c FROM Exposure__c 
                                          WHERE Loan_Application__c =: opportunityId WITH SECURITY_ENFORCED];
                if(!exposure.isEmpty()){
                    for(Exposure__c expo:exposure){
                        
                        if (expo.Type__c == System.Label.Borrower_Exposure && expo.Status_Flag__c == 'L' && opp.Product_Type__c == System.Label.TwoWheeler &&  opp.Vehicle_Type__c != System.Label.used ) {
                            isNonStp = true;
                            nonStpReasons.add(System.Label.X2Wheeler_live_loan_exists);

                        }
                        if (expo.Type__c == System.Label.Borrower_Exposure
                            &&  (decimal.valueOf(opp.Loan_amount__c) + expo.SOH__c) > 2000000 
                            && opp.Product_Type__c == System.Label.PassengerVehicles) {
                                isNonStp = true;
                                nonStpReasons.add(System.Label.Threshold_Exposure_amount_breach);
                            }
                        }
                }
                if (opp.Vehicle_Type__c == System.Label.new 
                && (decimal.valueOf(opp.Loan_amount__c) + fundedPremumium) > 700000 
                && opp.Product_Type__c == System.Label.PassengerVehicles) {
                    isNonStp = true;
                    nonStpReasons.add(System.Label.Threshold_Loan_amount_breach);
                }
           
                if (opp.Vehicle_Sub_Category__c != null && opp.Vehicle_Sub_Category__c != 'UIM' && opp.Vehicle_Type__c != System.Label.new && opp.Product_Type__c == System.Label.PassengerVehicles 
                && (decimal.valueOf(opp.Loan_amount__c) + fundedPremumium) > 400000) {
                    isNonStp = true;
                    nonStpReasons.add(System.Label.Threshold_Loan_amount_breach);
                }
            
            if (opp.Vehicle_Type__c == System.Label.new && opp.Product_Type__c == System.Label.TwoWheeler 
                && (decimal.valueOf(opp.Loan_amount__c) + fundedPremumium) > 150000) {
                    isNonStp = true;
                    nonStpReasons.add(System.Label.Threshold_Loan_amount_breach);
                }
            if (opp.Vehicle_Sub_Category__c != null && opp.Vehicle_Sub_Category__c != 'UIM' && opp.Vehicle_Type__c == System.Label.used && opp.Product_Type__c == System.Label.TwoWheeler) {
                    isNonStp = true;
                    nonStpReasons.add(System.Label.Threshold_Loan_amount_breach);
                }
            if (opp.Vehicle_Type__c == System.Label.new && (decimal.valueOf(opp.Loan_amount__c)) > 700000 
                && opp.Product_Type__c == System.Label.PassengerVehicles) {
                    isNonStp = true;
                    nonStpReasons.add(System.Label.Threshold_Loan_amount_breach);
                    
                }
            if ( opp.Vehicle_Sub_Category__c != null && opp.Vehicle_Sub_Category__c == 'UIM' && opp.Vehicle_Type__c != System.Label.new && opp.Product_Type__c == System.Label.PassengerVehicles 
                && (decimal.valueOf(opp.Loan_amount__c)) > 400000) {
                    isNonStp = true;
                    nonStpReasons.add(System.Label.Threshold_Loan_amount_breach);
                    
                }
            if (opp.Vehicle_Type__c == System.Label.new && opp.Product_Type__c == System.Label.TwoWheeler 
                && (decimal.valueOf(opp.Loan_amount__c)) > 150000) {
                    isNonStp = true;
                    nonStpReasons.add(System.Label.Threshold_Loan_amount_breach);
                    
                }
            if(opp.Vehicle_Sub_Category__c != null && opp.Vehicle_Sub_Category__c == 'UIM' && opp.Vehicle_Type__c == System.Label.used && opp.Product_Type__c == System.Label.TwoWheeler) {
                    isNonStp = true;
                    nonStpReasons.add(System.Label.Threshold_Loan_amount_breach);
                    
                }
       
                //   if(expo!=null && expo.Type__c==System.Label.Borrower_Exposure && expo.Status_Flag__c!='L' && opp.Vehicle_Type__c=='Refinance' && opp.Product_Type__c == System.Label.TwoWheeler){
                //     isNonStp = true;
                //}
                Documents__c[] doc = [SELECT Id, Permanent_Residential_Address_Proof__c, Submit_to_CMU__c, CMU_Accept_Reject__c, 
                                      Current_Residential_Address_Proof__c FROM Documents__c 
                                      WHERE Opportunity_Relation__c =: opportunityId AND RecordTypeId =: recTypeId WITH SECURITY_ENFORCED Limit 1];
                if(!doc.isEmpty()){
                    if (!doc[0].Permanent_Residential_Address_Proof__c) {
                        isNonStp = true;
                    }
                    if (!doc[0].Submit_to_CMU__c && doc[0].CMU_Accept_Reject__c != 'Accept') {
                        isNonStp = true;
                        nonStpReasons.add(System.Label.CMU_Verification_pending);
                    }
                }
                
                Documents__c[] doc1 = [SELECT Id,Current_Residential_Address_Proof__c,Opportunity_Relation__c FROM Documents__c
                                       WHERE Opportunity_Relation__c =: opportunityId and Current_Residential_Address_Proof__c=:true WITH SECURITY_ENFORCED limit 1];
                if (doc1.isEmpty() ) {
                    isNonStp = true;
                    nonStpReasons.add(System.Label.Present_addr_not_on_KYC);
                    
                }
                Documents__c[] document1 = [SELECT Id,Current_Residential_Address_Proof__c,Opportunity_Relation__c FROM Documents__c 
                                            WHERE Opportunity_Relation__c =: opportunityId and Is_Photocopy__c = false and Document_Type__c =: System.Label.RC_Document WITH SECURITY_ENFORCED
                                            limit 1 
                                           ];
                if (document1.isEmpty()  && opp.Vehicle_Type__c != System.Label.new) {
                    isNonStp = true;
                    nonStpReasons.add(System.Label.Original_RC_copy_NA);
                }
                Documents__c[] document2 = [SELECT Id,Current_Residential_Address_Proof__c,Opportunity_Relation__c FROM Documents__c 
                                            WHERE Opportunity_Relation__c =: opportunityId and Document_Type__c =: System.Label.Vehicle_Insurance_Policy WITH SECURITY_ENFORCED
                                            limit 1
                                           ];
                if (document2.isEmpty() && opp.Vehicle_Type__c != System.Label.new) {
                    isNonStp = true;
                    nonStpReasons.add(System.Label.Insurance_policy_doc_NA);
                }
                String vehicleModel;
                Vehicle_Detail__c[] vehicleDetails = [SELECT Id,Vehicle_Category__c,  Model__c , Insurance_declared_value__c,Valuation_price__c, 
                                                      Insurance_expiring_within_60_days__c, OEM_Dealer__c, Insurance_type__c, Ins_Expiry_date__c 
                                                      FROM Vehicle_Detail__c 
                                                      WHERE Loan_Application__c =: opportunityId WITH SECURITY_ENFORCED];
                Boolean flag = false;
                if(!vehicleDetails.isEmpty()){
                    if(vehicleDetails[0].Valuation_price__c==null) {
                        flag = true;
                    }
                    if(!vehicleDetails.isEmpty() && vehicleDetails[0].Model__c != null){
                        vehicleModel = vehicleDetails[0].Model__c;
                    }
                    if (vehicleDetails[0].Ins_Expiry_date__c > Date.today() && opp.Vehicle_Type__c == System.Label.used) {
                        flag = true;
                    }
                    if (vehicleDetails[0].Ins_Expiry_date__c < Date.today() && opp.Vehicle_Type__c == System.Label.used) {
                        isNonStp = true;
                        nonStpReasons.add(System.Label.Insurance_expired);
                    }
                    if (vehicleDetails[0].Insurance_expiring_within_60_days__c && flag && opp.Vehicle_Type__c == System.Label.used) {
                        isNonStp = true;
                        nonStpReasons.add(System.Label.Insurance_expiring_within_60days);
                    }
                    
                    if (vehicleDetails[0].Insurance_type__c == System.Label.Third_Party && opp.Vehicle_Type__c == System.Label.used) {
                        isNonStp = true;
                        nonStpReasons.add(System.Label.Insurance_type_Third_Party);
                    }
                    if (!vehicleDetails[0].OEM_Dealer__c && opp.Vehicle_Type__c == System.Label.used) {
                        isNonStp = true;
                        nonStpReasons.add(System.Label.Non_OEM_dealer);
                    }
                    if(vehicleModel != null){
                        List<Product2> product2 =  [Select asset_category__c from product2 where name=:vehicleModel WITH SECURITY_ENFORCED Limit 1]; 
                        
                        if(!product2.isEmpty() && product2[0].asset_category__c!= 'A' && product2[0].asset_category__c!= 'B'){
                            isNonStp = true;
                            nonStpReasons.add(System.Label.Asset_Category_Not_A_or_B);
                        }
                    }
                    if (opp.Ex_showroom_price_carwale__c == null || opp.Ex_showroom_price_carwale__c == 0) {
                        isNonStp = true;
                        nonStpReasons.add(System.Label.Carwale_price_NA);
                    }
                    if (opp.Ex_showroom_price_carwale__c != null && opp.Ex_showroom_price__c > opp.Ex_showroom_price_carwale__c 
                        && opp.On_Road_price__c > opp.On_Road_price_carwale__c) {
                            isNonStp = true;
                            nonStpReasons.add(System.Label.Ex_showroom_ORP_breach);
                        }
                }
                Final_Term__c finalTerm ;

                for(Final_Term__c finalTermRecord : [Select Loan_Amount__c, OfferengineMaxLoanAmount__c, OfferengineMaxTenure__c,
                OfferengineMinLoanAmount__c, OfferengineMinTenure__c, LtvEngine_Ltv__c, Tenure__c, Scheme_Bank_offers__c,
                IsRequiredCRMIRRChanged__c,Loan_Application__r.LeadSource FROM Final_Term__c WHERE Loan_Application__c =: opportunityId WITH SECURITY_ENFORCED]){
                    if(finalTermRecord.Scheme_Bank_offers__c != null || finalTermRecord.Loan_Application__r.LeadSource == 'Hero'){//CISH-23
                    finalTerm = finalTermRecord;
                    }
                
                }
                if (finalTerm.LtvEngine_Ltv__c == null) {
                    isNonStp = true;
                }
                if (opp.Vehicle_Type__c == System.Label.new || opp.Vehicle_Type__c == System.Label.new || opp.Vehicle_Type__c == System.Label.new) {
                    if (fundedPremumium > finalTerm.LtvEngine_Ltv__c) {
                        isNonStp = true;
                    }
                    
                }
                
                if (finalTerm.IsRequiredCRMIRRChanged__c) {
                    isNonStp = true;
                    nonStpReasons.add(System.Label.Change_in_required_CRM_IRR);
                }
                
                if(finalTerm.OfferengineMinLoanAmount__c!=null && finalTerm.Loan_Amount__c!=null &&finalTerm.OfferengineMaxLoanAmount__c!=null ){
                    if(finalTerm.OfferengineMinLoanAmount__c > decimal.valueOf(finalTerm.Loan_Amount__c) 
                       || decimal.valueOf(finalTerm.Loan_Amount__c) > finalTerm.OfferengineMaxLoanAmount__c) {
                           isNonStp = true;
                           nonStpReasons.add(System.Label.Min_Max_Loan_amount_breach);
                       }
                }
                
                if(finalTerm.OfferengineMinTenure__c!=null && finalTerm.Tenure__c!=null &&finalTerm.OfferengineMaxTenure__c!=null ){
                    if (finalTerm.OfferengineMinTenure__c > decimal.valueOf(finalTerm.Tenure__c) 
                        || decimal.valueOf(finalTerm.Tenure__c) > finalTerm.OfferengineMaxTenure__c) {
                            isNonStp = true;
                            nonStpReasons.add(System.Label.Min_Max_tenure_breach);
                        }
                }
                Vehicle_Detail__c[] vehicleDetailsbase = [SELECT Base_Prices__c,OEM_Dealer__c,Insurance_declared_value__c 
                                                          FROM Vehicle_Detail__c WHERE Loan_Application__c =: opportunityId];
                                                          if(!vehicleDetailsbase.isEmpty()){
                                                            for(Vehicle_Detail__c vehicleDetails1:vehicleDetailsbase){
                                                                if(finalTerm.LtvEngine_Ltv__c !=null && opp.Loan_amount__c!=null ){            
                                                                       //Add vehicle type is new
                                                                       Integer total = finalTerm.Loan_amount__c != null ? Integer.valueOf(finalTerm.Loan_amount__c) + fundedPremumium : fundedPremumium;
                                                                     
                                                                        if(opp.Vehicle_Type__c == System.Label.new && finalTerm.Loan_amount__c!=null && opp.On_Road_price__c!=null  && opp.On_Road_price__c >0 ){
                                                                            if ( (total  * 100) / Integer.valueOf(opp.On_Road_price__c) > Integer.valueOf(finalTerm.LtvEngine_Ltv__c)) {
                                                                                isNonStp = true;
                                                                                nonStpReasons.add(System.Label.LTV_breach);
                                                                            }
                                                                        }
                                                                        else{
                                                                            if(finalTerm.Loan_amount__c!=null && vehicleDetails1.Base_Prices__c!=null && vehicleDetails1.Base_Prices__c >0 ){
                                                                                if ( (total  * 100) / Integer.valueOf(vehicleDetails1.Base_Prices__c ) > Integer.valueOf(finalTerm.LtvEngine_Ltv__c) ){
                                            isNonStp = true;
                                            nonStpReasons.add(System.Label.LTV_breach);
                                        }
                                    }
                                }

                               if (vehicleDetails1.OEM_Dealer__c && vehicleDetails1.Insurance_declared_value__c!=null
                                   && (decimal.valueOf(opp.Loan_amount__c)) > (vehicleDetails1.Insurance_declared_value__c / 100) * 140) {
                                       isNonStp = true;
                                       nonStpReasons.add(System.Label.OEM_dealer_Loan_Amt_140_of_IDV);
                                       
                                   }
                               if (!vehicleDetails1.OEM_Dealer__c && vehicleDetails1.Insurance_declared_value__c!=null
                                   && (decimal.valueOf(opp.Loan_amount__c)) > (vehicleDetails1.Insurance_declared_value__c / 100) * 100) {
                                       isNonStp = true; 
                                       nonStpReasons.add(System.Label.Non_OEM_dealer_Loan_Amt_100_of_IDV);
                                   }
                           }         
                    }
                }
                
                
                Applicant__c[] apps = [SELECT Id, Bureau_Pull_Match__c,Bureau_Pull_Message__c, Run_Emi_Executed__c, Scorecard_Decision__c, Current_Address_Not_Present__c, 
                                       Check_Eligibility_Match__c, ABB_as_per_Perfios__c, In_Active_Applicant__c, Opportunity__c 
                                       FROM Applicant__c WHERE Opportunity__c =: opportunityId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED];
                set < Id > newt = new set < Id > ();
                
                for (Applicant__c a: apps) {
                    if (a.ABB_as_per_Perfios__c == null) {
                        isNonStp = true;
                    }
                    if (a.Scorecard_Decision__c != 'Dark Green' && a.Scorecard_Decision__c != 'Light Green' && !nonStpReasons.contains(System.Label.Other_than_DG_LG_riskband)) {
                        isNonStp = true;
                        nonStpReasons.add(System.Label.Other_than_DG_LG_riskband);
                    }
                    if (!a.Check_Eligibility_Match__c || a.Run_Emi_Executed__c == 'No') {
                        isNonStp = true;
                    }

                    if (a.Current_Address_Not_Present__c) {
                        isNonStp = true;
                        nonStpReasons.add(System.Label.Present_addr_not_on_KYC);
                    }
                    /*if (a.In_Active_Applicant__c) {
isNonStp = true;
}*/
                    if (a.Bureau_Pull_Match__c == false || a.Bureau_Pull_Message__c != 'Success') {
                        isNonStp = true;
                        nonStpReasons.add(System.Label.Bureau_report_not_available);
                    }
                    newt.add(a.id);
                }
                
                Income_details__c[] incomes = [SELECT Id, Name, Document_uploaded_to_Perfios__c,Income_Source_Status__c, Applicant__c, 
                                               Primary_Income_Source__c,Perfios_Transaction_Id__c FROM Income_details__c WHERE Applicant__c IN: newt AND Applicant__r.Opportunity__r.Product_Type__c =: System.Label.PassengerVehicles WITH SECURITY_ENFORCED];
                List<Id> incomeId  = new List<Id> ();                             
                for (Income_details__c ic: incomes) {
                    if (ic.Income_Source_Status__c != 'NIP' && ic.Primary_Income_Source__c){
                        incomeId.add(ic.Id);

                    }
                    if (ic.Primary_Income_Source__c && ic.Income_Source_Status__c == 'NIP') {
                        isNonStp = true;
                        nonStpReasons.add(System.Label.NIP_customer);
                    }
                    if (ic.Primary_Income_Source__c && (ic.Income_Source_Status__c == 'SEP-Not Verified' || ic.Income_Source_Status__c == 'NIP') ) {
                            if(!nonStpReasons.contains(System.Label.NIP_customer)){
                                isNonStp = true;
                                nonStpReasons.add(System.Label.NIP_customer);
                            }
                        }

                         /*if(ic.Perfios_Transaction_Id__c==null || String.isBlank(ic.Perfios_Transaction_Id__c)){
                           // isNonStp = true;
                            //nonStpReasons.add(System.Label.Perfios_output_NA); 
                            system.debug('here '+incomeId);
                        }*/

                }
                if(!incomeId.isEmpty()){
                    List<Id> conIncomeId  = new List<Id> ();  
                    for(ContentDocumentLink cd :[Select ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId IN :incomeId] ){
                        conIncomeId.add(cd.LinkedEntityId);
                        system.debug('conIncomeId '+conIncomeId);
                    }
                    if(!conIncomeId.isEmpty()){
                        for (Id icId:  incomeId) {
                            if(!conIncomeId.contains(icId) && !nonStpReasons.contains(System.Label.Perfios_output_NA)){
                                isNonStp = true;
                                nonStpReasons.add(System.Label.Perfios_output_NA);
                            }
                        }
                    }else if(!nonStpReasons.contains(System.Label.Perfios_output_NA)){
                        isNonStp = true;
                        nonStpReasons.add(System.Label.Perfios_output_NA);
                    }
                }

               
                
                Customer_Dedupe_Response__c[] cusDep = [SELECT Id, SF_Cust_Dedupe__c, Customer_Status_Flag__c,External_Dedupe_Status__c, 
                                                        PG_Cust_Dedupe__c, Is_Journey_Skipped__c FROM Customer_Dedupe_Response__c 
                                                        WHERE Applicant__c IN: newt WITH SECURITY_ENFORCED];
                
                for (Customer_Dedupe_Response__c cus: cusDep) {
                    if (cus.SF_Cust_Dedupe__c == null && cus.PG_Cust_Dedupe__c == null && cus.Is_Journey_Skipped__c == false) {
                        isNonStp = true;
                    }
                    
                    if (cus.External_Dedupe_Status__c == 'P') {
                        isNonStp = true;
                    }
                    if(cus.Customer_Status_Flag__c=='F'){
                        isNonStp = true;
                        nonStpReasons.add(System.Label.F_K_Flag_presence);
                    }
                }
                
                Map<String,String> failService = new Map<String,String>();
                Map<String,String> latestServicesMap = new Map<String,String>();
                
                List<String> serviceName = new List<String>();
                serviceName.add('CSR Vahan FI Waiver');
                serviceName.add('BREscorecardAPI');
                serviceName.add('Offer Engine');
                serviceName.add('Pricing Engine');
                serviceName.add('LTV Engine');
                serviceName.add('Fico Deviations'); 
                if(opp.Product_Type__c == System.Label.PassengerVehicles){
                    serviceName.add('Run EMI Engine');   
                }
               
                
                
                for(Integration_Log__c intl :Utilities.getIntegrationLog(serviceName,opportunityId )){
                    if(!latestServicesMap.containsKey(intl.Service_Name__c)){
                        System.debug('lstIntLog'+intl);
                        //failService.put(intl.Service_Name__c,intl.Status__c);
                        latestServicesMap.put(intl.Service_Name__c,intl.Status__c);
                        System.debug('failService'+failService);
                    }
                    //Checking Fico deviation detected
                    if(intl.Service_Name__c =='Fico Deviations' && intl.Status__c == 'Success' ){
                        string  orgResp = intl.Original_response__c;
                        if(!string.isBlank(orgResp) && orgResp.contains('DeviationId')){						
                            isNonStp = true;
                            nonStpReasons.add('Deviations detected');
                            
                        }
                    }
                }
                
                for(String serName :latestServicesMap.keySet()){
                    if(latestServicesMap.get(serName) == 'Failure'){
                        System.debug('lstIntLog'+serName);
                        failService.put(serName,latestServicesMap.get(serName));
                        System.debug('failService'+failService);
                    }
                }
                
                //Service from list which is not hit 
                for(string svcName: serviceName){            
                    if(!latestServicesMap.containsKey(svcName)){
                        System.debug('Inside 2nd if no present');
                        failService.put(svcName,'Not Hit');
                        System.debug('failService'+failService);
                    }
                }
                
                if(!failService.isEmpty()){
                    isNonStp=true;
                    for(String failSvc :failService.keyset()){
                        nonStpReasons.add(failSvc + ' '+ System.Label.Engine_failure);
                    }
                }
                
                Integer count =0;
                Opportunity oppRecord=[SELECT (SELECT ID,In_Active_Applicant__c FROM Applicants__r 
                                               WHERE Applicant_Type__c =: System.Label.CoBorrower) 
                                       FROM Opportunity WHERE Id =:opportunityId WITH SECURITY_ENFORCED];
                
                system.debug('oppRecord==>'+oppRecord.Applicants__r);
                for(Applicant__c applicant : oppRecord.Applicants__r){
                    system.debug('oppRecord.Applicants__r.In_Active_Applicant__c==>'+applicant.In_Active_Applicant__c);
                    if(applicant.In_Active_Applicant__c==true){
                        count++;
                    }
                }
                
                if(count > 0){
                    system.debug('inside if'+count);
                    isNonStp = true;
                    nonStpReasons.add(System.Label.CB_rejected_1);
                }
                
                if (isNonStp) {
                    opp.Sanction_Status__c = 'Non-STP';
                    for(String res:nonStpReasons){
                        if(opp.STP_Failure_Reasons__c	== null){
                            opp.STP_Failure_Reasons__c	= res;
                        }else{
                            opp.STP_Failure_Reasons__c	+= ', ' + res; 
                        }
                    }
                    System.debug('opp.STP_Failure_Reasons__c==>  '+opp.STP_Failure_Reasons__c);
                    if (Schema.sObjectType.Opportunity.isUpdateable()) {
                        update opp;
                    }
                } else {
                    opp.Sanction_Status__c = 'STP';
                    if (Schema.sObjectType.Opportunity.isUpdateable()) {
                        update opp;
                    }
                }
                
            }
            //Catch block 
        } catch (Exception e) {
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('IND_LWC_StpChecksCntrl', 'stpChecks', System.Label.Apex, e);
            System.debug('Exception  '+e + 'Line '+ e.getLineNumber());
            
            if (Schema.sObjectType.Error_Log__c.isCreateable()) {
                insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    @AuraEnabled
    public static void stpVerify(String opportunityId) {
        try {
            Opportunity opp = [SELECT Id, Product_Type__c, Sanction_Status__c, Vehicle_Sub_Category__c, Loan_amount__c, Vehicle_Type__c,
                               Ex_showroom_price_carwale__c, Total_Funded_premium_amount__c, On_Road_price_carwale__c, Total_Funded_Premium__c,
                               Ex_showroom_price__c, On_Road_price__c, STP_Failure_Reasons__c FROM Opportunity WHERE Id =: opportunityId WITH SECURITY_ENFORCED];
            
            opp.Sanction_Status__c = 'Non-STP';
            opp.STP_Failure_Reasons__c	= 'Deviations detected';
            update opp;
            //Catch block 
        } catch (Exception e) {
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('IND_LWC_StpChecksCntrl', 'stpChecks', System.Label.Apex, e);
            if (Schema.sObjectType.Error_Log__c.isCreateable()) {
                insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
}