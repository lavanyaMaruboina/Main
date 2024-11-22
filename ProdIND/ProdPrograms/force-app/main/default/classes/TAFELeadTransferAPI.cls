/*
* @Class Name:  tafeleadTransferAPI
* @Created by:  Aakash J
* @Description: RestResource API class will be used to create lead from TAFE system
*/

@RestResource(urlMapping='/v1/tafeleadTransferAPI/')
global with sharing class TAFELeadTransferAPI {
    
    @HttpPost
    global static void uploadLeadDetails(){
        
        Boolean errorFlag = false;
        String errorMsg = '';
        RestRequest req  = RestContext.request;
        //String leadPayload = req.requestBody.toString();
        String requestBody = req.requestBody.toString();

        Map<String, Object> requestBodyMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
        String leadPayload = (String) requestBodyMap.get('JData');
        System.debug('++++leadPayload: ' + leadPayload);

        ResponseWrapper response = new responseWrapper();
        RequestWrapper jsonParsed = new RequestWrapper();
        Opportunity loanApplication = new Opportunity();
        String decryptedReqBody = IntegrationUtilities.getDecryptedResponse(leadPayload,System.Label.privateKey,System.Label.ivkey);
        system.debug('++++++++decryptedReqBody '+decryptedReqBody);
        String encryptedResponse = '';
        String jdataRequest = '"JData":';     

        try{
            jsonParsed =(RequestWrapper)JSON.deserialize(decryptedReqBody , RequestWrapper.class);
            
            //request validation start
            if(jsonParsed.applicationNumber==null){
                errorFlag = true;
                errorMsg = 'applicationNumber is missing in the request';
            } else if(jsonParsed.name==null){
                errorFlag = true;
                errorMsg = 'name is missing in the request';
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
            } else if(jsonParsed.cgst==null){
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
            } else if(jsonParsed.downpayment==null){
                errorFlag = true;
                errorMsg = 'downpayment is missing in the request';
            } else if(jsonParsed.leadSource==null){
                errorFlag = true;
                errorMsg = 'leadSource is missing in the request';
            }else if(jsonParsed.dealerPincode==null){
                errorFlag = true;
                errorMsg = 'dealerPincode is missing in the request';
            }else if(jsonParsed.dealerCode==null){
                errorFlag = true;
                errorMsg = 'dealerCode is missing in the request';
            }else {
                errorFlag = false;
                errorMsg = '';
            }
            //request validation end
            
            if(!errorFlag){
                //Values comming from request
                jsonParsed.crmIRR = jsonParsed.crmIRR.setScale(2);
                loanApplication.Ex_showroom_price__c = jsonParsed.vehiclePrice + jsonParsed.chargerPrice + jsonParsed.fameSubsidy;
                loanApplication.Ex_showroom_price__c = loanApplication.Ex_showroom_price__c.setscale(0);
                loanApplication.X1st_yr_Insurance_Premium__c = jsonParsed.insurancePrice;
                loanApplication.Other_charges__c = jsonParsed.handlingCharges + jsonParsed.helmet;
                loanApplication.Other_charges__c = loanApplication.Other_charges__c.setScale(0);
                loanApplication.RTO_Road_Tax_New__c = jsonParsed.rtoRoadTax;
                loanApplication.Loan_amount__c = String.valueOf(jsonParsed.loanAmount);
                loanApplication.CRM_IRR__c = jsonParsed.crmIRR;
                loanApplication.Required_Tenure__c = jsonParsed.tenure;
                loanApplication.EMI_Amount__c = jsonParsed.emi.setScale(0);
                loanApplication.Documentation_Charges__c = jsonParsed.documentationCharge;
                loanApplication.On_Road_price__c = jsonParsed.iblORP.setScale(0);
                loanApplication.Service_Charges__c = jsonParsed.processingCharge;
                loanApplication.Stamping_Charges__c = jsonParsed.stampDuty;
                loanApplication.FAME_Subsidy__c = jsonParsed.fameSubsidy;
                loanApplication.Performance_Upgrade__c = jsonParsed.performanceUpgrade;
                loanApplication.LeadSource = jsonParsed.leadSource;
                loanApplication.Required_ROI__c = jsonParsed.crmIRR;
                loanApplication.Lead_number__c = jsonParsed.applicationNumber;
                
                //getting Bl_Code changes start
                /*String soqlString = 'SELECT Id, Name, Active_Flag__c, BL_Code__c, Employee_ID__c, Pin_Code__c, State__c, Vehicle_Type__c, Product_Type__c FROM BE_Master__c Where Vehicle_Type__c = \'New\' AND Product_Type__c=\'Tractor\' AND (Pin_Code__c = ' + (jsonParsed.dealerPincode);//SFTRAC-1878
                soqlString += ' OR PinCode_LastDigitRemoved__c = ' + (jsonParsed.dealerPincode / 10); 
                soqlString += ' OR PinCode_Last2DigitRemoved__c = ' + (jsonParsed.dealerPincode / 100)+')';
                soqlString += ' LIMIT 1';
                system.debug('+++++soqlString '+soqlString);
                List<BE_Master__c> blCodeMaster = Database.query(soqlString);*/
                //List<User> defaultUser = [SELECT id, Name, MobilePhone FROM User WHERE Username = 'omhari.singh@indusind.com.tfbe' ];
                
                List<User> defaultUser = [SELECT id, Name, MobilePhone FROM User WHERE Username =: System.Label.tafeDefaultOwner ];

                String OWNER_FULL_NAME;    
                  String OWNER_MOBILE_NUMBER;
                    
                List < BE_Master__c > blCodeMaster = new List < BE_Master__c > ();
                Set<String> setBLCodes = new Set<String>();

                if (blCodeMaster.isEmpty()) {
                    blCodeMaster = [SELECT Id, Name, Active_Flag__c, BL_Code__c, Employee_ID__c, Pin_Code__c, State__c, Vehicle_Type__c, Product_Type__c FROM BE_Master__c WHERE Vehicle_Type__c = 'New' AND Product_Type__c = 'Tractor' AND Pin_Code__c =: (jsonParsed.dealerPincode) LIMIT 1 ];
                    System.debug('++++ blCodeMaster1: ' + blCodeMaster);
                }
                if(blCodeMaster.isEmpty()){
                    blCodeMaster = [SELECT Id, Name, Active_Flag__c, BL_Code__c, Employee_ID__c, Pin_Code__c, State__c, Vehicle_Type__c, Product_Type__c 
                                    FROM BE_Master__c WHERE Vehicle_Type__c = 'New' AND Product_Type__c = 'Tractor' 
                                    AND (PinCode_LastDigitRemoved__c = : (jsonParsed.dealerPincode / 10) OR PinCode_Last2DigitRemoved__c = : (jsonParsed.dealerPincode / 100))];
                    system.debug('+++++blCodeMaster2 '+blCodeMaster);
                }System.debug('++++ blCodeMaster final result: ' + blCodeMaster);

                for(BE_Master__c master : blCodeMaster){
                    setBLCodes.add(master.BL_Code__c);
                }System.debug('++++ setBLCodes final result: ' + setBLCodes);
                    
                    if(blCodeMaster.size()>0){
                    //String wildName = '%' + blCodeMaster.get(0).Bl_Code__c + '_Tractor_N';
                    //List<Account> accList = [SELECT id, (SELECT id, UserId FROM AccountTeamMembers WHERE TeamMemberRole IN ('BE') ) FROM Account WHERE BranchBLCode__c =:blCodeMaster.get(0).Bl_Code__c AND Name Like :wildName LIMIT 1];
                    
                    //List<Account> accList = [SELECT id FROM Account WHERE BranchBLCode__c =:blCodeMaster.get(0).Bl_Code__c AND Name Like :wildName LIMIT 1];
                    List<Account> accList = [SELECT id, Name FROM Account WHERE BranchBLCode__c IN: setBLCodes AND Type = 'Tractor' LIMIT 1];
                    system.debug('+++++accList '+accList);
                    List<id> userIdList = new List<id>();
                    List<User> beUsers = new List<User>();
                    
                    /*if(accList.size()>0){
                    for(AccountTeamMember atm : accList.get(0).AccountTeamMembers){
                    userIdList.add(atm.UserId);
                    }
                    }*/
                    
                    //RoundRobin logic Start SFTRAC-2024
                    List<AccountTeamMember> userATMList = new List<AccountTeamMember>();
                    if(!accList.isEmpty()) {
                        userATMList = [SELECT Id, UserId, TAFE_BE_Counter__c FROM AccountTeamMember WHERE TeamMemberRole = 'BE' AND AccountId =: accList[0].Id AND User.isActive = true Order by LastModifiedDate ASC];
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
                            accountTeamMember.TAFE_BE_Counter__c = accountTeamMember.TAFE_BE_Counter__c == null ? 0 : accountTeamMember.TAFE_BE_Counter__c;//change made for round robin
                            Decimal tafeBECount = accountTeamMember.TAFE_BE_Counter__c == null ? 0 : accountTeamMember.TAFE_BE_Counter__c;
                            mapOfUserIdToCounter.put(accountTeamMember.userId,Integer.valueOf(tafeBECount));
                            mapOfUserIdToAccountTeamMember.put(accountTeamMember.userId,accountTeamMember);
                        }
                        system.debug('+++++mapOfUserIdToCounter '+mapOfUserIdToCounter);

                        if(!mapOfUserIdToCounter.isEmpty()){
                            assignmenedUserId = getLowestCounterTAFEBE(mapOfUserIdToCounter);
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
                            AccountTeamMember tafeBEAccountTeamMember = mapOfUserIdToAccountTeamMember.get(assignmentUserId);
                            System.debug('+++++ tafeBEAccountTeamMember is '+tafeBEAccountTeamMember);
                            System.debug('+++++ tafeBEAccountTeamMember counter '+tafeBEAccountTeamMember.TAFE_BE_Counter__c);
                            if(mapOfUserIdToCounter.get(assignmentUserId) > tafeBEAccountTeamMember.TAFE_BE_Counter__c) {
                                System.debug('+++++ TAFE_BE_Counter__c '+tafeBEAccountTeamMember.TAFE_BE_Counter__c+' assignmentUserId '+mapOfUserIdToCounter.get(assignmentUserId));
                                tafeBEAccountTeamMember.TAFE_BE_Counter__c = mapOfUserIdToCounter.get(assignmentUserId);
                                listAccountTeamMemberToUpdate.add(tafeBEAccountTeamMember);
                            }
                        }
    
                        if(!listAccountTeamMemberToUpdate.isEmpty()) {
                            Utilities.updateAccountTeamMembers(listAccountTeamMemberToUpdate);//SFTRAC-1339
                            //return true;
                        }else{
                            //return false;
                        }
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

                    /*if (beUsers.size() > 0) {
                        system.debug('Inside beUsers assignment '+beUsers.get(0).Id +' Name '+beUsers.get(0).Name);
                        loanApplication.OwnerId = beUsers.get(0).Id; // beUsers assignment from List of Id to List of User
                        OWNER_FULL_NAME = beUsers.get(0).Name;
                        OWNER_MOBILE_NUMBER = beUsers.get(0).MobilePhone;
                    }else if (defaultUser.size() > 0) {
                        system.debug('Inside defaultUser assignment1');
                    loanApplication.OwnerId = defaultUser.get(0).id;
                        OWNER_FULL_NAME = defaultUser.get(0).Name; 
                        OWNER_MOBILE_NUMBER = defaultUser.get(0).MobilePhone; 
                    } else {
                    throw new IND_Exception('There is no Agent Assigned for given pincode.');
                    }*/
                }else if(defaultUser.size()>0){
                    system.debug('Inside defaultUser assignment2');
                    loanApplication.OwnerId = defaultUser.get(0).id;
                }
                
                //Default Values
                loanApplication.Product_Type__c = 'Tractor';
                loanApplication.Vehicle_Type__c = 'New';
                loanApplication.Customer_Type__c ='Individual';
                loanApplication.Funded__c = true;
                loanApplication.Installment_type__c = 'Equated';
                // loanApplication.Funding_on_ORP__c = true;
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
                
                List<Applicant__c> loanApplicantList = new List<Applicant__c>();
                String browApplicantId;
                String browCategory;
                String browProfile;
                Date browDOB;

                // Loop through each cls_ApplicantDetails object in the response
                for (cls_ApplicantDetails appDetails : jsonParsed.applicantDetails) {
                    if(appDetails.dob==null){
                        errorFlag = true;
                        errorMsg = 'dob is missing in the request';
                    } else if(appDetails.phone==null){
                        errorFlag = true;
                        errorMsg = 'phone is missing in the request';
                    } else if(appDetails.pan==null){
                        errorFlag = true;
                        errorMsg = 'pan is missing in the request';
                    } else if(appDetails.maritalStatus==null){
                        errorFlag = true;
                        errorMsg = 'maritalStatus is missing in the request';
                    } else{
                        Applicant__c loanApplicant = new Applicant__c();
                        //Assigning First Name and Last Name for Applicant
                        string s1 = jsonParsed.name;
                        string s2 = s1.normalizeSpace();
                        List<String> nameList = s2.split(' ');
                        if(nameList.size()==1){
                            loanApplicant.Customer_First_Name__c = nameList.get(0);
                            loanApplicant.Customer_Last_Name__c = nameList.get(0);
                        } else if(nameList.size()==2){
                            loanApplicant.Customer_First_Name__c = nameList.get(0);
                            loanApplicant.Customer_Last_Name__c = nameList.get(1);
                        } else if(nameList.size()==3){
                            loanApplicant.Customer_First_Name__c = nameList.get(0);
                            loanApplicant.Customer_Last_Name__c = nameList.get(1)+' '+nameList.get(2);
                        } else if(nameList.size()==4){
                            loanApplicant.Customer_First_Name__c = nameList.get(0) + ' ' + nameList.get(1)+' '+nameList.get(2);
                            loanApplicant.Customer_Last_Name__c = nameList.get(3);
                        }
                        loanApplicant.Name = appDetails.name;
                        loanApplicant.Opportunity__c = loanApplication.id;
                        loanApplicant.Contact_number__c = appDetails.phone;
                        loanApplicant.Marital_status__c = appDetails.maritalStatus;
                        loanApplicant.Profile__c = appDetails.profile;
                        loanApplicant.PAN_No__c = IntegrationUtilities.getEncryptedRequest(appDetails.pan,System.Label.privateKey,System.Label.ivkey);   
                        loanApplicant.Email_Id__c = appDetails.emailId;
                        loanApplicant.Salaried_Self_employed__c = appDetails.category;
                        //loanApplicant.Income_source_available__c = true;
                        loanApplicant.Applicant_Type__c = appDetails.typeOfApplicant;
                        loanApplicant.Journey_Stage__c = 'User Details';
                        //loanApplicant.Do_you_have_a_bank_account__c = true;
                        browCategory = appDetails.category;
                        browProfile = appDetails.profile;
                        browDOB = appDetails.dob;
                        // Add the loanApplicant record to the list
                        loanApplicantList.add(loanApplicant);
                    }
                    
                }
                if(loanApplicantList.size()>0){
                    insert loanApplicantList;
                }
                browApplicantId = loanApplicantList.size()>0 ? loanApplicantList.get(0).id : null;
                
                //TAFE will send only one Vehicle record for now
                Vehicle_Detail__c vehicleObj = new Vehicle_Detail__c();
                vehicleObj.Loan_Application__c = loanApplication.id;
                vehicleObj.Lead_Source__c = jsonParsed.leadSource;
                vehicleObj.Vehicle_type__c = 'New';
                vehicleObj.Product__c = 'Tractor';
                vehicleObj.Purpose_of_purchase__c = 'Personal';

                vehicleObj.Make__c = jsonParsed.make;
                vehicleObj.Model__c = jsonParsed.model;
                vehicleObj.Variant__c = jsonParsed.variant;
                
                //vehicleObj.Ben_Code__c = benefiList.size()>0 ? benefiList.GET(0).Ben_code__c : '';
                vehicleObj.Dealer_Pincode__c = jsonParsed.dealerPincode;
                vehicleObj.Ben_Code__c = String.valueOf(jsonParsed.dealerCode);
                List<Benefi__c> benefiList = [SELECT id, Name, Ben_code__c  FROM Benefi__c WHERE Ben_code__c =: jsonParsed.dealerCode LIMIT 1];
                vehicleObj.Dealer_Sub_dealer_name__c = benefiList.size()>0 ? benefiList.GET(0).Name : '';
                insert vehicleObj;
                
                //Inserting Documents__c only one record which is of Borrower 
                Documents__c docObj = new Documents__c();
                docObj.KYC_DOB__c = browDOB;
                docObj.KYC_Pin_Code__c = jsonParsed.currentAddressPincode;
                docObj.Applicant__c = browApplicantId;
                docObj.Opportunity_Relation__c = loanApplication.id;
                docObj.RecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByDeveloperName().get('Other_Documents').getRecordTypeId();
                docObj.Document_Type__c = 'Other';
                insert docObj;
                
                Invoice_Details__c invoiceDetail= new Invoice_Details__c();
                invoiceDetail.Loan_Application__c = loanApplication.id;
                invoiceDetail.CGST__c = jsonParsed.cgst;
                invoiceDetail.SGST__c = jsonParsed.sgst;
                invoiceDetail.IGST__c = jsonParsed.igst;
                insert invoiceDetail; 
                
                IHM__c iHM = new IHM__c();
                iHM.Total_IHM_paid_to_dealer_A__c = jsonParsed.downpayment;
                iHM.Loan_amt_sanctioned_F_excl_fund_insu__c = jsonParsed.downpayment;
                iHM.Loan_Application__c = loanApplication.id;
                insert iHM;
                
                //One vehicle record so one Final Term record
                Final_Term__c finalTerm = new Final_Term__c();
                finalTerm.Loan_Application__c = loanApplication.id;
                finalTerm.Holiday_period__c = '30';
                finalTerm.EMI_Amount__c= jsonParsed.emi.setScale(0);
                finalTerm.Documentation_charges__c= String.valueOf((jsonParsed.documentationCharge));
                finalTerm.Service_charges__c= String.valueOf((jsonParsed.processingCharge));
                finalTerm.Stamping_charges__c= jsonParsed.stampDuty;
                finalTerm.Installment_Type__c ='Equated';
                finalTerm.CRM_IRR__c = jsonParsed.crmIRR;
                finalTerm.Required_CRM_IRR__c = String.valueOf(jsonParsed.crmIRR);
                Decimal Provisional_Channel_Cost =jsonParsed.loanAmount*2.5/100;
                finalTerm.Provisional_Channel_Cost__c =String.valueOf(Provisional_Channel_Cost.setScale(0));
                finalTerm.Loan_Amount__c = String.valueOf(jsonParsed.loanAmount);
                finalTerm.Tenure__c = String.valueOf(jsonParsed.tenure);
                finalTerm.Vehicle_Detail__c = vehicleObj.Id;
                insert finalTerm;
                
                //One LoanDisbursementDetails__c record with TAFE and TMTL hardcode name
                LoanDisbursementDetails__c loanDisDetails = new LoanDisbursementDetails__c();
                loanDisDetails.Beneficiary_1__c = 'Tractors and Farm Equipment Limited';
                loanDisDetails.Beneficiary_2__c = 'TAFE Motors and Tractors Limited';
                loanDisDetails.Beneficiary_1_Amount__c = 0;
                loanDisDetails.Beneficiary_2_Amount__c = 0;
                loanDisDetails.Beneficiary_1_Account_Number__c = 'BEN087368';
                loanDisDetails.Beneficiary_2_Account_Number__c = 'BEN072075'; // Action need to update the correct TAFE Motors and Tractors Limited Bencode
                loanDisDetails.Beneficiary_2_Type__c = 'MDR'; 
                loanDisDetails.Parent_Loan_Application__c = loanApplication.id;
                loanDisDetails.Vehicle_Registered_in_Name__c = jsonParsed.name;
                loanDisDetails.Do_Issuance__c = 'Along_with_Payment';
                loanDisDetails.Do_Issuance_Mode__c = 'Along_with_Payment';
                insert loanDisDetails;
                
                response.message = 'Lead created seccessfully';
                response.statusCode = '201';
                response.leadId = loanApplication.id;
                response.userName = OWNER_FULL_NAME;   
                response.mobileNumber = OWNER_MOBILE_NUMBER;    
                
                RestContext.response.statusCode = 201;   
                encryptedResponse = IntegrationUtilities.getEncryptedRequest(JSON.serialize(response),System.Label.privateKey,System.Label.ivkey);   
                RestContext.response.responseBody = Blob.valueOf('{'+jdataRequest + '"'+encryptedResponse+'"'+'}');
                RestContext.response.addHeader('Content-Type', 'application/json');
                if(jsonParsed.leadSource == 'TAFE'){
                    IntegrationUtilities.createIntegrationLogger(leadPayload, jsonParsed.toString(), 'Record created', '', 'TAFE Request', '', loanApplication.id, System.Label.Success);
                }
                try{
                    intimateCustomerOnLeadAssignment(loanApplication.Id,browApplicantId);
                }catch(exception e){
                    ErrorLoggerUtil.logErrorEvent('TAFELeadTransferAPI', 'intimateCustomerOnLeadAssignment', System.Label.Apex, e,loanApplication.id);
                }
                
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
            response.message = 'Something went wrong '+e.getMessage();
            response.statusCode = '400';
            encryptedResponse = IntegrationUtilities.getEncryptedRequest(JSON.serialize(response),System.Label.privateKey,System.Label.ivkey);   
            RestContext.response.responseBody = Blob.valueOf('{'+jdataRequest + '"'+encryptedResponse+'"'+'}');
            RestContext.response.addHeader('Content-Type', 'application/json');
            
            String deserror = 'Something went wrong ---> '+e.getMessage()+ ' Exception line number-->'+e.getLineNumber();
            String error = '{ "response": { "status": "FAILED", "respDesc": "'+deserror+'"} }';
            if(jsonParsed.leadSource == 'TAFE'){
                IntegrationUtilities.createIntegrationLogger(leadPayload, jsonParsed.toString(), error, '', 'TAFE Request', '', loanApplication.id, System.Label.Success);
            }
            ErrorLoggerUtil.logErrorEvent('TAFELeadTransferAPI', 'uploadLeadDetails', System.Label.Apex, e,loanApplication.id);
            
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
    
    public class ResponseWrapper{
        Public String message;
        Public String leadId;
        Public String statusCode;
        Public String userName; 
        Public String mobileNumber;
    }
    Public class RequestWrapper{
        //Public String date1;//
        Public String applicationNumber;
        Public String name;
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
        Public String dealerName;
        Public String dealerCode;
        Public Integer dealerPincode;
        Public Decimal downpayment;
        Public String leadSource;
        Public List<cls_ApplicantDetails> applicantDetails;
    }
    
    public class cls_ApplicantDetails {
        Public Date dob;
        Public String phone;
        Public String pan;
        Public String emailId;
        Public String maritalStatus;
        Public String profile;
        Public String category;
        Public String typeOfApplicant;
        Public String name;
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

    //SFTRAC-2024
    @Testvisible
    private static Id getLowestCounterTAFEBE(Map<Id, Decimal> mapOfUserIdToCounter) {
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
    }
}