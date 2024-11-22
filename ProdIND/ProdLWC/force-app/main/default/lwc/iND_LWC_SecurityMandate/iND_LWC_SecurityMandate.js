import getDocDetails from '@salesforce/apex/SecurityMandate.getDocDetails';
import { api, LightningElement,track,wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues} from 'lightning/uiObjectInfoApi';
import getLADetails from '@salesforce/apex/SecurityMandate.getLADetails';
import getApplicantData from '@salesforce/apex/SecurityMandate.getApplicantData';
import getChequeData from '@salesforce/apex/SecurityMandate.getChequeData';
import createDocumentForCheque from '@salesforce/apex/IND_DocumentUploadCntrl.createDocumentForCheque';
import saveOrUpdateLoanApplication from '@salesforce/apex/SecurityMandate.saveOrUpdateLoanApplication';
import deleteDocRecord from '@salesforce/apex/SecurityMandate.deleteDocRecord';
import updateDealNumber from '@salesforce/apex/SecurityMandate.updateDealNumber';
import getDealNumberDetails from '@salesforce/apex/SecurityMandate.getDealNumberDetails';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import checkIfReadOnly from '@salesforce/apex/SecurityMandate.checkIfReadOnly'
import LA_OBJECT from '@salesforce/schema/Opportunity';
import LA_Docs_Approved_FIELD from '@salesforce/schema/Opportunity.CVO_Accepts_SPDC_Documents__c';
import DOCS_OBJECT from '@salesforce/schema/Documents__c';
import Docs_CHEQUE_ELIGIBLE_FIELD from '@salesforce/schema/Documents__c.Cheque_legible__c';
import checkIFRTOISSubmitted from '@salesforce/apex/SecurityMandate.checkIFRTOISSubmitted';
import isSecurityMandateSubmitted from '@salesforce/apex/SecurityMandate.isSecurityMandateSubmitted';
import getContentVersion from '@salesforce/apex/SecurityMandate.getContentVersion';
import IBL_Community_Partners_URL from '@salesforce/label/c.IBL_Community_Partners_URL';
export default class IBL_Security_Mandate extends NavigationMixin(LightningElement) {
@api dealId = '';
communityPartnersURL = IBL_Community_Partners_URL;
isCommunityUser;
fileType;
@api currentStep;
isBEVisible
noofCheques = 6;
isCheckBox;
showUpload;
showPhotoCopy;
showDocView;
isVehicleDoc;
isAllDocType;
docType = 'Cheques SPDC';
uploadViewDocFlag;
uploadChequeDocFlag;
applicantid;
vehiclerecordid;
documentRecordId;
isSubmitCall = false;
@api recordId;
isChequeSameBank = false;
isSecurityACH = false;
isBankersignatureverification = false;
isAccountstatement = false;
isProductTypeTF = false;
keyIndex = 0;
productType;
chequeBasedOnProduct;
chequeSequenceTest = false;
@api stageCheck;
@track chequeList = [];
@track result = [];
@track chequeCount = 0;
indexRow=0;
isReadOnly = false;
docsApprovedOptions;
@track approvalLabel ='Documents Approved by CVO';
docsChequeLegibleOptions;
@api
isSubmitDisabled = false;
isPreview = false;
converId;
height = 32;
changeHandler(evt){
this.noofCheques = evt.target.value;
}
handleChangeCheckbox(event){
    this.isSubmitDisabled = false;
this.isChequeSameBank = event.target.checked;
} 

handleCheckbox(event){
    if(event.target.dataset.id == 'SecurityACH') this.isSecurityACH = event.target.checked;
    if(event.target.dataset.id == 'BankerSignatureVerification') this.isBankersignatureverification = event.target.checked;
    if(event.target.dataset.id == 'AccountStatement') this.isAccountstatement = event.target.checked;
    console.log('this.isSecurityACH : ',this.isSecurityACH);
    console.log('this.isBankersignatureverification : ',this.isBankersignatureverification);
    console.log('this.isAccountstatement : ',this.isAccountstatement);
}
@track chequeComp =[];



@wire(getObjectInfo,{ objectApiName: DOCS_OBJECT})
docsChequeLegibleMetadata;
@wire(getObjectInfo,{ objectApiName: LA_OBJECT})
docsApprovedMetadata;

@wire(getPicklistValues, 
    {   recordTypeId: '$docsChequeLegibleMetadata.data.defaultRecordTypeId', 
        fieldApiName: Docs_CHEQUE_ELIGIBLE_FIELD
    })
wiredPickListValue({ data, error }){
    if(data){            
        this.docsChequeLegibleOptions = data.values;   
        console.log('this.docsChequeLegibleOptions'+JSON.stringify(this.docsChequeLegibleOptions));               
    }
    if(error){            
        this.docsChequeLegibleOptions = undefined;
    }
}


@wire(getPicklistValues, 
    {   recordTypeId: '$docsApprovedMetadata.data.defaultRecordTypeId', 
        fieldApiName: LA_Docs_Approved_FIELD
    })
wiredPickListValue1({ data, error }){
    if(data){            
        this.docsApprovedOptions = data.values;   
        console.log('this.docsApprovedOptions '+JSON.stringify(this.docsApprovedOptions));               
    }
    if(error){           
        console.log('ErrorAAAA',error) ;
        this.docsApprovedOptions = undefined;
    }
}


