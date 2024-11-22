/**
* @Name         IND_ResidenceFIPDFController
* @Author       mohammad_shahkomeni
* @Company      Persistent Systems
* @Description  This class used to generate Residence FI PDF File
* Inputs:       None
* Test Class:   IND_ResidenceFIPDFController_Test
* History:      
* Date            Author              Comments
* -------------------------------------------------------------
* 02-20-2022      mohammad_shahkomeni      Created
* ------------------------------------------------------------
*/
public class IND_ResidenceFIPDFController {
    
    public IND_ResidenceFIInputWrapper inputWrapper {get; set;}
    public String fiAccordionTitle {get; set;}
    public Boolean tractorLead {get; set;}
    
    /*
* @Method:      IND_ResidenceFIPDFController
* @Created by:  mohammad_shahkomeni
* @Description: This constructor will get all Field Investigation fields and return the response back to VF Page
* @Param:       void
* @Return:      void
*/
    public IND_ResidenceFIPDFController() {
        String fiId = ApexPages.currentPage().getParameters().get('fiId');
        System.debug('fiId :- '+fiId);
        List<Field_Investigation__c> lstFIRecords = [SELECT ID,
                                                     FI_Status__c,
                                                     Residence_FI_completion_time__c,
                                                     Address_Line_1__c,
                                                     Address_Line_2__c,
                                                     City__c,
                                                     Pin_Code__c,
                                                     State__c,
                                                     Landmark__c,
                                                     Phone_Number__c,
                                                     Mobile__c,
                                                     Customer_house_same_as_in_application__c,
                                                     GeoCoder_Latitude_and_Longitude__Latitude__s,
                                                     GeoCoder_Latitude_and_Longitude__Longitude__s,
                                                     FI_Location__Latitude__s,
                                                     FI_Location__Longitude__s,
                                                     Coordinates_Verified__c,
                                                     Are_Co_ordinates_Matching_If_Amber__c,
                                                     Years_in_Residence__c,
                                                     Name,
                                                     Product__c,
                                                     Residence_Type__c,
                                                     Profile_to_Product_Match__c,
                                                     Name_of_Person_met__c,
                                                     Relationship__c,
                                                     Purpose_of_Purchase__c,
                                                     Number_of_Dependent__c,
                                                     Number_of_Earning_Member_in_Family__c,
                                                     Years_in_CIty__c,
                                                     No_of_Attempts__c,
                                                     FI_Observation__c,
                                                     FI_Feedback__c,
                                                     No_of_TVs__c,
                                                     No_of_Fridges__c,
                                                     No_of_Washing_Machines__c,
                                                     No_of_Sofas__c,
                                                     No_of_ACs__c,
                                                     No_of_Computers__c,
                                                     No_of_2_Wheelers__c,
                                                     No_of_3_Wheelers__c,
                                                     No_of_4_Wheelers__c,
                                                     No_of_CVs__c,
                                                     Remarks__c,
                                                     Case__c,
                                                     Case__r.OwnerId,
                                                     Case__r.Type,
                                                     Case__r.Status,
                                                     Case__r.CreatedDate,
                                                     Case__r.Applicant__c,
                                                     Case__r.Applicant__r.Name,
                                                     Case__r.Loan_Application__c,
                                                     Case__r.Loan_Application__r.Make__c,
                                                     Case__r.Loan_Application__r.Model__c,
                                                     Case__r.Loan_Application__r.Variant__c,
                                                     Case__r.Loan_Application__r.StageName,
                                                     Case__r.Loan_Application__r.Sub_Stage__c,
                                                     Case__r.Loan_Application__r.Is_Mobile_Journey_Completed__c,Case__r.Loan_Application__r.Product_Type__c
                                                     FROM Field_Investigation__c
                                                     WHERE Id =: fiId
                                                     WITH SECURITY_ENFORCED];
        
        if(lstFIRecords.size() > 0) {
            Field_Investigation__c fiRecord = lstFIRecords[0];
            inputWrapper = new IND_ResidenceFIInputWrapper();

            this.tractorLead = fiRecord.Case__r.Loan_Application__r.Product_Type__c == System.Label.Tractor ? true : false;
            
            inputWrapper.fiRequestGenerationDT = new IND_ResidenceFIInputWrapper.DatetimeField();
            inputWrapper.fiRequestGenerationDT.label = 'FI Request Generation Date and Time';
            inputWrapper.fiRequestGenerationDT.value = fiRecord.Case__r.CreatedDate;
            
            inputWrapper.residenceFIStatus = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.residenceFIStatus.label = 'Residence FI Status';
            inputWrapper.residenceFIStatus.value = fiRecord.FI_Status__c;
            
            inputWrapper.residenceFICompletionTime = new IND_ResidenceFIInputWrapper.DatetimeField();
            inputWrapper.residenceFICompletionTime.label = 'Residence FI completion time';
            inputWrapper.residenceFICompletionTime.value = fiRecord.Residence_FI_completion_time__c;
            
            inputWrapper.addrLine1 = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.addrLine1.label = 'Adress line 1';
            inputWrapper.addrLine1.value = fiRecord.Address_Line_1__c;
            
            inputWrapper.addrLine2 = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.addrLine2.label = 'Adress line 2';
            inputWrapper.addrLine2.value = fiRecord.Address_Line_2__c;
            
            inputWrapper.city = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.city.label = 'City';
            inputWrapper.city.value = fiRecord.City__c;
            
            inputWrapper.pinCode = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.pinCode.label = 'Pin Code';
            inputWrapper.pinCode.value = fiRecord.Pin_Code__c;
            
            inputWrapper.state = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.state.label = 'State';
            inputWrapper.state.value = fiRecord.State__c;
            
            inputWrapper.landmark = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.landmark.label = 'Landmark';
            inputWrapper.landmark.value = fiRecord.Landmark__c;
            
            inputWrapper.phoneNo = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.phoneNo.label = 'Phone no';
            inputWrapper.phoneNo.value = fiRecord.Phone_Number__c;
            
            inputWrapper.mobile = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.mobile.label = 'Mobile';
            inputWrapper.mobile.value = fiRecord.Mobile__c;
            
            inputWrapper.locationSameAsInApplication = new IND_ResidenceFIInputWrapper.BooleanField();
            inputWrapper.locationSameAsInApplication.label = 'Whether customer house located in the same address as in the application';
            inputWrapper.locationSameAsInApplication.value = fiRecord.Customer_house_same_as_in_application__c;
            
            inputWrapper.geocoderLatitudeAndLongitude = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.geocoderLatitudeAndLongitude.label = 'Geocoder Latitude and Longitude';
            inputWrapper.geocoderLatitudeAndLongitude.value = fiRecord.GeoCoder_Latitude_and_Longitude__Latitude__s + ', ' + fiRecord.GeoCoder_Latitude_and_Longitude__Longitude__s;
            
            inputWrapper.fiLatitudeAndLongitude = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.fiLatitudeAndLongitude.label = 'FI Latitude and Longitude';
            inputWrapper.fiLatitudeAndLongitude.value = fiRecord.FI_Location__Latitude__s + ', ' + fiRecord.FI_Location__Longitude__s;
            
            inputWrapper.coordinatesVerfied = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.coordinatesVerfied.label = 'Coordinates Verfied';
            inputWrapper.coordinatesVerfied.value = fiRecord.Coordinates_Verified__c;
            
            inputWrapper.Are_Co_ordinates_Matching_If_Amber = new IND_ResidenceFIInputWrapper.BooleanField();
            inputWrapper.Are_Co_ordinates_Matching_If_Amber.label = 'Are Co-ordinates matching (if Amber)';
            inputWrapper.Are_Co_ordinates_Matching_If_Amber.value = fiRecord.Are_Co_ordinates_Matching_If_Amber__c;
            
            inputWrapper.yearsInResidence = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.yearsInResidence.label = 'Yrs in Resi';
            inputWrapper.yearsInResidence.value = fiRecord.Years_in_Residence__c;
            
            inputWrapper.name = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.name.label = 'Name';
            inputWrapper.name.value = fiRecord.Case__r.Applicant__r.Name;
            
            inputWrapper.product = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.product.label = 'Product';
            inputWrapper.product.value = fiRecord.Product__c;
            
            inputWrapper.resiType = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.resiType.label = 'Resi Type';
            inputWrapper.resiType.value = fiRecord.Residence_Type__c;
            
            inputWrapper.profileProductMatch = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.profileProductMatch.label = 'Profile to Product Match';
            inputWrapper.profileProductMatch.value = fiRecord.Profile_to_Product_Match__c;
            
            inputWrapper.purposeOfPurchase = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.purposeOfPurchase.label = 'Purpose Of Purchase';
            inputWrapper.purposeOfPurchase.value = fiRecord.Purpose_of_Purchase__c;
            
            inputWrapper.noofDependents = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.noofDependents.label = 'No of Dependents';
            inputWrapper.noofDependents.value = fiRecord.Number_of_Dependent__c;
            
            inputWrapper.numberOfEarningMembersInTheFamily = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.numberOfEarningMembersInTheFamily.label = 'Number of earning members in the family';
            inputWrapper.numberOfEarningMembersInTheFamily.value = fiRecord.Number_of_Earning_Member_in_Family__c;
            
            inputWrapper.nameOfPersonMet = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.nameOfPersonMet.label = 'Name of Person met';
            inputWrapper.nameOfPersonMet.value = fiRecord.Name_of_Person_met__c;
            
            inputWrapper.relationShipWithCustomer = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.relationShipWithCustomer.label = 'Relationship with customer';
            inputWrapper.relationShipWithCustomer.value = fiRecord.Relationship__c;
            
            inputWrapper.noOfYearsinCity = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.noOfYearsinCity.label = 'No of Years in City';
            inputWrapper.noOfYearsinCity.value = fiRecord.Years_in_CIty__c;
            
            inputWrapper.noofAttempts = new IND_ResidenceFIInputWrapper.DecimalField();
            inputWrapper.noofAttempts.label = 'No of Attempts';
            inputWrapper.noofAttempts.value = fiRecord.No_of_Attempts__c;
            
            inputWrapper.fiObservation = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.fiObservation.label = 'FI Observation';
            inputWrapper.fiObservation.value = fiRecord.FI_Observation__c;
            
            inputWrapper.fiFeedback = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.fiFeedback.label = 'FI Feedback';
            inputWrapper.fiFeedback.value = fiRecord.FI_Feedback__c;
            
            inputWrapper.noOfTVs = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.noOfTVs.label = 'TV';
            inputWrapper.noOfTVs.value = fiRecord.No_of_TVs__c;
            
            inputWrapper.noOfFridgess = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.noOfFridgess.label = 'Fridge';
            inputWrapper.noOfFridgess.value = fiRecord.No_of_Fridges__c;
            
            inputWrapper.noofWashingMachines = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.noofWashingMachines.label = 'Washing Machine';
            inputWrapper.noofWashingMachines.value = fiRecord.No_of_Washing_Machines__c;
            
            inputWrapper.noOfSofas = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.noOfSofas.label = 'Sofa';
            inputWrapper.noOfSofas.value = fiRecord.No_of_Sofas__c;
            
            inputWrapper.noOfACs = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.noOfACs.label = 'AC';
            inputWrapper.noOfACs.value = fiRecord.No_of_ACs__c;
            
            inputWrapper.noOfComputers = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.noOfComputers.label = 'Computer';
            inputWrapper.noOfComputers.value = fiRecord.No_of_Computers__c;
            
            inputWrapper.noOf2Wheelers = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.noOf2Wheelers.label = '2 Wheeler';
            inputWrapper.noOf2Wheelers.value = fiRecord.No_of_2_Wheelers__c;
            
            inputWrapper.noOf3Wheelers = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.noOf3Wheelers.label = '3 Wheeler';
            inputWrapper.noOf3Wheelers.value = fiRecord.No_of_3_Wheelers__c;
            
            inputWrapper.noOf4Wheelers = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.noOf4Wheelers.label = '4 Wheeler';
            inputWrapper.noOf4Wheelers.value = fiRecord.No_of_4_Wheelers__c;
            
            inputWrapper.noOfCVs = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.noOfCVs.label = 'CV';
            inputWrapper.noOfCVs.value = fiRecord.No_of_CVs__c;
            
            //Status
            inputWrapper.Residence_FI_Accepted_Rejected = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.Residence_FI_Accepted_Rejected.label = '';
            inputWrapper.Residence_FI_Accepted_Rejected.value = fiRecord.Case__r.Status;
            inputWrapper.documentAddressType = new IND_ResidenceFIInputWrapper.StringField();
            fiAccordionTitle = '';
            if (fiRecord.Case__r.Type.equalsIgnoreCase(System.Label.Case_Current_Residence_FI_Type)) {
                inputWrapper.Residence_FI_Accepted_Rejected.label = System.Label.Current_FI_Status;
                inputWrapper.documentAddressType.value = System.Label.Document_Current_Residential_Address_Type;
                fiAccordionTitle = System.Label.CURRENT_RESIDENCE_FI_TITLE;
            } else if (fiRecord.Case__r.Type.equalsIgnoreCase(System.Label.Case_Permanent_Residence_FI_Type)) {
                inputWrapper.Residence_FI_Accepted_Rejected.label = System.Label.Permanent_FI_Status;
                inputWrapper.documentAddressType.value = System.Label.Document_Permanent_Residential_Address_Type;
                fiAccordionTitle = System.Label.PERMANENT_RESIDENCE_FI_TITLE;
            }
            
            inputWrapper.remarks = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.remarks.label = 'Remarks';
            inputWrapper.remarks.value = fiRecord.Remarks__c;
            
            // Vehicle Details
            Vehicle_Detail__c vehicleDetails = IND_ResidenceFIReadOnlyController.getVehicleDetailsOfFI(fiRecord.Case__r.Loan_Application__c);
            inputWrapper.make = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.make.label = 'Make';
            inputWrapper.make.value = '';
            inputWrapper.model = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.model.label = 'Model';
            inputWrapper.model.value = '';
            inputWrapper.variant = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.variant.label = 'Variant';
            inputWrapper.variant.value = '';
            inputWrapper.dealer = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.dealer.label = 'Dealer';
            inputWrapper.dealer.value = '';
            if(vehicleDetails != null) {
                inputWrapper.make.value = vehicleDetails.Make__c;
                inputWrapper.model.value = vehicleDetails.Model__c;
                inputWrapper.variant.value = vehicleDetails.Variant__c;
                inputWrapper.dealer.value = vehicleDetails.Dealer_Sub_dealer_name__c;
            }
            
            // Documents
            Map<String, Id> mapDocTypetoId = IND_ResidenceFIReadOnlyController.getDocumentsOfFI(
                fiRecord.Case__r.Loan_Application__c, fiRecord.Case__r.Applicant__c, fiRecord.Case__c);
            inputWrapper.viewResidencefrontview = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.viewResidencefrontview.label = System.Label.viewResidencefrontview;
            inputWrapper.viewResidencefrontview.value = '';
            if(mapDocTypetoId != null && !mapDocTypetoId.isEmpty() && mapDocTypetoId.get('viewResidencefrontview') != null) {                        
                inputWrapper.viewResidencefrontview.value = '/sfc/servlet.shepherd/document/download/' + mapDocTypetoId.get('viewResidencefrontview');
            }
            
            inputWrapper.signatureView = new IND_ResidenceFIInputWrapper.StringField();
            inputWrapper.signatureView.label = System.Label.signatureView;
            inputWrapper.signatureView.value = '';
            if(mapDocTypetoId != null && !mapDocTypetoId.isEmpty() && mapDocTypetoId.get('signatureView') != null) {
                inputWrapper.signatureView.value = '/sfc/servlet.shepherd/document/download/' + mapDocTypetoId.get('signatureView');
            }
            
            System.debug('inputWrapper :- '+inputWrapper);
        }
    }
}