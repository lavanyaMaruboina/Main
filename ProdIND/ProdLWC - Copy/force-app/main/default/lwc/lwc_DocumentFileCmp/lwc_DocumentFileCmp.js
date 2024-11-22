import { LightningElement ,api,track} from 'lwc';
import getRelatedFile from '@salesforce/apex/DocumentFileCntrl.getRelatedFile';
import { NavigationMixin } from 'lightning/navigation';
import doOCRfuCallout from '@salesforce/apexContinuation/IntegrationEngine.doCibilOcrFrontUploadCallout';
import doOCRbuCallout from '@salesforce/apexContinuation/IntegrationEngine.doCibilOcrBackUploadCallout';
import getRelatedDocumentDetails from '@salesforce/apex/DocumentFileCntrl.getRelatedDocumentDetails';
import getImageFile from '@salesforce/apex/DocumentFileCntrl.getImageFile';
import getPOIdetails from '@salesforce/apex/DocumentFileCntrl.getPOIdetails';
import storedMaskedKYCDoc from '@salesforce/apex/CaseWithoutSharingUpdate.storedMaskedKYCDoc';
import deleteDocumentRecord from '@salesforce/apex/DocumentFileCntrl.deleteDocumentRecord';
import retryCountIncrease from '@salesforce/apex/DocumentFileCntrl.retryCountIncrease';
import AadhaarCard from '@salesforce/label/c.AadhaarCard';
import CMU_Front from '@salesforce/label/c.CMU_Front';
import CMU_Back from '@salesforce/label/c.CMU_Back';
import CMU from '@salesforce/label/c.CMU';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Lwc_DocumentFileCmp extends LightningElement {
    @api recordId;
    @track customerImageList = [];
    @track customerImageLink;
    @track customerImageTitle;
    @track customerImageExtension;
    @track customerImageLastModifiedDate;
    @track customerImage;
    @track noCustomerImage = false;
    @track contentList = [];
    @track countOfFiles = 0;
    imageUrl = '';
    previewMobileView = false;
    previewCustomerImageView = false; 
    documentId = [];
    customerDocumentId = [];
    @track imgArray = [];
    @track customerImageArray=[];
    slideIndex = 1;
    currentWidth = 0;
    @track nofiles = false;
    isAadharFront = false;
    isAadharBack = false;
    showSpinnerinModel = false;
    loanApplicationId;
    FileIDsForDeletion = [];
    haveFrontAttemt = false;
    haveBackAttempt = false;
    type;
    customerImageUrl=false;
    visibleClosebtn= true;
    genderPOI;
    salutationPOI;
    connectedCallback(){
        console.log('OUTPUT recordId: ',this.recordId);
        this.fetchRelatedFiles();
        this.fetchCustomerImage();
        this.fetchPOIDocument();

    }
    fetchPOIDocument(){
        getPOIdetails({ docId: this.recordId})
        .then((res)=>{
            if(res){
               this.genderPOI=res?.Gender__c;
               this.salutationPOI=res?.Salutation__c;
            }
        })
        .catch((err)=>{
            console.error('error->'+err);
        })
    }
    fetchCustomerImage(){
        getImageFile({ docId: this.recordId})
        .then(result => {
           if( JSON.parse(result).contentDocId.length >0){
            this.customerImageList = JSON.parse(result).contentVersionList;
            this.customerImage = this.customerImageList[0].Id;
            this.customerImageTitle = this.customerImageList[0].Title;
            this.customerImageExtension = this.customerImageList[0].FileExtension;
            this.customerImageLastModifiedDate = this.customerImageList[0].LastModifiedDate;
            this.customerImageLink = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId='+this.customerImage+'&operationContext=CHATTER';
         }  
         else{ 
            this.noCustomerImage = true;
         }
          })
          .catch(error => {
            console.error('Error:', error);
        });
    }
    fetchRelatedFiles(){
        getRelatedFile({ docId: this.recordId })
          .then(result => {
            console.log('Result', JSON.parse(result));
           if( JSON.parse(result).contentDocId.length >0){
            this.contentList = JSON.parse(result).contentVersionList
            console.log('OUTPUT : ',this.contentList);
            this.countOfFiles = this.contentList.length;
            for(const element of this.contentList) {
                element.imageUrl = element.imageUrl = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId='+element.Id+'&operationContext=CHATTER'//CISP-2764
           }
           console.log('OUTPUT : ',this.contentList);
        }  
         else{ 
            this.nofiles = true;
         }
            //this.imageUrl = '/sfc/servlet.shepherd/version/download/'  +this.contentList[1].Id
          })
          .catch(error => {
            console.error('Error:', error);
        });
        getRelatedDocumentDetails({
            docId: this.recordId
        })
        .then(result => {
            if (result) {
                this.userProfile = result.userProfileName;
                this.type = result.DocumentRecord.Document_Type__c;
                this.loanApplicationId = result.DocumentRecord.Opportunity_Relation__c;
                this.haveFrontAttemt = result.haveFrontAttemt;
                this.haveBackAttempt = result.haveBackAttempt;
            }
        });            
    }
    handlePreview(event){
        console.log('event : ',event);
        let index = event.target.dataset.targetId;
        console.log('index : ',index);
        this.documentId = [];
        this.previewMobileView = true;
        const documentLink = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId='+this.contentList[index].Id+'&operationContext=CHATTER';//CISP-2764
        this.documentId.push({
            documentId:documentLink
        });
        this.imgArray = this.documentId;
        if (this.userProfile=== CMU && this.type == AadhaarCard && this.contentList[index].Document_Side_fileupload__c ==='Front') {
            this.isAadharFront = true;
            this.frontUploadDocId = this.contentList[index].ContentDocumentId;
        } else {
            this.isAadharFront =false;
        }
        if(this.userProfile=== CMU && this.type == AadhaarCard && this.contentList[index].Document_Side_fileupload__c ==='Back') {
            this.isAadharBack =true;
            this.backUploadDocId = this.contentList[index].ContentDocumentId;
        }else{
            this.isAadharBack = false;
        }
        console.log('OUTPUT this.imgArray : ',this.imgArray );  

        /*setTimeout(() => {
            this.showSlides(this.slideIndex); 
        }, 2000);*/
        
    }

    handleImagePreview(event){
        console.log('event : ',event);
        this.customerDocumentId = []; 
        const documentLink = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId='+this.customerImage+'&operationContext=CHATTER';
        this.previewCustomerImageView = true; 
        this.customerDocumentId.push({ 
            customerDocumentId:documentLink 
        });
        this.customerImgArray = this.customerDocumentId;
    }
    
    closeModal(){
        this.previewMobileView = false;
    }

    closeCustomerImageModal(){ 
        this.previewCustomerImageView = false; 
    } 

    runFrontOCR(){
        if (!this.haveFrontAttemt) {
            this.showToastMessage('Error', 'Retry Attempts are exhausted. Please assign the Case back to the Sales Team!', 'Error');
        }else{
            console.log('from runFrontOCR');
            this.showSpinnerinModel = true;
            console.log('this.showSpinnerinModel : ', this.showSpinnerinModel);
            console.log(this.recordId, this.frontUploadDocId, this.loanApplicationId);
            doOCRfuCallout({
                documentId: this.recordId,
                contentDocumentId: this.frontUploadDocId,
                loanAppId: this.loanApplicationId
            }).then(response => {
                const obj = JSON.parse(response);
                const status = obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Status;
                console.log('obj  : ', obj);
                if (status == 'Pass') {
                    var responseData = obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Operations.Operation[0].Data.Response.RawResponse;
                    const parsedRespData = JSON.parse(responseData);
                    let base64ImageResp = parsedRespData.result[0].details.base64Image;

                    storedMaskedKYCDoc({
                        base64Imag: base64ImageResp,
                        documentId: this.recordId,
                        docSide: 'Front',
                        contentDocumentId: this.frontUploadDocId
                    }).then(response => {
                        console.log('storedMaskedKYCDoc - Response:: ', response);
                        this.FileIDsForDeletion.push(this.frontUploadDocId);
                        this.deletedocs();
                        console.log('FileIDsForDeletion in front ---', this.FileIDsForDeletion);
                        retryCountIncrease({
                            loanApplicationId: this.loanApplicationId,
                            serviceName: CMU_Front
                        })
                        .then(result => {
                            this.haveFrontAttemt = result ===true ? !result : this.haveFrontAttemt;
                            console.log(result);
                        });
                    }).catch(error => {
                        console.log('storedMaskedKYCDoc - Error:: ', error);
                    });
                    this.showToastMessage('Uploaded', 'Front OCR successful', 'success');
                    setTimeout(() => {
                        eval("$A.get('e.force:refreshView').fire();");
                        this.showSpinnerinModel = false;
                    }, 2000);
                } else if (status == 'Fail') {
                    console.log('status fail : ', );
                    this.showSpinnerinModel = false;
                    this.showToastMessage('Error', 'Front OCR Failed. Please try again!', 'Error');
                    retryCountIncrease({
                        loanApplicationId: this.loanApplicationId,
                        serviceName: CMU_Front
                    })
                    .then(result => {
                        this.haveFrontAttemt = result ===true ? !result : this.haveFrontAttemt;
                        console.log(result);
                    });
                }
            }).catch(error => {
                this.showSpinnerinModel = false;
                this.showToastMessage('Error', 'Front OCR Failed. Please try again!', 'Error');
                console.log('Front ocr error', error);
                retryCountIncrease({
                    loanApplicationId: this.loanApplicationId,
                    serviceName: CMU_Front
                })
                .then(result => {
                    this.haveFrontAttemt = result ===true ? !result : this.haveFrontAttemt;
                    console.log(result);
                });
            });
        }
    }

    runBackOCR(){
        if (!this.haveBackAttempt) {
            this.showToastMessage('Error', 'Retry Attempts are exhausted. Please assign the Case back to the Sales Team!', 'Error');
        }else{
            console.log('from runBackOCR');
            this.showSpinnerinModel = true;
            doOCRbuCallout({
                documentId: this.recordId,
                contentDocumentId: this.backUploadDocId,
                loanAppId: this.loanApplicationId
            }).then(response => {
                const obj = JSON.parse(response);
                const status = obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Status;
                console.log('OCR BU Callout:: ', obj);
                this.showSpinnerinModel = false;
                if (status == 'Pass') {
                    this.backUploadRedCross = false;
                    var responseData = obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Operations.Operation[0].Data.Response.RawResponse;
                    const parsedRespData = JSON.parse(responseData);
                    let base64ImageResp = parsedRespData.result[0].details.base64Image;
                    storedMaskedKYCDoc({
                        base64Imag: base64ImageResp,
                        documentId: this.recordId,
                        docSide: 'Back',
                        contentDocumentId: this.backUploadDocId
                    }).then(response => {
                        console.log('storedMaskedKYCDoc Response:: ', response);
                        this.FileIDsForDeletion.push(this.backUploadDocId);
                        this.deletedocs();
                        console.log('FileIDsForDeletion in back ---', this.FileIDsForDeletion);
                        retryCountIncrease({
                            loanApplicationId: this.loanApplicationId,
                            serviceName: CMU_Back
                        })
                        .then(result => {
                            this.haveBackAttempt = result ===true ? !result : this.haveBackAttempt;
                            console.log(result);
                        });
                    }).catch(error => {
                        console.log('storedMaskedKYCDoc Error:: ', error);
                    });

                    this.showToastMessage('Uploaded', 'Back OCR successful', 'success');
                    setTimeout(() => {
                        eval("$A.get('e.force:refreshView').fire();");
                        this.showSpinnerinModel = false;
                    }, 2000); 
                } else if (status == 'Fail') {
                    this.showSpinnerinModel = false;
                    this.showToastMessage('Error', 'Back OCR Failed. Please try again!', 'Error');
                    console.log('back status fail : ', );
                    retryCountIncrease({
                        loanApplicationId: this.loanApplicationId,
                        serviceName: CMU_Back
                    })
                    .then(result => {
                        this.haveBackAttempt = result ===true ? !result : this.haveBackAttempt;
                        console.log(result);
                    });
                }
            }).catch(error => {
                this.showSpinnerinModel = false;
                this.showToastMessage('Error', 'Back OCR Failed. Please try again!', 'Error');
                console.log('error OCR Back', error);
                retryCountIncrease({
                    loanApplicationId: this.loanApplicationId,
                    serviceName: CMU_Back
                })
                .then(result => {
                    this.haveBackAttempt = result ===true ? !result : this.haveBackAttempt;
                    console.log(result);
                });
            });
        }
    }

    deletedocs() {
        console.log('deletedocs---- : ', this.FileIDsForDeletion);
        let detetionFiles;
        if (this.type == AadhaarCard) {
            console.log('handleDocumentUploadDoneButton : ', JSON.stringify(this.FileIDsForDeletion));
            detetionFiles = JSON.stringify(this.FileIDsForDeletion);
        }
        if ((this.FileIDsForDeletion.length >= 1 && this.type == AadhaarCard)) {
            deleteDocumentRecord({
                documentId: this.recordId,
                contentDocumentIds: detetionFiles
            }).then(() => {
                this.showToastMessage('Success', 'Documents are replaced Successfully.', 'success');
                this.FileIDsForDeletion = [];
            }).catch(error => {
                this.showToastMessage('error', error, 'error');
            });
        }
    }
    
    showToastMessage(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        }));
    }
}