/*------------------------------------------------------------
Author:        Bhushan Charde
Company:       Persistent Systems
Description:   This class is wrapper class for the Perfios ITR Report API response 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-23-2021      Bhushan Charde    Created
------------------------------------------------------------*/
public class IND_PerfiosGSTReportResponse extends ParentAPIResponse { 
    
    public class Gstr1AvgB2bBillValueList{}
    public class Gstr1B2bInvoiceCountList{}
    public class Gstr1B2bRevenueList{}
    public class Gstr1DebitNoteCountList{}
    public class Gstr2aCreditNoteCountList{}
    public class Gstr1ExpInvoiceCountList{}
    public class Gstr1ExpRevenueList{}
    public class Gstr1B2clRevenueList{}
    public class Gstr1B2clInvoiceCountList{}
    public class Gstr1AvgB2clBillValueList{}
    
 	public class Gstr2aNewClientCountList {
		public String returnPeriod{get;set;}
		public Integer count{get;set;}
	}

	public class Gstr2aTotalExpenseList {
		public String returnPeriod{get;set;}
		public Double expense{get;set;}
	}

	public class Gstr2aTopNSupplierInvoiceSummaryList {
		public String client{get;set;}
		public Integer count{get;set;}
		public Double concentration{get;set;}
		public Double expense{get;set;}
	}

