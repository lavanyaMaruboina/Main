/*------------------------------------------------------------
Author:        Daksh Mandowara
Class Name:    AmlCheckData
Description:   Used for generating deal number and customer code for IND_LWC_DealNumberGenerator LWC component. 
------------------------------------------------------------*/
public class DealNumberCustomerCode {
    /*
    * @Method Name: dnField1Increment
    * @Created by:  Daksh Mandowara
    * @description: For increment of First 3 letter of Deal number.  
    * @Param:       String - str
    * @return:      String - res
    */
    public static string dnField1Increment(string str) {
        Integer carry = 1;
        String res = '';
        try{
            for (Integer i = str.length() - 1; i >= 0; i--) {
                Integer charact = str.toUpperCase().charAt(i);
                charact += carry;
                if (charact > 90) {
                    charact = 65;
                    carry = 1;
                } else {
                    carry = 0;
                }
                List < Integer > chars = new List < Integer > {
                    charact
                };
                res = String.fromCharArray(chars) + res;
                if (carry == 0) {
                    res = str.substring(0, i) + res;
                    break;
                }
            }
            if (carry > 0) {
                res = 'A' + res;
            }
            return res;
        }catch(Exception ex){
                ErrorLoggerUtil.logErrorEvent('DealNumberCustomerCode', 'dnField1Increment', System.Label.Apex, ex);
                throw new AuraHandledException(ex.getMessage());
            }
        
    }

    /*
    * @Method Name: dealNumberGeneration
    * @Created by:  Daksh Mandowara
    * @description: For generating Deal Number.  
    * @Param:       void 
    * @return:      String - Deal Number
    */ 
    @AuraEnabled
    public static string dealNumberGeneration(String loanApplicationId, String assetDetailId) { 
        try{
            string newdealnumber;
            //CISP-2834 - START
            Opportunity Loanobj = [Select id, Deal_Number__c,Product_Type__c from Opportunity where id =: loanApplicationId WITH SECURITY_ENFORCED];
            List<Vehicle_Detail__c> vehicleList = new List<Vehicle_Detail__c>([Select Id,Deal_Number__c,Deal_Number__r.Deal_Number_Tractor__c from Vehicle_Detail__c Where Id=: assetDetailId]);
            if(Loanobj.Product_Type__c == Label.Tractor && vehicleList.size() > 0 && vehicleList[0].Deal_Number__c != null){
                newdealnumber = vehicleList[0].Deal_Number__r.Deal_Number_Tractor__c;
            }else if(String.isNotBlank(Loanobj.Deal_Number__c) && Loanobj.Product_Type__c != Label.Tractor){
                newdealnumber = Loanobj.Deal_Number__c;
            }else{
            //CISP-2834 - END
                String productCode = Loanobj.Product_Type__c == System.Label.TwoWheeler ? 'H' : Loanobj.Product_Type__c == System.Label.PassengerVehicles ? 'C' : Loanobj.Product_Type__c == System.Label.Tractor ? 'T' : '';

                List <Deal_Number__c> recentDealerNumber = [select id, DNField3__c from Deal_Number__c Where ProductCode__c =: productCode AND DNField3__c != null WITH SECURITY_ENFORCED order by Deal_No_Formula__c desc limit 1]; 

                boolean needToUpdateCustomSetting = false;
                Deal_Number__c dn = new Deal_Number__c(Loan_Application__c=loanApplicationId);
                insert dn;
                // fetch last auto dealnumber
                List <Deal_Number__c> autonumberlist = [select id, name, DNField1__c, DNField2__c, ProductCode__c, DNField3__c, Deal_Number__c from Deal_Number__c WHERE Id =: dn.Id WITH SECURITY_ENFORCED order by createdDate desc limit 1]; 
                Deal_Number_Setting__c dealNumberSetting = Deal_Number_Setting__c.getValues(Loanobj.Product_Type__c);
                for (Deal_Number__c autolist: autonumberlist) {
                    if (recentDealerNumber.size() == 0 || (recentDealerNumber.size() > 0 && Integer.valueof(recentDealerNumber[0].DNField3__c) == 99999)) {
                        if(autolist.DNField2__c == String.valueof(9)){
                            autolist.DNField1__c = dnField1Increment(autolist.DNField1__c); 
                            autolist.DNField2__c = '1';
                            needToUpdateCustomSetting = true;
                        } else if(recentDealerNumber.size() > 0){
                            autolist.DNField2__c = String.valueof(Integer.valueof(autolist.DNField2__c == null ? '0' : autolist.DNField2__c) + 1);
                            needToUpdateCustomSetting = true;
                        }
                        autolist.DNField3__c = '00001';
                    } else {
                        autolist.DNField3__c = String.valueof(Integer.valueof(recentDealerNumber[0].DNField3__c) + 1).leftPad(5, '0');
                    }
                    upsert autolist;
                    if (needToUpdateCustomSetting == true) {
                        dealNumberSetting.MDNField1__c = autolist.DNField1__c;
                        dealNumberSetting.MDNField2__c = Integer.valueof(autolist.DNField2__c);
                        update dealNumberSetting;
                    }
                        
                    newdealnumber = autolist.DNField1__c + autolist.DNField2__c + autolist.ProductCode__c + autolist.DNField3__c;
                }
                //SFTRAC-97
                if(productCode != 'T'){
                Loanobj.Deal_Number__c = newdealnumber;
                update Loanobj;
                }else if(productCode == 'T'){
                    DealNumberCustomerCode.updateAssetDealNumber(assetDetailId,newdealnumber);
                }
            }
            return newdealnumber;
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('DealNumberCustomerCode', 'dealNumberGeneration', System.Label.Apex, ex,loanApplicationId);
            throw new AuraHandledException(ex.getMessage());
        }
        
    }
	
