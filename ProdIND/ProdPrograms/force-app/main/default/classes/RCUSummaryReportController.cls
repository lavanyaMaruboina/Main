/**
* @Name         RCUSummaryReportController
* @Author       Shivswaroop Chougule
* @Company      Salesforce
* @Description  This class will generate RCU Summary report data.
* Inputs:       None
* Test Class:   RCUSummaryReportController_Test
*/
public with sharing class RCUSummaryReportController {
    public static set<id> documentIds = new set<Id>();
    public string recordId{get;set;}
    public RCUSummaryWrapper data{get;set;}
    public RCUSummaryReportController(){
        recordId = System.currentPageReference().getParameters().get('Id');
        if(recordId!=null && recordId!=''){
            data = getRCUSummary(recordId);
        }
    }
    /**
    * @Method       getPDFprint
    * @Company      Salesforce
    * @Description  This method will make call to VF page to generate PDF format to download/print.
    * @Param:       json  = RCU case Id (rcuCaseId)/JSON
    * @Return:   	List<string> - page URL and page blob content
    */
    @AuraEnabled
    public static list<string> getPDFprint(string json){
        list<string> pageString = new List<String>();
        PageReference pdfPage = new PageReference('/apex/generatePDF?Id='+json);
        Blob pdfBlob = !Test.isRunningTest() ? pdfPage.getContent(): Blob.valueOf('Fake content');
        String downloadURL = EncodingUtil.base64Encode(pdfBlob);
        pageString.add(downloadURL);
        pageString.add(pdfPage.getUrl());
        return pageString;
        
    }
    /**
    * @Method       getRCUSummary
    * @Author       Shivswaroop Chougule
    * @Company      Salesforce
    * @Description  This method will generate RCU Summary report data and return to LWC component.
    * @Param:       RCU case Id (rcuCaseId)
    * @Return:   	RCUSummaryWrapper - Object
    */
    @AuraEnabled(cacheable=true)
    public static RCUSummaryWrapper getRCUSummary(string rcuCaseId){
        System.debug('rcuCaseId '+rcuCaseId);
        Case rcuSummaryObj = [SELECT ID,Applicant__c,Origin,Case_Owner_Custom__c,Applicant__r.Name,Loan_Application_No__c,Loan_Application__r.Applicant_Name__c,Loan_Application__r.Loan_amount__c,Loan_Application__r.Product_Type__c,Loan_Application__c,Loan_Application__r.Address__c,Overall_RCU_Agency_Sampling_Reason__c,
                              Loan_Application__r.CreatedBy.Name, Loan_Application__r.Type,Overall_RCU_Agency_Verification_Remarks__c,Overall_RCU_Agency_Verification_Status__c,Overall_RCU_Verification_Remarks__c,Overall_RCU_Verification_Status__c, RCU_Agent__c, RCU_Agent__r.Name, RCU_Agent__r.Contact.Account.Name,
                              (SELECT Id,Name,Opportunity_Relation__c,RCU_Agency_Verification_Status__c, RCU_Agency_Verification_Sub_Status__c, RCU_Document_Remarks__c
                              FROM Documents__r),CreatedDate
                              FROM case
                              WHERE Id=:rcuCaseId ];
        
        //SFTRAC-1451
        List<CaseHistory> caseHistList = [SELECT Id, CaseId, Field, CreatedDate, DataType, OldValue, NewValue FROM CaseHistory Where CaseId =: rcuCaseId];
        system.debug('++++caseHistList '+caseHistList);
                              
        Opportunity loanApplication = new Opportunity();
        loanApplication = getLoanApplicationRelatedData(rcuSummaryObj.Loan_Application__c);
        RCUSummaryWrapper rcuSummary = new RCUSummaryWrapper();
        rcuSummary.loanApplicationId = rcuSummaryObj.Loan_Application__c != null ? rcuSummaryObj.Loan_Application__c :'N/A' ;
        rcuSummary.Applicant_Name = rcuSummaryObj.Loan_Application__r.Applicant_Name__c!=null ? rcuSummaryObj.Loan_Application__r.Applicant_Name__c : 'N/A';
        rcuSummary.Deal_Number = rcuSummaryObj.Loan_Application_No__c!=null ? rcuSummaryObj.Loan_Application_No__c : 'N/A' ;
        rcuSummary.Loan_Amount = rcuSummaryObj.Loan_Application__r.Loan_amount__c!=null ? rcuSummaryObj.Loan_Application__r.Loan_amount__c : 'N/A';
        rcuSummary.Product = rcuSummaryObj.Loan_Application__r.Product_Type__c!=null ? rcuSummaryObj.Loan_Application__r.Product_Type__c : 'N/A';
        rcuSummary.Address = rcuSummaryObj.Loan_Application__r.Address__c !=null ? rcuSummaryObj.Loan_Application__r.Address__c : 'N/A';
        rcuSummary.Loan_Type = rcuSummaryObj.Loan_Application__r.Type !=null ? rcuSummaryObj.Loan_Application__r.Type : 'N/A';
        //rcuSummary.Sampled_Date =rcuSummaryObj.CreatedDate!=null ? String.valueOf(rcuSummaryObj.CreatedDate.Date()) : 'N/A';
        rcuSummary.Reported_Date = String.valueOf(System.today());
        //rcuSummary.Sourcing_Staff_name = rcuSummaryObj.Case_Owner_Custom__c;
        rcuSummary.Sourcing_Staff_name = rcuSummaryObj.Loan_Application__r.CreatedBy.Name; //SFTRAC-1451
        rcuSummary.Sourced_By = rcuSummaryObj.Origin;
        rcuSummary.SamplerName = rcuSummaryObj.RCU_Agent__c!=null ? rcuSummaryObj.RCU_Agent__r.Contact.Account.Name : 'N/A'; //SFTRAC-1451
        rcuSummary.rcuAgencyName = rcuSummaryObj.RCU_Agent__c!=null ? rcuSummaryObj.RCU_Agent__r.Name : 'N/A'; //SFTRAC-1451
        if(rcuSummaryObj.Applicant__c!=null && getIncomeDetails(rcuSummaryObj.Applicant__c )!=null && getIncomeDetails(rcuSummaryObj.Applicant__c).Employer_Business_Name__c!=null)
        	rcuSummary.Branch_Location = getIncomeDetails(rcuSummaryObj.Applicant__c).Employer_Business_Name__c;
        else
            rcuSummary.Branch_Location = 'N/A';
        rcuSummary.vehicleDetails = loanApplication.Vehicle_Details__r;
        rcuSummary.Applicants = loanApplication.Applicants__r;
        rcuSummary.documents = !getRelatedDocs(rcuSummaryObj.Id).isEmpty() ? getRelatedDocs(rcuSummaryObj.Id) : new list<Documents__c>();
        rcuSummary.files = !getDocumentsFile().isEmpty() ? getDocumentsFile() : new list<FileWrapper>();
        rcuSummary.overall_RCU_Agency_Verification_Remarks = rcuSummaryObj.Overall_RCU_Agency_Verification_Remarks__c!=null ? rcuSummaryObj.Overall_RCU_Agency_Verification_Remarks__c : 'N/A';
        rcuSummary.overall_RCU_Agency_Verification_Status  = rcuSummaryObj.Overall_RCU_Agency_Verification_Status__c!=null ? rcuSummaryObj.Overall_RCU_Agency_Verification_Status__c : 'N/A';
        rcuSummary.overall_RCU_Verification_Status = rcuSummaryObj.Overall_RCU_Verification_Status__c!=null ? rcuSummaryObj.Overall_RCU_Verification_Status__c : 'N/A';
        rcuSummary.overall_RCU_Verification_Remarks = rcuSummaryObj.Overall_RCU_Verification_Remarks__c !=null ? rcuSummaryObj.Overall_RCU_Verification_Remarks__c : 'N/A';
        rcuSummary.overall_RCU_Agency_Sampling_Reason = rcuSummaryObj.Overall_RCU_Agency_Sampling_Reason__c!=null ? rcuSummaryObj.Overall_RCU_Agency_Sampling_Reason__c : 'N/A';//SFTRAC-1451
        //SFTRAC-1451 Starts
        for(CaseHistory caeHistRec: caseHistList){
            if(caeHistRec.NewValue == 'Assigned to RCU Agency' && rcuSummary.Sampled_Date == null){
                system.debug('++++IN '+caeHistRec.NewValue);
                rcuSummary.Sampled_Date =caeHistRec.CreatedDate!=null ? String.valueOf(caeHistRec.CreatedDate.Date()) : 'N/A';
            }
        }//SFTRAC-1451 ENds

        System.debug('JSON String==> '+JSON.serialize(rcuSummary));
        return rcuSummary;//JSON.serialize(rcuSummary);
    }
    /**
    * @Method       getLoanApplicationRelatedData
    * @Company      Salesforce
    * @Description  This method will return Loan Application(opportunity) associated with case.
    * @Param:       Loan Application Id(loadApplicationId)
    * @Return:   	opportunity - Object
    */
    public static opportunity getLoanApplicationRelatedData(string loadApplicationId){
        Opportunity loanApplication = [SELECT Id,(SELECT Id,Make__c,Model__c FROM Vehicle_Details__r),(SELECT Id,Name FROM Applicants__r where Applicant_Type__c='Co-borrower')
                                       FROM Opportunity
                                       WHERE Id=:loadApplicationId];
        return loanApplication;
    }
    /**
    * @Method       getLoanApplicationRelatedData
    * @Company      Salesforce
    * @Description  This method will return Income_Details associated with case.
    * @Param:       Applicant Id(applicantId)
    * @Return:   	Income_Details__c - Object
    */
    public static Income_Details__c getIncomeDetails(string applicantId){
        Income_Details__c incomeDetails = new Income_Details__c();
        incomeDetails =[SELECT Id,Employer_Business_Name__c 
                		FROM Income_Details__c 
                		WHERE Applicant__c=: applicantId limit 1];
        return incomeDetails;
    }
    /**
    * @Method       getLoanApplicationRelatedData
    * @Company      Salesforce
    * @Description  This method will return related document information.
    * @Param:       RCU Case Id (caseId)
    * @Return:   	list<Documents__c>
    */
    public static list<Documents__c> getRelatedDocs(string caseId){
        String resiRecordTypeId = Schema.sObjectType.Documents__c.getRecordTypeInfosByName().get('Resi Profile Documents').getRecordTypeId();
        list<Documents__c> documents = [SELECT Id,Name,Opportunity_Relation__c,RCU_Agency_Verification_Status__c, RCU_Agency_Verification_Sub_Status__c ,RCU_Document_Remarks__c,Document_Type__c,Is_Active__c,RecordTypeId,Applicant__r.Name
         FROM Documents__c where RCU_Case__c=:caseId OR RCU_Case__r.ParentId=:caseId LIMIT 1000];
        for(Documents__c document:documents){
            if(document.Document_Type__c == 'Resi Profile Document' && document.Is_Active__c == true && document.RecordTypeId == resiRecordTypeId){
                documentIds.add(document.Id);
            }
        }
        return documents;
    }
    /**
    * @Method       getLoanApplicationRelatedData
    * @Company      Salesforce
    * @Description  This method will return related documents uploaded for case.
    * @Param:       None
    * @Return:   	list<FileWrapper>
    */
    public static list<FileWrapper> getDocumentsFile(){
        list<FileWrapper> files = new list<FileWrapper>();
        if(!documentIds.isEmpty()){
        	for(ContentDocumentLink contentVersion :[SELECT Id,ContentDocumentId,ContentDocument.FileExtension,ContentDocument.LatestPublishedVersion.VersionData,ContentDocument.Title 
                                           			 FROM ContentDocumentLink 
                                                     WHERE LinkedEntityId IN : documentIds]){
                    FileWrapper fileObj = new FileWrapper();
                    fileObj.fileData =EncodingUtil.base64Encode(contentVersion.ContentDocument.LatestPublishedVersion.VersionData);
                    files.add(fileObj);
            }
        }
        return files.isEmpty() ? new list<FileWrapper>():files;
    }
     
    public class RCUSummaryWrapper{
        @AuraEnabled
        public string loanApplicationId{get;set;}//
        @AuraEnabled
        public string Applicant_Name{get;set;} // 
        @AuraEnabled
        public string Deal_Number{get;set;}  //
        @AuraEnabled
        public string Branch_location{get;set;} //
        @AuraEnabled
        public string Sourced_By{get;set;} 
        @AuraEnabled
        public string SamplerName{get;set;} //SFTRAC-1451
        @AuraEnabled
        public string rcuAgencyName{get;set;} //SFTRAC-1451
        @AuraEnabled
        public string Sourcing_Staff_name{get;set;}
        @AuraEnabled
        public string Loan_Amount{get;set;}
        @AuraEnabled
        public string Product{get;set;} //
        @AuraEnabled
        public string Address{get;set;} //
        @AuraEnabled
        public string Loan_Type{get;set;} //
        @AuraEnabled
        public string Sampled_Date{get;set;} 
        @AuraEnabled
        public string Reported_Date{get;set;} //
        @AuraEnabled
        public list<Vehicle_Detail__c> vehicleDetails{get;set;}//
        @AuraEnabled
        public list<Applicant__c> Applicants{get;set;}//
        @AuraEnabled
        public list<Documents__c> documents{get;set;}//
        @AuraEnabled
        public list<FileWrapper> files{get;set;}//
        @AuraEnabled
        public string overall_RCU_Verification_Status{get;set;}
        @AuraEnabled
        public string overall_RCU_Verification_Remarks{get;set;}
        @AuraEnabled
        public string overall_RCU_Agency_Verification_Status{get;set;}
        @AuraEnabled
        public string overall_RCU_Agency_Verification_Remarks{get;set;}
        @AuraEnabled
        public string overall_RCU_Agency_Sampling_Reason{get;set;}//SFTRAC-1451
    }
    public class FileWrapper{
        @AuraEnabled
        public object fileData{get;set;} 
    }
    @AuraEnabled
    public static List<Documents__c> getAllRCUDocs(string loanApplicationId){
        List<Documents__c> documentList = [SELECT Id,Document_Type__c,Applicant_Type__c,RCU_Agency_Verification_Status__c,RCU_Agency_Verification_Sub_Status__c,RCU_Document_Remarks__c,Applicant__r.Name FROM Documents__c where RCU_Case__c != null AND Opportunity_Relation__c =: loanApplicationId];
        for (Documents__c docObj : documentList) {
            if(docObj.Document_Type__c == Label.AadhaarCard){
                docObj.Document_Type__c = 'Aadhaar';
            }else if(docObj.Document_Type__c == Label.VoterIdCard){
                docObj.Document_Type__c = 'Voter Id';
            }else if(docObj.Document_Type__c == Label.PassportCard){
                docObj.Document_Type__c = 'Passport';
            }else if(docObj.Document_Type__c == Label.DrivingLicences){
                docObj.Document_Type__c = 'Driving License';
            }else if(docObj.Document_Type__c == Label.Telephone_bill){
                docObj.Document_Type__c = 'Telephone bill';
            }
        }
        return documentList;
    }
}