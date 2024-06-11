import insertActivity from "@salesforce/apex/ActivityDateTime.insertactivity";
import OPPORTUNITY_OBJECT from "@salesforce/schema/Opportunity";
import ACTIVITY_FIELD from "@salesforce/schema/Opportunity.Activity_Date_Time__c";
import { LightningElement, api, track } from 'lwc';

const STORAGE_KEY_PREFIX = 'activityDateTime_';

export default class ActivityDateTime extends LightningElement {
    @api recordId;
    objectName = OPPORTUNITY_OBJECT;
    oppActivity = ACTIVITY_FIELD;
    @track rec = {
        [this.oppActivity.fieldApiName]: null
    };

    get storageKey() {
        return `${STORAGE_KEY_PREFIX}${this.recordId}`;
    }

    get formattedDateTime() {
        return this.rec[this.oppActivity.fieldApiName] || '';
    }

    connectedCallback() {
        // Retrieve stored Activity Date&Time on component initialization
        const storedValue = localStorage.getItem(this.storageKey);
        if (storedValue) {
            this.rec[this.oppActivity.fieldApiName] = storedValue;
        }
    }

    changeHandler(event) {
        let { name, value } = event.target;
        if (name === "activity") {
            this.rec[this.oppActivity.fieldApiName] = value;
            // Store the entered value in local storage
            localStorage.setItem(this.storageKey, value);
            this.createRecord();
        }
    }

    createRecord() {
        if (this.rec[this.oppActivity.fieldApiName]) {
            insertActivity({
                recordId: this.recordId,
                activityDateTime: this.rec[this.oppActivity.fieldApiName]
            })
            .then((data) => {
                console.log(data);
            })
            .catch((error) => {
                console.log(error);
            });
        }
    }
}