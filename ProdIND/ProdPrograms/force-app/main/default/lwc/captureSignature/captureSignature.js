import { api,track,LightningElement } from 'lwc';
import saveSign from '@salesforce/apex/SignatureHelper.saveSign';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FORM_FACTOR from '@salesforce/client/formFactor';

//declaration of variables for calculations 
let isDownFlag, 
    isDotFlag = false,
    prevX = 0,
    currX = 0,
    prevY = 0,
    currY = 0;            
       
let x = "#0000FF"; //blue color
let y = 1.5; //weight of line width and dot.       
 
let canvasElement, ctx; //storing canvas context
let attachment; //holds attachment information after saving the sigture on canvas
let dataURL,convertedDataURI; //holds image data

export default class CapturequestedEventignature extends LightningElement {
    hasDrawn = false; /*Added for CISP-7374*/
    @api documentid;
    //event listeners added for drawing the signature within shadow boundary
    constructor() {
        super();
        this.template.addEventListener('mousemove', this.handleMouseMove.bind(this));
        this.template.addEventListener('mousedown', this.handleMouseDown.bind(this));
        this.template.addEventListener('mouseup', this.handleMouseUp.bind(this));
        this.template.addEventListener('mouseout', this.handleMouseOut.bind(this));
        this.template.addEventListener('touchstart', this.handleTouchDown.bind(this));
        this.template.addEventListener('touchmove', this.handleTouchMove.bind(this));
        this.template.addEventListener('touchend', this.handleTouchUp.bind(this));
    }

    //retrieve canvase and context
    renderedCallback(){
        canvasElement = this.template.querySelector('canvas');
        ctx = canvasElement.getContext("2d");
    }
    
    //handler for mouse move operation
    handleMouseMove(event){
        
        this.searchCoordinatesForEvent('move', event);      
    }
    
    //handler for mouse down operation
    handleMouseDown(event){
        this.searchCoordinatesForEvent('down', event);         
    }
    
    //handler for mouse up operation
    handleMouseUp(event){
        this.searchCoordinatesForEvent('up', event);       
    }

    //handler for mouse out operation
    handleMouseOut(event){
        this.searchCoordinatesForEvent('out', event);         
    }

    handleTouchMove(event){
        event.preventDefault();
        this.searchCoordinatesForEvent('move', event);      
    }
    
    //handler for mouse down operation
    handleTouchDown(event){   
        event.preventDefault();              
        this.searchCoordinatesForEvent('down', event);    
          
    }
    
    //handler for mouse up operation
    handleTouchUp(event){
        event.preventDefault();
        this.searchCoordinatesForEvent('up', event);       
    }
    
    /*
        handler to perform save operation.
        save signature as attachment.
        after saving shows success or failure message as toast
    */
    @api
    handleSaveClick(){    
        /*Added for CISP-7374 :  START*/
        if (!this.hasDrawn) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'No signature has been added. Please draw your signature before saving.',
                    variant: 'error',
                }),
            );
            return;
        }
        /*Added for CISP-7374 : END*/
        //set to draw behind current content
        ctx.globalCompositeOperation = "destination-over";
        ctx.fillStyle = "#FFF"; //white
        ctx.fillRect(0,0,canvasElement.width, canvasElement.height); 
        //convert to png image as dataURL
        dataURL = canvasElement.toDataURL("image/png");
        //convert that as base64 encoding
        convertedDataURI = dataURL.replace(/^data:image\/(png|jpg);base64,/, "");
        //call Apex method imperatively and use promise for handling sucess & failure
        saveSign({strSignElement: convertedDataURI,documentId : this.documentid})
            .then(result => {
                this.attachment = result;
                //show success message
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Attachment created with Signature',
                        variant: 'success',
                    }),
                );
                const selectEvent = new CustomEvent('capturesucessfull');
               this.dispatchEvent(selectEvent);
            })
            .catch(error => {
                //show error message
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating Attachment record',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
            
    }

    //clear the signature from canvas
    @api
    handleClearClick(){
        ctx.clearRect(0, 0, canvasElement.width, canvasElement.height);
        this.hasDrawn = false;   /* Added for CISP-7374 */        
    }

    searchCoordinatesForEvent(requestedEvent, event){
        
        event.preventDefault();
        if (requestedEvent === 'down') {
            
            this.setupCoordinate(event);           
            isDownFlag = true;
            isDotFlag = true;
            if (isDotFlag) {
                this.drawDot();
                isDotFlag = false;
            }
        }
        if (requestedEvent === 'up' || requestedEvent === "out") {
            isDownFlag = false;
        }
        if (requestedEvent === 'move') {
            if (isDownFlag) {
                this.setupCoordinate(event);
                this.redraw();
            }
        }
    }

    //This method is primary called from mouse down & move to setup cordinates.
    setupCoordinate(eventParam){
        //get size of an element and its position relative to the viewport 
        //using getBoundingClientRect which returns left, top, right, bottom, x, y, width, height.
        const clientRect = canvasElement.getBoundingClientRect();
        prevX = currX;
        prevY = currY;              
        if(FORM_FACTOR === 'Large'){
            currX = eventParam.clientX -  clientRect.left;
            currY = eventParam.clientY - clientRect.top;
        }else{
            var touch = eventParam.touches[0];  
            currX = touch.pageX -  clientRect.left;
            currY = touch.pageY - clientRect.top;
        }
        /* currX = eventParam.clientX -  clientRect.left;
        currY = eventParam.clientY - clientRect.top; */
        
    }

    //For every mouse move based on the coordinates line to redrawn
    redraw() {
        this.hasDrawn = true; /* Added for CISP-7374 */
        ctx.beginPath();
        ctx.moveTo(prevX, prevY);
        ctx.lineTo(currX, currY);
        ctx.strokeStyle = x; //sets the color, gradient and pattern of stroke
        ctx.lineWidth = y;        
        ctx.closePath(); //create a path from current point to starting point
        ctx.stroke(); //draws the path
    }
    
    //this draws the dot
    drawDot(){
        this.hasDrawn = true; /* Added for CISP-7374 */
        ctx.beginPath();
        ctx.fillStyle = x; //blue color
        ctx.fillRect(currX, currY, y, y); //fill rectrangle with coordinates
        ctx.closePath();
    }
}