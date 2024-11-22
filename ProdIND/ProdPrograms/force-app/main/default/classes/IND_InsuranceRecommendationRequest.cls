/*------------------------------------------------------------
Author:      Santhosh Mothe
Company:     Persistent Systems
Description: This class is wrapper class for the Insurance Recommendation Request
Test Class:  IND_InsuranceRecommendationService_Test
History
Date            Author              Comments
------------------------------------------------------------- 
12-01-2022    Santhosh Mothe            Created
------------------------------------------------------------*/
public class IND_InsuranceRecommendationRequest extends ParentAPIRequest{
//request paramaters for insurance premium request
    public final String Application_No{get;set;}
    public final String Vehicle_ID{get;set;}
    public final String Borrower_Type{get;set;}
    public final String Age {get;set;}
    public final String Gender {get;set;}
    public final String Product {get;set;}
    public final String Vehicle_Category{get;set;}
    public final String Variant{get;set;}
    public final String Fin_Amount{get;set;}
    public final String Balance_Available{get;set;}
    public final String Tenure{get;set;}
    public final String Agreement_Value{get;set;}
    public final String Motor_Expiry_Date{get;set;}
    public final String Motor_Premium{get;set;}
    public final String D2C{get;set;}
    public final String Periodicity {get;set;}//SFTRAC-629
    
    /*
    * @Method Name: Constructor
    * @Created by: 	Santhosh Mothe.
    * @Description: create the InsurancePremium
    * @Param:       Object Request Wrapper 
    * @Return:      void
    */
    public IND_InsuranceRecommendationRequest(RequestWrapper requestwrapper){
        Boolean istractor = false;
        if( requestwrapper != null){
            this.Application_No = requestwrapper.applicationNo==null?'':requestwrapper.applicationNo ; 
            this.Vehicle_ID = requestwrapper.vehicleId==null?'':requestwrapper.vehicleId ; 
            this.Borrower_Type = requestwrapper.Borrower_Type != null && requestwrapper.Borrower_Type =='Borrower' ?'C' : requestwrapper.Borrower_Type =='Co-Borrower' ? 'CB' : 'C'; 
            this.Age = requestwrapper.age==null?'':requestwrapper.age ; 
            this.Gender = requestwrapper.gender != null && requestwrapper.gender =='Male' ? 'M' : requestwrapper.gender =='Female' ? 'F':'' ; 
            //this.Product = requestwrapper.Product != null && requestwrapper.Product == 'Two Wheeler' ?'H': requestwrapper.Product == 'TW Refinance' ? 'S' : requestwrapper.Product == 'Car' ? 'C' :'' ; 
            //this.Vehicle_Category = requestwrapper.Vehicle_Category != null && requestwrapper.Vehicle_Category == 'New' ?'N': requestwrapper.Vehicle_Category == 'Internal Refinance'? 'R' : requestwrapper.Vehicle_Category == 'Used'? 'U' : requestwrapper.Vehicle_Category == 'External Refinance'? 'R' || ''  ;
            
            if(requestwrapper.Vehicle_Category != null){
                if(requestwrapper.Vehicle_Category == 'New'){
                    this.Vehicle_Category = 'N';
                }
                else if(requestwrapper.Vehicle_Category == 'Internal Refinance' || requestwrapper.Vehicle_Category == 'External Refinance' || requestwrapper.Vehicle_Category == 'Refinance'){
                    this.Vehicle_Category = 'R';
                }
                else if(requestwrapper.Vehicle_Category == 'Used'){
                    this.Vehicle_Category = 'U';
                }
                else{
                    this.Vehicle_Category = '';
                }
            }
            else{
                this.Vehicle_Category = '';
            }
            
            
            
            if(requestwrapper.product != null && requestwrapper.Product == 'Two Wheeler'){
                this.Product = 'H';
            } 
            else if(requestwrapper.product != null && requestwrapper.Product == 'Passenger Vehicles'){
                this.Product = 'C'; 
            }
            else if(requestwrapper.product != null && requestwrapper.Product == System.Label.Tractor){
                this.Product = 'T'; 
                istractor = true;
            }
            else{
                this.Product = '';
            }
                
            
            this.Variant = requestwrapper.Variant==null?'':requestwrapper.Variant ;
            this.Fin_Amount = requestwrapper.Fin_Amount==null?'':requestwrapper.Fin_Amount ;
            this.Balance_Available = requestwrapper.Balance_Available==null?'':requestwrapper.Balance_Available ;
            this.Tenure = requestwrapper.Tenure==null?'':requestwrapper.Tenure ;
            this.Agreement_Value = requestwrapper.Agreement_Value==null?'':requestwrapper.Agreement_Value ;
            this.Motor_Expiry_Date = requestwrapper.Motor_Expiry_Date==null?'':requestwrapper.Motor_Expiry_Date ;
            this.Motor_Premium = requestwrapper.Fin_Amount==null?'':requestwrapper.Motor_Premium ;
            this.D2C = requestwrapper.D2C=='Y'?'Y':'N';
            this.Periodicity = requestwrapper.Periodicity; //SFTRAC-629
        }
        validate(System.Label.Insurance_Recommendation, istractor);
    }
    
    
    /*
    * @Method Name: getHttpRequestHeaders
    * @Created by: 	Santhosh Mothe.
    * @Description: Method to get the HTTP request header data
    * @Return:      Map
    */
    public override Map<String,String> getHttpRequestHeaders(){
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }
    
    //
    /*
    * @Method Name: Constructor
    * @Created by: 	Santhosh Mothe.
    * @Description: Method to validate the request data
    * @Param:       String serviceName 
    * @Return:      boolean
    */
    public override boolean validate(String serviceName, Boolean istractor){
        List<String> errorMessageList = new List<String>();
        if(String.isBlank(this.Application_No)){
            throw new IND_Exception(System.Label.ApplicationNo);
        }
        if(String.isBlank(this.Vehicle_ID)){
            throw new IND_Exception(System.Label.VehicleId);
        }
        if(String.isBlank(this.Product)){
            throw new IND_Exception(System.Label.Product);
        }
        if(String.isBlank(this.Age)){
            throw new IND_Exception(System.Label.Age);
        }
        if(String.isBlank(this.Gender)){
            throw new IND_Exception(System.Label.Gender);
        }
        if(String.isBlank(this.Borrower_Type)){
            throw new IND_Exception(System.Label.Borrower_Type);
        }
        if(String.isBlank(this.Vehicle_Category)){
            throw new IND_Exception(System.Label.Vehicle_Category);
        }
        if(String.isBlank(this.Fin_Amount)){
            throw new IND_Exception(System.Label.FinAmount);
        }
        if(String.isBlank(this.Tenure)){
            throw new IND_Exception(System.Label.Tenure);
        }
        if(String.isBlank(this.Variant)){
            throw new IND_Exception(System.Label.Variant);
        }
        if(String.isBlank(this.Balance_Available)){
            throw new IND_Exception(System.Label.Balance_Available);
        }
        if(String.isBlank(this.Agreement_Value)){
            throw new IND_Exception(System.Label.Agreement_Value);
        }
        if(String.isBlank(this.Motor_Expiry_Date) && (this.Vehicle_Category =='R' || this.Vehicle_Category =='U') && istractor == false){
            throw new IND_Exception(System.Label.Motor_Expiry_Date);
        }
        if(String.isBlank(this.Motor_Premium)){
            throw new IND_Exception(System.Label.Motor_Premium);
        }
        
        
        return true;
    }
}