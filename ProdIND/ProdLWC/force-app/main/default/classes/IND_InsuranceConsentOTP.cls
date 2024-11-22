/*------------------------------------------------------------
Author:        Umamaheshwar P
Company:       Persistent Systems
Description:   This class is controller for Insurance Consent OTP
Test Class:     
Historyf
Date            Author              Comments
-------------------------------------------------------------
3-02-2022      Umamaheshwar P      Created
------------------------------------------------------------*/
//CISP: 2587
public without sharing class IND_InsuranceConsentOTP { 
    public  String currentRecordId {get;set;}
    public  String currentRecordurl {get;set;}
    public string LoanApplicatonNumber{get;set;}
    public string Label;
    public transient List<InsuranceDetails__c> detail {get;set;}
   public transient List<Vehicle_Detail__c> vehclDetails{get;set;}
    public transient  string InusuranceConsentVf{get;set;}
    public string applicantName{get;set;}
    public string vehicleVariant{get;set;}
    public string InsuranceConsentvfagree{get;set;}
    public string healthname{get;set;}
    public decimal healthamount{get;set;}
    public string comboname{get;set;}
    public decimal comboamount{get;set;}
    public string tataEMIName{get;set;}
    public decimal tataEMIAmount{get;set;}
    public string liEMIName{get;set;}
    public decimal liEMIAmount{get;set;}
    public string flexiName{get;set;}
    public decimal flexiAmount{get;set;}
    public string motorname{get;set;}
    public decimal motoramount{get;set;}
    public string liName{get;set;}
    public decimal liAmount{get;set;}
    public string gpaname{get;set;}
    public string tenure{get;set;}
    public string emiAmount{get;set;}
    public decimal gpaamount{get;set;}
    public String DocID;
    public Boolean healthValue{get;set;}
    public boolean isSubmitted{get;set;}   
    public Applicant__c app{get;set;}
    public boolean linkExpired;
    public Map<Id, Boolean> insuranceDetailIdVsCollapseExpand {get; set;}
    public Map<Id, Boolean> insuranceDetailIdVsCollapseExpandMap {get; set;}
    public String insuranceId {get; set;}
    public boolean optedTataEMI {get; set;}
    public String productType{get;set;}
    public  Map<String,List<InsuranceProduct>> vehicleInsuranceMap{get;set;}
    public  Map<String,String> vehicleVariantMap{get;set;}
    
   public boolean getlinkExpired()
   {
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        currentRecordurl  = ApexPages.CurrentPage().getparameters().get('connum');
       
       Applicant__c applicant=[Select id,Insurance_Consent_OTP_Time__c,
            Insurance_Consent_OTP__c,Insurance_Consent_Received__c ,Opportunity__c
            from Applicant__c where id =: currentRecordId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED]; 
       
           if(applicant.Insurance_Consent_Received__c == true)
           {
               isSubmitted = false;
           }
       system.debug('The is submiteed value is '+isSubmitted);
      
       
         Long currentDateTime = DateTime.now().getTime();
        if(applicant.Insurance_Consent_OTP_Time__c!=null){
            system.debug('The insurance consent otp time before '+applicant.Insurance_Consent_OTP_Time__c);
            Long consentSentOnDate = applicant.Insurance_Consent_OTP_Time__c.getTime();
               system.debug('The insurance consent otp time After '+consentSentOnDate);
            Long difference = (currentDateTime-consentSentOnDate)/60000;                
            if(difference > 4320){                
                system.debug('it is '+true);
                return true;
            }
            else{
                system.debug('it is '+false);
                if(currentRecordurl == applicant.Insurance_Consent_OTP__c){
                    system.debug('update link '+false);
                    return false;
                }
                else if (currentRecordurl != applicant.Insurance_Consent_OTP__c){
                    system.debug('New link '+false);
                    return true;
                }
                else{
                    return true;
                }
               
            }
        }
        return false;
       
   }
    
     public IND_InsuranceConsentOTP() 
     {
          optedTataEMI=false;
          isSubmitted=true;
          currentRecordId = ApexPages.CurrentPage().getparameters().get('id');
          insuranceDetailIdVsCollapseExpand = new Map<Id, Boolean>();
            detail =  [select Id,Name, Amount__c,Product_Type__c, Funded_Non_funded__c, Insurance_Plan__c
            ,Applicant__r.Name,Loan_Application__r.Lead_number__c,Funded_Premium__c,Applicant__r.Declaration_of_Good_Health__c,Vehicle_Detail__r.Declaration_of_Good_Health__c,Vehicle_Detail__c,Vehicle_Detail__r.Variant__c,Loan_Application__c
               from InsuranceDetails__c where Applicant__c =:currentRecordId WITH SECURITY_ENFORCED ORDER BY Name ASC];
         system.debug('The details are '+detail);
         healthValue = detail.size() > 0 ? detail[0].Applicant__r.Declaration_of_Good_Health__c : false;
         LoanApplicatonNumber = detail[0].Loan_Application__r.Lead_number__c;
                applicantName=detail[0].Applicant__r.Name;
                      
         if(detail[0].Product_Type__c==System.Label.Tractor)   {
          productType=System.Label.Tractor;
            vehicleInsuranceMap =new Map<String,List<InsuranceProduct>>();
             vehicleVariantMap= new Map<String,String>();
            Map<String,Final_Term__c> finalTermMap=new Map<String,Final_Term__c>();
            for(Final_Term__c finalTerm : [select Id,Tenure__c,EMI_Amount__c,Vehicle_Detail__c from Final_Term__c where Loan_Application__c =: detail[0].Loan_Application__c  AND Vehicle_Detail__c!=NULL WITH SECURITY_ENFORCED LIMIT 5]){
              finalTermMap.put(finalTerm.Vehicle_Detail__c,finalTerm);
            }
            for (InsuranceDetails__c insuranceObject : detail) {
              if(!vehicleVariantMap.containsKey(insuranceObject.Vehicle_Detail__c)){
                vehicleVariantMap.put(insuranceObject.Vehicle_Detail__c,insuranceObject.Vehicle_Detail__r.Variant__c);
              }
              if(!insuranceDetailIdVsCollapseExpand.containsKey(insuranceObject.Id)) {
                insuranceDetailIdVsCollapseExpand.put(insuranceObject.Id, false);
               }
            InsuranceProduct product=new InsuranceProduct();
            product.insuranceId=insuranceObject.Id;
            product.vehicleId=insuranceObject.Vehicle_Detail__c;
            product.name=insuranceObject.Name;
            product.amount=insuranceObject.Amount__c;
            product.vehicleVariant=insuranceObject.Vehicle_Detail__r.Variant__c;
            product.healthValue=insuranceObject.Vehicle_Detail__r.Declaration_of_Good_Health__c;
            if(finalTermMap.containsKey(insuranceObject.Vehicle_Detail__c)){
              product.finalTermTenure=finalTermMap.get(insuranceObject.Vehicle_Detail__c)?.Tenure__c;
              product.finaltermEMI=finalTermMap.get(insuranceObject.Vehicle_Detail__c)?.EMI_Amount__c;
            }
              if(vehicleInsuranceMap.containsKey(insuranceObject.Vehicle_Detail__c)){
                vehicleInsuranceMap.get(insuranceObject.Vehicle_Detail__c).add(product);
              }
              else{
                vehicleInsuranceMap.put(insuranceObject.Vehicle_Detail__c, new List<InsuranceProduct>{product});
              }          
            }
          
         }
         else{
          List<Final_Term__c> finalTermList=new List<Final_Term__c>();
 
            vehclDetails =  [select Id,Variant__c,Loan_Application__c from Vehicle_Detail__c where Loan_Application__c =: detail[0].Loan_Application__c WITH SECURITY_ENFORCED];
            finalTermList = [select Id,Tenure__c,EMI_Amount__c from Final_Term__c where Loan_Application__c =: detail[0].Loan_Application__c WITH SECURITY_ENFORCED LIMIT 1];
          vehicleVariant =vehclDetails[0].Variant__c;
            for(InsuranceDetails__c det : detail) {
              if(!insuranceDetailIdVsCollapseExpand.containsKey(det.Id)) {
                  insuranceDetailIdVsCollapseExpand.put(det.Id, false);
              }
                if(det.name == 'HEALTH') { healthname = det.name;healthamount = det.Amount__c;
                } else if(det.name == 'COMBO') {comboname = det.name;comboamount = det.Amount__c;
                } else if(det.name == 'MOTOR') { motorname = det.name;motoramount = det.Amount__c;
                } else if(det.name == 'GPA') {gpaname = det.name;gpaamount = det.Amount__c;
                } else if(det.name == 'FLEXI') {flexiName = det.name;flexiAmount = det.Amount__c;
                } else if(det.name == 'TATA_EMI') {tataEMIName = det.name;tataEMIAmount = det.Amount__c;optedTataEMI = true;
                } else if(det.name == 'LI_EMI') {liEMIName = det.name;liEMIAmount = det.Amount__c;
                } else if(det.name == 'LI') {liName = det.name;liAmount = det.Amount__c;
                }
            }
  
         if (finalTermList.size()>0) {
           tenure = finalTermList[0].Tenure__c;
          emiAmount = String.valueOf(finalTermList[0].EMI_Amount__c);
        }
        }     
        InusuranceConsentVf = System.label.InusuranceConsentVf;
        InsuranceConsentvfagree = system.label.InsuranceConsentvfagree;
     }
    
    public PageReference acceptandRender(){    
        try{
            System.debug('I am in accept renderer');
              detail = [select Id,Name, Amount__c,Product_Type__c, Funded_Non_funded__c, Insurance_Plan__c,Applicant__r.Name,Loan_Application__r.Lead_number__c,Funded_Premium__c from InsuranceDetails__c where Applicant__c =:currentRecordId WITH SECURITY_ENFORCED ORDER BY Name ASC];
            insuranceDetailIdVsCollapseExpandMap = insuranceDetailIdVsCollapseExpand;
          insuranceDetailIdVsCollapseExpand = new Map<Id, Boolean>();
          insuranceDetailIdVsCollapseExpand = insuranceDetailIdVsCollapseExpandMap;
            Applicant__c applObj= [SELECT Id,Applicant_Type__c,Opportunity__c,Opportunity__r.Product_Type__c, Insurance_Consent_OTP_Time__c,Insurance_Consent_Received__c,Insurance_Consent_OTP__c,Declaration_of_Good_Health__c                                   
                                   FROM Applicant__c
                                   WHERE Id =: currentRecordId
                                   WITH SECURITY_ENFORCED];
            System.debug('I am in accept render and applicant is '+applObj);
            applObj.Insurance_Consent_Received__c = true;
            applObj.Insurance_consent_sent_on__c = DateTime.Now();
            string VehicalID;
            if(applObj.Opportunity__r.Product_Type__c==System.Label.Tractor){
              List<InsuranceProduct> vehicleInsuranceList=new List<InsuranceProduct>();
              List<Vehicle_Detail__c> vehicleDetails=new List<Vehicle_Detail__c>();
              for(List<InsuranceProduct> productList : vehicleInsuranceMap.values()){
                vehicleInsuranceList.addAll(productList);
              }
              for(InsuranceProduct product :vehicleInsuranceList){
                if(product.name=='TATA_EMI'){
                  Vehicle_Detail__c vehicle=new Vehicle_Detail__c();
                  vehicle.Id=product.vehicleId;
                  vehicle.Declaration_of_Good_Health__c=product.healthValue;
                  vehicleDetails.add(vehicle);
                }
              }
              if(!vehicleDetails.isEmpty()){
                update vehicleDetails;
              }
            

            } 
            else{
              applObj.Declaration_of_Good_Health__c = healthValue;     
              VehicalID=[select Id,Variant__c,Loan_Application__c from Vehicle_Detail__c where Loan_Application__c=:applObj.Opportunity__c].id;
            }       
            update applObj;
             PageReference pageRef = new PageReference('/apex/InsuranceConsentThanksMessage');
            pageRef.setRedirect(true);
            
             if(applObj.Applicant_Type__c == 'Borrower')
            {
                Label =system.Label.Insurance_for_borrower;
            }
            else if(applObj.Applicant_Type__c == System.Label.CoBorrower)
            {
               Label=system.Label.Insurance_for_coborrower;
            }else{
              Label='Insurance form ' + applObj.Applicant_Type__c;
            }
          
           
            
            DocID = createOtherDocument(Label,VehicalID,applObj.id ,applObj.Opportunity__c);
            List<ContentDocumentLink> contentLinkList = [Select id from ContentDocumentLink WHERE LinkedEntityId =: DocID];
            if(contentLinkList.size() == 0){
              createInsuranceFormPdf(DocID,Label,applObj.Opportunity__c);
            }

               return pageRef;

        }
         catch (exception e){
            ErrorLoggerUtil.logErrorEvent('IND_InsuranceConsentOTP', 'acceptandRender', 'Class', e);
            system.debug('The error at line '+e.getLineNumber());
             system.debug('The error at line message  '+e.getMessage());
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
      //CISP: 2587
 
    public static void createInsuranceFormPdf(String DocID,string Label,String oppId) {
        Blob fileDetails ;
        PageReference PDf =  Page.InsuranceConsentPDF;
        PDf.getParameters().put('Id',DocID);
        if(!test.isRunningTest()){fileDetails = PDf.getContent();
            system.debug('The file details are '+fileDetails);
        }else{
          fileDetails = blob.valueof('TEST');
        } 
        Utilities.createContentDocumentDownloadFromApex(DocID,Label, fileDetails, 'pdf',oppId);
    }
    
     /*
    * @Method Name: createOtherDocument
    * @Created by:  Parimal Shinde
    * @description: to create a Document object for 'Other documents'
    * @Param:       String - Document Type
    * @Param:       String - current Vehicle Record ID
    * @Param:       String - Loan Applicant ID
    * @Return:      String - loanApplication ID
    */
    
        public static string createOtherDocument(String docType,String vehicleDetailId,String applicantId,String loanApplicationId){
         try {  
                string leadNo;
                list<Documents__c> docUpdList = new list<Documents__c>();
                ID otherDocRecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('Other Documents').getRecordTypeId();
                if(loanApplicationId!=null ){
                   list<Opportunity> loanApp= [Select Name from Opportunity where Id =: loanApplicationId WITH SECURITY_ENFORCED];
                   if(!loanApp.isEmpty()) {
                       leadNo = loanApp[0].Name;
                       //Deactivate existing Document, if any                      
                       for(Documents__c doc : [Select Id from Documents__c where Document_Type__c = :docType and Opportunity_Relation__c = :loanApplicationId and Applicant__c =:applicantId WITH SECURITY_ENFORCED]) {doc.is_Active__c = false; docUpdList.add(doc);
                       }
                   }
                   if(!docUpdList.isEmpty()) {update docUpdList;
                   }   
                   Documents__c docObject= new Documents__c(Name = docType+' '+leadNo,Vehicle_Detail__c=vehicleDetailId,Applicant__c=applicantId,Opportunity_Relation__c=loanApplicationId,Document_Type__c=docType,is_Active__c = true);
                    System.debug('docObject'+docObject);
                   docObject.RecordTypeId = otherDocRecordTypeId;
                   if (Schema.sObjectType.Documents__c.isCreateable())
                    	insert docObject;
                   
                   if(Test.isRunningTest())
                   {
                      throw new AuraHandledException(System.Label.ExceptionMessage);
                   }
                   return docObject.Id;
                }
                 return null;
              } catch(Exception e){
                    ErrorLoggerUtil.logErrorEvent('IND_InsuranceConsentOTP', 'createOtherDocument ', System.Label.Apex, e);
            		throw new AuraHandledException(e.getMessage() + ' ' + e.getStackTraceString());  
              }

    }

    /*
    * @Method Name: collapseExpandMethod
    * @Created by:  Rajat Jaiswal
    */
    public void collapseExpandMethod(){
      try {
          detail =  [select Id,Name, Amount__c,Product_Type__c, Funded_Non_funded__c, Insurance_Plan__c
        ,Applicant__r.Name,Loan_Application__r.Lead_number__c,Funded_Premium__c
          from InsuranceDetails__c where Applicant__c =:currentRecordId WITH SECURITY_ENFORCED  ORDER BY Name ASC];
        if (insuranceDetailIdVsCollapseExpand.containsKey(insuranceId)) {
          insuranceDetailIdVsCollapseExpand.put(insuranceId, !insuranceDetailIdVsCollapseExpand.get(insuranceId));
        }
          insuranceDetailIdVsCollapseExpandMap = insuranceDetailIdVsCollapseExpand;
          insuranceDetailIdVsCollapseExpand = new Map<Id, Boolean>();
          insuranceDetailIdVsCollapseExpand = insuranceDetailIdVsCollapseExpandMap;
      } catch(Exception e) {
          ErrorLoggerUtil.logErrorEvent('IND_InsuranceConsentOTP', 'collapseExpand', e.getTypeName(), e, '');
      }
    }
  /*  public Class AssetList{
      public List<InsuranceProduct> insuranceProductList{get;set;}
      public String variantName{get;set;}
    }*/
    public Class InsuranceProduct{
      public String vehicleVariant{get;set;}
      public String vehicleId{get;set;}
      public String insuranceId{get;set;}
      public String name{get;set;}
      public Decimal amount{get;set;}
      public String finalTermTenure{get;set;}
      public Decimal finaltermEMI{get;set;}
      public Boolean healthValue{get;set;}

    }
}