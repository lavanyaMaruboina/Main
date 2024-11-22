@isTest
public class IND_InsuranceRecommendationRequestTest {
    
    @isTest
    public static void verifyIND_InsuranceRecommendationRequest(){
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.leadId = 'L0001';
        reqWrapper.applicationNo = 'APP-001';
        reqWrapper.vehicleId = 'DL0001';
        reqWrapper.Borrower_Type ='Borrower';
        reqWrapper.age = '30';
        reqWrapper.gender = 'Male';
        reqWrapper.Vehicle_Category = 'Used';
        reqWrapper.Product = 'Passenger Vehicles';
        reqWrapper.Variant = 'BRAND';
        reqWrapper.Fin_Amount = '100000.0';
        reqWrapper.Balance_Available = '100000.0';
        reqWrapper.Tenure = '5';
        
        reqWrapper.Agreement_Value = '30000';
        reqWrapper.Motor_Expiry_Date = '01-01-2025';
        reqWrapper.Motor_Premium = 'DL0001';
        
        
        IND_InsuranceRecommendationRequest result = new IND_InsuranceRecommendationRequest(reqWrapper);
        IND_InsuranceRecommendationService.getInsuranceRecommendationCallout(reqWrapper);
        Boolean isValid = result.validate(System.Label.Insurance_Recommendation);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty()); 
        String errMsg = '';
        try{
            reqWrapper.applicationNo = null;
            result = new IND_InsuranceRecommendationRequest(reqWrapper);
            result.validate(System.Label.Insurance_Recommendation);
        }catch(Exception pEx){
            errMsg = pEx.getMessage();
            System.assertEquals('Application No is required.',errMsg);
        } 
    } 
    
    @isTest
    public static void verifyIND_InsuranceRecommendationRequest1(){
         Opportunity opcb1 = new Opportunity();
        opcb1.StageName = 'Qualification';
        opcb1.CloseDate = Date.newInstance(2021, 1, 11);
        opcb1.Name = 'testone';
        insert opcb1;
        Vehicle_Detail__c vg3 = new Vehicle_Detail__c();
        vg3.Loan_Application__c = opcb1.Id;
        vg3.Base_Price__c = 100000.00;
        vg3.Ben_Code__c = 'testveh';
        vg3.Valuer_code__c = 'BEN000871';
        vg3.Variant__c  = 'M&M KUV100 NXT K8 DIESEL';
        vg3.Make__c = 'TVS';
        vg3.Model__c = 'MAHINDRA MARAZZO';
        vg3.Engine_number__c  = 'TBH1H79814';
        vg3.Chassis_number__c  = 'MA1ZN2TBKH65317';
        vg3.Vehicle_Registration_number__c  = 'MH14GV9526';
        vg3.Product__c='Two Wheeler';
        insert vg3;
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.Motor_Premium = 'DL0002';
        reqWrapper.leadId = 'L0002';
        reqWrapper.applicationNo = 'APP-002';
        reqWrapper.Borrower_Type ='Borrower';
        reqWrapper.age = '30';
        reqWrapper.gender = 'Male';
        reqWrapper.Vehicle_Category = 'New';
        reqWrapper.Product = 'Tractor';
        reqWrapper.Variant = 'BRAND';
        reqWrapper.Fin_Amount = '100000.0';
        reqWrapper.Balance_Available = '100000.0';
        reqWrapper.Tenure = '5';
        reqWrapper.Agreement_Value = '30000';
        reqWrapper.Motor_Expiry_Date = '01-01-2025';
        reqWrapper.VehicleId=vg3.Id;
        IND_InsuranceRecommendationRequest result = new IND_InsuranceRecommendationRequest(reqWrapper);
        String errMsg = '';
        try{
            result = new IND_InsuranceRecommendationRequest(reqWrapper);
            result.validate(System.Label.Insurance_Recommendation);
        }catch(Exception pEx){
            errMsg = pEx.getMessage();
            System.assertEquals('Please enter Vehicle Id.',errMsg);
        } 
    }
    @isTest
    public static void verifyIND_InsuranceRecommendationRequest2(){
        Opportunity opcb1 = new Opportunity();
        opcb1.StageName = 'Qualification';
        opcb1.CloseDate = Date.newInstance(2021, 1, 11);
        opcb1.Name = 'testone';
        insert opcb1;
        Vehicle_Detail__c vg3 = new Vehicle_Detail__c();
        vg3.Loan_Application__c = opcb1.Id;
        vg3.Base_Price__c = 100000.00;
        vg3.Ben_Code__c = 'testveh';
        vg3.Valuer_code__c = 'BEN000871';
        vg3.Variant__c  = 'M&M KUV100 NXT K8 DIESEL';
        vg3.Make__c = 'TVS';
        vg3.Model__c = 'MAHINDRA MARAZZO';
        vg3.Engine_number__c  = 'TBH1H79814';
        vg3.Chassis_number__c  = 'MA1ZN2TBKH65317';
        vg3.Vehicle_Registration_number__c  = 'MH14GV9526';
        vg3.Product__c='Two Wheeler';
        insert vg3; 
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.Motor_Premium = 'DL0002';
        reqWrapper.leadId = 'L0002';
        reqWrapper.vehicleId = 'DL0002';
        reqWrapper.applicationNo = 'APP-002';
        reqWrapper.Borrower_Type ='Borrower';
        reqWrapper.age = '30';
        reqWrapper.gender = 'Male';
        reqWrapper.Vehicle_Category = 'External Refinance';
        reqWrapper.Variant = 'BRAND';
        reqWrapper.Fin_Amount = '100000.0';
        reqWrapper.Balance_Available = '100000.0';
        reqWrapper.Tenure = '5';
        reqWrapper.Agreement_Value = '30000';
        reqWrapper.Motor_Expiry_Date = '01-01-2025';
        reqWrapper.VehicleId=vg3.Id;
        reqWrapper.Product = 'Passenger Vehicles';
        IND_InsuranceRecommendationRequest result = new IND_InsuranceRecommendationRequest(reqWrapper);
        String errMsg = '';
        try{
            result = new IND_InsuranceRecommendationRequest(reqWrapper);
            result.validate(System.Label.Insurance_Recommendation);
        }catch(Exception pEx){
            errMsg = pEx.getMessage();
            System.assertEquals('Product',errMsg);
        } 
    }
    @isTest
    public static void verifyIND_InsuranceRecommendationRequest3(){
        Opportunity opcb1 = new Opportunity();
        opcb1.StageName = 'Qualification';
        opcb1.CloseDate = Date.newInstance(2021, 1, 11);
        opcb1.Name = 'testone';
        insert opcb1;
        Vehicle_Detail__c vg3 = new Vehicle_Detail__c();
        vg3.Loan_Application__c = opcb1.Id;
        vg3.Base_Price__c = 100000.00;
        vg3.Ben_Code__c = 'testveh';
        vg3.Valuer_code__c = 'BEN000871';
        vg3.Variant__c  = 'M&M KUV100 NXT K8 DIESEL';
        vg3.Make__c = 'TVS';
        vg3.Model__c = 'MAHINDRA MARAZZO';
        vg3.Engine_number__c  = 'TBH1H79814';
        vg3.Chassis_number__c  = 'MA1ZN2TBKH65317';
        vg3.Vehicle_Registration_number__c  = 'MH14GV9526';
        vg3.Product__c='Two Wheeler';
        insert vg3; 
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.Motor_Premium = 'DL0002';
        reqWrapper.leadId = 'L0002';
        reqWrapper.applicationNo = 'APP-002';
        reqWrapper.Borrower_Type ='Borrower';
        reqWrapper.vehicleId = 'DL0003';
        reqWrapper.gender = 'Male';
        reqWrapper.Product = 'Two Wheeler';
        reqWrapper.Vehicle_Category = 'New';
        reqWrapper.Variant = 'BRAND';
        reqWrapper.Fin_Amount = '100000.0';
        reqWrapper.Balance_Available = '100000.0';
        reqWrapper.Tenure = '5';
        reqWrapper.Agreement_Value = '30000';
        reqWrapper.Motor_Expiry_Date = '01-01-2025';
        reqWrapper.VehicleId=vg3.Id;
        reqWrapper.age='30';
        IND_InsuranceRecommendationRequest result = new IND_InsuranceRecommendationRequest(reqWrapper);
        String errMsg = '';
        try{
            result = new IND_InsuranceRecommendationRequest(reqWrapper);
            result.validate(System.Label.Insurance_Recommendation);
        }catch(Exception pEx){
            errMsg = pEx.getMessage();
            System.assertEquals('Age is required.',errMsg);
        } 
    } 
    
    @isTest
    public static void verifyIND_InsuranceRecommendationRequest4(){
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.Motor_Premium = 'DL0002';
        reqWrapper.leadId = 'L0002';
        reqWrapper.age = '30';
        reqWrapper.applicationNo = 'APP-002';
        reqWrapper.Borrower_Type ='Borrower';
        reqWrapper.vehicleId = 'DL0003';
        reqWrapper.Product = 'Two Wheeler';
        reqWrapper.Variant = 'BRAND';
        reqWrapper.Fin_Amount = '100000.0';
        reqWrapper.Balance_Available = '100000.0';
        reqWrapper.Tenure = '5';
        reqWrapper.Agreement_Value = '30000';
        reqWrapper.Motor_Expiry_Date = '01-01-2025';
        reqWrapper.gender='Male';
        reqWrapper.Vehicle_Category='Used';
        IND_InsuranceRecommendationRequest result = new IND_InsuranceRecommendationRequest(reqWrapper);
        String errMsg = '';
        try{
            result = new IND_InsuranceRecommendationRequest(reqWrapper);
            result.validate(System.Label.Insurance_Recommendation);
        }catch(Exception pEx){
            errMsg = pEx.getMessage();
            System.assertEquals('Gender is required.',errMsg);
        } 
    }   
}