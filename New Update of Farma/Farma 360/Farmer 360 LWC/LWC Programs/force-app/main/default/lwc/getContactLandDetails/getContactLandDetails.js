import { refreshApex } from '@salesforce/apex';
import createHarvest from '@salesforce/apex/AccountSearchController.createHarvest';
import getContactDetails from '@salesforce/apex/AccountSearchController.getContactDetails';
import getHarvestDetailsEqualtoLand from '@salesforce/apex/AccountSearchController.getHarvestDetailsEqualtoLand';
import createLand from '@salesforce/apex/LandDetailsController.createLand';
import getIrrigationTypePicklistValues from '@salesforce/apex/LandDetailsController.getIrrigationTypePicklistValues';
import saveHarvestDetails from '@salesforce/apex/LandDetailsController.saveHarvestDetails';
import getLandDetails from '@salesforce/apex/updateLandDetails.getLandDetails';
import updateLandDetailsMethod from '@salesforce/apex/updateLandDetails.updateLandDetailsMethod';
import Land_Object from '@salesforce/schema/Land_detals__c';
import Irrigation_Field from '@salesforce/schema/Land_detals__c.Irrigation_Type__c';
import Water_Field from '@salesforce/schema/Land_detals__c.Water_Source__c';
import LightningAlert from 'lightning/alert';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { LightningElement, api, track, wire } from 'lwc';

export default class GetContactLandDetails extends LightningElement {

    @track value;

    @wire(getObjectInfo, { objectApiName: Land_Object })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Water_Field})
    WaterPickListValues;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Irrigation_Field})
    IrrigationPickListValues;

    handleChange(event) {
        this.value = event.detail.value;
    }


    @track data;
    @track draftValues = [];
    @track harvestDraftValues = [];
    @track error;
    @track LandDetailsForm = false;
    @track landDatatable = true;
    @api contactId;
    @track landDetails;
    @track HarvestDetails;
    @track areaChange = '';
    @track tabsHandler = false;
    @track backVisible = false;
    @track harvestdata=[];
    @track harvesterror;
    @api landDetailId;
    @track selectedHarvest;
    @track isHarvestDataOpen = false;
    @track isHarvestFormOpen = false;
    @track name = '';
    @track density = '';
    @track feed = '';
    @track week = '';
    @track pPT = '';
    @track part1 = '';
    @track part3 = '';
    @track harvestDate = '';
    @track finalCount = '';
    @track pondStatus = '';
    @track remarks = '';
    @track gRams = '';
    @track weeklyGrowth = '';
    @track fCR = '';
    @track statusOptions = []; 
    @track selectedStatus
    @track selectedOption = '';

    @track landName = '';
    @track soilChange = '';
    @track landTopography = '';
    @track contactName = '';
    @track dateOfInspection = this.getCurrentDate();
    @track totalAreaNumber = 0;
    @track totalAreaSowed = 0;

    wiredLandDetailsResult;
    wiredHarvestDetailsResult;
    

     @track pondStatusOptions = [
        { label: 'Running', value: 'Running' },
        { label: 'Harvested', value: 'Harvested' }
      
    ];

    columns = [
        { label: 'Name', fieldName: 'Name', editable: true },
        {
            type: 'button',
            typeAttributes: {
                label: 'Harvest',
                variant: 'brand',
                name: 'HarvestDetails',
                title: 'Click to view harvest details',
                disabled: false,
                value: 'HarvestDetails',
            }
        },
        { label: 'Soil Detail', fieldName: 'Soil_Detail__c', type: 'text', editable: true },
        { label: 'Irrigation', fieldName: 'Irrigation_Type__c', type: 'picklist', editable: true, options: this.statusOptions  }, 
        { label: 'Total area Sowed', fieldName: 'Total_Area_Sowed__c',type: 'number', editable: true },
        { label: 'Last date of inspection', fieldName: 'Last_date_of_inspection__c', type: 'date', editable: true }
       
    ]; 
    contactName = ''; // Variable to store contact name

    @wire(getLandDetails, { contactId: '$contactId' })
    wiredLandDetails(result) {
        this.wiredLandDetailsResult = result;
        if (result.data) {
            this.data = result.data.map(landDetail => ({
                ...landDetail,
                ContactName: landDetail.Contact__r ? landDetail.Contact__r.Name : "",
                formatedateLand: this.formatDate(new Date(landDetail.Last_date_of_inspection__c))

            }));

            if (this.data.length > 0) {
                this.contactName = this.data[0].ContactName;
            }

            console.log('Contact Id data >>>>', JSON.stringify(this.wiredLandDetailsResult));
            console.log('Contact Name >>>>', this.contactName);
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.data = undefined;
        }
    }
    formatDate(date) {
        let day = date.getDate();
        let month = date.getMonth() + 1; 
        let year = date.getFullYear();
    
        if (day < 10) {
            day = '0' + day;
        }
        if (month < 10) {
            month = '0' + month;
        }
    
        return `${day}-${month}-${year}`;
    }


    @wire(getIrrigationTypePicklistValues)
    wiredPicklistValues({ error, data }) {
        if (data) {
            this.statusOptions = data.map(value => ({ label: value, value }));
        } else if (error) {
            this.error = error;
        }
    }

