//Test class for LwcCmuApplicationCntrl class.
@isTest
public class LwcCmuApplicationCntrlTest {
    /* Creating test data.
     Added by Khushiram 
	 IND-368
	*/
	@testSetup static void setup() {
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;
         Opportunity opp = TestDataUtility.createTestOpportunity(true);
      /*  Opportunity opp = new Opportunity( Name= 'Opportunity',
                                          StageName='Prospecting',
                                          CloseDate=System.today().addMonths(1),
                                          AccountId= testAccount.Id,
                                          OTP_for_borrower__c='99999',
                                          Applicant_Name__c='ayu',
                                          Mfr_Expence_Reimburse__c=32, 
                                          Mfr_Expence_Reimburse_Amt__c='6700'
                                          ,Mfr_Expence_Reimburse_Type__c='yhh' ,
                                          Mfr_Incentive__c=98,
                                          Main_Dealer_Incentive_Amount__c=76,
                                          Sub_Dealer_Ancentive_Amount__c=8798,
                                          DSM_Incentive1__c=767,
                                          DSM_Incentive2__c=65 ,DSM_Name1__c='bhgb' ,
                                          DSM_Name2__c='hhg', Dealer_Disc_to_Customer__c='878',
                                          Dealer_Expence_Reimburse_Type__c='hgfh',
                                          Gift_through_Dealer_Amount__c='866', Required_Tenure__c=7,
                                          Non_Dealer_DSM_Name1__c='jhfgh',
                                          Non_Dealer_DSM_Name2__c='jhhf',
                                          Non_Dealer_DSM_Incentive1__c=776, Non_Dealer_DSM_Incentive2__c=766,
                                          Required_ROI__c='5', Service_Charges__c='76', Parent_Deal_number__c='7878',
                                          Documentation_Charges__c='98', Stamping_Charges__c='87', Loan_amount__c='76777',
                                          Contact_number__c = '415.555.1212',Front_Upload_Attempts__c=0,Back_Upload_Attempts__c=0,Selfie_Retry_Attempts__c=2);
        insert opp; */
        
        //Applicant record for testing.==
        Applicant__c applicant = new Applicant__c(Name='Test_Applicant',Opportunity__c= opp.Id,Applicant_Type__c ='Borrower' ,Contact_Number__c ='1234567891',Whatsapp_number__c='1231231231',Income_Ca__c='SAL',Profile__c = 'Software Engineer', Bureau_Pull_Attempts__c=1,Income_Source__c='Non-Earning');
        insert applicant;
        
        //Document record for testing.
        Documents__c backDoc = new Documents__c(Name = 'Aadhaar', Opportunity_Relation__c=opp.id,Applicant__c =applicant.id,Document_Type__c = 'Aadhaar',Document_Side__c='front',Is_this_a_Photocopy__c = false,Proof_of_Address_POA__c=true,Proof_of_Identity_POI__c=true,Submit_to_CMU__c = true);
        insert backDoc;
    }
    
   
    /* test method for cmuDocumentRelatedList
        Added by Khushiram
        IND-368
    */
    @isTest
    public static void testCmuDocumentRelatedList(){ 
        Opportunity opp = [SELECT ID FROM Opportunity WHERE Name = 'Opportunity'];
        
        List<Documents__c> listOfDocsExpected = [select Name,Document_Type__c,Applicant__r.Name,Applicant__r.Applicant_Type__c,Document_Side__c,Is_this_a_Photocopy__c,
                                         Proof_of_Address_POA__c,Proof_of_Identity_POI__c from Documents__c where Submit_to_CMU__c = true];
        
        Test.startTest();
        List<Documents__c> listOfDocsActual = LwcCmuApplicationCntrl.cmuDocumentRelatedList(opp.Id); 
        Test.stopTest();
        System.assertEquals(listOfDocsExpected,listOfDocsActual);
    }
       
}