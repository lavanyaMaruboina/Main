@istest
public class IND_GetFinalOfferWithoutSharingTest {
    @isTest
    public static void getParentApplicationFiCaseTest(){
        try{
            Opportunity parentOpp = new Opportunity();
            parentOpp.StageName = 'Qualification';
            parentOpp.CloseDate = Date.newInstance(2021, 1, 11);
            parentOpp.Name = 'testone-A';
            parentOpp.Required_Loan_amount__c = 100000;
            insert parentOpp;
            
            Applicant__c applicant = new Applicant__c();
            applicant.Opportunity__c = parentOpp.Id;
            applicant.Contact_number__c = '9743514830';
            applicant.Applicant_Type__c = 'Borrower';
            insert applicant;
            
            case cs1 = new case();
            cs1.Loan_Application__c = parentOpp.Id;
            cs1.Subject='FI test Case Residence';
            cs1.Status = 'Completed';
            cs1.Origin = 'Web';
            cs1.Applicant__c = applicant.Id;
            cs1.Loan_Application__c = parentOpp.Id;
            cs1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FI').getRecordTypeId();
            insert cs1; 
            
            CaseHistory ch=new caseHistory();
            ch.CaseId = cs1.id;
            ch.Field= 'Subject';
            insert ch;
            
            Field_Investigation__c fiv1 = new Field_Investigation__c();
            fiv1.Case__c = cs1.Id;
            fiv1.Address_Line_1__c = 'Test Address1';
            fiv1.Address_Line_2__c = 'Test Address2';
            fiv1.City__c = 'Test City';
            fiv1.Pin_Code__c ='123442';
            fiv1.State__c =  'Test State';
            fiv1.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Residence').getRecordTypeId();
            insert fiv1;
            
            case cs2 = new case();
            cs2.Loan_Application__c = parentOpp.Id;
            cs2.Subject='FI test Case Permanent';
            cs2.Status = 'Completed';
            cs2.Origin = 'Web';
            cs2.Applicant__c = applicant.Id;
            cs2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FI').getRecordTypeId();
            insert cs2; 
            
            Field_Investigation__c fiv2 = new Field_Investigation__c();
            fiv2.Case__c = cs2.Id;
            fiv2.Address_Line_1__c = 'Test Address1';
            fiv2.Address_Line_2__c = 'Test Address2';
            fiv2.City__c = 'Test City';
            fiv2.Pin_Code__c ='123456';
            fiv2.State__c =  'Test State';
            fiv2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Permanent').getRecordTypeId();
            insert fiv2;
            
			case cs3 = new case();
            cs3.Loan_Application__c = parentOpp.Id;
            cs3.Subject='FI test Case Office';
            cs3.Status = 'FI-Unassigned';
            cs3.Origin = 'Web';
            cs3.Applicant__c = applicant.Id;
            cs3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FI').getRecordTypeId();
            insert cs3; 
            
            Field_Investigation__c fiv3 = new Field_Investigation__c();
            fiv3.Case__c = cs3.Id;
            fiv3.Address_Line_1__c = 'Test Address1';
            fiv3.Address_Line_2__c = 'Test Address2';
            fiv3.City__c = 'Test City';
            fiv3.Pin_Code__c ='123456';
            fiv3.State__c = 'Test State';
            fiv3.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
            insert fiv3; 
            cs3.Status = 'Completed';
            update cs3;
            
            Applicant__c applicant2 = new Applicant__c();
            applicant2.Opportunity__c = parentOpp.Id;
            applicant2.Contact_number__c = '9743514830';
            applicant2.Applicant_Type__c = 'Co-borrower';
            insert applicant2;
            
            case cs4 = new case();
            cs4.Loan_Application__c = parentOpp.Id;
            cs4.Subject='FI test Case Residence';
            cs4.Status = 'Completed';
            cs4.Origin = 'Web';
            cs4.Applicant__c = applicant2.Id;
            cs4.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FI').getRecordTypeId();
            insert cs4; 
            
            Field_Investigation__c fiv4 = new Field_Investigation__c();
            fiv4.Case__c = cs4.Id;
            fiv4.Address_Line_1__c = 'Test Address1';
            fiv4.Address_Line_2__c = 'Test Address2';
            fiv4.City__c = 'Test City';
            fiv4.Pin_Code__c ='123442';
            fiv4.State__c =  'Test State';
            fiv4.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Residence').getRecordTypeId();
            insert fiv4;
            
            case cs5 = new case();
            cs5.Loan_Application__c = parentOpp.Id;
            cs5.Subject='FI test Case Permanent';
            cs5.Status = 'Completed';
            cs5.Origin = 'Web';
            cs5.Applicant__c = applicant2.Id;
            cs5.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FI').getRecordTypeId();
            insert cs5; 
            
            Field_Investigation__c fiv5 = new Field_Investigation__c();
            fiv5.Case__c = cs5.Id;
            fiv5.Address_Line_1__c = 'Test Address1';
            fiv5.Address_Line_2__c = 'Test Address2';
            fiv5.City__c = 'Test City';
            fiv5.Pin_Code__c ='123456';
            fiv5.State__c =  'Test State';
            fiv5.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Permanent').getRecordTypeId();
            insert fiv5;
            
			case cs6 = new case();
            cs6.Loan_Application__c = parentOpp.Id;
            cs6.Subject='FI test Case Office';
            cs6.Status = 'FI-Unassigned';
            cs6.Origin = 'Web';
            cs6.Applicant__c = applicant2.Id;
            cs6.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FI').getRecordTypeId();
            insert cs6; 
            
            
            Field_Investigation__c fiv6 = new Field_Investigation__c();
            fiv6.Case__c = cs6.Id;
            fiv6.Address_Line_1__c = 'Test Address1';
            fiv6.Address_Line_2__c = 'Test Address2';
            fiv6.City__c = 'Test City';
            fiv6.Pin_Code__c ='123456';
            fiv6.State__c = 'Test State';
            fiv6.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
            insert fiv6; 
            cs6.Status = 'Completed';
            update cs6;
            Opportunity opfr1 = new Opportunity();
            opfr1.StageName = 'Qualification';
            opfr1.CloseDate = Date.newInstance(2021, 1, 11);
            opfr1.Name = 'testone-A';
            opfr1.Required_Loan_amount__c = 100000;
            opfr1.Parent_Loan_Application__c = parentOpp.Id;
            insert opfr1;
            
            Applicant__c apfr1 = new Applicant__c();
            apfr1.Opportunity__c = opfr1.Id;
            apfr1.Contact_number__c = '9743514830';
            apfr1.Applicant_Type__c = 'Borrower';
            insert apfr1;
            
            Vehicle_Detail__c vfr1 = new Vehicle_Detail__c();
            vfr1.Loan_Application__c = opfr1.Id;
            vfr1.Base_Price__c = 100000.00;
            vfr1.Ben_Code__c = 'testveh';
            insert vfr1; 
            
            
            Final_Term__c fgr1 = new Final_Term__c();
            fgr1.CRM_IRR__c = null;
            fgr1.Loan_Application__c = opfr1.Id;
            fgr1.Holiday_period__c='30';
            fgr1.Loan_Amount__c = null;
            fgr1.Tenure__c = null;
            //   fgr1.FIwaiver_offAddress__c = 'Not Waived';
            fgr1.EMI_Amount__c = 10000;
            insert fgr1;
            
            Test.startTest();
            IND_GetFinalOfferWithoutSharing.getParentApplicationFiCaseDetails(opfr1.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.debug('Exception ::::'+e.getMessage()+'Line Number::::'+e.getLineNumber());
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
     @isTest
    public static void cloneParentFICasetoChildAppTest(){
        try{
            Opportunity parentOpp = new Opportunity();
            parentOpp.StageName = 'Qualification';
            parentOpp.CloseDate = Date.newInstance(2021, 1, 11);
            parentOpp.Name = 'testone-A';
            parentOpp.Required_Loan_amount__c = 100000;
            insert parentOpp;
            Applicant__c applicant = new Applicant__c();
            applicant.Opportunity__c = parentOpp.Id;
            applicant.Contact_number__c = '9743514830';
            applicant.Applicant_Type__c = 'Borrower';
            insert applicant;
            
            case cs1 = new case();
            cs1.Loan_Application__c = parentOpp.Id;
            cs1.Subject='FI test Case Residence';
            cs1.Status = 'Completed';
            cs1.Origin = 'Web';
            cs1.RejectedFI__c = false;
            cs1.Applicant__c = applicant.Id;
            cs1.Loan_Application__c = parentOpp.Id;
            cs1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FI').getRecordTypeId();
            insert cs1; 
            
            CaseHistory ch=new caseHistory();
            ch.CaseId = cs1.id;
            ch.Field= 'Subject';
            insert ch;
            
            Field_Investigation__c fiv1 = new Field_Investigation__c();
            fiv1.Case__c = cs1.Id;
            fiv1.Address_Line_1__c = 'Test Address1';
            fiv1.Address_Line_2__c = 'Test Address2';
            fiv1.City__c = 'Test City';
            fiv1.Pin_Code__c ='123442';
            fiv1.State__c =  'Test State';
            fiv1.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Residence').getRecordTypeId();
            insert fiv1;
            
            case cs2 = new case();
            cs2.Loan_Application__c = parentOpp.Id;
            cs2.Subject='FI test Case Permanent';
            cs2.Status = 'Completed';
            cs2.Origin = 'Web';
            cs2.Applicant__c = applicant.Id;
            cs2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FI').getRecordTypeId();
            insert cs2; 

			CaseHistory ch2=new caseHistory();
            ch2.CaseId = cs2.id;
            ch2.Field= 'Subject';
            insert ch2;
			            
            Field_Investigation__c fiv2 = new Field_Investigation__c();
            fiv2.Case__c = cs2.Id;
            fiv2.Address_Line_1__c = 'Test Address1';
            fiv2.Address_Line_2__c = 'Test Address2';
            fiv2.City__c = 'Test City';
            fiv2.Pin_Code__c ='123456';
            fiv2.State__c =  'Test State';
            fiv2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Permanent').getRecordTypeId();
            insert fiv2;
            
			case cs3 = new case();
            cs3.Loan_Application__c = parentOpp.Id;
            cs3.Subject='FI test Case Office';
            cs3.Status = 'FI-Unassigned';
            cs3.Origin = 'Web';
            cs3.Applicant__c = applicant.Id;
            cs3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FI').getRecordTypeId();
            insert cs3; 
            
            CaseHistory ch3=new caseHistory();
            ch3.CaseId = cs3.id;
            ch3.Field= 'Subject';
            insert ch3;
            
            Field_Investigation__c fiv3 = new Field_Investigation__c();
            fiv3.Case__c = cs3.Id;
            fiv3.Address_Line_1__c = 'Test Address1';
            fiv3.Address_Line_2__c = 'Test Address2';
            fiv3.City__c = 'Test City';
            fiv3.Pin_Code__c ='123456';
            fiv3.State__c = 'Test State';
            fiv3.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
            insert fiv3; 
            cs3.Status = 'Completed';
            update cs3;
            Opportunity opfr1 = new Opportunity();
            opfr1.StageName = 'Qualification';
            opfr1.CloseDate = Date.newInstance(2021, 1, 11);
            opfr1.Name = 'testone-A';
            opfr1.Required_Loan_amount__c = 100000;
            opfr1.Parent_Loan_Application__c = parentOpp.Id;
            insert opfr1;
            
            cs2.Loan_Application__c = opfr1.Id;
            update cs2;
            
            Applicant__c apfr1 = new Applicant__c();
            apfr1.Opportunity__c = opfr1.Id;
            apfr1.Contact_number__c = '9743514830';
            apfr1.Applicant_Type__c = 'Borrower';
            insert apfr1;
            
            Vehicle_Detail__c vfr1 = new Vehicle_Detail__c();
            vfr1.Loan_Application__c = opfr1.Id;
            vfr1.Base_Price__c = 100000.00;
            vfr1.Ben_Code__c = 'testveh';
            insert vfr1; 
            
            
            Final_Term__c fgr1 = new Final_Term__c();
            fgr1.CRM_IRR__c = null;
            fgr1.Loan_Application__c = opfr1.Id;
            fgr1.Holiday_period__c='30';
            fgr1.Loan_Amount__c = null;
            fgr1.Tenure__c = null;
            //   fgr1.FIwaiver_offAddress__c = 'Not Waived';
            fgr1.EMI_Amount__c = 10000;
            insert fgr1;
            String docRecordTypeId = Schema.getGlobalDescribe().get('Documents__c').getDescribe().getRecordTypeInfosByName().get('Other Documents').getRecordTypeId();
            
            ContentVersion content=new ContentVersion(); 
            content.Title='Header_Picture1'; 
            content.PathOnClient='/' + content.Title + '.jpg'; 
            Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
            content.VersionData=bodyBlob; 
            content.origin = 'H';
            insert content;
            
            Documents__c document1 = new Documents__c();
            document1.Name = 'test document';
            document1.Opportunity_Relation__c = parentOpp.Id;
            document1.Document_Type__c = 'Signature';
            document1.is_Active__c = true;
            document1.RecordTypeId = docRecordTypeId;
            document1.Applicant__c = applicant.Id;
            insert document1;
            
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = document1.Id;
            contentlink.contentdocumentid = [SELECT contentdocumentid FROM contentversion WHERE Id =: content.Id].contentdocumentid;
            contentlink.ShareType = 'I';
            contentlink.Visibility = 'AllUsers'; 
            insert contentlink;

            IND_GetFinalOfferWithoutSharing.parentFICaseWrapper wrapperObj = new IND_GetFinalOfferWithoutSharing.parentFICaseWrapper();
            wrapperObj.parentLoanAppId = parentOpp.Id;
            
            Test.startTest();
            IND_GetFinalOfferWithoutSharing.cloneParentFICasetoChildApplication(opfr1.Id, JSON.serialize(wrapperObj));
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
}