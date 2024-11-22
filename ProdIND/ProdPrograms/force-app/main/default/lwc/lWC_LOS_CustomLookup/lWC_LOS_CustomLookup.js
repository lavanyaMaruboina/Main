import { LightningElement, track, wire, api } from "lwc";  
 import findRecords from "@salesforce/apex/iND_CustomLookup.findRecords";
 import findUserRecords from "@salesforce/apex/iND_CustomLookup.findUserRecords";
 import findRecordsForCVOPE from '@salesforce/apex/iND_CustomLookup.findRecordsForCVOPE';//SFTRAC-1893
 export default class LwcLookup extends LightningElement {  
  @track recordsList;  
  @track searchKey = "";  
  @api selectedValue;  
  @api selectedRecordId;  
  @api objectApiName;  
  @api iconName;  
  @api lookupLabel;  
  @track message;  
  @api loanappid;
  @api agentblcode;
  @track stateValue;
  @track branchValue ;
  @api fromleadassignment;//SFTRAC-1893
  @api accrole;//SFTRAC-1893
  @api currentowner;
  @api get state() {
    return this.stateValue;
  }
  set state(value) {
      this.setAttribute('state', value);
      this.stateValue = value;
      console.log('OUTPUT this.stateValue ***: ',this.stateValue);
      this.searchKey = ""; 
      this.recordsList = null;
      this.branchValue='';
      this.removeRecordOnLookup();
  }

  @api get branch() {
    return this.branchValue;
  }
  set branch(value) {
      this.setAttribute('branch', value);
      this.branchValue = value;
      console.log('OUTPUT this.branch ***: ',this.branchValue);
      this.searchKey = ""; 
      this.recordsList = null;
      this.removeRecordOnLookup();
  }
  connectedCallback(){
    console.log('i am in custom lookup : ',);
  }
  onLeave(event) {  
   setTimeout(() => {  
    this.searchKey = "";  
    this.recordsList = null;  
   }, 300);  
  }  
    
  onRecordSelection(event) {  
   this.selectedRecordId = event.target.dataset.key;  
   this.selectedValue = event.target.dataset.name;  
   this.searchKey = "";  
   this.onSeletedRecordUpdate();  
  }  
   
  handleKeyChange(event) {  
    console.log('OUTPUT handleKeyChange : ',);
   const searchKey = event.target.value;  
   this.searchKey = searchKey;  
   console.log('search key ',this.searchKey)
   if(this.fromleadassignment == true){
    this.getLookupData();
   }else
   this.getLookupResult(); 
  }  
   
  removeRecordOnLookup(event) {  
   this.searchKey = "";  
   this.selectedValue = null;  
   this.selectedRecordId = null;  
   this.recordsList = null;  
   this.onSeletedRecordUpdate();  
 }  
  
 getLookupData(){ //SFTRAC-1893
  console.log('getLookupResult called')
    findRecordsForCVOPE({ searchKey: this.searchKey, objectName : this.objectApiName , AccountID: this.agentblcode, accountRole : this.accrole})  
     .then((result) => {
      console.log('getLookupResult then')  
       console.log('The lenth of the user ', result.length)
       if (result.length===0) {  
        this.recordsList = [];  
        this.message= true;
         this.message = "No Records Found";  
    
     } else {  
        let itemVal=result.filter(item => ( item.User.Name != this.currentowner));
        console.log('in data save ***',itemVal); 
        this.recordsList = itemVal;  
         this.message = "";  
       }  
       this.error = undefined;  
      })  
    .catch((error) => {  
      this.error = error;  
     this.recordsList = undefined;  
    });  
 }
  getLookupResult() { 
    
    findRecords({ searchKey: this.searchKey, objectName : this.objectApiName , loanID: this.loanappid, AccountID: this.agentblcode , branch: this.branchValue})  
     .then((result) => {  
       console.log('The lenth of the user ', result.length)
       if (result.length===0) {  
        this.recordsList = [];  
        this.message= true;
         this.message = "No Records Found";  
    
     } else {  
        this.recordsList = result;  
         this.message = "";  
       }  
       this.error = undefined;  
      })  
    .catch((error) => {  
      this.error = error;  
     this.recordsList = undefined;  
    });  

    // CISP-3497
   /* findUserRecords({ searchKey: this.searchKey, objectName : this.objectApiName , loanID: this.loanappid, AccountID: this.agentblcode, branch: this.branch})  
    .then((result) => {  
      console.log('result : ',result)
     if (result.length===0) {  
       this.recordsList = [];  
       this.message= true;
       this.message = "No Records Found";  
      
      } else {  
       this.recordsList = result;  
       this.message = "";  
      }  
      this.error = undefined;  
    })  
    .catch((error) => {  
     this.error = error;  
     this.recordsList = undefined;  
    }); */
  }  
   
  onSeletedRecordUpdate(){  
   const passEventr = new CustomEvent('recordselection', {  
     detail: { selectedRecordId: this.selectedRecordId, selectedValue: this.selectedValue }  
    });  
    this.dispatchEvent(passEventr);  
  }  
 }