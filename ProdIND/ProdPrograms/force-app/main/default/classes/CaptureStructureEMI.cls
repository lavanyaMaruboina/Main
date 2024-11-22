/*------------------------------------------------------------
 Author:        Poonam Tilokani
 Company:       Manras
 Description:   CaptureStructureEMI is used to insert and get structured emi records. 
 Apex Class :   CaptureStructureEMI
 Test Class:    CaptureStructureEMITest
------------------------------------------------------------*/

public with sharing class CaptureStructureEMI {
   
     /*
   * @Method:      isFTStructuredType
   * @Created by:  Poonam Tilokani
   * @Description: This method is used for check final term installment type is structured or not.
   * @Param:       String - Loan Application ID
   * @Return:      Boolean
   */
 
    @AuraEnabled
    public static Boolean isFTStructuredType(string loanApplicationId, String dealId){
        try{
            Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED];
            List<Final_Term__c> ftList=[SELECT Id, Loan_Application__c, Installment_Type__c FROM Final_Term__c where Loan_Application__c =:loanApplicationId AND Installment_Type__c ='Structured' WITH SECURITY_ENFORCED];
            if(oppRec.Product_Type__c == System.Label.Tractor){
                List<Vehicle_Detail__c> VehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
                ftList=[SELECT Id, Loan_Application__c, Installment_Type__c 
                            FROM Final_Term__c 
                            WHERE Loan_Application__c =:loanApplicationId AND Installment_Type__c ='Structured' AND Vehicle_Detail__c =: VehicleLst[0].Id
                            WITH SECURITY_ENFORCED];
            }else{
                ftList=[SELECT Id, Loan_Application__c, Installment_Type__c 
                            FROM Final_Term__c 
                            WHERE Loan_Application__c =:loanApplicationId AND Installment_Type__c ='Structured' 
                            WITH SECURITY_ENFORCED];
            }
            if(ftList!=null && ftList.size()>0){
                return true;
            }
            return false;
        }catch(Exception e){
             ErrorLoggerUtil.logErrorEvent('CaptureStructureEMI', 'isFTStructuredType', System.Label.Apex, e,loanApplicationId);
            throw new IND_Exception(e.getMessage());
        }
    }
   
     /*
   * @Method:      getLADetails
   * @Created by:  Poonam Tilokani
   * @Description: This method is used to get Loan application record.
   * @Param:       String - Loan Application ID
   * @Return:      Opportunity (Loan Application)
   */

    @AuraEnabled
    public static Opportunity getLADetails(string loanApplicationId){
        system.debug('INSIDE::'+loanApplicationId);
        List<Opportunity> oppList=new List<Opportunity>();
        try {
             oppList=[Select id,Finance_Amount__c,Amount,CRM_IRR__c,Required_Tenure__c from Opportunity where id=:loanApplicationId  WITH SECURITY_ENFORCED];
            if(oppList!=null){
                return oppList[0];
            }
            
        } catch(Exception e){
             ErrorLoggerUtil.logErrorEvent('CaptureStructureEMI', 'getLADetails', System.Label.Apex, e,loanApplicationId);
            throw new IND_Exception(e.getMessage());
        }
        return null;
    }
    
      /*
   * @Method:      getFinalTermRecord
   * @Created by:  Poonam Tilokani
   * @Description: This method is used to get Final term record and insert first structured emi record.
   * @Param:       String - Loan Application ID
   * @Return:      Final_Term__c 
   */

    @AuraEnabled
    public static Final_Term__c getFinalTermRecord(string loanApplicationId, String dealId, String vehicleId,Boolean l1stage){
        List<Final_Term__c> finalTermList = new List<Final_Term__c>();
        List<Structered_EMI__c> firstList = new List<Structered_EMI__c>();
        try {
            Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED];
            if(oppRec.Product_Type__c == System.Label.Tractor){
                if(l1stage == true){ //SFTRAC-570
                   /* firstList = [SELECT Id,From_Month__c,To_Month__c,EMI_Amount__c,Number_of_Installments__c 
                    FROM Structered_EMI__c 
                    WHERE Loan_Application__c=:loanApplicationId AND From_Month__c = 1 AND Vehicle_Detail__c =: vehicleId
                    WITH SECURITY_ENFORCED]; */
                    finalTermList = [SELECT Holiday_period__c,EMI_Amount__c, Id,CRM_IRR__c, Loan_Amount__c, Tenure__c, Loan_Application__c,Loan_Application__r.Total_Funded_Premium__c,Required_CRM_IRR__c 
                         FROM Final_Term__c 
                         WHERE Loan_Application__c =:loanApplicationId AND Vehicle_Detail__c =:vehicleId
                         WITH SECURITY_ENFORCED];
                }else{
                firstList = [SELECT Id,From_Month__c,To_Month__c,EMI_Amount__c,Number_of_Installments__c 
                               FROM Structered_EMI__c 
                               WHERE Loan_Application__c=:loanApplicationId AND From_Month__c = 1 AND Deal_Number__c =: dealId
                               WITH SECURITY_ENFORCED];
                List<Vehicle_Detail__c> VehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
                finalTermList = [SELECT Holiday_period__c,EMI_Amount__c, Id,CRM_IRR__c, Loan_Amount__c, Tenure__c, Loan_Application__c,Loan_Application__r.Total_Funded_Premium__c 
                                    FROM Final_Term__c 
                                    WHERE Loan_Application__c =:loanApplicationId AND Vehicle_Detail__c =: VehicleLst[0].Id
                                    WITH SECURITY_ENFORCED];
            }
            }else{
                firstList = [SELECT Id,From_Month__c,To_Month__c,EMI_Amount__c,Number_of_Installments__c 
                               FROM Structered_EMI__c 
                               WHERE Loan_Application__c=:loanApplicationId AND From_Month__c = 1 
                               WITH SECURITY_ENFORCED];
                finalTermList = [SELECT Holiday_period__c,EMI_Amount__c, Id,CRM_IRR__c, Loan_Amount__c, Tenure__c, Loan_Application__c,Loan_Application__r.Total_Funded_Premium__c 
                                    FROM Final_Term__c 
                                    WHERE Loan_Application__c =:loanApplicationId 
                                    WITH SECURITY_ENFORCED];
            }
            
            if(firstList.size()>0){
                delete firstList;
            }
            if(finalTermList!=null){
                Structered_EMI__c st = new Structered_EMI__c(From_Month__c =1,To_Month__c = 1,Number_of_Installments__c = 1,EMI_Amount__c = finalTermList[0].EMI_Amount__c,
                                                             Loan_Application__c=loanApplicationId);
                
                if(oppRec.Product_Type__c == System.Label.Tractor){
                    if(dealId!=null)
                    st.Deal_Number__c = dealId;
                    if(vehicleId!=null)
                    st.Vehicle_Detail__c = vehicleId;
                }
                if(oppRec.Product_Type__c == System.Label.Tractor && !l1stage){ //SFTRAC-714
                    upsert st;
                }else if(oppRec.Product_Type__c != System.Label.Tractor){
                    upsert st;
                }
                return finalTermList[0];
            }
            
        } catch(Exception e){
             ErrorLoggerUtil.logErrorEvent('CaptureStructureEMI', 'getFinalTermRecord', System.Label.Apex, e,loanApplicationId);
            throw new IND_Exception(e.getMessage());
        }
        return null;
    }

    /*
   * @Method:      getFirstMonthStructeredEMI
   * @Created by:  Poonam Tilokani
   * @Description: This method is used to get First structured emi record.
   * @Param:       String - Loan Application ID
   * @Return:      Structered_EMI__c 
   */

    @AuraEnabled
    public static Structered_EMI__c getFirstMonthStructeredEMI(string loanApplicationId, String dealId,String vehicleId,Boolean l1stage){
        List<Structered_EMI__c> firstList=new List<Structered_EMI__c>();
        try {
            Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED];
            if(oppRec.Product_Type__c == System.Label.Tractor){
                if(l1stage == true){
                    firstList = [SELECT Id,From_Month__c,To_Month__c,EMI_Amount__c,Number_of_Installments__c 
                                FROM Structered_EMI__c 
                                WHERE Loan_Application__c=:loanApplicationId AND From_Month__c=1 AND Vehicle_Detail__c =:vehicleId
                                WITH SECURITY_ENFORCED];
                }else{
                firstList = [SELECT Id,From_Month__c,To_Month__c,EMI_Amount__c,Number_of_Installments__c 
                                FROM Structered_EMI__c 
                                WHERE Loan_Application__c=:loanApplicationId AND From_Month__c=1 AND Deal_Number__c =: dealId
                                WITH SECURITY_ENFORCED];
                }
            }else{
                firstList = [SELECT Id,From_Month__c,To_Month__c,EMI_Amount__c,Number_of_Installments__c 
                                FROM Structered_EMI__c 
                                WHERE Loan_Application__c=:loanApplicationId AND From_Month__c=1 
                                WITH SECURITY_ENFORCED];
            }
            
            if(firstList!=null){
                return firstList[0];
            }
            
        }catch(Exception e){
             ErrorLoggerUtil.logErrorEvent('CaptureStructureEMI', 'getFirstMonthStructeredEMI', System.Label.Apex, e,loanApplicationId);
            throw new IND_Exception(e.getMessage());
        }
        return null;
    }
     /*
       * @Method:      getStructeredEMIexceptFirst
       * @Created by:  Poonam Tilokani
       * @Description: This method is used to get structured emi records except first record.
       * @Param:       String - Loan Application ID
       * @Return:      List<Structered_EMI__c> 
       */

    @AuraEnabled
    public static List<Structered_EMI__c> getStructeredEMIexceptFirst(string loanApplicationId, String dealId, String vehicleId, Boolean l1stage){
        try {
            List<Structered_EMI__c> emiList = new List<Structered_EMI__c>();
            Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanApplicationId WITH SECURITY_ENFORCED];
            if(oppRec.Product_Type__c == System.Label.Tractor){
                if(l1stage == true){
                    emiList = [SELECT Id,From_Month__c,To_Month__c,Number_of_Installments__c,EMI_Amount__c 
                            FROM Structered_EMI__c 
                            WHERE Loan_Application__c=:loanApplicationId AND /*From_Month__c!=1 AND */ Vehicle_Detail__c =:vehicleId
                            WITH SECURITY_ENFORCED order by From_Month__c ASC];
                }else{
                emiList = [SELECT Id,From_Month__c,To_Month__c,Number_of_Installments__c,EMI_Amount__c 
                            FROM Structered_EMI__c 
                            WHERE Loan_Application__c=:loanApplicationId AND From_Month__c!=1 AND Deal_Number__c =: dealId
                            WITH SECURITY_ENFORCED order by From_Month__c ASC];
                }
            }else{
                emiList = [SELECT Id,From_Month__c,To_Month__c,Number_of_Installments__c,EMI_Amount__c 
                            FROM Structered_EMI__c 
                            WHERE Loan_Application__c=:loanApplicationId AND From_Month__c!=1 
                            WITH SECURITY_ENFORCED order by From_Month__c ASC];
            }
            if(emiList!=null){
                return emiList;
            }
            
        } catch(Exception e){
             ErrorLoggerUtil.logErrorEvent('CaptureStructureEMI', 'getStructeredEMIexceptFirst', System.Label.Apex, e,loanApplicationId);
            throw new IND_Exception(e.getMessage());
        }
        return null;
    }
     /*
       * @Method:      addupdateStructuredEMI
       * @Description: This method is used to upsert structured emi records except first record.
       * @Param:       String itemList(structured emi record list) , String - Loan Application ID, boolean - Submitted flag
       * @Return:      boolean 
       */

    @AuraEnabled
    public static boolean addupdateStructuredEMI(string itemList,String recordId,boolean submittedFalg, String dealId, String vehicleId){
        
        System.debug('The LIST::'+itemList);
        //ResultWrapper result=(ResultWrapper)JSON.deserialize(itemList, ResultWrapper.class);
        List<Object> results = (List<Object>)JSON.deserializeUntyped(itemList);
        System.debug('The LIST::'+results);
        try{
            Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:recordId WITH SECURITY_ENFORCED];
            List<Structered_EMI__c> strList=new List<Structered_EMI__c>();
            if(results!=null){
                for(Object o:results){
                    Map<String, Object> itemMap = (Map<String, Object>)o;
                    Structered_EMI__c st=new Structered_EMI__c();
                    Decimal fromMonth;
                    if(getTypeX(itemMap.get('fromMonth'))=='String'){
                        String d=(String)itemMap.get('fromMonth');
                        fromMonth=Decimal.Valueof(d);
                      }else{
                        fromMonth=(Decimal)itemMap.get('fromMonth');
                      }
                    st.From_Month__c=fromMonth;
                    Decimal toMonth;
                    if(getTypeX(itemMap.get('toMonth'))=='String'){
                        String d=(String)itemMap.get('toMonth');
                        toMonth=Decimal.Valueof(d);
                      }else{
                        toMonth=(Decimal)itemMap.get('toMonth');
                      }
                    st.To_Month__c=toMonth;
                    Decimal installment;
                    if(getTypeX(itemMap.get('installments'))=='String'){
                        String d=(String)itemMap.get('installments');
                        installment=Decimal.Valueof(d);
                      }else{
                        installment=(Decimal)itemMap.get('installments');
                      }
                    st.Number_of_Installments__c=installment;
                    Decimal emi;
                    System.debug('TYPE::'+getTypeX(itemMap.get('emi')));
                    if(getTypeX(itemMap.get('emi'))=='String'){
                      String d=(String)itemMap.get('emi');
                      emi=Decimal.Valueof(d);
                    }else{
                      emi=(Decimal)itemMap.get('emi');
                    }
                    st.EMI_Amount__c=emi;
                    st.Loan_Application__c=recordId;
                    if(getTypeX(itemMap.get('sfId'))=='String'){
                        String d=(String)itemMap.get('sfId');
                        if(!String.isBlank(d)){
                            st.Id=d;
                        }
                    }else{
                        if(itemMap.get('sfId')!=null){
                            st.Id=(Id)itemMap.get('sfId');
                         }
                    }

                    if(oppRec.Product_Type__c == System.Label.Tractor){
                        if(String.isNotBlank(vehicleId)){
                            st.Vehicle_Detail__c = vehicleId;
                        }
                        if(String.isNotBlank(dealId)){ 
                            st.Deal_Number__c = dealId;
                        }else{
                            List<Vehicle_Detail__c> vehicleLst = new List<Vehicle_Detail__c>([Select Id,Deal_Number__c from Vehicle_Detail__c Where Id =: vehicleId LIMIT 1]);
                            if(vehicleLst.size() > 0){
                                dealId = vehicleLst[0].Deal_Number__c;
                                st.Deal_Number__c = dealId;
                            }
                        }
                    }
                    
                    strList.add(st);
                }
            }
            if(strList!=null){
                createTrackingHistory(recordId,submittedFalg,dealId);
                upsert strList Id;
                return true;
            }
            return false;
    }catch(Exception e){
             ErrorLoggerUtil.logErrorEvent('CaptureStructureEMI', 'addupdateStructuredEMI', System.Label.Apex, e,recordId);
            throw new IND_Exception(e.getMessage());
        }
        
    }
    public static String getTypeX(Object o) {
        if(o==null)      {               return '';  }            
        String                              result  = 'Object';     
        if(o instanceof Id)  {             return 'Id';}
        if(o instanceof String)   {        return 'String';}
        if(o instanceof Integer)  {        return 'Integer';}
        if(o instanceof Decimal)   {        return 'Decimal';}
        //if(o instanceof Double)    {         return 'Double';}
        //if(o instanceof List<object>)   {    return 'List';}
        try {                                                   
        } catch (Exception e) {
            result = e.getMessage().substringAfter('from runtime type ').substringBefore(' ');
            
        }
        return result;
    }

    Public static void createTrackingHistory(String lAId,boolean submittedFalg, String dealId){
        try{
            List<Loan_Application_Transaction_History__c> lATList=[Select id,Name,Submitted_Flag__c from Loan_Application_Transaction_History__c where Loan_Application_ID__c=:LAId and Screen__c='Structured EMI' ANd Module__c = 'Post Sanction Checks and Documentation' AND Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
            if(lATList.size()==0){
                system.debug('Inside if:');
                Loan_Application_Transaction_History__c lt=new Loan_Application_Transaction_History__c();
                //lt.Name='Structured EMI';
                lt.Screen__c='Structured EMI';
                lt.Submitted_Flag__c=true;
                lt.Module__c = 'Post Sanction Checks and Documentation';
                lt.Loan_Application_ID__c=lAId;
                insert lt;
            }
            if(lATList.size()>0){
                lATList[0].Submitted_Flag__c = submittedFalg;
                update lATList;
            }
        }catch(Exception e){
             ErrorLoggerUtil.logErrorEvent('CaptureStructureEMI', 'createTrackingHistory', System.Label.Apex, e,lAId);
            throw new IND_Exception(e.getMessage());
        }
    }
     /*
       * @Method:      checkIfReadOnly
       * @Description: This method is used to check weather structured emi record submitted or not.
       * @Param:       String - Loan Application ID
       * @Return:      boolean 
       */
    @AuraEnabled
    Public static boolean checkIfReadOnly(String lAId, String dealId){
        try{
            List<Loan_Application_Transaction_History__c> lATList=[Select id,Name,Submitted_Flag__c from Loan_Application_Transaction_History__c where Loan_Application_ID__c=:LAId  and screen__c='Structured EMI' AND Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
            if(lATList!=null && lATList.size()>0){
                return (lATList[0].Submitted_Flag__c);
            }
            return false;
        }catch(Exception e){
             ErrorLoggerUtil.logErrorEvent('CaptureStructureEMI', 'checkIfReadOnly', System.Label.Apex, e,lAId);
            throw new IND_Exception(e.getMessage());
        }
    }

    // CISP-20786 start
    @AuraEnabled
    public static boolean updateStructuredEMI(string itemList,String recordId){
        System.debug('The LIST::'+itemList);
        List<Object> results = (List<Object>)JSON.deserializeUntyped(itemList);
        System.debug('The LIST::'+results);
        try{
            Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:recordId WITH SECURITY_ENFORCED];
            List<Structered_EMI__c> strList=new List<Structered_EMI__c>();
            if(results!=null){
                for(Object o:results){
                    Map<String, Object> itemMap = (Map<String, Object>)o;
                    Structered_EMI__c st=new Structered_EMI__c();
                    Decimal fromMonth;
                    if(getTypeX(itemMap.get('fromMonth'))=='String'){
                        String d=(String)itemMap.get('fromMonth');
                        fromMonth=Decimal.Valueof(d);
                      }else{
                        fromMonth=(Decimal)itemMap.get('fromMonth');
                      }
                    st.From_Month__c=fromMonth;
                    Decimal toMonth;
                    if(getTypeX(itemMap.get('toMonth'))=='String'){
                        String d=(String)itemMap.get('toMonth');
                        toMonth=Decimal.Valueof(d);
                      }else{
                        toMonth=(Decimal)itemMap.get('toMonth');
                      }
                    st.To_Month__c=toMonth;
                    Decimal installment;
                    if(getTypeX(itemMap.get('installments'))=='String'){
                        String d=(String)itemMap.get('installments');
                        installment=Decimal.Valueof(d);
                      }else{
                        installment=(Decimal)itemMap.get('installments');
                      }
                    st.Number_of_Installments__c=installment;
                    Decimal emi;
                    System.debug('TYPE::'+getTypeX(itemMap.get('emi')));
                    if(getTypeX(itemMap.get('emi'))=='String'){
                      String d=(String)itemMap.get('emi');
                      if(String.isNotBlank(d)){
                          emi=Decimal.Valueof(d);
                      }
                    }else{
                      emi=(Decimal)itemMap.get('emi');
                    }
                    st.EMI_Amount__c=emi;
                    if(oppRec.Product_Type__c == System.Label.PassengerVehicles){
                        Date dueDateVal;
                        if(getTypeX(itemMap.get('dueDate'))=='String'){
                          String d=(String)itemMap.get('dueDate');
                          List<String> dateList = d.split('-');
                          dueDateVal= date.newinstance(Integer.valueOf(dateList[2]), Integer.valueOf(dateList[1]), Integer.valueOf(dateList[0]));
                        }else{
                            String d=(String)itemMap.get('dueDate');
                            List<String> dateList = d.split('-');
                            dueDateVal = date.newinstance(Integer.valueOf(dateList[2]), Integer.valueOf(dateList[1]), Integer.valueOf(dateList[0]));
                        }
                        st.EMI_Due_Date__c=dueDateVal;
                    }
                    st.Loan_Application__c=recordId;
                    if(getTypeX(itemMap.get('sfId'))=='String'){
                        String d=(String)itemMap.get('sfId');
                        if(!String.isBlank(d)){
                            st.Id=d;
                        }
                    }else{
                        if(itemMap.get('sfId')!=null){
                            st.Id=(Id)itemMap.get('sfId');
                         }
                    }
                    
                    strList.add(st);
                }
            }
            if(strList!=null){
                upsert strList Id;
                return true;
            }
            return false;
    }catch(Exception e){
             ErrorLoggerUtil.logErrorEvent('CaptureStructureEMI', 'updateStructuredEMI', System.Label.Apex, e,recordId);
            throw new IND_Exception(e.getMessage());
        }
        
    }

}