global class ScheduleQuotationExpireDate1 implements Schedulable {
    global void execute(SchedulableContext sc) {
        QuotationExpireDate1 batchInstance = new QuotationExpireDate1();
        Database.executeBatch(batchInstance);
    }
}