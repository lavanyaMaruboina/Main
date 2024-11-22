/*
Author:        Pravallika K
Company:       Persistent Systems
Description:   Wrapper Class for Applicant record Id,Flag=OTP and Loan Application Id
Test Class: 

History
Date            Author              Comments
-------------------------------------------------------------
22-02-2022      Pravallika K        Created
------------------------------------------------------------*/
public class IND_SmsInputWrapperClass {
    /*
    * @Method Name: smsWrapper
    * @Created by: 	Pravallika K
    * @Description: Method to wrap applicant recordId, Flag=OTP and Loan Application
    * @Input:	List of applicants
    * @Return:  String 
    */
    public static String smsWrapper(List<Applicant__c> applicant){
        
        List<wrapperclass> wrapper_lst=new List<wrapperclass>();
        String smsStr1;
        for(Applicant__c app_new:applicant){
            wrapperclass obj=new wrapperclass(app_new);
            wrapper_lst.add(obj);
            system.debug('obj==>'+obj);
            smsStr1 = JSON.serialize(obj);
            system.debug('smsStr1==>'+smsStr1);
        }
      

        //String smsStr = JSON.serialize(wrapper_lst);
        //Object obj= IntegrationEngine.doSmsGatewayCallout(smsStr);
        return smsStr1;
    }
    
public class wrapperclass{
        
        public string loanApplicationId;
        public string flag;
        public string applicantId;
        
        public wrapperclass(Applicant__c app){
            applicantId = app.id;
            flag = 'LAS';
            loanApplicationId= app.Opportunity__c;  
        }   
    }    
}