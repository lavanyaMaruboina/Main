@isTest
public class IND_MultipleFileUplaod_API_Test {
    
    
    @isTest
    public static void testIND_MultipleFileUplaod_API(){
        
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/multifileapi/';
        request.httpMethod = 'POST';
        
        request.requestBody = Blob.valueOf('Test Data \n \r');
        RestContext.request = request;
        RestResponse res = new RestResponse();
        RestContext.response= res;
        Test.startTest();
        try{
           // IND_MultipleFileUplaod_API.doPost();
            IND_MultipleFileUplaod_API.getKeyValue(new List<String>{'{\'t\':\'content-disposition,   attachment;filename=TestPDF.pdf\'}'});
        
        }catch(Exception pEx){
            
        }
        Test.stopTest();
        System.debug('res ==>'+res );
        System.debug('RestContext.response ==>'+RestContext.response );
        
    }
    
    @isTest
    public static void testIND_MultipleFileUplaod_API1(){
        
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/multifileapi/';
        request.httpMethod = 'POST';
        
        request.requestBody = Blob.valueOf('Q29udGVudC1EaXNwb3NpdGlvbjo \n \r');
        RestContext.request = request;
        RestResponse res = new RestResponse();
        RestContext.response= res;
        Test.startTest();
        try{
              IND_MultipleFileUplaod_API.doPost();
            IND_MultipleFileUplaod_API.getKeyValue(new List<String>{'{\'t\':\'content-disposition,   attachment;filename=TestPDF.pdf\'}'});
        
        }catch(Exception pEx){
            
        }
        Test.stopTest();
        System.debug('res ==>'+res );
        System.debug('RestContext.response ==>'+RestContext.response );
        
    }
        
      
}