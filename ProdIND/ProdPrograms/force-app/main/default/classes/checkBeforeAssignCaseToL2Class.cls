public class checkBeforeAssignCaseToL2Class {
    public List<Case> caseRecord {get; set;}
    public Case caseObj {get; set;}
    public string msg{get; set;}
    public boolean isCheck {get;set;}
    public void checkCaseStatus(){
        String idOfRecord = ApexPages.currentPage().getParameters().get('id');
        caseRecord = [SELECT ID,Status,RecordTypeId,recordType.Name from Case where Id =: idOfRecord LIMIT 1];
        if(caseRecord.size()>0){
            caseObj = caseRecord[0];
            if(caseRecord[0].status == 'In Progress - L1'){
                isCheck = true;     		
            }else{
                msg = system.Label.Error_Message_when_Case_Status_Not_In_L1;
                
            }
            
        }
        
    }
    public checkBeforeAssignCaseToL2Class(){
        checkCaseStatus();
    }
}