/*------------------------------------------------------------
Author:        Gaurav Rawat
Company:       Manras
Description:   
Apex Class :   IND_RevokeController
Test Class:    
History 
Date            Author              Comments
-------------------------------------------------------------
21/07/2022     Gaurav Rawat       Initial Creation
------------------------------------------------------------*/
public without sharing class IND_RevokeController {
public static String ownerId = ''; 
public static Opportunity oppObj{get;set;}
public static List<ContentDocumentLink> globalContentDocList{get;set;}
public static CustomNotificationType globalNotificationType{get;set;}
    
    @AuraEnabled
    public static string loanApplicationRevoke(String loanApplicationId, String revokeType, String newOwnerId, List<Id> documentId){
        try {
            IND_RevokeController.ownerId = String.isNotBlank(newOwnerId) ? newOwnerId : ''; //CISP-4628
            String returnedWrapperObj;
            globalContentDocList = new List<ContentDocumentLink>();
            globalNotificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'Notification_to_Onwer' LIMIT 1];
            oppObj=[Select Id,Payment_Request_Generation_Date__c,Hunter_Match_Status__c,Hunter_APS_Response__c,Loan_Created_Date__c,Createddate,LeadSource,IModuleId__c,Vehicle_Verified__c, Name, Loan_amount__c, Product_Type__c, Vehicle_Sub_Category__c, Vehicle_Type__c, Required_Loan_amount__c, Required_Tenure__c, Required_ROI__c, Funding_on_Ex_Showroom__c, Funding_on_ORP__c, Is_customer_interested_in_a_motor_insura__c, Funded__c, Non_Funded__c, X1st_yr_Insurance_Premium__c, Motor_Insurance_Premium__c, Basic_Price__c, GST_Amount__c, Discount_on_Basic_Price__c, Ex_showroom_price__c, Ex_showroom_price_carwale__c,RTO_Road_Tax_New__c,RTO_Road_Tax__c, Other_charges__c, On_Road_price__c, On_Road_price_carwale__c, Final_Price__c, PartnerAccountId,AccountId,StageName,LastStageName__c,CloseDate,OwnerId, Lead_Number__c, Agent_BL_code__c, Gender__c, Parent_Deal_number__c,Deal_Number__c,Revoke_Parent_Deal_Number__c,Registration_Number_Format__c,Vehicle_Registration_Number__c,Customer_Code__c, NOC_Number__c,Vehicle_Proceed_Flag__c,Application_number__c,CreatedById,Sub_Stage__c,Applicant_Name__c,Is_Revoked__c,Revoked_Applicant_Count__c,Is_Customer_Dedupe_Submit__c,PreviousAccountId__c,Application_Type__c,Customer_Type__c,Class_of_Activity__c,Entity_Type__c,Entity_Name__c,Entity_Code__c,Entity_Category__c,Employee_No__c,Employee_Name__c,Employee_Branch__c,Loan_Type__c,Major_Industry__c,Profile__c,Date_of_Incorporation__c,Contact_Person_Name__c,Lead_Source_Non_Ind__c,Evaluation_Type__c,Minor_Industry__c,isTopUpLoan__c From Opportunity Where Id=:loanApplicationId LIMIT 1];
            if(oppObj.Payment_Request_Generation_Date__c != null){
                throw new IND_Exception('Payment request is already generated for this lead. You can not revoke this lead.');
            }
            if(oppObj.Is_Revoked__c== false) //CISP:3530
            {
                if(revokeType.equalsIgnoreCase('General Revoke')){
                    returnedWrapperObj = IND_RevokeController.generalRevoke(loanApplicationId,revokeType);
                }else if(revokeType.equalsIgnoreCase('Add/Change Co-Borrower')){
                    returnedWrapperObj = IND_RevokeController.addCoBorrowerRevoke(loanApplicationId,revokeType);
                } 
                /* CISP-6999 */
                
                else if(revokeType.equalsIgnoreCase('payandpayoutchanges')){//SFTRAC-166
                    returnedWrapperObj = IND_RevokeController.payandpayoutchangesRevoke(loanApplicationId,revokeType, documentId);
                }
                else if(revokeType.equalsIgnoreCase('removecoborroweraddcoborrower')){
                    returnedWrapperObj = IND_RevokeController.removecoborroweraddcoborrowerRevoke(loanApplicationId,revokeType, documentId);
                }
                else if(revokeType.equalsIgnoreCase('removecoborroweraddcoborrowerbypeuser')){
                    returnedWrapperObj = IND_RevokeController.removecoborroweraddcoborrowerRevokeByPEUser(loanApplicationId,revokeType, documentId);
                }//SFTRAC-2277
                else if(revokeType.equalsIgnoreCase('assetmodifications')){
                    returnedWrapperObj = IND_RevokeController.payandpayoutchangesRevoke(loanApplicationId,revokeType, documentId);
                }
                else if(revokeType.equalsIgnoreCase('anyloaninformationchanges')){
                    if(oppObj.Sub_Stage__c == 'View Application Details' || oppObj.Sub_Stage__c == 'CIBIL'){
                        throw new IND_Exception('Please select valid option!');
                    }else{
                        returnedWrapperObj = IND_RevokeController.anyloaninformationchangesRevoke(loanApplicationId,revokeType);
                    }
                }//SFTRAC-166 end

                if(ContentDocumentLink.SObjectType.getDescribe().isCreateable() && globalContentDocList.size() > 0){
                    insert globalContentDocList;
                }
            }else{
                throw new IND_Exception('This lead is already revoke. You can not revoke again.');
            }
            
            return returnedWrapperObj;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_RevokeController', 'loanApplicationRevoke', System.Label.Apex, e, loanApplicationId);
            throw new IND_Exception(e.getMessage());
        }
    }
    //CISP-3116-START
    @AuraEnabled
    public static void cloneCibil(String oldLoanApplicationId, String newLoanApplicationId, Map<Id,Applicant__c> newApplicantMap){
        try {
            if (oldLoanApplicationId != null && newLoanApplicationId != null) {
                List<CIBIL_Details__c> cibilList = new List<CIBIL_Details__c>([Select id,Amount_Overdue__c,Cibil_Decision__c,CIBIL_Report_URl__c,CIC_No__c,CRIF_Score_Desc__c,Current_Balance__c,Entity_Type__c,Equifax_Report_URl__c,HighCredit_Or_SanctionedAmount__c,Month_Overdue__c,NoOfEnLtSixMon__c,Oldest_Date__c,Recent_Date__c,Score__c,SuitFiledOrWilfulDefault__c,Type__c,WrittenoffAmountTotal__c,Maker_Date__c,Applicant__r.Applicant_Type__c,CIBIL_Pull_Date__c From CIBIL_Details__c Where Applicant__c IN : newApplicantMap.keySet() LIMIT 100]);

                if (cibilList.size() > 0) {
                    List<CIBIL_Details__c> newCibilList = new List<CIBIL_Details__c>();
                    for(CIBIL_Details__c cibilRecord : cibilList){
                        if(newApplicantMap.containskey(cibilRecord.Applicant__c)){
                            CIBIL_Details__c newCibilRecord = cibilRecord.clone(false, false, false, false);
                            newCibilRecord.Applicant__c = newApplicantMap.get(cibilRecord.Applicant__c).Id;
                            newCibilList.add(newCibilRecord);
                        }
                    }

                    if(newCibilList.size() > 0 && CIBIL_Details__c.SObjectType.getDescribe().isCreateable()){
                        insert newCibilList;
                    }
                }
            }
            
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_RevokeController', 'cloneCibil', System.Label.Apex, e, oldLoanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    @AuraEnabled
    public static List<RCUDocumentsWrapper> getRCUDocumentsList(String loanApplicationId){
        try{
           if(!String.isEmpty(loanApplicationId)){
            Map<Id, Documents__c> rcuDocumentMap = new Map<Id, Documents__c>([SELECT Id,Name,Document_Type__c,Applicant_Type__c,RCU_Case__r.Loan_Application__c,RCU_Case__r.Loan_Application__r.Product_Type__c,RCU_Case__r.RecordType.Name,RCU_Case__c,RecordType.Name From Documents__c where RCU_Case__r.Loan_Application__c =:loanApplicationId AND Case__c = null AND RCU_Case__r.RecordType.Name = 'RCU' AND RecordType.DeveloperName!='KYC' And Is_Active__c=true LIMIT 50000]);
                List<RCUDocumentsWrapper> rcuDocumentsWrapperList = new List<RCUDocumentsWrapper>();
                if(!rcuDocumentMap.isEmpty()){
                for(ContentDocumentLink contentDoc : [SELECT Id,LinkedEntityId,ContentDocumentId,ContentDocument.FileType,ContentDocument.LatestPublishedVersionId FROM ContentDocumentLink WHERE LinkedEntityId =: rcuDocumentMap.keySet() LIMIT 50000]){
                        RCUDocumentsWrapper rcuDocument = new RCUDocumentsWrapper();
                        rcuDocument.loanApplicationId = loanApplicationId;
                        rcuDocument.documentId = contentDoc.LinkedEntityId;
                        rcuDocument.applicantType = rcuDocumentMap.get(contentDoc.LinkedEntityId).Applicant_Type__c;
                        rcuDocument.documentType = rcuDocumentMap.get(contentDoc.LinkedEntityId).Document_Type__c;
                        rcuDocument.contentDocumentId = contentDoc.ContentDocumentId;
                        rcuDocument.documentName = rcuDocumentMap.get(contentDoc.LinkedEntityId).Name;
                        rcuDocument.contentVersionId = contentDoc.ContentDocument.LatestPublishedVersionId;
                        rcuDocumentsWrapperList.add(rcuDocument);
                    }
                }
                
                if(!rcuDocumentsWrapperList.isEmpty())
                    return rcuDocumentsWrapperList;
            }
            return null;
        }
        catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_RevokeController', 'getRCUDocumentsList', System.Label.Apex, e, loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }  
        
    }
    
    
    @AuraEnabled
    public static String generalRevoke(String loanApplicationId,String revokeType){
        try{
            ReturnedWrapper returnedWrapperObj = new ReturnedWrapper();
            // Clone Loan Application
            String loanApplicationCloneId = IND_RevokeController.cloneLoanApplication(loanApplicationId,revokeType);
            returnedWrapperObj.clonedLoanApplicationId = loanApplicationCloneId;
            
            // Clone Applicants
            ApplicantReturnedWrapper applicantWrapperObj = (ApplicantReturnedWrapper) JSON.deserialize(IND_RevokeController.cloneApplicant(loanApplicationId, loanApplicationCloneId,revokeType), ApplicantReturnedWrapper.Class);
            returnedWrapperObj.clonedApplicantsId = applicantWrapperObj;
            
            // Clone vehicles
            IND_RevokeController.cloneVehicle(loanApplicationId, loanApplicationCloneId,revokeType);
            
            // Clone finalTerm
            // IND_RevokeController.cloneFinalTerm(loanApplicationId, loanApplicationCloneId, revokeType);//CISP-2342
            
            // Clone dedpue
            IND_RevokeController.cloneCustomerDedpue(loanApplicationId, loanApplicationCloneId,applicantWrapperObj.newApplicantMap);
            
            //Clone Documents
            IND_RevokeController.cloneDocuments(loanApplicationId, loanApplicationCloneId, revokeType, applicantWrapperObj.newApplicantMap,new List<Id>());//CISP-2328
            
            // Clone CMU Case
            IND_RevokeController.cloneCMUCase(loanApplicationId, loanApplicationCloneId,System.Label.CMURequest, revokeType);//CISP-2328
            
            List<String> caseRecordTypeList = new List<String>{'FI',System.Label.TVR,System.Label.AML_Check,System.Label.Off_Role_Emp_Approval, 'AML Check'};//CISP-7506

            // Update other cases
            IND_RevokeController.updateOldCase(loanApplicationId, caseRecordTypeList);

            return JSON.serialize(returnedWrapperObj);
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_RevokeController', 'generalRevoke', System.Label.Apex, e, loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    @AuraEnabled
    public static String addCoBorrowerRevoke(String loanApplicationId,String revokeType){
        try{
            ReturnedWrapper returnedWrapperObj = new ReturnedWrapper();
            // Clone Loan Application
            String loanApplicationCloneId = IND_RevokeController.cloneLoanApplication(loanApplicationId,revokeType);
            returnedWrapperObj.clonedLoanApplicationId = loanApplicationCloneId;
            
            // Clone Applicants
            ApplicantReturnedWrapper applicantWrapperObj = (ApplicantReturnedWrapper) JSON.deserialize(IND_RevokeController.cloneApplicant(loanApplicationId, loanApplicationCloneId,revokeType), ApplicantReturnedWrapper.Class);
            returnedWrapperObj.clonedApplicantsId = applicantWrapperObj;
            
            //Clone Documents
            IND_RevokeController.cloneDocuments(loanApplicationId, loanApplicationCloneId, revokeType, applicantWrapperObj.newApplicantMap, new List<Id>());//CISP-2328
            
            // Clone vehicles
            IND_RevokeController.cloneVehicle(loanApplicationId, loanApplicationCloneId,revokeType);
            
            // Clone finalTerm
            // IND_RevokeController.cloneFinalTerm(loanApplicationId, loanApplicationCloneId, revokeType);//CISP-2342
            
            // Clone dedpue
            IND_RevokeController.cloneCustomerDedpue(loanApplicationId, loanApplicationCloneId,applicantWrapperObj.newApplicantMap);
            
            // Clone CMU Case
            IND_RevokeController.cloneCMUCase(loanApplicationId, loanApplicationCloneId,System.Label.CMURequest, revokeType);//CISP-2328
            
            List<String> caseRecordTypeList = new List<String>{'FI',System.Label.TVR,System.Label.AML_Check,System.Label.Off_Role_Emp_Approval, 'AML Check'};//CISP-7506
                
                // Update other cases
                IND_RevokeController.updateOldCase(loanApplicationId, caseRecordTypeList);
            
            return JSON.serialize(returnedWrapperObj);
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_RevokeController', 'addCoBorrowerRevoke', System.Label.Apex, e, loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    @AuraEnabled
    public static String cloneLoanApplication(String loanApplicationId, String revokeType){
        try {
            if (loanApplicationId!=null) {
                Opportunity existingLoan = oppObj;// INDI-4698 -- Added (Revoke_Parent_Deal_Number__c) field in the query.
                //CISP-1200 -- Removed Is_Loan_Details_Submitted__c field from the query.
                //CISP-2407 -- Added Applicant_Name__c field in the query.
                ////CISP-2384 -- Added is_Revoked
                //CISP-2583	-Added Revoked_Applicant_Count__c field
                
                existingLoan.Is_Revoked__c = true;//CISP-2384
                if(String.isBlank(existingLoan.Loan_Created_Date__c)){ //CISP-9624
                    existingLoan.Loan_Created_Date__c = IND_ApplicationFormSigning.getDateTimeFormat(existingLoan.Createddate);
                }
                //INDI-4698 -- START
                String parentDealNumber = '';
                String dealNumber = '';
                if(!String.isEmpty(existingLoan.Revoke_Parent_Deal_Number__c) && !String.isEmpty(existingLoan.Deal_Number__c)){
                    List<String> parentDealNumberList = existingLoan.Revoke_Parent_Deal_Number__c.split('-0');
                    Integer counter = Integer.valueOf(parentDealNumberList[1]);
                    counter++;
                    dealNumber = existingLoan.Deal_Number__c;
                    parentDealNumber = parentDealNumberList[0] + '-0' + String.valueOf(counter);
                    existingLoan.Deal_Number__c = parentDealNumber;
                }else if(!String.isEmpty(existingLoan.Deal_Number__c)){
                    dealNumber = existingLoan.Deal_Number__c;
                    parentDealNumber = existingLoan.Deal_Number__c + '-01';
                    existingLoan.Deal_Number__c = parentDealNumber;
                }
                
                if(Opportunity.SObjectType.getDescribe().isUpdateable()){
                    update existingLoan;
                }
                
                Integer[] vals;
                String tmp = existingLoan.Lead_Number__c.right(1);
                vals = tmp.getChars();
                
                String newChar = 'A';
                if(vals[0] >= 65 && vals[0] <= 90){
                    newChar = String.fromCharArray( new List<integer> { vals[0] + 1 }   );
                }
                
                //CISP-2583-START
                List<Applicant__c> tempAppList = new List<Applicant__c>([Select id From Applicant__c Where Opportunity__c =: loanApplicationId AND Applicant_Type__c = :System.Label.CoBorrower WITH SECURITY_ENFORCED]);
                Integer parentCoApplicantCount = existingLoan.Revoked_Applicant_Count__c == null ? 0 : Integer.valueOf(existingLoan.Revoked_Applicant_Count__c);
                Integer coApplicantSize = tempAppList.size() + parentCoApplicantCount;
                //CISP-2583-END
                
                Opportunity newLoanApplication = existingLoan.clone(false, false, false, false);
                newLoanApplication.StageName = revokeType == 'General Revoke' ? 'Asset Details' : 'Loan Initiation' ;//SFTRAC-166

                newLoanApplication.Sub_Stage__c = 'User Details';
                newLoanApplication.LastStageName__c = revokeType == 'General Revoke' ? 'Asset Details' : 'Loan Initiation';//SFTRAC-166

                newLoanApplication.Parent_Loan_Application__c = existingLoan.Id;
                newLoanApplication.Lead_Number__c = existingLoan.Lead_Number__c + '-' + newChar;
                newLoanApplication.Name = existingLoan.Name + '-' + newChar;
                // newLoanApplication.OwnerId = existingLoan.CreatedById; //INDI-4342/CISP-503//CISP-2452
                newLoanApplication.Deal_Number__c = dealNumber;
                newLoanApplication.Revoke_Parent_Deal_Number__c = parentDealNumber;
                newLoanApplication.Is_Revoked__c = false;//CISP-2384
                newLoanApplication.Revoked_Applicant_Count__c = coApplicantSize;//CISP-2583
                newLoanApplication.CreatedById = existingLoan.CreatedById;//CISP-2728
                newLoanApplication.LeadSource = existingLoan.LeadSource == 'Digital-MSIL-Custom' ? existingLoan.LeadSource : existingLoan.LeadSource == 'DSA' ? existingLoan.LeadSource : existingLoan.LeadSource == System.Label.Mahindra_Custom_Lead_API_Value ? existingLoan.LeadSource : existingLoan.LeadSource == System.Label.Mahindra_PreA_Lead_API_Value ? existingLoan.LeadSource : '';//CISP-3148 & CISP-10982 & //OLA-227 //CISP-15890 

                if(existingLoan.LeadSource == 'DSA'){
                    newLoanApplication.OwnerId = existingLoan.OwnerId;//CISP-10982
                }
                if(existingLoan.LeadSource == 'TAFE'){
                    newLoanApplication.LeadSource = existingLoan.LeadSource;
                }

                if(existingLoan.Product_type__c == System.Label.Tractor && (revokeType == 'removecoborroweraddcoborrower' || revokeType == 'removecoborroweraddcoborrowerbypeuser')){
                    newLoanApplication.Hunter_APS_Response__c = null;
                    newLoanApplication.Hunter_Match_Status__c = null;
                }

                newLoanApplication.isParentLeadMoreThan30or90Days__c = revokeType == 'removecoborroweraddcoborrowerbypeuser' ? true : false;
                if(Opportunity.SObjectType.getDescribe().isCreateable()){
                    insert newLoanApplication;
                }

                User userRecord = [Select Id,isActive from USER where id =: existingLoan.CreatedById];
                if(userRecord.IsActive){
                    CustomNotificationWrapper customNotification = new CustomNotificationWrapper();
                    customNotification.loanApplicationId = newLoanApplication.Id;
                    customNotification.ownerId = String.isNotBlank(IND_RevokeController.ownerId) ? IND_RevokeController.ownerId : existingLoan.CreatedById; // INDI-4342/CISP-503
                    customNotification.notificationTitle = 'Loan Application Assignment';
                    customNotification.notificationBody = 'Loan Application ' + newLoanApplication.Lead_Number__c +' has been assigned to you.';
                    IND_RevokeController.sendCustomNotification(customNotification);
                    // INDI-4698 -- END
                }
                return newLoanApplication.Id;
            }
            return null;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_RevokeController', 'cloneLoanApplication', System.Label.Apex, e, loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    @AuraEnabled
    public static String cloneApplicant(String oldLoanApplicationId, String newLoanApplicationId, String revokeType){
        try {
            ApplicantReturnedWrapper wrapperObj = new ApplicantReturnedWrapper();
            // Clone Applicants
            List<String> applicantType = new List<String>();
            applicantType.add(System.Label.Borrower);
            if(revokeType == 'General Revoke'){
                applicantType.add(System.Label.coBorrower);
            }
            //SFTRAC-166
            if(revokeType == 'payandpayoutchanges' || revokeType == 'assetmodifications' || revokeType == 'removecoborroweraddcoborrower' || revokeType == 'removecoborroweraddcoborrowerbypeuser'){
                applicantType.add(System.Label.coBorrower);
                applicantType.add('Guarantor');
                applicantType.add('Beneficiary');
            }
            List<Applicant__c> existingApplicantList = new List<Applicant__c>();
            if(revokeType == 'Add/Change Co-Borrower'){                
                existingApplicantList = [SELECT Id,AepS_Info__c,Contact_number__c,Name,OTP_for_borrower__c,Selfie_Retry_Attempts__c,Customer_First_Name__c,Customer_Last_Name__c,Whatsapp_number__c,customer_image_attempts__c,Applicant_Type__c,DocAuth_Application_Id__c,Selfie_Upload__c,Customer_code__c,Consent_Received__c,Register_for_WhatsApp_Banking__c,Journey_Stage__c,Declared_income__c,Loan_Amount__c,Do_you_have_a_bank_account__c,Do_you_have_a_bank_account_with_IBL__c,Would_you_like_to_open_a_bank_account__c,Current_Same_As_Permanent__c, Current_Address_Not_Present__c,Permanent_Address_Not_Present__c,Bureau_Pull_Match__c,Bureau_Pull_Message__c,In_Active_Applicant__c,Caste__c,Religion__c,Income_source_available__c,Is_Address_Declaration__c,isCodeValidateBySalesUser__c,Profile__c,Is_Borrower_Relative_Of_Director__c, Is_Borrower_Relative_Of_Senior_Officer__c, Is_CoBorrower_Relative_Of_Director__c, Is_CoBorrower_Relative_Of_Senior_Officer__c, Borrower_Relation_With_IndusInd_Q1__c,Borrower_Relation_With_IndusInd_Q2__c,Borrower_Relation_With_Other_Bank_Q1__c,Borrower_Relation_With_Other_Bank_Q2__c,CoBorrower_Relation_With_IndusInd_Q1__c,CoBorrower_Relation_With_IndusInd_Q2__c,CoBorrower_Relation_With_Other_Bank_Q1__c,CoBorrower_Relation_With_Other_Bank_Q2__c,Relationship_With_IndusInd_Or_Other_Bank__c,Feedback_Ref_1__c,Feedback_Ref_2__c  From Applicant__c Where Opportunity__c =: oldLoanApplicationId AND Applicant_Type__c IN : applicantType AND In_Active_Applicant__c = false ORDER BY CreatedDate ASC];//CISP-20 -- Added Caste__c,Religion__c fields in the query.//CISP-2736 - Added Income_source_available__c field in the query.//CISP-3116
            }else if(revokeType == 'General Revoke'){
                existingApplicantList = [SELECT Id,AepS_Info__c,Name,Preferred_address_for_communication__c, of_family_members_residing_with_you__c, Residence_country__c,  Who_will_repay_the_loan__c, Marital_status__c, Spouse_Name__c, Father_s_name__c, Mother_s_name__c, Communication_language__c, Customer_Qualification__c, Relationship_with_borrower__c, Email_Fail_Count__c,Is_Email_Valid__c,OTP_for_borrower__c,Selfie_Retry_Attempts__c,Customer_First_Name__c,Customer_Last_Name__c,Whatsapp_number__c,customer_image_attempts__c,Contact_number__c,Applicant_Type__c,DocAuth_Application_Id__c,Selfie_Upload__c,Customer_code__c,Consent_Received__c,Register_for_WhatsApp_Banking__c,Journey_Stage__c,Declared_income__c,Loan_Amount__c,Do_you_have_a_bank_account__c,Do_you_have_a_bank_account_with_IBL__c,Would_you_like_to_open_a_bank_account__c,Current_Same_As_Permanent__c, Current_Address_Not_Present__c,Permanent_Address_Not_Present__c,Email_Id__c,Bureau_Pull_Match__c,Bureau_Pull_Message__c,Income_source_available__c,In_Active_Applicant__c,Caste__c,Religion__c,Check_Eligibility_Final_Reason__c,Check_Eligibility_Message__c,Check_Eligibility_Match__c,Is_Address_Declaration__c,Is_Additional_Details_Submitted__c, Name_Ref_1__c, Relationship_with_Borrower_Ref_1__c, Address_Line_1_Ref_1__c, Address_Line_2_Ref_1__c, City_Ref_1__c, State_Ref_1__c,District_Ref_1__c, Pincode_Ref_1__c, Phone_Number_Ref_1__c, Name_Ref_2__c, Relationship_with_Borrower_Ref_2__c, Address_Line_1_Ref_2__c, Address_Line_2_Ref_2__c, City_Ref_2__c, State_Ref_2__c, District_Ref_2__c, Pincode_Ref_2__c, Phone_Number_Ref_2__c,IND_Customer_Master_Creation_Status__c, IND_Customer_Master_Updation_Status__c,isCodeValidateBySalesUser__c,Is_Borrower_Relative_Of_Director__c, Is_Borrower_Relative_Of_Senior_Officer__c, Is_CoBorrower_Relative_Of_Director__c, Is_CoBorrower_Relative_Of_Senior_Officer__c, Borrower_Relation_With_IndusInd_Q1__c,Borrower_Relation_With_IndusInd_Q2__c,Borrower_Relation_With_Other_Bank_Q1__c,Borrower_Relation_With_Other_Bank_Q2__c,CoBorrower_Relation_With_IndusInd_Q1__c,CoBorrower_Relation_With_IndusInd_Q2__c,CoBorrower_Relation_With_Other_Bank_Q1__c,CoBorrower_Relation_With_Other_Bank_Q2__c,Relationship_With_IndusInd_Or_Other_Bank__c,Feedback_Ref_1__c,Feedback_Ref_2__c  From Applicant__c Where Opportunity__c =: oldLoanApplicationId AND Applicant_Type__c IN : applicantType AND In_Active_Applicant__c = false ORDER BY CreatedDate ASC];//CISP-20 -- Added Caste__c,Religion__c fields in the query.//CISP-2723 Added - Check Eligibility fields in the query.
            }else if(revokeType == 'removecoborroweraddcoborrower' || revokeType == 'removecoborroweraddcoborrowerbypeuser'){
                existingApplicantList = [SELECT Id,AepS_Info__c,Contact_number__c,Name,OTP_for_borrower__c,Selfie_Retry_Attempts__c,Customer_First_Name__c,Customer_Last_Name__c,Whatsapp_number__c,customer_image_attempts__c,Applicant_Type__c,DocAuth_Application_Id__c,Selfie_Upload__c,Customer_code__c,Consent_Received__c,Register_for_WhatsApp_Banking__c,Journey_Stage__c,Declared_income__c,Loan_Amount__c,Do_you_have_a_bank_account__c,Do_you_have_a_bank_account_with_IBL__c,Would_you_like_to_open_a_bank_account__c,Current_Same_As_Permanent__c, Current_Address_Not_Present__c,Permanent_Address_Not_Present__c,In_Active_Applicant__c,Income_source_available__c,Is_Address_Declaration__c,isCodeValidateBySalesUser__c,Category__c,CRIFF_Report_URL__c,Gating_Screening_Outcome__c,IsPrimary__c,Literacy__c,Profile__c,(SELECT Id,Loan_Application__c,Applicant__c,Finacle_City__c,Nominee_City__c,Nominee_DOB__c,Nominee_Pin_Code__c,Nominee_State__c,Nominee_address__c,Nominee_available__c,Nominee_name__c,Relationship_with_borrower__c,Saving_Account_opened_for__c,Saving_Account_opening_form_No__c,TeleVerification__c,Geo_State_Master__c FROM CASA_Bank_Forms__r),Beneficial_Owner_Category__c,Relationship_with_Entity__c,Relationship_Type__c,POA_Holder__c,ShareHolding__c,Salutation__c,Gender__c,Employer_Type__c,Date_of_Birth__c,Is_Customer_NRI__c,Work_Permit_No__c,Permit_Validity__c,Work_Visa_Details__c,LegalEntityIdentifier__c,Salaried_Self_employed__c,Beneficiary_Office_Address_Line_1__c,Beneficiary_Office_Address_Line_2__c,Beneficiary_Office_City__c,Beneficiary_Office_Pincode__c,Beneficiary_Office_State__c,Beneficiary_Office_District__c,Is_Borrower_Relative_Of_Director__c, Is_Borrower_Relative_Of_Senior_Officer__c, Is_CoBorrower_Relative_Of_Director__c, Is_CoBorrower_Relative_Of_Senior_Officer__c, Borrower_Relation_With_IndusInd_Q1__c,Borrower_Relation_With_IndusInd_Q2__c,Borrower_Relation_With_Other_Bank_Q1__c,Borrower_Relation_With_Other_Bank_Q2__c,CoBorrower_Relation_With_IndusInd_Q1__c,CoBorrower_Relation_With_IndusInd_Q2__c,CoBorrower_Relation_With_Other_Bank_Q1__c,CoBorrower_Relation_With_Other_Bank_Q2__c,Relationship_With_IndusInd_Or_Other_Bank__c,Feedback_Ref_1__c,Feedback_Ref_2__c  From Applicant__c Where Opportunity__c =: oldLoanApplicationId AND Applicant_Type__c IN : applicantType AND In_Active_Applicant__c = false ORDER BY CreatedDate ASC];
            }else if(revokeType == 'payandpayoutchanges' || revokeType == 'assetmodifications'){
                existingApplicantList = [SELECT Id,AepS_Info__c,Name,Preferred_address_for_communication__c, of_family_members_residing_with_you__c, Residence_country__c,  Who_will_repay_the_loan__c, Marital_status__c, Spouse_Name__c, Father_s_name__c, Mother_s_name__c, Communication_language__c, Customer_Qualification__c, Relationship_with_borrower__c, Email_Fail_Count__c,Is_Email_Valid__c,OTP_for_borrower__c,Selfie_Retry_Attempts__c,Customer_First_Name__c,Customer_Last_Name__c,Whatsapp_number__c,customer_image_attempts__c,Contact_number__c,Applicant_Type__c,DocAuth_Application_Id__c,Selfie_Upload__c,Customer_code__c,Consent_Received__c,Register_for_WhatsApp_Banking__c,Journey_Stage__c,Declared_income__c,Loan_Amount__c,Do_you_have_a_bank_account__c,Do_you_have_a_bank_account_with_IBL__c,Would_you_like_to_open_a_bank_account__c,Current_Same_As_Permanent__c, Current_Address_Not_Present__c,Permanent_Address_Not_Present__c,Email_Id__c,Income_source_available__c,In_Active_Applicant__c,Caste__c,Religion__c,Check_Eligibility_Final_Reason__c,Check_Eligibility_Message__c,Check_Eligibility_Match__c,Is_Address_Declaration__c,Is_Additional_Details_Submitted__c, Name_Ref_1__c, Relationship_with_Borrower_Ref_1__c, Address_Line_1_Ref_1__c, Address_Line_2_Ref_1__c, City_Ref_1__c, State_Ref_1__c,District_Ref_1__c, Pincode_Ref_1__c, Phone_Number_Ref_1__c, Name_Ref_2__c, Relationship_with_Borrower_Ref_2__c, Address_Line_1_Ref_2__c, Address_Line_2_Ref_2__c, City_Ref_2__c, State_Ref_2__c, District_Ref_2__c, Pincode_Ref_2__c, Phone_Number_Ref_2__c,IND_Customer_Master_Creation_Status__c, IND_Customer_Master_Updation_Status__c,isCodeValidateBySalesUser__c,Category__c,CRIFF_Report_URL__c,Gating_Screening_Outcome__c,IsPrimary__c,Literacy__c,Profile__c,Repayment_Will_Be_Done_By__c,Nominee_address__c,Nominee_available__c,Nominee_City__c,Nominee_DOB__c,Nominee_name__c,Nominee_pin_code__c,Nominee_State__c,Nominee_Relationship__c,Co_Borrower_Reside_with_borrower__c,Is_this_current_residence_cum_office__c,Office_Address_Line_1__c,Office_Address_Line_2__c,(SELECT Id,Loan_Application__c,Applicant__c,Finacle_City__c,Nominee_City__c,Nominee_DOB__c,Nominee_Pin_Code__c,Nominee_State__c,Nominee_address__c,Nominee_available__c,Nominee_name__c,Relationship_with_borrower__c,Saving_Account_opened_for__c,Saving_Account_opening_form_No__c,TeleVerification__c,Geo_State_Master__c FROM CASA_Bank_Forms__r),Beneficial_Owner_Category__c,Relationship_with_Entity__c,Relationship_Type__c,POA_Holder__c,ShareHolding__c,Salutation__c,Gender__c,Employer_Type__c,Date_of_Birth__c,Is_Customer_NRI__c,Work_Permit_No__c,Permit_Validity__c,Work_Visa_Details__c,LegalEntityIdentifier__c,Salaried_Self_employed__c,Beneficiary_Office_Address_Line_1__c,Beneficiary_Office_Address_Line_2__c,Beneficiary_Office_City__c,Beneficiary_Office_Pincode__c,Beneficiary_Office_State__c,Beneficiary_Office_District__c,Is_Borrower_Relative_Of_Director__c, Is_Borrower_Relative_Of_Senior_Officer__c, Is_CoBorrower_Relative_Of_Director__c, Is_CoBorrower_Relative_Of_Senior_Officer__c, Borrower_Relation_With_IndusInd_Q1__c,Borrower_Relation_With_IndusInd_Q2__c,Borrower_Relation_With_Other_Bank_Q1__c,Borrower_Relation_With_Other_Bank_Q2__c,CoBorrower_Relation_With_IndusInd_Q1__c,CoBorrower_Relation_With_IndusInd_Q2__c,CoBorrower_Relation_With_Other_Bank_Q1__c,CoBorrower_Relation_With_Other_Bank_Q2__c,Relationship_With_IndusInd_Or_Other_Bank__c,Feedback_Ref_1__c,Feedback_Ref_2__c  From Applicant__c Where Opportunity__c =: oldLoanApplicationId AND Applicant_Type__c IN : applicantType AND In_Active_Applicant__c = false ORDER BY CreatedDate ASC];
            }
            List<CASA_Bank_Form__c> casaAppList = new List<CASA_Bank_Form__c>();
            Map<Id,Applicant__c> newApplicantMap = new Map<Id,Applicant__c>();
            for(Applicant__c applicant : existingApplicantList){
                Applicant__c newApplicant = applicant.clone(false, false, false, false);
                if((revokeType == 'payandpayoutchanges' || revokeType == 'assetmodifications' || revokeType == 'removecoborroweraddcoborrower' || revokeType == 'removecoborroweraddcoborrowerbypeuser') && newApplicant.CRIFF_Report_URL__c != null){
                    update new Opportunity (Id = newLoanApplicationId,CRIFF_Report_Initiated__c = true);
                }
                newApplicant.Opportunity__c = newLoanApplicationId;
                newApplicant.Journey_Stage__c = ((revokeType == 'payandpayoutchanges' || revokeType == 'assetmodifications') && applicant.Applicant_Type__c == System.Label.Borrower) ? 'Vehicle Dedupe' : 'Gatting And Screening';//SFTRAC-166
                newApplicantMap.put(applicant.Id,newApplicant);
                if(applicant.CASA_Bank_Forms__r != null && applicant.CASA_Bank_Forms__r.size() > 0){
                    casaAppList.addAll(applicant.CASA_Bank_Forms__r);
                }
            }
            if(Applicant__c.SObjectType.getDescribe().isCreateable()){
                insert newApplicantMap.values();
            }

            Applicant__c borrowerApp = new Applicant__c();
            for (Applicant__c applicant : existingApplicantList) {
                if(applicant.Applicant_Type__c == Label.Borrower){
                    borrowerApp = applicant;
                    break;
                }
            }
            if((revokeType == 'payandpayoutchanges' || revokeType == 'assetmodifications') && borrowerApp != null && newApplicantMap.containsKey(borrowerApp.Repayment_Will_Be_Done_By__c)){
                Applicant__c newBorrowerApp = newApplicantMap.get(borrowerApp.Id);
                newBorrowerApp.Repayment_Will_Be_Done_By__c = newApplicantMap.get(borrowerApp.Repayment_Will_Be_Done_By__c).Id;
                update newBorrowerApp;
            }

            List<CASA_Bank_Form__c> newCasaList = new List<CASA_Bank_Form__c>();
            for (CASA_Bank_Form__c casaObj : casaAppList) {
                casaObj.Loan_Application__c = newLoanApplicationId;
                casaObj.Applicant__c = newApplicantMap.containsKey(casaObj.Applicant__c) ? newApplicantMap.get(casaObj.Applicant__c).Id : '';
                newCasaList.add(casaObj);
            }
            

            if(newCasaList.size() > 0){
                update newCasaList;
            }
            
            for (Applicant__c applicant : newApplicantMap.values()) {
                if(!applicant.In_Active_Applicant__c){
                    if(applicant.Applicant_Type__c == System.Label.Borrower){
                        wrapperObj.clonedPrimaryApplicantId = applicant.Id;
                    }else if(applicant.Applicant_Type__c == System.Label.coBorrower){
                        wrapperObj.clonedSecondaryApplicantId = applicant.Id;
                    }
                }
            }
            
            wrapperObj.newApplicantMap = newApplicantMap;
            return JSON.serialize(wrapperObj);
            
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_RevokeController', 'cloneApplicant', System.Label.Apex, e, oldLoanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    // Start -- Tractar revoke changes - anyloaninformationchanges
    private static Boolean purgeTractorL2Data(String loanApplicationId){
        try {
            Savepoint dbsp = Database.setSavepoint();
        
            Boolean caseFISubmittedCheckReset = resetFICaseTabTractor(loanApplicationId);
            if(!caseFISubmittedCheckReset){
                Database.rollBack(dbsp);
                return false;
            }

            Boolean revokeTVRApplicationTractorStatus = revokeTVRApplicationTractor(loanApplicationId);
            if(!revokeTVRApplicationTractorStatus){
                Database.rollBack(dbsp);
                return false;
            }
            Boolean deleteLoanTransactionHistoryTractor = deleteLoanTransactionHistoryTractor(loanApplicationId);

            if(!deleteLoanTransactionHistoryTractor || deleteLoanTransactionHistoryTractor == null){
                Database.rollBack(dbsp);
                return false;
            }else{
                Boolean updateVehicleDetailsTractor = updateVehicleDetailsTractor(loanApplicationId);
                if(!updateVehicleDetailsTractor || updateVehicleDetailsTractor == null){
                    Database.rollBack(dbsp);
                    return false;
                }else{
                    Boolean dataPurged = purgeL2DataTractor(loanApplicationId);
                    if(!dataPurged || dataPurged == false){
                        Database.rollBack(dbsp);
                        return false;
                    }else{
                        return true;
                    }
                }
                
            }
                    
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_RevokeController', 'purgeL2DataTractor', System.Label.Apex, e, loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    private static Boolean revokeTVRApplicationTractor(String loanApplicationId){
        if(loanApplicationId != null){
            List<TeleVerification__c> teleLst= [SELECT Id FROM TeleVerification__c WHERE Case__r.Loan_Application__c  =: loanApplicationId WITH SECURITY_ENFORCED];
            List<Case> caseLst = [SELECT Id FROM Case WHERE Loan_Application__c =: loanApplicationId AND RecordType.Name = 'TVR'WITH SECURITY_ENFORCED];
            
            if(teleLst.size()>0){
                delete teleLst;
            }
            
            if(caseLst.size()>0){
                delete caseLst;
            }

            return true;
        }
        return false;
    }

    private static Boolean resetFICaseTabTractor(String loanApplicationId){
        try{     
            if(loanApplicationId != null){
                List<Case> updateCaseLst = new List<Case>();
                List<Case> caseLst = [SELECT Id FROM Case WHERE Loan_Application__c =:loanApplicationId AND RecordType.Name = 'FI' AND RejectedFI__c = false WITH SECURITY_ENFORCED];
                for(Case cs: caseLst){
                    cs.Status = 'Completed';
                    updateCaseLst.add(cs);
                }

                if(updateCaseLst.size()>0){
                    update updateCaseLst;
                }

                return true;
            }
            return false;
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_RevokeController', 'resetFICaseTabTractor', System.Label.Apex, e, loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    private static boolean updateVehicleDetailsTractor(String loanApplicationId){
        try{     
            if(loanApplicationId != null){
                List<Vehicle_Detail__c> vd = [SELECT Vehicle_Inspection_RC_Limit_Submitted__c,No_Of_Proposals_Available__c, Available_Disbursal_Amount__c, No_of_days_RC_Pending__c FROM Vehicle_Detail__c WHERE Loan_Application__r.Id =:loanApplicationId];
                for (Vehicle_Detail__c vdObj : vd) {
                    vdObj.Vehicle_Inspection_RC_Limit_Submitted__c = false;
                    vdObj.No_Of_Proposals_Available__c = 0;
                    vdObj.Available_Disbursal_Amount__c = 0;
                    vdObj.No_of_days_RC_Pending__c = false;
                    vdObj.L2_Insurance_Submitted__c = false;
                }
                if(vd.size() > 0){
                    update vd;
                    return true;
                }
            }
            return null;
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_RevokeController', 'updateVehicleDetailsTractor', System.Label.Apex, e, loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    private static boolean deleteLoanTransactionHistoryTractor(String loanApplicationId){
        try{     
            if(loanApplicationId != null){
                List<Loan_Application_Transaction_History__c> transactionsToBeDeleted = [SELECT Id FROM Loan_Application_Transaction_History__c WHERE Loan_Application_ID__c =: loanApplicationId];
                if(transactionsToBeDeleted != null){
                    delete transactionsToBeDeleted;
                    return true;
                }
            }
            return null;
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_RevokeController', 'deleteLoanTransactionHistoryTractor', System.Label.Apex, e, loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    public static boolean purgeL2DataTractor(String loanApplicationId){
        try{
            List<sObject> l2dataToPurge = new List<sObject>();      
            if(loanApplicationId != null){
                // Delete Structured EMIs
                List<sObject> structuredEMIs = IND_RevokeController.getDataToBePurgedTractor('Structered_EMI__c', loanApplicationId,'Loan_Application__r.Id');
                if(structuredEMIs != null){
                    l2dataToPurge.addAll(structuredEMIs);
                }
                // Delete Televerifications
                List<sObject> tvfData = IND_RevokeController.getDataToBePurgedTractor('TeleVerification__c', loanApplicationId,'Loan_Application__r.Id');
                if(tvfData != null){
                    l2dataToPurge.addAll(tvfData);
                }
                // Delete IHMs
                List<sObject> ihmData = IND_RevokeController.getDataToBePurgedTractor('IHM__c', loanApplicationId,'Loan_Application__r.Id');
                if(ihmData != null){
                    l2dataToPurge.addAll(ihmData);
                }
                // Delete LoanDisbursementDetails
                List<sObject> loanDisbursementData = IND_RevokeController.getDataToBePurgedTractor('LoanDisbursementDetails__c', loanApplicationId,'Parent_Loan_Application__r.Id');
                if(loanDisbursementData != null){
                    l2dataToPurge.addAll(loanDisbursementData);
                }
                // Delete Invoice Detail
                List<sObject> invoiceDetailData = IND_RevokeController.getDataToBePurgedTractor('Invoice_Details__c', loanApplicationId,'Loan_Application__r.Id');
                if(invoiceDetailData != null){
                    l2dataToPurge.addAll(invoiceDetailData);
                }
                // Delete Loan Agreement Data
                List<sObject> loanAgreementData = IND_RevokeController.getDataToBePurgedTractor('Loan_Agreement__c', loanApplicationId,'Loan_Application__r.Id');
                if(loanAgreementData != null){
                    l2dataToPurge.addAll(loanAgreementData);
                }
                 // Delete CAMs Data
                 List<sObject> CAMdata = IND_RevokeController.getDataToBePurgedTractor('CAM__c', loanApplicationId,'Loan_Application__r.Id');
                 if(CAMdata != null){
                     l2dataToPurge.addAll(CAMdata);
                 }
                  // Delete Structured Loan_Application_Transaction_History__c
                List<sObject> loanAppTransactions = IND_RevokeController.getDataToBePurgedTractor('Loan_Application_Transaction_History__c', loanApplicationId,'Loan_Application_ID__r.Id');
                if(loanAppTransactions != null){
                    l2dataToPurge.addAll(loanAppTransactions);
                }
                 // Delete Repayments
                 List<sObject> repayments = IND_RevokeController.getDataToBePurgedTractor('Repayments__c', loanApplicationId,'Loan_Application__r.Id');
                 if(repayments != null){
                     l2dataToPurge.addAll(repayments);
                 }

                 // Delete Retry Counts
                 List<sObject> retryCounts = [SELECT Id FROM Retry_Count__c WHERE Module__c NOT IN ('Gatting & Screening','Loan Details') AND Service_Name__c != 'FinalTermApi' LIMIT 50];
                 if(retryCounts != null){
                     l2dataToPurge.addAll(retryCounts);
                 }

                 // Delete Exposures
                 List<sObject> exposures = IND_RevokeController.getDataToBePurgedTractor('Exposure__c', loanApplicationId,'Loan_Application__r.Id');
                 if(exposures != null){
                     l2dataToPurge.addAll(exposures);
                 }

                 // Delete l2Documents
                 Set<String> L2_DOC_TYPES = new Set<String>{'RTO','DPN','Agreement Wrapper Booklet','Agreement 1st Schedule','Agreement 2nd Schedule','DPR','RC','Invoice','IHM Receipt'};
                 List<Documents__c> L2documents = [SELECT Id FROM Documents__c WHERE Opportunity_Relation__r.Id =:loanApplicationId AND Document_Type__c IN: L2_DOC_TYPES];
                 if(L2documents != null){
                     l2dataToPurge.addAll(L2documents);
                 }

                 if(!l2dataToPurge.isEmpty()){
                    try{
                        Database.delete(l2dataToPurge);
                        return true;
                    }catch(exception e){
                        ErrorLoggerUtil.logErrorEvent('IND_RevokeController', 'purgeL2DataTractor', System.Label.Apex, e, loanApplicationId);
                    }
                 }
            }
            return null;
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_RevokeController', 'purgeL2DataTractor-outer', System.Label.Apex, e, loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    public static List<sObject> getDataToBePurgedTractor(string objName, string loanApplicationId, string oppRelationshipName ){
        String PURGE_QUERY = 'SELECT Id FROM '+objName+' WHERE '+oppRelationshipName+' = \''+loanApplicationId+'\'';
        return Database.query(PURGE_QUERY);
    }
    // END - Tractar revoke changes - anyloaninformationchanges

    @AuraEnabled
    public static Map<Id,Vehicle_Detail__c>  cloneVehicle(String oldLoanApplicationId, String newLoanApplicationId, String revokeType){
        try {
            // Clone Vehicle
            List<Vehicle_Detail__c> vehicleObjList = new List<Vehicle_Detail__c>([ SELECT Id,Product_Segment__c,Vehicle_type__c,Product__c, Purpose_of_purchase__c, Vehicle_registered_in_the_name_of__c, Vehicle_Registration_number__c, Make__c, Model__c, Variant__c,Make_Code__c,Model_Code__c,Variant_Code__c, Dealer_Sub_dealer_name__c, Invoice_in_the_name_of__c,Usage_Type__c, Lien_in_favor_of__c, RC_retention_applicable__c, Number_of_ownerships__c, Manufacturer_Year_Month__c, Last_owner_name__c, Engine_number__c, Chassis_number__c,  Is_Get_Vehicle_Details_Successful__c,Is_D_Category_Vehicle__c,Ins_Expiry_date__c,Owner_Name__c,Owner_Contact_Number__c,Valuer_category__c,Valuer_code__c,Valuer__c,Location_Of_Vehicle__c,Insurance_declared_value__c,SLA_Number__c,OEM_Dealer__c,Vehicle_Place_Of_Valuation__c,State__c,City__c,Color_of_Vehicle__c,KMS_Run__c,Selling_Price__c,Purpose_of_IBB_fetch__c,Grid_value__c,Ben_Code__c,Executive_name__c,Executive_Contact_Number__c, Vehicle_Details_MFC_State_Master__c, Vehicle_Details_MFC_City_Master__c,MFC_valuation_Report_URL__c,Valuation_price__c,RC_limit_enabled_Dealer__c,Serial_number__c,Vehicle_SubCategory__c,Vehicle_SubType__c,Vehicle_Verified__c,Vehicle_Proceed_Flag__c,Vehicle_Delivered__c,Registration_Number_Format__c, What_is_thePrice_of_TractorHarvester__c ,How_much_margin_amount_paid_to_dealer__c,Loan_Amount__c ,What_is_emi_convyed_to_customer__c ,Loan_tenure__c ,Repayment_Mode__c ,
            Repayment_Frequency__c,Installment_Type__c,Parent_Deal_number__c, NOC_Number__c,RC_Hold_Amount__c FROM Vehicle_Detail__c WHERE Loan_Application__c=:oldLoanApplicationId]);
            Map<Id,Vehicle_Detail__c> vehicleMap = new Map<Id,Vehicle_Detail__c>();
            if(vehicleObjList.size() > 0){
                //SFTRAC-166 start
                if(revokeType == 'payandpayoutchanges' || revokeType == 'assetmodifications' || revokeType == 'removecoborroweraddcoborrower' || revokeType == 'removecoborroweraddcoborrowerbypeuser'){
                    for(Vehicle_Detail__c vehiObj : vehicleObjList){
                        Vehicle_Detail__c newVehicle = vehiObj.clone(false, false, false, false);
                        newVehicle.Loan_Application__c = newLoanApplicationId;
                        newVehicle.Is_Get_Vehicle_Details_Successful__c = false;
                        vehicleMap.put(vehiObj.Id,newVehicle);
                    }
                    if(Vehicle_Detail__c.SObjectType.getDescribe().isCreateable()){
                        insert vehicleMap.values();
                    }//SFTRAC-166 end
                }else{
                    Vehicle_Detail__c vehicleObj = vehicleObjList[0];
                    Vehicle_Detail__c newVehicleObj = vehicleObj.clone(false, false, false, false);
                    newVehicleObj.Loan_Application__c = newLoanApplicationId;
                    if(Vehicle_Detail__c.SObjectType.getDescribe().isCreateable()){
                        insert newVehicleObj;
                    }
                }
            }
            return vehicleMap;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_RevokeController', 'cloneVehicle', System.Label.Apex, e, oldLoanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    //SFTRAC-166 start
    @AuraEnabled
    public static String payandpayoutchangesRevoke(String loanApplicationId,String revokeType, List<Id> documentIds){
        try{
            ReturnedWrapper returnedWrapperObj = new ReturnedWrapper();
            // Clone Loan Application
            String loanApplicationCloneId = IND_RevokeController.cloneLoanApplication(loanApplicationId,revokeType);
            returnedWrapperObj.clonedLoanApplicationId = loanApplicationCloneId;
            
            // Clone Applicants
            ApplicantReturnedWrapper applicantWrapperObj = (ApplicantReturnedWrapper) JSON.deserialize(IND_RevokeController.cloneApplicant(loanApplicationId, loanApplicationCloneId,revokeType), ApplicantReturnedWrapper.Class);
            returnedWrapperObj.clonedApplicantsId = applicantWrapperObj;

            IND_RevokeController.cloneReference(loanApplicationId, loanApplicationCloneId,applicantWrapperObj.newApplicantMap);
            // Clone vehicles
            IND_RevokeController.cloneVehicle(loanApplicationId, loanApplicationCloneId,revokeType);
            
            // Clone finalTerm
            // IND_RevokeController.cloneFinalTerm(loanApplicationId, loanApplicationCloneId, revokeType);//CISP-2342
            
            // Clone dedpue
            IND_RevokeController.cloneCustomerDedpue(loanApplicationId, loanApplicationCloneId,applicantWrapperObj.newApplicantMap);
            
            //Clone RCU Case
            List<Id> clonedOldDocs = IND_RevokeController.cloneRCUCase(loanApplicationId, loanApplicationCloneId, 'RCU', documentIds,applicantWrapperObj.newApplicantMap);
            
            //Clone Documents
            IND_RevokeController.cloneDocuments(loanApplicationId, loanApplicationCloneId, revokeType, applicantWrapperObj.newApplicantMap,clonedOldDocs);//CISP-2328
            
            // Clone CMU Case
            IND_RevokeController.cloneCMUCase(loanApplicationId, loanApplicationCloneId,System.Label.CMURequest, revokeType);//CISP-2328
            
            IND_RevokeController.copyClosedFICases(loanApplicationId,loanApplicationCloneId,revokeType,applicantWrapperObj.newApplicantMap);
            List<String> caseRecordTypeList = new List<String>{'FI',System.Label.TVR,System.Label.AML_Check,System.Label.Off_Role_Emp_Approval,'Asset_Verification'};
                
                // Update other cases
                IND_RevokeController.updateOldCase(loanApplicationId, caseRecordTypeList);
            
            updateClonedLoanApplicationOwner(loanApplicationId,returnedWrapperObj.clonedLoanApplicationId,'');
            return JSON.serialize(returnedWrapperObj);
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_RevokeController', 'generalRevoke', System.Label.Apex, e, loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    @AuraEnabled
    public static void cloneReference(String oldLoanApplicationId, String newLoanApplicationId, Map<Id,Applicant__c> newApplicantMap){
        try {
            if (oldLoanApplicationId != null && newLoanApplicationId != null) {                
                List<Customer_Reference__c> refereceList = new List<Customer_Reference__c>([SELECT Id,Name,AddressFlag__c,AddressLine1__c,AddressLine2__c,AddressLine3__c,AddressLine4__c,Applicant__c,City__c,Customer_Code__c,District__c,Exposure__c,Landmark__c,Loan_Application__c,Maker_Date__c,Phone__c,Product__c,Refered__c,State__c,Surname__c,Feedback__c FROM Customer_Reference__c Where Applicant__c IN : newApplicantMap.keySet() AND Loan_Application__c =: oldLoanApplicationId LIMIT 1000]);

                if (refereceList.size() > 0) {
                    List<Customer_Reference__c> newreferenceList = new List<Customer_Reference__c>();
                    for(Customer_Reference__c referenceRecord : refereceList){
                        if(newApplicantMap.containskey(referenceRecord.Applicant__c)){
                            Customer_Reference__c newReferenceRecord = referenceRecord.clone(false, false, false, false);
                            newReferenceRecord.Applicant__c = newApplicantMap.get(referenceRecord.Applicant__c).Id;
                            newReferenceRecord.Loan_Application__c = newLoanApplicationId;
                            newreferenceList.add(newReferenceRecord);
                        }
                    }

                    if(newreferenceList.size() > 0){
                        insert newreferenceList;
                    }
                }
            }
            
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_RevokeController', 'cloneReference', System.Label.Apex, e, oldLoanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    @AuraEnabled
    public static String anyloaninformationchangesRevoke(String loanApplicationId,String revokeType){
        try{
            ReturnedWrapper returnedWrapperObj = new ReturnedWrapper();
            if (loanApplicationId!=null) {
                Opportunity existingLoan = [SELECT Id,Loan_Created_Date__c,Createddate,LeadSource,IModuleId__c,Vehicle_Verified__c, Name, Loan_amount__c, Product_Type__c, Vehicle_Sub_Category__c, Vehicle_Type__c, Required_Loan_amount__c, Required_Tenure__c, Required_ROI__c, Funding_on_Ex_Showroom__c, Funding_on_ORP__c, Is_customer_interested_in_a_motor_insura__c, Funded__c, Non_Funded__c, X1st_yr_Insurance_Premium__c, Motor_Insurance_Premium__c, Basic_Price__c, GST_Amount__c, Discount_on_Basic_Price__c, Ex_showroom_price__c, Ex_showroom_price_carwale__c,RTO_Road_Tax_New__c,RTO_Road_Tax__c, Other_charges__c, On_Road_price__c, On_Road_price_carwale__c, Final_Price__c, PartnerAccountId,AccountId,StageName,LastStageName__c,CloseDate,OwnerId, Lead_Number__c, Agent_BL_code__c, Gender__c, Parent_Deal_number__c,Deal_Number__c,Revoke_Parent_Deal_Number__c,Registration_Number_Format__c,Vehicle_Registration_Number__c,Customer_Code__c, NOC_Number__c,Vehicle_Proceed_Flag__c,Application_number__c,CreatedById,Sub_Stage__c,Applicant_Name__c,Is_Revoked__c,Revoked_Applicant_Count__c,Is_Customer_Dedupe_Submit__c,Application_Type__c FROM Opportunity WHERE Id =: loanApplicationId WITH SECURITY_ENFORCED LIMIT 1];
                existingLoan.StageName = 'Credit Processing';
                existingLoan.Sub_Stage__c = 'Cibil';
                update existingLoan;
            }
            purgeTractorL2Data(loanApplicationId);
            returnedWrapperObj.clonedLoanApplicationId = loanApplicationId;
            return JSON.serialize(returnedWrapperObj);
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_RevokeController', 'generalRevoke', System.Label.Apex, e, loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    @AuraEnabled
    public static string removecoborroweraddcoborrowerRevokeByPEUser(String loanApplicationId,String revokeType, List<Id> documentIds){
        try{
            ReturnedWrapper returnedWrapperObj = new ReturnedWrapper();
            // Clone Loan Application
            String loanApplicationCloneId = IND_RevokeController.cloneLoanApplication(loanApplicationId,revokeType);
            returnedWrapperObj.clonedLoanApplicationId = loanApplicationCloneId;
            
            // Clone Applicants
            ApplicantReturnedWrapper applicantWrapperObj = (ApplicantReturnedWrapper) JSON.deserialize(IND_RevokeController.cloneApplicant(loanApplicationId, loanApplicationCloneId,revokeType), ApplicantReturnedWrapper.Class);
            returnedWrapperObj.clonedApplicantsId = applicantWrapperObj;

            IND_RevokeController.cloneReference(loanApplicationId, loanApplicationCloneId,applicantWrapperObj.newApplicantMap);
            
            // Clone vehicles
            Map<Id,Vehicle_Detail__c>  vehicleMap = IND_RevokeController.cloneVehicle(loanApplicationId, loanApplicationCloneId,revokeType);
            
            // Clone finalTerm
            // IND_RevokeController.cloneFinalTerm(loanApplicationId, loanApplicationCloneId, revokeType);//CISP-2342
            
            // Clone dedpue
            IND_RevokeController.cloneCustomerDedpue(loanApplicationId, loanApplicationCloneId,applicantWrapperObj.newApplicantMap);
            
            //Clone RCU Case
            List<Id> clonedOldDocs = IND_RevokeController.cloneRCUCase(loanApplicationId, loanApplicationCloneId, 'RCU', documentIds,applicantWrapperObj.newApplicantMap);
            
            //Clone Documents
            IND_RevokeController.cloneDocuments(loanApplicationId, loanApplicationCloneId, revokeType, applicantWrapperObj.newApplicantMap,clonedOldDocs);//CISP-2328
            
            // Clone CMU Case
            IND_RevokeController.cloneCMUCase(loanApplicationId, loanApplicationCloneId,System.Label.CMURequest, revokeType);//CISP-2328
            IND_RevokeController.copyClosedFICases(loanApplicationId,loanApplicationCloneId,revokeType,applicantWrapperObj.newApplicantMap);
            IND_RevokeController.copyAssetVerificationCase(loanApplicationId,loanApplicationCloneId,applicantWrapperObj.newApplicantMap,vehicleMap);
            List<String> caseRecordTypeList = new List<String>{'FI',System.Label.TVR,System.Label.AML_Check,System.Label.Off_Role_Emp_Approval,'Asset_Verification'};
                
                // Update other cases
                IND_RevokeController.updateOldCase(loanApplicationId, caseRecordTypeList);
            
            updateClonedLoanApplicationOwner(loanApplicationId,returnedWrapperObj.clonedLoanApplicationId,'');
            return JSON.serialize(returnedWrapperObj);
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_RevokeController', 'generalRevoke', System.Label.Apex, e, loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    @AuraEnabled
    public static String removecoborroweraddcoborrowerRevoke(String loanApplicationId,String revokeType, List<Id> documentIds){
        try{
            ReturnedWrapper returnedWrapperObj = new ReturnedWrapper();
            // Clone Loan Application
            String loanApplicationCloneId = IND_RevokeController.cloneLoanApplication(loanApplicationId,revokeType);
            returnedWrapperObj.clonedLoanApplicationId = loanApplicationCloneId;
            
            // Clone Applicants
            ApplicantReturnedWrapper applicantWrapperObj = (ApplicantReturnedWrapper) JSON.deserialize(IND_RevokeController.cloneApplicant(loanApplicationId, loanApplicationCloneId,revokeType), ApplicantReturnedWrapper.Class);
            returnedWrapperObj.clonedApplicantsId = applicantWrapperObj;

            IND_RevokeController.cloneReference(loanApplicationId, loanApplicationCloneId,applicantWrapperObj.newApplicantMap);
            
            // Clone vehicles
            IND_RevokeController.cloneVehicle(loanApplicationId, loanApplicationCloneId,revokeType);
            
            // Clone finalTerm
            // IND_RevokeController.cloneFinalTerm(loanApplicationId, loanApplicationCloneId, revokeType);//CISP-2342
            
            // Clone dedpue
            IND_RevokeController.cloneCustomerDedpue(loanApplicationId, loanApplicationCloneId,applicantWrapperObj.newApplicantMap);
            
            //Clone RCU Case
            List<Id> clonedOldDocs = IND_RevokeController.cloneRCUCase(loanApplicationId, loanApplicationCloneId, 'RCU', documentIds,applicantWrapperObj.newApplicantMap);
            
            //Clone Documents
            IND_RevokeController.cloneDocuments(loanApplicationId, loanApplicationCloneId, revokeType, applicantWrapperObj.newApplicantMap,clonedOldDocs);//CISP-2328
            
            // Clone CMU Case
            IND_RevokeController.cloneCMUCase(loanApplicationId, loanApplicationCloneId,System.Label.CMURequest, revokeType);//CISP-2328
            IND_RevokeController.copyClosedFICases(loanApplicationId,loanApplicationCloneId,revokeType,applicantWrapperObj.newApplicantMap);
            List<String> caseRecordTypeList = new List<String>{'FI',System.Label.TVR,System.Label.AML_Check,System.Label.Off_Role_Emp_Approval,'Asset_Verification'};
                
                // Update other cases
                IND_RevokeController.updateOldCase(loanApplicationId, caseRecordTypeList);
            
            updateClonedLoanApplicationOwner(loanApplicationId,returnedWrapperObj.clonedLoanApplicationId,'');
            return JSON.serialize(returnedWrapperObj);
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_RevokeController', 'generalRevoke', System.Label.Apex, e, loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }//SFTRAC-166 end

    //CISP-2342 START
    //     @AuraEnabled
    //     public static void cloneFinalTerm(String oldLoanApplicationId, String newLoanApplicationId, String revokeType){
    //         try {
    //             // Clone Vehicle
    //             List<Final_Term__c> finalTermList = new List<Final_Term__c>();
    //             finalTermList = [SELECT Id, Scheme_Bank_offers__c, Service_charges__c, Documentation_charges__c, 
    //                              Stamping_charges__c, Due_date_shift_charges__c,RTO_prefix__c,ECS_verification_by__c, Verification_charges__c, 
    //                              Delinquency_Fund__c, Deliquency_Fund_type__c, Trade_certificate__c, Dlr_Exp_Reimburse_Amt__c,Dlr_Exp_Reimbursement_percent__c,
    //                              Dlr_Exp_Reimburse_Type__c, Mfr_Exp_Reimburse_Amt__c,Mfr_Exp_Reimburse_percent__c, Mfr_Exp_Reimburse_Type__c, 
    //                              Dealer_incentive_amount_main_dealer__c, Dealer_incentive_amount_sub_dealer__c, Dealer_Disc_to_Customer__c, 
    //                              Gift_through_dealer_amount__c, Mfr_incentive__c, DSM_Incentive1__c, DSM_Incentive2__c, Non_Dlr_DSM_Incentive1__c,
    //                              Non_Dlr_DSM_Incentive2__c, Refered_By__c, Rreferrer_Incentive__c, Referrer_Name__c, Provisional_Channel_Cost__c, 
    //                              DSA_pay__c, RCU_Retention_Charges__c,DSM_Name1__c,DSM_Name2__c, Repayment_mode__c,isNavigate__c,Loan_Amount__c,Advance_EMI__c,Holiday_period__c,Installment_Type__c,Agreement_Amount__c, CRM_IRR__c, 
    //                              Gross_IRR__c, Inputted_IRR__c, Net_IRR__c,Non_Dlr_DSM_Name2__c,Non_Dlr_DSM_Name1__c, Bank_IRR__c,Loan_Application__r.StageName,Loan_Application__r.Vehicle_Type__C,Loan_Application__r.Product_Type__c,
    //                              Emp_Name__c,Emp_No__c,EMI_Amount__c,Branch__c,Offerengine_StopJourney_Flag__c FROM Final_Term__c where Loan_Application__c =: oldLoanApplicationId WITH SECURITY_ENFORCED LIMIT 1];
    // //Required_CRM_IRR__c,Tenure__c CISP-2342 - Removed these two field from the query
    //             if(finalTermList.size() > 0){
    //                 Final_Term__c finalTermObj = finalTermList[0];
    //                 Final_Term__c newFinalTermObj = finalTermObj.clone(false, false, false, false);
    //                 newFinalTermObj.Loan_Application__c = newLoanApplicationId;
    //                 if(Final_Term__c.SObjectType.getDescribe().isCreateable()){
    //                     insert newFinalTermObj;
    //                 }
    //             }
    //         } catch (Exception e) {
    //             ErrorLoggerUtil.logErrorEvent('IND_RevokeController', 'cloneFinalTerm', System.Label.Apex, e, oldLoanApplicationId);
    //             throw new AuraHandledException(System.Label.ExceptionMessage);
    //         }
    //     }
    // CISP-2342 - END
    
    @AuraEnabled
    public static void cloneCustomerDedpue(String oldLoanApplicationId, String newLoanApplicationId, Map<Id,Applicant__c> newApplicantMap){
        try {
            if (oldLoanApplicationId!=null && newLoanApplicationId!=null) {                

                List<Customer_Dedupe_Response__c> customerDedpueList = new List<Customer_Dedupe_Response__c>([Select id, SF_Cust_Dedupe__c, PG_Cust_Dedupe__c, Customer_Code__c, Invalid_Customer_Code__c, Dedupe_Journey_Status__c, Dedupe_Journey_Status_Reason__c, Response__c,Applicant__r.Applicant_Type__c,CIC_No__c,CIN_No__c,Customer_Status_Flag__c,Deal_Status_Flag__c,External_Dedupe_Status__c,Is_Journey_Skipped__c,IND_isNewCustomer__c from Customer_Dedupe_Response__c Where Applicant__c IN :newApplicantMap.keySet()]);//CISP-2809 - Added some fields in the query.//CISP-3116
                if (customerDedpueList.size() > 0) {
                    List<Customer_Dedupe_Response__c> newCustomerDedpueList = new List<Customer_Dedupe_Response__c>();
                    for(Customer_Dedupe_Response__c customerDedpue : customerDedpueList){
                        if(newApplicantMap.containskey(customerDedpue.Applicant__c)){
                            Customer_Dedupe_Response__c newCustomerDedpue = customerDedpue.clone(false, false, false, false);
                            newCustomerDedpue.Applicant__c = newApplicantMap.get(customerDedpue.Applicant__c).Id;
                            newCustomerDedpueList.add(newCustomerDedpue);
                        }
                    }
                    
                    if(newCustomerDedpueList.size() > 0 && Customer_Dedupe_Response__c.SObjectType.getDescribe().isCreateable()){
                        insert newCustomerDedpueList;
                    }
                }
            }
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_RevokeController', 'cloneCustomerDedpue', System.Label.Apex, e, oldLoanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    @AuraEnabled
    public static void cloneDocuments(String oldLoanApplicationId,String newLoanApplicationId, String revokeType, Map<Id,Applicant__c> newApplicantMap, List<Id> documentIds){//CISP-2328
        try {
            Opportunity oppRec = oppObj;
            if(oppRec.Product_Type__c == 'Tractor' && (oppRec.Vehicle_Type__c == 'Used' || oppRec.Vehicle_Type__c == 'Refinance')){
                cloneValuationReports(oldLoanApplicationId,newLoanApplicationId);
            } 
            List<String> floaterDocsList = new List<String>{'NOC','RC Document','IT Return or Saral','Salary Slip','Form 16','GST Certificate','RCU report','Cheques SPDC','Borrower\'s Passbook','Co-Borrower\'s Passbook','Borrower\'s Bank Statement','Co-Borrower\'s Bank Statement','Invoice','IHM Receipt','Agreement Copy','ACH Mandate Form','Cancelled Cheque','Agreement Wrapper Booklet','DPN','RTO','Agreement 1st Schedule','Agreement 2nd Schedule','DPR'};
            String kycRecordTypeId = (String) Schema.SObjectType.Documents__c.getRecordTypeInfosByDeveloperName().get(System.Label.KYC).getRecordTypeId();//CISP-2393
            Map<Id,Documents__c> existingDocumentMap = new Map<Id,Documents__c>([
                SELECT Id,Salutation__c,First_Name__c,Last_Name__c,Name, Document_Type__c, KYC_name__c , KYC_Address_Line_1__c, KYC_Address_Line_2__c , KYC_Pin_Code__c,KYC_No__c,Masked_KYC_No__c,Aadhaar_Enrollment_Number__c,KYC_City__c, KYC_District__c, KYC_State__c , Proof_of_Address_POA__c,Proof_of_Identity_POI__c,is_Front_Upload_Completed__c,Current_Residential_Address_Proof__c, Permanent_Residential_Address_Proof__c,RecordTypeId,Case__c,Is_Active__c,Applicant__c,Applicant__r.Applicant_Type__c,Age__c,Gender__c,KYC_DOB__c,PAN_No__c,Addresss_Type__c,Image__c,Aadhar_Source__c,Name_Mismatch_Percentage__c,Name_Mismatch_Pass__c,CMU_Accept_Reject__c,CMU_Rejection_Fields__c,Opportunity_Relation__r.LeadSource,Estimated_annual_income__c,CMU_Rejection_Reason__c,Rejection_Fields__c,IND_Aadhaar_Vault_Token_ID__c,DL_Type__c,KYC_Expiry_Date__c,KYC_Issuance_Date__c,KYC_Address_Line_3__c,KYC_Address_Line_4__c,Content_Document_Count__c,Document_Side__c,is_Back_Upload_Completed__c,Is_Front__c,Back_Upload_Attempts__c,Is_Back__c,Raw_Response__c,Front_Upload_Attempts__c,Passport_File_No__c,Passport_No__c,Address__c,Father_Name__c,Golden_Source_Attempts__c,Golden_Source_Pass__c,Mobile_number__c,PAN_acknowledgement_number__c,Number_of_persons_involved_in_the_transa__c,Amount_of_transaction__c,NSDL_Response__c,Pan_Approved__c,AadhaarSeedingStatus__c,Taluka__c,Landmark__c,Village__c,NSDLNameMatch__c,NSDLPANName__c,NSDLPANStatus__c,Opportunity_Relation__r.Product_Type__c From Documents__c Where Opportunity_Relation__c =: oldLoanApplicationId AND Is_Active__c = true AND (RecordTypeId =: kycRecordTypeId OR Current_Residential_Address_Proof__c = true OR Permanent_Residential_Address_Proof__c = true OR Document_Type__c = :System.Label.CustomerImageDocumentType OR Document_Type__c = :System.Label.Form60DocumentType OR Case__r.RecordType.Name =: System.label.CMU_Request  OR (Document_Type__c IN: floaterDocsList AND Opportunity_Relation__r.Product_Type__c =: Label.TwoWheeler)) AND Applicant__r.In_Active_Applicant__c = false AND Id NOT IN : documentIds 
            ]);////CISP-2393 Added another where clause of RecordTypeId.
            //CISP-2703 Added some more where clause filters and Added Addresss_Type__c,Image__c fields in the query.
            //CISP-2736/CISP-2753 - Aadhar_Source__c,Name_Mismatch_Percentage__c,Name_Mismatch_Pass__c
            //CISP-2686 -- Added document type or filter
            //CISP- 3405 -- Added Document type form 60 or condition in where clause
            
            Map<Id,Documents__c> newDocumentMap = new Map<Id,Documents__c>();
            for(Documents__c document : existingDocumentMap.values()){
                if(((revokeType == 'General Revoke' && (document.Applicant__r.Applicant_Type__c == System.Label.coBorrower || document.Applicant__r.Applicant_Type__c == System.Label.Borrower)) || (revokeType == 'Add/Change Co-Borrower' && document.Applicant__r.Applicant_Type__c == System.Label.Borrower) || revokeType == 'payandpayoutchanges' || revokeType == 'removecoborroweraddcoborrower' || revokeType == 'assetmodifications' || revokeType == 'removecoborroweraddcoborrowerbypeuser') && newApplicantMap.containskey(document.Applicant__c)){//CISP-2328
                    Documents__c newDocument = document.clone(false,false,false,false);
                    newDocument.Opportunity_Relation__c = newLoanApplicationId;
                    newDocument.Case__c = null;
                    //if(document.Opportunity_Relation__r.LeadSource == 'DSA' && document.Document_Type__c == 'PAN'){
                    //newDocument.PAN_No__c = IntegrationUtilities.getDecryptedResponse(document.PAN_No__c,System.Label.privateKey,System.Label.ivkey);
                    //}
                    newDocument.Applicant__c = newApplicantMap.containskey(document.Applicant__c) ? newApplicantMap.get(document.Applicant__c).Id : '';
                    newDocumentMap.put(document.Id,newDocument);
                }
            }//CISP-2328
            
            if(Documents__c.SObjectType.getDescribe().isCreateable()){
                insert newDocumentMap.values();
            }
            
            List<ContentDocumentLink> contentDocList = new List<ContentDocumentLink>();
            if(existingDocumentMap.keySet().size() > 0){
                for(ContentDocumentLink contDocLink : [Select ContentDocumentId,LinkedEntityId From ContentDocumentLink Where LinkedEntityId IN : existingDocumentMap.keySet() WITH SECURITY_ENFORCED]){
                    if(newDocumentMap.containskey(contDocLink.LinkedEntityId)){//CISP-2373 - Added if condition.
                        ContentDocumentLink newContDocLink = new ContentDocumentLink();
                        newContDocLink.ContentDocumentId = contDocLink.ContentDocumentId;
                        newContDocLink.LinkedEntityId = newDocumentMap.get(contDocLink.LinkedEntityId).Id;
                        contentDocList.add(newContDocLink);
                    }//CISP-2373 - if End
                }
            }
            
            if(contentDocList.size() > 0){
                globalContentDocList.addAll(contentDocList);
            }
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_RevokeController', 'cloneDocuments', System.Label.Apex, e, oldLoanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    @AuraEnabled
    public static List<Id> cloneRCUCase(String oldLoanApplicationId,String newLoanApplicationId, String recordType, List<Id> documentIds, Map<Id,Applicant__c> newApplicantMap){
        try {
            String recordTypeId = (String) Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
            List<Case> existingRCUCaseList = new List<Case>([SELECT Id,OwnerId,CaseNumber,Status,Overall_RCU_Agency_Sampling_Reason__c,
                                                            Overall_RCU_Agency_Verification_Remarks__c,Overall_RCU_Agency_Verification_Status__c,Overall_RCU_Sampling_Reason__c,
                                                            Overall_RCU_Verification_Remarks__c,Overall_RCU_Verification_Status__c,Type,
                                                            CreatedById,Description,RecordTypeId,AccountId,RCU_Agent__c,RCU_Manager__c,(Select Id,Document_Type__c,Applicant__c From Documents__r),ContactId 
                                                            FROM Case WHERE RecordTypeId =: recordTypeId and Loan_Application__c =: oldLoanApplicationId and ParentId = null 
                                                             LIMIT 1]);
            Map<Id,Case> newRCUCaseMap = new Map<Id,Case>();
            List<Case> existingNotifiedRCUCaseList = new List<Case>();
            List<Case> updateExistingCaseList = new List<Case>();
            Set<Id> userIds = new Set<Id>();
            Set<Id> newCaseOwnerIds = new Set<Id>();
            List<Opportunity> oppList = new List<Opportunity>([SELECT Id,Lead_number__c FROM Opportunity WHERE Id=: newLoanApplicationId WITH SECURITY_ENFORCED LIMIT 1]);
            String newLeadNumber = oppList.size() > 0 ? oppList[0].Lead_Number__c : '';
            Map<Id,Documents__c> existingRCUCaseDocMap = new Map<Id,Documents__c>();
            Set<Id> allRCUCaseId = new Set<Id>();
            if(!existingRCUCaseList.isEmpty()){
                for(Case caseInstance: [SELECT Id FROM Case WHERE ParentId =: existingRCUCaseList[0].Id]){
                    allRCUCaseId.add(caseInstance.Id);
                    caseInstance.Status = 'Closed- Revoke';
                    updateExistingCaseList.add(caseInstance);
                }
                allRCUCaseId.add(existingRCUCaseList[0].Id);
                existingRCUCaseDocMap = new Map<Id,Documents__c>([SELECT Id,Name,Document_Type__c,RecordTypeId,RCU_Agency_Verification_Status__c,RCU_Agency_Verification_Sub_Status__c,NCM_Comment__c,NCM_Status__c,SCM_Comment__c,SCM_Status__c,Applicant__c,is_Active__c,Salutation__c,First_Name__c,Last_Name__c, KYC_name__c , KYC_Address_Line_1__c, KYC_Address_Line_2__c , KYC_Pin_Code__c,KYC_No__c,Masked_KYC_No__c,Aadhaar_Enrollment_Number__c,KYC_City__c, KYC_District__c, KYC_State__c , Proof_of_Address_POA__c,Proof_of_Identity_POI__c,is_Front_Upload_Completed__c,Current_Residential_Address_Proof__c, Permanent_Residential_Address_Proof__c,Case__c,Applicant__r.Applicant_Type__c,Age__c,Gender__c,KYC_DOB__c,PAN_No__c,Addresss_Type__c,Image__c,Aadhar_Source__c,Name_Mismatch_Percentage__c,Name_Mismatch_Pass__c,CMU_Accept_Reject__c,CMU_Rejection_Fields__c,Opportunity_Relation__r.LeadSource,Rejection_Fields__c,CMU_Rejection_Reason__c,IND_Aadhaar_Vault_Token_ID__c,DL_Type__c,KYC_Expiry_Date__c,KYC_Issuance_Date__c,KYC_Address_Line_3__c,KYC_Address_Line_4__c,Content_Document_Count__c,Document_Side__c,is_Back_Upload_Completed__c,Is_Front__c,Back_Upload_Attempts__c,Is_Back__c,Raw_Response__c,Front_Upload_Attempts__c,Passport_File_No__c,Passport_No__c,Address__c,Father_Name__c,Golden_Source_Attempts__c,Golden_Source_Pass__c,Mobile_number__c,PAN_acknowledgement_number__c,Number_of_persons_involved_in_the_transa__c,Amount_of_transaction__c,NSDL_Response__c,Pan_Approved__c,AadhaarSeedingStatus__c,Taluka__c,Landmark__c,Village__c,NSDLNameMatch__c,NSDLPANName__c,NSDLPANStatus__c,RCU_Case__c From Documents__c where RCU_Case__c IN: allRCUCaseId And Is_Active__c=true And Id NOT IN: documentIds  LIMIT 50000]);

            }
            System.debug('existingRCUCaseDocMap-->'+existingRCUCaseDocMap);
            for(Case caseObj: existingRCUCaseList){
                Case newCase = caseObj.clone(false,false,false,false);
                newCase.Loan_Application__c = newLoanApplicationId;
                newCase.Subject = 'RCU Request for Loan Application -' + newLeadNumber;
                newCase.CreatedById = caseObj.CreatedById;
                newCase.Type = caseObj.Type;
                newRCUCaseMap.put(caseObj.Id,newCase);
                newCaseOwnerIds.add(caseObj.CreatedById);

                if(caseObj.Status != 'Closed'){
                    existingNotifiedRCUCaseList.add(caseObj);
                    userIds.add(caseObj.RCU_Agent__c);
                }
                caseObj.Description = 'Case is revoked at::'+string.valueOf(Datetime.now());
                caseObj.Status = 'Closed- Revoke';
                
            }
            if(Case.SObjectType.getDescribe().isCreateable()){//CISP-2328
                insert newRCUCaseMap.values();
            }
            if(newRCUCaseMap.values().size() > 0){
                List<Vehicle_Detail__c> vehicleList = new List<Vehicle_Detail__c>([Select Id FROM Vehicle_Detail__c Where Loan_Application__c =: newLoanApplicationId]);
                for (Vehicle_Detail__c vehicleObj : vehicleList) {
                    vehicleObj.Parent_RCU_Case__c = newRCUCaseMap.values()[0].Id;
                }
                if(vehicleList.size() > 0){
                    update vehicleList;
                }
            }
            
            if(Case.SObjectType.getDescribe().isUpdateable()){
                if(!updateExistingCaseList.isEmpty())
                    update updateExistingCaseList;
                update existingRCUCaseList;
            }


            Map<Id,User> newCaseUserMap = new Map<Id,User>();
            if(newCaseOwnerIds.size() > 0){
                newCaseUserMap.putAll([Select Id,IsActive From User Where Id IN : userIds]);
            }
            
            for(Case caseObj : [Select Id,CaseNumber,OwnerId From Case Where Id IN: newRCUCaseMap.values()]){
                if(newCaseUserMap.containsKey(caseObj.OwnerId) && newCaseUserMap.get(caseObj.OwnerId).IsActive){
                    CustomNotificationWrapper customNotification = new CustomNotificationWrapper();
                    customNotification.caseId = caseObj.Id;
                    customNotification.notificationTitle = 'Case Assignment';
                    customNotification.notificationBody = 'Case ' + caseObj.CaseNumber + ' has been assigned to you.';
                    customNotification.ownerId = caseObj.OwnerId;
                    IND_RevokeController.sendCustomNotification(customNotification);
                }
            }
            //CISP-2328 - START
            Map<Id,User> userMap = new Map<Id,User>();
            if(userIds.size() > 0){
                userMap.putAll([Select Id,IsActive From User Where Id IN : userIds]);
            }
            for(Case caseObj : existingNotifiedRCUCaseList){
                if(userMap.containsKey(caseObj.OwnerId) && userMap.get(caseObj.OwnerId).IsActive){
                    CustomNotificationWrapper customNotification = new CustomNotificationWrapper();
                    customNotification.caseId = caseObj.Id;
                    customNotification.notificationTitle = 'Case revoked';
                    customNotification.notificationBody = 'Case ' + caseObj.CaseNumber + ' has been closed.';
                    customNotification.ownerId = caseObj.OwnerId;
                    IND_RevokeController.sendCustomNotification(customNotification);
                }
            }
            
            if(newRCUCaseMap.size() > 0){
                Map<Id,Documents__c> newDocumentMap = new Map<Id,Documents__c>();
                for(Documents__c doc : existingRCUCaseDocMap.values()){
                    if(newApplicantMap.containskey(doc.Applicant__c)){
                        Documents__c newDoc = doc.clone(false,false,false,false);
                        newDoc.Opportunity_Relation__c = newLoanApplicationId;
                        if(newRCUCaseMap.containsKey(newDoc.RCU_Case__c)){
                            newDoc.RCU_Case__c = newRCUCaseMap.get(newDoc.RCU_Case__c).Id;
                        }
                        newDoc.Case__c = null;
                        newDoc.Applicant__c = newApplicantMap.containskey(doc.Applicant__c) ? newApplicantMap.get(doc.Applicant__c).Id : '';
                        newDocumentMap.put(doc.Id,newDoc);
                    }
                }

                if(Documents__c.SObjectType.getDescribe().isCreateable() && !newDocumentMap.isEmpty()){
                    insert newDocumentMap.values();
                }

                List<ContentDocumentLink> contentDocList = new List<ContentDocumentLink>();
                if(!existingRCUCaseDocMap.isEmpty()){
                    for(ContentDocumentLink contDocLink : [Select ContentDocumentId,LinkedEntityId From ContentDocumentLink Where LinkedEntityId IN : existingRCUCaseDocMap.keySet() WITH SECURITY_ENFORCED]){
                        if(newDocumentMap.containskey(contDocLink.LinkedEntityId)){//CISP-2373 - Added if condition.
                            ContentDocumentLink newContDocLink = new ContentDocumentLink();
                            newContDocLink.ContentDocumentId = contDocLink.ContentDocumentId;
                            newContDocLink.LinkedEntityId = newDocumentMap.get(contDocLink.LinkedEntityId).Id;
                            contentDocList.add(newContDocLink);
                        }//CISP-2373 - if End
                    }
                }
                
                if(contentDocList.size() > 0){
                    globalContentDocList.addAll(contentDocList);
                }
                
                
            }
            
            List<OpportunityTeamMember> oldTeamMemberList = new List<OpportunityTeamMember>();
            oldTeamMemberList = [Select id,OpportunityAccessLevel,UserId, TeamMemberRole   from OpportunityTeamMember Where OpportunityId =: oldLoanApplicationId];
            
            List<OpportunityTeamMember> newTeamMemberList = new List<OpportunityTeamMember>();
            
            for(OpportunityTeamMember oldOppTeamMember : oldTeamMemberList){
                OpportunityTeamMember newOppTeamMember = oldOppTeamMember.clone(false,false,false,false);
                newOppTeamMember.OpportunityId = newLoanApplicationId;
                newTeamMemberList.add(newOppTeamMember);
            }
            insert newTeamMemberList;

            List<Id> documentIdsList = new List<Id>();
            documentIdsList.addAll(existingRCUCaseDocMap.keySet());

            return documentIdsList;

        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_RevokeController', 'cloneRCUCase', System.Label.Apex, e, oldLoanApplicationId);
            throw new AuraHandledException(e.getMessage());
        }
    }
    //SFTRAC-411 Chaynnitt Agarwal
    public static void cloneValuationReports(String oldLoanApplicationId,String newLoanApplicationId){
        try{
            List<Vehicle_Detail__c> vehLst = [SELECT Id FROM Vehicle_Detail__c WHERE Loan_Application__c=: oldLoanApplicationId WITH SECURITY_ENFORCED];
            List<Documents__c> docValuationLst = [SELECT Id, Opportunity_Relation__c, Asset_Verification__c, Asset_Verification__r.Vehicle_Detail__c 
                                            FROM Documents__c 
                                            WHERE RecordType.Name = 'Asset Verification Documents' AND Asset_Verification__r.Vehicle_Detail__c IN :vehLst
                                            WITH SECURITY_ENFORCED];
            Map<Id,Boolean> vehValuationMap = new Map<Id,Boolean>();
            
            for(Vehicle_Detail__c veh: vehLst){
                vehValuationMap.put(veh.Id,false);
            }
            
            for(Documents__c doc: docValuationLst){
                vehValuationMap.put(doc.Asset_Verification__r.Vehicle_Detail__c,true);
            }

            for(Id key: vehValuationMap.keySet()){
                if(vehValuationMap.get(key) == false){
                    return;
                }
            }

            //Clone Valuation Report Doc code - Given the below code execute if all vehicle valuation documents present.

            Map<Id,Documents__c> existingDocumentMap = new Map<Id,Documents__c>([
                SELECT Id , Name , Document_Type__c,RecordTypeId, Is_Active__c, Applicant__c, Opportunity_Relation__c, Content_Document_Count__c
                FROM Documents__c 
                WHERE Opportunity_Relation__c =: oldLoanApplicationId AND Document_Type__c = 'Valuation Report' AND Is_Active__c = true AND Applicant__r.In_Active_Applicant__c = false
            ]);

            Map<Id,Documents__c> newDocumentMap = new Map<Id,Documents__c>();
            for(Documents__c document : existingDocumentMap.values()){
                Documents__c newDocument = document.clone(false,false,false,false);
                newDocument.Opportunity_Relation__c = newLoanApplicationId;
                newDocumentMap.put(document.Id,newDocument);
            }
            
            if(Documents__c.SObjectType.getDescribe().isCreateable()){
                insert newDocumentMap.values();
            }
            
            List<ContentDocumentLink> contentDocList = new List<ContentDocumentLink>();
            if(existingDocumentMap.keySet().size() > 0){
                for(ContentDocumentLink contDocLink : [Select ContentDocumentId,LinkedEntityId From ContentDocumentLink Where LinkedEntityId IN : existingDocumentMap.keySet() WITH SECURITY_ENFORCED]){
                    if(newDocumentMap.containskey(contDocLink.LinkedEntityId)){
                        ContentDocumentLink newContDocLink = new ContentDocumentLink();
                        newContDocLink.ContentDocumentId = contDocLink.ContentDocumentId;
                        newContDocLink.LinkedEntityId = newDocumentMap.get(contDocLink.LinkedEntityId).Id;
                        contentDocList.add(newContDocLink);
                    }
                }
            }
            
            if(contentDocList.size() > 0){
                globalContentDocList.addAll(contentDocList);
            }

            notifyValuationReportOwners(newLoanApplicationId);

        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_RevokeController', 'cloneValuationReports', System.Label.Apex, e, oldLoanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    public static void notifyValuationReportOwners(String newLoanApplicationId){
        Opportunity oppRec = [SELECT Id, OwnerId FROM Opportunity WHERE Id =: newLoanApplicationId WITH SECURITY_ENFORCED ];
        // Get the Id for our custom notification type
        CustomNotificationType notificationType = [SELECT Id, DeveloperName 
                                                    FROM CustomNotificationType 
                                                    WHERE DeveloperName='Valuation_Report_Cloned_Notification'];

        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();

        // Set the contents for the notification
        notification.setTitle('Valuation Report Cloned Notification');
        notification.setBody('Upon Revoke since all the vehicle valuation has been completed. Valuation report has been cloned.');

        // Set the notification type and target
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(oppRec.Id);

        Set<String> addressee = new Set<String>();
        addressee.add(oppRec.OwnerId);

        // Actually send the notification
        try {
            notification.send(addressee);
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }

    
    @AuraEnabled
    public static void cloneCMUCase(String oldLoanApplicationId, String newLoanApplicationId,String recordType, String revokeType){
        try {
            String recordTypeId = (String) Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
            String kycRecordTypeId = (String) Schema.SObjectType.Documents__c.getRecordTypeInfosByDeveloperName().get(System.Label.KYC).getRecordTypeId();//CISP-2328
            String queueId = [select Id from Group where Name = :System.Label.CMU and Type = :System.Label.Queue LIMIT 1].Id ;//CISP-2328
            
            List<Case> existingCMUCaseList = new List<Case>([
                SELECT Id,OwnerId,CMU_Rejected__c,CaseNumber,Status,CreatedById,Description,RecordTypeId,AccountId,(Select Id,Document_Type__c From Documents__r),ContactId From Case WHERE Loan_Application__c =: oldLoanApplicationId AND RecordTypeId =: recordTypeId
            ]);//CISP-2867
            List<Case> newCMUCaseList = new List<Case>();
            List<Case> existingNotifiedCMUCaseList = new List<Case>();//CISP-2328
            Set<Id> userIds = new Set<Id>();
            Set<Id> newCaseOwnerIds = new Set<Id>();
            List<Opportunity> oppList = new List<Opportunity>([Select Id,Lead_number__c From Opportunity Where Id=: newLoanApplicationId WITH SECURITY_ENFORCED LIMIT 1]);
            String newLeadNumber = oppList.size() > 0 ? oppList[0].Lead_Number__c : '';
            List<Documents__c> existingCMUCaseDocList = new List<Documents__c>();//CISP-2867
            for(Case caseObj : existingCMUCaseList){
                //CISP-2328 - START
                if(revokeType == 'General Revoke' || revokeType == 'payandpayoutchanges' || revokeType == 'assetmodifications'){
                    existingCMUCaseDocList.addAll(caseObj.Documents__r);//CISP-2867
                    Case newCase = caseObj.clone(false,false,false,false);
                    //Update status of new case
                    newCase.Loan_Application__c = newLoanApplicationId;
                    newCase.Subject = 'CMU Request for Loan Application -' + newLeadNumber;
                    newCase.Status = (caseObj.Status == 'Closed') ? 'Closed' : (caseObj.Status == 'Pending with Sales') ? caseObj.Status : (caseObj.Status == 'Pending with CMU') ? caseObj.Status : 'New';//CISP-2700 Changes Open to new
                    newCase.CMU_Rejected__c = (caseObj.Status == 'Pending with Sales') ? true : false;
                    newCase.OwnerId = (caseObj.Status == 'Pending with Sales') ? (String.isNotBlank(IND_RevokeController.ownerId) ? IND_RevokeController.ownerId : caseObj.CreatedById) : (caseObj.Status == 'Closed') ? caseObj.OwnerId :  (caseObj.Status == 'Pending with CMU') ? caseObj.OwnerId : (caseObj.Status == 'New') ? queueId : queueId;
                    newCase.CreatedById = caseObj.CreatedById;
                    newCMUCaseList.add(newCase);//CISP-2328
                    newCaseOwnerIds.add(caseObj.CreatedById);
                }
                //CISP-2328 - END
                
                //Update status of old case
                //CISP-2328 - START
                if(caseObj.Status != 'Closed'){
                    existingNotifiedCMUCaseList.add(caseObj);
                    userIds.add(caseObj.OwnerId);
                }
                if(revokeType == 'General Revoke' || revokeType == 'payandpayoutchanges' || revokeType == 'assetmodifications' ){
                    caseObj.Status = caseObj.Status == 'Closed' ? 'Closed-Revoke' : 'Closed';
                }else{
                    caseObj.Status = 'Closed';
                }
                //CISP-2328 - END
                caseObj.Description = 'Case is revoked at::'+string.valueOf(Datetime.now());
                
            }
            if(Case.SObjectType.getDescribe().isCreateable() && (revokeType == 'General Revoke' || revokeType == 'payandpayoutchanges' || revokeType == 'assetmodifications' )){//CISP-2328
                insert newCMUCaseList;
            }
            
            if(Case.SObjectType.getDescribe().isUpdateable()){
                update existingCMUCaseList;
            }

            Map<Id,User> newCaseUserMap = new Map<Id,User>();
            if(newCaseOwnerIds.size() > 0){
                newCaseUserMap.putAll([Select Id,IsActive From User Where Id IN : userIds]);
            }
            
            for(Case caseObj : newCMUCaseList){
                if(newCaseUserMap.containsKey(caseObj.OwnerId) && newCaseUserMap.get(caseObj.OwnerId).IsActive){
                    CustomNotificationWrapper customNotification = new CustomNotificationWrapper();
                    customNotification.caseId = caseObj.Id;
                    customNotification.notificationTitle = 'Case Assignment';
                    customNotification.notificationBody = 'Case ' + caseObj.CaseNumber + ' has been assigned to you.';
                    customNotification.ownerId = caseObj.OwnerId;
                    IND_RevokeController.sendCustomNotification(customNotification);
                }
            }
            //CISP-2328 - START
            Map<Id,User> userMap = new Map<Id,User>();
            if(userIds.size() > 0){
                userMap.putAll([Select Id,IsActive From User Where Id IN : userIds]);
            }
            for(Case caseObj : existingNotifiedCMUCaseList){
                if(userMap.containsKey(caseObj.OwnerId) && userMap.get(caseObj.OwnerId).IsActive){
                    CustomNotificationWrapper customNotification = new CustomNotificationWrapper();
                    customNotification.caseId = caseObj.Id;
                    customNotification.notificationTitle = 'Case revoked';
                    customNotification.notificationBody = 'Case ' + caseObj.CaseNumber + ' has been closed.';
                    customNotification.ownerId = queueId;
                    IND_RevokeController.sendCustomNotification(customNotification);
                }
            }
            
            if(newCMUCaseList.size() > 0){
                //CISP-2867-START
                Set<String> documentTypeSet = new Set<String>();
                for(Documents__c doc : existingCMUCaseDocList){
                    documentTypeSet.add(doc.Document_Type__c);
                }
                List<Documents__c> documentList = new List<Documents__c>([SELECT Id,Case__c,Document_Type__c From Documents__c Where Opportunity_Relation__c =: newLoanApplicationId AND Is_Active__c = true AND Document_Type__c IN: documentTypeSet WITH SECURITY_ENFORCED
                                                                         ]);
                //CISP-2867-END
                //CISP-2686 -- Added document type or filter
                for(Documents__c document : documentList){
                    document.Case__c = newCMUCaseList[0].Id;
                }
                if(Documents__c.SObjectType.getDescribe().isUpdateable()){
                    update documentList;
                }
            }
            
            List<OpportunityTeamMember> oldTeamMemberList = new List<OpportunityTeamMember>();
            oldTeamMemberList = [Select id,OpportunityAccessLevel,UserId, TeamMemberRole   from OpportunityTeamMember Where OpportunityId =: oldLoanApplicationId];
            
            List<OpportunityTeamMember> newTeamMemberList = new List<OpportunityTeamMember>();
            
            for(OpportunityTeamMember oldOppTeamMember : oldTeamMemberList){
                OpportunityTeamMember newOppTeamMember = oldOppTeamMember.clone(false,false,false,false);
                newOppTeamMember.OpportunityId = newLoanApplicationId;
                newTeamMemberList.add(newOppTeamMember);
            }
            insert newTeamMemberList;
            //CISP-2328 - END
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_RevokeController', 'cloneCMUCase', System.Label.Apex, e, oldLoanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    @AuraEnabled
    public static void updateOldCase(String oldLoanApplicationId, List<String> caseRecordTypeList){
        try {
            Map<Id,RecordType> recordTypeMap = new Map<Id,RecordType>([SELECT id from RecordType where DeveloperName IN : caseRecordTypeList]);
            List<Case> existingCaseList = new List<Case>([
                SELECT Id,OwnerId,CaseNumber From Case WHERE Loan_Application__c =: oldLoanApplicationId AND RecordTypeId IN : recordTypeMap.keySet() WITH SECURITY_ENFORCED
            ]);//  CISP-2527
            
            for(Case caseObj : existingCaseList){
                caseObj.status = 'Closed-Revoke';
                caseObj.Description = 'Case is revoked at::'+string.valueOf(Datetime.now());
            }
            
            if(Case.SObjectType.getDescribe().isUpdateable()){
                update existingCaseList;
            }
            
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_RevokeController', 'updateOldCase', System.Label.Apex, e, oldLoanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    @AuraEnabled
    public static void copyAssetVerificationCase(String oldLoanApplicationId,String newLoanApplicationId,Map<Id,Applicant__c> applicantMap,Map<Id,Vehicle_Detail__c> vehicleMap){
        try {
            List<Case> existingCaseList = new List<Case>();
            List<Opportunity> oppList = new List<Opportunity>([Select Id,Lead_number__c From Opportunity Where Id=: newLoanApplicationId WITH SECURITY_ENFORCED LIMIT 1]);
            String newLeadNumber = oppList.size() > 0 ? oppList[0].Lead_Number__c : '';
            existingCaseList = new List<Case>([SELECT Id,OwnerId,CaseNumber,Status,CreatedById,Description,RecordTypeId,AccountId,Subject,Applicant__c,Applicant__r.Applicant_Type__c,(Select Id,Document_Type__c From Documents__r),ContactId,type,Loan_Application__r.Name From Case WHERE Loan_Application__c =: oldLoanApplicationId AND RecordType.name ='Asset Verification' AND (Status = 'Completed' OR Status = 'In Progress' OR Status = 'New') AND Applicant__r.In_Active_Applicant__c = false AND Applicant__c IN: applicantMap.keySet()]);
            Map<String ,Case> caseTypeVsCaseMap = new Map<String ,Case>();
            Map<Id,Asset_Verification__c> newAssetVerificationMap = new Map<Id,Asset_Verification__c>();
            if(existingCaseList.size() > 0){
                List<Documents__c> assetVeriCaseDocList = new List<Documents__c>();
                for (Case caseObj : existingCaseList) { 
                    if(!caseObj.Subject.contains('PD Asset Verification Case') && applicantMap.containskey(caseObj.Applicant__c)){
                        assetVeriCaseDocList.addAll(caseObj.Documents__r);
                        Case newCase = caseObj.clone(false,false,false,false);
                        newCase.Loan_Application__c = newLoanApplicationId;
                        String statusOfCase = caseObj.Subject;
                        String caseStatus = statusOfCase.substring(statusOfCase.indexOf(' '));
                        newCase.subject = newLeadNumber + caseStatus;
                        newCase.Status = 'New';
                        newCase.Applicant__c = applicantMap.get(caseObj.Applicant__c).Id;
                        caseTypeVsCaseMap.put(caseObj.Id, newCase);
                    }
                }
                if (caseTypeVsCaseMap.size() > 0) {
                    insert caseTypeVsCaseMap.values();
                    for(Case caseObj : [SELECT Id,OwnerId,CaseNumber,Status,CreatedById,Description,RecordTypeId,AccountId,Subject,Applicant__c,Applicant__r.Applicant_Type__c,type,Loan_Application__r.Name From Case WHERE Id IN: caseTypeVsCaseMap.values()]){
                            CustomNotificationWrapper customNotification = new CustomNotificationWrapper();
                            customNotification.caseId = caseObj.Id;
                            customNotification.notificationTitle = 'Case Assignment';
                            customNotification.notificationBody = 'Asset Verification Case No. '+  caseObj.CaseNumber  +' is assinged to you for Lead No. ' + caseObj.Loan_Application__r.Name + '. Click here to take action on this case.';
                            customNotification.ownerId = caseObj.OwnerId;
                            IND_RevokeController.sendCustomNotification(customNotification);
                    }
                    List<Asset_Verification__c> existingAssVerification = [SELECT ID, Name,Applicant__c,Asset_MMV__c,Case__c,Chasis_No__c,Date_of_Delivery__c,Engine_No__c,HMR__c,Hypothetation_available__c,Insurance_Validity_Date__c,RC_No__c,Serial_No__c,Status__c,Vehicle_Detail__c,Is_Post_Sanction_Verified_Asset__c,PDAV_Remarks__c,PDAV_Status__c,RC_in_the_name_of__c,Type_of_AV__c,Engine_and_Chassis_Number_Matches__c,Case__r.Applicant__c FROM Asset_Verification__c WHERE Case__c IN: existingCaseList];
                    for(Asset_Verification__c assetObj : existingAssVerification){
                        if(caseTypeVsCaseMap.containsKey(assetObj.Case__c) && applicantMap.containsKey(assetObj.Case__r.Applicant__c) && vehicleMap.containsKey(assetObj.Vehicle_Detail__c)){
                            Asset_Verification__c newAssetObj = assetObj.clone(false,false,false,false);
                            newAssetObj.Case__c = caseTypeVsCaseMap.get(assetObj.Case__c).Id;
                            newAssetObj.Applicant__c = applicantMap.get(assetObj.Case__r.Applicant__c).Id;
                            newAssetObj.Vehicle_Detail__c = vehicleMap.get(assetObj.Vehicle_Detail__c).Id;
                            newAssetObj.Status__c = 'New';
                            newAssetVerificationMap.put(assetObj.Id,newAssetObj);
                        }
                    }
                    if(newAssetVerificationMap.size() >0){insert newAssetVerificationMap.values();}
                    if(assetVeriCaseDocList.size() > 0){
                        Set<Id> assetVeriCaseDocSet = new Set<Id>();
                        for (Documents__c docObj : assetVeriCaseDocList) {
                            assetVeriCaseDocSet.add(docObj.Id);
                        }
                        Map<Id,Documents__c> existingDocumentMap = new Map<Id,Documents__c>([SELECT Id,Salutation__c,First_Name__c,Last_Name__c,Name, Document_Type__c,RecordTypeId,Case__c,Is_Active__c,Applicant__c,Case__r.Type,Vehicle_Detail__c,Vehicle_Detail__r.Serial_number__c,Asset_Verification__c FROM Documents__c WHERE Opportunity_Relation__c =: oldLoanApplicationId AND Is_Active__c = true AND Id IN : assetVeriCaseDocSet AND Applicant__r.In_Active_Applicant__c = false AND is_Active__c = true ORDER BY Case__c]);
                
                        Map<Id,Documents__c> newDocumentMap = new Map<Id,Documents__c>();
                        for(Documents__c document : existingDocumentMap.values()){
                            if(caseTypeVsCaseMap.containsKey(document.Case__c) && newAssetVerificationMap.containsKey(document.Asset_Verification__c) && vehicleMap.containsKey(document.Vehicle_Detail__c)){
                                Documents__c newDocument = document.clone(false,false,false,false);
                                newDocument.Opportunity_Relation__c = newLoanApplicationId;
                                newDocument.Applicant__c = caseTypeVsCaseMap.get(document.Case__c).Applicant__c;
                                newDocument.Case__c = caseTypeVsCaseMap.get(document.Case__c).Id;
                                newDocument.Vehicle_Detail__c = vehicleMap.get(document.Vehicle_Detail__c).Id;
                                newDocument.Asset_Verification__c = newAssetVerificationMap.get(document.Asset_Verification__c).Id;
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
            
                        if(contentDocList.size() > 0){
                            globalContentDocList.addAll(contentDocList);
                        }
                    }
                }
            }
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_RevokeController', 'copyAssetVerificationCase', System.Label.Apex, e, oldLoanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    //SFTRAC-166 start
    @AuraEnabled
    public static void copyClosedFICases(String oldLoanApplicationId,String newLoanApplicationId, String revokeType,Map<Id,Applicant__c> applicantMap){
        try {
            Map<Id,RecordType> recordTypeMap = new Map<Id,RecordType>([SELECT id from RecordType where DeveloperName = 'FI']);
            List<Opportunity> oppList = new List<Opportunity>([Select Id,Lead_number__c From Opportunity Where Id=: newLoanApplicationId WITH SECURITY_ENFORCED LIMIT 1]);
            String newLeadNumber = oppList.size() > 0 ? oppList[0].Lead_Number__c : '';
           
            List<Case> existingCaseList = new List<Case>();
           
            if(revokeType == 'payandpayoutchanges' || revokeType == 'assetmodifications' || revokeType == 'removecoborroweraddcoborrower' || revokeType == 'removecoborroweraddcoborrowerbypeuser'){
                existingCaseList = new List<Case>([SELECT Id,OwnerId,CaseNumber,Status,CreatedById,Description,RecordTypeId,AccountId,Subject,Applicant__c,Applicant__r.Applicant_Type__c,(Select Id,Document_Type__c From Documents__r),ContactId,type,Loan_Application__r.Name From Case WHERE RejectedFI__c = false AND Loan_Application__c =: oldLoanApplicationId AND RecordTypeId IN : recordTypeMap.keySet() AND (Status = 'Completed' OR Status = 'Accepted' OR Status = 'FI-Unassigned') AND Applicant__r.In_Active_Applicant__c = false AND Applicant__c IN: applicantMap.keySet()]);
            }
            Map<String ,Case> caseTypeVsCaseMap = new Map<String ,Case>();
            if(existingCaseList.size() > 0){
                List<Documents__c> fiCaseDocList = new List<Documents__c>();
                for (Case caseObj : existingCaseList) {
                    fiCaseDocList.addAll(caseObj.Documents__r);
                    Case newCase = caseObj.clone(false,false,false,false);
                    newCase.Loan_Application__c = newLoanApplicationId;
                    String statusOfCase = caseObj.Subject;
                    String caseStatus = statusOfCase.substring(statusOfCase.indexOf('_'));
                    newCase.subject = newLeadNumber + caseStatus;
                    if(((revokeType == 'payandpayoutchanges' || revokeType == 'assetmodifications') && caseObj.Applicant__r.Applicant_Type__c == Label.Borrower && caseObj.Type == 'Current Residence FI') || (revokeType == 'removecoborroweraddcoborrowerbypeuser')){
                        newCase.Status = 'FI-Unassigned';
                    }else{
                        newCase.Status = caseObj.Status == 'Accepted' ? 'Completed' : caseObj.Status;
                    }
                    newCase.Applicant__c = applicantMap.containskey(caseObj.Applicant__c) ? applicantMap.get(caseObj.Applicant__c).Id : caseObj.Applicant__c;
                    if(!caseTypeVsCaseMap.containsKey(caseObj.Type + caseObj.Applicant__c)){
                        caseTypeVsCaseMap.put(caseObj.Type + caseObj.Applicant__c, newCase);
                    }
                }
                if (caseTypeVsCaseMap.size() > 0) {
                    insert caseTypeVsCaseMap.values();
                    for(Case caseObj : [SELECT Id,OwnerId,CaseNumber,Status,CreatedById,Description,RecordTypeId,AccountId,Subject,Applicant__c,Applicant__r.Applicant_Type__c,type,Loan_Application__r.Name From Case WHERE Id IN: caseTypeVsCaseMap.values()]){
                        if(((revokeType == 'payandpayoutchanges' || revokeType == 'assetmodifications') && caseObj.Applicant__r.Applicant_Type__c == Label.Borrower && caseObj.Type == 'Current Residence FI' && caseObj.Status == 'FI-Unassigned') || (revokeType == 'removecoborroweraddcoborrowerbypeuser')){
                            CustomNotificationWrapper customNotification = new CustomNotificationWrapper();
                            customNotification.caseId = caseObj.Id;
                            customNotification.notificationTitle = 'Case Assignment';
                            customNotification.notificationBody = 'FI Case No. '+  caseObj.CaseNumber  +' is assinged to you for Lead No. ' + caseObj.Loan_Application__r.Name + '. Click here to take action on this case.';
                            customNotification.ownerId = caseObj.OwnerId;
                            IND_RevokeController.sendCustomNotification(customNotification);
                        }
                    }
                    List<Field_Investigation__c> fieldInvestigationList = new List<Field_Investigation__c>();
                    Map<Id,Field_Investigation__c> newFieldInvestigationMap = new Map<Id,Field_Investigation__c>();
                    fieldInvestigationList = [SELECT RecordTypeId,Case__r.Type,Case__r.Applicant__c,Id,Name,Case__c,Address_Verified_with_KYC__c,Color_Code__c,Address_Line_1__c,Address_Line_2__c,Affiliation_to_e_commerce__c,Annual_Turnover__c,ANY_NEGATIVE_OR_CAUTION_PROFILE__c,Are_Co_ordinates_Matching_If_Amber__c,Area__c,Average_Professional_Fee_Service_Rs__c,Average_Ticket_Size_Rs__c,Average_no_of_customers__c,Business_Premise__c,Category__c,City__c,AC_Installed__c,Current_experience_years__c,Customer_house_same_as_in_application__c,Declared_Income_During_Application__c,Agri_Commercial__c,Any_KCC_loan_running__c,Employer_Business_Name__c,Estimated_Average_Income_per_month__c,Estimated_Income_as_per_FI__c,Estimated_Service_FI__c,Estimated_Service_Income_as_per_FI__c,Estimated_Total_Monthly_Income__c,FI_Feedback__c,FI_Location__Latitude__s,FI_Location__Longitude__s,FI_Location__c,is_Active__c,FI_Request_Generation_Date_Time__c,Final_Income__c,GeoCoder_Latitude_and_Longitude__Latitude__s,GeoCoder_Latitude_and_Longitude__Longitude__s,GeoCoder_Latitude_and_Longitude__c,Income__c,Income_as_per_FI_Visit__c,Income_per_month__c,Income_per_month_property__c,Inhouse_Security_Camera_present__c,Irrigation_system_present__c,KYC_Location__Latitude__s,KYC_Location__Longitude__s,KYC_Location__c,Land_Photo__c,Landmark__c,Latest_Electricity_Bill_Amount_Paid_Mont__c,Latest_Telephone_Bill_Amount_Paid_Month__c,Latest_Water_Bill__c,List_of_equipment_tools_owned__c,Location__c,Mobile__c,Monthly_Income_as_per_FI_Visit__c,Monthly_Sales__c,Name_of_Person_met__c,No_of_Attempts__c,No_of_Cattle__c,Any_Margin_money_pending_with_dealer__c,No_of_Service_Requests_catered_in_month__c,No_of_contracts_awarded_in_last_1_year__c,No_of_crops_per_annum__c,No_of_vehicles_owned__c,Number_of_Properties_rented__c,Number_of_operational_hours_in_a_day__c,Any_existing_TractorHarvester_Loan__c,Any_existing_loans_like_TWHLCARPL__c,Approximate_Value_of_Agri_land__c,Office_FI_Accepted_Rejected__c,Office_FI_Completion_Time__c,Own_Equipment_Tools__c,Access_to_Tubewells__c,Patta_Document_available__c,Applicant_Recognized__c,Phone_Number__c,Pin_Code__c,Political_Photo__c,Price_per_unit__c,Product__c,Profile__c,Profit_Margin__c,Coordinates_Verified__c,Remarks__c,Residence_FI_Status__c,Residence_FI_completion_time__c,Same_Addresst_as_in_the_Application__c,State__c,IS_CO_BORROWER_HAVE_ANY_POLITICAL_RELATI__c,Asset_model_Variant_as_per__c,Do_you_have_any_government_contracts__c,Type_of_House__c,Type_of_goods_sold__c,Assets_at_Home_Sum_up__c,Upload_Pension_Document__c,Upload_Rent_Agreement_Reciept__c,Yield_Per_Acre_monthly__c,Coordinates_Distance__c,FI_Observation__c,FI_Status__c,No_of_2_Wheelers__c,No_of_3_Wheelers__c,No_of_4_Wheelers__c,No_of_ACs__c,No_of_CVs__c,No_of_Computers__c,No_of_Fridges__c,No_of_Sofas__c,No_of_TVs__c,No_of_Washing_Machines__c,Number_of_Dependent__c,Number_of_Earning_Member_in_Family__c,Office_FI_Status__c,Profile_to_Product_Match__c,Purpose_of_Purchase__c,Relationship__c,Residence_Type__c,SENP_Agriculture_Income__c,SENP_Contractor_Income__c,SENP_Own_Shop_Income__c,SENP_Pension_Income__c,SENP_Rental_Income__c,SENP_Service_oriented_Income__c,SENP_Transporter_Income__c,Years_in_CIty__c,Years_in_Residence__c,POS_Machine__c,Payment_Proof_Shown__c,Type_of_Crop__c,Payment_Proof_shown_for_Electricity_Bill__c,Telephone_Bill_Payment_Proof_Shown__c,Electricity_Connection_Present__c,No_of_Employees__c,Office_Business_Board__c,Office_Business_Size_Sqft__c,Office_Business_Type__c,Total_Experience_Years__c,Touring_or_Transferable_Job__c,Types_of_vehicles_owned__c,BORROWER_KNOWN_TO_Gurantor_SINCE__c,BROKER_DETAILS_FOR_HARVESTER__c,Basic_FI_address_to_be_populated_in_FI__c,Borrower_Having_Valid_Driving_licence__c,CATTLE_NAME__c,Caste__c,Collection_FI__c,Crop_details_cultivated_last_year__c,Crop_sold_to_any_specific_person__c,Current_Addr_is_different_than_KYC_Addr__c,Current_cropping_pattern_details__c,DEPLOYMENT_OF_ASSET__c,Distance_from_Borrower_to_Co_borrower__c,Distance_from_Branch_to_customer__c,Existing_Tractor_Loan_details__c,Existing_no_of_vehicles__c,Existing_other_Loan_details__c,Expense_of_higher_education_of_family__c,Expenses_for_vehicle_maintenance__c,FI_OBSERVATION_1__c,FI_RESULT__c,Gender__c,HOW_HE_WILL_DEPLOY_THE_ASSET__c,House_Type__c,House_ownership__c,How_many_members_in_the_Family__c,How_much_margin_amount_paid_to_Dealer__c,IBL_TFE_customer_borrower_count__c,IF_EXCHANGE_OF_ASSET__c,IF_NEGATIVE_THEN_REASON_FOR_NEGATIVE__c,IF_YES_ANY_IMPECT_OF_OUR_RECOVERY__c,IN_LAST_5_YEARS_ANY_DRAUGHTFlood__c,Father_DOB__c,IS_CUSTOMER_HAVING_IMPLEMENT__c,If_the_source_of_margin_money_is_CASH__c,If_yes_provide_details_of_damage__c,Is_CO_BORROWER_LIVING_WITH_BORROWER__c,Is_coborrower_existing_customer__c,Kcc_Details__c,LAST_5_YEARS_MAJOR_INVESTMENT__c,LOAN_TENURE__c,Land_Irrigation_source__c,Land_by_Borrower_in_Acres_with_proof__c,Marriage_in_the_family_in_next_2_years__c,NEAR_BY_POLICE_STATION_NAME__c,NEGATIVE_OR_CAUTION_Profile_details__c,Other_source_of_Income__c,Profile_to_Product_Match_1__c,REFERENCE_CHECK_TRACTORHARVESTER__c,REPAYMENT_FREQUENCY__c,REPAYMENT_MODE__c,Relationship_between_Borrower_Coborrower__c,Residance_Permanent_Address_are_Same__c,Running_loan_Emi_obligation_Monthly__c,Scheme_Type__c,Since_how_long_in_Agri_commercial__c,Sold_to_Contact_details__c,Sub_Scheme_Type__c,Total_Agri_Com_NetIncome_Existing_Harves__c,Total_Agri_Com_NetIncome_Proposed_Harves__c,Total_Agri_Com_NetIncome_Proposed_Tract__c,Total_Agri_Comm_Expen_Proposed_Harvest__c,Total_Agri_Comm_Expense_Existing_Tractor__c,Total_Agri_Comm_Expense_Proposed_Tractor__c,Total_Agri_Comm_Expenses_Exist_Harvest__c,Total_Agri_Comm_Income_Existing_Harvest__c,Total_Agri_Comm_Income_Existing_Tractor__c,Total_Agri_Comm_Income_Proposed_Harvest__c,Total_Agri_Comm_Income_Proposed_Tractor__c,Total_Agri_Comm_NetIncome_Existing_Tract__c,Total_Agri_Expenses_for_Existing_Harvest__c,Total_Agri_Expenses_for_Existing_Tractor__c,Total_Agri_Expenses_for_Proposed_Harvest__c,Total_Agri_Expenses_for_Proposed_Tractor__c,Total_Agri_Income_for_Existing_Harvester__c,Total_Agri_Income_for_Existing_Tractor__c,Total_Agri_Income_for_Proposed_Harvester__c,Total_Agri_Income_for_Proposed_Tractor__c,Total_Agri_Net_Income_for_Existing_Harve__c,Total_Agri_Net_Income_for_Existing_Tract__c,Total_Agri_Net_Income_for_Proposed_Harve__c,Total_Agri_Net_Income_for_Proposed_Tract__c,Total_HL_CAR_PL_TW_Loan__c,Total_KCC_Loan_Stakeholders__c,Total_Tractor_Loan_Family__c,Total_Tractor_Loan_Stakeholders__c,Total_land_holding_within_the_family__c,VILLAGE_DOMINATED_WITH_ANY_COMMUNITY__c,WHAT_IS_THE_ADDRESS_COBORROWER__c,WHAT_IS_THE_AMOUNT_BORROWED_FROM_MARKET__c,WHAT_IS_THE_TERMS_FOR_PARTNERSHIP__c,WHO_TO_HE_HAVE_BORROWED__c,What_is_thePrice_of_TractorHarvester__c,What_is_the_EMI_conveyed_to_customer__c,What_is_the_loan_amount_requried__c,What_is_the_source_of_margin_money__c,Whether_address_is_same_as_FI_done_by_BE__c,Work_order_details__c,expenses_for_Medical__c,how_long_he_is_residing_kyc_address__c,viability_of_existing_TractorHarvester__c,viability_of_proposed_TractorHarvester__c,FI_Address_Line_1__c,FI_Address_Line_2__c,FI_City__c,FI_District__c,FI_Pin_Code__c,FI_State__c,Any_political_relation_Remarks__c,Crop_Net_income__c,Non_Agri_Income__c,Contact_person_Desingnation__c,Contact_person_Name_Phone_number__c,First_Child_DOB__c,Are_you_ready_for_guarntee_for_this_loan__c,Asset_Model__c,Finance_Free__c,Financier_Name__c,Who_will_close_the_loan__c,First_Child_Gender__c,First_Child_Name__c,Mother_DOB__c,Second_Child_DOB__c,Second_Child_Gender__c,Second_Child_Name__c,Spouse_DOB__c,Spouse_Gender__c,Third_Child_DOB__c,Third_Child_Gender__c,Third_Child_Name__c,Entity_Type__c,How_many_Employees_in_Office__c,ITR_1__c,ITR_2__c,ITR_3__c,Nature_of_Business_Major_Industry__c,Nature_of_Business_Minor_Industry__c,Office_Type__c,Office_ownership__c,Number_of_years_in_city_in_years__c,Person_Met__c,(SELECT Id,Cattle_Name__c,Nos_of_Cattle__c,Field_Investigation__c FROM Cattle_Informations__r),(SELECT Id,Net_Income__c,Land_Survey_No__c,Crop_Master__c,Crop_Grown_in_acre__c,Crop_Cultivated_Year__c,Crop_Type__c,Field_Investigation__c FROM Crop_Details__r),(SELECT Id,BANK_NAME__c,EMI_Amount__c,Field_Investigation__c,Last_EMI_Paid_Date__c,LOAN_AMOUNT__c,Loan_Free__c,Loan_number__c,Loan_Stakeholders__c,Loan_Start_Date__c,Loan_Type__c,Model_Details__c,Sr_No__c,Total_Remarks_by_FI_Agent__c,Total_Tractor_Loan_Family__c,Total_Tractor_Loan_Stakeholders__c from Existing_Tractor_Loan_Informations__r),(SELECT Id,Asset_Name__c,Asset_Type__c,Field_Investigation__c,Financier_Name__c,Hypothecation__c,Loan__c,Owner_Name__c,RC_no__c,YOM__c FROM Fleet_Details__r),(SELECT Id,BANK_NAME__c,EMI_Amount__c,Field_Investigation__c,Last_EMI_Paid_Date__c,LOAN_AMOUNT__c,Loan_number__c,Loan_Stakeholders__c,Loan_Start_Date__c,Loan_Type__c,Model_Details__c,Sr_No__c,Total_KCC_Loan_Stakeholders__c,Total_Remarks_by_FI_Agent__c FROM KCC_And_Other_Loan_Informations__r),(SELECT Id,Approximate_value_of_Agri_Land__c,District_Master__c,Field_Investigation__c,Geo_State_Master__c,Land_holder_Name__c,Land_holding_In_acres__c,Land_holding_Type__c,Ownership_Type__c,Proof_attached__c,Since_How_long_are_they_doing_Agricultu__c,Survey_No__c,Taluka_Master__c,Type__c,Village_Name__c FROM Loan_Holding_Details__r),(SELECT Id,Category_Master__c,Field_Investigation__c,Total_Income__c,Utilization__c FROM Non_Agri_Incomes__r),(SELECT Id,Amount__c,Expenses_and_Investment_Type__c,Field_Investigation__c,Type__c FROM Total_Expense_and_investments__r),(SELECT Id,Diesal_counsumption_hr__c,Diesal_Rate_Hr__c,Existing_Proposed__c,Expenses__c,Field_Investigation__c,Net_Income__c,Nos_of_Hours_run_in_year__c,Per_Hour_Rate__c,Sr_No__c,Total_Income__c,Tractor_Harvester__c,Usage_Type__c FROM Viability_of_Existing_Proposed_Tractors__r),(SELECT Id,Contact_Amount__c,Contract_with_Company__c,Date_of_Commencement__c,Explanation__c,Field_Investigation__c,Tenure_of_Contract_Years__c FROM Work_Order_Details__r),Case__r.Applicant__r.Applicant_Type__c FROM Field_Investigation__c WHERE Case__c IN: existingCaseList];

                    Map<Id,List<sObject>> sObjectMap = new Map<Id,List<sObject>>();
                    if (fieldInvestigationList.size() > 0) {
                        for (Field_Investigation__c fIObj : fieldInvestigationList) {
                            Field_Investigation__c newFI = fIObj.clone(false,false,false,false);
                            if(((revokeType == 'payandpayoutchanges' || revokeType == 'assetmodifications') && fIObj.Case__r.Applicant__r.Applicant_Type__c == Label.Borrower && fIObj.Case__r.Type == 'Current Residence FI') || (revokeType == 'removecoborroweraddcoborrowerbypeuser')){
                                newFI.FI_Status__c = 'Pending';
                            }
                            if(caseTypeVsCaseMap.containsKey(fIObj.Case__r.Type + fIObj.Case__r.Applicant__c)){
                                newFI.Case__c = caseTypeVsCaseMap.get(fIObj.Case__r.Type + fIObj.Case__r.Applicant__c).Id;
                                newFieldInvestigationMap.put(fIObj.Id,newFI);
                                List<sObject> sobjectList = new List<sObject>();
                                sobjectList.addAll((List<sObject>)fIObj.Work_Order_Details__r);
                                sobjectList.addAll((List<sObject>)fIObj.Viability_of_Existing_Proposed_Tractors__r);
                                sobjectList.addAll((List<sObject>)fIObj.Total_Expense_and_investments__r);
                                sobjectList.addAll((List<sObject>)fIObj.Non_Agri_Incomes__r);
                                sobjectList.addAll((List<sObject>)fIObj.Loan_Holding_Details__r);
                                sobjectList.addAll((List<sObject>)fIObj.KCC_And_Other_Loan_Informations__r);
                                sobjectList.addAll((List<sObject>)fIObj.Fleet_Details__r);
                                sobjectList.addAll((List<sObject>)fIObj.Existing_Tractor_Loan_Informations__r);
                                sobjectList.addAll((List<sObject>)fIObj.Crop_Details__r);
                                sobjectList.addAll((List<sObject>)fIObj.Cattle_Informations__r);
                                sObjectMap.put(fIObj.Id,sobjectList);
                            }
                        }
                        if(Field_Investigation__c.SObjectType.getDescribe().isCreateable() && newFieldInvestigationMap.size() > 0){
                            insert newFieldInvestigationMap.values();
                        }
                    }

                    List<SObject> newChildRecordsList = new List<SObject>();
                    for(Id key : newFieldInvestigationMap.keySet()) {
                        for (sObject oldChildRecord : sObjectMap.get(key)) {
                            sObject newChildRecord = oldChildRecord.clone(false,false,false,false);
                            newChildRecord.put('Field_Investigation__c',newFieldInvestigationMap.get(key).Id);
                            newChildRecordsList.add(newChildRecord);
                        }
                    }
                    if(newChildRecordsList.size() > 0){
                        List<Work_order_details__c> workOrderDetails =new List<Work_order_details__c>();
                        List<Viability_of_Existing_Proposed_Tractor__c> viablityList =new List<Viability_of_Existing_Proposed_Tractor__c>();
                        List<Total_Expense_and_investment__c> totalExpenseList =new List<Total_Expense_and_investment__c>();
                        List<Non_Agri_Income__c> nonagriList =new List<Non_Agri_Income__c>();
                        List<Land_Holding_Detail__c> landHoldingList =new List<Land_Holding_Detail__c>();
                        List<KCC_And_Other_Loan_Information__c> kccList =new List<KCC_And_Other_Loan_Information__c>();
                        List<Fleet_Details__c> fleetDetails =new List<Fleet_Details__c>();
                        List<Existing_Tractor_Loan_Information__c> existingTractorList =new List<Existing_Tractor_Loan_Information__c>();
                        List<Crop_Detail__c> cropDetails =new List<Crop_Detail__c>();
                        List<Cattle_Information__c> cattleInfoList =new List<Cattle_Information__c>();
 
 
                        for(sObject obj : newChildRecordsList){
                            if(obj.getSObjectType()==Schema.Work_order_details__c.getSObjectType()){
                                workOrderDetails.add((Work_order_details__c)obj);
                            }
                            else if(obj.getSObjectType()==Schema.Viability_of_Existing_Proposed_Tractor__c.getSObjectType()){
                                viablityList.add((Viability_of_Existing_Proposed_Tractor__c)obj);
                            }
                            else if(obj.getSObjectType()==Schema.Total_Expense_and_investment__c.getSObjectType()){
                                totalExpenseList.add((Total_Expense_and_investment__c)obj);
                            }
                            else if(obj.getSObjectType()==Schema.Non_Agri_Income__c.getSObjectType()){
                                nonagriList.add((Non_Agri_Income__c)obj);
                            }
                            else if(obj.getSObjectType()==Schema.Land_Holding_Detail__c.getSObjectType()){
                                 landHoldingList.add((Land_Holding_Detail__c)obj);
                            }
                            else if(obj.getSObjectType()==Schema.KCC_And_Other_Loan_Information__c.getSObjectType()){
                                kccList.add((KCC_And_Other_Loan_Information__c)obj);
                            }
                            else if(obj.getSObjectType()==Schema.Fleet_Details__c.getSObjectType()){
                                fleetDetails.add((Fleet_Details__c)obj);
                            }
                            else if(obj.getSObjectType()==Schema.Existing_Tractor_Loan_Information__c.getSObjectType()){
                                existingTractorList.add((Existing_Tractor_Loan_Information__c)obj);
                            }
                            else if(obj.getSObjectType()==Schema.Crop_Detail__c.getSObjectType()){
                                cropDetails.add((Crop_Detail__c)obj);
                            }
                            else if(obj.getSObjectType()==Schema.Cattle_Information__c.getSObjectType()){
                                cattleInfoList.add((Cattle_Information__c)obj);
                            }
                            
                        }
                        if(!workOrderDetails.isEmpty()){
                            insert workOrderDetails;
                        }
                        if(!viablityList.isEmpty()){
                            insert viablityList;
                        }
                        if(!totalExpenseList.isEmpty()){
                            insert totalExpenseList;
                        }
                        if(!nonagriList.isEmpty()){
                            insert nonagriList;
                        }
                        if(!landHoldingList.isEmpty()){
                            insert landHoldingList;
                        }
                        if(!kccList.isEmpty()){
                            insert kccList;
                        }
                        if(!fleetDetails.isEmpty()){
                            insert fleetDetails;
                        }
                         if(!existingTractorList.isEmpty()){
                            insert existingTractorList;
                        }
                        if(!cropDetails.isEmpty()){
                            insert cropDetails;
                        }
                        if(!cattleInfoList.isEmpty()){
                            insert cattleInfoList;
                        }
                        system.debug('sobject----'+newChildRecordsList);
                        //insert newChildRecordsList;
                    }
                    if(fiCaseDocList.size() > 0){
                        Set<Id> fiCaseDocIdSet = new Set<Id>();
                        for (Documents__c docObj : fiCaseDocList) {
                            fiCaseDocIdSet.add(docObj.Id);
                        }
                        Map<Id,Documents__c> existingDocumentMap = new Map<Id,Documents__c>([SELECT Id,Salutation__c,First_Name__c,Last_Name__c,Name, Document_Type__c,RecordTypeId,Case__c,Is_Active__c,Applicant__c,Case__r.Type FROM Documents__c WHERE Opportunity_Relation__c =: oldLoanApplicationId AND Is_Active__c = true AND Id IN : fiCaseDocIdSet AND Applicant__r.In_Active_Applicant__c = false ORDER BY Case__c]);
                
                        Map<Id,Documents__c> newDocumentMap = new Map<Id,Documents__c>();
                        for(Documents__c document : existingDocumentMap.values()){
                            if(caseTypeVsCaseMap.containsKey(document.Case__r.Type + document.Applicant__c)){
                                Documents__c newDocument = document.clone(false,false,false,false);
                                newDocument.Opportunity_Relation__c = newLoanApplicationId;
                                newDocument.Applicant__c = applicantMap.containskey(document.Applicant__c) ? applicantMap.get(document.Applicant__c).Id : '';
                                    newDocument.Case__c = caseTypeVsCaseMap.get(document.Case__r.Type + document.Applicant__c).Id;
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
            
                        if(contentDocList.size() > 0){
                            globalContentDocList.addAll(contentDocList);
                        }
                    }

                    String recordTypeId = (String) Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('RCU').getRecordTypeId();
                    List<Case> existingRCUCaseList = new List<Case>([SELECT Id,RCU_Agent__c FROM Case WHERE RecordTypeId =: recordTypeId and Loan_Application__c =: oldLoanApplicationId and ParentId = null LIMIT 1]);
                    if(existingRCUCaseList.size() > 0 && existingRCUCaseList[0].RCU_Agent__c != null){
                        List<CaseTeamMember> existingCaseTeamMember = new List<CaseTeamMember>([Select Id,MemberId,TeamRoleId From CaseTeamMember Where ParentId IN : existingCaseList AND MemberId =: existingRCUCaseList[0].RCU_Agent__c Order By CreatedDate DESC LIMIT 1]);
                        if(existingCaseTeamMember.size() > 0){
                            List<CaseTeamMember> newCaseTeamMember = new List<CaseTeamMember>();
                            for (Case caseObj : caseTypeVsCaseMap.values()) {
                                CaseTeamMember caseTeamObj = existingCaseTeamMember[0].clone(false,false,false,false);
                                caseTeamObj.ParentId = caseObj.Id;
                                newCaseTeamMember.add(caseTeamObj);
                            }
                            if(newCaseTeamMember.size() > 0){
                                insert newCaseTeamMember;
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_RevokeController', 'copyClosedFICases', System.Label.Apex, e, oldLoanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }//SFTRAC-166 end
    
    //INDI-4342 OR CISP-503
    @AuraEnabled
    public static void upsertRecordDetails(String loanApplicationId, String fields, String objectApiName){
        try {
            if(objectApiName == 'Applicant__c'){
                Applicant__c applicantObj = new Applicant__c();
                applicantObj = (Applicant__c) JSON.deserialize(fields,Applicant__c.class);
                update applicantObj;
            }else if(objectApiName == 'CIBIL_Details__c'){
                CIBIL_Details__c cibilObj = new CIBIL_Details__c();
                cibilObj = (CIBIL_Details__c) JSON.deserialize(fields,CIBIL_Details__c.class);
                insert cibilObj;
            }
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_RevokeController', 'upsertRecordDetails', System.Label.Apex, e, loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    //CISP-503 END
    
    @AuraEnabled
    public static void sendCustomNotification(CustomNotificationWrapper customNotification) {
        try {
            CustomNotificationType notificationType;
            if(globalNotificationType != null){
                notificationType = globalNotificationType;
            }else{
                notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'Notification_to_Onwer'];
            }
            Messaging.CustomNotification noti = new Messaging.CustomNotification();
            
            if(customNotification.notificationTitle == 'Loan Application Assignment'){
                noti.setBody(customNotification.notificationBody);
                noti.setTitle(customNotification.notificationTitle);
                noti.setNotificationTypeId(notificationType.Id);
                noti.setTargetId(customNotification.loanApplicationId);
                noti.send(new Set<String> { customNotification.ownerId });
            }else if(customNotification.notificationTitle == 'Case Assignment'){
                noti.setBody(customNotification.notificationBody);
                noti.setTitle(customNotification.notificationTitle);
                noti.setNotificationTypeId(notificationType.Id);
                noti.setTargetId(customNotification.caseId);
                noti.send(new Set<String> { customNotification.ownerId });
            }            
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_RevokeController', 'sendCustomNotification', System.Label.Apex, e, customNotification.loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    public class CustomNotificationWrapper {
        public String loanApplicationId{get;set;}
        public String caseId{get;set;}
        public String notificationTitle{get;set;}
        public String notificationBody{get;set;}
        public String ownerId{get;set;}
    }

    public class RCUDocumentsWrapper {
        @AuraEnabled
        public String loanApplicationId{get;set;}
        @AuraEnabled
        public String documentId{get;set;}
        @AuraEnabled
        public String applicantType{get;set;}
        @AuraEnabled
        public String documentType{get;set;}
        @AuraEnabled
        public String contentDocumentId{get;set;}
        @AuraEnabled
        public String documentName{get;set;}
        @AuraEnabled
        public String contentVersionId{get;set;}
    }
    
    public class ReturnedWrapper{
        @AuraEnabled
        public String clonedLoanApplicationId{get;set;}
        @AuraEnabled
        public ApplicantReturnedWrapper clonedApplicantsId{get;set;}
        ReturnedWrapper(){
            this.clonedLoanApplicationId = '';
            this.clonedApplicantsId = new ApplicantReturnedWrapper();
        }
    }
    
    public class ApplicantReturnedWrapper{
        @AuraEnabled
        public String clonedPrimaryApplicantId{get;set;}
        @AuraEnabled
        public String clonedSecondaryApplicantId{get;set;}
        @AuraEnabled
        public Map<Id,Applicant__c> newApplicantMap{get;set;}

        ApplicantReturnedWrapper(){
            this.clonedPrimaryApplicantId = '';
            this.clonedSecondaryApplicantId = '';
            this.newApplicantMap = new Map<Id,Applicant__c>();
        }
    }
    
    //CISP-2390
    @AuraEnabled
    public static Boolean isRevokedLoanApplication(String loanApplicationId) {
        try {
            ////CISP-2384
            Opportunity opp = [Select id,Is_Revoked__c From Opportunity Where Id =: loanApplicationId WITH SECURITY_ENFORCED];
            if(opp.Is_Revoked__c){
                return true;
            }
            return false;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_RevokeController', 'isRevokedLoanApplication', System.Label.Apex, e, loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    //CISP-2390
    
    // CISP-2452
    @AuraEnabled
    public static void updateClonedLoanApplicationOwner(String loanApplicationId,String clonedLoanAppId, String newOwnerId) {
        try {
            Opportunity opp = oppObj != null ? oppObj : [Select id,CreatedById,LeadSource,OwnerId From Opportunity Where Id =: loanApplicationId WITH SECURITY_ENFORCED];
            // CISP-2574-START
            List<Final_Term__c> finalTermList = new List<Final_Term__c>();
                            finalTermList = [SELECT Id,CreatedById 
                                 FROM Final_Term__c 
                                 WHERE Loan_Application__c =: loanApplicationId
                                 WITH SECURITY_ENFORCED];
                        
            if((opp.LeadSource == System.Label.MSIL_Lead_API_Value || opp.LeadSource == System.label.Mahindra_Custom_Lead_API_Value || opp.LeadSource == System.label.Mahindra_PreA_Lead_API_Value ) && finalTermList.size() > 0){ //CISP-15890
                Opportunity oppCloned = new Opportunity();
                oppCloned.Id = clonedLoanAppId;
                oppCloned.OwnerId = finalTermList[0].CreatedById;
                update oppCloned;
            }else{//CISP-2574-END
                Opportunity oppCloned = new Opportunity();
                oppCloned.Id = clonedLoanAppId;
                if(opp.LeadSource == 'DSA'){
                    oppCloned.OwnerId = opp.OwnerId; //CISP-10982  
                }else{  
                    oppCloned.OwnerId = String.isNotBlank(newOwnerId) ? newOwnerId :  opp.CreatedById;
                } 
                
                update oppCloned;
            }
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_RevokeController', 'updateClonedLoanApplicationOwner', System.Label.Apex, e, loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    //CISP-2452
    
    
    @AuraEnabled
    public static Boolean isPACTLMSIntegrationLogFailed(String loanApplicationId, String dealId){
        try {
            Boolean pactIntegrationStatus = true;
            List<Opportunity> oppList = new List<Opportunity>([Select Id,Product_Type__c from Opportunity Where Id =: loanApplicationId LIMIT 1]);
            List<Integration_Log__c> integrationList = new List<Integration_Log__c>();
            if(oppList.size() > 0 && oppList[0].Product_Type__c == System.Label.Tractor){
                integrationList = [Select Id,Status__c from Integration_Log__c where Loan_Application__c =: loanApplicationId and (Service_Name__c = 'PACT/LMS' OR Service_Name__c =: System.Label.Payment_Request_For_Tractor) and targetRecordId__c =: dealId Order By Createddate DESC LIMIT 2];
                for(Integration_Log__c intlog :integrationList){
                    if(intlog.Status__c == 'Failure'){
                        pactIntegrationStatus = false;
                        break;
                    }
                }
            }else{
                integrationList = [Select Id,Status__c from Integration_Log__c where Loan_Application__c =: loanApplicationId and Service_Name__c = 'PACT/LMS' Order By Createddate DESC LIMIT 1];
                pactIntegrationStatus = integrationList.size() > 0 ? integrationList[0].Status__c == 'Failure' ?  false : true : true;
            }
            return pactIntegrationStatus;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_RevokeController', 'isPACTLMSIntegrationLogFailed', System.Label.Apex, e, loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    //CISP-4628 Start
    @AuraEnabled
    public static String isUserSelectionLookupRequiredOnRevoke(String loanApplicationId) {
        Boolean isUserSelectionNeeded = false;
        String benCode = '';
        String benName = '';

            Map<String,Object> mapData = new Map<String,Object>();
        
        List<Opportunity> oppList = [SELECT Id, AccountId, Account.BranchBLCode__c, LeadSource, Product_Type__c, CreatedBy.Name, CreatedBy.EmployeeNumber, CreatedBy.IsActive
                                     FROM Opportunity
                                     WHERE Id = :loanApplicationId
                                     WITH SECURITY_ENFORCED
                                     LIMIT 1];
        if (oppList.size() > 0){
            List<AccountTeamMember> eligibleMemberList = [SELECT UserId FROM AccountTeamMember WHERE AccountId = :oppList[0].AccountId AND User.IsActive = true AND TeamMemberRole = 'MA'];//CISP-14306
            if(String.isBlank(oppList[0].LeadSource) && oppList[0].Product_Type__c == 'Two Wheeler' && oppList[0].CreatedBy.IsActive == false) {
                if(eligibleMemberList.size() > 0) {//CISP-14306
                    isUserSelectionNeeded = true;
                } else {//CISP-14306
                    mapData.put('ph1TWRevokeErr','BL Code ' +(String.isNotBlank(oppList[0]?.Account?.BranchBLCode__c) ? oppList[0]?.Account?.BranchBLCode__c + ' ' : '')+ 'does not have any active Sales Users; hence, application cannot be revoked');//CISP-14306
                }//CISP-14306
                mapData.put('benCode', oppList[0].CreatedBy.EmployeeNumber);
                mapData.put('benName', oppList[0].CreatedBy.Name);
                mapData.put('branchAccountId', oppList[0].AccountId);
            }
        }
        mapData.put('isUserSelectionNeeded', isUserSelectionNeeded);

            return JSON.serialize(mapData);
    }

    @AuraEnabled(Cacheable = true)
    public static List<sObject> getEligibleUsersForRevokedApplication(Id branchAccountId, String searchTerm) {
        try {
            searchTerm = '%'+searchTerm+'%';
            List<sObject> sObjectList = [SELECT UserId, User.Name, User.EmployeeNumber
                                        FROM AccountTeamMember 
                                        WHERE AccountId = :branchAccountId AND User.IsActive = true AND TeamMemberRole = 'MA' AND User.EmployeeNumber LIKE :searchTerm 
                                        GROUP BY UserId, User.Name, User.EmployeeNumber ORDER BY User.EmployeeNumber LIMIT 2000];
            return sObjectList;
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
}
    //CISP-4628 End
    private static Boolean revokeTVRApplication(String loanApplicationId){
        if(loanApplicationId != null){
            List<TeleVerification__c> teleLst= [SELECT Id 
                                                    FROM TeleVerification__c 
                                                    WHERE Case__r.Loan_Application__c  =: loanApplicationId
                                                    WITH SECURITY_ENFORCED];
            List<Case> caseLst = [SELECT Id 
                                    FROM Case 
                                    WHERE Loan_Application__c =: loanApplicationId AND RecordType.Name = 'TVR'
                                    WITH SECURITY_ENFORCED];
            
            if(teleLst.size()>0){
                delete teleLst;
            }
            
            if(caseLst.size()>0){
                delete caseLst;
            }

            return true;
        }
        return false;
    }
    //SFTRAC-166 start
    @AuraEnabled
    public static String isTractorLoanApplication(String loanApplicationId) {
        try {
            Map<String, Object> oppMap = new Map<String, Object>();
            Opportunity opp = [Select id,Product_Type__c,Owner.Profile.name,(SELECT Id,Type from Cases__r WHERE Type = 'RCU' AND ParentId = null) From Opportunity Where Id =: loanApplicationId];
            oppMap.put('productType', opp.Product_Type__c);
            oppMap.put('profileName', opp.Owner.Profile.name);
            if(opp.Cases__r.size() > 0){
                oppMap.put('rcuCaseId', opp.Cases__r[0].Id);
            }
            List<Cam__c> camList = new List<Cam__c>([Select id,CAM_Submitted_by_ACM_SCM__c from Cam__c Where Loan_Application__c =:loanApplicationId LIMIT 1]);
            if(camList.size() > 0){
                oppMap.put('isCAMApproved', camList[0].CAM_Submitted_by_ACM_SCM__c);
            }else{
                oppMap.put('isCAMApproved', false);
            }
            return JSON.serialize(oppMap);
            
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_RevokeController', 'isTractorLoanApplication', System.Label.Apex, e, loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }//SFTRAC-166 end

    @AuraEnabled
    public static List<Opportunity> getCurrentOppRecord(String loanApplicationId) {
        return [Select Id,Parent_Loan_Application__r.Is_Revoked__c FROM Opportunity WHERE Id =: loanApplicationId];
    }
}