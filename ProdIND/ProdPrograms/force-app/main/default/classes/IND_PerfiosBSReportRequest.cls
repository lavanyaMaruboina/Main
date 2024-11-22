/*------------------------------------------------------------
Author:        Manish Baldota
Company:       Persistent Systems
Description:   This class is wrapper class for the Perfios Bank Statement Transaction Status API request 
Test Class:    
History
Date            Author              Comments
-------------------------------------------------------------
12-22-2021      Manish Baldota       Created
------------------------------------------------------------*/
public class IND_PerfiosBSReportRequest extends ParentAPIRequest {
    public Payload payload {get;set;}
    // @Method:      IND_PerfiosBSTransactionStatusRequest
    // @Created by:  Manish Baldota
    // @Description: Contructor to initialize the details
    // @Param:       ''
    // @Return:      ''
    public IND_PerfiosBSReportRequest(Applicant__c app, String loanAppId){      
        //Request parameter details are yet to be finalized. Weather we want to store those details or not.
        Payload payloadElement = new Payload();
        payloadElement.perfiosTransactionId = 'L3R71641893000136';
        payloadElement.reportType = 'json';
        payloadElement.txnId = '11012022145302027';
        payloadElement.Maker_Id = IntegrationUtilities.getMakerId();
        
        this.payload = payloadElement;
    } 
    
    // @Method:      IND_PerfiosBSTransactionStatusRequest
    // @Created by:  Manish Baldota
    // @Description: Contructor to initialize the details
    // @Param:       ''
    // @Return:      ''
    public IND_PerfiosBSReportRequest(Income_Details__c app, String perfiosId, String clientTxnId, String reportFormat){      
        Payload payloadElement = new Payload();
        payloadElement.perfiosTransactionId = perfiosId;
        payloadElement.reportType = reportFormat;
        payloadElement.txnId = clientTxnId;
        payloadElement.Maker_Id = '1001';//IntegrationUtilities.getMakerId();
        
        this.payload = payloadElement;
    }  
    // @Method:      getHttpRequestHeaders
    // @Created by:  Manish Baldota
    // @Description: Method to get the HTTP request header data
    // @Param:       ''
    // @Return:      Header required to callout the service.
    public override Map<String,String> getHttpRequestHeaders(){    
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }
    // @Method:      validate
    // @Created by:  Manish Baldota
    // @Description: abstract Method to validate the required input details
    // @Param:       Service name
    // @Return:      True - If all the validations are passed.
    public override boolean validate(String serviceName){
        if(this.payload.txnId  != null && String.isBlank(this.payload.TxnId)){
            throw new IND_Exception(System.Label.TxnIdErrorMsg);
        }
        if(this.payload.perfiosTransactionId  != null && String.isBlank(this.payload.perfiosTransactionId)){
            throw new IND_Exception(System.Label.perfiosTransactionErrorId);
        }
        if(this.payload.reportType  != null && String.isBlank(this.payload.reportType)){
            throw new IND_Exception(System.Label.reportTypeErrorMsg);
        }    
        return true;
    }
    
    public class Payload{
        public string txnId {get;set;}
        public string perfiosTransactionId {get;set;}
        public string reportType  {get;set;}
        public string Maker_Id  {get;set;}
    }
}