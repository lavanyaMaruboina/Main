@IsTest
public class OfficeFiClassTest {
 
    private testmethod static void TestOfficeFi() {
      
      Opportunity opp = new Opportunity();
        opp.StageName = 'Credit Processing';
        opp.Sub_Stage__c = 'Field Investigation';
        opp.Is_Mobile_Journey_Completed__c = true;
        opp.Vehicle_Type__c = 'Used';
        opp.Product_Type__c = 'Two Wheeler';
        opp.Sanction_Status__c = 'Non-STP';
        opp.CloseDate = date.Today();
        opp.Name = 'test23';        
        insert opp;
        
       Applicant__c applicant = new Applicant__c();
        applicant.Name='testtt';
        applicant.Opportunity__c =opp.id;
        applicant.Contact_number__c='6778298765';
        insert applicant;
      
      Case cse = new Case();
        cse.Applicant__c =applicant.id;
        cse.Loan_Application__c = opp.id;
        cse.Status ='FI Assigned';
        cse.Origin='Phone';
        insert cse;
        
      Field_Investigation__c officeFiRecord = new Field_Investigation__c();
        //officeFiRecord.Name ='test1';
        //officeFiRecord.AC_Installed__c = true;
        officeFiRecord.Address_Line_1__c='test';
        officeFiRecord.Case__c =cse.id;
        officeFiRecord.Address_Line_2__c ='test2';
        officeFiRecord.Product__c='prd';
        officeFiRecord.City__c='pune';
        officeFiRecord.Pin_Code__c='34562';
        officeFiRecord.State__c='maharashtra';
        officeFiRecord.Phone_Number__c = '2345678987';
        officeFiRecord.Mobile__c ='9876987645';
        officeFiRecord.Same_Addresst_as_in_the_Application__c =true;
        officeFiRecord.Employer_Business_Name__c ='empName';
        officeFiRecord.Office_Business_Board__c ='tstt';
        //officeFiRecord.Office_Business_Size_Sqft__c ='34.00';
        officeFiRecord.Office_Business_Type__c ='tjdx';
        officeFiRecord.Location__c = 'Location 1';
        officeFiRecord.Business_Premise__c ='Type 1';
        officeFiRecord.Category__c='Cst';
        officeFiRecord.Profile__c='Admin';
        officeFiRecord.Applicant_Recognized__c='Yes';
        officeFiRecord.Current_experience_years__c='34';
        //officeFiRecord.Total_Experience_Years__c='4.00';
        officeFiRecord.Monthly_Income_as_per_FI_Visit__c=77894.00;
        officeFiRecord.Touring_or_Transferable_Job__c ='yes';
        officeFiRecord.Income_as_per_FI_Visit__c =543456;
        officeFiRecord.Area__c='tedfh';
        officeFiRecord.Type_of_goods_sold__c = 'Goods Type 1';
        //officeFiRecord.No_of_Employees__c ='4563';
        officeFiRecord.Inhouse_Security_Camera_present__c ='YES';
        //officeFiRecord.POS_Machine__c=true;
        officeFiRecord.Own_Equipment_Tools__c ='Value 1';
        officeFiRecord.List_of_equipment_tools_owned__c='56';
        officeFiRecord.Affiliation_to_e_commerce__c='Yes';
        //officeFiRecord.Average_Professional_Fee_Service_Rs__c=3432;
        officeFiRecord.Types_of_vehicles_owned__c='car';
        officeFiRecord.No_of_vehicles_owned__c=2.00;
        officeFiRecord.Estimated_Average_Income_per_month__c =345666.00;
        officeFiRecord.No_of_contracts_awarded_in_last_1_year__c=45.00;
        officeFiRecord.Do_you_have_any_government_contracts__c='true';
        officeFiRecord.Estimated_Total_Monthly_Income__c=5647.00;
        officeFiRecord.Income_per_month__c=76498;
        insert officeFiRecord;
      
        Test.startTest();
        Field_Investigation__c response = OfficeFiClass.getOfficeFIRecord(officeFiRecord.Id);
        OfficeFiClass.getOfficeFIRecord(null);
        Test.stopTest();
    }
    
