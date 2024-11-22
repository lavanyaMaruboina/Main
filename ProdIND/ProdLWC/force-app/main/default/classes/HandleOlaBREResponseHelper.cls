public with sharing class HandleOlaBREResponseHelper extends TriggerHandler {

    List<Ola_BRE_Response_Payload__e> newBREResponseList;
    List<Opportunity> oppList;
    List<Applicant__c> appList;
    List<Final_Term__c> finalTermList;

    public HandleOlaBREResponseHelper() {
        newBREResponseList = (List<Ola_BRE_Response_Payload__e>)Trigger.new;
        oppList = new List<Opportunity>();
        appList = new List<Applicant__c>();
        finalTermList = new List<Final_Term__c>();
    }

    public override void afterInsert() {
        //getting list of application number from platfor event.
        Set<String> applicationNoList = new Set<String>();
        for(Ola_BRE_Response_Payload__e evt : newBREResponseList){
            applicationNoList.add(evt.Loan_Application_Number__c);
        }

        Map<String, Opportunity> oppMap = new Map<String, Opportunity>();
        for(Opportunity tempOpp :[SELECT id, Lead_number__c, On_Road_price__c, (SELECT id FROM Applicants__r LIMIT 1), (SELECT id FROM Final_Terms__r LIMIT 1) FROM Opportunity WHERE Lead_number__c =:applicationNoList]){
            oppMap.put(tempOpp.Lead_number__c, tempOpp);
        }

        try{
            for(Ola_BRE_Response_Payload__e event : newBREResponseList){
                Opportunity opp = new Opportunity();
                Applicant__c app = new Applicant__c();
                Final_Term__c finalTerm = new Final_Term__c();
                Map<String, Object> resp = (Map<String, Object>) JSON.deserializeUntyped(event.BRE_Payload__c);
                String encryptedResp = (String) resp.get('JData');
                String decryptedResp = IntegrationUtilities.getDecryptedResponse(encryptedResp, System.Label.privateKey, System.Label.ivkey);
                Map<String, Object> payload = (Map<String, Object>)JSON.deserializeUntyped(decryptedResp);
                
                Map<String, Object> iBL_Gating_Response = (Map<String, Object>)payload.get('IBL_Gating_Response');
                Map<String, Object> gatingApplication = (Map<String, Object>)iBL_Gating_Response.get('application');
                Map<String, Object> gatingApplicationDecision = (Map<String, Object>)gatingApplication.get('applicationDecision');
                String gatingScreeningOutcome = (String)gatingApplicationDecision.get('gatingScreeningOutcome');
                String finalDisplayReason = (String)gatingApplicationDecision.get('finalDisplayReason');
                
                Map<String, Object> lTV_Engine_Response = (Map<String, Object>)payload.get('LTV_Engine_Response');
                Map<String, Object> ltvApplication = (Map<String, Object>)lTV_Engine_Response.get('application');
                Map<String, Object> ltvApplicationDecision = (Map<String, Object>)gatingApplication.get('applicationDecision');
                String ltv = (String)gatingApplicationDecision.get('ltv');

                Map<String, Object> offer_Engine_Response = (Map<String, Object>)payload.get('Offer_Engine_Response');
                Map<String, Object> offerApplication = (Map<String, Object>)offer_Engine_Response.get('application');
                Map<String, Object> offerEngineDetails = (Map<String, Object>)offerApplication.get('offerEngineDetails');
                Map<String, Object> offerEngineDecision = (Map<String, Object>)offerEngineDetails.get('offerEngineDecision');
                String minDownPaymentAmt = (String)offerEngineDecision.get('minDownPaymentAmt');
                String maxDownPaymentAmt = (String)offerEngineDecision.get('maxDownPaymentAmt');

                Map<String, Object> pricing_Response = (Map<String, Object>)payload.get('Pricing_Response');
                Map<String, Object> pricingApplication = (Map<String, Object>)pricing_Response.get('application');
                Map<String, Object> pricingApplicationDecision = (Map<String, Object>)pricingApplication.get('applicationDecision');
                String prescribedRate = (String)pricingApplicationDecision.get('prescribedRate');
                

                Map<String, Object> scorecard_Response = (Map<String, Object>)payload.get('Scorecard_Response');
                Map<String, Object> scorecardApplication = (Map<String, Object>)scorecard_Response.get('application');
                List<Object> scorecardApplicantDetails = (List<Object>)scorecardApplication.get('applicantDetails');
                Map<String, Object> scorecardApplicantDetails0 = (Map<String, Object>)scorecardApplicantDetails.get(0);
                Map<String, Object> scorecardApplicantDecision = (Map<String, Object>)scorecardApplicantDetails0.get('applicantDecision');
                String riskBand = (String)scorecardApplicantDecision.get('riskBand');

                //bREscoreCardResponse mapping
                app.Id = oppMap.get(event.Loan_Application_Number__c).Applicants__r[0].id;
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

                //gatingScreeningResponse mapping
                app.Check_Eligibility_Match__c = (gatingScreeningOutcome == System.label.Journey_stop) ? false : true;
                app.Check_Eligibility_Message__c = gatingScreeningOutcome;
                app.Check_Eligibility_Final_Reason__c = finalDisplayReason;

                //offerEngineResponse mapping
                finalTerm.Id=oppMap.get(event.Loan_Application_Number__c).Final_Terms__r[0].id;
                finalTerm.OfferengineMaxTenure__c=36;
                finalTerm.OfferengineMinTenure__c=12;
                if(oppMap.get(event.Loan_Application_Number__c).On_Road_price__c != null){
                    finalTerm.OfferengineMinLoanAmount__c=oppMap.get(event.Loan_Application_Number__c).On_Road_price__c - Decimal.ValueOf(maxDownPaymentAmt);
                    finalTerm.OfferengineMaxLoanAmount__c=oppMap.get(event.Loan_Application_Number__c).On_Road_price__c - Decimal.ValueOf(minDownPaymentAmt);
                }
                /* finalTerm.Inputted_IRR__c=;
                finalTerm.Net_IRR__c=;
                finalTerm.Gross_IRR__c=; */

                //lTVEngineResponse mapping
                if(ltv!=null){
                    finalTerm.LtvEngine_Ltv__c=Decimal.ValueOf(ltv);
                }

                //pricingEngineRespons mapping
                finalTerm.PricingEngine_thresholdNetrr__c=Decimal.ValueOf(prescribedRate);

                appList.add(app);
                oppList.add(opp);
                finalTermList.add(finalTerm);
            }

            update appList;
            update oppList;
            update finalTermList;
        } catch(Exception e){}
    }
}