/*------------------------------------------------------------
Author: Bhushan Charde
Company: Persistent Systems
Description: This class is wrapper class for the ENACH Registration Status Response
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
12-28-2021    Bhushan Charde            Created
------------------------------------------------------------*/
public class IND_ENACHRegistrationStatusResponse extends ParentAPIResponse {
    
    public String Dcustomerbank{get;set;}
	public String DcustomerbankIFSCI{get;set;}
	public String endDate{get;set;}
	public String session{get;set;}
	public String fluxmessage{get;set;}
	public String urmn{get;set;}
	public String CIFID{get;set;}
	public String DealNo{get;set;}
	public String message{get;set;}
	public String Dcustomername{get;set;}
	public String frequency{get;set;}
	public String DcustomerAcc{get;set;}
	public String npcirejectreason{get;set;}
	public String emi_amount{get;set;}
	public String customerEmail{get;set;}
	public String referralCode{get;set;}
	public String max_amount{get;set;}
	public String digioID{get;set;}
	public String updatetime{get;set;}
	public String customerMobile{get;set;}
	public String startDate{get;set;}
	public String fluxstatus{get;set;}  
}