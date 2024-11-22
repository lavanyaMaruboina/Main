import { LightningElement, wire } from 'lwc';

import userId from '@salesforce/user/Id';
import CurrentUserRoleDevName from '@salesforce/schema/User.UserRole.DeveloperName';
import CurrentUserProfileName from '@salesforce/schema/User.Profile.Name';
import ExceptionMessage from '@salesforce/label/c.ExceptionMessage';

import getAccountTeamMembers from '@salesforce/apex/LwcLOSLoanApplicationCntrl.findAccountTeamMembers';
import getLoanApplicationRecords from '@salesforce/apex/IND_LWC_ReassignOwner.getLoanApplicationRecords';
import getFICaseRecords from '@salesforce/apex/IND_LWC_ReassignOwner.getFICaseRecords';
import getCMUCaseRecords from '@salesforce/apex/IND_LWC_ReassignOwner.getCMUCaseRecords';
import getReassignOwnerRecords from '@salesforce/apex/IND_LWC_ReassignOwner.getReassignOwnerRecords';
import submitReassignmentRequest from '@salesforce/apex/IND_LWC_ReassignOwner.submitReassignmentRequest';
import processReassignmentRequest from '@salesforce/apex/IND_LWC_ReassignOwner.processReassignmentRequest';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';

export default class IND_LWC_ReassignOwner extends LightningElement {

    isValidUser = true;
    hasApproverRole = true;
    forTwoWheeler = false;
    reassignOwnerData = {};
    showLandingOptions = true;
    showSearchOptions = false;
    showSearchResults = false;
    showNoRecordError = false;

    currentUserRole;
    selectedAction;
    selectedOption;
    blCodeValue;
    leadSourceValue;
    roleValue;
    leadNumberValue;
    benCodeValue;

    columns = [];
    tableData = [];
    pageSize = 20;
    selectedRows = [];

    showModal = false;
    isSpinnerMoving = false;
    isUserLookupDisabled = true;
    isMorethanOneRecordSelected = false;
    isUserSelected = false;
    selectedUserName;
    selectedUserId;

    blCodeOptionsList = [];
    roleOptionsList = [];
    leadSourceOptionsList = [
        { label: 'Salesforce', value: 'Salesforce' },
        { label: 'D2C', value: 'D2C' },
        { label: 'OLA', value: 'OLA' },
        { label: 'DSA', value: 'DSA' }
    ];

    optionsList = [
        { label: 'Lead Assignment', value: 'Lead Assignment' },
        { label: 'FI Case Assignment', value: 'FI Case Assignment' },
        { label: 'CMU Case Assignment', value: 'CMU Case Assignment' },
        { label: 'CVO Assignment', value: 'CVO Assignment' }
    ];

    actionList = [
        { label: 'Review Pending Request', value: 'Review Pending Request' },
        { label: 'Submit New Request', value: 'Submit New Request' }
    ];

    get options() {
        if (this.selectedAction == 'Submit New Request') {
            return this.optionsList;
        } else {
            return this.optionsList.filter(object => { return object.value !== 'CVO Assignment'; });
        }
    }

    get blCodeOptions() {
        if (this.currentUserRole == 'SCB') {
            return this.blCodeOptionsList.filter(object => { return (object.label).toLowerCase().includes('tw') });
        } else if (this.currentUserRole == 'SCM') {
            return this.blCodeOptionsList.filter(object => { return !(object.label).toLowerCase().includes('tw') });
        } else {
            return this.blCodeOptionsList;
        }
    }

    get leadSourceOptions() {
        if (this.forTwoWheeler) {
            return this.leadSourceOptionsList.filter(object => { return object.value !== 'DSA' && (this.selectedOption !== 'CMU Case Assignment' || object.value !== 'D2C'); });
        } else {
            return this.leadSourceOptionsList.filter(object => { return object.value !== 'OLA' && (this.selectedOption !== 'CMU Case Assignment' || object.value !== 'D2C'); });
        }
    }

    get roleOptions() {
        return this.roleOptionsList;
    }

    get isApproverScreen() {
        return this.selectedAction == 'Review Pending Request' && this.hasApproverRole;
    }

