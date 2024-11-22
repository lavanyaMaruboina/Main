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
public class IND_OfferEngineRequestDSA extends ParentAPIRequest {
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

    public IND_OfferEngineRequestDSA(RequestWrapper requestWrapper) {
        this.Lead_Id = requestWrapper.leadId == null ? '' : requestWrapper.leadId + '_' + requestWrapper.borrowerApplicantNumber;
        this.Maker_Id = IntegrationUtilities.getMakerId();
        this.Product = 'PV';
        this.VehicleType = 'U';
        this.OfferScreenType = 'Initial Offer';
        this.OwnHouseFlag = 'N';
        if(requestWrapper.Channel == 'IndusMobile' || requestWrapper.Channel == 'Aggregator'){
            this.Product = requestWrapper.product == 'Passenger Vehicles'?'PV' : requestWrapper.product == 'Two Wheeler'?'TW' :'' ;   
            this.VehicleType = requestWrapper.vehicleType == 'New'?'N' : requestWrapper.vehicleType == 'Used' ?'U' : requestWrapper.vehicleType == 'Refinance' ?'R' : '';
            
        }
        System.debug('@@@offer screen type' +  this.OfferScreenType);
        if(requestWrapper.Channel == 'IndusMobile' || requestWrapper.Channel == 'Aggregator') {
            this.OfferScreenType = 'Final Offer';
            System.debug('@@@ inside offer screen type' +  this.OfferScreenType);
            this.OwnHouseFlag = '';
        }
        System.debug('@@@offer screen type after' +  this.OfferScreenType);
        this.CallType = 'OFFER';
        this.Channel = String.isBlank(requestWrapper.Channel) ? 'DSA' : requestWrapper.Channel;
        this.ApplicantType = 'Borrower';
        this.OfferRunCount = '0';
        

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
        }
        this.DealerCategory = requestWrapper.DealerCategory;//'others';
        this.Funded_Insurance = '';
        this.Manufacture_Code = String.isNotBlank(requestWrapper.Manufacture_Code) ? requestWrapper.Manufacture_Code : '';
        this.RequiredLoanAmountFinalOffer = '';
        this.RequiredTenureFinalOffer = '';
        this.RequiredLoanAmountFromSlider = '';
        this.RequiredTenureFromSlider = '';
        this.IncomePerMonth = requestWrapper.income;
        this.Existing_EMI = requestWrapper.emi;
        this.ORPQuotationPrice = requestWrapper.ORPQuotationPrice;
        this.AbbFlag = 'N';
        this.AbbValue = '';
        
        this.Finance_Amount = '';
        this.DisplayCrmIrr = '';
        this.DisplayLoanAmount = '';
        this.DisplayTenure = '';
        this.DisplayImputedIrr = '';
        this.NetIrr = '';
        this.NetPayIns = '';
        this.NetPayOuts = '';
    }
    public override Map<String, String> getHttpRequestHeaders() {
        //Map to store HTTP request header data
        Map<String, String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }
}