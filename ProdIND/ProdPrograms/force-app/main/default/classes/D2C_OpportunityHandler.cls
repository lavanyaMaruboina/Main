public class D2C_OpportunityHandler {

    static map<Id, Boolean> initialOfferDropMap = new map<Id, Boolean>();

    public static void sendMoveToAssistedEmail(Set<Id> oppIdSet) {
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        List<Opportunity> oppList = [SELECT Id, Owner.Email, Lead_number__c, Customer_Name__c, Contact_number__c,StageName FROM Opportunity WHERE Id IN: oppIdSet AND Owner.Email != null];
        EmailTemplate et = [
            SELECT Id, Body, Subject
            FROM EmailTemplate
            WHERE DeveloperName = 'D2CLeadTransferredBE'
        ];

        for(Opportunity opp : oppList){
            String subject = et.Subject;
            subject = subject.replace('{!Opportunity.Lead_number__c}', opp.Lead_number__c != null ? opp.Lead_number__c : '');

            String emailBody = et.Body;
            emailBody = emailBody.replace('{!Opportunity.Lead_number__c}', opp.Lead_number__c != null ? opp.Lead_number__c : '');
            emailBody = emailBody.replace('{!Opportunity.Customer_Name__c}', opp.Customer_Name__c != null ? opp.Customer_Name__c : '');
            emailBody = emailBody.replace('{!Opportunity.Contact_number__c}', opp.Contact_number__c != null ? opp.Contact_number__c : '');

            List<String> toAddress = new List<String>();
            toAddress.add(opp.Owner.Email);
            allmsg.add(generateMail(subject, emailBody, toAddress));
            opp.StageName = 'Withdrawn';
        }
        try {
            if(oppList.size() > 0){
                database.update(oppList, false);
            }
            Messaging.sendEmail(allmsg, false);
            return;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }


    public static void sendVehicleDedupeEmail(Set<Id> oppIdSet){
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        List<Opportunity> oppList = [SELECT Id, Lead_number__c, Owner.Email, Product_Type__c, Vehicle_Type__c, Is_Pre_Approved__c FROM Opportunity WHERE Id IN: oppIdSet AND Owner.Email != null];
        EmailTemplate et = [
            SELECT Id, Body, Subject
            FROM EmailTemplate
            WHERE DeveloperName = 'D2CStageChangedVehicleDedupe'
        ];
        for(Opportunity opp: oppList){
            String vehicleType = opp.Is_Pre_Approved__c ? 'Pre Approved' : opp.Product_Type__c + ' ' + opp.Vehicle_Type__c;

            String subject = et.Subject;
            subject = subject.replace('{!Opportunity.Lead_number__c}', opp.Lead_number__c != null ? opp.Lead_number__c : '');

            String emailBody = et.Body;
            emailBody = emailBody.replace('{!Opportunity.Lead_number__c}', opp.Lead_number__c != null ? opp.Lead_number__c : '');
            emailBody = emailBody.replace('{vehicletype}', vehicleType);

            List<String> toAddress = new List<String>();
            toAddress.add(opp.Owner.Email);
            allmsg.add(generateMail(subject, emailBody, toAddress));
        }
        if(!allmsg.isEmpty()){
            Messaging.sendEmail(allmsg, false);
        }
    }

    public static Messaging.SingleEmailMessage generateMail(String subject, String emailBody, List<String> toAddress){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSenderDisplayName('IBL D2C');
        mail.setToAddresses(toAddress);
        mail.setSubject(subject);
        mail.setSaveAsActivity(false);
        mail.setUseSignature(false);
        mail.setPlainTextBody(emailBody);
        return mail;
    }

    public static void updateLastDropScreen(Map<Id,Opportunity> mapNewOpp,Map<Id,Opportunity> lstOldOpp) {
        
        for (Opportunity newOpp: mapNewOpp.values()) {
            Opportunity oldOpp = lstOldOpp.get(newOpp.Id);
            
            if((newOpp.LeadSource == 'D2C' && String.isNotBlank(newOpp.Sub_Stage__c))){
                
                if((newOpp.Sub_Stage__c != oldOpp.Sub_Stage__c) && newOpp.Sub_Stage__c.equalsIgnoreCase('Vehicle Dedupe') 
                    && newOpp.Vehicle_Type__c.equalsIgnoreCase('new')) {
                        newOpp.Sub_Stage__c = oldOpp.Sub_Stage__c;
                }
                
                if((newOpp.D2C_Journey_Status__c == IntegrationConstants.STATUS_INITIAL_OFFER_DROP) 
                    
                    && String.isNotBlank(newOpp.D2C_journey_drop_screen__c) 
                    && (newOpp.D2C_journey_drop_screen__c != oldOpp.D2C_journey_drop_screen__c)
                    && String.isBlank(newOpp.Aggregator_Source__c) && !newOpp.Is_Pre_Approved__c ) {
                        newOpp.Last_Drop_Screen__c = newOpp.D2C_journey_drop_screen__c;
                        newOpp.D2C_journey_drop_screen__c  = '';

                        initialOfferDropMap.put(newOpp.Id, true);
                        System.debug('in if 2 '+ initialOfferDropMap);
                    }
            }

        }
    }

    public static void callConvox(Map<Id,Opportunity> newOppMap,Map<Id,Opportunity> oldOppMap) {
        Set<Id> oppIdSet = new Set<Id>();
        for (Opportunity newOpp: newOppMap.values()) {
            Opportunity oldOpp = oldOppMap.get(newOpp.Id);
            System.debug('in if 3' + initialOfferDropMap);
            if(!initialOfferDropMap.isEmpty() && initialOfferDropMap.containsKey(newOpp.Id) 
            && initialOfferDropMap.get(newOpp.Id)) {
                oppIdSet.add(newOpp.Id);
            }
        }
        if(!oppIdSet.isEmpty()){
            Applicant__c app = [Select Id, Contact_number__c from Applicant__c WHERE Opportunity__c IN: oppIdSet limit 1];
        	conVoxAPIHandler.callApi(IntegrationConstants.CONVOX_DATAUPLOAD, app.Contact_number__c, app.Id);
        }
    }

}