    /*
    * @Method Name: updateMetaData
    * @Created by:  Daksh Mandowara
    * @description: update Customer Metadata
    * @Param:       Map<String> - fieldWithValuesMap
    */ 
    @future
    public static void updateMetaData(Map<String, String> fieldWithValuesMap){
        try{
            CustomMetadataUtils.updateCustomMetadata('DealNumber_Setting__mdt', 
                                                 'Deal_Number', 
                                                 'Deal Number', 
                                                 fieldWithValuesMap);
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('DealNumberCustomerCode', 'updateMetaData', System.Label.Apex, ex);
            throw new AuraHandledException(ex.getMessage());
        }
        
    }
      
	
    /*
    * @Method Name: UpdateDealCustomer
    * @Created by:  Daksh Mandowara
    * @description: update deal in loanapplication and applicants
    * @Param:       String - opportunityId
    */ 
    @AuraEnabled
    public static void UpdateDealCustomer(String opportunityId){
        try{
            Map<String,Loan_Application_Transaction_History__c> historyMap = new Map<String,Loan_Application_Transaction_History__c>();
            for(Loan_Application_Transaction_History__c history : [Select id, Name, Submitted_Flag__c, Screen__c, Deal_Number__c from Loan_Application_Transaction_History__c 
                                                                   where Loan_Application_ID__c =: opportunityId AND Module__c = 'Post Sanction Checks and Documentation' WITH SECURITY_ENFORCED]){
                                                                       historyMap.put(history.Screen__c, history);
                                                                   }
                List<Loan_Application_Transaction_History__c> tansactionHistory = new List<Loan_Application_Transaction_History__c>();
                Opportunity Loanobj = [Select id, Deal_Number__c, Product_Type__c,Vehicle_Type__c,Sanction_Status__c from Opportunity where id =: opportunityId WITH SECURITY_ENFORCED];
                if(Loanobj.Product_Type__c == System.Label.Tractor){
                    IND_VehicleInspectionRCLimitDetails.checkFinalTermRecords(opportunityId);
                }
                LoanObj.StageName = 'Post Sanction Checks and Documentation';
                update LoanObj;
                List<Deal_Number__c> dealNumberLst = [SELECT Id FROM Deal_Number__c WHERE Loan_Application__c =:Loanobj.Id WITH SECURITY_ENFORCED];

                Map<Id,Id> dealVehicleMap = new Map<Id,Id>();
                for(Vehicle_Detail__c veh :[SELECT Id, Deal_Number__c FROM Vehicle_Detail__c WHERE Loan_Application__c =:Loanobj.Id WITH SECURITY_ENFORCED ]){
                    dealVehicleMap.put(veh.Deal_Number__c,veh.Id);
                }
                Map<Id,List<Final_Term__c>> dealFinalTermMap = new Map<Id,List<Final_Term__c>>();
                for(Deal_Number__c deal: dealNumberLst){
                    if(dealVehicleMap.containsKey(deal.Id)){
                        List<Final_Term__c> finalList = [SELECT Id, Loan_Amount__c, Installment_Type__c ,Vehicle_Detail__r.Vehicle_Delivered__c,Vehicle_Detail__r.Vehicle_type__c,L1_L2_Final_Terms_Changed__c
                                                            FROM Final_Term__c 
                                                            WHERE Loan_Application__c =: Loanobj.Id AND Vehicle_Detail__c =: dealVehicleMap.get(deal.Id)
                                                            WITH SECURITY_ENFORCED limit 1];
                        dealFinalTermMap.put(deal.Id,finalList);
                    }
                }
                
                for(Webapp_Tab_Settings__mdt tab : [SELECT Stage__c, Sub_Stage__c,Vehicle_Category__c 
                                            FROM Webapp_Tab_Settings__mdt 
                                            WHERE Stage__c = 'Post Sanction Checks and Documentation' 
                                            AND Vehicle_Category__c = :Loanobj.Vehicle_Type__c
                                            AND Product_Type__c = :Loanobj.Product_Type__c
                                            AND Sanction_Status__c = :Loanobj.Sanction_Status__c
                                            ORDER BY Tab_Sequence__c]){
                    
                    Loan_Application_Transaction_History__c lth = new Loan_Application_Transaction_History__c();

                    if(Loanobj.Product_Type__c == System.Label.Tractor){
                       // IND_VehicleInspectionRCLimitDetails.checkFinalTermRecords(opportunityId);
                        for(Id dealId: dealVehicleMap.KeySet()){
                            lth = getLoanApplicationTransactionHistoryRec(opportunityId, tab, dealId,Loanobj.Product_Type__c,dealFinalTermMap.get(dealId));
                            if(historyMap.containsKey(lth.Screen__c) && historyMap.get(lth.Screen__c) !=null && historyMap.get(lth.Screen__c).Deal_Number__c == dealId){
                                lth.Id = historyMap.get(lth.Screen__c).Id;
                            }
                            tansactionHistory.add(lth);
                        }
                    }else{
                        List<Final_Term__c> finalTermList = [SELECT Id, Loan_Amount__c, Installment_Type__c FROM Final_Term__c WHERE Loan_Application__c =: Loanobj.Id WITH SECURITY_ENFORCED limit 1];
                        lth = getLoanApplicationTransactionHistoryRec(opportunityId, tab, '', Loanobj.Product_Type__c,finalTermList);
                        if(historyMap.containsKey(lth.Screen__c) && historyMap.get(lth.Screen__c) !=null){
                            lth.Id = historyMap.get(lth.Screen__c).Id;
                        }
                        tansactionHistory.add(lth);
                    }
                }
                    if(!tansactionHistory.isEmpty()){
                        upsert tansactionHistory;
                    }
            }catch(Exception ex){
                ErrorLoggerUtil.logErrorEvent('DealNumberCustomerCode', 'UpdateDealCustomer', System.Label.Apex, ex, opportunityId);
                throw new AuraHandledException(ex.getMessage());
            }
    }
	 public static Boolean getLoanAmountfromFO(String loanApplicationId, String dealId, String productType, List<Final_Term__c> finalTerms){

        try{
            List<Final_Term_Loan_Amount__mdt>  finalTeramLoanList = [SELECT Id, DeveloperName, MasterLabel, Loan_Amount__c FROM Final_Term_Loan_Amount__mdt WITH SECURITY_ENFORCED LIMIT 1];
            // List<Final_Term__c> finalTerms = new List<Final_Term__c>();
            // if(productType == System.Label.Tractor){
            //     List<Vehicle_Detail__c> VehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
            //     finalTerms = [SELECT Id, Loan_Amount__c 
            //                     FROM Final_Term__c 
            //                     WHERE Loan_Application__c =: loanApplicationId AND Vehicle_Detail__c =: VehicleLst[0].Id
            //                     WITH SECURITY_ENFORCED limit 1];
            // }else{
            //     finalTerms = [SELECT Id, Loan_Amount__c 
            //                     FROM Final_Term__c 
            //                     WHERE Loan_Application__c =: loanApplicationId 
            //                     WITH SECURITY_ENFORCED limit 1];
            // }
            if(finalTerms.size()>0){
                if(finalTerms[0].Loan_Amount__c == null || finalTerms[0].Loan_Amount__c == ''){
                    return false;
                }
                Integer loanAmount = Integer.valueOf(finalTerms[0].Loan_Amount__c);
                system.debug('loanAmount ::' + loanAmount);
                
                return (loanAmount >= finalTeramLoanList[0].Loan_Amount__c);
            }else{
                return false;
            }
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_VehicleInspectionRCLimitDetails', 'getLoanAmountfromFO', System.Label.Apex, ex,loanApplicationId);
            throw new IND_Exception(ex.getMessage());   
        }
        
    }

