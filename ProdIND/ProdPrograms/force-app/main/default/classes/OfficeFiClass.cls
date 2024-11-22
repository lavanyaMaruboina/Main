public class OfficeFiClass {
   @AuraEnabled
    public static Field_Investigation__c getOfficeFIRecord(Id recordId) {
        List<Field_Investigation__c> officeFI = new List<Field_Investigation__c>();
        try {
            officeFI = [SELECT Id,Office_FI_Status__c,Name,Product__c,Address_Line_1__c,Address_Line_2__c,City__c,Pin_Code__c,
            State__c,Phone_Number__c,Mobile__c,Category__c,Profile__c,Current_experience_years__c,Total_Experience_Years__c,
             FI_Request_Generation_Date_Time__c,Residence_FI_Status__c,Office_FI_Completion_Time__c,Case__c,Case__r.Applicant__c,Case__r.Loan_Application__c,Landmark__c,Same_Addresst_as_in_the_Application__c,
              Employer_Business_Name__c,Office_Business_Type__c,Business_Premise__c,Office_Business_Board__c,Office_Business_Size_Sqft__c,
                                       Location__c,Name_of_Person_met__c,Relationship__c,Political_Photo__c,Applicant_Recognized__c,Touring_or_Transferable_Job__c,
                                       Monthly_Income_as_per_FI_Visit__c,Income_as_per_FI_Visit__c,Area__c,Land_Photo__c,
                                       No_of_crops_per_annum__c,Patta_Document_available__c,Type_of_Crop__c,Yield_Per_Acre_monthly__c,
                                       Price_per_unit__c,Income__c,Type_of_House__c,Electricity_Connection_Present__c,Access_to_Tubewells__c,
                                       Irrigation_system_present__c,No_of_Cattle__c,Type_of_goods_sold__c,No_of_Employees__c,Inhouse_Security_Camera_present__c,
                                       POS_Machine__c,AC_Installed__c,Average_no_of_customers__c,Average_Ticket_Size_Rs__c,Number_of_operational_hours_in_a_day__c,
                                       Monthly_Sales__c,Annual_Turnover__c,Profit_Margin__c,Estimated_Income_as_per_FI__c,Declared_Income_During_Application__c,
                                       Final_Income__c,Latest_Water_Bill__c,Payment_Proof_Shown__c,Payment_Proof_shown_for_Electricity_Bill__c,Telephone_Bill_Payment_Proof_Shown__c,Latest_Telephone_Bill_Amount_Paid_Month__c,Latest_Electricity_Bill_Amount_Paid_Mont__c,Own_Equipment_Tools__c,List_of_equipment_tools_owned__c,
                                       Affiliation_to_e_commerce__c,Average_Professional_Fee_Service_Rs__c,No_of_Service_Requests_catered_in_month__c,Estimated_Service_Income_as_per_FI__c,
                                       Types_of_vehicles_owned__c,No_of_vehicles_owned__c,Estimated_Average_Income_per_month__c,No_of_contracts_awarded_in_last_1_year__c,
                                       Do_you_have_any_government_contracts__c,Estimated_Total_Monthly_Income__c,Number_of_Properties_rented__c,Income_per_month_property__c,Income_per_month__c,No_of_Attempts__c,
                                       FI_Observation__c,FI_Feedback__c,Office_FI_Accepted_Rejected__c,Upload_Pension_Document__c,Upload_Rent_Agreement_Reciept__c,
                                       Case__r.Applicant__r.Name,Case__r.Applicant__r.Contact_number__c,Case__r.Applicant__r.Whatsapp_number__c,Case__r.Loan_Application__r.Product_Type__c,FI_Status__c
                                       
                                       
              FROM Field_Investigation__c where Id =: recordId
                          order by LastModifiedDate desc
                          LIMIT 1 ];
                if(officeFI.isEmpty()) {
                return null;
                }
               
            } catch(Exception e){
              ErrorLoggerUtil.logErrorEvent(' OfficeFiClass ', ' getOfficeFIRecord ', 'System.Label.Apex', e);
              throw new AuraHandledException(System.Label.ExceptionMessage);
            }
            return officeFI[0];
    }

    @AuraEnabled
    public static Income_Details__c getIncomeSourceRecord(String applicantId) {
        List<Income_Details__c> incomrecordonOfficeFI = new List<Income_Details__c>();
        try {
            incomrecordonOfficeFI = [SELECT Id, Document_Type__c, Is_Salaried__c, Is_Self_Employed__c, Income_Source__c, Primary_Income_Source__c, Applicant__r.Name, Profile__r.Sub_Bucket_Desc__c,Profile__r.Sub_Bucket_Code__c,Profile__r.Category__c
            FROM Income_Details__c WHERE 
                        Applicant__c =: applicantId 
                        AND Primary_Income_Source__c=true ];  
            if(incomrecordonOfficeFI.isEmpty()) {
            return null;
            }
              
        }  catch(Exception e){
              ErrorLoggerUtil.logErrorEvent(' OfficeFiClass ', ' getIncomeSourceRecord ', 'System.Label.Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        return incomrecordonOfficeFI[0];  
    }
    @AuraEnabled
    public static boolean getUserRole(String caseId){
        try {
            Case objCase = [SELECT Id,Loan_Application__r.AccountId,Loan_Application__r.Product_Type__c,
                            Loan_Application__r.Owner.UserRole.Name FROM Case WHERE Id =:caseId Limit 1];
            AccountTeamMember accTeam = [SELECT ID ,TeamMemberRole,User.Name, Level__c ,Account.id 
                                        FROM AccountTeamMember WHERE Account.id=:objCase.Loan_Application__r.AccountId 
                                        AND UserId=: UserInfo.getUserId()];
            System.debug('accTeam==>'+accTeam);
                if(accTeam.TeamMemberRole == 'FI'){
                return false;
                }
            
        } catch (Exception e) {
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('FIOfficeController', 'getUserRoleforFIOffice', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }  
        return true;     
    }

    /*
    * @Method:      getDocumentRecordId
    * @Created by:  Neha Gosavi
    * @Description: This method is used to get Document recordID of Documnet Type - Other.
    * @Return:      String - document Record Id
    */
    @AuraEnabled
    public static string getDocumentRecordId(){
        try {
            Id otherDocRecordTypeId =  Schema.SObjectType.Documents__c.getRecordTypeInfosByDeveloperName().get('Other_Documents').getRecordTypeId();
            return otherDocRecordTypeId;     
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('OfficeFiClass', ' getDocumentRecordId ', 'Apex', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
}