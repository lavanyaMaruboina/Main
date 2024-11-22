/*------------------------------------------------------------
 Author:        Poonam Tilokani
 Company:       Manras
 Description:   IND_VehicleInspectionRCLimitDetails is used to store and get vehicle details. 
 Apex Class :   IND_VehicleInspectionRCLimitDetails
 Test Class:    IND_VehicleInspectionRCLimitDetailsTest
------------------------------------------------------------*/

public with sharing class IND_VehicleInspectionRCLimitDetails {
    
    /*
   * @Method:      getVehicleDetailsRecord
   * @Created by:  Poonam Tilokani
   * @Description: This method is used to get vehicle detail record.
   * @Param:       String - Loan Application ID
   * @Return:      Vehicle_Detail__c
   */
    @AuraEnabled
    public static Vehicle_Detail__c getVehicleDetailsRecord(String loanApplicationId, String dealId){
        try{
            Opportunity loanApplicationDetails = new Opportunity();
            List<Vehicle_Detail__c> vehicleDetails = new List<Vehicle_Detail__c>();
            vehicleDetails = [SELECT Id,Engine_Number_during_Inspection__c,Vehicle_SubCategory__c,Chassis_Number_during_Inspection__c,Vehicle_Reg_No_during_Inspection__c,
                              Location_of_Vehicle_Inspection__c,Engine_number__c, Chassis_number__c, Vehicle_Registration_number__c, Dealer_Sub_dealer_name__c,Remarks__c,
                              Finance_Amount__c,Vehicle_inspection_approved_by_CVO__c,CVO_remarks__c,CVO_Remarks_for_RC_Limit__c,Is_RC_Limit_Check_correctly_captured__c,Can_we_continue_with_above_RC_limit__c,Vehicle_Delivered__c from Vehicle_Detail__c where Loan_Application__c =: loanApplicationId And Deal_Number__c =: dealId  WITH SECURITY_ENFORCED LIMIT 1];
            if(vehicleDetails.size()>0){
                system.debug('vehicleDetails[0] :::'+ vehicleDetails[0]);
                return vehicleDetails[0];
            }
            return null;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_VehicleInspectionRCLimitDetails', 'getVehicleDetailsRecord', System.Label.Apex, ex,loanApplicationId);
            throw new IND_Exception(ex.getMessage());   
        }
    }

     /*
   * @Method:      getCaseId
   * @Created by:  Santhosh Guhan
   * @User Story:  SFTRAC-99
   * @Description: This method is used to get case Id for the asset verification.
   * @Param:       String - Loan Application ID
   * @Return:      String - Case Id
   */
  @AuraEnabled
  public static string getCaseId(String loanApplicationId){
      try{
          List<Case> asvCase = new List<Case>();
          asvCase = [SELECT Id FROM Case WHERE Loan_Application__c =: loanApplicationId And Recordtype.Name = 'Asset Verification'  WITH SECURITY_ENFORCED LIMIT 1];
          if(asvCase.size()>0){
              return asvCase[0].Id;
          }
          return null;
      }
      catch(Exception ex){
          ErrorLoggerUtil.logErrorEvent('IND_VehicleInspectionRCLimitDetails', 'getCaseId', System.Label.Apex, ex,loanApplicationId);
          throw new IND_Exception(ex.getMessage());   
      }
  }
 
    /*
   * @Method:      getLoanApplicationDetails
   * @Created by:  Poonam Tilokani
   * @Description: This method is used to get loan application and check weather logged in user is same as owner or not.
   * @Param:       String - Loan Application ID
   * @Return:      String
   */
    @AuraEnabled
    public static String getLoanApplicationDetails(String loanApplicationId){
        try{
             Map<String,Object> returnMap = new Map<String, Object>();
            List<Opportunity> loanApplicationDetails = new List<Opportunity>();
            loanApplicationDetails = [SELECT Id,OwnerId,Finance_Amount__c, Name,Loan_Application_Number__c,Ben_Code__c,Product_Type__c, Vehicle_Type__c,StageName,Sub_Stage__c,LeadSource  from Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED];

            if(loanApplicationDetails.size()>0){
                returnMap.put('loanApplication',loanApplicationDetails[0]);
                User Usr =[SELECT Id,profile.name,userType FROM User WHERE Id = : UserInfo.getUserId()];
                if(loanApplicationDetails[0].ownerId == usr.Id){
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
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_VehicleInspectionRCLimitDetails', 'getVehicleType', System.Label.Apex, ex,loanApplicationId);
            throw new IND_Exception(ex.getMessage());   
        }
    }
        /*
    * @Method:      getLoanAmountfromFO
    * @Created by:  Poonam Tilokani
    * @Description: This method is used to get Loan Amount from Final Offer page and check if it is >=15 Lacs.
    * @Param:       String - Loan Application ID
    * @Return:      Boolean
    */
    @AuraEnabled
   
    public static Boolean getLoanAmountfromFO(String loanApplicationId, String dealId){

        try{
            List<Final_Term_Loan_Amount__mdt>  finalTeramLoanList = [SELECT Id, DeveloperName, MasterLabel, Loan_Amount__c FROM Final_Term_Loan_Amount__mdt WITH SECURITY_ENFORCED LIMIT 1];
            List<Final_Term__c> finalTerms = new List<Final_Term__c>();
            Opportunity opp = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =: loanApplicationId LIMIT 1];
            if(opp.Product_Type__c == System.Label.Tractor){
                List<Vehicle_Detail__c> VehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
                finalTerms = [SELECT Id, Loan_Amount__c,Referrer_Ben_Code__c 
                                FROM Final_Term__c 
                                WHERE Loan_Application__c =: loanApplicationId AND Vehicle_Detail__c =: VehicleLst[0].Id 
                                WITH SECURITY_ENFORCED LIMIT 1];
            }else{
                finalTerms = [SELECT Id, Loan_Amount__c,Referrer_Ben_Code__c FROM Final_Term__c WHERE Loan_Application__c =: loanApplicationId WITH SECURITY_ENFORCED LIMIT 1];
            }
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
 	/*
    * @Method:      getApplicantId
    * @Created by:  Poonam Tilokani
    * @Description: This method return applicant Id.
    * @Param:       String - Loan Application ID
    * @Return:      String
    */
    @AuraEnabled
    public static String getApplicantId(String loanApplicationId){
        try{

            List<Applicant__c> applicants=[select Id,Name, Applicant_Type__c,Scorecard_Decision__c,Who_will_repay_the_loan__c, Gender__c, Journey_Stage__c, Contact_number__c,Opportunity__r.Product_Type__c
            from Applicant__c where Opportunity__c = :loanApplicationId WITH SECURITY_ENFORCED];

            List<Applicant__c> validApplicants = new List<Applicant__c>();
            if(applicants.size()>0){
                for(Applicant__c applicant : applicants){
                    if(applicant.Applicant_Type__c == System.Label.Borrower && applicant.Opportunity__r.Product_Type__c == System.Label.Tractor){
                        return applicant.Id;
                    }
                    if(applicant.Who_will_repay_the_loan__c != applicant.Applicant_Type__c){
                        continue;
                    }else if(applicant.Scorecard_Decision__c == 'Orange'){
                        return applicant.Id;
                    }
                }
            }
            return null;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_VehicleInspectionRCLimitDetails', 'getValidApplicants', System.Label.Apex, ex,loanApplicationId);
            throw new IND_Exception(ex.getMessage());   
        }
    }
	/*
    * @Method:      getValidApplicants
    * @Created by:  Poonam Tilokani
    * @Description: This method is used to check weather applicant is valid or not according to their scrorecard.
    * @Param:       String - Loan Application ID
    * @Return:      Boolean
    */
    @AuraEnabled
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
    * @Method:      updateVehicleInspectionRCDetails
    * @Created by:  Poonam Tilokani
    * @Description: This method is used to update vehicle details record.
    * @Param:       String - Loan Application ID , String Vehicle Detail Id ,String Vehicle data. 
    * @Return:      void
    */
    @AuraEnabled
    public static void updateVehicleInspectionRCDetails(String loanApplicationId, String vehicleRecordId, string vehicleInspectionDetails, String dealId){
        try{

            if (vehicleInspectionDetails != null) {
                vehicleDetailsWrapper vehicleDetailsObj = (vehicleDetailsWrapper) JSON.deserialize(vehicleInspectionDetails, vehicleDetailsWrapper.class);
                if(vehicleDetailsObj != null){
                    Vehicle_Detail__c vehicleDetails = new Vehicle_Detail__c();
                    vehicleDetails.Id = vehicleRecordId;
                    vehicleDetails.Engine_Number_during_Inspection__c = vehicleDetailsObj.engineNumber;
                    vehicleDetails.Chassis_Number_during_Inspection__c = vehicleDetailsObj.chassisNumber;
                    vehicleDetails.Vehicle_Reg_No_during_Inspection__c = vehicleDetailsObj.vehicleRegNumber;
                    vehicleDetails.Location_of_Vehicle_Inspection__c = vehicleDetailsObj.locationOfVehicle;
                    vehicleDetails.Remarks__c = vehicleDetailsObj.remarks;

                    update vehicleDetails;
                    
                    List<Loan_Application_Transaction_History__c> lATList=[Select id,Name,Submitted_Flag__c from Loan_Application_Transaction_History__c where Loan_Application_ID__c=:loanApplicationId  and Name='Vehicle Inspection and RC Check' And Module__c = 'Post Sanction Checks and Documentation' And Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
                    if(lATList!=null && lATList.size()>0){
                        lATList[0].Submitted_Flag__c = false;
                        update lATList;
                    }
                }
            }
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_VehicleInspectionRCLimitDetails', 'updateVehicleInspectionRCDetails', System.Label.Apex, ex,loanApplicationId);
            throw new IND_Exception(ex.getMessage());   
        }
    }
	/*
    * @Method:      saveRCLimitResponseDetails
    * @Created by:  Poonam Tilokani
    * @Description: This method is used to update vehicle details record.
    * @Param:       String - Loan Application ID , String Vehicle Detail Id ,String Response comes from api. 
    * @Return:      Boolean
    */
    @AuraEnabled
    public static Boolean saveRCLimitResponseDetails(String loanApplicationId, String vehicleRecordId, string response){
        try{
            system.debug('response :::'+ response);
            system.debug('vehicleRecordId :::'+ vehicleRecordId);

            if (response != null) {
                RCLimitCheckResponseWrapper RCLimitResponseObj = (RCLimitCheckResponseWrapper) JSON.deserialize(response, RCLimitCheckResponseWrapper.class);
                system.debug('RCLimitResponseObj :::'+ RCLimitResponseObj);
                if(RCLimitResponseObj != null){
                    Vehicle_Detail__c rcLimitResponseDetails = new Vehicle_Detail__c();
                    rcLimitResponseDetails.Id = vehicleRecordId;
                    if(RCLimitResponseObj.No_Of_Proposals_Available == null || RCLimitResponseObj.No_Of_Proposals_Available == ''){
                        rcLimitResponseDetails.No_Of_Proposals_Available__c = 0;
                    }else{
                        rcLimitResponseDetails.No_of_proposals_available__c = Integer.ValueOf(RCLimitResponseObj.No_Of_Proposals_Available);
                    }
                    if(RCLimitResponseObj.Available_Disbursal_Amount == null || RCLimitResponseObj.Available_Disbursal_Amount == ''){
                        rcLimitResponseDetails.Available_Disbursal_Amount__c = 0;
                    }
                    else{
                        rcLimitResponseDetails.Available_disbursal_amount__c = Integer.valueOf(RCLimitResponseObj.Available_Disbursal_Amount);
                    }
                    rcLimitResponseDetails.No_of_days_RC_Pending__c = (RCLimitResponseObj.Pending_Flag == 'Y') ? true : false;

                    update rcLimitResponseDetails;

                    return true;
                }
                return false;
            }
            return false;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_VehicleInspectionRCLimitDetails', 'saveRCLimitResponseDetails', System.Label.Apex, ex,loanApplicationId);
            throw new IND_Exception(ex.getMessage());   
        }

    }
	/*
    * @Method:      savecontinueWithRCLimitvalue
    * @Created by:  Poonam Tilokani
    * @Description: This method is used to update vehicle details record.
    * @Param:       String - Loan Application ID , String Vehicle Detail Id ,Boolean continueWithRCLimit. 
    * @Return:      void
    */
    @AuraEnabled
    public static void savecontinueWithRCLimitvalue(String loanApplicationId, String vehicleRecordId, Boolean continueWithRCLimit){
        try{
                
                Vehicle_Detail__c vehicleDetails = new Vehicle_Detail__c();
                vehicleDetails.Id = vehicleRecordId;
                vehicleDetails.Can_we_continue_with_above_RC_limit__c = continueWithRCLimit;
                update vehicleDetails;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_VehicleInspectionRCLimitDetails', 'savecontinueWithRCLimitvalue', System.Label.Apex, ex,loanApplicationId);
            throw new IND_Exception(ex.getMessage());   
        }
    }

    /*
    * @Method:      saveRCLimitResponseDetailsForDSA
    * @Created by:  Poonam Tilokani
    * @Description: This method is used to update Final terms record.
    * @Param:       String - Loan Application ID , String FinalTerm Id ,String Response comes from api. 
    * @Return:      Boolean
    */
    @AuraEnabled
    public static Boolean saveRCLimitResponseDetailsForDSA(String loanApplicationId, String finalTermID, string response){
        try{
            system.debug('response :::'+ response);
            system.debug('finalTermID :::'+ finalTermID);

            if (response != null) {
                RCLimitCheckResponseWrapper RCLimitResponseObj = (RCLimitCheckResponseWrapper) JSON.deserialize(response, RCLimitCheckResponseWrapper.class);
                system.debug('RCLimitResponseObj :::'+ RCLimitResponseObj);
                if(RCLimitResponseObj != null){
                    Final_Term__c rcLimitResponseDetails = new Final_Term__c();
                    rcLimitResponseDetails.Id = finalTermID;
                    if(RCLimitResponseObj.No_Of_Proposals_Available == null || RCLimitResponseObj.No_Of_Proposals_Available == ''){
                        rcLimitResponseDetails.No_Of_Proposals_Available__c = 0;
                    }else{
                        rcLimitResponseDetails.No_of_proposals_available__c = Integer.ValueOf(RCLimitResponseObj.No_Of_Proposals_Available);
                    }
                    if(RCLimitResponseObj.Available_Disbursal_Amount == null || RCLimitResponseObj.Available_Disbursal_Amount == ''){
                        rcLimitResponseDetails.Available_Disbursal_Amount__c = 0;
                    }
                    else{
                        rcLimitResponseDetails.Available_disbursal_amount__c = Integer.valueOf(RCLimitResponseObj.Available_Disbursal_Amount);
                    }
                    rcLimitResponseDetails.No_of_days_RC_Pending__c = (RCLimitResponseObj.Pending_Flag == 'Y') ? true : false;

                    update rcLimitResponseDetails;

                    return true;
                }
                return false;
            }
            return false;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_VehicleInspectionRCLimitDetails', 'saveRCLimitResponseDetailsForDSA', System.Label.Apex, ex,loanApplicationId);
            throw new IND_Exception(ex.getMessage());   
        }

    }
    /*
    * @Method:      savecontinueWithRCLimitvalueForDSA
    * @Created by:  Poonam Tilokani
    * @Description: This method is used to update Final Term record.
    * @Param:       String - Loan Application ID , String Final Term Id ,Boolean continueWithRCLimit. 
    * @Return:      void
    */
    @AuraEnabled
    public static void savecontinueWithRCLimitvalueForDSA(String loanApplicationId, String finalTermID, Boolean continueWithRCLimit){
        try{
                
                Final_Term__c finalTermDetails = new Final_Term__c();
                finalTermDetails.Id = finalTermID;
                finalTermDetails.Can_we_continue_with_above_RC_limit__c = continueWithRCLimit;
                update finalTermDetails;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_VehicleInspectionRCLimitDetails', 'savecontinueWithRCLimitvalueForDSA', System.Label.Apex, ex,loanApplicationId);
            throw new IND_Exception(ex.getMessage());   
        }
    }

    /*
    * @Method:      updateTransactionRecord
    * @Created by:  Poonam Tilokani
    * @Description: This method is used to update Loan application transaction history record for post sanction module.
    * @Param:       String - Loan Application ID. 
    * @Return:      void
    */
    @AuraEnabled
    public static void updateTransactionRecord(String loanApplicationId, String dealId){
        try{
            Opportunity oppObj = [Select Id,StageName From Opportunity Where Id =: loanApplicationId];
            List<Loan_Application_Transaction_History__c> lATList=[Select id,Name,Submitted_Flag__c from Loan_Application_Transaction_History__c where Loan_Application_ID__c=:loanApplicationId  and Name='Vehicle Inspection and RC Check' And Module__c = :oppObj.StageName And Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
            if(lATList.size()>0){
                lATList[0].Submitted_Flag__c = true;
                update lATList;
            }
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_VehicleInspectionRCLimitDetails', 'updateTransactionRecord', System.Label.Apex, ex,loanApplicationId);
            throw new IND_Exception(ex.getMessage());   
        }
    }
    /*
    * @Method:      saveFinalButtonStatus
    * @Created by:  Poonam Tilokani
    * @Description: This method is used to update Vehicle details record.
    * @Param:       String - Loan Application ID ,String Vehicle Detail Id ,Boolean finalButtonStatus. 
    * @Return:      Boolean
    */
    @AuraEnabled
    public static Boolean saveFinalButtonStatus(String loanApplicationId, String vehicleRecordId, Boolean finalButtonStatus, String dealId){
        try{
            
            Vehicle_Detail__c vehicleDetails = new Vehicle_Detail__c();
            vehicleDetails.Id = vehicleRecordId;
            vehicleDetails.Vehicle_Inspection_RC_Limit_Submitted__c = finalButtonStatus;
            
            update vehicleDetails;
            List<Loan_Application_Transaction_History__c> lATList=[Select id,Name,Submitted_Flag__c from Loan_Application_Transaction_History__c where Loan_Application_ID__c=:loanApplicationId  and Name='Vehicle Inspection and RC Check' And Module__c = 'Post Sanction Checks and Documentation' And Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
            if(lATList!=null && lATList.size()>0){
                lATList[0].Submitted_Flag__c = true;
                update lATList;
            }
            
            return true;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_VehicleInspectionRCLimitDetails', 'saveFinalButtonStatus', System.Label.Apex, ex,loanApplicationId);
            throw new IND_Exception(ex.getMessage());   
        }
    }
	/*
    * @Method:      getDocumentData
    * @Created by:  Poonam Tilokani
    * @Description: This method is used to get document records that are capture during vehicle inspection.
    * @Param:       String - Loan Application ID ,String Vehicle Detail Id. 
    * @Return:      List<Documents__c>
    */
    @AuraEnabled
    public static List<Documents__c> getDocumentData(String loanApplicationId , String vehicleRecordId){
        try{
            List<String> docStringList = new List<String>{'Chassis Number uploaded during verification','Engine Number uploaded during verification','Selfie with Vehicle-uploaded during verification','Vehicle Front-uploaded during verification','Vehicle Back-uploaded during verification','Branch In-charge Approval Email'};
            List<Documents__c> docList = [SELECT Id, Name, Applicant__c, Vehicle_Detail__c, Document_Type__c,Opportunity_Relation__c,is_active__c 
                                          FROM Documents__c 
                                          where Opportunity_Relation__c =:loanApplicationId And Vehicle_Detail__c =:vehicleRecordId 
                                          AND Is_active__c = true AND Document_Type__c In: docStringList WITH SECURITY_ENFORCED];
            
            if(docList.size()>0){
                return docList;
            }else
                return null;
            
        }catch(Exception ex){
             ErrorLoggerUtil.logErrorEvent('IND_VehicleInspectionRCLimitDetails', 'getDocumentData', System.Label.Apex, ex,loanApplicationId);
            throw new IND_Exception(ex.getMessage()); 
        }
    }

    /*
    * @Method:      getDocumentDataTractor
    * @Created by:  Gaurav Rawat
    * @Description: This method is used to get document records that are capture during vehicle inspection.
    * @Param:       String - Loan Application ID ,String Vehicle Detail Id. 
    * @Return:      Boolean
    */
    @AuraEnabled
    public static Boolean getDocumentDataTractor(String loanApplicationId , String vehicleRecordId){
        try{
            Boolean  flag = true;
            List<String> docStringList = new List<String>{'Engine Number uploaded during verification', 'Chassis Number uploaded during verification', 'Selfie with Vehicle-uploaded during verification', 'Vehicle Front-uploaded during verification', 'Vehicle Back-uploaded during verification', 'Capture Chassis plate', 'Capture Vehicle Right Side', 'Capture Vehicle Left Side', 'Capture HMR'};
            List<Documents__c> docList = [SELECT Id,(Select Id FROM ContentDocumentLinks) FROM Documents__c where Opportunity_Relation__c =:loanApplicationId And Vehicle_Detail__c =:vehicleRecordId AND Is_active__c = true AND Document_Type__c In: docStringList WITH SECURITY_ENFORCED];

            for (Documents__c doc : docList) {
                if(doc.ContentDocumentLinks.size() == 0){
                    flag = false;
                    break;
                }
            }
            return flag;            
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_VehicleInspectionRCLimitDetails', 'getDocumentDataTractor', System.Label.Apex, ex,loanApplicationId);
            throw new IND_Exception(ex.getMessage()); 
        }
    }
    @AuraEnabled
    public static Boolean getDocumentTractor(String loanApplicationId , String vehicleRecordId){
        try{
            Boolean  flag = true;
            List<String> docStringList = new List<String>{'Invoice'};
            List<Documents__c> docList = [SELECT Id,(Select Id FROM ContentDocumentLinks) FROM Documents__c where Opportunity_Relation__c =:loanApplicationId And Vehicle_Detail__c =:vehicleRecordId AND Is_active__c = true AND Document_Type__c In: docStringList WITH SECURITY_ENFORCED];

            for (Documents__c doc : docList) {
                if(doc.ContentDocumentLinks.size() == 0){
                    flag = false;
                    break;
                }
            }
            return flag;            
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_VehicleInspectionRCLimitDetails', 'getDocumentTractor', System.Label.Apex, ex,loanApplicationId);
            throw new IND_Exception(ex.getMessage()); 
        }
    }
    /*
    * @Method:      updateVehicleDetailsByCVO
    * @Created by:  Poonam Tilokani
    * @Description: This method is used to update vehicle details in pre-disbursment stage and also transaction history record.
    * @Param:       String - Loan Application ID ,String data. 
    * @Return:      void
    */
    @AuraEnabled
    public static void updateVehicleDetailsByCVO(String loanApplicationId, String data, String dealId){
        try{
            List<Vehicle_Detail__c> vehicleDetailList = (List<Vehicle_Detail__c>)JSON.deserialize(data, List<Vehicle_Detail__c>.class);
            system.debug('vehicleDetailList'+vehicleDetailList);
            if(vehicleDetailList.size()>0){
                upsert vehicleDetailList;
            }
            List<Loan_Application_Transaction_History__c> lATList=[Select id,Name,Submitted_Flag__c from Loan_Application_Transaction_History__c where Loan_Application_ID__c=:loanApplicationId  And Module__c = 'Pre Disbursement Check' AND Screen__c = 'Vehicle Inspection and RC Check' And Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
            if(lATList!=null && lATList.size()>0){
               lATList[0].Submitted_Flag__c = true;
                update lATList;
            }
            
        }catch(Exception ex){
             ErrorLoggerUtil.logErrorEvent('IND_VehicleInspectionRCLimitDetails', 'updateVehicleDetailsByCVO', System.Label.Apex, ex,loanApplicationId);
            throw new IND_Exception(ex.getMessage()); 
        }
    }
    //Wrapper class for vehicleInspectionDetails
    public class vehicleDetailsWrapper {
        @AuraEnabled public String engineNumber {get;set;}
        @AuraEnabled public String chassisNumber {get;set;}
        @AuraEnabled public String vehicleRegNumber {get;set;}
        @AuraEnabled public String locationOfVehicle {get;set;}
        @AuraEnabled public String remarks {get;set;}
    }

    public class RCLimitCheckResponseWrapper {
        @AuraEnabled public String No_Of_Proposals_Available {get;set;}
        @AuraEnabled public String Available_Disbursal_Amount {get;set;}
        @AuraEnabled public String Pending_Flag {get;set;}
        @AuraEnabled public String Payment_To_DSA_Flag {get;set;}
    }
    /*
    * @Method:      retryCountIncrease
    * @Created by:  Poonam Tilokani
    * @Description: This method is used to count how many number of times RC Limit parameter API call.
    * @Param:       String - Loan Application ID.
    * @Return:      Boolean
    */
    @AuraEnabled
    public static Boolean retryCountIncrease(String loanApplicationId){
        try{
            if(loanApplicationId != null){
                List<Retry_Count__c> retryCountList = [SELECT Id, Count__c
                                                        FROM Retry_Count__c 
                                                        WHERE Loan_Application_Id__c =: loanApplicationId AND Service_Name__c = 'RC Limit Check' 
                                                        WITH SECURITY_ENFORCED];
                if(!retryCountList.isEmpty()) {

                        retryCountList[0].Count__c += 1;
                     	retryCountList[0].Module__c = 'Vehicle Inspection';
                    	retryCountList[0].User_Id__c = UserInfo.getUserId();
                        if (Schema.sObjectType.Retry_Count__c.isUpdateable()){
                            UPDATE retryCountList;
                        } else {
                            throw new AuraHandledException('Not able to update Retry Count');
                        }
                        
                    
                }
                else{
                    Retry_Count__c retryCount = new Retry_Count__c();
                    retryCount.Loan_Application_Id__c = loanApplicationId;
                    retryCount.Service_Name__c = 'RC Limit Check';
                    retryCount.Count__c = 1;
                    retryCount.Module__c = 'Vehicle Inspection';
                    retryCount.User_Id__c = UserInfo.getUserId();
                    if(Schema.sObjectType.Retry_Count__c.isCreateable()) {
                        INSERT retryCount;
                    } else {
                        throw new AuraHandledException('Not able to insert Retry Count');
                    }
                }
            }
            return false;
        }
        catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_CustomerCodeAdditionCntrl','retryCountIncrease', System.Label.Apex, e,loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    /*
    * @Method:      checkIfReadOnly
    * @Created by:  Poonam Tilokani
    * @Description: This method is used to check weather RTO DPN screen is submitted or not.
    * @Param:       String - Loan Application ID.
    * @Return:      Boolean
    */
     @AuraEnabled
    Public static boolean checkIfReadOnly(String lAId, String dealId){
        try{
            Opportunity oppObj = new Opportunity();
            oppObj = [Select Id,Product_Type__c from  Opportunity where Id=:lAId];
            List<Loan_Application_Transaction_History__c> lATList = new  List<Loan_Application_Transaction_History__c>();
            if(oppObj.Product_Type__c == System.Label.Tractor){
                lATList=[Select id,Name,Submitted_Flag__c 
                from Loan_Application_Transaction_History__c 
                where Loan_Application_ID__c=:LAId   
                AND Module__c = 'Post Sanction Checks and Documentation' 
                And Screen__c ='Vehicle Inspection and RC Check' 
                And Deal_Number__c =: dealId 
                WITH SECURITY_ENFORCED];
            }else{
                lATList=[Select id,Name,Submitted_Flag__c from Loan_Application_Transaction_History__c 
                                                                   where Loan_Application_ID__c=:LAId   
                                                                   AND Module__c = 'Post Sanction Checks and Documentation' 
                                                                   And Screen__c ='RTO, DPN, POA Documents Upload' 
                                                                   And Deal_Number__c =: dealId 
                                                                   WITH SECURITY_ENFORCED];
            }
            System.debug('lATList : ' + lATList);
            if(lATList!=null && lATList.size()>0){
                return (lATList[0].Submitted_Flag__c);
            }
            return false;
        }catch(Exception ex){
             ErrorLoggerUtil.logErrorEvent('IND_VehicleInspectionRCLimitDetails', 'checkIfReadOnly', System.Label.Apex, ex,lAId);
            throw new IND_Exception(ex.getMessage()); 
        }

    }
    
    @AuraEnabled
    public static  Map<String,String> reffnamedata(String loanApplicationId){
        try {
            Map<String,String> beneficiaryNameList = new Map<String,String>();
            //Query the Vehicle details object related to Loan application.         
            List<Vehicle_Detail__c> vehicledetails = [select Id,Loan_Application__c, Loan_Application__r.Agent_BL_code__c,
                                                      Loan_Application__r.Product_Type__c,Ben_Code__c,Dealer_Sub_dealer_name__c 
                                                      from Vehicle_Detail__c
                                                      where Loan_Application__c =: loanApplicationId WITH SECURITY_ENFORCED];
            if(!vehicledetails.isEmpty()){ 
                /*String productCode = vehicledetails[0].Loan_Application__r.Product_Type__c == 'Two Wheeler' ? 'H' : 'C';
                //query the Beneficary product by passing the Delear name, Product type and DSM
				Beneficiary_Product__c[] benficaryProduct = [select Id,Ben_code__c,Ben_code__r.name,product__r.Name,Ben_code__r.Dealer_Code__c 
                                                               from Beneficiary_Product__c where
                                                               product__r.ProductCode =: productCode  and
                                                               Ben_code__r.Beneficiary__c ='DSA' and Ben_code__r.Status_Flag__c = 'L' ];
                list<String> bencodes= new list<String>();
                for(Beneficiary_Product__c ben:benficaryProduct){
                    bencodes.add(ben.Ben_code__c);
                }
                system.debug('bencodes'+bencodes);
                for(Beneficiary_BlCode__c benficaryblcode : [select Id,Ben_code__c,Ben_code__r.Name,Bl_Code_Details__c, Bl_Code_Details__r.Name
                                                               from Beneficiary_BlCode__c where Ben_code__c IN:bencodes and Ben_code__r.Dealer_Code__c=''
                                                              	]){
                    beneficiaryNameList.put(benficaryblcode.Ben_code__c,benficaryblcode.Ben_code__r.Name);
                    system.debug('beneficiaryNameList'+beneficiaryNameList);

                } */
                String blCode = vehicledetails[0].Loan_Application__r.Agent_BL_code__c;
                String productCode = vehicledetails[0].Loan_Application__r.Product_Type__c == 'Two Wheeler' ? 'H' : vehicledetails[0].Loan_Application__r.Product_Type__c == Label.Tractor ? 'T' : 'C';
                for(Beneficiary_BlCode__c benficaryblcode : [select id, Ben_code__r.name, Ben_code__r.Ben_code__c, Ben_code__r.Status_Flag__c, Ben_code__r.Dealer_Code__c, Ben_code__r.Beneficiary__c 
                                                             from Beneficiary_BlCode__c 
                                                             where Ben_code__c in (select Ben_code__c from Beneficiary_Product__c where Product__r.ProductCode =: productCode) and Bl_Code_Details__r.Bl_Code__c =: blCode AND Ben_code__r.Status_Flag__c = 'L' AND Ben_code__r.Dealer_Code__c ='' AND Ben_code__r.Beneficiary__c = 'DSA']){
                    beneficiaryNameList.put(benficaryblcode.Ben_code__c,benficaryblcode.Ben_code__r.Name+'|'+benficaryblcode.Ben_code__r.Ben_code__c); //CISP-5192
                    system.debug('beneficiaryNameList'+beneficiaryNameList);
                }
            }
            return beneficiaryNameList;
        }
        catch(Exception ex){
             ErrorLoggerUtil.logErrorEvent('IND_VehicleInspectionRCLimitDetails', 'reffnamedata', System.Label.Apex, ex,loanApplicationId);
            throw new IND_Exception(ex.getMessage()); 
        }
        }
    @AuraEnabled
    public static void updateFinalTermBenCode(String loanApplicationId, String benCode, String bencodeName){
            try{
                List<Final_Term__c> finalTermList = [SELECT Id, Referrer_Ben_Code__c,Referrer_Name__c from Final_Term__c
                                                     where Loan_Application__c =:loanApplicationId LIMIT 1];
                List<Benefi__c> benefMasterList = [Select Id, Ben_Code__c, Name from Benefi__c where (Id =: benCode OR Name =: bencodeName)];
                
                if(finalTermList.size()>0){
                    finalTermList[0].Referrer_Ben_Code__c = benefMasterList.size() > 0 ? benefMasterList[0].Ben_Code__c : '';
                    finalTermList[0].Referrer_Name__c = benefMasterList.size() > 0 ? benefMasterList[0].Name + '|' + benefMasterList[0].Ben_Code__c : '';
                    update finalTermList;
                }
            }
           catch(Exception ex){
                 ErrorLoggerUtil.logErrorEvent('IND_VehicleInspectionRCLimitDetails', 'updateFinalTermBenCode', System.Label.Apex, ex,loanApplicationId);
                throw new IND_Exception(ex.getMessage()); 
            }
    }
    @AuraEnabled
    public static List<Final_Term__c> getFinalTermRecord(String loanApplicationId){
            try{
                List<Final_Term__c> finalTermList = [SELECT Id, Referrer_Ben_Code__c,Referrer_Name__c from Final_Term__c
                                                     where Loan_Application__c =:loanApplicationId LIMIT 1];
                if(finalTermList.size()>0){
                   return finalTermList;
                }
                return null;
            }
           catch(Exception ex){
                 ErrorLoggerUtil.logErrorEvent('IND_VehicleInspectionRCLimitDetails', 'updateFinalTermBenCode', System.Label.Apex, ex,loanApplicationId);
                throw new IND_Exception(ex.getMessage()); 
            }
    }
    /*
    * @Method:      checkFinalTermRecords
    * @Created by:  Santhosh Guhan 
    * @Description: This method is used to whether Loan amount and Required IRR is changed.
    * @Param:       String - Loan Application ID.
    * @Return:      void 
    */
    @AuraEnabled
    public static void checkFinalTermRecords(String loanAppId){
        try {
            List<Final_Term__c> finalTermList = [SELECT Id,Required_CRM_IRR__c,Loan_Amount__c,L1_Finance_Amount__c,L1_Required_CRM_IRR__c,L1_L2_Final_Terms_Changed__c,Vehicle_Detail__c,Vehicle_Detail__r.Total_Funded_Amount__c,Structured_L1_Call__c,Installment_Type__c from Final_Term__c
                                                     where Loan_Application__c =:loanAppId WITH SECURITY_ENFORCED];                                         
            List<String> vehicleIds = new List<String>();  
            List<Final_Term__c> updFTermList = new List<Final_Term__c>();                                     
            for(Final_Term__c fts:finalTermList){
                Boolean check1 = false;
                Boolean check2 = false;
                Decimal fundedAmt = fts.Vehicle_Detail__r.Total_Funded_Amount__c != null ? fts.Vehicle_Detail__r.Total_Funded_Amount__c:0;
                Decimal totalFinance = Integer.valueOf(fts.Loan_Amount__c) + fundedAmt;
                if(fts.Installment_Type__c == 'Structured'){
                    fts.Structured_L1_Call__c = false;
                    check1 = true;
                }
                if(Decimal.valueOf(fts.L1_Finance_Amount__c == null ? '0' : fts.L1_Finance_Amount__c) != totalFinance || fts.L1_Required_CRM_IRR__c != fts.Required_CRM_IRR__c){
                    fts.L1_L2_Final_Terms_Changed__c = true;
                    vehicleIds.add(fts.Vehicle_Detail__c);
                    check2 = true;
                } 
                if(check1 || check2){
                    updFTermList.add(fts);
                } 
            }      
            if(!updFTermList.isEmpty()){                          
            update updFTermList;
            }

            List<Structered_EMI__c> strList = new List<Structered_EMI__c>();
            strList = [SELECT Id FROM Structered_EMI__c WHERE Loan_Application__c=:loanAppId AND Vehicle_Detail__c IN:vehicleIds WITH SECURITY_ENFORCED];

          if(!strList.isEmpty()){
                delete strList;
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}