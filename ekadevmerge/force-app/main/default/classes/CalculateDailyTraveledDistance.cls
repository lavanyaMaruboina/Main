public class CalculateDailyTraveledDistance implements Database.Batchable<sObject> {
    
    public String querySystemCheckIn='Select id, Distance_Travel_Per_Day__c, Check_Out_Geolocation__c, user__r.name, user__c,Check_In_Geolocation__c from system_check_in__c where createddate=TODAY and Check_In_Geolocation__Latitude__s !=null and Check_In_Geolocation__Longitude__s !=null order by user__c';
    
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        System.debug('Entry start()::'+querySystemCheckIn);
        System.debug('Exit start()::');
        return Database.getQueryLocator(querySystemCheckIn);
    }
    
    
    public void execute(Database.BatchableContext BC, List<System_check_In__c> scope){
        System.debug('Entry Execute():::'+scope);
        List<Location> geoCheckInLocation =new  List<Location>();
        Map<Id,List<Location>> mapCheckINGeoLocation= new Map<Id,List<Location>>();
        Map<Id,List<Location>> mapDailyCheckINGeoLocation= new Map<Id,List<Location>>();
        Map<id,System_check_In__c> userIdANdRecMap=new Map<id,System_check_In__c>();
        List<System_check_In__c> updateSystemRec;
        List<Check_in_out__c> checkRecs=[select id , CreatedDate, LastModifiedDate,  Check_In_Geolocation__c,Opportunity__r.OwnerId  from Check_IN_Out__c where createdDate=Today order by Opportunity__r.OwnerId, LastModifiedDate  ];
        System.debug('Section 1');
        if(checkRecs.size()>0)
        {
            System.debug('Section 1111');
            For(Check_in_out__c checkR:checkRecs)
            {
                if(mapCheckINGeoLocation.get(checkR.Opportunity__r.OwnerId)!=null)
                {
                    geoCheckInLocation=mapCheckINGeoLocation.get(checkR.Opportunity__r.OwnerId);
                }
                else
                {
                    geoCheckInLocation =new  List<Location>();
                }
                geoCheckInLocation.add(checkR.Check_In_Geolocation__c);
                mapCheckINGeoLocation.put(checkR.Opportunity__r.OwnerId,geoCheckInLocation);
                
            }
        }
        System.debug('Section 2');
        for(System_check_In__c systemCheck : scope){
            System.debug('Section 22222');            
            userIdANdRecMap.put(systemCheck.user__c,systemCheck);  
            System.debug('Section userIdANdRecMap:::'+userIdANdRecMap);            
            if(mapDailyCheckINGeoLocation.get(systemCheck.user__c)!=null)
            {
                System.debug('4444');
                geoCheckInLocation=mapDailyCheckINGeoLocation.get(systemCheck.user__c);
            }
            else
            {
                System.debug('5555');
                geoCheckInLocation =new  List<Location>();
                
            }
            System.debug('Gl0 :::'+geoCheckInLocation+':::'+systemCheck.Check_In_Geolocation__c);
            geoCheckInLocation.add(systemCheck.Check_In_Geolocation__c);
            System.debug('Gl1 :::'+geoCheckInLocation);
            geoCheckInLocation.add(systemCheck.Check_Out_Geolocation__c);
            System.debug('GL2 :::'+geoCheckInLocation);
            
            mapDailyCheckINGeoLocation.put(systemCheck.user__c,geoCheckInLocation);   
            System.debug('Map after second  :::'+mapDailyCheckINGeoLocation+'::::'+mapDailyCheckINGeoLocation.size());
            
        }
        if(!mapDailyCheckINGeoLocation.isEmpty() && !mapCheckINGeoLocation.isEmpty())
        {
            System.debug('Final Check Daily'+mapDailyCheckINGeoLocation.size() +'::Clinic::'+mapCheckINGeoLocation);
            updateSystemRec=new List<System_check_In__c>();
            System_check_In__c sysCheck;
            for(Id mapId: mapDailyCheckINGeoLocation.keySet())
            {
                List<Location> calcDistanceList=new List<Location>();
                List<Location> geoLocationDaily=mapDailyCheckINGeoLocation.get(mapId);
                List<Location> geoLocationCheck=mapCheckINGeoLocation.get(mapId);
                if(!geoLocationCheck.isEmpty())
                {
                    geoLocationCheck.add(0,geoLocationDaily.get(0));
                    geoLocationCheck.add(geoLocationCheck.size()-1,geoLocationDaily.get(1));
                    calcDistanceList.addAll(geoLocationCheck);
                    
                }
                else
                {
                    calcDistanceList.addAll(geoLocationDaily);
                }              
                Double totalDistance = 0;
                for(integer i=0;i<calcDistanceList.size()-1;i++)
                {
                    Location l1=calcDistanceList[i];
                    System.debug('Location 1:::'+l1);
                    Location l2=calcDistanceList[++i];
                    System.debug('Location 2:::'+l2);
                    System.debug('The distance is :::'+Location.getDistance(l1,l2,'km'));
                    totalDistance=+Location.getDistance(l1,l2,'km'); 
                    
                }
                System.debug('Final Check  totalDistance'+totalDistance);
                sysCheck=userIdANdRecMap.get(mapId);
                sysCheck.Distance_Travel_Per_Day__c=totalDistance;
                updateSystemRec.add(sysCheck);
            }
            
            System.debug('The list to be updated :::'+updateSystemRec);
            
        }
        
        
        Database.SaveResult[] resultsUpdate = Database.update(updateSystemRec, true);
        
        // Check results.
        for (Integer i = 0; i < resultsUpdate.size(); i++) {
            if (resultsUpdate[i].isSuccess()) {
                System.debug('Successfully updated ID: '
                             + resultsUpdate[i].getId());
            } else {
                System.debug('Error: could not update sobject '
                             + 'for array element ' + i + '.');
                System.debug('   The error reported was: '
                             + resultsUpdate[i].getErrors()[0].getMessage() + '\n');
            }
        }
        System.debug('Exit Execute():::');
        
    }
    
    public void finish(Database.BatchableContext BC){
        //Do Nothing
    }
    
}