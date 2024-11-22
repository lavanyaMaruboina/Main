public Without Sharing class IND_InsertApplicantWrapper {
   
    public class Coborrower {
		public String type;
		public String name;
		public String contactNumber;
		public String waNumber;
		public Boolean incomesourceAvailable;
		public Decimal declearedIncome;
		public Boolean doYouHaveABankAccount;
		public Boolean doYouHaveABankAccountWithIIB;
		public Boolean wouldYouLiketoOpenBankAccountWithIIB;
	}

	public class Applicantdata {
		public List<LA> LA;
		public List<Borrower> Borrower;
		public List<Coborrower> Coborrower;
		public List<Document> document;
	}

	public List<Applicantdata> applicantdata;

	public class LA {
		public String type;
		public String LoanApplicationName;
		public String CloseDate;
		public String AccountName;
		public String Stage;
		public String NonDealerDSMName2;
		public String NonDealerDSMName1;
		public String vehicleType;
		public String vehicleSubCategory;
		public String parentDealNumber;
		public String registrationNumberFormat;
		public String vehicleRegistrationNumber;
		public Decimal nocRefrenceNumber;
	}

	public class Borrower {
		public String type;
		public String name;
		public String contactNumber;
		public String waNumber;
		public Boolean incomesourceAvailable;
		public Decimal declearedIncome;
		public Decimal requiredLoanAmount;
		public Boolean doYouHaveABankAccount;
		public Boolean doYouHaveABankAccountWithIIB;
		public Boolean wouldYouLiketoOpenBankAccountWithIIB;
	}

	public class Document {
		public String Applicanttype;
		public String imageName;
		public String documentSide;
		public String documentType;
		public String base64EncodedImage;
	}
    
    /*
	public class Applicantdata {
		public List<Loan> loan;
        public List<Document> document;
	}

	public List<Applicantdata> applicantdata;

	public class Loan { 
		public String type;
		public String LoanApplicationName;
		public String CloseDate;
		public String AccountName;
		public String Stage;
		public String NonDealerDSMName2;
		public String NonDealerDSMName1;
		public String name;
		public String contactNumber;
		public String waNumber;
		public String salutation;
		public String vehicleType;
		public String vehicleSubCategory;
		public String parentDealNumber;
		public String registrationNumberFormat;
		public String vehicleRegistrationNumber;
		public Decimal nocRefrenceNumber;
		public Boolean incomesourceAvailable;
		public Decimal declearedIncome;
		public Decimal requiredLoanAmount;
		public Boolean doYouHaveABankAccount;
		public Boolean doYouHaveABankAccountWithIIB;
		public Boolean wouldYouLiketoOpenBankAccountWithIIB;
         
	}
    public class Document {
		public String Applicanttype;
		public String imageName;
		public String documentSide;
		public String documentType;
		public String base64EncodedImage;
	}
*/
     
}