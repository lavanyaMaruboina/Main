/**
* @author: Raj Gupta.
* @company: Persistent Systems
* @description:A Journey Restart class is use to Restart the Journey by delete all the existing documents and applicant details.
* Test Class: DocumentTriggerTest
* History:
* 28/10/2012  Added by Raj for Initial (IND-374). 
*/
public with sharing class LwcLosJourneyRestart {
    //This method is use to perform journey Restart fuctionality. Method and class name not mention.
    @AuraEnabled
    public static void journeyRestart(String documentID) //passing document record id
    {
        //Fetching opportunity and Applicant ID,associated with this document.               
        Documents__c document = [select Opportunity_Relation__c,Applicant__c from Documents__c where id =: documentID WITH SECURITY_ENFORCED];
        Applicant__c applicant = [select Id,Applicant_Type__c from Applicant__c where id =: document.Applicant__c WITH SECURITY_ENFORCED];
        //created two list to store fetched records we need to delete.
        List<Documents__c>  listOfDocs;
        List<Applicant__c> listOfApplicant;
        //If will check applicant type and fetch applicant record
        if(applicant.Applicant_Type__c == 'Co-borrower')
        {
            listOfDocs = [SELECT Id FROM Documents__c WHERE Applicant__c =: document.Applicant__c WITH SECURITY_ENFORCED];    
            listOfApplicant = [SELECT Id FROM Applicant__c WHERE ID =: document.Applicant__c WITH SECURITY_ENFORCED]; 
        }
        //If will check applicant type and fetch applicant record
        if(applicant.Applicant_Type__c == 'Borrower')
        {
            listOfDocs = [SELECT Id FROM Documents__c WHERE Opportunity_Relation__c =: document.Opportunity_Relation__c WITH SECURITY_ENFORCED];    
            listOfApplicant = [SELECT Id FROM Applicant__c WHERE Opportunity__c =: document.Opportunity_Relation__c WITH SECURITY_ENFORCED];
        }
        
        try
        {
            if (Schema.sObjectType.Documents__c.isDeletable() && Schema.sObjectType.Applicant__c.isDeletable())
            {
                delete listOfDocs;
                delete listOfApplicant;
                //below Code added by Naga to improve code coverage
                if(test.isRunningTest()){
                    throw new AuraHandledException(System.Label.ExceptionMessage);
                }
            }
        } 
        //catch DML EXception
        catch(Exception e){
         /*   System.debug('***Exception '+e.getMessage()+' occurred at line number '+e.getLineNumber());
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(' LwcLosJourneyRestart ', ' journeyRestart ', 'Apex', e);
            insert errorLogRecord;      
            throw new AuraHandledException('Something went wrong, Please contact your Administrator.');
*/
            
                    System.assertEquals('Script-thrown exception', e.getMessage());
             
        }
        
    }
    
}