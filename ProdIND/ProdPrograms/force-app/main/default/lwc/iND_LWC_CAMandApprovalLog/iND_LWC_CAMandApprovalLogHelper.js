import doProductivityCallout from '@salesforce/apexContinuation/IntegrationEngine.doProductivityCallout';
import doWeightedIRRCallout from '@salesforce/apexContinuation/IntegrationEngine.doWeightedIRRCallout';
import doAPDPendingCallout from '@salesforce/apexContinuation/IntegrationEngine.doAPDPendingCallout';
import doCAMPortfolioCallout from '@salesforce/apexContinuation/IntegrationEngine.doCAMPortfolioCallout';
import storingExternalCAMData from '@salesforce/apex/ExternalCAMDataController.storingExternalCAMData';
import checkInsuranceSubmitted from '@salesforce/apex/CAMApprovalLogController.checkInsuranceSubmitted';
import cam_ID_FIELD from '@salesforce/schema/CAM__c.Id';
import Productivity from '@salesforce/schema/CAM__c.Productivity_YTD__c';
import Weighted_IRR from '@salesforce/schema/CAM__c.Weighted_IRR_YTD__c';
import { updateRecord } from 'lightning/uiRecordApi';
import Message_Forward_CAM_To_SCM from '@salesforce/label/c.Message_Forward_CAM_To_SCM';
import Message_CAM_Not_Generated_Cannot_Forward_to_SCM from '@salesforce/label/c.Message_CAM_Not_Generated_Cannot_Forward_to_SCM';
import Message_No_TeamMember_found_with_role_SCM from '@salesforce/label/c.Message_No_TeamMember_found_with_role_SCM';
import Message_CAM_Not_Generated_Cannot_Forward_to_CCT from '@salesforce/label/c.Message_CAM_Not_Generated_Cannot_Forward_to_CCT';
import Message_No_TeamMember_found_with_role_CA from '@salesforce/label/c.Message_No_TeamMember_found_with_role_CA';
import Message_CAM_Not_Generated_Cannot_Generate_Deviations from '@salesforce/label/c.Message_CAM_Not_Generated_Cannot_Generate_Deviations';
import Message_Deviation_Created from '@salesforce/label/c.Message_Deviation_Created';
import Message_Generate_Deviation_First from '@salesforce/label/c.Message_Generate_Deviation_First';
import Message_remark from '@salesforce/label/c.Message_remark';
import Message_ForwardTo_Role from '@salesforce/label/c.Message_ForwardTo_Role';
import Message_Deviation_Mail_Triggered from '@salesforce/label/c.Message_Deviation_Mail_Triggered';
import Message_ApprovalLogs_Updated from '@salesforce/label/c.Message_ApprovalLogs_Updated';
import CRM_IRR_Not_As_Per_Norms from '@salesforce/label/c.CRM_IRR_Not_As_Per_Norms';
import Message_Offer_Engine_Success from '@salesforce/label/c.Message_Offer_Engine_Success';
import Message_Offer_Engine_Failure from '@salesforce/label/c.Message_Offer_Engine_Failure';
import Message_CAM_Generated from '@salesforce/label/c.Message_CAM_Generated';
import Message_Record_Created from '@salesforce/label/c.Message_Record_Created';
import Message_CAM_Not_Generated_Cannot_View_Deviations from '@salesforce/label/c.Message_CAM_Not_Generated_Cannot_View_Deviations';
import doInsurancePremiumCallout from '@salesforce/apexContinuation/IntegrationEngine.doInsurancePremiumCallout';//CISP-4490
import doFicoDeviationCalloutTractor from '@salesforce/apexContinuation/IntegrationEngine.doFicoDeviationCalloutTractor';
import getDeviationsForApprovalsTractor from '@salesforce/apex/CAMApprovalLogController.getDeviationsForApprovalsTractor';
import tractorOfferEngineCallout from '@salesforce/apex/IntegrationEngine.tractorOfferEngine';
import saveInstallmentScheduleTractor from '@salesforce/apex/InstallmentScheduleController.saveInstallmentScheduleTractor';
import getFinalTerms from '@salesforce/apex/CAMApprovalLogController.getFinalTerms';
import updateLoanApplication_MTD from '@salesforce/apex/CAMApprovalLogController.updateLoanApplication';
import roiMasterTractor from '@salesforce/apex/IND_OfferScreenController.roiMasterTractor';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import final_ID_FIELD from '@salesforce/schema/Final_Term__c.Id';

