import { refreshApex } from '@salesforce/apex';
import uploadFileVisit from '@salesforce/apex/VisitImageController.uploadFileVisit';
import getUserDetails from '@salesforce/apex/userController.getUserDetails';
import getVisits from '@salesforce/apex/visitContactDetails.getVisits';
import saveVisit from '@salesforce/apex/visitContactDetails.saveVisit';
import Icons from '@salesforce/resourceUrl/farmer360';
import VISIT_OBJECT from '@salesforce/schema/Visit__c';
import Visit_FIELD from '@salesforce/schema/Visit__c.Type_Of_Visit__c';
import Id from "@salesforce/user/Id";
import LightningAlert from 'lightning/alert';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { LightningElement, api, track, wire } from 'lwc';


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
    // added by Madhuri
    savedImageId;
    turnOnCam = false;

    connectedCallback(){
        console.log('this is dealer Id>>', this.contactId);
    }


    camera = Icons + '/farmer360/KipiIcons/HomePage/camera.png';
    @track visitPicklistValues = [];
    @track vistiDefaultRecordTypeId;
    @track error;
    @track value = '';
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

    
    @track userName;
    @track userId = Id; 

    @wire(getUserDetails, { userId: '$userId' })
    wiredUser({ error, data }) {
        if (data) {
            this.userName = data.Name; 
        } else if (error) {
            console.error(error);
        }
    }

    @wire(getObjectInfo, { objectApiName: VISIT_OBJECT })
    wiredObjectInfo({ error, data }) {
        if (data) {
            this.vistiDefaultRecordTypeId = data.defaultRecordTypeId;
            this.error = undefined;
            console.log('This is record type value>>', this.vistiDefaultRecordTypeId);
        } else if (error) {
            this.error = error;
            this.vistiDefaultRecordTypeId = undefined;
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$vistiDefaultRecordTypeId', fieldApiName: Visit_FIELD })
    wiredPicklistValues({ error, data }) {
        if (data) {
            this.visitPicklistValues = data.values.map(picklistValue => ({
                label: picklistValue.label,
                value: picklistValue.value
            }));
            console.log('Picklist values>>', JSON.stringify(this.visitPicklistValues));
        } else if (error) {
            console.error('Error fetching picklist values:', error);
        }
    }

    handleChange(event) {
        this.value = event.detail.value;
    }

    customerName= '';


    @wire(getVisits, { Contactlistdetails: '$contactId' })
    wiredVisits(result) {
        this.wiredVisitsResult = result;
        if (result.data) {
            this.visits = result.data.map(visit => ({
                ...visit,
                CustomerName: visit.Customer__r ? visit.Customer__r.Name : "",
                FormattedDate: this.formatDate(visit.Date__c),
                repName : this.userName
                //fullAddress: `${visit.Address__Street__s || ''}, ${visit.Address__City__s || ''}, ${visit.Address__StateCode__s || ''}, ${visit.Address__CountryCode__s || ''}, ${visit.Address__PostalCode__s || ''}`.replace(/(, )+/g, ', ').replace(/^, |, $/g,'')
            }));

            if (this.visits.length > 0) {
                this.customerName = this.visits[0].CustomerName;
            }

            console.log('visits>>',JSON.stringify(this.visits));
        } else if (result.error) {
            console.error(result.error);
            this.error = result.error;
        }
        
    }

    formatDate(dateString) {
        const options = { day: '2-digit', month: '2-digit', year: '2-digit' };
        return new Date(dateString).toLocaleDateString('en-GB', options);
    }

    renderedCallback() {
        if (!this.videoElement) {
            this.videoElement = this.template.querySelector('.videoElement');
            this.canvasElement = this.template.querySelector('.canvasElement');
        }
    }

    videoElement;
    canvasElement;
    imageElement;
    currentStream;

    initializeCamera() {
        const constraints = {
            video: {
                facingMode: this.useFrontCamera ? 'user' : 'environment'
            }
        };

        navigator.mediaDevices.getUserMedia(constraints)
            .then((stream) => {
                this.currentStream = stream;
                this.videoElement = this.template.querySelector('video');
                this.videoElement.srcObject = stream;
            })
            .catch((error) => {
                console.error('Error accessing media devices.', error);
            });
    }

    switchCamera() {
        this.useFrontCamera = !this.useFrontCamera;
        this.stopCurrentStream();
        this.initCamera();
    }

    stopCurrentStream() {
        if (this.currentStream) {
            this.currentStream.getTracks().forEach(track => {
                track.stop();
            });
        }
    }

    async initCamera() {
        console.log('click here');
        //variable added by Madhuri
        this.turnOnCam = true;
        if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
            try {
                console.log('click here123');

                //edited by sudarshan
                const constraints = {
                    video: {
                        facingMode: this.useFrontCamera ? 'user' : 'environment'
                    }
                };
        
                navigator.mediaDevices.getUserMedia(constraints)
                    .then((stream) => {
                        this.currentStream = stream;
                        this.videoElement = this.template.querySelector('video');
                        this.videoElement.srcObject = stream;
                    })
                    .catch((error) => {
                        console.error('Error accessing media devices.', error);
                    });

                //this.videoElement.srcObject = await navigator.mediaDevices.getUserMedia({ video: true, audio: false });
                this.isCameraInitialized = true;
            } catch (error) {
                console.error('Error accessing camera: ', JSON.stringify(error));
            }
        } else {
            console.error('getUserMedia is not supported in this browser');
        }
    }
    get handleVisiblilty(){
        if(this.turnOnCam==false){
            return 'slds-align_absolute-center slds-hide';
        } else {
            return 'slds-align_absolute-center';
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
        this.captureImage();
        console.log('Apex called', this.capturedImageData);
        if (this.capturedImageData) {
            try {
                const response = await uploadFileVisit({ 
                    base64: this.capturedImageData.split(',')[1], 
                    filename: 'CapturedImage.png', 
                    contactId: this.contactId 
                });
                console.log('Image sent successfully: Content Version Id', response);
                this.savedImageId = response;
                // Stop the camera and update the state after sending the image
                if (this.videoElement && this.videoElement.srcObject) {
                    this.videoElement.srcObject.getTracks().forEach((track) => track.stop());
                    this.videoElement.srcObject = null;
                    this.isCameraInitialized = false;
                    this.turnOnCam = false;
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
        this.visit.Customer__c = this.contactId;
        //this.userName = userFullName;

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
            console.log('---! Selected Row : '+JSON.stringify(this.selectedRow ));
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
        console.log('---! new Visit : '+JSON.stringify(this.visit));
        const fields = {
            Type_Of_Visit__c: this.visit.Type_Of_Visit__c,
            Name: this.visit.Name,
            Date__c: this.visit.Date__c,
            Customer__c: this.contactId,
            Visit_Notes__c: this.visit.Visit_Notes__c,
        };

        console.log('the adress is Keval>>>',this.fields);
        console.log('the adress is>>>',this.fields);
        saveVisit({ visit: fields,contentVersionId: this.savedImageId}) 
            .then(() => {
                console.log('the visit is saved');
                this.handleSuccess();
                console.log(this.visit);
            })
            .catch(error => {
                showErrorAlert();

                this.handleError({ detail: error });
            });
    }

    handleSuccess() {
        this.showSuccessAlert();
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
    showSuccessAlert() {
        LightningAlert.open({
            message: 'Visit Created Successfully',
            theme: 'Success',
            label: 'Success',
        });
    }
    showErrorAlert(headerLabel, bodyMessage) {
        LightningAlert.open({
            message: bodyMessage,
            theme: 'error',
            label: headerLabel,
        });
    }
}