    get isSelectedActionInputDisabled() {
        return this.isValidUser ? false : true;
    }

    get isSelectedOptionInputDisabled() {
        if (!this.isValidUser || this.hasApproverRole) {
            return true;
        } else {
            return false;
        }
    }

    get isProceedButtonDisabled() {
        return (this.isValidUser && this.selectedOption != null && this.selectedOption != undefined) ? false : true;
    }

    get isBlCodeDisabled() {
        if(this.blCodeOptions.length > 0) {
            return false;
        } else {
            this.showToast("Error", 'You are not part of any account team', 'error');
            return true;
        }
    }

    get isLeadNumberDisabled() {
        return (this.checkInput(this.blCodeValue) && this.checkInput(this.leadSourceValue) && this.checkInput(this.roleValue)) ? false : true;
    }

    get isBenCodeDisabled() {
        return (this.checkInput(this.blCodeValue) && this.checkInput(this.leadSourceValue) && this.checkInput(this.roleValue)) ? false : true;
    }

    get isSearchButtonDisabled() {
        return (this.checkInput(this.blCodeValue) && this.checkInput(this.leadSourceValue) && this.checkInput(this.roleValue)) ? false : true;
    }

    get isChangeOwnerDisabled() {
        return (this.selectedRows.length > 0) ? false : true;
    }

    get isSubmitButtonDisabled() {
        return (this.isUserSelected) ? false : true;
    }

    get noRecordError() {
        return this.isApproverScreen ? 'No Pending Requests Found.' : 'Sorry, that filter combination has no results. Please try different criteria.';
    }

    @wire(getRecord, { recordId: userId, optionalFields: [CurrentUserRoleDevName, CurrentUserProfileName] })
    currentUserInfo({ error, data }) {
        if (data) {
            this.currentUserRole = data.fields.UserRole?.value.fields.DeveloperName.value;
            let currentUserProfile = data.fields.Profile?.value?.fields?.Name?.value;
            this.currentUserRole = (['IBL Partner Community CVO', 'IBL CVO'].includes(currentUserProfile)) ? 'CVO' : this.currentUserRole;
            this.hasApproverRole = (['SCB', 'SCM'].includes(this.currentUserRole)) ? true : false;
            
            if (!['CVO', 'SCB', 'SCM'].includes(this.currentUserRole)) {
                this.isValidUser = false;
                this.showToast("Error", 'You are not permitted to Reassign Owner.', 'error');
            }
        } else if (error) {
            this.isSpinnerMoving = false;
            this.showToast("Error", ExceptionMessage, 'error');
        }
    }

    connectedCallback() {
        getAccountTeamMembers({ uid: userId })
            .then(result => {
                let lstOption = [];
                for (let i = 0; i < result.length; i++) {
                    var rec = result[i].Account;
                    lstOption.push({ value: rec.Id, label: rec.Name });
                }
                this.blCodeOptionsList = lstOption;
                console.log('blCodeOptionsList: ' + JSON.stringify(this.blCodeOptionsList));
            })
            .catch(error => {
                this.isSpinnerMoving = false;
                this.isValidUser = false;
                console.log(error);
                this.showToast("Error", ExceptionMessage, 'error');
            });
    }

    handleActionChange(event) {
        this.selectedAction = event.detail.value;
        this.selectedOption = undefined;
        this.refs.selectedOptionInput.disabled = false;
    }

    handleOptionChange(event) {
        this.selectedOption = event.detail.value;
        this.reassignOwnerData.selectedOption = this.selectedOption;
    }

    handleLeadNumberChange(event) {
        this.leadNumberValue = event.detail.value;
    }

    handleBenCodeChange(event) {
        this.benCodeValue = event.detail.value;
    }

    handleBranchNameChange(event) {
        this.blCodeValue = event.detail.value;
        this.reassignOwnerData.blCodeValue = this.blCodeValue;
        this.leadSourceValue = undefined;
        this.forTwoWheeler = (event.target.options.find(opt => opt.value === event.detail.value).label).toLowerCase().includes('tw') ? true : false;
        this.refs.leadSourceInput.disabled = false;
        this.refs.teamRoleInput.disabled = true;
        this.roleValue = undefined;
    }