	public List<Gstr1AvgB2bBillValueList> gstr1AvgB2bBillValueList{get;set;}
	public List<Gstr1AvgB2clBillValueList> gstr1AvgB2clBillValueList{get;set;}
	public List<Gstr1B2bInvoiceCountList> gstr1B2bInvoiceCountList{get;set;}
	public List<Gstr1B2bRevenueList> gstr1B2bRevenueList{get;set;}
	public List<Gstr1B2clInvoiceCountList> gstr1B2clInvoiceCountList{get;set;}
	public List<Gstr1B2clRevenueList> gstr1B2clRevenueList{get;set;}
	public List<Gstr1B2bInvoiceCountList> gstr1B2csDocumentCountList{get;set;}
	public List<Gstr1B2bRevenueList> gstr1B2csRevenueList{get;set;}
	public List<Gstr1B2bInvoiceCountList> gstr1CreditNoteCountList{get;set;}
	public List<Gstr1DebitNoteCountList> gstr1DebitNoteCountList{get;set;}
	public List<Gstr1DebitNoteCountList> gstr1ExpInvoiceCountList{get;set;}
	public List<Gstr1ExpRevenueList> gstr1ExpRevenueList{get;set;}
	public List<Gstr1FilingStatusList> gstr1FilingStatusList{get;set;}
	public List<Gstr1InvoiceTypesList> gstr1InvoiceTypesList{get;set;}
	public List<Gstr1B2bInvoiceCountList> gstr1NewClientCountList{get;set;}
	public List<Gstr1NewClientRevenueContributionList> gstr1NewClientRevenueContributionList{get;set;}
	public List<Gstr1B2bInvoiceCountList> gstr1RepeatClientCountList{get;set;}
	public List<Gstr1NewClientRevenueContributionList> gstr1RepeatClientRevenueContributionList{get;set;}
	public List<Gstr1RevenueMovementList> gstr1RevenueMovementList{get;set;}
	public List<Gstr1RevenueMovementTrendList> gstr1RevenueMovementTrendList{get;set;}
	public List<Gstr1B2bInvoiceCountList> gstr1StatesPresentList{get;set;}
	public List<Gstr1TaxSlabsList> gstr1TaxSlabsList{get;set;}
	public List<Gstr1NewClientRevenueContributionList> gstr1TopFiveClientRevenueContributionList{get;set;}
	public List<Gstr1TopNClientInvoiceSummaryList> gstr1TopNClientInvoiceSummaryList{get;set;}
	public List<Gstr1NewClientRevenueContributionList> gstr1TopTenClientRevenueContributionList{get;set;}
	public List<Gstr1B2bInvoiceCountList> gstr1TotalInvoiceCountList{get;set;}
	public List<Gstr1B2bRevenueList> gstr1TotalRevenueList{get;set;}
	public List<Gstr1AvgB2bBillValueList> gstr2aAvgB2bBillValueList{get;set;}
	public List<Gstr1B2bInvoiceCountList> gstr2aB2bInvoiceCountList{get;set;}
	public List<Gstr2aCreditNoteCountList> gstr2aCreditNoteCountList{get;set;}
	public List<Gstr1RevenueMovementList> gstr2aExpenseMovementList{get;set;}
	public List<Gstr1RevenueMovementTrendList> gstr2aExpenseMovementTrendList{get;set;}
	public List<Gstr1InvoiceTypesList> gstr2aInvoiceTypesList{get;set;}
	public List<Gstr2aNewClientCountList> gstr2aNewClientCountList{get;set;}
	public List<Gstr1NewClientRevenueContributionList> gstr2aNewClientExpenseContributionList{get;set;}
	public List<Gstr2aNewClientCountList> gstr2aRepeatClientCountList{get;set;}
	public List<Gstr1NewClientRevenueContributionList> gstr2aRepeatClientExpenseContributionList{get;set;}
	public List<Gstr2aNewClientCountList> gstr2aStatesPresentList{get;set;}
	public List<Gstr1TaxSlabsList> gstr2aTaxSlabsList{get;set;}
	public List<Gstr1NewClientRevenueContributionList> gstr2aTopFiveClientExpenseContributionList{get;set;}
	public List<Gstr2aTopNSupplierInvoiceSummaryList> gstr2aTopNSupplierInvoiceSummaryList{get;set;}
	public List<Gstr1NewClientRevenueContributionList> gstr2aTopTenClientExpenseContributionList{get;set;}
	public List<Gstr2aNewClientCountList> gstr2aTotalB2bClientList{get;set;}
	public List<Gstr2aTotalCreditNoteAmountToExpenseRatioList> gstr2aTotalCreditNoteAmountToExpenseRatioList{get;set;}
	public List<Gstr2aTotalExpenseList> gstr2aTotalExpenseList{get;set;}
	public List<Gstr3bBalanceLiabilityList> gstr3bBalanceLiabilityList{get;set;}
	public List<Gstr1FilingStatusList> gstr3bFilingStatusList{get;set;}
	public List<Gstr3bInwardTaxableSuppliesTaxList> gstr3bInwardTaxableSuppliesTaxList{get;set;}
	public List<Gstr3bInwardTaxableSuppliesTaxList> gstr3bInwardTaxableSuppliesTaxableValueList{get;set;}
	public List<Gstr3bNetITCAvlList> gstr3bNetITCAvlList{get;set;}
	public List<Gstr3bInwardTaxableSuppliesTaxList> gstr3bNonGstOutwardTaxableSuppliesTaxList{get;set;}
	public List<Gstr3bInwardTaxableSuppliesTaxList> gstr3bNonGstOutwardTaxableSuppliesTaxableValueList{get;set;}
	public List<Gstr3bInwardTaxableSuppliesTaxList> gstr3bOutwardTaxableSuppliesNilRatedTaxList{get;set;}
	public List<Gstr3bInwardTaxableSuppliesTaxList> gstr3bOutwardTaxableSuppliesNilRatedTaxableValueList{get;set;}
	public List<Gstr3bInwardTaxableSuppliesTaxList> gstr3bOutwardTaxableSuppliesTaxList{get;set;}
	public List<Gstr3bInwardTaxableSuppliesTaxList> gstr3bOutwardTaxableSuppliesTaxableValueList{get;set;}
	public List<Gstr3bInwardTaxableSuppliesTaxList> gstr3bOutwardTaxableSuppliesZeroRatedTaxList{get;set;}
	public List<Gstr3bInwardTaxableSuppliesTaxList> gstr3bOutwardTaxableSuppliesZeroRatedTaxableValueList{get;set;}
	public List<Gstr3bInwardTaxableSuppliesTaxList> gstr3bTotalTaxList{get;set;}
	public List<Gstr3bInwardTaxableSuppliesTaxList> gstr3bTotalTaxableValueList{get;set;}
	public TaxpayerInformation taxpayerInformation{get;set;}
	public List<Gstr1HsnSummaryList> gstr1HsnSummaryList{get;set;}
	public List<NilRatedList> nilRatedList{get;set;}
	public List<NilRatedList> nonGstList{get;set;}
	public List<NilRatedList> gstExemptedList{get;set;}

