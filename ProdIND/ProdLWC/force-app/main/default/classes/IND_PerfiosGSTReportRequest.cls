/*------------------------------------------------------------
Author:        Bhushan Charde
Company:       Persistent Systems
Description:   This class is wrapper class for the Perfios GST Report API request 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-23-2021      Bhushan Charde       Created
------------------------------------------------------------*/
public class IND_PerfiosGSTReportRequest extends ParentAPIRequest {
    
	public final string type {get;set;}
    public final string PerfiosTransactionId {get;set;}
    public final string maker_Id     {get;set;}
    public final string lead_Id 	   {get;set;}
    public final string reportFormat {get;set;}
    
    
    // @Method:      IND_PerfiosGSTReportRequest
    // @Created by:  Bhushan Charde 
    // @Description: Contructor to initialize the details
    // @Param:       Object applicant Record
    // @Return:      ''
    public IND_PerfiosGSTReportRequest(Applicant__c app){  
        //currently hardcode Id's has been passed these will be changed at the time of handshaking.
        this.type = 'GSTOnline';
        this.PerfiosTransactionId = 'PGVCGESPRWJWATY40UAJ6';  
        this.Lead_Id = app.Opportunity__r.Lead_number__c;  
        this.Maker_Id = IntegrationUtilities.getMakerId();
        this.reportFormat= 'xlsx';
        
        validate(System.Label.GSTReport);
    } 
    
    // @Method:      IND_PerfiosGSTReportRequest
    // @Created by:  Bhushan Charde 
    // @Description: Contructor to initialize the details
    // @Param:       Object applicant Record
    // @Return:      ''
    public IND_PerfiosGSTReportRequest(Income_Details__c app, Opportunity opty, String perfiosId, String reportFormat){  
        this.type = app.Capture_GST_Method__c != null && app.Capture_GST_Method__c == 'Online via link'?'GSTOnline': app.Capture_GST_Method__c == 'Upload online via link'?'GSTUpload' : '';
        this.PerfiosTransactionId = perfiosId;
        this.Lead_Id = opty.Lead_number__c;  
        this.Maker_Id = '1001';//IntegrationUtilities.getMakerId();
        this.reportFormat= reportFormat;
    }  
    
    // @Method:      getHttpRequestHeaders
    // @Created by:  Bhushan Charde 
    // @Description: Method to get the HTTP request header data
    // @Param:       ''
    // @Return:      Header required to callout the service.
    public override Map<String,String> getHttpRequestHeaders(){    
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }
    
    // @Method:      validate
    // @Created by:  Bhushan Charde 
    // @Description: Method to validate the required input details
    // @Param:       Service name
    // @Return:      True - If all the validations are passed.
   
    public override boolean validate(String serviceName){
        
        if(String.isBlank(this.PerfiosTransactionId)){
            throw new IND_Exception(System.Label.perfiosTransactionErrorId);
        }
        if(String.isBlank(this.Lead_Id)){
            throw new IND_Exception(System.Label.Lead_IDError);
        }        
        if(String.isBlank(this.Maker_Id)){
            throw new IND_Exception(System.Label.Maker_IdError);
        }
        
        return true;
    }
}