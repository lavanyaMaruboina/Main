import { LightningElement,track,api } from 'lwc';
import getTabList from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getTabList';
import { loadStyle } from 'lightning/platformResourceLoader';
import LightningCardApplyCSS from '@salesforce/resourceUrl/loanApplication';
import Borrower from '@salesforce/label/c.Borrower';
import CoBorrower from '@salesforce/label/c.CoBorrower';
export default class LWC_LOS_IncomeDetails extends LightningElement {

    label = {
        Borrower,
        CoBorrower
    }
    @api applicationId = '';
    @api isIncomeCreditedToBankAccount;
    @api isOnlineViaLink;
    @track activeTab;
    @track tabList = [];
    @track isBorrower = true;
    @track showIncomeOptions=false;
    @track showFileType=true;
    @track showURN=false;
    @track showIncomeCreditBankCheck=true;
    @track showLinkSection=false;
    @track showIncomeAssesment=false;
    @track showCaptureITR=false;
    @track showITR=false;
    @track showGST=false;
    @track showIncomeAnalysis=false;
    @track showPasswordStatement=false;
    @track showCaptureBankStatement=false;
    @track onlineLinkChecked=false;
    @track onlineUploadLinkChecked=false;
    @track scanDeviceChecked=false;
    @track isURNDisabled=true;
    @track isRegMCIDisabled=true;
    @track doFileITRChecked=false;
    @track doFileGSTChecked=false;
    @track onlineLinkChecked=false;

    renderedCallback() {
        loadStyle(this, LightningCardApplyCSS);
    }
    connectedCallback() {
        getTabList({ loanApplicationId: this.applicationId })
            .then(result => {
                if (result.length > 0) {
                    this.activeTab = result[0];
                    this.tabList = result;
                } else {
                    result.push(this.label.Borrower);
                    this.activeTab = this.label.Borrower;
                    this.tabList = result;
                }
            })
            .catch(error => {
                this.tryCatchError = error;
                this.errorInCatch();
            });
    }

    handleSalaried(event){
        let isSalariedSelected = this.template.querySelector('[data-id="salaried"]');
        isSalariedSelected.checked = event.target.checked;

        let isSelfEmployedSelected = this.template.querySelector('[data-id="selfEmployed"]');
        isSelfEmployedSelected.checked = false;

        if(isSalariedSelected.checked){
            this.showURN=false;
            this.showCheckRegiateration=false;
            this.showIncomeCreditBankCheck=true;
            this.showLinkSection=false;
            this.showPasswordStatement=false;
            this.showIncomeAssesment=false;
            this.showCaptureBankStatement=false;
            this.showIncomeAnalysis=false;
            this.showITR=false;
            this.showDocType=false;
            this.doFileITRChecked=false;
            this.doFileGSTChecked=false;
            this.onlineLinkChecked=false;
            this.onlineUploadLinkChecked=false;
            this.scanDeviceChecked=false;
            this.showIncomeOptions=false;
        } else if(!isSalariedSelected.checked){
            
        }
    }
    handleSelfEmployed(event){
        let isSelfEmployedSelected = this.template.querySelector('[data-id="selfEmployed"]');
        isSelfEmployedSelected.checked = event.target.checked;

        let isSalariedSelected = this.template.querySelector('[data-id="salaried"]');
        isSalariedSelected.checked = false;

        if(isSelfEmployedSelected.checked){
            this.showURN=true;
            this.showCheckRegiateration=true;
            this.showIncomeCreditBankCheck=false;
            this.showFileType=true;
            this.showIncomeOptions=false;
            this.showLinkSection=false;
            this.showPasswordStatement=false;
            this.showCaptureBankStatement=false;
            this.showIncomeAnalysis=false;
            this.showIncomeAssesment=false;
            this.showITR=false;
            this.showDocType=false;
            this.onlineLinkChecked=false;
            this.onlineUploadLinkChecked=false;
            this.scanDeviceChecked=false;
            this.doFileITRChecked=false;
            this.doFileGSTChecked=false;
            this.isURNDisabled=true;
            this.isRegMCIDisabled=true;
        } else if(!isSelfEmployedSelected.checked){
            this.showURN=false;
            this.showCheckRegiateration=false;
            this.showIncomeOptions=false;
            this.showLinkSection=false;
            this.showPasswordStatement=false;
            this.showIncomeAssesment=false;
            this.showCaptureBankStatement=false;
            this.showIncomeAnalysis=false;
            this.doFileITRChecked=false;
            this.doFileGSTChecked=false;
        }
    }
    handleIncomeCreditedToBankAccount(event){
        this.isIncomeCreditedToBankAccount = event.target.checked;
        if(this.isIncomeCreditedToBankAccount){
            this.showIncomeOptions=true;
            this.showFileType=false;
            this.showLinkSection=false;
            this.showPasswordStatement=false;
            this.showIncomeAssesment=false;
            this.showCaptureBankStatement=false;
            this.showIncomeAnalysis=false;
            this.showITR=false;
            this.showDocType=false;
            this.onlineLinkChecked=false;
            this.onlineUploadLinkChecked=false;
            this.scanDeviceChecked=false;
        }else if(!this.isIncomeCreditedToBankAccount){
            this.showIncomeOptions=false;
            this.showFileType=true;
            this.showLinkSection=false;
            this.showPasswordStatement=false;
            this.showIncomeAssesment=false;
            this.showCaptureBankStatement=false;
            this.showIncomeAnalysis=false;
        }
    }

