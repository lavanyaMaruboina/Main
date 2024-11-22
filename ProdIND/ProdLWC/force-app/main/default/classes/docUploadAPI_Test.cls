@IsTest
public class docUploadAPI_Test {
    Public Class requestWrapper{
        Public String loanApplicationId;
        Public String documentType;
        Public String base64EncodedImage;
        Public String imageName;
    }
    public static TestMethod void UnitTest1(){
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;
        Opportunity opp = new Opportunity( Name= 'Opportunity',
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
                                          Required_ROI__c=5,
                                          Service_Charges__c='76', Parent_Deal_number__c='7878',
                                          Documentation_Charges__c='98', Stamping_Charges__c='87', Loan_amount__c='76777',
                                          Contact_number__c = '415.555.1212',Front_Upload_Attempts__c=0,Back_Upload_Attempts__c=0);
        insert opp; 
        
        Applicant__c ag1 = new Applicant__c();
        ag1.Opportunity__c = opp.Id;
        ag1.Applicant_Type__c = 'Borrower';
        ag1.Contact_number__c = '8341401752';
        insert ag1;
        
        Documents__c dcg1 = new Documents__c();
        dcg1.Applicant__c = ag1.Id;
        dcg1.Opportunity_Relation__c = opp.Id;
        dcg1.Document_Type__c = 'Aadhaar';
        dcg1.Document_Side__c ='Back';
        insert dcg1;
        
        
        requestWrapper wrapper= new requestWrapper();
       
        wrapper.loanApplicationId = opp.Id;
        wrapper.documentType = 'Vehicle Insurance Policy';
        wrapper.base64EncodedImage = 'iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAApgAAAKYB3X3/OAAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAANCSURBVEiJtZZPbBtFFMZ/M7ubXdtdb1xSFyeilBapySVU8h8OoFaooFSqiihIVIpQBKci6KEg9Q6H9kovIHoCIVQJJCKE1ENFjnAgcaSGC6rEnxBwA04Tx43t2FnvDAfjkNibxgHxnWb2e/u992bee7tCa00YFsffekFY+nUzFtjW0LrvjRXrCDIAaPLlW0nHL0SsZtVoaF98mLrx3pdhOqLtYPHChahZcYYO7KvPFxvRl5XPp1sN3adWiD1ZAqD6XYK1b/dvE5IWryTt2udLFedwc1+9kLp+vbbpoDh+6TklxBeAi9TL0taeWpdmZzQDry0AcO+jQ12RyohqqoYoo8RDwJrU+qXkjWtfi8Xxt58BdQuwQs9qC/afLwCw8tnQbqYAPsgxE1S6F3EAIXux2oQFKm0ihMsOF71dHYx+f3NND68ghCu1YIoePPQN1pGRABkJ6Bus96CutRZMydTl+TvuiRW1m3n0eDl0vRPcEysqdXn+jsQPsrHMquGeXEaY4Yk4wxWcY5V/9scqOMOVUFthatyTy8QyqwZ+kDURKoMWxNKr2EeqVKcTNOajqKoBgOE28U4tdQl5p5bwCw7BWquaZSzAPlwjlithJtp3pTImSqQRrb2Z8PHGigD4RZuNX6JYj6wj7O4TFLbCO/Mn/m8R+h6rYSUb3ekokRY6f/YukArN979jcW+V/S8g0eT/N3VN3kTqWbQ428m9/8k0P/1aIhF36PccEl6EhOcAUCrXKZXXWS3XKd2vc/TRBG9O5ELC17MmWubD2nKhUKZa26Ba2+D3P+4/MNCFwg59oWVeYhkzgN/JDR8deKBoD7Y+ljEjGZ0sosXVTvbc6RHirr2reNy1OXd6pJsQ+gqjk8VWFYmHrwBzW/n+uMPFiRwHB2I7ih8ciHFxIkd/3Omk5tCDV1t+2nNu5sxxpDFNx+huNhVT3/zMDz8usXC3ddaHBj1GHj/As08fwTS7Kt1HBTmyN29vdwAw+/wbwLVOJ3uAD1wi/dUH7Qei66PfyuRj4Ik9is+hglfbkbfR3cnZm7chlUWLdwmprtCohX4HUtlOcQjLYCu+fzGJH2QRKvP3UNz8bWk1qMxjGTOMThZ3kvgLI5AzFfo379UAAAAASUVORK5CYII=';
        wrapper.imageName = 'test';
        
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/v1/docUploadAPI/';
        request.httpMethod = 'POST';
        system.debug('Before request.requestBody -->'+blob.valueof(Json.serialize(wrapper)));
        request.requestBody = blob.valueof(JSON.serialize(wrapper));
        RestContext.request = request;
        RestResponse res = new RestResponse();
        RestContext.response= res;
        docUploadAPI.uploadLoanDocument();
    }
    public static TestMethod void UnitTest3(){
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;
        Opportunity opp = new Opportunity( Name= 'Opportunity',
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
                                          Required_ROI__c=5,
                                          Service_Charges__c='76', Parent_Deal_number__c='7878',
                                          Documentation_Charges__c='98', Stamping_Charges__c='87', Loan_amount__c='76777',
                                          Contact_number__c = '415.555.1212',Front_Upload_Attempts__c=0,Back_Upload_Attempts__c=0);
        insert opp;
        
        Applicant__c apks1 = new Applicant__c();
        apks1.Opportunity__c = opp.Id;
        apks1.Contact_number__c = '9743514830';
        apks1.Applicant_Type__c = 'Borrower';
        apks1.In_Active_Applicant__c = false;
        insert apks1;
        
        Documents__c dcg1 = new Documents__c();
        dcg1.Applicant__c = apks1.Id;
        dcg1.Opportunity_Relation__c = opp.Id;
        dcg1.Document_Type__c = System.label.VoterIdCard;//'Voter Id'-7
        dcg1.Document_Side__c ='Back';
        insert dcg1;
        
        requestWrapper wrapper= new requestWrapper();
       
        wrapper.loanApplicationId = apks1.Id;
        wrapper.documentType = System.label.VoterIdCard;//'Voter Id'-7
        wrapper.base64EncodedImage = 'iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAApgAAAKYB3X3/OAAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAANCSURBVEiJtZZPbBtFFMZ/M7ubXdtdb1xSFyeilBapySVU8h8OoFaooFSqiihIVIpQBKci6KEg9Q6H9kovIHoCIVQJJCKE1ENFjnAgcaSGC6rEnxBwA04Tx43t2FnvDAfjkNibxgHxnWb2e/u992bee7tCa00YFsffekFY+nUzFtjW0LrvjRXrCDIAaPLlW0nHL0SsZtVoaF98mLrx3pdhOqLtYPHChahZcYYO7KvPFxvRl5XPp1sN3adWiD1ZAqD6XYK1b/dvE5IWryTt2udLFedwc1+9kLp+vbbpoDh+6TklxBeAi9TL0taeWpdmZzQDry0AcO+jQ12RyohqqoYoo8RDwJrU+qXkjWtfi8Xxt58BdQuwQs9qC/afLwCw8tnQbqYAPsgxE1S6F3EAIXux2oQFKm0ihMsOF71dHYx+f3NND68ghCu1YIoePPQN1pGRABkJ6Bus96CutRZMydTl+TvuiRW1m3n0eDl0vRPcEysqdXn+jsQPsrHMquGeXEaY4Yk4wxWcY5V/9scqOMOVUFthatyTy8QyqwZ+kDURKoMWxNKr2EeqVKcTNOajqKoBgOE28U4tdQl5p5bwCw7BWquaZSzAPlwjlithJtp3pTImSqQRrb2Z8PHGigD4RZuNX6JYj6wj7O4TFLbCO/Mn/m8R+h6rYSUb3ekokRY6f/YukArN979jcW+V/S8g0eT/N3VN3kTqWbQ428m9/8k0P/1aIhF36PccEl6EhOcAUCrXKZXXWS3XKd2vc/TRBG9O5ELC17MmWubD2nKhUKZa26Ba2+D3P+4/MNCFwg59oWVeYhkzgN/JDR8deKBoD7Y+ljEjGZ0sosXVTvbc6RHirr2reNy1OXd6pJsQ+gqjk8VWFYmHrwBzW/n+uMPFiRwHB2I7ih8ciHFxIkd/3Omk5tCDV1t+2nNu5sxxpDFNx+huNhVT3/zMDz8usXC3ddaHBj1GHj/As08fwTS7Kt1HBTmyN29vdwAw+/wbwLVOJ3uAD1wi/dUH7Qei66PfyuRj4Ik9is+hglfbkbfR3cnZm7chlUWLdwmprtCohX4HUtlOcQjLYCu+fzGJH2QRKvP3UNz8bWk1qMxjGTOMThZ3kvgLI5AzFfo379UAAAAASUVORK5CYII=';
        wrapper.imageName = 'test';
        
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/v1/docUploadAPI/';
        request.httpMethod = 'POST';
        system.debug('Before request.requestBody -->'+blob.valueof(Json.serialize(wrapper)));
        request.requestBody = blob.valueof(JSON.serialize(wrapper));
        RestContext.request = request;
        RestResponse res = new RestResponse();
        RestContext.response= res;
        docUploadAPI.uploadLoanDocument();
 
    }
    public static TestMethod void UnitTest2(){
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;
        Opportunity opp = new Opportunity( Name= 'Opportunity',
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
                                          Required_ROI__c=5,
                                          Service_Charges__c='76', Parent_Deal_number__c='7878',
                                          Documentation_Charges__c='98', Stamping_Charges__c='87', Loan_amount__c='76777',
                                          Contact_number__c = '415.555.1212',Front_Upload_Attempts__c=0,Back_Upload_Attempts__c=0);
        insert opp; 
        
        requestWrapper wrapper= new requestWrapper();
       
        wrapper.loanApplicationId = opp.Id;
        wrapper.documentType = 'test';
        wrapper.base64EncodedImage = '';
        wrapper.imageName = 'test';
        
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/v1/docUploadAPI/';
        request.httpMethod = 'POST';
        system.debug('Before request.requestBody -->'+blob.valueof(Json.serialize(wrapper)));
        request.requestBody = blob.valueof(JSON.serialize(wrapper));
        RestContext.request = request;
        RestResponse res = new RestResponse();
        RestContext.response= res;
        docUploadAPI.uploadLoanDocument();
    }
    
