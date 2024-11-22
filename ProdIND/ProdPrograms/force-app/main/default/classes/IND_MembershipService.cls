/*------------------------------------------------------------
Author:        Manish Baldota
Company:       Persistent
Description:   This class is service class to membership(ICAI,CMI,ICWAI) API
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
8-10-2021      Manish Baldota      Created
------------------------------------------------------------*/
public class IND_MembershipService {
    
   /* @Method:      membershipCallout
    * @Created by:  Manish Baldota
    * @Description: This method helps to perfrom the callout through callout processor class and return the response to calling method.
    * @Param:       Object - Applicant
    * @Return:      Object - IND_SMSResponse type reponse */    
    public static IND_MembershipRequest getMembershipCallOutRequest(Applicant__c app,String inputJSONString,String loanAppId){
        try{
            if(String.isNotBlank(inputJSONString)){
                IND_MembershipRequest membershipRequest = new IND_MembershipRequest(app,inputJSONString,loanAppId);//only validation and setting headers
                return membershipRequest;
            }else{
                throw new IND_Exception('Please provide valid membership Id or Membership type details.');   
            }            
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_MembershipService', 'getMembershipCallOutRequest', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());   
        }
    }
    
}