import OfferengineMinLoanAmount from '@salesforce/schema/Final_Term__c.OfferengineMinLoanAmount__c'; //SFTRAC-126
import OfferengineMaxLoanAmount from '@salesforce/schema/Final_Term__c.OfferengineMaxLoanAmount__c'; //SFTRAC-126
import Loan_Amount from '@salesforce/schema/Final_Term__c.Loan_Amount__c'; //SFTRAC-126
import OfferengineMinTenure from '@salesforce/schema/Final_Term__c.OfferengineMinTenure__c'; //SFTRAC-126
import OfferengineMaxTenure from '@salesforce/schema/Final_Term__c.OfferengineMaxTenure__c'; //SFTRAC-126
import Tenure from '@salesforce/schema/Final_Term__c.Tenure__c'; //SFTRAC-126
import EMI_Amount from '@salesforce/schema/Final_Term__c.EMI_Amount__c'; //SFTRAC-126
import Required_CRM_IRR from '@salesforce/schema/Final_Term__c.Required_CRM_IRR__c'; //SFTRAC-126
import CRM_IRR from '@salesforce/schema/Final_Term__c.CRM_IRR__c'; //SFTRAC-126
import Net_IRR from '@salesforce/schema/Final_Term__c.Net_IRR__c'; //SFTRAC-126
import Gross_IRR from '@salesforce/schema/Final_Term__c.Gross_IRR__c'; //SFTRAC-126
import Bank_IRR from '@salesforce/schema/Final_Term__c.Bank_IRR__c'; //SFTRAC-126
import Offer_Agreement_Amount from '@salesforce/schema/Final_Term__c.Offer_Agreement_Amount__c'; //SFTRAC-126
import x1stPVEMIDueDate from "@salesforce/label/c.x1stPVEMIDueDate"; // CISP-16789
import x1stPVEMIDueDatev2 from "@salesforce/label/c.x1stPVEMIDueDatev2"; // CISP-16789
import x21EMIDueDate from "@salesforce/label/c.x21EMIDueDate";
import x1stTWEMIDueDate from "@salesforce/label/c.x1stTWEMIDueDate";
import saveInstallmentSchedule from '@salesforce/apex/InstallmentScheduleController.saveInstallmentSchedule';
import First_EMI_Date from '@salesforce/schema/Final_Term__c.First_EMI_Date__c';
import Second_EMI_Date from '@salesforce/schema/Final_Term__c.Second_EMI_Date__c';
import updateJourneyStop from '@salesforce/apex/customerDedupeRevisedClass.updateJourneyStop'; //CISP-4459
import { createRecord } from 'lightning/uiRecordApi';
import Proposal_Approval_Log__c from '@salesforce/schema/Proposal_Approval_Log__c';
import HoldRmrk from '@salesforce/schema/Proposal_Approval_Log__c.Hold_Remark__c';
import ParentCAM from '@salesforce/schema/Proposal_Approval_Log__c.Parent_CAM__c';
import Decision from '@salesforce/schema/Proposal_Approval_Log__c.Decision__c';
import Remark__c from '@salesforce/schema/Proposal_Approval_Log__c.Proposal_Remark__c';//CISP-2332
import Role__c from '@salesforce/schema/Proposal_Approval_Log__c.Role__c';
import Approval_Status__c from '@salesforce/schema/Proposal_Approval_Log__c.Approval_Status__c';
import SF_Role__c from '@salesforce/schema/Proposal_Approval_Log__c.SF_Role__c';
import Vehicle_ID__c from '@salesforce/schema/Proposal_Approval_Log__c.Vehicle_ID__c';
import Loan_Ammount__c from '@salesforce/schema/Proposal_Approval_Log__c.Loan_Ammount__c';
import Submitted_By_BE_CVO__c from '@salesforce/schema/Proposal_Approval_Log__c.Submitted_By_BE_CVO__c';
import getRecentEMIdetails from '@salesforce/apex/InstallmentScheduleController.getRecentEMIdetails';
import calculateFinalTermLTVCalculations from '@salesforce/apex/CAMApprovalLogController.calculateFinalTermLTVCalculations';
import getFinalTermId from '@salesforce/apex/CAMApprovalLogController.getFinalTermId';
import getFinalTermCalculations from '@salesforce/apex/CAMApprovalLogController.getFinalTermCalculations';
import Table_Code from '@salesforce/schema/Final_Term__c.Table_Code__c';//CISP-16547
import DR_Penal_Interest from '@salesforce/schema/Final_Term__c.DR_Penal_Interest__c';//CISP-16547
import Interest_Version_No from '@salesforce/schema/Final_Term__c.Interest_Version_No__c';//CISP-16547 
import mclrRate from '@salesforce/schema/Final_Term__c.mclrRate__c';//CISP-16547 
import Loan_Deal_Date from '@salesforce/schema/Final_Term__c.Loan_Deal_Date__c';
import OE_Agreement_Amount from '@salesforce/schema/Final_Term__c.Offer_Agreement_Amount__c';
import NetLTV from '@salesforce/schema/Final_Term__c.Calculated_Net_LTV__c';
import GrossLTV from '@salesforce/schema/Final_Term__c.Calculated_Gross_LTV__c';
import grossInvoiceAmount from '@salesforce/schema/Final_Term__c.Calculated_Gross_Invoice_Amount__c';
import LTVInvoiceAmount from '@salesforce/schema/Final_Term__c.Calculated_LTV_Invoice_Amount__c';
import invoiceAmount from '@salesforce/schema/Final_Term__c.Calculated_Invoice_Amount__c';
import CAM_NET_INPUTTED_IRR  from '@salesforce/schema/Final_Term__c.CAM_Net_Inputted_IRR__c'; //CISP-20786
import CAM_CRM_IRR from '@salesforce/schema/Final_Term__c.CAM_CRM_IRR__c';//CISP-23100
import CAM_Gross_IRR from '@salesforce/schema/Final_Term__c.CAM_Gross_IRR__c';//CISP-23100
import CAM_NET_IRR  from '@salesforce/schema/Final_Term__c.CAM_NET_IRR__c';//CISP-23100
const accessibleProfiles = ['IBL CVO', 'IBL Business Executive', 'BE', 'CVO'];
const accessibleProfilesTractor = ['IBL TF CVO', 'IBL TF Business Executive', 'BE', 'CVO','IBL Partner Community TF CVO', 'IBL Partner Community TF Business Executive','IBL Partner Community CVO'];
export const customLabels = {
    Message_Forward_CAM_To_SCM:Message_Forward_CAM_To_SCM,
    Message_CAM_Not_Generated_Cannot_Forward_to_SCM:Message_CAM_Not_Generated_Cannot_Forward_to_SCM,
    Message_No_TeamMember_found_with_role_SCM:Message_No_TeamMember_found_with_role_SCM,
    Message_CAM_Not_Generated_Cannot_Forward_to_CCT:Message_CAM_Not_Generated_Cannot_Forward_to_CCT,
    Message_No_TeamMember_found_with_role_CA:Message_No_TeamMember_found_with_role_CA,
    Message_CAM_Not_Generated_Cannot_Generate_Deviations:Message_CAM_Not_Generated_Cannot_Generate_Deviations,
    Message_Deviation_Created:Message_Deviation_Created,
    Message_Generate_Deviation_First:Message_Generate_Deviation_First,
    Message_remark:Message_remark,
    Message_ForwardTo_Role:Message_ForwardTo_Role,
    Message_Deviation_Mail_Triggered:Message_Deviation_Mail_Triggered,
    Message_ApprovalLogs_Updated:Message_ApprovalLogs_Updated,
    CRM_IRR_Not_As_Per_Norms:CRM_IRR_Not_As_Per_Norms,
    Message_Offer_Engine_Success:Message_Offer_Engine_Success,
    Message_Offer_Engine_Failure:Message_Offer_Engine_Failure,
    Message_CAM_Generated:Message_CAM_Generated,
    Message_Record_Created:Message_Record_Created,
    Message_CAM_Not_Generated_Cannot_View_Deviations:Message_CAM_Not_Generated_Cannot_View_Deviations
}
export function callCamRelatedAPI(borrowerAppId, coborrowerAppId, recordId, camRecId){
    const camFields = {};
    camFields[cam_ID_FIELD.fieldApiName] = camRecId;   
    let productivityAPIrun = false;
    if(!productivityAPIrun){
        productivityAPIrun = true;
        doProductivityCallout({ loanAppId: recordId })
        .then(res => {
            let result = JSON.parse(res);
            if (result.response.status==='SUCCESS') {
                camFields[Productivity.fieldApiName] = result.response.content[0].Productivity;
            }
        }).catch(error => {
            console.error(error);
        });
    }  
    let weightedIRRAPIrun = false;
    if(!weightedIRRAPIrun){
        weightedIRRAPIrun = true;
        doWeightedIRRCallout({ loanAppId: recordId })
        .then(res => {
            let result = JSON.parse(res);
            if (result.response.status==='SUCCESS') {
                camFields[Weighted_IRR.fieldApiName] = result.response.content[0].Weighted_IRR;
            }
        }).catch(error => {
            console.error(error);
        });
    }
    updateRecordDetails(camFields);

    doAPDPendingCallout({applicantId:borrowerAppId, loanAppId: recordId })
    .then(res => {
        let result = JSON.parse(res);
        if (result.response.status==='SUCCESS') {
            storingExternalCAMData({  loanAppId: recordId, camId: camRecId, apiResponse : JSON.stringify(result.response), apiName: result.response.respDesc, isBorrower: false, applicantId: borrowerAppId})
            .then(() => {});
        }
    }).catch(error => {
        console.error(error);
    });
    if(borrowerAppId){
        camPortfolioMethod(borrowerAppId, true, recordId, camRecId);
    }
    if (coborrowerAppId) {
        camPortfolioMethod(coborrowerAppId, false, recordId, camRecId);
    }
}

