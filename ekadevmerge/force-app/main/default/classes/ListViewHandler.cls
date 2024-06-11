public class ListViewHandler {
      @AuraEnabled
    public static List<Lead> getLead(string sLeadIds){      
        List<String> LeadIds=sLeadIds.split('-');           
        Set<String> SobjectFields = Schema.getGlobalDescribe().get('Lead').getDescribe().fields.getMap().keySet();
        String queryString='SELECT ' + String.join(new List<String>(SobjectFields), ',') + ' FROM Lead WHERE Id IN (\''+String.join(LeadIds,'\',\'')+'\') Order by Name asc';
        return Database.query(queryString);
    }

}