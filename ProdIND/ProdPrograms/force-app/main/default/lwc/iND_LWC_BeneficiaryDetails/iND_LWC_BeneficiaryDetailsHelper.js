import { updateRecord } from 'lightning/uiRecordApi'; 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import x1stPVEMIDueDate from "@salesforce/label/c.x1stPVEMIDueDate";
import x1stTWEMIDueDate from "@salesforce/label/c.x1stTWEMIDueDate";
import x21EMIDueDate from "@salesforce/label/c.x21EMIDueDate";
import x1stPVEMIDueDatev2 from "@salesforce/label/c.x1stPVEMIDueDatev2";
import getAdvancedEMI from "@salesforce/apex/LoanAgreementController.getAdvancedEMI";
import doOfferEngineCallout from '@salesforce/apexContinuation/IntegrationEngine.doOfferEngineCallout';
import Message_Offer_Engine_Success from '@salesforce/label/c.Message_Offer_Engine_Success';
import Message_Offer_Engine_Failure from '@salesforce/label/c.Message_Offer_Engine_Failure';
import getFinalTermId from '@salesforce/apex/CAMApprovalLogController.getFinalTermId';
import Gross_IRR from '@salesforce/schema/Final_Term__c.Gross_IRR__c';
import final_ID_FIELD from '@salesforce/schema/Final_Term__c.Id';
import EMI_Amount from '@salesforce/schema/Final_Term__c.EMI_Amount__c';
import CRM_IRR from '@salesforce/schema/Final_Term__c.CRM_IRR__c';
import Net_IRR from '@salesforce/schema/Final_Term__c.Net_IRR__c';
import Inputted_IRR from '@salesforce/schema/Final_Term__c.Inputted_IRR__c';
import saveInstallmentSchedule from '@salesforce/apex/InstallmentScheduleController.saveInstallmentSchedule';//CISP-20786
import doFicoDeviationCallout_MTD from '@salesforce/apexContinuation/IntegrationEngine.doFicoDeviationCallout';
import triggerDeviations from '@salesforce/apex/CAMApprovalLogController.triggerDeviations';
import Message_CAM_Not_Generated_Cannot_Generate_Deviations from '@salesforce/label/c.Message_CAM_Not_Generated_Cannot_Generate_Deviations';
import Message_Deviation_Created from '@salesforce/label/c.Message_Deviation_Created';
import roiMaster from '@salesforce/apex/IND_OfferScreenController.roiMaster';
import roiMasterForImputedIRR from '@salesforce/apex/IND_OfferScreenController.roiMasterForImputedIRR';
import roiMasterForGrossIRR from '@salesforce/apex/IND_OfferScreenController.roiMasterForGrossIRR'; 
import triggerDeviationMail from '@salesforce/apex/IND_CAMWithoutSharing.triggerDeviationMail';
import doEmailServiceCallout from '@salesforce/apexContinuation/IntegrationEngine.doEmailServiceCallout';
import Message_Deviation_Mail_Triggered from '@salesforce/label/c.Message_Deviation_Mail_Triggered';
import First_EMI_Date from '@salesforce/schema/Final_Term__c.First_EMI_Date__c';
import Second_EMI_Date from '@salesforce/schema/Final_Term__c.Second_EMI_Date__c';
import Loan_Deal_Date from '@salesforce/schema/Final_Term__c.Loan_Deal_Date__c';
import allIrrDeviationApproved from '@salesforce/apex/LoanDisbursementController.allIrrDeviationApproved'; 
import doD2COfferEngineCallout from '@salesforce/apexContinuation/D2C_IntegrationEngine.doD2COfferEngineCallout';
import loanApplicationRevoke from '@salesforce/apex/IND_RevokeController.loanApplicationRevoke'; // Revoke Loan Application
import isUserSelectionLookupRequiredOnRevoke from '@salesforce/apex/IND_RevokeController.isUserSelectionLookupRequiredOnRevoke'; //CISP-4628
import EXCEPTIONMESSAGE from '@salesforce/label/c.ExceptionMessage';
import getIrrDeviationsForApprovals from '@salesforce/apex/LoanDisbursementController.getIrrDeviationsForApprovals';

import getFinalTermsRecord from '@salesforce/apex/ExternalCAMDataController.getFinalTermsRecord'; //SFTRAC-1896
import tractorOfferEngineCallout from '@salesforce/apex/IntegrationEngine.tractorOfferEngine'; //SFTRAC-1896
import saveInstallmentScheduleTractor from '@salesforce/apex/InstallmentScheduleController.saveInstallmentScheduleTractor';
import OfferengineMinLoanAmount from '@salesforce/schema/Final_Term__c.OfferengineMinLoanAmount__c'; //SFTRAC-1896
import OfferengineMaxLoanAmount from '@salesforce/schema/Final_Term__c.OfferengineMaxLoanAmount__c'; //SFTRAC-1896
import Loan_Amount from '@salesforce/schema/Final_Term__c.Loan_Amount__c'; //SFTRAC-1896
import OfferengineMinTenure from '@salesforce/schema/Final_Term__c.OfferengineMinTenure__c'; //SFTRAC-1896
import OfferengineMaxTenure from '@salesforce/schema/Final_Term__c.OfferengineMaxTenure__c'; //SFTRAC-1896
import Tenure from '@salesforce/schema/Final_Term__c.Tenure__c'; //SFTRAC-1896
import Required_CRM_IRR from '@salesforce/schema/Final_Term__c.Required_CRM_IRR__c'; //SFTRAC-1896
import Bank_IRR from '@salesforce/schema/Final_Term__c.Bank_IRR__c'; //SFTRAC-1896
import Offer_Agreement_Amount from '@salesforce/schema/Final_Term__c.Offer_Agreement_Amount__c'; //SFTRAC-1896
import Installment_Schedule_Submitted from '@salesforce/schema/Final_Term__c.Installment_Schedule_Submitted__c'; //SFTRAC-1896
import L1_L2_Final_Terms_Changed from '@salesforce/schema/Final_Term__c.L1_L2_Final_Terms_Changed__c'; //SFTRAC-1896
import roiMasterTractor from '@salesforce/apex/IND_OfferScreenController.roiMasterTractor'; //SFTRAC-1896
import Last_Offer_Engine_Equat from '@salesforce/schema/Final_Term__c.Last_Offer_Engine_Equat__c'; //SFTRAC-2291
import Last_Offer_Engine_Struct from '@salesforce/schema/Final_Term__c.Last_Offer_Engine_Struct__c'; //SFTRAC-2291
//Start - SFTRAC-2189
import CIBIL_DETAILS_OBJECT from '@salesforce/schema/CIBIL_Details__c';
import CIBIL_MAKER_DATE from '@salesforce/schema/CIBIL_Details__c.Maker_Date__c';
import AMOUNT_OVERDUE_FIELD from '@salesforce/schema/CIBIL_Details__c.Amount_Overdue__c';
import CIBIL_APPLICANT_FIELD from '@salesforce/schema/CIBIL_Details__c.Applicant__c';
import CIBIL_DECISION_FIELD from '@salesforce/schema/CIBIL_Details__c.Cibil_Decision__c';
import CIBIL_REPORT_URI_FIELD from '@salesforce/schema/CIBIL_Details__c.CIBIL_Report_URl__c';
import CIC_NO_FIELD from '@salesforce/schema/CIBIL_Details__c.CIC_No__c';
import CRIF_SCORE_DESC_FIELD from '@salesforce/schema/CIBIL_Details__c.CRIF_Score_Desc__c';
import CURRENT_BALANCE_FIELD from '@salesforce/schema/CIBIL_Details__c.Current_Balance__c';
import ENTITY_FIELD from '@salesforce/schema/CIBIL_Details__c.Entity_Type__c';
import EQUIFAX_REPORT_URL_FIELD from '@salesforce/schema/CIBIL_Details__c.Equifax_Report_URl__c';
import HIGHCREDIT_OR_SANCTIONEDAMOUNT_FIELD from '@salesforce/schema/CIBIL_Details__c.HighCredit_Or_SanctionedAmount__c';
import MONTH_OVERDUE_FIELD from '@salesforce/schema/CIBIL_Details__c.Month_Overdue__c';
import NOOFENLTSIXMON_FIELD from '@salesforce/schema/CIBIL_Details__c.NoOfEnLtSixMon__c';
import OLDEST_DATE_FIELD from '@salesforce/schema/CIBIL_Details__c.Oldest_Date__c';
import RECENT_DATE_FIELD from '@salesforce/schema/CIBIL_Details__c.Recent_Date__c';
import SCORE_FIELD from '@salesforce/schema/CIBIL_Details__c.Score__c';
import SUITFILEDORWILFULDEFAULT_FIELD from '@salesforce/schema/CIBIL_Details__c.SuitFiledOrWilfulDefault__c';
import TYPE_FIELD from '@salesforce/schema/CIBIL_Details__c.Type__c';
import WRITTENOFFAMOUNTTOTAL_FIELD from '@salesforce/schema/CIBIL_Details__c.WrittenoffAmountTotal__c';
//End - SFTRAC-2189
import doCIBILReportCallout from '@salesforce/apexContinuation/IntegrationEngine.doCIBILReportCallout';
import Kindly_Retry from '@salesforce/label/c.Kindly_Retry';
import CIBIL_PULL_DATE from '@salesforce/schema/CIBIL_Details__c.CIBIL_Pull_Date__c';
import CIBIL_RECORD_DETAILS_ID from '@salesforce/schema/CIBIL_Details__c.Id';
import Bureau_Pull_Match__c from '@salesforce/schema/Applicant__c.Bureau_Pull_Match__c';
import Bureau_Pull_Message__c from '@salesforce/schema/Applicant__c.Bureau_Pull_Message__c';
import APP_ID_FIELD from '@salesforce/schema/Applicant__c.Id';


