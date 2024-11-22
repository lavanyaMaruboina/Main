import { LightningElement, track, wire, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getProfile from "@salesforce/apex/AmlCheckData.getProfile";
import updateAml from "@salesforce/apex/AmlCheckData.updateAmlCheck";
import getLoanApplicants from "@salesforce/apex/AmlCheckData.getLoanApplicants";
import changeFilename from '@salesforce/apex/AmlCheckData.changeFilename';
import updateAMLCheckDocument from '@salesforce/apex/AmlCheckData.updateAMLCheckDocument';
import getLoanApplicantData from '@salesforce/apex/AmlCheckData.getLoanApplicantData';
import accessAMLCase from '@salesforce/apex/AmlCheckData.accessAMLCase';
import doEmailServiceCallout from '@salesforce/apexContinuation/IntegrationEngine.doEmailServiceCallout';


import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getRecord, updateRecord } from "lightning/uiRecordApi";
import AML_Check__c from "@salesforce/schema/AML_Check__c";

import AMLCHECK_ID_FIELD from "@salesforce/schema/AML_Check__c.Id";
import AMLCHECK_DOC_FIELD from "@salesforce/schema/AML_Check__c.Documents__c";
import AMLCHECK_CONTENT_DOCID_FIELD from "@salesforce/schema/AML_Check__c.Content_Document_Id__c";
import CA_Decision__c from "@salesforce/schema/AML_Check__c.CA_Decision__c";
import CH_Decision__c from "@salesforce/schema/AML_Check__c.CH_Decision__c";
import CMU_Decision__c from "@salesforce/schema/AML_Check__c.CMU_Decision__c";
import BE_CVO_Decision__c from "@salesforce/schema/AML_Check__c.BE_CVO_Decision__c";

import STATUS_FIELD from "@salesforce/schema/Case.Status";
import CMU_USER from "@salesforce/schema/Case.CMU_User__c";
import LOANAPP_FIELD from "@salesforce/schema/Case.Loan_Application__c";
import OWNER_Id from "@salesforce/schema/Case.OwnerId";
import CASE_ID from "@salesforce/schema/Case.Id";
import PRODUCT_TYPE from "@salesforce/schema/Case.Product_Type__c";

import Exception_Message from "@salesforce/label/c.ExceptionMessage";
import mandotoryDetailsNotProvide from "@salesforce/label/c.Mandotory_details_are_not_given_Please_provide";

const fields = [STATUS_FIELD, LOANAPP_FIELD, CMU_USER, PRODUCT_TYPE];
import LightningAlert from 'lightning/alert'; //CISP-7506
import doGenerateTokenAPI from  '@salesforce/apex/IntegrationEngine.doGenerateTokenAPI';//CISP-7506
import { NavigationMixin } from 'lightning/navigation';
export default class IND_LWC_AmlListForCase extends NavigationMixin(LightningElement) {
    //fields = [ CA_Decision__c, CH_Decision__c, CMU_Decision__c ];
    label = { mandotoryDetailsNotProvide, Exception_Message };
    @track amlrecords = [];
    @track amlrecordList = [];
    @track applicantDetailsWrapperList = [];
    @track pickListCA;
    @track pickListCH;
    @track pickListCMU;
    @track pickListBeCvo;
    @track valueCA;
    @track valueCH;
    @track valueCMU;
    @track valueBeCvo;
    @track toggleSpinner = false;
    @track response = "";
    @track tryCatchError;
    @track retryCount = 0;
    @track disableInitiateAMLCheck = false;
    @track caseStatus;
    @track loanAppId;
    @track selectedAMLCheckId;
    @api index;
    @api profileName;
    @api recordId;
    @track fileName;
    @track isVehicleDoc = true;
    @track isAllDocType = false;
    @track showUpload = true;
    @track showPhotoCopy = false;
    @track docType = "AML";
    @track uploadAMLCheckDocument = false;
    @track uploadAMLDocFlag = true;
    @track loanApplicantId;
    @track caFieldsDisabled;
    @track submitDisabled;
    enableAML = true;

    options = [ //CISP-7506
        {label : 'Positive', value : 'Positive'},
        {label : 'False Positive', value : 'False Positive'}
    ];

