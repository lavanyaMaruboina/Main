/*------------------------------------------------------------
Author:        Manish Baldota
Company:       Persistent Systems
Description:   This class handles the change CMU case change owner logic.
                1. CMU --> Last Sales Person.
                2. Last Sales Person --> Last working CMU.
Test Class:    
History
Date            Author              Comments
-------------------------------------------------------------
12-17-2021      Manish Baldota       Created
------------------------------------------------------------*/
public without sharing class LWC_LOS_CMUCaseOwnerChangeFlow_cntrl {
    @AuraEnabled
    public static string handleChangeOwnerProcess(String caseId){
        try{
            if(String.isNotBlank(caseId) && caseId != null){
                ReturnMessageWrapper returnWrapperElement = new ReturnMessageWrapper();
                Boolean isAllAccepted = true; //To check all the documents are accepted
                Map<Id,Documents__c> mapOfRejectedDocuments = new Map<Id,Documents__c>();
                Map<Id,Documents__c> mapOfRejectedDocumentsforCB = new Map<Id,Documents__c>();
                Boolean isAppCustomerCodeblanck = false;//CISP-3447
                Boolean borrowerCustomerCodeGenerated = false;//CISP-16280
                Boolean coBorrowerCustomerCodeGenerated = false;//CISP-16280
                Boolean coBorrowerPresent = false;//CISP-16280
                Boolean gurantorPresent = false; //SFTRAC-395
                Boolean gurantorCustomerCodeGenerated = false; //SFTRAC-395
                Boolean beneCustomerCodeGenerated = false; //SFTRAC-395
                Boolean benePresent = false;
                Boolean isSavedCR = false;
                Boolean isNonIndividualTractor = false;
                Boolean isTractor = false;//CISP-16280
                Case currentCase = [SELECT ID ,Loan_Application__r.Owner.IsActive,Loan_Application__r.Is_Revoked__c,Loan_Application__r.Name,Loan_Application__r.Is_Customer_Dedupe_Submit__c,Loan_Application__r.Journey_Status__c , Loan_Application__r.Journey_Stop_Reason__c,OwnerId,CreatedById,Status,owner.ProfileID,CMU_Case_Accepted_By__c,CMU_Case_Accepted_By__r.Name,CMU_Case_Submitted_By__c,Accept_Case__c,CMU_CaseTeamMember_Loanapp_Owner__c,CMU_CaseTeamMember_FI_User__c,CMU_Rejected__c,Loan_Application__c,Loan_Application__r.Parent_Loan_Application__r.Is_Revoked__c,Loan_Application__r.Parent_Loan_Application__c,Loan_Application__r.CreatedById,Loan_Application__r.Last_Sales_User__c,Loan_Application__r.OwnerId,Loan_Application__r.LeadSource, Loan_Application__r.Owner.ProfileID,Description, Loan_Application__r.Product_Type__c,(SELECT ID,Name,CMU_Accept_Reject__c,CMU_Rejection_Reason__c,Applicant__c,Applicant__r.Applicant_Type__c,Rejection_Fields__c,Aadhar_Source__c,Proof_of_Identity_POI__c, Document_Type__c,Proof_of_Address_POA__c,isFrontDocReplaced__c,isBackDocReplaced__c,AadhaarSeedingStatus__c FROM Documents__r where Applicant__r.In_Active_Applicant__c = false and (Aadhar_Source__c !='Biometric' OR (Applicant__r.Is_Address_Declaration__c = true AND Aadhar_Source__c = 'Biometric')) AND Is_active__c = true) FROM Case WHERE ID =: caseId Limit 1];//CISP-2667- Added Is_active__c check in the query. // CISP-3116 - Added is_address_Declaration //CISP-3447 added applicant type field
                //CISP-3447 start //CISP-4332 
                if(currentCase.Loan_Application__r.Is_Customer_Dedupe_Submit__c == false){
                    isAppCustomerCodeblanck = true;
                }
                List<Opportunity> oppListUpdatePriority = [Select ID,Priority_Flag__c,Entity_Type__c,Customer_Type__c,Product_Type__c from Opportunity where ID =: currentCase.Loan_Application__c LIMIT 1];    
                //CISP-3447 end
                //CISP-16280 start
                List<Applicant__c> appList = [SELECT ID,Opportunity__r.Product_Type__c,Opportunity__r.LeadSource, Applicant_Type__c,IND_Customer_Master_Creation_Status__c,IND_Customer_Master_Updation_Status__c,Opportunity__r.Customer_Type__c,Saved_Customer_Relation__c FROM Applicant__c where Opportunity__c =:oppListUpdatePriority[0].Id AND In_Active_Applicant__c = false];
                for(Applicant__c appObj : appList){
                    if(appObj.Opportunity__r.Product_Type__c == 'Tractor'){
                        isTractor = true;
                    }
                    if(appObj.Opportunity__r.Product_Type__c == 'Tractor' && appObj.Opportunity__r.Customer_Type__c == 'Non-Individual'){
                        isNonIndividualTractor = true;
                    }
                    if(appObj.Applicant_Type__c == 'Borrower' && (appObj.IND_Customer_Master_Creation_Status__c == true || appObj.IND_Customer_Master_Updation_Status__c == true) && isTractor){
                        borrowerCustomerCodeGenerated = true;
                    }
                    if(appObj.Applicant_Type__c == 'Co-borrower' && isTractor){
                        coBorrowerPresent = true;
                        if(appObj.IND_Customer_Master_Creation_Status__c == true || appObj.IND_Customer_Master_Updation_Status__c == true){
                            coBorrowerCustomerCodeGenerated = true;
                        }
                    }
                    if(appObj.Opportunity__r.Product_Type__c == 'Tractor' && appObj.Applicant_Type__c == 'Guarantor'){
                        gurantorPresent = true;
                        if(appObj.IND_Customer_Master_Creation_Status__c == true || appObj.IND_Customer_Master_Updation_Status__c == true){
                            gurantorCustomerCodeGenerated = true;
                        }
                    }
                    if(appObj.Opportunity__r.Product_Type__c == 'Tractor' && appObj.Opportunity__r.Customer_Type__c == 'Non-Individual' && appObj.Applicant_Type__c == 'Beneficiary'){
                        benePresent = true;
                        if(appObj.IND_Customer_Master_Creation_Status__c == true || appObj.IND_Customer_Master_Updation_Status__c == true){
                            beneCustomerCodeGenerated = true;
                        }
                    }
                    if(appObj.Opportunity__r.Product_Type__c == 'Tractor' && appObj.Opportunity__r.Customer_Type__c == 'Non-Individual' && appObj.Applicant_Type__c == 'Borrower' && appObj.Saved_Customer_Relation__c == true){
                        isSavedCR = true;
                    }
                }//CISP-16280 end
                String caseOwnerProfileName = [SELECT Name FROM Profile WHERE Id =: currentCase.Owner.ProfileID Limit 1].Name;

                if(currentCase.OwnerId != UserInfo.getUserId()){
                    throw new IND_Exception('You do not have permission to perform this action.');
                }

                if(currentCase.Status == 'Closed'){
                    throw new IND_Exception('Case is already closed.');
                }
                if(currentCase.Loan_Application__r.Is_Revoked__c){
                    String returnMessage = 'The loan applicaton is revoked. You are not allowed to proceed with this application and Case is closed.';
                    if(!oppListUpdatePriority.isEmpty()){
                        oppListUpdatePriority[0].Priority_Flag__c = false;
                        update oppListUpdatePriority;
                    }
                    returnWrapperElement.isSuccess = true;
                    returnWrapperElement.message = returnMessage;
                    return System.JSON.serialize(returnWrapperElement);
                }
                //CISP-4681 start
                if(currentCase.Loan_Application__r.Journey_Status__c == 'Stop'){
                    currentCase.Status = 'Closed';//If any journey stop secanrio found at the time of submit we are closing the case.
                    currentCase.Description = 'Case is closed due to journey status is stop';
                    update currentCase;
                    //CISP-6941
                    if(!oppListUpdatePriority.isEmpty()){
                        oppListUpdatePriority[0].Priority_Flag__c = false;
                        update oppListUpdatePriority;
                    }//CISP-6941 end

                    String msg = '';
                    if(currentCase.Loan_Application__r.Journey_Stop_Reason__c != null || currentCase.Loan_Application__r.Journey_Stop_Reason__c != ''){
                        msg = currentCase.Loan_Application__r.Journey_Stop_Reason__c + ' Case is closed.';
                    }else{
                        msg = 'You are not allowed to proceed with this application. Journey has been stopped for this lead and Case is closed.';
                    }
                    returnWrapperElement.isSuccess = true;
                    returnWrapperElement.message = msg;
                    return System.JSON.serialize(returnWrapperElement);
                }//CISP-4681 start
                System.debug('Log - Case:: '+currentCase);
                System.debug('Log - Case Owner Profile Name:: '+caseOwnerProfileName);
                //Check all the documents are decided, if not throwing error to user and next execution is skipped here.
                if(caseOwnerProfileName == 'CMU'){//CISP-3240 - Added if condition only
                    for(Documents__c document : currentCase.Documents__r){
                        if(String.isBlank(document.CMU_Accept_Reject__c)){
                            isAllAccepted = false;
                            throw new IND_Exception('Make sure you have selected Accept/Reject on all the documents.');
                        } else if(document.CMU_Accept_Reject__c == 'Reject'){
                            isAllAccepted = false;
                            if(document.Applicant__r.Applicant_Type__c == 'Borrower')
                                mapOfRejectedDocuments.put(document.Id,document);
                            if(document.Applicant__r.Applicant_Type__c != null && document.Applicant__r.Applicant_Type__c != Label.Borrower){
                                mapOfRejectedDocumentsforCB.put(document.Id,document);
                            }
                        }
                    }
                    mapOfRejectedDocuments.putAll(mapOfRejectedDocumentsforCB);
                }

                //1. All Document Accepted - Case Closed scenario
                if(caseOwnerProfileName == 'CMU' && isAllAccepted){
                    if(isAppCustomerCodeblanck == true){//CISP-3447
                        returnWrapperElement.isSuccess = true;
                        returnWrapperElement.message = 'Dedupe response pending from CMU side';
                        return System.JSON.serialize(returnWrapperElement);
                    }else if(isTractor == true && (borrowerCustomerCodeGenerated == false || (coBorrowerPresent == true && coBorrowerCustomerCodeGenerated == false) || ((gurantorPresent == true && gurantorCustomerCodeGenerated == false) || (benePresent == true && beneCustomerCodeGenerated == false)))){
                        returnWrapperElement.isSuccess = true;
                        returnWrapperElement.message = 'Please Generate Customer code';
                        return System.JSON.serialize(returnWrapperElement);
                    } else if(isNonIndividualTractor == true && isSavedCR == false){
                        returnWrapperElement.isSuccess = true;
                        returnWrapperElement.message = 'Please Save Customer Relation';
                        return System.JSON.serialize(returnWrapperElement);
                    } else {
                        currentCase.Status = 'Closed';
                        currentCase.Description = 'CMU verified all the documents and accepted the Case.';
                        currentCase.Accept_Case__c = false;
                        currentCase.CMU_Case_Accepted_By__c = null;
                        currentCase.CMU_Rejected__c = false;
                        currentCase.CMU_CaseTeamMember_FI_User__c = null;
                        currentCase.CMU_CaseTeamMember_Loanapp_Owner__c = null;

                        if (Schema.sObjectType.Case.isUpdateable()) {
                            Database.DMLOptions options = new Database.DMLOptions();
                            options.EmailHeader.triggerUserEmail = true;
                            database.update(currentCase, options);
                            //update currentCase;
                        } 
                        //CISP-6941
                         if(!oppListUpdatePriority.isEmpty()){
                            oppListUpdatePriority[0].Priority_Flag__c = false;
                            update oppListUpdatePriority;
                        }//CISP-6941 end 

                        List<OpportunityTeamMember> oppurtunityTeamMembersToBeDeleted = new List<OpportunityTeamMember>([SELECT Id,TeamMemberRole,OpportunityId FROM OpportunityTeamMember WHERE UserId =:currentCase.OwnerId  AND OpportunityId =:currentCase.Loan_Application__c AND TeamMemberRole = 'CMU']);
                        if(!oppurtunityTeamMembersToBeDeleted.isEmpty()){           	
                            CaseWithoutSharingUpdate.deleteOTMRecords(oppurtunityTeamMembersToBeDeleted);
                        } 

                        returnWrapperElement.isSuccess = true;
                        returnWrapperElement.message = 'Case is closed as all documents are accepted';
                        return System.JSON.serialize(returnWrapperElement);
                    }
                } else if(caseOwnerProfileName == 'CMU' && !isAllAccepted){
                    List<String> nonCriticalRejectionFieldsList = new List<String>{'Aadhaar KYC value not masked','Image not clear','Minor KYC/PAN attached','Image not pertains to this customer','Father name incorrect','Mother name incorrect','Spouse name incorrect','Incomplete document','PAN is not linked to Aadhaar'};
                    //2. Document Not Accepted
                    String ApplicantId = '';
                    String restartReson = '';
                    String applicantTypeData = '';//CISP-3447

                    List<String> restartReasonList = new List<String>();
                    List<Id> applicantIds = new List<Id>();
                    String journeyRestartTypeTF = 'Journey_Restart_NonBorrower_Tractor';

                    Boolean caseTeamMemberNotPresent = false;
                    List<String> niRejectionReasons = new List<String>{'Relationship not tagged properly','Shareholding pattern not tagged properly','Entity type mismatch','Document number mismatch for mandatory documents','DOI incorrect'};
                    if(isTractor){
                        for(Documents__c rejectedDocument : mapOfRejectedDocuments.values()){
                            Boolean isNonCritical = false;
                            if(String.isNotBlank(rejectedDocument.Rejection_Fields__c)){
                                for(String str : nonCriticalRejectionFieldsList){
                                    if(rejectedDocument.Rejection_Fields__c.contains(str)){
                                        isNonCritical = true;
                                        break;
                                    }
                                }
                            }
                            if(isNonCritical){
                                continue;
                            }
                            if(!applicantIds.contains(rejectedDocument.Applicant__c)){
                                applicantIds.add(rejectedDocument.Applicant__c);
                            }
                            if(rejectedDocument.Applicant__r.Applicant_Type__c == Label.Borrower){
                                journeyRestartTypeTF = 'Journey_Restart_Borrower_Tractor';
                            }
                            //CISP-3116-START
                            if(rejectedDocument.Document_Type__c == System.Label.AadhaarCard && rejectedDocument.Aadhar_Source__c == System.Label.Biometric && rejectedDocument.CMU_Rejection_Reason__c != null){
                                if(!restartReasonList.contains('CMU has selected '+rejectedDocument.CMU_Rejection_Reason__c+' as a Rejection Reason for e-KYC document')){
                                    restartReasonList.add('CMU has selected '+rejectedDocument.CMU_Rejection_Reason__c+' as a Rejection Reason for e-KYC document');
                                }
                            }
                            //CISP-3116-END

                            if(!String.isBlank(rejectedDocument.CMU_Rejection_Reason__c) && rejectedDocument.Document_Type__c == System.Label.PanCards){
                                if(rejectedDocument.CMU_Rejection_Reason__c == 'Name of the applicant / customer does not match as per NSDL records'){
                                    if(!restartReasonList.contains('CMU has selected '+rejectedDocument.CMU_Rejection_Reason__c+' as a Rejection Reason for Pan Document')){
                                        restartReasonList.add('CMU has selected '+rejectedDocument.CMU_Rejection_Reason__c+' as a Rejection Reason for Pan Document');
                                    }
                                }
                            }

                            if(rejectedDocument.CMU_Rejection_Reason__c == 'Incorrect fields' && !String.isBlank(rejectedDocument.Rejection_Fields__c) && (rejectedDocument.Proof_of_Identity_POI__c || rejectedDocument.Document_Type__c == System.Label.PanCards || rejectedDocument.Proof_of_Address_POA__c)){
                                List<String> criticalFields = getMetadata(rejectedDocument.Document_Type__c).trim().split(';');
                                List<String> rejectedFields = rejectedDocument.Rejection_Fields__c.split(';');
                                Boolean criticalMatchFound = false;
    
                                for(String rejectField : rejectedFields){
                                    for(String crField : criticalFields){
                                        if(crField == rejectField){
                                            criticalMatchFound = true;
                                            break;
                                        }
                                    }
                                } 
    
                                if(criticalMatchFound){
                                    if(!restartReasonList.contains('CMU has selected '+rejectedDocument.CMU_Rejection_Reason__c+' as a Rejection Reason for POA/POI/PAN document')){
                                        restartReasonList.add('CMU has selected '+rejectedDocument.CMU_Rejection_Reason__c+' as a Rejection Reason for POA/POI/PAN document');
                                    }
                                }
                                //2.2. Incorrect POI/PAN/POA Documents 
                            } else if(rejectedDocument.CMU_Rejection_Reason__c == 'Incorrect document' && (rejectedDocument.Proof_of_Identity_POI__c || rejectedDocument.Document_Type__c == System.Label.PanCards || rejectedDocument.Proof_of_Address_POA__c)){
                                if(!restartReasonList.contains('CMU has selected '+rejectedDocument.CMU_Rejection_Reason__c+' as a Rejection Reason for POA/POI/PAN document')){
                                    restartReasonList.add('CMU has selected '+rejectedDocument.CMU_Rejection_Reason__c+' as a Rejection Reason for POA/POI/PAN document');
                                }
                            }
                            if(!String.isBlank(rejectedDocument.Rejection_Fields__c) && rejectedDocument.Proof_of_Identity_POI__c) {
                                List<String> rejectedFields = rejectedDocument.Rejection_Fields__c.split(';');
                                for(String rejectField : rejectedFields){
                                    if('Gender' == rejectField){
                                        if(!restartReasonList.contains('CMU has rejected the gender of the applicant on '+rejectedDocument.Name+'; hence, journey has re-started. Please proceed with lead number: '+currentCase.Loan_Application__r.Name+'C')){
                                            restartReasonList.add('CMU has rejected the gender of the applicant on '+rejectedDocument.Name+'; hence, journey has re-started. Please proceed with lead number: '+currentCase.Loan_Application__r.Name+'C');
                                        }
                                    }
                                } 
                            }
                            if(!String.isBlank(rejectedDocument.Rejection_Fields__c)) {
                                List<String> rejectedFields = rejectedDocument.Rejection_Fields__c.split(';');
                                String rejectionReason = rejectedDocument.CMU_Rejection_Reason__c!=null ? rejectedDocument.CMU_Rejection_Reason__c : '';
                                if(rejectedFields.contains('Customer name/KYC value not matched with existing code - dedupe')){
                                    if(!restartReasonList.contains('CMU has rejected lead number '+currentCase.Loan_Application__r.Name+'for the reason '+ rejectionReason +' ; hence, journey has re-started. Please proceed with lead number: '+currentCase.Loan_Application__r.Name+'C')){
                                        restartReasonList.add('CMU has rejected lead number '+currentCase.Loan_Application__r.Name+'for the reason '+ rejectionReason +' ; hence, journey has re-started. Please proceed with lead number: '+currentCase.Loan_Application__r.Name+'C');
                                    }
                                }
                            }
                            if(currentCase.Loan_Application__r.Product_Type__c == 'Tractor' && !String.isBlank(rejectedDocument.CMU_Rejection_Reason__c)){
                                for(String str : niRejectionReasons){
                                    if(rejectedDocument.CMU_Rejection_Reason__c.contains(str)){
                                        restartReson = 'CMU has rejected lead number '+currentCase.Loan_Application__r.Name+'for the reason '+ rejectedDocument.CMU_Rejection_Reason__c +' ; hence, journey has re-started. Please proceed with lead number: '+currentCase.Loan_Application__r.Name+'C';  
                                        break;
                                    }
                                }
                            }
                        }
                    }else{
                        for(Documents__c rejectedDocument : mapOfRejectedDocuments.values()){
                            Boolean isNonCritical = false;
                            if(String.isNotBlank(rejectedDocument.Rejection_Fields__c)){
                                for(String str : nonCriticalRejectionFieldsList){
                                    if(rejectedDocument.Rejection_Fields__c.contains(str)){
                                        isNonCritical = true;
                                        break;
                                    }
                                }
                            }
                            if(isNonCritical){
                                continue;
                            }
                            //2.1. Incorrect Fields for POI/PAN/POA document
                            ApplicantId = rejectedDocument.Applicant__c;
                            applicantTypeData = rejectedDocument.Applicant__r.Applicant_Type__c;
                            //CISP-3116-START
                            if(rejectedDocument.Document_Type__c == System.Label.AadhaarCard && rejectedDocument.Aadhar_Source__c == System.Label.Biometric && rejectedDocument.CMU_Rejection_Reason__c != null){
                                restartReson = 'CMU has selected '+rejectedDocument.CMU_Rejection_Reason__c+' as a Rejection Reason for e-KYC document';
                                break;
                            }
                            //CISP-3116-END
                            if(!String.isBlank(rejectedDocument.CMU_Rejection_Reason__c) && rejectedDocument.Document_Type__c == System.Label.PanCards){
                                if(rejectedDocument.CMU_Rejection_Reason__c == 'Name of the applicant / customer does not match as per NSDL records'){
                                    restartReson = 'CMU has selected '+rejectedDocument.CMU_Rejection_Reason__c+' as a Rejection Reason for Pan Document';
                                    break;
                                }
                            }    
                            if(rejectedDocument.CMU_Rejection_Reason__c == 'Incorrect fields' && !String.isBlank(rejectedDocument.Rejection_Fields__c) && (rejectedDocument.Proof_of_Identity_POI__c || rejectedDocument.Document_Type__c == System.Label.PanCards || rejectedDocument.Proof_of_Address_POA__c)){
                                List<String> criticalFields = getMetadata(rejectedDocument.Document_Type__c).trim().split(';');
                                List<String> rejectedFields = rejectedDocument.Rejection_Fields__c.split(';');
                                Boolean criticalMatchFound = false;
    
                                for(String rejectField : rejectedFields){
                                    for(String crField : criticalFields){
                                        if(crField == rejectField){
                                            criticalMatchFound = true;
                                            break;
                                        }
                                    }
                                } 
    
                                if(criticalMatchFound){
                                    restartReson = 'CMU has selected '+rejectedDocument.CMU_Rejection_Reason__c+' as a Rejection Reason for POA/POI/PAN document';
                                    break;
                                }
                                //2.2. Incorrect POI/PAN/POA Documents 
                            } else if(rejectedDocument.CMU_Rejection_Reason__c == 'Incorrect document' && (rejectedDocument.Proof_of_Identity_POI__c || rejectedDocument.Document_Type__c == System.Label.PanCards || rejectedDocument.Proof_of_Address_POA__c)){
                                restartReson = 'CMU has selected '+rejectedDocument.CMU_Rejection_Reason__c+' as a Rejection Reason for POA/POI/PAN document';
                                Break;
                            }
                            if(!String.isBlank(rejectedDocument.Rejection_Fields__c) && rejectedDocument.Proof_of_Identity_POI__c) {
                                List<String> rejectedFields = rejectedDocument.Rejection_Fields__c.split(';');
                                for(String rejectField : rejectedFields){
                                        if('Gender' == rejectField){
                                            restartReson='CMU has rejected the gender of the applicant on '+rejectedDocument.Name+'; hence, journey has re-started. Please proceed with lead number: '+currentCase.Loan_Application__r.Name+'C';
                                            break;
                                        }
                                } 
                            }
                            if(!String.isBlank(rejectedDocument.Rejection_Fields__c)) {
                                List<String> rejectedFields = rejectedDocument.Rejection_Fields__c.split(';');
                                String rejectionReason = rejectedDocument.CMU_Rejection_Reason__c!=null ? rejectedDocument.CMU_Rejection_Reason__c : '';
                                if(rejectedFields.contains('Customer name/KYC value not matched with existing code - dedupe')){
                                    restartReson = 'CMU has rejected lead number '+currentCase.Loan_Application__r.Name+'for the reason '+ rejectionReason +' ; hence, journey has re-started. Please proceed with lead number: '+currentCase.Loan_Application__r.Name+'C';
                                    break;
                                }
                            }
                            if(currentCase.Loan_Application__r.Product_Type__c == 'Tractor' && !String.isBlank(rejectedDocument.CMU_Rejection_Reason__c)){
                                for(String str : niRejectionReasons){
                                    if(rejectedDocument.CMU_Rejection_Reason__c.contains(str)){
                                        restartReson = 'CMU has rejected lead number '+currentCase.Loan_Application__r.Name+'for the reason '+ rejectedDocument.CMU_Rejection_Reason__c +' ; hence, journey has re-started. Please proceed with lead number: '+currentCase.Loan_Application__r.Name+'C';  
                                        break;
                                    }
                                }
                            }
                        }
                    }

                    if(restartReasonList.size() > 0){
                        restartReson = String.join(restartReasonList, ',');
                    }

                    if(restartReson != ''){
                        if(currentCase.Loan_Application__r.LeadSource != 'OLA'&& currentCase.Loan_Application__r.LeadSource != 'Hero'){//CISH-62
                            //CISP-3447 start
                            if(applicantTypeData == 'Borrower' && caseOwnerProfileName == 'CMU' && currentCase.Loan_Application__r.Product_Type__c != Label.Tractor){

                                String response = JourneyRestartHandler.JourneyRestart(currentCase.Loan_Application__c,ApplicantId,'CMU_Reject_Borrower',restartReson );
                                returnWrapperElement = (ReturnMessageWrapper) JSON.deserialize(response,ReturnMessageWrapper.class);

                            }else if(applicantTypeData == 'Co-borrower' && caseOwnerProfileName == 'CMU' && currentCase.Loan_Application__r.Product_Type__c != Label.Tractor){

                                String response = JourneyRestartHandler.JourneyRestart(currentCase.Loan_Application__c,ApplicantId,'CMU_reject_Co_Borrower',restartReson );
                                returnWrapperElement = (ReturnMessageWrapper) JSON.deserialize(response,ReturnMessageWrapper.class);

                            } //CISP-3447 end
                            //String response = HandleJourney_Utility.handleCMUJourneyRestart(ApplicantId,restartReson );
                            //returnWrapperElement = (ReturnMessageWrapper) JSON.deserialize(response,ReturnMessageWrapper.class);
                            else if(caseOwnerProfileName == 'CMU' && applicantIds.size() > 0 && currentCase.Loan_Application__r.Product_Type__c == 'Tractor') {
                                String response = JourneyRestartHandler.JourneyRestart(currentCase.Loan_Application__c, String.join(applicantIds, '-'), journeyRestartTypeTF, restartReson );
                                returnWrapperElement = (ReturnMessageWrapper) JSON.deserialize(response,ReturnMessageWrapper.class);
                            }
                        } else {
                            Opportunity oppRec = new Opportunity(id=currentCase.Loan_Application__c, StageName = 'Rejected', IsRejected__c=true);
                            if (Schema.sObjectType.Opportunity.isUpdateable()){
                                update oppRec;
                                currentCase.Description = 'Application has been rejected. Initiate the offline process';//OLA-112
                                returnWrapperElement.isSuccess = true;
                            }
                            Id fIRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FI').getRecordTypeId();//OLA-177
                            String loanId = currentCase.Loan_Application__c;
                            List<Case> fiCaseList = [SELECT Id,OwnerId,Status FROM Case WHERE Loan_Application__r.Id=:loanId AND RecordTypeId=:fIRecTypeId AND Owner.IsActive=true];
                            if(!fiCaseList.isEmpty()){
                                for(Case cs:fiCaseList){
                                    cs.Status = 'Closed'; 
                                }
                                update fiCaseList;
                            }//OLA-177
                        }
                        if(!returnWrapperElement.isSuccess){
                            return System.JSON.serialize(returnWrapperElement);
                        } else {
                            returnWrapperElement.isSuccess = true;
                            returnWrapperElement.reason = restartReson;
                            currentCase.Status = 'Closed';
                        }
                    } else {
                        //CISP-13593 
                        List<Documents__c> docListForUpdate = new List<Documents__c>();
                        for(Documents__c document : currentCase.Documents__r){
                            system.debug('document---' + document);
                            if(document.CMU_Accept_Reject__c == 'Reject' && document.Document_Type__c == 'PAN'){
                                document.AadhaarSeedingStatus__c = null;
                                docListForUpdate.add(document);
                            }
                        }
                        if(!docListForUpdate.isEmpty()){
                            update docListForUpdate;
                        }  //CISP-13593 end  
                        currentCase.Status = 'Pending with Sales';
                        Id fIRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FI').getRecordTypeId();
                        String loanId = currentCase.Loan_Application__r.Id;
                        List<Case> fiCaseList = [SELECT Id,OwnerId FROM Case WHERE Loan_Application__r.Id=:loanId AND RecordTypeId=:fIRecTypeId AND Owner.IsActive=true AND Status='FI Assigned' LIMIT 1];
                        String uniqueFiCaseOwnerId;
                        if(fiCaseList.size() > 0){
                            uniqueFiCaseOwnerId = fiCaseList[0].OwnerId;
                        }
                        List<CaseTeamMember> caseTeamMemberList = new List<CaseTeamMember>();
                        Boolean fiOwnerPresentinCT = false;
                        Boolean laOwnerPresentinCT = false;
                        List<CaseTeamMember> existingCaseTeamMemberList = [SELECT Id,MemberId FROM CaseTeamMember WHERE ParentId =: currentCase.Id AND Member.IsActive=TRUE];
                        if(existingCaseTeamMemberList.size() > 0){
                            for (CaseTeamMember ctmObj : existingCaseTeamMemberList) {
                                if(uniqueFiCaseOwnerId == ctmObj.MemberId){
                                    fiOwnerPresentinCT = true;
                                    currentCase.CMU_CaseTeamMember_FI_User__c = uniqueFiCaseOwnerId;
                                }
                                if(currentCase.Loan_Application__r.OwnerId == ctmObj.MemberId){
                                    laOwnerPresentinCT = true;
                                    currentCase.CMU_CaseTeamMember_Loanapp_Owner__c = currentCase.Loan_Application__r.OwnerId;
                                }
                            }
                        }
                        List<CaseTeamRole> ctrole = [SELECT Id,Name FROM CaseTeamRole WHERE Name = 'caseaccess' LIMIT 1];
						
						 if(ctrole.size() > 0){
                            if(String.isNotBlank(uniqueFiCaseOwnerId) && !fiOwnerPresentinCT){
                                CaseTeamMember ctm = new CaseTeamMember();
                                ctm.ParentId = currentCase.Id;
                                ctm.MemberId = uniqueFiCaseOwnerId;
                                ctm.TeamRoleId = ctrole[0].Id;
                                caseTeamMemberList.add(ctm);
                            }
                            if(currentCase.Loan_Application__r.Owner.IsActive && !laOwnerPresentinCT){
                            if(currentCase.Loan_Application__r.OwnerId != uniqueFiCaseOwnerId){
                                CaseTeamMember ctm1 = new CaseTeamMember();
                                ctm1.ParentId = currentCase.Id;
                                ctm1.MemberId = currentCase.Loan_Application__r.OwnerId;
                                ctm1.TeamRoleId = ctrole[0].Id;
                                caseTeamMemberList.add(ctm1);
                            }
                            }
                        }
                         
                        if(caseTeamMemberList.size() > 0){
                            insert caseTeamMemberList;
                        }else{
                            caseTeamMemberNotPresent = true;
                        }

                        Set<String> sSalesStages = new Set<String>{'Additional Details', 'Asset Details', 'Vehicle Valuation', 'Loan Details', 'Income Details', 'Final Terms', ' Offer Screen', 'Customer Code Addition', 'Insurance Details', 'Final Offer'};
                        Set<String> sSalesProfiles = new Set<String>{'IBL Partner Community CVO','IBL Partner Community Marketing Agent', 'IBL Partner Community Marketing Officer', 'IBL Partner Community Counter Staff', 'IBL Marketing Officer', 'IBL Business Executive', 'IBL Product Executive', 'IBL Business Executive TW','IBL TF Business Executive', 'IBL Partner Community TF Business Executive'};//CISP-3304
                        List<OpportunityHistory> oppHistoryList = [select id, CreatedById from OpportunityHistory where OpportunityId =: currentCase.Loan_Application__c AND StageName in :sSalesStages AND CreatedBy.Profile.Name in :sSalesProfiles AND CreatedBy.IsActive=true order by CreatedDate desc limit 1];//CISP-2838 Removed WITH SECURITY_ENFORCED 
                        String ownerId; 
                        if(oppHistoryList.isEmpty()){
                            if(caseTeamMemberNotPresent){
                                throw new IND_Exception('Sales, FI, CVO users of this loan application are inactive, hence this case cannot be assigned to them'); 
                            }
                        }else{
                            ownerId = oppHistoryList[0].CreatedById;
                        }
                        if(String.isNotBlank(ownerId)){
                            Boolean bEmAuserPresentinCT = false;
                            for (CaseTeamMember ctmObj : caseTeamMemberList) {
                                if(ownerId == ctmObj.MemberId){
                                    bEmAuserPresentinCT = true;
                                }
                            }
                            if(!bEmAuserPresentinCT){
                                for (CaseTeamMember ctmObj : existingCaseTeamMemberList) {
                                    if(ownerId == ctmObj.MemberId){
                                        bEmAuserPresentinCT = true;
                                    }
                                } 
                            }
                            if(!bEmAuserPresentinCT){
                                CaseTeamMember ctm2 = new CaseTeamMember();
                                ctm2.ParentId = currentCase.Id;
                                ctm2.MemberId = ownerId;
                                ctm2.TeamRoleId = ctrole[0].Id;
                                insert ctm2;
                            }
                            currentCase.OwnerId = ownerId;
                        }else{
                            currentCase.OwnerId = caseTeamMemberList[0].MemberId;
                        }
                        currentCase.Accept_Case__c = false;
                        currentCase.CMU_Case_Accepted_By__c = null;
						currentCase.CMU_Rejected__c = true;
                        if(caseTeamMemberList.size() > 0){
                            currentCase.CMU_CaseTeamMember_FI_User__c = caseTeamMemberList[0].MemberId;
                        }
                        if(caseTeamMemberList.size() > 1){
                            currentCase.CMU_CaseTeamMember_Loanapp_Owner__c = caseTeamMemberList[1].MemberId;
                        }
                    }
                    
                    if (Schema.sObjectType.Case.isUpdateable()) {
                        Database.DMLOptions options = new Database.DMLOptions();
                        options.EmailHeader.triggerUserEmail = true;
                        Case[] caseArray = new List<Case>{currentCase};
                        Database.SaveResult[] srList = Database.update(caseArray, options);
                        
                        for (Database.SaveResult sr : srList) {
                            if (sr.isSuccess()) {
                                System.debug('EmailHeader Save:: '+sr.getId());
                            } else{
                                for(Database.Error err : sr.getErrors()) {
                                    System.debug('EmailHeader Error:: '+err.getMessage()); 
                                    System.debug('EmailHeader Fields error: ' +err.getFields());
                                }
                            }
                        }
                    }

                    if(restartReson == ''){
                        returnWrapperElement.isSuccess = true;
                        returnWrapperElement.message = 'CMU Request is assigned to Sales User';
                    }

                    return System.JSON.serialize(returnWrapperElement);
                } else {
                    //3. Sales User Submit Action - Status Update.
                    String errormsg = '';
                    Boolean panErrorMsg = false;
                    for(Documents__c document : currentCase.Documents__r){
                        if(document.CMU_Accept_Reject__c == 'Reject'){
                            if(document.Document_Type__c == system.Label.AadhaarCard || document.Document_Type__c == system.Label.PassportCard || document.Document_Type__c == system.Label.VoterIdCard || document.Document_Type__c == system.Label.DrivingLicences ){
                                if(document.isFrontDocReplaced__c == false){
                                    errormsg = errormsg + document.Name + ' Front ,' ;
                                }
                                if(document.isBackDocReplaced__c == false){
                                    errormsg = errormsg + document.Name + ' Back ,' ;
                                }
                            }else{
                                if(document.isFrontDocReplaced__c == false){
                                    errormsg = errormsg + document.Name + ', ' ;
                                }
                            }
                            if(document.Document_Type__c == 'PAN' && document.AadhaarSeedingStatus__c != 'Y'){
                                if(oppListUpdatePriority.size() > 0 && oppListUpdatePriority[0].Product_Type__c == System.label.Tractor && oppListUpdatePriority[0].Customer_Type__c == 'Non-Individual' && oppListUpdatePriority[0].Entity_Type__c != 'Proprietorship' && document.Applicant__r.Applicant_Type__c == System.Label.Borrower){
                                    break;
                                }else{
                                    panErrorMsg = true;
                                }
                            }

                        }
                    }
                    if(errormsg.length()>0){
                        errorMsg = errorMsg.substring(0,errorMsg.length()-1);
                        errorMsg = 'Please re-upload the following documents before submit the case : ' + errormsg + '.';
                        System.debug('errorMsg--' + errorMsg);
                        returnWrapperElement.isSuccess = true;
                        returnWrapperElement.message = errormsg;
                        return System.JSON.serialize(returnWrapperElement);
                    }
                    if(panErrorMsg){
                        returnWrapperElement.isSuccess = true;
                        returnWrapperElement.message = 'PAN is not linked to Aadhaar. Please reupload the Pan document and click on Golden Source.';//CISP-22946
                        return System.JSON.serialize(returnWrapperElement);
                    }
                    System.debug('Related Opportunity Id:: '+currentCase.Loan_Application__c);
                    // List<OpportunityTeamMember> oppTeamMember = [SELECT Id, userId FROM OpportunityTeamMember WHERE OpportunityId =:currentCase.Loan_Application__c AND TeamMemberRole = 'CMU'];
                    String queueId = [select Id from Group where Name = :System.Label.CMU and Type = :System.Label.Queue LIMIT 1].Id ;
                    if(currentCase.Status == 'Pending with Sales' && currentCase.CMU_Case_Accepted_By__c == UserInfo.getUserId() && currentCase.Accept_Case__c == true){
                        if(String.isNotBlank(queueId)){
                        currentCase.OwnerId = queueId;
                        currentCase.Status = 'Pending with CMU';
                        currentCase.CMU_Case_Accepted_By__c = null;
						currentCase.CMU_Rejected__c = false;
						currentCase.Accept_Case__c = false;
						currentCase.CMU_CaseTeamMember_FI_User__c = null;
						currentCase.CMU_CaseTeamMember_Loanapp_Owner__c = null;
                        currentCase.CMU_Case_Submitted_By__c=UserInfo.getName();

                        List<Documents__c> docListForUpdate = new List<Documents__c>();
                        for(Documents__c document : currentCase.Documents__r){
                            system.debug('document---' + document);
                            if(document.CMU_Accept_Reject__c == 'Reject'){
                                document.isFrontDocReplaced__c = false;
                                document.isBackDocReplaced__c = false;
                                docListForUpdate.add(document);
                            }
                        }
                        if(!docListForUpdate.isEmpty()){
                            update docListForUpdate;
                        }
                        if (Schema.sObjectType.Case.isUpdateable()) {
                            Database.DMLOptions options = new Database.DMLOptions();
                            options.EmailHeader.triggerUserEmail = true;
                            database.update(currentCase, options); 
                            List<Retry_Count__c> retryCountList = new List<Retry_Count__c>();
                            retryCountList = [SELECT Id, Count__c FROM Retry_Count__c WHERE Loan_Application_Id__c = :currentCase.Loan_Application__c AND (Service_Name__c =: System.Label.CMU_Front OR Service_Name__c =: System.Label.CMU_Back)];
                            if(retryCountList.size()>0){
                                CaseWithoutSharingUpdate.deleteOCRRetryCounts(retryCountList);
                            }
                        }

                        returnWrapperElement.isSuccess = true;
                        returnWrapperElement.message = 'CMU Request is assigned to CMU User';
                        return System.JSON.serialize(returnWrapperElement);
                    } else {
                        throw new IND_Exception('No CMU User Found'); 
                    }
                    }else if(currentCase.Status == 'Pending with Sales' && currentCase.CMU_Case_Accepted_By__c != UserInfo.getUserId() && currentCase.Accept_Case__c == true){
                throw new IND_Exception('This CMU case was already accepted by other User '+ currentCase.CMU_Case_Accepted_By__r.Name+ ', you donot have permission to submit this case');
                }else if(currentCase.Status == 'Pending with Sales' && currentCase.CMU_Case_Accepted_By__c == null && currentCase.Accept_Case__c == false){
                throw new IND_Exception('Please accept case first');
                }else{
                throw new IND_Exception('You do not have permission to perform this action.');
                }
                }
            } else {
                throw new IND_Exception(System.label.ExceptionMessage); 
            } 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

     //This method is use to return metadata according to Document type.   
     public static string getMetadata(String documentType)
     {
         //check doc type and return medata data according to it.
         if(documentType == system.Label.AadhaarCard)//'Aadhaar')
         {
             Golden_Source_Input_Output_Fields__mdt metadata =Golden_Source_Input_Output_Fields__mdt.getInstance('Aadhaar');//'Aadhaar');
             return metadata.Output_Fields__c+';'+metadata.Input_Fields__c;
         }
         //check doc type and return medata data according to it.
         else if(documentType == system.Label.DrivingLicences) //'Driving Licence')
         {
             Golden_Source_Input_Output_Fields__mdt metadata =Golden_Source_Input_Output_Fields__mdt.getInstance('Driving_Licence');//'Driving_Licence');
             return metadata.Output_Fields__c+';'+metadata.Input_Fields__c;
         }
         //check doc type and return medata data according to it.
         else if(documentType == system.Label.VoterIdCard) //'Voter Id')
         {
             Golden_Source_Input_Output_Fields__mdt metadata =Golden_Source_Input_Output_Fields__mdt.getInstance('Voter_ID'); //'Voter_ID');
             return metadata.Output_Fields__c+';'+metadata.Input_Fields__c;
         }
         //check doc type and return medata data according to it.
         else if(documentType == system.Label.PassportCard) //'Passport')
         {
             Golden_Source_Input_Output_Fields__mdt metadata =Golden_Source_Input_Output_Fields__mdt.getInstance('Passport'); //'Passport');
             return metadata.Output_Fields__c+';'+metadata.Input_Fields__c;
         }
         //check doc type and return medata data according to it.
         else if(documentType == system.Label.PanCard) //'PAN')
         {
             Golden_Source_Input_Output_Fields__mdt metadata =Golden_Source_Input_Output_Fields__mdt.getInstance('PAN'); //'PAN');
             return metadata.Output_Fields__c+';'+metadata.Input_Fields__c;
         }else{
            return null;
         }
     }

    public Class ReturnMessageWrapper{
        @AuraEnabled public Boolean isSuccess {get;set;}
        @AuraEnabled public String message {get;set;}
        @AuraEnabled public String reason {get;set;}
    }
    
}