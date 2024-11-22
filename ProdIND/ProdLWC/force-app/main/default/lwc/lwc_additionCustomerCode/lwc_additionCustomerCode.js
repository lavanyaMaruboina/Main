import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import checkRetryExhausted from '@salesforce/apex/IND_CustomerCodeAdditionCntrl.checkRetryExhausted';
import retryCountIncrease from '@salesforce/apex/IND_CustomerCodeAdditionCntrl.retryCountIncrease';
import checkExposure from '@salesforce/apex/IND_CustomerCodeAdditionCntrl.checkExposure';
import saveNamesearchdetails from '@salesforce/apex/IND_CustomerCodeAdditionCntrl.saveNamesearchdetails';
import fetchCustomerCodeAdditionData from '@salesforce/apex/IND_CustomerCodeAdditionCntrl.fetchCustomerCodeAdditionData';
import fetchOppourtunityData from '@salesforce/apex/IND_CustomerCodeAdditionCntrl.fetchOppourtunityData';
import fetchapplicantData from '@salesforce/apex/IND_CustomerCodeAdditionCntrl.fetchapplicantData';
import deleteCustomerCode from '@salesforce/apex/IND_CustomerCodeAdditionCntrl.deleteCustomerCode';
import doCustomerNameSearchCalloutcredit from '@salesforce/apex/IND_CustomerCodeAdditionCntrl.doCustomerNameSearchCalloutcredit';
import doCustomerNameSearchCallout from '@salesforce/apexContinuation/IntegrationEngine.doCustomerNameSearchCallout';
import doCustomerExposureCallout from '@salesforce/apexContinuation/IntegrationEngine.doCustomerExposureCallout';
import getExposureDetails from '@salesforce/apex/IND_LWC_ExposureAnalysis.getExposureDetails';//CISP-12610
import updateTotalExposureAmount from '@salesforce/apex/IND_LWC_ExposureAnalysis.updateTotalExposureAmount';//CISP-12610
import getDocumentsToCheckPan from '@salesforce/apex/IND_LWC_LoanDetailsCntrl.getDocumentsToCheckPan';//CISP-12610
// Loan Application Update
import OPP_ID_FIELD from '@salesforce/schema/Opportunity.Id';
import STAGENAME from '@salesforce/schema/Opportunity.StageName';
import LASTSTAGENAME from '@salesforce/schema/Opportunity.LastStageName__c';
import { updateRecord } from 'lightning/uiRecordApi';
// Custom Labels
import RetryExhausted from '@salesforce/label/c.Retry_Exhausted';
import ReadOnlyLeadAccess from '@salesforce/label/c.ReadOnlyLeadAccess';
import getTotalExpousreOfLead from '@salesforce/apex/IND_CustomerCodeAdditionCntrl.getTotalExpousreOfLead';//CISP-18978
export default class Lwc_additionCustomerCode extends LightningElement {
    @track exposureApexRefresh;//CISP-12610
    @track totalExposureAmount ;//CISP-12610
    documentCheckdata;//CISP-12610
    @api recordid;
    @api checkleadaccess;//coming from tabloanApplication
    @api currentStage;
    @api isRevokedLoanApplication;
    @track customerList = [];
    @track customerCodeValue;
    @track dealNoValue;
    //@track showCutomerCodeAddtional = true;
    @track showTable = false;
    @track isLoading = false;
    @track showFields = false;
    @track isDisabledDealNo = false;
    @track isDisabledCustomerCode = false;
    @track disableCheckCustomerCodeDealNumber = false;
    @track warningDealNo = false;
    @track warningCustCode = false;
    @track isEnableNext = false;
    @track isDisabledSubmit = false;
    @track isDisabledExposure = false;
    @track consentDisable = false;
    @track currentStageName;
    @track lastStage;
    

