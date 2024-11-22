import { LightningElement, api, track } from 'lwc';
import RCUVerification from '@salesforce/apex/RCUCaseController.RCUVerification';
import isCommunityUser from '@salesforce/apex/RCUCaseController.isCommunityUser';
import doGenerateTokenAPI from  '@salesforce/apex/IntegrationEngine.doGenerateTokenAPI';
import getCIBILDetails from '@salesforce/apex/IND_CibilEquifaxReportController.getCIBILDetails';
import getFIDetails from '@salesforce/apex/Utilities.getFIDetails';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import Borrower from '@salesforce/label/c.Borrower';
import CoBorrower from '@salesforce/label/c.CoBorrower';
import { NavigationMixin } from 'lightning/navigation';


const columns = [
  
    { label: 'Applicant Name', fieldName: 'ApplicantName' },
    { label: 'Contact number', fieldName: 'Contactnumber' },
    { label: 'Applicant Type', fieldName: 'ApplicantType' },
    { label: 'KYC Address', fieldName: 'KYCAddress' },
   // { label: 'BranchBLCode', fieldName: 'BranchBLCode' },

    {
        type: "button", label: 'CIBIL Report', initialWidth: 100, typeAttributes: {
            label: 'CIBIL Report',
            name: 'CIBIL Report',
            title: 'CIBIL Report',
            disabled: false,
            value: 'CIBIL Report',
            iconPosition: 'left',
            variant:'Brand'
        }
    },
    {
        type: "button", label: 'FI Report', initialWidth: 100, typeAttributes: {
            label: 'FI Report',
            name: 'FI Report',
            title: 'FI Report',
            disabled: false,
            value: 'FI Report',
            iconPosition: 'left',
            variant:'Brand'
        }
    }
];

export default class IND_LWC_Rcu_Address_Verification extends NavigationMixin(LightningElement) {
    @track columns = columns;
    @track data = [];
    @api recordId;
    @track reportURL;
    @track CibilReportURL;
    @track cRIFFURL;
    @track customerType;
    @track cibilId;
    @track FIReportId;
    label = {
        Borrower, CoBorrower
    };
    @track isCommunityUser = false;
   connectedCallback(){
        isCommunityUser({}).then((result)=>{
            this.isCommunityUser = result;
        });
        console.log('recordId::' + this.recordId);

         RCUVerification({ recordId: this.recordId })
        .then(result => {
            console.log("RCU result:: " + JSON.stringify(result));
            this.data = result.ApplicantsDataList;
            this.cibilId = result.ApplicantvsCibilIdMap;
            if(this.cRIFFURL == undefined){
                this.cRIFFURL = result.cRIFFReportURL;
                this.customerType = result.oppCustomerType;
            }
            console.log("RCU cibilId:: " + JSON.stringify(this.cibilId));
            console.log("Map cibilId:: " + JSON.stringify(this.cibilId['a04C2000000b8LCIAY']));

        })
        .catch(error => {
            console.log('error in moving to additional details ' + JSON.stringify(error));
        });

    }
    
    callRowAction(event) {
        let recId = event.detail.row.ApplicantID;
        console.log('recId==',JSON.stringify(event.detail.row.ApplicantID));
        const actionName = event.detail.action.name;
        const applicantTypevalue = event.detail.row.ApplicantType.trim();
        if (actionName === 'CIBIL Report') {
            console.log('CIBIL Report IN',this.cibilId[recId]);
            if (this.customerType == 'Non-Individual' && applicantTypevalue.toUpperCase() === 'BORROWER') {
                if(this.cRIFFURL != undefined){
                    this.viewCRIFFReport();
                }else{
                    this.dispatchEvent(new ShowToastEvent({message: 'There is no CRIFF Report available',variant: 'error',}));
                }
            }else{
                getCIBILDetails({cibilId : this.cibilId[recId]})
                .then( res =>{ 
                    if(res){
                        console.log('res==',JSON.stringify(res));
                        if(res?.Applicant__r?.Applicant_Type__c == this.label.Borrower){
                            this.CibilReportURL =res.CIBIL_Report_URl__c;
                        }else if(res?.Applicant__r?.Applicant_Type__c == this.label.CoBorrower){ 
                                this.CibilReportURL =res.CIBIL_Report_URl__c
                        }else if(res?.Applicant__r?.Applicant_Type__c == 'Beneficiary'){ 
                            this.CibilReportURL =res.CIBIL_Report_URl__c
                        }else if(res?.Applicant__r?.Applicant_Type__c == 'Guarantor'){ 
                            this.CibilReportURL =res.CIBIL_Report_URl__c
                        }
                            this.viewCibilReport();
                    }else{
                        this.dispatchEvent(
                            new ShowToastEvent({
                            message: 'There is no CIBIL Report available',
                            variant: 'error',
                        })
                        );
                        console.log('NoCIBIL Report Present');
                    }
                })
            }
        } else if (actionName === 'FI Report') {
            console.log('FI Report In');
            getFIDetails({applicantId : recId})
            .then(result =>{
                if(result){
                    if(result && result.length > 0){
                        for (let index = 0; index < result.length; index++) {
                            if(this.isCommunityUser){
                                this[NavigationMixin.Navigate]({
                                    type: 'standard__webPage',
                                    attributes: {
                                        url : `/fi-report?currentCaseId=${result[index].Id}&callingFromFIScreen=${true}`
                                    }
                                },false);
                            }else{
                                this[NavigationMixin.Navigate]({
                                    type: 'standard__webPage',
                                    attributes: {
                                        url : `/apex/LWC_FIReportPopupTractor?recordId=${result[index].Id}&callingFromFIScreen=${true}`
                                    }
                                },false);
                            }
                        }
                    }else{
                        this.dispatchEvent(
                            new ShowToastEvent({
                            message: 'There is no Fi Report available',
                            variant: 'error',
                          })
                        );
                    }
                }
                else{
                    this.dispatchEvent(
                        new ShowToastEvent({
                        message: 'There is no Fi Report available',
                        variant: 'error',
                      })
                    );
                }
            }).catch(error=>{
                console.log(error);
            })
        } 
    }

    viewCibilReport() {
        doGenerateTokenAPI()
        .then(resp=>{ 
            this.reportURL = this.CibilReportURL+'&SessionId='+resp;
            this[NavigationMixin.Navigate]({ 
                type:'standard__webPage',
                attributes:{ 
                    url: this.reportURL 
                }                
            })
        }).catch(error=>{
            console.log('error ->'+JSON.stringify(error));
        });
    }

    viewCRIFFReport() {
        doGenerateTokenAPI()
        .then(resp=>{ 
            this.reportURL = this.cRIFFURL+'&SessionId='+resp;
            this[NavigationMixin.Navigate]({ 
                type:'standard__webPage',
                attributes:{ 
                    url: this.reportURL 
                }                
            })
        }).catch(error=>{
            console.log('error ->'+JSON.stringify(error));
        });
    }

}