	public class TaxpayerInformation {
		public String gstin{get;set;}
		public String constitutionOfBusiness{get;set;}
		public String centerJurisdiction{get;set;}
		public String centerJurisdictionCode{get;set;}
		public String dateOfCancellation{get;set;}
		public String taxpayerType{get;set;}
		public String legalName{get;set;}
		public String lastUpdatedDate{get;set;}
		public String natureOfBusiness{get;set;}
		public PrincipalPlaceOfBusiness principalPlaceOfBusiness{get;set;}
		public String dateOfRegistration{get;set;}
		public String stateJurisdiction{get;set;}
		public String stateJurisdictionCode{get;set;}
		public String gstnStatus{get;set;}
		public String tradeName{get;set;}
		public String natureOfBusinessActivity{get;set;}
	}

	public class NilRatedList {
		public String returnPeriod{get;set;}
		public Object revenue{get;set;}
	}

	public class PrincipalPlaceOfBusiness {
		public PrincipalPlaceOfBusinessAddress principalPlaceOfBusinessAddress{get;set;}
	}

	public class Gstr3bInwardTaxableSuppliesTaxList {
		public String returnPeriod{get;set;}
		public Integer taxableValue{get;set;}
	}

	public class PrincipalPlaceOfBusinessAddress {
		public String buildingName{get;set;}
		public String doorNumber{get;set;}
		public String floorNo{get;set;}
		public String longitude{get;set;}
		public String location{get;set;}
		public String lattitude{get;set;}
		public String pincode{get;set;}
		public String street{get;set;}
		public String stateName{get;set;}
	}

	public class Gstr1RevenueMovementTrendList {
		public String returnPeriod{get;set;}
		public String trend{get;set;}
	}

	public class Gstr3bNetITCAvlList {
		public String returnPeriod{get;set;}
		public Double available{get;set;}
	}

	public class Gstr1NewClientRevenueContributionList {
		public String returnPeriod{get;set;}
		public Double contribution{get;set;}
	}

	public class Gstr1TaxSlabsList {
		public String returnPeriod{get;set;}
		public String slabs{get;set;}
	}

	public class Gstr2aTotalCreditNoteAmountToExpenseRatioList {
		public String returnPeriod{get;set;}
		public Object value{get;set;}
	}

	public class Gstr1TopNClientInvoiceSummaryList {
		public String client{get;set;}
		public Integer count{get;set;}
		public Double concentration{get;set;}
		public Double revenue{get;set;}
	}

	public class Gstr1RevenueMovementList {
		public String returnPeriod{get;set;}
		public Object movement{get;set;}
	}

	public class Gstr3bBalanceLiabilityList {
		public String returnPeriod{get;set;}
		public Double liability{get;set;}
	}

	public class Gstr1HsnSummaryList {
		public String returnPeriod{get;set;}
		public String summary{get;set;}
	}

	public class Gstr1FilingStatusList {
		public String returnPeriod{get;set;}
		public Object dof{get;set;}
	}

	public class Gstr1InvoiceTypesList {
		public String returnPeriod{get;set;}
		public String invoiceTypes{get;set;}
	}
}