    async connectedCallback() {
        this.isLoading = true;//CISP-519
        console.log('lwc_additionCustomerCode connectedCallback');
        //function to fetch applicants cusotmer data
        console.log('ID : ', this.recordid);
        await fetchapplicantData({ loanApplicantionId: this.recordid })
            .then(result => {
                console.log('fetchapplicantData result : ', this.recordid, JSON.stringify(result));
                result.forEach(applicant => {
                    this.customerList.push({
                        'customerCode': applicant.Customer_Code__c,
                        'dealNumber': '',
                        'customerName': applicant.Name,
                        'flag': '',
                        'IsExposureRecived': applicant.IsExposureRecived__c,
                        'disableDelete': true
                    });
                });
            })
            .catch(error => {
                console.log('fetchapplicantData error : ' + error);
            })
     
        //function to fetch additional customer data
        await fetchCustomerCodeAdditionData({ loanApplicantionId: this.recordid })
            .then(result => {
                console.log('fetchCustomerCodeAdditionData result : ', JSON.stringify(result));
                result.forEach(customer => {
                    this.customerList.push({
                        'customerCode': customer.Name,
                        'dealNumber': '',
                        'customerName': customer.Customer_Name__c ? customer.Customer_Name__c : '!',
                        'flag': customer.Flag__c,
                        'IsExposureRecived': customer.IsExposureRecived__c,
                        'disableDelete': false
                    });
                });
            })
            .catch(error => {
                console.log('fetchCustomerCodeAdditionData error : ' + error);
            })

        //function to fetch oppourtunity data
        await fetchOppourtunityData({ loanApplicantionId: this.recordid })
        .then(result => {
            console.log('fetchOppourtunityData result : ', result);
            this.currentStageName = result[0].StageName;
            this.lastStage =  result[0].LastStageName__c;
            this.totalExposureAmount = result[0].Total_Exposures_Amount__c;//CISP-12610
            console.log('current stage ', this.currentStageName);
            console.log('last ', this.lastStage );
            
        })
        .catch(error => {
            console.log('fetchOppourtunityData error : ' + error);
        })


        //function to check retry exhausted
        await checkRetryExhausted({ loanApplicationId: this.recordid })
            .then(result => {
                console.log('checkRetryExhausted result : ', result);
                if (result) {
                    this.consentDisable = true;
                    this.showFields = false;
                }
            })
            .catch(error => {
                console.log("checkRetryExhausted error : ", error);
            });

            console.log('this.checkleadaccess ',this.checkleadaccess);
            if(this.checkleadaccess){//if lead is accessible but user from different profile is viewing that
                const evt = new ShowToastEvent({
                    title: ReadOnlyLeadAccess,
                    variant: 'warning',
                    mode: 'sticky'
                });
                this.dispatchEvent(evt);
                console.log('from tab loan');
                this.disableEverything();
            }
            this.isLoading = false;//CISP-519
            //CISP-12610 start
            getDocumentsToCheckPan({ loanApplicationId: this.recordid  })
              .then(result => {
                console.log('Result', result);
                this.documentCheckdata = JSON.parse(result);
              })
              .catch(error => {
                console.error('Error:', error);
            });//CISP-12610 end
    }

