@isTest
private class InstallmentScheduleControllerTest {

    @isTest
    static void getRecentEMIdetailsTest() {
        Opportunity opp = new Opportunity();
            opp.Name = 'opptestone';
            opp.StageName = 'Loan Details';
            opp.CloseDate = Date.newInstance(2022, 1, 11);
            opp.Product_Type__c = 'Two Wheeler';
            insert opp;
         
            EMI_Schedule__c emisch = new EMI_Schedule__c();
            emisch.Loan_Application__c = opp.id;
            emisch.From_Month__c = 1;
            emisch.To_Month__c = 1;
            
            insert emisch;

            InstallmentScheduleController.getRecentEMIdetails(opp.id);
        
        Final_Term__c finalTerm = new Final_Term__c();
        finalTerm.Loan_Application__c = opp.id;
        insert finalTerm;

        InstallmentScheduleController.getFinalTermsLoandetails(opp.id);
        
        Structered_EMI__c struemi = new Structered_EMI__c();
        struemi.Number_of_Installments__c = 2;
        struemi.Loan_Application__c = opp.id;
        emisch.From_Month__c = 1;
        emisch.To_Month__c = 1;
        insert struemi;

        Loan_Application_Transaction_History__c loanHis = new Loan_Application_Transaction_History__c();
        loanHis.Name = 'Structured EMI';
        loanHis.Module__c = 'Post Sanction Checks and Documentation';
        insert loanHis;

        Vehicle_Detail__c vech = new Vehicle_Detail__c();
        vech.Loan_Application__c = opp.id;
        insert vech;


        InstallmentScheduleController.getFirstStructureEMI(opp.id);
        InstallmentScheduleController.calculateMonthlyPayment(20,10,10);
        InstallmentScheduleController.updateStructuredEMIDate(opp.id);
        InstallmentScheduleController.updateTransactionRecord(opp.id);
        List<Integer> sInt = new List<Integer>();
        sInt.add(2);
        sInt.add(2);
        sInt.add(2);
        sInt.add(2);

        InstallmentScheduleController.structuredEMIRepaymentSchedule(sInt,20.0,'10',date.today(),5,5,'1',date.today(),date.today(),false,opp.id);
        String str = '[{ "emiDueDate": "2024-09-19", "installmentNumber": "1", "installmentAmount": "5979.0", "openingPrincipal": "65000.0", "pricipalComponent": "5979.0", "interestComponent": "0.0", "closingPrincipal": "59021.0" }, { "emiDueDate": "2024-10-21", "installmentNumber": "2", "installmentAmount": "5979.0", "openingPrincipal": "59021.0", "pricipalComponent": "4833.93", "interestComponent": "1145.07", "closingPrincipal": "54187.07" }]';
        InstallmentScheduleController.saveInstallmentScheduleTractor(opp.id,str,'Structured',vech.id);
        InstallmentScheduleController.saveInstallmentSchedule(opp.id,str,'Structured');
        InstallmentScheduleController.emiRepaymentSchedule(20.0,'10',date.today(),5,5,'1',date.today()-1,date.today()-2,false,opp.id,2000);


    }
    @isTest
    static void getRecentEMIdetailsTestNeg() {

        Opportunity opp = new Opportunity();
        opp.Name = 'opptestone';
        opp.StageName = 'Loan Details';
        opp.CloseDate = Date.newInstance(2022, 1, 11);
        opp.Product_Type__c = 'Two Wheeler';
        insert opp;

        InstallmentScheduleController.emiRepaymentSchedule(20.0,'10',date.today(),5,5,'2',date.today()-1,date.today()-2,false,opp.id,2000);

    }
   
}