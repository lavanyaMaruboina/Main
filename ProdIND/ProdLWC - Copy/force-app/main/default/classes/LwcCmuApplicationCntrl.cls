//This class is created for CMU.
public with sharing class LwcCmuApplicationCntrl {
    
    /*Returing the list of documents for which submit_to_cmu is true.
        Added by Khushiram
        IND-368
    */
    @AuraEnabled(cacheable=true)
    public static List<Documents__c> cmuDocumentRelatedList(String loanApplicationId){
        //Fetching the list of documents for which submit_to_cmu is true.
        List<Documents__c> listOfDocs = [select Name,Document_Type__c,Applicant__r.Name,Applicant__r.Applicant_Type__c,
                                         Document_Side__c,Is_this_a_Photocopy__c,
                                         Proof_of_Address_POA__c,Proof_of_Identity_POI__c 
                                         from Documents__c where Submit_to_CMU__c = true 
                                         AND Opportunity_Relation__c =: loanApplicationId WITH SECURITY_ENFORCED];

    	return listOfDocs;
    }
    //End of cmuDocumentRelatedList.
    
}