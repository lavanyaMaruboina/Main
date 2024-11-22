@isTest
public class Dedup_Customer_DetailsTest {
      @isTest
    public static void parseTest(){
        
         Dedup_Customer_Details dcd1 = new Dedup_Customer_Details();
         dcd1.Customer_Name = 'testname';
         dcd1.Customer_Type = 'testtype';
         dcd1.Date_of_Birth = '2/15/1974';
         dcd1.PAN_GIR_Number = 'ATQPK4947F';
         dcd1.Passport_Number = 'EC4744643';
         dcd1.Voter_ID_Number = 'DL/01/001/000000';
         dcd1.Driving_License_Number = '1/234/56/X';
         dcd1.Aadhaar_No = '999999990019';
         dcd1.Entity = 'Individual';
         dcd1.CustomerCodeVal = 'CU7667071';
        
         Test.startTest();
              Dedup_Customer_Details.parse(Json.Serialize(dcd1));
         Test.stopTest();
        
        
    }
}