@wire(getContactDetails, { contactId: '$contactId' })
wiredContactDetails({ error, data }) {
    console.log('Wire method called>>>')
    if (data) {
        console.log('Wire method inside>>>', this.data);
        this.contactList = [data];
        this.contactName = data.Name;
        this.contactEmail = data.Email;
        this.contactPhone = data.Phone;
   
    } else if (error) {
        console.error('Error fetching contact details:', error);
    }
}



    @track selectedLandRecord = false;
    @track showYieldForm = false;
    @track selectedRecord = {};
    @track updatedFields = {}; 
    @track listViewLand = true;

    handleEditClick(event){

        this.landDatatable = false;
        this.listViewLand = false;
        this.selectedLandRecord = true;
        this.selectedRecordId = event.currentTarget.dataset.id;
        this.selectedRecord = this.data.find(record => record.Id === this.selectedRecordId);
        this.updatedFields = { ...this.selectedRecord }; 
        console.log('Edit clicekd', this.selectedLandRecord);
    }

    handleLandYieldClick(event){
        this.showYieldForm = true;
        this.selectedRecordId = event.currentTarget.dataset.id;
    }
    
    handleCardClick(event) {
        this.selectedRecordId = event.currentTarget.dataset.id;
        this.selectedRecord = this.data.find(record => record.Id === this.selectedRecordId);
        this.updatedFields = { ...this.selectedRecord }; 
        this.landDatatable = false;
        this.listViewLand = false;
    }

    /*handleInputChange(event) {
        let field = event.target.label.replace(/ /g, '_');
        if ((field.includes('Water_Source') && !field.endsWith('__c')) || (field.includes('Irrigation_Type') && !field.endsWith('__c'))) {
            field += '__c';
        }
    
        this.updatedFields[field] = event.target.value;
        console.log('Fields Data first >>>>', JSON.stringify(this.selectedRecord));
        console.log('Fields Data second >>>>', JSON.stringify(event.target.value));
    }*/ 
         handleInputChange(event) {
            const field = event.target.dataset.field;
            let value = event.target.value;
        
            if (field === 'Last_date_of_inspection__c') {
                // Ensure the value is in the correct format
                value = new Date(value).toISOString().split('T')[0];
            }
            if (field === 'Total_Area__c' || field === 'Total_Area_Sowed__c') {
                value = parseFloat(value);
            }
        
            this.updatedFields[field] = value;
            this.selectedRecord = { ...this.selectedRecord, [field]: value };
            console.log('updatedFields =>190'+JSON.stringify(this.updatedFields));
        }
    /*updateRecord() {
        const recordId = this.selectedRecordId;
        console.log('Fields Data >>>>', JSON.stringify(this.selectedRecord));
        console.log('Fields Data >>>>', JSON.stringify(this.updatedFields));
        updateLandDetailsMethod({ id: recordId, updatedFields: this.updatedFields })
        .then(() => {
            console.log('Record updated successfully:', recordId);
            this.listViewLand = true;
            this.landDatatable = true;
            this.selectedLandRecord=false;
            return refreshApex(this.wiredLandDetailsResult);
        })
        .catch(error => {
            console.error('Error updating record:', error);
        });
    }*/ 
        // updateRecord() {
        //     const recordId = this.selectedRecordId;
        //     const fieldsToUpdate = {};
        //     console.log('recordId ====> 210',recordId);
        
        //     // Iterate through updatedFields and add valid fields
        //     for (let key in this.updatedFields) {
        //         if (Object.prototype.hasOwnProperty.call(this.updatedFields, key)) {
        //             if (key === 'Name' || key === 'Soil_Detail__c' || key === 'Irrigation_Type__c' || key === 'Total_Area__c' ||
        //                 key === 'Total_Area_Sowed__c' || key === 'Last_date_of_inspection__c'|| key === 'Land_topography__c') {
        //                 fieldsToUpdate[key] = this.updatedFields[key];
        //             }
        //         }
        //     }
        
        //     console.log('Fields to Update:', JSON.stringify(fieldsToUpdate));
        
         
