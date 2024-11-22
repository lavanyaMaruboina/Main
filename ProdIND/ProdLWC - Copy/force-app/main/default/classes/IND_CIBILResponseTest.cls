@isTest
public class IND_CIBILResponseTest {

      @isTest
    public static void verifyIND_CIBILResponse(){
        IND_CIBILResponse.Data objRes =new IND_CIBILResponse.Data();
        System.assertEquals(objRes.IsSuccess, null);
        System.assertEquals(objRes.StatusCode, null);
        System.assertEquals(objRes.StatusDescription, null);
        System.assertEquals(objRes.Cibil_Report_URl, null);
        System.assertEquals(objRes.Application_Cibil_Details, null);
        System.assertEquals(objRes.Cibil_LoanAccount_Details, null);
        System.assertEquals(objRes.Cibil_TimeLine_Details, null);
        System.assertEquals(objRes.Cibil_ADE_Details, null);
        System.assertEquals(objRes.OverDueDocs_Details, null);
        System.assertEquals(objRes.Equifax_Generated, null);
        System.assertEquals(objRes.Equifax_Report_URl, null);
         IND_CIBILResponse.Application_Cibil_Details objRes1 =new IND_CIBILResponse.Application_Cibil_Details();
        System.assertEquals(objRes1.Lead_Id, null);
        System.assertEquals(objRes1.Entity_Type, null);
         System.assertEquals(objRes1.Type, null);
         System.assertEquals(objRes1.CIC_No, null);
         System.assertEquals(objRes1.Score, null);
         System.assertEquals(objRes1.HighCredit_Or_SanctionedAmount, null);
         System.assertEquals(objRes1.Current_Balance, null);
         System.assertEquals(objRes1.RecentDate, null);
         System.assertEquals(objRes1.OldestDate, null);
         System.assertEquals(objRes1.Amount_Overdue, null);
         System.assertEquals(objRes1.CibilDecision, null);
         System.assertEquals(objRes1.Month_Overdue, null);
         System.assertEquals(objRes1.NoOfEnLtSixMon, null);
         System.assertEquals(objRes1.WrittenoffAmountTotal, null);
         System.assertEquals(objRes1.SuitFiledOrWilfulDefault, null);
         System.assertEquals(objRes1.CRIFScore_Desc, null);
        IND_CIBILResponse.Cibil_LoanAccount_Details objRes2 =new IND_CIBILResponse.Cibil_LoanAccount_Details();
         System.assertEquals(objRes2.Lead_Id, null);
        System.assertEquals(objRes2.CIC_No, null);
        System.assertEquals(objRes2.Account_Type, null);
        System.assertEquals(objRes2.Account_Type_Desc, null);
        System.assertEquals(objRes2.Ownership, null);
        System.assertEquals(objRes2.OpenDate, null);
        System.assertEquals(objRes2.LastPaymentDate, null);
        System.assertEquals(objRes2.HighCredit, null);
         System.assertEquals(objRes2.CurrentBalance, null);
         System.assertEquals(objRes2.AmountOverdue, null);
         System.assertEquals(objRes2.WrittenoffAmountTotal, null);
         System.assertEquals(objRes2.ReasonforOverdue, null);
         System.assertEquals(objRes2.FinancierCode, null);
        System.assertEquals(objRes2.FinanicerName, null);
        System.assertEquals(objRes2.Maker_Id, null);
        System.assertEquals(objRes2.Maker_Date, null);
        System.assertEquals(objRes2.Expousure_Flag, null);
        System.assertEquals(objRes2.Enquiry_Amount, null);
        
        
        
        
        
            
       }
    
        
    }