    handleLeadSourceChange(event) {
        this.leadSourceValue = event.detail.value;
        this.reassignOwnerData.leadSourceValue = (this.leadSourceValue == 'Salesforce' ? '' : this.leadSourceValue);
        this.roleValue = undefined;
        this.updateRoleOptions();
        this.refs.teamRoleInput.disabled = false;
    }

    handleRoleChange(event) {
        this.roleValue = event.detail.value;
        this.reassignOwnerData.roleValue = this.roleValue;
    }

    updateRoleOptions() {
        const optionsMapping = {
            'CVO Assignment': {
                'Salesforce': this.forTwoWheeler ? ['CVO'] : ['CVO'],
                'D2C': this.forTwoWheeler ? ['CVO'] : ['CVO'],
                'DSA': this.forTwoWheeler ? [] : ['CVO'],
                'OLA': this.forTwoWheeler ? ['CVO'] : []
            },
            'Lead Assignment': {
                'Salesforce': this.forTwoWheeler ? ['MA'] : ['CS', 'BE'],
                'D2C': this.forTwoWheeler ? ['MO'] : ['BE'],
                'DSA': this.forTwoWheeler ? [] : ['CS', 'BE'],
                'OLA': this.forTwoWheeler ? ['BE', 'PE'] : []
            },
            'FI Case Assignment': {
                'Salesforce': this.forTwoWheeler ? ['FI', 'MO', 'BE'] : ['BE'],
                'D2C': this.forTwoWheeler ? ['FI'] : ['BE'],
                'DSA': this.forTwoWheeler ? [] : ['BE'],
                'OLA': this.forTwoWheeler ? ['BE', 'PE'] : []
            },
            'CMU Case Assignment': {
                'Salesforce': this.forTwoWheeler ? ['MA'] : ['CS', 'BE'],
                'D2C': this.forTwoWheeler ? [] : [],
                'DSA': this.forTwoWheeler ? [] : ['CS', 'BE'],
                'OLA': this.forTwoWheeler ? ['BE', 'PE'] : []
            }
        };

        const selectedOptions = optionsMapping[this.selectedOption];
        const availableOptions = selectedOptions ? selectedOptions[this.leadSourceValue] || [] : [];

        this.roleOptionsList = this.createOptionsFromArray(availableOptions);
    }

    openModal() {
        console.log(this.selectedRows);
        this.isUserLookupDisabled = false;
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
        this.selectedUserName = null;
        this.selectedUserId = null;
        this.isUserSelected = false;
    }

    handleUpdateSelectedRowValues(event) {
        this.selectedRows = event.detail;
        if (this.selectedRows.length > 1) {
            this.isMorethanOneRecordSelected = true;
        }
    }

    handleUserSelection(event) {
        this.selectedUserName = event.detail.selectedValueName;
        this.selectedUserId = event.detail.selectedValueId;
        this.isUserSelected = true;
        console.log('In handleUserSelection');
    }

    clearUserSelection(event) {
        this.selectedUserName = event.detail.selectedValueName;
        this.selectedUserId = event.detail.selectedValueId;
        this.isUserSelected = false;
        console.log('In clearUserSelection');
    }

    handleProceed() {
        this.showLandingOptions = false;
        this.showSearchOptions = this.isApproverScreen ? false : true;

        if (this.isApproverScreen) {
            this.showNoRecordError = false;
            this.showSearchResults = false;
            this.fetchReassignOwnerRecords();
        }
    }

    handleSearch() {
        this.showNoRecordError = false;
        this.showSearchResults = false;
        if (this.selectedOption == 'Lead Assignment' || this.selectedOption == 'CVO Assignment') {
            this.fetchLoanApplicationRecords();
        } else if (this.selectedOption == 'FI Case Assignment') {
            this.fetchFICaseRecords();
        } else if (this.selectedOption == 'CMU Case Assignment') {
            this.fetchCMUCaseRecords();
        }
    }

