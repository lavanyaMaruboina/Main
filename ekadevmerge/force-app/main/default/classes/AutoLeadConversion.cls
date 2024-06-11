public class AutoLeadConversion {
    @InvocableMethod   
    public static void bulkLeadConvert(List<Id> LeadIds)  
    {         
        LeadStatus convertedStatus = [SELECT MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
        system.debug('convertedStatus '+ convertedStatus);
        List<Database.LeadConvert> massLeadconvert = new List<Database.LeadConvert>(); 
        for(Lead record: [SELECT Id FROM Lead WHERE ID in :LeadIds and IsConverted = false ]) { 
            system.debug('record '+ record);
            Database.LeadConvert convert = new Database.LeadConvert();
            convert.setLeadId(record.Id); 
            convert.setConvertedStatus(convertedStatus.MasterLabel);
            massLeadconvert.add(convert);
            system.debug('massLeadconvert '+ massLeadconvert);
        }       
        if (!MassLeadconvert.isEmpty()){
            List<Database.LeadConvertResult> lcr = Database.convertLead(MassLeadconvert); 
            system.debug('lcr '+ lcr);
        }
    }
}