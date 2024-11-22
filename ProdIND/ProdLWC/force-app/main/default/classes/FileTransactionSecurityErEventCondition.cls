global class FileTransactionSecurityErEventCondition implements TxnSecurity.EventCondition {

	public boolean evaluate(SObject event) {
        switch on event{
            when FileEventStore fileEventStore {
                return evaluate(fileEventStore);
            }
            when else{
                return false;
            }
        }
    }

    private boolean evaluate(FileEventStore fileEventStore){
		Profile profile = [SELECT Name FROM Profile WHERE Id IN (SELECT profileId FROM User WHERE Id = :fileEventStore.UserId)];
        if(fileEventStore.FileAction.contains('UI_DOWNLOAD') && profile != null && profile.Name == 'CMU') {
            return true;
        }
        return false;
    }
}