import { LightningElement,api,track } from 'lwc';
//import getContentVersionType from '@salesforce/apex/AdditionalDocumentsClass.getContentVersionType';
export default class IND_LWC_ShowFIReports extends LightningElement {
  @api reportLink;
  @track errorMsg;
  isPreview = false;
  converId;
  height = 32;
  connectedCallback(){


    console.log(this.reportLink);
    console.log(typeof this.reportLink);
    if(!this.reportLink || this.reportLink=='null'){
      this.errorMsg = 'No Related Document Found!.';
    }
    else{
      this.getFileTypeData();
    }
    console.log(this.reportLink);

  }
  async getFileTypeData(){

    this.converId = this.reportLink;
    this.isPreview = true;
    /*await getContentVersionType({ contentVersionId: this.reportLink })
      .then(result => {
        console.log('Result', result);
        if(result){
          this.fileType = result[0].FileType;
         
          
            
        }
      })
      .catch(error => {
        console.error('Error:', error);
    });*/
    //this.showDocumentPage();
  }
  /*showDocumentPage(){
    console.log('OUTPUT in showDocumentPage : ','/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_'+this.fileType+'&versionId='+this.reportLink);
    let currentUrl = window.location.href;//Start CISP-2372
        if(currentUrl && currentUrl.includes('/partners/')){
            this.reportLink = '/partners/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId='+this.reportLink;//CISP-3521
        }
        else{
            this.reportLink = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId='+this.reportLink;//CISP-3521
        }// End CISP-2372

        //this.converId = this.reportLink;
        //this.isPreview = true;
  }*/
  handleCloseButton(){
    self.close();
  }

}