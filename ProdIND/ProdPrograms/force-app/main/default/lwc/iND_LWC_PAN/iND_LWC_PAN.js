import { LightningElement } from 'lwc';

export default class IND_LWC_PAN extends LightningElement {

    get option() {
        return [
            { label: 'Pan', value: 'option1' },
            { label: 'Form', value: 'option1' }
        ];
    }
    get option1() {
        return [
            { label: 'Is this a Photocopy?', value: 'option1' }
        ];
    }
// Start : Capture Image  Component Pop-UP on Upload Button

modalPopUpCaptureImage = false;

ImageLoad(){

    this.modalPopUpCaptureImage = true;

    

}

closeModal() {

    this.modalPopUpCaptureImage = false

}

// End : Capture Image Component Pop-UP on Upload Button    
}