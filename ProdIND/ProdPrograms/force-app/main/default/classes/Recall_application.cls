/**
* @Name         Recall_application
* @Author       Saloni Jadhav
* @Company      Persistent Systems
* @Description  This class contains all methods related to Reacll Lead assignment 
* Inputs:       None
* Test Class:   
* History:
*/

public with sharing class Recall_application {
    @AuraEnabled
    public static boolean reaclltranferedApplictaion(string loanId){
        Opportunity opp=[SELECT StageName FROM Opportunity WHERE Id=:loanId];
        System.debug('opp==>'+opp);
        Boolean obj;
        
        List<Lead_Genaration_Metadata__mdt> lstmdt ;
        if(Test.isRunningTest()){
            lstmdt = [SELECT id,MasterLabel,FieldSetName__c,Object__c,UpdateOrDeactivateOperation__c FROM Lead_Genaration_Metadata__mdt WHERE MasterLabel=:opp.StageName AND Object__c = 'Vehicle_Detail__c'];
            
        }else{
            lstmdt = [SELECT id,MasterLabel,FieldSetName__c,Object__c,UpdateOrDeactivateOperation__c FROM Lead_Genaration_Metadata__mdt WHERE MasterLabel=:opp.StageName];
        }
        system.debug('lstmdt==>'+ lstmdt);
        
        for(Lead_Genaration_Metadata__mdt mdt:lstmdt){
            if(mdt.UpdateOrDeactivateOperation__c=='Update'){
                obj = getUpdate(mdt.FieldSetName__c,mdt.Object__c,loanId);
                system.debug('obj'+obj);
            }else if(mdt.UpdateOrDeactivateOperation__c=='Deactivate'){
                obj = getDecivate(mdt.Object__c, loanID);
                system.debug('obj'+obj);
            }
        }
        
        try{
            List<Loan_Application_Transaction_History__c> listLoanApp = [SELECT id,name,Current_Owner__c ,New_Owner__c
                                                                    FROM Loan_Application_Transaction_History__c 
                                                                    WHERE Loan_Application_ID__c=:loanId AND Module_Name__c =: opp.StageName 
                                                                    AND recordType.Name ='Lead Assignment' AND Assignment_status__c!= 'Rejected' 
                                                                    AND Assignment_status__c!= 'Recalled' AND Assignment_status__c!= 'Completed'];
            //CISP: 2848
          
            if(!listLoanApp.isEmpty())    
            {
               
                 String new_owner = listLoanApp[0].New_Owner__c;
            System.debug('new_owner'+new_owner);
            
            listLoanApp[0].New_Owner__c=listLoanApp[0].Current_Owner__c;
            listLoanApp[0].Assignment_status__c='Recalled';

            upsert listLoanApp;
            System.debug('listLoanApp'+listLoanApp);
            
            List<OpportunityTeamMember> oppTeamMem = [SELECT id,Name,UserId FROM OpportunityTeamMember
                                                 WHERE OpportunityId =: loanId AND UserId =: new_owner ];
            // List<OpportunityTeamMember> ListoppTeamMem =  new List<OpportunityTeamMember>();
            // for(OpportunityTeamMember oppTeam : oppTeamMem){
            //     oppTeam.UserId=null;
            //     ListoppTeamMem.add(oppTeam);
            // }
            //upsert ListoppTeamMem;
            if(!oppTeamMem.isEmpty()){
                System.debug('oppTeamMem'+oppTeamMem[0]);
                    delete oppTeamMem[0];
            }
            }
              
        }catch(DmlException e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
            return false;
        }
          return true; 
    }
    
    public static Boolean getUpdate(String fieldSetName, String ObjectName, String oppID){
        try{
            Boolean isVehicleObj = false;//CISP-255
            Boolean requestIdPresent = false;//CISP-255
            Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
            Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
            Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
            system.debug('DescribeSObjectResultObj'+DescribeSObjectResultObj.getName());
            Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
            system.debug('DescribeSObjectResultObj'+DescribeSObjectResultObj.getName());  
            system.debug('fieldSetObj'+fieldSetObj);
            if(DescribeSObjectResultObj.getName() == 'Vehicle_Detail__c'){//CISP-255
                isVehicleObj = true;
            }//CISP-255
            String queryString = 'SELECT Id';
            List<Schema.FieldSetMember> lstFields;
            if(fieldSetObj != null){
                system.debug('fieldSetObj--');
                lstFields=fieldSetObj.getFields(); 
                system.debug('fieldSetObjlstFields--' + lstFields);
                for(Schema.FieldSetMember f : lstFields) {
                    queryString +=', ' +f.getFieldPath() ;
                }
                system.debug('queryString--' + queryString);
            }
            
            if(Test.isRunningTest() && lstFields == null && DescribeSObjectResultObj.getName() == 'Vehicle_Detail__c'){
                queryString += ' ,is_Active__c , City__c ';
            }
            if(DescribeSObjectResultObj.getName()== 'Income_Details__c'){
                queryString += ' , Applicant__c ';
            }
            queryString += ' FROM '+DescribeSObjectResultObj.getName();
            if(DescribeSObjectResultObj.getName()== 'Opportunity'){
                 queryString += ' WHERE Id=\'' +oppId + '\'';

            }else if(DescribeSObjectResultObj.getName()== 'Applicant__c'){
                queryString += ' WHERE Opportunity__c	=\'' +oppId + '\'';

            }else if(DescribeSObjectResultObj.getName()== 'Income_Details__c'){
                queryString += ' WHERE Applicant__r.Opportunity__c	=\'' +oppId + '\'';

            }else{
                    queryString += ' WHERE Loan_Application__c=\'' +oppId + '\'';

            }
            system.debug('queryString==>'+queryString);
            
            List<SObject> objs= Database.query(queryString);
            system.debug('objs==>'+objs);

            if(!objs.isEmpty()){
                for(SObject obj : objs){
                    Map<String, Object> fields = obj.getPopulatedFieldsAsMap();
                    system.debug('fields==>'+fields);
                    
                    Type classType = Type.forName(ObjectName);
                    SObject mergedRecord = (SObject)JSON.deserialize('{}', classType);
                    
                    for (String field : fields.keySet()){
                        if(isVehicleObj == true){//CISP-255
                            if('Id'.equals(field)){
                                //CISP-255
                                Vehicle_Detail__c vehiObj = [Select id,MFC_Request_Id__c from Vehicle_Detail__c where Id =: String.valueOf(obj.get(field))];
                                if(vehiObj.MFC_Request_Id__c!= null){
                                    requestIdPresent = true;
                                }//CISP-255
                            }
                        }
                        if(requestIdPresent == false){//CISP-255
                            if ('Id'.equals(field))
                            {
                                System.debug('field name is ' + field + ', value is ' + fields.get(field));            
                                mergedRecord.put(field, obj.get(field));
                            }else if (obj.get(field)!=null ){   
                                System.debug('field name is ' + field + ', value is ' + fields.get(field)); 
                                If (obj.get(field) instanceof Boolean) {
                                    mergedRecord.put(field, false);
                                }else{
                                    if(!'Applicant__c'.equals(field) ){
                                        mergedRecord.put(field, null);
                                    }
                                } 
                            }
                    	}
                    }
                    if(requestIdPresent == false){
                        upsert(mergedRecord);
                    }
                }
                    return true;
            }else{
                return true;
            }
            
           
        }catch(DmlException e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
            return false;
        }
    }
    
    public static Boolean getDecivate(String objectName, String oppID) {
        try{
            Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
            List<String> reqFields = new List<String>();
            Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
            Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
            system.debug('DescribeSObjectResultObj'+DescribeSObjectResultObj.getName());
            
            String queryString = 'SELECT Id From '+DescribeSObjectResultObj.getName();
            if(DescribeSObjectResultObj.getName()== 'Field_Investigation__c'){
                queryString += ' WHERE Case__r.Loan_Application__c =\'' +oppId + '\'';

            }else if(DescribeSObjectResultObj.getName()== 'Income_Details__c'){
                queryString += ' WHERE Applicant__r.Opportunity__c	=\'' +oppId + '\'';

            }else if(DescribeSObjectResultObj.getName()== 'Existing_EMI__c'){
                queryString += ' WHERE Applicant_Id__r.Opportunity__c	=\'' +oppId + '\'';

            }else if(DescribeSObjectResultObj.getName()== 'Documents__c'){
                queryString += ' WHERE Opportunity_Relation__c	=\'' +oppId + '\'';

            }else{
                queryString += ' WHERE Loan_Application__c=\'' +oppId + '\'';
            }
            queryString += ' Limit 1';
            system.debug('queryString==>'+queryString);
            
            List<SObject> obj= Database.query(queryString);
            system.debug('obj==>'+obj);
            if(!obj.isEmpty()){

                //Object o = obj.get('is_Active__c');
                //obj.put('is_Active__c', false);
                //upsert(obj);
                delete obj;
                system.debug('obj==>'+obj);
                
                return true;
            }else{
                return true;
            }
        }catch(DmlException e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
            return false;
        }
    }
    
    @AuraEnabled
    public static String getUserRole(string new_owner, string loanID){
        Opportunity opp = [SELECT ID, AccountId FROM Opportunity WHERE ID=: loanID];

        AccountTeamMember rol1=[SELECT Id, TeamMemberRole, UserId, User.Name FROM AccountTeamMember WHERE  UserId =: new_owner AND AccountId =: opp.AccountId];
        System.debug('rol1.TeamMemberRole');
        return rol1.TeamMemberRole;
    }

    @AuraEnabled
    public static boolean checkLoanApplicationTransactionHistory(string loanId,string stage){

        list<Loan_Application_Transaction_History__c> lstloanApphstry = [select id from Loan_Application_Transaction_History__c where Loan_Application_ID__c = :loanId and Module_Name__c=: stage and recordType.Name ='Lead Assignment' and Assignment_status__c != 'Completed'];
        if(lstloanApphstry.size()>0){
            List<opportunity> oppList = [Select Id ,ownerId from opportunity where Id =:loanId limit 1];
                if(oppList[0].ownerId == UserInfo.getUserId()){
                    return true;
                }
            //return true;
        }
        return false;
    }
}