    handleReassignRequest(event) {
        let isApproveRequest = event?.target?.dataset?.action == 'Approve' ? true : false;
        this.isSpinnerMoving = true;
        processReassignmentRequest({
            reassignmentType: this.selectedOption,
            selectedRecordIdList: this.selectedRows,
            isApproved: isApproveRequest
        }).then(response => {
            let data = JSON.parse(response);
            if (data.isSuccess) {
                if(isApproveRequest) {
                    this.showToast("Success", "Request processed successfully. All selected records will now be owned by the new assignee to whom the records were re-assigned.", "success");
                } else {
                    this.showToast("Success", "Request processed successfully. All selected records will remain assigned to the current owners.", "success");
                }
                setTimeout(() => {
                    this.handleHome();
                }, 2000); 
            } else {
                if (this.checkInput(data?.msg)) {
                    this.showToast("Error", data.msg, 'error');
                } else {
                    this.showToast("Error", ExceptionMessage, 'error');
                }
            }
            this.isSpinnerMoving = false;
        }).catch(error => {
            this.isSpinnerMoving = false;
            console.error('Error:', error);
            this.showToast("Error", ExceptionMessage, 'error');
        });
    }

    handleSubmit() {
        this.showModal = false;
        this.isSpinnerMoving = true;
        submitReassignmentRequest({
            reassignmentType: this.selectedOption,
            approverRole: this.forTwoWheeler ? 'SCB' : 'SCM',
            reassignmentRequestorId: userId,
            newOwnerId: this.selectedUserId,
            branchId: this.blCodeValue,
            selectedRecordIdList: this.selectedRows,
            autoApproveRequest: this.hasApproverRole
        }).then(response => {
            let data = JSON.parse(response);
            if (data.isSuccess) {
                if(this.hasApproverRole) {
                    if(this.selectedOption == 'CVO Assignment') {
                        this.showToast("Success", "Request submitted successfully. All such loan applications will now be owned by the new CVO to whom the applications were re-assigned.", "success");
                    } else {
                        this.showToast("Success", "Request submitted successfully. All selected records will now be owned by the new assignee to whom the records were re-assigned.", "success");
                    }
                } else {
                    this.showToast("Success", "Request submitted successfully. It has been assigned to your "+(this.forTwoWheeler ? 'SCB' : 'SCM')+" for validation.", "success");
                }
                setTimeout(() => {
                    this.handleHome();
                }, 2000); 
            } else {
                if (this.checkInput(data?.msg)) {
                    this.showToast("Error", data.msg, 'error');
                } else {
                    this.showToast("Error", ExceptionMessage, 'error');
                }
            }
            this.isSpinnerMoving = false;
        }).catch(error => {
            this.isSpinnerMoving = false;
            console.error('Error:', error);
            this.showToast("Error", ExceptionMessage, 'error');
        });
    }

    fetchLoanApplicationRecords() {
        this.isSpinnerMoving = true;
        getLoanApplicationRecords({
            reassignmentType: this.selectedOption,
            isTwoWheeler: this.forTwoWheeler,
            blCode: this.blCodeValue,
            leadSource: (this.leadSourceValue == 'Salesforce' ? '' : this.leadSourceValue),
            teamRole: this.roleValue,
            leadNumber: this.leadNumberValue,
            benCode: this.benCodeValue
        }).then(response => {
            if (response.length > 0) {
                this.tableData = JSON.parse(JSON.stringify(response));
                this.columns = [
                    { label: 'Branch Name', fieldName: 'Account.Name' },
                    { label: 'Lead Number', fieldName: 'Lead_number__c' },
                    { label: 'Ben Code', fieldName: 'Owner.EmployeeNumber' },
                    { label: 'Ben Name', fieldName: 'Owner.Name' },
                    { label: 'Status of the Ben Code', fieldName: 'Owner.IsActive' },
                ];

                this.tableData.forEach(function (temp) {
                    temp["Account.Name"] = temp?.Account?.Name;
                    temp["Owner.EmployeeNumber"] = temp?.Owner?.EmployeeNumber;
                    temp["Owner.Name"] = temp?.Owner?.Name;
                    temp["Owner.IsActive"] = temp?.Owner?.IsActive ? 'Active' : 'Inactive';
                });

                this.showSearchResults = true;
            } else {
                this.showNoRecordError = true;
            }
            this.isSpinnerMoving = false;
        }).catch(error => {
            this.isSpinnerMoving = false;
            console.error('Error:', error);
            this.showToast("Error", ExceptionMessage, 'error');
        });
    }

