public with sharing class EMI_CalculatorController {
    @AuraEnabled
    public static List<RepaymentWrapper> gradedRepaymentSchedule(List<Integer> cashFlows, Decimal principal, String irr, Date loanDate, Integer increment, Integer day, String frequency, Date repaymentDate,Date secondEMI){
        List<RepaymentWrapper> lstCom = new List<RepaymentWrapper>();
        try{
            Integer days = loanDate.daysBetween(repaymentDate);
            Integer excessDays;
            Integer frequencyDays;
            Decimal brokenInterest;
            Decimal interest;
            Date nextdue;
            Date lastDueDate;
            Decimal toRound;
            Decimal secondLastClosingBalance;
            List<Integer> cashFlowsList = new List<Integer>();
            cashFlowsList.add(-integer.valueof(principal));
            cashFlowsList.addall(cashFlows);
            Decimal effRate;
            Double monthlyRate;
            Decimal iRRInterest = Decimal.valueof(irr);
            if(frequency == '1'){
                monthlyRate = calculateIRR(cashFlowsList);
                effRate = monthlyRate*1200;
                frequencyDays = 30;	
            }
            else if(frequency == '2'){
                monthlyRate = calculateIRR(cashFlowsList);
                effRate = monthlyRate*600;
                frequencyDays = 60;	
            }
            else if(frequency == '3'){
                monthlyRate = calculateIRR(cashFlowsList);
                effRate = monthlyRate*400;
                frequencyDays = 90;	
            }
            else if(frequency == '6'){
                monthlyRate = calculateIRR(cashFlowsList);
                effRate = monthlyRate*200;
                frequencyDays = 180;		
            }
            if(frequency == '1'){
            for(integer i = 1 ; i<=cashFlows.size() ; i++) {
                RepaymentWrapper ap = new RepaymentWrapper();
                ap.instalmentAmount = string.valueof(cashFlows[i-1]);
                if(i==1){
                    ap.days = days;
                    ap.dueDate = repaymentDate;
                    repaymentDate = secondEMI;
                    //repaymentDate = repaymentDate.addMonths(1); 
                    excessDays = days - frequencyDays;
                    //brokenInterest = (effRate*Principal*excessDays)/36000;
                    toRound = Integer.Valueof(ap.instalmentAmount);
                    ap.instalmentAmount = string.valueof(toRound.round(roundingMode.UP));
                    interest = (iRRInterest*Principal*ap.days)/36500;
                    ap.interestComp = interest.setScale(2);
                }else{
                    ap.days=30;
                    ap.dueDate = repaymentDate;
                    nextdue = repaymentDate.addMonths(1); 
                    repaymentDate = repaymentDate.addMonths(1); 
                    Integer diff = lastDueDate.daysBetween(ap.dueDate);
                    interest = (iRRInterest*Principal*diff)/36500;
                    ap.interestComp = interest.setScale(2);
                }
                if(i == cashFlows.size()){
                    ap.closingPrinciple=secondLastClosingBalance;
                    ap.openingPrinciple = ap.closingPrinciple;
                    ap.principalComp = ap.closingPrinciple;
                    toRound = ap.interestComp + ap.principalComp;
                    ap.instalmentAmount = String.valueof(toRound.round(roundingMode.UP));  
                    ap.closingPrinciple = Principal-ap.principalComp;
                 }
                 else{
                     ap.principalComp = Integer.Valueof(ap.instalmentAmount)-ap.interestComp;
                     ap.closingPrinciple = Principal-ap.principalComp;
                     ap.openingPrinciple = ap.closingPrinciple + ap.principalComp;
                     if(i == (cashFlows.size()-1))
                     {
                         secondLastClosingBalance = ap.closingPrinciple;
                     }                 
                 }
                 ap.irr = effRate;
                 Principal = ap.closingPrinciple;
                 ap.instalmentNo = i;
                 lastDueDate = ap.dueDate;
                 lstCom.add(ap);
            }
        } else{
            for(integer i = 1 ; i<=Increment/integer.valueof(frequency) ; i++)
            {
                RepaymentWrapper ap = new RepaymentWrapper();
                ap.instalmentAmount = string.valueof(cashFlows[i-1]);
                if(i==1){
                        ap.days = days;
                        ap.dueDate = repaymentDate;
                        repaymentDate = secondEMI;
                        //repaymentDate = repaymentDate.addMonths(integer.valueof(frequency)); 
                            excessDays = days - frequencyDays;
                            //brokenInterest = (effRate*Principal*excessDays)/36000;
                            toRound = Integer.Valueof(ap.instalmentAmount);
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
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('EMI_CalculatorController', 'gradedRepaymentSchedule', System.Label.Apex, ex);
            throw new IND_Exception(ex.getMessage());   
        }
    }
    public static Double calculateIRR(List<Double> cashFlows) {
        Double guess = 0.1; // Initial guess for IRR
        Double x0 = 0.0;
        Double x1 = guess; // 0.1
        // Maximum number of iterations
        Integer maxIterations = 100;
        Integer iterations = 0;
        Double epsilon = 0.00001; // Error tolerance
        while (Math.abs(x1 - x0) > epsilon && iterations < maxIterations) {
            x0 = x1;
            x1 = x0 - calculateNPV(cashFlows, x0) / calculateDerivative(cashFlows, x0);
            iterations++;
        }
        return x1;
    }
    private static Double calculateNPV(List<Double> cashFlows, Double rate) {
        Double npv = 0.0;
        Integer n = cashFlows.size();
        for (Integer i = 0; i < n; i++) {
            npv += cashFlows[i] / Math.pow((1 + rate), i);
        }
        return npv;
    }
    private static Double calculateDerivative(List<Double> cashFlows, Double rate) {
        Double derivative = 0.0;
        Integer n = cashFlows.size();
        for (Integer i = 1; i < n; i++) {
            derivative -= i * cashFlows[i] / Math.pow((1 + rate), i + 1);
        }
        return derivative;
    }

@AuraEnabled 
public static IRRWrapper calculateGrossNetIRR(List<Decimal> cashFlows, Decimal principal, String frequency, String payIn, String payOut, String installmentType){

    try{
List<Decimal> grossCashFlowsList = new List<Decimal>();
List<Decimal> netcashFlowsList = new List<Decimal>();
Decimal payInWithoutGST = decimal.valueOf(payIn) / 1.18;

Decimal grossAmount = principal - payInWithoutGST;
Decimal netAmount = integer.valueof(principal) + integer.valueof(Payout) - integer.valueof(payInWithoutGST); 
		
        if(installmentType == 'EQUATED'){
            cashFlows.remove(0);
            cashFlows.add(0,cashFlows[0]);
        }
        grossCashFlowsList.add(-grossAmount);
        grossCashFlowsList.addall(cashFlows);
	    netcashFlowsList.add(-netAmount);
	    netcashFlowsList.addAll(cashFlows);
        Decimal grossEffRate;
        Double grossMonthlyRate;
 	    Decimal netEffRate;
        Double netMonthlyRate;

        if(frequency == '1'){
                grossMonthlyRate = calculateIRR(grossCashFlowsList);
                grossEffRate = grossMonthlyRate*1200;
		        netMonthlyRate = calculateIRR(netcashFlowsList);
                netEffRate = netMonthlyRate*1200;
            }
            else if(frequency == '2'){
		        grossMonthlyRate = calculateIRR(grossCashFlowsList);
                grossEffRate = grossMonthlyRate*600;
		        netMonthlyRate = calculateIRR(netcashFlowsList);
                netEffRate = netMonthlyRate*600;
            }
            else if(frequency == '3'){
                grossMonthlyRate = calculateIRR(grossCashFlowsList);
                grossEffRate = grossMonthlyRate*400;
		        netMonthlyRate = calculateIRR(netcashFlowsList);
                netEffRate = netMonthlyRate*400;
            }
            else if(frequency == '6'){
                grossMonthlyRate = calculateIRR(grossCashFlowsList);
                grossEffRate = grossMonthlyRate*200;
		        netMonthlyRate = calculateIRR(netcashFlowsList);
                netEffRate = netMonthlyRate*200;
            }

        IRRWrapper ap = new IRRWrapper();
		ap.grossirr = grossEffRate;
		ap.netirr = netEffRate;
		return ap;
    }catch(Exception ex){
        ErrorLoggerUtil.logErrorEvent('EMI_CalculatorController', 'calculateGrossNetIRR', System.Label.Apex, ex);
        throw new IND_Exception(ex.getMessage());   
    }
}

//SFTRAC-2064 start
@AuraEnabled
public static IRRWrapper calculateCRMIRR(List < Decimal > cashFlows, Decimal principal, String frequency, String installmentType) {

    try {
        List < Decimal > crmCashFlowsList = new List < Decimal > ();

        Decimal crmAmount = principal;

        if (installmentType == 'EQUATED') {
            cashFlows.remove(0);
            cashFlows.add(0, cashFlows[0]);
        }

        crmCashFlowsList.add(-crmAmount);
        crmCashFlowsList.addall(cashFlows);
        Decimal crmEffRate;
        Double crmMonthlyRate;
        system.debug('++++++crmCashFlowsList '+crmCashFlowsList);
        if (frequency == '1') {
            crmMonthlyRate = calculateIRR(crmCashFlowsList);
            crmEffRate = crmMonthlyRate * 1200;
        } else if (frequency == '2') {
            crmMonthlyRate = calculateIRR(crmCashFlowsList);
            crmEffRate = crmMonthlyRate * 600;
        } else if (frequency == '3') {
            crmMonthlyRate = calculateIRR(crmCashFlowsList);
            crmEffRate = crmMonthlyRate * 400;
        } else if (frequency == '6') {
            crmMonthlyRate = calculateIRR(crmCashFlowsList);
            crmEffRate = crmMonthlyRate * 200;
        }

        IRRWrapper ap = new IRRWrapper();
        ap.crmirr = crmEffRate;
        return ap;
    } catch (Exception ex) {
        ErrorLoggerUtil.logErrorEvent('EMI_CalculatorController', 'calculateCRMIRR', System.Label.Apex, ex);
        throw new IND_Exception(ex.getMessage());
    }
}
//SFTRAC-2064 end

public class IRRWrapper{
        @AuraEnabled public Decimal grossirr {get;set;}
        @AuraEnabled public Decimal netirr {get;set;}
        @AuraEnabled public Decimal crmirr {get;set;}   //SFTRAC-2064
    }

    public class RepaymentWrapper{
        @AuraEnabled public String instalmentAmount {get;set;}
        @AuraEnabled public Integer days {get;set;}
        @AuraEnabled public Decimal interestComp {get;set;}
        @AuraEnabled public Decimal closingPrinciple {get;set;}
        @AuraEnabled public Decimal principalComp {get;set;}
        @AuraEnabled public Decimal openingPrinciple {get;set;}
        @AuraEnabled public Decimal irr {get;set;}
        @AuraEnabled public Decimal monthlyIRR {get;set;}
        @AuraEnabled public Date dueDate {get;set;}
        @AuraEnabled public Integer instalmentNo {get;set;}
    }
}