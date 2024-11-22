@RestResource(urlMapping='/v1/leadTransferAPI/')
global with sharing class  OLALeadTransferAPI {
    
    @HttpPost
    global static void uploadLeadDetails(){
        
        Boolean errorFlag = false;
        String errorMsg = '';
        RestRequest req  = RestContext.request;
        String leadPayload = req.requestBody.toString();
        ResponseWrapper response = new responseWrapper();
        RequestWrapper jsonParsed = new RequestWrapper();
        Opportunity loanApplication = new Opportunity();
        String decryptedReqBody = IntegrationUtilities.getDecryptedResponse(leadPayload,System.Label.privateKey,System.Label.ivkey);
        String encryptedResponse = '';
        String jdataRequest = '"JData":';
        Decimal minCRM;//OLA-276
        Decimal maxCRM;//OLA-276
        List<ROI_Master__c> roiMaster = new List<ROI_Master__c>();
        if(jsonParsed.leadSource=='OLA'){
                    roiMaster = [Select Id, Description__c, Max_Value__c, Min_Value__c from ROI_Master__c where Product__r.ProductCode = 'H' AND Vehicle_Category__c ='N' AND Description__c = 'CRM_IRR' and Product_Segment__c ='ESCOOTER' WITH SECURITY_ENFORCED LIMIT 1];
                    }else{
                         roiMaster = [Select Id, Description__c, Max_Value__c, Min_Value__c,Product_Segment__c from ROI_Master__c where Product__r.ProductCode = 'H' AND Vehicle_Category__c ='N' AND Description__c = 'CRM_IRR' and Product_Segment__c ='TWO_WHEELER' WITH SECURITY_ENFORCED LIMIT 1];//CISH-103
                    }
                    if(!roiMaster.isEmpty()) {
                        minCRM = roiMaster[0].Min_Value__c;
                        maxCRM = roiMaster[0].Max_Value__c;
                    }          
        try{
            jsonParsed =(RequestWrapper)JSON.deserialize(decryptedReqBody , RequestWrapper.class);


            //request validation start
            if(jsonParsed.applicationNumber==null){
                errorFlag = true;
                errorMsg = 'applicationNumber is missing in the request';
            } else if(jsonParsed.name==null){
                errorFlag = true;
                errorMsg = 'name is missing in the request';
            } else if(jsonParsed.dob==null){
                errorFlag = true;
                errorMsg = 'dob is missing in the request';
            } else if(jsonParsed.phone==null){
                errorFlag = true;
                errorMsg = 'phone is missing in the request';
            } else if(jsonParsed.pan==null){
                errorFlag = true;
                errorMsg = 'pan is missing in the request';
            } else if(jsonParsed.emailId==null){
                errorFlag = true;
                errorMsg = 'emailId is missing in the request';
            } else if(jsonParsed.maritalStatus==null){
                errorFlag = true;
                errorMsg = 'maritalStatus is missing in the request';
            } else if(jsonParsed.profile==null){
                errorFlag = true;
                errorMsg = 'profile is missing in the request';
            } else if(jsonParsed.category==null){
                errorFlag = true;
                errorMsg = 'category is missing in the request';
            } else if(jsonParsed.currentAddressPincode==null){
                errorFlag = true;
                errorMsg = 'currentAddressPincode is missing in the request';
            } else if(jsonParsed.make==null){
                errorFlag = true;
                errorMsg = 'make is missing in the request';
            } else if(jsonParsed.model==null){
                errorFlag = true;
                errorMsg = 'model is missing in the request';
            } else if(jsonParsed.variant==null){
                errorFlag = true;
                errorMsg = 'variant is missing in the request';
            } else if(jsonParsed.vehiclePrice==null){
                errorFlag = true;
                errorMsg = 'vehiclePrice is missing in the request';
            } else if(jsonParsed.chargerPrice==null){
                errorFlag = true;
                errorMsg = 'chargerPrice is missing in the request';
            } else if(jsonParsed.insurancePrice==null){
                errorFlag = true;
                errorMsg = 'insurancePrice is missing in the request';
            } else if(jsonParsed.handlingCharges==null){
                errorFlag = true;
                errorMsg = 'handlingCharges is missing in the request';
            } else if(jsonParsed.helmet==null){
                errorFlag = true;
                errorMsg = 'helmet is missing in the request';
            } else if(jsonParsed.fameSubsidy==null){
                errorFlag = true;
                errorMsg = 'fameSubsidy is missing in the request';
            }/* else if(jsonParsed.performanceUpgrade==null){
                errorFlag = true;
                errorMsg = 'performanceUpgrade is missing in the request';
            } */ else if(jsonParsed.cgst==null){
                errorFlag = true;
                errorMsg = 'cgst is missing in the request';
            } else if(jsonParsed.sgst==null){
                errorFlag = true;
                errorMsg = 'sgst is missing in the request';
            } else if(jsonParsed.igst==null){
                errorFlag = true;
                errorMsg = 'igst is missing in the request';
            } else if(jsonParsed.rtoRoadTax==null){
                errorFlag = true;
                errorMsg = 'rtoRoadTax is missing in the request';
            } else if(jsonParsed.iblORP==null){
                errorFlag = true;
                errorMsg = 'iblORP is missing in the request';
            } else if(jsonParsed.loanAmount==null){
                errorFlag = true;
                errorMsg = 'loanAmount is missing in the request';
            } else if(jsonParsed.crmIRR==null){
                errorFlag = true;
                errorMsg = 'crmIRR is missing in the request';
            } else if(jsonParsed.tenure==null){
                errorFlag = true;
                errorMsg = 'tenure is missing in the request';
            } else if(jsonParsed.emi==null){
                errorFlag = true;
                errorMsg = 'emi is missing in the request';
            } else if(jsonParsed.documentationCharge==null){
                errorFlag = true;
                errorMsg = 'documentationCharge is missing in the request';
            } else if(jsonParsed.processingCharge==null){
                errorFlag = true;
                errorMsg = 'processingCharge is missing in the request';
            } else if(jsonParsed.stampDuty==null){
                errorFlag = true;
                errorMsg = 'stampDuty is missing in the request';
            } else if(jsonParsed.downpayment==null){
                errorFlag = true;
                errorMsg = 'downpayment is missing in the request';
            } else if(jsonParsed.leadSource==null){
                errorFlag = true;
                errorMsg = 'leadSource is missing in the request';
            } else if((jsonParsed.crmIRR < minCRM) || (jsonParsed.crmIRR > maxCRM)){
                errorFlag = true;
                errorMsg = 'CRM IRR not within permissible range.please change CRM IRR';
                }else if(jsonParsed.dealerPincode==null && jsonParsed.leadSource == 'Hero'){//CISH-104
                errorFlag = true;
                errorMsg = 'dealerPincode is missing in the request';
            }else if(jsonParsed.dealerCode==null && jsonParsed.leadSource == 'Hero'){//CISH-104
                errorFlag = true;
                errorMsg = 'dealerCode is missing in the request';
            } else {
                errorFlag = false;
                errorMsg = '';
            }
            //request validation end

            if(!errorFlag){
                //Values comming from request
                jsonParsed.crmIRR = jsonParsed.crmIRR.setScale(2);//OLA-148
                loanApplication.Ex_showroom_price__c = jsonParsed.vehiclePrice + jsonParsed.chargerPrice + jsonParsed.fameSubsidy;
                loanApplication.Ex_showroom_price__c = loanApplication.Ex_showroom_price__c.setscale(0);
                loanApplication.X1st_yr_Insurance_Premium__c = jsonParsed.insurancePrice;
                loanApplication.Other_charges__c = jsonParsed.handlingCharges + jsonParsed.helmet;
                loanApplication.Other_charges__c = loanApplication.Other_charges__c.setScale(0);
                loanApplication.RTO_Road_Tax_New__c = jsonParsed.rtoRoadTax;//
                loanApplication.Loan_amount__c = String.valueOf(jsonParsed.loanAmount);
                loanApplication.CRM_IRR__c = jsonParsed.crmIRR;
                loanApplication.Required_Tenure__c = jsonParsed.tenure;//
                loanApplication.EMI_Amount__c = jsonParsed.emi.setScale(0);
                loanApplication.Documentation_Charges__c = jsonParsed.documentationCharge;
                loanApplication.On_Road_price__c = jsonParsed.iblORP.setScale(0);//OLA-78
                loanApplication.Service_Charges__c = jsonParsed.processingCharge;
                loanApplication.Stamping_Charges__c = jsonParsed.stampDuty;
                loanApplication.FAME_Subsidy__c = jsonParsed.fameSubsidy;
                loanApplication.Performance_Upgrade__c = jsonParsed.performanceUpgrade;
                loanApplication.LeadSource = jsonParsed.leadSource;
                loanApplication.Required_ROI__c = jsonParsed.crmIRR;
                loanApplication.Lead_number__c = jsonParsed.applicationNumber;
                
                //getting Bl_Code
                 List<User> defaultUser = new List<User>();
				 String OWNER_FULL_NAME;    // OLA-210
                 String OWNER_MOBILE_NUMBER; // OLA-210 
                 if(jsonParsed.leadSource == 'OLA'){
                    String soqlString = 'SELECT id, Pin_Code__c, BL_Code__c FROM D2C_BE_Master__c Where Vehicle_Type__c = \'New\' AND Product_Type__c=\'Two Wheeler\' AND Pin_Code__c = ' + Decimal.valueOf(jsonParsed.currentAddressPincode) + ' LIMIT 1';//OLA-76
                 List<D2C_BE_Master__c> blCodeMaster = Database.query(soqlString);
                defaultUser = [SELECT id, Name, MobilePhone FROM User WHERE Username = 'kishorbollam_vijay@indusind.com' ]; // Added Name and Mobile fields for OLA-210//OLA-223
                 if(blCodeMaster.size()>0){
                    String wildName = '%' + blCodeMaster.get(0).Bl_Code__c + '_TW_N';
                    List<Account> accList = [SELECT id, (SELECT id, UserId FROM AccountTeamMembers WHERE TeamMemberRole IN ('PE', 'BE') ) FROM Account WHERE BranchBLCode__c =:blCodeMaster.get(0).Bl_Code__c AND Name Like :wildName LIMIT 1];
                    List<id> userIdList = new List<id>();
                    List<User> peUsers = new List<User>(); // OLA-210 - Changed from List of Id to List of User  
                    List<User> beUsers = new List<User>(); // OLA-210 - Changed from List of Id to List of User  
                    if(accList.size()>0){
                        for(AccountTeamMember atm : accList.get(0).AccountTeamMembers){
                            userIdList.add(atm.UserId);
                        }
                    }
                    List<User> userRecords = [SELECT id,Name, MobilePhone, Profile.name FROM User WHERE id IN :userIdList AND IsActive = true];  // Added Name and Mobile fields for OLA-210 
                    for(User usr : userRecords){
                        if(usr.Profile.name=='IBL Business Executive TW'){
                            beUsers.add(usr);            // OLA-210 - adding user record instead of user id 
                        } else if(usr.Profile.name=='IBL Product Executive') {
                            peUsers.add(usr);           // OLA-210 - adding user record instead of user id 
                        } else{
                            system.debug('Inside 3rd condition');
                            //3rd scenario under discussion
                        }
                    }
                    loanApplication.AccountId = accList.size()>0 ? accList.get(0).id : null;
                    loanApplication.Agent_BL_code__c = blCodeMaster.get(0).Bl_Code__c;
                    if(beUsers.size()>0){
                        loanApplication.OwnerId = beUsers.get(0).Id;         // OLA-210 - beUsers changed from List of Id to List of User 
                        OWNER_FULL_NAME = beUsers.get(0).Name;              // OLA-210 
                        OWNER_MOBILE_NUMBER = beUsers.get(0).MobilePhone;  // OLA-210 
                    } else if(peUsers.size()>0){
                        loanApplication.OwnerId = peUsers.get(0).Id;           // OLA-210 - peUsers changed from List of Id to List of User 
                        OWNER_FULL_NAME = peUsers.get(0).Name;                // OLA-210 
                        OWNER_MOBILE_NUMBER = peUsers.get(0).MobilePhone;    // OLA-210 
                    } else if(defaultUser.size()>0){
                        loanApplication.OwnerId = defaultUser.get(0).id;
                        OWNER_FULL_NAME = defaultUser.get(0).Name;  // OLA-210 
                        OWNER_MOBILE_NUMBER = defaultUser.get(0).MobilePhone;  // OLA-210 
                    }else{
                        throw new IND_Exception('There is no Agent Assigned for given pincode.');
                    }
                    }
                 }else if(jsonParsed.leadSource == 'Hero'){
                    // String OWNER_FULL_NAME;       
                    // String OWNER_MOBILE_NUMBER; 
                    Set<String> setBLCodes = new Set<String>();
                    List <D2C_BE_Master__c>  blCodeMaster = new List <D2C_BE_Master__c>();
                    defaultUser = [SELECT id, Name, MobilePhone FROM User WHERE Username = 'iblr05349@indusind.com.ma.uat' ]; // Added Name and Mobile fields for OLA-210//OLA-223
                    if (blCodeMaster.isEmpty()) {
                    blCodeMaster = [SELECT id, Pin_Code__c, BL_Code__c FROM D2C_BE_Master__c Where Vehicle_Type__c = 'New' AND Product_Type__c='Two Wheeler' AND Pin_Code__c =: (jsonParsed.dealerPincode) LIMIT 1];
                    }
                    if (blCodeMaster.isEmpty()) {
                    blCodeMaster = [SELECT Id, Name, Active_Flag__c, BL_Code__c, Employee_ID__c, Pin_Code__c, State__c, Vehicle_Type__c, Product_Type__c,PinCode_LastDigitRemoved__c,PinCode_Last2DigitRemoved__c 
                    FROM D2C_BE_Master__c WHERE Vehicle_Type__c = 'New' AND Product_Type__c = 'Two Wheeler' 
                    AND (PinCode_LastDigitRemoved__c = : (jsonParsed.dealerPincode / 10) OR PinCode_Last2DigitRemoved__c = : (jsonParsed.dealerPincode / 100))];
                    }
                    for(D2C_BE_Master__c master : blCodeMaster){
                        setBLCodes.add(master.BL_Code__c);
                    }
                    List<Account> accList = [SELECT id, Name FROM Account WHERE BranchBLCode__c IN: setBLCodes AND Type = 'TW' LIMIT 1];
                    system.debug('+++++accList '+accList);
                    List<id> userIdList = new List<id>();
                    List<User> beUsers = new List<User>();
                    
                    //RoundRobin logic Start CISH-106
                    List<AccountTeamMember> userATMList = new List<AccountTeamMember>();
                    if(!accList.isEmpty()) {
                        userATMList = [SELECT Id, UserId,HERO_MA_Counter__c FROM AccountTeamMember WHERE TeamMemberRole = 'MA' AND AccountId =: accList[0].Id AND User.isActive = true WITH SECURITY_ENFORCED Order by LastModifiedDate ASC];
                    }
                    system.debug('+++++userATMList '+userATMList);

                    Map<Id, Integer> mapOfUserIdToCounter = new Map<Id, Integer>();
                    List<AccountTeamMember> listAccountTeamMemberToUpdate = new List<AccountTeamMember>(); 
                    Map<Id, AccountTeamMember> mapOfUserIdToAccountTeamMember = new Map<Id, AccountTeamMember>();
                    Id assignmenedUserId;
                    List<User> userRecords = new List<User>();

                    if(!userATMList.isEmpty()) {
                        for(AccountTeamMember accountTeamMember : userATMList) {
                            System.debug('+++++ accountTeamMember is: '+accountTeamMember);
                            accountTeamMember.HERO_MA_Counter__c = accountTeamMember.HERO_MA_Counter__c == null ? 0 : accountTeamMember.HERO_MA_Counter__c;//change made for round robin
                            Decimal heroMACount = accountTeamMember.HERO_MA_Counter__c == null ? 0 : accountTeamMember.HERO_MA_Counter__c;
                            mapOfUserIdToCounter.put(accountTeamMember.userId,Integer.valueOf(heroMACount));
                            mapOfUserIdToAccountTeamMember.put(accountTeamMember.userId,accountTeamMember);
                        }
                        system.debug('+++++mapOfUserIdToCounter '+mapOfUserIdToCounter);

                        if(!mapOfUserIdToCounter.isEmpty()){
                            assignmenedUserId = getLowestCounterHeroMA(mapOfUserIdToCounter);
                            userRecords = [SELECT id,Name, MobilePhone, Profile.name FROM User WHERE id = :assignmenedUserId AND IsActive = true Limit 1];  // Added Name and Mobile fields
                        }
                        system.debug('+++++assignmenedUserId '+assignmenedUserId);
                        system.debug('+++++userRecords '+userRecords);

                        if(mapOfUserIdToCounter != null && mapOfUserIdToCounter.size()>0) {
                            System.debug('+++++  assignmenedUserId is: '+assignmenedUserId);
                        
                            loanApplication.OwnerId = assignmenedUserId; // beUsers assignment from List of Id to List of User
                            OWNER_FULL_NAME = userRecords.get(0).Name;
                            OWNER_MOBILE_NUMBER = userRecords.get(0).MobilePhone;
    
                            //Push the detail to SET of assignmentUserId, declare the Set at top                    
                            mapOfUserIdToCounter.put(assignmenedUserId, mapOfUserIdToCounter.get(assignmenedUserId) + 1);
                            System.debug('+++++ mapOfUserIdToCounter2 '+mapOfUserIdToCounter);
                        }
    
                        // Update counter on TAFE BE
                        for(Id assignmentUserId : mapOfUserIdToCounter.keySet()) {
                            AccountTeamMember heroMAaccountTeamMember = mapOfUserIdToAccountTeamMember.get(assignmentUserId);
                            System.debug('+++++ heroMAaccountTeamMember is '+heroMAaccountTeamMember);
                            System.debug('+++++ heroMAaccountTeamMember counter '+heroMAaccountTeamMember.HERO_MA_Counter__c);
                            if(mapOfUserIdToCounter.get(assignmentUserId) > heroMAaccountTeamMember.HERO_MA_Counter__c) {
                                System.debug('+++++ HERO_MA_Counter__c '+heroMAaccountTeamMember.HERO_MA_Counter__c+' assignmentUserId '+mapOfUserIdToCounter.get(assignmentUserId));
                                heroMAaccountTeamMember.HERO_MA_Counter__c = mapOfUserIdToCounter.get(assignmentUserId);
                                listAccountTeamMemberToUpdate.add(heroMAaccountTeamMember);
                            }
                        }
    
                        if(!listAccountTeamMemberToUpdate.isEmpty()) {
                            Utilities.updateAccountTeamMembers(listAccountTeamMemberToUpdate);
                            //return true;
                                                }
}else if(defaultUser.size()>0){
                        loanApplication.OwnerId = defaultUser.get(0).id;
                        OWNER_FULL_NAME = defaultUser.get(0).Name;  // OLA-210
                        OWNER_MOBILE_NUMBER = defaultUser.get(0).MobilePhone;  // OLA-210
                    }else{

                        throw new IND_Exception('There is no Agent Assigned for given pincode.');
                    }

                    //RoundRobin logic End SFTRAC-2024

                    /*for (User usr: userRecords) {
                        if (usr.Profile.name == 'IBL TF Business Executive') {
                    beUsers.add(usr);            
                        }else {
                    system.debug('Inside 3rd condition');
                            //will be default user
                    }
                    }*/

                    loanApplication.AccountId = accList.size()>0 ? accList.get(0).id : null;
                    loanApplication.Agent_BL_code__c = blCodeMaster.get(0).Bl_Code__c;
                    //CISH-106 end
                 } else if(defaultUser.size()>0){
                    loanApplication.OwnerId = defaultUser.get(0).id;
                 }

                //Default Values
                loanApplication.Product_Type__c = 'Two Wheeler';
                loanApplication.Vehicle_Type__c = 'New';
                loanApplication.Funded__c = true;
                loanApplication.Installment_type__c = 'Equated';
                loanApplication.Funding_on_ORP__c = true;
                loanApplication.Name = jsonParsed.applicationNumber;
                loanApplication.Sub_Stage__c = 'User Details';
                loanApplication.StageName = 'Loan Initiation';
                loanApplication.LastStageName__c = 'Loan Initiation';
                loanApplication.Basic_Price__c = loanApplication.Ex_showroom_price__c*100/105;
                Decimal gstAmount = loanApplication.Basic_Price__c*5/100;
                loanApplication.GST_Amount__c = gstAmount.setScale(0);
                loanApplication.Basic_Price__c = loanApplication.Basic_Price__c.setScale(0);
                
                loanApplication.CloseDate = System.today().addMonths(1);
                insert loanApplication;
                UniqueLeadNumberHandler.updateApplicationSeqNumber(loanApplication.id);

                Applicant__c loanApplicant = new Applicant__c();
                string s1 = jsonParsed.name;//OLA-264
                string s2 = s1.normalizeSpace();//OLA-264
                List<String> nameList = s2.split(' ');//OLA-264
                if(nameList.size()==1){
                    loanApplicant.Customer_First_Name__c = nameList.get(0);
                    loanApplicant.Customer_Last_Name__c = nameList.get(0);
                } else if(nameList.size()==2){
                    loanApplicant.Customer_First_Name__c = nameList.get(0);
                    loanApplicant.Customer_Last_Name__c = nameList.get(1);
                } else if(nameList.size()==3){
                    loanApplicant.Customer_First_Name__c = nameList.get(0);
                    loanApplicant.Customer_Last_Name__c = nameList.get(1)+' '+nameList.get(2);
                }else if(nameList.size()==4){
                    loanApplicant.Customer_First_Name__c = nameList.get(0) + ' ' + nameList.get(1)+' '+nameList.get(2);
                    loanApplicant.Customer_Last_Name__c = nameList.get(3);
                }
                loanApplicant.Name = jsonParsed.name;
                loanApplicant.Opportunity__c = loanApplication.id;
                loanApplicant.Contact_number__c = jsonParsed.phone;
                loanApplicant.Marital_status__c = jsonParsed.maritalStatus;
                loanApplicant.Profile__c = jsonParsed.profile;
                loanApplicant.PAN_No__c = IntegrationUtilities.getEncryptedRequest(jsonParsed.pan,System.Label.privateKey,System.Label.ivkey);   
                loanApplicant.Email_Id__c = jsonParsed.emailId;
                loanApplicant.Salaried_Self_employed__c = jsonParsed.category;
                loanApplicant.Income_source_available__c = true;
                loanApplicant.Applicant_Type__c = 'Borrower';
                loanApplicant.Journey_Stage__c = 'User Details';
                loanApplicant.Do_you_have_a_bank_account__c = true;//OLA-29
                insert loanApplicant;

                Income_Details__c incDetailsObj = new Income_Details__c();
                incDetailsObj.Applicant__c = loanApplicant.id;
                list<Profile_Master__c> profileList = [SELECT id, name, Code__c FROM Profile_Master__c WHERE Code__c =:jsonParsed.profile LIMIT 1];

                if(jsonParsed.category=='SAL'){
                    incDetailsObj.Is_Salaried__c = true;
                } else if(jsonParsed.category=='SEP' || jsonParsed.category=='SENP'){
                    incDetailsObj.Is_Self_Employed__c = true;

                }
                incDetailsObj.Profile__c = profileList.size()>0 ? profileList.get(0).id : null;
                insert incDetailsObj;

                Vehicle_Detail__c vehicleObj = new Vehicle_Detail__c();
                vehicleObj.Loan_Application__c = loanApplication.id;
                vehicleObj.Lead_Source__c = jsonParsed.leadSource;//Hero CISH-8
                vehicleObj.Make__c = jsonParsed.make;
                List<product2> makeList = [SELECT id, Make_Code__c FROM product2 WHERE Product_Type__c = 'Two Wheeler' AND Make_Code__c = :jsonParsed.make AND Type__c = 'Make' AND IsActive = true WITH SECURITY_ENFORCED LIMIT 1];//OLA-174 in place 'name' add  'Make_Code__c'. 
                vehicleObj.Make_Code__c = makeList.size()>0 ? makeList.get(0).Make_Code__c : '';
                vehicleObj.Model__c = jsonParsed.model;
                List<product2> modelList = [SELECT Id, Model_Code__c FROM Product2 WHERE Parent_Product__r.Make_Code__c = :vehicleObj.Make_Code__c AND Name =:jsonParsed.model AND Type__c = 'Model' AND IsActive = true WITH SECURITY_ENFORCED LIMIT 1];
                vehicleObj.Model_Code__c = modelList.size()>0 ? modelList.get(0).Model_Code__c : '';
                vehicleObj.Variant__c = jsonParsed.variant;
                List<product2> variantList = [SELECT Id, Variant_Code__c FROM Product2 where Parent_Product__r.Model_Code__c = :vehicleObj.Model_Code__c AND Name =:jsonParsed.variant AND type__c = 'Variant' AND IsActive = true WITH SECURITY_ENFORCED LIMIT 1];
                vehicleObj.Variant_Code__c = variantList.size()>0 ? variantList.get(0).Variant_Code__c : '';

                vehicleObj.Vehicle_type__c = 'New';
                vehicleObj.Product__c = 'Two Wheeler';
                vehicleObj.Purpose_of_purchase__c = 'Personal';
                 if(jsonParsed.leadSource == 'Hero'){//CISH-104 start
                vehicleObj.Dealer_Pincode__c = jsonParsed.dealerPincode;
                vehicleObj.Ben_Code__c = String.valueOf(jsonParsed.dealerCode);
                List<Benefi__c> benefiList = [SELECT id, Name, Ben_code__c  FROM Benefi__c WHERE Ben_code__c =: jsonParsed.dealerCode LIMIT 1];
                vehicleObj.Dealer_Sub_dealer_name__c = benefiList.size()>0 ? benefiList.GET(0).Name : '';
                }//CISH-104 end
                if(jsonParsed.leadSource == 'OLA'){//Hero CISH-8
                vehicleObj.Dealer_Sub_dealer_name__c = 'OLA FINANCIAL SERVICES PRIVATE LIMITED';
                List<Benefi__c> benefiList = [SELECT id, Name, Ben_code__c  FROM Benefi__c WHERE Name ='OLA FINANCIAL SERVICES PRIVATE LIMITED' LIMIT 1];
                vehicleObj.Ben_Code__c = benefiList.size()>0 ? benefiList.GET(0).Ben_code__c : '';
                 }//Hero CISH-8
                
                insert vehicleObj;

                Documents__c docObj = new Documents__c();
                docObj.KYC_DOB__c = jsonParsed.dob;
                docObj.KYC_Pin_Code__c = jsonParsed.currentAddressPincode;
                docObj.Applicant__c = loanApplicant.id;
                docObj.Opportunity_Relation__c = loanApplication.id;
                docObj.RecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByDeveloperName().get('Other_Documents').getRecordTypeId();
                docObj.Document_Type__c = 'Other';//OLA-105
                insert docObj;
                
                Invoice_Details__c invoiceDetail= new Invoice_Details__c();
                invoiceDetail.Loan_Application__c = loanApplication.id;
                invoiceDetail.CGST__c = jsonParsed.cgst;
                invoiceDetail.SGST__c = jsonParsed.sgst;
                invoiceDetail.IGST__c = jsonParsed.igst;
                insert invoiceDetail; 

                IHM__c iHM = new IHM__c();
                iHM.Total_IHM_paid_to_dealer_A__c = jsonParsed.downpayment;
                //iHM.IHM_amount_as_per_receipt__c = jsonParsed.downpayment;
                iHM.Loan_amt_sanctioned_F_excl_fund_insu__c = jsonParsed.downpayment;
                iHM.Loan_Application__c = loanApplication.id;
                insert iHM;

                // Final_Term__c.Scheme_Bank_offers__c, Final_Term__c.Holiday_period__c=morotorium
                Final_Term__c finalTerm = new Final_Term__c();
                finalTerm.Loan_Application__c = loanApplication.id;
                finalTerm.Holiday_period__c='30';
                finalTerm.EMI_Amount__c= jsonParsed.emi.setScale(0);
                finalTerm.Documentation_charges__c= String.valueOf(Decimal.valueOf(jsonParsed.documentationCharge).setScale(0));//OLA-36
                finalTerm.Service_charges__c= String.valueOf(Decimal.valueOf(jsonParsed.processingCharge).setScale(0));//OLA-36
                finalTerm.Stamping_charges__c= jsonParsed.stampDuty;
                finalTerm.Installment_Type__c ='Equated';
                finalTerm.CRM_IRR__c = jsonParsed.crmIRR;
                finalTerm.Required_CRM_IRR__c = String.valueOf(jsonParsed.crmIRR);
                Decimal Provisional_Channel_Cost =jsonParsed.loanAmount*2.5/100;
                finalTerm.Provisional_Channel_Cost__c =String.valueOf(Provisional_Channel_Cost.setScale(0));//OLA-21
                finalTerm.Loan_Amount__c = String.valueOf(jsonParsed.loanAmount);
                finalTerm.Tenure__c = String.valueOf(jsonParsed.tenure);
                insert finalTerm;

                LoanDisbursementDetails__c loanDisDetails = new LoanDisbursementDetails__c();
                loanDisDetails.Beneficiary_1__c = 'OLA FINANCIAL SERVICES PRIVATE LIMITED';
                //loanDisDetails.Beneficiary_2__c = 'OLA ELECTRIC TECHNOLOGIES PRIVATE LIMITED';//OLA-336
                //loanDisDetails.Beneficiary_1_Amount__c = (jsonParsed.insurancePrice)*(jsonParsed.iblORP - jsonParsed.downpayment)/(jsonParsed.iblORP);//OLA-59
                loanDisDetails.Beneficiary_1_Amount__c = (jsonParsed.iblORP - jsonParsed.downpayment);//OLA-336
                loanDisDetails.Beneficiary_1_Amount__c = loanDisDetails.Beneficiary_1_Amount__c.setScale(0);//OLA-59
                //loanDisDetails.Beneficiary_2_Amount__c = (jsonParsed.iblORP - jsonParsed.insurancePrice)*(jsonParsed.iblORP - jsonParsed.downpayment)/(jsonParsed.iblORP);//OLA-59
                //loanDisDetails.Beneficiary_2_Amount__c = loanDisDetails.Beneficiary_2_Amount__c.setScale(0);//OLA-59
                loanDisDetails.Beneficiary_1_Account_Number__c = 'BEN251629';
                //loanDisDetails.Beneficiary_2_Account_Number__c = 'BEN275695';//OLA-336
                loanDisDetails.Beneficiary_2_Type__c = 'MDR'; //OLA-107
                loanDisDetails.Parent_Loan_Application__c = loanApplication.id;
                loanDisDetails.Vehicle_Registered_in_Name__c = jsonParsed.name;//OLA-52
                loanDisDetails.Do_Issuance__c = 'Along_with_Payment';//OLA-51
                loanDisDetails.Do_Issuance_Mode__c = 'Along_with_Payment';//OLA-51
                insert loanDisDetails;
                
                response.message = 'Lead created seccessfully';
                response.statusCode = '201';
                response.leadId = loanApplication.id;
                response.userName = OWNER_FULL_NAME;    //OLA-210 
                response.mobileNumber = OWNER_MOBILE_NUMBER;    //OLA-210 

                RestContext.response.statusCode = 201;   
                encryptedResponse = IntegrationUtilities.getEncryptedRequest(JSON.serialize(response),System.Label.privateKey,System.Label.ivkey);   
                RestContext.response.responseBody = Blob.valueOf('{'+jdataRequest + '"'+encryptedResponse+'"'+'}');
                RestContext.response.addHeader('Content-Type', 'application/json');
                if(jsonParsed.leadSource == 'OLA'){//CISH-78
                IntegrationUtilities.createIntegrationLogger(leadPayload, jsonParsed.toString(), 'Record created', '', 'OLA Request', '', loanApplication.id, System.Label.Success);
                 }else{
                    IntegrationUtilities.createIntegrationLogger(leadPayload, jsonParsed.toString(), 'Record created', '', 'Hero Request', '', loanApplication.id, System.Label.Success);    
                }//CISH-78
                /*OLA-204 - Start*/
                try{
                	intimateCustomerOnLeadAssignment(loanApplication.Id,loanApplicant.Id);
                }catch(exception e){
                    ErrorLoggerUtil.logErrorEvent('OLALeadTransferAPI', 'intimateCustomerOnLeadAssignment', System.Label.Apex, e,loanApplication.id);
                }
                /*OLA-204 - End*/
                
            } else {
                RestContext.response.statusCode = 400;
                response.message = errorMsg;
                response.statusCode = '400';encryptedResponse = IntegrationUtilities.getEncryptedRequest(JSON.serialize(response),System.Label.privateKey,System.Label.ivkey);  
                RestContext.response.responseBody = Blob.valueOf('{'+jdataRequest + '"'+encryptedResponse+'"'+'}');
                RestContext.response.addHeader('Content-Type', 'application/json');
            }
        } catch(exception e) {
            system.debug('exc '+e.getMessage());
            system.debug('exc '+e.getLineNumber());
            RestContext.response.statusCode = 400;
            response.message = 'Something went wrong';
            response.statusCode = '400';
            encryptedResponse = IntegrationUtilities.getEncryptedRequest(JSON.serialize(response),System.Label.privateKey,System.Label.ivkey);   
            RestContext.response.responseBody = Blob.valueOf('{'+jdataRequest + '"'+encryptedResponse+'"'+'}');
            RestContext.response.addHeader('Content-Type', 'application/json');

            String deserror = 'Something went wrong ---> '+e.getMessage()+ ' Exception line number-->'+e.getLineNumber();
            String error = '{ "response": { "status": "FAILED", "respDesc": "'+deserror+'"} }';
            if(jsonParsed.leadSource == 'OLA'){//CISH-78
                IntegrationUtilities.createIntegrationLogger(leadPayload, jsonParsed.toString(), 'Record created', '', 'OLA Request', '', loanApplication.id, System.Label.Success);
                }else{
                    IntegrationUtilities.createIntegrationLogger(leadPayload, jsonParsed.toString(), 'Record created', '', 'Hero Request', '', loanApplication.id, System.Label.Success);    
                }//CISH-78
            ErrorLoggerUtil.logErrorEvent('OLALeadTransferAPI', 'uploadLeadDetails', System.Label.Apex, e,loanApplication.id);
            
        }
    }
    
    @future(callout=true)
    public static void intimateCustomerOnLeadAssignment(String oppId, String appId) {
        /*Send SMS Block*/
        String serialisedSMSWrapper;
        smsWrapper smsWrap = new smsWrapper(appId,oppId);	
        serialisedSMSWrapper = JSON.serialize(smsWrap);
		Object obj= IntegrationEngine.doSmsGatewayAPI(serialisedSMSWrapper);
        /*Send SMS Block*/
        
        /*Send Email Block*/
        emailWrapper emailReq = new emailWrapper();
        List<Applicant__c> applicant = [SELECT Email_Id__c,Opportunity__r.Name,Opportunity__r.Id, Opportunity__r.Owner.Name, Opportunity__r.Owner.MobilePhone 
                                     FROM Applicant__c
                                     WHERE Id =:appId];
        if(applicant.size() >0){
            emailReq.leadId = applicant[0].Opportunity__r.Id;
            emailReq.loanApplicationId = applicant[0].Opportunity__r.Id;
            emailReq.emailTo = applicant[0].Email_Id__c;
            emailReq.emailCC = applicant[0].Email_Id__c;
            emailReq.emailSubject = 'Your Lead has been assigned to our executive!';
            String emailBody = 'Dear Customer,\n\n' +
                      'Thanks for giving us an opportunity to serve you. Your Lead Number:{0} is assigned to {1}. He can be contacted on {2}\n\n' +
                      '- IndusInd Bank';
            emailBody = String.format(emailBody, new List<Object>{applicant[0].Opportunity__r.Name, applicant[0].Opportunity__r.Owner.Name, applicant[0].Opportunity__r.Owner.MobilePhone});
        	emailReq.emailBody = emailBody;
            IntegrationEngine.doEmailServiceCalloutwithoutContinuation(JSON.serialize(emailReq));
        }
        /*Send Email Block*/
    }
    @Testvisible
    private static Id getLowestCounterHeroMA(Map<Id, Decimal> mapOfUserIdToCounter) {//CISH-106 start
        Decimal lowestCounterValue = null;
        Id assignmentUserId = null;
        
        // Iterate through the map entries to find the lowest counter value
        for (Id userId : mapOfUserIdToCounter.keySet()) {
            Decimal counterValue = mapOfUserIdToCounter.get(userId);
            if (lowestCounterValue == null || counterValue < lowestCounterValue) {
                lowestCounterValue = counterValue;
                assignmentUserId = userId;
            }
        }
        return assignmentUserId;
    }//CISH-106 end

    public class ResponseWrapper{
        Public String message;
        Public String leadId;
        Public String statusCode;
        Public String userName; //OLA-210 
        Public String mobileNumber; //OLA-210 
    }
    Public class RequestWrapper{
        //Public String date1;//
        Public String applicationNumber;
        Public String name;
        Public Date dob;
        Public String phone;
        Public String pan;
        Public String emailId;
        Public String maritalStatus;
        Public String profile;
        Public String category;
        Public String currentAddressPincode;
        Public String make;
        Public String model;
        Public String variant;
        Public Decimal vehiclePrice;
        Public Decimal chargerPrice;
        Public Decimal insurancePrice;
        Public Decimal handlingCharges;
        Public Decimal helmet;
        Public Decimal fameSubsidy;
        Public Decimal performanceUpgrade;
        Public Decimal cgst;
        Public Decimal sgst;
        Public Decimal igst;
        Public Decimal rtoRoadTax;
        Public Decimal iblORP;
        Public Decimal loanAmount;
        Public Decimal crmIRR;
        Public Decimal tenure;
        Public Decimal emi;
        Public String documentationCharge;
        Public String processingCharge;
        Public String stampDuty;
        Public Decimal downpayment;
        Public String leadSource;
        Public String dealerCode;//CISH-104
        Public Integer dealerPincode;//CISH-104
    }
    
    public class smsWrapper{
        
        public string loanApplicationId;
        public string flag;
        public string applicantId;
        
        public smsWrapper(String appId, String oppId){
            applicantId = appId;
            flag = 'cutomer_intimation';
            loanApplicationId= oppId;
        }  
        
        }   
            public class emailWrapper{
        public string leadId;
        public string loanApplicationId;
        public string emailTo;
        public string emailCC;
        public string emailSubject;
        public string emailBody;
        public string flag = 'cutomer_intimation';
    } 
}