/*------------------------------------------------------------
Author: Chaynnitt Agarwal
Description: Controller class for Field Investigation child tables details
@Last Modified By : Chaynnitt Agarwal
@Last Modified On : 19 Oct 2023
@Modification Log : 
============================================================================== 
Ver        Date          Author                  Modification 
============================================================================== 
1.0     19 Oct 2023    Chaynnitt Agarwal        Initial Version 
*/

public without sharing class iND_TF_FI_DetailsController {

     /*
    * @Method:      getStateMaster
    * @Created by:  Chaynnitt Agarwal
    * @Description: This method will return all the list of record
    * @Param:       NIL 
    * @Return:      List<Object>
    */
    @AuraEnabled
    public static List<locationWrapper> getStateMaster(){
        List<locationWrapper> locationLst = new List<locationWrapper>();
        try {
            List<Geo_State_Masters__c> geoStateLst = [SELECT Id, Name FROM Geo_State_Masters__c];
            for(Geo_State_Masters__c state: geoStateLst){
                locationLst.add(new locationWrapper(state.Id,state.Name));
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return locationLst;
    }

    /*
    * @Method:      getDistrictMasterByState
    * @Created by:  Chaynnitt Agarwal
    * @Description: This method will return all the list of record
    * @Param:       Geo State Master Id
    * @Return:      List<Object>
    */
    @AuraEnabled
    public static List<locationWrapper> getDistrictMasterByState(String stateId){
        List<locationWrapper> locationLst = new List<locationWrapper>();
        try {
            System.debug('STATE ID >>> '+stateId);
            List<District_Master__c> districtLst = [SELECT Id, Name FROM District_Master__c WHERE Geo_State_Master__c =: stateId];
            for(District_Master__c district: districtLst){
                locationLst.add(new locationWrapper(district.Id,district.Name));
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return locationLst;
    }

    /*
    * @Method:      getDistrictMasterByPOA
    * @Created by:  Chaynnitt Agarwal
    * @Description: This method will return all the list of disctrict record based on POA
    * @Param:       fieldInvestigationId,fetchState
    * @Return:      List<Object>
    */
    @AuraEnabled(cacheable=true)
    public static List<locationWrapper> getDistrictMasterByPOA(String fieldInvestigationId,Boolean fetchState){
        try {
            Id loanId = null;
            Id applicantId = null;
            Field_Investigation__c fiRecord = [SELECT Id, Case__r.Loan_Application__c,Case__r.Applicant__c FROM Field_Investigation__c WHERE Id =:fieldInvestigationId];
            loanId = fiRecord != null ? fiRecord.Case__r.Loan_Application__c : null;
            applicantId = fiRecord != null ? fiRecord.Case__r.Applicant__c : null;
            List<Documents__c> docList = new List<Documents__c>();
            List<Geo_State_Masters__c> stateList = new List<Geo_State_Masters__c>();
            if(loanId != null && applicantId != null){
                docList.addAll([SELECT Id, KYC_State__c FROM Documents__c WHERE Proof_of_Address_POA__c = TRUE AND Applicant__c =: applicantId AND Opportunity_Relation__c =:loanId]);
                if(docList.size() > 0){
                    stateList.addAll([SELECT Id, Name FROM Geo_State_Masters__c WHERE Name =: docList[0].KYC_State__c]);
                }            }
            String stateId = '';
            if(stateList.size()>0){
                stateId = stateList[0].Id;
            }
            if(stateList.size() > 0 && fetchState == true){
                List<locationWrapper> locationLst = new List<locationWrapper>();
                locationLst.add(new locationWrapper(stateList[0].Id,stateList[0].Name));
                return locationLst;
            }else{
                return getDistrictMasterByState(stateId);
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
    * @Method:      getSubSchemeValue
    * @Created by:  Chaynnitt Agarwal
    * @Description: This method will return the sub scheme type value available on the FI.
    * @Param:       fieldInvestigationId
    * @Return:      List<Object>
    */
    @AuraEnabled
    public static String getSubSchemeValue(String fieldInvestigationId){
        try {
            List<Field_Investigation__c> fieldInvLst = [SELECT Id,Sub_Scheme_Type__c 
                                                            FROM Field_Investigation__c
                                                            WHERE Id =:fieldInvestigationId
                                                           ];
            return fieldInvLst[0].Sub_Scheme_Type__c;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
    * @Method:      getAllDistrict
    * @Created by:  Chaynnitt Agarwal
    * @Description: This method will return all the list of record
    * @Param:       Geo State Master Id
    * @Return:      List<Object>
    */
    @AuraEnabled(cacheable=true)
    public static List<locationWrapper> getAllDistrict(){
        List<locationWrapper> locationLst = new List<locationWrapper>();
        try {
            List<District_Master__c> districtLst = [SELECT Id, Name FROM District_Master__c];
            for(District_Master__c district: districtLst){
                locationLst.add(new locationWrapper(district.Id,district.Name));
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return locationLst;
    }

    /*
    * @Method:      fetchCropMaster
    * @Created by:  Chaynnitt Agarwal
    * @Description: This method will return all the list of Crop master based on the district
    * @Param:       districtState Name
    * @Return:      List<Object>
    */
    @AuraEnabled
    public static List<CropMasterWrapper> fetchCropMaster(String districtName){
        List<CropMasterWrapper> cropMasterLst = new List<CropMasterWrapper>();
        try {
            List<Crop_Master__c> cropLst = [SELECT Id, Name, Market_Price_Rs_Per_Quintal__c, Yield_Quintal_Per_Acre__c FROM Crop_Master__c WHERE Location__c =: districtName];
            for(Crop_Master__c crop: cropLst){
                cropMasterLst.add(new CropMasterWrapper(crop.Id, crop.Name, crop.Yield_Quintal_Per_Acre__c, crop.Market_Price_Rs_Per_Quintal__c));
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return cropMasterLst;
    }

    public class CropMasterWrapper{
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public Decimal Yield_Acre {get;set;}
        @AuraEnabled
        public Decimal Sold_Price {get;set;}

        public CropMasterWrapper(String id, String name, Decimal yield, Decimal soldprice){
            this.id = id;
            this.name = name;
            this.Yield_Acre = yield;
            this.Sold_Price = soldprice;
        }
    }

    /*
    * @Method:      getCropInformation
    * @Created by:  Chaynnitt Agarwal
    * @Description: This method will get record of Crop Detail
    * @Param:       Field Investigation Id, Cultivation Year
    * @Return:      List<CropDetailWrapper>
    */
    @AuraEnabled(cacheable = true)
    public static List<CropDetailWrapper> getCropInformation(String fieldInvestigationId, String year){
        List<CropDetailWrapper> cropInfoWrapperLst = new List<CropDetailWrapper>();
        try {
            //Select id,Crop_Cultivated_Year__c, Crop_Grown_in_acre__c, Crop_Type__c, Net_Income__c, Field_Investigation__c, Crop_Master__r.Name, Crop_Master__r.Location__c, Crop_Master__r.Yield_Acre__c, Crop_Master__r.Sold_Price__c from Crop_Detail__c 
            List<Crop_Detail__c> cropDetailLst = [SELECT Id, Crop_Grown_in_acre__c, Crop_Type__c, Net_Income__c, Crop_Master__r.Name, Crop_Master__r.Location__c, Crop_Master__r.Yield_Quintal_Per_Acre__c, Crop_Master__r.Market_Price_Rs_Per_Quintal__c, Land_Survey_No__c
                                                    FROM Crop_Detail__c 
                                                    WHERE Crop_Cultivated_Year__c =: year AND Field_Investigation__c =: fieldInvestigationId
                                                   ];
            for(Crop_Detail__c crop: cropDetailLst){
                cropInfoWrapperLst.add(new CropDetailWrapper(crop));
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return cropInfoWrapperLst;
    }

    /*
    * @Method:      saveCropInformation
    * @Created by:  Chaynnitt Agarwal
    * @Description: This method will save record of Crop Detail
    * @Param:       Crop Detail List, Field Investigation Id, Cultivation Year
    * @Return:      Null
    */
    @AuraEnabled
    public static void saveCropInformation(List<CropDetailWrapper> cropDetails, String fieldInvestigationId, String year){
        try {
            List<Crop_Detail__c> cropDetailLst = new List<Crop_Detail__c>();
            for(CropDetailWrapper obj: cropDetails){
                Crop_Detail__c crop = new Crop_Detail__c();
                if(obj.isDatabase == false && obj.isValid == true){
                    crop.Crop_Cultivated_Year__c = year;
                    crop.Crop_Grown_in_acre__c = Decimal.valueOf(obj.Crop_Grown_in_acre);
                    crop.Crop_Master__c = obj.Crop_Master;
                    crop.Crop_Type__c = obj.Crop_Type;
                    crop.Field_Investigation__c = fieldInvestigationId;
                    crop.Net_Income__c = Decimal.valueOf(obj.Net_Income);
                    crop.Land_Survey_No__c = obj.Land_Survey_No;
                    if (obj.id != null && obj.id.length() == 18) { //SFTRAC-614 checking Id length and passing Id
                        crop.Id = obj.id;
                    }
                    cropDetailLst.add(crop);
                }
            }
            if(cropDetailLst.size()>0){
                //insert cropDetailLst;  //SFTRAC-614 removed
                upsert cropDetailLst;    //SFTRAC-614 added upsert
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class CropDetailWrapper{
        @AuraEnabled
        public Boolean isValid {get;set;}
        @AuraEnabled
        public Boolean isDatabase {get;set;}
        @AuraEnabled
        public String District_Master {get;set;}
        @AuraEnabled
        public String District_Master_Value {get;set;}
        @AuraEnabled
        public String Crop_Type {get;set;}
        @AuraEnabled
        public String Crop_Grown_in_acre {get;set;}
        @AuraEnabled
        public String Net_Income {get;set;}
        @AuraEnabled
        public String Crop_Master {get;set;}
        @AuraEnabled
        public String Crop_Master_Value {get;set;}
        @AuraEnabled
        public String Yield_Acre {get;set;}
        @AuraEnabled
        public String Sold_Price {get;set;}
        @AuraEnabled
        public String Land_Survey_No {get;set;}
        @AuraEnabled
        public String id {get;set;}

        public CropDetailWrapper(Crop_Detail__c crop){
            this.id = crop.Id;
            this.isValid = true;
            this.isDatabase = true;
            this.District_Master_Value = crop.Crop_Master__r.Location__c;
            this.Crop_Type = crop.Crop_Type__c;
            this.Crop_Grown_in_acre = String.valueOf(crop.Crop_Grown_in_acre__c);
            this.Net_Income = String.valueOf(crop.Net_Income__c);
            this.Crop_Master_Value = crop.Crop_Master__r.Name;
            this.Yield_Acre = String.valueOf(crop.Crop_Master__r.Yield_Quintal_Per_Acre__c);
            this.Sold_Price = String.valueOf(crop.Crop_Master__r.Market_Price_Rs_Per_Quintal__c);
            this.Land_Survey_No = String.valueOf(crop.Land_Survey_No__c);
        }

        public CropDetailWrapper(){
            //To do
        }
    }

    /*
    * @Method:      fetchCategoryMaster
    * @Created by:  Chaynnitt Agarwal
    * @Description: This method will return all the list of record
    * @Param:       Geo State Master Name and District Master Name
    * @Return:      List<Object>
    */
    @AuraEnabled(cacheable=true)
    public static List<CategoryMasterWrapper> fetchCategoryMaster(){
        List<CategoryMasterWrapper> categoryWrapperLst = new List<CategoryMasterWrapper>();
        try {
            List<Category_Master__c> categoryLst = [SELECT Id, Category__c, Sub_category__c, Income__c FROM Category_Master__c];
            for(Category_Master__c category: categoryLst){
                categoryWrapperLst.add(new CategoryMasterWrapper(category.Id,category.Category__c,category.Sub_category__c,category.Income__c));
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return categoryWrapperLst;
    }
    @AuraEnabled(cacheable=true)
    public static List<SubcategoryWrapper> fetchSubcategoriesByCategory(String selectedCategory) {
        List<SubcategoryWrapper> subcategories = new List<SubcategoryWrapper>();

        try {
            List<Category_Master__c> categoryList = [SELECT Id, Category__c, Sub_category__c,Income__c FROM Category_Master__c
                                                    WHERE Category__c = :selectedCategory
            ];

            for (Category_Master__c category : categoryList) {
                subcategories.add(new SubcategoryWrapper(category.Id,category.Sub_category__c,category.Income__c));
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
        return subcategories;
    }

    public class SubcategoryWrapper {
        @AuraEnabled public String subcategoryId { get; set; }
        @AuraEnabled public String subcategoryName { get; set; }
        @AuraEnabled public Decimal income {get;set;}
        
        public SubcategoryWrapper(String id, String name,Decimal income) {
            this.subcategoryId = id;
            this.subcategoryName = name;
            this.income = income;
        }
    }

    public class CategoryMasterWrapper{
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public String category {get;set;}
        @AuraEnabled
        public String sub_category {get;set;}
        @AuraEnabled
        public Decimal income {get;set;}

        public CategoryMasterWrapper(String id, String category, String subcategory, Decimal income){
            this.id = id;
            this.category = category;
            this.sub_category = subcategory;
            this.income = income;
        }
    }

    /*
    * @Method:      saveNonAgriIncomeInformation
    * @Created by:  Chaynnitt Agarwal
    * @Description: This method will save all the list of record of type Non Agri Income object
    * @Param:       Geo State Master Name and District Master Name
    * @Return:      List<Object>
    */
    @AuraEnabled
    public static void saveNonAgriIncomeInformation(List<NonAgriIncomeWrapper> nonAgriLst, String fieldInvestigationRecordId){
        try{
            List<Non_Agri_Income__c> nonAgriIncomeLst = new List<Non_Agri_Income__c>();
            for(NonAgriIncomeWrapper obj : nonAgriLst){
                Non_Agri_Income__c nonAgri = new Non_Agri_Income__c();
                if(obj.isvalid == true && obj.isDatabase == false){
                    nonAgri.Field_Investigation__c = fieldInvestigationRecordId;
                    //nonAgri.Category_Master__c = obj.Category;
                    nonAgri.Category_Master__c = obj.Sub_Category;
                    nonAgri.Total_Income__c = Decimal.valueOf(obj.Total_Income);
                    nonAgri.Utilization__c = obj.Utilization;
                    if (obj.id != null && obj.id.length() == 18) { //SFTRAC-614 checking Id length and passing Id
                        nonAgri.Id = obj.id;
                    }
                    nonAgriIncomeLst.add(nonAgri);
                }
            }

            if(nonAgriIncomeLst.size()>0){
                //insert nonAgriIncomeLst;  //SFTRAC-614 removed
                upsert nonAgriIncomeLst;    //SFTRAC-614 added upsert
            }
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<NonAgriIncomeWrapper> fetchNonAgriInfo(String fieldInvestigationRecordId){
        List<NonAgriIncomeWrapper> nonAgriWrapperLst = new List<NonAgriIncomeWrapper>();
        try{
            List<Non_Agri_Income__c> nonAgriLst = [SELECT Id,Utilization__c, Total_Income__c, Category_Master__c, Category_Master__r.Category__c, Category_Master__r.Sub_category__c, Category_Master__r.Income__c
                                                    FROM Non_Agri_Income__c 
                                                    WHERE Field_Investigation__c =: fieldInvestigationRecordId
                                                   ];
            for(Non_Agri_Income__c obj: nonAgriLst){
                nonAgriWrapperLst.add(new NonAgriIncomeWrapper(obj));
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }

        return nonAgriWrapperLst;
    }

    public class NonAgriIncomeWrapper{
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public Boolean isValid {get;set;}
        @AuraEnabled
        public Boolean isDatabase {get;set;}
        @AuraEnabled
        public String Category {get;set;}
        @AuraEnabled
        public String Category_Value {get;set;}
        @AuraEnabled
        public String Sub_Category {get;set;}
        @AuraEnabled
        public String Sub_categoryLabel {get;set;}
        @AuraEnabled
        public String Income {get;set;}
        @AuraEnabled
        public String Utilization {get;set;}
        @AuraEnabled
        public String Total_Income {get;set;}

        public NonAgriIncomeWrapper(){
            //Default constructor
        }

        public NonAgriIncomeWrapper(Non_Agri_Income__c obj){
            this.id = obj.Id;
            this.Utilization = obj.Utilization__c;
            this.Total_Income = String.valueOf(obj.Total_Income__c);
            this.isValid = true;
            this.isDatabase = true;
            this.Category = obj.Category_Master__c;
            this.Category_Value = obj.Category_Master__r.Category__c;
            this.Sub_Category = obj.Category_Master__c;
            this.Sub_categoryLabel = obj.Category_Master__r.Sub_category__c;
            this.Income = String.valueOf(obj.Category_Master__r.Income__c);
        }

    }


    /*
    * @Method:      getTaluqaMaster
    * @Created by:  Chaynnitt Agarwal
    * @Description: This method will return all the list of record
    * @Param:       Geo State Master Name and District Master Name
    * @Return:      List<Object>
    */
    @AuraEnabled
    public static List<locationWrapper> getTaluqaMaster(String stateName, String districtName){
        List<locationWrapper> locationLst = new List<locationWrapper>();
        try {
            List<Taluka_Master__c> taluqaLst = [SELECT Id, Name, Per_Acre_Cost__c FROM Taluka_Master__c WHERE State__c =: stateName AND District__c =: districtName];
            for(Taluka_Master__c taluqa: taluqaLst){
                locationLst.add(new locationWrapper(taluqa.Id,taluqa.Name,taluqa.Per_Acre_Cost__c));
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return locationLst;
    }

    public class locationWrapper{
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public Decimal perAcreCost {get;set;}
        public locationWrapper(String id, String name){
            this.id = id;
            this.name = name;
        }
        public locationWrapper(String id, String name, Decimal perAcreCost){
            this.id = id;
            this.name = name;
            this.perAcreCost = perAcreCost;
        }
    }
	/*
    * @Method:      saveKCCAndOtherLoanDetails
    * @Created by:  Shivswaroop Chougule
    * @Description: This method will save all the KCC And Other loan Details record
    * @Param:       Object KccAndOtherLoanInformationWrapper list & Field Investigation Id
    * @Return:      Void
    */
    @AuraEnabled
    public static void saveKCCAndOtherLoanDetails(List<KccAndOtherLoanInformationWrapper> kccAndOtherLoanLst, String fieldInvestigationId){
        System.debug('>>> Input received for saving is :: \n'+JSON.serializePretty(kccAndOtherLoanLst));
        try{
            List<KCC_And_Other_Loan_Information__c> kccAndOtherLoanDetailLst = new List<KCC_And_Other_Loan_Information__c>();
            for(KccAndOtherLoanInformationWrapper obj : kccAndOtherLoanLst){
                if(obj.isValid == true && obj.isDatabase == false){
                    KCC_And_Other_Loan_Information__c kccLoanInfo = new KCC_And_Other_Loan_Information__c();
                    kccLoanInfo.Loan_Type__c = obj.Loan_Type;
                    kccLoanInfo.BANK_NAME__c = obj.BANK_NAME;
                    kccLoanInfo.EMI_Amount__c = obj.EMI_Amount;
                    kccLoanInfo.Loan_number__c = obj.Loan_number;
                    kccLoanInfo.Field_Investigation__c = fieldInvestigationId;
                    kccLoanInfo.LOAN_AMOUNT__c = Decimal.valueof(obj.LOAN_AMOUNT);
                    kccLoanInfo.Loan_Stakeholders__c = obj.Loan_Stakeholders;
                    kccLoanInfo.Loan_Start_Date__c = Date.valueOf(obj.Loan_Start_Date);
                    kccLoanInfo.Total_Remarks_by_FI_Agent__c = obj.Total_Remarks_by_FI_Agent;
                    kccLoanInfo.Last_EMI_Paid_Date__c = Date.valueOf(obj.Last_EMI_Paid_Date);
                    kccLoanInfo.Model_Details__c = obj.Model_Details;
                    //kccLoanInfo.Sr_No__c = obj.id;
                    if (obj.id != null && obj.id.length() == 18) { //SFTRAC-614 checking Id length and passing Id
                        kccLoanInfo.Id = obj.id;
                    }else{
                    kccLoanInfo.Sr_No__c = obj.id;
                    }
                    kccAndOtherLoanDetailLst.add(kccLoanInfo);
                }
            }
            if(!kccAndOtherLoanDetailLst.isEmpty()){
                upsert kccAndOtherLoanDetailLst;
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    /*
    * @Method:      getKCCOtherLoanInformationRecords
    * @Created by:  Shivswaroop Chougule
    * @Description: This method will get KCC and Other Loan information records
    * @Param:       fieldInvestigationId
    * @Return:      List<KccAndOtherLoanInformationWrapper>
    */
    @AuraEnabled(cacheable = true)
    public static List<KccAndOtherLoanInformationWrapper> getKCCOtherLoanInformationRecords(String fieldInvestigationId){
        System.debug('getKCC fieldInvestigationId '+fieldInvestigationId);
        list<KccAndOtherLoanInformationWrapper> kccWrapperList = new list<KccAndOtherLoanInformationWrapper>();
        List<Field_Investigation__c> fi_List = [SELECT Id,Total_KCC_Loan_Stakeholders__c,Total_HL_CAR_PL_TW_Loan__c,(SELECT Id,Sr_No__c, BANK_NAME__c,EMI_Amount__c,Field_Investigation__c,Last_EMI_Paid_Date__c,LOAN_AMOUNT__c,Loan_number__c,Loan_Stakeholders__c, Loan_Start_Date__c, Loan_Type__c, Model_Details__c, Total_KCC_Loan_Stakeholders__c,Total_Remarks_by_FI_Agent__c 
                                                           FROM KCC_And_Other_Loan_Informations__r) 
                                                FROM Field_Investigation__c 
                                                WHERE Id=:fieldInvestigationId] ;
        System.debug('getKCC fieldInvestigationId '+(!fi_List.isEmpty() && !fi_List[0].KCC_And_Other_Loan_Informations__r.isEmpty()));
        if(!fi_List.isEmpty() && !fi_List[0].KCC_And_Other_Loan_Informations__r.isEmpty()){
            for(KCC_And_Other_Loan_Information__c kccOtherLoanInformation :fi_List[0].KCC_And_Other_Loan_Informations__r){
                KccAndOtherLoanInformationWrapper wrapperObj = new KccAndOtherLoanInformationWrapper();
                wrapperObj.isValid = true;
                wrapperObj.isDatabase = true;
                wrapperObj.Loan_Type = kccOtherLoanInformation.Loan_Type__c;
                wrapperObj.Loan_Stakeholders = kccOtherLoanInformation.Loan_Stakeholders__c;
                wrapperObj.Loan_number = kccOtherLoanInformation.Loan_number__c;
                wrapperObj.LOAN_AMOUNT = String.valueOf(kccOtherLoanInformation.LOAN_AMOUNT__c);
                wrapperObj.BANK_NAME = kccOtherLoanInformation.BANK_NAME__c;
                wrapperObj.Loan_Start_Date = String.valueOf(kccOtherLoanInformation.Loan_Start_Date__c);
                wrapperObj.EMI_Amount = kccOtherLoanInformation.EMI_Amount__c;
                wrapperObj.Last_EMI_Paid_Date = String.valueOf(kccOtherLoanInformation.Last_EMI_Paid_Date__c);
                wrapperObj.Total_Remarks_by_FI_Agent = kccOtherLoanInformation.Total_Remarks_by_FI_Agent__c;
                wrapperObj.Model_Details = kccOtherLoanInformation.Model_Details__c;
                wrapperObj.sumOfAllLoanTypeKCC = String.valueOf(fi_List[0].Total_KCC_Loan_Stakeholders__c) ;
                wrapperObj.sumOfAllLoanTypeNonKCC = String.valueOf(fi_List[0]. Total_HL_CAR_PL_TW_Loan__c) ;
                wrapperObj.id = kccOtherLoanInformation.Id;
                wrapperObj.modalDetailsRequired = false; 
                kccWrapperList.add(wrapperObj);
            }
            return kccWrapperList;
        }
        return null;
    }
    public class KccAndOtherLoanInformationWrapper{
        @AuraEnabled public boolean isValid{get;set;}
        @AuraEnabled public boolean isDatabase{get;set;}
        @AuraEnabled public string Loan_Type{get;set;}
        @AuraEnabled public string Loan_Stakeholders{get;set;}
        @AuraEnabled public string Loan_number{get;set;}
        @AuraEnabled public string LOAN_AMOUNT{get;set;}
        @AuraEnabled public string BANK_NAME{get;set;}
        @AuraEnabled public string Loan_Start_Date{get;set;}
        @AuraEnabled public string EMI_Amount{get;set;}
        @AuraEnabled public string Last_EMI_Paid_Date{get;set;}
        @AuraEnabled public string Total_Remarks_by_FI_Agent{get;set;}
        @AuraEnabled public string Model_Details{get;set;}
        @AuraEnabled public string sumOfAllLoanTypeKCC{get;set;}
        @AuraEnabled public string sumOfAllLoanTypeNonKCC{get;set;}
        @AuraEnabled public string id{get;set;}
        @AuraEnabled public Boolean modalDetailsRequired{get;set;}
    }
    /*
    * @Method:      saveExistingLoanDetails
    * @Created by:  Shivswaroop Chougule
    * @Description: This method will save all the Existing Tractor Loan Information record
    * @Param:       Object existingTractorLoanInformationWrapper list & Field Investigation Id
    * @Return:      Void
    */
    @AuraEnabled
    public static void saveExistingLoanDetails(List<existingTractorLoanInformationWrapper> existingTractorLoanLst, String fieldInvestigationId){
        System.debug('>>> Input received for saving is :: \n'+existingTractorLoanLst[0]);
        try{
            List<Existing_Tractor_Loan_Information__c> existingTractorLoanDetailLst = new List<Existing_Tractor_Loan_Information__c>();
            for(existingTractorLoanInformationWrapper obj : existingTractorLoanLst){
                if(obj.isValid == true && obj.isDatabase == false){
                    Existing_Tractor_Loan_Information__c existingTractorLoan = new Existing_Tractor_Loan_Information__c();
                    existingTractorLoan.BANK_NAME__c = obj.BANK_NAME;
                    existingTractorLoan.EMI_Amount__c = obj.EMI_Amount;
                    existingTractorLoan.Field_Investigation__c = fieldInvestigationId;
                    existingTractorLoan.Last_EMI_Paid_Date__c = obj.Last_EMI_Paid_Date != null ?  Date.valueOf(obj.Last_EMI_Paid_Date) : null;
                    existingTractorLoan.LOAN_AMOUNT__c = obj.LOAN_AMOUNT != null ?  Decimal.valueof(obj.LOAN_AMOUNT) : 0;
                    existingTractorLoan.Loan_Free__c = obj.Loan_Free;
                    existingTractorLoan.Loan_number__c = obj.Loan_number;
                    existingTractorLoan.Loan_Stakeholders__c = obj.Loan_Stakeholders;
                    existingTractorLoan.Loan_Start_Date__c = obj.Loan_Start_Date != null ? Date.valueOf(obj.Loan_Start_Date) : null;
                    existingTractorLoan.Loan_Type__c = obj.Loan_Type;
                    existingTractorLoan.Model_Details__c = obj.Model_Details;
                    existingTractorLoan.Total_Remarks_by_FI_Agent__c = obj.Total_Remarks_by_FI_Agent;
                    //existingTractorLoan.Sr_No__c = obj.id;
                    if (obj.id != null && obj.id.length() == 18) { //SFTRAC-614 checking Id length and passing Id
                        existingTractorLoan.Id = obj.id;
                    }else{
                    existingTractorLoan.Sr_No__c = obj.id;
                    }
                    existingTractorLoanDetailLst.add(existingTractorLoan);
                }
            }
            if(!existingTractorLoanDetailLst.isEmpty()){
                //insert existingTractorLoanDetailLst;  //SFTRAC-614 removed
                upsert existingTractorLoanDetailLst;    //SFTRAC-614 added upsert
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    /*
    * @Method:      getExistingLoanDetails
    * @Created by:  Shivswaroop Chougule
    * @Description: This method will get Existing Tractor Loan Information records
    * @Param:       loanApplicationId
    * @Return:      List<existingTractorLoanInformationWrapper>
    */
    @AuraEnabled(cacheable = true)
    public static List<existingTractorLoanInformationWrapper> getExistingLoanDetails(String fieldInvestigationId){
        list<existingTractorLoanInformationWrapper> existingTractorLoanWrapperList = new list<existingTractorLoanInformationWrapper>();
        List<Field_Investigation__c> fi_List = [SELECT Id,Total_Tractor_Loan_Family__c ,Total_Tractor_Loan_Stakeholders__c ,(SELECT Id, BANK_NAME__c,Sr_No__c,EMI_Amount__c,Field_Investigation__c,Last_EMI_Paid_Date__c,LOAN_AMOUNT__c,Loan_number__c,Loan_Stakeholders__c, Loan_Start_Date__c, Loan_Type__c, Model_Details__c, Loan_Free__c,Total_Remarks_by_FI_Agent__c 
                                                           FROM Existing_Tractor_Loan_Informations__r) 
                                                FROM Field_Investigation__c 
                                                WHERE Id=:fieldInvestigationId] ;
        if(!fi_List.isEmpty() && !fi_List[0].Existing_Tractor_Loan_Informations__r.isEmpty()){
            for(Existing_Tractor_Loan_Information__c existingTractorLoan :fi_List[0].Existing_Tractor_Loan_Informations__r ){
                existingTractorLoanInformationWrapper existingTractorLoanObj = new existingTractorLoanInformationWrapper();
                existingTractorLoanObj.isValid = true;
                existingTractorLoanObj.isDatabase = true;
                existingTractorLoanObj.Loan_Type = existingTractorLoan.Loan_Type__c;
                existingTractorLoanObj.Loan_Stakeholders = existingTractorLoan.Loan_Stakeholders__c;
                existingTractorLoanObj.Loan_number = existingTractorLoan.Loan_number__c;
                existingTractorLoanObj.LOAN_AMOUNT = string.valueOf(existingTractorLoan.LOAN_AMOUNT__c);
                existingTractorLoanObj.BANK_NAME = existingTractorLoan.BANK_NAME__c;
                existingTractorLoanObj.Loan_Start_Date = String.valueOf(existingTractorLoan.Loan_Start_Date__c);
                existingTractorLoanObj.EMI_Amount = existingTractorLoan.EMI_Amount__c;
                existingTractorLoanObj.Model_Details = existingTractorLoan.Model_Details__c;
                existingTractorLoanObj.Loan_Free = existingTractorLoan.Loan_Free__c;
                existingTractorLoanObj.Last_EMI_Paid_Date = String.valueOf(existingTractorLoan.Last_EMI_Paid_Date__c);
                existingTractorLoanObj.Total_Remarks_by_FI_Agent = existingTractorLoan.Total_Remarks_by_FI_Agent__c;
                existingTractorLoanObj.totalTractorLoanStakeholders = String.valueOf(fi_List[0].Total_Tractor_Loan_Stakeholders__c);
                existingTractorLoanObj.totalTractorLoanFamily = String.valueOf(fi_List[0].Total_Tractor_Loan_Family__c);
                existingTractorLoanObj.id = existingTractorLoan.Id;
                existingTractorLoanObj.disableFields = false;
                existingTractorLoanWrapperList.add(existingTractorLoanObj);
            }
            return existingTractorLoanWrapperList;
        }
        return null;
    }
    public class existingTractorLoanInformationWrapper{
        @AuraEnabled public boolean isValid{get;set;}
        @AuraEnabled public boolean isDatabase{get;set;}
        @AuraEnabled public string Loan_Type{get;set;}
        @AuraEnabled public string id{get;set;}
        @AuraEnabled public string Loan_Stakeholders{get;set;}
        @AuraEnabled public string Loan_number{get;set;}
        @AuraEnabled public string LOAN_AMOUNT{get;set;}
        @AuraEnabled public string BANK_NAME{get;set;}
        @AuraEnabled public string Loan_Start_Date{get;set;}
        @AuraEnabled public string EMI_Amount{get;set;}
        @AuraEnabled public string Model_Details{get;set;}
        @AuraEnabled public string Loan_Free{get;set;}
        @AuraEnabled public string Last_EMI_Paid_Date{get;set;}
        @AuraEnabled public string Total_Remarks_by_FI_Agent{get;set;}
        @AuraEnabled public string totalTractorLoanStakeholders{get;set;}
        @AuraEnabled public string totalTractorLoanFamily {get;set;}
        @AuraEnabled public Boolean disableFields {get;set;}
    }
    /*
    * @Method:      saveViabilityExistingTractorDetails
    * @Created by:  Shivswaroop Chougule
    * @Description: This method will save all the Existing Tractor Loan Information record
    * @Param:       Object saveViabilityExistingTractorInformationWrapper list & Field Investigation Id
    * @Return:      Void
    */
    @AuraEnabled
    public static void saveViabilityExistingTractorDetails(List<saveViabilityExistingTractorInformationWrapper> viabilityOfExistingTractorLst, String fieldInvestigationId){
        try{
            List<Viability_of_Existing_Proposed_Tractor__c> viabilityOfExistingTractorDetailLst = new List<Viability_of_Existing_Proposed_Tractor__c>();
            for(saveViabilityExistingTractorInformationWrapper obj : viabilityOfExistingTractorLst){
                if(obj.isValid == true && obj.isDatabase == false){
                    Viability_of_Existing_Proposed_Tractor__c vibilityOfExistingTractor = new Viability_of_Existing_Proposed_Tractor__c();
                    vibilityOfExistingTractor.Usage_Type__c = obj.Usage_Type;
                    vibilityOfExistingTractor.Diesal_counsumption_hr__c = obj.Diesal_counsumption_hr != null ? Decimal.valueOf(obj.Diesal_counsumption_hr) : 0;
                    vibilityOfExistingTractor.Diesal_Rate_Hr__c = obj.Diesal_Rate_Hr != null ? Decimal.valueOf(obj.Diesal_Rate_Hr) : 0;
                    vibilityOfExistingTractor.Existing_Proposed__c = obj.Existing_Proposed;
                    vibilityOfExistingTractor.Expenses__c = obj.Expenses != null ? Decimal.valueOf(obj.Expenses): 0;
                    vibilityOfExistingTractor.Field_Investigation__c = fieldInvestigationId;
                    vibilityOfExistingTractor.Net_Income__c = obj.Net_Income != null ? Decimal.valueOf(obj.Net_Income) : 0;
                    vibilityOfExistingTractor.Nos_of_Hours_run_in_year__c = obj.Nos_of_Hours_run_in_year != null ? Decimal.valueOf(obj.Nos_of_Hours_run_in_year) : 0;
                    vibilityOfExistingTractor.Per_Hour_Rate__c = obj.Per_Hour_Rate != null ? Decimal.valueOf(obj.Per_Hour_Rate) : 0;
                    vibilityOfExistingTractor.Total_Income__c = obj.Total_Income != null ? Decimal.valueOf(obj.Total_Income) : 0;
                    vibilityOfExistingTractor.Tractor_Harvester__c = obj.Tractor_Harvester;
                    if (obj.id != null && obj.id.length() == 18) { //SFTRAC-614 checking Id length and passing Id
                        vibilityOfExistingTractor.Id = obj.id;
                    }else{
                    vibilityOfExistingTractor.Sr_No__c = obj.id;
                    }
                    viabilityOfExistingTractorDetailLst.add(vibilityOfExistingTractor);
                }  
            }
            if(!viabilityOfExistingTractorDetailLst.isEmpty()){
                //insert viabilityOfExistingTractorDetailLst;  //SFTRAC-614 removed
                upsert viabilityOfExistingTractorDetailLst;    //SFTRAC-614 added upsert                    
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    /*
    * @Method:      getViabilityExistingTractorInformation
    * @Created by:  Shivswaroop Chougule
    * @Description: This method will get Viability Existing Tractor Information records
    * @Param:       loanApplicationId
    * @Return:      List<saveViabilityExistingTractorInformationWrapper>
    */
    @AuraEnabled(cacheable = true)
    public static List<saveViabilityExistingTractorInformationWrapper> getViabilityExistingTractorInformation(String fieldInvestigationId){
        list<saveViabilityExistingTractorInformationWrapper> viabilityExistingTractorInformationList = new list<saveViabilityExistingTractorInformationWrapper>();
        List<Field_Investigation__c> fi_List = [SELECT Id,Total_Agri_Expenses_for_Existing_Harvest__c, 
												Total_Agri_Expenses_for_Proposed_Harvest__c, 
												Total_Agri_Expenses_for_Existing_Tractor__c, 
												Total_Agri_Expenses_for_Proposed_Tractor__c, 
												Total_Agri_Income_for_Existing_Harvester__c, 
                                                Total_Agri_Income_for_Proposed_Harvester__c, 
                                                Total_Agri_Income_for_Existing_Tractor__c, 
                                                Total_Agri_Income_for_Proposed_Tractor__c, 
                                                Total_Agri_Net_Income_for_Existing_Harve__c, 
                                                Total_Agri_Net_Income_for_Proposed_Harve__c,
                                                Total_Agri_Net_Income_for_Existing_Tract__c, 
                                                Total_Agri_Net_Income_for_Proposed_Tract__c, 
                                                Total_Agri_Comm_Expenses_Exist_Harvest__c, 
                                                Total_Agri_Comm_Expen_Proposed_Harvest__c, 
                                                Total_Agri_Comm_Expense_Existing_Tractor__c, 
                                                Total_Agri_Comm_Expense_Proposed_Tractor__c, 
                                                Total_Agri_Comm_Income_Existing_Harvest__c, 
                                                Total_Agri_Comm_Income_Proposed_Harvest__c, 
                                                Total_Agri_Comm_Income_Existing_Tractor__c, 
                                                Total_Agri_Comm_Income_Proposed_Tractor__c, 
                                                Total_Agri_Com_NetIncome_Existing_Harves__c, 
                                                Total_Agri_Com_NetIncome_Proposed_Harves__c, 
                                                Total_Agri_Comm_NetIncome_Existing_Tract__c, 
												Total_Agri_Com_NetIncome_Proposed_Tract__c ,
                                                (SELECT Id,Sr_No__c,Usage_Type__c,Diesal_counsumption_hr__c,Diesal_Rate_Hr__c,Existing_Proposed__c,
                                                 Expenses__c,Field_Investigation__c,Net_Income__c,Nos_of_Hours_run_in_year__c,Per_Hour_Rate__c,
                                                 Total_Income__c,Tractor_Harvester__c
                                                 FROM Viability_of_Existing_Proposed_Tractors__r) 
                                                FROM Field_Investigation__c 
                                                WHERE Id=:fieldInvestigationId] ;
        if(!fi_List.isEmpty() && !fi_List[0].Viability_of_Existing_Proposed_Tractors__r.isEmpty()){
            for(Viability_of_Existing_Proposed_Tractor__c viabilityObj : fi_List[0].Viability_of_Existing_Proposed_Tractors__r){
                saveViabilityExistingTractorInformationWrapper viabilityWrapper = new saveViabilityExistingTractorInformationWrapper();
                viabilityWrapper.isValid 									= true;
                viabilityWrapper.isDatabase 								= true;
                viabilityWrapper.Usage_Type									= viabilityObj.Usage_Type__c;
                viabilityWrapper.Diesal_counsumption_hr						= String.valueOf(viabilityObj.Diesal_counsumption_hr__c); //String.valueOf(System.Label.Diesal_counsumption_hr);
                viabilityWrapper.Diesal_Rate_Hr								= String.valueOf(System.Label.diesel_rate); //String.valueOf(viabilityObj.Diesal_Rate_Hr__c);
                viabilityWrapper.Existing_Proposed							= viabilityObj.Existing_Proposed__c;
                viabilityWrapper.Expenses									= String.valueOf(viabilityObj.Expenses__c);
                viabilityWrapper.Net_Income									= String.valueOf(viabilityObj.Net_Income__c);
                viabilityWrapper.Nos_of_Hours_run_in_year					= String.valueOf(viabilityObj.Nos_of_Hours_run_in_year__c);
                viabilityWrapper.Per_Hour_Rate								= String.valueOf(viabilityObj.Per_Hour_Rate__c); //String.valueOf(System.Label.per_hour_rate);
                viabilityWrapper.Total_Income								= String.valueOf(viabilityObj.Total_Income__c);
                viabilityWrapper.Tractor_Harvester							= viabilityObj.Tractor_Harvester__c;
			    viabilityWrapper.id                							= viabilityObj.Id;
                viabilityWrapper.totalAgriExpensesForExistingHarvester		= String.valueOf(fi_List[0].Total_Agri_Expenses_for_Existing_Harvest__c);
                viabilityWrapper.totalAgriExpensesForProposedHarvester		= String.valueOf(fi_List[0].Total_Agri_Expenses_for_Proposed_Harvest__c);
                viabilityWrapper.totalAgriExpensesForExistingTractor		= String.valueOf(fi_List[0].Total_Agri_Expenses_for_Existing_Tractor__c);
                viabilityWrapper.totalAgriExpensesForProposedTractor		= String.valueOf(fi_List[0].Total_Agri_Expenses_for_Proposed_Tractor__c);
                    
                viabilityWrapper.totalAgriIncomeForExistingHarvester		= String.valueOf(fi_List[0].Total_Agri_Income_for_Existing_Harvester__c);
                viabilityWrapper.totalAgriIncomeForProposedHarvester    	= String.valueOf(fi_List[0].Total_Agri_Income_for_Proposed_Harvester__c);
                viabilityWrapper.totalAgriIncomeForExistingTractor			= String.valueOf(fi_List[0].Total_Agri_Income_for_Existing_Tractor__c);
                viabilityWrapper.totalAgriIncomeForProposedTractor			= String.valueOf(fi_List[0].Total_Agri_Income_for_Proposed_Tractor__c);
                    
                viabilityWrapper.totalAgriNetIncomeForExistingHarvester		= String.valueOf(fi_List[0].Total_Agri_Net_Income_for_Existing_Harve__c);
                viabilityWrapper.totalAgriNetIncomeForProposedHarvester		= String.valueOf(fi_List[0].Total_Agri_Net_Income_for_Proposed_Harve__c);
                viabilityWrapper.totalAgriNetIncomeForExistingTractor		= String.valueOf(fi_List[0].Total_Agri_Net_Income_for_Existing_Tract__c);
                viabilityWrapper.totalAgriNetIncomeForProposedTractor		= String.valueOf(fi_List[0].Total_Agri_Net_Income_for_Proposed_Tract__c);
                    
                viabilityWrapper.totalAgriCommercialExpensesForExistingHarvester = String.valueOf(fi_List[0].Total_Agri_Comm_Expenses_Exist_Harvest__c);
                viabilityWrapper.totalAgriCommercialExpensesForProposedHarvester = String.valueOf(fi_List[0].Total_Agri_Comm_Expen_Proposed_Harvest__c);
                viabilityWrapper.totalAgriCommercialExpensesForExistingTractor	 = String.valueOf(fi_List[0].Total_Agri_Comm_Expense_Existing_Tractor__c);
                viabilityWrapper.totalAgriCommercialExpensesForProposedTractor	 = String.valueOf(fi_List[0].Total_Agri_Comm_Expense_Proposed_Tractor__c);
                    
                viabilityWrapper.totalAgriCommercialIncomeForExistingHarvester	 = String.valueOf(fi_List[0].Total_Agri_Comm_Income_Existing_Harvest__c);
                viabilityWrapper.totalAgriCommercialIncomeForProposedHarvester	 = String.valueOf(fi_List[0].Total_Agri_Comm_Income_Proposed_Harvest__c);
                viabilityWrapper.totalAgriCommercialIncomeForExistingTractor	 = String.valueOf(fi_List[0].Total_Agri_Comm_Income_Existing_Tractor__c);
                viabilityWrapper.totalAgriCommercialIncomeForProposedTractor	 = String.valueOf(fi_List[0].Total_Agri_Comm_Income_Proposed_Tractor__c);
                    
                viabilityWrapper.totalAgriCommercialNetIncomeForExistingHarvester	= String.valueOf(fi_List[0].Total_Agri_Com_NetIncome_Existing_Harves__c);
                viabilityWrapper.totalAgriCommercialNetIncomeForProposedHarvester	= String.valueOf(fi_List[0].Total_Agri_Com_NetIncome_Proposed_Harves__c);
                viabilityWrapper.totalAgriCommercialNetIncomeForExistingTractor		= String.valueOf(fi_List[0].Total_Agri_Comm_NetIncome_Existing_Tract__c);
                viabilityWrapper.totalAgriCommercialNetIncomeForProposedTractor		= String.valueOf(fi_List[0].Total_Agri_Com_NetIncome_Proposed_Tract__c);
                viabilityExistingTractorInformationList.add(viabilityWrapper);
            }
            return viabilityExistingTractorInformationList;
        }
        return null;
    }
    public class saveViabilityExistingTractorInformationWrapper{
        @AuraEnabled public boolean isValid{get;set;}
        @AuraEnabled public boolean isDatabase{get;set;}
        @AuraEnabled public string Usage_Type{get;set;}
        @AuraEnabled public string id{get;set;}
        @AuraEnabled public string Diesal_counsumption_hr{get;set;}
        @AuraEnabled public string Diesal_Rate_Hr{get;set;}
        @AuraEnabled public string Existing_Proposed{get;set;}
        @AuraEnabled public string Expenses{get;set;}
        @AuraEnabled public string Net_Income{get;set;}
        @AuraEnabled public string Nos_of_Hours_run_in_year{get;set;}
        @AuraEnabled public string Per_Hour_Rate{get;set;}
        @AuraEnabled public string Total_Income{get;set;}
        @AuraEnabled public string Tractor_Harvester{get;set;}
        
        @AuraEnabled public string totalAgriExpensesForExistingHarvester {get;set;}
        @AuraEnabled public string totalAgriExpensesForProposedHarvester {get;set;}
        @AuraEnabled public string totalAgriExpensesForExistingTractor {get;set;}
        @AuraEnabled public string totalAgriExpensesForProposedTractor {get;set;}
    
        @AuraEnabled public string totalAgriIncomeForExistingHarvester {get;set;}
        @AuraEnabled public string totalAgriIncomeForProposedHarvester {get;set;}
        @AuraEnabled public string totalAgriIncomeForExistingTractor {get;set;}
        @AuraEnabled public string totalAgriIncomeForProposedTractor {get;set;}
    
        @AuraEnabled public string totalAgriNetIncomeForExistingHarvester {get;set;}
        @AuraEnabled public string totalAgriNetIncomeForProposedHarvester {get;set;}
        @AuraEnabled public string totalAgriNetIncomeForExistingTractor {get;set;}
        @AuraEnabled public string totalAgriNetIncomeForProposedTractor {get;set;}
    
        @AuraEnabled public string totalAgriCommercialExpensesForExistingHarvester {get;set;}
        @AuraEnabled public string totalAgriCommercialExpensesForProposedHarvester {get;set;}
        @AuraEnabled public string totalAgriCommercialExpensesForExistingTractor {get;set;}
        @AuraEnabled public string totalAgriCommercialExpensesForProposedTractor {get;set;}
    
        @AuraEnabled public string totalAgriCommercialIncomeForExistingHarvester {get;set;}
        @AuraEnabled public string totalAgriCommercialIncomeForProposedHarvester {get;set;}
        @AuraEnabled public string totalAgriCommercialIncomeForExistingTractor {get;set;}
        @AuraEnabled public string totalAgriCommercialIncomeForProposedTractor {get;set;}
    
        @AuraEnabled public string totalAgriCommercialNetIncomeForExistingHarvester {get;set;}
        @AuraEnabled public string totalAgriCommercialNetIncomeForProposedHarvester {get;set;}
        @AuraEnabled public string totalAgriCommercialNetIncomeForExistingTractor {get;set;}
        @AuraEnabled public string totalAgriCommercialNetIncomeForProposedTractor {get;set;}
    }

    @AuraEnabled(cacheable=true)
    public static List<CattleInformationWrapper> getCattleInformation(String fieldInvestigationId){
        List<CattleInformationWrapper> cattleWrapperLst = new List<CattleInformationWrapper>();
        try{
            List<Cattle_Information__c>cattleLst = [SELECT Id, Cattle_Name__c, Nos_of_Cattle__c
                                                            FROM Cattle_Information__c
                                                            WHERE Field_Investigation__c =: fieldInvestigationId
                                                           ];
            
            for(Cattle_Information__c cattleInfo: cattleLst){
                CattleInformationWrapper cattleWrapper = new CattleInformationWrapper();
                cattleWrapper.isValid = true;
                cattleWrapper.isDatabase = true;
                cattleWrapper.Cattle_Name = cattleInfo.Cattle_Name__c;
                cattleWrapper.Nos_of_Cattle = Integer.valueOf(cattleInfo.Nos_of_Cattle__c);
                cattleWrapper.id =  cattleInfo.Id;
                cattleWrapperLst.add(cattleWrapper);
            }

            return cattleWrapperLst;

        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void saveCattleInformation(List<CattleInformationWrapper> cattleLst, String fieldInvestigationId){
        System.debug('>>> Input received for saving Cattle Information is :: \n'+cattleLst);
        try {
            List<Cattle_Information__c> cattleInformationLst = new List<Cattle_Information__c>();
            for(CattleInformationWrapper obj: cattleLst){
                if(obj.isValid == true && obj.isDatabase == false){
                    Cattle_Information__c cattleInfo = new Cattle_Information__c();
                    cattleInfo.Cattle_Name__c = obj.Cattle_Name;
                    cattleInfo.Nos_of_Cattle__c = obj.Nos_of_Cattle;
                    cattleInfo.Field_Investigation__c = fieldInvestigationId;
                    if (obj.id != null && obj.id.length() == 18) { //SFTRAC-614 checking Id length and passing Id
                        cattleInfo.Id = obj.id;
                    }
                    cattleInformationLst.add(cattleInfo);
                }
            }

            if(cattleInformationLst.size()>0){
                //insert cattleInformationLst;  //SFTRAC-614 removed
                upsert cattleInformationLst;    //SFTRAC-614 added upsert
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class CattleInformationWrapper{
        @AuraEnabled
        public Boolean isValid {get;set;}
        @AuraEnabled
        public Boolean isDatabase {get;set;}
        @AuraEnabled
        public String Cattle_Name {get;set;}
        @AuraEnabled
        public Integer Nos_of_Cattle {get;set;}
        @AuraEnabled
        public String id {get;set;}
    }
    @AuraEnabled(cacheable=true)
    public static List<WorkOrderWrapper> getWorkOrderDetails(String fieldInvestigationId){
        List<WorkOrderWrapper> workOrderWrapperLst = new List<WorkOrderWrapper>();
        try{
            List<Work_Order_Details__c>workOrderLst = [SELECT Id, Contract_with_Company__c,Date_of_Commencement__c,Explanation__c,Contact_Amount__c,Tenure_of_Contract_Years__c
                                                            FROM Work_Order_Details__c
                                                            WHERE Field_Investigation__c =: fieldInvestigationId
                                                           ];
            
            for(Work_Order_Details__c workInfo: workOrderLst){
                WorkOrderWrapper workWrapper = new WorkOrderWrapper();
                workWrapper.isValid = true;
                workWrapper.isDatabase = true;
                workWrapper.ContractWithCompany = workInfo.Contract_with_Company__c;
                workWrapper.dateofCommencement = workInfo.Date_of_Commencement__c;
                workWrapper.Explanation =  workInfo.Explanation__c;
                workWrapper.contactAmount = workInfo.Contact_Amount__c;
                workWrapper.tenureofContacts = workInfo.Tenure_of_Contract_Years__c;
                workWrapper.id =  workInfo.Id;
                workOrderWrapperLst.add(workWrapper);
            }

            return workOrderWrapperLst;

        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void saveWorkOrderDetails(List<WorkOrderWrapper> workOrderLst, String fieldInvestigationId){
        System.debug('>>> Input received for saving Work Order Information is :: \n'+workOrderLst);
        try {
            List<Work_Order_Details__c> workOrderList = new List<Work_Order_Details__c>();
            for(WorkOrderWrapper obj: workOrderLst){
                if(obj.isValid == true && obj.isDatabase == false){
                    Work_Order_Details__c workInfo = new Work_Order_Details__c();
                    workInfo.Contract_with_Company__c = obj.ContractWithCompany;
                    workInfo.Date_of_Commencement__c = obj.dateofCommencement;
                    workInfo.Explanation__c = obj.Explanation;
                    workInfo.Contact_Amount__c = obj.contactAmount;
                    workInfo.Tenure_of_Contract_Years__c = obj.tenureofContacts;

                    workInfo.Field_Investigation__c = fieldInvestigationId;
                    workOrderList.add(workInfo);
                }
            }

            if(workOrderList.size()>0){
                insert workOrderList;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class WorkOrderWrapper{
        @AuraEnabled
        public Boolean isValid {get;set;}
        @AuraEnabled
        public Boolean isDatabase {get;set;}
        @AuraEnabled
        public String ContractWithCompany {get;set;}
        @AuraEnabled
        public Date dateofCommencement {get;set;}
        @AuraEnabled
        public String Explanation {get;set;}
        @AuraEnabled
        public Decimal contactAmount {get;set;}
        @AuraEnabled
        public String tenureofContacts {get;set;}
        @AuraEnabled
        public String id {get;set;}
    }

    @AuraEnabled(cacheable=true)
    public static List<FleetWrapper> getFleetDetails(String fieldInvestigationId){
        List<FleetWrapper> fleetWrapperLst = new List<FleetWrapper>();
        try{
            List<Fleet_Details__c> fleetLst = [SELECT Id, Asset_Type__c,Asset_Name__c,RC_no__c,YOM__c,Owner_Name__c,Hypothecation__c,Financier_Name__c,Loan__c
                                                            FROM Fleet_Details__c
                                                            WHERE Field_Investigation__c =: fieldInvestigationId
                                                           ];
            
            for(Fleet_Details__c fleetInfo: fleetLst){
                FleetWrapper fleetWrap = new FleetWrapper();
                fleetWrap.isValid = true;
                fleetWrap.isDatabase = true;
                fleetWrap.assetType = fleetInfo.Asset_Type__c;
                fleetWrap.assetName = fleetInfo.Asset_Name__c;
                fleetWrap.rcNo =  fleetInfo.RC_no__c;
                fleetWrap.yom = fleetInfo.YOM__c;
                fleetWrap.ownerName = fleetInfo.Owner_Name__c;
                fleetWrap.hypothecation = fleetInfo.Hypothecation__c;
                fleetWrap.financierName = fleetInfo.Financier_Name__c;
                fleetWrap.loan = fleetInfo.Loan__c;

                fleetWrap.id =  fleetInfo.Id;
                fleetWrapperLst.add(fleetWrap);
            }

            return fleetWrapperLst;

        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void saveFleetDetails(List<FleetWrapper> fleetLst, String fieldInvestigationId){
        System.debug('>>> Input received for saving Work Order Information is :: \n'+fleetLst);
        try {
            List<Fleet_Details__c> fleetListData = new List<Fleet_Details__c>();
            for(FleetWrapper obj: fleetLst){
                if(obj.isValid == true && obj.isDatabase == false){
                    Fleet_Details__c fleetInfo = new Fleet_Details__c();
                    fleetInfo.Asset_Type__c = obj.assetType;
                    fleetInfo.Asset_Name__c = obj.assetName;
                    fleetInfo.RC_no__c = obj.rcNo;
                    fleetInfo.YOM__c = obj.yom;
                    fleetInfo.Owner_Name__c = obj.ownerName;
                    fleetInfo.Hypothecation__c = obj.hypothecation;
                    fleetInfo.Financier_Name__c = obj.financierName;
                    fleetInfo.Loan__c = obj.loan;

                    fleetInfo.Field_Investigation__c = fieldInvestigationId;
                    fleetListData.add(fleetInfo);
                }
            }

            if(fleetListData.size()>0){
                insert fleetListData;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class FleetWrapper{
        @AuraEnabled
        public Boolean isValid {get;set;}
        @AuraEnabled
        public Boolean isDatabase {get;set;}
        @AuraEnabled
        public String assetType {get;set;}
        @AuraEnabled
        public String assetName {get;set;}
        @AuraEnabled
        public String rcNo {get;set;}
        @AuraEnabled
        public String yom {get;set;}
        @AuraEnabled
        public String ownerName {get;set;}
        @AuraEnabled
        public String hypothecation {get;set;}
        @AuraEnabled
        public String financierName {get;set;}
        @AuraEnabled
        public String loan {get;set;}
        @AuraEnabled
        public String id {get;set;}
    }

    /*
    * @Method:      saveLandHoldingDetails
    * @Created by:  Chaynnitt Agarwal
    * @Description: This method will save all the Land Holding Details record
    * @Param:       Object landHoldingLst & Field Investigation Id
    * @Return:      Void
    */
    @AuraEnabled
    public static void saveLandHoldingDetails(List<LandHoldingDetailWrapper> landLst, String fieldInvestigationId){
        System.debug('>>> Input received for saving is :: \n'+landLst[0]);
        try {
            List<Land_Holding_Detail__c> landHoldingDetailLst = new List<Land_Holding_Detail__c>();
            for(LandHoldingDetailWrapper obj: landLst){
                if(obj.isValid == true && obj.isDatabase == false){
                    Land_Holding_Detail__c landDetail = new Land_Holding_Detail__c();
                    landDetail.Land_holder_Name__c = obj.Land_holder_Name;
                    landDetail.Type__c = obj.Type;
                    landDetail.Land_holding_Type__c = obj.Land_holding_Type;
                    landDetail.Ownership_Type__c = obj.Ownership_Type;
                    landDetail.Geo_State_Master__c = obj.State_Master;
                    landDetail.District_Master__c = obj.District_Master;
                    landDetail.Taluka_Master__c = obj.Taluka_Master;
                    landDetail.Village_Name__c = obj.Village_Name;
                    landDetail.Survey_No__c = obj.Survey_No;
                    landDetail.Land_holding_In_acres__c = Decimal.valueof(obj.Land_holding_In_acres);
                    landDetail.Proof_attached__c = obj.Proof_attached;
                    landDetail.Since_How_long_are_they_doing_Agricultu__c = Integer.valueof(obj.Since_How_long_are_they_doing_Agricultu);
                    landDetail.Field_Investigation__c = fieldInvestigationId;
                    landDetail.Approximate_value_of_Agri_Land__c = obj.Approx_Value;
                    if (obj.id != null && obj.id.length() == 18) { //SFTRAC-614 checking Id length and passing Id
                        landDetail.Id = obj.id;
                    }
                    landHoldingDetailLst.add(landDetail);
                }
            }

            if(landHoldingDetailLst.size()>0){
                //insert landHoldingDetailLst;  //SFTRAC-614 removed
                upsert landHoldingDetailLst;    //SFTRAC-614 added upsert
            }
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    public class LandHoldingDetailWrapper{
        @AuraEnabled
        public Boolean isValid {get;set;}
        @AuraEnabled
        public Boolean isDatabase {get;set;}
        @AuraEnabled
        public String Land_holder_Name {get;set;}
        @AuraEnabled
        public String Type {get;set;}
        @AuraEnabled
        public String Land_holding_Type {get;set;}
        @AuraEnabled
        public String Ownership_Type {get;set;}
        @AuraEnabled
        public String State_Master {get;set;}
        @AuraEnabled
        public String State_Master_Value {get;set;}
        @AuraEnabled
        public String District_Master {get;set;}
        @AuraEnabled
        public String District_Master_Value {get;set;}
        @AuraEnabled
        public String Taluka_Master {get;set;}
        @AuraEnabled
        public String Taluka_Master_Value {get;set;}
        @AuraEnabled
        public String Village_Name {get;set;}
        @AuraEnabled
        public String Survey_No {get;set;}
        @AuraEnabled
        public String Land_holding_In_acres {get;set;}
        @AuraEnabled
        public String Proof_attached {get;set;}
        @AuraEnabled
        public String Since_How_long_are_they_doing_Agricultu {get;set;}
        @AuraEnabled
        public Decimal Approx_Value {get;set;}
        @AuraEnabled
        public String id {get;set;}
    }


    /*
    * @Method:      getLandHoldingDetails
    * @Created by:  Chaynnitt Agarwal
    * @Description: This method will get all the Land Holding Details record based on FI
    * @Param:       Field Investigation Id
    * @Return:      List<LandHoldingDetailWrapper>
    */
    @AuraEnabled(cacheable = true)
    public static List<LandHoldingDetailWrapper> getLandHoldingDetails(String fieldInvestigationId){
        List<LandHoldingDetailWrapper> LandHoldingWrapperLst = new List<LandHoldingDetailWrapper>();
        try{
            List<Land_Holding_Detail__c> landHoldingLst = [SELECT Id, Land_holder_Name__c, Type__c, Land_holding_Type__c, Ownership_Type__c, Geo_State_Master__c, Geo_State_Master__r.Name, District_Master__c, District_Master__r.Name, Taluka_Master__c, Taluka_Master__r.Name, Village_Name__c, Survey_No__c, Land_holding_In_acres__c, Proof_attached__c, Since_How_long_are_they_doing_Agricultu__c, Approximate_value_of_Agri_Land__c
                                                            FROM Land_Holding_Detail__c
                                                            WHERE Field_Investigation__c =: fieldInvestigationId
                                                           ];
            
            
            for(Land_Holding_Detail__c landDetail: landHoldingLst){
                LandHoldingDetailWrapper landHoldingWrapper = new LandHoldingDetailWrapper();
                landHoldingWrapper.isValid = true;
                landHoldingWrapper.isDatabase = true;
                landHoldingWrapper.Land_holder_Name = landDetail.Land_holder_Name__c;
                landHoldingWrapper.Type = landDetail.Type__c;
                landHoldingWrapper.Land_holding_Type = landDetail.Land_holding_Type__c;
                landHoldingWrapper.Ownership_Type = landDetail.Ownership_Type__c;
                landHoldingWrapper.State_Master = landDetail.Geo_State_Master__c;
                landHoldingWrapper.State_Master_Value = landDetail.Geo_State_Master__r.Name;
                landHoldingWrapper.District_Master = landDetail.District_Master__c;
                landHoldingWrapper.District_Master_Value = landDetail.District_Master__r.Name;
                landHoldingWrapper.Taluka_Master = landDetail.Taluka_Master__c;
                landHoldingWrapper.Taluka_Master_Value = landDetail.Taluka_Master__r.Name;
                landHoldingWrapper.Village_Name = landDetail.Village_Name__c;
                landHoldingWrapper.Survey_No = landDetail.Survey_No__c;
                landHoldingWrapper.Land_holding_In_acres = String.valueof(landDetail.Land_holding_In_acres__c);
                landHoldingWrapper.Proof_attached = landDetail.Proof_attached__c;
                landHoldingWrapper.Since_How_long_are_they_doing_Agricultu = String.valueof(landDetail.Since_How_long_are_they_doing_Agricultu__c);
                landHoldingWrapper.Approx_Value = landDetail.Approximate_value_of_Agri_Land__c;
                landHoldingWrapper.id =  landDetail.Id;
                LandHoldingWrapperLst.add(landHoldingWrapper);
            }

            return LandHoldingWrapperLst;

        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    /*
    * @Method:      getCurrentResidenceAddress
    * @Created by:  Sahil M
    * @Description: This method will get the document with Current_Residential_Address_Proof__c = true
    * @Param:       Applicant Id
    * @Return:      List<Documents__c>
    */
    @AuraEnabled(Cacheable=true) 
    public static List<Documents__c> getCurrentResidenceAddress(String applicantId){
        List<Documents__c> documentList = [SELECT Id,
                                           KYC_Address_Line_1__c,KYC_Address_Line_2__c,KYC_City__c,
                                           KYC_Pin_Code__c, KYC_State__c
                                           FROM Documents__c
                                           WHERE Applicant__c = :applicantId AND  
                                           (Current_Residential_Address_Proof__c=true OR (Proof_of_Address_POA__c = true AND Document_Type__c =: System.Label.GST_Cert AND Applicant__r.Is_this_Current_Residence_Cum_office__c = true)) LIMIT 1];
        return documentList;
    }
    
    /*
    * @Method:      getPermanentResidenceAddress
    * @Created by:  Sahil M
    * @Description: This method will get the document with Permanent_Residential_Address_Proof__c = true
    * @Param:       Applicant Id
    * @Return:      List<Documents__c>
    */
    @AuraEnabled (Cacheable=true) 
    public static List<Documents__c> getPermanentResidenceAddress(String applicantId){
        List<Documents__c> documentList = [SELECT Id,
                                           KYC_Address_Line_1__c,KYC_Address_Line_2__c,KYC_City__c,
                                           KYC_Pin_Code__c, KYC_State__c
                                           FROM Documents__c
                                           WHERE Applicant__c = :applicantId AND  
                                           (Permanent_Residential_Address_Proof__c=true OR (Proof_of_Address_POA__c = true AND Document_Type__c =: System.Label.GST_Cert)) LIMIT 1];
        return documentList;
    }

    public class ExpenseAndInvestmentWrapper {
        @AuraEnabled
        public Boolean isValid { get; set; }
        @AuraEnabled
        public Boolean isDatabase { get; set; }
        @AuraEnabled
        public String Type { get; set; }
        @AuraEnabled
        public String ExpenseType { get; set; }
        @AuraEnabled
        public List<ExpenseTypeOption> ExpenseTypeOptions { get; set; }
        @AuraEnabled
        public Decimal Amount { get; set; }
        @AuraEnabled
        public string id { get; set; }
        
    }
    public class ExpenseTypeOption {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String value { get; set; }
    }
    /*
    * @Method:      saveExpenseInvestmentDetails
    * @Created by:  Sahil M
    * @Description: This method will save Expense Investment Details
    * @Param:       List<ExpenseAndInvestmentWrapper> records, String fieldInvestigationId
    * @Return:      
    */
    @AuraEnabled
    public static void saveExpenseInvestmentDetails(List<ExpenseAndInvestmentWrapper> records, String fieldInvestigationId){
        System.debug('>>> Input received for saving is :: \n'+records[0]);
        try {
            List<Total_Expense_and_investment__c > expenseInvesetmentDetailList = new List<Total_Expense_and_investment__c >();
            for (ExpenseAndInvestmentWrapper record : records) {
                //if(record.isValid == true && record.isDatabase == false){
                    Total_Expense_and_investment__c rec = new Total_Expense_and_investment__c();
                    rec.Type__c = record.Type;
                    rec.Expenses_and_Investment_Type__c = record.ExpenseType;
                    rec.Amount__c = record.Amount;
                    rec.Field_Investigation__c  = fieldInvestigationId;
                    if (record.id != null && record.id.length() == 18) { //SFTRAC-614 checking Id length and passing Id
                        rec.Id = record.id;
                    }
                    expenseInvesetmentDetailList.add(rec);
                //}
                
            }
            
            if(expenseInvesetmentDetailList.size()>0){
                //insert expenseInvesetmentDetailList;  //SFTRAC-614 removed
                upsert expenseInvesetmentDetailList;    //SFTRAC-614 added upsert
            }
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /*
    * @Method:      saveExpenseInvestmentDetails
    * @Created by:  Sahil M
    * @Description: This method will Get Expense Investment Details
    * @Param:       fieldInvestigationId
    * @Return:      List<ExpenseAndInvestmentWrapper>
    */
    @AuraEnabled(cacheable = true)
    public static List<ExpenseAndInvestmentWrapper> getExpenseInvestmentDetail(String fieldInvestigationId){
        List<ExpenseAndInvestmentWrapper> ExpenseAndInvestmentWrapperLst = new List<ExpenseAndInvestmentWrapper>();
        try{
            List<Total_Expense_and_investment__c> expenseInvstDetail = [SELECT Id,Expenses_and_Investment_Type__c, Type__c, Amount__c 
                                                                        FROM Total_Expense_and_investment__c  
                                                                        WHERE Field_Investigation__c =: fieldInvestigationId];
            
            
            for(Total_Expense_and_investment__c record: expenseInvstDetail){
                ExpenseAndInvestmentWrapper wrap = new ExpenseAndInvestmentWrapper();
                wrap.isValid = true;
                wrap.isDatabase = true;
                wrap.Type = record.Type__c;
                wrap.ExpenseType = record.Expenses_and_Investment_Type__c;
                wrap.Amount = record.Amount__c;
                wrap.id = record.Id;
                ExpenseAndInvestmentWrapperLst.add(wrap);
            }
            
            return ExpenseAndInvestmentWrapperLst;
            
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    /*
    * @Method:      getVehicleDetailsRecord
    * @Created by:  Sahil M
    * @Description: This method will get vehicle detail record
    * @Param:       loanApplicationId
    * @Return:      List<Vehicle_Detail__c>
    */
    @AuraEnabled(cacheable = true)
    public static List<Vehicle_Detail__c> getVehicleDetailsRecord(String loanApplicationId){
        List<Vehicle_Detail__c> vehicleDetails = [SELECT Id, Name,Variant__c, What_is_thePrice_of_TractorHarvester__c ,How_much_margin_amount_paid_to_dealer__c ,
                                                  Loan_Amount__c ,What_is_emi_convyed_to_customer__c ,Loan_tenure__c ,Repayment_Mode__c ,
                                                  Repayment_Frequency__c,Installment_Type__c,Vehicle_SubType__c
                                                  FROM Vehicle_Detail__c 
                                                  WHERE Loan_Application__c =: loanApplicationId];
        
        return vehicleDetails;
    }

    public class loaninformationWrapper {
        @AuraEnabled
        public String Id { get; set; }
        @AuraEnabled
        public String Name { get; set; }
        @AuraEnabled
        public string purchasePrice { get; set; }
        @AuraEnabled
        public string marginAmountToDealer { get; set; }
        @AuraEnabled
        public Integer emiConveyed { get; set; }
        @AuraEnabled
        public Integer loanTenure { get; set; }
        @AuraEnabled
        public string repaymentMode { get; set; }
        @AuraEnabled
        public string repaymentFrequency { get; set; }
        @AuraEnabled
        public string installmentType { get; set; }
    }
	/*
    * @Method:      updateVehicleRecord
    * @Created by:  Sahil M
    * @Description: This method will update the vehicle detail record from FI Case page
    * @Param:       List<loaninformationWrapper> loanData , String recId
    * @Return:      
    */
    @AuraEnabled
    public static void updateVehicleRecord(List<loaninformationWrapper> loanData , String recId) {
        system.debug('datatoupdate-'+loanData);
        system.debug('recId-'+recId);
        List<Vehicle_Detail__c> recordsToUpdate = new List<Vehicle_Detail__c>();
        for (loaninformationWrapper updateData : loanData) {
            Vehicle_Detail__c recordToUpdate = new Vehicle_Detail__c(
                Id = updateData.Id,
                What_is_thePrice_of_TractorHarvester__c = updateData.purchasePrice,
                How_much_margin_amount_paid_to_dealer__c = updateData.marginAmountToDealer,
                What_is_emi_convyed_to_customer__c = updateData.emiConveyed,
                Loan_tenure__c = updateData.loanTenure,
                Repayment_Mode__c = updateData.repaymentMode,
                Repayment_Frequency__c = updateData.repaymentFrequency,
                Installment_Type__c = updateData.installmentType
            );
            
            recordsToUpdate.add(recordToUpdate);
        }
        if (!recordsToUpdate.isEmpty()) {
            update recordsToUpdate;
        }
    }
    
    @AuraEnabled
    public static Field_Investigation__c getFieldInvestigationKycLocation(String fieldInvestigationId) {
        try{
            Field_Investigation__c fiRecord = new Field_Investigation__c();
            fiRecord = [Select Id,KYC_Location__c,KYC_Location__Latitude__s,KYC_Location__Longitude__s,FI_Location__c,FI_Location__Latitude__s,FI_Location__Longitude__s,Coordinates_Verified__c From Field_Investigation__c WHERE Id=:fieldInvestigationId];
            return fiRecord;
        }
        catch(Exception e) {
           throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    /*
    * @Method:      getLandSurveyNo
    * @Created by:  Chaynnitt Agarwal
    * @Description: This method will get list of all Survey No from Land Holding Detail Object
    * @Param:       Field Investigation Id
    * @Return:      List<PicklistWrapper>
    */
    @AuraEnabled(cacheable = true)
    public static List<PicklistWrapper> getLandSurveyNo(String fieldInvestigationId){
        List<PicklistWrapper> landSurveyNoLst = new List<PicklistWrapper>();
        try {
            List<Land_Holding_Detail__c> landDetailLst = [SELECT Id, Survey_No__c FROM Land_Holding_Detail__c 
                                                    WHERE Field_Investigation__c =: fieldInvestigationId
                                                   ];
            for(Land_Holding_Detail__c land: landDetailLst){
                landSurveyNoLst.add(new PicklistWrapper(land.Survey_No__c,land.Survey_No__c));
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return landSurveyNoLst;
    }

    class PicklistWrapper{
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public String value{get;set;}

        public PicklistWrapper(String label, String value){
            this.label = label;
            this.value = value;
        }
    }

    @AuraEnabled(cacheable = true)
    public static Field_Investigation__c getFIRecord(String caseId){
        try{
            if(String.isNotBlank(caseId)){
                List<Field_Investigation__c> fieldInvestiagationList = [SELECT Id, RecordType.Name FROM Field_Investigation__c
                                                                        WHERE Case__c =: caseId LIMIT 1];
                if(!fieldInvestiagationList.isEmpty()){
                    return fieldInvestiagationList[0];
                }else{
                    throw new IND_Exception('Field Investigation Details are not available, Please contact your administrator.');
                }
            }else{
                throw new IND_Exception('Something went wrong, Please contact your administator.');
            }
        }Catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('getFIID', 'IND_LWC_FICasePageCntrl', System.Label.Apex, e, '');
            throw new IND_Exception(e.getMessage());
        }
        
    }

    //SFTRAC-1880 Start
    @AuraEnabled
    public static Field_Investigation__c getRecordWithGeoLocation(String recordId){
        return [
            SELECT FI_Location__Latitude__s, FI_Location__Longitude__s
            FROM Field_Investigation__c
            WHERE Id = :recordId
            LIMIT 1
        ];
    }
    //SFTRAC-1880 End

    //SFTRAC-1880 Start
    @AuraEnabled(cacheable = true)
    public static Boolean isFISubmitAllowed(String caseId){
        Boolean result = true;
        Case caseRec = [ SELECT Id, Loan_Application__c, Loan_Application__r.Vehicle_Type__c
                            FROM Case
                            WHERE Id = :caseId
                            LIMIT 1 ];
        List<Vehicle_Detail__c> vehLst = [SELECT Id, Valuer_category__c, Loan_Amount__c 
                                            FROM Vehicle_Detail__c 
                                            WHERE Loan_Application__c =: caseRec.Loan_Application__c
                                            WITH SECURITY_ENFORCED];
        for(Vehicle_Detail__c veh: vehLst){
            // if((caseRec.Loan_Application__r.Vehicle_Type__c == 'New' && veh.Loan_Amount__c == null) || ((caseRec.Loan_Application__r.Vehicle_Type__c == 'Used' || caseRec.Loan_Application__r.Vehicle_Type__c == 'Refinance') && veh.Valuer_category__c == 'MFC' && veh.Loan_Amount__c == null)){
            if(veh.Loan_Amount__c == null){
                result = false;
                break;
            }
        }
        
        return result;
        
    }
    //SFTRAC-1880 End

}