public without sharing class DSA_WSController {
    public List<Geo_State_Masters__c> getStateCityMaster() { 
        List<Geo_State_Masters__c> listOfStateValue = new List<Geo_State_Masters__c>();
        listOfStateValue = [
            SELECT
                Id,
                NeSL_State_Code__c,
                Name,
                State_Code__c,
                Pincode__c,
                Pincode_Starting_Max__c,
                (SELECT Id, Name, City_Code__c FROM City_State_Masters__r)
            FROM Geo_State_Masters__c
            WITH SECURITY_ENFORCED
            ORDER BY Name ASC
        ];
        return listOfStateValue;
    }
    public List<Beneficiary_BlCode__c> getBenefBlCode(String benCode) {
        return [
            SELECT Id, Name, Ben_code__c, Bl_Code_Details__r.Bl_Code__c
            FROM Beneficiary_BlCode__c
            WHERE Ben_code__r.Ben_code__c = :benCode AND Ben_code__r.Status_Flag__c = 'L'
        ];
    }


     /*
     * @Method:      deleteCoBorrower
     * @Created by:  Rohan Saxena
     * @Description: delete a Co-borrower record
     * @Param:
     * @Return:
     */
    @AuraEnabled
    public static void deleteCoBorrower(Id AppId) {
        try {
            String Who_will_Repay='Co-Borrower';
            List<Applicant__c> lstApp = new List<Applicant__c>();
            Id LoanId = [SELECT Opportunity__c FROM Applicant__c WHERE Id =:AppId Limit 1].Opportunity__c;
            List<Applicant__c> lstborr = [
                SELECT
                    Id,
                    Opportunity__c,
                    Who_will_repay_the_loan__c,
                    Applicant_Type__c
                FROM Applicant__c
                WHERE Opportunity__c = :LoanId
            ];

            for(Applicant__c app: lstborr){
                if(app.Applicant_Type__c=='Borrower'){
                    Who_will_Repay = 'Borrower';
                }
                else if(app.Applicant_Type__c=='Co-borrower'){
                    Applicant__c objapp = new Applicant__c();
                    objapp.Id = app.Id;
                    lstApp.add(objapp);
                }
            }
            if(Who_will_Repay=='Borrower'){
                delete lstApp;
            }

        }
         catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('DSA_WSController', 'deleteCoBorrower', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
   /*
     * @Method:      GetBEDetails
     * @Created by:  Rohan Saxena
     * @Description: New DSA Requirement to fetch BE details.
     * @Param:String, String
     * @Return:Map<Id,String>
     */
    
    public Map<Id,String> GetBEDetails(String userId, String ApplicantId) {
        try{
            Map<Id,String> BEDetails = new Map<Id,String>();
            Set<String> BE_BL_Code = new Set<String>();
            Set<String> DSA_BL_Code = new Set<String>();
            User PreffBEUser;
            //Preferred BE Logic
            User dsaUser = [Select Id, EmployeeNumber,Name from User where Id =: userId Limit 1];
            List<DSA_Preferred_BE_Mapping__c> lstPreffBE = [Select Id,Preferred_BE_Name__c, Emp_Id__c from DSA_Preferred_BE_Mapping__c where Ben_code__c=:dsaUser.EmployeeNumber AND Active_Flag__c = true Limit 1];
            if(!lstPreffBE.isEmpty()){
            PreffBEUser = [Select Id, Name from User where EmployeeNumber=: lstPreffBE[0].Emp_Id__c AND IsActive=true Limit 1];
            List<AccountTeamMember> lstAccountTeams = [Select Id, Account.BranchBLCode__c from AccountTeamMember where UserId=:PreffBEUser.Id AND user.profile.Name = 'IBL Business Executive'];
            for(AccountTeamMember act:lstAccountTeams){
                BE_BL_Code.add(act.Account.BranchBLCode__c);//BL code of BE
            }
                }
            List<Beneficiary_BlCode__c> lstBenef = getBenefBlCode(dsaUser.EmployeeNumber);// BL Code of DSA
            for(Beneficiary_BlCode__c blcode: lstBenef){
                DSA_BL_Code.add(blcode.Bl_Code_Details__r.Bl_Code__c);
                if(BE_BL_Code.contains(blcode.Bl_Code_Details__r.Bl_Code__c) && !lstPreffBE.isEmpty()){
                    BEDetails.put(PreffBEUser.Id, PreffBEUser.Name+'__Preffered__');
                }
            }
            
            //Other BE Logic
            set<String> setBLCode = new set<String>();
            //Fetch pincode of Applicant
            String strpincode = [Select id,Office_PinCode__c from Applicant__c where Id=:ApplicantId Limit 1].Office_PinCode__c;
            Decimal pincode = decimal.valueOf(strpincode);
            //Fetch BE Master
            List<BE_Master__c> lstBEMaster = [Select Pin_Code__c ,BL_Code__c from BE_Master__c Where Pin_Code__c=:pincode AND Product_Type__c='Passenger Vehicles' AND Vehicle_Type__c!='New'];
            for(BE_Master__c BEMaster : lstBEMaster){
                setBLCode.add(BEMaster.BL_Code__c);
            }
            List<AccountTeamMember> ACT = [Select Id, UserId, User.Name,Account.BranchBLCode__c from AccountTeamMember where Account.BranchBLCode__c =: setBLCode AND user.profile.Name = 'IBL Business Executive'];
            for(AccountTeamMember ATM : ACT){
                if(!lstPreffBE.isEmpty()){
                   if(PreffBEUser.Id !=ATM.UserId && DSA_BL_Code.contains(ATM.Account.BranchBLCode__c)){
                    BEDetails.put(ATM.UserId, ATM.User.Name);
                } 
                } 
                else if(DSA_BL_Code.contains(ATM.Account.BranchBLCode__c)){
                    BEDetails.put(ATM.UserId, ATM.User.Name);
                }
            }
            return BEDetails;
        }
        catch(Exception E){
            ErrorLoggerUtil.logErrorEvent(
                'IND_DSAController',
                ' GetBEDetails ',
                System.Label.Apex,
                e
            );
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    

    /*
     * @Method:      dsaToBEAssignment
     * @Created by:  Rohan Saxena
     * @Description: Transfer Loan Application from DSA to BE
     * @Param:
     * @Return:
     */
    // prettier-ignore
    public String dsaToBEAssignment(String OppId,String UserId) {
        try {
            User objDSA = [
                SELECT Id, FirstName, LastName,Email
                FROM User
                WHERE Id = :UserId
                LIMIT 1
            ];
          /*  Beneficiary_BlCode__c objBenef = getBenefBlCode(objDSA.IND_BEN_Code__c)[0];
            
            AccountTeamMember objAccTeamMember = [
                SELECT
                    Id,
                    AccountId,
                    Account.BranchBLCode__c,
                    UserId,
                    User.FirstName,
                    User.LastName,
                    User.Email,
                    TeamMemberRole
                FROM AccountTeamMember
                WHERE
                    Account.BranchBLCode__c = :objBenef.Bl_Code_Details__r.Bl_Code__c
                    AND User.isActive = TRUE
                    AND TeamMemberRole = 'BE'
                    AND user.profile.name = 'IBL Business Executive'
                LIMIT 1
            ];*/
            Opportunity objOpp = [
                SELECT Id, Lead_Number__c, (SELECT Id FROM Applicants__r)
                FROM Opportunity
                WHERE Id = :OppId
                LIMIT 1
            ];
            objOpp.OwnerId = UserId;
            //objOpp.Vehicle_Type__c = '';
            objOpp.DSA_Stage__c = 'Transferred';
            objOpp.DSA_Sub_Stage__c = 'Application in Progress';
            update objOpp;
            List<Applicant__c> appList = new List<Applicant__c>();
            for (Applicant__c appRecord : objOpp.Applicants__r) {
                Applicant__c app = new Applicant__c();
                app.Id = appRecord.Id;
                app.Check_Eligibility_Match__c = false;
                app.Check_Eligibility_Message__c = '';
                app.Bureau_Pull_Match__c = false;
                app.Bureau_Pull_Message__c = '';
                appList.add(app);
            }
            update appList;
			
            updateFinalterms(OppId);//DSA new requirement to make Referrer name readonly
           /* insert new OpportunityShare(
                OpportunityId = objOpp.Id,
                UserOrGroupId = UserInfo.getUserId(),
                OpportunityAccessLevel = 'Edit'
            );*/
            insert new OpportunityTeamMember(
                UserId=UserInfo.getUserId(),
                OpportunityId=objOpp.Id,
                TeamMemberRole='DSA',
                OpportunityAccessLevel='Edit'
            );
            //Deleting existing PAN document so that BE can reupload the same in VLOS
            delete [SELECT Id FROM Documents__c WHERE Opportunity_Relation__c = :objOpp.Id AND Document_Type__c = 'PAN'];
            
            //Deleting the dedupe response so that dedupe can run again in VLOS
            delete [SELECT id FROM Customer_Dedupe_Response__c Where Applicant__r.opportunity__c=:objOpp.Id];

             //Deleting the final terms value so that BRE engine can re-run in VLOS
             List<Final_Term__c> lstFinalTerms =[SELECT Id, Loan_Amount__c, LtvEngine_Ltv__c, Threshold_CRM_IRR__c, PricingEngine_thresholdNetrr__c FROM Final_Term__c where Loan_Application__c=:objOpp.Id];
             lstFinalTerms[0].Loan_Amount__c= null;
         lstFinalTerms[0].LtvEngine_Ltv__c= null;
         lstFinalTerms[0].Threshold_CRM_IRR__c= null;
         lstFinalTerms[0].PricingEngine_thresholdNetrr__c= null;
         update lstFinalTerms;
            IND_DSAController.sendEmailToBE(objDSA.Email, UserInfo.getName(), objOpp.Lead_Number__c);
            return (String.isBlank(objDSA.FirstName) ? '' : objDSA.FirstName) + ' ' + (String.isBlank(objDSA.LastName) ? '' : objDSA.LastName);
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent(
                'IND_DSAController',
                ' dsaToBEAssignment ',
                System.Label.Apex,
                e
            );
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    /*
     * @Method:      getLoanByRecordId
     * @Created by:  Swapnil Prajapati
     * @Description: get loan and related records
     * @Param:
     * @Return:
     */
    public IND_DSAController.DSA_NewLeadWrapper getLoanByRecordId(String recordId) {
        String oppFields = 'Id, Name, Lead_number__c, StageName, DSA_Stage__c, (SELECT Id, Service_Name__c, Status__c, Original_Response__c FROM Integration_Log__r)';
        String appFields = 'Id, Applicant_Type__c, Consent_Received__c, Contact_number__c, Customer_First_Name__c, Customer_Last_Name__c, Lead_number__c, Opportunity__c';
        appFields += ', Gender__c, Name, PAN_No__c, Register_for_WhatsApp_Banking__c, Residence_country__c, Journey_Stage__c';
        appFields += ', Office_Address_Line_1__c, Office_Address_Line_2__c, Office_City__c, Office_State__c, Office_PinCode__c, Whatsapp_number__c';
        appFields += ',(SELECT Id, Gender__c, KYC_DOB__c, PAN_No__c, Salutation__c FROM Documents__r)';
        appFields += ',(SELECT Id, Dedupe_Journey_Status__c FROM Customer_Dedupe_Response__r)';
        try {
            if (Schema.sObjectType.Opportunity.isAccessible()) {
                List<Opportunity> opp = Database.query(
                    'SELECT ' +
                    oppFields +
                    ' FROM Opportunity WHERE Id =: recordId'
                );
                if (opp.isEmpty()) {
                    throw new AuraHandledException(
                        'No loan application found for this record id.'
                    );
                }
                Id oppId = opp[0].Id;
                List<Applicant__c> app = Database.query(
                    'SELECT ' +
                    appFields +
                    ' FROM Applicant__c WHERE Opportunity__c =: oppId AND Applicant_Type__c = \'Borrower\''
                );
                if (app.isEmpty()) {
                    return new IND_DSAController.DSA_NewLeadWrapper(opp[0], new Applicant__c());
                } else {
                    return new IND_DSAController.DSA_NewLeadWrapper(opp[0], app[0]);
                }
            }
            return null;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent(
                'DSA_CreateNewLeadController',
                'getLoanByRecordId',
                'Apex',
                e
            );
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    /*
     * @Method:      updateFinalterms
     * @Created by:  Rohan Saxena
     * @Description: Auto-Populate Referrer Name.
     * @Param:
     * @Return:
     */
    public static void updateFinalterms(String OppId){
        try{
            Opportunity objOpp = [Select Id, CreatedById from Opportunity where Id =:OppId Limit 1];
            Final_Term__c objFinalTerms = [Select Id from Final_Term__c where Loan_Application__c  =: objOpp.Id Limit 1];
            User objUser = [Select id, Name,EmployeeNumber from User where Id = :objOpp.CreatedById AND EmployeeNumber != null Limit 1];
            if(objUser !=null){
                Final_Term__c FinalTerms = new Final_Term__c();
                FinalTerms.Id = objFinalTerms.Id;
                FinalTerms.Referrer_Name__c  = objUser.Name + '|' + objUser.EmployeeNumber;
                FinalTerms.Referrer_Ben_Code__c  = objUser.EmployeeNumber;
                update FinalTerms;
            }
        }
        Catch(Exception e){
           throw new AuraHandledException('DSA Name not caputured properly. Please contact with Administrator'); 
        }
    }
    public Map<String, String> getRCLimitData() {
        Map<String, String> retMap = new Map<String, String>();
        try{
        User objDSA = [
            SELECT Id, EmployeeNumber
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
        if (String.isBlank(objDSA.EmployeeNumber)) {
            throw new AuraHandledException('Error: DSA user is not assigned a BEN Code.');
        }
        List<MIS_RC_Limit_Topsheet__c> rcLimitTopsheet = [
            SELECT Id, Max_Limit__c, Max_Amount__c, Max_Days__c, RC_Pending__c, Fin_Amt__c
            FROM MIS_RC_Limit_Topsheet__c
            WHERE Ben_Code__c = :objDSA.EmployeeNumber AND Ben_Type__c = 'DSA' AND RC_Pending__c != null AND Fin_Amt__c != null
        ];
        Double sumRCPending = 0;
        Double sumfinAmt = 0;
        Double availableAmount = 0;
        //Calculating sum of values as per discussion with anurag on 25/11/2022 - Swapnil
        for(MIS_RC_Limit_Topsheet__c rec : rcLimitTopsheet){
            sumRCPending += rec.RC_Pending__c;
            sumfinAmt += rec.Fin_Amt__c;
        }
        List<AggregateResult> rcLimitDt = [
            SELECT MIN(Disbursed_Date__c)
            FROM MIS_RC_Limit_Dt__c
            WHERE
                Ben_Code__c = :objDSA.EmployeeNumber
                AND Ben_Type__c = 'DSA'
                AND IBL_Lien_Marked__c = 'N'
        ];
        if (!rcLimitTopsheet.isEmpty()) {
            retMap.put('sanctionedNoOfCars', String.valueOf(rcLimitTopsheet[0].Max_Limit__c));
            retMap.put('sanctionedAmount', String.valueOf(rcLimitTopsheet[0].Max_Amount__c));
            retMap.put('sanctionedNoOfDays', String.valueOf(rcLimitTopsheet[0].Max_Days__c));
            retMap.put(
                'availableNoOfCars',
                String.valueOf((rcLimitTopsheet[0].Max_Limit__c - sumRCPending)?.round())
            );
            retMap.put(
                'availableAmount',
                String.valueOf((rcLimitTopsheet[0].Max_Amount__c - sumfinAmt)?.round())
            );
        }
        if (rcLimitDt[0].get('expr0') != null && !rcLimitTopsheet.isEmpty()) {
            Double availableNoOfDays = rcLimitTopsheet[0].Max_Days__c - Date.valueOf(rcLimitDt[0].get('expr0')).daysBetween(System.today());
            retMap.put(
                'availableNoOfDays',
                availableNoOfDays <= 0 ? 'Limit Breached' : String.valueOf(availableNoOfDays)
            );
            }
        }catch(Exception e){
            throw new AuraHandledException('No RC Limit data exists for the DSA.');
        }
        return retMap;
    }
}