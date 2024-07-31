import { api, LightningElement, track, wire } from 'lwc';
import displayVisits from '@salesforce/apex/VisitController.displayVisits';
import updateVisitRecords from '@salesforce/apex/VisitController.updateVisitRecords';
import searchLandDetails from '@salesforce/apex/VisitController.searchLandDetails';
import { refreshApex } from '@salesforce/apex';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import VISIT_OBJECT from '@salesforce/schema/Visit__c';
import VISIT_LOCATION_FIELD from '@salesforce/schema/Visit__c.Visit_Location__c';
import uploadFileVisit from '@salesforce/apex/VisitImageController.uploadFileVisit';
import Icons from '@salesforce/resourceUrl/farmer360';
import uploadFile from '@salesforce/apex/VisitController.uploadFile';
import LightningAlert from 'lightning/alert';
export default class UpdateVisit extends LightningElement {
    camera = Icons + '/farmer360/KipiIcons/HomePage/camera.png';
    @api visitid;
    @track visitid;
    @track visitid = '';
    @track visitRecord;
    @track visitLocationOptions = [];
    @track visitLocation;
    @track visitNotes;
    @track dealerName;
    @track repName;
    @track typeOfVisitDealer;
    @track farmerName;
    @track typeOfVisitFarmer;
    @track errormessage;
    wiredVisitData;
    @track landSearchTerm = '';
    @track lands = [];
    @track selectedLandId;
    @track quantity;
    @track isCameraInitialized = false;
    videoElement;
    canvasElement;
    capturedImageData;
    capturedImages = []; // Array to store captured images
    imageContainer;
    @wire(displayVisits, { visitid: '$visitid' })
    wiredVisits(result) {
        this.wiredVisitData = result;
        if (result.data) {
            this.visitRecord = result.data;
            this.visitLocation = this.visitRecord?.Visit_Location__c;
            this.dealerName = this.visitRecord?.Dealer__r?.Name;
            this.farmerName = this.visitRecord?.Customer__r?.Name;
            this.selectedLandId = this.visitRecord?.Land_Details__c;
            this.landSearchTerm = this.visitRecord?.Land_Details__r?.Name;
            this.visitNotes = this.visitRecord?.Visit_Notes__c;
            this.quantity = this.visitRecord?.Quantity__c;
            this.typeOfVisitDealer = this.visitRecord?.Type_Of_Visit_For_Dealer__c;
            this.typeOfVisitFarmer = this.visitRecord?.Type_Of_Visit__c;
            this.repName = this.visitRecord?.Name;
        } else if (result.error) {
            this.errormessage = result.error;
            console.log('Error fetching visit record: ' + JSON.stringify(result.error));
        }
    }
    @wire(getObjectInfo, { objectApiName: VISIT_OBJECT })
    visitMetadata;
    @wire(getPicklistValues, { recordTypeId: '$visitMetadata.data.defaultRecordTypeId', fieldApiName: VISIT_LOCATION_FIELD })
    wiredPicklistValues({ error, data }) {
        if (data) {
            this.visitLocationOptions = data.values.map(item => ({
                label: item.label, value: item.value
            }));
        } else if (error) {
            this.errormessage = error;
        }
    }
    get isDealerSelected() {
        return this.visitLocation === 'Dealer';
    }
    get isFarmerSelected() {
        return this.visitLocation === 'Farmer';
    }
    handleFieldChange(event) {
        if (event.target.dataset.field === 'visitLocation') {
            this.visitLocation = event.detail.value;
        }
        else if (event.target.dataset.field === 'visitNotes'){
            this.visitNotes = event.detail.value;
        }
        else if (event.target.dataset.field === 'quantity'){
            this.quantity = event.detail.value;
        }
        
    }
    /**************land search*****************/
    handleLandSearch(event) {
        this.landSearchTerm = event.target.value;
        if (this.landSearchTerm.length > 1) {
            searchLandDetails({ searchTerm: this.landSearchTerm })
                .then(result => {
                    this.lands = result.map(record => ({
                        Id: record.Id,
                        Name: record.Name
                    }));
                })
                .catch(error => {
                    this.errormessage = error;
                    console.log('Error searching land details: ' + JSON.stringify(error));
                });
        } else {
            this.lands = [];
        }
    }
    selectLand(event) {
        this.selectedLandId = event.target.dataset.id;
        const selectedLand = this.lands.find(land => land.Id === this.selectedLandId);
        if (selectedLand) {
            this.landSearchTerm = selectedLand.Name;
        }
        this.lands = []; // Hide the dropdown after selection
    }
    /****************camera functionality********************/
    renderedCallback() {
        if (!this.videoElement) {
            this.videoElement = this.template.querySelector('.videoElement');
            this.canvasElement = this.template.querySelector('.canvasElement');
            this.imageContainer = this.template.querySelector('.imageContainer'); // Get the container for images
            this.fileInputElement = this.template.querySelector('.file-input'); // Get the file input element
            
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
            // Create a new canvas for each capture
            const newCanvas = document.createElement('canvas');
            newCanvas.height = this.videoElement.videoHeight;
            newCanvas.width = this.videoElement.videoWidth;
            const context = newCanvas.getContext('2d');
            context.drawImage(this.videoElement, 0, 0, newCanvas.width, newCanvas.height);
            // Add date and time
            const now = new Date();
            const dateTimeString = now.toLocaleString();
            context.font = '20px Arial';
            context.fillStyle = 'white';
            context.fillText(dateTimeString, 10, newCanvas.height - 40);
            // Get location
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition((position) => {
                    const { latitude, longitude } = position.coords;
                    const locationString = `Lat: ${latitude.toFixed(6)}, Lon: ${longitude.toFixed(6)}`;
                    context.fillText(locationString, 10, newCanvas.height - 10);
                    const imageData = newCanvas.toDataURL('image/png');
                    this.addCapturedImage(newCanvas, imageData);
                }, (error) => {
                    console.error('Error getting location: ', error);
                    this.addImageDataAndShow(newCanvas, dateTimeString, 'Location error');
                });
            } else {
                console.error('Geolocation is not supported in this browser');
                this.addImageDataAndShow(newCanvas, dateTimeString, 'Geolocation not supported');
            }
        }
    }
    triggerFileUpload() {
        this.fileInputElement.click();
    }
    handleFileUpload(event) {
        const file = event.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = (e) => {
                const imageData = e.target.result;
                this.addCapturedImage(null, imageData, true); // Indicate this is an uploaded image
            };
            reader.readAsDataURL(file);
        }
    }
    addCapturedImage(canvas, imageData, isUploaded = false) {
        const imageWrapper = document.createElement('div');
        imageWrapper.classList.add('image-wrapper');
        const imageElement = document.createElement('img');
        imageElement.setAttribute('src', imageData);
        imageElement.classList.add('slds-show');
        imageElement.classList.remove('slds-hide');
        const deleteButton = document.createElement('button');
        deleteButton.textContent = 'Remove';
        deleteButton.classList.add('slds-button', 'slds-button_destructive');
        deleteButton.style.position = 'absolute';
        deleteButton.style.top = '5px';
        deleteButton.style.right = '5px';
        deleteButton.style.backgroundColor = '#e74c3c';
        deleteButton.style.color = 'white';
        deleteButton.style.border = 'none';
        deleteButton.style.padding = '5px 10px';
        deleteButton.style.cursor = 'pointer';
        deleteButton.style.zIndex = '10';
        deleteButton.onclick = () => {
            this.imageContainer.removeChild(imageWrapper);
            this.capturedImages = this.capturedImages.filter(img => img !== imageData);
        };
        imageWrapper.style.position = 'relative';
        imageWrapper.style.display = 'inline-block';
        imageWrapper.appendChild(imageElement);
        imageWrapper.appendChild(deleteButton);
        this.imageContainer.appendChild(imageWrapper);
        console.log('Image container>>>', this.imageContainer);
        this.capturedImages.push(imageData);
        console.log('Capture Image container>>>', JSON.stringify(this.capturedImages));
    }
    addImageDataAndShow(canvas, dateTimeString, locationString) {
        const context = canvas.getContext('2d');
        context.font = '20px Arial';
        context.fillStyle = 'white';
        context.fillText(dateTimeString, 10, canvas.height - 40);
        context.fillText(locationString, 10, canvas.height - 10);
        const imageData = canvas.toDataURL('image/png');
        this.addCapturedImage(canvas, imageData);
    }
    async sendImageToApex() {
        console.log('Apex called>>>', this.capturedImages);
        if (this.capturedImages.length > 0) {
            try {
                for (let imageData of this.capturedImages) {
                    const response = await uploadFile({
                        base64: imageData.split(',')[1],
                        filename: 'visitExecutionImage.png',
                        visitId: this.visitid
                    });
                    console.log('Image sent successfully: ', response);
                }
                // Stop the camera and update the state after sending the images
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
    handleUpdate() {
        this.sendImageToApex();  
        updateVisitRecords({
            visitid: this.visitid,
            visitLocation: this.visitLocation,
            landDetailsId: this.selectedLandId,
            visitNotes: this.visitNotes,
            quantity: this.quantity
                     
        })
        .then(() => {
            this.showAlert('Success', 'Your visit has been updated successfully');
            return refreshApex(this.wiredVisitData);
            
           
        })
        .catch(error => {
            this.errormessage = error;
            console.log('Unable to update the record: ' + JSON.stringify(this.errormessage));
            this.showAlert('Error', 'There was an error updating the visit');
        });
    }
    handleCloseModal(){
        console.log('Restting the form');
        window.location.reload();
    }
    showAlert(title, message) {
        LightningAlert.open({
            message: message,
            theme: 'success', // 'success', 'error', 'warning', 'info'
            label: title,
        }).then(() => {
            // This will be called after the user clicks the "OK" button
            window.location.reload(); // Reload the browser to go to the home page
        });
    }
}