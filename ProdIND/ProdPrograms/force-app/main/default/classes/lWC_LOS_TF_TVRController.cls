public without sharing class lWC_LOS_TF_TVRController {
    
    @AuraEnabled(cacheable=true)
    public static List<TVRFieldWrapper> getFieldsValue(String tvrId){
        System.debug('TVR Id received >> '+tvrId);
        List<TVRFieldWrapper> FieldWrapperList = new List<TVRFieldWrapper>();
        try {
            List<TeleVerification__c> tvrList = [SELECT Id, Case__c, Applicant__c, Loan_Application__c, Field_Investigation__c, Customer_Name_Verification__c, Application_No_Verification__c, Mobile_No_Verification__c, Loan_Amount_Verification__c, Tenure_Verification__c, Invoice_Amount_Verification__c, Repayment_Frequency_Verification__c, BE_visited_your_house_Verification__c, Asset_use_for_Verification__c, Asset_Details_Verification__c, Customer_Current_Address_Verification__c, Customer_Permanent_Address_Verification__c, CoApplicant_Verification__c, Margin_Money_Paid_Verification__c, Margin_Money_Paid_by_Verification__c, TVR_Status__c, TVR_Observation__c
                                                    FROM TeleVerification__c
                                                    WHERE Id =: tvrId 
                                                    WITH SECURITY_ENFORCED];
            Id tvrCaseId = tvrList[0].Case__c;
            Id tvrApplicantId =  tvrList[0].Applicant__c;
            Id tvrLoanId = tvrList[0].Loan_Application__c;
            Id fiId = tvrList[0].Field_Investigation__c;

            List<Applicant__c> app = [SELECT Id, Name, Opportunity__r.Application_number__c, Contact_number__c FROM Applicant__c WHERE Id =: tvrApplicantId WITH SECURITY_ENFORCED LIMIT 1];
            // List<Opportunity> opp = [SELECT Id, Loan_amount__c, Required_Tenure__c FROM Opportunity WHERE Id =: tvrLoanId WITH SECURITY_ENFORCED LIMIT 1];
            // List<Repayments__c> repayment = [SELECT Id, Frequency__c FROM Repayments__c WHERE Loan_Application__c =: tvrLoanId WITH SECURITY_ENFORCED LIMIT 1];
            // List<Invoice_Details__c> invoice = [SELECT Id, Invoice_Amount_incl_discount__c FROM Invoice_Details__c WHERE Loan_Application__c =: tvrLoanId WITH SECURITY_ENFORCED LIMIT 1];
            List<Field_Investigation__c> fiRec = [SELECT Id, Coordinates_Verified__c, viability_of_proposed_TractorHarvester__c FROM Field_Investigation__c WHERE Id =: fiId WITH SECURITY_ENFORCED LIMIT 1];
            
            if(app.size()>0){
                FieldWrapperList.add(new TVRFieldWrapper('applicant_number','Application No.',app[0].Opportunity__r.Application_number__c,'picklist'));
                FieldWrapperList.add(new TVRFieldWrapper('Name','Customer Name',app[0].Name,'picklist'));
                FieldWrapperList.add(new TVRFieldWrapper('Contact_number','Mobile No.',app[0].Contact_number__c,'picklist'));
            }

            // if(opp.size()>0){
            //     FieldWrapperList.add(new TVRFieldWrapper('Loan_Amount','Loan Amount',opp[0].Loan_Amount__c,'picklist'));
            //     FieldWrapperList.add(new TVRFieldWrapper('Required_Tenure','Tenure',String.valueOf(opp[0].Required_Tenure__c),'picklist'));
            // }

            // if(repayment.size()>0){
            //     FieldWrapperList.add(new TVRFieldWrapper('Frequency','Repayment Frequency',repayment[0].Frequency__c,'picklist'));
            // }

            // if(invoice.size()>0){
            //     FieldWrapperList.add(new TVRFieldWrapper('Invoice_Amount_incl_discount','Invoice Amount',invoice[0].Invoice_Amount_incl_discount__c,'picklist'));
            // }

            if(fiRec.size()>0){
                FieldWrapperList.add(new TVRFieldWrapper('Coordinates_Verified','Asset use for',fiRec[0].Coordinates_Verified__c,'picklist'));
                FieldWrapperList.add(new TVRFieldWrapper('viability_of_proposed_TractorHarvester','BE visited your house',fiRec[0].viability_of_proposed_TractorHarvester__c,'picklist'));
            }else{
                FieldWrapperList.add(new TVRFieldWrapper('Coordinates_Verified','Asset use for','','picklist'));
                FieldWrapperList.add(new TVRFieldWrapper('viability_of_proposed_TractorHarvester','BE visited your house','','picklist'));
            }
            
            if(!(tvrList[0].TVR_Status__c == '' || tvrList[0].TVR_Status__c == null)){
                for(TVRFieldWrapper wrap: FieldWrapperList){
                    if(wrap.name == 'applicant_number'){
                        wrap.verification = tvrList[0].Application_No_Verification__c;
                    }else if(wrap.name == 'Name'){
                        wrap.verification = tvrList[0].Customer_Name_Verification__c;
                    }else if(wrap.name == 'Contact_number'){
                        wrap.verification = tvrList[0].Mobile_No_Verification__c;
                    }else if(wrap.name == 'Loan_Amount'){
                        wrap.verification = tvrList[0].Loan_Amount_Verification__c;
                    }else if(wrap.name == 'Required_Tenure'){
                        wrap.verification = tvrList[0].Tenure_Verification__c;
                    }else if(wrap.name == 'Frequency'){
                        wrap.verification = tvrList[0].Repayment_Frequency_Verification__c;
                    }else if(wrap.name == 'Invoice_Amount_incl_discount'){
                        wrap.verification = tvrList[0].Invoice_Amount_Verification__c;
                    }else if(wrap.name == 'Coordinates_Verified'){
                        wrap.verification = tvrList[0].BE_visited_your_house_Verification__c;
                    }else if(wrap.name == 'viability_of_proposed_TractorHarvester'){
                        wrap.verification = tvrList[0].Asset_use_for_Verification__c;
                    }
                }
            }

            return FieldWrapperList;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    public class TVRFieldWrapper{
        @AuraEnabled
        public Integer index{get;set;}
        @AuraEnabled
        public String name{get;set;}
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public String value{get;set;}
        @AuraEnabled
        public Boolean isPicklist{get;set;}
        @AuraEnabled
        public Boolean isText{get;set;}
        @AuraEnabled
        public String verification{get;set;}

        public TVRFieldWrapper(Integer index, String name, String label, String value){
            this.index = index;
            this.name = name;
            this.label = label;
            this.value = value;
        }

        public TVRFieldWrapper(String name, String label, String value, String type){
            this.name = name;
            this.label = label;
            this.value = value;
            if(type == 'picklist'){
                this.isPicklist = true;
            }else if(type == 'text'){
                this.isText = true;
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<CoApplicantWrapper> getCoApplicantList(String tvrId){
        List<CoApplicantWrapper> applicantWrapperLst = new  List<CoApplicantWrapper>();
        try {
            List<TeleVerification__c> tvrList = [SELECT Id, Case__c, Applicant__c, Loan_Application__c
                                                    FROM TeleVerification__c
                                                    WHERE Id =: tvrId 
                                                    WITH SECURITY_ENFORCED];
            for(Applicant__c app: [SELECT Id, Name, Applicant_Type__c, Relationship_with_borrower__c FROM Applicant__c WHERE Opportunity__c =: tvrList[0].Loan_Application__c AND ID != :tvrList[0].Applicant__c AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED]){
                applicantWrapperLst.add(new CoApplicantWrapper(app.Name, app.Applicant_Type__c, app.Relationship_with_borrower__c));
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return applicantWrapperLst;
    }

    public class CoApplicantWrapper{
        @AuraEnabled
        public String name{get;set;}
        @AuraEnabled
        public String relation{get;set;}
        @AuraEnabled
        public String type{get;set;}

        public CoApplicantWrapper(String name, String type, String relation){
            this.name = name;
            this.relation = relation;
            this.type = type;
        }
    }


    @AuraEnabled(cacheable=true)
    public static List<AssetWrapper> getAssetList(String tvrId){
        List<AssetWrapper> assetWrapperLst = new  List<AssetWrapper>();
        try {
            List<TeleVerification__c> tvrList = [SELECT Id, Case__c, Applicant__c, Loan_Application__c
                                                    FROM TeleVerification__c
                                                    WHERE Id =: tvrId 
                                                    WITH SECURITY_ENFORCED];
            for(Vehicle_Detail__c detail: [Select Id, Make__c, Model__c,Invoice_Price__c,(Select Id,Loan_Amount__c,Tenure__c,CRM_IRR__c,Installment_Frequency__c, EMI_Amount__c From Final_Terms__r LIMIT 1) from Vehicle_Detail__c WHERE Loan_Application__c =: tvrList[0].Loan_Application__c AND Approval_Status__c='Approved' WITH SECURITY_ENFORCED]){
                if(detail.Final_Terms__r.size()>0){
                    assetWrapperLst.add(new AssetWrapper(detail.Make__c, detail.Model__c, detail.Invoice_Price__c,detail.Final_Terms__r[0].Loan_Amount__c,detail.Final_Terms__r[0].Tenure__c,detail.Final_Terms__r[0].CRM_IRR__c,detail.Final_Terms__r[0].Installment_Frequency__c, String.valueOf(detail.Final_Terms__r[0].EMI_Amount__c)));
                }else{
                    assetWrapperLst.add(new AssetWrapper(detail.Make__c, detail.Model__c, detail.Invoice_Price__c,'','',0,'',''));
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return assetWrapperLst;
    }

    public class AssetWrapper{
        @AuraEnabled
        public String make{get;set;}
        @AuraEnabled
        public String model{get;set;}
        @AuraEnabled
        public Decimal invoicePrice{get;set;}
        @AuraEnabled
        public String loanAmount{get;set;}
        @AuraEnabled
        public String tenure{get;set;}
        @AuraEnabled
        public Decimal crmIRR{get;set;}
        @AuraEnabled
        public String installmentFrequency{get;set;}
        @AuraEnabled
        public String emiAmount{get;set;}

        public AssetWrapper(String make, String model, Decimal invoicePrice, String loanAmount,  String tenure, Decimal crmIRR, String installmentFrequency, String emiAmount){
            this.make = make;
            this.model = model;
            this.loanAmount = String.isNotBlank(loanAmount) ? loanAmount : '';
            this.invoicePrice = invoicePrice != null ? invoicePrice : null;
            this.tenure = String.isNotBlank(tenure) ? tenure : '';
            this.crmIRR = crmIRR != null ? crmIRR : null;
            this.installmentFrequency = String.isNotBlank(installmentFrequency) ? installmentFrequency : '';
            this.emiAmount = emiAmount;
        }
    }

    @AuraEnabled(Cacheable=true) 
    public static List<TVRFieldWrapper> getCurrentResidenceAddress(String tvrId){
        List<TVRFieldWrapper> fieldWrapperLst  = new List<TVRFieldWrapper>();
        try{
            List<TeleVerification__c> tvrList = [SELECT Id, Case__c, Applicant__c, Loan_Application__c
                                                        FROM TeleVerification__c
                                                        WHERE Id =: tvrId 
                                                        WITH SECURITY_ENFORCED];
            List<Documents__c> documentList = [SELECT Id,
                                            KYC_Address_Line_1__c,KYC_Address_Line_2__c,KYC_City__c,
                                            KYC_Pin_Code__c, KYC_State__c, KYC_District__c
                                            FROM Documents__c
                                            WHERE Applicant__c = :tvrList[0].Applicant__c AND  
                                            Current_Residential_Address_Proof__c=true LIMIT 1];
            fieldWrapperLst.add(new TVRFieldWrapper(0,'KYC_Address_Line_1__c', 'Address Line 1', documentList[0].KYC_Address_Line_1__c));
            fieldWrapperLst.add(new TVRFieldWrapper(1,'KYC_Address_Line_2__c', 'Address Line 2', documentList[0].KYC_Address_Line_2__c));
            fieldWrapperLst.add(new TVRFieldWrapper(2,'KYC_City__c', 'City', documentList[0].KYC_City__c));
            fieldWrapperLst.add(new TVRFieldWrapper(3,'KYC_District__c', 'District', documentList[0].KYC_District__c));
            fieldWrapperLst.add(new TVRFieldWrapper(4,'KYC_State__c', 'State', documentList[0].KYC_State__c));
            fieldWrapperLst.add(new TVRFieldWrapper(5,'KYC_Pin_Code__c', 'Pin Code', documentList[0].KYC_Pin_Code__c));
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        return fieldWrapperLst;
    }

    @AuraEnabled(Cacheable=true) 
    public static List<TVRFieldWrapper> getResidenceAddress(String tvrId, String addressType){
        List<TVRFieldWrapper> fieldWrapperLst  = new List<TVRFieldWrapper>();
        try{
            List<TeleVerification__c> tvrList = [SELECT Id, Case__c, Applicant__c, Loan_Application__c
                                                        FROM TeleVerification__c
                                                        WHERE Id =: tvrId 
                                                        WITH SECURITY_ENFORCED];
            List<Documents__c> documentList = new List<Documents__c>();
            if(addressType == 'current'){
                documentList = [SELECT Id,KYC_Address_Line_1__c,KYC_Address_Line_2__c,KYC_City__c,KYC_Pin_Code__c, KYC_State__c, KYC_District__c
                                FROM Documents__c
                                WHERE Applicant__c = :tvrList[0].Applicant__c AND Current_Residential_Address_Proof__c = true 
                                LIMIT 1];
            }else if(addressType == 'permanent'){
                documentList = [SELECT Id,KYC_Address_Line_1__c,KYC_Address_Line_2__c,KYC_City__c,KYC_Pin_Code__c, KYC_State__c, KYC_District__c
                                FROM Documents__c
                                WHERE Applicant__c = :tvrList[0].Applicant__c AND Permanent_Residential_Address_Proof__c = true 
                                LIMIT 1];
            }
            if(documentList.size()>0){
                fieldWrapperLst.add(new TVRFieldWrapper(0,'KYC_Address_Line_1__c', 'Address Line 1', documentList[0].KYC_Address_Line_1__c));
                fieldWrapperLst.add(new TVRFieldWrapper(1,'KYC_Address_Line_2__c', 'Address Line 2', documentList[0].KYC_Address_Line_2__c));
                fieldWrapperLst.add(new TVRFieldWrapper(2,'KYC_City__c', 'City', documentList[0].KYC_City__c));
                fieldWrapperLst.add(new TVRFieldWrapper(3,'KYC_District__c', 'District', documentList[0].KYC_District__c));
                fieldWrapperLst.add(new TVRFieldWrapper(4,'KYC_State__c', 'State', documentList[0].KYC_State__c));
                fieldWrapperLst.add(new TVRFieldWrapper(5,'KYC_Pin_Code__c', 'Pin Code', documentList[0].KYC_Pin_Code__c));
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return fieldWrapperLst;
    }

    @AuraEnabled
    public static void saveTVR(List<TVRList> tvrList, String tvrId){
        System.debug('SAVE LIST RECEIVED >>> '+tvrList);
        try {
            List<TeleVerification__c> teleRec = [SELECT Id, Case__c, Customer_Name_Verification__c, Application_No_Verification__c, Mobile_No_Verification__c, Loan_Amount_Verification__c, Tenure_Verification__c, Repayment_Frequency_Verification__c, Invoice_Amount_Verification__c, BE_visited_your_house_Verification__c, Asset_use_for_Verification__c, Asset_Details_Verification__c, Customer_Current_Address_Verification__c, Customer_Permanent_Address_Verification__c, CoApplicant_Verification__c, Margin_Money_Paid_Verification__c, Margin_Money_Paid_by_Verification__c, TVR_Status__c, TVR_Observation__c
                                                    FROM TeleVerification__c
                                                    WHERE Id =: tvrId 
                                                    WITH SECURITY_ENFORCED];
            teleRec[0].Id = tvrId;
            for(TVRList item: tvrList){
               if(item.name == 'applicant_number'){
                teleRec[0].Application_No_Verification__c = item.value;
               }else if(item.name == 'Contact_number'){
                teleRec[0].Mobile_No_Verification__c = item.value;
               }else if(item.name == 'Name'){
                teleRec[0].Customer_Name_Verification__c = item.value;
               }else if(item.name == 'Loan_amount'){
                teleRec[0].Loan_Amount_Verification__c = item.value;
               }else if(item.name == 'Required_Tenure'){
                teleRec[0].Tenure_Verification__c = item.value;
               }else if(item.name == 'Frequency'){
                teleRec[0].Repayment_Frequency_Verification__c = item.value;
               }else if(item.name == 'Coordinates_Verified'){
                teleRec[0].BE_visited_your_house_Verification__c = item.value;
               }else if(item.name == 'viability_of_proposed_TractorHarvester'){
                teleRec[0].Asset_use_for_Verification__c = item.value;
               }else if(item.name == 'Asset_Details'){
                teleRec[0].Asset_Details_Verification__c = item.value;
               }else if(item.name == 'CoApplicant_Details'){
                teleRec[0].CoApplicant_Verification__c = item.value;
               }else if(item.name == 'Current_Address'){
                teleRec[0].Customer_Current_Address_Verification__c = item.value;
               }else if(item.name == 'permanent_Address'){
                teleRec[0].Customer_Permanent_Address_Verification__c = item.value;
               }else if(item.name == 'TVR_Observation'){
                teleRec[0].TVR_Observation__c = item.value;
               }else if(item.name == 'TVR_Status'){
                teleRec[0].TVR_Status__c = item.value;
               }else if(item.name == 'Margin_Money_Paid'){
                teleRec[0].Margin_Money_Paid_Verification__c = item.value;
               }else if(item.name == 'Margin_Money_Paid_by'){
                teleRec[0].Margin_Money_Paid_by_Verification__c = item.value;
               }else if(item.name == 'Invoice_Amount_incl_discount'){
                teleRec[0].Invoice_Amount_Verification__c = item.value;
               }
               //Invoice_Amount_incl_discount
            }

            if(teleRec.size()>0){
                update teleRec;
            }

            List<Case> tvrCaseLst = [SELECT Id, Status FROM Case WHERE Id =:teleRec[0].Case__c WITH SECURITY_ENFORCED];
            if(teleRec[0].TVR_Status__c == 'Positive'){
                tvrCaseLst[0].Status = 'Pass';
            }else{
                tvrCaseLst[0].Status = 'High Risk';
            }

            if(tvrCaseLst.size()>0){
                update tvrCaseLst;
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class TVRList{
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String value {get;set;}
    }
}