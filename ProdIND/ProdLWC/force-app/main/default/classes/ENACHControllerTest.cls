@isTest 
public class ENACHControllerTest {
    @testSetup 
    static void testDataSetup() 
    {
        
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey = 'en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey = 'America/Los_Angeles',UserName='test_userprod123enach@indusbank.com',MobilePhone = '9089078967');
        insert u;
        System.runAs(u) 
        {
            
            // Create Opportunity
            Opportunity opp = new Opportunity();
            opp.StageName = 'Qualification';
            opp.CloseDate = Date.newInstance(2021, 1, 11);
            opp.Name = 'testone';
            insert opp;
                        Applicant__c appli = new Applicant__c();
			appli.Name = 'testApplicant';
			appli.Opportunity__c = opp.Id ;
			insert appli ;
            //Create Retry_Count__c records
            List<Retry_Count__c> rtCountList = new List<Retry_Count__c>();
            Retry_Count__c retryCount = new Retry_Count__c();
            retryCount.Service_Name__c = 'Retry_Count';
            retryCount.Count__c = 1;
            retryCount.Loan_Application_Id__c = opp.Id;
            rtCountList.add(retryCount);
            insert rtCountList;
            
            // Create Low_Payload_Response__e
            Low_Payload_Response__e lPay = new Low_Payload_Response__e();
            lPay.Reference_Id__c = '5676535245';
            lPay.SVC_Name__c = 'Document Report';
            lPay.Response__c='34567890';
            lPay.Reference_Id__c = opp.Id;
            
            // Create Loan_Application_Transaction_History__c
            List<Loan_Application_Transaction_History__c> laptHistList = new List<Loan_Application_Transaction_History__c>();
            Loan_Application_Transaction_History__c lth4 = new Loan_Application_Transaction_History__c();
            lth4.Submitted_Flag__c = false;
            lth4.Name = 'Repayment Mandate';
            laptHistList.add(lth4);
            insert laptHistList;
            
            Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
            dlNumberSetting.Name = System.Label.TwoWheeler;
            dlNumberSetting.MDNField1__c ='AB';
            dlNumberSetting.MDNField2__c = 2.0;
            insert dlNumberSetting;
            
            Deal_Number__c dl=new Deal_Number__c();
            dl.Loan_Application__c = opp.Id;
            dl.DNField1__c = dlNumberSetting.MDNField1__c;
            dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c.round());
            dl.Sub_Stage__c = 'RC Upload'; 
            insert dl;
            
            Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
            vgd1.Loan_Application__c = opp.Id;
            vgd1.Base_Price__c = 100000.00;
            vgd1.Ben_Code__c = 'testveh';
            vgd1.Deal_Number__c=dl.Id;
            insert vgd1;
            
            
            
            // Create Repayments__c
            Repayments__c repayment = new Repayments__c(Repayment_to_be_done_by__c='ABC', IFSC_Code__c='HDFC0000001',
                                                        Account_Number__c='342342344567644', 
                                                        Created_Date__c=Date.newInstance(2022, 02, 08 ),
                                                        End_Date__c=Date.newInstance(2030, 02, 08 ), Frequency__c='As Presented',Is_Netbanking_available_with_customer__c='yes',
                                                        EMI_Amount__c=4566, Loan_Application__c=opp.Id, Repayment_Method__c='N');
            insert repayment;
                    }
    }
    
    @isTest 
    public static void checkRetryExhaustedTest(){
        try
        {     
            
            Test.startTest();
            
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123enach@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u){ 
                Id loanApplicationId;
                Opportunity oppObject = [SELECT id from Opportunity LIMIT 1];
                Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
                dlNumberSetting.Name = System.Label.TwoWheeler;
                dlNumberSetting.MDNField1__c ='AB';
                dlNumberSetting.MDNField2__c = 2.0;
                insert dlNumberSetting;
                
                Deal_Number__c dl=new Deal_Number__c();
                dl.Loan_Application__c = oppObject.Id;
                dl.DNField1__c = dlNumberSetting.MDNField1__c;
                dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c.round());
                dl.Sub_Stage__c = 'RC Upload'; 
                insert dl;
                
                Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
                vgd1.Loan_Application__c = oppObject.Id;
                vgd1.Base_Price__c = 100000.00;
                vgd1.Ben_Code__c = 'testveh';
                vgd1.Deal_Number__c=dl.Id;
                insert vgd1;
                loanApplicationId =  oppObject.id;
                Retry_Count__c retryCount = new Retry_Count__c();
                retryCount.Service_Name__c = 'Retry_Count';
                retryCount.Count__c = 8;
                retryCount.Vehicle_Detail__c=vgd1.Id;
                retryCount.Loan_Application_Id__c = oppObject.Id;
                                //rtCountList.add(retryCount);
                insert retryCount;
                Retry_Count__c retryCount1 = [SELECT Id, Count__c,Service_Name__c FROM Retry_Count__c WHERE Loan_Application_Id__c = :oppObject.id AND Service_Name__c = :retryCount.Service_Name__c LIMIT 1];
                
                System_Constant_custom_metadata__mdt metadata = System_Constant_custom_metadata__mdt.getInstance(retryCount1.Service_Name__c);
                System.debug('Ccount'+metadata.Number_Of_Attempts__c);
                ENACHController.checkRetryExhausted(oppObject.Id, 'Retry_Count',vgd1.Deal_Number__c);
                //rc.Count__c=4;
                //update rc;
                ENACHController.checkRetryExhausted(oppObject.Id, 'Retry_Count',vgd1.Deal_Number__c);
                //system.assertEquals(4, rc.Count__c);
            }
            
            Test.stopTest();
        }
        catch(Exception e)
        {
            String Error  = e.getMessage();
            //System.assertEquals('Script-thrown exception', e.getMessage());
        }  
    }
    ////
    
    
    @isTest 
    static void testCheckRetryExhausted() {
        // Create test data for Retry_Count__c
        Opportunity oppObj = [SELECT id from Opportunity LIMIT 1];
        
        Retry_Count__c testRetryCount = new Retry_Count__c(
            Loan_Application_Id__c = oppObj.Id,
            Service_Name__c = 'testServiceName',
            User_Id__c = UserInfo.getUserId(),
            Count__c = 10 // Set this to a value to test different scenarios
        );
        insert testRetryCount;
        
        
          System_Constant_custom_metadata__mdt metadata = [Select Id,Number_Of_Attempts__c from System_Constant_custom_metadata__mdt where label='ENACH Sms Retry Limit'];
        System.debug('Retry Count===>'+testRetryCount.Count__c);
        System.debug('Count===>'+metadata.Number_Of_Attempts__c);
        
        Test.startTest();
        // Call the method under test
        Boolean isRetryExhausted = ENACHController.checkRetryExhausted(oppObj.Id, 'testServiceName', 'testDealId');
        Test.stopTest();
        
        // Assert the results
        // In this example, since Count__c is 10 and Number_Of_Attempts__c is 5, we expect it to be true
        System.assertEquals(false, isRetryExhausted, 'The retry exhausted check did not return the expected result.');
    }
    
   @isTest
   public static void enachJournyStatusHistoryTest(){
    Opportunity oppObjEnach = [SELECT id from Opportunity LIMIT 1];
    Integration_Log__c EnachIntlog = new Integration_Log__c(
        Loan_Application__c = oppObjEnach.Id,
        Service_Name__c = 'ENACH Registration Status',
        Original_response__c = 'Json Data'
        //Count__c = 10 // Set this to a value to test different scenarios
    );
    insert EnachIntlog;
    Test.startTest();
    ENACHController.enachJournyStatusHistory(oppObjEnach.Id);
    Test.stopTest();
   }

