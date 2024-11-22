@isTest
public class ApprovalProposalControllerTest {
    @isTest
    public static void getProposalTest(){
        Test.startTest();
             ApprovalProposalController.getProposal();
        Test.stopTest();
    }
    
    @isTest
    public static void updateProposalRecordsTest(){
        
        Opportunity opdo1 = new Opportunity();
        opdo1.StageName = 'Qualification';
        opdo1.CloseDate = Date.newInstance(2021, 1, 11);
        opdo1.Name = 'testone';
        insert opdo1;
        
        CAM__c cam1 = new CAM__c();
        cam1.Loan_Application__c = opdo1.Id;
        cam1.BE_CVO_Remark__c = 'testbe';
        cam1.Conditional_Approval__c = 'testapprov';
    //    cam1.Proposal_Status__c = 'testproposal';
        insert cam1;
        
        Deviation__c dv1 = new Deviation__c();
        dv1.Parent_CAM__c = cam1.Id;
        dv1.Deviation_Description__c = 'testdesc';
        dv1.Deviation_Level__c = 'testlevel';
        dv1.Role__c = 'testrole';
        insert dv1;
        
        Proposal_Approval_Log__c pa1 = new Proposal_Approval_Log__c();
        pa1.Deviation_Id__c = dv1.Id;
        pa1.Parent_CAM__c = cam1.Id;
        pa1.Approval_Status__c = 'proaprv';
        pa1.Forward_Remark__c = 'testremark';
        pa1.Forwarded_By__c = 'testuser';
        insert pa1;
        
        Map<Id,Proposal_Approval_Log__c> mapVal = new Map<Id,Proposal_Approval_Log__c>();
        mapVal.put(pa1.Id,pa1);
        
        Test.startTest();
            // ApprovalProposalController.updateProposalRecords(JSON.serialize(mapVal));
        Test.stopTest();
    }
    
        @isTest
    public static void updateProposalRecordsTestNegative(){
        Opportunity opdo1 = new Opportunity();
        opdo1.StageName = 'Qualification';
        opdo1.CloseDate = Date.newInstance(2021, 1, 11);
        opdo1.Name = 'testone';
        insert opdo1;
        
        CAM__c cam1 = new CAM__c();
        cam1.Loan_Application__c = opdo1.Id;
        cam1.BE_CVO_Remark__c = 'testbe';
        cam1.Conditional_Approval__c = 'testapprov';
        cam1.Proposal_Status__c = 'testproposal';
        insert cam1;
        
        Deviation__c dv1 = new Deviation__c();
        dv1.Parent_CAM__c = cam1.Id;
        dv1.Deviation_Description__c = 'testdesc';
        dv1.Deviation_Level__c = 'testlevel';
        dv1.Role__c = 'testrole';
        insert dv1;
        
        Proposal_Approval_Log__c pa1 = new Proposal_Approval_Log__c();
        pa1.Deviation_Id__c = dv1.Id;
        pa1.Parent_CAM__c = cam1.Id;
        pa1.Approval_Status__c = 'proaprv';
        pa1.Forward_Remark__c = 'testremark';
        pa1.Forwarded_By__c = 'testuser';
        insert pa1;
        pa1.Id = null;
        
        Map<Id,Proposal_Approval_Log__c> mapVal = new Map<Id,Proposal_Approval_Log__c>();
        mapVal.put(pa1.Id,pa1);
        Test.startTest();
        String result = ApprovalProposalController.updateProposalRecords(new List<Proposal_Approval_Log__c>{pa1});
        System.assert(result.contains('The following exception has occurred'));
        Test.stopTest();
    }
    
    
    
    
    
    
    
}