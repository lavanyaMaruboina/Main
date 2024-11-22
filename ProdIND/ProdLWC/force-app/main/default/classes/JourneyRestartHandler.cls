/*------------------------------------------------------------
Author:        Abhishek Yadav
Company:       Manureva
Description:   
Apex Class :   JourneyRestartHandler
Test Class:    
History 
Date            Author              Comments
-------------------------------------------------------------
19/04/2023     Abhishek Yadav       Initial Creation
------------------------------------------------------------*/
public without sharing class JourneyRestartHandler {
    @AuraEnabled
    public static String JourneyRestart(String loanApplicationId, String applicantId, string journeyRestartType, String journeyRestartReason){
        try{
            if(journeyRestartType == 'Journey_Restart_Borrower'){
                ReturnMessageWrapper returnWrapperElement = new ReturnMessageWrapper();
                
                if(String.isNotBlank(loanApplicationId) && String.isNotBlank(applicantId)){
                    returnWrapperElement.isSuccess = true;
                    returnWrapperElement.message = 'Journey has been restarted';
                    // Clone Loan Application
                    Map<String,Object> LoanApplication = (Map<String,Object>)JSON.deserializeUntyped(cloneLoanApplication(loanApplicationId,journeyRestartType, journeyRestartReason));
                    String loanApplicationCloneId = (String)LoanApplication.get('LoanApplicationId');
                    returnWrapperElement.LoanApplicationLeadNumber = (String)LoanApplication.get('LeadNumber');
                    returnWrapperElement.cloneLoanApplicationId = loanApplicationCloneId;
                    // Clone Applicants
                    String applicantCloneId = cloneApplicant(loanApplicationId,loanApplicationCloneId,System.Label.Borrower, journeyRestartType);
                    returnWrapperElement.cloneBorrowerApplicantId = applicantCloneId;
                    
                    //Clone Documents
                    cloneDocuments(loanApplicationId,loanApplicationCloneId,System.Label.Borrower);
                    
                    // Clone dedpue
                    cloneCustomerDedpue(loanApplicationId,loanApplicationCloneId,System.Label.Borrower);
                }else{
                    returnWrapperElement.isSuccess = false;
                    returnWrapperElement.message = 'Missing Loan Applicantion and Applicant details';
                }
                return JSON.serialize(returnWrapperElement); 
            }
            
            if(journeyRestartType == 'CMU_Reject_Borrower'){
                ReturnMessageWrapper returnWrapperElement = new ReturnMessageWrapper();
                
                if(String.isNotBlank(applicantId)){
                    returnWrapperElement = CMURejectCloneLoanApplication(applicantId,journeyRestartReason);                    
                }else{
                    returnWrapperElement.isSuccess = false;
                    returnWrapperElement.message = 'Missing Applicant Details';
                }
                return JSON.serialize(returnWrapperElement);
            }
            
            if(journeyRestartType == 'CMU_reject_Co_Borrower'){
                ReturnMessageWrapper returnWrapperElement = new ReturnMessageWrapper();
                if(String.isNotBlank(loanApplicationId) && String.isNotBlank(applicantId)){
                    returnWrapperElement.isSuccess = true;
                    returnWrapperElement.message = 'Journey has been restarted';
                    // Clone Loan Application
                    Map<String,Object> LoanApplication = (Map<String,Object>)JSON.deserializeUntyped(cloneLoanApplication(loanApplicationId,journeyRestartType,journeyRestartReason));
                    String loanApplicationCloneId = (String)LoanApplication.get('LoanApplicationId');
                    returnWrapperElement.LoanApplicationLeadNumber = (String)LoanApplication.get('LeadNumber');
                    returnWrapperElement.cloneLoanApplicationId = loanApplicationCloneId;
                    // Clone Applicants
                    String applicantCloneId = cloneApplicant(loanApplicationId,loanApplicationCloneId,System.Label.Borrower,journeyRestartType);
                    returnWrapperElement.cloneBorrowerApplicantId = applicantCloneId;
                    
                    //Clone Documents
                    cloneDocuments(loanApplicationId,loanApplicationCloneId,System.Label.Borrower);
                    
                    // Clone dedpue
                    cloneCustomerDedpue(loanApplicationId,loanApplicationCloneId,System.Label.Borrower);
                    
                }else{
                    returnWrapperElement.isSuccess = false;
                    returnWrapperElement.message = 'Missing Loan Applicantion and Applicant details';
                }
                return JSON.serialize(returnWrapperElement);
            }
            
            if(journeyRestartType == 'Journey_Restart_Coborrower'){
                ReturnMessageWrapper returnWrapperElement = new ReturnMessageWrapper();
                if(String.isNotBlank(loanApplicationId) && String.isNotBlank(applicantId)){
                    
                    // Clone Loan Application
                    Map<String,Object> LoanApplication = (Map<String,Object>)JSON.deserializeUntyped(cloneLoanApplication(loanApplicationId,journeyRestartType,journeyRestartReason));
                    String loanApplicationCloneId = (String)LoanApplication.get('LoanApplicationId');
                    returnWrapperElement.LoanApplicationLeadNumber = (String)LoanApplication.get('LeadNumber');
                    returnWrapperElement.cloneLoanApplicationId = loanApplicationCloneId;
                    
                    // Clone Borrower details
                    
                    // Clone Applicants
                    String applicantCloneId = cloneApplicant(loanApplicationId,loanApplicationCloneId,System.Label.Borrower,journeyRestartType);
                    returnWrapperElement.cloneBorrowerApplicantId = applicantCloneId;
                    
                    //Clone Documents
                    cloneDocuments(loanApplicationId,loanApplicationCloneId,System.Label.Borrower);
                    
                    // Clone dedpue
                    cloneCustomerDedpue(loanApplicationId,loanApplicationCloneId,System.Label.Borrower);
                    
                    List<String> caseRecordTypeList = new List<String>{'FI',System.Label.TVR,System.Label.AML_Check,System.Label.Off_Role_Emp_Approval};
                    
                    updateOldCase(loanApplicationId,caseRecordTypeList);
                    
                    //clone cloneCibil
                    cloneCibil(loanApplicationId,loanApplicationCloneId);

                    // Clone co-Borrower details
                    
                    // Clone Applicants
                    String applicantcoBorrowerCloneId = cloneApplicant(loanApplicationId,loanApplicationCloneId,System.Label.CoBorrower,journeyRestartType);
                    returnWrapperElement.cloneCoBorrowerApplicantId = applicantcoBorrowerCloneId;
                    
                    //Clone Documents
                    cloneDocuments(loanApplicationId,loanApplicationCloneId,System.Label.CoBorrower);
                    
                    // Clone dedpue
                    cloneCustomerDedpue(loanApplicationId,loanApplicationCloneId,System.Label.CoBorrower);
                }
                return JSON.serialize(returnWrapperElement);
            }
            
            if(journeyRestartType == 'Journey_Reject_Borrower_Tractor' || journeyRestartType == 'Journey_Reject_NonBorrower_Tractor' || journeyRestartType == 'Journey_Restart_Borrower_Tractor' || journeyRestartType == 'Journey_Restart_NonBorrower_Tractor') {
                ReturnMessageWrapper returnWrapperElement = new ReturnMessageWrapper();
                
                if(String.isNotBlank(loanApplicationId) && String.isNotBlank(applicantId)){
                    returnWrapperElement.isSuccess = true;
                    returnWrapperElement.message = 'Journey has been restarted';
                    // Clone Loan Application
                    Map<String,Object> LoanApplication = (Map<String,Object>)JSON.deserializeUntyped(cloneLoanApplication(loanApplicationId, journeyRestartType, journeyRestartReason));
                    String loanApplicationCloneId = (String)LoanApplication.get('LoanApplicationId');
                    returnWrapperElement.LoanApplicationLeadNumber = (String)LoanApplication.get('LeadNumber');
                    returnWrapperElement.cloneLoanApplicationId = loanApplicationCloneId;

                    // Clone Applicants
                    ApplicantWrapper wrapper = cloneApplicantTractor(loanApplicationId, loanApplicationCloneId, applicantId, journeyRestartType);
                    
                    //Clone Documents
                    cloneDocumentsTractor(loanApplicationId, loanApplicationCloneId, wrapper);
                    
                    //Clone dedpue
                    cloneCustomerDedpueTractor(loanApplicationId, wrapper);

                    //Clone vehicleDetail
                    cloneVehicleDetailTractor(loanApplicationId, loanApplicationCloneId);   
                    
                    // Update oldcase as closed
                    List<String> caseRecordTypeList = new List<String>{'FI',System.Label.TVR,System.Label.AML_Check,System.Label.Off_Role_Emp_Approval,'CMU_Request'};
                    updateOldCase(loanApplicationId,caseRecordTypeList);
                }else{
                    returnWrapperElement.isSuccess = false;
                    returnWrapperElement.message = 'Missing Loan Applicantion and Applicant details';
                }
                return JSON.serialize(returnWrapperElement);
            }
            
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('JourneyRestartHandler', 'JourneyRestart', 'System.Label.Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        return null;
    }

    public static String cloneLoanApplication(String loanApplicationId, String journeyRestartType, String journeyRestartReason) {
        try{
            
            Opportunity existingLoan = [SELECT Id,LeadSource,Createddate,Loan_Created_Date__c,IModuleId__c,Vehicle_Verified__c, Name, Loan_amount__c, Product_Type__c, Vehicle_Sub_Category__c, Vehicle_Type__c, Required_Loan_amount__c, Required_Tenure__c, Required_ROI__c, Funding_on_Ex_Showroom__c, Funding_on_ORP__c, Is_customer_interested_in_a_motor_insura__c, Funded__c, Non_Funded__c, X1st_yr_Insurance_Premium__c, Motor_Insurance_Premium__c, Basic_Price__c, GST_Amount__c, Discount_on_Basic_Price__c, Ex_showroom_price__c, Ex_showroom_price_carwale__c,RTO_Road_Tax_New__c,RTO_Road_Tax__c, Other_charges__c, On_Road_price__c, On_Road_price_carwale__c, Final_Price__c, PartnerAccountId,AccountId,StageName,LastStageName__c,CloseDate,OwnerId, Lead_Number__c, Agent_BL_code__c, Gender__c, Parent_Deal_number__c,Revoke_Parent_Deal_Number__c,Registration_Number_Format__c,Vehicle_Registration_Number__c,Customer_Code__c, NOC_Number__c,Vehicle_Proceed_Flag__c,Application_number__c,CreatedById,Sub_Stage__c,Applicant_Name__c,Is_Revoked__c,Revoked_Applicant_Count__c,PreviousAccountId__c, Customer_Type__c,Application_Type__c,Class_of_Activity__c,Entity_Type__c,Entity_Name__c,Entity_Code__c,Entity_Category__c,Employee_No__c,Employee_Name__c,Employee_Branch__c,Loan_Type__c,Major_Industry__c,Profile__c,Date_of_Incorporation__c,Contact_Person_Name__c,Lead_Source_Non_Ind__c,Evaluation_Type__c,Minor_Industry__c FROM Opportunity WHERE Id =: loanApplicationId LIMIT 1];
            if(String.isBlank(existingLoan.Loan_Created_Date__c)){
                    existingLoan.Loan_Created_Date__c = IND_ApplicationFormSigning.getDateTimeFormat(existingLoan.Createddate); //CISP-9624
            }
            Opportunity newLoanApplication = existingLoan.clone(false, false, false, false);
            if(journeyRestartType == 'Journey_Restart_Borrower' || journeyRestartType == 'Journey_Restart_Coborrower'){
                newLoanApplication.StageName = 'Loan Initiation';
                newLoanApplication.Sub_Stage__c = 'User Details';
                newLoanApplication.LastStageName__c = 'Loan Initiation';
            }
            if(journeyRestartType == 'CMU_Reject_Borrower'){
                newLoanApplication.StageName = 'Loan Initiation';
                newLoanApplication.Sub_Stage__c = 'User Details';
                newLoanApplication.LastStageName__c = 'Loan Initiation';
            }
            if(journeyRestartType == 'CMU_reject_Co_Borrower'){
                newLoanApplication.StageName = 'Loan Initiation';
                newLoanApplication.Sub_Stage__c = 'View Application Details';
                newLoanApplication.LastStageName__c = 'Loan Initiation';
            }
            if(journeyRestartType == 'Journey_Reject_Borrower_Tractor' || journeyRestartType == 'Journey_Reject_NonBorrower_Tractor' || journeyRestartType == 'Journey_Restart_Borrower_Tractor' || journeyRestartType == 'Journey_Restart_NonBorrower_Tractor'){
                newLoanApplication.StageName = 'Loan Initiation';
                newLoanApplication.Sub_Stage__c = 'User Details';
                newLoanApplication.LastStageName__c = 'Loan Initiation';
            }
            newLoanApplication.Parent_Loan_Application__c = existingLoan.Id;
            newLoanApplication.Name = newLoanApplication.Lead_Number__c = HandleJourney_Utility.handleLoanApplictionNumber(existingLoan.Name,'CMU Journey Restart');//CISP-6341
            newLoanApplication.CreatedById = existingLoan.CreatedById;
            newLoanApplication.IModuleId__c = existingLoan.IModuleId__c != null ? existingLoan.IModuleId__c : '';
            
            List<Final_Term__c> finalTermList = new List<Final_Term__c>([Select Id,CreatedById From Final_Term__c Where Loan_Application__c =: existingLoan.Id]);
            if((existingLoan.LeadSource == System.Label.MSIL_Lead_API_Value || existingLoan.LeadSource == System.label.Mahindra_Custom_Lead_API_Value || existingLoan.LeadSource == System.label.Mahindra_PreA_Lead_API_Value)  && finalTermList.size() > 0){  //CISP-15890
                newLoanApplication.OwnerId = finalTermList[0].CreatedById;
            }else if(existingLoan.LeadSource == System.Label.MSIL_Lead_API_Value || existingLoan.LeadSource == 'DSA' || existingLoan.LeadSource == System.label.Mahindra_Custom_Lead_API_Value || existingLoan.LeadSource == System.label.Mahindra_PreA_Lead_API_Value || existingLoan.LeadSource == System.label.Synergy_Lead_Source){//CISP-12675 //CISP-15890//Synergy lead source added by Rajasekar as part of CISP-21840
                newLoanApplication.OwnerId = existingLoan.OwnerId;
            }else{
                newLoanApplication.OwnerId = existingLoan.CreatedById;
            }

            newLoanApplication.LeadSource = existingLoan.LeadSource;
            List<Opportunity> oppList = [SELECT Id,Lead_Number__c from Opportunity where Lead_Number__c =: newLoanApplication.Lead_Number__c LIMIT 1]; //checking if new lead number is already present or not
            if(Opportunity.SObjectType.getDescribe().isCreateable() && oppList.isEmpty()){
                insert newLoanApplication;
            }
            existingLoan.StageName = 'Journey Restart';
            existingLoan.Journey_Restart_Reason__c = journeyRestartReason;
            if (Schema.sObjectType.Opportunity.isUpdateable()){
                update existingLoan;
                if(Schema.sObjectType.Refresh_View__e.isCreateable()){
                    Refresh_View__e refreshEvent = new Refresh_View__e();
                    refreshEvent.Record_Id__c = existingLoan.Id;
                    refreshEvent.Stage__c = existingLoan.StageName;
                    EventBus.publish(refreshEvent);
                }
            }
            if(newLoanApplication.Id != null){
                CustomNotificationWrapper customNotification = new CustomNotificationWrapper();
                customNotification.loanApplicationId = newLoanApplication.Id;
                if(existingLoan.LeadSource == 'DSA' || existingLoan.LeadSource == System.label.Synergy_Lead_Source){//CISP-12675//Synergy lead source added by Rajasekar as part of CISP-21840
                    customNotification.ownerId = existingLoan.OwnerId;
                }else{
                    customNotification.ownerId = existingLoan.CreatedById;
                }//CISP-12675
                customNotification.notificationTitle = 'Loan Application Assignment';
                customNotification.notificationBody = 'Loan Application ' + newLoanApplication.Lead_Number__c +' has been assigned to you.';
                sendCustomNotification(customNotification);
            }

            CustomNotificationWrapper customNotification1 = new CustomNotificationWrapper();
            customNotification1.loanApplicationId = existingLoan.Id;
            customNotification1.ownerId = existingLoan.OwnerId;
            customNotification1.notificationTitle = 'Loan Application Journey Restart';
            customNotification1.notificationBody = 'Loan Application ' + existingLoan.Lead_Number__c +' journey has been restarted.Please refresh the screen.';
            sendCustomNotification(customNotification1);

            return JSON.serialize(new Map<String,String> {'LoanApplicationId' => newLoanApplication.Id, 'LeadNumber' => newLoanApplication.Lead_Number__c});
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('JourneyRestartHandler', 'cloneLoanApplication', System.Label.Apex, e, loanApplicationId);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static String cloneApplicant(String oldLoanApplicationId, String newLoanApplicationId, String ApplicationType, String journeyRestartType){
        try{
            Map<String,String> journeyStageMap = new Map<String,String>{'Journey_Restart_Borrower' => 'Capture Dedupe' , 'CMU_Reject_Borrower' => 'User Details', 'CMU_reject_Co_Borrower' => 'Gatting And Screening'};
            Applicant__c existingApplicant = [SELECT Id,AepS_Info__c,Name,Preferred_address_for_communication__c, of_family_members_residing_with_you__c, Residence_country__c,  Who_will_repay_the_loan__c, Marital_status__c, Spouse_Name__c, Father_s_name__c, Mother_s_name__c, Communication_language__c, Customer_Qualification__c, Relationship_with_borrower__c, Email_Fail_Count__c,Is_Email_Valid__c,OTP_for_borrower__c,Selfie_Retry_Attempts__c,Customer_First_Name__c,Customer_Last_Name__c,Whatsapp_number__c,customer_image_attempts__c,Contact_number__c,Applicant_Type__c,DocAuth_Application_Id__c,Selfie_Upload__c,Customer_code__c,Consent_Received__c,Register_for_WhatsApp_Banking__c,Journey_Stage__c,Declared_income__c,Loan_Amount__c,Do_you_have_a_bank_account__c,Do_you_have_a_bank_account_with_IBL__c,Would_you_like_to_open_a_bank_account__c,Current_Same_As_Permanent__c, Current_Address_Not_Present__c,Permanent_Address_Not_Present__c,Email_Id__c,Bureau_Pull_Match__c,Bureau_Pull_Message__c,Income_source_available__c,In_Active_Applicant__c,Caste__c,Religion__c,Check_Eligibility_Final_Reason__c,Check_Eligibility_Message__c,Check_Eligibility_Match__c,Is_Address_Declaration__c,isCodeValidateBySalesUser__c,IND_Customer_Master_Creation_Status__c, IND_Customer_Master_Updation_Status__c,Is_Borrower_Relative_Of_Director__c, Is_Borrower_Relative_Of_Senior_Officer__c, Is_CoBorrower_Relative_Of_Director__c, Is_CoBorrower_Relative_Of_Senior_Officer__c, Borrower_Relation_With_IndusInd_Q1__c,Borrower_Relation_With_IndusInd_Q2__c,Borrower_Relation_With_Other_Bank_Q1__c,Borrower_Relation_With_Other_Bank_Q2__c,CoBorrower_Relation_With_IndusInd_Q1__c,CoBorrower_Relation_With_IndusInd_Q2__c,CoBorrower_Relation_With_Other_Bank_Q1__c,CoBorrower_Relation_With_Other_Bank_Q2__c,Relationship_With_IndusInd_Or_Other_Bank__c From Applicant__c Where Opportunity__c =: oldLoanApplicationId AND Applicant_Type__c =: ApplicationType AND In_Active_Applicant__c = false LIMIT 1];
            Applicant__c newApplicant = existingApplicant.clone(false, false, false, false);
            newApplicant.Opportunity__c = newLoanApplicationId;
            if(journeyStageMap.containsKey(journeyRestartType)){
                newApplicant.Journey_Stage__c = journeyStageMap.get(journeyRestartType);
            }
            else if(journeyRestartType == 'Journey_Restart_Coborrower' && ApplicationType == System.Label.coBorrower){
                newApplicant.Journey_Stage__c = 'Capture Dedupe';
                newApplicant.Bureau_Pull_Match__c = false;
                newApplicant.Bureau_Pull_Message__c = null;
                newApplicant.Income_source_available__c = false;
                newApplicant.Declared_income__c = null;
                newApplicant.Do_you_have_a_bank_account__c = false;
                newApplicant.Do_you_have_a_bank_account_with_IBL__c = false;
                newApplicant.Would_you_like_to_open_a_bank_account__c = false;
                newApplicant.Check_Eligibility_Match__c = false;//CISP-6902
                newApplicant.Check_Eligibility_Message__c = null;//CISP-6902
            }
            else if(journeyRestartType == 'Journey_Restart_Coborrower' && ApplicationType == System.Label.Borrower){
                newApplicant.Journey_Stage__c = 'Gatting And Screening';
            }
            if(journeyRestartType == 'Journey_Restart_Borrower'){//CISP-5390
                newApplicant.Declared_income__c = null;
                newApplicant.Income_source_available__c = false;
                newApplicant.Bureau_Pull_Match__c = false;//CISP-6542
                newApplicant.Bureau_Pull_Message__c = null;//CISP-6542
                newApplicant.Check_Eligibility_Match__c = false;//CISP-6902
                newApplicant.Check_Eligibility_Message__c = null;//CISP-6902
            }
            if(journeyRestartType == 'CMU_reject_Co_Borrower'){//CISP-6542
                newApplicant.Bureau_Pull_Match__c = false;
                newApplicant.Bureau_Pull_Message__c = null;
                newApplicant.Check_Eligibility_Match__c = false;//CISP-6902
                newApplicant.Check_Eligibility_Message__c = null;//CISP-6902
            }
            if(Applicant__c.SObjectType.getDescribe().isCreateable()){
                insert newApplicant;
            }
            return newApplicant.Id;
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('JourneyRestartHandler', 'cloneApplicant', System.Label.Apex, e, oldLoanApplicationId);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void cloneDocuments(String oldLoanApplicationId,String newLoanApplicationId, String ApplicationType){
        try {
            Applicant__c applicant = [SELECT Id, Applicant_Type__c From Applicant__c Where Opportunity__c =: newLoanApplicationId AND Applicant_Type__c =: ApplicationType AND In_Active_Applicant__c = false LIMIT 1];
            System.debug('applicant  '+applicant);
            String kycRecordTypeId = (String) Schema.SObjectType.Documents__c.getRecordTypeInfosByDeveloperName().get(System.Label.KYC).getRecordTypeId();
            System.debug('kycRecordTypeId  '+kycRecordTypeId);
            Map<Id,Documents__c> existingDocumentMap = new Map<Id,Documents__c>([
                SELECT Id,Salutation__c,First_Name__c,Last_Name__c,Name, Document_Type__c, KYC_name__c , KYC_Address_Line_1__c, KYC_Address_Line_2__c , KYC_Pin_Code__c,KYC_No__c,Masked_KYC_No__c,Aadhaar_Enrollment_Number__c,KYC_City__c, KYC_District__c, KYC_State__c , Proof_of_Address_POA__c,Proof_of_Identity_POI__c,is_Front_Upload_Completed__c,Current_Residential_Address_Proof__c, Permanent_Residential_Address_Proof__c,RecordTypeId,Is_Active__c,Applicant__c,Applicant__r.Applicant_Type__c,Age__c,Gender__c,KYC_DOB__c,PAN_No__c,Addresss_Type__c,Image__c,Aadhar_Source__c,Name_Mismatch_Percentage__c,Name_Mismatch_Pass__c,CMU_Accept_Reject__c,Rejection_Fields__c,CMU_Rejection_Fields__c,CMU_Rejection_Reason__c,IND_Aadhaar_Vault_Token_ID__c,DL_Type__c,KYC_Expiry_Date__c,KYC_Issuance_Date__c,KYC_Address_Line_3__c,KYC_Address_Line_4__c,Content_Document_Count__c,Document_Side__c,is_Back_Upload_Completed__c,Is_Front__c,Back_Upload_Attempts__c,Is_Back__c,Raw_Response__c,Front_Upload_Attempts__c,Passport_File_No__c,Passport_No__c,Address__c,Father_Name__c,Golden_Source_Attempts__c,Golden_Source_Pass__c,Mobile_number__c,PAN_acknowledgement_number__c,Number_of_persons_involved_in_the_transa__c,Amount_of_transaction__c,NSDL_Response__c,Pan_Approved__c,AadhaarSeedingStatus__c,NSDLNameMatch__c,NSDLPANName__c,NSDLPANStatus__c From Documents__c Where Opportunity_Relation__c =: oldLoanApplicationId AND Is_Active__c = true AND applicant_Type__c =:ApplicationType  AND (RecordTypeId =: kycRecordTypeId OR Current_Residential_Address_Proof__c = true OR Permanent_Residential_Address_Proof__c = true OR Document_Type__c = :System.Label.CustomerImageDocumentType OR Document_Type__c = :System.Label.Form60DocumentType OR Document_Type__c =: System.Label.Address_Declaration OR Case__r.RecordType.Name =: System.label.CMU_Request) AND Applicant__r.In_Active_Applicant__c = false
            ]);
            SYstem.debug('existingDocumentMap  '+existingDocumentMap);
            Map<Id,Documents__c> newDocumentMap = new Map<Id,Documents__c>();
            
            for(Documents__c document : existingDocumentMap.values()){
                Documents__c newDocument = document.clone(false,false,false,false);
                newDocument.Opportunity_Relation__c = newLoanApplicationId;
                newDocument.Applicant__c = applicant.Id;
                newDocument.Case__c = null;
                newDocument.Rejection_Fields__c = null;
                newDocument.CMU_Accept_Reject__c = null;
                newDocument.CMU_Rejection_Fields__c = null;
                newDocument.CMU_Rejection_Reason__c = null;
                newDocumentMap.put(document.id,newDocument);
            }
            SYstem.debug('newDocumentMap  '+newDocumentMap);
            if(Documents__c.SObjectType.getDescribe().isCreateable()){
                System.debug('newDocumentMap.values()  '+newDocumentMap.values());
                insert newDocumentMap.values();
            }
            List<ContentDocumentLink> contentDocList = new List<ContentDocumentLink>();
            if(existingDocumentMap.keySet().size() > 0){
                for(ContentDocumentLink contDocLink : [Select ContentDocumentId,LinkedEntityId From ContentDocumentLink Where LinkedEntityId IN : existingDocumentMap.keySet()]){
                    if(newDocumentMap.containskey(contDocLink.LinkedEntityId)){
                        ContentDocumentLink newContDocLink = new ContentDocumentLink();
                        newContDocLink.ContentDocumentId = contDocLink.ContentDocumentId;
                        newContDocLink.LinkedEntityId = newDocumentMap.get(contDocLink.LinkedEntityId).Id;
                        contentDocList.add(newContDocLink);
                    }
                }
            }
            System.debug('contentDocList  '+contentDocList);
            if(ContentDocumentLink.SObjectType.getDescribe().isCreateable() && contentDocList.size() > 0){
                insert contentDocList;
            }
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('JourneyRestartHandler ', ' cloneDocuments ', 'System.Label.Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    public static void cloneCustomerDedpue(String oldLoanApplicationId, String newLoanApplicationId, String ApplicationType){
        try {
            List<Customer_Dedupe_Response__c> newCustomerDedpueList = new List<Customer_Dedupe_Response__c>();
            Map<String,Applicant__c> applicantMap = new Map<String,Applicant__c>();
            for(Applicant__c applicant : [SELECT Id, Applicant_Type__c From Applicant__c Where Opportunity__c =: newLoanApplicationId AND In_Active_Applicant__c = false]){
                if(applicant.Applicant_Type__c == ApplicationType){
                    applicantMap.put(ApplicationType, applicant);
                }
            }
            
            List<Applicant__c> applicantList = new List<Applicant__c>([SELECT Id, Applicant_Type__c From Applicant__c Where Opportunity__c =: oldLoanApplicationId AND In_Active_Applicant__c = false]);
            List<Customer_Dedupe_Response__c> customerDedpueList = new List<Customer_Dedupe_Response__c>([Select id, SF_Cust_Dedupe__c, PG_Cust_Dedupe__c, Customer_Code__c, Invalid_Customer_Code__c, Dedupe_Journey_Status__c, Dedupe_Journey_Status_Reason__c, Response__c,Applicant__r.Applicant_Type__c,CIC_No__c,CIN_No__c,Customer_Status_Flag__c,Deal_Status_Flag__c,External_Dedupe_Status__c,Is_Journey_Skipped__c,IND_isNewCustomer__c from Customer_Dedupe_Response__c Where Applicant__c IN :applicantList]);
            if (customerDedpueList.size() > 0) {
                for(Customer_Dedupe_Response__c customerDedpue : customerDedpueList){
                    if(applicantMap.containskey(customerDedpue.Applicant__r.Applicant_Type__c)){
                        Customer_Dedupe_Response__c newCustomerDedpue = customerDedpue.clone(false, false, false, false);
                        newCustomerDedpue.Applicant__c = applicantMap.get(customerDedpue.Applicant__r.Applicant_Type__c).Id;
                        newCustomerDedpueList.add(newCustomerDedpue);
                    }
                }
            }
            
            if(newCustomerDedpueList.size() > 0 && Customer_Dedupe_Response__c.SObjectType.getDescribe().isCreateable()){
                insert newCustomerDedpueList;
            }
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('JourneyRestartHandler', 'cloneCustomerDedpue', System.Label.Apex, e, oldLoanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    
    public static ReturnMessageWrapper CMURejectCloneLoanApplication(String applicantId, String journeyRestartReason){
        try{
            ReturnMessageWrapper returnWrapperElement = new ReturnMessageWrapper();
            // Get the borrower details
            Applicant__c applicantDetails = [SELECT Id,Applicant_Type__c,Opportunity__c 
                                             FROM Applicant__c WHERE Id =: applicantId 
                                             WITH SECURITY_ENFORCED LIMIT 1];
            if(applicantDetails.Applicant_Type__c == System.label.Borrower){
                returnWrapperElement.isSuccess = true;
                returnWrapperElement.message = 'Journey has been restarted';
                Opportunity existingOpportunity = [SELECT Id,IModuleId__c,createdById,Createddate,Loan_Created_Date__c,Name, Product_Type__c , Agent_BL_code__c, AccountId, PartnerAccountId, OwnerId, Lead_number__c, Vehicle_Type__c,LeadSource,PreviousAccountId__c,(SELECT ID, createdById, Opportunity__c, Name, Customer_First_Name__c, Customer_Last_Name__c, Journey_Stage__c, Applicant_Type__c FROM Applicants__r WHERE Applicant_Type__c =: System.label.Borrower AND In_Active_Applicant__c = false) FROM Opportunity WHERE Id =: applicantDetails.Opportunity__c WITH SECURITY_ENFORCED]; //CISP-4505
                if(String.isBlank(existingOpportunity.Loan_Created_Date__c)){ 
                    existingOpportunity.Loan_Created_Date__c = IND_ApplicationFormSigning.getDateTimeFormat(existingOpportunity.Createddate); //CISP-9624
                }
                Opportunity newLoanApplication = existingOpportunity.clone(false, false, false, true); 
                newLoanApplication.StageName = 'Loan Initiation';
                newLoanApplication.Sub_Stage__c = 'User Details';
                newLoanApplication.LastStageName__c = 'Loan Initiation';
                newLoanApplication.Parent_Loan_Application__c = existingOpportunity.Id;
                newLoanApplication.CreatedById = existingOpportunity.CreatedById;
                newLoanApplication.IModuleId__c = existingOpportunity.IModuleId__c != null ? existingOpportunity.IModuleId__c : '';
                newLoanApplication.Lead_Number__c = newLoanApplication.Name = HandleJourney_Utility.handleLoanApplictionNumber(existingOpportunity.Name,'CMU Journey Restart');//CISP-6341
                newLoanApplication.CloseDate = System.today()+30;
                newLoanApplication.Agent_BL_code__c = existingOpportunity.Agent_BL_code__c;
                List<Final_Term__c> finalTermList = new List<Final_Term__c>([Select Id,CreatedById From Final_Term__c Where Loan_Application__c =: existingOpportunity.Id]);
                if((existingOpportunity.LeadSource == System.Label.MSIL_Lead_API_Value || existingOpportunity.LeadSource == System.label.Mahindra_Custom_Lead_API_Value || existingOpportunity.LeadSource == System.label.Mahindra_PreA_Lead_API_Value ) && finalTermList.size() > 0){ //CISP-15890
                    newLoanApplication.OwnerId = finalTermList[0].CreatedById;
                }else if(existingOpportunity.LeadSource == System.Label.MSIL_Lead_API_Value || existingOpportunity.LeadSource == 'DSA' || existingOpportunity.LeadSource == System.label.Mahindra_Custom_Lead_API_Value || existingOpportunity.LeadSource == System.label.Mahindra_PreA_Lead_API_Value || existingOpportunity.LeadSource == System.label.Synergy_Lead_Source){//CISP-12675 //CISP-15890//Synergy lead source added by Rajasekar as part of CISP-21840
                    newLoanApplication.OwnerId = existingOpportunity.OwnerId;
                }else{
                    newLoanApplication.OwnerId = existingOpportunity.CreatedById;
                }
                newLoanApplication.LeadSource = existingOpportunity.LeadSource;
                List<Opportunity> oppList = [SELECT Id,Lead_Number__c from Opportunity where Lead_Number__c =: newLoanApplication.Lead_Number__c LIMIT 1]; //checking if new lead number is already present or not
                if (Schema.sObjectType.Opportunity.isCreateable()  && oppList.isEmpty()){
                    insert newLoanApplication;
                    returnWrapperElement.cloneLoanApplicationId = newLoanApplication.Id;
                    returnWrapperElement.LoanApplicationLeadNumber = newLoanApplication.Lead_Number__c;
                }
                existingOpportunity.StageName = 'Journey Restart';
                existingOpportunity.Journey_Restart_Reason__c = journeyRestartReason;
            if (Schema.sObjectType.Opportunity.isUpdateable()){
                update existingOpportunity;
                if(Schema.sObjectType.Refresh_View__e.isCreateable()){
                    Refresh_View__e refreshEvent = new Refresh_View__e();
                    refreshEvent.Record_Id__c = existingOpportunity.Id;
                    refreshEvent.Stage__c = existingOpportunity.StageName;
                    EventBus.publish(refreshEvent);
                }
            }
                if(newLoanApplication.Id != null){
                    CustomNotificationWrapper customNotification = new CustomNotificationWrapper();
                    customNotification.loanApplicationId = newLoanApplication.Id;
                    if(existingOpportunity.LeadSource == 'DSA' || existingOpportunity.LeadSource == System.label.Synergy_Lead_Source){//CISP-12675//Synergy lead source added by Rajasekar as part of CISP-21840
                        customNotification.ownerId = existingOpportunity.ownerId;
                    }else{
                        customNotification.ownerId = existingOpportunity.CreatedById;
                    }//CISP-12675
                    customNotification.notificationTitle = 'Loan Application Assignment';
                    customNotification.notificationBody = 'Loan Application ' + newLoanApplication.Lead_Number__c +' has been assigned to you.';
                    sendCustomNotification(customNotification);
                }

                CustomNotificationWrapper customNotification1 = new CustomNotificationWrapper();
                customNotification1.loanApplicationId = existingOpportunity.Id;
                customNotification1.ownerId = existingOpportunity.OwnerId;
                customNotification1.notificationTitle = 'Loan Application Journey Restart';
                customNotification1.notificationBody = 'Loan Application ' + existingOpportunity.Lead_Number__c +' journey has been restarted.Please refresh the screen.';
                sendCustomNotification(customNotification1);
            }else{
                returnWrapperElement.isSuccess = false;
                returnWrapperElement.message = 'Invalid Applicant Id'; 
            }
            return returnWrapperElement;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('JourneyRestartHandler', 'CMURejectCloneLoanApplication', System.Label.Apex, e, applicantId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    public static void updateOldCase(String oldLoanApplicationId, List<String> caseRecordTypeList){
        try {
            Map<Id,RecordType> recordTypeMap = new Map<Id,RecordType>([SELECT id from RecordType where DeveloperName IN : caseRecordTypeList]);
            List<Case> existingCaseList = new List<Case>([
                SELECT Id,OwnerId,CaseNumber From Case WHERE Loan_Application__c =: oldLoanApplicationId AND RecordTypeId IN : recordTypeMap.keySet()
            ]);

            for(Case caseObj : existingCaseList){
                caseObj.status = 'Closed';
                caseObj.Description = 'Case is close at::'+string.valueOf(Datetime.now());
            }

            if(Case.SObjectType.getDescribe().isUpdateable()){
                update existingCaseList;
            }

        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('JourneyRestartHandler', 'updateOldCase', System.Label.Apex, e, oldLoanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    public static void cloneCibil(String oldLoanApplicationId, String newLoanApplicationId){
        try {
            if (oldLoanApplicationId != null && newLoanApplicationId != null) {
                Map<String,Applicant__c> newApplicantMap = new Map<String,Applicant__c>();
                for(Applicant__c applicant : [SELECT Id, Applicant_Type__c From Applicant__c Where Opportunity__c =: newLoanApplicationId AND Applicant_Type__c =: System.Label.Borrower AND In_Active_Applicant__c = false LIMIT 1]){
                    if(applicant.Applicant_Type__c == System.Label.Borrower){
                        newApplicantMap.put(System.Label.Borrower, applicant);
                    }
                }
                
                List<Applicant__c> oldApplicantList = new List<Applicant__c>([SELECT Id, Applicant_Type__c From Applicant__c Where Opportunity__c =: oldLoanApplicationId AND Applicant_Type__c =:System.Label.Borrower AND In_Active_Applicant__c = false  LIMIT 1]);

                List<CIBIL_Details__c> cibilList = new List<CIBIL_Details__c>([Select id,Amount_Overdue__c,Cibil_Decision__c,CIBIL_Report_URl__c,CIC_No__c,CRIF_Score_Desc__c,Current_Balance__c,Entity_Type__c,Equifax_Report_URl__c,HighCredit_Or_SanctionedAmount__c,Month_Overdue__c,NoOfEnLtSixMon__c,Oldest_Date__c,Recent_Date__c,Score__c,SuitFiledOrWilfulDefault__c,Type__c,WrittenoffAmountTotal__c,Maker_Date__c,Applicant__r.Applicant_Type__c From CIBIL_Details__c Where Applicant__c IN : oldApplicantList LIMIT 100]);

                if (cibilList.size() > 0) {
                    List<CIBIL_Details__c> newCibilList = new List<CIBIL_Details__c>();
                    for(CIBIL_Details__c cibilRecord : cibilList){
                        if(newApplicantMap.containskey(cibilRecord.Applicant__r.Applicant_Type__c)){
                            CIBIL_Details__c newCibilRecord = cibilRecord.clone(false, false, false, false);
                            newCibilRecord.Applicant__c = newApplicantMap.get(cibilRecord.Applicant__r.Applicant_Type__c).Id;
                            newCibilList.add(newCibilRecord);
                        }
                    }

                    if(newCibilList.size() > 0 && CIBIL_Details__c.SObjectType.getDescribe().isCreateable()){
                        insert newCibilList;
                    }
                }
            }
            
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('JourneyRestartHandler', 'cloneCibil', System.Label.Apex, e, oldLoanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    public static void sendCustomNotification(CustomNotificationWrapper customNotification) {
        try {
            CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'Notification_to_Onwer'];
            Messaging.CustomNotification noti = new Messaging.CustomNotification();
            
            if(customNotification.notificationTitle == 'Loan Application Assignment'){
                noti.setBody(customNotification.notificationBody);
                noti.setTitle(customNotification.notificationTitle);
                noti.setNotificationTypeId(notificationType.Id);
                noti.setTargetId(customNotification.loanApplicationId);
                noti.send(new Set<String> { customNotification.ownerId });
            }else if(customNotification.notificationTitle == 'Loan Application Journey Restart'){
                noti.setBody(customNotification.notificationBody);
                noti.setTitle(customNotification.notificationTitle);
                noti.setNotificationTypeId(notificationType.Id);
                noti.setTargetId(customNotification.loanApplicationId);
                noti.send(new Set<String> { customNotification.ownerId });
            }            
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('JourneyRestartHandler', 'sendCustomNotification', System.Label.Apex, e, customNotification.loanApplicationId);
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
    
    public Class ReturnMessageWrapper{
        @AuraEnabled public Boolean isSuccess {get;set;}
        @AuraEnabled public String message {get;set;}
        @AuraEnabled public String cloneLoanApplicationId {get;set;}
        @AuraEnabled public String cloneBorrowerApplicantId {get;set;}
        @AuraEnabled public String cloneCoBorrowerApplicantId {get;set;}
        @AuraEnabled public String LoanApplicationLeadNumber {get;set;}
    }
    public static ApplicantWrapper cloneApplicantTractor(String oldLoanApplicationId, String newLoanApplicationId, String applicantId, String journeyRestartType){
        try{
            List<String> applicantIds = new List<String>();
            if(applicantId.split('-').size() > 0){
                applicantIds = applicantId.split('-');
            }
            List<Applicant__c> existingApplicantList = [SELECT Id,AepS_Info__c,Contact_number__c,Name,OTP_for_borrower__c,Selfie_Retry_Attempts__c,Customer_First_Name__c,Customer_Last_Name__c,Whatsapp_number__c,customer_image_attempts__c,Applicant_Type__c,DocAuth_Application_Id__c,Selfie_Upload__c,Customer_code__c,Consent_Received__c,Register_for_WhatsApp_Banking__c,Journey_Stage__c,Declared_income__c,Loan_Amount__c,Do_you_have_a_bank_account__c,Do_you_have_a_bank_account_with_IBL__c,Would_you_like_to_open_a_bank_account__c,Current_Same_As_Permanent__c, Current_Address_Not_Present__c,Permanent_Address_Not_Present__c,In_Active_Applicant__c,Income_source_available__c,Is_Address_Declaration__c,isCodeValidateBySalesUser__c,Category__c,CRIFF_Report_URL__c,Gating_Screening_Outcome__c,IsPrimary__c,Literacy__c,Profile__c,Beneficial_Owner_Category__c,Relationship_with_Entity__c,Relationship_Type__c,POA_Holder__c,ShareHolding__c,Salutation__c,Gender__c,Employer_Type__c,Date_of_Birth__c,Is_Customer_NRI__c,Work_Permit_No__c,Permit_Validity__c,Work_Visa_Details__c,LegalEntityIdentifier__c,Salaried_Self_employed__c,Beneficiary_Office_Address_Line_1__c,Beneficiary_Office_Address_Line_2__c,Beneficiary_Office_City__c,Beneficiary_Office_Pincode__c,Beneficiary_Office_State__c,Beneficiary_Office_District__c,Feedback_Ref_1__c,Feedback_Ref_2__c  FROM Applicant__c Where Opportunity__c =: oldLoanApplicationId AND In_Active_Applicant__c = false Order By CreatedDate ASC LIMIT 20];

            ApplicantWrapper wrapper = new ApplicantWrapper();

            List<Applicant__c> newApplicantInsertList = new List<Applicant__c>();

            for(Applicant__c existingApplicant: existingApplicantList) {
                if(journeyRestartType == 'Journey_Reject_Borrower_Tractor' || journeyRestartType == 'Journey_Reject_NonBorrower_Tractor'){
                    Applicant__c newApplicant = existingApplicant.clone(false, false, false, false);
                    newApplicant.Opportunity__c = newLoanApplicationId;
                    if((applicantIds.size() > 0 && applicantIds.contains(existingApplicant.Id)) && ((journeyRestartType == 'Journey_Reject_Borrower_Tractor') || (journeyRestartType == 'Journey_Reject_NonBorrower_Tractor' && (existingApplicant.Applicant_Type__c == System.Label.coBorrower || existingApplicant.Applicant_Type__c == Label.Guarantor || existingApplicant.Applicant_Type__c == Label.Beneficiary)))){
                        newApplicant.Journey_Stage__c = 'Capture Dedupe';
                        newApplicant.Income_source_available__c = false;
                        newApplicant.Declared_income__c = null;
                        newApplicant.Do_you_have_a_bank_account__c = false;
                        newApplicant.Do_you_have_a_bank_account_with_IBL__c = false;
                        newApplicant.Would_you_like_to_open_a_bank_account__c = false;
                    } else{
                        newApplicant.Journey_Stage__c = 'Gatting And Screening';
                    }
                    newApplicantInsertList.add(newApplicant);
                }else if(journeyRestartType == 'Journey_Restart_Borrower_Tractor' || journeyRestartType == 'Journey_Restart_NonBorrower_Tractor'){
                    Applicant__c newApplicant = new Applicant__c();
                    if(applicantIds.size() > 0 && applicantIds.contains(existingApplicant.Id)) {
                        newApplicant.Name = existingApplicant.Name;
                        newApplicant.Opportunity__c = newLoanApplicationId;
                        newApplicant.Applicant_Type__c = existingApplicant.Applicant_Type__c;
                        newApplicant.Journey_Stage__c = 'User Details';
                        newApplicant.In_Active_Applicant__c = false;
                    } else{
                        newApplicant = existingApplicant.clone(false, false, false, false);
                        newApplicant.Opportunity__c = newLoanApplicationId;
                        newApplicant.Journey_Stage__c = 'Gatting And Screening';
                    }
                    newApplicantInsertList.add(newApplicant);
                }
            }

            if(!newApplicantInsertList.isEmpty() && Applicant__c.SObjectType.getDescribe().isCreateable()){
                insert newApplicantInsertList;
            }

            Map<Id, Id> clonedApplicantMap = new Map<Id, Id>();
            List<Applicant__c> newApplicantList = new List<Applicant__c>();
            List<Applicant__c> existingList = new List<Applicant__c>();

            for(integer i = 0; i < existingApplicantList.size(); i++) {

                if(journeyRestartType == 'Journey_Reject_Borrower_Tractor' || journeyRestartType == 'Journey_Reject_NonBorrower_Tractor'){
                    clonedApplicantMap.put(existingApplicantList[i].Id, newApplicantInsertList[i].Id);
                    existingList.add(existingApplicantList[i]);
                    newApplicantList.add(newApplicantInsertList[i]);
                }else if(journeyRestartType == 'Journey_Restart_Borrower_Tractor' || journeyRestartType == 'Journey_Restart_NonBorrower_Tractor'){
                    if(applicantIds.size() > 0 && !applicantIds.contains(existingApplicantList[i].Id)) {
                        clonedApplicantMap.put(existingApplicantList[i].Id, newApplicantInsertList[i].Id);
                        existingList.add(existingApplicantList[i]);
                        newApplicantList.add(newApplicantInsertList[i]);
                    }
                }

            }

            wrapper.existingApplicantList = existingList;
            wrapper.newApplicantList = newApplicantList;
            wrapper.clonedApplicantMap = clonedApplicantMap;

            return wrapper;
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('JourneyRestartHandler', 'cloneApplicantTractor', System.Label.Apex, e, oldLoanApplicationId);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void cloneDocumentsTractor(String oldLoanApplicationId, String newLoanApplicationId, ApplicantWrapper wrapper){
        try {
            String kycRecordTypeId = (String) Schema.SObjectType.Documents__c.getRecordTypeInfosByDeveloperName().get(System.Label.KYC).getRecordTypeId();
            Map<Id, Documents__c> existingDocumentMap = new Map<Id, Documents__c>([
                SELECT Id,Salutation__c,First_Name__c,Last_Name__c,Name, Document_Type__c, KYC_name__c , KYC_Address_Line_1__c, KYC_Address_Line_2__c , KYC_Pin_Code__c,
                KYC_No__c,Masked_KYC_No__c,Aadhaar_Enrollment_Number__c,KYC_City__c, KYC_District__c, KYC_State__c , Proof_of_Address_POA__c,Proof_of_Identity_POI__c,
                is_Front_Upload_Completed__c,Current_Residential_Address_Proof__c, Permanent_Residential_Address_Proof__c,RecordTypeId,Is_Active__c,Applicant__c,
                Applicant__r.Applicant_Type__c,Age__c,Gender__c,KYC_DOB__c,PAN_No__c,Addresss_Type__c,Image__c,Aadhar_Source__c,Name_Mismatch_Percentage__c,
                Name_Mismatch_Pass__c,CMU_Accept_Reject__c,Rejection_Fields__c,CMU_Rejection_Fields__c,CMU_Rejection_Reason__c,IND_Aadhaar_Vault_Token_ID__c,DL_Type__c,
                KYC_Expiry_Date__c,KYC_Issuance_Date__c,KYC_Address_Line_3__c,KYC_Address_Line_4__c,Content_Document_Count__c,Document_Side__c,is_Back_Upload_Completed__c,
                Is_Front__c,Back_Upload_Attempts__c,Is_Back__c,Raw_Response__c,Front_Upload_Attempts__c,Passport_File_No__c,Passport_No__c,Address__c,Father_Name__c,
                Golden_Source_Attempts__c,Golden_Source_Pass__c,Mobile_number__c,PAN_acknowledgement_number__c,Number_of_persons_involved_in_the_transa__c,
                Amount_of_transaction__c From Documents__c Where Opportunity_Relation__c =: oldLoanApplicationId AND Is_Active__c = true
                AND (RecordTypeId =: kycRecordTypeId OR Current_Residential_Address_Proof__c = true OR Permanent_Residential_Address_Proof__c = true OR 
                Document_Type__c = :System.Label.CustomerImageDocumentType OR Document_Type__c = :System.Label.Form60DocumentType OR 
                Document_Type__c =: System.Label.Address_Declaration OR Case__r.RecordType.Name =: System.label.CMU_Request) AND Applicant__r.In_Active_Applicant__c = false AND
                Applicant__c In: wrapper.existingApplicantList
            ]);

            Map<Id, Documents__c> newDocumentMap = new Map<Id, Documents__c>();
            
            for(Documents__c document : existingDocumentMap.values()){
                String newApplicantId = wrapper.clonedApplicantMap.get(document.Applicant__c);

                Documents__c newDocument = document.clone(false,false,false,false);
                newDocument.Opportunity_Relation__c = newLoanApplicationId;
                newDocument.Applicant__c = newApplicantId;
                newDocument.Case__c = null;
                newDocument.Rejection_Fields__c = null;
                newDocument.CMU_Accept_Reject__c = null;
                newDocument.CMU_Rejection_Fields__c = null;
                newDocument.CMU_Rejection_Reason__c = null;

                newDocumentMap.put(document.Id, newDocument);
            }

            if(Documents__c.SObjectType.getDescribe().isCreateable()){
                insert newDocumentMap.values();
            }

            List<ContentDocumentLink> contentDocList = new List<ContentDocumentLink>();
            if(existingDocumentMap.keySet().size() > 0){
                for(ContentDocumentLink contDocLink : [Select ContentDocumentId, LinkedEntityId From ContentDocumentLink Where LinkedEntityId IN : existingDocumentMap.keySet()]){
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
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('JourneyRestartHandler ', ' cloneDocumentsTractor ', 'System.Label.Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    public static void cloneCustomerDedpueTractor(String oldLoanApplicationId, ApplicantWrapper wrapper){
        try {
            List<Customer_Dedupe_Response__c> newCustomerDedpueList = new List<Customer_Dedupe_Response__c>();
            
            List<Customer_Dedupe_Response__c> customerDedpueList = new List<Customer_Dedupe_Response__c>([Select id, SF_Cust_Dedupe__c, PG_Cust_Dedupe__c, Customer_Code__c, 
            Invalid_Customer_Code__c, Dedupe_Journey_Status__c, Dedupe_Journey_Status_Reason__c, Response__c,Applicant__r.Applicant_Type__c,CIC_No__c,CIN_No__c,
            Customer_Status_Flag__c,Deal_Status_Flag__c,External_Dedupe_Status__c,Is_Journey_Skipped__c,IND_isNewCustomer__c from Customer_Dedupe_Response__c WHERE
            Applicant__c In: wrapper.existingApplicantList]);

            if (!customerDedpueList.isEmpty()) {
                for(Customer_Dedupe_Response__c customerDedpue : customerDedpueList){
                    String newApplicantId = wrapper.clonedApplicantMap.get(customerDedpue.Applicant__c);

                    Customer_Dedupe_Response__c newCustomerDedpue = customerDedpue.clone(false, false, false, false);
                    newCustomerDedpue.Applicant__c = newApplicantId;
                    newCustomerDedpueList.add(newCustomerDedpue);
                }
            }
            
            if(!newCustomerDedpueList.isEmpty() && Customer_Dedupe_Response__c.SObjectType.getDescribe().isCreateable()){
                insert newCustomerDedpueList;
            }

        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('JourneyRestartHandler', 'cloneCustomerDedpueTractor', System.Label.Apex, e, oldLoanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    public static void cloneVehicleDetailTractor(String oldLoanApplicationId, String newLoanApplicationId) {
        try {
            List<Vehicle_Detail__c> newVehicleDetailList = new List<Vehicle_Detail__c>();
            
            List<Vehicle_Detail__c> existingVehicleDetailList = new List<Vehicle_Detail__c>([SELECT Id,Vehicle_type__c,Vehicle_Registration_number__c, Engine_number__c, Chassis_number__c,Serial_number__c,Vehicle_SubCategory__c,Vehicle_SubType__c,Vehicle_Verified__c,Vehicle_Proceed_Flag__c,
            Vehicle_Delivered__c,Registration_Number_Format__c,Customer_Code__c,Parent_Deal_Number__c FROM Vehicle_Detail__c WHERE Loan_Application__c =: oldLoanApplicationId]);

            if (!existingVehicleDetailList.isEmpty()) {
                for(Vehicle_Detail__c record : existingVehicleDetailList){

                    Vehicle_Detail__c vehicleDetail = record.clone(false, false, false, false);
                    vehicleDetail.Loan_Application__c = newLoanApplicationId;
                    newVehicleDetailList.add(vehicleDetail);
                }
            }
            if(!newVehicleDetailList.isEmpty()){
                insert newVehicleDetailList;
            }

        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('JourneyRestartHandler', 'cloneCustomerDedpue', System.Label.Apex, e, oldLoanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    public Class ApplicantWrapper{
        @AuraEnabled public Map<Id, Id> clonedApplicantMap {get;set;}
        @AuraEnabled public List<Applicant__c> existingApplicantList {get;set;}
        @AuraEnabled public List<Applicant__c> newApplicantList {get;set;}
    }
}