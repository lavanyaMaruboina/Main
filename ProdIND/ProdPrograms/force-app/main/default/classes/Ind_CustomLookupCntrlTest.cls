/*
* @Test Class:  Ind_CustomLookupCntrlTest
* @Author: 		Khushiram
* @Description :Test Class for Ind_CustomLookupController.
* @Company:     Persistent Systems
*/
@isTest(seeAllData = false)
public class Ind_CustomLookupCntrlTest {
	@isTest 
    public static void searchLookupTest(){
        try{  
            Test.startTest();
                list<sobject> sojbectlistOne = Ind_CustomLookupController.searchLookup('Name','Opportunity','Name','Opportunity','stageName','Qualification');
            	list<sobject> sojbectlistTwo = Ind_CustomLookupController.searchLookup('Name','Opportunity','Name','Opportunity','','');
            	list<sobject> sojbectlist3 = Ind_CustomLookupController.searchLookup('Name','Opportunity',null,'Opportunity','stageName','Qualification');
            	list<sobject> sojbectlist4 = Ind_CustomLookupController.searchLookup('Name','Opportunity',null,'','','');
            	list<sobject> sojbectlistT5 = Ind_CustomLookupController.searchLookup('Name',null,'','Opportunity','','');
            	list<sobject> sojbectlistException = Ind_CustomLookupController.searchLookup('null','null','null','null','','');
                System.assertNotEquals(null,sojbectlistOne);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
   @isTest 
    public static void searchLookupWithArrayTest(){
        try{  
            
            List<String> fetchFields = new List<String>{'Name', 'Industry'};
            List<String> filterFields = new List<String>{'Industry'};  
            List<String> filterTerms = new List<String>{'Finance'};
            List<String> filterMultipleTerms = new List<String>{'Technology', 'Manufacturing'};    
            String filterMultipleFieldName = 'Type';
            
            //List<String> fieldList = new List<String>{'Name'};
            //List<String> filterList = new List<String>{'stageName'};
            //List<String> filterTermList = new List<String>{'Prospecting'};

            Test.startTest();
                list<sobject> sojbectlistOne = Ind_CustomLookupController.searchLookupWithArray(fetchFields,'Account','Name','Test',filterFields,filterTerms,filterMultipleTerms,filterMultipleFieldName);
                list<sobject> sojbectlistTwo = Ind_CustomLookupController.searchLookupWithArray(fetchFields,'Account','Name','Test',null,null,filterMultipleTerms,filterMultipleFieldName);
                list<sobject> sojbectlist3 = Ind_CustomLookupController.searchLookupWithArray(fetchFields,'Account',null,'Test',filterFields,filterTerms,filterMultipleTerms,filterMultipleFieldName);
                list<sobject> sojbectlist4 = Ind_CustomLookupController.searchLookupWithArray(fetchFields,'Account',null,'',null,null,null,filterMultipleFieldName);
                list<sobject> sojbectlistT5 = Ind_CustomLookupController.searchLookupWithArray(fetchFields,null,'','Test',null,null,filterMultipleTerms,null);
                list<sobject> sojbectlistException = Ind_CustomLookupController.searchLookupWithArray(null,'null','null','null',null,null,null,null);
            Test.stopTest();
            
            System.assertNotEquals(null,sojbectlistOne);
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    
    
}