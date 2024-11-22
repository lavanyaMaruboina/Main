/*
* User Story : SFTRAC-152
* Developer Name : Rajat Jaiswal
* Description : Test Class of EMI_CalculatorController Apex Class.
*/
@isTest
private class EMI_CalculatorControllerTest {
    @isTest
    static void testforMonthly() {
        List<Integer> cashflows = new List<Integer>();
        for (Integer i=0; i<59; i++) {
            cashflows.add(1000);
        }
        Test.startTest();
        EMI_CalculatorController.gradedRepaymentSchedule(cashflows, 80000, '12', Date.today(), 59,0,'1',Date.today().addDays(30),Date.today());
        Test.stopTest();
    }
    @isTest
    static void testforBiMonthly() {
        List<Integer> cashflows = new List<Integer>();
        for (Integer i=0; i<59; i++) {
            cashflows.add(1000);
        }
        Test.startTest();
        EMI_CalculatorController.gradedRepaymentSchedule(cashflows, 80000, '12', Date.today(), 59,0,'2',Date.today().addDays(30),Date.today());
        Test.stopTest();
    }
    @isTest
    static void testforQuartly() {
        List<Integer> cashflows = new List<Integer>();
        for (Integer i=0; i<59; i++) {
            cashflows.add(1000);
        }
        Test.startTest();
        EMI_CalculatorController.gradedRepaymentSchedule(cashflows, 80000, '12', Date.today(), 59,0,'3',Date.today().addDays(30),Date.today());
        Test.stopTest();
    }
    @isTest
    static void testforHalfYearly() {
        List<Integer> cashflows = new List<Integer>();
        for (Integer i=0; i<59; i++) {
            cashflows.add(1000);
        }
        Test.startTest();
        EMI_CalculatorController.gradedRepaymentSchedule(cashflows, 80000, '12', Date.today(), 59,0,'6',Date.today().addDays(30),Date.today());
        Test.stopTest();
    }


 @isTest
    static void testCalculateGrossNetIRR() {
        // Test data
        List<Decimal> cashFlows = new List<Decimal>{1000, 2000, 3000};
        Decimal principal = 10000;
        String frequency = '1';
        String payIn = '100';
        String payOut = '50';
        String installmentType = 'EQUATED';

       

        // Call the method under test
         EMI_CalculatorController.calculateGrossNetIRR(cashFlows, principal, frequency, payIn, payOut,installmentType);

        // Assertions
       // System.assertEquals(expectedGrossIRR, result.grossirr, 'Gross IRR calculation is incorrect');
       // System.assertEquals(expectedNetIRR, result.netirr, 'Net IRR calculation is incorrect');
    }

    // Inner class to mock the calculateIRR method
   
}