import { LightningElement, track,wire,api } from 'lwc';

export default class AddressSections extends LightningElement 
{
    @api eachApplicant;
    @api finacleCityOptions = [];
    @api index;
    residenceCityFinacle;
    permanentFinacle;
    officeCityFinacle;

    connectedCallback()
    {
        if(this.eachApplicant.residenceCityFinacle != '' && this.eachApplicant.residenceCityFinacle != undefined && this.eachApplicant.residenceCityFinacle != null)
        {
            this.residenceCityFinacle = this.eachApplicant.residenceCityFinacle;
        }
        if(this.eachApplicant.permanentFinacle != '' && this.eachApplicant.permanentFinacle != undefined && this.eachApplicant.permanentFinacle != null)
        {
            this.permanentFinacle = this.eachApplicant.permanentFinacle;
        }
        if(this.eachApplicant.officeCityFinacle != '' && this.eachApplicant.officeCityFinacle != undefined && this.eachApplicant.officeCityFinacle != null)
        {
            this.officeCityFinacle = this.eachApplicant.officeCityFinacle;
        }                 
    }
    residenceCityOnlookuphandler(event) {
       // this.residenceCityFinacle = event.target.value;
        const changeEvent = new CustomEvent('child', {
            // detail contains only primitives
            detail: {fieldName:'residenceCityFinacle', index:this.index, value:event.detail.selectedValueId}
            });
        this.dispatchEvent(changeEvent);
        
      }
      permanentFinaclonlookupHandler(event) {
      //  this.residenceCityFinacle = event.target.value;
        const changeEvent = new CustomEvent('child', {
            // detail contains only primitives
            detail: {fieldName:'permanentFinacle', index:this.index, value:event.detail.selectedValueId}
            });
        this.dispatchEvent(changeEvent);
        
      }
      officeCityFinacleonlookupHandler(event) {
     //   this.residenceCityFinacle = event.target.value;
        const changeEvent = new CustomEvent('child', {
            // detail contains only primitives
            detail: {fieldName:'officeCityFinacle', index:this.index, value:event.detail.selectedValueId}
            });
        this.dispatchEvent(changeEvent);
        
      }
    // handleChange(event)
    // {
    //     const name = event.target.name;
    //     console.log('test in child ',event.target.value);
    //     if(name == 'residenceCityFinacle')
    //     {            
    //         this.residenceCityFinacle = event.target.value;
    //     }
    //     else if(name == 'permanentFinacle')
    //     {            
    //         this.permanentFinacle = event.target.value; 
    //     }
    //     else if(name == 'officeCityFinacle')
    //     {            
    //         this.officeCityFinacle = event.target.value; 
    //     }   
        
    //     const changeEvent = new CustomEvent('child', {
    //         // detail contains only primitives
    //         detail: {fieldName:name, index:this.index, value:event.target.value}
    //         });
    //     this.dispatchEvent(changeEvent);
    // }
}