    handleAssignBack(event) { //CISP-7506
        let fields = {};
        fields[CASE_ID.fieldApiName] = this.recordId;
        fields[OWNER_Id.fieldApiName] = this.cmuUser;
        this.updateRecordDetails(fields).then(response => {
            const toastevent = new ShowToastEvent({
                title: "Success !",
                message: "Case Assigned back Sucessfully!",
                variant: "success",
                mode: "dismissable",
            });
            this.dispatchEvent(toastevent);
            console.log(JSON.stringify(this.amlrecordList));
        })
    }
    async updateRecordDetails(fields) {const recordInput = { fields };await updateRecord(recordInput).then(result => {}).catch(error => {console.log(error)});}
    
    handleChange(event) { //CISP-7506
        let name = event.currentTarget.name;
        let value = event.currentTarget.value;
        this.postpositiveAlert(value);//CISP-7506
        switch (name) {
            case 'BE-CVO':
                for (let rec of this.amlrecordList) {
                    rec["BE_CVO_Decision__c"] = value;                
                }
                break;
            case 'CMU':
                for (let rec of this.amlrecordList) {
                    rec["CMU_Decision__c"] = value;                
                }
                break;
            case 'CA':
                for (let rec of this.amlrecordList) {
                    rec["CA_Decision__c"] = value;                
                }
                break;
            case 'CH':
                for (let rec of this.amlrecordList) {
                    rec["CH_Decision__c"] = value;                
                }
                break;            
            default:
                break;
        }
    }
    handleCopyRemarksBECVO() {
        this.applyRemarksToAllRows('Remarks_BE_CVO__c');
    }
    handleCopyRemarksCMU() {
        this.applyRemarksToAllRows('Remarks_CMU__c');
    }
    handleCopyRemarksCA() {
        this.applyRemarksToAllRows('Remarks_Credit_Analyst__c');
    }
    handleCopyRemarksCH() {
        this.applyRemarksToAllRows('Remarks_Credit_Head__c');
    }
    applyRemarksToAllRows(fieldName) {
        const updatedRemarks = this.amlrecordList.find(record => record[fieldName] !== null && record[fieldName] !== undefined)?.[fieldName];
        if (updatedRemarks !== undefined && updatedRemarks !== null) {
            this.amlrecordList = this.amlrecordList.map(record => ({
                ...record,
                [fieldName]: updatedRemarks
            }));
        } else {
            console.error(`No remarks found in the ${fieldName} field for any row.`);
        }
    }
    viewCibilReport(event) {//CISP-7506
        let CibilReportURL = event.currentTarget.dataset.url;
        doGenerateTokenAPI()
        .then(resp=>{ 
            let reportURL = CibilReportURL+'&SessionId='+resp;
            this[NavigationMixin.Navigate]({ 
                type:'standard__webPage',
                attributes:{ 
                    url: reportURL 
                }                
            })
        }).catch(error=>{
            console.log('error ->'+JSON.stringify(error));
        });
    }

    get bEcVOFieldsDisabled(){
        if(this.profileName == "IBL Business Executive" || this.profileName == "IBL CVO" || this.profileName == "IBL Partner Community CVO" || this.profileName == 'IBL TF Business Executive' ||
        this.profileName == 'IBL Partner Community TF Business Executive' || this.profileName == 'IBL TF CVO' || this.profileName == 'IBL Partner Community TF CVO'){
            return false;
        }else if(this.profileName == "CMU"){
            return true;
        }else if(this.profileName == "IBL Credit Analyst" || this.profileName == "IBL National Credit Manager" || this.profileName == "IBL State Credit Manager" || this.profileName == "IBL Zonal Credit Manager"){
            return true;
        }
        return;
    }
    get cmuFieldsDisabled(){
        if(this.profileName == "IBL Business Executive" || this.profileName == "IBL CVO" || this.profileName == "IBL Partner Community CVO" || this.profileName == 'IBL TF Business Executive' ||
        this.profileName == 'IBL Partner Community TF Business Executive' || this.profileName == 'IBL TF CVO' || this.profileName == 'IBL Partner Community TF CVO'){
            return true;
        }else if(this.profileName == "CMU"){
            return false;
        }else if(this.profileName == "IBL Credit Analyst" || this.profileName == "IBL National Credit Manager" || this.profileName == "IBL State Credit Manager" || this.profileName == "IBL Zonal Credit Manager"){
            return true;
        }
        return;
    }
    get position() {
        return index + 1;
    }