export function disableEverything(thisvar){
  let allElements = thisvar.template.querySelectorAll('*');
  allElements.forEach(element =>
      element.disabled = true
  );
  const event = new ShowToastEvent({
    title: '',
    message:  'Cibil Report or MFC Report generation date is more than 30 or 90 days. Please revoke the application',
    variant: 'warning',
    mode: 'dismissable'
  });
  thisvar.dispatchEvent(event);
}//SFTRAC-2277
export function handlePaymentInputHelper(event,thisVar){
  try {
    thisVar.paymentMadeOnValue = event.target.value;
    const currentDate = new Date();currentDate.setHours(0, 0, 0, 0);const userDate = new Date(thisVar.paymentMadeOnValue);userDate.setHours(0, 0, 0, 0);if((thisVar.paymentMadeOnValue !== thisVar.invoiceTaxDate) && (userDate < currentDate)){thisVar.isPaymentMadeOnInvalid = true;thisVar.showToastMessage('error','Payment date should be same as invoice tax date or today date or future date','error');}else{thisVar.isPaymentMadeOnInvalid = false;calculateFirstSecEMI(thisVar.paymentMadeOnValue,thisVar);}
  } catch (error) {
    console.error(error);
  }
}
export async function handleTFOfferEngineCalloutHelper(thisVar){

  console.log('++++handleTFOfferEngineCalloutHelper finalTermRecordId '+thisVar.finalTermRecordId +' installmentTypeValue '+thisVar.installmentTypeValue);
  thisVar.isSpinnerMoving=true;
  const FinalTermFields = {};
  FinalTermFields[final_ID_FIELD.fieldApiName] = thisVar.finalTermRecordId;
  FinalTermFields[First_EMI_Date.fieldApiName] = thisVar.tffirstEMIdueDate;
  FinalTermFields[Second_EMI_Date.fieldApiName] = thisVar.tfsecEMIdueDate;
  FinalTermFields[Loan_Deal_Date.fieldApiName] = thisVar.tfloanDealDate;
  const recordInput = { fields:FinalTermFields,};
  console.log('++++IN handleTFOfferEngineCalloutHelper recordInput '+recordInput);
  await updateRecord(recordInput).then(() => {}).catch((error) => {console.error('updateRecord finalterm',error);});
  console.log('++++IN thisVar.recordid '+thisVar.recordid+' thisVar.vehicleRecordId '+thisVar.vehicleRecordId);
  try{
    let result = await tractorOfferEngineCallout({ loanAppId: thisVar.recordid, vehicleId: thisVar.vehicleRecordId, screenName : 'Disbursement Request Preparation'});
        const parsedResponse = JSON.parse(result);
        const offerEngineResponse = parsedResponse?.application?.offerEngineDetails?.offerEngineDecision;
      if(offerEngineResponse.stopJourneyFlag == true && thisVar.installmentTypeValue == 'Structured'){
          const evt = new ShowToastEvent({ title: "Error", message: 'API responed to stop journey, please update EMI again', variant: 'error' });
          thisVar.dispatchEvent(evt);
          deleteStructeredEMIRec({ vehicleRecId: thisVar.vehicleRecordId, loanAppId: thisVar.recordid })
          .then(result => {console.log('+++++result ',result);})
          .catch(error => { thisVar.showToast('Error', error.body.message, 'error');});
          //setTimeout(() => {window.location.reload(); },2000);
          if(thisVar.installmentTypeValue == 'Structured'){
            const FinalTermFields = {};
            FinalTermFields[final_ID_FIELD.fieldApiName] = thisVar.finalTermRecordId;
            FinalTermFields[L1_L2_Final_Terms_Changed.fieldApiName] = true;
            FinalTermFields[Installment_Schedule_Submitted.fieldApiName] = false;
            const recordInput = { fields:FinalTermFields,};
            await updateRecord(recordInput).then(() => {}).catch((error) => {console.error('updateRecord finalterm',error);});
          }
      }else{
        if(thisVar.isNonIndividual != true && (parseFloat(offerEngineResponse.displayCrmIrr) > parseFloat(thisVar.tfmaxcrm) || parseFloat(offerEngineResponse.displayCrmIrr) < parseFloat(thisVar.tfmincrm))){
          thisVar.showToastMessage('Warning', `CRM IRR is not as per norms Min ${thisVar.tfmincrm} and Max ${thisVar.tfmaxcrm}`, 'Warning');
          thisVar.isSpinnerMoving = false;

          if(thisVar.installmentTypeValue == 'Structured'){
            thisVar.showInstallmentModel = true; /*SFTRAC-2291*/
            thisVar.isIRRBreached = true; /*SFTRAC-2291*/
            thisVar.isTFInstallmentDisabled = false;  /*SFTRAC-2291*/
            thisVar.isTFOfferEngineDisabled=true; /*SFTRAC-2291*/
            const FinalTermFields = {};
            FinalTermFields[final_ID_FIELD.fieldApiName] = thisVar.finalTermRecordId;
            //FinalTermFields[L1_L2_Final_Terms_Changed.fieldApiName] = true;
            FinalTermFields[Installment_Schedule_Submitted.fieldApiName] = false;
            const recordInput = { fields:FinalTermFields,};
            await updateRecord(recordInput).then(() => {}).catch((error) => {console.error('updateRecord finalterm',error);});
          }
          return;
        }else if(thisVar.isNonIndividual != true && (parseFloat(offerEngineResponse.grossIrr) > parseFloat(thisVar.maxGROSSIRR) || parseFloat(offerEngineResponse.grossIrr) < parseFloat(thisVar.minGROSSIRR))){
          thisVar.showToastMessage('Warning', 'Gross IRR is not as per norms Min ${thisVar.minGROSSIRR} and Max ${thisVar.maxGROSSIRR}', 'Warning');
          thisVar.isSpinnerMoving = false;
          if(thisVar.installmentTypeValue == 'Structured'){
            thisVar.showInstallmentModel = true; /*SFTRAC-2291*/
            thisVar.isIRRBreached = true; /*SFTRAC-2291*/
            thisVar.isTFInstallmentDisabled = false;  /*SFTRAC-2291*/
            thisVar.isTFOfferEngineDisabled=true; /*SFTRAC-2291*/
            const FinalTermFields = {};
            FinalTermFields[final_ID_FIELD.fieldApiName] = thisVar.finalTermRecordId;
            //FinalTermFields[L1_L2_Final_Terms_Changed.fieldApiName] = true;
            FinalTermFields[Installment_Schedule_Submitted.fieldApiName] = false;
            const recordInput = { fields:FinalTermFields,};
            await updateRecord(recordInput).then(() => {}).catch((error) => {console.error('updateRecord finalterm',error);});
          }
          return;
        }
        const FinalTermFields = {};
        FinalTermFields[final_ID_FIELD.fieldApiName]= thisVar.finalTermRecordId;
        FinalTermFields[OfferengineMinLoanAmount.fieldApiName] = offerEngineResponse !== undefined && offerEngineResponse.minLoanAmt != 'NaN' ?  offerEngineResponse.minLoanAmt : '';
        FinalTermFields[OfferengineMaxLoanAmount.fieldApiName] = offerEngineResponse !== undefined && offerEngineResponse.maxLoanAmt != 'NaN' ?  offerEngineResponse.maxLoanAmt : '';
        //FinalTermFields[Loan_Amount.fieldApiName] = offerEngineResponse !== undefined && offerEngineResponse.displayLoanAmt != 'NaN' ?  offerEngineResponse.displayLoanAmt.toString() : '';
        FinalTermFields[Loan_Amount.fieldApiName] = offerEngineResponse !== undefined ?  (parseFloat(offerEngineResponse.displayLoanAmt) - thisVar.totalFundedPremium).toString() : '';
        FinalTermFields[OfferengineMinTenure.fieldApiName] = offerEngineResponse !== undefined && offerEngineResponse.minTenure != 'NaN' ?  offerEngineResponse.minTenure : '';
        FinalTermFields[OfferengineMaxTenure.fieldApiName] = offerEngineResponse !== undefined && offerEngineResponse.maxTenure != 'NaN' ?  offerEngineResponse.maxTenure : '';
        FinalTermFields[Tenure.fieldApiName] = offerEngineResponse !== undefined && offerEngineResponse.displayTenure != 'NaN' ?  offerEngineResponse.displayTenure.toString() : '';
        FinalTermFields[EMI_Amount.fieldApiName] = offerEngineResponse !== undefined && offerEngineResponse.displayEMI != 'NaN' ?  offerEngineResponse.displayEMI : '';
        FinalTermFields[Required_CRM_IRR.fieldApiName] = offerEngineResponse !== undefined && offerEngineResponse.displayCrmIrr != 'NaN' ?  offerEngineResponse.displayCrmIrr.toString() : '';
        FinalTermFields[Net_IRR.fieldApiName] = offerEngineResponse !== undefined && offerEngineResponse.netIrr != 'NaN' ?  offerEngineResponse.netIrr : '';
        FinalTermFields[Gross_IRR.fieldApiName] = offerEngineResponse !== undefined && offerEngineResponse.grossIrr != 'NaN' ?  offerEngineResponse.grossIrr : '';
        FinalTermFields[Bank_IRR.fieldApiName] = offerEngineResponse !== undefined && offerEngineResponse.bankCrmIrr != 'NaN' ?  offerEngineResponse.bankCrmIrr.toString() : '';
        FinalTermFields[Offer_Agreement_Amount.fieldApiName] = offerEngineResponse !== undefined && offerEngineResponse.agreementAmount != 'NaN' ?  offerEngineResponse.agreementAmount : '';
        FinalTermFields[L1_L2_Final_Terms_Changed.fieldApiName] = false;
        FinalTermFields[Installment_Schedule_Submitted.fieldApiName] = true;

        //SFTRAC-2291 start
        if(thisVar.installmentTypeValue == 'Equated'){
          FinalTermFields[Last_Offer_Engine_Equat.fieldApiName] = true;
          thisVar.isAllowPACTAPI = true;
        }else if(thisVar.installmentTypeValue == 'Structured' && thisVar.isIRRBreached == false){
          FinalTermFields[Last_Offer_Engine_Equat.fieldApiName] = true;
          FinalTermFields[Last_Offer_Engine_Struct.fieldApiName] = true;
          thisVar.isAllowPACTAPI = true;
        }else if(thisVar.installmentTypeValue == 'Structured' && thisVar.isIRRBreached == true){
          FinalTermFields[Last_Offer_Engine_Equat.fieldApiName] = true;
        }
        //SFTRAC-2291 end

        if(offerEngineResponse && offerEngineResponse.amortizationSchedule){
          let result = await saveInstallmentScheduleTractor({ loanId: thisVar.recordid, response: JSON.stringify(offerEngineResponse.amortizationSchedule), installmentType: thisVar.installmentTypeValue, vehicleId: thisVar.vehicleRecordId})
          if(result){
            let res = await thisVar.updateRecordDetails(FinalTermFields);
            if(res){
              thisVar.showToastMessage('Success', 'Offer Engine API Completed', 'Success');
              thisVar.isTFOfferEngineDisabled=true;
              thisVar.isSpinnerMoving=false;
              thisVar.isTFInstallmentDisabled = false;
              thisVar.disableReTriggerPR = false;
              thisVar.isTFPaymentMadeDisabled = true;
              thisVar.tfCRMIRR = offerEngineResponse.displayCrmIrr.toString();
              thisVar.tfGrossRR = offerEngineResponse.grossIrr.toString();
              thisVar.tfNetRR = offerEngineResponse.netIrr.toString();
            }else{
              thisVar.showToastMessage('Error', 'Failed to update Offer Engine Response, try after sometime', 'Error');
              thisVar.isTFOfferEngineDisabled=false;
              thisVar.isSpinnerMoving=false;
              thisVar.disableReTriggerPR = true;
              thisVar.isTFInstallmentDisabled = true;
              //thisVar.isTFPaymentMadeDisabled = false;
            }
          }
      }else{
          const evt = new ShowToastEvent({
              title: 'Error',
              message: "Something went wrong!",
              variant: 'error',
          });
          thisVar.dispatchEvent(evt);
          thisVar.isSpinnerMoving = false;
      }
            }
    }catch(error){
      thisVar.showToastMessage('Error', 'Offer Engine API Failed', 'Error');
      thisVar.isTFOfferEngineDisabled=false;
      thisVar.isSpinnerMoving=false;
      thisVar.disableReTriggerPR = true;
      thisVar.isTFInstallmentDisabled = true;
      //thisVar.isTFPaymentMadeDisabled = false;
    }
}
export async function calculateFirstSecEMI(paymentMadeOnDate,thisVar) {
  try {
      await getAdvancedEMI({
        loanAppId: thisVar.recordid,
        dealId: thisVar.dealId
      })
        .then((response) => {
          try {
            let today = new Date();
            if (response?.Advance_EMI__c || response == null) {
              if (paymentMadeOnDate) {
                today = new Date(paymentMadeOnDate);
              }
              let x1stEMIDate1;
              let x2ndEMIDate1;
              if (thisVar.loanAppProductType && thisVar.loanAppProductType.includes("Two Wheeler")) {
                  let effectiveDealDate1 = new Date(paymentMadeOnDate);
                  x1stEMIDate1 = effectiveDealDate1;
                  x2ndEMIDate1 = new Date((x1stEMIDate1.getFullYear()), (x1stEMIDate1.getMonth() + 1), );
                  if (parseInt(effectiveDealDate1.getDate()) > 0 && parseInt(effectiveDealDate1.getDate()) <= 15) {
                      x2ndEMIDate1 = new Date(x2ndEMIDate1.getFullYear(), x2ndEMIDate1.getMonth(), parseInt(x1stTWEMIDueDate));
                  } else {
                      x2ndEMIDate1 = new Date(x2ndEMIDate1.getFullYear(), x2ndEMIDate1.getMonth(), parseInt(x21EMIDueDate));
                  }
              } else if (thisVar.loanAppProductType && thisVar.loanAppProductType.includes("Passenger Vehicles")) {
                  x1stEMIDate1 = new Date(paymentMadeOnDate);
                  x2ndEMIDate1 = new Date((x1stEMIDate1.getFullYear()), (x1stEMIDate1.getMonth() + 1), );
                  if (parseInt(x1stEMIDate1.getDate()) > 0 && parseInt(x1stEMIDate1.getDate()) < 15) {
                      x2ndEMIDate1 = new Date(x2ndEMIDate1.getFullYear(), x2ndEMIDate1.getMonth(), parseInt(x1stPVEMIDueDate));
                  } else {
                      x2ndEMIDate1 = new Date(x2ndEMIDate1.getFullYear(), x2ndEMIDate1.getMonth(), parseInt(x1stPVEMIDueDatev2));
                  }
              }
              thisVar.secEMIdueDate = x2ndEMIDate1.getDate() + "-" + (x2ndEMIDate1.getMonth() + 1) + "-" + x2ndEMIDate1.getFullYear();
              thisVar.emidatelist = [];
              let firstEmiVal = new Date(x1stEMIDate1.getFullYear(),x1stEMIDate1.getMonth(),x1stEMIDate1.getDate());
              thisVar.firstEMIdueDate = firstEmiVal.toString() ;
              thisVar.emidatelist.push({label: x1stEMIDate1.getDate()+"-"+(x1stEMIDate1.getMonth()+1)+"-"+x1stEMIDate1.getFullYear(), value: firstEmiVal.toString()});
              thisVar.fistEmiAPIValue = x1stEMIDate1.toString();
              thisVar.secondEmiAPIValue = x2ndEMIDate1.toString();
            } else {
              let x1stEMIDate2 = new Date(
                (today.getFullYear()),
                (today.getMonth() + 1)
              );
              let x2ndEMIDate2 = new Date(
                (x1stEMIDate2.getFullYear()),
                (x1stEMIDate2.getMonth() + 1),
              );
              if (
                thisVar.loanAppProductType &&
                thisVar.loanAppProductType.includes("Two Wheeler")
              ) {
                  let x1stEMIDate1;
                  let x2ndEMIDate1;
                let x1stEMIDate2;
                x1stEMIDate2 = new Date(paymentMadeOnDate);
                let x2ndEMIDate2 = new Date(
                  (x1stEMIDate2.getFullYear()),
                  (x1stEMIDate2.getMonth() + 1),
                );
                if (parseInt(x1stEMIDate2.getDate()) > 0 && parseInt(x1stEMIDate2.getDate()) <= 15) {
                  x1stEMIDate2 = new Date(
                    x1stEMIDate2.getFullYear(),
                    x1stEMIDate2.getMonth() + 1,
                    parseInt(x1stTWEMIDueDate)
                  );
                  x2ndEMIDate2 = new Date(
                    x2ndEMIDate2.getFullYear(),
                    x2ndEMIDate2.getMonth() + 1,
                    parseInt(x1stTWEMIDueDate)
                  );
                } else {
                  x1stEMIDate2 = new Date(
                    x1stEMIDate2.getFullYear(),
                    x1stEMIDate2.getMonth() + 1,
                    parseInt(x21EMIDueDate)
                  );
                  x2ndEMIDate2 = new Date(
                    x2ndEMIDate2.getFullYear(),
                    x2ndEMIDate2.getMonth() + 1,
                    parseInt(x21EMIDueDate)
                  );
                }
                thisVar.secEMIdueDate = x2ndEMIDate2.getDate() + "-" + (x2ndEMIDate2.getMonth() + 1) + "-" + x2ndEMIDate2.getFullYear();
                thisVar.emidatelist = [];
                let firstEmiVal = new Date(x1stEMIDate2.getFullYear(),x1stEMIDate2.getMonth(),x1stEMIDate2.getDate());
                thisVar.firstEMIdueDate = firstEmiVal && firstEmiVal.toString() ;
                thisVar.emidatelist.push({label: x1stEMIDate2.getDate()+"-"+(x1stEMIDate2.getMonth()+1)+"-"+x1stEMIDate2.getFullYear(), value: firstEmiVal.toString()});
                thisVar.fistEmiAPIValue = x1stEMIDate2.toString();
                thisVar.secondEmiAPIValue = x2ndEMIDate2.toString();
              } else if (
                thisVar.loanAppProductType &&
                thisVar.loanAppProductType.includes("Passenger Vehicles")
              ) {
                thisVar.showemidropdown = false;
                let datelist = [];
                let x1stEMIDate2 = new Date(paymentMadeOnDate);
                let x2ndEMIDate2 = new Date(
                  (x1stEMIDate2.getFullYear()),
                  (x1stEMIDate2.getMonth() + 1),
                );
                if(parseInt(x1stEMIDate2.getDate()) >= parseInt(x1stPVEMIDueDate) && parseInt(x1stEMIDate2.getDate()) < parseInt(x1stPVEMIDueDatev2)){
                  let firstdate = new Date(
                    x1stEMIDate2.getFullYear(),
                    x1stEMIDate2.getMonth(),
                    parseInt(x1stPVEMIDueDatev2)
                  );
                  datelist.push({ label: firstdate.getDate()+'-'+(firstdate.getMonth()+1)+'-'+firstdate.getFullYear(), value: firstdate.toString() });
                  let secdate = new Date(
                    x2ndEMIDate2.getFullYear(),
                    x2ndEMIDate2.getMonth(),
                    parseInt(x1stPVEMIDueDate)
                  );
                  datelist.push({ label: secdate.getDate()+'-'+(secdate.getMonth()+1)+'-'+secdate.getFullYear(), value: secdate.toString()});
                  let thirddate = new Date(
                    x2ndEMIDate2.getFullYear(),
                    x2ndEMIDate2.getMonth(),
                    parseInt(x1stPVEMIDueDatev2)
                  );
                  datelist.push({ label: thirddate.getDate()+'-'+(thirddate.getMonth()+1)+'-'+thirddate.getFullYear(), value: thirddate.toString()});
                } else {
                  let firstdateNew = new Date(
                    x1stEMIDate2.getFullYear(),
                    x1stEMIDate2.getMonth() + 1,
                    parseInt(x1stPVEMIDueDate)
                  );
                  datelist.push({label: firstdateNew.getDate()+'-'+(firstdateNew.getMonth()+1)+'-'+firstdateNew.getFullYear(), value: firstdateNew.toString()});
                  let secdateNew = new Date(
                    x2ndEMIDate2.getFullYear(),
                    x2ndEMIDate2.getMonth(),
                    parseInt(x1stPVEMIDueDatev2)
                  );
                  datelist.push({label: secdateNew.getDate()+'-'+(secdateNew.getMonth()+1)+'-'+secdateNew.getFullYear(), value: secdateNew.toString()});
                  let thirddateNew = new Date(
                    x2ndEMIDate2.getFullYear(),
                    x2ndEMIDate2.getMonth() + 1,
                    parseInt(x1stPVEMIDueDate)
                  );
                  datelist.push({label: thirddateNew.getDate()+'-'+(thirddateNew.getMonth()+1)+'-'+thirddateNew.getFullYear(), value: thirddateNew.toString()});
                }
                thisVar.emidatelist = datelist;
                //new changes
                   thisVar.firstEMIdueDate = thisVar.emidatelist[0].value;
                   calculateSecEmiOnPaymentModeChange(thisVar.firstEMIdueDate,thisVar);
              }
            }
          } catch (err) { 
            console.error(err); 
          }
        })
        .catch((error) => {
          console.error(error);
        });
    } catch (error) {
      console.log('getAdvancedEMIController error ', error);
    }
}
export function calculateSecEmi(firstemi,thisVar){
  let newFirstDate = new Date(firstemi);
  let secemi = new Date(
      newFirstDate.getFullYear(),
    (newFirstDate.getMonth() + 1),
    newFirstDate.getDate()
  );
  thisVar.secEMIdueDate = secemi.getDate() + "-" + (secemi.getMonth() + 1) + "-" + secemi.getFullYear();
  thisVar.fistEmiAPIValue = newFirstDate.toString();
  thisVar.secondEmiAPIValue = secemi.toString();
}
export function calculateSecEmiOnPaymentModeChange(firstemi,thisVar){
  let newFirstDate = new Date(firstemi);
  let secemi = new Date(
      newFirstDate.getFullYear(),
    (newFirstDate.getMonth() + 1),
    newFirstDate.getDate()
  );
  thisVar.secEMIdueDate = secemi.getDate() + "-" + (secemi.getMonth() + 1) + "-" + secemi.getFullYear();
  thisVar.fistEmiAPIValue = newFirstDate.toString();
  thisVar.secondEmiAPIValue = secemi.toString();
}
export async function handleOfferEngineCalloutHelper(thisVar){
  try {
    const currentDate = new Date();currentDate.setHours(0, 0, 0, 0);const userDate = new Date(thisVar.paymentMadeOnValue);userDate.setHours(0, 0, 0, 0);if((thisVar.paymentMadeOnValue !== thisVar.invoiceTaxDate) && (userDate < currentDate)){thisVar.showToastMessage('error','Payment date should be same as invoice tax date or today date or future date','error'); return;}
  if(!thisVar.paymentMadeOnValue || !thisVar.secondEmiAPIValue || !thisVar.fistEmiAPIValue){
    thisVar.showToastMessage('Error','Payment to be Made on ,First EMI due date and Second EMI due date should not empty.','Error');
    return;
  }
  thisVar.isSpinnerMoving = true;
  thisVar.irrComBtnClicked = false;
  thisVar.isOfferEngineClicked = true;
  let firstDate= new Date(thisVar.fistEmiAPIValue);
  let secondDate= new Date(thisVar.secondEmiAPIValue);
  let firstEmiDate = firstDate.getFullYear() + "-" + (firstDate.getMonth() + 1) + "-" + firstDate.getDate();

  let secondEmiDate = secondDate.getFullYear() + "-" + (secondDate.getMonth() + 1) + "-" + secondDate.getDate();
  let emiDueDate = new Date(thisVar.paymentMadeOnValue);
  emiDueDate = new Date(emiDueDate.getFullYear(),emiDueDate.getMonth(),emiDueDate.getDate());
  let emiDueDateVal = emiDueDate.getFullYear() + "-" + (emiDueDate.getMonth() + 1) + "-" + emiDueDate.getDate();
  if(!thisVar.previousEngineData){
    thisVar.previousEngineData = {paymentMadeOnValue:new Date(thisVar.paymentMadeOnValue),firstData:firstDate,secondDate:secondDate};
  }
  const FinalTermFields = {};
  FinalTermFields[final_ID_FIELD.fieldApiName] = thisVar.finaltermRec.Id;
  FinalTermFields[First_EMI_Date.fieldApiName] = firstEmiDate;
  FinalTermFields[Second_EMI_Date.fieldApiName] = secondEmiDate;
  FinalTermFields[Loan_Deal_Date.fieldApiName] = emiDueDateVal;
  const recordInput = { fields:FinalTermFields,};
  await updateRecord(recordInput).then(() => {}).catch((error) => {console.error('updateRecord finalterm',error);});
  try {
        let offerEngineRequestString = {
          'loanApplicationId': thisVar.recordid,
          'currentScreen': 'Final Offer',
          'thresholdNetIRR': null,
          'crmIrrChanged': null,
          'loanAmountChanged': null,
          'tenureChanged': null,
          'advanceEmiFlag': null,
          'offerEMI': thisVar.emi?thisVar.emi.toString():'',
        };
      let offerEngineMethod = doOfferEngineCallout;
      let offerEngineParams = { offerEngineRequestString: JSON.stringify(offerEngineRequestString) };
      if(thisVar.source === 'D2C' || thisVar.source === 'Hero'){
          offerEngineMethod = doD2COfferEngineCallout;
          offerEngineParams = {loanId: thisVar.recordid, applicantId: null, fromScreen:'cam'};
          await callOfferEngineContinue(offerEngineParams,thisVar,offerEngineMethod,false);
      }
      if(thisVar.isTw && !thisVar.source){
        offerEngineRequestString = {
          'loanApplicationId': thisVar.recordid,
          'currentScreen': 'CAM and Approval Log',
          'thresholdNetIRR': null,
          'crmIrrChanged': null,
          'loanAmountChanged': null,
          'tenureChanged': null,
          'advanceEmiFlag': null,
          'offerEMI': thisVar.emi?thisVar.emi.toString():'',
      };
      offerEngineParams = { offerEngineRequestString: JSON.stringify(offerEngineRequestString) };
        await callOfferEngineContinue(offerEngineParams,thisVar,offerEngineMethod,false);
      }
      if(thisVar.isPv || (thisVar.isTw && !thisVar.source)){
        let offerEngineRequestString = {
          'loanApplicationId': thisVar.recordid,
          'currentScreen': 'Final Offer',
          'thresholdNetIRR': null,
          'crmIrrChanged': null,
          'loanAmountChanged': null,
          'tenureChanged': null,
          'advanceEmiFlag': null,
          'offerEMI': thisVar.emi?thisVar.emi.toString():'',
        };
      offerEngineParams = { offerEngineRequestString: JSON.stringify(offerEngineRequestString) };
        await callOfferEngineContinue(offerEngineParams,thisVar,offerEngineMethod,true);
      }
  } catch (error) {
    thisVar.isSpinnerMoving = false;
    console.error('error in offerEngineHandler', error);
  }
  } catch (error) {
  console.error(error);
}
}
export async function generateDeviations(thisVar) {
  thisVar.isTriggerDeviationBtnClicked = true;
  if (!thisVar.camRecId) {
      thisVar.showToastMessage('warning',Message_CAM_Not_Generated_Cannot_Generate_Deviations,'warning');
  } else {
      let res = true;
      if(thisVar.offerEngineRes && !thisVar.isTractor && thisVar.isOfferEngineSuccess){
        res = await validateIRRData(thisVar,thisVar.offerEngineRes);
        if(!res){
          return;
        }
      }
      thisVar.disableViewDeviations = true;
      thisVar.isSpinnerMoving = true;
      let response;
      const irrDeviationList = await getIrrDeviationsForApprovals({ camID: thisVar.camRecId });
      if(irrDeviationList == null  || irrDeviationList.length == 0){
        try{
          response = await doFicoDeviationCallout_MTD({ loanAppId: thisVar.recordid, flag: "PR" });
      }catch(error){thisVar.isSpinnerMoving = false;thisVar.disableViewDeviations = false;thisVar.showToastMessage('Error!','FICO Deviation api failling.','error');
      }
      if (response && thisVar.isMultipleClicked == false) {
          thisVar.isMultipleClicked = true;
          response = response.replace(/\\n/g, '');
          response = JSON.parse(response);
          response = JSON.parse(response);
          // const FinalTermFields = {};
          // FinalTermFields[final_ID_FIELD.fieldApiName] = thisVarfinalTermRecordId;
          // FinalTermFields[NetLTV.fieldApiName] = response.netLTV != null ? parseFloat(response.netLTV) : null;
          // FinalTermFields[GrossLTV.fieldApiName] = response.grossltv != null ? parseFloat(response.grossltv) : null;
          //updateRecordDetails(FinalTermFields);//End CISP-2491
          await triggerDeviations({ camId: thisVar.camRecId, deviationResponse: JSON.stringify(response),fromScreen:'BeneficiaryDetails' })
              .then(obj => {
                  if (obj == 'Success') {
                      thisVar.isDisabledTriggerIRR = true;
                      thisVar.isTriggerDeviationSuccess = true;
                      thisVar.isOfferEngineDisabled = true;
                      thisVar.isPaymentMadeDisabled = true;
                      thisVar.showemidropdown = true;
                      handleDeviationClick(thisVar);
                      thisVar.disableViewDeviations = false;
                      thisVar.disablefields = false;
                      thisVar.showToastMessage('Success',Message_Deviation_Created,'Success');
                      thisVar.isSpinnerMoving = false;
                  } else {
                    thisVar.showToastMessage('error','Deviation is not Created','error');
                      thisVar.isMultipleClicked = false;
                      thisVar.disableViewDeviations = false;
                      handleDeviationClick(thisVar);
                      thisVar.isSpinnerMoving = false;
                      thisVar.disablefields = false;
                  }
              })
              .catch(error => {
                  thisVar.isMultipleClicked = false;
                  thisVar.disableViewDeviations = false;
                  console.error('error in record creation ', error);
                  thisVar.showToastMessage('error',error.body.message,'error');
                  thisVar.isSpinnerMoving = false;
              });
      }
      else{
          thisVar.isSpinnerMoving = false;
          thisVar.disableViewDeviations = false;
          thisVar.showToastMessage('error','No response from FICO Deviation API.','error');
      }
      }else{
        thisVar.isSpinnerMoving = false;
        thisVar.isPaymentMadeDisabled = true;
        thisVar.showemidropdown = true;
        handleDeviationClick(thisVar);
      }
      
  }
}