@isTest 
public static void retryCountIncreaseTest(){
    try
    {
        Test.startTest();
        
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123enach@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity oppo=[select id, StageName, CloseDate, Name from Opportunity];
            
            Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
            dlNumberSetting.Name = System.Label.TwoWheeler;
            dlNumberSetting.MDNField1__c ='AB';
            dlNumberSetting.MDNField2__c = 2.0;
            insert dlNumberSetting;
            
            Deal_Number__c dl=new Deal_Number__c();
            dl.Loan_Application__c = oppo.Id;
            dl.DNField1__c = dlNumberSetting.MDNField1__c;
            dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c.round());
            dl.Sub_Stage__c = 'RC Upload'; 
            insert dl;
            
            Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
            vgd1.Loan_Application__c = oppo.Id;
            vgd1.Base_Price__c = 100000.00;
            vgd1.Ben_Code__c = 'testveh';
            vgd1.Deal_Number__c=dl.Id;
            insert vgd1;
            
            //List<Retry_Count__c> rtCountList = new List<Retry_Count__c>();
            Retry_Count__c retryCount = new Retry_Count__c();
            retryCount.Service_Name__c = 'Retry_Count';
            retryCount.Count__c = 1;
            retryCount.Vehicle_Detail__c=vgd1.Id;
            retryCount.Loan_Application_Id__c = oppo.Id;
                        //rtCountList.add(retryCount);
            insert retryCount;
            
            ENACHController.retryCountIncrease(oppo.id, retryCount.Service_Name__c,retryCount.Vehicle_Detail__r.Deal_Number__c);
            Retry_Count__c retryCount1 = [SELECT Id, Count__c FROM Retry_Count__c WHERE Loan_Application_Id__c = :oppo.id AND Service_Name__c = :retryCount.Service_Name__c LIMIT 1];
            ENACHController.retryCountIncrease(oppo.id, 'serviceName',null);
            retryCount.Count__c = 4;
            update retryCount;
            ENACHController.retryCountIncrease(oppo.id, 'serviceName','');
            system.assertEquals(2, retryCount.Count__c);
        }
        Test.stopTest();
    }
    catch(Exception e)
    {
        String Error  = e.getMessage();
        //System.assertEquals('Script-thrown exception', Error);            
    } 
}
@isTest 
public static void eNachEventHandlerTest1(){
    try
    {
        Test.startTest();
        
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123enach@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            list<Opportunity> each = [SELECT Id, Name, CloseDate, StageName, Loan_Application_Number__c, (SELECT Id,Repayment_Method__c FROM Repayments__r WHERE Repayment_Method__c ='N' LIMIT 1) FROM Opportunity  LIMIT 1];
            List<Low_Payload_Response__e> lprList1 = new List<Low_Payload_Response__e>();
            Low_Payload_Response__e lPay = new Low_Payload_Response__e(Reference_Id__c=each[0].Id);
            lPay.Response__c = '{"JData":"0csl54DkldGHh0Ee0CKaxRlIsY4u5zvzFi81TzOET5OkCVZTxHW+jrnywex1nvWcKYNPwZG5Ratcp/aF+XMqg4QskWS6YrTCyhYxWU6RlV8NpPMR3EWqTpYOM7/ffBh8pSV1Hibj79wVYRAmvKD/ryTfdpHSWkFkWFAULv9lPFGrLzych8sfaH+lRF5namuj"}';
            lpay.SVC_Name__c = 'ENACH Registration Status';
            lprList1.add(lpay);
            
            ENACHController.eNachEventHandler(lprList1);
            system.assertEquals('ENACH Registration Status',lpay.SVC_Name__c);
        }
        
        Test.stopTest();
    }
    catch(Exception e)
    {
        System.debug('error'+e.getMessage());
    } 
}

