import { LightningElement, api, wire,track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getIncomeDetails from '@salesforce/apex/ind_ApplicationFormSigningController.getIncomeDetails';
import getloanappid from '@salesforce/apex/ind_ApplicationFormSigningController.getloanappid';
import getInsurenDetails from '@salesforce/apex/ind_ApplicationFormSigningController.getInsurenDetails';
import getKYCDetails from '@salesforce/apex/ind_ApplicationFormSigningController.getKYCDetails';
import getFinalTerm from '@salesforce/apex/ind_ApplicationFormSigningController.getFinalTerm';
import getInsurenceDetails from '@salesforce/apex/ind_ApplicationFormSigningController.getInsurenceDetails';
import getvehicle from '@salesforce/apex/ind_ApplicationFormSigningController.getvehicle';
//import enableCheckbox from '@salesforce/apexContinuation/IND_InsuranceConsentOTP.enableCheckbox';
import getProductType from '@salesforce/apex/ind_ApplicationFormSigningController.getProductType';
import getApplicentDocuments from '@salesforce/apex/ind_ApplicationFormSigningController.getApplicentDocuments';
import DisplayCustomerImage from '@salesforce/apex/ind_ApplicationFormSigningController.DisplayCustomerImage';
//import downloadjs from '@salesforce/resourceUrl/downloadjs';
//import downloadPDF from '@salesforce/apex/renderasPdfcontroller.renderasPdfcontroller';

export default class Ind_Lwc_ApplicationFormSigning extends LightningElement {
    @api recordId; 
    @api name;
    @api showUpload;
    @api showDocView;
    @api isVehicleDoc;
    @api isAllDocType;
    @track uploadViewDocFlag = false;
    @track isTwoWheeler = false;
    @track isPassengerVehicle = false;
    @track Doculist = [];
    @track imageUrl;
    boolShowSpinner = false;
    pdfString;

    handleViewDoc() {
        this.showUpload = true;
        this.showDocView = true;
        this.isVehicleDoc = false;
        this.isAllDocType = true;
        this.uploadViewDocFlag = true;
    }
    connectedCallback(){
        console.log('name '+this.name+'id '+this.recordId)
        getProductType({ appId: this.recordId})
        .then(result=>{
           // alert('result is'+result);
            if(result.toLowerCase()  === 'Two Wheeler'.toLowerCase()){

                this.isTwoWheeler = true;
            }if(result.toLowerCase()  === 'Passenger Vehicles'.toLowerCase() ){
               
                this.isPassengerVehicle = true;
            }
        })
        .catch(error=>{
            console.log('error is'+error);
        });
        getApplicentDocuments({ appId: this.recordId})
        .then(result=>{
             // alert('result is'+ JSON.stringify(result)); 
              this.Doculist = result; 
        })
        .catch(error=>{
            console.log('error is'+error);
        });

        DisplayCustomerImage({ appId: this.recordId })
               .then(result=>{
                    alert('id is AD '+ JSON.stringify(result));
                    this.imageUrl  =  'ApplicationformSigning/sfc/servlet.shepherd/version/download/'+ result;
               })
               .catch(error=>{
                    alert('error 56'+JSON.stringify(error));
               });

    }

    @track DocuColumns = [
        { label: 'Document Type',
        fieldName: 'DocName',
        type: 'text'},
        {
            label: 'Borrower/Co Borrower',
            fieldName: 'Applicant_Type',
            type: 'text'  
        },
    ]

    @track columnsins = [{
        label: 'Insurance number',
        fieldName: 'Insurance_number__c',
        type: 'text'
        
    },
    
    {
        label: 'Insurance declared value ',
        fieldName: 'Insurance_declared_value__c',
        type: 'text'
      
    },
    {
        label: 'Insurer name ',
        fieldName: 'Insurer_name__c',
        type: 'text'
      
    },
    {
        label: 'Insurance type ',
        fieldName: 'Insurance_type__c',
        type: 'text'
      
    }
    ];

    @track columns = [{
        label: 'Legal Entity Identifier',
        fieldName: 'Legal__c',
        type: 'text'
       
    },
    {
        label: 'Income Source',
        fieldName: 'Income_Source__c',
        type: 'text'
      
    },
    {
        label: 'Name of Recipient Bank ',
        fieldName: 'Name_of_Recipient_Bank__c',
        type: 'text'
      
    },
    {
        label: 'Employer Business Name ',
        fieldName: 'Employer_Business_Name__c',
        type: 'text'
      
    },
    {
        label: 'Income Details Name ',
        fieldName: 'Name',
        type: 'text'
      
    },
    {
        label: 'Current Years in employment/business ',
        fieldName: 'Current_Years_in_employment_business__c',
        type: 'text'
      
    },
    ];
    @track kycColumns =[{
        label: 'KYC name',
        fieldName: 'KYC_name__c',
        type: 'text'
        
    },
    {
        label: 'Gender',
        fieldName: 'Gender__c',
        type: 'text'
      
    },
    {
        label: 'First Name',
        fieldName: 'First_Name__c',
        type: 'text'
      
    },
    {
        label: 'KYC No.',
        fieldName: 'KYC_No__c',
        type: 'text'
      
    }];

  @track finTercolumns=[{
    label: 'Offer engine EMI Amount',
    fieldName: 'EMI_Amount__c',
    type: 'text'
    
},
{
    label: 'Offer engine Loan Amount',
    fieldName: 'Loan_Amount__c',
    type: 'text'
  
},
{
    label: 'Offer engine CRM IRR',
    fieldName: 'CRM_IRR__c',
    type: 'text'
  
},
{
    label: 'Offer engine Tenure',
    fieldName: 'Tenure__c',
    type: 'text'
  
},
{
    label: 'Offer engine Required CRM IRR',
    fieldName: 'Required_CRM_IRR__c',
    type: 'text'
  
    }];

    @track Insurancecolumns=[{
        label: 'Amount',
        fieldName: 'Amount__c',
        type: 'text'
        
    },
    {
        label: 'Funded/Non funded ',
        fieldName: 'Funded_Non_funded__c',
        type: 'text'
      
    },
    {
        label: 'Insurance Plan',
        fieldName: 'Insurance_Plan__c',
        type: 'text'
      
    },
    {
        label: 'Product Type ',
        fieldName: 'Product_Type__c',
        type: 'text'
      
    }] 




    @track vehiclecolumns=[{
        label: 'Vehicle type',
        fieldName: 'Vehicle_type__c',
        type: 'text'
        
    },
    {
        label: 'Product',
        fieldName: 'Product__c',
        type: 'text'
      
    },
    {
        label: 'Make',
        fieldName: 'Make__c',
        type: 'text'
      
    },
    {
        label: 'Model',
        fieldName: 'Model__c',
        type: 'text'
      
    },
    {
        label: 'Variant',
        fieldName: 'Variant__c',
        type: 'text'
      
    }]

   

@track error;
@track inclist ;  
@track lonlist ;
@track inslist;
@track kyclist; 
@track finTerlist;
@track Insurancelist;
@track vehiclelist;
handleToggleSectionLonD(event){
    getloanappid({ appId: this.recordId})
    .then((result) => {
       console.log(result);
       this.lonlist = result;
     this.error = undefined;
    })
    .catch((error) => {
        alert('Error in Loan Details'+JSON.stringify(error));

        this.error = error;
         this.lonlist = undefined;
     });

}
handleToggleSectionInsur(event){
    getvehicle({appId: this.recordId})
    .then((result) => {
        console.log(result);
        this.inslist = result;
      this.error = undefined;
     })
     .catch((error) => {
         alert('error in Insurence Details'+JSON.stringify(error));
         this.error = error;
          this.inslist = undefined;
      });
}
handleToggleSectionKyc(event){

    getKYCDetails({ aplId: this.recordId})
        .then((result) => {
            console.log(result);
           this.kyclist = result;
          this.error = undefined;
        })
        .catch((error) => {
            alert('Error in Kyc'+JSON.stringify(error));
           this.error = error;
            this.kyclist = undefined;
        });

}
   
   handleToggleSection(event){

        getIncomeDetails ({ aplId: this.recordId})
            .then((result) => {
                console.log(result);
               this.inclist = result;
              this.error = undefined;
            })
            .catch((error) => {
                alert('Error in Income'+JSON.stringify(error));
               this.error = error;
                this.inclist = undefined;
            });

    }

    handleToggleSectionvehicle(event){
        getvehicle ({ appId: this.recordId})
        .then((result) => {
            console.log(result);
           this.vehiclelist = result;
          this.error = undefined;
        })
        .catch((error) => {
            alert('Error in Income'+JSON.stringify(error));
           this.error = error;
            this.vehiclelist = undefined;
        });

    }

   activeSections = ['leadDetails'];
    activeSectionsMessage = '';

   toggleSectionHandle(event) {
       const openSections = event.detail.openSections; 
        if (openSections.length === 0) {
            this.activeSectionsMessage = 'All sections are closed';
           
        } else {
            this.activeSectionsMessage =
                'Open sections: ' + openSections.join(', ');
        }
    } 
  
    handleToggleSectionFinalTerm(event) {
        getFinalTerm ({ appId: this.recordId})
        .then((result) => {
            console.log(result);
           this.finTerlist = result;
          this.error = undefined;
        })
        .catch((error) => {
            alert('Error in Income'+JSON.stringify(error));
           this.error = error;
            this.inclist = undefined;
        });
    }
    handleToggleSectionInsurance(event){

        getInsurenceDetails({ aplId: this.recordId})
            .then((result) => {
                console.log(result);
               this.Insurancelist = result;
              this.error = undefined;
            })
            .catch((error) => {
                alert('Error in Kyc'+JSON.stringify(error));
               this.error = error;
                this.Insurancelist = undefined;
            });
    
    }    

   // generatePdf(){
        /*this.boolShowSpinner = true;
        downloadPDF({}).then(response => {
            console.log(response);
            this.boolShowSpinner = false;
            var strFile = "data:application/pdf;base64,"+response;
            window.download(strFile, "sample.pdf", "application/pdf");

        }).catch(error => {
            console.log('Error: ' +error.body.message);
        });*/

      //  window.open('https://psldev1-acceptconsent.ind2s.sfdc-y37hzm.force.com/ApplicationformSigning');
    
    
   // }
    changeflagvalue(){
        
    }
}