    public static Boolean getValidApplicants(String loanApplicationId){

        try{

            List<Applicant__c> applicants=[select Id,Name, Applicant_Type__c,Who_will_repay_the_loan__c,Scorecard_Decision__c, Gender__c, Journey_Stage__c, Contact_number__c
            from Applicant__c where Opportunity__c = :loanApplicationId WITH SECURITY_ENFORCED];

            List<Applicant__c> validApplicants = new List<Applicant__c>();
            if(applicants.size()>0){
                for(Applicant__c applicant : applicants){
                    if(applicant.Who_will_repay_the_loan__c != applicant.Applicant_Type__c){
                        continue;
                    }else if(applicant.Scorecard_Decision__c == 'Orange'){
                        return true;
                    }
                }
            }
            return false;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_VehicleInspectionRCLimitDetails', 'getValidApplicants', System.Label.Apex, ex,loanApplicationId);
            throw new IND_Exception(ex.getMessage());   
        }
    }
    
    /*
    * @Method Name: getLoanApplicationTransactionHistoryRec
    * @Created by:  Daksh Mandowara
    * @description: update deal in loanapplication and applicants
    * @Param:       Id - opportunityId
    */
    @TestVisible
    private static Loan_Application_Transaction_History__c getLoanApplicationTransactionHistoryRec(Id opportunityId, Webapp_Tab_Settings__mdt tab, String dealId, String productType, List<Final_Term__c> finalList ){
        Boolean isLoanAmountApplicable = getLoanAmountfromFO(opportunityId, dealId, productType, finalList);
        Boolean isApplicantValid = getValidApplicants(opportunityId);
        // Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:opportunityId WITH SECURITY_ENFORCED];
 		//List<Applicant__c> applicantDetails = new List<Applicant__c>();
      	//applicantDetails = [SELECT Id, Name,Would_you_like_to_open_a_bank_account__c, Willing_to_open_Bank_Account_with_IIB__c FROM Applicant__c WHERE Opportunity__c = :opportunityId AND Who_will_repay_the_loan__c != NULL WITH SECURITY_ENFORCED];    
        List<Final_Term__c> finalTerms= new List<Final_Term__c>();
        for(Final_Term__c fin: finalList){
            if(fin.Installment_Type__c == 'Structured'){
                finalTerms.add(fin);
            }
        }
        // if(productType == System.Label.Tractor){
        //     List<Vehicle_Detail__c> VehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
        //     finalTerms = [SELECT Installment_Type__c 
        //                     FROM Final_Term__c 
        //                     WHERE Loan_Application__c = :opportunityId AND Installment_Type__c='Structured' AND Vehicle_Detail__c =: VehicleLst[0].Id
        //                     WITH SECURITY_ENFORCED LIMIT 1];
        // }else{
        //     finalTerms = [SELECT Installment_Type__c 
        //                     FROM Final_Term__c 
        //                     WHERE Loan_Application__c = :opportunityId AND Installment_Type__c='Structured' 
        //                     WITH SECURITY_ENFORCED LIMIT 1];
        // }
        Loan_Application_Transaction_History__c lth = new Loan_Application_Transaction_History__c();
        lth.Module__c = tab.Stage__c;
        lth.Module_Name__c = tab.Stage__c;
        lth.Screen__c = tab.Sub_Stage__c;
        lth.Submitted_Flag__c = false;
        try{
            if(tab.Sub_Stage__c.equals('RTO, DPN, POA Documents Upload')){
                //lth.Submitted_Flag__c = true;
            }else if(tab.Sub_Stage__c.equals('Vehicle Inspection and RC Check') && (((tab.Vehicle_Category__c.equals('New')|| isLoanAmountApplicable == false || isApplicantValid == false) && productType != System.Label.Tractor) || (productType == System.Label.Tractor && finalList.size() > 0 && finalList[0].Vehicle_Detail__r.Vehicle_Delivered__c == 'NO' && finalList[0].Vehicle_Detail__r.Vehicle_type__c == 'New' && productType == System.Label.Tractor))){ //SFTRAC-99
                lth.Submitted_Flag__c = true;
            }else if(tab.Sub_Stage__c.equals('Invoice') && (tab.Vehicle_Category__c.equals('Used') || tab.Vehicle_Category__c.equals('Refinance'))){
                lth.Submitted_Flag__c = true;
            }
            // SFTRAC-100 Added Tractor check for Structured emi Screen : Sahil
            else if((productType != System.Label.Tractor && finalTerms.isEmpty() && tab.Sub_Stage__c.equals('Structured EMI')) || (productType == System.Label.Tractor && tab.Sub_Stage__c.equals('Structured EMI') && finalList[0].L1_L2_Final_Terms_Changed__c == false)){
                lth.Submitted_Flag__c = true;
            }
            lth.Loan_Application_ID__c = opportunityId;
            lth.Name = tab.Sub_Stage__c;
            lth.Type__c = 'Module';
            if(productType == System.Label.Tractor){
                lth.Deal_Number__c = dealId;
            }
            return lth;
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('DealNumberCustomerCode', 'getLoanApplicationTransactionHistoryRec', System.Label.Apex, ex, opportunityId);
            throw new AuraHandledException(ex.getMessage());
        }
        
    }
    

