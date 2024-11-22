/* eslint-disable no-extra-bind */
import checkFIRetryExhausted from '@salesforce/apex/LwcLOSGattingAndScreeningCntrl.checkRetryExhausted'; //SFTRAC-1810
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRecordWithGeoLocation from '@salesforce/apex/iND_TF_FI_DetailsController.getRecordWithGeoLocation'; //SFTRAC-1880
import createDocumentRecord from '@salesforce/apex/IND_ResidenceFIController.createDocumentRecord';
import { getRecord, updateRecord,getRelatedListRecords, getFieldValue} from 'lightning/uiRecordApi';

export function populateLatLon(ref){
    ref.isSpinnerMoving = true;
    checkFIRetryExhausted({
        loanApplicationId: ref.applicationId, attemptFor: 'FI Latitude Longitude', applicantId: ref.applicantId, moduleName: 'Tractor FI Case', mtDataName: 'FI_Retry_Count'
    }) //SFTRAC-1810 Implementation
    .then(response => {
        ref.isSpinnerMoving = false;
        if (response === 'Failure') {
            console.log('FI Retry Check :: FAILURE ');
        } else if (response === 'Retry attempts are exhausted.') {
            ref.fiLatLonRetryExhausted = true;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'FI Location'+response,
                variant: 'error',
            });
            ref.dispatchEvent(evt);
        } else if (response === 'Success') {
            console.log('FI Retry Check :: SUCCESS');
            fetchCoords(ref);
        }
    })
    .catch(err => {
        ref.isSpinnerMoving = false;
        console.log('error in bureaPull:', err);
        const evt = new ShowToastEvent({
            title: 'Kindly Retry',
            variant: 'error',
        });
        ref.dispatchEvent(evt);
    });
}

    async function fetchCoords(ref){
        await navigator.geolocation.getCurrentPosition(
            function (position) {
                ref.filattitude = position.coords.latitude;
                ref.filongitude = position.coords.longitude;
                ref.init();
            }.bind(ref),function (e) {
                ref.showToast('Warning!', 'Please give location access to browser', 'warning', 'dismissable');
            }.bind(ref),{
            enableHighAccuracy: true,
            }
        );
    }

    function openUploadComp(recordType, ref){
        ref.showUpload = ref.isSubmitDisabled ? false: true;
        ref.showDocView = true;
        ref.isVehicleDoc = true;
        ref.isAllDocType = false;
        ref.sendingRecordTypeName = recordType;
        if(ref.isSubmitDisabled){
            ref.viewDocFlag = true;
        }else{
            ref.uploadViewDocFlag = true;
        }
        ref.functionality = 'ACH';
        ref.isSpinnerMoving = false;

    }

    export async function createDocument(docType, recordType, ref) {
        await createDocumentRecord({ caseId: ref.fiRecordId, applicantId: ref.applicantId, loanApplicationId: ref.applicationId, documentType: docType, recordTypeName: recordType })
            .then((response) => {
                console.log('response ', response);
                ref.documentId = response;
                openUploadComp(recordType, ref);//CISP-2975
            })
            .catch((error) => {
                if (error.body.message) {
                    this.showToast('Error!', error.body.message, 'error', 'sticky');
                } else {
                    this.showToast('Error!', 'Something went wrong, Please contact System Administrator', 'error', 'sticky');
                }
                ref.isSpinnerMoving = false;
            });       
    }


    //SFTRAC-1880 Start
    export async function fetchFIRecords(ref) {
        ref.isSpinnerMoving = true;
        await getRecordWithGeoLocation({ recordId: ref.fiRecordId })
            .then(result => {
                ref.isSpinnerMoving = false;
                console.log('FI Location Received >>'+JSON.stringify(result));
                ref.filattitude = result?.FI_Location__Latitude__s;
                ref.filongitude = result?.FI_Location__Longitude__s;
            })
            .catch(error => {
                ref.isSpinnerMoving = false;
                ref.errorMessage = 'An error occurred: ' + error.body.message;
                console.error('Error:', error);
            });
    }
    //SFTRAC-1880 End

    //SFTRAC-1880#New START
    export function handleSubmitClicked(ref){
        ref.isSpinnerMoving = true;
        ref.isSubmitCalled = true;
        ref.loanInfoTableDisabled = true;
        ref.SubmitDisabled = true;

        if (ref.borrowerFlag){
            let loanDetails = ref.template.querySelectorAll('c-l-w-c_-l-o-s_-loan-informationfi-details');
            if(loanDetails && loanDetails.length > 0){
                let isValidLoanDetails = true;
                for (let index = 0; index < loanDetails.length; index++) {
                    if(loanDetails[index] && loanDetails[index].saveRows()){
                        isValidLoanDetails = false;
                    }
                }
                if(!isValidLoanDetails){
                    ref.isSpinnerMoving = false;
                    ref.SubmitDisabled = false;
                    ref.loanInfoTableDisabled = false;
                    return;
                }
            }
        }
        if(!ref.isSave){
            const evt = new ShowToastEvent({
                title: 'Warning',
                message: 'FI record should be Save before clicking on Submit',
                variant: 'warning',
            });
            ref.dispatchEvent(evt);
            
            ref.isSpinnerMoving = false;
            ref.isSubmitCalled = false;
            ref.SubmitDisabled = false;

            return;
        }else{
            ref.saveFIPage();
        }
    }
    //SFTRAC-1880#New END

    //SFTRAC-1880#New START
    export function onSaveFI(ref){
         //SFTRAC-1880 New START
         const fields = {};
         fields['Id'] = ref.fiRecordId; // update FI record
         fields['Is_Save__c'] = true;
         const recordInput = {
             fields
         };
         updateRecord(recordInput).then(result=>{
             if(result){
                 try {
                    ref.isSave = true;
                    ref.isDisabled = true;
                    ref.handleDisableScreenOnSave();
                    ref.isSpinnerMoving = false;
                 } catch (error) {
                    ref.showToast('Error!', 'Something went wrong!', 'error', 'sticky');
                    ref.isSpinnerMoving = false;
                 }
             }
         }).catch(error=>{
            ref.showToast('Error!', 'Something went wrong!', 'error', 'sticky');
            ref.SubmitDisabled = false;
            ref.isSpinnerMoving = false;
         });
    }
    //SFTRAC-1880#New End