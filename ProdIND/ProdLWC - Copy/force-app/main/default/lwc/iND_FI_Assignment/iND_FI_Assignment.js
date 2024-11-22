import { LightningElement, track, wire, api } from 'lwc';
import GEO_STATE_MASTER_OBJECT from '@salesforce/schema/Geo_State_Masters__c';
import STATE_NAME from '@salesforce/schema/Geo_State_Masters__c.Name';
import STATE_ID from '@salesforce/schema/Geo_State_Masters__c.Id';
import assignmentFIApp from '@salesforce/apex/FIAssignmentController.assignmentFIApp';
import getLoanApplicationDetails from '@salesforce/apex/FIAssignmentController.getLoanApplicationDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { NavigationMixin } from 'lightning/navigation';
import ID_FIELD from "@salesforce/schema/Case.Id";
import OpportunityID_FIELD from "@salesforce/schema/Case.Loan_Application__c";
import AccountID_FIELD from "@salesforce/schema/Case.Loan_Application__r.AccountId";
import ProductType_FIELD from "@salesforce/schema/Case.Loan_Application__r.Product_Type__c";
import USERROLE_FIELD from "@salesforce/schema/Case.Loan_Application__r.Owner.UserRole.Name";
import OWNER_FIELD from "@salesforce/schema/Case.OwnerId";
import isCommunity from '@salesforce/apex/LwcLOSLoanApplicationCntrl.isCommunity';
import FORM_FACTOR from '@salesforce/client/formFactor';

import OPPID_FIELD from "@salesforce/schema/Opportunity.Id";
import OPP_AccountID_FIELD from "@salesforce/schema/Opportunity.AccountId";
import OPP_ProductType_FIELD from "@salesforce/schema/Opportunity.Product_Type__c";
import OPP_USERROLE_FIELD from "@salesforce/schema/Opportunity.Owner.UserRole.Name";
import PassengerVehicles from '@salesforce/label/c.PassengerVehicles';
import TwoWheeler from '@salesforce/label/c.TwoWheeler';
import OpportunityLabel from '@salesforce/label/c.Opportunity';
import createCase from '@salesforce/apex/OffRollEmpApproval.createCase';
let fields = [ID_FIELD, OpportunityID_FIELD, AccountID_FIELD, ProductType_FIELD, OWNER_FIELD, USERROLE_FIELD];
let fieldsOpp = [OPPID_FIELD, OPP_AccountID_FIELD, OPP_ProductType_FIELD, OPP_USERROLE_FIELD];

import { updateRecord, createRecord } from 'lightning/uiRecordApi';

import View_Application_Details from '@salesforce/label/c.View_Application_Details';
import Credit_Processing from '@salesforce/label/c.Credit_Processing';
import Lead_KYC_Details from '@salesforce/label/c.Lead_KYC_Details';
import { CurrentPageReference } from 'lightning/navigation';
import StageName from '@salesforce/schema/Opportunity.StageName';
import Sub_Stage from '@salesforce/schema/Opportunity.Sub_Stage__c';
import View_Application_Sub_Stage from '@salesforce/schema/Opportunity.View_Application_Sub_Stages__c';

export default class IND_FI_Assignment  extends NavigationMixin(LightningElement) {

