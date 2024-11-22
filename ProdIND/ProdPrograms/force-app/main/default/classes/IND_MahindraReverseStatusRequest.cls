/*------------------------------------------------------------
Author: Chaynnitt Agarwal
Company: Salesforce
Description: This class is wrapper class for the Reverse Status Request for Mahindra Reverse Sync API
Test Class: 
Ticket: CISP-21375
*/

public with sharing class IND_MahindraReverseStatusRequest extends ParentAPIRequest {
    
    public String approved_tenure {get;set;}
    public String approved_ROI {get;set;}
    public String approved_loan_amount {get;set;}
    public String processing_fee {get;set;}
    public String approver_comment {get;set;}
    public String applicant_Id {get;set;}
    public String application_status {get;set;}
    public String loan_type_id {get;set;}
    public String application_sub_status {get;set;}
    public String last_updated_timestamp {get;set;}
    public String status_comment {get;set;}    
    public List<document_re_upload_list> document_re_upload_list {get;set;}

    public class document_re_upload_list {
        public String bank_code {get;set;}
        public String reject_reason {get;set;}
    }
    
    public IND_MahindraReverseStatusRequest(Id loanAppId, String status, String code) {
        
        if(loanAppId != null)
        {
            List<document_re_upload_list> docList = new List<document_re_upload_list>();
            document_re_upload_list docRecord = new document_re_upload_list();
            try{
                Opportunity opp = [select IModuleId__c,LastModifiedDate, Total_Funded_Premium__c, LeadSource, (select Document_Type__c, CMU_Accept_Reject__c, CMU_Rejection_Reason__c from Documents__r where CMU_Accept_Reject__c = 'Reject') from Opportunity where Id=: loanAppId WITH SECURITY_ENFORCED limit 1];
                System.debug('opp doc records: '+opp.Documents__r);
                if(opp!=null)
                {
                    this.applicant_Id = opp.IModuleId__c;
                    this.application_status = code;
                    if(opp.leadSource == System.label.Mahindra_Custom_Lead_API_Value){
                        this.loan_type_id = System.Label.Mahindra_Custom_Loan_Type_ID;
                    }else if(opp.leadSource == System.label.Mahindra_PreA_Lead_API_Value){
                        this.loan_type_id = System.Label.Mahindra_PreA_Loan_Type_ID;
                    }
                    this.application_sub_status ='';
                    //format Datatime to accepted format
                    Datetime myDT = opp.LastModifiedDate;
                    String myDate = myDT.format('yyyy-MM-dd HH:mm:ss');
                    this.last_updated_timestamp = myDate;

                    this.status_comment = System.Label.MSIL_Status_Comment;
                    if(opp.Documents__r != null && opp.Documents__r.size() > 0) {
                        for(Documents__c docs : opp.Documents__r) {
                            docRecord.bank_code = docs.Document_Type__c;
                        	docRecord.reject_reason = docs.CMU_Rejection_Reason__c;
                        	docList.add(docRecord);                        	
                        }
                        this.document_re_upload_list = docList;
                    }
                    
                    List<Final_Term__c> finalTermList = [SELECT Id, Name, Loan_Amount__c, Loan_Application__r.Required_Loan_amount__c, Installment_Type__c,
                                               Loan_Application__r.Required_Tenure__c, Repayment_mode__c, Do_you_want_to_initiate_e_NACH__c,
                                               Tenure__c, CRM_IRR__c, EMI_Amount__c,
                                               Holiday_period__c, Net_IRR__c,Gross_IRR__c, IsOfferEngineApiFailed__c, Service_charges__c, Documentation_charges__c
                                               FROM Final_Term__c 
                                               WHERE Loan_Application__c =: loanAppId 
                                               WITH SECURITY_ENFORCED 
                                               LIMIT 1];                    

                    // approved_tenure

                    if(finalTermList.size() > 0){
                        Final_Term__c finalTerm = finalTermList[0];
                    if(code == '340002'){
                        if(finalTerm.Tenure__c != null){
                            this.approved_tenure = String.valueOf(finalTerm.Tenure__c);
                        }else{
                            this.approved_tenure = String.valueOf(finalTerm.Loan_Application__r.Required_Tenure__c);
                        }
                    }

                    if(code == '340003' || code == '340005'){
                        this.approved_tenure = finalTerm.Tenure__c != null ? String.valueOf(finalTerm.Tenure__c) : String.valueOf(0);
                    }

                    //approved_ROI

                    if(code == '340002' || code == '340003' || code == '340005'){
                        if(finalTerm.CRM_IRR__c != null){
                            this.approved_ROI = String.valueOf(finalTerm.CRM_IRR__c);
                        }else{
                            this.approved_ROI = String.valueOf(0);
                        }
                    }

                    // approved_loan_amount

                    if(code == '340002'){
                        if(finalTerm.Loan_Amount__c != null){
                            Integer finAmount = Integer.valueOf(finalTerm.Loan_Amount__c) + Integer.valueOf(opp.Total_Funded_Premium__c);
                            this.approved_loan_amount = String.valueOf(finAmount);
                        }
                        else{
                            if(finalTerm.Loan_Application__r.Required_Loan_amount__c != null){
                                Integer finAmount = Integer.valueOf(finalTerm.Loan_Application__r.Required_Loan_amount__c) + Integer.valueOf(opp.Total_Funded_Premium__c);
                                this.approved_loan_amount = String.valueOf(finAmount);
                            }else{
                                this.approved_loan_amount = '';
                            }
                        }
                    }

                    if(code == '340003'){
                        Decimal amount = Decimal.valueOf(finalTerm.Loan_Amount__c) + opp.Total_Funded_Premium__c;
                        this.approved_loan_amount = String.valueOf(Integer.valueOf(amount));
                    }

                    if(code == '340005'){
                        List<InsuranceDetails__c> insuranceDetailsList = [SELECT Id,Name, Amount__c,Applicant__r.Name,Applicant__r.Applicant_Type__c,Funded_Non_funded__c,Product_Type__c,Funded_Premium__c,Insurance_Plan__c,Combo_LI_Premium__c,Combo_EMI_Premium__c,EMI_Passed_in_API__c 
                                                                            FROM InsuranceDetails__c 
                                                                            WHERE Loan_Application__c =: loanAppId];
                        Decimal fundedPremium = 0; 
                        for(InsuranceDetails__c insDet : insuranceDetailsList){
                            if(insDet.Funded_Non_funded__c == 'Funded'){
                                fundedPremium = fundedPremium + insDet.Amount__c;
                            }
                        }

                        Decimal amt = finalTerm != null && finalTerm.Loan_Amount__c != null ? Decimal.valueOf(finalTerm.Loan_Amount__c) + fundedPremium : 0;
                        this.approved_loan_amount = String.valueOf(amt);

                    }

                    //processing_fee
                    if(code == '340002' || code == '340003' || code == '340005'){
                        Decimal charges = Decimal.valueOf(finalTerm.Service_charges__c) + Decimal.valueOf(finalTerm.Documentation_charges__c);
                        this.processing_fee = String.valueOf(charges);
                    }
                    }
                }
            }
            catch(Exception ex)
            {
                System.debug(ex);
                throw new IND_Exception(ex.getMessage());
            }
        } 
    }
}