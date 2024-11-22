/*------------------------------------------------------------
Author: Neeraj Mehethrajkar
Company: Salesforce
Description: This class is wrapper class for the PaymentRequestAPI Request. SFTRAC-241
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
28-11-2023    Neeraj Mehethrajkar   Created
------------------------------------------------------------*/
public class IND_PaymentRequestApiRequest extends ParentAPIRequest {
    public IND_PaymentRequestApiRequest(String loanId, String dealId) {
        List<Opportunity> loanApplication = [SELECT Id,Customer_Type__c,Number_of_Products__c FROM Opportunity WHERE Id =:loanId LIMIT 1];
        List<Vehicle_Detail__c> deal = [SELECT Id, Deal_Number__r.Deal_Number__c, Vehicle_Delivered__c, Vehicle_Registration_number__c, Manufacturer_Year_Month__c, Make_Code__c, Product__c, Variant_Code__c, KMS_Run__c, createdDate, Serial_number__c,(Select Id,HMR__c From RelatedAsset_Verifications__r),(Select Id,Installment_Frequency__c From Final_Terms__r) FROM Vehicle_Detail__c WHERE Deal_Number__c =:dealId LIMIT 1];

        List<LoanDisbursementDetails__c> loandisbursementList = [SELECT Id, Vehicle_Delivered__c,Registration_Number__c FROM LoanDisbursementDetails__c WHERE Deal_Number__c =:dealId LIMIT 1];

        List<Case> caseRec = [SELECT Id FROM Case WHERE Loan_Application__c =: loanId AND Applicant__r.Applicant_Type__c = 'Borrower' AND RecordType.Name = 'FI' AND Type = 'Current Residence FI'];
        List<Field_Investigation__c> fiRecord = [SELECT Id, Relationship__c, Area__c, Pin_Code__c, Land_Irrigation_source__c, Type_of_Crop__c, Yield_Per_Acre_monthly__c, IS_CUSTOMER_HAVING_IMPLEMENT__c, Agri_Commercial__c, Since_how_long_in_Agri_commercial__c, Sub_Scheme_Type__c, Scheme_Type__c, 
        (SELECT Id, Survey_No__c, Land_holding_In_acres__c, Ownership_Type__c, Land_holder_Name__c, Type__c, Approximate_value_of_Agri_Land__c FROM Loan_Holding_Details__r), 
        (SELECT Id, Name, Crop_Type__c, Net_Income__c, Crop_Master__r.Yield_Quintal_Per_Acre__c, Crop_Master__r.Market_Price_Rs_Per_Quintal__c, Land_Survey_No__c,Crop_Master__r.Name  FROM Crop_Details__r), (SELECT Id, Loan_Free__c FROM Existing_Tractor_Loan_Informations__r) FROM Field_Investigation__c WHERE Case__c =: caseRec[0].Id AND RecordType.Name = 'Residence' ];
        List<Documents__c> docList =  [SELECT  Taluka__c, Village__c, KYC_Pin_Code__c  FROM Documents__c WHERE (Permanent_Residential_Address_Proof__c = true OR Current_Residential_Address_Proof__c = true OR Proof_of_Address_POA__c = true) AND Applicant__r.Applicant_Type__c = 'Borrower' ];
        List<Invoice_Details__c> invoice = [SELECT Id, Invoice_Number__c, Invoice_Date__c FROM Invoice_Details__c WHERE loan_application__c =: loanId and Deal_Number__c =: dealId];
        List<Applicant__c> guarantor = [SELECT Id  FROM Applicant__c WHERE Opportunity__c =: loanId AND Applicant_Type__c = 'Gaurantor'];
        List<Applicant__c> borrower = [SELECT Id, PACS_Member__c, PACS_Name__c, (SELECT Id, Saral_date__c, Tax_Return_Filed__c FROM Income_Details__r)  FROM Applicant__c WHERE Opportunity__c =: loanId AND Applicant_Type__c = 'Borrower'];
        List<product2> product = [SELECT Manufacturer_code__c FROM Product2 WHERE Make_Code__c = :deal[0].Make_Code__c];
        List<String> survey_no_List = new List<String>();
        Integer area = 0 ;
        for (Land_Holding_Detail__c landHolding : fiRecord[0].Loan_Holding_Details__r) {
            survey_no_List.add(landHolding.Survey_No__c);
            area += Integer.valueOf(landHolding.Land_holding_In_acres__c);
        }
        Integer yesCount = 0;
        for (Existing_Tractor_Loan_Information__c existing : fiRecord[0].Existing_Tractor_Loan_Informations__r) {
            if (existing.Loan_Free__c == 'Yes') {
                yesCount++;
            }
        }
        this.PaymentRequest = new PaymentRequest();
        this.PaymentRequest.Deal_No = deal[0].Deal_Number__r.Deal_Number__c;
        this.PaymentRequest.Delivered_Flag= loandisbursementList.size() > 0 ? loandisbursementList[0].Vehicle_Delivered__c == 'Yes' ? 'Y' : 'N' : '';
        this.PaymentRequest.Registration_No= loandisbursementList.size() > 0 ? loandisbursementList[0].Registration_Number__c : '';
        this.PaymentRequest.Implements_Category = fiRecord.size() > 0 && fiRecord[0].IS_CUSTOMER_HAVING_IMPLEMENT__c != null && fiRecord[0].IS_CUSTOMER_HAVING_IMPLEMENT__c != 'No' ? 'Y' : 'N';
        if(deal[0].RelatedAsset_Verifications__r.size() > 0 && deal[0].RelatedAsset_Verifications__r[0].HMR__c != null){
            this.PaymentRequest.Hour_Meter_Reading= String.valueof(deal[0].RelatedAsset_Verifications__r[0].HMR__c) ;
        }else{
            this.PaymentRequest.Hour_Meter_Reading= '';
        }
        this.PaymentRequest.Invoice_No= invoice.size() > 0 && invoice[0].Invoice_Number__c != null ? invoice[0].Invoice_Number__c : '';
        this.PaymentRequest.Invoice_date= invoice.size() > 0 && invoice[0].Invoice_Date__c != null ? String.valueOf(invoice[0].Invoice_Date__c) : '';
        this.PaymentRequest.Customer_Category= fiRecord[0].Scheme_Type__c == null ? '' : fiRecord[0].Scheme_Type__c;
        this.PaymentRequest.Agri_Type = fiRecord[0].Agri_Commercial__c == null ? '' : fiRecord[0].Agri_Commercial__c;
        this.PaymentRequest.Years_In_Agri = fiRecord[0].Since_how_long_in_Agri_commercial__c == null ? '' : fiRecord[0].Since_how_long_in_Agri_commercial__c;
        this.PaymentRequest.Own_Tractor = fiRecord.size() > 0 ? String.valueOf(fiRecord[0].Existing_Tractor_Loan_Informations__r.size()) : '0';
        this.PaymentRequest.Free_Tractor_Nos= String.valueOf(yesCount);
        this.PaymentRequest.Loan_Tractor_Nos= loanApplication.size() > 0 && loanApplication[0].Number_of_Products__c == null ? '0' : String.valueOf(loanApplication[0].Number_of_Products__c);
        if(loanApplication.size() > 0 && loanApplication[0].Customer_Type__c == 'Non-Individual'){
            this.PaymentRequest.Tax_Return_Filed = borrower.size()>0 &&  borrower[0].Income_Details__r.size()>0 && borrower[0].Income_Details__r[0].Tax_Return_Filed__c != null ? borrower[0].Income_Details__r[0].Tax_Return_Filed__c : ''; 
            this.PaymentRequest.Saral_date = borrower.size()>0 && borrower[0].Income_Details__r.size()> 0 && String.valueOf(borrower[0].Income_Details__r[0].Saral_date__c) != null ? String.valueOf(borrower[0].Income_Details__r[0].Saral_date__c) : '';
            this.PaymentRequest.PACS_Member = borrower.size()>0 && borrower[0].PACS_Member__c != null ?  'Y' : 'N';
            this.PaymentRequest.PACS_Name = borrower.size()>0 && borrower[0].PACS_Name__c != null? borrower[0].PACS_Name__c : '';
        }else{
            this.PaymentRequest.Tax_Return_Filed = '';
            this.PaymentRequest.Saral_date = '';
            this.PaymentRequest.PACS_Member = '';
            this.PaymentRequest.PACS_Name = '';
        }
        this.PaymentRequest.Maker_Date= String.valueOf(deal[0].createdDate);
        this.PaymentRequest.Registration_No_Trolley = '';

        this.PaymentRequestDetails = new List<PaymentRequestDetails>();
        Map<String, List<Crop_Detail__c>> landToCropMap = new Map<String, List<Crop_Detail__c>>();
        for (Crop_Detail__c crop : fiRecord[0].Crop_Details__r) {
            if (!landToCropMap.containsKey(crop.Land_Survey_No__c)) {
                landToCropMap.put(crop.Land_Survey_No__c, new List<Crop_Detail__c>());
            }
            landToCropMap.get(crop.Land_Survey_No__c).add(crop);
        }
        for (Land_Holding_Detail__c landHolding : fiRecord[0].Loan_Holding_Details__r) {
            PaymentRequestDetails prdObj = new PaymentRequestDetails();
            prdObj.Deal_No = deal[0].Deal_Number__r.Deal_Number__c;
            prdObj.Property_Id = landHolding.Survey_No__c == null ? '' : landHolding.Survey_No__c;
            prdObj.Land_Ownership = landHolding.Ownership_Type__c == null ? '' : landHolding.Ownership_Type__c;
            prdObj.Land_Owner_Name = landHolding.Land_holder_Name__c == null ? '' : landHolding.Land_holder_Name__c;
            prdObj.Relationship = landHolding.Type__c == null ? '' : landHolding.Type__c;
            prdObj.Guarantor_Flag = guarantor.isEmpty() ? 'N' : 'Y';
            prdObj.Area_Acres = landHolding.Land_holding_In_acres__c == null ? '' : String.valueOf(landHolding.Land_holding_In_acres__c);
            
            for (Documents__c document : docList) {
                if(String.isBlank(prdObj.Taluk)){
                    prdObj.Taluk = document.Taluka__c == null ? '' : document.Taluka__c;
                }
                if(String.isBlank(prdObj.Village)){
                    prdObj.Village = document.Village__c == null ? '' : document.Village__c;
                }
                if(String.isBlank(prdObj.PinCode)){
                    prdObj.PinCode = document.KYC_Pin_Code__c == null ? '' : document.KYC_Pin_Code__c;
                }
            }
            prdObj.Survey_Patta_No = landHolding.Survey_No__c == null ? '' : landHolding.Survey_No__c;
            prdObj.Free_Encumbered = '';
            prdObj.Market_Value = landHolding.Approximate_value_of_Agri_Land__c == null ? '' : String.valueOf(landHolding.Approximate_value_of_Agri_Land__c);
            prdObj.Land_Tax_PA = '';
            prdObj.Irrigation_Source = fiRecord[0].Land_Irrigation_source__c;
            prdObj.Soil_Type = '';
            prdObj.Crop_Type = fiRecord[0].Type_of_Crop__c == null ? '' : fiRecord[0].Type_of_Crop__c;

            Crop_Detail__c crop = landToCropMap.containsKey(landHolding.Survey_No__c) ? landToCropMap.get(landHolding.Survey_No__c)[0] : null ;
            if (crop != null) {
                prdObj.Crop_Name = crop.Crop_Master__r.Name == null ? '' : crop.Crop_Master__r.Name;
                prdObj.Harvest_Cycle_PA = ''; //Hardcoded
                prdObj.Acre_Yield_Quintal = crop.Crop_Master__r.Yield_Quintal_Per_Acre__c == null ? '' : String.valueOf(crop.Crop_Master__r.Yield_Quintal_Per_Acre__c); 
                prdObj.Market_Price_Quintal = crop.Crop_Master__r.Market_Price_Rs_Per_Quintal__c == null ? '' : String.valueOf(crop.Crop_Master__r.Market_Price_Rs_Per_Quintal__c);
                prdObj.Cycle_Cost_Acre = crop.Net_Income__c == null ? '' : String.valueOf(crop.Net_Income__c);
                prdObj.Rental_Cycle  = ''; //Hardcoded
            }else{
                prdObj.Crop_Name = '';
                prdObj.Harvest_Cycle_PA = '';
                prdObj.Acre_Yield_Quintal = ''; 
                prdObj.Market_Price_Quintal = '';
                prdObj.Cycle_Cost_Acre = '';
                prdObj.Rental_Cycle  = '';
            }

            if(deal.size() > 0 && deal[0].Final_Terms__r.Size() > 0 && deal[0].Final_Terms__r[0].Installment_Frequency__c != null){
                prdObj.Net_Income_Cycle = deal[0].Final_Terms__r[0].Installment_Frequency__c == 'Monthly' ? '1' : deal[0].Final_Terms__r[0].Installment_Frequency__c == 'bi-monthly' ? '2' : deal[0].Final_Terms__r[0].Installment_Frequency__c == 'Quarterly' ? '3' : deal[0].Final_Terms__r[0].Installment_Frequency__c == 'Half yearly' ? '6' : '';
            }else{
                prdObj.Net_Income_Cycle = '';
            }
            prdObj.Maker_Date = '';
            prdObj.Collateral = '';
            prdObj.Reg_No_Implement = '';
            prdObj.Slno_Implement = deal[0].Serial_number__c == null ? '' : deal[0].Serial_number__c;
            prdObj.Mfg_Month_Implement = deal[0].Manufacturer_Year_Month__c?.split('-')[1] == null ? '' : deal[0].Manufacturer_Year_Month__c?.split('-')[1];
            prdObj.Mfg_Year_Implement = deal[0].Manufacturer_Year_Month__c?.split('-')[0] == null ? '' : deal[0].Manufacturer_Year_Month__c?.split('-')[0];
            prdObj.Tractor_Status_Implement = '';
            prdObj.Manufacturer_Code = product[0].Manufacturer_code__c == null ? '' : product[0].Manufacturer_code__c;
            prdObj.Product_Code = deal[0].Product__c == null ? '' : deal[0].Product__c;
            prdObj.Variant_Code = deal[0].Variant_Code__c == null ? '' : deal[0].Variant_Code__c;
            this.PaymentRequestDetails.add(prdObj);
        } 
        if(fiRecord[0].Loan_Holding_Details__r.size() == 0){
            PaymentRequestDetails prdObj = new PaymentRequestDetails();
            prdObj.Deal_No = deal[0].Deal_Number__r.Deal_Number__c;
            prdObj.Property_Id = '';
            prdObj.Land_Ownership = '';
            prdObj.Land_Owner_Name = '';
            prdObj.Relationship = '';
            prdObj.Guarantor_Flag = guarantor.isEmpty() ? 'N' : 'Y';
            prdObj.Area_Acres = '';
            
            for (Documents__c document : docList) {
                if(String.isBlank(prdObj.Taluk)){
                    prdObj.Taluk = document.Taluka__c == null ? '' : document.Taluka__c;
                }
                if(String.isBlank(prdObj.Village)){
                    prdObj.Village = document.Village__c == null ? '' : document.Village__c;
                }
                if(String.isBlank(prdObj.PinCode)){
                    prdObj.PinCode = document.KYC_Pin_Code__c == null ? '' : document.KYC_Pin_Code__c;
                }
            }
            prdObj.Survey_Patta_No = '';
            prdObj.Free_Encumbered = '';
            prdObj.Market_Value = '';
            prdObj.Land_Tax_PA = '';
            prdObj.Irrigation_Source = fiRecord[0].Land_Irrigation_source__c;
            prdObj.Soil_Type = '';
            prdObj.Crop_Type = fiRecord[0].Type_of_Crop__c == null ? '' : fiRecord[0].Type_of_Crop__c;

            prdObj.Crop_Name = '';
            prdObj.Harvest_Cycle_PA = '';
            prdObj.Acre_Yield_Quintal = ''; 
            prdObj.Market_Price_Quintal = '';
            prdObj.Cycle_Cost_Acre = '';
            prdObj.Rental_Cycle  = '';

            if(deal.size() > 0 && deal[0].Final_Terms__r.Size() > 0 && deal[0].Final_Terms__r[0].Installment_Frequency__c != null){
                prdObj.Net_Income_Cycle = deal[0].Final_Terms__r[0].Installment_Frequency__c == 'Monthly' ? '1' : deal[0].Final_Terms__r[0].Installment_Frequency__c == 'bi-monthly' ? '2' : deal[0].Final_Terms__r[0].Installment_Frequency__c == 'Quarterly' ? '3' : deal[0].Final_Terms__r[0].Installment_Frequency__c == 'Half yearly' ? '6' : '';
            }else{
                prdObj.Net_Income_Cycle = '';
            }
            prdObj.Maker_Date = '';
            prdObj.Collateral = '';
            prdObj.Reg_No_Implement = '';
            prdObj.Slno_Implement = deal[0].Serial_number__c == null ? '' : deal[0].Serial_number__c;
            prdObj.Mfg_Month_Implement = deal[0].Manufacturer_Year_Month__c?.split('-')[1] == null ? '' : deal[0].Manufacturer_Year_Month__c?.split('-')[1];
            prdObj.Mfg_Year_Implement = deal[0].Manufacturer_Year_Month__c?.split('-')[0] == null ? '' : deal[0].Manufacturer_Year_Month__c?.split('-')[0];
            prdObj.Tractor_Status_Implement = '';
            prdObj.Manufacturer_Code = product[0].Manufacturer_code__c == null ? '' : product[0].Manufacturer_code__c;
            prdObj.Product_Code = deal[0].Product__c == null ? '' : deal[0].Product__c;
            prdObj.Variant_Code = deal[0].Variant_Code__c == null ? '' : deal[0].Variant_Code__c;
            this.PaymentRequestDetails.add(prdObj);
        }
    }
	public PaymentRequest PaymentRequest{get;set;}
	public List<PaymentRequestDetails> PaymentRequestDetails{get;set;}
    public class PaymentRequestDetails{
        public String Deal_No{get;set;}
        public String Property_Id{get;set;}
        public String Land_Ownership{get;set;}
        public String Land_Owner_Name{get;set;}
        public String Relationship{get;set;}
        public String Guarantor_Flag{get;set;}
        public String Area_Acres{get;set;}
        public String Taluk{get;set;}
        public String Village{get;set;}
        public String PinCode{get;set;}
        public String Survey_Patta_No{get;set;}
        public String Free_Encumbered{get;set;}
        public String Market_Value{get;set;}
        public String Land_Tax_PA{get;set;}
        public String Irrigation_Source{get;set;}
        public String Soil_Type{get;set;}
        public String Crop_Type{get;set;}
        public String Crop_Name{get;set;}
        public String Harvest_Cycle_PA{get;set;}
        public String Acre_Yield_Quintal{get;set;}
        public String Market_Price_Quintal{get;set;}
        public String Cycle_Cost_Acre{get;set;}
        public String Rental_Cycle{get;set;}
        public String Net_Income_Cycle{get;set;}
        public String Maker_Date{get;set;}
        public String Collateral{get;set;}
        public String Reg_No_Implement{get;set;}
        public String Slno_Implement{get;set;}
        public String Mfg_Month_Implement{get;set;}
        public String Mfg_Year_Implement{get;set;}
        public String Tractor_Status_Implement{get;set;}
        public String Manufacturer_Code{get;set;}
        public String Product_Code{get;set;}
        public String Variant_Code{get;set;}
    }
     public class PaymentRequest{
        public String Deal_No{get;set;}
        public String Delivered_Flag{get;set;}
        public String Registration_No{get;set;}
        public String Implements_Category{get;set;}
        public String Hour_Meter_Reading{get;set;}
        public String Invoice_No{get;set;}
        public String Invoice_date{get;set;}
        public String Customer_Category{get;set;}
        public String Agri_Type{get;set;}
        public String Years_In_Agri{get;set;}
        public String Own_Tractor{get;set;}
        public String Free_Tractor_Nos{get;set;}
        public String Loan_Tractor_Nos{get;set;}
        public String Tax_Return_Filed{get;set;}
        public String Saral_date{get;set;}
        public String PACS_Member{get;set;}
        public String PACS_Name{get;set;}
        public String Maker_Date{get;set;}
        public String Registration_No_Trolley{get;set;} 
    }
}