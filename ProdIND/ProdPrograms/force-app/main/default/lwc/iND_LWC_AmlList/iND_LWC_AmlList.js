import { LightningElement, track, wire, api } from "lwc"; 
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import doAMLCheckCallout from "@salesforce/apexContinuation/IntegrationEngine.doAMLCheckCallout";
import getAmlResponse from "@salesforce/apex/AmlCheckData.insertObjectRecords";
import disableInitiateAML from "@salesforce/apex/AmlCheckData.disableInitiateAML";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import AML_Check__c from "@salesforce/schema/AML_Check__c";
import Exception_Message from "@salesforce/label/c.ExceptionMessage";
import GetBorrowerLoanApplicant from "@salesforce/apex/AmlCheckData.getBorrowerLoanApplicant";
import checkRetryExhausted from "@salesforce/apex/AmlCheckData.checkRetryExhausted";
import retryCountIncrease from "@salesforce/apex/AmlCheckData.retryCountIncrease";
import AML from "@salesforce/label/c.AML";
import Please_Retry from "@salesforce/label/c.Please_Retry";
export default class IND_LWC_AmlList extends LightningElement {
    //fields = [ CA_Decision__c, CH_Decision__c, CMU_Decision__c ];
    @track amlrecords = [];
    @track matchedResults;
    @track toggleSpinner = false;
    @track response = "";
    @track tryCatchError;
    @track retryCount = 0;
    @track disableInitiateAMLCheck = false;
    @track redCross;
    @track checkButton;
    @api index;
    @api profileName;
    @api recordid;
    @api applicantid;
    coBorrowerId;
    @track matchedResultsForCoborrower;
    borroApplicantNumber;
    coBorroApplicantNumber;
    amlCaseId=null;
    @api isrevokelead;

    get position() {
        return index + 1;
    }

    @wire(getObjectInfo, { objectApiName: AML_Check__c })
    amlCheckObject;

    //CISP-2735-START
    renderedCallback(){
        if(this.isrevokelead){
            console.log('render if ', this.disableInitiateAMLCheck);
            this.disableInitiateAMLCheck = true;
            console.log('render if then ', this.disableInitiateAMLCheck);
        }
    }
    //CISP-2735-END

    //async
    connectedCallback() {
        this.toggleSpinner = true;//CISP-2735
        GetBorrowerLoanApplicant({ loanApplicationId: this.recordid })
            .then((result) => {
                console.debug(result);
                result.forEach((applicantRec, index) => {
                    if(applicantRec.Applicant_Type__c=='Borrower'){
                        this.applicantid = applicantRec.Id;
                        this.borroApplicantNumber =applicantRec.applicant_number__c;
                    } else {
                        this.coBorrowerId = applicantRec.Id;
                        this.coBorroApplicantNumber =applicantRec.applicant_number__c;
                    }
                });
                
            })
            .catch((error) => {
                //CISP-2735
                const evt = new ShowToastEvent({
                    title: "Error",
                    message: Exception_Message,
                    variant: "Error",
                });
                this.dispatchEvent(evt);
            });
        disableInitiateAML({ loanApplicationId: this.recordid })
            .then((result) => {
                this.toggleSpinner = false;//CISP-2735
                this.disableInitiateAMLCheck = result;
                console.log('disableInitiateAMLCheck ', this.disableInitiateAMLCheck);
                if(!this.disableInitiateAMLCheck){
                     //CISP-3265
                    /*checkRetryExhausted({
                        loanApplicationId: this.recordid
                    })
                    .then((result) => {
                        try {
                            if (result == true) {
                                this.redCross = true;
                                this.checkButton = false;
                                this.disableInitiateAMLCheck = true;
                                this.dispatchEvent(new CustomEvent('amlprocessed', { detail: false }));//CISP-3087
                            }else{*/
                                this.dispatchEvent(new CustomEvent('amlprocessed', { detail: false }));
                           /* }
                        } catch (err) {
                            console.error(err);
                        }
                    })
                    .catch((error) => {
                        console.error("error --> " + error);
                    }); */
                    //CISP-3265
                }else{
                    this.redCross = false;
                    this.checkButton = true;
                    this.dispatchEvent(new CustomEvent('amlprocessed', { detail: true }));
                //}
            }
        })
            .catch((error) => {
                this.toggleSpinner = false;
                const evt = new ShowToastEvent({
                    title: "Error",
                    message: Exception_Message,
                    variant: "Error",
                });
                this.dispatchEvent(evt);
            });
    }

