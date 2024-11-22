import { LightningElement, api, track } from 'lwc';

export default class IND_LWC_InputFieldForAdditionalDocuments extends LightningElement {
    @api fieldLabel;
    @api fieldName;
    @api fieldVal;
    @api fieldType;
    @api isPicklist;
    @track _fieldOptions = [];
    @api fieldOptions;
    @api fieldDisabled;

    get isPicklistType() {
        return this.isPicklist == 'true';
    }
    connectedCallback(){
        if(this.fieldOptions && this.fieldOptions.length > 0){
            let fieldOptions = [];
            this.fieldOptions.forEach(element => {
                fieldOptions.push({label : element.label, value : element.value});
            });
            this._fieldOptions = fieldOptions;
        }
        console.log('_fieldOptions ' + this._fieldOptions);
    }

    handleInputFieldChange(event) {
        this.fieldVal = event.target.value;
        const changeEvent = new CustomEvent('changeval', {
            detail: {
                name : event.target.name,
                value : event.target.value
            }
        });
        this.dispatchEvent(changeEvent);
    }
    @api getInput() {
        return this.template.querySelector('[data-id="'+this.fieldName+'"]');
    }
}