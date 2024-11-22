/*------------------------------------------------------------
Author:        Haarika Chodisetti
Company:       Salesforce
Description:   This is schedular class to delete particular Applicant records
Test Class:    Schedule_DeleteApps_ConVoxTest
History
Date            Author              Comments
-------------------------------------------------------------
16-08-2022      Haarika Chodisetti         Created
------------------------------------------------------------*/
public class Schedule_DeleteApplicants_ConVox implements Schedulable 
{
    /*
     * @Method:      execute
     * @Created by:  Haarika Chodisetti
     * @Description: invokes callApi method of conVoxAPIHandler 
     * @Param:       SchedulableContext
     * @Return:     
     History
     Date            Author              Comments
     -------------------------------------------------------------
     16-08-2022      Haarika Chodisetti         Created
     ------------------------------------------------------------*/
    public void execute(SchedulableContext sc) 
    {
        conVoxAPIHandler.callApi(IntegrationConstants.CONVOX_DELETELEAD,null,null);
    }
}