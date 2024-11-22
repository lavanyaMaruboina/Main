public class RequestWrapper{
    @AuraEnabled public String applicantId {get;set;}   
    @AuraEnabled public String panNumber {get;set;} 
    @AuraEnabled public String firstName {get;set;} 
    @AuraEnabled public String lastName {get;set;} 
    @AuraEnabled public String dlNumber {get;set;} 
    @AuraEnabled public String dateOfBirth {get;set;} 
    @AuraEnabled public String telephoneNumber {get;set;}
    @AuraEnabled public String kycNo {get;set;}
    @AuraEnabled public String kycPassportFileNo {get;set;}
    @AuraEnabled public String kycGender {get;set;}
    @AuraEnabled public String kycPassportNo {get;set;}
    @AuraEnabled public String leadId {get;set;}
    @AuraEnabled public String email {get;set;}
    @AuraEnabled public String income {get;set;}
    @AuraEnabled public String aadhaarNo {get;set;}
    @AuraEnabled public DateTime dOB {get;set;} 
    @AuraEnabled public String vehicleRegisterationNumber {get;set;}
    @AuraEnabled public String loanApplicationId {get;set;}//this needs to come from UI in every API call
    @AuraEnabled public String noOfCoborrowers {get;set;}
    @AuraEnabled public String vehicleType {get;set;}
    @AuraEnabled public String CityId {get;set;}    
    @AuraEnabled public String VariantCode {get;set;}
    @AuraEnabled public String customerCode {get;set;}
    @AuraEnabled public String oldDealNo {get;set;}
    @AuraEnabled public String nocNo {get;set;}
    @AuraEnabled public String product {get;set;}
    @AuraEnabled public String category {get;set;}
    @AuraEnabled public String subCategory {get;set;}
    @AuraEnabled public String applicationId {get;set;}
    @AuraEnabled public String cicNo {get;set;} 
    @AuraEnabled public String emailTo {get;set;}
    @AuraEnabled public String emailCC {get;set;}
    @AuraEnabled public String emailSubject {get;set;}
    @AuraEnabled public String emailBody {get;set;}
    @AuraEnabled public String loanAmount {get;set;}
   @AuraEnabled public String loanDuration{get;set;}
   @AuraEnabled  public String loanType{get;set;}
   @AuraEnabled  public String processingType{get;set;}
   @AuraEnabled public String acceptancePolicy{get;set;}
   @AuraEnabled public String uploadingScannedStatements{get;set;}
   @AuraEnabled public String yearMonthFrom{get;set;}
   @AuraEnabled public String yearMonthTo{get;set;}
   @AuraEnabled public String productType{get;set;}
   @AuraEnabled public String employmentType{get;set;}
   @AuraEnabled public String employerName{get;set;}
   @AuraEnabled public String fileId{get;set;}
   @AuraEnabled public String institutionId{get;set;}
   @AuraEnabled public String password{get;set;}
   @AuraEnabled public String perfiosTransactionId{get;set;}
   @AuraEnabled public String uid{get;set;}
   @AuraEnabled public String otp{get;set;}
   @AuraEnabled public String txn{get;set;}
   @AuraEnabled public String rnn{get;set;} 
	@AuraEnabled public String applicantFirstName{get;set;}    
    @AuraEnabled public String applicantMiddleName{get;set;}
    @AuraEnabled public String applicantLastName{get;set;}
    @AuraEnabled public String name{get;set;}
    @AuraEnabled public String destinationName{get;set;}
    @AuraEnabled public String destinationNames{get;set;}
    @AuraEnabled public String cinNo{get;set;}
    @AuraEnabled public String applicationNo{get;set;}
    @AuraEnabled public String vehicleId{get;set;}
    @AuraEnabled public String age{get;set;}
    @AuraEnabled public String gender{get;set;}
    @AuraEnabled public String insProduct{get;set;}
    @AuraEnabled public String planCode{get;set;}
    @AuraEnabled public String finAmount{get;set;}
    @AuraEnabled public String tenure{get;set;}
    @AuraEnabled public String dealNumber{get;set;}//Insurance Premium
    @AuraEnabled public String Borrower_Type{get;set;}//Insurance Recommendation
    @AuraEnabled public String Vehicle_Category{get;set;}//Insurance Recommendation
    @AuraEnabled public String Variant{get;set;}//Insurance Recommendation
    @AuraEnabled public String Fin_Amount{get;set;}//Insurance Recommendation
    @AuraEnabled public String Balance_Available{get;set;}//Insurance Recommendation
    @AuraEnabled public String Agreement_Value{get;set;}//Insurance Recommendation
    @AuraEnabled public String Motor_Expiry_Date{get;set;}//Insurance Recommendation
    @AuraEnabled public String Motor_Premium{get;set;}//Insurance Recommendation
    @AuraEnabled public String Periodicity{get;set;}//Insurance Recommendation //SFTRAC-629
    @AuraEnabled public String coBorrowerPanNumber{get;set;}
    @AuraEnabled public DateTime coBorrowerDob{get;set;}
    @AuraEnabled public String coBorrowerIncome{get;set;}
    @AuraEnabled public String coBorrowerCinNo{get;set;}
    @AuraEnabled public String contactNumber{get;set;}
    @AuraEnabled public String otpForBorrower{get;set;}
    @AuraEnabled public String flag{get;set;}
    @AuraEnabled public String valuerCategory{get;set;} 
    @AuraEnabled public String placeOfInspection{get;set;}
    @AuraEnabled public String locationOfVehicle{get;set;}
    @AuraEnabled public String city{get;set;}
    @AuraEnabled public String state{get;set;}
    @AuraEnabled public String incomeDtlId{get;set;} 
    @AuraEnabled public String gstType{get;set;}
    @AuraEnabled public String itrType{get;set;}
    @AuraEnabled public String bankType{get;set;}
    @AuraEnabled public String GstNumber{get;set;}
    @AuraEnabled public Date kycDOB {get;set;} 
    @AuraEnabled public String year{get;set;}
    @AuraEnabled public String month{get;set;}
    @AuraEnabled public String stateCode{get;set;}
    @AuraEnabled public String color{get;set;}
    @AuraEnabled public String owner {get;set;}  
    @AuraEnabled public String kilometer {get;set;} 
    @AuraEnabled public String incomeDetailId {get;set;}
    @AuraEnabled public Income_Details__c incomeDetails {get;set;}
    @AuraEnabled public String whatsappNo {get;set;}
    @AuraEnabled public String reportType {get;set;}
    @AuraEnabled public String enachStatus {get;set;}
    @AuraEnabled public String contentId {get;set;}
    @AuraEnabled public String crmIrrRequested {get;set;}
    @AuraEnabled public String exShowroomPrice {get;set;}
    @AuraEnabled public String onRoadPrice {get;set;}
    @AuraEnabled public String finalTermId {get;set;}
    @AuraEnabled public String fundingOnExShowroom {get;set;}
    @AuraEnabled public String fundingOnORP {get;set;}
    @AuraEnabled public String currentScreen {get;set;}
    @AuraEnabled public String sumOfFundedInsurance {get;set;}
    @AuraEnabled public String riskBand {get;set;}
    @AuraEnabled public String borrowerNIP {get;set;}
    @AuraEnabled public String coBorrowerNIP {get;set;}
    @AuraEnabled public String borrowerPresentAddress {get;set;}
    @AuraEnabled public String coBorrowerPresentAddress {get;set;}
    @AuraEnabled public String emi {get;set;}
    @AuraEnabled public String subProduct {get;set;} 
    @AuraEnabled public String thresholdNetIRR {get;set;} 
    @AuraEnabled public String borrowerApplicantNumber {get;set;} 
    @AuraEnabled public String coBorrowerApplicantNumber {get;set;}
    @AuraEnabled public String applicantNumber {get;set;}
    @AuraEnabled public String scoreCardDecision {get;set;}
    @AuraEnabled public String proposalBasedOn {get;set;}
    @AuraEnabled public String tenureChanged {get;set;}
    @AuraEnabled public String loanAmountChanged {get;set;}
    @AuraEnabled public String crmIrrChanged {get;set;}
    @AuraEnabled public String noOfActiveCoborrowers {get;set;}
    @AuraEnabled public String url {get;set;}
    @AuraEnabled public String accountNumEnd {get;set;}
    @AuraEnabled public String borrowerForm60Present {get;set;}
    @AuraEnabled public String coBorrowerForm60Present {get;set;}
    @AuraEnabled public String bankName {get;set;}
    @AuraEnabled public String otpForInsConsent {get;set;}
    @AuraEnabled public String otpForAppSignConsent {get;set;}
    @AuraEnabled public String advanceEmiFlag {get;set;}
	@AuraEnabled public String documentId {get;set;}
	@AuraEnabled public String otpForCasaConsent {get;set;}
    @AuraEnabled public String offerEMI {get;set;}//INDI-4682
	@AuraEnabled public String parentDealNo {get;set;} //INDI-4709 AND CISP-112 Added new attribute in the request wrapper.
	@AuraEnabled public String provisionAmount {get;set;} //CISP-124
    @AuraEnabled public String leadName {get;set;}  //OLA-204 - Added leadName Parameter to share with customer
    @AuraEnabled public String leadOwnerName {get;set;}  //OLA-204 - Added leadOwnerName Parameter to share with customer
    @AuraEnabled public String leadOwnerContact {get;set;}  //OLA-204 - Added leadOwnerContact Parameter to share with customer
    //Added by Rohan for new DSA Api
    @AuraEnabled public  String Channel {get;set;}
    @AuraEnabled public String CountBRECall {get;set;}
    @AuraEnabled public String EngineBankIrr {get;set;}
    @AuraEnabled public String EngineLTV {get;set;}
    @AuraEnabled public String ORPQuotationPrice {get;set;}
    @AuraEnabled public Boolean isPACustomer {get; set;}//Added for D2C
    @AuraEnabled public String D2C {get; set;}//Added for D2C
    @AuraEnabled public String DealerCategory {get; set;}//Added for D2C
    @AuraEnabled public String Manufacture_Code {get; set;}//Added for D2C
    @AuraEnabled public String RequiredTenureFinalOffer {get; set;}//Added for D2C
    @AuraEnabled public String RequiredLoanAmountFinalOffer {get; set;}//Added for D2C
    @AuraEnabled public String Funded_Insurance {get; set;}//Added for D2C
    @AuraEnabled public String DisplayLoanAmount {get; set;}//Added for D2C
    @AuraEnabled public String DisplayCrmIrr {get; set;}//Added for D2C
    @AuraEnabled public String DisplayTenure {get; set;}//Added for D2C
    @AuraEnabled public String DisplayImputedIrr {get; set;}//Added for D2C
    @AuraEnabled public String NetIrr {get; set;}//Added for D2C
    @AuraEnabled public String NetPayIns {get; set;}//Added for D2C
    @AuraEnabled public String NetPayOuts {get; set;}//Added for D2C
    @AuraEnabled public String AbbValue {get; set;}//Added for D2C
    @AuraEnabled public String AbbFlag {get; set;}//Added for D2C
    @AuraEnabled public String SliderLoanAmount {get; set;}//Added for D2C
    @AuraEnabled public String SliderTenure {get; set;}//Added for D2C
    @AuraEnabled public String Applicant_ETC {get; set;}//Added for D2C
    @AuraEnabled public String OwnHouseFlag {get; set;}//Added for D2C
    @AuraEnabled public Boolean expiringWithin60Days {get; set;}//Added for D2C //CFDI-1164
    @AuraEnabled public String selectedUser {get; set;}//CISP-6945
    @AuraEnabled public String RefId {get; set;}

    
    @AuraEnabled public String dealId {get; set;}//Added for handling multiple vehicle details for Tractor Product Type
    @AuraEnabled public String installmentType {get; set;}
    @AuraEnabled public String firstEMIDate {get; set;}
    @AuraEnabled public String secondEMIDate {get; set;}
    @AuraEnabled public String StageName {get; set;} //cisp-20786
    @AuraEnabled public String notificationBody {get; set;}//SFTRAC-1117
    @AuraEnabled public String userId {get; set;}//SFTRAC-1117
    
    
    @AuraEnabled public Boolean fromProCredit {get; set;}
    @AuraEnabled public String pcdId {get; set;}
    @AuraEnabled public String Unique_Id {get; set;}
    @AuraEnabled public String Application_No {get; set;}
    @AuraEnabled public String Deal_No {get; set;}
    @AuraEnabled public String Maker_Id {get; set;}
    @AuraEnabled public String Product_Type {get; set;}
    @AuraEnabled public String kfsOtp {get; set;}
    @AuraEnabled public String kfsId {get; set;}
    @AuraEnabled public String mobileNumber {get; set;}
    
    
     
}