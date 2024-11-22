import { LightningElement, api, track } from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import getViabilityDetails from '@salesforce/apex/ViewCamControllerAdditional.getViabilityDetails';

export default class IND_LWC_CAMViewViability extends NavigationMixin(LightningElement) {
  @api recordId; // Loan Application Id
  @api vehicleId;
   viabilityDetails;
   firstViabilityDetail; // To store the first viability detail
   hasViabilityDetails = false;  // Boolean to check if viability details exist
   loading = true;

  // Called when the component is initialized
  connectedCallback() {
    if (this.recordId && this.vehicleId) {
      this.fetchViabilityDetails();
    }
  }

  // Close button functionality
  handleCloseButton() {
    window.close();  // Close the popup
  }

  // Method to fetch viability details from Apex
  fetchViabilityDetails() {
    this.loading = true;
    console.log('@@@recordId22 ',this.recordId);
    console.log('@@@vehicleId222 ',this.vehicleId);
    getViabilityDetails({ recordId: this.recordId, vehicleId: this.vehicleId })
      .then(response => {
        if (response && response.length > 0) {
          this.viabilityDetails = response;
          this.firstViabilityDetail = response[0];  // Extract the first record
          this.hasViabilityDetails = true;
        }
        this.loading = false;
      })
      .catch(error => {
        console.error('Error fetching viability details:', error);
        this.loading = false;
      });
  }
}