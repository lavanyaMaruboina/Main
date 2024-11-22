/**
* @Name         HandleJourney_Utility
* @Author       Manish Baldota
* @Company      Persistent Systems
* @Description  This class is being used to handle the journey status.
* Inputs:       None
* Test Class:   LwcLOSLoanApplicationCntrlTest
* History:
* 18/03/2022    Manish Baldota		- Initial Deveopment 
*/
public without sharing  class HandleJourney_Utility { //CISP-2929
    //@Method:      handleCMUJourneyRestart
    //@Created by:  Manish Baldota.
    //@Description: Method to handle the Journye Restart for CMU
    //				1. Borrower Journy Restart - Clone new application with Limited details, and link existing to new.
    //				2. Co-borrower journey restart - Clone new application with cloned new borrower with existing details, capture new co-borrower.
    //@Param:       String - loanApplication ID
    //@Return:      String - Execution Status
    public static String handleCMUJourneyRestart(String applicantId,String restartReason){
        try{
            ReturnMessageWrapper returnWrapperElement = new ReturnMessageWrapper();
            System.debug('Log- handleCMUJourneyRestart - Called');
            System.debug('Log- handleCMUJourneyRestart - '+applicantId);
            System.debug('Log- handleCMUJourneyRestart - '+restartReason);
            
            if(String.isNotBlank(applicantId)){
                //Default status
                returnWrapperElement.isSuccess = true;
                returnWrapperElement.message = 'Journey has been restarted';

                // Get the borrower details
                Applicant__c applicantDetails = [SELECT Id,Applicant_Type__c,Opportunity__c 
                                                FROM Applicant__c WHERE Id =: applicantId 
                                                WITH SECURITY_ENFORCED LIMIT 1];
                
                                                //SANKET:: Commented Borrower and Co-Borrower logic: For both Journey will start from Loan Initiation with first screen details except Contact Details, Consent and Image Upload
                //Operate borrower and co-borrower journey restrart
                /*if(applicantDetails.Applicant_Type__c == System.label.Borrower){*/
                    Opportunity existingOpportunity = [SELECT Id, createdById, Name, StageName, Sub_Stage__c, LastStageName__c, Product_Type__c , Agent_BL_code__c, AccountId, PartnerAccountId, OwnerId, Lead_number__c,LeadSource, (SELECT ID, createdById, Opportunity__c, Name, Customer_First_Name__c, Customer_Last_Name__c, Journey_Stage__c, Applicant_Type__c FROM Applicants__r WHERE Applicant_Type__c =: System.label.Borrower AND In_Active_Applicant__c = false) FROM Opportunity WHERE Id =: applicantDetails.Opportunity__c WITH SECURITY_ENFORCED];
                    Opportunity newOpportunity = existingOpportunity.clone(false, false, false, true);
                    newOpportunity.StageName = 'Loan Initiation';
                    newOpportunity.LastStageName__c = 'Loan Initiation';
                    newOpportunity.Name = newOpportunity.Lead_number__c = handleLoanApplictionNumber(existingOpportunity.Name,'CMU Journey Restart');
                    newOpportunity.CloseDate = System.today()+30;
                    if(existingOpportunity.LeadSource == 'DSA'){//CISP-12675
                        newOpportunity.OwnerId = existingOpportunity.OwnerId;    
                        }else{
                    newOpportunity.OwnerId = existingOpportunity.CreatedById;//CISP-2836
                        }
                    newOpportunity.CreatedById = existingOpportunity.CreatedById;//CISP-2836
                    if (Schema.sObjectType.Opportunity.isCreateable()){
                        Insert newOpportunity;
                    } else {
                        returnWrapperElement.isSuccess = false;
                        returnWrapperElement.message = 'Missing write access';
                    }

                    existingOpportunity.StageName = 'Journey Restart';
                    existingOpportunity.Journey_Restart_Reason__c = restartReason;
                    if (Schema.sObjectType.Opportunity.isUpdateable()){
                        update existingOpportunity;
                        //CISP-2868-START
                        if(Schema.sObjectType.Refresh_View__e.isCreateable()){
                            Refresh_View__e refreshEvent = new Refresh_View__e();
                            refreshEvent.Record_Id__c = existingOpportunity.Id;
                            refreshEvent.Stage__c = existingOpportunity.StageName;
                            EventBus.publish(refreshEvent);
                        }
                        //CISP-2868-END
                    } else {
                        returnWrapperElement.isSuccess = false;
                        returnWrapperElement.message = 'Missing update access';
                    }

                    if(existingOpportunity.Applicants__r[0] != null){
                        Applicant__c newApplicant = existingOpportunity.Applicants__r[0].clone(false, false, false, true);
                        newApplicant.Opportunity__c = newOpportunity.Id;
                        newApplicant.Journey_Stage__c = 'User Details';
                        if (Schema.sObjectType.Applicant__c.isCreateable()){
                            System.debug('Log - Logged In User:: '+ UserInfo.getUserId());
                            System.debug('Log - newApplicant:: '+newApplicant);
                            insert newApplicant;
                        } else {
                            returnWrapperElement.isSuccess = false;
                            returnWrapperElement.message = 'Missing write access';
                        }
                    }
                    if(existingOpportunity.LeadSource == 'DSA'){//CISP-12675
                        newOpportunity.OwnerId = existingOpportunity.OwnerId;    
                        }else{
                    newOpportunity.OwnerId = existingOpportunity.createdById;
                        }
                    if (Schema.sObjectType.Opportunity.isUpdateable()){
                        update newOpportunity;
                    } else {
                        returnWrapperElement.isSuccess = false;
                        returnWrapperElement.message = 'Missing update access';
                    }
                    System.debug('Log - NewOpportunity:: '+newOpportunity);
               
            }else{
                returnWrapperElement.isSuccess = false;
                returnWrapperElement.message = 'Missing Applicant Details';
            }

            return System.JSON.serialize(returnWrapperElement);
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent(' HandleJourney_Utility ', ' handleCMUJourneyRestart ', 'System.Label.Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    public Class ReturnMessageWrapper{
        @AuraEnabled public Boolean isSuccess {get;set;}
        @AuraEnabled public String message {get;set;}
    }

    public static String handleLoanApplictionNumber(String existingLoanAppNumber,String journeyType){
        try{
        String loanApplicationNumber = '';
        
        if(journeyType == 'CMU Journey Restart'){
            //Handling number sequence for the already restarted Application.
            //Replace the sequence with custom label.
            if(existingLoanAppNumber.contains('_C')){
                //Logic to Implement check for all the last digit get that and do the addition to the code.
                Integer lastDigit = Integer.valueOf(existingLoanAppNumber.right(existingLoanAppNumber.length()-(existingLoanAppNumber.length()-1)));//CISP-6610
                loanApplicationNumber = existingLoanAppNumber.left(existingLoanAppNumber.length()-1) + String.valueOf(lastDigit+1);//CISP-6610
            }else{
                loanApplicationNumber = existingLoanAppNumber+'_C1';
            }
        }
            return loanApplicationNumber;}
        catch(Exception e){
              ErrorLoggerUtil.logErrorEvent(' HandleJourney_Utility ', ' handleLoanApplictionNumber ', 'System.Label.Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    public static String getLastSalesUserId(String opptyId){
        try{
            Id stageChangeRecordTypeID = Schema.SObjectType.Loan_Application_Transaction_History__c.getRecordTypeInfosByName().get('Stage Change').getRecordTypeId();
            List<Loan_Application_Transaction_History__c> lathRecords = [SELECT Id,Current_Owner__c,New_Owner__c,Loan_Application_ID__r.ownerId FROM Loan_Application_Transaction_History__c WHERE Module__c = 'Credit Processing' AND Loan_Application_ID__c =: opptyId AND RecordTypeId =: stageChangeRecordTypeID];
            if(!lathRecords.isEmpty()){
                return lathRecords[0].Current_Owner__c;
            } else {
                return [SELECT ID,OwnerId FROM Opportunity WHERE Id=:opptyId].OwnerId;
            }
        }catch(Exception e){
              ErrorLoggerUtil.logErrorEvent(' HandleJourney_Utility ', ' getLastSalesUserId ', 'System.Label.Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    @AuraEnabled
    public static string getBussSourceBy(String loanApplicationId){
        Map<string,string> bussSourcemap = new Map<string,string>();
        Set<String> previosAccountIdSet = new Set<String>();
        Opportunity opp = [Select accountId,owner.Name,ownerId,Product_Type__c,PreviousAccountId__c from Opportunity where Id =:loanApplicationId];
        try {
            if(opp.PreviousAccountId__c != null){
                List<String> previosAccountIdList = opp.PreviousAccountId__c.split(',');
                previosAccountIdSet = new Set<String>(previosAccountIdList);
            }
            previosAccountIdSet.add(opp.accountId);
            for(AccountTeamMember atm : [SELECT AccountId, TeamMemberRole, User.Name,UserId,user.IsActive FROM AccountTeamMember 
                                        WHERE AccountId IN : previosAccountIdSet AND (TeamMemberRole = 'BE' OR TeamMemberRole = 'CS') AND user.IsActive = true WITH SECURITY_ENFORCED]) {
                                            bussSourcemap.put(atm.UserId,atm.User.Name.removeStart('ibl'));
                                        }
                return JSON.serialize(bussSourcemap);
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('HandleJourney_Utility', 'getBussSourceBy', System.Label.Apex, e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string getBussDoneByID(String loanApplicationId){
        Map<string,string> bussSourcemap = new Map<string,string>();
        Set<String> previosAccountIdSet = new Set<String>();
        Opportunity opp = [Select accountId,owner.Name,ownerId,Product_Type__c,PreviousAccountId__c from Opportunity where Id =:loanApplicationId];
        try {
            if(opp.PreviousAccountId__c != null){
                List<String> previosAccountIdList = opp.PreviousAccountId__c.split(',');
                previosAccountIdSet = new Set<String>(previosAccountIdList);
            }
            previosAccountIdSet.add(opp.accountId);
            for(AccountTeamMember atm : [SELECT AccountId, TeamMemberRole, User.Name,UserId,user.IsActive FROM AccountTeamMember 
                                        WHERE AccountId IN : previosAccountIdSet AND (TeamMemberRole = 'BE') AND user.IsActive = true WITH SECURITY_ENFORCED]) {
                                            bussSourcemap.put(atm.UserId,atm.User.Name.removeStart('ibl'));
                                        }
                return JSON.serialize(bussSourcemap);
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('HandleJourney_Utility', 'getBussDoneByID', System.Label.Apex, e);
            throw new AuraHandledException(e.getMessage());
        }
    }
}