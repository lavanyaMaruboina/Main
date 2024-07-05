import { refreshApex } from '@salesforce/apex';
import createHarvest from '@salesforce/apex/AccountSearchController.createHarvest';
import createLand from '@salesforce/apex/AccountSearchController.createLand';
import getContactDetails from '@salesforce/apex/AccountSearchController.getContactDetails';
import getHarvestDetailsEqualtoLand from '@salesforce/apex/AccountSearchController.getHarvestDetailsEqualtoLand';
import getIrrigationTypePicklistValues from '@salesforce/apex/AccountSearchController.getIrrigationTypePicklistValues';
import getLandDetails from '@salesforce/apex/AccountSearchController.getLandDetailstrue';
import getLandsByContactId from '@salesforce/apex/AccountSearchController.getLandsByContactId';
import LightningAlert from 'lightning/alert';
import { LightningElement, api, track, wire } from 'lwc';
export default class CreateLandDetailsForm extends LightningElement {
    @track landName = '';
    @track soilChange = '';
    @track landTopography = '';
    @track contactName = '';
    @track dateOfInspection = this.getCurrentDate();
    @track totalAreaNumber = '';
    @track totalAreaSowed = '';
    @track statusOptions = [];
    @api contactId;
    @track LandDetailsForm = true;
    @track selectedStatus = '';
    @track isHarvestFormOpen = false;
    //===================Harvest==================
    @track name = '';
    @track density = '';
    @track feed = '';
    @track pPT = '';
    @track part1 = '';
    @track part3 = '';
    @track finalCount = '';
    @track pondStatus = '';
    @track remarks = '';
    @track gRams = '';
    @track weeklyGrowth = '';
    @track fCR = '';
    @track harvestdata;
    @track harvesterror;
    wiredHarvestDetailsResult;
    @api landDetailId;
    @track finalData = false;
    @track landDetailsNew = true;
    @track contactDetails = false;
    @track landList;
    @track landData = [];
    @track newLand;

    @track landDetails = false;

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
        if (data) {
            this.contactList = [data];
            this.contactName = data.Name;
            this.contactEmail = data.Email;
            this.contactPhone = data.Phone;
       
        } else if (error) {
            console.error('Error fetching contact details:', error);
        }
    }

    @wire(getHarvestDetailsEqualtoLand, { landDetailId: '$landDetailId' })
    wiredHarvestDetails(result) {
        this.wiredHarvestDetailsResult = result;
        if (result.data) {
            this.harvestdata = result.data;
            this.harvesterror = undefined;
        } else if (result.error) {
            this.harvesterror = result.error;
            this.harvestdata = undefined;
        }
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

    resetForm() {
        this.landName = '';
        this.soilChange = '';
        this.landTopography = '';
        this.dateOfInspection = '';
        this.totalAreaNumber = '';
        this.totalAreaSowed = '';
        this.selectedStatus = '';
    }
   

    saveLand(event) {
            const fields = {
                Name: this.landName,
                Soil_Detail__c: this.soilChange,
                Land_topography__c: this.landTopography,
                Contact__c: this.contactId,
                Date_of_Sampling_Harvest__c: this.dateOfInspection,
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
                this.landDetails = true;

               
                //alert('Land created successfully');
                this.showSuccessAlertLand();
                this.landName = '';
                this.soilChange = '';
                this.landTopography = '';
                this.dateOfInspection = '';
                this.totalAreaNumber = '';
                this.totalAreaSowed = '';
                this.selectedStatus = '';

                })
                .catch(error => {
                    console.error('Error creating contact', error);
                    this.showErrorAlert();
                    //alert('An error occurred while creating the Land');
                });
       
    }

    fetchLandDetails(contactId) {
        getLandDetails({ contactId })
            .then(data => {
                if (data) {
                    console.log('Fetched Land details', data);
                    this.newLand = data;
                }
            })
            .catch(error => {
                console.error('Error fetching contact details:', error);
            });
    }


    handleReset(event){
        this.resetForm(); 
    }

    handleBack(){
        this.contactDetails = true;
        this.LandDetailsForm = false;
        this.isHarvestFormOpen = false;
        this.landDetailsNew =false;
        this.landDetails =false;
        this.landName = '';
        this.soilChange = '';
        this.landTopography = '';
        this.dateOfInspection = '';
        this.totalAreaNumber = '';
        this.totalAreaSowed = '';
        this.selectedStatus = '';
    }

    handleCreateLand(){
        this.LandDetailsForm = true;
        this.isHarvestFormOpen = false;
        this.landDetailsNew =false;
        this.contactDetails = false;

    }
   
    //======================================= Harvest details ==================================
    handleName(event) {
        this.name = event.target.value;
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

    handleFinalSurvival(event) {
        this.finalSurvival = event.target.value;
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

    handleAddHarvest(){
        console.log('land id is new>>',event.target.dataset.id);
        this.landDetailId = event.target.dataset.id;
        this.isHarvestFormOpen = true;
        this.LandDetailsForm = false;
        this.landDetailsNew =false;
        this.landDetails=false;
        this.contactDetails = false;
    }

    saveHarvest() {
    const harvestRecord = {
        Name: this.name,
        Stocking_Density_in_Millions__c: this.density,
        Cum_feed_MT__c: this.feed,
        Last_week_ABW__c: this.week,
        Salinity_ppt__c: this.pPT,
        Partial_1_Count__c: this.part1,
        Partial_3_Biomass_MT__c: this.part3,
        Present_Final_Count__c: this.finalCount,
        Pond_status__c: this.pondStatus,
        Remarks__c: this.remarks,
        ADG_gRAMS__c: this.gRams,
        Weekly_growth__c: this.weeklyGrowth,
        FCR__c: this.fCR,
        Land_detals__c: this.landDetailId,
        Contact__c: this.contactId
    };

    createHarvest({ harvest: harvestRecord, landDetailId: this.landDetailId })
        .then(result => {
            console.log('harvestRecord==>>'+harvestRecord);
            this.harvestdata = [result];
            //alert('Harvest Created Successfully');
            this.showSuccessAlertHarvest();
            console.log('harvestdata creted==>>',JSON.stringify(this.harvestdata));
            
            this.fetchDetails(this.contactId);

            this.contactDetails = true;

            this.name = '';
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
            this.isHarvestFormOpen = false;
            return refreshApex(this.wiredHarvestDetailsResult);
        })
        
        .catch(error => {
        
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            //this.showErrorAlert();

        });
}
   resetHarvestForm() {
        this.name = '';
        this.density = '';
        this.feed = '';
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

    handleBackHome(){
        window.location.reload();
    }

    handleBackContact(){
        this.contactDetails = true;
        this.landDetails = false;
        this.fetchDetails(this.contactId);
    }

    fetchDetails(contactId) {
        console.log('fetching new data');
        getLandsByContactId({ contactId })
        .then(data => {
            if (data) {
                console.log('Fetched Land details newsnb12>>', data);
                this.landData = data;
                this.finalData = true;
            }
        })
        .catch(error => {
            console.error('Error fetching contact details:', error);
        });
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
            message: 'Land has been created successfully',
            theme: 'Success',
            label: 'Success',
        });
    }
    showSuccessAlertUpdate() {
        LightningAlert.open({
            message: 'Land has been Updated successfully',
            theme: 'Success',
            label: 'Success',
        });
    }

}