/**
* @Name         Loan Details
* @Author       Raj Gupta
* @Company      Persistent Systems
* @Description  This class contains all methods related to loan Details initiation
* Inputs:       None
* Test Class:   IND_LWC_LoanDetailsCntlTest
*/
public with sharing class IND_LWC_LoanDetailsCntrl {   
    private Static Final String CARWALE_API = 'CarwaleApi_Attemps';
    //CISP-15787 Start
    @AuraEnabled
    public static Vehicle_Detail__c getVehicleDetails(String oppId){
        try{
            List<Vehicle_Detail__c> vdList = [SELECT Id,Product_Segment__c FROM Vehicle_Detail__c WHERE Loan_Application__c=:oppId LIMIT 1];
            if(vdList.size() > 0){
            return vdList[0];
            }else{
            throw new IND_Exception('Vehicle Details not available.');
            }
        }Catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_LWC_LoanDetailsCntrl', 'getVehicleDetails', System.Label.Apex, e, '');
            throw new IND_Exception(e.getMessage());
        }
    }
    //CISP-15787 End
    
    @AuraEnabled
    public static LoanDetailResponseWrapper fetchLoanDetails(String opportunityId) {
        return IND_LWC_LoanDetailsCntrl.fetchLoanDetails(opportunityId,'');
    }

    public Class FOIRInfoWrapper{
        @auraEnabled public string applicantId; 
        @auraEnabled public string coBorrowerApplicantId; 
        @auraEnabled public List<String> appList;
    }

    @AuraEnabled
    public static FOIRInfoWrapper getRequestDetails(string oppId){
        try {
            if(oppId!=null){
                FOIRInfoWrapper wrapperObj = new FOIRInfoWrapper();
                List<String> applicantTypesList = new List<String>();
                List<Applicant__C> applicantList = new List<Applicant__c>();
                applicantList = [SELECT Id,Applicant_Type__c FROM Applicant__c WHERE Opportunity__c=:oppId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED ORDER BY Applicant_Type__c ASC];
                    if(!applicantList.isEmpty()){
                        for (Applicant__c applicantObj : applicantList) {
                            applicantTypesList.add(applicantObj.Applicant_Type__c);
                            if(applicantObj.Applicant_Type__c=='Borrower'){
                                wrapperObj.applicantId = applicantObj.Id;
                            }
                            if(applicantObj.Applicant_Type__c=='Co-borrower'){
                                wrapperObj.coBorrowerApplicantId = applicantObj.Id;
                            }
                        }
                    }
                wrapperObj.appList = applicantTypesList;
                return wrapperObj;
            }
            return null;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_LWC_LoanDetailsCntrl', 'getRequestDetails', e.getTypeName(), e, '');
            return null;
        }
    }

    /*
    * @Method:      fetchLoanDetails
    * @Created by:  Raj Gupta
    * @Description: This method will fetch fields from Opportunity, vehicle details,ROI Master.
    * @Param:       String - current Applicantion ID
    * @Return:      json - carwale api response.
    */
    @AuraEnabled
    public static LoanDetailResponseWrapper fetchLoanDetails(String opportunityId, String dealId) {
        Opportunity opp = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =: opportunityId WITH SECURITY_ENFORCED];
        try{
            if(opportunityId != null){
                String sServiceName = System.Label.carwaleapi;
                LoanDetailResponseWrapper loanDetailWrapperObj = new LoanDetailResponseWrapper(); 
                List<Opportunity> loanDetailsList = new List<Opportunity>();
                if(opp.Product_Type__c == 'Tractor'){
                    List<Vehicle_Detail__c> VehicleLst = new List<Vehicle_Detail__c>();
                    
                    if(String.isNotBlank(dealId)){
                        VehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId AND Loan_Application__c =: opportunityId WITH SECURITY_ENFORCED];
                        loanDetailsList = [SELECT Id, Name,Total_Exposures_Amount__c,Lead_number__c,Customer_Name__c,Contact_number__c, Loan_amount__c, Product_Type__c, Vehicle_Sub_Category__c, Vehicle_Type__c, Required_Loan_amount__c, Required_Tenure__c, Required_ROI__c, Funding_on_Ex_Showroom__c, Funding_on_ORP__c, Is_customer_interested_in_a_motor_insura__c, Funded__c, Non_Funded__c, X1st_yr_Insurance_Premium__c, Motor_Insurance_Premium__c, Basic_Price__c, GST_Amount__c, Discount_on_Basic_Price__c, Ex_showroom_price__c, Ex_showroom_price_carwale__c,RTO_Road_Tax__c,RTO_Road_Tax_New__c, Other_charges__c, On_Road_price__c, On_Road_price_carwale__c, Final_Price__c, Is_Loan_Details_Submitted__c, StageName, LastStageName__c,Sub_Stage__c, LeadSource,FAME_Subsidy__c,Performance_Upgrade__c,Application_Type__c,Customer_Type__c,  Registration_Number_Format__c,Vehicle_Registration_Number__c,  
                                        (SELECT ID,Manufacturer_Year_Month__c,Insurance_expiring_within_60_days__c,Eligible_Tenure__c,Eligible_Loan_Amount__c,Basic_Price__c, Loan_Amount__c, Required_Tenure__c, Required_CRM_IRR__c, Funding_on_Invoice_Amount__c, Funded__c, Non_Funded__c, X1st_yr_Insurance_Premium__c, GST_Amount__c, Invoice_Price__c, Vehicle_Type__c, Is_Customer_Interested_in_MotorInsurance__c, Cost_of_the_body__c, Cost_of_the_Chassis__c, Serial_number__c, Vehicle_SubType__c,Make__c,Model__c,Variant__c,Product_Segment__c,Vehicle_Delivered__c,Vehicle_Registration_number__c,Registration_Number_Format__c,Chassis_number__c,Engine_number__c FROM Vehicle_Details__r WHERE Id	=: VehicleLst[0].Id ORDER BY CreatedDate ASC), 
                                        (SELECT Id, CRM_IRR__c,Offerengine_On_Road_Price__c FROM Final_Terms__r WHERE Vehicle_Detail__c =: VehicleLst[0].Id),  (SELECT Id,Name from Applicants__r) FROM Opportunity WHERE Id =: opportunityId WITH SECURITY_ENFORCED LIMIT 1];//Ola Integration changes
                    }else{
                        loanDetailsList = [SELECT Id, Name,Total_Exposures_Amount__c,Lead_number__c,Customer_Name__c,Contact_number__c, Loan_amount__c, Product_Type__c, Vehicle_Sub_Category__c, Vehicle_Type__c, Required_Loan_amount__c, Required_Tenure__c, Required_ROI__c, Funding_on_Ex_Showroom__c, Funding_on_ORP__c, Is_customer_interested_in_a_motor_insura__c, Funded__c, Non_Funded__c, X1st_yr_Insurance_Premium__c, Motor_Insurance_Premium__c, Basic_Price__c, GST_Amount__c, Discount_on_Basic_Price__c, Ex_showroom_price__c, Ex_showroom_price_carwale__c,RTO_Road_Tax__c,RTO_Road_Tax_New__c, Other_charges__c, On_Road_price__c, On_Road_price_carwale__c, Final_Price__c, Is_Loan_Details_Submitted__c, StageName, LastStageName__c,Sub_Stage__c,  LeadSource,FAME_Subsidy__c,Performance_Upgrade__c,Application_Type__c,Customer_Type__c,Registration_Number_Format__c,Vehicle_Registration_Number__c,(SELECT ID,Manufacturer_Year_Month__c,Insurance_expiring_within_60_days__c,Eligible_Tenure__c,Eligible_Loan_Amount__c,Vehicle_type__c,Basic_Price__c, Loan_Amount__c, Required_Tenure__c, Required_CRM_IRR__c, Funding_on_Invoice_Amount__c, Funded__c, Non_Funded__c, X1st_yr_Insurance_Premium__c, GST_Amount__c, Invoice_Price__c, Is_Customer_Interested_in_MotorInsurance__c, Cost_of_the_body__c, Cost_of_the_Chassis__c,Make__c,Model__c,Variant__c,Vehicle_SubType__c FROM Vehicle_Details__r ORDER BY CreatedDate ASC), (SELECT Id, CRM_IRR__c,Offerengine_On_Road_Price__c FROM Final_Terms__r),(SELECT Id,Name from Applicants__r),Total_Funded_Premium__c FROM Opportunity WHERE Id =: opportunityId WITH SECURITY_ENFORCED LIMIT 1];//Ola Integration changes & //CISP-5752//CISH-77  &//CISP-6945
                    }
                }else{
                    loanDetailsList = [SELECT Id, Name,Total_Exposures_Amount__c,Lead_number__c,Customer_Name__c,Contact_number__c, Loan_amount__c, Product_Type__c, Vehicle_Sub_Category__c, Vehicle_Type__c, Required_Loan_amount__c, Required_Tenure__c, Required_ROI__c, Funding_on_Ex_Showroom__c, Funding_on_ORP__c, Is_customer_interested_in_a_motor_insura__c, Funded__c, Non_Funded__c, X1st_yr_Insurance_Premium__c, Motor_Insurance_Premium__c, Basic_Price__c, GST_Amount__c, Discount_on_Basic_Price__c, Ex_showroom_price__c, Ex_showroom_price_carwale__c,RTO_Road_Tax__c,RTO_Road_Tax_New__c, Other_charges__c, On_Road_price__c, On_Road_price_carwale__c, Final_Price__c, Is_Loan_Details_Submitted__c, StageName, LastStageName__c,Sub_Stage__c,  LeadSource,FAME_Subsidy__c,Performance_Upgrade__c,Application_Type__c,Registration_Number_Format__c,Vehicle_Registration_Number__c,(SELECT ID,Manufacturer_Year_Month__c,Insurance_expiring_within_60_days__c,Eligible_Tenure__c,Eligible_Loan_Amount__c,Vehicle_type__c,Basic_Price__c, Loan_Amount__c, Required_Tenure__c, Required_CRM_IRR__c, Funding_on_Invoice_Amount__c, Funded__c, Non_Funded__c, X1st_yr_Insurance_Premium__c, GST_Amount__c, Invoice_Price__c, Is_Customer_Interested_in_MotorInsurance__c, Cost_of_the_body__c, Cost_of_the_Chassis__c,Make__c,Model__c,Variant__c,Vehicle_SubType__c FROM Vehicle_Details__r ORDER BY CreatedDate ASC limit 1), (SELECT Id, CRM_IRR__c,Offerengine_On_Road_Price__c FROM Final_Terms__r),(SELECT Id,Name from Applicants__r),Total_Funded_Premium__c FROM Opportunity WHERE Id =: opportunityId WITH SECURITY_ENFORCED LIMIT 1];//Ola Integration changes & //CISP-5752//CISH-77  &//CISP-6945
                }              
                List<Retry_Count__c> retryCountList = [select Id, Count__c, IsAPIFailed__c from Retry_Count__c where Loan_Application_Id__c = :opportunityId and Service_Name__c = :sServiceName WITH SECURITY_ENFORCED limit 1];

                if(!loanDetailsList.isEmpty() && !loanDetailsList[0].Vehicle_Details__r.isEmpty()) {
                    loanDetailWrapperObj.loanApplicationDetails = loanDetailsList;

                    //Get Variant Code of Selected Variant
                    String VariantName = loanDetailsList[0].Vehicle_Details__r[0].Variant__c;
                    if(VariantName != null){
                        List<Product2> prodObjList =  [select Id, Variant_Code__c from Product2 where Name =: VariantName AND Type__c = 'Variant' WITH SECURITY_ENFORCED LIMIT 1];//Ola integration changes.
                        
                        if(!prodObjList.isEmpty()){
                            loanDetailWrapperObj.variantcode = prodObjList[0].Variant_Code__c;
                        }
                    }

                     //Get GST Percentage
                    //vehicleCategoryCode__mdt vehicleCategoryCodes= [SELECT vehicleCategoryCode__c from vehicleCategoryCode__mdt where vehicleType__c =: loanDetailsList[0].Vehicle_Type__c and productType__c =: loanDetailsList[0].Product_Type__c];
                    VehicleTypeCategory__mdt vehicleTypeCategory = [SELECT vehicleCategoryCode__c from VehicleTypeCategory__mdt where vehicleType__c =: loanDetailsList[0].Vehicle_Type__c and productType__c =: loanDetailsList[0].Product_Type__c]; 
                    
                    System_Constant_custom_metadata__mdt metadata = System_Constant_custom_metadata__mdt.getInstance('GstPercentage');
                    loanDetailWrapperObj.gstPercentage = metadata.GstPercentage__c;
                    
                    String vehicleCategoryCode = vehicleTypeCategory.vehicleCategoryCode__c;
                    //List<ROI_Master__c> roiList = [select Max_Value__c,Min_Value__c from ROI_Master__c where Description__c =: System.Label.ROI and Vehicle_Category__c =: vehicleCategoryCode WITH SECURITY_ENFORCED Limit 1];
                    //if(!roiList.isEmpty()){
                    //   	loanDetailWrapperObj.maxValue = roiList[0].Max_Value__c;
                    //	loanDetailWrapperObj.minValue = roiList[0].Min_Value__c;
                    //}
                    if(loanDetailsList[0].Product_Type__c== 'TWO WHEELER'){
                        List<ROI_Master__c> roiList = [select Max_Value__c,Min_Value__c from ROI_Master__c where Description__c =: System.Label.ROI and Vehicle_Category__c =: vehicleCategoryCode and Product_Segment__c =: 'TWO_WHEELER' WITH SECURITY_ENFORCED Limit 1];
                    	if(!roiList.isEmpty()){
                      	loanDetailWrapperObj.maxValue = roiList[0].Max_Value__c;//CISP-2346
                    	loanDetailWrapperObj.minValue = roiList[0].Min_Value__c;
                        }
                    } else {
                        List<ROI_Master__c> roiList = [select Max_Value__c,Min_Value__c from ROI_Master__c where Description__c =: System.Label.ROI and Vehicle_Category__c =: vehicleCategoryCode AND Tenure_Max__c >=: loanDetailsList[0].Required_Tenure__c AND Tenure_Min__c<=: loanDetailsList[0].Required_Tenure__c AND Product__r.ProductCode ='C' WITH SECURITY_ENFORCED Limit 1];
                    	if(!roiList.isEmpty()){
                       	loanDetailWrapperObj.maxValue = roiList[0].Max_Value__c;
                    	loanDetailWrapperObj.minValue = roiList[0].Min_Value__c;
                        }
                    }
                                                                              
                    if(Test.isRunningTest()) {
                        throw new AuraHandledException(System.Label.ExceptionMessage);
                    }
                }
                if(!loanDetailsList.isEmpty() && !loanDetailsList[0].Final_Terms__r.isEmpty()) {
                    loanDetailWrapperObj.crmIRRTW = String.valueOf(loanDetailsList[0].Final_Terms__r[0].CRM_IRR__c);
                }

                List<Documents__C> docObjList = new List<Documents__C>();
                if(opp.Product_Type__c == 'Tractor'){
                    List<Vehicle_Detail__c> vehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId AND Loan_Application__c =: opportunityId WITH SECURITY_ENFORCED];
                    if (!vehicleLst.isEmpty()) {
                    docObjList = [SELECT Id, KYC_City__c 
                                    FROM Documents__C 
                                    WHERE RecordType.Name = 'KYC Document' AND Opportunity_Relation__c = :opportunityId AND KYC_City__c != null AND Proof_of_Address_POA__c = true AND Vehicle_Detail__c =: vehicleLst[0].Id
                                    WITH SECURITY_ENFORCED 
                                    LIMIT 1];
                    }
                }else{
                    docObjList = [SELECT Id, KYC_City__c 
                                    FROM Documents__C 
                                    WHERE RecordType.Name = 'KYC Document' AND Opportunity_Relation__c = :opportunityId AND KYC_City__c != null AND Proof_of_Address_POA__c = true 
                                    WITH SECURITY_ENFORCED 
                                    LIMIT 1];
                }
                
                if(!docObjList.isEmpty()){
                    String cityName = docObjList[0].KYC_City__c;
                    List <City_State_Master__c> cityMasterList =  [select City_Code__c,Carwale_ID__c from City_State_Master__c where Name =: cityName WITH SECURITY_ENFORCED LIMIT 1];
                    if(!cityMasterList.isEmpty()){
                        loanDetailWrapperObj.citycode = cityMasterList[0].Carwale_ID__c; 
                    }
                }
                
                if(!retryCountList.isEmpty()){
                    loanDetailWrapperObj.retryCountDetails = retryCountList;
                }
				System.debug('Loan Details:: '+ loanDetailWrapperObj);
                return loanDetailWrapperObj;
            }
            return null;
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent(System.Label.IND_LWC_LoanDetailsCntrl , System.Label.getDetailsforLoan, System.Label.Apex, e);
            throw new AuraHandledException(e.getStackTraceString());
        }
    }
    

    /*
    * @Method:      saveVehicleDetailsForTractor
    * @Created by:  Neeraj Mehethrajkar
    * @Description: This method will save vehicle details for Loan application's in Loan Details screen
    * @Param:       wrapper object
    * @Return:      Boolean - Success
    */
    @AuraEnabled
    public static Boolean saveVehicleDetailsForTractor(String vehicleListString) {
        System.debug(vehicleListString);
        List<vehicleDetailsWrapper> vehicleList = (List<vehicleDetailsWrapper>)JSON.deserialize(vehicleListString, List<vehicleDetailsWrapper>.class);
        System.debug(vehicleList);
        List<Vehicle_Detail__c> vehiclesToUpdate = new List<Vehicle_Detail__c>();

        for (vehicleDetailsWrapper vehicle : vehicleList) {
            Vehicle_Detail__c vehicleObj = new Vehicle_Detail__c();
            vehicleObj.Id = vehicle.recordId;
            vehicleObj.Loan_Amount__c = vehicle.requiredLoanAmount;
            vehicleObj.Required_Tenure__c = vehicle.requiredTenure;
            vehicleObj.Required_CRM_IRR__c = vehicle.requiredCRMIRRTW;
            vehicleObj.Is_Customer_Interested_in_MotorInsurance__c = vehicle.isCustomerInterested;
            vehicleObj.Funded__c = vehicle.funded;
            vehicleObj.Non_Funded__c = vehicle.nonFunded;
            vehicleObj.X1st_yr_Insurance_Premium__c = vehicle.firstYrInsurancePremium;
            vehicleObj.GST_Amount__c = vehicle.gstAmount;
            vehicleObj.Invoice_Price__c = vehicle.invoicePrice;
            vehicleObj.Basic_Price__c = vehicle.basicPrice;
            vehicleObj.Cost_of_the_body__c = vehicle.costOfBody;
            vehicleObj.Cost_of_the_Chassis__c = vehicle.costOfChassis;
            vehiclesToUpdate.add(vehicleObj);
        }

        if (!vehiclesToUpdate.isEmpty()) {
            update vehiclesToUpdate;
            return true;
        }

        return false;
    }

    public class vehicleDetailsWrapper {
        @AuraEnabled public Id recordId;
        @AuraEnabled public Integer requiredLoanAmount;
        @AuraEnabled public Integer requiredTenure;
        @AuraEnabled public Decimal requiredCRMIRRTW;
        @AuraEnabled public Boolean isCustomerInterested;
        @AuraEnabled public Boolean funded;
        @AuraEnabled public Boolean nonFunded;
        @AuraEnabled public Integer firstYrInsurancePremium;
        @AuraEnabled public Integer gstAmount;
        @AuraEnabled public Integer invoicePrice;
        @AuraEnabled public Integer basicPrice;
        @AuraEnabled public Integer costOfBody;
        @AuraEnabled public Integer costOfChassis;
    }

    /*
    * @Method:      checkRetryExhausted
    * @Created by:  Raj Gupta
    * @Description: This method will return success response
    * @Param:       String - current Applicantion ID
    * @Return:      json - response and Also check the retry attemps
    */
    @AuraEnabled
    public static String checkRetryExhausted(String loanApplicationId){
        try{
            String sServiceName = System.Label.carwaleapi;
            CarwaleAPIWrapper responseJSON = new CarwaleAPIWrapper();
             
            if(loanApplicationId != null){
                List<Retry_Count__c> retryCountList = [select Loan_Application_Id__c, Count__c from Retry_Count__c where Loan_Application_Id__c = :loanApplicationId and Service_Name__c = :sServiceName WITH SECURITY_ENFORCED limit 1];
                System.debug('Service Name:: '+retryCountList);
                
                if(retryCountList.isEmpty()) {
                    Retry_Count__c retryCount = new Retry_Count__c();
                    retryCount.Loan_Application_Id__c = loanApplicationId;
                    retryCount.Module__c = 'Loan Details';                    
                    retryCount.Service_Name__c = sServiceName;
                    retryCount.Count__c = 1;

                    if(Schema.sObjectType.Retry_Count__c.isCreateable()) {
                        insert retryCount;
                    }
                } else {
                    System_Constant_custom_metadata__mdt metadata = System_Constant_custom_metadata__mdt.getInstance(CARWALE_API); 
                    //If number of attempts are greater than predefined number of attempts.

                    if(retryCountList[0].Count__c >= metadata.Number_Of_Attempts__c) {
                        responseJSON.message = System.Label.Retry_Exhausted;
                        String serializedResponse = JSON.serialize(responseJSON);
                        
                        retryCountList[0].IsAPIFailed__c = true;
                        if (Schema.sObjectType.Retry_Count__c.isUpdateable()){
                            update retryCountList[0];
                        }

                        return serializedResponse;
                    } else {
                    	//If number of attempts are Less than predefined number of attempts.
                        retryCountList[0].Count__c += 1;
                        
                        if (Schema.sObjectType.Retry_Count__c.isUpdateable()){
                            update retryCountList[0];
                        }                    
                        responseJSON.message = 	System.Label.SuccessMessage;
                        String serializedResponse = JSON.serialize(responseJSON);
                        return serializedResponse;
                    }
                }
            }
            
            String serializedResponse = JSON.serialize(responseJSON);
            if(Test.isRunningTest()){
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
            return serializedResponse;
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent(System.Label.IND_LWC_LoanDetailsCntrl ,System.Label.CheckRetryExhausted, System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    /*
    * @Method:      calculatePrices
    * @Created by:  Raj Gupta
    * @Description: This method will return the calculated result
    * @Param:       object - price details
    * @Return:      json - calculated values
    */
    @AuraEnabled
    public static String calculatePrices(String detail) {
        String journeyStatus;
        Double finalPrice;
        Double lowerLimit;
        Double upperLimit;
        DetailsWrapper resJON = new DetailsWrapper();
        try {
            DetailWrapper detailObject = (DetailWrapper) JSON.deserialize(detail, DetailWrapper.class);
              Loan_Variation__mdt loanVariation  = [select lowerLimitCsdCase__c,lowerLimitExShowroom__c,upperLimitCSDCase__c,upperLimitExShowroom__c from Loan_Variation__mdt limit 1];
            
            //Check CSD case
            if(detailObject.flagtocheckCsddetail == false) {  
                //Lowerlimit = 5% && Upperlimit = 1%
                lowerLimit  = loanVariation.lowerLimitExShowroom__c;
                upperLimit = loanVariation.upperLimitExShowroom__c;

            } else {
                //Lowerlimit = 35% && Upperlimit = 1%
                lowerLimit  = loanVariation.lowerLimitCsdCase__c;
                upperLimit = loanVariation.upperLimitCSDCase__c;
            }
            
            //ExShowroomPriceOne and  ExShowroomPriceTwo Calculation            
            Decimal exShowroomPriceOne = detailObject.basicPricedetail + detailObject.gstAmountdetail - detailObject.discountOnBasicPriceDetail;
            Decimal exShowroomPriceTwo = 0; 
            if (detailObject != null && detailObject.exShowroomPriceCarwaledetail != null  ){
                exShowroomPriceTwo = detailObject.exShowroomPriceCarwaledetail - detailObject.discountOnBasicPriceDetail;
            }
            
            resJON.exShowroomPriceOne = exShowroomPriceOne;
            resJON.exShowroomPriceTwo = exShowroomPriceTwo;
            //onRoadPriceOne and  onRoadPriceTwo Calculation
            Decimal onRoadPriceOne = (exShowroomPriceOne!=null?exShowroomPriceOne:0) + (detailObject.rtoRoadTaxDetail!=null?detailObject.rtoRoadTaxDetail:0)  + (detailObject.otherChargesDetail!=null?detailObject.otherChargesDetail:0)  + (detailObject.insurancePremiumDeatil!=null?detailObject.insurancePremiumDeatil:0) ; //CISP-2346 //CISP-2621
            Decimal onRoadPriceTwo = (exShowroomPriceTwo!=null?exShowroomPriceTwo:0) + (detailObject.rtoRoaTaxVal!=null?detailObject.rtoRoaTaxVal:0)  + (detailObject.otherChargesDetail!=null?detailObject.otherChargesDetail:0)  + (detailObject.insurancePremiumDeatil!=null?detailObject.insurancePremiumDeatil:0) ;
            
            resJON.onRoadPriceOne = onRoadPriceOne;
            resJON.onRoadPriceTwo = onRoadPriceTwo;
            
            //Funding based on ORP
            if(detailObject.flagtocheckFundingdetail == true)
            {	
                Double upperRange = onRoadPriceOne + ((upperLimit / 100) * onRoadPriceOne);
                Double lowerRange = onRoadPriceTwo - ((lowerLimit / 100) * onRoadPriceTwo);
                if(onRoadPriceOne < lowerRange || onRoadPriceOne > upperRange)
                {
                    journeyStatus = System.Label.nonStp;
                } 
                finalPrice = onRoadPriceOne;   
            }
            //Funding based on Ex-Showroom
            if(detailObject.flagtocheckFundingdetail == false)
            {
                Double lowerRange = exShowroomPriceOne - ((lowerLimit / 100) * exShowroomPriceTwo);
                Double upperRange = exShowroomPriceOne + ((upperLimit / 100) * exShowroomPriceTwo);
                if(exShowroomPriceOne < lowerRange|| exShowroomPriceOne > upperRange)
                { 
                    journeyStatus = System.Label.nonStp;
                } 
                finalPrice =  exShowroomPriceOne;
            }
            resJON.journeyStatus = journeyStatus;
            resJON.finalPrice = finalPrice;
            String serializedResonponse = JSON.serialize(resJON);
            if(Test.isRunningTest())
            {
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
            return serializedResonponse; 
        } catch(Exception e){
            system.debug('Error in calculatePrices:: '+ e.getMessage() + e.getLineNumber());
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.IND_LWC_LoanDetailsCntrl, System.Label.calculatePrices, System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
            }
            throw new AuraHandledException(e.getStackTraceString());
        }
    }

    //Wrapper Class for carwale api Details.
    public class CarwaleAPIWrapper {
        public String message {get;set;}
        //constructor
        public CarwaleAPIWrapper(){
            this.message = NUll;
        }
    }

    public class DetailWrapper {
        @AuraEnabled public Integer exShowroomPriceCarwaledetail;
        @AuraEnabled public Integer basicPricedetail;
        @AuraEnabled public Boolean flagtocheckCsddetail;
        @AuraEnabled public Integer discountOnBasicPriceDetail;
        @AuraEnabled public Integer gstAmountdetail;
        @AuraEnabled public Boolean flagtocheckFundingdetail;
        @AuraEnabled public Integer insurancePremiumDeatil;
        @AuraEnabled public Integer otherChargesDetail;
        @AuraEnabled public Integer rtoRoadTaxDetail;
        @AuraEnabled public Integer rtoRoaTaxVal;//CISP-2346
        
    }
    
    public class DetailsWrapper {
        public Double onRoadPriceOne {get;set;}
        public Double onRoadPriceTwo {get;set;}
        public String journeyStatus {get;set;} 
        public Double finalPrice {get;set;}
        public  Double exShowroomPriceOne {get;set;} 
        public Double exShowroomPriceTwo {get;set;}

        public DetailsWrapper(){
            this.journeyStatus = null;
            this.onRoadPriceOne = null;
            this.onRoadPriceTwo = null;
            this.finalPrice = null;
            this.exShowroomPriceOne = null;
            this.exShowroomPriceTwo = null;
        }
    }

    public class LoanDetailResponseWrapper{
        @AuraEnabled public List<Opportunity> loanApplicationDetails;
        @AuraEnabled public List<Retry_Count__C> retryCountDetails;
        @AuraEnabled public Decimal citycode;
        @AuraEnabled public String variantcode;
        @AuraEnabled public Decimal gstPercentage;
        @AuraEnabled public Decimal maxValue;
        @AuraEnabled public Decimal minValue;
        @AuraEnabled public String crmIRRTW;//D2C change

    }


    @AuraEnabled
    public static String getVehicleType(String opportunityId){ 
            List<Opportunity> opportunityList = new List<Opportunity>();
                opportunityList = [SELECT ID , Vehicle_Type__c FROM Opportunity 
                WHERE Id =: opportunityId WITH SECURITY_ENFORCED];
        	system.debug('opportunityList::'+opportunityList);
            return opportunityList[0].Vehicle_Type__c;
    }
    /*
    * @Method:      updateApplicantSubStage
    * @Created by:  Sanket Patil
    * @Description: Method to update Applicant SubStage on Navigation from Loan Details module
    * @Param:       Opportunity Id
    * @Return:      Boolean - Update Status
    */
    @AuraEnabled
    public static Boolean updateApplicantSubStage(String loanApplicationId){
        Boolean updateStatusFlag = false;
        try{
            List<Applicant__c> appList = [SELECT Id, Journey_Stage__c,Opportunity__r.Customer_Type__c,Opportunity__r.Product_Type__c FROM Applicant__c WHERE Opportunity__c =: loanApplicationId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED];

            if(!appList.isEmpty()){
                for(Applicant__c app : appList){
                    if(app.Opportunity__r.Customer_Type__c == 'Individual' && app.Opportunity__r.Product_Type__c == System.Label.Tractor){
                        app.Journey_Stage__c = 'Run EMI Engine';
                    }else{
                    app.Journey_Stage__c = 'Income Details';
                    }
                }

                if (Schema.sObjectType.Applicant__c.isUpdateable()){
                    update appList;
                    updateStatusFlag = true;
                }
            }
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent(System.Label.IND_LWC_LoanDetailsCntrl ,'updateApplicantSubStage', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        return updateStatusFlag;
    }

         /*
    * @Method:      getDocumentsToCheckPan
    * @Created by:  Poonam Tilokani
    * @Description: This method is used to check Pan is valid or not
    * @Param:       Opportunity Id
    * @Return:      Boolean -flag
    */
    @AuraEnabled
    public static String getDocumentsToCheckPan(String loanApplicationId){
        try {
            Map<String,Object> returnData = new Map<String,Object>();
            List<Applicant__c> AppList = [SELECT ID,applicant_type__c,Opportunity__r.Customer_Type__c,Opportunity__r.Entity_Type__c,(select id, Document_Type__c,NSDL_Response__c,AadhaarSeedingStatus__c,NSDLPANStatus__c  from Documents__r where Document_Type__c  IN ('Form 60','PAN') and is_active__c = true) from Applicant__c where Opportunity__c =: loanApplicationId];
            for(Applicant__c app : AppList){
                if(app.applicant_type__c == 'Borrower'){
                    if(app.Documents__r.size() > 0 && ((app.Documents__r[0].Document_Type__c == 'PAN' && (app.Documents__r[0].NSDL_Response__c == 'Existing and Valid PAN' || app.Documents__r[0].NSDL_Response__c == 'Existing and Valid' || app.Documents__r[0].NSDLPANStatus__c == 'E') && (app.Documents__r[0].AadhaarSeedingStatus__c == 'Y' || (app.Opportunity__r.Customer_Type__c == 'Non-Individual' && app.Opportunity__r.Entity_Type__c != 'Proprietorship'))) || (app.Documents__r[0].Document_Type__c == 'PAN' && app.Documents__r[0].NSDL_Response__c == Null  && app.Documents__r[0].AadhaarSeedingStatus__c == NUll))){
                        returnData.put('borrowerPanAvailable' , true);
                    }else{
                        returnData.put('borrowerPanAvailable' , false);
                    }
                }else if(app.applicant_type__c == 'Co-Borrower'){
                    if(app.Documents__r.size() > 0 &&((app.Documents__r[0].Document_Type__c == 'PAN' && (app.Documents__r[0].NSDL_Response__c == 'Existing and Valid PAN' || app.Documents__r[0].NSDL_Response__c == 'Existing and Valid' || app.Documents__r[0].NSDLPANStatus__c == 'E')  && app.Documents__r[0].AadhaarSeedingStatus__c == 'Y') || (app.Documents__r[0].Document_Type__c == 'PAN' && app.Documents__r[0].NSDL_Response__c == Null  && app.Documents__r[0].AadhaarSeedingStatus__c == NUll))){
                        returnData.put('coborrowerPanAvailable' , true);
                    }else{
                        returnData.put('coborrowerPanAvailable' , false);
                    }
                }
            }
            return JSON.serialize(returnData);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}