    /*
    * @Method Name: getDistrictOptions
    * @Created by:  Daksh Mandowara
    * @description: update deal in loanapplication and applicants
    * @Param:       String - state
    */
    @AuraEnabled(cacheable=true)
    public static String getDistrictOptions(string state){
        try{
            List<District_Master__c> districts = [SELECT Id,Name FROM District_Master__c WHERE Geo_State_Master__r.Name = :state];
        JSONGenerator jsonGen = JSON.createGenerator(true);
        jsonGen.writeStartArray();
        if(!districts.isEmpty()){
            for(District_Master__c district : districts){
                jsonGen.writeStartObject();
                jsonGen.writeStringField('label',district.Name);
                jsonGen.writeStringField('value',district.Name);
                jsonGen.writeEndObject();
            }
        }
        jsonGen.writeEndArray();
        return jsonGen.getAsString();
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('DealNumberCustomerCode', 'getDistrictOptions', System.Label.Apex, ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    

    /*
    * @Method Name: getLoanApplicantDetails
    * @Created by:  Daksh Mandowara
    * @description: update deal in loanapplication and applicants
    * @Param:       String - loanApplicationId
    */
    @AuraEnabled
    public static List<Applicant__c> getLoanApplicantDetails(string loanApplicationId){
        try{
            List<Applicant__c> applicants = [SELECT Id,Name,Opportunity__r.LeadSource,Applicant_Type__c,IND_Customer_Master_Updation_Status__c,IND_Customer_Master_Creation_Status__c,Religion__c,Caste__c,Bank_Account_No__c,Customer_Code__c,Opportunity__c,Opportunity__r.Deal_Number__c,Opportunity__r.Product_Type__c,Opportunity__r.Customer_Type__c,Opportunity__r.StageName,Opportunity__r.IsReferenceAndRelationApiCalled__c,(SELECT Id,Customer_Code__c from Customer_Dedupe_Response__r),(SELECT Id,KYC_State__c,KYC_District__c,KYC_City__c  FROM Documents__r WHERE Proof_of_Address_POA__c = TRUE AND KYC_State__c != NULL LIMIT 1) FROM Applicant__c WHERE Opportunity__c = :loanApplicationId AND In_Active_Applicant__c = FALSE];//CISP-4263
        if(!applicants.isEmpty()){
            return applicants;
        }
        
        return null;
        } catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('DealNumberCustomerCode', 'getLoanApplicantDetails', System.Label.Apex, ex,loanApplicationId);
            throw new AuraHandledException(ex.getMessage());
        }        
    }
    @AuraEnabled(cacheable=true) 
    public static Boolean hasForm60Document(String applicantId) {
        Boolean form60Found = false;
    
        try {
            List<Documents__c> docs = [
                SELECT Id, Document_Type__c
                FROM Documents__c
                WHERE Applicant__c = :applicantId
            ];
    
            for (Documents__c doc : docs) {
                if (doc.Document_Type__c != null && doc.Document_Type__c.equalsIgnoreCase('Form 60')) {
                    form60Found = true;
                    break;
                }
            }
        } catch (Exception ex) {
            System.debug('Error in hasForm60Document method: ' + ex.getMessage());
            ErrorLoggerUtil.logErrorEvent('DealNumberCustomerCode', 'getLoanApplicantDetails', System.Label.Apex, ex, applicantId); 
            throw new AuraHandledException(ex.getMessage());
        }        
    
        return form60Found; 
    } 
    
    //CISP-16280
    @AuraEnabled
    public static String getOppIdFromCase(string caseId){
        try{
            List<Case> caseList = [SELECT Id,Loan_Application__c from Case where Id =:caseId  WITH SECURITY_ENFORCED];//CISP-4263
        if(!caseList.isEmpty()){
            return caseList[0].Loan_Application__c;
        }
        
        return null;
        } catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('DealNumberCustomerCode', 'getOppIdFromCase', System.Label.Apex, ex,'');
            throw new AuraHandledException(ex.getMessage());
        }        
    }

    /*
    * @Method Name: getProductType
    * @Created by:  Santhosh Guhan 
    * @description: get product type details
    * @User Story: US-395
    * @Param:       String - loanApplicationId
    */
    @AuraEnabled
    public static String getProductType(string loanApplicationId){
        try{
            String productType;
            List<Opportunity> opps = [SELECT Id,Product_Type__c FROM Opportunity WHERE Id = :loanApplicationId WITH SECURITY_ENFORCED];
        if(!opps.isEmpty()){
            productType = opps[0].Product_Type__c;
            return productType;
        }
        return null;
        } catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('DealNumberCustomerCode', 'getProductType', System.Label.Apex, ex,loanApplicationId);
            throw new AuraHandledException(ex.getMessage());
        }        
    }

