import { LightningElement, wire, track } from 'lwc';
import getUserDetails from '@salesforce/apex/userController.getUserDetails';

export default class CurrentUser extends LightningElement {
    @track userName;
    @track isModalOpen = true;
    @track userId = '005QH000000umunYAA'; 

    @wire(getUserDetails, { userId: '$userId' })
    wiredUser({ error, data }) {
        if (data) {
            this.userName = data.Name; 
        } else if (error) {
            console.error(error);
        }
    }

    handleClose() {
        this.isModalOpen = false; 
    }
}