    @api objectApiName;
    @api objectname;
    @api recordId;
    @track label = {
        Credit_Processing,
        View_Application_Details,
        Lead_KYC_Details
    };

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        console.log(' record id line 53 :',this.recordId );
        console.log(' currentPageReference line 53 :',currentPageReference );
        if (this.objectApiName !== OpportunityLabel && currentPageReference) {
            this.recordId = currentPageReference.attributes.recordId;
        }
    }
    
    @track empApp_Filter_Field = ['TeamMemberRole', 'AccountId'];
    @track isAppEnabled = false;
    @track empApp_Filter_term = [];
    @track accountId = '';
    @api productType;
    @track loanApplicationID = '';
    @track caseID = '';
    @track caseCurrentOwnerId = '';
    @track isAutomatedPV = false;
    @track userRole = '';
    @track accountTeamMemberRoleSearch = 'BE';
    connectedCallback() {
    
        console.log('Record id line no 71 :',this.recordId);
        console.log('objectApiName  :',this.objectApiName);

        getLoanApplicationDetails({
            recordId: this.recordId,
            objectName: this.objectApiName
        }).then(result => {
            this.accountId = result.accountId;
            this.ProductType = result.ProductType;
            this.userRole = result.userRole;
            this.loanApplicationID = result.loanApplicationId;
            this.caseID = result.caseId;
            this.caseCurrentOwnerId = result.caseCurrentOwnerId;
            if (this.objectApiName == OpportunityLabel) {
                this.isAppEnabled = true; //true
                this.accountTeamMemberRoleSearch = 'BE';
                this.empApp_Filter_term = ['BE', this.accountId];
                this.isAutomatedPV = true;
            } else if (this.ProductType == PassengerVehicles && this.userRole == 'BE') {
                this.accountTeamMemberRoleSearch = 'BE';
                this.empApp_Filter_term = ['BE', this.accountId];
            }
            if (this.ProductType == TwoWheeler) {
                this.accountTeamMemberRoleSearch = 'FI';
                this.empApp_Filter_term = ['FI', this.accountId];
            }
        }).catch(error => {
            console.log('error : ', error);
        });
    }

   

    @track geoStatemasterObject = GEO_STATE_MASTER_OBJECT.objectApiName;
    @track stateName = STATE_NAME.fieldApiName;
    @track stateId;
    @track state;
    state_Filter_Field = [];
    state_fetch_Field = [STATE_NAME.fieldApiName];

    blcode_Fetch_Field = ['Type', 'State__c', 'Name'];
    blcode_Search_Field = 'Name';
    blcode_Filter_Field = 'State__c';
    blcode_Filter_term;

    emp_Fetch_Field = ['TeamMemberRole', 'UserId', 'User.Name', 'User.EmployeeNumber'];
    emp_Search_Field = 'User.Name';
    emp_Filter_Field = ['AccountId', 'TeamMemberRole'];
    emp_Filter_term = [];

    empCode_Search_Field = 'User.EmployeeNumber';

    @track selectedEmpName;
    @track selectedEmCode;
    @track selectedAppEmpName;
    @track selectedAppEmCode;
    @track serachEmpCode = true;
    @track serachEmpName = true;

    @track caseOwnerId = '';
    @track loanAppOwnerId = '';

    @track blOptionEnabled = true;
    @track empOptionEnabled = true;
    @track empCodeOptionEnabled = true;

    @track webAppCodeOptionEnabled = false;
    @track webAppNameOptionEnabled = false;

    selectedStateHandler(event) {
        this.stateId = event.detail.selectedValueId;
        this.state = event.detail.selectedValueName;
        this.blcode_Filter_term = this.state?.replaceAll(' ','');
        this.blOptionEnabled = false;
        this.empOptionEnabled = true;
        this.empCodeOptionEnabled = true;
        this.resetValues();
    }

    clearStateHandler(event) {
        this.resetValues();
        this.blOptionEnabled = true;
        this.empOptionEnabled = true;
        this.empCodeOptionEnabled = true;
        this.stateId = event.detail.selectedValueId;
        this.state = event.detail.selectedValueName;
        this.BlcodeAccountId = '';
        this.BlCodeValue = '';
    }

    resetValues() {
        this.caseOwnerId = '';
        this.selectedEmCode = '';
        this.selectedEmpName = '';
    }

    selectedBlCodeHandler(event) {
        console.log('selectedBlCodeHandler : ');
        this.BlcodeAccountId = event.detail.selectedValueId;
        this.BlCodeValue = event.detail.selectedValueName;
        this.emp_Filter_term = [this.BlcodeAccountId, this.accountTeamMemberRoleSearch];
        this.empOptionEnabled = false;
        this.empCodeOptionEnabled = false;
        this.resetValues();
    }

    clearBlCodeHandler(event) {
        this.resetValues();
        this.empOptionEnabled = true;
        this.empCodeOptionEnabled = true;
        this.BlcodeAccountId = event.detail.selectedValueId;
        this.BlCodeValue = event.detail.selectedValueName;
    }

    selectedEmpHandler(event) {
        this.caseOwnerId = event.detail.selectedValueId;
        this.selectedEmpName = event.detail.selectedValueName;
        this.selectedEmCode = event.detail.selectedEmpCode;
        this.serachEmpCode = false;
        this.empCodeOptionEnabled = true;
    }
    clearEmpHandler(event) {
        this.resetValues();
        this.caseOwnerId = event.detail.selectedValueId;
        this.selectedEmpName = event.detail.selectedValueName;
        this.empOptionEnabled = false;
        this.serachEmpCode = true;
        this.empCodeOptionEnabled = false;
    }
    selectedEmpCodeHandler(event) {
        this.caseOwnerId = event.detail.selectedValueId;
        this.selectedEmpName = event.detail.selectedValueName;
        this.selectedEmCode = event.detail.selectedEmpCode;
        this.serachEmpName = false;
        this.empOptionEnabled = true;
    }

    clearEmpCodeHandler(event) {
        this.resetValues();
        this.loanAppOwnerId = event.detail.selectedValueId;
        this.selectedAppEmpName = event.detail.selectedValueName;
        this.empOptionEnabled = false;
        this.serachEmpName = true;
        this.empCodeOptionEnabled = false;
    }

    selectedEmpAppHandler(event) {
        this.loanAppOwnerId = event.detail.selectedValueId;
        this.caseOwnerId = event.detail.selectedValueId;
        this.selectedAppEmpName = event.detail.selectedValueName;
        this.webAppCodeOptionEnabled = true;
    }

    selectedEmpCodeAppHandler(event) {
        this.loanAppOwnerId = event.detail.selectedValueId;
        this.selectedAppEmCode = event.detail.selectedValueName;
        this.webAppNameOptionEnabled = true;
    }

    clearEmpAppHandler(event) {
        this.loanAppOwnerId = '';
        this.loanAppOwnerId = event.detail.selectedValueId;
        this.selectedAppEmpName = event.detail.selectedValueName;
        this.webAppCodeOptionEnabled = false;
    }

    clearEmpCodeAppHandler(event) {
        this.loanAppOwnerId = '';
        this.loanAppOwnerId = event.detail.selectedValueId;
        this.selectedAppEmCode = event.detail.selectedValueName;
        this.webAppNameOptionEnabled = false;
    }


    async UpdateData() {

        // if (this.caseOwnerId == '') {
        //     const evt = new ShowToastEvent({
        //         title: 'Toast Error',
        //         message: 'Please select employee for case owner',
        //         variant: 'error',
        //         mode: 'dismissable'
        //     });
        //     this.dispatchEvent(evt);
        // } else 
        if (this.loanAppOwnerId == '' && this.isAutomatedPV) {
            const evt = new ShowToastEvent({
                title: 'Toast Error',
                message: 'Please select employee for application owner',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
        else {
            await createCase({ loanId: this.recordId, productType: this.ProductType,laownerId: this.loanAppOwnerId })
                .then(result => {
                    console.log(result);
                    if (result != 'not entered') {
                        const event = new ShowToastEvent({
                            title: 'SUCCESS',
                            message: 'Case created successfully.',
                            variant: 'SUCCESS'

                        });
                        this.dispatchEvent(event);
                    }                    
                })
                .catch(error => {
                    console.log('Error ', error);
                });

            assignmentFIApp({
                recordIdCase: this.caseID,
                recordIDOpportunity: this.loanApplicationID,
                //caseOwnerId:this.caseOwnerId,
                caseOwnerId: this.caseOwnerId,
                loanOwnerId: this.loanAppOwnerId,
                isAutomatedPV: this.isAutomatedPV,
                BlcodeAccountId:this.BlcodeAccountId
            })
                .then(() => {
                    const evt = new ShowToastEvent({
                        title: 'Success',
                        message: 'Application has been assigned to new user.',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);

                    /* const oppFields = {};
                    oppFields[OPPID_FIELD.fieldApiName] = this.recordId;
                    oppFields[StageName.fieldApiName] = this.label.Credit_Processing;
                    oppFields[Sub_Stage.fieldApiName] = this.label.View_Application_Details
                    oppFields[View_Application_Sub_Stage.fieldApiName] = this.label.Lead_KYC_Details;
                    this.updateRecordDetails(oppFields); */

                    //eval("$A.get('e.force:refreshView').fire();");

                    this.navigateToHomePage();
                })
                .catch((error) => {
                    console.log(error);
                });

        }
    }

    async updateRecordDetails(fields) {
        const recordInput = { fields };
        await updateRecord(recordInput)
            .then(() => {
                console.log('record update success', JSON.stringify(fields));//keeping for reference
            })
            .catch(error => {
                console.log('error in record update =>', error)
            });
    }
    navigateToHomePage() {
        isCommunity()
        .then(response => {
            if(response){
                this[NavigationMixin.Navigate]({
                    type: 'standard__namedPage',
                    attributes: {
                        pageName: 'home'
                    }, });
                }else{
                    this[NavigationMixin.Navigate]({
                        type: 'standard__navItemPage',
                        attributes: {
                        apiName: 'Home'
                        } }); 
                    }
        })  
        .catch(error => {          
        });   
       
    }
}