/*------------------------------------------------------------
Author:        Divya Jawale
Company:       Persistent Systems
Description:   This class is wrapper class for the MFC Valuation request 
Test Class:    IND_MFCValuationService_Test
History
Date            Author              Comments
-------------------------------------------------------------
20-12-2021      Divya Jawale       Created
------------------------------------------------------------*/

public with sharing class IND_MFCValuationRequest extends ParentAPIRequest{
    //request paramaters for MFC Valuationrequest
    public final String Lead_Id{get;set;}
    public final String Branch{get;set;}
    public final String Productcode{get;set;}
    public final String ValuerCategory{get;set;}
    public final String ValuerCode{get;set;}
    public final String Valuer{get;set;}
    public final String Purpose{get;set;}
    public final String PlaceOfInspection{get;set;}
    public final String Location_of_Vehicle{get;set;}
    public final String Application_Ref_Type{get;set;}
    public final String Appl_Ref_Deal_No{get;set;}
    public final String CustomerName{get;set;}
    public final String ContactPerson{get;set;}
    public final String MobileNo{get;set;}
    public final String Emailid{get;set;}
    public final String City{get;set;}
    public final String VehicleCatg{get;set;}
    public final String VehicleSubCatg{get;set;}
    public final String Makecode{get;set;}
    public final String Model{get;set;}
    public final String Variantcode{get;set;}
    public final String VehRegNo{get;set;}
    public final String Vehtype{get;set;}
    public final String EngineNo{get;set;}
    public final String ChasisNo{get;set;}
    public final String NameTransferred{get;set;}
    public final String CurrentVehicleOwner{get;set;}
    public final String LienMaerkedIBL{get;set;}
    public final String MarkedOn{get;set;}
    public final String NowLienNameOf{get;set;}
    public final String RequesterName{get;set;}
    public final String RequesterMobilno{get;set;}
    public final String RcCopy{get;set;}
    public final String statename{get;set;}
    public final String MakerID{get;set;}
    public final String VehicleId{get;set;}
    public final String VehRegType{get;set;}
     /*
@Method:      IND_MFCValuationRequest
@Created by:  Divya Jawale
@Description: Contructor to initialize the details
@Param:       Id - opportunityId
@Return:      '' 
*/     
    public IND_MFCValuationRequest(RequestWrapper requestWrapper){
        Boolean isImplement = false;
        if(requestWrapper != null){
            Vehicle_Detail__c vehicleDetail = [select Id, Loan_Application__c,Loan_Application__r.Application_number__c,Loan_Application__r.Lead_Number__c,Loan_Application__r.Agent_BL_code__c,Loan_Application__r.Vehicle_Sub_Category__c,Vehicle_SubType__c,Vehicle_SubCategory__c,
           Loan_Application__r.Employee_Name__c,Loan_Application__r.Employee_No__c,Loan_Application__r.Product_Type__c, Loan_Application__r.Owner.Name,Loan_Application__r.Owner.MobilePhone,
                                               Loan_Application__r.Vehicle_Type__c,Purpose_of_purchase__c,Valuer_category__c,Valuer_code__c,Valuer__c,Vehicle_Place_Of_Valuation__c,
                                               Location_Of_Vehicle__c,City__c,Make__c,Model__c,Variant__c,Vehicle_Registration_number__c,Vehicle_type__c,Engine_number__c,Chassis_number__c,
                                               State__c, Product__c,Model_Code__c FROM Vehicle_Detail__c WHERE Loan_Application__c =:requestWrapper.loanApplicationId and id=:requestWrapper.vehicleId WITH SECURITY_ENFORCED LIMIT 1];
            
            List<Product2> product2 =  [Select variant_code__c from Product2 where name =:vehicleDetail.Variant__c and type__c = 'variant' WITH SECURITY_ENFORCED Limit 1]; 
            isImplement = vehicleDetail.Vehicle_SubType__c == 'Implement' ?  true : false;           
             if(!product2.isEmpty()){                       
                      requestWrapper.variantcode=product2[0].variant_code__c;
                    system.debug('variantcode'+requestWrapper.variantcode);                        
                    }
                    else{
                        throw new IND_Exception('Variant not found in product');                  
              }

              String likeClause = '%' + (vehicleDetail.Product__c)?.substring(0,3).toUpperCase()+'%';
              List<Product2> vehTypeQuery =  [Select ProductCode from Product2 
                            where name LIKE :likeClause and type__c = 'Class Of Vehicle' 
                            WITH SECURITY_ENFORCED Limit 1]; 

              if(vehTypeQuery.isEmpty()){ 
                throw new IND_Exception('Product not found in Product Master'); 
              }
            
            Applicant__c app = [SELECT Id,Contact_number__c,Customer_First_Name__c,Customer_Last_Name__c,Email_Id__c 
                                FROM Applicant__c WHERE Opportunity__c =: requestWrapper.loanApplicationId WITH SECURITY_ENFORCED Limit 1]; 
            
            if(vehicleDetail != null && app != null){
                this.Lead_Id = vehicleDetail.Loan_Application__r.Lead_Number__c == null ? '' :vehicleDetail.Loan_Application__r.Lead_Number__c;
                this.Branch = vehicleDetail.Loan_Application__r.Agent_BL_code__c == null ? '' : vehicleDetail.Loan_Application__r.Agent_BL_code__c;
                this.Productcode = vehicleDetail.Loan_Application__r.Product_Type__c == System.Label.TwoWheeler ?'H' : vehicleDetail.Loan_Application__r.Product_Type__c == System.Label.PassengerVehicles ?'C' : vehicleDetail.Loan_Application__r.Product_Type__c == System.Label.Tractor ? 'T' :'' ;
                this.ValuerCategory = requestWrapper.valuerCategory == null? '' :requestWrapper.valuerCategory=='MFC'?'FC':requestWrapper.valuerCategory; 
                this.ValuerCode = vehicleDetail.Valuer_code__c == null ? '' : vehicleDetail.Valuer_code__c;
                this.Valuer = vehicleDetail.Valuer__c == null ?'': vehicleDetail.Valuer__c;
                this.Purpose = 'F'; 
                this.PlaceOfInspection = requestWrapper.placeOfInspection == null ?'': requestWrapper.placeOfInspection;
                this.Location_of_Vehicle = requestWrapper.locationOfVehicle == null ?'': requestWrapper.locationOfVehicle;
                this.Application_Ref_Type = 'AP'; 
                this.Appl_Ref_Deal_No = vehicleDetail.Loan_Application__r.Application_number__c == null ? '' : vehicleDetail.Loan_Application__r.Application_number__c;
                this.CustomerName = app.Customer_First_Name__c == null ? '' : app.Customer_First_Name__c;
                this.ContactPerson = app.Customer_First_Name__c+' '+app.Customer_Last_Name__c;
                this.MobileNo = app.Contact_number__c == null ?'' : app.Contact_number__c;
                this.Emailid = app.Email_Id__c == null ? '' : app.Email_Id__c ;
                this.City= requestWrapper.city == null ?'': requestWrapper.city; 
                this.VehicleCatg= vehicleDetail.Loan_Application__r.Vehicle_Type__c; 
                if(vehicleDetail.Loan_Application__r.Product_Type__c == System.Label.Tractor){
                    this.VehicleSubCatg= vehicleDetail.Vehicle_SubCategory__c == null ? '' : vehicleDetail.Vehicle_SubCategory__c; 
                }else{
                    this.VehicleSubCatg= vehicleDetail.Loan_Application__r.Vehicle_Sub_Category__c == null ? '' : vehicleDetail.Loan_Application__r.Vehicle_Sub_Category__c; 
                }
                this.Makecode= vehicleDetail.Make__c == null ? '' : vehicleDetail.Make__c;
                if(vehicleDetail.Loan_Application__r.Product_Type__c == System.Label.Tractor){
                    this.Model= vehicleDetail.Model_Code__c == null ? '' :vehicleDetail.Model_Code__c; 
                }else{
                    this.Model= vehicleDetail.Model__c == null ? '' :vehicleDetail.Model__c; 
                }
                this.Variantcode= requestWrapper.variantcode;
                this.VehRegNo= vehicleDetail.Vehicle_Registration_number__c; 
                this.Vehtype= vehTypeQuery[0].ProductCode == 'H'  ?'1' : vehTypeQuery[0].ProductCode == 'S' ?'1': vehTypeQuery[0].ProductCode == 'C' ?'3' :vehTypeQuery[0].ProductCode == 'T' ? '5':'' ;
                this.EngineNo= vehicleDetail.Engine_number__c;
                this.ChasisNo= vehicleDetail.Chassis_number__c; 
                this.NameTransferred= '';
                this.CurrentVehicleOwner='';
                this.LienMaerkedIBL= '';
                this.MarkedOn= '';
                this.NowLienNameOf= '';
                this.RequesterName= vehicleDetail.Loan_Application__r.Owner.Name;
                this.RequesterMobilno= vehicleDetail.Loan_Application__r.Owner.MobilePhone;
                this.RcCopy= '';
                this.statename= requestWrapper.state == null ?'': requestWrapper.state;
                this.MakerID= IntegrationUtilities.getMakerId(); 
                this.VehicleId= requestWrapper.variantcode +'_V1';
                this.VehRegType= vehicleDetail.Loan_Application__r.Vehicle_Type__c;
            }
            else{
            throw new IND_Exception(System.Label.OpportunityIdMissing);
        }
        }
        else{
            throw new IND_Exception(System.Label.OpportunityIdMissing);
        }
        validate(System.Label.MFCValuationAPI,isImplement);
        
    }  
     /*Method to get the HTTP request header data
@Method:      getHttpRequestHeaders
@Created by:  Divya Jawale
@Description: Method to get the HTTP request header data
@Param:       ''
@Return:      Header required to callout the service.
*/
     public override Map<String,String> getHttpRequestHeaders(){    
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }
    
    /*Method to validate the request data
@Method:      validate
@Created by:  Divya Jawale
@Description: Method to validate the required input details
@Param:       Service name
@Return:      True - If all the validations are passed.
*/
    public override boolean validate(String serviceName,Boolean isImplement){
        List<String> errorMessageList = new List<String>();
        if(String.isBlank(this.Lead_Id)){
            throw new IND_Exception(System.Label.LeadId);
        }
        if(String.isBlank(this.Branch)){
            throw new IND_Exception(System.Label.Branch);
        }
        if(String.isBlank(this.Purpose)){
            throw new IND_Exception(System.Label.Purpose);
        }
        if(String.isBlank(this.PlaceOfInspection)){
            throw new IND_Exception(System.Label.PlaceOfInspection);
        }
        if(String.isBlank(this.Location_of_Vehicle)){
            throw new IND_Exception(System.Label.Location_of_Vehicle);
        }
        if(String.isBlank(this.Application_Ref_Type)){
            throw new IND_Exception(System.Label.Application_Ref_Type);
        }
        if(String.isBlank(this.Appl_Ref_Deal_No)){
            throw new IND_Exception(System.Label.Appl_Ref_Deal_No);
        }
        if(String.isBlank(this.CustomerName)){
            throw new IND_Exception(System.Label.CustomerName);
        }
        if(String.isBlank(this.ContactPerson)){
            throw new IND_Exception(System.Label.ContactPerson);
        }
        if(String.isBlank(this.MobileNo)){
            throw new IND_Exception(System.Label.EnterMobileNumber);
        }
        if(String.isBlank(this.City)){
            throw new IND_Exception(System.Label.City);
        }
        if(String.isBlank(this.VehicleCatg)){
            throw new IND_Exception(System.Label.VehicleCategory);
        }
        if(String.isBlank(this.VehicleSubCatg)){
            throw new IND_Exception(System.Label.VehicleSubCategory);
        }
        if(String.isBlank(this.Makecode)){
            throw new IND_Exception(System.Label.Makecode);
        }
        if(String.isBlank(this.Model)){
            throw new IND_Exception(System.Label.Model);
        }
        if(String.isBlank(this.Variantcode)){
            throw new IND_Exception(System.Label.VarientCode);
        }
        if(String.isBlank(this.EngineNo) && isImplement == false){
            throw new IND_Exception(System.Label.EngineNo);
        }
        if(String.isBlank(this.ChasisNo) && isImplement == false){
            throw new IND_Exception(System.Label.ChasisNo);
        }
        if(String.isBlank(this.RequesterName)){
            throw new IND_Exception(System.Label.RequesterName);
        }
        if(String.isBlank(this.RequesterMobilno)){
            throw new IND_Exception(System.Label.RequesterMobilno);
        }
        if(String.isBlank(this.MakerID)){
            throw new IND_Exception(System.Label.MakerID);
        }
        if(String.isBlank(this.VehicleId)){
            throw new IND_Exception(System.Label.VehicleId);
        }
        if(String.isBlank(this.VehRegType)){
            throw new IND_Exception(System.Label.VehRegType);
        }
        if(String.isBlank(this.statename)){
            throw new IND_Exception(System.Label.State);
        }
        if(String.isBlank(this.VehRegNo) && isImplement == false){
            throw new IND_Exception(System.Label.VehicleRegistrationNumber);
        }
        return true;
    }    
    
}