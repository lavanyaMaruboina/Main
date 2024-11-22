/*
Author:        Pravallika K
Company:       Persistent Systems
Description:   This class is invoked in the flow SMSApexAction to send SMS Consent Reminder
				after 24,48,72 hours if consent not received
Test Class: 

History
Date            Author              Comments
-------------------------------------------------------------
22-02-2022      Pravallika K        Created
------------------------------------------------------------*/
public class IND_SmsConsentReminder {
    
    /*
    * @Method Name: smsCallOut
    * @Created by: 	Pravallika K
    * @Description: Flow Invoked Method to call doSmsGatewayCallout to send consent message
    * @Input:	List<List> of applicant ids sent from Flow
    * @Return:      List of applicants
    */
    @InvocableMethod(label='Send SMS for consent' description='To send sms for consent from Insurance Details') 
    public static List<Applicant__c> smsCallOut(List<List<Applicant__c>> ids){
        system.debug('Method called');
        List<Applicant__c> app_list = new List<Applicant__c>();
//        Applicant__c applicant = app_list.get(0);
        try{
            //IND_SmsInputWrapperClass wrap = new IND_SmsInputWrapperClass();
            for(List<Applicant__c> id : ids){
                String app_str = IND_SmsInputWrapperClass.smsWrapper(id);
                system.debug('SMS String : '+app_str);
               // Object obj= IntegrationEngine.doSmsGatewayCallout(app_str);
               Object obj= IntegrationEngine.doSmsGatewayAPI(app_str); 
            
                for(Applicant__c innerList : id){
                    app_list.add(innerList);
                }
            }
        }
        catch(Exception e){             
            Error_Log__c errorLogRecord = ErrorLoggerUtil.logError(System.Label.IND_SmsConsentReminder, ' smsCallOut ', System.Label.Apex, e);
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
            insert errorLogRecord;
            }
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
        return app_list;           
    }

}