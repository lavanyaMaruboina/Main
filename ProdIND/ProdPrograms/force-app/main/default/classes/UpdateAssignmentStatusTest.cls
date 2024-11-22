@isTest
public class UpdateAssignmentStatusTest 
{
    @isTest
    public static void TestOne()
    {
         string CurrenrPageId = 'a1CBl000000OuXJMA0';
         Account accobj = new Account();
        accobj.Name = 'testname';
        accobj.State__c = 'ASSAM';
        accobj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        insert accobj;
        
         Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        oppobj.accountid = accobj.id;
        insert oppobj;
        
        Loan_Application_Transaction_History__c LL = new Loan_Application_Transaction_History__c();
        LL.Loan_Application_ID__c = oppobj.id;
       LL.Assignment_status__c ='Pending';
        LL.Module_Name__c='Loan Initiation';
        LL.RecordTypeId= Schema.SObjectType.Loan_Application_Transaction_History__c.getRecordTypeInfosByName().get('Lead Assignment').getRecordTypeId();
        LL.Type__c='Module';
        LL.Current_Owner__c=userInfo.getUserId();
        LL.New_Owner__c= userInfo.getUserId();
        insert LL;
        
       PageReference pageRef = Page.AcceptButton;
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(LL);
        ApexPages.currentPage().getParameters().put('Id',LL.id);
        
        UpdateAssignmentStatus.UpdateStatusAcceptedAndRejected();
        UpdateAssignmentStatus.UpdateStatusRejcted();
        UpdateAssignmentStatus.redirect();
    

        
       
        // PageReference pageRef = new PageReference('/' + CurrenrPageId );
    }
    
}