@isTest 
public static void eNachEventHandlerTest2(){
    try
    {
        Test.startTest();
        
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123enach@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            // Create Opportunity
                Opportunity opp1 = new Opportunity();
                opp1.StageName = 'Qualification1';
                opp1.CloseDate = Date.newInstance(2021, 1, 11);
                opp1.Name = 'testone1';
                insert opp1;
                Applicant__c appli1 = new Applicant__c();
                appli1.Name = 'testApplicant1';
                appli1.Opportunity__c = opp1.Id ;
                insert appli1 ;
                //Create Retry_Count__c records
                List<Retry_Count__c> rtCountList1 = new List<Retry_Count__c>();
                Retry_Count__c retryCount1 = new Retry_Count__c();
                retryCount1.Service_Name__c = 'SIStatus';
                retryCount1.Count__c = 1;
                retryCount1.Loan_Application_Id__c = opp1.Id;
                rtCountList1.add(retryCount1);
                insert rtCountList1;
                
                // Create Low_Payload_Response__e
                Low_Payload_Response__e lPay1 = new Low_Payload_Response__e();
                lPay1.Reference_Id__c = '5676535247';
                lPay1.SVC_Name__c = 'Document Report';
                lPay1.Response__c='34567890';
                lPay1.Reference_Id__c = opp1.Id;
                
                // Create Loan_Application_Transaction_History__c
                List<Loan_Application_Transaction_History__c> laptHistList1 = new List<Loan_Application_Transaction_History__c>();
                Loan_Application_Transaction_History__c lth5 = new Loan_Application_Transaction_History__c();
                lth5.Submitted_Flag__c = false;
                lth5.Name = 'Repayment Mandate';
                laptHistList1.add(lth5);
                insert laptHistList1;
                
                Deal_Number_Setting__c dlNumberSetting1= new Deal_Number_Setting__c();
                dlNumberSetting1.Name = System.Label.TwoWheeler;
                dlNumberSetting1.MDNField1__c ='AB';
                dlNumberSetting1.MDNField2__c = 2.0;
                insert dlNumberSetting1;
                
                Deal_Number__c dl1=new Deal_Number__c();
                dl1.Loan_Application__c = opp1.Id;
                dl1.DNField1__c = dlNumberSetting1.MDNField1__c;
                dl1.DNField2__c = String.valueOf(dlNumberSetting1.MDNField2__c.round());
                dl1.Sub_Stage__c = 'RC Upload'; 
                insert dl1;
                
                Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
                vgd1.Loan_Application__c = opp1.Id;
                vgd1.Base_Price__c = 100000.00;
                vgd1.Ben_Code__c = 'testveh';
                vgd1.Deal_Number__c=dl1.Id;
                insert vgd1;
                
                
                
                // Create Repayments__c
               Repayments__c repayment1 = new Repayments__c(Repayment_to_be_done_by__c='ABC', IFSC_Code__c='HDFC0000001',
                                                            Account_Number__c='342342344567644', 
                                                            Created_Date__c=Date.newInstance(2022, 02, 08 ),
                                                            End_Date__c=Date.newInstance(2030, 02, 08 ), Frequency__c='As Presented',Is_Netbanking_available_with_customer__c='yes',
                                                            EMI_Amount__c=4566, Loan_Application__c=opp1.Id, Repayment_Method__c='I');
                insert repayment1;

            list<Opportunity> each = [SELECT Id, Name, CloseDate, StageName, Loan_Application_Number__c, (SELECT Id,Repayment_Method__c FROM Repayments__r WHERE Repayment_Method__c ='I' LIMIT 1 ) FROM Opportunity WHERE Id =:opp1.Id  LIMIT 1];
            List<Low_Payload_Response__e> lprList1 = new List<Low_Payload_Response__e>();
            Low_Payload_Response__e lPay = new Low_Payload_Response__e(Reference_Id__c=each[0].Id);
            lPay.Response__c = '{"JData":"f3U2xrqk3erkhq1xxOr+S8/57VD7sQmb49TNN+RvxQZ6Aundr1zSv6p381eT+1JED+5V5DC8Qi6aecRRomH0P9BKIua7ZgSpK5sh5O6DJrgBDBqKT5skkSI4KdqbAZpYutjX2cbzlKwtQKJnhgX0Wqzd2cVNKu6U+kBLQJCCF9l4MjZc3YWPsDmq+JgyxN7n"}';
            lpay.SVC_Name__c = 'SIStatus';
            lprList1.add(lpay);
            
            ENACHController.eNachEventHandler(lprList1);
            system.assertEquals('SIStatus',lpay.SVC_Name__c);
        }
        
        Test.stopTest();
    }
    catch(Exception e)
    {
        System.debug('error'+e.getMessage());
    } 
}

