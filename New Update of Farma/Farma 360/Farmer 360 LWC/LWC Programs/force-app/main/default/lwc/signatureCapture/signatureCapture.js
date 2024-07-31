import { LightningElement ,track, api} from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import sResource from '@salesforce/resourceUrl/signature';
import saveSignature from '@salesforce/apex/SignatureController.saveSignature';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningAlert from 'lightning/alert';


let isMousePressed, 
    isDotFlag = false,
    prevX = 0,
    currX = 0,
    prevY = 0,
    currY = 0;            
       
let penColor = "#000000"; 
let lineWidth = 1.5;     

let scanvasElement, ctx; 
let dataURL,convertedDataURI; //holds image data

export default class SignatureCapture extends LightningElement {

    @api recordId;
    

    fileName;
    @api headerText='To process with current application process, sign and upload it';;
    addEvents() {
        scanvasElement.addEventListener('mousemove', this.handleMouseMove.bind(this));
        scanvasElement.addEventListener('mousedown', this.handleMouseDown.bind(this));
        scanvasElement.addEventListener('mouseup', this.handleMouseUp.bind(this));
        scanvasElement.addEventListener('mouseout', this.handleMouseOut.bind(this));
        scanvasElement.addEventListener("touchstart", this.handleTouchStart.bind(this));
        scanvasElement.addEventListener("touchmove", this.handleTouchMove.bind(this));
        scanvasElement.addEventListener("touchend", this.handleTouchEnd.bind(this));
    }

     handleMouseMove(event){
        if (isMousePressed) {
            this.setupCoordinate(event);
            this.redraw();
        }     
    }    
    handleMouseDown(event){
        event.preventDefault();
        this.setupCoordinate(event);           
        isMousePressed = true;
        isDotFlag = true;
        if (isDotFlag) {
            this.drawDot();
            isDotFlag = false;
        }     
    }    
    handleMouseUp(event){
        isMousePressed = false;      
    }
    handleMouseOut(event){
        isMousePressed = false;      
    }
    handleTouchStart(event) {
        if (event.targetTouches.length == 1) {
            this.setupCoordinate(event);     
        }
    };

    handleTouchMove(event) {
        // Prevent scrolling.
        event.preventDefault();
        this.setupCoordinate(event);
        this.redraw();
    };
    handleTouchEnd(event) {
        var wasCanvasTouched = event.target === scanvasElement;
        if (wasCanvasTouched) {
            event.preventDefault();
            this.setupCoordinate(event);
            this.redraw();
        }
    };
    renderedCallback() {
        scanvasElement = this.template.querySelector('canvas');
        ctx = scanvasElement.getContext("2d");
        ctx.lineCap = 'round';
        this.addEvents();
     }
    signIt(e)
    {
        var signText = e.detail.value;
        this.fileName=signText;
        ctx.font = "30px GreatVibes-Regular";
        this.handleClearClick(e);
        ctx.fillText(signText, 30, scanvasElement.height/2);
    }
    downloadSignature(e)
    {
        dataURL = scanvasElement.toDataURL("image/jpg");
        this.downloadSign(e);
    }
    @api
    async saveSignature(e)
    {
        dataURL = scanvasElement.toDataURL("image/jpg");
        //console.log('record id for the signature: ', this.recordId);
        //convert that as base64 encoding
        convertedDataURI = dataURL.replace(/^data:image\/(png|jpg);base64,/, "");

        await saveSignature({signElement: convertedDataURI})
        .then(result => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Signature Image saved in record',
                    variant: 'success',
                }),
            );
            this.showSuccessAlert();
            //console.log('record id for the signature: ', this.recordId);
        })
        .catch(error => {
            //show error message
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error uploading signature in Salesforce record',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        });
    }
    downloadSign(e)
    {
        var link = document.createElement('a');
        link.download = '.jpg';
        link.href = dataURL;
        link.click();
    }
    handleClearClick()
    {
        ctx.clearRect(0, 0, scanvasElement.width, scanvasElement.height);
    }

    setupCoordinate(eventParam){
        const clientRect = scanvasElement.getBoundingClientRect();
        prevX = currX;
        prevY = currY;
        currX = eventParam.clientX -  clientRect.left;
        currY = eventParam.clientY - clientRect.top;
    }

    redraw() {
        ctx.beginPath();
        ctx.moveTo(prevX, prevY);
        ctx.lineTo(currX, currY);
        ctx.strokeStyle = penColor;
        ctx.lineWidth = lineWidth;        
        ctx.closePath(); 
        ctx.stroke(); 
    }
    drawDot(){
        ctx.beginPath();
        ctx.fillStyle = penColor;
        ctx.fillRect(currX, currY, lineWidth, lineWidth); 
        ctx.closePath();
    }
    
    showSuccessAlert() {
        LightningAlert.open({
            message: 'Signature Captured Successfully',
            theme: 'Success',
            label: 'Success',
        });
    }

}