export function camPortfolioMethod(applicantId, isBorrower, recordId, camRecId){
    doCAMPortfolioCallout({ applicantId: applicantId, loanAppId: recordId })
    .then(res => {
        let result = JSON.parse(res);
        if (result.response.status==='SUCCESS') {
            if (result.response.status==='SUCCESS') {
                storingExternalCAMData({  loanAppId: recordId, camId: camRecId, apiResponse : JSON.stringify(result.response), apiName: result.response.respDesc, isBorrower: isBorrower, applicantId: applicantId})
                .then(() => {});
            }
        }
    }).catch(error => {
        console.error(error);
    });
}
export async function updateRecordDetails(fields) {
    let valid = false;
    const recordInput = { fields };
    await updateRecord(recordInput).then(() => {
                valid = true;
        }).catch(error => {
            console.error('error ', error);
            valid  = false;
        });
    return valid  ;
}
export async function generateDeviations(thisVar,getDeviationsForApprovals, doFicoDeviationCallout_MTD,final_ID_FIELD,NetLTV,GrossLTV,updateRecordDetails,triggerDeviations) {
    if (!thisVar.camRecId) {
        thisVar.showToastWarning(thisVar.labelCustom.Message_CAM_Not_Generated_Cannot_Generate_Deviations);
    } else {
        thisVar.disableViewDeviations = true;
        thisVar.showSpinner = true;
        const deviationList = await getDeviationsForApprovals({ camID: thisVar.camRecId });
        let deviationListTractor = [];
        if(thisVar.isTractor){
            deviationListTractor = await getDeviationsForApprovalsTractor({ camID: thisVar.camRecId });
        }
        if ((thisVar.deviationList.length == 0 && (deviationList == null || deviationList.length == 0)) || (thisVar.isTractor && deviationListTractor.length == 0 && (deviationListTractor == null || deviationListTractor.length == 0))) {
                    let response;
                    try{
                    if(thisVar.isTractor){
                        response = await doFicoDeviationCalloutTractor({ loanAppId: thisVar.loanApplicationID, flag: "" });
                    }else{
                        response = await doFicoDeviationCallout_MTD({ loanAppId: thisVar.loanApplicationID, flag: "" });
                        }
                    }catch(error){
                        console.log(error);thisVar.showSpinner = false;thisVar.disableViewDeviations = false;thisVar.showToastMessage('Error!','FICO Deviation api failling.','error');
                    }
                    if (response && thisVar.isMultipleClicked == false) {
                        thisVar.isMultipleClicked = true;
                        response = response.replace(/\\n/g, '');
                        response = JSON.parse(response);
                        response = JSON.parse(response);
                        let finalTermId = thisVar.finalTermsRecord ? thisVar.finalTermsRecord.Id : null;//Start CISP-2491
                        const FinalTermFields = {};
                        FinalTermFields[final_ID_FIELD.fieldApiName] = finalTermId;
                        FinalTermFields[NetLTV.fieldApiName] = response.netLTV != null ? parseFloat(response.netLTV) : null;
                        FinalTermFields[GrossLTV.fieldApiName] = response.grossltv != null ? parseFloat(response.grossltv) : null;
                        updateRecordDetails(FinalTermFields);//End CISP-2491
                        await triggerDeviations({ camId: thisVar.camRecId, deviationResponse: JSON.stringify(response) })
                            .then(obj => {
                                if (obj == 'Success') {
                                    thisVar.getDeviationList(true);
                                    thisVar.disableViewDeviations = false;
                                    thisVar.showToast(thisVar.labelCustom.Message_Deviation_Created);
                                    thisVar.showSpinner = false;
                                } else {
                                    thisVar.isMultipleClicked = false;
                                    thisVar.disableViewDeviations = false;
                                    thisVar.handleDeviationClick();
                                    thisVar.showSpinner = false;
                                }
                            })
                            .catch(error => {
                                thisVar.isMultipleClicked = false;
                                thisVar.disableViewDeviations = false;
                                console.error('error in record creation ', error);
                                thisVar.showToastWarning(error.body.message);
                                thisVar.showSpinner = false;
                            });
                    }
                    else{
                        thisVar.showSpinner = false;
                        thisVar.disableViewDeviations = false;
                        thisVar.showToastWarning('No response from FICO Deviation API.');
                    }
        } else if (thisVar.deviationList.length != deviationList.length) {
            window.location.reload();
        } else {
            thisVar.disableViewDeviations = false;
            thisVar.showSpinner = false;
            thisVar.handleDeviationClick();
        }
    }
}
export  function computeLIPremiumIns(borrowerAppId,recordId,disableSubmit,showSpinner,insuranceDetailsList){
    doInsurancePremiumCallout({
      applicantId: borrowerAppId,
      Ins_Product: 'LI',
      Plan_Code: 'Plan',
      loanAppId: recordId
  }).then(result => { 
      var getResponse = JSON.parse(result); 
      if (getResponse.Status_Flag == 'Failure') {
          disableSubmit = true;
         // thisVar.showToastMessage('Warning','This Application selected LI as a Insurance premium the api response is failed kindly try again','Warning'); return;
      } else {
          for (let i = 0; i < getResponse.Premium_Details.length; i++) {
              const product = getResponse.Premium_Details[i];
              let tempinsuranceDetailsList = insuranceDetailsList;
              insuranceDetailsList = [];
              for (let i = 0; i < tempinsuranceDetailsList.length; i++) {
                  const element = tempinsuranceDetailsList[i];
                  if (element.isPlanChecked && element.insProductName === product.Ins_Product.toUpperCase()) {
                      element.insAmount = product.Premium ? product.Premium : 0;
                  }
                  insuranceDetailsList.push(element);
              }
          }
         
          disableSubmit = false;
      }
   }).catch(error => {
      console.error('error in email service callout ', error);
               showSpinner = false;
                                  });
                   }
export const checkInsSubmit = (recordId) => {
    return checkInsuranceSubmitted({'loanAppId': recordId}).then((result) => {
        if(result){
            return true;
        }else{
            return false;
        }
    }).catch((error) => {
        console.error('error ', error);
    });
}