/*@isTest 
public static void eNachEventHandlerTestSI2(){
    try
    {
        Test.startTest();
        
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123enach@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            list<Opportunity> each = [SELECT Id, Name, CloseDate, StageName, Loan_Application_Number__c, (SELECT Id FROM Repayments__r LIMIT 1) FROM Opportunity  LIMIT 1];
            List<Low_Payload_Response__e> lprList1 = new List<Low_Payload_Response__e>();
            Low_Payload_Response__e lPay2 = new Low_Payload_Response__e(Reference_Id__c=each[0].Id);
            lPay2.Response__c = '{"JData":"ylOEeUv4IFCU9y4ZmCJtu88UaLndXK98brbc4DfV+8ZsMD3aRhQ/h0dNgAXd9TTkzpU2kD0C6vMX54/teGPjPg9RNecVaTGPvcKd5CXavaApbaaRs1MHCUEzJip4nTSz2LUDXdfqSMhelJDYmfqdBA=="}';
            lpay2.SVC_Name__c = 'SIStatus';
            lprList1.add(lpay2);
            ENACHController.eNachEventHandler(lprList1);
        }
        
        Test.stopTest();
    }
    catch(Exception e)
    {
        System.debug('error'+e.getMessage());
    } 
}
*/
@isTest 
public static void submitENACHTest(){
    try
    {
        
        Test.startTest();
        
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123enach@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Id loanApplicationId;
            Opportunity oppObject = [SELECT id from Opportunity LIMIT 1];
            loanApplicationId =  oppObject.id;
            Loan_Application_Transaction_History__c lth = new Loan_Application_Transaction_History__c();
            lth.Submitted_Flag__c = false;
            lth.Name = 'Repayment Mandate';
            lth.Loan_Application_ID__c = loanApplicationId;
            insert lth;
            Loan_Application_Transaction_History__c loanAppTranHis = [SELECT Id, Name FROM Loan_Application_Transaction_History__c  WHERE  Loan_Application_ID__c = :loanApplicationId AND Name = 'Repayment Mandate' LIMIT 1];
            ENACHController.submitENACH(loanApplicationId);
            system.assertEquals(false,lth.Submitted_Flag__c);
        }
        
        Test.stopTest();
    }
    catch(Exception e)
    {
        //System.assertEquals('Script-thrown exception', e.getMessage());
    } 
}


@isTest 
public static void getRepaymentIdTest(){
    try
    {
        Test.startTest();
        
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123enach@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            list<Opportunity> each = [SELECT Id, Name, CloseDate, StageName, Loan_Application_Number__c, (SELECT Id FROM Repayments__r LIMIT 1) FROM Opportunity  LIMIT 1];
            List<Low_Payload_Response__e> lowList = new List<Low_Payload_Response__e>();
            lowList.add(new Low_Payload_Response__e(Reference_Id__c = each[0].Loan_Application_Number__c));
            Set<String> loanAppNum = new Set<String>();
            loanAppNum.add(lowList[0].Reference_Id__c);
            ENACHController.getRepaymentId(lowList);
            // system.assert(!ass.isEmpty());
        }
        
        Test.stopTest();
    }
    
    catch(Exception e)
    {
        // System.assertEquals('Script-thrown exception', e.getMessage());
    } 
}

