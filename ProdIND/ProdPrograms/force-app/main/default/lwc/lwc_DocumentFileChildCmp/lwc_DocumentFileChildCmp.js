import { LightningElement,api,track } from 'lwc';

export default class Lwc_DocumentFileChildCmp extends LightningElement {
    @api imgArray;
    @api customerImgArray; 
    slideIndex = 1;
    currentWidth = 0;
    @api isaadharfront = false;
    @api isaadharback = false;
    @api showspinnerinmodel = false;
    @api closebtn = false;
    @api customerImgDoc; 
    @api kycDoc; 
    get total(){
        return this.imgArray.length;
    }
    rotateNumber = 0;
    get rotateClass()
    {
        return 'rotate'+this.rotateNumber;
    }
    rotateRight(){
        this.rotateNumber += 90;
        if(this.rotateNumber == 360){
            this.rotateNumber = 0;
        }
    }

    rotateLeft(){
        this.rotateNumber -= 90;
        if(this.rotateNumber == -90){
            this.rotateNumber = 270;
        }
        /*if(this.rotateNumber == 90 || this.rotateNumber == 270){
            let img = this.template.querySelector('.activeImg');
            alert(img.parent.clientWidth);
            alert(img.clientHeight);
            //img.clientHeight = img.parent.clientWidth;
        }*/
    }

    myLastTap;
    checkDoubletap(){
        let now = new Date().getTime();
        let timesince = now - this.myLastTap;
        if(timesince < 600 && timesince > 0){
            this.zoomIn();
        }
        this.myLastTap = new Date().getTime();
    }

    zoomPinch(event){
        if(event.scale > 1.0){
            this.zoomIn();
        }else if (event.scale < 1.0){
            this.zoomOut();
        }
    }

    
    zoomIn(){
        console.log('myImg before',this.currentWidth);
        let img = this.template.querySelector('.activeImg .zoomClass');
        this.currentWidth = this.currentWidth === 0 ? img.clientWidth : this.currentWidth;
        console.log('myImg before'+JSON.stringify(img.style.width));
        img.style.width = (img.clientWidth + 100) + "px";
        console.log('myImg after'+JSON.stringify(img.style.width));
        if(this.template.querySelector('.activeImg .applyWidth')){
            this.template.querySelector('.activeImg .applyWidth').classList.remove("applyWidth");
        }
        // else{
        //     this.currentWidth = this.currentWidth === 0 ? img.clientWidth : this.currentWidth;
        //     console.log('myImg before'+JSON.stringify(img.style.width));
        //     img.style.width = (img.clientWidth + 100) + "px";
        //     console.log('myImg after'+JSON.stringify(img.style.width));
        // }
        
    }
    
    zoomOut(){
        let img = this.template.querySelector(".activeImg .zoomClass");
        console.log('myImg before'+JSON.stringify(img.width));
        this.currentWidth = this.currentWidth === 0?img.clientWidth:this.currentWidth;
        let currWidth = img.clientWidth;
        if(currWidth <= this.currentWidth) {
            if(this.template.querySelector('.activeImg .zoomClass')){
                this.template.querySelector('.activeImg .zoomClass').classList.add("applyWidth");
            }
        }
		 else{
            img.style.width = (currWidth - 100) + "px";
        }
    }

   
    // Next/previous controls
    plusSlides() {
        this.showSlides(this.slideIndex += 1);
        this.rotateNumber = 0;
    }
    // Next/previous controls
    minusSlides() {
       this.showSlides(this.slideIndex -= 1);
        this.rotateNumber = 0;
    }

    // Thumbnail image controls
    currentSlide(n) {
       this.showSlides(this.slideIndex = n);
    }
    renderedCallback(){
        this.showSlides(this.slideIndex);
    }
    showSlides(n) {
        let i;
        let slides = this.template.querySelectorAll(".mySlides1");
        console.log('slides : ',slides);
        console.log('OUTPUT **: ',document.getElementsByClassName('mySlides1'));
        if(this.currentWidth > 0){
           let slideWidth=  this.template.querySelector(".activeImg .zoomClass");
           if(slideWidth){slideWidth.style.width = this.currentWidth + "px";}
        }
        if (n > slides.length) { this.slideIndex = 1 }
        if (n < 1) { this.slideIndex = slides.length }
        for (i = 0; i < slides.length; i++) {
            slides[i].style.display = "none";
            if(slides[i].classList.contains('activeImg')){
                slides[i].classList.remove("activeImg");
            }              
        }

        console.log('this.currentWidth',this.currentWidth);
        console.log('this.slideIndex',this.slideIndex);
        console.log('slides : ',slides[0]);
        
        slides[this.slideIndex - 1].style.display = "block";
        slides[this.slideIndex - 1].classList.add("activeImg");
        this.currentWidth = 0;
        console.log(slides[this.slideIndex - 1].style.clientWidth);
        console.log(slides[this.slideIndex - 1].style.width);
    }
    closeModal(){
        this.dispatchEvent(new CustomEvent('close')); 
     }

     closecustomerImage(){
        this.dispatchEvent(new CustomEvent('closecustomerimage')); 
    }

    handleFrontOCRAPI(){
       this.dispatchEvent(new CustomEvent('frontocr')); 
    }
    
    handleBackOCRAPI(){
       this.dispatchEvent(new CustomEvent('backocr')); 
    }
}