export async function calculateOnLoadFirstSecEMI(ref,paymentMadeOnDate,firstdate,seconddate) {
  ref.showemidropdown = false;
  let datelist = [];
  let x1stEMIDate2 = new Date(paymentMadeOnDate);
  let x2ndEMIDate2 = new Date(
    (x1stEMIDate2.getFullYear()),
    (x1stEMIDate2.getMonth() + 1),
  );
  if(parseInt(x1stEMIDate2.getDate()) >= parseInt(x1stPVEMIDueDate) && parseInt(x1stEMIDate2.getDate()) < parseInt(x1stPVEMIDueDatev2)){
    let firstdate = new Date(
      x1stEMIDate2.getFullYear(),
      x1stEMIDate2.getMonth(),
      parseInt(x1stPVEMIDueDatev2)
    );
    datelist.push({ label: firstdate.getDate()+'-'+(firstdate.getMonth()+1)+'-'+firstdate.getFullYear(), value: firstdate.toString() });
    let secdate = new Date(
      x2ndEMIDate2.getFullYear(),
      x2ndEMIDate2.getMonth(),
      parseInt(x1stPVEMIDueDate)
    );
    datelist.push({ label: secdate.getDate()+'-'+(secdate.getMonth()+1)+'-'+secdate.getFullYear(), value: secdate.toString()});
    let thirddate = new Date(
      x2ndEMIDate2.getFullYear(),
      x2ndEMIDate2.getMonth(),
      parseInt(x1stPVEMIDueDatev2)
    );
    datelist.push({ label: thirddate.getDate()+'-'+(thirddate.getMonth()+1)+'-'+thirddate.getFullYear(), value: thirddate.toString()});
  } else {
    let firstdateNew = new Date(
      x1stEMIDate2.getFullYear(),
      x1stEMIDate2.getMonth() + 1,
      parseInt(x1stPVEMIDueDate)
    );
    datelist.push({label: firstdateNew.getDate()+'-'+(firstdateNew.getMonth()+1)+'-'+firstdateNew.getFullYear(), value: firstdateNew.toString()});
    let secdateNew = new Date(
      x2ndEMIDate2.getFullYear(),
      x2ndEMIDate2.getMonth(),
      parseInt(x1stPVEMIDueDatev2)
    );
    datelist.push({label: secdateNew.getDate()+'-'+(secdateNew.getMonth()+1)+'-'+secdateNew.getFullYear(), value: secdateNew.toString()});
    let thirddateNew = new Date(
      x2ndEMIDate2.getFullYear(),
      x2ndEMIDate2.getMonth() + 1,
      parseInt(x1stPVEMIDueDate)
    );
    datelist.push({label: thirddateNew.getDate()+'-'+(thirddateNew.getMonth()+1)+'-'+thirddateNew.getFullYear(), value: thirddateNew.toString()});
  }
  ref.emidatelist = datelist;
  ref.fistEmiAPIValue = firstdate && firstdate.toString();
  ref.secondEmiAPIValue = seconddate && seconddate.toString();
  //thisVar.firstEMIdueDate = firstEmiVal.toString() ;
  ref.secEMIdueDate = seconddate && seconddate.getDate()+'-'+(seconddate.getMonth()+1)+'-'+seconddate.getFullYear();
  ref.firstEMIdueDate = firstdate && firstdate.getDate()+'-'+(firstdate.getMonth()+1)+'-'+firstdate.getFullYear();
}

