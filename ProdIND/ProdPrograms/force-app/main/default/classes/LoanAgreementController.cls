/*------------------------------------------------------------
Author:        Daksh Mandowara
Class Name:    LoanAgreementController
Description:   Class to handle operations for IND_LWC_LoanAgreement
------------------------------------------------------------*/
public with sharing class LoanAgreementController {
    /*
   * @Method Name: isRequiredStageCompleted
   * @Created by:  Daksh Mandowara
   * @description: For checking if required stage is completed or not
   * @Param:       String - Opportunity Id
   */
   @AuraEnabled
   public static String isRequiredStageCompleted(String oppId, String dealId){
       try {
           if(String.isNotBlank(oppId)){
               List<Opportunity> opps = [SELECT Id,Vehicle_Type__c FROM Opportunity WHERE Id = :oppId WITH SECURITY_ENFORCED]; 
               if(!opps.isEmpty()){
                   
                   if(opps[0].Vehicle_Type__c.equals('Used') || opps[0].Vehicle_Type__c.equals('Refinance')){
                       List<Case> tvrCases = [SELECT Id, Status FROM Case WHERE RecordType.Name='TVR' AND Loan_Application__c=:oppId AND Loan_Application__r.Product_Type__c != 'Passenger Vehicles' WITH SECURITY_ENFORCED LIMIT 1];
                       if(!tvrCases.isEmpty()){
                           if(tvrCases[0].Status.equals('Pass')){
                               return System.Label.true;
                           }else{
                               return System.Label.tvrStatusFailed;
                           }
                       }else{
                           return System.Label.true;
                       }
                   }else if(opps[0].Vehicle_Type__c.equals('New')){
                       List<Loan_Application_Transaction_History__c> history = [SELECT Submitted_Flag__c FROM Loan_Application_Transaction_History__c 
                                                                       WHERE Loan_Application_ID__c = :oppId 
                                                                       AND (Module_Name__c='Post Sanction Checks and Documentation' OR Module__c='Post Sanction Checks and Documentation') 
                                                                       AND Screen__c =: System.Label.IHM AND Deal_Number__c =: dealId WITH SECURITY_ENFORCED LIMIT 1];
                       if(!history.isEmpty()){
                           if(history[0].Submitted_Flag__c){
                               List<Case> tvrCases = [SELECT Id, Status FROM Case WHERE RecordType.Name='TVR' AND Loan_Application__c=:oppId AND Loan_Application__r.Product_Type__c != 'Passenger Vehicles' WITH SECURITY_ENFORCED LIMIT 1];
                               if(!tvrCases.isEmpty()){
                                   if(tvrCases[0].Status.equals('Pass')){
                                       return  System.Label.true;
                                   }else{
                                       return  System.Label.tvrStatusFailed;
                                   }
                               }else{
                                   return  System.Label.true;
                               }
                           }else{
                               return System.Label.submittedFlagFailed;
                           }
                       }
                   }
               }
           }
           
           return System.Label.submittedFlagFailed;
       } catch (Exception e) {
           ErrorLoggerUtil.logErrorEvent('LoanAgreementController', 'isPreDisbursementLASubmitted', System.Label.Apex, e,oppId);
           throw new AuraHandledException(e.getMessage());
       }
   }
   /*
   * @Method Name: isPreDisbursementLASubmitted
   * @Created by:  Daksh Mandowara
   * @description: For checking if Pre-Disbursement Loan Agreement is Submitted or not.
   * @Param:       String - Opportunity Id
   */
   @AuraEnabled
   public static PreDisburstmentWrapper isPreDisbursementLASubmitted(String oppId, String dealId){
       try {
            PreDisburstmentWrapper preDisburstmentWrapper = new PreDisburstmentWrapper();
           List<Loan_Application_Transaction_History__c> history = [SELECT Submitted_Flag__c FROM Loan_Application_Transaction_History__c 
                                                               WHERE Loan_Application_ID__c = :oppId 
                                                               AND (Module_Name__c='Pre Disbursement Check' OR Module__c='Pre Disbursement Check') 
                                                               AND Screen__c = 'Loan Agreement' AND Deal_Number__c =: dealId WITH SECURITY_ENFORCED LIMIT 1];
            Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE Id = :oppId WITH SECURITY_ENFORCED LIMIT 1];
            preDisburstmentWrapper.currentBackEndStage = opp.StageName;
           if(!history.isEmpty()){
            preDisburstmentWrapper.isSubmitted = history[0].Submitted_Flag__c;
           }
           return preDisburstmentWrapper;
       } catch (Exception e) {
           ErrorLoggerUtil.logErrorEvent('LoanAgreementController', 'isPreDisbursementLASubmitted', System.Label.Apex, e,oppId);
           throw new AuraHandledException(e.getMessage());
       }
   }
   public class PreDisburstmentWrapper{
    @AuraEnabled
    public String currentBackEndStage{get;set;}
    @AuraEnabled
    public Boolean isSubmitted{get;set;}
   }
   /*
   * @Method Name: isPostSanctionLASubmitted
   * @Created by:  Daksh Mandowara
   * @description: For checking if Post-Sanction Loan Agreement is Submitted or not.
   * @Param:       String - Opportunity Id
   */
   @AuraEnabled
   public static boolean isPostSanctionLASubmitted(String oppId, String dealId){
       try {
           List<Loan_Application_Transaction_History__c> history = [SELECT Submitted_Flag__c FROM Loan_Application_Transaction_History__c 
                                                               WHERE Loan_Application_ID__c = :oppId 
                                                               AND (Module_Name__c='Post Sanction Checks and Documentation' OR Module__c='Post Sanction Checks and Documentation') 
                                                               AND Screen__c = 'Loan Agreement' AND Deal_Number__c =: dealId WITH SECURITY_ENFORCED LIMIT 1];
           if(!history.isEmpty()){
               return history[0].Submitted_Flag__c;
           }
           return false;
       } catch (Exception e) {
           ErrorLoggerUtil.logErrorEvent('LoanAgreementController', 'isPostSanctionLASubmitted', System.Label.Apex, e,oppId);
           throw new AuraHandledException(e.getMessage());
       }
   }
   /*
   * @Method Name: updateLoanTransacionToSubmitted
   * @Created by:  Daksh Mandowara
   * @description: To Update the submit flag of Post Sanction's Loan Agreement Screen Loan Transaction History record.
   * @Param:       String - Opportunity Id
   */
   @AuraEnabled
   public static boolean updateLoanTransacionToSubmitted(String oppId, String dealId){
       try {
           List<Loan_Application_Transaction_History__c> history = [SELECT Submitted_Flag__c FROM Loan_Application_Transaction_History__c 
                                                               WHERE Loan_Application_ID__c = :oppId 
                                                               AND (Module_Name__c='Post Sanction Checks and Documentation' OR Module__c='Post Sanction Checks and Documentation') 
                                                               AND Screen__c = 'Loan Agreement' AND Deal_Number__c =: dealId WITH SECURITY_ENFORCED LIMIT 1];
           if(!history.isEmpty() && !history[0].Submitted_Flag__c){
               if(!history[0].Submitted_Flag__c){
                   history[0].Submitted_Flag__c = true;
                   update history[0];
               }
               return true;
           }
           return false;
       } catch (Exception e) {
           ErrorLoggerUtil.logErrorEvent('LoanAgreementController', 'updateLoanTransacionToSubmitted', System.Label.Apex, e,oppId);
           throw new AuraHandledException(e.getMessage());
       }
   }
    
    
    
   /*
  * @Method Name: updateLoanTransacionToSubmitted
  * @Created by:  Daksh Mandowara
  * @description: To Update the submit flag of Post Sanction's Loan Agreement Screen Loan Transaction History record.
  * @Param:       String - Opportunity Id
  */
  @AuraEnabled
  public static boolean GetLoanapplicationHistory(String oppId){
      try {
        if(oppId != null){
            List<Loan_Application_Transaction_History__c> history = [SELECT Submitted_Flag__c FROM Loan_Application_Transaction_History__c 
                                                                     WHERE Loan_Application_ID__c = :oppId 
                                                                     AND (Module_Name__c='Post Sanction Checks and Documentation' OR Module__c='Post Sanction Checks and Documentation') 
                                                                     AND Screen__c = 'Loan Agreement' WITH SECURITY_ENFORCED LIMIT 1];
            if(!history.isEmpty() && history[0].Submitted_Flag__c== true){
                
                return true;
            }
            return false;
        }
        return false;
      } catch (Exception e) {
          ErrorLoggerUtil.logErrorEvent('LoanAgreementController', 'GetLoanapplicationHistory', System.Label.Apex, e,oppId);
          throw new AuraHandledException(e.getMessage());
      }
  }
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   

  /*
   * @Method Name: updateLoanTransacionHistoryToSubmitted
   * @Created by:  Daksh Mandowara
   * @description: To Update the submit flag of Pre-Disbursement's Loan Agreement Screen Loan Transaction History record.
   * @Param:       String - Opportunity Id
   */
   @AuraEnabled
   public static boolean updateLoanTransacionHistoryToSubmitted(String oppId, String dealId){
       try {
           List<Loan_Application_Transaction_History__c> history = [SELECT Submitted_Flag__c FROM Loan_Application_Transaction_History__c 
                                                               WHERE Loan_Application_ID__c = :oppId 
                                                               AND (Module_Name__c='Pre Disbursement Check' OR Module__c='Pre Disbursement Check') 
                                                               AND Screen__c = 'Loan Agreement' AND Deal_Number__c =: dealId WITH SECURITY_ENFORCED LIMIT 1];
           if(!history.isEmpty() && !history[0].Submitted_Flag__c){
               if(!history[0].Submitted_Flag__c){
                   history[0].Submitted_Flag__c = true;
                   update history[0];
               }
               return true;
           }
           return false;
       } catch (Exception e) {
           ErrorLoggerUtil.logErrorEvent('LoanAgreementController', 'updateLoanTransacionHistoryToSubmitted', System.Label.Apex, e,oppId);
           throw new AuraHandledException(e.getMessage());
       }
   }

   /*
   * @Method Name: getLoanAgreement
   * @Created by:  Daksh Mandowara
   * @description: To get the loan agreement record.
   * @Param:       String - Opportunity Id
   */
   @AuraEnabled
   public static LoanAgreementWrapper getLoanAgreement(String oppId, String dealId){
       try {
            Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:oppId WITH SECURITY_ENFORCED];
            List<Loan_Agreement__c> loanAgreeList = new List<Loan_Agreement__c>();
            if(oppRec.Product_Type__c == System.Label.Tractor){
                loanAgreeList = [SELECT Id FROM Loan_Agreement__c WHERE Loan_Application__c =: oppId AND Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
            }else{
                loanAgreeList = [SELECT Id FROM Loan_Agreement__c WHERE Loan_Application__c =: oppId WITH SECURITY_ENFORCED];
            }

            if(loanAgreeList.size() == 0){
                Loan_Agreement__c loanAgreement = new Loan_Agreement__c();
                loanAgreement.Loan_Application__c = oppId;
                if(oppRec.Product_Type__c == System.Label.Tractor){
                    loanAgreement.Deal_Number__c = dealId;
                }
                if(Schema.sObjectType.Loan_Agreement__c.iscreateable()){
                    insert loanAgreement;
                }
            }
            LoanAgreementWrapper loanAgreementWrapperObj = new LoanAgreementWrapper();
            List<Loan_Agreement__c> laList = new List<Loan_Agreement__c>();

            List<Final_Term__c> finaltermsList = new List<Final_Term__c>();
            List<Documents__c> documentList = new List<Documents__c>();

            String docKycRecordTypeId = Schema.getGlobalDescribe().get('Documents__c').getDescribe().getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();

            if(oppRec.Product_Type__c == System.Label.Tractor){
                List<Vehicle_Detail__c> VehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
                laList = [SELECT Id,Agreement_Type__c,Loan_Application__r.Finance_Amount__c,
                            Loan_Application__r.Agent_BL_code__c,Loan_Application__r.Product_Type__c,Loan_Application__r.StageName,Loan_Application__r.Total_Funded_Premium__c,
                            Loan_Application__r.Sanction_Date__c, Loan_Application__r.Vehicle_Type__c,Is_Additional_Loan_Agreement_Stamp_Duty__c,
                            Agreement_Booklet_Num__c,ScannedBookLet__c,Ist_EMI_Due_Date__c,Add_POA_SD_Initiation_method__c
                            FROM Loan_Agreement__c 
                            WHERE Loan_Application__c=: oppId AND Deal_Number__c =: dealId
                            WITH SECURITY_ENFORCED];
                finaltermsList = [SELECT id,Loan_Amount__c,Loan_Application__r.Total_Funded_Premium__c,Vehicle_Detail__r.Total_Funded_Amount__c
                                    FROM Final_Term__c 
                                    WHERE Loan_Application__c = :oppId AND Vehicle_Detail__c =: VehicleLst[0].Id
                                    WITH SECURITY_ENFORCED 
                                    LIMIT 1];
                documentList = [SELECT Id,Applicant__r.Applicant_Type__c,Document_Type__c 
                                    FROM Documents__c 
                                    WHERE (RecordTypeId =: docKycRecordTypeId OR Document_Type__c = 'Form 60') AND Opportunity_Relation__c =: oppId AND is_Active__c = true AND Vehicle_Detail__c =: VehicleLst[0].Id
                                    WITH SECURITY_ENFORCED];
                
            }else{
                laList = [SELECT Id,Agreement_Type__c,Loan_Application__r.Finance_Amount__c,
                            Loan_Application__r.Agent_BL_code__c,Loan_Application__r.Product_Type__c,Loan_Application__r.StageName,Loan_Application__r.Total_Funded_Premium__c,
                            Loan_Application__r.Sanction_Date__c, Loan_Application__r.Vehicle_Type__c,Is_Additional_Loan_Agreement_Stamp_Duty__c,
                            Agreement_Booklet_Num__c,ScannedBookLet__c,Ist_EMI_Due_Date__c,Add_POA_SD_Initiation_method__c
                            FROM Loan_Agreement__c 
                            WHERE Loan_Application__c=: oppId 
                            WITH SECURITY_ENFORCED];
                finaltermsList = [SELECT id,Loan_Amount__c,Loan_Application__r.Total_Funded_Premium__c 
                                    FROM Final_Term__c 
                                    WHERE Loan_Application__c = :oppId 
                                    WITH SECURITY_ENFORCED 
                                    LIMIT 1];
                documentList = [SELECT Id,Applicant__r.Applicant_Type__c,Document_Type__c 
                                    FROM Documents__c 
                                    WHERE (RecordTypeId =: docKycRecordTypeId OR Document_Type__c = 'Form 60') AND Opportunity_Relation__c =: oppId AND is_Active__c = true 
                                    WITH SECURITY_ENFORCED];
            }
        
            Map<String,Map<String,Documents__c>> documentMapAccApplicant = new Map<String,Map<String,Documents__c>>();
            for(Documents__c document : documentList){
                if(documentMapAccApplicant.containskey(document.Applicant__r.Applicant_Type__c)){
                    Map<String,Documents__c> documentMapTemp = documentMapAccApplicant.get(document.Applicant__r.Applicant_Type__c);
                    documentMapTemp.put(document.Document_Type__c,document);
                    documentMapAccApplicant.put(document.Applicant__r.Applicant_Type__c,documentMapTemp);
                }else{
                    Map<String,Documents__c> documentMapTemp = new Map<String,Documents__c>();
                    documentMapTemp.put(document.Document_Type__c,document);
                    documentMapAccApplicant.put(document.Applicant__r.Applicant_Type__c,documentMapTemp);
                }
            }

            Integer borrowerKycDocCount = 0;
            Integer coBorrowerKycDocCount = 0;

            for(Applicant__c applicant : [Select Id,Applicant_Type__c From Applicant__c Where Opportunity__c = :oppId AND In_Active_Applicant__c = false With SECURITY_ENFORCED]){
                if(documentMapAccApplicant.containsKey(applicant.Applicant_Type__c)){
                    Map<String,Documents__c> documentMap = documentMapAccApplicant.get(applicant.Applicant_Type__c);
                    if(applicant.Applicant_Type__c == System.Label.Borrower && documentMap.containsKey('Form 60')){
                        if(documentMap.containsKey(System.Label.AadhaarCard)){
                            borrowerKycDocCount++;
                        }
                        if(documentMap.containsKey(System.Label.VoterIdCard)){
                            borrowerKycDocCount++;
                        }
                        if(documentMap.containsKey(System.Label.DrivingLicences)){
                            borrowerKycDocCount++;
                        }
                        if(documentMap.containsKey(System.Label.PassportCard)){
                            borrowerKycDocCount++;
                        }
                    }else if(applicant.Applicant_Type__c == System.Label.CoBorrower && documentMap.containsKey('Form 60')){
                        if(documentMap.containsKey(System.Label.AadhaarCard)){
                            coBorrowerKycDocCount++;
                        }
                        if(documentMap.containsKey(System.Label.VoterIdCard)){
                            coBorrowerKycDocCount++;
                        }
                        if(documentMap.containsKey(System.Label.DrivingLicences)){
                            coBorrowerKycDocCount++;
                        }
                        if(documentMap.containsKey(System.Label.PassportCard)){
                            coBorrowerKycDocCount++;
                        }
                    }
                }
            }

            if(borrowerKycDocCount == 1 || coBorrowerKycDocCount == 1){
                loanAgreementWrapperObj.isEligibleForEAgreement = false;
            }else{
                loanAgreementWrapperObj.isEligibleForEAgreement = true;
            }
            //CISP-133 - END
            if(!laList.isEmpty()){
                loanAgreementWrapperObj.loanAgreement = laList[0];
                if(oppRec.Product_Type__c == System.Label.Tractor){
                    loanAgreementWrapperObj.financeAmount = !finaltermsList.isEmpty() ? Decimal.valueOf(finaltermsList[0].Loan_amount__c) + (finaltermsList[0].Vehicle_Detail__r.Total_Funded_Amount__c  == null ? 0 : finaltermsList[0].Vehicle_Detail__r.Total_Funded_Amount__c): 0;
                }else{
                    loanAgreementWrapperObj.financeAmount = !finaltermsList.isEmpty() ? Decimal.valueOf(finaltermsList[0].Loan_amount__c) + laList[0].Loan_Application__r.Total_Funded_Premium__c : laList[0].Loan_Application__r.Total_Funded_Premium__c;
                }
                return loanAgreementWrapperObj;
            }
            return null;
       } catch (Exception e) {
           ErrorLoggerUtil.logErrorEvent('LoanAgreementController', 'getLoanAgreement', System.Label.Apex, e,oppId);
           throw new AuraHandledException(e.getMessage());
       }
   }

   public class LoanAgreementWrapper{
    @AuraEnabled
    public Double financeAmount;
    @AuraEnabled
    public Loan_Agreement__c loanAgreement;
    @AuraEnabled
    public Boolean isEligibleForEAgreement; //CISP-133
   }
   
   public LoanAgreementController (String loanAppId){
       try{    
           List<TeleVerification__c> teleVerificationList=[Select id,Is_customer_using_Aadhar_Linked_Mob_No__c,Applicant__r.Aadhar_No__c,Loan_Application__c from TeleVerification__c where Loan_Application__c=:loanAppId WITH SECURITY_ENFORCED];
       }catch(Exception ex){
           ErrorLoggerUtil.logErrorEvent('LoanAgreementController', 'Constructor', System.Label.Apex, ex,loanAppId);
           throw new AuraHandledException(ex.getMessage());
       }
   }
   
   /*
   * @Method Name: getTeleVerificationDetails
   * @Created by:  Daksh Mandowara
   * @description: To get the TeleVerification details.
   * @Param:       String - Opportunity Id
   */
   public List<TeleVerification__c> getTeleVerificationDetails(String loanAppId){

       try{   
           List<TeleVerification__c> teleVerificationList=[Select id,Is_customer_using_Aadhar_Linked_Mob_No__c,Applicant__r.Aadhar_No__c,Loan_Application__c from TeleVerification__c where Loan_Application__c=:loanAppId WITH SECURITY_ENFORCED];
           if(!teleVerificationList.isEmpty()){
               return teleVerificationList;
           }  
           return null;
       }catch(Exception ex){
           ErrorLoggerUtil.logErrorEvent('LoanAgreementController', 'getTeleVerificationDetails', System.Label.Apex, ex,loanAppId);
           throw new AuraHandledException(ex.getMessage());
       }   
   }
   /*
   * @Method Name: getGeoGraphicalState
   * @Created by:  Daksh Mandowara
   * @description: To get the geo graphical state from BL Code Details.
   * @Param:       String - Agent BL Code
   */
   @AuraEnabled
   public static String getGeoGraphicalState(String loanApplicationId){
       try{
           List<Opportunity> loanApps = [SELECT Id,Product_Type__c,Agent_BL_code__c FROM Opportunity WHERE Id = :loanApplicationId];
           String productCode = String.isNotBlank(loanApps[0].Product_Type__c)?
                                   loanApps[0].Product_Type__c.equals('Two Wheeler')?'H':
                                       loanApps[0].Product_Type__c.equals('Passenger Vehicles')?'C':
                                       loanApps[0].Product_Type__c.equals(System.Label.Tractor)?'T':
                                           loanApps[0].Product_Type__c:'';
           List<BankBranchDetails__c> bankBranchDetail = [SELECT Id,Geo_State_Code__c,Geo_State_Master__c,Geo_State_Master__r.Name FROM BankBranchDetails__c WHERE Bl_Code__c = :loanApps[0].Agent_BL_code__c AND Geo_State_Code__c!=NULL AND Product__c = :productCode WITH SECURITY_ENFORCED];
           if(!bankBranchDetail.isEmpty() && bankBranchDetail[0].Geo_State_Master__c != null && String.isNotBlank(bankBranchDetail[0].Geo_State_Master__r.Name)){
               return bankBranchDetail[0].Geo_State_Master__r.Name+'_'+bankBranchDetail[0].Geo_State_Code__c;
           }else{
               return System.label.NoGeoStateCodeFound;
           }
       }catch(Exception ex){
           ErrorLoggerUtil.logErrorEvent('LoanAgreementController', 'getGeoGraphicalState', System.Label.Apex, ex);
           throw new AuraHandledException(ex.getMessage());
       }
   }

   /*
   * @Method Name: getGeoGraphicalState
   * @Created by:  Daksh Mandowara
   * @description: To get the tax invoice date from Invoice Details.
   * @Param:       String - Opportunity Id
   */
   @AuraEnabled
   public static Date getTaxInvoiceDate(String loanAppId, String dealId){
       try{
        Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanAppId WITH SECURITY_ENFORCED];
        List<Invoice_Details__c> invoice = new List<Invoice_Details__c>();
        if(oppRec.Product_Type__c == System.Label.Tractor){
            invoice = [SELECT Id,Tax_Invoice_Date__c 
                        FROM Invoice_Details__c 
                        WHERE Loan_Application__c = :loanAppId AND Deal_Number__c =: dealId
                        WITH SECURITY_ENFORCED 
                        LIMIT 1];
        }else{
            invoice = [SELECT Id,Tax_Invoice_Date__c 
                        FROM Invoice_Details__c 
                        WHERE Loan_Application__c = :loanAppId 
                        WITH SECURITY_ENFORCED 
                        LIMIT 1];
        }
        if(!invoice.isEmpty() && invoice[0].Tax_Invoice_Date__c != null){
            return invoice[0].Tax_Invoice_Date__c;
        }
        return null;
       }catch(Exception ex){
           ErrorLoggerUtil.logErrorEvent('LoanAgreementController', 'getTaxInvoiceDate', System.Label.Apex, ex,loanAppId);
           throw new AuraHandledException(ex.getMessage());
       }
   }

   /*
   * @Method Name: getAdvancedEMI
   * @Created by:  Daksh Mandowara
   * @description: To get the Advance EMI flag from Final Term.
   * @Param:       String - Opportunity Id
   */
   @AuraEnabled
   public static Final_Term__c getAdvancedEMI(String loanAppId, String dealId){
       try{            
        Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanAppId WITH SECURITY_ENFORCED];
        List<Final_Term__c> finalTerm = new List<Final_Term__c>();
        if(oppRec.Product_Type__c == System.Label.Tractor){
            List<Vehicle_Detail__c> VehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
            finalTerm = [SELECT Id,Advance_EMI__c,Holiday_period__c 
                            FROM Final_Term__c 
                            WHERE Loan_Application__c = :loanAppId AND Vehicle_Detail__c =: VehicleLst[0].Id
                            WITH SECURITY_ENFORCED 
                            LIMIT 1];
        }else{
            finalTerm = [SELECT Id,Advance_EMI__c,Holiday_period__c 
                            FROM Final_Term__c 
                            WHERE Loan_Application__c = :loanAppId 
                            WITH SECURITY_ENFORCED 
                            LIMIT 1];
        }
        
        if(!finalTerm.isEmpty()){
            return finalTerm[0];
        }else{
            return null;
        }
       }catch(Exception e){
           ErrorLoggerUtil.logErrorEvent('LoanAgreementController', 'getAdvancedEMI', System.Label.Apex, e,loanAppId);
           throw new AuraHandledException('Didn\'t found any Final Term Details');
       }
   }
   
   // @AuraEnabled
   // public static TotalStamping getTotalStampValues(String loanAgrementId,String loanAppId){
   //     try{
   //         TotalStamping ts = new TotalStamping();
   //         ts.totalStampingOfExistingLA = 0;
   //         ts.totalStampingOfAdditionalLA = 0;
   //         ts.totalStampingDone = 0;
   //         for(AggregateResult agg : [SELECT SUM(Stamp_Value__c),Type__c FROM Stamp_Detail__c WHERE Loan_Agreement__c = :loanAgrementId GROUP BY Type__c]){
   //             String type = (String)agg.get('Type__c');
   //             if(type.equals('Loan Agreement')){
   //                 ts.totalStampingOfExistingLA = (Decimal)agg.get('expr0');
   //             }else if(type.equals('Additional LA')){
   //                 ts.totalStampingOfAdditionalLA = (Decimal)agg.get('expr0');
   //             }
   //             ts.totalStampingDone += (Decimal)agg.get('expr0');
   //         }
   //         return ts;
   //     }catch(Exception ex){
   //         ErrorLoggerUtil.logErrorEvent('LoanAgreementController', 'getTotalStampValues', System.Label.Apex, ex,loanAppId);
   //         throw new AuraHandledException(ex.getMessage());
   //     }
   // }
   /*
   * @Method Name: getStampingDetails
   * @Created by:  Daksh Mandowara
   * @description: To get the Stamping Details flag from Final Term.
   * @Param:       String - Opportunity Id
   */
   @AuraEnabled
   public static StampingList getStampingDetails(String loanAgrementId, String loanAppId){
       try{
           List<Stamp_Detail__c> existingStampList = new List<Stamp_Detail__c>();
           List<Stamp_Detail__c> additionalStampList = new List<Stamp_Detail__c>();
           List<Stamp_Detail__c> stampingList = [SELECT Stamp_S_No__c,Stamp_Towards__c,Stamp_Type__c,Stamp_Value__c,Stamp_Date__c,Stamp_For__c,Type__c,Stamp_Location_Type__c FROM Stamp_Detail__c WHERE Loan_Agreement__c = :loanAgrementId WITH SECURITY_ENFORCED];
           StampingList stamping = new StampingList();
           Decimal totalStampingOfExistingLA = 0;
           Decimal totalStampingOfAdditionalLA = 0;
           Decimal totalStampingDone = 0;
           if(!stampingList.isEmpty()){
               for(Stamp_Detail__c stmp : stampingList){
                   if(stmp.Type__c.equals('Loan Agreement')){
                       existingStampList.add(stmp);
                       totalStampingOfExistingLA += stmp.Stamp_Value__c!=null?stmp.Stamp_Value__c:0;
                   }else if(stmp.Type__c.equals('Additional LA')){
                       additionalStampList.add(stmp);
                       totalStampingOfAdditionalLA += stmp.Stamp_Value__c!=null?stmp.Stamp_Value__c:0;
                   }
                   totalStampingDone += stmp.Stamp_Value__c!=null?stmp.Stamp_Value__c:0;
               }
               stamping.existingStamping = existingStampList;
               stamping.additionalStamping = additionalStampList;
               stamping.totalStampingOfExistingLA = totalStampingOfExistingLA;
               stamping.totalStampingOfAdditionalLA = totalStampingOfAdditionalLA;
               stamping.totalStampingDone = totalStampingDone;
               return stamping;
           }else{
               return null;
           }
       }catch(Exception ex){
           ErrorLoggerUtil.logErrorEvent('LoanAgreementController', 'getStampingDetails', System.Label.Apex, ex,loanAppId);
           throw new AuraHandledException(ex.getStackTraceString()+ex.getMessage());
       }
   }

   /*
   * @Method Name: currentUserProfile
   * @Created by:  Daksh Mandowara
   * @description: To get the current user profile details.
   * @Param:       String - userId
   */
   @AuraEnabled
   public static String currentUserProfile(String userId){
       try{
           List<User> userDetail = [SELECT Id,ProfileId,Profile.Name FROM User WHERE Id = :userId];
           if(!userDetail.isEmpty()){
               return userDetail[0].Profile.Name;
           }
           return null;
       }catch(Exception ex){
           ErrorLoggerUtil.logErrorEvent('LoanAgreementController', 'currentUserProfile', System.Label.Apex, ex);
           throw new AuraHandledException(ex.getMessage());
       }
   }

   /*
   * @Method Name: insertAdditionalStampings
   * @Created by:  Daksh Mandowara
   * @description: For inserting additional stampings.
   * @Param:       String - JSONResponse & agreementId
   */
   @AuraEnabled
   public static void insertAdditionalStampings(String JSONResponse,String agreementId){
       try{
           if(String.isNotBlank(JSONResponse)){
            List<Stamp_Detail__c> insertedList = new List<Stamp_Detail__c>();
               List<Stamp_Detail__c> listOfStamps = (List<Stamp_Detail__c>) JSON.deserialize(JSONResponse, List<Stamp_Detail__c>.class);
               if(!listOfStamps.isEmpty()){
                    for(Stamp_Detail__c st :listOfStamps){
                        if(st.Stamp_Value__c != null){
                            insertedList.add(st);
                        }
                    }
                    if(!insertedList.isEmpty()){
                        upsert insertedList;
                    }
               }
               if(String.isNotBlank(agreementId)){
                   Loan_Agreement__c loanAgr = new Loan_Agreement__c();
                   loanAgr.Id = agreementId;
                   loanAgr.Is_Additional_Loan_Agreement_Stamp_Duty__c = true;
                   if(loanAgr!=null){
                       update loanAgr;
                   }
               }
           }
       }catch(Exception ex){
           ErrorLoggerUtil.logErrorEvent('LoanAgreementController', 'insertAdditionalStampings', System.Label.Apex, ex);
           throw new AuraHandledException(ex.getMessage());
       }
   }

    /*
   * @Method Name: getAgreementBookletDetails
   * @Created by:  Daksh Mandowara
   * @description: For getting agreement booklet details.
   * @Param:       String - responseStr, Loan Agrement Id, Loan Application Id, Booklet Number
   */
   @AuraEnabled
   public static Loan_Agreement__c getAgreementBookletDetails(String responseStr, String loanAgrementId, String loanAppId, String bookletNumber, String dealId){
       try{
            Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanAppId WITH SECURITY_ENFORCED];
           Loan_Agreement__c loanAgr = new Loan_Agreement__c();
               loanAgr.Id = loanAgrementId;    
           loanAgr.Agreement_Booklet_Num__c = bookletNumber;
           List<TeleVerification__c> tvrData = [Select Is_customer_having_an_Aadhar_Card__c, Is_customer_using_Aadhar_Linked_Mob_No__c, Is_customer_s_Mob_No_linked_to_Aadhar__c,Applicant__r.Applicant_Type__c from TeleVerification__c where Loan_Application__c=:loanAppId WITH SECURITY_ENFORCED];
           if(tvrData.size() > 0){ 
               for(TeleVerification__c tvr : tvrData){
                   if(tvr.Applicant__r.Applicant_Type__c.equals('Borrower')){
                       loanAgr.Borrower_Has_Aadharcard__c = tvr.Is_customer_having_an_Aadhar_Card__c;
                       loanAgr.Borrower_Aadhar_Mobile_In_Use__c = tvr.Is_customer_using_Aadhar_Linked_Mob_No__c;
                       loanAgr.Borrower_Aadhar_Linked_To_Mobile__c = tvr.Is_customer_s_Mob_No_linked_to_Aadhar__c;
                   }else if(tvr.Applicant__r.Applicant_Type__c.equals('Co-borrower')){
                       loanAgr.CoBorrower_Has_Aadharcard__c = tvr.Is_customer_having_an_Aadhar_Card__c;
                       loanAgr.CoBorrower_Aadhar_Mobile_In_Use__c = tvr.Is_customer_using_Aadhar_Linked_Mob_No__c;
                       loanAgr.CoBorrower_Aadhar_Linked_To_Mobile__c = tvr.Is_customer_s_Mob_No_linked_to_Aadhar__c;
                   }
               }
           }

           if(oppRec.Product_Type__c == System.Label.Tractor){
            loanAgr.Deal_Number__c = dealId;
           }

           if(loanAgr!=null){
               upsert loanAgr;
           }
       System.debug(responseStr);
       IND_AgreementBookletResponse resData = (IND_AgreementBookletResponse)JSON.deserialize(responseStr, IND_AgreementBookletResponse.class);
       System.debug(resData);
       List<Stamp_Detail__c> stampDetails = new List<Stamp_Detail__c>();
       AgreementBookletDetails agrDetails = new AgreementBookletDetails();
       if(resData != null && resData?.response?.content.size() > 0){
           for(IND_AgreementBookletResponse.Content con : resData.response.content){
               if(con.Stamp_Towards.equals('AGREEMENT')){
                   Stamp_Detail__c stmp = new Stamp_Detail__c();
                   stmp.Stamp_S_No__c = con.Stamp_S_No;
                   stmp.Stamp_Towards__c = con.Stamp_Towards;
                   stmp.Stamp_Type__c = con.Stamp_Type;
                   stmp.Stamp_Value__c = con.Stamp_Value != null ? decimal.valueOf(con.Stamp_Value) : null;
                   //CISP-2484
                   List<String> dateList = new List<String>();
                   if(resData.response.content[0].Stamp_On != null){
                    dateList = resData.response.content[0].Stamp_On.split('/');
                   }
                   if(dateList.size() == 3){
                     Date stampDate = Date.newInstance(Integer.valueOf(dateList[2]),Integer.valueOf(dateList[1]),Integer.valueOf(dateList[0]));
                     stmp.Stamp_Date__c = stampDate;
                   }
                   //CISP-2484
                   stmp.Stamp_For__c = con.Stamped_For;
                   stmp.Stamp_Printed_Location_Blcode__c = con.Stamp_Printed_Location_Blcode;
                   stmp.Stamp_Printed_Location_BlName__c = con.Stamp_Printed_Location_BlName;
                   stmp.Type__c = 'Loan Agreement';
                   stmp.Loan_Agreement__c = loanAgrementId;
                   stampDetails.add(stmp);
               }
           }
       }
       if(!stampDetails.isEmpty()){
           insert stampDetails;
       }
       
       
       
       return loanAgr;
   }catch(Exception ex){
       ErrorLoggerUtil.logErrorEvent('LoanAgreementController', 'getAgreementBookletDetails', System.Label.Apex, ex,loanAppId);
       throw new AuraHandledException(ex.getMessage());
   }
}
/*
   * @Method Name: getLoanApplicationDetails
   * @Created by:  Satyam Singh
   * @description: To get Opportunity Data.
   * @Param:       String - Loan Application Id
   */
