@isTest
public class IND_ExternalCustomerResponseTest {
@isTest
    public static void verifyIND_ExternalCustomerDedupeAPIResponse(){
        IND_ExternalCustomerDedupeAPIResponse.DtRECENTLEAD resDtRECENTLEAD=new IND_ExternalCustomerDedupeAPIResponse.DtRECENTLEAD();
        	System.assertEquals(resDtRECENTLEAD.SOURCE_CIC_NO, null);
         	System.assertEquals(resDtRECENTLEAD.MATCHED_CIC_NO, null);
        	System.assertEquals(resDtRECENTLEAD.MATCHED_LEAD_NAME, null);
         	System.assertEquals(resDtRECENTLEAD.MATCHED_LEAD_DATE, null);
        	System.assertEquals(resDtRECENTLEAD.MATCHED_SCORE, null);
         	System.assertEquals(resDtRECENTLEAD.MATCHED_CRITERIA, null);
        
        IND_ExternalCustomerDedupeAPIResponse.DtCFDCUSTBAS resDtCFDCUSTBAS=new IND_ExternalCustomerDedupeAPIResponse.DtCFDCUSTBAS();
        	System.assertEquals(resDtCFDCUSTBAS.SOURCE_CIC_NO, null);
         	System.assertEquals(resDtCFDCUSTBAS.MATCH_ECIF, null);
        	System.assertEquals(resDtCFDCUSTBAS.MATCHED_CUSTOMER_NAME, null);
         	System.assertEquals(resDtCFDCUSTBAS.MATCHED_CUSTOMER_CODE, null);
        	System.assertEquals(resDtCFDCUSTBAS.MATCHED_SCORE, null);
         	System.assertEquals(resDtCFDCUSTBAS.MATCHED_SOURCE, null);
        	System.assertEquals(resDtCFDCUSTBAS.MATCHED_CRITERIA, null);
         	System.assertEquals(resDtCFDCUSTBAS.CONFIDENCE_LEVEL, null);
        
        IND_ExternalCustomerDedupeAPIResponse.CustomerMaster resCustomerMaster=new IND_ExternalCustomerDedupeAPIResponse.CustomerMaster();
        	System.assertEquals(resCustomerMaster.Customer_Name, null);
         	System.assertEquals(resCustomerMaster.Customer_Type, null);
        	System.assertEquals(resCustomerMaster.Date_of_Birth, null);
         	System.assertEquals(resCustomerMaster.PAN_GIR_Number, null);
        	System.assertEquals(resCustomerMaster.Passport_Number, null);
         	System.assertEquals(resCustomerMaster.Voter_ID_Number, null);
        	System.assertEquals(resCustomerMaster.Driving_License_Number, null);
         	System.assertEquals(resCustomerMaster.Aadhaar_No, null);
        
         IND_ExternalCustomerDedupeAPIResponse.BeneficiaryAlert resBeneficiaryAlert=new IND_ExternalCustomerDedupeAPIResponse.BeneficiaryAlert();
        	System.assertEquals(resBeneficiaryAlert.Ben_code, null);
         	System.assertEquals(resBeneficiaryAlert.Beneficiary, null);
        	System.assertEquals(resBeneficiaryAlert.Status_Flag, null);
         	System.assertEquals(resBeneficiaryAlert.PAN_No, null);
        
         IND_ExternalCustomerDedupeAPIResponse.CustomerValidate resCustomerValidate=new IND_ExternalCustomerDedupeAPIResponse.CustomerValidate();
        	System.assertEquals(resCustomerValidate.CustomerCodeVal, null);
         	System.assertEquals(resCustomerValidate.CustomerMaster, null);
        	System.assertEquals(resCustomerValidate.CustomerStatus, null);
         	System.assertEquals(resCustomerValidate.Dealstatus, null);
        	System.assertEquals(resCustomerValidate.NPA, null);
         	System.assertEquals(resCustomerValidate.Restructure, null);
        	System.assertEquals(resCustomerValidate.Gecl, null);
         	System.assertEquals(resCustomerValidate.ARC, null);
        	System.assertEquals(resCustomerValidate.PanAlert, null);
        	System.assertEquals(resCustomerValidate.CINAlert, null);
         	System.assertEquals(resCustomerValidate.BeneficiaryAlert, null);

    	IND_ExternalCustomerDedupeAPIResponse.CustomerMaster_Z resCustomerMaster_Z=new IND_ExternalCustomerDedupeAPIResponse.CustomerMaster_Z();
        	System.assertEquals(resCustomerMaster_Z.CIC_No, null);
         	System.assertEquals(resCustomerMaster_Z.Matched_Customer_Code, null);
        	System.assertEquals(resCustomerMaster_Z.Rule_Matching_Fields, null);
         	System.assertEquals(resCustomerMaster_Z.Current_Parameter_Value, null);
        	System.assertEquals(resCustomerMaster_Z.Matched_Parameter_Value, null);
         	System.assertEquals(resCustomerMaster_Z.Matched_Score, null);
        	System.assertEquals(resCustomerMaster_Z.Rule_Field_Weightage, null);
         	System.assertEquals(resCustomerMaster_Z.Matched_Source, null);
        	System.assertEquals(resCustomerMaster_Z.Active_Flag, null);
        	System.assertEquals(resCustomerMaster_Z.Dedupe_Super_Match, null);
         	System.assertEquals(resCustomerMaster_Z.Dedupe_Super_Match_Score, null);
       	    System.assertEquals(resCustomerMaster_Z.Rule_Id, null);
        	System.assertEquals(resCustomerMaster_Z.Type, null);
         	System.assertEquals(resCustomerMaster_Z.PEP_Remarks, null);
        	System.assertEquals(resCustomerMaster_Z.Customer_Name, null);
         	System.assertEquals(resCustomerMaster_Z.Customer_Type, null);
        	System.assertEquals(resCustomerMaster_Z.Date_of_Birth, null);
         	System.assertEquals(resCustomerMaster_Z.PAN_GIR_Number, null);
        	System.assertEquals(resCustomerMaster_Z.Voter_ID_Number, null);
        	System.assertEquals(resCustomerMaster_Z.Driving_License_Number, null);
         	System.assertEquals(resCustomerMaster_Z.Aadhaar_No, null);
        	System.assertEquals(resCustomerMaster_Z.Passport_Number, null);
        
        IND_ExternalCustomerDedupeAPIResponse.CustomerMaster_Y resCustomerMaster_Y=new IND_ExternalCustomerDedupeAPIResponse.CustomerMaster_Y();
        	System.assertEquals(resCustomerMaster_Y.CIC_No, null);
         	System.assertEquals(resCustomerMaster_Y.Matched_Customer_Code, null);
        	System.assertEquals(resCustomerMaster_Y.Rule_Matching_Fields, null);
         	System.assertEquals(resCustomerMaster_Y.Current_Parameter_Value, null);
        	System.assertEquals(resCustomerMaster_Y.Matched_Parameter_Value, null);
         	System.assertEquals(resCustomerMaster_Y.Matched_Score, null);
        	System.assertEquals(resCustomerMaster_Y.Rule_Field_Weightage, null);
         	System.assertEquals(resCustomerMaster_Y.Matched_Score, null);
        	System.assertEquals(resCustomerMaster_Y.Rule_Field_Weightage, null);
        	System.assertEquals(resCustomerMaster_Y.Matched_Source, null);
         	System.assertEquals(resCustomerMaster_Y.Active_Flag, null);
       	    System.assertEquals(resCustomerMaster_Y.Dedupe_Super_Match, null);
        	System.assertEquals(resCustomerMaster_Y.Dedupe_Super_Match_Score, null);
         	System.assertEquals(resCustomerMaster_Y.Rule_Id, null);
        	System.assertEquals(resCustomerMaster_Y.Type, null);
         	System.assertEquals(resCustomerMaster_Y.PEP_Remarks, null);
        	System.assertEquals(resCustomerMaster_Y.Customer_Name, null);
         	System.assertEquals(resCustomerMaster_Y.Customer_Type, null);
        	System.assertEquals(resCustomerMaster_Y.Date_of_Birth, null);
        	System.assertEquals(resCustomerMaster_Y.PAN_GIR_Number, null);
         	System.assertEquals(resCustomerMaster_Y.Passport_Number, null);
        	System.assertEquals(resCustomerMaster_Y.Voter_ID_Number, null);
        	System.assertEquals(resCustomerMaster_Y.Driving_License_Number, null);
         	System.assertEquals(resCustomerMaster_Y.Aadhaar_No, null);
        
         IND_ExternalCustomerDedupeAPIResponse.Response resResponse=new IND_ExternalCustomerDedupeAPIResponse.Response();
        	System.assertEquals(resResponse.status, null);
         	System.assertEquals(resResponse.respDesc, null);
        	System.assertEquals(resResponse.content, null);
        
         IND_ExternalCustomerDedupeAPIResponse.CustomerValidate_Z resCustomerValidate_Z=new IND_ExternalCustomerDedupeAPIResponse.CustomerValidate_Z();
        	System.assertEquals(resCustomerValidate_Z.CustomerCodeVal, null);
         	System.assertEquals(resCustomerValidate_Z.CustomerMaster, null);
        	System.assertEquals(resCustomerValidate_Z.CustomerStatus, null);
         	System.assertEquals(resCustomerValidate_Z.Dealstatus, null);
        	System.assertEquals(resCustomerValidate_Z.NPA, null);
         	System.assertEquals(resCustomerValidate_Z.Restructure, null);
        	System.assertEquals(resCustomerValidate_Z.Gecl, null);
         	System.assertEquals(resCustomerValidate_Z.ARC, null);
        	System.assertEquals(resCustomerValidate_Z.PanAlert, null);
        	System.assertEquals(resCustomerValidate_Z.CINAlert, null);
         	System.assertEquals(resCustomerValidate_Z.BeneficiaryAlert, null);
        
          IND_ExternalCustomerDedupeAPIResponse.Content resContent=new IND_ExternalCustomerDedupeAPIResponse.Content();
			System.assertEquals(resContent.Data, null);
        	System.assertEquals(resContent.ErrorDesc, null);
        
        IND_ExternalCustomerDedupeAPIResponse.CustomerStatus resCustomerStatus=new IND_ExternalCustomerDedupeAPIResponse.CustomerStatus();
			System.assertEquals(resCustomerStatus.Cross_Dedupe_Match_Id, null);
        	System.assertEquals(resCustomerStatus.Active_Flag, null);
        
          IND_ExternalCustomerDedupeAPIResponse.Restructure resRestructure=new IND_ExternalCustomerDedupeAPIResponse.Restructure();
			System.assertEquals(resRestructure.Deal_Restructured, null);
        
         IND_ExternalCustomerDedupeAPIResponse.Dealstatus resDealstatus=new IND_ExternalCustomerDedupeAPIResponse.Dealstatus();
			System.assertEquals(resDealstatus.Deal_No, null);
        	System.assertEquals(resDealstatus.Status_Flag, null);
        
         IND_ExternalCustomerDedupeAPIResponse.ExternalDedupeResponse resExternalDedupeResponse=new IND_ExternalCustomerDedupeAPIResponse.ExternalDedupeResponse();
			System.assertEquals(resExternalDedupeResponse.DEDUPE_STATUS, null);
        	System.assertEquals(resExternalDedupeResponse.DtCFDCUSTBAS, null);
        	System.assertEquals(resExternalDedupeResponse.DtRECENTLEAD, null);
        	System.assertEquals(resExternalDedupeResponse.CustomerValidate, null);
        
        IND_ExternalCustomerDedupeAPIResponse.InternalDedupeResponse resInternalDedupeResponse=new IND_ExternalCustomerDedupeAPIResponse.InternalDedupeResponse();
			System.assertEquals(resInternalDedupeResponse.CustomerMaster, null);
        	System.assertEquals(resInternalDedupeResponse.CustomerValidate, null);
        
        IND_ExternalCustomerDedupeAPIResponse.Data resData=new IND_ExternalCustomerDedupeAPIResponse.Data();
			System.assertEquals(resData.ExternalDedupeResponse, null);
        	System.assertEquals(resData.InternalDedupeResponse, null);
        
           IND_ExternalCustomerDedupeAPIResponse result=new IND_ExternalCustomerDedupeAPIResponse();
			System.assertEquals(result.response, null);
    }
}