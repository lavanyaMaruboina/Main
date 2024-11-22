@isTest
public class IND_CAMPortfolioResponseTest {

    @isTest
    public static void verifyIND_CAMPortfolioResponse(){
        IND_CAMPortfolioResponse.Response objResp = new  IND_CAMPortfolioResponse.Response();
        IND_CAMPortfolioResponse.Content objContent = new IND_CAMPortfolioResponse.Content();
        IND_CAMPortfolioResponse.DPD_DT objdpd = new IND_CAMPortfolioResponse.DPD_DT();
       
        IND_CAMPortfolioResponse.PANA_DT objpana = new IND_CAMPortfolioResponse.PANA_DT();
        IND_CAMPortfolioResponse.CIBIL_Dt objcibil = new IND_CAMPortfolioResponse.CIBIL_Dt();
        IND_CAMPortfolioResponse.Non_IBL_Exposure objnonexposure = new IND_CAMPortfolioResponse.Non_IBL_Exposure();
        IND_CAMPortfolioResponse.CIBIL_Suit_Filed objcibilsuitfiled = new IND_CAMPortfolioResponse.CIBIL_Suit_Filed();
        
        
        
        System.assertEquals(objdpd.Deal_No, null);
        System.assertEquals(objdpd.Curr_Month, null);
        System.assertEquals(objdpd.Advance, null);
        System.assertEquals(objdpd.OverDue, null);
        System.assertEquals(objdpd.SOH, null);
        System.assertEquals(objdpd.One_Month, null);
        System.assertEquals(objdpd.Two_Month, null);
        System.assertEquals(objdpd.Three_Month, null);
        System.assertEquals(objdpd.Four_Month, null);
        System.assertEquals(objdpd.Five_Month, null);
        System.assertEquals(objdpd.Six_Month, null);
        System.assertEquals(objdpd.Seven_12Month, null);
        System.assertEquals(objdpd.Above_12Month, null);
        System.assertEquals(objdpd.OD_Category, null);
        System.assertEquals(objdpd.Ageing, null);
        System.assertEquals(objdpd.DPD, null);
        System.assertEquals(objdpd.Status_Flag, null);
        System.assertEquals(objdpd.Deal_Date, null);
        
        System.assertEquals(objContent.PANA_DT, null);
        System.assertEquals(objContent.DPD_DT, null);
        
        System.assertEquals(objpana.Segment, null);
        System.assertEquals(objpana.Name, null);
        System.assertEquals(objpana.Year, null);
        System.assertEquals(objpana.Tot_Deals, null);
        System.assertEquals(objpana.Adv_Nos, null);
        System.assertEquals(objpana.Adv_Amt, null);
        System.assertEquals(objpana.NoDue_Nos, null);
        System.assertEquals(objpana.NoDue_LOS, null);
        System.assertEquals(objpana.STD1_Nos, null);
        System.assertEquals(objpana.STD1_LOS, null);
        System.assertEquals(objpana.STD2_Nos, null);
        System.assertEquals(objpana.STD2_LOS, null);
        System.assertEquals(objpana.STD3_Nos, null);
        System.assertEquals(objpana.STD3_LOS, null);
        System.assertEquals(objpana.NPA1_Nos, null);
        System.assertEquals(objpana.NPA1_LOS, null);
        System.assertEquals(objpana.NPA2_Nos, null);
        System.assertEquals(objpana.NPA2_LOS, null);
        System.assertEquals(objpana.NPA3_Nos, null);
        System.assertEquals(objpana.NPA3_LOS, null);
        System.assertEquals(objpana.NPAA_Nos, null);
        System.assertEquals(objpana.NPAA_LOS, null);
        System.assertEquals(objpana.Tot_Nos, null);
        System.assertEquals(objpana.Tot_LOS, null);
        
        System.assertEquals(objcibil.CIC_No, null);
        System.assertEquals(objcibil.Account_Segment_Tag, null);
        System.assertEquals(objcibil.Reporting_Member_ShortName, null);
        System.assertEquals(objcibil.Account_Number, null);
        System.assertEquals(objcibil.Account_Type, null);
        System.assertEquals(objcibil.Owenership_Indicator, null);
        System.assertEquals(objcibil.DateOpened_Or_Disbursed, null);
        System.assertEquals(objcibil.Date_Of_Last_Payment, null);
        System.assertEquals(objcibil.Date_Closed, null);
        System.assertEquals(objcibil.Date_Reported, null);
        System.assertEquals(objcibil.HighCredit_Or_SanctionedAmount, null);
        System.assertEquals(objcibil.CurrentBalance, null);
        System.assertEquals(objcibil.AmountOverdue, null);
        System.assertEquals(objcibil.Payment_History1, null);
        System.assertEquals(objcibil.Payment_History2, null);
        System.assertEquals(objcibil.Payment_History_StartDate, null);
        System.assertEquals(objcibil.Payment_History_EndDate, null);
        System.assertEquals(objcibil.SuitFiledOrWilfulDefault, null);
        System.assertEquals(objcibil.WrittenOffAndSettled, null);
        System.assertEquals(objcibil.ValueOfCollateral, null);
        System.assertEquals(objcibil.TypeOfCollateral, null);
        System.assertEquals(objcibil.CreditLimit, null);
        System.assertEquals(objcibil.CashLimit, null);
        System.assertEquals(objcibil.RateOfInterest, null);
        System.assertEquals(objcibil.RepaymentTenure, null);
        System.assertEquals(objcibil.EmiAmount, null);
        System.assertEquals(objcibil.PaymentFrequency, null);
        System.assertEquals(objcibil.ActualPaymentAmount, null);
        System.assertEquals(objcibil.WrittenoffAmountTotal, null);
        System.assertEquals(objcibil.WrittenoffAmountPrincipal, null);
        System.assertEquals(objcibil.SettlementAmount, null);
        
        System.assertEquals(objnonexposure.Application_No, null);
        System.assertEquals(objnonexposure.CIC_No, null);
        System.assertEquals(objnonexposure.Account_Type, null);
        System.assertEquals(objnonexposure.Account_Type_Desc, null);
        System.assertEquals(objnonexposure.Ownership, null);
        System.assertEquals(objnonexposure.OpenDate, null);
        System.assertEquals(objnonexposure.LastPaymentDate, null);
        System.assertEquals(objnonexposure.HighCredit, null);
        System.assertEquals(objnonexposure.CurrentBalance, null);
        System.assertEquals(objnonexposure.AmountOverdue, null);
        System.assertEquals(objnonexposure.WrittenoffAmountTotal, null);
        System.assertEquals(objnonexposure.ReasonforOverdue, null);
        System.assertEquals(objnonexposure.FinancierCode, null);
        System.assertEquals(objnonexposure.FinanicerName, null);
        System.assertEquals(objnonexposure.Maker_Id, null);
        System.assertEquals(objnonexposure.Maker_Date, null);
        System.assertEquals(objnonexposure.Expousure_Flag, null);
        System.assertEquals(objnonexposure.Customer, null);

        System.assertEquals(objcibilsuitfiled.Application_No, null);
        System.assertEquals(objcibilsuitfiled.Entity_Type, null);
        System.assertEquals(objcibilsuitfiled.Type, null);
        System.assertEquals(objcibilsuitfiled.CIC_No, null);
        System.assertEquals(objcibilsuitfiled.Score, null);
        System.assertEquals(objcibilsuitfiled.HighCredit_Or_SanctionedAmount, null);
        System.assertEquals(objcibilsuitfiled.Current_Balance, null);
        System.assertEquals(objcibilsuitfiled.RecentDate, null);
        System.assertEquals(objcibilsuitfiled.OldestDate, null);
        System.assertEquals(objcibilsuitfiled.Amount_Overdue, null);
        System.assertEquals(objcibilsuitfiled.CibilDecision, null);
        System.assertEquals(objcibilsuitfiled.Month_Overdue, null);
        System.assertEquals(objcibilsuitfiled.NoOfEnLtSixMon, null);
        System.assertEquals(objcibilsuitfiled.WrittenoffAmountTotal, null);
        System.assertEquals(objcibilsuitfiled.SuitFiledOrWilfulDefault, null);
        System.assertEquals(objcibilsuitfiled.CRIFScore_Desc, null);
        
       // System.assertEquals(objContent.Transaction_Id, null);
        objResp.content = new List<IND_CAMPortfolioResponse.Content>{objContent};
            objResp.respDesc = '';
        objResp.status = '';
        
        IND_CAMPortfolioResponse result = new IND_CAMPortfolioResponse();
        result.response = objResp;
        System.assert(result.response.status == '');
    }
    

}