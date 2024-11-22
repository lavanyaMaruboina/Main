import createCaseAVRecords from '@salesforce/apex/LWCLOSAssetVerificationCntrl.createCaseAVRecords';
import updateVehicleRecords from '@salesforce/apex/IND_AssetDetailsCntrl.updateVehicleRecords';
import validateVehicleRecords from '@salesforce/apex/IND_AssetDetailsCntrl.validateVehicleRecords';
import changeStage from '@salesforce/apex/IND_AssetDetailsCntrl.changeStage';

import VEHICLE_TYPE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Vehicle_type__c';
import PRODUCT_FIELD from '@salesforce/schema/Vehicle_Detail__c.Product__c';
import MAKE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Make__c';
import MAKE_CODE from '@salesforce/schema/Vehicle_Detail__c.Make_Code__c';//CISP-2794
import MODEL_FIELD from '@salesforce/schema/Vehicle_Detail__c.Model__c';
import MODEL_CODE from '@salesforce/schema/Vehicle_Detail__c.Model_Code__c';//CISP-2794
import VARIANT_FIELD from '@salesforce/schema/Vehicle_Detail__c.Variant__c';
import VARIANT_CODE from '@salesforce/schema/Vehicle_Detail__c.Variant_Code__c';//CISP-2794
import PURPOSE_OF_PURCHANSE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Purpose_of_purchase__c';
import DEALER_SUBDEALER_NAME_FIELD from '@salesforce/schema/Vehicle_Detail__c.Dealer_Sub_dealer_name__c';
import BEN_CODE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Ben_Code__c';
import INVOICE_IN_THE_NAME_FIELD from '@salesforce/schema/Vehicle_Detail__c.Invoice_in_the_name_of__c';
import VEHICLE_REGISTERED_NAME_FIELD from '@salesforce/schema/Vehicle_Detail__c.Vehicle_registered_in_the_name_of__c';
import RC_HOLD_AMOUNT_FIELD from '@salesforce/schema/Vehicle_Detail__c.RC_Hold_Amount__c'; //SFTRAC-1715
import USAGE_TYPE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Usage_Type__c';
import VEHICLE_REG_NUMBER_FIELD from '@salesforce/schema/Vehicle_Detail__c.Vehicle_Registration_number__c';
import MANUFACTURER_YEAR_MONTH_FIELD from '@salesforce/schema/Vehicle_Detail__c.Manufacturer_Year_Month__c';
import ENGINE_NUMBER_FIELD from '@salesforce/schema/Vehicle_Detail__c.Engine_number__c';
import LAST_OWNER_NAME_FIELD from '@salesforce/schema/Vehicle_Detail__c.Last_owner_name__c';
import CHASSIS_NUMBER_FIELD from '@salesforce/schema/Vehicle_Detail__c.Chassis_number__c';
import LIEN_IN_FAVOR_FIELD from '@salesforce/schema/Vehicle_Detail__c.Lien_in_favor_of__c';
import RC_RETENTION_APPLICABLE_FIELD from '@salesforce/schema/Vehicle_Detail__c.RC_retention_applicable__c';
import IS_GET_VEHICLE_DETAILS_SUCCESSFUL_FIELD from '@salesforce/schema/Vehicle_Detail__c.Is_Get_Vehicle_Details_Successful__c';
import NUMBER_OF_OWNERSHIP_FIELD from '@salesforce/schema/Vehicle_Detail__c.Number_of_ownerships__c';
import INSURER_NAME_FIELD from '@salesforce/schema/Vehicle_Detail__c.Insurer_name__c';
import INSURANCE_NUMBER_FIELD from '@salesforce/schema/Vehicle_Detail__c.Insurance_number__c';
import ELIGIBLE_LOAN_AMT_FIELD from '@salesforce/schema/Vehicle_Detail__c.Eligible_Loan_Amount__c';
import ELIGIBLE_TENURE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Eligible_Tenure__c';
import OWNER_NAME_FIELD from '@salesforce/schema/Vehicle_Detail__c.Owner_Name__c';
import OWNER_CONTACT_FIELD from '@salesforce/schema/Vehicle_Detail__c.Owner_Contact_Number__c';
import VEHICLE_PLACE_VALUATION_FIELD from '@salesforce/schema/Vehicle_Detail__c.Vehicle_Place_Of_Valuation__c';
import VEHICLE_ID_FIELD from '@salesforce/schema/Vehicle_Detail__c.Id';
import INS_ISSUANCE_DATE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Ins_Issuance_date__c';
import INS_EXPIRY_DATE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Ins_Expiry_date__c';
import FITNESS_UPTO_FIELD from '@salesforce/schema/Vehicle_Detail__c.Fitness_Upto__c'; //SFTRAC-2028
import REGISTRATION_DATE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Registration_Date__c'; //SFTRAC-2028
import DEALER_FIELD from '@salesforce/schema/Vehicle_Detail__c.Dealer__c'; //SFTRAC-2028
import BODY_TYPE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Body_Type__c'; //SFTRAC-2028
import OWNER_SR_NO_FIELD from '@salesforce/schema/Vehicle_Detail__c.Owner_Sr_No__c'; //SFTRAC-2028
import MANUFACTURER_FIELD from '@salesforce/schema/Vehicle_Detail__c.Manufacturer__c'; //SFTRAC-2028
import MAKER_MODEL_FIELD from '@salesforce/schema/Vehicle_Detail__c.Maker_Model__c'; //SFTRAC-2028
import FATHER_NAME_FIELD from '@salesforce/schema/Vehicle_Detail__c.Father_Name__c'; //SFTRAC-2028
import PRESENT_ADDRESS_FIELD from '@salesforce/schema/Vehicle_Detail__c.Present_Address__c'; //SFTRAC-2028
import FINANCIER_NAME_FIELD from '@salesforce/schema/Vehicle_Detail__c.Financier_Name__c'; //SFTRAC-2028
import VEHICLE_CLASS_FIELD from '@salesforce/schema/Vehicle_Detail__c.Vehicle_Class__c'; //SFTRAC-2028
import RefinanceLabel from '@salesforce/label/c.Refinance';

