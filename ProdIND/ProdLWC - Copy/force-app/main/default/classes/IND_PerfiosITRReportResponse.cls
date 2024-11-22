/*------------------------------------------------------------
Author:        Thilak Bondiga
Company:       Persistent Systems
Description:   This class is wrapper class for the Perfios ITR Report API response 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-19-2021      Thilak Bondiga      Created
------------------------------------------------------------*/
public class IND_PerfiosITRReportResponse  extends ParentAPIResponse {    
	
    /*public class BankAccountDtls {
		public List<PriBankDetails> priBankDetails {get;set;} 
		public List<AddtnlBankDetails> addtnlBankDetails {get;set;} 

		public BankAccountDtls(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'priBankDetails') {
							priBankDetails = arrayOfPriBankDetails(parser);
						} else if (text == 'addtnlBankDetails') {
							addtnlBankDetails = arrayOfAddtnlBankDetails(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'BankAccountDtls consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class CapGain {
		public Integer totalLongTerm {get;set;} 
		public Integer totalShortTerm {get;set;} 
		public Integer totalCapGains {get;set;} 
		public ItrDetails itrDetails {get;set;} 
        
		public CapGain(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'totalLongTerm') {
							totalLongTerm = parser.getIntegerValue();
						} else if (text == 'totalShortTerm') {
							totalShortTerm = parser.getIntegerValue();
						} else if (text == 'totalCapGains') {
							totalCapGains = parser.getIntegerValue();
						} else {
							System.debug(LoggingLevel.WARN, 'CapGain consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
    
	public class TaxPaid {
		public Integer selfAssessmentTax {get;set;} 
		public Integer tds {get;set;} 
		public Integer balTaxPayable {get;set;} 
		public Integer refundDue {get;set;} 
		public Integer advanceTax {get;set;} 
		public Integer tcs {get;set;} 
		public Integer totalTaxesPaid {get;set;} 

		public TaxPaid(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'selfAssessmentTax') {
							selfAssessmentTax = parser.getIntegerValue();
						} else if (text == 'tds') {
							tds = parser.getIntegerValue();
						} else if (text == 'balTaxPayable') {
							balTaxPayable = parser.getIntegerValue();
						} else if (text == 'refundDue') {
							refundDue = parser.getIntegerValue();
						} else if (text == 'advanceTax') {
							advanceTax = parser.getIntegerValue();
						} else if (text == 'tcs') {
							tcs = parser.getIntegerValue();
						} else if (text == 'totalTaxesPaid') {
							totalTaxesPaid = parser.getIntegerValue();
						} else {
							System.debug(LoggingLevel.WARN, 'TaxPaid consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class AddtnlBankDetails {
		public Object bankAccountType {get;set;} 
		public Object useForRefund {get;set;} 
		public Object bankAccountNo {get;set;} 
		public Object bankName {get;set;} 
		public Object ifscCode {get;set;} 

		public AddtnlBankDetails(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'bankAccountType') {
							bankAccountType = parser.readValueAs(Object.class);
						} else if (text == 'useForRefund') {
							useForRefund = parser.readValueAs(Object.class);
						} else if (text == 'bankAccountNo') {
							bankAccountNo = parser.readValueAs(Object.class);
						} else if (text == 'bankName') {
							bankName = parser.readValueAs(Object.class);
						} else if (text == 'ifscCode') {
							ifscCode = parser.readValueAs(Object.class);
						} else {
							System.debug(LoggingLevel.WARN, 'AddtnlBankDetails consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Itr {
		public String date_Z {get;set;} // in json: date
		public Integer deductionsUnderScheduleVIA {get;set;} 
		public PersonalInfo personalInfo {get;set;} 
		public Integer lateFilingFee234F {get;set;} 
		public Integer totalSurcharge {get;set;} 
		public Integer incChargeTaxSplRate111A112 {get;set;} 
		public Integer incomeFromSal {get;set;} 
		public String origRetFiledDate {get;set;} 
		public Losses losses {get;set;} 
		public String type {get;set;} 
		public String ackNoOriginalReturn {get;set;} 
		public TaxPaid taxPaid {get;set;} 
		public Integer totTaxRelief {get;set;} 
		public String fy {get;set;} 
		public Integer rebate87A {get;set;} 
		public Integer taxPayableOnRebate {get;set;} 
		public Integer totIncFromOS {get;set;} 
		public Integer intrstPayUs234A {get;set;} 
		public Integer intrstPayUs234B {get;set;} 
		public ProfBusGain profBusGain {get;set;} 
		public Integer intrstPayUs234C {get;set;} 
		public Integer aggregateIncome {get;set;} 
		public BankAccountDtls bankAccountDtls {get;set;} 
		public Integer aggregateTaxInterestLiability {get;set;} 
		public CapGain capGain {get;set;} 
		public Integer incomeFromHP {get;set;} 
		public Integer grossTaxLiability {get;set;} 
		public Integer incChargeableTaxSplRates {get;set;} 
		public Integer totTaxPlusIntrstPay {get;set;} 
		public Integer taxPayableOnTotInc {get;set;} 
		public Integer totalIncome {get;set;} 
		public TdSonSalaries tdSonSalaries {get;set;} 
		public Integer educationCess {get;set;} 
		public Integer grossTotalIncome {get;set;} 
		public String receiptNo {get;set;} 
		public String ay {get;set;} 
		public Integer netTaxLiability {get;set;} 
		public Integer netAgricultureIncomeOrOtherIncomeForRate {get;set;} 
		public Integer totalIntrstPay {get;set;} 
		public Integer totalExemptInc {get;set;} 
		public String returnType {get;set;} 

		public Itr(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'date') {
							date_Z = parser.getText();
						} else if (text == 'deductionsUnderScheduleVIA') {
							deductionsUnderScheduleVIA = parser.getIntegerValue();
						} else if (text == 'personalInfo') {
							personalInfo = new PersonalInfo(parser);
						} else if (text == 'lateFilingFee234F') {
							lateFilingFee234F = parser.getIntegerValue();
						} else if (text == 'totalSurcharge') {
							totalSurcharge = parser.getIntegerValue();
						} else if (text == 'incChargeTaxSplRate111A112') {
							incChargeTaxSplRate111A112 = parser.getIntegerValue();
						} else if (text == 'incomeFromSal') {
							incomeFromSal = parser.getIntegerValue();
						} else if (text == 'origRetFiledDate') {
							origRetFiledDate = parser.getText();
						} else if (text == 'losses') {
							losses = new Losses(parser);
						} else if (text == 'type') {
							type = parser.getText();
						} else if (text == 'ackNoOriginalReturn') {
							ackNoOriginalReturn = parser.getText();
						} else if (text == 'taxPaid') {
							taxPaid = new TaxPaid(parser);
						} else if (text == 'totTaxRelief') {
							totTaxRelief = parser.getIntegerValue();
						} else if (text == 'fy') {
							fy = parser.getText();
						} else if (text == 'rebate87A') {
							rebate87A = parser.getIntegerValue();
						} else if (text == 'taxPayableOnRebate') {
							taxPayableOnRebate = parser.getIntegerValue();
						} else if (text == 'totIncFromOS') {
							totIncFromOS = parser.getIntegerValue();
						} else if (text == 'intrstPayUs234A') {
							intrstPayUs234A = parser.getIntegerValue();
						} else if (text == 'intrstPayUs234B') {
							intrstPayUs234B = parser.getIntegerValue();
						} else if (text == 'profBusGain') {
							profBusGain = new ProfBusGain(parser);
						} else if (text == 'intrstPayUs234C') {
							intrstPayUs234C = parser.getIntegerValue();
						} else if (text == 'aggregateIncome') {
							aggregateIncome = parser.getIntegerValue();
						} else if (text == 'bankAccountDtls') {
							bankAccountDtls = new BankAccountDtls(parser);
						} else if (text == 'aggregateTaxInterestLiability') {
							aggregateTaxInterestLiability = parser.getIntegerValue();
						} else if (text == 'capGain') {
							capGain = new CapGain(parser);
						} else if (text == 'incomeFromHP') {
							incomeFromHP = parser.getIntegerValue();
						} else if (text == 'grossTaxLiability') {
							grossTaxLiability = parser.getIntegerValue();
						} else if (text == 'incChargeableTaxSplRates') {
							incChargeableTaxSplRates = parser.getIntegerValue();
						} else if (text == 'totTaxPlusIntrstPay') {
							totTaxPlusIntrstPay = parser.getIntegerValue();
						} else if (text == 'taxPayableOnTotInc') {
							taxPayableOnTotInc = parser.getIntegerValue();
						} else if (text == 'totalIncome') {
							totalIncome = parser.getIntegerValue();
						} else if (text == 'tdSonSalaries') {
							tdSonSalaries = new TdSonSalaries(parser);
						} else if (text == 'educationCess') {
							educationCess = parser.getIntegerValue();
						} else if (text == 'grossTotalIncome') {
							grossTotalIncome = parser.getIntegerValue();
						} else if (text == 'receiptNo') {
							receiptNo = parser.getText();
						} else if (text == 'ay') {
							ay = parser.getText();
						} else if (text == 'netTaxLiability') {
							netTaxLiability = parser.getIntegerValue();
						} else if (text == 'netAgricultureIncomeOrOtherIncomeForRate') {
							netAgricultureIncomeOrOtherIncomeForRate = parser.getIntegerValue();
						} else if (text == 'totalIntrstPay') {
							totalIntrstPay = parser.getIntegerValue();
						} else if (text == 'totalExemptInc') {
							totalExemptInc = parser.getIntegerValue();
						} else if (text == 'returnType') {
							returnType = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Itr consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class ProfBusGain {
		public Integer profGainSpeculativeBus {get;set;} 
		public Integer profGainSpecifiedBus {get;set;} 
		public Integer profGainNoSpecBus {get;set;} 
		public Integer totProfBusGain {get;set;} 

		public ProfBusGain(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'profGainSpeculativeBus') {
							profGainSpeculativeBus = parser.getIntegerValue();
						} else if (text == 'profGainSpecifiedBus') {
							profGainSpecifiedBus = parser.getIntegerValue();
						} else if (text == 'profGainNoSpecBus') {
							profGainNoSpecBus = parser.getIntegerValue();
						} else if (text == 'totProfBusGain') {
							totProfBusGain = parser.getIntegerValue();
						} else {
							System.debug(LoggingLevel.WARN, 'ProfBusGain consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class AddressInfo {
		public String localityOrArea {get;set;} 
		public String roadOrStreet {get;set;} 
		public String pinCode {get;set;} 
		public String residenceNo {get;set;} 
		public String cityOrTownOrDistrict {get;set;} 
		public String state {get;set;} 
		public String residenceName {get;set;} 

		public AddressInfo(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'localityOrArea') {
							localityOrArea = parser.getText();
						} else if (text == 'roadOrStreet') {
							roadOrStreet = parser.getText();
						} else if (text == 'pinCode') {
							pinCode = parser.getText();
						} else if (text == 'residenceNo') {
							residenceNo = parser.getText();
						} else if (text == 'cityOrTownOrDistrict') {
							cityOrTownOrDistrict = parser.getText();
						} else if (text == 'state') {
							state = parser.getText();
						} else if (text == 'residenceName') {
							residenceName = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'AddressInfo consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class ItrDetails {
		public List<FilingDetailsList> filingDetailsList {get;set;} 
		public ItrInfoList itrInfoList {get;set;} 

		public ItrDetails(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'filingDetailsList') {
							filingDetailsList = arrayOfFilingDetailsList(parser);
						} else if (text == 'itrInfoList') {
							itrInfoList = new ItrInfoList(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'ItrDetails consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class FilingDetailsList {
		public String filingDatesDiff {get;set;} 
		public String isItrNotFiledForPrevYear {get;set;} 
		public String filingDatesLTSixMonths {get;set;} 

		public FilingDetailsList(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'filingDatesDiff') {
							filingDatesDiff = parser.getText();
						} else if (text == 'isItrNotFiledForPrevYear') {
							isItrNotFiledForPrevYear = parser.getText();
						} else if (text == 'filingDatesLTSixMonths') {
							filingDatesLTSixMonths = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'FilingDetailsList consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Losses {
		public Integer lossesOfCurrentYearCarriedFwd {get;set;} 
		public Integer currentYearLoss {get;set;} 
		public Integer broughtFwdLossesSetoff {get;set;} 

		public Losses(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'lossesOfCurrentYearCarriedFwd') {
							lossesOfCurrentYearCarriedFwd = parser.getIntegerValue();
						} else if (text == 'currentYearLoss') {
							currentYearLoss = parser.getIntegerValue();
						} else if (text == 'broughtFwdLossesSetoff') {
							broughtFwdLossesSetoff = parser.getIntegerValue();
						} else {
							System.debug(LoggingLevel.WARN, 'Losses consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class TdSonSalaries {
		public Object tdSonSalary {get;set;} 
		public Integer totalTDSonSalaries {get;set;} 

		public TdSonSalaries(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'tdSonSalary') {
							tdSonSalary = parser.readValueAs(Object.class);
						} else if (text == 'totalTDSonSalaries') {
							totalTDSonSalaries = parser.getIntegerValue();
						} else {
							System.debug(LoggingLevel.WARN, 'TdSonSalaries consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class PersonalInfo {
		public String firstName {get;set;} 
		public String surNameOrOrgName {get;set;} 
		public AddressInfo addressInfo {get;set;} 
		public String emailAddress {get;set;} 
		public String address {get;set;} 
		public String dob {get;set;} 
		public String aadhaarCardNo {get;set;} 
		public String name {get;set;} 
		public String mobileNo {get;set;} 
		public String pan {get;set;} 
		public String employerCategory {get;set;} 

		public PersonalInfo(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'firstName') {
							firstName = parser.getText();
						} else if (text == 'surNameOrOrgName') {
							surNameOrOrgName = parser.getText();
						} else if (text == 'addressInfo') {
							addressInfo = new AddressInfo(parser);
						} else if (text == 'emailAddress') {
							emailAddress = parser.getText();
						} else if (text == 'address') {
							address = parser.getText();
						} else if (text == 'dob') {
							dob = parser.getText();
						} else if (text == 'aadhaarCardNo') {
							aadhaarCardNo = parser.getText();
						} else if (text == 'name') {
							name = parser.getText();
						} else if (text == 'mobileNo') {
							mobileNo = parser.getText();
						} else if (text == 'pan') {
							pan = parser.getText();
						} else if (text == 'employerCategory') {
							employerCategory = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'PersonalInfo consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class PriBankDetails {
		public Object bankAccountType {get;set;} 
		public Object useForRefund {get;set;} 
		public String bankAccountNo {get;set;} 
		public String bankName {get;set;} 
		public String ifscCode {get;set;} 

		public PriBankDetails(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'bankAccountType') {
							bankAccountType = parser.readValueAs(Object.class);
						} else if (text == 'useForRefund') {
							useForRefund = parser.readValueAs(Object.class);
						} else if (text == 'bankAccountNo') {
							bankAccountNo = parser.getText();
						} else if (text == 'bankName') {
							bankName = parser.getText();
						} else if (text == 'ifscCode') {
							ifscCode = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'PriBankDetails consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class ItrInfoList {
		public List<Itr> itr {get;set;} 

		public ItrInfoList(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'itr') {
							itr = arrayOfItr(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'ItrInfoList consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
    private static List<FilingDetailsList> arrayOfFilingDetailsList(System.JSONParser p) {
        List<FilingDetailsList> res = new List<FilingDetailsList>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new FilingDetailsList(p));
        }
        return res;
    }
    private static List<PriBankDetails> arrayOfPriBankDetails(System.JSONParser p) {
        List<PriBankDetails> res = new List<PriBankDetails>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new PriBankDetails(p));
        }
        return res;
    }
    private static List<AddtnlBankDetails> arrayOfAddtnlBankDetails(System.JSONParser p) {
        List<AddtnlBankDetails> res = new List<AddtnlBankDetails>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new AddtnlBankDetails(p));
        }
        return res;
    }
    private static List<Itr> arrayOfItr(System.JSONParser p) {
        List<Itr> res = new List<Itr>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Itr(p));
        }
        return res;
    }*/
    
}