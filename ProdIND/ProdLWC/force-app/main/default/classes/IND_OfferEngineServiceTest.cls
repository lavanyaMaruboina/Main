@isTest(SeeAllData=false)
public class IND_OfferEngineServiceTest {
   
    @isTest
    public static void getOfferEngineCallOutRequest(){
        
        try{
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        insert opgd1;
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.leadId = opgd1.Id;
        reqWrapper.vehicleRegisterationNumber = opgd1.Id;
        
        List<Final_Term__c> finalTermList = new List<Final_Term__c>();
        
        Final_Term__c fg1 = new Final_Term__c();
        fg1.CRM_IRR__c = 120;
        fg1.Loan_Application__c = opgd1.Id;
        fg1.Holiday_period__c='30';
        fg1.EMI_Amount__c= 10000;
        finalTermList.add(fg1);
        insert finalTermList;
            
        
        IND_OfferEngineService.getOfferEngineCallOutRequest(reqWrapper,finalTermList,opgd1.id);
        }
        catch(Exception e){}
        
    }
    
    @isTest
    public static void getOfferEngineCallOutRequest1(){
        
        try{
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        insert opgd1;
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.leadId = opgd1.Id;
        reqWrapper.vehicleRegisterationNumber = opgd1.Id;
        reqWrapper.currentScreen = 'CAM and Approval Log';
        
        List<Final_Term__c> finalTermList = new List<Final_Term__c>();
        
        Final_Term__c fg1 = new Final_Term__c();
        fg1.CRM_IRR__c = 120;
        fg1.Loan_Application__c = opgd1.Id;
        fg1.Holiday_period__c='30';
        fg1.EMI_Amount__c= 10000;
        fg1.Tenure__c = null;
        finalTermList.add(fg1);
        insert finalTermList;
            
        
        IND_OfferEngineService.getOfferEngineCallOutRequest(reqWrapper,finalTermList,opgd1.id);
        //IND_OfferEngineRequest fr1 = new IND_OfferEngineRequest(reqWrapper,finalTermList);
        }
        catch(Exception e){}
        
    }


}