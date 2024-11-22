@isTest
public class IND_PricingEngineRequestTest {
    
    @isTest
    public static void verifyIND_PricingEngineRequest(){
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        opgd1.Agent_BL_code__c = 'AG001';
        opgd1.Lead_number__c = 'L18012200011';
        insert opgd1;
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opgd1.Id;
        applicant.Applicant_Type__c  = null;
        applicant.Scorecard_Decision__c = 'Red';
        insert applicant;
        applicant.Opportunity__r = opgd1; 
        
        Final_Term__c fgd3 = new Final_Term__c();
        fgd3.CRM_IRR__c = 120;
        fgd3.Loan_Application__c = opgd1.Id;
        fgd3.Holiday_period__c='30';
        fgd3.EMI_Amount__c= 10000;
        fgd3.FIwaiver_offAddress__c = 'Not Waived';
        insert fgd3;
        
        Vehicle_Detail__c  vehicleDetail =  TestDataUtility.createTestVehicleDetailForIbb(false, opgd1);
        vehicleDetail.OEM_Dealer__c = true;
        insert vehicleDetail;
        
        
        Bl_Code_Details__c bcd1 = new Bl_Code_Details__c();
        bcd1.Bl_Code__c = opgd1.Agent_BL_code__c;
        bcd1.Name = 'test';
        insert bcd1;
        
        Geo_State_Masters__c gm1 = new Geo_State_Masters__c();
        gm1.NeSL_State_Code__c = 'test';
        gm1.OwnerId = UserInfo.getUserId();
        gm1.Pincode_Starting_Max__c = 524;
        gm1.Pincode__c = 315;
        gm1.Name = 'allur';
        gm1.State_Code__c = '01';
        insert gm1;
        
        
        BankBranchDetails__c bd1 = new BankBranchDetails__c();
        bd1.Bl_Code_Details__c = bcd1.Id;
        bd1.Geo_State_Master__c = gm1.Id;
        bd1.Address_1__c = 'testad1';
        bd1.Address_2__c = 'testad2';
        bd1.UniqueIdentifier__c = '201';
        bd1.District__c = 'nellore';
        insert bd1; 
        
        Profile_Master__c obj1 = new Profile_Master__c();
        obj1.code__c = '1';
        obj1.Category__c  = 'SENP';
        obj1.Name='test';
        insert obj1;
        
        Income_Details__c incomeObj = new Income_Details__c();
        incomeObj.Applicant__c = applicant.id;
        incomeObj.Profile__c = obj1.Id;
        insert incomeObj;
        
        
        Income_Details__c objIncomingDetails = new Income_Details__c();
        objIncomingDetails.Applicant__c = applicant.Id;
        objIncomingDetails.From_Month__c = '2022-03';
        objIncomingDetails.To_Month__c = '2022-09';
        objIncomingDetails.Is_Salaried__c = true;
        objIncomingDetails.Employer_Business_Name__c = 'Test';
        objIncomingDetails.Capture_GST_Method__c = 'Online via link'; 
        objIncomingDetails.Profile__c = obj1.Id;
        insert objIncomingDetails;
        objIncomingDetails.Applicant__r = applicant;
        
        
        RequestWrapper requestWrapper = new RequestWrapper();
        requestWrapper.scoreCardDecision = 'Red';
        requestWrapper.applicantId = applicant.ID;
        
        
        IND_PricingEngineRequest result = new IND_PricingEngineRequest(opgd1, opgd1.Id, requestWrapper);
        Boolean isValid = result.validate(System.Label.CSRVahanFIwaiver);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty());
        
        String errorMessage = '';
        try{
            requestWrapper.applicantId = '';
            result = new IND_PricingEngineRequest(opgd1, opgd1.Id, requestWrapper);
        }catch(Exception pEx){
            errorMessage =  pEx.getMessage(); 
        }
        //System.assert(errorMessage.contains(System.Label.Category));
        