    public static TestMethod void UnitTest4(){
        Opportunity opks1 = new Opportunity();
        opks1.StageName = 'Qualification';
        opks1.CloseDate = Date.newInstance(2021, 1, 11);
        opks1.Name = 'testone';
        opks1.Lead_number__c = '45367';
        insert opks1;
        
        Applicant__c apks1 = new Applicant__c();
        apks1.Opportunity__c = opks1.Id;
        apks1.Contact_number__c = '9743514830';
        apks1.Applicant_Type__c = 'Borrower';
        apks1.In_Active_Applicant__c = false;
        insert apks1;
        
        Case cs1 = new Case();
        cs1.Applicant__c = apks1.Id;
        cs1.Loan_Application__c = opks1.Id;
        cs1.Origin = 'Email';
        cs1.SuppliedCompany = 'testpvt';
        insert cs1;
		requestWrapper wrapper= new requestWrapper();        
        wrapper.loanApplicationId = opks1.Id;
        wrapper.documentType = 'Residence Front View';
        wrapper.base64EncodedImage = 'iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAApgAAAKYB3X3/OAAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAANCSURBVEiJtZZPbBtFFMZ/M7ubXdtdb1xSFyeilBapySVU8h8OoFaooFSqiihIVIpQBKci6KEg9Q6H9kovIHoCIVQJJCKE1ENFjnAgcaSGC6rEnxBwA04Tx43t2FnvDAfjkNibxgHxnWb2e/u992bee7tCa00YFsffekFY+nUzFtjW0LrvjRXrCDIAaPLlW0nHL0SsZtVoaF98mLrx3pdhOqLtYPHChahZcYYO7KvPFxvRl5XPp1sN3adWiD1ZAqD6XYK1b/dvE5IWryTt2udLFedwc1+9kLp+vbbpoDh+6TklxBeAi9TL0taeWpdmZzQDry0AcO+jQ12RyohqqoYoo8RDwJrU+qXkjWtfi8Xxt58BdQuwQs9qC/afLwCw8tnQbqYAPsgxE1S6F3EAIXux2oQFKm0ihMsOF71dHYx+f3NND68ghCu1YIoePPQN1pGRABkJ6Bus96CutRZMydTl+TvuiRW1m3n0eDl0vRPcEysqdXn+jsQPsrHMquGeXEaY4Yk4wxWcY5V/9scqOMOVUFthatyTy8QyqwZ+kDURKoMWxNKr2EeqVKcTNOajqKoBgOE28U4tdQl5p5bwCw7BWquaZSzAPlwjlithJtp3pTImSqQRrb2Z8PHGigD4RZuNX6JYj6wj7O4TFLbCO/Mn/m8R+h6rYSUb3ekokRY6f/YukArN979jcW+V/S8g0eT/N3VN3kTqWbQ428m9/8k0P/1aIhF36PccEl6EhOcAUCrXKZXXWS3XKd2vc/TRBG9O5ELC17MmWubD2nKhUKZa26Ba2+D3P+4/MNCFwg59oWVeYhkzgN/JDR8deKBoD7Y+ljEjGZ0sosXVTvbc6RHirr2reNy1OXd6pJsQ+gqjk8VWFYmHrwBzW/n+uMPFiRwHB2I7ih8ciHFxIkd/3Omk5tCDV1t+2nNu5sxxpDFNx+huNhVT3/zMDz8usXC3ddaHBj1GHj/As08fwTS7Kt1HBTmyN29vdwAw+/wbwLVOJ3uAD1wi/dUH7Qei66PfyuRj4Ik9is+hglfbkbfR3cnZm7chlUWLdwmprtCohX4HUtlOcQjLYCu+fzGJH2QRKvP3UNz8bWk1qMxjGTOMThZ3kvgLI5AzFfo379UAAAAASUVORK5CYII=';
        wrapper.imageName = 'test';
        
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/v1/docUploadAPI/';
        request.httpMethod = 'POST';
        request.requestBody = blob.valueof(JSON.serialize(wrapper));
        RestContext.request = request;
        RestResponse res = new RestResponse();
        RestContext.response= res;
        docUploadAPI.uploadLoanDocument();
    }
}