@AuraEnabled
public static Opportunity getLoanApplication(string loanAppId){
    try {
        Opportunity LoanAppDetail =[select Id ,Product_Type__c from Opportunity where Id =:loanAppId];
        return LoanAppDetail;
        
    } catch (Exception ex) {
        ErrorLoggerUtil.logErrorEvent('LoanAgreementController', 'getAgreementBookletDetails', System.Label.Apex, ex,loanAppId);
        throw new AuraHandledException(ex.getMessage());
    }
}
/*
   * @Method Name: getTVRDetails
   * @Created by:  Satyam Singh
   * @description: To get TVR Data.
   * @Param:       String - Loan Application Id
   */
@AuraEnabled
public static List<TeleVerification__c> getTVRDetails(string loanAppId){
    try {
        List<TeleVerification__c> tvrData = [Select Is_customer_having_an_Aadhar_Card__c, Is_customer_using_Aadhar_Linked_Mob_No__c, Is_customer_s_Mob_No_linked_to_Aadhar__c,Applicant__r.Applicant_Type__c,Applicant__r.Name from TeleVerification__c where Loan_Application__c=:loanAppId AND Applicant__r.Applicant_Type__c ='Co-borrower' and Applicant__r.In_Active_Applicant__c = false WITH SECURITY_ENFORCED];
        return tvrData;
    } catch (Exception ex) {
        ErrorLoggerUtil.logErrorEvent('LoanAgreementController', 'getTVRDetails', System.Label.Apex, ex,loanAppId);
        throw new AuraHandledException(ex.getMessage());
    }
}

