public without sharing class ind_ApplicationFormSigningController {
    @AuraEnabled(cacheable=true)
    public static Id getloanappid(Id appId) {
        Id loanapId;
        Applicant__c appp =[select id, Opportunity__c from Applicant__c where id=:appId];
        if( appp.Opportunity__c != null)
        {
            loanapId = appp.Opportunity__c;
        }
        return loanapId;
    }
    
     @AuraEnabled(cacheable=true)
    public static  List<InsuranceDetails__c> getInsurenDetails(Id aplId){
        List<InsuranceDetails__c> InsurenDetList= [SELECT Amount__c,Applicant__c,Funded_Non_funded__c,Funded_Premium__c
                                              FROM InsuranceDetails__c WHERE Applicant__c =: aplId];
         
        return InsurenDetList;
        }
    
    @AuraEnabled(cacheable=true)
    public static  List<Documents__c> getKYCDetails(Id aplId){
        List<Documents__c> KycList= [select id, KYC_name__c, Gender__c,
                                            First_Name__c, KYC_No__c from Documents__c where Applicant__c =: aplId];
         
        return KycList;
        }
        
 @AuraEnabled(cacheable=true)
     public static  List<Income_Details__c> getIncomeDetails(Id aplId){
       List<Income_Details__c> IncomeDetList= new List<Income_Details__c>();
        Applicant__c app =[select id,(select Id ,
                                      name,
                                      Legal__c,
                                      Income_Source__c ,
                                      Name_of_Recipient_Bank__c,
                                      Employer_Business_Name__c,
                                      Current_Years_in_employment_business__c from Income_Details__r) from Applicant__c where id=:aplId limit 1];
          system.debug('app'+app);
          for(Income_Details__c IncomeDet : app.Income_Details__r){
              Income_Details__c idet = new Income_Details__c();
              idet.Id=IncomeDet.Id;
              idet.Name=IncomeDet.Name;
              idet.Legal__c=IncomeDet.Legal__c;
              idet.Income_Source__c=IncomeDet.Income_Source__c;
              idet.Name_of_Recipient_Bank__c=IncomeDet.Name_of_Recipient_Bank__c;
              idet.Employer_Business_Name__c=IncomeDet.Employer_Business_Name__c;
              idet.Current_Years_in_employment_business__c=IncomeDet.Current_Years_in_employment_business__c;
              IncomeDetList.add(idet);
          }

      return IncomeDetList;
     }
    
     @AuraEnabled(cacheable=true)
     public static List<Final_Term__c> getFinalTerm(Id appId){
        Id loanapId;
       List<Final_Term__c> FinalTermList= new List<Final_Term__c>();
        Applicant__c appp =[select id, Opportunity__c from Applicant__c where id=:appId];
         if( appp.Opportunity__c != null)
        {
        loanapId = appp.Opportunity__c;
        }
         FinalTermList =  [select EMI_Amount__c,
                                         Loan_Amount__c,
                                         CRM_IRR__c,
                                         Tenure__c,
                                         Required_CRM_IRR__c from Final_Term__c where Loan_Application__c=:loanapId];
            
    /*  Opportunity opp = [select id,name,(select EMI_Amount__c,
                                         Loan_Amount__c,
                                         CRM_IRR__c,
                                         Tenure__c,
                                         Required_CRM_IRR__c from Final_Terms__r) from Opportunity where id=:loanapId];
         for(Final_Term__c FinalTerm : opp.Final_Terms__r){
             Final_Term__c fitrm =new Final_Term__c();
             fitrm.EMI_Amount__c = FinalTerm.EMI_Amount__c;
             fitrm.Loan_Amount__c = FinalTerm.Loan_Amount__c;
             fitrm.CRM_IRR__c = FinalTerm.CRM_IRR__c;
             fitrm.Tenure__c = FinalTerm.Tenure__c;
             fitrm.Required_CRM_IRR__c = FinalTerm.Required_CRM_IRR__c;
             
             FinalTermList.add(fitrm);
         }*/
        
        return FinalTermList;
    }
    
     @AuraEnabled(cacheable=true)
    public static  List<InsuranceDetails__c> getInsurenceDetails(Id aplId){
        List<InsuranceDetails__c> InsurenceDetList= [select Id, Amount__c,
                                                   Product_Type__c, 
                                                   Funded_Non_funded__c,
                                                   Insurance_Plan__c,
                                                   Applicant__c from InsuranceDetails__c where Applicant__c =: aplId];
         
        return InsurenceDetList;
        }
     @AuraEnabled(cacheable=true)
     public static List<Vehicle_Detail__c> getvehicle(Id appId){
        Id loanapId;
       List<Vehicle_Detail__c> vehiclelist= new List<Vehicle_Detail__c>();
        Applicant__c appp =[select id, Opportunity__c from Applicant__c where id=:appId];
         if( appp.Opportunity__c != null)
        {
        loanapId = appp.Opportunity__c;
        }
         vehiclelist =  [select Vehicle_type__c,
                          Product__c, Make__c, Model__c,
                          Variant__c,Ins_Issuance_date__c,
                         Insurance_declared_value__c,
                         Insurance_number__c,Insurer_name__c,
                         Insurance_type__c from Vehicle_Detail__c where Loan_Application__c=:loanapId];
        return vehiclelist;
    }
    
     @AuraEnabled(cacheable=true)
    public static String getProductType(Id appId){
        Applicant__c appp =[select id, Opportunity__r.Product_Type__c from Applicant__c where id=:appId WITH SECURITY_ENFORCED];
       
        return appp.Opportunity__r.Product_Type__c;
    }
    
    @AuraEnabled(cacheable=true)
    public static list<appWrapper> getApplicentDocuments(Id appId){
        Id OppId = [select id,Opportunity__c from Applicant__c where id = :appId].Opportunity__c;
       
       list<Documents__c> lst_document = [select id,name,Applicant__r.Opportunity__c,Applicant__r.Name,Applicant__r.Applicant_Type__c  from Documents__c where Applicant__r.Opportunity__c = :OppId ];
        list<appWrapper> lst_appWrapper = new list<appWrapper>();
        
        for(Documents__c D : lst_document){
           appWrapper aw = new appWrapper(); 
            aw.DocName = d.Name;
            aw.Applicant_Type = d.Applicant__r.Applicant_Type__c ;
            
            lst_appWrapper.add(aw);
        }       
        return lst_appWrapper;
    }
        
    public class appWrapper{
        @AuraEnabled
        public string DocName;
      @AuraEnabled
        public string Applicant_Type;
   
       
    }    
    
   @AuraEnabled(cacheable=true)
    public static string DisplayCustomerImage(Id appId){
        Documents__c doc = [select id, name,Applicant__c,Document_Type__c,Opportunity_Relation__c from Documents__c where Applicant__c= :appId and  Document_Type__c='Customer Image' limit 1];
        system.debug('Dco is '+doc);
        ContentDocumentLink docLink = [Select ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId =: doc.Id limit 1 ];
       // Set<id> setDocId = new Set<id>();
       // setDocId.add(docLink.id);
        ContentVersion cv =[SELECT Id,Document_Side_fileupload__c,FileType,ContentDocumentId from Contentversion where ContentDocumentId = : docLink.ContentDocumentId limit 1];
        	// ContentVersion cv = lst_contentVersion.get(0);
        system.debug('cv is '+ cv);
        return cv.Id;
      
    }
    
  /*   @AuraEnabled
    public static string getCustomerImageTypeDoc(Id appId){
       
        String docId;
        Set<id> setDocId = new Set<id>();
        Documents__c doc = [select id,Applicant__c,Document_Type__c,Opportunity_Relation__c from Documents__c where Applicant__c=:appId and  Document_Type__c='Customer Image'];
        for(ContentDocumentLink cdl : [Select ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId =: doc.Id]){
                setDocId.add(cdl.ContentDocumentId);
            }  
        system.debug('Set of ids : '+setDocId);
            docId = doc.id;       	
            ContentDocumentLink docLink = [Select ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId =: doc.Id ];
        	List<ContentVersion> lstcontentVersion=[SELECT Id,Document_Side_fileupload__c,FileType,ContentDocumentId from Contentversion where ContentDocumentId IN : setDocId];
             system.debug('lstcontentVersion'+lstcontentVersion);   
        	ContentVersion cv = lstcontentVersion.get(0);      
             return cv.Id;
    }*/

}