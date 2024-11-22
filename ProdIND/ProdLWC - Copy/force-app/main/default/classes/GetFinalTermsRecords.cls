public class GetFinalTermsRecords {
    
    public final static String JOURENY_STATUS_STP = 'Non STP';
    public final static String JOURENY_STAUS_STOP = 'stop';
    public final static String IN_CASE_OF_FINALSANCTION = 'GREEN';
    public final static String IN_CASE_OF_PRINCIPLE = 'YELLOW';
    public final static String DARK_GREEN = 'Dark Green';
    public final static String LIGHT_GREEN = 'Light Green';
    public final static String DARK_RED = 'Dark Red';
    
    public static string getdetails(String offerid){
        String getscoreDesionStr;
        Boolean color;
        Final_Term__c finTermsObj = [SELECT id, Loan_Application__c,Loan_Application__r.Journey_Status__c FROM Final_Term__c WHERE id =: offerid WITH SECURITY_ENFORCED  LIMIT 1 ];
        String getJourStats = finTermsObj.Loan_Application__r.Journey_Status__c;
        
        for(Applicant__c applcnt: [SELECT Id, Scorecard_Decision__c FROM Applicant__c where Opportunity__c =: finTermsObj.Loan_Application__c WITH SECURITY_ENFORCED]){
            
            getscoreDesionStr = applcnt.Scorecard_Decision__c;
            
            if(getscoreDesionStr.equalsIgnoreCase(DARK_RED) || getscoreDesionStr.contains('red')){//  || OfferEngineStatus != success){
                //applcnt.status = 'anas';
            }
            else if(getscoreDesionStr.equalsIgnoreCase(DARK_GREEN) || getscoreDesionStr.equalsIgnoreCase(LIGHT_GREEN)  ||  getscoreDesionStr.contains('green')  || getJourStats == 'STP' ){//||OfferEngineStatus == success){
                //Show sanction details
            }
            else if(getscoreDesionStr.equalsIgnoreCase(DARK_GREEN) || getscoreDesionStr.equalsIgnoreCase(LIGHT_GREEN) || getJourStats == 'Non STP'){// ||OfferEngineStatus == success){
                //Show prinicple details
            }
            else{
                //Show yellow 
            }
        }
        
        return null;
    }
    
    @AuraEnabled
    public static String getFinalOfferDetailsflag(String offerId) {
        String loanLevel;
        try {
            
            Final_Term__c finTermsObj = [SELECT id, Loan_Application__r.Journey_Status__c FROM Final_Term__c WHERE id =: offerId WITH SECURITY_ENFORCED  LIMIT 1 ];
            Applicant__c appObj = [SELECT Id, Scorecard_Decision__c FROM Applicant__c where Opportunity__c =: finTermsObj.Loan_Application__c WITH SECURITY_ENFORCED  LIMIT 1];
            
            String getJourStats = finTermsObj.Loan_Application__r.Journey_Status__c;
            String getscoreDesionStr = appObj.Scorecard_Decision__c;
            Boolean darklighGreenbln;
            
            if( String.isNotEmpty(getscoreDesionStr) ){
                darklighGreenbln = getscoreDesionStr.equalsIgnoreCase(DARK_GREEN) || getscoreDesionStr.equalsIgnoreCase(LIGHT_GREEN);
            }
            else{
                darklighGreenbln = false;
            }
            
            if (darklighGreenbln && getJourStats == JOURENY_STATUS_STP) {
                loanLevel = IN_CASE_OF_PRINCIPLE;
                
            } else if (darklighGreenbln && getJourStats == JOURENY_STAUS_STOP) {
                loanLevel = IN_CASE_OF_FINALSANCTION;
                
            } else if (darklighGreenbln == false) {
                loanLevel = 'Loading';
            }
            
            return loanLevel;
            
        } catch (Exception e) {
            return String.valueof(e.getLineNumber());
        }
    }
    
    @AuraEnabled(Cacheable = true)
    public static Map < String, String > getFinalTerms(string ft) {
        ft = 'a1471000002Uh81AAC';
        Final_Term__c[] finalTermList = [select id, name, Loan_Application__c, Loan_Amount__c, Tenure__c, CRM_IRR__c, EMI_Amount__c from Final_Term__c where id =: ft]; //, Risk_band__c
        Final_Term__c finalTerm = finalTermList.get(0);
        string loan_app = finalTerm.Loan_Application__c;
        Applicant__c applicant = [select id, Name, Contact_number__c, Opportunity__c from Applicant__c where Opportunity__c =: loan_app LIMIT 1];
        Vehicle_Detail__c vdetails;
        vdetails = [select id,Loan_Application__c,Make__c,Model__c,Variant__c from Vehicle_Detail__c where Loan_Application__c=:loan_app];
        Map < String, String > ftDetails = new Map < String, String > ();
        Map < String, String > ftmap = new Map < String, String > ();
        if (finalTermList.size() > 0 ) {
            ftmap.put('Name', '' + applicant.Name);
            ftmap.put('Application Number', '' + finalTerm.Loan_Application__c);
            ftmap.put('Contact Number', '' + applicant.Contact_number__c);
            ftmap.put('MMV',''+vdetails.Make__c+' '+vdetails.Model__c+' '+vdetails.Variant__c);
            //ftmap.put('Make Model Variant', 'N/A');
            ftmap.put('Loan Amount', '' + finalTerm.Loan_Amount__c);
            ftmap.put('Tenure', '' + finalTerm.Tenure__c);
            ftmap.put('CRM IRR', '' + finalTerm.CRM_IRR__c);
            ftmap.put('EMI Amount', '' + finalTerm.EMI_Amount__c);
          //  ftmap.put('Risk Band', '' + finalTerm.Risk_band__c);
        }
        
        
        
        return ftmap;
    }
}