    private testmethod static void TestOfficeFi2() {
        Opportunity opp = new Opportunity();
        opp.StageName = 'Credit Processing';
        opp.Sub_Stage__c = 'Field Investigation';
        opp.Is_Mobile_Journey_Completed__c = true;
        opp.Vehicle_Type__c = 'Used';
        opp.Product_Type__c = 'Two Wheeler';
        opp.Sanction_Status__c = 'Non-STP';
        opp.CloseDate = date.Today();
        opp.Name = 'test23';
        insert opp;
        
        Applicant__c applicant = new Applicant__c();
        applicant.Name='testtt';
        applicant.Opportunity__c =opp.id;
        applicant.Contact_number__c='6778298765';
        insert applicant;
        Profile_Master__c prf = new Profile_Master__c();
        prf.Name='test';
        
        Income_Details__c incmeRecord =new Income_Details__c();
        incmeRecord.Is_Salaried__c=true;
        incmeRecord.Applicant__c =applicant.id ;
        incmeRecord.Primary_Income_Source__c =true;
        incmeRecord.Is_Self_Employed__c=false;
        incmeRecord.Profile__c =prf.id;
        insert incmeRecord;

        try{
           	Test.startTest();
        	Income_Details__c response = OfficeFiClass.getIncomeSourceRecord(applicant.id);
        	OfficeFiClass.getIncomeSourceRecord(null);
            Test.stopTest();   
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getUserRoleTest(){
      Account accobj = new Account();
      accobj.Name = 'testname';
      accobj.State__c = 'ASSAM';
      accobj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
      insert accobj;

      Opportunity opks1 = new Opportunity();
      opks1.AccountId = accobj.Id;
      opks1.StageName = 'Qualification';
      opks1.CloseDate = Date.newInstance(2021, 1, 11);
      opks1.Name = 'testone';
      insert opks1;

      case cs1 = new case();
      cs1.Loan_Application__c = opks1.Id;
      cs1.Subject='Approval Of Application Sourced By Off Roll Employee';
      cs1.Status = 'Pending-Off Role Employee App';
      cs1.Origin = 'Web';
      insert cs1; 

      AccountTeamMember atm1 = new AccountTeamMember();
      atm1.AccountId = opks1.AccountId;
      atm1.TeamMemberRole = 'BE';
      atm1.UserId = UserInfo.getUserId();
      insert atm1;

      Test.startTest();
      OfficeFiClass.getUserRole(cs1.Id);
      Test.stopTest();
    }
    
     @isTest
    public static void getUserRoleTest1(){  
      Account accobj = new Account();
      accobj.Name = 'testname';
      accobj.State__c = 'ASSAM';
      accobj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
      insert accobj;
        
      Opportunity opks1 = new Opportunity();
      opks1.AccountId = accobj.Id;
      opks1.StageName = 'Qualification';
      opks1.CloseDate = Date.newInstance(2021, 1, 11);
      opks1.Name = 'testone';
      insert opks1;
        
      case cs1 = new case();
      cs1.Loan_Application__c = opks1.Id;
      cs1.Subject='Approval Of Application Sourced By Off Roll Employee';
      cs1.Status = 'Pending-Off Role Employee App';
      cs1.Origin = 'Web';
      insert cs1; 
      
      AccountTeamMember atm1 = new AccountTeamMember();
      atm1.AccountId = opks1.AccountId;
      atm1.TeamMemberRole = 'FI';
      atm1.UserId = UserInfo.getUserId();
      insert atm1;

      Test.startTest();
      OfficeFiClass.getUserRole(cs1.Id);
      Test.stopTest();
    }
    
    @isTest
    public static void getUserRoleTestNegative(){  
      case cs1 = new case();
      cs1.Subject='Approval Of Application Sourced By Off Roll Employee';
      cs1.Status = 'Pending-Off Role Employee App';
      cs1.Origin = 'Web';
      insert cs1; 
      
      Test.startTest();
      try {
          OfficeFiClass.getUserRole(cs1.Id);
      } catch(Exception ex){
          System.assert(ex.getMessage().contains('Script-thrown exception'));
      }
      Test.stopTest();
    }
    
    @isTest
    public static void getDocumentRecordIdTest(){
        Test.startTest();
        OfficeFiClass.getDocumentRecordId();
        Test.stopTest();        
    } 
}