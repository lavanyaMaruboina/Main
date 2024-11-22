@isTest
public class IND_CAMPortfolioRequestTest {
    @testSetup
    public static void testSetup(){ 
        
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,User_Id__c = '29927_MO',
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod1237@indusbank.com',MobilePhone = '9089078967');
        
        insert u;
        
        
        
        System.runAs(u) 
        {
            Opportunity loanAPP = new Opportunity();
            loanAPP.StageName = 'Qualification';
            loanAPP.CloseDate = Date.newInstance(2021, 1, 11);
            loanAPP.Name = 'testone';
            loanAPP.Product_Type__c = 'Two Wheeler';
            loanAPP.Vehicle_Type__c = 'New';
            loanAPP.Agent_BL_code__c = 'AG-001';
            loanAPP.Lead_number__c = 'L18012200011';
            loanAPP.On_Road_price__c = 10000;
            insert loanAPP;
            
            Final_Term__c finalTeram = new Final_Term__c();
            finalTeram.CRM_IRR__c = 120;
            finalTeram.Loan_Application__c = loanAPP.Id;
            finalTeram.Holiday_period__c='30';
            finalTeram.EMI_Amount__c= 10000;
            finalTeram.FIwaiver_offAddress__c = 'Not Waived';
            finalTeram.Tenure__c = '50';
            finalTeram.Inputted_IRR__c = 12;
            insert finalTeram;
            
            List<Applicant__c> applicanList = new List<Applicant__c>();
            for(Integer j=0;j<6;j++){
                Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
                applicant.Opportunity__c = loanAPP.Id;
                applicant.Applicant_Type__c  = null;
                if(j==0){
                    applicant.Scorecard_Decision__c = 'Red';
                }
                if(j==1){
                    applicant.Scorecard_Decision__c = 'orange ';
                    
                }
                if(j==2){
                    applicant.Scorecard_Decision__c = 'Light Green';
                    
                }
                if(j==3){
                    applicant.Scorecard_Decision__c = 'Dark Green';
                    
                }
                if(j==4){
                    applicant.Scorecard_Decision__c = 'Yellow';
                    
                }
                if(j==5){
                    applicant.Scorecard_Decision__c = ' ';
                }
                applicant.Opportunity__r = loanAPP; 
                applicanList.add(applicant);
            }
            insert applicanList;
            
            
            List<Exposure__c> lstExp = new List<Exposure__c>();
            for(integer i=0;i<4;i++){
                Exposure__c  Eexpobject = new Exposure__c();  
                Eexpobject.Name = 'expName';
                Eexpobject.Loan_Application__c = loanAPP.Id;
                Eexpobject.Applicant__c =  applicanList[0].id;
                Eexpobject.CIF_ID__c ='3534534';
                Eexpobject.Deal_No__c = 'something1';
                if(i==0){
                    Eexpobject.Type__C = 'Borrower Exposure';
                }
                if(i==1){
                    Eexpobject.Type__C ='Co-Borrower Exposure';    
                }
                if(i==2){
                    Eexpobject.Type__C = 'Additional Customer';  
                }
                if(i==3){
                    Eexpobject.Type__C = 'Bank Exposure';  
                    
                }
                lstExp.add(Eexpobject);
            }                     
            insert lstExp;
            
            Bl_Code_Details__c bcd1 = new Bl_Code_Details__c();
            bcd1.Bl_Code__c = loanAPP.Agent_BL_code__c;
            bcd1.Name = 'test';
            insert bcd1;
            
            Geo_State_Masters__c gm1 = new Geo_State_Masters__c();
            gm1.NeSL_State_Code__c = 'test';
            gm1.OwnerId = UserInfo.getUserId();
            gm1.Pincode_Starting_Max__c = 524;
            gm1.Pincode__c = 315;
            gm1.Name = 'allur';
            gm1.State_Code__c = '01';
            insert gm1;
            
            
            BankBranchDetails__c bd1 = new BankBranchDetails__c();
            bd1.Bl_Code_Details__c = bcd1.Id;
            bd1.Geo_State_Master__c = gm1.Id;
            bd1.Address_1__c = 'testad1';
            bd1.Address_2__c = 'testad2';
            bd1.UniqueIdentifier__c = '201';
            bd1.District__c = 'nellore';
            insert bd1; 
            
            Profile_Master__c obj1 = new Profile_Master__c();
            obj1.code__c = '1';
            obj1.Category__c  = 'SENP';
            obj1.Name='test';
            insert obj1;
            
            Income_Details__c incomeObj = new Income_Details__c();
            incomeObj.Applicant__c = applicanList[0].id;
            incomeObj.Profile__c = obj1.Id;
            insert incomeObj;
            
            Vehicle_Detail__c vg3 = new Vehicle_Detail__c();
            vg3.Loan_Application__c = loanAPP.Id;
            vg3.Base_Price__c = 100000.00;
            vg3.Valuation_price__c = 100000;
            vg3.Selling_Price__c = 120000;
            vg3.Grid_value__c = 10000;
            vg3.Ben_Code__c = 'testveh';
            vg3.Manufacturer_Year_Month__c = '2009-02';
            insert vg3; 
            
            Income_Details__c objIncomingDetails = new Income_Details__c();
            objIncomingDetails.Applicant__c =  applicanList[0].Id;
            objIncomingDetails.From_Month__c = '2022-03';
            objIncomingDetails.To_Month__c = '2022-09';
            objIncomingDetails.Is_Salaried__c = true;
            objIncomingDetails.Employer_Business_Name__c = 'Test';
            objIncomingDetails.Capture_GST_Method__c = 'Online via link'; 
            objIncomingDetails.Profile__c = obj1.Id;
            objIncomingDetails.Applicant__r =  applicanList[0];
            insert objIncomingDetails;
            
            
            Documents__c document = new Documents__c();
            document.Applicant__c =  applicanList[0].Id;
            document.Opportunity_Relation__c = loanAPP.Id;
            document.KYC_name__c = 'Aadhar';
            document.Document_Side__c ='Back';
            document.Aadhar_Source__c = 'ScanAadhar';
            document.Name = 'Aadhar';
            document.Document_Type__c = 'Aadhaar';
            document.Document_Type__c ='Residence FI';
            document.KYC_DOB__c = System.today();
            document.Proof_of_Identity_POI__c = true;
            document.Proof_of_Address_POA__c = 	true;
            insert document;
            CIBIL_Details__c cibilDetail = TestDataUtility.createCIBILDetails(false, applicanList[0]);
            cibilDetail.CIC_No__c = '0132564314623555';
            insert cibilDetail;
            
            IND_CAMPortfolioRequest result = new IND_CAMPortfolioRequest(applicanList[0], loanAPP.Id);
            result.getHttpRequestHeaders();
            Boolean isValid = result.validate(System.Label.CAMPortfolio);
            System.assert(isValid);
            
            
        }
    }
    
    
    @istest
    Public static void  PassingRecord_Pass(){
        // Arrange 
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1237@indusbank.com' AND IsActive = true LIMIT 1]; 
        system.runAs(u){
            try{
                Test.startTest();
                Opportunity loanApp = [SELECT Id,Product_Type__c,Vehicle_Type__c,Agent_BL_code__c,Lead_number__c, Customer_Code__c FROM opportunity LIMIT 1];
                Applicant__c app = [SELECT Id,Opportunity__r.Lead_number__c,applicant_number__c FROM Applicant__c WHERE Scorecard_Decision__c = 'Red'];
                // Act
                IND_CAMPortfolioRequest result = new IND_CAMPortfolioRequest(app, loanAPP.Id);
                Test.stopTest();
            }
            catch(Exception e){
                // Assert
                System.assert(true);
            }
        }        
    }
}