    get acceptedFormats() {
        return ['.jpg', '.png','.jpeg','.docx','.pdf'];
    }

    @track cmuUser = '';//CISP-7506
    @track productType = '';//CISP-7506

    get showAssignBack() {//CISP-7506
        return this.isCa && this.isTwoWheeler;
    }

    get isTwoWheeler() {//CISP-7506
        return this.productType.toLowerCase() == 'two wheeler';
    }


    get decisionTitleCAZCMSCM() {
        return this.productType == 'Tractor' ? 'SCM/ZCM Decision' : 'CA Decision';
    }
    get remarkTitleCAZCMSCM() {
        return this.productType == 'Tractor' ? 'Remarks SCM/ZCM' : 'Remarks Credit Analyst';
    }

    @wire(getRecord, { recordId: "$recordId", fields })
    wiredCase({ error, data }) {
        if (data) {
            console.debug(data);
            this.caseStatus = data.fields.Status.value;
            if(this.caseStatus == 'Closed') {
                this.enableAML = false;
            }
            this.loanAppId = data.fields.Loan_Application__c.value;
            this.cmuUser = data.fields.CMU_User__c.value;
            this.productType = data.fields.Product_Type__c.value;
            if (this.loanAppId) {
                getLoanApplicantData({
                    loanApplicationId: this.loanAppId
                }).then(result => {
                    console.log('result:: ', result);
                    this.applicantDetailsWrapperList = result;
                });
            }
            if (this.caseStatus) {
                getProfile({
                    caseStatus: this.caseStatus,
                    loanApplicationId: this.loanAppId,
                }).then((record) => {
                    console.debug(record.amlResultList);
                    this.amlrecords = record.amlResultList;
                    let sequence = 1;
                    for (let amlRec of this.amlrecords) {
                        this.amlrecordList.push({
                            Id: amlRec.Id,
                            serialNo:sequence,
                            BE_CVO__c: amlRec.BE_CVO__c,
                            CMU__c: amlRec.CMU__c,
                            Credit_Analyst__c: amlRec.Credit_Analyst__c,
                            Credit_Head__c: amlRec.Credit_Head__c,
                            BE_CVO_Decision__c: amlRec.BE_CVO_Decision__c,
                            CMU_Decision__c: amlRec.CMU_Decision__c,
                            CA_Decision__c: amlRec.CA_Decision__c,
                            CH_Decision__c: amlRec.CH_Decision__c,
                            Remarks_BE_CVO__c: amlRec.Remarks_BE_CVO__c,
                            Remarks_CMU__c: amlRec.Remarks_CMU__c,
                            Remarks_Credit_Analyst__c: amlRec.Remarks_Credit_Analyst__c,
                            Remarks_Credit_Head__c: amlRec.Remarks_Credit_Head__c,
                            Case__c: amlRec.Case__c,
                            ML_City__c: amlRec.ML_City__c,
                            Matched_base__c: amlRec.Matched_base__c,
                            ML_Id__c:amlRec.ML_Id__c,
							Applicant_Number__c:amlRec.Applicant_Number__c,
                            List_Name__c:amlRec.List_Name__c,
                            Name__c:amlRec.Name__c,
                            Name_Score__c:amlRec.Name_Score__c,
                            Nationality__c:amlRec.Nationality__c,
                            ML_Address__c:amlRec.ML_Address__c,
                            ML_Date_Of_Birth__c:amlRec.ML_Date_Of_Birth__c,
                            ML_Description__c:amlRec.ML_Description__c,
							Nationality_Score__c:amlRec.Nationality_Score__c,
							recordCSS: amlRec.Partial_KYC_Flag__c ? 'slds-text-color_error' : 'slds-hint-parent',
                        });
                        sequence++;
                    }
                    this.profileName = record.profileName;
                    console.debug(record);
                    console.debug(
                        "this.amlrecords:: ",
                        JSON.stringify(record.amlResultList)
                    );
                    console.debug(
                        "this.profileName:: ",
                        JSON.stringify(record.profileName)
                    );
                    return record;
                });
                getLoanApplicants({
                    loanApplicationId: this.loanAppId,
                }).then((record) => {
                    console.debug(record);
                    if (record) {
                        this.loanApplicantId = record[0].Id;
                        for (let rec of record) {
                            if (rec.Applicant_Type__c ? rec.Applicant_Type__c.includes('Borrower') : false) {
                                this.loanApplicantId = rec.Id;
                            }
                        }
                    }
                });
            }
        } else if (error) {
            console.debug(this.recordId);
            this.tryCatchError = error;
            console.debug(error);
            this.errorInCatch(this.label.Exception_Message);
        }
    }