//SFTRAC-2028 Start
export function getDateTimeValue(dateString){
    const dateParts = dateString.split(' ')[0].split('-');
    const timeParts = dateString.split(' ')[1].split(':');
    const finalDate = new Date(Date.UTC(
        dateParts[2], // Year
        dateParts[1] - 1, // Month (0-based index)
        dateParts[0], // Day
        timeParts[0], // Hours
        timeParts[1], // Minutes
        timeParts[2] // Seconds
    ));

    return finalDate.toISOString();
}
//SFTRAC-2028 End


export async function saveAssetDetailsTractor(ref){
    let finalAssetDetailsList = [];
    let saveStatus = {'allowedNavigate': false,'saveMessage': ''};
    ref.assetDetailList.forEach((item) => {
        try{
            let dealerName;
            let benCode;
            if(item.dealerSubDealerName){
                let splitBenCode = item.dealerSubDealerName.split('|');
                dealerName = splitBenCode[0];
                benCode = splitBenCode[1];
            }

            const fields = {};
            //SFTRAC-2028 Start
            fields[FITNESS_UPTO_FIELD.fieldApiName] = item.fitnessUpto;
            fields[REGISTRATION_DATE_FIELD.fieldApiName] = item.registrationDt;
            fields[DEALER_FIELD.fieldApiName] = item.dealer;
            fields[BODY_TYPE_FIELD.fieldApiName] = item.bodyType;
            fields[OWNER_SR_NO_FIELD.fieldApiName] = item.ownerSrNo;
            fields[MANUFACTURER_FIELD.fieldApiName] = item.manufacturer;
            fields[MAKER_MODEL_FIELD.fieldApiName] = item.makerModel;
            fields[FATHER_NAME_FIELD.fieldApiName] = item.fatherName;
            fields[PRESENT_ADDRESS_FIELD.fieldApiName] = item.presentAddress;
            fields[FINANCIER_NAME_FIELD.fieldApiName] = item.financierName;
            fields[VEHICLE_CLASS_FIELD.fieldApiName] = item.vehicleClass;
            //SFTRAC-2028 End
            //Save Operation - New and Used vehicle Type Common fields 
            fields[VEHICLE_TYPE_FIELD.fieldApiName] = item.vehicleType;
            fields[PRODUCT_FIELD.fieldApiName] = item.product; //-> 'C' 
            fields[MAKE_FIELD.fieldApiName] = item.make;
            fields[MAKE_CODE.fieldApiName] = item.makeCodeOfProduct;//CISP-2794
            fields[MODEL_FIELD.fieldApiName] = item.model;
            fields[MODEL_CODE.fieldApiName] = item.modelCodeOfProduct;//CISP-2794
            fields[VARIANT_FIELD.fieldApiName] = item.variant;
            fields[VARIANT_CODE.fieldApiName] = item.variantCodeOfProduct;//CISP-2794
            fields[PURPOSE_OF_PURCHANSE_FIELD.fieldApiName] = item.purposeOfPurchase;
            fields[DEALER_SUBDEALER_NAME_FIELD.fieldApiName] = dealerName;
            fields[BEN_CODE_FIELD.fieldApiName] = benCode;
            fields[INVOICE_IN_THE_NAME_FIELD.fieldApiName] = item.invoiceInNameOf;
            fields[VEHICLE_REGISTERED_NAME_FIELD.fieldApiName] = item.vehicleRegisteredInNameOf;
            fields[RC_HOLD_AMOUNT_FIELD.fieldApiName] = item.rcHoldAmount; //SFTRAC-1715
            //Used vehicle Type Specific fields
            // if (item.vehicleType === 'Used' || item.vehicleType === RefinanceLabel) {
                fields[USAGE_TYPE_FIELD.fieldApiName] = item.usageType;
                fields[VEHICLE_REG_NUMBER_FIELD.fieldApiName] = item.vehicleRegNoValue;
                fields[MANUFACTURER_YEAR_MONTH_FIELD.fieldApiName] = item.manufacturerYearAndMonth;
                fields[LAST_OWNER_NAME_FIELD.fieldApiName] = item.lastOwnerName;
                fields[ENGINE_NUMBER_FIELD.fieldApiName] = item.engineNumber;
                fields[CHASSIS_NUMBER_FIELD.fieldApiName] = item.chassisNumber;
                fields[LIEN_IN_FAVOR_FIELD.fieldApiName] = item.lienInFavorOf;
                fields[RC_RETENTION_APPLICABLE_FIELD.fieldApiName] = item.rcRetentionApplicable;
                fields[IS_GET_VEHICLE_DETAILS_SUCCESSFUL_FIELD.fieldApiName] = item.isGetVehicleDetailsSuccessful;

                //Restricted Picklist value check
                if (item.numberOfOwnerships) {
                    item.numberOfOwnershipsOptionsList.forEach((obj) => {
                        if (obj.value === item.numberOfOwnerships) {//CISP-2998
                            fields[NUMBER_OF_OWNERSHIP_FIELD.fieldApiName] = item.numberOfOwnerships;
                            return true;
                        }
                    });
                }

                //Vehicle Insurance Fields
                fields[INSURER_NAME_FIELD.fieldApiName] = item.insurerName;
                fields[INSURANCE_NUMBER_FIELD.fieldApiName] = item.insurancNumber;
                
                //Eligiible API fields
                fields[ELIGIBLE_LOAN_AMT_FIELD.fieldApiName] = item.eligibilityLoanAmount;
                fields[ELIGIBLE_TENURE_FIELD.fieldApiName] = item.tenureInMonths;

                //Vehicle Valuation Fields
                fields[OWNER_NAME_FIELD.fieldApiName] = item.lastOwnerName;
                fields[OWNER_CONTACT_FIELD.fieldApiName] = item.ownerContactNumber;
                fields[VEHICLE_PLACE_VALUATION_FIELD.fieldApiName] = item.vehiclePlaceOfValuation;
            // }

            fields[VEHICLE_ID_FIELD.fieldApiName] = item.vehicleDetailId;
            
            if(item.insIssuanceDate){
                // fields[INS_ISSUANCE_DATE_FIELD.fieldApiName] = item.insIssuanceDate;
                const dateFields = {};
                dateFields[VEHICLE_ID_FIELD.fieldApiName] = item.vehicleDetailId;
                dateFields[INS_ISSUANCE_DATE_FIELD.fieldApiName] = item.insIssuanceDate;
                ref.updateVehicleDateFields(dateFields);
            }
            if(item.insExpiryDate){
                // fields[INS_EXPIRY_DATE_FIELD.fieldApiName] = item.insExpiryDate;
                const dateFields = {};
                dateFields[VEHICLE_ID_FIELD.fieldApiName] = item.vehicleDetailId;
                dateFields[INS_EXPIRY_DATE_FIELD.fieldApiName] = item.insExpiryDate;
                ref.updateVehicleDateFields(dateFields);
            }

            finalAssetDetailsList.push(fields);
        }catch(error){
            console.log('Error in loading Asset Details:: ', error);
            ref.showSpinner = false;
            ref.showToastMessage(null, 'Error in saving details', 'Error');
            saveStatus.allowedNavigate = false;
            saveStatus.saveMessage = 'Navigation Fail';
            return;
        };
    });

    console.log('finalAssetDetailsList:::'+JSON.stringify(finalAssetDetailsList));

    await updateVehicleRecords({'vehicleList': JSON.stringify(finalAssetDetailsList), 'loanApplicationId': ref.recordid}).then((response)=>{
        console.log('response::'+response);
        ref.showSpinner = false;
        if(!ref.fromHome){
            navigateToNextModuleTractor(ref);
        }
        saveStatus.allowedNavigate = true;
        saveStatus.saveMessage = 'Navigation Success';
    }).catch(error => {
        console.log('Error in updating reocrd:: ', error);
        ref.showSpinner = false;
        ref.showToastMessage(null, 'Error in saving details', 'Error');
        saveStatus.allowedNavigate = false;
        saveStatus.saveMessage = 'Navigation Fail';
    });
    console.log('isTractor++ '+ref.isTractor+'this.recordid++ '+ref.recordid+ 'this.applicantId++ '+ref.applicantId );
    if(ref.isTractor && ref.assetCaseCreated == false){
        ref.assetCaseCreated = true;
        createCaseAVRecords({loanApplicationId : ref.recordid,applicantId :ref.applicantId, lastAssetOwnerId: null}).then(result =>{
            ref.assetCaseCreated = true;
        }).catch(error =>{
            ref.assetCaseCreated = false;
        })
    }
    
    return saveStatus;
}


export async function navigateToNextModuleTractor(ref) {
    try{
        let valid = await validateVehicleRecords({'loanApplicationId' : ref.recordid});
        if(valid == 'true'){
            let nextStage = 'Loan Details';
            for (let index = 0; index < ref.assetDetailList.length; index++) {
                const element = ref.assetDetailList[index];
                if(element.vehicleType === 'Used' || element.vehicleType === RefinanceLabel) {
                    nextStage = 'Vehicle Insurance';
                }
            }
            await changeStage({ stageName: nextStage, loanApplicationId: ref.recordid }).then(response => {

                if (response) {
                    console.log('Positive Response:: ', response);
                    ref.callLoanApplicationHistory(nextStage);
                } else {
                    console.log('Negative Response:: ', response);
                    ref.showToastMessage('Error in navigating to next module', null, 'error');
                }

                ref.showSpinner = false;
            }).catch(error => {
                console.log(error);
            });
        }else{
            console.log('valid ' , valid);
            ref.showToastMessage('Error in navigating to next module', valid, 'error');
        }
    }catch(error){
        console.log('error ',error);
        ref.showToastMessage('Error in navigating to next module', null, 'error');
    }
}