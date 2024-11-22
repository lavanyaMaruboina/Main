/**
* @description       : This test class is for lWC_ManualDeviationMitigantsCntrl Apex class.
* @author            : Aakash J
* @group             : 
* @created on		 : 08-11-2023
* @Version 		  	 : 1.0
**/
@isTest
public class lWC_ManualDeviationMitigantsCntrlTest {
	@testSetup static void createCAMData() {
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod123@indusbank.com.uat',MobilePhone = '9089078967');
        insert u;
        System.runAs(u) 
        {
            Account au1 = new Account();
            au1.Name = 'test';
            au1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
            insert au1;
            
            List<AccountTeamMember> atmList = new List<AccountTeamMember>();
            AccountTeamMember atm1 = new AccountTeamMember();
            atm1.AccountId = au1.Id;
            atm1.TeamMemberRole = 'ACM';
            atm1.UserId = UserInfo.getUserId();
            atm1.FI_Executive_Counter__c = 3;
             atm1.Level__c ='L4;L1;L2';
            insert atm1;
            
            Opportunity opp = TestDataUtility.createTestLoanApplication(true);        
            opp.Sub_Stage__c = System.Label.Field_Investigation;
            opp.Is_Mobile_Journey_Completed__c = true;
            opp.Vehicle_Type__c = System.Label.used;
            opp.Product_Type__c = System.Label.TwoWheeler;
            opp.Sanction_Status__c = System.Label.nonStp;
            opp.AccountId = au1.Id;
            update opp;
            
            Applicant__c applicant = TestDataUtility.createTestApplicantService(true,opp);
            applicant.In_Active_Applicant__c = false;
            applicant.Would_you_like_to_open_a_bank_account__c = true;
            update applicant;
            
            Deviation_Master__c deviMaster = new Deviation_Master__c();
            deviMaster.Name ='Test DeviMaster';
            deviMaster.Active__c =true;
            deviMaster.Deviation_Level__c ='L4';
            deviMaster.Parameter__c ='Test DeviMaster Parameter';
            deviMaster.Source__c ='Manual';
            insert deviMaster;
            
            Mitigant_Master__c mitiMaster = new Mitigant_Master__c();
            mitiMaster.Name ='Test mitiMaster';
            mitiMaster.Active__c =true;
            mitiMaster.Description__c ='Test mitiMaster Parameter';
            insert mitiMaster;
            
            CAM__c parentCam = new CAM__c();
            parentCam.Loan_Application__c = opp.Id;
            parentCam.BE_CVO_Remark__c = 'testbeCVO';
            //parentCam.Is_Hold__c = true;
            parentCam.Conditional_Approval__c = 'testapproved';
            parentCam.Proposal_Status__c = 'Approved';
            insert parentCam;
            
        }
    }
    
    @isTest public static void testClassmethod(){
        User u = [SELECT Id FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<Deviation_Master__c> devMasterRecords = [SELECT Id, Name, Active__c, Deviation_Level__c, Parameter__c,
                                                          Source__c  FROM Deviation_Master__c where Active__c = true];
        
        List<Mitigant_Master__c> mitiMasterRecords = [SELECT Id, Name, Active__c, Description__c
                                                          FROM Mitigant_Master__c where Active__c = true];
        
        CAM__c parentCam = [Select id,Loan_Application__c From CAM__c Limit 1];
        AccountTeamMember atm1 = new AccountTeamMember();
            atm1.AccountId =[SELECT Id FROM Account WHERE NAme='test' LIMIT 1].Id;
            atm1.TeamMemberRole = 'ACM';
            atm1.UserId = UserInfo.getUserId();
            atm1.FI_Executive_Counter__c = 3;
             atm1.Level__c ='L4;L1;L2';
            insert atm1;
        System.runAs(u) 
        {	
            list<lWC_ManualDeviationMitigantsCntrl.deviationMasterWrapper>  devirecordsLst = new list<lWC_ManualDeviationMitigantsCntrl.deviationMasterWrapper>();
            lWC_ManualDeviationMitigantsCntrl.deviationMasterWrapper deviationMasterWrapperRec = new lWC_ManualDeviationMitigantsCntrl.deviationMasterWrapper();
            if(!devMasterRecords.isEmpty()){
                deviationMasterWrapperRec.Deviation_Id = devMasterRecords[0].Name;
                deviationMasterWrapperRec.Source = devMasterRecords[0].Source__c;
                deviationMasterWrapperRec.Parameter = devMasterRecords[0].Parameter__c;
                deviationMasterWrapperRec.Deviation_Level = devMasterRecords[0].Deviation_Level__c;
                devirecordsLst.add(deviationMasterWrapperRec);     
            }
            
            list<lWC_ManualDeviationMitigantsCntrl.mitigantsMasterWrapper>  mitigantsMasterWrapperLst = new list<lWC_ManualDeviationMitigantsCntrl.mitigantsMasterWrapper>();
            lWC_ManualDeviationMitigantsCntrl.mitigantsMasterWrapper mitigantsMasterWrapperRec = new lWC_ManualDeviationMitigantsCntrl.mitigantsMasterWrapper();
            if(!mitiMasterRecords.isEmpty()){
                mitigantsMasterWrapperRec.Name = mitiMasterRecords[0].Name;
                mitigantsMasterWrapperRec.Description = mitiMasterRecords[0].Description__c;
                mitigantsMasterWrapperLst.add(mitigantsMasterWrapperRec);     
            }
                        
            Test.startTest();
            lWC_ManualDeviationMitigantsCntrl.getOpportunity(opp.Id);
            lWC_ManualDeviationMitigantsCntrl.fetchMitigantRecords(String.valueOf(parentCam.Id));
            lWC_ManualDeviationMitigantsCntrl.fetchManulaDeviationRecords(String.valueOf(parentCam.Id));
         	lWC_ManualDeviationMitigantsCntrl.getdeviMasterRecords();
            lWC_ManualDeviationMitigantsCntrl.getmitigantsMasterRecords();
            lWC_ManualDeviationMitigantsCntrl.saveDeviationRec(devirecordsLst, String.valueOf(parentCam.Id));
            lWC_ManualDeviationMitigantsCntrl.saveMitigantRec(mitigantsMasterWrapperLst,String.valueOf(parentCam.Id));
            lWC_ManualDeviationMitigantsCntrl.sendApprovalCAMReqAPI(String.valueOf(parentCam.Id));
         	Test.stopTest();
            
        }
    }
}