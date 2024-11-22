/**
* @Name         IND_OfficeFIPDFController
* @Author       mohammad_shahkomeni
* @Company      Persistent Systems
* @Description  This class used to generate Office FI PDF File
* Inputs:       None
* Test Class:   IND_OfficeFIPDFController_Test
* History:      
* Date            Author              Comments
* -------------------------------------------------------------
* 02-20-2022      mohammad_shahkomeni      Created
* ------------------------------------------------------------
*/
public class IND_OfficeFIPDFController {
    
    public IND_OfficeFIInputWrapper inputWrapper {get; set;}
    public String fiAccordionTitle {get; set;}
    
    /*
* @Method:      IND_OfficeFIPDFController
* @Created by:  mohammad_shahkomeni
* @Description: This constructor will get all Field Investigation fields and return the response back to VF Page
* @Param:       void
* @Return:      void
*/
    public IND_OfficeFIPDFController() {
        String fiId = ApexPages.currentPage().getParameters().get('fiId');
        System.debug('fiId :- '+fiId);
        List<Field_Investigation__c> lstFIRecords = [SELECT ID,
                                                     FI_Status__c,
                                                     Office_FI_completion_time__c,
                                                     Name,
                                                     Product__c,
                                                     Case__c,
                                                     Address_Line_1__c,
                                                     Address_Line_2__c,
                                                     City__c,
                                                     Pin_Code__c,
                                                     State__c,
                                                     Landmark__c,
                                                     Phone_Number__c,
                                                     Mobile__c,
                                                     Same_Addresst_as_in_the_Application__c,
                                                     GeoCoder_Latitude_and_Longitude__Latitude__s,
                                                     GeoCoder_Latitude_and_Longitude__Longitude__s,
                                                     Coordinates_Verified__c,
                                                     Are_Co_ordinates_Matching_If_Amber__c,
                                                     FI_Location__Latitude__s,
                                                     FI_Location__Longitude__s,
                                                     Employer_Business_Name__c,
                                                     Office_Business_Type__c,
                                                     Business_Premise__c,
                                                     Office_Business_Board__c,
                                                     Office_Business_Size_Sqft__c,
                                                     Location__c,
                                                     Name_of_Person_met__c,
                                                     Relationship__c,
                                                     Political_Photo__c,
                                                     Category__c,
                                                     Profile__c,
                                                     Applicant_Recognized__c,
                                                     Touring_or_Transferable_Job__c,
                                                     Monthly_Income_as_per_FI_Visit__c,
                                                     Current_experience_years__c,
                                                     Total_Experience_Years__c,
                                                     Income_as_per_FI_Visit__c,
                                                     Area__c,
                                                     Land_Photo__c,
                                                     Patta_Document_available__c,
                                                     No_of_crops_per_annum__c,
                                                     Type_of_Crop__c,
                                                     Yield_Per_Acre_monthly__c,
                                                     Price_per_unit__c,
                                                     Income__c,
                                                     Type_of_House__c,
                                                     Electricity_Connection_Present__c,
                                                     Access_to_Tubewells__c,
                                                     Irrigation_system_present__c,
                                                     No_of_Cattle__c,
                                                     Type_of_goods_sold__c,
                                                     No_of_Employees__c,
                                                     Inhouse_Security_Camera_present__c,
                                                     POS_Machine__c,
                                                     AC_Installed__c,
                                                     Average_no_of_customers__c,
                                                     Average_Ticket_Size_Rs__c,
                                                     Number_of_operational_hours_in_a_day__c,
                                                     Monthly_Sales__c,
                                                     Annual_Turnover__c,
                                                     Profit_Margin__c,
                                                     Estimated_Income_as_per_FI__c,                                                   
                                                     Final_Income__c,
                                                     Latest_Water_Bill__c,
                                                     Latest_Electricity_Bill_Amount_Paid_Mont__c,
                                                     Latest_Telephone_Bill_Amount_Paid_Month__c,
                                                     Payment_Proof_Shown__c,
                                                     Own_Equipment_Tools__c,
                                                     List_of_equipment_tools_owned__c,
                                                     Affiliation_to_e_commerce__c,
                                                     Average_Professional_Fee_Service_Rs__c,
                                                     No_of_Service_Requests_catered_in_month__c,
                                                     Estimated_Service_Income_as_per_FI__c,
                                                     Declared_Income_During_Application__c,
                                                     Types_of_vehicles_owned__c,
                                                     No_of_vehicles_owned__c,
                                                     Estimated_Average_Income_per_month__c,                                                    
                                                     No_of_contracts_awarded_in_last_1_year__c,
                                                     Do_you_have_any_government_contracts__c,
                                                     Estimated_Total_Monthly_Income__c,                                                   
                                                     Number_of_Properties_rented__c,
                                                     Income_per_month_property__c,                                                    
                                                     Upload_Rent_Agreement_Reciept__c,                                                                                                    
                                                     Upload_Pension_Document__c,
                                                     Income_per_month__c,
                                                     No_of_Attempts__c,
                                                     FI_Observation__c,
                                                     FI_Feedback__c,
                                                     Remarks__c,
                                                     Case__r.Type,
                                                     Case__r.CreatedDate,
                                                     Case__r.Status,
                                                     Case__r.Loan_Application__c,Case__r.Loan_Application__r.Product_Type__c,
                                                     Case__r.Applicant__c
                                                     FROM Field_Investigation__c
                                                     WHERE Id =: fiId
                                                     WITH SECURITY_ENFORCED];
        if(lstFIRecords.size() > 0) {
            Field_Investigation__c fiRecord = lstFIRecords[0];
            inputWrapper = new IND_OfficeFIInputWrapper();
            inputWrapper.officeFIobj= lstFIRecords[0];            

            inputWrapper.sameAddressAsInApplication = new IND_OfficeFIInputWrapper.BooleanField();
            inputWrapper.sameAddressAsInApplication.label = 'Same Address as in the Application';
            inputWrapper.sameAddressAsInApplication.value = fiRecord.Same_Addresst_as_in_the_Application__c;

            inputWrapper.pinCode = new IND_OfficeFIInputWrapper.StringField();
            inputWrapper.pinCode.label = 'Pincode';
            inputWrapper.pinCode.value = fiRecord.Pin_Code__c;

            inputWrapper.state = new IND_OfficeFIInputWrapper.StringField();
            inputWrapper.state.label = 'State';

            inputWrapper.incomeAsPerFIVisit = new IND_OfficeFIInputWrapper.StringField();
            inputWrapper.incomeAsPerFIVisit.label = 'Income As Per FI Visit';

            inputWrapper.product = new IND_OfficeFIInputWrapper.StringField();
            inputWrapper.product.value = fiRecord.Case__r.Loan_Application__r.Product_Type__c;
            
            inputWrapper.fiRequestGenerationDT = new IND_OfficeFIInputWrapper.DatetimeField();
            inputWrapper.fiRequestGenerationDT.label = System.Label.FI_Request_Generation_Date_And_Time;
            inputWrapper.fiRequestGenerationDT.value = fiRecord.Case__r.CreatedDate;
            
            inputWrapper.geocoderLatitudeAndLongitude = new IND_OfficeFIInputWrapper.StringField();
            inputWrapper.geocoderLatitudeAndLongitude.label = System.Label.GeocoderLatitudeandLongitude;
            inputWrapper.geocoderLatitudeAndLongitude.value = fiRecord.GeoCoder_Latitude_and_Longitude__Latitude__s + ', ' + fiRecord.GeoCoder_Latitude_and_Longitude__Longitude__s;
            
            inputWrapper.fiLatitudeAndLongitude = new IND_OfficeFIInputWrapper.StringField();
            inputWrapper.fiLatitudeAndLongitude.label = 'FI Latitude And Longitude';
            inputWrapper.fiLatitudeAndLongitude.value = fiRecord.FI_Location__Latitude__s + ', ' + fiRecord.FI_Location__Longitude__s;
            
            //Status
            inputWrapper.Office_FI_Accepted_Rejected = new IND_OfficeFIInputWrapper.StringField();
            inputWrapper.Office_FI_Accepted_Rejected.label = System.Label.Office_FI_Status;
            inputWrapper.Office_FI_Accepted_Rejected.value = fiRecord.Case__r.Status;
            fiAccordionTitle = '';
            if (fiRecord.Case__r.Type.equalsIgnoreCase(System.Label.Case_Office_FI_Type)) {
                inputWrapper.Office_FI_Accepted_Rejected.label = System.Label.Office_FI_Status;
                fiAccordionTitle = System.Label.OFFICE_RESIDENCE_FI_TITLE;
            }
            
            // Documents
            Map<String, Id> mapDocTypetoId = IND_OfficeFIReadOnlyController.getDocumentsOfFI(fiRecord.Case__r.Loan_Application__c, fiRecord.Case__r.Applicant__c);
            inputWrapper.buildingfrontview = new IND_OfficeFIInputWrapper.StringField();
            inputWrapper.buildingfrontview.label = System.Label.buildingfrontview;
            inputWrapper.buildingfrontview.value = '';
            if(mapDocTypetoId != null && !mapDocTypetoId.isEmpty() && mapDocTypetoId.get('buildingfrontview') != null) {                      
                inputWrapper.buildingfrontview.value = '/sfc/servlet.shepherd/document/download/' + mapDocTypetoId.get('buildingfrontview');
            }
            
            inputWrapper.signatureView = new IND_OfficeFIInputWrapper.StringField();
            inputWrapper.signatureView.label = System.Label.signatureView;
            inputWrapper.signatureView.value = '';
            if(mapDocTypetoId != null && !mapDocTypetoId.isEmpty() && mapDocTypetoId.get('signatureView') != null) {
                inputWrapper.signatureView.value = '/sfc/servlet.shepherd/document/download/' + mapDocTypetoId.get('signatureView');
            }
            
            System.debug('inputWrapper :- '+inputWrapper);
        }
    }
}