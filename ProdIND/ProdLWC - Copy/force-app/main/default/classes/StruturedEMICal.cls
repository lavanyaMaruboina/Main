public with sharing class StruturedEMICal {
    @AuraEnabled
    public static List<Integer> calculateMonthlyEMI(String loanApplicationId,String vehicleID) {
        // Initialize list to store monthly EMI amounts
        List<Integer> monthlyEMIs = new List<Integer>();
        
        // Fetch structured EMI records based on Loan Application Id
        List<Structered_EMI__c> structuredEMIList = [SELECT Id, From_Month__c, To_Month__c, EMI_Amount__c FROM Structered_EMI__c WHERE Loan_Application__c = :loanApplicationId AND Vehicle_Detail__c =: vehicleID ORDER BY From_Month__c];
        
        // Process structured EMI records to calculate monthly EMI amounts
        for (Structered_EMI__c emiRecord : structuredEMIList) {
            Integer fromMonth = Integer.valueOf(emiRecord.From_Month__c);
            Integer toMonth = Integer.valueOf(emiRecord.To_Month__c);
            Integer emiAmount = Integer.valueOf(emiRecord.EMI_Amount__c);
            
            // Distribute EMI amount to the corresponding months
            for (Integer i = fromMonth; i <= toMonth; i++) {
                monthlyEMIs.add(emiAmount);
            }
        }
        
        return monthlyEMIs;
    }
}