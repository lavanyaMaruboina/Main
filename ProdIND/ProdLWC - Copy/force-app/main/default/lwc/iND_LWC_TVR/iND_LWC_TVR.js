import { LightningElement, track,wire,api } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues} from 'lightning/uiObjectInfoApi';
import TVR_OBJECT from '@salesforce/schema/TeleVerification__c';
import TVR_OBJECT1 from '@salesforce/schema/TeleVerification__c';
import TVRAssessment_FIELD from '@salesforce/schema/TeleVerification__c.TVR_assessment__c';
import TVRENDUSERPRODUCT_FIELD from '@salesforce/schema/TeleVerification__c.Who_will_be_the_end_user_of_the_product__c';

import CASA_OBJECT from '@salesforce/schema/CASA_Bank_Form__c';
import Saving_Account_opened_for_FIELD from '@salesforce/schema/CASA_Bank_Form__c.Saving_Account_opened_for__c';

import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';	
import getTVRRecord from '@salesforce/apex/IND_TeleverificationDetails.getTVRRecord'; 
import updateDetails from '@salesforce/apex/IND_TeleverificationDetails.updateTVRRecord'; 
import customerChequeBounce from '@salesforce/label/c.customerChequeBounce';
import isKycUpdatedIn3Months from '@salesforce/label/c.isKycUpdatedIn3Months';
import updateDocCountForApplicant from '@salesforce/apex/IND_TeleverificationDetails.updateDocCountForApplicant';
import getState from '@salesforce/apex/IND_TeleverificationDetails.getState';
import Applicant__c from '@salesforce/schema/Applicant__c';
import Pin_code_Pattern from "@salesforce/label/c.Pin_code_Pattern";
export default class IND_LWC_TVR extends NavigationMixin(LightningElement) 
{    
// Expose the labels to use in the template.
label = {
    customerChequeBounce,
    isKycUpdatedIn3Months,
    Pin_code_Pattern
};
@wire(getObjectInfo, { objectApiName: Applicant__c }) objectInfo;
relationshipOptions = [
    {label: 'Father', value: 'Father'},
    {label: 'Mother', value: 'Mother'},
    {label: 'Son', value: 'Son'},
    {label: 'Daughter', value: 'Daughter'},
    {label: 'Friend', value: 'Friend'},
    {label: 'Brother', value: 'Brother'},
    {label: 'Sister', value: 'Sister'},
    {label: 'Husband', value: 'Husband'},
    {label: 'Wife', value: 'Wife'}];

finacleCityOptions = [];
borrowerAvailable = false;
borrowerNomineeEnable = false;
coBorrowerNomineeEnable = false;   

