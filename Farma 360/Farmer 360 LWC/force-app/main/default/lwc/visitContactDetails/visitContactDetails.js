import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getVisits from '@salesforce/apex/visitContactDetails.getVisits';
import saveVisit from '@salesforce/apex/visitContactDetails.saveVisit';
import uploadFile from '@salesforce/apex/ImageController.uploadFile';
import { refreshApex } from '@salesforce/apex';
import Icons from '@salesforce/resourceUrl/farmer360';
import Address from '@salesforce/schema/Asset.Address';

const columns = [
    { label: 'Visit Name', fieldName: 'Name' },
    { label: 'Customer', fieldName: 'CustomerName' },
    { label: 'Visit Type', fieldName: 'Visit_Type__c' },
    { label: 'Date', fieldName: 'Date__c' }, 
    { label: 'Visit Notes', fieldName: 'Visit_Notes__c', type: 'text' },
    //{ label: 'Address', fieldName: 'fullAddress' },
];

export default class VisitContactDetails extends NavigationMixin(LightningElement) {
    @track visitList = true;
    @track showVisitForm = false;
    @track visits = [];
    @track columns = columns;
    @track selectedRow;
    @api contactId;
    wiredVisitsResult;


    camera = Icons + '/farmer360/KipiIcons/HomePage/camera.png';

   /* address = {
        street: '',
        city: '',
        province: '',
        country: '',
        postalCode: ''
    };*/
    @track isCameraInitialized = false;
    videoElement;
    canvasElement;
    capturedImageData;

    visit = {
        Name: '',
        //Enter_Address__c: '',
        //Street__c: '',
        //State__c: '',
        //Country__c: '',
        //Zip_Code__c: '',
        Date__c: '',
        Customer__c: '',
        Visit_Notes__c: ''
    };

    @wire(getVisits, { Contactlistdetails: '$contactId' })
    wiredVisits(result) {
        this.wiredVisitsResult = result;
        if (result.data) {
            this.visits = result.data.map(visit => ({
                ...visit,
                CustomerName: visit.Customer__r ? visit.Customer__r.Name : "",
                //fullAddress: `${visit.Address__Street__s || ''}, ${visit.Address__City__s || ''}, ${visit.Address__StateCode__s || ''}, ${visit.Address__CountryCode__s || ''}, ${visit.Address__PostalCode__s || ''}`.replace(/(, )+/g, ', ').replace(/^, |, $/g,'')
            }));

            console.log('visits>>',JSON.stringify(this.visits));
        } else if (result.error) {
            console.error(result.error);
            this.error = result.error;
        }
    }

    renderedCallback() {
        if (!this.videoElement) {
            this.videoElement = this.template.querySelector('.videoElement');
            this.canvasElement = this.template.querySelector('.canvasElement');
        }
    }

    async initCamera() {
        if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
            try {
                this.videoElement.srcObject = await navigator.mediaDevices.getUserMedia({ video: true, audio: false });
                this.isCameraInitialized = true;
            } catch (error) {
                console.error('Error accessing camera: ', JSON.stringify(error));
            }
        } else {
            console.error('getUserMedia is not supported in this browser');
        }
    }

    async captureImage() {
        if (this.videoElement && this.videoElement.srcObject) {
            this.canvasElement.height = this.videoElement.videoHeight;
            this.canvasElement.width = this.videoElement.videoWidth;
            const context = this.canvasElement.getContext('2d');
            context.drawImage(this.videoElement, 0, 0, this.canvasElement.width, this.canvasElement.height);
            this.capturedImageData = this.canvasElement.toDataURL('image/png');

            const imageElement = this.template.querySelector('.imageElement');
            imageElement.setAttribute('src', this.capturedImageData);
            imageElement.classList.add('slds-show');
            imageElement.classList.remove('slds-hide');
            
            // Do not stop the camera here; keep it running until the image is sent
        }
        console.log('Image>>>>>', this.capturedImageData);
    }

    async sendImageToApex() {
        console.log('Apex called', this.capturedImageData);
        if (this.capturedImageData) {
            try {
                const response = await uploadFile({ 
                    base64: this.capturedImageData.split(',')[1], 
                    filename: 'CapturedImage.png', 
                    contactId: this.contactId 
                });
                console.log('Image sent successfully: ', response);
                
                // Stop the camera and update the state after sending the image
                if (this.videoElement && this.videoElement.srcObject) {
                    this.videoElement.srcObject.getTracks().forEach((track) => track.stop());
                    this.videoElement.srcObject = null;
                    this.isCameraInitialized = false;
                }
            } catch (error) {
                console.error('Error sending image to Apex: ', error);
            }
        } else {
            console.error('No image data to send');
        }
    }


    handleVisit() {
        this.showVisitForm = true;
        this.visitList = false;
        this.visit.Customer__c = this.contactId; // Prefill the customer field with the contactId
    }

    handleBack() {
        this.showVisitForm = false;
        this.visitList = true;
    }
    handlecancel(){
        location.reload();
    }

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        if (selectedRows.length > 0) {
            this.selectedRow = selectedRows[0];
        } else {
            this.selectedRow = null;
        }
    }


    /*handleAddressChanges(event){
        console.log('the adress is>>',JSON.stringify(event.detail));
        this.address = event.detail;
        console.log('the adress is>>',this.address.country);
    }*/

    handleInputChange(event){
        console.log('name is>>', event.target.name);
        console.log('value is>>', event.target.value);
        this.visit[event.target.name] = event.target.value;
    }

    handleSave(event) {

         event.preventDefault();

        const fields = {
            Visit_Type__c: this.visit.Visit_Type__c,
            Name: this.visit.Name,
            Date__c: this.visit.Date__c,
            Customer__c: this.contactId,
            Visit_Notes__c: this.visit.Visit_Notes__c,
        };

        console.log('the adress is Keval>>>',this.fields);
        console.log('the adress is>>>',this.fields);

        saveVisit({ visit: fields}) //address: this.address})
            .then(() => {
                console.log('the visit is saved');
                this.handleSuccess();
                console.log(this.visit);
            })
            .catch(error => {
                this.handleError({ detail: error });
            });
    }

    handleSuccess() {
        this.showVisitForm = false;
        this.visitList = true;
        this.clearAll();
        return refreshApex(this.wiredVisitsResult);
    }

    handleError(event) {
        console.error('Error: ', event.detail);
    }

    clearAll() {
        this.visit = {
            Name: '',
            Street: '',
            City: '',
            State: '',
            Country: '',
            PostalCode: '',
            Date__c: '',
            Customer__c: '',
            Visit_Notes__c: ''
        };

        this.address = {
            street: '',
            city: '',
            province: '',
            country: '',
            postalCode: ''
        };

        this.template.querySelectorAll('lightning-input-field').forEach(field => {
            field.value = null;
        });

        this.template.querySelectorAll('lightning-input').forEach(field => {
            field.value = '';
        });
    }
}