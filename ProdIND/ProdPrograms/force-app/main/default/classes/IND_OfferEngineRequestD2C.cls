/*------------------------------------------------------------
Author: Rohan Saxena
Company: Salesforce
Description: This class is wrapper class for the DSA Offer Engine request 
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
06-09-2022    Rohan Saxena           Created
------------------------------------------------------------*/
public class IND_OfferEngineRequestD2C extends ParentAPIRequest {
    public String Lead_Id { get; set; }
    public String Maker_Id { get; set; }
    public String Product { get; set; }
    public String VehicleType { get; set; }
    public String CallType { get; set; }
    public String Channel { get; set; }
    public String ApplicantType { get; set; }
    public String OfferRunCount { get; set; }
    public String OfferScreenType { get; set; }
    public String EngineBankIrr { get; set; }
    public String EngineLTV { get; set; }
    public String EngineRiskBand { get; set; }
    public String DealerCategory { get; set; }
    public String Funded_Insurance { get; set; }
    public String Manufacture_Code { get; set; }
    public String RequiredLoanAmountFinalOffer { get; set; }
    public String RequiredTenureFinalOffer { get; set; }
    public String RequiredLoanAmountFromSlider { get; set; }
    public String RequiredTenureFromSlider { get; set; }
    public String IncomePerMonth { get; set; }
    public String Existing_EMI { get; set; }
    public String ORPQuotationPrice { get; set; }
    public String AbbFlag { get; set; }
    public String AbbValue { get; set; }
    public String OwnHouseFlag { get; set; }
    public String Finance_Amount { get; set; }
    public String DisplayCrmIrr { get; set; }
    public String DisplayLoanAmount { get; set; }
    public String DisplayTenure { get; set; }
    public String DisplayImputedIrr { get; set; }
    public String NetIrr { get; set; }
    public String NetPayIns { get; set; }
    public String NetPayOuts { get; set; }
    public Boolean isPACustomer {get; set; }
    public String loanDealDate {get;set;}
    public String installmentPattern {get;set;}
    public String firstEMIdate {get;set;}
    public String secondEMIdate {get;set;}
    public List<AmortizationSchedule> amortizationSchedule {get;set;}

    public class AmortizationSchedule {
        public String emiDueDate{get;set;}
        public String installmentNumber{get;set;}
        public String installmentAmount{get;set;}
        public String openingPrincipal{get;set;}
        public String pricipalComponent{get;set;}
        public String interestComponent{get;set;}
        public String closingPrincipal{get;set;}
    }
    
    public IND_OfferEngineRequestD2C(RequestWrapper requestWrapper, String fromScreen) {
        this(requestWrapper,fromScreen,'');
    } //CISP-21080

