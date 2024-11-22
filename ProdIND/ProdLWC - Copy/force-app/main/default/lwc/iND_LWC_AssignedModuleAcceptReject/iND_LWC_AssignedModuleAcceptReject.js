import { LightningElement,api ,track, wire} from 'lwc';
// import getAllModules from '@salesforce/apex/IND_LWC_LeadAssignmentCtrl.getAllModules';
// import assignModules from '@salesforce/apex/IND_LWC_LeadAssignmentCtrl.assignModules';
//import getModules from '@salesforce/apex/IND_LWC_LeadAssignmentCtrl.getModules'
//import getFieldsforScreen from '@salesforce/apex/IND_LWC_LeadAssignmentCtrl.getFieldsforScreen';
//import assignedModuleCompleted from '@salesforce/apex/IND_LWC_LeadAssignmentCtrl.assignedModuleCompleted'
//import assignedUserCheck from '@salesforce/apex/IND_LWC_LeadAssignmentCtrl.assignedUserCheck';
//import removeModuleAssignment from '@salesforce/apex/IND_LWC_LeadAssignmentCtrl.removeModuleAssignment'
import { getRecord,getRecordNotifyChange } from "lightning/uiRecordApi";
import ASSIGNED_MODULE__C from '@salesforce/schema/Opportunity.Assigned_Module__c';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Id from '@salesforce/user/Id';


const FIELDS = [ASSIGNED_MODULE__C];

export default class IND_LWC_AssignedModuleAcceptReject extends LightningElement {
    //Attribute to hold the value of current logged in user id.
    currentUserId = Id; 
    //Attribute to store the value Object API Name 
    objectApiName = '';

    showPrevious = false;
    showNext = false;
    showSubmit = false;

    //Attribute to store the value of current Record Id.
    @api recordId ;

    //Attribute to store the label of button which is clicked from the UI.
    clickedButton = '';

    //Attribute to show/hide the popup.
    isPopupOpen = false;

    //To show/hide the wizard.
    leadAssignmentWizard = false;

    //Attribute to store the value of assigned module.
    assignedModule = '';

    isPopupShown = false;

    //This function will fetch the name of assigned module.
    @wire(getRecord, {recordId: '$recordId',fields: FIELDS})
    wireResult({error,data}) {
        if (error) {
            this.error = error ;
        } 
        else if (data) {
            if(typeof data.id !== 'undefined'){
                this.assignedModule = data.fields.Assigned_Module__c.value;
                if(this.assignedModule && this.isPopupShown === false){
                 /*    assignedUserCheck({oppId : this.recordId,currentUserId : this.currentUserId,assignedModule:this.assignedModule})
                    .then((result) => {
                        if(result){
                            console.log('result:', result);
                            this.isPopupOpen = true;
                        }
                    })
                    .catch((error) => {
                        console.log('error:', error);
                    }); */
                    //not to show popup again.
                    this.isPopupShown = true;   
                }               
            }
        }
    }

    subModuleName = '';
    @track subModuleList = [];
    @track fieldsList = [];
    @track mandatoryFieldsList = [];
    index = 0;
    
    //Handler for accept button of popup.
    handleYes(event){
        this.isPopupOpen = false;
        //Fetching the list of submodules from apex controller.
       /*  getModules({moduleName : this.assignedModule})
        .then((result) => {
            if(result.length > 0){
                this.leadAssignmentWizard = true;
                this.showNext = true;
                this.subModuleList = result;  
                this.subModuleName = this.subModuleList[this.index].Sub_Module_Name__c;

                this.error = undefined;

                getFieldsforScreen({moduleName : this.assignedModule , subModuleName : this.subModuleName ,screenType: FORM_FACTOR})
                .then((fieldsWrapper) => {
                    // console.log('field list',fieldsWrapper);
                    this.fieldsList =  fieldsWrapper.fieldNames;
                    this.objectApiName = fieldsWrapper.objectName;
                })
                .catch((error)=>{
                    this.error = error;
                    console.log('error ->',error);
                });   
            }        
        })
        .catch((error) => {
            this.error = error;
            this.subModuleList = undefined;
            console.log('error', error);
        }); */
    }
    
