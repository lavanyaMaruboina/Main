import { LightningElement, api, track } from 'lwc';
import getDecryptKycNumber from "@salesforce/apex/IND_LWC_CMURejectController.getDecryptKycNumber";
import doPANCallout from '@salesforce/apexContinuation/IntegrationEngine.doPANCallout';
import documentUpdateAftergoldenSource from '@salesforce/apex/LwcLOSLoanApplicationCntrl.documentUpdateAftergoldenSource';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateJourneyStopOfLead from '@salesforce/apex/LwcLOSLoanApplicationCntrl.updateJourneyStopOfLead';
import checkPanDocument from '@salesforce/apex/IND_LWC_CMURejectController.checkPanDocument';//CISP-17565
import doDLCallout from '@salesforce/apexContinuation/IntegrationEngine.doDLCallout';//CISP-17561
import goldenSourcePass from '@salesforce/apex/LwcLOSLoanApplicationCntrl.goldenSourcePass';//CISP-17561
export default class IND_LWC_DecryptKycNumber extends LightningElement {
    @track isSpinnerMoving = false;
    @api recordId;
    nsdlResponse;aadhaarSeedingStatus;nsdlPanMatch;
    @track goldenSourceButtonDisable = true;
    currentapplicationid;firstName;lastName;currentoppid
    @track _KycNumber;
    kycDlDob;//CISP-17561
    nsdlPanName ; NSDLPANStatus;
    get KycNumber(){ return this._KycNumber; }
    set KycNumber(value){ this._KycNumber = value; }

    get showComponent(){ return this.KycNumber ? true : false;}
    