@isTest    
public static void eNachEventHandlerTest3(){    
    try 
    {   
        Test.startTest();   
        
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123enach@indusbank.com' AND IsActive = true LIMIT 1];   
        System.runAs(u)     
        {   
            list<Opportunity> each = [SELECT Id, Name, CloseDate, StageName, Loan_Application_Number__c, (SELECT Id FROM Repayments__r LIMIT 1) FROM Opportunity  LIMIT 1]; 
            List<Low_Payload_Response__e> lprList1 = new List<Low_Payload_Response__e>();   
            Low_Payload_Response__e lPay = new Low_Payload_Response__e(Reference_Id__c=each[0].Id); 
            lPay.Response__c = '{"JData":"ylOEeUv4IFCU9y4ZmCJtu59+t81FP8Lcup1y9DMSz56M4i28kvgsdBbG0nIcSkQYQ0C3e15dn3QbULhnA2ggWuyARhW9AEmjDzkPENKBEiuycHQCGBr/8NPkpV+GPA4idYR3rvI2kCCvMxzu9k/bcd99yznKV/9hmh9+FT1cGts="}';  
            lpay.SVC_Name__c = 'ENACH Registration Status'; 
            lprList1.add(lpay); 
            ENACHController.eNachEventHandler(lprList1);
            //system.assertEquals('ENACH Registration Status',lpay.SVC_Name__c);  
        }   
        
        Test.stopTest();    
    }   
    catch(Exception e)  
    {   
        System.debug('error'+e.getMessage());   
    }   
}

@isTest     
public static void eNachEventHandlerTest4(){    
    try 
    {   
        Test.startTest();   
        
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123enach@indusbank.com' AND IsActive = true LIMIT 1];   
        System.runAs(u)     
        {   
            list<Opportunity> each = [SELECT Id, Name, CloseDate, StageName, Loan_Application_Number__c, (SELECT Id FROM Repayments__r LIMIT 1) FROM Opportunity  LIMIT 1]; 
            List<Low_Payload_Response__e> lprList1 = new List<Low_Payload_Response__e>();   
            Low_Payload_Response__e lPay = new Low_Payload_Response__e(Reference_Id__c=each[0].Id); 
            lPay.Response__c = '{"JData":"ylOEeUv4IFCU9y4ZmCJtu59+t81FP8Lcup1y9DMSz56M4i28kvgsdBbG0nIcSkQYQ0C3e15dn3QbULhnA2ggWuyARhW9AEmjDzkPENKBEiuycHQCGBr/8NPkpV+GPA4idYR3rvI2kCCvMxzu9k/bceS5LexabacjUhcPpgeySwE="}';  
            lpay.SVC_Name__c = 'ENACH Registration Status'; 
            lprList1.add(lpay); 
            ENACHController.eNachEventHandler(lprList1);
            //system.assertEquals('ENACH Registration Status',lpay.SVC_Name__c);  
        }   
        
        Test.stopTest();    
    }   
    catch(Exception e)  
    {   
        System.debug('error'+e.getMessage());   
    }   
}

@isTest 
public static void retryCountIncreaseTest1(){
    try
    {
        Test.startTest();
        
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123enach@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Retry_Count__c rc = [select id,Service_Name__c FROM Retry_Count__c LIMIT 1];
            Opportunity oppo=[select id, StageName, CloseDate, Name from Opportunity];
            Vehicle_Detail__c vehicleDetailObj=[Select Id,Deal_Number__c from Vehicle_Detail__c Limit 1];
            ENACHController.retryCountIncrease(oppo.id, rc.Service_Name__c,vehicleDetailObj.Deal_Number__c);
            Retry_Count__c retryCount = [SELECT Id, Count__c,Vehicle_Detail__c,Vehicle_Detail__r.Deal_Number__c FROM Retry_Count__c WHERE Loan_Application_Id__c = :oppo.id AND Service_Name__c = :rc.Service_Name__c AND Vehicle_Detail__r.Deal_Number__c =: vehicleDetailObj.Deal_Number__c LIMIT 1];
            System_Constant_custom_metadata__mdt metadata = System_Constant_custom_metadata__mdt.getInstance(rc.Service_Name__c);
            ENACHController.retryCountIncrease(oppo.id, 'serviceName',retryCount.Vehicle_Detail__r.Deal_Number__c);
            retryCount.Count__c = 4;
            update retryCount;
            ENACHController.retryCountIncrease(oppo.id, 'serviceName',retryCount.Vehicle_Detail__r.Deal_Number__c);
            system.assertEquals(2, retryCount.Count__c);
        }
        Test.stopTest();
    }
    catch(Exception e)
    {
        String Error  = e.getMessage();
        //System.assertEquals('Script-thrown exception', Error);            
    } 
}

