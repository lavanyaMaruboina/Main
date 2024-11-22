/**
* @author: Raj Gupta.
* @company: Persistent Systems
* @description:A BackToLoanApp class is use to return the custom metadata according to documentType
* History:
* 27/10/2012  Added by Raj. 
*/
public class BackToLoanAppLWC {
    
    //Class to declare kycMetadata. 
    class GoBackWrapper
      {
         string kycMetadata;
      }
    
    //This method is use to return metadata according to Document type.
    @AuraEnabled
    public static string getMetadata(String documentType)
    {
        GoBackWrapper gw  = new GoBackWrapper();
        //check doc type and return medata data according to it.
        if(documentType == system.Label.AadhaarCard)//'Aadhaar')
        {
            Golden_Source_Input_Output_Fields__mdt metadata =Golden_Source_Input_Output_Fields__mdt.getInstance(system.Label.AadhaarCard);//'Aadhaar');
            gw.kycMetadata = metadata.Output_Fields__c;
            return gw.kycMetadata;
        }
        //check doc type and return medata data according to it.
        else if(documentType == system.Label.DrivingLicences) //'Driving Licence')
        {
            Golden_Source_Input_Output_Fields__mdt metadata =Golden_Source_Input_Output_Fields__mdt.getInstance(system.Label.DrivingLicenceMetadata);//'Driving_Licence');
            gw.kycMetadata = metadata.Output_Fields__c;
            return gw.kycMetadata;
        }
        //check doc type and return medata data according to it.
        else if(documentType == system.Label.VoterIdCard) //'Voter Id')
        {
            Golden_Source_Input_Output_Fields__mdt metadata =Golden_Source_Input_Output_Fields__mdt.getInstance(system.Label.VoterIDMetadata); //'Voter_ID');
            gw.kycMetadata = metadata.Output_Fields__c;
            return gw.kycMetadata;
        }
        //check doc type and return medata data according to it.
        else if(documentType == system.Label.PassportCard) //'Passport')
        {
            Golden_Source_Input_Output_Fields__mdt metadata =Golden_Source_Input_Output_Fields__mdt.getInstance(system.Label.PassportCard); //'Passport');
            gw.kycMetadata = metadata.Output_Fields__c;
            return gw.kycMetadata;
        }
        //check doc type and return medata data according to it.
        else if(documentType == system.Label.PanCard) //'PAN')
        {
            Golden_Source_Input_Output_Fields__mdt metadata =Golden_Source_Input_Output_Fields__mdt.getInstance(system.Label.PanCards); //'PAN');
            gw.kycMetadata = metadata.Output_Fields__c;
            return gw.kycMetadata;
    }
        return gw.kycMetadata;
}
}

// demo commit for using testing 
// demo commit for using testing