    renderedCallback() {
        console.log('lwc_additionCustomerCode renderedCallback');
        if (this.currentStageName==='Loan Initiation' || this.currentStageName==='Additional Details' || this.currentStageName==='Asset Details' || this.currentStageName==='Vehicle Valuation' || this.currentStageName==='Vehicle Insurance' || this.currentStageName==='Loan Details' || this.currentStageName==='Income Details' || this.currentStageName==='Final Terms'|| this.currentStageName==='Offer Screen' ||  (this.currentStageName!=='Customer Code Addition' && this.lastStage !== 'Customer Code Addition' && this.lastStage != undefined && this.currentStageName != undefined)) {//CISP-519
            this.disableEverything();
        }

        if (this.currentStage === 'Credit Processing') {
            this.disableEverything();
            this.isEnableNext = true;
            if (this.template.querySelector('.next')) {
                this.template.querySelector('.next').disabled = false;
            }
            doCustomerNameSearchCalloutcredit({ loanApplicationId: this.recordid })
                .then(result => {
                    const res = result;
                    console.log(res);
                    if (res === '') {
                        this.isEnableNexttab = false;
                    }
                    else {
                        this.isEnableNexttab = true;
                        console.log('loanApplicantionId ===>' + this.recordid);
                        console.log('Response ===>' + res);
                        this.customerListval = res;
                    }
                })
                .catch(error => {
                    console.log("error checkRetryOfFailCustomerCode " + error);
                })
        }
        if(this.isRevokedLoanApplication){this.disableEverything();}
    }

    addCustomerDeal() {
        console.log('addCustomerDeal');
        this.showFields = true;
        this.isDisabledDealNo = false;
        this.isDisabledCustomerCode = false;
        this.customerCodeValue = null;
        this.dealNoValue = null;
        this.warningCustCode = false;
        this.warningDealNo = false;
    }

    handleCustomerCode(event) {
        console.log('handleCustomerCode');
        this.customerCodeValue = event.target.value;
        if (this.customerCodeValue) {
            this.isDisabledDealNo = true;
            this.dealNoValue = null;
            this.warningCustCode = false;
            this.warningDealNo = false;
        } else {
            this.isDisabledDealNo = false;
        }
    }

    handleDealNumber(event) {
        console.log('handleDealNumber');
        this.dealNoValue = event.target.value;
        if (this.dealNoValue) {
            this.customerCodeValue = null;
            this.isDisabledCustomerCode = true;
            this.warningDealNo = false;
            this.warningCustCode = false;
        } else {
            this.isDisabledCustomerCode = false;
        }
    }

    handleCheckCustomerCodeDealNumber() {
        console.log('handleCheckCustomerCodeDealNumber customerCodeValue : ', this.customerCodeValue, ', dealNoValue : ', this.dealNoValue);
        this.isLoading = true;
        if (this.customerCodeValue) {
            this.customerCodeValue = this.customerCodeValue.trim();
        }
        if (this.dealNoValue) {
            this.dealNoValue = this.dealNoValue.trim();
        }
        if (this.customerCodeValue || this.dealNoValue) {
            this.customerList.forEach(element => {
                if (this.customerCodeValue != null && this.customerCodeValue === element.customerCode) {
                    const evt = new ShowToastEvent({
                        title: "Warning",
                        message: "Already added customer code.",
                        variant: 'warning',
                    });
                    this.dispatchEvent(evt);
                    this.customerCodeValue = null;
                    this.isDisabledDealNo = false;
                    this.isDisabledCustomerCode = false;
                    this.isLoading = false;
                }
            })

            this.customerList.forEach(element => {
                if (this.dealNoValue != null && this.dealNoValue === element.dealNumber) {
                    const evt = new ShowToastEvent({
                        title: "Warning",
                        message: "Already added customer deal number.",
                        variant: 'warning',
                    });
                    this.dispatchEvent(evt);
                    this.dealNoValue = null;
                    this.isDisabledDealNo = false;
                    this.isDisabledCustomerCode = false;
                    this.isLoading = false;
                }
            })

            if (this.customerCodeValue || this.dealNoValue) {
                const payload = {
                    loanApplicationId: this.recordid,
                    customerCode: this.customerCodeValue,
                    dealNumber: this.dealNoValue
                }
                this.executeCustomerNameSearcLogic(payload);
            }
        } else {
            const evt = new ShowToastEvent({
                title: "Warning",
                message: "Please enter either Deal Number or Customer Code.",
                variant: 'warning',
            });
            this.dispatchEvent(evt);
            this.isLoading = false;
        }
    }

