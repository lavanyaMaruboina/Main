/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is wrapper class for the DocAuth Create Applicant Request
Test Class: IND_DocAuthCreateApplicantService_Test
History
Date            Author              Comments
------------------------------------------------------------- 
19-11-2021    Satyam More            Created
------------------------------------------------------------*/

public class IND_DocAuthCreateApplicantRequest extends ParentAPIRequest {
    
    //request paramaters for DocAuth Create Applicant Request
    public final String Lead_Id{get;set;}
    public final String FName{get;set;}
    public final String MName{get;set;}
    public final String LName{get;set;}
    public final String Maker_Id{get;set;}
    
    //constructor
    // @Method:      IND_DocAuthCreateApplicantRequest
    // @Created by:  Satyam More
    // @Description: Contructor to initialize the details
    // @Param:       Object Applicant Object
    // @Return:      ''
    
    public IND_DocAuthCreateApplicantRequest(Applicant__c app, String loanAppId){
        Boolean nonIndividualBorrower = false;
        if( app != null){
            nonIndividualBorrower = (app.Opportunity__r.Product_Type__c == System.Label.Tractor && app.Opportunity__r.Customer_Type__c == 'Non-Individual' && app.Applicant_Type__c == System.Label.Borrower) ? true : false;
            this.Lead_Id = app.Opportunity__r.Lead_Number__c + '_' + app.applicant_number__c;//CISP-2879
            this.FName = app.Customer_First_Name__c;
            this.MName = '';
            this.LName = app.Customer_Last_Name__c == null ? '' : app.Customer_Last_Name__c; 
            this.Maker_Id = IntegrationUtilities.getMakerId();
            //fetching details from Applicant Object
        }
        validate(System.Label.CreateApplicant,nonIndividualBorrower);
    }
    
    //Method to get the HTTP request header data
    // @Method:      getHttpRequestHeaders
    // @Created by:  Satyam More
    // @Description: Method to get the HTTP request header data
    // @Param:       ''
    // @Return:      Header required to callout the service.
    
    //Method to get the HTTP request header data
    public override Map<String,String> getHttpRequestHeaders(){    
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }
    
    //Method to validate the request data
    // @Method:      getHttpRequestHeaders
    // @Created by:  Satyam More
    // @Description: Method to validate the required input details
    // @Param:       Service name
    // @Return:      True - If all the validations are passed.
    
    public override boolean validate(String serviceName, Boolean nonIndividualBorrower){
        
        if(String.isBlank(this.FName)){
            throw new IND_Exception(System.Label.FirstName);
        }
        if(String.isBlank(this.LName) && nonIndividualBorrower == false){
            throw new IND_Exception(System.Label.LastName);
        }
        if(String.isBlank(this.Maker_Id)){
            throw new IND_Exception(System.Label.MakerId);
        }
        return true;
    }
    
}