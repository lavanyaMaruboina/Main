public with sharing class HandleOlaFicoResponseEvent {
    public static void olaFicoResponseEventHandler(List<Low_Payload_Response__e> newLowPayloadResponseList){
        Applicant__c app = new Applicant__c();
        Final_Term__c finalTerm = new Final_Term__c();

        Set<String> oppIdList = new Set<String>();
        for(Low_Payload_Response__e evt : newLowPayloadResponseList){
            String oppId = evt.Reference_Id__c.replace('offer_engine','');
            oppId = oppId.replace('gating_Screening','');
            oppId = oppId.replace('ltv_engine','');
            oppId = oppId.replace('pricing_engine','');
            oppId = oppId.replace('ScoreCard','');
            oppIdList.add(oppId);
        }

        Map<String, Opportunity> oppMap = new Map<String, Opportunity>();
        List<Opportunity> InsertOpplist = [SELECT id, Lead_number__c, On_Road_price__c,LeadSource, (SELECT id FROM Applicants__r LIMIT 1), (SELECT id FROM Final_Terms__r LIMIT 1) FROM Opportunity WHERE id IN :oppIdList];
        for(Opportunity tempOpp : InsertOpplist){
            oppMap.put(tempOpp.id, tempOpp);
        }

        try{
            for(Low_Payload_Response__e event : newLowPayloadResponseList){
                String oppId = event.Reference_Id__c.replace('offer_engine','');
                oppId = oppId.replace('gating_Screening','');
                oppId = oppId.replace('ltv_engine','');
                oppId = oppId.replace('pricing_engine','');
                oppId = oppId.replace('ScoreCard','');

                if(oppMap.get(oppId)!=null){
                    app.id= oppMap.get(oppId).Applicants__r[0].id;
                    finalTerm.Id=oppMap.get(oppId).Final_Terms__r[0].id;
                }

                if(event.SVC_Name__c=='FICO Response'){
                    Map<String, Object> resp = (Map<String, Object>) JSON.deserializeUntyped(event.Response__c);
                    String encryptedResp = (String) resp.get('JData');
                    String decryptedResp = IntegrationUtilities.getDecryptedResponse(encryptedResp, System.Label.privateKey, System.Label.ivkey);
                    Map<String, Object> payload = (Map<String, Object>)JSON.deserializeUntyped(decryptedResp);
                    String refrenceId = event.Reference_Id__c;
                    
                    if(refrenceId.contains('gating_Screening')){
                        //gatingScreeningResponse mapping
                        Map<String, Object> iBL_Gating_Response = payload;
                        Map<String, Object> gatingApplication = (Map<String, Object>)iBL_Gating_Response.get('application');
                        Map<String, Object> gatingApplicationDecision = (Map<String, Object>)gatingApplication.get('applicationDecision');
                        String gatingScreeningOutcome = (String)gatingApplicationDecision.get('gatingScreeningOutcome');
                        String finalDisplayReason = (String)gatingApplicationDecision.get('finalDisplayReason');

                        
                        app.Check_Eligibility_Match__c = (gatingScreeningOutcome == System.label.Journey_stop) ? false : true;
                        app.Check_Eligibility_Message__c = gatingScreeningOutcome;
                        app.Check_Eligibility_Final_Reason__c = finalDisplayReason;
                    } else if(refrenceId.contains('ltv_engine')){
                        //lTVEngineResponse mapping
                        Map<String, Object> lTV_Engine_Response = payload;
                        Map<String, Object> ltvApplication = (Map<String, Object>)lTV_Engine_Response.get('application');
                        Map<String, Object> ltvApplicationDecision = (Map<String, Object>)ltvApplication.get('applicationDecision');
                        Decimal ltv = (Decimal)ltvApplicationDecision.get('ltv');

                        if(ltv!=null){
                            finalTerm.LtvEngine_Ltv__c=ltv;
                        }
                    } else if(refrenceId.contains('offer_engine')){
                        //offerEngineResponse mapping
                        Map<String, Object> offer_Engine_Response = payload;
                        Map<String, Object> offerApplication = (Map<String, Object>)offer_Engine_Response.get('application');
                        Map<String, Object> offerassetDetails = (Map<String, Object>)offerApplication.get('assetDetails');//CISH-77
                        Map<String, Object> offerEngineDetails = (Map<String, Object>)offerApplication.get('offerEngineDetails');
                        Map<String, Object> offerEngineDecision = (Map<String, Object>)offerEngineDetails.get('offerEngineDecision');
                        Map<String, Object> payouts = (Map<String, Object>)offerEngineDetails.get('payouts');
                        Decimal provisionCost = (Decimal)payouts.get('provisionCost');
                        Decimal mfrIncentiveAmt = (Decimal)payouts.get('mfrIncentiveAmt');
                        Decimal minDownPaymentAmt = (Decimal)offerEngineDecision.get('minDownPaymentAmt');
                        Decimal maxDownPaymentAmt = (Decimal)offerEngineDecision.get('maxDownPaymentAmt');
                         //Hero Change CISH-01
                         Decimal minLoanAmtSlider = (Decimal)offerEngineDecision.get('minLoanAmtSlider');
                         Decimal maxLoanAmtSlider = (Decimal)offerEngineDecision.get('maxLoanAmtSlider');
                         Decimal minTenureSlider = (Decimal)offerEngineDecision.get('minTenureSlider');
                         Decimal maxTenureSlider = (Decimal)offerEngineDecision.get('maxTenureSlider');
                         Decimal netIrr = (Decimal)offerEngineDecision.get('netIrr');
                         Decimal displayImputedIrr = (Decimal)offerEngineDecision.get('displayImputedIrr');
                         Decimal grossIrr = (Decimal)offerEngineDecision.get('grossIrr');
                         Decimal bankCrmIrr = (Decimal)offerEngineDecision.get('bankCrmIrr');
                         //Hero Change CISH-01
                         System.debug('Asset Details - onroad price'+(Decimal)offerassetDetails.get('onroadPrice'));
                         Decimal onRoadprice = (Decimal)offerassetDetails.get('onroadPrice');//CISH-77
                          System.debug('Asset - onRoadprice---->'+onRoadprice);
                         if(InsertOpplist[0].LeadSource == 'Hero'){//Hero Change CISH-01
                             finalTerm.OfferengineMaxTenure__c = maxTenureSlider != null ? maxTenureSlider : null;
                             finalTerm.OfferengineMinTenure__c = minTenureSlider != null ? minTenureSlider : null;
                             finalTerm.OfferengineMinLoanAmount__c = minLoanAmtSlider != null ? minLoanAmtSlider : null;
                             finalTerm.OfferengineMaxLoanAmount__c = maxLoanAmtSlider != null ? maxLoanAmtSlider : null;
                             finalTerm.Gross_IRR__c = grossIrr != null ? grossIrr : null;
                             finalTerm.Net_IRR__c = netIrr != null ? netIrr : null;
                             finalTerm.Inputted_IRR__c = displayImputedIrr != null ? displayImputedIrr : null;
                             finalTerm.Bank_IRR__c = bankCrmIrr != null ? String.ValueOf(bankCrmIrr) : null;
                             finalTerm.Provisional_Channel_Cost__c = provisionCost != null ? String.ValueOf(provisionCost) : '';
                             finalTerm.Mfr_incentive__c = mfrIncentiveAmt != null ? String.ValueOf(mfrIncentiveAmt) : '';
                             finalTerm.Offerengine_On_Road_Price__c = onRoadprice != null ? onRoadprice : null;//CISH-77
                         System.debug('Hero onroad price'+finalTerm.Offerengine_On_Road_Price__c);
                         }else{//Hero Change CISH-01
                        finalTerm.OfferengineMaxTenure__c=36;
                        finalTerm.OfferengineMinTenure__c=12;
                        System.debug('onroadprice from Asset'+onRoadprice);
                        finalTerm.Offerengine_On_Road_Price__c = onRoadprice != null ? onRoadprice : null;//CISH-77
                         System.debug('Final Term On Road Price'+finalTerm.Offerengine_On_Road_Price__c);
                        if(oppMap.get(event.Reference_Id__c.replace('offer_engine','')).On_Road_price__c != null && minDownPaymentAmt != null && maxDownPaymentAmt != null){
                            finalTerm.OfferengineMinLoanAmount__c=oppMap.get(event.Reference_Id__c.replace('offer_engine','')).On_Road_price__c - maxDownPaymentAmt;
                            finalTerm.OfferengineMaxLoanAmount__c=oppMap.get(event.Reference_Id__c.replace('offer_engine','')).On_Road_price__c - minDownPaymentAmt;
                        }
                    }
                        /* finalTerm.Inputted_IRR__c=;
                        finalTerm.Net_IRR__c=;
                        finalTerm.Gross_IRR__c=; */
                    } else if(refrenceId.contains('pricing_engine')){
                        //pricingEngineRespons mapping
                        Map<String, Object> pricing_Response = payload;
                        Map<String, Object> pricingApplication = (Map<String, Object>)pricing_Response.get('application');
                        Map<String, Object> pricingApplicationDecision = (Map<String, Object>)pricingApplication.get('applicationDecision');
                        String prescribedRate = (String)pricingApplicationDecision.get('prescribedRate');
                        
                        finalTerm.PricingEngine_thresholdNetrr__c=Decimal.ValueOf(prescribedRate);
                    } else if(refrenceId.contains('ScoreCard')){
                        //bREscoreCardResponse mapping
                        Map<String, Object> scorecard_Response = payload;
                        Map<String, Object> scorecardApplication = (Map<String, Object>)scorecard_Response.get('application');
                        List<Object> scorecardApplicantDetails = (List<Object>)scorecardApplication.get('applicantDetails');
                        Map<String, Object> scorecardApplicantDetails0 = (Map<String, Object>)scorecardApplicantDetails.get(0);
                        Map<String, Object> scorecardApplicantDecision = (Map<String, Object>)scorecardApplicantDetails0.get('applicantDecision');
                        String riskBand = (String)scorecardApplicantDecision.get('riskBand');

                        switch on riskBand {
                            when '01' {		
                                app.ScoreCard_Description__c = 'The customer has an in-principle vehicle loan offer from IndusInd bank. Please proceed to collect all required details to help create the best offer';
                                app.Scorecard_Decision__c = 'Dark Green';
                            }	
                            when '02' {		
                                app.ScoreCard_Description__c = 'The customer has an in-principle vehicle loan offer from IndusInd bank. Please proceed to collect all required details to help create the best offer';
                                app.Scorecard_Decision__c = 'Light Green';
                            }
                            when '03' {		
                                app.ScoreCard_Description__c = 'The customer\'s vehicle loan application is Under Review. Please proceed to collect all required details to help create the best offer';
                                app.Scorecard_Decision__c = 'Yellow';
                            }
                            when '04' {		
                                app.ScoreCard_Description__c = 'The customer\'s vehicle loan application is Under Review. Please proceed to collect all required details to help create the best offer';
                                app.Scorecard_Decision__c = 'Orange';
                            }
                            when '05' {		
                                app.ScoreCard_Description__c = 'Journey stops';
                                app.Scorecard_Decision__c = 'Red';
                            }
                            when else {		  // default block, optional
                                app.ScoreCard_Description__c = '';
                                app.Scorecard_Decision__c = '';
                            }
                        }
                    }
                }
            }
            if(app.id!=null){update app;}
            if(finalTerm.id!=null){update finalTerm;
            System.debug('finalTerm Updating from Platform Events'+finalTerm);}
            
        } catch(Exception e){
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('HandleOlaFicoResponseEvent', ' olaFicoResponseEventHandler ', System.Label.Apex, e);
            insert errorLogRecord;
        }
    }
}