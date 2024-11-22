import { LightningElement ,api} from 'lwc';

export default class approvalstatus extends LightningElement {

    @api approvalstatus;
    @api color;
    @api noOfDaysPending;

    get getColor(){
        if(this.approvalstatus!=undefined){
            var statusLowerCase = this.approvalstatus.toLowerCase();

            var cOrange='Pending';
            var cGreen='Approved';
            var cRed='Not Approved';
            
           
            if(this.approvalstatus =='Pending'){
                this.color='orange';
            }
            else if(this.approvalstatus =='Approved'){
                this.color='green';
            }
            // else if(cRed.indexOf(statusLowerCase)!=-1){
            //     this.color='red';
            if(this.noOfDaysPending>3) {
                this.color='red';
            }
    }

   
    return this.color + ' slds-badge';

}
get getRecordColor(){

    if(this.noOfDaysPending!=undefined){
        // var statusLowerCase = this.noOfDaysPending.toLowerCase();
 
         var cOrange='Pending';
         var cGreen='Approved';
         var cRed='Not Approved';
         
        
         if(this.noOfDaysPending === 13){
             this.color='red';
         }
        
 }
     return this.color + ' slds-badge';
 
}

}