        try{
            requestWrapper.scoreCardDecision = '';
            result = new IND_PricingEngineRequest(opgd1, opgd1.Id, requestWrapper);
        }catch(Exception pEx){
            errorMessage =  pEx.getMessage(); 
        }
        System.assert(errorMessage.contains(System.Label.RiskBand));
        
    }
    
     @isTest
    public static void verifyIND_PricingEngineRequest1(){
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        opgd1.Agent_BL_code__c = 'AG001';
        opgd1.Lead_number__c = 'L18012200011';
        insert opgd1;
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opgd1.Id;
        applicant.Applicant_Type__c  = null;
        applicant.Scorecard_Decision__c = 'Red';
        insert applicant;
        applicant.Opportunity__r = opgd1; 
        
        Final_Term__c fgd3 = new Final_Term__c();
        fgd3.CRM_IRR__c = 120;
        fgd3.Loan_Application__c = opgd1.Id;
        fgd3.Holiday_period__c='30';
        fgd3.EMI_Amount__c= 10000;
        fgd3.FIwaiver_offAddress__c = 'Not Waived';
        insert fgd3;
        
        Vehicle_Detail__c  vehicleDetail =  TestDataUtility.createTestVehicleDetailForIbb(false, opgd1);
        vehicleDetail.OEM_Dealer__c = true;
        insert vehicleDetail;
        
        
        Bl_Code_Details__c bcd1 = new Bl_Code_Details__c();
        bcd1.Bl_Code__c = opgd1.Agent_BL_code__c;
        bcd1.Name = 'test';
        insert bcd1;
        
        Geo_State_Masters__c gm1 = new Geo_State_Masters__c();
        gm1.NeSL_State_Code__c = 'test';
        gm1.OwnerId = UserInfo.getUserId();
        gm1.Pincode_Starting_Max__c = 524;
        gm1.Pincode__c = 315;
        gm1.Name = 'allur';
        gm1.State_Code__c = '01';
        insert gm1;
        
        
        BankBranchDetails__c bd1 = new BankBranchDetails__c();
        bd1.Bl_Code_Details__c = bcd1.Id;
        bd1.Geo_State_Master__c = gm1.Id;
        bd1.Address_1__c = 'testad1';
        bd1.Address_2__c = 'testad2';
        bd1.UniqueIdentifier__c = '201';
        bd1.District__c = 'nellore';
        insert bd1; 
        
        Profile_Master__c obj1 = new Profile_Master__c();
        obj1.code__c = '1';
        obj1.Category__c  = 'SENP';
        obj1.Name='test';
        insert obj1;
        
        Income_Details__c incomeObj = new Income_Details__c();
        incomeObj.Applicant__c = applicant.id;
        incomeObj.Profile__c = obj1.Id;
        insert incomeObj;
        
        
        Income_Details__c objIncomingDetails = new Income_Details__c();
        objIncomingDetails.Applicant__c = applicant.Id;
        objIncomingDetails.From_Month__c = '2022-03';
        objIncomingDetails.To_Month__c = '2022-09';
        objIncomingDetails.Is_Salaried__c = true;
        objIncomingDetails.Employer_Business_Name__c = 'Test';
        objIncomingDetails.Capture_GST_Method__c = 'Online via link'; 
        objIncomingDetails.Profile__c = obj1.Id;
        insert objIncomingDetails;
        objIncomingDetails.Applicant__r = applicant;
        
        
        RequestWrapper requestWrapper = new RequestWrapper();
        requestWrapper.scoreCardDecision = 'Dark Green';
        requestWrapper.applicantId = applicant.ID;
        
        
        IND_PricingEngineRequest result = new IND_PricingEngineRequest(opgd1, opgd1.Id, requestWrapper);
        Boolean isValid = result.validate(System.Label.CSRVahanFIwaiver);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty());
        
        String errorMessage = '';
        try{
            requestWrapper.applicantId = '';
            result = new IND_PricingEngineRequest(opgd1, opgd1.Id, requestWrapper);
        }catch(Exception pEx){
            errorMessage =  pEx.getMessage(); 
        }
        //System.assert(errorMessage.contains(System.Label.Category));
        
        try{
            requestWrapper.scoreCardDecision = '';
            result = new IND_PricingEngineRequest(opgd1, opgd1.Id, requestWrapper);
        }catch(Exception pEx){
            errorMessage =  pEx.getMessage(); 
        }
        System.assert(errorMessage.contains(System.Label.RiskBand));
        
    }
    
    
     @isTest
    public static void verifyIND_PricingEngineRequest2(){
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        opgd1.Agent_BL_code__c = 'AG001';
        opgd1.Lead_number__c = 'L18012200011';
        insert opgd1;
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opgd1.Id;
        applicant.Applicant_Type__c  = null;
        applicant.Scorecard_Decision__c = 'Red';
        insert applicant;
        applicant.Opportunity__r = opgd1; 
        
        Final_Term__c fgd3 = new Final_Term__c();
        fgd3.CRM_IRR__c = 120;
        fgd3.Loan_Application__c = opgd1.Id;
        fgd3.Holiday_period__c='30';
        fgd3.EMI_Amount__c= 10000;
        fgd3.FIwaiver_offAddress__c = 'Not Waived';
        insert fgd3;
        
        Vehicle_Detail__c  vehicleDetail =  TestDataUtility.createTestVehicleDetailForIbb(false, opgd1);
        vehicleDetail.OEM_Dealer__c = true;
        insert vehicleDetail;
        
        
        Bl_Code_Details__c bcd1 = new Bl_Code_Details__c();
        bcd1.Bl_Code__c = opgd1.Agent_BL_code__c;
        bcd1.Name = 'test';
        insert bcd1;
        
        Geo_State_Masters__c gm1 = new Geo_State_Masters__c();
        gm1.NeSL_State_Code__c = 'test';
        gm1.OwnerId = UserInfo.getUserId();
        gm1.Pincode_Starting_Max__c = 524;
        gm1.Pincode__c = 315;
        gm1.Name = 'allur';
        gm1.State_Code__c = '01';
        insert gm1;
        
        
        BankBranchDetails__c bd1 = new BankBranchDetails__c();
        bd1.Bl_Code_Details__c = bcd1.Id;
        bd1.Geo_State_Master__c = gm1.Id;
        bd1.Address_1__c = 'testad1';
        bd1.Address_2__c = 'testad2';
        bd1.UniqueIdentifier__c = '201';
        bd1.District__c = 'nellore';
        insert bd1; 
        
        Profile_Master__c obj1 = new Profile_Master__c();
        obj1.code__c = '1';
        obj1.Category__c  = 'SENP';
        obj1.Name='test';
        insert obj1;
        
        Income_Details__c incomeObj = new Income_Details__c();
        incomeObj.Applicant__c = applicant.id;
        incomeObj.Profile__c = obj1.Id;
        insert incomeObj;
        
        
        Income_Details__c objIncomingDetails = new Income_Details__c();
        objIncomingDetails.Applicant__c = applicant.Id;
        objIncomingDetails.From_Month__c = '2022-03';
        objIncomingDetails.To_Month__c = '2022-09';
        objIncomingDetails.Is_Salaried__c = true;
        objIncomingDetails.Employer_Business_Name__c = 'Test';
        objIncomingDetails.Capture_GST_Method__c = 'Online via link'; 
        objIncomingDetails.Profile__c = obj1.Id;
        insert objIncomingDetails;
        objIncomingDetails.Applicant__r = applicant;
        
        
        RequestWrapper requestWrapper = new RequestWrapper();
        requestWrapper.scoreCardDecision = 'Light Green';
        requestWrapper.applicantId = applicant.ID;
        
        
        IND_PricingEngineRequest result = new IND_PricingEngineRequest(opgd1, opgd1.Id, requestWrapper);
        Boolean isValid = result.validate(System.Label.CSRVahanFIwaiver);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty());
        
        String errorMessage = '';
        try{
            requestWrapper.applicantId = '';
            result = new IND_PricingEngineRequest(opgd1, opgd1.Id, requestWrapper);
        }catch(Exception pEx){
            errorMessage =  pEx.getMessage(); 
        }
        //System.assert(errorMessage.contains(System.Label.Category));
        
        try{
            requestWrapper.scoreCardDecision = '';
            result = new IND_PricingEngineRequest(opgd1, opgd1.Id, requestWrapper);
        }catch(Exception pEx){
            errorMessage =  pEx.getMessage(); 
        }
        System.assert(errorMessage.contains(System.Label.RiskBand));
        
    }
    
     @isTest
    public static void verifyIND_PricingEngineRequest3(){
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        opgd1.Agent_BL_code__c = 'AG001';
        opgd1.Lead_number__c = 'L18012200011';
        insert opgd1;
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opgd1.Id;
        applicant.Applicant_Type__c  = null;
        applicant.Scorecard_Decision__c = 'Red';
        insert applicant;
        applicant.Opportunity__r = opgd1; 
        
        Final_Term__c fgd3 = new Final_Term__c();
        fgd3.CRM_IRR__c = 120;
        fgd3.Loan_Application__c = opgd1.Id;
        fgd3.Holiday_period__c='30';
        fgd3.EMI_Amount__c= 10000;
        fgd3.FIwaiver_offAddress__c = 'Not Waived';
        insert fgd3;
        
        Vehicle_Detail__c  vehicleDetail =  TestDataUtility.createTestVehicleDetailForIbb(false, opgd1);
        vehicleDetail.OEM_Dealer__c = true;
        insert vehicleDetail;
        
        
        Bl_Code_Details__c bcd1 = new Bl_Code_Details__c();
        bcd1.Bl_Code__c = opgd1.Agent_BL_code__c;
        bcd1.Name = 'test';
        insert bcd1;
        
        Geo_State_Masters__c gm1 = new Geo_State_Masters__c();
        gm1.NeSL_State_Code__c = 'test';
        gm1.OwnerId = UserInfo.getUserId();
        gm1.Pincode_Starting_Max__c = 524;
        gm1.Pincode__c = 315;
        gm1.Name = 'allur';
        gm1.State_Code__c = '01';
        insert gm1;
        
        
        BankBranchDetails__c bd1 = new BankBranchDetails__c();
        bd1.Bl_Code_Details__c = bcd1.Id;
        bd1.Geo_State_Master__c = gm1.Id;
        bd1.Address_1__c = 'testad1';
        bd1.Address_2__c = 'testad2';
        bd1.UniqueIdentifier__c = '201';
        bd1.District__c = 'nellore';
        insert bd1; 
        
        Profile_Master__c obj1 = new Profile_Master__c();
        obj1.code__c = '1';
        obj1.Category__c  = 'SENP';
        obj1.Name='test';
        insert obj1;
        
        Income_Details__c incomeObj = new Income_Details__c();
        incomeObj.Applicant__c = applicant.id;
        incomeObj.Profile__c = obj1.Id;
        insert incomeObj;
        
        
        Income_Details__c objIncomingDetails = new Income_Details__c();
        objIncomingDetails.Applicant__c = applicant.Id;
        objIncomingDetails.From_Month__c = '2022-03';
        objIncomingDetails.To_Month__c = '2022-09';
        objIncomingDetails.Is_Salaried__c = true;
        objIncomingDetails.Employer_Business_Name__c = 'Test';
        objIncomingDetails.Capture_GST_Method__c = 'Online via link'; 
        objIncomingDetails.Profile__c = obj1.Id;
        insert objIncomingDetails;
        objIncomingDetails.Applicant__r = applicant;
        
        
        RequestWrapper requestWrapper = new RequestWrapper();
        requestWrapper.scoreCardDecision = 'Yellow';
        requestWrapper.applicantId = applicant.ID;
        
        
        IND_PricingEngineRequest result = new IND_PricingEngineRequest(opgd1, opgd1.Id, requestWrapper);
        Boolean isValid = result.validate(System.Label.CSRVahanFIwaiver);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty());
        
        String errorMessage = '';
        try{
            requestWrapper.applicantId = '';
            result = new IND_PricingEngineRequest(opgd1, opgd1.Id, requestWrapper);
        }catch(Exception pEx){
            errorMessage =  pEx.getMessage(); 
        }
        //System.assert(errorMessage.contains(System.Label.Category));
        
        try{
            requestWrapper.scoreCardDecision = '';
            result = new IND_PricingEngineRequest(opgd1, opgd1.Id, requestWrapper);
        }catch(Exception pEx){
            errorMessage =  pEx.getMessage(); 
        }
        //System.assert(errorMessage.contains(System.Label.RiskBand));
        
    }
    
     @isTest
    public static void verifyIND_PricingEngineRequest4(){
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        opgd1.Agent_BL_code__c = 'AG001';
        opgd1.Lead_number__c = 'L18012200011';
        insert opgd1;
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opgd1.Id;
        applicant.Applicant_Type__c  = null;
        applicant.Scorecard_Decision__c = 'Red';
        insert applicant;
        applicant.Opportunity__r = opgd1; 
        
        Final_Term__c fgd3 = new Final_Term__c();
        fgd3.CRM_IRR__c = 120;
        fgd3.Loan_Application__c = opgd1.Id;
        fgd3.Holiday_period__c='30';
        fgd3.EMI_Amount__c= 10000;
        fgd3.FIwaiver_offAddress__c = 'Not Waived';
        insert fgd3;
        
        Vehicle_Detail__c  vehicleDetail =  TestDataUtility.createTestVehicleDetailForIbb(false, opgd1);
        vehicleDetail.OEM_Dealer__c = true;
        insert vehicleDetail;
        
        
        Bl_Code_Details__c bcd1 = new Bl_Code_Details__c();
        bcd1.Bl_Code__c = opgd1.Agent_BL_code__c;
        bcd1.Name = 'test';
        insert bcd1;
        
        Geo_State_Masters__c gm1 = new Geo_State_Masters__c();
        gm1.NeSL_State_Code__c = 'test';
        gm1.OwnerId = UserInfo.getUserId();
        gm1.Pincode_Starting_Max__c = 524;
        gm1.Pincode__c = 315;
        gm1.Name = 'allur';
        gm1.State_Code__c = '01';
        insert gm1;
        
        
        BankBranchDetails__c bd1 = new BankBranchDetails__c();
        bd1.Bl_Code_Details__c = bcd1.Id;
        bd1.Geo_State_Master__c = gm1.Id;
        bd1.Address_1__c = 'testad1';
        bd1.Address_2__c = 'testad2';
        bd1.UniqueIdentifier__c = '201';
        bd1.District__c = 'nellore';
        insert bd1; 
        
        Profile_Master__c obj1 = new Profile_Master__c();
        obj1.code__c = '1';
        obj1.Category__c  = 'SENP';
        obj1.Name='test';
        insert obj1;
        
        Income_Details__c incomeObj = new Income_Details__c();
        incomeObj.Applicant__c = applicant.id;
        incomeObj.Profile__c = obj1.Id;
        insert incomeObj;
        
        
        Income_Details__c objIncomingDetails = new Income_Details__c();
        objIncomingDetails.Applicant__c = applicant.Id;
        objIncomingDetails.From_Month__c = '2022-03';
        objIncomingDetails.To_Month__c = '2022-09';
        objIncomingDetails.Is_Salaried__c = true;
        objIncomingDetails.Employer_Business_Name__c = 'Test';
        objIncomingDetails.Capture_GST_Method__c = 'Online via link'; 
        objIncomingDetails.Profile__c = obj1.Id;
        insert objIncomingDetails;
        objIncomingDetails.Applicant__r = applicant;
        
        
        RequestWrapper requestWrapper = new RequestWrapper();
        requestWrapper.scoreCardDecision = 'Orange';
        requestWrapper.applicantId = applicant.ID;
        
        
        IND_PricingEngineRequest result = new IND_PricingEngineRequest(opgd1, opgd1.Id, requestWrapper);
        Boolean isValid = result.validate(System.Label.CSRVahanFIwaiver);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty());
        
        String errorMessage = '';
        try{
            requestWrapper.applicantId = '';
            result = new IND_PricingEngineRequest(opgd1, opgd1.Id, requestWrapper);
        }catch(Exception pEx){
            errorMessage =  pEx.getMessage(); 
        }
        //System.assert(errorMessage.contains(System.Label.Category));
        
        try{
            requestWrapper.scoreCardDecision = '';
            result = new IND_PricingEngineRequest(opgd1, opgd1.Id, requestWrapper);
        }catch(Exception pEx){
            errorMessage =  pEx.getMessage(); 
        }
        //System.assert(errorMessage.contains(System.Label.RiskBand));
        
    }
}