    connectedCallback(){
        getDecryptKycNumber({'documentId' : this.recordId}).then(result=>{
            if(result){ 
                console.log('OUTPUT : ',result);
                if(result.decryptedKycNumber){
                    this.KycNumber = result.decryptedKycNumber;
                }else{
                    this.KycNumber = result.kycNo;
                }
                this.kycDocumentType = result.kycDocumentType;
                if(this.kycDocumentType == 'PAN No.'){
                    this.currentapplicationid = result.docAppId;
                    this.firstName = result.firstName;
                    this.lastName = result.lastName;
                    this.currentoppid = result.docOppId;
                    checkPanDocument({ 'documentId' : this.recordId })
                      .then(result => {
                        console.log('Result checkPanDocument', result);
                        this.goldenSourceButtonDisable = result;
                      })
                      .catch(error => {
                        console.error('Error:', error);
                    });
                }else if(this.kycDocumentType == 'DrivingLicences No.'){
                    this.goldenSourceButtonDisable = result.isGoldenSourcePass;
                    this.currentoppid = result.docOppId;
                    this.currentapplicationid = result.docAppId;
                    let kycdob = result.kycDob;
                    this.kycDlDob = kycdob.split("-").reverse().join(""); 
                }
            }
        });
    }
    handleGoldenSource(){
        this.isSpinnerMoving = true;
        if(this.kycDocumentType == 'PAN No.'){
        let kycPanDetails = {
            'applicantId': this.currentapplicationid,
            'panNumber': this.KycNumber,
            'firstName': this.firstName,
            'lastName': this.lastName,
            'loanApplicationId': this.currentoppid  };
            doPANCallout({ 'kycPanDetailRequest': JSON.stringify(kycPanDetails) })
          .then(result => {
            console.log('Result', result);
            this.isSpinnerMoving = false;
            const obj = JSON.parse(result);
            if (obj.response.content[0].NSDLPANStatus == 'E') {
                this.nsdlPanName = obj.response.content[0].Name;
                this.NSDLPANStatus = obj.response.content[0].NSDLPANStatus;
                this.nsdlPanMatch = obj.response.content[0].IDNSDLNameMatch;
                this.nsdlResponse = obj.response.content[0].NSDLPANStatusDesc;this.aadhaarSeedingStatus = obj.response.content[0].NSDLAadhaarSeedingStatus;
                if(obj.response.content[0].NSDLAadhaarSeedingStatus != 'Y'){this.successToast('Error', 'PAN is not linked to Aadhaar.', 'error');}
                else{
                    if(this.nsdlPanName != 'Y'){this.successToast('Error', 'Name does not match with NSDL records. Please reject the pan document', 'error');}else{
                    this.goldenSourceButtonDisable = true; eval("$A.get('e.force:refreshView').fire();");
                    this.successToast(obj.response.content[0].NSDLReturnCdDesc, obj.response.content[0].NSDLPANStatusDesc, 'success');
                }}
                this.handleGoldenSourceUpdate(true);
                
            } else if (obj.response.content[0].NSDLPANStatus == 'F' || 'X' || 'D' || 'N' || 'EA' || 'EC' || 'ED' || 'EI' || 'EL' || 'EM' || 'EP' || 'ES' || 'EU') {
                this.nsdlResponse = obj.response.content[0].NSDLPANStatusDesc;this.aadhaarSeedingStatus = obj.response.content[0].NSDLAadhaarSeedingStatus;
                this.handleGoldenSourceUpdate(false);
                let errmsg = obj.response.content[0].NSDLPANStatusDesc != null ? obj.response.content[0].NSDLPANStatusDesc : 'Invalid';
                this.successToast('Error', 'Journey has stopped because  of ' + errmsg, 'error');
                this.updateJourneyStopOfLead('Journey has stopped because  of ' + errmsg);
                this.goldenSourceButtonDisable = true;
            }
          })
          .catch(error => {
            console.error('Error:', error);
            this.isSpinnerMoving = false;
            this.successToast('Error', 'Please retry.', 'error');
        });
        }else if(this.kycDocumentType == 'DrivingLicences No.'){
            let kycDlDetails = {
                'applicantId': this.currentapplicationid,
                'dateOfBirth': this.kycDlDob,
                'dlNumber': this.KycNumber,
                'loanApplicationId': this.currentoppid  };
                doDLCallout({ 'kycDlDetailRequest': JSON.stringify(kycDlDetails) }).then(result => {
                    this.isSpinnerMoving = false;
                    const obj = JSON.parse(result);
                    if (obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Status == 'Pass') {
                        var responseData = obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Operations.Operation[0].Data.Response.RawResponse;
                        responseData = responseData.replace('status-code', 'statuscode');
                        responseData = responseData.replace('non-transport', 'nontransport');
                        const parsedRespData = JSON.parse(responseData);
                        if (parsedRespData.result.dl.statuscode==='103') {
                            this.successToast('Error', 'Incorrect Id Number', 'error');this.goldenSourceButtonDisable = false;
                        } else if (parsedRespData.result.dl.statuscode==='102') {
                            this.successToast('Error', 'Incorrect DOB', 'error'); this.goldenSourceButtonDisable = false;}else{
                            this.handleGoldenSourceSuccess();this.goldenSourceButtonDisable = true;
                            this.successToast(obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Operations.Operation[0].Status, 'Verified successfully', 'success');
                        } }
                    else if (obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Status == 'Fail') {
                        this.successToast(obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Status, obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Operations.Operation[0].Errors.Error[0].Message, 'error');
                    }
                }).catch(error => {
                    this.isSpinnerMoving = false;
                    console.log('OUTPUT error : ',error);
                    this.hanldeKindlyRetryMsg = true;this.successToast('Error', error, 'error'); }); }
        
    }
    handleGoldenSourceUpdate(isgoldenSourcePass){
        console.log('OUTPUT : ',this.aadhaarSeedingStatus);
        documentUpdateAftergoldenSource({ documentId: this.recordId,nsdlResponse: this.nsdlResponse,aadhaarSeedingStatus:this.aadhaarSeedingStatus, goldenSourcePass:isgoldenSourcePass,nsdlPanName : this.nsdlPanName ,NSDLPANStatus : this.NSDLPANStatus,nsdlPanMatch: this.nsdlPanMatch })
          .then(result => {
            console.log('Result', result);
          })
          .catch(error => {
            console.error('Error:', error);
        });
    }
    handleGoldenSourceSuccess(){
        goldenSourcePass({ documentId: this.recordId });
    }
    successToast(toastTitle, message, variant) {
        const evt = new ShowToastEvent({
            title: toastTitle,
            message: message,
            variant: variant, });
        this.dispatchEvent(evt); 
    }
    updateJourneyStopOfLead(journeyStopReasonMsg){
        updateJourneyStopOfLead({ leadNo: this.currentoppid,journeyStopReason: journeyStopReasonMsg})
          .then(result => {
            console.log('Result', result);
          })
          .catch(error => {
            console.error('Error:', error);
        });
    }
    
}