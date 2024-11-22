/*------------------------------------------------------------
Author:        Aman Mundhada
Company:       Salesforce
Description:   This class is request class for the Gating Screening-Check Eligibility Request 
Test Class:    IND_GatingScreeningServiceTest
History
Date            Author              Comments
-------------------------------------------------------------
16-12-2021      Aman Mundhada       Created
------------------------------------------------------------*/
public with sharing class IND_GatingScreeningRequest extends ParentAPIRequest  {
    
    //request paramaters for gating screening-check eligibility request
    public final String Noof_Coborrowers{get;set;}
    public final String Vehicle_Type{get;set;}
    public final String Maker_Id {get;set;}  
    public final String Loan_Amount {get;set;}
    public Borrower Borrower;
    public CoBorrower CoBorrower;
    
    public class Borrower{
        public final String Lead_Id{get;set;}
        public final String Date_of_Birth {get;set;}
        public final String Customer_PAN{get;set;}
        public final String Customer_CIN{get;set;}
        public final String Income{get;set;}       
        public final String parentDealNo{get;set;}  // INDI-4709 Added a new attribute.
    }
    
    public class CoBorrower{
        public final String Lead_Id{get;set;}
        public final String Date_of_Birth {get;set;}
        public final String Customer_PAN{get;set;}
        public final String Customer_CIN{get;set;}
        public final String Income{get;set;}   
        public final String parentDealNo{get;set;}  // INDI-4709 Added a new attribute.
        
    }
    
    //constructor
    // @Method:      IND_GatingScreeningRequest
    // @Created by:  Aman Mundhada
    // @Description: Contructor to initialize the details
    // @Param:       RequestWrapper requestWrapper
    // @Return:      ''    
    public IND_GatingScreeningRequest(RequestWrapper requestWrapper){  
        if(requestWrapper!=null){     
            this.Noof_Coborrowers=requestWrapper.noOfCoborrowers==null?'':requestWrapper.noOfCoborrowers;
            this.Maker_Id=IntegrationUtilities.getMakerId();
            this.Loan_Amount = requestWrapper.loanAmount== null ? '' : requestWrapper.loanAmount;  
            this.Vehicle_Type = requestWrapper.vehicleType== null ? '' : requestWrapper.vehicleType;        

            this.borrower = new Borrower();
            if(requestWrapper.dOB!=null){
                Datetime dOB = requestWrapper.dOB;
                borrower.Date_of_Birth=dOB.format('yyyy-MM-dd');
            }
            else 
            {
                borrower.Date_of_Birth='';
            }                        
            borrower.Income=requestWrapper.income==null?'0':requestWrapper.income;
            borrower.Lead_Id= requestWrapper.leadId==null?'':requestWrapper.leadId+'_'+requestWrapper.borrowerApplicantNumber;
            system.debug('requestWrapper.borrowerForm60Present'+requestWrapper.borrowerForm60Present);
            borrower.Customer_PAN=requestWrapper.borrowerForm60Present=='true'?null:requestWrapper.panNumber;
            borrower.Customer_CIN= requestWrapper.cinNo==null?'':requestWrapper.cinNo;	
            borrower.parentDealNo= requestWrapper.parentDealNo==null?'':requestWrapper.parentDealNo; // INDI-4709
            
            if(requestWrapper.noOfActiveCoborrowers!=null && (Integer.valueOf(requestWrapper.noOfActiveCoborrowers) > 0)){
                this.coBorrower = new CoBorrower();
                system.debug('requestWrapper::'+JSON.serialize(requestWrapper));
                if(requestWrapper.coBorrowerDob!=null){
                    Datetime dOB = requestWrapper.coBorrowerDob;
                    coBorrower.Date_of_Birth=dOB.format('yyyy-MM-dd');
                }
                else 
                {
                    coBorrower.Date_of_Birth='';
                }   
                coBorrower.Lead_Id= requestWrapper.leadId==null?'':requestWrapper.leadId+'_'+requestWrapper.coBorrowerApplicantNumber;
                coBorrower.Customer_PAN=requestWrapper.coBorrowerForm60Present=='true'?null:requestWrapper.coBorrowerPanNumber;
                coBorrower.Customer_CIN= requestWrapper.coBorrowerCinNo==null?'':requestWrapper.coBorrowerCinNo;	
                coBorrower.Income=requestWrapper.coBorrowerIncome==null?'':requestWrapper.coBorrowerIncome;
                coBorrower.parentDealNo=requestWrapper.parentDealNo==null?'':requestWrapper.parentDealNo;// INDI-4709
            } 
        }
        validate(System.Label.IblBre);
    }
    
    //Method to get the HTTP request header data
    // @Method:      getHttpRequestHeaders
    // @Created by:  Aman Mundhada
    // @Description: Method to get the HTTP request header data
    // @Param:       ''
    // @Return:      Header required to callout the service.
    public override Map<String,String> getHttpRequestHeaders(){
        //Map to store HTTP request header data
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }
    
    //Method to validate the request data
    // @Method:      validate
    // @Created by:  Aman Mundhada
    // @Description: Method to validate the required input details
    // @Param:       Service name
    // @Return:      True - If all the validations are passed.
    public override boolean validate(String serviceName){
        if(String.isBlank(this.Noof_Coborrowers)){
            throw new IND_Exception(System.Label.NoofCoborrowers);
        }
        if(String.isBlank(this.Maker_Id)){            
            throw new IND_Exception(System.Label.MakerId);
        }
        if(String.isBlank(this.Vehicle_Type)){
            throw new IND_Exception(System.Label.VehicleType);
        }  
        if(String.isBlank(this.borrower.Lead_Id)){
            throw new IND_Exception(System.Label.LeadId);
        }        
        if(String.isBlank(this.borrower.Date_of_Birth)){
            throw new IND_Exception(System.Label.DateOfBirth);
        }      

        if(String.isBlank(this.borrower.Income)){
            throw new IND_Exception(System.Label.Incomemessage);
        }  
        
        if(this.coBorrower!=null)
        {  
            if(String.isBlank(this.coBorrower.Lead_Id)){
                throw new IND_Exception(System.Label.LeadId);
            }        
            if(String.isBlank(this.coBorrower.Date_of_Birth)){
                
                throw new IND_Exception(System.Label.DateOfBirth);
            }       
        }
        return true;
    }
}