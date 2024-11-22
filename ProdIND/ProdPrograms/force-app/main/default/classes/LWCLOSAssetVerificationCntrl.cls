/**
* @Name         LWCLOSAssetVerificationCntrl
* @Author       Aakash J
* @Company      Salesforce
* @Description  This class contains all methods related to Tractor Asset Verification process 
* Inputs:       None
* Test Class:   
* History:
*/
public without Sharing class LWCLOSAssetVerificationCntrl {
    
    //Wrapper assetVerificationWrapper class for Asset Verification added by Aakash J    
    public class assetVerificationListWrapper{
        @AuraEnabled public List<aVIDWrapper> aVIDWrapperList {get;set;}
        @AuraEnabled public String vehicleType {get;set;} //vehicleType
        @AuraEnabled public String applicantId {get;set;}
        @AuraEnabled public String loanDetailsId {get;set;}
        @AuraEnabled public String loanDetailsStageName {get;set;}
        @AuraEnabled public String loanDetailsSubStage {get;set;}
    }
    
    //Wrapper assetVerificationWrapper class for Asset Verification added by Aakash J    
    public class aVIDWrapper{
        @AuraEnabled public Id avId{get;set;}
        @AuraEnabled public Id vehicleId{get;set;}
        @AuraEnabled public String avLabel{get;set;}
        @AuraEnabled public Boolean isCompleted{get;set;}
        @AuraEnabled public Boolean avStatus{get;set;} //SFTRAC-99
        @AuraEnabled public String avStatusValue{get;set;} //SFTRAC-1431
        @AuraEnabled public Boolean engineImgUploaded {get;set;}
        @AuraEnabled public Boolean chassisImgUploaded {get;set;}
        @AuraEnabled public Boolean selfieWithVehImgUploaded {get;set;}
        @AuraEnabled public Boolean vehFrontImgUploaded {get;set;}
        @AuraEnabled public Boolean vehBackImgUploaded {get;set;}
        @AuraEnabled public Boolean serialNoUploaded {get;set;} //SFTRAC-1785
        @AuraEnabled public Boolean vehRightImgUploaded {get;set;}
        @AuraEnabled public Boolean vehLeftImgUploaded {get;set;}
        @AuraEnabled public Boolean hmrImgUploaded {get;set;}
        @AuraEnabled public Boolean chassisPlateImgUploaded {get;set;}
        @AuraEnabled public String avVehicleSubType{get;set;}   //SFTRAC-1785
        @AuraEnabled public Boolean isImplement {get;set;}  //SFTRAC-1785
        // Constructor to initialize default values
        public aVIDWrapper() {
            engineImgUploaded = false;
            chassisImgUploaded = false;
            selfieWithVehImgUploaded = false;
            vehFrontImgUploaded = false;
            vehBackImgUploaded = false;
            vehRightImgUploaded = false;
            vehLeftImgUploaded = false;
            hmrImgUploaded = false;
            chassisPlateImgUploaded = false;
            serialNoUploaded = false;   //SFTRAC-1785
        }
    }
    
    /*
* @Method:      getassetVerificationsRecord
* @Created by:  Aakash J.
* @Modified by: Santhosh Guhan
* @Description: Method to return list of Asset Verification for Tractor Asset
* @Param:       String - case ID
* @Return:      List<assetVerificationWrapper> - List of Tabs
*/
    @AuraEnabled
    public static assetVerificationListWrapper getassetVerificationsId(String caseId,Boolean psdStage, String dealId){
        try{
            List<Asset_Verification__c> assetVList = new List<Asset_Verification__c>();
            assetVerificationListWrapper avWrapper = new assetVerificationListWrapper();
            if(psdStage == true){ //SFTRAC-99
                assetVList =[SELECT Id,Applicant__c,Status__c,Vehicle_Detail__c, Vehicle_Detail__r.Vehicle_type__c, Vehicle_Detail__r.Loan_Application__c,
                                                     Vehicle_Detail__r.Loan_Application__r.Applicant__c, Vehicle_Detail__r.Loan_Application__r.StageName, 
                                                     Vehicle_Detail__r.Make__c, Vehicle_Detail__r.Model__c, Vehicle_Detail__r.Variant__c,Vehicle_Detail__r.Vehicle_SubType__c,
                                                     Vehicle_Detail__r.Loan_Application__r.Sub_Stage__c FROM Asset_Verification__c where Case__c =:caseId and Vehicle_Detail__r.Deal_Number__c =:dealId];
            }else{
            assetVList =[SELECT Id,Applicant__c,Status__c, Vehicle_Detail__c, Vehicle_Detail__r.Vehicle_type__c, Vehicle_Detail__r.Loan_Application__c,Vehicle_Detail__r.Vehicle_SubType__c,
                                                     Vehicle_Detail__r.Loan_Application__r.Applicant__c, Vehicle_Detail__r.Loan_Application__r.StageName, 
                                                     Vehicle_Detail__r.Loan_Application__r.Sub_Stage__c,Vehicle_Detail__r.Make__c,
                                                     Vehicle_Detail__r.Model__c,
                                                     Vehicle_Detail__r.Variant__c FROM Asset_Verification__c where Case__c =:caseId];
            }
            
            List<Id> avRecIdList = new List<Id>();
            
            List<aVIDWrapper> aVIDWrapperList = new List<aVIDWrapper>();
            Integer index = 1;
            for(Asset_Verification__c assetVRec: assetVList){
                aVIDWrapper avIdWrapperRec = new aVIDWrapper(); 
                avIdWrapperRec.avId =  assetVRec.Id;
                avIdWrapperRec.vehicleId = assetVRec.Vehicle_Detail__c;
                avIdWrapperRec.avStatusValue = assetVRec.Status__c; //SFTRAC-1431
                avIdWrapperRec.avVehicleSubType = assetVRec.Vehicle_Detail__r.Vehicle_SubType__c; //SFTRAC-1785
                avIdWrapperRec.isImplement = assetVRec.Vehicle_Detail__r.Vehicle_SubType__c == 'Implement' ? true : false; //SFTRAC-1785
                avIdWrapperRec.avLabel =  assetVRec.Vehicle_Detail__r.Make__c + ' ' + assetVRec.Vehicle_Detail__r.Model__c + ' ' + assetVRec.Vehicle_Detail__r.Variant__c;
                if(assetVRec.Status__c == 'Completed'){
                    avIdWrapperRec.avStatus = true;
                    avIdWrapperRec.isCompleted = true;
                } 
                else{
                    avIdWrapperRec.avStatus = false;
                    avIdWrapperRec.isCompleted = false;
                }
                
                for(Documents__c docRec: [SELECT Id, Applicant__c,CreatedDate, Document_Type__c,(SELECT Id FROM ContentDocumentLinks) FROM Documents__c WHERE Asset_Verification__c =: assetVRec.Id]){
                    system.debug('++++++docRec '+docRec);
                    if(docRec.Document_Type__c == 'Engine Number uploaded during verification' && docRec.ContentDocumentLinks.size() > 0){
                        avIdWrapperRec.engineImgUploaded = true;
                    }else if(docRec.Document_Type__c == 'Chassis Number uploaded during verification' && docRec.ContentDocumentLinks.size() > 0){
                        avIdWrapperRec.chassisImgUploaded = true;
                    }else if(docRec.Document_Type__c == 'Selfie with Vehicle-uploaded during verification' && docRec.ContentDocumentLinks.size() > 0){
                        avIdWrapperRec.selfieWithVehImgUploaded = true;
                    }else if(docRec.Document_Type__c == 'Vehicle Front-uploaded during verification' && docRec.ContentDocumentLinks.size() > 0){
                        avIdWrapperRec.vehFrontImgUploaded = true;
                    }else if(docRec.Document_Type__c == 'Vehicle Back-uploaded during verification' && docRec.ContentDocumentLinks.size() > 0){
                        avIdWrapperRec.vehBackImgUploaded = true;
                    }else if(docRec.Document_Type__c == 'Capture Vehicle Right Side' && docRec.ContentDocumentLinks.size() > 0){
                        avIdWrapperRec.vehRightImgUploaded = true;
                    }else if(docRec.Document_Type__c == 'Capture Vehicle Left Side' && docRec.ContentDocumentLinks.size() > 0){
                        avIdWrapperRec.vehLeftImgUploaded = true;
                    }else if(docRec.Document_Type__c == 'Capture HMR' && docRec.ContentDocumentLinks.size() > 0){
                        avIdWrapperRec.hmrImgUploaded = true;
                    }else if(docRec.Document_Type__c == 'Capture Chassis plate' && docRec.ContentDocumentLinks.size() > 0){
                        avIdWrapperRec.chassisPlateImgUploaded = true;
                    }else if(docRec.Document_Type__c == 'Capture Serial Number' && docRec.ContentDocumentLinks.size() > 0){ //SFTRAC-1785
                        avIdWrapperRec.serialNoUploaded = true; 
                    }
                }

                aVIDWrapperList.add(avIdWrapperRec);
                avWrapper.vehicleType = assetVRec.Vehicle_Detail__r.Vehicle_type__c;
                avWrapper.applicantId = assetVRec.Applicant__c;
                avWrapper.loanDetailsId = assetVRec.Vehicle_Detail__r.Loan_Application__c;
                avWrapper.loanDetailsStageName = assetVRec.Vehicle_Detail__r.Loan_Application__r.StageName;
                avWrapper.loanDetailsSubStage = assetVRec.Vehicle_Detail__r.Loan_Application__r.Sub_Stage__c;
                index++ ;
            }
            avWrapper.aVIDWrapperList = aVIDWrapperList;
            system.debug('++++avWrapper '+avWrapper);
            return avWrapper;    
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('LWCLOSAssetVerificationCntrl', 'getassetVerificationsId', System.Label.Apex, e, '');
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        
    }
    @AuraEnabled
    public static void updateCaseAVRecords(String loanApplicationId, String dealId){
        List<Asset_Verification__c> assetVerificationFailedList = new List<Asset_Verification__c>();
        List<Asset_Verification__c> assetVerificationList = new List<Asset_Verification__c>();
        Set<Id> caseIdsSet = new Set<Id>();

        for(Asset_Verification__c assetVeriRec : [SELECT Id,Date_of_submission__c,Case__c,OwnerId FROM Asset_Verification__c WHERE Case__r.Loan_Application__c =:loanApplicationId AND Vehicle_Detail__r.Deal_Number__c =:dealId]){
            if(assetVeriRec.Date_of_submission__c != null  && assetVeriRec.Date_of_submission__c < (Date.today()-30)){
                assetVeriRec.Date_of_submission__c = null;
                assetVeriRec.Status__c = 'New';
                caseIdsSet.add(assetVeriRec.Case__c);
                assetVerificationList.add(assetVeriRec);
            }
        }
        if(assetVerificationList.size() > 0){
            update assetVerificationList;
        }
        List<Case> caseList = new List<Case>();
        for (Id caseId : caseIdsSet) {
            Case caseObj = new Case();
            caseObj.Id = caseId;
            caseObj.Status = 'New';
            caseList.add(caseObj);
        }
        if(caseList.size() > 0){
            update caseList;
        }

    }
    /*
* @Method:      createCaseAVRecords
* @Created by:  Aakash J.
* @Description: Method to return success message after Case & Asset_Verification__c record is created
* @Param:       String - loanApplicationId(Opportunity Id)
* @Return:      List<assetVerificationWrapper> - List of Tabs
*/
    @AuraEnabled
    public static String createCaseAVRecords(String loanApplicationId, String applicantId, String lastAssetOwnerId){
        system.debug('++++loanApplicationId '+loanApplicationId+'++++applicantId '+applicantId);
        string result='';
        ID caseAVRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Asset Verification').getRecordTypeId();
        List<Case> assetCase = new List<Case>([Select id from Case Where RecordTypeId =: caseAVRecordType and Loan_Application__c =: loanApplicationId]);
        if(assetCase.size() > 0){
            return result;
        }

        List<Asset_Verification__c> avInsertList = new List<Asset_Verification__c>();
        
        List<Vehicle_Detail__c> vehicleDetailsList = [  SELECT Id, Name, Vehicle_type__c, Vehicle_Category__c, 
                                                      Registration_Number_Format__c,Vehicle_Registration_Number__c, Vehicle_Verified__c, 
                                                      Engine_number__c, Vehicle_SubCategory__c, Chassis_number__c, Serial_number__c, 
                                                      Vehicle_Delivered__c, Vehicle_SubType__c, Loan_Application__r.Name, Make__c, 
                                                      Model__c, Variant__c, KMS_Run__c, Loan_Application__r.OwnerId,
                                                      Loan_Application__r.Applicant__c, Loan_Application__r.AccountId,(Select Id from RelatedAsset_Verifications__r WHERE Case__r.RecordType.Name = 'Asset Verification') FROM Vehicle_Detail__c
                                                      WHERE Loan_Application__c =: loanApplicationId AND (Vehicle_Delivered__c = 'Yes' OR Vehicle_Delivered__c = 'No')];
        
        system.debug('++++vehicleDetailsList '+vehicleDetailsList);
        if(!vehicleDetailsList.isEmpty()){
            try {
                
                Case caseRec = new Case();
                //Get Asset Verification Case recordTypeId
                caseRec.Subject = vehicleDetailsList[0].Loan_Application__r.Name + ' Asset Verification Case';
                caseRec.Status = 'New';
                caseRec.Priority = 'Medium';
                caseRec.Loan_Application__c = vehicleDetailsList[0].Loan_Application__c;
caseRec.AccountId = vehicleDetailsList[0].Loan_Application__r.AccountId;
                caseRec.Applicant__c = applicantId;
                caseRec.RecordTypeId = caseAVRecordType;
               	caseRec.OwnerId = String.isNotBlank(lastAssetOwnerId) ? lastAssetOwnerId : vehicleDetailsList[0].Loan_Application__r.OwnerId;
                insert caseRec;
                system.debug('++++caseRec '+caseRec);
                for(Vehicle_Detail__c vdRec: vehicleDetailsList){
                    if(vdRec.RelatedAsset_Verifications__r.size() == 0){
                        Asset_Verification__c  avRec = new Asset_Verification__c ();
                        avRec.Name = vdRec.Name;
                        avRec.Asset_MMV__c= vdRec.Make__c+' '+vdRec.Model__c+' '+vdRec.Variant__c;
                        avRec.Engine_No__c= vdRec.Engine_number__c;
                        avRec.Chasis_No__c= vdRec.Chassis_number__c;
                        avRec.Serial_No__c= vdRec.Serial_number__c;
                        avRec.RC_No__c = vdRec.Vehicle_Registration_Number__c;
                        //avRec.HMR__c = Decimal.valueOf(vdRec.KMS_Run__c);
                        avRec.HMR__c = (vdRec.KMS_Run__c != null) ? Decimal.valueOf(vdRec.KMS_Run__c) : 0;
                        avRec.Status__c= 'New';
                        avRec.Vehicle_Detail__c= vdRec.Id;
                        avRec.Case__c = caseRec.Id;
                        avRec.Applicant__c = applicantId;
                        avRec.OwnerId = caseRec.OwnerId;
                        avInsertList.add(avRec);
                    }
                }
                system.debug('++++avInsertList '+avInsertList);
                if(!avInsertList.isEmpty()){
                    insert avInsertList;
                }
            }catch(Exception e){
                ErrorLoggerUtil.logErrorEvent('LWCLOSAssetVerificationCntrl', 'createCaseAVRecords', System.Label.Apex, e, '');
                system.debug('ERROR '+e.getMessage() + 'ERROR Line '+e.getLineNumber());
                throw new AuraHandledException(e.getMessage());
            }
        }
        
        return result;
    }
    
    /*
* @Method:      createDocumentRecord
* @Created by:  Aakash J.
* @Description: Method to return list of Asset Verification for Tractor Asset
* @Param:       String : applicantId // ID of applicant for which documents to be retrived.  
*              	String : loanApplicationId // Id of the loan application.
*				String : caseId // Id of the case where all the Asset Verification records are linked.
*				String : assetVerifiId // Id of current Asset Verification records.
*				String : documentType // Document Type of document.
*				String : recordTypeName // Name of the record type
* @Return:      String : documentId // Returning created Id to the LWC Component.
*/    
    @AuraEnabled
    public static String createDocumentRecord(String caseId,String applicantId, String vehicleId, String assetVerifiId, String loanApplicationId,String documentType,String recordTypeName){
        try{
            String avDocumentRecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
            String orignaldoc=null;
            
            system.debug('++++applicantId '+applicantId);
            for(Documents__c doc : [SELECT Id, Applicant__c,CreatedDate, Document_Type__c FROM Documents__c
                                    WHERE Asset_Verification__c = :assetVerifiId AND RecordTypeId =: avDocumentRecordTypeId 
                                    AND Document_Type__c =:documentType and is_Active__c =true]) {
                                        if(doc.Document_Type__c == documentType){
                                            orignaldoc= doc.Id;
                                        }
                                    }
            
            if(orignaldoc==null){
                Documents__c document =  new Documents__c(Name=documentType,Asset_Verification__c  = assetVerifiId, Vehicle_Detail__c= vehicleId,is_Active__c = true,Opportunity_Relation__c = loanApplicationId,Applicant__c = applicantId,Document_Type__c = documentType, RecordTypeId = avDocumentRecordTypeId, Case__c=caseId);
                system.debug('++++document '+document);
                if(Schema.sObjectType.Documents__c.isCreateable()){
                    Insert document;
                } 
                orignaldoc=document.Id;
            }else{
                return orignaldoc;
            } 
            return orignaldoc;    
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('LWCLOSAssetVerificationCntrl', 'createDocumentRecord', System.Label.Apex, e, '');
            system.debug('ERROR '+e.getMessage() + 'ERROR Line '+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    /* 
    @description :   Method to send notification
    @Created By : Santhosh Guhan 
    @User Story : SFTRAC - 99
    @param :  String assetVerId - Asset Verification Id
    @return : Void 
    */
    @AuraEnabled
    public static void sendNotification(String assetVerId){
        try{
            List<Asset_Verification__c> assVer = [SELECT Id, Name, Case__c, Case__r.CaseNumber, OwnerId,Case__r.Loan_Application__c, Case__r.Loan_Application__r.Name FROM Asset_Verification__c WHERE Id=:assetVerId AND Status__c != 'Completed'];
            Set<String> recIds = new Set<String>();
            recIds.add(assVer[0].OwnerId);
            String message = 'Hi, Please note that there is a Post Sanction Asset Verification Case assigned to you - Case Number: ' +assVer[0].Case__r.CaseNumber+ ', Loan Application Number - '+assVer[0].Case__r.Loan_Application__r.Name+ ' Thanks';
            notifyUsers(recIds,assVer[0].Case__c,message);
            }
        catch(Exception ex){
            throw new IND_Exception(ex.getMessage()); 
        }
    }
    /* 
    @description :   Method to send notification
    @Created By : Santhosh Guhan 
    @User Story : SFTRAC - 99
    @param :  Set<String> recipientsIds - userIds to whom notification should be sent
    @param :  String assetVerId - Asset Verification Id
    @param :  String message - Message to be notified
    @return : Void 
    */
    public static void notifyUsers(Set<String> recipientsIds, String assetVerId, String message) {
        
        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'Notification_to_Onwer'];
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle('Asset Verification Request');
        notification.setBody(message);
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(assetVerId);
        try {
            notification.send(recipientsIds);
        } catch(Exception ex){
            throw new IND_Exception(ex.getMessage()); 
        }
  }    
        /*
* @Method:      checkAssetVerificationStatus
* @Created by:  Aakash J.
* @Description: Method to return string Asset verification completed or not
* @Param:       String - loanApplicationId
* @Return:      return string
*/
    @AuraEnabled
    public static string checkAssetVerificationStatus(String loanApplicationId){
        try{
            String resultStr ='';
            List<Asset_Verification__c> assetVList =[SELECT Id, Name, Case__c,Case__r.Loan_Application__c, Status__c 
                                                    FROM Asset_Verification__c where Case__r.Loan_Application__c =:loanApplicationId And Status__c !='Completed'];
            if(assetVList.isEmpty()){
                resultStr ='Asset Verification Completed';
            }else{
                resultStr ='Asset Verification Inprogress';
            }
            return resultStr;
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('LWCLOSAssetVerificationCntrl', 'checkAssetVerificationStatus', System.Label.Apex, e, '');
            throw new AuraHandledException(System.Label.ExceptionMessage);
            //return 'error';
        }
    }
    
           /*
    * @Method:      checkAssetVerificationStatus SFTRAC-1636
    * @Created by:  Aakash J.
    * @Description: Method to return string Asset verification completed or not only on Final Term Screen Vehicle Type = New and Delivered Yes
    * @Param:       String - loanApplicationId
    * @Return:      return string
    */
    @AuraEnabled
    public static string checkAssetVerificationStatusFinalTerm(String loanApplicationId, String vehicleId){
        try{
            String resultStr ='';
            List<Asset_Verification__c> assetVList =[SELECT Id, Name, Case__c,Case__r.Loan_Application__c, Status__c, Vehicle_Detail__c
                                        FROM Asset_Verification__c where Case__r.Loan_Application__c =:loanApplicationId And Vehicle_Detail__c =: vehicleId 
                                        And Vehicle_Detail__r.Vehicle_Delivered__c = 'Yes' And Status__c !='Completed'];

            if(assetVList.isEmpty()){
                resultStr ='Asset Verification Completed';
            }else{
                resultStr ='Asset Verification Inprogress';
            }
            return resultStr;
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('LWCLOSAssetVerificationCntrl', 'checkAssetVerificationStatus', System.Label.Apex, e, '');
            throw new AuraHandledException(System.Label.ExceptionMessage);
            //return 'error';
        }
    }
    
           /*
* @Method:      checkAssetVerificationStatuson Payment Disbursment stage
* @Created by:  Aakash J.
* @Description: Method to return string Asset verification completed or not
* @Param:       String - loanApplicationId
* @Return:      return string
*/
@AuraEnabled
public static string checkAssetVerificationStatuspaymentScreen(String loanApplicationId){
    try{
        String resultStr ='';
        List<Asset_Verification__c> assetVList =[SELECT Id, Name, Case__c,Case__r.Loan_Application__c, Status__c 
                                                FROM Asset_Verification__c where Case__r.Loan_Application__c =:loanApplicationId And Status__c !='Completed' AND Type_of_AV__c = null];
        if(assetVList.isEmpty()){
            resultStr ='Asset Verification Completed';
        }else{
            resultStr ='Asset Verification Inprogress';
        }
        return resultStr;
    }catch(Exception e){
        ErrorLoggerUtil.logErrorEvent('LWCLOSAssetVerificationCntrl', 'checkAssetVerificationStatuspaymentScreen', System.Label.Apex, e, '');
        throw new AuraHandledException(System.Label.ExceptionMessage);
        //return 'error';
    }
}
/*
* @Method:      createCasePDAVRecords
* @Created by:  Aakash J.
* @Description: Method to return success message after Post Disbursement Case & Asset_Verification__c record is created //SFTRAC-147 changes
* @Param:       String - loanApplicationId(Opportunity Id)
* @Return:      List<assetVerificationWrapper> - List of Tabs
*/

@AuraEnabled
    public static String createCasePDAVRecords(String loanApplicationId, String applicantId, String dealId){
        string result='true';
        List<Asset_Verification__c> avInsertList = new List<Asset_Verification__c>();
        
        Opportunity opp = [SELECT Id, AccountId, Name, StageName, Sub_Stage__c, Product_Type__c, Vehicle_Type__c FROM Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED];

        AccountTeamMember rCUManager = [SELECT ID ,TeamMemberRole, Level__c ,Account.id, User.Email, user.Name, UserId, user.IsActive,
                                            User.Profile.UserLicense.Name FROM AccountTeamMember WHERE Account.id= :opp.AccountId AND TeamMemberRole =: 'RCU_M' AND user.IsActive = true LIMIT 1];
        
                                            List<Vehicle_Detail__c> vehicleDetailsList = [  SELECT Id, Name, Vehicle_type__c, Vehicle_Category__c, 
                                            Registration_Number_Format__c,Vehicle_Registration_Number__c, Vehicle_Verified__c, 
                                            Engine_number__c, Vehicle_SubCategory__c, Chassis_number__c, Serial_number__c, 
                                            Vehicle_Delivered__c, Vehicle_SubType__c, Loan_Application__r.Name, Make__c, 
                                            Model__c, Variant__c, KMS_Run__c, Loan_Application__r.OwnerId,
                                            Loan_Application__r.Applicant__c, Loan_Application__r.AccountId,(Select Id from RelatedAsset_Verifications__r WHERE Case__r.Subject LIKE : '%PD Asset Verification Case%' and Case__r.RecordType.Name = 'Asset Verification') FROM Vehicle_Detail__c
                                            WHERE Loan_Application__c =: loanApplicationId AND Deal_Number__c =:dealId];
        
        if(!vehicleDetailsList.isEmpty()){
            try {
                //Get Asset Verification Case recordTypeId
                ID caseAVRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Asset Verification').getRecordTypeId();
                List<Case> existingAVCase = [Select Id, CaseNumber, OwnerId From Case Where Loan_Application__c =: loanApplicationId AND RecordTypeId =: caseAVRecordType AND Subject LIKE :'%PD%' LIMIT 1];
                Case caseRec = new Case();
                
                if(existingAVCase.isEmpty()){
                    caseRec.Subject = vehicleDetailsList[0].Loan_Application__r.Name + ' PD Asset Verification Case';
                    caseRec.OwnerId = rCUManager.UserId;
                    caseRec.Status = 'New';
                    caseRec.Priority = 'Medium';
                    caseRec.Loan_Application__c = vehicleDetailsList[0].Loan_Application__c;
caseRec.AccountId = vehicleDetailsList[0].Loan_Application__r.AccountId;
                    caseRec.Applicant__c = applicantId;
                    caseRec.RecordTypeId = caseAVRecordType;              
                    insert caseRec;
                }else{

                }
                
                for(Vehicle_Detail__c vdRec: vehicleDetailsList){
                    if(vdRec.RelatedAsset_Verifications__r.size() == 0){
                        Asset_Verification__c  avRec = new Asset_Verification__c ();
                        if(opp.StageName =='Disbursement Request Preparation' && opp.Sub_Stage__c =='Payment Request'){
                            avRec.Type_of_AV__c  = 'PDAV';                      
                        }else{
                            avRec.Type_of_AV__c  = 'L1AV';
                        }
                        avRec.Name = vdRec.Name;
                        avRec.Asset_MMV__c= vdRec.Make__c+' '+vdRec.Model__c+' '+vdRec.Variant__c;
                        avRec.Engine_No__c= vdRec.Engine_number__c;
                        avRec.Chasis_No__c= vdRec.Chassis_number__c;
                        avRec.Serial_No__c= vdRec.Serial_number__c;
                        avRec.RC_No__c = vdRec.Vehicle_Registration_Number__c;
                        avRec.HMR__c = (vdRec.KMS_Run__c != null) ? Decimal.valueOf(vdRec.KMS_Run__c) : 0;
                        avRec.Status__c= 'New';
                        avRec.Vehicle_Detail__c= vdRec.Id;
                        if(!existingAVCase.isEmpty()){
                            avRec.Case__c = existingAVCase[0].Id;
                            avRec.OwnerId = existingAVCase[0].OwnerId;  
                        }else{
                            avRec.Case__c = caseRec.Id;
                            avRec.OwnerId = caseRec.OwnerId;                        
                        }
                        
                        avRec.Applicant__c = applicantId;
                        //avRec.OwnerId = caseRec.OwnerId;
                        avInsertList.add(avRec);
                    }
                }
                if(!avInsertList.isEmpty()){
                    insert avInsertList;
                }
            }catch(Exception e){
                ErrorLoggerUtil.logErrorEvent('LWCLOSAssetVerificationCntrl', 'createCaseAVRecords', System.Label.Apex, e, '');
                throw new AuraHandledException(e.getMessage());
            }
        }
        
        return result;
    }

    /*
    * @Method:      isDocumentUploaded
    * @Created by:  Chaynnitt Agarwal
    * @Description: Method to check if the document is uploaded for the specific Asset Verification
    * @Param:       String - avId
    * @Return:      return Boolean
    */
    @AuraEnabled
    public static Boolean isDocumentUploaded(String avId){
        try{
            Boolean isUploaded = false;
            List<Documents__c> docList = [SELECT Id, Name, Document_Type__c FROM Documents__c WHERE Asset_Verification__c =:avId WITH SECURITY_ENFORCED];
            for(Documents__c docRec: docList){
                if(docRec.Document_Type__c == 'Engine Number uploaded during verification' && docRec.Document_Type__c == 'Chassis Number uploaded during verification' && 
                  docRec.Document_Type__c == 'Selfie with Vehicle-uploaded during verification' && docRec.Document_Type__c == 'Vehicle Front-uploaded during verification' && 
                  docRec.Document_Type__c == 'Vehicle Back-uploaded during verification' && docRec.Document_Type__c == 'Capture Chassis plate' &&
                  docRec.Document_Type__c == 'Capture Vehicle Right Side' && docRec.Document_Type__c == 'Capture Vehicle Left Side' && docRec.Document_Type__c == 'Capture HMR'){
                    isUploaded = true;
                }
            }
            return isUploaded;
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('LWCLOSAssetVerificationCntrl', 'isDocumentUploaded', System.Label.Apex, e, '');
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    /*
    * @Method:      updateAVStatus
    * @Created by:  Aakash J
    * @Description: Method to update Asset Verification if PE/CVO update the Vehicle Inpection status = No
    * @Param:       String - avId
    * @Return:      return Boolean
    */
    @AuraEnabled
    public static String updateAVStatus(String loanId){
        String returnStr;
        try{
            List<Asset_Verification__c> avList = [SELECT Id,Applicant__c,Status__c, Case__c FROM Asset_Verification__c Where Case__r.Loan_application__c =: loanId];
            List<Asset_Verification__c> avUpdateList = new List<Asset_Verification__c>(); 
            for(Asset_Verification__c avRec : avList){
                avRec.Status__c = 'New';
                avUpdateList.add(avRec);
            }
            update avUpdateList;
            returnStr = 'Success';
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('LWCLOSAssetVerificationCntrl', 'updateAVStatus', System.Label.Apex, e, '');
            returnStr = 'Error';
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        return returnStr;
        
    }

@AuraEnabled
    public static void deleteDocument(String documentId){
        try{
            if(documentId!=null){
                List<SObject> documentsObject= [Select Id from Documents__c Where Id= :documentId WITH SECURITY_ENFORCED ];
                
                if (Schema.sObjectType.Documents__c.isAccessible() && Schema.sObjectType.Documents__c.isDeletable() ){
                    delete documentsObject;
                }
                //delete [SELECT Id FROM ContentDocument WHERE Id=:documentId WITH SECURITY_ENFORCED];
            }
            if(Test.isRunningTest())
            {
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
            
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('LWCLOSAssetVerificationCntrl', 'deleteDocument ', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);  
        }
    }

    @AuraEnabled
    public static String previewDocument(String assetId,string docName){
        String contentDocumentId = null;
        //List<ContentVersion> contentList = [ SELECT Id, ContentDocumentId FROM ContentVersion WHERE FirstPublishLocationId IN ( SELECT Id FROM Documents__c WHERE Asset_Verification__c = :assetId AND Name = :docName ) LIMIT 1 ];
        List<ContentDocumentLink> contentList = [ Select ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId IN (SELECT Id FROM Documents__c WHERE Asset_Verification__c = :assetId AND Name = :docName) LIMIT 1 ];
        system.debug('+++++contentList '+contentList);
        
        if (!contentList.isEmpty()) {
            contentDocumentId = contentList[0].ContentDocumentId;
        }

        return contentDocumentId;  
    }

    /** SFTRAC-1451 
    * @Method       getRCUSamplerName
    * @Author       Aakash Jaiswar
    * @Company      Salesforce
    * @Description  This method will generate RCU Summary report data and return to LWC component.
    * @Param:       RCU case Id (rcuCaseId)
    * @Return:   	samplerName = String
    */
    @AuraEnabled
    public static String getRCUSamplerName(string rcuCaseId){

        System.debug('rcuCaseId '+rcuCaseId);
        String samplerNameStr = '';
        Case rcuSummaryObj = [SELECT ID,Applicant__c,Origin, RCU_Agent__c, RCU_Agent__r.Name, RCU_Agent__r.Contact.Account.Name FROM case WHERE Id=:rcuCaseId ];
        samplerNameStr = rcuSummaryObj.RCU_Agent__c!=null ? rcuSummaryObj.RCU_Agent__r.Contact.Account.Name : 'N/A'; //SFTRAC-1451 
        return samplerNameStr;                  
    }
    @AuraEnabled
    public static Boolean haveCaseAccesibility(String caseId) {
        List<Case> caseList = new List<Case>([SELECT Id,OwnerId FROM Case WHERE Id =: caseId]);
        if(caseList.size() > 0 && caseList[0].OwnerId == UserInfo.getUserId()) {
            return true;
        }
        return false;
    }
}