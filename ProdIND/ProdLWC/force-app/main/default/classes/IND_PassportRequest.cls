/*------------------------------------------------------------
Author: Aman Mundhada
Company: Persistent Systems
Description: This class is wrapper class for the Passport Request
Test Class:  IND_PassportService_Test
History
Date            Author              Comments
------------------------------------------------------------- 
11-11-2021    Aman Mundhada            Created
------------------------------------------------------------*/

public class IND_PassportRequest extends ParentAPIRequest { 	
    //request paramaters for Passport Request
    public final string Lead_Id{get;set;}
    public final String fileNo{get;set;}
    public final String FName{get;set;}
    public final String MName{get;set;}
    public final String LName{get;set;}
    public final String Email{get;set;}
    public final String Gender{get;set;}
    public final String DateOfBirth{get;set;}
    public final String Identify_IdNumber{get;set;}
    public final String Identify_IdType{get;set;}
    public final String Maker_Id{get;set;}
    
    //constructor
    // @Method:      IND_PassportRequest
    // @Created by:  Aman Mundhada
    // @Description: Contructor to initialize the details
    // @Param:       Object Request Wrapper
    // @Return:      ''    
    public IND_PassportRequest(RequestWrapper requestWrapper){
        if(requestWrapper!=null){
            this.Lead_Id =  requestWrapper.leadId==null?'':requestWrapper.leadId; 
            this.fileNo = requestWrapper.kycPassportFileNo==null?'':requestWrapper.kycPassportFileNo;  
            this.FName = requestWrapper.firstName==null?'':requestWrapper.firstName;
            this.MName = '';
            this.LName = requestWrapper.lastName==null?'':requestWrapper.lastName;
            this.Email = '' ;
            if(requestWrapper.kycGender!=null){
                if(requestWrapper.kycGender.equalsIgnoreCase('Male')){                
                    this.gender = 'M';
                }
                else if(requestWrapper.kycGender.equalsIgnoreCase('Female')){
                    this.gender = 'F';
                }
                else if(requestWrapper.kycGender.equalsIgnoreCase('Transgender')){
                    this.gender = 'Transgender';
                }
            }
            else {
                this.gender='';
            }
            this.DateOfBirth =requestWrapper.dateOfBirth==null?'':requestWrapper.dateOfBirth;
            this.Identify_IdNumber =requestWrapper.kycPassportNo==null?'':requestWrapper.kycPassportNo; 
            this.Identify_IdType = System.label.PassportIdType ;            
            this.Maker_Id=IntegrationUtilities.getMakerId();
        } 
        validate(System.Label.PassportAPI);
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
        if(String.isBlank(this.fileNo)){
            throw new IND_Exception(System.Label.FileNo);
        }
        if(String.isBlank(this.FName)){
            throw new IND_Exception(System.Label.FirstName);
        }
        if(String.isBlank(this.LName)){
            throw new IND_Exception(System.Label.LastName);
        }
        if(String.isBlank(this.Gender)){
            throw new IND_Exception(System.Label.Gender);
        }
        if(String.isBlank(this.DateOfBirth)){
            throw new IND_Exception(System.Label.DateOfBirth);
        }
        if(String.isBlank(this.Identify_IdNumber)){
            throw new IND_Exception(System.Label.PassportNumber);
        }
        if(String.isBlank(this.Identify_IdType)){
            throw new IND_Exception(System.Label.IdType);
        }
        if(String.isBlank(this.Maker_Id)){
            throw new IND_Exception(System.Label.MakerId);
        }        
        return true;
    }
}