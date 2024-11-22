public with sharing class IND_ResidenceFIInputWrapper {

	public DatetimeField fiRequestGenerationDT{ get; set; }
	public StringField residenceFIStatus{ get; set; }
	public DatetimeField residenceFICompletionTime{ get; set; }
	public StringField addrLine1{ get; set; }
	public StringField addrLine2{ get; set; }
	public StringField city{ get; set; }
	public StringField pinCode{ get; set; }
	public StringField state{ get; set; }
	public StringField landmark{ get; set; }
	public StringField phoneNo{ get; set; }
	public StringField mobile{ get; set; }
	public BooleanField locationSameAsInApplication{ get; set; }
	public StringField geocoderLatitudeAndLongitude{ get; set; }
	public StringField fiLatitudeAndLongitude{ get; set; }
	public StringField coordinatesVerfied{ get; set; }
	public BooleanField areCoordinatesMatching{ get; set; }
	public StringField yearsInResidence{ get; set; }
	public StringField name{ get; set; }
	public StringField product{ get; set; }
	public StringField resiType{ get; set; }
	public StringField permCurrAddress{ get; set; }
	public StringField purposeOfPurchase{ get; set; }
	public StringField make{ get; set; }
	public StringField model{ get; set; }
	public StringField variant{ get; set; }
	public StringField dealer{ get; set; }
	public StringField noofDependents{ get; set; }
	public StringField numberOfEarningMembersInTheFamily{ get; set; }
	public StringField nameOfPersonMet{ get; set; }
	public StringField relationShipWithCustomer{ get; set; }
	public StringField noOfYearsinCity{ get; set; }
    public StringField signatureView{ get; set; }
    public StringField viewResidencefrontview{ get; set; }
	public DecimalField noofAttempts{ get; set; }
	public StringField fiObservation{ get; set; }
	public StringField fiFeedback{ get; set; }
	public StringField noOfTVs{ get; set; }
	public StringField noOfFridgess{ get; set; }
	public StringField noofWashingMachines{ get; set; }
	public StringField noOfSofas{ get; set; }
	public StringField noOfACs{ get; set; }
	public StringField noOfComputers{ get; set; }
	public StringField noOf2Wheelers{ get; set; }
	public StringField noOf3Wheelers{ get; set; }
	public StringField noOf4Wheelers{ get; set; }
	public StringField noOfCVs{ get; set; }
	public StringField whiteGoodsAtHome{ get; set; }
	public StringField vehiclesOwnedAtHome{ get; set; }
	public StringField fiAcceptedRejected{ get; set; }
	public StringField remarks{ get; set; }
    public StringField fiId{ get; set; }
    public StringField caseId{ get; set; }
    public StringField ownerId{ get; set; }
    public StringField applicantId{ get; set; }
    public StringField applicationId{ get; set; }
    public StringField stage{ get; set; }
    public StringField subStage{ get; set; }
    public StringField isMobileJourneyCompleted{ get; set; }
    public StringField officeFIStatus{ get; set; }
    public StringField Employer_Business_Name{ get; set; }
    public StringField Current_experience_years{ get; set; }
    public DecimalField Total_Experience_Years{ get; set; }
    public DecimalField Income{ get; set; }
    public DecimalField Estimated_Service_Income_as_per_FI{ get; set; }
    public BooleanField Are_Co_ordinates_Matching_If_Amber{ get; set; }
    public StringField Office_FI_Accepted_Rejected{ get; set; }
	public StringField Subject{ get; set; }
    public DecimalField SENP_Agriculture_Income{ get; set; }
    public DecimalField SENP_Own_Shop_Income{ get; set; }
    public DecimalField SENP_Service_oriented_Income{ get; set; }
    public DecimalField SENP_Transporter_Income{ get; set; }
    public DecimalField SENP_Contractor_Income{ get; set; }
    public DecimalField SENP_Rental_Income{ get; set; }
    public DecimalField SENP_Pension_Income{ get; set; }
    public StringField profileProductMatch{ get; set; }
	public StringField documentAddressType{ get; set; }
    //added by Hemanth Thikka
    public StringField Residence_FI_Accepted_Rejected{ get; set; }
    public StringField Origin{ get; set; }
    public StringField Type{ get; set; }
    

    public class StringField {
        public String label{ get; set; }
        public String value{ get; set; }
	}

	public class BooleanField {
        public String label{ get; set; }
        public Boolean value{ get; set; }
	}

    public class DecimalField {
        public String label{ get; set; }
        public Decimal value{ get; set; }
		
	}

    public class DatetimeField {
        public String label{ get; set; }
        public Datetime value{ get; set; }
	}
	
	public static IND_ResidenceFIInputWrapper parse(String json) {
		return (IND_ResidenceFIInputWrapper) System.JSON.deserialize(json, IND_ResidenceFIInputWrapper.class);
	}
}