    checkRTOAndPostSecuritySubmit(){
        checkIFRTOISSubmitted({ lAId: this.recordId, dealId: this.dealId })
        .then(result => {
          result = JSON.parse(result);
          console.log('Result when checkIFRTOISSubmitted', result);
          if(result.securityMandate == true && result.RTOSub == true){
              this.isReadOnly = true;
              this.isSubmitDisabled = true;
              this.isCheckBox = true;
          }
        })
        .catch(error => {
          console.error('Error:', error);
      });
    }
    isSecurityMandateSubmittedHandler(){
        isSecurityMandateSubmitted({ lAId: this.recordId, dealId: this.dealId }).then(result =>{
            if(result){
                this.isReadOnly = true;
                this.isSubmitDisabled = true;
                this.isCheckBox = true;
            }
        }).catch(error => {
            console.error('Error:', error);
        })
    }

    checkedPredisSubmit(){
        this.isCheckBox = true;
                    checkIfReadOnly({ lAId: this.recordId, dealId: this.dealId })
                        .then(result => {
                        console.log('Result ** ', result);
                        this.isReadOnly = result;
                        })
                        .catch(error => {
                        console.error('Error:', error);
                     });
                    this.stageCheck = true;
    }
    @api isRevokedLoanApplication;//CISP-2735
    async connectedCallback(){
        console.log('currentStep in security : ',this.currentStep);
        this.isBEVisible = true;
        this.isSubmitDisabled = true;
        console.log('record id ***', this.recordId);
        getApplicantData({ loanApplicationId: this.recordId })
          .then(result => {
            console.log('Result getApplicantData' , result);
            this.applicantid = result.Id;
          })
          .catch(error => {
            console.error('Error:', error);
        });
        await getLADetails({ loanApplicationId: this.recordId, dealId: this.dealId })
            .then(result => {
               result = JSON.parse(result);
                console.log("Remark2", result);   
            if(result!=null){
                console.log('OUTPUT ****: ',);
                this.isBEVisible = result.isOwnerSame;
                this.isCommunityUser = result.isCommunityUser;
                this.isChequeSameBank = result.loanApplication.All_Cheques_are_from_Same_bank__c;
                if(result.loanApplication.CVO_Accepts_SPDC_Documents__c !='' || result.loanApplication.CVO_Accepts_SPDC_Documents__c != undefined){
                this.CVOSPDCDoc=result.loanApplication.CVO_Accepts_SPDC_Documents__c;
                }
                this.CVORemaeks=result.loanApplication.CVO_Remarks_SPDC__c;
                this.productType = result.loanApplication.Product_Type__c;
                console.log('OUTPUT |||: ',this.productType);
                if(this.productType =='Tractor'){
                    this.isProductTypeTF = true;
                    this.approvalLabel = 'Documents Approved by PE';
                }
                //this.applicantid = result.Applicant__c;
                this.loanstage = result.loanApplication.StageName;
                
                if(this.loanstage == 'Disbursement Request Preparation' && this.currentStep == 'post-sanction'){
                    console.log('security mandate when stage is disbursment and step is post sanction : ',);
                    this.checkRTOAndPostSecuritySubmit();

                }else if(this.loanstage == 'Disbursement Request Preparation' && this.currentStep == 'pre-disbursement'){
                    console.log('security mandate when stage is disbursment and step is pre dis sanction : ',);
                    this.checkedPredisSubmit();
                }
                if(this.loanstage == 'Pre Disbursement Check' && this.currentStep != 'post-sanction'){
                    console.log('security mandate when stage is pre-disbursment and step is not post sanction : ',);
                    this.checkedPredisSubmit();
                }else if(this.loanstage == 'Pre Disbursement Check' && this.currentStep == 'post-sanction'){
                    console.log('security mandate when stage is pre-disbursment and step is post sanction : ',);
                    this.isReadOnly = true;
                    this.isSubmitDisabled = true;
                    this.isCheckBox = true;
                    //this.stageCheck = false;
                    //this.isCheckBox = false;
                }
                if(this.loanstage == 'Post Sanction Checks and Documentation'){
                    this.checkRTOAndPostSecuritySubmit();
                    this.isSecurityMandateSubmittedHandler();
                }
                
               this.vehiclerecordid = result.loanApplication.Vehicle_Details__r.records[0].Id;
               console.log('OUTPUT --  : ',this.vehiclerecordid);
                this.getChequeDataDetails();
              
               //this.getDocDetails(this.recordId);
            }
            })
            .catch(error => {
                this.error = error;
                console.log('error : ',error);
            });
           
            
            

    getDocDetails({ loanApplicationId: this.recordId, dealId: this.dealId })
    .then(result => {    
        console.log('OUTPUT getDocDetails: ',result);
       
        let data = JSON.parse(result);
        console.log('data ***: ',data.contentDocId);
       
        if(data.docDetails.length>0){
            for(let i=0; i<data.docDetails.length; i++)
        {
            let chqSeq = i+1;
            let docIdVal = data.docDetails[i].Id;
            console.log('data.contentDocId[docIdVal] : ',data.contentDocId[docIdVal]);
            let conVal = data.contentDocId[docIdVal];
            console.log('data.contentVersionId--',data.contentVersionId[conVal]);
            this.chequeList.push({'id': i,'chequeSeq':chqSeq,'chequeNo':data.docDetails[i].Cheque_Number__c,'chequePreview':data.contentDocId[docIdVal],'chequeLegible':data.docDetails[i].Cheque_legible__c,
            'chequeRemarks':data.docDetails[i].Remarks__c,'docId':data.docDetails[i].Id,'chequeUnique':data.docDetails[i].Name,'contentVersion':data.contentVersionId[conVal] }); 
        
            
        }
        this.chequeCount = this.chequeList.length;
        }
       
        
       
})
.catch(error => {
   
    this.error = error;
                });

        if(this.productType =='Tractor')
        {
            getDealNumberDetails({dealId : this.dealId})
            .then(result =>{
            console.log('getDealNumberDetails result='+JSON.stringify(result));
            this.isSecurityACH = result.Security_ACH__c ? result.Security_ACH__c : false;
            this.isBankersignatureverification = result.Banker_signature_verification__c ? result.Banker_signature_verification__c : false;
            this.isAccountstatement = result.Account_statement__c ? result.Account_statement__c : false;
            this.CVOSPDCDoc=result.Accepts_SPDC_Documents__c ? result.Accepts_SPDC_Documents__c : '';
            this.CVORemaeks = result.Remarks_SPDC__c ? result.Remarks_SPDC__c : '';
            this.isChequeSameBank = result.All_Cheques_are_from_Same_bank__c ? result.All_Cheques_are_from_Same_bank__c : false;
            this.chequeCount =result.Number_of_SPDC_collected__c ? result.Number_of_SPDC_collected__c : 0;
            })
            .catch(error =>{
                console.log('getDealNumberDetails =>'+error);
            })
        }

        if(this.isRevokedLoanApplication){this.disableEverything();}//CISP-2735
    }
    renderedCallback(){
        if(this.isRevokedLoanApplication){this.disableEverything();}//CISP-2735
    }
    disableEverything(){
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
            element.disabled = true
        );
    }//CISP-2735-END


        getChequeDataDetails(){
            console.log('getChequeData productType',this.productType)
            getChequeData({ productType: this.productType })
                .then(result => {
                console.log('Result', result);
                if(result.Product_Type__c == this.productType){
                    this.chequeBasedOnProduct = result.Number_of_Cheque__c;
                }
                console.log('chequeBasedOnProduct : ',this.chequeBasedOnProduct);
                })
                .catch(error => {
                console.error('Error:', error);
            });
        }