updateRecord() {
    const recordId = this.selectedRecordId;

    const fieldsToUpdate = {};
    for (let key in this.updatedFields) {
        if (this.updatedFields.hasOwnProperty(key)) {
            if (key === 'Name' || key === 'Soil_Detail__c' || key === 'Irrigation_Type__c' || key === 'Total_Area__c' || key === 'Total_Area_Sowed__c' || key === 'Last_date_of_inspection__c' || key === 'Land_topography__c') {
                fieldsToUpdate[key] = this.updatedFields[key];
            }
        }
    }

    updateLandDetailsMethod({ id: recordId, updatedFields: fieldsToUpdate })
        .then(() => {
            console.log('Record updated successfully:', recordId);
            this.listViewLand = true;
            this.landDatatable = true;
            this.showSuccessAlertUpdate();
            this.selectedLandRecord = false;
            refreshApex(this.wiredLandDetailsResult);
        })
        .catch(error => {
            console.error('Error updating record:', error);
            this.error = error;
            this.showToast('Error updating record', error.body.message, 'error');
        });
}


    backToLandDetails(){
        this.landName = '';
        this.soilChange = '';
        this.landTopography = '';
        this.dateOfInspection = '';
        this.totalAreaNumber = '';
        this.totalAreaSowed = '';
        this.selectedStatus = '';
        this.selectedRecordId = '';
        this.listViewLand = true;
        this.landDatatable= true;
        this.selectedLandRecord = false;
    }

    handleHarvestDetails(event) {
        const harvestId = event.detail.row.Id;
        this.selectedHarvest = this.data.find(harvest => harvest.Id === harvestId);
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        if (action.name === 'HarvestDetails') {
            this.landDetailId = row.Id;
            this.isHarvestDataOpen = true;
            this.landDatatable = false;
        }
    }
    
    handleContactChange(event) {
        this.contactName = event.target.value;
        console.log('contactName :'+ event.target.value )
    }

    createLandForm() {
        this.listViewLand = false;
        this.LandDetailsForm = true;
        this.landDatatable = false;
        this.isHarvestFormOpen = false;
        if (this.landList && this.landList.length > 0) {
            this.contactName = this.landList[0].Contact__r.Name;
        }
    }

    handleBack(event) {
        this.LandDetailsForm = false;
        this.landDatatable = true;
        this.listViewLand = true;
        console.log('Land data list vie'+ this.listViewLand);
        console.log('Land data list vie Data table'+ this.landDatatable);

        this.isHarvestDataOpen = false;
        this.isHarvestFormOpen = false;
    }

    handleLandChange(event) {
        this.landName = event.target.value;
    }

    handleSoilChange(event) {
        this.soilChange = event.target.value;
    }

    handleLandtopographyChange(event) {
        this.landTopography = event.target.value;
    }

    handleDateChange(event) {
        this.dateOfInspection = event.target.value;
    }

    handleAreaChange(event) {
        this.totalAreaNumber = event.target.value;
    }

    handleTotalArea(event) {
        this.totalAreaSowed = event.target.value;
    }

    handleIrrigationChange(event) {
        this.selectedStatus = event.detail.value;
        this.selectedOption = this.statusOptions.find(option => option.value === this.selectedStatus);
    }

    handleCellChange(event) {
   
      const draftValues = event.detail.draftValues;
      this.draftValues = draftValues;
    }

    //=========================================================Harvest Form start====================================================
    handleName(event) {
        this.name = event.target.value;
    }
    handleHarvestDate(event) {
        this.harvestDate = event.target.value;
    }
    handleFeed(event) {
        this.feed = event.target.value;
    }

    handleDensity(event) {
        this.density = event.target.value;
    }

    handlePPT(event) {
        this.pPT = event.target.value;
    }

    handlePart1(event) {
        this.part1 = event.target.value;
    }

    handlePart2(event) {
        this.part2 = event.target.value;
    }

    handlePart3(event) {
        this.part3 = event.target.value;
    }

    handleNumberFinalCount(event) {
        this.finalCount = event.target.value;
    }

    handleRemarks(event) {
        this.remarks = event.target.value;
    }

    handleGRams(event) {
        this.gRams = event.target.value;
    }

    handleWeeklyGrowth(event) {
        this.weeklyGrowth = event.target.value;
    }

    handleFCR(event) {
        this.fCR = event.target.value;
    }

    saveHarvest() {
        console.log('the land is is1>>',this.landDetailId);
        if (!this.landDetailId) {
            console.error('Land Detail ID is not set');
            //alert('Please select a land detail before saving the harvest.');
            this.showErrorAlert();
            return;
        }

        console.log('the land is is2>>',this.landDetailId);
        if (this.validateForm()) {
        const harvestDetails = {
            Name: this.name,
            Harvest_Date__c: this.harvestDate,
            Stocking_Density_in_Millions__c: this.density,
            Cum_feed_MT__c: this.feed,
            Salinity_ppt__c: this.pPT,
            Partial_1_Count__c: this.part1,
            Partial_3_Count__c: this.part3,
            Present_Final_Count__c: this.finalCount,
            Remarks__c: this.remarks,
            ADG_gRAMS__c: this.gRams,
            Weekly_growth__c: this.weeklyGrowth,
            FCR__c: this.fCR,
            Land_detals__c: this.landDetailId,
            Contact__c: this.contactId
        };
    
        createHarvest({ harvest: harvestDetails, landDetailId: this.landDetailId })
            .then(result => {
                console.log('harvestRecord==>>',JSON.stringify(result));
                this.harvestdata = [...this.harvestdata, result];
                this.contactDetails = true;
                this.fetchDetails(this.contactId);
                //alert('Harvest Created Successfully');
                this.showSuccessAlertHarvest();
                this.resetHarvestForm();
                this.isHarvestFormOpen = false;
                this.isHarvestDataOpen = false;
                this.LandDetailsForm = false;
                this.selectedLandRecord = false;

                this.isHarvestDataOpen = true;
                this.fetchDetails(this.landDetailId);
                return refreshApex(this.harvestdata);

            })
            .catch(error => {
                let message = 'Unknown error';
    
                if (error) {
                    if (error.body) {
                        if (Array.isArray(error.body)) {
                            message = error.body.map(e => e.message).join(', ');
                        } else if (error.body.message) {
                            message = error.body.message;
                        }
                    } else if (error.message) {
                        message = error.message;
                    }
                }
    
                console.error('Error: ' + message);
                //alert('Error: ' + message);
                this.showErrorAlert();
            });
    }
}
    
    resetHarvestForm() {
        this.name = '';
        this.harvestDate='';
        this.density = '';
        this.feed = '';
        this.week = '';
        this.pPT = '';
        this.part1 = '';
        this.part3 = '';
        this.finalCount = '';
        this.pondStatus = '';
        this.remarks = '';
        this.gRams = '';
        this.weeklyGrowth = '';
        this.fCR = '';
}


    createHarvestForm(event) {

        const selectedLandId = event.target.dataset.id;

        console.log( 'this.landDetailId >>',this.landDetailId );
        console.log( 'this.selectedRecordId >>',this.selectedRecordId);
        console.log( 'selectedLandId >>',selectedLandId);

        this.landDetailId = this.selectedRecordId;

        console.log( 'this.landDetailId >>',this.landDetailId );


        this.isHarvestFormOpen = true;
        this.isHarvestDataOpen = false;
        this.LandDetailsForm = false;
        this.selectedLandRecord = false;
        
    }

    //=========================================================Harvest Form End====================================================

    //======================================================== Land Details Save button in Datatable start ==========================================


    openHarvestData(landDetailId) {
        this.landDatatable = false;
        this.isHarvestDataOpen = true;
        this.isHarvestFormOpen = false;
        this.harvesterror = undefined;
        getHarvestDetailsEqualtoLand({ landDetailId })
            .then(result => {
                this.harvestdata = result;
            })
            .catch(error => {
                this.harvesterror = error;
            });
    }
    getCurrentDate() {
        const today = new Date();
        const yyyy = today.getFullYear();
        let mm = today.getMonth() + 1; 
        let dd = today.getDate();

        if (dd < 10) dd = '0' + dd;
        if (mm < 10) mm = '0' + mm;

        return `${yyyy}-${mm}-${dd}`;
    }


    saveLand(event) {
        if (this.validateForm()) {
        const fields = {
            Name: this.landName,
            Soil_Detail__c: this.soilChange,
            Land_topography__c: this.landTopography,
            Contact__c: this.contactId,
            Last_date_of_inspection__c: this.dateOfInspection,
            Total_Area__c: this.totalAreaNumber,
            Total_Area_Sowed__c: this.totalAreaSowed,
            Irrigation_Type__c: this.selectedOption ? this.selectedOption.label : null

        };

        createLand({ land: fields })
        .then(result => {
            this.landDetailId = result.Id; 
            this.fetchLandDetails(this.contactId);
            this.isHarvestFormOpen=false;
            this.LandDetailsForm=false;
            this.contactDetails = false;
            this.listViewLand = true;
            this.landDatatable = true;
            this.isHarvestDataOpen = false;

            //alert('Land created successfully');
            this.showSuccessAlertLand();
            this.landName = '';
            this.soilChange = '';
            this.landTopography = '';
            this.dateOfInspection = '';
            this.totalAreaNumber = '';
            this.totalAreaSowed = '';
            this.selectedStatus = '';
            return refreshApex(this.wiredLandDetailsResult);

            })
            .catch(error => {
                console.error('Error creating contact', error);
                //alert('An error occurred while creating the Land');
                this.showErrorAlert();
            });
        }
   
}
validateForm() {
    const allValid = [...this.template.querySelectorAll('lightning-input')]
        .reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
    return allValid;
}