export async function handleRevokeHelper(ref){
  ref.showRevokeModal = true;
  if (ref.showUserSelectionLookupOnRevoke) {
      ref.dispatchEvent(new ShowToastEvent({
          title: 'Warning',
          message: 'Please select the MA to whom the lead needs to be assigned as ' + ref.benCode + ' | ' + ref.benName + ' is Inactive.',
          variant: 'warning',
          mode: 'sticky'
      }));
  }
}

export async function handleRevokeConfirmHelper(ref){
  try {
    ref.showRevokeModal = false;
    ref.isSpinnerMoving = true;
    let revokeTyepVal = 'anyloaninformationchanges';
    let responseObj;
    if(ref.isD2C){
        let UNSUCCESSFUL_RESPONSE = 'D2C_APPLICATION_COULD_NOT_BE_REVOKED';
        let SUCCESSFUL_RESPONSE = 'D2C_APPLICATION_REVOKED_SUCCESSFULLY';

        await loanApplicationRevoke({ loanApplicationId : ref.recordid, revokeType : 'D2C_Revoke', newOwnerId : '' }).then(response => {
            if(response === SUCCESSFUL_RESPONSE){
                ref.showToastMessage('Application Revoked!','Your D2C Application is Revoked Succesfully','success');
                setTimeout(() => {
                    window.location.reload();
                }, 2000); 
            }else if(response === UNSUCCESSFUL_RESPONSE){
                ref.showToastMessage('Application could not be Revoked!','We faced some issue while revoking ref application','error');
            }
        });
    }else{
    await loanApplicationRevoke({ loanApplicationId : ref.recordid, revokeType : revokeTyepVal }).then(response => {
        if (response) {
            responseObj = JSON.parse(response);
              const event = new ShowToastEvent({
                title: 'Message',
                message: 'Application Revoked Successfully',
                variant: 'Success'
            });
            ref.dispatchEvent(event);
            setTimeout(() => {
              window.location.reload();
            }, 2000);
        }else{
            const event = new ShowToastEvent({
                title: 'Message',
                message: 'Application Revoke Failed',
                variant: 'Error'
            });
            ref.dispatchEvent(event);
        }
        ref.isSpinnerMoving = false;
    }).catch(error => {
        ref.isSpinnerMoving = false;
        console.error('loanApplicationRevoke ',error);
        ref.showToastMessage('Error!',error?.body?.message,'error');
    });
    }
} catch (error) {
    console.error('handleRevokeConfirm ', JSON.stringify(error));
    ref.showToastMessage('Error!',EXCEPTIONMESSAGE,'error');
}
}
export async function handleUserSelectionHelper(e,ref) {
  ref.selectedUserName = e.detail.selectedValueName;
  ref.selectedUserId = e.detail.selectedValueId;
  ref.isUserSelected = true;
}
export async function clearUserSelectionHelper(e,ref) {
  ref.selectedUserName = e.detail.selectedValueName;
  ref.selectedUserId = e.detail.selectedValueId;
  ref.isUserSelected = false;
}
export async function triggerDeviationsClickHelper(ref) {
  triggerDeviationMailHelper(ref);
}
export async function triggerDeviationMailHelper(ref) {
  triggerDeviationMail({ camId: ref.camRecId,caRemark:'',calledfrom:'BeneficiaryDetails'})
  .then(response => {
      if (response && response.length != 0) {
          let successResponse = response.length;
          let count = 0;
          let loopCount = 0;
          response.forEach(emailRequestWrapper => {
              doEmailServiceCallout({ emailService: JSON.stringify(emailRequestWrapper) }).then(result => {
                  loopCount++;
                  result = JSON.parse(result);
                  if (result && result.response && result.response.status == 'SUCCESS') {
                      count += 1;
                  }
                  if (count == successResponse) {
                      const event = new ShowToastEvent({
                        title: 'success',
                        message:Message_Deviation_Mail_Triggered,
                        variant: 'Success',
                    });
                    ref.dispatchEvent(event);
                      
                  }
                  if (loopCount == response.length) {
                      ref.showSpinner = false;
                  }
              }).catch(error => {
                  loopCount++;
                  ref.showSpinner = false;
              });
          });
      }else{
          ref.showToastWarning('There is no Team Member who have assigned Deviation Role!!!');
          ref.showSpinner = false;
      }
  }).catch((error) => {
      ref.showSpinner = false;
  });
 }
 export async function handleDeviationClick(thisVar) {
  thisVar.valuesPassedToChild.camRecId = thisVar.camRecId;
  thisVar.valuesPassedToChild.modalOpen = true;
  thisVar.valuesPassedToChild.isDeviationTriggered = false;;
  thisVar.valuesPassedToChild.iconButton = false;
  thisVar.valuesPassedToChild.isIRRDeviation = true;
  thisVar.template.querySelector("c-i-n-d-_-l-w-c-_-view-deviation").openModal();
}
 export async function calculateIRRValues(ref,finaltermObj) {
  try {
    let finalTermId = finaltermObj.Id;
    if (finalTermId) {
      //CRM IRR
      if(!ref.isPv){
          roiMaster({loanApplicationId : ref.recordid,productType : ref.loanAppProductType,tenure : parseInt(finaltermObj.Tenure__c,10),vehicleCategory : finaltermObj.Loan_Application__r.Vehicle_Type__c})
          .then(result => {let parsedData = JSON.parse(result);if(parsedData.mincrm != null && parsedData.maxcrm != null){ref.mincrm = parsedData.mincrm;ref.maxcrm = parsedData.maxcrm;}});
      }
      if(ref.isPv){
          roiMasterForImputedIRR({loanApplicationId : ref.recordid,productType : ref.loanAppProductType,tenure : parseInt(finaltermObj.Tenure__c,10),vehicleCategory : finaltermObj.Loan_Application__r.Vehicle_Type__c,queryBased:'CRM_IRR'})
          .then(result => {let parsedData = JSON.parse(result);if(parsedData.mincrm != null && parsedData.maxcrm != null){ref.mincrm = parsedData.mincrm;ref.maxcrm = parsedData.maxcrm;}});
      }
      roiMasterForImputedIRR({ loanApplicationId : ref.recordid,productType : ref.loanAppProductType,tenure : parseInt(finaltermObj.Tenure__c,10),vehicleCategory : finaltermObj.Loan_Application__r.Vehicle_Type__c ,queryBased:'NET_IRR' })
      .then(result => {
          let parsedData = JSON.parse(result); if(parsedData.mincrm != null && parsedData.maxcrm != null){ref.minImputedCrm = parsedData.mincrm;ref.maxImputedCrm = parsedData.maxcrm;}
      }).catch(error => {});
      roiMasterForGrossIRR({loanApplicationId : ref.recordid,productType : ref.loanAppProductType,productSegment:ref.productSegment,vehicleCategory : finaltermObj.Loan_Application__r.Vehicle_Type__c})    
      .then(result =>{
          let parsedData = JSON.parse(result);
          if(parsedData.mingross != null && parsedData.maxgross != null){
              ref.mingross = parsedData.mingross;//CISP-20504
              ref.maxgross = parsedData.maxgross;//CISP-20504
          }});
    }
  } catch (error) {
     console.log('calculateIRRValues error',error);
  }
}
export async function validateIRRData(ref,obj) {
  if(obj.CRM_IRR && ref.mincrm && ref.maxcrm && (parseFloat(obj.CRM_IRR) > parseFloat(ref.maxcrm) || parseFloat(obj.CRM_IRR) < parseFloat(ref.mincrm))){
    ref.isIRRValidate = false;
    let messageBasedOnProduct; //CISP-5450
    messageBasedOnProduct = 'CRM IRR is not as per norms Min '+ ref.mincrm +' and Max '+ ref.maxcrm +' . Please change payment to be made on or due date accordingly to satisfy the validation or revoke the lead to change other loan terms';
    const evt = new ShowToastEvent({
        title: "Error",
        message: messageBasedOnProduct,
        variant: 'error'
    });
    ref.dispatchEvent(evt);
    return false;
}else if(!ref.isPv && obj.Imputed_IRR_Offered && ref.minImputedCrm && ref.maxImputedCrm && (parseFloat(obj.Imputed_IRR_Offered) > parseFloat(ref.maxImputedCrm) || parseFloat(obj.Imputed_IRR_Offered) < parseFloat(ref.minImputedCrm))){
        ref.isIRRValidate = false;
        const evt = new ShowToastEvent({
            title: "Error",
            message: 'Imputed IRR is not as per norms Min '+ ref.minImputedCrm +' and Max '+ ref.maxImputedCrm +' . Please change payment to be made on or due date accordingly to satisfy the validation or revoke the lead to change other loan terms' ,
            variant: 'error'
        });
        ref.dispatchEvent(evt);
        return false;   
}else if(ref.isPv && obj.Net_IRR_Offered && ref.minImputedCrm && ref.maxImputedCrm && (parseFloat(obj.Net_IRR_Offered) > parseFloat(ref.maxImputedCrm) || parseFloat(obj.Net_IRR_Offered) < parseFloat(ref.minImputedCrm))){
    ref.isIRRValidate = false;
    const evt = new ShowToastEvent({
        title: "Error",
        message: 'Net IRR is not as per norms Min '+ ref.minImputedCrm +' and Max '+ ref.maxImputedCrm +' . Please change payment to be made on or due date accordingly to satisfy the validation or revoke the lead to change other loan terms',
        variant: 'error'
    });
    ref.dispatchEvent(evt);
    return false;
 }else if(obj.Gross_IRR_Offered!=null && ref.mingross!=null && ref.maxgross!=null && ((parseFloat(obj.Gross_IRR_Offered) < parseFloat(ref.mingross)) || (parseFloat(obj.Gross_IRR_Offered) > parseFloat(ref.maxgross)))){
  ref.isIRRValidate = false;
      const event = new ShowToastEvent({
          title: 'Error',
          message:'Gross IRR is not as per norms Min '+ ref.mingross +' and Max '+ ref.maxgross +' . Please change payment to be made on or due date accordingly to satisfy the validation or revoke the lead to change other loan terms',
          variant: 'Error',
      });
      ref.dispatchEvent(event);
      return false;
    }
    ref.isIRRValidate = true;
    return true;
}
 export async function onLoadHelper(ref,result) {
  try {
    ref.requiredLoanAmount = result?.requiredLoanAmount;
    let finaltermObj = result?.finaltermObj;
    ref.finaltermRec = finaltermObj;
    ref.serviceCharges = finaltermObj?.Service_charges__c;
    ref.docCharges = finaltermObj?.Documentation_charges__c;
    ref.crmIRR = finaltermObj?.CRM_IRR__c;
    ref.emiValue = finaltermObj?.EMI_Amount__c;
    ref.netIRR= finaltermObj?.Net_IRR__c;
    ref.grossIRR = finaltermObj?.Gross_IRR__c;
    ref.imputedIRR = finaltermObj?.Inputted_IRR__c;
    ref.installmentTypeValue = finaltermObj?.Installment_Type__c;
    ref.camNetImputtedIRR = finaltermObj?.CAM_Net_Inputted_IRR__c;
    ref.loanAppVehicleType = result.loanAppVehicleType;
    ref.loanAppProductType = result.loanAppProductType;
    ref.isPv = ref.loanAppProductType == 'Passenger Vehicles' ? true : false;
    ref.isTw = ref.loanAppProductType == 'Two Wheeler' ? true : false;
    ref.productSegment = result.productSegment;
    if(ref.isTw){//CISP-23100
      ref.irrSanctionObj = {crmIRR:parseFloat(finaltermObj?.CAM_CRM_IRR__c?.toFixed(2)),netIRR:parseFloat(finaltermObj?.CAM_NET_IRR__c?.toFixed(2)),grossIRR:parseFloat(finaltermObj?.CAM_Gross_IRR__c?.toFixed(2)),imputedIRR:parseFloat(ref?.camNetImputtedIRR?.toFixed(2))};
      console.log('ref.irrSanctionObj--',ref.irrSanctionObj);
    }else
    ref.irrSanctionObj = {crmIRR:ref.crmIRR,netIRR:ref.netIRR,grossIRR:ref.grossIRR,imputedIRR:ref.imputedIRR};
    if(ref.loanAppVehicleType == 'Refinance' && ref.loanAppProductType == 'Two Wheeler' && ref.source == null){
      ref.isTWRefinace = true;
      console.log('thisVar.totalBeneficiaryAmount --' ,ref.serviceCharges,'  ', ref.docCharges)
      ref.calculateTotalBeneficiaryAmount()
  }
  //SFTRAC-2291 Start
  if(ref.installmentTypeValue == 'Structured'){
    ref.isStructured = true;
    if(finaltermObj.Last_Offer_Engine_Equat__c == true && finaltermObj.Last_Offer_Engine_Struct__c == true){
      ref.isAllowPACTAPI = true;
    }
  }else if(ref.installmentTypeValue == 'Equated'){
    if(finaltermObj.Last_Offer_Engine_Equat__c == true){
      ref.isAllowPACTAPI = true;
    }
  }//SFTRAC-2291 End
    if(ref.loanAppProductType.toLowerCase() === 'tractor'){
        ref.totalFundedPremium = finaltermObj?.Vehicle_Detail__r?.Total_Funded_Amount__c ? finaltermObj?.Vehicle_Detail__r?.Total_Funded_Amount__c : 0; //SFTRAC-2291
        ref.isTractor = true;
        //SFTRAC-1896 start
        ref.tfCRMIRR = finaltermObj.CRM_IRR__c;
        ref.tfGrossRR = finaltermObj.Gross_IRR__c;
        ref.tfNetRR = finaltermObj.Net_IRR__c;
        //ref.isPACTGenerated = result.isPACTGenerated; //SFTRAC-2313
        //SFTRAC-2313 start
        console.log('++++++result.isPACTGenerated '+result.isPACTGenerated);
        console.log('++++++result.isAllowPACTAPI '+ref.isAllowPACTAPI);
        if(result.isPACTGenerated == true){
          ref.isAllowPACTAPI = true;
        }else{
          ref.isAllowPACTAPI = false;
        }//SFTRAC-2313 end
        await roiMasterTractor({'loanApplicationId' : ref.recordid}).then((result)=>{
          if(result){
            ref.tfmaxcrm = result.CRM_IRR_MAX;
            ref.tfmincrm = result.CRM_IRR_MIN;
            ref.minGROSSIRR = result.GROSS_IRR_MIN;
            ref.maxGROSSIRR = result.GROSS_IRR_MAX;
            ref.isNonIndividual = result.isNonIndividual;
          }
        }).catch((error)=>console.log("Error in", "roiMasterTractor", error));
        //SFTRAC-1896 end
    } 
    let firstdate = new Date(finaltermObj?.First_EMI_Date__c);
    firstdate = new Date(firstdate.getFullYear(),firstdate.getMonth(),firstdate.getDate());
    let seconddate = new Date(finaltermObj?.Second_EMI_Date__c);
    let loanDealDate = new Date(finaltermObj?.Loan_Deal_Date__c);
    seconddate = new Date(seconddate.getFullYear(),seconddate.getMonth(),seconddate.getDate());
    ref.emidatelist.push({label: firstdate.getDate()+'-'+(firstdate.getMonth()+1)+'-'+firstdate.getFullYear(), value: firstdate.toString()});
    if(!ref.finaltermRec?.Advance_EMI__c && ref.isPv){
      await calculateOnLoadFirstSecEMI(ref,finaltermObj?.Loan_Deal_Date__c,firstdate,seconddate);
    }
    //SFTRAC-1896 start
    if(ref.isTractor){
      ref.tfloanDealDate = finaltermObj?.Loan_Deal_Date__c;
      ref.tffirstEMIdueDate = finaltermObj?.First_EMI_Date__c;
      ref.tfsecEMIdueDate = finaltermObj?.Second_EMI_Date__c;
    }
    //SFTRAC-1896 end
    ref.fistEmiAPIValue = firstdate.toString();
    ref.secondEmiAPIValue = seconddate.toString();
    ref.paymentMadeOnValue = finaltermObj?.Loan_Deal_Date__c;
    ref.firstDueDate = finaltermObj?.First_EMI_Date__c;
    ref.secondDueDate = finaltermObj?.Second_EMI_Date__c;
    ref.firstEMIdueDate = firstdate && firstdate.toString();
    ref.secEMIdueDate = seconddate && seconddate.getDate()+'-'+(seconddate.getMonth()+1)+'-'+seconddate.getFullYear();
    ref.loanDealDate =finaltermObj?.Loan_Deal_Date__c;
    //CISP-20786 start
    if(!ref.isTractor){calculateIRRValues(ref,finaltermObj);}
    if (ref.loanAppVehicleType.toLowerCase() === 'new' && ref.loanAppProductType.toLowerCase() === 'tractor' && result.loanAppApplicationType.toLowerCase() === 'Build Body and Chassis Funding'.toLowerCase()) {
        ref.showBodyChassisInfo = true;
    }
    ref.vehicleRecordId = result.vehicleRecordId;//CISP-8762
    ref.finalTermRecordId = result.finalTermRecordId;//CISP-8762
    ref.rcLimitDealerName = result?.dealerName + '|' + result?.dealerBenCode;//CISP-8762
    ref.ihmRecoveryAmount = result.ihmRecoveryAmount;
    ref.financeAmount = result.financeAmount;
    //CISP-8762 start
    ref.financeAmountForRcLimit = result.financeAmountForRcLimit;
    ref.continueWithRCLimitForDSA = result.rcLimitClearedForDSA;
    ref.continueWithRCLimit = result.rcLimitClearedForDealer;
    //CISP-8762 changes end
    ref.ihmPaidToDealer = result.totalIHMPaidToDealer == undefined ? 0 : result.totalIHMPaidToDealer;
  //   await getIrrDeviationsForApprovals({camID: ref.camRecId}).then((res)=>{
  //     if(res && res.length > 0) {
  //       ref.isIrrDevNotApproved = true;
  //       ref.isPaymentMadeDisabled = true;
  //       ref.showemidropdown = true;
  //       ref.isOfferEngineDisabled = true;
  //       ref.isInstallmentScBtnShown = false;
  //       ref.openIRRDeviation = true; //CISP-22153
  //       ref.valuesPassedToChild.camRecId = ref.camRecId;//CISP-22153
  //       ref.valuesPassedToChild.isViewIrrOpen = true;//CISP-22153
  //       ref.valuesPassedToChild.isDeviationTriggered = false;//CISP-22153
  //       ref.valuesPassedToChild.iconButton = false;//CISP-22153
  //       ref.valuesPassedToChild.isIRRDeviation = true;//CISP-22153
  //       ref.template.querySelector("c-i-n-d-_-l-w-c-_-view-deviation").openIRRModal();//CISP-22153
  //     }
  //  });
    // await isUserSelectionLookupRequiredOnRevoke({ loanApplicationId: ref.recordid })
    //       .then(response => {
    //         //ref.showUserSelectionLookupOnRevoke = true;// TESTING
    //           let result = JSON.parse(response);
    //           if (result.isUserSelectionNeeded) {
    //               ref.showUserSelectionLookupOnRevoke = true;
    //               ref.benCode = result.benCode;
    //               ref.benName = result.benName;
    //               ref.revokeData.branchAccountId = result.branchAccountId;
    //           } else if(result?.ph1TWRevokeErr) {
    //               ref.ph1TWRevokeErr = result.ph1TWRevokeErr;
    //           }
    //       })
    //       .catch(error => {
    //           console.log('isUserSelectionLookupRequiredOnRevoke error:: ', error);
    //       });
  } catch (error) {
    console.error('error',error);
  }
 }
