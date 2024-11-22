/*------------------------------------------------------------
 Author:        Poonam Tilokani
 Company:       Manras
 Description:   IND_InvoiceDetails is used to get and store Invoice Deatils.
 Apex Class :   IND_InvoiceDetails
 Test Class:    IND_InvoiceDetails_Test
------------------------------------------------------------*/

public with sharing class IND_InvoiceDetails {

    /*
    * @Method Name: getGSTTypeMetadataRecord
    * @Created by:  Poonam Tilokani
    * @description: to get a GST Type metadata record 
    * @Return:  List of GST_Type_Store__mdt
    */
@AuraEnabled
public static List<GST_Type_Store__mdt> getGSTTypeMetadataRecord(){
    try{
        List<GST_Type_Store__mdt> gstTypeStoreMdt = [SELECT Id, DeveloperName, MasterLabel, Label, GST_Type__c, IGST__c, UTGST__c, SGST__c, CGST__c, CESS__c FROM GST_Type_Store__mdt];
        if(gstTypeStoreMdt.size()>0){
            return gstTypeStoreMdt;
        }
        return null;
    }
    catch(Exception ex){
        ErrorLoggerUtil.logErrorEvent('IND_InvoiceDetails', 'getGSTTypeMetadataRecord', System.Label.Apex, ex);
        throw new IND_Exception(ex.getMessage());   
    }
}
  /*
    * @Method Name: getApplicantData
    * @Created by:  Poonam Tilokani
    * @description: This method is used to get Applicant record.
    * @param : Loan application Id 
    * @Return:  Applicant__c
    */
    
    @AuraEnabled 
    public static Applicant__c getApplicantData(String loanApplicationId){
        try{
            List<Applicant__c> applicantList = new List<Applicant__c>();
            applicantList = [Select id, Name,Applicant_Type__c,Opportunity__c from Applicant__c where Opportunity__c  =: loanApplicationId AND Applicant_Type__c='Borrower' WITH SECURITY_ENFORCED];
            if(applicantList.size()>0){
                return applicantList[0];
            }
            return null;
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_InvoiceDetails', 'getApplicantData', System.Label.Apex, ex,loanApplicationId);
            throw new IND_Exception(ex.getMessage());  
        }
    }
    /*
    * @Method Name: getLoanApplicationRecord
    * @Created by:  Poonam Tilokani
    * @description: This method is used to get a Loan appliaction record and check that logged in user same as the owner of record.
    * @param : Loan application Id 
    * @Return:  String
    */
    

@AuraEnabled
public static String getLoanApplicationRecord(String loanApplicationId){
    try{
        Map<String,Object> returnMap = new Map<String, Object>();
        
        List<Opportunity> loanApplicationList = [SELECT Id,Funding_on_Ex_Showroom__c,Funding_on_ORP__c,ownerId,Agent_BL_code__c ,Product_Type__c,StageName ,Vehicle_Type__c,Applicant__c, Basic_Price__c, GST_Amount__c, Discount_on_Basic_Price__c, Ex_showroom_price__c, Ex_showroom_price_carwale__c, RTO_Road_Tax__c, RTO_Road_Tax_New__c,Other_charges__c, On_Road_price__c, On_Road_price_carwale__c, X1st_yr_Insurance_Premium__c FROM 
                                                 Opportunity where Id=:loanApplicationId WITH SECURITY_ENFORCED];
        if(loanApplicationList.size()>0){
            returnMap.put('loanApplication',loanApplicationList[0]);
            User Usr =[SELECT Id,profile.name,userType FROM User WHERE Id = : UserInfo.getUserId()];
            if(loanApplicationList[0].ownerId == UserInfo.getUserId()){
                returnMap.put('isOwnerSame',true);
            }else{
                returnMap.put('isOwnerSame',false);
            }
            if(Usr.userType == 'PowerPartner'){
                returnMap.put('isCommunityUser',true);
            }else{
                returnMap.put('isCommunityUser',false);
            }
            return JSON.serialize(returnMap);
        }
        return null;
    }catch(Exception ex){
         ErrorLoggerUtil.logErrorEvent('IND_InvoiceDetails', 'getLoanApplicationRecord', System.Label.Apex, ex,loanApplicationId);
        throw new IND_Exception(ex.getMessage());  
    }
}
/*
    * @Method Name: getVehicleDetailsRecord
    * @Created by:  Poonam Tilokani
    * @description: to get a Vehicle Detail Record record
    * @param : Loan application Id 
    * @Return:  Vehicle_Detail__c
    */
@AuraEnabled
public static Vehicle_Detail__c getVehicleDetailsRecord(String loanApplicationId, String dealId){
    try{
        Opportunity loanApplicationDetails = new Opportunity();
        List<Vehicle_Detail__c> vehicleDetails = new List<Vehicle_Detail__c>();
        Opportunity opp = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED];
        system.debug('Opportunity :'+ opp.Id + 'dealId '+dealId);
        if(opp.Product_Type__c == 'Tractor'){
            vehicleDetails = [SELECT Id,Invoice_Price__c, Ben_Code__c,Engine_number__c, Chassis_number__c, Vehicle_Registration_number__c, Dealer_Sub_dealer_name__c,Loan_Application__r.Is_Revoked__c,
                                Finance_Amount__c,Make__c,Model__c,Variant__C,Vehicle_SubType__c,Serial_number__c,Model_Code__c, Vehicle_Delivered__c 
                                FROM Vehicle_Detail__c 
                                WHERE Loan_Application__c =: loanApplicationId AND Deal_Number__c =: dealId WITH SECURITY_ENFORCED LIMIT 1];
                                system.debug('vehicleDetails :'+vehicleDetails);
        }else{
            vehicleDetails = [SELECT Id,Ben_Code__c,Engine_number__c, Chassis_number__c, Vehicle_Registration_number__c, Dealer_Sub_dealer_name__c,Loan_Application__r.Is_Revoked__c,
            Finance_Amount__c,Make__c,Model__c,Variant__C,Serial_number__c,Vehicle_SubType__c, Vehicle_Delivered__c 
            FROM Vehicle_Detail__c 
            WHERE Loan_Application__c =: loanApplicationId WITH SECURITY_ENFORCED LIMIT 1];//CISP-2735
        }
        
        system.debug('vehicleDetails[0] :::'+ vehicleDetails[0]);
        if(vehicleDetails.size()>0){
            return vehicleDetails[0];
        }
        return null;
    }
    catch(Exception ex){
        ErrorLoggerUtil.logErrorEvent('IND_InvoiceDetails', 'getVehicleDetailsRecord', System.Label.Apex, ex,loanApplicationId);
        throw new IND_Exception(ex.getMessage());   
    }
}
/*
    * @Method Name: getInvoiceDetailsRecord
    * @Created by:  Poonam Tilokani
    * @description: This method is used to get Invoice Detail record.
    * @param : Loan application Id 
    * @Return:  Invoice_Details__c
    */
