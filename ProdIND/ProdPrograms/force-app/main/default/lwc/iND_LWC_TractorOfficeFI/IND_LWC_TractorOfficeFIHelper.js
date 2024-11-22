/* eslint-disable */
import checkFIRetryExhausted from '@salesforce/apex/LwcLOSGattingAndScreeningCntrl.checkRetryExhausted'; //SFTRAC-1810
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, updateRecord,getRelatedListRecords,getFieldValue} from 'lightning/uiRecordApi';

export function populateLatLon(ref){
    ref.isSpinnerMoving = true;
    checkFIRetryExhausted({
        loanApplicationId: ref.applicationId, attemptFor: 'FI Latitude Longitude', applicantId: ref.applicantId, moduleName: 'Tractor Office FI Case', mtDataName: 'FI_Retry_Count'
    }) //SFTRAC-1810 Implementation
    .then(response => {
        ref.isSpinnerMoving = false;
        if (response === 'Failure') {
            console.log('FI Retry Check :: FAILURE ');
        } else if (response === 'Retry attempts are exhausted.') {
            ref.fiLatLonRetryExhausted = true;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'FI Location '+response,
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

    //SFTRAC-1880 # New START
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
   //SFTRAC-1880 # New End