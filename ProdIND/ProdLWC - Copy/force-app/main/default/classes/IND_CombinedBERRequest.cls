public class IND_CombinedBERRequest {
    public String Proposal_Based_On;	//Borrower
	public String Product;	//T
	public String VehicleType;	//New
	public String LoanAmount;	//1401035
	public String Channel;	//TRACTOR
	public String CallType;	//Combined_BRE
	public String emiAmountFor12Months;
	//public cls_ApplicationDetails[] ApplicationDetails;
	public List<cls_ApplicationDetails> ApplicationDetails;
	public cls_LoanDetails LoanDetails;
	//public cls_AssetLoanDetails[] AssetLoanDetails;
	public List<cls_AssetLoanDetails> AssetLoanDetails;
    
    
    public class cls_ApplicationDetails {
		public String Lead_Id;	//AC6578870_469518636552
		public String applicantType;	//Borrower
		public String applicantName;	//
		public String dateOfBirth;	//1990-07-17
		public String typeOfBuyer;	//0
		public Integer noOfVehiclesGreaterthan4W;	//0
		public Integer earningMemebers;	//2
		public Integer assetsAtHome;	//3
		public String pastRepaymentTrack;
		public String Score;
		public cls_agriDetailsInfo agriDetailsInfo;
		//public cls_workProfileDetails[] workProfileDetails;
		public List<cls_workProfileDetails> workProfileDetails;
		public Integer familyMemebersCount;	//1
		public cls_expenseDetails expenseDetails;
		//public cls_addressDetails[] addressDetails;
		public List<cls_addressDetails> addressDetails;
		public cls_incomeDetails incomeDetails;
	}
    public class cls_agriDetailsInfo {
		public String cropsGrown;	//FICO team will move this field to cropdetails array
		public String landValue;	//1000000
		public String landIrrigationSource;	//TUBEWELL
		public String landHoldingType;	//3
		public Integer noOfDairyAnimals;	//4
		public String agriLandAcres;	//3
		public String farmerProfile;	//3
		public String kccLoanlast3yrs;	//
		public List<cls_cropDetails> cropDetails;
		public cls_assetCosumptionDetails[] assetCosumptionDetails;
	}
    public class cls_cropDetails {
		//public String cropsGrown;
		public String cropName;	//MAIZE
		public Integer noOfAcresInCropGrown;	//0
		public Integer yieldQuintalPerAcre;	//0
		public Integer soldPrice;	//0
		public Integer netAgriIncome1;	//0
	}
    public class cls_assetCosumptionDetails {
		public Integer noOfHoursRan;	//0
		public Integer ratePerHour;	//0
		public Integer dieselRate;	//0
		public Decimal dieselCosumption;	//0
		public Integer assetBasedExpenses;	//0
		public Integer assetBasedTotalIncome;	//0
		public Integer netAgriIncome2;	//0
	}
    public class cls_workProfileDetails {
		public String employmentCategory;	//
		public String employmentSubCategory;	//
		public Integer incomefromEmploymentCategory;	//18000
		public Integer incomeUtilization;	//6
		public Integer nonAgriIncome;	//0
	}
    public class cls_expenseDetails {
		public Integer educationExpense;	//0
		public Integer medicalExpense;	//0
		public Integer vehicleExpense;	//0
		public Integer existingLoanObligations;	//0
		public Integer marriageExpense;	//0
		public Integer expensesPerPersonPerMonth;	//0
		public Integer livelihoodTotalExpenses;	//0
		public Integer totalLiabilityExpenses;	//0
	}
    public class cls_addressDetails {
		public String addressType;	//O
		public String addressLine;
		public String residenceType;
		public Integer stabilityOfResidence;	//0
		public String pincode;
		public String houseType;
		public String city;
		public String district;
		public String districtCategory;
		public String state;	//36
		public String stateCodeIBL;	//L
	}
    public class cls_incomeDetails {
		public String incomeSource;
		public String modeOfIncome;	//
		public Integer netAnnualIncome;	//0
		public Integer agriNetIncome1;	//0
		public Integer nonAgriNetIncome;	//0
		public String agriNetIncome2;
	}
    public class cls_LoanDetails {
		public Integer loanEMI12M;	//8000
		public Integer requestedLoanAmount;	//10000
		public String repaymentFrequency;	//
		public String assetDeployment;	//
		public String commercialActivityProof;	
		public Integer requestedTenure;	//12
		public String sourceOfMarginAmount;	//CASH
		public String purposeOfPurchase; 
	}
    public class cls_AssetLoanDetails {
		public Integer marginAmount;	//7000
		public Integer purchasePrice;	//3000
		public String dealerCategory;	//Silver
		public String vehicleType;	//NEW
		public String assetSegment;	//TRACTOR
		public String variantCode;	//T245U1022
		public String variantName;	//M245S325.5 7.5*1614.9*28GBOIBMSPTOPS1022
		public String annualInstallmentAmount;	//70000
		public String requestedLoanAmount;	//70000
		public String requestedTenure;	//24
		public String repaymentFrequency;
		public String assetBasedCategory;
	}
    
    public IND_CombinedBERRequest(String loanAppId, String vehicleId){
		System.debug('+++IN');

		Integer totalLandValue = 0;
        Integer noCattleValue = 0 ;
		String assetDev = '';
		String commercialAct ='';
		String sourceMarginAmt = '';
		String cropsGrownStr ='';
		String noOfVehicleStr ='';
		Integer vdloanEMI12M = 0;
		String districtCategry ='';
		Integer totalIncome = 0;

		Integer totalEducationExpense = 0;
		Integer totalMedicalExpense = 0;
		Integer totalVehicleExpense = 0;
		Integer totalExistingLoanObligations = 0;
		Integer totalMarriageExpense = 0;
		String kccLast3Year = 'NO'; //SFTRAC-2246
		//Get Current Loan Application Record
		Opportunity loanAppRec = [Select Id, Name, Lead_number__c, StageName, Sub_Stage__c, Product_Type__c, Vehicle_Type__c, Requested_loan_amount__c, 
									Customer_Type__c From Opportunity Where Id =: loanAppId Limit 1];
        System.debug('+++CBRE loanAppRec '+loanAppRec);
        
		//Get Loan Application KYC details 
		Map<Id,List<Documents__c>> applicantDocumentsMap = new Map<Id,List<Documents__c>>();

        List<Documents__c> docLst = [SELECT Id,Proof_of_Identity_POI__c, Proof_of_Address_POA__c, KYC_DOB__c, PAN_No__c, Applicant__c ,KYC_City__c,KYC_Pin_Code__c,KYC_State__c,Addresss_Type__c,Document_Type__c,
										KYC_Address_Line_1__c, KYC_Address_Line_2__c, KYC_District__c FROM Documents__c 
                                        WHERE Applicant__c IN (SELECT Id FROM Applicant__c WHERE Opportunity__c =:loanAppId )
                                        WITH SECURITY_ENFORCED ];
        for(Documents__c doc: docLst){
            List<Documents__c> newDocLst = new List<Documents__c>();
            if(applicantDocumentsMap.containsKey(doc.Applicant__c)){
                newDocLst = applicantDocumentsMap.get(doc.Applicant__c);
                newDocLst.add(doc);
                applicantDocumentsMap.put(doc.Applicant__c,newDocLst);
            }else{
                newDocLst.add(doc);
                applicantDocumentsMap.put(doc.Applicant__c,newDocLst);
            }
        }

		//Get FI Case created under Loan Application 
        ID caseFIRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FI').getRecordTypeId();
        
		Set<Id> caseIdSet = new Set<Id>();
		Map<Id, Case> caseIdMap = new Map<Id, Case>([SELECT Id, CaseNumber, Subject, RecordTypeId, Type, Status, Applicant__c FROM Case Where Loan_Application__c =: loanAppId AND RecordTypeId =:caseFIRecordType]);
		System.debug('+++CBRE caseIdMap '+caseIdMap);
		caseIdSet.addAll(caseIdMap.keySet());
		System.debug('+++caseIdSet ' + caseIdSet);
        
		//Get FI Record created under all the FI Case of current Loan Application 

		List<Field_Investigation__c> fiRecList = [SELECT Id, Name, Scheme_Type__c, Residence_Type__c, House_ownership__c, Existing_no_of_vehicles__c, Land_Irrigation_source__c, Sub_Scheme_Type__c, How_many_members_in_the_Family__c,Work_order_details__c,
										What_is_the_source_of_margin_money__c, Since_how_long_in_Agri_commercial__c, House_Type__c, Number_of_Earning_Member_in_Family__c, Assets_at_Home_Sum_up__c, Case__r.Applicant__c,
										(SELECT Id, Land_holding_In_acres__c, Approximate_value_of_Agri_Land__c From Loan_Holding_Details__r),(SELECT Id, Nos_of_Cattle__c From Cattle_Informations__r),
										(SELECT Id, Name, Crop_Type__c, Land_Survey_No__c, Crop_Grown_in_acre__c, Field_Investigation__c, Net_Income__c, Crop_Master__c, Crop_Cultivated_Year__c, Crop_Master__r.Yield_Quintal_Per_Acre__c, Crop_Master__r.Name, Crop_Master__r.Market_Price_Rs_Per_Quintal__c  FROM Crop_Details__r),
										(SELECT Id, Name, Usage_Type__c, Existing_Proposed__c, Tractor_Harvester__c, Nos_of_Hours_run_in_year__c,Per_Hour_Rate__c, Diesal_Rate_Hr__c, Diesal_counsumption_hr__c, Expenses__c, Total_Income__c, Net_Income__c, Field_Investigation__c FROM Viability_of_Existing_Proposed_Tractors__r),
										(SELECT Id, Name, Category_Master__c, Utilization__c, Total_Income__c, Field_Investigation__c,Category_Master__r.Category__c, Category_Master__r.Sub_category__c, Category_Master__r.Income__c FROM Non_Agri_Incomes__r),
										(SELECT Id, Name, Type__c, Expenses_and_Investment_Type__c, Amount__c, Field_Investigation__c FROM Total_Expense_and_investments__r),
										(SELECT Id,EMI_Amount__c,Field_Investigation__c,Last_EMI_Paid_Date__c,LOAN_AMOUNT__c,Loan_number__c, Loan_Start_Date__c, Loan_Type__c,Total_Remarks_by_FI_Agent__c FROM KCC_And_Other_Loan_Informations__r Where Loan_Type__c = 'KCC')
										FROM Field_Investigation__c where Case__c IN: caseIdSet];
		System.debug('+++CBRE fiRecList '+fiRecList);

		//Applicant and FI map
        Map<Id,List<Field_Investigation__c>> applicantFIMap = new Map<Id,List<Field_Investigation__c>>();
		for (Field_Investigation__c fiRec : fiRecList) {
			if (!applicantFIMap.containsKey(fiRec.Case__r.Applicant__c)) {
				applicantFIMap.put(fiRec.Case__r.Applicant__c, new List<Field_Investigation__c>());
			}
			applicantFIMap.get(fiRec.Case__r.Applicant__c).add(fiRec);
		}
		System.debug('+++CBRE applicantFIMap '+applicantFIMap);

		//Get all Applicants of current Loan Application
		List<Applicant__c> applicantList = [SELECT Id,Contact_number__c,Opportunity__r.Lead_number__c,Customer_First_Name__c,
											Customer_Last_Name__c,Loan_Amount__c,Current_Same_As_Permanent__c,Is_Existing_Customer__c,Applicant_Type__c,Name, 
											applicant_number__c, Date_of_Birth__c, (SELECT Id, Name, Income_Source_for_Tractor__c, Applicant__c, Total_Income__c FROM Income_Details__r), 
											(SELECT Id, Name, Score__c, Applicant__c FROM CIBIL_Details__r) FROM Applicant__c WHERE Opportunity__c =: loanAppId];
		System.debug('+++CBRE applicantList '+applicantList);
        
		//Get all Vehicle Details record of current Loan Application
		List<Vehicle_Detail__c> vehicleDetailList = new List<Vehicle_Detail__c>();
		Final_Term__c finalTermRec = new Final_Term__c();
		
			vehicleDetailList = [SELECT Id, Name, Vehicle_type__c, Vehicle_Category__c, Parent_Deal_number__c, Registration_Number_Format__c, Customer_Code__c, NOC_Number__c, Ben_Code__c,Repayment_Frequency__c,
													What_is_emi_convyed_to_customer__c, Loan_Amount__c, Vehicle_Registration_Number__c, Vehicle_Verified__c, Engine_number__c, Vehicle_SubCategory__c,
                                                    Chassis_number__c, Serial_number__c, Vehicle_Delivered__c, Vehicle_SubType__c, Required_Tenure__c, How_much_margin_amount_paid_to_dealer__c,
													What_is_thePrice_of_TractorHarvester__c, Variant_Code__c, Variant__c FROM Vehicle_Detail__c WHERE Loan_Application__c =: loanAppId AND Id =:vehicleId];
													
			finalTermRec = [SELECT Id, Installment_Type__c, Installment_Frequency__c, EMI_Amount__c, Loan_Amount__c FROM Final_Term__c Where Vehicle_Detail__c =: vehicleId LIMIT 1];
		
		
		System.debug('+++CBRE vehicleDetailList '+vehicleDetailList);

		//Ben Code master Map
		/*List<Benefi__c> benCodeMasterList = [SELECT id,Ben_code__c, Dealer_Code__c,Grade__c FROM Benefi__c];
		Map<String,String> benCodeMap = new Map<String,String>();
		for(Benefi__c benCodeRec: benCodeMasterList){
			if(!benCodeMap.containsKey(benCodeRec.Ben_code__c)){
				benCodeMap.put(benCodeRec.Ben_code__c,benCodeRec.Grade__c);
			}
		}*/

		List<Benefi__c> benCode = new List<Benefi__c>();
		if(!vehicleDetailList.isEmpty() && vehicleDetailList[0].Ben_Code__c != null) {
            benCode = [SELECT id,Dealer_Code__c,Grade__c FROM Benefi__c where Ben_code__c  =:vehicleDetailList[0].Ben_Code__c Limit 1];
        }

		//Geo State master Map
		List<Geo_State_Masters__c> geoStateMasterList = [SELECT Id,Name, NeSL_State_Code__c, State_Code__c  FROM Geo_State_Masters__c];
		Map<String,String> stateCodeMap = new Map<String,String>();
		for(Geo_State_Masters__c geoRec: geoStateMasterList){
			if(!stateCodeMap.containsKey(geoRec.Name)){
				stateCodeMap.put(geoRec.Name,geoRec.NeSL_State_Code__c);
			}
		}
        
		//Start of Request Body

		Proposal_Based_On ='Borrower';
		Product = loanAppRec.Product_Type__c == 'Tractor' ? 'T' : '';
		VehicleType = loanAppRec.Vehicle_Type__c;
        LoanAmount =  '';
		Channel = loanAppRec.Product_Type__c.toUpperCase();
		CallType = 'Combined_BRE';
		// Initialize ApplicationDetails array
		List<cls_ApplicationDetails> applicationDetailsList = new List<cls_ApplicationDetails>();

		for (Applicant__c appRec : applicantList) {
			cls_ApplicationDetails appDetail = new cls_ApplicationDetails();

			//get FI record for the current loop Applicant
			List<Field_Investigation__c> fiRecord = applicantFIMap.get(appRec.Id);

			//If Applicant is borrower than some fix values for LoanDetail object of Request body
			if(appRec.Applicant_Type__c == 'Borrower'){
				assetDev = fiRecord != null && fiRecord[0].Sub_Scheme_Type__c != null ? fiRecord[0].Sub_Scheme_Type__c : '';
				commercialAct = fiRecord != null && fiRecord[0].Work_order_details__c != null ? fiRecord[0].Work_order_details__c : '';
				sourceMarginAmt = fiRecord != null && fiRecord[0].What_is_the_source_of_margin_money__c != null ? fiRecord[0].What_is_the_source_of_margin_money__c : '';
			}

			appDetail.Lead_Id = appRec.Opportunity__r.Lead_number__c +'_'+appRec.applicant_number__c;
			appDetail.applicantType = appRec.Applicant_Type__c;
			appDetail.applicantName = appRec.Name;
			//appDetail.dateOfBirth = String.valueof(appRec.Date_of_Birth__c);
			if(applicantDocumentsMap.containsKey(appRec.Id)){
				for(Documents__c doc: applicantDocumentsMap.get(appRec.Id)){
					if(doc.Proof_of_Identity_POI__c == true){
						appDetail.dateOfBirth =	doc.KYC_DOB__c!=null ? String.valueof(doc.KYC_DOB__c) : '';
					}
				}
			}
			appDetail.typeOfBuyer = fiRecord != null && fiRecord[0].Scheme_Type__c != null ? fiRecord[0].Scheme_Type__c == 'FTU' ? '0' : fiRecord[0].Scheme_Type__c == 'REPEAT BUYER' ? '1' : '' : '' ;
			
			//noOfVehicleStr = fiRecord != null && fiRecord[0].Existing_no_of_vehicles__c != null ? fiRecord[0].Existing_no_of_vehicles__c : '';
			noOfVehicleStr = fiRecord != null ? nullCheckString(fiRecord[0].Existing_no_of_vehicles__c) : '';
            if(noOfVehicleStr == 'More than two 4 wheeler'){
				appDetail.noOfVehiclesGreaterthan4W = 3;
			}else if(noOfVehicleStr == 'More than one 4 wheeler'){
				appDetail.noOfVehiclesGreaterthan4W = 2;
			}else if(noOfVehicleStr == 'Only 4 wheeler or 2 wheeler'){
				appDetail.noOfVehiclesGreaterthan4W = 1;
			}else {
				appDetail.noOfVehiclesGreaterthan4W = 0;
			}
			
			//appDetail.earningMemebers = fiRecord != null && fiRecord[0].Number_of_Earning_Member_in_Family__c != null ? Integer.valueof(fiRecord[0].Number_of_Earning_Member_in_Family__c) : 0;
			if (fiRecord != null && fiRecord.size() > 0 && fiRecord[0].Number_of_Earning_Member_in_Family__c != null) {
				if (fiRecord[0].Number_of_Earning_Member_in_Family__c == '>5') {
					appDetail.earningMemebers = 6;
				} else {
					appDetail.earningMemebers = Integer.valueOf(fiRecord[0].Number_of_Earning_Member_in_Family__c);
				}
			} else {
				appDetail.earningMemebers = 0;
			}
			//appDetail.assetsAtHome = fiRecord != null && fiRecord[0].Assets_at_Home_Sum_up__c != null ? Integer.valueof(fiRecord[0].Assets_at_Home_Sum_up__c) : 0;
			
			// Check if the field has values
			if (fiRecord != null && fiRecord[0].Assets_at_Home_Sum_up__c != null) {
				List<String> selectedValues = fiRecord[0].Assets_at_Home_Sum_up__c.split(';');
				Integer numberOfSelectedValues = selectedValues.size();
				System.debug('Number of selected values: ' + numberOfSelectedValues);
				appDetail.assetsAtHome = numberOfSelectedValues;
			} else {
				System.debug('No values selected in the Multi-Select Picklist');
				appDetail.assetsAtHome = 0;
			}
			appDetail.pastRepaymentTrack = '';
			//system.debug('appRec.CIBIL_Details__r[0] '+appRec.CIBIL_Details__r[0]);
			appDetail.Score = appRec.CIBIL_Details__r.size() > 0 ? nullCheckString(appRec.CIBIL_Details__r[0].Score__c): '';

			//Assign FI child records values to Request body
            if(fiRecord != null){
					if(fiRecord[0].Loan_Holding_Details__r.size() > 0){
						for(Land_Holding_Detail__c landHolding : fiRecord[0].Loan_Holding_Details__r){
							totalLandValue += landHolding.Approximate_value_of_Agri_Land__c!=null ? Integer.valueOf(landHolding.Approximate_value_of_Agri_Land__c):0;
						}
					}
                
					if(fiRecord[0].Cattle_Informations__r.size() > 0){
						for(Cattle_Information__c cattelInfoRec : fiRecord[0].Cattle_Informations__r){
							System.debug('+++CATTLE'+Integer.valueOf(cattelInfoRec.Nos_of_Cattle__c));
							noCattleValue += cattelInfoRec.Nos_of_Cattle__c!=null ? Integer.valueOf(cattelInfoRec.Nos_of_Cattle__c):0;
						}
					}
    
                
    
					List<cls_cropDetails> cropDetailList = new List<cls_cropDetails>();
					if(fiRecord[0].Crop_Details__r.size() > 0){
						for(Crop_Detail__c cropDetailRec : fiRecord[0].Crop_Details__r){
							cls_cropDetails cropDetail = new cls_cropDetails();
							if(cropDetailRec.Crop_Type__c == 'Kharif' && cropsGrownStr == ''){
								cropsGrownStr = 'Kharif';
							}else if (cropDetailRec.Crop_Type__c == 'Rabi' && cropsGrownStr == 'Kharif'){
								cropsGrownStr = 'Kharif + Rabi';
							}else if (cropDetailRec.Crop_Type__c == 'Summer' && cropsGrownStr == 'Kharif + Rabi'){
								cropsGrownStr = 'Kharif + Rabi + Summer';
							}
		
							cropDetail.cropName = nullCheckString(cropDetailRec.Crop_Master__r.Name);
							cropDetail.noOfAcresInCropGrown = cropDetailRec.Crop_Grown_in_acre__c != null ? Integer.valueOf(cropDetailRec.Crop_Grown_in_acre__c) : 0;
							cropDetail.yieldQuintalPerAcre = cropDetailRec.Crop_Master__r.Yield_Quintal_Per_Acre__c != null ? Integer.valueOf(cropDetailRec.Crop_Master__r.Yield_Quintal_Per_Acre__c) : 0;
							cropDetail.soldPrice =cropDetailRec.Crop_Master__r.Market_Price_Rs_Per_Quintal__c != null ?  Integer.valueOf(cropDetailRec.Crop_Master__r.Market_Price_Rs_Per_Quintal__c) : 0 ;
							cropDetail.netAgriIncome1 = 0 ;
							totalIncome += cropDetailRec.Crop_Cultivated_Year__c == 'Last Year' && cropDetailRec.Net_Income__c != null ? Integer.valueOf(cropDetailRec.Net_Income__c) : 0;
							cropDetailList.add(cropDetail);
						}
					}
                
					cls_agriDetailsInfo agriDetailsInfo = new cls_agriDetailsInfo();
					agriDetailsInfo.cropsGrown = cropsGrownStr;
					agriDetailsInfo.landValue = String.valueof(totalLandValue); //Land_Holding_Detail__c.Land_holding_In_acres__c (Add all the land value)
					agriDetailsInfo.landIrrigationSource = fiRecord[0].Land_Irrigation_source__c != null ? fiRecord[0].Land_Irrigation_source__c : '';
					agriDetailsInfo.landHoldingType = fiRecord != null && fiRecord[0].Sub_Scheme_Type__c != null ? fiRecord[0].Sub_Scheme_Type__c : '';
					agriDetailsInfo.noOfDairyAnimals = noCattleValue; // Cattle_Information__c.Nos_of_Cattle__c((Add all the Catttle value))
					agriDetailsInfo.agriLandAcres = '';
					agriDetailsInfo.farmerProfile = '';

					//SFTRAC-2246 start
					if(fiRecord[0].KCC_And_Other_Loan_Informations__r.size() > 0){
						Date today = Date.today();
						Date threeYearsAgo = today.addYears(-3);
						for(KCC_And_Other_Loan_Information__c kccRec : fiRecord[0].KCC_And_Other_Loan_Informations__r){
							Date givenDate = (kccRec.Loan_Start_Date__c);
							if (givenDate >= threeYearsAgo && givenDate <= today && kccLast3Year == 'NO') {
								kccLast3Year = 'YES';
							} else if(kccLast3Year == 'NO') {
								kccLast3Year = 'NO';
							}
						}                                   
					}
					//SFTRAC-2246 end
					/* commentted for SFTRAC-2246
					if(fiRecord[0].KCC_And_Other_Loan_Informations__r.size() > 0){
						agriDetailsInfo.kccLoanlast3yrs = 'YES';
					}else{
						agriDetailsInfo.kccLoanlast3yrs = 'NO';
					}*/
					agriDetailsInfo.kccLoanlast3yrs = kccLast3Year;	//SFTRAC-2246
					agriDetailsInfo.cropDetails = cropDetailList;
		
					List<cls_assetCosumptionDetails> assetCosumptionDetailList = new List<cls_assetCosumptionDetails>();
					if(fiRecord[0].Viability_of_Existing_Proposed_Tractors__r.size() > 0){
						for(Viability_of_Existing_Proposed_Tractor__c viablityEPTRec : fiRecord[0].Viability_of_Existing_Proposed_Tractors__r){
							cls_assetCosumptionDetails assetCosumptionDetail = new cls_assetCosumptionDetails();
							assetCosumptionDetail.noOfHoursRan = viablityEPTRec.Nos_of_Hours_run_in_year__c != null ? Integer.valueOf(viablityEPTRec.Nos_of_Hours_run_in_year__c): 0 ;
							assetCosumptionDetail.ratePerHour = viablityEPTRec.Per_Hour_Rate__c != null ? Integer.valueOf(viablityEPTRec.Per_Hour_Rate__c): 0;
							assetCosumptionDetail.dieselRate = Integer.valueOf(System.Label.diesel_rate);
							assetCosumptionDetail.dieselCosumption = viablityEPTRec.Diesal_counsumption_hr__c != null ? viablityEPTRec.Diesal_counsumption_hr__c : 0;
							assetCosumptionDetail.assetBasedExpenses = 0;
							assetCosumptionDetail.assetBasedTotalIncome = 0;
							assetCosumptionDetail.netAgriIncome2 = 0;
							assetCosumptionDetailList.add(assetCosumptionDetail);	
						}
					}
                
					agriDetailsInfo.assetCosumptionDetails = assetCosumptionDetailList;
					appDetail.agriDetailsInfo = agriDetailsInfo;
    
					List<cls_workProfileDetails> workProfileDetailList = new List<cls_workProfileDetails>();
					if(fiRecord[0].Non_Agri_Incomes__r.size() > 0){
						for(Non_Agri_Income__c nonAgriIncomeRec : fiRecord[0].Non_Agri_Incomes__r){
							cls_workProfileDetails workProfileDetail = new cls_workProfileDetails();
							workProfileDetail.employmentCategory = nullCheckString(nonAgriIncomeRec.Category_Master__r.Category__c);
							workProfileDetail.employmentSubCategory = nullCheckString(nonAgriIncomeRec.Category_Master__r.Sub_category__c);
							workProfileDetail.incomefromEmploymentCategory = Integer.valueOf(nonAgriIncomeRec.Category_Master__r.Income__c) ;
							workProfileDetail.incomeUtilization = Integer.valueOf(nonAgriIncomeRec.Utilization__c) ;
							workProfileDetail.nonAgriIncome = 0;
							totalIncome += Integer.valueOf(nonAgriIncomeRec.Total_Income__c);
							workProfileDetailList.add(workProfileDetail);
						}
					}
                
                	appDetail.workProfileDetails = workProfileDetailList;

                	appDetail.familyMemebersCount = Integer.valueOf(fiRecord[0].How_many_members_in_the_Family__c) != null ? Integer.valueOf(fiRecord[0].How_many_members_in_the_Family__c) : 0;
				
					if(fiRecord[0].Total_Expense_and_investments__r.size() > 0){
						for(Total_Expense_and_investment__c totalExpenInvestRec : fiRecord[0].Total_Expense_and_investments__r){
							if(totalExpenInvestRec.Type__c == 'Expense'){
								if(totalExpenInvestRec.Expenses_and_Investment_Type__c == 'Expenses for higher education of son / Daughter / Family member'){
									totalEducationExpense += Integer.valueOf(totalExpenInvestRec.Amount__c);
								}else if(totalExpenInvestRec.Expenses_and_Investment_Type__c == 'Approx Medical Expenses'){
									totalMedicalExpense += Integer.valueOf(totalExpenInvestRec.Amount__c);
								}else if(totalExpenInvestRec.Expenses_and_Investment_Type__c == 'Existing vehicle maintenance'){
									totalVehicleExpense += Integer.valueOf(totalExpenInvestRec.Amount__c);
								}else if(totalExpenInvestRec.Expenses_and_Investment_Type__c == 'Running Loan EMI Obligation(Monthly)'){
									totalExistingLoanObligations += Integer.valueOf(totalExpenInvestRec.Amount__c);
								}else if(totalExpenInvestRec.Expenses_and_Investment_Type__c == 'Upcoming Marriage expense (Approx) in the family in next 2 years'){
									totalMarriageExpense += Integer.valueOf(totalExpenInvestRec.Amount__c);
								}
							}
						}
						cls_expenseDetails expenseDetail = new cls_expenseDetails();
						expenseDetail.educationExpense = totalEducationExpense;
						expenseDetail.medicalExpense = totalMedicalExpense;
						expenseDetail.vehicleExpense = totalVehicleExpense;
						expenseDetail.existingLoanObligations = totalExistingLoanObligations;
						expenseDetail.marriageExpense = totalMarriageExpense;
						expenseDetail.expensesPerPersonPerMonth =  appDetail.familyMemebersCount != null ? appDetail.familyMemebersCount * 12 * 1000 : 0;
						expenseDetail.livelihoodTotalExpenses = 0;
						expenseDetail.totalLiabilityExpenses = 0;
						appDetail.expenseDetails = expenseDetail;
					}
				
					List<District_Master__c> districtMasterList = [SELECT Id, District_Code__c, Name, District_Category__c FROM District_Master__c];
					Map<String,String> districtMasterMAP = new Map<String,String>();
					for(District_Master__c districtMasterRec: districtMasterList){
						if(!districtMasterMAP.containsKey(districtMasterRec.Name)){
							districtMasterMAP.put((districtMasterRec.Name).toUpperCase(),districtMasterRec.District_Category__c);
						}
					}
					
					List<cls_addressDetails> addressDetailList = new List<cls_addressDetails>();
					if(applicantDocumentsMap.containsKey(appRec.Id)){
						for(Documents__c doc: applicantDocumentsMap.get(appRec.Id)){
							cls_addressDetails addressDetail = new cls_addressDetails();
							String addrType = '';
							if(doc.Proof_of_Address_POA__c == true){
								addrType = doc.Addresss_Type__c!=null ? doc.Addresss_Type__c:'';
								addressDetail.addressType = addrType == 'Current Residential Address' ? 'C' : addrType == 'Permanent Residential Address' ? 'P' : addrType == 'Office Address' ? 'O' : '' ;
								addressDetail.addressLine = doc.KYC_Address_Line_1__c+' , '+doc.KYC_Address_Line_2__c;
								addressDetail.residenceType = fiRecord[0].House_ownership__c!=null ? fiRecord[0].House_ownership__c:'' ;
								addressDetail.stabilityOfResidence = fiRecord[0].Since_how_long_in_Agri_commercial__c != null ? Integer.valueOf(fiRecord[0].Since_how_long_in_Agri_commercial__c) : 0;
								addressDetail.pincode = doc.KYC_Pin_Code__c!=null ? doc.KYC_Pin_Code__c:'';
								addressDetail.houseType = fiRecord[0].House_Type__c!=null ? fiRecord[0].House_Type__c:'';
								addressDetail.city = doc.KYC_City__c!=null ? doc.KYC_City__c:'';
								addressDetail.district = doc.KYC_District__c!=null ? doc.KYC_District__c:'';
								addressDetail.districtCategory = districtMasterMAP != null && doc.KYC_District__c != null && districtMasterMAP.containsKey((doc.KYC_District__c).toUpperCase())  ? districtMasterMAP.get((doc.KYC_District__c).toUpperCase()) != null ? districtMasterMAP.get((doc.KYC_District__c).toUpperCase()).toUpperCase() : '' :'';
								addressDetail.state = doc.KYC_State__c !=null ? doc.KYC_State__c.toUpperCase() : '';
								addressDetail.stateCodeIBL = doc.KYC_State__c !=null ? stateCodeMap.get(doc.KYC_State__c).toUpperCase():'';
								addressDetailList.add(addressDetail);
							}
						}
					}
					appDetail.addressDetails = addressDetailList;

					cls_incomeDetails incomeDetail = new cls_incomeDetails();
					incomeDetail.incomeSource = '';
					incomeDetail.modeOfIncome = '';
					incomeDetail.netAnnualIncome = totalIncome;
					incomeDetail.agriNetIncome1 = 0;
					incomeDetail.nonAgriNetIncome = 0;
					incomeDetail.agriNetIncome2 = '0';
					appDetail.incomeDetails = incomeDetail;

					/*if(appRec.Income_Details__r.size() > 0){
						for(Income_Details__c incomeRec: appRec.Income_Details__r){
							cls_incomeDetails incomeDetail = new cls_incomeDetails();
							incomeDetail.incomeSource = '';
							incomeDetail.modeOfIncome = '';
							incomeDetail.netAnnualIncome = incomeRec.Total_Income__c != null ? Integer.valueOf(incomeRec.Total_Income__c) : 0;
							incomeDetail.agriNetIncome1 = 0;
							incomeDetail.nonAgriNetIncome = 0;
							incomeDetail.agriNetIncome2 = '0';
							appDetail.incomeDetails = incomeDetail;
						}
					}*/
					
				}

			applicationDetailsList.add(appDetail);
			ApplicationDetails = applicationDetailsList;
		}

		String cfdStateCode = Utilities.getCFDStateCode([SELECT Id,Agent_BL_code__c FROM Opportunity WHERE Id =: loanAppId LIMIT 1].Agent_BL_code__c, 'T');
		List<TBM_Product_Variant_dt__c> dlpMasterList = [SELECT Id, State_Code__c, Product_Variant_Code__c, Segment_Grade__c,Unique_State_Code__c FROM TBM_Product_Variant_dt__c Where State_Code__c =: cfdStateCode];
		Map<String,String> dlpMasterMAP = new Map<String,String>();
        for(TBM_Product_Variant_dt__c dlpMasterRec: dlpMasterList){
            if(!dlpMasterMAP.containsKey(dlpMasterRec.Product_Variant_Code__c)){
                dlpMasterMAP.put(dlpMasterRec.Product_Variant_Code__c,dlpMasterRec.Segment_Grade__c);
            }
        }

		List<cls_AssetLoanDetails> assetLoanDetailList = new List<cls_AssetLoanDetails>();
		for(Vehicle_Detail__c vehicleRec: vehicleDetailList){
			cls_AssetLoanDetails assetLoanDetail = new cls_AssetLoanDetails();
			String paymentFrequency = '';
			String installMentType = '';
			assetLoanDetail.marginAmount = vehicleRec.How_much_margin_amount_paid_to_dealer__c !=null ? Integer.valueOf(vehicleRec.How_much_margin_amount_paid_to_dealer__c) : 0;
			assetLoanDetail.purchasePrice = vehicleRec.What_is_thePrice_of_TractorHarvester__c !=null ? Integer.valueOf(vehicleRec.What_is_thePrice_of_TractorHarvester__c.replace(',', '')) : 0;
			//assetLoanDetail.dealerCategory =  benCodeMap.get(vehicleRec.Ben_Code__c); //Silver
			assetLoanDetail.dealerCategory =  !benCode.isEmpty() && benCode[0].Grade__c!=null?benCode[0].Grade__c:'Others';
			assetLoanDetail.vehicleType = vehicleRec.Vehicle_Type__c.toUpperCase();
			assetLoanDetail.assetSegment = vehicleRec.Vehicle_SubType__c.toUpperCase();
			assetLoanDetail.variantCode = vehicleRec.Variant_Code__c != null ? vehicleRec.Variant_Code__c.toUpperCase(): '';
			assetLoanDetail.variantName = vehicleRec.Variant__c != null ? vehicleRec.Variant__c.toUpperCase(): '';
			
			installMentType = finalTermRec != null && finalTermRec.Installment_Type__c != null ? finalTermRec.Installment_Type__c : '';
			if(installMentType == 'Structured'){
				assetLoanDetail.repaymentFrequency = installMentType.toUpperCase();
			}else{
				assetLoanDetail.repaymentFrequency = finalTermRec != null && finalTermRec.Installment_Frequency__c != null ? finalTermRec.Installment_Frequency__c.toUpperCase() : vehicleDetailList != null && vehicleRec.Repayment_Frequency__c != null ? vehicleRec.Repayment_Frequency__c : '';
			}
            paymentFrequency = finalTermRec != null && finalTermRec.Installment_Frequency__c != null ? finalTermRec.Installment_Frequency__c.toUpperCase() : vehicleDetailList != null && vehicleRec.Repayment_Frequency__c != null ? vehicleRec.Repayment_Frequency__c.toUpperCase() : '';
			if(paymentFrequency == 'HALF YEARLY'){
				vdloanEMI12M = finalTermRec.EMI_Amount__c != null ? Integer.valueOf(finalTermRec.EMI_Amount__c * 2) : vehicleRec.What_is_emi_convyed_to_customer__c != null ? Integer.valueOf(vehicleRec.What_is_emi_convyed_to_customer__c * 2) : 0;
				assetLoanDetail.annualInstallmentAmount = vehicleRec.What_is_emi_convyed_to_customer__c !=null ?  String.valueOf(vehicleRec.What_is_emi_convyed_to_customer__c * 2): '';
			}else if(paymentFrequency == 'QUARTERLY'){
				vdloanEMI12M = finalTermRec.EMI_Amount__c != null ? Integer.valueOf(finalTermRec.EMI_Amount__c * 4) : vehicleRec.What_is_emi_convyed_to_customer__c != null ? Integer.valueOf(vehicleRec.What_is_emi_convyed_to_customer__c * 4) : 0;
				assetLoanDetail.annualInstallmentAmount = vehicleRec.What_is_emi_convyed_to_customer__c !=null ?  String.valueOf(vehicleRec.What_is_emi_convyed_to_customer__c * 4): '';
			}else if(paymentFrequency == 'MONTHLY'){
				vdloanEMI12M = finalTermRec.EMI_Amount__c != null ? Integer.valueOf(finalTermRec.EMI_Amount__c * 12) : vehicleRec.What_is_emi_convyed_to_customer__c != null ? Integer.valueOf(vehicleRec.What_is_emi_convyed_to_customer__c * 12) : 0;
				assetLoanDetail.annualInstallmentAmount = vehicleRec.What_is_emi_convyed_to_customer__c !=null ?  String.valueOf(vehicleRec.What_is_emi_convyed_to_customer__c * 12): '';
			}else if(paymentFrequency == 'BI-MONTHLY'){
				vdloanEMI12M = finalTermRec.EMI_Amount__c != null ? Integer.valueOf(finalTermRec.EMI_Amount__c * 6) : vehicleRec.What_is_emi_convyed_to_customer__c != null ? Integer.valueOf(vehicleRec.What_is_emi_convyed_to_customer__c * 6) : 0;
				assetLoanDetail.annualInstallmentAmount = vehicleRec.What_is_emi_convyed_to_customer__c !=null ?  String.valueOf(vehicleRec.What_is_emi_convyed_to_customer__c * 6): '';
			}
			assetLoanDetail.requestedLoanAmount = vehicleRec.Loan_Amount__c !=null ?  String.valueOf(vehicleRec.Loan_Amount__c): '';
			assetLoanDetail.requestedTenure = vehicleRec.Required_Tenure__c !=null ?  String.valueOf(vehicleRec.Required_Tenure__c): '';
			assetLoanDetail.assetBasedCategory = dlpMasterMAP != null && assetLoanDetail.variantCode != null && dlpMasterMAP.containsKey(assetLoanDetail.variantCode) ? dlpMasterMAP.get(assetLoanDetail.variantCode) : '';
			assetLoanDetailList.add(assetLoanDetail);
		}
		AssetLoanDetails = assetLoanDetailList;
		
		cls_LoanDetails LoanDetail = new cls_LoanDetails();
		LoanDetail.loanEMI12M = 0;
		LoanDetail.requestedLoanAmount = 0;
		LoanDetail.repaymentFrequency = '';

		if(assetDev == 'KYC or lease land holding'){
			LoanDetail.assetDeployment = 'AGRICULTURAL USES';
		}else if( assetDev == 'Agri Commercial'){
			LoanDetail.assetDeployment = 'AGRI CUM COMMERCIAL';
		}else if(assetDev == '0.1-2 acre' || assetDev == '2-4 acre' || assetDev == '>4 acre'){
			LoanDetail.assetDeployment = 'AGRI HIRING';
		}else{
			LoanDetail.assetDeployment ='';
		}
		LoanDetail.commercialActivityProof = commercialAct != '' ? commercialAct : '';
		LoanDetail.requestedTenure = 0;
		LoanDetail.sourceOfMarginAmount = sourceMarginAmt != '' ? sourceMarginAmt : '';
		LoanDetail.purposeOfPurchase ='';
		LoanDetails = LoanDetail;

		emiAmountFor12Months = String.valueOf(vdloanEMI12M);

    }

	//String null check method
	public static String nullCheckString(String stringValue) {
		system.debug('++++stringValue '+stringValue);
		if (stringValue != null && stringValue != '') {
			return stringValue;
		} else {
			return '';
		}
	  }
	  
	  //Integer and Dobule null check method
	  public static Integer nullCheckInteger(Integer integerValue) {
		system.debug('++++integerValue '+integerValue);
		if (integerValue != null) {
			return integerValue;
		} else {
			return 0;
		}
	  }
}