    fetchFICaseRecords() {
        this.isSpinnerMoving = true;
        getFICaseRecords({
            blCode: this.blCodeValue,
            leadSource: (this.leadSourceValue == 'Salesforce' ? '' : this.leadSourceValue),
            teamRole: this.roleValue,
            leadNumber: this.leadNumberValue,
            benCode: this.benCodeValue
        }).then(response => {
            if (response.length > 0) {
                this.tableData = JSON.parse(JSON.stringify(response));
                this.columns = [
                    { label: 'Branch Name', fieldName: 'Account.Name' },
                    { label: 'Lead Number', fieldName: 'Loan_Application__r.Lead_number__c' },
                    { label: 'Case Number', fieldName: 'CaseNumber' },
                    { label: 'Ben Code', fieldName: 'Owner.EmployeeNumber' },
                    { label: 'Ben Name', fieldName: 'Owner.Name' },
                    { label: 'Status of the Ben Code', fieldName: 'Owner.IsActive' },
                ];

                this.tableData.forEach(function (temp) {
                    temp["Account.Name"] = temp?.Account?.Name;
                    temp["Loan_Application__r.Lead_number__c"] = temp?.Loan_Application__r?.Lead_number__c;
                    temp["Owner.EmployeeNumber"] = temp?.Owner?.EmployeeNumber;
                    temp["Owner.Name"] = temp?.Owner?.Name;
                    temp["Owner.IsActive"] = temp?.Owner?.IsActive ? 'Active' : 'Inactive';
                });

                this.showSearchResults = true;
            } else {
                this.showNoRecordError = true;
            }
            this.isSpinnerMoving = false;
        }).catch(error => {
            this.isSpinnerMoving = false;
            console.error('Error:', error);
            this.showToast("Error", ExceptionMessage, 'error');
        });
    }

    fetchCMUCaseRecords() {
        this.isSpinnerMoving = true;
        getCMUCaseRecords({
            blCode: this.blCodeValue,
            leadSource: (this.leadSourceValue == 'Salesforce' ? '' : this.leadSourceValue),
            teamRole: this.roleValue,
            leadNumber: this.leadNumberValue,
            benCode: this.benCodeValue
        }).then(response => {
            if (response.length > 0) {
                this.tableData = JSON.parse(JSON.stringify(response));
                this.columns = [
                    { label: 'Branch Name', fieldName: 'Account.Name' },
                    { label: 'Lead Number', fieldName: 'Loan_Application__r.Lead_number__c' },
                    { label: 'Case Number', fieldName: 'CaseNumber' },
                    { label: 'Ben Code', fieldName: 'Owner.EmployeeNumber' },
                    { label: 'Ben Name', fieldName: 'Owner.Name' },
                    { label: 'Status of the Ben Code', fieldName: 'Owner.IsActive' },
                ];

                this.tableData.forEach(function (temp) {
                    temp["Account.Name"] = temp?.Account?.Name;
                    temp["Loan_Application__r.Lead_number__c"] = temp?.Loan_Application__r?.Lead_number__c;
                    temp["Owner.EmployeeNumber"] = temp?.Owner?.EmployeeNumber;
                    temp["Owner.Name"] = temp?.Owner?.Name;
                    temp["Owner.IsActive"] = temp?.Owner?.IsActive ? 'Active' : 'Inactive';
                });

                this.showSearchResults = true;
            } else {
                this.showNoRecordError = true;
            }
            this.isSpinnerMoving = false;
        }).catch(error => {
            this.isSpinnerMoving = false;
            console.error('Error:', error);
            this.showToast("Error", ExceptionMessage, 'error');
        });
    }