    @wire(getObjectInfo, { objectApiName: AML_Check__c })
    amlCheckObject;

    //async
    connectedCallback() { 
        console.log('recordId ', this.recordId);
        accessAMLCase({'caseId' : this.recordId}).then((result)=>{
        console.log('accessAMLCase ', result);
        if(result){
            this.submitDisabled = false;
            this.caFieldsDisabled = false;
        }else{
            this.submitDisabled = true;
            this.caFieldsDisabled = true;
        }
    }) }
    changeUploadAMLDocument(contentDocumentId) {
        if (this.selectedAMLCheckId) {
            updateAMLCheckDocument({
                contentDocId: contentDocumentId,
                amlRecordId: this.selectedAMLCheckId
            }).then((record) => {});
        }
    }
    get isCVO() {
        if (
            this.profileName == "IBL Business Executive" ||
            this.profileName == 'IBL TF Business Executive' ||
            this.profileName == 'IBL Partner Community TF Business Executive' ||
            this.profileName == 'IBL TF CVO' || 
            this.profileName == 'IBL Partner Community TF CVO' ||
            this.profileName == "IBL CVO" || 
            this.profileName == "System Administrator" ||
            this.profileName == "CMU" ||
            this.profileName == "IBL Credit Analyst" ||
            this.profileName == "IBL National Credit Manager" ||
            this.profileName == "IBL State Credit Manager" ||
            this.profileName == "IBL Zonal Credit Manager" ||
            this.profileName == "IBL Partner Community CVO"
        ) {
            return true;
        } else {
            return false;
        }
    }

    get isCmu() {
        if (
            this.profileName == "CMU" ||
            this.profileName == "System Administrator" ||
            this.profileName == "IBL National Credit Manager" ||
            this.profileName == "IBL Zonal Credit Manager" ||
            this.profileName == "IBL Credit Analyst" || this.profileName == "IBL State Credit Manager") {
            return true;
        } else {
            return false;
        }
    }

    get isCa() {
        if (
            this.profileName == "IBL Credit Analyst" || this.profileName == "IBL National Credit Manager" ||
            this.profileName == "System Administrator" || this.profileName == "IBL National Credit Manager" || this.profileName == "IBL State Credit Manager" || this.profileName == "IBL Zonal Credit Manager"
        ) {
            return true;
        } else {
            return false;
        }
    }

    get isCh() {
        if (
            this.profileName == "IBL Credit Head" ||
            this.profileName == "System Administrator"
        ) {
            return true;
        } else {
            return false;
        }
    }
    get isOtbtn() {
        if (
            this.profileName == "IBL Business Executive" ||
            this.profileName == 'IBL TF Business Executive' ||
            this.profileName == 'IBL Partner Community TF Business Executive' ||
            this.profileName == 'IBL TF CVO' || 
            this.profileName == 'IBL Partner Community TF CVO' ||
            this.profileName == "IBL CVO" ||
            this.profileName == "CMU" ||
            this.profileName == "IBL Credit Head" ||
            this.profileName == "System Administrator" ||
            this.profileName == "IBL Partner Community CVO"
        ) {
            return true;
        } else {
            return false;
        }
    }
    get isCabtn() {
        if (this.profileName == "IBL Credit Analyst" || this.profileName == "IBL National Credit Manager" || this.profileName == "IBL State Credit Manager" || this.profileName == "IBL Zonal Credit Manager") {
            return true;
        } else {
            return false;
        }
    }
    get isCmuProfile() {
        if (
            this.profileName == "CMU") {
            return true;
        } else {
            return false;
        }
    }
    get isCmuCa(){
        return this.isCmu || this.isCa;
    }
    get isCaCh(){
        return this.isCa || this.isCh;
    }
    get isCmuCaCh(){
        return this.isCmu || this.isCa || this.isCh;
    }