/*
   * @Method Name: getDocumentData
   * @Created by:  Daksh Mandowara
   * @description: To get Document Data.
   * @Param:       String - Loan Application Id
   */
@AuraEnabled
   public static List<Documents__c> getDocumentData(String loanApplicationId, String dealId){
       try{
            Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED];
            List<Documents__c> docList = new List<Documents__c>();
            if(oppRec.Product_Type__c == System.Label.Tractor){
                List<Vehicle_Detail__c> VehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
                docList = [SELECT Id, Name, Applicant__c, Vehicle_Detail__c, Document_Type__c, Opportunity_Relation__c,is_active__c 
                            FROM Documents__c 
                            WHERE Opportunity_Relation__c =:loanApplicationId AND Is_active__c = true AND Document_Type__c = 'Agreement Copy' AND Vehicle_Detail__c =: VehicleLst[0].Id
                            WITH SECURITY_ENFORCED];
            }else{
                docList = [SELECT Id, Name, Applicant__c, Vehicle_Detail__c, Document_Type__c, Opportunity_Relation__c,is_active__c 
                            FROM Documents__c 
                            WHERE Opportunity_Relation__c =:loanApplicationId AND Is_active__c = true AND Document_Type__c = 'Agreement Copy' 
                            WITH SECURITY_ENFORCED];
            }
           
            if(!docList.isEmpty()){
                return docList;
            }else
                return null;
           
       }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_VehicleInspectionRCLimitDetails', 'saveFinalButtonStatus', System.Label.Apex, ex,loanApplicationId);
           throw new IND_Exception(ex.getMessage()); 
       }
   }