export async function validationHelper(ref) {
    if(ref.isTractor && ref.radioButtonVal == 'Accept'){
        if(!ref.isCAMApproved){
            const event = new ShowToastEvent({
                title: 'Warning',
                message: 'CAM/Asset approval pending from SCM/ACM.',
                variant: 'Warning',
            });
            ref.dispatchEvent(event);
            return true;
        }else{
            let response =  await calculateFinalTermLTVCalculations({'loanAppId' : ref.recordId});
            let result = await getFinalTerms({'loanApplicationID' : ref.recordId});
            if(result){
                ref.finalTermList = result;
            }
            if(ref.finalTermList && ref.finalTermList.length == 0){
                const event = new ShowToastEvent({
                    title: 'Warning',
                    message: 'SCM/ACM rejected all vehicles. Hence you can not proceed further.',
                    variant: 'Warning',
                });
                ref.dispatchEvent(event);
                return true;
            }
        }
    }
    let fundedAmount = ref.loanApplicationDetails[0] ? ref.loanApplicationDetails[0].Total_Funded_Premium__c : 0;
    let exshowroomAmount = ref.loanApplicationDetails[0] ? ref.loanApplicationDetails[0].Ex_showroom_price__c : 0;
    let vehicleType = ref.loanApplicationDetails[0] ? ref.loanApplicationDetails[0].Vehicle_Type__c : '';
    let fundedExshowroom = ref.loanApplicationDetails[0] ? ref.loanApplicationDetails[0].Funding_on_Ex_Showroom__c : false;
    let fundedOrp = ref.loanApplicationDetails[0] ? ref.loanApplicationDetails[0].Funding_on_ORP__c : false;
    let orpAmount = ref.loanApplicationDetails[0] ? ref.loanApplicationDetails[0].On_Road_price__c : false;
    if (vehicleType.toLowerCase() === 'New'.toLowerCase() && fundedExshowroom == true && exshowroomAmount && ((parseFloat(ref.loanAmmount)) > parseFloat(exshowroomAmount))) {
        const event = new ShowToastEvent({
            title: 'Warning',
            message: 'Loan amount is out of bounds. Please enter value less than Ex Showroom Price '+exshowroomAmount,
            variant: 'Warning',
        });
        ref.dispatchEvent(event);
        return true;
    }else if (vehicleType.toLowerCase() === 'New'.toLowerCase() && fundedOrp == true && orpAmount !=null && ((parseFloat(ref.loanAmmount)) > parseFloat(orpAmount))) {
        const event = new ShowToastEvent({
            title: 'Warning',
            message: 'Loan amount is out of bounds. Please enter value less than On Road Price '+orpAmount,
            variant: 'Warning',
        });
        ref.dispatchEvent(event);
        return true;
    }
    return false;
}
export function getParsedJSOND2C(parsedJSON){
    let obj = {};
    obj.EMI = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.displayEMI;
    obj.Tenure = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.displayTenure.toString();
    obj.Loan_Amt = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.displayLoanAmt;
    obj.CRM_IRR = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.displayCrmIrr.toString();
    obj.Final_CRM_IRR = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.displayCrmIrr.toString();
    obj.Max_Tenure_Slider = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.maxTenureSlider;
    obj.Min_Tenure_Slider = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.minTenureSlider;
    obj.Min_Loan_Amt_Slider = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.minLoanAmtSlider;
    obj.Max_Loan_Amt_Slider = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.maxLoanAmtSlider;
    obj.Imputed_IRR_Offered = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.displayImputedIrr;
    obj.Net_IRR_Offered = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.netIrr;
    obj.Gross_IRR_Offered = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.grossIrr;
    obj.Final_Gross_IRR = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.grossIrr;
    obj.Stop_Journey_Flag = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.stopJourneyFlag;
    obj.Stop_Journey_Flag = obj.Stop_Journey_Flag ? 'True' : 'False';//D2C change - Rahul
    obj.NetPayIns = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.netPayIns?.toString();
    obj.NetPayOuts = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.netPayOuts?.toString();
    obj.TableCode = parsedJSON?.application?.tableCode;
    obj.Interest_VersionNo = parsedJSON?.application?.interestVersionNo;
    obj.DR_PenalInterest = parsedJSON?.application?.drPenalInterest?.toString();
    obj.mclrRate = parsedJSON?.application?.loanDetails?.mclrRate?.toString();
    obj.loanDealDate = parsedJSON?.application?.offerEngineDetails?.loanDealDate;     
    obj.agreementAmount = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.agreementAmount;     
    obj.amortizationSchedule = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.amortizationSchedule;    
    return obj;
    
}

export async function roiMasterHelper(ref){
    roiMasterTractor({'loanApplicationId' : ref.recordId}).then(result=>{
        if(result){
            ref.minCRMIRR = result.CRM_IRR_MIN;
            ref.maxCRMIRR = result.CRM_IRR_MAX;
            ref.minGROSSIRR = result.GROSS_IRR_MIN;
            ref.maxGROSSIRR = result.GROSS_IRR_MAX;
            ref.isNonIndividual = result.isNonIndividual;
        }
    }).catch(error=>{})
}
export async function fetchFinalTermHelper(ref){
    ref.totalLoanAmount = 0;
    getFinalTerms({'loanApplicationID' : ref.recordId}).then(result=>{
        if(result){
            ref.finalTermList = result;
            result.forEach(element => {
                let loanAmount = element.Loan_Amount__c ?    parseFloat(element.Loan_Amount__c) : 0; 
                let fundedAmount =  element.Vehicle_Detail__r.Total_Funded_Amount__c ?   parseInt(element.Vehicle_Detail__r.Total_Funded_Amount__c) : 0;
                ref.totalLoanAmount += loanAmount;
                ref.totalLoanAmount += fundedAmount;
            });
        }
    }).catch(error=>{})
}

