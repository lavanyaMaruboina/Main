import { LightningElement,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLeadDetails from '@salesforce/apex/ind_leadAssignmentForNCMUser.getLeadDetails';
import changeOwnerFromLeadAssignment from '@salesforce/apex/ind_leadAssignmentForNCMUser.changeOwnerFromLeadAssignment'
export default class IND_leadAssignmentForNCMUsers extends LightningElement {
    optionValue;searchValue;fromLeadAssignment =true;selectedrecordName;selectedRecordId
    @track leadDetailsList =[];
    get searchOptions() {
        return [
            { label: 'Search By User Name', value: 'searchByUserName' },
            { label: 'Search By Lead Number', value: 'searchByLeadNumber' },
        ];
    }
    handleChange(event){
        this.leadDetailsList = [];
        this.searchValue  = '';
        this.optionValue = event.target.value;
    }
    handleSerachChange(event){
        this.leadDetailsList = [];
        this.searchValue = event.target.value;
    }
    handleSearchClick(){
        this.leadDetailsList = [];
        if(!this.optionValue || !this.searchValue){
            const evt = new ShowToastEvent({
                title: 'Please select or enter Search Option/Value',
                variant: 'warning'
            });
            this.dispatchEvent(evt);
            return null;
        }else{
            getLeadDetails({searchValue : this.searchValue,searchOption:this.optionValue}).then(data =>{
                console.log('data---',data);
                if(data){
                this.leadDetailsList = data;
                console.log('this.leadDetailsList---',this.leadDetailsList);
                }else{
                    const evt = new ShowToastEvent({
                        title: 'Info',
                        message: 'No Matching Records Found',
                        variant: 'info'
                    });
                    this.dispatchEvent(evt);
                }
            }
            ).catch(error =>{console.log('error--',error)})
        }
        
    }
    onRecordSelection(event) {
        var index=event.target.dataset.targetId;
        console.log('index--',index);
        this.selectedrecordName = event.detail.selectedValue;
        console.log('The selected record name is '+ this.selectedrecordName)
        this.selectedRecordId = event.detail.selectedRecordId;
        console.log('The selected record name id is '+ this.selectedRecordId);
        this.leadDetailsList[index].selectedrecordName = this.selectedrecordName;
        this.leadDetailsList[index].selectedRecordId = this.selectedRecordId;
        console.log('this.leadDetailsList after update ', this.leadDetailsList);
    }
    handleDone(){
        let itemVal=this.leadDetailsList.filter(item => (item.hasOwnProperty('selectedrecordName') && item.selectedrecordName != ''));
        console.log('in data save ***',itemVal);
        if(itemVal.length == 0){
            const evt = new ShowToastEvent({
                title: 'Please select a record to transfer',
                variant: 'warning'
            });
            this.dispatchEvent(evt);
            return null;
        }
        changeOwnerFromLeadAssignment({listOfLeads : JSON.stringify(itemVal)}).then(data =>{
            console.log('in data save ***',data);
            const evt = new ShowToastEvent({
                message: 'Lead Transfer Successfully !...',
                title: 'Success',
                variant: 'Success'
            });
            this.dispatchEvent(evt);

        }).catch(error =>{
            console.log('error in data save--',error);
            const evt = new ShowToastEvent({
                title: 'Error',
                message: error,
                variant: 'error'
            });
            this.dispatchEvent(evt);
        })
    }
}