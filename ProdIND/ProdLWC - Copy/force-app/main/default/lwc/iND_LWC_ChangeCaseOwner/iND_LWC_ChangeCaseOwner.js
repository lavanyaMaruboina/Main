import { LightningElement, wire, api, track } from 'lwc';

import Id from '@salesforce/user/Id';
import USER_NAME from '@salesforce/schema/User.Name';
import USER_OR_GROUP_ID from '@salesforce/schema/GroupMember.UserOrGroupId';
import CurrentUserRoleDevName from '@salesforce/schema/User.UserRole.DeveloperName';

import getCMUQueueId from '@salesforce/apex/IND_LWC_ChangeCaseOwner.getCMUQueueId';
import changeCaseOwner from '@salesforce/apex/IND_LWC_ChangeCaseOwner.changeCaseOwner';
import validateCaseRecordType from '@salesforce/apex/IND_LWC_ChangeCaseOwner.validateCaseRecordType';

import { getRecord } from 'lightning/uiRecordApi';

export default class IND_LWC_ChangeCaseOwner extends LightningElement {
	@api listViewIds = [];
	selectedUserName;
	selectedUserId;
	total = 0;
	isMorethanOneCaseSelected = false;
	isCustomLookupDisabled = true;
	isSubmitButtonDisabled = true;
	isUserSelected = false;
	cmuQueueId;
	USER_NAME_FIELD = USER_NAME.fieldApiName;
	USER_OR_GROUP_ID_FIELD = USER_OR_GROUP_ID.fieldApiName;
	msg = '';
	msgTheme = 'slds-theme_error';
	currentUserRole;

	@wire(getRecord, { recordId: Id, fields: [CurrentUserRoleDevName] })
	currentUserInfo({ error, data }) {
		if (data) {
			this.currentUserRole = data.fields.UserRole.value.fields.DeveloperName.value;
			if (this.currentUserRole != 'CMU_Team_Lead') {
				this.msgTheme = 'slds-theme_error';
				this.msg = 'You are not permitted to change the owner.';
			} else {
				if (this.total === 0) {
					this.msgTheme = 'slds-theme_error';
					this.msg = 'Select at least one record and try again.';
					this.isSubmitButtonDisabled = true;
				}
				if (this.total > 0) {
					this.isCustomLookupDisabled = false;
				}
				if (this.total > 1) {
					this.isMorethanOneCaseSelected = true;
				}

				validateCaseRecordType({ selectedCaseList: this.listViewIds })
					.then(result => {
						if (result == false) {
							this.msgTheme = 'slds-theme_error';
							this.msg = 'One or more than one of the selected cases is not a CMU Request case.';
						}
					})
					.catch(error => {
						console.log(error);
					});

				getCMUQueueId()
					.then(result => {
						this.cmuQueueId = result;
					})
					.catch(error => {
						console.log(error);
					});
			}
		} else if (error) {
			this.error = error;
		}
	}

	connectedCallback() {
		this.msg = '';
		this.total = this.listViewIds.length;
	}

	selectedStateHandler(event) {
		this.selectedUserName = event.detail.selectedValueName;
		this.selectedUserId = event.detail.selectedValueId;
		this.isUserSelected = true;
		this.empCodeOptionEnabled = true;

		if (this.total > 0) {
			this.isSubmitButtonDisabled = false;
		}
	}

	clearStateHandler(event) {
		this.selectedUserName = event.detail.selectedValueName;
		this.selectedUserId = event.detail.selectedValueId;
		this.isSubmitButtonDisabled = true;
	}

	updateCaseOwner() {
		this.isSubmitButtonDisabled = true;
		changeCaseOwner({ selectedCaseList: this.listViewIds, newOwnerId: this.selectedUserId })
			.then((result) => {
				if (result == 'Success') {
					this.msgTheme = 'slds-theme_success';
					if (this.isMorethanOneCaseSelected) {
						this.msg = this.total + ' case owners have been changed.';
					} else {
						this.msg = this.total + ' case owner has been changed.';
					}
				}
			})
			.catch((error) => {
				this.msgTheme = 'slds-theme_error'; 
				this.msg = 'Something went wrong please try again.'; 
				console.log("error", error);  
			});

		setTimeout(() => {
			this.close();
		}, 3000);

	}

	close() {
		setTimeout(
			function () {
				window.history.back();
			},
			500
		);
	}
}