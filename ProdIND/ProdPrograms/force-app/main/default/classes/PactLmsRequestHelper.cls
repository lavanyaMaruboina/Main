public class PactLmsRequestHelper {
    // public String loanAppId {get;set;} 
     public ObjReqPR objReqPR{get;set;}
     public class ObjPRBList {
        public String Deal_No{get;set;}
        public String Beneficiary_Code{get;set;}
        public String Beneficiary_Name{get;set;}
        public Decimal Amount{get;set;}
        public Integer SNo{get;set;}
        public String Account_No{get;set;}
    }
   public class ObjReqPR{
        public List<ObjPRBList> objPRBList;
        public List<ObjPRInsList> ObjPRInsList;
    }
          public  PactLmsRequestHelper(string loanAppId,Opportunity opptyDetails,List<Vehicle_Detail__c> vehDetailList,List<LoanDisbursementDetails__c> loanDisbursDetailList,List<Applicant__c> applicantDetailsList,List<Final_Term__c> finalTermList,List<Invoice_Details__c> invoiceDetailsList,Applicant__c borrowerDetails,Applicant__c coBorrowerDetails,String dealNumber){
             // if( loanAppId != null){
           // this.loanAppId = loanAppId;
            this.ObjReqPR=new ObjReqPR();
    //IND_PactLmsRequest.ObjPRBList ObjPRBList = new IND_PactLmsRequest.ObjPRBList();
      List<ObjPRBList> ObjPRBList = new List<ObjPRBList>(); 
            if(loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Beneficiary_1__c != null
               && loanDisbursDetailList[0].Beneficiary_1__c != '' && loanDisbursDetailList[0].Beneficiary_1_Amount__c != null && Integer.valueOf(loanDisbursDetailList[0].Beneficiary_1_Amount__c) != 0){//CISP-2534 - Added in the if condition Amount not equals to zero.
                   ObjPRBList ObprbList1 = new ObjPRBList();
                   ObprbList1.Deal_No= dealNumber;
                  ObprbList1 = setBenCodeBenName(ObprbList1, loanDisbursDetailList[0].Beneficiary_1_Type__c, finalTermList[0], vehDetailList[0], loanDisbursDetailList[0], loanDisbursDetailList[0].Beneficiary_1__c, borrowerDetails, coBorrowerDetails);
                   if(loanDisbursDetailList[0].Beneficiary_1_Type__c == 'MDR' || loanDisbursDetailList[0].Beneficiary_1_Type__c == 'SDR' || loanDisbursDetailList[0].Beneficiary_1_Type__c == 'SSP' || loanDisbursDetailList[0].Beneficiary_1_Type__c=='MFR'){
                       obprbList1.Beneficiary_Code = invoiceDetailsList[0].Ben_Code_Of_Main_dealer__c; 
                   }
                   ObprbList1.Amount= loanDisbursDetailList.size() > 0 ? loanDisbursDetailList[0].Beneficiary_1_Amount__c : 0;
                   ObprbList1.SNo= 1;
                   ObprbList1.Account_No= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Beneficiary_1_Account_Number__c != null ? String.valueOf(loanDisbursDetailList[0].Beneficiary_1_Account_Number__c) : '';
                   if(loanDisbursDetailList[0].Beneficiary_1_Type__c == 'Borrower' || loanDisbursDetailList[0].Beneficiary_1_Type__c == 'Coborrower' || loanDisbursDetailList[0].Beneficiary_1_Type__c == 'Seller' || loanDisbursDetailList[0].Beneficiary_1_Type__c == 'Bank'){
                    //ObprbList1.Beneficiary_Name = ObprbList1.Beneficiary_Name + ' A/C ' + ObprbList1.Account_No;//Here we add the A/C and removed from obprbList.Beneficiary_Name.// start CISP-3564  
                       // Here we check if the BeneficiaryName length is greaterthan 60 then we pass the BeneficiaryName only.
                       string Beneficiaryname= ObprbList1.Beneficiary_Name + ' A/C ' + ObprbList1.Account_No;//Here we add the A/C and removed from obprbList.Beneficiary_Name.  
                       if(Beneficiaryname.length() >= 60){
                          //system.debug('Result is:'+ Beneficiaryname);
                          ObprbList1.Beneficiary_Name = ObprbList1.Beneficiary_Name; 
                       }else{
                          ObprbList1.Beneficiary_Name = Beneficiaryname;  
                       }// end CISP-3564 
                   }
                   ObjPRBList.add(ObprbList1);
               }
            if(loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Beneficiary_2__c != null
               && loanDisbursDetailList[0].Beneficiary_2__c != '' && loanDisbursDetailList[0].Beneficiary_2_Amount__c != null && Integer.valueof(loanDisbursDetailList[0].Beneficiary_2_Amount__c) != 0){//CISP-2534 - Added in the if condition Amount not equals to zero.
                   ObjPRBList ObprbList2 = new ObjPRBList();
                   ObprbList2.Deal_No= dealNumber;
                   if(opptyDetails.LeadSource == 'OLA'){
                    obprbList2.Beneficiary_Name = loanDisbursDetailList[0].Beneficiary_2__c; //OLA-107
                    obprbList2.Beneficiary_Code = loanDisbursDetailList[0].Beneficiary_2_Account_Number__c; //OLA-107
                   }else{
                  ObprbList2 =setBenCodeBenName(ObprbList2, loanDisbursDetailList[0].Beneficiary_2_Type__c, finalTermList[0], vehDetailList[0], loanDisbursDetailList[0], loanDisbursDetailList[0].Beneficiary_2__c, borrowerDetails, coBorrowerDetails);
                   }
                   ObprbList2.Amount= loanDisbursDetailList.size() > 0 ? loanDisbursDetailList[0].Beneficiary_2_Amount__c : 0;
                   ObprbList2.SNo= 2;
                   ObprbList2.Account_No= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Beneficiary_2_Account_Number__c != null ? String.valueOf(loanDisbursDetailList[0].Beneficiary_2_Account_Number__c) : '';
                   if(loanDisbursDetailList[0].Beneficiary_2_Type__c == 'Borrower' || loanDisbursDetailList[0].Beneficiary_2_Type__c == 'Coborrower' || loanDisbursDetailList[0].Beneficiary_2_Type__c == 'Seller' || loanDisbursDetailList[0].Beneficiary_2_Type__c == 'Bank'){
                       // ObprbList2.Beneficiary_Name = ObprbList2.Beneficiary_Name + ' A/C ' + ObprbList2.Account_No;//Here we add the A/C and removed from obprbList.Beneficiary_Name.// start CISP-3564  
                     // Here we check. if the BeneficiaryName length is greaterthan 60 then we palce the BeneficiaryName only.
                      string Beneficiaryname= ObprbList2.Beneficiary_Name + ' A/C ' + ObprbList2.Account_No;//Here we add the A/C and removed from obprbList.Beneficiary_Name. 
                       if(Beneficiaryname.length() >= 60){
                        // system.debug('Result is:'+ Beneficiaryname);
                          ObprbList2.Beneficiary_Name = ObprbList2.Beneficiary_Name; 
                       }else{
                          ObprbList2.Beneficiary_Name = Beneficiaryname;  
                       } // end CISP-3564 
                   }
                   ObjPRBList.add(ObprbList2);
               }
            if(loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Beneficiary_3__c != null
               && loanDisbursDetailList[0].Beneficiary_3__c != '' && loanDisbursDetailList[0].Beneficiary_3_Amount__c != null && Integer.valueof(loanDisbursDetailList[0].Beneficiary_3_Amount__c) != 0){//CISP-2534 - Added in the if condition Amount not equals to zero.
                   ObjPRBList ObprbList3 = new ObjPRBList();
                   ObprbList3.Deal_No= dealNumber;
                   ObprbList3 = setBenCodeBenName(ObprbList3, loanDisbursDetailList[0].Beneficiary_3_Type__c, finalTermList[0], vehDetailList[0], loanDisbursDetailList[0], loanDisbursDetailList[0].Beneficiary_3__c, borrowerDetails, coBorrowerDetails);
                   ObprbList3.Amount= loanDisbursDetailList.size() > 0 ? loanDisbursDetailList[0].Beneficiary_3_Amount__c : 0;
                   ObprbList3.SNo= 3;
                   ObprbList3.Account_No= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Beneficiary_3_Account_Number__c != null ? String.valueOf(loanDisbursDetailList[0].Beneficiary_3_Account_Number__c) : '';
                   if(loanDisbursDetailList[0].Beneficiary_3_Type__c == 'Borrower' || loanDisbursDetailList[0].Beneficiary_3_Type__c == 'Coborrower' || loanDisbursDetailList[0].Beneficiary_3_Type__c == 'Seller' || loanDisbursDetailList[0].Beneficiary_3_Type__c == 'Bank'){
                       // ObprbList3.Beneficiary_Name = ObprbList3.Beneficiary_Name + ' A/C ' + ObprbList3.Account_No;//Here we add the A/C and removed from obprbList.Beneficiary_Name.//start CISP-3564  
                   // Here we check. if the BeneficiaryName length is greaterthan 60 then we palce the BeneficiaryName only.
                       string Beneficiaryname= ObprbList3.Beneficiary_Name + ' A/C ' + ObprbList3.Account_No;//Here we add the A/C and removed from obprbList.Beneficiary_Name. 
                       if(Beneficiaryname.length() >= 60){
                          // system.debug('Result is:'+ Beneficiaryname);
                          ObprbList3.Beneficiary_Name = ObprbList3.Beneficiary_Name; 
                       }else{
                          ObprbList3.Beneficiary_Name = Beneficiaryname;  
                       } // end CISP-3564 
                   }
                   ObjPRBList.add(ObprbList3);
               }
              ObjPRBList=ObjPRBList;
            this.ObjReqPR.ObjPRBList=ObjPRBList; 

            List<ObjPRInsList> ObjPRInsList = new List<ObjPRInsList>();
            ObjPRInsList ObprinsList = new ObjPRInsList();
            
            ObprinsList.Deal_No= '';
            ObprinsList.Spouse_Name=  borrowerDetails.Spouse_Name__c != null ? borrowerDetails.Spouse_Name__c : '';
            ObprinsList.Spouse_Gender= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Borrower_Spouse_Gender__c != null ? (loanDisbursDetailList[0].Borrower_Spouse_Gender__c) : '';
            ObprinsList.Spouse_DOB= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Borrower_Spouse_DOB__c != null ? String.valueOf(loanDisbursDetailList[0].Borrower_Spouse_DOB__c) : '';
            ObprinsList.Child1_Name= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Borrower_X1st_Child_Name__c != null ? (loanDisbursDetailList[0].Borrower_X1st_Child_Name__c) : '';
            ObprinsList.Child1_Gender= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Borrower_X1st_Child_Gender__c != null ? (loanDisbursDetailList[0].Borrower_X1st_Child_Gender__c) : '';
            ObprinsList.Child1_DOB= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Borrower_X1st_Child_DOB__c != null ? String.valueOf(loanDisbursDetailList[0].Borrower_X1st_Child_DOB__c) : '';
            ObprinsList.Child2_Name=loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Borrower_X2nd_Child_Name__c != null ? (loanDisbursDetailList[0].Borrower_X2nd_Child_Name__c) : '';
            ObprinsList.Child2_Gender=loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Borrower_X2nd_Child_Gender__c != null ? (loanDisbursDetailList[0].Borrower_X2nd_Child_Gender__c) : '';
            ObprinsList.Child2_DOB= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Borrower_X2nd_Child_DOB__c != null ? String.valueOf(loanDisbursDetailList[0].Borrower_X2nd_Child_DOB__c) : '';
            ObprinsList.Child3_Name= loanDisbursDetailList.size() > 0  && loanDisbursDetailList[0].Borrower_X3rd_Child_Name__c != null ? (loanDisbursDetailList[0].Borrower_X3rd_Child_Name__c) : '';
            ObprinsList.Child3_Gender=loanDisbursDetailList.size() > 0  && loanDisbursDetailList[0].Borrower_X3rd_Child_Gender__c != null ? (loanDisbursDetailList[0].Borrower_X3rd_Child_Gender__c) : '';
            ObprinsList.Child3_DOB= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Borrower_X3rd_Child_DOB__c != null ? String.valueOf(loanDisbursDetailList[0].Borrower_X3rd_Child_DOB__c) : '';
            ObprinsList.Father_Name= borrowerDetails.Father_s_name__c;
            ObprinsList.Father_Gender= 'Male' ;
            ObprinsList.Father_DOB= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Borrower_Father_DOB__c != null ? String.valueOf(loanDisbursDetailList[0].Borrower_Father_DOB__c) : '';
            ObprinsList.Mother_Name=  borrowerDetails.Mother_s_name__c != null ? borrowerDetails.Mother_s_name__c : '';
            ObprinsList.Mother_Gender= 'Female';
            ObprinsList.Mother_DOB= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].Borrower_Mother_DOB__c != null ? String.valueOf(loanDisbursDetailList[0].Borrower_Mother_DOB__c) : '';
            ObprinsList.Spouse_Name_G= coborrowerDetails.Spouse_Name__c != null ? coborrowerDetails.Spouse_Name__c : '';
            ObprinsList.Spouse_Gender_G= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].CoBorrower_Spouse_Gender__c != null ? (loanDisbursDetailList[0].CoBorrower_Spouse_Gender__c) : '';
            ObprinsList.Spouse_DOB_G= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].CoBorrower_Spouse_DOB__c != null ? String.valueOf(loanDisbursDetailList[0].CoBorrower_Spouse_DOB__c) : '';
            ObprinsList.Child1_Name_G= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].CoBorrower_X1st_Child_Name__c != null ? (loanDisbursDetailList[0].CoBorrower_X1st_Child_Name__c) : '';
            ObprinsList.Child1_Gender_G= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].CoBorrower_X1st_Child_Gender__c != null ? (loanDisbursDetailList[0].CoBorrower_X1st_Child_Gender__c) : '';
            ObprinsList.Child1_DOB_G= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].CoBorrower_X1st_Child_DOB__c != null ? String.valueOf(loanDisbursDetailList[0].CoBorrower_X1st_Child_DOB__c) : '';
            ObprinsList.Child2_Name_G=loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].CoBorrower_X2nd_Child_Name__c != null ? (loanDisbursDetailList[0].CoBorrower_X2nd_Child_Name__c) : '';
            ObprinsList.Child2_Gender_G= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].CoBorrower_X2nd_Child_Gender__c != null ? (loanDisbursDetailList[0].CoBorrower_X2nd_Child_Gender__c) : '';
            ObprinsList.Child2_DOB_G= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].CoBorrower_X2nd_Child_DOB__c != null ? String.valueOf(loanDisbursDetailList[0].CoBorrower_X2nd_Child_DOB__c) : '';
            ObprinsList.Child3_Name_G= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].CoBorrower_X3rd_Child_Name__c != null?  (loanDisbursDetailList[0].CoBorrower_X3rd_Child_Name__c) : '';
            ObprinsList.Child3_Gender_G= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].CoBorrower_X3rd_Child_Gender__c != null ? (loanDisbursDetailList[0].CoBorrower_X3rd_Child_Gender__c) : '';
            ObprinsList.Child3_DOB_G= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].CoBorrower_X3rd_Child_DOB__c != null ? String.valueOf(loanDisbursDetailList[0].CoBorrower_X3rd_Child_DOB__c) : '';
            ObprinsList.Father_Name_G= coBorrowerDetails.Father_s_name__c != null ? coBorrowerDetails.Father_s_name__c : '';
            ObprinsList.Father_Gender_G= 'Male';
            ObprinsList.Father_DOB_G= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].CoBorrower_Father_DOB__c != null ? String.valueOf(loanDisbursDetailList[0].CoBorrower_Father_DOB__c) : '';
            ObprinsList.Mother_Name_G=  coBorrowerDetails.Mother_s_name__c != null ? coBorrowerDetails.Mother_s_name__c : '';
            ObprinsList.Mother_Gender_G= 'Female' ;
            ObprinsList.Mother_DOB_G= loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].CoBorrower_Mother_DOB__c != null ? String.valueOf(loanDisbursDetailList[0].CoBorrower_Mother_DOB__c) : '';
            ObprinsList.Maker_Id= Integer.valueOf(IntegrationUtilities.getMakerId()) ;
            ObprinsList.Maker_Date= String.valueOf(Datetime.now());
            ObprinsList.Ins_App_No= '';
            ObprinsList.Weight= borrowerDetails.Weight__c!=null ? Integer.valueOf(borrowerDetails.Weight__c) : 0;
            ObprinsList.Height= borrowerDetails.Height__c!=null ? Integer.valueOf(borrowerDetails.Height__c) : 0;
            ObprinsList.Weight_G= 0;
            ObprinsList.Height_G= 0;
            ObprinsList.Spouse_weight= 0;
            ObprinsList.Spouse_Height= 0;
            ObprinsList.Spouse_weight_G= 0;
            ObprinsList.Spouse_Height_G= 0;
            ObprinsList.Child1_weight= 0;
            ObprinsList.Child1_Height= 0;
            ObprinsList.Child1_weight_G= 0;
            ObprinsList.Child1_Height_G= 0;
            ObprinsList.Child2_weight= 0;
            ObprinsList.Child2_Height= 0;
            ObprinsList.Child2_weight_G= 0;
            ObprinsList.Child2_Height_G= 0;
            ObprinsList.Child3_weight= 0;
            ObprinsList.Child3_Height= 0;
            ObprinsList.Child3_weight_G= 0;
            ObprinsList.Child3_Height_G= 0;            
            ObjPRInsList.add(ObprinsList);
            ObjPRInsList=ObjPRInsList;
            this.ObjReqPR.ObjPRInsList=ObjPRInsList;
       }


     public static ObjPRBList setBenCodeBenName(ObjPRBList obprbList, String beneficiaryType, Final_Term__c finalTerm, Vehicle_Detail__c vehDetail, LoanDisbursementDetails__c loanDisbDetail, String beneficiary, Applicant__c borrower, Applicant__c coBorrower){
        if(beneficiaryType == 'DSA' && finalTerm != null){
            obprbList.Beneficiary_Name = finalTerm.Referrer_Name__c;
            obprbList.Beneficiary_Code = finalTerm.Referrer_Ben_Code__c != null ? finalTerm.Referrer_Ben_Code__c : '';
        } else if(beneficiaryType == 'Borrower' && borrower != null){
            obprbList.Beneficiary_Name = borrower.Name; // CISP-3564 Here removed A/C And added above Beneficiary name.
            obprbList.Beneficiary_Code = 'Paytocust';
        } else if(beneficiaryType == 'Coborrower' && coBorrower!= null){
            obprbList.Beneficiary_Name = coBorrower.Name; // CISP-3564 Here removed A/C And added above Beneficiary name.
            obprbList.Beneficiary_Code = 'Paytocust';
        } else if(beneficiaryType == 'Bank'){
            obprbList.Beneficiary_Name = loanDisbDetail.Beneficiary_1__c; // CISP-3564 Here removed A/C And added above Beneficiary name.
            obprbList.Beneficiary_Code = loanDisbDetail.Bank_Ben_Code__c;
        } else if(beneficiaryType == 'Seller' && loanDisbDetail != null){
            obprbList.Beneficiary_Name = loanDisbDetail.Vehicle_Sold_By__c; // CISP-3564 Here removed A/C And added above Beneficiary name.
            obprbList.Beneficiary_Code = 'UVHSeller';
        } else if(beneficiaryType == 'Dealer' && loanDisbDetail != null){
            obprbList.Beneficiary_Name = loanDisbDetail.Beneficiary_1__c;
            obprbList.Beneficiary_Code = vehDetail != null ? vehDetail.Ben_Code__c : '';
        } else if((beneficiaryType == 'MDR' || beneficiaryType == 'SDR' || beneficiaryType == 'SSP' || beneficiaryType == 'MFR') && loanDisbDetail != null){
            obprbList.Beneficiary_Name = loanDisbDetail.Beneficiary_1__c;
        }
        // Start CISP-9244 Trim the Beneficiary_Name value if it contains "|" 
        if (obprbList.Beneficiary_Name != null){
            String[] parts = obprbList.Beneficiary_Name.split('\\|');
            if (parts.size() > 0) {
                obprbList.Beneficiary_Name = parts[0].trim();
            }
        } // END CISP-9244
        return obprbList;
    }

    public static string getMainDealerBenCode(List<Invoice_Details__c> invoiceDetailsList,Opportunity opptyDetails){
        String mainDealerBenCode = '';
        if(invoiceDetailsList.size() > 0 && opptyDetails.LeadSource == 'OLA'){
            mainDealerBenCode  = invoiceDetailsList[0].Ben_Code_Of_Main_dealer__c ;//OLA-196
        }else if(invoiceDetailsList.size() > 0 && opptyDetails.LeadSource != 'D2C'){
            List<Benefi__c> benefiList = [select Id, Ben_code__c from Benefi__c where Id =: invoiceDetailsList[0].Main_Dealer__c]; //CISP-9890
            mainDealerBenCode  = benefiList.size() > 0 ? benefiList[0].Ben_code__c : '';
        }else if(invoiceDetailsList.size() > 0 && opptyDetails.LeadSource == 'D2C'){
            List<Benefi__c> benefiList = [select Id, Ben_code__c from Benefi__c where Id =: invoiceDetailsList[0].Payment_to_be_made__c]; //CISP-9890
            mainDealerBenCode  = benefiList.size() > 0 ? benefiList[0].Ben_code__c : '';
        }
        return mainDealerBenCode;
    }
    
     public static string getFinalTermsData(String loanAppId,String nameOfField){
        String mainDealerBenCode = '';
        List<Final_Term__c> finalTermList =  new List<Final_Term__c>([Select Id,Table_Code__c,DR_Penal_Interest__c,	Interest_Version_No__c,mclrRate__c
                                                                          From Final_Term__c Where Loan_Application__c =:loanAppId ]);
        if(finalTermList.size()>0){
            if(nameOfField == 'tableCode'){
            return finalTermList.size() > 0 && finalTermList[0].Table_Code__c != null ? finalTermList[0].Table_Code__c : '';
            }
            if(nameOfField == 'InterestVersionNo'){
                return finalTermList.size() > 0 && finalTermList[0].Interest_Version_No__c != null ? finalTermList[0].Interest_Version_No__c : '';
            }
            if(nameOfField == 'DrPenalInterest'){
                return finalTermList.size() > 0 && finalTermList[0].DR_Penal_Interest__c != null ? finalTermList[0].DR_Penal_Interest__c : null;
            }
            if(nameOfField == 'mclrRate'){
                return finalTermList.size() > 0 && finalTermList[0].mclrRate__c != null ? finalTermList[0].mclrRate__c : null;
            }
        }
        return mainDealerBenCode; 
    } 
    public static string getDealNumber(Opportunity opptyDetails,String dealId,Boolean isTractor){
        List<Deal_Number__c> dealNumberList = new List<Deal_Number__c>([Select Deal_Number__c,(Select id from Vehicle_Details__r LIMIT 1) from Deal_Number__c Where id =: dealId LIMIT 1]);
        if(isTractor == true && dealNumberList.size() > 0){
            return dealNumberList[0].Deal_Number__c;
        }else{
            return opptyDetails.Deal_Number__c;
        }
    }
    public static List<Vehicle_Detail__c> getVehicleDetails(String loanAppId,String dealId,Boolean isTractor){
        if(isTractor == true){
            return [Select Id,Valuer_category__c,RC_Hold_Amount__c,Ins_Expiry_date__c, Ben_Code__c,Dealer_Sub_dealer_name__c,Product__c, Loan_Application__c, Variant_Code__c, 
            Selling_Price__c, Manufacturer_Year_Month__c,Vehicle_Registration_number__c,Lien_in_favor_of__c,Insurance_type__c, Variant__c,
            Insurance_declared_value__c, Purpose_of_purchase__c,Vehicle_registered_in_the_name_of__c,Vehicle_Category__c,Valuation_price__c,
            Loan_Application__r.Product_Type__c, Insurer_name__c,Base_Prices__c , RC_limit_enabled_Dealer__c,Vehicle_SubCategory__c,Parent_Deal_Number__c,NOC_Number__c,SLA_Number__c,GST_Amount__c,X1st_yr_Insurance_Premium__c,Basic_Price__c
            From Vehicle_Detail__c Where Loan_Application__c =:loanAppId and Deal_Number__c =: dealId Limit 1];
        }else{
            return [Select Id,Valuer_category__c,Ins_Expiry_date__c, Ben_Code__c,Dealer_Sub_dealer_name__c,Product__c, Loan_Application__c, Variant_Code__c, 
            Selling_Price__c, Manufacturer_Year_Month__c,Vehicle_Registration_number__c,Lien_in_favor_of__c,Insurance_type__c, Variant__c,
            Insurance_declared_value__c, Purpose_of_purchase__c,Vehicle_registered_in_the_name_of__c,Vehicle_Category__c,Valuation_price__c,
            Loan_Application__r.Product_Type__c, Insurer_name__c,Base_Prices__c , RC_limit_enabled_Dealer__c
            From Vehicle_Detail__c Where Loan_Application__c =:loanAppId Limit 1];
        }
    }
    public static List<Final_Term__c> getFinalTermDetails(String loanAppId,String dealId,Boolean isTractor){
        if(isTractor == true){
            return [Select Id,Deal_No__c,Tenure__c, RCU_Retention_Charges__c,Stamping_charges__c,Repayment_mode__c,ECS_verification_by__c,
            Dealer_incentive_amount_sub_dealer__c,Branch__c,DSA_pay__c,Refered_By__c,Mfr_incentive__c,Gift_through_dealer_amount__c,Referrer_Ben_Code__c,
            Dealer_Disc_to_Customer__c,Due_date_shift_charges__c,Mfr_Exp_Reimburse_Amt__c,Mfr_Exp_Reimburse_Type__c,
            Provisional_Channel_Cost__c,Dealer_incentive_amount_main_dealer__c,Deliquency_Fund_type__c, Service_charges__c,
            Documentation_charges__c,Verification_charges__c,Loan_Amount__c, Holiday_period__c,Agreement_Amount__c, Rreferrer_Incentive__c, 
            CRM_IRR__c,Bank_IRR__c,Gross_IRR__c,Installment_Type__c,Trade_certificate__c,RTO_prefix__c,Scheme_Bank_offers__c, Calculated_Gross_LTV__c, Calculated_Net_LTV__c,
            Delinquency_Fund__c,EMI_Amount__c,DSM_Incentive1__c,Advance_EMI__c,DSM_Name1__c,DSM_Incentive2__c,DSM_Name2__c,Inputted_IRR__c, 
            Referrer_Name__c, Emp_Name__c, Emp_No__c, Net_IRR__c ,RC_limit_enabled_DSA__c,Required_CRM_IRR__c,No_of_Installment__c,Offer_Agreement_Amount__c,Funding_for_Chassis__c,Funding_for_Body__c,Loan_Deal_Date__c,Installment_Frequency__c,First_EMI_Date__c,Second_EMI_Date__c, Loan_Application__c
            From Final_Term__c Where Loan_Application__c =:loanAppId AND Vehicle_Detail__r.Deal_Number__c =: dealId LIMIT 1];
        }else{
            return [Select Id,Deal_No__c,Tenure__c, RCU_Retention_Charges__c,Stamping_charges__c,Repayment_mode__c,ECS_verification_by__c,
            Dealer_incentive_amount_sub_dealer__c,Branch__c,DSA_pay__c,Refered_By__c,Mfr_incentive__c,Gift_through_dealer_amount__c,Referrer_Ben_Code__c,
            Dealer_Disc_to_Customer__c,Due_date_shift_charges__c,Mfr_Exp_Reimburse_Amt__c,Mfr_Exp_Reimburse_Type__c,
            Provisional_Channel_Cost__c,Dealer_incentive_amount_main_dealer__c,Deliquency_Fund_type__c, Service_charges__c,
            Documentation_charges__c,Verification_charges__c,Loan_Amount__c, Holiday_period__c,Agreement_Amount__c, Rreferrer_Incentive__c, 
            CRM_IRR__c,Bank_IRR__c,Gross_IRR__c,Installment_Type__c,Trade_certificate__c,RTO_prefix__c,Scheme_Bank_offers__c, Calculated_Gross_LTV__c, Calculated_Net_LTV__c,
            Delinquency_Fund__c,EMI_Amount__c,DSM_Incentive1__c,Advance_EMI__c,DSM_Name1__c,DSM_Incentive2__c,DSM_Name2__c,Inputted_IRR__c, 
            Referrer_Name__c, Emp_Name__c, Emp_No__c, Net_IRR__c ,RC_limit_enabled_DSA__c,Required_CRM_IRR__c, Loan_Application__c
            From Final_Term__c Where Loan_Application__c =:loanAppId LIMIT 1];
        }
    }
    public static List<Applicant__c> getApplicantsDetails(String loanAppId,String dealId,Boolean isTractor){
        if(isTractor == true){
            return [Select Id, Name,Spouse_Name__c,Mother_s_name__c,Employee_Name__c,Applicant_Type__c, 
            Income_Source__c,Customer_Code__c,Relationship_with_borrower__c,Father_s_name__c,applicant_number__c,
            Consent_Received__c,CASA_Consent_Received__c,Height__c,Weight__c,CreatedDate
            From Applicant__c Where Opportunity__c =:loanAppId and In_Active_Applicant__c = false and (Applicant_Type__c =: System.Label.Borrower  OR  Applicant_Type__c =: System.Label.Coborrower OR Applicant_Type__c =: System.Label.Guarantor) ORDER BY CreatedDate ASC]; //SFTRAC-1964 added Guarantor check
        }else{
            return [Select Id, Name,Spouse_Name__c,Mother_s_name__c,Employee_Name__c,Applicant_Type__c, 
            Income_Source__c,Customer_Code__c,Relationship_with_borrower__c,Father_s_name__c,applicant_number__c,
            Consent_Received__c,CASA_Consent_Received__c,Height__c,Weight__c
            From Applicant__c Where Opportunity__c =:loanAppId and In_Active_Applicant__c = false];
        }
    }

    public class ObjPROList {
        public String Deal_No{get;set;}
        public String GPA_Type{get;set;}
        public Decimal GPA_Premium{get;set;}
        public String GPA_Business_done_By{get;set;}
        public Integer Credit_Days{get;set;}
        public Integer Credit_Amount{get;set;}
        public Integer Credit_ROI{get;set;}
        public String Install_Pattern_Type{get;set;}
        public String Ins_Prm_Paid_I{get;set;}
        public String Ins_Dep_Recovery_Type{get;set;}
        public Decimal Ins_Prm_I{get;set;}
        public Integer Ins_Prm_Dep_II{get;set;}
        public Integer Ins_Prm_Dep_III{get;set;}
        public Integer Ins_Prm_Dep_IV{get;set;}
        public Integer Ins_Prm_Dep_V{get;set;}
        public Decimal IHM_Dealer_Amt{get;set;}
        public String IHM_Dealer_Rec_No{get;set;}
        public String IHM_Dealer_Rec_Dt{get;set;}
        public Decimal IHM_IBL_Rct_Amt{get;set;}
        public String IHM_IBL_Rct_No{get;set;}
        public String IHM_IBL_Rct_Date{get;set;}
        public Decimal IHM_Recovery_Payment{get;set;}
        public String PDC_Bank{get;set;}
        public String PDC_Bank_Branch{get;set;}
        public String PDC_ACC_No{get;set;}
        public String PDC_Bank_PinCode{get;set;}
        public String Seller_Bank{get;set;}
        public String Seller_Bank_Branch{get;set;}
        public String Seller_Acc_No{get;set;}
        public String Seller_Bank_PinCode{get;set;}
        public String Seller_IFSC_Code{get;set;}//CISP-2553
        public String GPA_Customer_Name{get;set;}
        public String GPA_Customer_DOB{get;set;}
        public String Sort_Code{get;set;}
        public String Vehicle_Reg_No{get;set;}
        public String Name_Transferred{get;set;}
        public String Current_Owner{get;set;}
        public String Lien_Marked{get;set;}
        public String Lien_Marked_On{get;set;}
        public String Lien_Marked_for{get;set;}
        public String Ins_Policy_Type{get;set;}
        public Decimal IDV{get;set;}
        public Decimal Ins_Premium{get;set;}
        public String RSD{get;set;}
        public String RED{get;set;}
        public String Insurer{get;set;}
        public String Health_Product{get;set;}
        public Decimal Health_Premium{get;set;}
        public String Health_Renewal{get;set;}
        public Integer Health_Renewal_Years{get;set;}
        public String Health_Spouse_Name{get;set;}
        public String Health_Spouse_Gender{get;set;}
        public String Health_Spouse_DOB{get;set;}
        public String Health_Child1_Name{get;set;}
        public String Health_Child1_Gender{get;set;}
        public String Health_Child1_DOB{get;set;}
        public String Health_Child2_Name{get;set;}
        public String Health_Child2_Gender{get;set;}
        public String Health_Child2_DOB{get;set;}
        public Decimal Combo_Premium{get;set;}
        public String Combo_Renewal{get;set;}
        public Integer Combo_Renewal_Years{get;set;}
        public String Enquiry_Number{get;set;}
        public String CIC_No{get;set;}
        public String Letter_Ref{get;set;}
        public String Deal_Geo_State_Code{get;set;}
        public String Customer_Geo_State_Code{get;set;}
        public String Guarantor_Geo_State_Code{get;set;}
        public Integer Future_Period{get;set;}
        public String BSR_Code{get;set;}
        public String Evaluation_Method{get;set;}
        public String Enquiry_Number_Guar{get;set;}
        public String CIC_No_Guar{get;set;}
        public String Asset_Usage_By{get;set;}
        public String TopUp_Refin{get;set;}
        public String IBL_Account_No{get;set;}
        public String SA_Application_No{get;set;}
        public Decimal SA_Acc_Open_Charges{get;set;}
        public Decimal Amount_Hold{get;set;}
        public String GPA_Insured_Gender{get;set;}
        public String Nominee_Name{get;set;}
        public String Nominee_DOB{get;set;}
        public String Nominee_Relation{get;set;}
        public String Nominee_Address{get;set;}
        public String GPA_Insured{get;set;}
        public String SA_Nominee_Available{get;set;}
        public Integer DLP_Price{get;set;}
        public String GPA_Available_G{get;set;}
        public String GPA_Type_G{get;set;}
        public Decimal GPA_Premium_G{get;set;}
        public String Health_Fund_Type{get;set;}
        public String Health_Fund_Type_G{get;set;}
        public String Health_Product_G{get;set;}
        public Decimal Health_Premium_G{get;set;}
        public String Health_Spouse_Name_G{get;set;}
        public String Health_Spouse_Gender_G{get;set;}
        public String Health_Spouse_DOB_G{get;set;}
        public String Health_Child1_Name_G{get;set;}
        public String Health_Child1_Gender_G{get;set;}
        public String Health_Child1_DOB_G{get;set;}
        public String Health_Child2_Name_G{get;set;}
        public String Health_Child2_Gender_G{get;set;}
        public String Health_Child2_DOB_G{get;set;}
        public String Combo_Fund_Type{get;set;}
        public String Combo_Fund_Type_G{get;set;}
        public Decimal Combo_Premium_G{get;set;}
        public String Nominee_Name_G{get;set;}
        public String Nominee_DOB_G{get;set;}
        public String Nominee_Relation_G{get;set;}
        public String Nominee_Address_G{get;set;}
        public String SA_Security_Cheque_No{get;set;}
        public String SA_Acc_Holder_Type{get;set;}
        public String SA_Acc_Holder{get;set;}
        public String Motor_Fund_Type{get;set;}
        public String Valuer_Catq{get;set;}
        public String Valuer_Code{get;set;}
        public String Valuer_Name{get;set;}
        public String SLA_No{get;set;}
        public String Valuation_Report_No{get;set;}
        public String Valuation_Done_On{get;set;}
        public Decimal Valuation_Charges{get;set;}
        public String Valuation_Charges_Borne_By{get;set;}
        public String Combo_Product{get;set;}
        public String Combo_Product_G{get;set;}
        public Integer LI_Prm{get;set;}
        public Integer LI_Prm_G{get;set;}
        public Integer Valuation_Request_id{get;set;}
        public Integer Ins_Prm_Dep_VI{get;set;}
        public Integer Ins_Prm_Dep_VII{get;set;}
        public String Engine_No{get;set;}
        public String Chassis_no{get;set;}
        public String Vehicle_Register_Name{get;set;}
        public String IFSC_Code{get;set;}
        public String Phy_Mandate_Despatched_YN{get;set;}
        public String DO_Type{get;set;}
        public String DO_Authorised_By{get;set;}
        public Integer Chola_LP_Premium{get;set;}
        public String Chola_LP_Fund_Type{get;set;}
        public Integer AP_Premium{get;set;}
        public String AP_Fund_Type{get;set;}
        public String DO_Date{get;set;}
        public Integer VAS_Premium{get;set;}
        public String VAS_Fund_Type{get;set;}
        public Integer LHC_Amt{get;set;}
        public String LHC_Flag{get;set;}
        public String Deal_Date_Flag{get;set;}
        public Integer Telematics_Premium{get;set;}
        public String Telematics_Fund_Type{get;set;}
        public String Telematics_Device_At{get;set;}
        public String Account_Holder_Name{get;set;}
        public String Combo_Insurer{get;set;}
        public String Combo_Insurer_G{get;set;}
        public Integer Long_Term_Policy_Yrs{get;set;}
        public Integer No_Of_CoBorrowers{get;set;}
        public Integer LI_LHC{get;set;}
        public String Usage{get;set;}
        public Integer OD_Premium{get;set;}
        public Integer TP_Premium{get;set;}
        public long UniqueTransactionID{get;set;}
        public String LI_Fund_Type{get;set;}
        public String LI_Fund_Type_G{get;set;}
        public Integer LI_LHC_G{get;set;}
        public Integer RD_Amount{get;set;}
        public String Dep_Type{get;set;}
        public String HP_Available{get;set;}
        public Integer HP_Premium{get;set;}
        public String HP_Available_G{get;set;}
        public Integer HP_Premium_G{get;set;}
        public String RD_Start_Date{get;set;}
        public Integer RD_Years{get;set;}
        public Integer Subh_Raksha_Prm{get;set;}
        public Integer Subh_Raksha_Prm_G{get;set;}
        public String Tractor_Deal_No{get;set;}
        public String Covid_Cover_YN{get;set;}
        public Integer Covid_Cover_Amt{get;set;}
        public String Trade_Certificate_YN{get;set;}
        public Decimal Trade_Certificate_Fee{get;set;}
        public String RTO_Prefix{get;set;}
        public String Delivered_YN{get;set;}
        public Double MCLR{get;set;}
        public String Borr_Mobile_Aadhar{get;set;}
        public String CoBorr_Mobile_Aadhar{get;set;}
        public String Addl_CobBorr_Mobile_Aadhar{get;set;}
        public String Enable_Eagreement{get;set;}
        public String RTA_Taxes_Upto{get;set;}
        public String Fund_End_Use{get;set;}
        public String SOC_Version_No{get;set;}
        public String Arogya_Product{get;set;}
        public Integer Arogya_SI{get;set;}
        public Integer Arogya_Premium{get;set;}
        public String Arogya_Fund_Type{get;set;}
        public Integer Disc_Connect_Premium{get;set;}
        public String Disc_Connect_Fund_Type{get;set;}
        public Integer TATA_EMI_Amount{get;set;}
        public Integer TATA_EMI_Premium{get;set;}
        public String TATA_EMI_Fund_Type{get;set;}
        public String Arogya_Product_G{get;set;}
        public Integer Arogya_SI_G{get;set;}
        public Integer Arogya_Premium_G{get;set;}
        public String Arogya_Fund_Type_G{get;set;}
        public Integer Disc_Connect_Premium_G{get;set;}
        public String Disc_Connect_Fund_Type_G{get;set;}
        public String TATA_EMI_Amount_G{get;set;}
        public Integer Flexi_Prm{get;set;}
        public String Flexi_Plan{get;set;}
        public String Flexi_Fund_Type{get;set;}
        public Integer Flexi_Prm_G{get;set;}
        public String Flexi_Plan_G{get;set;}
        public String Flexi_Fund_Type_G{get;set;}
    }
    
    public class ObjPRInsList {
        public String Deal_No{get;set;}
        public String Spouse_Name{get;set;}
        public String Spouse_Gender{get;set;}
        public String Spouse_DOB{get;set;}
        public String Child1_Name{get;set;}
        public String Child1_Gender{get;set;}
        public String Child1_DOB{get;set;}
        public String Child2_Name{get;set;}
        public String Child2_Gender{get;set;}
        public String Child2_DOB{get;set;}
        public String Child3_Name{get;set;}
        public String Child3_Gender{get;set;}
        public String Child3_DOB{get;set;}
        public String Father_Name{get;set;}
        public String Father_Gender{get;set;}
        public String Father_DOB{get;set;}
        public String Mother_Name{get;set;}
        public String Mother_Gender{get;set;}
        public String Mother_DOB{get;set;}
        public String Spouse_Name_G{get;set;}
        public String Spouse_Gender_G{get;set;}
        public String Spouse_DOB_G{get;set;}
        public String Child1_Name_G{get;set;}
        public String Child1_Gender_G{get;set;}
        public String Child1_DOB_G{get;set;}
        public String Child2_Name_G{get;set;}
        public String Child2_Gender_G{get;set;}
        public String Child2_DOB_G{get;set;}
        public String Child3_Name_G{get;set;}
        public String Child3_Gender_G{get;set;}
        public String Child3_DOB_G{get;set;}
        public String Father_Name_G{get;set;}
        public String Father_Gender_G{get;set;}
        public String Father_DOB_G{get;set;}
        public String Mother_Name_G{get;set;}
        public String Mother_Gender_G{get;set;}
        public String Mother_DOB_G{get;set;}
        public Integer Maker_Id{get;set;}
        public String Maker_Date{get;set;}
        public String Ins_App_No{get;set;}
        public Integer Weight{get;set;}
        public Integer Height{get;set;}
        public Integer Weight_G{get;set;}
        public Integer Height_G{get;set;}
        public Integer Spouse_weight{get;set;}
        public Integer Spouse_Height{get;set;}
        public Integer Spouse_weight_G{get;set;}
        public Integer Spouse_Height_G{get;set;}
        public Integer Child1_weight{get;set;}
        public Integer Child1_Height{get;set;}
        public Integer Child1_weight_G{get;set;}
        public Integer Child1_Height_G{get;set;}
        public Integer Child2_weight{get;set;}
        public Integer Child2_Height{get;set;}
        public Integer Child2_weight_G{get;set;}
        public Integer Child2_Height_G{get;set;}
        public Integer Child3_weight{get;set;}
        public Integer Child3_Height{get;set;}
        public Integer Child3_weight_G{get;set;}
        public Integer Child3_Height_G{get;set;}
    }
    public class ObjPRList {
        public String Deal_No{get;set;}
        public String Product{get;set;}
        public String Application_No{get;set;}
        public String Payment_Source{get;set;}
        public String Customer_Code{get;set;}
        public String Guarantor_Available{get;set;}
        public String Guarantor_Name{get;set;}
        public String Product_Variant{get;set;}
        public String Fully_Built{get;set;}
        public String RTO_Registered{get;set;}
        public String Vehicle_Category{get;set;}
        public String Vehicle_Sub_Category{get;set;}
        public String Old_Deal_No{get;set;}
        public String Sold_By_Dealer{get;set;}
        public String Main_Dealer{get;set;}
        public String Business_Sourced_By{get;set;}
        public String Business_Done_By{get;set;}
        public String FI_Done_By{get;set;}
        public String Approved_By{get;set;}
        public String Approval_No{get;set;}
        public String Invoice_Category{get;set;}
        public Decimal Invoice_Amt{get;set;}
        public Decimal Invoice_Amt_Chasis{get;set;}
        public Integer Invoice_Amt_Body{get;set;}
        public Integer Market_Value{get;set;}
        public Decimal Sales_Value{get;set;}
        public Decimal Balance_Transfer_Amt{get;set;}
        public Integer Mfg_Month{get;set;}
        public Integer Mfg_Year{get;set;}
        public Decimal Fin_Amt{get;set;}
        public Decimal Fin_Amt_Chasis{get;set;}
        public Integer Fin_Amt_Body{get;set;}
        public String GPA_Available{get;set;}
        public String Hospital_Cash_Available{get;set;}
        public Double Interest_Rate{get;set;}
        public String Interest_Comp_Method{get;set;}
        public String Periodicity{get;set;}
        public Integer Deal_Period{get;set;}
        public Integer Instalment_Nos{get;set;}
        public Integer Moratorium{get;set;}
        public Integer Advance_EMI_Nos{get;set;}
        public String EMI_13_Free{get;set;}
        public String Rebate_Available{get;set;}
        public Integer Rebate_Per{get;set;}
        public String Credit_Available{get;set;}
        public String Sec_Dep_Available{get;set;}
        public Decimal IHM_Computed{get;set;}
        public Decimal Finance_Charges{get;set;}
        public Decimal Agreement_Value{get;set;}
        public Decimal Total_Disburse_Amt{get;set;}
        public Double CRM_IRR{get;set;}
        public Double Bank_IRR{get;set;}
        public Double Gross_IRR{get;set;}
        public Double Imputed_IRR{get;set;}
        public Double Net_LTV{get;set;}
        public Double Gross_LTV{get;set;}
        public String Payment_To{get;set;}
        public Integer Maker_ID{get;set;}
        public String Maker_Date{get;set;}
        public String Gurantor_code{get;set;}
        public Integer Net_Disburse_Amt{get;set;}
        public String NOC_Status{get;set;}
        public String Waiver_Scheme_500{get;set;}
        public String Health_Available{get;set;}
        public String Deal_Date{get;set;}
        public String First_EMI_Date{get;set;}
        public String Second_EMI_Date{get;set;}
        public Decimal Basic_Price{get;set;}
        public Decimal RTO_Road_Tax{get;set;}
        public Decimal IYear_Ins_Prm{get;set;}
        public Decimal Other_Charges{get;set;}
        public String Guarantor_Relation_Type{get;set;}
        public String Scheme_Info{get;set;}
        public Decimal VAT{get;set;}
        public Integer Permit_Amt{get;set;}
        public Double ROI_perc{get;set;}
        public String Approval_Status{get;set;}
        public String Colln_Exec{get;set;}
        public String Addl_CB_Available{get;set;}
        public String Addl_CB_Code{get;set;}
        public String Addl_CB_Name{get;set;}
        public String Invoice_Type{get;set;}
        public String Invoice_No{get;set;}
        public String Invoice_Date{get;set;}
        public Decimal CGST{get;set;}
        public Decimal SGST{get;set;}
        public Decimal UTGST{get;set;}
        public Decimal IGST{get;set;}
        public Decimal CESS{get;set;}
        public String Sale_Date{get;set;}
        public String HSN_No{get;set;}
        public String Purchase_Doc_Catq{get;set;}
        public Decimal Org_Sale_Value{get;set;}
        public String Date1{get;set;}
        public String ROC_ID{get;set;}
        public String Version_no{get;set;}
        public String Repayment_LeadNo{get;set;}
        public String Repayment_By{get;set;}
        public String Repayment_Mode{get;set;}
        public String Table_Code{get;set;}//CISP-16547
        public String Interest_Version_No{get;set;}//CISP-16547
        public Decimal Dr_Penal_Interest {get;set;}//CISP-16547
        public Decimal MCLR{get;set;}//CISP-16547
        public String AEPS{get;set;}
    }
    public class ObjPUIMList {
        public String Customer_Code{get;set;}
        public String Product{get;set;}
        public String Pay_Source{get;set;}
        public Integer Inv_Amt{get;set;}
        public Integer Fin_Amt{get;set;}
        public Integer IHM{get;set;}
        public Integer Term{get;set;}
        public Integer Emi_Nos{get;set;}
        public Integer Adv_Emi_Nos{get;set;}
        public Double ROI{get;set;}
        public Integer Incen_Amt{get;set;}
        public String Incen_Type{get;set;}
        public Integer Dsa_Amt{get;set;}
        public String Dsa_Name{get;set;}
        public Integer Serv_Chrgs{get;set;}
        public Integer Channel_Cost{get;set;}
        public Integer Insurance{get;set;}
        public Integer First_Pdc_Amt{get;set;}
        public Double Gross_Irr{get;set;}
        public Double Net_Irr{get;set;}
        public Integer Disburse_Amt{get;set;}
        public String Beneficiary{get;set;}
        public String Enter_Dt{get;set;}
        public Integer IHM_BY_IBL{get;set;}
        public String Gpayn{get;set;}
        public Integer Gpprm{get;set;}
        public String Gparef{get;set;}
        public Double Ltv{get;set;}
        public Integer dlrincent{get;set;}
        public String dlrinctype{get;set;}
        public Integer delinqamt{get;set;}
        public String delinqtype{get;set;}
        public String iblrctref{get;set;}
        public String dlrrctref{get;set;}
        public String Ma_code{get;set;}
        public Integer Doc_Chrgs{get;set;}
        public Double Approved_IRR{get;set;}
        public Double Gross_LTV{get;set;}
        public String InvPrice_Category{get;set;}
        public String GPA_Sourced_By{get;set;}
        public Integer Market_Value{get;set;}
        public String Main_Dealer{get;set;}
        public String Sub_dealer{get;set;}
        public String Deal_No{get;set;}
        public Integer Mfg_Month{get;set;}
        public Integer Mfg_Year{get;set;}
        public Integer Maker_ID{get;set;}
        public Integer Mfg_Incentive{get;set;}
        public Integer Finance_Charges{get;set;}
        public Integer Gift_Amt{get;set;}
        public String Gift_Type{get;set;}
        public String Collection_Mode{get;set;}
        public String ECS_Verification_By{get;set;}
        public Decimal ECS_Verification_Charges{get;set;}
        public String Periodicity{get;set;}
        public Integer Moratorium{get;set;}
        public String Vehicle_Category{get;set;}
        public String Vehicle_Sub_Category{get;set;}
        public Integer Hospital_Cash_Premium{get;set;}
        public String FI_Done_By{get;set;}
        public Decimal Health_Premium{get;set;}
        public String Health_Renewal{get;set;}
        public Integer Health_Renewal_Years{get;set;}
        public String Health_Spouse_Name{get;set;}
        public String Health_Spouse_Gender{get;set;}
        public String Health_Spouse_DOB{get;set;}
        public String Health_Child1_Name{get;set;}
        public String Health_Child1_Gender{get;set;}
        public String Health_Child1_DOB{get;set;}
        public String Health_Child2_Name{get;set;}
        public String Health_Child2_Gender{get;set;}
        public String Health_Child2_DOB{get;set;}
        public String Health_Product{get;set;}
        public String GPA_Type{get;set;}
        public Integer Sub_Dlr_Incentive_Amt{get;set;}
        public String Sub_Dlr_Incentive_Type{get;set;}
        public Decimal Stamping_Charges{get;set;}
        public String POSB_Charges_By{get;set;}
        public Integer POSB_Charges{get;set;}
        public String Long_Term_Policy_Flag{get;set;}
    }
        
    public class ObjPayInOutList {
        public String Deal_No{get;set;}
        public Decimal Service_Charges{get;set;}
        public Decimal Doc_Charges{get;set;}
        public Decimal Part_PDC_Charges{get;set;}
        public Decimal Due_Date_Shift_Charges{get;set;}
        public Integer Delinquency_Fund{get;set;}
        public String Delinquency_Fund_Type{get;set;}
        public Integer Dealer_Subv_Amt{get;set;}
        public String Dealer_Subv_Type{get;set;}
        public Decimal Mfr_Subv_Amt{get;set;}
        public String Mfr_Subv_Type{get;set;}
        public Decimal Provision_Cost{get;set;}
        public Decimal Dlr_Incentive_Amt{get;set;}
        public String Dlr_Incentive_Type{get;set;}
        public Decimal Dlr_Discount_Customer{get;set;}
        public Decimal Gift_Amt{get;set;}
        public String Gift_Type{get;set;}
        public Integer Mfr_Incentive{get;set;}
        public String Source_Channel_Type{get;set;}
        public Integer DSM_Incentive1{get;set;}
        public String DSM_Name1{get;set;}
        public Integer DSM_Incentive2{get;set;}
        public String DSM_Name2{get;set;}
        public Integer DSA_Incentive{get;set;}
        public String DSA_Name{get;set;}
        public Integer DMA_Incentive{get;set;}
        public String DMA_Name{get;set;}
        public String Branch{get;set;}
        public String Employee_No{get;set;}
        public String Employee_Name{get;set;}
        public String Reference_No{get;set;}
        public String Collection_Mode{get;set;}
        public String ECS_Verification_By{get;set;}
        public Decimal ECS_Verification_Charges{get;set;}
        public Decimal Sub_Dlr_Incentive_Amt{get;set;}
        public String Sub_Dlr_Incentive_Type{get;set;}
        public Decimal Stamping_Charges{get;set;}
        public String POSB_Charges_By{get;set;}
        public Integer POSB_Charges{get;set;}
        public Integer Pseudo_DSM_Incentive1{get;set;}
        public String Pseudo_DSM_Name1{get;set;}
        public Integer Pseudo_DSM_Incentive2{get;set;}
        public String Pseudo_DSM_Name2{get;set;}
        public String Sourcing_Digital_Channel{get;set;}
        public String Sourcing_Digital_Channel_ID{get;set;}
    }    
    public class ObjPRPList {
        public String Deal_No{get;set;}
        public String Permit_Nature{get;set;}
        public String Permit_No{get;set;}
        public String Permit_Date{get;set;}
        public String Permit_Expired_On{get;set;}
        public String Permit_Regn_No{get;set;}
        public String Permit_Holder_Name{get;set;}
        public String RTO{get;set;}
        public Integer Seats_Tonnage{get;set;}
        public String Maker_Date{get;set;}
        public String Permit_Type{get;set;}
        public String Stamping_Agr_No{get;set;}
        public String Stamping_Done_At_1{get;set;}
        public Decimal Stamping_Amt_1{get;set;}
        public String Stamping_Type_1{get;set;}
        public String Stamping_Done_At_2{get;set;}
        public Decimal Stamping_Amt_2{get;set;}
        public String Stamping_Type_2{get;set;}
        public String Stamping_Done_At_3{get;set;}
        public Decimal Stamping_Amt_3{get;set;}
        public String Stamping_Type_3{get;set;}
    }
    public class ObjSANDList {
        public String Deal_No {get;set;}
        public String Nominee_Name {get;set;}
        public String Nominee_Relationship {get;set;}
        public String Nominee_Addr1{get;set;}
        public String Nominee_Addr2{get;set;}
        public String Nominee_Addr3{get;set;}
        public String Nominee_City_Code{get;set;}
        public String Nominee_City{get;set;}
        public String Nominee_State{get;set;}
        public String Nominee_PinCode{get;set;}
        public String Nominee_DOB{get;set;}
        public String Guardian_Name{get;set;}
        public String Guardian_Code{get;set;}
        public String Guardian_Addr1{get;set;}
        public String Guardian_Addr2{get;set;}
        public String Guardian_Addr3{get;set;}
        public String Guardian_City_Code{get;set;}
        public String Guardian_City{get;set;}
        public String Guardian_State{get;set;}
        public String Guardian_PinCode{get;set;}
        public String SA_Account_BarCodeNo{get;set;}
        public String Nominee_Available{get;set;}        
    }
        
    public class ObjRFDList {
        public String Reference_No{get;set;}
        public String Reference_Description{get;set;}
        public String Customer_Code{get;set;}
        public String Reference_Type{get;set;}
        public String Product{get;set;}
        public String Bl_Code{get;set;}
        public String Active_Flag{get;set;}
        public Integer Maker_Id{get;set;}
        public String Maker_Date{get;set;}
    }

    public class ObjConsentInfo {
        public String Application_No{get;set;}
        public String Customer_Code{get;set;}
        public String Customer_Name{get;set;} //SFTRAC-1964
        public String Whatsapp_Consent_Flag{get;set;}
        public String CASA_Consent_Flag{get;set;}
    }    
    
    public class ObjPRBDTList {
        public String Deal_No{get;set;}
        public String PV_Number{get;set;}
        public String Beneficiary_Code{get;set;}
        public Integer Amount_Paid{get;set;}
    }

    public class ObjDRLList {
        public String Deal_No{get;set;}
        public String Pay_Req_Date{get;set;}
        public String Ben_Code{get;set;}
        public String IBL_Lien_Marked{get;set;}
    }

    public class ObjRequestLead{
        public String Application_No;
        public String Deal_No;
        public String Lead_No;
        public String Subsidy_Amt;//OLA-124
    }

    public class ObjGPRList {
        public String Document_Code{get;set;}
        public String GST_Effect_Date{get;set;}
        public String Deal_No{get;set;}
        public String Nature{get;set;}
        public String GL_Entry_Code{get;set;}
        public Decimal Document_Value{get;set;}
        public Decimal GST_Value{get;set;}
        public Decimal Total_Value{get;set;}
        public Integer Maker_Id{get;set;}
        public String Maker_Date{get;set;}
        public Integer CESS_Value{get;set;}
    }

    public static string getInsPrePaid(List<LoanDisbursementDetails__c> loanDisbursDetailList,Boolean isTractor, String hasMotorInsu, String hasMotorInsuForCob){
        String Ins_Prm_Paid_I = '';
        if(loanDisbursDetailList.size() > 0 && loanDisbursDetailList[0].X1st_Yr_Insurance_premium_paid_by__c != null){
            if(loanDisbursDetailList[0].X1st_Yr_Insurance_premium_paid_by__c == 'By Bank (Funding)'){
                Ins_Prm_Paid_I = 'B';
            }
            else if(loanDisbursDetailList[0].X1st_Yr_Insurance_premium_paid_by__c == 'BY CUSTOMER (UPFRONT)'){
                Ins_Prm_Paid_I = 'C';
            }
            else if(loanDisbursDetailList[0].X1st_Yr_Insurance_premium_paid_by__c == 'Dealer'){
                Ins_Prm_Paid_I = 'D';
            }
            else if(loanDisbursDetailList[0].X1st_Yr_Insurance_premium_paid_by__c == 'Free Insurance'){
                Ins_Prm_Paid_I = 'F';
            }
            else if(loanDisbursDetailList[0].X1st_Yr_Insurance_premium_paid_by__c == 'Policy Taken By Customer'){
                Ins_Prm_Paid_I = 'U';
            }
            else {
                Ins_Prm_Paid_I = '';
            }
        }
        if(isTractor && (String.isEmpty(Ins_Prm_Paid_I) || String.isBlank(Ins_Prm_Paid_I)) && (hasMotorInsu == 'Y' || hasMotorInsuForCob == 'Y')){
            Ins_Prm_Paid_I = 'B';
        }
        return Ins_Prm_Paid_I;
    }

    public class ObjPRIList {
        public String Deal_No{get;set;}
        public Integer From_No{get;set;}
        public Integer To_No{get;set;}
        public Integer Instal_Nos{get;set;}
        public Decimal Instal_Amt{get;set;}
        public Decimal Insur_Amt{get;set;}
        public Decimal EMI{get;set;}
        public Decimal Health_Amt{get;set;}
        public Integer Hospital_Cash_Amt{get;set;}
        public Integer POSB_Charges{get;set;}
        public Decimal Combo_Amt{get;set;}
        public date Instal_Date{get;set;}
        public Integer RD_Amount{get;set;}
        public Decimal Interest{get;set;}
        public Decimal Principal{get;set;}
        public Decimal Balance{get;set;}
    } 

    public static List<ObjConsentInfo> getObjConsentInfoList(List<Applicant__c> applicantDetailsList, Opportunity opptyDetails, Boolean isTractor){
        // Applicant__c borrowerDetails = new Applicant__c();
        // Applicant__c coBorrowerDetails = new Applicant__c();
        List<ObjConsentInfo> ObjConsentInfoList = new List<ObjConsentInfo>();
        ObjConsentInfo objConsetRec = new ObjConsentInfo();
        for(Applicant__c applicant : applicantDetailsList){
            objConsetRec = new ObjConsentInfo();
            if(applicant.Applicant_Type__c == Label.Borrower){
                //borrowerDetails = applicant;
                objConsetRec.Application_No = opptyDetails.Application_number__c;
                objConsetRec.Customer_Code = applicant.Customer_Code__c;
                if(isTractor == true){
                    objConsetRec.Customer_Name = applicant.Name;    //SFTRAC-1964
                }
                objConsetRec.Whatsapp_Consent_Flag = applicant.Consent_Received__c == true ? 'Y' : 'N';
                objConsetRec.CASA_Consent_Flag = applicant.CASA_Consent_Received__c == true ? 'Y' : 'N';
                
            } else if(applicant.Applicant_Type__c == Label.CoBorrower){
                //coBorrowerDetails = applicant;
                objConsetRec.Application_No = opptyDetails.Application_number__c;
                objConsetRec.Customer_Code = applicant.Customer_Code__c;
                if(isTractor == true){
                    objConsetRec.Customer_Name = applicant.Name;    //SFTRAC-1964
                }
                objConsetRec.Whatsapp_Consent_Flag = applicant.Consent_Received__c == true ? 'Y' : 'N';
                objConsetRec.CASA_Consent_Flag = applicant.CASA_Consent_Received__c == true ? 'Y' : 'N';
            } else if(applicant.Applicant_Type__c == Label.Guarantor && isTractor == true){  //SFTRAC-1964 Start
                objConsetRec.Application_No = opptyDetails.Application_number__c;
                objConsetRec.Customer_Code = applicant.Customer_Code__c;
                objConsetRec.Customer_Name = applicant.Name;    
                objConsetRec.Whatsapp_Consent_Flag = applicant.Consent_Received__c == true ? 'Y' : 'N';
                objConsetRec.CASA_Consent_Flag = applicant.CASA_Consent_Received__c == true ? 'Y' : 'N';
            }//SFTRAC-1964 end
            ObjConsentInfoList.add(objConsetRec);
        }
        ObjConsentInfoList = ObjConsentInfoList;
        return ObjConsentInfoList;
    }
    
    public static String getSourcingDigital(Opportunity opp){
        String sourcingDigital = '';
        String leadSource = opp.LeadSource;
        String sanitizedString = '';
        if(opp.LeadSource!=null){
            sanitizedString = leadSource.replace('-', '_');
        }else{
            sanitizedString = leadSource;
        }
        if(opp.LeadSource!=null){
        switch on sanitizedString{
            when 'OLA'  {
                sourcingDigital= 'OLA';
            }
            when 'DSA'  {
                sourcingDigital= 'DSA';
            }
            when 'Hero'  {
                sourcingDigital= 'HERO';
            }
            when 'D2C'  {
                sourcingDigital= 'D2C';
            }
            when 'TAFE'  {
                sourcingDigital= 'TAFE';
            }
            when 'Digital_MSIL_Custom'{
                sourcingDigital= 'MSIL';
            }
            when 'Digital_Mahindra_Custom'{
                sourcingDigital= 'MAHIN';
            }
            when 'Digital_Mahindra_PreA'{
                sourcingDigital= 'MAHIN';
            }
            when else {
                sourcingDigital= '';
            } 
        }
        }else{
            sourcingDigital = '';
        }
        return sourcingDigital;
    }

    public static List<PactLmsRequestHelper.ObjPRIList> getInstallments(List<Structered_EMI__c> structuredEmiList, List<Final_Term__c> finalTermList, Boolean isTractor, String dealNumber, Decimal fundedPremium, Decimal allInstSum, Integer noOfInstalments){
        //create based on Installment Type
        List<PactLmsRequestHelper.ObjPRIList> ObjPRIList = new List<PactLmsRequestHelper.ObjPRIList>();
        if(finalTermList.size() > 0 && finalTermList[0].Installment_Type__c == 'Structured'){
            Double totalLoanAmt = 0;
            if(isTractor){
                for(Structered_EMI__c structuredEmi : structuredEmiList){
                    totalLoanAmt= totalLoanAmt + (structuredEmi.EMI_Amount__c != null && structuredEmi.Number_of_Installments__c != null ? structuredEmi.EMI_Amount__c * structuredEmi.Number_of_Installments__c : 0);
                }
            }
            Integer counter = 0;
            for(Structered_EMI__c structuredEmi : structuredEmiList){
                PactLmsRequestHelper.ObjPRIList ObpriList = new PactLmsRequestHelper.ObjPRIList();
                ObpriList.Deal_No= dealNumber;
                ObpriList.From_No= structuredEmi.From_Month__c != null ? Integer.valueOf(structuredEmi.From_Month__c) : 0;
                ObpriList.To_No= structuredEmi.To_Month__c != null ? Integer.valueOf(structuredEmi.To_Month__c) : 0;
                ObpriList.Instal_Nos= structuredEmi.Number_of_Installments__c != null ? Integer.valueOf(structuredEmi.Number_of_Installments__c) : 0;
                counter++;
                if(isTractor && counter == structuredEmiList.size()){
                    Decimal diffAmt = (totalLoanAmt - allInstSum);
                    ObpriList.Instal_Amt = (structuredEmi.EMI_Amount__c != null ? structuredEmi.EMI_Amount__c : 0) - diffAmt;
                    ObpriList.EMI= (structuredEmi.EMI_Amount__c != null ? structuredEmi.EMI_Amount__c : 0) - diffAmt;
                }else{
                    ObpriList.Instal_Amt= structuredEmi.EMI_Amount__c != null ? structuredEmi.EMI_Amount__c : 0;
                    ObpriList.EMI= structuredEmi.EMI_Amount__c != null ? structuredEmi.EMI_Amount__c : 0;
                }
                ObpriList.Insur_Amt= 0;
                ObpriList.Health_Amt= 0;
                ObpriList.Hospital_Cash_Amt= 0;
                ObpriList.POSB_Charges= 0;
                ObpriList.Combo_Amt= 0;
                ObpriList.Instal_Date= structuredEmi.EMI_Due_Date__c !=null ? structuredEmi.EMI_Due_Date__c : Date.today();
                ObpriList.RD_Amount= 0;
                ObpriList.Interest= structuredEmi.Interest_Component__c != null ? structuredEmi.Interest_Component__c : 0;
                ObpriList.Principal= structuredEmi.Principal_Component__c != null ? structuredEmi.Principal_Component__c : 0;
                ObpriList.Balance= structuredEmi.Closing_Principal__c != null ? structuredEmi.Closing_Principal__c : 0;
                ObjPRIList.add(ObpriList);
            }
        } else {
            if(finalTermList.size() > 0){
                // if(isTractor){
                //     Decimal principal = finalTermList[0].Loan_Amount__c != null ? Decimal.valueOf(finalTermList[0].Loan_Amount__c) + fundedPremium : 0;
                //     String irr = finalTermList[0].Required_CRM_IRR__c;
                //     Date loanDate = finalTermList[0].Loan_Deal_Date__c;
                //     Integer increment = finalTermList[0].Tenure__c != null ? Integer.valueof(finalTermList[0].Tenure__c) : 0;
                //     Integer day;
                //     String frequency = '1';
                //     if(finalTermList[0].Installment_Frequency__c ==  'Monthly'){
                //         frequency = '1';
                //     }else if(finalTermList[0].Installment_Frequency__c ==  'bi-monthly'){
                //         frequency = '2';
                //     }else if(finalTermList[0].Installment_Frequency__c ==  'Quarterly'){
                //         frequency = '3';
                //     }else if(finalTermList[0].Installment_Frequency__c ==  'Half yearly'){
                //         frequency = '6';
                //     }
                //     Date repaymentDate = finalTermList[0].First_EMI_Date__c;
                //     Date secondEMI = finalTermList[0].Second_EMI_Date__c;
                //     Boolean advanceEMI = finalTermList[0].Advance_EMI__c;
                //     List<IND_OfferScreenController.RepaymentWrapper> repaymentWrapperList = IND_OfferScreenController.emiRepaymentSchedule(principal, irr, loanDate, increment, day, frequency, repaymentDate, secondEMI, advanceEMI);
                //     Decimal sumofAmor = 0;
                //     for (Integer i = 0; i < repaymentWrapperList.size(); i++) {
                //         IND_OfferScreenController.RepaymentWrapper repaymentWrapperObj = repaymentWrapperList[i];
                //         PactLmsRequestHelper.ObjPRIList ObpriList = new PactLmsRequestHelper.ObjPRIList();
                //         ObpriList.Deal_No= dealNumber;
                //         ObpriList.From_No= repaymentWrapperObj.instalmentNo;
                //         ObpriList.To_No= repaymentWrapperObj.instalmentNo;
                //         ObpriList.Instal_Nos= repaymentWrapperObj.instalmentNo;
                //         ObpriList.Insur_Amt= 0;
                //         Decimal instalmentAmount = repaymentWrapperObj.instalmentAmount != null ? Integer.valueof(repaymentWrapperObj.instalmentAmount) : 0;
                //         sumofAmor += instalmentAmount;
                //         if(repaymentWrapperList.size() == i+1) {
                //             Decimal diffAmt = (sumofAmor - allInstSum);
                //             ObpriList.EMI = instalmentAmount - diffAmt;
                //             ObpriList.Instal_Amt = instalmentAmount - diffAmt;
                //         }else{
                //             ObpriList.EMI= repaymentWrapperObj.instalmentAmount != null ? Integer.valueof(repaymentWrapperObj.instalmentAmount) : 0;
                //             ObpriList.Instal_Amt= repaymentWrapperObj.instalmentAmount != null ? Integer.valueof(repaymentWrapperObj.instalmentAmount) : 0;
                //         }
                //         ObpriList.Health_Amt= 0;
                //         ObpriList.Hospital_Cash_Amt= 0;
                //         ObpriList.POSB_Charges= 0;
                //         ObpriList.Combo_Amt= 0;
                //         ObpriList.Instal_Date= '';
                //         ObpriList.RD_Amount= 0;
                //         ObjPRIList.add(ObpriList);
                //     }
                // }
                // else{
                //     for(Integer installNo = 1; installNo <= noOfInstalments; installNo++){
                //         PactLmsRequestHelper.ObjPRIList ObpriList = new PactLmsRequestHelper.ObjPRIList();
                //         ObpriList.Deal_No= dealNumber;
                //         ObpriList.From_No= installNo;
                //         ObpriList.To_No= installNo;
                //         ObpriList.Instal_Nos= installNo;
                //         ObpriList.Instal_Amt= finalTermList[0].EMI_Amount__c != null ? finalTermList[0].EMI_Amount__c : 0;
                //         ObpriList.Insur_Amt= 0;
                //         ObpriList.EMI= finalTermList[0].EMI_Amount__c != null ? finalTermList[0].EMI_Amount__c : 0;
                //         ObpriList.Health_Amt= 0;
                //         ObpriList.Hospital_Cash_Amt= 0;
                //         ObpriList.POSB_Charges= 0;
                //         ObpriList.Combo_Amt= 0;
                //         ObpriList.Instal_Date= '';
                //         ObpriList.RD_Amount= 0;
                //         ObjPRIList.add(ObpriList);
                //     }
                // }
                List<EMI_Schedule__c> emiScheduleList = InstallmentScheduleController.getRecentEMIdetails(finalTermList[0].Loan_Application__c);
                if(emiScheduleList.size() > 0){
                Integer installIdxNo = 0;
                    for(Integer installNo = 1; installNo <= emiScheduleList.size(); installNo++){
                        PactLmsRequestHelper.ObjPRIList ObpriList = new PactLmsRequestHelper.ObjPRIList();
                        ObpriList.Deal_No= dealNumber;
                        ObpriList.From_No= installNo;
                        ObpriList.To_No= installNo;
                        ObpriList.Instal_Nos= installNo;
                        ObpriList.Instal_Amt= emiScheduleList[installIdxNo].EMI_Amount__c != null ? emiScheduleList[installIdxNo].EMI_Amount__c : 0;
                        ObpriList.Insur_Amt= 0;
                        ObpriList.EMI= emiScheduleList[installIdxNo].EMI_Amount__c != null ? emiScheduleList[installIdxNo].EMI_Amount__c : 0;
                        ObpriList.Health_Amt= 0;
                        ObpriList.Hospital_Cash_Amt= 0;
                        ObpriList.POSB_Charges= 0;
                        ObpriList.Combo_Amt= 0;
                        ObpriList.Instal_Date= emiScheduleList[installIdxNo].EMI_Due_Date__c !=null ? emiScheduleList[installIdxNo].EMI_Due_Date__c : Date.today();
                        ObpriList.RD_Amount= 0;
                        ObpriList.Interest = emiScheduleList[installIdxNo].Interest_Component__c != null ? emiScheduleList[installIdxNo].Interest_Component__c : 0;
                        ObpriList.Principal = emiScheduleList[installIdxNo].Principal_Component__c != null ? emiScheduleList[installIdxNo].Principal_Component__c : 0;
                        ObpriList.Balance = emiScheduleList[installIdxNo].Closing_Principal__c != null ? emiScheduleList[installIdxNo].Closing_Principal__c : 0;
                        ObjPRIList.add(ObpriList);
                        installIdxNo ++;
                    }
                }else{
                    for(Integer installNo = 1; installNo <= noOfInstalments; installNo++){
                        PactLmsRequestHelper.ObjPRIList ObpriList = new PactLmsRequestHelper.ObjPRIList();
                        ObpriList.Deal_No= dealNumber;
                        ObpriList.From_No= installNo;
                        ObpriList.To_No= installNo;
                        ObpriList.Instal_Nos= installNo;
                        ObpriList.Instal_Amt= finalTermList[0].EMI_Amount__c != null ? finalTermList[0].EMI_Amount__c : 0;
                        ObpriList.Insur_Amt= 0;
                        ObpriList.EMI= finalTermList[0].EMI_Amount__c != null ? finalTermList[0].EMI_Amount__c : 0;
                        ObpriList.Health_Amt= 0;
                        ObpriList.Hospital_Cash_Amt= 0;
                        ObpriList.POSB_Charges= 0;
                        ObpriList.Combo_Amt= 0;
                        ObpriList.Instal_Date= Date.today();
                        ObpriList.RD_Amount= 0;
                        ObpriList.Interest = 0;
                        ObpriList.Principal = 0;
                        ObpriList.Balance = 0;
                        ObjPRIList.add(ObpriList);
            }
        }
    }
}
        return ObjPRIList;
    }

    public static List<PactLmsRequestHelper.objPayInOutList> getPayInPayOut(List<Final_Term__c> finalTermList, Boolean isTractor, Opportunity opptyDetails, String dealNumber){
        List<PactLmsRequestHelper.objPayInOutList> objPayInOutList = new List<PactLmsRequestHelper.objPayInOutList>();
        PactLmsRequestHelper.objPayInOutList ObpioList = new PactLmsRequestHelper.objPayInOutList();

            ObpioList.Deal_No= dealNumber;
            ObpioList.Service_Charges= finalTermList.size() > 0 && finalTermList[0].Service_charges__c != null ? Decimal.valueOf(finalTermList[0].Service_charges__c) : 0;
            ObpioList.Doc_Charges= finalTermList.size() > 0 && finalTermList[0].Documentation_charges__c != null ? Decimal.valueOf(finalTermList[0].Documentation_charges__c) : 0;
            ObpioList.Part_PDC_Charges= finalTermList.size() > 0 && finalTermList[0].Verification_charges__c != null ? Decimal.valueOf(finalTermList[0].Verification_charges__c) : 0;
            ObpioList.Due_Date_Shift_Charges= finalTermList.size() > 0 && finalTermList[0].Due_date_shift_charges__c != null ? Decimal.valueOf(finalTermList[0].Due_date_shift_charges__c) : 0;
            ObpioList.Delinquency_Fund= finalTermList.size() > 0 && finalTermList[0].Delinquency_Fund__c != null ? (Integer)Decimal.valueOf(finalTermList[0].Delinquency_Fund__c) : 0;//CISP-3169
            ObpioList.Delinquency_Fund_Type= finalTermList.size() > 0 && (finalTermList[0].Delinquency_Fund__c != null && Decimal.valueOf(finalTermList[0].Delinquency_Fund__c) != 0) ? 'S' : '' ;//CISP-3169
            ObpioList.Dealer_Subv_Amt= 0;
            ObpioList.Dealer_Subv_Type= '';
            ObpioList.Mfr_Subv_Amt=  finalTermList.size() > 0 && finalTermList[0].Mfr_Exp_Reimburse_Amt__c != null ? Decimal.valueOf(finalTermList[0].Mfr_Exp_Reimburse_Amt__c).round(System.RoundingMode.HALF_EVEN) : 0;
            ObpioList.Mfr_Subv_Type=  ObpioList.Mfr_Subv_Amt != null && ObpioList.Mfr_Subv_Amt > 0 ? 'S' : '' ;
            ObpioList.Provision_Cost= finalTermList.size() > 0 && finalTermList[0].Provisional_Channel_Cost__c != null ? Decimal.valueOf(finalTermList[0].Provisional_Channel_Cost__c) : 0;
            ObpioList.Dlr_Incentive_Amt=  finalTermList.size() > 0 && finalTermList[0].Dealer_incentive_amount_main_dealer__c != null ? Decimal.valueOf(finalTermList[0].Dealer_incentive_amount_main_dealer__c).round(System.RoundingMode.HALF_EVEN) : 0;
            ObpioList.Dlr_Incentive_Type= ObpioList.Dlr_Incentive_Amt > 0 ? 'S' : '';
            ObpioList.Dlr_Discount_Customer=  finalTermList.size() > 0 && finalTermList[0].Dealer_Disc_to_Customer__c != null ? Decimal.valueOf(finalTermList[0].Dealer_Disc_to_Customer__c).round(System.RoundingMode.HALF_EVEN) : 0;
            ObpioList.Gift_Amt= finalTermList.size() > 0 && finalTermList[0].Gift_through_dealer_amount__c != null ? Decimal.valueOf(finalTermList[0].Gift_through_dealer_amount__c).round(System.RoundingMode.HALF_EVEN) : 0;
            ObpioList.Gift_Type= ObpioList.Gift_Amt > 0 ? 'S' : '';
            ObpioList.Mfr_Incentive= finalTermList.size() > 0 && finalTermList[0].Mfr_incentive__c != null ? (Integer)Decimal.valueOf(Decimal.valueOf(finalTermList[0].Mfr_incentive__c).round(System.RoundingMode.HALF_EVEN)) : 0;//CISP-3169
            if(opptyDetails.LeadSource == 'OLA'){//OLA-170
                ObpioList.Source_Channel_Type = 'OLA'; 
            }else if(opptyDetails.LeadSource == 'D2C'){
                ObpioList.Source_Channel_Type = 'O'; 
            }else{
                ObpioList.Source_Channel_Type =  finalTermList.size() > 0 && finalTermList[0].Refered_By__c != null ? String.valueOf(finalTermList[0].Refered_By__c) : '';
            }
            String dsmName1 = finalTermList.size() > 0 && finalTermList[0].DSM_Name1__c != null ? finalTermList[0].DSM_Name1__c : '';
            String [] splittedDSMName1 = dsmName1.split('\\-');
            String dsmName2 = finalTermList.size() > 0 && finalTermList[0].DSM_Name2__c != null ? finalTermList[0].DSM_Name2__c : '';
            String [] splittedDSMName2 = dsmName2.split('\\-');
            ObpioList.DSM_Incentive1= finalTermList.size() > 0 && finalTermList[0].DSM_Incentive1__c != null ? (Integer)Decimal.valueOf(finalTermList[0].DSM_Incentive1__c).round(System.RoundingMode.HALF_EVEN) : 0;//CISP-3169
            ObpioList.DSM_Name1= splittedDSMName1 != null && splittedDSMName1.size() > 1 ? finalTermList[0].DSM_Name1__c.substringAfterLast('-') : '';
            ObpioList.DSM_Incentive2= finalTermList.size() > 0 && finalTermList[0].DSM_Incentive2__c!= null ? (Integer)Decimal.valueOf(finalTermList[0].DSM_Incentive2__c).round(System.RoundingMode.HALF_EVEN) : 0;//CISP-3169
            ObpioList.DSM_Name2= splittedDSMName2 != null && splittedDSMName2.size() > 1 ? finalTermList[0].DSM_Name2__c.substringAfterLast('-') : '';
            ObpioList.DSA_Incentive= finalTermList.size() > 0 && finalTermList[0].Rreferrer_Incentive__c != null ? (Integer)Decimal.valueOf(finalTermList[0].Rreferrer_Incentive__c).round(System.RoundingMode.HALF_EVEN) : 0;//CISP-3169
            ObpioList.DSA_Name= finalTermList.size() > 0 && finalTermList[0].Referrer_Ben_Code__c != null ? finalTermList[0].Referrer_Ben_Code__c : '';
            ObpioList.DMA_Incentive= 0;
            ObpioList.DMA_Name= '';
            ObpioList.Branch= finalTermList.size() > 0 && finalTermList[0].Branch__c != null ? finalTermList[0].Branch__c : '';
            ObpioList.Employee_No= finalTermList.size() > 0 && finalTermList[0].Emp_No__c != null ? finalTermList[0].Emp_No__c : '';
            ObpioList.Employee_Name= finalTermList.size() > 0 && finalTermList[0].Emp_Name__c != null ? finalTermList[0].Emp_Name__c : '';
            ObpioList.Reference_No=  finalTermList.size() > 0 && finalTermList[0].Deal_No__c != null? finalTermList[0].Deal_No__c : '';
            List<Repayments__c> repayment = [Select Id, Repayment_Method__c from Repayments__c where Loan_Application__c =: opptyDetails.Id];
            ObpioList.Collection_Mode = repayment.size() > 0 ? repayment[0].Repayment_Method__c : '';
            ObpioList.ECS_Verification_By=finalTermList.size() > 0 && finalTermList[0].ECS_verification_by__c != null? finalTermList[0].ECS_verification_by__c : '';
            ObpioList.ECS_Verification_Charges= finalTermList.size() > 0 && finalTermList[0].Verification_charges__c != null ? Decimal.valueOf(finalTermList[0].Verification_charges__c) : 0;
            ObpioList.Sub_Dlr_Incentive_Amt=finalTermList.size() > 0 && finalTermList[0].Dealer_incentive_amount_sub_dealer__c != null ? Decimal.valueOf(finalTermList[0].Dealer_incentive_amount_sub_dealer__c).round(System.RoundingMode.HALF_EVEN) : 0;
            ObpioList.Sub_Dlr_Incentive_Type=  ObpioList.Sub_Dlr_Incentive_Amt != null && ObpioList.Sub_Dlr_Incentive_Amt > 0 ? 'S' : '' ;//CISP-4155
            ObpioList.Stamping_Charges = finalTermList.size() > 0 && finalTermList[0].Stamping_charges__c != null ? (Integer)Decimal.valueOf(finalTermList[0].Stamping_charges__c) : 0;//CISP-3169
            ObpioList.POSB_Charges_By='';
            ObpioList.POSB_Charges= 0;
            ObpioList.Pseudo_DSM_Incentive1=0;
            ObpioList.Pseudo_DSM_Name1='';
            ObpioList.Pseudo_DSM_Incentive2= 0;
            ObpioList.Pseudo_DSM_Name2= '';
            ObpioList.Sourcing_Digital_Channel=PactLmsRequestHelper.getSourcingDigital(opptyDetails);
            ObpioList.Sourcing_Digital_Channel_ID= opptyDetails.IModuleId__c != null ? opptyDetails.IModuleId__c : '';
            objPayInOutList.add(ObpioList);   
            objPayInOutList=objPayInOutList;
            return objPayInOutList;
    }
 }