public class DealNumberBatch implements Database.Batchable<String>, Database.AllowsCallouts{
    public String processingRecordId;
    public List<String> dealNumbers;
    public String kfsparentId;
    public Boolean fromProCredit;
    public String entityType;
    public String productType;
    public DealNumberBatch(List<String> dealNumbers, String processingRecordId, String kfsparentId, String entityType, Boolean fromProCredit, String productType) {
        this.dealNumbers = dealNumbers;
        this.processingRecordId = processingRecordId;
        this.kfsparentId = kfsparentId;
        this.fromProCredit = fromProCredit;
        this.entityType = entityType;
        this.productType = productType;
    }


    public static String smsWrapper(Key_Fact_Statement__c kfs, String pcdId, Boolean fromProCredit, String loanAppId, String mobileNumber){
        Wrapperclass obj = new Wrapperclass(kfs, pcdId, fromProCredit, loanAppId, mobileNumber);
        String smsStr = JSON.serialize(obj);
        return smsStr;
      }
    
      public class Wrapperclass{
        public string flag;
        public string kfsId;
        public string kfsOtp;
        public string pcdId;
        public Boolean fromProCredit;
        public string loanApplicationId;
        public string mobileNumber;
    
        public Wrapperclass(Key_Fact_Statement__c kfs, String pcdId, Boolean fromProCredit, String loanAppId, String mobileNumber){
          this.flag = System.Label.KFS_Flag;
          this.kfsId = kfs.Id;
          this.kfsOtp = kfs.Keyfact_Consent_OTP__c;
          this.pcdId = pcdId;
          this.fromProCredit = fromProCredit;
          this.loanApplicationId = loanAppId;
          this.mobileNumber = mobileNumber;
        }
      }



    public Iterable<String> start(Database.BatchableContext bc){
        return dealNumbers;
    }