    public IND_OfferEngineRequestD2C(RequestWrapper requestWrapper, String fromScreen, String minCRM) {
        this.Lead_Id = requestWrapper.leadId == null ? '' : requestWrapper.leadId + '_' + requestWrapper.borrowerApplicantNumber;
        this.Maker_Id = IntegrationUtilities.getMakerId();
        this.Product = requestWrapper.product == 'Passenger Vehicles'?'PV' : requestWrapper.product == 'Two Wheeler'?'TW' :'' ;   
        this.VehicleType = requestWrapper.vehicleType == 'New'?'N' : requestWrapper.vehicleType == 'Used' ?'U' : requestWrapper.vehicleType == 'Refinance' ?'R' : '';
        this.OfferScreenType = 'Final Offer';
        this.OwnHouseFlag = String.isNotBlank(requestWrapper.OwnHouseFlag)?requestWrapper.OwnHouseFlag:'';
        this.CallType = fromScreen == 'insurance'?'INSURANCE': fromScreen == 'payin_payout'?'PayIn_PayOut' : fromScreen=='cam'?'CAM':'OFFER'; // Added PayIn_PayOut calltype for CISP-12521
        this.Channel = requestWrapper.Channel;
        this.ApplicantType = 'Borrower';
        this.OfferRunCount = (fromScreen == 'sliderScreen' || fromScreen == 'finalTerms')?'1':'0';
        this.EngineBankIrr = requestWrapper.EngineBankIrr;
        this.EngineLTV = requestWrapper.EngineLTV;
        if ((!String.IsBlank(requestWrapper.scoreCardDecision)) && requestWrapper.scoreCardDecision != null && requestWrapper.scoreCardDecision.equalsIgnoreCase('Dark Green')) {
            this.EngineRiskBand = '01';
        } else if ((!String.IsBlank(requestWrapper.scoreCardDecision)) && requestWrapper.scoreCardDecision != null && requestWrapper.scoreCardDecision.equalsIgnoreCase('Light Green')) {
            this.EngineRiskBand = '02';
        } else if ((!String.IsBlank(requestWrapper.scoreCardDecision)) && requestWrapper.scoreCardDecision != null && requestWrapper.scoreCardDecision.equalsIgnoreCase('Yellow')) {
            this.EngineRiskBand = '03';
        } else if ((!String.IsBlank(requestWrapper.scoreCardDecision)) && requestWrapper.scoreCardDecision != null && requestWrapper.scoreCardDecision.equalsIgnoreCase('Orange')) {
            this.EngineRiskBand = '04';
        } else if ((!String.IsBlank(requestWrapper.scoreCardDecision)) && requestWrapper.scoreCardDecision != null && requestWrapper.scoreCardDecision.equalsIgnoreCase('Red')) {
            this.EngineRiskBand = '05';
        } else {
            this.EngineRiskBand = '';
        }
        if(requestWrapper.isPACustomer == true){
            this.isPACustomer = requestWrapper.isPACustomer;
        }else{
            this.isPACustomer = false;
        }
        this.DealerCategory = requestWrapper.DealerCategory;//'others';
        this.Funded_Insurance = (fromScreen == 'insurance' || fromScreen == 'cam')?requestWrapper.Funded_Insurance:'';
        this.Manufacture_Code = String.isNotBlank(requestWrapper.Manufacture_Code) ? requestWrapper.Manufacture_Code : '';
        this.RequiredLoanAmountFinalOffer = this.callType == 'OFFER'?requestWrapper.RequiredLoanAmountFinalOffer:'';
        this.RequiredTenureFinalOffer = this.callType == 'OFFER'?requestWrapper.RequiredTenureFinalOffer:'';
        this.RequiredLoanAmountFromSlider = fromScreen == 'sliderScreen'?requestWrapper.SliderLoanAmount:'';
        this.RequiredTenureFromSlider = fromScreen == 'sliderScreen'?requestWrapper.SliderTenure :'';
        this.IncomePerMonth = requestWrapper.income == null?'':requestWrapper.income;
        this.Existing_EMI = String.isNotBlank(requestWrapper.emi)?requestWrapper.emi:'';
        this.ORPQuotationPrice = requestWrapper.ORPQuotationPrice;
        this.AbbFlag = requestWrapper.AbbFlag != null?requestWrapper.AbbFlag:'N';
        this.AbbValue = requestWrapper.AbbValue != null? requestWrapper.AbbValue:'';
        
        this.Finance_Amount = (fromScreen == 'cam' || fromScreen == 'payin_payout') ? requestWrapper.finAmount:''; // Added PayIn PayOut condition for CISP-12521
        if(String.isNotBlank(minCRM)){ //CISP-20180
            this.DisplayCrmIrr = minCRM;
        }else{
            this.DisplayCrmIrr = fromScreen == 'insurance'?requestWrapper.DisplayCrmIrr:'';
        }
        this.DisplayLoanAmount = fromScreen == 'insurance'?requestWrapper.DisplayLoanAmount:'';
        this.DisplayTenure = (fromScreen == 'insurance' || fromScreen == 'cam')?requestWrapper.DisplayTenure:'';
        this.DisplayImputedIrr = fromScreen == 'cam'?requestWrapper.DisplayImputedIrr:'';
        this.NetIrr = fromScreen == 'cam'?requestWrapper.NetIrr:'';
        this.NetPayIns = fromScreen == 'cam'?requestWrapper.NetPayIns:'';
        this.NetPayOuts = fromScreen == 'cam'?requestWrapper.NetPayOuts:'';
        if(fromScreen == 'finalTerms'){
            this.RequiredLoanAmountFromSlider = requestWrapper.RequiredLoanAmountFinalOffer;
            this.RequiredTenureFromSlider = requestWrapper.RequiredTenureFinalOffer;
        }
        if(this.CallType == 'OFFER' || this.CallType == 'CAM' || this.CallType == 'INSURANCE'){
            this.installmentPattern = requestWrapper.installmentType;
            this.firstEMIdate = requestWrapper.firstEMIDate!=null ? requestWrapper.firstEMIDate : '';
            this.secondEMIdate = requestWrapper.secondEMIDate!=null ? requestWrapper.secondEMIDate : '';
            this.loanDealDate = String.valueOf(Date.Today());
            this.amortizationSchedule = new List<AmortizationSchedule>();
        }
    }
    public override Map<String, String> getHttpRequestHeaders() {
        //Map to store HTTP request header data
        Map<String, String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }
}