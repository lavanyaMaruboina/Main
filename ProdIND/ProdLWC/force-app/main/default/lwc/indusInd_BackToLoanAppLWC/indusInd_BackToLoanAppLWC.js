import { LightningElement, api, wire, track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import document_Types from '@salesforce/schema/Documents__c.Document_Type__c';
import rejection_Fields from '@salesforce/schema/Documents__c.Rejection_Fields__c';
import opportunity_Relations from '@salesforce/schema/Documents__c.Opportunity_Relation__c';
const field = [document_Types,rejection_Fields,opportunity_Relations];
import getMetadata from '@salesforce/apex/BackToLoanAppLWC.getMetadata';
export default class IndusInd_BackToLoanAppLWC extends NavigationMixin(LightningElement) {
    
    //
    @track record;
    @track error;
    rejectionField;
    documentType;
    flagForRejection = false;
    response='';
    results = false;
    opportunityRelation
    @api recordId;
    @wire(getRecord, {recordId:'$recordId',fields : field})
    document;

    @api async invoke() {
       //fetch the value of 3 fields 
        this.rejectionField = getFieldValue(this.document.data, rejection_Fields);
        this.documentType = getFieldValue(this.document.data, document_Types);
        this.opportunityRelation = getFieldValue(this.document.data, opportunity_Relations);
        if(this.rejectionField == null){
           
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.opportunityRelation,
                    objectApiName: 'Opportunity',
                    actionName: 'view'
                }
            });
            
        }
        else{

            let splitString = [];
            let metadataAadhar = [];
            let metadatavoter = [];
            let metadataPan = [];
            let metadataDl = [];
            let metadatapassport = [];
            getMetadata({documentType : this.documentType})
            .then(result =>{
                
                if(this.documentType === 'Aadhaar')
                {
                    metadataAadhar = result.split(';');

                    
                }
                else if(this.documentType === 'Driving Licence')
                {
                    metadataDl = result.split(';');
                  
                }
                else if(this.documentType === 'Passport')
                    {
                        metadatapassport = result.split(';');
                        
                    }
                    else if(this.documentType === 'PAN')
                    {
                     
                        metadataPan = result.split(';');
                      
                    }
                    else{ metadatavoter = result.split(';');
                    }              
                  
                splitString=this.rejectionField.split(';');
                for (let i = 0; i < splitString.length; i++)
                {
                    
                    if(this.documentType === 'Aadhaar')
                    {
                        
                        this.results = metadataAadhar.includes(splitString[i]);
                        if(this.results === true)
                        {
                            this.flagForRejection = true;
                        }
                        
                        
    
                    }
                    else if(this.documentType === 'Driving Licence')
                    {
                        this.results = metadataDl.includes(splitString[i]);
                        if(this.results === true)
                        {
                            this.flagForRejection = true;
                        }
                    }
                    else if(this.documentType === 'Passport')
                    {
                        this.results = metadatapassport.includes(splitString[i]);
                        if(this.results === true)
                        {
                            this.flagForRejection = true;
                        }
                    }
                    else if(this.documentType === 'PAN')
                    {
                        
                        this.results = metadataPan.includes(splitString[i]);
                        
                        if(this.results === true)
                        {
                            this.flagForRejection = true;
                        }
                    }
                    else{ 
                        this.results = metadatavoter.includes(splitString[i]);
                        if(this.results === true)
                        {
                            this.flagForRejection = true;
                        }
                    }              
                }  
                    if(this.flagForRejection === true)
                    {
                        const evt = new ShowToastEvent({
                            title: 'Error',
                            message: 'Please Click on Restart Journey Button or please change the rejection fields.',
                            variant: 'error',
                            duration:' 5000',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(evt);
                    }
                    else{
                        
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: this.opportunityRelation,
                                objectApiName: 'Opportunity',
                                actionName: 'view'
                            }
                        });
            }
        })
            .error(error =>{
                this.error = error;
            });
        
           
            }
            
        }


    }