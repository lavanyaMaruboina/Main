/*------------------------------------------------------------
Author:        Rohan Saxena
Company:       Salesforce
Description:   This class is Request Wrapper Class of IBM Reverse Vehicle Valuation API
Test Class:    
History
Date            Author              Comments
-------------------------------------------------------------
07-12-2022      Rohan Saxena         Created
------------------------------------------------------------*/
public with sharing class IND_D2CVehicleValuationRequst extends ParentAPIRequest{
    public final String leadNumber { get; set; }
    public final String beContactNumber { get; set; }
    public final String beSFDCId { get; set; }
    public final String beName { get; set; }
    public final String beId { get; set; }
    public final String beBranchCode { get; set; }
    public final String valuationPrice { get; set; }
    public final String gridValue { get; set; }
    public final String sellingPrice { get; set; }
    public final String insuranceType { get; set; }
    public final String insuranceExpiringWithin60Days { get; set; }
    public final String numberOfOwnerships { get; set; }
    public final String checkOEMDealer { get; set; }
    public String originalRCCopy { get; set; }
    public String insurancePolicyDocument { get; set; }
    public final String motorInsurancePolicyName { get; set; }
    public final String vehicleCategoryCode { get; set; }
    public final String leadSourcedBy { get; set; }
    public final String motorInsuranceAmount { get; set; }
    public final String funded { get; set; }
    public final String nonFunded { get; set; }
    public final String fundedPremium { get; set; }
    public final String IDV { get; set; }
    public final String manufacturerYear { get; set; }
    public final String manufacturerMonth { get; set; }
    public final String valuer { get; set; }
    public final String valuerCategory { get; set; }
    public final String eligibleAmount { get; set; }

    public IND_D2CVehicleValuationRequst(String loanId) {

        //get Vehicle_Detail__c
        List<Vehicle_Detail__c> vehDetailList = new List<Vehicle_Detail__c>([Select Id, Executive_name__c, Executive_Contact_Number__c,Ins_Expiry_date__c, Ben_Code__c,Dealer_Sub_dealer_name__c,Product__c, Loan_Application__c, Variant_Code__c, 
        Selling_Price__c, Manufacturer_Year_Month__c,Vehicle_Registration_number__c,Lien_in_favor_of__c,Insurance_type__c, Variant__c, Insurance_expiring_within_60_days__c, Valuer__c, Eligible_Loan_Amount__c,
        Insurance_declared_value__c, Purpose_of_purchase__c, Number_of_ownerships__c, OEM_Dealer__c, Vehicle_registered_in_the_name_of__c,Vehicle_Category__c,Valuation_price__c, Grid_value__c,
        Loan_Application__r.Agent_BL_code__c, Loan_Application__r.mapped_BE__c,Loan_Application__r.Vehicle_Sub_Category__c, Loan_Application__r.Lead_number__c, Loan_Application__r.OEM_Dealer_Checkbox__c, Insurer_name__c, Base_Prices__c, Valuer_category__c
        From Vehicle_Detail__c Where Loan_Application__c =:loanId ]);

        List<InsuranceDetails__c> insurDetailObj =  [SELECT id, Name, Amount__c, Funded_Non_funded__c, Funded_Premium__c, Insurance_Plan__c
                                                    FROM InsuranceDetails__c
                                                    WHERE Loan_Application__c =: loanId
                                                    WITH SECURITY_ENFORCED
                                                    ];

        List<Applicant__c> app = [Select Id, applicant_number__c FROM Applicant__c WHERE Opportunity__c =: loanId];
        List<Documents__c> docObject = [SELECT Document_Type__c, Name from Documents__c where Opportunity_Relation__c =: loanId and (Name='Vehicle RC Copy' or Name='Vehicle Insurance Policy')];
        if(vehDetailList != null && !vehDetailList.isEmpty()){
            this.leadNumber =vehDetailList[0].Loan_Application__r.Lead_number__c+'_'+app[0].applicant_number__c;
            this.beContactNumber =vehDetailList[0].Executive_Contact_Number__c;
            this.beSFDCId =String.isNotBlank(vehDetailList[0].Loan_Application__r.mapped_BE__c)?vehDetailList[0].Loan_Application__r.mapped_BE__c:'';
            this.beName =vehDetailList[0].Executive_name__c;
            this.beId =String.isNotBlank(vehDetailList[0].Loan_Application__r.mapped_BE__c)?vehDetailList[0].Loan_Application__r.mapped_BE__c:'';
            this.beBranchCode =vehDetailList[0].Loan_Application__r.Agent_BL_code__c;
            this.valuationPrice =vehDetailList[0].Valuation_price__c!=null?String.valueOf(Integer.valueOf(vehDetailList[0].Valuation_price__c)):'0';
            this.gridValue =String.valueOf(Integer.valueOf(vehDetailList[0].Grid_value__c));
            this.sellingPrice =String.valueOf(Integer.valueOf(vehDetailList[0].Selling_Price__c));
            this.insuranceType =String.isNotBlank(vehDetailList[0].Insurance_type__c)?vehDetailList[0].Insurance_type__c:'';
            this.insuranceExpiringWithin60Days =vehDetailList[0].Insurance_expiring_within_60_days__c?'Y':'N';
            this.numberOfOwnerships =vehDetailList[0].Number_of_ownerships__c;
            this.checkOEMDealer =vehDetailList[0].Loan_Application__r.OEM_Dealer_Checkbox__c?'Y':'N';
            
            this.vehicleCategoryCode =String.isNotBlank(vehDetailList[0].Loan_Application__r.Vehicle_Sub_Category__c)?vehDetailList[0].Loan_Application__r.Vehicle_Sub_Category__c:'';
            this.leadSourcedBy ='D2C';
            if(!docObject.isEmpty()){
                for(Documents__c doc:docObject){
                    if(doc.Document_Type__c=='Vehicle Insurance Policy'){
                        this.insurancePolicyDocument = 'Y';
                    } else if(doc.Document_Type__c=='Vehicle RC Copy'){
                        this.originalRCCopy = 'Y';
                    }
                }
            }
            this.originalRCCopy = String.isNotBlank(this.originalRCCopy)?this.originalRCCopy:'N';
            this.insurancePolicyDocument =String.isNotBlank(this.insurancePolicyDocument)?this.insurancePolicyDocument:'N';

            if(insurDetailObj != null && !insurDetailObj.isEmpty()){
                this.motorInsuranceAmount =insurDetailObj[0].Amount__c!=null?String.valueOf(Integer.valueOf(insurDetailObj[0].Amount__c)):'0';
                this.funded = insurDetailObj[0].Funded_Non_funded__c == 'Funded'?'Y':'N';
                this.motorInsurancePolicyName = String.isNotBlank(insurDetailObj[0].Insurance_Plan__c)?insurDetailObj[0].Insurance_Plan__c:'';
                this.nonFunded = insurDetailObj[0].Funded_Non_funded__c != 'Funded'?'Y':'N';
                if(insurDetailObj[0].Funded_Non_funded__c == 'Funded'){
                    this.fundedPremium = insurDetailObj[0].Amount__c!=null?String.valueOf(Integer.valueOf(insurDetailObj[0].Amount__c)):'0';
                }else{
                    this.fundedPremium='0';
                }
                
            }else{
                this.motorInsuranceAmount ='0';
                this.funded ='N';
                this.motorInsurancePolicyName = '';
                this.nonFunded ='N';
                this.fundedPremium='0';
            }
            
            this.IDV =String.valueOf(Integer.valueOf(vehDetailList[0].Insurance_declared_value__c));
            this.manufacturerYear =vehDetailList[0].Manufacturer_Year_Month__c.split('-')[0];
            this.manufacturerMonth =vehDetailList[0].Manufacturer_Year_Month__c.split('-')[1];
            this.valuer =String.isNotBlank(vehDetailList[0].Valuer__c)?vehDetailList[0].Valuer__c:'';
            this.valuerCategory =String.isNotBlank(vehDetailList[0].Valuer_category__c)?vehDetailList[0].Valuer_category__c:'';
            this.eligibleAmount =String.isNotBlank(String.valueOf(Integer.valueOf(vehDetailList[0].Eligible_Loan_Amount__c)))?String.valueOf(Integer.valueOf(vehDetailList[0].Eligible_Loan_Amount__c)):'0';
        }
        

    }
    public override Map<String, String> getHttpRequestHeaders() {
        //Map to store HTTP request header data
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        Map<String, String> requestHeaderMap = new Map<String, String>();
        requestHeaderMap.put(IntegrationConstants.CONTENT_TYPE , IntegrationConstants.CONTENT_TYPE_JSON);
        requestHeaderMap.put('X-IBM-Client-Id', System.Label.IBMClientId);
        requestHeaderMap.put('X-IBM-Client-Secret', System.Label.IBMClientSecret);
        requestHeaderMap.put('Origin', URL.getSalesforceBaseUrl().toExternalForm());
        requestHeaderMap.put('UUID', guid);
        return requestHeaderMap;
    }
}