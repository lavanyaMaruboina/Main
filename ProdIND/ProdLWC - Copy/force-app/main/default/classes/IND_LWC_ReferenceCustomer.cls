/*
    * @Class Name:  Ind_Lwc_ReferenceCustomer
    * @Created by:  Utkarsh Maurya
*/

public without sharing class IND_LWC_ReferenceCustomer {
    

    /*
    * @Method:      getReferenceCustomerOfApplicant
    * @Created by:  Utkarsh Maurya
    * @Description: This method is used to get all reference customers of Applicant.
    * @Return:      List of Customer_Reference__c
    */
    @AuraEnabled(cacheable=true)
    public Static List<Customer_Reference__c> getReferenceCustomerOfApplicant(String applicantId, Boolean refered){
        try {
            List<Customer_Reference__c> customerRefList = new List<Customer_Reference__c>();
            String query = 'SELECT Id, Name , AddressLine1__c, AddressLine2__c, Phone__c, Refered__c, Maker_Date__c, Exposure__c, Product__c, Feedback__c FROM Customer_Reference__c WHERE Applicant__c =: ApplicantId ';
            String conditionQuery = ' ORDER BY Product__c DESC , Exposure__c DESC';
            if(refered==true){
                customerRefList =  (List<Customer_Reference__c>)Database.query(query+' AND Refered__c =:refered' +conditionQuery);
            }
            else{
                customerRefList =  (List<Customer_Reference__c>)Database.query(query+''+conditionQuery);
            }
            
            if(!customerRefList.isEmpty()){
                return customerRefList;     
            }
                return null;
        } catch (Exception e) {
           ErrorLoggerUtil.logErrorEvent('Ind_Lwc_ReferenceCustomer', ' getReferenceCustomerOfApplicant ', 'Apex', e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
    * @Method:      updateReferedCustomerOfApplicant
    * @Created by:  Utkarsh Maurya
    * @Description: This method is used to update field of reference customers.
    * @parameter : List of String and applicant id
    * @Return:      String 
    */
    @AuraEnabled
    public Static String updateReferedCustomerOfApplicant(String customerReferencesResponse , String applicantId){
        try {

            List<Customer_Reference__c> referenceCustomerToUpdate = new List<Customer_Reference__c>();

            List<WrapperResponse> refCustomersList = (List<WrapperResponse>)JSON.deserialize(customerReferencesResponse, List<WrapperResponse>.class );
            
            Map<Id, String> crMap = new Map<Id, String>();
            for(WrapperResponse refDetails : refCustomersList){
                crMap.put(refDetails.Id, refDetails.Feedback);
            }

            if(!refCustomersList.isEmpty()){
                for(Customer_Reference__c customerReferences : [SELECT Id, Name, Refered__c,Feedback__c FROM Customer_Reference__c WHERE Applicant__c=:applicantId]){
                    if(String.isNotBlank(crMap.get(customerReferences.Id))){
                        customerReferences.Refered__c = true;
                        customerReferences.Feedback__c = crMap.get(customerReferences.Id);
                    }
                    else{
                        customerReferences.Refered__c = false;
                        customerReferences.Feedback__c = '';
                    }
                    referenceCustomerToUpdate.add(customerReferences);
                }
            }

            if(!referenceCustomerToUpdate.isEmpty()){
                update referenceCustomerToUpdate;
                return 'SUCCESS';
            }
            else{
                return 'FAILED';
            }
        } catch (Exception e) {

            ErrorLoggerUtil.logErrorEvent('Ind_Lwc_ReferenceCustomer', ' updateReferedCustomerOfApplicant ', 'Apex', e);
          throw new AuraHandledException(e.getMessage());
        }
    }

    public class WrapperResponse{
        public String Id{get;set;}
        public String Feedback{get;set;}
    }

}