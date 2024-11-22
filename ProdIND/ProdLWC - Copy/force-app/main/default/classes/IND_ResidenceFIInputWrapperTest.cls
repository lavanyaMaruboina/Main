@isTest
public class IND_ResidenceFIInputWrapperTest {

    private static final String TEST = 'Test';
    
    @isTest
    private static void testParse() {
        IND_ResidenceFIInputWrapper.StringField str = new IND_ResidenceFIInputWrapper.StringField();
        str.label = TEST;
        str.value = TEST;
        
        IND_ResidenceFIInputWrapper.DatetimeField dt = new IND_ResidenceFIInputWrapper.DatetimeField();
        dt.label = TEST;
        dt.value = System.now();
        
		IND_ResidenceFIInputWrapper.DecimalField dec = new IND_ResidenceFIInputWrapper.DecimalField();
		dec.label = TEST;
		dec.value = 1.0;
        
        IND_ResidenceFIInputWrapper.BooleanField bool = new IND_ResidenceFIInputWrapper.BooleanField();
		bool.label = TEST;
		bool.value = true;
        
        IND_ResidenceFIInputWrapper wrap = new IND_ResidenceFIInputWrapper();
        wrap.addrLine1 = str;
        wrap.noofAttempts = dec;
        wrap.Are_Co_ordinates_Matching_If_Amber = bool;
        wrap.fiRequestGenerationDT = dt;
        wrap.residenceFIStatus = str;
        wrap.addrLine2 = str;
        wrap.applicantId = str;
        wrap.applicationId = str;
        wrap.areCoordinatesMatching = bool;
        wrap.caseId = str;
        wrap.city = str;
        wrap.coordinatesVerfied = str;
        wrap.dealer = str;
        wrap.fiAcceptedRejected = str;
        wrap.fiFeedback = str;
        wrap.fiId = str;
        wrap.fiLatitudeAndLongitude = str;
        wrap.fiObservation = str;
        wrap.geocoderLatitudeAndLongitude = str;
        wrap.isMobileJourneyCompleted = str;
        wrap.landmark = str;
        wrap.locationSameAsInApplication = bool;
        wrap.make = str;
        wrap.mobile = str;
        wrap.model = str;
        wrap.name = str;
        wrap.nameOfPersonMet = str;
        wrap.noOf2Wheelers = str;
        wrap.noOf3Wheelers = str;
        wrap.noOf4Wheelers = str;
        wrap.noOfACs = str;
        wrap.noOfComputers = str;
        wrap.noOfCVs = str;
        wrap.noofDependents = str;
        wrap.noOfFridgess = str;
        wrap.noOfSofas = str;
        wrap.noOfTVs = str;
        wrap.noofWashingMachines = str;
        wrap.noOfYearsinCity = str;
        wrap.numberOfEarningMembersInTheFamily = str;
        wrap.residenceFICompletionTime = dt;
        wrap.pinCode = str;
        wrap.state = str;
        wrap.phoneNo = str;
        wrap.yearsInResidence = str;
        wrap.product = str;
        wrap.resiType = str;
        wrap.permCurrAddress = str;
        wrap.purposeOfPurchase = str;
        wrap.variant = str;
        wrap.relationShipWithCustomer = str;
        wrap.signatureView = str;
        wrap.viewResidencefrontview = str;
        wrap.whiteGoodsAtHome = str;
        wrap.vehiclesOwnedAtHome = str;
        wrap.remarks = str;
        wrap.ownerId = str;
        wrap.stage = str;
        wrap.subStage = str;
        wrap.officeFIStatus = str;
        wrap.Employer_Business_Name = str;
        wrap.Current_experience_years = str;
        wrap.Total_Experience_Years = dec;
        wrap.Income = dec;
        wrap.Estimated_Service_Income_as_per_FI = dec;
        wrap.Office_FI_Accepted_Rejected = str;
        wrap.SENP_Agriculture_Income = dec;
        wrap.SENP_Own_Shop_Income = dec;
        wrap.SENP_Service_oriented_Income = dec;
        wrap.SENP_Transporter_Income = dec;
        wrap.SENP_Contractor_Income = dec;
        wrap.SENP_Rental_Income = dec;
        wrap.SENP_Pension_Income = dec;
        wrap.profileProductMatch = str;
        wrap.areCoordinatesMatching = bool;
        wrap.Subject = str;
        wrap.documentAddressType = str;
        wrap.Residence_FI_Accepted_Rejected = str;
        wrap.Origin = str;
        wrap.Type = str;
        
        String jsonStr = JSON.serialize(wrap);
        
        IND_ResidenceFIInputWrapper parsedWrapper = IND_ResidenceFIInputWrapper.parse(jsonStr);
        System.assertEquals(TEST, parsedWrapper.addrLine1.value);
    }
}