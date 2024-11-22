/**
* @Name         BEUserMappingInformation
* @Author       Raman Raj Saxena
* @Company      Salesforce
* @Description  This is a web service class to get the BE user mapping information
* Inputs:       None
* Test Class:   BEUserMappingInformationTest
*/
@RestResource(urlMapping='/getBEUserInfo/*')
global with sharing class BEUserMappingInformation {
    /*
* @Method:      getBEInformation
* @Created by:  Raman Raj Saxena
* @Description: Method to return Response which contains userId, userName and contactNumber of BE user.
* @Param:       None
* @Return:     String - response
*/
    @HttpPost
    global static void getBEInformation() {
        
        RestRequest request = RestContext.request;
        String pincodeRequest = request.requestBody.toString();
        PincodeRequestData reqData =(PincodeRequestData) JSON.deserialize(pincodeRequest,PincodeRequestData.class);
        String response = getBEInformation(reqData.pincode, reqData.productType, reqData.loanApplicationId, reqData.isAggregator,null);
        //create Integration Log
        IntegrationUtilities.createIntegrationLogger(pincodeRequest, pincodeRequest, response, response, 'BEUserMappingInformation', null,reqData.loanApplicationId);
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(response);
    }

        /*
* @Method:      getBEInformation
* @Created by:  Siddhesh Jawale, Rahul Sharma
* @Description: Method to return Response which contains userId, userName and contactNumber of BE user.
* @Param:       None
* @Return:     String - response
*/
/**
 * consolidated summary of BE/MO mapping logic in D2C.

    1. The BE/MO - Pin code mapping table will store BLCode, PinCode, Product Type and Vehicle Type information.
    2. Based on Pincode, product Type and vehicle type sent by IBM logic will check for related BLCodes in the above table.
    3. Using above BLCodes logic will query accounts with the same BLCodes.
    4. Then we will find related Account Team Members (BE/ MO users ) related to those accounts.
    5. In 2W, If no active user is found then we will check the active MOs available in the same State. 
    6. In PV if no active user is found then we will return 'No BE found' message.     
    7. In Both PV and 2W we will apply round robin on BE and MO which means we will assign the applications to the users one by one (order is not important) to properly distribute the applications.
    8. If in point 2 no Pincode-BLCode mapping is found then we will return 'No BE found' or ''No MO Found' respectively to PV and 2W.

*/
    public static String getBEInformation(String pincode, String productType, String loanId, Boolean isAggregator, String vehicleTypeAggregator) {
        if(isAggregator == NULL) { isAggregator = FALSE; }
        //If either of them are blank, return null
        if(String.isBlank(pincode) || String.isBlank(productType)){
            return errorResponse('Pincode and Product Type are required.');
        }

        List<Opportunity> loanApps = new List<Opportunity>();
        String vehicleType = null;
        if(!String.isBlank(loanId)) {
            loanApps = [SELECT Id, LeadSource, Vehicle_Type__c, mapped_BE__c, BE_mapping_date__c FROM Opportunity WHERE Id =: loanId];// Added LeadSource field for CISP-8659  
            vehicleType = loanApps[0].Vehicle_Type__c;
        }else if(String.isBlank(vehicleType) && String.isNotBlank(vehicleTypeAggregator)){
            vehicleType = vehicleTypeAggregator;
        }
        Decimal pincodeVal = Decimal.valueOf(pincode);
        String query = 'SELECT Id, Name, BL_Code__c, Pin_Code__c from D2C_BE_Master__c WHERE Pin_code__c =: pincodeVal AND Product_Type__c =: productType AND BL_Code__c != NULL ';
        if(String.isNotBlank(vehicleType)) {

            query += ' AND Vehicle_Type__c =: vehicleType';
        }
        System.debug('###query ' + query);
        Set<String> setBLCodes = new Set<String>();
        List<D2C_BE_Master__c> lstBeMasters = Database.query(query);
        
        for(D2C_BE_Master__c master : lstBeMasters){
            setBLCodes.add(master.BL_Code__c);
        }


        /* CISP-9061 - Duplicate Lead Assignment Logic START*/ 
        if(!String.isBlank(loanId) && productType.contains('Passenger Vehicle')){
            String DUPLICATE_LEAD_OWNER = runDuplicateCheckForAssignment(loanId, setBLCodes);
            
            if(DUPLICATE_LEAD_OWNER != null){
                String VEHICLE_TYPE = (String.isNotBlank(vehicleType) && vehicleType.equalsIgnoreCase('New'))?'New':'Used';
                List<AccountTeamMember> duplicateOwnerMember = [SELECT AccountId, Account.BranchBLCode__c, Account.State__c, UserId, User.Name, User.UserName, User.MobilePhone, User.IsActive FROM AccountTeamMember 
                                                                    WHERE UserId =:DUPLICATE_LEAD_OWNER
                                                                    AND User.IsActive = true
                                                                    AND TeamMemberRole = 'BE'
                                                                    AND Account.Type= 'PV'
                                                                    AND Account.Product_Type__c =:VEHICLE_TYPE LIMIT 1];
                if(duplicateOwnerMember != null && duplicateOwnerMember.size()>0){ // CISP-13990 : size check on duplicateOwnerMember
                    if(loanApps.size() > 0) {
                        loanApps[0].mapped_BE__c = duplicateOwnerMember[0].UserId;
                        loanApps[0].BE_mapping_date__c = System.Date.today();
                        update loanApps;
                    }
                    return returnResponse(duplicateOwnerMember, isAggregator, loanId);
                }
            }
            
        }
        /* CISP-9061 - Duplicate Lead Assignment Logic END*/  

        if(setBLCodes.isEmpty()) {
            //What if no BL Codes are found?
            System.debug('###no user found');
            return productType.contains('Passenger Vehicle') ? errorResponse('No BE Found..') : errorResponse('No MO Found..'); 
        }
        String vehicleFilter    = (String.isNotBlank(vehicleType) && vehicleType.equalsIgnoreCase('New'))?'New':'Used';
        String productFilter    = productType.equalsIgnoreCase('Passenger Vehicles')?'PV':'TW';
        String memberRoleFilter = productType.equalsIgnoreCase('Passenger Vehicles')?'BE':'MO';
        List<String> memberRoleFilterList = new List<String>();
        if(productType.equalsIgnoreCase('Passenger Vehicles')) {
            memberRoleFilterList.add('BE');
        } else {
            memberRoleFilterList.add('BE');
            memberRoleFilterList.add('MO');
        }

        List<AccountTeamMember> accountTMs = [SELECT Id, AccountId, Account.BranchBLCode__c, Account.State__c, UserId, User.Name, User.UserName, User.MobilePhone, User.IsActive FROM AccountTeamMember 
                                                WHERE Account.BranchBLCode__c IN :setBLCodes
                                                AND TeamMemberRole IN :  memberRoleFilterList
                                                AND Account.Type=: productFilter
                                                AND Account.Product_Type__c =:vehicleFilter];
        List<AccountTeamMember> activeBEs = new List<AccountTeamMember>();
        Set<Id> activeBEUserIds = new Set<Id>(); // For CISP-8659
        Map<Id,AccountTeamMember> activeBEUserVsAccountTeamMember = new Map<Id,AccountTeamMember>(); // For CISP-8659
        //Set<String> states = new Set<String>();
        for(AccountTeamMember tm : accountTMs) {
            if(tm.User.isActive) {
                activeBEs.add(tm);
                activeBEUserIds.add(tm.UserId); // For CISP-8659
                activeBEUserVsAccountTeamMember.put(tm.UserId, tm); // For CISP-8659
            }
        //    states.add(tm.Account.State__c);
        }
        /*For CISP-8659 START */
        if(loanApps!= NULL && loanApps[0].LeadSource == 'D2C' && productType.equalsIgnoreCase('Passenger Vehicles') && activeBEs.size() > 0 ){
            List<LoanDisbursementDetails__c> loanDisbursementsInLastOneMonth = [SELECT Business_Done_By__c FROM LoanDisbursementDetails__c 
                                                                                WHERE Business_Done_By__c IN:activeBEUserIds 
                                                                                    AND Parent_Loan_Application__r.Vehicle_Type__c =:vehicleFilter 
                                                                                    AND Parent_Loan_Application__r.LastModifiedDate = LAST_N_DAYS:30];
            if(loanDisbursementsInLastOneMonth != null){
                activeBEs = new List<AccountTeamMember>();          // Filtering only the BEs who have worked on the vehicleFilter in context
                for(LoanDisbursementDetails__c loanDisbursement : loanDisbursementsInLastOneMonth){
                    if(activeBEUserVsAccountTeamMember.containsKey(loanDisbursement.Business_Done_By__c)){
                        activeBEs.add(activeBEUserVsAccountTeamMember.get(loanDisbursement.Business_Done_By__c));
                    }  
                }
            }else if(activeBEs != null && activeBEs.size() > 0){
                return errorResponse('No Users were found who have worked on '+vehicleFilter+' Leads in last month');
            }
        }
        /*For CISP-8659 END */
        /*For CISP-8659 START */
        if(productType.equalsIgnoreCase('Passenger Vehicles') && activeBEs.size() > 0){
            List<LoanDisbursementDetails__c> loanDisbursementsInLastOneMonth = [SELECT Business_Done_By__c FROM LoanDisbursementDetails__c 
                                                                                WHERE Business_Done_By__c IN:activeBEUserVsAccountTeamMember.keySet() 
                                                                                    AND Parent_Loan_Application__r.Vehicle_Type__c =:vehicleFilter 
                                                                                    AND Parent_Loan_Application__r.CreatedDate = LAST_N_DAYS:30];
            if(loanDisbursementsInLastOneMonth != null){
                activeBEs = new List<AccountTeamMember>();          // Filtering only the BEs who have worked on the vehicleFilter in context
                for(LoanDisbursementDetails__c loanDisbursement : loanDisbursementsInLastOneMonth){
                    if(activeBEUserVsAccountTeamMember.containsKey(loanDisbursement.Business_Done_By__c)){
                        activeBEs.add(activeBEUserVsAccountTeamMember.get(loanDisbursement.Business_Done_By__c));
                    }  
                }
            }else if(activeBEs != null && activeBEs.size() > 0){
                return errorResponse('No Users were found who have worked on '+vehicleFilter+' Leads in last month');
            }
        }
        /*For CISP-8659 END */

        if(activeBEs.isEmpty()) {
            //WHAT IF NO TEAM MEMBERS ARE FOUND
            if(productType.equals('Two Wheeler')) {
                accountTMs = [SELECT Id, AccountId, Account.BranchBLCode__c, Account.State__c, UserId, User.Name, User.UserName, User.MobilePhone, User.IsActive FROM AccountTeamMember 
                                                WHERE Account.BranchBLCode__c IN :setBLCodes
                                                AND Account.Type=: productFilter
                                                AND Account.Product_Type__c =:vehicleFilter];
                
                Set<String> states = new Set<String>();
                for(AccountTeamMember tm : accountTMs) {
                    states.add(tm.Account.State__c);
                }
                //than find active MO in same state.
                activeBEs = [SELECT Id, AccountId, Account.BranchBLCode__c, Account.State__c, UserId, User.Name, User.UserName, User.MobilePhone, User.IsActive FROM AccountTeamMember 
                            WHERE Account.State__c IN :states 
                            AND User.isActive = TRUE
                            AND TeamMemberRole IN :  memberRoleFilterList
                            AND Account.Type=: productFilter
                            AND Account.Product_Type__c =:vehicleFilter];

                if(activeBEs.size() == 0) {
                    System.debug('###No MO Found.');
                    return errorResponse('No MO Found.');
                }
            } else if(productType.contains('Passenger Vehicle')) {
                System.debug('###No BE Found.');
                return errorResponse('No BE Found.');
            }
            
        }
        AccountTeamMember member = roundRobinBEsearch(activeBEs);
        
        if(loanApps.size() > 0) {
            loanApps[0].mapped_BE__c = member.UserId;
            loanApps[0].BE_mapping_date__c = System.Date.today();
            update loanApps;
        }
        
        System.debug('team member' + member);
        return returnResponse(new List<AccountTeamMember> {member}, isAggregator, loanId);
    }

    /*
    * @Method:      roundRobinBEsearch
    * @Created by:  Rahul Sharma
    * @Description: This method returns the account team member who has least assigned applications in past 7 days.
    * @Param:       List of Account team members.
    * @Return:      AccountTeamMember
    */
    public static AccountTeamMember roundRobinBEsearch(List<AccountTeamMember> users) {
        
        Set<String> userIds = new Set<String>();
        Map<Id, AccountTeamMember> userMap = new Map<Id, AccountTeamMember>();
        for(AccountTeamMember tm : users) {
            userMap.put(tm.UserId, tm);
        }
        List<opportunity> oldOpps = [SELECT mapped_BE__c, BE_mapping_date__c FROM Opportunity WHERE mapped_BE__c IN :userMap.keySet() AND  BE_mapping_date__c >= LAST_N_DAYS:7 ];
        Map<String, List<opportunity>> userOpprtunityMap = new Map<String, List<opportunity>> ();

        if(oldOpps.size() > 0) {
            for(opportunity opp : oldOpps) {
                if(String.isNotBlank(opp.mapped_BE__c)) {
                    if(!userOpprtunityMap.containsKey(opp.mapped_BE__c)) {
                        userOpprtunityMap.put(opp.mapped_BE__c, new List<opportunity>());
                    }
                    userOpprtunityMap.get(opp.mapped_BE__c).add(opp);
    
                }
                
            }
            if(!userOpprtunityMap.isEmpty()) {
                for(String userId : userMap.keySet()) {
                    if(!userOpprtunityMap.containsKey(userId)) {
                        userOpprtunityMap.put(userId, new List<opportunity>());
                    }
                }
                Integer count = 10000000;
                String mappedUserId = null;
                for(String userId : userOpprtunityMap.keySet()) {
                    if(userOpprtunityMap.get(userId).size() < count) {
                        mappedUserId = userId;
                        count = userOpprtunityMap.get(userId).size();
                    } 
                }
                return userMap.get(mappedUserId);
    
            }
        }
        return userMap.values()[0];
    
        
    }

        /*
* @Method:      returnResponse
* @Created by:  Prashanth
* @Description: Method to return Response which contains userId, userName and contactNumber of BE user.
* @Param:       None
* @Return:     String - response
*/
private static String returnResponse(List<AccountTeamMember> accountTMs, Boolean isAggregator, String loanId){
    Response response = new Response();
    response.contactNumber = accountTMs[0].User.MobilePhone;
    String userName = accountTMs[0].User.UserName;
    String employeeId = username.substringBefore('@').toUpperCase();
    response.beId = employeeId; 
    response.beSFDCId = accountTMs[0].UserId;
    response.beName = accountTMs[0].User.Name;
    response.blCode = accountTMs[0].Account.BranchBLCode__c;
    response.accountId = accountTMs[0].AccountId;
    if(isAggregator){
        assignBEDetails(response,loanId);
    }
    System.debug('@@@response' + response);
    return JSON.serialize(response);
}

private static String errorResponse(String message) {
    ErrorResponse response = new ErrorResponse();
    response.errorMessage = message;
    return JSON.serialize(response);
}

   
    //Opportunity update in case of Aggregator journey
    public static void assignBEDetails(Response resp, String loanId){
        Opportunity opp = new Opportunity(Id=loanId);
        opp.Agent_BL_code__c = resp.blCode;
        opp.OwnerId = resp.beSFDCId;
        opp.AccountId = resp.accountId;
        update opp;
    }
    
    /**
    * Class: PincodeRequestData
    * Description: Wrapper class to store the request.
    */
    public class PincodeRequestData{
        public String pincode;
        public String productType;
        public String loanApplicationId;
        public Boolean isAggregator;
    }
    /**
    * Class: Response
    * Description: Wrapper class to store the response.
    */
    public class Response{
        public String beId;
        public String beName;
        public String contactNumber;
        public String beSFDCId;
        public String blCode;
        public String accountId;
    }

    Public Class ErrorResponse {
        public String errorMessage;
    }

    private static string runDuplicateCheckForAssignment(String loanAppId, Set<String> setBLCodes){
       
        String PAN_DOCUMENT_TYPE = System.label.PanCards;
        // Find PAN details of context Opportunity
        String CONTEXT_PAN_NUMBER;

        List<Documents__c> CONTEXT_PAN_DOC = [SELECT PAN_No__c,Opportunity_Relation__c,Opportunity_Relation__r.Vehicle_Type__c, Opportunity_Relation__r.IO_Vehicle_Pincode__c 
                                FROM Documents__c 
                                WHERE Opportunity_Relation__c = :loanAppId AND Document_Type__c = :PAN_DOCUMENT_TYPE LIMIT 1];  
        if(CONTEXT_PAN_DOC != null && CONTEXT_PAN_DOC.size() > 0){
            CONTEXT_PAN_NUMBER = CONTEXT_PAN_DOC[0].PAN_No__c;
        }else{
            return null; // back to normal assignment
        }

            // Check if the CONTEXT_PAN exists on another Lead, get Opportunity details if it does.

        List<Documents__c> EXISTING_MATCHING_PAN_DOC = [SELECT PAN_No__c,Opportunity_Relation__r.IO_Vehicle_Pincode__c,Opportunity_Relation__r.Vehicle_Type__c, Opportunity_Relation__r.Agent_BL_code__c, Opportunity_Relation__r.OwnerId 
                                        FROM Documents__c 
                                        WHERE Opportunity_Relation__c != :loanAppId AND PAN_No__c = :CONTEXT_PAN_NUMBER LIMIT 1];
        if(EXISTING_MATCHING_PAN_DOC != null && EXISTING_MATCHING_PAN_DOC.size()>0){ 
            /*Duplicate PAN found, running duplicate logic */
            /*Check if Vehicle Type and Dealer Pincodes also match */
            Boolean VEHICLE_TYPE_IS_SAME = false;
            Boolean DEALER_PINCODE_IS_SAME = false;

            if(CONTEXT_PAN_DOC[0].Opportunity_Relation__r.IO_Vehicle_Pincode__c == EXISTING_MATCHING_PAN_DOC[0].Opportunity_Relation__r.IO_Vehicle_Pincode__c){
                DEALER_PINCODE_IS_SAME = true; // Dealer Pin Code Matches
            }

            if((CONTEXT_PAN_DOC[0].Opportunity_Relation__r.Vehicle_Type__c == EXISTING_MATCHING_PAN_DOC[0].Opportunity_Relation__r.Vehicle_Type__c) || 
            (CONTEXT_PAN_DOC[0].Opportunity_Relation__r.Vehicle_Type__c == 'Used' && EXISTING_MATCHING_PAN_DOC[0].Opportunity_Relation__r.Vehicle_Type__c == 'Refinance') ||
            (CONTEXT_PAN_DOC[0].Opportunity_Relation__r.Vehicle_Type__c == 'Refinance' && EXISTING_MATCHING_PAN_DOC[0].Opportunity_Relation__r.Vehicle_Type__c == 'Used')){
                VEHICLE_TYPE_IS_SAME = true; // Vehicle Type is same (Refinance is same as Used)
            }
            
            /* If VEHICLE_TYPE_IS_SAME and DEALER_PINCODE_IS_SAME, assign to Existing Opportunity Owner*/
            if(VEHICLE_TYPE_IS_SAME && DEALER_PINCODE_IS_SAME){
                /*assign to Existing Opportunity Owner*/
                return EXISTING_MATCHING_PAN_DOC[0].Opportunity_Relation__r.OwnerId;
            }
            /* If VEHICLE_TYPE_IS_SAME and DEALER_PINCODE is not same, we check if Existing Opportunity's BL Code is in our set setBLCodes */
            else if(!DEALER_PINCODE_IS_SAME && VEHICLE_TYPE_IS_SAME){
                if(setBLCodes != null && EXISTING_MATCHING_PAN_DOC[0].Opportunity_Relation__r.Agent_BL_code__c != null){
                    for(String blCode : setBLCodes){
                        if(blCode == EXISTING_MATCHING_PAN_DOC[0].Opportunity_Relation__r.Agent_BL_code__c){
                            /*assign to Existing Opportunity Owner*/
                            return EXISTING_MATCHING_PAN_DOC[0].Opportunity_Relation__r.OwnerId;
                        }
                    }
                }else{
                    return null; // No BL Codes found, return to normal assignment
                }
            }
        }else{
            return null; // No matching PAN found, return to normal assignment
        }
            
        return null;
    }
    
}