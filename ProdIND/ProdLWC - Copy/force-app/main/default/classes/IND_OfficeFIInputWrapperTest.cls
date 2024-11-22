@isTest
public class IND_OfficeFIInputWrapperTest {
    
    @testSetup
    static void testDataSetup() {
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
        doc2.Document_Type__c = System.Label.Residence_Front_View;
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
    public static void testAcceptedSaveOfficeFI(){
        IND_OfficeFIInputWrapper deserializedInputWrapper = createOfficeFIInputWrapperJSON(System.Label.FI_Accepted);
        String serializedInputWrapper = JSON.serialize(deserializedInputWrapper);
        
        Test.startTest();
        Boolean status = IND_OfficeFIReadOnlyController.saveOfficeFI(serializedInputWrapper);
        Test.stopTest();
        
        System.assertEquals(true, status);
    }


    
    
    @isTest
    public static void verifyWrapperInput(){
        IND_OfficeFIInputWrapper.StringField objStrField = new IND_OfficeFIInputWrapper.StringField();
        objStrField.label = 'Label1';
        objStrField.value = 'Value1';  
        
        IND_OfficeFIInputWrapper.BooleanField objBooleanField = new IND_OfficeFIInputWrapper.BooleanField();
        objBooleanField.label = 'Label1';
        objBooleanField.value = false;  
        
        IND_OfficeFIInputWrapper.DecimalField objDecimalField = new IND_OfficeFIInputWrapper.DecimalField();
        objDecimalField.label = 'Label1';
        objDecimalField.value = 1.0;  
        
        
        IND_OfficeFIInputWrapper.DatetimeField objDatetimeField = new IND_OfficeFIInputWrapper.DatetimeField();
        objDatetimeField.label = 'Label1';
        objDatetimeField.value = System.now();  
        
        
        IND_OfficeFIInputWrapper objInput = new IND_OfficeFIInputWrapper();
        objInput.buildingfrontview = objStrField;
        System.assert(objInput.buildingfrontview.label == 'Label1');
        
        //Decimal
        objInput.area = objDecimalField;  
      
        
        
        
        
        //String
        objInput.residenceFIStatus = objStrField;
        objInput.IBLFieldInvestigationName = objStrField;
        objInput.signCapture = objStrField;
        objInput.touringOrTransferableJob = objStrField;
        objInput.geocoderLatitudeAndLongitude = objStrField;
        objInput.coordinatesVerfied = objStrField;
        objInput.buildingfrontview = objStrField;
        objInput.signatureView = objStrField;
        objInput.employerbusinessname = objStrField;
        objInput.officebusinesstype = objStrField;
        objInput.businesspremise = objStrField;
        objInput.officebusinessboard = objStrField;
        objInput.officebusinesssizesqft = objStrField;
        objInput.location = objStrField;
        objInput.nameofpersonmet = objStrField;
        objInput.relationship = objStrField;
        objInput.politicalphoto = objStrField;
        objInput.category = objStrField;
        objInput.profile = objStrField;
        objInput.currentExperienceYears = objStrField;
        objInput.totalExperienceYears = objStrField;
        objInput.applicantRecognized = objStrField;
        
        objInput.touringOrTransferrableJob = objStrField;
        objInput.monthlyIncomeAsPerFIVisit = objStrField;
        objInput.incomeAsPerFIVisit = objStrField;
        
        objInput.landPhoto = objStrField;
        objInput.typeOfcrop = objStrField;
        objInput.uploadPattaDocument = objStrField;
        objInput.noOfCropsPerAnnum = objStrField;
        objInput.pricePerUnit = objStrField;
        objInput.fiLatitudeAndLongitude = objStrField;
        
        
        objInput.fiAcceptedRejected = objStrField;
        objInput.typeOfHouse = objStrField;
        objInput.electricityConnectionPresent = objStrField;
        objInput.accessToTubewells = objStrField;
        objInput.irrigationSystemPresent = objStrField;
        objInput.noOfCattle = objStrField;
        objInput.declaredIncomeDuringApplication = objStrField;
        objInput.typeOfGoodsSold = objStrField;
        objInput.noOfEmployees = objStrField;
        objInput.inHouseSecurityPresent = objStrField;
        objInput.posMachine = objStrField;
        objInput.acInstalled = objStrField;
        objInput.averageNoOfCustomershourly = objStrField;
        objInput.averageTicketSize = objStrField;
        objInput.numberOfOperationalHoursInADay = objStrField;
        objInput.monthlySales = objStrField;
        objInput.annualTurnOver = objStrField;
        objInput.profitMargin = objStrField;
        objInput.estimatedIncomeAsPerFI = objStrField;
        objInput.finalIncome = objStrField;
        objInput.latestWaterBillamountPaidmonthly = objStrField;
        objInput.paymentProofShown = objStrField;
        objInput.latestElectricityBillAmountPaidMont = objStrField;
        objInput.latestTelephoneBillAmount = objStrField;
        objInput.ownEquipmentTools = objStrField;
        objInput.listOfEquipmentToolsOwned = objStrField;
        objInput.affiliationToEcommerce = objStrField;
        objInput.averageProfessionalFeeService = objStrField;
        objInput.noOfServiceRequestsCateredInMonth = objStrField;
        objInput.estimatedServiceIncomeasperFI = objStrField;
        objInput.typesOfVehiclesOwned = objStrField;
        objInput.noOfVehiclesOwned = objStrField;
        objInput.estimatedIncomeAsPerMonth = objStrField;
        objInput.noOfContractsAwardedInLast1year = objStrField;
        objInput.doYouHaveAnyGovermentContracts = objStrField;
        objInput.estimatedTotalMonthlyIncome = objStrField;
        objInput.NoOfpropertiesRented = objStrField;
        objInput.incomePerMonthProperty = objStrField;
        objInput.incomePerMonth = objStrField;
        objInput.uploadRentAgreementReciept = objStrField;
        objInput.uploadPensionDocument = objStrField;
        objInput.noOfAttempts = objStrField;
        objInput.fiObservation = objStrField;
        objInput.fiFeedback = objStrField;
        objInput.officeFIAcceptedRejected = objStrField;
        objInput.officeFIStatus = objStrField;
        
        
        //DateTime
        objInput.officeFICompletionTime = objDatetimeField;
        objInput.fiRequestGenerationDT = objDatetimeField;  
        
        //Boolean
        objInput.sameAddressAsInApplication = objBooleanField;
        objInput.areCoordinatesMatching = objBooleanField;
        objInput.yeildPerAcre = objBooleanField;
        objInput.isMobileJourneyCompleted = objBooleanField;
        
        IND_OfficeFIInputWrapper objResult =  IND_OfficeFIInputWrapper.parse(JSON.serialize(objInput));
        System.assert(objResult != null);
        
        
    }
    
    
    public static IND_OfficeFIInputWrapper createOfficeFIInputWrapperJSON(String status) {
        IND_OfficeFIInputWrapper inputWrapper = new IND_OfficeFIInputWrapper();
        List<Field_Investigation__c> lstFIRecords = [SELECT ID,
                                                     Name,
                                                     Product__c,
                                                     Address_Line_1__c,
                                                     Address_Line_2__c,
                                                     City__c,
                                                     Pin_Code__c,
                                                     State__c,
                                                     Landmark__c,
                                                     Phone_Number__c,
                                                     Mobile__c,
                                                     Employer_Business_Name__c,
                                                     Current_experience_years__c,
                                                     Total_Experience_Years__c,
                                                     Income__c,
                                                     Estimated_Service_Income_as_per_FI__c,
                                                     Are_Co_ordinates_Matching_If_Amber__c,
                                                     Remarks__c,
                                                     SENP_Agriculture_Income__c,
                                                     SENP_Own_Shop_Income__c,
                                                     SENP_Service_oriented_Income__c,
                                                     SENP_Transporter_Income__c,
                                                     SENP_Contractor_Income__c,
                                                     SENP_Rental_Income__c,
                                                     SENP_Pension_Income__c,
                                                     Case__c,
                                                     Case__r.OwnerId,
                                                     Case__r.Origin,
                                                     Case__r.Type,
                                                     Case__r.Applicant__c,
                                                     Case__r.Loan_Application__c,
                                                     Case__r.Loan_Application__r.StageName,
                                                     Case__r.Loan_Application__r.Sub_Stage__c,
                                                     Case__r.Loan_Application__r.Vehicle_Type__c,
                                                     Case__r.Loan_Application__r.Product_Type__c,
                                                     Case__r.Loan_Application__r.Sanction_Status__c
                                                     FROM Field_Investigation__c
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
        }
        return inputWrapper;
    }
    
}