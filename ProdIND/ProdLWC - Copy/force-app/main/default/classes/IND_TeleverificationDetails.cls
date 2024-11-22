/* 
* @Class Name: getTVRRecord
* @Created by:  Apoorva
* @description: class to complete the TVR journey
*/
public without sharing class IND_TeleverificationDetails {
    /*
    * @Method Name: getTVRRecord
    * @Created by:  Apoorva
    * @description: to get tvr related details from various objects which are related to given loan application
    * @Param:       String - strOppId   
    */
    @AuraEnabled (cacheable=true)
    public static List<wrpTVR> getTVRRecord(string strOppId){               
        List<Opportunity> lstOpp = new List<Opportunity>();
        List<Final_Term__c> lstFinalTerms = new List<Final_Term__c>();// D2C Change
        List<Applicant__c> lstApplicant = new List<Applicant__c>();
        List<TeleVerification__c> lstTeleVerification = new List<TeleVerification__c>();
        List<Field_Investigation__c> lstFI = new list<Field_Investigation__c>();
        List<Case> lstCase = new List<Case>();
        List<Case> lstCaseQuery = new List<Case>();
        List<Documents__c> lstDocuments = new List<Documents__c>();
        List<Vehicle_Detail__c> lstVehicleDetail = new List<Vehicle_Detail__c>();
        List<Income_Details__c> lstIncome = new List<Income_Details__c>();
        List<Finacle_City__c> lstFinacle = new List<Finacle_City__c>();
        List<CASA_Bank_Form__c> lstCasaBank = new List<CASA_Bank_Form__c>();
        Set<Id> setApplicant = new Set<Id>();
        List<wrpTVR> wrpTVRList = new List<wrpTVR>();
        List<CAM__c> camList = new List<CAM__c>();
        
        Map<Id,List<Documents__c>> applicantDocMap = new Map<Id,List<Documents__c>>();
        Map<Id,Income_Details__c> applicantIncomeMap = new Map<Id,Income_Details__c>();
        Map<Id,TeleVerification__c> applicantTVRMap = new Map<Id,TeleVerification__c>();
        Map<Id,List<Field_Investigation__c>> applicantFIMap = new Map<Id,List<Field_Investigation__c>>();
        
        String strLoanAppId;
        
        Id caseTVRRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TVR').getRecordTypeId();
        Id caseFIRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('FI').getRecordTypeId();
        try
        {
            strLoanAppId = [Select Id,Loan_Application__c from Case where Id=:strOppId WITH SECURITY_ENFORCED LIMIT 1].Loan_Application__c;
            lstOpp = [Select id, Name, Vehicle_Type__c,LeadSource, Loan_Amount__c, Total_Funded_Premium__c, Product_Type__c from Opportunity where id = :strLoanAppId WITH SECURITY_ENFORCED]; // D2C Change, added LeadSource
            lstTeleVerification = [SELECT Id, Attempts__c, Applicant__c,TVR_assessment__c, Remarks_in_RemarkSection__c ,Have_original_KYC_verified_atleast_once__c,Is_customer_s_Mob_No_linked_to_Aadhar__c,
                                   Is_customer_using_Aadhar_Linked_Mob_No__c,Have_you_applied_for_a_loan__c,Has_the_vehicle_been_delivered__c,Who_will_be_the_end_user_of_the_product__c,
                                   Purpose_of_purchasing_the_vehicle__c,Remark__c,No_of_years_in_business_current_emplo__c,Cheque_bounce_charges_informed__c,Customer_Informed_Provide_KYC_in_3Month__c ,
                                   Margin_Money_Paid__c,To_Whom_Margin_Money_Paid__c,Did_you_get_any_receipt__c,Amount_paid__c,Applicant__r.Applicant_Type__c, Is_customer_having_an_Aadhar_Card__c,
                                   Money_asked_for_processing_Down_Payment__c, Finacle_City__c,Finacle_City__r.Name, Office_Address_Finacle_City__c, Office_Address_Finacle_City__r.Name, Permanent_Address_Finacle_City__c, Permanent_Address_Finacle_City__r.Name
                                   FROM TeleVerification__c where Loan_Application__c = :strLoanAppId WITH SECURITY_ENFORCED];
            
            if(lstTeleVerification != null && !lstTeleVerification.isEmpty()){
                for(TeleVerification__c tvr : lstTeleVerification){
                    applicantTVRMap.put(tvr.Applicant__c, tvr);  
                }                       
            }
            //D2C Change
            if(lstOpp[0].LeadSource == 'D2C'){
                lstFinalTerms = [Select Id, Loan_Amount__c FROM Final_Term__c WHERE Loan_Application__c =:lstOpp[0].Id];
            }//EO D2C Change

          //  lstFinacle = [Select Id,City_Code__c from Finacle_City__c WITH SECURITY_ENFORCED];
            
            lstCasaBank = [Select Id,Applicant__c,Applicant__r.Name,Applicant__r.Contact_number__c,Applicant__r.Would_you_like_to_open_a_bank_account__c,
                           Applicant__r.Applicant_Type__c,Loan_Application__c,Nominee_address__c,Nominee_available__c,Nominee_City__c,Nominee_DOB__c,
                           Nominee_name__c,Nominee_Pin_Code__c,Nominee_State__c,Relationship_with_borrower__c,Saving_Account_opened_for__c,
                           Saving_Account_opening_form_No__c,TeleVerification__c, Finacle_City__c, Finacle_City__r.Name, Geo_State_Master__c, Geo_State_Master__r.Name from CASA_Bank_Form__c where Loan_Application__c=:strLoanAppId WITH SECURITY_ENFORCED];
            
            
            lstCase = [Select id,Applicant__c ,Type,Applicant__r.Applicant_Type__c  from case where Loan_Application__c = :strLoanAppId and RecordTypeId=:caseFIRecordTypeId WITH SECURITY_ENFORCED];          
            
            if(!lstCase.isEmpty())
            {
                
                lstFI = [select Id, Landmark__c,Case__r.Type,Case__r.Applicant__c, Case__r.Applicant__r.Applicant_Type__c,Case__r.RecordTypeId,Address_Verified_with_KYC__c ,recordTypeId, recordType.Name, Customer_house_same_as_in_application__c  
                         from Field_Investigation__c where Case__c = :lstCase WITH SECURITY_ENFORCED];               
            }
            List<Applicant__c> proposalList = [SELECT Who_will_repay_the_loan__c FROM Applicant__c WHERE Opportunity__c =: strLoanAppId AND Who_will_repay_the_loan__c != null AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED];
            String whoWillRepayLoan = '';
            if (proposalList.size() > 0) {
                whoWillRepayLoan = proposalList[0].Who_will_repay_the_loan__c != null ? proposalList[0].Who_will_repay_the_loan__c : '';
            }
        lstApplicant =  [select id,Name,Opportunity__c,Contact_number__c,Document_Count__c,Document_Count_for_TVR__c,Would_you_like_to_open_a_bank_account__c,Applicant_Type__c,Relationship_with_borrower__c,Name_Ref_1__c, Relationship_with_Borrower_Ref_1__c, Address_Line_1_Ref_1__c, Address_Line_2_Ref_1__c, City_Ref_1__c, State_Ref_1__c,
                        District_Ref_1__c, Pincode_Ref_1__c, Phone_Number_Ref_1__c, Name_Ref_2__c, Relationship_with_Borrower_Ref_2__c, Address_Line_1_Ref_2__c,
                        Address_Line_2_Ref_2__c, City_Ref_2__c, State_Ref_2__c, District_Ref_2__c, Pincode_Ref_2__c, Phone_Number_Ref_2__c,Alternate_Mobile_Number__c
                         from Applicant__c where Opportunity__c = :strLoanAppId and In_Active_Applicant__c = false  WITH SECURITY_ENFORCED];
            
            if(!lstApplicant.isEmpty()){
                for(Applicant__c objApplicant : lstApplicant){
                    setApplicant.add(objApplicant.Id);
                }
            }
            
            lstDocuments = [Select Id,Applicant__r.Applicant_Type__c,Document_Type__c,KYC_State__c,KYC_Pin_Code__c,KYC_District__c,KYC_City__c,KYC_Address_Line_2__c,
                            KYC_Address_Line_1__c,Current_Residential_Address_Proof__c,Permanent_Residential_Address_Proof__c,Applicant__r.Current_Same_As_Permanent__c from Documents__c
                            where  Applicant__c =: setApplicant and Applicant__r.In_Active_Applicant__c = false WITH SECURITY_ENFORCED];//CISP-2876
            
            if(lstDocuments != null && !lstDocuments.isEmpty()){
                for(Documents__c doc : lstDocuments){
                    if(applicantDocMap != null){ 
                        if(applicantDocMap.containsKey(doc.Applicant__c)){
                            applicantDocMap.get(doc.Applicant__c).add(doc);
                        } 
                        else{
                            applicantDocMap.put(doc.Applicant__c, new List<Documents__c>{doc});
                        }   
                    }                
                }
            }
            
            if(lstFI != null && !lstFI.isEmpty()){
                for(Field_Investigation__c fi : lstFI){
                    if(applicantFIMap != null){ 
                        if(applicantFIMap.containsKey(fi.Case__r.Applicant__c)){
                            applicantFIMap.get(fi.Case__r.Applicant__c).add(fi);
                        } 
                        else{
                            applicantFIMap.put(fi.Case__r.Applicant__c, new List<Field_Investigation__c>{fi});
                        }   
                    }                
                }
            }
            
            
            lstVehicleDetail = [Select Id,Loan_Application__c,Make__c,Model__c,Variant__c,Dealer_Sub_dealer_name__c,Manufacturer_Year_Month__c,Last_owner_name__c,Number_of_ownerships__c,Engine_number__c,Chassis_number__c,Lien_in_favor_of__c,RC_retention_applicable__c,Insurance_number__c,Insurer_name__c,Insurance_type__c,Insurance_declared_value__c,Ins_Issuance_date__c,Ins_Expiry_date__c,Insurance_expiring_within_60_days__c from Vehicle_Detail__c 
                                where Loan_Application__c =:strLoanAppId WITH SECURITY_ENFORCED];
            
            lstIncome = [Select Id, Applicant__r.Applicant_Type__c,Applicant__c,Employer_Business_Name__c,Office_Address_Line_1__c,Office_Address_Line_2__c,Office_PinCode__c,
                         Office_City__c,Office_State__c,Office_District__c,Current_Years_in_employment_business__c from Income_Details__c where Applicant__c =: setApplicant and Applicant__r.In_Active_Applicant__c = false AND IsOfficeAddressSubmitted__c = true WITH SECURITY_ENFORCED];
            
            if(lstIncome != null && !lstIncome.isEmpty()){
                for(Income_Details__c income : lstIncome){
                    applicantIncomeMap.put(income.Applicant__c, income);  
                }
            }   
            camList = [SELECT Id FROM CAM__c WHERE Loan_Application__c =: strLoanAppId WITH SECURITY_ENFORCED LIMIT 1];
            String camRecordId;
            if(!camList.isEmpty() && camList.size() > 0 && camList[0].Id!=null){
                camRecordId = camList[0].Id;
            }
            if(lstApplicant != null && !lstApplicant.isEmpty()){
                
                for(Applicant__c applicant : lstApplicant){ 
                    wrpTVR objwrpTVR = new wrpTVR(); 
                    System.debug('new wrpTVR() --> ' + new wrpTVR());
                    objwrpTVR.oppId = applicant.Opportunity__c;
                    objwrpTVR.applicantId = applicant.Id == null? '' : applicant.Id;
                objwrpTVR.applicantdocCount = applicant.Document_Count_for_TVR__c != null ? applicant.Document_Count__c + applicant.Document_Count_for_TVR__c : applicant.Document_Count__c;
                objwrpTVR.applicantdocCountForTVR = applicant.Document_Count_for_TVR__c != null ? applicant.Document_Count_for_TVR__c : 0;
                    objwrpTVR.applicantType = applicant.Applicant_Type__c == null? '' : applicant.Applicant_Type__c;
                    objwrpTVR.isBorrower = applicant.Applicant_Type__c == 'Borrower'? true : false;
                    objwrpTVR.applicantName = applicant.Name == null? '' : applicant.Name;
                    objwrpTVR.applicantContactNumber = applicant.Contact_number__c == null? '' : applicant.Contact_number__c;
                    objwrpTVR.isWillingToopenBankAccountWithIIB = applicant.Would_you_like_to_open_a_bank_account__c == null? false : applicant.Would_you_like_to_open_a_bank_account__c;
                    objwrpTVR.applicationrelationshipWithBorrower = (objwrpTVR.isBorrower == false && applicant.Relationship_with_borrower__c != null) ? applicant.Relationship_with_borrower__c : '';
                    objwrpTVR.alternateMobileNumber = applicant.Alternate_Mobile_Number__c != null ? applicant.Alternate_Mobile_Number__c : '';
                    objwrpTVR.whoWillRepayLoan = String.isNotBlank(whoWillRepayLoan) ? whoWillRepayLoan : '';
                    objwrpTVR.camRecId = String.isNotBlank(camRecordId) ? camRecordId : '';
                    if (applicant.Id!=null && applicant.Applicant_Type__c=='Borrower') {
                        objwrpTVR.nameRef1Value = applicant.Name_Ref_1__c;
                        objwrpTVR.relationRef1Value = applicant.Relationship_with_Borrower_Ref_1__c;
                        objwrpTVR.addressLine1Ref1Value = applicant.Address_Line_1_Ref_1__c;
                        objwrpTVR.addressLine2Ref1Value = applicant.Address_Line_2_Ref_1__c;
                        objwrpTVR.stateRef1Value = applicant.State_Ref_1__c;
                        objwrpTVR.districtRef1Value = applicant.District_Ref_1__c;
                        objwrpTVR.cityRef1Value = applicant.City_Ref_1__c;
                        objwrpTVR.pincodeRef1Value = String.valueOf(applicant.Pincode_Ref_1__c);
                        objwrpTVR.phoneNumberRef1Value = applicant.Phone_Number_Ref_1__c;
                        objwrpTVR.nameRef2Value = applicant.Name_Ref_2__c;
                        objwrpTVR.relationRef2Value = applicant.Relationship_with_Borrower_Ref_2__c;
                        objwrpTVR.addressLine1Ref2Value = applicant.Address_Line_1_Ref_2__c;
                        objwrpTVR.addressLine2Ref2Value = applicant.Address_Line_2_Ref_2__c;
                        objwrpTVR.stateRef2Value = applicant.City_Ref_2__c;
                        objwrpTVR.districtRef2Value = applicant.District_Ref_2__c;
                        objwrpTVR.cityRef2Value = applicant.State_Ref_2__c;
                        objwrpTVR.pincodeRef2Value = String.valueOf(applicant.Pincode_Ref_2__c);
                        objwrpTVR.phoneNumberRef2Value = applicant.Phone_Number_Ref_2__c;
                    }
                    //INDI:4596 line No: 138  to 176
                  for(integer i=0;i<lstCasaBank.size();i++)
                    {
                    if(applicant.Id!=null && applicant.Applicant_Type__c=='Borrower')
                    {
                        if(!lstCasaBank.isEmpty() && lstCasaBank[i].Applicant__c == applicant.Id ){
                            objwrpTVR.casabankId = lstCasaBank[i].Id;
                            objwrpTVR.nomineeSAAccountOpening  =  lstCasaBank[i].Saving_Account_opening_form_No__c == null? '' : lstCasaBank[i].Saving_Account_opening_form_No__c;
                            objwrpTVR.nomineeSAAccountOpenedFor  =  lstCasaBank[i].Saving_Account_opened_for__c == null? '' : lstCasaBank[i].Saving_Account_opened_for__c;
                            objwrpTVR.nomineeName = lstCasaBank[i].Nominee_name__c == null? '' : lstCasaBank[i].Nominee_name__c;
                            objwrpTVR.nomineeAddress  =  lstCasaBank[i].Nominee_address__c == null? '' : lstCasaBank[i].Nominee_address__c;
                            objwrpTVR.nomineeAvailable  =  lstCasaBank[i].Nominee_available__c == null? false : lstCasaBank[i].Nominee_available__c;
							objwrpTVR.nomineeCityId  =  lstCasaBank[i].Finacle_City__c == null? '' : lstCasaBank[i].Finacle_City__c;
                            objwrpTVR.nomineeCity  =  lstCasaBank[i].Finacle_City__r.Name == null? '' : lstCasaBank[i].Finacle_City__r.Name;
                            objwrpTVR.nomineeDOB  =  lstCasaBank[i].Nominee_DOB__c;
                            objwrpTVR.nomineePinCode  =  lstCasaBank[i].Nominee_pin_code__c == null? '' : String.valueOf(lstCasaBank[i].Nominee_pin_code__c);
						    objwrpTVR.nomineeStateId  =  lstCasaBank[i].Geo_State_Master__c == null? '' : lstCasaBank[i].Geo_State_Master__c;
                            objwrpTVR.nomineeState  =  lstCasaBank[i].Geo_State_Master__r.Name == null? '' : lstCasaBank[i].Geo_State_Master__r.Name;
                            objwrpTVR.nomineeRelationshipBorrower  =  lstCasaBank[i].Relationship_with_borrower__c == null? '' : lstCasaBank[i].Relationship_with_borrower__c;
                        }    
                        
                    }
                    if(applicant.Id!=null && applicant.Applicant_Type__c=='Co-borrower')    
                    {
                        if(!lstCasaBank.isEmpty()&& lstCasaBank[i].Applicant__c == applicant.Id)
                        {  
                            objwrpTVR.CB_casabankId = lstCasaBank[i].Id;
                            objwrpTVR.CB_nomineeSAAccountOpening  =  lstCasaBank[i].Saving_Account_opening_form_No__c == null? '' : lstCasaBank[i].Saving_Account_opening_form_No__c;
                            objwrpTVR.CB_nomineeSAAccountOpenedFor  =  lstCasaBank[i].Saving_Account_opened_for__c == null? '' : lstCasaBank[i].Saving_Account_opened_for__c;
                            objwrpTVR.CB_nomineeName = lstCasaBank[i].Nominee_name__c == null? '' : lstCasaBank[i].Nominee_name__c;
                            objwrpTVR.CB_nomineeAddress  =  lstCasaBank[i].Nominee_address__c == null? '' : lstCasaBank[i].Nominee_address__c;
                            objwrpTVR.CB_nomineeAvailable  =  lstCasaBank[i].Nominee_available__c == null? false : lstCasaBank[i].Nominee_available__c;
							objwrpTVR.CB_nomineeCityId  =  lstCasaBank[i].Finacle_City__c == null? '' : lstCasaBank[i].Finacle_City__c;
                            objwrpTVR.CB_nomineeCity  =  lstCasaBank[i].Finacle_City__r.Name == null? '' : lstCasaBank[i].Finacle_City__r.Name;
                            objwrpTVR.CB_nomineeDOB  =  lstCasaBank[i].Nominee_DOB__c;
                            objwrpTVR.CB_nomineePinCode  =  lstCasaBank[i].Nominee_pin_code__c == null? '' : String.valueOf(lstCasaBank[i].Nominee_pin_code__c);
							objwrpTVR.CB_nomineeStateId  =  lstCasaBank[i].Geo_State_Master__c == null? '' : lstCasaBank[i].Geo_State_Master__c;
                            objwrpTVR.CB_nomineeState  =  lstCasaBank[i].Geo_State_Master__r.Name == null? '' : lstCasaBank[i].Geo_State_Master__r.Name;
                            objwrpTVR.CB_nomineeRelationshipBorrower  =  lstCasaBank[i].Relationship_with_borrower__c == null? '' : lstCasaBank[i].Relationship_with_borrower__c;
                            
                        } 
                    }
                    }
                    
                    
                    
                    
                    
                    
                    if(applicantFIMap != null && !applicantFIMap.isEmpty()){
                        
                        if(applicantFIMap.get(applicant.Id) != null && !applicantFIMap.get(applicant.Id).isEmpty())
                        {
                            for(Field_Investigation__c fi : applicantFIMap.get(applicant.Id)){
                                
                                if(fi.Case__r.Applicant__r.Applicant_Type__c == 'Borrower' && fi.Case__r.Type == 'Current Residence FI'){
                                    
                                    objwrpTVR.residenceFIid = fi.id;
                                    objwrpTVR.residenceLandmark = fi.Landmark__c == null? '' : fi.Landmark__c;
                                    objwrpTVR.residenceAddressVerifiedWithKYC = fi.Address_Verified_with_KYC__c == null? false : fi.Address_Verified_with_KYC__c;
                                    
                                }else if(fi.Case__r.Applicant__r.Applicant_Type__c == 'Co-borrower' && fi.Case__r.Type == 'Current Residence FI'){
                                    
                                    objwrpTVR.residenceFIid = fi.id;
                                    objwrpTVR.residenceLandmark = fi.Landmark__c == null? '' : fi.Landmark__c;
                                    objwrpTVR.residenceAddressVerifiedWithKYC = fi.Address_Verified_with_KYC__c == null? false : fi.Address_Verified_with_KYC__c;
                                    
                                } else if(fi.Case__r.Applicant__r.Applicant_Type__c == 'Borrower' && fi.Case__r.Type == 'Permanent Residence FI'){
                                    
                                    objwrpTVR.permanentresidenceFIid = fi.id;
                                    objwrpTVR.permanentLandmark = fi.Landmark__c == null? '' : fi.Landmark__c;
                                    objwrpTVR.permanentAddressVerifiedWithKYC = fi.Address_Verified_with_KYC__c == null? false : fi.Address_Verified_with_KYC__c;
                                    
                                    
                                } else if(fi.Case__r.Applicant__r.Applicant_Type__c == 'Co-borrower' && fi.Case__r.Type == 'Permanent Residence FI'){
                                    
                                    objwrpTVR.permanentresidenceFIid = fi.id;
                                    objwrpTVR.permanentLandmark = fi.Landmark__c == null? '' : fi.Landmark__c;
                                    objwrpTVR.permanentAddressVerifiedWithKYC = fi.Address_Verified_with_KYC__c == null? false : fi.Address_Verified_with_KYC__c;
                                    
                                }
                            } 
                        }  
                    }
                    if(applicantDocMap != null && !applicantDocMap.isEmpty()){
                        objwrpTVR.currentAddressAvailable = false;             
						objwrpTVR.kycAadhaarCard = false;						
                        if(applicantDocMap.get(applicant.Id) != null && !applicantDocMap.get(applicant.Id).isEmpty())
                        {
                            for(Documents__c doc : applicantDocMap.get(applicant.Id)){
                                
                                if(doc.Current_Residential_Address_Proof__c == true){
                                    
                                    objwrpTVR.residenceAddressId = doc.id;
                                    objwrpTVR.residenceAddressLine1 = doc.KYC_Address_Line_1__c == null? '' : doc.KYC_Address_Line_1__c;
                                    objwrpTVR.residenceAddressLine2 = doc.KYC_Address_Line_2__c == null? '' : doc.KYC_Address_Line_2__c;
                                    objwrpTVR.residencePinCode = doc.KYC_Pin_Code__c == null? '' : doc.KYC_Pin_Code__c;
                                    objwrpTVR.residenceCity = doc.KYC_City__c == null? '' : doc.KYC_City__c;
                                    objwrpTVR.residenceState = doc.KYC_State__c == null? '' : doc.KYC_State__c;
                                    objwrpTVR.residenceDistrict = doc.KYC_District__c == null? '' : doc.KYC_District__c;
                                    objwrpTVR.currentAddressAvailable = true;
                                }
                                
                                if(doc.Permanent_Residential_Address_Proof__c == true || (doc.Applicant__r.Current_Same_As_Permanent__c == true && doc.Current_Residential_Address_Proof__c == true)){//CISP-2876
                                    
                                    objwrpTVR.permanentAddressId = doc.id;
                                    objwrpTVR.permanentAddressLine1 = doc.KYC_Address_Line_1__c == null? '' : doc.KYC_Address_Line_1__c;
                                    objwrpTVR.permanentAddressLine2 = doc.KYC_Address_Line_2__c == null? '' : doc.KYC_Address_Line_2__c;
                                    objwrpTVR.permanentPinCode = doc.KYC_Pin_Code__c == null? '' : doc.KYC_Pin_Code__c;
                                    objwrpTVR.permanentCity = doc.KYC_City__c == null? '' : doc.KYC_City__c;
                                    objwrpTVR.permanentState = doc.KYC_State__c == null? '' : doc.KYC_State__c;
                                    objwrpTVR.permanentDistrict = doc.KYC_District__c == null? '' : doc.KYC_District__c;
                                } 
                                
                                if(doc.Document_Type__c == System.Label.AadhaarCard){
                                    objwrpTVR.kycAadhaarCard = true;
                                }
                            } 
                        }  
                    }
                    if(applicantIncomeMap != null && !applicantIncomeMap.isEmpty() && applicantIncomeMap.get(applicant.Id) != null && applicantIncomeMap.containsKey(applicant.Id)){
                        objwrpTVR.incomeDetailsId = applicantIncomeMap.get(applicant.Id).Id;
                        objwrpTVR.businessCompanyName = applicantIncomeMap.get(applicant.Id).Employer_Business_Name__c == null? '' : applicantIncomeMap.get(applicant.Id).Employer_Business_Name__c;
                        objwrpTVR.officeAddressLine1 = applicantIncomeMap.get(applicant.Id).Office_Address_Line_1__c == null? '' : applicantIncomeMap.get(applicant.Id).Office_Address_Line_1__c;
                        objwrpTVR.officeAddressLine2 = applicantIncomeMap.get(applicant.Id).Office_Address_Line_2__c == null? '' : applicantIncomeMap.get(applicant.Id).Office_Address_Line_2__c;
                        objwrpTVR.officePinCode = applicantIncomeMap.get(applicant.Id).Office_PinCode__c == null? '' : applicantIncomeMap.get(applicant.Id).Office_PinCode__c;
                        objwrpTVR.officeCity = applicantIncomeMap.get(applicant.Id).Office_City__c == null? '' : applicantIncomeMap.get(applicant.Id).Office_City__c;
                        objwrpTVR.officeState = applicantIncomeMap.get(applicant.Id).Office_State__c == null? '' : applicantIncomeMap.get(applicant.Id).Office_State__c;
                        objwrpTVR.officeDistrict = applicantIncomeMap.get(applicant.Id).Office_District__c == null? '' : applicantIncomeMap.get(applicant.Id).Office_District__c;
                        objwrpTVR.businessYearsInBusiness = applicantIncomeMap.get(applicant.Id).Current_Years_in_employment_business__c == null? '' : applicantIncomeMap.get(applicant.Id).Current_Years_in_employment_business__c;
                    }
                    
                    if(applicantTVRMap != null && !applicantTVRMap.isEmpty() && applicantTVRMap.containsKey(applicant.Id)){
                        objwrpTVR.tvrId = applicantTVRMap.get(applicant.Id).Id;
                        objwrpTVR.tvrAttempts = applicantTVRMap.get(applicant.Id).Attempts__c == null? '' : String.valueOf(applicantTVRMap.get(applicant.Id).Attempts__c);
                        objwrpTVR.tvrassessment = applicantTVRMap.get(applicant.Id).TVR_assessment__c == null? '' : applicantTVRMap.get(applicant.Id).TVR_assessment__c;
                        objwrpTVR.tvrRemarks = applicantTVRMap.get(applicant.Id).Remarks_in_RemarkSection__c == null? '' : applicantTVRMap.get(applicant.Id).Remarks_in_RemarkSection__c;
                        objwrpTVR.personalAppliedForLoan = applicantTVRMap.get(applicant.Id).Have_you_applied_for_a_loan__c == null? false : applicantTVRMap.get(applicant.Id).Have_you_applied_for_a_loan__c;
                        objwrpTVR.personalVehicleDelivered = applicantTVRMap.get(applicant.Id).Has_the_vehicle_been_delivered__c == null? false : applicantTVRMap.get(applicant.Id).Has_the_vehicle_been_delivered__c;
                        objwrpTVR.personalProductEndUser = applicantTVRMap.get(applicant.Id).Who_will_be_the_end_user_of_the_product__c == null? '' : applicantTVRMap.get(applicant.Id).Who_will_be_the_end_user_of_the_product__c;
                        objwrpTVR.personalPurpose = applicantTVRMap.get(applicant.Id).Purpose_of_purchasing_the_vehicle__c == null? '' : applicantTVRMap.get(applicant.Id).Purpose_of_purchasing_the_vehicle__c;
                        objwrpTVR.personalRemarks = applicantTVRMap.get(applicant.Id).Remark__c == null? '' : applicantTVRMap.get(applicant.Id).Remark__c;                    
                        objwrpTVR.loanChequeBounce = applicantTVRMap.get(applicant.Id).Cheque_bounce_charges_informed__c == null? false : applicantTVRMap.get(applicant.Id).Cheque_bounce_charges_informed__c;
                        objwrpTVR.loanMarginMoney = applicantTVRMap.get(applicant.Id).Margin_Money_Paid__c == null? false : applicantTVRMap.get(applicant.Id).Margin_Money_Paid__c;
                        objwrpTVR.loanWhomMarginMoney = applicantTVRMap.get(applicant.Id).To_Whom_Margin_Money_Paid__c == null? '' : applicantTVRMap.get(applicant.Id).To_Whom_Margin_Money_Paid__c;
                        objwrpTVR.loanReceipt = applicantTVRMap.get(applicant.Id).Did_you_get_any_receipt__c == null? false : applicantTVRMap.get(applicant.Id).Did_you_get_any_receipt__c;
                        objwrpTVR.loanAmountPaid = applicantTVRMap.get(applicant.Id).Amount_paid__c == null? '' : String.valueOf(applicantTVRMap.get(applicant.Id).Amount_paid__c);
                        objwrpTVR.customerInformedProvideKYCIn3Months = applicantTVRMap.get(applicant.Id).Customer_Informed_Provide_KYC_in_3Month__c == null? false : applicantTVRMap.get(applicant.Id).Customer_Informed_Provide_KYC_in_3Month__c;
                        objwrpTVR.moneyAskedForProcessingDownPayment = applicantTVRMap.get(applicant.Id).Money_asked_for_processing_Down_Payment__c == null? false : applicantTVRMap.get(applicant.Id).Money_asked_for_processing_Down_Payment__c;
                        if(objwrpTVR.kycAadhaarCard == false){                       
                            objwrpTVR.kycAadhaarCard = applicantTVRMap.get(applicant.Id).Is_customer_having_an_Aadhar_Card__c == null? false : applicantTVRMap.get(applicant.Id).Is_customer_having_an_Aadhar_Card__c;
                        }                    
                        objwrpTVR.kycAttestationOnce  = applicantTVRMap.get(applicant.Id).Have_original_KYC_verified_atleast_once__c == null? false : applicantTVRMap.get(applicant.Id).Have_original_KYC_verified_atleast_once__c;
                        objwrpTVR.kycMobileLinkedAadhaar = applicantTVRMap.get(applicant.Id).Is_customer_s_Mob_No_linked_to_Aadhar__c == null? false : applicantTVRMap.get(applicant.Id).Is_customer_s_Mob_No_linked_to_Aadhar__c;
                        objwrpTVR.kycUsingMobileLinkedAadhaar = applicantTVRMap.get(applicant.Id).Is_customer_using_Aadhar_Linked_Mob_No__c == null? false : applicantTVRMap.get(applicant.Id).Is_customer_using_Aadhar_Linked_Mob_No__c;
                        
                        objwrpTVR.residenceCityFinacle = applicantTVRMap.get(applicant.Id).Finacle_City__c == null? '' : applicantTVRMap.get(applicant.Id).Finacle_City__c;
                        objwrpTVR.residenceCityFinacleValue = applicantTVRMap.get(applicant.Id).Finacle_City__c == null? '' : applicantTVRMap.get(applicant.Id).Finacle_City__r.Name;
                        objwrpTVR.permanentFinacle = applicantTVRMap.get(applicant.Id).Permanent_Address_Finacle_City__c == null? '' : applicantTVRMap.get(applicant.Id).Permanent_Address_Finacle_City__c;
                        objwrpTVR.permanentFinacleValue = applicantTVRMap.get(applicant.Id).Permanent_Address_Finacle_City__c == null? '' : applicantTVRMap.get(applicant.Id).Permanent_Address_Finacle_City__r.Name;
                        objwrpTVR.officeCityFinacle = applicantTVRMap.get(applicant.Id).Office_Address_Finacle_City__c == null? '' : applicantTVRMap.get(applicant.Id).Office_Address_Finacle_City__c;
                        objwrpTVR.officeCityFinacleValue = applicantTVRMap.get(applicant.Id).Office_Address_Finacle_City__c == null? '' : applicantTVRMap.get(applicant.Id).Office_Address_Finacle_City__r.Name;
                    }
                    
                    // lstFinacle.sort();
                    
                    //objwrpTVR.lstFinacleValues = lstFinacle;
                    objwrpTVR.oppName = lstOpp[0].Name == null? '' : lstOpp[0].Name;
                    objwrpTVR.vehicleType = lstOpp[0].Vehicle_Type__c == null? '' : lstOpp[0].Vehicle_Type__c;
                    //D2C Change
                    if(lstOpp[0].LeadSource == 'D2C' && !lstFinalTerms.isEmpty()){
                        objwrpTVR.loanAmount = lstFinalTerms[0].Loan_Amount__c == null? '' : lstFinalTerms[0].Loan_Amount__c; 
                    }//EO D2C Change
                    objwrpTVR.isPassengerVehicle = lstOpp[0].Product_Type__c == 'Passenger Vehicles'? true : false;
                    List<Final_Term__c> finalTermList = new List<Final_Term__c>();
                    finalTermList = [Select Id,Loan_Amount__c FROM Final_Term__c WHERE Loan_Application__c = :strLoanAppId LIMIT 1];
                    if(finalTermList.size()  > 0){
                        objwrpTVR.loanAmount = String.valueOf(Decimal.valueOf(finalTermList[0].Loan_amount__c) + lstOpp[0].Total_Funded_Premium__c);
                    }else{
                        objwrpTVR.loanAmount = lstOpp[0].Loan_Amount__c == null? '' : lstOpp[0].Loan_Amount__c;
                    }
                    
                    if(!lstVehicleDetail.isEmpty()){
                        objwrpTVR.vehicleId = lstVehicleDetail[0].id;
                        objwrpTVR.personalVehicleMake = lstVehicleDetail[0].Make__c == null? '' : lstVehicleDetail[0].Make__c;
                        objwrpTVR.personalVehicleModel = lstVehicleDetail[0].Model__c == null? '' : lstVehicleDetail[0].Model__c;
                        objwrpTVR.personalVehicleVariant = lstVehicleDetail[0].Variant__c == null? '' : lstVehicleDetail[0].Variant__c;
                        objwrpTVR.dealerName = lstVehicleDetail[0].Dealer_Sub_dealer_name__c == null? '' : lstVehicleDetail[0].Dealer_Sub_dealer_name__c;
                        objwrpTVR.manufacturerYearMonth = lstVehicleDetail[0].Manufacturer_Year_Month__c == null? '' : lstVehicleDetail[0].Manufacturer_Year_Month__c;
                        objwrpTVR.lastOwnerName = lstVehicleDetail[0].Last_owner_name__c == null? '' : lstVehicleDetail[0].Last_owner_name__c;
                        objwrpTVR.numberOfOwnerships = lstVehicleDetail[0].Number_of_ownerships__c == null? '' : lstVehicleDetail[0].Number_of_ownerships__c;
                        objwrpTVR.engineNumber = lstVehicleDetail[0].Engine_number__c == null? '' : lstVehicleDetail[0].Engine_number__c;
                        objwrpTVR.chassisNumber = lstVehicleDetail[0].Chassis_number__c == null? '' : lstVehicleDetail[0].Chassis_number__c;
                        objwrpTVR.lienInFavorOf = lstVehicleDetail[0].Lien_in_favor_of__c == null? '' : lstVehicleDetail[0].Lien_in_favor_of__c;
                        objwrpTVR.rcRetentionApplicable = lstVehicleDetail[0].RC_retention_applicable__c == null? '' : lstVehicleDetail[0].RC_retention_applicable__c;
                        objwrpTVR.insuranceNumber = lstVehicleDetail[0].Insurance_number__c == null? '' : lstVehicleDetail[0].Insurance_number__c;
                        objwrpTVR.insurerName = lstVehicleDetail[0].Insurer_name__c == null? '' : lstVehicleDetail[0].Insurer_name__c;
                        objwrpTVR.insuranceType = lstVehicleDetail[0].Insurance_type__c == null? '' : lstVehicleDetail[0].Insurance_type__c;
                        objwrpTVR.insuranceDeclaredValue = lstVehicleDetail[0].Insurance_declared_value__c;
                        objwrpTVR.insIssuanceDate = lstVehicleDetail[0].Ins_Issuance_date__c;
                        objwrpTVR.insExpiryDate = lstVehicleDetail[0].Ins_Expiry_date__c;
                        objwrpTVR.insExpiringWhithin60Days = lstVehicleDetail[0].Insurance_expiring_within_60_days__c;
                    }       
                    wrpTVRList.add(objwrpTVR);
                }    
            }  
            return wrpTVRList;
        } 
        catch(exception e)
        {            
            System.debug('Exception 384 --> ' + e.getMessage());
            ErrorLoggerUtil.logErrorEvent('IND_TeleverificationDetails', 'getTVRRecord', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);   
        }                
    }
    
    /*
    * @Method Name: updateTVRRecord
    * @Created by:  Apoorva
    * @description: to update tvr and casa bank form records
    * @Param:       List<wrpTVR> - wrapperListForUpdate       
    */
    @AuraEnabled 
    public static void updateTVRRecord(List<wrpTVR> wrapperListForUpdate,String loanapplicationId){
        system.debug('The Wrapper to be updated'+wrapperListForUpdate);
        List<CASA_Bank_Form__c> caseBankList = new List<CASA_Bank_Form__c>();
        List<TeleVerification__c> teleVerificationList = new List<TeleVerification__c>();
        List<Applicant__c> lstApplicant = new List<Applicant__c>();
        List<Case> caseList = new List<Case>();
        Map<Id,Case> caseMapUpdate = new Map<Id,Case>();
        Set<Id> setCaseId = new Set<Id>();       
        try
        {
            if(!wrapperListForUpdate.isEmpty())
            {
                system.debug('I am in below empty ' + wrapperListForUpdate);
                for(wrpTVR wrapperObj : wrapperListForUpdate)
                {
                    system.debug('I am in wapeetr for loop ');
                    if(wrapperObj.casabankId != null||wrapperObj.CB_casaBankId!=null)
                    {
                        
                        //Bug: INDI 4696 Line 325 to 344: when update will happen on nominee details of the borrower or Co- borrower then details will be reflect in CASA bank record 
                        CASA_Bank_Form__c objCasaBank = new CASA_Bank_Form__c();
                        objCasaBank.Id =  wrapperObj.casabankId == null? wrapperObj.CB_casaBankId : wrapperObj.casabankId;   
                        objCasaBank.Saving_Account_opening_form_No__c = wrapperObj.nomineeSAAccountOpening == null?  wrapperObj.CB_nomineeSAAccountOpening: wrapperObj.nomineeSAAccountOpening;
                        objCasaBank.Saving_Account_opened_for__c = wrapperObj.nomineeSAAccountOpenedFor == null?  wrapperObj.CB_nomineeSAAccountOpenedFor: wrapperObj.nomineeSAAccountOpenedFor;
                        objCasaBank.Nominee_available__c = wrapperObj.nomineeAvailable == null?  wrapperObj.CB_nomineeAvailable: wrapperObj.nomineeAvailable;
                        objCasaBank.Nominee_name__c = wrapperObj.nomineeName == null?  wrapperObj.CB_nomineeName: wrapperObj.nomineeName;
                        objCasaBank.Nominee_DOB__c = wrapperObj.nomineeDOB == null?  wrapperObj.CB_nomineeDOB: wrapperObj.nomineeDOB;
                        objCasaBank.Nominee_address__c = wrapperObj.nomineeAddress == null?  wrapperObj.CB_nomineeAddress: wrapperObj.nomineeAddress;
                        if(wrapperObj.nomineePinCode != null && wrapperObj.nomineePinCode !='')
                        {                        
                            objCasaBank.Nominee_pin_code__c = Decimal.valueOf(wrapperObj.nomineePinCode);
                        } 
                        if(wrapperObj.CB_nomineePinCode != null && wrapperObj.CB_nomineePinCode !='')
                        {                        
                            objCasaBank.Nominee_pin_code__c = Decimal.valueOf(wrapperObj.CB_nomineePinCode);
                        }
						// Added Nominee City
                        if(wrapperObj.nomineeCityId != null && wrapperObj.nomineeCityId !=''){
                            objCasaBank.Finacle_City__c = wrapperObj.nomineeCityId;
                        }
                        if(wrapperObj.CB_nomineeCityId != null && wrapperObj.CB_nomineeCityId !=''){
                            objCasaBank.Finacle_City__c = wrapperObj.CB_nomineeCityId;
                        }
                        //objCasaBank.Nominee_City__c = wrapperObj.nomineeCity == null?  wrapperObj.CB_nomineeCity: wrapperObj.nomineeCity;
                        // Added Nominee State
                        if(wrapperObj.nomineeStateId != null && wrapperObj.nomineeStateId !=''){
                            objCasaBank.Geo_State_Master__c = wrapperObj.nomineeStateId;
                        }
                        if(wrapperObj.CB_nomineeStateId != null && wrapperObj.CB_nomineeStateId !=''){
                            objCasaBank.Geo_State_Master__c = wrapperObj.CB_nomineeStateId;
                        }
						//objCasaBank.Nominee_State__c = wrapperObj.nomineeState == null?  wrapperObj.CB_nomineeState: wrapperObj.nomineeState;
                        objCasaBank.Relationship_with_borrower__c = wrapperObj.nomineeRelationshipBorrower == null?  wrapperObj.CB_nomineeRelationshipBorrower: wrapperObj.nomineeRelationshipBorrower;
                        caseBankList.add(objCasaBank);
 
                    }
       
                    if(wrapperObj.tvrId != null)
                    {
                        TeleVerification__c objTVR = new TeleVerification__c();
                        
                        objTVR.id = wrapperObj.tvrId;
                        //KYC DETAILS -
                        objTVR.Have_original_KYC_verified_atleast_once__c = wrapperObj.kycAttestationOnce == null? false : wrapperObj.kycAttestationOnce;
                        objTVR.Is_customer_having_an_Aadhar_Card__c = wrapperObj.kycAadhaarCard == null? false : wrapperObj.kycAadhaarCard;
                        objTVR.Is_customer_s_Mob_No_linked_to_Aadhar__c = wrapperObj.kycMobileLinkedAadhaar == null? false : wrapperObj.kycMobileLinkedAadhaar;
                        objTVR.Is_customer_using_Aadhar_Linked_Mob_No__c = wrapperObj.kycUsingMobileLinkedAadhaar == null? false : wrapperObj.kycUsingMobileLinkedAadhaar;
                        //PERSONAL DETAILS
                        objTVR.Have_you_applied_for_a_loan__c  = wrapperObj.personalAppliedForLoan == null? false : wrapperObj.personalAppliedForLoan;
                        objTVR.Has_the_vehicle_been_delivered__c = wrapperObj.personalVehicleDelivered == null? false : wrapperObj.personalVehicleDelivered;   
                        objTVR.Who_will_be_the_end_user_of_the_product__c = wrapperObj.personalProductEndUser;
                        objTVR.Purpose_of_purchasing_the_vehicle__c = wrapperObj.personalPurpose;                    
                        objTVR.Remark__c = wrapperObj.personalRemarks;                    
                        //LOAN DETAILS
                        objTVR.Cheque_bounce_charges_informed__c= wrapperObj.loanChequeBounce == null? false : wrapperObj.loanChequeBounce;        
                        objTVR.Margin_Money_Paid__c = wrapperObj.loanMarginMoney == null? false : wrapperObj.loanMarginMoney;
                        objTVR.To_Whom_Margin_Money_Paid__c = wrapperObj.loanWhomMarginMoney;
                        objTVR.Did_you_get_any_receipt__c = wrapperObj.loanReceipt == null? false : wrapperObj.loanReceipt;
                        
                        //Current Address
                        if(String.isNotBlank(wrapperObj.residenceCityFinacle))
                        {
                            objTVR.Finacle_City__c= wrapperObj.residenceCityFinacle;
                        }
                        
                        //Permanent Address
                        if(String.isNotBlank(wrapperObj.permanentFinacle))
                        {
                            objTVR.Permanent_Address_Finacle_City__c = wrapperObj.permanentFinacle;                    
                        }                    
                        
                        //Office Address
                        if(String.isNotBlank(wrapperObj.officeCityFinacle))
                        {
                            objTVR.Office_Address_Finacle_City__c = wrapperObj.officeCityFinacle;                    
                        }
                        
                        //GENERAL DETAILS
                        objTVR.Customer_Informed_Provide_KYC_in_3Month__c = wrapperObj.customerInformedProvideKYCIn3Months == null? false : wrapperObj.customerInformedProvideKYCIn3Months;
                        objTVR.Money_asked_for_processing_Down_Payment__c = wrapperObj.moneyAskedForProcessingDownPayment == null? false : wrapperObj.moneyAskedForProcessingDownPayment;
                        
                        if(wrapperObj.loanAmountPaid != null && wrapperObj.loanAmountPaid !='')
                        {
                            objTVR.Amount_paid__c = Decimal.valueOf(wrapperObj.loanAmountPaid);
                        } 
                        
                        //REMARKS
                        if(wrapperObj.tvrAttempts != null && wrapperObj.tvrAttempts !='')
                        {
                            objTVR.Attempts__c = Integer.valueOf(wrapperObj.tvrAttempts);
                        }                    
                        objTVR.TVR_assessment__c = wrapperObj.tvrassessment;
                        objTVR.Remarks_in_RemarkSection__c = wrapperObj.tvrRemarks;
                        
                        teleVerificationList.add(objTVR);
                        
                    }
                    if(String.isNotBlank(wrapperObj.alternateMobileNumber)){
                        Applicant__c applicantObj = new Applicant__c();
                        applicantObj.Id = wrapperObj.applicantId;
                        applicantObj.Alternate_Mobile_Number__c = wrapperObj.alternateMobileNumber;
                        lstApplicant.add(applicantObj);
                    }   
                }            
            }  
            if(!caseBankList.isEmpty())
            {
                System.debug('caseBankList --> ' + caseBankList);
                update caseBankList;
            }
            if(!teleVerificationList.isEmpty())
            {
                update teleVerificationList;
                
            } 
            if(!lstApplicant.isEmpty()){
                update lstApplicant;
            } 
            
            if(!teleVerificationList.isEmpty()){
                for(TeleVerification__c objTele : [Select Id,Case__c,TVR_assessment__c from TeleVerification__c where Id=:teleVerificationList WITH SECURITY_ENFORCED]){
                    {
                        
                        if(teleVerificationList.size() == 1){
                            if(objTele.TVR_assessment__c == 'High Risk'){
                                Case objCase = new Case();
                                objCase.Id = objTele.Case__c;
                                objCase.Status = 'High Risk';
                                caseMapUpdate.put(objCase.Id,objCase);
                            }else if(objTele.TVR_assessment__c == 'Pass'){
                                Case objCase = new Case();
                                objCase.Id = objTele.Case__c;
                                objCase.Status = 'Pass';
                                caseMapUpdate.put(objCase.Id,objCase);
                            }
                        }else if(teleVerificationList.size() == 2){
                            if(teleVerificationList[0].TVR_assessment__c == 'High Risk'){
                                Case objCase = new Case();
                                objCase.Id = objTele.Case__c;
                                objCase.Status = 'High Risk';
                                caseMapUpdate.put(objCase.Id,objCase);
                            }else if(teleVerificationList[0].TVR_assessment__c == 'Pass'){
                                Case objCase = new Case();
                                objCase.Id = objTele.Case__c;
                                objCase.Status = 'In Progress';
                                caseMapUpdate.put(objCase.Id,objCase);
                            }
                            if(teleVerificationList[1].TVR_assessment__c == 'High Risk'){
                                Case objCase = new Case();
                                objCase.Id = objTele.Case__c;
                                objCase.Status = 'High Risk';
                                caseMapUpdate.put(objCase.Id,objCase);
                            }  else if(teleVerificationList[1].TVR_assessment__c == 'Pass'){
                                Case objCase = new Case();
                                objCase.Id = objTele.Case__c;
                                if(objCase.Status != 'High Risk'){
                                    objCase.Status = 'Pass';
                                }else{
                                    objCase.Status = 'High Risk';  
                                }
                                caseMapUpdate.put(objCase.Id,objCase);
                            }  
                        } 
                    }   
                    
                }    
                
            }
            
            if(!caseMapUpdate.isEmpty())
            {
                update caseMapUpdate.values();
                
            }
        }
        catch(exception e)
        {            
            System.debug('Exception 593 -- >' + e.getMessage());
            ErrorLoggerUtil.logErrorEvent('IND_TeleverificationDetails', 'updateTVRRecord', System.Label.Apex, e, loanapplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);   
        } 
    }
    
    /*
    * @Method Name: createRealatedRecords
    * @Created by:  Apoorva
    * @description: to create case, tvr and casa bank form records
    * @Param:       String - strOppId
    * @Param:       String - tvrType    
    */
    @AuraEnabled 
    public static string createRealatedRecords(string strOppId, string tvrType){
        
        List<TeleVerification__c> lstTVR =new  list<TeleVerification__c>();
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        List<Applicant__c> lstApplicant = new List<Applicant__c>();
        List<Case> lstCase = new List<case>();
        List<CASA_Bank_Form__c> lstCasaBank = new List<CASA_Bank_Form__c>();
        Boolean borrowerCasa = false;
        Boolean coBorrowerCasa = false;
        String borrowerId;
        String caseId = '';
        String coBorrowerId;
        String vehDetail;//Added for refinance change
        
        try
        {
            Id tvrRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TVR').getRecordTypeId();
            List<Group > lstQueue = [select Id from Group where Type = 'Queue' and DeveloperNAME = 'BE_CVO'];
            //Prashanth- added Is_Pre_Approved__c,LeadSource in the below query.
            lstOpportunity = [select id,Product_Type__c,StageName, AccountId, Vehicle_Type__c,Name, Vehicle_Sub_Category__c, Applicant__c, Sanction_Status__c,Is_Pre_Approved__c,LeadSource,OwnerId
                              from Opportunity where id = :strOppId WITH SECURITY_ENFORCED];
            //prashanth
            if(!lstOpportunity.isEmpty() && lstOpportunity[0].LeadSource == 'D2C' && lstOpportunity[0].Is_Pre_Approved__c){
                return caseId;
            }
            lstApplicant = [select id,Name,Applicant_Type__c, Would_you_like_to_open_a_bank_account__c, Relationship_with_borrower__c, Who_will_repay_the_loan__c from Applicant__c where Opportunity__c = :strOppId and In_Active_Applicant__c = false WITH SECURITY_ENFORCED];
            List<AccountTeamMember> accTeamMem = [Select Id, UserId, TeamMemberRole from AccountTeamMember where AccountId =: lstOpportunity[0].AccountId and TeamMemberRole = 'CVO' AND User.IsActive = true limit 1];//CISP-2987
            //Added for refinance change
            if(!lstOpportunity.isEmpty()){
                if(lstOpportunity[0].Vehicle_Type__c == 'New'){
                    vehDetail = 'New';
                }
                // else if(lstOpportunity[0].Vehicle_Type__c == 'Used'){
                //     vehDetail = 'Used';
                // }
                else if(lstOpportunity[0].Vehicle_Type__c == 'Refinance' || lstOpportunity[0].Vehicle_Type__c == 'Used'){
                    if(lstOpportunity[0].Vehicle_Sub_Category__c == 'UPB' || lstOpportunity[0].Vehicle_Sub_Category__c == 'UPO'){
                        vehDetail = 'External Refinance';
                    }
                    else if(lstOpportunity[0].Vehicle_Sub_Category__c == 'UIM' || lstOpportunity[0].Vehicle_Sub_Category__c == 'RLY' || lstOpportunity[0].Vehicle_Sub_Category__c == 'RLN'){
                        vehDetail = 'Internal Refinance';
                    }else{
                        vehDetail = 'Used';
                    }
                    
                }
            }
            //Added for refinance change
            
            if(!lstOpportunity.isEmpty() &&
               (
                   ((lstOpportunity[0].Product_Type__c == 'Passenger Vehicles' && (vehDetail == 'New' || vehDetail =='Internal Refinance')) ||           
                    (lstOpportunity[0].Product_Type__c == 'Two Wheeler' && lstOpportunity[0].Sanction_Status__c == 'STP')) && tvrType == 'Post-TVR'
               ) ||
               (
                   ((lstOpportunity[0].Product_Type__c == 'Passenger Vehicles' && (vehDetail == 'Used' || vehDetail =='External Refinance')) ||           
                    (lstOpportunity[0].Product_Type__c == 'Two Wheeler' && lstOpportunity[0].Sanction_Status__c == 'Non-STP')) && tvrType == 'Pre-TVR'
               ) ||
               (
                    lstOpportunity[0].Product_Type__c == 'Tractor'
               ) 
              )
            {
                if([SELECT Id, Subject FROM Case WHERE Loan_Application__c = :strOppId AND RecordTypeId =: tvrRecordTypeId WITH SECURITY_ENFORCED].isEmpty())
                {
                    case objCase = new case();
                    if(lstOpportunity[0].Product_Type__c == 'Passenger Vehicles'){
                        objCase.OwnerId = lstQueue[0].Id;
                    }
                    else if(lstOpportunity[0].Product_Type__c == 'Two Wheeler'){
                        if(!accTeamMem.isEmpty()){
                            objCase.OwnerId = accTeamMem[0].UserId;
                        }                        
                    }else if(lstOpportunity[0].Product_Type__c == 'Tractor'){
                        objCase.OwnerId = lstOpportunity[0].OwnerId;
                    }

                    objCase.Subject = lstOpportunity[0].Name+'_TVR';
                    objCase.RecordTypeId = tvrRecordTypeId;
                    objCase.Loan_Application__c = strOppId;
                    objCase.AccountId = lstOpportunity[0].AccountId;
                    try{ //Duplicate Record Creation Start 
                          objCase.Loan_Number__c= lstOpportunity[0].Name + ' TVR';
                    insert objCase;
                    }catch(Exception e){ System.debug('Exception: ' + e); }// //Duplicate Record Creation End 
                  
                    caseId = objCase.Id;
                    if(!lstApplicant.isEmpty())
                    {
                        List<Applicant__c> proposalList = new List<Applicant__c>();
                        if(lstOpportunity[0].Product_Type__c == 'Tractor'){
                            proposalList = [SELECT Who_will_repay_the_loan__c 
                                            FROM Applicant__c 
                                            WHERE Opportunity__c =: strOppId AND Who_will_repay_the_loan__c != null AND In_Active_Applicant__c = false AND Applicant_Type__c = 'Borrower'
                                            WITH SECURITY_ENFORCED];
                        }else{
                            proposalList = [SELECT Who_will_repay_the_loan__c 
                                            FROM Applicant__c 
                                            WHERE Opportunity__c =: strOppId AND Who_will_repay_the_loan__c != null AND In_Active_Applicant__c = false 
                                            WITH SECURITY_ENFORCED];
                        }
                        
                        String whoWillRepayLoan = '';
                        if (proposalList.size() > 0) {
                            whoWillRepayLoan = proposalList[0].Who_will_repay_the_loan__c != null ? proposalList[0].Who_will_repay_the_loan__c : '';
                        }
                        for(Applicant__c item : lstApplicant)
                        {
                            TeleVerification__c objTVR = new TeleVerification__c(); 
                            objTVR.Name = item.Name + '_TVR';
                            objTVR.Case__c = objCase.Id; 
                            if(tvrType == 'Post-TVR')
                            { 
                                objTVR.RecordTypeId = Schema.SObjectType.TeleVerification__c.getRecordTypeInfosByName().get('Post-Sanction').getRecordTypeId();
                            }    
                            else
                            { 
                                objTVR.RecordTypeId = Schema.SObjectType.TeleVerification__c.getRecordTypeInfosByName().get('Pre-Sanction').getRecordTypeId();
                            }
                            objTVR.Applicant__c = item.id;
                            objTVR.Loan_Application__c = strOppId;
                            lstTVR.add(objTVR);  
                            
                            if(item.Would_you_like_to_open_a_bank_account__c)
                            {
                                if(item.Applicant_Type__c == 'Borrower' && whoWillRepayLoan == 'Borrower')
                                {
                                    borrowerCasa = true;
                                    borrowerId = item.Id;
                                }
                                else if(item.Applicant_Type__c == 'Co-borrower' && whoWillRepayLoan == 'Co-borrower')
                                {
                                    coBorrowerCasa = true; 
                                    coBorrowerId = item.Id; 
                                }      
                            }                 
                        }
                        if(!lstTVR.isEmpty()) 
                        {
                            insert lstTVR;
                        }
                    }
                    if(lstOpportunity[0].Product_Type__c != 'Tractor'){
                        if(borrowerCasa || coBorrowerCasa){
                            CASA_Bank_Form__c objCASA = new CASA_Bank_Form__c();
                            if(borrowerCasa)
                            {                        
                                objCASA.Applicant__c = borrowerId;
                                objCASA.Saving_Account_opened_for__c = 'Borrower';
                                if(lstOpportunity[0].Product_Type__c == 'Passenger Vehicles'){
                                    Utilities.createCaseTeamMember(caseId);
                                }
                            }
                            else if(coBorrowerCasa)
                            {                         
                                objCASA.Applicant__c = coBorrowerId;
                                objCASA.Saving_Account_opened_for__c = 'Co-Borrower';
                                if(lstOpportunity[0].Product_Type__c == 'Passenger Vehicles'){
                                    Utilities.createCaseTeamMember(caseId);
                                }
                            } 
                            
                            objCASA.Loan_Application__c = lstOpportunity[0].Id;
                                
                            objCASA.TeleVerification__c = [Select Id from TeleVerification__c where Applicant__c =: objCASA.Applicant__c LIMIT 1].Id; 
                            
                            insert objCASA; 
                        }  
                    }  
                }                
            }
            
        }
        catch(exception e)
        {            
            ErrorLoggerUtil.logErrorEvent('IND_TeleverificationDetails', 'createRealatedRecords', System.Label.Apex, e, strOppId);//CISP-2987
            throw new AuraHandledException(System.Label.ExceptionMessage);   
        } 
        return caseId; 
    }
    
    /* 
    * This method updates the document count for documents uploaded on TVR
    * against each applicant.
    * @param String applicantId - Id of the applicant
    * @param Integer docCountForTVR - document count for TVR
    * @return void
    */
    @AuraEnabled
    public static void updateDocCountForApplicant(String applicantId, Decimal docCountForTVR){
        try {
            Applicant__c applicant = new Applicant__c();
            applicant.Id = applicantId;
            applicant.Document_Count_for_TVR__c = docCountForTVR;
            update applicant;
        } catch (Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IND_TeleverificationDetails', 'updateDocCountForApplicant', System.Label.Apex, ex, applicantId);
            throw new IND_Exception(ex.getMessage());    
        }
    }

    @AuraEnabled
    public static String getState(String FinacalCityCode){
        try {
            Finacle_City__c fibacalCity = [SELECT Id, Name, City_Code__c FROM Finacle_City__c Where City_Code__c =: FinacalCityCode WITH SECURITY_ENFORCED LIMIT 1];
            City_State_Master__c cityMster = [SELECT State__c FROM City_State_Master__c WHERE Name = :fibacalCity.Name WITH SECURITY_ENFORCED LIMIT 1];
            Geo_State_Masters__c stateMaster = [SELECT Id,Name FROM Geo_State_Masters__c WHERE Id = :cityMster.State__c WITH SECURITY_ENFORCED LIMIT 1];
            return JSON.serialize(stateMaster);
        } catch (Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IND_TeleverificationDetails', 'getState', System.Label.Apex, ex, FinacalCityCode);
            throw new IND_Exception(ex.getMessage());    
        }
    }

    public class wrpTVR {
        
        //Application
        @AuraEnabled public string oppId {get; set;}
        @AuraEnabled public string oppName {get; set;}
        @AuraEnabled public string vehicleType {get; set;}
        @AuraEnabled public string applicantType {get; set;}
        @AuraEnabled public string applicantId {get; set;}
        @AuraEnabled public Decimal applicantdocCount {get; set;}
        @AuraEnabled public Decimal applicantdocCountForTVR {get; set;}
        @AuraEnabled public string applicantName {get; set;}
        @AuraEnabled public Boolean isBorrower {get; set;}
        @AuraEnabled public string applicantContactNumber {get; set;}
        @AuraEnabled public Boolean isWillingToopenBankAccountWithIIB {get; set;}
        @AuraEnabled public string applicationrelationshipWithBorrower {get; set;}
        
        //KYC
        @AuraEnabled public Boolean kycAttestationOnce {get;set;}
        @AuraEnabled public Boolean kycAadhaarCard{get;set;}
        @AuraEnabled public Boolean kycMobileLinkedAadhaar {get;set;}
        @AuraEnabled public Boolean kycUsingMobileLinkedAadhaar {get;set;}
        
        //Personal details
        @AuraEnabled public string vehicleId {get;set;}
        @AuraEnabled public string personalVehicleMake {get;set;}
        @AuraEnabled public string personalVehicleModel{get;set;}
        @AuraEnabled public string personalVehicleVariant {get;set;}        
        @AuraEnabled public Boolean personalAppliedForLoan {get;set;}
        @AuraEnabled public Boolean personalVehicleDelivered {get;set;}
        @AuraEnabled public string personalProductEndUser {get;set;}
        @AuraEnabled public string personalPurpose {get;set;}
        @AuraEnabled public string personalRemarks {get;set;}
        
        //Business details
        @AuraEnabled public string incomeDetailsId {get;set;}
        @AuraEnabled public string businessCompanyName {get;set;}
        @AuraEnabled public string businessYearsInBusiness {get;set;}
        
        //Loan details
        @AuraEnabled public string loanAmount {get; set;}
        @AuraEnabled public Boolean loanChequeBounce {get;set;}
        @AuraEnabled public Boolean loanMarginMoney {get;set;}
        @AuraEnabled public string loanWhomMarginMoney {get;set;}
        @AuraEnabled public Boolean loanReceipt {get;set;}
        @AuraEnabled public String loanAmountPaid {get;set;}
        
        //CURRENT RESIDENTIAL ADDRESS
        @AuraEnabled public Boolean currentAddressAvailable {get; set;}
        @AuraEnabled public string residenceAddressId {get; set;}
        @AuraEnabled public string residenceAddressLine1 {get; set;}
        @AuraEnabled public string residenceAddressLine2 {get; set;}
        @AuraEnabled public string residencePinCode {get; set;}
        @AuraEnabled public string residenceCity {get; set;}
        @AuraEnabled public string residenceDistrict {get; set;}
        @AuraEnabled public string residenceCityFinacle {get; set;}
        @AuraEnabled public string residenceState {get; set;}
        @AuraEnabled public string residenceLandmark {get; set;}
        @AuraEnabled public string residenceFIId {get; set;}
        @AuraEnabled public Boolean residenceAddressVerifiedWithKYC {get; set;}
        
        //PERMANENT RESIDENTIAL ADDRESS
        @AuraEnabled public string permanentAddressId {get; set;}
        @AuraEnabled public string permanentAddressLine1 {get; set;}
        @AuraEnabled public string permanentAddressLine2 {get; set;}
        @AuraEnabled public string permanentPinCode {get; set;}
        @AuraEnabled public string permanentCity {get; set;}
        @AuraEnabled public string permanentDistrict{get; set;}
        @AuraEnabled public string permanentFinacle {get; set;}
        @AuraEnabled public string permanentState {get; set;}
        @AuraEnabled public string permanentLandmark {get; set;}
        @AuraEnabled public string permanentresidenceFIId {get; set;}
        @AuraEnabled public Boolean permanentAddressVerifiedWithKYC {get; set;}
        
        //CURRENT OFFICE ADDRESS
        @AuraEnabled public string officeAddressId {get; set;}
        @AuraEnabled public string officeAddressLine1 {get; set;}
        @AuraEnabled public string officeAddressLine2 {get; set;}
        @AuraEnabled public string officePinCode {get; set;}
        @AuraEnabled public string officeCity {get; set;}
        @AuraEnabled public string officeDistrict {get; set;}
        @AuraEnabled public string officeCityFinacle {get; set;}
        @AuraEnabled public string officeState {get; set;}
        @AuraEnabled public string officeLandmark {get; set;}
        
        //GENERAL
        @AuraEnabled public Boolean customerInformedProvideKYCIn3Months {get;set;}
        @AuraEnabled public Boolean moneyAskedForProcessingDownPayment {get;set;}
        
        //NOMINEE DETAILS borrower 
        @AuraEnabled public string casaBankId {get;set;}
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
        
        //INDI4596
         //NOMINEE DETAILS for co-borrower
        @AuraEnabled public string CB_casaBankId {get;set;}
        @AuraEnabled public string CB_nomineeSAAccountOpening {get;set;}
        @AuraEnabled public string CB_nomineeSAAccountOpenedFor {get;set;}
        @AuraEnabled public Boolean CB_nomineeAvailable {get;set;}
        @AuraEnabled public string CB_nomineeName {get;set;}
        @AuraEnabled public Date   CB_nomineeDOB {get;set;}
        @AuraEnabled public string CB_nomineeAddress {get;set;}
        @AuraEnabled public String CB_nomineePinCode {get;set;}
        @AuraEnabled public string CB_nomineeCity {get;set;}
		@AuraEnabled public string CB_nomineeCityId {get;set;}
        @AuraEnabled public string CB_nomineeState {get;set;}
		@AuraEnabled public string CB_nomineeStateId {get;set;}
        @AuraEnabled public string CB_nomineeRelationshipBorrower {get;set;}
        
        //REMARKS
        @AuraEnabled public string tvrId {get; set;}
        @AuraEnabled public String tvrAttempts {get; set;}
        @AuraEnabled public string tvrassessment {get; set;}
        @AuraEnabled public string tvrRemarks {get; set;}
        
        //@AuraEnabled public List<Finacle_City__c> lstFinacleValues {get; set;}

        //REFERENCE DETAILS 
        @AuraEnabled public string nameRef1Value {get;set;}
        @AuraEnabled public string relationRef1Value {get;set;}
        @AuraEnabled public string addressLine1Ref1Value {get;set;}
        @AuraEnabled public String addressLine2Ref1Value {get;set;}
        @AuraEnabled public string stateRef1Value {get;set;}
        @AuraEnabled public String districtRef1Value {get;set;}
        @AuraEnabled public string cityRef1Value {get;set;}
        @AuraEnabled public String pincodeRef1Value {get;set;}
        @AuraEnabled public string phoneNumberRef1Value {get;set;}
        @AuraEnabled public string nameRef2Value {get;set;}
        @AuraEnabled public string relationRef2Value {get;set;}
        @AuraEnabled public string addressLine1Ref2Value {get;set;}
        @AuraEnabled public String addressLine2Ref2Value {get;set;}
        @AuraEnabled public string stateRef2Value {get;set;}
        @AuraEnabled public String districtRef2Value {get;set;}
        @AuraEnabled public string cityRef2Value {get;set;}
        @AuraEnabled public String pincodeRef2Value {get;set;}
        @AuraEnabled public string phoneNumberRef2Value {get;set;}

        @AuraEnabled public string residenceCityFinacleValue {get;set;}
        @AuraEnabled public string permanentFinacleValue {get;set;}
        @AuraEnabled public string officeCityFinacleValue {get;set;}
        @AuraEnabled public string alternateMobileNumber {get;set;}
        @AuraEnabled public Boolean isPassengerVehicle {get;set;}
        @AuraEnabled public String camRecId {get;set;}
        @AuraEnabled public String whoWillRepayLoan {get;set;}

        //VEHICLE DETAILS
        @AuraEnabled public string dealerName {get;set;}
        @AuraEnabled public string manufacturerYearMonth {get;set;}
        @AuraEnabled public string lastOwnerName {get;set;}
        @AuraEnabled public string numberOfOwnerships {get;set;}
        @AuraEnabled public string engineNumber {get;set;}
        @AuraEnabled public string chassisNumber {get;set;}
        @AuraEnabled public string lienInFavorOf {get;set;}
        @AuraEnabled public string rcRetentionApplicable {get;set;}
        @AuraEnabled public string insuranceNumber {get;set;}
        @AuraEnabled public string insurerName {get;set;}
        @AuraEnabled public string insuranceType {get;set;}
        @AuraEnabled public Decimal insuranceDeclaredValue {get;set;}
        @AuraEnabled public Date insIssuanceDate {get;set;}
        @AuraEnabled public Date insExpiryDate {get;set;}
        @AuraEnabled public Boolean insExpiringWhithin60Days {get;set;}
    }
    
    @AuraEnabled
    public static String getProductType(String tvrId){
        try {
            TeleVerification__c teleRec = [SELECT Id, Loan_Application__r.Product_Type__c 
                                            FROM TeleVerification__c 
                                            WHERE Id =:tvrId
                                            WITH SECURITY_ENFORCED];
            return teleRec.Loan_Application__r.Product_Type__c;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getTVRId(String caseId){
        try {
            String loanId = [SELECT Id, Loan_Application__c FROM Case WHERE Id =:caseId WITH SECURITY_ENFORCED].Loan_Application__c;
            String TVRId = [SELECT Id FROM TeleVerification__c WHERE Loan_Application__c =:loanId AND Applicant__r.Applicant_Type__c = 'Borrower' WITH SECURITY_ENFORCED].Id;
            return TVRId;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}