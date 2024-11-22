/*
* @Author	: Sharad Kathane
* Version 	: Initial
* Date		: 08-10-2021	
* Description:  Constant class
*/
public class IntegrationConstants {
    
    public static String CONTENT_TYPE = 'Content-Type';
    public static String CONTENT_TYPE_XML = 'application/xml';
    public static String CONTENT_TYPE_JSON = 'application/json';
    public static String CONTENT_TYPE_URL_ENCODED = 'application/x-www-form-urlencoded';

    //Haarika - 06/09/2022 - Created new strings to store values of CTI functionality 
    public static String CONVOX_END_POINT = 'https://h16.deepijatel.in/ConVoxCCS/External/external_dialer.php';
    public static String CONVOX_CONTENT_TYPE_JSON = 'application/json;charset=UTF-8';
    public static String OBJECT_APPLICANT = 'Applicant__c';  
    public static String STATUS_INITIAL_OFFER_DROP = 'Initial offer drop';
    public static String STATUS_MOVE_TO_ASSISTED = 'Move to assisted';
    public static String METHOD_POST = 'POST';
    public static String CONVOX_PROCESS = 'ConVox_Process';
    public static String CONVOX_GETLISTALL = 'GETLISTALL';
    public static String CONVOX_DATAUPLOAD = 'DATAUPLOAD';
    public static String CONVOX_DELETELEAD = 'DELETELEAD';
    public static String TO_BE_DELETED_SUBDISPOSITION = 'Customer to complete journey on his own';
    public static Set<String> TO_BE_DELETED_DISPOSITIONS = new Set<String>{'Not Interested','Completed leads'};
    public static String DISPOSITION_NOT_INTERESTED = 'Not Interested';
    public static String SUB_DISPOSITION_CAR_NOT_NEEDED = 'Car not needed';
    public static String CONVOX_ACCESS_TOKEN_HEADER = 'access_token';
    

}