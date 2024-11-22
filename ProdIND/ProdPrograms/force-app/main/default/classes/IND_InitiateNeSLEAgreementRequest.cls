/*------------------------------------------------------------
 Author:        Yugandhar
 Company:       Persistent Systems
 Description:   This class is wrapper class for the InitiateNeSLEAgreement API request
 Apex Class : IND_InitiateNeSLEAgreementRequest for API InitiateNeSLEAgreement
 Test Class:
 History
 Date            Author              Comments
 -------------------------------------------------------------
 12-31-2021      Yugandhar      Created

 06-15-2022      Gaurav Rawat   Modified
 ------------------------------------------------------------*/
 public class IND_InitiateNeSLEAgreementRequest extends ParentAPIRequest{
    public Loan loan{ get; set; }

    // @Method:      IND_InitiateNeSLEAgreementRequest
    // @Created by:  Yugandhar
    // @Description: Contructor to initialize the details
    // @Param:       Object applicant Record
    // @Return:      ''
    public IND_InitiateNeSLEAgreementRequest(Applicant__c app, String loanAppId,String initiationMethod, String dealId){ // Gaurav Changes
        Opportunity oppRec = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanAppId WITH SECURITY_ENFORCED];
        Loan loanWrapper = new Loan();
        LoadDetails loadDetail = new LoadDetails();
        List<DocumentDtls> documentDtlList = new List<DocumentDtls>();
        List<ESignCordinate> eSignCordinateList = new List<ESignCordinate>();
        AssetParticulars assetParticulars = new AssetParticulars();
        List<String> coordinatesList = new List<String>();
        coordinatesList.add('1, 447, 770');
        coordinatesList.add('2, 447, 770');
        coordinatesList.add('3, 447, 770');
        coordinatesList.add('4, 447, 770');
        coordinatesList.add('5, 447, 770');
        coordinatesList.add('6, 447, 770');
        coordinatesList.add('7, 447, 770');
        coordinatesList.add('8, 447, 770');
        coordinatesList.add('9, 447, 770');
        coordinatesList.add('10, 447, 770');
        coordinatesList.add('11, 447, 770');
        coordinatesList.add('12, 447, 770');
        coordinatesList.add('13, 447, 770');
        coordinatesList.add('14, 447, 770');
        coordinatesList.add('15, 447, 770');
        coordinatesList.add('16, 447, 770');
        coordinatesList.add('17, 447, 770');
        coordinatesList.add('18, 447, 770');
        coordinatesList.add('19, 447, 770');
        coordinatesList.add('20, 447, 770');
        coordinatesList.add('21, 447, 770');
        coordinatesList.add('22, 447, 770');
        String benifCode = '';

        FinanceDtls financeDtls = new FinanceDtls();
        OtherCharges otherCharges = new OtherCharges();
        ObjStamping objStamping = new ObjStamping();
        List<PaymentInstallment> paymentInstallmentList = new List<PaymentInstallment>();
        String makeId = [Select id,Maker_Id__c From User Where Id =: UserInfo.getUserId()].Maker_Id__c;

        ReceiptDtls receiptDtlsObj = new ReceiptDtls();

        List<Documents__c> documentsList = new List<Documents__c>();
        if(oppRec.Product_Type__c == System.Label.Tractor){
            List<Vehicle_Detail__c> VehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
            documentsList = [SELECT Id,IHM_receipt_number__c,Name,IHM_receipt_date__c,IHM_amount_as_per_receipt__c 
                                FROM Documents__c 
                                WHERE Opportunity_Relation__c =: LoanAppId AND Document_Type__c = 'IHM Receipt' AND is_Active__c = true AND Vehicle_Detail__c =: VehicleLst[0].Id
                                WITH SECURITY_ENFORCED Order By CreatedDate DESC LIMIT 1];
        }else{
            documentsList = [SELECT Id,IHM_receipt_number__c,Name,IHM_receipt_date__c,IHM_amount_as_per_receipt__c 
                                FROM Documents__c 
                                WHERE Opportunity_Relation__c =: LoanAppId AND Document_Type__c = 'IHM Receipt' AND is_Active__c = true 
                                WITH SECURITY_ENFORCED Order By CreatedDate DESC LIMIT 1];
        }

        if(documentsList.size() > 0){
            for(Documents__c document : documentsList){
                receiptDtlsObj.receiptno = document.IHM_receipt_number__c == null ? '' : String.valueof(document.IHM_receipt_number__c);
                receiptDtlsObj.receiptdate = document.IHM_receipt_date__c == null ? '' : String.valueof(document.IHM_receipt_date__c);
                receiptDtlsObj.receiptamount = document.IHM_amount_as_per_receipt__c == null ? '0' : String.valueof(document.IHM_amount_as_per_receipt__c);
                receiptDtlsObj.receipttype = 'DEALER';
            }
        }else{
            receiptDtlsObj.receiptno = '';
            receiptDtlsObj.receiptdate = '';
            receiptDtlsObj.receiptamount = '0';
            receiptDtlsObj.receipttype = 'DEALER';
        }

        Map<Id,Decimal> totalAmountInsMap = new Map<Id,Decimal>();
        for(InsuranceDetails__c inusrance : [
            Select id,Funded_Non_funded__c,Amount__c,Loan_Application__c From InsuranceDetails__c Where Loan_Application__c =: LoanAppId AND Funded_Non_funded__c = 'Funded' With SECURITY_ENFORCED
        ] ){
            if(totalAmountInsMap.containsKey(inusrance.Loan_Application__c)){
                totalAmountInsMap.put(inusrance.Loan_Application__c,totalAmountInsMap.get(inusrance.Loan_Application__c) + inusrance.Amount__c);
            }else{
                totalAmountInsMap.put(inusrance.Loan_Application__c,inusrance.Amount__c);
            }
        }

        String blCode = '';
        String txnIDstr = '';
        String stateName = '';
        List<Loan_Agreement__c> loanAgreementList = new List<Loan_Agreement__c>();

        if(oppRec.Product_Type__c == System.Label.Tractor){
            loanAgreementList = [SELECT Id,Geo_State_Code__c 
                                    FROM Loan_Agreement__c 
                                    WHERE Loan_Application__c =: LoanAppId AND Deal_Number__c =: dealId
                                    WITH SECURITY_ENFORCED];
        }else{
            loanAgreementList = [SELECT Id,Geo_State_Code__c 
                                    FROM Loan_Agreement__c 
                                    WHERE Loan_Application__c =: LoanAppId 
                                    WITH SECURITY_ENFORCED];
        }

        List<Geo_State_Masters__c> getStateMaster = new List<Geo_State_Masters__c>();
        if(loanAgreementList.size() > 0){
            stateName = loanAgreementList[0].Geo_State_Code__c;
            getStateMaster = [Select Id,Name,NeSL_State_Code__c,State_Code__c From Geo_State_Masters__c Where Name =: stateName With SECURITY_ENFORCED];
        }
        String neslStateCode = '';
        String stateCode = '';
        if(getStateMaster.size() > 0){
            neslStateCode = getStateMaster[0].NeSL_State_Code__c;
            stateCode = getStateMaster[0].State_Code__c;
        }

        List<Opportunity> oppList = new List<Opportunity>();
        List<Deal_Number__c> dealNumberList = New List<Deal_Number__c>(); 
        if(oppRec.Product_Type__c == System.Label.Tractor){
            List<Vehicle_Detail__c> VehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
            dealNumberList = [SELECT Id, Deal_Number__c  FROM Deal_Number__c WHERE Loan_Application__c =:loanAppId WITH SECURITY_ENFORCED];
            oppList =  [SELECT Id, Agent_BL_code__c, Deal_Number__c, Account.State__c, Required_ROI__c, Sanction_Date__c, Product_Type__c, Account.Name,EMI_Amount__c, 
                        (SELECT Id, Geographical_State__c, Ist_EMI_Due_Date__c, X2nd_EMI_Due_Date__c,Geo_State_Code__c, Agreement_Date__c,AgreementDate__c, Effective_Deal_Date__c, Agreement_Type__c, Add_POA_SD_Initiation_method__c,Agreement_Booklet_Num__c,Total_POA_Stamping__c,Total_Loan_Agreement_Stamping__c FROM Loan_Agreements__r WHERE Deal_Number__c =: dealId),
                        (SELECT Id, Vehicle_Type__c,Finance_Amount__c,Eligible_Loan_Amount__c, Dealer_Sub_dealer_name__c, Vehicle_Registration_number__c, Make__c, Model__c, Variant_Code__c,Variant__c, Ben_Code__c,Ins_Expiry_date__c,Purpose_of_Purchase__c  FROM Vehicle_Details__r WHERE Deal_Number__c =: dealId), 
                        (SELECT id, Name,Applicant_Type__c FROM Applicants__r), 
                        (SELECT Id, Loan_Amount__c, Tenure__c,Holiday_period__c,Advance_EMI__c, EMI_Amount__c,CRM_IRR__c,Agreement_Amount__c,Service_charges__c,Documentation_charges__c,Stamping_charges__c FROM Final_Terms__r WHERE Vehicle_Detail__c =: VehicleLst[0].Id), 
                        (SELECT Id, Tax_Invoice_No__c, Tax_Invoice_Date__c, Engine_No__c, Chassis_No__c,Invoice_Amount_incl_discounts__c FROM Invoice_Details__r WHERE Deal_Number__c =: dealId) 
                        FROM Opportunity WHERE Id = :loanAppId With SECURITY_ENFORCED];
        }else{
            oppList =  [SELECT Id,Agent_BL_code__c, Deal_Number__c, Account.State__c, Required_ROI__c, Sanction_Date__c, Product_Type__c, Account.Name,EMI_Amount__c, 
                        (SELECT Id, Geographical_State__c, Ist_EMI_Due_Date__c, X2nd_EMI_Due_Date__c,Geo_State_Code__c, Agreement_Date__c,AgreementDate__c, Effective_Deal_Date__c, Agreement_Type__c, Add_POA_SD_Initiation_method__c,Agreement_Booklet_Num__c,Total_POA_Stamping__c,Total_Loan_Agreement_Stamping__c FROM Loan_Agreements__r),
                        (SELECT Id, Vehicle_Type__c,Finance_Amount__c,Eligible_Loan_Amount__c, Dealer_Sub_dealer_name__c, Vehicle_Registration_number__c, Make__c, Model__c, Variant_Code__c,Variant__c, Ben_Code__c,Ins_Expiry_date__c,Purpose_of_Purchase__c  FROM Vehicle_Details__r), 
                        (SELECT id, Name,Applicant_Type__c FROM Applicants__r), 
                        (SELECT Id, Loan_Amount__c, Tenure__c,Holiday_period__c,Advance_EMI__c, EMI_Amount__c,CRM_IRR__c,Agreement_Amount__c,Service_charges__c,Documentation_charges__c,Stamping_charges__c FROM Final_Terms__r), 
                        (SELECT Id, Tax_Invoice_No__c, Tax_Invoice_Date__c, Engine_No__c, Chassis_No__c,Invoice_Amount_incl_discounts__c FROM Invoice_Details__r) 
                        FROM Opportunity WHERE Id = :loanAppId With SECURITY_ENFORCED];
        }

        for (Opportunity loanApplication : oppList){
            blCode = loanApplication.Agent_BL_code__c == null ? '' : loanApplication.Agent_BL_code__c;
            if(oppRec.Product_Type__c == System.Label.Tractor){
                loanWrapper.loanno = dealNumberList[0].Deal_Number__c == null ? '' : dealNumberList[0].Deal_Number__c;
                loanWrapper.snctnno = dealNumberList[0].Deal_Number__c == null ? '' : dealNumberList[0].Deal_Number__c;
                txnIDstr= 'CFD' + 'VEH' + 'T' + dealNumberList[0].Deal_Number__c + String.valueOf(Datetime.now().formatGMT('SSSssHHmmyyyyMMdd'));
                loanWrapper.txnID = txnIDstr;

            }else{
                loanWrapper.loanno = loanApplication.Deal_Number__c == null ? '' : loanApplication.Deal_Number__c;
                loanWrapper.snctnno = loanApplication.Deal_Number__c == null ? '' : loanApplication.Deal_Number__c;
                txnIDstr= 'CFD' + 'VEH' + (loanApplication.Product_Type__c.equalsIgnoreCase('Passenger Vehicles') ? 'C' : loanApplication.Product_Type__c.equalsIgnoreCase('Two Wheeler') ? 'H' : '') + loanApplication.Deal_Number__c + String.valueOf(Datetime.now().formatGMT('SSSssHHmmyyyyMMdd'));
                loanWrapper.txnID = txnIDstr;
            }
            loanWrapper.regType = '1';
            loanWrapper.signFlag = '1';
            loanWrapper.loanDocFlag = '';
            loanWrapper.estampFlag = loanApplication.Loan_Agreements__r.size() > 0 ? loanApplication.Loan_Agreements__r[0].Agreement_Type__c == 'e-agreement' ? 'Y' : 'N' : '';
            loanWrapper.f2f = initiationMethod == 'Face to Face' ? 'Y' : 'N';
            loanWrapper.state = neslStateCode;
            loanWrapper.Geo_State_Code = stateCode;
            loanWrapper.Src = 'VEHICLE';
            loanWrapper.Product = (loanApplication.Product_Type__c.equalsIgnoreCase('Passenger Vehicles') ? 'C' : loanApplication.Product_Type__c.equalsIgnoreCase('Two Wheeler') ? 'H' : '');
            loanWrapper.Unit = 'CFD';
            loanWrapper.respURL = System.Label.IndusIndNeSL_Response_URL;
            loanWrapper.Noofpersonsign = (loanApplication.Applicants__r.size() >= 2) ? '2' : '1';
            loanWrapper.Policyno = '';
            loanWrapper.Vehiclecategory = loanApplication.Vehicle_Details__r.size() > 0 ? loanApplication.Vehicle_Details__r[0].Vehicle_Type__c == null ? '' : loanApplication.Vehicle_Details__r[0].Vehicle_Type__c == 'New' ? 'N' : loanApplication.Vehicle_Details__r[0].Vehicle_Type__c == 'Used' ? 'U' : loanApplication.Vehicle_Details__r[0].Vehicle_Type__c == 'Refinance' ? 'R' : '' : '';
            loanWrapper.Telematicsflag = '0';
            loanWrapper.Firstemiduedate = loanApplication.Loan_Agreements__r.size() > 0 ? String.valueof(loanApplication.Loan_Agreements__r[0].Ist_EMI_Due_Date__c) == null ? '' : String.valueof(loanApplication.Loan_Agreements__r[0].Ist_EMI_Due_Date__c) : '';
            loanWrapper.Secondemiduedate = loanApplication.Loan_Agreements__r.size() > 0 ? String.valueof(loanApplication.Loan_Agreements__r[0].X2nd_EMI_Due_Date__c) == null ? '' : String.valueof(loanApplication.Loan_Agreements__r[0].X2nd_EMI_Due_Date__c) : '';
            loanWrapper.Communicationlanguage = 'EN';

            loanWrapper.Branchname = loanApplication.Account.Name;            

            loadDetail.chgamt = '0.00';
            loadDetail.crdtsubtyp = 'Credit Facility';
            loadDetail.currofsanc = 'INR';
            loadDetail.dtofsnctn = String.valueof(loanApplication.Sanction_Date__c) == null ? '' : String.valueof(loanApplication.Sanction_Date__c);
            loadDetail.fcltynm = loanApplication.Product_Type__c.equalsIgnoreCase('Passenger Vehicles') ? 'C' : loanApplication.Product_Type__c.equalsIgnoreCase('Two Wheeler') ? 'H' : '';
            loadDetail.fundtyp = 'Funded';
            loadDetail.isacctclosed = 'No';
            loadDetail.ntrofcrdt = 'Financial';
            loadDetail.rtofint = loanApplication.Required_ROI__c == null ? '' : String.valueof(loanApplication.Required_ROI__c);
            loadDetail.snctnamt = loanApplication.Final_Terms__r.size() > 0 ? loanApplication.Final_Terms__r[0].Loan_Amount__c == null ? '' : loanApplication.Final_Terms__r[0].Loan_Amount__c : '';
            loadDetail.tenure = loanApplication.Final_Terms__r.size() > 0 ? loanApplication.Final_Terms__r[0].Tenure__c == null ? '' : loanApplication.Final_Terms__r[0].Tenure__c : '';
            loadDetail.toutstndamt = loanApplication.Vehicle_Details__r.size() > 0 ? String.valueof(loanApplication.Vehicle_Details__r[0].Finance_Amount__c) == null ? '0' : String.valueof(loanApplication.Vehicle_Details__r[0].Finance_Amount__c) : '';
            loadDetail.Emiamt = loanApplication.Final_Terms__r.size() > 0 ? String.valueof(loanApplication.Final_Terms__r[0].EMI_Amount__c) == null ? '' : String.valueof(loanApplication.Final_Terms__r[0].EMI_Amount__c) : '';

            DocumentDtls documentDtl = new DocumentDtls();
            documentDtl.docData = '';
            documentDtl.documentID = 1;
            documentDtl.documentDesc = 'CVLoan_agr';
            documentDtlList.add(documentDtl);

            ESignCordinate eSignCordinate1 = new ESignCordinate();
            eSignCordinate1.prtcptenttyId = 1;
            eSignCordinate1.documentID = 1;
            eSignCordinate1.Coordinates = coordinatesList;
            eSignCordinateList.add(eSignCordinate1);

            assetParticulars.Agmntdate = loanApplication.Loan_Agreements__r.size() > 0 ? String.valueof(loanApplication.Loan_Agreements__r[0].AgreementDate__c) == null ? '' : String.valueof(loanApplication.Loan_Agreements__r[0].AgreementDate__c) : '';
            assetParticulars.Effectivedate = loanApplication.Loan_Agreements__r.size() > 0 ? String.valueof(loanApplication.Loan_Agreements__r[0].Effective_Deal_Date__c) == null ? '' : String.valueof(loanApplication.Loan_Agreements__r[0].Effective_Deal_Date__c) : '';
            assetParticulars.Assetdesc = loanApplication.Vehicle_Details__r.size() > 0 ? String.valueof(loanApplication.Vehicle_Details__r[0].Variant__c) == null ? '' : String.valueof(loanApplication.Vehicle_Details__r[0].Variant__c) : '';
            assetParticulars.Invoiceno = loanApplication.Invoice_Details__r.size() > 0 ? String.valueof(loanApplication.Invoice_Details__r[0].Tax_Invoice_No__c) == null ? '' :  String.valueof(loanApplication.Invoice_Details__r[0].Tax_Invoice_No__c) : '';
            assetParticulars.Invoicedate = loanApplication.Invoice_Details__r.size() > 0 ? String.valueof(loanApplication.Invoice_Details__r[0].Tax_Invoice_Date__c) == null ? '' : String.valueof(loanApplication.Invoice_Details__r[0].Tax_Invoice_Date__c) : '';

            benifCode = loanApplication.Vehicle_Details__r.size() > 0 ? String.valueof(loanApplication.Vehicle_Details__r[0].Ben_Code__c) == null ? '' : String.valueof(loanApplication.Vehicle_Details__r[0].Ben_Code__c) : '';

            assetParticulars.Vehinvbydesc = loanApplication.Vehicle_Details__r.size() > 0 ? String.valueof(loanApplication.Vehicle_Details__r[0].Dealer_Sub_dealer_name__c) == null ? '' : String.valueof(loanApplication.Vehicle_Details__r[0].Dealer_Sub_dealer_name__c) : '';
            assetParticulars.Engineno = loanApplication.Invoice_Details__r.size() > 0 ? String.valueof(loanApplication.Invoice_Details__r[0].Engine_No__c) == null ? '' : String.valueof(loanApplication.Invoice_Details__r[0].Engine_No__c) : '';
            assetParticulars.Chassisno = loanApplication.Invoice_Details__r.size() > 0 ? String.valueof(loanApplication.Invoice_Details__r[0].Chassis_No__c) == null ? '' : String.valueof(loanApplication.Invoice_Details__r[0].Chassis_No__c) : '';
            assetParticulars.Regnno = loanApplication.Vehicle_Details__r.size() > 0 ? String.valueof(loanApplication.Vehicle_Details__r[0].Vehicle_Registration_number__c) == null ? '' : String.valueof(loanApplication.Vehicle_Details__r[0].Vehicle_Registration_number__c) : '';
            assetParticulars.Make = loanApplication.Vehicle_Details__r.size() > 0 ? String.valueof(loanApplication.Vehicle_Details__r[0].Make__c) == null ? '' : String.valueof(loanApplication.Vehicle_Details__r[0].Make__c) : '';
            assetParticulars.Model = loanApplication.Vehicle_Details__r.size() > 0 ? String.valueof(loanApplication.Vehicle_Details__r[0].Model__c) == null ? '' : String.valueof(loanApplication.Vehicle_Details__r[0].Model__c) : '';
            assetParticulars.Bodybuildername = '';
            assetParticulars.Mnthyrofmfg = '';
            assetParticulars.Donumber = '';
            assetParticulars.Dodate = '';
            assetParticulars.Collateralsecurity = '';
            assetParticulars.Insurancevalidupto = loanApplication.Vehicle_Details__r.size() > 0 ? String.valueof(loanApplication.Vehicle_Details__r[0].Ins_Expiry_date__c) == null ? '' : String.valueof(loanApplication.Vehicle_Details__r[0].Ins_Expiry_date__c) : '';
            assetParticulars.Rtataxremittedupto = '';
            assetParticulars.Permitvalidupto = '';
            assetParticulars.Purposeloan = loanApplication.Vehicle_Details__r.size() > 0 ? String.valueof(loanApplication.Vehicle_Details__r[0].Purpose_of_Purchase__c) == null ? '' : String.valueof(loanApplication.Vehicle_Details__r[0].Purpose_of_Purchase__c) : '';

            financeDtls.Period = loanApplication.Final_Terms__r.size() > 0 ? loanApplication.Final_Terms__r[0].Tenure__c == null ? '' : loanApplication.Final_Terms__r[0].Tenure__c  : '';
            financeDtls.Moratorium = loanApplication.Final_Terms__r.size() > 0 ? String.valueof(loanApplication.Final_Terms__r[0].Holiday_period__c) == null ? '' : String.valueof(loanApplication.Final_Terms__r[0].Holiday_period__c): '';
            financeDtls.noadveMI = loanApplication.Final_Terms__r.size() > 0 ? String.valueof(loanApplication.Final_Terms__r[0].Advance_EMI__c) == null ? '' : String.valueof(loanApplication.Final_Terms__r[0].Advance_EMI__c) : '';
            financeDtls.Instfrequency = 'M';
            financeDtls.mclrloadedtenorprm = '07.5%';
            
            Double invoiceAmount = loanApplication.Invoice_Details__r.size() > 0 ? loanApplication.Invoice_Details__r[0].Invoice_Amount_incl_discounts__c == null ? 0 : loanApplication.Invoice_Details__r[0].Invoice_Amount_incl_discounts__c: 0;
            Double financeAmount = loanApplication.Vehicle_Details__r.size() > 0 ? loanApplication.Vehicle_Details__r[0].Finance_Amount__c == null ? 0 : loanApplication.Vehicle_Details__r[0].Finance_Amount__c : 0;
            Double margin = invoiceAmount - financeAmount;
            
            financeDtls.Margin = String.valueof(margin);
            financeDtls.Interestrate = loanApplication.Final_Terms__r.size() > 0 ? String.valueof(loanApplication.Final_Terms__r[0].CRM_IRR__c) == null ? '' : String.valueof(loanApplication.Final_Terms__r[0].CRM_IRR__c) : '';
            financeDtls.Costofchassis = loanApplication.Invoice_Details__r.size() > 0 ? String.valueof(loanApplication.Invoice_Details__r[0].Invoice_Amount_incl_discounts__c) == null ? '0' : String.valueof(loanApplication.Invoice_Details__r[0].Invoice_Amount_incl_discounts__c) : '0';
            financeDtls.Costofbody = '0.00';

            Double finalTermAmount = loanApplication.Final_Terms__r.size() > 0 ? loanApplication.Final_Terms__r[0].Loan_Amount__c == null ? 0 : Integer.valueof(loanApplication.Final_Terms__r[0].Loan_Amount__c) : 0;
            margin = invoiceAmount - finalTermAmount;
            financeDtls.Chassismargincost = String.valueOf(margin);
            
            Double agreementAmount = loanApplication.Final_Terms__r.size() > 0 ? loanApplication.Final_Terms__r[0].Agreement_Amount__c == null ? 0 : loanApplication.Final_Terms__r[0].Agreement_Amount__c : 0;

            financeDtls.Bodymargincost = '0.00';
            financeDtls.loanamtonchassis = loanApplication.Vehicle_Details__r.size() > 0 ? loanApplication.Vehicle_Details__r[0].Eligible_Loan_Amount__c == null ? '' : String.valueOf(loanApplication.Vehicle_Details__r[0].Eligible_Loan_Amount__c)  : '';
            financeDtls.loanamtonbody = '';
            financeDtls.loanamtaddfunding = String.valueOf(totalAmountInsMap.get(LoanAppId)) == null ? '' : String.valueOf(totalAmountInsMap.get(LoanAppId));
            financeDtls.Intcharges = String.valueof(agreementAmount - finalTermAmount);
            financeDtls.Agrmtvalue = loanApplication.Final_Terms__r.size() > 0 ? String.valueof(loanApplication.Final_Terms__r[0].Agreement_Amount__c) == null ? '' : String.valueof(loanApplication.Final_Terms__r[0].Agreement_Amount__c) : '';
            
            otherCharges.Processingch = loanApplication.Final_Terms__r.size() > 0 ? String.valueof(loanApplication.Final_Terms__r[0].Service_charges__c) == null ? '' : String.valueof(loanApplication.Final_Terms__r[0].Service_charges__c) : '';
            otherCharges.Docmntch = loanApplication.Final_Terms__r.size() > 0 ? String.valueof(loanApplication.Final_Terms__r[0].Documentation_charges__c) == null ? '' : String.valueof(loanApplication.Final_Terms__r[0].Documentation_charges__c) : '';
            otherCharges.Stampingch = loanApplication.Final_Terms__r.size() > 0 ? String.valueof(loanApplication.Final_Terms__r[0].Stamping_charges__c) == null ? '' : String.valueof(loanApplication.Final_Terms__r[0].Stamping_charges__c) : '';

            objStamping.txnID = txnIDstr;
            objStamping.No_Of_Signer = (loanApplication.Applicants__r.size() >= 2) ? '2' : '1';
            objStamping.Stamp_Duty_Purcased_By = 'B';
            if(oppRec.Product_Type__c == System.Label.Tractor){
                objStamping.Deal_No = dealNumberList[0].Deal_Number__c == null ? '' : dealNumberList[0].Deal_Number__c;
            }else{
                objStamping.Deal_No = loanApplication.Deal_Number__c;
            }
            objStamping.Agreement_Booklet_No = loanApplication.Loan_Agreements__r.size() > 0 ? loanApplication.Loan_Agreements__r[0].Agreement_Booklet_Num__c == null ? '' : loanApplication.Loan_Agreements__r[0].Agreement_Booklet_Num__c : '';
            objStamping.Stamping_Type = loanApplication.Loan_Agreements__r.size() > 0 ? loanApplication.Loan_Agreements__r[0].Agreement_Type__c == 'e-agreement' ? 'Nesl' : 'MAN' : '';            
            objStamping.Total_Stamping_Amount = loanApplication.Loan_Agreements__r.size() > 0 ? String.valueof(loanApplication.Loan_Agreements__r[0].Total_Loan_Agreement_Stamping__c) == null ? '' : String.valueof(loanApplication.Loan_Agreements__r[0].Total_Loan_Agreement_Stamping__c) : '';
            objStamping.Total_Stamping_Amount_As_Per_Master = '300.00'; //For testing purpose

            objStamping.InitMethod = initiationMethod == 'Face to Face' ? 'Y' : 'N';           
            objStamping.Tentative_Deal_Date = String.valueof(Date.today());
            objStamping.Due_Date_Pattern = '';
            objStamping.First_EMI_Due_Date =  loanApplication.Loan_Agreements__r.size() > 0 ? String.valueof(loanApplication.Loan_Agreements__r[0].Ist_EMI_Due_Date__c) == null ? '' : String.valueof(loanApplication.Loan_Agreements__r[0].Ist_EMI_Due_Date__c) : '';
            objStamping.Second_EMI_Due_Date =  loanApplication.Loan_Agreements__r.size() > 0 ? String.valueof(loanApplication.Loan_Agreements__r[0].X2nd_EMI_Due_Date__c) == null ? '' : String.valueof(loanApplication.Loan_Agreements__r[0].X2nd_EMI_Due_Date__c) : '';
            objStamping.Deal_Date_Basis = '';
            objStamping.InvoiceDO_Date = '';
            objStamping.Agreement_Sign_Date = String.valueof(Date.today());
            objStamping.Effective_Deal_Date =  loanApplication.Loan_Agreements__r.size() > 0 ? String.valueof(loanApplication.Loan_Agreements__r[0].Effective_Deal_Date__c) == null ? '' : String.valueof(loanApplication.Loan_Agreements__r[0].Effective_Deal_Date__c) : '';
            objStamping.Maker_Id =  makeId;

        }

        for(SOC_Master__c socMaster : [Select Id,From_Date__c,	Asset_val_charges__c,	Cersairgnch__c,	Cibil_charges__c,	Closure_bank_acc_charges__c,Colln_chrg_chq_rtn__c,	Collnchrgcash__c,	Collnchrgpdcs__c,	Compensation_charges__c,	Due_date_charges__c,	Dupnocch__c,	Fore_closure_charges__c,	Legal_repo_charges__c,	Loancc__c,	Nesl_registration_charges__c,	Nesl_renewal_charges__c,	Nocusageconv__c,	Other_charges__c,	Over_due_int_mon__c,	Pre_closure_charges__c,	Repay_dc__c,	Repay_dishonr_charges__c,	Roc_consult_fee__c,	Roc_filing_charges__c,	Rto_registration_charges__c,	Sms_tc_charges__c,	Statement_charges__c,	Swap_charges__c,	Tradecertch__c,	Travelcc__c,Vehicle_reg_hypothecation_verification__c From SOC_Master__c Where From_Date__c <=: date.today() WITH SECURITY_ENFORCED Order By From_Date__c ASC LIMIT 1]){
                otherCharges.vehrgnhypch = socMaster.Vehicle_reg_hypothecation_verification__c == null ? '' : socMaster.Vehicle_reg_hypothecation_verification__c;
                otherCharges.rtorgnch = socMaster.Rto_registration_charges__c == null ? '' : socMaster.Rto_registration_charges__c;
                otherCharges.rocfilingch = socMaster.Roc_filing_charges__c == null ? '' : socMaster.Roc_filing_charges__c;
                otherCharges.cersairgnch = socMaster.Cersairgnch__c == null ? '' : socMaster.Cersairgnch__c;
                otherCharges.neslregnch = socMaster.Nesl_registration_charges__c == null ? '' : socMaster.Nesl_registration_charges__c;
                otherCharges.neslrenewch = socMaster.Nesl_renewal_charges__c == null ? '' : socMaster.Nesl_renewal_charges__c;
                otherCharges.rocconsultfee = socMaster.Roc_consult_fee__c == null ? '' : socMaster.Roc_consult_fee__c;
                otherCharges.cibilch = socMaster.Cibil_charges__c == null ? '' : socMaster.Cibil_charges__c;
                otherCharges.assetvalch = socMaster.Asset_val_charges__c == null ? '' : socMaster.Asset_val_charges__c;
                otherCharges.repaydc = socMaster.Repay_dc__c == null ? '' : socMaster.Repay_dc__c;
                otherCharges.repaydishonch = socMaster.Repay_dishonr_charges__c == null ? '' : socMaster.Repay_dishonr_charges__c;
                otherCharges.closurebankaccch = socMaster.Closure_bank_acc_charges__c == null ? '' : socMaster.Closure_bank_acc_charges__c;
                otherCharges.swapch = socMaster.Swap_charges__c == null ? '' : socMaster.Swap_charges__c;
                otherCharges.collnchrgchqrtn = socMaster.Colln_chrg_chq_rtn__c == null ? '' : socMaster.Colln_chrg_chq_rtn__c;
                otherCharges.collnchrgcash = socMaster.Collnchrgcash__c == null ? '' : socMaster.Collnchrgcash__c;
                otherCharges.collnchrgpdcs = socMaster.Collnchrgpdcs__c == null ? '' : socMaster.Collnchrgpdcs__c;  
                otherCharges.travelcc = socMaster.Travelcc__c == null ? '' : socMaster.Travelcc__c;
                otherCharges.smstcch = socMaster.Sms_tc_charges__c == null ? '' : socMaster.Sms_tc_charges__c;
                otherCharges.preclosurech = socMaster.Pre_closure_charges__c == null ? '' : socMaster.Pre_closure_charges__c;     
                otherCharges.overdueintmon = socMaster.Over_due_int_mon__c == null ? '' : socMaster.Over_due_int_mon__c; 
                otherCharges.statementch = socMaster.Statement_charges__c == null ? '' : socMaster.Statement_charges__c;
                otherCharges.dupnocch = socMaster.Dupnocch__c == null ? '' : socMaster.Dupnocch__c;
                otherCharges.loancc = socMaster.Loancc__c == null ? '' : socMaster.Loancc__c;
                otherCharges.foreclosurech  = socMaster.Fore_closure_charges__c == null ? '' : socMaster.Fore_closure_charges__c;
                otherCharges.nocusageconv = socMaster.Nocusageconv__c == null ? '' : socMaster.Nocusageconv__c;
                otherCharges.legalrepoch = socMaster.Legal_repo_charges__c == null ? '' : socMaster.Legal_repo_charges__c;
                otherCharges.compensationch = socMaster.Compensation_charges__c == null ? '' : socMaster.Compensation_charges__c;
                otherCharges.tradecertch = socMaster.Tradecertch__c == null ? '' : socMaster.Tradecertch__c;
                otherCharges.duedatech = socMaster.Due_date_charges__c == null ? '' : socMaster.Due_date_charges__c;
                otherCharges.otherch = socMaster.Other_charges__c == null ? '' : socMaster.Other_charges__c;
        }

        Map<Id,Structered_EMI__c> structedMap = new Map<Id,Structered_EMI__c>();

        List<Structered_EMI__c> structeredEmiList = new List<Structered_EMI__c>();
        List<Final_Term__c> finalTermList = new List<Final_Term__c>();

        if(oppRec.Product_Type__c == System.Label.Tractor){
            List<Vehicle_Detail__c> VehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
            structeredEmiList = [SELECT Id,From_Month__c,To_Month__c,Number_of_Installments__c,EMI_Amount__c,Loan_Application__c 
                                    FROM Structered_EMI__c 
                                    WHERE Loan_Application__c =: loanAppId AND Deal_Number__c =: dealId
                                    WITH SECURITY_ENFORCED LIMIT 1];
            finalTermList = [SELECT Id,Installment_Type__c,EMI_Amount__c,Loan_Application__r.EMI_Amount__c,Tenure__c,Loan_amount__c,Loan_Application__c 
                                FROM Final_Term__c 
                                WHERE Loan_Application__c =:  loanAppId AND Vehicle_Detail__c =: VehicleLst[0].Id
                                WITH SECURITY_ENFORCED LIMIT 1];
        }else{
            structeredEmiList = [SELECT Id,From_Month__c,To_Month__c,Number_of_Installments__c,EMI_Amount__c,Loan_Application__c 
                                    FROM Structered_EMI__c 
                                    WHERE Loan_Application__c =: loanAppId 
                                    WITH SECURITY_ENFORCED LIMIT 1];
            finalTermList = [SELECT Id,Installment_Type__c,EMI_Amount__c,Loan_Application__r.EMI_Amount__c,Tenure__c,Loan_amount__c,Loan_Application__c 
                                FROM Final_Term__c 
                                WHERE Loan_Application__c =:  loanAppId 
                                WITH SECURITY_ENFORCED LIMIT 1];
        }
        
        for(Structered_EMI__c structeredEmi : structeredEmiList){
            structedMap.put(structeredEmi.Loan_Application__c, structeredEmi);
        }
        
        if(finalTermList.size() > 0){
            for(Final_Term__c finalTerm : finalTermList){
                PaymentInstallment paymentInstallment = new PaymentInstallment();
                if(finalTerm.Installment_Type__c == 'Equated'){
                    paymentInstallment.fromno = String.valueof(1);
                    paymentInstallment.tono = finalTerm.Tenure__c == null ? '' : finalTerm.Tenure__c;
                    paymentInstallment.Emi = finalTerm.EMI_Amount__c == null ? '' : String.valueof(finalTerm.EMI_Amount__c);
                }else if(finalTerm.Installment_Type__c == 'Structured'){
                    if(structedMap.containsKey(finalTerm.Loan_Application__c)){
                        paymentInstallment.fromno = structedMap.get(finalTerm.Loan_Application__c).From_Month__c == null ? '' : String.valueof(structedMap.get(finalTerm.Loan_Application__c).From_Month__c);
                        paymentInstallment.tono = structedMap.get(finalTerm.Loan_Application__c).To_Month__c == null ? '' : String.valueof(structedMap.get(finalTerm.Loan_Application__c).To_Month__c);
                        paymentInstallment.Emi = structedMap.get(finalTerm.Loan_Application__c).EMI_Amount__c == null ? '' : String.valueof(structedMap.get(finalTerm.Loan_Application__c).EMI_Amount__c);
                    }else{
                        paymentInstallment.fromno = '';
                        paymentInstallment.tono = '';
                        paymentInstallment.Emi = '';
                    }
                }else{
                    paymentInstallment.fromno = '';
                    paymentInstallment.tono = '';
                    paymentInstallment.emi = '';
                }
                paymentInstallmentList.add(paymentInstallment);
            }
        }else{
            PaymentInstallment paymentInstallment = new PaymentInstallment();
            paymentInstallment.fromno = '';
            paymentInstallment.tono = '';
            paymentInstallment.emi = '';
            paymentInstallmentList.add(paymentInstallment);
        }
        

        List<ObjSD> objSDsList = new List<ObjSD>();
        List<Stamp_Detail__c> stamplist = [
            Select Id,Stamp_S_No__c,Stamp_Type__c,Stamp_Value__c,Stamp_For__c,Stamp_Date__c,Stamp_Printed_Location_Blcode__c From Stamp_Detail__c Where Loan_Agreement__r.Loan_Application__c =: loanAppId With SECURITY_ENFORCED 
        ];
        if(stamplist.size()>0){
        for(Stamp_Detail__c stamDetails :stamplist){
            ObjSD objSD = new ObjSD();
            objSD.Stamp_On = stamDetails.Stamp_Date__c == null ? String.valueof(Date.today()) : String.valueof(stamDetails.Stamp_Date__c);
            objSD.Stamp_Printed_Location_Blcode = stamDetails.Stamp_Printed_Location_Blcode__c == null ? '' : stamDetails.Stamp_Printed_Location_Blcode__c;
            objSD.Stamp_S_No = stamDetails.Stamp_S_No__c == null ? '': stamDetails.Stamp_S_No__c;
            objSD.Stamp_Type = stamDetails.Stamp_Type__c == null ? '' : stamDetails.Stamp_Type__c;
            objSD.Stamp_Value = stamDetails.Stamp_Value__c == null ? '0' : String.valueof(stamDetails.Stamp_Value__c);
            objSD.Stamped_For = stamDetails.Stamp_For__c == null ? '' : stamDetails.Stamp_For__c;
            objSDsList.add(objSD);
        }}
        else{
            ObjSD objSD = new ObjSD();
            objSD.Stamp_On = String.valueOf(Date.Today());
            objSD.Stamp_Printed_Location_Blcode = '';
            objSD.Stamp_S_No = '0';
            objSD.Stamp_Type = '';
            objSD.Stamp_Value = '0';
            objSD.Stamped_For = '';
            objSDsList.add(objSD);
        }

        if (benifCode != ''){
            for (Benefi__c benefi : [Select id, Dealership_Nature__c, Name
                                     From Benefi__c
                                     Where Ben_Code__c = :benifCode
                                     With SECURITY_ENFORCED
                                     Limit 1]){
                assetParticulars.Vehinvby = benefi.Dealership_Nature__c;
            }
        }else{
            assetParticulars.Vehinvby = '';
        }

        List<EStampDetail> eStampDetailsList = new List<EStampDetail>();
        List<PrtcptEntty> prtcptEnttyList = new List<PrtcptEntty>();

        List<Loan_Agreement__c> loanAgrmtList = new List<Loan_Agreement__c>();

        if(oppRec.Product_Type__c == System.Label.Tractor){
            loanAgrmtList  = [SELECT Id, Total_POA_Stamping__c, Loan_Application__r.Product_Type__c, Loan_Application__r.Applicant_Name__c,Loan_Application__r.Total_Funded_Premium__c 
                                FROM Loan_Agreement__c 
                                WHERE Loan_Application__c = :loanAppId AND Deal_Number__c =: dealId
                                WITH SECURITY_ENFORCED];
        }else{
            loanAgrmtList  = [SELECT Id, Total_POA_Stamping__c, Loan_Application__r.Product_Type__c, Loan_Application__r.Applicant_Name__c,Loan_Application__r.Total_Funded_Premium__c 
                                FROM Loan_Agreement__c 
                                WHERE Loan_Application__c = :loanAppId 
                                WITH SECURITY_ENFORCED];
        }

        for (Loan_Agreement__c loanAgreement : loanAgrmtList){
            EStampDetail eStampDetail = new EStampDetail();
            eStampDetail.Firstparty = 'INDUSIND BANK';
            eStampDetail.considerationPrice = String.valueof(!finalTermList.isEmpty() ? Decimal.valueOf(finalTermList[0].Loan_amount__c) + loanAgreement.Loan_Application__r.Total_Funded_Premium__c : loanAgreement.Loan_Application__r.Total_Funded_Premium__c);
            eStampDetail.stampDutyAmount = String.valueof(!finalTermList.isEmpty() ? Decimal.valueOf(finalTermList[0].Loan_amount__c) + loanAgreement.Loan_Application__r.Total_Funded_Premium__c : loanAgreement.Loan_Application__r.Total_Funded_Premium__c);
            eStampDetail.stampdutyPaidby = 'INDUSIND BANK';
            eStampDetail.Secondparty = app.Name == null ? '' : app.Name;
            eStampDetail.documentID = '1';
            eStampDetail.descriptionofDocument = loanAgreement.Loan_Application__r.Product_Type__c == null ? '' : loanAgreement.Loan_Application__r.Product_Type__c;
            eStampDetail.StampedFor = 'CVLoan_agr';
            eStampDetail.articleCode = '';
            eStampDetailsList.add(eStampDetail);
        }

        String docKycRecordTypeId = Schema.getGlobalDescribe().get('Documents__c').getDescribe().getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
        
        Map<String,Map<String,Documents__c>> documentMapAccApplicant = new Map<String,Map<String,Documents__c>>();

        List<Documents__c> doccList = new List<Documents__c>();
        if(oppRec.Product_Type__c == System.Label.Tractor){
            List<Vehicle_Detail__c> VehicleLst = [SELECT Id FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
            doccList = [SELECT Id,Applicant__r.Applicant_Type__c, KYC_State__c,KYC_Address_Line_2__c,KYC_Address_Line_1__c, KYC_No__c, Passport_No__c, Address_line_CR_1__c, Address_line_1_PR__c, Address_line_CR_2__c, Address_line_2_PR__c,KYC_Pin_Code__c,Document_Type__c, KYC_DOB__c,PAN_No__c 
                            FROM Documents__c 
                            WHERE RecordTypeId =: docKycRecordTypeId AND Opportunity_Relation__c =: loanAppId AND Vehicle_Detail__c =: VehicleLst[0].Id
                            WITH Security_Enforced];
        }else{
            doccList = [SELECT Id,Applicant__r.Applicant_Type__c, KYC_State__c,KYC_Address_Line_2__c,KYC_Address_Line_1__c, KYC_No__c, Passport_No__c, Address_line_CR_1__c, Address_line_1_PR__c, Address_line_CR_2__c, Address_line_2_PR__c,KYC_Pin_Code__c,Document_Type__c, KYC_DOB__c,PAN_No__c 
                            FROM Documents__c 
                            WHERE RecordTypeId =: docKycRecordTypeId AND Opportunity_Relation__c =: loanAppId 
                            WITH Security_Enforced];
        }

        for(Documents__c document : doccList){
            if(documentMapAccApplicant.containskey(document.Applicant__r.Applicant_Type__c)){
                Map<String,Documents__c> documentMapTemp = documentMapAccApplicant.get(document.Applicant__r.Applicant_Type__c);
                documentMapTemp.put(document.Document_Type__c,document);
                documentMapAccApplicant.put(document.Applicant__r.Applicant_Type__c,documentMapTemp);
            }else{
                Map<String,Documents__c> documentMapTemp = new Map<String,Documents__c>();
                documentMapTemp.put(document.Document_Type__c,document);
                documentMapAccApplicant.put(document.Applicant__r.Applicant_Type__c,documentMapTemp);
            }
        }

        for (Applicant__c applicant : [Select id, Opportunity__r.Product_Type__c,Contact_Number__c, Applicant_Type__c, Email_Id_2__c,Email_Id_1__c, Email_Id__c, Name, Opportunity__r.Account.Phone, Father_s_name__c, (Select Id, KYC_State__c, KYC_No__c, Passport_No__c, Address_line_CR_1__c, Address_line_1_PR__c, Address_line_CR_2__c, Address_line_2_PR__c,KYC_Pin_Code__c,Document_Type__c, KYC_DOB__c From Documents__r Where RecordTypeId =: docKycRecordTypeId), (Select Id, Office_Address_Line_1__c, Office_Address_Line_2__c, Office_State__c, Email_Id_1__c, Office_PinCode__c From Income_Details__r) From Applicant__c Where Opportunity__c = :LoanAppId AND In_Active_Applicant__c = false With SECURITY_ENFORCED]){
            Map<String,Documents__c> documentMap = documentMapAccApplicant.get(applicant.Applicant_Type__c);
            PrtcptEntty prtcptEntty = new PrtcptEntty();
            prtcptEntty.prtcptenttyId = applicant.Applicant_Type__c == System.Label.Borrower ? 1 : 2;
            prtcptEntty.Altemlid = applicant.Email_Id_1__c == null ? '' : applicant.Email_Id_1__c;
            prtcptEntty.Altmobno = '';
            
			String commAddress = '';
            
            if(documentMap.containsKey('36')){
                commAddress = documentMap.get('36').KYC_Address_Line_1__c == null ? '' : documentMap.get('36').KYC_Address_Line_1__c + ' ' + documentMap.get('36').KYC_Address_Line_2__c == null ? '' : documentMap.get('36').KYC_Address_Line_2__c;
            }else if(documentMap.containsKey('Passport')){
                commAddress = documentMap.get('Passport').KYC_Address_Line_1__c == null ? '' : documentMap.get('Passport').KYC_Address_Line_1__c + ' ' + documentMap.get('Passport').KYC_Address_Line_2__c == null ? '' : documentMap.get('Passport').KYC_Address_Line_2__c;
            }else if(documentMap.containsKey('PAN')){
                commAddress = documentMap.get('PAN').KYC_Address_Line_1__c == null ? '' : documentMap.get('PAN').KYC_Address_Line_1__c + ' ' + documentMap.get('PAN').KYC_Address_Line_2__c == null ? '' : documentMap.get('PAN').KYC_Address_Line_2__c;
            }
            
            prtcptEntty.Cntrprtyaddr = commAddress;
            prtcptEntty.Cntrprtycntmobno = applicant.Contact_Number__c == null ? '' : applicant.Contact_Number__c;
            prtcptEntty.Cntrprtycntnm = applicant.Name == null ? '' : applicant.Name;
            prtcptEntty.Fatherhusbandname = applicant.Father_s_name__c == null ? '' : applicant.Father_s_name__c;
            prtcptEntty.Authsignatoryname = '';
            prtcptEntty.Designationsignatory = '';
            
            String stateStr = '';
            
            if(documentMap.containsKey('36')){
                stateStr = documentMap.get('36').KYC_State__c;
            }else if(documentMap.containsKey('Passport')){
                stateStr = documentMap.get('Passport').KYC_State__c;
            }else if(documentMap.containsKey('PAN')){
                stateStr = documentMap.get('PAN').KYC_State__c;
            }
            
            prtcptEntty.Resistate = stateStr;
            prtcptEntty.Offaddr = applicant.Income_Details__r.size() > 0 ? (applicant.Income_Details__r[0].Office_Address_Line_1__c == null ? '' : applicant.Income_Details__r[0].Office_Address_Line_1__c + ' ' + applicant.Income_Details__r[0].Office_Address_Line_2__c == null ? '' : applicant.Income_Details__r[0].Office_Address_Line_2__c) : '';
            prtcptEntty.Offphone = '';
            prtcptEntty.offpin = '';
            prtcptEntty.Offstate = applicant.Income_Details__r.size() > 0 ? applicant.Income_Details__r[0].Office_State__c == null ? '' : applicant.Income_Details__r[0].Office_State__c : '';
            prtcptEntty.Offemail = applicant.Income_Details__r.size() > 0 ? applicant.Income_Details__r[0].Email_Id_1__c == null ? '' : applicant.Income_Details__r[0].Email_Id_1__c : '';
            if(documentMap.containsKey('Voter Id')){
              prtcptEntty.Voterid = documentMap.get('Voter Id').KYC_No__c == null ? '' : documentMap.get('Voter Id').KYC_No__c;
            }else{
                prtcptEntty.Voterid = '';
            }
            if(documentMap.containsKey('Passport')){
              prtcptEntty.Passport = documentMap.get('Passport').KYC_No__c == null ? '' : documentMap.get('Passport').KYC_No__c;
            }else{
                prtcptEntty.Passport = '';
            }
            if(documentMap.containsKey('Driving License')){
				prtcptEntty.Drivinglicense = documentMap.get('Driving License').KYC_No__c == null ? '' : documentMap.get('Driving License').KYC_No__c;
            }else{
                prtcptEntty.Drivinglicense = '';
            }
            if(documentMap.containsKey('36')){
				prtcptEntty.Aadhaar = documentMap.get('36').KYC_No__c == null ? '' : documentMap.get('36').KYC_No__c;
            }else{
                prtcptEntty.Aadhaar = '';
            }
            prtcptEntty.Din = '';
            prtcptEntty.Virtualid = '';
            prtcptEntty.Ckycid = '';
            prtcptEntty.Cin = '';
            prtcptEntty.Gstno = '';
            prtcptEntty.Udyogaadhaarno = '';
            prtcptEntty.Udyam = '';
            prtcptEntty.Constitution = applicant.Applicant_Type__c;
            
            prtcptEntty.Comaddr = commAddress;
            if(documentMap.containskey('36')){
                prtcptEntty.Doi = documentMap.get('36').KYC_DOB__c == null ? '' : String.valueof(documentMap.get('36').KYC_DOB__c);
                prtcptEntty.Pin = documentMap.get('36').KYC_Pin_Code__c == null ? '' : documentMap.get('36').KYC_Pin_Code__c;
                prtcptEntty.Regoffpin = documentMap.get('36').KYC_Pin_Code__c == null ? '' : documentMap.get('36').KYC_Pin_Code__c;
            }else if(documentMap.containskey('PAN')){
                prtcptEntty.Doi = documentMap.get('PAN').KYC_DOB__c == null ? '' : String.valueof(documentMap.get('PAN').KYC_DOB__c);
                prtcptEntty.Pin = documentMap.get('PAN').KYC_Pin_Code__c == null ? '' : documentMap.get('PAN').KYC_Pin_Code__c;
                prtcptEntty.Regoffpin = documentMap.get('PAN').KYC_Pin_Code__c == null ? '' : documentMap.get('PAN').KYC_Pin_Code__c;
            }else{
                prtcptEntty.Doi = '';
                prtcptEntty.Pin = '';
                prtcptEntty.Regoffpin = '';
            }
           // prtcptEntty.Emlid = applicant.Email_Id__c == null ? '' : applicant.Email_Id__c;
            prtcptEntty.Emlid = 'payments@indusind.com';
            prtcptEntty.Fulnm = applicant.Name == null ? '' : applicant.Name;
            prtcptEntty.Partytyp = 'Indian Entity';
            // prtcptEntty.Regoffpin = applicant.Income_Details__r.size() > 0 ? applicant.Income_Details__r[0].Office_PinCode__c == null ? '' : applicant.Income_Details__r[0].Office_PinCode__c : '';
            prtcptEntty.Reltocntrct = applicant.Applicant_Type__c == System.Label.Borrower ? 'Debtor' : 'Co-obligant';
            if(!documentMap.containskey('PAN')){
                if(documentMap.containskey('Voter Id')){
                    prtcptEntty.Ovdtype = documentMap.get('Voter Id').Document_Type__c == null ? '' : documentMap.get('Voter Id').Document_Type__c;
                    prtcptEntty.Ovdid = documentMap.get('Voter Id').KYC_No__c == null ? '' : documentMap.get('Voter Id').KYC_No__c;
                }else if(documentMap.containskey('Passport')){
                    prtcptEntty.Ovdtype = documentMap.get('Passport').Document_Type__c == null ? '' : documentMap.get('Passport').Document_Type__c;
                    prtcptEntty.Ovdid = documentMap.get('Passport').KYC_No__c == null ? '' : documentMap.get('Passport').KYC_No__c;
                }else if(documentMap.containskey('Driving License')){
                    prtcptEntty.Ovdtype = documentMap.get('Driving License').Document_Type__c == null ? '' : documentMap.get('Driving License').Document_Type__c;
                    prtcptEntty.Ovdid = documentMap.get('Driving License').KYC_No__c == null ? '' : documentMap.get('Driving License').KYC_No__c;
                }
            }else{
                prtcptEntty.panno = documentMap.get('PAN').PAN_No__c == null ? '' : documentMap.get('PAN').PAN_No__c;
                prtcptEntty.Ovdtype = documentMap.get('PAN').Document_Type__c == null ? '' : documentMap.get('PAN').Document_Type__c;
                prtcptEntty.Ovdid = documentMap.get('PAN').PAN_No__c == null ? '' : documentMap.get('PAN').PAN_No__c;
            }
            List<Integer> docList = new List<Integer>();
            docList.add(1);
            prtcptEntty.documentID = docList;
            prtcptEntty.Seqno = applicant.Applicant_Type__c == System.Label.Borrower ? 1 : 2;
            prtcptEntty.Lglcnstn = 'Resident Individual';
            prtcptEnttyList.add(prtcptEntty);

        }

        if(blCode != ''){
            for(BankBranchDetails__c bankBranchDetails : [
                Select Id,City__c,Address_4__c,Address_3__c,Address_2__c,Address_1__c,Bl_Code__c From BankBranchDetails__c Where Bl_Code__c =: blCode With SECURITY_ENFORCED LIMIT 1
            ]){
                loanWrapper.Branchplace = bankBranchDetails.City__c == null ? '' : bankBranchDetails.City__c;
                loanWrapper.Branchaddress = (bankBranchDetails.Address_1__c + ' ' +
                bankBranchDetails.Address_2__c + ' ' +
                bankBranchDetails.Address_3__c + ' ' + 
                bankBranchDetails.Address_4__c) == null ? '' : (bankBranchDetails.Address_1__c + ' ' +
                bankBranchDetails.Address_2__c + ' ' +
                bankBranchDetails.Address_3__c + ' ' + 
                bankBranchDetails.Address_4__c);
            }
        }      

        loanWrapper.estampdtls = eStampDetailsList;
        loanWrapper.prtcptentty = prtcptEnttyList;
        loanWrapper.loandtls = loadDetail;
        loanWrapper.documentdtls = documentDtlList;
        loanWrapper.eSignCordinates = eSignCordinateList;
        loanWrapper.AssetParticulars = assetParticulars;
        loanWrapper.financedtls = financeDtls;
        loanWrapper.othercharges = otherCharges;
        loanWrapper.paymentinstallment = paymentInstallmentList;
        loanWrapper.receiptdtls = receiptDtlsObj;
        loanWrapper.objStamping = objStamping;
        loanWrapper.objSDLst = objSDsList;

        this.loan =loanWrapper;
        System.debug('this.loan --> ' + JSON.serialize(this.loan));
        validate(System.Label.InitiateNeSL);
    }

    // @Method:      getHttpRequestHeaders
    // @Created by:  Yugandhar
    // @Description: Method to get the HTTP request header data
    // @Param:       ''
    // @Return:      Header required to callout the service.
    public override Map<String, String> getHttpRequestHeaders(){
        Map<String, String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }

    // @Method:      validate
    // @Created by:  Yugandhar
    // @Description: Method to validate the required input details
    // @Param:       Service name
    // @Return:      True - If all the validations are passed.
    public override boolean validate(String serviceName){

        string ErrorText = '';

        if (this.loan == null){
            ErrorText = System.Label.LoanDetailError;
        }
        if(this.Loan.Loanno == ''){
            ErrorText = ErrorText + 'Loan number, ';
        }
        if(this.Loan.Snctnno == ''){
            ErrorText = ErrorText +  'Snct number, ';
        }
        if(this.Loan.regType == ''){
            ErrorText = ErrorText +  'reg Type, ';
        }
         if(this.Loan.signFlag == ''){
            ErrorText = ErrorText + 'sign Flag, ';
        }
         if(this.Loan.txnID == ''){
            ErrorText = ErrorText + 'txnID, ';
        }
         if(this.Loan.estampFlag == ''){
            ErrorText = ErrorText +  'Estamp Flag, ';
        }
         if(this.Loan.f2f == ''){
            ErrorText = ErrorText +  'Face to Face, ';
        }
         if(this.Loan.State == ''){
            ErrorText = ErrorText +  'State, ';
        }
         if(this.Loan.Geo_State_Code == ''){
            ErrorText = ErrorText +  'Geo State Code, ';
        }

         if(this.Loan.product == ''){
            ErrorText = ErrorText +  'Product Type, ';
        }
         if(this.Loan.Unit == ''){
            ErrorText = ErrorText +  'Unit, ';
        }
      
         if(this.Loan.Noofpersonsign == ''){
            ErrorText = ErrorText +  'No of person sign, ';
        }
         if(this.Loan.Vehiclecategory == ''){
            ErrorText = ErrorText +  'Vehicle category, ';
        }
         if(this.Loan.Firstemiduedate == ''){
            ErrorText = ErrorText +  'First emi due date, ';
        }
         if(this.Loan.Secondemiduedate == ''){
            ErrorText = ErrorText +  'Second emi due date, ';
        }
    
         if(this.Loan.Branchname == ''){
            ErrorText = ErrorText +  'Branch name, ';
        }
         if(this.Loan.Branchplace == ''){
            ErrorText = ErrorText +  'Branch place, ';
        }
         if(this.Loan.Branchaddress == ''){
            ErrorText = ErrorText +  'Branch address, ';
        }

        if(this.Loan.estampdtls[0].stampDutyAmount == '' || this.Loan.estampdtls[0].stampDutyAmount == '0'){
            ErrorText = ErrorText +  'Total Stamping Done, ';
        }

        if(this.Loan.estampdtls[0].considerationPrice == '' || this.Loan.estampdtls[0].considerationPrice == '0'){
            ErrorText = ErrorText +  'Consideration Price, ';
        }
    
         if(this.Loan.estampdtls[0].Secondparty == ''){
            ErrorText = ErrorText +  'Applicant Name, ';
        } if(this.Loan.estampdtls[0].documentID == ''){
            ErrorText = ErrorText +  'documentID, ';
        } if(this.Loan.estampdtls[0].descriptionofDocument == ''){
            ErrorText = ErrorText +  'description of Document, ';
        } 
         if(this.Loan.prtcptentty[0].prtcptenttyId == 0){
            ErrorText = ErrorText +  'Applicant No., ';
        }
         if(this.Loan.prtcptentty[0].Cntrprtycntmobno == ''){
            ErrorText = ErrorText +  'Applicant Contact No, ';
        } if(this.Loan.prtcptentty[0].Cntrprtycntnm == ''){
            ErrorText = ErrorText +  'Applicant Name, ';
        } if(this.Loan.prtcptentty[0].Fatherhusbandname == ''){
            ErrorText = ErrorText +  'Applicant Father Name, ';
        }
         if(this.Loan.prtcptentty[0].Resistate == ''){
            ErrorText = ErrorText +  'KYC State, ';
        } if(this.Loan.prtcptentty[0].Aadhaar == ''){
            ErrorText = ErrorText +  'Aadhaar, ';
        }  if(this.Loan.prtcptentty[0].Constitution == ''){
            ErrorText = ErrorText +  'Applicant Type, ';
        } if(this.Loan.prtcptentty[0].Comaddr == ''){
            ErrorText = ErrorText +  'KYC Address, ';
        } 
        // if(this.Loan.prtcptentty[0].Doi == ''){
        //     ErrorText = ErrorText +  'Date of birth, ';
        // } 
        if(this.Loan.prtcptentty[0].Emlid == ''){
            ErrorText = ErrorText +  'Email ID, ';
        } if(this.Loan.prtcptentty[0].Fulnm == ''){
            ErrorText = ErrorText +  'Applicant Full Name, ';
        } 
        // if(this.Loan.prtcptentty[0].Panno == ''){
        //     ErrorText = ErrorText +  'Pan no, ';
        // } 
         if(this.Loan.prtcptentty[0].Pin == ''){
            ErrorText = ErrorText +  'Pin, ';
        }
        //  if(this.Loan.prtcptentty[0].Regoffpin == ''){
        //     ErrorText = ErrorText +  'Office PIN CODE, ';
        // }
      
         if(this.Loan.prtcptentty[0].documentID.size() == 0){
            ErrorText = ErrorText +  'documentID, ';
        }
        

        if(this.Loan.prtcptentty.size() > 1){
             if(this.Loan.prtcptentty[1].prtcptenttyId == 0){
                ErrorText = ErrorText +  '2nd Applicant No, ';
            }
             if(this.Loan.prtcptentty[1].Cntrprtycntmobno == ''){
                ErrorText = ErrorText +  '2nd Applicant Contact No, ';
            } if(this.Loan.prtcptentty[1].Cntrprtycntnm == ''){
                ErrorText = ErrorText +  '2nd Applicant Name, ';
            } if(this.Loan.prtcptentty[1].Fatherhusbandname == ''){
                ErrorText = ErrorText +  '2nd Applicant Father Name, ';
            }
             if(this.Loan.prtcptentty[1].Resistate == ''){
                ErrorText = ErrorText +  '2nd KYC State, ';
            } if(this.Loan.prtcptentty[1].Aadhaar == ''){
                ErrorText = ErrorText +  '2nd Aadhaar, ';
            } if(this.Loan.prtcptentty[1].Constitution == ''){
                ErrorText = ErrorText +  '2nd Applicant Type, ';
            } if(this.Loan.prtcptentty[1].Comaddr == ''){
                ErrorText = ErrorText +  '2nd KYC Address, ';
            } if(this.Loan.prtcptentty[1].Doi == ''){
                ErrorText = ErrorText +  '2nd DOB, ';
            } if(this.Loan.prtcptentty[1].Emlid == ''){
                ErrorText = ErrorText +  '2nd Email Id, ';
            } if(this.Loan.prtcptentty[1].Fulnm == ''){
                ErrorText = ErrorText +  '2nd Applicant Full Name, ';
            } if(this.Loan.prtcptentty[1].Panno == ''){
                ErrorText = ErrorText +  '2nd Pan no, ';
            }  

             if(this.Loan.prtcptentty[1].Pin == ''){
                ErrorText = ErrorText +  '2nd Pin, ';
            }
             if(this.Loan.prtcptentty[1].Regoffpin == ''){
                ErrorText = ErrorText +  '2nd Applicant Office Pin Code, ';
            }
           
             if(this.Loan.prtcptentty[1].documentID.size() == 0){
                ErrorText = ErrorText +  '2nd documentID, ';
            }
           
        }
        

        if(this.loan.loandtls.Dtofsnctn == ''){
            ErrorText = ErrorText +  'Sanction Date, ';
        }
        if(this.loan.loandtls.Rtofint == ''){
            ErrorText = ErrorText +  'Required ROI, ';
        }
        if(this.loan.loandtls.Fcltynm == ''){
            ErrorText = ErrorText +  'Facility name, ';
        }
        if(this.loan.loandtls.Snctnamt == ''){
            ErrorText = ErrorText +  'Sanction amount, ';
        }
        if(this.loan.loandtls.Tenure == ''){
            ErrorText = ErrorText +  'Tenure, ';
        }
        if(this.loan.loandtls.Toutstndamt == ''){
            ErrorText = ErrorText +  'Finance Amount, ';
        }        
        if(this.loan.loandtls.Emiamt == ''){
            ErrorText = ErrorText +  'EMI Amount, ';
        }
       
        if (this.loan.assetparticulars.Agmntdate == '') {
            ErrorText  = ErrorText + 'Agreement Date, ';
        }
        if (this.loan.assetparticulars.Effectivedate == '') {
            ErrorText  = ErrorText + 'Effective date, ';
        }
        if (this.loan.assetparticulars.Assetdesc == '') {
            ErrorText  = ErrorText + 'Variant, ';
        }
        // if (this.loan.assetparticulars.Vehinvbydesc == '') {
        //     ErrorText  = ErrorText + 'Dealer/Sub-dealer name, ';
        // }
        if (this.loan.assetparticulars.Make == '') {
            ErrorText  = ErrorText + 'Make, ';
        }
        if (this.loan.assetparticulars.Model == '') {
            ErrorText  = ErrorText + 'Model, ';
        }
        if (this.loan.financedtls.Period == '') {
            ErrorText  = ErrorText + 'Period, ';
        }
        if (this.loan.financedtls.Margin == '') {
            ErrorText  = ErrorText + 'Margin, ';
        }
        if (this.loan.financedtls.Interestrate == '') {
            ErrorText  = ErrorText + 'Offer engine CRM IRR, ';
        }
        
        if (this.loan.financedtls.Chassismargincost == '') {
            ErrorText  = ErrorText + 'Chassis margin cost, ';
        }
        if (this.loan.financedtls.Intcharges == '') {
            ErrorText  = ErrorText + 'Interest charges, ';
        }
        if (this.loan.financedtls.Agrmtvalue == '') {
            ErrorText  = ErrorText + 'Agreement Amount, ';
        }

        if(this.Loan.paymentinstallment[0].Fromno == ''){
            ErrorText  = ErrorText + 'From no, ';
        }
        if(this.Loan.paymentinstallment[0].Tono == ''){
            ErrorText  = ErrorText + 'To no, ';
        }
        if(this.Loan.paymentinstallment[0].Emi == ''){
            ErrorText  = ErrorText + 'Structured Emi Amount, ';
        }

        //Receiptno
    /*    if(this.Loan.receiptdtls.Receiptno == ''){
            ErrorText  = ErrorText + 'Receipt no, ';
        }
        if(this.Loan.receiptdtls.Receiptdate == ''){
            ErrorText  = ErrorText + 'Receipt date, ';
        }
        if(this.Loan.receiptdtls.Receiptamount == ''){
            ErrorText  = ErrorText + 'Receipt amount, ';
        }
        if(this.Loan.receiptdtls.Receipttype == ''){
            ErrorText  = ErrorText + 'Receipt type, ';
        } */

        //objStamping
        if(this.Loan.ObjStamping.No_Of_Signer == ''){
            ErrorText  = ErrorText + 'No Of Signer, ';
        }
        if(this.Loan.ObjStamping.Stamp_Duty_Purcased_By == ''){
            ErrorText  = ErrorText + 'Stamp Duty Purcased By, ';
        }
        if(this.Loan.ObjStamping.Deal_No == ''){
            ErrorText  = ErrorText + 'Deal No, ';
        }
        if(this.Loan.ObjStamping.Agreement_Booklet_No == ''){
            ErrorText  = ErrorText + 'Agreement Booklet No, ';
        }
        if(this.Loan.ObjStamping.Stamping_Type == ''){
            ErrorText  = ErrorText + 'Stamping Type, ';
        }
        if(this.Loan.ObjStamping.Total_Stamping_Amount == ''){
            ErrorText  = ErrorText + 'Total Stamping Amount, ';
        }
        if(this.Loan.ObjStamping.Total_Stamping_Amount_As_Per_Master == ''){
            ErrorText  = ErrorText + 'Total_Stamping_Amount_As_Per_Master, ';
        }
        if(this.Loan.ObjStamping.InitMethod == ''){
            ErrorText  = ErrorText + 'InitMethod, ';
        }
        if(this.Loan.ObjStamping.First_EMI_Due_Date == ''){
            ErrorText  = ErrorText + 'First EMI Due Date, ';
        }if(this.Loan.ObjStamping.Second_EMI_Due_Date == ''){
            ErrorText  = ErrorText + 'Second EMI Due Date, ';
        }
        if(this.Loan.ObjStamping.Agreement_Sign_Date == ''){
            ErrorText  = ErrorText + 'Agreement Sign Date, ';
        }
        if(this.Loan.ObjStamping.Effective_Deal_Date == ''){
            ErrorText  = ErrorText + 'Effective Deal Date, ';
        }
        if(this.Loan.ObjStamping.Maker_Id == ''){
            ErrorText  = ErrorText + 'Maker Id, ';
        }
        if(this.Loan.objSDLst.size() == 0)
        {
            ErrorText  = ErrorText + 'Stamp Details, ';
        }
        ErrorText = ErrorText.left(ErrorText.length()-2)+ErrorText.right(1);
       
        if(ErrorText != ''){
            ErrorText = 'These fields are Madantory : ' + ErrorText  ;
            throw new IND_Exception(ErrorText);
        }

        return true;
    }

    public class Loan{
        public final string loanno;
        public final string snctnno;
        public final string regType;
        public final string signFlag;
        public final string txnID;
        public final string loanDocFlag;
        public final string estampFlag;
        public final string f2f;
        public final string state;
        public final string Geo_State_Code;
        public final string src;
        public final string product;
        public final string Unit;
        public final string respURL;
        public final string noofpersonsign;
        public final string policyno;
        public final string vehiclecategory;
        public final string telematicsflag;
        public final string firstemiduedate;
        public final string secondemiduedate;
        public final string communicationlanguage;
        public final string branchname;
        public final string branchplace;
        public final string branchaddress;
        public EStampDetail[] estampdtls;
        public PrtcptEntty[] prtcptentty;
        public LoadDetails loandtls;
        public DocumentDtls[] documentdtls;
        public ESignCordinate[] eSignCordinates;
        public AssetParticulars assetparticulars;
        public FinanceDtls financedtls;
        public OtherCharges othercharges;
        public PaymentInstallment[] paymentinstallment;
        public ReceiptDtls receiptdtls;
        public ObjStamping objStamping;
        public ObjSD[] objSDLst;
    }

    public class EStampDetail{
        public final string firstparty;
        public final string considerationPrice;
        public final string stampDutyAmount;
        public final string stampdutyPaidby;
        public final string secondparty;
        public final string documentID;
        public final string descriptionofDocument;
        public final string StampedFor;
        public final string articleCode;
    }

    public class PrtcptEntty{
        public Integer prtcptenttyId;
        public final string altemlid;
        public final string altmobno;
        public final string cntrprtyaddr;
        public final string cntrprtycntmobno;
        public final string cntrprtycntnm;
        public final string fatherhusbandname;
        public final string authsignatoryname;
        public final string designationsignatory;
        public final string resistate;
        public final string offaddr;
        public final string offstate;
        public final string offpin;
        public final string offphone;
        public final string offemail;
        public final string voterid;
        public final string passport;
        public final string drivinglicense;
        public final string aadhaar;
        public final string din;
        public final string virtualid;
        public final string ckycid;
        public final string cin;
        public final string gstno;
        public final string udyogaadhaarno;
        public final string udyam;
        public final string constitution;
        public final string comaddr;
        public final string doi;
        public final string emlid;
        public final string fulnm;
        public final string panno;
        public final string partytyp;
        public final string pin;
        public final string regoffpin;
        public final string reltocntrct;
        public final string ovdtype;
        public final string ovdid;
        public Integer[] documentID;
        public Integer seqno;
        public final string lglcnstn;
    }

    public class LoadDetails{
        public final string chgamt;
        public final string crdtsubtyp;
        public final string currofsanc;
        public final string dtofsnctn;
        public final string fcltynm;
        public final string fundtyp;
        public final string isacctclosed;
        public final string ntrofcrdt;
        public final string rtofint;
        public final string snctnamt;
        public final string tenure;
        public final string toutstndamt;
        public final string emiamt;
    }

    public class DocumentDtls{
        public final string docData;
        public Integer documentID;
        public final string documentDesc;
    }

    public class ESignCordinate{
        public Integer prtcptenttyId;
        public Integer documentID;
        public final string[] coordinates;
    }

    public class AssetParticulars{
        public final string agmntdate;
        public final string effectivedate;
        public final string assetdesc;
        public final string invoiceno;
        public final string invoicedate;
        public final string vehinvby;
        public final string vehinvbydesc;
        public final string engineno;
        public final string chassisno;
        public final string regnno;
        public final string make;
        public final string model;
        public final string bodybuildername;
        public final string mnthyrofmfg;
        public final string donumber;
        public final string dodate;
        public final string collateralsecurity;
        public final string insurancevalidupto;
        public final string rtataxremittedupto;
        public final string permitvalidupto;
        public final string purposeloan;
    }

    public class FinanceDtls{
        public final string period;
        public final string moratorium;
        public final string noadveMI;
        public final string instfrequency;
        public final string mclrloadedtenorprm;
        public final string margin;
        public final string interestrate;
        public final string costofchassis;
        public final string costofbody;
        public final string chassismargincost;
        public final string bodymargincost;
        public final string loanamtonchassis;
        public final string loanamtonbody;
        public final string loanamtaddfunding;
        public final string intcharges;
        public final string agrmtvalue;
    }

    public class OtherCharges{
        public string processingch;
        public string docmntch;
        public string stampingch;
        public string vehrgnhypch;
        public string rtorgnch;
        public string rocfilingch;
        public string cersairgnch;
        public string neslregnch;
        public string neslrenewch;
        public string rocconsultfee;
        public string cibilch;
        public string assetvalch;
        public string repaydc;
        public string repaydishonch;
        public string closurebankaccch;
        public string swapch;
        public string collnchrgchqrtn;
        public string collnchrgpdcs;
        public string collnchrgcash;
        public string travelcc;
        public string smstcch;
        public string preclosurech;
        public string overdueintmon;
        public string statementch;
        public string dupnocch;
        public string loancc;
        public string foreclosurech;
        public string nocusageconv;
        public string legalrepoch;
        public string compensationch;
        public string tradecertch;
        public string duedatech;
        public string otherch;
        OtherCharges(){
            this.processingch = '';
            this.docmntch = '';
            this.stampingch = '';
            this.vehrgnhypch = '';
            this.rtorgnch = '';
            this.rocfilingch = '';
            this.cersairgnch = '';
            this.neslregnch = '';
            this.neslrenewch = '';
            this.rocconsultfee = '';
            this.cibilch = '';
            this.assetvalch = '';
            this.repaydc = '';
            this.repaydishonch = '';
            this.closurebankaccch = '';
            this.swapch = '';
            this.collnchrgchqrtn = '';
            this.collnchrgpdcs = '';
            this.collnchrgcash = '';
            this.travelcc = '';
            this.smstcch = '';
            this.preclosurech = '';
            this.overdueintmon = '';
            this.statementch = '';
            this.dupnocch = '';
            this.loancc = '';
            this.foreclosurech = '';
            this.nocusageconv = '';
            this.legalrepoch = '';
            this.compensationch = '';
            this.tradecertch = '';
            this.duedatech = '';
            this.otherch = '';
        }
    }

    public class PaymentInstallment{
        public final string fromno;
        public final string tono;
        public final string emi;
    }

    public class ReceiptDtls{
        public final string receiptno;
        public final string receiptdate;
        public final string receiptamount;
        public final string receipttype;
    }

    public class ObjStamping{
        public final string txnID;
        public final string No_Of_Signer;
        public final string Stamp_Duty_Purcased_By;
        public final string Deal_No;
        public final string Agreement_Booklet_No;
        public final string Stamping_Type;
        public final string Total_Stamping_Amount;
        public final string Total_Stamping_Amount_As_Per_Master;
        public final string InitMethod;
        public final string Tentative_Deal_Date;
        public final string Due_Date_Pattern;
        public final string First_EMI_Due_Date;
        public final string Second_EMI_Due_Date;
        public final string Deal_Date_Basis;
        public final string InvoiceDO_Date;
        public final string Agreement_Sign_Date;
        public final string Effective_Deal_Date;
        public final string Maker_Id;
    }

    public class ObjSD{
        public final string Stamp_S_No;
        public final string Stamp_On;
        public final string Stamp_Printed_Location_Blcode;
        public final string Stamp_Type;
        public final string Stamp_Value;
        public final string Stamped_For;

    }

}