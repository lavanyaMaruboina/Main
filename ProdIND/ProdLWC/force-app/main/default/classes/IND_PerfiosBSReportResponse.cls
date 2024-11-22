/*------------------------------------------------------------
Author:        	Manish Baldota
Company:       	Persistent
Description:   	This class is wrapper class for Perfios Bank Account Statement API, 
Note:			Need to change the date and group after the confirmaiton from SP/SAI
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-21-2021      Manish Baldota      Created
01-10-2022		Manish Baldota		Accomodated after Respose changes in Report.
------------------------------------------------------------*/
public class IND_PerfiosBSReportResponse extends ParentAPIResponse {
	public cls_customerInfo customerInfo;
	public cls_statementdetails[] statementdetails;
	public cls_summaryInfo summaryInfo;
	public cls_monthlyDetails[] monthlyDetails;
	public cls_eODBalances[] eODBalances;
	public cls_top10FundsReceived[] top10FundsReceived;
	public cls_earningsToSalaryXns[] earningsToSalaryXns;
	public cls_eMIECSLOANXns[] eMIECSLOANXns;
	public cls_highValueDebitXns[] highValueDebitXns;
	public cls_top10FundsTransferred[] top10FundsTransferred;
	public cls_inwEMIBounceXns[] inwEMIBounceXns;
	public cls_regularCredits[] regularCredits;
	public cls_highValueCreditXns[] highValueCreditXns;
	public cls_regularDebits[] regularDebits;
	public cls_salaryXns[] salaryXns;
	public cls_bouncedOrPenalXns[] bouncedOrPenalXns;
	public cls_accountXns[] accountXns;
	public cls_AdditionalABBMonthlyDetails[] AdditionalABBMonthlyDetails;
	public cls_AdditionalSelfEmployedSummaryDetails[] AdditionalSelfEmployedSummaryDetails;
	public cls_AdditionalSelfEmployedMonthlyDetails[] AdditionalSelfEmployedMonthlyDetails;
	public cls_AdditionalSalariedSummaryDetails[] AdditionalSalariedSummaryDetails;
	public cls_AdditionalSalariedMonthlyDetails[] AdditionalSalariedMonthlyDetails;
	class cls_customerInfo {
		public String name;	//string
		public String address;	//string
		public String landline;	//string
		public String mobile;	//string
		public String email;	//string
		public String pan;	//string
		public String bank;	//string
	}
	class cls_statementdetails {
		public String fileName;	//string
		public String statementStatus;	//string
		public cls_customerInfo customerInfo;
		public cls_statementAccounts[] statementAccounts;
	}
	class cls_statementAccounts {
		public String accountNo;	//string
		public String accountType;	//string
		public String xnsStartDate;	//string:YYYY-MM-DD
		public String xnsEndDate;	//string:YYYY-MM-DD
	}
	class cls_summaryInfo {
		public String instName;	//string
		public String accNo;	//string
		public String accType;	//string
		public Integer fullMonthCount;	//1
		public String accountOpenDate;	//string
		public cls_total total;
		public cls_average average;
	}
	class cls_total {
		public Decimal bal10;	//1.5
		public Decimal bal15;	//1.5
		public Decimal bal20;	//1.5
		public Decimal bal25;	//1.5
		public Decimal bal5;	//1.5
		public Decimal balAvg;	//1.5
		public Decimal balLast;	//1.5
		public Decimal balMax;	//1.5
		public Decimal balMin;	//1.5
		public Decimal balOpen;	//1.5
		public Integer cashDeposits;	//1
		public Integer cashWithdrawals;	//1
		public Integer chqDeposits;	//1
		public Integer chqIssues;	//1
		public Integer credits;	//1
		public Integer creditsSC;	//1
		public Integer creditsSelf;	//1
		public Integer debits;	//1
		public Integer debitsSC;	//1
		public Integer debitsSelf;	//1
		public Integer earningsToSalaries;	//1
		public Decimal dpLimit;	//1.5
		public Integer emiOrLoans;	//1
		public Integer intPayDelay;	//1
		public Integer inwBounces;	//1
		public Integer inwEMIBounces;	//1
		public Integer loanDisbursals;	//1
		public Integer outwBounces;	//1
		public Integer salaries;	//1
		public Integer overdrawnDays;	//1
		public Decimal snLimit;	//1.5
		public Decimal totalCardSettlement;	//1.5
		public Decimal totalCashDeposit;	//1.5
		public Decimal totalCashWithdrawal;	//1.5
		public Decimal totalChqDeposit;	//1.5
		public Decimal totalChqIssue;	//1.5
		public Decimal totalCredit;	//1.5
		public Decimal totalCreditSC;	//1.5
		public Decimal totalCreditSelf;	//1.5
		public Decimal totalDebit;	//1.5
		public Decimal totalDebitSC;	//1.5
		public Decimal totalDebitSelf;	//1.5
		public Decimal totalEarningsToSalary;	//1.5
		public Decimal totalEmiOrLoan;	//1.5
		public Decimal totalHouseRent;	//1.5
		public Decimal totalInterestCharged;	//1.5
		public Decimal totalInvExpense;	//1.5
		public Decimal totalInvIncome;	//1.5
		public Decimal totalInwEMIBounce;	//1.5
		public Decimal totalLoanDisbursal;	//1.5
		public Decimal totalSalary;	//1.5
		public Integer xnsCount;	//1
	}
	class cls_average {
		public Decimal bal10;	//1.5
		public Decimal bal15;	//1.5
		public Decimal bal20;	//1.5
		public Decimal bal25;	//1.5
		public Decimal bal5;	//1.5
		public Decimal balAvg;	//1.5
		public Decimal balLast;	//1.5
		public Decimal balMax;	//1.5
		public Decimal balMin;	//1.5
		public Decimal balOpen;	//1.5
		public Integer cashDeposits;	//1
		public Integer cashWithdrawals;	//1
		public Integer chqDeposits;	//1
		public Integer chqIssues;	//1
		public Integer credits;	//1
		public Integer creditsSC;	//1
		public Integer creditsSelf;	//1
		public Integer debits;	//1
		public Integer debitsSC;	//1
		public Integer debitsSelf;	//1
		public Integer earningsToSalaries;	//1
		public Decimal dpLimit;	//1.5
		public Integer emiOrLoans;	//1
		public Integer intPayDelay;	//1
		public Integer inwBounces;	//1
		public Integer inwEMIBounces;	//1
		public Integer loanDisbursals;	//1
		public Integer outwBounces;	//1
		public Integer salaries;	//1
		public Integer overdrawnDays;	//1
		public Decimal snLimit;	//1.5
		public Decimal totalCardSettlement;	//1.5
		public Decimal totalCashDeposit;	//1.5
		public Decimal totalCashWithdrawal;	//1.5
		public Decimal totalChqDeposit;	//1.5
		public Decimal totalChqIssue;	//1.5
		public Decimal totalCredit;	//1.5
		public Decimal totalCreditSC;	//1.5
		public Decimal totalCreditSelf;	//1.5
		public Decimal totalDebit;	//1.5
		public Decimal totalDebitSC;	//1.5
		public Decimal totalDebitSelf;	//1.5
		public Decimal totalEarningsToSalary;	//1.5
		public Decimal totalEmiOrLoan;	//1.5
		public Decimal totalHouseRent;	//1.5
		public Decimal totalInterestCharged;	//1.5
		public Decimal totalInvExpense;	//1.5
		public Decimal totalInvIncome;	//1.5
		public Decimal totalInwEMIBounce;	//1.5
		public Decimal totalLoanDisbursal;	//1.5
		public Decimal totalSalary;	//1.5
		public Integer xnsCount;	//1
	}
	class cls_monthlyDetails {
		public Decimal bal10;	//1.5
		public Decimal bal15;	//1.5
		public Decimal bal20;	//1.5
		public Decimal bal25;	//1.5
		public Decimal bal5;	//1.5
		public Decimal balAvg;	//1.5
		public Decimal balLast;	//1.5
		public Decimal balMax;	//1.5
		public Decimal balMin;	//1.5
		public Decimal balOpen;	//1.5
		public Integer cashDeposits;	//1
		public Integer cashWithdrawals;	//1
		public Integer chqDeposits;	//1
		public Integer chqIssues;	//1
		public Integer credits;	//1
		public Integer creditsSC;	//1
		public Integer creditsSelf;	//1
		public Integer debits;	//1
		public Integer debitsSC;	//1
		public Integer debitsSelf;	//1
		public Integer earningsToSalaries;	//1
		public Decimal dpLimit;	//1.5
		public Integer emiOrLoans;	//1
		public Integer intPayDelay;	//1
		public Integer inwBounces;	//1
		public Integer inwEMIBounces;	//1
		public Integer loanDisbursals;	//1
		public String monthName;	//string:MMM-YY
		public Integer outwBounces;	//1
		public Integer salaries;	//1
		public String startDate;	//string:YYYY-MM-DD
		public Integer overdrawnDays;	//1
		public Decimal snLimit;	//1.5
		public Decimal totalCardSettlement;	//1.5
		public Decimal totalCashDeposit;	//1.5
		public Decimal totalCashWithdrawal;	//1.5
		public Decimal totalChqDeposit;	//1.5
		public Decimal totalChqIssue;	//1.5
		public Decimal totalCredit;	//1.5
		public Decimal totalCreditSC;	//1.5
		public Decimal totalCreditSelf;	//1.5
		public Decimal totalDebit;	//1.5
		public Decimal totalDebitSC;	//1.5
		public Decimal totalDebitSelf;	//1.5
		public Decimal totalEarningsToSalary;	//1.5
		public Decimal totalEmiOrLoan;	//1.5
		public Decimal totalHouseRent;	//1.5
		public Decimal totalInterestCharged;	//1.5
		public Decimal totalInvExpense;	//1.5
		public Decimal totalInvIncome;	//1.5
		public Decimal totalInwEMIBounce;	//1.5
		public Decimal totalLoanDisbursal;	//1.5
		public Decimal totalSalary;	//1.5
		public Integer xnsCount;	//1
	}
	class cls_eODBalances {
		//public String date;	//string:YYYY-MM-DD
		public Decimal balance;	//1.5
	}
	class cls_top10FundsReceived {
		public String month;	//string:MMM-YY
		public String category;	//string
		public Decimal amount;	//1.5
	}
	class cls_earningsToSalaryXns {
		//public String date;	//string:YYYY-MM-DD
		public String chqNo;	//string
		public String narration;	//string
		public Decimal amount;	//1.5
		public String category;	//string
		public Decimal balance;	//1.5
	}
	class cls_eMIECSLOANXns {
		//public String date;	//string:YYYY-MM-DD
		public String chqNo;	//string
		public String narration;	//string
		public Decimal amount;	//1.5
		public String category;	//string
		public Decimal balance;	//1.5
	}
	class cls_highValueDebitXns {
		//public String date;	//string:YYYY-MM-DD
		public String chqNo;	//string
		public String narration;	//string
		public Decimal amount;	//1.5
		public String category;	//string
		public Decimal balance;	//1.5
	}
	class cls_top10FundsTransferred {
		public String month;	//string:MMM-YY
		public String category;	//string
		public Decimal amount;	//1.5
	}
	class cls_inwEMIBounceXns {
		//public String date;	//string:YYYY-MM-DD
		public String chqNo;	//string
		public String narration;	//string
		public Decimal amount;	//1.5
		public String category;	//string
		public Decimal balance;	//1.5
	}
	class cls_regularCredits {
		//public Integer group;	//1
		//public String date;	//string:YYYY-MM-DD
		public String chqNo;	//string
		public String narration;	//string
		public Decimal amount;	//1.5
		public String category;	//string
		public Decimal balance;	//1.5
	}
	class cls_highValueCreditXns {
		//public String date;	//string:YYYY-MM-DD
		public String chqNo;	//string
		public String narration;	//string
		public Decimal amount;	//1.5
		public String category;	//string
		public Decimal balance;	//1.5
	}
	class cls_regularDebits {
		//public Integer group;	//1
		//public String date;	//string:YYYY-MM-DD
		public String chqNo;	//string
		public String narration;	//string
		public Decimal amount;	//1.5
		public String category;	//string
		public Decimal balance;	//1.5
	}
	class cls_salaryXns {
		//public String date;	//string:YYYY-MM-DD
		public String chqNo;	//string
		public String narration;	//string
		public Decimal amount;	//1.5
		public String category;	//string
		public Decimal balance;	//1.5
	}
	class cls_bouncedOrPenalXns {
		//public String date;	//string:YYYY-MM-DD
		public String chqNo;	//string
		public String narration;	//string
		public Decimal amount;	//1.5
		public String category;	//string
		public Decimal balance;	//1.5
	}
	class cls_accountXns {
		public String accountNo;	//string
		public String accountType;	//string
		public cls_xns[] xns;
	}
	class cls_xns {
		//public String date;	//string:YYYY-MM-DD
		public String chqNo;	//string
		public String narration;	//string
		public Decimal amount;	//1.5
		public String category;	//string
		public Decimal balance;	//1.5
	}
	class cls_AdditionalABBMonthlyDetails {
		public String monthName;	//string:MMM-YY
		public Decimal averageMonthlyBalance;	//1.5
		public Decimal netInflows;	//1.5
		public Decimal totalNetInflow;	//1.5
	}
	class cls_AdditionalSelfEmployedSummaryDetails {
		public Decimal consolidatedABB;	//1.5
		public Decimal totalAvgEODBalance;	//1.5
		public String isCompletedMonthsLessThan3;	//string
	}
	class cls_AdditionalSelfEmployedMonthlyDetails {
		public String monthName;	//string:MMM-YY
		public Decimal inwReturnPercent;	//1.5
		public Decimal avgUtilization;	//1.5
		public Decimal unusedLimit;	//1.5
		public Integer outflows;	//1
		public Decimal totalOutflow;	//1.5
		public Integer inflows;	//1
		public Decimal totalInflow;	//1.5
		public Decimal netInflows;	//1.5
		public Decimal totalNetInflow;	//1.5
	}
	class cls_AdditionalSalariedSummaryDetails {
		public Decimal consolidatedABB;	//1.5
		public Decimal avgSalary;	//1.5
		public Decimal avgIncome;	//1.5
		public Decimal avgObligation;	//1.5
		public Decimal latest3MAvgSalary;	//1.5
		public String isCalSalAmountVariationMoreThan50Percent;	//string
		public String isCompletedMonthsLessThan3;	//string
		public Decimal avgOfCalSalaryForThePeriod;	//1.5
		public Decimal totalObligation;	//1.5
		public Decimal totalSalary;	//1.5
		public Decimal totalIncome;	//1.5
		public Decimal foirSalary;	//1.5
		public Decimal foirIncome;	//1.5
		public Decimal totalAvgEODBalance;	//1.5
	}
	class cls_AdditionalSalariedMonthlyDetails {
		public String monthName;	//string:MMM-YY
		public Decimal averageEODBalance;	//1.5
		public Decimal inwReturnPercent;	//1.5
		public Integer outflows;	//1
		public Decimal totalOutflow;	//1.5
		public Integer inflows;	//1
		public Decimal totalInflow;	//1.5
		public Decimal netInflows;	//1.5
		public Decimal totalNetInflow;	//1.5
		public Decimal totalCalSalaryForTheMonth;	//1.5
		public Decimal calSalAmountVariation;	//1.5
	}	
}