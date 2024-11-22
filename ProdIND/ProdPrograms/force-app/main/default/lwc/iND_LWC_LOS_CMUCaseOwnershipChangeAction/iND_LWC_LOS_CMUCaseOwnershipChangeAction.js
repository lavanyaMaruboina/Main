import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecordNotifyChange } from "lightning/uiRecordApi";
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getUserList from '@salesforce/apex/IND_CMUCaseOwnershipChangeActionCntrl.getUserList';
import updateOwner from '@salesforce/apex/IND_CMUCaseOwnershipChangeActionCntrl.updateOwner';

export default class IND_LWC_LOS_CMUCaseOwnershipChangeAction extends NavigationMixin(LightningElement) {
    @api recordId;
    @track userOptionsList = [];
    @track selectedUserId;
    selectedUserName;

    async connectedCallback(){
        await this.recordId;
        await this.init();
    }

    async init(){
        console.log('Record ID:: ', this.recordId);

        await getUserList({recordId: this.recordId}).then(response => {
            let result = JSON.parse(response);
            console.log('Get User List - result:: ', result);

            if(result.status){
                let userList = result.userList;
                
                this.userOptionsList = userList.map(function (obj) {
                    return { label: obj.Name, value: obj.Id };
                });
            } else {
                this.showToastMessage('Error', result.message, 'error');
            }
            console.log('User List:: ', this.userOptionsList);
        }).catch(error => {
            console.log("Error in Getting User Details:: ", error);
            this.showToast('Error', 'Please contact System Administrator', 'error');
        });
    }

    handleUserChange(event) {
        this.selectedUserId = event.target.value;
        this.selectedUserName = event.target.options.find(opt => opt.value === event.detail.value).label;

        console.log('selectedUserName:: ', this.selectedUserName);
    }

    updateOwner(){
        console.log('Select Owner::', this.selectedUserId);

        if(!this.selectedUserId){
            this.showToast('Error', 'Enter a new owner for this record', 'error');
        } else {
            updateOwner({recordId: this.recordId, userId: this.selectedUserId}).then(response => {
                const result = JSON.parse(response);
                console.log('updateOwner - Response::', response);

                if(result.status){
                    this.showToastMessage('Success', this.selectedUserName + ' ' + result.message, 'success');
                    getRecordNotifyChange([{recordId: this.recordId}]);
                    this.dispatchEvent(new CloseActionScreenEvent());
                } else {
                    this.showToastMessage('Error', result.message, 'error');
                }
            }).catch(error => {
                console.log('error::',error)
                this.showToastMessage('Error', error?.body?.message, 'error');
            });
        }
    }

    showToastMessage(title, message, variant) {
        if (title) {
            this.dispatchEvent(new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            }));
        } else {
            this.dispatchEvent(new ShowToastEvent({
                message: message,
                variant: variant,
            }));
        }
    }
}