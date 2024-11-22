public without sharing class iND_CustomLookup {
    
    @AuraEnabled(cacheable=true)  
    public static List<sobject> findRecords(String searchKey, String objectName, String loanID, string AccountID,String branch) {  
        //CISP: Addedd AccountID as a parameter for CISP: 2861
        MAP<Id,sObject> accountTeamMemberMap = new MAP<Id,sObject>(); 
        string searchText =  String.escapeSingleQuotes(searchKey) + '%';
        string uid =   userinfo.getUserId() ;
        Map<String,list<string>> lst_role = new Map<String,list<string>> ();
        lst_role.put('BE',new List<String>{'BE','CS'});
        lst_role.put('CS',new List<String>{'CS','BE'});
        lst_role.put('MA',new List<String>{'MA'});
        lst_role.put('MO',new List<String>{'MO','MA'});
		lst_role.put('XSB',new List<String>{'BE','CS'});
        System.debug('lst_role=>'+lst_role);
        system.debug('The agent bl code is '+AccountID);
       
        //Added AccountID as a parameter CISP: 2861
        Opportunity opp = [SELECT ID, AccountId, LeadSource FROM Opportunity WHERE ID=: loanID];
		system.debug('The agent bl code by method '+opp.AccountId);
        if(opp.LeadSource == 'D2C'){
            AccountID = opp.AccountId;
        }
        AccountTeamMember rol1=[SELECT Id, TeamMemberRole, UserId, User.Name FROM AccountTeamMember WHERE  UserId =: UserInfo.getUserId() AND AccountId =: AccountID];
        String role=rol1.TeamMemberRole;

        system.debug('role::'+role);
        List<sObject> lookUpList = new List<sObject>();
        Map<string,List<SObject>> mapSobj = new Map<string,List<SObject>>();

        for(String str : lst_role.keySet()){
            system.debug('str::'+str);
            if(str == role){
                for(String val : lst_role.get(str)){
                    string query = 'SELECT Id, TeamMemberRole, UserId, User.Name FROM AccountTeamMember' 
                                    + ' WHERE User.Name LIKE \'%' + searchKey + '%\' AND TeamMemberRole=\''+ val +'\' AND UserId!=\''+ uid +'\' AND AccountId =\''+ branch +'\'  LIMIT 20';

                    system.debug('query::'+query);
                    lookUpList = Ind_CustomLookupController_Helper.searchLookupHelper(query);

                    mapSobj.put(val,lookUpList);
                   
                }
            }
        }
        for(String str: mapSobj.keySet()){
            for(sObject record: mapSobj.get(str)){
                AccountTeamMember atmRecord = (AccountTeamMember) record;
                accountTeamMemberMap.put(atmRecord.UserId, atmRecord)   ;                     
            }   
        }    
        return accountTeamMemberMap.values();  
    }

    
    
    public class userWrap{
        public string name {get;Set;}
        public string id {get;Set;}
        
    }
    
    //CISP-3497 -- start
    @AuraEnabled
    public static List<AccountTeamMember> findUserRecords(String searchKey, String objectName, String loanID, string AccountID,String branch)
    {
        if(String.isEmpty(searchKey)) {
		 List<AccountTeamMember> atm = [select id,UserId,User.name from AccountTeamMember where AccountId=:branch and (TeamMemberRole='BE' or TeamMemberRole = 'CS')];
            System.debug('atm if: '+atm);
            return atm;
        }
        else {
            String search = '%'+searchKey + '%';
            List<AccountTeamMember> atm = [select id,UserId,User.name from AccountTeamMember where AccountId=:branch and User.Name like :search ];
            System.debug('atm else: '+atm);
            return atm;
        }
    }
    //CISP-3497 -- end


    /*
* @Method Name: getBranchesOfState 
* @Created by:  Vishal Gadhave
* @description: Get Account data 
* @Param:       current State 
* @Return:      
*/
@AuraEnabled
public static List<Account> getBranchesOfState(String State ,String productType, String leadId) {
    try{
        String vehicleType = [Select id,Vehicle_Type__c From Opportunity Where Id =: leadId].Vehicle_Type__c == 'New' ? 'New' : 'Used';
        List<Account> accList = [SELECT Id, State__c,Name FROM Account WHERE State__c =:State and type =: productType AND Product_type__c =: vehicleType];
        return accList;
    }catch(Exception e){
        ErrorLoggerUtil.logErrorEvent(System.Label.LwcLOSLoanApplicationCntrl, ' getLoanApplicationReadOnlySettings ', System.Label.Apex, e);
            throw new IND_Exception(e.getMessage());
    }
}

@AuraEnabled
public static List<Account> getBranchesOfStateSynergy(String State ,String productType, String vehicleType) {
    try{
        // String vehicleType = [Select id,Vehicle_Type__c From Opportunity Where Id =: leadId].Vehicle_Type__c == 'New' ? 'New' : 'Used';
        List<Account> accList = [SELECT Id, State__c,Name FROM Account WHERE State__c =:State and type =: productType AND Product_type__c =: vehicleType];
        return accList;
    }catch(Exception e){
        ErrorLoggerUtil.logErrorEvent(System.Label.LwcLOSLoanApplicationCntrl, ' getLoanApplicationReadOnlySettings ', System.Label.Apex, e);
            throw new IND_Exception(e.getMessage());
    }
}

@AuraEnabled
public static List<SObject> findRecordsForCVOPE(String searchKey, String objectName,string AccountID,String accountRole){
    try {
        List<String> roleName = new List<String>();
        if(accountRole == 'IBL Partner Community TF CVO' || accountRole == 'IBL TF CVO' || (accountRole != null && accountRole.contains('CVO'))){
            roleName.add('CVO');
        }else if(accountRole == 'IBL TF Payment Executive' || accountRole == 'IBL TF Internal Payment Executive'){
            roleName.add('PE');
            roleName.add('PME');
        }
        List<sObject> lookUpList = new List<sObject>();
        Map<string,List<SObject>> mapSobj = new Map<string,List<SObject>>();
        MAP<Id,sObject> accountTeamMemberMap = new MAP<Id,sObject>();

        for(String roleN : roleName){
            string query = 'SELECT Id, TeamMemberRole, UserId, User.Name FROM AccountTeamMember' 
            + ' WHERE User.Name LIKE \'%' + searchKey + '%\' AND TeamMemberRole=\''+ roleN +'\' AND AccountId =\''+ AccountID +'\'  LIMIT 20';

            system.debug('query::'+query);
            lookUpList = Ind_CustomLookupController_Helper.searchLookupHelper(query);

            mapSobj.put(roleN,lookUpList);
        }
        
        for(String str: mapSobj.keySet()){
            for(sObject record: mapSobj.get(str)){
                AccountTeamMember atmRecord = (AccountTeamMember) record;
                accountTeamMemberMap.put(atmRecord.UserId, atmRecord)   ;                     
            }   
        }    
        return accountTeamMemberMap.values();  
        
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
}
}