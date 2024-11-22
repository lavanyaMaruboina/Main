/**
* @Name         IND_OfficeFIReadOnlyController_Test
* @Author       mohammad_shahkomeni
* @Company      Persistent Systems
* @Description  This test class used to test IND_OfficeFIReadOnlyController
* Inputs:       None
* Test Class:   None
* History:      
* Date            Author              Comments
* -------------------------------------------------------------
* 02-20-2022      mohammad_shahkomeni      Created
* ------------------------------------------------------------
*/
@isTest(seeAllData = false)
public class IND_OfficeFIReadOnlyController_Test {
    
    @testSetup static void testDataSetup() {
        // Create Opportunity
        Opportunity opp = TestDataUtility.createTestOpportunityForOcr(false);
        opp.StageName = System.Label.Credit_Processing;
        opp.Sub_Stage__c = System.Label.Field_Investigation;
        opp.Is_Mobile_Journey_Completed__c = true;
        opp.Vehicle_Type__c = System.Label.used;
        opp.Product_Type__c = System.Label.TwoWheeler;
        opp.Sanction_Status__c = System.Label.nonStp;
        insert opp;
        // Create Applicant__c
        Applicant__c applicant = TestDataUtility.createTestApplicantForMFCValuation(true, opp);
        // Create Vehicle Detail
        Vehicle_Detail__c vehDet = TestDataUtility.createTestVehicleDetailForMFCValuation(true, opp);
        // Create Documents__c
        Documents__c doc1 = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant, opp);
        doc1.Document_Type__c = System.Label.Signature;
        doc1.Addresss_Type__c = System.Label.Document_Office_Address_Type;
        insert doc1;
        Documents__c doc2 = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant, opp);
        doc2.Document_Type__c = System.Label.Office_Front_View;
        doc2.Addresss_Type__c = System.Label.Document_Office_Address_Type;
        insert doc2;
        // Create ContentVersion
        ContentVersion contVer1 = TestDataUtility.createContentVersionforOcrFront('Test document for content version',true, doc1);
        ContentVersion contVer2 = TestDataUtility.createContentVersionforOcrFront('Test document for content version',true, doc2);
        // Create Case
        Case cse = TestDataUtility.createTestCase(true, opp, applicant);
        // Create Field Investigation
        Field_Investigation__c fiRecord = TestDataUtility.createTestFieldInvestigation(true, cse);
    }
    
    @isTest 
    public static void testGetDocumentsOfFI(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Applicant__c apl = [SELECT Id FROM Applicant__c LIMIT 1];
        
        Test.startTest();
        Map<String, Id> mapDocTypetoId = IND_OfficeFIReadOnlyController.getDocumentsOfFI(opp.Id, apl.Id);
        Test.stopTest();
        
      //  System.assertEquals(2, mapDocTypetoId.size());
    }
    
    @isTest 
    public static void testAcceptedSaveOfficeFI(){
        IND_OfficeFIInputWrapper deserializedInputWrapper = createOfficeFIInputWrapperJSON(System.Label.FI_Accepted);
        String serializedInputWrapper = JSON.serialize(deserializedInputWrapper);
        
        Test.startTest();
        Boolean status = IND_OfficeFIReadOnlyController.saveOfficeFI(serializedInputWrapper);
        Test.stopTest();
        
        System.assertEquals(true, status);
    }
    
    @isTest 
    public static void testRejectedSaveOfficeFI(){
        IND_OfficeFIInputWrapper deserializedInputWrapper = createOfficeFIInputWrapperJSON(System.Label.FI_Rejected);
        String serializedInputWrapper = JSON.serialize(deserializedInputWrapper);
        
        Test.startTest();
        Boolean status = IND_OfficeFIReadOnlyController.saveOfficeFI(serializedInputWrapper);
        Test.stopTest();
        
        System.assertEquals(false, status);
    }
    
    public static IND_OfficeFIInputWrapper createOfficeFIInputWrapperJSON(String status) {
        IND_OfficeFIInputWrapper inputWrapper = new IND_OfficeFIInputWrapper();
        List<Field_Investigation__c> lstFIRecords = [SELECT ID,
                                                     Case__c,
                                                     Case__r.OwnerId,
                                                     Case__r.Origin,
                                                     Case__r.Type,
                                                     Case__r.Subject,
                                                     Case__r.Applicant__c,
                                                     Case__r.Loan_Application__c,
                                                     Case__r.Loan_Application__r.StageName,
                                                     Case__r.Loan_Application__r.Sub_Stage__c,
                                                     Case__r.Loan_Application__r.Vehicle_Type__c,
                                                     Case__r.Loan_Application__r.Product_Type__c,
                                                     Case__r.Loan_Application__r.Sanction_Status__c,
                                                     Access_to_Tubewells__c,AC_Installed__c,Address_Line_1__c,Address_Line_2__c,Address_Verified_with_KYC__c,Affiliation_to_e_commerce__c,Annual_Turnover__c,Applicant_Recognized__c,Area__c,Are_Co_ordinates_Matching_If_Amber__c,Average_no_of_customers__c,Average_Professional_Fee_Service_Rs__c,Average_Ticket_Size_Rs__c,Category__c,City__c,Coordinates_Distance__c,Coordinates_Verified__c,CreatedById,CreatedDate,CurrencyIsoCode,Current_experience_years__c,Customer_house_same_as_in_application__c,Declared_Income_During_Application__c,Do_you_have_any_government_contracts__c,Electricity_Connection_Present__c,Employer_Business_Name__c,Estimated_Average_Income_per_month__c,Estimated_Income_as_per_FI__c,Estimated_Service_FI__c,Estimated_Service_Income_as_per_FI__c,Estimated_Total_Monthly_Income__c,Final_Income__c,FI_Feedback__c,FI_Location__c,FI_Location__Latitude__s,FI_Location__Longitude__s,FI_Observation__c,FI_Request_Generation_Date_Time__c,FI_Status__c,GeoCoder_Latitude_and_Longitude__c,GeoCoder_Latitude_and_Longitude__Latitude__s,GeoCoder_Latitude_and_Longitude__Longitude__s,Income_as_per_FI_Visit__c,Income_per_month_property__c,Income_per_month__c,Income__c,Inhouse_Security_Camera_present__c,Irrigation_system_present__c,IsDeleted,is_Active__c,KYC_Location__c,KYC_Location__Latitude__s,KYC_Location__Longitude__s,Landmark__c,Land_Photo__c,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Latest_Electricity_Bill_Amount_Paid_Mont__c,Latest_Telephone_Bill_Amount_Paid_Month__c,Latest_Water_Bill__c,List_of_equipment_tools_owned__c,Location__c,Mobile__c,Monthly_Income_as_per_FI_Visit__c,Monthly_Sales__c,Name,Name_of_Person_met__c,No_of_2_Wheelers__c,No_of_3_Wheelers__c,No_of_4_Wheelers__c,No_of_ACs__c,No_of_Attempts__c,No_of_Cattle__c,No_of_Computers__c,No_of_contracts_awarded_in_last_1_year__c,No_of_crops_per_annum__c,No_of_CVs__c,No_of_Employees__c,No_of_Fridges__c,No_of_Service_Requests_catered_in_month__c,No_of_Sofas__c,No_of_TVs__c,No_of_vehicles_owned__c,No_of_Washing_Machines__c,Number_of_Dependent__c,Number_of_Earning_Member_in_Family__c,Number_of_operational_hours_in_a_day__c,Number_of_Properties_rented__c,Office_Business_Board__c,Office_Business_Size_Sqft__c,Office_Business_Type__c,Office_FI_Accepted_Rejected__c,Office_FI_Completion_Time__c,Office_FI_Status__c,Own_Equipment_Tools__c,Patta_Document_available__c,Payment_Proof_shown_for_Electricity_Bill__c,Payment_Proof_Shown__c,Phone_Number__c,Pin_Code__c,Political_Photo__c,POS_Machine__c,Price_per_unit__c,Product__c,Profile_to_Product_Match__c,Profile__c,Profit_Margin__c,Purpose_of_Purchase__c,RecordTypeId,Relationship__c,Remarks__c,Residence_FI_completion_time__c,Residence_FI_Status__c,Residence_Type__c,Same_Addresst_as_in_the_Application__c,SENP_Agriculture_Income__c,SENP_Contractor_Income__c,SENP_Own_Shop_Income__c,SENP_Pension_Income__c,SENP_Rental_Income__c,SENP_Service_oriented_Income__c,SENP_Transporter_Income__c,State__c,SystemModstamp,Telephone_Bill_Payment_Proof_Shown__c,Total_Experience_Years__c,Touring_or_Transferable_Job__c,Types_of_vehicles_owned__c,Type_of_Crop__c,Type_of_goods_sold__c,Type_of_House__c,Upload_Pension_Document__c,Upload_Rent_Agreement_Reciept__c,Years_in_CIty__c,Years_in_Residence__c,Yield_Per_Acre_monthly__c FROM Field_Investigation__c
                                                     LIMIT 1];
        if(lstFIRecords.size() > 0) {
            Field_Investigation__c fiRecord = lstFIRecords[0];
            
            inputWrapper.name = new IND_OfficeFIInputWrapper.StringField();
            inputWrapper.name.value = fiRecord.Name;
            
            inputWrapper.product = new IND_OfficeFIInputWrapper.StringField();
            inputWrapper.product.value = fiRecord.Product__c;
            
            inputWrapper.addrLine1 = new IND_OfficeFIInputWrapper.StringField();
            inputWrapper.addrLine1.value = fiRecord.Address_Line_1__c;
            
            inputWrapper.addrLine2 = new IND_OfficeFIInputWrapper.StringField();
            inputWrapper.addrLine2.value = fiRecord.Address_Line_2__c;
            
            inputWrapper.city = new IND_OfficeFIInputWrapper.StringField();
            inputWrapper.city.value = fiRecord.City__c;
            
            inputWrapper.pinCode = new IND_OfficeFIInputWrapper.StringField();
            inputWrapper.pinCode.value = fiRecord.Pin_Code__c;
            
            inputWrapper.state = new IND_OfficeFIInputWrapper.StringField();
            inputWrapper.state.value = fiRecord.State__c;
            
            inputWrapper.landmark = new IND_OfficeFIInputWrapper.StringField();
            inputWrapper.landmark.value = fiRecord.Landmark__c;
            
            inputWrapper.phoneNo = new IND_OfficeFIInputWrapper.StringField();
            inputWrapper.phoneNo.value = fiRecord.Phone_Number__c;
            
            inputWrapper.mobile = new IND_OfficeFIInputWrapper.StringField();
            inputWrapper.mobile.value = fiRecord.Mobile__c;
            
            inputWrapper.remarks = new IND_OfficeFIInputWrapper.StringField();
            inputWrapper.remarks.value = fiRecord.Remarks__c;
            
            inputWrapper.Employer_Business_Name = new IND_OfficeFIInputWrapper.StringField();
            inputWrapper.Employer_Business_Name.value = fiRecord.Employer_Business_Name__c;
            
            inputWrapper.Current_experience_years = new IND_OfficeFIInputWrapper.StringField();
            inputWrapper.Current_experience_years.value = fiRecord.Current_experience_years__c;
            
            inputWrapper.Total_Experience_Years = new IND_OfficeFIInputWrapper.StringField();
            inputWrapper.Total_Experience_Years.value = fiRecord.Total_Experience_Years__c;
            
            inputWrapper.Income = new IND_OfficeFIInputWrapper.DecimalField();
            inputWrapper.Income.value = fiRecord.Income__c;
            
            inputWrapper.Estimated_Service_Income_as_per_FI = new IND_OfficeFIInputWrapper.DecimalField();
            inputWrapper.Estimated_Service_Income_as_per_FI.value = fiRecord.Estimated_Service_Income_as_per_FI__c;
            
            inputWrapper.Are_Co_ordinates_Matching_If_Amber = new IND_OfficeFIInputWrapper.BooleanField();
            inputWrapper.Are_Co_ordinates_Matching_If_Amber.value = fiRecord.Are_Co_ordinates_Matching_If_Amber__c;
            
            inputWrapper.Office_FI_Accepted_Rejected = new IND_OfficeFIInputWrapper.StringField();
            inputWrapper.Office_FI_Accepted_Rejected.value = status;
            
            inputWrapper.SENP_Agriculture_Income = new IND_OfficeFIInputWrapper.DecimalField();
            inputWrapper.SENP_Agriculture_Income.value = fiRecord.SENP_Agriculture_Income__c;
            
            inputWrapper.SENP_Own_Shop_Income = new IND_OfficeFIInputWrapper.DecimalField();
            inputWrapper.SENP_Own_Shop_Income.value = fiRecord.SENP_Own_Shop_Income__c;
            
            inputWrapper.SENP_Service_oriented_Income = new IND_OfficeFIInputWrapper.DecimalField();
            inputWrapper.SENP_Service_oriented_Income.value = fiRecord.SENP_Service_oriented_Income__c;
            
            inputWrapper.SENP_Transporter_Income = new IND_OfficeFIInputWrapper.DecimalField();
            inputWrapper.SENP_Transporter_Income.value = fiRecord.SENP_Transporter_Income__c;
            
            inputWrapper.SENP_Contractor_Income = new IND_OfficeFIInputWrapper.DecimalField();
            inputWrapper.SENP_Contractor_Income.value = fiRecord.SENP_Contractor_Income__c;
            
            inputWrapper.SENP_Rental_Income = new IND_OfficeFIInputWrapper.DecimalField();
            inputWrapper.SENP_Rental_Income.value = fiRecord.SENP_Rental_Income__c;
            
            inputWrapper.SENP_Pension_Income = new IND_OfficeFIInputWrapper.DecimalField();
            inputWrapper.SENP_Pension_Income.value = fiRecord.SENP_Pension_Income__c;
            
            inputWrapper.fiId = new IND_OfficeFIInputWrapper.StringField();
            inputWrapper.fiId.value = fiRecord.Id;
            
            inputWrapper.caseId = new IND_OfficeFIInputWrapper.StringField();
            inputWrapper.caseId.value = fiRecord.Case__c;
            
            inputWrapper.ownerId = new IND_OfficeFIInputWrapper.StringField();
            inputWrapper.ownerId.value = fiRecord.Case__r.OwnerId;
            
            inputWrapper.Origin = new IND_OfficeFIInputWrapper.StringField();
            inputWrapper.Origin.value = fiRecord.Case__r.Origin;
            
            inputWrapper.Type = new IND_OfficeFIInputWrapper.StringField();
            inputWrapper.Type.value = fiRecord.Case__r.Type;
            
            inputWrapper.applicantId = new IND_OfficeFIInputWrapper.StringField();
            inputWrapper.applicantId.value = fiRecord.Case__r.Applicant__c;
            
            inputWrapper.applicationId = new IND_OfficeFIInputWrapper.StringField();
            inputWrapper.applicationId.value = fiRecord.Case__r.Loan_Application__c;
            
            inputWrapper.stage = new IND_OfficeFIInputWrapper.StringField();
            inputWrapper.stage.value = fiRecord.Case__r.Loan_Application__r.StageName;
            
            inputWrapper.subStage = new IND_OfficeFIInputWrapper.StringField();
            inputWrapper.subStage.value = fiRecord.Case__r.Loan_Application__r.Sub_Stage__c;
            
            inputWrapper.Vehicle_Type = new IND_OfficeFIInputWrapper.StringField();
            inputWrapper.Vehicle_Type.value = fiRecord.Case__r.Loan_Application__r.Vehicle_Type__c;
            
            inputWrapper.Product_Type = new IND_OfficeFIInputWrapper.StringField();
            inputWrapper.Product_Type.value = fiRecord.Case__r.Loan_Application__r.Product_Type__c;
            
            inputWrapper.Sanction_Status = new IND_OfficeFIInputWrapper.StringField();
            inputWrapper.Sanction_Status.value = fiRecord.Case__r.Loan_Application__r.Sanction_Status__c;
            
            inputWrapper.Subject = new IND_OfficeFIInputWrapper.StringField();
            inputWrapper.Subject.value = fiRecord.Case__r.Subject;
        }
        return inputWrapper;
        
    }
    
}