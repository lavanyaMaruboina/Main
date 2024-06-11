import getregistrationID from '@salesforce/apex/OpportunityLocationController.insertregistarionid';
import REGISTRATION_ID from "@salesforce/schema/Request_For_ID__c";
import EmailID from "@salesforce/schema/Request_For_ID__c.Email_ID__c";
import MedicalCouncilName from "@salesforce/schema/Request_For_ID__c.Medical_council_Name__c";
import OnboardingDate from "@salesforce/schema/Request_For_ID__c.Onboarding_Date__c";
import Onboardingtype from "@salesforce/schema/Request_For_ID__c.Onboarding_Type__c";
import Qualification from "@salesforce/schema/Request_For_ID__c.Qualification__c";
import RegistrationNumber from "@salesforce/schema/Request_For_ID__c.Registration_Number__c";
import YearOFGraduation from "@salesforce/schema/Request_For_ID__c.Year_of_graduation__c";
import { LightningElement, track } from 'lwc';

export default class RequestForIdCreation extends LightningElement {
    registrationID = REGISTRATION_ID;
    Onboardingtype = Onboardingtype;
    OnboardingDate = OnboardingDate;
    EmailID = EmailID;
    RegistrationNumber = RegistrationNumber;
    MedicalCouncilName = MedicalCouncilName;
    Qualification = Qualification;
    YearOFGraduation = YearOFGraduation;
    @track rec = {
        Onboarding_Type__c: this.Onboardingtype,
        Onboarding_Date__c: this.OnboardingDate,
        Email_ID__c: this.EmailID,
        Registration_Number__c: this.RegistrationNumber,
        Medical_council_Name__c: this.MedicalCouncilName,
        Qualification__c: this.Qualification,
        Year_of_graduation__c: this.YearOFGraduation
      };
      requestForId(event) {
        let { name, value } = event.target;
        if (name === "Onboardtype") { this.rec.Onboarding_Type__c = value;
          console.log("this.rec.FirstName", this.rec.Onboarding_Type__c);
        }
        if (name === "Onboarddate") this.rec.Onboarding_Date__c = value;
        if (name === "email") this.rec.Email_ID__c = value;
        if (name === "registrationnumber") this.rec.Registration_Number__c = value;
        if (name === "medicalcouncil") this.rec.Medical_council_Name__c = value;
        if (name === "qualification") this.rec.Qualification__c = value;
        if (name === "yeargraduation") {
          this.rec.Year_of_graduation__c = value;
          console.log("this.rec.Name", this.rec.Year_of_graduation__c);
        }
      }
      saveHandler(event)
    {
        getregistrationID({
            regi:this.rec
        }).then((data)=>{
            console.log(data);

        })
        .catch((error)=> {
            console.log(error);
        });
        
        }
}