    public void execute(Database.BatchableContext bc, List<String> dealNos){
        try{
        //Logic to make callout by looping over dealNos
        for(String s : dealNos){
            String requestForIntegrationLog = '';
            String plainRequest = '';
            Long endTime;
            Long startTime;
            String elapseTime = '';
            IND_KFSAPIRequest kfsStatusRequest = IND_KFSService.getKFSCalloutMultiAsset(s,fromProCredit,processingRecordId);
            IND_KFSResponse apiResponse;
            String status = System.Label.Failure;
            List<KFS_Applicant__c> kfsApplicantList = new List<KFS_Applicant__c>();
            List<KFS_Instalment_Schedule__c> kfsInstallmentList = new List<KFS_Instalment_Schedule__c>();
            String pcdId;
            IND_KFSResponse parsedResponse = null;
            String coBorrowerCustomerCode = '';
            String coBorrowerId = '';
            String borrowerCustomerCode = '';
            String borrowerId = '';
            List<IND_KFSResponse.ApplicantDetails> applicantdetails = new List<IND_KFSResponse.ApplicantDetails>();
            List<IND_KFSResponse.VehicleDetails> vehicleDetails = new List<IND_KFSResponse.VehicleDetails>();
            List<IND_KFSResponse.FinalTerms> finalTerms = new List<IND_KFSResponse.FinalTerms>();
            List<IND_KFSResponse.InstalmentSchedule> installmentSchedule = new List<IND_KFSResponse.InstalmentSchedule>();
            List<IND_KFSResponse.MMVDetails> mmvDetails = new List<IND_KFSResponse.MMVDetails>();
            List<IND_KFSResponse.AddressDetails> addressDetails = new List<IND_KFSResponse.AddressDetails>();
            List<IND_KFSResponse.GSTDetails> gstDetails = new List<IND_KFSResponse.GSTDetails>();
            CalloutProcessor processor= new CalloutProcessor('KfsStatementQueueable', kfsStatusRequest);
            HttpRequest request = processor.createHttpRequest();
            requestForIntegrationLog = request.getBody();
            System.debug('Request body..'+requestForIntegrationLog);
            plainRequest = IntegrationUtilities.getPlainTextForLog(request.getBody());
            Http http = new Http();
            startTime = DateTime.now().getTime();
            HttpResponse response = http.send(request);
            System.debug('KFS-response: '+response);
            endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            System.debug('resp code is::'+response.getStatusCode());
            if(response != null && response.getStatusCode() == 200){
                status=System.Label.Success;
                apiResponse = (IND_KFSResponse)processor.getHttpResponse(response, 'KfsStatementQueueable');
                // if(apiResponse?.Lead_No != null){
                applicantdetails = apiResponse?.ApplicantDetails;
                vehicleDetails = apiResponse?.VehicleDetails;
                finalTerms = apiResponse?.FinalTerms;
                installmentSchedule = apiResponse?.InstalmentSchedule;
                mmvDetails = apiResponse?.MMVDetails;
                addressDetails = apiResponse?.AddressDetails;
                gstDetails = apiResponse?.GSTDetails;
                
                IntegrationUtilities.createIntegrationLogger(plainRequest, requestForIntegrationLog, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), 'Procredit KFS', elapseTime,processingRecordId,status);

                

                Key_Fact_Statement__c kfsparent = [SELECT Id,Deal_Number__c FROM Key_Fact_Statement__c WHERE Id=:kfsparentId];
                kfsparent.Deal_Number__c = kfsparent.Deal_Number__c!=null ? kfsparent.Deal_Number__c+';'+apiResponse.Deal_No : apiResponse.Deal_No;
                kfsparent.Lead_Number__c = apiResponse.Lead_No;
                update kfsparent;
                

                Key_Fact_Statement__c kfs = new Key_Fact_Statement__c();
                kfs.Key_Fact_Statement__c = kfsparent.Id;
                kfs.Lead_Number__c = apiResponse.Lead_No;
                kfs.Deal_Number__c = apiResponse.Deal_No;
                kfs.Dealer_Sub_dealer_name__c = apiResponse.Sub_Dealer;
                insert kfs;

                if(applicantdetails.size() > 0){
                    for(integer i=0; i< applicantdetails.size() ; i++){
                        KFS_Applicant__c newKfsApp = new KFS_Applicant__c();
                        newKfsApp.Key_Fact_Statement__c = kfs.Id;
                        newKfsApp.Applicant_Type__c = applicantdetails[i]?.ApplicantType;
                        newKfsApp.Customer_Name__c = applicantdetails[i]?.Customer_Name;
                        newKfsApp.Customer_Code__c = applicantdetails[i]?.Customer_Code;
                        newKfsApp.Passport_Number__c = applicantdetails[i]?.Passport_Number;
                        newKfsApp.PAN_GIR_Number__c = applicantdetails[i]?.PAN_GIR_Number;
                        newKfsApp.Voter_ID_Number__c = applicantdetails[i]?.Voter_ID_Number;
                        newKfsApp.Salutation__c = applicantdetails[i]?.Customer_Salutation;
                        newKfsApp.Passport_Expiry_Date__c = applicantdetails[i]?.Passport_Expiry_Date;
                        newKfsApp.Date_of_Birth__c = applicantdetails[i]?.Date_of_Birth;
                        newKfsApp.Driving_License_Number__c = applicantdetails[i]?.Driving_License_Number;
                        newKfsApp.Driving_License_Expiry_Date__c = applicantdetails[i]?.Driving_License_Expiry_Date;
                        newKfsApp.Aadhaar_Number__c = applicantdetails[i]?.Aadhaar_No;
                        newKfsApp.Form60__c = applicantdetails[i]?.FORM60;
                        newKfsApp.SurName__c = applicantdetails[i]?.SurName;
                        newKfsApp.Regn_Incorp_Date__c = applicantdetails[i]?.Regn_Incorp_Date;
                        newKfsApp.Customer_Type__c = applicantdetails[i]?.Customer_Type;
                        newKfsApp.UCIC__c = applicantdetails[i]?.UCIC;
                        newKfsApp.CKYC_ID__c = applicantdetails[i]?.CKYC_ID;
                        insert newKfsApp; //ApplicantType
                        if(newKfsApp.Applicant_Type__c.toLowerCase() == 'BORROWER'.toLowerCase()){
                            borrowerId = newKfsApp.Id;
                            borrowerCustomerCode = applicantdetails[i]?.Customer_Code;
                        }else if(newKfsApp.Applicant_Type__c.toLowerCase() == 'GUARANTOR'.toLowerCase()){
                            coBorrowerId = newKfsApp.Id;
                            coBorrowerCustomerCode = applicantdetails[i]?.Customer_Code;
                        }
                    }
                }

                if(addressDetails.size() > 0 && borrowerId != null && borrowerId != ''){
                    KFS_Applicant__c kfsa = new KFS_Applicant__c(Id=borrowerId);

                    for(integer i=0; i< addressDetails.size() ; i++){
                        if(addressDetails[i].Communication_Address_Flag != null && addressDetails[i].Communication_Address_Flag != '' && addressDetails[i].Customer_Code == borrowerCustomerCode){
                            kfsa.Communication_Address_Flag__c = addressDetails[i]?.Communication_Address_Flag;
                            kfsa.Mobile_Number__c = addressDetails[i]?.Mobile_Number;
                        }
                        if(addressDetails[i].Customer_Code == borrowerCustomerCode && addressDetails[i].Address_Flag == 'O'){
                            kfsa.Office_Address_Line_1__c = addressDetails[i]?.Address_Line_1;
                            kfsa.Office_Address_Line_3__c = addressDetails[i]?.Address_Line_3;
                            kfsa.Office_Address_Line_2__c = addressDetails[i]?.Address_Line_2;
                            kfsa.Office_Address_Line_4__c = addressDetails[i]?.Address_Line_4;
                            kfsa.Office_State__c = addressDetails[i]?.State;
                            kfsa.Office_District__c = addressDetails[i]?.District;
                            kfsa.Office_Pin_code__c = addressDetails[i]?.Pin_code;
                            kfsa.Office_City__c = addressDetails[i]?.City;
                            kfsa.Office_Mobile_Number__c = addressDetails[i]?.Mobile_Number;
                            kfsa.Office_Address_Flag__c = addressDetails[i]?.Address_Flag;
                        // kfsa.Communication_Address_Flag__c = addressDetails[i]?.City;
                        }else if(addressDetails[i].Customer_Code == borrowerCustomerCode && addressDetails[i].Address_Flag == 'P'){
                            kfsa.Permanent_Address_Line_1__c = addressDetails[i]?.Address_Line_1;
                            kfsa.Permanent_Address_Line_3__c = addressDetails[i]?.Address_Line_3;
                            kfsa.Permanent_Address_Line_2__c = addressDetails[i]?.Address_Line_2;
                            kfsa.Permanent_Address_Line_4__c = addressDetails[i]?.Address_Line_4;
                            kfsa.Permanent_State__c = addressDetails[i]?.State;
                            kfsa.Permanent_District__c = addressDetails[i]?.District;
                            kfsa.Permanent_Pin_code__c = addressDetails[i]?.Pin_code;
                            kfsa.Permanent_City__c = addressDetails[i]?.City;
                            //kfsa.Mobile_Number__c = addressDetails[i]?.Mobile_Number;
                            kfsa.Permanent_Address_Flag__c = addressDetails[i]?.Address_Flag;
                        }else if(addressDetails[i].Customer_Code == borrowerCustomerCode && addressDetails[i].Address_Flag == 'R'){
                            kfsa.Residential_Address_Line_1__c = addressDetails[i]?.Address_Line_1;
                            kfsa.Residential_Address_Line_3__c = addressDetails[i]?.Address_Line_3;
                            kfsa.Residential_Address_Line_2__c = addressDetails[i]?.Address_Line_2;
                            kfsa.Residential_Address_Line_4__c = addressDetails[i]?.Address_Line_4;
                            kfsa.Residential_State__c = addressDetails[i]?.State;
                            kfsa.Residential_District__c = addressDetails[i]?.District;
                            kfsa.Residential_Pin_code__c = addressDetails[i]?.Pin_code;
                            kfsa.Residential_City__c = addressDetails[i]?.City;
                            kfsa.Residential_Mobile_Number__c = addressDetails[i]?.Mobile_Number;
                            kfsa.Residential_Address_Flag__c = addressDetails[i]?.Address_Flag;
                        }
                    }
                    update kfsa;
                }

                if(addressDetails.size() > 0 && coBorrowerId != null && coBorrowerId != ''){
                    KFS_Applicant__c kfsacb = new KFS_Applicant__c(Id=coBorrowerId);

                    for(integer i=0; i< addressDetails.size() ; i++){
                        if(addressDetails[i].Communication_Address_Flag != null && addressDetails[i].Communication_Address_Flag != '' && addressDetails[i].Customer_Code == coBorrowerCustomerCode){
                            kfsacb.Communication_Address_Flag__c = addressDetails[i]?.Communication_Address_Flag;
                            kfsacb.Mobile_Number__c = addressDetails[i]?.Mobile_Number;
                        }
                        if(addressDetails[i].Customer_Code == coBorrowerCustomerCode && addressDetails[i].Address_Flag == 'O'){
                            kfsacb.Office_Address_Line_1__c = addressDetails[i]?.Address_Line_1;
                            kfsacb.Office_Address_Line_3__c = addressDetails[i]?.Address_Line_3;
                            kfsacb.Office_Address_Line_2__c = addressDetails[i]?.Address_Line_2;
                            kfsacb.Office_Address_Line_4__c = addressDetails[i]?.Address_Line_4;
                            kfsacb.Office_State__c = addressDetails[i]?.State;
                            kfsacb.Office_District__c = addressDetails[i]?.District;
                            kfsacb.Office_Pin_code__c = addressDetails[i]?.Pin_code;
                            kfsacb.Office_City__c = addressDetails[i]?.City;
                            kfsacb.Office_Mobile_Number__c = addressDetails[i]?.Mobile_Number;
                            kfsacb.Office_Address_Flag__c = addressDetails[i]?.Address_Flag;
                        // kfsa.Communication_Address_Flag__c = addressDetails[i]?.City;
                        }else if(addressDetails[i].Customer_Code == coBorrowerCustomerCode && addressDetails[i].Address_Flag == 'P'){
                            kfsacb.Permanent_Address_Line_1__c = addressDetails[i]?.Address_Line_1;
                            kfsacb.Permanent_Address_Line_3__c = addressDetails[i]?.Address_Line_3;
                            kfsacb.Permanent_Address_Line_2__c = addressDetails[i]?.Address_Line_2;
                            kfsacb.Permanent_Address_Line_4__c = addressDetails[i]?.Address_Line_4;
                            kfsacb.Permanent_State__c = addressDetails[i]?.State;
                            kfsacb.Permanent_District__c = addressDetails[i]?.District;
                            kfsacb.Permanent_Pin_code__c = addressDetails[i]?.Pin_code;
                            kfsacb.Permanent_City__c = addressDetails[i]?.City;
                            //kfsacb.Mobile_Number__c = addressDetails[i]?.Mobile_Number;
                            kfsacb.Permanent_Address_Flag__c = addressDetails[i]?.Address_Flag;
                        }else if(addressDetails[i].Customer_Code == coBorrowerCustomerCode && addressDetails[i].Address_Flag == 'R'){
                            kfsacb.Residential_Address_Line_1__c = addressDetails[i]?.Address_Line_1;
                            kfsacb.Residential_Address_Line_3__c = addressDetails[i]?.Address_Line_3;
                            kfsacb.Residential_Address_Line_2__c = addressDetails[i]?.Address_Line_2;
                            kfsacb.Residential_Address_Line_4__c = addressDetails[i]?.Address_Line_4;
                            kfsacb.Residential_State__c = addressDetails[i]?.State;
                            kfsacb.Residential_District__c = addressDetails[i]?.District;
                            kfsacb.Residential_Pin_code__c = addressDetails[i]?.Pin_code;
                            kfsacb.Residential_City__c = addressDetails[i]?.City;
                            kfsacb.Residential_Mobile_Number__c = addressDetails[i]?.Mobile_Number;
                            kfsacb.Residential_Address_Flag__c = addressDetails[i]?.Address_Flag;
                        }
                    }
                    update kfsacb;
                }
                

                if(vehicleDetails.size() > 0){
                    for(integer i=0; i< vehicleDetails.size() ; i++){
                        Key_Fact_Statement__c kfsv = new Key_Fact_Statement__c(Id=kfs.Id);
                        kfsv.Engine_Number__c = vehicleDetails[i]?.Engine_No;
                        kfsv.Chassis_number__c = vehicleDetails[i]?.Chassis_no;
                        kfsv.Vehicle_Registration_number__c = vehicleDetails[i]?.Vehicle_Reg_No;
                        String vp = vehicleDetails[i]?.Valuation_Charges;
                        kfsv.Valuation_price__c = vp==null || String.isBlank(vp) ? 0:Decimal.valueOf(vp) ;
                       


                        kfsv.Insurance_Combo_Fund_Type__c =  vehicleDetails[i]?.Combo_Fund_Type;
                        kfsv.Insurance_Combo_Fund_Type_G__c = vehicleDetails[i]?.Combo_Fund_Type_G;

                        String cp = vehicleDetails[i]?.Combo_Premium;
                        kfsv.Insurance_Combo_Premium__c = cp==null || String.isBlank(cp) ? 0:Decimal.valueOf(cp) ;

                        String cpg = vehicleDetails[i]?.Combo_Premium_G;
                        kfsv.Insurance_Combo_Premium_G__c = cpg==null || String.isBlank(cpg) ?0: Decimal.valueOf(cpg);

                        kfsv.Insurance_Combo_Product__c = vehicleDetails[i]?.Combo_Product;
                        kfsv.Insurance_Combo_Product_G__c =  vehicleDetails[i]?.Combo_Product_G;
                        kfsv.Insurance_Flexi_Fund_Type__c = vehicleDetails[i]?.Flexi_Fund_Type;
                        kfsv.Insurance_Flexi_Fund_Type_G__c = vehicleDetails[i]?.Flexi_Fund_Type_G;

                        String fp = vehicleDetails[i]?.Flexi_Prm;
                        kfsv.Insurance_Flexi_Premium__c = fp==null || String.isBlank(fp) ?0: Decimal.valueOf(fp) ;

                        String fpg = vehicleDetails[i]?.Flexi_Prm_G;
                        kfsv.Insurance_Flexi_Premium_G__c = fpg==null || String.isBlank(fpg) ?0: Decimal.valueOf(fpg) ;

                        String gpa = vehicleDetails[i]?.GPA_Premium;
                        kfsv.Insurance_GPA_Premium__c = gpa==null || String.isBlank(gpa)?0: Decimal.valueOf(gpa) ;

                        String gpag = vehicleDetails[i]?.GPA_Premium_G;
                        kfsv.Insurance_GPA_Premium_G__c = gpag==null || String.isBlank(gpag)?0: Decimal.valueOf(gpag) ;

                        
                        kfsv.Insurance_GPA_Type__c = vehicleDetails[i]?.GPA_Type;
                        kfsv.Insurance_GPA_Type_G__c = vehicleDetails[i]?.GPA_Type_G;
                        kfsv.Insurance_Health_Fund_Type__c = vehicleDetails[i]?.Health_Fund_Type;
                        kfsv.Insurance_Health_Fund_Type_G__c =  vehicleDetails[i]?.Health_Fund_Type_G;

                        String ihp = vehicleDetails[i]?.Health_Premium;
                        kfsv.Insurance_Health_Premium__c = ihp==null || String.isBlank(ihp)? 0:Decimal.valueOf(ihp) ;

                        String ihpg = vehicleDetails[i]?.Health_Premium_G;
                        kfsv.Insurance_Health_Premium_G__c = ihpg==null || String.isBlank(ihpg) ? 0:Decimal.valueOf(ihpg) ;

                
                        kfsv.Insurance_LI_Fund_Type__c = vehicleDetails[i]?.LI_Fund_Type;
                        kfsv.Insurance_LI_Fund_Type_G__c = vehicleDetails[i]?.LI_Fund_Type_G;


                        String ilp = vehicleDetails[i]?.LI_Prm;
                        kfsv.Insurance_LI_Premium__c = ilp==null || String.isBlank(ilp) ? 0 : Decimal.valueOf(ilp);

                        String ilpg = vehicleDetails[i]?.LI_Prm_G;
                        kfsv.Insurance_LI_Premium_G__c = ilpg==null || String.isBlank(ilpg)  ? 0 : Decimal.valueOf(ilpg);

                        kfsv.Insurance_Motor_Fund_Type__c = vehicleDetails[i]?.Motor_Fund_Type;

                        String ip = vehicleDetails[i]?.Ins_Premium;
                        kfsv.Insurance_Premium__c = ip==null || String.isBlank(ip)  ? 0 : Decimal.valueOf(ip) ;

                        String ipi = vehicleDetails[i]?.Ins_Prm_I;
                        kfsv.Insurance_Premium_I__c = ipi==null || String.isBlank(ipi) ? 0 : Decimal.valueOf(ipi);

                       /* String ippi = vehicleDetails[i]?.Ins_Prm_Paid_I;
                        kfsv.Insurance_Premium_Paid_I__c = ippi==null || String.isBlank(ippi) ? 0 : Decimal.valueOf(ippi);
                        */
                        kfsv.Insurance_Premium_Paid_I__c = vehicleDetails[i]?.Ins_Prm_Paid_I;
                        String srp = vehicleDetails[i]?.Subh_Raksha_Prm;
                        kfsv.Insurance_Subh_Raksha_Premium__c = srp==null || String.isBlank(srp) ? 0 : Decimal.valueOf(srp);

                        String srpg = vehicleDetails[i]?.Subh_Raksha_Prm_G;
                        kfsv.Insurance_Subh_Raksha_Premium_G__c = srpg==null || String.isBlank(srpg) ? 0 : Decimal.valueOf(srpg);
                        kfsv.Insurance_Tata_Emi_Fund_Type__c = vehicleDetails[i]?.TATA_EMI_Fund_Type;
                        String itep = vehicleDetails[i]?.TATA_EMI_Premium;
                        kfsv.Insurance_Tata_Emi_Premium__c = itep==null || String.isBlank(itep) ? 0 : Decimal.valueOf(itep);

                        kfsv.Installment_Pattern_Type__c = vehicleDetails[i]?.Install_Pattern_Type;

                        update kfsv;
                    }
                }

                Decimal totalC = 0.0;
                Decimal totalB = 0.0;

                Key_Fact_Statement__c kf = [SELECT Id,Total_Insurance_Funded_By_Customer__c,Total_Insurance_Funded_By_Bank__c,Insurance_GPA_Type__c,Insurance_GPA_Premium__c,Insurance_Combo_Fund_Type__c,Insurance_Combo_Premium__c,
                Insurance_Combo_Fund_Type_G__c,Insurance_Combo_Premium_G__c,Insurance_Flexi_Fund_Type__c,Insurance_Flexi_Premium__c,
                Insurance_Flexi_Fund_Type_G__c,Insurance_Flexi_Premium_G__c,
                Insurance_GPA_Type_G__c,Insurance_GPA_Premium_G__c,
                Insurance_Health_Fund_Type__c,Insurance_Health_Premium__c,
                Insurance_Health_Fund_Type_G__c,Insurance_Health_Premium_G__c,
                Insurance_LI_Fund_Type__c, Insurance_LI_Premium__c,
                Insurance_LI_Fund_Type_G__c, Insurance_LI_Premium_G__c,
                Insurance_Tata_Emi_Fund_Type__c, Insurance_Tata_Emi_Premium__c,
                Insurance_Motor_Fund_Type__c,Insurance_Premium_Paid_I__c, Insurance_Premium_I__c FROM Key_Fact_Statement__c WHERE Id=:kfs.Id];

                totalC = kf.Insurance_GPA_Type__c == 'C' ? totalC+kf.Insurance_GPA_Premium__c : totalC;
                totalB = kf.Insurance_GPA_Type__c == 'B' ? totalB+kf.Insurance_GPA_Premium__c : totalB;
                if(productType=='H'){
                totalC = kf.Insurance_Combo_Fund_Type__c == 'C' ? totalC+kf.Insurance_Combo_Premium__c : totalC;
                totalB = kf.Insurance_Combo_Fund_Type__c == 'B' ? totalB+kf.Insurance_Combo_Premium__c : totalB;
                
                totalC = kf.Insurance_Combo_Fund_Type_G__c == 'C' ? totalC+kf.Insurance_Combo_Premium_G__c : totalC;
                totalB = kf.Insurance_Combo_Fund_Type_G__c == 'B' ? totalB+kf.Insurance_Combo_Premium_G__c : totalB;
                }
                totalC = kf.Insurance_Flexi_Fund_Type__c == 'C' ? totalC+kf.Insurance_Flexi_Premium__c : totalC;
                totalB = kf.Insurance_Flexi_Fund_Type__c == 'B' ? totalB+kf.Insurance_Flexi_Premium__c : totalB;

                totalC = kf.Insurance_Flexi_Fund_Type_G__c == 'C' ? totalC+kf.Insurance_Flexi_Premium_G__c : totalC;
                totalB = kf.Insurance_Flexi_Fund_Type_G__c == 'B' ? totalB+kf.Insurance_Flexi_Premium_G__c : totalB;

                totalC = kf.Insurance_GPA_Type_G__c == 'C' ? totalC+kf.Insurance_GPA_Premium_G__c : totalC;
                totalB = kf.Insurance_GPA_Type_G__c == 'B' ? totalB+kf.Insurance_GPA_Premium_G__c : totalB;

                totalC = kf.Insurance_Health_Fund_Type__c == 'C' ? totalC+kf.Insurance_Health_Premium__c : totalC;
                totalB = kf.Insurance_Health_Fund_Type__c == 'B' ? totalB+kf.Insurance_Health_Premium__c : totalB;

                totalC = kf.Insurance_Health_Fund_Type_G__c == 'C' ? totalC+kf.Insurance_Health_Premium_G__c : totalC;
                totalB = kf.Insurance_Health_Fund_Type_G__c == 'B' ? totalB+kf.Insurance_Health_Premium_G__c : totalB;

                totalC = kf.Insurance_LI_Fund_Type__c == 'C' ? totalC+kf.Insurance_LI_Premium__c : totalC;
                totalB = kf.Insurance_LI_Fund_Type__c == 'B' ? totalB+kf.Insurance_LI_Premium__c : totalB;

                totalC = kf.Insurance_LI_Fund_Type_G__c == 'C' ? totalC+kf.Insurance_LI_Premium_G__c : totalC;
                totalB = kf.Insurance_LI_Fund_Type_G__c == 'B' ? totalB+kf.Insurance_LI_Premium_G__c : totalB;

                totalC = kf.Insurance_Tata_Emi_Fund_Type__c == 'C' ? totalC+kf.Insurance_Tata_Emi_Premium__c : totalC;
                totalB = kf.Insurance_Tata_Emi_Fund_Type__c == 'B' ? totalB+kf.Insurance_Tata_Emi_Premium__c : totalB;

                totalC = kf.Insurance_Motor_Fund_Type__c == 'C' && kf.Insurance_Premium_Paid_I__c == 'C' ? totalC+kf.Insurance_Premium_I__c :totalC;
                totalB = kf.Insurance_Motor_Fund_Type__c == 'B' && kf.Insurance_Premium_Paid_I__c == 'B' ? totalB+kf.Insurance_Premium_I__c :totalB;
            

                kf.Total_Insurance_Funded_By_Customer__c = totalC;
                kf.Total_Insurance_Funded_By_Bank__c = totalB;

                update kf;

                if(finalTerms.size() > 0){
                    for(integer i=0; i< finalTerms.size() ; i++){
                        Key_Fact_Statement__c kfsf = new Key_Fact_Statement__c(Id=kfs.Id);

                        String loanAmount = finalTerms[i]?.Fin_Amt;
                        kfsf.Loan_Amount__c = loanAmount==null || String.isBlank(loanAmount) ? 0 : Decimal.valueOf(loanAmount);
                        
                            String loanAmountChassis = finalTerms[i]?.Fin_Amt_Chasis;
                        kfsf.Loan_Amount_Chassis__c = loanAmountChassis == null || String.isBlank(loanAmountChassis) ? 0 : Decimal.valueOf(loanAmountChassis);
                        String ihmComputed = finalTerms[i]?.IHM_Computed;
                        kfsf.IHM_Computed__c = ihmComputed == null || String.isBlank(ihmComputed) ? 0 : Decimal.valueOf(ihmComputed);

                        kfsf.BL_Name__c = finalTerms[i]?.Bl_Name;
                        kfsf.BL_Code__c = finalTerms[i]?.Bl_Code;
                        kfsf.Sold_By_Dealer_Name__c = finalTerms[i]?.Sold_By_Dealer_Name;
                        kfsf.Effetive_From_Date__c = finalTerms[i]?.Eff_from_date;

                        //kfsf.Loan_Amount__c = finalTerms[i]?.Fin_Amt;
                        kfsf.Gross_IRR__c = finalTerms[i]?.Gross_IRR;
                        kfsf.Deal_Period__c = finalTerms[i]?.Deal_Period;
                        kfsf.Moratorium__c = finalTerms[i]?.Moratorium;
                        kfsf.Advance_EMI_Number__c = finalTerms[i]?.Advance_EMI_Nos;
                        String crmIrr = finalTerms[i]?.CRM_IRR;
                        kfsf.CRM_IRR__c = crmIrr==null || String.isBlank(crmIrr) ? 0 : Decimal.valueOf(crmIrr);

                        kfsf.First_EMI_Date__c = finalTerms[i]?.First_EMI_Date;
                        kfsf.Second_EMI_Date__c = finalTerms[i]?.Second_EMI_Date;
                        kfsf.Gross_LTV__c = finalTerms[i]?.Gross_LTV;
                        kfsf.Vehicle_Category__c = finalTerms[i]?.Vehicle_Category;
                        kfsf.Vehicle_Sub_Category__c = finalTerms[i]?.Vehicle_Sub_Category;
                        kfsf.Product__c = finalTerms[i]?.Product;
                        kfsf.Mfg_Year__c = finalTerms[i]?.Mfg_Year;
                        kfsf.Service_Charges__c = finalTerms[i]?.Service_Charges;
                        
                        String docChargs = finalTerms[i]?.Doc_Charges;
                        kfsf.Document_Charges__c = docChargs==null || String.isBlank(docChargs) ? 0 : Decimal.valueOf(docChargs);

                        String stampChargs = finalTerms[i]?.Stamping_Charges;
                        kfsf.Stamping_Charges__c = stampChargs==null || String.isBlank(stampChargs) ? 0 : Decimal.valueOf(stampChargs);

                        String totalIntrstAmnt = finalTerms[i]?.Finance_Charges;
                        kfsf.Total_Interest_Amount__c = totalIntrstAmnt==null || String.isBlank(totalIntrstAmnt) ? 0 : Decimal.valueOf(totalIntrstAmnt);

                        String totatAmntPaidBorr = finalTerms[i]?.Agreement_Value;
                        kfsf.Total_Amount_Paid_By_Borrower__c = totatAmntPaidBorr==null || String.isBlank(totatAmntPaidBorr) ? 0 : Decimal.valueOf(totatAmntPaidBorr);

                        String netDisbAmnt = finalTerms[i]?.Net_Disburse_Amt;
                        kfsf.Net_Disburse_Amount__c = netDisbAmnt==null || String.isBlank(netDisbAmnt) ? 0 : Decimal.valueOf(netDisbAmnt);
                        
                        String netDisbAmntApr = finalTerms[i]?.Net_Disburse_Amt_Apr;
                        kfsf.Net_Disbursement_APR__c = netDisbAmntApr==null || String.isBlank(netDisbAmntApr) ? 0 : Decimal.valueOf(netDisbAmntApr);


                        String apr = finalTerms[i]?.APR;
                        kfsf.APR__c = apr==null || String.isBlank(apr) ? 0 : Decimal.valueOf(apr).setScale(4);
                        kfsf.MCLR__c = finalTerms[i]?.MCLR;
                        kfsf.Type_Of_Instalments__c = finalTerms[i]?.Periodicity;
                        
                       
                        kfsf.Instalment_Numbers__c = finalTerms[i]?.Instalment_Nos;

                        String invoiceAmount = finalTerms[i]?.Invoice_Amt;
                        kfsf.Invoice_Amount__c = invoiceAmount==null || String.isBlank(invoiceAmount) ? 0 : Decimal.valueOf(invoiceAmount);

                        kfsf.Deal_Date__c = finalTerms[i]?.Deal_Date;
                        //kfsf.Invoice_Amount__c = finalTerms[i]?.Invoice_Amt;
                        update kfsf;
                    }
                }

                if(installmentSchedule.size() > 0){
                    for(integer i=0; i< installmentSchedule.size() ; i++){
                        KFS_Instalment_Schedule__c kfsIns = new KFS_Instalment_Schedule__c();
                        kfsIns.Key_Fact_Statement__c = kfs.Id;
                        
                        String rdAmnt = installmentSchedule[i]?.RD_Amount;
                        kfsIns.RD_Amount__c = rdAmnt==null || String.isBlank(rdAmnt) ? 0 : Decimal.valueOf(rdAmnt);
                       
                        String cmbAmnt = installmentSchedule[i]?.Combo_Amt;
                        kfsIns.Combo_Amount__c = cmbAmnt==null || String.isBlank(cmbAmnt) ? 0 : Decimal.valueOf(cmbAmnt);

                        kfsIns.Instal_Date__c = installmentSchedule[i]?.Instal_Date;

                        String posbChrgs = installmentSchedule[i]?.POSB_Charges;
                        kfsIns.POSB_Charges__c = posbChrgs==null || String.isBlank(posbChrgs) ? 0 : Decimal.valueOf(posbChrgs);

                        String hospCashAmnt = installmentSchedule[i]?.Hospital_Cash_Amt;
                        kfsIns.Hospital_Cash_Amount__c = hospCashAmnt==null || String.isBlank(hospCashAmnt) ? 0 : Decimal.valueOf(hospCashAmnt);
                        
                        String healthAmnt = installmentSchedule[i]?.Health_Amt;
                        kfsIns.Health_Amount__c = healthAmnt==null || String.isBlank(healthAmnt) ? 0 : Decimal.valueOf(healthAmnt);

                        String emiAmnt = installmentSchedule[i]?.EMI;
                        kfsIns.EMI_Amount__c = emiAmnt==null || String.isBlank(emiAmnt) ? 0 : Decimal.valueOf(emiAmnt);

                        String insurAmnt = installmentSchedule[i]?.Insur_Amt;
                        kfsIns.Insur_Amount__c = insurAmnt==null || String.isBlank(insurAmnt) ? 0 : Decimal.valueOf(insurAmnt);

                        String installAmnt = installmentSchedule[i]?.Instal_Amt;
                        kfsIns.Instal_Amount__c = installAmnt==null || String.isBlank(installAmnt) ? 0 : Decimal.valueOf(installAmnt);

                        kfsIns.Instal_Number__c = installmentSchedule[i]?.Instal_Nos;
                        kfsIns.To_Month__c = installmentSchedule[i]?.To_No;
                        kfsIns.From_Month__c = installmentSchedule[i]?.From_No;
                        kfsIns.Deal_Number__c = installmentSchedule[i]?.Deal_No;

                        String balance = installmentSchedule[i]?.Balance;
                        kfsIns.Balance__c = balance==null || String.isBlank(balance) ? 0 : Decimal.valueOf(balance);

                        String interest = installmentSchedule[i]?.Interest;
                        kfsIns.Interest__c = interest==null || String.isBlank(interest) ? 0 : Decimal.valueOf(interest);

                        String principal = installmentSchedule[i]?.Principal;
                        kfsIns.Principal__c = principal==null || String.isBlank(principal) ? 0 : Decimal.valueOf(principal);

                        kfsInstallmentList.add(kfsIns);
                    }
                }
                if(kfsInstallmentList.size() > 0){
                    insert kfsInstallmentList;
                }

                if(mmvDetails.size() > 0){
                    for(integer i=0; i< mmvDetails.size() ; i++){
                        Key_Fact_Statement__c kfsm = new Key_Fact_Statement__c(Id=kfs.Id);
                        kfsm.Varient_Code__c = mmvDetails[i]?.Product_Varient_code;
                        kfsm.Variant__c = mmvDetails[i]?.Product_Variant_Name;
                        kfsm.Product_Code__c = mmvDetails[i]?.Product_Code;
                        kfsm.Model__c = mmvDetails[i]?.Product_Name;
                        kfsm.Make__c = mmvDetails[i]?.Make;
                        kfsm.Beneficiary_Code__c = mmvDetails[i]?.Beneficiary_Code;
                        update kfsm;
                    }
                }
                if(gstDetails.size() > 0){
                    Key_Fact_Statement__c kfsg = new Key_Fact_Statement__c(Id=kfs.Id);
                    for(integer i=0; i< gstDetails.size() ; i++){
                        if(gstDetails[i].Nature !=null && gstDetails[i].Nature !='' && gstDetails[i].Nature == 'SERV_CHRGS'){
                            String serGstVal = gstDetails[i].GST_Value;
                            kfsg.Service_Charges_Gst_Value__c = serGstVal==null || String.isBlank(serGstVal) ? 0 : Decimal.valueOf(serGstVal);
                            String serWthoutGstVal = gstDetails[i].Document_Value;
                            kfsg.Service_Charges_Without_Gst__c = serWthoutGstVal==null || String.isBlank(serWthoutGstVal) ? 0 :Decimal.valueOf( serWthoutGstVal);
                            kfsg.GST_Number__c = gstDetails[i].GST_Number;
                        }else if(gstDetails[i].Nature !=null && gstDetails[i].Nature !='' && gstDetails[i].Nature == 'DOC_CHRGS'){
                            String serGstVal = gstDetails[i].GST_Value;
                            kfsg.Document_Charges_Gst_Value__c = serGstVal==null || String.isBlank(serGstVal) ? 0 : Decimal.valueOf(serGstVal);
                            String serWthoutGstVal = gstDetails[i].Document_Value;
                            kfsg.Document_Charges_Without_Gst__c = serWthoutGstVal==null || String.isBlank(serWthoutGstVal) ? 0 : Decimal.valueOf(serWthoutGstVal);
                            kfsg.GST_Number__c = gstDetails[i].GST_Number;
                        }
                    }
                    update kfsg;
                }

             /*   if(!fromProCredit){
                    IntegrationUtilities.createIntegrationLogger(plainRequest, requestForIntegrationLog, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), 'Key Fact Statement', elapseTime,processingRecordId,status);
                }else{
                    IntegrationUtilities.createIntegrationLogger(plainRequest, requestForIntegrationLog, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), 'Procredit KFS', elapseTime,processingRecordId,status);
                }
                */
            }else {
                try{
                    String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                    ProCredit_Deals__c pcd = [SELECT Id,Error_Message__c FROM ProCredit_Deals__c WHERE Id=:processingRecordId];
                    pcd.Error_Message__c =  errString;
                    update pcd;
                    IntegrationUtilities.createIntegrationLogger(plainRequest, requestForIntegrationLog, errString, response.getBody(), 'Procredit KFS', elapseTime, processingRecordId, System.Label.Failure);
                    ErrorLoggerUtil.logErrorEventProCreditDeal('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString) ,processingRecordId);
                }catch(Exception ex){
                    String errString ='++++ getStatusCode++++' +response.getStatusCode()+'++++getStatus++++' +response.getStatus();
                    ProCredit_Deals__c pcd = [SELECT Id,Error_Message__c FROM ProCredit_Deals__c WHERE Id=:processingRecordId];
                    pcd.Error_Message__c =  errString;
                    update pcd;
                    IntegrationUtilities.createIntegrationLogger(plainRequest, requestForIntegrationLog, errString, '', 'Procredit KFS', elapseTime, processingRecordId, System.Label.Failure);
                    ErrorLoggerUtil.logErrorEventProCreditDeal('CalloutProcessor', 'getHttpResponse', System.Label.Apex, ex ,processingRecordId);
                }            
            }
        } 
    }catch(Exception ex){
            ProCredit_Deals__c pcd = [SELECT Id,Error_Message__c FROM ProCredit_Deals__c WHERE Id=:processingRecordId];
            pcd.Error_Message__c =  ex.getMessage();
            update pcd;
            ErrorLoggerUtil.logErrorEventProCreditDeal('IntegrationEngine', 'processKFSResponse', System.Label.Apex, ex ,processingRecordId);
            throw new IND_Exception(ex.getMessage());
        }
        }