@isTest 
public static void testENACHEventHandler() {
    // Create test data for Low_Payload_Response__e records
    List<Low_Payload_Response__e> testPayloadList = new List<Low_Payload_Response__e>();
    Low_Payload_Response__e testPayload = new Low_Payload_Response__e();
    testPayload.Reference_Id__c = 'TestReferenceId'; // Placeholder value for Reference Id
    testPayload.SVC_Name__c = 'ENACH Registration Status'; // Example value for SVC Name
    testPayload.Response__c = '{"JData":"TestResponseData"}'; // Example value for Response
    // Add testPayload to the list
    testPayloadList.add(testPayload);
    
    // Call the method under test
    Test.startTest();
    ENACHController.eNachEventHandler(testPayloadList);
    Test.stopTest();
    
    // Perform assertions
    // Example assertions based on expected behavior
    // Verify that certain updates were made or not made
    // Assert.assertEquals(expectedValue, actualValue, errorMessage);
}

/*@isTest 
public static void testENACHEventHandlerNew() {
	List<Opportunity> oppList=[Select Id,name,(SELECT Id,Deal_Number__c FROM Repayments__r LIMIT 1)  from Opportunity Limit 1];

    // Create test data for Low_Payload_Response__e records
    List<Low_Payload_Response__e> testPayloadList = new List<Low_Payload_Response__e>();
    
	String strRef = oppList[0].Id ;
    Low_Payload_Response__e testPayloadN = new Low_Payload_Response__e();
    testPayloadN.Reference_Id__c = strRef+'-Test' ; // Placeholder value for Reference Id
    testPayloadN.SVC_Name__c = 'SIStatus'; // Example value for SVC Name
    testPayloadN.Response__c = '{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ngW4uvrFnbNNR39RrFHeB3tBI8nYCv7nh9vS/jESy5SxCB63C1H7HEcaLsbQJrPx7IHI/NK+cJu+HR6IO8nn+vs+xsfKMEOq37UmPNMgXfwq/heqbvhTYGypJ1Wur7rmsRWcywoKLq/Z/MK7aU5uSLpS30Sb96mMTje5Arwr1RvAIjgBIomF4t8xQ6hP8gVbrA="}'; // Example value for Response
    testPayloadList.add(testPayloadN);
    
    // Call the method under test
    Test.startTest();
    ENACHController.eNachEventHandler(testPayloadList);
    Test.stopTest();
    
    // Perform assertions
    // Example assertions based on expected behavior
    // Verify that certain updates were made or not made
    // Assert.assertEquals(expectedValue, actualValue, errorMessage);
}
    
@isTest 
public static void testENACHEventHandlerNew1() {
	List<Opportunity> oppList=[Select Id,name,(SELECT Id,Deal_Number__c FROM Repayments__r LIMIT 1)  from Opportunity Limit 1];
	// Create test data for Low_Payload_Response__e records
    List<Low_Payload_Response__e> testPayloadList = new List<Low_Payload_Response__e>();
    Low_Payload_Response__e testPayload = new Low_Payload_Response__e();
	String strRef = oppList[0].Id ;
    testPayload.Reference_Id__c = strRef+'-Test' ; // Placeholder value for Reference Id
    testPayload.SVC_Name__c = 'ENACH Registration Status'; // Example value for SVC Name
    testPayload.Response__c = '{"JData":"6GecuhPLaTcF1+oci47iBvva9ciB4AjJnX0yiX0iqxmbhJ162ObM2T2qmHFWuFecNYn5YILBQy1IFV2F49V0lyIL0hsh3jXbJhiCEXs+KOemXPWvV2A84DvjyZ1WokTky7v+0tO4iXkt5jcvRVSQIGPCi6gTequOt+1Sxba4seMeN9Kk8m8nZEsP6kvYRLph6O8B27WnWo2i4yjZmymmgMPBUX2i9zevI9yNJYgFKLS4quMAghen+Xl1JNLODpleUkgP5UvzQFFoTz8BqqKPtQ=="}'; // Example value for Response
    testPayloadList.add(testPayload);    
    // Call the method under test
    Test.startTest();
    ENACHController.eNachEventHandler(testPayloadList);
    Test.stopTest();
    
    // Perform assertions
    // Example assertions based on expected behavior
    // Verify that certain updates were made or not made
    // Assert.assertEquals(expectedValue, actualValue, errorMessage);
}

@isTest 
public static void testENACHEventHandlerNew2() {
	List<Opportunity> oppList=[Select Id,name,(SELECT Id,Deal_Number__c FROM Repayments__r LIMIT 1)  from Opportunity Limit 1];

    // Create test data for Low_Payload_Response__e records
    List<Low_Payload_Response__e> testPayloadList = new List<Low_Payload_Response__e>();
    
	String strRef = oppList[0].Id ;
    Low_Payload_Response__e testPayload2 = new Low_Payload_Response__e();
    testPayload2.Reference_Id__c = strRef+'-Test' ; // Placeholder value for Reference Id
    testPayload2.SVC_Name__c = 'SIStatus'; // Example value for SVC Name
    testPayload2.Response__c = '{"JData":"bmvHXB5/b59ltoDPA8dwPO76mbIIRh7pyG7RWowIbHPjOfwvy5ofT+tiiWVxukOFtb4/WuCwQ0i41sj10uWikyHxuk5p5Dn0RyfrWeexr3SNML+FnSnt+gHC+QauJtJitRSjSX+cCRFO4GrP4Ib9d6fZ5ZcdSKLhLWSPHccQvmBWJlQAFGxCPI/ixsjCg32k5eG4fRIchd5bp8Ywuox4Hw=="}'; // Example value for Response
    testPayloadList.add(testPayload2);
    
    //testPayloadList.add(testPayloadN);

    
    // Call the method under test
    Test.startTest();
    ENACHController.eNachEventHandler(testPayloadList);
    Test.stopTest();
}
@isTest 
public static void testENACHEventHandlerNew3() {
	List<Opportunity> oppList=[Select Id,name,(SELECT Id,Deal_Number__c FROM Repayments__r LIMIT 1)  from Opportunity Limit 1];

    // Create test data for Low_Payload_Response__e records
    List<Low_Payload_Response__e> testPayloadList = new List<Low_Payload_Response__e>();
    
	String strRef = oppList[0].Id ;
    Low_Payload_Response__e testPayload2 = new Low_Payload_Response__e();
    testPayload2.Reference_Id__c = strRef+'-Test' ; // Placeholder value for Reference Id
    testPayload2.SVC_Name__c = 'GetCRIFReport'; // Example value for SVC Name
    System.debug('@@@@@ label name  >>'+System.Label.GetCRIFReport);
	System.debug('@@@@@ testPayload2.SVC_Name__c'+testPayload2.SVC_Name__c);
    testPayload2.Response__c = '{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5nhbsSGnEOy7Ai5TEbBgZ3uJ54wvjUHpk2lskoOqH0f739CEfxfBNdgezTzrBwn0f+v0OlfGLLOGSmOC/qDikyUEvMpZtPfjFRqwr8bP9YQQ1ggNkXR568Fwpa7niw2vpq5g8X9SFj77aoO57Wt45WA8cPl0HVJGtMK5z8DR4NE6JD5PjVexMGlMyQV2Q9ge45cOngiA1V7BRIdp5o16zE2/s17an3knO1ThAG6bHzLbs+MupH4atHd4qVHvuvfo531LuMVG6rKEx3m4Sik9RCumWIvllaxdP2ooT60l00wGeh+LWkXet1vrKDYCQKzi9kc="}'; // Example value for Response
    testPayloadList.add(testPayload2);
    
    //testPayloadList.add(testPayloadN);

    
    // Call the method under test
    Test.startTest();
    ENACHController.eNachEventHandler(testPayloadList);
    Test.stopTest();
}*/
    