export async function submitValidationChecks(ref) {
  let validateIrrDataRes = true;
  if(ref.isOfferEngineSuccess){
    validateIrrDataRes = await validateIRRData(ref,ref.offerEngineRes);
    if(!validateIrrDataRes){
      return false;
    }
  }
  // await handleSFCalculationHelper(ref);
  let resultData;
    try {
      let result = await allIrrDeviationApproved({camId:ref.camRecId,loanApplicationId:ref.recordid});
      resultData = JSON.parse(result);
    } catch (error) {
       const event = new ShowToastEvent({
        title: 'Error',
        message:error,
        variant: 'Error',
    });
        ref.dispatchEvent(event);
        return false;
    }
  if(!ref.isIrrDevNotApproved && !ref.isOfferEngineClicked){
    const event = new ShowToastEvent({
      title: 'Error',
      message:'Please Trigger Offer Engine first.',
      variant: 'Error',
     });
      ref.dispatchEvent(event);
      return false;
  }else if(!ref.isIrrDevNotApproved && ref.isPaymentEMIChanged && !ref.isOfferEngineClicked){
        const event = new ShowToastEvent({
          title: 'Error',
          message:'Please Trigger Offer Engine first.',
          variant: 'Error',
      });
          ref.dispatchEvent(event);
          return false;
   }else if (!ref.isIrrDevNotApproved && !ref.isOfferEngineSuccess){
      const event = new ShowToastEvent({
        title: 'Error',
        message:'Offer Engine Failed. Please Re trigger Offer Engine.',
        variant: 'Error',
    });
    ref.dispatchEvent(event);
        return false;
   }else if ((!ref.isIrrDevNotApproved && ref.isOfferEngineSuccess && !ref.isInsSubmitted) || (ref.isIrrDevNotApproved && !ref.isInsSubmitted)){
    const event = new ShowToastEvent({
      title: 'Error',
      message:'Submit Installment Schedule first.',
      variant: 'Error',
  });
  ref.dispatchEvent(event);
      return false;
 }else if ((!ref.isIrrDevNotApproved && ref.isOfferEngineSuccess && !validateIrrDataRes) || (ref.isIrrDevNotApproved && !validateIrrDataRes)){
      const event = new ShowToastEvent({
        title: 'Error',
        message:'IRR is not in terms. Please Validate IRR.',
        variant: 'Error',
    });
    ref.dispatchEvent(event);
        return false;
   }else if (resultData && resultData.isSuccess =='true'){
    let message = 'IRR Deviation triggered to ' + resultData.userName + ' - ' +  resultData.role +' is pending for approval. Please get the deviation approved and click on Submit button';
const event = new ShowToastEvent({
  title: 'Error',
  message: message,
  variant: 'Error',
});
ref.dispatchEvent(event);

      return false;
 }
 if(!ref.isRevokedDisabled){
  return false;
 }else{
   return true;
 }
}
async function callOfferEngineContinue(offerEngineParams,thisVar,offerEngineMethod,isOpen){
  await offerEngineMethod(offerEngineParams)
  .then(result => {
      thisVar.isSpinnerMoving = false;
      const obj = (thisVar.source === 'D2C' || thisVar.source === 'Hero') ? getParsedJSOND2C(JSON.parse(result)) : JSON.parse(result);
          if (obj != null && obj.status != 'FAILED') {
            thisVar.disablefields = false;
              thisVar.showToastMessage('Success',Message_Offer_Engine_Success,'Success');
                  getFinalTermId({
                          loanAppId: thisVar.recordid
                      })
                      .then(finalTermId => {
                          thisVar.isPaymentEMIChanged = false;
                          thisVar.offerEngineRes = obj;
                          thisVar.isIRRValidate = false;
                          thisVar.isIrrComparisionDesaibled = false;
                          thisVar.isOfferEngineSuccess = true;
                          thisVar.isTriggerDeviationSuccess = false;
                          thisVar.isTriggerDeviationBtnClicked = false;
                          thisVar.isInsSubmitted = false;
                          thisVar.isSfAmortDataSaved = false;
                          if(obj.Final_CRM_IRR){
                            thisVar.finalCRMIRR = obj.Final_CRM_IRR;
                          }
                          let finCRMIRR; let finalNetIrr; let finalGrossIRR; let finalImputtedIRR;
                          if(thisVar.finalCRMIRR){finCRMIRR = parseFloat(thisVar.finalCRMIRR).toFixed(2);}//CISP-23272
                          if(obj.Net_IRR_Offered){finalNetIrr = parseFloat(obj.Net_IRR_Offered).toFixed(2);}//CISP-23272
                          if(obj.Gross_IRR_Offered){finalGrossIRR = parseFloat(obj.Gross_IRR_Offered).toFixed(2);}//CISP-23272
                          if(obj.Imputed_IRR_Offered){finalImputtedIRR = parseFloat(obj.Imputed_IRR_Offered).toFixed(2);}//CISP-23272
                          if(thisVar.isTw){//CISP-23272
                            thisVar.irrOfferEngineObj = {crmIRR:finCRMIRR,netIRR:finalNetIrr,grossIRR:finalGrossIRR,imputedIRR:finalImputtedIRR};
                          }else
                          thisVar.irrOfferEngineObj = {crmIRR:thisVar.finalCRMIRR,netIRR:obj.Net_IRR_Offered,grossIRR:obj.Gross_IRR_Offered,imputedIRR:obj.Imputed_IRR_Offered};
                          console.log('thisVar.irrOfferEngineObj ***',thisVar.irrOfferEngineObj);
                          thisVar.irrComBtnClicked = isOpen;
                          if(obj.EMI){
                            thisVar.emiValue = obj.EMI;
                          }
                          const FinalTermFields = {};
                          FinalTermFields[final_ID_FIELD.fieldApiName] = finalTermId;
                          FinalTermFields[EMI_Amount.fieldApiName] = parseFloat(obj.EMI);
                          if(obj.CRM_IRR){
                            thisVar.crmIRR = obj.CRM_IRR;
                            FinalTermFields[CRM_IRR.fieldApiName] = parseFloat(obj.CRM_IRR);
                          }
                          if(obj.Imputed_IRR_Offered) {
                              FinalTermFields[Inputted_IRR.fieldApiName] = parseFloat(obj.Imputed_IRR_Offered);
                              if(thisVar.isTw){
                                let camimpIrr = parseFloat(thisVar.camNetImputtedIRR);
                                let impIRR = parseFloat(obj.Imputed_IRR_Offered);
                                if(camimpIrr != impIRR){
                                  thisVar.isDisabledTriggerIRR = false;
                                }
                              }
                              thisVar.imputedIRR = obj.Imputed_IRR_Offered;
                          }
                          if(obj.Gross_IRR_Offered) { 
                            thisVar.grossIRR = obj.Gross_IRR_Offered;
                            FinalTermFields[Gross_IRR.fieldApiName] = parseFloat(obj.Gross_IRR_Offered);
                          }
                          if(obj.Net_IRR_Offered) { 
                            FinalTermFields[Net_IRR.fieldApiName] = parseFloat(obj.Net_IRR_Offered);
                            if(thisVar.isPv){
                                let camNetIrr = parseFloat(thisVar.camNetImputtedIRR);
                                let netIRR = parseFloat(obj.Net_IRR_Offered);
                                if(netIRR != camNetIrr){
                                  thisVar.isDisabledTriggerIRR = false;
                                }
                            }
                            thisVar.netIRR= obj.Net_IRR_Offered;
                          }
                          if(obj.amortizationSchedule){
                          saveInstallmentSchedule({ loanId: thisVar.recordid, response: JSON.stringify(obj.amortizationSchedule), installmentType: thisVar.installmentTypeValue}).then(result => {thisVar.isInstallmentScBtnShown = false;}).catch(error => {thisVar.isInstallmentScBtnShown = true;});
                        }
                          const recordInput = { fields:FinalTermFields,};
                          updateRecord(recordInput).then(() => {}).catch((error) => {console.error('updateRecord ',error);});
                      }).catch(error => {thisVar.isOfferEngineSuccess = false;console.error('error in Offer Engine', error);});
          }else {thisVar.showToastMessage('Error','Offer Engine API has failed. Please re-trigger Offer Engine','Error');} 
  }).catch(error => {
    thisVar.isOfferEngineSuccess = false;
    thisVar.isSpinnerMoving = false;
    console.error('error in Offer Engine', error);thisVar.showToastMessage('Error','Offer Engine API has failed. Please re-trigger Offer Engine','Error');
  });
}
export function getParsedJSOND2C(parsedJSON) {
  let obj = {};
  obj.EMI = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.displayEMI;
  obj.CRM_IRR = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.displayCrmIrr;
  obj.CRM_IRR = obj.CRM_IRR != null ? obj.CRM_IRR.toString() : '';
  obj.Imputed_IRR_Offered = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.displayImputedIrr;
  obj.Net_IRR_Offered = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.netIrr;
  obj.Gross_IRR_Offered = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.grossIrr;    
  return obj; 
}
export async function handleLoanDateCalHelper(thisVar){
  try {
    //thisVar.tfloanDealDate = evt.target.value;
    const currentDate = new Date();
    currentDate.setHours(0, 0, 0, 0);
    const userDate = new Date(thisVar.tfloanDealDate);
    userDate.setHours(0, 0, 0, 0);
    if ((thisVar.tfloanDealDate !== thisVar.invoiceTaxDate) && (userDate < currentDate)) {
        thisVar.isTFPaymentMadeOnInvalid = true;
        thisVar.showToastMessage('error', 'Payment date should be same as invoice tax date or today date or future date', 'error');
    } else {
        thisVar.isTFPaymentMadeOnInvalid = false;
        calculateTFFirstSecEMI(thisVar.tfloanDealDate, thisVar);
    }
  } catch (error) {
      console.error(error);
  }
}

