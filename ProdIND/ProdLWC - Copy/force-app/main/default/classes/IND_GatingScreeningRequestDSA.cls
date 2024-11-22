public with sharing class IND_GatingScreeningRequestDSA extends ParentAPIRequest {
    //request paramaters for gating screening-check eligibility request
    public final String Noof_Coborrowers { get; set; }
    public final String Vehicle_Type { get; set; }
    public final String Maker_Id { get; set; }
    public final String Loan_Amount { get; set; }
    public Borrower Borrower;
    public CoBorrower CoBorrower;
    //Added by Rohan for new DSA API 
    public final String Channel { get; set; }

    public class Borrower {
        public final String Lead_Id { get; set; }
        public final String Date_of_Birth { get; set; }
        public final String Customer_PAN { get; set; }
        public final String Customer_CIN { get; set; }
        public final String Income { get; set; }
    }

    public class CoBorrower {
        public final String Lead_Id { get; set; }
        public final String Date_of_Birth { get; set; }
        public final String Customer_PAN { get; set; }
        public final String Customer_CIN { get; set; }
        public final String Income { get; set; }
    }

    public IND_GatingScreeningRequestDSA(RequestWrapper requestWrapper) {
        if (requestWrapper != null) {
            this.Noof_Coborrowers = requestWrapper.noOfCoborrowers == null ? '' : requestWrapper.noOfCoborrowers;
            this.Maker_Id = IntegrationUtilities.getMakerId();
            this.Loan_Amount = requestWrapper.loanAmount == null ? '' : requestWrapper.loanAmount;
            this.Vehicle_Type = requestWrapper.vehicleType == null ? '' : requestWrapper.vehicleType;
            //added by Rohan for new DSA API
            this.Channel = 'DSA';

            this.borrower = new Borrower();
            if (requestWrapper.dOB != null) {
                Datetime dOB = requestWrapper.dOB;
                borrower.Date_of_Birth = dOB.format('yyyy-MM-dd');
            } else {
                borrower.Date_of_Birth = '';
            }
            borrower.Income = requestWrapper.income == null ? '0' : requestWrapper.income;
            borrower.Lead_Id = requestWrapper.leadId == null ? '' : requestWrapper.leadId + '_' + requestWrapper.borrowerApplicantNumber;
            system.debug('requestWrapper.borrowerForm60Present' + requestWrapper.borrowerForm60Present);
            borrower.Customer_PAN = requestWrapper.borrowerForm60Present == 'true' ? null : requestWrapper.panNumber;
            borrower.Customer_CIN = requestWrapper.cinNo == null ? '' : requestWrapper.cinNo;

            if (requestWrapper.noOfActiveCoborrowers != null && (Integer.valueOf(requestWrapper.noOfActiveCoborrowers) > 0)) {
                this.coBorrower = new CoBorrower();
                system.debug('requestWrapper::' + JSON.serialize(requestWrapper));
                if (requestWrapper.coBorrowerDob != null) {
                    Datetime dOB = requestWrapper.coBorrowerDob;
                    coBorrower.Date_of_Birth = dOB.format('yyyy-MM-dd');
                } else {
                    coBorrower.Date_of_Birth = '';
                }
                coBorrower.Lead_Id = requestWrapper.leadId == null ? '' : requestWrapper.leadId + '_' + requestWrapper.coBorrowerApplicantNumber;
                coBorrower.Customer_PAN = requestWrapper.coBorrowerForm60Present == 'true' ? null : requestWrapper.coBorrowerPanNumber;
                coBorrower.Customer_CIN = requestWrapper.coBorrowerCinNo == null ? '' : requestWrapper.coBorrowerCinNo;
                coBorrower.Income = requestWrapper.coBorrowerIncome == null ? '' : requestWrapper.coBorrowerIncome;
            }
        }
        validate(System.Label.IblBre);
    }

    public override Map<String, String> getHttpRequestHeaders() {
        //Map to store HTTP request header data
        Map<String, String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }

    public override boolean validate(String serviceName) {
        if (String.isBlank(this.Noof_Coborrowers)) {
            throw new IND_Exception(System.Label.NoofCoborrowers);
        }
        if (String.isBlank(this.Maker_Id)) {
            throw new IND_Exception(System.Label.MakerId);
        }
        if (String.isBlank(this.Vehicle_Type)) {
            throw new IND_Exception(System.Label.VehicleType);
        }
        if (String.isBlank(this.borrower.Lead_Id)) {
            throw new IND_Exception(System.Label.LeadId);
        }
        if (String.isBlank(this.borrower.Date_of_Birth)) {
            throw new IND_Exception(System.Label.DateOfBirth);
        }

        if (String.isBlank(this.borrower.Income)) {
            throw new IND_Exception(System.Label.Incomemessage);
        }

        if (this.coBorrower != null) {
            if (String.isBlank(this.coBorrower.Lead_Id)) {
                throw new IND_Exception(System.Label.LeadId);
            }
            if (String.isBlank(this.coBorrower.Date_of_Birth)) {
                throw new IND_Exception(System.Label.DateOfBirth);
            }
        }
        return true;
    }
}