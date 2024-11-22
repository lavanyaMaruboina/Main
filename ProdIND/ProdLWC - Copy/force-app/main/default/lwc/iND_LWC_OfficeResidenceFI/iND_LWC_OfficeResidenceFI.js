import { LightningElement, wire, api, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import doFicoDeviationCallout from '@salesforce/apexContinuation/IntegrationEngine.doFicoDeviationCallout';

// ReadOnly OFfice FI
import saveOfficeFI from '@salesforce/apex/IND_OfficeFIReadOnlyController.saveOfficeFI';
import getDocumentsOfFI from '@salesforce/apex/IND_OfficeFIReadOnlyController.getDocumentsOfFI';
import creditProcessing from '@salesforce/label/c.Credit_Processing';
import fieldInvestigation from '@salesforce/label/c.Field_Investigation';
import pendingOfficeFIStatus from '@salesforce/label/c.Pending_Office_FI_Status';
import cordVerGreenColor from '@salesforce/label/c.Coordinates_Verified_Green_Color';
import cordVerAmberColor from '@salesforce/label/c.Coordinates_Verified_Amber_Color';
import cordVerRedColor from '@salesforce/label/c.Coordinates_Verified_Red_Color';
import variation from '@salesforce/label/c.OfficeFI_Final_Income_Variation';
import variationTitle from '@salesforce/label/c.OfficeFI_Final_Income_Variation_Title';
import variationMessage from '@salesforce/label/c.OfficeFI_Final_Income_Variation_Message';
import ofcAcptRejSelMessage from '@salesforce/label/c.Office_FI_Accepted_Rejected_Selection_Error_Message';
import serverDownErrMessage from '@salesforce/label/c.Server_down_error_message';
import acceptedSuccessfully from '@salesforce/label/c.Accepted_Successfully';
import rejectedSuccessfully from '@salesforce/label/c.Rejected_Successfully';
import buildingfrontview from '@salesforce/label/c.buildingfrontview';
import signatureView from '@salesforce/label/c.signatureView';
import caseOfficeFIType from '@salesforce/label/c.Case_Office_FI_Type';
import officeFIStatus from '@salesforce/label/c.Office_FI_Status';
import accepted from '@salesforce/label/c.FI_Accepted';
import rejected from '@salesforce/label/c.FI_Rejected';

const FI_FIELDS = [
    'Field_Investigation__c.Office_FI_Status__c',
    'Field_Investigation__c.Coordinates_Verified__c',
    'Field_Investigation__c.Product__c',
    'Field_Investigation__c.Address_Line_1__c',
    'Field_Investigation__c.Address_Line_2__c',
    'Field_Investigation__c.City__c',
    'Field_Investigation__c.Pin_Code__c',
    'Field_Investigation__c.State__c',
    'Field_Investigation__c.Landmark__c',
    'Field_Investigation__c.Phone_Number__c',
    'Field_Investigation__c.Mobile__c',
    'Field_Investigation__c.Employer_Business_Name__c',
    'Field_Investigation__c.Current_experience_years__c',
    'Field_Investigation__c.Total_Experience_Years__c',
    'Field_Investigation__c.Income__c',
    'Field_Investigation__c.Estimated_Service_Income_as_per_FI__c',
    'Field_Investigation__c.Are_Co_ordinates_Matching_If_Amber__c',
    'Field_Investigation__c.Remarks__c',
    'Field_Investigation__c.SENP_Agriculture_Income__c',
    'Field_Investigation__c.SENP_Own_Shop_Income__c',
    'Field_Investigation__c.SENP_Service_oriented_Income__c',
    'Field_Investigation__c.SENP_Transporter_Income__c',
    'Field_Investigation__c.SENP_Contractor_Income__c',
    'Field_Investigation__c.SENP_Rental_Income__c',
    'Field_Investigation__c.SENP_Pension_Income__c',
    'Field_Investigation__c.Declared_Income_During_Application__c',
    'Field_Investigation__c.Case__c',
    'Field_Investigation__c.Case__r.OwnerId',
    'Field_Investigation__c.Case__r.Origin',
    'Field_Investigation__c.Case__r.Type',
    'Field_Investigation__c.Case__r.CreatedDate',
    'Field_Investigation__c.Case__r.Applicant__c',
    'Field_Investigation__c.Case__r.Applicant__r.Name',
    'Field_Investigation__c.Case__r.Loan_Application__c',
    'Field_Investigation__c.Case__r.Loan_Application__r.StageName',
    'Field_Investigation__c.Case__r.Loan_Application__r.Sub_Stage__c',
    'Field_Investigation__c.Case__r.Loan_Application__r.Is_Mobile_Journey_Completed__c',
    'Field_Investigation__c.Case__r.Loan_Application__r.Vehicle_Type__c',
    'Field_Investigation__c.Case__r.Loan_Application__r.Product_Type__c',
    'Field_Investigation__c.Case__r.Loan_Application__r.Sanction_Status__c'
];

export default class IND_LWC_OfficeResidenceFI extends NavigationMixin(LightningElement) {
    activeSections = ['A','B', 'C','D','E','F','G','H','I','J','K','L','M','N','LocationBoundBy'];
    @api recordId = 'a0s71000000BXK2AAO';
    @track applicationId;
    @track applicantId;
    @track creditFIProcessing = false;
    @track pendingFI = false;
    @track disableButtonOnSubmit = false;
    @track showVariationPopup = false;
    @track variationTitle;
    @track variationMessage;
    @track inputWrapper = {};
    @track fiAccordionTitle;

    get fiStatusOptions() {
        return [
            { label: accepted, value: accepted },
            { label: rejected, value: rejected }
        ];
    }

    fiRecord;
    @wire(getRecord, { recordId: '$recordId', fields: FI_FIELDS })
    wiredFIRecord({ error, data }) {
        if (data) {
            this.fiRecord = data;
            // Prepare Input Wrapper
            this.inputWrapperPopulator();
            //console.log('before inputWrapper..', JSON.stringify(this.inputWrapper));
            // Updating other fields
            this.applicationId = this.inputWrapper.applicationId.value;
            this.applicantId = this.inputWrapper.applicantId.value;
            if (this.inputWrapper.officeFIStatus.value === pendingOfficeFIStatus) {
                this.pendingFI = true;
            }
            if (this.inputWrapper.stage.value === creditProcessing/* && this.inputWrapper.subStage.value === fieldInvestigation*/) {
                this.creditFIProcessing = true;
            }
        }
        else if (error) {
            if(error.body.message) {
                this.showToast('Error!',error.body.message,'error','sticky');
            } else {
                this.showToast('Error!',serverDownErrMessage,'error','sticky');
            }
        }
    }
    
    @wire(getDocumentsOfFI, {applicationId: '$applicationId', applicantId:'$applicantId'})
    wiredFilesResult({ data, error }) {
        if(data){
            console.log('office files data..', JSON.stringify(data));
            if (data.signatureView) {
                this.inputWrapper['signatureView'].value = data.signatureView;
            }
            if (data.buildingfrontview) {
                this.inputWrapper['buildingfrontview'].value = data.buildingfrontview;
            }
        }
        else if (error) { 
            if(error.body.message) {
                this.showToast('Error!',error.body.message,'error','sticky');
            } else {
                this.showToast('Error!',serverDownErrMessage,'error','sticky');
            }
        }
    }

    validateFinalIncome() {
        console.log('Validate Fincal Income logic');
        let variationAmount = this.inputWrapper.Declared_Income_During_Application.value * (parseInt(variation) / 100);
        let maxRange = this.inputWrapper.Declared_Income_During_Application.value + variationAmount;
        let minRange = this.inputWrapper.Declared_Income_During_Application.value - variationAmount;
        if ((minRange <= this.inputWrapper.SENP_Agriculture_Income.value && this.inputWrapper.SENP_Agriculture_Income.value <= maxRange)
            && (minRange <= this.inputWrapper.SENP_Own_Shop_Income.value && this.inputWrapper.SENP_Own_Shop_Income.value <= maxRange)
            && (minRange <= this.inputWrapper.SENP_Service_oriented_Income.value && this.inputWrapper.SENP_Service_oriented_Income.value <= maxRange)
            && (minRange <= this.inputWrapper.SENP_Transporter_Income.value && this.inputWrapper.SENP_Transporter_Income.value <= maxRange)
            && (minRange <= this.inputWrapper.SENP_Contractor_Income.value && this.inputWrapper.SENP_Contractor_Income.value <= maxRange)
            && (minRange <= this.inputWrapper.SENP_Rental_Income.value && this.inputWrapper.SENP_Rental_Income.value <= maxRange)
            && (minRange <= this.inputWrapper.SENP_Pension_Income.value && this.inputWrapper.SENP_Pension_Income.value <= maxRange))
        {
            this.saveOfficeFI();
        }
        else {
            this.variationTitle = variationTitle;
            this.variationMessage = variationMessage;
            this.showVariationPopup = true;
        }
    }

    saveOfficeFI() {
        //console.log('after inputWrapper..', JSON.stringify(this.inputWrapper));
        this.showVariationPopup = false;
        if (this.inputWrapper.Office_FI_Accepted_Rejected.value) {
            this.disableButtonOnSubmit = true;
            saveOfficeFI({ 
                inputWrapper: JSON.stringify(this.inputWrapper)
            })
            .then(result => {
                if(result) {
                    this.showToast('Success!',acceptedSuccessfully,'success','dismissable');
                } else {
                    this.showToast('Success!',rejectedSuccessfully,'success','dismissable');
                }
                const nextStage = new CustomEvent('submit');
                this.dispatchEvent(nextStage);
            })
            .catch(error => {
                if(error.body.message) {
                    this.showToast('Error!',error.body.message,'error','sticky');
                } else {
                    this.showToast('Error!',serverDownErrMessage,'error','sticky');
                }
            });
        }
        else {
            this.showToast('Error!',ofcAcptRejSelMessage,'error','sticky');
        }
    }
    
    previewImage(event){
        console.log('event.target.dataset.id', event.target.dataset.id);
        this[NavigationMixin.Navigate]({ 
            type:'standard__namedPage',
            attributes:{ 
                pageName:'filePreview'
            },
            state:{ 
                selectedRecordId: event.target.dataset.id
            }
        })
    }

    handleFIInputChange(event) {
        console.log('event.target.value', event.target.value);
        this.inputWrapper[event.target.fieldName.slice(0,-3)].value = event.target.value;
    }

    handleFIStatusChange(event) {
        console.log('event.target.value', event.target.value);
        this.inputWrapper['Office_FI_Accepted_Rejected'].value = event.target.value;
    }

    closeVariationPopup() {
        this.showVariationPopup = false;
    }
    
    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }
    
    inputWrapperPopulator() {
        // Color variant based on Coordinates_Verified__c value
        let coordinatesVerifiedVariant = '';
        if (this.fiRecord.fields.Coordinates_Verified__c.value === cordVerGreenColor) {
            coordinatesVerifiedVariant = 'base-autocomplete';
        } else if (this.fiRecord.fields.Coordinates_Verified__c.value === cordVerAmberColor) {
            coordinatesVerifiedVariant = 'warning';
        } else if (this.fiRecord.fields.Coordinates_Verified__c.value === cordVerRedColor) {
            coordinatesVerifiedVariant = 'expired';
        }        
        // FI fields
        this.inputWrapper['fiId'] = { value: this.recordId };
        this.inputWrapper['officeFIStatus'] = { value: this.fiRecord.fields.Office_FI_Status__c.value };
        this.inputWrapper['coordinatesVerfied'] = { label: 'Coordinates Verfied', value: coordinatesVerifiedVariant };
        this.inputWrapper['product'] = { value: this.fiRecord.fields.Product__c.value };
        this.inputWrapper['addrLine1'] = { value: this.fiRecord.fields.Address_Line_1__c.value };
        this.inputWrapper['addrLine2'] = { value: this.fiRecord.fields.Address_Line_2__c.value };
        this.inputWrapper['city'] = { value: this.fiRecord.fields.City__c.value };
        this.inputWrapper['pinCode'] = { value: this.fiRecord.fields.Pin_Code__c.value };
        this.inputWrapper['state'] = { value: this.fiRecord.fields.State__c.value };
        this.inputWrapper['landmark'] = { value: this.fiRecord.fields.Landmark__c.value };
        this.inputWrapper['phoneNo'] = { value: this.fiRecord.fields.Phone_Number__c.value };
        this.inputWrapper['mobile'] = { value: this.fiRecord.fields.Mobile__c.value };
        this.inputWrapper['Employer_Business_Name'] = { value: this.fiRecord.fields.Employer_Business_Name__c.value };
        this.inputWrapper['Current_experience_years'] = { value: this.fiRecord.fields.Current_experience_years__c.value };
        this.inputWrapper['Total_Experience_Years'] = { value: this.fiRecord.fields.Total_Experience_Years__c.value };
        this.inputWrapper['Income'] = {value: this.fiRecord.fields.Income__c.value };
        this.inputWrapper['Estimated_Service_Income_as_per_FI'] = { value: this.fiRecord.fields.Estimated_Service_Income_as_per_FI__c.value };
        this.inputWrapper['Are_Co_ordinates_Matching_If_Amber'] = { value: this.fiRecord.fields.Are_Co_ordinates_Matching_If_Amber__c.value };
        this.inputWrapper['Remarks'] = { value: this.fiRecord.fields.Remarks__c.value };
        this.inputWrapper['SENP_Agriculture_Income'] = { value: this.fiRecord.fields.SENP_Agriculture_Income__c.value };
        this.inputWrapper['SENP_Own_Shop_Income'] = { value: this.fiRecord.fields.SENP_Own_Shop_Income__c.value };
        this.inputWrapper['SENP_Service_oriented_Income'] = { value: this.fiRecord.fields.SENP_Service_oriented_Income__c.value };
        this.inputWrapper['SENP_Transporter_Income'] = { value: this.fiRecord.fields.SENP_Transporter_Income__c.value };
        this.inputWrapper['SENP_Contractor_Income'] = { value: this.fiRecord.fields.SENP_Contractor_Income__c.value };
        this.inputWrapper['SENP_Rental_Income'] = { value: this.fiRecord.fields.SENP_Rental_Income__c.value };
        this.inputWrapper['SENP_Pension_Income'] = { value: this.fiRecord.fields.SENP_Pension_Income__c.value };
        this.inputWrapper['Declared_Income_During_Application'] = { value: this.fiRecord.fields.Declared_Income_During_Application__c.value };
        // Case fields
        this.inputWrapper['caseId'] = { value: this.fiRecord.fields.Case__c.value };
        this.inputWrapper['ownerId'] = { value: this.fiRecord.fields.Case__r.value.fields.OwnerId.value };
        this.inputWrapper['applicantId'] = { value: this.fiRecord.fields.Case__r.value.fields.Applicant__c.value };
        this.inputWrapper['fiRequestGenerationDT'] = { label: 'FI Request Generation date and time', value: this.fiRecord.fields.Case__r.value.fields.CreatedDate.value };
        this.inputWrapper['Origin'] = { value: this.fiRecord.fields.Case__r.value.fields.Origin.value };
        this.inputWrapper['Type'] = { value: this.fiRecord.fields.Case__r.value.fields.Type.value };
        // Applicant fields
        this.inputWrapper['name'] = { label: 'Name', value: this.fiRecord.fields.Case__r.value.fields.Applicant__r.value.fields.Name.value };
        // Opportunity fields
        this.inputWrapper['applicationId'] = {value: this.fiRecord.fields.Case__r.value.fields.Loan_Application__c.value };
        this.inputWrapper['stage'] = { value: this.fiRecord.fields.Case__r.value.fields.Loan_Application__r.value.fields.StageName.value };
        this.inputWrapper['subStage'] = { value: this.fiRecord.fields.Case__r.value.fields.Loan_Application__r.value.fields.Sub_Stage__c.value };
        this.inputWrapper['isMobileJourneyCompleted'] = { value: this.fiRecord.fields.Case__r.value.fields.Loan_Application__r.value.fields.Is_Mobile_Journey_Completed__c.value };
        this.inputWrapper['Vehicle_Type'] = { value: this.fiRecord.fields.Case__r.value.fields.Loan_Application__r.value.fields.Vehicle_Type__c.value };
        this.inputWrapper['Product_Type'] = { value: this.fiRecord.fields.Case__r.value.fields.Loan_Application__r.value.fields.Product_Type__c.value };
        this.inputWrapper['Sanction_Status'] = { value: this.fiRecord.fields.Case__r.value.fields.Loan_Application__r.value.fields.Sanction_Status__c.value };
        // Document fields
        this.inputWrapper['signatureView'] = { label: signatureView, value: '' };
        this.inputWrapper['buildingfrontview'] = { label: buildingfrontview, value: '' };
        //Status field
        if (this.inputWrapper.Type.value === caseOfficeFIType) {
            this.inputWrapper['Office_FI_Accepted_Rejected'] = { label: officeFIStatus, value: '' };
            this.fiAccordionTitle = 'OFFICE RESIDENCE FI';
        }
    }


    onSubmit() {
        this.executeFicoDeviationCalloutSubmit();
    }

    executeFicoDeviationCalloutSubmit() {
        console.log('executeFicoDeviationCalloutSubmit method');
        doFicoDeviationCallout({
            applicantId: this.applicantId,
            loanAppId: this.applicationId
        }).then(result => {
            var state = result.getState();
            console.log('executeFicoDeviationCalloutSubmit success : ', JSON.stringify(state));
            if (state === 'SUCCESS') {
                console.log('From server: ' + result.getReturnValue());
            } else if (state === 'INCOMPLETE') {
                console.log('Continuation action is INCOMPLETE');
            } else if (state === 'ERROR') {
                //this.showToast('Error!', result.getError(), 'error', 'sticky');
            }
        }).catch(error => {
            console.log('executeFicoDeviationCalloutSubmit error : ', JSON.stringify(error));
            /*if (error.body.message) {
                this.showToast('Error!', error.body.message, 'error', 'sticky');
            } else {
                this.showToast('Error!', this.label.serverDownErrMessage, 'error', 'sticky');
            }*/
        });
    }
}