get shouldDisplay() {
return this.index <= 6;
}


addRow(event){

let addBtn1 = this.template.querySelector('.addBtn1'); 
let dataNOtFound = false;
let chequeDocNOotFound = false;
console.log('this.chequeList.length before: ',this.chequeList.length);
let chqNO = this.template.querySelectorAll(".chqNO");
if(this.chequeList.length > 0){
    console.log('this.chequeList.length : ',this.chequeList.length);
    console.log('chqNO : ',chqNO.length);
    dataNOtFound = false;
    chqNO.forEach(element => {
        console.log('element : ',element);
        if(element.value == undefined || element.value == ''){
            dataNOtFound = true;
        }
    })
    this.chequeList.forEach(element => {
        if(element.chequePreview == undefined || element.chequePreview == ''){
            chequeDocNOotFound = true;
        }else{
            chequeDocNOotFound = false;
        }
    });
}
if(dataNOtFound || chequeDocNOotFound){
    this.dispatchEvent(
        new ShowToastEvent({
            title: 'Error',
            message : 'Please provide cheque number and cheque image before adding new row.',
            variant: 'error',
        }),
    );
    //addBtn1.setCustomValidity('Please provide cheque number and cheque image before adding new row.');
    }else{
    //addBtn1.setCustomValidity('');
    }
    //addBtn1.reportValidity();
if(!dataNOtFound && !chequeDocNOotFound){
    this.keyIndex = this.chequeList.length;
    let chqSeq = this.keyIndex + 1;
    
        this.chequeList.push({'id': this.keyIndex,'chequeSeq':chqSeq,'chequeNo':'','chequePreview':'','chequeLegible':'',
    'chequeRemarks':'' }); 
        ++this.keyIndex;
        ++this.chequeCount;
    
    console.log('this.chequeList : ',this.chequeList);
}

}
deleteRow(event){
this.isSubmitDisabled = false;
let chqNO = this.template.querySelectorAll(".chqNO");
chqNO.forEach(element => {
    console.log('element : ',element.id);
    this.chequeList.forEach(item => {
        console.log('item : ',item.id);
        if(item.id == parseInt(element.id.split('-')[0])){
            item.chequeNo = element.value;
        }
    });
});
console.log('this.chequeList--- : ',this.chequeList);
let tempList = [];
let deleteTempList =[];
    console.log('Check == ' , this.chequeList);
    tempList = this.chequeList.filter(function (element) {
        return parseInt(element.id) !== parseInt(event.target.id);
    })
    deleteTempList = this.chequeList.filter(function (element) {
        return parseInt(element.id) === parseInt(event.target.id);
    })
    console.log('tempList',tempList);
    console.log('deleteTempList',deleteTempList);
    this.chequeList = [];
    for(let i = 0 ; i< tempList.length ; i++){ 
        console.log(' Temp Loop == ' , tempList[i]);
        this.chequeList.push({'id': i,'chequeSeq':i+1,'chequeNo':tempList[i].chequeNo,'chequePreview':tempList[i].chequePreview,
    'docId':tempList[i].docId,'chequeUnique': this.docType + ' ' + this.recordId + ' ' + (i+1)}); 
    }
    console.log('chequeList == ',this.chequeList);
    this.chequeCount = this.chequeList.length;
    //var index=event.target.dataset.targetId;
    //console.log('OUTPUT index ****: ',index-1);
    //console.log('this.chequeList[index].docId : ',this.chequeList[index-1].docId);
    
        deleteDocRecord({loanApplicationId : this.recordId,updatedList: JSON.stringify(this.chequeList), deleteList : JSON.stringify(deleteTempList), dealId: this.dealId })
            .then(result => {
            console.log('Result', result);
            })
            .catch(error => {
            console.error('Error:', error);
        });
    


}