fetchLandDetails(contactId) {
    getLandDetails({ contactId })
        .then(data => {
            if (data) {
                console.log('Fetched Land details', data);
                this.landList = data;
            }
        })
        .catch(error => {
            console.error('Error fetching contact details:', error);
        });
}

    //================== Edit functionality in Harvest Datatable ========================================

    handleHarvestCellChange(event) {
        const { draftValues } = event.detail;
        this.harvestDraftValues = draftValues;
    }
    

     saveHarvestDetails(event) {
        const updatedFields = event.detail.draftValues;
        saveHarvestDetails({ data: updatedFields })
            .then(() => {
                this.harvestDraftValues = [];
                return refreshApex(this.wiredHarvestDetailsResult);
            })
            .catch(error => {
                this.error = error;
            });
    }
    handleBackHarvest(event){
        
        this.LandDetailsForm = false;
        this.LandDatatable = false;
        this.isHarvestFormOpen = false;
        this.isHarvestDataOpen = true
        
    
    }
    handleBackToMain(event){
       location.reload();
    }
    handleHarvestButton(event) {

        this.selectedRecordId = event.currentTarget.dataset.id;
        this.selectedRecord = this.data.find(record => record.Id === this.selectedRecordId);
        console.log('the seleted record is>>',this.selectedRecordId);

        this.landDatatable = false;
        this.listViewLand = false;
        this.selectedLandRecord = false;
        this.LandDetailsForm = false;
        this.isHarvestFormOpen = false;
        this.isHarvestDataOpen = true;
        const landHarvestDetail = event.target.dataset.id;
        this.fetchDetails(landHarvestDetail);
        this.landDatatable = false;
    }
    
    fetchDetails(landHarvestDetail) {
        
        console.log('fetching new data');
        getHarvestDetailsEqualtoLand({ landDetailId: landHarvestDetail })
            .then(data => {
                if (data) {
                    console.log('Harvest details newsnb12>>', data);
                    this.harvestdata = data;
                    // this.formatedateHarvest = this.formatDate(new Date(this.harvestdata.Harvest_Date__c));
                }
            })
            .catch(error => {
                console.error('Error fetching contact details:', error);
            });
    }
    handleBackToListview(event){
      //  this.listViewLand=true;
    }
    //shivanipandarkar
    // Method to show sucess harvest
    showSuccessAlertHarvest() {
        LightningAlert.open({
            message: 'Harvest has been created successfully',
            theme: 'Success',
            label: 'Success',
        });
    }
 
    // Method to show an error alert
    showErrorAlert(headerLabel, bodyMessage) {
        LightningAlert.open({
            message: bodyMessage,
            theme: 'error',
            label: headerLabel,
        });
    }
    //Method to show success land
    showSuccessAlertLand() {
        LightningAlert.open({
            message: 'land has been created successfully',
            theme: 'Success',
            label: 'Success',
        });
    }
    showSuccessAlertUpdate() {
        LightningAlert.open({
            message: 'land has been Updated successfully',
            theme: 'Success',
            label: 'Success',
        });
    }
}