export async function calculateTFFirstSecEMI(tfloanDealDate,thisVar) {
  const X1stDate = new Date(tfloanDealDate);
  console.log('++++finalTermRecordId '+thisVar.finalTermRecordId);
  let updatedFinalTermData = await getFinalTermsRecord({finalTermId : thisVar.finalTermRecordId});
  thisVar.finaltermTFRec = (updatedFinalTermData);
  console.log('++++finaltermTFRec '+JSON.stringify(thisVar.finaltermTFRec));
  const firstRecord = thisVar.finaltermTFRec[0];
  console.log('Advance EMI:', firstRecord?.Advance_EMI__c);
  console.log('++++Advance_EMI__c '+firstRecord?.Advance_EMI__c +' Holiday_period__c '+firstRecord?.Holiday_period__c+' Installment_Frequency__c '+firstRecord?.Installment_Frequency__c); 
  
  if(firstRecord?.Advance_EMI__c == false){
    const monthsToAdd = firstRecord.Holiday_period__c ? parseInt(firstRecord.Holiday_period__c)/30 : 0;
    thisVar.tffirstEMIdueDate = new Date(X1stDate.getFullYear(),(X1stDate.getMonth() + monthsToAdd),);
    const targetFirstDate =  X1stDate.getDate() <= 15 ? 7 : 15;
    let firstEMI = new Date(thisVar.tffirstEMIdueDate.getFullYear() , (thisVar.tffirstEMIdueDate.getMonth()) , parseInt(targetFirstDate))
    thisVar.tffirstEMIdueDate = firstEMI.getFullYear() + '-' + ('0' + (firstEMI.getMonth() + 1)).slice(-2) + '-' +  ('0' + firstEMI.getDate()).slice(-2);
  }else{
    thisVar.tffirstEMIdueDate = thisVar.tfloanDealDate;
  }

    thisVar.tfsecEMIdueDate = new Date(thisVar.tffirstEMIdueDate);
    if (firstRecord.Installment_Frequency__c === 'Monthly') {
        thisVar.tfsecEMIdueDate = new Date(thisVar.tfsecEMIdueDate.getFullYear(),(thisVar.tfsecEMIdueDate.getMonth() + 1),);
        const targetSecondDate =  X1stDate.getDate() <= 15 ? 7 : 15;
        let seccondEMI = new Date(thisVar.tfsecEMIdueDate.getFullYear() , (thisVar.tfsecEMIdueDate.getMonth()) , parseInt(targetSecondDate))
        thisVar.tfsecEMIdueDate = seccondEMI.getFullYear() + '-' + ('0' + (seccondEMI.getMonth() + 1)).slice(-2) + '-' + ('0' + seccondEMI.getDate()).slice(-2);   
    } else if (firstRecord.Installment_Frequency__c === 'bi-monthly') {
        thisVar.tfsecEMIdueDate = new Date(thisVar.tfsecEMIdueDate.getFullYear(),(thisVar.tfsecEMIdueDate.getMonth() + 2),);
        const targetSecondDate =  X1stDate.getDate() <= 15 ? 7 : 15;
        let seccondEMI = new Date(thisVar.tfsecEMIdueDate.getFullYear() , (thisVar.tfsecEMIdueDate.getMonth()) , parseInt(targetSecondDate))
        thisVar.tfsecEMIdueDate = seccondEMI.getFullYear() + '-' + ('0' + (seccondEMI.getMonth() + 1)).slice(-2) + '-' + ('0' + seccondEMI.getDate()).slice(-2);  
    } else if (firstRecord.Installment_Frequency__c === 'Quarterly') {
      thisVar.tfsecEMIdueDate = new Date(thisVar.tfsecEMIdueDate.getFullYear(),(thisVar.tfsecEMIdueDate.getMonth() + 3),);
        const targetSecondDate =  X1stDate.getDate() <= 15 ? 7 : 15;
        let seccondEMI = new Date(thisVar.tfsecEMIdueDate.getFullYear() , (thisVar.tfsecEMIdueDate.getMonth()) , parseInt(targetSecondDate))
        thisVar.tfsecEMIdueDate = seccondEMI.getFullYear() + '-' + ('0' + (seccondEMI.getMonth() + 1)).slice(-2) + '-' + ('0' + seccondEMI.getDate()).slice(-2);  
    } else if (firstRecord.Installment_Frequency__c === 'Half yearly') {
        thisVar.tfsecEMIdueDate = new Date(thisVar.tfsecEMIdueDate.getFullYear(),(thisVar.tfsecEMIdueDate.getMonth() + 6),);
        const targetSecondDate =  X1stDate.getDate() <= 15 ? 7 : 15;
        let seccondEMI = new Date(thisVar.tfsecEMIdueDate.getFullYear() , (thisVar.tfsecEMIdueDate.getMonth()) , parseInt(targetSecondDate))
        thisVar.tfsecEMIdueDate = seccondEMI.getFullYear() + '-' + ('0' + (seccondEMI.getMonth() + 1)).slice(-2) + '-' + ('0' + seccondEMI.getDate()).slice(-2);
    }
  
}

