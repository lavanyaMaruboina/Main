import { LightningElement } from 'lwc';
import sendImageToServer from '@salesforce/apex/ImageController.sendImageToServer';

export default class FarmerClickPicture extends LightningElement {

   videoElement;
    canvasElement;
    capturedImageData;

    renderedCallback() {
        this.videoElement = this.template.querySelector('.videoElement');
        this.canvasElement = this.template.querySelector('.canvas');
    }

    async initCamera() {
        if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
            try {
                this.videoElement.srcObject = await navigator.mediaDevices.getUserMedia({ video: true, audio: false });
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

            if (this.videoElement && this.videoElement.srcObject) {
                this.videoElement.srcObject.getTracks().forEach((track) => track.stop());
                this.videoElement.srcObject = null;
            }

        }
        console.log('Image>>>>>',capturedImageData);
    }

    // async stopCamera() {
    //     if (this.videoElement && this.videoElement.srcObject) {
    //         this.videoElement.srcObject.getTracks().forEach((track) => track.stop());
    //         this.videoElement.srcObject = null;
    //     }
    //     console.log('Image>>>>>',capturedImageData);
    // }

    async sendImageToApex() {
        console.log('Apex called', this.capturedImageData);
        if (this.capturedImageData) {
            try {
                const response = await sendImageToServer({ imageData: this.capturedImageData });
                console.log('Image sent successfully: ', response);
                // Handle success (e.g., show a success message or update UI)
            } catch (error) {
                console.error('Error sending image to Apex: ', error);
                // Handle error (e.g., show an error message)
            }
        } else {
            console.error('No image data to send');
            // Handle case where no image is captured (e.g., show a warning message)
        }
    }
}