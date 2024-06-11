public class OpportunityTriggerHandler {
    public static void updateAccountfieldsFromOpportunity(List<Opportunity> oppLst){
        
        list<recordtype> RTY = [SELECT id, name, SobjectType FROM RecordType WHERE (name = 'HXNG Team' OR name = 'EMR Team') AND SobjectType = 'Opportunity'];        
        Map<Id, Account> accMap = new Map<Id, Account>();
        
        if(RTY[0].Name == 'HXNG Team' || RTY[0].Name == 'EMR Team' || RTY[1].Name == 'HXNG Team' || RTY[1].Name == 'EMR Team'){
            for (Opportunity opp : oppLst) {
                if (opp.RecordTypeId != null && opp.AccountId != null) {
                    
                    accMap.put(opp.AccountId, new Account(
                        Id = opp.AccountId,
                        //Eka_Id__c = opp.Eka_Id__c,
                        Number_of_Staff_in_Clinic__c = opp.Number_of_Staff_in_Clinic__c,
                        Other_Apps_Used__c = opp.Other_Apps_Used__c,
                        OPD_Days__c = opp.OPD_Days__c,
                        Staff_Alternate_Phone_Number__c = opp.Staff_Alternate_Phone_Number__c,
                        OPD_timings__c = opp.OPD_timings__c,
                        OPD_Start_Timing__c = opp.OPD_Start_Timing__c,
                        OPD_End_Timing__c = opp.OPD_End_Timing__c,
                        Daily_OPD_Vol__c = opp.Daily_OPD_Vol__c,
                        Staff_Name__c = opp.Staff_Name__c,
                        Software_Name__c = opp.Software_Name__c,
                        Infra_In_Clinic__c = opp.Infra_in_clinic__c,
                        //Does_the_doctor_have_Preferred_Pharmacy__c = opp.Does_the_doctor_have_Preferred_Pharmacy__c,
                        Does_the_doctor_have_their_own_Lab__c = opp.Does_the_doctor_have_their_own_Lab__c,
                        Does_the_doctor_have_their_own_pharmacy__c = opp.Does_the_doctor_have_their_own_pharmacy__c,
                        Pharmacy_Type__c = opp.Pharmacy_Type__c,
                        Type = opp.Type,
                        Notes_Reamrks__c = opp.Notes_Remarks__c,
                        Check_In_Time__c = opp.Check_In_Time__c,
                        Check_Out_Time__c = opp.Check_Out_Time__c,
                        Check_In_Count__c = opp.Check_In_Count__c,
                        Phone = opp.Phone__c
                    ));
                    
                }
            }
            
            if (!accMap.isEmpty()) {
                update accMap.values();
                               
            }
        }
    }
}