/**
* @Name         IND_OfficeFIInputWrapper
* @Author       mohammad_shahkomeni
* @Company      Persistent Systems
* @Description  This class contains all input parameters used in Field Investigation
* Inputs:       None
* Test Class:   IND_OfficeFIReadOnlyController_Test
* History:      
* Date            Author              Comments
* -------------------------------------------------------------
* 02-20-2022      mohammad_shahkomeni      Created
* ------------------------------------------------------------
*/
public with sharing class IND_OfficeFIInputWrapper {
    
    public Field_Investigation__c officeFIobj{get; set; }
	public DatetimeField fiRequestGenerationDT{ get; set; }
	public StringField residenceFIStatus{ get; set; }
	public DatetimeField officeFICompletionTime{ get; set; }
    public StringField IBLFieldInvestigationName{ get; set; }
    public StringField signCapture{ get; set; }
    public StringField product{ get; set; }
    public StringField touringOrTransferableJob{ get; set; }
   //public StringField monthlyIncomeAsperFIVisit{ get; set; }
	public StringField addrLine1{ get; set; }
	public StringField addrLine2{ get; set; }
	public StringField city{ get; set; }
	public StringField pinCode{ get; set; }
	public StringField state{ get; set; }
	public StringField landmark{ get; set; }
	public StringField phoneNo{ get; set; }
	public StringField mobile{ get; set; }
	public BooleanField sameAddressAsInApplication{ get; set; }
	public StringField geocoderLatitudeAndLongitude{ get; set; }
	public StringField fiLatitudeAndLongitude{ get; set; }
	public StringField coordinatesVerfied{ get; set; }
	public BooleanField areCoordinatesMatching{ get; set; }
    public StringField buildingfrontview{ get; set; }
    public StringField signatureView{ get; set; }
    public StringField employerbusinessname{ get; set; }
    public StringField officebusinesstype{ get; set; }
	public StringField businesspremise{ get; set; }
	public StringField officebusinessboard{ get; set; }
	public StringField officebusinesssizesqft{ get; set; }
	public StringField location{ get; set; }
	public StringField nameofpersonmet{ get; set; }
	public StringField relationship{ get; set; }
	public StringField politicalphoto{ get; set; }
	public StringField category{ get; set; }
	public StringField profile{ get; set; }
	public StringField currentExperienceYears{ get; set; }
	public StringField totalExperienceYears{ get; set; }
	public StringField applicantRecognized{ get; set; }
	public StringField touringOrTransferrableJob{ get; set; }
	public StringField monthlyIncomeAsPerFIVisit{ get; set; }
	public StringField incomeAsPerFIVisit{ get; set; }  
	public DecimalField area{ get; set; }
	public StringField landPhoto{ get; set; }
	public StringField uploadPattaDocument{ get; set; }
	public StringField noOfCropsPerAnnum{ get; set; }
	public StringField typeOfcrop{ get; set; }
	public BooleanField yeildPerAcre{ get; set; }
	public StringField pricePerUnit{ get; set; }
    public DecimalField income{ get; set; }
    public StringField typeOfHouse{ get; set; }
    public StringField electricityConnectionPresent{ get; set; }
    public StringField accessToTubewells{ get; set; }
    public StringField irrigationSystemPresent{ get; set; }
    public StringField noOfCattle{ get; set; }
    public StringField declaredIncomeDuringApplication{ get; set; }
    public StringField typeOfGoodsSold{ get; set; }
    public StringField noOfEmployees{ get; set; }
    public StringField inHouseSecurityPresent{ get; set; }
    public StringField posMachine{ get; set; }
    public StringField acInstalled{ get; set; }
    public StringField averageNoOfCustomershourly{ get; set; }
    public StringField averageTicketSize{ get; set; }
    public StringField numberOfOperationalHoursInADay{ get; set; }
    public StringField monthlySales{ get; set; }
    public StringField annualTurnOver{ get; set; }
    public StringField profitMargin{ get; set; }
    public StringField estimatedIncomeAsPerFI{ get; set; }
    public StringField finalIncome{ get; set; }
    public StringField latestWaterBillamountPaidmonthly{ get; set; }
    public StringField paymentProofShown{ get; set; }
    public StringField latestElectricityBillAmountPaidMont{ get; set; }
    public StringField latestTelephoneBillAmount{ get; set; }
    public StringField ownEquipmentTools{ get; set; }
    public StringField listOfEquipmentToolsOwned{ get; set; }
    public StringField affiliationToEcommerce{ get; set; }
    public StringField averageProfessionalFeeService{ get; set; }
    public StringField noOfServiceRequestsCateredInMonth{ get; set; }
    public StringField estimatedServiceIncomeasperFI{ get; set; }
    public StringField typesOfVehiclesOwned{ get; set; }
    public StringField noOfVehiclesOwned{ get; set; }
    public StringField estimatedIncomeAsPerMonth{ get; set; }
    public StringField noOfContractsAwardedInLast1year{ get; set; }
    public StringField doYouHaveAnyGovermentContracts{ get; set; }
    public StringField estimatedTotalMonthlyIncome{ get; set; }
    public StringField NoOfpropertiesRented{ get; set; }
    public StringField incomePerMonthProperty{ get; set; }
    public StringField incomePerMonth{ get; set; }
    public StringField uploadRentAgreementReciept{ get; set; }
    public StringField uploadPensionDocument{ get; set; }
    public StringField noOfAttempts{ get; set; }
    public StringField fiObservation{ get; set; }
    public StringField fiFeedback{ get; set; }
    public StringField officeFIAcceptedRejected{ get; set; }
    public StringField remarks{ get; set; }
    public StringField fiId{ get; set; }
    public StringField caseId{ get; set; }
    public StringField ownerId{ get; set; }
    public StringField applicantId{ get; set; }
    public StringField applicationId{ get; set; }
    public StringField stage{ get; set; }
    public StringField Subject{ get; set; }
    public StringField subStage{ get; set; }
    public StringField fiAcceptedRejected{ get; set; }
    public StringField name{ get; set; }
    
    // Mohammed
    public BooleanField isMobileJourneyCompleted{ get; set; }  
    public StringField officeFIStatus{ get; set; }
    public StringField Office_FI_Accepted_Rejected{ get; set; }
    public StringField Employer_Business_Name{ get; set; }
    public StringField Current_experience_years{ get; set; }
    public StringField Total_Experience_Years{ get; set; }
    public DecimalField Estimated_Service_Income_as_per_FI{ get; set; }
    public BooleanField Are_Co_ordinates_Matching_If_Amber{ get; set; }
    public DecimalField SENP_Agriculture_Income{ get; set; }
    public DecimalField SENP_Own_Shop_Income{ get; set; }
    public DecimalField SENP_Service_oriented_Income{ get; set; }
    public DecimalField SENP_Transporter_Income{ get; set; }
    public DecimalField SENP_Contractor_Income{ get; set; }
    public DecimalField SENP_Rental_Income{ get; set; }
    public DecimalField SENP_Pension_Income{ get; set; }
	public StringField Vehicle_Type{ get; set; }
    public StringField Product_Type{ get; set; }
    public StringField Sanction_Status{ get; set; }
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
	
	public static IND_OfficeFIInputWrapper parse(String json) {
		return (IND_OfficeFIInputWrapper) System.JSON.deserialize(json, IND_OfficeFIInputWrapper.class);
	}

}