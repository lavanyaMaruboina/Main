@RestResource(urlMapping='/getDealers/*')
/**
* Class: DealerMasterAPI
* Description: Class to return dealer data.
* Test class:
*/
global with sharing class DealerMasterAPI {
    /**
     * Method: getDealerMaster
     * Description: Method to get dealer details based on request parameter
     * return void;
     */
    @HttpPost
    global static List<DealerDataResponse> getDealerMaster() {
        //Request
        RestRequest req  = RestContext.request;
        String stringRequest = req.requestBody.toString();
        
        DealerDataRequest request = (DealerDataRequest) JSON.deserialize(stringRequest, DealerDataRequest.class);
        system.debug(request);
        Map<string,Benefi__c> beneficiacyManufacturerMap  = new Map<string,Benefi__c>();
        Decimal pincode = Decimal.ValueOf(request.Pin_Code);
        /*
        string productType=  request.Product_Type.contains('Passenger Vehicle')?'Passenger Vehicles':request.Product_Type;
        system.debug(productType);
        */
       
        try {
            Opportunity loanApplicantionObj = [Select Id,Vehicle_Type__c,Vehicle_Sub_Category__c From Opportunity Where Id =: request.Loan_Application_Id With SECURITY_ENFORCED];
            List<Beneficiary_BlCode__c> benBLCodeRefDealerList = new List<Beneficiary_BlCode__c>();
            List<Product2> manufacturerList = new List<Product2>();
             //Based on Pincode get the bl code set 
             set<string> blCodeSet = new set<string>();
             
             for( D2C_BE_Master__c instofBeMaster : [SELECT ID,Pin_Code__c,BL_Code__c FROM D2C_BE_Master__c WHERE Pin_Code__c =:pincode WITH SECURITY_ENFORCED]){
                blCodeSet.add(instofBeMaster.BL_Code__c);
             }
            //Get Current Products Manufacturer
      
            manufacturerList= [select id,Product_Type__c, Manufacturer__c from Product2 where Model_Code__c =:request.Model_Code AND Type__c='Model' AND Product_Type__c Like: request.Product_Type WITH SECURITY_ENFORCED];
              system.debug('manufacturerList '+manufacturerList);
          
            
            if(!manufacturerList.isEmpty() && loanApplicantionObj.Vehicle_Type__c == 'New'){
                benBLCodeRefDealerList = [SELECT id, Ben_code__c,Ben_code__r.Grade__c, Ben_code__r.name, Ben_code__r.Ben_code__c from Beneficiary_BlCode__c 
                where Ben_code__c in (SELECT Beneficiary_Master__c FROM Beneficiary_Manufacturer__c WHERE Manufacturer__c= :manufacturerList[0].Manufacturer__c) 
                AND Bl_Code_Details__r.Bl_Code__c IN :blCodeSet and Ben_code__r.Beneficiary__c = 'DLR' and Ben_code__r.Status_Flag__c = 'L' 
                and (Ben_code__r.Used_Flag__c != 'U' OR Ben_code__r.Used_Flag__c = Null) ORDER BY Ben_code__r.name ASC];

            }else if(!manufacturerList.isEmpty() ){//&& (loanApplicantionObj.Vehicle_Sub_Category__c == 'UPD' || loanApplicantionObj.Vehicle_Sub_Category__c == 'UEB')
                System.debug('UPD, UEB');
                benBLCodeRefDealerList = [SELECT id, Ben_code__c,Ben_code__r.Grade__c, Ben_code__r.name, Ben_code__r.Ben_code__c from Beneficiary_BlCode__c where Ben_code__c in (SELECT Beneficiary_Master__c FROM Beneficiary_Manufacturer__c WHERE Manufacturer__c= :manufacturerList[0].Manufacturer__c) AND Bl_Code_Details__r.Bl_Code__c IN :blCodeSet and Ben_code__r.Beneficiary__c = 'DLR' AND (Ben_code__r.Dealership_Nature__c = 'MDR' OR Ben_code__r.Dealership_Nature__c = 'EDR') and Ben_code__r.Status_Flag__c = 'L' and (Ben_code__r.Used_Flag__c != 'N' OR Ben_code__r.Used_Flag__c = Null) WITH SECURITY_ENFORCED ORDER BY Ben_code__r.name ASC];
            }

            Map<String, Beneficiary_BlCode__c> uniqueBenefi_BLRecords = new Map<String, Beneficiary_BlCode__c> ();

            for(Beneficiary_BlCode__c beneBL : benBLCodeRefDealerList) {
                if(!uniqueBenefi_BLRecords.containsKey(beneBL.Ben_code__r.Ben_code__c)) {
                    uniqueBenefi_BLRecords.put(beneBL.Ben_code__r.Ben_code__c, beneBL);
                } 
            }

            if(!uniqueBenefi_BLRecords.isEmpty()) {
                benBLCodeRefDealerList = uniqueBenefi_BLRecords.values();
            }

            system.debug('benBLCodeRefDealerList '+benBLCodeRefDealerList);
            Set<Id> dealerIds = new Set<Id>();
            Map<String,Beneficiary_BlCode__c>  belcodeVsBEmap = new Map<String,Beneficiary_BlCode__c>();
            
            if(!benBLCodeRefDealerList.isEmpty()){
                for(Beneficiary_BlCode__c dealer : benBLCodeRefDealerList){
                    dealerIds.add(dealer.Ben_code__c);
                    belcodeVsBEmap.put(dealer.Ben_code__r.Ben_code__c,dealer);
                }
            }
            Map<Id, Benefi__c> oemDealers = new Map<Id, Benefi__c>();
            if(!dealerIds.isEmpty()){
                
                 for(Benefi__c instofBenfi : [SELECT Id, Ben_code__c, Name from Benefi__c
                 WHERE Id in (SELECT Beneficiary_Master__c from Beneficiary_Manufacturer__c
                 WHERE Manufacturer__r.Manufacturer_code__c = 'U01')
                 AND Beneficiary__c = 'DLR' AND Status_Flag__c = 'L' AND Id IN: dealerIds WITH SECURITY_ENFORCED ]  ){
                    beneficiacyManufacturerMap.put(instofBenfi.Ben_code__c,instofBenfi);
                 }
            }
            List<DealerDataResponse> dealerResponseList = new List<DealerDataResponse>();

           if(!benBLCodeRefDealerList.isEmpty()){

                for(Beneficiary_BlCode__c dealer : benBLCodeRefDealerList){
                    DealerDataResponse instofResponse = new DealerDataResponse();
                    instofResponse.dealerID = dealer.Ben_code__c;
                    instofResponse.dealerName = dealer.Ben_code__r.name ;
                    instofResponse.benCode = dealer.Ben_code__r.Ben_code__c;
                    instofResponse.dealerCategorization = String.isNotBlank(dealer.Ben_code__r.Grade__c) ? dealer.Ben_code__r.Grade__c : 'Others';

                    if(!beneficiacyManufacturerMap.isEmpty() && beneficiacyManufacturerMap.containsKey(dealer.Ben_code__r.Ben_code__c)){ 
                        instofResponse.Type_Of_Dealer = 'OEM' ;
                    }else{
                        instofResponse.Type_Of_Dealer = 'Non-OEM' ;
                    }
                    dealerResponseList.add(instofResponse);
                }
            }
            system.debug(dealerResponseList);
            IntegrationUtilities.createIntegrationLogger(stringRequest, stringRequest, JSON.serialize(dealerResponseList), JSON.serialize(dealerResponseList), 'getDealers', null,request.Loan_Application_Id,System.Label.Success);
            if(!dealerResponseList.isEmpty()){
                return dealerResponseList;
            } else {
                throw new CalloutException('No Dealers found for given parameters.');
            }
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('DealerMasterAPI', 'getDealerMaster', 'Apex', e);
            throw new CalloutException(e.getMessage() + e.getStackTraceString());
        }
    }

    public class DealerDataRequest{
        public String Product_Type;
        public String Vehicle_Type;
        public String Make_Code;
        public String Model_Code;
        public String Variant_Code;
        public String Agent_BL_Code;
        public String Pin_Code;
        public String Loan_Application_Id;
    }
    global class DealerDataResponse{
        global String dealerID;
        global String dealerName;
        global String benCode;
        global String dealerCategorization;
        global String Type_Of_Dealer; //'OEM' || 'Non-OEM'
    }
   
}