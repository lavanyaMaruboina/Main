/* eslint-disable no-unused-vars */ 
import { LightningElement, track, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { updateRecord, createRecord } from "lightning/uiRecordApi";
import doGatingScreeningCheckEligibilityCallout from "@salesforce/apexContinuation/DSA_IntegrationEngine.doGatingScreeningCheckEligibilityCallout";
import checkRetryExhausted from "@salesforce/apex/LwcLOSGattingAndScreeningCntrl.checkRetryExhausted";
import doCIBILReportCallout from "@salesforce/apexContinuation/DSA_IntegrationEngine.doCIBILReportCallout";
import doBREscorecardCallout from "@salesforce/apexContinuation/DSA_IntegrationEngine.doBREscoreCardCallout";
import doPricingEngineCallout from "@salesforce/apexContinuation/DSA_IntegrationEngine.doPricingEngineCallout";
import doRunEmiEngineCallout from "@salesforce/apexContinuation/IntegrationEngine.doRunEmiEngineCallout";
import doLTVEngineCallout from "@salesforce/apexContinuation/DSA_IntegrationEngine.doLTVEngineCallout";
import doDSAOfferEngineCallout from "@salesforce/apexContinuation/DSA_IntegrationEngine.doDSAOfferEngineCallout";
import createFinalTermRecord from "@salesforce/apex/FinalTermscontroller.createFinalTermRecord";
import saveEMIDetails from "@salesforce/apex/Ind_ExistingEMICtrl.saveEMIDetails1";
import getApplicants from "@salesforce/apex/IND_DSAController.getApplicantDetails";

import APP_ID_FIELD from "@salesforce/schema/Applicant__c.Id";
import Check_Eligibility_Match__c from "@salesforce/schema/Applicant__c.Check_Eligibility_Match__c";
import Check_Eligibility_Message__c from "@salesforce/schema/Applicant__c.Check_Eligibility_Message__c";
import CIBIL_MAKER_DATE from "@salesforce/schema/CIBIL_Details__c.Maker_Date__c";
import CIBIL_RECORD_DETAILS_ID from "@salesforce/schema/CIBIL_Details__c.Id";
import AMOUNT_OVERDUE_FIELD from "@salesforce/schema/CIBIL_Details__c.Amount_Overdue__c";
import CIBIL_APPLICANT_FIELD from "@salesforce/schema/CIBIL_Details__c.Applicant__c";
import CIBIL_DECISION_FIELD from "@salesforce/schema/CIBIL_Details__c.Cibil_Decision__c";
import CIBIL_REPORT_URI_FIELD from "@salesforce/schema/CIBIL_Details__c.CIBIL_Report_URl__c";
import CIC_NO_FIELD from "@salesforce/schema/CIBIL_Details__c.CIC_No__c";
import CRIF_SCORE_DESC_FIELD from "@salesforce/schema/CIBIL_Details__c.CRIF_Score_Desc__c";
import CURRENT_BALANCE_FIELD from "@salesforce/schema/CIBIL_Details__c.Current_Balance__c";
import ENTITY_FIELD from "@salesforce/schema/CIBIL_Details__c.Entity_Type__c";
import EQUIFAX_REPORT_URL_FIELD from "@salesforce/schema/CIBIL_Details__c.Equifax_Report_URl__c";
import HIGHCREDIT_OR_SANCTIONEDAMOUNT_FIELD from "@salesforce/schema/CIBIL_Details__c.HighCredit_Or_SanctionedAmount__c";
import MONTH_OVERDUE_FIELD from "@salesforce/schema/CIBIL_Details__c.Month_Overdue__c";
import NOOFENLTSIXMON_FIELD from "@salesforce/schema/CIBIL_Details__c.NoOfEnLtSixMon__c";
import OLDEST_DATE_FIELD from "@salesforce/schema/CIBIL_Details__c.Oldest_Date__c";
import RECENT_DATE_FIELD from "@salesforce/schema/CIBIL_Details__c.Recent_Date__c";
import SCORE_FIELD from "@salesforce/schema/CIBIL_Details__c.Score__c";
import SUITFILEDORWILFULDEFAULT_FIELD from "@salesforce/schema/CIBIL_Details__c.SuitFiledOrWilfulDefault__c";
import TYPE_FIELD from "@salesforce/schema/CIBIL_Details__c.Type__c";
import WRITTENOFFAMOUNTTOTAL_FIELD from "@salesforce/schema/CIBIL_Details__c.WrittenoffAmountTotal__c";
import CIBIL_DETAILS_OBJECT from "@salesforce/schema/CIBIL_Details__c";
import final_ID_FIELD from "@salesforce/schema/Final_Term__c.Id";
import LtvEngine_Ltv from "@salesforce/schema/Final_Term__c.LtvEngine_Ltv__c";
import Loan_Amount__c from "@salesforce/schema/Final_Term__c.Loan_Amount__c";
import Tenure__c from "@salesforce/schema/Final_Term__c.Tenure__c";
import CRM_IRR__c from "@salesforce/schema/Final_Term__c.CRM_IRR__c";
import EMI_Amount__c from "@salesforce/schema/Final_Term__c.EMI_Amount__c";
import Bureau_Pull_Match__c from "@salesforce/schema/Applicant__c.Bureau_Pull_Match__c";
import Bureau_Pull_Message__c from "@salesforce/schema/Applicant__c.Bureau_Pull_Message__c";
import PricingEngine_thresholdNetrr from "@salesforce/schema/Final_Term__c.PricingEngine_thresholdNetrr__c";
import is_Active__c from "@salesforce/schema/Final_Term__c.is_Active__c";
import Journey_stop from "@salesforce/label/c.Journey_stop";
import Journey_Stop_message from "@salesforce/label/c.Journey_Stop_message";
import Add_Coborrower from "@salesforce/label/c.Add_Coborrower";
import ChangeCoborrower from "@salesforce/label/c.ChangeCoborrower";
import ContWithJourney from "@salesforce/label/c.ContWithJourney";
import CoborrowerNotReq from "@salesforce/label/c.CoborrowerNotReq";
import SuccessMessage from "@salesforce/label/c.SuccessMessage";
import Retry_Exhausted from "@salesforce/label/c.Retry_Exhausted";
import Journey_Continues from "@salesforce/label/c.Journey_Continues";
import FailureMessage from "@salesforce/label/c.FailureMessage";

export default class Dsa_BRE_engines extends LightningElement {
    @track spinnerText = "Please wait, System is processing the data.";
    @track checkEligFlag = false;
    @track checkEligibilityMessage = "";
    @track cibilDetailsRecordId;
    @track makerDateConversion;
    @track bureauPullFlag;
    @track bureauPullMessage;
    @track finalTermId;
    @track showEMIDetails;
    @track loanRecordsArray=[];
    @track countForScreening = 0;
    boolCIBILVorrower=true;
    boolDisableCoborrowerOffer=false;
     applicantsforCibil;
    @track dataWrapper = {
        disableCheckEligibilityButton: false,
        journeyStopPopUp: false,
        coborrowerPopup: false,
        count: this.countForScreening,
        api:'Gating'
    };
    @track pricingEnginethresholdNetIrrValue;
    @track thresholdNetIRR;
    @track existingEMIList;
    cibilResult = false;
    showSpinner = false;
    applicantId;
    loanId;
    ltvEngineValue;
    boolOfferPage=false;
    label = {
        Journey_stop,
        CoborrowerNotReq,
        ContWithJourney,
        Add_Coborrower,
        SuccessMessage,
        Retry_Exhausted,
        FailureMessage,
        Journey_Stop_message,
        Journey_Continues,
        ChangeCoborrower
    };
    @api
    handleCheckEligibility(applicant, loan, boolCibil) {
        this.boolCIBILVorrower=boolCibil;
        this.showSpinner = true;
        this.countForScreening = ++this.countForScreening;
        this.applicantId = applicant;
        this.loanId = loan;
        this.callBREEngines();
    }


    async callBREEngines() {
       this.applicantsforCibil= await getApplicants({loanId: this.loanId});
       if(this.applicantsforCibil.length >0 && this.applicantsforCibil[0].Opportunity__r.DSA_Stage__c !=='Offer')
       {
        this.boolDisableCoborrowerOffer=true;
       }
       else if(this.applicantsforCibil.length >0 && this.applicantsforCibil[0].Opportunity__r.DSA_Stage__c ==='Offer' && this.countForScreening>=3){
        this.boolDisableCoborrowerOffer=true;
       }
       else{
        this.boolDisableCoborrowerOffer=false;
       }

      // this.boolDisableCoborrowerOffer = this.applicantsforCibil.length >0 ? true:false;
        let retryResponse = await this.checkRetryExhaustedCount();
            await this.checkCIVILAPI();
            if(this.boolCIBILVorrower){
                await  this.checkCIVILAPIBorrower();

            }
            await this.callCheckEligibilityAPI();
            if (this.checkEligFlag) {
                await this.checkScoreCardAPI();
                await this.callLTVEngine();
                await this.executePricingCallout();
                await this.executeEMIEngine();
                await this.executeOfferEngine();
            }
    }

    //function to check retry limit
    async checkRetryExhaustedCount() {
        this.showSpinner = true;
        //checking retry limit
        await checkRetryExhausted({
            loanApplicationId: this.loanId,
            attemptFor: "Check Eligibility Attempts",
            applicantId: this.applicantId,
            moduleName: "Gatting & Screening"
        })
            .then((response) => {
                this.showSpinner = false;
            })
            .catch((error) => {
                this.showSpinner = false;
                const evt = new ShowToastEvent({
                    title: "Error",
                    message: error.body.message,
                    variant: "error"
                });
                this.dispatchEvent(evt);
            });
    }

    saveCheckEligibilityResponse(message, flag) {
        const applicantsFields = {};
        applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
        applicantsFields[Check_Eligibility_Match__c.fieldApiName] = flag;
        applicantsFields[Check_Eligibility_Message__c.fieldApiName] = message;
        this.updateRecordDetails(applicantsFields);
    }

    async updateRecordDetails(fields) {
        const recordInput = { fields };
        await updateRecord(recordInput)
            .then(() => {
                console.log("record update success", JSON.stringify(fields)); //keeping for reference
            })
            .catch((error) => {
                console.log("error in record update =>",JSON.stringify(error));
                this.tryCatchError = error;
                // this.errorInCatch();
            });
    }

    async createRecordDetails(objectApiName, fields) {
        await createRecord({ apiName: objectApiName, fields: fields })
            .then((obj) => {
                console.log(
                    "record created successfully",
                    JSON.stringify(fields)
                );
                this.cibilDetailsRecordId = obj.id;
            })
            .catch((error) => {
                console.log("error in record creation ", error);
            });
    }

    //CIVIL API START
    async checkCIVILAPI() {
        let cibilRequest;
        this.showSpinner = true;
        if(this.applicantsforCibil.length >0 && typeof this.applicantsforCibil !== 'undefined'){    
         cibilRequest = {
            applicantId: this.applicantsforCibil[0].Id,
            loanApplicationId: this.loanId
        };
        return doCIBILReportCallout({
            cibilRequestString: JSON.stringify(cibilRequest)
        })
            .then((res) => {
                return this.CIBILProcessing(res,this.applicantsforCibil[0].Id);
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log("Bureau Pull API Error is :==>", error);
                this.bureauPullFlag = false;
                this.bureauPullMessage = error.body.message;
                const evt = new ShowToastEvent({
                    title: "Error",
                    message: error.body.message,
                    variant: "error"
                });
                this.dispatchEvent(evt);
                const applicantsFields = {};
                applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantsforCibil[0].Id;
                //Added below as part of Bug id 1424 by Sathyanarayana Somayajula
                applicantsFields[Bureau_Pull_Match__c.fieldApiName] =
                    this.bureauPullFlag;
                applicantsFields[Bureau_Pull_Message__c.fieldApiName] =
                    this.bureauPullMessage;
                return this.updateRecordDetails(applicantsFields);
                //this.retrypopup = true;
            });
        }
    }
    async checkCIVILAPIBorrower() {
        this.boolCIBILVorrower=false;
        let cibilRequest;
        this.showSpinner = true;
        cibilRequest = {
            applicantId: this.applicantId,
            loanApplicationId: this.loanId
        };
        return doCIBILReportCallout({
            cibilRequestString: JSON.stringify(cibilRequest)
        })
            .then((res) => {
                return this.CIBILProcessing(res,this.applicantId);
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log("Bureau Pull API Error is :==>", error);
                this.bureauPullFlag = false;
                this.bureauPullMessage = error.body.message;
                const evt = new ShowToastEvent({
                    title: "Error",
                    message: error.body.message,
                    variant: "error"
                });
                this.dispatchEvent(evt);
                const applicantsFields = {};
                applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
                //Added below as part of Bug id 1424 by Sathyanarayana Somayajula
                applicantsFields[Bureau_Pull_Match__c.fieldApiName] =
                    this.bureauPullFlag;
                applicantsFields[Bureau_Pull_Message__c.fieldApiName] =
                    this.bureauPullMessage;
                return this.updateRecordDetails(applicantsFields);
                //this.retrypopup = true;
            });
    }
    //CIVIL API END

    async callCheckEligibilityAPI() {
        this.showSpinner = true;
        let checkEligRequest = {
            applicantId: this.applicantId,
            loanApplicationId: this.loanId,
            CountBRECall: this.countForScreening
        };
        await doGatingScreeningCheckEligibilityCallout({
            checkEligibilityString: JSON.stringify(checkEligRequest)
        })
            .then((result) => {
                const obj = JSON.parse(result);
                if (
                    obj.application.applicationDecision
                        .gatingScreeningOutcome === this.label.Journey_stop
                ) {
                    this.dataWrapper.journeyStopPopUp = true;
                    this.dataWrapper.disableCheckEligibilityButton = true;
                    this.dataWrapper.coborrowerPopup = false;
                    // this.checkEligibilityTick = true;
                    this.showSpinner = false;
                    this.dispatchEvent(
                        new CustomEvent("checkeligibility", {
                            detail: this.dataWrapper
                        })
                    );
                    this.checkEligFlag = false;
                    this.checkEligibilityMessage =
                        this.label.Journey_Stop_message;
                    this.saveCheckEligibilityResponse(
                        this.checkEligibilityMessage,
                        this.checkEligFlag
                    );
                } else if (
                    (obj.application.applicationDecision
                        .gatingScreeningOutcome === this.label.Add_Coborrower ||
                        obj.application.applicationDecision
                            .gatingScreeningOutcome ===
                            this.label.ChangeCoborrower) &&
                    this.countForScreening <= 3
                ) {
                    this.showSpinner = false;
                    this.dataWrapper.coborrowerPopup = true;
                    this.dataWrapper.count= this.countForScreening;
                    this.dispatchEvent(
                        new CustomEvent("checkeligibility", {
                            detail: this.dataWrapper
                        })
                    );
                    //this.coborrowerPopupMessage = obj.gatingScreeningOutcome;
                } else if (
                    obj.application.applicationDecision.gatingScreeningOutcome === this.label.Journey_Continues || obj.application.applicationDecision.gatingScreeningOutcome ==="Continue With latest Coborrower" ||(this.countForScreening > 3)
                ) {
                   // this.showSpinner = false;
                    // this.genrateApplicationNo();
                    //  this.disableCheckEligibilityButton = true;
                    // this.checkEligibilityTick = true;
                    this.checkEligFlag = true;
                    this.checkEligibilityMessage = this.label.Journey_Continues;
                    this.saveCheckEligibilityResponse(
                        this.checkEligibilityMessage,
                        this.checkEligFlag
                    );
                } else {
                    const evt = new ShowToastEvent({
                        title:
                            "Something went wrong, Please connect with admin with this message: " +
                            obj.application.applicationDecision
                                .gatingScreeningOutcome,
                        variant: "error"
                    });
                    // this.retrypopup = true;
                }
                this.showSpinner = false;
            })
            .catch((error) => {
                this.showSpinner = false;
                // this.retrypopup = true;
                if (error.body.message !== 'Unrecognized base64 character: "') {
                    const evt = new ShowToastEvent({
                        title: error.body.message,
                        variant: "error"
                    });
                    this.dispatchEvent(evt);
                }
            });
        //If response is true this code will run and show toast message
    }

    //used to process data after response
    async CIBILProcessing(res, applicantId) {
        const result = JSON.parse(res);

        const cibilFields = {};
        if (
            result.Data &&
            result.Data.StatusCode === "200" &&
            result.Data.Application_Cibil_Details.length
        ) {
            cibilFields[AMOUNT_OVERDUE_FIELD.fieldApiName] =
                result.Data.Application_Cibil_Details[0].Amount_Overdue;
            cibilFields[CIBIL_DECISION_FIELD.fieldApiName] =
                result.Data.Application_Cibil_Details[0].CibilDecision;
            cibilFields[CIC_NO_FIELD.fieldApiName] =
                result.Data.Application_Cibil_Details[0].CIC_No;
            cibilFields[CRIF_SCORE_DESC_FIELD.fieldApiName] =
                result.Data.Application_Cibil_Details[0].CRIFScore_Desc;
            cibilFields[CURRENT_BALANCE_FIELD.fieldApiName] =
                result.Data.Application_Cibil_Details[0].Current_Balance;
            cibilFields[ENTITY_FIELD.fieldApiName] =
                result.Data.Application_Cibil_Details[0].Entity_Type;
            cibilFields[HIGHCREDIT_OR_SANCTIONEDAMOUNT_FIELD.fieldApiName] =
                result.Data.Application_Cibil_Details[0].HighCredit_Or_SanctionedAmount;
            cibilFields[MONTH_OVERDUE_FIELD.fieldApiName] =
                result.Data.Application_Cibil_Details[0].Month_Overdue;
            cibilFields[NOOFENLTSIXMON_FIELD.fieldApiName] =
                result.Data.Application_Cibil_Details[0].NoOfEnLtSixMon;
            cibilFields[OLDEST_DATE_FIELD.fieldApiName] = new Date(
                Date.parse(result.Data.Application_Cibil_Details[0].OldestDate)
            );
            cibilFields[RECENT_DATE_FIELD.fieldApiName] = new Date(
                Date.parse(result.Data.Application_Cibil_Details[0].RecentDate)
            );
            cibilFields[SCORE_FIELD.fieldApiName] =
                result.Data.Application_Cibil_Details[0].Score;
            cibilFields[SUITFILEDORWILFULDEFAULT_FIELD.fieldApiName] =
                result.Data.Application_Cibil_Details[0].SuitFiledOrWilfulDefault;
            cibilFields[TYPE_FIELD.fieldApiName] =
                result.Data.Application_Cibil_Details[0].Type;
            cibilFields[WRITTENOFFAMOUNTTOTAL_FIELD.fieldApiName] =
                result.Data.Application_Cibil_Details[0].WrittenoffAmountTotal;

            if (result.Data.Cibil_LoanAccount_Details.length) {
                if (
                    result.Data.Cibil_LoanAccount_Details[0].Maker_Date !=
                        null ||
                    result.Data.Cibil_LoanAccount_Details[0].Maker_Date !==
                        undefined ||
                    result.Data.Cibil_LoanAccount_Details[0].Maker_Date !== ""
                ) {
                    let makerDate =
                        result.Data.Cibil_LoanAccount_Details[0].Maker_Date;
                    this.makerDateConversion = makerDate.substring(
                        0,
                        makerDate.lastIndexOf(" ")
                    );
                }
            }
            cibilFields[CIBIL_MAKER_DATE.fieldApiName] = result.Data
                .Cibil_LoanAccount_Details.length
                ? this.makerDateConversion.split("-").reverse().join("-")
                : "";

            if (result.Data.Equifax_Report_URl) {
                cibilFields[EQUIFAX_REPORT_URL_FIELD.fieldApiName] =
                    result.Data.Equifax_Report_URl +
                    "/?CIC_No=" +
                    result.Data.Application_Cibil_Details[0].CIC_No;
            }
            if (result.Data.Cibil_Report_URl) {
                cibilFields[CIBIL_REPORT_URI_FIELD.fieldApiName] =
                    result.Data.Cibil_Report_URl +
                    "/?CIC_No=" +
                    result.Data.Application_Cibil_Details[0].CIC_No;
            }

            if (
                result.Data.Application_Cibil_Details[0].CIC_No
            ) {
                cibilFields[CIBIL_APPLICANT_FIELD.fieldApiName] =
                applicantId;
                await this.createRecordDetails(
                    CIBIL_DETAILS_OBJECT.objectApiName,
                    cibilFields
                );
            }
            //  else if (this.cibilDetailsRecordId) {
            //     cibilFields[CIBIL_RECORD_DETAILS_ID.fieldApiName] =
            //         this.cibilDetailsRecordId;
            //     await this.updateRecordDetails(cibilFields);
            // }

            const applicantsFields = {};
            applicantsFields[APP_ID_FIELD.fieldApiName] = applicantId;
            applicantsFields[Bureau_Pull_Match__c.fieldApiName] =
                result.Data.IsSuccess === "True" ? true : false;
            applicantsFields[Bureau_Pull_Message__c.fieldApiName] =
                result.Data.StatusDescription;
            await this.updateRecordDetails(applicantsFields);

            this.cibilResult = true;
        } else {
            console.log("error " + result.Data.StatusDescription);
        }
    }

    async checkScoreCardAPI() {
        this.showSpinner = true;
        let executionStatus = {
            isAPISucessful: "false",
            message: "Scorecard API Failed"
        };

        await doBREscorecardCallout({
            applicantId: this.applicantId,
            loanAppId: this.loanId
        })
            .then((result) => {
                let scorecardDecision;
                const res = JSON.parse(result);
                switch (res.application.applicationDecision.riskBand) {
                    case "01":
                        scorecardDecision = "Dark Green";
                        break;
                    case "02":
                        scorecardDecision = "Light Green";
                        break;
                    case "03":
                        scorecardDecision = "Yellow";
                        break;
                    case "04":
                        scorecardDecision = "Orange";
                        break;
                    case "05":
                        scorecardDecision = "Red";
                        break;
                    default:
                        scorecardDecision = "";
                }

                executionStatus.isAPISucessful = true;
                executionStatus.message =
                    "Score Card Decision - " + this.scorecardDecision;
                    if(this.applicantsforCibil.length >0 && typeof this.applicantsforCibil !== 'undefined'){ 
                        return updateRecord({
                            fields: {
                                Id: this.applicantsforCibil[0].Id,
                                Scorecard_Decision__c: scorecardDecision,
                                ScoreCard_Description__c: scorecardDecision
                            }
                        }).catch((error) => {
                            console.log("Error: " + error.body.message);
                        });
                    }
                    else{
                        return updateRecord({
                            fields: {
                                Id: this.applicantId,
                                Scorecard_Decision__c: scorecardDecision,
                                ScoreCard_Description__c: scorecardDecision
                            }
                        }).catch((error) => {
                            console.log("Error: " + error.body.message);
                        });
                    }
            })
            .catch((error) => {
                this.showSpinner = false;
                executionStatus.isAPISucessful = false;
                executionStatus.message = error;
                console.log('score card error-->'+error);
            });

        return executionStatus;
    }

    async callLTVEngine() {
        await createFinalTermRecord({ loanApplicationId: this.loanId })
            .then((responses) => {
                const obj = JSON.parse(responses);
                this.finalTermId = obj.finalTermId;
            })
            .catch((error) => {
                const event = new ShowToastEvent({
                    title: "Error",
                    variant: "error",
                    message: error.body.message
                });
                this.dispatchEvent(event);
                // this.isLoading = false;
                console.log("error. ", error);
            });

        await doLTVEngineCallout({
            applicantId: this.applicantId,
            loanAppId: this.loanId
        })
            .then((result) => {
                const obj = JSON.parse(result);
                this.ltvEngineValue = obj.application.applicationDecision.ltv;
                const FinalTermFields = {};
                FinalTermFields[final_ID_FIELD.fieldApiName] = this.finalTermId;
                FinalTermFields[LtvEngine_Ltv.fieldApiName] =
                    this.ltvEngineValue;
                FinalTermFields[is_Active__c.fieldApiName] = true;
                return this.updateRecordDetails(FinalTermFields);
            })
            .catch((error) => {
                const event = new ShowToastEvent({
                    title: "Error",
                    variant: "error",
                    message: error.body.message
                });
                this.dispatchEvent(event);
                this.isLoading = false;
                this.showSpinner = false;
            });
    }

    async executePricingCallout() {
        let pricingRequest = {
            applicantId: this.applicantId,
            loanAppId: this.loanId
        }
        await doPricingEngineCallout(pricingRequest)
            .then((result) => {
                const obj = JSON.parse(result);
                this.thresholdNetIRR =
                    obj.application.applicationDecision.prescribedRate;
                const FinalTermFields = {};
                FinalTermFields[final_ID_FIELD.fieldApiName] = this.finalTermId;
                FinalTermFields[PricingEngine_thresholdNetrr.fieldApiName] =
                    this.thresholdNetIRR;
                return this.updateRecordDetails(FinalTermFields);
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log("error=> ", error);
                this.showSpinner = false;
                this.apiMessage =
                    "Please Kindly Retry Pricing Engine Api is Failed";
            });
    }

    async executeEMIEngine() {
        let runEMIDetails = {
            applicantId: this.applicantId,
            loanApplicationId: this.loanId
        };

        await doRunEmiEngineCallout({
            runEmiEngine: JSON.stringify(runEMIDetails)
        })
            .then((result) => {
                let custObj;
                let resArr = [JSON.parse(result)];
                let emiRanges = resArr[0].emiRanges;
                let k = 0;
                let updatedResp = [];

                for (let i = 0; i < emiRanges.length; i++) {
                    if (emiRanges[i].Outstanding_Amt > 0) {
                        custObj = {
                            Id: k,
                            Loan_Type: emiRanges[i].Loan_Type,
                            Outstanding_Amount: emiRanges[i].Outstanding_Amt,
                            Sequential_Number: "Loan " + parseInt(k + 1, 10),
                            upper_LimitEMI: emiRanges[i].Upper_Emi_Cap,
                            lower_LimitEMI: emiRanges[i].Lower_Emi_Cap,
                            emi: "",
                            existing_emi_id: ""
                        };
                        updatedResp.push(custObj);
                        k++;
                    }
                }

                this.existingEMIList = updatedResp;
                this.showEMIDetails = true;

                if (emiRanges.length > 0) {
                    this.saveValidatedEMIData();
                } else {
                    this.showEMIDetails = false;
                    // this.showNoEMIMessage = true;
                }

                //Update API Fields
                const fields = {};
                fields.Id = this.applicantId;
                fields.Is_RUN_EMI_Assessed__c = true;
                const recordInput = { fields };

                return updateRecord(recordInput)
                    .then(() => {

                    })
                    .catch((error) => {
                        console.log("Error in updating reocrd:: ", error);
                        this.showToastMessage(
                            null,
                            "Error in saving Existing EMI data",
                            "Error"
                        );
                    });
            })
            .catch((error) => {
                this.showSpinner = false;
            });
    }

    saveValidatedEMIData() {
        this.showSpinner = true;

        saveEMIDetails({
            emiData: JSON.stringify(this.existingEMIList),
            applicantId: this.applicantId
        })
            .then((response) => {
                let k = 0;
                let custObj;

                for (let i = 0; i < response.length; i++) {
                    custObj = {
                        Id: k,
                        Loan_Type: response[i].Loan_Type__c,
                        Outstanding_Amount: response[i].Outstanding_Amount__c,
                        Sequential_Number: "Loan " + parseInt(k + 1, 10),
                        upper_LimitEMI: response[i].Upper_EMI_Limit__c,
                        lower_LimitEMI: response[i].Lower_EMI_Limit__c,
                        emi: "",
                        existing_emi_id: response[i].Id
                    };
                    this.loanRecordsArray.push(custObj);
                    k++;
                }

                this.existingEMIList = this.loanRecordsArray;
                this.showSpinner = false;
            })
            .catch((error) => {
                console.log(
                    "getEMIExecutedValue - saveEMIDetails - Error:: ",
                    error
                );
                this.showSpinner = false;
            });
    }

   async executeOfferEngine(){
    this.boolOfferPage=true;
        this.showSpinner = true;
       await doDSAOfferEngineCallout({loanId:this.loanId,applicantId:this.applicantId})
        .then((response)=>{
            const res= JSON.parse(response);
            let maxLoan= Math.floor(res.application.offerEngineDetails.offerEngineDecision.displayLoanAmt || 0);
            let maxTenure=res.application.offerEngineDetails.offerEngineDecision.displayTenure;
            let EMI=res.application.offerEngineDetails.offerEngineDecision.displayEMI;
            let journeyDecision =res.application.offerEngineDetails.offerEngineDecision.stopJourneyFlag;
            console.log('journeyDecision-->'+journeyDecision);
            let IRR=res.application.offerEngineDetails.offerEngineDecision.displayCrmIrr.toFixed(2);
            const FinalTermsFields = {};
            FinalTermsFields[final_ID_FIELD.fieldApiName] = this.finalTermId;
            FinalTermsFields[Loan_Amount__c.fieldApiName] = maxLoan.toString();
            FinalTermsFields[Tenure__c.fieldApiName] = maxTenure.toString();
            FinalTermsFields[CRM_IRR__c.fieldApiName] = IRR;
           FinalTermsFields[EMI_Amount__c.fieldApiName] = EMI;
            this.updateRecordDetails(FinalTermsFields);
            if(journeyDecision === true){
                const oppFields = {};
                oppFields['Id'] = this.loanId;
                oppFields['DSA_Stage__c']='';
                this.updateRecordDetails(oppFields);
                console.log('inside journey stop');
                this.dataWrapper.journeyStopPopUp = true;
                this.dataWrapper.disableCheckEligibilityButton = true;
                this.dataWrapper.coborrowerPopup = false;
                this.dataWrapper.api='offer';
                // this.checkEligibilityTick = true;
                this.showSpinner = false;
                this.dispatchEvent(
                    new CustomEvent("checkeligibility", {
                        detail: this.dataWrapper
                    })
                );
            }
            else{
                console.log('inside way to offer');
                this.dispatchEvent(
                    new CustomEvent("brecomplete", {
                        detail: {
                            maxEligibleLoanAmount: maxLoan,
                            irr: IRR,
                            maxTenure: maxTenure,
                            emi: EMI,
                            disableCoborrowerIncomeField: this.boolDisableCoborrowerOffer
                        }
                    })
                );
            }
            this.showSpinner = false;
        })
        .catch((error)=>{
            console.log('error-->'+JSON.stringify(error));
            this.showSpinner = false;
        })
    }
}