/*------------------------------------------------------------
Author:        Satyan More
Company:       Persistent Systems
Description:   Test class for IND_UidaiBiometricService class 
Apex Class:    IND_UidaiBiometricService
History
Date            Author              Comments
-------------------------------------------------------------
07-01-2022      Satyam More      Created
------------------------------------------------------------*/
@isTest(SeeAllData=false)
public class IND_UidaiBiometricService_Test {

    @isTest
    public static void testUidaiBiometricService(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForUidaiBiometric(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
             String loanAppId = '00671000001DVS1AAO';
            Continuation con = (Continuation)IntegrationEngine.doUidaiBiometricCallout(applicant.Id,loanAppId,'12345');
            
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5nhk3W/13tkTvT9p3wLEsdHabuc+WEo6Phedn5saqrRY7nyjXo75Tirl1sgT4c7qcezNOdWjRB0SJ8Mfz7/172eJQOOy6TgkVnxxFnWZgtYBoTY51ROTuoxTu0j+sGjuvjXRezVa2X/Bb0M8V0P61lSd3JMUeFSGnl1x9mXf1mC+LwooxDcQwR1ynFvM8xck4bwZhf+wgRINfGTl8CCOiqcSN/qLoE3TOjK9W67WqE+cIH3gSW9Lfm39akQxKu9GK6fLqcCFVibKfPt6NkMKMfHiEmReTMHV2Kg+sRZIrI7ahts7kYEepO+jKWgSquyFVE69t92BIXdM2Twcho4qVO/Rr7z7SF/7IConMr0VIJTHfgGCcAnSSwefD3PMk0KZFJvojxQP5FQ1o+lGBrYm/cR+1pQXDPjGZGi0BF4BhbKokl7o9qcNK0UChA2GWJMjikC+J9cIHWJXaHXrKpy0VWfaGU2lQF7qU/PPTxuniZ199d5oEk8EYvD8963JxuMEVKFxhlB0aEyk6RnGMjisxFAUtixNfHuq0NlC8f8q5MO0QyLTbTmcY/+VtOtDMtEIYROphKSpkkmFm8AB6wyJrT7G0DT0fhXlIfyik0Bkl9VemqfcOZIesEVi/+Hzhva1xf6bZ0uB/f8CumSe6AQ0UyIfB/5tcIoOoYNOoOubEfBYRs9d1XYihjA2WdgIt7RColAgLMeHoa8SM0lu4jYd21YtujskCxDUvV/PbOHgbrNSXtEFqnNNoxrWTKkT8riOLdDJd/SGNUuQf9z0NwG3W2z64WQVvC3E8AjMHADG3+aN0b90qTTW8Rwm9iFLJsTKHdWGQKCqKQtIG+zscGj70jYtxHfdn6XofPKY/H9FuYpzbpLIYwo6FzYYrHqz+R9jKNCMYZWvdUwwHEknn85c6+bp7JHL7D06O28SA3RQmP5lB0zERuQPRMrTRFYRt3dsVkM="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;   
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String uidaiOTPResponse = (String)IntegrationEngine.processUidaiBiometricResponse(labels, IntegrationEngine.continuationState);          
            Test.stopTest();
            //String responseExpected ='"{\\"kycResponse\\": {\\"TransactionInfo\\": {\\"Pan\\": \\"6071890510925076003\\", \\"Proc_Code\\": \\"140000\\", \\"Transm_Date_time\\": \\"1229133218\\", \\"Stan\\": \\"247733\\", \\"Local_Trans_Time\\": \\"190218\\", \\"Local_date\\": \\"1229\\", \\"AcqId\\": \\"200031\\", \\"RRN\\": \\"136319247733\\", \\"ResponseCode\\": \\"00\\", \\"ResponseMsg\\": \\"Approved\\", \\"CA_Tid\\": \\"register\\", \\"CA_ID\\": \\"IBLA76232I02361\\", \\"CA_TA\\": \\"IBL HOUSE ANDHERI      MUMBAI       MHIN\\"}, \\"UidData\\": {\\"txn\\": \\"247733\\"}}}"';
            String responseExpected ='"\\"kycResponse\\": {\\"TransactionInfo\\": {\\"Pan\\": \\"6071890363155436548\\", \\"Proc_Code\\": \\"130000\\", \\"Transm_Date_time\\": \\"0107082610\\", \\"Stan\\": \\"145071\\", \\"Local_Trans_Time\\": \\"135610\\", \\"Local_date\\": \\"0107\\", \\"AcqId\\": \\"200031\\", \\"RRN\\": \\"200713145071\\", \\"ResponseCode\\": \\"K1\\", \\"ResponseMsg\\": \\"Resident authentication failed\\", \\"CA_Tid\\": \\"register\\", \\"CA_ID\\": \\"IBLA76232I02361\\", \\"CA_TA\\": \\"IBL HOUSE ANDHERI      MUMBAI       MHIN\\"}, \\"txn\\": \\"UKC:145071\\", \\"k-err\\": \\"K-100\\", \\"k-mesage\\": \\"Resident authentication failed\\", \\"a-err\\": \\"501\\", \\"a-mesage\\": \\"Invalid Certificate identifer in Skey\\"}"';

            System.assertEquals(responseExpected, uidaiOTPResponse, 'Success');
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Script-thrown exception', 'Exception');
        }
    }
    
