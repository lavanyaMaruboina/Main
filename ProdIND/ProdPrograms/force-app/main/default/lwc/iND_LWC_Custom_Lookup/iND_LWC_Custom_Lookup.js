// import lookUp from '@salesforce/apex/CustomLookupCntrl.search';
import { api, LightningElement, track } from 'lwc';
import searchLookup from '@salesforce/apex/Ind_CustomLookupController.searchLookup';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class IND_LWC_Custom_Lookup extends LightningElement {
    @api isCustomClassNotApplicable = false;
    // D2C change - Raman
    @api inputdisabled;
    // EO D2C change
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
    @api index;
    @track records;
    @track blurTimeout;
    @api disableValue = false; // Pass this when you want to show lookUp Value in disable mode.
    //css
    @api isDisabled = false;

    @api
    setFilterTerm(value){
        this.filterTerm = value;
    }

    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track isRecordName;
    @track isCitycheck;
    connectedCallback() {
        if(this.isDisabled){this.inputdisabled = this.isDisabled;}
        if(!this.isCustomClassNotApplicable){
            if (FORM_FACTOR === 'Large') {
                this.inputClass = 'inputClassForPC';
            }
            if (FORM_FACTOR === 'Medium') {
                this.inputClass = 'inputClassForTab';
            }
            if (FORM_FACTOR === 'Small') {
                this.inputClass = 'inputClassForMobile';
            }
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
        var currentValues = { selectedValueId: selectedId, records: null, selectedValueName: selectedName, index : this.index};
        const valueSelectedEvent = new CustomEvent('lookupselected', { detail: currentValues });
        this.dispatchEvent(valueSelectedEvent);
        this.isValueSelected = true;
        this.selectedName = selectedName;
        if (this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    }

    handleRemovePill() {
        if(!this.disableValue) {
        this.filterTerm = "";
        this.searchTerm = "";
        this.isValueSelected = false;
        this.records = null;
        this.inputClass = 'slds-has-error';
        this.showHide = 'slds-show';
        var currentValues = { selectedValue: "", records: null, selectedValueName: "", index : this.index };
        const valueSelectedEvent = new CustomEvent('clearvalue', { detail: currentValues });
        this.dispatchEvent(valueSelectedEvent);
        }
    }

    onChange(event) {
        this.searchTerm = event.target.value;
        this.records = null;

        if (this.searchTerm.length >= 3) {
            searchLookup({ fetchField: this.fetchField, objectName: this.objectName, searchField: this.searchField, searchTerm: this.searchTerm, filterField: this.filterField, filterTerm: this.filterTerm })
                .then((result) => {
                    this.error = undefined;
                    this.records = result;
                    if(result.length>0 &&result[0].Name== undefined)
                    {
                        this.isCitycheck=true; 
                        this.isRecordName=false;
                    }
                    else{
                        this.isCitycheck=false; 
                        this.isRecordName=true;
                    }
                })
                .catch((error) => {
                    this.error = error;
                    this.records = undefined;
                    console.log("error", error)
                });
        }
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
}