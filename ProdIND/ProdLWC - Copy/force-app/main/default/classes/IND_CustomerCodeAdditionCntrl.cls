/*
Author:        Khushiram
Company:       Persistent Systems
Description:   This class is being used for Customer Code Addition Module.
Test Class:       
History
*/
public with sharing class IND_CustomerCodeAdditionCntrl {
    
    /*
* @Method:      fetchCustomerCodeAdditionData
* @Created by:  Raj Gupta
* @Description: This method will return Customer code data from CustomerCode object.
* @Param:       Current Opportunity Id
* @Return:      return Customer code data from CustomerCode object.   
*/
    @AuraEnabled(Cacheable = true)
    public static List<Customer_Code__c> fetchCustomerCodeAdditionData(String loanApplicantionId){
        try {
            if(String.isNotBlank(loanApplicantionId)){
                List<Customer_Code__c> customerCode = [SELECT Name, Customer_Name__c, IsExposureRecived__c, Flag__c 
                                                       FROM Customer_Code__c 
                                                       WHERE Loan_Application__c =: loanApplicantionId
                                                       WITH SECURITY_ENFORCED];
                return customerCode;
            }
            return null;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent(' IND_CustomerCodeAdditionCntrl ', ' fetchCustomerCodeAdditionData ', 'System.Label.Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    /*
* @Method:      fetchOppourtunity details
* @Created by:  Nidhi Dhote
* @Description: This method will return data from fetch Oppourtunity object.
* @Param:       Current Opportunity Id
* @Return:      return Opportunity code data from Oppourtunity object.   
*/
@AuraEnabled(Cacheable = true)
public static List<Opportunity> fetchOppourtunityData(String loanApplicantionId){
    try {
        if(String.isNotBlank(loanApplicantionId)){
            List<Opportunity> listOpp = [SELECT Id, StageName,LastStageName__c,Total_Exposures_Amount__c
                                                   FROM Opportunity 
                                                   WHERE Id =: loanApplicantionId
                                                   WITH SECURITY_ENFORCED];
            return listOpp;
        }
        return null;
    } catch (Exception e) {
        ErrorLoggerUtil.logErrorEvent(' IND_CustomerCodeAdditionCntrl ', ' fetchOppourtunityData ', 'System.Label.Apex', e);
        throw new AuraHandledException(System.Label.ExceptionMessage);
    }
}
    /*
* @Method:      fetchapplicantData
* @Created by:  Raj Gupta
* @Description: This method will return Applicant data from Applicant object.
* @Param:       Current Opportunity Id
* @Return:      return Applicant data from Applicant object.
*/
    @AuraEnabled(Cacheable = true)
    public static List<Applicant__c> fetchapplicantData(String loanApplicantionId){
        try {
            if(String.isNotBlank(loanApplicantionId)){
                List<Applicant__c> appl = [SELECT Name, Customer_Code__c, IsExposureRecived__c,Opportunity__r.Product_Type__c 
                                            FROM Applicant__c 
                                            WHERE Opportunity__c =: loanApplicantionId AND Customer_Code__c != null
                                            and In_Active_Applicant__c =false
                                            WITH SECURITY_ENFORCED];
                return appl;
            }
            return null;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent(' IND_CustomerCodeAdditionCntrl ', ' fetchapplicantData ', 'System.Label.Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
     
    /*
* @Method:      doCustomerNameSearchCalloutcredit
* @Created by:  Raj Gupta
* @Description: This method will return Customer names.
* @Param:       String - Current Opportunity Id
* @Return:      list<String> - return Customer names list.
*/
    @AuraEnabled(Cacheable = true)
    public static list<String> doCustomerNameSearchCalloutcredit(String loanApplicantionId){
        try {
            list<string> finalList = new list<string>();
            if(String.isNotBlank(loanApplicantionId)){
                List<Applicant__c> applicants = [select id,Customer_Code__c from Applicant__c where Opportunity__c =: loanApplicantionId and In_Active_Applicant__c =false WITH SECURITY_ENFORCED]; 
                List<string> customerCode = new List<string>();
                
                for(Applicant__c app : applicants)
                {
                    customerCode.add(app.Customer_Code__c);
                }  
                System.debug('customerCode -->'+customerCode);
                List<Customer_Code__c> customerCodes = [select Name,Customer_Name__c,flag__c,IsExposureRecived__c from Customer_Code__c where Loan_Application__c =: loanApplicantionId and Name IN: customerCode WITH SECURITY_ENFORCED];
                System.debug('customerCodes -->'+customerCodes);
                List<string> receviedCustomerCodes = new List<string>();
                if(customerCodes.isEmpty())
                {
                    return customerCode;
                }
                else
                {
                    
                    for(Customer_Code__c custcode : customerCodes)
                    {
                        receviedCustomerCodes.add(custcode.Name);
                        if(custcode.IsExposureRecived__c == false) 
                        {
                            finalList.add(custcode.Name); 
                        }
                    }
                    System.debug('receviedCustomerCodes -->'+receviedCustomerCodes);
                    for(String strEle : customerCode) 
                    {
                        if(!receviedCustomerCodes.contains(strEle))
                        {
                            finalList.add(strEle);
                            System.debug('finalList -->'+finalList);
                        }
                    }
                    
                }
                return finalList;
            }
            return null;
        } catch (Exception e) {
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(' IND_CustomerCodeAdditionCntrl ', ' loadCustomerCodeAdditionData ', 'System.Label.Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    /*
* @Method:      checkExposure
* @Created by:  Thilak
* @Description: This method will get response from server and insert details in objects.
* @Param:       Object - Customer Codes, String - Loan Application Id, String - Exposure Response
* @Return:      Boolean
*/
    @AuraEnabled
    public static Boolean checkExposure(object lstCustCodes,String loanApplicantionId,String exposureResponse){
        System.debug('*******exposureResponse'+exposureResponse);
        try {
            if(String.isNotBlank(loanApplicantionId)){
                List<Customer_Code__c> custmrcdesLst = new  List<Customer_Code__c>();
                List<Applicant__c> applicantLst = new  List<Applicant__c>();
                List<Exposure__c> lstCustExpsreInserted = new List<Exposure__c>();
                List<Exposure__c> lstFamlyExpsreInserted = new List<Exposure__c>(); 
                List<Lien_Detail__c> lstLienDetail = new List<Lien_Detail__c>();                
                Set<String> custmrcdes = new Set<String>();
                Map<String,Exposure__c> custExposureMap = new Map<String,Exposure__c>();
                Opportunity opp = [SELECT Id,Lead_number__c 
                                   FROM Opportunity 
                                   WHERE Id =: loanApplicantionId 
                                   WITH SECURITY_ENFORCED];
                String leadnum = opp.Lead_number__c;
                System.debug('****'+leadnum);
                Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(exposureResponse);
                Map<String, Object> response = (Map<String, Object>) m.get('response');
                
                List<Object> content = (List<Object>) response.get('content');                
                for(Object objct: content){
                    Map<String, Object> m8 = (Map<String, Object>) objct;
                    String cc =(String) m8.get('Customer_Code');
                    custmrcdes.add(cc);
                }
                Map<String,Applicant__c> applctMap = new Map<String,Applicant__c>();
                for(Applicant__c app :  [SELECT id,Name,Customer_Code__c,Opportunity__r.id,Applicant_Type__c,
                                        IsExposureRecived__c,IsExposureTriggered__c, Opportunity__r.Product_Type__c
                                         FROM Applicant__c 
                                         WHERE Customer_Code__c IN: custmrcdes AND Opportunity__c=:loanApplicantionId
                                         and In_Active_Applicant__c =false
                                         WITH SECURITY_ENFORCED]) //Updated for SFTRAC-86 Added Opportunity__r.Product_Type__c In Query Modified By: Prashant
                {   app.IsExposureTriggered__c =true;
                    app.IsExposureRecived__c =true;
                    applctMap.put(app.Customer_Code__c,app);
                }
                
                Map<String,Customer_Code__c> custcodeMap = new Map<String,Customer_Code__c>();
                for(Customer_Code__c code : [SELECT id,Name,IsExposureRecived__c,IsExposureTriggered__c
                                             FROM Customer_Code__c 
                                             WHERE Loan_Application__c =: loanApplicantionId 
                                             WITH SECURITY_ENFORCED])
                {
                    code.IsExposureRecived__c =true;
                    code.IsExposureTriggered__c =true;
                    custcodeMap.put(code.Name,code);
                }
                
                for(Object objct: content){
                    Customer_Code__c custcde = new Customer_Code__c();
                    Applicant__c applicant = new Applicant__c();
                    Map<String, Object> m8 = (Map<String, Object>) objct;
                    String cc =(String) m8.get('Customer_Code');
                    //Cheque Details data
                    Map<String, Object> chequeDetails = (Map<String, Object>) m8.get('ChequeDetails');
                    String mindealdate = (String)chequeDetails.get('Min_Deal_Date');
                    Integer cheqRtrnCount = (Integer)chequeDetails.get('ChequeReturnCount');
                    System.debug('cheqRtrnCount  ::'+cheqRtrnCount);
                    System.debug('mindealdate '+mindealdate);
                    if(applctMap.containsKey(cc)){ 
                        System.debug ('applctMap.get(cc).Applicant_Type__c'+applctMap.get(cc).Applicant_Type__c);
                        if(applctMap.get(cc).Applicant_Type__c == 'Borrower' || applctMap.get(cc).Applicant_Type__c == 'Co-borrower' || (applctMap.get(cc).Applicant_Type__c == 'Guarantor' && applctMap.get(cc).Opportunity__r.Product_Type__c == 'Tractor')){  //Updated for SFTRAC-221 by Prashant
                            applicant.Opportunity__c = loanApplicantionId;
                            applicant.Cheque_Return_Count__c = cheqRtrnCount;                            
                            applicant.Id = applctMap.get(cc).Id;
                            applicant.IsExposureRecived__c = true;
                            applicant.IsExposureTriggered__c =true;
                            System.debug('******applicant data '+applicant.name);
                            System.debug( 'strDate :'+mindealdate);
                            if(String.isNotBlank(mindealdate)){
                                String[] applMinDate = mindealdate.split('/');
                                Integer appDate = Integer.valueOf(applMinDate[0]);
                                Integer appMonth = Integer.valueOf(applMinDate[1]);
                                Integer appYear = Integer.valueOf(applMinDate[2]);
                                applicant.Relationship_Since__c = Date.newInstance(appYear, appMonth, appDate); 
                            }
                            applicantLst.add(applicant);
                        }
                    }
                    System.debug('******applicantNO data ');
                    if(custcodeMap.containsKey(cc)){
                        if(String.isNotBlank(mindealdate)){ 
                            String[] strDate = mindealdate.split('/');
                            System.debug( 'strDate :'+strDate);
                            Integer mydate = Integer.valueOf(strDate[0]);
                            Integer mymonth = Integer.valueOf(strDate[1]);
                            Integer myyear = Integer.valueOf(strDate[2]);
                            Datetime myDateTime = Datetime.newInstance(myyear, mymonth, mydate,0 , 0, 0); 
                            custcde.Min_Deal_Date__c = myDateTime;
                        }
                        custcde.Cheque_Return_Count__c = cheqRtrnCount;
                        custcde.Loan_Application__c = loanApplicantionId; 
                        custcde.IsExposureRecived__c = true;
                        custcde.IsExposureTriggered__c = true;
                        custcde.CustomerCodeExtId__c = cc;
                        System.debug(' cc code 395'+cc);
                        custcde.Id = custcodeMap.get(cc).Id;                        
                        custmrcdesLst.add(custcde);
                    }                    
                }
                
                System.debug('custmrcdesLst ::'+custmrcdesLst);
                if(!custmrcdesLst.isEmpty()){
                    if(Schema.sObjectType.Customer_Code__c.isUpdateable()) {
                        UPDATE custmrcdesLst;
                    } else {
                        throw new AuraHandledException(system.label.Exposure_Message2);
                    }
                }
                System.debug('*******all Customer Codes updated');
                
                System.debug('applicantLst ::'+applicantLst);
                if(!applicantLst.isEmpty()){
                    if(Schema.sObjectType.Applicant__c.isUpdateable()) {
                        UPDATE applicantLst;
                    } else {
                        throw new AuraHandledException(system.label.Exposure_Message1);
                    }
                }
                System.debug('*******all Applicants updated');
                
                for(Object objct: content){
                    Map<String, Object> m8 = (Map<String, Object>) objct;
                    String cc =(String) m8.get('Customer_Code');
                    //Customer Exposure data
                    List<Object> customerExposure = (List<Object>) m8.get('Customer_Exposure'); 
                    for(Object obj: customerExposure){
                        Boolean isCustomerCodeFound =false;
                        Map<String, Object> m9 = (Map<String, Object>) obj; 
                        System.debug('*******custcde.id'+cc);
                        Exposure__c custexpsure = new Exposure__c();
                        if(custcodeMap.containsKey(cc) ){ 
                            isCustomerCodeFound =true;
                            custexpsure.Customer_Code__c =custcodeMap.get(cc).id; 
                            custexpsure.Type__c = 'Additional Customer';
                        }else if(applctMap.containsKey(cc)){ 
                            isCustomerCodeFound =true;
                            custexpsure.Applicant__c =  applctMap.get(cc).id;
                            //Start: Updated For SFTRAC-86 Modified By : Prashant
                            if(applctMap.get(cc).Opportunity__r.Product_Type__c == 'Tractor'){ 
                                custexpsure.Type__c =  applctMap.get(cc).Applicant_Type__c =='Borrower' ? 'Borrower Exposure' : applctMap.get(cc).Applicant_Type__c =='Co-borrower' ? 'Co-Borrower Exposure' : applctMap.get(cc).Applicant_Type__c =='Guarantor' ? 'Guarantor Exposure' :'';
                            }else{
                            custexpsure.Type__c =  applctMap.get(cc).Applicant_Type__c =='Borrower' ? 'Borrower Exposure' : applctMap.get(cc).Applicant_Type__c =='Co-borrower' ? 'Co-Borrower Exposure' : '';
                            }
                            //End: Updated For SFTRAC-86 Modified By : Prashant
                        } 
                        if(isCustomerCodeFound){
                            custexpsure.Loan_Application__c = loanApplicantionId; 
                            custexpsure.ExposureHeader__c = 'Customer Exposure';
                            custexpsure.Write_Off__c = (Integer) m9.get('Write_Off'); 
                            custexpsure.Finance_Amt__c =(Double) m9.get('Finance_Amt');
                            custexpsure.SOH__c = (Double) m9.get('SOH');
                            custexpsure.Sanctioned_Amt__c =(Decimal) m9.get('Sanctioned_Amt');
                            custexpsure.used__c = (String) m9.get('used');
                            custexpsure.Status_Flag__c = (String) m9.get('Status_Flag');
                            custexpsure.Mor2__c = (String) m9.get('Mor2');
                            custexpsure.Mor1__c = (String) m9.get('Mor1');
                            custexpsure.IB_Seasoning__c = (String) m9.get('IBLSeasoning');
                            custexpsure.Deal_Stage__c =(String) m9.get('Deal_Stage');
                            custexpsure.Deal_No__c =(String) m9.get('Deal_No');        
                            custexpsure.RCNo__c = (String) m9.get('RCNo');                    
                            custexpsure.Exposure_Type__c = (String) m9.get('Status_Flag') == 'L'?'Existing' :(String) m9.get('Status_Flag') == 'Z'?'Closed':'';
                            if((String) m9.get('Deal_No') != null && leadnum == (String) m9.get('Deal_No')){
                                custexpsure.Exposure_Type__c = 'Current';
                            }
                            custexpsure.Name =(String) m9.get('Deal_No');
                            custexpsure.Product_Variant_Name__c =(String) m9.get('Product_Variant_Name');
                            custexpsure.Product__c = (String) m9.get('Product');  
                            custexpsure.Deal_Ageing__c = (Decimal) m9.get('Deal_Ageing');
                            custexpsure.Current_Demand__c = (Decimal) m9.get('Current_Demand');
                            custexpsure.AD__c = (Decimal) m9.get('AD'); 
                            custexpsure.Over_Due__c = (Double) m9.get('Over_Due');
                            custexpsure.Guaranteed_SOH__c = (Double) m9.get('Guaranteed_SOH');
                            custexpsure.Guaranteed_OD__c = (Double) m9.get('Guaranteed_OD');
                            custexpsure.DPD__c = (Double) m9.get('DPD'); 
                            custexpsure.Waiver__c = (Integer) m9.get('Waiver');
                            custexpsure.Peak_Delay__c = (Integer) m9.get('Peak_Delay');
                            custexpsure.PD__c = (Integer) m9.get('PD');
                            custexpsure.Average_Delay__c = (Integer) m9.get('Average_Delay'); 
                            String custdate = (String)m9.get('Deal_Date');
                            if(String.isNotBlank(custdate)){
                                custdate = custdate.replace('T',' ');
                                custexpsure.Deal_Date__c = datetime.valueOf(custdate); 
                            }
                            lstCustExpsreInserted.add(custexpsure);
                            System.debug('*******custexpsure inserted');
                        } 
                    }
                }
                
                System.debug('lstCustExpsreInserted ::'+lstCustExpsreInserted);
                if(!lstCustExpsreInserted.isEmpty()){
                    if(Schema.sObjectType.Exposure__c.isCreateable()) {
                        INSERT lstCustExpsreInserted;
                    } else {
                        throw new AuraHandledException(system.label.Exposure_Message3);
                    }
                }
                System.debug('*******all Customer expsures inserted');
                
                for(Object objct: content){
                    Map<String, Object> m8 = (Map<String, Object>) objct;
                    String cc =(String) m8.get('Customer_Code');
                    //Family Exposure data
                    Map<String, Object> familyExposure = (Map<String, Object>) m8.get('Family_Exposure');
                    //RS2 DATA
                    List<Object> RS2 = (List<Object>) familyExposure.get('RS2');
                    Map<String, Object> m10 = (Map<String, Object>) RS2.get(0); 
                    String customer_Relation =(String) m10.get('Customer_Relation'); 
                    String customer =(String) m10.get('Customer');
                    //RS1 DATA
                    List<Object> RS1 = (List<Object>) familyExposure.get('RS1'); 
                    for(Object obj : RS1){
                        Map<String, Object> m11 = (Map<String, Object>) obj;                         
                        Exposure__c famlyexpsure = new Exposure__c();
                        if(custcodeMap.containsKey(cc)){
                            famlyexpsure.Customer_Code__c =custcodeMap.get(cc).id;                            
                        }else if(applctMap.containsKey(cc)){ 
                            famlyexpsure.Applicant__c =  applctMap.get(cc).id;
                        }                        
                        famlyexpsure.Loan_Application__c = loanApplicantionId; 
                        famlyexpsure.Type__c = 'Family Exposure';                         
                        famlyexpsure.Exposure_Type__c = (String) m11.get('Status_Flag') == 'L'?'Existing' :(String) m11.get('Status_Flag') == 'Z'?'Closed':'';
                        famlyexpsure.Finance_Amt__c =(Double) m11.get('Finance_Amt');
                        famlyexpsure.SOH__c = (Double) m11.get('SOH'); 
                        //famlyexpsure.Manufacture_Date__c = (Date) m11.get('Manufacture_Date');
                        famlyexpsure.amount_paid__c = (Double) m11.get('Amt_Paid');
                        famlyexpsure.Agreement_amount__c = (Double) m11.get('Agreement_Amt'); 
                        famlyexpsure.Write_Off__c = (Integer) m11.get('Write_Off');   
                        famlyexpsure.used__c = (String) m11.get('used');
                        famlyexpsure.Status_Flag__c = (String) m11.get('Status_Flag'); 
                        famlyexpsure.IB_Seasoning__c = (String) m11.get('IBLSeasoning');
                        famlyexpsure.Deal_Stage__c =(String) m11.get('Deal_Stage');
                        famlyexpsure.Deal_No__c =(String) m11.get('Deal_No');
                        famlyexpsure.Name =(String) m11.get('Deal_No');
                        famlyexpsure.Product_Variant_Name__c =(String) m11.get('Product_Variant_Name');
                        famlyexpsure.Product__c = (String) m11.get('Product');  
                        famlyexpsure.Deal_Ageing__c = (Decimal) m11.get('Deal_Ageing'); 
                        famlyexpsure.AD__c = (Decimal) m11.get('AD'); 
                        famlyexpsure.Over_Due__c = (Double) m11.get('Over_Due');
                        famlyexpsure.Guaranteed_SOH__c = (Double) m11.get('Guaranteed_SOH');
                        famlyexpsure.Guaranteed_OD__c = (Double) m11.get('Guaranteed_OD');
                        famlyexpsure.DPD__c = (Double) m11.get('DPD'); 
                        famlyexpsure.Waiver__c = (Integer) m11.get('Waiver');
                        famlyexpsure.Peak_Delay__c = (Integer) m11.get('Peak_Delay');
                        famlyexpsure.PD__c = (Integer) m11.get('PD');
                        famlyexpsure.Average_Delay__c = (Integer) m11.get('Average_Delay');
                        famlyexpsure.RCNo__c = (String) m11.get('RCNo');
                        String famlydate = (String)m11.get('Deal_Date');
                        if(String.isNotBlank(famlydate)){
                            famlydate = famlydate.replace('T',' ');
                            famlyexpsure.Deal_Date__c = datetime.valueOf(famlydate);
                        }
                        System.debug('*******famlyexpsure inserted');
                        lstFamlyExpsreInserted.add(famlyexpsure);
                    }
                }               
                
                System.debug('lstFamlyExpsreInserted ::'+lstFamlyExpsreInserted);
                if(!lstFamlyExpsreInserted.isEmpty()){
                    if(Schema.sObjectType.Exposure__c.isCreateable()) {
                        INSERT lstFamlyExpsreInserted;
                    } else {
                        throw new AuraHandledException(system.label.Exposure_Message3);
                    }
                }
                System.debug('*******all Family expsures inserted');
                
                for(Exposure__c exp : [SELECT Id,Deal_No__c 
                                       FROM Exposure__c 
                                       WHERE Loan_Application__c =: loanApplicantionId 
                                       and Type__c IN ('Borrower Exposure','Additional Customer','Co-Borrower Exposure')
                                       WITH SECURITY_ENFORCED])
                {
                    custExposureMap.put(exp.Deal_No__c, exp);
                }


                for(Object objct: content){
                    Map<String, Object> m8 = (Map<String, Object>) objct;
                    String cc =(String) m8.get('Customer_Code'); 
                    //Line  data 
                    List<Object> lien = (List<Object>) m8.get('Lien'); 
                    System.debug('*******lien'+lien);
                    for(Object obj: lien){
                        Map<String, Object> m12 = (Map<String, Object>) obj;
                        List<Object> table = (List<Object>) m12.get('Table');  
                        for(Object obj1: table){
                            Map<String, Object> m13 = (Map<String, Object>) obj1;
                            String dealno = (String) m13.get('Deal_No');
                            String lienMakerDate = (String) m13.get('Lien_Maker_Date');
                            Lien_Detail__c liendtil= new Lien_Detail__c();                           
                            liendtil.Source_Deal_No__c = (String) m13.get('Source_Deal_No');
                            liendtil.Lien_Type__c = (String) m13.get('Lien_Type');
                            liendtil.Lien_Request_By__c = (String) m13.get('Lien_Request_By');
                            liendtil.Name = (String) m13.get('Lien_No');
                            liendtil.Lien_Marking_Reason__c = (String) m13.get('Lien_Marking_Reason'); 
                            String lienMarkingPeriod = (String)m13.get('Lien_Marking_Period');
                            if(String.isNotBlank(lienMarkingPeriod)){
                                lienMarkingPeriod = lienMarkingPeriod.substringBefore('T');
                                liendtil.Lien_Marking_Period__c = date.valueOf(lienMarkingPeriod);
                            } 
                            String lienMakerDate1 = (String)m13.get('Lien_Maker_Date');
                            if(string.isNotBlank(lienMakerDate1)){
                                lienMakerDate1 = lienMakerDate1.substringBefore('T');
                                liendtil.Lien_Maker_Date__c = date.valueOf(lienMakerDate1);
                            } 
                            //liendtil.Deal_No__c = dealno;
                            System.debug('custExposureMap :'+custExposureMap);
                            if(custExposureMap.containsKey(dealno)){
                                liendtil.Deal_No__c = custExposureMap.get(dealno).Id;    
                                lstLienDetail.add(liendtil);
                            }else{
                                System.debug(' Liens did not inserted' +lstLienDetail);
                            }
                        } 
                    }
                }
                
                
                System.debug('lstLienDetail ::'+lstLienDetail);
                if(!lstLienDetail.isEmpty()){
                    if(Schema.sObjectType.Lien_Detail__c.isCreateable()) {
                        INSERT lstLienDetail;
                    } else {
                        throw new AuraHandledException(system.label.Exposure_Message4);
                    }
                }
                System.debug('*******all lien Details inserted');                

                return true;
            }
            return false;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent(' IND_CustomerCodeAdditionCntrl ', ' checkExposure ', 'System.Label.Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    /*
* @Method:      checkRetryExhausted
* @Created by:  Raj Gupta
* @Description: This method will check retry attemps
* @Param:       String - current Applicantion ID
* @Return:      json -check the retry attemps
*/
    @AuraEnabled
    public static Boolean checkRetryExhausted(String loanApplicationId){
        try{
            if(String.isNotBlank(loanApplicationId)){
                List<Retry_Count__c> retryCountList = [SELECT Id, Count__c
                                                        FROM Retry_Count__c 
                                                        WHERE Loan_Application_Id__c =: loanApplicationId AND Service_Name__c = 'checkExposure' 
                                                        WITH SECURITY_ENFORCED];
                if(!retryCountList.isEmpty()) {
                    System_Constant_custom_metadata__mdt metadata = System_Constant_custom_metadata__mdt.getInstance('Exposure'); 
                    //If number of attempts are greater than predefined number of attempts.
                    if(retryCountList[0].Count__c >= metadata.Number_Of_Attempts__c) {
                        return true;
                    }
                }
            }
            return false;
        }
        catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_CustomerCodeAdditionCntrl' ,System.Label.CheckRetryExhausted, System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    /*
* @Method:      retryCountIncrease
* @Created by:  Raj Gupta
* @Description: This method increment the retry attemps count.
* @Param:       String - loan Applicantion ID
* @Return:      Boolean
*/
    @AuraEnabled
    public static Boolean retryCountIncrease(String loanApplicationId){
        try{
            if(String.isNotBlank(loanApplicationId)){
                List<Retry_Count__c> retryCountList = [SELECT Id, Count__c
                                                        FROM Retry_Count__c 
                                                        WHERE Loan_Application_Id__c =: loanApplicationId AND Service_Name__c = 'checkExposure' 
                                                        WITH SECURITY_ENFORCED];
                if(!retryCountList.isEmpty()) {
                    System_Constant_custom_metadata__mdt metadata = System_Constant_custom_metadata__mdt.getInstance('Exposure'); 
                    //If number of attempts are greater than predefined number of attempts.
                    if(retryCountList[0].Count__c < metadata.Number_Of_Attempts__c) {
                        retryCountList[0].Count__c += 1;
                        if (Schema.sObjectType.Retry_Count__c.isUpdateable()){
                            UPDATE retryCountList;
                        } else {
                            throw new AuraHandledException('Not able to update Retry Count');
                        }
                        if(retryCountList[0].Count__c >= metadata.Number_Of_Attempts__c) {
                            return true;
                        }
                    }
                }
                else{
                    Retry_Count__c retryCount = new Retry_Count__c();
                    retryCount.Loan_Application_Id__c = loanApplicationId;
                    retryCount.Service_Name__c = 'checkExposure';
                    retryCount.Count__c = 1;
                    if(Schema.sObjectType.Retry_Count__c.isCreateable()) {
                        INSERT retryCount;
                    } else {
                        throw new AuraHandledException('Not able to insert Retry Count');
                    }
                }
            }
            return false;
        }
        catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_CustomerCodeAdditionCntrl','retryCountIncrease', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    /*
* @Method:      saveNamesearchdetailsAPI 
* @Created by:  Thilak
* @Description: This method will save the details captured on the UI.
* @Param:       String - Loan Application Id, String - Payload
* @Return:      Boolean
*/
    @AuraEnabled
    public static Boolean saveNamesearchdetails(String loanApplicantionId, String payload){
        try {
            System.debug('Start of  the saveNamesearchdetails with Values ---> '+loanApplicantionId+' and Payload '+payload);
            if(String.isNotBlank(payload)){
                System.debug('***'+payload);
                Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(payload); 
                Map<String, Object> response = (Map<String, Object>) m.get('response');
                List<Object> content = (List<Object>) response.get('content'); 
                Map<String, Object> m8 = (Map<String, Object>) content.get(0);
                String cc =(String) m8.get('Customer_Code');  
                String cName = (String) m8.get('Customer_Name'); 
                String cFlag =  (String) m8.get('Flag'); 
                String cDescription =(String) m8.get('Description'); 
                
                Customer_Code__c custcde = new Customer_Code__c(); 
                custcde.IsExposureRecived__c = False; 
                custcde.Name = cc;
                custcde.CustomerCodeExtId__c = cc;
                custcde.Customer_Name__c = cName;
                custcde.Flag__c = cFlag; 
                System.debug('***loanApplicantionId'+loanApplicantionId);
                custcde.Loan_Application__c = loanApplicantionId;
                System.debug('***saveNamesearchdetails*');
                if(Schema.sObjectType.Customer_Code__c.isCreateable()) {
                    INSERT custcde;
                    return true;
                } else {
                    throw new AuraHandledException('Not able to insert Customer Code');
                }
            } 
            return false;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent(' IND_CustomerCodeAdditionCntrl ', ' checkExposure ', 'System.Label.Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    /*
* @Method:      deleteCustomerCode 
* @Created by:  shahkomeni mohammad
* @Description: This method will delete customer code and related records.
* @Param:       String - Customer code
* @Return:      Boolean - Success/Failure
*/
    @AuraEnabled
    public static Boolean deleteCustomerCode(String loanApplicantionId, String customerCode) {
        try {
            Map<Id, Customer_Code__c> mapCustomerCodes = new Map<Id,Customer_Code__c>();
            Map<Id, Exposure__c> mapExposures = new Map<Id, Exposure__c>();
            Map<Id, Lien_Detail__c> mapLienDetails = new Map<Id, Lien_Detail__c>();
            Decimal BorrowerExposureAmount=0, CoBorrowerExposureAmount=0, OtherExposureAmount=0,BankExpAmt=0;
            if(String.isNotBlank(loanApplicantionId) && String.isNotBlank(customerCode)){
                
                mapCustomerCodes = new Map<Id,Customer_Code__c>([SELECT Id 
                                                                 FROM Customer_Code__c 
                                                                 WHERE Loan_Application__c =: loanApplicantionId AND Name =: customerCode 
                                                                 WITH SECURITY_ENFORCED]);
                if(!mapCustomerCodes.isEmpty()) {
                    mapExposures = new Map<Id, Exposure__c>([SELECT Id ,Type__c,SOH__c
                                                             FROM Exposure__c 
                                                             WHERE Customer_Code__c IN: mapCustomerCodes.keySet() 
                                                             WITH SECURITY_ENFORCED]);
                    if(!mapExposures.isEmpty()) {
                        mapLienDetails = new Map<Id, Lien_Detail__c>([SELECT Id 
                                                                      FROM Lien_Detail__c 
                                                                      WHERE Deal_No__c IN: mapExposures.keySet() 
                                                                      WITH SECURITY_ENFORCED]);
                    }
                }
            }
            if(!mapExposures.isEmpty()){
                for(Exposure__c exposureRecord : mapExposures.values()){
                    if(exposureRecord.Type__c  == system.Label.Borrower_Exposure){ 
                        BorrowerExposureAmount = exposureRecord.SOH__c !=null ? BorrowerExposureAmount + (Decimal)exposureRecord.SOH__c:BorrowerExposureAmount;
                    }
                    if(exposureRecord.Type__c  == system.Label.Co_Borrower_Exposure){
                        CoBorrowerExposureAmount = exposureRecord.SOH__c != null ? CoBorrowerExposureAmount + (Decimal)exposureRecord.SOH__c:CoBorrowerExposureAmount;
                    }
                    if(exposureRecord.Type__c  == system.Label.Additional_Customer){
                        OtherExposureAmount = exposureRecord.SOH__c != null ? OtherExposureAmount + (Decimal)exposureRecord.SOH__c:exposureRecord.SOH__c;
                    }
                    if(exposureRecord.Type__c  == system.Label.Bank_Exposure){
                        BankExpAmt = exposureRecord.Sanctioned_Amt__c != null? BankExpAmt + (Decimal)exposureRecord.Sanctioned_Amt__c:BankExpAmt;
                    } 
                }
                List<opportunity> oppList = [SELECT ID,Existing_Borrowers_Exposure_Amt__c,Existing_Co_Borrowers_Exposure_Amt__c,Existing_Others_Exposure_Amt__c,Total_Bank_Exposure__c,Total_Exposures_Amount__c from Opportunity where ID =: loanApplicantionId  WITH SECURITY_ENFORCED LIMIT 1];
                if(oppList.size()> 0){
                    oppList[0].Existing_Borrowers_Exposure_Amt__c = oppList[0].Existing_Borrowers_Exposure_Amt__c - BorrowerExposureAmount;
                    oppList[0].Existing_Co_Borrowers_Exposure_Amt__c = oppList[0].Existing_Co_Borrowers_Exposure_Amt__c - CoBorrowerExposureAmount;
                    oppList[0].Existing_Others_Exposure_Amt__c = oppList[0].Existing_Others_Exposure_Amt__c - OtherExposureAmount;
                    oppList[0].Total_Bank_Exposure__c = oppList[0].Total_Bank_Exposure__c - BankExpAmt;
                    oppList[0].Total_Exposures_Amount__c = oppList[0].Total_Exposures_Amount__c - (BorrowerExposureAmount + CoBorrowerExposureAmount + OtherExposureAmount + BankExpAmt );
                    update oppList;
                }
                
            }
            // Delete records
            if(!mapLienDetails.isEmpty() && Schema.sObjectType.Lien_Detail__c.isDeletable()) {
                DELETE mapLienDetails.values();
            }
            if(!mapExposures.isEmpty() && Schema.sObjectType.Exposure__c.isDeletable()) {
                DELETE mapExposures.values();
            }
            if(!mapCustomerCodes.isEmpty() && Schema.sObjectType.Customer_Code__c.isDeletable()) {
                DELETE mapCustomerCodes.values();
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent(' IND_CustomerCodeAdditionCntrl ', ' deleteCustomerCode ', 'System.Label.Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    @AuraEnabled
    public static string getTotalExpousreOfLead(String loanApplicantionId){
        try {
            List<opportunity> oppList = [SELECT ID,Existing_Borrowers_Exposure_Amt__c,Existing_Co_Borrowers_Exposure_Amt__c,Existing_Others_Exposure_Amt__c,Total_Bank_Exposure__c,Total_Exposures_Amount__c from Opportunity where ID =: loanApplicantionId  WITH SECURITY_ENFORCED LIMIT 1];
            if(oppList.size()> 0){
                return String.valueOf(oppList[0].Total_Exposures_Amount__c);
            }
            return null;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent(' IND_CustomerCodeAdditionCntrl ', ' getTotalExpousreOfLead ', 'System.Label.Apex', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
 //CISP_4656
    @AuraEnabled
    public static void saveExposureAPITriggered(String loanApplicantionId){
        try {
            List<Opportunity> oppList = [SELECT ID, IsExposureAPITriggered__c from Opportunity where Id =: loanApplicantionId limit 1];
            if(!oppList.isEmpty()){
                oppList[0].IsExposureAPITriggered__c = true;
                update oppList; 
            }

        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent(' IND_CustomerCodeAdditionCntrl ', ' saveExposureAPITriggered ', 'System.Label.Apex', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
}