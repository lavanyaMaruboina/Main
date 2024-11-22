/**
* @Name         IND_GetFinalOfferWithoutSharing
* @Author       Rajat Jaiswal
* @Description  This Class is used for WITHOUT SHARING
**/
public without sharing class IND_GetFinalOfferWithoutSharing {
   /*
    * @Method Name: getParentApplicationFiCaseDetails
    * @Created by:     Rajat Jaiswal
    * @Description: 
    * @Input:  String - loanId
    * @Return:  String
    */
    @AuraEnabled
    public static String getParentApplicationFiCaseDetails(String loanAppId) {
        String parentleadType = '';
        try {
            if (loanAppId!=null) {
                List<Opportunity> loanAppList = new List<Opportunity>();
                loanAppList = [SELECT Id, Name, Parent_Loan_Application__c, Parent_Loan_Application__r.Name, Parent_Loan_Application__r.StageName, Parent_Loan_Application__r.Is_Revoked__c, Product_Type__C FROM Opportunity WHERE Id =: loanAppId AND Parent_Loan_Application__c!=null LIMIT 1];
                if (loanAppList.size() > 0) {
                    String currentLoanAppNumber = loanAppList[0].Name;
                    String existingLoanAppNumber = loanAppList[0].Parent_Loan_Application__r.Name;
                    String existingLoanAppId = loanAppList[0].Parent_Loan_Application__c;
                    List<Case> fiCaseList = new List<Case>();
                    List<Case> currentFiCaseList = new List<Case>();
                    currentFiCaseList = [SELECT Id, Subject, Status, RecordType.Name, Applicant__c, Applicant__r.Applicant_Type__c FROM Case WHERE Loan_Application__c =: loanAppId AND RecordType.Name = 'FI'];
                    List<Field_Investigation__c> fieldInvestigationList = new List<Field_Investigation__c>();
                    fiCaseList = [SELECT Id, Subject, Status, RecordType.Name, Applicant__c, Applicant__r.Applicant_Type__c FROM Case WHERE Loan_Application__c =: existingLoanAppId AND RecordType.Name = 'FI' AND RejectedFI__c = false];
                    Set<Id> fiCaseIdSet = new Set<Id>();
                    Set<Id> applicantIdSet = new Set<Id>();
                    List<parentFICaseWrapper> parentFICaseList = new List<parentFICaseWrapper>();
                    if (fiCaseList.size() > 0) {
                        for (Case caseObj : fiCaseList) {
                            fiCaseIdSet.add(caseObj.Id);
                            applicantIdSet.add(caseObj.Applicant__c);
                        }
                        List<CaseHistory> caseHistoryList = [SELECT Id, OldValue, NewValue, CaseId FROM CaseHistory WHERE CaseId IN: fiCaseIdSet];
                        Map<Id, Boolean> caseIdVsFIcaseCompletedMap = new Map<Id, Boolean>();
                        if(caseHistoryList.size() > 0){
                            for (CaseHistory casehisObj : caseHistoryList) {
                                if(!caseIdVsFIcaseCompletedMap.containsKey(casehisObj.CaseId)){
                                    if(casehisObj.OldValue =='Completed' || casehisObj.OldValue =='Accepted' || casehisObj.NewValue =='Completed' || casehisObj.NewValue =='Accepted'){
                                        caseIdVsFIcaseCompletedMap.put(casehisObj.CaseId, true);
                                    }
                                }
                            }
                        }
                        fieldInvestigationList = [SELECT Id, Name, Case__c, RecordType.Name, Case__r.Applicant__c, Case__r.Applicant__r.Applicant_Type__c, Case__r.Status, Case__r.Type FROM Field_Investigation__c WHERE Case__c IN: fiCaseIdSet];
                        
                        parentFICaseWrapper parentFICaseObj = new parentFICaseWrapper();
                        parentFICaseObj.parentLoanAppId = existingLoanAppId;
                        parentFICaseObj.parentLoanAppName = existingLoanAppNumber;
                        parentFICaseObj.productType = loanAppList[0].Product_Type__C;
                        parentFICaseObj.casePresent = currentFiCaseList.size() > 0 ? true : false;
                        if (fieldInvestigationList.size() > 0) {
                            for (Field_Investigation__c fiCaseObj : fieldInvestigationList) {
                                if (fiCaseObj.RecordType.Name == 'Residence') {
                                    parentFICaseObj.currentResidenceName = fiCaseObj.Case__r.Type;
                                    if(fiCaseObj.Case__r.Applicant__r.Applicant_Type__c == 'Borrower'){
                                        parentFICaseObj.bo_CaseResiStatus = caseIdVsFIcaseCompletedMap.containsKey(fiCaseObj.Case__c) ? 'Completed' : 'Not completed';
                                    }else if(fiCaseObj.Case__r.Applicant__r.Applicant_Type__c == 'Co-borrower'){
                                        parentFICaseObj.CB_CaseResiStatus = caseIdVsFIcaseCompletedMap.containsKey(fiCaseObj.Case__c) ? 'Completed' : 'Not completed';
                                        parentFICaseObj.coborrowerPresent = true;
                                    }
                                }
                                if (fiCaseObj.RecordType.Name == 'Permanent') {
                                    parentFICaseObj.casePermanentName = fiCaseObj.Case__r.Type;
                                    if(fiCaseObj.Case__r.Applicant__r.Applicant_Type__c == 'Borrower'){
                                        parentFICaseObj.bo_CasePerStatus = caseIdVsFIcaseCompletedMap.containsKey(fiCaseObj.Case__c) ? 'Completed' : 'Not completed';
                                    }else if(fiCaseObj.Case__r.Applicant__r.Applicant_Type__c == 'Co-borrower'){
                                        parentFICaseObj.CB_CasePerStatus = caseIdVsFIcaseCompletedMap.containsKey(fiCaseObj.Case__c) ? 'Completed' : 'Not completed';
                                        parentFICaseObj.coborrowerPresent = true;
                                    }
                                }
                                if (fiCaseObj.RecordType.Name == 'Office') {
                                    parentFICaseObj.caseOfficeName = fiCaseObj.Case__r.Type;
                                    if(fiCaseObj.Case__r.Applicant__r.Applicant_Type__c == 'Borrower'){
                                        parentFICaseObj.bo_CaseOffStatus = caseIdVsFIcaseCompletedMap.containsKey(fiCaseObj.Case__c) ? 'Completed' : 'Not completed';
                                    }else if(fiCaseObj.Case__r.Applicant__r.Applicant_Type__c == 'Co-borrower'){
                                        parentFICaseObj.CB_CaseOffStatus = caseIdVsFIcaseCompletedMap.containsKey(fiCaseObj.Case__c) ? 'Completed' : 'Not completed';
                                        parentFICaseObj.coborrowerPresent = true;
                                    }
                                }
                                
                            }
                            if (currentLoanAppNumber.contains('-A') && currentLoanAppNumber.contains('_C')){
                                parentFICaseObj.leadType = 'Revoked and Restart';
                            }else if(currentLoanAppNumber.contains('_C')){
                                parentFICaseObj.leadType = 'Restart';
                            }else if(currentLoanAppNumber.contains('-A')){
                                parentFICaseObj.leadType = 'Revoked';
                            }
                        }
                        parentFICaseList.add(parentFICaseObj);
                        if(parentFICaseList.size() > 0){
                            parentleadType = JSON.serialize(parentFICaseObj);
                        }
                    }
                    if(parentFICaseList.isEmpty()){
                        parentleadType = 'FI case not found';
                    }
                }else{
                    parentleadType = 'Existing lead not found';
                }
            }
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_GetFinalOfferWithoutSharing', 'getParentApplicationFiCaseDetails', e.getTypeName(), e, loanAppId);
        }
        return parentleadType;
    }

        /*
    * @Method Name: cloneParentFICasetoChildApplication
    * @Created by:     Rajat Jaiswal
    * @Description: 
    * @Input:  String - loanId
    * @Return:  String
    */
    @AuraEnabled
    public static String cloneParentFICasetoChildApplication(String loanAppId, String parentLeadData) {
        String cloneFIcase = '';
        try {
            if (loanAppId!=null) {
                List<Case> newFICaseList = new List<Case>();
                List<Case> existingFICaseList = new List<Case>();
                List<Opportunity> loanAppList = new List<Opportunity>();
                loanAppList = [SELECT Id, Name, Parent_Loan_Application__c, Parent_Loan_Application__r.Name, Parent_Loan_Application__r.StageName, Parent_Loan_Application__r.Is_Revoked__c, Product_Type__c, AccountId, OwnerId FROM Opportunity WHERE Id =: loanAppId AND Parent_Loan_Application__c!=null LIMIT 1];
                if(loanAppList.size()>0){
                String parentLoanAppId = loanAppList[0].Parent_Loan_Application__c;
                Map<String, Applicant__c> applicantTypeVsApplicantMap = new Map<String, Applicant__c>();
                for(Applicant__c appObj : [SELECT Id, Applicant_Type__c FROM Applicant__c WHERE Opportunity__c = :loanAppId AND In_Active_Applicant__c = False ]){
                    applicantTypeVsApplicantMap.put(appObj.Applicant_Type__c, appObj);
                }
                parentFICaseWrapper responseWrapper = (parentFICaseWrapper)system.JSON.deserialize(parentLeadData, parentFICaseWrapper.class);
                Set<Id> existingCloneCaseId = new Set<Id>();
                existingFICaseList = [SELECT Id, Subject, Status, Type, RecordTypeId, RecordType.Name, Applicant__c, Applicant__r.Applicant_Type__c,(Select Id,Document_Type__c From Documents__r) FROM Case WHERE Loan_Application__c =: parentLoanAppId AND RecordType.Name = 'FI' AND RejectedFI__c = false];

                if(existingFICaseList.size() > 0){
                    List<Case> currentFiCaseList = new List<Case>();
                    currentFiCaseList = [SELECT Id, Subject, Status, RecordType.Name,Type, Applicant__c, Applicant__r.Applicant_Type__c FROM Case WHERE Loan_Application__c =: loanAppId AND RecordType.Name = 'FI'];
                    Map<String , List<Case>> currentCaseTypeVsCaseMap = new Map<String , List<Case>>();
                    if(currentFiCaseList.size() > 0){
                        for (Case caseObj : currentFiCaseList) {
                            if(!currentCaseTypeVsCaseMap.containsKey(caseObj.Type)){
                                currentCaseTypeVsCaseMap.put(caseObj.Type, new List<Case>{caseObj});
                            }else{
                                currentCaseTypeVsCaseMap.get(caseObj.Type).add(caseObj);
                            }
                        }
                    }
                    Set<Id> fiCaseIdSet = new Set<Id>();
                    List<Documents__c> fiCaseDocList = new List<Documents__c>();
                    for (Case caseObj : existingFICaseList) {
                        fiCaseIdSet.add(caseObj.Id);
                        
                    }
                    List<CaseHistory> caseHistoryList = [SELECT Id, OldValue, NewValue, CaseId FROM CaseHistory WHERE CaseId IN: fiCaseIdSet];
                    Map<Id, Boolean> caseIdVsFIcaseCompletedMap = new Map<Id, Boolean>();
                    if(caseHistoryList.size() > 0){
                        for (CaseHistory casehisObj : caseHistoryList) {
                            if(!caseIdVsFIcaseCompletedMap.containsKey(casehisObj.CaseId)){
                                if(casehisObj.NewValue =='Completed' || casehisObj.NewValue =='Accepted' || casehisObj.OldValue == 'Completed' || casehisObj.OldValue =='Accepted'){
                                    caseIdVsFIcaseCompletedMap.put(casehisObj.CaseId, true);
                                }
                            }
                        }
                    }
                    for (Case caseObj : existingFICaseList) {
                        Boolean createNewCase = true;
                        if(caseIdVsFIcaseCompletedMap.containsKey(caseObj.Id) && !currentCaseTypeVsCaseMap.isEmpty() && currentCaseTypeVsCaseMap.containsKey(caseObj.Type)){
                            for (Case currentCaseObj : currentCaseTypeVsCaseMap.get(caseObj.Type)) {
                                if(caseObj.Applicant__r.Applicant_Type__c == currentCaseObj.Applicant__r.Applicant_Type__c){
                                    createNewCase = false;
                                }
                            }
                        }
                        if((currentCaseTypeVsCaseMap.isEmpty() || createNewCase) && caseIdVsFIcaseCompletedMap.containsKey(caseObj.Id)){
                            existingCloneCaseId.add(caseObj.Id);
                            fiCaseDocList.addAll(caseObj.Documents__r);
                            Case newCase = caseObj.clone(false,false,false,false);
                            newCase.OwnerId = loanAppList[0].OwnerId;
                            newCase.Loan_Application__c = loanAppList[0].Id;
                            newCase.Status = 'Completed';
                            newCase.Subject = loanAppList[0].Name +'_'+ caseObj.Type +'_'+ caseObj.Applicant__r.Applicant_Type__c;
                            newCase.Applicant__c = applicantTypeVsApplicantMap.get(caseObj.Applicant__r.Applicant_Type__c).Id;
                            newCase.AccountId = loanAppList[0].AccountId;
                            newFICaseList.add(newCase);
                        }
                    }
                    if(Case.SObjectType.getDescribe().isCreateable() && newFICaseList.size() > 0){
                        insert newFICaseList;
                    }
                    if (newFICaseList.size() > 0) {
                        Map<String , List<Case>> caseTypeVsCaseMap = new Map<String , List<Case>>();
                        for (Case caseObj : newFICaseList) {
                            if(!caseTypeVsCaseMap.containsKey(caseObj.Type)){
                                caseTypeVsCaseMap.put(caseObj.Type, new List<Case>{caseObj});
                            }else{
                                caseTypeVsCaseMap.get(caseObj.Type).add(caseObj);
                            }
                        }
                        List<Field_Investigation__c> fieldInvestigationList = new List<Field_Investigation__c>();
                        List<Field_Investigation__c> newFieldInvestigationList = new List<Field_Investigation__c>();

                        fieldInvestigationList = [SELECT Id, Name, RecordType.Name, Case__r.Applicant__c, Case__r.Applicant__r.Applicant_Type__c, Case__r.Status, Case__r.Type, RecordTypeId, Case__c, Address_Verified_with_KYC__c, Color_Code__c, Address_Line_1__c, Address_Line_2__c, Affiliation_to_e_commerce__c, Annual_Turnover__c, Are_Co_ordinates_Matching_If_Amber__c, Area__c, Average_Professional_Fee_Service_Rs__c, Average_Ticket_Size_Rs__c, Average_no_of_customers__c, Business_Premise__c, Category__c, City__c, AC_Installed__c, Current_experience_years__c, Customer_house_same_as_in_application__c, Declared_Income_During_Application__c, Employer_Business_Name__c, Estimated_Average_Income_per_month__c, Estimated_Income_as_per_FI__c, Estimated_Service_FI__c, Estimated_Service_Income_as_per_FI__c, Estimated_Total_Monthly_Income__c, FI_Feedback__c, FI_Location__Latitude__s, FI_Location__Longitude__s, FI_Location__c, is_Active__c, FI_Request_Generation_Date_Time__c, Final_Income__c, GeoCoder_Latitude_and_Longitude__Latitude__s, GeoCoder_Latitude_and_Longitude__Longitude__s, GeoCoder_Latitude_and_Longitude__c, Income__c, Income_as_per_FI_Visit__c, Income_per_month__c, Income_per_month_property__c, Inhouse_Security_Camera_present__c, Irrigation_system_present__c, KYC_Location__Latitude__s, KYC_Location__Longitude__s, KYC_Location__c, Land_Photo__c, Landmark__c, Latest_Electricity_Bill_Amount_Paid_Mont__c, Latest_Telephone_Bill_Amount_Paid_Month__c, Latest_Water_Bill__c, List_of_equipment_tools_owned__c, Location__c, Mobile__c, Monthly_Income_as_per_FI_Visit__c, Monthly_Sales__c, Name_of_Person_met__c, No_of_Attempts__c, No_of_Cattle__c, No_of_Service_Requests_catered_in_month__c, No_of_contracts_awarded_in_last_1_year__c, No_of_crops_per_annum__c, No_of_vehicles_owned__c, Number_of_Properties_rented__c, Number_of_operational_hours_in_a_day__c, Office_FI_Accepted_Rejected__c, Office_FI_Completion_Time__c, Own_Equipment_Tools__c, Access_to_Tubewells__c, Patta_Document_available__c, Applicant_Recognized__c, Phone_Number__c, Pin_Code__c, Political_Photo__c, Price_per_unit__c, Product__c, Profile__c, Profit_Margin__c, Coordinates_Verified__c, Remarks__c, Residence_FI_Status__c, Residence_FI_completion_time__c, Same_Addresst_as_in_the_Application__c, State__c, Do_you_have_any_government_contracts__c, Type_of_House__c, Type_of_goods_sold__c, Upload_Pension_Document__c, Upload_Rent_Agreement_Reciept__c, Yield_Per_Acre_monthly__c, Coordinates_Distance__c, FI_Observation__c, FI_Status__c, No_of_2_Wheelers__c, No_of_3_Wheelers__c, No_of_4_Wheelers__c, No_of_ACs__c, No_of_CVs__c, No_of_Computers__c, No_of_Fridges__c, No_of_Sofas__c, No_of_TVs__c, No_of_Washing_Machines__c, Number_of_Dependent__c, Number_of_Earning_Member_in_Family__c, Office_FI_Status__c, Profile_to_Product_Match__c, Purpose_of_Purchase__c, Relationship__c, Residence_Type__c, SENP_Agriculture_Income__c, SENP_Contractor_Income__c, SENP_Own_Shop_Income__c, SENP_Pension_Income__c, SENP_Rental_Income__c, SENP_Service_oriented_Income__c, SENP_Transporter_Income__c, Years_in_CIty__c, Years_in_Residence__c, POS_Machine__c, Payment_Proof_Shown__c, Type_of_Crop__c, Payment_Proof_shown_for_Electricity_Bill__c, Telephone_Bill_Payment_Proof_Shown__c, Electricity_Connection_Present__c, No_of_Employees__c, Office_Business_Board__c, Office_Business_Size_Sqft__c, Office_Business_Type__c, Total_Experience_Years__c, Touring_or_Transferable_Job__c, Types_of_vehicles_owned__c FROM Field_Investigation__c WHERE Case__c IN: existingCloneCaseId];

                        if (fieldInvestigationList.size() > 0) {
                            for (Field_Investigation__c fIObj : fieldInvestigationList) {
                                Field_Investigation__c newFI = fIObj.clone(false,false,false,false);
                                if(caseTypeVsCaseMap.containsKey(fIObj.Case__r.Type)){
                                    for(Case newCaseObj : caseTypeVsCaseMap.get(fIObj.Case__r.Type)){
                                        if(fIObj.Case__r.Applicant__r.Applicant_Type__c == newCaseObj.Applicant__r.Applicant_Type__c){
                                            newFI.Case__c = newCaseObj.Id;
                                        }
                                    }
                                    newFieldInvestigationList.add(newFI);
                                }
                            }
                            if(Field_Investigation__c.SObjectType.getDescribe().isCreateable() && newFieldInvestigationList.size() > 0){
                                insert newFieldInvestigationList;
                            }
                        }
                        if(fiCaseDocList.size() > 0){
                            Set<Id> fiCaseDocIdSet = new Set<Id>();
                            for (Documents__c docObj : fiCaseDocList) {
                                fiCaseDocIdSet.add(docObj.Id);
                            }
                            Map<Id,Documents__c> existingDocumentMap = new Map<Id,Documents__c>([
                                SELECT Id,Salutation__c,First_Name__c,Last_Name__c,Name, Document_Type__c,RecordTypeId,Case__c,Is_Active__c,Applicant__c,Applicant__r.Applicant_Type__c,Case__r.Type,Case__r.Applicant__r.Applicant_Type__c FROM Documents__c WHERE Opportunity_Relation__c =: parentLoanAppId AND Is_Active__c = true AND Id IN : fiCaseDocIdSet AND Applicant__r.In_Active_Applicant__c = false ORDER BY Case__c]);
                
                            Map<Id,Documents__c> newDocumentMap = new Map<Id,Documents__c>();
                            for(Documents__c document : existingDocumentMap.values()){
                                if(caseTypeVsCaseMap.containsKey(document.Case__r.Type)){
                                    Documents__c newDocument = document.clone(false,false,false,false);
                                    newDocument.Opportunity_Relation__c = loanAppId;
                                    newDocument.Applicant__c = applicantTypeVsApplicantMap.containskey(document.Applicant__r.Applicant_Type__c) ? applicantTypeVsApplicantMap.get(document.Applicant__r.Applicant_Type__c).Id : document.Applicant__c;
                                    for(Case newCaseObj : caseTypeVsCaseMap.get(document.Case__r.Type)){
                                        if(document.Case__r.Applicant__r.Applicant_Type__c == newCaseObj.Applicant__r.Applicant_Type__c){
                                            newDocument.Case__c = newCaseObj.Id;
                                        }
                                    }
                                    newDocumentMap.put(document.Id,newDocument);
                                }
                            }
                
                            if(Documents__c.SObjectType.getDescribe().isCreateable()){
                                insert newDocumentMap.values();
                            }
                
                            List<ContentDocumentLink> contentDocList = new List<ContentDocumentLink>();
                            if(existingDocumentMap.keySet().size() > 0 && newDocumentMap.keySet().size() > 0){
                                for(ContentDocumentLink contDocLink : [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN : existingDocumentMap.keySet()]){
                                    if(newDocumentMap.containskey(contDocLink.LinkedEntityId)){
                                        ContentDocumentLink newContDocLink = new ContentDocumentLink();
                                        newContDocLink.ContentDocumentId = contDocLink.ContentDocumentId;
                                        newContDocLink.LinkedEntityId = newDocumentMap.get(contDocLink.LinkedEntityId).Id;
                                        contentDocList.add(newContDocLink);
                                    }
                                }
                            }
                
                            if(ContentDocumentLink.SObjectType.getDescribe().isCreateable() && contentDocList.size() > 0){
                                insert contentDocList;
                            }
                        }
                        cloneFIcase = JSON.serialize(newFieldInvestigationList);
                    }
                }
                }
            }
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_GetFinalOfferWithoutSharing', 'cloneParentFICasetoChildApplication', e.getTypeName(), e, loanAppId);
        }
        return cloneFIcase;
    }

    public class parentFICaseWrapper{
        @AuraEnabled public String applicantId;
        @AuraEnabled public String productType;
        @AuraEnabled public String parentLoanAppId;
        @AuraEnabled public String parentLoanAppName;
        @AuraEnabled public String leadType;
        @AuraEnabled public String currentResidenceName;
        @AuraEnabled public String bo_CaseResiStatus;
        @AuraEnabled public String CB_CaseResiStatus;
        @AuraEnabled public String casePermanentName;
        @AuraEnabled public String bo_CasePerStatus;
        @AuraEnabled public String CB_CasePerStatus;
        @AuraEnabled public String caseOfficeName;
        @AuraEnabled public String bo_CaseOffStatus;
        @AuraEnabled public String CB_CaseOffStatus;
        @AuraEnabled public Boolean coborrowerPresent;
        @AuraEnabled public Boolean casePresent;
    }
}