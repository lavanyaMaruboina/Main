import {wire, api, LightningElement, track } from 'lwc';
import searchLookupWithArray from '@salesforce/apex/Ind_CustomLookupController.searchLookupWithArray';
import getUsersFromQueue from '@salesforce/apex/IND_LWC_ChangeCaseOwner.getUsersFromQueue';
import getEligibleUsersForRevokedApplication from '@salesforce/apex/IND_RevokeController.getEligibleUsersForRevokedApplication'; //CISP-4628
import getEligibleUserRecords from '@salesforce/apex/IND_LWC_ReassignOwner.getEligibleUserRecords'; //CISP-10070
import FORM_FACTOR from '@salesforce/client/formFactor';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import Account_INVESTIGATION_OBJECT from '@salesforce/schema/Account';
import STATE_FIELD from '@salesforce/schema/Account.State__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class GenericCustomLookup extends LightningElement {
    @api iconName;
    @api filter = '';
    @api searchPlaceholder = 'Search';
    @api recordId;
    @api fetchField;
    @api objectName;
    @api searchField;
    @api searchTerm;
    @api filterField;
    @api filterTerm;
    @api selectFieldName;
    @api selectedName;
    @api isValueSelected;
    @api showHide = 'slds-hide';
    @api inputClass = '';
    @api smallInput = false;
    @api caseCurrentOwnerId;
    @track records =[];
    @track blurTimeout;
    @api disableValue = false; // Pass this when you want to show lookUp Value in disable mode.
    //css
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @api isCustomLookupFieldDisabled=false;
    @api empCodOptions = [];
    @api empOption =[];
    @api selectedUserId;
    @api switchCode = '';
    @api isGetUsersFromQueue = false; //CISP-7811
    @api queueId;   //CISP-7811
    @api isCalledFromRevoke = false; //CISP-4628
    @api isCalledFromReassignOwner = false; //CISP-10070
    @api parentData = {}; //CISP-4628
    @api filterMultipleTerm;
    @api filterMultipleFieldName;

    timeOut = null; //CISP-4628
    @track statePicklist =[];
    @wire (getObjectInfo, { objectApiName: Account_INVESTIGATION_OBJECT }) fiMetadata;

    @wire(getPicklistValues,{
        recordTypeId: '$fiMetadata.data.defaultRecordTypeId', 
        fieldApiName: STATE_FIELD})    
        statePicklist({ error, data }) {
        if (data) {
           this.statePicklist = data;
          
        }
    }

    connectedCallback() {
        if(this.smallInput == false){
            if (FORM_FACTOR === 'Large') {
                this.inputClass = 'inputClassForPC';
            }
            if (FORM_FACTOR === 'Medium') {
                this.inputClass = 'inputClassForTab';
            }
            if (FORM_FACTOR === 'Small') {
                this.inputClass = 'inputClassForMobile';
            }

        
        }else{
            this.inputClass = '';
        }
    }

    handleClick() {
        this.searchTerm = '';
        this.inputClass = 'slds-has-focus';
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
    }

    onBlur() {
        this.blurTimeout = setTimeout(() => { this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-has-error' }, 300);
        this.showHide = 'slds-show';
    }

    onSelect(event) {
       
        let selectedId = event.currentTarget.dataset.id;        
        let selectedName = event.currentTarget.dataset.name;        
        var currentValues = { selectedValueId: selectedId, records: this.records, selectedValueName: selectedName };
        const valueSelectedEvent = new CustomEvent('lookupselected', { detail: currentValues }, { bubbles: true });
        this.dispatchEvent(valueSelectedEvent);
        this.isValueSelected = true;
        this.selectedName = selectedName;       
        if (this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    }

    handleRemovePill() { console.log('Remove handleRemovePill');
        if(!this.disableValue) {
        this.searchTerm = "";
        this.isValueSelected = false;
        this.records = null;
        var currentValues = { selectedValue: "", records: null, selectedValueName: "" };
        const valueSelectedEvent = new CustomEvent('clearvalue', { detail: currentValues });
        this.dispatchEvent(valueSelectedEvent);
        this.inputClass = 'slds-has-error';
        this.showHide = 'slds-show';
        //this.filterTerm = "";
        }
    }

    onChange(event) {
        
        this.searchTerm = event.target.value;
        this.records = null;
        (event.target).addEventListener('keyup', this.debounce(() => {          
        if (this.searchTerm.length >= 3) {   
            console.log('filterField::',this.filterField);
            console.log('filterTerm::',this.filterTerm);         
            //CISP-7811 added bypass for the change case owner functionality as the current implementation of custom lookup does not support  record filtering in SOQL queries using IN clause
            if(this.isGetUsersFromQueue) {
                getUsersFromQueue({queueId: this.queueId, searchField: this.searchField, searchTerm: this.searchTerm})
                .then((result) => {
                    console.log('result::',result);  
                    this.error = undefined;
                    
                   
                    let options = [];
                    result.forEach(function (item) {
                        options.push({
                            Id: item.Id,
                            Name: item.Name
                        });                   
                    });
                    this.records = options;
                })
                .catch((error) => {
                    this.error = error;
                    this.records = undefined;
                    console.log("error", error)
                });
            } else if(this.isCalledFromRevoke) {
                getEligibleUsersForRevokedApplication({branchAccountId: this.parentData.branchAccountId, searchTerm: this.searchTerm })
                    .then((result) => {
                        console.log('result::', result);
                        if (result?.length > 0) {
                            this.error = undefined;
                            let options = [];
                            result.forEach(function (item) {
                                options.push({
                                    Id: item.UserId,
                                    Name: item.EmployeeNumber + ' | ' +item.Name
                                });
                            });
                            this.records = options;
                            console.log('records', this.records);
                        } else {
                            this.showNoRecordsFoundError();
                        }

                    })
                    .catch((error) => {
                        this.error = error;
                        this.records = undefined;
                        console.log("error", error)
                    });
            } else if(this.isCalledFromReassignOwner) {
                getEligibleUserRecords({ reassignmentType: this.parentData.selectedOption, leadSource: this.parentData.leadSourceValue, teamRole: this.parentData.roleValue, branchAccountId: this.parentData.blCodeValue, searchTerm: this.searchTerm })
                .then((result) => {
                    console.log('result::', result);
                    if (result?.length > 0) {
                        this.error = undefined;
                        let options = [];
                        result.forEach(function (item) {
                            options.push({
                                Id: item.UserId,
                                Name: item.EmployeeNumber + ' | ' +item.Name
                            });
                        });
                        this.records = options;
                        console.log('records', this.records);
                    } else {
                        this.showNoRecordsFoundError();
                    }

                })
                .catch((error) => {
                    this.error = error;
                    this.records = undefined;
                    console.log("error", error)
                });
            }
                else {
                searchLookupWithArray({ fetchField: this.fetchField, objectName: this.objectName, 
                    searchField: this.searchField, searchTerm: this.searchTerm, 
                    filterField: this.filterField, filterTerm: this.filterTerm, filterMultipleTerm : this.filterMultipleTerm, filterMultipleFieldName : this.filterMultipleFieldName })
                    .then((result) => {
                        console.log('result::',result);  
                        this.error = undefined;
                        let options = [];    
                        if(this.objectName === 'CFD_State_Master__c') {
                            result.forEach(function (item) {
                                options.push({
                                    Id: item.Id,
                                    Name: item.Name
                                });                   
                            });
                        } else if(this.objectName === 'Account') {
                            result.forEach(function (item) {
                                options.push({
                                    Id: item.Id,
                                    Name: item.Name
                                });                   
                            });
                        }
                        else if(this.switchCode == 'empName') {
                            let thisins = this;
                            result.forEach(function (item) {
                                if(item.UserId != thisins.caseCurrentOwnerId){
                                    options.push({
                                        Id: item.UserId,
                                        Name: item.User.Name + ' - ' + item.User.EmployeeNumber,
                                        EmpCode :  item.User.EmployeeNumber
                                    });  
                                }
                            });
                        }
                        else if(this.switchCode == 'empCode') {
                            let thisins = this;
                            result.forEach(function (item) {
                                if(item.UserId != thisins.caseCurrentOwnerId){
                                    options.push({
                                        Id: item.UserId,
                                        Name: item.User.Name + ' - ' + item.User.EmployeeNumber,
                                        EmpCode :  item.User.EmployeeNumber,
                                    });                   
                                }
                            });
                        }
                        else if(this.switchCode == 'userCode') {
                            result.forEach(function (item) {
                                    options.push({
                                        Id: item.UserId,
                                        Name: item.User.Name
                                    });                   
                                
                            });
                        }
                        else {
                            result.forEach(function (item) {
                                options.push({
                                    Id: item.Id,
                                    Name: item.Name
                                });                   
                            });
                        }
                        this.records = options;
                        console.log('records', this.records);
                    })
                    .catch((error) => {
                        this.error = error;
                        this.records = undefined;
                        console.log("error", error)
                    });
            }  

            }
        }, 1000)); /*CISP-4628 End*/
        
    }

    @api displayValidityError() {
        if (this.selectedName === '') {
            this.inputClass = 'slds-has-error'
            this.showHide = 'slds-show';
        }
    }

    @api makeCityBlank() {
        this.handleRemovePill();
        this.showHide = 'slds-hide';
        this.inputClass = "";
    }
    //CISP-4628 Start
    debounce(callback, wait) {

        return (...args) => {
            clearTimeout(this.timeOut);
            this.timeOut = setTimeout(function () {
                callback.apply(this, args);
            }, wait);
        };
    }

    showNoRecordsFoundError() {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message: 'No eligible user records were found based on the provided search criteria.',
            variant: 'error'
        }));
    }
    //CISP-4628 End
}