@isTest 
public static void testSubmitENACH() {
    Opportunity oppObj=[Select Id from Opportunity Limit 1];
    Loan_Application_Transaction_History__c testTransaction = new Loan_Application_Transaction_History__c();
    testTransaction.Name = System.Label.Repayment_Mandate; // Assuming this label exists
    testTransaction.Loan_Application_ID__c = oppObj.Id; // Placeholder value for Loan Application ID
    // Add more fields as needed for your test scenario
    insert testTransaction;
    
    // Call the method under test
    Test.startTest();
    ENACHController.submitENACH(testTransaction.Loan_Application_ID__c);
    Test.stopTest();
    
    // Perform assertions
    // Verify that the records were updated as expected
    testTransaction = [SELECT Id, Submitted_Flag__c FROM Loan_Application_Transaction_History__c WHERE Id = :testTransaction.Id];
    System.assertEquals(true, testTransaction.Submitted_Flag__c, 'Submitted_Flag__c should be true after method execution');
}

@isTest
public static void testCriffEventHandler() {
    // Create test data - Low_Payload_Response__e records
    List<Low_Payload_Response__e> testPayloadResponses = new List<Low_Payload_Response__e>();
    
    // Create instances of the Platform Event object
    Low_Payload_Response__e testPayload1 = new Low_Payload_Response__e(Reference_Id__c = 'TestApplicantId-1', SVC_Name__c = System.Label.GetCRIFReport, Response__c = '{"response": {"status": "SUCCESS", "content": [{"Isreportgenerated": "true", "Reporturl": "https://example.com/report"}]}}');
    Low_Payload_Response__e testPayload2 = new Low_Payload_Response__e(Reference_Id__c = 'TestApplicantId-2', SVC_Name__c = System.Label.GetCRIFReport, Response__c = '{"response": {"status": "SUCCESS", "content": [{"Isreportgenerated": "true", "Reporturl": "https://example.com/report"}]}}');
    // Add more test payloads as needed
    
    // Add test payloads to the list
    testPayloadResponses.add(testPayload1);
    testPayloadResponses.add(testPayload2);
    // Add more payloads to the list if needed
    
    // Call the method under test
    Test.startTest();
    ENACHController.criffEventHandler(testPayloadResponses);
    Test.stopTest();
    
    // Assert the changes in the database
    // Verify that the Applicant__c records are updated with the correct CRIFF_Report_URL__c values
    // Verify other relevant assertions based on the logic of criffEventHandler method
}

