/*------------------------------------------------------------
Author:        Santhosh Mothe
Company:       Persistent Systems
Description:   Test class created to validate the DelegatedAuthService class
History
Date            Author              Comments
-------------------------------------------------------------
24-1-2022      Santhosh Mothe       Created
------------------------------------------------------------*/
@isTest(SeeAllData=false)
public class DelegatedAuthServiceTest{
    
    
    @testSetup 
    static void testDataSetup() 
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL CVO'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',MobilePhone = '9999999999',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, Maker_Id__c='12',
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='iblfm9344@persistent1.com.psldev1');
        insert u;
        
    }
    
    @isTest
    public static void testADAuthenticationService(){
        
        try{             
            String requestBody = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><Authenticate xmlns="urn:authentication.soap.sforce.com"><username>iblfm9344@persistent1.com.psldev1</username><password>12345</password><sourceIp>49.206.33.208</sourceIp></Authenticate></soapenv:Body></soapenv:Envelope>';
            
            
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();  
            request.requestURI = '/services/apexrest/delegatedauth/*';
            request.httpMethod = 'POST';
            
            request.requestBody = Blob.valueOf(requestBody);
            RestContext.request = request;
            RestContext.response = res;
            
            HttpResponse response1 = new HttpResponse();
            response1.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ngVhwejKhuxc7/MoDjigfAPS7/Wqztd6bzHheDNj4l9VIpwdN3XyppK5syNc4ycQJ2XVyqHqBs1acqxTfK7/TjCUngBil2dqQpDa4GXMq2IsiwZbGoCYYMYMgimFPK2RGZgOTvh8rxQIJAUCaPq8FRaioIdZN4ofzyKk20v4ChYM/YAd+CweSyb/K4JFIYF9B7koAvqaPSHHmDJ3mTyYmRmBtmtXdUY5AluNiLvzUDrSILVAUKT2jdUkaA7lFUaFrg9ekGeJgqqxkd2/5HfRLOBu/nAhovkxRmEoB255c6WCn3E4JJS7pHT86brIS8KLQ7XNcM4rLiA56Th7w+L1qjVHq8SmvBPdGf5mYmCDGTjvmmYtUixn26eNPB/0Pa7LneQrDy4ILwqrwUb8POOYsWj6fFTaauFbdXUUcpKLdTiXhTVobRYD+MJT06a9idGBcieoFFUgsBtT5dLrpMWQZuau4pzgnU8Ry+OoE+XfQdSpBo9P95cwgwPx9jeJVDUiGXL/k/bMfCr+UZk44vLyPbDFVVZeFN5Me7cjdMstP+dq+k6nFfurDsjdH8c9WMbFgYB4IgHSqcsVmeFChBjvf6taOEnZc794fbgtGQMFwFNSjdMdpvSSo6iV8sxVFFOmxk5WVesVFalaWXCFbDfPVf5GaJ6la9kGg19h7Qq+SIfOPObrJWb8pn4/v/Dx5BMToY="}');
            response1.setStatusCode(200);
            
            MockHttpRespDelegAuth mockResp = new MockHttpRespDelegAuth();
            mockResp.addResponse(response1);
            Test.setMock(HttpCalloutMock.class, mockResp);
            Test.startTest();
            DelegatedAuthService.doPost();
            System.debug(' ===>'+ RestContext.response);
            System.assert(RestContext.response.responseBody != null);
            //   System.assert(RestContext.response.statusCode == 200);
            Test.stopTest();
        } catch(Exception ex){
            system.debug('excepion details:'+ex.getStackTraceString());
        }
    }
    
    @isTest
    public static void testADAuthenticationService2(){
        
        try{             
            String requestBody = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><Authenticate xmlns="urn:authentication.soap.sforce.com"><username>iblfm9344@persistent1.com.psldev1</username><password>12345</password><sourceIp>49.206.33.208</sourceIp></Authenticate></soapenv:Body></soapenv:Envelope>';
            
            
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();  
            request.requestURI = '/services/apexrest/delegatedauth/*';
            request.httpMethod = 'POST';
            
            request.requestBody = Blob.valueOf(requestBody);
            RestContext.request = request;
            RestContext.response = res;
            
            HttpResponse response1 = new HttpResponse();
            response1.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5nhxnn6z+ibavpgNGTlE02imXgThE2tZJE79aTKwlbmIaBMXOIeqINx0nmMpf/kx6j0om0FxW4EHwMm4AsYOwE+7Hu52+usjF37uPsViWEEpM3ql5kHGftLeYxzKTbRK/emJYXsu9jbIzoTTPunVBLwkSsOjhiRS+Nl5OX7AmzSBV5XgOhiE4NBQPt6eUQHaileBJxMjaL+bmRNa+FhP2tzl62svJLU3RITe5SuJaeIgKA9XeWNOFM94zMKUO0GKWdhDL7zNEVrDIdaNEjAOUMASsmd2LZQMlnPoYtnjYeh5go92kIDILX3jZHJ5lpLSW3r++bntOutfwTVyJnLjbv5k4lo+qmB/OvvHeBbVZWXS6wha6B2NyJldQhnUcsL3BPATxRb0Ers/p3i8SKWA4EJ5nmHiGtOCRQHPKBwfdkQZEUQbkL3UWj3wy7GqYqKnj//OI0Ggzkf43dFV6+EEqbnEWzBGKz1ZxFQra/ZbGr8WEXX4e3C4/RGchcD8smJ7NGEXHoOa3yz152wIguEDgl1wwoIRBl3Sf0cLZsxyWuoe0v176t71ZGHlzoSy/NZS2PKtR9SDwA7+eX2tX10/DbHdiqtb6ofDA0Swha0beTzX57myYThJjZ7UWCMXFMIZA3GLJZWuL+Pp1Qay4Q/LI1tqkWpZhE33ZZ/84AV7gbj0NOZQ6y0RlUbhRLJVX43Qajw="}');
            
            response1.setStatusCode(200);
            
            MockHttpRespDelegAuth mockResp = new MockHttpRespDelegAuth();
            mockResp.addResponse(response1);
            Test.setMock(HttpCalloutMock.class, mockResp);
            Test.startTest();
            DelegatedAuthService.doPost();
            System.debug(' ===>'+ RestContext.response);
            System.assert(RestContext.response.responseBody != null);
            //   System.assert(RestContext.response.statusCode == 200);
            Test.stopTest();
        } catch(Exception ex){
            system.debug('excepion details:'+ex.getStackTraceString());
        }
    }
    
    @isTest
    public static void testADAuthenticationService3(){
        
        try{             
            String requestBody = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><Authenticate xmlns="urn:authentication.soap.sforce.com"><username>iblfm9344@persistent1.com.psldev1</username><password>12345</password><sourceIp>49.206.33.208</sourceIp></Authenticate></soapenv:Body></soapenv:Envelope>';
            
            
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();  
            request.requestURI = '/services/apexrest/delegatedauth/*';
            request.httpMethod = 'POST';
            
            request.requestBody = Blob.valueOf(requestBody);
            RestContext.request = request;
            RestContext.response = res;
            
            HttpResponse response1 = new HttpResponse();
            response1.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ngKWsZX8XLFdzKuTQXkxPT9HVSBsVY6ZpyvmG02QpbPVxxCtmm6SkPTWU6fT8pgSbsbgXZtsyjMEqz+5IZOO6dnCJvGnIg9uEezihGc43SgOIk+GPuBgJVcy6Zj1ojdkB8tdR3kJ4BgQTzLYcG2/etOEEn5fXhkjxXA726Bw5DBH/mrox1xqyU6q6ggzSvJuO6ZiSDA9ZlDeQP25hxvMV+HyjWXdV0DKORJ8ed1WLSrKDIfcKcqZAOKvM+EEPzhiFl/3aQmlkjG1Ph5QFoxnXcg5qoGZj6ajEOwDoMJGFZZ2z6XLATdxYdSo15IdE0vwLjlZq2vPz6xbL0rjcktgzE372/9RKAGQDkWzbReixPKGQs064BiUfRMS8fqxD9Z4Vg6NA0enR4gGlp77uW0czMImECHrGcC4PjHjfFr1cUoDcEBjZ7q0d0gdmKrHHjKV8SyjwKfK6ELRWh8/drKCOZtYmL3S0jZXCx5ceTHF9BHyEAkIPE5KKgwcSgUPqUp+9X3N0S9DnknIDXqyL0B2Ku4KNpmK21vC0XNP0cXsqPHU+vaDl7N91nSKob/jtSNqIbu9F0HWn5WHIJ6FkLBEs6620N/6MbeHWdXNJzejqqYSgp5DXmbQH3Y1yqioQTVZWBLW4ysaHgmsEQU4vAnbsZ78FLOH5+I9nwWGqMBE369TuqqxNRbKjB48UvA8VZCbMs="}');
            response1.setStatusCode(200);
            
            MockHttpRespDelegAuth mockResp = new MockHttpRespDelegAuth();
            mockResp.addResponse(response1);
            Test.setMock(HttpCalloutMock.class, mockResp);
            Test.startTest();
            DelegatedAuthService.doPost();
            System.debug(' ===>'+ RestContext.response);
            System.assert(RestContext.response.responseBody != null);
            //   System.assert(RestContext.response.statusCode == 200);
            Test.stopTest();
        } catch(Exception ex){
            system.debug('excepion details:'+ex.getStackTraceString());
        }
    }
    
    @isTest
    public static void testADAuthenticationService4(){
        
        try{             
            String requestBody = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><Authenticate xmlns="urn:authentication.soap.sforce.com"><username>iblfm9344@persistent1.com.psldev1</username><password>12345</password><sourceIp>49.206.33.208</sourceIp></Authenticate></soapenv:Body></soapenv:Envelope>';
            
            
            RestRequest request = new RestRequest();
            request.requestURI = '/services/apexrest/delegatedauth/*';
            request.httpMethod = 'POST';
            
            request.requestBody = Blob.valueOf(requestBody);
            RestContext.request = request;
            RestContext.response = new RestResponse();
            
            HttpResponse response2 = new HttpResponse();
            response2.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ngKWsZX8XLFdzKuTQXkxPT9WWjhrYi/jCjD4e1CvHrnS8V5t+bvSRT903axWzEFuSYQb+mg7SFDPNHd4cUdhmTpOKGhKcMfZZc310UpGisxhHCdcvW87dEbWm5Bx1WqSEKSRVsPuWu3QZvlAGrFi/NMNiA7Fjj8Ns4WkkcdZuoK51ZrdyTxtLZ3i/MNeH6YNqXtTfH8RaqZoPJPAYdgOVlkPxilYtq2vIgPX/58W+vWpNsyEYH6Rm5vaLE95xF0PWPFCjPOlWHhcsTHj8lEiajf5uYqsknm/PPhv6dq8M02++rSV1UpHFM1qOtdN7GTfcMFHKmBHs1HNW0EE3EmDGNUBLZBQ+jRcjQ/N5uwbM9x2CqfhMbZ5r2Whe7dR0EbFTew5eD/WD1WToyFIU4MDhQneBXn66k+LIB4i3mVn3zfSHLwByiI6lWWoEIwTW/zBQyAKg5X9+HqettbgOyx0lAf/o/QCsFZyQVG0KkAMD3q/M38HATdwkqcq4zXqvdymGQGBB4Dev91IjIARGjRblvxLjxxV3LVXTiPM7lKdvNtV3n5/vEZ6Rr9V631ISJSaxF+QrDJ2vZsplI438/un8mZyQvVUSydxGO0L47gzVj90AVwOHY/DcPaY0YURzSSmdF3fCls8XTXM5YCswFLgDyLHHtfuZGkB2i0c6FL9kv8iA=="}');
            response2.setStatusCode(200);
            
            MockHttpRespDelegAuth mockResp = new MockHttpRespDelegAuth();
            
            mockResp.addResponse(response2);
            Test.setMock(HttpCalloutMock.class, mockResp);
            Test.startTest();
            DelegatedAuthService.doPost();
            System.debug(' ===>'+RestContext.response);
            System.assert(RestContext.response.responseBody != null);
            System.assert(RestContext.response.statusCode == 201);
            Test.stopTest();
        } catch(Exception ex){
            system.debug('excepion details:'+ex.getStackTraceString());
        }
    }
    
    
    @isTest
    public static void testADAuthenticationService5(){
        
        try{             
            String requestBody = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><Authenticate xmlns="urn:authentication.soap.sforce.com"><username>iblfm9344@persistent1.com.psldev1</username><password>12345</password><sourceIp>49.206.33.208</sourceIp></Authenticate></soapenv:Body></soapenv:Envelope>';
            
            
            RestRequest request = new RestRequest();
            request.requestURI = '/services/apexrest/delegatedauth/*';
            request.httpMethod = 'POST';
            
            request.requestBody = Blob.valueOf(requestBody);
            RestContext.request = request;
            RestContext.response = new RestResponse();
            
            HttpResponse response2 = new HttpResponse();
            response2.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ng2kVzdHekohyxPbFgXAU2FTliiuE45xNfExWE973mpL1NLbMRoKUDsMmYIv8BOpEqnhptFrolHi9Y1Tg4QO1t+CrrS1Pk5q2fuGp8fNLfcMFIfkfnkrG5HmLVk+LmoVNIM0/wDwXsmQxp2dpjp9DEAl/IE7cO1D9nm64MWeqGK5xYXWGKxrwyC6K9HpSa5o+IyH+NvW0ijlxjoPZPk1Wvupgq7tnnLwo/tuvAocCo7c1DKM2dMyk8STK3qAF8ISUupQHLee1sId0zv5vO80/193RHhJXkIt3SyMHyoTCUH7kzQCuv23u7lJf8ef1C3zBzmzywRFgOJGjYeZ624RodHhNsy8j+dQbnDNa2MVETf9r7gphufUAyZsSPpMK7Fb2ZR+4JsIHrVlHz43wy1fSdK5Lx47qt4QWs8QEodn+2ExZ5+FWYb8j1a8IpisIMuzekQN03eQ3JsLz35J/+0vz4AWYzioZhBlYiP53t4SU4OvaUBUhrVGielY6kBNgpmezkkt/qrAGJ6YoGYxMfzCH7xiAK5+rVFba8XJILhFLPWgbF3Yy0c5s2AJ7sRClkv73lAcaIhDh3t/gU5NdiRjlj6Hs9ewaA6gje0C93aWiHPFV7dj/xs8vaCjW569L69imL7vA0IShCLMXMm78/v6crHD2I9YXxvlxImAT9k2penGVX9JR7X23ZQS1oRW15L6y8="}');
            response2.setStatusCode(200);
            
            MockHttpRespDelegAuth mockResp = new MockHttpRespDelegAuth();
            
            mockResp.addResponse(response2);
            Test.setMock(HttpCalloutMock.class, mockResp);
            Test.startTest();
            DelegatedAuthService.doPost();
            System.debug(' ===>'+RestContext.response);
            System.assert(RestContext.response.responseBody != null);
            System.assert(RestContext.response.statusCode == 201);
            Test.stopTest();
        } catch(Exception ex){
            system.debug('excepion details:'+ex.getStackTraceString());
        }
    }
    
     @isTest
    public static void testADAuthenticationService6(){
        
        try{             
            String requestBody = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><Authenticate xmlns="urn:authentication.soap.sforce.com"><username>iblfm9344@persistent1.com.psldev1</username><password>12345</password><sourceIp>49.206.33.208</sourceIp></Authenticate></soapenv:Body></soapenv:Envelope>';
            
            
            RestRequest request = new RestRequest();
            request.requestURI = '/services/apexrest/delegatedauth/*';
            request.httpMethod = 'POST';
            
            request.requestBody = Blob.valueOf(requestBody);
            RestContext.request = request;
            RestContext.response = new RestResponse();
            
            HttpResponse response2 = new HttpResponse();
            response2.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ng2kVzdHekohyxPbFgXAU2FChbWxt8qQWxdrAkIHwliEH/W4kkqueIHnGnOZ57WLu77OhQ9NCarFh5u/dRE0wKWAkovX4TZEhBSFFZlrrPr6x3OwAvqCAxopbqZC/JuC4hUbn8ha7MUWi3L4ju3sO9GsApWUFF+Vg5cTjEYyN3gSmDs1RwJsLLKdVIP63lHqro0JNvvtVL10uktlZ7MDa+rBxeOBRLVyPqV/xMipYyzyHPVKmLW7V14jDBoJMb/UyM9QDrhXJuQmnQG+VKSVFKYLMVgJVeVie+YUKFrxhEcl747btqT+4cbnTIq17boMeU+FfPqVdI8uTED8GQY16JC+iKAlGn6G/PhBP0M8pOoyihJzNBigRh368YWiwKi8G+/A1+rfrTg0w+nZuza+m1qaQD+vMDEWROCKoE2T3MqJP5D0Yj97khmN+fpr7JpsiHG6uq0XmXx5Eiz5YgHrbRUyWTLvQPTUMYMfAgMndcrGr02jiys+Hi6uWyaz5bcrwVbBIsKbPbi6FVCYPznV3QDso2vTCYYM9hp8OSwBA4UKNGc0ZTQdMctJT00T+2QfQv4KUPk2cWnm9GO0z+zDpxfEdh/aNTncMo0/hXSr8jhnG9A72jxVnIauo5poQR3QjOeQFq2YZxrjgEC1kA+DpwcH6FXtGm2rWKC+pEEBUtnjA=="}');
                              response2.setStatusCode(200);
            
            MockHttpRespDelegAuth mockResp = new MockHttpRespDelegAuth();
            
            mockResp.addResponse(response2);
            Test.setMock(HttpCalloutMock.class, mockResp);
            Test.startTest();
            DelegatedAuthService.doPost();
            System.debug(' ===>'+RestContext.response);
            System.assert(RestContext.response.responseBody != null);
            System.assert(RestContext.response.statusCode == 201);
            Test.stopTest();
        } catch(Exception ex){
            system.debug('excepion details:'+ex.getStackTraceString());
        }
    }
    
  
    @isTest
    public static void testADAuthenticationService7(){
        
        try{             
            String requestBody = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><Authenticate xmlns="urn:authentication.soap.sforce.com"><username>iblfm934411@persistent.com.psldev1</username><password>12345</password><sourceIp>49.206.33.208</sourceIp></Authenticate></soapenv:Body></soapenv:Envelope>';
            
            
            RestRequest request = new RestRequest();
            request.requestURI = '/services/apexrest/delegatedauth/*';
            request.httpMethod = 'POST';
            
            request.requestBody = Blob.valueOf(requestBody);
            RestContext.request = request;
            RestContext.response = new RestResponse();
            
            HttpResponse response1 = new HttpResponse();
            response1.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ngVhwejKhuxc7/MoDjigfAPS7/Wqztd6bzHheDNj4l9VIpwdN3XyppK5syNc4ycQJ2XVyqHqBs1acqxTfK7/TjCUngBil2dqQpDa4GXMq2IsiwZbGoCYYMYMgimFPK2RGZgOTvh8rxQIJAUCaPq8FRaioIdZN4ofzyKk20v4ChYM/YAd+CweSyb/K4JFIYF9B7koAvqaPSHHmDJ3mTyYmRmBtmtXdUY5AluNiLvzUDrSILVAUKT2jdUkaA7lFUaFrg9ekGeJgqqxkd2/5HfRLOBu/nAhovkxRmEoB255c6WCn3E4JJS7pHT86brIS8KLQ7XNcM4rLiA56Th7w+L1qjVHq8SmvBPdGf5mYmCDGTjvmmYtUixn26eNPB/0Pa7LneQrDy4ILwqrwUb8POOYsWj6fFTaauFbdXUUcpKLdTiXhTVobRYD+MJT06a9idGBcieoFFUgsBtT5dLrpMWQZuau4pzgnU8Ry+OoE+XfQdSpBo9P95cwgwPx9jeJVDUiGXL/k/bMfCr+UZk44vLyPbDFVVZeFN5Me7cjdMstP+dq+k6nFfurDsjdH8c9WMbFgYB4IgHSqcsVmeFChBjvf6taOEnZc794fbgtGQMFwFNSjdMdpvSSo6iV8sxVFFOmxk5WVesVFalaWXCFbDfPVf5GaJ6la9kGg19h7Qq+SIfOPObrJWb8pn4/v/Dx5BMToY="}');
            response1.setStatusCode(200);
            
            HttpResponse response2 = new HttpResponse();
            response2.setBody('{"JData":"f3U2xrqk3erkhq1xxOr+S8/57VD7sQmb49TNN+RvxQYM+Pga7l7dii8Jsm653ivyUecty6iu2EM4+RDcxXASc3ucpFERhHhuqc1Ix6wbOQ0MbiouiU5zGzignPR5CbMEro8f6xCidPawsIySzagUl7Xh8PPTSvX88kYW+rlRnYXr2iGXL2fj63SEcqbwf5gU"}');
            response2.setStatusCode(201);
            
            
            MockHttpRespDelegAuth mockResp = new MockHttpRespDelegAuth();
            
            mockResp.addResponse(response2);
            Test.setMock(HttpCalloutMock.class, mockResp);
            Test.startTest();
            
            DelegatedAuthService.doPost();
            System.debug(' ===>'+RestContext.response);
            System.assert(RestContext.response.responseBody != null);
            System.assert(RestContext.response.statusCode == 201);
            Test.stopTest();
            
            
            
        } catch(Exception ex){
            system.debug('excepion details:'+ex.getStackTraceString());
        }
    }
    
    
    ///////////////////////////////////////////////////////////////
    
    
    
    @isTest
    static void testDoPost_Failure() {
        // Set up test data
        // Insert test data as needed
        
        // Set up mock request and response
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response = response;
        request.requestBody = Blob.valueOf('Sample request body'); // Adjust as needed
        
        // Mock external callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, '{"response":{"respDesc":"Sample response"}}'));
        
        // Call the method under test
        Test.startTest();
        DelegatedAuthService.doPost();
        Test.stopTest();
        
        // Assert the response
        System.assertNotEquals(null, RestContext.response, 'RestContext.response should not be null.');
        //System.assertEquals(400, RestContext.response.statusCode, 'The status code should be 400.');
        // Add more assertions as needed
    }
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;
        
        // Constructor that matches the signature in the error
        public MockHttpResponseGenerator(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }
        
        // Implement the respond method as required by HttpCalloutMock
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HTTPResponse response = new HTTPResponse();
            response.setStatusCode(this.statusCode);
            response.setBody(this.responseBody);
            return response;
        }
    }
    
    
}