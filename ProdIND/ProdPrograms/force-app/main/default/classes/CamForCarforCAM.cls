public class CamForCarforCAM {
@AuraEnabled(Cacheable=true) 
    	public static Map<String,String> getCamRec(string opp){
        system.debug('opp'+opp);
            
		Opportunity[] LoanAppCam=[SELECT Id,Agent_BL_code__c,Application_number__c,Loan_Application_Number__c,Customer_Code__c From Opportunity where Id=:opp];
            Map<String,String> Details= new Map<String,String>();
            Map<String,String> newmap= new Map<String,String>();
            if(LoanAppCam.size() > 0){
                newmap.put('Branch Name / StateName',LoanAppCam[0].Agent_BL_code__c == null ? 'N/A' : LoanAppCam[0].Agent_BL_code__c);
                //Executive Name
                //Weighted IRR (YTD)
                //Productivity (YTD)
                newmap.put('Application No',LoanAppCam[0].Application_number__c == null ? 'N/A' : LoanAppCam[0].Application_number__c);
                //newmap.put('Loan Application Number',LoanAppCam[0].Loan_Application_Number__c == null ? 'N/A' : LoanAppCam[0].Loan_Application_Number__c);
                //Applicant Name
                //Customer type
                newmap.put('Customer Code',LoanAppCam[0].Customer_Code__c == null ? 'N/A' : LoanAppCam[0].Customer_Code__c);
                //Current Exposure
                //Existing Borrower Exposure
                //Existing OtherExposure
                //Existing Co-Borrower Exposure
				//Total Exposure
                
            }else{
                newmap.put('Branch Name / StateName','N/A');
                //Executive Name
                //Weighted IRR (YTD)
                //Productivity (YTD)
				newmap.put('Application No','N/A');
                //newmap.put('Loan Application No','N/A');
                //Loan Application Number
                //Applicant Name
                //Customer type
                newmap.put('Customer Code','N/A');
				//Current Exposure
                //Existing Borrower Exposure
                //Existing OtherExposure
                //Existing Co-Borrower Exposure
				//Total Exposure
				 
            }
            
            /*for(String key: newmap.keySet()){
            if(LoanAppCam.size() > 0){
                list<String> LoanApplst= new List<String>();
                LoanApplst.add(newmap.get(key));
                Details.put(key,LoanApplst);
            }else{
                list<String> LoanApplst= new List<String>();
                LoanApplst.add('N/A');
                LoanApplst.add('-');
                Details.put(key,LoanApplst);
            }
			
        }*/
        return newmap;
    }
}