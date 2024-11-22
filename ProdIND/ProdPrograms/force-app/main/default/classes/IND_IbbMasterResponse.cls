/*------------------------------------------------------------
Author: Aman Mundhada
Company: Persistent Systems
Description: This class is wrapper class for the IBB Master response
Test Class:	IND_IbbMasterServiceTest
History
Date            Author              Comments
------------------------------------------------------------- 
16-12-2021    Aman Mundhada            Created
------------------------------------------------------------*/

public class IND_IbbMasterResponse extends ParentAPIResponse{
    public final String application_no{get;set;}
    public final String vehicle_id{get;set;} 
    public final String ibb_price_min{get;set;}
    public final String ibb_price_avg{get;set;}
    public final String ibb_price_max{get;set;}
    public final String status{get;set;}
    public final String message{get;set;}
}