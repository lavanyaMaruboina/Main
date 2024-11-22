/*------------------------------------------------------------
Author: Santhosh Mothe
Company: Persistent Systems
Description: This class is wrapper class for the DocAuth Document Report Request
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
19-11-2021    Santhosh Mothe            Created
------------------------------------------------------------*/

public class Ind_DelegateAuthRequest extends ParentAPIRequest {
    public String User_Name{get;set;} 
    public String Password{get;set;} 
    
    public Ind_DelegateAuthRequest(String username, String password){
        this.User_Name = username;
        this.Password = password;
    }
    
    /*
    * @Method Name: Constructor
    * @Created by: 	Santhosh Mothe.
    * @Description: Method to validate the request data
    * @Param:       String serviceName 
    * @Return:      boolean
    */
    public override boolean validate(String serviceName){
        return true;
    }
    
}