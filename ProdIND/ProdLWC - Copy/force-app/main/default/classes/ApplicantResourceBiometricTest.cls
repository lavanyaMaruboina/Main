@isTest
public class ApplicantResourceBiometricTest {
    
    @isTest
    public static void verifyApplicantResourceBiometricPIDBlock(){
        
        Opportunity opgr1 = new Opportunity();
        opgr1.StageName = 'Qualification';
        opgr1.CloseDate = Date.newInstance(2021, 1, 11);
        opgr1.Name = 'testone';
        insert opgr1;
        
        Applicant__c apgr1 = new Applicant__c();
        apgr1.Opportunity__c = opgr1.Id;
        apgr1.Contact_number__c = '9743514830';
        apgr1.Applicant_Type__c = 'Borrower';
        apgr1.PID_Block__c = '<PidData><Resp errCode="0" errInfo="Image Capture Success" fCount="1" fType="0" iCount="-1" iType="-1" pCount="-1" pType="-1" nmPoints="38" qScore="80"/><DeviceInfo dpId="PRECISION.PB" rdsId="PRECISION.AND.001" rdsVer="1.2.3" dc="d8507b94-6000-439c-a17a-ddb1f5688474" mi="PB510" mc="MIIEGDCCAwCgAwIBAgIIa66JYt9W00kwDQYJKoZIhvcNAQELBQAwgewxNzA1BgNVBAMTLkRTIFBSRUNJU0lPTiBCSU9NRVRSSUMgSU5ESUEgUFJJVkFURSBMSU1JVEVEIDMxJjAkBgNVBDMTHU5PIDIyIEhBQklCVUxMQUggUk9BRCBUIE5BR0FSMRAwDgYDVQQJEwdDSEVOTkFJMRIwEAYDVQQIEwlUQU1JTE5BRFUxIjAgBgNVBAsTGVNPTFVUSU9OIERFVkVMT1BNRU5UIFRFQU0xMjAwBgNVBAoTKVBSRUNJU0lPTiBCSU9NRVRSSUMgSU5ESUEgUFJJVkFURSBMSU1JVEVEMQswCQYDVQQGEwJJTjAeFw0yMjAxMTIxMzAwMTNaFw0yMjAyMTExMzAwMTNaMG4xMjAwBgNVBAoMKVByZWNpc2lvbiBCaW9tZXRyaWMgSW5kaWEgUHJpdmF0ZSBMaW1pdGVkMRIwEAYDVQQLDAlCaW9tZXRyaWMxEDAOBgNVBAcMB0NIRU5OQUkxEjAQBgNVBAMMCVByZWNpc2lvbjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMae3jniHAsBoDbNff7IB4oXO2SJXvbDGIcQPkruMahSPydVUmT9ZC8E4FQi/ZXc7dm4LOgKK48uLVWeWKInvRhhJKIbHf0eIVBimLI5KghFvLyd/hKx/7dc3KYN0Ntxi4uL3+1JX9tJk8vEBQUP3SsYo2bfUt59msHL10GhlzoyqzVbjfaOaVwta9oyp4RoeZQM3mJot6q4KB4GXQcMzv5yXFVqzWRMy1l789Yjdayq5CWI2f17x4/gvjV2hkNchPSrnsNgws155xEa7Gy+F9my3XTbmqmcHfRSMXMpbLqimeocz5FpDH51E2EgAKgT5BAr+y0pZlTgsRHRAcuwyHsCAwEAAaM7MDkwCQYDVR0TBAIwADALBgNVHQ8EBAMCAYYwHwYDVR0jBBgwFoAUtTWwpFcL+TBx63TcMhe9Ih9zKGcwDQYJKoZIhvcNAQELBQADggEBAFsUy4zSNVA5aREGPmgyb9p4u2EqlZ1PryDJAl4qFRXeX/lc+ox0JCvcQotmDjlVClaceEW30ND0mUHERWQGIpvz0d0dd25m5tl7blEvO78PpBw99hm1ZlXxbJgrdhRaejUjMC8F5exwnYW9P5pdLbCzqemqcwHZo0w4WjnIQSCFvVrL0Z787glz1TrMiC7R9bCG4KIRbDMEBpjkTNbj0FSOvkFhcviFAb+Z6pRkOw08Lp0kufpwSvdSjSagY5uWSnpt9ZejVXNVGnUzscA9fn60fCUn3RrOgslZwjodhJAFaefMi2Ajb5MabLLn9zn8IbT3f+wzluoMfvLgqCy406c="><additional_info><Param name="srno" value="EAC9026AZRFE41912380"/><Param name="sysid" value=""/><Param name="ts" value="2022-01-21T15:21:53+05:30"/><Param name="Locking" value="N"/></additional_info></DeviceInfo><Skey ci="20221021">jzbRJ9XC5R1TfOOyTfi86eoCvVcDnA/GL6JFQf1eeJlqD1zd4uIglDOveCKyxDbj5DbQQJb5D8xqlmnVYzXzwoN+d6gvRtrMYe+4qS4ha3ol18JYPwA7gVLdVQjMY6wAWlkJbrDOFnP4Pqd70oF8n1jfzmiKeBHjWdAzvJ+BS1yeyq3ZAZBUrEuiAj8bUPp+6lr6NbeGW/lllVp2wMvdI8rpFPwHY+N2MH4SElAtO3IITlJoMjMAbigi6ZvYXdTwfb85n+j6VB/Yd6K5t8vT89sFnt5qzxoSuGXEfpRhRUIclBGHzeeIjN1TCq00WzuiYNdk9zrzC0wTIm5XynarbA==</Skey><Hmac>Wwua3H0Tjt0kgZnsLn4yKcRmP7Qc57FL73/bdf4SmeLl9mXwlf9xF3k/QZfMePWl</Hmac><Data type="X">MjAyMi0wMS0yMVQxNToyMTo1M2p24RH84QXOfo/jCuCpr2ku4+pm0YelX8dEIHzVrZVlWG8PbGZCu8WBlcJ5hhng66JMqrepFXNW4b9ajXE/tgJ9l/0LWfHMNAze7PV8+DOpM6QLVTKZ4KCIB3vyT2MTdrPhCOiZAZhh2IfGzJfYnfMkvj6LKh6P7IzcobQ3EqDCSwSHCmYAQMQuEj6JRNakdO3UZ34OIZzW9dw7s57SgedYrORWGbpOjxjxR6+FcnzWt8DXMyW4nolB6Ad/KolJQbqXabh98yzbdgdBlX66177CsYtnNxgsbpYjBH3LBhqnWTpKRI+RFGOtq1cJ4XJzrsOjPGlXl2BCeLIfeMApRkbpnTCMskzRUCd9ZwcVmXpO9yQxx2ft4IAzEwaad4J9OcDAOMFwDtXrUUEGlf3LyBsRqsP9cvnElWoTttwfnDZEjFvvmixmvogIzqlcCwqspApDxusvR/R5eidzygePLyPGUC736vwI/XjpI+fixcpzXvAUUUxZjU43SHP/c63w1UAPF2QhOgYlBbTdWUW1RExGbdzk6m/2rTMJ29OWtqv3SFECQK1xruGSguNDf2+CJAMDKwzZ5M2lixFZjkbWUM9b/KOPPRvNOUyp5KJr7MOJm/xZYFo+9kVU+5mnBgafzI/l+4K/GSQEHxcqRtQxq56X2pQauHUj4h07/25uVaLPukEUj/ACJQ57DEdVcxSzw2kfj+ym/Ymf3Dywkb3/ZONtfv6aNdGLKFa/qDmlxTwk7ZCKediYySQDGJT+YOSO44AS6oVtks6S4FAknVMuIq59NbDNw7NMjG7qUZmgJPFh8FzjkmNAOzi8U3auJ9tY/K2PFEYm1eC2uI7CMSpqC0QcyBe24fQQfB8sdZGA6BzueC9DjZZtfDjgyNtyvgbRbAD7/vLjxBrcpsMeIiHkb+BB5E4l52OpLi02epQRcYn7wrkHNnYYG02Q2bIb3t4YIZTsZjYLHtew9Ps1Land1NLi9nyFUcbvsf0ugGLonfRCQ9PnSVjptvUYz2lq0SpTNQ26yMs2u6+ICh7SZCse4f8jjEqXpXEByrnhNVm4hTrzu1yer+0pSeqgv95JFM2xXcZpov8eTtLYpGC3IM7ICNyI7+OUCztWnmg1lFi6CArIRpFGYbGuHVsA5Xth/ZPC1VvjCtsAzGYvxifK6ejxRZCREhwPzQsb9Rw3wxPD4ITBhdy1G1KDbXkF3wuIRGbYxFt504cDBWnCMcMQWFvilOedI/p7apQbJuPfS0JULfkzxaur8dG4f7p8NgRhrO5ZkL1kSuDHkURFf1NskH2JJZBuCQ==</Data></PidData>';
        insert apgr1;
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        
        req.requestURI = '/services/apexrest/ApplicantBiometricAPI/' + apgr1.Id;
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf(JSON.serialize(apgr1));
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        ApplicantResourceBiometric arb=new ApplicantResourceBiometric();
        ApplicantResourceBiometric.updateApplicant();
        System.debug('res ==>'+res);
        Test.stopTest();
        System.assertEquals(res.statusCode, 200);
        
    }
    