    postpositiveAlert(detailValue) {//CISP-7506
        if (detailValue == 'Positive') { 
            LightningAlert.open({ 
                message: "you have selected as positive match, do you want to proceed further",
                variant: "header", // if headerless, theme not applicable
                theme: "default", 
                label: "Warning!", // this is the header text
              });
        }
    }

    handleCA(event) {
        try {
            const index = event.target.dataset.name;
            var currentRec = this.amlrecordList[index];
            const detailValue = event.detail.value;
            this.postpositiveAlert(detailValue);//CISP-7506
            
            for (let rec of this.amlrecordList) {
                if (rec.Id.includes(currentRec.Id)) {
                    rec["CA_Decision__c"] = detailValue;
                }
            }
        } catch (error) {
            console.error(error);
        }
    }

    handleCH(event) {
        try {
            const index = event.target.dataset.name;
            var currentRec = this.amlrecordList[index];
            const detailValue = event.detail.value;
            this.postpositiveAlert(detailValue);//CISP-7506
            for (let rec of this.amlrecordList) {
                if (rec.Id.includes(currentRec.Id)) {
                    rec["CH_Decision__c"] = detailValue;
                }
            }
        } catch (error) {
            console.error(error);
        }
    }

    handleCMU(event) {
        try {
            const index = event.target.dataset.name;
            var currentRec = this.amlrecordList[index];
            const detailValue = event.detail.value;
            this.postpositiveAlert(detailValue);//CISP-7506
            for (let rec of this.amlrecordList) {
                if (rec.Id.includes(currentRec.Id)) {
                    rec["CMU_Decision__c"] = detailValue;
                }
            }
        } catch (error) {
            console.error(error);
        }
    }

    handleBeCvo(event) {
        try {
            const index = event.target.dataset.name;
            var currentRec = this.amlrecordList[index];
            const detailValue = event.detail.value;
            this.postpositiveAlert(detailValue);//CISP-7506
            for (let rec of this.amlrecordList) {
                if (rec.Id.includes(currentRec.Id)) {
                    rec["BE_CVO_Decision__c"] = detailValue;
                }
            }
        } catch (error) {
            console.error(error);
        }
    }
    //remark
    handleCaRemark(event) {
        try {
            const index = event.target.dataset.name;
            var currentRec = this.amlrecordList[index];
            const detailValue = event.detail.value;
            for (let rec of this.amlrecordList) {
                if (rec.Id.includes(currentRec.Id)) {
                    rec["Remarks_Credit_Analyst__c"] = detailValue;
                }
            }
        } catch (error) {
            console.error(error);
        }
    }

    handleChRemark(event) {
        try {
            const index = event.target.dataset.name;
            var currentRec = this.amlrecordList[index];
            const detailValue = event.detail.value;
            for (let rec of this.amlrecordList) {
                if (rec.Id.includes(currentRec.Id)) {
                    rec["Remarks_Credit_Head__c"] = detailValue;
                }
            }
        } catch (error) {
            console.error(error);
        }
    }

    handleCmuRemark(event) {
        try {
            const index = event.target.dataset.name;
            var currentRec = this.amlrecordList[index];
            const detailValue = event.detail.value;
            for (let rec of this.amlrecordList) {
                if (rec.Id.includes(currentRec.Id)) {
                    rec["Remarks_CMU__c"] = detailValue;
                }
            }
        } catch (error) {
            console.error(error);
        }
    }

