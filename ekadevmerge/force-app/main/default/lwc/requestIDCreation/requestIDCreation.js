import Insertregistarionid from "@salesforce/apex/FileUploaderClass.Insertregistarionid";
import getCurrentLead from '@salesforce/apex/FileUploaderClass.getCurrentLead';
import leadRecordName from "@salesforce/apex/FileUploaderClass.methodName1";
import REQUEST_ID from "@salesforce/schema/Request_For_ID__c";
import clinicAddress from "@salesforce/schema/Request_For_ID__c.Clinic_Address2__c";
import clinicFEES from "@salesforce/schema/Request_For_ID__c.Clinic_Consultation_Fees__c";
import clinicname from "@salesforce/schema/Request_For_ID__c.Clinic_Name__c";
import emailId from "@salesforce/schema/Request_For_ID__c.Email_ID__c";
import medicalcouName from "@salesforce/schema/Request_For_ID__c.Medical_council_Name__c";
import onboardingdate from "@salesforce/schema/Request_For_ID__c.Onboarding_Date__c";
import onboardtype from "@salesforce/schema/Request_For_ID__c.Onboarding_Type__c";
import qualification from "@salesforce/schema/Request_For_ID__c.Qualification__c";
import registrationNumber from "@salesforce/schema/Request_For_ID__c.Registration_Number__c";
import yearofGraduation from "@salesforce/schema/Request_For_ID__c.Year_of_graduation__c";
import yearofexperience from "@salesforce/schema/Request_For_ID__c.Years_of_Experience__c";
import { NavigationMixin } from 'lightning/navigation';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningElement, api, track, wire } from 'lwc';

export default class RequestIDCreation extends NavigationMixin(LightningElement) {
    @api recordId;
    @track selectedValue = ''; // To store the selected value
    @track medicalSelectedValue='';
    // @track addresspicklistValue='';
    @track dropdownOptions = [
        { label: 'New', value: 'New' },
        { label: 'Old', value: 'Old' },
    ];

    @track medicaldropdownOptions = [
        { label: 'Andhra pradesh medical council', value: 'Andhra pradesh medical council'},
        { label: 'Arunachal pradesh medical council', value: 'Arunachal pradesh medical council'},
        { label: 'Assam medical council', value: 'Assam medical council'},
        { label: 'Bhopal medical council', value: 'Bhopal medical council'},
        { label: 'Bihar medical council', value: 'Bihar medical council'},
        { label: 'Bombay medical council', value: 'Bombay medical council'},
        { label: 'Chandigarh medical council', value: 'Chandigarh medical council'},
        { label: 'Chattisgarh medical council', value: 'Chattisgarh medical council'},
        { label: 'Delhi medical council', value: 'Delhi medical council'},
        { label: 'Goa medical council', value: 'Goa medical council'},
        { label: 'Gujarat medical council', value: 'Gujarat medical council'},
        { label: 'Haryana medical councils', value: 'Haryana medical councils'},
        { label: 'Himachal pradesh medical council', value: 'Himachal pradesh medical council'},
        { label: 'Hyderabad medical council', value: 'Hyderabad medical council'},
        { label: 'Jammu & kashmir medical council', value: 'Jammu & kashmir medical council'},
        { label: 'Jharkhand medical council', value: 'Jharkhand medical council'},
        { label: 'Karnataka medical council', value: 'Karnataka medical council'},
        { label: 'Madhya pradesh medical council', value: 'Madhya pradesh medical council'},
        { label: 'Madras medical council', value: 'Madras medical council'},
        { label: 'Mahakoshal medical council', value: 'Mahakoshal medical council'},
        { label: 'Maharashtra medical council', value: 'Maharashtra medical council'},
        { label: 'Manipur medical council', value: 'Manipur medical council'},
        { label: 'Medical council of india', value: 'Medical council of india'},
        { label: 'Medical council of tanganyika', value: 'Medical council of tanganyika'},
        { label: 'Mizoram medical council', value: 'Mizoram medical council'},
        { label: 'Mysore medical council', value: 'Mysore medical council'},
        { label: 'Nagaland medical council', value: 'Nagaland medical council'},
        { label: 'Orissa council of medical registration', value: 'Orissa council of medical registration'},
        { label: 'Pondicherry medical council', value: 'Pondicherry medical council'},
        { label: 'Punjab medical council', value: 'Punjab medical council'},
        { label: 'Rajasthan medical council', value: 'Rajasthan medical council'},
        { label: 'Sikkim medical council', value: 'Sikkim medical council'},
        { label: 'Tamil nadu medical council', value: 'Tamil nadu medical council'},
        { label: 'Telangana state medical council', value: 'Telangana state medical council'},
        { label: 'Travancore cochin medical council, trivandrum', value: 'Travancore cochin medical council, trivandrum'},
        { label: 'Tripura state medical council', value: 'Tripura state medical council'},
        { label: 'Uttar pradesh medical council', value: 'Uttar pradesh medical council'},
        { label: 'Uttarakhand medical council', value: 'Uttarakhand medical council'},
        { label: 'Vidharba medical council', value: 'Vidharba medical council'},
        { label: 'West bengal medical council', value: 'West bengal medical council'},
    ];
   