@AuraEnabled
public static Invoice_Details__c getInvoiceDetailsRecord(String loanApplicationId, String dealId){
    try{
        Opportunity opp = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED];
        Opportunity loanApplicationDetails = new Opportunity();
        List<Invoice_Details__c> invoiceDetails = new List<Invoice_Details__c>();
        if(opp.Product_Type__c == 'Tractor'){
            invoiceDetails = [SELECT Id,Tax_Invoice_No__c, Tax_Invoice_Date__c,CGST__c,SGST__c,UTGST__c,IGST__c,CESS__c,GST_Total__c,Is_Invoice_legible__c,Remarks__c,
                                Is_Invoice_date_correctly_captured__c,Tax_Collected_at_Source__c,Engine_No__c,Chassis_No__c,HSN_No__c,
                                GST_Type__c,Invoice_Amount_incl_discount__c,Invoice_Amount_incl_discounts__c,Is_Invoice_amount_correctly_captured__c,
                                Ex_showroom_prices__c,On_road_price__c,Is_Invoice_MMV_matching_with_above_MMV__c,Is_Invoice_amount_entered_above_as_per_I__c,
                                Do_you_accept_uploaded_invoice__c,Invoice_Uploaded_Remark__c,	Type_of_Invoice__c,Documents__c ,
                                Ben_Code_Of_Main_dealer__c,Main_Dealer__c,Payment_to_be_made__c, Serial_No__c, Invoice_Date__c, Invoice_Number__c
                                FROM Invoice_Details__c
                                WHERE Loan_Application__c =: loanApplicationId AND Deal_Number__c =: dealId WITH SECURITY_ENFORCED LIMIT 1];
        }else{
            invoiceDetails = [SELECT Id,Tax_Invoice_No__c, Tax_Invoice_Date__c,CGST__c,SGST__c,UTGST__c,IGST__c,CESS__c,GST_Total__c,Is_Invoice_legible__c,Remarks__c,
                                Is_Invoice_date_correctly_captured__c,Tax_Collected_at_Source__c,Engine_No__c,Chassis_No__c,HSN_No__c,
                                GST_Type__c,Invoice_Amount_incl_discount__c,Invoice_Amount_incl_discounts__c,Is_Invoice_amount_correctly_captured__c,
                                Ex_showroom_prices__c,On_road_price__c,Is_Invoice_MMV_matching_with_above_MMV__c,Is_Invoice_amount_entered_above_as_per_I__c,
                                Do_you_accept_uploaded_invoice__c,Invoice_Uploaded_Remark__c,	Type_of_Invoice__c,Documents__c ,
                                Ben_Code_Of_Main_dealer__c,Main_Dealer__c,Payment_to_be_made__c, Serial_No__c, Invoice_Date__c, Invoice_Number__c
                                FROM Invoice_Details__c
                                WHERE Loan_Application__c =: loanApplicationId WITH SECURITY_ENFORCED LIMIT 1];
        }

        if(invoiceDetails.size() == 0){
            Invoice_Details__c invoiceDetailsRecord = new Invoice_Details__c();
            invoiceDetailsRecord.Loan_Application__c = loanApplicationId;
            if(opp.Product_Type__c == 'Tractor'){
                invoiceDetailsRecord.Deal_Number__c = dealId;
            }
            insert invoiceDetailsRecord;
            return invoiceDetailsRecord;
        }else if(invoiceDetails.size()>0){
             return invoiceDetails[0];
        }
        return null;
    }
    catch(Exception ex){
        ErrorLoggerUtil.logErrorEvent('IND_InvoiceDetails', 'getInvoiceDetailsRecord', System.Label.Apex, ex,loanApplicationId);
        throw new IND_Exception(ex.getMessage());   
    }
}
   
    /*
    * @Method Name: updateTransactionRecord
    * @Created by:  Poonam Tilokani
    * @description: This method is used to update Loan Transaction History Record for Invoice Post Sanction module.
    * @param : Loan application Id 
    * @Return:  void
    */
