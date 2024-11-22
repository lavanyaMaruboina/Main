@RestResource(urlMapping='/msil-lead/*')
global class MSILRestCallout {
    @HttpPut
    global static void insertLoanApplication() {
        
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;        
        MSILRequestClass msilObj = new MSILRequestClass();
        String jsonbody = req.requestBody.toString(); 
        system.debug('jsonbody'+jsonbody);
        String oppId;
        try{  
            msilObj = msilObj.parseJSON(jsonbody);
            system.debug('msilObj'+msilObj);
            oppId = convertToObject(msilObj);
            system.debug('oppId******'+oppId);
            
            if(oppId != null){
                RestContext.response.statusCode = 200; 
                String sucdec = oppId + ' Loan Application Created Successfully';
                String sucmsg = '{ "response": { "status": "SUCCESS", "respDesc": "'+sucdec+'"} }';
                RestContext.response.responseBody = Blob.valueOf(sucmsg);
                IntegrationUtilities.createIntegrationLogger(jsonbody, msilObj.toString(), 'Record created', '', 'MSIL Request', '', oppId, System.Label.Success);
            }
        }catch(Exception ex){
            system.debug('exception --' + ex.getMessage());
            RestContext.response.statusCode = 400;
           
            String deserror = 'Something went wrong ---> '+ex.getMessage()+ ' Exception line number-->'+ex.getLineNumber();
            String error = '{ "response": { "status": "FAILED", "respDesc": "'+deserror+'"} }';
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(error));
           	RestContext.response.addHeader('Content-Type', 'application/json');
            IntegrationUtilities.createIntegrationLogger(jsonbody, msilObj.toString(), error, '', 'MSIL Request', '', oppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('MSILRestCallout', 'insertLoanApplication', System.Label.Apex, ex,oppId);
            throw ex;
        }
    }
    public static String convertToObject(MSILRequestClass msilObj){
        Opportunity oppObj = new Opportunity();
        Applicant__c appObj = new Applicant__c();
        Vehicle_Detail__c vehiObj = new Vehicle_Detail__c();
        Product2 productObj = new Product2();
        Manufacturer__c manuObj = new Manufacturer__c();
        Benefi__c beneObj = new Benefi__c();
        Bl_Code_Details__c blCodObj = new Bl_Code_Details__c();
        Documents__c docObj = new Documents__c();
        Income_Details__c incObj = new Income_Details__c(); //CISP-2410
        
        //applicationInfo JSON parse 
        MSILRequestClass.MetaData metaObj = new MSILRequestClass.MetaData();
        metaObj.applicationInfo = msilObj.MetaData.ApplicationInfo;
        OppObj.IModuleId__c = metaObj.applicationInfo.IIModuleID;
        oppObj.LeadSource = metaObj.applicationInfo.Lead_Sourced_Through;
        oppObj.agentId__c =  metaObj.applicationInfo.agentId;
        oppObj.Agent_BL_code__c = metaObj.applicationInfo.agentBLCode;
        
        //leadExistingRelationship JSON parse
        MSILRequestClass.LeadExistingRelationship leadExistObj = new MSILRequestClass.LeadExistingRelationship();
        leadExistObj = msilObj.LeadExistingRelationship;
        vehiObj.Vehicle_type__c = (leadExistObj.leadVehicleType == 'N')?'New':'Used';
        oppObj.Vehicle_type__c = (leadExistObj.leadVehicleType == 'N')?'New':'Used'; //CISP-2394
        //CISP-2352
        List<Product2> proMake = [Select Id,name,Make_Code__c from  product2 where Make_Code__c  =: leadExistObj.MakeCode AND isactive = true  AND Type__c = 'Make' LIMIT 1];
        if(proMake.size()>0){
            vehiObj.Make__c = proMake[0].Name;
            vehiObj.Make_Code__c = proMake[0].Make_Code__c; //CISP-3425
        }
        List<Product2> proModel = [Select Id,name,Model_Code__c from  product2 where Model_Code__c   =: leadExistObj.ModelCode AND isactive = true  AND Type__c = 'Model' LIMIT 1];
        if(proModel.size()>0){
            vehiObj.Model__c = proModel[0].Name;
            vehiObj.Model_Code__c = proModel[0].Model_Code__c;//CISP-3425
        }
        List<Product2> proVariant = [Select Id,name,Variant_Code__c from  product2 where Variant_Code__c   =: leadExistObj.VariantCode AND isactive = true  AND Type__c = 'Variant' LIMIT 1];
        if(proVariant.size()>0){
            vehiObj.Variant__c = proVariant[0].Name;
            vehiObj.Variant_Code__c = proVariant[0].Variant_Code__c;//CISP-3425
        }
        //CISP-2352 
      
        OppObj.Product_Type__c = leadExistObj.Product == 'C' ? 'Passenger Vehicles':'Two Wheeler';
        vehiObj.Product__c = leadExistObj.Product == 'C' ? 'Passenger Vehicles':'Two Wheeler';
        vehiObj.Variant_Code__c = leadExistObj.VariantCode;
        
        String proTYpe = OppObj.Product_Type__c == 'Passenger Vehicles' ? 'PV' : 'TW';//CISP-2641
        //CISP-2395
        List<Account> accountList = [SELECT Id,BranchBLCode__c FROM Account WHERE BranchBLCode__c =:metaObj.applicationInfo.agentBLCode AND BranchBLCode__c!= null AND  Product_type__c =:oppObj.Vehicle_type__c AND type =: proTYpe];//CISP-2641
        if(accountList.size()>0){
            oppObj.AccountId = accountList[0].Id;
        }else{
            String jsonResponse = '{"response": {"message": "Agent BLCode not match with any Account"}}';
            responseSet(jsonResponse);
        }//CISP-2395
        
        //LeadDetails parse json
        MSILRequestClass.LeadDetails leadObj = new  MSILRequestClass.LeadDetails();
        leadObj = msilObj.LeadDetails;
        OppObj.Loan_amount__c = String.valueof((Integer)Double.valueOf(leadObj.FinanceAmount));
        oppObj.Contact_number__c = leadObj.Mobile;
        appObj.Name = leadObj.Name;
        vehiObj.Ben_Code__c = leadObj.DealerData.Ben_code;
        
        //Get Marital_status API name 
        Schema.DescribeFieldResult fieldResult = Applicant__c.Marital_status__c.getDescribe();
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
        Map<String,String> statusApiToLabelMap = new Map<String,String>();
        For(Schema.PicklistEntry sp : values){
            statusApiToLabelMap.put(sp.getLabel(),sp.getValue());
        }

        
       	//userDetail parse json
        MSILRequestClass.MSIL_UserData msilUserObj = new MSILRequestClass.MSIL_UserData();
        msilUserObj = msilObj.MSIL_UserData;
        docObj.Salutation__c = msilUserObj.Salutation;
        docObj.First_Name__c = msilUserObj.FirstName;
        docObj.Last_Name__c = msilUserObj.LastName;
        docObj.Gender__c = msilUserObj.Gender;
        //CISP-1219
        appObj.Customer_First_Name__c = msilUserObj.FirstName;
        appObj.Customer_Last_Name__c = msilUserObj.LastName;
        OppObj.Applicant_Name__c = msilUserObj.FirstName + ' ' + msilUserObj.LastName;//CISP-2693
        appObj.Gender__c = msilUserObj.Gender;
        appobj.Contact_number__c = msilUserObj.Mobile;
        //CISP-1219
        docObj.KYC_DOB__c = msilUserObj.DateofBirth;
        appObj.Salaried_Self_employed__c = msilUserObj.Profession;
        incObj.Is_Salaried__c = msilUserObj.Profession == 'Salaried' ? true:false; //CISP-2410
        incObj.Is_Self_Employed__c = msilUserObj.Profession == 'Self employed' || msilUserObj.Profession == 'Self-Employed'? true:false;//CISP-2410
        incObj.Salaried_Self_employed__c = msilUserObj.Profession;//CISP-2410
        docObj.PAN_No__c = msilUserObj.PANNumber;
        appObj.Email_Id__c = msilUserObj.email;
        appObj.Marital_status__c = statusApiToLabelMap.get(msilUserObj.MaritalStatus);
        docObj.KYC_Address_Line_1__c = msilUserObj.Curr_Resi_Address_Line_1;
        docObj.KYC_Address_Line_2__c = msilUserObj.Curr_Resi_Address_Line_2;
        docObj.KYC_City__c = msilUserObj.Curr_Resi_City;
        docObj.KYC_Pin_Code__c = msilUserObj.Curr_Resi_Pin_code;
        docObj.KYC_State__c = msilUserObj.Curr_Resi_State;
        appObj.Office_Address_Line_1__c = msilUserObj.Off_Address_Line_1;
        appObj.Office_Address_Line_2__c = msilUserObj.Off_Address_Line_2;
        appObj.Office_City__c = msilUserObj.Off_City;
        appObj.Office_PinCode__c = msilUserObj.Off_Pin_code;
        appObj.Office_State__c = msilUserObj.Off_State;
        OppObj.Required_ROI__c = msilUserObj.FinanceROI; // CISP-2358
        if(OppObj.LeadSource == System.Label.Mahindra_Custom_Lead_API_Value || OppObj.LeadSource == System.Label.Mahindra_PreA_Lead_API_Value){ //CISP-21374
            OppObj.Required_Tenure__c = msilUserObj.FinanceVehicleTenor;
        }else{
            OppObj.Required_Tenure__c= msilUserObj.FinanceVehicleTenor * 12; //CISP 2357 (Tenure converted to months)
        }
        
        Opportunity opp = createOpportunity(OppObj);
        
        if(opp.agentId__c == ''){
            String jsonResponse = '{"response": {"message": "AgentId not found"}}';
            responseSet(jsonResponse);
        }
        if(vehiObj.Ben_Code__c == ''){
            String jsonResponse = '{"response": {"message": "BenCode not found"}}';
            responseSet(jsonResponse);
        }
        //insert opportunity
            if(Schema.sObjectType.Opportunity.isCreateable()){
                Set<String> agentCombinations = new Set<String>();
                if(opp.agentId__c != null){
                    agentCombinations.add(opp.agentId__c + '_BE');
                    agentCombinations.add(opp.agentId__c + '_CS');
                }
                // String agentId = '%' + opp.agentId__c + '%';
                //CISP-1219 Changed username to User_Id__c
                List<User> userList = new List<User>();
                if(agentCombinations.size() > 0){
                    userList = [SELECT Id,Maker_Id__c,User_Id__c FROM User WHERE User_Id__c IN : agentCombinations LIMIT 1];
                }
                if(!userList.isEmpty()){
                    opp.OwnerId = userList[0].Id; 
                }else{
                    String jsonResponse = '{"response": {"message": "AgentId not match with any user name"}}';
                    responseSet(jsonResponse);
                }
                
            }
        List<Benefi__c> beneObjList = [Select Id, ben_code__c,Name from benefi__c where ben_code__c =:vehiObj.Ben_Code__c ];
        if(beneObjList.size()>0){
            vehiObj.Dealer_Sub_dealer_name__c =  beneObjList[0].Name; //CISP-2353
        }else{
            String jsonResponse = '{"response": {"message": "Ben code not match with any record."}}';
            responseSet(jsonResponse);
        }
        system.debug('RestContext.response.statusCode--'+RestContext.response.statusCode);
        if(RestContext.response.statusCode != 400){
            insert opp;
            Set<Id> oppIdSet = new Set<Id>{opp.Id};
                //populate Lead Number
            UniqueLeadNumberHandler.updateLeadSeqNumber(oppIdSet);
            //applicant object insert
            appObj.Opportunity__c = oppObj.Id;
            appObj.Applicant_Type__c = 'Borrower'; //CISP-1219
            appObj.Journey_Stage__c = 'User Details'; //CISP-2340;
            insert appObj;
            
            incObj.Applicant__c = appObj.Id; //CISP-2410
            insert incObj; //CISP-2410
            
            //Vehicle object insert 
            vehiObj.Loan_Application__c = oppObj.Id;
            insert vehiObj;
        }
            	            
        if(OppObj.Id != null){
            return OppObj.Id;
        }
        return null;
    }
    private static Opportunity createOpportunity(Opportunity oppObj){
        OppObj.Name = 'Test Lead';
        OppObj.StageName = 'Loan Initiation';
        oppObj.Sub_Stage__c = 'User Details';
        OppObj.LastStageName__c = 'Loan Initiation';
        OppObj.CloseDate = System.today().addMonths(1);
        return oppObj;
    }
    private static void responseSet(String jsonResponse){
        RestContext.response.statusCode = 400;
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(jsonResponse));
        RestContext.response.addHeader('Content-Type', 'application/json');
    }
}