    @isTest
    public static void testUidaiBiometricService2(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForUidaiBiometric(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
             String loanAppId = '00671000001DVS1AAO';
            Continuation con = (Continuation)IntegrationEngine.doUidaiBiometricCallout(applicant.Id,loanAppId,'12345');
            
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5nhk3W/13tkTvT9p3wLEsdHabuc+WEo6Phedn5saqrRY7nyjXo75Tirl1sgT4c7qcezNOdWjRB0SJ8Mfz7/172eJQOOy6TgkVnxxFnWZgtYBoTY51ROTuoxTu0j+sGjuvjXRezVa2X/Bb0M8V0P61lSd3JMUeFSGnl1x9mXf1mC+LwooxDcQwR1ynFvM8xck4bwZhf+wgRINfGTl8CCOiqcSN/qLoE3TOjK9W67WqE+cIH3gSW9Lfm39akQxKu9GK6fLqcCFVibKfPt6NkMKMfHiEmReTMHV2Kg+sRZIrI7ahts7kYEepO+jKWgSquyFVE69t92BIXdM2Twcho4qVO/Rr7z7SF/7IConMr0VIJTHfgGCcAnSSwefD3PMk0KZFJvojxQP5FQ1o+lGBrYm/cR+1pQXDPjGZGi0BF4BhbKokl7o9qcNK0UChA2GWJMjikC+J9cIHWJXaHXrKpy0VWfaGU2lQF7qU/PPTxuniZ199d5oEk8EYvD8963JxuMEVKFxhlB0aEyk6RnGMjisxFAUtixNfHuq0NlC8f8q5MO0QyLTbTmcY/+VtOtDMtEIYROphKSpkkmFm8AB6wyJrT7G0DT0fhXlIfyik0Bkl9VemqfcOZIesEVi/+Hzhva1xf6bZ0uB/f8CumSe6AQ0UyIfB/5tcIoOoYNOoOubEfBYRs9d1XYihjA2WdgIt7RColAgLMeHoa8SM0lu4jYd21YtujskCxDUvV/PbOHgbrNSXtEFqnNNoxrWTKkT8riOLdDJd/SGNUuQf9z0NwG3W2z64WQVvC3E8AjMHADG3+aN0b90qTTW8Rwm9iFLJsTKHdWGQKCqKQtIG+zscGj70jYtxHfdn6XofPKY/H9FuYpzbpLIYwo6FzYYrHqz+R9jKNCMYZWvdUwwHEknn85c6+bp7JHL7D06O28SA3RQmP5lB0zERuQPRMrTRFYRt3dsVkM="}');
            response.setStatusCode(500);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;   
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String uidaiOTPResponse = (String)IntegrationEngine.processUidaiBiometricResponse(labels, IntegrationEngine.continuationState);          
            Test.stopTest();
            //String responseExpected ='"{\\"kycResponse\\": {\\"TransactionInfo\\": {\\"Pan\\": \\"6071890510925076003\\", \\"Proc_Code\\": \\"140000\\", \\"Transm_Date_time\\": \\"1229133218\\", \\"Stan\\": \\"247733\\", \\"Local_Trans_Time\\": \\"190218\\", \\"Local_date\\": \\"1229\\", \\"AcqId\\": \\"200031\\", \\"RRN\\": \\"136319247733\\", \\"ResponseCode\\": \\"00\\", \\"ResponseMsg\\": \\"Approved\\", \\"CA_Tid\\": \\"register\\", \\"CA_ID\\": \\"IBLA76232I02361\\", \\"CA_TA\\": \\"IBL HOUSE ANDHERI      MUMBAI       MHIN\\"}, \\"UidData\\": {\\"txn\\": \\"247733\\"}}}"';
            String responseExpected ='"\\"kycResponse\\": {\\"TransactionInfo\\": {\\"Pan\\": \\"6071890363155436548\\", \\"Proc_Code\\": \\"130000\\", \\"Transm_Date_time\\": \\"0107082610\\", \\"Stan\\": \\"145071\\", \\"Local_Trans_Time\\": \\"135610\\", \\"Local_date\\": \\"0107\\", \\"AcqId\\": \\"200031\\", \\"RRN\\": \\"200713145071\\", \\"ResponseCode\\": \\"K1\\", \\"ResponseMsg\\": \\"Resident authentication failed\\", \\"CA_Tid\\": \\"register\\", \\"CA_ID\\": \\"IBLA76232I02361\\", \\"CA_TA\\": \\"IBL HOUSE ANDHERI      MUMBAI       MHIN\\"}, \\"txn\\": \\"UKC:145071\\", \\"k-err\\": \\"K-100\\", \\"k-mesage\\": \\"Resident authentication failed\\", \\"a-err\\": \\"501\\", \\"a-mesage\\": \\"Invalid Certificate identifer in Skey\\"}"';

            System.assertEquals(responseExpected, uidaiOTPResponse, 'Success');
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Script-thrown exception', 'Exception');
        }
    }
    @isTest
    public static void testUidaiBiometricService3(){
        try{
            IND_UidaiBiometricService.getUidaiBiometricRequest(null, null); 
           
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Script-thrown exception', 'Exception');
        }
    }
    
