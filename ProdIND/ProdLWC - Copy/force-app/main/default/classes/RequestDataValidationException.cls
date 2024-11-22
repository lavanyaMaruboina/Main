/*
* @Author	: Sharad Kathane
* Version 	: Initial
* Date		: 08-10-2021
* Description: A validation exception class to maintain all the validations exception related to API request classes
*/
public class RequestDataValidationException extends Exception {

    public List<String> errorMessageList{get;set;}
    
    public RequestDataValidationException(List<String> errorMessageList){
        this.errorMessageList = errorMessageList;
    }
}