/*
* @Class Name:  IND_LWC_HomePage_Cntrl
* @Author: 		Vinita K.
* @Description :Class contail logic of Creating new Application on button , also has POA tagging for KYC .
* @Company      Persistent Systems
* Inputs:       None
* History: 
*/

public with sharing class LWC_LOS_HomePage_Cntrl {
    /*
    * @Method Name: poaTagging
    * @Created by: 	Vinita K.
    * @Description: Method will mark the POA check according to Residential address proof -IND-308
    * @Param:       String - loanApplication ID
    * @Return:      Boolean flag as response if POA mapping updated.
    */
    @AuraEnabled
    public static void poaTagging(String applicantId){
        try {
            if(applicantId!=null) {           
                // Documents__c docToUpdate = new Documents__c();
                // Map<Boolean, Documents__c> mapOfRecords = new Map<Boolean, Documents__c>();
                // for(Documents__c document :[Select Current_Residential_Address_Proof__c,Permanent_Residential_Address_Proof__c,Proof_of_Address_POA__c,Applicant__r.Current_Address_Not_Present__c from Documents__c where Applicant__c=:applicantId WITH SECURITY_ENFORCED]) {
                //     if(document.Current_Residential_Address_Proof__c && !Applicant__r.Current_Address_Not_Present__c) {
                //         mapOfRecords.put(true,document);
                //     } else if(document.Permanent_Residential_Address_Proof__c){
                //         mapOfRecords.put(false,document);
                //     }            
                // }
                // if(mapOfRecords.get(true)==null){
                //     docToUpdate.Id = mapOfRecords.get(false).Id;
                //     docToUpdate.Proof_of_Address_POA__c = true;
                // } else {
                //     docToUpdate.Id = mapOfRecords.get(true).Id;
                //     docToUpdate.Proof_of_Address_POA__c = true;
                // }

                // if(Schema.sObjectType.Documents__c.isUpdateable()){
                //     update docToUpdate;
                // }                       
                // if(Test.isRunningTest()) {
                //     throw new AuraHandledException(System.Label.ExceptionMessage);
                // }
            
                //CISP-3095 OR CISP-3047 - START
                MAP<String,Integer> preferenceOrderMap = new MAP<String,Integer>();
                for(POA_Preference__mdt mdtElement : POA_Preference__mdt.getAll().values()){
                    preferenceOrderMap.put(mdtElement.MasterLabel.toUpperCase(),(Integer)mdtElement.Preference_Order__c);
                }
                List<Documents__c> doctoUpdate=new List<Documents__c>();
                List<Documents__c> documentsList = [select Id,Name from Documents__c where Applicant__c=:applicantId And Document_Type__c !=: System.Label.PanCards And Document_Type__c !=: System.Label.CustomerImageDocumentType And Document_Type__c != 'Form 60' AND Is_Active__c = true WITH SECURITY_ENFORCED];
                if(!documentsList.isEmpty() && documentsList.size()>0){
                    Integer poaOfDoc;
                    MAP<Integer,String> poaAndName = new MAP<Integer,String>();
                    List<Integer> poaVal= new List<Integer> ();
                    Integer minvalue;
                    for(Documents__c doc : documentsList) {
                        if(preferenceOrderMap.containsKey(doc.Name.toUpperCase())){
                            poaOfDoc= preferenceOrderMap.get(doc.Name.toUpperCase());
                            poaVal.add(poaOfDoc);
                            poaAndName.put(poaOfDoc,doc.Name);
                            minvalue=poaOfDoc;
                        } 
                    }
                    for(integer i =0;i<poaVal.size();i++) {
                        if( poaVal[i] < minvalue) {
                            minvalue = poaVal[i];  
                        }
                    }
                    for(Documents__c doc : documentsList) {
                        if(doc.Name==poaAndName.get(minvalue) && preferenceOrderMap.containsKey(doc.Name.toUpperCase())) {
                            doc.Proof_of_Address_POA__c=true;
                        }else {
                            doc.Proof_of_Address_POA__c=false;
                        }
                        doctoUpdate.add(doc);
                    }
                    if (Schema.sObjectType.Documents__c.isUpdateable()){
                        update doctoUpdate;
                    }
                }
                //CISP-3095 OR CISP-3047 - END
            }
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('LWC_LOS_HomePage_Cntrl', 'poaTagging', 'Apex', e);
		   	throw new AuraHandledException(System.Label.ExceptionMessage);
        } 
    }   
	//End : POA Method created by Vinita Kamble
    
    /*
    * @Method Name: createLoanApplication
    * @Modified by: Neha G.
    * @description: Method will create a new Opportunity and get assigned few values from User logged in
    * @Param:       
	* @Return:      Application Id
    */
    @AuraEnabled
    public static String createLoanApplication(){
        try {
            //temName to be used to replace it with Lead Number as Name in trigger-generateUniqueLeadNumber
            String tempName = 'TempName';
            //String uniqueLeadNumber = Utilities.generateUniqueLeadNumber();
            Opportunity opp = new Opportunity(Name= tempName,StageName = 'Loan Initiation',
                                              CloseDate = System.today().addMonths(1) );
            //opp.name =opp.Lead_n
            opp.Sub_Stage__c = 'User Details';
            opp.LastStageName__c = 'Loan Initiation';
            //tempName = opp.Lead_number__c;
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
            	insert opp;
                //String appAutonumber = opp.id;
                SET<ID> oppIdSet = new SET<ID>{opp.Id};
                    UniqueLeadNumberHandler.updateLeadSeqNumber(oppIdSet);
            }
            if(Test.isRunningTest())
			{
				throw new AuraHandledException(System.Label.ExceptionMessage);
			}
            return opp.Id;
        } catch (Exception e) {
           ErrorLoggerUtil.logErrorEvent('LWC_LOS_HomePage_Cntrl', 'createLoanApplication', 'Apex', e);
		   throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    /*
    * @Method Name: checkUserRoleAccess
    * @Modified by: Neha Gosavi
    * @description: Method will get current loggedin User's Profile and check if User can create lead or not 
    * @Param:       null
	* @Return:      Booelan: if User can create lead or not
    */
    @AuraEnabled
    public static Boolean checkUserRoleAccess(){
        try {
            Boolean canUserCreateLead = false;
            List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
            List<String> rolesList = System.Label.User_Roles.split(';');
            if(PROFILE != null) {    
                if(rolesList.contains(PROFILE[0].Name)) {
                    canUserCreateLead = true;
                }
            }
            return canUserCreateLead;
        } catch (Exception e) {
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
}