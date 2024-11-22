/*------------------------------------------------------------
Author: Vishal Gadhave & Parimal Shinde
Company: Nanostuffs Technologies
Description: This class is wrapper class for the Reverse Status Request
Test Class: 
*/

public class IND_ReverseStatusRequest extends ParentAPIRequest{
    
    //public Id loanAppId {get;set;}
    //public String Application_No{get;set;}
    public String application_status {get;set;}
   //public String loan_type_id {get;set;}
    public String application_sub_status {get;set;}
    public String last_updated_timestamp {get;set;}
    //public String status_comment {get;set;}    
    public List<document_re_upload_list> document_re_upload_list {get;set;}
    public List<disbursement_details> disbursement_details {get;set;}
    public String unique_id{get;set;}
    public String los_id{get;set;}
    public String reference_id{get;set;}
    public String comment{get;set;}
    public String approved_date{get;set;}
    public String approved_tenure{get;set;}
    public String approved_roi{get;set;}
    public String approved_loan_amount{get;set;}
    public String approved_processing_fee{get;set;}

    
    public class document_re_upload_list {
        public String bank_code {get;set;}
        public String reject_reason {get;set;}
    }
    public class disbursement_details {   
    }
    
    public IND_ReverseStatusRequest(Id loanAppId, String status, String code)
    {
        if(loanAppId != null)
        {
            List<document_re_upload_list> docList = new List<document_re_upload_list>();
            document_re_upload_list docRecord = new document_re_upload_list();
            disbursement_details disRecord = new disbursement_details();
            try{
                Opportunity opp = [select IModuleId__c,LastModifiedDate, (select Document_Type__c, CMU_Accept_Reject__c, CMU_Rejection_Reason__c from Documents__r where CMU_Accept_Reject__c = 'Reject'),Sanction_Date__c,(select id,Tenure__c,CRM_IRR__c,Loan_Amount__c,Service_charges__c,Documentation_charges__c from Final_Terms__r ) from Opportunity where Id=: loanAppId WITH SECURITY_ENFORCED limit 1];
                System.debug('opp doc records: '+opp.Documents__r);
                if(opp!=null)
                {
                    //this.Application_No = opp.IModuleId__c;
                    this.application_status = code;
                    //this.loan_type_id = System.Label.MSIL_Loan_Type_ID;
                    this.application_sub_status ='';
                    DateTime lastModifiedDate = opp.LastModifiedDate;
                    this.last_updated_timestamp = lastModifiedDate.format('yyyy-MM-dd HH:mm:ss');
                    //this.status_comment = System.Label.MSIL_Status_Comment;
                    if(opp.Documents__r != null && opp.Documents__r.size() > 0) {
                        for(Documents__c docs : opp.Documents__r) {
                            docRecord.bank_code = docs.Document_Type__c;
                        	docRecord.reject_reason = docs.CMU_Rejection_Reason__c;
                        	docList.add(docRecord);                        	
                        }
                        this.document_re_upload_list = docList;
                    }
                    this.unique_id = opp.IModuleId__c;
                    this.los_id = opp.IModuleId__c;
                    this.reference_id = '';
                    this.comment = '';
                    String dateString='';
                    if(opp.Sanction_Date__c!=null){
                        Datetime dt = Datetime.newInstance(opp.Sanction_Date__c.year(), opp.Sanction_Date__c.month(),opp.Sanction_Date__c.day());
                        dateString = dt.format('dd-MM-yyyy');
                    }
                    this.approved_date =  (opp.Sanction_Date__c != null) ? dateString : '';
                    if(opp.Final_Terms__r != null && opp.Final_Terms__r.size() > 0) {
                        for(Final_Term__c ft : opp.Final_Terms__r) {
                            this.approved_tenure = (ft.Tenure__c != null) ? ft.Tenure__c : '';
                            this.approved_roi = '';
                            this.approved_loan_amount = (ft.Loan_Amount__c != null) ? ft.Loan_Amount__c : '';
                            // Decimal totalProcessingFee = 0;
                            // if(ft.Service_charges__c != null) {
                            //     totalProcessingFee += Decimal.valueOf(ft.Service_charges__c);
                            // }
                            // if(ft.Documentation_charges__c != null) {
                            //     totalProcessingFee += Decimal.valueOf(ft.Documentation_charges__c);
                            // }
                            // this.approved_processing_fee = totalProcessingFee.format();
                            this.approved_processing_fee = '';
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