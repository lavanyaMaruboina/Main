@isTest
public class IND_PactLmsServiceTest {
   /*   @isTest
     public static void getPactLmsCallOutRequestTest(){
         try{
             Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Opportunity__c = opp.Id;
            app1.Applicant_Type__c = 'Co-borrower';
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
             
             Test.startTest();
                   IND_PactLmsService.getPactLmsCallOutRequest(opp.Id);
             Test.stopTest();
         }catch(Exception e){
            // System.assertEquals('Script-thrown exception', e.getMessage());
         }
     } */
    //Added by Prashant Dixit to cover IND_PactLmsRequest class 
    @isTest
     public static void getPactLmsCallOutRequestTest(){
         
            Opportunity opp = new Opportunity(StageName = 'Qualification',CloseDate = Date.newInstance(2021, 1, 11),Name = 'testone', Deal_Number__c = 'TUT06226H', Vehicle_Type__c = 'New',Product_Type__c ='Tractor');
            insert opp;
                        
            Applicant__c app = new Applicant__c(Opportunity__c = opp.Id, Applicant_Type__c = 'Co-borrower');
            insert app;
         
            LoanDisbursementDetails__c loanDisRec = new LoanDisbursementDetails__c(Parent_Loan_Application__c = opp.Id, 
                                                                                   Payment_to_co_borrower__c = true, 
                                                                                   FirstYr_Own_Damage_Premium__c = 457354,
                                                                                   SecondYr_Own_Damage_Premium__c = 557354,
                                                                                   ThirdYr_Own_Damage_Premium__c = 986546,
                                                                                   FourthYr_Own_Damage_Premium__c = 232449,
                                                                                   FifthYr_Own_Damage_Premium__c = 643575,
                                                                                   FirstYr_Third_Party_Premium__c = 3256671,
                                                                                   SecondYr_Third_Party_Premium__c = 246576,
                                                                                   ThirdYr_Third_Party_Premium__c = 316516,
                                                                                   FourthYr_Third_Party_Premium__c = 434164,
                                                                                   FifthYr_Third_Party_Premium__c = 663642,
                                                                                   Adjustment_Deal_Number1__c = '5275',
                                                                                   Adjustment_Amount1__c = 63457, 
                                                                                   Adjustment_Deal_Number2__c = '57572',
                                                                                   Adjustment_Amount2__c = 56633,
                                                                                   Adjustment_Deal_Number3__c = '45757',
                                                                                   Adjustment_Amount3__c = 67575,
                                                                                   Adjustment_Deal_Number4__c = '57573',
                                                                                   Adjustment_Amount4__c = 74573,
                                                                                   Adjustment_Deal_Number5__c = '75375',
                                                                                   Adjustment_Amount5__c = 74672,
                                                                                   Adjustment_Deal_Number6__c = '58746',
                                                                                   Adjustment_Amount6__c = 46572,
                                                                                   Adjustment_Deal_Number7__c = '75735',
                                                                                   Adjustment_Amount7__c = 66768,
                                                                                   Adjustment_Deal_Number8__c = '54757',
                                                                                   Adjustment_Amount8__c = 54673);
            insert loanDisRec;
                
            Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c(Name = System.Label.Tractor, MDNField1__c = 'AB', MDNField2__c = 2);
            insert dlNumberSetting;
           
            try{
             Test.startTest();  
                   Deal_Number__c dealRec = new Deal_Number__c(Loan_Application__c = opp.Id, Sub_Stage__c = 'test', DNField1__c = dlNumberSetting.MDNField1__c, DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c));
                   insert dealRec;
                  
                   Vehicle_Detail__c vehicleDetail = new Vehicle_Detail__c(Dealer_Sub_dealer_name__c = 'abc',
                                                                Loan_Application__c = opp.Id,
                                                                Deal_Number__c =  dealRec.Id,         
                                                                Executive_Contact_Number__c='8989898989', 
                                                                Executive_name__c='ABC',
                                                                Product__c = '',
                                                                Insurance_expiring_within_60_days__c=true,
                                                                City__c='Aadityana',
                                                                Manufacturer_Year_Month__c = '2019-09',
                                                                Variant_Code__c = 'SWIFTVDI6',
                                                                Eligible_Tenure__c = 30,                                                               
                                                                Eligible_Loan_Amount__c = 500000);
                insert vehicleDetail;
                
                Final_Term__c finalTerm = new Final_Term__c(Vehicle_Detail__c=vehicleDetail.Id, Loan_Amount__c = '1000000', 
                                                            Tenure__c = '60', Net_IRR__c = 7, EMI_Amount__c = 10000, 
                                                            Holiday_period__c = '30', Installment_Type__c = 'Structured',
                                                            Service_charges__c = '3266', Due_date_shift_charges__c = '6536',
                                                            Documentation_charges__c = '3466', Verification_charges__c = '6733',
                                                            Trade_certificate__c = '6372', Loan_Application__c = opp.Id);
                insert finalTerm;
                
                IHM__c ihmRec = new IHM__c(Loan_Application__c = opp.Id, Deal_Number__c = dealRec.Id, 
                                           Total_amount_to_be_paid_by_customer_G__c = 78799, 
                                           Margin_money_to_be_deducted_from_disburs__c = 6478,
                                           SA_account_opening_charges__c = 1000);
                insert ihmRec;
                
                Loan_Agreement__c loanAgrRec = new Loan_Agreement__c(Loan_Application__c = opp.Id, Deal_Number__c = dealRec.Id,
                                                                    Agreement_Booklet_Num__c = '3562');
                insert loanAgrRec;
                
                 Documents__c doc1 = TestDataUtility.createTestDocumentITR(false, app, opp);
            doc1.Vehicle_Detail__c = vehicleDetail.Id;
            doc1.Opportunity_Relation__c = opp.Id;
            doc1.Is_Document_Eligible__c='No';
            doc1.Is_active__c = true;
            doc1.Document_Type__c = 'Chassis Number uploaded during verification';
            doc1.Additional_Document__c = true;
			insert doc1;                
                
            ContentVersion contentVersion = new ContentVersion(
                Title          = 'testfname',
                PathOnClient   = 'Pic.jpg',
                VersionData    = Blob.valueOf('Test Content'),
                IsMajorVersion = true);
            insert contentVersion; 
                
                 List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            //create ContentDocumentLink  record
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = doc1.Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
           
                
                   IND_PactLmsRequest pactLmsReqRec = IND_PactLmsService.getPactLmsCallOutRequest(opp.Id, dealRec.Id);
             Test.stopTest();
             
            }catch(Exception e){
             //System.debug('Exception is -> '+e.getMessage());
                String error = e.getMessage()+'  line number=>'+e.getLineNumber();
                
          }
     }
}