import { LightningElement,wire,api,track} from 'lwc';
import IndBankImage from '@salesforce/resourceUrl/SiteSamples';
import InusuranceConsentVf from '@salesforce/label/c.InusuranceConsentVf';
import InsuranceConsentvfagree from '@salesforce/label/c.InsuranceConsentvfagree';
import getInsuranceDetails from '@salesforce/apex/IND_InsuranceConsentOTP.getInsuranceDetails';
import updateInsuranceConsent from '@salesforce/apex/IND_InsuranceConsentOTP.updateInsuranceConsent';
import Consent_Already_Received from '@salesforce/label/c.Consent_Already_Received';
import Consent_Sent_Successfully from '@salesforce/label/c.Consent_Sent_Successfully';
import { NavigationMixin } from 'lightning/navigation';

export default class IND_InsuranceConsent extends NavigationMixin(LightningElement) {
    label = {
        InsuranceConsentvfagree,
        InusuranceConsentVf,
        Consent_Sent_Successfully,
        Consent_Already_Received
    };
    @api isAgreeButtonDisabled = false;
    @api iconButton = false;
    @api getInsPrdouctData;
    @api recordId;
    @api name;
    @api applicatnName;
    @api appId;
    @api loanAppId;

    @api preimum;
    @api insurDetailsLst;
    @api insuranceConsentDetails;
    @api showReceivedPage;
    @track applicant_name;
    @track vehicleName ;
    @track appNumber ;
    boolShowSpinner = false;
    pdfString;
    @track fileURL;
    imageURL;
    imageURL2;
    getIndBankImage = IndBankImage + '/img/indusind.png';

    async connectedCallback(){
        var list = await getInsuranceDetails({applicantId:this.recordId})
        .then(result=>{            
             this.insuranceConsentDetails=result.insuranceDetails;   
            
              this.applicant_name = result.applicantName;
              this.appNumber = result.leadNumber;
              this.vehicleName  = result.vehicleVariant;
             this.rowNo=0;

             this.fileURL = result.docId;
             this.imageURL =result.docId;
             this.imageURL2 = 'https://indusindbank123--psldev1.my.salesforce.com/sfc/p/71000000Fj9h/a/7100000044Rd/h4WKOASzRCInrx6LBWhUxzSvr9fzFMnNVwdhK6oGXSA';




         })
    }

    navigateToRecordPage() {
        console.log('Inside navigateToRecordPage');
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                "url": 'https://indusindbank123--psldev1.my.salesforce.com/'+this.fileURL
            }
        });
}

//Navigate to visualforce page
navigateToVFPage() {
    console.log('Inside navigateToVFPage');
    this[NavigationMixin.GenerateUrl]({
        type: 'standard__webPage',
        attributes: {
            url: 'https://indusindbank123--psldev1.my.salesforce.com/'+this.fileURL
        }
    }).then(generatedUrl => {
        window.open(generatedUrl);
    });
}


navigateURLPage(){
    console.log('Inside navigateURLPage');
   // window.open('https://indusindbank123--psldev1.my.salesforce.com/'+this.fileURL);
   window.open('data:image/gif;base64',this.fileURL);
}
    updateConsent(){
       // console.log('Calling enable checkbox', this.recordId);
        updateInsuranceConsent({appId:this.recordId}).then(result=>{
            console.log('Insurance consent result : ',result);
                this.iconButton = true;
                this.isAgreeButtonDisabled = true;
                this.showReceivedPage=true;
                const myEvent=new CustomEvent('received',{
                    detail:this.showReceivedPage
                })

                this.dispatchEvent(myEvent)


        }).catch(error => {
            console.log('ERROR'+JSON.stringify(error));
        })
    }



    get inscrementRowNo()
    {
        
        if(this.rowNo < this.insuranceConsentDetails.length)
        {
            this.rowNo=this.rowNo+1
            return this.rowNo;
        }
        else{
            this.rowNo=1
            return this.rowNo;
        }
    }
   
}