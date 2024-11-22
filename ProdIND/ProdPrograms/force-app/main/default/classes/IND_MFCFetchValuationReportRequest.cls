/*------------------------------------------------------------
Author:        Divya Jawale
Company:       Persistent Systems
Description:   This class is wrapper class for the MFC Fetch Valuation Report request 
Test Class:    IND_MFCFetchValuationReportService_Test
History
Date            Author              Comments
-------------------------------------------------------------
04-01-2022      Divya Jawale       Created
------------------------------------------------------------*/
public class IND_MFCFetchValuationReportRequest extends ParentAPIRequest {
    //request paramaters for MFC Fetch Valuation Report request
    public final String Lead_Id {get;set;}
    public final String VehicleRegNo{get;set;}
    /*
@Method:      IND_MFCFetchValuationReportRequest
@Created by:  Divya Jawale
@Description: Contructor to initialize the details
@Param:       Object - RequestWrapper
@Return:      '' 
*/
    public IND_MFCFetchValuationReportRequest (RequestWrapper requestWrapper){
        Boolean isImplement = false;
        if(requestWrapper!=null){
            Applicant__c app = [SELECT Id,applicant_number__c 
                                FROM Applicant__c WHERE Opportunity__c =: requestWrapper.loanApplicationId WITH SECURITY_ENFORCED Limit 1];
            if(String.isNotBlank(requestWrapper.vehicleId)){
                Vehicle_Detail__c vehicleObj = [Select id,Vehicle_SubType__c from Vehicle_Detail__c Where id =: requestWrapper.vehicleId LIMIT 1];
                isImplement = vehicleObj.Vehicle_SubType__c == 'Implement' ?  true: false;
            }
            this.Lead_Id = requestWrapper.leadId==null?'':requestWrapper.leadId+'_'+app.applicant_number__c;  
            this.VehicleRegNo= requestWrapper.vehicleRegisterationNumber==null?'':requestWrapper.vehicleRegisterationNumber;
        }
        validate(System.Label.MFCFetchValuationReportAPI,isImplement);
    }   
    
    /*Method to get the HTTP request header data
@Method:      getHttpRequestHeaders
@Created by:  Divya Jawale
@Description: Method to get the HTTP request header data
@Param:       ''
@Return:      Header required to callout the service.
*/
    public override Map<String,String> getHttpRequestHeaders(){
        //Map to store HTTP request header data
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
        //requestheadermap is used to fetch the request from client
    }    
    
    /*Method to validate the request data
@Method:      validate
@Created by:  Divya Jawale
@Description: Method to validate the required input details
@Param:       Service name
@Return:      True - If all the validations are passed.
*/
    public override boolean validate(String serviceName,Boolean isImplement){
        if(String.isBlank(this.VehicleRegNo) && isImplement == false){
            throw new IND_Exception(System.Label.VehicleRegistrationNumber);
        } 
        if(String.isBlank(this.Lead_Id)){
            throw new IND_Exception(System.Label.LeadId);
        }
        return true;
    }
}