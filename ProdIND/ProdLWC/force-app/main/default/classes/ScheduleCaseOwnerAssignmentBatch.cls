/*
    * @Class Name: ScheduleCaseOwnerAssignmentBatch
    * @Created by: 	Gaurav Rawat.
    * @Description: Scheduler class for Scheduling the "ScheduleCaseOwnerAssignmentBatch" batch class..
*/
public class ScheduleCaseOwnerAssignmentBatch implements Schedulable {
    public void execute(SchedulableContext SC){//Execute method of scheduler class..
        //To execute the CaseOwnerAssignmentBatch..
        CaseOwnerAssignmentBatch obj = new CaseOwnerAssignmentBatch();
		Database.executeBatch(obj);
    }
}