/**
* UserStory     CISP-160
* @Name         ExternalCAMDataController
* @Author       Rajat Jaiswal
* @Description  This Class is used to saving API data and creating External CAM Data for APD Pending, Portfolio, Non IBL Exposure and many more.
**/
public without sharing class ExternalCAMDataController {
    @AuraEnabled
    public static void storingExternalCAMData(String loanAppId, String camId, String apiResponse, String apiName, Boolean isBorrower, String applicantId){
        try {
            if(apiName!=null && apiResponse!=null){
                List<External_CAM_Data__c> camDataList = new List<External_CAM_Data__c>();
                Integer accountType = 0;
                Integer accountTypeforADPD = 0;
                Decimal overdueAccount = 0.0;
                String totalDPD = '';
                Integer totalHighCredit = 0;
                Decimal termLoanAD;
                Decimal termLoanPD;
                Decimal otherLoanAD;
                Decimal otherLoanPD;
                List<String> accountTypeList = new List<String>{'14','15','31','59'};
                if (apiName == 'CAM Portfolio') {
                    System.debug('apiResponse CAM: ' + apiResponse);
                    IND_CAMPortfolioResponse.response responseWrapper = (IND_CAMPortfolioResponse.response)system.JSON.deserialize(apiResponse, IND_CAMPortfolioResponse.response.class);
                    System.debug('responseWrapper CAM: ' + responseWrapper);
                    if(isBorrower && responseWrapper != null && responseWrapper.content != null && responseWrapper.content[0].PANA_DT != null){
                        Id portfolioId = Schema.SObjectType.External_CAM_Data__c.getRecordTypeInfosByDeveloperName().get('Portfolio').getRecordTypeId();
                        for(IND_CAMPortfolioResponse.PANA_DT objPanaDt  :responseWrapper.content[0].PANA_DT){
                            External_CAM_Data__c camData = new External_CAM_Data__c();
                            camData.CAM__c = camId;
                            camData.RecordTypeId = portfolioId;
                            camData.Name__c = objPanaDt.Name;
                            camData.Year__c = objPanaDt.Year;
                            camData.Total_Deals__c = Integer.valueOf(objPanaDt.Tot_Deals);
                            camData.Adv_Nos__c = Integer.valueOf(objPanaDt.Adv_Nos);
                            camData.Adv_Amt__c = Integer.valueOf(objPanaDt.Adv_Amt);
                            camData.NoDue_Nos__c = Integer.valueOf(objPanaDt.NoDue_Nos);
                            camData.NoDue_LOS__c = Integer.valueOf(objPanaDt.NoDue_LOS);
                            camData.STD1_Nos__c = Integer.valueOf(objPanaDt.STD1_Nos);
                            camData.STD1_LOS__c = Integer.valueOf(objPanaDt.STD1_LOS);
                            camData.STD2_Nos__c = Integer.valueOf(objPanaDt.STD2_Nos);
                            camData.STD2_LOS__c = Integer.valueOf(objPanaDt.STD2_LOS);
                            camData.STD3_Nos__c = Integer.valueOf(objPanaDt.STD3_Nos);
                            camData.STD3_LOS__c = Integer.valueOf(objPanaDt.STD3_LOS);
                            camData.NPA1_Nos__c = Integer.valueOf(objPanaDt.NPA1_Nos);
                            camData.NPA1_LOS__c = Integer.valueOf(objPanaDt.NPA1_LOS);
                            camData.NPA2_Nos__c = Integer.valueOf(objPanaDt.NPA2_Nos);
                            camData.NPA2_LOS__c = Integer.valueOf(objPanaDt.NPA2_LOS);
                            camData.NPA3_Nos__c = Integer.valueOf(objPanaDt.NPA3_Nos);
                            camData.NPA3_LOS__c = Integer.valueOf(objPanaDt.NPA3_LOS);
                            camData.NPAA_Nos__c = Integer.valueOf(objPanaDt.NPAA_Nos);
                            camData.NPAA_LOS__c = Integer.valueOf(objPanaDt.NPAA_LOS);
                            camData.Tot_Nos__c = Integer.valueOf(objPanaDt.Tot_Nos);
                            camData.Tot_LOS__c = Integer.valueOf(objPanaDt.Tot_LOS);
                            camDataList.add(camData);
                        }
                    }
                    if(responseWrapper != null && responseWrapper.content != null && responseWrapper.content[0].CIBIL_Dt != null){
                        for(IND_CAMPortfolioResponse.CIBIL_Dt cibilObj  :responseWrapper.content[0].CIBIL_Dt){
                            if(String.isNotBlank(cibilObj.Account_Type) && accountTypeList.contains(cibilObj.Account_Type)){
                                accountType += Integer.ValueOf(cibilObj.Account_Type);
                            }else if(String.isNotBlank(cibilObj.Account_Type) && !accountTypeList.contains(cibilObj.Account_Type)){
                                accountTypeforADPD += Integer.ValueOf(cibilObj.Account_Type);
                            }
                            totalDPD = cibilObj.Payment_History1 + cibilObj.Payment_History2;
                            totalHighCredit = Integer.ValueOf(cibilObj.HighCredit_Or_SanctionedAmount);
                        }
                    }
                    if(responseWrapper != null && responseWrapper.content != null && responseWrapper.content[0].CIBIL_Suit_Filed != null){
                        for(IND_CAMPortfolioResponse.CIBIL_Suit_Filed cibilSuitObj  :responseWrapper.content[0].CIBIL_Suit_Filed){
                            if(String.isNotBlank(cibilSuitObj.Month_Overdue)){
                                overdueAccount += Decimal.ValueOf(cibilSuitObj.Month_Overdue);
                            }
                        }
                    }
                    if(responseWrapper != null && responseWrapper.content != null && responseWrapper.content[0].Non_IBL_Exposure != null){
                        Id nonIBLExposureId = Schema.SObjectType.External_CAM_Data__c.getRecordTypeInfosByDeveloperName().get('Non_IBL_Exposure').getRecordTypeId();
                        for(IND_CAMPortfolioResponse.Non_IBL_Exposure nonIBLExObj  :responseWrapper.content[0].Non_IBL_Exposure){
                            External_CAM_Data__c camData = new External_CAM_Data__c();
                            camData.CAM__c = camId;
                            camData.RecordTypeId = nonIBLExposureId;
                            camData.Account_Type_Desc__c = nonIBLExObj.Account_Type_Desc;
                            camData.Ownership__c = nonIBLExObj.Ownership;
                            camData.HighCredit__c = Integer.valueOf(nonIBLExObj.HighCredit);
                            camData.CurrentBalance__c = Integer.valueOf(nonIBLExObj.CurrentBalance);
                            camData.AmountOverdue__c = Integer.valueOf(nonIBLExObj.AmountOverdue);
                            camData.ReasonforOverdue__c = nonIBLExObj.ReasonforOverdue;
                            camData.Name__c= nonIBLExObj.FinanicerName;
                            camData.Customer_Type__c = nonIBLExObj.Customer;
                            if(String.isNotBlank(nonIBLExObj.OpenDate)){
                                camData.Open_Date__c = Date.parse(changeDateFormat(nonIBLExObj.OpenDate));
                            }
                            if(String.isNotBlank(nonIBLExObj.LastPaymentDate)){
                                camData.Last_Payment_Date__c = Date.parse(changeDateFormat(nonIBLExObj.LastPaymentDate));
                            }
                            camDataList.add(camData);
                        }
                    }
                }
                if(apiName == 'APD Pending'){
                    System.debug('apiResponse APD: ' + apiResponse);
                    IND_APDPendingResponse.response responseWrapper = (IND_APDPendingResponse.response)system.JSON.deserialize(apiResponse, IND_APDPendingResponse.response.class);
                    System.debug('responseWrapper APD: ' + responseWrapper);
                    if(responseWrapper != null && responseWrapper.content != null){
                        Id apdPendingId = Schema.SObjectType.External_CAM_Data__c.getRecordTypeInfosByDeveloperName().get('APD_Pending').getRecordTypeId();
                        if(responseWrapper.content[0].User_APD_Pending != null && responseWrapper.content[0].User_APD_Pending.UserRCPendings != null){
                            for(IND_APDPendingResponse.UserRCPendings userRCObj : responseWrapper.content[0].User_APD_Pending.UserRCPendings){
                                if(String.isNotBlank(userRCObj.Name)){
                                    External_CAM_Data__c camData = new External_CAM_Data__c();
                                    camData.CAM__c = camId;
                                    camData.Name__c = userRCObj.Name;
                                    camData.RecordTypeId = apdPendingId;
                                    camData.Document_Type__c = userRCObj.Doc_Type;
                                    camData.Below_30_Days__c = Integer.valueOf(userRCObj.Count_1_30);
                                    camData.X30_To_60_Days__c = Integer.valueOf(userRCObj.Count_31_60);
                                    camData.X60_To_90_Days__c = Integer.valueOf(userRCObj.Count_61_90);
                                    camData.Above_90_Days__c = Integer.valueOf(userRCObj.Count_Above_90);
                                    camData.Total_Pending__c = Integer.valueOf(userRCObj.Total_Count);
                                    // camData.Deposit_Available__c = Integer.valueOf(userRCObj.STD1_Nos);
                                    camData.Log_Type__c = 'User RC APD';
                                    camDataList.add(camData);
                                }
                            }
                        }
                        if(responseWrapper.content[0].User_APD_Pending != null && responseWrapper.content[0].User_APD_Pending.UserInsurancePending != null){
                            for(IND_APDPendingResponse.UserInsurancePending userInsObj : responseWrapper.content[0].User_APD_Pending.UserInsurancePending){
                                if(String.isNotBlank(userInsObj.Name)){
                                    External_CAM_Data__c camData = new External_CAM_Data__c();
                                    camData.CAM__c = camId;
                                    camData.Name__c = userInsObj.Name;
                                    camData.RecordTypeId = apdPendingId;
                                    camData.Document_Type__c = userInsObj.Doc_Type;
                                    camData.Below_30_Days__c = Integer.valueOf(userInsObj.Count_1_30);
                                    camData.X30_To_60_Days__c = Integer.valueOf(userInsObj.Count_31_60);
                                    camData.X60_To_90_Days__c = Integer.valueOf(userInsObj.Count_61_90);
                                    camData.Above_90_Days__c = Integer.valueOf(userInsObj.Count_Above_90);
                                    camData.Total_Pending__c = Integer.valueOf(userInsObj.Total_Count);
                                    camData.Deposit_Available__c = userInsObj.Deposit_Avl;
                                    camData.Log_Type__c = 'User Insurance APD';
                                    camDataList.add(camData);
                                }
                            }
                        }
                        if(responseWrapper.content[0].Dealer_APD_Pending != null && responseWrapper.content[0].Dealer_APD_Pending.DealerRCPending != null){
                            for(IND_APDPendingResponse.DealerRCPending DealerInsObj : responseWrapper.content[0].Dealer_APD_Pending.DealerRCPending){
                                if(String.isNotBlank(DealerInsObj.Name)){
                                    External_CAM_Data__c camData = new External_CAM_Data__c();
                                    camData.CAM__c = camId;
                                    camData.Name__c = DealerInsObj.Name;
                                    camData.RecordTypeId = apdPendingId;
                                    camData.Document_Type__c = DealerInsObj.Doc_Type;
                                    camData.Below_30_Days__c = Integer.valueOf(DealerInsObj.Count_1_30);
                                    camData.X30_To_60_Days__c = Integer.valueOf(DealerInsObj.Count_31_60);
                                    camData.X60_To_90_Days__c = Integer.valueOf(DealerInsObj.Count_61_90);
                                    camData.Above_90_Days__c = Integer.valueOf(DealerInsObj.Count_Above_90);
                                    camData.Total_Pending__c = Integer.valueOf(DealerInsObj.Total_Count);
                                    // camData.Deposit_Available__c = DealerInsObj.Deposit_Avl;
                                    camData.Log_Type__c = 'Dealer RC APD';
                                    camDataList.add(camData);
                                }
                            }
                        }
                        if(responseWrapper.content[0].User_APD_Pending != null && responseWrapper.content[0].Dealer_APD_Pending.DealerInsurancePending != null){
                            for(IND_APDPendingResponse.DealerInsurancePending dealerInsObj : responseWrapper.content[0].Dealer_APD_Pending.DealerInsurancePending){
                                if(String.isNotBlank(dealerInsObj.Name)){
                                    External_CAM_Data__c camData = new External_CAM_Data__c();
                                    camData.CAM__c = camId;
                                    camData.Name__c = dealerInsObj.Name;
                                    camData.RecordTypeId = apdPendingId;
                                    camData.Document_Type__c = dealerInsObj.Doc_Type;
                                    camData.Below_30_Days__c = Integer.valueOf(dealerInsObj.Count_1_30);
                                    camData.X30_To_60_Days__c = Integer.valueOf(dealerInsObj.Count_31_60);
                                    camData.X60_To_90_Days__c = Integer.valueOf(dealerInsObj.Count_61_90);
                                    camData.Above_90_Days__c = Integer.valueOf(dealerInsObj.Count_Above_90);
                                    camData.Total_Pending__c = Integer.valueOf(dealerInsObj.Total_Count);
                                    camData.Deposit_Available__c = dealerInsObj.Deposit_Avl;
                                    camData.Log_Type__c = 'Dealer Insurance APD';
                                    camDataList.add(camData);
                                }
                            }
                        }
                    }
                }
                System.debug('overdueAccount ===>>> '+overdueAccount);
                if (camDataList.size() > 0) {
                    insert camDataList;
                    if(apiName == 'CAM Portfolio'){
                        List<CIBIL_Details__c> cibilList = new List<CIBIL_Details__c>();
                        cibilList = [SELECT Id, Other_Loan_AD__c, Term_Loan_AD__c, Other_Loan_PD__c, Term_Loan_PD__c, Overdue_Account__c FROM CIBIL_Details__c WHERE Applicant__c =: applicantId LIMIT 1];
                        if(cibilList.size()> 0){
                            if (accountType!=null) {
                                cibilList[0].Other_Loan_AD__c = accountType;
                            }
                            if (accountType!=null) {
                                cibilList[0].Other_Loan_PD__c = accountType;
                            }
                            if (accountTypeforADPD!=null) {
                                cibilList[0].Term_Loan_AD__c = accountTypeforADPD;
                            }
                            if (accountTypeforADPD!=null) {
                                cibilList[0].Term_Loan_PD__c = accountTypeforADPD;
                            }
                            if (overdueAccount!=null) {
                                cibilList[0].Overdue_Account__c = Integer.valueOf(overdueAccount); 
                            }
                            update cibilList;
                        }
                    }
                }
            }
        } catch(Exception e) {
            System.Debug('Exception ==> ' + e.getCause() + e.getLineNumber() + e.getMessage() );
            ErrorLoggerUtil.logErrorEvent('ExternalCAMDataController', 'storingExternalCAMData', e.getTypeName(), e, loanAppId);
        }
    }

    @AuraEnabled
    public static List<External_CAM_Data__c> getCAMPortfolioDetails(String loanAppId, String camId){
        try {
            if(camId!=null){
                List<External_CAM_Data__c> camDataList = new List<External_CAM_Data__c>();
                Id portfolioId = Schema.SObjectType.External_CAM_Data__c.getRecordTypeInfosByDeveloperName().get('Portfolio').getRecordTypeId();
                camDataList = [SELECT Id, Name__c, Year__c, Adv_Nos__c, Adv_Amt__c, NoDue_Nos__c, NoDue_LOS__c, STD1_Nos__c, STD1_LOS__c, STD2_Nos__c, STD2_LOS__c, STD3_Nos__c, STD3_LOS__c, NPA1_Nos__c, NPA1_LOS__c, NPA2_Nos__c, NPA2_LOS__c, NPA3_Nos__c, NPA3_LOS__c, NPAA_Nos__c, NPAA_LOS__c, Tot_Nos__c, Tot_LOS__c FROM External_CAM_Data__c WHERE CAM__c =:camId AND RecordTypeId =: portfolioId];
                return camDataList;
            }
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('ExternalCAMDataController', 'getCAMPortfolioDetails', e.getTypeName(), e, loanAppId);
        }
        return null;
    }
        
    @AuraEnabled
    public static List<External_CAM_Data__c> getAPDPendingDetails(String loanAppId, String camId){
        try {
            if(camId!=null){
                List<External_CAM_Data__c> camDataList = new List<External_CAM_Data__c>();
                Id apdPendingId = Schema.SObjectType.External_CAM_Data__c.getRecordTypeInfosByDeveloperName().get('APD_Pending').getRecordTypeId();
                camDataList = [SELECT Id, Name__c, Total_Pending__c, Below_30_Days__c, X30_To_60_Days__c, X60_To_90_Days__c, Above_90_Days__c, Log_Type__c, Document_Type__c, Deposit_Available__c FROM External_CAM_Data__c WHERE CAM__c =:camId AND RecordTypeId =: apdPendingId];
                return camDataList;
            }
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('ExternalCAMDataController', 'getAPDPendingDetails', e.getTypeName(), e, loanAppId);
        }
        return null;
    }

    @AuraEnabled
    public static cibilDataWrapper getCIBILExposureDetails(String loanAppId, String applicantId){
        try {
            if(applicantId!=null){
                cibilDataWrapper  wrapperObj = new cibilDataWrapper();
                List<External_CAM_Data__c> cibilExposureList = new List<External_CAM_Data__c>();
                List<External_CAM_Data__c> cibilEnquiryList = new List<External_CAM_Data__c>();
                Id cibilExposureId = Schema.SObjectType.External_CAM_Data__c.getRecordTypeInfosByDeveloperName().get('CIBIL_Exposure').getRecordTypeId();
                Id cibilEnquiryId = Schema.SObjectType.External_CAM_Data__c.getRecordTypeInfosByDeveloperName().get('CIBIL_Enquiry').getRecordTypeId();
                cibilExposureList = [SELECT Id, Name__c, Account_Type_Desc__c, Ownership__c, Open_Date__c, Last_Payment_Date__c, HighCredit__c, CurrentBalance__c, AmountOverdue__c, ReasonforOverdue__c FROM External_CAM_Data__c WHERE RecordTypeId =: cibilExposureId AND Applicant__c =: applicantId];
                wrapperObj.cIBILExposureContent = cibilExposureList.size() > 0 ? cibilExposureList : new List<External_CAM_Data__c>();
                cibilEnquiryList = [SELECT Id, CIC_No__c, Date_Of_Enquiry__c, Enquiring_Member__c, Enquiry_Amount__c FROM External_CAM_Data__c WHERE RecordTypeId =: cibilEnquiryId AND Applicant__c =: applicantId];
                
                wrapperObj.cIBILEnquiryContent = cibilEnquiryList.size() > 0 ? cibilEnquiryList : new List<External_CAM_Data__c>();
            }
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('ExternalCAMDataController', 'getCIBILExposureDetails', e.getTypeName(), e, loanAppId);
        }
        return null;
    }

    @AuraEnabled
    public static List<External_CAM_Data__c> getCIBILTimelineDetails(String loanAppId, String applicantId){
        try {
            if(applicantId!=null){
                List<External_CAM_Data__c> camDataList = new List<External_CAM_Data__c>();
                Id timelineId = Schema.SObjectType.External_CAM_Data__c.getRecordTypeInfosByDeveloperName().get('CIBIL_Time_Line').getRecordTypeId();
                camDataList = [SELECT Id, App_No__c, Date_Of_Enquiry__c, CIC_No__c, Customer_Type__c, Trend_Type__c, CIBIL_Detect_Decision__c, Inprinciple_Decision__c, Final_Decision__c, CIBIL_Score__c FROM External_CAM_Data__c WHERE Applicant__c =:applicantId AND RecordTypeId =: timelineId];
                return camDataList;
            }
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('ExternalCAMDataController', 'getCIBILTimelineDetails', e.getTypeName(), e, loanAppId);
        }
        return null;
    }

    /**********************************************
    * @Commented By:  Rajat Jaiswal
    * @UserStory:  Feature 8.2.18 - CAM Screen
    * @Purpose: This method is used to provide the kyc details to the IBLKYC cmp to render the files and details of applicant.
    ***********************************************/
    @AuraEnabled
    public static DocumentWrapper getKYCDetails(String applicationID) {
        try {
            if(applicationID!=null){
                DocumentWrapper wrapperObj = new DocumentWrapper();
                List<Documents__c> kycDocumentList = [SELECT Id, Opportunity_Relation__r.Loan_Application_Number__c,Name,Document_Type__c,Applicant__r.Name,Applicant__r.Applicant_Type__c,Applicant__r.Contact_number__c,KYC_Address_Line_1__c,KYC_Address_Line_2__c,Opportunity_Relation__r.Lead_number__c,Applicant__r.applicant_number__c,
                Document_Side__c,Age__c,KYC_DOB__c,PAN_No__c,KYC_name__c,KYC_No__c,KYC_Issuance_Date__c, Aadhaar_Enrollment_Number__c,Current_Residential_Address_Proof__c,Applicant__r.Current_Same_As_Permanent__c,KYC_Pin_Code__c, KYC_City__c,KYC_District__c, KYC_State__c,Permanent_Residential_Address_Proof__c,Proof_of_Address_POA__c,Proof_of_Identity_POI__c
                FROM Documents__c WHERE (RecordType.Name = 'KYC Document' OR Document_Type__c = :System.Label.Signature) AND Applicant__c=:applicationID AND is_Active__c = true AND Applicant__r.In_Active_Applicant__c = false];
                Set<Id> docmentKycIdSet = new Set<Id>();
                Map<String,List<String>> documentIdVsContentKycDocIdMap = new Map<String,List<String>>();
                Map<String,String> documentKycTypeVsFileIdMap = new Map<String,String>();
                for(Documents__c docObj :kycDocumentList){
                    docmentKycIdSet.add(docObj.Id);
                    if (docObj.Proof_of_Identity_POI__c) {
                        wrapperObj.natureAgeProof = docObj.Name;
                        wrapperObj.natureIdProof = docObj.Name;
                    }
                    if(wrapperObj.residentialAddress == null && docObj.Current_Residential_Address_Proof__c){
                        wrapperObj.otherResiProof = docObj.Name;
                        wrapperObj.natureResiProof = docObj.Name;
                        if(String.isNotEmpty(docObj.KYC_Address_Line_1__c)){
                            wrapperObj.residentialAddress = docObj.KYC_Address_Line_1__c+' ';
                        }
                        if(String.isNotEmpty(docObj.KYC_Address_Line_2__c)){
                            wrapperObj.residentialAddress += docObj.KYC_Address_Line_2__c+' ';
                        }
                        if(String.isNotEmpty(docObj.KYC_City__c)){
                            wrapperObj.residentialAddress += docObj.KYC_City__c+' ';
                        }
                        if(String.isNotEmpty(docObj.KYC_District__c)){
                            wrapperObj.residentialAddress += docObj.KYC_District__c+' ';
                        }
                        if(String.isNotEmpty(docObj.KYC_State__c)){
                            wrapperObj.residentialAddress += docObj.KYC_State__c+' ';
                        }
                        if(String.isNotEmpty(docObj.KYC_Pin_Code__c)){
                            wrapperObj.residentialAddress += docObj.KYC_Pin_Code__c+' ';
                        } 
                    }
                    if(wrapperObj.permanentAddress == null && (docObj.Applicant__r.Current_Same_As_Permanent__c || docObj.Permanent_Residential_Address_Proof__c)){

                        if(String.isNotEmpty(docObj.KYC_Address_Line_1__c)){
                            wrapperObj.permanentAddress = docObj.KYC_Address_Line_1__c+' ';
                        }
                        if(String.isNotEmpty(docObj.KYC_Address_Line_2__c)){
                            wrapperObj.permanentAddress += docObj.KYC_Address_Line_2__c+' ';
                        }
                        if(String.isNotEmpty(docObj.KYC_City__c)){
                            wrapperObj.permanentAddress += docObj.KYC_City__c+' ';
                        }
                        if(String.isNotEmpty(docObj.KYC_District__c)){
                            wrapperObj.permanentAddress += docObj.KYC_District__c+' ';
                        }
                        if(String.isNotEmpty(docObj.KYC_State__c)){
                            wrapperObj.permanentAddress += docObj.KYC_State__c+' ';
                        }
                        if(String.isNotEmpty(docObj.KYC_Pin_Code__c)){
                            wrapperObj.permanentAddress += docObj.KYC_Pin_Code__c+' ';
                        } 
                    }
                }

                if(docmentKycIdSet!=null && !kycDocumentList.isEmpty()){
                    List<ContentDocumentLink> contentDocLinkList = [SELECT LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN:docmentKycIdSet WITH SECURITY_ENFORCED LIMIT 10000];
                    Set<Id> contentDocIdSet = new Set<Id>();
                        for(ContentDocumentLink conLinkObj:contentDocLinkList){
                            if(!documentIdVsContentKycDocIdMap.containsKey(conLinkObj.LinkedEntityId)){
                                documentIdVsContentKycDocIdMap.put(conLinkObj.LinkedEntityId,new List<String>{conLinkObj.ContentDocumentId});
                            }else{
                                documentIdVsContentKycDocIdMap.get(conLinkObj.LinkedEntityId).add(conLinkObj.ContentDocumentId);
                            }
                            contentDocIdSet.add(conLinkObj.ContentDocumentId);
                        }
                    List<ContentVersion> contentVerList = [Select Id,ContentDocumentId,Document_Side_fileupload__c from ContentVersion where ContentDocumentId IN :contentDocIdSet and IsLatest=true WITH SECURITY_ENFORCED ORDER BY CreatedDate ASC LIMIT 10000];
                    for (Documents__c docObj : kycDocumentList) {
                        for(ContentVersion conDocObj:contentVerList){
                            if(documentIdVsContentKycDocIdMap.containsKey(docObj.Id)){
                                List<String> contentDocId = documentIdVsContentKycDocIdMap.get(docObj.Id);
                                if(contentDocId.contains(conDocObj.ContentDocumentId)){
                                    if(docObj.Document_Type__c == System.Label.Signature || docObj.Document_Type__c == System.label.CustomerImageDocumentType){
                                        documentKycTypeVsFileIdMap.put(docObj.Document_Type__c, conDocObj.Id);
                                    }else
                                    documentKycTypeVsFileIdMap.put(docObj.Document_Type__c+'-'+conDocObj.Document_Side_fileupload__c,conDocObj.Id);
                                }
                            }
                        }
                    }
                    wrapperObj.documentKycTypeVsFileIdMap = documentKycTypeVsFileIdMap;
                }
                wrapperObj.documentList = kycDocumentList;
                List<Income_Details__c> incomeDetailList = new List<Income_Details__c>();
                incomeDetailList = [Select Id, Office_Address_Line_1__c, Office_Address_Line_2__c,Applicant__c,Office_State__c, Office_District__c, Office_PinCode__c, Office_City__c from Income_Details__c WHERE Applicant__c =:applicationID];
                if (incomeDetailList.size() > 0) {
                    for (Income_Details__c incomeObj : incomeDetailList) {
                        if(String.isNotEmpty(incomeObj.Office_Address_Line_1__c)){
                            wrapperObj.officialAddress = incomeObj.Office_Address_Line_1__c+' ';
                        }
                        if(String.isNotEmpty(incomeObj.Office_Address_Line_2__c)){
                            wrapperObj.officialAddress += incomeObj.Office_Address_Line_2__c+' ';
                        }
                        if(String.isNotEmpty(incomeObj.Office_City__c)){
                            wrapperObj.officialAddress += incomeObj.Office_City__c+' ';
                        }
                        if(String.isNotEmpty(incomeObj.Office_District__c)){
                            wrapperObj.officialAddress += incomeObj.Office_District__c+' ';
                        }
                        if(String.isNotEmpty(incomeObj.Office_State__c)){
                            wrapperObj.officialAddress += incomeObj.Office_State__c+' ';
                        }
                        if(String.isNotEmpty(incomeObj.Office_PinCode__c)){
                            wrapperObj.officialAddress += incomeObj.Office_PinCode__c+' ';
                        }
                    }
                }
                return wrapperObj;
            } 
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('ExternalCAMDataController', 'getKYCDetails', e.getTypeName(), e, '');
        }
        return null;
    }
    
    /**********************************************
    * @Commented By:  Rajat Jaiswal
    * @UserStory:  Feature 8.2.18 - CAM Screen
    * @Purpose: This wrapper is used for IBLKYC cmp to show applicant details and documents.
    ***********************************************/
    public class DocumentWrapper{
        @auraenabled public List<Documents__c> documentList;
        @auraenabled public Map<String,String> documentKycTypeVsFileIdMap;
        @auraenabled public string residentialAddress;
        @auraenabled public string officialAddress;
        @auraenabled public string permanentAddress;
        @auraenabled public string otherResiProof;
        @auraenabled public string natureResiProof;
        @auraenabled public string natureAgeProof;
        @auraenabled public string natureIdProof;
    }

    public class cibilDataWrapper{
        @auraenabled public List<External_CAM_Data__c> cIBILExposureContent;
        @auraenabled public List<External_CAM_Data__c> cIBILEnquiryContent;
    }

    @AuraEnabled
    public static void storingCIBILDetails(String loanAppId, String apiResponse, String applicantId){
        try {
            if(apiResponse!=null){
                List<External_CAM_Data__c> camDataList = new List<External_CAM_Data__c>();
                System.debug('apiResponse: ' + apiResponse);
                IND_CIBILResponse.Data responseWrapper = (IND_CIBILResponse.Data)system.JSON.deserialize(apiResponse, IND_CIBILResponse.Data.class);
                System.debug('responseWrapper: ' + responseWrapper);
                if(responseWrapper != null && responseWrapper.Cibil_TimeLine_Details != null){
                    Id timelineId = Schema.SObjectType.External_CAM_Data__c.getRecordTypeInfosByDeveloperName().get('CIBIL_Time_Line').getRecordTypeId();
                    for(IND_CIBILResponse.Cibil_TimeLine_Details timelineObj  :responseWrapper.Cibil_TimeLine_Details){
                        External_CAM_Data__c camData = new External_CAM_Data__c();
                        camData.Applicant__c = applicantId;
                        camData.RecordTypeId = timelineId;
                        camData.App_No__c = timelineObj.Lead_Id;
                        if(String.isNotBlank(timelineObj.Date_Processed)){
                            camData.Date_Of_Enquiry__c = Date.parse(changeDateFormat((timelineObj.Date_Processed).split(' ')[0]));
                        }
                        camData.CIC_No__c = timelineObj.ADE_CIC_No;
                        camData.CIBIL_Score__c = Integer.valueOf(timelineObj.Score);
                        camData.Customer_Type__c = timelineObj.Customer_Role;
                        camData.Trend_Type__c = timelineObj.Arrow_Type;
                        camData.CIBIL_Detect_Decision__c = timelineObj.CIBIL_Detect_Decision;
                        camData.Inprinciple_Decision__c = timelineObj.Inprinciple_Decision;
                        camData.Final_Decision__c = timelineObj.Final_Decision;
                        camDataList.add(camData);
                    }
                }
                if(responseWrapper != null && responseWrapper.Cibil_LoanAccount_Details != null){
                    List<IND_CIBILResponse.Enquiry_Amount> enquiryDetails = new List<IND_CIBILResponse.Enquiry_Amount>();
                    Id cibilExposureId = Schema.SObjectType.External_CAM_Data__c.getRecordTypeInfosByDeveloperName().get('CIBIL_Exposure').getRecordTypeId();
                    for(IND_CIBILResponse.Cibil_LoanAccount_Details expObj  :responseWrapper.Cibil_LoanAccount_Details){
                        External_CAM_Data__c camData = new External_CAM_Data__c();
                        camData.Applicant__c = applicantId;
                        camData.RecordTypeId = cibilExposureId;
                        camData.Account_Type_Desc__c = expObj.Account_Type_Desc;
                        camData.Ownership__c = expObj.Ownership;
                        camData.HighCredit__c = Integer.valueOf(expObj.HighCredit);
                        camData.CurrentBalance__c = Integer.valueOf(expObj.CurrentBalance);
                        camData.AmountOverdue__c = Integer.valueOf(expObj.AmountOverdue);
                        camData.ReasonforOverdue__c = expObj.ReasonforOverdue;
                        camData.Name__c= expObj.FinanicerName;
                        if(String.isNotBlank(expObj.OpenDate)){
                            camData.Open_Date__c = Date.parse(changeDateFormat(expObj.OpenDate));
                        }
                        if(String.isNotBlank(expObj.LastPaymentDate)){
                            camData.Last_Payment_Date__c = Date.parse(changeDateFormat(expObj.LastPaymentDate));
                        }
                        enquiryDetails.add(expObj.Enquiry_Amount);
                        camDataList.add(camData);
                    }
                    if(enquiryDetails.size() > 0){
                        Id cibilEnquiryId = Schema.SObjectType.External_CAM_Data__c.getRecordTypeInfosByDeveloperName().get('CIBIL_Enquiry').getRecordTypeId();
                        for(IND_CIBILResponse.Enquiry_Amount expObj  :enquiryDetails){
                            External_CAM_Data__c camData = new External_CAM_Data__c();
                            camData.Applicant__c = applicantId;
                            camData.RecordTypeId = cibilEnquiryId;
                            camData.CIC_No__c = expObj.CIC_No;
                            if(String.isNotBlank(expObj.Date_Of_Enquiry)){
                                camData.Date_Of_Enquiry__c = Date.parse(changeDateFormat(expObj.Date_Of_Enquiry));
                            }
                            camData.Enquiring_Member__c = expObj.Enquiring_Member_ShortName;
                            camData.Enquiry_Amount__c = Integer.valueOf(expObj.Enquiry_Amount);
                            camDataList.add(camData);
                        }
                    }
                }       
                if (camDataList.size() > 0) {
                    insert camDataList;
                }
            }
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('ExternalCAMDataController', 'storingCIBILDetails', e.getTypeName(), e, loanAppId);
        }
    }
        

    @AuraEnabled
    public static List<Final_Term__c> getFinalTermsRecord(String finalTermId){
        try {
            if(finalTermId!=null){
                List<Final_Term__c> finaltermsList = new List<Final_Term__c>();  //CISP-131
                //CISP-4785 Added LeadSource in soql query
                finaltermsList = [SELECT id,OfferengineMinLoanAmount__c,Advance_EMI__c,OfferengineMaxLoanAmount__c,Loan_Application__r.Loan_amount__c,Loan_Amount__c,Net_IRR__c,Inputted_IRR__c,Loan_Application__r.Product_Type__c,Loan_Application__r.Total_Funded_Premium__c,Loan_Application__r.LeadSource,Service_charges__c,Documentation_charges__c,Stamping_charges__c,Due_date_shift_charges__c,RTO_prefix__c,Trade_certificate__c,Mfr_Exp_Reimburse_Amt__c,Mfr_Exp_Reimburse_percent__c,Mfr_Exp_Reimburse_Type__c,Dealer_incentive_amount_main_dealer__c,Dealer_Disc_to_Customer__c,Gift_through_dealer_amount__c,DSM_Incentive1__c,DSM_Incentive2__c,Refered_By__c,Rreferrer_Incentive__c,Referrer_Name__c,Provisional_Channel_Cost__c,DSA_pay__c,DSM_Name1__c,DSM_Name2__c,Emp_Name__c,Emp_No__c,EMI_Amount__c,Branch__c,Loan_Application__c,Loan_Application__r.Is_Revoked__c,Is_Loan_Amount_Change_From_CAM__c,Tenure__c,Loan_Application__r.Vehicle_Type__c FROM Final_Term__c WHERE Id = :finalTermId LIMIT 1];
                return finaltermsList;
            }
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('ExternalCAMDataController', 'getFinalTermsRecord', e.getTypeName(), e, '');
        }
        return null;
    }
    @AuraEnabled 
    public static String getApplicantId(String loanAppId){
        try {
            if(loanAppId!=null){
                List<Applicant__c> app = [SELECT Id FROM Applicant__c WHERE Opportunity__r.Id =: loanAppId]; 
                if(app != null && app.size() > 0){
                    return app[0].Id;
                }
            }
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('ExternalCAMDataController', 'getApplicantId', e.getTypeName(), e, '');
        }
        return null; 
    }

    public static String changeDateFormat(String DatetobeChanged){
        List<String> datetobeChangedList = DatetobeChanged.split('-');
        return datetobeChangedList[1] +'/' + datetobeChangedList[0] + '/' + datetobeChangedList[2];
    }
}