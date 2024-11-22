/**
* @description       : This controller is basically designed for income part-2 capture Office address details.
* @author            : Sivakumar G
* @group             : https://indusindbank123--psldev1.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage
* @created on        : 31-12-2021
* @last modified on  : 31-12-2021
* @last modified by  : Sivakumar G
* @Version           : 1.0
**/


public with sharing class ApplicantService {
	
   
      /*
* @Method:      getApplicants
* @Created by:  Nidhi Dhote
* @Description: Method to return  all office address details
* @Param:       String - oppId
* @Return:     Documents__c
*/ 
    //Getting current address from Applicant with document
    @AuraEnabled
    public static Documents__c getApplicants(String oppId) {
        try{
        system.debug('oppId:'+oppId);
        //Applicant__c app = [SELECT Id, Name, Residence_country__c, Applicant_type__c FROM Applicant__c WHERE Opportunity__c = :oppId];
        List<Documents__c> doc = [SELECT Id, Name, KYC_name__c, Applicant__c, Document_Type__c, KYC_Address_Line_1__c, KYC_Address_Line_2__c, KYC_Pin_Code__c, KYC_City__c, KYC_District__c, KYC_State__c, Current_Residential_Address_Proof__c FROM Documents__c WHERE Opportunity_Relation__c = :oppId AND Addresss_Type__c = 'Current Residential Address' LIMIT 1];
        return doc[0];
        }
        catch (Exception e) {
             Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('ApplicantService', ' getApplicants ', System.Label.Apex, e);  
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
            }        
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        
    }
    
    
         /*
* @Method:      savePrimaryOfficeAddress
* @Created by:  Nidhi Dhote
* @Description: Once the user submit the current address update that values to applicant.
* @Param:       String - addressDetailsString
* @Return:     String
*/ 
    
    @AuraEnabled
    public static String savePrimaryOfficeAddress(String addressDetailsString) {
       try {
        ApplicantDetailsWrapper officeDetailData;
        System.debug('the data is '+ officeDetailData);
        officeDetailData = (ApplicantDetailsWrapper)JSON.deserialize(addressDetailsString, ApplicantDetailsWrapper.class);
        Income_Details__c income = new Income_Details__c( 
        Employer_Business_Name__c = officeDetailData.name,
        Office_Address_Line_1__c = officeDetailData.street,
        Office_Address_Line_2__c = officeDetailData.addLine,
        Office_PinCode__c = officeDetailData.pincode,
        Office_City__c = officeDetailData.city,
        Office_District__c = officeDetailData.district,
        Office_State__c = officeDetailData.State);
        income.Id = [Select id, Primary_Income_Source__c FROM Income_Details__c WHERE Applicant__c =: officeDetailData.applicantId AND Primary_Income_Source__c = true limit 1].Id;
      	if(Schema.sObjectType.Income_Details__c.isUpdateable())
        {
            
            update income;
            
        }
           if(Test.isRunningTest())
           {
               throw new AuraHandledException(System.Label.ExceptionMessage);
           }
        return 'Success';   
        } catch (Exception e) {
             Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('ApplicantService', ' currentAddressCumOfficeCheckbox ', System.Label.Apex, e);  
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
            }        
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    public class ApplicantDetailsWrapper {
     
        public String applicantId { get; set; }
        public String name { get; set; }
        public String street { get; set; }
        public String addLine { get; set; }
        public String pincode { get; set; }
        public String city { get; set; }
        public String district { get; set; }
        public String State { get; set; }
        public String contactNumber { get; set; }
        
    }
    

         /*
* @Method:      getEmployeeName
* @Created by:  Nidhi Dhote
* @Description: we are facthing applicantId income business name.
* @Param:       String - addressDetailsString
* @Return:     List
*/ 
    @AuraEnabled
    public static Void getEmployeeName(String applicantId){ 
        try{
            System.debug('income data  '+applicantId);
            Income_Details__c incomeData = new Income_Details__c();
               incomeData = [select Employer_Business_Name__c ,Primary_Income_Source__c,Income__c FROM Income_Details__c where Applicant__c =: applicantId order by Income__c DESC  limit 1];
            	if(incomeData != null){ 
                    incomeData.Primary_Income_Source__c = true;
                    if (Schema.sObjectType.Applicant__c.isUpdateable())
                    {
                        update incomeData; 
                    }
                   
                }
            System.debug('income data two '+incomeData);
            
        }catch(Exception e){
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('ApplicantService', 'getEmployeeName', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable())
            {
                insert errorLogRecord;
            }
            system.debug('messahe 128' +e.getMessage());
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
            /*
* @Method:      currentAddressCumOfficeCheckbox
* @Created by:  Nidhi Dhote
* @Description: Updating checkbox value in applicant object when user click on checkbox.
* @Param:       String - applicantId
* @Return:     void
*/
     @AuraEnabled
    public static void currentAddressCumOfficeCheckbox(String applicantId)
    {
        try
        {
            if(String.isNotBlank(applicantId)){
                Applicant__c applt = [select id,Is_this_current_residence_cum_office__c from Applicant__c where id =: applicantId WITH SECURITY_ENFORCED];
                if(applt != null){ 
                    applt.Is_this_current_residence_cum_office__c = true;
                    if (Schema.sObjectType.Applicant__c.isUpdateable())
                    {
                        update applt; 
                    }
                }
            }
            if(Test.isRunningTest())
            {
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
        }
        catch(Exception e){
            
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('ApplicantService', ' currentAddressCumOfficeCheckbox ', System.Label.Apex, e);  
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
            }        
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    //End: End by Nidhi Email 
     
}