    public void finish(Database.BatchableContext bc){
        try{
            if(entityType != 'NON'){
                System.debug('finishhed___'+kfsparentId);
                ProCredit_Deals__c pcd = [SELECT Id,SMS_URL__c FROM ProCredit_Deals__c WHERE Id=:processingRecordId];
                    Key_Fact_Statement__c kfssms = [SELECT Id,Keyfact_Consent_OTP__c,Keyfact_Form_SMS_Sent__c FROM Key_Fact_Statement__c WHERE Id=:kfsparentId];
                    Key_Fact_Statement__c kfschild = [SELECT Id FROM Key_Fact_Statement__c WHERE Key_Fact_Statement__c=:kfssms.Id LIMIT 1];
    
                    KFS_Applicant__c kfsapp = [SELECT Id,Applicant_Type__c,Mobile_Number__c,Office_Mobile_Number__c,Residential_Mobile_Number__c FROM KFS_Applicant__c WHERE Key_Fact_Statement__c=:kfschild.Id AND Applicant_Type__c='BORROWER'];
                    String mobileNumber = kfsapp.Mobile_Number__c != null ? kfsapp.Mobile_Number__c : kfsapp.Office_Mobile_Number__c != null ? kfsapp.Office_Mobile_Number__c : kfsapp.Residential_Mobile_Number__c != null ? kfsapp.Residential_Mobile_Number__c : '';
                    String app_str = smsWrapper(kfssms,pcd.Id, fromProCredit,'', mobileNumber);
                    Map<String,String> responseString = IntegrationEngine.doKFSSmsGatewayAPI(app_str);
                    pcd.SMS_URL__c = responseString.get('requestfortesting');
                    update pcd;
            }else{
              // if(fromProCredit){
                    ProCredit_Deals__c pcd = [SELECT Id,SMS_URL__c FROM ProCredit_Deals__c WHERE Id=:processingRecordId];
                    Key_Fact_Statement__c kfssms = [SELECT Id,Keyfact_Consent_OTP__c,Keyfact_Form_SMS_Sent__c FROM Key_Fact_Statement__c WHERE Id=:kfsparentId];
                    Key_Fact_Statement__c kfschild = [SELECT Id FROM Key_Fact_Statement__c WHERE Key_Fact_Statement__c=:kfssms.Id LIMIT 1];
    
                    KFS_Applicant__c kfsapp = [SELECT Id,Applicant_Type__c,Mobile_Number__c,Office_Mobile_Number__c,Residential_Mobile_Number__c FROM KFS_Applicant__c WHERE Key_Fact_Statement__c=:kfschild.Id AND Applicant_Type__c='BORROWER'];
                    String mobileNumber = kfsapp.Mobile_Number__c != null ? kfsapp.Mobile_Number__c : kfsapp.Office_Mobile_Number__c != null ? kfsapp.Office_Mobile_Number__c : kfsapp.Residential_Mobile_Number__c != null ? kfsapp.Residential_Mobile_Number__c : '';
                    String app_str = smsWrapper(kfssms,pcd.Id, fromProCredit,'', mobileNumber);
                    if(!Test.isRunningTest()){
                    Map<String,String> responseString = KFSCalloutController.doKFSSmsGatewayAPI(app_str);
                    pcd.SMS_URL__c = responseString.get('requestfortesting');
                    update pcd;   
                    }
    
                System.debug('entitytype'+entityType);
               }
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEventProCreditDeal('DealNumberBatch', 'finishMethod', System.Label.Apex, ex ,processingRecordId);
        } 
    }
}