    @track showForm = false;
    @track verificationCertificate=false;
    fileData
    fileData1
    @api leadname;
    @api leadRecordTypeName;
    @track isDuplicate = false;
    @track email;
    @track clinicName;
    objectRecordId;
    @api myRecordId;


    @api strStreet;
    @api strCity;
    @api strState;
    @api strCountry='IN';
    @api strPostalCode;
    @api objectAPIName;
    @track filedataview = false;
    @track requestIDdataview =true;
   
    objectName=REQUEST_ID;
    onboardingType=onboardtype;

    onboardingDate=onboardingdate;
    email= emailId;
    regiNumber=registrationNumber;
    qualifi=qualification;
    garduation=yearofGraduation;
    yearofExp=yearofexperience;
    clinicadress=clinicAddress;
    clinicName=clinicname;
    consultationFees=clinicFEES;
    medicalcouncilName=medicalcouName;
    @track clinicName;
    
    @wire(getCurrentLead, { leadId: '$recordId' })
    wiredLead({ error, data }) {
        if (data) {
            this.email = data.Email;
            this.clinicName = data.Company;
        } else if (error) {
            console.error('Error fetching lead data:', error);
        }
    }

    @wire(leadRecordName,{recordid:"$recordId"})
    record({data,error}) {
        if(data){
            this.leadRecordTypeName=data.RecordType.Name;
            console.log('lavanya=============================Record name',this.recordId);
            console.log('lavanya=============================Record name',data);
        } 
    }
    @track rec={

    };

    handleDropdownChange(event) {
        // Update the selectedValue when the dropdown selection changes
        this.selectedValue = event.detail.value;
        
      
    }
    handlemedicaldropdownOptions(event){

        this.rec.medicalSelectedValue = event.detail.value; 
        console.log('lavanya78965555555>>>>>>>>>>>>>>>>>>>>>>',this.rec.medicalSelectedValue);
    }
    registrationId(event) {
        let { name, value } = event.target;
    
        if (name === "onboardtype") this.rec.Onboarding_Type__c = value;
        if (name === "onboarddate") this.rec.Onboarding_Date__c = value;
        if (name === "email") this.rec.Email_ID__c = value;
        if (name === "regNum") this.rec.Registration_Number__c = value;
        if (name === "qualifi") this.rec.Qualification__c = value;
        if (name === "yearofgraduate") this.rec.Year_of_graduation__c = value;
        if (name === "yearofexp") this.rec.Years_of_Experience__c = value;
        if (name === "cosultationfee") this.rec.Clinic_Consultation_Fees__c = value;
        if (name === "clinicName") this.rec.Clinic_Name__c = value;
        if (name === "councilname") this.rec.Medical_council_Name__c = value;
        if (name === "clinicadress") this.rec.Clinic_Address2__c = value; // Update for address field
    }

    saveHandler(event) {
        if (this.isInputValid()) {
            let fields = event.detail.fields;
            Insertregistarionid({
                request: this.rec,
                Leadid: this.recordId,
                leadRecod: this.recordId,
                leadRecodName: this.leadRecordTypeName
            })
            .then((data) => {
            
                    this.showToast("Success", "Request ID Created Successfully", "success");
                    console.log("the returned record d>>",data);
                    this.requestIDdataview = false;
                    this.filedataview = true;
                    this.objectRecordId=data;
                    console.log('recordIdLavanya  ',this.objectRecordId);

            })
            .catch((error) => {
                console.error(error);
                this.showToast("Error", "Error", "Error");
            });
        }
    }
   
     cancelHandler(event){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName:this.objectName,
                actionName:'view'
            }
        })
    }

     
    get acceptedFormats() {
        return ['.xlsx', '.xls', '.csv', '.png', '.doc', '.docx', '.pdf', '.jpg'];
    }
      
    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;

        uploadedFiles.forEach(file => {
            if (file.name === 'fileData') {
                this.fileData = file;
            } else if (file.name === 'fileData1') {
                this.fileData1 = file;
            }
        });

        if (this.fileData && this.fileData1) {
            this.uploadFilesAndAssociate();
        } else {
            this.showToast('Error', 'Please upload both files', 'error');
        }
    }

    handleUploadFinished(event) { 
        const uploadedFiles = event.detail.files;
        console.log('No. of files uploaded : ' + uploadedFiles.length);

    }

      showToast(customtitle, custommessage, customvariant) {
            const event = new ShowToastEvent({
              title: customtitle,
              message: custommessage,
              variant: customvariant
            });
            this.dispatchEvent(event);
          }
        isInputValid() {
            let isValid = true;
            let inputFields = this.template.querySelectorAll('.validate');
        
            let errorMessage = "Please fill in all the required fields.";
        
            inputFields.forEach(inputField => {
                if (!inputField.checkValidity()) {
                    isValid = false;
                }
        
                if (!inputField.value && inputField.required) {
                    isValid = false;
                    // Concatenate error messages for all empty required fields
                    errorMessage += `\n${inputField.label} is mandatory.`;
                }
        
                this.rec[inputField.name] = inputField.value;
            });
        
            if (!isValid) {
                // Show a single error toast for all empty required fields
                this.showToast("Error", errorMessage, "error");
            }
        
            return isValid;
        }

}