    //Handler for reject button onclick event.
    handleNo(event){
        this.isPopupOpen = false;
       /*  removeModuleAssignment({oppId : this.recordId})
        .then((result) => {
            if(result){
                const evt = new ShowToastEvent({
                    title: 'Deleted',
                    message: 'OTM is deleted',
                    variant : 'success',
                    });
                this.dispatchEvent(evt);
            }
        })
        .catch((error) => {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Some problem is occurred' + error,
                variant : 'error',
            });
            this.dispatchEvent(evt);
        }); */

        getRecordNotifyChange([{recordId: this.recordId}]);
    }


    proceedNext = false;
    handleNext(event){
        event.preventDefault(); 
        console.log('this.isPopupOpen:', this.isPopupOpen);
        this.proceedNext = true;
        //fetching the fields of record-edit-form.
        const inputfields = event.detail.fields;
        const fields = this.template.querySelectorAll('lightning-input-field');
        // console.log('fields:', fields[0].required,fields[0].value);
        fields.forEach(function(field){
            //console.log('inside for each',field.required,field.value);
            if(field.required === true && (field.value == null || field.value == undefined)){
                this.proceedNext = false;
            }
        });

        if(this.proceedNext == true){
           // console.log('next function called'); 
            //Submitting the form.
            this.template.querySelector('lightning-record-edit-form').submit(inputfields);

            if(this.index + 1 < this.subModuleList.length ){
                this.showPrevious = true;
                this.index += 1;
                this.subModuleName = this.subModuleList[this.index].Sub_Module_Name__c;
               /*  getFieldsforScreen({moduleName : this.assignedModule , subModuleName : this.subModuleName ,screenType: FORM_FACTOR})
                .then((fieldsWrapper) => {
                    //console.log('field list',fieldsWrapper);
                    this.fieldsList =  fieldsWrapper.fieldNames;
                    this.objectApiName = fieldsWrapper.objectName;
                })
                .catch((error)=>{
                    this.error = error;
                    console.log('error ->',error);
                });   */ 
            }
            if(this.index + 1 == this.subModuleList.length){
                this.showNext = false;
                this.showSubmit = true;
            }
        }
    }

    handlePrevious(){
        if(this.index > 0){
            this.index -= 1;
            if(this.index < this.subModuleList.length){
                this.showSubmit = false;
                this.showNext = true;
            }
            if(this.index == 0){
                this.showPrevious = false;
            }
            this.subModuleName = this.subModuleList[this.index].Sub_Module_Name__c;
           /*  getFieldsforScreen({moduleName : this.assignedModule , subModuleName : this.subModuleName ,screenType: FORM_FACTOR})
            .then((fieldsWrapper) => {
                //console.log('field list',fieldsWrapper);
                this.fieldsList =  fieldsWrapper.fieldNames;
                this.objectApiName = fieldsWrapper.objectName;
            })
            .catch((error)=>{
                this.error = error;
                console.log('error ->',error);
            });    */
        }
    }


    proceedSubmit = false;
    handleSubmit(event){
       event.preventDefault(); 
        this.proceedSubmit = true;
        //fetching the fields of record-edit-form.
        const inputfields = event.detail.fields;
        const fields = this.template.querySelectorAll('lightning-input-field');
        // console.log('fields:', fields[0].required,fields[0].value);
        fields.forEach(function(field){
            //console.log('inside for each',field.required,field.value);
            if(field.required === true && (field.value == null || field.value == undefined)){
                this.proceedSubmit = false;
            }
        }); 
        if(this.proceedSubmit == true){
           // console.log('submit function called'); 
            //Submitting the form.
            this.template.querySelector('lightning-record-edit-form').submit(inputfields);
            
       /*      assignedModuleCompleted({oppId : this.recordId ,currentUserId : this.currentUserId,assignedModule:this.assignedModule})
            .then((result) => {
                if(result){
                    const evt = new ShowToastEvent({
                        title: 'Completed',
                        message: 'Thanks for completing the task',
                        variant : 'success',
                        });
                    this.dispatchEvent(evt);
                    this.leadAssignmentWizard = false;
                }
            })
            .catch((error) => {
                const evt = new ShowToastEvent({
                        title: 'Error',
                        message: error,
                        variant : 'error',
                        });
                    this.dispatchEvent(evt);
            }); */

            //const evt = new ShowToastEvent({
            //     title: 'Completed',
            //     message: 'Thanks for completing the task',
            //     variant : 'success',
            // });
            // this.dispatchEvent(evt);
        }
    }
}