    fetchReassignOwnerRecords() {
        this.isSpinnerMoving = true;
        getReassignOwnerRecords({
            reassignmentType: this.selectedOption,
            reassignmentApprover: userId
        }).then(response => {
            if (response.length > 0) {
                this.tableData = JSON.parse(JSON.stringify(response));
                if (this.selectedOption == 'Lead Assignment') {
                    this.columns = [
                        { label: 'Branch Name', fieldName: 'Account.Name' },
                        { label: 'Lead Number', fieldName: 'Loan_Application__r.Lead_number__c' },
                        { label: 'Ben Code', fieldName: 'Owner.EmployeeNumber' },
                        { label: 'Ben Name', fieldName: 'Owner.Name' },
                        { label: 'Status of the Ben Code', fieldName: 'Owner.IsActive' },
                        { label: 'Ben Code of the assignee', fieldName: 'New_Record_Owner__r.EmployeeNumber' },
                        { label: 'Ben Name of the assignee', fieldName: 'New_Record_Owner__r.Name' },
                        { label: 'Status of the Ben Code of the assignee', fieldName: 'New_Record_Owner__r.IsActive' },
                    ];
                } else {
                    this.columns = [
                        { label: 'Branch Name', fieldName: 'Account.Name' },
                        { label: 'Lead Number', fieldName: 'Loan_Application__r.Lead_number__c' },
                        { label: 'Case Number', fieldName: 'Case__r.CaseNumber' },
                        { label: 'Ben Code', fieldName: 'Owner.EmployeeNumber' },
                        { label: 'Ben Name', fieldName: 'Owner.Name' },
                        { label: 'Status of the Ben Code', fieldName: 'Owner.IsActive' },
                        { label: 'Ben Code of the assignee', fieldName: 'New_Record_Owner__r.EmployeeNumber' },
                        { label: 'Ben Name of the assignee', fieldName: 'New_Record_Owner__r.Name' },
                        { label: 'Status of the Ben Code of the assignee', fieldName: 'New_Record_Owner__r.IsActive' },
                    ];
                }

                this.tableData.forEach((temp) => {
                    console.log('temp: ' + temp);
                    temp["Account.Name"] = temp?.Loan_Application__r?.Account?.Name;
                    temp["Loan_Application__r.Lead_number__c"] = temp?.Loan_Application__r?.Lead_number__c;
                    temp["Case__r.CaseNumber"] = temp?.Case__r?.CaseNumber;
                    temp["Owner.EmployeeNumber"] = this.selectedOption == 'Lead Assignment' ? temp?.Loan_Application__r?.Owner?.EmployeeNumber : temp?.Case__r?.Owner?.EmployeeNumber;
                    temp["Owner.Name"] = this.selectedOption == 'Lead Assignment' ? temp?.Loan_Application__r?.Owner?.Name : temp?.Case__r?.Owner?.Name;
                    temp["Owner.IsActive"] = this.selectedOption == 'Lead Assignment' && (temp?.Loan_Application__r?.Owner?.IsActive || temp?.Case__r?.Owner?.IsActive) ? 'Active' : 'Inactive';
                    temp["New_Record_Owner__r.EmployeeNumber"] = temp?.New_Record_Owner__r?.EmployeeNumber;
                    temp["New_Record_Owner__r.Name"] = temp?.New_Record_Owner__r?.Name;
                    temp["New_Record_Owner__r.IsActive"] = temp?.New_Record_Owner__r?.IsActive ? 'Active' : 'Inactive';
                });

                this.showSearchResults = true;
            } else {
                this.showNoRecordError = true;
            }
            this.isSpinnerMoving = false;
        }).catch(error => {
            this.isSpinnerMoving = false;
            console.error('Error:', error);
            this.showToast("Error", ExceptionMessage, 'error');
        });
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    handleHome() {
        window.location.reload();
    }

    checkInput(inputParam) {
        if (inputParam !== null && inputParam !== undefined && inputParam !== '' && !Number.isNaN(inputParam)) {
            return true;
        }
        else {
            return false;
        }
    }

    createOptionsFromArray(optionsArray) {
        return optionsArray.sort().map(item => ({ label: item, value: item }));
    }
}