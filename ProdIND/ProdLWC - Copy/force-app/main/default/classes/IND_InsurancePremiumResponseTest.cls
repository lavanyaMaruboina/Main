@isTest
public class IND_InsurancePremiumResponseTest {
    
      @isTest
    public static void verifyIND_InsurancePremiumResponse(){
         IND_InsurancePremiumResponse obj = new IND_InsurancePremiumResponse();
      
        obj.Application_No= '';
        obj.Vehicle_ID= '';
        // obj.Premium= '';
        // obj.LHC= '';
        List<IND_InsurancePremiumResponse.Premium_Details> proDetailList = new List<IND_InsurancePremiumResponse.Premium_Details>();
        IND_InsurancePremiumResponse.Premium_Details proDetailobj = new IND_InsurancePremiumResponse.Premium_Details();
        proDetailobj.Ins_Product = '';
        proDetailobj.Plan_Code = '';
        proDetailobj.Premium = '';
        proDetailList.add(proDetailobj);
        obj.Premium_Details = proDetailList;
        obj.Status_Flag= '';
        obj.Error_Code= '';
        obj.Error_Description= '';
   
       
        
        
     
    }

}