handleInputFieldChange(event)
{
const index = event.target.dataset.targetId;

console.log(this.chequeList);
const name = event.target.name;

console.log('index '+index+' Name '+name);

//For KYC Section
if(name == 'chequeNumber')
{
    console.log('indx--- : ',index);
    console.log('chequeNumber *****  : ',this.indexRow);
    console.log('chequeNumber event.detail.value*****  : ',event.detail.value);
    if(isNaN(event.detail.value) || event.detail.value == '' ){
        console.log('not a number : ',);
    }else{
        console.log(' a number : ',);
    this.chequeList[index].chequeNo = parseFloat(event.detail.value);
    }
}
if(name == 'Is sale DD legible ?')
{

this.CVOSPDCDoc = event.detail.value;
 
}
 if(name == 'chassisNumberFieldCapturedIntially')
{
this.CVORemaeks = event.detail.value;
}
 if(name == 'chequeLegible')
{
    this.chequeList[index].chequeLegible = event.detail.value;
}
if(name == 'chequeRemarks')
{
   
    this.chequeList[index].chequeRemarks = event.detail.value;
}
this.isSubmitDisabled = false;
}
@api handleSubmitFromParent(){
    this.dataSaveFromSubmit(this.loanstage,false);
}
handleSubmit(){
    this.dataSaveFromSubmit(this.loanstage,true);

}
async dataSaveFromSubmit(loanStage,submitFlag){
    let isSuccess = false;
    console.log('OUTPUT dataSaveFromSubmit loanStage: ',loanStage);
    console.log('OUTPUT dataSaveFromSubmit submitFlag: ',submitFlag);
    var error = false;

    let remarksError = false;   
    let CVOError = false;   
     
    if((this.CVOSPDCDoc == '' || this.CVOSPDCDoc == undefined || this.CVOSPDCDoc == null) && this.loanstage == 'Pre Disbursement Check')
    {
        console.log('Inside');
        CVOError = true;
        this.dispatchEvent(
            new ShowToastEvent({
                title : 'Error',
                message : 'Documents Approved by CVO is mandatory',
                variant : 'error',
            }),
        )                
    }else{
       CVOError = false; 
    }
    if((this.CVOSPDCDoc == 'No' && (this.CVORemaeks == '' || this.CVORemaeks == undefined || this.CVORemaeks == null)) && this.loanstage == 'Pre Disbursement Check')
    {
   
        console.log('Inside');
        remarksError = true;
        this.dispatchEvent(
            new ShowToastEvent({
                title : 'Error',
                message : 'CVO Remarks is mandatory if Documents Approved by CVO is selected as No',
                variant : 'error',
            }),
        )                
    }else{
        remarksError = false; 
    }



console.log('in handle click : ',);
let allDataAreFilled = false;
let dataNOtFound = false;
let chequeDocNOotFound = false;



let chqNO = this.template.querySelectorAll(".chqNO");
if(this.chequeList.length > 0){
console.log('this.chequeList.length : ',this.chequeList.length);
console.log('chqNO : ',chqNO.length);
await chqNO.forEach(element => {
    console.log('element : ',element);
    if(element.value == undefined || element.value == '' || element.value == null){
        dataNOtFound = true;
    }
})
chequeDocNOotFound = false;
await this.chequeList.forEach((element) => {
    if(element.chequePreview == undefined || element.chequePreview == '' || element.chequePreview == null){
        chequeDocNOotFound = true;
    }
})
}







if((dataNOtFound || chequeDocNOotFound) && this.loanstage != 'Pre Disbursement Check'){
    isSuccess = false;
allDataAreFilled = true;
this.dispatchEvent(
    new ShowToastEvent({
        title: 'Error',
        message : 'Please provide cheque number and cheque image before submit.',
        variant: 'error',
    }),
);
//addBtn1.setCustomValidity('Please provide cheque number and cheque image before adding new row.');
}else{
allDataAreFilled = false;
//addBtn1.setCustomValidity('');
}
let issameBank = false;
let issameChqCount = false;
let chequeCheckBox = this.template.querySelector(".allCheque");
let submitBtn1 = this.template.querySelector('.submitBtn1'); 
console.log('chequeCheckBox : ',chequeCheckBox); 

    let result = await getDocDetails({ loanApplicationId: this.recordId , dealId: this.dealId});
    let data = JSON.parse(result);
    if(!this.stageCheck){
        console.log('data 530 ',data);
    if(!this.isChequeSameBank && data.docDetails.length > 0){    
    issameBank = true;
    this.dispatchEvent(
        new ShowToastEvent({
            title: 'Error',
            message : 'Please acknowledge that all cheques are from the same bank',
            variant: 'error',
        }),
    );
    //chequeCheckBox.setCustomValidity('Please Acknowledge that all cheques are from the same bank');
    }
else{
    issameBank = false
    //chequeCheckBox.setCustomValidity('');
    }
    //chequeCheckBox.reportValidity();
}
let chequeArr = this.chequeBasedOnProduct.split(',');
console.log('chequeArr : ',chequeArr);
let isSameCount = false;
await chequeArr.forEach(element => {
    console.log('chequeArr element : ',element);
    if(!isSameCount){
        console.log('chequeArr isSameCount : ',isSameCount);
    if(parseInt(element) == data.docDetails.length){
        console.log('same : ',);
        isSameCount = true;
    }else{
        isSameCount = false;
    }
    }
});
console.log('isSameCount 000: ',isSameCount);
    let fieldsChecked = false;
    if(this.isProductTypeTF == true && this.chequeCount == 0 && (this.isSecurityACH == false || this.isBankersignatureverification == false || this.isAccountstatement == false))
    {
        fieldsChecked = true;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message : 'The following fields are mandatory \'If no. of cheques is 0\': Security ACH, Banker signature verification and Account statement',
                variant: 'error',
            }),
        );
    }

    if(this.chequeCount != 0 && isSameCount == false && issameBank == false && this.loanstage != 'Pre Disbursement Check' ){//CISP-5932
    issameChqCount = true
    this.dispatchEvent(
        new ShowToastEvent({
            title: 'Error',
            message : 'Please add exactly the same number of cheques as populated in Number of SPDC to be allowed field',
            variant: 'error',
        }),
    );
    
    }else{
    issameChqCount = false
    
    }
 
 console.log('this.chequeList *******: ',this.chequeList);
 console.log('error-A',CVOError);
 console.log('remarksError',remarksError);
    if(issameChqCount == false && issameBank == false && allDataAreFilled == false &&  CVOError == false && remarksError == false && fieldsChecked == false){
     
        saveOrUpdateLoanApplication({ loanApplicationId: this.recordId,sameBankAccount:this.isChequeSameBank,numberOfChecks:this.chequeList.length,cvo:this.CVOSPDCDoc, remarks:this.CVORemaeks,lstDoc:JSON.stringify(this.chequeList),
            loanStageName:loanStage,submitFlag:submitFlag, dealId: this.dealId })
            .then(result => {
                if(this.stageCheck == true){
                   this.isReadOnly = true;
                }else{
                    this.isReadOnly = false;
                }
                this.isSubmitDisabled = true;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message : 'Loan application successfully updated',
                    variant: 'success',
                }),
            );
            
            this.isReadOnly = true;
            this.isSubmitDisabled = true;
            this.isCheckBox = true;
            })
            .catch(error => {
                console.log('error in submit : ',error);
                this.isReadOnly = false;
            
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message : error.body.message,
                    variant: 'error',
                }),
            );
        });
        if(this.isProductTypeTF == true)
        {
            updateDealNumber({ dealId: this.dealId, securityACH: this.isSecurityACH , BankerSignature: this.isBankersignatureverification , AccountStatement: this.isAccountstatement })
            .then(result =>{
                console.log('deal number is updated');
            })
            .catch(error => {
                console.log('error in submit : ',error);
            })
        }

        isSuccess = true;
    }
    if(submitFlag == false){
    const actionResultEvent = new CustomEvent("submitresultaction", {
        detail: {isSuccess: isSuccess}
      });
  
      // Dispatches the event.
      this.dispatchEvent(actionResultEvent);
    }
}

