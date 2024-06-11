public class CalculateDailyTravelDistance implements Database.Batchable<sObject> {
    
    public String querySystemCheckIn='Select id, Distance_Travel_Per_Day__c, Check_Out_Geolocation__c, user__r.name, user__c,'+
        'Check_In_Geolocation__c from system_check_in__c where createddate=TODAY and Check_In_Geolocation__Latitude__s !=null'+
        ' and Check_In_Geolocation__Longitude__s !=null and User_Profile__c=\'Field Sales Team\' order by user__c';
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        System.debug('querySystemCheckIn '+querySystemCheckIn);
        return Database.getQueryLocator(querySystemCheckIn);
    }
    public void execute(Database.BatchableContext BC, List<System_check_In__c> scope){
        
        System.debug('Entry Execute():::'+scope);
        
        Map<Id,List<Location>> mapCheckINGeoLocation= new Map<Id,List<Location>>();
        Map<Id,List<Location>> mapDailyCheckINGeoLocation= new Map<Id,List<Location>>();
        Map<id,System_check_In__c> userIdANdRecMap=new Map<id,System_check_In__c>();
        List<Location> geoCheckInLocation =new  List<Location>();
        List<System_check_In__c> updateSystemRec = new  List<System_check_In__c>();
        Double totalDistanceTravelled;
        
        List<Check_in_out__c> clinicCheckIn=[select id , CreatedDate, LastModifiedDate, Check_In_Geolocation__c,OwnerId  
                                             from Check_IN_Out__c where createdDate=Today and Check_In_Geolocation__Latitude__s!=NULL
                                             and Check_In_Geolocation__Longitude__s != null order by OwnerId, LastModifiedDate];
        System.debug('clinicCheckIn '+ clinicCheckIn);
        
        if(clinicCheckIn.size()>0){
            For(Check_in_out__c checkR:clinicCheckIn){
                if(mapCheckINGeoLocation.containsKey(checkR.OwnerId)){
                    geoCheckInLocation=mapCheckINGeoLocation.get(checkR.OwnerId);
                }
                else{
                    geoCheckInLocation =new  List<Location>();
                }
                geoCheckInLocation.add(checkR.Check_In_Geolocation__c);
                mapCheckINGeoLocation.put(checkR.OwnerId,geoCheckInLocation);                
            }
        }
        System.debug('mapCheckINGeoLocation '+ mapCheckINGeoLocation); 
        
        if(scope.size()>0){
            for(System_check_In__c systemCheck : scope){
                userIdANdRecMap.put(systemCheck.user__c,systemCheck);  
                System.debug('Section userIdANdRecMap:::'+userIdANdRecMap);            
                if(mapDailyCheckINGeoLocation.containsKey(systemCheck.user__c)) {
                    geoCheckInLocation=mapDailyCheckINGeoLocation.get(systemCheck.user__c);
                }
                else{
                    geoCheckInLocation =new  List<Location>();
                }
                geoCheckInLocation.add(systemCheck.Check_In_Geolocation__c);
                geoCheckInLocation.add(systemCheck.Check_Out_Geolocation__c);
                mapDailyCheckINGeoLocation.put(systemCheck.user__c,geoCheckInLocation);   
                System.debug('mapDailyCheckINGeoLocation '+mapDailyCheckINGeoLocation);   
            }
        }
        if(mapDailyCheckINGeoLocation.isEmpty() && !mapCheckINGeoLocation.isEmpty()){
            System_check_In__c sysCheck;
            for(Id userId: mapCheckINGeoLocation.keySet()){
                List<Location> geoLocationClinic = new List<Location>();                               
                geoLocationClinic.addAll(mapCheckINGeoLocation.get(userId));                
                system.debug('geoLocationClinic '+ geoLocationClinic); 
                if(geoLocationClinic.size()>0){
                    totalDistanceTravelled = calculateDistance(geoLocationClinic);  
                }
                System.debug('Final Check  totalDistanceTravelled '+ totalDistanceTravelled);
                sysCheck=userIdANdRecMap.get(userId);                
                sysCheck.Distance_Travel_Per_Day__c = totalDistanceTravelled;
                updateSystemRec.add(sysCheck);
            }
            System.debug('The list to be updated :::'+updateSystemRec);
        }else if(!mapDailyCheckINGeoLocation.isEmpty() && !mapCheckINGeoLocation.isEmpty()){
            System_check_In__c sysCheck;
            for(Id userId: mapDailyCheckINGeoLocation.keySet()){
                List<Location> geoLocationDailyAndClinic = new List<Location>();                
                
                geoLocationDailyAndClinic.add(mapDailyCheckINGeoLocation.get(userId).get(0));
                if(mapCheckINGeoLocation.containsKey(userId)){
                    geoLocationDailyAndClinic.addAll(mapCheckINGeoLocation.get(userId));
                }
                geoLocationDailyAndClinic.add(mapDailyCheckINGeoLocation.get(userId).get(1));  
                
                system.debug('geoLocationDailyAndClinic '+ geoLocationDailyAndClinic);
                if(geoLocationDailyAndClinic.size()>0){
                    totalDistanceTravelled = calculateDistance(geoLocationDailyAndClinic);
                }
                System.debug('Final Check  totalDistanceTravelled '+ totalDistanceTravelled);
                sysCheck=userIdANdRecMap.get(userId);
                
                sysCheck.Distance_Travel_Per_Day__c = totalDistanceTravelled;
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
    
    public double calculateDistance(List<Location> geoLocationCheck){
        double totaldistance = 0 ;
        for(integer i=0;i<geoLocationCheck.size()-1;i++)
        {
            Location l1=geoLocationCheck[i];
            System.debug('Location 1:::'+l1);
            Location l2=geoLocationCheck[++i];
            System.debug('Location 2:::'+l2);
            if(l1 != null && l2 != null){
                System.debug('The distance is :::'+Location.getDistance(l1,l2,'km'));
                totalDistance=+Location.getDistance(l1,l2,'km'); 
            }
        }
        return totalDistance;
        
    }
    
    public void finish(Database.BatchableContext BC){
        //Do Nothing
    }
    
}