/***
 * Description : Wrapper Class for CTI Rest Callout
 * Author : Maantic
 * Date: 27/10/2022
 **/

public with sharing class CTIRequestWrpper {
    @AuraEnabled
    public String phoneNumber;
    //Optional
    @AuraEnabled
    public String name;
    //Optional
    @AuraEnabled
    public String leadSource;
    //Optional
    @AuraEnabled
    public String assignedAgentId;  
  
}