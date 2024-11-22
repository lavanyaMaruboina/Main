/**
* @description       : This controller is basically designed for income part-2 capture Office address details.
* @author            : Sivakumar G
* @group             : https://indusindbank123--psldev1.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage
* @created on        : 31-12-2021
* @last modified on  : 31-12-2021
* @last modified by  : Sivakumar G
* @Version           : 1.0
**/


public with sharing class Ind_ApplicantService {
	
    /*
    * @Method:      getApplicantCurrentResidentialAddress
    * @Created by:  Nidhi Dhote
    * @Description: Method to return  all office address details
    * @Param:       String - oppId
    * @Return:     Documents__c
    */ 
    //Getting current address from Applicant with document
    @AuraEnabled
    public static Documents__c getApplicantCurrentResidentialAddress(String applicantId) {
        try{
            List<Documents__c> doc = [SELECT Id, Name, KYC_name__c, Applicant__c, Document_Type__c, KYC_Address_Line_1__c, KYC_Address_Line_2__c, KYC_Pin_Code__c, KYC_City__c, KYC_District__c, KYC_State__c, Current_Residential_Address_Proof__c FROM Documents__c WHERE Applicant__c =:applicantId AND Current_Residential_Address_Proof__c= true WITH SECURITY_ENFORCED Limit 1];
            return doc[0];
        }
        catch (Exception e) {
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('Ind_ApplicantService', ' getApplicantCurrentResidentialAddress ', System.Label.Apex, e);  
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
            Office_State__c = officeDetailData.State,
            Is_this_Current_Residence_Cum_office__c = officeDetailData.checkboxVal,
            IsOfficeAddressSubmitted__c = officeDetailData.isOfficeAddressSubmitted);

            income.Id = [Select id, Primary_Income_Source__c FROM Income_Details__c WHERE Applicant__c =: officeDetailData.applicantId AND Primary_Income_Source__c = true limit 1].Id;
            if(Schema.sObjectType.Income_Details__c.isUpdateable()){ 
                update income;
            }
            if(Test.isRunningTest()){
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
            return 'Success';   
        } catch (Exception e) {
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('Ind_ApplicantService', ' currentAddressCumOfficeCheckbox ', System.Label.Apex, e);  
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
        public String state { get; set; }
        public String contactNumber { get; set; }
        public Boolean checkboxVal {get;set;}
        public Boolean isOfficeAddressSubmitted{get;set;}
        
    }
    
    /*
    * @Method:      updatePrimaryIncomeSource
    * @Created by:  Nidhi Dhote
    * @Description: Updating Primary Income Source
    * @Param:       String - Applicant Id
    * @Return:      Void
    */ 
    @AuraEnabled
    public static Void updatePrimaryIncomeSource(String applicantId){ 
        try{
            String primarySourceCategory ='';//CISP-2560

            System.debug('Applicant Id:: '+applicantId);
            List<Income_Details__c> incomeDetailsList = [select Primary_Income_Source__c,Profile__r.Category__c FROM Income_Details__c where Applicant__c =: applicantId  order by Income__c DESC limit 1];
            System.debug('Income Obj:: '+incomeDetailsList);

            if(!incomeDetailsList.isEmpty()){ 
                incomeDetailsList[0].Primary_Income_Source__c = true;
                primarySourceCategory = incomeDetailsList[0].Profile__r.Category__c;//CISP-2560

                if (Schema.sObjectType.Applicant__c.isUpdateable()){
                    update incomeDetailsList; 
                }
                //CISP-2560
                List<Applicant__C> appList = [Select Id,Customer_Category__c,Income_source_available__c from Applicant__c where Id =: applicantId];
                if(!appList.isEmpty()){
                    if(appList[0].Income_source_available__c){
                        appList[0].Customer_Category__c = primarySourceCategory;
                    }else{
                        appList[0].Customer_Category__c = 'NE';
                    }
                }
                if (Schema.sObjectType.Applicant__c.isUpdateable()){
                    update appList; 
                }
                //CISP-2560
            }
        } catch(Exception e){
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('Ind_ApplicantService', ' updatePrimaryIncomeSource ', System.Label.Apex, e);  
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
            }        
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    

    /*
    * @Method:      getSavedDetails
    * @Created by:  Khushiram
    * @Description: To fetch the saved details.
    * @Param:       String: applicantId
    * @Return:      String : WrapperObject
    */ 

    @AuraEnabled
    public static string getSavedDetails(String applicantId,String loanApplicationId){
        try {
            SavedDetailsWrapper responseJSON = new SavedDetailsWrapper();
            Opportunity oppObj=[ SELECT Id,Lead_number__c,Product_Type__c, Vehicle_Type__c,Vehicle_Sub_Category__c, Parent_Deal_number__c,Vehicle_Registration_Number__c, LastStageName__c, StageName FROM Opportunity WHERE Id =: loanApplicationId WITH SECURITY_ENFORCED limit 1];

            List<Income_Details__c> listOfIncomeObj = [Select Primary_Income_Source__c,Employer_Business_Name__c,Office_Address_Line_1__c,Office_Address_Line_2__c,Office_District__c,Office_State__c,Office_PinCode__c,Office_City__c,Is_this_Current_Residence_Cum_office__c, IsOfficeAddressSubmitted__c from Income_Details__c where Applicant__c =: applicantId WITH SECURITY_ENFORCED];
            for(Income_Details__c incObj : listOfIncomeObj){
                if(incObj.Primary_Income_Source__c){
                    responseJSON.isOfficeCumCheckbox = incObj.Is_this_Current_Residence_Cum_office__c;
                    responseJSON.addLineOne = incObj.Office_Address_Line_1__c ;
                    responseJSON.addLineTwo =incObj.Office_Address_Line_2__c ;
                    responseJSON.state = incObj.Office_State__c;
                    responseJSON.district = incObj.Office_District__c;
                    responseJSON.city = incObj.Office_City__c;
                    responseJSON.pinCode = incObj.Office_PinCode__c;
                    responseJSON.employerName = incObj.Employer_Business_Name__c;
                    responseJSON.isOfficeAddressSubmitted = incObj.IsOfficeAddressSubmitted__c;
                }
            }

            if(oppObj != null){

                responseJSON.lastStage=oppObj.LastStageName__c;
                responseJSON.currentStageName=oppObj.StageName;
            }

            String serializedResonponse = JSON.serialize(responseJSON);
            return serializedResonponse;
        } catch (Exception e) {
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('Ind_ApplicantService', ' getSavedDetails ', System.Label.Apex, e);  
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
            }        
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    //Wrapper class for getSavedDetails method.
    public class SavedDetailsWrapper{  
        public Boolean isOfficeCumCheckbox {get;set;}      
        public String employerName {get;set;} 
        public String addLineOne {get;set;}
        public String addLineTwo {get;set;}
        public String state {get;set;}
        public String district {get;set;}
        public String city {get;set;}
        public String pinCode {get;set;} 
        String lastStage {get;set;}
        String currentStageName {get;set;}
        public Boolean isOfficeAddressSubmitted{get;set;}    

    }

}