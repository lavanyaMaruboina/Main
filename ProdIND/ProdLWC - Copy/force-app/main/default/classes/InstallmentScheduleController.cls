/*------------------------------------------------------------
Author:        Rajat Jaiswal
User Story:    CISP-16789
Class Name:    InstallmentScheduleController
------------------------------------------------------------*/
public with sharing class InstallmentScheduleController {
    @AuraEnabled
    public static List<EMI_Schedule__c> getRecentEMIdetails(String loanId){
        try{
            List<EMI_Schedule__c> insScheduleList =  [SELECT Id, EMI_Due_Date__c, Number_of_Installments__c, EMI_Amount__c, Opening_Principal__c, Principal_Component__c, Interest_Component__c, Closing_Principal__c, Installment_Type__c,From_Month__c,To_Month__c,Loan_Application__c FROM EMI_Schedule__c WHERE Loan_Application__c =: loanId];
            return insScheduleList;
        }catch(exception e){
            ErrorLoggerUtil.logErrorEvent('InstallmentScheduleController', 'getRecentEMIdetails', System.Label.Apex, e, loanId);
            return null;
        }
    }

    @AuraEnabled
    public static void saveInstallmentSchedule(String loanId, String response, String installmentType){
        try{
            if(response!=null){
                List<AmortizationSchedule> amortizationScheduleList =(List<AmortizationSchedule>)system.JSON.deserialize(response, List<AmortizationSchedule>.class);
                List<EMI_Schedule__c> existingInsScheduleList =  [SELECT Id FROM EMI_Schedule__c WHERE Loan_Application__c =: loanId]; 
                List<EMI_Schedule__c> insScheduleList = new List<EMI_Schedule__c>();
                for(AmortizationSchedule amortScheduleObj : amortizationScheduleList){
                    EMI_Schedule__c insScheduleObj = new EMI_Schedule__c();
                    insScheduleObj.Loan_Application__c = loanId;
                    insScheduleObj.EMI_Due_Date__c = Date.valueOf(amortScheduleObj.emiDueDate);
                    insScheduleObj.Number_of_Installments__c = Integer.valueOf(amortScheduleObj.installmentNumber);
                    insScheduleObj.EMI_Amount__c = Decimal.valueOf(amortScheduleObj.installmentAmount).setScale(2);
                    insScheduleObj.Opening_Principal__c = Decimal.valueOf(amortScheduleObj.openingPrincipal).setScale(2);
                    insScheduleObj.Principal_Component__c = Decimal.valueOf(amortScheduleObj.pricipalComponent).setScale(2);
                    insScheduleObj.Interest_Component__c = Decimal.valueOf(amortScheduleObj.interestComponent).setScale(2);
                    insScheduleObj.Closing_Principal__c = Decimal.valueOf(amortScheduleObj.closingPrincipal).setScale(2);
                    insScheduleObj.Installment_Type__c = installmentType;
                    if(installmentType =='Structured'){
                    insScheduleObj.From_Month__c = Integer.valueOf(amortScheduleObj.installmentNumber);
                    insScheduleObj.To_Month__c = Integer.valueOf(amortScheduleObj.installmentNumber);                        
                    }
                    insScheduleList.add(insScheduleObj);
                }
                if(insScheduleList.size() > 0){
                    if(existingInsScheduleList.size() > 0){delete existingInsScheduleList;}
                    insert insScheduleList;
                    if(installmentType =='Structured'){
                        InstallmentScheduleController.updateStructuredEMIDate(loanId);
                    }
                }
            }
        }catch(exception e){
            ErrorLoggerUtil.logErrorEvent('InstallmentScheduleController', 'saveInstallmentSchedule', System.Label.Apex, e, loanId);
        }
    }
    @AuraEnabled
    public static boolean saveInstallmentScheduleTractor(String loanId, String response, String installmentType, String vehicleId){
        Boolean recordUpdate = true;
        try{
            if(response!=null){
                List<AmortizationSchedule> amortizationScheduleList =(List<AmortizationSchedule>)system.JSON.deserialize(response, List<AmortizationSchedule>.class);
                List<EMI_Schedule__c> existingInsScheduleList =  [SELECT Id FROM EMI_Schedule__c WHERE Loan_Application__c =: loanId AND Vehicle_Detail__c =: vehicleId]; 
                List<EMI_Schedule__c> insScheduleList = new List<EMI_Schedule__c>();
                for(AmortizationSchedule amortScheduleObj : amortizationScheduleList){
                    EMI_Schedule__c insScheduleObj = new EMI_Schedule__c();
                    insScheduleObj.Loan_Application__c = loanId;
                    insScheduleObj.Vehicle_Detail__c = vehicleId;
                    insScheduleObj.EMI_Due_Date__c = Date.valueOf(amortScheduleObj.emiDueDate);
                    insScheduleObj.Number_of_Installments__c = Integer.valueOf(amortScheduleObj.installmentNumber);
                    insScheduleObj.EMI_Amount__c = Decimal.valueOf(amortScheduleObj.installmentAmount).setScale(2);
                    insScheduleObj.Opening_Principal__c = Decimal.valueOf(amortScheduleObj.openingPrincipal).setScale(2);
                    insScheduleObj.Principal_Component__c = Decimal.valueOf(amortScheduleObj.pricipalComponent).setScale(2);
                    insScheduleObj.Interest_Component__c = Decimal.valueOf(amortScheduleObj.interestComponent).setScale(2);
                    insScheduleObj.Closing_Principal__c = Decimal.valueOf(amortScheduleObj.closingPrincipal).setScale(2);
                    insScheduleObj.Installment_Type__c = installmentType;
                    if(installmentType =='Structured'){
                    insScheduleObj.From_Month__c = Integer.valueOf(amortScheduleObj.installmentNumber);
                    insScheduleObj.To_Month__c = Integer.valueOf(amortScheduleObj.installmentNumber);                        
                    }
                    insScheduleList.add(insScheduleObj);
                }
                if(insScheduleList.size() > 0){
                    if(existingInsScheduleList.size() > 0){delete existingInsScheduleList;}
                    insert insScheduleList;
                    if(installmentType =='Structured'){
                        InstallmentScheduleController.updateStructuredEMIDateTractor(loanId,vehicleId);
                    }
                }
            }
        }catch(exception e){
            ErrorLoggerUtil.logErrorEvent('InstallmentScheduleController', 'saveInstallmentSchedule', System.Label.Apex, e, loanId);
            recordUpdate = false;
        }
        return recordUpdate;
    }

    @AuraEnabled
    public static void updateStructuredEMIDateTractor(String loanId, String vehicleId){
        try {
            List<Structered_EMI__c> structureList =  [SELECT Id,From_Month__c,To_Month__c,EMI_Due_Date__c FROM Structered_EMI__c WHERE Loan_Application__c =: loanId AND Vehicle_Detail__c =: vehicleId];
            if(!structureList.isEmpty()){
                List<EMI_Schedule__c> insScheduleList =  [SELECT Id, EMI_Due_Date__c,From_Month__c,To_Month__c FROM EMI_Schedule__c WHERE Loan_Application__c =: loanId];
                if(!insScheduleList.isEmpty()){
                    Map<Decimal,EMI_Schedule__c> scMap= new Map<Decimal,EMI_Schedule__c>();
                    for(EMI_Schedule__c emiRec:insScheduleList){
                        scMap.put(emiRec.From_Month__c,emiRec);
                    }
                    Boolean flag = false;
                    for(Structered_EMI__c stEmi :structureList){
                        if(scMap.containsKey(stEmi.From_Month__c) && scMap.get(stEmi.From_Month__c).From_Month__c == stEmi.From_Month__c && scMap.get(stEmi.From_Month__c).EMI_Due_Date__c != stEmi.EMI_Due_Date__c){
                            flag = true;
                            stEmi.EMI_Due_Date__c = scMap.get(stEmi.From_Month__c).EMI_Due_Date__c;
                        }
                        stEmi.Vehicle_Detail__c = vehicleId;
                    }
                    if(flag){
                        update structureList;
                    }
                }
            }
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('InstallmentScheduleController', 'updateStructuredEMIDate', System.Label.Apex, e, loanId);
            throw new AuraHandledException(e.getMessage());
        }
    }

    // @AuraEnabled
    // public static boolean saveAmortScheduleRecTractor(String loanId, String response, String installmentType, String vehicleId){
    //     Boolean recordUpdate = true;
    //     try{
    //         if(response!=null){
    //             List<RepaymentWrapper> amortizationScheduleList =(List<RepaymentWrapper>)system.JSON.deserialize(response, List<RepaymentWrapper>.class);
    //             List<Amort_Schedule__c> existingAmtScheduleList =  [SELECT Id FROM Amort_Schedule__c WHERE Loan_Application__c =: loanId AND Vehicle_Detail__c =: vehicleId]; 
    //             List<Amort_Schedule__c> amtScheduleList = new List<Amort_Schedule__c>();
    //             for(RepaymentWrapper amortScheduleObj : amortizationScheduleList){
    //                 Amort_Schedule__c amtScheduleObj = new Amort_Schedule__c();
    //                 amtScheduleObj.Loan_Application__c = loanId;
    //                 amtScheduleObj.Vehicle_Detail__c = vehicleId;
    //                 amtScheduleObj.EMI_Due_Date__c = amortScheduleObj.dueDate;
    //                 amtScheduleObj.Number_of_Installments__c = amortScheduleObj.instalmentNo;
    //                 amtScheduleObj.EMI_Amount__c = Decimal.valueOf(amortScheduleObj.instalmentAmount).setScale(2);
    //                 amtScheduleObj.Opening_Principal__c = amortScheduleObj.openingPrinciple.setScale(2);
    //                 amtScheduleObj.Principal_Component__c = amortScheduleObj.principalComp.setScale(2);
    //                 amtScheduleObj.Interest_Component__c = amortScheduleObj.interestComp.setScale(2);
    //                 amtScheduleObj.Closing_Principal__c = amortScheduleObj.closingPrinciple.setScale(2);
    //                 amtScheduleObj.Installment_Type__c = installmentType;
    //                 if(installmentType =='Structured'){
    //                 amtScheduleObj.From_Month__c = amortScheduleObj.instalmentNo;
    //                 amtScheduleObj.To_Month__c = amortScheduleObj.instalmentNo;                        
    //                 }
    //                 amtScheduleList.add(amtScheduleObj);
    //             }
    //             if(amtScheduleList.size() > 0){
    //                 if(existingAmtScheduleList.size() > 0){delete existingAmtScheduleList;}
    //                 insert amtScheduleList;
    //             }
    //         }
    //     }catch(exception e){
    //         ErrorLoggerUtil.logErrorEvent('InstallmentScheduleController', 'saveAmortScheduleRec', System.Label.Apex, e, loanId);
    //         recordUpdate = false;
    //     }
    //     return recordUpdate;
    // }

    @AuraEnabled
    public static List<Final_Term__c> getFinalTermsLoandetails(String loanId){
        try{
            List<Final_Term__c> finaltermsList = [SELECT Id,Advance_EMI__c,Loan_Amount__c,Loan_Application__r.Product_Type__c,Loan_Application__r.Total_Funded_Premium__c,EMI_Amount__c,Tenure__c,Loan_Application__r.Vehicle_Type__c,Installment_Type__c,Offer_Agreement_Amount__c,First_EMI_Date__c,Second_EMI_Date__c,CRM_IRR__c,Holiday_period__c,Loan_Application__r.StageName,Loan_Application__r.Sub_Stage__c,Loan_Deal_Date__c FROM Final_Term__c WHERE Loan_Application__c = :loanId LIMIT 1];
            return finaltermsList;
        }catch(exception e){
            ErrorLoggerUtil.logErrorEvent('InstallmentScheduleController', 'getFinalTermsLoandetails', System.Label.Apex, e, loanId);
            return null;
        }
    }

    public class AmortizationSchedule {
        public String emiDueDate{get;set;}
        public String installmentNumber{get;set;}
        public String installmentAmount{get;set;}
        public String openingPrincipal{get;set;}
        public String pricipalComponent{get;set;}
        public String interestComponent{get;set;}
        public String closingPrincipal{get;set;}
    }

    @AuraEnabled
    public static Structered_EMI__c getFirstStructureEMI(String loanId){
        try{
            List<Structered_EMI__c> firstEMIList = [SELECT Id,From_Month__c,To_Month__c,EMI_Amount__c,Number_of_Installments__c FROM Structered_EMI__c WHERE Loan_Application__c=:loanId AND From_Month__c = 1];
            List<EMI_Schedule__c> emiScheduleList =  [SELECT Id,EMI_Amount__c,EMI_Due_Date__c FROM EMI_Schedule__c WHERE Loan_Application__c =: loanId AND From_Month__c = 1];
            if(!emiScheduleList.isEmpty()){
                List<Structered_EMI__c> stEMIList = new List<Structered_EMI__c>();
                Structered_EMI__c st = new Structered_EMI__c(From_Month__c =1,To_Month__c = 1,Number_of_Installments__c = 1,EMI_Amount__c = emiScheduleList[0].EMI_Amount__c,EMI_Due_Date__c=emiScheduleList[0].EMI_Due_Date__c, Loan_Application__c=loanId);
                if(!firstEMIList.isEmpty()){
                    st.Id = firstEMIList[0].Id;
                }
                upsert st;
                return st;
            }else{
                return null;
            }
        }catch(exception e){
            ErrorLoggerUtil.logErrorEvent('InstallmentScheduleController', 'getFirstStructureEMI', System.Label.Apex, e, loanId);
            return null;
        }
    }
    

    @AuraEnabled
    public static List<RepaymentWrapper> emiRepaymentSchedule(Decimal principal , String irr, Date loanDate, Integer increment, Integer day, String frequency, Date repaymentDate, Date secondEMI, Boolean advanceEMI,String loanId,Decimal emiAmount) 
    {
        try{ 
            Opportunity OppObj = [SELECT ID,Product_type__C from Opportunity where ID =:loanId LIMIT 1];
            Integer days = loanDate.daysBetween(repaymentDate);
            Integer excessDays;
            Integer frequencyDays;
            List<RepaymentWrapper> lstCom = new List<RepaymentWrapper>();
            Decimal interest; 
            Decimal brokenInterest;
            Decimal secondLastClosingBalance;
            Date nextdue;
            Date lastDueDate;
            Integer dueDay = secondEMI.day();
            Integer x;
            Decimal toRound;
            Decimal iRRInterest = Decimal.valueof(irr);
            Decimal closePreValue;
            Decimal installmentWithoutRound ;//CISP-22162
            switch on frequency {
                when '1' {	
                    frequencyDays = 30;	
                }	
                when '2' {	
                    frequencyDays = 60;	
                }
                when '3' {
                    frequencyDays = 90;	
                }
                when '6' {
                    frequencyDays = 180;		
                }
            }
            if(advanceEMI == true){
                x = 0;
            } else {
                x = 1;
            }
            if(frequency == '1'){
              double finalResult1 = calculateMonthlyPayment( Principal,  iRRInterest,  Increment-x);
              if(OppObj.Product_Type__c == 'Two Wheeler' && advanceEMI == true){
                finalResult1 = emiAmount;
              }
                for(integer i = 1 ; i<=(Increment-x) ; i++)
                {
                    RepaymentWrapper ap = new RepaymentWrapper();
                    ap.instalmentAmount = string.valueof(Math.floor(finalResult1));
                    if(i==1){
                        ap.days = days;
                        ap.dueDate = repaymentDate;
                        repaymentDate = secondEMI;
                        Integer noOfDays = Date.isLeapYear(ap.dueDate.year())? 366 : 365;
                        //repaymentDate = repaymentDate.addMonths(1); 
                            excessDays = days - frequencyDays;
                            if(OppObj.Product_Type__c == 'Passenger Vehicles'){
                            brokenInterest = (iRRInterest*Principal*excessDays)/36000;
                            toRound = Decimal.Valueof(ap.instalmentAmount) + brokenInterest;
                            ap.instalmentAmount = string.valueof(Math.floor(toRound));
                            interest = iRRInterest/noOfDays*(ap.days)*Principal;
                            }else if(OppObj.Product_Type__c == 'Two Wheeler'){
                                interest = (iRRInterest*Principal)/noOfDays*ap.days;
                            }
                            installmentWithoutRound = (interest/100);//CISP-22162
                            ap.interestComp = (interest/100).setScale(2);
                    // }
                    }
                    else{
                        // ap.days=30;
                        ap.dueDate = repaymentDate;
                        nextdue = repaymentDate.addMonths(1); 
                        repaymentDate = repaymentDate.addMonths(1); 
                        Integer diff = lastDueDate.daysBetween(ap.dueDate);
                        ap.days = diff;
                        Integer noOfDays = Date.isLeapYear(ap.dueDate.year())? 366 : 365;
                        Integer dueDateLeapYear = Date.isLeapYear(lastDueDate.year())? 366 : 365;
                        if(OppObj.Product_Type__c == 'Passenger Vehicles'){
                            if(ap.dueDate.month() == 01 && noOfDays != dueDateLeapYear){
                                
                                Decimal oldVal = ((iRRInterest/dueDateLeapYear*((lastDueDate.daysBetween(Date.newinstance(lastDueDate.year(),12,31)))+1))*closePreValue);
                                Decimal newVal = ((iRRInterest/noOfDays*((Date.newinstance(ap.dueDate.year(),01,01)).daysBetween(ap.dueDate)))*closePreValue);
                                interest = oldVal + newVal;
                                System.debug('interest--' + interest);
                            }else{
                            interest = iRRInterest/noOfDays*(ap.days)*closePreValue;
                            }
                        }else if(OppObj.Product_Type__c == 'Two Wheeler'){
                            if(ap.dueDate.month() == 01 && noOfDays != dueDateLeapYear){
                                system.debug('oldVal--' + ((lastDueDate.daysBetween(Date.newinstance(lastDueDate.year(),12,31)))+1));
                                system.debug('new val --' + ((Date.newinstance(ap.dueDate.year(),01,01)).daysBetween(ap.dueDate)));
                                Decimal oldVal = ((iRRInterest/dueDateLeapYear*((lastDueDate.daysBetween(Date.newinstance(lastDueDate.year(),12,31)))+1))*closePreValue);
                                Decimal newVal = ((iRRInterest/noOfDays*((Date.newinstance(ap.dueDate.year(),01,01)).daysBetween(ap.dueDate)))*closePreValue);
                                interest = oldVal + newVal;

                                System.debug('interest--' + interest);
                            }else{
                            interest = (iRRInterest*Principal)/noOfDays*diff;
                            }
                        }
                        installmentWithoutRound = (interest/100);//CISP-22162
                        ap.interestComp = (interest/100).setScale(2);

                        // ap.days=30;
                        // ap.dueDate = repaymentDate;
                        // repaymentDate = date.newinstance(repaymentDate.year(), repaymentDate.month() + 1, dueDay);
                        // Integer diff = lastDueDate.daysBetween(ap.dueDate);
                        // interest = (iRRInterest*Principal*diff)/36500;
                        // ap.interestComp = interest.setScale(2);
                    }      
                    
                    if(i == (Increment-x)){
                       ap.closingPrinciple=secondLastClosingBalance;
                       ap.openingPrinciple = ap.closingPrinciple;
                       ap.principalComp = ap.closingPrinciple;
                        if(OppObj.Product_Type__c == 'Two Wheeler'){
                            toRound = ap.interestComp + ap.principalComp;
                            ap.instalmentAmount = String.valueof(Math.round(toRound));  
                            ap.principalComp = toRound - ap.interestComp;
                        }else{
                            toRound = installmentWithoutRound + ap.principalComp;
                            ap.instalmentAmount = String.valueof(Math.floor(toRound)); 
                            ap.principalComp = Decimal.valueof(ap.instalmentAmount) - installmentWithoutRound; 
                        }
                       
                       ap.closingPrinciple = Principal-ap.principalComp;
                       
                    }
                    else{
                        if(OppObj.Product_Type__c == 'Two Wheeler'){
                            ap.principalComp = Decimal.Valueof(ap.instalmentAmount)-ap.interestComp;
                        }else{
                            ap.principalComp = Decimal.Valueof(ap.instalmentAmount)-installmentWithoutRound;
                        }
                        ap.closingPrinciple = Principal-ap.principalComp;
                        ap.openingPrinciple = ap.closingPrinciple + ap.principalComp;
                        closePreValue = ap.closingPrinciple;
                        if(i == (Increment-x-1))
                        {
                            secondLastClosingBalance = ap.closingPrinciple;
                        }                 
                    }
                    ap.irr = iRRInterest;
                    Principal = ap.closingPrinciple;
                    ap.instalmentNo = i;
                    lastDueDate = ap.dueDate;
                    system.debug('ap--' + ap);
                    lstCom.add(ap);
                }
            }else{
            decimal finalResult1 = calculateMonthlyPayment( Principal,  iRRInterest*integer.valueof(frequency),  Increment/integer.valueof(frequency));
            for(integer i = 1 ; i<=Increment/integer.valueof(frequency) ; i++)
            {
                RepaymentWrapper ap = new RepaymentWrapper();
                ap.instalmentAmount = string.valueof(Math.round(finalResult1));
                if(i==1){
                        ap.days = days;
                        ap.dueDate = repaymentDate;
                        repaymentDate = secondEMI;
                        //repaymentDate = repaymentDate.addMonths(integer.valueof(frequency)); 
                            excessDays = days - frequencyDays;
                            brokenInterest = (iRRInterest*Principal*excessDays)/36000;
                            toRound = Integer.Valueof(ap.instalmentAmount) + brokenInterest;
                            ap.instalmentAmount = string.valueof(toRound.round(roundingMode.UP));
                            interest = (iRRInterest*Principal*ap.days)/36500;
                            ap.interestComp = interest.setScale(2);
                    //}
                }
                else{
                    if(frequency == '2'){
                        ap.days=60;
                    }
                    else if(frequency == '3'){
                        ap.days=90;
                    }
                    else if(frequency == '6'){
                        ap.days=180;
                    }
                    ap.dueDate = repaymentDate;
                        nextdue = repaymentDate.addMonths(integer.valueof(frequency)); 
                        repaymentDate = repaymentDate.addMonths(integer.valueof(frequency)); 
                        Integer diff = lastDueDate.daysBetween(ap.dueDate);
                        interest = (iRRInterest*Principal*diff)/36500;
                        ap.interestComp = interest.setScale(2);
                }      

                if(i == Increment/integer.valueof(frequency)){
                    ap.closingPrinciple=secondLastClosingBalance;
                    ap.openingPrinciple = ap.closingPrinciple;
                    ap.principalComp = ap.closingPrinciple;
                    toRound = ap.interestComp + ap.principalComp;
                    ap.instalmentAmount = String.valueof(toRound.round(roundingMode.UP));
                    ap.closingPrinciple = Principal-ap.principalComp;
                }
                else{
                    ap.principalComp = Integer.Valueof(ap.instalmentAmount)-ap.interestComp;
                    //ap.openingPrinciple = ap.principalComp;
                    ap.closingPrinciple = Principal-ap.principalComp;
                    ap.openingPrinciple = ap.closingPrinciple + ap.principalComp;
                    if(i == Increment/integer.valueof(frequency)-1)
                    {
                        secondLastClosingBalance = ap.closingPrinciple;
                    }                 
                }
                ap.irr = iRRInterest;
                Principal = ap.closingPrinciple;
                lastDueDate = ap.dueDate;
                ap.instalmentNo = i;
                lstCom.add(ap);
            }
        }
            return lstCom;
        }
        catch(DmlException e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    Public static Decimal calculateMonthlyPayment(Decimal principalAmount, Decimal interestRate, Double loanTermMonths) { 
        Double monthlyInterestRate = interestRate / 12 / 100;
        Decimal numerator = principalAmount * monthlyInterestRate;
        Decimal denominator = 1 - (1 / Math.pow(1 + monthlyInterestRate, loanTermMonths));
        return numerator / denominator;
    }
    public Class RepaymentWrapper{
        
        @AuraEnabled
        public Boolean inputError {
            get;
            set;
        }
        @AuraEnabled
        public Integer instalmentNo {
            get;
            set;
        }
        @AuraEnabled
        public String instalmentAmount {
            get;
            set;
        }
        
        @AuraEnabled
        public decimal principalComp
        {
            get;
            set;
        }
        @AuraEnabled
        public decimal interestComp {
            get;
            set;
        }
        @AuraEnabled
        public decimal irr {
            get;
            set;
        }
        @AuraEnabled
        public decimal openingPrinciple {
            get;
            set;
        }
        @AuraEnabled
        public decimal  closingPrinciple {
            get;
            set;
        }
        @AuraEnabled
        public Date dueDate {
            get;
            set;
        }
        @AuraEnabled
        public Integer days {
            get;
            set;
        }        
    }

    @AuraEnabled
    public static List<RepaymentWrapper> structuredEMIRepaymentSchedule(List<Integer> cashFlows, Decimal principal, String irr, Date loanDate, Integer increment, Integer day, String frequency, Date repaymentDate, Date secondEMI, Boolean advanceEMI,String loanId) 
    {
        try{ 
            System.debug('from method'+ cashFlows);
            Opportunity OppObj = [SELECT ID,Product_type__C from Opportunity where ID =:loanId LIMIT 1];
            Integer days = loanDate.daysBetween(repaymentDate);
            Integer excessDays;
            Integer frequencyDays;
            List<RepaymentWrapper> lstCom = new List<RepaymentWrapper>();
            Decimal interest; 
            Decimal brokenInterest;
            Decimal secondLastClosingBalance;
            Date nextdue;
            Date lastDueDate;
            Integer dueDay = secondEMI.day();
            List<Integer> cashFlowsList = new List<Integer>();
            cashFlowsList.add(-integer.valueof(principal));
            cashFlowsList.addall(cashFlows);
            Integer x;
            Decimal toRound;
            Decimal iRRInterest = Decimal.valueof(irr);
            Decimal closePreValue;
            switch on frequency {
                when '1' {	
                    frequencyDays = 30;	
                }	
                when '2' {	
                    frequencyDays = 60;	
                }
                when '3' {
                    frequencyDays = 90;	
                }
                when '6' {
                    frequencyDays = 180;		
                }
            }
            if(advanceEMI == true){
                x = 0;
            } else {
                x = 1;
            }
            if(frequency == '1'){
                for(integer i = 1 ; i<=(Increment-x) ; i++)
                {
                    RepaymentWrapper ap = new RepaymentWrapper();
                    ap.instalmentAmount = string.valueof(Math.floor(cashFlowsList[i]));
                    if(i==1){
                        ap.days = days;
                        ap.dueDate = repaymentDate;
                        repaymentDate = secondEMI;
                        Integer noOfDays = Date.isLeapYear(ap.dueDate.year())? 366 : 365;
                        if(OppObj.Product_Type__c == 'Passenger Vehicles'){
                            interest = iRRInterest/noOfDays*(ap.days)*Principal;
                        }else{
                            interest = (iRRInterest*Principal)/noOfDays*ap.days;
                        }
                        //repaymentDate = repaymentDate.addMonths(1); 
                            // excessDays = days - frequencyDays;
                            // brokenInterest = (iRRInterest*Principal*excessDays)/36000;
                            // toRound = Integer.Valueof(ap.instalmentAmount) + brokenInterest;
                            // ap.instalmentAmount = string.valueof(toRound.round(roundingMode.UP));
                            
                            ap.interestComp = (interest/100).setScale(2);
                    // }
                    }
                    else{
                        // ap.days=30;
                        ap.dueDate = repaymentDate;
                        nextdue = repaymentDate.addMonths(1); 
                        repaymentDate = repaymentDate.addMonths(1); 
                        Integer diff = lastDueDate.daysBetween(ap.dueDate);
                        ap.days = diff;
                        Integer noOfDays = Date.isLeapYear(ap.dueDate.year())? 366 : 365;
                        Integer dueDateLeapYear = Date.isLeapYear(lastDueDate.year())? 366 : 365;
                        if(OppObj.Product_Type__c == 'Passenger Vehicles'){
                            if(ap.dueDate.month() == 01 && noOfDays != dueDateLeapYear){
                                
                                Decimal oldVal = ((iRRInterest/dueDateLeapYear*((lastDueDate.daysBetween(Date.newinstance(lastDueDate.year(),12,31)))+1))*closePreValue);
                                Decimal newVal = ((iRRInterest/noOfDays*((Date.newinstance(ap.dueDate.year(),01,01)).daysBetween(ap.dueDate)))*closePreValue);
                                interest = oldVal + newVal;
                                System.debug('interest--' + interest);
                            }else{
                            interest = iRRInterest/noOfDays*(ap.days)*closePreValue;
                            }
                        }else if(OppObj.Product_Type__c == 'Two Wheeler'){
                            if(ap.dueDate.month() == 01 && noOfDays != dueDateLeapYear){
                                system.debug('oldVal--' + ((lastDueDate.daysBetween(Date.newinstance(lastDueDate.year(),12,31)))+1));
                                system.debug('new val --' + ((Date.newinstance(ap.dueDate.year(),01,01)).daysBetween(ap.dueDate)));
                                Decimal oldVal = ((iRRInterest/dueDateLeapYear*((lastDueDate.daysBetween(Date.newinstance(lastDueDate.year(),12,31)))+1))*closePreValue);
                                Decimal newVal = ((iRRInterest/noOfDays*((Date.newinstance(ap.dueDate.year(),01,01)).daysBetween(ap.dueDate)))*closePreValue);
                                interest = oldVal + newVal;

                                System.debug('interest--' + interest);
                            }else{
                            interest = (iRRInterest*Principal)/noOfDays*diff;
                            }
                        }
                        ap.interestComp = (interest/100).setScale(2);

                        // ap.days=30;
                        // ap.dueDate = repaymentDate;
                        // repaymentDate = date.newinstance(repaymentDate.year(), repaymentDate.month() + 1, dueDay);
                        // Integer diff = lastDueDate.daysBetween(ap.dueDate);
                        // interest = (iRRInterest*Principal*diff)/36500;
                        // ap.interestComp = interest.setScale(2);
                    }      
                    
                    if(i == (Increment-x)){
                       ap.closingPrinciple=secondLastClosingBalance;
                       ap.openingPrinciple = ap.closingPrinciple;
                       ap.principalComp = ap.closingPrinciple;
                       toRound = ap.interestComp + ap.principalComp;
                       if(OppObj.Product_Type__c == 'Two Wheeler'){
                        ap.instalmentAmount = String.valueof(Math.round(toRound));  
                        ap.principalComp = toRound - ap.interestComp;
                       }else{
                        ap.instalmentAmount = String.valueof(Math.floor(toRound));
                        ap.principalComp = Decimal.valueof(ap.instalmentAmount) - ap.interestComp;
                       }
                       ap.closingPrinciple = Principal-ap.principalComp;
                    }
                    else{
                        ap.principalComp = Integer.Valueof(ap.instalmentAmount)-ap.interestComp;
                        ap.closingPrinciple = Principal-ap.principalComp;
                        ap.openingPrinciple = ap.closingPrinciple + ap.principalComp;
                        closePreValue = ap.closingPrinciple;
                        if(i == (Increment-x-1))
                        {
                            secondLastClosingBalance = ap.closingPrinciple;
                        }                 
                    }
                    ap.irr = iRRInterest;
                    Principal = ap.closingPrinciple;
                    ap.instalmentNo = i;
                    lastDueDate = ap.dueDate;
                    lstCom.add(ap);
                }
            }
            return lstCom;
        }catch(DmlException e) {
            ErrorLoggerUtil.logErrorEvent('InstallmentScheduleController', 'structuredEMIRepaymentSchedule', System.Label.Apex, e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Boolean updateStructuredEMIDate(String loanId){
        try {
            List<Structered_EMI__c> structureList =  [SELECT Id,From_Month__c,To_Month__c,EMI_Due_Date__c FROM Structered_EMI__c WHERE Loan_Application__c =: loanId];
            if(!structureList.isEmpty()){
                List<EMI_Schedule__c> insScheduleList =  [SELECT Id, EMI_Due_Date__c,From_Month__c,To_Month__c FROM EMI_Schedule__c WHERE Loan_Application__c =: loanId];
                if(!insScheduleList.isEmpty()){
                    Map<Decimal,EMI_Schedule__c> scMap= new Map<Decimal,EMI_Schedule__c>();
                    for(EMI_Schedule__c emiRec:insScheduleList){
                        scMap.put(emiRec.From_Month__c,emiRec);
                    }
                    Boolean flag = false;
                    for(Structered_EMI__c stEmi :structureList){
                        if(scMap.containsKey(stEmi.From_Month__c) && scMap.get(stEmi.From_Month__c).From_Month__c == stEmi.From_Month__c && scMap.get(stEmi.From_Month__c).EMI_Due_Date__c != stEmi.EMI_Due_Date__c){
                            flag = true;
                            stEmi.EMI_Due_Date__c = scMap.get(stEmi.From_Month__c).EMI_Due_Date__c;
                        }
                    }
                    if(flag){
                        update structureList;
                        return true;
                    }
                    return false;
                }
            }
            return false;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('InstallmentScheduleController', 'updateStructuredEMIDate', System.Label.Apex, e, loanId);
            return false;
        }
    }
    
    @AuraEnabled
    public static void updateTransactionRecord(String loanApplicationId){
        try{
            List<Loan_Application_Transaction_History__c> lATList=[Select id,Name,Submitted_Flag__c from Loan_Application_Transaction_History__c where Loan_Application_ID__c=:loanApplicationId  and Name='Structured EMI' And Module__c = 'Post Sanction Checks and Documentation' WITH SECURITY_ENFORCED];
            if(!lATList.isEmpty()){
                lATList[0].Submitted_Flag__c = true;
                update lATList;
            }
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('InstallmentScheduleController', 'updateTransactionRecord', System.Label.Apex, ex,loanApplicationId);
            throw new IND_Exception(ex.getMessage());   
        }
    }  
    // //CISP-22087
    // @AuraEnabled
    // public static void saveAmortScheduleRec(String loanId, String response, String installmentType){
    //     try{
    //         if(response!=null){
    //             List<RepaymentWrapper> amortizationScheduleList =(List<RepaymentWrapper>)system.JSON.deserialize(response, List<RepaymentWrapper>.class);
    //             List<Amort_Schedule__c> existingAmtScheduleList =  [SELECT Id FROM Amort_Schedule__c WHERE Loan_Application__c =: loanId]; 
    //             List<Amort_Schedule__c> amtScheduleList = new List<Amort_Schedule__c>();
    //             for(RepaymentWrapper amortScheduleObj : amortizationScheduleList){
    //                 Amort_Schedule__c amtScheduleObj = new Amort_Schedule__c();
    //                 amtScheduleObj.Loan_Application__c = loanId;
    //                 amtScheduleObj.EMI_Due_Date__c = amortScheduleObj.dueDate;
    //                 amtScheduleObj.Number_of_Installments__c = amortScheduleObj.instalmentNo;
    //                 amtScheduleObj.EMI_Amount__c = Decimal.valueOf(amortScheduleObj.instalmentAmount).setScale(2);
    //                 amtScheduleObj.Opening_Principal__c = amortScheduleObj.openingPrinciple.setScale(2);
    //                 amtScheduleObj.Principal_Component__c = amortScheduleObj.principalComp.setScale(2);
    //                 amtScheduleObj.Interest_Component__c = amortScheduleObj.interestComp.setScale(2);
    //                 amtScheduleObj.Closing_Principal__c = amortScheduleObj.closingPrinciple.setScale(2);
    //                 amtScheduleObj.Installment_Type__c = installmentType;
    //                 if(installmentType =='Structured'){
    //                 amtScheduleObj.From_Month__c = amortScheduleObj.instalmentNo;
    //                 amtScheduleObj.To_Month__c = amortScheduleObj.instalmentNo;                        
    //                 }
    //                 amtScheduleList.add(amtScheduleObj);
    //             }
    //             if(amtScheduleList.size() > 0){
    //                 if(existingAmtScheduleList.size() > 0){delete existingAmtScheduleList;}
    //                 insert amtScheduleList;
    //             }
    //         }
    //     }catch(exception e){
    //         ErrorLoggerUtil.logErrorEvent('InstallmentScheduleController', 'saveAmortScheduleRec', System.Label.Apex, e, loanId);
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }
//     @AuraEnabled
//     public static List<Amort_Schedule__c> getAmortSchedule(String loanId){
//     try {
//         List<Amort_Schedule__c> amtList= [SELECT ID,Opening_Principal__c, Closing_Principal__c, Interest_Component__c, EMI_Amount__c from Amort_Schedule__c where Loan_Application__c =:loanId];
//         return amtList;
//     } catch (Exception e) {
//         ErrorLoggerUtil.logErrorEvent('InstallmentScheduleController', 'saveAmortScheduleRec', System.Label.Apex, e, loanId);
//         throw new AuraHandledException(e.getMessage());
//     }
// }
}