/**
* @Name         IND_OfficeFIReadOnlyController
* @Author       mohammad_shahkomeni
* @Company      Persistent Systems 
* @Description  This class contains all methods related to Office Field Investigation
* Inputs:       None
* Test Class:   IND_OfficeFIReadOnlyController_Test
* History:      
* Date            Author              Comments
* -------------------------------------------------------------
* 02-20-2022      mohammad_shahkomeni Created
* ------------------------------------------------------------
*/
public with sharing class IND_OfficeFIReadOnlyController {
    
    /*
* @Method:      getDocumentsOfFI
* @Created by:  mohammad_shahkomeni
* @Description: This function will get Content Document Ids of Documents and return the response back to LWC
* @Param:       String - Loan Application Id, String - Applicat Id
* @Return:      Map<String, Id> - Map of Document types to Content Document Ids.
*/
    @AuraEnabled(cacheable=true)
    public static Map<String, Id> getDocumentsOfFI(String applicationId, String applicantId) {
        try {
            Map<Id, String> mapDocIDtoTypes = new Map<Id, String>();
            Map<String, Id> mapDocTypetoId = new Map<String, Id>();
            for(Documents__c doc : [SELECT Id,
                                    Document_Type__c
                                    FROM Documents__c
                                    WHERE Opportunity_Relation__c = :applicationId
                                    AND Applicant__c = :applicantId
                                    AND Addresss_Type__c =: System.Label.Document_Office_Address_Type
                                    WITH SECURITY_ENFORCED]) 
            {
                if(doc.Document_Type__c != null){
                    if(doc.Document_Type__c.equalsIgnoreCase(System.Label.Signature)){
                        mapDocIDtoTypes.put(doc.Id, 'signatureView');
                    } 
                    else if(doc.Document_Type__c.equalsIgnoreCase(System.Label.Office_Front_View)){
                        mapDocIDtoTypes.put(doc.Id, 'buildingfrontview');
                    }
                }
                if(mapDocIDtoTypes.size() == 2) {
                    break;
                }
            }
            if(mapDocIDtoTypes.size() > 0) {
                for (ContentDocumentLink docLink : [SELECT LinkedEntityId, 
                                                    ContentDocumentId
                                                    FROM ContentDocumentLink 
                                                    WHERE LinkedEntityId =:mapDocIDtoTypes.keyset()
                                                    WITH SECURITY_ENFORCED]) 
                {
                    mapDocTypetoId.put(mapDocIDtoTypes.get(docLink.LinkedEntityId), docLink.ContentDocumentId);
                }
                if(mapDocTypetoId.size() > 0) {
                    return mapDocTypetoId;
                }
            }
            return null;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_OfficeFIReadOnlyController', 'getDocumentsOfFI', System.Label.Apex, e, applicationId);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /*
* @Method:      saveOfficeFI
* @Created by:  mohammad_shahkomeni
* @Description: This function will accept/reject based on user input and return the response back to LWC
* @Param:       String - json object containing all the details captured on UI
* @Return:      Boolean - true for accepted or false for rejected successfully
*/
    @AuraEnabled
    public static Boolean saveOfficeFI(String inputWrapper) {
        try {
            IND_OfficeFIInputWrapper wrapper = IND_OfficeFIInputWrapper.parse(inputWrapper);
            List<Opportunity> oppList = [Select Id,Product_Type__c from Opportunity Where Id=:wrapper.applicationId.value];
            if(oppList.size() > 0 && oppList[0].Product_type__c == System.Label.Tractor){
                Case cse = new Case(Id = wrapper.caseId.value);
                cse.Status = wrapper.Office_FI_Accepted_Rejected.value;
                cse.RejectedFI__c = cse.Status== 'Accepted'?false:true;//CISP-3137
                CaseWithoutSharingUpdate.updateCase(cse);
                Field_Investigation__c fiRecord = new Field_Investigation__c(Id = wrapper.fiId.value);
                fiRecord.Remarks__c = wrapper.remarks.value;
                CaseWithoutSharingUpdate.updateFi(fiRecord);
                return true;
            }else{
            if((wrapper.Office_FI_Accepted_Rejected.value).equalsIgnoreCase(System.Label.FI_Accepted)) {
                updateOldCaseAndOfficeFI(wrapper);
                generateOfficeFIPDF(wrapper.fiId.value, wrapper.applicantId.value, wrapper.applicationId.value);
                return true;
            }
            else if((wrapper.Office_FI_Accepted_Rejected.value).equalsIgnoreCase(System.Label.FI_Rejected)) {
                updateOldCaseAndOfficeFI(wrapper);
                createNewCaseAndOfficeFI(wrapper);
                generateOfficeFIPDF(wrapper.fiId.value, wrapper.applicantId.value, wrapper.applicationId.value);
                return false;
            }
            else {
                throw new AuraHandledException(System.Label.Office_FI_Accepted_Rejected_Selection_Error_Message);
            }
            }
        }
        catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_OfficeFIReadOnlyController', 'saveOfficeFI', System.Label.Apex, e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /*
* @Method:      updateOldCaseAndOfficeFI
* @Created by:  mohammad_shahkomeni
* @Description: This function updates Old Case and Field Investigation records based on input wrapper
* @Param:       IND_OfficeFIInputWrapper - Office FI Wrapper data
* @Return:      void
*/
    private static void updateOldCaseAndOfficeFI(IND_OfficeFIInputWrapper wrapper){
        try{
       
        Case cse = new Case(Id = wrapper.caseId.value);
        cse.Status = wrapper.Office_FI_Accepted_Rejected.value;
        cse.RejectedFI__c = cse.Status== 'Accepted'?false:true;//CISP-3137
        CaseWithoutSharingUpdate.updateCase(cse);
        
        Field_Investigation__c fiRecord = new Field_Investigation__c(Id = wrapper.fiId.value);
        fiRecord.SENP_Agriculture_Income__c = wrapper.SENP_Agriculture_Income.value;
        fiRecord.SENP_Own_Shop_Income__c = wrapper.SENP_Own_Shop_Income.value;
        fiRecord.SENP_Service_oriented_Income__c = wrapper.SENP_Service_oriented_Income.value;
        fiRecord.SENP_Transporter_Income__c = wrapper.SENP_Transporter_Income.value;
        fiRecord.SENP_Contractor_Income__c = wrapper.SENP_Contractor_Income.value;
        fiRecord.SENP_Rental_Income__c = wrapper.SENP_Rental_Income.value;
        fiRecord.SENP_Pension_Income__c = wrapper.SENP_Pension_Income.value;
        fiRecord.Are_Co_ordinates_Matching_If_Amber__c = wrapper.Are_Co_ordinates_Matching_If_Amber.value;
        fiRecord.Remarks__c = wrapper.remarks.value;
        CaseWithoutSharingUpdate.updateFi(fiRecord);
        }catch(exception e){
            ErrorLoggerUtil.logErrorEvent('IND_OfficeFIReadOnlyController', 'updateOldCaseAndOfficeFI', System.Label.Apex, e);
           // ErrorLoggerUtil.logErrorEvent('IND_OfficeFIReadOnlyController', 'updateOldCaseAndOfficeFI', System.Label.Apex, e,loanApplicationId);

        }
    }
    
    /*
* @Method:      createNewCaseAndOfficeFI
* @Created by:  mohammad_shahkomeni
* @Description: This function creates New Case and Field Investigation records based on input wrapper
* @Param:       IND_OfficeFIInputWrapper - Office FI Wrapper data
* @Return:      void
*/
    private static void createNewCaseAndOfficeFI(IND_OfficeFIInputWrapper wrapper){
        try{

        
        Id fiRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(System.Label.Case_FI_Record_Type_Name).getRecordTypeId();
        Case newCse = new Case();
        newCse.RecordTypeId = fiRecordTypeId;
        newCse.Parent_FI__c = wrapper.caseId.value;
        newCse.OwnerId = wrapper.ownerId.value;
        newCse.Loan_Application__c = wrapper.applicationId.value;
        newCse.Applicant__c = wrapper.applicantId.value;
        newCse.Subject = wrapper.Subject.value;
        newCse.Status = System.Label.Case_FI_Assigned_Status;
        newCse.Origin = wrapper.Origin.value;
        newCse.Type = wrapper.Type.value;
        if (Schema.sObjectType.Case.isCreateable()) {
            INSERT newCse;
        }
        
        Id ofcFIRecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByDeveloperName().get(System.Label.FI_Office_Record_Type_Name).getRecordTypeId();
        Field_Investigation__c newFIRecord = new Field_Investigation__c();
        newFIRecord.Case__c = newCse.Id;
        newFIRecord.RecordTypeId = ofcFIRecordTypeId;
        newFIRecord.Product__c = wrapper.product.value;
        newFIRecord.Address_Line_1__c = wrapper.addrLine1.value;
        newFIRecord.Address_Line_2__c = wrapper.addrLine2.value;
        newFIRecord.City__c = wrapper.city.value;
        newFIRecord.Pin_Code__c = wrapper.pinCode.value;
        newFIRecord.State__c = wrapper.state.value;
        newFIRecord.Landmark__c = wrapper.landmark.value;
        newFIRecord.Phone_Number__c = wrapper.phoneNo.value;
        newFIRecord.Mobile__c = wrapper.mobile.value;
        newFIRecord.Employer_Business_Name__c = wrapper.Employer_Business_Name.value;
        newFIRecord.Current_experience_years__c = wrapper.Current_experience_years.value;
        newFIRecord.Total_Experience_Years__c = wrapper.Total_Experience_Years.value;
        newFIRecord.Income__c = wrapper.Income.value;
        newFIRecord.Estimated_Service_Income_as_per_FI__c = wrapper.Estimated_Service_Income_as_per_FI.value;
        if (Schema.sObjectType.Field_Investigation__c.isCreateable()) {
            INSERT newFIRecord;
        }
        List<OpportunityTeamMember> teamMemberList = new List<OpportunityTeamMember>();
        teamMemberList = [SELECT Id, OpportunityAccessLevel, UserId, TeamMemberRole FROM OpportunityTeamMember WHERE OpportunityId =: wrapper.applicationId.value AND UserId =: wrapper.ownerId.value];
        if(teamMemberList.size() == 0){
            List<OpportunityTeamMember> opptyTeams = new List<OpportunityTeamMember>();
            OpportunityTeamMember oppTeam = new OpportunityTeamMember();
            oppTeam.OpportunityId = wrapper.applicationId.value;
            oppTeam.UserId = wrapper.ownerId.value;
            oppTeam.OpportunityAccessLevel = 'Edit'; 
            opptyTeams.add(oppTeam);  
            CaseWithoutSharingUpdate.insertopptyTeamMembers(opptyTeams);
        }
    }catch(exception e){
        ErrorLoggerUtil.logErrorEvent('IND_OfficeFIReadOnlyController', 'createNewCaseAndOfficeFI', System.Label.Apex, e);
       // ErrorLoggerUtil.logErrorEvent('IND_OfficeFIReadOnlyController', 'updateOldCaseAndOfficeFI', System.Label.Apex, e,loanApplicationId);

    }
    }
    
    /*
* @Method:      generateOfficeFIPDF
* @Created by:  mohammad_shahkomeni
* @Description: This function generates Office FI PDF document
* @Param:       String, String, String
* @Return:      void
*/
    @future (callout=true)
    public static void generateOfficeFIPDF(String fiId, String applicantId, String applicationId){
        try {     
            Pagereference pg = Page.IND_OfficeFIRenderAsPDF;
            pg.getParameters().put('fiId', fiId);
            blob pdfBody;
            if(Test.isRunningTest()) { 
                pdfBody = blob.valueOf('Unit.Test');
            } else {
                pdfBody = pg.getContentAsPDF();
            }
            User usr = [Select Id,Name,IsPortalEnabled from User where Id=:UserInfo.getUserId()];
            Network networkVal = [SELECT Id, Name, Status FROM Network where Name ='IndusDrive' limit 1];
            ContentVersion contentVersion_1 = new ContentVersion();
            contentVersion_1.Title = System.Label.Document_Office_FI_PDF_File_Title;
            contentVersion_1.PathOnClient = System.Label.Document_Office_FI_PDF_File_Path;
            contentVersion_1.VersionData = pdfBody;
            contentVersion_1.origin = 'H';
            if(usr.IsPortalEnabled){
                contentVersion_1.NetworkId = networkVal.Id;
            }
            if (Schema.sObjectType.ContentVersion.isCreateable()) {
                INSERT contentVersion_1;
            }
            
            String otherDocRecTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByDeveloperName().get(System.Label.Document_Other_Documents_Record_Type).getRecordTypeId();
            Documents__c document = new Documents__c( Name = System.Label.Document_Office_FI_PDF_File_Title,
                                                     RecordTypeId = otherDocRecTypeId,
                                                     Applicant__c = applicantId,
                                                     Opportunity_Relation__c = applicationId,
                                                     is_Active__c = true,
                                                     Document_Type__c = System.Label.Document_Office_FI_Type,
                                                     Addresss_Type__c = System.Label.Document_Office_Address_Type );
            if (Schema.sObjectType.Documents__c.isCreateable()) {
                INSERT document;
            }
            
            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                                               FROM ContentVersion
                                               WHERE Id = :contentVersion_1.Id 
                                               WITH SECURITY_ENFORCED 
                                               LIMIT 1];
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = document.id;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            if (Schema.sObjectType.ContentDocumentLink.isCreateable()) {
                INSERT contentlink;
            }
        }
        catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_OfficeFIReadOnlyController', 'generateOfficeFIPDF', System.Label.Apex, e, applicationId);
            throw new AuraHandledException(e.getMessage());
        }
    }
}