handleUploadViewAndDelete(event){
this.isSubmitCall = false;
this.isSubmitDisabled = false;
this.docType = 'Cheques SPDC';
var index=event.target.dataset.targetId;
console.log('index ---: ',index);
this.indexRow = index;
var cheSeq = this.chequeList[index].chequeSeq;
console.log('cheSeq ----: ',cheSeq);
let chqNOList = this.template.querySelectorAll(".chqNO");

var chqno = chqNOList[index].value;
console.log('cheSeq ----: ',cheSeq);

if(chqno){
    console.log('this.applicantid : ',this.applicantid);
createDocumentForCheque({docType:this.docType,vehicleDetailId: this.vehiclerecordid,applicantId:this.applicantid,loanApplicationId: this.recordId,
    chequeNum:chqno,chequeSeq:cheSeq })
    .then(result => {
    
    this.chequeList[this.indexRow].docId = result;
    this.documentRecordId = result;
    this.showUpload = true;
    this.showPhotoCopy = false;
    this.showDocView = false;
    this.isVehicleDoc = true;
    this.isAllDocType = false;
    this.uploadViewDocFlag = false;
    this.uploadChequeDocFlag = true;
    
    })
    .catch(error => {
   
});
}else{
    this.dispatchEvent(
        new ShowToastEvent({
            title: 'Error',
            message : 'Please enter cheque number',
            variant: 'error',
        }),
    );
}

}

        changeFlagValue() {
        console.log('OUTPUT changeflagvalue: ',this.uploadChequeDocFlag);
        this.uploadChequeDocFlag = false;
        console.log('after changeflagvalue: ',this.uploadChequeDocFlag);
        }
        handleChequeNoChange(){
            this.isSubmitCall = false;
            this.isSubmitDisabled = false;
        }
        docUploadSuccessfully(event){
        this.ContentDocumentId = event.detail;
        console.log('this.ContentDocumentId ---- : ',this.ContentDocumentId);
        let chequePreviewList = this.template.querySelectorAll(".chequePreview");
        console.log('index--- : ',this.indexRow);
        this.chequeList[this.indexRow].chequePreview = this.ContentDocumentId;
        if(this.ContentDocumentId){
            getContentVersion({ conDocId: this.ContentDocumentId })
              .then(result => {
                console.log('getContentVersion', result);
                if(result!=null){
                    this.chequeList[this.indexRow].contentVersion = result[0].Id;
                    this.chequeList[this.indexRow].fileType = result[0].FileType;
                }
              })
              .catch(error => {
                console.error('Error:', error);
            });
        }
        console.log('chequeList : ',this.chequeList);
        }
        handlePreview(event){
            this.fileType = '';
        this.isSubmitCall = false;
        var index=event.target.dataset.targetId;
        console.log('index in preview : ',index);
        let conDoc = this.chequeList[index].chequePreview;
        
        let fileId;
        if(!this.isCommunityUser){
            fileId = this.chequeList[index].chequePreview;
        }else if(this.isCommunityUser){
            fileId = this.chequeList[index].contentVersion;
        }
        console.log('index in fileId : ',fileId);
        if(fileId){
            this.previewFile(fileId,conDoc);
        }
        }
        previewFile(fileId,conDoc){
        console.log('preview Id'+ fileId);
        if(!this.isCommunityUser){
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'filePreview'
                },
                state : {
                    selectedRecordId:  fileId
                }
            });
        }else if(this.isCommunityUser){
            this.loadCommunity(fileId,conDoc);
            
        }
        }

        async loadCommunity(fileId,conDoc){
            /*await getContentVersion({ conDocId: conDoc })
            .then(result => {
              console.log('getContentVersion', result);
              if(result!=null){
                  this.fileType = result[0].FileType;
              }
              
            })
            .catch(error => {
              console.error('Error:', error);
            });
            console.log('this.fileType : ',this.fileType);
            this.sendData(fileId);*/

            this.converId = fileId;
            this.isPreview = true;

            }
            sendData(fileId){
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url : this.communityPartnersURL+ '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' +fileId
                    }
                }, false );
            }

            hideModalBox(){
                this.isPreview = false;
            }


        }