@isTest
public static void testCriffEventHandler1() {
    List<Opportunity> oppList=[Select Id,name,(SELECT Id,Deal_Number__c FROM Repayments__r LIMIT 1)  from Opportunity Limit 1];
	List<Applicant__c> appliList = [Select id,name,Opportunity__c from Applicant__c where Opportunity__c in: oppList ];
    System.debug('@@@@@ appliList>>'+appliList);
    // Create test data - Low_Payload_Response__e records
    List<Low_Payload_Response__e> testPayloadResponses = new List<Low_Payload_Response__e>();
    
    // Create instances of the Platform Event object
    Low_Payload_Response__e testPayload1 = new Low_Payload_Response__e(Reference_Id__c = appliList[0].Id+'-1', 
                                                                       SVC_Name__c = System.Label.GetCRIFReport, 
                                                                       Response__c = '{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5nhbsSGnEOy7Ai5TEbBgZ3uJ54wvjUHpk2lskoOqH0f739CEfxfBNdgezTzrBwn0f+v0OlfGLLOGSmOC/qDikyUEvMpZtPfjFRqwr8bP9YQQ1ggNkXR568Fwpa7niw2vpq5g8X9SFj77aoO57Wt45WA8cPl0HVJGtMK5z8DR4NE6JD5PjVexMGlMyQV2Q9ge45cOngiA1V7BRIdp5o16zE2/s17an3knO1ThAG6bHzLbs+MupH4atHd4qVHvuvfo531LuMVG6rKEx3m4Sik9RCumWIvllaxdP2ooT60l00wGeh+LWkXet1vrKDYCQKzi9kc="}');
    //Low_Payload_Response__e testPayload2 = new Low_Payload_Response__e(Reference_Id__c = 'TestApplicantId-2', SVC_Name__c = System.Label.GetCRIFReport, Response__c = '{"response": {"status": "SUCCESS", "content": [{"Isreportgenerated": "true", "Reporturl": "https://example.com/report"}]}}');
    // Add more test payloads as needed
    
    // Add test payloads to the list
    testPayloadResponses.add(testPayload1);
    //testPayloadResponses.add(testPayload2);
    // Add more payloads to the list if needed
    
    // Call the method under test
    Test.startTest();
    ENACHController.criffEventHandler(testPayloadResponses);
    Test.stopTest();
    
    // Assert the changes in the database
    // Verify that the Applicant__c records are updated with the correct CRIFF_Report_URL__c values
    // Verify other relevant assertions based on the logic of criffEventHandler method
}

@isTest
static void testENACHEndEventHandler1() {
    // Create test data - Low_Payload_Response__e records
    List<Low_Payload_Response__e> testPayloadResponses = new List<Low_Payload_Response__e>();
    
    // Create test payload for ENACH Registration Status - Success
    Low_Payload_Response__e enachStatusPayloadSuccess = new Low_Payload_Response__e(
        Reference_Id__c = 'TestLeadId-1', 
        SVC_Name__c = 'ENACH Registration Status', 
        Response__c = '{"npcistatus": "success", "message": "Success"}'
    );
    testPayloadResponses.add(enachStatusPayloadSuccess);
    
    // Create test payload for ENACH Registration Status - Failed
    Low_Payload_Response__e enachStatusPayloadFailed = new Low_Payload_Response__e(
        Reference_Id__c = 'TestLeadId-2', 
        SVC_Name__c = 'ENACH Registration Status', 
        Response__c = '{"error_code": "500", "message": "Failed"}'
    );
    testPayloadResponses.add(enachStatusPayloadFailed);
    
    // Create test payload for SIStatus - Success
    Low_Payload_Response__e siStatusPayloadSuccess = new Low_Payload_Response__e(
        Reference_Id__c = 'TestLeadId-3', 
        SVC_Name__c = 'SIStatus', 
        Response__c = '{"response": {"status": "SUCCESS"}}'
    );
    testPayloadResponses.add(siStatusPayloadSuccess);
    
    // Create test payload for SIStatus - Failed
    Low_Payload_Response__e siStatusPayloadFailed = new Low_Payload_Response__e(
        Reference_Id__c = 'TestLeadId-4', 
        SVC_Name__c = 'SIStatus', 
        Response__c = '{"response": {"status": "FAILED"}}'
    );
    testPayloadResponses.add(siStatusPayloadFailed);
    
    // Call the method under test
    Test.startTest();
    ENACHController.eNachEventHandler(testPayloadResponses);
    Test.stopTest();
    
    // Assert the changes in the database
    // Add your assertions here to verify that the expected changes are made to the database
    // For example, verify that Repayments__c records are updated with the correct status and messages
    // Verify other relevant assertions based on the logic of eNachEventHandler method
}

}