  //Bug No: INDI: 4596
  borrowerWillingess=false;
CoborrowerWillingess=false;
ShowCoborrowerNominee=true;


isCrrOfficeCustomerInformedAboutKYC;
crrOfficeMoneyAskedForProcessing;

crrAddressVerified;

prrAddressVerified;

showModal = false;
showModalForUpdateKYC = false;
showModalForChequeBounce = false;
docUploaded = false;

@track isEnableUploadViewDoc = true;    
@api uploadViewDocFlag;
@track response = [];

@api recordId;

@api applicantId;
@api oppId;
@track uploadRCDocFlag = false;
@api listOfDocument = {fileName:'', contentDocumentId : '', documentRecordId: ''}; // use the format to pass data = {fileName:'', contentDocumentId : '', documentRecordId: ''}
@api documentRecordId='101' ;



@api applicantid;
@api loanapplicationid;
@api applicantdetails = [];
disableUpload = false;
disableSubmit = true;
@track isSpinnerMoving=false;
camRecId;
get acceptedFormats() {
    return ['.jpg', '.png','.jpeg','.docx','.pdf'];
}


/*

@wire(getObjectInfo, { objectApiName: TVR_OBJECT})
tvrAssessmentMetadata;



@wire(getObjectInfo, { objectApiName: TVR_OBJECT1})
tvrAssessmentMetadata1;

@wire(getPicklistValues, 
    {   recordTypeId: '$tvrAssessmentMetadata.data.defaultRecordTypeId', 
        fieldApiName: TVRAssessment_FIELD
    })
wiredPickListValue({ data, error }){
    if(data){            
        this.tvrAssessmentOptions = data.values;   
        console.log('this.tvrAssessmentOptions '+JSON.stringify(this.tvrAssessmentOptions));               
    }
    if(error){            
        this.tvrAssessmentOptions = undefined;
    }
}
@wire(getPicklistValues, 
    {   recordTypeId: '$tvrAssessmentMetadata1.data.defaultRecordTypeId', 
        fieldApiName: TVRENDUSERPRODUCT_FIELD
    })
wiredPickListValue({ data, error }){
    if(data){            
        this.tvrEndUserOptions = data.values;   
        console.log('this.tvrEndUserOptions '+JSON.stringify(this.tvrEndUserOptions));               
    }
    if(error){            
        this.tvrEndUserOptions = undefined;
    }
}
*/

connectedCallback()
{
 

var tvrAssessmentOptionsList = new Array();
tvrAssessmentOptionsList.push({ label: "High Risk", value: "High Risk" });
tvrAssessmentOptionsList.push({ label: "Pass", value: "Pass" });
this.tvrAssessmentOptions = tvrAssessmentOptionsList;

var tvrEndUserOptionsList = new Array();
tvrEndUserOptionsList.push({ label: "Applicant", value: "Applicant" });
tvrEndUserOptionsList.push({ label: "others", value: "others" });
this.tvrEndUserOptions = tvrEndUserOptionsList;

var tvrMarginMoneyOptionsList = new Array();
tvrMarginMoneyOptionsList.push({ label: "Dealer", value: "Dealer" });
tvrMarginMoneyOptionsList.push({ label: "Executive", value: "Executive" });
this.tvrMarginMoneyOptions = tvrMarginMoneyOptionsList;

    getTVRRecord({ strOppId: this.recordId})
    //strOppId
    .then(response => {            
        if(response)
        {                                                       
            this.response = JSON.parse(JSON.stringify(response));  
            this.borrowerAvailable = false;
            for(var index=0;index<this.response.length;index++)
            {
                if(this.response[index].applicantType == 'Borrower')
                {
                    this.applicantid=this.response[index].applicantId; // Added 9/5/2022
                    this.loanapplicationid = this.response[index].oppId;
                        
                    this.borrowerAvailable = true;
                    if(this.response[index].isWillingToopenBankAccountWithIIB && this.response[index].whoWillRepayLoan == 'Borrower')
                    {
                        this.borrowerNomineeEnable = true;     
                        this.coBorrowerNomineeEnable = false;   
                        //INDI 4596  
                        this.borrowerWillingess=true;
                        console.log('154',this.borrowerWillingess);
                    }                                                                      
                }
                if(this.response[index].applicantType == 'Co-borrower' && this.response[index].isWillingToopenBankAccountWithIIB && this.borrowerNomineeEnable==false && this.response[index].whoWillRepayLoan == 'Co-borrower')
                {
                    this.applicantid=this.response[index].applicantId; // Added 9/5/2022
                    this.loanapplicationid = this.response[index].oppId;
                    
                    this.borrowerNomineeEnable = false;
                    this.coBorrowerNomineeEnable = true;
                }        
                
                //Bug No: INDI: 4596
                if(this.response[index].applicantType == 'Co-borrower' && this.response[index].isWillingToopenBankAccountWithIIB && this.response[index].whoWillRepayLoan == 'Co-borrower')
                {
                //Bug No: INDI: 4596
                  
                    this.CoborrowerWillingess=true;
                }
                
                if(this.CoborrowerWillingess==true && this.borrowerWillingess==true && this.response[index].whoWillRepayLoan != 'Co-borrower'){
                              this.ShowCoborrowerNominee=false;
                }
                if(this.response[index].camRecId){
                    this.camRecId = this.response[index].camRecId;
                }

            }   
            // if(this.response[0].lstFinacleValues != undefined && Array.isArray(this.response[0].lstFinacleValues))
            // {         
                    
            //     for(var i=0; i<this.response[0].lstFinacleValues.length; i++) {                        
            //         this.finacleCityOptions = [...this.finacleCityOptions ,{value: this.response[0].lstFinacleValues[i].Id , label: this.response[0].lstFinacleValues[i].City_Code__c}];                
            //     }
            // }
            console.log('this.finacleCityOptions '+this.finacleCityOptions); 
            console.log('this.borrowerAvailable '+this.borrowerAvailable);                               
            console.log('this.borrowerNomineeEnable '+this.borrowerNomineeEnable); 
            console.log('this.coBorrowerNomineeEnable '+this.coBorrowerNomineeEnable); 
            console.log('response size '+this.response.length);                               
            console.log('response '+JSON.stringify(this.response));                    
        }
    })
    .catch(error => {
        console.log('error '+JSON.stringify(error));
    
    });
}

handleUploadViewAndDelete(){
    console.log('AAAAAA ',this.uploadRCDocFlag);
    this.showUpload = true;
    this.showPhotoCopy = false;
    this.showDocView = false;
    this.isVehicleDoc = true;
    this.isAllDocType = false;
    this.uploadViewDocFlag = false;
    this.uploadRCDocFlag = true;
    this.docType = 'Email Attachment';
}

uploadDone(event) {
    //increase the document count for respective applicant
    if(this.docUploaded){
        //reset the flag
        this.docUploaded = false;
        //update docCount on Object and in data
        var docUploadApplicantId = event.currentTarget.dataset.id;
        var docCountForTVR = 0;
        for(var index=0;index<this.response.length;index++){
            if(docUploadApplicantId == this.response[index].applicantId){
                this.response[index].applicantdocCount = this.response[index].applicantdocCount + 1;
                this.response[index].applicantdocCountForTVR = this.response[index].applicantdocCountForTVR + 1;
                docCountForTVR = this.response[index].applicantdocCountForTVR;
            }
        }

        //update the TVR document count on Applicant record
        updateDocCountForApplicant({ 
            applicantId: docUploadApplicantId,
            docCountForTVR: docCountForTVR         
        })
        .then((response) => {              
            console.log('success ' + response);
        })
        .catch(error => {
            console.log('error ' + error);
        }); 
    }
    this.uploadRCDocFlag = false;
}

handleFileUpload(event){
    this.docUploaded = true;
    const evt = new ShowToastEvent({
        title: 'Uploaded',
        message: 'File Uploaded successfully..!',
        variant: 'success',
    });
    this.dispatchEvent(evt);
}

handleChange(event)
{
    const index = event.target.dataset.id;
    const name = event.target.name;

    console.log('index '+index+' Name '+name);

    //For KYC Section

    if(name == 'kycAttestationOnce')
    {
        this.response[index].kycAttestationOnce = event.target.checked;
    }
    else if(name == 'kycAadhaarCard')
    {
        this.response[index].kycAadhaarCard = event.target.checked; 
    }
    else if(name == 'kycMobileLinkedAadhaar')
    {
        this.response[index].kycMobileLinkedAadhaar = event.target.checked; 
    }
    else if(name == 'kycUsingMobileLinkedAadhaar')
    {
        this.response[index].kycUsingMobileLinkedAadhaar = event.target.checked; 
    }
    
    //For PERSONAL DETAILS Section
    else if(name == 'personalAppliedForLoan')
    {
        this.response[index].personalAppliedForLoan = event.target.checked;
    }
    else if(name == 'personalVehicleDelivered')
    {
        this.response[index].personalVehicleDelivered = event.target.checked;    
    }
    else if(name == 'personalProductEndUser')
    {
        this.response[index].personalProductEndUser = event.detail.value;  
    }
    else if(name == 'personalPurpose')
    {
        this.response[index].personalPurpose = event.detail.value;  
    }
    else if(name == 'personalRemarks')
    {
        this.response[index].personalRemarks = event.detail.value;
    }

    //For LOAN DETAILS Section
    else if(name == 'loanChequeBounce')
    {
        this.response[index].loanChequeBounce = event.target.checked;   
        if (!event.target.checked) 
        {           
            this.showModal = true;
            this.showModalForUpdateKYC = false;
            this.showModalForChequeBounce = true;          
        }   
    }
    else if(name == 'loanMarginMoney')
    {
        this.response[index].loanMarginMoney = event.target.checked;
    }
    else if(name == 'loanWhomMarginMoney')
    {
        this.response[index].loanWhomMarginMoney = event.detail.value;
    }
    else if(name == 'loanReceipt')
    {
        this.response[index].loanReceipt = event.target.checked;
    }
    else if(name == 'loanAmountPaid')
    {
        this.response[index].loanAmountPaid = event.detail.value;
    }

    //For CURRENT RESIDENTIAL ADDRESS Section
    else if(name == 'residenceCityFinacle')
    {
        this.response[index].residenceCityFinacle = event.detail.value;
    }
    else if(name == 'crrAddressVerified')
    {
        this.crrAddressVerified = event.target.checked;
    }

    //For PERMANENT RESIDENTIAL ADDRESS Section
    else if(name == 'permanentFinacle')
    {
        this.response[index].permanentFinacle = event.detail.value;
    }
    else if(name == 'prrAddressVerified')
    {
        this.prrAddressVerified = event.target.checked;
    }

    //For CURRENT OFFICE ADDRESS Section
    else if(name == 'officeCityFinacle')
    {
        this.response[index].officeCityFinacle = event.detail.value;
    }

    //GENERAL
    else if(name == 'isCrrOfficeCustomerInformedAboutKYC')
    {
        this.response[index].customerInformedProvideKYCIn3Months = event.target.checked;
        if (!event.target.checked) 
        {
            this.showModal = true;
            this.showModalForUpdateKYC = true;
            this.showModalForChequeBounce = false;          
        }
    }
    else if(name == 'crrOfficeMoneyAskedForProcessing')
    {
        this.response[index].moneyAskedForProcessingDownPayment = event.target.checked;
    }

    //For Nominee DETAILS Section
    else if(name == 'nomineeSAAccountOpening')
    {
        this.response[index].nomineeSAAccountOpening = event.detail.value;
    }
    else if(name == 'nomineeSAAccountOpenedFor')
    {
        this.response[index].nomineeSAAccountOpenedFor = event.detail.value;
    }
    else if(name == 'nomineeAvailable')
    {
        this.response[index].nomineeAvailable = event.target.checked;
    }
    else if(name == 'nomineeName')
    {
        this.response[index].nomineeName = event.detail.value;
    }
    else if(name == 'nomineeDOB')
    {
        this.response[index].nomineeDOB = event.detail.value;
    }
    else if(name == 'nomineeAddress')
    {
        this.response[index].nomineeAddress = event.detail.value;
    }
    else if(name == 'nomineePinCode')
    {
        this.response[index].nomineePinCode = event.detail.value;
    }
    else if(name == 'nomineeCity')
    {
        this.response[index].nomineeCity = event.detail.value;
    }
    else if(name == 'nomineeState')
    {
        this.response[index].nomineeState = event.detail.value;
    }
    else if(name == 'nomineeRelationshipBorrower')
    {
        this.response[index].nomineeRelationshipBorrower = event.detail.value;
    }

    // INDI 4569
    else if(name == 'CB_nomineeSAAccountOpening')
    {
        //this.response[index].nomineeSAAccountOpening = event.detail.value;
        this.response[index].CB_nomineeSAAccountOpening = event.detail.value;
    }
    else if(name == 'CB_nomineeSAAccountOpenedFor')
    {
       // this.response[index].nomineeSAAccountOpenedFor = event.detail.value;
        this.response[index].CB_nomineeSAAccountOpenedFor = event.detail.value;
    }
    else if(name == 'CB_nomineeAvailable')
    {
        //this.response[index].nomineeAvailable = event.target.checked;
        this.response[index].CB_nomineeAvailable = event.target.checked;
    }
    else if(name == 'CB_nomineeName')
    {
       // this.response[index].nomineeName = event.detail.value;
        this.response[index].CB_nomineeName = event.detail.value;
    }
    else if(name == 'CB_nomineeDOB')
    {
        //this.response[index].nomineeDOB = event.detail.value;
        this.response[index].CB_nomineeDOB = event.detail.value;
    }
    else if(name == 'CB_nomineeAddress')
    {
        //this.response[index].nomineeAddress = event.detail.value;
        this.response[index].CB_nomineeAddress = event.detail.value;
    }
    else if(name == 'CB_nomineePinCode')
    {
        //this.response[index].nomineePinCode = event.detail.value;
        this.response[index].CB_nomineePinCode = event.detail.value;
    }
    else if(name == 'CB_nomineeCity')
    {
        //this.response[index].nomineeCity = event.detail.value;
        this.response[index].CB_nomineeCity = event.detail.value;
    }
    else if(name == 'CB_nomineeState')
    {
        //this.response[index].nomineeState = event.detail.value;
        this.response[index].CB_nomineeState = event.detail.value;
    }
    else if(name == 'CB_nomineeRelationshipBorrower')
    {
        //this.response[index].nomineeRelationshipBorrower = event.detail.value;
        this.response[index].CB_nomineeRelationshipBorrower = event.detail.value;
    }

    //For Remarks Section
    else if(name == 'tvrassessment')
    {
        this.response[index].tvrassessment = event.detail.value;
    }
    else if(name == 'tvrAttempts')
    {            
        this.response[index].tvrAttempts = event.detail.value;            
    }
    else if(name == 'tvrRemarks')
    {
        this.response[index].tvrRemarks = event.detail.value;
    }
    else if(name == 'alternateMobileNumber')
    {
        this.response[index].alternateMobileNumber = event.target.value;
    }

    console.log('current rec '+JSON.stringify(this.response[index]));
}

handleFinacleCityChange(event)
{
    console.log('name '+event.detail.fieldName);
    console.log('index '+event.detail.index);
    console.log('value '+event.detail.value);
    
    if(event.detail.fieldName == 'residenceCityFinacle')
    {
        this.response[event.detail.index].residenceCityFinacle = event.detail.value;
    }
    else if(event.detail.fieldName == 'permanentFinacle')
    {
        this.response[event.detail.index].permanentFinacle = event.detail.value; 
    }
    else if(event.detail.fieldName == 'officeCityFinacle')
    {
        this.response[event.detail.index].officeCityFinacle = event.detail.value; 
    }   
}

handleOk()
{
    this.showModal = false;
    this.showModalForUpdateKYC = false;
    this.showModalForChequeBounce = false;
}

handleUploadViewDoc() {
    this.showUpload = true;
    this.showPhotoCopy = false;
    this.showDocView = true;
    this.isVehicleDoc = true;
    this.isAllDocType = false;
    this.uploadViewDocFlag = true;
    this.uploadRCDocFlag = false;
    this.docType = 'Email attachment';
}

handleSubmit()
{      
    var error = false;
    console.log('Submit',JSON.stringify(this.response));
    for(var index=0;index<this.response.length;index++)
    {
        if (this.response[index].applicantType == this.response[index].whoWillRepayLoan && ((this.response[index].nomineeAvailable && this.emptyFieldCheck('.boNomineeField')) || (this.response[index].CB_nomineeAvailable && this.emptyFieldCheck('.cbNomineeField')))) {
            error = true;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please fill all the Nominee Details.',
                    variant: 'error',
                }),
            );
        }
        if(this.response[index].tvrAttempts){
            if(isNaN(this.response[index].tvrAttempts)){
                error = true;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title : 'Error',
                        message : 'Please provide numeric value in Attempts field.',
                        variant : 'error',
                    }),
                )  
            }
        }  
        if(this.response[index].tvrassessment == 'High Risk' && (this.response[index].tvrRemarks == undefined || this.response[index].tvrRemarks=='' || this.response[index].tvrRemarks == null || this.response[index].applicantdocCount < 1) && this.response[index].applicantType == 'Borrower')
        {
            error = true;
            this.dispatchEvent(
                new ShowToastEvent({
                    title : 'Error',
                    message : 'Remark and uploading email attachment is mandatory for High Risk TVR Assessment for borrower.',
                    variant : 'error',
                }),
            )                
        }
        if(this.response[index].tvrassessment == 'High Risk' && (this.response[index].tvrRemarks == undefined || this.response[index].tvrRemarks=='' || this.response[index].tvrRemarks == null || this.response[index].applicantdocCount < 1) && this.response[index].applicantType == 'Co-borrower')
        {
            error = true;
            this.dispatchEvent(
                new ShowToastEvent({
                    title : 'Error',
                    message : 'Remark and uploading email attachment is mandatory for High Risk TVR Assessment for Co-borrower.',
                    variant : 'error',
                }),
            )
        }
    }  
    if(!error)
    {
        updateDetails({ 
            wrapperListForUpdate: this.response,'loanapplicationId':this.loanapplicationid          
        })
        .then((response) => {              
            this.dispatchEvent(
                new ShowToastEvent({
                    title : 'Success',
                    message : 'Details saved succesfully!',
                    variant : 'success',
                }),
            )
        })
        .catch(error => 
        {
            console.log('error '+error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title : 'Error!',
                    message : error?.body?.message,
                    variant : 'error',
                }),
            )
        });    
    }                          
}
    nomineeCitylookupHandler(event){
        const index = event.detail?.index;
            console.log('call apex');
            this.response[event.detail.index].nomineeCity = event.detail.selectedValueName;
            this.response[event.detail.index].nomineeCityId = event.detail.selectedValueId;
        //apex call to get state of selcted city
        getState({FinacalCityCode : event.detail.selectedValueName})
        .then((resp)=>{
            console.log('resp ',resp);
            const result = JSON.parse(resp);
            this.response[event.detail.index].nomineeState = result.Name;
            this.response[event.detail.index].nomineeStateId = result.Id;
        }
        )
        .catch((error)=>{
            console.error('in catch',error)} );
        
        
        console.log(JSON.stringify(this.response,null,2));
    }
    
    nomineeCityClearvaluelookupHandler(event){
        // empty the nominee city
            this.response[event.detail.index].nomineeCity = '';
            this.response[event.detail.index].nomineeCityId = '';
        // empty the nominee city
            this.response[event.detail.index].nomineeState = '';
            this.response[event.detail.index].nomineeStateId = '';
            console.log(JSON.stringify(this.response,null,2));
    }
    CBnomineeCitylookupHandler(event){
        const index = event.detail?.index;
            this.response[event.detail.index].CB_nomineeCity = event.detail.selectedValueName;
            this.response[event.detail.index].CB_nomineeCityId = event.detail.selectedValueId;
        //apex call to get state of selcted city
        getState({FinacalCityCode : event.detail.selectedValueName})
        .then((resp)=>{
            console.log('resp ',resp);
            const result = JSON.parse(resp);
            this.response[event.detail.index].CB_nomineeState = result.Name;
            this.response[event.detail.index].CB_nomineeStateId = result.Id;
        }
        )
        .catch((error)=>{
            console.error('in catch',error)} );
        
        
        console.log(JSON.stringify(this.response,null,2));
    }

     CBnomineeCityClearvaluelookupHandler(event){
        // empty the CBnomineeCity
            this.response[event.detail.index].CB_nomineeCity = '';
            this.response[event.detail.index].CB_nomineeCityId = '';
        // empty the CBnomineeCity
            this.response[event.detail.index].CB_nomineeState = '';
            this.response[event.detail.index].CB_nomineeStateId = '';
            console.log(JSON.stringify(this.response,null,2));

    }

    viewCam() {
        let currentUrl = window.location.href;
        if(currentUrl && currentUrl.includes('/s/')){
            currentUrl = currentUrl.split('/s/')[0];
            window.open(currentUrl+'/apex/IBLCAMPage' + '?id=' + this.camRecId, '_blank');
        }
        else{
            window.open('/apex/IBLCAMPage' + '?id=' + this.camRecId, '_blank');
        }
    }

    emptyFieldCheck(query) {
        let notEmpty = false;
        [...this.template.querySelectorAll(query)].forEach(inputField => {
            if (inputField.value == null || inputField.value == undefined || inputField.value.trim() == '') {
                notEmpty = true;
            }
        });
        return notEmpty;
    }        
}