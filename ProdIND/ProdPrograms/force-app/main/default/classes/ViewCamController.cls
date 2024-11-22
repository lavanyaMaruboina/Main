/**
* @Name         ViewCamController
* @Author       Rajat Jaiswal
* @Description  This Class is used to showing all field values in the CAM Screen. Also this class is "without sharing" because we have to give read/write access to forwarded users.
**/
public without sharing class ViewCamController {  
    public String schemeName{get;set;}
    public String schemeCode{get;set;}
    public String minCRM{get;set;}//CISP-2702
    public String maxCRM{get;set;}//CISP-2702
    public String minNetIrr{get;set;}//CISP-10059
    public String maxNetIrr{get;set;}//CISP-10059
    public String productType{get;set;}//Start CISP-2522
    public String oppVehicleType{get;set;}
    public Decimal totalFundedPremium{get;set;}
    public String totalLoanAmountWithInsurance{get;set;}
    public Decimal exShowroomPrice{get;set;}//End CISP-2522
    public String vehicleSubCategory{get;set;}
    public List<Lien_Detail__c> lienList{get;set; } 
    public Boolean family_Exposure {get; set;}
    public Boolean haveFamilyExposure {get; set;}
    public Boolean haveAdditionalExposure {get; set;}
    public String vehicleBasicPrice {get; set;}
    public String yearOfManufacture {get; set;}
    public String productSegment {get; set;}
    public String myString {get; set;}
    public String parentLoanAppId {get; set;}//CISP-2445
    public String grandparentLoanAppId {get; set;}//CISP-2445
    public string forwardWrapperList{get;set;}
    public String emailRequestWrapper{get;set;}
    public string requestLabel;
    public Carrier carrier{get;set;}
    public string forwardResponse{get;set;}
    public string option{get;set;}
    public Opportunity opp{get;set;}
    public Opportunity opploan{get;set;}
    public CIBIL_Details__c cibil{get;set;}
    public CIBIL_Details__c coBorrowercibil{get;set;}
    public Applicant__C appBorrower{get;set;}
    public Applicant__C appCoBorrower{get;set;}
    public Income_Details__c incomeBorrower{get;set;}
    public Income_Details__c incomeCoBorrower{get;set;}
    public Customer_Dedupe_Response__c borrowerCustomerDedupe{get;set;}
    public Customer_Dedupe_Response__c coborrowerCustomerDedupe{get;set;}
    public DedupeDataWrapper borrowerDedupeWrapper{get;set;}
    public List<DedupeDataWrapper> coborrowerDedupeList{get;set;}
    public list <Proposal_Approval_Log__c> applog{get;set;}
    public list<DeviationWrapper> deviationWrapperList{get;set;}
    public list<Deviation__c> deviation{get;set;}
    public list<Documents__c> document{get;set;}
    public Documents__c resiFiBorrowerDoc{get;set;}
    public Documents__c resiFiCoBorrowerDoc{get;set;}
    public Documents__c resiFiGuarantorDoc{get;set;}
    public Documents__c officeFiBorrowerDoc{get;set;}
    public Documents__c officeFiCoBorrowerDoc{get;set;}
    public Documents__c officeFiGuarantorDoc{get;set;}
    public list<AnnexureWrapper> annexureWrapperList{get;set;}
    public Vehicle_Detail__c veh{get;set;}
    public Product2 prod{get;set;}
    public Documents__c docBorrower{get;set;}
    public Documents__c docCoBorrower{get;set;}
    public String borrowerResiFi{get;set;}
    public String coBorrowerResiFi{get;set;}
    public String guarantorResiFi{get;set;}
    public String rcuCaseRecordId{get;set;}//SFTRAC-1271
    public String borrowerOfficeFi{get;set;}
    public String coBorrowerOfficeFi{get;set;}
    public String guarantorOfficeFi{get;set;}
    public Exposure__c exp{get;set;}
    public List<Exposure__c> borrowerExposureList{get;set;}
    public List<Exposure__c> coBorrowerExposureList{get;set;}
    public CAM__C cam{get;set;}
    public Final_Term__c finalterms{get;set;}
    public Field_Investigation__c FI{get;set;}
    public Field_Investigation__c officeFI{get;set;}
    public Field_Investigation__c permanentFI{get;set;}
    public Field_Investigation__c coFI{get;set;}
    public Field_Investigation__c officeCoFI{get;set;}
    public Field_Investigation__c permanentCoFI{get;set;}
    public String accN {get;set;}    
    public String valueType;   
    public String fundingOn{get;set;}   
    public String registeredIncome {get;set;}  
    public String vehicleType {get;set;}  
    public String proposalStatus{get;set;} 
    public String borrowerRiskBand{get;set;} 
    public String coborrowerRiskBand{get;set;} 
    public String proposalRiskBand{get;set;} 
    public String currentUserId{get;set;}
    public String currentUserRole{get;set;}
    public String warningMessage{get;set;}
    public String approvalConditionsOrRemarks{get;set;}
    public String currentUserLevel{get;set;}
    public String borrowerAge{get;set;}
    public String coborrowerAge{get;set;}
    public String borrowerGender{get;set;}
    public String coborrowerGender{get;set;}
    public String highestAuthorityRole{get;set;}
    public Integer numberOfInstalments{get;set;}
    public boolean flag=true;  
    public boolean disableAll{get;set;}
    public boolean isNonMandatoryUser{get;set;}
    public boolean disableRadioButton{get;set;}
    public Decimal onRoadPrice{get;set;}// CISP-2459
    public Decimal totalPayInAmount{get;set;}
    public Decimal totalPayOutAmount{get;set;}
    public Decimal updatedLoanAmount{get;set;}
    public String finalTermId{get;set;}
    public Decimal updatedIRR{get;set;}
    public Decimal totalDealerPayout{get;set;}
    public Decimal netLTV{get;set;}
    public Decimal grossLTV{get;set;}
    public Decimal loanAmount{get;set;}
    public Decimal originalloanAmount{get;set;}
    public Decimal requiredNetIRR{get;set;}
    public Decimal originalIRR{get;set;}
    public Decimal currentExposureAmount{get;set;}
    public Decimal existingBorrowerExposureAmount{get;set;}
    public Decimal bankExposureAmount{get;set;}
    public Decimal existingOtherExposureAmount{get;set;}
    public Decimal existingCoBorrowerExposureAmount{get;set;}
    public Decimal advanceEmiAmount{get;set;}
    public Decimal totalExposureAmount{get;set;}
    public String grossInvoiceAmount{get;set;}
    public String LTVInvoiceAmount{get;set;}
    public String branchStateName{get;set;}
    public String invoiceAmount{get;set;}
    public String customerCode{get;set;}
    public String coborrowerCustomerCode{get;set;}
    public String crossSell{get;set;}
    public Deviation__c items{get;set;}
    public Existing_EMI__c existingEMI{get;set;}
    public String status{get;set;}
    public String selectedstatus{get;set;}
    public String borrowerABB{get;set;}
    public String coborrowerABB{get;set;}
    public String isForwardTo{get;set;}
    public String forwardTo{get;set;}
    public String vehicleId{get;set;}
    public String remarks{get;set;}
    public Id tobeEdited{get;set;}
    public Set<String> additionalExposureNameSet{get;set;}
    public Set<String> familyExposureNameSet{get;set;}
    public Map<String, List<Exposure__c>> lstAdditionalExpCustCodes{get;set;}
    public Map<String, List<Exposure__c>> lstFamilylExpCustCodes{get;set;}
    public Map<string,Set<string>> deviationLevelVsUserIdList{get;set;}
    public Map<string,string> committeeDeviationRolesMap{get;set;}
    public Map<String, String> roleVsTypeMap {get;set;}
    public Map<String, String> roleVsLevelMap {get;set;}
    public Map<string,string> userIdVsLevelMap{get;set;}
    List<selectOption> options = new List<selectOption>();
    List<selectOption> forwardOptions = new List<selectOption>();
    List<selectOption> availableForwardedRoles{get;set;}
    public String borrowerEmpType{get;set;}
    public String coborrowerEmpType{get;set;}
    public static Id recordId = '00671000001LBEQAA4';
    public static Id camRecordId;
    public static Boolean enableEquifaxBorrowerButton {get;set;}
    public static Boolean enableEquifaxCoBorrowerButton {get;set;}
    public Decimal roadTaxValue {get;set;}
    public String leadSource {get;set;}//OLA-96
    public Boolean isLeadSourceOLA {get;set;}//OLA
    public Boolean isNetIRREditable{get;set;} // CISP-12742
    public Boolean isLoanAmountEditable{get; set;} // CISP-14432
     public Boolean isImmputedIRREditable{get; set;}//CISP-20773
    public Boolean isCRMIRREditableTf{get;set;}
    public Boolean isLoanAmountEditableTF{get;set;}
    public String evaluationtypeBorrower {get;set;}
    public String evaluationtypeCoBorrower {get;set;}
    public Decimal netAnnualIncome {get;set;} 
    public String borrowerProfile {get;set;}
    public String borrowerCategory {get;set;}
    public String coBorrowerProfile {get;set;}
    public String coBorrowerCategory {get;set;}
    public List<Applicant__C> appCoBorrowerList{get;set;}//SFTRAC-1791


    //Added for Vehicle details dynamically iteration start
    public List<Vehicle_Detail__c> vehicleList{get;set;}
    public List<String> vehicleDetailHedingList{get;set;}
    //Added for Vehicle details dynamically iteration end
    public Applicant__C oppGuarantors{get;set;}//Added for Guarantors Personal Details
    //Added for Co-Borrower Personal Details start
    public Map<Id,CoBorrowerWrapper> coBorrowersWrapperMap{get;set;}
    public List<CoBorrowerWrapper> coBorrowersWrapperList{get;set;}
    //Added for Co-Borrower Personal Details end
    //Added for Mitigant Details start
    public List<Mitigant__c> mitigantList{get;set;}
    public List<String> mitigantHeadingList{get;set;}
    //Added for Mitigant Details end
    public CIBIL_Details__c guarantorCibilRecList{get;set;}//Added for Guarantor CIBIL Details
    public Field_Investigation__c permanentGuarantorFI{get;set;}//Added for Guarantor FI details-Home
    public Field_Investigation__c officeGuarantorFI{get;set;}//Added for Guarantor Business Details
    public Field_Investigation__c residenceGuarantorFI{get;set;}//Added for Guarantor Business Details
    public String districtValue{get;set;}
    public String talukaValue{get;set;}
    public String schemeValue{get;set;}
    
    public Map<Id,String> coborrowerAgeMap{get;set;}
    public String guarantorAge{get;set;}
    public String guarantorGender{get;set;}
    public Map<Id,String> coborrowerGenderMap{get;set;}
    public List<CoBorrowerWrapper> appBenList{get;set;}
    public String productTypeName{get;set;}
    public Decimal minInvDlp{get;set;}
    public Decimal minRsvIdvValuation{get;set;}
    public incomeWrapper tfBorrowerIncome{get;set;}
    public List<incomeWrapper> tfCoGurIncomeList{get;set;}
    public List<incomeWrapper> tfBenIncomeList{get;set;}
    public Decimal dlpLTV{get;set;}
    public Decimal rsvLTV{get;set;}
    public Decimal valuationLTV{get;set;}
    public Decimal idvLTV{get;set;}
    public static Boolean enableEquifaxGtrButton {get;set;}
    public static Boolean isCurrentUserACMSCMLien  {get;set;}
    public List<Final_Term__c> finalTermTF{get;set;}//TF
    public String alertMessage{get;set;}//TF
    public List<loanDetailWrapper> loanDetailList{get;set;}//TF
    public Decimal tfTotalLoanAmount{get;set;}//TF

    public String proposalMCLR{get;set;}
    public List<External_CAM_Data__c> nonIBLExList{get;set;}
    public String totalPayOutAmountPer{get;set;}
    public Decimal borrowerFOIR{get;set;}
    public Decimal coBorrowerFOIR{get;set;}
    public Boolean disableForwarded{get;set;}
    public Boolean sameApprovedUser{get;set;}//SFTRAC-2101
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.16,8.2.18 - Forward To,CAM Screen
* @Purpose: This method is used to provide the options in the Forward dropdown.
***********************************************/ 
    public List<selectOption> getAccNames() {
        try {
            options = new list<SelectOption>(); 
            Schema.DescribeFieldResult fieldResult = Deviation__c.Approval_Status__c.getDescribe();            
            List<Schema.picklistEntry> ple = fieldResult.getPicklistValues();
            for(Schema.picklistEntry f:ple){
                if(f.getValue()=='Rejected'){
                    flag=false;
                }
            }
            if(flag==false){
                options.add(new selectOption('-None-','-None-'));
                for(Schema.picklistEntry f:ple){  
                    options.add(new selectOption(f.getLabel(),f.getValue()));
                }
            }
            return options;
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('ViewCamController', 'getAccNames', e.getTypeName(), e, '');
            return null;
        }  
    }
    
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.16,8.2.18 - Forward To,CAM Screen
* @Purpose: This method is used to provide the options in the Forward dropdown.
***********************************************/
    public List<selectOption> getForwardOptions() {
        try {
            forwardOptions = new list<SelectOption>();
            forwardOptions.add(new selectOption('No','No'));
            forwardOptions.add(new selectOption('Yes','Yes'));
            return forwardOptions;
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('ViewCamController', 'getForwardOptions', e.getTypeName(), e, '');
            return null;
        }
    }
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.16,8.2.18 - Forward To,CAM Screen
* @Purpose: This method is used to provide all the available roles (present in AccountTeam) for forwarding the cam.
***********************************************/
    public List<selectOption> getAvailableForwardedRoles() {
        camRecordId = ApexPages.currentPage().getParameters().get('id');
        try {
            availableForwardedRoles = new list<SelectOption>(); 
            availableForwardedRoles.add(new selectOption('-None-','-None-'));
            Set<String> uniqueRoleList = new Set<String>(); 
            if(camRecordId!=null){
                Boolean userFlag = false;
                recordId = [SELECT Loan_Application__c FROM CAM__c WHERE Id=:camRecordId LIMIT 1].Loan_Application__c;
                if(String.isNotEmpty(recordId)){
                    List<Opportunity> opportunityList = [SELECT AccountId FROM Opportunity WHERE Id =:recordId WITH SECURITY_ENFORCED LIMIT 1];
                    if(opportunityList.size()>0 && opportunityList[0].AccountId!=null){
                        List<AccountTeamMember> accountTeamMemberList = [SELECT TeamMemberRole,UserId FROM AccountTeamMember WHERE AccountId=:opportunityList[0].AccountId WITH SECURITY_ENFORCED LIMIT 10000];
                        if(!accountTeamMemberList.isEmpty()){
                            for (AccountTeamMember accountTeamObj : accountTeamMemberList) {
                                if(accountTeamObj.TeamMemberRole != null && accountTeamObj.TeamMemberRole != System.Label.SystemAdmin){
                                    uniqueRoleList.add(accountTeamObj.TeamMemberRole);
                                }
                            }
                            System.debug('uniqueRoleList-->'+uniqueRoleList);
                            IBL_Configuration__mdt config = IBL_Configuration__mdt.getInstance('default');
                            List<String> rolesToSkip = config.RolesToSkipInForwardTo__c.split(',');
                            System.debug('rolesToSkip-->'+rolesToSkip);
                            for (String roleObj : uniqueRoleList) {
                                System.debug('roleObj-->'+roleObj);
                                if (!rolesToSkip.contains(roleObj)) {
                                    availableForwardedRoles.add(new selectOption(roleObj,roleObj));
                                }
                            }
                        }
                    }
                }
            }
            System.debug('availableForwardedRoles-->'+availableForwardedRoles);
            return availableForwardedRoles;
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('ViewCamController', 'getAvailableForwardedRoles', e.getTypeName(), e, [SELECT Loan_Application__c FROM CAM__c WHERE Id = :camRecordId LIMIT 1].Loan_Application__c);
            return null;
        }
    }
    
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.16,8.2.18 - Forward To,CAM Screen
* @Purpose: This method used to set the value of the forward dropdown, If yes then we are showing the other forward section inputs (same as in CAM & Approval Log).
***********************************************/
    public void setIsForwardTo() {
        //If multiselect is false, countries must be of type String
        try {
            this.isForwardTo = isForwardTo.trim();
            System.debug('this.isForwardTo-->'+this.isForwardTo);
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('ViewCamController', 'setIsForwardTo', e.getTypeName(), e, '');
        }
    }

    /**********************************************
    * @Commented By:  Prashant Kumar Dixit
    * @UserStory:  Feature 8.2.16,8.2.18 - Forward To,CAM Screen
    * @Purpose: This method used to set the value of the forward dropdown, If yes then we are showing the other forward section inputs (same as in CAM & Approval Log).
    ***********************************************/
    public void approveVehileDetails() {
        try {
            String camRecordId = ApexPages.currentPage().getParameters().get('id');
            CAM__c camRecord = [SELECT Loan_Application__c,CAM_Submitted_by_ACM_SCM__c,Submit_for_Approval_UserId__c,Loan_Application__r.AccountId FROM CAM__c WHERE Id = :camRecordId LIMIT 1]; 
            Boolean isCurrentUserACMSCM = false;
            List<AccountTeamMember> accountTeamMember = [SELECT Id, Level__c,TeamMemberRole FROM AccountTeamMember WHERE AccountId =:camRecord.Loan_Application__r.AccountId AND UserId = :UserInfo.getUserId() WITH SECURITY_ENFORCED LIMIT 1];
            if (accountTeamMember.size() > 0) {
                currentUserLevel = accountTeamMember[0].Level__c;
                List<String> camApprovalRoleLabelList = System.Label.camApprovalRoleLabel.split(',');
                for(String role : camApprovalRoleLabelList){
                    if(role == accountTeamMember[0].TeamMemberRole && camRecord.CAM_Submitted_by_ACM_SCM__c == false && camRecord.Submit_for_Approval_UserId__c == UserInfo.getUserId()){
                        isCurrentUserACMSCM = true;
                        break;
                    }
                }
            }
            if(String.isNotEmpty(vehicleId) && isCurrentUserACMSCM == true && camRecord.CAM_Submitted_by_ACM_SCM__c == false){
                Vehicle_Detail__c vehicleDetail = new Vehicle_Detail__c ();
                vehicleDetail.Id = vehicleId;
                vehicleDetail.Approval_Status__c = 'Approved';
                update vehicleDetail;
                alertMessage = 'Vehicle has been approved!';
            }else if(camRecord.CAM_Submitted_by_ACM_SCM__c == true){
                alertMessage = 'Proposal has  been already Approved/Reject by ACM/SCM!';
            }else{
                alertMessage = 'You don\'t have accesss to Approved/Reject this.';
            }
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('ViewCamController', 'approveVehileDetails', e.getTypeName(), e, '');
        }
    }

    public void rejectVehileDetails() {
        try {
            String camRecordId = ApexPages.currentPage().getParameters().get('id');
            CAM__c camRecord = [SELECT Loan_Application__c,CAM_Submitted_by_ACM_SCM__c,Submit_for_Approval_UserId__c,Loan_Application__r.AccountId, Loan_Application__r.Product_Type__c FROM CAM__c WHERE Id = :camRecordId LIMIT 1]; //SFTRAC-1788
            Boolean isCurrentUserACMSCM = false;
            List<AccountTeamMember> accountTeamMember = [SELECT Id, Level__c,TeamMemberRole FROM AccountTeamMember WHERE AccountId =:camRecord.Loan_Application__r.AccountId AND UserId = :UserInfo.getUserId() WITH SECURITY_ENFORCED LIMIT 1];
            if (accountTeamMember.size() > 0) {
                currentUserLevel = accountTeamMember[0].Level__c;
                List<String> camApprovalRoleLabelList = System.Label.camApprovalRoleLabel.split(',');
                for(String role : camApprovalRoleLabelList){
                    if(role == accountTeamMember[0].TeamMemberRole && camRecord.CAM_Submitted_by_ACM_SCM__c == false && camRecord.Submit_for_Approval_UserId__c == UserInfo.getUserId()){
                        isCurrentUserACMSCM = true;
                        break;
                    }
                }
            }
            if(String.isNotEmpty(vehicleId) && ((isCurrentUserACMSCM == true && camRecord.CAM_Submitted_by_ACM_SCM__c == false) || (camRecord.Loan_Application__r.Product_Type__c == System.Label.Tractor && (accountTeamMember[0].TeamMemberRole == 'NCM' || accountTeamMember[0].TeamMemberRole == 'NPH' || accountTeamMember[0].TeamMemberRole == 'ZCM')))){ //SFTRAC-1788
                Vehicle_Detail__c vehicleDetail = new Vehicle_Detail__c ();
                vehicleDetail.Id = vehicleId;
                vehicleDetail.Approval_Status__c = 'Rejected';
                update vehicleDetail;
                alertMessage = 'Vehicle has been rejected!';
            }else if(camRecord.CAM_Submitted_by_ACM_SCM__c == true){
                alertMessage = 'Proposal has  been already Approved/Reject by ACM/SCM!';
            }else{
                alertMessage = 'You don\'t have accesss to Approved/Reject this.';
            }
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('ViewCamController', 'rejectVehileDetails', e.getTypeName(), e, '');
        }
    }

    //SFTRAC-2028 Start
    public PageReference generateVahaanPDFReport() {
        PageReference pageRef = Page.IBLVahaanReport;
        pageRef.getParameters().put('vehicleId', vehicleId);
        return pageRef;
    }
    //SFTRAC-2028 End
    
    public PageReference setForwardToAsNo() {
        //If multiselect is false, countries must be of type String
        try {
            this.isForwardTo = 'No';
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('ViewCamController', 'setForwardToAsNo', e.getTypeName(), e, '');
        }
        return null; 
    }
    public PageReference updateForwardedLogs() {
        if(cam != null){
            ProposalStatusClass.updateForwardedLogs(cam.Id);
        }
        return null; 
    }
    
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.16,8.2.18 - Forward To,CAM Screen
* @Purpose: This method used to set the value of the forward dropdown, If yes then we are showing the other forward section inputs (same as in CAM & Approval Log).
***********************************************/
    public void setForwardTo() {
        //If multiselect is false, countries must be of type String
        try {
            this.forwardTo = forwardTo.trim();
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('ViewCamController', 'setForwardTo', e.getTypeName(), e, '');
        }
    }
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.17,8.2.18 - Deviation Management,CAM Screen
* @Purpose: This is the constructor of the Class which fetches and construct all the required data to map on the CAM Screen (IBLCAMpage).
***********************************************/
    public ViewCamController() {
        String readOnly = ApexPages.currentPage().getParameters().get('readOnly');
        camRecordId = ApexPages.currentPage().getParameters().get('id');
        isNonMandatoryUser= false;
        isLeadSourceOLA=false;
        disableForwarded=true;
        try {
            if(readOnly!=null && Boolean.valueOf(readOnly)){
                disableAll = true;
            }
            isCurrentUserACMSCMLien = true;
            enableEquifaxBorrowerButton = false;
            enableEquifaxCoBorrowerButton = false;    
            //enableEquifaxGtrButton = false;
            currentUserId = UserInfo.getUserId();
            availableForwardedRoles = new List<SelectOption>();
            existingBorrowerExposureAmount = 0;
            bankExposureAmount = 0;
            existingCoBorrowerExposureAmount = 0;
            existingOtherExposureAmount = 0;
            currentExposureAmount = 0;
            tfTotalLoanAmount = 0;
            List<Opportunity> opportunityList = new List<Opportunity>();
            if(camRecordId!=null){
                Boolean userFlag = false;
                recordId = [SELECT Loan_Application__c FROM CAM__c WHERE Id=:camRecordId WITH SECURITY_ENFORCED LIMIT 1].Loan_Application__c;
                if(String.isNotEmpty(recordId)){
                    opportunityList = [SELECT AccountId, LeadSource,Product_Type__c,StageName,Sub_Stage__c,OwnerId FROM Opportunity WHERE Id =:recordId WITH SECURITY_ENFORCED LIMIT 1]; /*CISP-12742 : Added Product Type field in query*/
                    if(opportunityList.size()>0 && opportunityList[0].AccountId!=null){
                        leadSource = opportunityList[0].LeadSource;//OLA-96
                        isLeadSourceOLA = leadSource=='OLA' ? true : false;
                        List<AccountTeamMember> accountTeamMemberList = [SELECT TeamMemberRole,UserId FROM AccountTeamMember WHERE AccountId=:opportunityList[0].AccountId WITH SECURITY_ENFORCED LIMIT 10000];
                        if(!accountTeamMemberList.isEmpty()){
                            for (AccountTeamMember accountTeamObj : accountTeamMemberList) {
                                if(accountTeamObj.UserId!=null && accountTeamObj.UserId==UserInfo.getUserId()){
                                    currentUserRole=accountTeamObj.TeamMemberRole;
                                    userFlag = true;
                                }
                                if(accountTeamObj.TeamMemberRole != null &&accountTeamObj.TeamMemberRole!=System.Label.SystemAdmin){
                                    availableForwardedRoles.add(new selectOption(accountTeamObj.TeamMemberRole,accountTeamObj.TeamMemberRole));
                                }
                            }
                        }
                        System.debug('availableForwardedRoles-1->'+availableForwardedRoles);
                        family_Exposure = false;
                        // if(userFlag==false){ //Start CISP-2442
                        //     List<Profile> profileList = [SELECT Name FROM Profile WHERE Id=:UserInfo.getProfileId() LIMIT 1];
                        //     currentUserRole = profileList[0].Name;
                        // }//End CISP-2442
                        // 
                        /*CISP-12742: Display NetIRR to predefined roles - START*/
                        
                        If((opportunityList[0].LeadSource == 'D2C' && opportunityList[0].Product_Type__c=='Passenger Vehicles') || opportunityList[0].Product_Type__c=='Tractor'){
                            isNetIRREditable = false;
                            isLoanAmountEditable = false; // Added for CISP-14432
                            isCRMIRREditableTF = false;
                            isLoanAmountEditableTF = false;
                            if(currentUserRole != null){
                                String permittedRolesLabel = System.Label.Permitted_Roles_for_NetIRR_field;
                                if(permittedRolesLabel != null){
                                    String[] permittedRolesList = permittedRolesLabel.split(',');
                                    for(string permittedRole : permittedRolesList){
                                        if(currentUserRole == permittedRole){
                                            isNetIRREditable = true;
                                        }
                                    }
                                    
                                }
                                 /*Block to set Loan Amount field visibility : CISP-14432 Start */
                                String permittedRolesForLoanAmountLabel = System.Label.Permitted_Roles_For_Loan_Amount_Field;
                                if(permittedRolesForLoanAmountLabel != null){
                                    String[] permittedRolesForLoanAmtList = permittedRolesForLoanAmountLabel.split(',');
                                    for(string permittedRole : permittedRolesForLoanAmtList){
                                        if(currentUserRole == permittedRole){
                                            isLoanAmountEditable = true;
                                        }
                                    }
                                }
                                /*Block to set Loan Amount field visibility : CISP-14432 End */
                                // if(opportunityList.size() > 0 && opportunityList[0].Product_Type__c=='Tractor' && opportunityList[0].StageName == 'Credit Processing' && opportunityList[0].Sub_Stage__c == 'CAM and Approval Log'){
                                //     String permittedRolesForLoanAmountCRMIRRLabel = System.Label.Permitted_Roles_for_LoanAmount_CRMIRR_field;
                                //     if(permittedRolesForLoanAmountCRMIRRLabel != null){
                                //         String[] permittedRolesList = permittedRolesForLoanAmountCRMIRRLabel.split(',');
                                //         for(string permittedRole : permittedRolesList){
                                //             if(currentUserRole == permittedRole){
                                //                 isCRMIRREditableTF = true;
                                //                 isLoanAmountEditableTF = true;
                                //             }
                                //         }
                                //     }
                                // }
                            }
                        }
                        /*CISP-12742: Display NetIRR to predefined roles - END*/
                        if(opportunityList.size() > 0 && opportunityList[0].Product_Type__c=='Two Wheeler' && (opportunityList[0].LeadSource == null || opportunityList[0].LeadSource == '')){
                            isImmputedIRREditable = false;
                            String permittedRolesForImputedIRRLabel = System.Label.Permitted_Roles_for_Imputed_IRR_field;
                            if(permittedRolesForImputedIRRLabel != null){
                               String[] permittedRolesList = permittedRolesForImputedIRRLabel.split(',');
                               for(string permittedRole : permittedRolesList){
                                isImmputedIRREditable = true;
                               }
                            }
                       }
                    }
                }
                // loanDetailList = new List<loanDetailWrapper>();
                // Loan Application
                disableAll=false;
                disableRadioButton=false; 
                //Updated for PSL Classification
                List<Opportunity> oppLoanList = new List<Opportunity>();
                oppLoanList = [SELECT Id,Name,CreatedBy.Name,StageName,Applicant_Name__c,Number_of_Products__c,Hunter_Match_Status__c,Hunter_APS_Response__c,Parent_Loan_Application__c,Parent_Loan_Application__r.Parent_Loan_Application__c,Bank_Branch_Detail__c,Employee_Branch__c,Customer_Code__c,Vehicle_Type__c,Agent_BL_code__c,OwnerId,Owner.Name,Funding_on_ORP__c,IBL_State__c,Product_Type__c,Loan_Application_Number__c,Parent_Deal_number__c,Required_Tenure__c,Net_LTV__c,Gross_LTV__c,NOC_Number__c,Invoice__c,LTV__c,Vehicle_Sub_Category__c,Funding_on_Ex_Showroom__c,CRM_IRR__c,Documentation_Charges__c,LeadSource,Dealer_Expence_Reimburse_Amt__c,Service_Charges__c,DSM_Incentive1__c,Gift_through_Dealer_Amount__c,Mfr_Incentive__c,Repayment_mode__c,Basic_Price__c,RTO_Road_Tax__c,RTO_Road_Tax_New__c,X1st_yr_Insurance_Premium__c,Finance_Amount__c,Advance_EMI__c,Other_charges__c,GST_Amount__c,Gross_Invoice_Amount__c,Loan_amount__c,Discount_on_Basic_Price__c,EMI_Amount__c,Total_Funded_Premium__c,Gross_IRR__c,Net_IRR__c,Verification_charges__c,Account.BranchBLCode__c,Journey_Status__c,Is_Revoked__c,On_Road_price__c,Ex_showroom_price__c,Customer_Type__c, Loan_Categorization__c, Non_PSL_Categorization__c, PSL_Sub_Type__c, Borrower_Category__c, Acre_Category__c,Submitted_Tabs__c,Application_Type__c,isTopUpLoan__c,Minor_Industry__c,Major_Industry__c,Recommendation_for_the_Loan__c,Entity_Type__c FROM Opportunity WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1];// CISP-2445//CISP-2384-- Added Is_Revoked__c //CISP-2522
                opploan = oppLoanList.size() > 0 ? oppLoanList[0] : new Opportunity();
                onRoadPrice = opploan.On_Road_price__c!=null? opploan.On_Road_price__c:0;// CISP-2459
                productType = opploan.Product_Type__c!=null? opploan.Product_Type__c:'';//Start CISP-2522
                oppVehicleType = opploan.Vehicle_Type__c!=null? opploan.Vehicle_Type__c:'';
                totalFundedPremium = opploan.Total_Funded_Premium__c!=null? opploan.Total_Funded_Premium__c:0;
                exShowroomPrice = opploan.Ex_showroom_price__c!=null? opploan.Ex_showroom_price__c:0;//End CISP-2522
                productTypeName = opploan.Product_Type__c=='Two Wheeler' || opploan.Product_Type__c=='Passenger Vehicles' || (opploan.Product_Type__c =='Tractor' && opploan.Customer_Type__c=='Individual') ? opploan.Product_Type__c : (opploan.Product_Type__c =='Tractor' && opploan.Customer_Type__c=='Non-Individual') ? opploan.Customer_Type__c + ' '+ opploan.Product_Type__c+' Loan' :'';
                if(opploan.Vehicle_Type__c!=null && opploan.Product_Type__c!=null){
                    String productTypeValue = opploan.Product_Type__c=='Passenger Vehicles' ? 'C' : opploan.Product_Type__c=='Two Wheeler' ? 'H' : opploan.Product_Type__c=='Tractor' ? 'T' : '';
                    if(opploan.Vehicle_Type__c=='New'){
                        vehicleType = productTypeValue + ' / N (New)';
                    }
                    else if(opploan.Vehicle_Type__c=='Used'){
                        vehicleType = productTypeValue + ' / U (Used)';
                    }
                    else if(opploan.Vehicle_Type__c=='Refinance'){
                        vehicleType = productTypeValue + ' / R (Refinance)';
                    }
                }
                
                if(opploan!=null && opploan.Funding_on_ORP__c){
                    fundingOn = 'ORP';
                }
                if(opploan!=null && opploan.Funding_on_Ex_Showroom__c){
                    fundingOn = 'Ex Showroom';
                }
                List<BankBranchDetails__c> branchDetailsList = new List<BankBranchDetails__c>();
                branchDetailsList = [SELECT Id,Geo_State_Master__c, Geo_State_Master__r.Name,Name,Bl_Code__c FROM BankBranchDetails__c WHERE Bl_Code__c =: opploan.Account.BranchBLCode__c WITH SECURITY_ENFORCED LIMIT 1];
                if(branchDetailsList.size()>0){
                    branchStateName = branchDetailsList[0].Name;
                    branchStateName += branchDetailsList[0].Geo_State_Master__c != null ? +' / ' + branchDetailsList[0].Geo_State_Master__r.Name : '';
                }
                
                // Vehicle Detail
                List<Vehicle_Detail__c> vehList = new List<Vehicle_Detail__c>();
                vehList = [SELECT id,Product_Segment__c,Loan_Amount__c,Purpose_of_purchase__c,Make__c,Model__c,Lead_Source__c,Variant__c,Variant_Code__c,RC_retention_applicable__c,Ben_Code__c,OEM_Dealer__c,Can_we_continue_with_above_RC_limit__c,Dealer_Sub_dealer_name__c,Vehicle_Registration_number__c,Vehicle_Category__c,Base_Prices__c,Product__c,Selling_Price__c,Insurance_declared_value__c,Valuation_price__c,Grid_value__c,Valuer_category__c,Valuer__c,Manufacturer_Year_Month__c,Approval_Status__c,RC_limit_enabled_Dealer__c,Total_Funded_Amount__c,GST_Amount__c,X1st_yr_Insurance_Premium__c,Basic_Price__c,Invoice_Price__c, MFC_valuation_Report_URL__c,Parent_Deal_Number__c, Vehicle_SubCategory__c, NOC_Number__c,(SELECT Id,Case__r.Asset_Verification__c FROM RelatedAsset_Verifications__r WHERE Type_of_AV__c != 'PDAV' LIMIT 1)   FROM Vehicle_Detail__c WHERE Loan_Application__c = :recordId ORDER BY CreatedDate ASC LIMIT 10000];//updated for Vehicle details dynamically iteration start
                veh = vehList.size() > 0 ? vehList[0] : new Vehicle_Detail__c();

                yearOfManufacture = vehList.size() > 0 && vehList[0].Manufacturer_Year_Month__c!=null ? vehList[0].Manufacturer_Year_Month__c.substringBefore('-') : '';
                //Added for Vehicle details dynamically start
                vehicleList = new List<Vehicle_Detail__c>(vehList);
                Map<Id, Vehicle_Detail__c> vehicleIdVsVehicleMap = new Map<Id, Vehicle_Detail__c>(vehList);
                vehicleDetailHedingList = new List<String>();
                Decimal totalLoanAmountWithInsuranceVal = 0;
                for(Integer i=0; i < vehicleList.size(); i++){
                   Integer j = i+1;
                   vehicleDetailHedingList.add('Vehicle Detail '+j);
                   System.debug('vehicleList[i].Insurance_declared_value__c - '+vehicleList[i].Insurance_declared_value__c);
                   totalLoanAmountWithInsuranceVal += vehicleList[i].Insurance_declared_value__c == null ? 0 : vehicleList[i].Insurance_declared_value__c;
                   System.debug('totalLoanAmountWithInsuranceVal - '+totalLoanAmountWithInsuranceVal);
                }
                //Added for Vehicle details dynamically end
                
                productSegment = vehList.size() > 0 && vehList[0].Product_Segment__c!=null ? vehList[0].Product_Segment__c: '';
                //Product Detail
                List<product2> productList = new List<product2>();
                productList = [SELECT Id, name, Asset_Category__c FROM product2 WHERE Name =: veh.Model__c WITH SECURITY_ENFORCED LIMIT 1];
                prod = productList.size() > 0 ? productList[0] : new product2();
                
                // Final Terms
                List<Final_Term__c> finaltermsList = new List<Final_Term__c>();
                finaltermsList = [select id,Net_Income__c,No_of_Installment__c,OfferengineMinLoanAmount__c,DSM_Incentive2__c,DSM_Incentive1__c,Rreferrer_Incentive__c,Mfr_incentive__c,Gift_through_Dealer_Amount__c,Mfr_Exp_Reimburse_Amt__c,Dlr_Exp_Reimburse_Amt__c,Service_charges__c,Dealer_incentive_amount_main_dealer__c,Trade_certificate__c,Advance_EMI__c,OfferengineMaxLoanAmount__c,Required_CRM_IRR__c,EMI_Amount__c,OfferengineMinTenure__c,OfferengineMaxTenure__c,Tenure__c,PricingEngine_thresholdNetrr__c,LtvEngine_Ltv__c,FIwaiver_co_currentAddress__c, FIwaiver_co_offAddress__c, FIwaiver_co_presentAddress__c,Documentation_charges__c, FIwaiver_currentAddress__c, FIwaiver_offAddress__c,Holiday_period__c, FIwaiver_presentAddress__c,Provisional_Channel_Cost__c,Dealer_incentive_amount_sub_dealer__c,Gross_IRR__c,CRM_IRR__c,Net_IRR__c,Repayment_mode__c,Inputted_IRR__c,Calculated_Net_LTV__c,Calculated_Gross_LTV__c,Is_Loan_Amount_Change_From_CAM__c,Referrer_Name__c,Is_Change_Pay_In_Pay_Out_Submit_Required__c,Refered_By__c,Schemes__c,Approving_Authority_Loan_Amount__c,Schemes__r.Name,Fi_Score_Band__c, Vehicle_Detail__c,Name,Installment_Type__c ,CashFlowPerAnnum__c,Installment_To_Income_Ratio__c,Installment_Frequency__c,Vehicle_Detail__r.MFC_valuation_Report_URL__c,Vehicle_Detail__r.Valuer_category__c,Loan_amount__c,Vehicle_Detail__r.Grid_value__c,Vehicle_Detail__r.Valuation_price__c,Vehicle_Detail__r.Insurance_declared_value__c, Vehicle_Detail__r.Invoice_Price__c, Vehicle_Detail__r.Selling_Price__c,Vehicle_Detail__r.Total_Funded_Amount__c,Loan_Application__r.Vehicle_Type__c,Loan_Application__r.isTopUpLoan__c,Vehicle_Detail__r.Variant_Code__c FROM Final_Term__c WHERE Loan_Application__c = :recordId WITH SECURITY_ENFORCED];// CISP-2491 CISP-2507 CISP-2522
                finalterms = finaltermsList.size() > 0 ? finaltermsList[0] : new Final_Term__c();
                finalTermTF = finaltermsList.size() > 0 ? finaltermsList : new List<Final_Term__c>();//TF
                if (finalterms !=null && finalterms.Schemes__c != null) {
                    List<Schemes__c> schemeList = [SELECT Id,Name,Scheme_Code__c FROM Schemes__c WHERE Id =: finalterms.Schemes__c];
                    if(!schemeList.isEmpty()){
                        schemeName = schemeList[0].Name;
                        schemeCode = schemeList[0].Scheme_Code__c !=null ? schemeList[0].Scheme_Code__c : '';
                    }
                }
                totalPayInAmount = 0;
                totalPayOutAmount = 0;
                totalDealerPayout = 0;
                schemeValue = '';
                totalPayOutAmountPer ='';
                if(finalterms!=null){
                    schemeValue = finalterms.Schemes__r.Name;
                    if(finalterms.Holiday_period__c != null && finalterms.Tenure__c != null){
                        if(!oppLoanList.isEmpty() && oppLoanList[0].Product_Type__c==Label.Tractor){
                            numberOfInstalments=Integer.valueOf(finalterms.No_of_Installment__c);
                        }else if(Integer.valueOf(finalterms.Holiday_period__c) == 0 || leadSource=='OLA'){
                            numberOfInstalments = Integer.valueOf(finalterms.Tenure__c);
                        } else if(Integer.valueOf(finalterms.Holiday_period__c) == 30){
                            numberOfInstalments = Integer.valueOf(finalterms.Tenure__c) -1;
                        }
                    }
                    totalPayInAmount += finalterms.Service_Charges__c != null ? Decimal.valueOf(finalterms.Service_Charges__c) : 0;
                    totalPayInAmount += finalterms.Documentation_Charges__c != null ? Decimal.valueOf(finalterms.Documentation_Charges__c) : 0;
                    totalPayInAmount += finalterms.Dlr_Exp_Reimburse_Amt__c != null ? Decimal.valueOf(finalterms.Dlr_Exp_Reimburse_Amt__c) : 0;
                    totalPayInAmount += finalterms.Mfr_Exp_Reimburse_Amt__c != null ? Decimal.valueOf(finalterms.Mfr_Exp_Reimburse_Amt__c) : 0;
                    totalPayOutAmount += finalterms.Gift_through_Dealer_Amount__c != null ? Decimal.valueOf(finalterms.Gift_through_Dealer_Amount__c) : 0;
                    totalPayOutAmount += finalterms.Mfr_Incentive__c != null ? Decimal.valueOf(finalterms.Mfr_Incentive__c) : 0;
                    totalPayOutAmount += finalterms.DSM_Incentive1__c != null ? Decimal.valueOf(finalterms.DSM_Incentive1__c) : 0;
                    totalPayOutAmount += finalterms.DSM_Incentive2__c != null ? Decimal.valueOf(finalterms.DSM_Incentive2__c) : 0;
                    totalPayOutAmount += finalterms.Dealer_incentive_amount_main_dealer__c != null ? Decimal.valueOf(finalterms.Dealer_incentive_amount_main_dealer__c) : 0; 
                    if(opploan.Product_Type__c == 'Two Wheeler'){
                        totalPayOutAmount += finalterms.Provisional_Channel_Cost__c != null ? Decimal.valueOf(finalterms.Provisional_Channel_Cost__c) : 0;
                        totalPayOutAmount += finalterms.Dealer_incentive_amount_sub_dealer__c != null ? Decimal.valueOf(finalterms.Dealer_incentive_amount_sub_dealer__c) : 0;
                        requiredNetIRR = finalterms.Inputted_IRR__c!=null ?finalterms.Inputted_IRR__c:null;
                    }
                    if(opploan.Product_Type__c == 'Passenger Vehicles'){
                        totalPayOutAmount += finalterms.Rreferrer_Incentive__c != null ? Decimal.valueOf(finalterms.Rreferrer_Incentive__c) : 0;
                        requiredNetIRR = finalterms.Net_IRR__c!=null ?finalterms.Net_IRR__c:null;
                    }
                    if(totalPayOutAmount!=null && finalterms.Loan_Amount__c != null){
                        totalPayOutAmountPer = String.valueOf(((totalPayOutAmount / (Decimal.valueOf(finalterms.Loan_Amount__c)+ totalFundedPremium)) * 100).setScale(2));
                    }
                    currentExposureAmount += finalterms.Loan_Amount__c != null ? Decimal.valueOf(finalterms.Loan_Amount__c) : 0;
                    System.debug('totalLoanAmountWithInsuranceVal 2- '+totalLoanAmountWithInsuranceVal);
                    System.debug('finalterms.Loan_Amount__c -'+finalterms.Loan_Amount__c);
                    System.debug(finalterms.Loan_Amount__c != null ? Decimal.valueOf(finalterms.Loan_Amount__c) : 0);
                    totalLoanAmountWithInsurance = String.valueOf(totalLoanAmountWithInsuranceVal + (finalterms.Loan_Amount__c != null ? Decimal.valueOf(finalterms.Loan_Amount__c) : 0));
                    System.debug('totalLoanAmountWithInsurance - '+totalLoanAmountWithInsurance);
                    System.debug('totalLoanAmountWithInsuranceVal 3- '+totalLoanAmountWithInsuranceVal);

                    List<MCLR_Master__c > proposalMCLRList = new List<MCLR_Master__c >();
                    Decimal tenure = Decimal.valueOf(finalterms.Tenure__c);
                    proposalMCLRList = [Select MCLR__c from MCLR_Master__c where Rate_Type__c = 'MCLR' AND Nature__c = 'FXD' AND Flag__c = 'L' AND Eff_from_date__c  <= TODAY And Period__c >= : tenure Order by Period__c ASC LIMIT 1];
                    proposalMCLR = proposalMCLRList.size() > 0 && proposalMCLRList[0].MCLR__c != null ? String.valueOf(proposalMCLRList[0].MCLR__c) : '';
                }
                
                vehicleSubCategory = '';
                if(oppLoanList!=null){
                    if (oppLoanList[0].Vehicle_Sub_Category__c!=null) {
                        List<Vehicle_Sub_Category_Mapping__mdt> subCategoryList = [SELECT Id, Label, DeveloperName,Sub_Category_Name__c from Vehicle_Sub_Category_Mapping__mdt WHERE DeveloperName =:oppLoanList[0].Vehicle_Sub_Category__c WITH SECURITY_ENFORCED];
                        if (subCategoryList.size() > 0) {
                            vehicleSubCategory = subCategoryList[0].Sub_Category_Name__c;
                        }
                    }
                    Decimal basePrice = veh.Base_Prices__c!=null?veh.Base_Prices__c:0;
                    Decimal basicPrice = oppLoanList[0].Basic_Price__c!=null?oppLoanList[0].Basic_Price__c:0;
                    Decimal roadTax = 0;
                    if(oppLoanList[0].Product_Type__c == 'Two Wheeler' && oppLoanList[0].Vehicle_Type__c=='New'){
                        roadTax = oppLoanList[0].RTO_Road_Tax_New__c!=null?oppLoanList[0].RTO_Road_Tax_New__c:0;
                    }
                    else{
                        if(oppLoanList[0].Product_Type__c == 'Passenger Vehicles'){
                         // List<Retry_Count__c> retryCounList = new List<Retry_Count__c>([Select Id from Retry_Count__c WHERE Loan_Application_Id__c =: recordId AND Service_Name__c = 'CarwaleApi' AND Count__c >= 3 AND IsAPIFailed__c = true]);
                          // if(retryCounList.size() > 0){
                                roadTax = oppLoanList[0].RTO_Road_Tax_New__c!=null?oppLoanList[0].RTO_Road_Tax_New__c:0;
                           // }else{
                            //    roadTax = oppLoanList[0].RTO_Road_Tax__c!=null?oppLoanList[0].RTO_Road_Tax__c:0;
                          // }
                      // }else{
                        //  roadTax = oppLoanList[0].RTO_Road_Tax__c!=null?oppLoanList[0].RTO_Road_Tax__c:0;
                        }
                    }
                    roadTaxValue = roadTax;
                    Decimal istInsurancePremium = oppLoanList[0].X1st_yr_Insurance_Premium__c!=null?oppLoanList[0].X1st_yr_Insurance_Premium__c:0;
                    Decimal otherCharges = oppLoanList[0].Other_charges__c!=null?oppLoanList[0].Other_charges__c:0;
                    Decimal gstAmount = oppLoanList[0].GST_Amount__c!=null?oppLoanList[0].GST_Amount__c:0;
                    Decimal discount = oppLoanList[0].Discount_on_Basic_Price__c!=null?oppLoanList[0].Discount_on_Basic_Price__c:0;
                    Decimal totalFundedInsurancePremium = oppLoanList[0].Total_Funded_Premium__c!=null?oppLoanList[0].Total_Funded_Premium__c:0;
                    Decimal finalLoanAmount = finalterms.Loan_Amount__c!=null?Decimal.valueOf(finalterms.Loan_Amount__c)+totalFundedInsurancePremium:totalFundedInsurancePremium;
                    loanAmount = finalLoanAmount;
                    originalloanAmount = finalLoanAmount;
                    originalIRR = requiredNetIRR;
                    if(oppLoanList[0].Advance_EMI__c==true){
                        advanceEmiAmount = finaltermsList[0].EMI_Amount__c;
                    }
                    if(oppLoanList[0].Vehicle_Type__c == 'New' && oppLoanList[0].Product_Type__c == 'Passenger Vehicles'){
                        grossInvoiceAmount = String.valueOf((basicPrice+roadTax+istInsurancePremium+otherCharges+gstAmount).setScale(2));
                        vehicleBasicPrice = basicPrice!=null ? String.valueOf(basicPrice) : '';
                        if(oppLoanList[0].Funding_on_Ex_Showroom__c==true){
                            LTVInvoiceAmount = String.valueOf(((basicPrice - discount) + gstAmount).setScale(2));
                        }
                        if(oppLoanList[0].Funding_on_ORP__c==true){
                            LTVInvoiceAmount = String.valueOf((basicPrice+roadTax+istInsurancePremium+otherCharges+gstAmount-discount).setScale(2));
                        }
                        
                        invoiceAmount = String.valueOf((basicPrice+roadTax+istInsurancePremium+otherCharges+gstAmount-discount).setScale(2));
                        if(finalLoanAmount!=null && LTVInvoiceAmount!=null && decimal.valueof(LTVInvoiceAmount)!=0){
                            grossLTV = (finalterms.Calculated_Gross_LTV__c == null || finalterms.Is_Loan_Amount_Change_From_CAM__c) ? ((finalLoanAmount/decimal.valueof(LTVInvoiceAmount))*100).setScale(2) : finalterms.Calculated_Gross_LTV__c;// CISP-2491
                        }
                        if(finalterms.EMI_Amount__c!=null && finalLoanAmount!=null && LTVInvoiceAmount!=null && decimal.valueof(LTVInvoiceAmount)!=0){
                            netLTV = (finalterms.Calculated_Net_LTV__c == null || finalterms.Is_Loan_Amount_Change_From_CAM__c) ? ((((finalLoanAmount-(finalterms.EMI_Amount__c*(finalterms.Advance_EMI__c==true?1:0)))/decimal.valueof(LTVInvoiceAmount))*100).setScale(2)) : finalterms.Calculated_Net_LTV__c;// CISP-2491
                        }
                    }
                    else if((oppLoanList[0].Vehicle_Type__c=='Used' || oppLoanList[0].Vehicle_Type__c=='Refinance') && oppLoanList[0].Product_Type__c == 'Passenger Vehicles'){
                        vehicleBasicPrice = basePrice!=null ? String.valueOf(basePrice) : '';
                        if(finalLoanAmount!=null && basePrice!=null && basePrice!=0){
                            grossLTV = (finalterms.Calculated_Gross_LTV__c == null || finalterms.Is_Loan_Amount_Change_From_CAM__c) ? ((finalLoanAmount/basePrice)*100).setScale(2) : finalterms.Calculated_Gross_LTV__c;// CISP-2491
                        }
                        if(finalterms.EMI_Amount__c!=null && finalLoanAmount!=null && basePrice!=null && basePrice!=0){
                            netLTV = (finalterms.Calculated_Net_LTV__c == null || finalterms.Is_Loan_Amount_Change_From_CAM__c) ? ((((finalLoanAmount-(finalterms.EMI_Amount__c*(finalterms.Advance_EMI__c==true?1:0)))/basePrice))*100).setScale(2) : finalterms.Calculated_Net_LTV__c;// CISP-2491
                        }
                        grossInvoiceAmount = 'NA';
                        LTVInvoiceAmount = 'NA';
                        invoiceAmount = 'NA'; 
                    }
                    else if(oppLoanList[0].Vehicle_Type__c=='New' && oppLoanList[0].Product_Type__c == 'Two Wheeler'){
                        grossInvoiceAmount = String.valueOf((basicPrice+roadTax+istInsurancePremium+otherCharges+gstAmount).setScale(2));
                        vehicleBasicPrice = basicPrice!=null ? String.valueOf(basicPrice) : '';
                        if(oppLoanList[0].Funding_on_Ex_Showroom__c==true){
                            LTVInvoiceAmount = String.valueOf(((basicPrice - discount) + gstAmount).setScale(2));
                        }
                        if(oppLoanList[0].Funding_on_ORP__c==true){
                            LTVInvoiceAmount = String.valueOf((basicPrice+roadTax+istInsurancePremium+otherCharges+gstAmount-discount).setScale(2));
                        }
                        if (LTVInvoiceAmount!=null) {
                            invoiceAmount = String.valueOf((Decimal.valueOf(LTVInvoiceAmount) + totalFundedInsurancePremium).setScale(2));
                        } else {
                            invoiceAmount = null;
                        }
                        if(finalLoanAmount!=null && invoiceAmount!=null && decimal.valueof(invoiceAmount)!=0){
                            grossLTV = finalterms.Calculated_Gross_LTV__c == null ? ((finalLoanAmount/decimal.valueof(invoiceAmount))*100).setScale(2) :finalterms.Calculated_Gross_LTV__c;// CISP-2491
                        }
                        if(finalterms.EMI_Amount__c!=null && finalLoanAmount!=null && invoiceAmount!=null && finalterms.Advance_EMI__c!=null && decimal.valueof(invoiceAmount)!=0){
                            netLTV = finalterms.Calculated_Net_LTV__c == null ? ((((finalLoanAmount-(finalterms.EMI_Amount__c*(finalterms.Advance_EMI__c==true?1:0)))/decimal.valueof(invoiceAmount)))*100).setScale(2) : finalterms.Calculated_Net_LTV__c;// CISP-2491
                        } 
                    }
                    else if((oppLoanList[0].Vehicle_Type__c=='Used' || oppLoanList[0].Vehicle_Type__c=='Refinance') && oppLoanList[0].Product_Type__c == 'Two Wheeler'){
                        vehicleBasicPrice = basePrice!=null ? String.valueOf(basePrice) : '';
                        if(finalLoanAmount!=null && basePrice!=null && basePrice!=0){
                            grossLTV = finalterms.Calculated_Gross_LTV__c == null ? ((finalLoanAmount/basePrice)*100).setScale(2) : finalterms.Calculated_Gross_LTV__c;// CISP-2491
                        }
                        if(finalterms.EMI_Amount__c!=null && finalLoanAmount!=null && basePrice!=null && finalterms.Advance_EMI__c!=null && basePrice!=0){
                            netLTV = finalterms.Calculated_Net_LTV__c == null ? ((((finalLoanAmount-(finalterms.EMI_Amount__c*(finalterms.Advance_EMI__c==true?1:0)))/basePrice))*100).setScale(2) : finalterms.Calculated_Net_LTV__c;// CISP-2491
                        }
                        grossInvoiceAmount = 'NA';
                        LTVInvoiceAmount = 'NA';
                        invoiceAmount = 'NA'; 
                    }
                }
                if (oppLoan.Product_Type__c == System.Label.Tractor) {
                    loanDetailList = ViewCamController.getloanDetailWrapperDetails(oppLoan,vehicleIdVsVehicleMap,finaltermsList);
                    if(!loanDetailList.isEmpty()){
                        for (loanDetailWrapper loanDetailObj : loanDetailList) {
                            tfTotalLoanAmount += Decimal.valueOf(loanDetailObj.loanAmountWithInsurance);
                        }
                    }
                }
                if(oppLoan.Product_Type__c == 'Two Wheeler'){
                String roiMasterData = IND_OfferScreenController.roiMasterForImputedIRR(String.valueOf(oppLoan.Id), oppLoan.Product_Type__c, Integer.valueOf(finalterms.Tenure__c), oppLoan.Vehicle_Type__c);//Start CISP-2702
                    if (roiMasterData!=null) {
                    IND_OfferScreenController.LoadOfferScreenDataWrapper roiObj = new IND_OfferScreenController.LoadOfferScreenDataWrapper();
                    roiObj = (IND_OfferScreenController.LoadOfferScreenDataWrapper)JSON.deserialize(roiMasterData, IND_OfferScreenController.LoadOfferScreenDataWrapper.class);
                    minCRM = String.valueOf(roiObj.mincrm);
                    maxCRM = String.valueOf(roiObj.maxcrm);
                }}//End CISP-2702
                else if(oppLoan.Product_Type__c != System.Label.Tractor){//CISP-10059 start
                    if(finalterms.Tenure__c != null){
                    String roiMasterDataForCRMIrr = IND_OfferScreenController.roiMasterForImputedIRR(String.valueOf(oppLoan.Id), oppLoan.Product_Type__c, Integer.valueOf(finalterms.Tenure__c), oppLoan.Vehicle_Type__c,'CRM_IRR');//Start CISP-2702
                    if (roiMasterDataForCRMIrr!=null) {
                        IND_OfferScreenController.LoadOfferScreenDataWrapper roiObj = new IND_OfferScreenController.LoadOfferScreenDataWrapper();
                        roiObj = (IND_OfferScreenController.LoadOfferScreenDataWrapper)JSON.deserialize(roiMasterDataForCRMIrr, IND_OfferScreenController.LoadOfferScreenDataWrapper.class);
                        minCRM = String.valueOf(roiObj.mincrm);
                        maxCRM = String.valueOf(roiObj.maxcrm);
                    }
                    String roiMasterDataForNETIrr = IND_OfferScreenController.roiMasterForImputedIRR(String.valueOf(oppLoan.Id), oppLoan.Product_Type__c, Integer.valueOf(finalterms.Tenure__c), oppLoan.Vehicle_Type__c,'NET_IRR');//Start CISP-2702
                    if (roiMasterDataForNETIrr!=null) {
                        IND_OfferScreenController.LoadOfferScreenDataWrapper roiObj = new IND_OfferScreenController.LoadOfferScreenDataWrapper();
                        roiObj = (IND_OfferScreenController.LoadOfferScreenDataWrapper)JSON.deserialize(roiMasterDataForNETIrr, IND_OfferScreenController.LoadOfferScreenDataWrapper.class);
                        minNetIrr = String.valueOf(roiObj.mincrm);
                        maxNetIrr = String.valueOf(roiObj.maxcrm);
                    }
                }}//CISP-10059 END
                else if(oppLoan.Product_Type__c == System.Label.Tractor) {
                    String vehicleCode;
                    if(oppLoan.Vehicle_Type__c == 'New'){
                        vehicleCode = 'N';
                    }
                    if(oppLoan.Vehicle_Type__c == 'Used'){
                        vehicleCode = 'U';
                    }
                    if(oppLoan.Vehicle_Type__c == 'Refinance'){
                        vehicleCode = 'R';
                    }
                    List<ROI_Master__c> roiMaster = new List<ROI_Master__c>();
                    roiMaster = [Select Id, Description__c, Max_Value__c, Min_Value__c from ROI_Master__c where Product__r.ProductCode = 'T' AND Vehicle_Category__c =: vehicleCode AND Description__c = 'CRM_IRR' WITH SECURITY_ENFORCED LIMIT 1];
                    if(!roiMaster.isEmpty()) {
                        minCRM = String.valueOf(roiMaster[0].Min_Value__c);
                        maxCRM = String.valueOf(roiMaster[0].Max_Value__c);
                    }
                }
                // Applicant
                //Added for Guarantors Personal Details start
                List<Applicant__c> oppGuarantorsList = new List<Applicant__c>();
                oppGuarantorsList = [select ID,Email_Id__c,Remarks__c, Start_Date__c,Cheque_Return_Count__c,Relationship_Since__c,Scorecard_Decision__c, Total_Insurance_Payable__c, Employee_Name__c,Name,Gender__c, Marital_status__c,Income_Ca__c,Relationship_with_borrower__c,Customer_Code__c,Entity__c,Employer_Name__c,Applicant_Type__c,Do_you_have_a_bank_account_with_IBL__c,Willing_to_open_Bank_Account_with_IIB__c,Would_you_like_to_open_a_bank_account__c,Contact_number__c,Are_you_registered_with_any_of_the_follo__c,Salaried_Self_employed__c,Profile__c,(Select Id, Income_Detail_Bank_Master__r.Name from Income_Details__r where Applicant__r.Opportunity__r.Product_Type__c = 'Tractor' AND Income_Source_for_Tractor__c = 'Banking' LIMIT 1) from Applicant__c where Opportunity__c = :recordId AND Applicant_Type__c ='Guarantor' AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED LIMIT 1];
                oppGuarantors = oppGuarantorsList.size() > 0 ? oppGuarantorsList[0] : new Applicant__c();
                System.debug('oppGuarantorsList - '+oppGuarantorsList);
                //Added for Guarantors Personal Details end
                
                List<Applicant__c> appBorrowerList = new List<Applicant__c>();
                appBorrowerList = [select ID,FOIR__c,Customer_Category__c,Email_Id__c,Remarks__c, Start_Date__c,Cheque_Return_Count__c,Relationship_Since__c,Scorecard_Decision__c, Total_Insurance_Payable__c, Employee_Name__c,Name,Gender__c, Marital_status__c,Income_Ca__c,Relationship_with_borrower__c,Customer_Code__c,Entity__c,Employer_Name__c,Applicant_Type__c,Do_you_have_a_bank_account_with_IBL__c,Willing_to_open_Bank_Account_with_IIB__c,Would_you_like_to_open_a_bank_account__c,Contact_number__c,Are_you_registered_with_any_of_the_follo__c,Is_Borrower_Relative_Of_Director__c, Is_Borrower_Relative_Of_Senior_Officer__c, Borrower_Relation_With_IndusInd_Q1__c,Borrower_Relation_With_IndusInd_Q2__c,Borrower_Relation_With_Other_Bank_Q1__c,Borrower_Relation_With_Other_Bank_Q2__c,Relationship_With_IndusInd_Or_Other_Bank__c,Profile__c,(Select Id, Income_Detail_Bank_Master__r.Name from Income_Details__r where Applicant__r.Opportunity__r.Product_Type__c = 'Tractor' AND Income_Source_for_Tractor__c = 'Banking' LIMIT 1) from Applicant__c where Opportunity__c = :recordId AND Applicant_Type__c = 'Borrower' AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED LIMIT 1];
                appBorrower = appBorrowerList.size() > 0 ? appBorrowerList[0] : new Applicant__c();
                if(appBorrowerList.size() > 0){
                    borrowerFOIR = appBorrowerList[0].FOIR__c!=null ? appBorrowerList[0].FOIR__c.setScale(2) : 0;
                }else{
                    borrowerFOIR=0;
                }
                borrowerRiskBand = ViewCamController.calculateRiskBand(appBorrower.Scorecard_Decision__c);
                
                if(appBorrower!=null && appBorrower.Id!=null){
                    currentExposureAmount += totalFundedPremium!= null ? (Decimal)totalFundedPremium : 0;
                    List<Existing_EMI__c> existingEmiDetails = new List<Existing_EMI__c>();
                    existingEmiDetails = [SELECT Applicant_Id__c,EMI__c FROM Existing_EMI__c WHERE Applicant_Id__c=:appBorrower.Id LIMIT 1000];
                    existingEMI = existingEmiDetails.size()>0?existingEmiDetails[0]:new Existing_EMI__c();
                }
                
                
                appCoBorrowerList = [select Id,FOIR__c,Customer_Category__c,Beneficial_Owner_Category__c,Remarks__c,Email_Id__c,Name,Gender__c,Marital_status__c,Scorecard_Decision__c,Income_Ca__c,Relationship_with_borrower__c,Customer_Code__c, Entity__c,Employer_Name__c,Applicant_Type__c,Do_you_have_a_bank_account_with_IBL__c,Willing_to_open_Bank_Account_with_IIB__c,Would_you_like_to_open_a_bank_account__c,Total_Insurance_Payable__c, Is_CoBorrower_Relative_Of_Director__c, Is_CoBorrower_Relative_Of_Senior_Officer__c,CoBorrower_Relation_With_IndusInd_Q1__c,CoBorrower_Relation_With_IndusInd_Q2__c,CoBorrower_Relation_With_Other_Bank_Q1__c,CoBorrower_Relation_With_Other_Bank_Q2__c,Relationship_With_IndusInd_Or_Other_Bank__c,Salaried_Self_employed__c,Profile__c,(Select Id, Income_Detail_Bank_Master__r.Name from Income_Details__r where Applicant__r.Opportunity__r.Product_Type__c = 'Tractor' AND Income_Source_for_Tractor__c = 'Banking' LIMIT 1),Relationship_with_Entity__c from Applicant__c where Opportunity__c = :recordId AND Applicant_Type__c IN ('Co-borrower','Beneficiary','Guarantor') and In_Active_Applicant__c = false WITH SECURITY_ENFORCED LIMIT 10000];
                appCoBorrower = appCoBorrowerList.size() > 0 ? appCoBorrowerList[0] : new Applicant__c();
                if(appCoBorrowerList.size() > 0){
                    coBorrowerFOIR = appCoBorrowerList[0].FOIR__c!=null ?  appCoBorrowerList[0].FOIR__c.setScale(2) : 0;
                }else{
                    coBorrowerFOIR=0;
                }
                coborrowerRiskBand = ViewCamController.calculateRiskBand(appCoBorrower.Scorecard_Decision__c);
                
                //Added for Co-Borrowers details dynamically start
                coBorrowersWrapperMap = new Map<Id,CoBorrowerWrapper>();
                appBenList = new List<CoBorrowerWrapper>();
                Integer counter = 1;
                Integer benCounter = 1;
                Integer appPartyCounter = 1;
                Map<String, String> relationWithEntMap = IND_CAMWithoutSharing.getPicklistValues('Applicant__c','Relationship_with_Entity__c');
                for (Applicant__c applicant : appCoBorrowerList) {
                    if(!coBorrowersWrapperMap.containsKey(applicant.Id) && (applicant.Applicant_Type__c == 'Co-borrower' || (opploan.Customer_Type__c=='Non-Individual' && applicant.Applicant_Type__c == 'Beneficiary' && (applicant.Beneficial_Owner_Category__c =='Controlling person' || applicant.Beneficial_Owner_Category__c =='Beneficial Owner cum Co-borrower')))){
                        CoBorrowerWrapper coBorrowerWrapperObj = new CoBorrowerWrapper();
                        coBorrowerWrapperObj.applicantTitle = applicant.Applicant_Type__c == 'Co-borrower' ? 'Co-Borrower '+ counter : 'Beneficiary '+ benCounter;
                        coBorrowerWrapperObj.applicantName = applicant.Name == null ? '' : applicant.Name;
                        if(applicant.Applicant_Type__c == 'Beneficiary'){
                            coBorrowerWrapperObj.relationshipWithBorrower = applicant.Relationship_with_Entity__c == null ? '' : relationWithEntMap.get(applicant.Relationship_with_Entity__c);
                        }else{
                            coBorrowerWrapperObj.relationshipWithBorrower = applicant.Relationship_with_borrower__c == null ? '' : applicant.Relationship_with_borrower__c;
                        }
                        coBorrowerWrapperObj.martialStatus = applicant.Marital_status__c == null ? '' : applicant.Marital_status__c;
                        coBorrowerWrapperObj.profileName = applicant.Profile__c == null ? '' : applicant.Profile__c;
                        coBorrowerWrapperObj.applicantRemarks = applicant.Remarks__c == null ? '' : applicant.Remarks__c;
                        coBorrowerWrapperObj.coBorrowerId = applicant.Id;
                        coBorrowerWrapperObj.applicantType = applicant.Applicant_Type__c == 'Co-borrower' ? 'CoBorrower' : applicant.Applicant_Type__c;
                        if(applicant.Applicant_Type__c == 'Co-borrower'){
                            counter++;
                        }else{
                            benCounter++;
                        }
                        coBorrowersWrapperMap.put(applicant.id, coBorrowerWrapperObj);
                    }
                   /* if(opploan.Product_Type__c == 'Tractor' && opploan.Customer_Type__c=='Non-Individual' && applicant.Applicant_Type__c == 'Beneficiary'){
                        CoBorrowerWrapper coBorrowerWrapperObj = new CoBorrowerWrapper();
                        coBorrowerWrapperObj.applicantTitle = applicant.Applicant_Type__c +' '+ appPartyCounter;
                        coBorrowerWrapperObj.applicantName = applicant.Name == null ? '' : applicant.Name;
                        coBorrowerWrapperObj.relationshipWithBorrower = applicant.Relationship_with_borrower__c == null ? '' : applicant.Relationship_with_borrower__c;
                        coBorrowerWrapperObj.martialStatus = applicant.Marital_status__c == null ? '' : applicant.Marital_status__c;
                        coBorrowerWrapperObj.applicantRemarks = applicant.Remarks__c == null ? '' : applicant.Remarks__c;
                        coBorrowerWrapperObj.coBorrowerId = applicant.Id;
                        coBorrowerWrapperObj.applicantType = applicant.Applicant_Type__c == 'Co-borrower' ? 'CoBorrower' : applicant.Applicant_Type__c;
                        appPartyCounter++;
                        appBenList.add(coBorrowerWrapperObj);
                    }*/
                   /* else if(opploan.Product_Type__c != 'Tractor' && opploan.Customer_Type__c=='Non-Individual' && (applicant.Relationship_with_borrower__c=='Beneficial Owner' || applicant.Relationship_with_borrower__c=='Authorised signatory')){
                        CoBorrowerWrapper coBorrowerWrapperObj = new CoBorrowerWrapper();
                        coBorrowerWrapperObj.applicantTitle = applicant.Applicant_Type__c +' '+ appPartyCounter;
                        coBorrowerWrapperObj.applicantName = applicant.Name == null ? '' : applicant.Name;
                        coBorrowerWrapperObj.relationshipWithBorrower = applicant.Relationship_with_borrower__c == null ? '' : applicant.Relationship_with_borrower__c;
                        coBorrowerWrapperObj.martialStatus = applicant.Marital_status__c == null ? '' : applicant.Marital_status__c;
                        coBorrowerWrapperObj.applicantRemarks = applicant.Remarks__c == null ? '' : applicant.Remarks__c;
                        coBorrowerWrapperObj.coBorrowerId = applicant.Id;
                        coBorrowerWrapperObj.applicantType = applicant.Applicant_Type__c == 'Co-borrower' ? 'CoBorrower' : applicant.Applicant_Type__c;
                        appPartyCounter++;
                        appBenList.add(coBorrowerWrapperObj);
                    }*/
                }
                //Added for Co-Borrowers details dynamically end                
                if(String.isNotEmpty(borrowerRiskBand)){
                    if(String.isNotEmpty(coborrowerRiskBand)){
                        proposalRiskBand = Integer.valueOf(borrowerRiskBand)>Integer.valueOf(coborrowerRiskBand)?borrowerRiskBand:coborrowerRiskBand;
                    }
                    else{
                        proposalRiskBand = borrowerRiskBand;
                    }
                }
                
                if(appBorrower.Id!=null){
                    List<InsuranceDetails__c> InsuranceList=[SELECT Applicant__c,Applicant__r.name,Applicant__r.Applicant_Type__c, Product_Type__c, Name, Amount__c,Funded_Non_funded__c, Funded_Premium__c from InsuranceDetails__c where Applicant__c=:appBorrower.Id WITH SECURITY_ENFORCED];
                    crossSell = !InsuranceList.isEmpty()?'Yes':'No';
                }
                else {
                    crossSell='No';
                }
                
                List<Applicant__c> applicantList = new List<Applicant__c>();
                applicantList = [SELECT Scorecard_Decision__c,In_Active_Applicant__c,Applicant_Type__c FROM Applicant__c WHERE Opportunity__c = :recordId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED];
                
                List<Customer_Dedupe_Response__c> customerDedupeList = new List<Customer_Dedupe_Response__c>();
                customerDedupeList = [SELECT Response__c,Deal_Status_Flag__c,Customer_Status_Flag__c,Customer_Code__c,Applicant__r.Applicant_Type__c,Applicant__r.Check_Eligibility_Message__c FROM Customer_Dedupe_Response__c WHERE Applicant__c IN:applicantList AND Applicant__r.In_Active_Applicant__c = false WITH SECURITY_ENFORCED LIMIT 1000];
                Boolean borrowerDedupe = false;
                Boolean coborrowerDedupe = false;
                coborrowerDedupeList = new List<DedupeDataWrapper>();
                if (coborrowerDedupeList.size() == 0) {
                    customerCode = 'New';
                }
                for(Customer_Dedupe_Response__c dedupeObj:customerDedupeList){
                    if(dedupeObj.Applicant__r.Applicant_Type__c=='Borrower' && borrowerDedupe==false){
                        borrowerCustomerDedupe = dedupeObj;
                        borrowerDedupe=true;
                        borrowerDedupeWrapper = new DedupeDataWrapper();
                        borrowerDedupeWrapper.checkEligibilityMsg = dedupeObj.Applicant__r.Check_Eligibility_Message__c;
                        if(borrowerCustomerDedupe!=null && borrowerCustomerDedupe.Customer_Code__c!=null && borrowerCustomerDedupe.Response__c!=null){
                            customerCode= borrowerCustomerDedupe.Customer_Code__c!=null?'Existing':'New';
                            DedupeResoponseWrapper dedupeResponseObj = null;
                            if (borrowerCustomerDedupe.Response__c != null && !borrowerCustomerDedupe.Response__c.contains('"content":"')) {
                                dedupeResponseObj = (DedupeResoponseWrapper)JSON.deserialize(borrowerCustomerDedupe.Response__c, DedupeResoponseWrapper.class);
                            }
                            if(dedupeResponseObj!=null && dedupeResponseObj.response.status=='SUCCESS'){
                                if(dedupeResponseObj.response.content[0].Data!=null && dedupeResponseObj.response.content[0].Data.InternalDedupeResponse!=null && dedupeResponseObj.response.content[0].Data.InternalDedupeResponse[0].CustomerValidate!=null){
                                    for(CustomerValidate customerValidateObj:dedupeResponseObj.response.content[0].Data.InternalDedupeResponse[0].CustomerValidate){
                                        if(customerValidateObj.CustomerCodeVal==borrowerCustomerDedupe.Customer_Code__c){
                                            string fraudCheck='';
                                            fraudCheck.trim();
                                            if(!customerValidateObj.ARC.isEmpty()){
                                                fraudCheck+='ARC';
                                            }
                                            if(!customerValidateObj.Gecl.isEmpty()){
                                                fraudCheck+= fraudCheck!=''? ','+'Gecl':'Gecl';
                                            }
                                            if(!customerValidateObj.Restructure.isEmpty()){
                                                fraudCheck+=(String.isNotBlank(fraudCheck)? ',Restructure':'Restructure');
                                            }
                                            if(!customerValidateObj.NPA.isEmpty()){
                                                fraudCheck+=fraudCheck!=''? ','+'NPA':'NPA';
                                            }
                                            string rvgdFlag = '';
                                            string fkFlag = '';
                                            if(!customerValidateObj.Dealstatus.isEmpty() && (customerValidateObj.Dealstatus[0].Status_Flag=='R' || customerValidateObj.Dealstatus[0].Status_Flag=='V' || customerValidateObj.Dealstatus[0].Status_Flag=='G')){
                                                rvgdFlag+=customerValidateObj.Dealstatus[0].Status_Flag;
                                            }
                                            if(!customerValidateObj.CustomerStatus.isEmpty() && (customerValidateObj.CustomerStatus[0].Active_Flag=='D')){
                                                rvgdFlag += rvgdFlag!=''? ','+customerValidateObj.CustomerStatus[0].Active_Flag:customerValidateObj.CustomerStatus[0].Active_Flag;
                                            }
                                            if(!customerValidateObj.CustomerStatus.isEmpty() && (customerValidateObj.CustomerStatus[0].Active_Flag=='F' || customerValidateObj.CustomerStatus[0].Active_Flag=='K')){
                                                fkFlag = customerValidateObj.CustomerStatus[0].Active_Flag;
                                            }
                                            borrowerDedupeWrapper.fraudChecks = String.isNotBlank(fraudCheck) && String.isNotEmpty(fraudCheck) ? fraudCheck : 'Not found';
                                            borrowerDedupeWrapper.rvgdFlag = String.isNotBlank(rvgdFlag) ? rvgdFlag : 'Not found';
                                            borrowerDedupeWrapper.fkFlag = String.isNotBlank(fkFlag) ? fkFlag : 'Not found';
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if(dedupeObj.Applicant__r.Applicant_Type__c=='Co-borrower' && coborrowerDedupe==false){
                        DedupeDataWrapper coborrowerDedupeWrapper = new DedupeDataWrapper();
                        coborrowerDedupeWrapper.checkEligibilityMsg = dedupeObj.Applicant__r.Check_Eligibility_Message__c;
                        if(dedupeObj!=null && dedupeObj.Customer_Code__c!=null && dedupeObj.Response__c!=null){
                            DedupeResoponseWrapper dedupeResponseObj = null;
                            if (dedupeObj.Response__c != null && !dedupeObj.Response__c.contains('"content":"')) {
                                dedupeResponseObj = (DedupeResoponseWrapper)JSON.deserialize(dedupeObj.Response__c, DedupeResoponseWrapper.class);
                            }
                            // DedupeResoponseWrapper dedupeResponseObj = (DedupeResoponseWrapper)JSON.deserialize(dedupeObj.Response__c, DedupeResoponseWrapper.class);
                            coborrowerCustomerCode = dedupeObj.Customer_Code__c;
                            if(dedupeResponseObj!=null && dedupeResponseObj.response.status=='SUCCESS'){
                                if(dedupeResponseObj.response.content[0].Data!=null && dedupeResponseObj.response.content[0].Data.InternalDedupeResponse!=null && dedupeResponseObj.response.content[0].Data.InternalDedupeResponse[0].CustomerValidate!=null){
                                    for(CustomerValidate customerValidateObj:dedupeResponseObj.response.content[0].Data.InternalDedupeResponse[0].CustomerValidate){
                                        if(customerValidateObj.CustomerCodeVal==dedupeObj.Customer_Code__c){
                                            string fraudCheck='';
                                            if(!customerValidateObj.ARC.isEmpty()){
                                                fraudCheck+='ARC';
                                            }
                                            if(!customerValidateObj.Gecl.isEmpty()){
                                                fraudCheck+=',Gecl';
                                            }
                                            if(!customerValidateObj.Restructure.isEmpty()){
                                                fraudCheck+=',Restructure';
                                            }
                                            if(!customerValidateObj.NPA.isEmpty()){
                                                fraudCheck+=',NPA';
                                            }
                                            string rvgdFlag = '';
                                            string fkFlag = '';
                                            if(!customerValidateObj.Dealstatus.isEmpty() && (customerValidateObj.Dealstatus[0].Status_Flag=='R' || customerValidateObj.Dealstatus[0].Status_Flag=='V' || customerValidateObj.Dealstatus[0].Status_Flag=='G')){
                                                rvgdFlag+=customerValidateObj.Dealstatus[0].Status_Flag;
                                            }
                                            if(!customerValidateObj.CustomerStatus.isEmpty() && (customerValidateObj.CustomerStatus[0].Active_Flag=='D')){
                                                rvgdFlag += ','+customerValidateObj.CustomerStatus[0].Active_Flag;
                                            }
                                            if(!customerValidateObj.CustomerStatus.isEmpty() && (customerValidateObj.CustomerStatus[0].Active_Flag=='F' || customerValidateObj.CustomerStatus[0].Active_Flag=='K')){
                                                fkFlag = customerValidateObj.CustomerStatus[0].Active_Flag;
                                            }
                                            coborrowerDedupeWrapper.fraudChecks = String.isNotBlank(fraudCheck) ? fraudCheck : 'Not found';
                                            coborrowerDedupeWrapper.rvgdFlag = String.isNotBlank(rvgdFlag) ? rvgdFlag : 'Not found';
                                            coborrowerDedupeWrapper.fkFlag = String.isNotBlank(fkFlag) ? fkFlag : 'Not found';
                                            coborrowerDedupeList.add(coborrowerDedupeWrapper);
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                        
                    }
                }
                coBorrowersWrapperList = new List<CoBorrowerWrapper>();
                // CIBIL Details
                List<CIBIL_Details__c> cibilList = new List<CIBIL_Details__c>();
                cibilList = [SELECT Score__c,HighCredit_Or_SanctionedAmount__c,Current_Balance__c,Recent_Date__c,Oldest_Date__c,WrittenoffAmountTotal__c,SuitFiledOrWilfulDefault__c,Amount_Overdue__c,Equifax_Report_URl__c,CIBIL_Report_URl__c,NoOfEnLtSixMon__c,Cibil_Decision__c,Other_Loan_AD__c,Other_Loan_PD__c,Term_Loan_AD__c,Term_Loan_PD__c,Overdue_Account__c FROM CIBIL_Details__c WHERE Applicant__c = :appBorrower.Id LIMIT 1 ];
                cibil = cibilList.size() > 0 ? cibilList[0] : new CIBIL_Details__c();
                enableEquifaxBorrowerButton = cibilList.size() > 0 && cibil != null && cibil.Equifax_Report_URl__c != null;
                List<CIBIL_Details__c> coborrowercibilList = new List<CIBIL_Details__c>();
                coborrowercibilList = [SELECT Score__c,HighCredit_Or_SanctionedAmount__c,Current_Balance__c,Recent_Date__c,Oldest_Date__c,WrittenoffAmountTotal__c,SuitFiledOrWilfulDefault__c,Amount_Overdue__c,Equifax_Report_URl__c,CIBIL_Report_URl__c,NoOfEnLtSixMon__c,Cibil_Decision__c,Other_Loan_AD__c,Other_Loan_PD__c,Term_Loan_AD__c,Term_Loan_PD__c,Overdue_Account__c FROM CIBIL_Details__c WHERE Applicant__c = :appCoBorrower.Id LIMIT 1 ];
                coBorrowercibil = coborrowercibilList.size() > 0 ? coborrowercibilList[0] : new CIBIL_Details__c();
                enableEquifaxCoBorrowerButton = coborrowercibilList.size() > 0 && coBorrowercibil != null && coBorrowercibil.Equifax_Report_URl__c != null;
                
                //Added for CIBIL Details Co-Borrower section start
                Set<Id> setOfCoBorrowerIds = new Set<Id>();
                if(appCoBorrowerList.size() > 0){
                  for (Applicant__c applicantRec : appCoBorrowerList){
                    setOfCoBorrowerIds.add(applicantRec.Id);
                  } 
                }
                List<CIBIL_Details__c> coBorrowerCibilRecList = new List<CIBIL_Details__c>();
                coBorrowerCibilRecList = [SELECT Score__c,HighCredit_Or_SanctionedAmount__c,Current_Balance__c,Recent_Date__c,Oldest_Date__c,WrittenoffAmountTotal__c,SuitFiledOrWilfulDefault__c,Amount_Overdue__c,Equifax_Report_URl__c,CIBIL_Report_URl__c,Applicant__c,NoOfEnLtSixMon__c,Cibil_Decision__c,Other_Loan_AD__c,Other_Loan_PD__c,Term_Loan_AD__c,Term_Loan_PD__c,Overdue_Account__c FROM CIBIL_Details__c WHERE Applicant__c IN : setOfCoBorrowerIds LIMIT 10000];
                if(coBorrowerCibilRecList.size() > 0){
                  for (CIBIL_Details__c coBrCibilRec : coBorrowerCibilRecList) {
                      if(coBrCibilRec.Applicant__c != null && coBorrowersWrapperMap.containsKey(coBrCibilRec.Applicant__c)){
                          CoBorrowerWrapper coBorrowerCibilWrapper = coBorrowersWrapperMap.get(coBrCibilRec.Applicant__c);
                          coBorrowerCibilWrapper.cibilScore =  coBrCibilRec.Score__c != null ? coBrCibilRec.Score__c : '';
                          coBorrowerCibilWrapper.highCreditOrSanctionedAmount = coBrCibilRec.HighCredit_Or_SanctionedAmount__c != null ? coBrCibilRec.HighCredit_Or_SanctionedAmount__c : null;
                          coBorrowerCibilWrapper.currentBalance = coBrCibilRec.Current_Balance__c != null ? coBrCibilRec.Current_Balance__c : null;
                          coBorrowerCibilWrapper.recentDate = coBrCibilRec.Recent_Date__c != null ? coBrCibilRec.Recent_Date__c : null;
                          coBorrowerCibilWrapper.oldestDate = coBrCibilRec.Oldest_Date__c != null ? coBrCibilRec.Oldest_Date__c : null;
                          coBorrowerCibilWrapper.writtenoffAmountTotal = coBrCibilRec.WrittenoffAmountTotal__c != null ? coBrCibilRec.WrittenoffAmountTotal__c : null;
                          coBorrowerCibilWrapper.suitFiledOrWilfulDefault = coBrCibilRec.SuitFiledOrWilfulDefault__c != null ? coBrCibilRec.SuitFiledOrWilfulDefault__c : ''; 
                          coBorrowerCibilWrapper.amountOverdue = coBrCibilRec.Amount_Overdue__c != null ? coBrCibilRec.Amount_Overdue__c : null;
                          coBorrowersWrapperMap.put(coBrCibilRec.Applicant__c, coBorrowerCibilWrapper);
                      }
                    }  
                }
                //Added for CIBIL Details Co-Borrower section start
                //Added for Guarantor CIBIL Details section start
                List<CIBIL_Details__c> guarantorCibilList = new List<CIBIL_Details__c>();
                guarantorCibilList = [SELECT Score__c,HighCredit_Or_SanctionedAmount__c,Current_Balance__c,Recent_Date__c,Oldest_Date__c,WrittenoffAmountTotal__c,SuitFiledOrWilfulDefault__c,Amount_Overdue__c,Equifax_Report_URl__c,CIBIL_Report_URl__c,NoOfEnLtSixMon__c,Cibil_Decision__c,Other_Loan_AD__c,Other_Loan_PD__c,Term_Loan_AD__c,Term_Loan_PD__c,Overdue_Account__c FROM CIBIL_Details__c WHERE Applicant__c = :oppGuarantors.Id WITH SECURITY_ENFORCED LIMIT 1 ];
                guarantorCibilRecList = guarantorCibilList.size() > 0 ? guarantorCibilList[0] : new CIBIL_Details__c();
                System.debug('guarantorCibilList - '+guarantorCibilList);
                enableEquifaxGtrButton = guarantorCibilRecList != null && guarantorCibilRecList.Equifax_Report_URl__c == null;
                //Added for Guarantor CIBIL Details section end
                

                // CAM
                List<CAM__c> camList = new List<CAM__c>();
                camList = [SELECT Id, BE_CVO_Remark__c,Proposal_Status__c,Action_Taken__c,Productivity_YTD__c,Weighted_IRR_YTD__c,Conditional_Approval__c,Hold_Date__c,Is_Hold__c,Level_of_Hold_User__c,Loan_Application__c,Trigger_Deviations__c,Deviation_Created_Date__c,CreatedBy.Name,CreatedById,Credit_Analyst_Remarks__c,Is_CAM_Reopen__c,CAM_Approval_Date__c,CAM_Submitted_by_ACM_SCM__c,Submit_for_Approval_UserId__c from CAM__c WHERE Loan_Application__c = :recordId LIMIT 1];
                cam = camList.size() > 0 ? camList[0] : new CAM__c();
                disableAll = cam.Action_Taken__c;
                // CAM
                if(camRecordId!=null){
                    camList = new List<CAM__c>();
                    camList = [SELECT Id, BE_CVO_Remark__c,Productivity_YTD__c,Action_Taken__c,Weighted_IRR_YTD__c,Proposal_Status__c,Conditional_Approval__c,Hold_Date__c,Is_Hold__c,Level_of_Hold_User__c,Loan_Application__c,Trigger_Deviations__c, Loan_Application__r.AccountId,Deviation_Created_Date__c,CreatedBy.Name,CreatedById,Credit_Analyst_Remarks__c,Is_CAM_Reopen__c,CAM_Approval_Date__c,CAM_Submitted_by_ACM_SCM__c,Submit_for_Approval_UserId__c from CAM__c WHERE Id = :camRecordId LIMIT 1];
                    cam = camList.size() > 0 ? camList[0] : new CAM__c();
                    disableAll = cam.Action_Taken__c;
                    
                }
                
                // try {
                List<AccountTeamMember> accountTeamMember = [SELECT Id, Level__c,TeamMemberRole FROM AccountTeamMember WHERE AccountId =:camList[0].Loan_Application__r.AccountId AND UserId = :currentUserId WITH SECURITY_ENFORCED LIMIT 1];
                if (accountTeamMember.size() > 0) {
                    currentUserLevel = accountTeamMember[0].Level__c;
                }
                
                deviationWrapperList = new List<DeviationWrapper>();
                deviation = new List<Deviation__c>();
                // Proposal Approval Log
                applog = new List<Proposal_Approval_Log__c>();//	CISP-2332
                applog = [select Name, Proposal_description__c,Role__c,Proposal_Approval_Condition__c,Forwarded_On__c,Forwarding_Role__c,Forwarded_By__c,Forwarded_Role__c,Forwarded_Employee__r.Name,Approval_Status__c,Remark__c,Date_and_Time__c,RecordType.Name,Parent_CAM__r.Loan_Application__c,Parent_CAM__r.Loan_Application__r.Id,Parent_CAM__c,Parent_CAM__r.Loan_Application__r.Applicant_Name__c,LastModifiedDate,CreatedBy.FirstName,CreatedBy.LastName,Proposal_Remark__c,CreatedDate from Proposal_Approval_Log__c WHERE Parent_CAM__c = :cam.Id ORDER BY CreatedDate DESC];//CISP-2532
                Boolean proposalRejected = false;
                for (Proposal_Approval_Log__c proposalObj : applog) {
                    if(proposalObj.Approval_Status__c != null && proposalObj.Approval_Status__c == 'Rejected'){
                        proposalRejected = true;
                    }
                }
                
                if (oppLoan.Product_Type__c == System.Label.Tractor) {
                    if((cam.Trigger_Deviations__c == true && cam.CAM_Submitted_by_ACM_SCM__c == true) || (cam.Trigger_Deviations__c == true && ((cam.Submit_for_Approval_UserId__c == UserInfo.getUserId()) || (currentUserRole == 'CVO' && opportunityList.size() > 0 && opportunityList[0].OwnerId == UserInfo.getUserId())))){
                        deviation = [select id, Deviation_Description__c,Justification_Remarks__c,Deviation_Level__c,Role__c,Approval_Status__c,Remarks__c,Parent_CAM__c, Parent_CAM__r.Loan_Application__c,Parent_CAM__r.Loan_Application__r.CreatedById,Parent_CAM__r.Loan_Application__r.Id,Proposal_Status__c,Type__c from Deviation__c WHERE Parent_CAM__c = :cam.Id WITH SECURITY_ENFORCED];
                    }
                    if(cam.Submit_for_Approval_UserId__c == UserInfo.getUserId()){sameApprovedUser = true;}
                }else{
                    deviation = [select id, Deviation_Description__c,Justification_Remarks__c,Deviation_Level__c,Role__c,Approval_Status__c,Remarks__c,Parent_CAM__c, Parent_CAM__r.Loan_Application__c,Parent_CAM__r.Loan_Application__r.CreatedById,Parent_CAM__r.Loan_Application__r.Id,Proposal_Status__c,Type__c from Deviation__c WHERE Parent_CAM__c = :cam.Id WITH SECURITY_ENFORCED];
                }
                if(oppLoanList[0].Parent_Loan_Application__c != null){
                    parentLoanAppId =  String.valueOf(oppLoanList[0].Parent_Loan_Application__c).substring(0, 15);
                    CAMApprovalLogController.CAMDataWrapper parentCamWrapper = CAMApprovalLogController.getParentLoanApplicationData(oppLoanList[0].Parent_Loan_Application__c);
                    if(parentCamWrapper != null){
                        if (parentCamWrapper.parentLoanProposal != null) {
                            for(Proposal_Approval_Log__c proposalObj:parentCamWrapper.parentLoanProposal){
                                applog.add(proposalObj);
                            } 
                        }    
                    }
                }//Start CISP-2445
                if(oppLoanList[0].Parent_Loan_Application__c != null && oppLoanList[0].Parent_Loan_Application__r.Parent_Loan_Application__c != null){
                    grandparentLoanAppId =  String.valueOf(oppLoanList[0].Parent_Loan_Application__r.Parent_Loan_Application__c).substring(0, 15);
                    CAMApprovalLogController.CAMDataWrapper parentCamWrapper = CAMApprovalLogController.getParentLoanApplicationData(oppLoanList[0].Parent_Loan_Application__r.Parent_Loan_Application__c);
                    if(parentCamWrapper != null){
                        if (parentCamWrapper.parentLoanProposal != null) {
                            for(Proposal_Approval_Log__c proposalObj:parentCamWrapper.parentLoanProposal){
                                applog.add(proposalObj);
                            } 
                        }    
                    }//End CISP-2445
                }
                
                // Deviation
                
                
                for(Deviation__c deviationObj:deviation){
                    if(deviationObj.Proposal_Status__c!=null && deviationObj.Proposal_Status__c=='Rejected'){
                        disableAll=true;
                    }
                    deviationWrapperList.add(new DeviationWrapper(deviationObj, true));
                }
                List<CommitteeRoleLevel__mdt> committeeRoleLevelList = [SELECT Id, Label, DeveloperName, Product__c, Business_Credit__c FROM CommitteeRoleLevel__mdt WHERE Product__c = :opploan.Product_Type__c WITH SECURITY_ENFORCED LIMIT 100];
                roleVsTypeMap = new Map<String, String>();
                if (!committeeRoleLevelList.isEmpty()) {
                    for(CommitteeRoleLevel__mdt committeeRoleLevel : committeeRoleLevelList) {
                        roleVsTypeMap.put(committeeRoleLevel.Label, committeeRoleLevel.Business_Credit__c);
                    }
                }
                committeeDeviationRolesMap = new Map<String,String>();
                Map<String,String> committeeDeviationNMRolesMap = new Map<String,String>();
                List<Committee_Deviation__mdt> committeeDeviationMDList=[SELECT Id, Label, DeveloperName,CCC_Above_Flag__c,Mandatory_Role__c,Non_Mandatory_Role__c from Committee_Deviation__mdt WHERE Product__c=:opploan.Product_Type__c WITH SECURITY_ENFORCED limit 100 ];
                if(committeeDeviationMDList!=null && committeeDeviationMDList.size()>0){
                    for(Committee_Deviation__mdt committeeMdt:committeeDeviationMDList){
                        if(!committeeDeviationRolesMap.containsKey(committeeMdt.Label)){
                            committeeDeviationRolesMap.put(committeeMdt.Label,committeeMdt.Mandatory_Role__c);
                            committeeDeviationNMRolesMap.put(committeeMdt.Label,committeeMdt.Non_Mandatory_Role__c);
                        }
                    }
                }
                
                //Mitigant section start
                List<Mitigant__c> metigantRecList = new List<Mitigant__c>();
                metigantRecList = [SELECT Id,Name,Description__c FROM Mitigant__c Where CAM__c =: cam.id WITH  SECURITY_ENFORCED  LIMIT 10000];
                mitigantList = new List<Mitigant__c>(metigantRecList);
                mitigantHeadingList = new List<String>();
                Integer mitiCounter = 1;
                if(metigantRecList.size() > 0){
                    for(Integer i=1; i<=metigantRecList.size(); i++){
                        mitigantHeadingList.add('Mitigant '+mitiCounter);
                        mitiCounter++;
                    }
                }else{
                    mitigantHeadingList.add('Mitigant '+mitiCounter);
                }
                //Mitigant section end

                //Added for disable Approve/Reject button on CAMPage SFTRAC-58 by Prashant Dixit start
                // for(Proposal_Approval_Log__c prAppLog : [SELECT Id, Role__c, Approval_Status__c FROM Proposal_Approval_Log__c WHERE Parent_CAM__c =: cam.id AND Parent_CAM__r.Is_CAM_Reopen__c = false WITH SECURITY_ENFORCED LIMIT 10000]){
                //     if((prAppLog.Role__c == 'SCM' || prAppLog.Role__c == 'ACM')){
                //         disableAll = true;
                //     }
                // }
                //Added for disable Approve/Reject button on CAMPage SFTRAC-58 by Prashant Dixit end

                // Document
                document = new list<Documents__c>();
                document = [select ID,Case__c,Document_Type__c,Name,Applicant__c,Age__c,Applicant__r.Applicant_Type__c,Applicant__r.Opportunity__r.Product_Type__c,RecordType.Name, Proof_of_Identity_POI__c,KYC_DOB__c,Gender__c,Is_Active__c,KYC_District__c, KYC_City__c,Taluka__c from Documents__c Where  Document_Type__c not in ('Customer Image') and  Opportunity_Relation__c = :recordId AND Applicant__r.In_Active_Applicant__c = false WITH SECURITY_ENFORCED Limit 10000];//CISP-2747 and CISP-2750 Limit updated
                Map<Id,Documents__c> docIdVsDocMap = new Map<Id,Documents__c>(document);
                Set<Id> documentIdSet = new Set<Id>();
                districtValue = '';
                talukaValue = '';
                guarantorAge = '';
                guarantorGender = '';
                coborrowerAgeMap = new Map<Id,String>();
                coborrowerGenderMap = new Map<Id,String>();
                for(Documents__c documentObj:document){
                    if(documentObj.Applicant__r.Applicant_Type__c == 'Borrower' && documentObj.Is_Active__c == true){
                        districtValue = String.isNotBlank(documentObj.KYC_District__c) ? documentObj.KYC_District__c : String.isNotBlank(documentObj.KYC_City__c) ? documentObj.KYC_City__c : districtValue;
                        talukaValue = String.isNotBlank(documentObj.Taluka__c) ? documentObj.Taluka__c : talukaValue;
                    }
                    if(documentObj.Document_Type__c=='Residence FI' && documentObj.Applicant__r.Applicant_Type__c=='Borrower'){
                        resiFiBorrowerDoc = documentObj;
                    }
                    if(documentObj.Document_Type__c=='Residence FI' && documentObj.Applicant__r.Applicant_Type__c=='Co-borrower'){
                        resiFiCoBorrowerDoc = documentObj;
                        coBorrowersWrapperMap.get(documentObj.Applicant__c).resiFiCoBorrowerDocMul = documentObj;  
                    }
                    if(documentObj.Document_Type__c=='Residence FI' && documentObj.Applicant__r.Applicant_Type__c=='Guarantor'){
                        resiFiGuarantorDoc = documentObj;
                    }
                    if(documentObj.Document_Type__c=='Office FI' && documentObj.Applicant__r.Applicant_Type__c=='Borrower'){
                        officeFiBorrowerDoc = documentObj;
                    }
                    if(documentObj.Document_Type__c=='Office FI' && documentObj.Applicant__r.Applicant_Type__c=='Co-borrower'){
                        officeFiCoBorrowerDoc = documentObj;
                        coBorrowersWrapperMap.get(documentObj.Applicant__c).officeFiCoBorrowerDocMul = documentObj;
                    }
                    if(documentObj.Document_Type__c=='Office FI' && documentObj.Applicant__r.Applicant_Type__c=='Guarantor'){
                        officeFiGuarantorDoc = documentObj;
                    }
                    documentIdSet.add(documentObj.Id);
                    if(documentObj.Applicant__r.Applicant_Type__c=='Borrower' && documentObj.Proof_of_Identity_POI__c == true){
                        if(documentObj.KYC_DOB__c!=null && (documentObj.KYC_DOB__c.month() > date.today().month() || (documentObj.KYC_DOB__c.month() == date.today().month() && documentObj.KYC_DOB__c.day() > date.today().day()))) {
                            borrowerAge = String.valueOf(date.today().year()-documentObj.KYC_DOB__c.year()-1);
                        }else if(documentObj.KYC_DOB__c!=null && documentObj.KYC_DOB__c.month() == date.today().month() && documentObj.KYC_DOB__c.day() <= date.today().day()) {
                            borrowerAge = String.valueOf(date.today().year()-documentObj.KYC_DOB__c.year());
                        }else if(documentObj.KYC_DOB__c!=null && documentObj.KYC_DOB__c.month() < date.today().month()) {
                            borrowerAge = String.valueOf(date.today().year()-documentObj.KYC_DOB__c.year());
                        }else{
                            borrowerAge = '';
                        }
                        if(documentObj.Gender__c!=null) {
                            borrowerGender = String.valueOf(documentObj.Gender__c);
                        }else {
                            borrowerGender = ''; 
                        }
                    }
                    if(documentObj.Applicant__r.Applicant_Type__c=='Co-borrower' && documentObj.Proof_of_Identity_POI__c == true){
                        if(documentObj.KYC_DOB__c!=null && (documentObj.KYC_DOB__c.month() > date.today().month() || (documentObj.KYC_DOB__c.month() == date.today().month() && documentObj.KYC_DOB__c.day() > date.today().day()))) {
                            if(documentObj.Applicant__r.Opportunity__r.Product_Type__c == 'Tractor'){
                                coborrowerAgeMap.put(documentObj.Applicant__c, String.valueOf(date.today().year()-documentObj.KYC_DOB__c.year()-1));
                            }else{
                                coborrowerAge = String.valueOf(date.today().year()-documentObj.KYC_DOB__c.year()-1);
                            }
                        }else if(documentObj.KYC_DOB__c!=null && documentObj.KYC_DOB__c.month() == date.today().month() && documentObj.KYC_DOB__c.day() <= date.today().day()) {
                            if(documentObj.Applicant__r.Opportunity__r.Product_Type__c == 'Tractor'){
                                coborrowerAgeMap.put(documentObj.Applicant__c, String.valueOf(date.today().year()-documentObj.KYC_DOB__c.year()));
                            }else{
                                coborrowerAge = String.valueOf(date.today().year()-documentObj.KYC_DOB__c.year());
                            }
                        }else if(documentObj.KYC_DOB__c!=null && documentObj.KYC_DOB__c.month() < date.today().month()) {
                            if(documentObj.Applicant__r.Opportunity__r.Product_Type__c == 'Tractor'){
                                coborrowerAgeMap.put(documentObj.Applicant__c, String.valueOf(date.today().year()-documentObj.KYC_DOB__c.year()));
                            }else{
                                coborrowerAge = String.valueOf(date.today().year()-documentObj.KYC_DOB__c.year());
                            }
                        }else{
                            if(documentObj.Applicant__r.Opportunity__r.Product_Type__c == 'Tractor'){
                                coborrowerAgeMap.put(documentObj.Applicant__c, '');
                            }else{
                                coborrowerAge = '';
                            }
                        }
                        if(documentObj.Applicant__r.Opportunity__r.Product_Type__c == 'Tractor'){
                            if(documentObj.Gender__c!=null) {
                                coborrowerGenderMap.put(documentObj.Applicant__c, String.valueOf(documentObj.Gender__c));
                            }else{
                                coborrowerGenderMap.put(documentObj.Applicant__c, '');
                            }
                        }else{
                            if(documentObj.Gender__c!=null) {
                                coborrowerGender = String.valueOf(documentObj.Gender__c);
                            }else {
                                coborrowerGender = ''; 
                            }
                        }
                    }
                    if(documentObj.Applicant__r.Applicant_Type__c == 'Guarantor' && documentObj.Proof_of_Identity_POI__c == true && documentObj.Applicant__r.Opportunity__r.Product_Type__c == 'Tractor'){
                        if(documentObj.KYC_DOB__c!=null && (documentObj.KYC_DOB__c.month() > date.today().month() || (documentObj.KYC_DOB__c.month() == date.today().month() && documentObj.KYC_DOB__c.day() > date.today().day()))) {
                            guarantorAge = String.valueOf(date.today().year()-documentObj.KYC_DOB__c.year()-1);
                        }else if(documentObj.KYC_DOB__c!=null && documentObj.KYC_DOB__c.month() == date.today().month() && documentObj.KYC_DOB__c.day() <= date.today().day()) {
                            guarantorAge = String.valueOf(date.today().year()-documentObj.KYC_DOB__c.year());
                        }else if(documentObj.KYC_DOB__c!=null && documentObj.KYC_DOB__c.month() < date.today().month()) {
                            guarantorAge = String.valueOf(date.today().year()-documentObj.KYC_DOB__c.year());
                        }
                        guarantorGender = String.isNotBlank(documentObj.Gender__c) ? String.valueOf(documentObj.Gender__c) : guarantorGender;
                    }
                }
                coborrowerAgeMap = IND_CAMWithoutSharing.applicantAge(document,coborrowerAgeMap);
                coborrowerGenderMap = IND_CAMWithoutSharing.applicantGender(document,coborrowerGenderMap);
                //coBorrowersWrapperList = new List<CoBorrowerWrapper>();
                for (Id applicantId : coBorrowersWrapperMap.keySet()) {
                    CoBorrowerWrapper coBorrowerWrapper = coBorrowersWrapperMap.get(applicantId);
                    coBorrowerWrapper.age = coborrowerAgeMap.containsKey(applicantId) ? (String)coborrowerAgeMap.get(applicantId) : '';
                    if(coborrowerGenderMap != null){
                       coBorrowerWrapper.gender = coborrowerGenderMap.containsKey(applicantId) ? (String)coborrowerGenderMap.get(applicantId) : '';
                    }else{
                       coBorrowerWrapper.gender = '';
                  }
                }
                System.debug('coBorrowersWrapperList-2-->'+coBorrowersWrapperList);
                Map<String,String> documentIdVsContentDocIdMap = new Map<String,String>();
                annexureWrapperList = new List<AnnexureWrapper>();
                if(documentIdSet!=null && !documentIdSet.isEmpty()){
                    List<ContentDocumentLink> contentDocLinkList = [SELECT LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE (LinkedEntityId IN:documentIdSet) WITH SECURITY_ENFORCED LIMIT 10000];
                    Set<Id> contentDocIdSet = new Set<Id>();
                    for (Id doc : documentIdSet) {
                        for(ContentDocumentLink conLinkObj:contentDocLinkList){
                            if(doc!=null && doc==conLinkObj.LinkedEntityId){
                                documentIdVsContentDocIdMap.put(doc, conLinkObj.ContentDocumentId);
                            }
                            contentDocIdSet.add(conLinkObj.ContentDocumentId);
                        }
                    }
                    
                    List<ContentDocument> contentDocList = [SELECT LatestPublishedVersionId,Title FROM ContentDocument WHERE Id IN:contentDocIdSet WITH SECURITY_ENFORCED ORDER BY CreatedDate ASC LIMIT 10000];
                    for(ContentDocument contentDoc:contentDocList){
                        if(resiFiCoBorrowerDoc!=null && documentIdVsContentDocIdMap.containsKey(resiFiCoBorrowerDoc.Id) && contentDoc.Id==documentIdVsContentDocIdMap.get(resiFiCoBorrowerDoc.Id)){
                            coBorrowerResiFi = contentDoc.LatestPublishedVersionId;
                        }
                        if(opploan.Product_Type__c == 'Tractor'){
                            for(Id applicant: coBorrowersWrapperMap.keySet()){
                                if(coBorrowersWrapperMap.get(applicant).resiFiCoBorrowerDocMul != null && documentIdVsContentDocIdMap.containsKey(coBorrowersWrapperMap.get(applicant).resiFiCoBorrowerDocMul.Id)
                                 && contentDoc.Id==documentIdVsContentDocIdMap.get(coBorrowersWrapperMap.get(applicant).resiFiCoBorrowerDocMul.Id)){
                                    coBorrowersWrapperMap.get(applicant).coBorrowerResiFiMul = contentDoc.LatestPublishedVersionId;
                                 }
                            }
                        }
                        if(resiFiBorrowerDoc!=null && documentIdVsContentDocIdMap.containsKey(resiFiBorrowerDoc.Id) && contentDoc.Id==documentIdVsContentDocIdMap.get(resiFiBorrowerDoc.Id)){
                            borrowerResiFi = contentDoc.LatestPublishedVersionId;
                        }
                        if(resiFiGuarantorDoc!=null && documentIdVsContentDocIdMap.containsKey(resiFiGuarantorDoc.Id) && contentDoc.Id==documentIdVsContentDocIdMap.get(resiFiGuarantorDoc.Id)){
                            guarantorResiFi = contentDoc.LatestPublishedVersionId;
                        }
                        if(officeFiBorrowerDoc!=null && documentIdVsContentDocIdMap.containsKey(officeFiBorrowerDoc.Id) && contentDoc.Id==documentIdVsContentDocIdMap.get(officeFiBorrowerDoc.Id)){
                            borrowerOfficeFi = contentDoc.LatestPublishedVersionId;
                        }
                        if(officeFiCoBorrowerDoc!=null && documentIdVsContentDocIdMap.containsKey(officeFiCoBorrowerDoc.Id) && contentDoc.Id==documentIdVsContentDocIdMap.get(officeFiCoBorrowerDoc.Id)){
                            coBorrowerOfficeFi = contentDoc.LatestPublishedVersionId;
                        }
                        if(officeFiGuarantorDoc!=null && documentIdVsContentDocIdMap.containsKey(officeFiGuarantorDoc.Id) && contentDoc.Id==documentIdVsContentDocIdMap.get(officeFiGuarantorDoc.Id)){
                            guarantorOfficeFi = contentDoc.LatestPublishedVersionId;
                        }
                        if(opploan.Product_Type__c == 'Tractor'){
                            for(Id applicant: coBorrowersWrapperMap.keySet()){
                                if(coBorrowersWrapperMap.get(applicant).officeFiCoBorrowerDocMul != null && documentIdVsContentDocIdMap.containsKey(coBorrowersWrapperMap.get(applicant).officeFiCoBorrowerDocMul.Id)
                                 && contentDoc.Id==documentIdVsContentDocIdMap.get(coBorrowersWrapperMap.get(applicant).officeFiCoBorrowerDocMul.Id)){
                                    coBorrowersWrapperMap.get(applicant).coBorrowerOfficeFiMul = contentDoc.LatestPublishedVersionId;
                                 }
                            }
                        }
                    }
                    Set<String> excludedDocumentTypeSet = new Set<String>{System.Label.PanCards, System.Label.Form60DocumentType, System.Label.VoterIdCard, System.Label.AadhaarCard,System.Label.AddressDeclaration, System.Label.DrivingLicences, System.Label.PassportCard, System.Label.CustomerImageDocumentType};
                    for(Documents__c docObj:document){
                        if((docObj.Document_Type__c != null && !excludedDocumentTypeSet.contains(docObj.Document_Type__c)) && docObj.Is_Active__c == true){//CISP-2911
                            for (ContentDocument contentDoc : contentDocList) {
                                if(documentIdVsContentDocIdMap!=null && documentIdVsContentDocIdMap.containsKey(docObj.Id) && documentIdVsContentDocIdMap.get(docObj.Id)==contentDoc.Id){
                                    AnnexureWrapper wrapperObj = new AnnexureWrapper();
                                    wrapperObj.documentName = docObj.Name;
                                    wrapperObj.documentType = docObj.Document_Type__c;
                                    wrapperObj.fileId = contentDoc.LatestPublishedVersionId;
                                    annexureWrapperList.add(wrapperObj);
                                }
                            }
                        }
                    }
                }
                
                List<Documents__c> docBorrowerList = new List<Documents__c>();
                docBorrowerList = [SELECT id,KYC_DOB__c FROM Documents__c Where Opportunity_Relation__c =:recordId AND Applicant__r.Applicant_Type__c='Borrower' WITH SECURITY_ENFORCED LIMIT 1];
                docBorrower = docBorrowerList.size() > 0 ? docBorrowerList[0] : new Documents__c();
                
                List<Documents__c> docCoBorrowerList = new List<Documents__c>();
                docCoBorrowerList = [SELECT id,KYC_DOB__c FROM Documents__c Where Opportunity_Relation__c =:recordId AND Applicant__r.Applicant_Type__c='Co-borrower' WITH SECURITY_ENFORCED LIMIT 1];
                docCoBorrower = docCoBorrowerList.size() > 0 ? docCoBorrowerList[0] : new Documents__c();
                
                // Exposure
                haveFamilyExposure = false;
                haveAdditionalExposure = false;
                borrowerExposureList = new List<Exposure__c>();
                coBorrowerExposureList = new List<Exposure__c>();
                additionalExposureNameSet = new Set<String>();
                familyExposureNameSet = new Set<String>();
                lstAdditionalExpCustCodes = new Map<String, List<Exposure__c>>();
                lstFamilylExpCustCodes = new Map<String, List<Exposure__c>>();
                List<Exposure__c> expList = new List<Exposure__c>();
                expList = [SELECT Id,Name,Exposure_Type__c,Applicant__c,Applicant__r.Applicant_Type__c,Loan_Application__r.Loan_amount__c,Loan_Application__r.Sub_Stage__c,Deal_Stage__c,Deal_No__c,Deal_Date__c,Product__c,Product_Variant_Name__c,
                           Used__c,Status_Flag__c,Finance_Amt__c,Over_Due__c, AD__c, PD__c,
                           Customer_Code__c,Customer_Code__r.Name,Customer_Code__r.Customer_Name__c,Applicant__r.Customer_Code__c,Applicant__r.Name, //CISP-2443
                           Current_Demand__c,Mor1__c, Mor2__c, Sanctioned_Amt__c, SOH__c, Type__c,RCNo__c,IB_Seasoning__c
                           from Exposure__c where Loan_Application__c = :cam.Loan_Application__c WITH SECURITY_ENFORCED LIMIT 1000];
                if(expList.size()>0){
                    List<Lien_Detail__c> lienRecordList = new List<Lien_Detail__c>();
                    lienRecordList = [SELECT Id, Name, Lien_Type__c, Lien_Maker_Date__c, Lien_Marking_Period__c, Deal_No__c, Deal_No__r.Name, Lien_Request_By__c, Lien_Marking_Reason__c FROM Lien_Detail__c WHERE Deal_No__c IN:expList WITH SECURITY_ENFORCED LIMIT 1000];
                    lienList = lienRecordList.size() > 0 ? lienRecordList : new List<Lien_Detail__c>();
                    for (Exposure__c expObj : expList) {
                        if(expObj.Type__c  == System.Label.Borrower_Exposure){ 
                            existingBorrowerExposureAmount =expObj.SOH__c !=null ? existingBorrowerExposureAmount + (Decimal)expObj.SOH__c:existingBorrowerExposureAmount;
                            borrowerExposureList.add(expObj);
                        }
                        if(expObj.Type__c  == System.Label.Co_Borrower_Exposure){
                            existingCoBorrowerExposureAmount = expObj.SOH__c !=null ? existingCoBorrowerExposureAmount + (Decimal)expObj.SOH__c:existingCoBorrowerExposureAmount;
                            coBorrowerExposureList.add(expObj);
                        }
                        if(expObj.Type__c  == System.Label.Additional_Customer){
                            existingOtherExposureAmount = expObj.SOH__c !=null ? existingOtherExposureAmount + (Decimal)expObj.SOH__c:existingOtherExposureAmount;
                            if(expObj.Customer_Code__c != null){
                                string key =expObj.Customer_Code__r.Name+' - '+expObj.Customer_Code__r.Customer_Name__c;
                                if(lstAdditionalExpCustCodes.containsKey(key)){
                                    List<Exposure__c> exposureList = lstAdditionalExpCustCodes.get(key);
                                    exposureList.add(expObj);
                                    lstAdditionalExpCustCodes.put(key, exposureList);
                                }else{                        
                                    lstAdditionalExpCustCodes.put(key, new List<Exposure__c>{expObj});
                                    haveAdditionalExposure = true;
                                }
                            }else if(expObj.Applicant__c != null){
                                string key = expObj.Applicant__r.Customer_Code__c +' - '+expObj.Applicant__r.Name;
                                if(lstAdditionalExpCustCodes.containsKey(key)){
                                    List<Exposure__c> exposureList = lstAdditionalExpCustCodes.get(key);
                                    exposureList.add(expObj);
                                    lstAdditionalExpCustCodes.put(key, exposureList);
                                }else{
                                    lstAdditionalExpCustCodes.put(key, new List<Exposure__c>{expObj});
                                    haveAdditionalExposure = true;
                                }
                            }
                            if (lstAdditionalExpCustCodes!=null) {
                                additionalExposureNameSet.addall(lstAdditionalExpCustCodes.keyset());
                            }
                        }
                        if(expObj.Type__c  == System.Label.Bank_Exposure){
                            bankExposureAmount = expObj.Sanctioned_Amt__c != null? bankExposureAmount + (Decimal)expObj.Sanctioned_Amt__c:bankExposureAmount;
                        }
                        if (expObj.Type__c  == System.Label.Family_Exposure) {
                            if(expObj.Customer_Code__c != null){
                                string key =expObj.Customer_Code__r.Name+' - '+expObj.Customer_Code__r.Customer_Name__c;
                                if(lstFamilylExpCustCodes.containsKey(key)){
                                    List<Exposure__c> exposureList = lstFamilylExpCustCodes.get(key);
                                    exposureList.add(expObj);
                                    lstFamilylExpCustCodes.put(key, exposureList);
                                }else{                        
                                    lstFamilylExpCustCodes.put(key, new List<Exposure__c>{expObj});
                                    haveFamilyExposure = true;
                                }
                            }else if(expObj.Applicant__c != null){
                                string key = expObj.Applicant__r.Customer_Code__c +' - '+expObj.Applicant__r.Name;
                                if(lstFamilylExpCustCodes.containsKey(key)){
                                    List<Exposure__c> exposureList = lstFamilylExpCustCodes.get(key);
                                    exposureList.add(expObj);
                                    lstFamilylExpCustCodes.put(key, exposureList);
                                }else{
                                    lstFamilylExpCustCodes.put(key, new List<Exposure__c>{expObj});
                                    haveFamilyExposure = true;
                                }
                            }
                            if (lstFamilylExpCustCodes!=null) {
                                familyExposureNameSet.addall(lstFamilylExpCustCodes.keyset());
                            }
                        }
                        // if(expObj.Type__c  == System.Label.Bank_Exposure){
                        //     bankExposureAmount = expObj.SOH__c !=null ? bankExposureAmount + (Decimal)expObj.SOH__c:bankExposureAmount;;
                        // }
                    }
                }
                //CISP-15712 start
                Boolean isCoborrowerRelationMatch = false;
                List<String> relationWithBorrowerList = new List<String>{'BROTHER - IN LAW' , 'BROTHER - INCLUDING STEP BROTHER' , 'DAUGHTER - INCLUDING STEP DAUGHTER' , 'FATHER' , 'GRANDDAUGHTER' , 'GRANDSON' , 'HUSBAND', 'HUSBAND OF GRANDDAUGHTER',
                'HUSBAND OF SISTER' , 'MATERNAL GRANDFATHER' ,'MATERNAL GRANDMOTHER' , 'MEMBER OF HINDU UNDIVIDED FAMILY' , 'MOTHER -INCLUDING STEP MOTHER' , 'PATERNAL GRANDFATHER',
                'PATERNAL GRANDMOTHER', 'SISTER - IN LAW', 'SISTER - INCLUDING STEP SISTER' , 'SON - INCLUDING STEP SON', 'SON WIFE' , 'WIFE' , 'WIFE OF BROTHER' , 'WIFE OF GRANDSON'};
                for(Applicant__c applicantRecord : [SELECT Id,Relationship_with_borrower__c,Applicant_Type__c
                                                From Applicant__c                                                
                                                Where Opportunity__c =:cam.Loan_Application__c and In_Active_Applicant__c =false WITH SECURITY_ENFORCED])
                {
                    //CISP-7987
                    if(applicantRecord.Applicant_Type__c == 'Co-borrower'){
                        if(relationWithBorrowerList.contains(applicantRecord.Relationship_with_borrower__c)){
                            isCoborrowerRelationMatch = true;
                        }
                    }
                }
                if(isCoborrowerRelationMatch == false){
                    existingCoBorrowerExposureAmount = 0;//CISP-7987
                } //CISP-15712 end
                totalExposureAmount = existingBorrowerExposureAmount +existingCoBorrowerExposureAmount+bankExposureAmount+existingOtherExposureAmount+currentExposureAmount;
                
                exp = expList.size() > 0 ? expList[0] : new Exposure__c();
                List<External_CAM_Data__c> nonIBLExDataList = new List<External_CAM_Data__c>();
                Id nonIBLExposureId = Schema.SObjectType.External_CAM_Data__c.getRecordTypeInfosByDeveloperName().get('Non_IBL_Exposure').getRecordTypeId();
                nonIBLExDataList = [SELECT Id, Name__c, Account_Type_Desc__c, Ownership__c, HighCredit__c, CurrentBalance__c, AmountOverdue__c, ReasonforOverdue__c, Customer_Type__c, Open_Date__c, Last_Payment_Date__c FROM External_CAM_Data__c WHERE CAM__c =:camRecordId AND RecordTypeId =: nonIBLExposureId];
                nonIBLExList = nonIBLExDataList.size() > 0 ? nonIBLExDataList : new List<External_CAM_Data__c>();
                // Case
                List<Case> caseList = new List<Case>();
                caseList = [SELECT Id,RecordType.Name,Type,Applicant__c,Applicant__r.Applicant_Type__c FROM Case WHERE Loan_Application__c = :recordId WITH SECURITY_ENFORCED];
                if(opploan.Product_Type__c == System.Label.Tractor){
                    for(Case caseObj : caseList){
                        if(caseObj.RecordType.Name == 'FI' && caseObj.Type == 'Current Residence FI' && caseObj.Applicant__r.Applicant_Type__c == System.Label.Borrower){
                            borrowerResiFi = caseObj.Id;
                        }else if(caseObj.RecordType.Name == 'FI' && caseObj.Type == 'Office FI' && caseObj.Applicant__r.Applicant_Type__c == System.Label.Borrower){
                            borrowerOfficeFi = caseObj.Id;
                        }else if(caseObj.RecordType.Name == 'FI' && caseObj.Type == 'Current Residence FI' && (caseObj.Applicant__r.Applicant_Type__c == System.Label.CoBorrower || caseObj.Applicant__r.Applicant_Type__c==Label.Beneficiary)&& coBorrowersWrapperMap.containsKey(caseObj.Applicant__c)){
                            coBorrowersWrapperMap.get(caseObj.Applicant__c).coBorrowerResiFiMul = caseObj.Id;
                        }else if(caseObj.RecordType.Name == 'FI' && caseObj.Type == 'Current Residence FI' && caseObj.Applicant__r.Applicant_Type__c == System.Label.Guarantor){
                            guarantorResiFi = caseObj.Id;
                        }else if(caseObj.RecordType.Name == 'RCU' && caseObj.Type == 'RCU'){//SFTRAC-1271
                            rcuCaseRecordId = caseObj.Id;
                        }//SFTRAC-1271
                    }
                }
                
                // Final Investigation
                List<Field_Investigation__c> fieldInvestigationList = new List<Field_Investigation__c>();
                if (caseList.size() > 0) {
                    fieldInvestigationList = [SELECT id,House_ownership__c,how_long_he_is_residing_kyc_address__c,Distance_from_Branch_to_customer__c,Same_Addresst_as_in_the_Application__c,Business_Premise__c,Residence_Type__c,Years_in_CIty__c,Number_of_years_in_city_in_years__c,Years_in_Residence__c,RecordType.Name,RecordTypeId,Coordinates_Distance__c,Coordinates_Verified__c,FI_Status__c,Total_Experience_Years__c,Employer_Business_Name__c,Office_Business_Type__c,Name_of_Person_met__c,Customer_house_same_as_in_application__c,Remarks__c,Case__r.Applicant__c,Case__r.Applicant__r.Applicant_Type__c,Monthly_Income_as_per_FI_Visit__c,Office_ownership__c, Nature_of_Business_Major_Industry__c ,Nature_of_Business_Minor_Industry__c,Case__r.Applicant__r.Name, Person_Met__c,Current_Addr_is_different_than_KYC_Addr__c  FROM Field_Investigation__c WHERE Case__c IN :caseList LIMIT 1000]; 
                    Boolean borrowerFi = false;
                    Boolean coborrowerFi = false;
                    Boolean borrowerOfficeFi = false;
                    Boolean coborrowerOfficeFi = false;
                    Boolean borrowerPermanentFi = false;
                    Boolean coborrowerPermanentFi = false;
                    Boolean guarantorPermanentFi = false;
                    Boolean guarantorOfficeFi = false;
                    Boolean guarantorResidenceFi = false;

                    for (Field_Investigation__c fiVar : fieldInvestigationList) {
                        if(fiVar.Case__r.Applicant__c!=null && fiVar.Case__r.Applicant__r.Applicant_Type__c=='Borrower' && borrowerFi==false && fiVar.RecordTypeId!=null && fiVar.RecordType.Name=='Residence'){
                            FI = fiVar;
                            borrowerFi = true;
                        }
                        if(fiVar.Case__r.Applicant__c!=null && fiVar.Case__r.Applicant__r.Applicant_Type__c=='Borrower' && borrowerOfficeFi==false && fiVar.RecordTypeId!=null && fiVar.RecordType.Name=='Office'){
                            officeFI = fiVar;
                            borrowerOfficeFi = true;
                            if(opploan.leadSource =='D2C'){
                                if(fiVar.Monthly_Income_as_per_FI_Visit__c!=null){
                                    netAnnualIncome=fiVar.Monthly_Income_as_per_FI_Visit__c * 12;  
                                }
                            }
                        }
                        if(fiVar.Case__r.Applicant__c!=null && fiVar.Case__r.Applicant__r.Applicant_Type__c=='Borrower' && borrowerPermanentFi==false && fiVar.RecordTypeId!=null && fiVar.RecordType.Name=='Permanent'){
                            permanentFI = fiVar;
                            borrowerPermanentFi = true;
                        }
                        if(fiVar.Case__r.Applicant__c!=null && fiVar.Case__r.Applicant__r.Applicant_Type__c=='Co-borrower' && coborrowerFi==false && fiVar.RecordTypeId!=null && fiVar.RecordType.Name=='Residence'){
                            coFI = fiVar;
                            coborrowerFi = true;
                            //SFTRAC-1789 Start
                            if(coBorrowersWrapperMap.containsKey(fiVar.Case__r.Applicant__c) && this.productType == System.Label.Tractor){
                                CoBorrowerWrapper coBorrowerPermanentFIWrapper = coBorrowersWrapperMap.get(fiVar.Case__r.Applicant__c);
                                coBorrowerPermanentFIWrapper.nameOfPersonMet = fiVar.Person_Met__c != null ? String.valueOf(fiVar.Person_Met__c) : '';
                                coBorrowerPermanentFIWrapper.customerHouseSameAsInApplication = fiVar.Current_Addr_is_different_than_KYC_Addr__c != null ? fiVar.Current_Addr_is_different_than_KYC_Addr__c == 'Yes' ? false : true : false;
                                coBorrowersWrapperMap.put(fiVar.Case__r.Applicant__c,coBorrowerPermanentFIWrapper);
                            }
                            //SFTRAC-1789 End
                        }
                        //Added for Co-brower Residence Details section start
                        if(fiVar.Case__r.Applicant__c!=null && (fiVar.Case__r.Applicant__r.Applicant_Type__c=='Co-borrower' ||fiVar.Case__r.Applicant__r.Applicant_Type__c=='Beneficiary') && fiVar.RecordTypeId!=null && fiVar.RecordType.Name=='Residence'){
                            if(coBorrowersWrapperMap.containsKey(fiVar.Case__r.Applicant__c)){
                            CoBorrowerWrapper coBorrowerResidenceFIWrapper = coBorrowersWrapperMap.get(fiVar.Case__r.Applicant__c);
                            if(!oppLoanList.isEmpty() && oppLoanList[0].Product_Type__c==Label.Tractor){
                               coBorrowerResidenceFIWrapper.residenceType = fiVar.House_ownership__c != '' ? fiVar.House_ownership__c : '';
                               coBorrowerResidenceFIWrapper.yearsInResidence = fiVar.how_long_he_is_residing_kyc_address__c != '' ? fiVar.how_long_he_is_residing_kyc_address__c : '';
                                coBorrowerResidenceFIWrapper.distanceFromBranch=fiVar.Distance_from_Branch_to_customer__c  != '' ? fiVar.Distance_from_Branch_to_customer__c  : '';
                                if(opploan.Product_Type__c == 'Tractor'){
                                    coBorrowerResidenceFIWrapper.yearsInCIty = fiVar.Number_of_years_in_city_in_years__c != null ? String.valueof(fiVar.Number_of_years_in_city_in_years__c) : '';
                                }else{
                                    coBorrowerResidenceFIWrapper.yearsInCIty = fiVar.Years_in_CIty__c != '' ? fiVar.Years_in_CIty__c : '';
                                }
 
                            }else{
                             coBorrowerResidenceFIWrapper.residenceType = fiVar.Residence_Type__c != '' ? fiVar.Residence_Type__c : '';
                           	 coBorrowerResidenceFIWrapper.yearsInResidence = fiVar.Years_in_Residence__c != '' ? fiVar.Years_in_Residence__c : '';
                             if(opploan.Product_Type__c == 'Tractor'){
                                coBorrowerResidenceFIWrapper.yearsInCIty = fiVar.Number_of_years_in_city_in_years__c != null ? String.valueof(fiVar.Number_of_years_in_city_in_years__c) : '';
                             }else{
                                coBorrowerResidenceFIWrapper.yearsInCIty = fiVar.Years_in_CIty__c != '' ? fiVar.Years_in_CIty__c : '';
                             }
                            }
                           coBorrowerResidenceFIWrapper.resCoordinatesVerified = fiVar.Coordinates_Verified__c != '' ? fiVar.Coordinates_Verified__c : '';
                            }
                        }
                        // System.debug('coBorrowersWrapperList-3-->'+coBorrowersWrapperList);
                        //Added for Co-brower Residence Details section end
                        //Added for Guarantor Residence Details section start
                        
                        if(fiVar.Case__r.Applicant__c!=null && fiVar.Case__r.Applicant__r.Applicant_Type__c=='Guarantor' && coborrowerFi==false && fiVar.RecordTypeId!=null && fiVar.RecordType.Name=='Residence'){
                            residenceGuarantorFI = fiVar;
                            guarantorResidenceFi = true;
                        }
                        //Added for Guarantor Residence Details section end
                        if(fiVar.Case__r.Applicant__c!=null && fiVar.Case__r.Applicant__r.Applicant_Type__c=='Co-borrower' && coborrowerOfficeFi==false && fiVar.RecordTypeId!=null && fiVar.RecordType.Name=='Office'){
                            officeCoFI = fiVar;
                            coborrowerOfficeFi = true;
                            if(opploan.leadSource =='D2C'){
                                if(fiVar.Monthly_Income_as_per_FI_Visit__c!=null){
                                    if(netAnnualIncome == null){
                                        netAnnualIncome=fiVar.Monthly_Income_as_per_FI_Visit__c * 12;
                                    } 
                                }
                            }
                        }
                        //Added for Co-brower Business Details section start
                        if(fiVar.Case__r.Applicant__c!=null && fiVar.Case__r.Applicant__r.Applicant_Type__c=='Co-borrower' && fiVar.RecordTypeId!=null && fiVar.RecordType.Name=='Office'){
                            CoBorrowerWrapper coBorrowerOfficeFIWrapper = coBorrowersWrapperMap.get(fiVar.Case__r.Applicant__c);
                            coBorrowerOfficeFIWrapper.employerBusinessName = fiVar.Employer_Business_Name__c != '' ? fiVar.Employer_Business_Name__c : '';
                            coBorrowerOfficeFIWrapper.officeBusinessType = fiVar.Office_Business_Type__c != '' ? fiVar.Office_Business_Type__c : '';
                            coBorrowerOfficeFIWrapper.totalExperienceYears = fiVar.Total_Experience_Years__c != '' ? fiVar.Total_Experience_Years__c : '';
                            
                            coBorrowerOfficeFIWrapper.businessPremise = fiVar.Business_Premise__c != '' ? fiVar.Business_Premise__c : '';
                            coBorrowerOfficeFIWrapper.coordinatesVerified = fiVar.Coordinates_Verified__c != '' ? fiVar.Coordinates_Verified__c : '';
                        }
                        // System.debug('coBorrowersWrapperList-4-->'+coBorrowersWrapperList);
                        //Added for Co-brower Business Details section end
                        //Added for Guarantor Business Details section start
                        if(fiVar.Case__r.Applicant__c!=null && fiVar.Case__r.Applicant__r.Applicant_Type__c=='Guarantor' && coborrowerOfficeFi==false && fiVar.RecordTypeId!=null && fiVar.RecordType.Name=='Office'){
                            officeGuarantorFI = fiVar;
                            guarantorOfficeFi = true;
                        }
                        //Added for Guarantor Business Details section end
                        if(fiVar.Case__r.Applicant__c!=null && fiVar.Case__r.Applicant__r.Applicant_Type__c=='Co-borrower' && coborrowerPermanentFi==false && fiVar.RecordTypeId!=null && fiVar.RecordType.Name=='Permanent'){
                            permanentCoFI = fiVar;
                            coborrowerPermanentFi = true;
                        }
                        //Added for Co-brower FI Details-Home section start
                        if(fiVar.Case__r.Applicant__c!=null && fiVar.Case__r.Applicant__r.Applicant_Type__c=='Co-borrower' && fiVar.RecordTypeId!=null && fiVar.RecordType.Name=='Permanent'){
                            // CoBorrowerWrapper coBorrowerPermanentFIWrapper = coBorrowersWrapperMap.get(fiVar.Case__r.Applicant__c);
                            // coBorrowerPermanentFIWrapper.nameOfPersonMet = fiVar.Name_of_Person_met__c != '' ? fiVar.Name_of_Person_met__c : '';
                            // coBorrowerPermanentFIWrapper.customerHouseSameAsInApplication = fiVar.Customer_house_same_as_in_application__c != false ? fiVar.Customer_house_same_as_in_application__c : false;
                            // coBorrowerPermanentFIWrapper.remarks = fiVar.Remarks__c != '' ? fiVar.Remarks__c : '';
                            // coBorrowerPermanentFIWrapper.coordinatesVerified = fiVar.Coordinates_Verified__c != '' ? fiVar.Coordinates_Verified__c : '';
                        }
                        // System.debug('coBorrowersWrapperList-5-->'+coBorrowersWrapperList);
                        //Added for Co-brower FI Details-Home section end
                        //Added for Guarantor FI Details-Home section start
                        if(fiVar.Case__r.Applicant__c!=null && fiVar.Case__r.Applicant__r.Applicant_Type__c=='Guarantor' && coborrowerPermanentFi==false && fiVar.RecordTypeId!=null && fiVar.RecordType.Name=='Permanent'){
                            permanentGuarantorFI = fiVar;
                            guarantorPermanentFi = true;
                        }
                        //Added for Guarantor FI Details-Home section end
                        // System.debug('fiVar.Case__r.Applicant__r.Applicant_Type__c - '+fiVar.Case__r.Applicant__r.Applicant_Type__c);
                    }
                    // System.debug('coBorrowersWrapperList -6 '+coBorrowersWrapperList);
                }
                // FI = fieldInvestigationList.size() > 0 ? fieldInvestigationList[0] : new Field_Investigation__c();
                
                // Income Details
                List<Income_Details__c> incomeBorrowerList = new List<Income_Details__c>();
                incomeBorrowerList = [SELECT id,Legal__c,Income_Source_Status__c,ABB_to_be_considered__c,Income_from_Perfios__c,Name_of_Recipient_Bank__c,Name_of_Recipient_Banks__r.name,Employer_Business_Name__c,Current_Years_in_employment_business__c,Total_Years_in_employment_business__c,Profile__c,BSR_Occupation__c,Is_Income_Credited_In_Bank_Account__c,Do_You_File_ITR__c,Unique_Registration_Number__c,Is_ICAI__c,Is_MCI__c,Is_ICWAI__c,Income__c,Profile__r.Name,Profile__r.Category__c,Is_Salaried__c,Is_Self_Employed__c,Incomeproof__c FROM Income_Details__c WHERE Applicant__c = :appBorrower.Id AND  Applicant__r.Applicant_Type__c = 'Borrower' WITH SECURITY_ENFORCED LIMIT 1000];
                incomeBorrower = incomeBorrowerList.size() > 0 ? incomeBorrowerList[0] : new Income_Details__c();
                if(incomeBorrowerList.size() > 0){
                    borrowerProfile=incomeBorrowerList[0].Profile__r.Name;
                    borrowerCategory=incomeBorrowerList[0].Profile__r.Category__c;
                }else{
                    borrowerProfile=appBorrower.Profile__c;
                    borrowerCategory=appBorrower.Customer_Category__c;
                }
                borrowerEmpType = incomeBorrower.Is_Salaried__c == true ? 'Salaried' : incomeBorrower.Is_Self_Employed__c == true ? 'Self Employed' : '';
                if(incomeBorrower.Is_ICWAI__c){
                    registeredIncome+=' ICWAI ';
                }
                if(incomeBorrower.Is_MCI__c){
                    registeredIncome+=' MCI ';
                }
                if(incomeBorrower.Is_ICAI__c){
                    registeredIncome+=' ICAI ';
                }

                Decimal borrowerAbbRatio = 0;
                evaluationtypeBorrower = 'Income Proof';
                for(Income_Details__c income:incomeBorrowerList){
                    if(income.ABB_to_be_considered__c!=null){
                        borrowerAbbRatio+=Decimal.valueOf(income.ABB_to_be_considered__c);
                    }
                    if(opploan.leadSource == 'D2C' && (income.Income_Source_Status__c == 'NIP' || income.Incomeproof__c == 'NIP')){
                        evaluationtypeBorrower = 'Non Income Proof';
                    }
                }

                if(opploan.leadSource != 'D2C' || evaluationtypeBorrower == 'Income Proof'){
                    netAnnualIncome = incomeBorrower.Income__c;
                } 

                borrowerABB = borrowerAbbRatio!=0?String.valueOf(borrowerAbbRatio):'N/A';
            if(opploan.Product_Type__c!='Tractor'){
                List<Income_Details__c> incomeCoBorrowerList = new List<Income_Details__c>();
                incomeCoBorrowerList = [SELECT id,Legal__c,Income_Source_Status__c,ABB_to_be_considered__c,Income_from_Perfios__c,Name_of_Recipient_Bank__c,Name_of_Recipient_Banks__r.name,Employer_Business_Name__c,Current_Years_in_employment_business__c,Income__c,Total_Years_in_employment_business__c,Profile__c,BSR_Occupation__c,Is_Income_Credited_In_Bank_Account__c,Do_You_File_ITR__c,Profile__r.Name,Profile__r.Category__c,Is_Salaried__c,Is_Self_Employed__c,Incomeproof__c,Applicant__r.Applicant_Type__c FROM Income_Details__c WHERE Applicant__r.Applicant_Type__c IN ('Co-borrower') AND Applicant__r.In_Active_Applicant__c = false AND Applicant__r.Opportunity__r.Id =: recordId WITH SECURITY_ENFORCED LIMIT 1000];
                incomeCoBorrower = incomeCoBorrowerList.size() > 0 ? incomeCoBorrowerList[0] : new Income_Details__c();
                if(incomeCoBorrowerList.size() > 0){
                    coBorrowerProfile=incomeCoBorrowerList[0].Profile__r.Name;
                    coBorrowerCategory=incomeCoBorrowerList[0].Profile__r.Category__c;
                }else{
                    coBorrowerProfile=appCoBorrower.Profile__c;
                    coBorrowerCategory=appCoBorrower.Customer_Category__c;
                }
                coborrowerEmpType = incomeCoBorrower.Is_Salaried__c == true ? 'Salaried' : incomeCoBorrower.Is_Self_Employed__c == true ? 'Self Employed' : '';
                Decimal coborrowerAbbRatio = 0;
                evaluationtypeCoBorrower = 'Income Proof';
                for(Income_Details__c income:incomeCoBorrowerList){
                    if(income.ABB_to_be_considered__c!=null){
                        coborrowerAbbRatio+=Decimal.valueOf(income.ABB_to_be_considered__c);
                    }
                    if(opploan.leadSource == 'D2C' && (income.Income_Source_Status__c == 'NIP' || income.Incomeproof__c == 'NIP')){
                        evaluationtypeCoBorrower = 'Non Income Proof';
                    }
                }

                if(opploan.leadSource != 'D2C' || evaluationtypeCoBorrower == 'Income Proof'){
                    if(netAnnualIncome == null){
                        netAnnualIncome = incomeCoBorrower.Income__c;
                    } 
                }

                coborrowerABB = coborrowerAbbRatio!=0?String.valueOf(coborrowerAbbRatio):'N/A';
            }else if(opploan.Product_Type__c == 'Tractor' && opploan.Customer_Type__c == 'Non-Individual'){
                    Map<Id,Decimal> nonAgrIncomeMap = new Map<Id,Decimal>();
                    for(Non_Agri_Income__c nonAgriObj : [SELECT Total_Income__c,Field_Investigation__r.Case__r.Applicant__c from Non_Agri_Income__c where Field_Investigation__r.Case__r.Loan_Application__c  =: opploan.Id AND Field_Investigation__r.Case__r.Type = 'Current Residence FI']){
                        if(nonAgrIncomeMap.containsKey(nonAgriObj.Field_Investigation__r.Case__r.Applicant__c)){
                            nonAgrIncomeMap.put(nonAgriObj.Field_Investigation__r.Case__r.Applicant__c,nonAgrIncomeMap.get(nonAgriObj.Field_Investigation__r.Case__r.Applicant__c) + (nonAgriObj.Total_Income__c == null ? 0 : nonAgriObj.Total_Income__c));
                        }else{
                            nonAgrIncomeMap.put(nonAgriObj.Field_Investigation__r.Case__r.Applicant__c,(nonAgriObj.Total_Income__c == null ? 0 : nonAgriObj.Total_Income__c));
                        }
                    }
                    for(Viability_of_Existing_Proposed_Tractor__c vibExiProTraObj : [SELECT Total_Income__c,Field_Investigation__r.Case__r.Applicant__c from Viability_of_Existing_Proposed_Tractor__c where Field_Investigation__r.Case__r.Loan_Application__c  =: opploan.Id AND Field_Investigation__r.Case__r.Type = 'Current Residence FI']){
                        if(nonAgrIncomeMap.containsKey(vibExiProTraObj.Field_Investigation__r.Case__r.Applicant__c)){
                            nonAgrIncomeMap.put(vibExiProTraObj.Field_Investigation__r.Case__r.Applicant__c,nonAgrIncomeMap.get(vibExiProTraObj.Field_Investigation__r.Case__r.Applicant__c) + (vibExiProTraObj.Total_Income__c == null ? 0 : vibExiProTraObj.Total_Income__c));
                        }else{
                            nonAgrIncomeMap.put(vibExiProTraObj.Field_Investigation__r.Case__r.Applicant__c,(vibExiProTraObj.Total_Income__c == null ? 0 : vibExiProTraObj.Total_Income__c));
                        }
                    }
                    tfBorrowerIncome = new incomeWrapper();
                    tfCoGurIncomeList = new List<incomeWrapper>();
                    tfBenIncomeList = new List<incomeWrapper>();
                    for (Applicant__c applicantObj : appBorrowerList) {
                        tfBorrowerIncome.applicantTitle = applicantObj.Applicant_Type__c;
                        tfBorrowerIncome.legalEntity = opploan.Entity_Type__c == null ? '' : opploan.Entity_Type__c;
                        if(nonAgrIncomeMap.containsKey(applicantObj.id)){
                            tfBorrowerIncome.income = String.valueof(nonAgrIncomeMap.get(applicantObj.id));
                        }else{
                            tfBorrowerIncome.income = '';
                        }
                        tfBorrowerIncome.recipientBank = applicantObj.Income_Details__r.size() > 0 ? applicantObj.Income_Details__r[0].Income_Detail_Bank_Master__r.Name == null ? '' : applicantObj.Income_Details__r[0].Income_Detail_Bank_Master__r.Name : '';
                        tfBorrowerIncome.employeeType = 'N/A';
                        tfBorrowerIncome.businessName = applicantObj.Name == null ? '' : applicantObj.Name;
                        tfBorrowerIncome.profileName = applicantObj.Profile__c == null ? '' : applicantObj.Profile__c;
                    }

                    Integer benefCounter = 1;
                    Integer coboCounter = 1;
                    for (Applicant__c applicantObj : appCoBorrowerList) {
                        if(applicantObj.Applicant_Type__c == 'Beneficiary'){
                            incomeWrapper wrapperObj = new incomeWrapper();
                            wrapperObj.applicantTitle = applicantObj.Applicant_Type__c + ' ' + benefCounter;
                            wrapperObj.legalEntity = 'N/A';
                            if(nonAgrIncomeMap.containsKey(applicantObj.id)){
                                wrapperObj.income = String.valueof(nonAgrIncomeMap.get(applicantObj.id));
                            }else{
                                wrapperObj.income = '';
                            }
                            wrapperObj.recipientBank = applicantObj.Income_Details__r.size() > 0 ? applicantObj.Income_Details__r[0].Income_Detail_Bank_Master__r.Name == null ? '' : applicantObj.Income_Details__r[0].Income_Detail_Bank_Master__r.Name : '';
                            wrapperObj.employeeType = applicantObj.Salaried_Self_employed__c == null ? '' : applicantObj.Salaried_Self_employed__c;
                            wrapperObj.businessName = 'N/A';
                            wrapperObj.profileName = applicantObj.Profile__c == null ? '' : applicantObj.Profile__c;
                            tfBenIncomeList.add(wrapperObj);
                            benefCounter++;
                        }else if(applicantObj.Applicant_Type__c == Label.CoBorrower){
                            incomeWrapper wrapperObj = new incomeWrapper();
                            wrapperObj.applicantTitle = applicantObj.Applicant_Type__c + ' ' + coboCounter;
                            wrapperObj.legalEntity = 'N/A';
                            if(nonAgrIncomeMap.containsKey(applicantObj.id)){
                                wrapperObj.income = String.valueof(nonAgrIncomeMap.get(applicantObj.id));
                            }else{
                                wrapperObj.income = '';
                            }
                            wrapperObj.recipientBank = applicantObj.Income_Details__r.size() > 0 ? applicantObj.Income_Details__r[0].Income_Detail_Bank_Master__r.Name == null ? '' : applicantObj.Income_Details__r[0].Income_Detail_Bank_Master__r.Name : '';
                            wrapperObj.employeeType = applicantObj.Salaried_Self_employed__c == null ? '' : applicantObj.Salaried_Self_employed__c;
                            wrapperObj.businessName = 'N/A';
                            wrapperObj.profileName = applicantObj.Profile__c == null ? '' : applicantObj.Profile__c;
                            tfCoGurIncomeList.add(wrapperObj);
                        }
                    }
                    for (Applicant__c applicantObj : oppGuarantorsList) {
                        if(applicantObj.Applicant_Type__c == Label.Guarantor){
                            incomeWrapper wrapperObj = new incomeWrapper();
                            wrapperObj.applicantTitle = applicantObj.Applicant_Type__c;
                            wrapperObj.legalEntity = 'N/A';
                            if(nonAgrIncomeMap.containsKey(applicantObj.id)){
                                wrapperObj.income = String.valueof(nonAgrIncomeMap.get(applicantObj.id));
                            }else{
                                wrapperObj.income = '';
                            }
                            wrapperObj.recipientBank = applicantObj.Income_Details__r.size() > 0 ? applicantObj.Income_Details__r[0].Income_Detail_Bank_Master__r.Name == null ? '' : applicantObj.Income_Details__r[0].Income_Detail_Bank_Master__r.Name : '';
                            wrapperObj.employeeType = applicantObj.Salaried_Self_employed__c == null ? '' : applicantObj.Salaried_Self_employed__c;
                            wrapperObj.businessName = 'N/A';
                            wrapperObj.profileName = applicantObj.Profile__c == null ? '' : applicantObj.Profile__c;
                            tfCoGurIncomeList.add(wrapperObj);
                        }
                    }
                }
                List<Opportunity> loanApplicationList = [SELECT AccountId FROM Opportunity WHERE Id=:recordId LIMIT 1];
                deviationLevelVsUserIdList = new Map<String,Set<String>>();
                userIdVsLevelMap = new Map<String,String>();
                roleVsLevelMap = new Map<String,String>();
                if(!loanApplicationList.isEmpty() && loanApplicationList[0].AccountId!=null){
                    List<AccountTeamMember> accountTeamMemberList = [SELECT AccountId,Level__c,TeamMemberRole,UserId FROM AccountTeamMember WHERE AccountId=:loanApplicationList[0].AccountId WITH SECURITY_ENFORCED LIMIT 10000];
                    for (Deviation__c deviationObj : deviation) {
                        for(AccountTeamMember teamMemberObj:accountTeamMemberList){
                            if(deviationObj.Deviation_Level__c!= null && !deviationLevelVsUserIdList.containsKey(deviationObj.Deviation_Level__c)){
                                deviationLevelVsUserIdList.put(deviationObj.Deviation_Level__c, new Set<String>());
                            }
                            if(teamMemberObj.Level__c!=null && deviationObj.Deviation_Level__c!= null && teamMemberObj.Level__c>=deviationObj.Deviation_Level__c){
                                deviationLevelVsUserIdList.get(deviationObj.Deviation_Level__c).add(teamMemberObj.UserID);
                            }
                            
                        }
                        // if (deviationObj.Role__c != null) {
                        //     roleVsLevelMap.put(deviationObj.Role__c, null);
                        // }
                    }
                    // List<User> userList
                    
                    IBL_Configuration__mdt iblConfigObj = IBL_Configuration__mdt.getInstance('default');
                    String highestRole;
                    String highestTWRoles;
                    List<String> highestTWRolesList = new List<String>();
                    
                    if(opploan.Product_Type__c == 'Passenger Vehicles'){
                        highestRole = iblConfigObj.Highest_Authority_Role__c;
                    }
                    if(opploan.Product_Type__c == 'Two Wheeler' && iblConfigObj.Highest_Authority_Role_TW__c != null){
                        highestTWRoles = iblConfigObj.Highest_Authority_Role_TW__c;
                        highestTWRolesList = iblConfigObj.Highest_Authority_Role_TW__c.split(',');
                    }
                    String salesCapRole = iblConfigObj.Sales_Cap_Role__c;
                    String highestRoleLevel;
                    String salesCapRoleLevel;
                    
                    
                    for(AccountTeamMember teamMemberObj:accountTeamMemberList){
                        String[] tempStringList = teamMemberObj.Level__c!=null?teamMemberObj.Level__c.split(';'):null;
                        string highestLevel='L0';
                        if(tempStringList!=null){
                            for (String level : tempStringList) {
                                if(highestLevel==null){
                                    highestLevel = level;
                                }
                                if(level>highestLevel){
                                    highestLevel = level;
                                }
                            }
                        }
                        userIdVsLevelMap.put(teamMemberObj.UserId, highestLevel);
                        if (!roleVsLevelMap.containsKey(teamMemberObj.TeamMemberRole) || roleVsLevelMap.containsKey(teamMemberObj.TeamMemberRole) && roleVsLevelMap.get(teamMemberObj.TeamMemberRole) <  highestLevel ) {
                            roleVsLevelMap.put(teamMemberObj.TeamMemberRole, highestLevel);
                        }
                        
                        if(teamMemberObj.TeamMemberRole != null && highestRole != null && teamMemberObj.TeamMemberRole == highestRole && teamMemberObj.Level__c != null){
                            highestRoleLevel = teamMemberObj.Level__c;
                        }
                        if(teamMemberObj.TeamMemberRole != null && salesCapRole != null && teamMemberObj.TeamMemberRole == salesCapRole && teamMemberObj.Level__c != null){
                            salesCapRoleLevel = teamMemberObj.Level__c;
                        }
                    }
                    string currentUserLevel = userIdVsLevelMap.get(UserInfo.getUserId()); //CISP-2399
                    List<CommitteeRoleLevel__mdt> committeeRoleList = [SELECT id,Business_Credit__c, Product__c,MasterLabel,Label   from CommitteeRoleLevel__mdt WHERE  Product__c = 'Two Wheeler'];
                    List<CommitteeRoleHierarchy__mdt> committeeRoleHierarchyList = [SELECT Id, Label, New_Used__c, Product__c, Approval_level__c FROM CommitteeRoleHierarchy__mdt];
                    Set<String> salesRolesSet = new Set<String>();
                    Set<String> creditRolesSet = new Set<String>();
                    for(CommitteeRoleLevel__mdt committeeRole:committeeRoleList){
                        if(committeeRole.Business_Credit__c != null && committeeRole.Business_Credit__c != 'Credit' && highestTWRolesList.size() > 0 && highestTWRolesList.contains(committeeRole.Label)){
                            salesRolesSet.add(committeeRole.Label);
                        }
                        if(committeeRole.Business_Credit__c != null && committeeRole.Business_Credit__c != 'Business' && highestTWRolesList.contains(committeeRole.Label)){
                            creditRolesSet.add(committeeRole.Label);
                        }
                    }
                    Boolean triggeredToHigherRoles = false;
                    Boolean triggeredToSalesRoles = false;
                    Boolean triggeredToCreditRoles = false;
                    Boolean hasNPHAndNCMOnly = false;
                    Boolean hasNormalDeviations = false;
                    Boolean holdedByHigherLevel = false;
                    Set<String> assignedDeviationRoles = new Set<String>();
                    List<User> userList = [SELECT Id, User_Id__c FROM User WHERE Id =: currentUserId  LIMIT 1];//Start CISP-2569
                    List<AccountTeamMember> SimilarTeamMemberList = new List<AccountTeamMember>();
                    if (userList.size() > 0 && userList[0].User_Id__c!=null) {
                        SimilarTeamMemberList = [SELECT Id, Level__c, UserId FROM AccountTeamMember WHERE AccountId =:cam.Loan_Application__r.AccountId AND User.User_Id__c =:userList[0].User_Id__c WITH SECURITY_ENFORCED];//CISP-3018
                    }//End CISP-2569
                    for (DeviationWrapper wrapper : deviationWrapperList) {
                        
                         if (userIdVsLevelMap.containsKey(UserInfo.getUserId()) && userIdVsLevelMap.get(UserInfo.getUserId()) != null) {
                            if (wrapper.deviation.Deviation_Level__c!=null && wrapper.deviation.Deviation_Level__c.startsWith('L') && (currentUserRole != 'RMDM' && currentUserRole != 'HMFI' && currentUserRole != 'RMDR')) {
                                if(!wrapper.deviation.Deviation_Level__c.contains(',') && Decimal.valueOf(userIdVsLevelMap.get(UserInfo.getUserId()).substringAfter('L')) >= Decimal.valueOf(wrapper.deviation.Deviation_Level__c.substringAfter('L'))){//Start CISP-2596
                                    wrapper.disabled = false;
                                }
                                else if(wrapper.deviation.Deviation_Level__c.contains(',')){
                                    String lowestDeviationLevel = wrapper.deviation.Deviation_Level__c.split(',')[0];
                                    for(String deviationLevel : wrapper.deviation.Deviation_Level__c.split(',')){
                                        if(Decimal.valueOf(deviationLevel.substringAfter('L')) <= Decimal.valueOf(lowestDeviationLevel.substringAfter('L'))){
                                            lowestDeviationLevel = deviationLevel;
                                        }
                                    }
                                    if(Decimal.valueOf(userIdVsLevelMap.get(UserInfo.getUserId()).substringAfter('L')) >= Decimal.valueOf(lowestDeviationLevel.substringAfter('L'))){
                                        wrapper.disabled = false;
                                    }
                                }//End CISP-2596
                            }
                            if (wrapper.deviation.Type__c == 'Committee Deviation' && wrapper.deviation.Role__c == currentUserRole ) {
                                wrapper.disabled = false;
                            }

                            if (wrapper.deviation.Type__c == 'Committee Deviation' && opploan.Product_Type__c == System.Label.Tractor) {
                                if(wrapper.deviation.Role__c.contains(',')){
                                    for(String role : wrapper.deviation.Role__c.split(',')){
                                        if(role == currentUserRole){
                                            wrapper.disabled = false;
                                        }
                                    }
                                }
                            }
                        }
                        if (wrapper.deviation.Role__c != null && !roleVsLevelMap.containsKey(wrapper.deviation.Role__c)) {
                            for (CommitteeRoleHierarchy__mdt committeeRoleHierarchyRecord : committeeRoleHierarchyList) {
                                if (committeeRoleHierarchyRecord.Label == wrapper.deviation.Role__c && opploan.Product_Type__c == committeeRoleHierarchyRecord.Product__c &&  ((opploan.Vehicle_Type__c == committeeRoleHierarchyRecord.New_Used__c || (opploan.Vehicle_Type__c == 'Refinance' && committeeRoleHierarchyRecord.New_Used__c=='Used') || (opploan.Product_Type__c == System.Label.Tractor)))) {//Enabled Deviation for Refinance Vehicle Type
                                    roleVsLevelMap.put(wrapper.deviation.Role__c, committeeRoleHierarchyRecord.Approval_level__c);
                                }
                            }
                        }
                        
                        if (wrapper.deviation.Type__c == 'Committee Deviation' && roleVsLevelMap.containsKey(wrapper.deviation.Role__c) && roleVsLevelMap.get(wrapper.deviation.Role__c) != null && (currentUserRole != 'RMDM' && currentUserRole != 'HMFI' && currentUserRole != 'RMDR')) {
                            if(roleVsTypeMap.containsKey(wrapper.deviation.Role__c) && roleVsTypeMap.containsKey(currentUserRole)
                               && (roleVsTypeMap.get(currentUserRole) == 'Both' || roleVsTypeMap.get(wrapper.deviation.Role__c) == roleVsTypeMap.get(currentUserRole)) && Decimal.valueOf(currentUserLevel.substringAfter('L')) >= Decimal.valueOf(roleVsLevelMap.get(wrapper.deviation.Role__c).substringAfter('L'))){
                                   wrapper.disabled = false;
                               }
                        }
                        if (wrapper.deviation.Type__c == 'Committee Deviation' && opploan.Product_Type__c == System.Label.Tractor && wrapper.deviation.Role__c.contains(',')) {
                            for(String role : wrapper.deviation.Role__c.split(',')){
                                if (roleVsLevelMap.containsKey(role) && roleVsLevelMap.get(role) != null) {
                                    if(roleVsTypeMap.containsKey(role) && roleVsTypeMap.containsKey(currentUserRole) && (roleVsTypeMap.get(currentUserRole) == 'Both' || roleVsTypeMap.get(role) == roleVsTypeMap.get(currentUserRole)) && Decimal.valueOf(currentUserLevel.substringAfter('L')) >= Decimal.valueOf(roleVsLevelMap.get(role).substringAfter('L'))){
                                        wrapper.disabled = false;
                                    }
                                }
                            }
                        }
                        if(SimilarTeamMemberList.size() > 1){//Start CISP-2569 CISP-3018
                            for (AccountTeamMember teamMemberObj : SimilarTeamMemberList) {
                                if (wrapper.deviation.Parent_CAM__r.Loan_Application__r.CreatedById == teamMemberObj.UserId && currentUserRole=='BH') {
                                    wrapper.disabled = true;
                                }
                            }
                        }//End CISP-2569 CISP-3018

                        if(cam.Is_Hold__c && cam.Level_of_Hold_User__c != null && userIdVsLevelMap.containsKey(UserInfo.getUserId()) && Decimal.valueOf(cam.Level_of_Hold_User__c.substringAfter('L')) > Decimal.valueOf(userIdVsLevelMap.get(UserInfo.getUserId()).substringAfter('L'))){
                            disableAll = true;
                            holdedByHigherLevel = true;
                        }
                        
                        if(wrapper.fromParent != true && wrapper.deviation!= null && committeeDeviationNMRolesMap != null && wrapper.deviation.Role__c != null && wrapper.deviation.Deviation_Level__c != null && committeeDeviationNMRolesMap.containsKey(wrapper.deviation.Deviation_Level__c) && currentUserRole != null && committeeDeviationNMRolesMap.get(wrapper.deviation.Deviation_Level__c)!=null && committeeDeviationNMRolesMap.get(wrapper.deviation.Deviation_Level__c).contains(currentUserRole)){
                            wrapper.isNonMandatoryRole = true;
                        }
                        
                        if(opploan.Product_Type__c == 'Two Wheeler'){
                            if(highestTWRolesList.size() > 0 && wrapper.deviation.Role__c != null){
                                for(String highestRoleTW : highestTWRolesList){
                                    if(wrapper.deviation.Role__c.contains(highestRoleTW)){
                                        triggeredToHigherRoles = true;
                                    }
                                }
                            }
                            if(salesRolesSet.size() > 0 && wrapper.deviation.Role__c != null){
                                for(String salesRole : salesRolesSet){
                                    if(wrapper.deviation.Role__c.contains(salesRole)){
                                        triggeredToSalesRoles = true;
                                    }
                                }
                            }
                            if(creditRolesSet.size() > 0 && wrapper.deviation.Role__c != null){
                                for(String creditRole : creditRolesSet){
                                    if(wrapper.deviation.Role__c.contains(creditRole)){
                                        triggeredToCreditRoles = true;
                                    }
                                }
                            }
                        }
                        if(wrapper.deviation.Role__c != null){
                            assignedDeviationRoles.addAll(wrapper.deviation.Role__c.split(','));
                        }
                        if(wrapper.deviation.Type__c == 'Normal Deviation'){
                            hasNormalDeviations = true;
                        }
                        
                        if(wrapper.disabled){
                            wrapper.finalDisableDeviation = true;
                        }
                        else if(disableAll){
                            if(wrapper.isNonMandatoryRole == true && wrapper.deviation.Approval_Status__c != null){
                                wrapper.finalDisableDeviation = true;
                            }
                            else{
                                wrapper.finalDisableDeviation = true;
                            }
                            if(wrapper.isNonMandatoryRole == true && wrapper.deviation.Approval_Status__c == null){
                                wrapper.finalDisableDeviation = false;
                                if(wrapper.deviation.Role__c != null && currentUserRole != null && (wrapper.deviation.Approval_Status__c == null || (currentUserLevel!=null && wrapper.deviation.Deviation_Level__c!=null && Decimal.valueOf(currentUserLevel.substringAfter('L')) >= Decimal.valueOf(wrapper.deviation.Deviation_Level__c.substringAfter('L'))))){
                                    isNonMandatoryUser = true;
                                }
                            }
                        }
                        else if (cam.Trigger_Deviations__c == true) {
                            wrapper.finalDisableDeviation = false;
                        }
                        if(holdedByHigherLevel || proposalRejected || opploan.Journey_Status__c == 'Stop'){
                            wrapper.finalDisableDeviation = true;
                            disableAll = true;
                        }
                        if(parentLoanAppId != null && wrapper.deviation.Parent_CAM__r.Loan_Application__r.Id == parentLoanAppId){
                            wrapper.finalDisableDeviation = true;
                            wrapper.fromParent = true;
                        }

                        if(currentUserRole == 'CVO' && opportunityList.size() > 0 && opportunityList[0].Product_Type__c=='Tractor'){
                            wrapper.finalDisableDeviation = true;
                        }
                    }
                    if(assignedDeviationRoles.size()>0 && assignedDeviationRoles.size() == 2 && assignedDeviationRoles.contains('NPH') && assignedDeviationRoles.contains('NCM')){
                        hasNPHAndNCMOnly = true;
                    }
                    Boolean foundHighestRole = false;
                    String deviationLevel = 'L0';
                    String accountLevel = 'L0';
                    for(AccountTeamMember teamMemberObj:accountTeamMemberList){
                        if(opploan.Product_Type__c == 'Passenger Vehicles'){

                        }
                        if(opploan.Product_Type__c == 'Two Wheeler'){
                            if(triggeredToHigherRoles){
                                if(triggeredToSalesRoles && teamMemberObj.TeamMemberRole != null){
                                    string role = teamMemberObj.TeamMemberRole;
                                    if(teamMemberObj.Level__c != null && salesCapRoleLevel != null && accountLevel < teamMemberObj.Level__c && salesRolesSet.size() > 0 && salesRolesSet.contains(role) && assignedDeviationRoles.contains(role)){
                                        highestRole = role;
                                        accountLevel = teamMemberObj.Level__c;
                                        foundHighestRole = true;
                                    }
                                }
                                if(hasNPHAndNCMOnly == true){
                                    highestRole = 'NPH';
                                    foundHighestRole = true;
                                }
                                if(triggeredToCreditRoles && teamMemberObj.TeamMemberRole != null && foundHighestRole == false){
                                    string role = teamMemberObj.TeamMemberRole;
                                    if(teamMemberObj.Level__c != null  && accountLevel < teamMemberObj.Level__c && creditRolesSet.size() > 0 && creditRolesSet.contains(role) && assignedDeviationRoles.contains(role)){
                                        highestRole = role;
                                        accountLevel = teamMemberObj.Level__c;
                                    }
                                }
                            }
                        }
                    }
                    highestAuthorityRole = highestRole;
                }

                for(Id applicantId :coBorrowersWrapperMap.keySet()){
                    system.debug('coBorrowersWrapperMap--->'+coBorrowersWrapperMap);
                    if(coBorrowersWrapperMap.get(applicantId).applicantType=='Beneficiary'){
                        appBenList.add(coBorrowersWrapperMap.get(applicantId));
                    }
                    else{
                       coBorrowersWrapperList.add(coBorrowersWrapperMap.get(applicantId));
                        system.debug('coBorrowersWrapperList---->'+coBorrowersWrapperList);
                    }                    
                }
            }
            forwardWrapperList = JSON.serialize(new emailWrapper(deviationWrapperList, IND_CAMWithoutSharing.getForwardWrapper(cam.Id)));
            myString = '';
            if (oppLoan.Product_Type__c == System.Label.Tractor) {
                disableForwarded = ((cam.CAM_Submitted_by_ACM_SCM__c == false && currentUserRole == 'CVO') || disableAll == true) ? true : false;
            }
        } catch (Exception ex) {
            if(readOnly!=null && Boolean.valueOf(readOnly)){
                disableAll = true;
            }
            ErrorLoggerUtil.logErrorEvent('ViewCamController', 'Constructor', ex.getTypeName(), ex, [SELECT Loan_Application__c FROM CAM__c WHERE Id = :camRecordId LIMIT 1].Loan_Application__c);
        }    
    }
    
    public class emailWrapper {
        public List<DeviationWrapper> deviationWrapper {get;set;}
        public List<RequestWrapper> requestWrapper {get;set;}
        public emailWrapper (List<DeviationWrapper> deviationWrapper, List<RequestWrapper> requestWrapper) {
            this.deviationWrapper = deviationWrapper;
            this.requestWrapper = requestWrapper;
        }
    }
    
    
    
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.18 - CAM Screen
* @Purpose: This method is used to calculate riskband based on applicant scorecard.
***********************************************/
    public static string calculateRiskBand(string scoreCardDecision){
        String riskBand = '';
        try{
            if (scoreCardDecision!=null && scoreCardDecision.equalsIgnoreCase('Dark Green')){
                riskBand = '01';
            }
            else if ( scoreCardDecision!=null && scoreCardDecision.equalsIgnoreCase('Light Green')){
                riskBand = '02';
            }
            else if (scoreCardDecision!=null && scoreCardDecision.equalsIgnoreCase('Yellow')){
                riskBand = '03';
            }
            else if (scoreCardDecision!=null && scoreCardDecision.equalsIgnoreCase('Orange')){
                riskBand = '04';
            }
            else if (scoreCardDecision!=null && scoreCardDecision.equalsIgnoreCase('Red')){
                riskBand = '05';
            }
            else{
                riskBand='';
            }
        } catch (Exception e){
            ErrorLoggerUtil.logErrorEvent('ViewCamController', 'calculateRiskBand', e.getTypeName(), e, '');
        }
        return riskBand;
    }
    
    
    
    
    
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.18 - CAM Screen
* @Purpose: This method is used to save the loan amount and the net IRR value to final terms object (If changed).
***********************************************/
    public void saveLoanAmountAndIRR(){
        try {
            if(opploan != null && opploan.Product_Type__c == 'Tractor' && String.isNotBlank(finalTermId)){
                Final_Term__c finaltermObj = new Final_Term__c();
                finaltermObj.Id = finalTermId;
                finaltermObj.Is_Loan_Amount_Change_From_CAM__c = true;
                finaltermObj.L1_L2_Final_Terms_Changed__c = true;
                finaltermObj.Loan_Amount__c = String.valueOf(updatedLoanAmount);
                update finaltermObj;
                for(loanDetailWrapper loanDetailObj : loanDetailList){
                    if(loanDetailObj.finalRec.Id == finalTermId){
                        tfTotalLoanAmount -= Decimal.valueof(loanDetailObj.finalRec.Loan_Amount__c == null ? '0' : loanDetailObj.finalRec.Loan_Amount__c);
                        tfTotalLoanAmount += updatedLoanAmount;
                        loanDetailObj.finalRec.Loan_Amount__c = String.valueOf(updatedLoanAmount);
                    }
                }
            }else if(finalterms != null && opploan != null && opploan.Product_Type__c != 'Tractor'){
                Decimal totalPremium = (opploan!=null?opploan.Total_Funded_Premium__c:0);
                finalterms.Approving_Authority_Loan_Amount__c = String.valueOf(updatedLoanAmount);// CISP-4785 Store previous loan amount to recalculate the payout fiels on final terms
                finalterms.Loan_Amount__c = String.valueOf(updatedLoanAmount - totalPremium);
                // if (opploan!=null && opploan.Product_Type__c == 'Passenger Vehicles') {//CISP-2852
                finalterms.Is_Loan_Amount_Change_From_CAM__c = true;//CISP-2507
                finalterms.Is_Change_Pay_In_Pay_Out_Submit_Required__c = true;
                // }//CISP-2852
                if(opploan!=null && opploan.Product_Type__c == 'Passenger Vehicles' && updatedLoanAmount != loanAmount ){
                    string strPickListValue = opploan.Submitted_Tabs__c;
                    List<string> lstPicklistValues = strPickListValue.split(';');
                    Boolean isPickListValueChanged = false;
                    string borrowerValueToRemove ='Borrower Insurance Recompute';
                    if(lstPicklistValues.contains(borrowerValueToRemove)){
                        lstPicklistValues.remove(lstPicklistValues.indexOf(borrowerValueToRemove));
                        isPickListValueChanged = true;
                    }
                    string CoborrowerValueToRemove ='Coborrower Insurance Recompute';
                    if(lstPicklistValues.contains(CoborrowerValueToRemove)){
                        lstPicklistValues.remove(lstPicklistValues.indexOf(CoborrowerValueToRemove));
                        isPickListValueChanged = true;
                    }
                    opploan.Submitted_Tabs__c = String.join(lstPicklistValues,';');
                    if(isPickListValueChanged){
                        update opploan;
                    }
                }
                update finalterms;
                loanAmount = Decimal.valueOf(finalterms.Loan_Amount__c) + opploan.Total_Funded_Premium__c;
                updateProvisionalCost(opploan.Id);//CISP-124
                if (opploan!=null && opploan.Product_Type__c == 'Passenger Vehicles') {//Start CISP-2522
                    CAMApprovalLogController.FinalTermCalculationWrapper  finalTermCalculation = CAMApprovalLogController.getFinalTermCalculations(opploan.Id);
                    if (finalTermCalculation!=null) {
                        grossLTV = finalTermCalculation.grossLTV;
                        netLTV = finalTermCalculation.netLTV;
                    }
                }//CISP-2522
            }
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('ViewCamController', 'saveLoanAmountAndIRR', e.getTypeName(), e, '');
        }
    }
    //CISP-124
    /*
    * @Method:      updateProvisionalCost
    * @Created by:  Gaurav Rawat
    * @Description: update the provisional cost according metadata.
    * @Param:       String - loanApplicationId
    * @Return:      
    */
    @AuraEnabled
    public static void updateProvisionalCost(String loanApplicationId){
        try{
            List<Final_Term__c> finalTermList = new List<Final_Term__c>([Select Id,Loan_Application__r.Product_Type__c,Loan_Application__r.Vehicle_Type__c,Loan_Application__r.Total_Funded_Premium__c,Loan_Amount__c,Tenure__c,Provisional_Channel_Cost__c,Service_charges__c,Documentation_charges__c From Final_Term__c Where Loan_Application__c=:loanApplicationId 
            WITH SECURITY_ENFORCED LIMIT 1]);

            if(finalTermList.size() > 0){
                Decimal fundedAmount = finalTermList[0].Loan_Application__r.Total_Funded_Premium__c != null ? finalTermList[0].Loan_Application__r.Total_Funded_Premium__c : 0;
                finalTermValidation__mdt finalTermVali = new finalTermValidation__mdt();
                String vehicleCategoryCode;
                vehicleCategoryCode__mdt vehicleCategoryCodes= [SELECT vehicleCategoryCode__c from vehicleCategoryCode__mdt where vehicleType__c =: finalTermList[0].Loan_Application__r.Vehicle_Type__c and productType__c =: finalTermList[0].Loan_Application__r.Product_Type__c WITH SECURITY_ENFORCED LIMIT 1];
                vehicleCategoryCode = vehicleCategoryCodes.vehicleCategoryCode__c; 

                finalTermVali = [SELECT Id,ProvisionalChannelCost__c, ProvisionalChannelCostTwo__c, ProvisionalChannelCostMax__c,ProvisionalChannelCostMin__c,serviceChargesValueMin__c,serviceChargesValueMax__c,serviceChargesValue__c,documentChargesFinAmount__c,documentChargesMinAmount__c,DocumentchargesPercentage__c,DocumentChargesMinPercentage__c FROM finalTermValidation__mdt where product__c =:vehicleCategoryCode WITH SECURITY_ENFORCED LIMIT 1];

                Decimal loanAmount = Decimal.valueOf(finalTermList[0].Loan_Amount__c) + fundedAmount;
                if(finalTermList[0].Loan_Application__r.Product_Type__c.toLowerCase() == 'Two Wheeler'.toLowerCase() && finalTermList[0].Loan_Application__r.Vehicle_Type__c.toLowerCase() == 'new'.toLowerCase()){
                    System.debug('new');
                    if(Integer.valueOf(finalTermList[0].Tenure__c) >= 12){
                        Decimal provisionalAmount = ((loanAmount * finalTermVali.ProvisionalChannelCost__c)/100) + finalTermVali.ProvisionalChannelCostMin__c;
                        finalTermList[0].Provisional_Channel_Cost__c = String.valueOf(provisionalAmount);
                    }else{
                        Decimal provisionalAmount = ((loanAmount * finalTermVali.ProvisionalChannelCostTwo__c)/100) + finalTermVali.ProvisionalChannelCostMax__c;
                        finalTermList[0].Provisional_Channel_Cost__c = String.valueOf(provisionalAmount);
                    }
                }else if(finalTermList[0].Loan_Application__r.Product_Type__c.toLowerCase() == 'Two Wheeler'.toLowerCase() && (finalTermList[0].Loan_Application__r.Vehicle_Type__c.toLowerCase() == 'used'.toLowerCase() || finalTermList[0].Loan_Application__r.Vehicle_Type__c.toLowerCase() == 'Refinance'.toLowerCase())){
                    System.debug('used or refinance');
                    Decimal provisionalAmount = ((loanAmount * finalTermVali.ProvisionalChannelCost__c)/100) + finalTermVali.ProvisionalChannelCostMax__c;
                    finalTermList[0].Provisional_Channel_Cost__c = String.valueOf(provisionalAmount);
                }
                if (finalTermList[0].Loan_Application__r.Product_Type__c.toLowerCase() == 'Two Wheeler'.toLowerCase()) {
                    if (((finalTermVali.serviceChargesValueMin__c * loanAmount) / 100) > Decimal.ValueOf(finalTermList[0].Service_charges__c)) {
                        Decimal serviceAmount = ((loanAmount * finalTermVali.serviceChargesValueMin__c)/100);
                        finalTermList[0].Service_charges__c = String.valueOf(Math.round(serviceAmount));
                    }
                    else if(((finalTermVali.serviceChargesValueMax__c * loanAmount) / 100) < Decimal.ValueOf(finalTermList[0].Service_charges__c)){
                        Decimal serviceAmount = ((loanAmount * finalTermVali.serviceChargesValueMax__c)/100);
                        finalTermList[0].Service_charges__c = String.valueOf(Math.round(serviceAmount));
                    }
                    if (((finalTermVali.DocumentChargesMinPercentage__c * loanAmount) / 100) > Decimal.ValueOf(finalTermList[0].Documentation_charges__c)) {
                        Decimal documentationAmount = ((loanAmount * finalTermVali.DocumentChargesMinPercentage__c)/100);
                        finalTermList[0].Documentation_charges__c = String.valueOf(Math.round(documentationAmount));
                    }
                    else if(((finalTermVali.DocumentchargesPercentage__c * loanAmount) / 100) < Decimal.ValueOf(finalTermList[0].Documentation_charges__c)){
                        Decimal documentationAmount = ((loanAmount * finalTermVali.DocumentchargesPercentage__c)/100);
                        finalTermList[0].Documentation_charges__c = String.valueOf(Math.round(documentationAmount));
                    }
                }

                update finalTermList[0];
            }
        }
        catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_OfferScreenController', 'updateProvisionalCost', System.Label.Apex, e, loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
     //CISP-3359
    /*
    * @Method:      updateDocandServiceCharge
    * @Created by:  Rohan Saxena
    * @Description: update document and service charge field
    * @Param:       String - loanApplicationId
    * @Return:      
    */
    @AuraEnabled
    public static String updateDocandServiceCharge(String loanApplicationId){
        try{
            //CISP-4785 Added LeadSource in SOQL
            List<Final_Term__c> finalTermList = new List<Final_Term__c>([Select Id,Loan_Application__r.LeadSource,Loan_Application__r.Product_Type__c,Loan_Application__r.Vehicle_Type__c,Loan_Application__r.Total_Funded_Premium__c,Loan_Amount__c,Tenure__c,Provisional_Channel_Cost__c,Service_charges__c,Documentation_charges__c,Is_Loan_Amount_Change_From_CAM__c From Final_Term__c Where Loan_Application__c=:loanApplicationId 
            WITH SECURITY_ENFORCED LIMIT 1]);
            Decimal ser,doc;
            if(finalTermList.size() > 0 && finalTermList[0].Is_Loan_Amount_Change_From_CAM__c == true && finalTermList[0].Loan_Application__r.Product_Type__c.toLowerCase() == 'Two Wheeler'.toLowerCase()){
                Decimal fundedAmount = finalTermList[0].Loan_Application__r.Total_Funded_Premium__c != null ? finalTermList[0].Loan_Application__r.Total_Funded_Premium__c : 0;
                finalTermValidation__mdt finalTermVali = new finalTermValidation__mdt();
                String vehicleCategoryCode;
                vehicleCategoryCode__mdt vehicleCategoryCodes= [SELECT vehicleCategoryCode__c from vehicleCategoryCode__mdt where vehicleType__c =: finalTermList[0].Loan_Application__r.Vehicle_Type__c and productType__c =: finalTermList[0].Loan_Application__r.Product_Type__c WITH SECURITY_ENFORCED LIMIT 1];
                vehicleCategoryCode = vehicleCategoryCodes.vehicleCategoryCode__c; 

                finalTermVali = [SELECT Id,ProvisionalChannelCost__c, ProvisionalChannelCostTwo__c, ProvisionalChannelCostMax__c,ProvisionalChannelCostMin__c,serviceChargesValueMin__c,serviceChargesValueMax__c,serviceChargesValue__c,documentChargesFinAmount__c,documentChargesMinAmount__c,DocumentchargesPercentage__c,DocumentChargesMinPercentage__c FROM finalTermValidation__mdt where product__c =:vehicleCategoryCode WITH SECURITY_ENFORCED LIMIT 1];

                Decimal loanAmount = Decimal.valueOf(finalTermList[0].Loan_Amount__c) + fundedAmount;
                ser= Decimal.Valueof(finalTermList[0].Service_charges__c);
                doc= Decimal.Valueof(finalTermList[0].Documentation_charges__c);
                if (((finalTermVali.serviceChargesValueMin__c * loanAmount) / 100) > Decimal.ValueOf(finalTermList[0].Service_charges__c)) {
                    Decimal serviceAmount = ((loanAmount * finalTermVali.serviceChargesValueMin__c)/100);
                    ser= Math.round(serviceAmount);
                    finalTermList[0].Service_charges__c = String.valueOf(Math.round(serviceAmount));
                }
                else if(((finalTermVali.serviceChargesValueMax__c * loanAmount) / 100) < Decimal.ValueOf(finalTermList[0].Service_charges__c)){
                    Decimal serviceAmount = ((loanAmount * finalTermVali.serviceChargesValueMax__c)/100);
                    ser= Math.round(serviceAmount);
                    finalTermList[0].Service_charges__c = String.valueOf(Math.round(serviceAmount));
                }
                if (((finalTermVali.DocumentChargesMinPercentage__c * loanAmount) / 100) > Decimal.ValueOf(finalTermList[0].Documentation_charges__c)) {
                    Decimal documentationAmount = ((loanAmount * finalTermVali.DocumentChargesMinPercentage__c)/100);
                    doc= Math.round(documentationAmount);
                    finalTermList[0].Documentation_charges__c = String.valueOf(Math.round(documentationAmount));
                }
                else if(((finalTermVali.DocumentchargesPercentage__c * loanAmount) / 100) < Decimal.ValueOf(finalTermList[0].Documentation_charges__c)){
                    Decimal documentationAmount = ((loanAmount * finalTermVali.DocumentchargesPercentage__c)/100);
                    doc= Math.round(documentationAmount);
                    finalTermList[0].Documentation_charges__c = String.valueOf(Math.round(documentationAmount));
                }
                //CISP-4785 Replaced hardcoded value with custom label so that it is configurable
                if(finalTermList[0].Loan_Application__r.LeadSource != 'D2C' && finalTermList[0].Loan_Application__r.LeadSource != 'DSA') {
                    if((ser+doc )< Decimal.valueOf(System.Label.Valid_sum_of_Service_Charge_and_Documentation_charge)){
                        return 'TW_min_Val';
                    }
                } else {
                    if((ser+doc )< 1400){//CISP-10189 changed 1200 to 1400
                        return 'TW_min_Val';
                        //throw new AuraHandledException('Sum of Both Service Charge and Documentation charge should not be less than 1400');
                    }
                }
                update finalTermList[0];
                return 'SUCCESS';
            }
            return null;
        }
        catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('ViewCamController', 'updateDocandServiceCharge', System.Label.Apex, e, loanApplicationId);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    //CISP-124
    public void confirmChangeIRR(){
        try {
            if (opploan != null && opploan.Product_Type__c == 'Tractor' && String.isNotBlank(finalTermId)) {
                Final_Term__c finaltermObj = new Final_Term__c();
                finaltermObj.Id = finalTermId;
                finaltermObj.Required_CRM_IRR__c = String.valueOf(updatedIRR);
                finaltermObj.L1_L2_Final_Terms_Changed__c = true;
                update finaltermObj;
                for(loanDetailWrapper loanDetailObj : loanDetailList){
                    if(loanDetailObj.finalRec.Id == finalTermId){
                        loanDetailObj.finalRec.Required_CRM_IRR__c = String.valueOf(updatedIRR);
                    }
                }
            }else if(finalterms != null && opploan != null && opploan.Product_Type__c != 'Tractor'){
                if (opploan.Product_Type__c == 'Passenger Vehicles') {
                    finalterms.Net_IRR__c = updatedIRR;   
                } else if (opploan.Product_Type__c == 'Two Wheeler') {
                    finalterms.Inputted_IRR__c = updatedIRR;   
                }
                update finalterms;
                if (opploan.Product_Type__c == 'Passenger Vehicles') {
                    requiredNetIRR = finalterms.Net_IRR__c!=null ?finalterms.Net_IRR__c:null;   
                } else if (opploan.Product_Type__c == 'Two Wheeler') {
                    requiredNetIRR = finalterms.Inputted_IRR__c!=null ?finalterms.Inputted_IRR__c:null;   
                }
            }
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('ViewCamController', 'confirmChangeIRR', e.getTypeName(), e, '');
        }
    }
    
    public void familyExposure(){
        try {
            if (family_Exposure==true) {
                family_Exposure = false;
            } else {
                family_Exposure = true;
            }
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('ViewCamController', 'familyExposure', e.getTypeName(), e, '');
        }
    }
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.18 - CAM Screen
* @Purpose: This method is used to revert back the values of Loan Amount and Net IRR if user cancels the confirmation.
***********************************************/
    public void redoChanges(){
        try {
            loanAmount=finalterms.Loan_Amount__c!=null?Decimal.valueOf(finalterms.Loan_Amount__c)+ opploan.Total_Funded_Premium__c: opploan.Total_Funded_Premium__c;
            if (opploan.Product_Type__c == 'Passenger Vehicles') {
                requiredNetIRR = finalterms.Net_IRR__c!=null ?finalterms.Net_IRR__c:null;   
            } else if (opploan.Product_Type__c == 'Two Wheeler') {
                requiredNetIRR = finalterms.Inputted_IRR__c!=null ?finalterms.Inputted_IRR__c:null;   
            }
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('ViewCamController', 'redoChanges', e.getTypeName(), e, '');
        }
    }
    public  void Save(){
        try {
            if(deviation!=null){
                upsert deviation;
            }
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('ViewCamController', 'Save', e.getTypeName(), e, '');
        }
    }
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.18 - CAM Screen
* @Purpose: This method is used to disable the Approved radio button (proposal status) if user has rejected any deviation.
***********************************************/
    public  void checkDeviations(){
        try {
            if(deviation!=null){
                for (Deviation__c deviationObj : deviation) {
                    if(deviationObj.Approval_Status__c=='Rejected'){
                        disableRadioButton = true;
                        break;
                    }
                    else {
                        disableRadioButton = false;
                    }
                }
            }
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('ViewCamController', 'checkDeviations', e.getTypeName(), e, '');
        }
    }
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.16,8.2.18 - Forward To,CAM Screen
* @Purpose: This method is used to forward the cam to other user by creating a proposal approval log record of Forward log record type.
***********************************************/
    public void forwardTheProposal(){
        try {
            string camId = cam.Id;
            string role = forwardTo;
            CAM__c cam=[SELECT Id,Loan_Application__c, Loan_Application__r.AccountId,Loan_Application__r.Product_Type__c FROM CAM__c WHERE id=:camId WITH SECURITY_ENFORCED];
            Id accountId = cam.Loan_Application__r.AccountId;
            
            List<AccountTeamMember> roleList = [SELECT ID ,TeamMemberRole, Level__c ,Account.id, User.Email, user.Name, UserId, user.IsActive FROM AccountTeamMember WHERE AccountId= :accountId AND TeamMemberRole=:role AND user.IsActive=TRUE WITH SECURITY_ENFORCED]; //CISP-4176
            List<AccountTeamMember> currentUserRoleList = [SELECT TeamMemberRole FROM AccountTeamMember WHERE AccountId= :accountId AND UserId=:currentUserId WITH SECURITY_ENFORCED LIMIT 1];
            User runningUser = [SELECT Id, Name FROM User WHERE Id=:UserInfo.getUserId() WITH SECURITY_ENFORCED];
            
            String str= ForwardToMail.emailCallOut(camId,  role);
            Id recType = Schema.SObjectType.Proposal_Approval_Log__c.getRecordTypeInfosByName().get('Forward log').getRecordTypeId();
            List<Proposal_Approval_Log__c> proposalLogToInsert = new List<Proposal_Approval_Log__c>();
            if(str=='Success'){
                for(AccountTeamMember roleMember : roleList){
                    Proposal_Approval_Log__c logRec = new Proposal_Approval_Log__c();
                    logRec.Name = String.valueOf(Math.floor(Math.random() * 10000).intValue()); // CISP-16665
                    logRec.Proposal_description__c = 'Test Approval Log'; // CISP-16665
                    logRec.Parent_CAM__c = camId;
                    logRec.Date_and_Time__c = System.now();
                    logRec.RecordTypeId = recType;
                    logRec.Forwarded_On__c=System.now();
                    logRec.Forwarded_By__c = runningUser.Name;
                    logRec.Forwarded_Role__c = role;
                    logRec.Forwarding_Employee__c = runningUser.Id;
                    logRec.Forwarded_Employee__c =roleMember.UserId;
                    logRec.Proposal_Remark__c=remarks;
                    if(currentUserRoleList.size()>0){
                        logRec.Forwarding_Role__c = currentUserRoleList[0].TeamMemberRole;
                    }
                    proposalLogToInsert.add(logRec);
                }
                if(proposalLogToInsert.size()>0){
                    insert proposalLogToInsert;
                }
                
                // applog = [select Role__c,Forwarded_On__c,Forwarding_Role__c,Forwarded_By__c,Forwarded_Role__c,Forwarded_Employee__r.Name,Approval_Status__c,Remark__c,Date_and_Time__c,RecordType.Name,Parent_CAM__r.Loan_Application__c,Parent_CAM__c,Parent_CAM__r.Loan_Application__r.Applicant_Name__c  from Proposal_Approval_Log__c WHERE Parent_CAM__c = :cam.Id WITH SECURITY_ENFORCED ORDER BY LastModifiedDate DESC];
                remarks=null;
                forwardTo=null;
                isForwardTo = 'No';
            }
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('ViewCamController', 'forwardTheProposal', e.getTypeName(), e, '');
        }
    }
    
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.17,8.2.18 - Deviation Management,CAM Screen
* @Purpose: This method is used to save the deviation changes made by the user and creates a respective proposal approval log of Deviation log record type and creates one proposal approval log of Proposal log type and save the proposal status there and it also checks the validation that user must enter remarks or any change has to be made on deviation to take any proposal action.
***********************************************/
    public void saveDeviationAndApprovalChanges(){
        try {
            System.debug('saveDeviationAndApprovalChanges');
            System.debug('proposalStatus-->'+proposalStatus);
            Boolean isvalid = false;
            if(proposalStatus!=null){
                List<Cam__c> camList = [SELECT Loan_Application__c,Loan_Application__r.Product_Type__c FROM CAM__c WHERE Id=:cam.Id LIMIT 1];
                if(!camList.isEmpty() && camList[0].Loan_Application__c!=null){
                    System.debug('values' + minNetIrr+ ' ' + maxNetIrr + ' ' + requiredNetIRR);
                    List<Opportunity> oppList = [SELECT Id, Product_Type__c from Opportunity where Id =:camList[0].Loan_Application__c LIMIT 1];
                    List<Final_Term__c> finalTermList = new List<Final_Term__c>([Select Id,Is_Change_Pay_In_Pay_Out_Submit_Required__c,Is_Loan_Amount_Change_From_CAM__c From Final_Term__c Where Loan_Application__c=:camList[0].Loan_Application__c WITH SECURITY_ENFORCED LIMIT 1]);
                    if(!oppList.isEmpty() && oppList[0].Product_Type__c == 'Passenger Vehicles'){
                        system.debug('in if condition');
                        if(minNetIrr!=null && maxNetIrr!=null && ((requiredNetIRR< decimal.valueOf(minNetIrr) ) || (requiredNetIRR > decimal.valueOf(maxNetIrr)))){  
                            warningMessage = 'NET IRR is not as per norms Min' + minNetIrr  + ' and Max '+maxNetIrr+' . Please make the relevant changes by editing Net IRR in CAM screen (or) revoke the proposal.';
                            isvalid = true;
                            disableAll=false;
                        }else{
                            isvalid = false;
                        }
                    }else if(!oppList.isEmpty() && oppList[0].Product_Type__c == 'Two Wheeler' && !finalTermList.isEmpty() && finalTermList[0].Is_Loan_Amount_Change_From_CAM__c && finalTermList[0].Is_Change_Pay_In_Pay_Out_Submit_Required__c){                 
                        warningMessage = 'You have changed Loan Amount. Please submit Change Pay in / Pay out';
                        isvalid = true;
                    }
                }
                system.debug('isvalid--' + isvalid);
                if(!isvalid){
                if(proposalStatus != 'Conditionally Approve' || (approvalConditionsOrRemarks!=null && String.isNotBlank(approvalConditionsOrRemarks))){
                    List<Deviation__c> updatedDeviationList = new List<Deviation__c>();
                    Map<Id,Deviation__c> existingDeviationMap = new Map<Id,Deviation__c>([select id, Deviation_Description__c,Deviation_Level__c,Role__c,Approval_Status__c,Remarks__c,Parent_CAM__c, Parent_CAM__r.Loan_Application__c from Deviation__c WHERE Parent_CAM__c = :cam.Id WITH SECURITY_ENFORCED]);
                    if(deviation!=null && existingDeviationMap!=null){
                        Boolean remarkFlag = false;
                        Integer count=0;
                        for(DeviationWrapper deviationWrapper : deviationWrapperList){
                            
                            Deviation__c deviationObj = deviationWrapper.deviation;
                            Deviation__c existedDeviation = existingDeviationMap.get(deviationObj.Id);
                            if(deviationWrapper.fromParent == false && deviationObj.Approval_Status__c!=null && deviationObj.Approval_Status__c!='-None-' && (deviationObj.Approval_Status__c!=existedDeviation.Approval_Status__c || (existedDeviation.Remarks__c!=null && deviationObj.Remarks__c.trim()!=existedDeviation.Remarks__c.trim()))){
                                if(deviationObj.Approval_Status__c=='-None-'){      
                                    deviationObj.Approval_Status__c = null;
                                }
                                if(deviationObj.Approval_Status__c=='Conditionally Approve' && String.isEmpty(deviationObj.Remarks__c.trim())){
                                    remarkFlag = true;
                                }
                                deviationObj.Proposal_Status__c = proposalStatus;
                                
                                deviationObj.Deviation_Submitted_By__c = UserInfo.getUserId();
                                updatedDeviationList.add(deviationObj);
                            }
                            else {
                                count+=1;
                            }
                        }
                        if(remarkFlag==false){
                            // if(count!=deviation.size()){
                            List<Proposal_Approval_Log__c> proposalLogList = new List<Proposal_Approval_Log__c>();
                            List<Proposal_Approval_Log__c> existedProposalLogList = new List<Proposal_Approval_Log__c>();
                            Id recType = Schema.SObjectType.Proposal_Approval_Log__c.getRecordTypeInfosByName().get('Deviation Log').getRecordTypeId();
                            Id proposalRecType = Schema.SObjectType.Proposal_Approval_Log__c.getRecordTypeInfosByName().get('Proposal log').getRecordTypeId();
                            if(updatedDeviationList.size() > 0){
                                upsert updatedDeviationList;
                                existedProposalLogList = [SELECT Id,Deviation_Id__c FROM Proposal_Approval_Log__c WHERE Deviation_Id__c IN:updatedDeviationList WITH SECURITY_ENFORCED LIMIT 10000];
                                Map<string,Proposal_Approval_Log__c> deviationIdVsProposalLogMap = new Map<string,Proposal_Approval_Log__c>();
                                for (Proposal_Approval_Log__c proposalLog : existedProposalLogList) {
                                    if(!deviationIdVsProposalLogMap.containsKey(proposalLog.Deviation_Id__c)){
                                        deviationIdVsProposalLogMap.put(proposalLog.Deviation_Id__c,proposalLog);
                                    }
                                }
                                for (Deviation__c deviationObj  : updatedDeviationList) {
                                    Proposal_Approval_Log__c proposalLogObj = new Proposal_Approval_Log__c();
                                    if(deviationIdVsProposalLogMap.containsKey(deviationObj.Id)){
                                        proposalLogObj.Id = deviationIdVsProposalLogMap.get(deviationObj.Id).Id;
                                    }
                                    else {
                                        proposalLogObj.Parent_CAM__c = deviationObj.Parent_CAM__c;
                                    }
                                    if(deviationObj.Type__c == 'Committee Deviation'){
                                        proposalLogObj.Name = String.valueOf(Math.floor(Math.random() * 10000).intValue()); // CISP-16665
                                        proposalLogObj.Proposal_description__c = deviationObj.Deviation_Level__c+ ' Committee for (Exposure) ' + deviationObj.Role__c; // CISP-16665
                                    }else{
                                        proposalLogObj.Name = String.valueOf(Math.floor(Math.random() * 10000).intValue()); // CISP-16665
                                        proposalLogObj.Proposal_description__c = deviationObj.Deviation_Description__c; // CISP-16665
                                    }
                                    proposalLogObj.Role__c = currentUserRole;
                                    proposalLogObj.Deviation_Id__c = deviationObj.Id;
                                    proposalLogObj.Approval_Status__c = deviationObj.Approval_Status__c;
                                    if(deviationObj.Approval_Status__c=='Conditionally Approve'){
                                        proposalLogObj.Proposal_Approval_Condition__c = deviationObj.Remarks__c;
                                    }
                                    else{
                                        proposalLogObj.Proposal_Remark__c = deviationObj.Remarks__c;
                                    }
                                    if(recType!=null){
                                        proposalLogObj.RecordTypeId = recType;
                                    }
                                    proposalLogList.add(proposalLogObj);
                                }
                            }
                            if(proposalStatus!=null){
                                Proposal_Approval_Log__c proposalLogObj = new Proposal_Approval_Log__c();
                                proposalLogObj.Parent_CAM__c = cam.Id;
                                proposalLogObj.Name = String.valueOf(Math.floor(Math.random() * 10000).intValue()); // CISP-16665
                                proposalLogObj.Proposal_description__c = 'Proposal Action taken by '+UserInfo.getName(); // CISP-16665
                                proposalLogObj.Role__c = currentUserRole;
                                proposalLogObj.Approval_Status__c = proposalStatus;
                                proposalLogObj.Proposal_Approval_Condition__c = approvalConditionsOrRemarks;
                                if(proposalRecType!=null){
                                    proposalLogObj.RecordTypeId = proposalRecType;
                                }
                                proposalLogList.add(proposalLogObj);
                            }
                            if(!proposalLogList.isEmpty()){
                                upsert proposalLogList;
                            }
                            if(finalterms.Approving_Authority_Loan_Amount__c==null && loanAmount !=null){
                                finalterms.Approving_Authority_Loan_Amount__c = String.valueOf(loanAmount);
                                update finalterms;
                            }
                            if(proposalStatus=='Hold'){
                                cam.Is_Hold__c = true;
                                cam.Hold_Date__c = system.now();
                                if(userIdVsLevelMap!=null && userIdVsLevelMap.containsKey(UserInfo.getUserId()) && userIdVsLevelMap.get(UserInfo.getUserId())!=null){
                                    cam.Level_of_Hold_User__c =  userIdVsLevelMap.get(UserInfo.getUserId());
                                }
                                update cam;
                            }
                            else {
                                if(cam.Is_Hold__c==true){
                                    cam.Is_Hold__c = false;
                                    cam.Hold_Date__c = null;
                                    cam.Level_of_Hold_User__c = null;
                                    update cam;
                                }
                            }
                            proposalStatus = null;
                            approvalConditionsOrRemarks =null;
                            
                            isNonMandatoryUser = false;
                            for(DeviationWrapper wrapper : deviationWrapperList){
                                if(wrapper.disabled){
                                    wrapper.finalDisableDeviation = true;
                                }
                                else if(disableAll){
                                    if(wrapper.isNonMandatoryRole && wrapper.deviation.Approval_Status__c != null){
                                        wrapper.finalDisableDeviation = true;
                                    }
                                    else{
                                        wrapper.finalDisableDeviation = true;
                                    }
                                    if(wrapper.isNonMandatoryRole && wrapper.deviation.Approval_Status__c == null){
                                        wrapper.finalDisableDeviation = false;
                                        isNonMandatoryUser = true;
                                    }
                                }
                                else if(cam.Trigger_Deviations__c == true) {
                                    wrapper.finalDisableDeviation = false;
                                }
                                if(proposalStatus == 'Rejected' && wrapper.deviation.Proposal_Status__c!=null){
                                    disableAll=true;
                                    wrapper.finalDisableDeviation = true;
                                }
                            }
                            warningMessage='';
                            ApexPages.addMessage(
                                new ApexPages.Message(
                                    ApexPages.Severity.CONFIRM,
                                    'Proposal response is saved successfully.'
                                )
                            );
                        }
                        // }
                        // else{
                        //     warningMessage = System.Label.Message_deviation;
                        // }
                        else {
                            warningMessage = System.Label.Message_Conditionally_Approve_deviation;
                        }
                    }
                }
                else {
                    warningMessage = System.Label.Message_Approval_Condition;
                }
            }
            }
            else  {
                warningMessage = System.Label.Message_proposal_action;
            }
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('ViewCamController', 'saveDeviationAndApprovalChanges', e.getTypeName(), e, [SELECT Loan_Application__c FROM CAM__c WHERE Id=:cam.Id LIMIT 1].Loan_Application__c);
        }
    }
      /*
    * @Method:      sendApprovedCAMEmail
    * @Created by:  Aakash J.
    * @Description: Method to return list of RequestWrapper
    * @Param:       String - CAM ID camRecId
    * @Return:      List<RequestWrapper> - List of RequestWrapper
    */
    public static void sendApprovedCAMEmail(String camRecId){
        try {
            //List<RequestWrapper> emailRequestWrapperList = new List<RequestWrapper>();
            if(camRecId!=null){
                
                List<EmailTemplate> etList = [select id,Subject,HtmlValue from EmailTemplate where developername='TractorLoanApplicationApprovedEmail'];

                CAM__c camRec =[SELECT Id,Loan_Application__c,Loan_Application__r.Name, Loan_Application__r.Owner.Email, Loan_Application__r.OwnerId,Loan_Application__r.Owner.Name,
                                Loan_Application__r.AccountId FROM CAM__c WHERE id=:camRecId ];
                
                User userRec = [SELECT ID ,Email, Name, IsActive, Profile.UserLicense.Name FROM User WHERE Id= :camRec.Loan_Application__r.OwnerId ];
                    
                List<Applicant__c> applicant = [SELECT Id, Name FROM Applicant__c WHERE Opportunity__c = :camRec.Loan_Application__c AND Applicant_Type__c = 'Borrower' AND In_Active_Applicant__c = false];
                String applicantName = applicant.size() > 0 ? applicant[0].Name : '';
                
                RequestWrapper emailRequestWrapper = new RequestWrapper();
                
                Boolean communityCheck = userRec.Profile?.UserLicense.Name == 'Partner Community';
                emailRequestWrapper.leadId = camRec.Loan_Application__c;
                emailRequestWrapper.loanApplicationId = camRec.Loan_Application__c;
                emailRequestWrapper.emailTo = camRec.Loan_Application__r.Owner.Email;
                emailRequestWrapper.emailCC =  camRec.Loan_Application__r.Owner.Email;
                String emailTemplateSubject = etList[0].Subject.replace('{!Opportunity.Name}', camRec.Loan_Application__r.Name);
                emailRequestWrapper.emailSubject = emailTemplateSubject;
                
                String emailBody = etList[0].HtmlValue.replace('{!Receiving_User.Name}',camRec.Loan_Application__r.Owner.Name);
                emailBody = emailBody.replace('{!Opportunity.Name}',  camRec.Loan_Application__r.Name);
                emailBody = emailBody.replace('{!User.Name}',applicantName);
                emailBody = emailBody.replace('{!loan.Id}',camRec.Loan_Application__c);
                emailBody = emailBody.replace('{!Approver.Name}',UserInfo.getName());
                emailBody = emailBody.replace('{cvo.Name}',camRec.Loan_Application__r.Owner.Name);
                
                if (communityCheck) {
                    emailBody = emailBody.replace('{!InsertHyperLink}',System.Label.IBL_Community_Partners_URL);
                } else {
                    emailBody = emailBody.replace('{!InsertHyperLink}',System.Label.IBL_Lightning_Base_URL);
                }
                emailRequestWrapper.emailBody = emailBody;
                String emailString = JSON.serialize(emailRequestWrapper);
                System.debug('+++++emailString '+emailString);
                IntegrationEngine.doEmailServiceCallout(emailString);
            }
            
        }catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('viewCamController', 'sendApprovedCAMEmail', e.getTypeName(), e, [SELECT Loan_Application__c FROM CAM__c WHERE Id=:camRecId LIMIT 1].Loan_Application__c);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }    
    }
    @AuraEnabled(cacheable=true)
    public static List <Applicant__c> getApplicants() {
        return [SELECT Id, Name, Gender__c FROM Applicant__c LIMIT 5];
    }
    @AuraEnabled(cacheable=true)
    
    public static List<InsuranceDetails__c> getInsuranceDetails(String applicationID) {
        
        List<InsuranceDetails__c> InsuranceList=[SELECT Applicant__c,Applicant__r.name,Applicant__r.Applicant_Type__c, Product_Type__c, Name, Amount__c,Funded_Non_funded__c, Funded_Premium__c from InsuranceDetails__c where Applicant__c='a0U71000000B41tEAC' WITH SECURITY_ENFORCED];
        return InsuranceList;
        
    }
    @AuraEnabled(cacheable=true)
    
    public static List<AggregateResult> getInsuranceAggregation(String applicationID) {
        List<AggregateResult> InsuranceAgg=[SELECT Applicant__c, SUM(Amount__c)total from InsuranceDetails__c group by Applicant__c having Applicant__c in ('a0U71000000B41tEAC')];
        return InsuranceAgg;
        
    }
    
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.18 - CAM Screen
* @Purpose: This method is used to provide the details to IND_LWC_CibilEquifax cmp to show the equifax/ cibil report.
***********************************************/
    @AuraEnabled
    public static CAMInfoWrapper getRequestDetails(string camId){
        try {
            if(camId!=null){
                CAMInfoWrapper wrapperObj = new CAMInfoWrapper();
                String leadSource;
                List<String> applicantTypesList = new List<String>();
                List<CAM__C> camList = new List<CAM__C>();
                camList = [SELECT Id,Loan_Application__c,Loan_Application__r.EMI_Amount__c,Loan_Application__r.Required_Tenure__c,Loan_Application__r.LeadSource FROM CAM__c WHERE Id=:camId AND Loan_Application__c!=null  WITH SECURITY_ENFORCED LIMIT 1];
                if(!camList.isEmpty() && camList[0].Loan_Application__c!=null){
                    wrapperObj.camRecord = camList[0];
                    leadSource = camList[0].Loan_Application__r.LeadSource;//OLA-139
                    List<Applicant__C> applicantList = new List<Applicant__c>();
                    applicantList = [SELECT Id,Applicant_Type__c,Opportunity__r.Customer_Type__c,CRIFF_Report_URL__c FROM Applicant__c WHERE Opportunity__c=:camList[0].Loan_Application__c AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED ORDER BY Applicant_Type__c ASC];
                    if(!applicantList.isEmpty()){
                        List<CIBIL_Details__c> cibilDetailsList = new List<CIBIL_Details__c>();
                        cibilDetailsList = [SELECT Equifax_Report_URl__c,CIBIL_Report_URl__c,Applicant__r.Applicant_Type__c FROM CIBIL_Details__c WHERE Applicant__c IN:applicantList WITH SECURITY_ENFORCED ORDER BY CreatedDate Desc  LIMIT 1000];
                        Boolean borrowerCheck = false;
                        Boolean coBorrowerCheck = false;
                        Boolean guarantorCheck = false;
                        for (CIBIL_Details__c cibilObj : cibilDetailsList) {
                            if(cibilObj.Applicant__r.Applicant_Type__c=='Borrower' && borrowerCheck==false){
                                wrapperObj.borrowerCibilRecord = cibilObj;
                                borrowerCheck = true;
                            }
                            if(cibilObj.Applicant__r.Applicant_Type__c=='Co-borrower' && coBorrowerCheck==false){
                                wrapperObj.coBorrowerCibilRecord = cibilObj;
                                coBorrowerCheck = true;
                            }
                            if(cibilObj.Applicant__r.Applicant_Type__c=='Guarantor' && guarantorCheck==false){
                                wrapperObj.guarantorCibilRecord = cibilObj;
                                guarantorCheck = true;
                            }
                        }
                        Boolean borrowerApplicantCheck = false;
                        Boolean coBorrowerApplicantCheck = false;
                        Boolean guarantorApplicantCheck = false;
                        for (Applicant__c applicantObj : applicantList) {
                            applicantTypesList.add(applicantObj.Applicant_Type__c);
                            if(applicantObj.Applicant_Type__c=='Borrower' && borrowerApplicantCheck==false){
                                wrapperObj.applicantId = applicantObj.Id;
                                borrowerApplicantCheck = true;
                                if(applicantObj.Opportunity__r.Customer_Type__c=='Non-Individual'){
                                    wrapperObj.reportURL=applicantObj.CRIFF_Report_URL__c;
                                }
                            }
                            if(applicantObj.Applicant_Type__c=='Co-borrower' && coBorrowerApplicantCheck==false){
                                wrapperObj.coBorrowerApplicantId = applicantObj.Id;
                                coBorrowerApplicantCheck = true;
                            }
                            if(applicantObj.Applicant_Type__c=='Guarantor' && guarantorApplicantCheck==false){
                                wrapperObj.guarantorApplicantId = applicantObj.Id;
                                guarantorApplicantCheck = true;
                            }
                            wrapperObj.customerType=applicantObj.Opportunity__r.Customer_Type__c;
                        }
                    }
                    wrapperObj.appList = applicantTypesList;
                    wrapperObj.loanAppId = camList[0].Loan_Application__c;
                    // Start CISP-110
                    List<Final_Term__c> finalTermList = [select Id, EMI_Amount__c,Holiday_period__c, Tenure__c from Final_Term__c  where Loan_Application__c = :camList[0].Loan_Application__c WITH SECURITY_ENFORCED LIMIT 1];
                    if (finalTermList.size() > 0) {
                        wrapperObj.emiAmount = finalTermList[0].EMI_Amount__c;
                        if(finalTermList[0].Holiday_period__c != null && finalTermList[0].Tenure__c != null){
                            if(Integer.valueOf(finalTermList[0].Holiday_period__c) == 0 || leadSource=='OLA'){
                                wrapperObj.tenure = Integer.valueOf(finalTermList[0].Tenure__c);
                            } else if(Integer.valueOf(finalTermList[0].Holiday_period__c) == 30){
                                wrapperObj.tenure = Integer.valueOf(finalTermList[0].Tenure__c) -1;
                            }
                        }else{
                            wrapperObj.tenure = finalTermList[0].Tenure__c != null ? Integer.valueOf(finalTermList[0].Tenure__c) : null;
                        }
                    }// End CISP-110
                }
                return wrapperObj;
            }
            return null;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('ViewCamController', 'getRequestDetails', e.getTypeName(), e, [SELECT Loan_Application__c FROM CAM__c WHERE Id=:camId LIMIT 1].Loan_Application__c);
            return null;
        }
    }


    @AuraEnabled
    public static CAMInfoWrapper getRequestDetailsForTractor(string camId,String applicantId){
        try {
            if(camId!=null){
                CAMInfoWrapper wrapperObj = new CAMInfoWrapper();
                String leadSource;
                List<CAM__C> camList = new List<CAM__C>();
                camList = [SELECT Id,Loan_Application__c,Loan_Application__r.EMI_Amount__c,Loan_Application__r.Required_Tenure__c,Loan_Application__r.LeadSource FROM CAM__c WHERE Id=:camId AND Loan_Application__c!=null  WITH SECURITY_ENFORCED LIMIT 1];
                if(!camList.isEmpty() && camList[0].Loan_Application__c!=null){
                    wrapperObj.camRecord = camList[0];
                    leadSource = camList[0].Loan_Application__r.LeadSource;//OLA-139
                    List<Applicant__C> applicantList = new List<Applicant__c>();
                    applicantList = [SELECT Id,Applicant_Type__c FROM Applicant__c WHERE Opportunity__c=:camList[0].Loan_Application__c and Id =: applicantId  WITH SECURITY_ENFORCED LIMIT 1000];
                    if(!applicantList.isEmpty()){
                        List<CIBIL_Details__c> cibilDetailsList = new List<CIBIL_Details__c>();
                        cibilDetailsList = [SELECT Equifax_Report_URl__c,CIBIL_Report_URl__c,Applicant__r.Applicant_Type__c FROM CIBIL_Details__c WHERE Applicant__c =: applicantList[0].Id WITH SECURITY_ENFORCED ORDER BY CreatedDate Desc  LIMIT 1000];
                        wrapperObj.coBorrowerCibilRecord = cibilDetailsList[0];
                    }
                    wrapperObj.loanAppId = camList[0].Loan_Application__c;
                    // Start CISP-110
                }
                return wrapperObj;
            }
            return null;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('ViewCamController', 'getRequestDetailsForTractor', e.getTypeName(), e, [SELECT Loan_Application__c FROM CAM__c WHERE Id=:camId LIMIT 1].Loan_Application__c);
            return null;
        }
    }
    
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.18 - CAM Screen
* @Purpose: This method is used to provide the insurance details to IND_LWC_CAMViewInsurance cmp.
***********************************************/
    @auraenabled
    public static List<InsuranceDetails__c> getRelatedInsuranceDetails(String camId, String vehicleId){
        try {
            if(camId!=null){
                List<CAM__C> camList = new List<CAM__C>();
                camList = [SELECT Id,Loan_Application__c FROM CAM__c WHERE Id=:camId AND Loan_Application__c!=null  WITH SECURITY_ENFORCED LIMIT 1];
                if(!camList.isEmpty() && camList[0].Loan_Application__c!=null){
                    List<Applicant__C> applicantList = new List<Applicant__c>();
                    applicantList = [SELECT Id FROM Applicant__c WHERE Opportunity__c=:camList[0].Loan_Application__c AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED LIMIT 100];
                    if(!applicantList.isEmpty()){
                        List<InsuranceDetails__c> insuranceDetailsList = new List<InsuranceDetails__c>();
                        if(String.isNotBlank(vehicleId)){
                            insuranceDetailsList = [SELECT Amount__c,Funded_Premium__c,Funded_Non_funded__c,Name,Insurance_Plan__c,Is_Active__c,Product_Type__c,Applicant__r.Applicant_Type__c,Vehicle_Detail__r.Variant__c FROM InsuranceDetails__c WHERE Applicant__c IN: applicantList AND Loan_Application__c=:camList[0].Loan_Application__c AND Vehicle_Detail__c =: vehicleId WITH SECURITY_ENFORCED LIMIT 1000];
                        }else{
                            insuranceDetailsList = [SELECT Amount__c,Funded_Premium__c,Funded_Non_funded__c,Name,Insurance_Plan__c,Is_Active__c,Product_Type__c,Applicant__r.Applicant_Type__c,Vehicle_Detail__r.Variant__c FROM InsuranceDetails__c WHERE Applicant__c IN: applicantList AND Loan_Application__c=:camList[0].Loan_Application__c WITH SECURITY_ENFORCED LIMIT 1000];
                        }
                        return insuranceDetailsList;
                    }
                    return null;
                }
                return null;
            }
            return null;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('ViewCamController', 'getRelatedInsuranceDetails', e.getTypeName(), e, [SELECT Loan_Application__c FROM CAM__c WHERE Id=:camId LIMIT 1].Loan_Application__c);
            return null;
        }
    }
    
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.18 - CAM Screen
* @Purpose: This wrapper is used to sent cibil/equifax details to IND_LWC_CibilEquifax component.
***********************************************/
    public Class CAMInfoWrapper{
        @auraEnabled public string applicantId;  
        @auraEnabled public string reportURL;     
        @auraEnabled public string customerType;
        @auraEnabled public string coBorrowerApplicantId;
        @auraEnabled public string guarantorApplicantId;
        @auraEnabled public string loanAppId;
        @auraEnabled public string installmentType;
        @auraEnabled public Decimal emiAmount;
        @auraEnabled public Integer tenure;
        @auraEnabled public CIBIL_Details__c borrowerCibilRecord;
        @auraEnabled public CIBIL_Details__c coBorrowerCibilRecord;
        @auraEnabled public CIBIL_Details__c guarantorCibilRecord;
        @auraEnabled public CAM__c camRecord;
        @auraEnabled public List<String> appList;
    }
  
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.18 - CAM Screen
* @Purpose: This wrapper is used for annexture section for displaying files and preview them using fileId.
***********************************************/
    public class AnnexureWrapper{
        @auraenabled public string documentType{get;set;}
        @auraenabled public string documentName{get;set;}
        @auraenabled public string fileId{get;set;}
    }
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.18 - CAM Screen
* @Purpose: This wrapper is used for storing values from customer dedupe response to be shown in Gating & Screening section in VF page.
***********************************************/
    public Class DedupeDataWrapper{
        public string checkEligibilityMsg{get;set;}
        public string rvgdFlag{get;set;}
        public string fkFlag{get;set;}
        public string fraudChecks{get;set;}
        public DedupeDataWrapper(){
            checkEligibilityMsg = '';
            rvgdFlag = 'Not Found';
            fkFlag = 'Not Found';
            fraudChecks = 'Not Found';
        }
    }
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.18 - CAM Screen
* @Purpose: This wrapper is used for deserializing the customer dedupe response to fetch out some flags values.
***********************************************/
    public Class DedupeResoponseWrapper{
        public responseWrapper response;
    }
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.18 - CAM Screen
* @Purpose: This wrapper is used for deserializing the customer dedupe response to fetch out some flags values.
***********************************************/
    public class responseWrapper{
        // public String respDesc{get;set;}
        public list<content> content{get;set;}
        public String status{get;set;}
    }
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.18 - CAM Screen
* @Purpose: This wrapper is used for deserializing the customer dedupe response to fetch out some flags values.
***********************************************/
    public class InternalDedupeResponse{
        // public list<CustomerMaster> CustomerMaster{get;set;}
        public list<CustomerValidate> CustomerValidate{get;set;}
    }
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.18 - CAM Screen
* @Purpose: This wrapper is used for deserializing the customer dedupe response to fetch out some flags values.
***********************************************/
    public class ExternalDedupeResponse{
        public String DtCFDCUSTBAS{get;set;}
        public String CustomerValidate{get;set;}
        public String DtRECENTLEAD{get;set;}
        public String DEDUPE_STATUS{get;set;}
    }
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.18 - CAM Screen
* @Purpose: This wrapper is used for deserializing the customer dedupe response to fetch out some flags values.
***********************************************/
    public class Dealstatus{
        public String Deal_No{get;set;}
        public String Status_Flag{get;set;}
    }
    public class Gecl{//Start CISP-3119
        public String Deal_No{get;set;}
        public String Status_Flag{get;set;}
    }
    public class NPA{
        public String REFERENCE_NO{get;set;}
        public String NPATYPE{get;set;}
    }
    public class Restructure{
        public String Deal_Restructured{get;set;}
    }
    public class ARC{
        public String Deal_No{get;set;}
        public String ARC_Reference_No{get;set;}
        public String ARC_Buyer_Name{get;set;}
        public String ARC_Sale_Date{get;set;}
    }
    public class PanAlert{
        public String PAN{get;set;}
        public String Customer_Name{get;set;}
        public String Listing{get;set;}
        public String Remarks{get;set;}
        public String Source_Report_Date{get;set;}
    }
    public class CINAlert{
        public String PAN{get;set;}
        public String Customer_Name{get;set;}
        public String Listing{get;set;}
        public String Remarks{get;set;}
        public String Source_Report_Date{get;set;}
        
    }//End CISP-3119
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.18 - CAM Screen
* @Purpose: This wrapper is used for deserializing the customer dedupe response to fetch out some flags values.
***********************************************/
    public class Data{
        public list<InternalDedupeResponse> InternalDedupeResponse{get;set;}
        // public ExternalDedupeResponse ExternalDedupeResponse{get;set;}
    }
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.18 - CAM Screen
* @Purpose: This wrapper is used for deserializing the customer dedupe response to fetch out some flags values.
***********************************************/
    public class CustomerValidate{
        public list<NPA> NPA{get;set;}//Start CISP-3119
        public list<Restructure> Restructure{get;set;}
        public list<Dealstatus> Dealstatus{get;set;}
        public list<Gecl> Gecl{get;set;}
        public list<ARC> ARC{get;set;}
        public list<PanAlert> PanAlert{get;set;}
        public list<CustomerStatus> CustomerStatus{get;set;}
        public list<CINAlert> CINAlert{get;set;}//End CISP-3119
        public String CustomerCodeVal{get;set;}
        public BeneficiaryAlert BeneficiaryAlert{get;set;}
    }
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.18 - CAM Screen
* @Purpose: This wrapper is used for deserializing the customer dedupe response to fetch out some flags values.
***********************************************/
    public class CustomerStatus{
        public String Active_Flag{get;set;}
        public String Cross_Dedupe_Match_Id{get;set;}
    }
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.18 - CAM Screen
* @Purpose: This wrapper is used for deserializing the customer dedupe response to fetch out some flags values.
***********************************************/
    public class CustomerMaster{
        public String Matched_Customer_Code{get;set;}
        public String Rule_Matching_Fields{get;set;}
        public String CIC_No{get;set;}
        public String Current_Parameter_Value{get;set;}
        public String Aadhaar_No{get;set;}
        public String Matched_Parameter_Value{get;set;}
        public String Driving_License_Number{get;set;}
        public String Matched_Score{get;set;}
        public String Voter_ID_Number{get;set;}
        public String Rule_Field_Weightage{get;set;}
        public String Passport_Number{get;set;}
        public String Matched_Source{get;set;}
        public String PAN_GIR_Number{get;set;}
        public String Active_Flag{get;set;}
        public String Date_of_Birth{get;set;}
        public String Dedupe_Super_Match{get;set;}
        public String Customer_Type{get;set;}
        public String Dedupe_Super_Match_Score{get;set;}
        public String Customer_Name{get;set;}
        public String Rule_Id{get;set;}
        public String PEP_Remarks{get;set;}
        public String Type{get;set;}
    }
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.18 - CAM Screen
* @Purpose: This wrapper is used for deserializing the customer dedupe response to fetch out some flags values.
***********************************************/
    public class content{
        public Data Data{get;set;}
        public String ErrorDesc{get;set;}
    }
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.18 - CAM Screen
* @Purpose: This wrapper is used for deserializing the customer dedupe response to fetch out some flags values.
***********************************************/
    public class BeneficiaryAlert{
        public String Ben_code{get;set;}
        public String Status_Flag{get;set;}
        public String Beneficiary{get;set;}
        public String PAN_No{get;set;}
    }
    
    public class DeviationWrapper{
        public Deviation__c deviation {get;set;}
        public Boolean disabled {get;set;}
        public Boolean isNonMandatoryRole {get;set;}
        public Boolean finalDisableDeviation {get;set;}
        public Boolean fromParent {get;set;}
        
        public DeviationWrapper(Deviation__c deviation, Boolean disabled) {
            this.deviation = deviation;
            this.disabled = disabled;
            this.finalDisableDeviation = true;
            this.isNonMandatoryRole = false;
            this.fromParent = false;
        }
    }

    public class CoBorrowerWrapper{
        public String coBorrowerId {get;set;}
        public String applicantTitle {get;set;}
        public String applicantName {get;set;}
        public String relationshipWithBorrower {get;set;}
        public String age {get;set;}
        public String gender {get;set;}
        public String martialStatus {get;set;}
        public String profileName {get;set;}
        public String applicantRemarks {get;set;}
        public String cibilScore{get;set;}
        public Decimal highCreditOrSanctionedAmount {get;set;}
        public Decimal currentBalance {get;set;}
        public DateTime recentDate {get;set;}
        public DateTime oldestDate {get;set;}
        public Decimal writtenoffAmountTotal {get;set;}
        public String suitFiledOrWilfulDefault {get;set;}
        public Decimal amountOverdue {get;set;}
        public String nameOfPersonMet {get;set;}
        public Boolean customerHouseSameAsInApplication {get;set;}
        public String remarks {get;set;}
        public String applicantType {get;set;}

        public String employerBusinessName {get;set;}
        public String officeBusinessType {get;set;}
        public String totalExperienceYears {get;set;}
        public String businessPremise {get;set;}
        public String coordinatesVerified {get;set;}

        public String residenceType {get;set;}
        public String yearsInResidence {get;set;}
        public String yearsInCIty {get;set;}
        public String resCoordinatesVerified {get;set;}
        public Documents__c resiFiCoBorrowerDocMul {get;set;}
        public Documents__c officeFiCoBorrowerDocMul {get;set;}

        public String coBorrowerOfficeFiMul {get;set;}
        public String coBorrowerResiFiMul {get;set;}
        public String distanceFromBranch{get;set;}

        CoBorrowerWrapper(){
            this.applicantTitle = '';
            this.applicantName = '';
            this.distanceFromBranch='';
            this.relationshipWithBorrower = '';
            this.age = '';
            this.gender = '';
            this.martialStatus = '';
            this.profileName = '';
            this.applicantRemarks = '';
            this.cibilScore = '';
            this.highCreditOrSanctionedAmount= null;
            this.currentBalance = null;
            this.recentDate = null;
            this.oldestDate = null;
            this.writtenoffAmountTotal = null;
            this.suitFiledOrWilfulDefault = '';
            this.amountOverdue = null;
            this.nameOfPersonMet = '';
            this.customerHouseSameAsInApplication = false;
            this.remarks = '';

            this.employerBusinessName = '';
            this.officeBusinessType = '';
            this.totalExperienceYears = '';
            this.businessPremise = '';
            this.coordinatesVerified = '';

            this.residenceType = '';
            this.yearsInResidence = '';
            this.yearsInCIty = '';
            this.resCoordinatesVerified = '';
        }
    }
    
    public PageReference forwardThePrposalFromCAM(){
        try {
            ViewCamController ViewCamControllerObj = new ViewCamController();
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('ViewCAMController', 'forwardThePrposalFromCAM', e.getTypeName(), e, '');
        }
        return null; 
    }
    
    
    
    public Object doEmailServiceCallout(){
        Continuation con;
        String loanAppId;
        try{
            this.myString = Apexpages.currentPage().getParameters().get('emailRequestWrapper');
            String emailRequestWrapper = this.myString;
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.EmailService);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            //if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.EmailService);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }
            RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(emailRequestWrapper,'RequestWrapper');
            loanAppId = requestWrapper.loanApplicationId;
            loanApplicationRef= requestWrapper.loanApplicationId;
            IND_EmailServiceRequest emailServiceRequest = IND_EmailServiceService.getEmailServiceCallOutRequest(requestWrapper);
            CalloutProcessor processor= new CalloutProcessor(System.Label.EmailService, emailServiceRequest);
            HttpRequest request = processor.createHttpRequest();
            Long startTime = DateTime.now().getTime();
            carrier carri = new carrier();
            carri.setServiceName(System.Label.EmailService);
            carri.setProcessor(processor);
            carri.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carri.setEncryptedRequest(request.getBody());
            carri.setStartTime(startTime);     
            carri.setLoanApplicationId(loanAppId);
            carri.emailTo = requestWrapper.emailTo;
            carri.name = requestWrapper.name;
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processEmailServiceResponse';
            con.state=carri;
            carrier =carri;
            this.requestLabel = con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
                continuationLabel = con.addHttpRequest(request);
                continuationState = carri;
            } 
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('ViewCamController', 'doEmailServiceCallout', e.getTypeName(), e, loanAppId);
        }
        return con;
    }
    @TestVisible
    public static String continuationLabel;
    
    // Test variable used for holding the value of the Continuation.state attribute
    @TestVisible
    public static Object continuationState;
    
    public static String loanApplicationRef;
    
    /*
* @Method:      processEmailServiceResponse
* @Created by:  Satyam More 
* @Description: Callback method to return Response for Email Service API
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    public Object processEmailServiceResponse(){
        IND_EmailServiceResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        HttpResponse response;
        String elapseTime='';        
        String loanAppId='';
        try{            
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(requestLabel);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();
            IND_CAMWithoutSharing.createProposalLog(cam.Id, forwardTo, remarks, carrier.emailTo);//CISP-3019
            if(response != null && response.getStatusCode() == 200){
                apiResponse = (IND_EmailServiceResponse)processor.getHttpResponse(response, serviceName);
                if(apiResponse!=null){
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Success);
                } else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);               
                }
            } else {
                throw new IND_Exception(System.Label.NoResponse);
            } 
        } catch (Exception ex){
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('ViewCamController', 'processEmailServiceResponse', System.Label.Apex, ex, loanAppId);
        }
        return null;
    }
    @TestVisible
    public class Carrier {
        public transient string request;
        public transient string encryptedRequest;
        public transient String serviceName;
        public transient CalloutProcessor processor;
        public transient Long startTime;
        public transient String loanApplicationId;
        public transient List<Object> tempObject;
        public transient string emailTo;
        public transient string name;
        
        Public Carrier(){}
        
        Carrier(String serviceName, CalloutProcessor processor, String encryptRequest, Long startTime, String loanAppId, String plainRequest){
            this.serviceName = serviceName;
            this.processor = processor;
            this.encryptedRequest = encryptRequest;
            this.startTime = startTime;
            this.loanApplicationId = loanAppId;
            this.request = plainRequest;
        }
        
        void setTempObject(List<Object> tempObject){
            this.tempObject = tempObject;
        }
        public List<Object> getTempObject(){
            return tempObject;
        }
        
        void setRequest(String request){
            this.request = request;
        }
        public String getRequest(){
            return request;
        }        
        void setEncryptedRequest(String encryptedRequest){
            this.encryptedRequest = encryptedRequest;
        }        
        public String getEncryptedRequest(){
            return encryptedRequest;
        }
        void setProcessor(CalloutProcessor processor){
            this.processor = processor;
        }       
        public CalloutProcessor getProcessor(){
            return processor;
        }       
        void setServiceName(String serviceName){
            this.serviceName = serviceName;
        }        
        public String getServiceName(){
            return serviceName;
        }
        void setStartTime(Long startTime){
            this.startTime = startTime;
        }
        public Long getStartTime(){
            return startTime;
        } 
        void setLoanApplicationId(String loanApplicationId){
            this.loanApplicationId = loanApplicationId;
        }
        public String getLoanApplicationId(){
            return loanApplicationId;
        }
    }
    @AuraEnabled
    public static List<loanDetailWrapper> getloanDetailWrapperDetails(Opportunity oppLoan, Map<Id, Vehicle_Detail__c> vehicleIdVsVehicleMap, List<Final_Term__c> finaltermsList){
        try {
            System.debug(oppLoan);
            System.debug(vehicleIdVsVehicleMap);
            System.debug(finaltermsList);
            List<loanDetailWrapper> loanDetailWrapperList = new List<loanDetailWrapper>();
            Map<Id,Documents__c> valuationReports=new Map<Id,Documents__c>([select Id, Vehicle_Detail__c  from Documents__c where is_Active__c =TRUE AND Opportunity_Relation__c=:oppLoan.Id AND Document_Type__c='Valuation Report'LIMIT 50]);
            Set<Id> reportSet = valuationReports.keySet();

            // Valuation Reports for TF
             Map<String,String> vehicleReportMap=new Map<String,String>();
            if(oppLoan.Product_Type__c==Label.Tractor && !valuationReports.isEmpty()){
             List<ContentDocumentLink> contentDocLinkList = [SELECT LinkedEntityId,ContentDocumentId, ContentDocument.LatestPublishedVersionId FROM ContentDocumentLink WHERE (LinkedEntityId IN:reportSet) WITH SECURITY_ENFORCED LIMIT 10000];
                    Set<Id> contentDocIdSet = new Set<Id>();
                    for (Documents__c docObj : valuationReports.values()) {
                        for(ContentDocumentLink conLinkObj:contentDocLinkList){
                            if(docObj.Id==conLinkObj.LinkedEntityId){
                                vehicleReportMap.put(docObj.Vehicle_Detail__c, conLinkObj.ContentDocument.LatestPublishedVersionId);
                            }
                        }
                    } 
            }    
                      
            Map<String,Decimal> dlpVariantMap = getDLPVariant(finaltermsList);
            List<Exposure__c> expoList = [SELECT Id,SOH__c,Type__c  from Exposure__c where Loan_Application__c =:oppLoan.Id and Type__c = 'Borrower Exposure' limit 1];
            for (Final_Term__c finalTermObj : finaltermsList) {
                Decimal minInvDlp = dlpVariantMap.containsKey(finaltermObj.Vehicle_Detail__r.Variant_Code__c) ? dlpVariantMap.get(finaltermObj.Vehicle_Detail__r.Variant_Code__c) : 0;
                GrossNetLTVWrapper resultWrapperObj = getGrossNetLTVTractor(finalTermObj,expoList, minInvDlp);
                Vehicle_Detail__c veh  = vehicleIdVsVehicleMap.get(finalTermObj.Vehicle_Detail__c);
                loanDetailWrapper loanDetailObj = new loanDetailWrapper();
                loanDetailObj.Name = veh.Variant__c;
                loanDetailObj.vehicleRecId = veh.Id;
                if(veh!=null && veh.Valuer_category__c!=null && veh.Valuer_category__c =='MFC'){
                  loanDetailObj.valuationReportURL = veh?.MFC_valuation_Report_URL__c;
                }
                else if(veh!=null && veh.Valuer_category__c!=null && veh.Valuer_category__c =='Empanelled'){
                  if(vehicleReportMap.containsKey(veh.Id) && vehicleReportMap.get(veh.Id)!=null)
					loanDetailObj.valuationReportURL=vehicleReportMap.get(veh.Id);
                }
                loanDetailObj.finalRecId = finalTermObj.Id;
                loanDetailObj.finalRec = finalTermObj;
                loanDetailObj.installmentToIncomeRatio = finalTermObj.Installment_To_Income_Ratio__c != null ? (Decimal)((finalTermObj.Installment_To_Income_Ratio__c * 100).setScale(2)) + '%' : '';
                loanDetailObj.vehicleRec = veh;
                loanDetailObj.fiScoreBand = finalTermObj.Fi_Score_Band__c;
                loanDetailObj.assetMfg = veh.Variant__c;
                loanDetailObj.yearOfManufacture = veh.Manufacturer_Year_Month__c!=null ? veh.Manufacturer_Year_Month__c.substringBefore('-') : '';
                loanDetailObj.assetCategory = Utilities.getAssetCategory(oppLoan, veh);// tbM
                loanDetailObj.vehicleId = veh.Variant__c;
                loanDetailObj.purposeofPurchase = veh.Purpose_of_purchase__c;
                loanDetailObj.dealerSubDealerName = veh.Dealer_Sub_dealer_name__c;
                loanDetailObj.rCLimitEnabledDealer = veh.RC_limit_enabled_Dealer__c ? 'Yes':'No';
                loanDetailObj.schemeType = finalTermObj.Schemes__r.Name;
                loanDetailObj.tradeAdvance = finalTermObj.Trade_certificate__c;
                loanDetailObj.invoiceAmount = String.valueOf(veh.Invoice_Price__c);

                Decimal basePrice = veh.Base_Prices__c!=null?veh.Base_Prices__c:0;
                Decimal basicPrice = veh.Basic_Price__c!=null?veh.Basic_Price__c:0;
                Decimal istInsurancePremium = veh.X1st_yr_Insurance_Premium__c!=null?veh.X1st_yr_Insurance_Premium__c:0;
                Decimal gstAmount = veh.GST_Amount__c!=null?veh.GST_Amount__c:0;
                Decimal totalFundedInsurancePremium = veh.Total_Funded_Amount__c!=null?veh.Total_Funded_Amount__c:0;
                Decimal finalLoanAmount = finalTermObj.Loan_Amount__c!=null?Decimal.valueOf(finalTermObj.Loan_Amount__c)+totalFundedInsurancePremium:totalFundedInsurancePremium;
                if(finalTermObj.Advance_EMI__c){
                    loanDetailObj.advanceEmiAmount = String.valueOf(finalTermObj.EMI_Amount__c);
                }
                if(oppLoan.Vehicle_Type__c == 'New'){
                    // loanDetailObj.invoiceAmount = String.valueOf((basicPrice+istInsurancePremium+gstAmount).setScale(2));
                    loanDetailObj.vehicleBasicPrice = basicPrice!=null ? String.valueOf(basicPrice) : '';
                    if(finalLoanAmount!=null && minInvDlp!=null && minInvDlp!=0){
                        //loanDetailObj.dlpLTV = String.valueOf(((finalLoanAmount/minInvDlp).setScale(2))*100);
                        loanDetailObj.dlpLTV = String.valueOf((((finalLoanAmount/minInvDlp))*100).setScale(2)); //SFTRAC-1675
                    }
                    
                    loanDetailObj.grossLTV = (finalTermObj.Calculated_Gross_LTV__c == null || finalTermObj.Is_Loan_Amount_Change_From_CAM__c) ? resultWrapperObj.ltvWithInsurance : String.valueOf(finalTermObj.Calculated_Gross_LTV__c);
                    
                    loanDetailObj.netLTV = (finalTermObj.Calculated_Net_LTV__c == null || finalTermObj.Is_Loan_Amount_Change_From_CAM__c) ? resultWrapperObj.ltvWithoutInsurance : String.valueOf(finalTermObj.Calculated_Net_LTV__c);
                }
                else if(oppLoan.Vehicle_Type__c=='Used' || oppLoan.Vehicle_Type__c=='Refinance'){
                    Decimal minRsvIdvValuation;
                    if (veh.Insurance_declared_value__c != null && veh.Valuation_price__c != null && veh.Grid_value__c != null) {
                        minRsvIdvValuation = Math.min(Math.min(veh.Insurance_declared_value__c, veh.Valuation_price__c), veh.Grid_value__c);
                    } else if (veh.Insurance_declared_value__c != null && veh.Valuation_price__c != null) {
                        minRsvIdvValuation = Math.min(veh.Insurance_declared_value__c, veh.Valuation_price__c);
                    } else if (veh.Insurance_declared_value__c != null && veh.Grid_value__c != null) {
                        minRsvIdvValuation = Math.min(veh.Insurance_declared_value__c, veh.Grid_value__c);
                    } else if (veh.Valuation_price__c != null && veh.Grid_value__c != null) {
                        minRsvIdvValuation = Math.min(veh.Valuation_price__c, veh.Grid_value__c);
                    } else if (veh.Insurance_declared_value__c != null) {
                        minRsvIdvValuation = veh.Insurance_declared_value__c;
                    } else if (veh.Valuation_price__c != null) {
                        minRsvIdvValuation = veh.Valuation_price__c;
                    } else if (veh.Grid_value__c != null) {
                        minRsvIdvValuation = veh.Grid_value__c;
                    }
                    loanDetailObj.vehicleBasicPrice = minRsvIdvValuation!=null ? String.valueOf(minRsvIdvValuation) : '';
                    
                    loanDetailObj.grossLTV = (finalTermObj.Calculated_Gross_LTV__c == null || finalTermObj.Is_Loan_Amount_Change_From_CAM__c) ? resultWrapperObj.ltvWithInsurance : String.valueOf(finalTermObj.Calculated_Gross_LTV__c);

                    loanDetailObj.netLTV = (finalTermObj.Calculated_Net_LTV__c == null || finalTermObj.Is_Loan_Amount_Change_From_CAM__c) ? resultWrapperObj.ltvWithoutInsurance : String.valueOf(finalTermObj.Calculated_Net_LTV__c);

                    if(finalLoanAmount!=null && veh.Grid_value__c!=null && veh.Grid_value__c!=0){
                        loanDetailObj.rsvLTV = String.valueOf(((finalLoanAmount/veh.Grid_value__c)*100).setScale(2));
                    }
                    if(finalLoanAmount!=null && veh.Valuation_price__c!=null && veh.Valuation_price__c!=0){
                        loanDetailObj.valuationLTV = String.valueOf(((finalLoanAmount/veh.Valuation_price__c)*100).setScale(2));
                    }
                    if(finalLoanAmount!=null && veh.Insurance_declared_value__c!=null && veh.Insurance_declared_value__c!=0){
                        loanDetailObj.idvLTV = String.valueOf(((finalLoanAmount/veh.Insurance_declared_value__c)*100).setScale(2));
                    }
                    // loanDetailObj.invoiceAmount = 'NA';
                }
                loanDetailObj.totalPayInAmount = 0;
                loanDetailObj.totalPayOutAmount = 0;
                loanDetailObj.totalDealerPayout = 0;
                loanDetailObj.totalPayOutAmountPer = '';
                if(finalTermObj.Holiday_period__c != null && finalTermObj.Tenure__c != null){
                    if(oppLoan.Product_Type__c==Label.Tractor){
                       loanDetailObj.numberOfInstalments=String.valueof(Integer.valueOf(finalTermObj.No_of_Installment__c));
                    }else if(Integer.valueOf(finalTermObj.Holiday_period__c) == 0){
                        loanDetailObj.numberOfInstalments = String.valueOf(Integer.valueOf(finalTermObj.Tenure__c));
                    } else if(Integer.valueOf(finalTermObj.Holiday_period__c) == 30){
                        loanDetailObj.numberOfInstalments = String.valueOf(Integer.valueOf(finalTermObj.Tenure__c) -1);
                    }
                }
                loanDetailObj.totalPayInAmount += finalTermObj.Service_Charges__c != null ? Decimal.valueOf(finalTermObj.Service_Charges__c) : 0;
                loanDetailObj.totalPayInAmount += finalTermObj.Documentation_Charges__c != null ? Decimal.valueOf(finalTermObj.Documentation_Charges__c) : 0;
                loanDetailObj.totalPayInAmount += finalTermObj.Dlr_Exp_Reimburse_Amt__c != null ? Decimal.valueOf(finalTermObj.Dlr_Exp_Reimburse_Amt__c) : 0;
                loanDetailObj.totalPayInAmount += finalTermObj.Mfr_Exp_Reimburse_Amt__c != null ? Decimal.valueOf(finalTermObj.Mfr_Exp_Reimburse_Amt__c) : 0;
                loanDetailObj.totalPayOutAmount += finalTermObj.Gift_through_Dealer_Amount__c != null ? Decimal.valueOf(finalTermObj.Gift_through_Dealer_Amount__c) : 0;
                loanDetailObj.totalPayOutAmount += finalTermObj.Mfr_Incentive__c != null ? Decimal.valueOf(finalTermObj.Mfr_Incentive__c) : 0;
                loanDetailObj.totalPayOutAmount += finalTermObj.DSM_Incentive1__c != null ? Decimal.valueOf(finalTermObj.DSM_Incentive1__c) : 0;
                loanDetailObj.totalPayOutAmount += finalTermObj.DSM_Incentive2__c != null ? Decimal.valueOf(finalTermObj.DSM_Incentive2__c) : 0;
                loanDetailObj.totalPayOutAmount += finalTermObj.Dealer_incentive_amount_main_dealer__c != null ? Decimal.valueOf(finalTermObj.Dealer_incentive_amount_main_dealer__c) : 0; 
                if(loanDetailObj.totalPayOutAmount != null && finalLoanAmount != null){
                    loanDetailObj.totalPayOutAmountPer = String.valueOf(((loanDetailObj.totalPayOutAmount / (finalLoanAmount)) * 100).setScale(2));
                }
                loanDetailObj.sellingPrice = String.valueOf(veh.Selling_Price__c);
                if(oppLoan.Vehicle_Type__c == 'New'){
                    loanDetailObj.dLPRSVPrice = String.valueof(minInvDlp);
                }else{
                    loanDetailObj.dLPRSVPrice = String.valueOf(veh.Grid_value__c);
                }
                loanDetailObj.tenure = finalTermObj.Tenure__c;
                loanDetailObj.moratorium = finalTermObj.Holiday_period__c;
                loanDetailObj.proposedEMI = String.valueOf(finalTermObj.EMI_Amount__c);
                loanDetailObj.cRMIRR = String.valueOf(finalTermObj.Required_CRM_IRR__c);
                loanDetailObj.servicecharges = finalTermObj.Service_charges__c;
                loanDetailObj.documentationcharges = finalTermObj.Documentation_charges__c;
                loanDetailObj.dSMIncentive1 = finalTermObj.DSM_Incentive1__c;
                loanDetailObj.dSMIncentive2 = finalTermObj.DSM_Incentive2__c;
                loanDetailObj.dealerIncentiveAmountMainDealer = finalTermObj.Dealer_incentive_amount_main_dealer__c;
                loanDetailObj.referredby = finalTermObj.Refered_By__c;
                loanDetailObj.referrerName = finalTermObj.Referrer_Name__c;
                loanDetailObj.referrerIncentive = finalTermObj.Rreferrer_Incentive__c;
                loanDetailObj.gROSSIRR = String.valueOf(finalTermObj.Gross_IRR__c);
                loanDetailObj.proposalMCLR = '';
                List<Schema.PicklistEntry> values = Final_Term__c.Repayment_mode__c.getDescribe().getPicklistValues();
                Map<String,String> statusApiToLabelMap = new Map<String,String>();
                if(oppLoan.Product_Type__c==Label.Tractor){
                    for(Schema.PicklistEntry sp : values){
                      statusApiToLabelMap.put(sp.getValue(),sp.getLabel());
                    }
                    if(statusApiToLabelMap.containsKey(finalTermObj.Repayment_mode__c)){
                        loanDetailObj.repaymentmode=statusApiToLabelMap.get(finalTermObj.Repayment_mode__c);
                    }
                }else{
                    loanDetailObj.repaymentmode = finalTermObj.Repayment_mode__c;
                }            
                loanDetailObj.leadSource = finalTermObj.Refered_By__c;
                loanDetailObj.rCLimit = veh.Can_we_continue_with_above_RC_limit__c ? 'Yes': 'No';
                loanDetailObj.loanAmountWithInsurance = String.valueOf(finalLoanAmount);
                loanDetailObj.loanAmountWithoutInsurance = finalTermObj.Loan_Amount__c; 
                loanDetailWrapperList.add(loanDetailObj);  
            }
            return loanDetailWrapperList;
        }catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('ViewCamController', 'getloanDetailWrapperDetails', e.getTypeName(), e, '');
            return null;
        }
        
    }

    public class incomeWrapper{
        public String applicantTitle {get;set;}
        public String legalEntity {get;set;}
        public String income {get;set;}
        public String recipientBank {get;set;}
        public String employeeType {get;set;}
        public String businessName {get;set;}
        public String profileName {get;set;}
    }
    
    public class loanDetailWrapper{
        public String Name {get;set;}
        public String assetMfg {get;set;}
        public String assetCategory {get;set;}
        public String vehicleId {get;set;}
        public String valuationReportURL{get;set;}
        public String purposeofPurchase {get;set;}
        public String yearOfManufacture {get;set;}
        public String dealerSubDealerName {get;set;}
        public String rCLimitEnabledDealer {get;set;}
        public String schemeType {get;set;}
        public String subSchemeType {get;set;}
        public String tradeAdvance {get;set;}
        public String invoiceAmount {get;set;}
        public String dLPRSVPrice {get;set;}
        public String basicPrice {get;set;}
        public String vehicleBasicPrice {get;set;}
        public String dlpLTV {get;set;}
        public String rsvLTV {get;set;}
        public String valuationLTV {get;set;}
        public String idvLTV {get;set;}
        public String loanAmount {get;set;}
        public String grossLTV {get;set;}
        public String netLTV {get;set;}
        public String tenure {get;set;}
        public String moratorium {get;set;}
        public String advanceEmiAmount {get;set;}
        public String proposedEMI {get;set;}
        public String cRMIRR {get;set;}
        public Decimal totalPayInAmount {get;set;}
        public String servicecharges {get;set;}
        public String documentationcharges {get;set;}
        public Decimal totalPayOutAmount {get;set;}
        public String dSMIncentive1 {get;set;}
        public String dSMIncentive2 {get;set;}
        public String dealerIncentiveAmountMainDealer {get;set;}
        public String referredby {get;set;}
        public String referrerName {get;set;}
        public String referrerIncentive {get;set;}
        public Decimal dealerPayout {get;set;}
        public String gROSSIRR {get;set;}
        public String proposalMCLR {get;set;}
        public String repaymentmode {get;set;}
        public String leadSource {get;set;}
        public String crossSell {get;set;}
        public String rCLimit {get;set;}
        public String loanAmountWithInsurance {get;set;}
        public String loanAmountWithoutInsurance {get;set;}        
        public Decimal totalDealerPayout {get;set;}        
        public String numberOfInstalments {get;set;}        
        public String sellingPrice {get;set;}    
        public String vehicleRecId {get;set;}            
        public String finalRecId {get;set;}            
        public String fiScoreBand {get;set;}            
        public Final_Term__c finalRec {get;set;}            
        public Vehicle_Detail__c vehicleRec {get;set;}            
        public String installmentToIncomeRatio {get;set;}   
        public String totalPayOutAmountPer {get;set;}          
    }

    @AuraEnabled
    public static CAMInfoWrapper finalTermDetails(String vehicleId){
        CAMInfoWrapper wrapperObj = new CAMInfoWrapper();
        if(String.isNotBlank(vehicleId)){
            List<Final_Term__c> finalTermList = [SELECT Id, EMI_Amount__c,Holiday_period__c, Tenure__c,Installment_Type__c,Loan_Application__c FROM Final_Term__c WHERE Vehicle_Detail__c =: vehicleId WITH SECURITY_ENFORCED LIMIT 1];        
            if (finalTermList.size() > 0) {
                wrapperObj.emiAmount = finalTermList[0].EMI_Amount__c;
                wrapperObj.installmentType = finalTermList[0].Installment_Type__c;
                wrapperObj.loanAppId = finalTermList[0].Loan_Application__c;
                if(finalTermList[0].Holiday_period__c != null && finalTermList[0].Tenure__c != null){
                    if(Integer.valueOf(finalTermList[0].Holiday_period__c) == 0){
                        wrapperObj.tenure = Integer.valueOf(finalTermList[0].Tenure__c);
                    } else if(Integer.valueOf(finalTermList[0].Holiday_period__c) == 30){
                        wrapperObj.tenure = Integer.valueOf(finalTermList[0].Tenure__c) -1;
                    }
                }else{
                    wrapperObj.tenure = finalTermList[0].Tenure__c != null ? Integer.valueOf(finalTermList[0].Tenure__c) : null;
                }
            }
        }
        return wrapperObj;            
    }
    @RemoteAction
    public static Integer getVehiclePurchaseprice(String finalTermId){
        List<Final_Term__c> finalTermList = [SELECT Id, Vehicle_Detail__c, Loan_Application__c FROM Final_Term__c WHERE Id =: finalTermId WITH SECURITY_ENFORCED LIMIT 1]; 
        return IND_OfferScreenController.getPurchaseprice(finalTermList[0].Loan_Application__c, finalTermList[0].Vehicle_Detail__c);
    }
    @AuraEnabled
    public static boolean isTractorLead(String camId){
        return [SELECT Id from CAM__c WHERE Id =: camId AND Loan_Application__r.Product_Type__c =: Label.Tractor].size() > 0;
    }

    @AuraEnabled
    public static List<IND_OfferScreenController.RepaymentWrapper> emiRepaymentSchedule(String vehicleId){
        List<Final_Term__c> finalTermList = [Select Id,Loan_Deal_Date__c,Installment_Frequency__c,First_EMI_Date__c,Second_EMI_Date__c,Tenure__c,Required_CRM_IRR__c,Vehicle_Detail__r.Total_Funded_Amount__c,Loan_Amount__c,Advance_EMI__c From Final_Term__c Where Vehicle_Detail__c =: vehicleId];
        Decimal principal = finalTermList[0].Loan_Amount__c != null ? Decimal.valueOf(finalTermList[0].Loan_Amount__c) + (finalTermList[0].Vehicle_Detail__r.Total_Funded_Amount__c == null ? 0 : finalTermList[0].Vehicle_Detail__r.Total_Funded_Amount__c) : 0;
        String irr = finalTermList[0].Required_CRM_IRR__c;
        Date loanDate = finalTermList[0].Loan_Deal_Date__c;
        Integer increment = finalTermList[0].Tenure__c != null ? Integer.valueof(finalTermList[0].Tenure__c) : 0;
        Integer day;
        String frequency = '1';
        if(finalTermList[0].Installment_Frequency__c ==  'Monthly'){
            frequency = '1';
        }else if(finalTermList[0].Installment_Frequency__c ==  'bi-monthly'){
            frequency = '2';
        }else if(finalTermList[0].Installment_Frequency__c ==  'Quarterly'){
            frequency = '3';
        }else if(finalTermList[0].Installment_Frequency__c ==  'Half yearly'){
            frequency = '6';
        }
        Date repaymentDate = finalTermList[0].First_EMI_Date__c;
        Date secondEMI = finalTermList[0].Second_EMI_Date__c;
        Boolean advanceEMI = finalTermList[0].Advance_EMI__c;
        return IND_OfferScreenController.emiRepaymentSchedule(principal, irr, loanDate, increment, day, frequency, repaymentDate, secondEMI, advanceEMI);
    }
    @AuraEnabled
    public static GrossNetLTVWrapper getGrossNetLTVTractor(Final_Term__c finalTermObj, List<Exposure__c> expoList, Decimal minInvDlp){
        GrossNetLTVWrapper responseJSON = new GrossNetLTVWrapper();

        if(finalTermObj != null){
            Decimal premiumFunding = finalTermObj.Vehicle_Detail__r.Total_Funded_Amount__c == null ? 0 : finalTermObj.Vehicle_Detail__r.Total_Funded_Amount__c;
            Double loanAmountValue = finaltermobj.Loan_amount__c != '' ? Double.valueOf(finaltermobj.Loan_Amount__c) : 0;

            if(finalTermObj.Loan_Application__r.isTopUpLoan__c){
                Double sohValue = expoList.size() > 0 && expoList[0]?.SOH__c != null ? expoList[0].SOH__c : 0;
                Double rsvValue = finalTermObj.Vehicle_Detail__r.Grid_value__c != null ? finalTermObj.Vehicle_Detail__r.Grid_value__c : 0;
                Double idvValue = finalTermObj.Vehicle_Detail__r.Insurance_declared_value__c != null ? finalTermObj.Vehicle_Detail__r.Insurance_declared_value__c : 0;
                Double valuationAmount = finalTermObj.Vehicle_Detail__r.Valuation_price__c != null ? finalTermObj.Vehicle_Detail__r.Valuation_price__c : 0;
                Double minValue = 0;

                List<Double> doubleList = new List<Double>();
                if(rsvValue != 0){
                    doubleList.add(rsvValue);
                } 
                if(idvValue != 0){
                    doubleList.add(idvValue);
                }
                if(valuationAmount != 0){
                    doubleList.add(valuationAmount);
                }
                minValue = IND_CAMWithoutSharing.getMinimumValue(doubleList);
                if(minValue != null && minValue != 0){
                    //responseJSON.ltvWithInsurance = String.valueOf(((sohValue+loanAmountValue+premiumFunding)/minValue).setScale(2)*100);
                    responseJSON.ltvWithInsurance = String.valueOf((((sohValue+loanAmountValue+premiumFunding)/minValue)*100).setScale(2)); //SFTRAC-1675
                    Decimal result = (sohValue+loanAmountValue)/(minValue);
                    //responseJSON.ltvWithoutInsurance = String.valueOf((result)*100);
                    responseJSON.ltvWithoutInsurance = String.valueOf(((result)*100).setScale(2)); //SFTRAC-1675
                }
            }else if(finalTermObj.Loan_Application__r.Vehicle_Type__c != System.Label.new){
                Decimal minimumValue = 0;
                if(finalTermObj?.Vehicle_Detail__r.Grid_value__c == null){finalTermObj.Vehicle_Detail__r.Grid_value__c = 0;}
                if(finalTermObj?.Vehicle_Detail__r.Valuation_price__c == null){finalTermObj.Vehicle_Detail__r.Valuation_price__c = 0;}
                if(finalTermObj?.Vehicle_Detail__r.Insurance_declared_value__c == null){finalTermObj.Vehicle_Detail__r.Insurance_declared_value__c = 0;}

                List<Double> doubleList = new List<Double>();
                if(finalTermObj.Vehicle_Detail__r.Grid_value__c != 0){
                    doubleList.add(finalTermObj.Vehicle_Detail__r.Grid_value__c);
                } 
                if(finalTermObj.Vehicle_Detail__r.Valuation_price__c != 0){
                    doubleList.add(finalTermObj.Vehicle_Detail__r.Valuation_price__c);
                }
                if(finalTermObj.Vehicle_Detail__r.Insurance_declared_value__c != 0){
                    doubleList.add(finalTermObj.Vehicle_Detail__r.Insurance_declared_value__c);
                }
                minimumValue = IND_CAMWithoutSharing.getMinimumValue(doubleList);
                if(minimumValue != null && minimumValue != 0){
                    //responseJSON.ltvWithInsurance = ((loanAmountValue + premiumFunding) / minimumValue).setScale(2)!=null ? String.valueOf(((loanAmountValue + premiumFunding) / minimumValue).setScale(2)*100):null;
                    responseJSON.ltvWithInsurance = ((loanAmountValue + premiumFunding) / minimumValue).setScale(2)!=null ? String.valueOf((((loanAmountValue + premiumFunding) / minimumValue)*100).setScale(2)):null; //SFTRAC-1675
                    //responseJSON.ltvWithoutInsurance =(loanAmountValue / minimumValue).setScale(2)!= null ? String.valueOf((loanAmountValue  / minimumValue).setScale(2)*100) :null;
                    responseJSON.ltvWithoutInsurance =(loanAmountValue / minimumValue).setScale(2)!= null ? String.valueOf(((loanAmountValue  / minimumValue)*100).setScale(2)) :null; //SFTRAC-1675
                }
            }else if(finalTermObj.Loan_Application__r.Vehicle_Type__c == System.Label.new){
                Decimal orpValue;
                Decimal invoicePrice = finalTermObj.Vehicle_Detail__r.Invoice_Price__c != null ? finalTermObj.Vehicle_Detail__r.Invoice_Price__c : 0;
                /*Decimal minOrpValue = 999999999;
                if (invoicePrice > 0) minOrpValue = Math.min(minOrpValue, invoicePrice);
                if (minInvDlp > 0) minOrpValue = Math.min(minOrpValue, minInvDlp);
                orpValue = minOrpValue;*/

                orpValue = Math.min(minInvDlp, invoicePrice);

                //responseJSON.ltvWithInsurance = String.valueOf(((loanAmountValue+premiumFunding)/(orpValue)).setScale(2)*100);
                responseJSON.ltvWithInsurance = String.valueOf((((loanAmountValue+premiumFunding)/(orpValue))*100).setScale(2)); //SFTRAC-1675
                Decimal result = (loanAmountValue)/(orpValue);
                //responseJSON.ltvWithoutInsurance = String.valueOf((result.setScale(2))*100);
                responseJSON.ltvWithoutInsurance = String.valueOf(((result)*100).setScale(2)); //SFTRAC-1675
            }
        }
        return responseJSON;
    }

    public class GrossNetLTVWrapper {
        public String ltvWithInsurance {get;set;}
        public String ltvWithoutInsurance {get;set;}

        GrossNetLTVWrapper(){
            this.ltvWithInsurance = '';
            this.ltvWithoutInsurance = '';
        }
    }

    @AuraEnabled
    public static Map<String,Decimal> getDLPVariant(List<Final_Term__c> finalTermList){
        Map<String,Decimal> dlpMasterMAP = new Map<String,Decimal>();
        String loanAppId = null;
        Set<String> variantSet = new Set<String>();
        for (Final_Term__c finalTermObj : finalTermList) {
            loanAppId = finaltermobj.Loan_Application__c;
            variantSet.add(finaltermObj.Vehicle_Detail__r.Variant_Code__c);
        }
        String cfdStateCode = Utilities.getCFDStateCode([SELECT Id,Agent_BL_code__c FROM Opportunity WHERE Id =: loanAppId LIMIT 1].Agent_BL_code__c, 'T');
        List<TBM_Product_Variant_dt__c> dlpMasterList = [SELECT Id, State_Code__c, Product_Variant_Code__c,Dealer_Landed_Price__c, Segment_Grade__c,Unique_State_Code__c FROM TBM_Product_Variant_dt__c Where State_Code__c =: cfdStateCode AND Product_Variant_Code__c IN : variantSet];
        
        for(TBM_Product_Variant_dt__c dlpMasterRec: dlpMasterList){
            if(!dlpMasterMAP.containsKey(dlpMasterRec.Product_Variant_Code__c)){
                dlpMasterMAP.put(dlpMasterRec.Product_Variant_Code__c,dlpMasterRec.Dealer_Landed_Price__c);
            }
        }
        return dlpMasterMAP;
    }
}