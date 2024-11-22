/*------------------------------------------------------------
Author:        Chowdesha N
Company:       Persistent Systems
Description:   This class is wrapper class for the Ind_CSRVahanFIwaiver API request 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-28-2021      Chowdesha N       Created
02-22-2021      Bhushan Charde    Modified - change in request
------------------------------------------------------------*/
public class Ind_CSRVahanFIwaiverRequest extends ParentAPIRequest {
   
	public final String Product {get;set;}
	public final String VehicleType {get;set;}
	public final String Maker_Id {get;set;}
	public List<ApplicationDetails> ApplicationDetails;

	public class ApplicationDetails {
		public final String ApplicationType {get;set;}
		public final String Lead_Id {get;set;}
		public final String RiskBand {get;set;}
		public final String NIP {get;set;}
		public final String Present_Address_In_Kyc {get;set;}
	}
    

    // @Method:      IND_CSRVahanFIwaiverRequest
    // @Created by:  Chowdesha N
    // @Description: Contructor to initialize the details
    // @Param:       Object applicant Record
    // @Return:      ''
    public IND_CSRVahanFIwaiverRequest(RequestWrapper requestWrapper,List<Applicant__c> appList){  
        
        ApplicationDetails = new List<ApplicationDetails>();
        ApplicationDetails dtl;
        
        for(Applicant__c app : appList){
            dtl = new ApplicationDetails();
            dtl.Lead_Id = app.Opportunity__r.Lead_number__c +'_'+ app.applicant_number__c;
            dtl.NIP = app.Applicant_Type__c=='Borrower'? requestWrapper.borrowerNIP:requestWrapper.coBorrowerNIP;
            dtl.Present_Address_in_Kyc = app.Applicant_Type__c=='Borrower'? requestWrapper.borrowerPresentAddress:requestWrapper.coBorrowerPresentAddress;
            if ((!String.IsBlank(app.Scorecard_Decision__c)) && app.Scorecard_Decision__c!=null && app.Scorecard_Decision__c.equalsIgnoreCase('Dark Green')){
			dtl.RiskBand = '01';
			}
        else if ((!String.IsBlank(app.Scorecard_Decision__c)) && app.Scorecard_Decision__c!=null && app.Scorecard_Decision__c.equalsIgnoreCase('Light Green')){
			dtl.RiskBand = '02';
			}
         else if ((!String.IsBlank(app.Scorecard_Decision__c)) && app.Scorecard_Decision__c!=null && app.Scorecard_Decision__c.equalsIgnoreCase('Yellow')){
			dtl.RiskBand = '03';
			}
         else if ((!String.IsBlank(app.Scorecard_Decision__c)) && app.Scorecard_Decision__c!=null && app.Scorecard_Decision__c.equalsIgnoreCase('Orange')){
			dtl.RiskBand = '04';
			}
         else if ((!String.IsBlank(app.Scorecard_Decision__c)) && app.Scorecard_Decision__c!=null && app.Scorecard_Decision__c.equalsIgnoreCase('Red')){
			dtl.RiskBand = '05';
			}
        else{
             dtl.RiskBand='';
        }
            if(app.Applicant_Type__c == 'Co-borrower'){
                dtl.ApplicationType = IntegrationUtilities.getCoborrowerName(app.Applicant_Type__c);
            }else{
                dtl.ApplicationType = app.Applicant_Type__c;
            }
            this.ApplicationDetails.add(dtl);
        }
        this.Maker_Id = IntegrationUtilities.getMakerId();
        this.Product = appList[0].Opportunity__r.Product_Type__c == 'Two Wheeler'?'H' : appList[0].Opportunity__r.Product_Type__c == 'Passenger Vehicles' ?'C' : appList[0].Opportunity__r.Product_Type__c == 'Tractor' ?'T':'';
        this.VehicleType = appList[0].Opportunity__r.Vehicle_Type__c == 'New'?'N' : appList[0].Opportunity__r.Vehicle_Type__c == 'Used' ?'U' : appList[0].Opportunity__r.Vehicle_Type__c == 'Refinance' ?'R' : '';
        
		validate(System.Label.CSRVahanFIwaiver);
    }    
    
    // @Method:      getHttpRequestHeaders
    // @Created by:  Chowdesha N
    // @Description: Method to get the HTTP request header data
    // @Param:       ''
    // @Return:      Header required to callout the service.
    public override Map<String,String> getHttpRequestHeaders(){    
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }
    
    // @Method:      validate
    // @Created by:  Chowdesha N
    // @Description: Method to validate the required input details
    // @Param:       Service name
    // @Return:      True - If all the validations are passed.
    
    public override boolean validate(String serviceName){
        for (ApplicationDetails appDetails :this.ApplicationDetails){
            if(String.isBlank(appDetails.Lead_Id)){
			throw new IND_Exception(System.Label.LeadId);
        }  
        
         if(String.isBlank(appDetails.NIP)){
			throw new IND_Exception(System.Label.NIP);
        }
       
    	  if(String.isBlank(appDetails.Present_Address_in_Kyc)){
			throw new IND_Exception(System.Label.Present_Address_in_Kyc);
        }
    	   if(String.isBlank(appDetails.RiskBand)){
			throw new IND_Exception(System.Label.RiskBand);
        }
        }
      	  if(String.isBlank(this.Maker_Id)){
			throw new IND_Exception(System.Label.MakerId );
         }
        
       	  if(String.isBlank(this.Product)){
			throw new IND_Exception(System.Label.Product);
        }
        
      	  if(String.isBlank(this.VehicleType)){
			throw new IND_Exception(System.Label.VehicleType);
        }
        return true;
    }
}