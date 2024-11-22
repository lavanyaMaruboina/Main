/*------------------------------------------------------------
Author:        Manish Baldota
Company:       Persistent Systems
Description:   This class is used to provide the details to the FI case page lWC component.
Test Class:    
History
Date            Author              Comments
-------------------------------------------------------------
25-04-2022      Manish Baldota       Created
------------------------------------------------------------*/
public with sharing class IND_LWC_FICasePageCntrl {
    // @Method:      handleChangeOwnerProcess
    // @Created by:  Manish Baldota
    // @Description: Method to handle the business logic of CMU owner change.
    // @Param:       String : caseId  
    // @Return:  
    @AuraEnabled(cacheable = true)
    public static Field_Investigation__c getFIRecord(String caseId){
        try{
            if(String.isNotBlank(caseId)){
                List<Field_Investigation__c> fieldInvestiagationList = [SELECT Id, RecordType.Name,Case__r.Loan_Application__r.Product_Type__c,Case__r.Product_Type__c FROM Field_Investigation__c
                                                                        WHERE Case__c =: caseId LIMIT 1];
                if(!fieldInvestiagationList.isEmpty()){
                    return fieldInvestiagationList[0];
                }else{
                    throw new IND_Exception('Field Investigation Details are not available, Please contact your administrator.');
                }
            }else{
                throw new IND_Exception('Something went wrong, Please contact your administator.');
            }
        }Catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('getFIID', 'IND_LWC_FICasePageCntrl', System.Label.Apex, e, '');
            throw new IND_Exception(e.getMessage());
        }
        
    }
}