    async handleInitiateAML() {
        console.debug(this.applicantid);
        console.debug(this.recordid);
        //CISP-3265
       /* checkRetryExhausted({
            loanApplicationId: this.recordid
        })
        .then((result) => {
            try {*/
                /*if (result == true) {
                    this.disableInitiateAMLCheck = true;
                    this.redCross = true;
                    this.dispatchEvent(new CustomEvent('amlprocessed', { detail: false }));//CISP-3087
                }else{*/
                    this.disableInitiateAMLCheck = false;
                //}CISP-3265
                if (!this.disableInitiateAMLCheck) {
                    this.toggleSpinner = true;
                    await doAMLCheckCallout({
                            applicantId: this.applicantid,
                            loanAppId: this.recordid,
                        })
                        .then((result) => {
                            this.matchedResults = JSON.parse(result);
                            console.debug(this.matchedResults);
                            if (this.matchedResults) {
                                if(!this.coBorrowerId){//cisp-3087
                                    this.sendResponseToApex(this.matchedResults, this.borroApplicantNumber);
                                }
                                if(this.coBorrowerId){
                                    doAMLCheckCallout({
                                        applicantId: this.coBorrowerId,
                                        loanAppId: this.recordid,
                                    })
                                    .then((result) => {
                                        this.matchedResultsForCoborrower = JSON.parse(result);
                                        console.debug(this.matchedResultsForCoborrower);
                                        if (this.matchedResultsForCoborrower) {
                                            this.sendResponseToApex(this.matchedResults, this.borroApplicantNumber).then(()=>{
                                                this.sendResponseToApex(this.matchedResultsForCoborrower, this.coBorroApplicantNumber);
                                            });
                                            this.toggleSpinner = true;
                                        } else {
                                            this.toggleSpinner = false;
                                            this.retryCount += 1;
                                        }
                                    })
                                    .catch((error) => {
                                        console.debug(error);
                                        this.toggleSpinner = false;
                                        const evt = new ShowToastEvent({
                                            title: "Error!",
                                            message: Please_Retry,
                                            variant: "Error",
                                        });
                                        this.dispatchEvent(evt);
                                        //CISP-3265
                                       /* retryCountIncrease({
                                            loanApplicationId: this.recordid
                                        })
                                            .then((result) => {
                                            if (result == true) {
                                                this.disableInitiateAMLCheck = true;
                                                this.redCross = true;
                                                this.dispatchEvent(new CustomEvent('amlprocessed', { detail: false }));//CISP-3087
                                            }
                                            else{
                                                console.debug(Exception_Message);
                                            }
                                            })
                                            .catch((error) => {
                                            console.error("error --> " + error);
                                            });*/
                                            //CISP-3265
                                    });
                                }
                                this.toggleSpinner = true;
                            } else {
                                this.toggleSpinner = false;
                                this.retryCount += 1;
                            }
                        })
                        .catch((error) => {
                            console.debug(error);
                            this.toggleSpinner = false;
                            const evt = new ShowToastEvent({
                                title: "Error!",
                                message: Please_Retry,
                                variant: "Error",
                            });
                            this.dispatchEvent(evt);
                            //CISP-3265
                            /*retryCountIncrease({
                                loanApplicationId: this.recordid
                            })
                                .then((result) => {
                                if (result == true) {
                                    this.disableInitiateAMLCheck = true;
                                    this.redCross = true;
                                    this.dispatchEvent(new CustomEvent('amlprocessed', { detail: false }));//CISP-3087
                                }
                                else{
                                    console.debug(Exception_Message);
                                }
                                })
                                .catch((error) => {
                                console.error("error --> " + error);
                                });*/
                                //CISP-3265
                    });
                }
                //CISP-3265
           /* } catch (err) {
                console.error(err);
            }*/
       /* })
        .catch((error) => {
            console.error("error --> " + error);
        });*/
        //CISP-3265
        

    }

    async sendResponseToApex(resultResponse, applicantNumber) {
        console.debug("resultResponse ==", JSON.stringify(resultResponse));
        await getAmlResponse({
                resp: JSON.stringify(resultResponse),
                loanApplicationId: this.recordid,
                applicantNumber: applicantNumber,
                amlCaseId: this.amlCaseId
            })
            .then((result) => {
                console.log("result:", result);
                if (result.includes("Error")) {
                    this.toggleSpinner = false;
                    const evt = new ShowToastEvent({
                        title: "Error",
                        message: Please_Retry,
                        variant: "Error",
                    });
                    this.dispatchEvent(evt);
                } else {
                    var toastMsg;
                    if(result.includes('_')){
                        toastMsg = result.split('_')[0];
                        this.amlCaseId = result.split('_')[1];
                    } else {
                        toastMsg = result;
                    }
                    this.toggleSpinner = false;
                    const evt = new ShowToastEvent({
                        title: "Success!",
                        message: toastMsg,
                        variant: "success",
                    });
                    this.dispatchEvent(evt);
                    this.checkButton = true;
                    this.disableInitiateAMLCheck = true;
                    this.dispatchEvent(new CustomEvent('amlprocessed', { detail: true }));
                }
            })
            .catch((error) => {
                console.error(error);
                this.toggleSpinner = false;
                const evt = new ShowToastEvent({
                    title: "Error",
                    message: Exception_Message,
                    variant: "Error",
                });
                this.dispatchEvent(evt);
            });
    }
}