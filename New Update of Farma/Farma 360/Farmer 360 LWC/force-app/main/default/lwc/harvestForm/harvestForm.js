import { LightningElement, track } from 'lwc';
import createHarvestRecord from '@salesforce/apex/HarvestController.createHarvestRecord';

export default class HarvestRecordForm extends LightningElement {
    // Define @track variables to bind with input fields
    @track adgGrams;
    @track cumulativeFeed;
    @track density;
    @track densityAfterHarvest;
    @track densityAfterSurvival;
    @track doc;
    @track fcr;
    @track lastWeekABW;
    @track partial1Biomass;
    @track partial1Count;
    @track partial2Biomass;
    @track partial2Count;
    @track partial3Biomass;
    @track partial3Count;
    @track pondStatus;
    @track presentFinalCount;
    @track remarks;
    @track salinity;
    @track stockingDensity;
    @track weeklyGrowth;
    @track contactId;

    // Function to handle input change for all input fields
    handleInputChange(event) {
        // Update the respective variable on input change
        this[event.target.name] = event.target.value;
    }
      handleContactChange(event) {
        this.contactId = event.detail.value;
    }
    // Function to save the record when the Save button is clicked
    saveRecord() {
        // Call the Apex method to save the harvest record
        createHarvestRecord({ 
            adgGrams: this.adgGrams,
            cumulativeFeed: this.cumulativeFeed,
            density: this.density,
            densityAfterHarvest: this.densityAfterHarvest,
            densityAfterSurvival: this.densityAfterSurvival,
            doc: this.doc,
            fcr: this.fcr,
            lastWeekABW: this.lastWeekABW,
            partial1Biomass: this.partial1Biomass,
            partial1Count: this.partial1Count,
            partial2Biomass: this.partial2Biomass,
            partial2Count: this.partial2Count,
            partial3Biomass: this.partial3Biomass,
            partial3Count: this.partial3Count,
            pondStatus: this.pondStatus,
            presentFinalCount: this.presentFinalCount,
            remarks: this.remarks,
            salinity: this.salinity,
            stockingDensity: this.stockingDensity,
            weeklyGrowth: this.weeklyGrowth,
            contactId: this.contactId
        })
        .then(result => {
            // Handle success - log the success message to the console
            console.log('Record saved successfully: ' + result);
        })
        .catch(error => {
            // Handle error - log the error message to the console
            console.error('Error saving record: ' + error);
        });
    }
}