//TF offer Engine API callout SFTRAC-126
export async function handleTFOfferEngineCalloutHelper(thisVar,accepted){
    try{
        let isOfferEngineAPICalled;
        let isOfferEngineAPISkipped = true;
        let finalTermList = thisVar.finalTermList;
        if(finalTermList){
            for (let index = 0; index < finalTermList.length; index++) {
                const finalTerm = finalTermList[index];
                if(finalTerm.L1_L2_Final_Terms_Changed__c){
                isOfferEngineAPISkipped = false;
                let totalFundedAmt = finalTerm.Vehicle_Detail__r.Total_Funded_Amount__c ? parseInt(finalTerm.Vehicle_Detail__r.Total_Funded_Amount__c) : 0;
                let offerResponse = await tractorOfferEngineCallout({ loanAppId: thisVar.recordId, vehicleId: finalTerm.Vehicle_Detail__c, screenName : 'CAM and Approval Log'});
                if(offerResponse){
                    const parsedResponse = JSON.parse(offerResponse);
            const offerEngineResponse = parsedResponse?.application?.offerEngineDetails?.offerEngineDecision;

                    if(thisVar.isNonIndividual != true && (parseFloat(offerEngineResponse.displayCrmIrr) > parseFloat(thisVar.maxCRMIRR) || parseFloat(offerEngineResponse.displayCrmIrr) < parseFloat(thisVar.minCRMIRR))){
                        thisVar.showToastWarning(`CRM IRR is not as per norms Min ${thisVar.minCRMIRR} and Max ${thisVar.maxCRMIRR}.`);
                        break;
                    }else if(thisVar.isNonIndividual != true && (parseFloat(offerEngineResponse.grossIrr) > parseFloat(thisVar.maxGROSSIRR) || parseFloat(offerEngineResponse.grossIrr) < parseFloat(thisVar.minGROSSIRR))){
                        thisVar.showToastWarning(`Gross IRR is not as per norms Min ${thisVar.minGROSSIRR} and Max ${thisVar.maxGROSSIRR}.`);
                        break;
                    }else if(offerEngineResponse){
            const FinalTermFields = {};
                        FinalTermFields[final_ID_FIELD.fieldApiName]= finalTerm.Id;
            
            FinalTermFields[OfferengineMinLoanAmount.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.minLoanAmt : '';
            FinalTermFields[OfferengineMaxLoanAmount.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.maxLoanAmt : '';
            //FinalTermFields[Loan_Amount.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.displayLoanAmt.toString() : '';
            FinalTermFields[Loan_Amount.fieldApiName] = offerEngineResponse !== undefined ?  (parseFloat(offerEngineResponse.displayLoanAmt) - totalFundedAmt).toString() : '';
            FinalTermFields[OfferengineMinTenure.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.minTenure : '';
            FinalTermFields[OfferengineMaxTenure.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.maxTenure : '';
            FinalTermFields[Tenure.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.displayTenure.toString() : '';
            FinalTermFields[EMI_Amount.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.displayEMI : '';
            FinalTermFields[Required_CRM_IRR.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.displayCrmIrr.toString() : '';
            FinalTermFields[Net_IRR.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.netIrr : '';
            FinalTermFields[Gross_IRR.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.grossIrr : '';
            FinalTermFields[Bank_IRR.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.bankCrmIrr.toString() : '';
            FinalTermFields[Offer_Agreement_Amount.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.agreementAmount : '';

                        if(offerEngineResponse && offerEngineResponse.amortizationSchedule){
                            let result = await saveInstallmentScheduleTractor({ loanId: thisVar.recordId, response: JSON.stringify(offerEngineResponse.amortizationSchedule), installmentType: finalTerm.Installment_Type__c, vehicleId: finalTerm.Vehicle_Detail__c});
                            if(result){
                                let res = await updateRecordDetails(FinalTermFields);
                                if (res) { isOfferEngineAPICalled = true; } else { isOfferEngineAPICalled = false; break; }
                            }
                        }else{
                            const evt = new ShowToastEvent({
                                title: 'Error',
                                message: "Something went wrong!",
                                variant: 'error',
                            });
                            thisVar.dispatchEvent(evt);
                            isOfferEngineAPICalled = false;break;
                        }
                    }else{
                        isOfferEngineAPICalled = false;break;
                    }
                }else{
                    isOfferEngineAPICalled = false;break;
                }
            }else if(isOfferEngineAPICalled == undefined){isOfferEngineAPICalled=true;}
            }
        }
        if(isOfferEngineAPICalled == true || isOfferEngineAPISkipped == true){
            if(isOfferEngineAPISkipped == false){
                const evt = new ShowToastEvent({title: 'Success',message: "Offer Engine API Success",variant: 'Success',});
                thisVar.dispatchEvent(evt);
            }
            let isUpdated = await updateLoanApplication_MTD({loanAppId: thisVar.loanApplicationID,isAccepted: accepted,cam: thisVar.camRecord});
            if (isUpdated) {
                thisVar.template.querySelectorAll(`[type="radio"]`).forEach(elem => elem.disabled = true);
                createProposalLogRecord(thisVar);
                thisVar.applicationAccepted = true;
            thisVar.hideSubmit = true;
                thisVar.showSpinner = false;
                thisVar.addChangeCoBorrower = true;
                if (thisVar.radioButtonVal == 'Accept') {
                    const selectedEvent = new CustomEvent('camandapprovalevent', { detail: 'CAM and Approval Log' });
                    thisVar.dispatchEvent(selectedEvent);
                }
                thisVar.showToast('Record updated Successfully.');
            }else{
                thisVar.showSpinner = false;
                thisVar.hideSubmit = false;
            thisVar.disableSubmit = false;
                thisVar.showToastMessage('Error!','Something went wrong!','error');
            }
        }else if(isOfferEngineAPICalled == false){
            const evt = new ShowToastEvent({title: 'Error',message: "Offer Engine API Failed",variant: 'error',});
            thisVar.dispatchEvent(evt);
            thisVar.hideSubmit = false;
            thisVar.disableSubmit = false;
            thisVar.showSpinner = false;
        }else if(isOfferEngineAPICalled == undefined){
            thisVar.hideSubmit = false;
            thisVar.disableSubmit = false;
            thisVar.showSpinner = false;
        }
    }catch(error){
        const evt = new ShowToastEvent({title: 'Error',message: "Something went wrong!",variant: 'error',});
        thisVar.dispatchEvent(evt);
        thisVar.hideSubmit = false;
        thisVar.disableSubmit = false;
        thisVar.showSpinner = false;
    }
}

//CISP-4459 start
export function journeyStopScenarioFound(thisVar){
    updateJourneyStop({ leadNo: thisVar.recordId })
    .then(result => {
    })
    .catch(error => {console.error('Error:', error);});
}//CISP-4459

export async function getEmiDateList(ref){    
    let x1stEMIDate1;
    let x2ndEMIDate1;
    let datelist = [];
    ref.emidatelist = [];
    let effectiveDealDate1 = new Date();
    if(ref.finalTermsRecord?.Holiday_period__c && (ref.finalTermsRecord?.Holiday_period__c == '30' || ref.finalTermsRecord?.Holiday_period__c == 30)){
        x1stEMIDate1 = new Date(
          (effectiveDealDate1.getFullYear()),
          (effectiveDealDate1.getMonth() + 1),
        );
        x2ndEMIDate1 = new Date(
          (x1stEMIDate1.getFullYear()),
          (x1stEMIDate1.getMonth() + 1),
        );
    }else{
        x1stEMIDate1 = effectiveDealDate1;
        x2ndEMIDate1 = new Date(
          (x1stEMIDate1.getFullYear()),
          (x1stEMIDate1.getMonth() + 1),
        );
    }
    if (ref.finalTermsRecord?.Advance_EMI__c) {
        if (ref.isProductTypeTW) {
          if (parseInt(effectiveDealDate1.getDate()) > 0 && parseInt(effectiveDealDate1.getDate()) <= 15) {
            x1stEMIDate1 = new Date(
              x1stEMIDate1.getFullYear(),
              x1stEMIDate1.getMonth(),
              x1stEMIDate1.getDate()
            );
            x2ndEMIDate1 = new Date(
              x2ndEMIDate1.getFullYear(),
              x2ndEMIDate1.getMonth(),
              parseInt(x1stTWEMIDueDate)
            );
          } else {
            x1stEMIDate1 = new Date(
              x1stEMIDate1.getFullYear(),
              x1stEMIDate1.getMonth(),
              x1stEMIDate1.getDate()
            );
            x2ndEMIDate1 = new Date(
              x2ndEMIDate1.getFullYear(),
              x2ndEMIDate1.getMonth(),
              parseInt(x21EMIDueDate)
            );
          }
          datelist.push({ label: x1stEMIDate1.getDate()+'-'+(x1stEMIDate1.getMonth()+1)+'-'+x1stEMIDate1.getFullYear(), value: x1stEMIDate1.toString()});
          ref.emidatelist = datelist;
          ref.emidate = x1stEMIDate1.toString();
          ref.x2EmiDate = x2ndEMIDate1.getDate()+'-'+(x2ndEMIDate1.getMonth()+1)+'-'+x2ndEMIDate1.getFullYear();
          ref.firstemidate = x1stEMIDate1.getFullYear() + "-" + (x1stEMIDate1.getMonth() + 1) + "-" + x1stEMIDate1.getDate();
          ref.secondemidate = x2ndEMIDate1.getFullYear() + "-" + (x2ndEMIDate1.getMonth() + 1) + "-" + x2ndEMIDate1.getDate();
          console.log('ref.emidatelist',ref.emidatelist,ref.firstemidate,ref.secondemidate, ref.x2EmiDate,ref.emidate);
        } else if (!ref.isProductTypeTW) {
          if (parseInt(effectiveDealDate1.getDate()) > 0 && parseInt(effectiveDealDate1.getDate()) < 15) {
            x2ndEMIDate1 = new Date(
              x2ndEMIDate1.getFullYear(),
              x2ndEMIDate1.getMonth(),
              parseInt(x1stPVEMIDueDate)
            );
          } else {
            x2ndEMIDate1 = new Date(
              x2ndEMIDate1.getFullYear(),
              x2ndEMIDate1.getMonth(),
              parseInt(x1stPVEMIDueDatev2)
            );
          }
          datelist.push({ label: x1stEMIDate1.getDate()+'-'+(x1stEMIDate1.getMonth()+1)+'-'+x1stEMIDate1.getFullYear(), value: x1stEMIDate1.toString()});
          ref.emidatelist = datelist;
          ref.emidate = x1stEMIDate1.toString();
          ref.x2EmiDate = x2ndEMIDate1.getDate()+'-'+(x2ndEMIDate1.getMonth()+1)+'-'+x2ndEMIDate1.getFullYear();
          ref.firstemidate = x1stEMIDate1.getFullYear() + "-" + (x1stEMIDate1.getMonth() + 1) + "-" + x1stEMIDate1.getDate();
          ref.secondemidate = x2ndEMIDate1.getFullYear() + "-" + (x2ndEMIDate1.getMonth() + 1) + "-" + x2ndEMIDate1.getDate();
          console.log('ref.emidatelist',ref.emidatelist,ref.firstemidate,ref.secondemidate, ref.x2EmiDate,ref.emidate);
        }
    } else {
        if (ref.isProductTypeTW) {
            if (parseInt(effectiveDealDate1.getDate()) > 0 && parseInt(effectiveDealDate1.getDate()) <= 15) {
                x1stEMIDate1 = new Date(
                x1stEMIDate1.getFullYear(),
                x1stEMIDate1.getMonth(),
                parseInt(x1stTWEMIDueDate)
                );
                x2ndEMIDate1 = new Date(
                x2ndEMIDate1.getFullYear(),
                x2ndEMIDate1.getMonth(),
                parseInt(x1stTWEMIDueDate)
                );
            } else {
                x1stEMIDate1 = new Date(
                x1stEMIDate1.getFullYear(),
                x1stEMIDate1.getMonth(),
                parseInt(x21EMIDueDate)
                );
                x2ndEMIDate1 = new Date(
                x2ndEMIDate1.getFullYear(),
                x2ndEMIDate1.getMonth(),
                parseInt(x21EMIDueDate)
                );
            }
            datelist.push({ label: x1stEMIDate1.getDate()+'-'+(x1stEMIDate1.getMonth()+1)+'-'+x1stEMIDate1.getFullYear(), value: x1stEMIDate1.toString()});
            ref.emidatelist = datelist;
            ref.emidate = x1stEMIDate1.toString();
            ref.x2EmiDate = x2ndEMIDate1.getDate()+'-'+(x2ndEMIDate1.getMonth()+1)+'-'+x2ndEMIDate1.getFullYear();
            ref.firstemidate = x1stEMIDate1.getFullYear() + "-" + (x1stEMIDate1.getMonth() + 1) + "-" + x1stEMIDate1.getDate();
            ref.secondemidate = x2ndEMIDate1.getFullYear() + "-" + (x2ndEMIDate1.getMonth() + 1) + "-" + x2ndEMIDate1.getDate();
            console.log('ref.emidatelist',ref.emidatelist,ref.firstemidate,ref.secondemidate, ref.x2EmiDate,ref.emidate);
        } else if (!ref.isProductTypeTW) {
            // ref.x2EmiDate = '';
            // ref.secondemidate = '';
            let x1stEMIDate2 = new Date();
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
        }
    }
}
export function handleEmiChangeHelper(thisVar,event){
    try {
        if(event.target.name == 'firstEMI'){
            let firstemi = new Date(event.target.value);
            thisVar.emidate = event.target.value;
            thisVar.firstemidate = firstemi.getFullYear() + "-" + (firstemi.getMonth() + 1) + "-" + firstemi.getDate();
            let secemi = new Date(
              firstemi.getFullYear(),
              (firstemi.getMonth() + 1),
              firstemi.getDate()
            );
            thisVar.secondemidate = secemi.getFullYear() + "-" + (secemi.getMonth() + 1) + "-" + secemi.getDate();
            thisVar.template
            .querySelectorAll("lightning-input")
            .forEach((input) => {
              if (input.name == "secondEMI") {
                thisVar.x2EmiDate = input.value = secemi.getDate() + "-" + (secemi.getMonth() + 1) + "-" + secemi.getFullYear();
              } 
            });
            saveEMIdueDates(thisVar);
          }
    } catch (error) {
        console.error(error);
    }
}

export function saveEMIdueDates(ref){
    const FinalTermFields = {};
    FinalTermFields[final_ID_FIELD.fieldApiName] = ref.finalTermsRecord.Id;
    FinalTermFields[First_EMI_Date.fieldApiName] = ref.firstemidate;
    FinalTermFields[Second_EMI_Date.fieldApiName] = ref.secondemidate;
    updateRecordDetails(FinalTermFields);
}
export function saveAmortDetails(ref,obj){
    if(obj.amortizationSchedule){
        saveInstallmentSchedule({ loanId: ref.recordId, response: JSON.stringify(obj.amortizationSchedule), installmentType: ref.finalTermsRecord.Installment_Type__c}).then(result => {}).catch(error =>{});
    }
}

export async function createProposalLogRecord(ref){
    const proposalApprovals = {};
    proposalApprovals[HoldRmrk.fieldApiName] = ref.holdRemark;
    proposalApprovals[ParentCAM.fieldApiName] = ref.camRecId;
    proposalApprovals[Decision.fieldApiName] = ref.radioButtonVal;
    proposalApprovals[Loan_Ammount__c.fieldApiName] = ref.loanAmmount ? ref.loanAmmount.toString() : '';

    proposalApprovals[Vehicle_ID__c.fieldApiName] = ref.vehicleId;
    proposalApprovals['Name'] = Math.floor(Math.random() * 10000).toString(); // CISP-16665
    proposalApprovals['Proposal_description__c'] = 'Final Decision taken by ' + ref.currentUserName; // CISP-16665
    if (ref.proposalRecordTypeId) {
        proposalApprovals['RecordTypeId'] = ref.proposalRecordTypeId;
    }
    proposalApprovals[Approval_Status__c.fieldApiName] = ref.radioButtonVal;
    proposalApprovals[Remark__c.fieldApiName] = ref.finalRemark;
    proposalApprovals[Role__c.fieldApiName] = ref.currentUserRole;
    proposalApprovals[SF_Role__c.fieldApiName] = ref.currentUserRole;
    if ((ref.currentUserRole && accessibleProfiles.includes(ref.currentUserRole)) || (ref.isTractor && accessibleProfilesTractor.includes(ref.currentUserRole))) {
        proposalApprovals[Submitted_By_BE_CVO__c.fieldApiName] = true;
    }
    await createRecord({ apiName: Proposal_Approval_Log__c.objectApiName, fields: proposalApprovals })
        .then(obj => {
            ref.getProposalLog();
        })
        .catch(error => {});
}
export async function  disableInsScheduleHelper(ref){
    getRecentEMIdetails({loanId:ref.recordId}).then((data)=>{
        if(data && data.length>0){
           ref.disableInsSchedule = false;
        }else{
           ref.disableInsSchedule = true;
        }
     }).catch((error) => { console.log('error in getRecentEMIdetails ',error);});
}

export async function runOfferEngineHelper(ref,offerEngineParams,offerEngineMethod,isvalidForSubmit,accepted,submitCam){
    try {
        offerEngineMethod(offerEngineParams)
        .then(result => {
            const obj = (ref.leadSource === 'D2C' || ref.leadSource === 'Hero')  ? getParsedJSOND2C(JSON.parse(result)) : JSON.parse(result);
                if (obj != null && obj.status != 'FAILED') {
                    ref.showToast(ref.labelCustom.Message_Offer_Engine_Success);
                        getFinalTermId({
                                loanAppId: ref.loanApplicationID
                            })
                            .then(finalTermId => {
                                console.log('finalTermId',finalTermId,submitCam);
                                if (finalTermId) {
                                    ref.oppFinalTermId = finalTermId;//CISP-5977
                                    getFinalTermCalculations({
                                            loanAppId: ref.loanApplicationID
                                        })
                                        .then(response => {
                                            const wrapperobj = response;
                                            const FinalTermFields = {};
                                            FinalTermFields[final_ID_FIELD.fieldApiName] = finalTermId;
                                            if (obj.EMI) {
                                                FinalTermFields[EMI_Amount.fieldApiName] = obj.EMI;
                                            }
                                            if (obj.Final_CRM_IRR) {
                                                FinalTermFields[CRM_IRR.fieldApiName] = obj.Final_CRM_IRR;
                                                FinalTermFields[CAM_CRM_IRR.fieldApiName] = obj.Final_CRM_IRR;
                                            }
                                            if (obj.Final_Gross_IRR) {
                                                FinalTermFields[Gross_IRR.fieldApiName] = obj.Final_Gross_IRR;
                                            }
                                            if(!ref.leadSource || ref.leadSource !== 'D2C' || ref.leadSource !== 'Hero'){        
                                            
                                                if (ref.camRecord && ref.camRecord.Loan_Application__r?.Product_Type__c === 'Two Wheeler' && obj.Final_Net_IRR) {
                                                    FinalTermFields[Net_IRR.fieldApiName] = obj.Final_Net_IRR;
                                                }
                                            }
                                            if((ref.leadSource === 'D2C' || ref.leadSource === 'Hero') && obj.Loan_Amt != null){// D2C Change
                                                FinalTermFields[Loan_Amount.fieldApiName] = parseFloat(obj.Loan_Amt).toString();
                                                ref.loanAmount = parseFloat(obj.Loan_Amt).toString();
                                                //ref.camRecord.Loan_Amount__c = obj.Loan_Amt;
                                            }
                                            //CISP-16547 start
                                            if(ref.leadSource != 'Hero'){
                                                if (obj.TableCode) {FinalTermFields[Table_Code.fieldApiName] = obj.TableCode;}
                                                if(obj.Interest_VersionNo){FinalTermFields[Interest_Version_No.fieldApiName] = obj.Interest_VersionNo;}
                                                if(obj.DR_PenalInterest){FinalTermFields[DR_Penal_Interest.fieldApiName] = obj.DR_PenalInterest;}       
                                                if(obj.mclrRate){FinalTermFields[mclrRate.fieldApiName] = obj.mclrRate;}                                                               
                                            }//CISP-16547 end
                                            if(obj.loanDealDate){FinalTermFields[Loan_Deal_Date.fieldApiName] = obj.loanDealDate;}if(obj.agreementAmount){FinalTermFields[OE_Agreement_Amount.fieldApiName] = obj.agreementAmount;}saveAmortDetails(ref,obj);
                                            FinalTermFields[NetLTV.fieldApiName] = wrapperobj.netLTV ? wrapperobj.netLTV : null;
                                            FinalTermFields[GrossLTV.fieldApiName] = wrapperobj.grossLTV ? wrapperobj.grossLTV : null;
                                            FinalTermFields[grossInvoiceAmount.fieldApiName] = wrapperobj.grossInvoiceAmount ? wrapperobj.grossInvoiceAmount : null;
                                            FinalTermFields[LTVInvoiceAmount.fieldApiName] = wrapperobj.LTVInvoiceAmount ? wrapperobj.LTVInvoiceAmount : null;
                                            FinalTermFields[invoiceAmount.fieldApiName] = wrapperobj.invoiceAmount ? wrapperobj.invoiceAmount : null;
                                            if(ref.camRecord.Loan_Application__r?.Product_Type__c === 'Two Wheeler' && obj.Imputed_IRR_Offered){//CISP-20786
                                                FinalTermFields[CAM_NET_INPUTTED_IRR.fieldApiName] = parseFloat(obj.Imputed_IRR_Offered);
                                            }else if(ref.camRecord.Loan_Application__r?.Product_Type__c ==='Passenger Vehicles' && obj.Net_IRR_Offered){
                                                FinalTermFields[CAM_NET_INPUTTED_IRR.fieldApiName] = parseFloat(obj.Net_IRR_Offered);
                                            }
                                            if (obj.Gross_IRR_Offered) {
                                                FinalTermFields[CAM_Gross_IRR.fieldApiName] = obj.Gross_IRR_Offered;
                                            }
                                            if(obj.Net_IRR_Offered){
                                                FinalTermFields[CAM_NET_IRR.fieldApiName] = obj.Net_IRR_Offered;
                                            }
                                            updateRecordDetails(FinalTermFields);
                                            if(obj.Final_CRM_IRR && ref.mincrm && ref.maxcrm && (parseFloat(obj.Final_CRM_IRR) > parseFloat(ref.maxcrm) || parseFloat(obj.Final_CRM_IRR) < parseFloat(ref.mincrm))){
                                                ref.showSpinner = false;
                                                let messageBasedOnProduct; //CISP-5450
                                                if(!ref.isPassengerVehicle){
                                                    messageBasedOnProduct = ref.labelCustom.CRM_IRR_Not_As_Per_Norms
                                                }else{//CISP-5450
                                                    messageBasedOnProduct = 'CRM IRR is not as per norms Min '+ ref.mincrm +' and Max '+ ref.maxcrm +' . Please make the relevant changes by editing Net IRR in CAM screen (or) revoke the proposal';ref.netIRRDisable = false;
                                                }
                                                const evt = new ShowToastEvent({
                                                    title: "Error",
                                                    message: messageBasedOnProduct,
                                                    variant: 'error'
                                                });
                                                ref.dispatchEvent(evt);
                                                return;
                                            }else if(!ref.isPassengerVehicle && ref.requiredNetIRR && ref.minImputedCrm && ref.maxImputedCrm && (parseFloat(ref.requiredNetIRR) > parseFloat(ref.maxImputedCrm) || parseFloat(ref.requiredNetIRR) < parseFloat(ref.minImputedCrm))){
                                                if(!ref.isNetIRRChange){
                                                    ref.showSpinner = false;
                                                    const evt = new ShowToastEvent({
                                                        title: "Error",
                                                        message: 'Imputed IRR is not within the range',
                                                        variant: 'error'
                                                    });
                                                    ref.dispatchEvent(evt);
                                                    ref.netIRRDisable = false;
                                                    return;
                                                }
                                                if(ref.isNetIRRChange){
                                                    ref.showSpinner = false;
                                                    const evt = new ShowToastEvent({
                                                        title: "Error",
                                                        message: 'Imputed IRR entered is not as per norms. Please revoke or withdraw ref proposal',
                                                        variant: 'error'
                                                    });
                                                    ref.dispatchEvent(evt);
                                                    ref.netIRRDisable = true;
                                                    return;
                                                }    
                                            }else if(ref.isPassengerVehicle && ref.requiredNetIRR && ref.minImputedCrm && ref.maxImputedCrm && (parseFloat(ref.requiredNetIRR) > parseFloat(ref.maxImputedCrm) || parseFloat(ref.requiredNetIRR) < parseFloat(ref.minImputedCrm))){
                                                ref.showSpinner = false;
                                                const evt = new ShowToastEvent({
                                                    title: "Error",
                                                    message: 'Net IRR is not as per norms Min '+ ref.minImputedCrm +' and Max '+ ref.maxImputedCrm +' . Please make the relevant changes by editing Net IRR in CAM screen (or) revoke the proposal',
                                                    variant: 'error'
                                                });
                                                ref.dispatchEvent(evt);
                                                ref.netIRRDisable = false;
                                                return;
                                            }else if((parseInt(obj.Loan_Amt) >= 1000000 || parseInt(ref.totalExposureAmt) >= 1000000) && isvalidForSubmit == false){
                                                const evt = new ShowToastEvent({
                                                    title: "Error",
                                                    message: 'Exposure (Incl. loan amount) is >= INR 10 Lakhs, hence, PAN is mandatory. Please withdraw ref lead and create a new lead with PAN or change the Loan amount by revoking the application',
                                                    variant: 'error',
                                                    mode: 'sticky'
                                                });
                                                ref.dispatchEvent(evt);
                                                return;
                                            }else if(!ref.isPassengerVehicle && obj.Final_Gross_IRR!=null && ref.mingross!=null && ref.maxgross!=null && ((parseFloat(obj.Final_Gross_IRR) < parseFloat(ref.mingross)) || (parseFloat(obj.Final_Gross_IRR) > parseFloat(ref.maxgross)))){//CISP-20504

                                                ref.showSpinner = false;

                                                    const event = new ShowToastEvent({

                                                        title: 'Error',

                                                        message: 'Gross IRR is not as per norms. Please revoke and re-do the application with correct Gross IRR',

                                                        variant: 'Error',

                                                    });

                                                    ref.dispatchEvent(event);

                                                    return;

                                            }//CISP-20504
                                            else if(submitCam){
                                                console.log('submitCam',submitCam,accepted);
                                            updateLoanApplication_MTD({
                                                loanAppId: ref.loanApplicationID,
                                                isAccepted: accepted,
                                                cam: ref.camRecord
                                            })
                                            .then((res) => {
                                                if (res) {
                                                console.log('submitCam',res);
                                                createProposalLogRecord(ref);
                                                    ref.showToast(ref.labelCustom.Message_Record_Created);
                                                    ref.applicationAccepted = true;ref.hideSubmit = true; ref.showSpinner = false;
                                                    ref.addChangeCoBorrower = true; //CISP-2399
                                                    ref.template.querySelectorAll(`[type="radio"]`).forEach(elem => elem.disabled = true);ref.emidisable=true;
                                                    if (ref.radioButtonVal == 'Accept') {const selectedEvent = new CustomEvent('camandapprovalevent', { detail: 'CAM and Approval Log' });ref.dispatchEvent(selectedEvent);
                                                    }
                                                }else{ref.showSpinner = false;ref.hideSubmit = false;ref.disableSubmit = false;ref.showToastMessage('Error!',EXCEPTIONMESSAGE,'error');}
                                            }).catch(error => {
                                                    ref.showSpinner = false;
                                                });
                                            }
                                        }).catch(error => {ref.showSpinner = false;});
                                }
                            }).catch(error => {ref.showSpinner = false;});
                } else {ref.showToastWarning(ref.labelCustom.Message_Offer_Engine_Failure);ref.hideSubmit = false;ref.disableSubmit = false;ref.showSpinner = false;} 
            }).catch(error => {
                ref.showSpinner = false;ref.showToastWarning(ref.labelCustom.Message_Offer_Engine_Failure);ref.hideSubmit = false;ref.disableSubmit = false;
            }); 
    } catch (error) {
        console.error(error);
    }
    
}