    handleRegistered(event){
        this.isRegistered = event.detail.checked;
        if(this.isRegistered){
            this.isURNDisabled=false;
            this.isRegMCIDisabled=false;
        } else if(!this.isRegistered){
            this.isURNDisabled=true;
            this.isRegMCIDisabled=true;
        }
    }
    handleOnlineViaLink(event){
       
        this.isOnlineViaLink = event.detail.checked;
        let isFileITRSelected = this.template.querySelector('[data-id="fileITR"]').checked;

       if(isFileITRSelected){
        console.log('select value inside ITR:',isFileITRSelected);
            this.showITR=true;
            this.showDocType=false;
            this.showIncomeAssesment=true;
            this.showIncomeAnalysis=false;
            this.onlineLinkChecked=true;
            this.onlineUploadLinkChecked=false;
            this.scanDeviceChecked=false;
       } else {
        if(this.isOnlineViaLink ){
            this.showLinkSection=true;
            this.showIncomeAssesment=true;
            this.showPasswordStatement=false;
            this.showCaptureBankStatement=false;
            this.showIncomeAnalysis=false;
            this.onlineLinkChecked=true;
            this.onlineUploadLinkChecked=false;
            this.scanDeviceChecked=false;
            
        }else if(!this.isOnlineViaLink){
            this.showLinkSection=false;
            this.showIncomeAssesment=false;
           
        }
      }
        
    }
   
    handleUploadOnlineViaLink(event){
        
        this.isUploadOnlineViaLink = event.detail.checked;
        let isFileITRSelected = this.template.querySelector('[data-id="fileITR"]').checked;
        this.isOnlineViaLink=false;
        this.isScanDevice=false;
        if(isFileITRSelected){
            this.showITR=true;
            this.showDocType=true;
            this.showIncomeAssesment=true;
            this.showIncomeAnalysis=false;
            this.onlineLinkChecked=false;
            this.onlineUploadLinkChecked=true;
            this.scanDeviceChecked=false;
        } else {
            if(this.isUploadOnlineViaLink){
                this.showLinkSection=true;
                this.showPasswordStatement=true;
                this.showIncomeAssesment=true;
                this.showCaptureBankStatement=false;
                this.showIncomeAnalysis=false;
                this.onlineLinkChecked=false;
                this.onlineUploadLinkChecked=true;
                this.scanDeviceChecked=false;
                
            }else if(!this.isUploadOnlineViaLink){
                this.showLinkSection=false;
                this.showPasswordStatement=false;
                this.showIncomeAssesment=false;
               
            }
        }
       
    }

    handleScanDevice(event){
        this.isScanDevice = event.target.checked;
        let isFileITRSelected = this.template.querySelector('[data-id="fileITR"]').checked;

        if(isFileITRSelected){
            this.onlineLinkChecked=false;
            this.onlineUploadLinkChecked=false;
            this.scanDeviceChecked=true;
            this.showITR=true;
            this.showDocType=true;
            this.showIncomeAssesment=true;
            this.showIncomeAnalysis=true;
        } else{
            if(this.isScanDevice){
                this.showLinkSection=true;
                this.showCaptureBankStatement=true;
                this.showIncomeAssesment=true;
                this.showIncomeAnalysis=true;
                this.showPasswordStatement=false;
                this.onlineLinkChecked=false;
                this.onlineUploadLinkChecked=false;
                this.scanDeviceChecked=true;
            }else if(!this.isScanDevice){
                this.showLinkSection=false;
                this.showCaptureBankStatement=true;
                this.showIncomeAssesment=false;
                this.showIncomeAnalysis=false;
            }
        }
        
    }
    handleDoFileITR(event){
        let isFileITRSelected = this.template.querySelector('[data-id="fileITR"]');
        isFileITRSelected.checked = event.target.checked;

        let isFileGSTSelected = this.template.querySelector('[data-id="fileGST"]');
        isFileGSTSelected.checked = false;

        if(isFileITRSelected.checked){
            this.showIncomeOptions=true;
            this.showLinkSection=false;
            this.showPasswordStatement=false;
            this.showIncomeAssesment=false;
            this.showCaptureBankStatement=false;
            this.onlineLinkChecked=false;
            this.onlineUploadLinkChecked=false;
            this.scanDeviceChecked=false;
            this.doFileITRChecked=true;
            this.doFileGSTChecked=false;
        } else if(!isFileITRSelected.checked){
            this.showIncomeOptions=false;
        }
    }

    handleDoFileGST(event){
        let isFileGSTSelected = this.template.querySelector('[data-id="fileGST"]');
        isFileGSTSelected.checked = event.target.checked;

        let isFileITRSelected = this.template.querySelector('[data-id="fileITR"]');
        isFileITRSelected.checked = false;

        if(isFileGSTSelected.checked){
            this.showIncomeOptions=true;
            this.showLinkSection=false;
            this.showPasswordStatement=false;
            this.showIncomeAssesment=false;
            this.showCaptureBankStatement=false;
            this.showIncomeAnalysis=false;
            this.onlineLinkChecked=false;
            this.onlineUploadLinkChecked=false;
            this.scanDeviceChecked=false;
            this.showITR=false;
            this.showDocType=false;
        } else if(!isFileGSTSelected.checked){
            this.showIncomeOptions=false;
           
        }
    }

    handleActive(event) {
        this.activeTab = event.target.value;
        if (this.activeTab === this.label.CoBorrower) {
            this.isBorrower = false;
        } else if (this.activeTab === this.label.Borrower) {
            this.isBorrower = true;
        }
    }
}