@AuraEnabled
public static void updateTransactionRecord(String loanApplicationId, String dealId){
    try{
        List<Loan_Application_Transaction_History__c> lATList=[Select id,Name,Submitted_Flag__c from Loan_Application_Transaction_History__c where Loan_Application_ID__c=:loanApplicationId  and Screen__c='Invoice' And Module__c = 'Post Sanction Checks and Documentation' And Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
        if(lATList.size()>0){
            lATList[0].Submitted_Flag__c = true;
            update lATList;
        }
    }catch(Exception ex){
        ErrorLoggerUtil.logErrorEvent('IND_InvoiceDetails', 'updateTransactionRecord', System.Label.Apex, ex,loanApplicationId);
        throw new IND_Exception(ex.getMessage());   
    }
}
 /*
    * @Method Name: updateInvoiceDetail
    * @Created by:  Poonam Tilokani
    * @description: This method is used to update invoice detail and  Loan Transaction History Record for Invoice Post Sanction module.
    * @param : String - Loan application Id , String screen name , String module name , String submitted flag.
    * @Return:  void
    */
@AuraEnabled 
public static void updateInvoiceDetail(String loanApplicationId,String data,String screenName, String moduleName,Boolean submitFlg, String dealId){
    try{
       List<Invoice_Details__c> invoiceDetailList = (List<Invoice_Details__c>)JSON.deserialize(data, List<Invoice_Details__c>.class);
       for(Invoice_Details__c invoice :  invoiceDetailList){
            if(invoice.Type_of_Invoice__c == 'Performa Invoice' && invoice.Is_Invoice_date_correctly_captured__c != null && invoice.Is_Invoice_date_correctly_captured__c != ''){
                invoice.Is_Invoice_date_correctly_captured__c = '';
            }
       }
        if(invoiceDetailList.size()>0){
            Opportunity opp = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED];
            if(opp.Product_Type__c == 'Tractor'){
                for(Invoice_Details__c invoice :  invoiceDetailList){
                    invoice.Deal_Number__c = dealId;
                } 
            }
            upsert invoiceDetailList;
        }
        List<Loan_Application_Transaction_History__c> transactionRecords = [SELECT Id, Name, Module__c, Screen__c, Submitted_Flag__c, Loan_Application_ID__c 
                                                                            FROM Loan_Application_Transaction_History__c 
                                                                            where Loan_Application_ID__c =:loanApplicationId AND Screen__c =:screenName AND Module__c =:moduleName AND Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
        if(transactionRecords.size()>0){
            if(transactionRecords[0].Module__c == 'Pre Disbursement Check'){
                transactionRecords[0].Submitted_Flag__c = submitFlg;
            }else{
                transactionRecords[0].Submitted_Flag__c = submitFlg;
            }
            update transactionRecords;
        }

    }catch(Exception ex){
        ErrorLoggerUtil.logErrorEvent('IND_InvoiceDetails', 'updateInvoiceDetail', System.Label.Apex, ex,loanApplicationId);
        throw new IND_Exception(ex.getMessage());   
    }
}
    /*
    * @Method Name: checkIfReadOnly
    * @Created by:  Poonam Tilokani
    * @description: This method is used to check weather RTO,DPN screen submitted or not.
    * @param : String - Loan application Id.
    * @Return:  String
    */
@AuraEnabled
Public static String checkIfReadOnly(String loanApplicationId, String dealId){
    try{
        Map<String,Object> transactionRecords = new Map<String,Object>();
        List<Loan_Application_Transaction_History__c> lATList=[Select id,Name, Module__c, Screen__c, Submitted_Flag__c, Loan_Application_ID__c from Loan_Application_Transaction_History__c where Loan_Application_ID__c=:loanApplicationId And 
                                                               screen__c= 'RTO, DPN, POA Documents Upload' And 
                                                               Module__c = 'Post Sanction Checks and Documentation' And
                                                               Deal_Number__c =: dealId
                                                               WITH SECURITY_ENFORCED];
        if(lATList!=null && lATList.size()>0){
            transactionRecords.put('RTOSub',lATList[0].Submitted_Flag__c);
        }
        List<Loan_Application_Transaction_History__c> lATList1=[Select id,Name, Module__c, Screen__c, Submitted_Flag__c, Loan_Application_ID__c from Loan_Application_Transaction_History__c where Loan_Application_ID__c=:loanApplicationId And 
                                                               screen__c= 'Invoice' And 
                                                               Module__c = 'Post Sanction Checks and Documentation' And
                                                               Deal_Number__c =: dealId
                                                               WITH SECURITY_ENFORCED];
        if(lATList1!=null && lATList1.size()>0){
            transactionRecords.put('invoiceSub',lATList1[0].Submitted_Flag__c);
        }
        return JSON.serialize(transactionRecords);
    }catch(Exception ex){
        ErrorLoggerUtil.logErrorEvent('IND_InvoiceDetails', 'checkIfReadOnly', System.Label.Apex, ex);
        throw new IND_Exception(ex.getMessage()); 
    }
}
    /*
    * @Method Name: getBeneficaryDetail
    * @Created by:  Poonam Tilokani
    * @description: This method is used to get Beneficiary Master detail.
    * @param : String - Ben Code.
    * @Return:  Benefi__c
    */
@AuraEnabled
public static Benefi__c getBeneficaryDetail(String bencode){
    try{
        List<Benefi__c> benefiList = [SELECT Id, Ben_code__c, Beneficiary__c, Dealership_Nature__c, Name, Dealer_Code__c FROM Benefi__c
                                      WHERE Ben_code__c =: bencode WITH SECURITY_ENFORCED];
        if(benefiList.size()>0){
            return benefiList[0];
        }
        return null;
    }catch(Exception ex){
       ErrorLoggerUtil.logErrorEvent('IND_InvoiceDetails', 'getBeneficaryDetail', System.Label.Apex, ex);
        throw new IND_Exception(ex.getMessage());  
    }
}

    /*
    * @Method Name: getMfrBeneficaryDetail
    * @Created by:  Santhosh Guhan 
    * @description: This method is used to get Manufacturer Beneficiary detail.
    * @param : String - Ben Code.
    * @Return:  Beneficiary_Manufacturer__c
    */
    @AuraEnabled
    public static Beneficiary_Manufacturer__c getMfrBeneficaryDetail(String bencode, String modelcode){
        try{
            List<Beneficiary_Manufacturer__c> benefiList = [SELECT Id,Manufacturer__r.Name,Manufacturer_Ben_Code__c FROM Beneficiary_Manufacturer__c WHERE Manufacturer_Ben_Code__c!=null AND Beneficiary_Master__r.Ben_code__c =: bencode WITH SECURITY_ENFORCED];
            if(benefiList.size()>0){
                if(benefiList.size()==1)
                return benefiList[0];
                else{
                    List<Product2> prod = [Select Id,Manufacturer__r.Name FROM Product2 Where Model_Code__c=:modelcode];
                    system.debug('prod---'+prod);
                    for(Beneficiary_Manufacturer__c bm : benefiList){
                        if(bm.Manufacturer__r.Name == prod[0].Manufacturer__r.Name)
                            return bm;
                    }
                }
            }
            return null;
        }catch(Exception ex){
           ErrorLoggerUtil.logErrorEvent('IND_InvoiceDetails', 'getMfrBeneficaryDetail', System.Label.Apex, ex);
        throw new IND_Exception(ex.getMessage());  
    }
}
     /*
    * @Method Name: getMainDealerFromBenefiDetails
    * @Created by:  Poonam Tilokani
    * @description: This method is used to get Beneficiary Master Records according to Ben code that are same as Beneficiary BLCode records and product type that are same as
    * 				Beneficiary Product records.
    * @param : String - Ben Code, String Product Type
    * @Return:  List<Benefi__c>
    */
@AuraEnabled 
public static List<Benefi__c> getMainDealerFromBenefiDetails(String blCode , String productType){
    try{
        Set<Id> benCodeIds = new Set<Id>();
        List<Beneficiary_BlCode__c> beneficaryBLCodeList = [SELECT Id, Name, Ben_code__c,Ben_code__r.Name, Bl_Code_Details__c FROM Beneficiary_BlCode__c Where Bl_Code_Details__r.bl_code__c =: blCode WITH SECURITY_ENFORCED];
        System.debug('beneficaryBLCodeList--'+beneficaryBLCodeList);
        if(beneficaryBLCodeList.size() > 0){
            for(Beneficiary_BlCode__c blCodeData : beneficaryBLCodeList){
                benCodeIds.add(blCodeData.Ben_code__c);
            }
        }
        system.debug('benCodeIds---'+benCodeIds);
        List<Beneficiary_Product__c> productList = [SELECT Id, Name, Ben_code__c, Product__c FROM Beneficiary_Product__c Where Ben_code__c IN: benCodeIds AND Product__r.Name =: productType WITH SECURITY_ENFORCED];
        if(productList.size() > 0){
            system.debug('productList'+productList);
            benCodeIds = new Set<Id>();
            for(Beneficiary_Product__c productdata : productList){
                benCodeIds.add(productdata.Ben_code__c);
            }
        }
        system.debug('benCodeIds***'+benCodeIds);
        Map<Id,String> benefMap = new Map<Id,String>();
        List<Benefi__c> benefiDetailList = [SELECT Id, Name, Ben_code__c, Beneficiary__c, Dealership_Nature__c FROM Benefi__c
                                            Where Dealership_Nature__c In ('MDR','MFR') AND ID In : benCodeIds WITH SECURITY_ENFORCED];
        if(benefiDetailList.size()>0){
            return benefiDetailList;
        }
        return null;
    }catch(Exception ex){
        ErrorLoggerUtil.logErrorEvent('IND_InvoiceDetails', 'getMainDealerFromBenefiDetails', System.Label.Apex, ex);
        throw new IND_Exception(ex.getMessage()); 
    }
}
}