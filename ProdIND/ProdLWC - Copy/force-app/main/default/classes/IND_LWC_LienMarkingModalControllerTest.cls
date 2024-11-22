/**
 * Author - Neeraj Mehethrajkar - Salesforce
 * Date - 1 Nov 2023
 * Description - Test class for the IND_LWC_LienMarkingModalController
 */
@isTest
public class IND_LWC_LienMarkingModalControllerTest {
	
    @isTest
    public static void testGetExposures(){
        try{
                Opportunity opgr1 = new Opportunity();
                opgr1.StageName = 'Qualification';
                opgr1.CloseDate = Date.newInstance(2021, 1, 11);
                opgr1.Name = 'testone';
                insert opgr1;
                           
                Exposure__c ex = new Exposure__c();
            	ex.Loan_Application__c = opgr1.Id;
            	ex.Deal_No__c = 'ASDBAS';
            	ex.Deal_Date__c = System.now();
            	ex.Product_Variant_Name__c = 'test tractor';
            	ex.Finance_Amt__c = 12342134;
            	insert ex;
            
                Test.startTest();
                     IND_LWC_LienMarkingModalController.getExposures(opgr1.Id);
                Test.stopTest();
            
         }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void testGetExposures_1(){
        try{
                Opportunity opgr1 = new Opportunity();
                opgr1.StageName = 'Qualification';
                opgr1.CloseDate = Date.newInstance(2021, 1, 11);
                opgr1.Name = 'testone';
                insert opgr1;
                           
                Exposure__c ex = new Exposure__c();
            	ex.Loan_Application__c = opgr1.Id;
            	ex.Deal_No__c = 'ASDBAS';
            	ex.Deal_Date__c = System.now();
            	ex.Product_Variant_Name__c = 'test tractor';
            	ex.Finance_Amt__c = 12342134;
            	insert ex;
            
                Test.startTest();
            		IND_LWC_LienMarkingModalController.isTestRun = true;
                     IND_LWC_LienMarkingModalController.getExposures(opgr1.Id);
                Test.stopTest();
            
         }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
}