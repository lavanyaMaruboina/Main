@isTest
public class IND_PerfiosITROnlineRequestTest {
    @isTest
    public static void getPerfiosITROnlineRequestTest(){
        try{
            Test.startTest();
            RequestWrapper requestWrapper =  new RequestWrapper();
            requestWrapper.panNumber = '';
            requestWrapper.kycDOB = Date.today();
            requestWrapper.itrType = 'Type';
            requestWrapper.contactNumber = '1234567890';
            IND_PerfiosITROnlineRequest result = IND_PerfiosITROnlineService.getPerfiosITROnlineRequest(requestWrapper);
            Test.stopTest();
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Please enter the PAN No');
        }
    }
    
    @isTest
    public static void getPerfiosITROnlineRequestTest1(){
        try{
            Test.startTest();
            RequestWrapper requestWrapper1 =  new RequestWrapper();
            requestWrapper1.panNumber = 'ABCDE1234F';
            requestWrapper1.itrType = 'Type';
            requestWrapper1.contactNumber = '1234567890';
            IND_PerfiosITROnlineRequest result = IND_PerfiosITROnlineService.getPerfiosITROnlineRequest(requestWrapper1);
            Test.stopTest();
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Date Of Birth is required.');
        }
    }
    
    @isTest
    public static void getPerfiosITROnlineRequestTest2(){
        try{
            Test.startTest();
            RequestWrapper requestWrapper = new RequestWrapper();
            requestWrapper.panNumber = 'ABCDE1234F';
            requestWrapper.kycDOB = Date.today();
            requestWrapper.itrType = '';
            requestWrapper.dateOfBirth = '01-01-1996';
            requestWrapper.contactNumber = '1234567890';
            IND_PerfiosITROnlineRequest result = IND_PerfiosITROnlineService.getPerfiosITROnlineRequest(requestWrapper);
            Test.stopTest();
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Please provide type of ITR (ITRUpload/ITROnline)');
        }
    } 
    
    @isTest
    public static void getPerfiosITROnlineRequestTest3(){
        try{
            Test.startTest();
            RequestWrapper requestWrapper = new RequestWrapper();
            requestWrapper.panNumber = 'ABCDE1234F';
            requestWrapper.kycDOB = Date.today();
            requestWrapper.itrType = 'Type';
            requestWrapper.dateOfBirth = '01-01-1996';
            requestWrapper.contactNumber = '';
            IND_PerfiosITROnlineRequest result = IND_PerfiosITROnlineService.getPerfiosITROnlineRequest(requestWrapper);
            Test.stopTest();
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Please provide Mobile Number.');
        }
    } 
}