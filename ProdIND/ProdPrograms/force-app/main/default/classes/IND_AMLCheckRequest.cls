/*------------------------------------------------------------
Author: Vaishnavi Gadewar
Company: Persistent Systems
Description: This class is wrapper class for the AML Check Request
Test Class: IND_AMLCheckService_Test
History
Date            Author              Comments
------------------------------------------------------------- 
28-12-2021    Vaishnavi Gadewar         Created
13-1-2022     Satyam More				Modified
------------------------------------------------------------*/

public class IND_AMLCheckRequest extends ParentAPIRequest {
    public string Application_No {get;set;}
    public string ruleName {get;set;}
    public List<Fields> fields {get;set;}
    public class Fields {
        public string name {get;set;}
        public string value {get;set;}
        
    }
    public IND_AMLCheckRequest(Applicant__c app){  
        try{
            if(app!=null){
            
                this.Application_No = app.Opportunity__r.Lead_number__c+'_'+app.Applicant_Number__c; //'AC12313244_13423';
                this.ruleName = System.Label.BRANCH_CUSTOMER_WL;
                
                List<fields> fieldList = new List<fields>();
                fields fi = new fields();
                fi.name = 'name';
                fi.value = app.Name;
                
                fields fi1 = new fields();
                fi1.name = 'nationality';
                fi1.value = 'India';
                
                fields fi2 = new fields();
                fi2.name = 'dob';
                fields fi3 = new fields();
                fi3.name = 'resAddrCity';
                
                if(!app.Documents__r.isEmpty()){
                    for(Documents__c doc : app.Documents__r) {
                        if(app.Opportunity__r.Product_Type__c == System.Label.Tractor && app.Opportunity__r.Customer_Type__c == 'Non-Individual' && app.Applicant_Type__c == System.Label.Borrower && doc.Document_Type__c == System.Label.PanCards && doc.KYC_DOB__c != null){
                            //fi2.value = DateTime.newInstance(doc.KYC_DOB__c.year(),doc.KYC_DOB__c.month(),doc.KYC_DOB__c.day()).format('yyyy-MM-dd');
                            fi2.value = DateTime.newInstance(app.Opportunity__r.Date_of_Incorporation__c.year(),app.Opportunity__r.Date_of_Incorporation__c.month(),app.Opportunity__r.Date_of_Incorporation__c.day()).format('yyyy-MM-dd');
                        }else if(doc.Proof_of_Identity_POI__c == true) {
                            fi2.value = DateTime.newInstance(doc.KYC_DOB__c.year(),doc.KYC_DOB__c.month(),doc.KYC_DOB__c.day()).format('yyyy-MM-dd');  
                        }
                        if(doc.Proof_of_Address_POA__c == true || (app.Opportunity__r.Product_Type__c == System.Label.Tractor && app.Opportunity__r.Customer_Type__c == 'Non-Individual' && app.Applicant_Type__c == System.Label.Borrower && String.isNotBlank(doc.KYC_City__c) && doc.Document_Type__c == System.Label.GST)) {
                            fi3.value = doc.KYC_City__c;
                        }
                    }  
                }else{
                    throw new IND_Exception(System.Label.NoKYCFound);
                }   
    
                fieldList.add(fi);
                fieldList.add(fi1);
                fieldList.add(fi2);
                fieldList.add(fi3);
                fields=fieldList;
                fields=fields;
            }
            validate(System.Label.AMLCheck);
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_AMlCheckrequest', 'IND_AMLCheckRequest', System.Label.Apex, e);
            throw new AuraHandledException(e.getMessage());
        }
    }    
    
    
    public override Map<String,String> getHttpRequestHeaders(){    
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }
    
    
    public override boolean validate(String serviceName){
        
        if(String.isBlank(this.Application_No)){
            throw new IND_Exception(System.Label.ApplicationNo);
        }
        if(String.isBlank(this.ruleName)){
            throw new IND_Exception(System.Label.ruleName);
        }
        
        return true;
    }
}