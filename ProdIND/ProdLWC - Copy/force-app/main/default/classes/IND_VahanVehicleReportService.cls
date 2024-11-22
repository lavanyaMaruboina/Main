/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is service class for the Vahan Vehicle Report API
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
04-01-2022    Satyam More            Created
------------------------------------------------------------*/

public class IND_VahanVehicleReportService {
/*
* @Method:      getVahanVehicleReportCallOutRequest
* @Created by:  Satyam More
* @Description: This method will process Email Service API
* @Param:       Object - RequestWrapper 
* @Return:      Object - IND_EmailServiceRequest type request
*/
   
    public static IND_VahanVehicleReportRequest getVahanVehicleReportCallOutRequest(RequestWrapper requestWrapper, String loanAppId){
        try
        {
            IND_VahanVehicleReportRequest vahanVehicleReport = new IND_VahanVehicleReportRequest(requestWrapper,loanAppId);
            return vahanVehicleReport;
        }
        catch(Exception ex){
                        ErrorLoggerUtil.logErrorEvent('IND_VahanVehicleReportService', 'getVahanVehicleReportCallOutRequest', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());            
        } 
    }
}