    handleCvoRemark(event) {
        try {
            const index = event.target.dataset.name;
            var currentRec = this.amlrecordList[index];
            const detailValue = event.detail.value;
            for (let rec of this.amlrecordList) {
                if (rec.Id.includes(currentRec.Id)) {
                    rec["Remarks_BE_CVO__c"] = detailValue;
                }
            }
        } catch (error) {
            console.error(error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: "$amlCheckObject.data.defaultRecordTypeId",
        fieldApiName: CA_Decision__c,
    })
    fetchPicklist1({ error, data }) {
        if (data !== undefined) {
            this.pickListCA = data.values;
            console.debug(this.pickListCA);
        } else if (error) {
            console.debug(error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: "$amlCheckObject.data.defaultRecordTypeId",
        fieldApiName: CH_Decision__c,
    })
    fetchPicklist2({ error, data }) {
        if (data !== undefined) {
            this.pickListCH = data.values;
        } else if (error) {
            console.debug(error);
        }
    }
    @wire(getPicklistValues, {
        recordTypeId: "$amlCheckObject.data.defaultRecordTypeId",
        fieldApiName: CMU_Decision__c,
    })
    fetchPicklist3({ error, data }) {
        if (data !== undefined) {
            this.pickListCMU = data.values;
        } else if (error) {
            console.debug(error);
        }
    }
    @wire(getPicklistValues, {
        recordTypeId: "$amlCheckObject.data.defaultRecordTypeId",
        fieldApiName: BE_CVO_Decision__c,
    })
    fetchPicklist4({ error, data }) {
        console.debug(data);
        console.debug(error);
        if (data !== undefined) {
            this.pickListBeCvo = data.values;
        } else if (error) {
            console.debug(error);
        }
    }

    handleInitiateAML() {
        this.toggleSpinner = true;
    }
    async handleSumit() {
        this.submitDisabled = true;
        this.caFieldsDisabled = true;//CISP-3248
        this.toggleSpinner = true;
        console.log("Status" + this.caseStatus);
        console.log("pname" + this.profileName);
        let inputFields;
        if (
            (this.profileName == "IBL Business Executive" ||
            this.profileName == 'IBL TF Business Executive' ||
            this.profileName == 'IBL Partner Community TF Business Executive' ||
            this.profileName == 'IBL TF CVO' || 
            this.profileName == 'IBL Partner Community TF CVO' ||
                this.profileName == "IBL CVO" ||
                this.profileName == "System Administrator" ||
                this.profileName == "IBL Partner Community CVO") &&
            this.caseStatus.includes("Pending with BE_CVO")
        ) {
            // if(this.caseStatus.includes('Pending with BE_CVO')){
            inputFields = this.template.querySelectorAll(".inputBECVODecision");
            //}
        } else if (
            (this.profileName == "CMU" ||
                this.profileName == "System Administrator" ||
                this.profileName == "IBL Partner Community CVO") &&
            this.caseStatus.includes("Pending with CMU")
        ) {
            //if(this.caseStatus.includes('Pending with CMU')){
            inputFields = this.template.querySelectorAll(".inputCMUDecision");
            //}
        } else if (
            (this.profileName == "IBL Credit Analyst" || this.profileName == "IBL National Credit Manager" ||
                this.profileName == "System Administrator" || this.profileName == "IBL State Credit Manager" || this.profileName == "IBL Zonal Credit Manager") &&
            (this.caseStatus.includes("Pending with Credit Analyst") || this.caseStatus.includes("Pending with SCM/ZCM")) //SFTRAC-89
        ) {
            console.log("Status" + this.caseStatus);
            //if(this.caseStatus.includes('Pending with Credit Analyst')){
            console.log("Status" + this.caseStatus);
            inputFields = this.template.querySelectorAll(".inputCADecision");
            // }
        }else if (
            (this.profileName == "IBL Credit Head" || this.profileName == "System Administrator") &&
            this.caseStatus.includes("Pending with Credit Head")
        ) {
            
            inputFields = this.template.querySelectorAll(".inputCHDecision");
        }
        let isValid = true;
        inputFields.forEach((inputField) => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                inputField.focus();
                isValid = false;
            }
        });
        if ((inputFields != undefined && inputFields != '' && inputFields != null && inputFields.length > 0 && isValid) || (this.amlrecordList && this.amlrecordList.length == 0)) {//CISP-3173 OR //CISP-3217
            await updateAml({
                amlRecords: this.amlrecordList,
                loanApplicationId: this.loanAppId,
                caseId: this.recordId
            })
                .then((result) => {
                    console.debug("Result from APex" + result);
                    if(result != 'AML Record Updated successfully!' && result != 'You do not have enough permission to perform this operation.' && result != 'false') {
                        this.toggleSpinner = false;
                        this.submitDisabled = false;
                        this.caFieldsDisabled = false;
                    /*let emailRequest = JSON.parse(result).EmailRequest; //commented due to CISP-3272
                    let successResponse = emailRequest.length;
                    if(successResponse>0){
                        emailRequest.forEach(emailRequestWrapper => {
                            doEmailServiceCallout({emailService : JSON.stringify(emailRequestWrapper)}).then(result=>{
                                result = JSON.parse(result);
                                let count = 0;
                                if(result && result.response && result.response.status == 'SUCCESS'){
                                    count += 1;
                                }
                                if(count == successResponse){
                                    this.submitDisabled = true;
                                    this.caFieldsDisabled = true;
                                    const toastevent = new ShowToastEvent({
                                        title: "Sucess !",
                                        message: "AML Records Updated Sucessfully !",
                                        variant: "success",
                                        mode: "dismissable",
                                    });
                                    this.dispatchEvent(toastevent);
                                }
                            }).catch(error=>{
                              console.error('error in email service callout ', error);
                              this.submitDisabled = false;
                              this.caFieldsDisabled = false;//CISP-3248
                            });
                        });
                    }*/
                    }else if(result == 'You do not have enough permission to perform this operation.'){
                        this.submitDisabled = true;
                        this.caFieldsDisabled = true;
                        this.toggleSpinner = false;
                        const toastevent = new ShowToastEvent({
                            title: "Error!",
                            message: result,
                            variant: "error",
                            mode: "dismissable",
                        });
                        this.dispatchEvent(toastevent);
                        location.reload();
                    }else if(result == 'false'){
                        this.submitDisabled = false;
                        this.caFieldsDisabled = false;
                        this.toggleSpinner = false;
                        const toastevent = new ShowToastEvent({
                            title: "Error!",
                            message: 'You Can\'t close this case because CAM is not generated.',
                            variant: "error",
                            mode: "dismissable",
                        });
                        this.dispatchEvent(toastevent);
                        //location.reload();
                    } else {
                        this.submitDisabled = true;
                        this.caFieldsDisabled = true;
                        this.toggleSpinner = false;
                        const toastevent = new ShowToastEvent({
                            title: "Sucess !",
                            message: result,
                            variant: "success",
                            mode: "dismissable",
                        });
                        this.dispatchEvent(toastevent);
                        location.reload();
                    }
                    //this.response = result;
                    this.toggleSpinner = false;
                    // location.reload();
                    
                    
                })
                .catch((error) => {
                    this.submitDisabled = false;
                    this.caFieldsDisabled = false;//CISP-3248
                    this.toggleSpinner = false;
                    console.error("error:", error);
                    this.errorInCatch(this.label.Exception_Message);
                });
        } else if(!isValid) {//CISP-3173 OR //CISP-3217
            this.submitDisabled = false;
            this.caFieldsDisabled = false;//CISP-3248
            this.toggleSpinner = false;
            this.errorInCatch(this.label.mandotoryDetailsNotProvide);
        }else{
            this.submitDisabled = true;
            this.caFieldsDisabled = true;//CISP-3248
            this.toggleSpinner = false;
        }//CISP-3173 OR //CISP-3217-END
    }
    handleUploadAMLDocument(event) {
        this.selectedAMLCheckId = event.target.dataset.id;
        this.fileName = "AML_" + event.target.dataset.mlid;
        console.debug(this.fileName);
        this.uploadAMLCheckDocument = true;
        this.uploadAMLDocFlag = true;
    }
    uploadDone() {
        this.uploadAMLCheckDocument = false;
    }
    handleFileUpload(event) {
        try {
            console.log('handleFileUpload');
            this.contentDocumentId = event.detail.files[0].documentId;
            this.changeUploadAMLDocument(this.contentDocumentId);
            changeFilename({ contentDocId: this.contentDocumentId, fname: this.fileName }).then(
                result => {
                    console.log('FileName changed.');
                }
            ).catch(error => {
                console.log('FileName not change error' + JSON.stringify(error));
            });
            console.log('Check Document Id : ' + this.contentDocumentId);
            const evt = new ShowToastEvent({
                title: 'Uploaded',
                message: 'File Uploaded successfully..!',
                variant: 'success',
            });
            this.dispatchEvent(evt);
        }
        catch (err) {
            console.debug(err);
        }

    }
    errorInCatch(errMessage) {
        const evt = new ShowToastEvent({
            title: "Error!",
            message: errMessage,
            variant: "error",
        });
        this.dispatchEvent(evt);
    }

}