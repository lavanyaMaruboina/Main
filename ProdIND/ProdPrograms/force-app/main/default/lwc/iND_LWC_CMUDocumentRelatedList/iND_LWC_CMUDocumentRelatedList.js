import { LightningElement,api,wire,track } from 'lwc';
import cmuDocumentRelatedList from '@salesforce/apex/LwcCmuApplicationCntrl.cmuDocumentRelatedList'


export default class IND_LWC_CMUDocumentRelatedList extends LightningElement {
    //Attribute to hold the data that will come from backend.
    @track documents;
    //Attribute to hold the errors if any comes.
    @track error;
    @api recordId; 

    //Column whose data will be shown on UI.
    @track columns = [
        {label: 'Document Name',fieldName: 'documentNameLink',type: 'url',typeAttributes: {label: { fieldName: 'documentName' }, target: '_blank'}},
        { label: 'Document Type', fieldName: 'Document_Type__c' ,type : 'text'},
        { label: 'Applicant Name', fieldName: 'applicantName',type :'text'},
        { label: 'Applicant Type', fieldName: 'applicantType',type :'text'},
        { label: 'Document Side', fieldName: 'Document_Side__c',type :'text'},
        { label: 'Is This photocopy', fieldName: 'Is_this_a_Photocopy__c',type :'text'},
        { label: 'POA', fieldName: 'Proof_of_Address_POA__c',type :'text'},
        { label: 'POI', fieldName: 'Proof_of_Identity_POI__c',type :'text'}
    ];

    //Calling the apex method using.
    @wire(cmuDocumentRelatedList,{ loanApplicationId: '$recordId' }) 
    wiredDocument( { error, data } ) {
        //Url for Documents__c record.
        let documentBaseUrl = 'https://indusindbank123--psldev1.lightning.force.com/lightning/r/Documents__c/';
        
        //Setting the data and managing the applicant fields and also creating the hyperlink for Document Name.
        if ( data ) {
            let tempRecords = JSON.parse( JSON.stringify( data ) );
            tempRecords = tempRecords.map( row => {
                return { ...row, documentName : row.Name, documentNameLink: documentBaseUrl+row.Id+'/view' , applicantName: row.Applicant__r.Name, applicantType : row.Applicant__r.Applicant_Type__c };
            })
            this.documents = tempRecords;
            this.error = undefined;

        } else if ( error ) {
            this.error = error;
            this.documents = undefined;
        }
    } 
    //End of wired function.  
}