/*
   * @Method Name: getVehicleID
   * @Created by:  Gaurav Rawat
   * @description: get Vehicle Id realted to deal number
   * @Param:       String loanApplicationId, String - deal Id
   */
@AuraEnabled
   public static String getVehicleID(String loanApplicationId, String dealId){
       try{
            List<Vehicle_Detail__c> VehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED LIMIT 1];
            return VehicleLst.size() > 0 ? VehicleLst[0].Id : '';
           
       }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_VehicleInspectionRCLimitDetails', 'saveFinalButtonStatus', System.Label.Apex, ex,loanApplicationId);
       }
       return '';
   }
   
   /*
   * @Class Name: StampingList
   * @Created by:  Daksh Mandowara
   * @description: Wrapper class: To get & set the stamping List.
   * @Param:       String - Loan Application Id
   */
   public class StampingList{
       @AuraEnabled
       public List<Stamp_Detail__c> existingStamping;
       @AuraEnabled
       public List<Stamp_Detail__c> additionalStamping;
       @AuraEnabled
       public Decimal totalStampingOfExistingLA;
       @AuraEnabled
       public Decimal totalStampingOfAdditionalLA;
       @AuraEnabled
       public Decimal totalStampingDone;
   }
   
   /*
   * @Class Name: deleteLoanAgreementDetails
   * @Created by:  Gaurav Rawat
   * @description: To delete the Loan Agreement Details and insert the new one.
   * @Param:       String - Loan Agreement Id
   */
   @AuraEnabled
   public static String deleteLoanAgreementDetails(String loanApplication, String currentAgreementBookletNumber, String dealId){
       try{
            Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanApplication WITH SECURITY_ENFORCED];
            List<Loan_Agreement__c> loanAgreementList = new List<Loan_Agreement__c>();

            Map<Id,Documents__c> docMap=new Map<Id,Documents__c>();

            List<Documents__c> doccList = new List<Documents__c>();

            if(oppRec.Product_Type__c == System.Label.Tractor){
                List<Vehicle_Detail__c> VehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
                loanAgreementList = [SELECT Id 
                                        FROM Loan_Agreement__c 
                                        WHERE Loan_Application__c =:loanApplication AND Deal_Number__c =: dealId
                                        WITH SECURITY_ENFORCED];
                doccList = [SELECT Id,Document_Type__c 
                                FROM Documents__c 
                                WHERE Opportunity_Relation__c=:loanApplication AND is_Active__c= true AND Document_Type__c = 'Agreement Copy' AND Vehicle_Detail__c =: VehicleLst[0].Id
                                WITH SECURITY_ENFORCED];
            }else{
                loanAgreementList = [SELECT Id 
                                        FROM Loan_Agreement__c 
                                        WHERE Loan_Application__c =:loanApplication 
                                        WITH SECURITY_ENFORCED];
                doccList = [SELECT Id,Document_Type__c 
                                FROM Documents__c 
                                WHERE Opportunity_Relation__c=:loanApplication AND is_Active__c= true AND Document_Type__c = 'Agreement Copy' 
                                WITH SECURITY_ENFORCED];
            }

            for(Documents__c doc : doccList){
                docMap.put(doc.Id, doc);
            }

            List<ContentDocumentLink> listOfContentLinkDocs=new List<ContentDocumentLink>([SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN:docMap.keySet() WITH SECURITY_ENFORCED]);
            
            Set<Id> cdIds=new Set<Id>();
            if(!docMap.isEmpty()){
                    for(ContentDocumentLink cd:[SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN:docMap.keySet() WITH SECURITY_ENFORCED]){
                        cdIds.add(cd.ContentDocumentId);
                    }
                }
                List<ContentDocument> listOfContentDocs=new List<ContentDocument>([SELECT Id, Title,ContentSize,FileType,Owner.Name,ParentId FROM ContentDocument WHERE Id IN:cdIds ORDER BY CreatedDate DESC LIMIT 10000]);

                if(Schema.sObjectType.ContentDocumentLink.isDeletable()){
                    delete listOfContentLinkDocs;
                }
                if(Schema.sObjectType.ContentDocument.isDeletable()){
                    delete listOfContentDocs;
                }
                if(loanAgreementList.size() > 0 && Schema.sObjectType.Loan_Agreement__c.isDeletable()){
                delete loanAgreementList;
                Loan_Agreement__c loanAgreement = new Loan_Agreement__c();
                loanAgreement.Loan_Application__c = loanApplication;
                loanAgreement.Agreement_Booklet_Num__c = currentAgreementBookletNumber;

                if(oppRec.Product_Type__c == System.Label.Tractor){
                    loanAgreement.Deal_Number__c = dealId;
                }

                if(Schema.sObjectType.Loan_Agreement__c.iscreateable()){
                    insert loanAgreement;
                    return loanAgreement.Id;
                }
            }
            return 'error';
       }catch(Exception ex){
           ErrorLoggerUtil.logErrorEvent('LoanAgreementController', 'deleteLoanAgreementDetails', System.Label.Apex, ex,loanApplication);
           throw new IND_Exception(ex.getMessage()); 
       }
   }
   
    @AuraEnabled
   public static boolean getAPIsCalloutResponse(String loanAppId){
    list<Loan_Agreement__c> LoanAgreement =[select Id ,Agreement_Type__c,Existing_LA_Stamp_S_No__c,Existing_LA_Stamp_On__c,Existing_LA_Stamped_For__c,Existing_LA_Stamped_Towards__c,Existing_LA_Stamp_Type__c,Existing_LA_Stamp_Value__c from Loan_Agreement__c where Loan_Application__c =:loanAppId Limit 1];
   system.debug('LoanAgreement-->'+LoanAgreement[0]);
    if(LoanAgreement[0].Agreement_Type__c!=null && (LoanAgreement[0].Existing_LA_Stamp_S_No__c!='' || LoanAgreement[0].Existing_LA_Stamp_On__c!=null || LoanAgreement[0].Existing_LA_Stamped_For__c!='' || LoanAgreement[0].Existing_LA_Stamped_Towards__c!='' || LoanAgreement[0].Existing_LA_Stamp_Type__c!='' || LoanAgreement[0].Existing_LA_Stamp_Value__c!=null)){
       	system.debug('Inside If');
        return true;
   }
   return false;
   }

   /*
    * @Method Name: checkApiCalloutStatus
    * @Created by:  Gaurav Rawat
    * @description: To get the Loan Agreement Details.
    * @Param:       String - Loan Application Id
    */
   @AuraEnabled
   public static APIStatusWrapper checkApiCalloutStatus(String loanApplicationId,String loanAgreementId, String dealId){
    Boolean isBorrower = false;
    Boolean isCoBorrower = false;
    try {
        Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED];
        APIStatusWrapper apiStatusWrapper = new APIStatusWrapper();
        List<Loan_Agreement__c> loanAgreementList = new List<Loan_Agreement__c>();
        if(oppRec.Product_Type__c == System.Label.Tractor){
            loanAgreementList = [SELECT Id,Agreement_Type__c,Add_POA_SD_Agreement_signed_for_borrower__c,Add_POA_SD_Agreement_signed_for_co_borro__c,AgreementDate__c 
                                    FROM Loan_Agreement__c 
                                    WHERE Id =:loanAgreementId AND Deal_Number__c =: dealId
                                    WITH SECURITY_ENFORCED];
        }else{
            loanAgreementList = [SELECT Id,Agreement_Type__c,Add_POA_SD_Agreement_signed_for_borrower__c,Add_POA_SD_Agreement_signed_for_co_borro__c,AgreementDate__c 
                                    FROM Loan_Agreement__c 
                                    WHERE Id =:loanAgreementId 
                                    WITH SECURITY_ENFORCED];
        }
        List<Applicant__c> applicantList = new List<Applicant__c>([SELECT Id,Applicant_Type__c FROM Applicant__c WHERE Opportunity__c =:loanApplicationId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED]);
        if(loanAgreementList.size() > 0){
            apiStatusWrapper.agreementDate = String.valueof(loanAgreementList[0].AgreementDate__c);
            apiStatusWrapper.agreementType = loanAgreementList[0].Agreement_Type__c == null ? '' : loanAgreementList[0].Agreement_Type__c;
            System.debug('loanAgreementList[0].Agreement_Type__c' + loanAgreementList[0].Agreement_Type__c);
            for(Applicant__c applicant : applicantList){
                if(applicant.Applicant_Type__c == System.Label.Borrower){
                    isBorrower = true;
                }else if(applicant.Applicant_Type__c == System.Label.CoBorrower){
                    isCoBorrower = true;
                }
            }
            apiStatusWrapper.isBorrowerApiSuccess =  isBorrower ? loanAgreementList[0].Add_POA_SD_Agreement_signed_for_borrower__c : true;
            apiStatusWrapper.isCoBorrowerApiSuccess = isCoBorrower ? loanAgreementList[0].Add_POA_SD_Agreement_signed_for_co_borro__c : true;
        }
        System.debug('apiStatusWrapper '+apiStatusWrapper);
        return apiStatusWrapper;
    } catch (Exception e) {
        ErrorLoggerUtil.logErrorEvent('LoanAgreementController', 'checkApiCalloutStatus', System.Label.Apex, e,loanApplicationId);
        throw new IND_Exception(e.getMessage());
    }
   }

   public class APIStatusWrapper{
         @AuraEnabled
         public Boolean isBorrowerApiSuccess{get;set;}
         @AuraEnabled
         public Boolean isCoBorrowerApiSuccess{get;set;}
         @AuraEnabled
         public String agreementDate{get;set;}
         @AuraEnabled
         public String agreementType{get;set;}

         APIStatusWrapper(){
            isBorrowerApiSuccess = false;
            isCoBorrowerApiSuccess = false;
            agreementDate = '';
            agreementType = '';
         }
   }

   /* 
   * @Method Name: validateScannedDocs
   * @Created By: Gaurav Rawat
    @description :   To validate the scanned documents.
    @param :  String loanApplicationId
    @return : String
   */
    @AuraEnabled
    public static Boolean validateScannedDocs(String loanApplicationId, String dealId) {
        Boolean isAllDocsAvailable = false;
        List<ContentDocument> listOfBookletContentDocs = new List<ContentDocument>();
        try {
                Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED];
                Map<String, Object> returnMap = new Map<String, Object>();
                Map<Id,Documents__c> docMap=new Map<Id,Documents__c>();
                List<Documents__c> documentsList = new List<Documents__c>();
                if(oppRec.Product_Type__c == System.Label.Tractor){
                    List<Vehicle_Detail__c> VehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
                    documentsList = [SELECT Id,Document_Type__c 
                                        FROM Documents__c 
                                        WHERE Opportunity_Relation__c=:loanApplicationId AND is_Active__c= true AND Document_Type__c = 'Agreement Copy' AND Vehicle_Detail__c =: VehicleLst[0].Id
                                        WITH SECURITY_ENFORCED];
                }else{
                    documentsList = [SELECT Id,Document_Type__c 
                                        FROM Documents__c 
                                        WHERE Opportunity_Relation__c=:loanApplicationId AND is_Active__c= true AND Document_Type__c = 'Agreement Copy' 
                                        WITH SECURITY_ENFORCED];
                }

                for(Documents__c doc: documentsList){
                    docMap.put(doc.Id,doc);
                }
                Set<Id> cdIds=new Set<Id>();
                List<ContentDocument> listOfContentDocs=new List<ContentDocument>();
                if(!docMap.isEmpty()){
                    for(ContentDocumentLink cd:[SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN:docMap.keySet() WITH SECURITY_ENFORCED]){
                        cdIds.add(cd.ContentDocumentId);
                    }
                }
                listOfContentDocs=[SELECT Id, Title,ContentSize,FileType,Owner.Name,ParentId FROM ContentDocument WHERE Id IN:cdIds ORDER BY CreatedDate DESC LIMIT 10000];
                returnMap.put('records', listOfContentDocs);

                listOfBookletContentDocs = (List<ContentDocument>) returnMap.get('records');
                if(listOfBookletContentDocs.size() >= 1) {
                    isAllDocsAvailable = true;
                }
                return isAllDocsAvailable;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IHMPageController', 'validateIHMDocs', System.Label.Apex, e, loanApplicationId);
            throw new IND_Exception(e.getMessage());
        }
    }

    //CISP-2420 AND CISP-2418 - START
   /* 
   * @Method Name: isEmiDatesCapturedInBackend
   * @Created By: Gaurav Rawat
    @description :   To check emi date is saved in backed.
    @param :  String loanApplicationId
    @return : String
   */
    @AuraEnabled
    public static Boolean isEmiDatesCapturedInBackend(String loanApplicationId, String dealId) {
        Boolean isEmiDatesCapturedInBackend = false;
        try {
            Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED];
            List<Loan_Agreement__c> loanAgreeList = new List<Loan_Agreement__c>();
            if(oppRec.Product_Type__c == System.Label.Tractor){
                loanAgreeList = [SELECT Id,Ist_EMI_Due_Date__c,X2nd_EMI_Due_Date__c 
                                    FROM Loan_Agreement__c 
                                    WHERE Loan_Application__c =: loanApplicationId AND Deal_Number__c =: dealId
                                    WITH SECURITY_ENFORCED];
            }else{
                loanAgreeList = [SELECT Id,Ist_EMI_Due_Date__c,X2nd_EMI_Due_Date__c 
                                    FROM Loan_Agreement__c 
                                    WHERE Loan_Application__c =: loanApplicationId 
                                    WITH SECURITY_ENFORCED];
            }

            if(loanAgreeList.size() > 0){
                if(loanAgreeList[0].Ist_EMI_Due_Date__c != null && loanAgreeList[0].X2nd_EMI_Due_Date__c != null){
                    isEmiDatesCapturedInBackend = true;
                }
            }
            return isEmiDatesCapturedInBackend;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('LoanAgreementController', 'isEmiDatesCapturedInBackend', System.Label.Apex, e, loanApplicationId);
            throw new IND_Exception(e.getMessage());
        }
    }
    //CISP-2420 AND CISP-2418 - END

    //CISP-2487 - START
   /* 
   * @Method Name: isEAgreementAPIsSuccess
   * @Created By: Gaurav Rawat
    @description :   To NESL APIs successed or not.
    @param :  String oppId
    @return : EagreementAPIsStatusWrapper
   */
    @AuraEnabled
    public static EagreementAPIsStatusWrapper isEAgreementAPIsSuccess(String oppId) {
        EagreementAPIsStatusWrapper wrapperObj = new EagreementAPIsStatusWrapper();
        try {
            for(Applicant__c app : [Select Id,Applicant_Type__c,Is_Nesl_API_Succeed__c From Applicant__c Where Opportunity__c = :oppId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED]){
                if(app.Applicant_Type__c == System.Label.Borrower && app.Is_Nesl_API_Succeed__c){
                    wrapperObj.borrowerAPIsSuccessed = true;
                }else if(app.Applicant_Type__c == System.Label.CoBorrower && app.Is_Nesl_API_Succeed__c){
                    wrapperObj.coBorrowerAPIsSuccessed = true;
                }
            }
            return wrapperObj;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('LoanAgreementController', 'isEAgreementAPIsSuccess', System.Label.Apex, e, oppId);
            throw new IND_Exception(e.getMessage());
        }
    }

    public class EagreementAPIsStatusWrapper{
        @AuraEnabled
        public Boolean borrowerAPIsSuccessed{get;set;}
        @AuraEnabled
        public Boolean coBorrowerAPIsSuccessed{get;set;}
        public EagreementAPIsStatusWrapper(){
            this.borrowerAPIsSuccessed = false;
            this.coBorrowerAPIsSuccessed = false;
        }
    }
    // CISP-2487- END
}