    // //CISP-16280
    // @AuraEnabled
    // public static String getOppIdFromCase(string caseId){
    //     try{
    //         List<Case> caseList = [SELECT Id,Loan_Application__c from Case where Id =:caseId  WITH SECURITY_ENFORCED];//CISP-4263
    //     if(!caseList.isEmpty()){
    //         return caseList[0].Loan_Application__c;
    //     }
        
    //     return null;
    //     } catch(Exception ex){
    //         ErrorLoggerUtil.logErrorEvent('DealNumberCustomerCode', 'getOppIdFromCase', System.Label.Apex, ex,'');
    //         throw new AuraHandledException(ex.getMessage());
    //     }        
    // }

    @AuraEnabled
    public static List<Applicant__c> getCoborrowerGrtDetails(string loanApplicantId){
        try{
          List<Applicant__c> applicants = [SELECT Id,Name,Applicant_Type__c,IND_Customer_Master_Updation_Status__c,IND_Customer_Master_Creation_Status__c,Religion__c,Caste__c,Bank_Account_No__c,Customer_Code__c,Opportunity__c,Opportunity__r.Deal_Number__c,Opportunity__r.StageName,(SELECT Id,Customer_Code__c from Customer_Dedupe_Response__r),(SELECT Id,KYC_State__c,KYC_District__c FROM Documents__r WHERE Proof_of_Address_POA__c = TRUE AND KYC_District__c != NULL LIMIT 1)
          FROM Applicant__c WHERE Id =:loanApplicantId AND In_Active_Applicant__c = FALSE WITH SECURITY_ENFORCED];
        if(!applicants.isEmpty()){
            return applicants;
        }
        
        return null;
        } catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('DealNumberCustomerCode', 'getCoborrowerGrtDetails', System.Label.Apex, ex,loanApplicantId);
            throw new AuraHandledException(ex.getMessage());
        }        
    }

    @AuraEnabled
    public static void updateReferenceAndRelationFieldOnOpp(string loanApplicationId){
        try{
            List<Opportunity> oppList = [SELECT ID ,IsReferenceAndRelationApiCalled__c from Opportunity Where ID =:loanApplicationId LIMIT 1 ];

            if(!oppList.isEmpty()){
                oppList[0].IsReferenceAndRelationApiCalled__c = true;
                update oppList;
            }
            
        } catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('DealNumberCustomerCode', 'IsReferenceAndRelationApiCalled__c', System.Label.Apex, ex,loanApplicationId);
            throw new AuraHandledException(ex.getMessage());
        }        
    }
    /*
    * @Method Name: getAssetDetails
    * @Created by:  Santhosh Guhan 
    * @description: get asset details as part of SFTRAC -97
    * @Param:       String - loanApplicationId
    */
    @AuraEnabled
    public static List<Vehicle_Detail__c> getAssetDetails(string loanApplicationId){
        try{
          List<Vehicle_Detail__c> vechileDetails = [SELECT Id,Make__c, Model__c, Variant__c, Deal_Number__c, Deal_Number__r.Deal_Number__c,Deal_Number__r.Deal_Number_Tractor__c from Vehicle_Detail__c WHERE Loan_Application__c =: loanApplicationId AND Approval_Status__c = 'Approved' WITH SECURITY_ENFORCED ORDER BY CreatedDate ASC];
         System.debug('vechiledetails------'+vechileDetails);
          if(!vechileDetails.isEmpty()){
           // return JSON.serialize(vechileDetails);
           return vechileDetails;
        }
        return null;
        } catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('DealNumberCustomerCode', 'getAssetDetails', System.Label.Apex, ex,loanApplicationId);
            throw new AuraHandledException(ex.getMessage());
        }        
    }
    /*
    * @Method Name: updateApplicantCustomerCode
    * @Created by:  Daksh Mandowara
    * @description: To update applicant customer code.  
    * @Return:      void 
    * @Param:       String - Applicant Id, Customer Code, Religion, Caste, Proof of Address Document Id
    */ 
    @AuraEnabled
     public static void updateApplicantCustomerCode(String loanApplicationId,String applicantId,String customerCode,String religion,String caste,String district, String POADocumentId, Boolean customerMasterStatus, Boolean customerCreationStatus) {
        try{
            List<Applicant__c> applicants = [SELECT Id,Customer_Code__c FROM Applicant__c WHERE Id = :applicantId];
            List <Documents__c> documents = New List <Documents__c> ();
            SYstem.debug(applicants);
            SYstem.debug(documents);
            if(!applicants.isEmpty()){
                
                if(String.isNotBlank(customerCode)){
                    for(Applicant__c appl : applicants){
                        appl.Customer_Code__c = customerCode;
                        appl.Religion__c = religion;
                        appl.Caste__c = caste;
                        appl.IND_Customer_Master_Updation_Status__c = customerMasterStatus;
                        
                        //CISP-5382
                        if(!customerCreationStatus){
                        appl.IND_Customer_Master_Creation_Status__c = true;
                    }
                        if(String.isNotBlank(POADocumentId) && String.isNotBlank(district)){
                            Documents__c doc = new Documents__c();
                            doc.Id = POADocumentId;
                            doc.KYC_District__c = district;
                            documents.add(doc);
                        }
                    }
                    if(!documents.isEmpty()){
                        update documents;
                    }
                    update applicants;
                }
            }
        } catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('DealNumberCustomerCode', 'updateApplicantCustomerCode', System.Label.Apex, ex,loanApplicationId);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    @AuraEnabled 
    public static void updateStatusFlags(String loanApplicationId,String applicantId) { 
        try{
            List<Applicant__c> applicants = [SELECT Id,Customer_Code__c FROM Applicant__c WHERE Id = :applicantId]; 
            if(!applicants.isEmpty()){
                    for(Applicant__c appl : applicants){
                        appl.IND_Customer_Master_Updation_Status__c = false;
                        appl.IND_Customer_Master_Creation_Status__c = false;
                    }
                    update applicants; 
                
            }
        } catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('DealNumberCustomerCode', 'updateApplicantCustomerCode', System.Label.Apex, ex,loanApplicationId);
            throw new AuraHandledException(ex.getMessage());
        }
    } 
    
    /*
    * @Method Name: updateAssetDealNumber
    * @Created by:  Santhosh Guhan 
    * @description: To update asset deal number as part of SFTRAC-97
    * @Return:      void 
    * @Param:       String - Asset Id, Deal Number
    */ 
    @AuraEnabled
     public static void updateAssetDealNumber(String assetId,String DealNum) {
        try{
            List<Vehicle_Detail__c> assetDetails = [SELECT Id,Deal_Number__c FROM Vehicle_Detail__c WHERE Id = :assetId];
            List<Deal_Number__c> dealnumber = [SELECT Id FROM Deal_Number__c WHERE Deal_Number__c =: DealNum LIMIT 1];
            if(!assetDetails.isEmpty()){
                if(String.isNotBlank(DealNum)){
                    for(Vehicle_Detail__c vd : assetDetails){
                        vd.Deal_Number__c = dealnumber[0].Id;
                    }
                    }
                    update assetDetails;
                }
            
             } catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('AssetDetailDealNumberUpdate', 'updateAssetDealNumber', System.Label.Apex, ex,assetId);
            throw new AuraHandledException(ex.getMessage());
        }
    }    
        /*
    * @Method Name: getNomineeDetails
    * @Created by:  Rajat Jaiswal
    * @description: Update Nominee Details for Borrower and Coborrower
    * @Param:       String - loanApplicationId
    */
    @AuraEnabled
    public static String getNomineeDetails(string loanApplicationId){
        try{
            if(loanApplicationId != null){
                List<Opportunity> loanAppList = [SELECT Id, Product_Type__c from Opportunity WHERE Id =: loanApplicationId WITH SECURITY_ENFORCED LIMIT 1];
                if (loanAppList.size() > 0 && loanAppList[0].Product_Type__c == 'Passenger Vehicles') {
                    String bankAccountOpeningFor;
                    List<Applicant__c> applicants = new List<Applicant__c>();
                    List<Applicant__c> proposalList = [SELECT Who_will_repay_the_loan__c FROM Applicant__c WHERE Opportunity__c =: loanApplicationId AND Who_will_repay_the_loan__c != null AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED];
                    if (proposalList.size() > 0 && proposalList[0].Who_will_repay_the_loan__c!=null) {
                        bankAccountOpeningFor = proposalList[0].Who_will_repay_the_loan__c;
                        applicants = [SELECT Id,Would_you_like_to_open_a_bank_account__c, Opportunity__r.Name,Applicant_Type__c,In_Active_Applicant__c, Willing_to_open_Bank_Account_with_IIB__c FROM Applicant__c WHERE  Opportunity__c =: loanApplicationId AND In_Active_Applicant__c = FALSE AND Would_you_like_to_open_a_bank_account__c = true AND Applicant_Type__c =: bankAccountOpeningFor WITH SECURITY_ENFORCED ORDER BY Applicant_Type__c LIMIT 1];
                    }
                    if (applicants.size() > 0) {
                        NomineeWrapper wrapperObj = new NomineeWrapper();
                        wrapperObj.applicantId = applicants[0].Id;
                        wrapperObj.applicantType = applicants[0].Applicant_Type__c;
                        List<TeleVerification__c> teleVerificationList = [SELECT Id, Applicant__c, Finacle_City__c, Finacle_City__r.Name, Office_Address_Finacle_City__c,Office_Address_Finacle_City__r.Name, Permanent_Address_Finacle_City__c, Permanent_Address_Finacle_City__r.Name FROM TeleVerification__c WHERE Applicant__c = :wrapperObj.applicantId WITH SECURITY_ENFORCED LIMIT 1];
                        if (teleVerificationList.size() > 0) {
                            wrapperObj.tvrId = teleVerificationList[0].Id;
                            wrapperObj.residenceCityFinacleId = teleVerificationList[0].Finacle_City__c == null? '' : teleVerificationList[0].Finacle_City__c;
                            wrapperObj.residenceCityFinacle = teleVerificationList[0].Finacle_City__r.Name == null? '' : teleVerificationList[0].Finacle_City__r.Name;
                            wrapperObj.permanentFinacleId = teleVerificationList[0].Permanent_Address_Finacle_City__c == null? '' : teleVerificationList[0].Permanent_Address_Finacle_City__c;
                            wrapperObj.permanentFinacle = teleVerificationList[0].Permanent_Address_Finacle_City__r.Name == null? '' : teleVerificationList[0].Permanent_Address_Finacle_City__r.Name;
                            wrapperObj.officeCityFinacleId = teleVerificationList[0].Office_Address_Finacle_City__c == null? '' : teleVerificationList[0].Office_Address_Finacle_City__c;
                            wrapperObj.officeCityFinacle = teleVerificationList[0].Office_Address_Finacle_City__r.Name == null? '' : teleVerificationList[0].Office_Address_Finacle_City__r.Name;
                        }
                        List<CASA_Bank_Form__c> caseBankList = [SELECT Id,Applicant__c,Applicant__r.Would_you_like_to_open_a_bank_account__c,
                        Applicant__r.Applicant_Type__c,Loan_Application__c,Nominee_address__c,Nominee_available__c,Nominee_City__c,Nominee_DOB__c,
                        Nominee_name__c,Nominee_Pin_Code__c,Nominee_State__c,Relationship_with_borrower__c,Saving_Account_opened_for__c,
                        Saving_Account_opening_form_No__c,TeleVerification__c, Finacle_City__c, Finacle_City__r.Name, Geo_State_Master__c, Geo_State_Master__r.Name from CASA_Bank_Form__c WHERE Applicant__c=:wrapperObj.applicantId LIMIT 1];
                        if (caseBankList.size() > 0) {
                            wrapperObj.casabankId = caseBankList[0].Id;
                            wrapperObj.nomineeSAAccountOpening = caseBankList[0].Saving_Account_opening_form_No__c == null? '' : caseBankList[0].Saving_Account_opening_form_No__c;
                            wrapperObj.nomineeSAAccountOpenedFor = caseBankList[0].Saving_Account_opened_for__c == null? '' : caseBankList[0].Saving_Account_opened_for__c;
                            wrapperObj.nomineeName = caseBankList[0].Nominee_name__c == null? '' : caseBankList[0].Nominee_name__c;
                            wrapperObj.nomineeAddress = caseBankList[0].Nominee_address__c == null? '' : caseBankList[0].Nominee_address__c;
                            wrapperObj.nomineeAvailable = caseBankList[0].Nominee_available__c == null? false : caseBankList[0].Nominee_available__c;
							wrapperObj.nomineeCityId = caseBankList[0].Finacle_City__c == null? '' : caseBankList[0].Finacle_City__c;
                            wrapperObj.nomineeCity = caseBankList[0].Finacle_City__r.Name == null? '' : caseBankList[0].Finacle_City__r.Name;
                            wrapperObj.nomineeDOB = caseBankList[0].Nominee_DOB__c;
                            wrapperObj.nomineePinCode = caseBankList[0].Nominee_pin_code__c == null? '' : String.valueOf(caseBankList[0].Nominee_pin_code__c);
						    wrapperObj.nomineeStateId = caseBankList[0].Geo_State_Master__c == null? '' : caseBankList[0].Geo_State_Master__c;
                            wrapperObj.nomineeState = caseBankList[0].Geo_State_Master__r.Name == null? '' : caseBankList[0].Geo_State_Master__r.Name;
                            wrapperObj.nomineeRelationshipBorrower = caseBankList[0].Relationship_with_borrower__c == null? '' : caseBankList[0].Relationship_with_borrower__c;
                        }
                        return JSON.serialize(wrapperObj);
                    }else{
                        return loanAppList.size() > 0 ? loanAppList[0].Product_Type__c : null;
                    }
                }else{
                    return loanAppList.size() > 0 ? loanAppList[0].Product_Type__c : null;
                }
            }
        } catch(Exception ex){
            System.debug('Exception 407 -- >' + ex.getMessage());
            ErrorLoggerUtil.logErrorEvent('DealNumberCustomerCode', 'getNomineeDetails', System.Label.Apex, ex,loanApplicationId);
            throw new AuraHandledException(ex.getMessage());
        }
        return null;
    }


    /*
    * @Method Name: getCRFlag
    * @Created by:  Santhosh Guhan 
    * @description: Update Save Customer Relation Flag in Borrower 
    * @Param:       String - loanapp
    */

    @AuraEnabled
    public static Boolean getCRFlag(String loanapp){
        try {
            List<Applicant__c> listApp = [Select ID,Saved_Customer_Relation__c FROM Applicant__c WHERE Applicant_Type__c = 'Borrower' AND Opportunity__c=:loanapp AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED];
            if(!listApp.isEmpty()){
                return listApp[0].Saved_Customer_Relation__c;
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
    * @Method Name: updateCRFlag
    * @Created by:  Santhosh Guhan 
    * @description: Update Save Customer Relation Flag in Borrower 
    * @Param:       String - loanapp
    */

    @AuraEnabled
    public static void updateCRFlag(String loanapp){
        try {
            List<Applicant__c> listApp = [Select ID,Saved_Customer_Relation__c FROM Applicant__c WHERE Applicant_Type__c = 'Borrower' AND Opportunity__c=:loanapp AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED];
            for(Applicant__c app:listApp){
                app.Saved_Customer_Relation__c = true;
            }
            update listApp;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
    * @Method Name: updateNomineeDetails
    * @Created by:  Rajat Jaiswal
    * @description: Update Nominee Details for Borrower and Coborrower
    * @Param:       String - loanApplicationId
    */
    @AuraEnabled
    public static void updateNomineeDetails(string loanApplicationId, NomineeWrapper wrapperObj){
        try{
            if(wrapperObj != null){
                List<CASA_Bank_Form__c> caseBankList = new List<CASA_Bank_Form__c>();
                List<TeleVerification__c> teleVerificationList = new List<TeleVerification__c>();
                String teleVerificationId;
                String casaBankId;
                if(String.isNotBlank(wrapperObj.applicantId) && (String.isBlank(wrapperObj.casabankId) || String.isBlank(wrapperObj.tvrId))){
                    List<TeleVerification__c> lstTeleVerification = [SELECT Id,Applicant__c FROM TeleVerification__c where Applicant__c =: wrapperObj.applicantId WITH SECURITY_ENFORCED];
                    if(lstTeleVerification.size() > 0){
                        teleVerificationId =lstTeleVerification[0].Id;
                    }
                    List<CASA_Bank_Form__c> lstCasaBank = [Select Id,Applicant__c from CASA_Bank_Form__c where Applicant__c =: wrapperObj.applicantId];
                    if(lstCasaBank.size() > 0){
                        casaBankId =lstCasaBank[0].Id;
                    }
                }
                if (String.isNotBlank(wrapperObj.casabankId) || String.isNotBlank(casaBankId)) {
                    CASA_Bank_Form__c objCasaBank = new CASA_Bank_Form__c();
                    objCasaBank.Id =  String.isNotBlank(wrapperObj.casabankId) ? wrapperObj.casabankId : casaBankId;  
                    if(String.isNotBlank(wrapperObj.nomineeSAAccountOpening)){
                        objCasaBank.Saving_Account_opening_form_No__c = wrapperObj.nomineeSAAccountOpening;
                    }
                    if(String.isNotBlank(wrapperObj.nomineePinCode)){
                        objCasaBank.Saving_Account_opened_for__c = wrapperObj.nomineeSAAccountOpenedFor;
                    }
                    if (wrapperObj.nomineeAvailable == true) {
                        objCasaBank.Nominee_available__c = wrapperObj.nomineeAvailable;
                        objCasaBank.Nominee_name__c = wrapperObj.nomineeName == null?  '' : wrapperObj.nomineeName;
                        if(wrapperObj.nomineeDOB != null){
                            objCasaBank.Nominee_DOB__c = wrapperObj.nomineeDOB;
                        }
                        objCasaBank.Nominee_address__c = wrapperObj.nomineeAddress == null? '': wrapperObj.nomineeAddress;
                        if(String.isNotBlank(wrapperObj.nomineePinCode)){
                            objCasaBank.Nominee_pin_code__c = Integer.valueOf(wrapperObj.nomineePinCode);
                        }
                        if(String.isNotBlank(wrapperObj.nomineeCityId)){
                            objCasaBank.Finacle_City__c = wrapperObj.nomineeCityId;
                        }
                        if(String.isNotBlank(wrapperObj.nomineeStateId)){
                            objCasaBank.Geo_State_Master__c = wrapperObj.nomineeStateId;
                        }
                        if(String.isNotBlank(wrapperObj.nomineeRelationshipBorrower)){
                            objCasaBank.Relationship_with_borrower__c = wrapperObj.nomineeRelationshipBorrower;
                        }
                    }
                    caseBankList.add(objCasaBank);
                }
                if(String.isNotBlank(wrapperObj.tvrId) || String.isNotBlank(teleVerificationId)){
                    TeleVerification__c objTVR = new TeleVerification__c();
                    objTVR.Id = String.isNotBlank(wrapperObj.tvrId) ? wrapperObj.tvrId : teleVerificationId;
                    if(String.isNotBlank(wrapperObj.residenceCityFinacleId)){
                        objTVR.Finacle_City__c= wrapperObj.residenceCityFinacleId;
                    }
                    if(String.isNotBlank(wrapperObj.permanentFinacleId)){
                        objTVR.Permanent_Address_Finacle_City__c = wrapperObj.permanentFinacleId;                    
                    }
                    if(String.isNotBlank(wrapperObj.officeCityFinacleId)){
                        objTVR.Office_Address_Finacle_City__c = wrapperObj.officeCityFinacleId;                    
                    }
                    teleVerificationList.add(objTVR);
                }
                if(!caseBankList.isEmpty()){
                    System.debug('caseBankList --> ' + caseBankList);
                    update caseBankList;
                }
                if(!teleVerificationList.isEmpty()){
                    update teleVerificationList;
                }
            }
        } catch(Exception ex){
            System.debug('Exception 494 -- >' + ex.getMessage());
            ErrorLoggerUtil.logErrorEvent('DealNumberCustomerCode', 'updateNomineeDetails', System.Label.Apex, ex,loanApplicationId);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public class NomineeWrapper{
        @AuraEnabled public string applicantId {get; set;}
        @AuraEnabled public string applicantType {get; set;}
        @AuraEnabled public string tvrId {get; set;}
        @AuraEnabled public string casabankId {get;set;}
        @AuraEnabled public string nomineeSAAccountOpening {get;set;}
        @AuraEnabled public string nomineeSAAccountOpenedFor {get;set;}
        @AuraEnabled public Boolean nomineeAvailable {get;set;}
        @AuraEnabled public string nomineeName {get;set;}
        @AuraEnabled public Date nomineeDOB {get;set;}
        @AuraEnabled public string nomineeAddress {get;set;}
        @AuraEnabled public String nomineePinCode {get;set;}
        @AuraEnabled public string nomineeCity {get;set;}
        @AuraEnabled public string nomineeCityId {get;set;}
        @AuraEnabled public string nomineeState {get;set;}
        @AuraEnabled public string nomineeStateId {get;set;}
        @AuraEnabled public string nomineeRelationshipBorrower {get;set;}
        @AuraEnabled public string residenceCityFinacle {get; set;}
        @AuraEnabled public string residenceCityFinacleId {get; set;}
        @AuraEnabled public string permanentFinacle {get; set;}
        @AuraEnabled public string permanentFinacleId {get; set;}
        @AuraEnabled public string officeCityFinacle {get; set;}    
        @AuraEnabled public string officeCityFinacleId {get; set;}    
    }
}