    /*
    @isTest
    public static void testUidaiBiometricService2(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForUidaiBiometric2(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
                          String loanAppId = '00671000001DVS1AAO';
            Continuation con = (Continuation)IntegrationEngine.doUidaiBiometricCallout(applicant.Id,loanAppId);
            
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5nhk3W/13tkTvT9p3wLEsdHabuc+WEo6Phedn5saqrRY7nyjXo75Tirl1sgT4c7qcezNOdWjRB0SJ8Mfz7/172eJQOOy6TgkVnxxFnWZgtYBoTY51ROTuoxTu0j+sGjuvjXRezVa2X/Bb0M8V0P61lSd3JMUeFSGnl1x9mXf1mC+LwooxDcQwR1ynFvM8xck4bwZhf+wgRINfGTl8CCOiqcSN/qLoE3TOjK9W67WqE+cIH3gSW9Lfm39akQxKu9GK6fLqcCFVibKfPt6NkMKMfHiEmReTMHV2Kg+sRZIrI7ahts7kYEepO+jKWgSquyFVE69t92BIXdM2Twcho4qVO/Rr7z7SF/7IConMr0VIJTHfgGCcAnSSwefD3PMk0KZFJvojxQP5FQ1o+lGBrYm/cR+1pQXDPjGZGi0BF4BhbKokl7o9qcNK0UChA2GWJMjikC+J9cIHWJXaHXrKpy0VWfaGU2lQF7qU/PPTxuniZ199d5oEk8EYvD8963JxuMEVKFxhlB0aEyk6RnGMjisxFAUtixNfHuq0NlC8f8q5MO0QyLTbTmcY/+VtOtDMtEIYROphKSpkkmFm8AB6wyJrT7G0DT0fhXlIfyik0Bkl9VemqfcOZIesEVi/+Hzhva1xf6bZ0uB/f8CumSe6AQ0UyIfB/5tcIoOoYNOoOubEfBYRs9d1XYihjA2WdgIt7RColAgLMeHoa8SM0lu4jYd21YtujskCxDUvV/PbOHgbrNSXtEFqnNNoxrWTKkT8riOLdDJd/SGNUuQf9z0NwG3W2z64WQVvC3E8AjMHADG3+aN0b90qTTW8Rwm9iFLJsTKHdWGQKCqKQtIG+zscGj70jYtxHfdn6XofPKY/H9FuYpzbpLIYwo6FzYYrHqz+R9jKNCMYZWvdUwwHEknn85c6+bp7JHL7D06O28SA3RQmP5lB0zERuQPRMrTRFYRt3dsVkM="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;   
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String uidaiOTPResponse = (String)IntegrationEngine.processUidaiBiometricResponse(labels, IntegrationEngine.continuationState);          
            Test.stopTest();
            //String responseExpected ='"{\\"kycResponse\\": {\\"TransactionInfo\\": {\\"Pan\\": \\"6071890510925076003\\", \\"Proc_Code\\": \\"140000\\", \\"Transm_Date_time\\": \\"1229133218\\", \\"Stan\\": \\"247733\\", \\"Local_Trans_Time\\": \\"190218\\", \\"Local_date\\": \\"1229\\", \\"AcqId\\": \\"200031\\", \\"RRN\\": \\"136319247733\\", \\"ResponseCode\\": \\"00\\", \\"ResponseMsg\\": \\"Approved\\", \\"CA_Tid\\": \\"register\\", \\"CA_ID\\": \\"IBLA76232I02361\\", \\"CA_TA\\": \\"IBL HOUSE ANDHERI      MUMBAI       MHIN\\"}, \\"UidData\\": {\\"txn\\": \\"247733\\"}}}"';
            String responseExpected ='"\\"kycResponse\\": {\\"TransactionInfo\\": {\\"Pan\\": \\"6071890363155436548\\", \\"Proc_Code\\": \\"130000\\", \\"Transm_Date_time\\": \\"0107082610\\", \\"Stan\\": \\"145071\\", \\"Local_Trans_Time\\": \\"135610\\", \\"Local_date\\": \\"0107\\", \\"AcqId\\": \\"200031\\", \\"RRN\\": \\"200713145071\\", \\"ResponseCode\\": \\"K1\\", \\"ResponseMsg\\": \\"Resident authentication failed\\", \\"CA_Tid\\": \\"register\\", \\"CA_ID\\": \\"IBLA76232I02361\\", \\"CA_TA\\": \\"IBL HOUSE ANDHERI      MUMBAI       MHIN\\"}, \\"txn\\": \\"UKC:145071\\", \\"k-err\\": \\"K-100\\", \\"k-mesage\\": \\"Resident authentication failed\\", \\"a-err\\": \\"501\\", \\"a-mesage\\": \\"Invalid Certificate identifer in Skey\\"}"';

            System.assertEquals(responseExpected, uidaiOTPResponse, 'Success');
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Script-thrown exception', 'Exception');
        }
    }
    
    /*@isTest
    public static void testUidaiBiometricService2(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForUidaiBiometric(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
             
            Continuation con = (Continuation)IntegrationEngine.doUidaiBiometricCallout(applicant.Id);
            
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"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"}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;   
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String uidaiBiometricResponse = (String)IntegrationEngine.processUidaiBiometricResponse(labels, IntegrationEngine.continuationState);          
            Test.stopTest();
            //String responseExpected ='"{\\"kycResponse\\": {\\"TransactionInfo\\": {\\"Pan\\": \\"6071890510925076003\\", \\"Proc_Code\\": \\"140000\\", \\"Transm_Date_time\\": \\"1229133218\\", \\"Stan\\": \\"247733\\", \\"Local_Trans_Time\\": \\"190218\\", \\"Local_date\\": \\"1229\\", \\"AcqId\\": \\"200031\\", \\"RRN\\": \\"136319247733\\", \\"ResponseCode\\": \\"00\\", \\"ResponseMsg\\": \\"Approved\\", \\"CA_Tid\\": \\"register\\", \\"CA_ID\\": \\"IBLA76232I02361\\", \\"CA_TA\\": \\"IBL HOUSE ANDHERI      MUMBAI       MHIN\\"}, \\"UidData\\": {\\"txn\\": \\"247733\\"}}}"';
            String responseExpected ='"{"kycResponse":{"TransactionInfo":{"Pan":"6071890617513230925","Proc_Code":"130000","Transm_Date_time":"1228125049","Stan":"115204","Local_Trans_Time":"182049","Local_date":"1228","AcqId":"200031","RRN":"136218115204","ResponseCode":"00","ResponseMsg":"Approved","CA_Tid":"register","CA_ID":"IBLA76232I02361","CA_TA":"IBL HOUSE ANDHERI      MUMBAI       MHIN"},"UidData":{"tkn":"01000733bHGeC96SuJWbzUsBDcTiE9X2ayeYj8j8wQ3cC4bqJT8ta9n4eI6mGBf4YLM0f","txn":"UKC:115204","uid":"617325139025","dob":"08-06-1981","gender":"M","name":"Perumal S","email":"null","phone":"null","dist":"Madurai","house":"7B","lm":"null","co":"SO:  subramanian","subdist":"null","po":"null","loc":"null","pc":"600125","state":"Tamil Nadu","street":"T V KAMARAJAR STREET","vtc":"Madurai","Pht":"9j4AAQSkZJRgABAgAAAQABAAD2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjLwAARCADIAKADASIAAhEBAxEB8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn68QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn69oADAMBAAIRAxEAPwDTp60ynrUDHUUUUAL2pcUYpQKYBTT1p3U0hpMBtOUU2noKBgaco4pCOacBTEFBFLiikAlFLRQA3FFLRQA3FIRTqQikBABzTwKQU4UwFAoApaUUAAFOAxRS0wExSEDpTs0hoAjIqRBgU01IvSkMaRzTgKQ9acOlMQmKXFFLigY3FGKcaSgBMUmKdSUgExSFadQaAK4FOApBUgpCDFLilFKKYCYpcUUtMBMU0inZpjMFGScCgYgHNTKPlqnLe2tum+a4ijTP3ncAfmakjv7R4wVuYWB7hwaEBN3p4HFVhd27EgTxkjj7wqwrKRwRTEKBS0ClpDG0mKfSYoAbSYp4GDRQAzFBFOpKQFcCpAKatPFAABS0UUAFLRXH+MPFK2ET6fZSZumGJXU6oemexP6D60wLOs+MrLTpGghHnTjII6KD7nAD+FcDqfia1GQaLgiMHIjj4Ar+dYtxcO+TvJyeoquDu6s1OwjRF8xBIJk+p5pftsjLnJHtWcTtPy5PtQZuew9qLBc0Uum3BiSD61bg1u9tpf9Hu5EIhDcfl0NYIfORk0eYPuk4xTsK56PpnxFdSI7+AOM8yRcH8j1Ou307V7LVYPNtJlkUfeA6qfcdq+fzKyMDmtvwqzafqcNwr7ADhdT1pWGme59qKgtbuK7gSWGRZEYcMhyD61NSGLSUZozQAlIaWkJoAhBpwNMFPFIB1FJijFMDH8UasdI0SadGAlf93Hn+8Qf6An8K8WuLqSaVnZyzMdzMx5J96734lXDfabO338LGXKfU4yfyNedNljxz+FNCY5nJBPWo2lJwO31qQQuYy5piJI77EUn2AouFmGAyyikaRuyTvWlBpTzMA3B789K2LPRIQDv5xUSqJFRptnMrb3EoDEFQas2Y6xlmyea6UWEY2nbyMVK0KuwAHyock+prJ1mbKiupyc1gVX5c5xVZHaNwv8Q9a6e5hU5wOawbyHbKH9DzV05t7kVKaWx1gvXGtNUWFjtguOHHbd2b69vf8K9UDZHFfP8EximGGIOcqQehr2RLprzR7W4kILvGC2PWtTJGjmkJoopDDNJmlpKBkINPBqOnCkIkzRSCjtTA8z+JVuwDa1tcZAjeDYPqrEn0IVwQchwo6V614083eji4jXL27bjungwBD+FeVWcHn3gUjgHJobshJXZtW0IaJeO3pVm2sYkcso5JzUE7tBEBGuT0qCO8vUGVQiK5rNnVdR3N+CwBDHPU1fgsowAskzRknrtyK5qDW7yKQB48jvg1sW+qiYDPWocXHctST2NSXT7eKNf9JLtj+EDABqpLbgLx1qGbVBFnP4Vj3Gs3szbYYhg9zxTScnoDly7luePHU1j6hHuhZgOnNEhv2BLtwf9oU+ASupSXn0rSMeXqZuXNoYSvuYYPtXufhhv+KesRnP7pQfrXiMNrI+ofZ0Uly+0V7xpsPkWUEQAGxAvHsK6LnNaxfzRSUUDFopM8UZpDIKeuKZTu1IQ7NLnimA0tNAZPid5E8P3TRffwqgVgD+hNeU2EATUJwBgLxXqvibdwj9yF2Py3rXn3kJFcu6sDvAyPes6jtobU43VyC6jfb8nDVTNspgjkBElwkgZklZgrrd4IOPxB962DEJOtN+xxjqtYqdjZwuU47G2j0+KNmZ7sAkyI2VJz0OfbPT2p8AC3GFH3eD9asGPYDsGKgh4kwozg80SlcIwsOvfnkDMPlzzimNa2zwzI6gPIpCPnITkdsfrzVm7BKg7e3NJGm6MDtiiMrIc4XdjGtrOO2t5o5JFeViNhjJ+X3zVy1jcDDtuI7+tXxaxt1ABpGRUHAxVOpdkclkT+FNPE3iC7lI1ajH48A6q9LjG1QPSuP8H24U3dwOrsqkPAK9dgDXRHY5pbkwNGaYpoJpiJKTtTSeBSbuKQxmKdimCnUCHAUYNJmlzTAparEZtLuYwMs0bYHvjivNmjCAMOvc+teqMMqR61zV9oSHzGREBIODtFZ1It2aNKckrpnJo3FTJ8wOSaqZaNipyMHBBolu1hj3M2AK5ZJ3OqMlYvMqCNuO1UILmCKYLhuTjOO9Zk+uEqVRefc1Vh1G6eUbuVJxtAq40nbUmVaKeh02oXtvtxGp5HQc0WjK0A4I9M+lcfXUicxcDqMD0NRQ63cR8OAar2TtoSqyvqdPIcccVVZiahtr9bqHeDyOo9KsWqG5u44gOC1TGNnYqU01dHXeERxLJOP+WpHgV0orP062FtAEH1q+Olda0Rxt3dyQUhHFC0HpQAp6UmBigmkJ4pANXpS0gPFLSAcBzS4oXk0p2pgR44qOVcrU54PbFRyYx9aYHnWvWRtL1nUfu3Ofoa5+9g+0Q7A2MHPHeu38WzbIEhjCmR+pPOBXF78HDcHvWMlZ3RtGV1ZmdFpTg7mIJ7A1ftrUoQRIUYdMLUgLE4FSC0eUZMu36Co523qaKKjqkQXELMoBlLe20CqcunmVckgH1AxWn9kKc+bk+9R4KePFHNbYJJPoVLK3NqrZOc11nhqzaSbz2HHRa5Z5wz4Wt3Tb+6srcCKZtyjowyP1rSOruzGTsrI9DjGMCpV6VVtJxc28co43DJHpVsda2Mh60GlUZprfWgYZpD0ozRSAiFOFN4pQakZKvQ+oqQHI96RBhQ1Ob5W3DkfWmIaCCuDUE7rHGzMcAClubiG3P7yRRnsOTj6dayb2+W5CrEGVBy27HJCk3YaRyiCdpLsO3QHP0FcvPKs0zNG3GeDXUatGJxIvXiuPg+UbTxis29DSC94lFy8Jw4P1FSJqS4ILgU7yw6YIBqu9sAcgAis00zVprYlk1NNuA4qAzy3RwmQvdjSrAufuDn0FWETaOlNtLYSTe5BsEa4Fatldx3bLGoKydGFZzqeauaFbk37PjgD+dVCRNSKsdo0wEIibv0rbB5rmID5ajHBHIrUh1TGBKn4rAIVpGXcxaNhKYx5ptvcRTgmN1bAzjuPwoc4qxC560E8U0HmlY8YoAjzQZEjUu7BVHUk4ArDuNZkOVgUKP7x5Pb8PX1rPdpZiHeRmbp8xzWTmUkdLNrVtCpVGMjD+70Os241m4lXareWv+zwfzrMXcnVcipFUMucUnJsdkSCRm5IxTycIaheRIUaSV1RF6sxwBWbPqNxcgrZIETAJ6yryfov+P5UldjbSJbhdyt6iuVng8q+kXsTkV0lsZz+6uGMkvJ37QNwDjj6f1qnd6a91OHiIUqOQ1JrSw4tXuZCHa+3tU+wY5WpZtOngwZFypiXkU5UbaKwZ0rVaFby1J6GkdNtXBGfSmSQM2OPpRcLFFgMc1t6RB5cIkxksc4VLb6PDDAZboKzAZIYKtKs7ry7M5YnBcqQqj+p9O1bRiYTmjWWWNmZFkQumA6hgSuRnn0p9YQs1jfzVdln6+aOpNWY9W8vC3UZHAE0j5H1I6j8M1pYyUjRy6MCrEYOQc1bj1S4i4f8AeAevWstNRtJEDC4QA9A52n8jzUuQKsCPUUtitDai1q2YEyBo8e2R+lXo545lJjkVwOu05xXKlQCaFLROHRirDoRTU2LlQm1hyKNxHUUO047UYBrIYomQLlugpjTTS8QqqD+83JKhoVYYpghliPy8iqQiCTTJJZVle4d3Ucb+QPoOgCpVjli4dAQO61Ok5HDjFTK6t3p3FYpNskHI6HII4INJuljyQBMp7HhvwPf8fzq88SOOQpnUBtyPusR7HmgAjaG5VkDA8cqeCPqKzbuya0O9MmIwDjtXJLbOCyHI6MvUfQ9RT45JSCkmJUPGe4jP41Mo3RcZuLMbfnvmrMA8lg5QvKBkIONvuT2qaOwj+0F4ydnVcj7tWAgA8uJM9znvUxhbcudW6sir9mluXV7mTeR0RRhR+H+NSlFj6nn0FWlt5CP3kmPZaesUcf3V59e9a3MNymkMsh6bF9WqQWMSnLjcfU1Z6nNIeuKVx2IvJQfwijy0BztGfpUhppGeTRcLB96g0oPFIeeBUlCnmlFFFAh69qcDRRQAYDDkU3yloooGOCle9ByKKKYhc+1RSEHpjd60UUAWQYI4YwEIbb8xJzk5+nFNd0BUgjoaKKFoFhm9TSZ54oopgKBxSEdKKKQBgY6VGaKKAE7UmcZoopAf9k="}},"#omit-xml-declaration":"yes"}"';

            System.assertEquals(responseExpected, uidaiBiometricResponse, 'Success');
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Script-thrown exception', 'Exception');
        }
    }*/
    
   
}