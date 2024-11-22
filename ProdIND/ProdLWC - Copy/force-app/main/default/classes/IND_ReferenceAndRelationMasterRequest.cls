public class IND_ReferenceAndRelationMasterRequest extends ParentAPIRequest {
    
    public refInfo refInfo{get;set;}
	public list<relInfo> relInfo{get;set;}
    public class relInfo{
		public String Relationship_With_Hirer{get;set;}
		public String Preference{get;set;}
		public String Active_Flag{get;set;}
		public String Relation_Type{get;set;}
		public String Active_Flag_Maker_Date{get;set;}
		public String Relation_Code{get;set;}
		public String Active_Flag_Remarks{get;set;}
		public String Deal_No{get;set;}
	}
    public class refInfo{
		public String Checker_Date{get;set;}
		public String Product{get;set;}
		public String Bl_Code{get;set;}
		public String Reference_Type{get;set;}
		public String Active_Flag{get;set;}
		public String Customer_Code{get;set;}
		public String Maker_Id{get;set;}
		public String Reference_Description{get;set;}
		public String Checker_Id{get;set;}
		public String Reference_No{get;set;}
	}
    public IND_ReferenceAndRelationMasterRequest(String loanAppId, String vehicleId){
        if( loanAppId != null){
            Boolean isCoBorrowerExists = false; 
            Boolean isGuarantorExists = false; //SFTRAC-1710
            Opportunity opptyDetails = [Select Id,Employee_No__c,DSM_Incentive1__c,Agent_BL_code__c,DSM_Name1__c,DSM_Incentive2__c,DSM_Name2__c,DSA_pay__c, 
                                        Deal_Number__c, Customer_Code__c, Application_number__c, Vehicle_Type__c, LTV__c, Invoice__c,
                                        Vehicle_Sub_Category__c, Funding_on_Ex_Showroom__c, Funding_on_ORP__c, Required_ROI__c,
                                        Advance_EMI__c, Imputed_IRR__c, Net_LTV__c, Gross_LTV__c, Basic_Price__c,
                                        RTO_Road_Tax__c, RTO_Road_Tax_New__c, X1st_yr_Insurance_Premium__c, Other_Charges__c, GST_Amount__c, NOC_Number__c,
                                        Finance_Amount__c, Product_Type__c, Discount_on_Basic_Price__c, Total_Funded_Premium__c, Parent_Deal_number__c, LeadSource,Lead_number__c,Performance_Upgrade__c,FAME_Subsidy__c
                                        From Opportunity Where Id =:loanAppId LIMIT 1 ];
            //SFTRAC-1710
            List<Vehicle_Detail__c> vechileDetailList = new List<Vehicle_Detail__c>();
            if(String.isNotBlank(vehicleId)){
                vechileDetailList = [SELECT Id,Make__c, Model__c, Variant__c, Deal_Number__c, Deal_Number__r.Deal_Number__c,Deal_Number__r.Deal_Number_Tractor__c from Vehicle_Detail__c WHERE Loan_Application__c =: loanAppId AND Id =: vehicleId AND Approval_Status__c = 'Approved' LIMIT 1];
            }else{
                vechileDetailList = [SELECT Id,Make__c, Model__c, Variant__c, Deal_Number__c, Deal_Number__r.Deal_Number__c,Deal_Number__r.Deal_Number_Tractor__c from Vehicle_Detail__c WHERE Loan_Application__c =: loanAppId LIMIT 1];
            }

            Applicant__c borrowerDetails = new Applicant__c();
            Applicant__c coBorrowerDetails = new Applicant__c();
            Applicant__c guarantorDetails = new Applicant__c(); //SFTRAC-1710
            List<Applicant__c> applicantDetailsList = new List<Applicant__c>([Select Id, Name,Spouse_Name__c,Mother_s_name__c,Employee_Name__c,Applicant_Type__c, 
                                                                              Income_Source__c,Customer_Code__c,Relationship_with_borrower__c,Father_s_name__c,applicant_number__c,
                                                                              Consent_Received__c,CASA_Consent_Received__c
                                                                              From Applicant__c Where Opportunity__c =:loanAppId and In_Active_Applicant__c = false]);
            for(Applicant__c applicant : applicantDetailsList){
                if(applicant.Applicant_Type__c == Label.Borrower){
                    borrowerDetails = applicant;
                }else if(applicant.Applicant_Type__c == Label.CoBorrower){
                    coBorrowerDetails = applicant;isCoBorrowerExists = true;
                }else if(applicant.Applicant_Type__c == Label.Guarantor && opptyDetails.Product_Type__c == 'Tractor'){ //SFTRAC-1710
                    guarantorDetails = applicant;isGuarantorExists = true;
                }
            }
            refInfo refData = new refInfo();
            //SFTRAC-1710 added Tractor condition
            if(opptyDetails.Product_Type__c == 'Tractor'){
                refdata.Product = 'T';
                refdata.Reference_No = vechileDetailList[0].Deal_Number__r.Deal_Number__c;
            }else{
                refdata.Product = opptyDetails.Product_Type__c == 'Two Wheeler' ? 'H' : 'C';
            refdata.Reference_No = opptyDetails.Deal_Number__c;
            }

            //refdata.Reference_No = opptyDetails.Deal_Number__c;   //Commented because added above
            refdata.Reference_Description = borrowerDetails.Name;
            refdata.Customer_Code = borrowerDetails.Customer_Code__c;
            refdata.Checker_Date = String.valueOf(Datetime.now());
            //refdata.Product = opptyDetails.Product_Type__c == 'Two Wheeler' ? 'H' : 'C';  //Commented because added above
            refdata.Bl_Code = opptyDetails.Agent_BL_code__c;
            refdata.Reference_Type = 'H';
            refdata.Active_Flag = 'Y';
            refdata.Maker_Id = IntegrationUtilities.getMakerId();
            refdata.Checker_Id = IntegrationUtilities.getMakerId();
            this.refInfo = refdata;
            List<relInfo> relInfoList = new List<relInfo>();
            if(isCoBorrowerExists){
                relInfo relInfoCoBorObj = new relInfo();
                //relInfoCoBorObj.Deal_No = opptyDetails.Deal_Number__c;
                relInfoCoBorObj.Deal_No = opptyDetails.Product_Type__c == 'Tractor' ? vechileDetailList[0].Deal_Number__r.Deal_Number__c : opptyDetails.Deal_Number__c;
                relInfoCoBorObj.Active_Flag_Remarks = 'CB_UNIFIED_RECTI_CW7140825';
                relInfoCoBorObj.Relation_Code = coBorrowerDetails.Customer_Code__c;
                relInfoCoBorObj.Active_Flag_Maker_Date = String.valueOf(Datetime.now());
                relInfoCoBorObj.Relation_Type = opptyDetails.Product_Type__c == 'Tractor' ? 'CB' : 'GU' ;
                relInfoCoBorObj.Active_Flag = 'Y';
                relInfoCoBorObj.Relationship_With_Hirer = coBorrowerDetails.Relationship_with_borrower__c != null ?coBorrowerDetails.Relationship_with_borrower__c: 'OTHERS';
                relInfoCoBorObj.Preference = '1';
                relInfoList.add(relInfoCoBorObj);
            }
            //SFTRAC-1710 only for Tractor starts
            if(isGuarantorExists && opptyDetails.Product_Type__c == 'Tractor'){
                relInfo relInfoCoBorObj = new relInfo();
                relInfoCoBorObj.Deal_No = opptyDetails.Product_Type__c == 'Tractor' ? vechileDetailList[0].Deal_Number__r.Deal_Number__c : opptyDetails.Deal_Number__c;
                relInfoCoBorObj.Active_Flag_Remarks = 'CB_UNIFIED_RECTI_CW7140825';
                relInfoCoBorObj.Relation_Code = guarantorDetails.Customer_Code__c;
                relInfoCoBorObj.Active_Flag_Maker_Date = String.valueOf(Datetime.now());
                relInfoCoBorObj.Relation_Type = 'GU' ;
                relInfoCoBorObj.Active_Flag = 'Y';
                relInfoCoBorObj.Relationship_With_Hirer = guarantorDetails.Relationship_with_borrower__c != null ?guarantorDetails.Relationship_with_borrower__c: 'OTHERS';
                relInfoCoBorObj.Preference = '1';
                relInfoList.add(relInfoCoBorObj);
            }//SFTRAC-1710 only for Tractor End

            this.relInfo = relInfoList;
            System.debug('refInfo--' + this.refInfo);
            System.debug('relInfo--' + this.relInfo);
        }else{
            throw new IND_Exception(System.Label.OpportunityIdMissing);
        }
    }
    
     public override Map<String,String> getHttpRequestHeaders(){    
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }
}