    @isTest
    public static void verifyApplicantResourceBiometricPIDBlockErrorResponse(){
        
        Opportunity opgr1 = new Opportunity();
        opgr1.StageName = 'Qualification';
        opgr1.CloseDate = Date.newInstance(2021, 1, 11);
        opgr1.Name = 'testone';
        insert opgr1;
        
        Applicant__c apgr1 = new Applicant__c();
        apgr1.Opportunity__c = opgr1.Id;
        apgr1.Contact_number__c = '9743514830';
        apgr1.Applicant_Type__c = 'Borrower';
        apgr1.PID_Block_Error_Response__c = '<PidData><Resp errCode="700" errInfo="Precision - Capture timed out" fCount="1" fType="0" iCount="-1" iType="-1" pCount="-1" pType="-1"/><DeviceInfo dpId="PRECISION.PB" rdsId="PRECISION.AND.001" rdsVer="1.2.3" dc="d8507b94-6000-439c-a17a-ddb1f5688474" mi="PB510" mc="MIIEGDCCAwCgAwIBAgIIYjRCGCmhn50wDQYJKoZIhvcNAQELBQAwgewxNzA1BgNVBAMTLkRTIFBSRUNJU0lPTiBCSU9NRVRSSUMgSU5ESUEgUFJJVkFURSBMSU1JVEVEIDMxJjAkBgNVBDMTHU5PIDIyIEhBQklCVUxMQUggUk9BRCBUIE5BR0FSMRAwDgYDVQQJEwdDSEVOTkFJMRIwEAYDVQQIEwlUQU1JTE5BRFUxIjAgBgNVBAsTGVNPTFVUSU9OIERFVkVMT1BNRU5UIFRFQU0xMjAwBgNVBAoTKVBSRUNJU0lPTiBCSU9NRVRSSUMgSU5ESUEgUFJJVkFURSBMSU1JVEVEMQswCQYDVQQGEwJJTjAeFw0yMjAyMTQxMTM0MDNaFw0yMjAzMTYxMTM0MDNaMG4xMjAwBgNVBAoMKVByZWNpc2lvbiBCaW9tZXRyaWMgSW5kaWEgUHJpdmF0ZSBMaW1pdGVkMRIwEAYDVQQLDAlCaW9tZXRyaWMxEDAOBgNVBAcMB0NIRU5OQUkxEjAQBgNVBAMMCVByZWNpc2lvbjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALIaF+M3g5/1bgKLntGKz75xkMXXtl3Z2NkbfTZWWKllvPLsajHaibjfOot1cQ8mYZeO1mxyxg932hpWg1C2JjlkjpQ5JiBz5OWz8aRVPOUNtsJnLLIwQBZQAR6fYk6CCuRZiTugvTfl/eL5eA5p9ukNSarYeZf2S/c1boKRQs/d4+nzugtuV37j1BkEf7fjbppGYBD1KTmaDGhgb5iXobEidsB7IMcZC2SVEcc3QzPlxRELNgEGtG98eJMxRno2mDYTelQoiUur/F8/A6dXvfOR03z2FQx/UA5uWzrEtIv2DAGyItlIcjcE0HCQdrpf3JVHEW6OawdUk4G0rINi43kCAwEAAaM7MDkwCQYDVR0TBAIwADALBgNVHQ8EBAMCAYYwHwYDVR0jBBgwFoAUtTWwpFcL+TBx63TcMhe9Ih9zKGcwDQYJKoZIhvcNAQELBQADggEBAFcAY1gjDVx9jqRcEP0ayRIGLWoW3DOybYBqjuDCgZPaIfNhRN9dHmcp9D1q25YdOlxCDfoK8/k3aP8gYlPTq/pksmjN5VhoR1Taoy40KHe0OrsBVXv5kvXI3C3Qq0rxcjhpmnP0HTf67sIZ47NByzBCG6LjD2ZOGAd4SdJYX2E3AcVuU84Nh4GIMNg6Cvmpjbb3q+uX24MEzHA4YwsZRGNUedhbWWGG7ackqwfduIAiqCeZlVZ6DE51l234xGuGBf4FGloNMnLyBDjjzMerhgm3LLka43skX2LwJ/i2zd5EzXZrzqASk+MfMYuuN/qWG+IpdHJPwpiGu41uX+2E0gA="><additional_info><Param name="srno" value="EAC9026AZRFE41912380"/><Param name="sysid" value=""/><Param name="ts" value="2022-02-25T11:19:31+05:30"/><Param name="Locking" value="N"/></additional_info></DeviceInfo><Data type="X"/></PidData>';
        insert apgr1;
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        
        req.requestURI = '/services/apexrest/ApplicantBiometricAPI/' + apgr1.Id;
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf(JSON.serialize(apgr1));
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        ApplicantResourceBiometric arb=new ApplicantResourceBiometric();
        ApplicantResourceBiometric.updateApplicant();
        System.debug('res ==>'+res);
        Test.stopTest();
        System.assertEquals(res.statusCode, 200);
    }
}