    executeCustomerNameSearcLogic(payload) {
        console.log('executeCustomerNameSearcLogic payload : ', JSON.stringify(payload));
        doCustomerNameSearchCallout({ customerNameSearchString: JSON.stringify(payload) })
            .then(result => {
                console.log('doCustomerNameSearchCallout result : ' + JSON.stringify(result));
                const res = JSON.parse(result);
                if (res && res.response && res.response.content[0] && res.response.content[0].Customer_Code) {
                    this.customerList.forEach(element => {
                        if (res.response.content[0].Customer_Code === element.customerCode) {
                            const evt = new ShowToastEvent({
                                title: "Warning",
                                message: "Already added customer code.",
                                variant: 'warning',
                            });
                            this.dispatchEvent(evt);
                            this.customerCodeValue = null;
                            this.dealNoValue = null;
                            this.isDisabledDealNo = false;
                            this.isDisabledCustomerCode = false;
                            this.isLoading = false;
                        }
                    })
                    if (this.customerCodeValue || this.dealNoValue) {
                        saveNamesearchdetails({ loanApplicantionId: this.recordid, payload: result })
                            .then(result => {
                                console.log("saveNamesearchdetails result : ", result);
                                if (result) {
                                    this.customerList.push({
                                        'customerCode': res.response.content[0].Customer_Code,
                                        'dealNumber': this.dealNoValue,
                                        'customerName': res.response.content[0].Customer_Name ? res.response.content[0].Customer_Name : '!',
                                        'flag': res.response.content[0].Flag,
                                        'IsExposureRecived': false,
                                        'disableDelete': false
                                    });
                                    this.customerCodeValue = null;
                                    this.dealNoValue = null;
                                    this.isDisabledDealNo = false;
                                    this.isDisabledCustomerCode = false;
                                    this.showTable = this.customerList.length > 0 ? true : false;
                                    this.isLoading = false;
                                } else {
                                    const evt = new ShowToastEvent({
                                        title: "Error",
                                        message: "Something went wrong while creating Customer Code",
                                        variant: 'error',
                                    });
                                    this.dispatchEvent(evt);
                                    this.isLoading = false;
                                }
                            })
                            .catch(error => {
                                console.log("saveNamesearchdetails error : ", error);
                            });
                    }
                } else {
                    const evt = new ShowToastEvent({
                        title: "Error",
                        message: "No data found for Customer code / Deal number.",
                        variant: 'Error',
                    });
                    this.dispatchEvent(evt);
                    this.isLoading = false;
                }
            })
            .catch(error => {
                console.log('doCustomerNameSearchCallout error : ', error);
            })
    }

    retryCount() {
        console.log('retryCount');
        retryCountIncrease({ loanApplicationId: this.recordid })
            .then(result => {
                if (result) {
                    this.consentDisable = true;
                    this.showFields = false;
                }
                console.log("retryCountIncrease result : ", result);
            })
            .catch(error => {
                console.log("retryCountIncrease error : ", error);
            });
    }

    updateExposureRecived(customerCodeList) {
        console.log('updateExposureRecived');
        this.customerList.forEach(element1 => {
            customerCodeList.forEach(element2 => {
                if (element1.customerCode === element2) {
                    element1.IsExposureRecived = true;
                }
            });
        });
    }

    handleOnfinish(event) {
        console.log('handleOnfinish');
        const evnts = new CustomEvent('offervaleve', { detail: event });
        this.dispatchEvent(evnts);
    }