export async function handleChangeHelper(event,thisVar){
  let selectedName = event.target.name;
      if(selectedName ==='RedoFI'){
           thisVar.isModalOpen = false;
           let result = await thisVar.updateCaseAndFI();
           if(result === true){
              thisVar.showToastMessage('success','FI case assigned successfully','success');
           }else if(result === false){
              thisVar.showToastMessage('error','Error while FI case assign','error');
           }else if(result === 'Opportunity Team member is not found'){
              thisVar.showToastMessage('error','Opportunity Team member is not found','error');
           }
      }else if(selectedName ==='createNewLoanFI'){
          thisVar.showToastMessage('Create new Loan application','Please withdrawn current loan application and create new loan application','info');
          thisVar.isModalOpen = false;
      }else if(selectedName === 'camApproval'){
          //thisVar.updateCamApprovalDate();
          thisVar.isReapprovalOfCam = true;
      }else if(selectedName === 'createNewLoanCAM'){
          thisVar.isReapprovalOfCam = false;
          thisVar.showToastMessage('Create new Loan application','Please withdrawn current loan application and create new loan application','info');
          thisVar.isModalOpen = false;
      }else if(selectedName === 'createNewLoanCIBIL'){
          thisVar.showToastMessage('Create new Loan application','Please withdrawn current loan application and create new loan application','info');
          thisVar.isModalOpen = false;
      }else if(selectedName === 'AssetVerification'){
          thisVar.updateAssetVerification();
      }else if(selectedName === 'createNewLoanAssetVer'){
          thisVar.showToastMessage('Create new Loan application','Please withdrawn current loan application and create new loan application','info');
          thisVar.isModalOpen = false;
      }
      else{
          let applicantId = event.target.dataset.id;
          thisVar.isModalOpen = false;
          getCIBILReport(applicantId,thisVar);
      }
}
export async function getCIBILReport(applicantId,ref) {
  try {
  ref.isSpinnerMoving = true;
  let filteredRecord = ref.applicantCibilRecordList?.find( o => o.applicantId === applicantId);
  let cibilRecordId = filteredRecord?.cibilRecord?.Id;
  let cibilRequest = {
      applicantId: applicantId,
      loanApplicationId: ref.recordid
  }
      doCIBILReportCallout({ cibilRequestString: JSON.stringify(cibilRequest) })
          .then(res => {                   
              const result = JSON.parse(res);
              const cibilFields = {};
              if (result.Data && result.Data.StatusCode ==200 && (result.Data.Application_Cibil_Details).length) {
                  cibilFields[AMOUNT_OVERDUE_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].Amount_Overdue;
                  cibilFields[CIBIL_DECISION_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].CibilDecision;
                  cibilFields[CIC_NO_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].CIC_No;
                  cibilFields[CRIF_SCORE_DESC_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].CRIFScore_Desc;
                  cibilFields[CURRENT_BALANCE_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].Current_Balance;
                  cibilFields[ENTITY_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].Entity_Type;
                  cibilFields[HIGHCREDIT_OR_SANCTIONEDAMOUNT_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].HighCredit_Or_SanctionedAmount;
                  cibilFields[MONTH_OVERDUE_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].Month_Overdue;
                  cibilFields[NOOFENLTSIXMON_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].NoOfEnLtSixMon;
                  if(result.Data.Application_Cibil_Details[0].OldestDate){
                      cibilFields[OLDEST_DATE_FIELD.fieldApiName] = new Date(Date.parse(result.Data.Application_Cibil_Details[0].OldestDate));
                  }
                  if(result.Data.Application_Cibil_Details[0].RecentDate){
                      cibilFields[RECENT_DATE_FIELD.fieldApiName] = new Date(Date.parse(result.Data.Application_Cibil_Details[0].RecentDate));
                  }
                  cibilFields[SCORE_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].Score;
                  cibilFields[SUITFILEDORWILFULDEFAULT_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].SuitFiledOrWilfulDefault;
                  cibilFields[TYPE_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].Type;
                  cibilFields[WRITTENOFFAMOUNTTOTAL_FIELD.fieldApiName] = result.Data.Application_Cibil_Details[0].WrittenoffAmountTotal;
                  
                  if((result.Data.Cibil_LoanAccount_Details).length){
                      if((result.Data.Cibil_LoanAccount_Details[0].Maker_Date != null) || (result.Data.Cibil_LoanAccount_Details[0].Maker_Date != undefined) || (result.Data.Cibil_LoanAccount_Details[0].Maker_Date != '')){
                          let makerDate =  result.Data.Cibil_LoanAccount_Details[0].Maker_Date;
                          let makerDateConversion = makerDate.substring(0, makerDate.lastIndexOf(' '));
                          cibilFields[CIBIL_MAKER_DATE.fieldApiName] = ((result.Data.Cibil_LoanAccount_Details).length) ? makerDateConversion.split("-").reverse().join("-") : '';
                    }
                  }
                  
                  if (result.Data.Equifax_Report_URl) {
                      cibilFields[EQUIFAX_REPORT_URL_FIELD.fieldApiName] = result.Data.Equifax_Report_URl + '/?CIC_No=' + result.Data.Application_Cibil_Details[0].CIC_No;
                  }
                  if (result.Data.Cibil_Report_URl) {
                      cibilFields[CIBIL_REPORT_URI_FIELD.fieldApiName] = result.Data.Cibil_Report_URl + '/?CIC_No=' + result.Data.Application_Cibil_Details[0].CIC_No;
                  }
                  if (cibilRecordId) {
                    cibilFields[CIBIL_RECORD_DETAILS_ID.fieldApiName] = cibilRecordId;
                    cibilFields[CIBIL_PULL_DATE.fieldApiName] = new Date().toISOString();
                    ref.updateRecordDetails(cibilFields);
                  }
                  const applicantsFields = {};
                  applicantsFields[APP_ID_FIELD.fieldApiName] = applicantId;
                  applicantsFields[Bureau_Pull_Match__c.fieldApiName] = result.Data.IsSuccess === 'True' ? true: false;
                  applicantsFields[Bureau_Pull_Message__c.fieldApiName] = result.Data.StatusDescription;
                  ref.updateRecordDetails(applicantsFields);
                  ref.showToastMessage('success','CIBIL pulled successfully !','success');
              }else{
                const evt = new ShowToastEvent({
                  title: 'Error',
                  message: 'CIBIL API has failed!',
                  variant: 'error',
                });
                ref.dispatchEvent(evt);
              }
              ref.isSpinnerMoving = false;
          })
          .catch(error => {
              ref.showToast(Kindly_Retry, 'warning');
              ref.isSpinnerMoving = false;
              const bureauPullMessage = error.body.message;
              const evt = new ShowToastEvent({
                  title: 'Error',
                  message: error.body.message,
                  variant: 'error',
              });
              ref.dispatchEvent(evt);
              let applicantsFields ={};
              applicantsFields[APP_ID_FIELD.fieldApiName] = applicantId;
              applicantsFields[Bureau_Pull_Match__c.fieldApiName] = false;
              applicantsFields[Bureau_Pull_Message__c.fieldApiName] = bureauPullMessage;
              ref.updateRecordDetails(applicantsFields);
          });
  } catch (error) {
       console.log('## error: ',error);   
  }
}