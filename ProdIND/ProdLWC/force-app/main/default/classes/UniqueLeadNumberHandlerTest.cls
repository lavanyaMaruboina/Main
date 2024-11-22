@isTest
public class UniqueLeadNumberHandlerTest {
    @isTest
    public static void generateLeadNumberTest(){
        
        Opportunity opdo1 = new Opportunity();
        opdo1.StageName = 'Qualification';
        opdo1.CloseDate = Date.newInstance(2021, 1, 11);
        opdo1.Name = 'testone';
        insert opdo1;
        Map<Id,Opportunity> opMap = new Map<Id,Opportunity>();
        opMap.put(opdo1.Id,opdo1);
        
        Test.startTest();
        UniqueLeadNumberHandler.generateLeadNumber(opMap);
        Test.stopTest();
    }
    
    @isTest
    public static void updateLeadSeqNumberTest(){
        
        Opportunity opdo1 = new Opportunity();
        opdo1.StageName = 'Qualification';
        opdo1.CloseDate = Date.newInstance(2021, 1, 11);
        opdo1.Name = 'testone';
        opdo1.Lead_number__c = '12345';
        insert opdo1;
        
        Set<Id> opSetId = new Set<Id>();
        opSetId.add(opdo1.Id);
        
        Test.startTest();
        UniqueLeadNumberHandler.updateLeadSeqNumber(opSetId);
        Test.stopTest();
    }
    
