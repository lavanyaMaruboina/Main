@isTest
public class IND_AMLCheckResponseTest {
 @isTest
    public static void verifyIND_AMLCheckResponse(){
        Test.startTest();
        IND_AMLCheckResponse.Fields resFields=new IND_AMLCheckResponse.Fields();
        	System.assertEquals(resFields.score, null);
         	System.assertEquals(resFields.name, null);
        	System.assertEquals(resFields.value, null);
         	System.assertEquals(resFields.queryValue, null);
        
       IND_AMLCheckResponse.Status resStatus=new IND_AMLCheckResponse.Status();
        	System.assertEquals(resStatus.status, null);
         	System.assertEquals(resStatus.errorDetails, null);
        
        IND_AMLCheckResponse.MatchedRecords resMatchedRecords=new IND_AMLCheckResponse.MatchedRecords();
        	System.assertEquals(resMatchedRecords.id, null);
         	System.assertEquals(resMatchedRecords.score, null);
        	System.assertEquals(resMatchedRecords.listName, null);
         	System.assertEquals(resMatchedRecords.address, null);
      	    System.assertEquals(resMatchedRecords.description, null);
         	System.assertEquals(resMatchedRecords.DateOfBirth, null);
        	System.assertEquals(resMatchedRecords.partialKycFlag, null);
         	System.assertEquals(resMatchedRecords.city, null);
        	System.assertEquals(resMatchedRecords.fields, null);
        
        IND_AMLCheckResponse.MatchedResults resMatchedResults=new IND_AMLCheckResponse.MatchedResults();
        	System.assertEquals(resMatchedResults.total, null);
         	System.assertEquals(resMatchedResults.maxScore, null);
        	System.assertEquals(resMatchedResults.matchedRecords, null);
        
        IND_AMLCheckResponse.WlMatch resWlMatch=new IND_AMLCheckResponse.WlMatch();
        	System.assertEquals(resWlMatch.status, null);
         	System.assertEquals(resWlMatch.matchedResults, null);
        
        IND_AMLCheckResponse result=new IND_AMLCheckResponse();
        	System.assertEquals(result.WlMatch, null);
        Test.stopTest();
    }
    
}