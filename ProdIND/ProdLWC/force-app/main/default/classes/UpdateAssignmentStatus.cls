public class UpdateAssignmentStatus 
{
    public static string Message{get;set;}
    ApexPages.StandardController setCon;
    public UpdateAssignmentStatus(ApexPages.StandardController setCon){}
    public static PageReference UpdateStatusAcceptedAndRejected()
    { 
        PageReference pageRef;
        string UserID= userInfo.getUserId();
        string CurrenrPageId = System.currentPageReference().getParameters().get('Id');
        system.debug('The current id is '+CurrenrPageId);
        List<Loan_Application_Transaction_History__c> LPP = [select id,Branch__c,Type__c,Loan_Application_ID__c,Assignment_status__c,Current_Owner__c,New_Owner__c from Loan_Application_Transaction_History__c where id=:CurrenrPageId];
        
        system.debug('The lPP list is '+LPP);
        List<Opportunity> oppList = [select id,AccountId,PreviousAccountId__c from Opportunity where Id =: Lpp[0].Loan_Application_ID__c LIMIT 1];
        
        if(!LPP.isEmpty())
        {   
            if(LPP[0].New_Owner__c ==UserID)
            {
                if(LPP[0].Assignment_status__c != 'Accepted')
                {
                    LPP[0].Assignment_status__c ='Accepted';
                    
                    if(LPP[0].Type__c == 'Application' && LPP[0].Assignment_status__c =='Accepted'){
                        if(oppList[0].PreviousAccountId__c != null){
                            oppList[0].PreviousAccountId__c = oppList[0].PreviousAccountId__c + ',' + oppList[0].AccountId;
                        }else{
                            oppList[0].PreviousAccountId__c = oppList[0].AccountId;
                        }
                    }
                    update oppList;
                    update LPP;
                    pageRef = new PageReference('/' + CurrenrPageId );
                    pageRef.setRedirect(true);
                }     
            }
            else
            {  
                Message='Current Owner cant not Accept the application'; 
            }  
        }
        return pageRef;
    }
    
    public  static PageReference redirect()
    {  PageReference pageRef;
     string CurrenrPageId = System.currentPageReference().getParameters().get('Id');
     system.debug('The current id is '+CurrenrPageId);
     pageRef = new PageReference('/' + CurrenrPageId );
     pageRef.setRedirect(true);
     return pageRef;
    } 
    public static PageReference UpdateStatusRejcted()
    {
        string CurrenrPageIdd = System.currentPageReference().getParameters().get('Id');
        List<Loan_Application_Transaction_History__c> LPPP = [select id,Assignment_status__c,Current_Owner__c,New_Owner__c from Loan_Application_Transaction_History__c where id=:CurrenrPageIdd];
        PageReference pageRef;
         string UserID= userInfo.getUserId();
        if(!LPPP.isEmpty())
        {   
            if(LPPP[0].New_Owner__c ==UserID)
            {  
                if(LPPP[0].Assignment_status__c != 'Rejected')
                {
                    LPPP[0].Assignment_status__c ='Rejected';
                    update LPPP;
                    pageRef = new PageReference('/' + CurrenrPageIdd );
                    pageRef.setRedirect(true);
                }    
            }
            else
            {  
                Message='Current Owner cant not reject the application'; 
            } 
        }        

        return pageRef;
    }  
}