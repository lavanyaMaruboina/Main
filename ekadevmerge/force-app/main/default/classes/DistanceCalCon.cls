public class DistanceCalCon {
    @InvocableMethod
    public static void desCalcon(){
        String loggedInUserId = UserInfo.getUserId();
        list<System_Check_In__c> syslist=[SELECT Name,Id,Check_In_Time__c, Check_In_Geolocation__latitude__s,Check_In_Geolocation__longitude__s
                                           FROM System_Check_In__c
                                           where CreatedDate = TODAY AND OwnerId =:loggedInUserId limit 1];
        system.debug(syslist);
        
        list<Check_IN_Out__c> checklist=[SELECT Name,Check_In_Time__c,  Check_In_Geolocation__latitude__s,Check_In_Geolocation__longitude__s
                                        FROM Check_IN_Out__c
                                        where CreatedDate = TODAY AND OwnerId =:loggedInUserId];
        system.debug(checklist);
       /* for(System_Check_In__c s:syslist){
            system.debug(s.Check_In_Geolocation__Longitude__s);
        } */
        

Decimal Distance=0;
Integer i; 
       
for(i =0;i<checklist.size();i++)
{
    if(i==0 && Distance==0){
        Distance=distanceCalculation.calculateDistance(syslist[0].Check_In_Geolocation__latitude__s,syslist[0].Check_In_Geolocation__longitude__s, checklist[1].Check_In_Geolocation__latitude__s, checklist[1].Check_In_Geolocation__longitude__s);
        
    }else
    {
      Distance=Distance + distanceCalculation.calculateDistance(checklist[i-1].Check_In_Geolocation__latitude__s, checklist[i-1].Check_In_Geolocation__longitude__s, checklist[i].Check_In_Geolocation__latitude__s, checklist[i].Check_In_Geolocation__longitude__s);
  
    }
    
} 
        
        system.debug(Distance);
     
        //system.debug(checklist[1].Check_In_Geolocation__latitude__s);
        

        System_Check_In__c checkInRecord = new System_Check_In__c();
		checkInRecord.Id = syslist[0].Id; // Set the ID of the record you want to update
		checkInRecord.Distance_Travel_Per_Day__c = Distance; // Set the new value

		// Update the record
            Update checkInRecord;
              
 }
    }