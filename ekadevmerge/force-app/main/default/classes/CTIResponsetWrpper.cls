/***
 * Description : Wrapper Class for CTI Rest Callout
 * Author : Maantic
 * Date: 27/10/2022
 **/

public with sharing class CTIResponsetWrpper {
    @AuraEnabled
    public String phoneNumber;
    @AuraEnabled
    public String isSaved;
    @AuraEnabled
    public String message;
  
}