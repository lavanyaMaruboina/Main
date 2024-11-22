/**
* @Name:         Utilities
* @Author:       Khushiram
* @Company:      Persistent Systems
* @Description:  A class for generic functions
* Inputs:        None
* Test Class:    UtilitiesTest
*/
public without sharing class Utilities 
{
    public static Integer Max_Digit = 5;
    public static String STARTING_DIGIT= '00001';
    public static BusinessHours businessHours;
    public static Map<Id,RecordType> recordTypeMap;
    /*
* @Method Name: generateUniqueLeadNumber
* @Created by:  Neha G.
* @Description: Method to generate unique Lead Number pattern - L+Today'sDate(ddMMYY)+'00001'(Incrementing No):IND-308
* @Return:      String - returns Unique Lead Number
*/
    public static String generateUniqueLeadNumber() {
        try {
            //Query to fetch last Opportunity created for the day
            List < Opportunity > lastOpp = new List < Opportunity > ([Select Id , Lead_Number_Sequence__c from Opportunity where CreatedDate = TODAY WITH SECURITY_ENFORCED order by CreatedDate Desc limit 1]);
            //Query to fetch Lead Sequence No from Custom setting-->System_Configuration__c
            //Were getting issues in WITH SECURITY_ENFORCED so using getValues()
            //System_Configuration__c seqNumber = [SELECT id,Lead_Sequence_No__c FROM System_Configuration__c WITH SECURITY_ENFORCED FOR UPDATE ];
            System_Configuration__c seqNumber = System_Configuration__c.getValues('System Configuration');
            String todayYear = String.valueOf(System.today().Year()).right(2);
            String todayMonth = String.valueOf(system.today().Month()).length() == 1 ? '0' + String.valueOf(system.today().Month()) : String.valueOf(system.today().Month());
            String todayDay = String.valueOf(system.today().day()).length() == 1 ? '0' + String.valueOf(system.today().day()) : String.valueOf(system.today().day());
            String datePrefix = todayDay + '' + todayMonth + '' + todayYear;
            String finalLeadNumber = '';
            if (!lastOpp.isEmpty()) {
                integer lastFive = integer.valueof(lastOpp[0].Lead_Number_Sequence__c)- integer.valueof(seqNumber.Lead_Sequence_No__c);
                string lastFiveDigits=string.valueOf(lastFive);
                String applicationNameString = datePrefix + lastFiveDigits;
                long appvalue = Long.valueOf(applicationNameString);
                //increament by 1 if not first Loan Application created for the day
                if (String.valueOf(appvalue).length() == 10) {
                    //adding '0' to Lead No pattern if date ranges in 01-09
                    finalLeadNumber = 'L' + '' + '0' + '' + String.valueOf(appvalue + 1);
                } else {
                    finalLeadNumber = 'L' + '' + String.valueOf(appvalue + 1);
                }
            } else {
                //creats Lead Number for first Loan Application created for the day
                String applicationNameString = datePrefix + STARTING_DIGIT;
                long appvalue = Long.valueOf(applicationNameString);
                if (String.valueOf(appvalue).length() == 10) {
                    finalLeadNumber = 'L' + '' + '0' + '' + String.valueOf(appvalue);
                } else {
                    finalLeadNumber = 'L' + '' + String.valueOf(appvalue);
                }
            }
            //Stamp the current 05 digit increamenting seqNumber in Custom Setting(System Configuration)
            seqNumber.Lead_Sequence_No__c = finalLeadNumber.substring(finalLeadNumber.length() - Max_Digit);
            //if (Schema.sObjectType.System_Configuration__c.isUpdateable()){
            update seqNumber;
            //}
            if (Test.isRunningTest()) {
                // throw new AuraHandledException(System.Label.ExceptionMessage);
            }
            return finalLeadNumber;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('Utilities', 'generateUniqueLeadNumber', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    /*
* @Method:      generateUniqueNumber
* @Created by:  Khushiram
* @Description: Method to generate random Unique Number
* @Param:       Integer - length of random number to be generated
* @Return:      Integer - returns Unique Number
*/
    @AuraEnabled(cacheable=true)
    public static Integer generateUniqueNumber(Integer length){
        try{
            String randomString = string.valueof(Math.abs(Crypto.getRandomInteger()));
            Integer randomNumber = Integer.valueOf(randomString.substring(0, length));
            return randomNumber;
        }
        catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('Utilities', 'generateUniqueNumber', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    //End: generateUniqueNumber()
 
     /*
* @Method:      generateUniqueNumberAsync
* @Created by:  Aman
* @Description: Method to generate random Unique Number
* @Param:       Integer - length of random number to be generated
* @Return:      Integer - returns Unique Number
*/
    @AuraEnabled(cacheable=true)
    public static Integer generateUniqueNumberAsync(Integer length){
        try{
            String randomString = string.valueof(Math.abs(Crypto.getRandomInteger()));
            Integer randomNumber = Integer.valueOf(randomString.substring(0, length));
            List<Integration_Log__c> intLogList = new List<Integration_Log__c>();
            intLogList = [Select id, ReferenceId__c from Integration_Log__c where ReferenceId__c =:String.valueOf(randomNumber)];
            if(intLogList.isEmpty()){
                return randomNumber;
            }
            else {
                return	Utilities.generateUniqueNumberAsync(length);
            }
            
        }
        catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('Utilities', 'generateUniqueNumberAsync', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    //End: generateUniqueNumberAsync()

    /*
* @Method:      generateUniqueNumberAsyncCallout
* @Created by:  Gaurav
* @Description: Method to generate random Unique Number
* @Param:       Integer - length of random number to be generated
* @Return:      Integer - returns Unique Number
*/
@AuraEnabled
public static Integer generateUniqueNumberAsyncCallout(Integer length){
    try{
        String randomString = string.valueof(Math.abs(Crypto.getRandomInteger()));
        Integer randomNumber = Integer.valueOf(randomString.substring(0, length)); 
        return randomNumber;        
    } catch (Exception e) {
        ErrorLoggerUtil.logErrorEvent('Utilities', 'generateUniqueNumberAsyncCallout', 'Apex', e);
        throw new AuraHandledException(System.Label.ExceptionMessage);
    }
}
 
    /*
* @Method Name: encryptToBase64
* @Created by:  Khushiram.
* @Description: Function to encode the uploaded image in Base64 
*/
    public static String encryptToBase64(Blob uploadedImage){
        try{
            // Encoding the blob object into Base64                                                                           
            String encryptedBase64 = EncodingUtil.base64Encode(uploadedImage);
            return encryptedBase64;
        }
        catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('Utilities', 'encryptToBase64', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    //End: encryptToBase64()
    
    /*
* @Method Name: validateContactNumber
* @Created by:  Nidhi Dhote.
* @description: Function to Validate contact number from user
* @Param:       String - Contact Number entered by User
* @Return:      Boolean - response if Number already registered with User or not
*/
    @AuraEnabled(cacheable=true)
    public static Boolean validateContactNumber(String contactNumber){
        Boolean isNumberAvailable;
        try{
            isNumberAvailable = [select Count() from User where Phone=: contactNumber OR MobilePhone=: contactNumber WITH SECURITY_ENFORCED]> 0;  
            if(Test.isRunningTest())
            {
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
            return isNumberAvailable;
        }
        catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('Utilities', 'validateContactNumber', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    //End: validateContactNumber()
    
    /*
* @Method Name: generatePDFfromResponse
* @Created by:  Naga Puppala.
* @Description: Function to Validate generate PDF from responce.
* @Param:       String - response received
* @Param:      String - parent ID
*/
    public static void generatePDFfromResponse(String response, String parentId){
        try{
            Attachment attachment = new Attachment();
            attachment.ContentType = 'image/png';
            String name = System.now().format('ddMMyyyyHH:mm:ss');
            name = 'Photo_'+ name.replaceAll(':', '');
            attachment.Name = name+'.jpeg';
            attachment.ParentId = parentId;
            attachment.Body = EncodingUtil.base64Decode(response);
            if (Schema.sObjectType.Attachment.isCreateable()){
                insert attachment;
            }
            PageReference pageReference2 = new PageReference('/apex/PDFGeneratorPage?FileId='+attachment.Id);
            fetchContentDataFromPage(attachment.Id, name, pageReference2.getUrl(), parentId);
            if(Test.isRunningTest())
            {
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('Utilities', 'generatePDFfromResponse', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    //End: generatePDFfromResponse()
    
    /*
* @Method Name: fetchContentDataFromPage
* @Created by:  
* @Description: Function to fetch Content data from Page
*/
    @Future(Callout=true)
    public static void fetchContentDataFromPage(String attId, String name, String pageURL, String parentId){
        Attachment attachment = new Attachment();
        attachment.ContentType = 'application/pdf';
        attachment.Name = name+'.pdf';
        attachment.ParentId = parentId;
        if(Test.isRunningTest()){
            attachment.Body = Blob.valueOf('Testing String');
        }
        else{
            attachment.Body = new PageReference(pageURL).getContent();
        }
        if (Schema.sObjectType.Attachment.isCreateable()){
            insert attachment;
        }
        if (Schema.sObjectType.Attachment.isDeletable()){
            delete [select Id from Attachment where Id = :attId];
        }
    }
    //End: fetchContentDataFromPage()
    
    /*
* @Method:      generateApplicationNumber
* @Created by:  Neha G.
* @Description: Method generates an Application Number
* @Return:      Integer - returns generated Application No
*/
    public static Integer generateApplicationNumber(){
        //For now passing hardcoded value to gattingCheckEligibility() of LwcLOSLoanApplicationCtrl class
        return 123456;
    }
    
    public static Map<String,String> getHeaders(){
        Security_Setting__mdt metadataApi = Security_Setting__mdt.getInstance(System.Label.IBMMasterKey);
        //Security_Setting__mdt metadataApi = Security_Setting__mdt.getInstance('Reverse_Status');
        Map<String,String> requestHeaderMap = new Map<String,String>();
        requestHeaderMap.put(IntegrationConstants.CONTENT_TYPE , IntegrationConstants.CONTENT_TYPE_JSON);
        //requestHeaderMap.put('X-IBM-Client-Id', metadataApi?.Client_Id__c);
        //requestHeaderMap.put('X-IBM-Client-Secret', metadataApi?.Client_Secret__c);
        requestHeaderMap.put('IBL-Client-Id', metadataApi?.Client_Id__c);
        requestHeaderMap.put('IBL-Client-Secret', metadataApi?.Client_Secret__c);
        return requestHeaderMap;
    }
    
    //End: generateApplicationNumber()
    
    public static Map<String,String> pidblock(String xmlData){
        Map<String,String> finalResponseInJSON = new  Map<String,String>();
        system.debug('********** xmlData at PID BLOCK ******' +xmlData);
        String jsonContent; 
        //added by thilak
        //String response = '<PidData><Resp errCode="0" errInfo="SUCCESS" nmPoints="37" fType = "0" fCount = "1" qScore="74" /><DeviceInfo dpId="SECUGEN.SGI" rdsId="SGI.AND.001" rdsVer="1.0.2" dc="d2620fa5-0cb8-11e8-b92d-1418775b2036" mi="HU20" mc="MIIDoTCCAomgAwIBAgIEBBlSYjANBgkqhkiG9w0BAQUFADCBvzEmMCQGCSqGSIb3DQEJARYXa3VuZGFqQHNlY3VnZW5pbmRpYS5jb20xDzANBgNVBAcTBk11bWJhaTEsMCoGA1UEAxMjRFMgU0VDVUdFTiBJTkRJQSBQUklWQVRFIExJTUlURUQgMDQxJjAkBgNVBAoTHVNFQ1VHRU4gSU5ESUEgUFJJVkFURSBMSU1JVEVEMQswCQYDVQQLEwJJVDEUMBIGA1UECBMLTWFoYXJhc2h0cmExCzAJBgNVBAYTAklOMB4XDTIxMD-EyMTEwNDY1NVoXDTIxMDIyMDEwNDY1NVowZTEZMBcGA1UEAxMQc2dpcmRzc3Vic2NyaWJlcjENMAsGA1UECxMEQVVUSDEMMAoGA1UEChMDQVVBMQ4wDAYDVQQHEwVJbmRpYTEOMAwGA1UECBMFU3RhdGUxCzAJBgNVBAYTAklOMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsXz3GViGd780Rl5+WcVwtZQCh6A6T4Ee53tRYbi5cGxqRhaw31QHKtXudAUjXh/ZhD4J8X091vawBxqN9aI0fgGe377g7TnUoYS0luLynvhbzgee8KWf5bV+CpDrUeTPNvN5IzpsmD5KsNdUoOG/nAjc2IXoRZp6HyX6ZJigaieJ+WmZFL28wtWQJ/KU26ckbdYUWZ3drBXmhUxobWi2/k3vgiCVP5kUZm27kdte2UBkrD71sfUJpH37JgP5ailsy8R+TPGAvrCERUNCyif3AqfX5VtUv9+dI4khqta6utKAK8kxgcmdO+9qGue1h8npngSRBOQS26hwK9j23sfsGQIDAQABMA0GCSqGSIb3DQEBBQUAA4IBAQAjqySQzvrQ2sBm+dJZmN2KodfrZxwCnMVH/TuEBQsdv/Gvql2oQKLmnbL1o4i1H2N2HosMb8BFM/7R/0ze92HgwNqY0TxU45PnrPHjlCCVTt3POmneZGiEitc04aSZIOT96u7uYdqRgQ+NQhcsheI6iwy4Mf4bzVBr2JpaduvaF6UlP8488e/ROIUDYZdtEj8CtB43ZUWuhdk13Tynu0nM4/0Wcya2dwrKvASS1+eIYFx/qBKe8NtkMPwD+5s/9q5W9h/zbZwBPKPdnzB67itif+PUE36XRYAEqfZ4w8cd4VyrQQ8u0qPyrvNe3MSgA7Ndfw2kZe3+EtFxk6t3dpi/" ><additional_info><Param name="version" value="v1.0.2(0178)" /><Param name="camera" value="0" /><Param name="srno" value="H54201219107" /><Param name="pass" value="N" /></additional_info></DeviceInfo><Skey ci="20221023" >e5Pn3SM7OlHyBGRScN7wE9RAKU1w1VcQtpa8Z3up8sNwz3Y6JvR0Df4JOr+YtrKl44rBkG0rtb2cN6TpqYt5LJh6eyCLVTgoMkt61aSVVMS4ulkRXiBk3TNTeeujg+iSRwMIMNW7Cezgz+wUXgTIJ9iwaRorb3pV0ELWS7W4GugBSyfWpRUvs2B2U7bEg1m4igR7wYgP8/4e8JLEqy/tURgzRdoXFi2D33BgNCRyBPIl17p4LSHI5W9WhkOgT99/nsPRUcnuL7LmzcSQw1FYKewquE6njIfR2UL87Ck9LGP9Z78o2XvfhXDbupV2vMUOm95LEwApKrvO2IGM+vNo7g==</Skey><Hmac>UWxnwQulzeD6JniR0Rd0XXcWtl6nRSldK79FKufac4Bf4ifQikblrkJA+za8mozE</Hmac><Data type="X">MjAyMS0wMi0xMFQxNjoxOTo1NNX8A6e5eEtaXQ+TzCMoDHXjFbNy0heMFlAm0PWZFPwJEMfW09h/erSVV7nXTwEkmpHwzgxqFYrlbX1BTAFGVyxHIUkbGIbmjcWAHvMAWK/AWoa7WOO73Eba8IXReWnO374WQq/HAWt0uJUVyVWjkP8L/8Jj9kvnEx5t6BfeSRe1e9w2XNk4tf+HLlIPiwVf1qe/+iBpXA63aW08BB9fCCHxK7nHOt7pD0tileTXhwv+ryxbxObLREYDAB4myt9dFeEsHJS5M6KaJf0y8uDgN6vh83kvzxBOA6j8q3A66smmwQs2AURAADk/6qpAH01vzOhcZ3+LBUAst6oohmK3e2RlCtwGzwlfHbxPFhcvrhbX8fuQvK9/koXjpYfG2a95u7scH4YfhUFBTjv4WWnhE2lHBzuvjRL6DOJnu4fQJ/VVJQ6xD+0lePuu1ZppW0OWWyV9y1tcDI7NaDY3auj4w6z25+HuLxVG7F+U/vNKKtcE2VOwtPrytgPj764E0X5LUtymkRYoTbUAc3Q+p8MyVCI7rIn3oXuOV0aLh6i8oWKhPm/1asS+BUS4QKF9N8TpXB7kSe6pr8qKUPDDLIlMXb5WeEfTCUMpF+tC4EIQ7Tc7WNABYkapkXEcEIGszRXVsGNmXYx7CuZMvCiv5bSMRLpAOX3peXtB+nxMiwbzUpvOG4FF2Bw/4kwD3yQJoDdHk5McvZaZQAOx/AG27XOlN1jyU0/9RCEVDb2ZjVmFXUAlbl0e2eLBXf1jXTixvGPFNQ7lEk1oIiNhpUYGJCr91QyShpd/b2GLVc7q/g8SSZGQpsT+ESpAjTS0ai9AbuFjzIZH2k/TVf800ZjeAIEdWYju9/S0tHsmPzWFNihk55iQOuYKAdz/MsFxqc+CD03ICiGD9LdV39FBr46caaF2ldfFziQzJKVZvp8mFBvYP08UR1T/c8xIVM4lE22/1oauSddUgiPNt2h8lHBYezSLSW29Shv96oY9uv7I/lIse2boddm3Muev+ocXJiuctlkDVeQr679+KndMgzRMJmOwxsb/OJMi3ht1yWy4RRJmjW5z3iQM4GuY9jc/i/M0tkyNo35WHzsfZciPaaiJQ7+OnqnJxj652fqTbVDlvZ5E3PdjS0Hu1vCzF7J50VJZpUTm8pISPNZlrPm6u7L05OtmUeZUbJz8KWXPZta/Dawvjk5Ad5XySp9vMWWYwwzixX5Wqko=</Data></PidData>';
        //String jsonContent = XMLParser.xmlToJson(response);
        if( xmlData != NULL){
            jsonContent = XMLParser.xmlToJson(xmlData);
            Map<String,Object> jsonParsed =(Map<String,Object> ) JSON.deserializeUntyped(jsonContent);
            Map<String,Object> responseheader = (Map<String,Object>) jsonParsed.get('PidData'); 
            Map<String,Object> Resp = (Map<String,Object>) responseheader.get('Resp'); 
            Map<String,Object> DeviceInfo = (Map<String,Object>) responseheader.get('DeviceInfo');
            Map<String,Object> Skey = (Map<String,Object>) responseheader.get('Skey');
            Map<String,Object> Data = (Map<String,Object>) responseheader.get('Data');
            list<Object> additional_info = (list<Object>) DeviceInfo.get('additional_info');
            //Map<String,Object> Hmac = (Map<String,Object>) responseheader.get('Hmac'); 
            
            for(String key:responseheader.keySet()){
                string a =  String.valueOf(responseheader.get(key));
                finalResponseInJSON.put(key,a);
            }
            for(String key:DeviceInfo.keySet()){
                string a =  String.valueOf(DeviceInfo.get(key));
                finalResponseInJSON.put(key,a);
            }
            for(String key:Resp.keySet()){
                string a =  String.valueOf(Resp.get(key));
                finalResponseInJSON.put(key,a);
            }
            
            for(String key:Skey.keySet()){
                string a =  String.valueOf(Skey.get(key));
                if(key.equalsIgnoreCase('ele_text')){
                    key = 'ele_text1';
                } 
                finalResponseInJSON.put(key,a);
            }
            for(String key:Data.keySet()){
                string a =  String.valueOf(Data.get(key));
                if(key.equalsIgnoreCase('ele_text')){
                    key = 'ele_text2';
                }
                
                finalResponseInJSON.put(key,a);
            }
            system.debug('***Checking'+additional_info[0]);
            system.debug('***Checking1'+additional_info[1]);
            //system.debug('***addstring'+addstring);
            Map<String,object> addstring1 = (Map<String,object>) additional_info[0];
            Map<String,object> addstring2 = (Map<String,object>) additional_info[1];
            Map<String,object> addstring3 = (Map<String,object>) additional_info[2];
            
            for(String key:addstring3.keySet()){
                
                system.debug('***key'+key+'***');
                string a =  String.valueOf(addstring3.get(key));
                finalResponseInJSON.put(key,a);             
                
                //string value1 =  String.valueOf(key.value);
                //finalResponseInJSON.put(name1,value1);
            } 
            
            system.debug('***'+finalResponseInJSON+'***');
        }  
        return finalResponseInJSON;
    }
    
    /*
* @Method:      getStateMasterData
* @Created by:  Devanshu Gupta
* @Description: Method to return Geo_State_Masters__c
* @Param:       
* @Return:      Geo_State_Masters__c List
*/
    @AuraEnabled(cacheable=true)
    public static List<Geo_State_Masters__c> getStateMasterData() {
        try{
            List <Geo_State_Masters__c> listOfStateValue  = new List <Geo_State_Masters__c>();
            if(Schema.sObjectType.Geo_State_Masters__c.isAccessible()) {
                listOfStateValue = [SELECT Id, NeSL_State_Code__c, Name , State_Code__c, Pincode__c,Pincode_Starting_Max__c FROM Geo_State_Masters__c  WITH SECURITY_ENFORCED Order by Name ASC];
                
            }
            return listOfStateValue;
        } catch(Exception e){
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('Utilities', ' getStateMasterData ', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    /*
* @Method:      getCityStateMaster
* @Created by:  Devanshu Gupta
* @Description: Method to return City_State_Master__c
* @Param:       State name
* @Return:      City_State_Master__c List
*/
    @AuraEnabled
    public static List<District_Master__c> getCityStateMaster(String stateName) {
        try{
            List <District_Master__c> listOfCityValue  = new List <District_Master__c>();
            if(Schema.sObjectType.District_Master__c.isAccessible()) {
                listOfCityValue = [SELECT Id, District_Code__c, Name , Geo_State_Master__r.Name FROM District_Master__c WHERE Geo_State_Master__r.Name =:stateName WITH SECURITY_ENFORCED order by Name ASC];
              
            }
            System.debug('The City Values Are ---> '+listOfCityValue);
            return listOfCityValue;
        } catch(Exception e){
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('Utilities', ' getCityStateMaster ', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    /*
* @Method:      getCityStateMaster
* @Created by:  Devanshu Gupta
* @Description: Method to return City_State_Master__c
* @Param:       State name
* @Return:      City_State_Master__c List
*/
@AuraEnabled
public static List<City_State_Master__c> getCityStateMaster2(String stateName) {
    try{
        List <City_State_Master__c> listOfCityValue  = new List <City_State_Master__c>();
        if(Schema.sObjectType.City_State_Master__c.isAccessible()) {
     listOfCityValue = [SELECT Id, City_Code__c, Name , State__r.Name FROM City_State_Master__c WHERE State__r.Name =:stateName WITH SECURITY_ENFORCED order by Name ASC];
        }
    return listOfCityValue;
    } catch(Exception e){
        ErrorLoggerUtil.logError('Utilities', ' getCityStateMaster ', System.Label.Apex, e);
        throw new AuraHandledException(System.Label.ExceptionMessage);
    }
}

    /*
* @Method:      getDistrictsbyState
* @Created by:  Sathyanarayana Somayajula
* @Description: Method to return District_Master__c
* @Param:       State name
* @Return:      District_Master__c List
*/
    @AuraEnabled
    public static List<District_Master__c> getDistrictsByState(String stateName) {
        System.debug('Start of The District Masters ');
        try{
            
            List <District_Master__c> districtsList  = new List <District_Master__c>();
            if(Schema.sObjectType.District_Master__c.isAccessible()) {
                districtsList = [SELECT Id, Name, District_Code__c,Geo_State_Master__r.Name FROM District_Master__c  WHERE Geo_State_Master__r.Name =:stateName WITH SECURITY_ENFORCED Order by Name ASc];
                
            }
            System.debug('*** Start of The District Masters  --> '+districtsList);
            return districtsList;
        } catch(Exception e){
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('Utilities', ' getDistrictsByState ', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    /*
    * @Method:      getMFCCityMasterBasedOnStateCode
    * @Created by:  Sanketkumar Patil
    * @Description: To get MFC City Data
    * @Param:       String - State Code
    * @Return:      MFC_City_Master__c List
    */
    @AuraEnabled
    public static List<MFC_City_Master__c> getMFCCityMasterBasedOnStateCode(String stateCode) {
        try{
            List <MFC_City_Master__c> mFCCityList  = new List <MFC_City_Master__c>();
            
            if(Schema.sObjectType.MFC_City_Master__c.isAccessible()) {
                mFCCityList = [SELECT Id, Name, City_Code__c, City_Name_Code__c, State_Code__c, State_Name__c FROM MFC_City_Master__c WHERE Active_Flag__c = 'Y' AND State_Code__c = :stateCode WITH SECURITY_ENFORCED Order by Name ASC];
            }
            return mFCCityList;
        } catch(Exception e){
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('Utilities', ' getMFCCityMasterBasedOnStateCode ', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
/*
* @Method:      getTalukaByDistrictAndState
* @Created by:  Satyam Singh
* @Description: Method to return Taluka_Master__c
* @Param:       State name ,District name
* @Return:      Taluka_Master__c List
*/
@AuraEnabled
public static List<Taluka_Master__c> getTalukaByDistrictAndState(String stateName) { //removed String districtName parameter
    try{
        List <Taluka_Master__c> talukasList  = new List <Taluka_Master__c>();
        // if(Schema.sObjectType.Taluka_Master__c.isAccessible()) {
            talukasList = [SELECT Id, Name FROM Taluka_Master__c WHERE State__c =:stateName Order by Name ASc]; // removed District__c =:districtName condition
        // }
        return talukasList;
    } catch(Exception e){
        Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('Utilities', ' getTalukaByDistrictAndState ', System.Label.Apex, e);
        if(Schema.sObjectType.Error_Log__c.isCreateable()){
            insert errorLogRecord;
        }
        throw new AuraHandledException(System.Label.ExceptionMessage);
    }
}
    /*
    * @Method:      getMFCStateMasterData
    * @Created by:  Sanketkumar Patil
    * @Description: To get MFC State Data
    * @Param:       -
    * @Return:      MFC_State_Master__c List
    */
    @AuraEnabled(cacheable=true)
    public static List<MFC_State_Master__c> getMFCStateMasterData() {
        try{
            List <MFC_State_Master__c> mFCStateList  = new List <MFC_State_Master__c>();
            
            if(Schema.sObjectType.MFC_State_Master__c.isAccessible()) {
                mFCStateList = [SELECT Id, Name, State_Code__c, State_Name_Code__c FROM MFC_State_Master__c WITH SECURITY_ENFORCED Order by Name ASC];
            }
            return mFCStateList;
        } catch(Exception e){
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError('Utilities', ' getMFCStateMasterData ', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    // @Method:      handleChangeOwnerProcess
    // @Created by:  Manish Baldota
    // @Description: Method to handle the business logic of CMU owner change.
    // @Param:       List : source - List in which check contains. Object : target - string to check in list  
    // @Return:      Boolean, True - if contains, False - if not contains.
    public static Boolean listContains(Object[] source, Object target) {
        return (new Set<Object>(source)).contains(target);
    }

     // @Method:      createContentDocumentFromApex
    // @Created by:  Manish Baldota
    // @Description: Generic method to create the content Document and verision of it and associate that with recordId.
    // @Param:       String : documentName - Name/title of the document  
    //               Blob : documentData - Document Data to be stored
    //               String : recordId - Id of record to which thi s document to be attached
    // @Return:      String : contentDocumentID, Id of conent document.
    public static String createContentDocumentFromApex(String recordId, String documentName,Blob documentData,String fileType) {
        try{
            User usr = [Select Id,Name,IsPortalEnabled from User where id=:UserInfo.getUserId()];
            Id netId = [SELECT Id FROM Network LIMIT 1].Id;

            //Create Document
            ContentVersion cv = new ContentVersion();
            cv.Title = documentName;
            cv.VersionData = documentData;
            cv.IsMajorVersion = true;
            cv.PathOnClient = documentName+'.'+fileType;
            cv.Document_Side_fileupload__c = 'Front';//CISP-3484
            if(usr.IsPortalEnabled){
                cv.NetworkId = netId;    
            }

            if (Schema.sObjectType.ContentVersion.isCreateable()){  
                Insert cv; 
            }

            //Get Content Documents
            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
            
            //Create ContentDocumentLink 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = recordId;
            cdl.ContentDocumentId = conDocId;
            cdl.shareType = 'V';
            if (Schema.sObjectType.ContentDocumentLink.isCreateable()){  
                Insert cdl; 
            }
            return conDocId;
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('utilites', 'createContentDocumentFromApex', System.Label.Apex, e, '');
            throw new IND_Exception(e.getMessage());
        }
    }

    // @Method:      createContentDocumentDownloadFromApex
    // @Created by:  Kruthi Nadig
    // @Description: Generic method to create the content Document and verision of it and associate that with recordId.
    // @Param:       String : documentName - Name/title of the document  
    //               Blob : documentData - Document Data to be stored
    //               String : recordId - Id of record to which thi s document to be attached
    //               String : oppId - Id of loan application
    // @Return:      String : contentDocumentID, Id of conent document.
    public static String createContentDocumentDownloadFromApex(String recordId, String documentName,Blob documentData,String fileType,String oppId) {
        try{
            User usr = [Select Id,Name,IsPortalEnabled from User where id=:UserInfo.getUserId()];
            Id netId = [SELECT Id FROM Network LIMIT 1].Id;
            Opportunity opp = new Opportunity();

            if(oppId != null){
                opp = [Select Id,ownerId from Opportunity where Id = :oppId];
            }

            //Create Document
            ContentVersion cv = new ContentVersion();
            cv.ownerId = opp.ownerId;
            cv.firstPublishLocationId = opp.Id;
            cv.Title = documentName;
            cv.VersionData = documentData;
            cv.IsMajorVersion = true;
            cv.PathOnClient = documentName+'.'+fileType;
            if(usr.IsPortalEnabled){
                cv.NetworkId = netId;    
            }

            if (Schema.sObjectType.ContentVersion.isCreateable()){  
                Insert cv; 
            }

            //Get Content Documents
            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
            
            //Create ContentDocumentLink 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = recordId;
            cdl.ContentDocumentId = conDocId;
            cdl.shareType = 'V';
            if (Schema.sObjectType.ContentDocumentLink.isCreateable()){  
                Insert cdl; 
            }
            return conDocId;
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('utilites', 'createContentDocumentFromApex', System.Label.Apex, e, '');
            throw new IND_Exception(e.getMessage());
        }
    }

    
    // @Method:      getRetryCount
    // @Created by:  Sanketkumar Patil
    // @Description: Generic Method to get Retry Count.
    // @Param:       String : loanApplicationId - Loan Application Id
    // @Param:       String : applicantType - Applicant Type
	// @Param:       String : countfieldName - Count Field
    // @Param:       String : metadataAttemptsField - Count Field from Metadata
    // @Return:      Integer : Retry Count
    @AuraEnabled
    public static Decimal getRetryCount(String loanApplicationId, String applicantType, String countfieldName, String metadataAttemptsField) {
        try{
            Decimal currentCount = 0;
            System_Constant_custom_metadata__mdt metadataCount = System_Constant_custom_metadata__mdt.getInstance(metadataAttemptsField); 
            
            //Temporary code to work with existing Leads - To be removed once creation of record handled in L1 Journey
            List<Retry_count__c> retryCountCheckList = [select id from Retry_Count__c where Loan_Application_Id__c = :loanApplicationId and Applicant_Type__c = :applicantType WITH SECURITY_ENFORCED];
            if(retryCountCheckList.isEmpty()){
            	Retry_count__c rcObj = new Retry_count__c(Loan_Application_Id__c = loanApplicationId, Applicant_Type__c = applicantType);
                
                if (Schema.sObjectType.Retry_Count__c.isCreateable()){
                    insert rcObj;
                } 
            }
            //Temporary code to work with existing Leads - To be removed once creation of record handled in L1 Journey
                        
            String soqlQuery = 'SELECT ID, ' + countfieldName + ' FROM Retry_count__c WHERE Loan_Application_Id__c = \''  +  loanApplicationId  + '\' and Applicant_Type__c = \'' + applicantType + '\' WITH SECURITY_ENFORCED';
            List<Retry_count__c> retryCountList = Database.query(soqlQuery);   
            
            if(!retryCountList.isEmpty()){
                currentCount = (Decimal) retryCountList[0].get(countfieldName);
            }
            
            if(currentCount <= metadataCount.Number_Of_Attempts__c) {                    
                //If number of attempts are Less than predefined number of attempts.
                currentCount += 1;
                
                retryCountList[0].put(countfieldName, currentCount);
                
                if (Schema.sObjectType.Retry_Count__c.isUpdateable()){
                    update retryCountList[0];
                }                    
            }

            return currentCount;
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('utilites', 'getRetryCount', System.Label.Apex, e, '');
            throw new IND_Exception(e.getStackTraceString());
        }
    }
    // @Method:      getRetryCountNew
    // @Created by:  Gaurav Rawat
    // @Description: Generic Method to get Retry Count.
    // @Param:       String : loanApplicationId - Loan Application Id
    // @Param:       String : applicantType - Applicant Type
	// @Param:       String : countfieldName - Count Field
    // @Param:       String : metadataAttemptsField - Count Field from Metadata
    // @Param:       String : applicantId - applicant Id
    // @Return:      Integer : Retry Count
    @AuraEnabled
    public static Decimal getRetryCountNew(String loanApplicationId, String applicantType, String countfieldName, String metadataAttemptsField, String applicantId) {
        try{
            Decimal currentCount = 0;
            System_Constant_custom_metadata__mdt metadataCount = System_Constant_custom_metadata__mdt.getInstance(metadataAttemptsField); 
            
            //Temporary code to work with existing Leads - To be removed once creation of record handled in L1 Journey
            List<Retry_count__c> retryCountCheckList = [select id from Retry_Count__c where Loan_Application_Id__c = :loanApplicationId and Applicant_Type__c = :applicantType AND Applicant__c =: applicantId WITH SECURITY_ENFORCED];
            if(retryCountCheckList.isEmpty()){
            	Retry_count__c rcObj = new Retry_count__c(Loan_Application_Id__c = loanApplicationId, Applicant_Type__c = applicantType, Applicant__c = applicantId);
                
                if (Schema.sObjectType.Retry_Count__c.isCreateable()){
                    insert rcObj;
                } 
            }
            //Temporary code to work with existing Leads - To be removed once creation of record handled in L1 Journey
                        
            String soqlQuery = 'SELECT ID, ' + countfieldName + ' FROM Retry_count__c WHERE Loan_Application_Id__c = \''  +  loanApplicationId  + '\' and Applicant_Type__c = \'' + applicantType + '\' AND Applicant__c =  \'' + applicantId + '\' WITH SECURITY_ENFORCED';
            List<Retry_count__c> retryCountList = Database.query(soqlQuery);   
            
            if(!retryCountList.isEmpty()){
                currentCount = (Decimal) retryCountList[0].get(countfieldName);
            }
            
            if(currentCount <= metadataCount.Number_Of_Attempts__c) {                    
                //If number of attempts are Less than predefined number of attempts.
                currentCount += 1;
                
                retryCountList[0].put(countfieldName, currentCount);
                
                if (Schema.sObjectType.Retry_Count__c.isUpdateable()){
                    update retryCountList[0];
                }                    
            }

            return currentCount;
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('utilites', 'getRetryCount', System.Label.Apex, e, '');
            throw new IND_Exception(e.getStackTraceString());
        }
    }

    // @Method:      fetchCustomerCode
    // @Created by:  Khushiram
    // @Description: Method to fetch the customer code.
    // @Param:       Id applicantId - Applicant Id
    // @Return:      String - Customer code
    @AuraEnabled
    public static string fetchCustomerCode(id applicantId){
        try {
            Applicant__c app = [select id,Account__r.Customer_code__c,Customer_code__c  from applicant__c where id=: applicantId WITH SECURITY_ENFORCED];
            System.debug('app => '+app.Account__r.Customer_code__c);
            return app.Account__r.Customer_code__c != null ? app.Account__r.Customer_code__c : app.Customer_code__c;//CISP-3560
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('utilites', 'fetchCustomerCode', System.Label.Apex, e, '');
            throw new IND_Exception(e.getStackTraceString());
        }
    }

    /*
     * @Method:      getApplicantId
     * @Created by:  
     * @Description: This Method is for fetching applicant Id.
     * @Param:     String opportunityId, String applicantType
     * @Return:     	null
     */
    @AuraEnabled(Cacheable = true)
    public static string getApplicantId(String opportunityId, String applicantType) {
        try {
            if (opportunityId != null && applicantType != null) {
                list<Applicant__c> appObj = [SELECT Id FROM Applicant__c WHERE Opportunity__c =: opportunityId AND Applicant_Type__c =: applicantType
                AND In_Active_Applicant__c = false 
                WITH SECURITY_ENFORCED limit 1];
                if(!appObj.isEmpty()){
                    return appObj[0].id;
                }
            }
            return null;
        } catch (Exception e) {
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(' Utilities ', ' getApplicantId ', 'System.Label.Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);            
        }
    }
        /*
        written without method to fetch the Integration records in system mode. 
        this should be run in without sharing mode
    */

    public static List<Integration_Log__c> getIntegrationLogs(String serviceName, String loanId){
        try{

            List<Integration_Log__c> integrationLogs =  [select Id, Status__c, Service_Name__c,
            Loan_Application__c, CreatedDate from Integration_Log__c 
            where Service_Name__c =: serviceName and
            Loan_Application__c =:loanId order by createddate Desc  limit 1];

        return integrationLogs;
        }catch(exception e){
            return null;
        }
        
    }

    public static Boolean isFiCasesAvailable(String loanId , String applicantId ){
        try{
            List<Case> caseList = [select id, Loan_Application__c from case 
                                    where Loan_Application__c =: loanId AND Applicant__c=:applicantId
                                    AND RecordType.DeveloperName = 'FI'];
                if(!caseList.isEmpty()){
                    system.debug(caseList);
                    return true;   
                }
                return false;
        }
        catch(exception e)
        {            
            ErrorLoggerUtil.logErrorEvent('Utilities', 'isFiCasesAvailable', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);   
        }
    }

    public static List<Integration_Log__c> getIntegrationLog(List<String> serviceName, String opportunityId){
        try{
            List<Integration_Log__c> lstIntLog =[SELECT Service_Name__c,Status__c,Original_response__c FROM Integration_Log__c 
            WHERE Service_Name__c IN: serviceName  
            AND Loan_Application__c=:opportunityId 
            order by CreatedDate Desc];

            return lstIntLog;
        }
        catch(exception e)
        {            
            ErrorLoggerUtil.logErrorEvent('Utilities', 'getIntegrationLog', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);   
        }

    }

    public static Boolean createCaseTeamMember(String caseId){
        try{
            CaseTeamRole csrole = [select Id,name,AccessLevel from CaseTeamRole where name = 'caseaccess' limit 1];
            system.debug('csrole::'+csrole);
            insert new CaseTeamMember(ParentId = caseId, MemberId = UserInfo.getUserId(),TeamRoleId = csrole.Id);
            return true;
        }
        catch(exception e)
        {            
            ErrorLoggerUtil.logErrorEvent('Utilities', 'createCaseTeamMember', System.Label.Apex, e);
            return false;  
        }

    }
    public static Boolean deleteCaseTeamMember(String loanId){
        try{
            List<case> caseList = [select id from case where Loan_Application__c =: loanId and RecordType.Name = 'CMU Request' limit 1];
                if(!caseList.isEmpty()){
                    List<CaseTeamMember> caseTeamList = [select id from CaseTeamMember where ParentId = :caseList[0].Id AND MemberId =:  UserInfo.getUserId() Limit 1];
                    System.debug('caseTeamList '+caseTeamList);
                    if(!caseTeamList.isEmpty()){
                        delete caseTeamList;
                    }
            return true;
            }
            return false;
        }
        catch(exception e)
        {            
            ErrorLoggerUtil.logErrorEvent('Utilities', 'createCaseTeamMember', System.Label.Apex, e);
            return false;  
        }

    }
    
    public static Boolean deleteOpportunityTeamMemberRecord(List<OpportunityTeamMember> oppTeam){
        try{
            delete oppTeam;
            return true;
        }
        catch(exception e)
        {            
            ErrorLoggerUtil.logErrorEvent('Utilities', 'deleteOpportunityTeamMemberRecord', System.Label.Apex, e);
            return false;  
        }

    }

    @InvocableMethod(label='get indus site url' description='get indus site url')
    public static List<String> getSiteUrl(){
        try{
            List<String> st=new List<String>();
            List<SiteDetail> SiteDetailrec;
          List<Site> siterec=  [select Id from Site where Name = 'IndusDrive'];
          if(!siterec.isEmpty()){
            SiteDetailrec =[select SecureURL from SiteDetail where DurableId =: siterec[0].Id];
          }
          if(!SiteDetailrec.isEmpty()){
            st.add(SiteDetailrec[0].SecureURL);

          }
            return st;
           
        }
        catch(exception e)
        {          
              System.debug(' getSiteUrl error '+e.getMessage());
           ErrorLoggerUtil.logErrorEvent('Utilities', 'getSiteUrl', System.Label.Apex, e);
           return null;
        }

    }

    // @Method:      getCustDedupeBasedOnCICNumber
    // @Created by:  Sanketkumar
    // @Description: Method to get matching Customer Dedupe
    // @Param:       Set if CIC Numbers
    // @Return:      Matching Customer Dedupe List
    public static List<Customer_Dedupe_Response__c> getCustDedupeBasedOnCICNumber(Set<String> sCICNoSet,String productType,String oppId){ //CISP-4571 Retriving existing lead based on product type as well
        try {
            //CISP:142
            List<Customer_Dedupe_Response__c> custDedupeList = [select id , CIC_No__c, Applicant__r.Opportunity__r.Sanction_Date__c, Applicant__r.Opportunity__r.Name, Applicant__r.Opportunity__r.StageName,Applicant__r.Opportunity__r.Is_Revoked__c,Applicant__r.Opportunity__r.Parent_Loan_Application__r.StageName,Customer_Code__c, Applicant__r.Opportunity__r.Product_Type__c,Applicant__r.Name,Applicant__r.Opportunity__r.Agent_BL_code__c,Applicant__r.Opportunity__r.Sub_Stage__c ,Applicant__r.Opportunity__r.Journey_Status__c,Applicant__r.Opportunity__r.JourneyStopScenarioFound__c,Applicant__r.Opportunity__r.Account.name  from Customer_Dedupe_Response__c where CIC_No__c in :sCICNoSet AND Applicant__r.Opportunity__r.Product_Type__c =:productType AND Applicant__r.In_Active_Applicant__c = false AND Applicant__r.Opportunity__c !=:oppId];////CISP-8202 ,CISP-2384 -- Added is_Revoked //CISP-2783
            
            System.debug('Matching Customer Dedupe:: '+ custDedupeList);
            return custDedupeList;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('utilites', 'getCustDedupeBasedOnCICNumber', System.Label.Apex, e, '');
            throw new IND_Exception(e.getStackTraceString());
        }
    }

    // @Method:      getDocumentInfo
    // @Created by:  Kruthi Nadig
    // @Description: Method to get documentInfo for PACT request
    // @Param:       
    // @Return:      List of DocumentInfo
    public static List<IND_PactLmsRequest.objDocumentInfo> getDocumentInfo(String laId,list<TeleVerification__c> TeleVerificationList,list<Documents__c> loanDocumentList){
        
        List<IND_PactLmsRequest.objDocumentInfo> objDocumentInfo = new List<IND_PactLmsRequest.objDocumentInfo>();
        Set<Id> docIdSet = new Set<Id>();
        for(Documents__c doc : loanDocumentList) {
            docIdSet.add(doc.Id);
        }
        List<AML_Check__c> amlCheckList = new List<AML_Check__c>([Select Id, Loan_Application__c From AML_Check__c Where Loan_Application__c=: laId WITH SECURITY_ENFORCED]);
            if(amlCheckList.size() > 0) {
                for(AML_Check__c aml : amlCheckList) {
                    docIdSet.add(aml.Id);
                }
            }
            if(TeleVerificationList.size() > 0) {
                for(TeleVerification__c tvr : TeleVerificationList) {
                    docIdSet.add(tvr.Id);
                }
            } 

            Map<string,list<string>> cdDocMap = new Map<string,list<string>>(); 
            Map<string,ContentVersion> cvMap = new Map<string,ContentVersion>();
            list<String> cdIds = new list<String>();
            for(ContentDocumentLink cdl: [Select Id,ContentDocumentId,LinkedEntityId from ContentDocumentLink where LinkedEntityId = :docIdSet]) {
                cdIds.add(cdl.ContentDocumentId);
                if(cdDocMap.containsKey(cdl.LinkedEntityId)) {
                    cdDocMap.get(cdl.LinkedEntityId).add(cdl.ContentDocumentId);
                } else {
                    cdDocMap.put(cdl.LinkedEntityId,new list<String>());
                    cdDocMap.get(cdl.LinkedEntityId).add(cdl.ContentDocumentId);
                }
            }
            for(ContentVersion cv : [Select Id,ContentDocumentId,Document_Side_fileupload__c from ContentVersion where ContentDocumentId = :cdIds and IsLatest=true]) {
                cvMap.put(cv.ContentDocumentId,cv);
            }
            
            for(Documents__c doc :loanDocumentList){
                if(cdDocMap.containsKey(doc.Id)) {
                for(String cd : cdDocMap.get(doc.Id)){
                    if(cvMap.get(cd) != null){
                        ContentVersion contentVersion = cvMap.get(cd);
                        IND_PactLmsRequest.objDocumentInfo obDocumentInfo = new IND_PactLmsRequest.objDocumentInfo();
                        obDocumentInfo.Document_Type = doc.Document_Type__c != null ? doc.Document_Type__c : '';
                        obDocumentInfo.Record_Id = contentVersion.id != null ? String.valueOf(contentVersion.id) : '';
                        objDocumentInfo.add(obDocumentInfo);
                        } 
                    }
                } 
            } 
            
            if(amlCheckList.size() > 0){
                for(AML_Check__c aml : amlCheckList) {
                    if(cdDocMap.containsKey(aml.Id)) {
                        for(String cd : cdDocMap.get(aml.Id)){
                        ContentVersion contentVersion = cvMap.get(cd);
                        IND_PactLmsRequest.objDocumentInfo obDocumentInfo = new IND_PactLmsRequest.objDocumentInfo();
                        obDocumentInfo.Document_Type = 'AML check';
                        obDocumentInfo.Record_Id = contentVersion.id != null ? String.valueOf(contentVersion.id) : '';
                        objDocumentInfo.add(obDocumentInfo);
                        }
                    }
                }
            }
            if(TeleVerificationList.size() > 0){
                for(TeleVerification__c tvr : TeleVerificationList) {
                    if(cdDocMap.containsKey(tvr.Id)) {
                        for(String cd : cdDocMap.get(tvr.Id)){
                        ContentVersion contentVersion = cvMap.get(cd);
                        IND_PactLmsRequest.objDocumentInfo obDocumentInfo = new IND_PactLmsRequest.objDocumentInfo();
                        obDocumentInfo.Document_Type = 'Email Attachment';
                        obDocumentInfo.Record_Id = contentVersion.id != null ? String.valueOf(contentVersion.id) : '';
                        objDocumentInfo.add(obDocumentInfo);
                        }
                    }
                }
            }
            return objDocumentInfo;
        }
    /*
     * @Method:      calculateMedianPayouts
     * @Created by:  Udit Singhal
     * @Description: This method will retrieve the median pay-outs for the last 90 days for Main Dealer, Sub-dealer and DSM Incentive
     * @Param:       String - Id of the current loan application record
     * @Return:      Map<String, Decimal>
     */
    @AuraEnabled
    public static Map<String, Decimal> calculateMedianPayouts(String loanApplicationId){
        List<Opportunity> oppList = new List<Opportunity>([Select Id, Product_Type__c FROM Opportunity Where Id=: loanApplicationId LIMIT 1]);
        Map<String, Decimal> resultMap = new Map<String, Decimal>();
        List<Final_Term__c> finalTermList = new List<Final_Term__c>();
        if(oppList.size() > 0){
            finalTermList = [SELECT Id, Dealer_incentive_amount_main_dealer__c, Dealer_incentive_amount_sub_dealer__c, DSM_Incentive1__c, DSM_Incentive2__c, Loan_Amount__c
            FROM Final_Term__c WHERE CreatedDate = LAST_90_DAYS AND Loan_Application__r.Payment_Request_Generation_Date__c != null AND Loan_Application__c != :loanApplicationId AND Loan_Application__r.Product_Type__c =: oppList[0].Product_Type__c Order by CreatedDate DESC LIMIT 49998];
        }
        Integer count = 0;
        Decimal mainDlrIncentivePercentMedian = 0;
        Decimal subDlrIncentivePercentMedian = 0;
        Decimal dsmIncentive1PercentMedian = 0;
        Decimal dsmIncentive2PercentMedian = 0;

        for (Final_Term__c ftRecord : finalTermList){
            Decimal mainDlrIncentive = String.isNotBlank(ftRecord.Dealer_incentive_amount_main_dealer__c) ? Decimal.valueOf(ftRecord.Dealer_incentive_amount_main_dealer__c) : 0;
            Decimal subDlrIncentive = String.isNotBlank(ftRecord.Dealer_incentive_amount_sub_dealer__c) ? Decimal.valueOf(ftRecord.Dealer_incentive_amount_sub_dealer__c) : 0;
            Decimal dsmIncentive1 = String.isNotBlank(ftRecord.DSM_Incentive1__c) ? Decimal.valueOf(ftRecord.DSM_Incentive1__c) : 0;
            Decimal dsmIncentive2 = String.isNotBlank(ftRecord.DSM_Incentive2__c) ? Decimal.valueOf(ftRecord.DSM_Incentive2__c) : 0;
            Decimal loanAmount = String.isNotBlank(ftRecord.Loan_Amount__c) ? Decimal.valueOf(ftRecord.Loan_Amount__c) : 0;
            if (String.isNotBlank(ftRecord.Loan_Amount__c)){
                mainDlrIncentivePercentMedian += (mainDlrIncentive / loanAmount);
                subDlrIncentivePercentMedian += (subDlrIncentive / loanAmount);
                dsmIncentive1PercentMedian += (dsmIncentive1 / loanAmount);
                dsmIncentive2PercentMedian += (dsmIncentive2 / loanAmount);
                ++count;
            }
        }
        
        if(count > 0) {
            mainDlrIncentivePercentMedian = ((mainDlrIncentivePercentMedian / count) * 100).setScale(2);
            subDlrIncentivePercentMedian = ((subDlrIncentivePercentMedian / count) * 100).setScale(2);
            dsmIncentive1PercentMedian = ((dsmIncentive1PercentMedian / count) * 100).setScale(2);
            dsmIncentive2PercentMedian = ((dsmIncentive2PercentMedian / count) * 100).setScale(2);
        }

        resultMap.put('mainDlrIncentivePercentMedian', mainDlrIncentivePercentMedian);
        resultMap.put('subDlrIncentivePercentMedian', subDlrIncentivePercentMedian);
        resultMap.put('dsmIncentive1PercentMedian', dsmIncentive1PercentMedian);
        resultMap.put('dsmIncentive2PercentMedian', dsmIncentive2PercentMedian);

        return resultMap;
    }
/*
    * @Method:      manufacturingDateAndYearDecoder
    * @Created by:  Gaurav Rawat
    * @Description: 
    * @Param:       String makeName
    * @Return:      String 
    */
    @AuraEnabled
    public static String manufacturingDateAndYearDecoder(String loanApplicationId, String makeName, String chassisNumber,String modelName){
        List<Chassis_Decoder_Month__c> chassisDecoderMonthList = new List<Chassis_Decoder_Month__c>();
        List<Chassis_Decoder_Year__c> chassisDecoderYearList = new List<Chassis_Decoder_Year__c>();
        String manufactureDate = '';
        String yearCode = '';
        String monthCode = '';
        try {
            if(String.isNotBlank(chassisNumber) && String.isNotBlank(makeName)){
                if(makeName == 'SONALIKA'){
                    yearCode = chassisNumber.substring(4, 5);
                    monthCode = chassisNumber.substring(0, 1);
                } else if(makeName == 'TAFE MOTORS & TRACTORS LTD'){
                    yearCode = chassisNumber.substring(1, 4);
                    monthCode = yearCode;
                }else if(makeName == 'ESCORTS' || makeName == 'ESCORTS FARMTRAC'){
                    String lastTwoCharacters = chassisNumber.substring(chassisNumber.length() - 2);
                    yearCode = lastTwoCharacters.substring(1, 2);
                    monthCode = lastTwoCharacters.substring(0, 1);
                } else if(modelName.contains('SWARAJ')){
                    yearCode = chassisNumber.substring(0, 2);//First 2 character SFTRAC-1780
                    monthCode = chassisNumber.substring(3, 4);//4th Character SFTRAC-1780
                }
            }

            chassisDecoderYearList = [Select Id,Year__c FROM Chassis_Decoder_Year__c WHERE Make_Name__c =: makeName AND Year_Code__c =: yearCode AND Product_Type__c = 'Tractor' LIMIT 1];
            chassisDecoderMonthList = [Select Id,Month__c FROM Chassis_Decoder_Month__c WHERE Make_Name__c =: makeName AND Month_Code__c =: monthCode AND Product_Type__c = 'Tractor' LIMIT 1];
            if(String.isNotBlank(modelName) && modelName.contains('SWARAJ')){
                chassisDecoderYearList = [Select Id,Year__c FROM Chassis_Decoder_Year__c WHERE Make_Name__c ='SWARAJ' AND Year_Code__c =: yearCode AND Product_Type__c = 'Tractor' LIMIT 1];
                chassisDecoderMonthList = [Select Id,Month__c FROM Chassis_Decoder_Month__c WHERE Make_Name__c = 'SWARAJ' AND Month_Code__c =: monthCode AND Product_Type__c = 'Tractor' LIMIT 1];
            }
            if(chassisDecoderMonthList.size() > 0 && chassisDecoderYearList.size() > 0){
                manufactureDate = chassisDecoderYearList[0].Year__c + '-' + chassisDecoderMonthList[0].Month__c;
            }
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('Utilites', 'manufacturingDateAndYearDecoder', 'Apex', e, loanApplicationId);
        }
        return manufactureDate;
    }
    /*
    * @Method:      getMakeList
    * @Created by:  Gaurav Rawat
    * @Description: This method will return Make List.
    * @Param:       String - Product Type
                    String - vehicleSubType
    * @Return:      List<OptionsWrapper> - List of Make records
    */
    @AuraEnabled (cacheable=true)
    public static List<OptionsWrapper> getMakeList(){
        try {
            List<OptionsWrapper> makeList = new List<OptionsWrapper>();
            List<Product2> make = [SELECT Id, Name,Make_Code__c FROM Product2 where Product_Type__c =: System.Label.TRACTORS_AND_FARM_EQUIPMENT AND Type__c = 'Make' AND IsActive = true WITH SECURITY_ENFORCED ORDER by Name ASC]; 
            for(Product2 product : make){
                OptionsWrapper options = new OptionsWrapper();
                options.label = product.Name;
                options.value = product.Make_Code__c;
                makeList.add(options);
            }
            return makeList;
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('Utilities', 'getMakeList', 'Apex', e);
            throw e;  
        }
    }
    /*
    * @Method:      getRelatedModelList
    * @Created by:  Gaurav Rawat
    * @Description: This method will return related Model List.
    * @Param:       String - sMake
                    String - vehicleSubType
    * @Return:      List<OptionsWrapper> - List of Model records
    */
    @AuraEnabled
    public static List<OptionsWrapper> getRelatedModelList(String sMake, String vehicleSubType){
       try {
            List<OptionsWrapper> modelList = new List<OptionsWrapper>();

            List<Product2> models = new List<Product2>();
				
            if(vehicleSubType == 'TRACTOR'){
                models = [SELECT Id, Name, Model_Code__c FROM Product2 where Parent_Product__r.Make_Code__c = :sMake AND Type__c = 'Model' AND Segment__r.Segment_Code__c IN ('TRACFEQ') AND IsActive = true WITH SECURITY_ENFORCED order by Name ASC];
            }else if(vehicleSubType == 'HARVESTER'){
                models = [SELECT Id, Name, Model_Code__c FROM Product2 where Parent_Product__r.Make_Code__c = :sMake AND Type__c = 'Model' AND Segment__r.Segment_Code__c IN ('HARVESTER') AND IsActive = true WITH SECURITY_ENFORCED order by Name ASC];
            }else{
                models = [SELECT Id, Name, Model_Code__c FROM Product2 where Parent_Product__r.Make_Code__c = :sMake AND Type__c = 'Model' AND Segment__r.Segment_Code__c NOT IN ('TRACFEQ', 'HARVESTER') AND IsActive = true WITH SECURITY_ENFORCED order by Name ASC];
            }
            
            for(Product2 product : models){
				OptionsWrapper options = new OptionsWrapper();
				options.label = product.Name;
				options.value = product.Model_Code__c;
				modelList.add(options);
			}
			return modelList;
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('Utilities', 'getRelatedModelList', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);  
        }
    }
    public class OptionsWrapper{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
    }

    /*
    * @Method:      getRelatedVariantList
    * @Created by:  Gaurav Rawat
    * @Description: This method will return related Variant List.
    * @Param:       String - sModel Code
    * @Return:      List<Product2> - List of Variant records
    */
    @AuraEnabled
    public static List<Product2> getRelatedVariantList(String sModel, String loanApplicationId){
        try {
            String agentBLCode = [SELECT Id,Agent_BL_code__c FROM Opportunity WHERE Id =: loanApplicationId LIMIT 1].Agent_BL_code__c;
            String stateCode = '';
            if(String.isNotBlank(agentBLCode)){
                stateCode = getCFDStateCode(agentBLCode,'T');
            }
            List<Product2> productVariantList = new List<Product2>();
            if(String.isNotBlank(stateCode)){
                Set<String> variantCodeSet = new Set<String>();
                for (TBM_Product_Variant_dt__c tbmVariant : [SELECT Product_Variant_Code__c FROM TBM_Product_Variant_dt__c WHERE State_Code__c =: stateCode LIMIT 49000]) {
                    variantCodeSet.add(tbmVariant.Product_Variant_Code__c);
                }
                if(variantCodeSet.size() > 0){
                    productVariantList = [SELECT Id, Name, Variant_Code__c FROM Product2 where Parent_Product__r.Model_Code__c = :sModel AND type__c = 'Variant' AND Variant_Code__c IN:variantCodeSet AND IsActive = true  LIMIT 49000];
                }
            }
            return productVariantList;
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('Utilites', 'getRelatedVariantList', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);  
        }
    }
 /*
    * @Method:      getDealerSubDealerDetails
    * @Created by:  Gaurav Rawat
    * @Description: This method will return Dealer/Subdealer based on the Selected Model
    * @Param:       String - loanApplication ID
    * @Return:      String - Wrapper response data
    */
    @AuraEnabled
    public static String getDealerSubDealerDetails(String sModelName, String sBLCode, String loanApplicationId, String vehicleSubCategory){
        try {
            Opportunity loanApplicantionObj = [Select Id,Vehicle_Type__c From Opportunity Where Id =: loanApplicationId With SECURITY_ENFORCED];
            List<Beneficiary_BlCode__c> benBLCodeRefDealerList = new List<Beneficiary_BlCode__c>();

            //Get Current Products Manufacturer
            List<Product2> manufacturerList= [select id, Manufacturer__c from Product2 where Name=:sModelName AND Type__c='Model' WITH SECURITY_ENFORCED];

            if(!manufacturerList.isEmpty() && loanApplicantionObj.Vehicle_Type__c == 'New'){       
                benBLCodeRefDealerList = [SELECT id, Ben_code__r.name, Ben_code__r.Ben_code__c from Beneficiary_BlCode__c where Ben_code__c in (SELECT Beneficiary_Master__c FROM Beneficiary_Manufacturer__c WHERE Manufacturer__c= :manufacturerList[0].Manufacturer__c) AND Bl_Code_Details__r.Bl_Code__c = :sBLCode and Ben_code__r.Beneficiary__c = 'DLR' and Ben_code__r.Status_Flag__c = 'L' and (Ben_code__r.Used_Flag__c != 'U' OR Ben_code__r.Used_Flag__c = Null) ORDER BY Ben_code__r.name ASC];
            }else if(!manufacturerList.isEmpty() && (vehicleSubCategory == 'UPD' || vehicleSubCategory == 'UPO')){
                benBLCodeRefDealerList = [SELECT id, Ben_code__r.name, Ben_code__r.Ben_code__c from Beneficiary_BlCode__c where  Bl_Code_Details__r.Bl_Code__c = :sBLCode and Ben_code__r.Beneficiary__c = 'DLR' AND (Ben_code__r.Dealership_Nature__c = 'MDR' OR Ben_code__r.Dealership_Nature__c = 'EDR') and Ben_code__r.Status_Flag__c = 'L' and (Ben_code__r.Used_Flag__c != 'N' OR Ben_code__r.Used_Flag__c = Null) WITH SECURITY_ENFORCED ORDER BY Ben_code__r.name ASC];
            }

            if(!benBLCodeRefDealerList.isEmpty()){
                return JSON.serialize(benBLCodeRefDealerList);
            } else {
                return JSON.serialize('');
            }
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('Utilites', 'getDealerSubDealerDetails', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);        
        }
    }

    /*
    * @Method:      getFIDetails
    * @Created by:  Gaurav Rawat
    * @Description: This method will help to get FI Details. 
    * @Param:       String loanAppId , String applicantId
    * @Return:      List<Case>
    */
    @AuraEnabled
    public static List<Case> getFIDetails(string applicantId){
        try{
            List<Case> fiCaseList = new List<Case>();
            fiCaseList = [Select id from Case Where Applicant__c =: applicantId AND RecordType.name = 'FI' AND Type = 'Current Residence FI' LIMIT 1];
            return fiCaseList;
        } catch(exception e){
            ErrorLoggerUtil.logErrorEvent('Utilites', 'getFIDetails', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        } 
    }
    @AuraEnabled
    public static Boolean checkOwner(String loanAppId){
        try {
            List<Opportunity> oppList = new List<Opportunity>();
            String currentUserId = UserInfo.getUserId();
            oppList = [Select Id,OwnerId,Product_Type__c FROM Opportunity WHERE ID=:loanAppId];
            if(!oppList.isEmpty()){
                if(oppList[0].Product_Type__c == 'Tractor' && currentUserId != oppList[0].OwnerId){
                    return true;
                }
                return false;
            }
            return false;
        }
        catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('Utilites', 'getRelatedVariantList', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);  
        }
    }
    @AuraEnabled
    public static String uploadTractorDocument(DocumentWrapper docWrapper){
        try {
            system.debug('docWrapper----'+docWrapper);
            Documents__c doc = new Documents__c();
            doc.RecordTypeId = docWrapper.RecordTypeId;
            doc.Document_Type__c = docWrapper.DocType;
            doc.Opportunity_Relation__c = docWrapper.OppId;
            doc.Applicant__c = docWrapper.AppId;
            doc.is_Active__c = true;
            doc.Name = docWrapper.DocType;
            doc.Additional_Document__c = docWrapper.IsAddDoc;
            insert doc;
            return doc.Id;

        }
        catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('Utilites', 'uploadTractorDocument', 'Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);  
        }
    }
    /*
    * @Method:      getCFDStateCode
    * @Created by:  Gaurav Rawat
    * @Description: This method will be responsible to fetch the CFD Statecode. 
    * @Param:       String blcode,String productCode
    * @Return:      String
    */
    @AuraEnabled
    public static String getCFDStateCode(String blcode,String productCode){
        try{
            List<TBM_Business_Location_Dt__c>  businessLocationList =new List<TBM_Business_Location_Dt__c>([select Id,State_Code__c,Product__c,Bl_Code__c from TBM_Business_Location_Dt__c where Bl_Code__c=:blcode AND Product__c=:productCode]);
            if(!businessLocationList.isEmpty()){
                return businessLocationList[0].State_Code__c;
            }
            return null;
        }
        catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('Utilites', 'getCFDStateCode', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

     /*
    * @Method:      getAssetCategory
    * @Created by:  Gaurav Rawat
    * @Description: This method will be responsible to fetch the asset category code as per Statecode & vehicle variant. 
    * @Param:       Opportunity oppObj,Vehicle_Detail__c vehicleObj
    * @Return:      String
    */
    @AuraEnabled
    public static String getAssetCategory(Opportunity oppObj,Vehicle_Detail__c vehicleObj){
        String assetCategory = '';
        try{
            if(oppObj != null && vehicleObj != null){
                String cfdStateCode = Utilities.getCFDStateCode(oppObj.Agent_BL_code__c, 'T');
                List<TBM_Product_Variant_dt__c> dlpMasterList = new List<TBM_Product_Variant_dt__c>();
                if(String.isNotBlank(cfdStateCode)){
                    dlpMasterList = [SELECT Id, Segment_Grade__c FROM TBM_Product_Variant_dt__c Where State_Code__c =: cfdStateCode  AND Product_Variant_Code__c =: vehicleObj.Variant_Code__c LIMIT 1];
                }
                if(dlpMasterList.size() > 0){
                    assetCategory = dlpMasterList[0].Segment_Grade__c;
                }
            }
        }
        catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('Utilites', 'getAssetCategory', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        return assetCategory;
    }
     /*
    * @Method:      getProfileCode
    * @Created by:  Gaurav Rawat
    * @Description: This method will be responsible to fetch the Profile Code to be passed in CustomerMasterAPI
    * @Param:       profile name
    * @Return:      String
    */
     @AuraEnabled
    public static String getProfileCode(String profile){
        String profileCode = '';
        try{
            List<Profile_Master__c > profileMaster=new List<Profile_Master__c>([SELECT ID,Name,Code__c from Profile_Master__c where Name=:profile Limit 1 ]);
            if(!profileMaster.isEmpty() && profileMaster[0].Code__c!=null ){
                profileCode= profileMaster[0].Code__c;
            }             
        }
        catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('Utilites', 'getProfileCode', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        return profileCode;
    }
    /*
    * @Method:      updateAccountTeamMembers
    * @Created by:  Aakash J
    * @Description: This method will be responsible to update the Account Team Member
    * @Param:       AccountTeamMember
    * @Return:      void
    */
    public static void updateAccountTeamMembers(List<AccountTeamMember> teamMembersToUpdate) {
        if (teamMembersToUpdate != null && !teamMembersToUpdate.isEmpty()) {
            try {
                update teamMembersToUpdate;
                System.debug('Account Team Members updated successfully.');
            } catch (Exception e) {
                System.debug('An error occurred while updating Account Team Members: ' + e.getMessage());
            }
        } else {
            System.debug('No Account Team Members to update.');
        }
    }
    public class DocumentWrapper{
        @AuraEnabled
        public string RecordTypeId{get;set;}
        @AuraEnabled
        public string DocType{get;set;}
        @AuraEnabled
        public string OppId{get;set;}
        @AuraEnabled
        public string AppId{get;set;}
        @AuraEnabled
        public boolean IsAddDoc{get;set;}
    }
    
}