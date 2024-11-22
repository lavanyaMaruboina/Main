/*------------------------------------------------------------
Author: Santhosh Mothe
Company: Persistent Systems
Description: This class is wrapper class for the DocAuth Document Report Request
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
12-01-2022    Santhosh Mothe            Created
------------------------------------------------------------*/
public with sharing class IND_InsurancePremiumRequest extends ParentAPIRequest{
    //request paramaters for insurance premium request
    public String Application_No{get;set;}
    public String Vehicle_ID{get;set;}
    public String Product{get;set;}
    public String Age {get;set;}
    public String Gender {get;set;} //SFTRAC-629
    public String Periodicity {get;set;} //SFTRAC-629
    // public String Ins_Product {get;set;}
    // public String Plan_Code{get;set;}
    public String Fin_Amount{get;set;}
    public String Tenure{get;set;}
    public List<Product_Details> Product_Details{get;set;}

    public class Product_Details {
    public String Ins_Product{get;set;}
    public String Opt_YN{get;set;}
    public String Plan_Code{get;set;}
    public String Premium{get;set;}
    public String Fund_YN{get;set;}
    }
    /*
* @Method Name: Constructor
* @Created by: 	Santhosh Mothe.
* @Description: create the InsurancePremium
* @Param:       Object Request Wrapper 
* @Return:      void
*/
    public IND_InsurancePremiumRequest(Applicant__c app,String Ins_Product, String Plan_Code,String loanAppId){
        this(app,Ins_Product,Plan_Code,loanAppId,'');
    }
    public IND_InsurancePremiumRequest(Applicant__c app,String Ins_Product, String Plan_Code,String loanAppId, String assetId){
        try{
         if( app != null){
             List<Documents__c> docList = [SELECT Proof_of_Identity_POI__c, Applicant__c,Gender__c,KYC_DOB__c,Opportunity_Relation__c, Document_Type__c, Opportunity_Relation__r.LeadSource //D2C Change
                                           FROM Documents__c 
                                           WHERE Opportunity_Relation__c =:loanAppId AND Applicant__c =: app.Id
                                           WITH SECURITY_ENFORCED];
                                           
             for(Documents__c doc : docList)  {
                if(doc.Proof_of_Identity_POI__c == true){
                    if(doc.KYC_DOB__c != null){
                        Date kycDOB = doc.KYC_DOB__c;
                        this.Age = calculateAge(kycDOB);
                        if(app.Opportunity__r.Product_Type__c=='Tractor'){//SFTRAC-629
                            this.Gender = doc.Gender__c != null && doc.Gender__c =='Male' ? 'M' : doc.Gender__c =='Female' ? 'F':'' ; 
                        }/*else{
                            this.Gender =doc.Gender__c;//CISP-21364
                        }*/
                    }
                } else if(doc.Proof_of_Identity_POI__c == false){
                    if(doc.KYC_DOB__c != null && this.Age == null){
                        if(app.Opportunity__r.Product_Type__c != Label.Tractor){
                        Date kycDOB = doc.KYC_DOB__c;
                        this.Age = calculateAge(kycDOB);
                        }
                        if(app.Opportunity__r.Product_Type__c=='Tractor'){//SFTRAC-629
                            this.Gender = doc.Gender__c != null && doc.Gender__c =='Male' ? 'M' : doc.Gender__c =='Female' ? 'F':'' ; 
                        }/*else{
                            this.Gender =doc.Gender__c;//CISP-21364
                        }*/
                    }
                }
             }                         
             this.Application_No =  String.valueOf(app.Opportunity__r.Application_number__c);
             this.Vehicle_ID = app.Opportunity__r.Vehicle_type__c=='New'? '1' : '4';
            List<Vehicle_Detail__c> vehLst = new List<Vehicle_Detail__c>();
            if(String.isBlank(assetId)){
                vehLst = [SELECT ID,Product__c,Loan_Application__c  FROM Vehicle_Detail__c WHERE Loan_Application__c =:app.Opportunity__c];
             }else{
                vehLst = [SELECT Id,Product__c,Loan_Application__c  FROM Vehicle_Detail__c WHERE Loan_Application__c =:app.Opportunity__c AND Id =: assetId WITH SECURITY_ENFORCED];
             }

            for(Vehicle_Detail__c vedObj:vehLst)
            {
                this.Product = vedObj.Product__c != null && vedObj.Product__c == 'Two Wheeler' && app.Opportunity__r.Vehicle_type__c=='Refinance' ? 'S' : vedObj.Product__c == 'Two Wheeler' ? 'H' : vedObj.Product__c == 'Passenger Vehicles' ? 'C' : vedObj.Product__c == System.Label.Tractor ? 'T' : '' ;
            }
            List<Final_Term__c> objFinalTerms = new List<Final_Term__c>();
            if(String.isBlank(assetId)){
                objFinalTerms = [SELECT id, Loan_amount__c, Tenure__c,Installment_Frequency__c FROM Final_Term__c WHERE Loan_Application__c = :loanAppId LIMIT 1];
            }else{
                objFinalTerms = [SELECT Id, Loan_amount__c, Tenure__c,Installment_Frequency__c FROM Final_Term__c WHERE Loan_Application__c = :loanAppId AND Vehicle_Detail__c =: assetId LIMIT 1];
            }
            if (objFinalTerms.size() != 0) {
                this.Fin_Amount = objFinalTerms[0].Loan_amount__c;
                this.Tenure = objFinalTerms[0].Tenure__c;
                if(app.Opportunity__r.Product_Type__c=='Tractor'){//SFTRAC-629
                    this.Periodicity = objFinalTerms[0].Installment_Frequency__c == 'Monthly' ? 'M' : objFinalTerms[0].Installment_Frequency__c == 'Quarterly' ? 'Q' : objFinalTerms[0].Installment_Frequency__c == 'Half yearly' ? 'H' : '';  //SFTRAC-629
                }/*else{
                    this.Periodicity ='';
                }*/
            }else if(app.Opportunity__r.Product_Type__c=='Tractor'){//SFTRAC-629
                this.Periodicity ='';
            }

            Product_Details = new List<Product_Details>();
            
            List<Product_Details> prodetailList = (List<Product_Details>) JSON.deserialize(Ins_Product, List<Product_Details>.class);
            for (Product_Details pro : prodetailList) {
                if (String.isNotBlank(pro.Ins_Product)) {
                    Product_Details productDetali = new Product_Details();
                    if(app.Opportunity__r.Product_Type__c == Label.PassengerVehicles && pro.Ins_Product == 'LI_EMI'){
                        productDetali.Ins_Product = 'COMBO';
                        productDetali.Plan_Code = 'LI_EMI';
                    }else{
                        productDetali.Ins_Product = pro.Ins_Product;
                        productDetali.Plan_Code = pro.Plan_Code != null ? pro.Plan_Code : '';
                    }
                    productDetali.Opt_YN = pro.Opt_YN == 'Y' ? 'Y' : 'N';
                    productDetali.Premium = pro.Premium !=null ? String.valueOf(pro.Premium) : '';
                    productDetali.Fund_YN = pro.Fund_YN == 'Y' ? 'Y' : 'N';
                    this.Product_Details.add(productDetali);
                }
            }
        }
        validate(System.Label.Insurance_Premium, app.Opportunity__r.Product_Type__c); //SFTRAC-629 added one more parameter app.Opportunity__r.Product_Type__c
        }catch(Exception e){
            throw new IND_Exception(e.getMessage()+' => '+e.getStackTraceString()); 
        }

    }
    public static String calculateAge (Date dt){
        date todayDate =date.today();
        Integer age = todayDate.year() - dt.year();
        if(todayDate.month() < dt.month() || (todayDate.month() == dt.month() && todayDate.day() < dt.day())) {
            age--;
        }
        return String.valueOf(age);
    }
    
    
    /*
* @Method Name: getHttpRequestHeaders
* @Created by: 	Santhosh Mothe.
* @Description: Method to get the HTTP request header data
* @Return:      Map
*/
    public override Map<String,String> getHttpRequestHeaders(){    
        //Map to store HTTP request header data
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }
    
    //
    /*
* @Method Name: Constructor
* @Created by: 	Santhosh Mothe.
* @Description: Method to validate the request data
* @Param:       String serviceName 
* @Return:      boolean
*/
    public override boolean validate(String serviceName, String oppProductType){
      
        if(String.isBlank(this.Application_No)){
            throw new IND_Exception(System.Label.ApplicationNo);
        }
        if(String.isBlank(this.Vehicle_ID)){
            throw new IND_Exception(System.Label.VehicleId);
        }
        if(String.isBlank(this.Product)){
            throw new IND_Exception(System.Label.Product);
        }
        if(String.isBlank(this.Age)){
            throw new IND_Exception(System.Label.Age);
        }
        if(String.isBlank(this.Gender) && oppProductType == 'Tractor'){ //SFTRAC-629
            throw new IND_Exception(System.Label.Gender);
        }
        // if(String.isBlank(this.Ins_Product)){
        //     throw new IND_Exception(System.Label.Ins_Product);
        // }
        // if(String.isBlank(this.Plan_Code)){
        //    throw new IND_Exception(System.Label.Plan_Code);
        // }
        if(String.isBlank(this.Fin_Amount)){
			throw new IND_Exception(System.Label.FinAmount);
        }
        if(String.isBlank(this.Tenure)){
			throw new IND_Exception(System.Label.Tenure);
        }
        
        return true;
    }
}