    @isTest
    public static void deleteDocTest(){
        try{
            Opportunity opgr1 = new Opportunity();
            opgr1.StageName = 'Qualification';
            opgr1.CloseDate = Date.newInstance(2021, 1, 11);
            opgr1.Name = 'testone';
            insert opgr1;
            List<Applicant__c> lstApl = new List<Applicant__c>();
            for(Integer i=0;i<1;i++) {
                lstApl.add(new Applicant__c(Name = 'apName'+i,
                                            Opportunity__c = opgr1.id,
                                            Customer_Code__c = 'CU010104',
                                            Contact_number__c = '9988776655'));
            }
            insert lstApl;
            List<Documents__c> docs=new List<Documents__c>();
            Documents__c doc1 = new Documents__c();
            
            doc1.Opportunity_Relation__c = opgr1.id;
            doc1.Applicant__c = lstApl[0].id;
            doc1.name = 'test doc';
            docs.add(doc1) ;
            
            Documents__c doc = new Documents__c();
            
            doc.Opportunity_Relation__c = opgr1.id;
            doc.Applicant__c = lstApl[0].id;
            doc.name = 'test doc';
            docs.add(doc) ;
            insert docs;
            
            List<Opportunity> opps=new List<Opportunity>();
            opps.add(opgr1);
            
            Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the');
            ContentVersion contentVersion_1 = new ContentVersion(
                Title='SampleTitle', 
                PathOnClient ='SampleTitle.jpg',
                VersionData = bodyBlob, 
                origin = 'H'
            );
            insert contentVersion_1;
            
            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                                               FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
            
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = doc.id;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            insert contentlink;
            
            
            Test.startTest();
               UniqueLeadNumberHandler.deleteDoc(opps);
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void updateApplicationSeqNumberTest(){
        
        System_Configuration__c sysConfig = new System_Configuration__c();
        sysConfig.Name = 'System Configuration';
        sysConfig.Eligible_Roles_for_BE_Assignment__c = 'BE,CS';
        sysConfig.Eligible_Roles_for_CS_Assignment__c = 'CS,MA';
        sysConfig.Eligible_Roles_for_MA_Assignment__c = 'MA,MO';
        sysConfig.Eligible_Roles_for_MO_Assignment__c = 'BE,CS,MA,MO';
        sysConfig.Application_Date__c = System.today();
        insert sysConfig;  
        
        Opportunity opun1 = new Opportunity();
        opun1.StageName = 'Qualification';
        opun1.CloseDate = Date.newInstance(2021, 1, 11);
        opun1.Name = 'testone';
        opun1.Application_Sequence__c=00001; 
        insert opun1;
        
        Test.startTest();
            UniqueLeadNumberHandler.updateApplicationSeqNumber(opun1.Id);
        Test.stopTest();
    }
    
     @isTest
    public static void updateApplicationSeqNumberTest1(){
        
        System_Configuration__c sysConfig = new System_Configuration__c();
        sysConfig.Name = 'System Configuration';
        sysConfig.Eligible_Roles_for_BE_Assignment__c = 'BE,CS';
        sysConfig.Eligible_Roles_for_CS_Assignment__c = 'CS,MA';
        sysConfig.Eligible_Roles_for_MA_Assignment__c = 'MA,MO';
        sysConfig.Eligible_Roles_for_MO_Assignment__c = 'BE,CS,MA,MO';
        sysConfig.Application_Date__c = System.today();
        sysConfig.Application_Sequence_No__c = null;
        insert sysConfig;  
        
        Opportunity opun1 = new Opportunity();
        opun1.StageName = 'Qualification';
        opun1.CloseDate = Date.newInstance(2021, 1, 11);
        opun1.Name = 'testone';
        opun1.Application_Sequence__c=00001; 
        insert opun1;
        
        Test.startTest();
            UniqueLeadNumberHandler.updateApplicationSeqNumber(opun1.Id);
        Test.stopTest();
    }
    
     @isTest
    public static void updateApplicationSeqNumberTest2(){
        
        System_Configuration__c sysConfig = new System_Configuration__c();
        sysConfig.Name = 'System Configuration';
        sysConfig.Eligible_Roles_for_BE_Assignment__c = 'BE,CS';
        sysConfig.Eligible_Roles_for_CS_Assignment__c = 'CS,MA';
        sysConfig.Eligible_Roles_for_MA_Assignment__c = 'MA,MO';
        sysConfig.Eligible_Roles_for_MO_Assignment__c = 'BE,CS,MA,MO';
        sysConfig.Application_Date__c = Date.newInstance(2021, 1, 11);
        sysConfig.Application_Sequence_No__c = null;
        insert sysConfig;  
        
        Opportunity opun1 = new Opportunity();
        opun1.StageName = 'Qualification';
        opun1.CloseDate = Date.newInstance(2021, 1, 11);
        opun1.Name = 'testone';
        opun1.Application_Sequence__c=00001; 
        insert opun1;
        
        Test.startTest();
            UniqueLeadNumberHandler.updateApplicationSeqNumber(opun1.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void verifyUpdateApplicationSeqNumber(){ 
        System_Configuration__c sysConfig = new System_Configuration__c();
        sysConfig.Name = 'System Configuration';
        sysConfig.Eligible_Roles_for_BE_Assignment__c = 'BE,CS';
        sysConfig.Eligible_Roles_for_CS_Assignment__c = 'CS,MA';
        sysConfig.Eligible_Roles_for_MA_Assignment__c = 'MA,MO';
        sysConfig.Eligible_Roles_for_MO_Assignment__c = 'BE,CS,MA,MO';
        //sysConfig.Application_Sequence_No__c = '0';
        insert sysConfig;
        
        Opportunity opun1 = new Opportunity();
        opun1.StageName = 'Qualification';
        opun1.CloseDate = Date.newInstance(2021, 1, 11);
        opun1.Name = 'testone';
        insert opun1;
        System.assert(opun1.Id != null);
        List<Opportunity> opptyList = [SELECT Id, Application_Sequence_Number__c, Application_number__c FROM Opportunity WHERE Id =: opun1.Id];
        //UniqueLeadNumberHandler.processUpdateApplicationSeqNumberLogic(opptyList[0], '', '', sysConfig);
      //  System.assert(opptyList[0].Application_number__c != null);
    }
    
    
    @isTest
    public static void verifyUpdateLeadSeqNumber(){  
        System_Configuration__c sysConfig = new System_Configuration__c();
        sysConfig.Name = 'System Configuration';
        sysConfig.Eligible_Roles_for_BE_Assignment__c = 'BE,CS';
        sysConfig.Eligible_Roles_for_CS_Assignment__c = 'CS,MA';
        sysConfig.Eligible_Roles_for_MA_Assignment__c = 'MA,MO';
        sysConfig.Eligible_Roles_for_MO_Assignment__c = 'BE,CS,MA,MO';       
        sysConfig.Lead_Sequence_No__c = '0';
        insert sysConfig;
        
        Opportunity opun1 = new Opportunity();
        opun1.StageName = 'Qualification';
        opun1.CloseDate = Date.newInstance(2021, 1, 11);
        opun1.Name = 'testone';
        insert opun1;
        System.assert(opun1.Id != null);
        List<Opportunity> opptyList = [SELECT Id, Application_Sequence_Number__c,  Lead_Number_Sequence__c, Application_number__c, Lead_number__c FROM Opportunity WHERE Id =: opun1.Id];
        UniqueLeadNumberHandler.processUpdateLeadSeqNumberLogic(opptyList[0], '', '', sysConfig);
        System.assert(opptyList[0].Lead_number__c != null);
    }
    
    
    
}