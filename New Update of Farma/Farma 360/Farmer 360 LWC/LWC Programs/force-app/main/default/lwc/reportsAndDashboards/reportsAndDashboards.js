import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class ReportsAndDashboards extends NavigationMixin (LightningElement) {

    @track vfPageUrl;

    connectedCallback() {
        // Construct the Visualforce page URL
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: '/apex/reportCharts'
            }
        }).then(url => {
            this.vfPageUrl = url;
        });
    }
}