    checkExposure() {
        console.log('checkExposure');
        this.isLoading = true;
        //function to fetch Check Exposure Exhausted
        checkRetryExhausted({ loanApplicationId: this.recordid })
            .then(result => {
                console.log('checkRetryExhausted result : ', result);
                if (result) {
                    const evt = new ShowToastEvent({
                        title: "Error",
                        message: RetryExhausted,
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);
                    this.consentDisable = true;
                    this.showFields = false;
                    this.isLoading = false;
                }
                else {
                    if (this.customerList.length === 0) {
                        const evt = new ShowToastEvent({
                            title: "Warning",
                            message: "There are no records for exposure",
                            variant: 'warning',
                        });
                        this.dispatchEvent(evt);
                        this.isLoading = false;
                    }
                    else {
                        let customerCodeList = [];
                        this.customerList.forEach(element => {
                            if (element.customerCode && element.IsExposureRecived === false) {
                                customerCodeList.push(element.customerCode);
                            }
                        });
                        if (customerCodeList.length <= 0) {
                            const evt = new ShowToastEvent({
                                title: "Warning",
                                message: "Check exposure done for all records",
                                variant: 'warning',
                            });
                            this.dispatchEvent(evt);
                            this.isLoading = false;
                        }
                        else {
                            this.executeCustomerExposureLogic(customerCodeList);
                        }
                    }
                }
            })
            .catch(error => {
                console.log("checkRetryExhausted error : ", error);
            });
    }

   async executeCustomerExposureLogic(customerCodeList) {
        console.log('executeCustomerExposureLogic customerCodeList : ', JSON.stringify(customerCodeList));
        await doCustomerExposureCallout({ lstCustCodes: customerCodeList, loanAppId: this.recordid })
            .then(result => {
                console.log('doCustomerExposureCallout result : ', JSON.stringify(result));
                const obj = JSON.parse(result);
                if (obj.response?.status == 'SUCCESS') {
                     checkExposure({ lstCustCodes: customerCodeList, loanApplicantionId: this.recordid, exposureResponse: result })
                        .then(result => {
                            console.log('checkExposure result : ', result);
                            if (result) {
                                const evt = new ShowToastEvent({
                                    title: "Success",
                                    message: "Exposure records created successfully",
                                    variant: 'success',
                                });
                                this.dispatchEvent(evt);
                                this.updateExposureRecived(customerCodeList);
                                this.updateTotalExposureAmount();//CISP-12610
                                this.retryCount();
                                this.isLoading = false;
                            } else {
                                const evt = new ShowToastEvent({
                                    title: "Error",
                                    message: "Something went wrong while creating Exposure",
                                    variant: 'error',
                                });
                                this.dispatchEvent(evt);
                                this.retryCount();
                                this.isLoading = false;
                            }
                        })
                        .catch(error => {
                            this.retryCount();
                            console.log('checkExposure error : ', error);
                        });
                }
                else {
                    const evt = new ShowToastEvent({
                        title: "Error",
                        message: "Something went wrong in Customer Exposure Callout",
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);
                    this.retryCount();
                    this.isLoading = false;
                }
            })
            .catch(error => {
                this.retryCount();
                console.log('doCustomerExposureCallout error : ', error);
            });
    }
    //CISP-12610 start
    updateTotalExposureAmount(){
        getExposureDetails({ oppId: this.recordid })
          .then(result => {
            console.log('Result getExposureDetails', result);
            this.exposureApexRefresh = result;
            this.totalExposureAmount = this.exposureApexRefresh.totalExposureAmount
            updateTotalExposureAmount({loanApplicationId: this.recordid,exposureWrapperData:this.exposureApexRefresh})
              .then(result => {
                console.log('Result updateTotalExposureAmount', result);
                if(parseInt(this.totalExposureAmount) >= 1000000 && (this.documentCheckdata?.borrowerPanAvailable == false || this.documentCheckdata?.coborrowerPanAvailable == false )){
                    const evt = new ShowToastEvent({
                        title: "Error",
                        message: "Exposure (Incl. loan amount) is >=10 Lakhs, hence, PAN is mandatory. Please withdraw this lead and create a new lead with PAN",
                        variant: 'Error',
                    });
                    this.dispatchEvent(evt);
                }
              })
              .catch(error => {
                console.error('Error:', error);
            });
          })
          .catch(error => {
            console.error('Error:', error);
        });
    }//CISP-12610 end
    handleDeleteRow(event) {
        let index = event.target.value;
        console.log('handleDeleteRow customer code : ', this.customerList[index].customerCode);
        deleteCustomerCode({ loanApplicantionId: this.recordid, customerCode: this.customerList[index].customerCode })
            .then(result => {
                console.log('handleDeleteRow result : ', result);
                if (result) {
                    if (index > -1) {
                        this.customerList.splice(index, 1);
                    }
                    this.showTable = this.customerList.length > 0 ? true : false;
                    const evt = new ShowToastEvent({
                        title: "Success",
                        message: "Customer Code deleted successfully",
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                    getTotalExpousreOfLead({loanApplicantionId:this.recordid}).then(result =>{
                        console.log('getTotalExpousreOfLead result : ', result);
                        this.totalExposureAmount = result;
                    })
                    .catch(error =>{console.log('getTotalExpousreOfLead error : ' + error);});
                } else {
                    const evt = new ShowToastEvent({
                        title: "Error",
                        message: "Not able to delete selected Customer Code",
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);
                }
            })
            .catch(error => {
                console.log('handleDeleteRow error : ' + error);
            });
    }

    async updateRecordDetails(nextStage) {
        console.log('updateRecordDetails');
        const fields = {};
        fields[OPP_ID_FIELD.fieldApiName] = this.recordid;
        fields[STAGENAME.fieldApiName] = nextStage;
        fields[LASTSTAGENAME.fieldApiName] = nextStage;
        const recordInput = { fields: fields };
        await updateRecord(recordInput)
            .then((result) => {
                console.log('updateRecord successfully', result);
                //let nextStage = 'Insurance Details';
                //this.dispatchEvent(new CustomEvent('submitnavigation', { detail: nextStage }));
            })
            .catch(error => {
                console.log('updateRecord error : ', error);
            });
    }

    handleSubmit() {
        console.log('handleSubmit');
        if (this.currentStage === 'Credit Processing') {
            const nextStage = new CustomEvent('submit');
            this.dispatchEvent(nextStage);
        } else {
            let flagToSubmit = false;
            this.customerList.forEach(element => {
                if (element.customerCode && element.IsExposureRecived === false) {
                    flagToSubmit = true;
                }
            });
            if (this.customerCodeValue || this.dealNoValue) {
                const evt = new ShowToastEvent({
                    title: "Warning",
                    message: 'Please click on "Check Customer Code/Deal Number" button or clear Customer Code/Deal Number',
                    variant: 'warning',
                });
                this.dispatchEvent(evt);
            } else if (flagToSubmit && !this.consentDisable) {
                const evt = new ShowToastEvent({
                    title: "Warning",
                    message: "You have added new Customer Code, Please click on Check Exposure button",
                    variant: 'warning',
                });
                this.dispatchEvent(evt);
            } else if(parseInt(this.totalExposureAmount) >= 1000000 && (this.documentCheckdata?.borrowerPanAvailable == false || this.documentCheckdata?.coborrowerPanAvailable == false )){//CISP-12610
                const evt = new ShowToastEvent({
                    title: "Error",
                    message: "Exposure (Incl. loan amount) is >=10 Lakhs, hence, PAN is mandatory. Please withdraw this lead and create a new lead with PAN",
                    variant: 'Error',
                });
                this.dispatchEvent(evt);
            }else {
                let nextStage = 'Insurance Details';
                let records = this.updateRecordDetails(nextStage).then(() => {
                    console.log('inside update record',records);
                    this.dispatchEvent(new CustomEvent('submitnavigation', { detail: nextStage }));
                    }).catch(error=>{
                        console.log("Error generating audio file: " + error);
                      });
                //this.showCutomerCodeAddtional = false;
               
            }
        }
    }

    disableEverything(){
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
            element.disabled = true
        );
    }
}