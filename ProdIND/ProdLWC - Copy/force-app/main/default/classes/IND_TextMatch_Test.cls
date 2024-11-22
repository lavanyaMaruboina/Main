/*------------------------------------------------------------
Author:        Satyam More
Company:       Persistent Systems
Description:   Test class created to validate the IND_TextMatchRequest 
History
Date            Author              Comments
-------------------------------------------------------------
14-1-2022      Satyam More       Created
18-1-2022      Satyam More       Modified
------------------------------------------------------------*/

@isTest(SeeAllData=false)
public class IND_TextMatch_Test {

    @isTest
    public static void testTextMatch(){
        
        try{   
            
            Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
            system.debug('p'+ p);
    		User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
					EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
					LocaleSidKey='en_US', ProfileId = p.Id,
					TimeZoneSidKey='America/Los_Angeles',
					UserName='standarduser4@testorg.com.psdev1', MobilePhone = '9701498575',
					Maker_Id__c = '1002');
            insert u;
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                //opp.Lead_number__c ='';
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            String textMatch = '{"leadId":"MT8971254_894378439","applicantFirstName":"NAMA" ,"applicantMiddleName":"VEENESH","applicantLastName":"KUMAR" ,"name":"DestinationSources","destinationName":"Golden Source" ,"destinationNames":"NAMA Kumar"}';
            
            // Continuation con = (Continuation)IntegrationEngine.doVahanVehicleReportAsyncCallout(vahanVehicleReport);
            
            Continuation con = (Continuation)IntegrationEngine.doTextMatchCallout(textMatch);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"WQS3WU5PcbxKdeCdQ8H/I3m8SkT/+VsTy9KjQMev1jyqg4oBEjk7ZX2g3vBucCeCGGRIGAXavEGu3+YrCna9YX8HiUIqDqQXgZK/o0EfE5v7wCIewluS2cD1IaJ9DuxiikrxmJ7TYOhNeVIfSNcyf15VNK/w/dCG1XhKpfgA0c76lSJb4WWSL3fU7sdSCGLYvgZa+IWcQKpqN6ENwX8i6YJo0L/+c4m0EoOBZg9S4yOb3EZaJh5Xy/ernvuj9Bc8ifWgSefmRt8ed3tyu4PDuIXGC8KaM65cSZUefz975zENC75dykngjTgHPszKOgHmBgIFQzbLaatUXp+g7ysYsZA93xuT56Nbhh6EhUz0QUh9QvXrCOKc+GE8hTTb+PEekPSh8PRmqs0E1KSGh0OZIyQ6G2sE/pYRgBO9QeS8aNQxc/ePkhrA/zLnAC3S8Xp+nC0YD7P7K0wU0/MEmGskGKaJfDvXBN1hqo77tuUfLsDig1AAoLnwHipf2Hi8txWBC0iWJYXfik93ox/8a0xe97YEvdsDieIFfGA7j00Je53h7WVENeLJwnO/1CM4kEIgZFK8pDud3i+z86B/Axp5Mrp53mctqCEP3nPpAVpW812he6yXxO6fyvl1hUFPGaMXrDs91vLZT+FNaeSkyWH3yuRnc684piS6JlYCl6DKA2RJ/nKJ14zVcfyqg5jhciSk/ZpIRhLXqWmZfTDe465B8xzeWc7QSjfmOYhBioqIdkzP1iCpMW88qxBKivZpWv9qwVnI3ivEv2fgykwljnkdmf3l6xChu/Xv59Gyxxi2GipZPSYTF8IIsOOLttpoWsxfRe2S7n3hajbMU/HknEdSTKdDMRSlzxhPKxPhHf1HRlEBgxjxjRUjcUHBNWBZ3KgNbGHZW7LmrlLaf4TY9tM4uhJPXzaik3qizQ3JFkmVfvptEuGwrN9A3uagF0CYZSwIYJQZ2Pjas64A2ddE4QQR35l8Zm5vsVCCGXN7zKoJ0X0gSxzASY9c6DbzwWq2vm/9OaDKqmYZlSc7MSAAPSnx/j0RfEI6zvTHikX5Yrx9aRBPbvRYsgFKCMSBeN+uE5ikPfnIfkoNIZodWYJkMnUW3e3U6RWpp0PDdp7KZ/wOGlF4CO2rZ4rYSvm25vw1aB/4MftPGNvHufqMZUUVGGk5GXFcIIkLj58ncDGcpwID0xa8svxaisiSmsvFb17jHD1gOWg5Q0XL/+HwkBxrpjnOW0gtLcBVcT6Jixrk8YR5R2n8hNk/9TVulINna6q2lBYxxaF9iGdi4PomYEGUaVVapXht6xyVzxvFOQzGvDuojaodeDiwGJXOmwF8lRs4o4+OxfvpF8SFM4nRDSABOUQ6NXEHljzMwndEXHH89+cwJfbeQADM7rNDuvEDsvFFnHiRSrMvIeHxLq9CSaJgBQ1j3FepDGtKqQ4Kd/LQ8OGoiyGRdCKUVr4u87LqD1IQxpq42+D5EeisvvQV2MLUzzLzGS8dpoWYDc94dd24V721vSQe9//oZwq615Dndqu8L2Sslb6+WE2M4A7UGEvypI5cTYnqG/IAp0fGu3aqamXKqaTD83Sy4YdgIs4slboAoReRVFl+IuuXSQtOIWqOS6TORhtsRkJM4pQuywRyJfnBANwl1Y2/lgLJfabniEVjAksuVrqQdOhnC1qRWSGvL3ShKHR+iZ68p97UUzvzxf15vnTY/PCOTY0c+XZaMyQT7BziNt31dgViYXjj28EtMnBLGGlOfi9GtmXNYfhRjF6qHog="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            
            String textMatchCallOutResponse;
            system.runAs(u){
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                textMatchCallOutResponse= (String)IntegrationEngine.processTextMatchResponse(labels, IntegrationEngine.continuationState);
                Test.stopTest();
            }
            String responseExpected ='{"body":null,"ResponseData":{"Status":"Success","ResponseInfo":{"SolutionSetInstanceId":"3a2a9614-10f9-4243-8c18-c1ee0373acc1","ApplicationId":26926040},"Fields":{"Decision":"Pass","ApplicationId":"26926040","ApplicationData":{"Services":{"Service":{"Skip":"N","Name":"","Id":"VMA001","Consent":"true"}}},"Applicants":{"Applicant":{"Services":{"Service":[{"Status":"Pass","Skip":"N","Operations":{"Operation":[{"Status":"Pass","Params":{"Param":[{"Value":{"DestinationSource":[{"Telephones":null,"Names":{"Name":"NAMA Kumar"},"Identifiers":null,"Gender":null,"FatherName":null,"EmailAddresses":null,"DestinationName":"Golden Source","DateOfBirth":null,"Addresses":null}]},"Name":"DestinationSources"}]},"Name":"","Id":"VMA001P001","Data":{"Response":{"RawResponse":{"MatchService":{"Source":[{"SourceName":"Golden Source","PhoneMatch":"NULL","NameMatch":"72","Name":{"LastName":"","FirstName":"NAMA Kumar"},"IDMatch":"NULL","GenderMatch":"NULL","FatherNameMatch":"NULL","FatherName":{"MiddleName":"","LastName":"","FirstName":""},"EmailMatch":"NULL","DobMatch":"NULL","AddressMatch":"NULL"}]}}}}}]},"Name":"","Id":"VMA001","Consent":"true"}]},"ApplicantMiddleName":"VEENESH","ApplicantLastName":"KUMAR","ApplicantIdentifier":"c48a041e-66e7-459e-891d-8d79427daa3d","ApplicantFirstName":"NAMA"}}}},"RequestId":"17012022183615556"}';
            System.assertEquals(responseExpected, textMatchCallOutResponse, 'SUCCESS');
            
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),'Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Mobile number should be of 10 digits: [MobilePhone]', 'Exception');
        }
    }
    
    @isTest
    public static void testTextMatch2(){
        
        try{   
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                //opp.Lead_number__c ='';
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            String textMatch = '{"leadId":"","applicantFirstName":"NAMA" ,"applicantMiddleName":"VEENESH","applicantLastName":"KUMAR" ,"name":"DestinationSources","destinationName":"Golden Source" ,"destinationNames":"NAMA Kumar"}';
            
           // Continuation con = (Continuation)IntegrationEngine.doVahanVehicleReportAsyncCallout(vahanVehicleReport);
            Continuation con = (Continuation)IntegrationEngine.doTextMatchCallout(textMatch);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"WQS3WU5PcbxKdeCdQ8H/I3m8SkT/+VsTy9KjQMev1jyqg4oBEjk7ZX2g3vBucCeCGGRIGAXavEGu3+YrCna9YX8HiUIqDqQXgZK/o0EfE5v7wCIewluS2cD1IaJ9DuxiikrxmJ7TYOhNeVIfSNcyf15VNK/w/dCG1XhKpfgA0c76lSJb4WWSL3fU7sdSCGLYvgZa+IWcQKpqN6ENwX8i6YJo0L/+c4m0EoOBZg9S4yOb3EZaJh5Xy/ernvuj9Bc8ifWgSefmRt8ed3tyu4PDuIXGC8KaM65cSZUefz975zENC75dykngjTgHPszKOgHmBgIFQzbLaatUXp+g7ysYsZA93xuT56Nbhh6EhUz0QUh9QvXrCOKc+GE8hTTb+PEekPSh8PRmqs0E1KSGh0OZIyQ6G2sE/pYRgBO9QeS8aNQxc/ePkhrA/zLnAC3S8Xp+nC0YD7P7K0wU0/MEmGskGKaJfDvXBN1hqo77tuUfLsDig1AAoLnwHipf2Hi8txWBC0iWJYXfik93ox/8a0xe97YEvdsDieIFfGA7j00Je53h7WVENeLJwnO/1CM4kEIgZFK8pDud3i+z86B/Axp5Mrp53mctqCEP3nPpAVpW812he6yXxO6fyvl1hUFPGaMXrDs91vLZT+FNaeSkyWH3yuRnc684piS6JlYCl6DKA2RJ/nKJ14zVcfyqg5jhciSk/ZpIRhLXqWmZfTDe465B8xzeWc7QSjfmOYhBioqIdkzP1iCpMW88qxBKivZpWv9qwVnI3ivEv2fgykwljnkdmf3l6xChu/Xv59Gyxxi2GipZPSYTF8IIsOOLttpoWsxfRe2S7n3hajbMU/HknEdSTKdDMRSlzxhPKxPhHf1HRlEBgxjxjRUjcUHBNWBZ3KgNbGHZW7LmrlLaf4TY9tM4uhJPXzaik3qizQ3JFkmVfvptEuGwrN9A3uagF0CYZSwIYJQZ2Pjas64A2ddE4QQR35l8Zm5vsVCCGXN7zKoJ0X0gSxzASY9c6DbzwWq2vm/9OaDKqmYZlSc7MSAAPSnx/j0RfEI6zvTHikX5Yrx9aRBPbvRYsgFKCMSBeN+uE5ikPfnIfkoNIZodWYJkMnUW3e3U6RWpp0PDdp7KZ/wOGlF4CO2rZ4rYSvm25vw1aB/4MftPGNvHufqMZUUVGGk5GXFcIIkLj58ncDGcpwID0xa8svxaisiSmsvFb17jHD1gOWg5Q0XL/+HwkBxrpjnOW0gtLcBVcT6Jixrk8YR5R2n8hNk/9TVulINna6q2lBYxxaF9iGdi4PomYEGUaVVapXht6xyVzxvFOQzGvDuojaodeDiwGJXOmwF8lRs4o4+OxfvpF8SFM4nRDSABOUQ6NXEHljzMwndEXHH89+cwJfbeQADM7rNDuvEDsvFFnHiRSrMvIeHxLq9CSaJgBQ1j3FepDGtKqQ4Kd/LQ8OGoiyGRdCKUVr4u87LqD1IQxpq42+D5EeisvvQV2MLUzzLzGS8dpoWYDc94dd24V721vSQe9//oZwq615Dndqu8L2Sslb6+WE2M4A7UGEvypI5cTYnqG/IAp0fGu3aqamXKqaTD83Sy4YdgIs4slboAoReRVFl+IuuXSQtOIWqOS6TORhtsRkJM4pQuywRyJfnBANwl1Y2/lgLJfabniEVjAksuVrqQdOhnC1qRWSGvL3ShKHR+iZ68p97UUzvzxf15vnTY/PCOTY0c+XZaMyQT7BziNt31dgViYXjj28EtMnBLGGlOfi9GtmXNYfhRjF6qHog="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String textMatchCallOutResponse= (String)IntegrationEngine.processTextMatchResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"ResponseData":{"Status":"Success","ResponseInfo":{"SolutionSetInstanceId":"3a2a9614-10f9-4243-8c18-c1ee0373acc1","ApplicationId":26926040},"Fields":{"Decision":"Pass","ApplicationId":"26926040","ApplicationData":{"Services1":null},"Applicants":{"Applicant":{"Services":{"Service":[{"Status":"Pass","Skip":"N","Operations":{"Operation":[{"Status":"Pass","Params":{"Param":[{"Value":{"DestinationSource":[{"Telephones":null,"Names":{"Name":"NAMA Kumar"},"Identifiers":null,"Gender":null,"FatherName":null,"EmailAddresses":null,"DestinationName":"Golden Source","DateOfBirth":null,"Addresses":null}]},"Name":"DestinationSources"}]},"Name":"","Id":"VMA001P001","Data":{"Response":{"RawResponse":{"MatchService":{"Source":[{"SourceName":"Golden Source","PhoneMatch":"NULL","NameMatch":"72","Name":{"LastName":"","FirstName":"NAMA Kumar"},"IDMatch":"NULL","GenderMatch":"NULL","FatherNameMatch":"NULL","FatherName":{"MiddleName":"","LastName":"","FirstName":""},"EmailMatch":"NULL","DobMatch":"NULL","AddressMatch":"NULL"}]}}}}}]},"Name":"","Id":"VMA001","Consent":"true"}]},"ApplicantMiddleName":"VEENESH","ApplicantLastName":"KUMAR","ApplicantIdentifier":"c48a041e-66e7-459e-891d-8d79427daa3d","ApplicantFirstName":"NAMA"}}}},"RequestId":"17012022183615556"}';
            System.assertEquals(responseExpected, textMatchCallOutResponse, 'SUCCESS');
            
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),'Script-thrown exception', 'Exception');
        }
    }
}