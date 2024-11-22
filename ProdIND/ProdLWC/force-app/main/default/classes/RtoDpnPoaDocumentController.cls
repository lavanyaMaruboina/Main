/*
* @Name         RtoDpnPoaDocumentController
* @Author       Anuj
* @Company      
* @Description  This class contains all the methods related to RTO, DPN, POA documents details.
* Inputs:       None
* Test Class:   IND_DocumentUploadCntrlTest
* History:
* Dated                      Modified By           Description
*                            Gaurav Rawat
*/
public with sharing class RtoDpnPoaDocumentController { 
    
        /*
    * @Method Name: getApplicantRecord
    * @Created by:  Poonam Tilokani
    * @description: get Applicant data
    * @Param:       String - loan Application record Id
    */
    @AuraEnabled
    public static Applicant__c getApplicantRecord(String loanApplicationId){
        try{
                List<Applicant__c> applicantList = new List<Applicant__c>();
            applicantList = [Select id,Name ,Applicant_Type__c,Opportunity__c from Applicant__c where Opportunity__c  =: loanApplicationId AND Applicant_Type__c=: System.Label.Borrower AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED];
            if(applicantList.size()>0){
                return applicantList[0];
            }
            return null;
        }
            catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('RtoDpnPoaDocumentController','getApplicantRecord', System.Label.Apex, e,loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    /*
    * @Method Name: fetchDetails
    * @Created by:  Anuj
    * @description: to create a Document object for 'RTO, DPN, POA'
    * @Param:       String - loan Application record Id
    */
    @AuraEnabled
    public static WrapperData fetchDetails(String loanApplicationId, String dealId){
        WrapperData wrap = new WrapperData();
        Boolean showSubmitBtn = true;
        Opportunity oppRecord = new Opportunity();
        List<Opportunity> oppList = new List<Opportunity>();
        String module = '';
        try {
            oppList = [Select Id, StageName, Applicant__c, Product_Type__c ,Vehicle_Type__c, Number_of_SPDC_collected__c,All_Cheques_are_from_Same_bank__c, CVO_Accepts_SPDC_Documents__c,  LeadSource, //D2C Swapnil added LeadSource
                        CVO_Remarks_SPDC__c,(Select Id from Vehicle_Details__r WHERE Deal_Number__c =: dealId) FROM Opportunity WHERE id =: loanApplicationId  WITH SECURITY_ENFORCED];
            if(oppList != null){
                oppRecord = oppList[0];
            }
            List<Applicant__c> applicantList = new List<Applicant__c>([Select Id,Name ,Applicant_Type__c,Opportunity__c from Applicant__c where Opportunity__c  =: loanApplicationId AND Applicant_Type__c=: System.Label.Borrower AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED LIMIT 1]);

            List<Documents__c> docList = new List<Documents__c>();
            if(oppRecord.Product_Type__c == System.Label.Tractor){
                List<Vehicle_Detail__c> VehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
                docList = [SELECT Id, Name, Document_Type__c, is_Active__c, Is_Document_Eligible__c, Correctly_Captured__c, Remarks__c from Documents__c WHERE Opportunity_Relation__c =: oppRecord.Id AND Applicant__c =: applicantList[0].Id AND is_Active__c = true AND Vehicle_Detail__c =: VehicleLst[0].Id WITH SECURITY_ENFORCED order by createdDate desc];
            }else{
                docList = [SELECT Id, Name, Document_Type__c, is_Active__c, Is_Document_Eligible__c, Correctly_Captured__c, Remarks__c from Documents__c where Opportunity_Relation__c =: oppRecord.Id AND Applicant__c =: applicantList[0].Id AND is_Active__c = true With SECURITY_ENFORCED order by createdDate desc];
            }


            for(Documents__c doc : docList){
                    System.debug('doc.Document_Type__c '+doc.Document_Type__c);         
                if(doc.Document_Type__c == 'RTO'){
                    wrap.rtoDoc = doc;
                }else if(doc.Document_Type__c == 'DPN'){
                    wrap.dpnDoc = doc;
                }else if(doc.Document_Type__c == 'POA'){
                    wrap.poaDoc = doc;
                }
            }
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('RtoDpnPoaDocumentController','fetchDetails', System.Label.Apex, e,loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        wrap.oppRec = oppRecord;
        
        if(oppRecord != null && oppRecord.stageName == 'Post Sanction Checks and Documentation'){
            module = 'Post Sanction Checks and Documentation';
            for(Loan_Application_Transaction_History__c history : [Select id, Name, Submitted_Flag__c, Screen__c from Loan_Application_Transaction_History__c where Loan_Application_ID__c =: loanApplicationId AND Module__c =: module AND Deal_Number__c =: dealId WITH SECURITY_ENFORCED]){
                if(history.Screen__c == Label.RTO_DPN_POA_Documents && !history.Submitted_Flag__c){
                    showSubmitBtn = false;
                }   
            }
        }else if(oppRecord != null && oppRecord.stageName == 'Pre Disbursement Check'){
            module = 'Pre Disbursement Check';
            List<Profile> profileList = new List<Profile>([SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1]);
            String profileName = profileList[0].Name;
            for(Loan_Application_Transaction_History__c history : [Select id, Name, Submitted_Flag__c, Screen__c from Loan_Application_Transaction_History__c where Loan_Application_ID__c =: loanApplicationId AND Module__c =: module AND Deal_Number__c =: dealId WITH SECURITY_ENFORCED]){
                if(history.Screen__c == Label.RTO_DPN_POA_Documents && !history.Submitted_Flag__c && (profileName == 'IBL Partner Community CVO' || profileName == 'IBL CVO'  || (oppRecord.Product_Type__c == System.Label.Tractor && (profileName == 'IBL TF Payment Executive' || profileName == 'IBL TF Internal Payment Executive')))){
                    showSubmitBtn = false;
                }   
            }
        }       
        wrap.showSubmitBtn = showSubmitBtn;
        return wrap;
    }
    
    /*
    * @Method Name: submitDocuments
    * @Created by:  Anuj
    * @description: to submit the loan application details and update the loan application history records.
    * @Param:       String - loan Application record Id
    * @Param:       String - opportunity record Stage
    * @Param:       String - docDetails List of document records
    */
    @AuraEnabled
    public static string submitDocuments(String loanApplicationId, String oppStage, String docDetails, String dealId){
        try {
            List<Opportunity> oppList = [Select Id,Product_Type__c, Name, AccountId, Account.Type, Vehicle_Type__c FROM Opportunity WHERE Id =: loanApplicationId WITH SECURITY_ENFORCED];
            if(oppStage == System.Label.Post_Sanction_Checks_and_Documentation){
                List<Loan_Application_Transaction_History__c> transactionHistroyList = new List<Loan_Application_Transaction_History__c>();
                
                Boolean vehicle_Inspection = false;
                Boolean structured_EMI = false;
                Boolean invoice = false;
                Boolean security_Mandate = false;
                Boolean IHM = false;
                Boolean loan_Agreement = false;
                Boolean repayment_Mandate = false;
                Boolean additional_Document = false;
                Boolean RTO_DPN_POA_Document = false;
                Opportunity opp = new Opportunity();
                opp.Id = loanApplicationId;
                opp.stageName = 'Pre Disbursement Check';
                List<AccountTeamMember> accTeam = new List<AccountTeamMember>([SELECT Id, accountId, TeamMemberRole, UserId FROM AccountTeamMember WHERE accountId =: oppList[0].accountId AND TeamMemberRole = 'CVO' WITH SECURITY_ENFORCED]);
                List<Loan_Application_Transaction_History__c> historyToUpdate = new List<Loan_Application_Transaction_History__c>();
                List<Applicant__c> applicantDetails = new List<Applicant__c>();
                applicantDetails = [SELECT Id, Name,Would_you_like_to_open_a_bank_account__c, Willing_to_open_Bank_Account_with_IIB__c FROM Applicant__c WHERE Opportunity__c = :loanApplicationId AND Who_will_repay_the_loan__c != NULL AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED];    
                Map<String,Loan_Application_Transaction_History__c> historyMap = new Map<String,Loan_Application_Transaction_History__c>();
                
                for(Loan_Application_Transaction_History__c history : [Select id, Name, Submitted_Flag__c, Screen__c from Loan_Application_Transaction_History__c
                                                                        where Loan_Application_ID__c =: loanApplicationId AND Module__c = :System.Label.Post_Sanction_Checks_and_Documentation AND Deal_Number__c =: dealId  WITH SECURITY_ENFORCED]){
                    if(history.Submitted_Flag__c){
                    
                        if(history.Screen__c == Label.Vehicle_Inspection){
                            vehicle_Inspection = true;
                        }else if(history.Screen__c == Label.Structured_EMI){
                            structured_EMI = true;
                        }else if(history.Screen__c == Label.Invoice){
                            invoice = true;
                        }else if(history.Screen__c == Label.Security_Mandate){
                            security_Mandate = true;
                        }else if(history.Screen__c == Label.IHM){
                            IHM = true;
                        }else if(history.Screen__c == Label.Loan_Agreement){
                            loan_Agreement = true;
                        }else if(history.Screen__c == Label.Repayment_Mandate){
                            repayment_Mandate = true;
                        }else if(history.Screen__c == Label.Additional_Document){
                            additional_Document = true;
                        }
                    }
                    if(!oppList.isEmpty()){
                        if(oppList[0].Product_Type__c == System.Label.PassengerVehicles){
                            history.Current_Owner__c = UserInfo.getUserId();
                            history.New_Owner__c = !accTeam.isEmpty() ? accTeam[0].UserId : null;
                        }else{
                            history.Current_Owner__c = UserInfo.getUserId();
                            history.New_Owner__c = UserInfo.getUserId();
                        }
                        historyToUpdate.add(history);
                    }
                    if(history.Screen__c == Label.RTO_DPN_POA_Documents && !history.Submitted_Flag__c){
                        history.Submitted_Flag__c = true;
                        transactionHistroyList.add(history);
                    }
                }

                List<AccountTeamMember> teamMemberList = new List<AccountTeamMember>();
                if(vehicle_Inspection && structured_EMI && invoice && security_Mandate && IHM && loan_Agreement && repayment_Mandate && additional_Document){
                    for(Loan_Application_Transaction_History__c history : [Select id, Name, Submitted_Flag__c, Screen__c from Loan_Application_Transaction_History__c 
                    where Loan_Application_ID__c =: loanApplicationId AND Module__c = :System.Label.Pre_Disbursement_Check AND Deal_Number__c =: dealId  WITH SECURITY_ENFORCED]){
                        historyMap.put(history.Screen__c, history);
                    }
                    List<Vehicle_Detail__c> vehicleList = new List<Vehicle_Detail__c>([SELECT Id,Vehicle_Delivered__c,Vehicle_type__c from Vehicle_Detail__c WHERE Deal_Number__c =:dealId LIMIT 1]);
                    List<User> intergrationUser = new List<User>();
                    if(oppList != null && oppList[0].accountId != null){
                        if(oppList[0].Product_Type__c == 'Passenger Vehicles'){
                            intergrationUser = [Select Id from User where Name = 'Integration User']; 
                            if(intergrationUser.size()>0){
                                opp.OwnerId = intergrationUser[0].Id;
                            }
                            teamMemberList = [Select Id, accountId, TeamMemberRole, UserId,account.Account_Type__c, account.parent.parentId from AccountTeamMember where accountId =: oppList[0].accountId AND TeamMemberRole = 'CVO' LIMIT 1];
                            if(teamMemberList.size()>0){
                                String parentId = teamMemberList[0].account.parent.parentId;
                                system.debug('parentId'+parentId);
                                List<AccountTeamMember> parentTeamMemberList = [Select Id, accountId, TeamMemberRole, UserId,account.Account_Type__c, account.parent.parentId from AccountTeamMember where accountId =: parentId AND TeamMemberRole = 'CVO'];
                                system.debug('parentTeamMemberList'+parentTeamMemberList);
                                if(parentTeamMemberList.size()>0){
                                    List<OpportunityTeamMember> opportTeamMemberList = new List<OpportunityTeamMember>();
                                    for(AccountTeamMember acc : parentTeamMemberList){
                                        OpportunityTeamMember oppTeam = new OpportunityTeamMember();
                                        oppTeam.OpportunityId = loanApplicationId;
                                        oppTeam.TeamMemberRole = acc.TeamMemberRole;
                                        oppTeam.UserId = acc.UserId;
                                        opportTeamMemberList.add(oppTeam);
                                    }
                                    if(opportTeamMemberList.size()>0){
                                        upsert opportTeamMemberList;
                                    }
                                }
                            }

                    }


                        if(intergrationUser != null && intergrationUser.size() > 0){
                                
                            CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'Notification_to_Onwer'];
                            
                            if(notificationType != null){
                                Messaging.CustomNotification noti = new Messaging.CustomNotification();
                                noti.setBody('Loan Application ' +oppList[0].Name +' has been assigned to you.');
                                noti.setTitle('Loan Application Assignment');
                                noti.setNotificationTypeId(notificationType.Id);
                                noti.setTargetId(loanApplicationId);
                                noti.send(new Set<String> { intergrationUser[0].Id });
                            }
                        }
                        
                        Boolean isLoanAmountApplicable = getLoanAmountfromFO(loanApplicationId,dealId);
                        Boolean isApplicantValid = getValidApplicants(loanApplicationId);
                        for(String screenName : Label.Pre_Disbursement_Check_Loan_App_History.split(';')){
                            if(screenName != null){//RTO DPN post to chatter issue
                                Loan_Application_Transaction_History__c hist = new Loan_Application_Transaction_History__c();
                                hist.Name = screenName;
                                hist.Module__c = 'Pre Disbursement Check';
                                hist.Screen__c = screenName;
                                hist.Loan_Application_ID__c = loanApplicationId;
                                if(historyMap.containsKey(screenName) && historyMap.get(screenName) !=null){
                                    hist.Id = historyMap.get(screenName).Id;
                                }
                                if(screenName.equals('Vehicle Inspection and RC Check') && 
                                (((oppList[0].Vehicle_Type__c.equals('New') || isLoanAmountApplicable == false || isApplicantValid == false) && oppList[0].Product_Type__c != System.Label.Tractor) || (vehicleList.size() > 0 && vehicleList[0].Vehicle_type__c == 'New' && vehicleList[0].Vehicle_Delivered__c == 'NO' && oppList[0].Product_Type__c == System.Label.Tractor))){
                                        hist.Submitted_Flag__c = true;
                                    }else if(screenName.equals('Invoice') && (oppList[0].Vehicle_Type__c.equals('Used') || oppList[0].Vehicle_Type__c.equals('Refinance'))){
                                        hist.Submitted_Flag__c = true;
                                    }
                                    if(oppList.size() > 0 && oppList[0].Product_Type__c == System.Label.Tractor && String.isBlank(hist.Deal_Number__c)){
                                        hist.Deal_Number__c = dealId;
                                    }    
                                transactionHistroyList.add(hist);
                            }
                        }
                        // CISP-2601-START
                        System.debug('transactionHistroyList '+ transactionHistroyList);
                        upsert transactionHistroyList ;

                        // CISP-2601-END
                    }
                }else{
                    return Label.Check_Post_Sanction_screens_Msg;
                }
                if (!historyToUpdate.isEmpty() && Schema.sObjectType.Loan_Application_Transaction_History__c.isUpdateable()) {
                    update historyToUpdate;
                }
                if(Schema.sObjectType.Opportunity.isUpdateable()){
                    System.debug('in the update opp');
                    if(oppList.size() > 0 && oppList[0].Product_Type__c == System.Label.Tractor){
                        teamMemberList = [Select Id, PE_Counter__c, accountId, TeamMemberRole, UserId,account.Account_Type__c, account.parent.parentId from AccountTeamMember where accountId =: oppList[0].accountId AND TeamMemberRole = 'PME' AND User.IsActive = true];
                        if(teamMemberList.size() == 0){
                            return System.Label.No_Payment_Executive;
                        } 

                        Map<Id, Integer> mapOfUserIdToCounter = new Map<Id, Integer>(); //SFTRAC-1339
                        List<AccountTeamMember> listAccountTeamMemberToUpdate = new List<AccountTeamMember>(); //SFTRAC-1339
                        Map<Id, AccountTeamMember> mapOfUserIdToAccountTeamMember = new Map<Id, AccountTeamMember>(); //SFTRAC-1339

                        if(teamMemberList.size()>0){
                            //SFTRAC-1339 Starts
                            for(AccountTeamMember accountTeamMember : teamMemberList) {
                                System.debug('+++++ accountTeamMember is: '+accountTeamMember);
                                accountTeamMember.PE_Counter__c = accountTeamMember.PE_Counter__c == null ? 0 : accountTeamMember.PE_Counter__c;//change made for round robin
                                Decimal peCount = accountTeamMember.PE_Counter__c == null ? 0 : accountTeamMember.PE_Counter__c;
                                mapOfUserIdToCounter.put(accountTeamMember.userId,Integer.valueOf(peCount));
                                mapOfUserIdToAccountTeamMember.put(accountTeamMember.userId,accountTeamMember);
                            }
                            //opp.OwnerId = teamMemberList[0].UserId;   //SFTRAC-1339 commented
                        }//SFTRAC-1339 ends

                        //SFTRAC-1339 Starts
                        if(!mapOfUserIdToCounter.isEmpty()){
                            Id assignmenedUserId = getLowestCounterPE(mapOfUserIdToCounter);
    
                            if(mapOfUserIdToCounter != null && mapOfUserIdToCounter.size()>0) {
                                System.debug('+++++  assignmenedUserId is: '+assignmenedUserId);
                                opp.OwnerId = assignmenedUserId;
                                //Push the detail to SET of assignmentUserId, declare the Set at top                    
                                mapOfUserIdToCounter.put(assignmenedUserId, mapOfUserIdToCounter.get(assignmenedUserId) + 1);
                                System.debug('+++++ mapOfUserIdToCounter '+mapOfUserIdToCounter);
                            }
                        }

                        // Update counter on FI Executive
                        for(Id assignmentUserId : mapOfUserIdToCounter.keySet()) {
                            AccountTeamMember peAccountTeamMember = mapOfUserIdToAccountTeamMember.get(assignmentUserId);
                            System.debug('+++++ peAccountTeamMember is '+peAccountTeamMember);
                            System.debug('+++++ peAccountTeamMember counter '+peAccountTeamMember.PE_Counter__c);
                            if(mapOfUserIdToCounter.get(assignmentUserId) > peAccountTeamMember.PE_Counter__c) {
                                System.debug('+++++ PE_Counter__c '+peAccountTeamMember.PE_Counter__c+' assignmentUserId '+mapOfUserIdToCounter.get(assignmentUserId));
                                peAccountTeamMember.PE_Counter__c = mapOfUserIdToCounter.get(assignmentUserId);
                                listAccountTeamMemberToUpdate.add(peAccountTeamMember);
                            }
                        }
                        System.debug('+++++ list to update '+listAccountTeamMemberToUpdate);
                        //SFTRAC-1339 ends

                        if(allDealClosed(oppList[0].Id, 'Post Sanction Checks and Documentation')){
                            update opp;
                            List<Loan_Application_Transaction_History__c> transactionList = [SELECT Id, Module__c, Screen__c, Submitted_Flag__c, Loan_Application_ID__c FROM Loan_Application_Transaction_History__c where Loan_Application_ID__c  =: loanApplicationId and Module__c = 'Pre Disbursement Check' and screen__c != null and screen__c = 'Additional Documents' WITH SECURITY_ENFORCED];
                            for (Loan_Application_Transaction_History__c lth : transactionList) {
                                lth.Submitted_Flag__c = false;
                            }
                            update transactionList;
                            CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'Notification_to_Onwer'];
                            
                            if(notificationType != null && teamMemberList.size()>0){
                                Messaging.CustomNotification noti = new Messaging.CustomNotification();
                                noti.setBody('Loan Application ' +oppList[0].Name +' has been assigned to you.');
                                noti.setTitle('Loan Application Assignment');
                                noti.setNotificationTypeId(notificationType.Id);
                                noti.setTargetId(loanApplicationId);
                                noti.send(new Set<String> { teamMemberList[0].UserId });
                            }

                            //SFTRAC-1339 starts
                            if(!listAccountTeamMemberToUpdate.isEmpty()) {  
                                //update listAccountTeamMemberToUpdate;
                                Utilities.updateAccountTeamMembers(listAccountTeamMemberToUpdate);
                            }//SFTRAC-1339 ends
                        }
                    }else{
                        update opp;
                    }
                }
            }
            else if(oppStage == 'Pre Disbursement Check'){
                system.debug('== docDetails '+docDetails);
                
                List<Loan_Application_Transaction_History__c> transactionHistroyList = new List<Loan_Application_Transaction_History__c>();
                
                List<Documents__c> docList = new List<Documents__c>();
                if(docDetails != null){
                    docList = (List<Documents__c>)JSON.deserialize(docDetails, List<Documents__c>.class);
                }
                system.debug('== docList '+docList);
                if(Schema.sObjectType.Documents__c.isUpdateable()){
                    update docList;
                }
                
                for(Loan_Application_Transaction_History__c history : [Select id, Name, Submitted_Flag__c, Screen__c from Loan_Application_Transaction_History__c
                            where Loan_Application_ID__c =: loanApplicationId AND Module__c = 'Pre Disbursement Check' AND Deal_Number__c =: dealId WITH SECURITY_ENFORCED]){
                    if(history.Screen__c == Label.RTO_DPN_POA_Documents && !history.Submitted_Flag__c){
                        history.Submitted_Flag__c = true;
                        transactionHistroyList.add(history);
                    }
                }
                system.debug('== transactionHistroyList '+transactionHistroyList);
                if(Schema.sObjectType.Loan_Application_Transaction_History__c.isUpdateable()){
                    update transactionHistroyList;
                }
            }
            return 'Success';            
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('RtoDpnPoaDocumentController','submitDocuments', System.Label.Apex, e,loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);      
        }
    }

   @AuraEnabled
   public static Boolean allDealClosed(String oppId, String module){
        Boolean result = true;
        List<Loan_Application_Transaction_History__c> hisLst = [SELECT Id FROM Loan_Application_Transaction_History__c WHERE Loan_Application_ID__c =:oppId AND Module__c=:module AND Submitted_Flag__c = false WITH SECURITY_ENFORCED ];
        if(hisLst.size()>0){
            result = false;
        }
        return result;
    }

    
    /*
    * @Method Name: createDocuments
    * @Created by:  Anuj
    * @description: to create a Document object for 'RTO, DPN, POA'
    * @Param:       String - Document Type
    * @Param:       String - current Vehicle Record ID
    * @Param:       String - loanApplication ID
    * @Return:      String - created Document's ID
    */
    @AuraEnabled
    public static string createDocuments(String docType,String vehicleDetailId,String applicantId,String loanApplicationId){
        try {
            if(loanApplicationId!=null ){
               String nameTest = docType+' '+loanApplicationId;

               ID otherDocRecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('Other Documents').getRecordTypeId();
               
               Documents__c docObject= new Documents__c(Name = docType+' '+loanApplicationId,Vehicle_Detail__c=vehicleDetailId,Applicant__c=applicantId,Opportunity_Relation__c=loanApplicationId,Document_Type__c=docType,is_Active__c = true);
               
               docObject.RecordTypeId = otherDocRecordTypeId;
               if (Schema.sObjectType.Documents__c.isCreateable()){
                 insert docObject;
               }
               if(Test.isRunningTest())
               {
                  throw new AuraHandledException(System.Label.ExceptionMessage);
               }
               return docObject.Id;
            }
            return null;
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('RtoDpnPoaDocumentController', 'createDocuments', System.Label.Apex, e,loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);  
        }

    }
    
    public static Boolean getLoanAmountfromFO(String loanApplicationId,String dealId){

        try{
            Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED];
            List<Final_Term_Loan_Amount__mdt>  finalTeramLoanList = [SELECT Id, DeveloperName, MasterLabel, Loan_Amount__c FROM Final_Term_Loan_Amount__mdt WITH SECURITY_ENFORCED LIMIT 1];
            List<Final_Term__c> finalTerms = new List<Final_Term__c>();
           if(oppRec.Product_Type__c == System.Label.Tractor){
                List<Vehicle_Detail__c> VehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
                finalTerms = [SELECT Id, Loan_Amount__c from Final_Term__c where Loan_Application__c =: loanApplicationId AND Vehicle_Detail__c =: VehicleLst[0].Id WITH SECURITY_ENFORCED limit 1];
            }else{
                finalTerms = [SELECT Id, Loan_Amount__c from Final_Term__c where Loan_Application__c =: loanApplicationId WITH SECURITY_ENFORCED limit 1];
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
    public static Boolean getValidApplicants(String loanApplicationId){

        try{

            List<Applicant__c> applicants=[select Id,Name, Applicant_Type__c,Who_will_repay_the_loan__c,Scorecard_Decision__c, Gender__c, Journey_Stage__c, Contact_number__c
            from Applicant__c where Opportunity__c = :loanApplicationId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED];

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
    * @Method Name: updateContentDocument
    * @Created by:  Gaurav Rawat
    * @description: to update the content of the document
    * @Param:       String -contentDocumentId
    * @Param:       String - loanApplicationId
    * @Param:       String - documentRecordId
    * @Return:      String -
    */
    @AuraEnabled
    public static string updateContentDocument(String contentDocumentId, String loanApplicationId, String documentRecordId, String docType){
        try {
            List<Documents__c> docList = new List<Documents__c>([Select id,is_Active__c,Name From Documents__c where id =: documentRecordId WITH SECURITY_ENFORCED LIMIT 1]);
            if(docList.size() > 0){
                for(Documents__c doc : docList){
                    doc.Name = docType;
                }
                if(Schema.sObjectType.Documents__c.isUpdateable()){
                    update docList;
                }
            }
            ContentDocumentLink conLink = new ContentDocumentLink();
            conLink.ContentDocumentId = contentDocumentId;
            conLink.LinkedEntityId = documentRecordId;
            if(Schema.sObjectType.ContentDocumentLink.isCreateable() && !Test.isRunningTest()){
                insert conLink;
                return conLink.Id;
            }
            return 'Failure';
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('RtoDpnPoaDocumentController','updateContentDocument', System.Label.Apex, e,loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);      
        }
    }
/*
    * @Method Name: deleteContentDocument
    * @Created by:  Gaurav Rawat
    * @description: to update the content of the document
    * @Param:       String -previousDocumentRecordId
    * @Param:       String - loanApplicationId
    * @Param:       String - contentDocumentId
    * @Return:      String -
    */
    @AuraEnabled
    public static string deleteContentDocument(String previousDocumentRecordId, String loanApplicationId, String contentDocumentId){
        try {
            List<Documents__c> docList = new List<Documents__c>([Select id,is_Active__c From Documents__c where id =: previousDocumentRecordId WITH SECURITY_ENFORCED]);
            if(docList.size() > 0){
                for(Documents__c doc : docList){
                    doc.is_Active__c = false;
                }
                if(Schema.sObjectType.Documents__c.isUpdateable()){
                    update docList;
                }
            }
            List<ContentDocumentLink> conLinkList = new List<ContentDocumentLink>([Select id From ContentDocumentLink where LinkedEntityId =: previousDocumentRecordId AND ContentDocumentId =: contentDocumentId]);
            if(Schema.sObjectType.ContentDocumentLink.isDeletable() && conLinkList.size() > 0){
                delete conLinkList;
                return 'Success';
            }
            return 'Failure';
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('RtoDpnPoaDocumentController','deleteContentDocument', System.Label.Apex, e,loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);      
        }
    }


    
    /*
* @Class Name         WrapperData
* @Author             Anuj
* @Description        This class is used to wrap the data for the rto,dpn component.
    */
    public class WrapperData{
        @AuraEnabled public Opportunity oppRec;
        @AuraEnabled public boolean showSubmitBtn;
        @AuraEnabled public Documents__c rtoDoc;
        @AuraEnabled public Documents__c dpnDoc;
        @AuraEnabled public Documents__c poaDoc;    
    }
        /*
    * @Method Name: validateDocument
    * @Created by:  Gaurav Rawat
    * @description: to validate the document for 'RTO, DPN, POA'
    * @Param:       String - vehicleDetailId, String - applicantId, String - loanApplicationId
    * @Return:      Boolean - true/false
    */
    @AuraEnabled
    public static Boolean validateDocument(String vehicleDetailId,String applicantId, String loanApplicationId){
        try {
            Boolean isValid = false;
            Boolean isRtoDocValid = false;
                Boolean isDpnDocValid = false;
                Boolean isPoaDocValid = false;//OLA-142
                string leadSource; //OLA-142
            if(loanApplicationId!=null ){
                Map<Id,Documents__c> documentMap = new  Map<Id,Documents__c>([SELECT Id,Name,Opportunity_Relation__c,is_Active__c,Vehicle_Detail__c,Document_Type__c,Applicant__c,Opportunity_Relation__r.LeadSource FROM Documents__c
                WHERE Opportunity_Relation__c =:loanApplicationId AND Applicant__c =:applicantId AND Vehicle_Detail__c =:vehicleDetailId AND is_Active__c = true WITH SECURITY_ENFORCED]);
                List<ContentDocumentLink> contentDocLinkList = new List<ContentDocumentLink>([SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId IN: documentMap.keySet() WITH SECURITY_ENFORCED]);
                Map<Id,ContentDocumentLink> contentDocLinkMap = new Map<Id,ContentDocumentLink>();
                for(ContentDocumentLink contentDocLink : contentDocLinkList){
                    if(!contentDocLinkMap.containsKey(contentDocLink.LinkedEntityId)){
                        contentDocLinkMap.put(contentDocLink.LinkedEntityId,contentDocLink);
                    }
                }
               if(documentMap.size()>0){
                   for(Documents__c doc : documentMap.values()){
                       if(doc.Document_Type__c == 'RTO' && contentDocLinkMap.containsKey(doc.Id)){
                        isRtoDocValid = true;
                       }
                       if(doc.Document_Type__c == 'DPN' && contentDocLinkMap.containsKey(doc.Id)){
                        isDpnDocValid = true;
                        }
                        if(doc.Document_Type__c == 'POA' && contentDocLinkMap.containsKey(doc.Id)){
                            isPoaDocValid = true;
                        }//OLA-142
                        leadSource = doc.Opportunity_Relation__r.LeadSource;//OLA-142
                    }
                }
            }
            if(leadSource == 'OLA' && isDpnDocValid && isPoaDocValid ){//OLA-142
                isValid = true;
            }else if(isRtoDocValid && isDpnDocValid && leadsource != 'OLA'){//OLA-142
                isValid = true;
              }
           return isValid;
       } catch (Exception e) {
           ErrorLoggerUtil.logErrorEvent('RtoDpnPoaDocumentController', 'validateDocument ', System.Label.Apex, e,loanApplicationId);
           throw new AuraHandledException(System.Label.ExceptionMessage);
       }
   }
   @AuraEnabled
    public static String changeOwnerOfLA(String recordId){
        system.debug('changeOwnerOfLA');
        try{
            List<Opportunity> oppList = [SElect Id from Opportunity where Id =: recordId];
            if(oppList.size()>0){
                oppList[0].ownerId = UserInfo.getUserId();
                update oppList;
                return 'success';
            }
            return null;
        }
        catch (Exception e) {
           ErrorLoggerUtil.logErrorEvent('RtoDpnPoaDocumentController', 'changeOwnerOfLA ', System.Label.Apex, e,recordId);
           throw new AuraHandledException(System.Label.ExceptionMessage);
       }
    }
    
    //CISP-2885 -- start
    @AuraEnabled
    public static String updatePriorityFlagLoanApp(String recordId){
        try{
            List<Opportunity> oppList = [SElect Id,Priority_Flag__c from Opportunity where Id =: recordId];
            if(oppList.size()>0){
                oppList[0].Priority_Flag__c = true;
                update oppList;
                return 'success';
            }
            return null;
        }
        catch (Exception e) {
           ErrorLoggerUtil.logErrorEvent('RtoDpnPoaDocumentController', 'updatePriorityFlagLoanApp ', System.Label.Apex, e,recordId);
           throw new AuraHandledException(System.Label.ExceptionMessage);
       }
    }
    //CISP-2885 -- end



   @Testvisible
   private static Id getLowestCounterPE(Map<Id, Decimal> mapOfUserIdToCounter) {
       Decimal lowestCounterValue = null;
       Id assignmentUserId = null;
       
       // Iterate through the map entries to find the lowest counter value
       for (Id userId : mapOfUserIdToCounter.keySet()) {
           Decimal counterValue = mapOfUserIdToCounter.get(userId);
           if (lowestCounterValue == null || counterValue < lowestCounterValue) {
               lowestCounterValue = counterValue;
               assignmentUserId = userId;
           }
       }
       return assignmentUserId;
   }
}