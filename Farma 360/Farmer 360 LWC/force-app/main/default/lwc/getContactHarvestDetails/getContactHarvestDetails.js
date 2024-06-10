import { refreshApex } from '@salesforce/apex';
import createHarvest from '@salesforce/apex/AccountSearchController.createHarvest';
import getHarvestDetails from '@salesforce/apex/LandDetailsController.getHarvestDetails';
import { LightningElement, api, track, wire } from 'lwc';

export default class GetContactHarvestDetails extends LightningElement {
    @track data;
    @track columns = [
        { label: 'Name', fieldName: 'Name', editable: true },
        { label: 'Stocking Dencity', fieldName: 'Stocking_Density_in_Millions__c', type: 'number', editable: true },
        { label: 'Cum.Feed', fieldName: 'Cum_feed_MT__c', editable: true },
        { label: 'Last week ABW', fieldName: 'Last_week_ABW__c', editable: true },
        { label: 'Salinity', fieldName: 'Salinity_ppt__c', type: 'number', editable: true },
        { label: 'Partial1 Biomass', fieldName: 'Partial_1_Count__c', editable: true },
        { label: 'Present Final Count', fieldName: 'Present_Final_Count__c', type: 'number', editable: true },
        { label: 'Present Final Survival', fieldName: 'Present_Final_Survival_Millions__c', editable: true },
    ];
    @track draftValues = [];
    @track error;
    @track editMode = false;
    @track HarvestDetailsForm = false; // To manage the form visibility
    @track HarvestDatatable = true; // To manage the edit mode
    @api contactId;

    @track name;
    @track density;
    @track feed;
    @track week;
    @track pPT;
    @track part1;
    @track part2;
    @track part3;
    @track finalCount;
    @track finalSurvival;
    @track pondStatus;
    @track remarks;
    @track ontact;
    @track gRams;
    @track weeklyGrowth;
    @track fCR;
    @track pondStatus;

    wiredLandDetailsResult;

    @wire(getHarvestDetails, { contactId: '$contactId' })
    wiredLandDetails(result) {
        this.wiredLandDetailsResult = result;
        if (result.data) {
            this.data = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.data = undefined;
        }
    }

    createLandForm() {
        this.LandDetailsForm = true;
        this.HarvestDatatable = false;
        if (this.data && this.data.length > 0) {
            this.contactName = this.data[0].Contact__r.Name;
        }
    }

     handleBack(event) {
        this.LandDetailsForm = false;
        this.HarvestDatatable = true;

    }

    toggleEditMode() {
        this.editMode = !this.editMode;
    }

    handleSave(event) {
        const updatedFields = event.detail.draftValues;
        saveHarvestDetails({ data: updatedFields })
            .then(() => {
                this.draftValues = [];
                return refreshApex(this.wiredLandDetailsResult);
            })
            .catch(error => {
                this.error = error;
            });
    }

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        if (selectedRows.length > 0) {
            this.selectedContactId = selectedRows[0].Id;
        }
    }

     handleName(event) {
        this.name = event.target.value;
    }

     handleFeed(event) {
        this.feed = event.target.value;
    }
    
     handleDensity(event) {
        this.density = event.target.value;
    }

     handleWeek(event) {
        this.week = event.target.value;
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


     handlePondStatus(event) {
        this.pondStatus = event.target.value;
    }

      handleRemarks(event) {
        this.remarks = event.target.value;
    }
    
      handleOntact(event) {
        this.ontact = event.target.value;
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

      handlePondStatus(event) {
        this.pondStatus = event.target.value;
    }



    // saveHarvest() {
    //     this.HarverDetailsForm = true;
    //     this.LandDatatable = false;
    //     const fields = {
    //         Name: this.name,
    //         tocking_Density_in_Millions__c: this.density,
    //         Cum_feed_MT__c: this.feed,
    //         CLast_week_ABW__c: this.week,
    //         Salinity_ppt__c: this.pPT,
    //         Partial_1_Count__: this.part1,
    //         Partial_2_Count__c: this.part2,
    //         Partial_3_Count__c: this.part3,
    //         Present_Final_Count__cs: this.finalCount,
    //         PPresent_Final_Survival_Millions__: this.finalSurvival,
    //         PPond_status__c: this.pondStatus,
    //         Remarks__c: this.remarks,
    //         ontact__c: this.ontact,
    //         ADG_gRAMS__c: this.gRams,
    //         Weekly_growth__c: this.weeklyGrowth,
    //         FCR__c: this.fCR,
    //         Pond_status__c: this.pondStatus,
    //     };

    //     createLand({ land: fields })
    //         .then(result => {
    //             this.landDetails = [...this.landDetails, result];
    //             this.dispatchEvent(
    //                 new ShowToastEvent({
    //                     title: 'Success',
    //                     message: 'Land created successfully',
    //                     variant: 'success',
    //                 })
    //             );
    //             return refreshApex(this.wiredLandDetailsResult);
    //         })
    //         .catch(error => {
    //             let message = 'Unknown error';
    //             if (Array.isArray(error.body)) {
    //                 message = error.body.map(e => e.message).join(', ');
    //             } else if (typeof error.body.message === 'string') {
    //                 message = error.body.message;
    //             }
    //             this.dispatchEvent(
    //                 new ShowToastEvent({
    //                     title: 'Error creating land',
    //                     message: message,
    //                     variant: 'error',
    //                 })
    //             );
    //         });
    // }



//=====================
saveHarvest() {
        const harvestRecord = {
            Name: this.name,
            Stocking_Density_in_Millions__c: this.density,
            Cum_feed_MT__c: this.feed,
            CLast_week_ABW__c: this.week,
            Salinity_ppt__c: this.pPT,
            Partial_1_Count__c: this.part1,
            Partial_2_Count__c: this.part2,
            Partial_3_Count__c: this.part3,
            Present_Final_Count__c: this.finalCount,
            Present_Final_Survival_Millions__c: this.finalSurvival,
            // PPond_status__c: this.pondStatus,
            Remarks__c: this.remarks,
            Contact__c: this.contact,
            ADG_gRAMS__c: this.gRams,
            Weekly_growth__c: this.weeklyGrowth,
            FCR__c: this.fCR,
            // Pond_status__c: this.pondStatus,
        };
    
        createHarvest({ harvest: harvestRecord, landDetailId: this.landDetailId })
            .then(result => {
                console.log('harvestRecord==>>'+harvestRecord);
                this.harvestdata = [...this.harvestdata, result];
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Harvest created successfully',
                        variant: 'success',
                    })
            
                );
    
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
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating Harvest',
                        message: message,
                        variant: 'error',
                    })
                );
            });
        }
}