import { LightningElement,wire,api,track } from 'lwc';
import getRecords from '@salesforce/apex/PersonalDetailsforCAM.getRecordsVarientold';
import getTractorAssetRecords from '@salesforce/apex/PersonalDetailsforCAM.getRecordsVarientForTractor'; // for SFTRAC-92

export default class LWC_incomedetailsVarient extends LightningElement {
    activeSections = ['Varient Selected'];
    @api recordId;
    @api appId;
@track lstRecords =[];

@track VehicleRegistrationNumber;
@track VehicleType;
@track VehicleSubCategory;
@track ParentDealnumber;
@track Make;
@track Model;
@track Variant;
@track Valuationprice;
@track Insurancedeclaredvalue;
@track Gridvalue;
@track SellingPrice;
@track assetLabel = 'Asset Variant'; // Added for SFTRAC-92
@api substage=false;
// @api index; // Added for SFTRAC-92
@api isTractorLead = false; // Added for SFTRAC-92
@api vehicleRecordId; // Added for SFTRAC-92
@api isUsedTractorLead = false; // Added for SFTRAC-92
@api isNewTractorLead = false; // Added for SFTRAC-92

@wire (getRecords,{ opp :'$recordId' })fetchData(value) {
    const {
        data,
        error
    } = value;
    if(data){
for (let key in data) {
    this.lstRecords.push({value:data[key], key:key});
    }
    if(!this.isTractorLead){
    this.VehicleRegistrationNumber= data["Vehicle_Registration_Number__c"];
    this.VehicleType= data["Vehicle_Type__c"];
    this.VehicleSubCategory= data["Vehicle_Sub_Category__c"];
    this.ParentDealnumber= data["Parent_Deal_number__c"];
    this.Make= data["Make__c"];
    this.Model= data["Model__c"];
    this.Variant= data["Variant__c"];  
    this.Valuationprice= data["Valuation_price__c"];
    this.Insurancedeclaredvalue= data["Insurance_declared_value__c"];
    this.Gridvalue= data["Grid_value__c"];
    this.SellingPrice= data["Selling_Price__c"];
    }
   // this.OnRoadprice= data["On_Road_price__c"];
}
    else if(error){
        ////console.log(error);
        this.lstRecords = [];
    }
}

async connectedCallback(){
    /*Change for SFTRAC-92 Start*/
    if(this.isTractorLead){
        // this.index += 1; 
        // console.log('this.index+1>>  '+this.index);
        // this.assetLabel = 'Asset Variant: '+ this.index ;
        // console.log('this.assetLabel>>  '+this.assetLabel);
        await getTractorAssetRecords({opp : this.recordId, vehicleRecordId : this.vehicleRecordId }).then(result => {
            console.log('result getTractorAssetRecords > '+JSON.stringify(result));
            if(result){
                for (let key in result) {
                    this.lstRecords.push({value:result[key], key:key});
                }
                this.VehicleRegistrationNumber= result["Vehicle_Registration_Number__c"];
                this.VehicleType= result["Vehicle_Type__c"];
                this.VehicleSubCategory= result["Vehicle_Sub_Category__c"];
                this.ParentDealnumber= result["Parent_Deal_number__c"];
                this.Make= result["Make__c"];
                this.Model= result["Model__c"];
                this.Variant= result["Variant__c"];  
                this.assetLabel += (' - ' + result["Variant__c"]); 
                this.Valuationprice= result["Valuation_price__c"];
                this.Insurancedeclaredvalue= result["Insurance_declared_value__c"];
                this.Gridvalue= result["Grid_value__c"];
                this.SellingPrice= result["Selling_Price__c"];
            }
        })
        .catch(error => {
            // Handle any errors that occurred during the Apex call
            console.error('Error fetching tractor records:', error);
            // Optionally, display an error message to the user
        });
    }
    /*Change for SFTRAC-92 End*/
}
renderedCallback() {
    if(this.substage){
        let allElements = this.template.querySelectorAll('*');
    allElements.forEach(element =>
     element.disabled = true
       );
    }
    //this.handle_Green_Text_Click();
}
@api handlesubmits(){
    
    submitrec()
            .then(result => {
               //('@@');
            })
            .catch(error => {
                this.error = error;
            });
}
}