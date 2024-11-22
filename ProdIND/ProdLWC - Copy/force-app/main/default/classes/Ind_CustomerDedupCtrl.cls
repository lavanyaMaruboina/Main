/**
* @Name         Ind_CustomerDedupCtrl
* @Author       Sanketkumar
* @Company      Persistent Systems
* @Description  This class contains all methods related to Customer Dedupe functionality.
* Inputs:       None
* Test Class:   Ind_CustomerDedupCtrlTest
*/
public with sharing class Ind_CustomerDedupCtrl {
    //CISP-13928 Start
    @AuraEnabled
    public static String getApplicantName(Id applicantId){
        try {
            Applicant__c app = [SELECT Name FROM Applicant__c WHERE Id=:applicantId LIMIT 1];
            return app.Name;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    //CISP-13928 End
    /*
    * @Method:      validateCustomerCode
    * @Created by:  Sanketkumar
    * @Description: This method is to validate the Customer Code selected by user.
    * @Param:       Id - Applicant ID
    * @Param:       Id - current Application ID
    * @Param:       String - Selected Dudupe Customer Details
    * @Return:      Status of Customer Code.
    */
    @AuraEnabled
    public static String saveInvalidCustomerCode(Id applicantId, String selectedInvalidCustomerCodes,Boolean userProfile){
        try {
            String custDedupeResponseObjId = '';
            String validCustomerCod = '';//CISP-9068
            for(Applicant__c app: [select Id, Applicant_Type__c, (select Id, response__c,Customer_Code__c from Customer_Dedupe_Response__r) from Applicant__c where id = :applicantId WITH SECURITY_ENFORCED limit 1 ]) {
				custDedupeResponseObjId = app.Customer_Dedupe_Response__r[0].Id;
                validCustomerCod = app.Customer_Dedupe_Response__r[0].Customer_Code__c;
            }
            Customer_Dedupe_Response__c custDedupeResObj = [Select Id,Invalid_Customer_Code__c,Invalid_Customer_Code_By_Sales_User__c from Customer_Dedupe_Response__c where Id =:custDedupeResponseObjId];
            if(userProfile == true){
                    if(custDedupeResObj.Invalid_Customer_Code__c != null){
                        custDedupeResObj.Invalid_Customer_Code__c = custDedupeResObj.Invalid_Customer_Code__c + ',' + selectedInvalidCustomerCodes;
                    }else{
                    custDedupeResObj.Invalid_Customer_Code__c = selectedInvalidCustomerCodes;
                    }
                    List<String> duplicateRemoveList = new List<String>(new Set<String>(custDedupeResObj.Invalid_Customer_Code__c.split(',')));
                    Integer index = duplicateRemoveList.indexOf(validCustomerCod);
                    if (index >= 0) {
                        duplicateRemoveList.remove(index);
                    }
                    String uniquestr = String.join(duplicateRemoveList, ',');
                    System.debug('uniquestr'+uniquestr);
                    custDedupeResObj.Invalid_Customer_Code__c = uniquestr;
            }else{
                if(custDedupeResObj.Invalid_Customer_Code_By_Sales_User__c != null){
                    custDedupeResObj.Invalid_Customer_Code_By_Sales_User__c = custDedupeResObj.Invalid_Customer_Code_By_Sales_User__c + ',' + selectedInvalidCustomerCodes;
                }else{
                custDedupeResObj.Invalid_Customer_Code_By_Sales_User__c = selectedInvalidCustomerCodes;
                }
                List<String> duplicateRemoveList = new List<String>(new Set<String>(custDedupeResObj.Invalid_Customer_Code_By_Sales_User__c.split(',')));
                String uniquestr = String.join(duplicateRemoveList, ',');
                System.debug('uniquestr'+uniquestr);
                custDedupeResObj.Invalid_Customer_Code_By_Sales_User__c = uniquestr;
            }
            custDedupeResObj.Dedupe_Journey_Status__c = 'Continued';
            update custDedupeResObj;
            if(custDedupeResObj.Invalid_Customer_Code__c != null)
                return custDedupeResObj.Invalid_Customer_Code__c;
            else    
                return null;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static String validateCustomerCode(Id applicantId, Id oppId, String dedupCustomerDetails, String customerType) {
        DedupeResponseWrapper validationResponse = new DedupeResponseWrapper();
        
        try {
            Opportunity oppObj = [Select Id,Vehicle_Type__c,Lead_Number__c,OwnerId, Product_Type__c from Opportunity where Id =: oppId];
            String vehicleType = oppObj.Vehicle_Type__c;//CISP-3447
            String productType = oppObj.Product_Type__c;//CISP-3447
            ReturnMessageWrapper returnWrapperElement = new ReturnMessageWrapper(); //CISP-3447
            Boolean isCoBorrowerValidate = false;
            Profile p = [Select Name from Profile where Id =: userinfo.getProfileid()];//CISP-3447 Get profile name for changing the messgae 
            String errMsg = System.Label.Err_Msg_Customer_Dedup_Resp_Err;
            String strBorrower = System.Label.Borrower;
            set<string> sDealStatusFlagSet=new Set<string>{};
            set<string> sCustomerStatusFlagSet=new Set<string>{};
            set<string> sNPATypeSet=new Set<string>{};
                       
            sDealStatusFlagSet.addAll(Customer_Dedupe_Flags__mdt.getInstance('DealStatusFlag').Flag_Values__c.split(','));
            sCustomerStatusFlagSet.addAll(Customer_Dedupe_Flags__mdt.getInstance('CustomerStatusFlag').Flag_Values__c.split(','));
            sNPATypeSet.addAll(Customer_Dedupe_Flags__mdt.getInstance('NPAType').Flag_Values__c.split(','));
            
            System.debug('Deal Status Flag:: '+sDealStatusFlagSet);
            System.debug('Cust Status Flag:: '+sCustomerStatusFlagSet);
            System.debug('NPA Status Flag:: '+sNPATypeSet);

			String custDedupeResponseObjId = ''; 
			String custDedupeResponse = ''; 
            String custType = '';
            String oppLeadNumber = '';//CISP-3447
            Boolean isCMUValidatePVUsedRefinance = false;
            
            for(Applicant__c app: [select Id, Applicant_Type__c,Opportunity__r.Lead_Number__c, (select Id, response__c from Customer_Dedupe_Response__r order by createdDate desc) from Applicant__c where id = :applicantId WITH SECURITY_ENFORCED limit 1 ]) {
				custDedupeResponseObjId = app.Customer_Dedupe_Response__r[0].Id;
                custDedupeResponse = app.Customer_Dedupe_Response__r[0].response__c;
                custType = app.Applicant_Type__c;
                oppLeadNumber = app.Opportunity__r.Lead_Number__c;
            }

            CustomerDetailsParser custDetailsObj = new CustomerDetailsParser();
            CustomerDetailsParser selectedCustDetails = custDetailsObj.parse(dedupCustomerDetails);
            Customer_Dedup_Response_Parser dedupResponse= Customer_Dedup_Response_Parser.parse(custDedupeResponse);

            String sSelectedCustCode = selectedCustDetails.CustomerCodeVal;
             //CISP-13928 Start
            if(custType=='Borrower'){
                    List<Applicant__c> coBorrowerApplicant = [select Id,Customer_Code__c, Applicant_Type__c from Applicant__c where Applicant_Type__c='Co-borrower' AND In_Active_Applicant__c=false AND Opportunity__c =:oppId AND Customer_Code__c=:sSelectedCustCode WITH SECURITY_ENFORCED limit 1 ];
                    if(coBorrowerApplicant.size() > 0){
                        validationResponse.message = 'Same customer code chosen for both borrower and co borrower';
                        return JSON.serialize(validationResponse);
                    }
                }else{
                    List<Applicant__c> borrowerApplicant = [select Id,Customer_Code__c, Applicant_Type__c from Applicant__c where Applicant_Type__c='Borrower' AND In_Active_Applicant__c=false AND Opportunity__c =:oppId AND Customer_Code__c=:sSelectedCustCode WITH SECURITY_ENFORCED limit 1 ];
                    if(borrowerApplicant.size() > 0){
                        validationResponse.message = 'Same customer code chosen for both borrower and co borrower';
                        return JSON.serialize(validationResponse);
                    }
                }
            //CISP-13928 End
            System.debug('Select Code:: '+ sSelectedCustCode);
            Opportunity opp = new Opportunity(ID=oppId);
            Applicant__c app = new Applicant__c(ID=applicantId);
            Customer_Dedupe_Response__c custDedupeResObj = new Customer_Dedupe_Response__c(ID=custDedupeResponseObjId);

            Set<String> custCodeSet = new Set<String>();
            List<Customer_Dedup_Response_Parser.cls_CustomerValidate[]> dedupeValidateDataList = new List<Customer_Dedup_Response_Parser.cls_CustomerValidate[]>();

            if(dedupResponse?.response?.content[0]?.Data?.ExternalDedupeResponse != null && dedupResponse?.response?.content[0]?.Data?.ExternalDedupeResponse?.DEDUPE_STATUS == 'M'){
                dedupeValidateDataList.add(dedupResponse?.response?.content[0]?.Data?.ExternalDedupeResponse?.CustomerValidate);
            }
            if(dedupResponse?.response?.content[0]?.Data?.InternalDedupeResponse != null){
                List<Customer_Dedup_Response_Parser.cls_InternalDedupeResponse> interResCount = dedupResponse?.response?.content[0]?.Data?.InternalDedupeResponse;
                for(Customer_Dedup_Response_Parser.cls_InternalDedupeResponse interObj : interResCount){
                dedupeValidateDataList.add(interObj?.CustomerValidate); //CISP-14294
                }
            }

            for(Customer_Dedup_Response_Parser.cls_CustomerValidate[] validateData: dedupeValidateDataList){
                for (Integer i = 0; i<validateData.size(); i++) {
                    //Skip if Customer Code already processed
                    if(custCodeSet.contains(validateData[i].CustomerCodeVal)){
                    	continue;
                    } else {
                        custCodeSet.add(validateData[i].CustomerCodeVal);
                    }

                    system.debug('Customer Validate Code: '+validateData[i].CustomerCodeVal);

                    if(validateData[i].CustomerCodeVal == sSelectedCustCode){
                        //DealStatus
                        if(!validateData[i]?.Dealstatus.isEmpty()){
                            for(Customer_Dedup_Response_Parser.cls_Dealstatus status: validateData[i]?.Dealstatus){
                            	system.debug('DealStatus Values: '+status.Status_Flag);
                                custDedupeResObj.Deal_Status_Flag__c = status.Status_Flag;
                                
                                if(sDealStatusFlagSet.contains(status.Status_Flag)){
                                    opp.Journey_Status__c = System.Label.Journey_Status_Stop;
                                    if(p.Name == 'CMU'){
                                        validationResponse.message = 'Status of the code is ' +  custDedupeResObj.Deal_Status_Flag__c  + ' cannot use this code';
                                        opp.Journey_Stop_Reason__c = 'CMU has validated ' + sSelectedCustCode + ' for '+ custType + ' and the status flag of the customer code chosen suggests hard stop. Hence, cannot proceed';
                                    }else{
                                        validationResponse.message = 'Due to deal code status flag '+ status.Status_Flag + ' for the validated customer code, journey cannot proceed.';//CISP-3447
                                        opp.Journey_Stop_Reason__c = validationResponse.message;
                                    }
                                    isCoBorrowerValidate = true;
                                    //validationResponse.message = 'Customer code tagged as '+ status.Status_Flag + ' flag. Hence cannot proceed.';
                                    break;
                                }
                            }
                            if(validationResponse.message != null){
                            	break;
                            }
                        }
                        system.debug('1. DealStatus Ran');

                        //CustomerStatus
                        if(!validateData[i]?.CustomerStatus.isEmpty()){
                            for(Customer_Dedup_Response_Parser.cls_CustomerStatus status: validateData[i]?.CustomerStatus){
                            	system.debug('CustomerStatus Values: '+status.Active_Flag);
                                custDedupeResObj.Customer_Status_Flag__c = status.Active_Flag;

                                if(sCustomerStatusFlagSet.contains(status.Active_Flag)){
                                    opp.Journey_Status__c = System.Label.Journey_Status_Stop;
                                    if(p.Name == 'CMU'){
                                        opp.Journey_Stop_Reason__c = 'CMU has validated ' + sSelectedCustCode + ' for '+ custType + ' and the status flag of the customer code chosen suggests hard stop. Hence, cannot proceed';
                                        validationResponse.message = 'Status of the code is ' +  custDedupeResObj.Customer_Status_Flag__c  + ' cannot use this code';
                                    }else{
                                    validationResponse.message = 'Due to deal customer code status flag '+ status.Active_Flag + ' for the validated customer code, journey cannot proceed.';//CISP-3447
                                    opp.Journey_Stop_Reason__c = validationResponse.message;
                                    }
                                    isCoBorrowerValidate = true;
                                    //validationResponse.message = 'Customer code tagged as '+ status.Active_Flag + ' flag. Hence cannot proceed.';
                                    break;
                                }
                            }
                            if(validationResponse.message != null){
                            	break;
                            }
                        }
                        system.debug('2. CustomerStatus Ran');
                        
                        //NPA
                        if(!validateData[i]?.NPA.isEmpty()){
                            /*for(Customer_Dedup_Response_Parser.cls_NPA status: validateData[i]?.NPA){
                            	system.debug('NPA Values: '+status.NPATYPE);

                                if(sNPATypeSet.contains(status.NPATYPE)){
                                    opp.Journey_Status__c = System.Label.Journey_Status_Stop;
                                    validationResponse.message = 'Customer code tagged as NPA. Hence cannot proceed.';
                                    opp.Journey_Stop_Reason__c = validationResponse.message;
                                    isCoBorrowerValidate = true;
                                    break;
                                }
                            }
                            */
                            opp.Journey_Status__c = System.Label.Journey_Status_Stop;
                            validationResponse.message = 'Customer code tagged as NPA. Hence cannot proceed.';
                            opp.Journey_Stop_Reason__c = validationResponse.message;
                            isCoBorrowerValidate = true;
                            //if(validationResponse.message != null){
                            	break;
                            //}
                        }
                        system.debug('3. NPA Ran');
                        
                        //Restructure
                        if(!validateData[i]?.Restructure.isEmpty()){
                            for(Customer_Dedup_Response_Parser.cls_Restructure status: validateData[i]?.Restructure){
                            	system.debug('Restructure Values: '+status.Deal_Restructured);

                                if(status.Deal_Restructured == 'Yes'){
                                    opp.Journey_Status__c = System.Label.Journey_Status_Stop;
                                    validationResponse.message = 'Customer code under deal no has availed Restructure(com). Hence cannot proceed.';
                                    opp.Journey_Stop_Reason__c = validationResponse.message;
                                    isCoBorrowerValidate = true;
                                    break;
                                }
                            }
                            if(validationResponse.message != null){
                            	break;
                            }
                        }
                        system.debug('4. Restructure Ran');
                        
                        //PanAlert
                        system.debug('Pan Empty check:: '+ !validateData[i]?.PanAlert.isEmpty());
                        if(!validateData[i]?.PanAlert.isEmpty()){
                            system.debug('Pan Details Exists');
                            for(Customer_Dedup_Response_Parser.cls_PanAlert status: validateData[i]?.PanAlert){
                                opp.Journey_Status__c = System.Label.Journey_Status_Stop;
                            	validationResponse.message = 'This customer/ entity is listed by FIU under '+status.Listing+' '+status.Remarks+' dated '+status.Source_Report_Date;
                                opp.Journey_Stop_Reason__c =  validationResponse.message;
                                isCoBorrowerValidate = true;
                                break;
                            }
                            if(validationResponse.message != null){
                            	break;
                            }
                        }
                        system.debug('5. PanAlert Ran');
                        
                        //CINAlert
                        system.debug('Pan Empty check:: '+ !validateData[i]?.CINAlert.isEmpty());
                        if(!validateData[i]?.CINAlert.isEmpty()){
                            system.debug('Pan Details Exists');
                            for(Customer_Dedup_Response_Parser.cls_CINAlert status: validateData[i]?.CINAlert){
                                opp.Journey_Status__c = System.Label.Journey_Status_Stop;
                                validationResponse.message = 'This customer/ entity is listed by FIU under '+status.Listing+' '+status.Remarks+' dated '+status.Source_Report_Date;
                                opp.Journey_Stop_Reason__c =validationResponse.message;
                                isCoBorrowerValidate = true;
                                break;
                            }
                            if(validationResponse.message != null){
                            	break;
                            }
                        }
                        system.debug('6. CINAlert Ran');

                        //ARC
                        system.debug('ARC check:: '+ !validateData[i]?.ARC.isEmpty());
                        if(!validateData[i]?.ARC.isEmpty()){
                            system.debug('ARC Details Exists');
                            for(Customer_Dedup_Response_Parser.cls_ARC arc: validateData[i]?.ARC){
                                opp.Journey_Status__c = System.Label.Journey_Status_Stop;
                            	validationResponse.message = 'Customer has contract sold to ARC.';
                                opp.Journey_Stop_Reason__c =  validationResponse.message;
                                isCoBorrowerValidate = true;
                                break;
                            }
                            if(validationResponse.message != null){
                            	break;
                            }
                        }
                        system.debug('7. ARC check Ran');

                        //Gecl
                        system.debug('Gecl check:: '+ !validateData[i]?.Gecl.isEmpty());
                        if(!validateData[i]?.Gecl.isEmpty()){
                            system.debug('Gecl Details Exists');
                            for(Customer_Dedup_Response_Parser.cls_Gecl gecl: validateData[i]?.Gecl){
                                opp.Journey_Status__c = System.Label.Journey_Status_Stop;
                            	validationResponse.message = 'Customer code under deal no has availed GECL. Hence cannot proceed.';
                                opp.Journey_Stop_Reason__c = validationResponse.message;
                                isCoBorrowerValidate = true;
                                break;
                            }
                            if(validationResponse.message != null){
                            	break;
                            }
                        }
                        system.debug('8. Gecl Ran');

                        //BeneficiaryAlert
                        system.debug('Beneficiary check:: '+ validateData[i]?.BeneficiaryAlert != null);
                        if(validateData[i]?.BeneficiaryAlert?.PAN_No != null){
                            system.debug('Beneficiary Details Exists');
							Customer_Dedup_Response_Parser.cls_BeneficiaryAlert bAlert = validateData[i]?.BeneficiaryAlert;
                            opp.Journey_Status__c = System.Label.Journey_Status_Stop; 
                            validationResponse.message = 'Customer is part of beneficiary list. Hence cannot proceed.';
                            opp.Journey_Stop_Reason__c = validationResponse.message;
                            isCoBorrowerValidate = true;
                            if(validationResponse.message != null){
                            	break;
                            }
                        }
                        system.debug('9. Beneficiary Ran');

                        break;
                    }
                }
				if(validationResponse.message != null){
                    break;
                }                
            }
            
            if(validationResponse.message == null){
                custDedupeResObj.Customer_Code__c = sSelectedCustCode;
                custDedupeResObj.Dedupe_Journey_Status__c = 'Continued';
                String customMessage = '';
                if(p.Name == 'CMU'){//CISP-3447
                    customMessage = 'The code: '+ sSelectedCustCode + ': '+selectedCustDetails.Customer_Name + ' identified basis '+ selectedCustDetails.Rule_Matching_Fields+' with value '+selectedCustDetails.Matched_Parameter_Value+' and percentage of match is '+selectedCustDetails.Matched_Score + '% was chosen as valid for '+customerType;
                    custDedupeResObj.Dedupe_Journey_Status_Reason__c = customMessage;
                    app.IsExposureRecived__c = false;//CISP-4693
                }
                if(p.Name != 'CMU'){
                    customMessage = 'The code: '+ sSelectedCustCode + ' is chosen as valid. Moving ahead with the existing code: '+  sSelectedCustCode + ' for ' + customerType;
                    custDedupeResObj.Dedupe_Journey_Status_Reason__c = customMessage;  //'Selected customer is identified as valid'; //CISP-3447
                }
                if(p.Name == 'CMU' && (vehicleType == 'Used' || vehicleType == 'Refinance') && (productType == 'Passenger Vehicles' || productType == 'Tractor') && customerType == 'Borrower'){ //CISP-6989
                    isCMUValidatePVUsedRefinance = true;
                    String opNumber = HandleJourney_Utility.handleLoanApplictionNumber(oppLeadNumber,'CMU Journey Restart');//CISP-6341
                    customMessage = 'CMU has validated “'+ sSelectedCustCode+'” for borrower, journey has restarted, please proceed with ' + opNumber;
                    custDedupeResObj.Dedupe_Journey_Status_Reason__c = customMessage; 
                    app.IsExposureRecived__c = false;//CISP-4693
                }
                validationResponse.message = customMessage;//Passing message on UI //CISP-3447
                app.Customer_Code__c = sSelectedCustCode;
                validationResponse.customerCode = sSelectedCustCode;
                validationResponse.isValid = true;
            } else {
                custDedupeResObj.Invalid_Customer_Code__c = sSelectedCustCode;
                custDedupeResObj.Dedupe_Journey_Status__c = 'Stopped';
                custDedupeResObj.Dedupe_Journey_Status_Reason__c = validationResponse.message;
                app.Invalid_Customer_Code__c = sSelectedCustCode;
                validationResponse.invalidCustomerCode = sSelectedCustCode;
                validationResponse.isValid = false;

                //Purge - Inactive Co-borrower if Invalid Customer code selected
                if(customerType == System.Label.coBorrower || customerType == Label.Guarantor || customerType == Label.Beneficiary){
                    app.In_Active_Applicant__c = true;
                }
            }

            if (Schema.sObjectType.Opportunity.isUpdateable() && Schema.sObjectType.Applicant__c.isUpdateable() && Schema.sObjectType.Customer_Dedupe_Response__c.isUpdateable()){
                if(customerType == 'borrower' || customerType == 'Borrower'){
                    if(opp.Journey_Status__c == System.Label.Journey_Status_Stop){ //CISP-4459
                        opp.JourneyStopScenarioFound__c = true;
                        if(p.Name == 'CMU'){ //CISP-5048
                            List<Case> caseList = [select Id,Status,Description from case where Loan_Application__c =:oppId and RecordType.Name = 'CMU Request' LIMIT 1];
                            if(!caseList.isEmpty()){
                                caseList[0].Status = 'Closed';
                                caseList[0].Description = 'Case is Closed.';
                                update caseList;
                                validationResponse.message = validationResponse.message + ' And Case is Closed';
                            }
                        }//CISP-5048 end
                    }
                    update opp;
                }
                update app;
                update custDedupeResObj;
                if(isCoBorrowerValidate == true && customerType == 'Borrower'){
                    system.debug('in isCoBorrowerValidate and type borrower');
                    if(Schema.sObjectType.Refresh_View__e.isCreateable()){
						Refresh_View__e refreshEvent = new Refresh_View__e();
						refreshEvent.Record_Id__c = oppId;
						refreshEvent.Stage__c = 'STOP';
						EventBus.publish(refreshEvent);
                    }
                    CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'Notification_to_Onwer'];
                    Messaging.CustomNotification notification = new Messaging.CustomNotification();
                    notification.setTitle('Loan Application Journey Stop ' + oppObj.Lead_Number__c);
                    notification.setBody(opp.Journey_Stop_Reason__c + ' Please refresh this screen');
                    notification.setNotificationTypeId(notificationType.Id);
                    notification.setTargetId(oppId);
                    notification.send(new Set<String> { oppObj.OwnerId });
                }
                if(productType == Label.Tractor){
                    if(isCoBorrowerValidate == true && (customerType == System.Label.coBorrower || customerType == Label.Guarantor || customerType == Label.Beneficiary)){
                        String opNumber = HandleJourney_Utility.handleLoanApplictionNumber(oppLeadNumber,'CMU Journey Restart');
                        validationResponse.message = validationResponse.message + ' Please continue with restarted lead ' + opNumber;
                        String journeyRestartType = 'Journey_Reject_NonBorrower_Tractor';
                        JourneyRestartHandler.JourneyRestart(oppId, applicantId, journeyRestartType, validationResponse.message);
                    }
                    if(isCMUValidatePVUsedRefinance == true){
                        String opNumber = HandleJourney_Utility.handleLoanApplictionNumber(oppLeadNumber,'CMU Journey Restart');
                        String journeyRestartType = (customerType == System.Label.Borrower) ? 'Journey_Reject_Borrower_Tractor' : 'Journey_Reject_NonBorrower_Tractor';
                        JourneyRestartHandler.JourneyRestart(oppId, applicantId, journeyRestartType, validationResponse.message);
                    }                    
                }else{
                    if(isCoBorrowerValidate == true && customerType == 'Co-Borrower'){
                        String opNumber = HandleJourney_Utility.handleLoanApplictionNumber(oppLeadNumber,'CMU Journey Restart');//CISP-5171
                        validationResponse.message = validationResponse.message + ' Please continue with restarted lead ' + opNumber;//CISP-5171
                        String response = JourneyRestartHandler.JourneyRestart(oppId,applicantId,'CMU_reject_Co_Borrower',validationResponse.message);
                    }
                    if(isCMUValidatePVUsedRefinance == true){
                        String response = JourneyRestartHandler.JourneyRestart(oppId,applicantId,'Journey_Restart_Borrower',validationResponse.message);
                    }
                }
                
            }
            
            System.debug('validateCustomerCode Response: '+validationResponse);
            System.debug('validateCustomerCode sSelectedCustCode: '+sSelectedCustCode);
            
            return JSON.serialize(validationResponse);
        } catch(Exception ex){
            System.debug('EX:: '+ex.getStackTraceString());
            ErrorLoggerUtil.logErrorEvent('Ind_CustomerDedupCtrl', 'validateCustomerCode', System.Label.Apex, ex);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
 
    /*
    * @Method:      validateDedupeCustomerCodeInSF
    * @Created by:  Sanketkumar
    * @Description: This method is to validate the CIC NO. In SF.
    * @Param:       ID - Applicant Id
    * @Param:       String - External Customer Dedupe Response
    * @Return:      Status of Customer Dedupe Response.
    */
    @AuraEnabled
    public static String validateDedupeCustomerCodeInSF(Id applicantId, String cicNo, String custDedupeResponse) {
		DedupeResponseWrapper validationResponse = new DedupeResponseWrapper();

        try{
            set<string> sNPATypeSet=new Set<string>{};
            sNPATypeSet.addAll(Customer_Dedupe_Flags__mdt.getInstance('NPAType').Flag_Values__c.split(','));
            List<Customer_Dedupe_Response__c> customerDedpueList = [Select Id,Applicant__c from Customer_Dedupe_Response__c where Applicant__c =:applicantId];//CISP-4459 and //CISP-4716 (deleted previous responses)
            if(!customerDedpueList.isEmpty()){
                delete customerDedpueList;
            }

            Profile profileObj = [Select Name from Profile where Id =: userinfo.getProfileid()];//CISP-3447 Get profile name for taking action
            List<Applicant__c> appList = [Select Id,Applicant_Type__c,Opportunity__c,Opportunity__r.Lead_Number__c,Opportunity__r.Product_Type__c from Applicant__c where Id =: applicantId limit 1 ];
            String oppId;
            String leadNumber;
            String productType; //CISP_4571
            if(!appList.isEmpty()){
                oppId = appList[0].Opportunity__c;
                leadNumber = appList[0].Opportunity__r.Lead_Number__c;
                productType = appList[0].Opportunity__r.Product_Type__c;
            }
            Opportunity existingOpt = new Opportunity(Id = oppId);
            Set<String> cicNoSet = new Set<String>();
            Boolean externalDedupeCustCodeExists = false;
            Boolean externalDedupeRecentLeadExists  = false;
            Boolean internalDedupeCustCodeExists = false;
            Integer sSFCustomerDedupeFlag = 1; //If 0 then exist in SF
            Integer sPGCustomerDedupeFlag = 1; //1 By Default
            String sDedupeJourneyStatusReason;
            String sDedupeJourneyStatus;
            String sSourceCICNo = '';
            String sExternalDedupeStatus = '';
            String sDedupeCalloutStatus = '';
            Boolean isNewCustomer=false;//CISP-5266

            Customer_Dedup_Response_Parser parsedResponse = null;
            string existingLeadIdForTW = ''; //CISP-3447
            string existingLeadNoForTW = '';//CISP-3447
            Boolean existingLeadTWBeforeCPStage = false;//CISP-3447
			
            if(custDedupeResponse != null){
                try{
                    parsedResponse= Customer_Dedup_Response_Parser.parse(custDedupeResponse);
                    //Callout Status Check
                    if(parsedResponse?.response?.status != null){
                        sDedupeCalloutStatus = parsedResponse?.response?.status;
                    }

                    if(sDedupeCalloutStatus == 'SUCCESS'){

                        if(parsedResponse?.response?.content[0]?.Data?.NonCFD_NPA != null){
                            String npaType = parsedResponse?.response?.content[0]?.Data?.NonCFD_NPA?.NPATYPE;
                            if(sNPATypeSet.contains(npaType)){
                                existingOpt.Journey_Status__c = System.Label.Journey_Status_Stop;
                                sDedupeJourneyStatus = 'Stopped';
                                sDedupeJourneyStatusReason = 'NonCFD Customer code tagged as NPA. Hence cannot proceed.';
                                existingOpt.Journey_Stop_Reason__c = sDedupeJourneyStatusReason;
                                if(appList[0].Applicant_Type__c == 'Co-borrower' && productType != Label.Tractor){//CISP-6486
                                    String opNumber = HandleJourney_Utility.handleLoanApplictionNumber(leadNumber,'CMU Journey Restart');
                                    String restartMessage = sDedupeJourneyStatusReason + ' Please continue with restarted lead ' + opNumber;
                                    String response = JourneyRestartHandler.JourneyRestart(oppId,applicantId,'CMU_reject_Co_Borrower',restartMessage);
                                }else if(profileObj.Name == 'CMU' && (appList[0].Applicant_Type__c == System.Label.coBorrower || appList[0].Applicant_Type__c == Label.Guarantor || appList[0].Applicant_Type__c == Label.Beneficiary) && productType == Label.Tractor) {
                                   String opNumber = HandleJourney_Utility.handleLoanApplictionNumber(leadNumber,'CMU Journey Restart');
                                   String msg = sDedupeJourneyStatusReason + ' Please continue with restarted lead ' + opNumber;                                   
                                   String journeyRestartType = 'Journey_Reject_NonBorrower_Tractor';
                                   JourneyRestartHandler.JourneyRestart(oppId, applicantId, journeyRestartType, msg);
                                }
                            }
                        }
                        //External API Status Check
                        if(parsedResponse?.response?.content[0]?.Data?.ExternalDedupeResponse?.DEDUPE_STATUS != null){
                            sExternalDedupeStatus = parsedResponse?.response?.content[0]?.Data?.ExternalDedupeResponse?.DEDUPE_STATUS;
                        }

                        //External API Recent Lead Empty check
                        if(parsedResponse?.response?.content[0]?.Data?.ExternalDedupeResponse?.DtRECENTLEAD != null){
                            externalDedupeRecentLeadExists = true;
                        }

                        //External API Customer Validate Empty check CISP-5521
                        if(parsedResponse?.response?.content[0]?.Data?.ExternalDedupeResponse?.CustomerValidate != null && parsedResponse?.response?.content[0]?.Data?.ExternalDedupeResponse?.CustomerValidate.size()>0){
                            externalDedupeCustCodeExists = true;
                        }
                        
                        //Internal API Null Check - Customer Validate is null
                        if(parsedResponse?.response?.content[0]?.Data?.InternalDedupeResponse.size()>0){
                        if(parsedResponse?.response?.content[0]?.Data?.InternalDedupeResponse[0]?.CustomerValidate[0].CustomerCodeVal != null){
                            internalDedupeCustCodeExists = true;
                        }
                        }
                    } else if (sDedupeCalloutStatus == 'FAILED'){
                        //Callout failure Case
                        sDedupeJourneyStatus = 'Skipped';
                        sDedupeJourneyStatusReason = 'Dedupe Callout Error, Journey was proceeded as new customer';
                    }
                } catch (Exception ex){
                    //Callout - Response Error: Response change error 
                    sDedupeJourneyStatus = 'Skipped';
                    sDedupeJourneyStatusReason = 'Dedupe Response Error, Journey was proceeded as new customer';
                }
            }  else {
                //Callout Error: Null Response
                sDedupeJourneyStatus = 'Skipped';
                sDedupeJourneyStatusReason = 'Dedupe Callout Error, Journey was proceeded as new customer';
            }

            System.debug('externalDedupeCustCodeExists:: '+externalDedupeCustCodeExists);
            System.debug('internalDedupeCustCodeExists:: '+internalDedupeCustCodeExists);
            System.debug('Dedupe Journey Status:: '+sDedupeJourneyStatus);

            if(sDedupeJourneyStatus != 'Skipped'){
                //Internal Dedupe Non-Customer Code Check - If No Customer Code Exists
                if(internalDedupeCustCodeExists == false){
                    //2. Validate Hard Journey Stop Case for BeneficiaryAlert, CINAlert, PanAlert in Intenal Dedupe Response
                    if(parsedResponse?.response?.content[0]?.Data?.InternalDedupeResponse.size()>0){
                    if(parsedResponse?.response?.content[0]?.Data?.InternalDedupeResponse[0]?.CustomerValidate[0]?.BeneficiaryAlert?.PAN_No != null){
                        //2.1 BeneficiaryAlert Check
                        sDedupeJourneyStatus = 'Stopped';
                        sDedupeJourneyStatusReason = 'Customer is part of beneficiary list. Hence cannot proceed';
                    } else if(!parsedResponse?.response?.content[0]?.Data?.InternalDedupeResponse[0]?.CustomerValidate[0]?.CINAlert.isEmpty()){
                        //2.2 CINAlert Check
                        for(Customer_Dedup_Response_Parser.cls_CINAlert status: parsedResponse?.response?.content[0]?.Data?.InternalDedupeResponse[0]?.CustomerValidate[0]?.CINAlert){                   
                            sDedupeJourneyStatus = 'Stopped';
                            sDedupeJourneyStatusReason = 'This customer/ entity is listed by FIU under '+status.Listing+' '+status.Remarks+' dated '+status.Source_Report_Date;
                            break;
                        }
                    } else if(!parsedResponse?.response?.content[0]?.Data?.InternalDedupeResponse[0]?.CustomerValidate[0]?.PanAlert.isEmpty()){
                        //2.3 PanAlert Check
                        for(Customer_Dedup_Response_Parser.cls_PanAlert status: parsedResponse?.response?.content[0]?.Data?.InternalDedupeResponse[0]?.CustomerValidate[0]?.PanAlert){
                            sDedupeJourneyStatus = 'Stopped';
                            sDedupeJourneyStatusReason = 'This customer/ entity is listed by FIU under '+status.Listing+' '+status.Remarks+' dated '+status.Source_Report_Date;
                            break;
                        }
                    }
                    }
                }

                //Internal Dedupe Non-Customer Code Check - SF Check
                if(sDedupeJourneyStatus != 'Stopped' && externalDedupeRecentLeadExists == true){
                    //Get set of Matched CIC No
                    Map<String,Date> cicNoAndDate = new Map<String,Date>();
                    for(Customer_Dedup_Response_Parser.cls_DtRECENTLEAD cust : parsedResponse?.response?.content[0]?.Data?.ExternalDedupeResponse?.DtRECENTLEAD){
                        cicNoSet.add(cust.MATCHED_CIC_NO);
                        cicNoAndDate.put(cust.MATCHED_CIC_NO,Date.valueOf(cust.MATCHED_LEAD_DATE));
                    }
                    System.debug('cicNoAndDate:: '+ cicNoAndDate);
                    //Check for CIC NO. Match in SF
                    List<Customer_Dedupe_Response__c> custDedupeResList = Utilities.getCustDedupeBasedOnCICNumber(cicNoSet,productType,oppId);//CISP-4571
                    System.debug('cicNoSet:: '+ cicNoSet);
                    System.debug('custDedupeResList:: '+ custDedupeResList);
                    Date validatedDate = Date.today().addDays(90);//CISP-3447
                    Set<Id> leadIds = new Set<Id>();//CISP-3447
                    String isPvExistingLeadsFound = '';
                    //Validate Matching Lead in SF
                    if(!custDedupeResList.isEmpty()){
                        Set<String> sArchivedStages = new Set<String>{'Journey Restart', 'Journey Stop', 'Revoke', 'Rejected', 'Withdrawn'};
                        set<String> twStagesStop = new Set<String>{'Credit Processing','Post Sanction Checks and Documentation','Pre Disbursement Check','Disbursement Request Preparation'};
                        set<String> twStagesContinue = new set<String>{'Loan Initiation','Additional Details','Asset Details','Loan Details','Income Details','Final Terms','Offer Screen','Customer Code Addition','Insurance Details','Final Offer'};
                        for(Customer_Dedupe_Response__c deupeResponse : custDedupeResList){
                            //If matching record is not in any of the Post Sanction Stage - Journey Stop
                            if(sArchivedStages.contains(deupeResponse.Applicant__r.Opportunity__r.StageName)  || deupeResponse.Applicant__r.Opportunity__r.Is_Revoked__c || ( (deupeResponse.Applicant__r.Opportunity__r.Product_Type__c == 'Passenger Vehicles' || deupeResponse.Applicant__r.Opportunity__r.Product_Type__c == 'Tractor') && deupeResponse.Applicant__r.Opportunity__r.JourneyStopScenarioFound__c == true)){////CISP-2384 - Added is_revoked__C
                                externalDedupeRecentLeadExists = false;
                                continue;
                            }
                            //CISP-3447 start
                            if(deupeResponse.Applicant__r.Opportunity__r.Product_Type__c == 'Passenger Vehicles' || deupeResponse.Applicant__r.Opportunity__r.Product_Type__c == 'Two Wheeler'){
                                if(cicNoAndDate.containsKey(deupeResponse.CIC_No__c)){
                                    if(cicNoAndDate.get(deupeResponse.CIC_No__c) > validatedDate){
                                        leadIds.add(deupeResponse.Applicant__r.Opportunity__c);
                                        continue;
                                    }
                                }
                            }//CISP-3447 end
                            if (deupeResponse.Applicant__r.Opportunity__r.Product_Type__c == 'Passenger Vehicles' || deupeResponse.Applicant__r.Opportunity__r.Product_Type__c == 'Tractor') {// CISP-2783
                                if(deupeResponse.Applicant__r.Opportunity__r.Sanction_Date__c == null){//CISP-3447
                                    if(profileObj.Name == 'CMU' && appList[0].Applicant_Type__c == 'Co-borrower' && deupeResponse.Applicant__r.Opportunity__r.Product_Type__c != Label.Tractor){
                                        String opNumber = HandleJourney_Utility.handleLoanApplictionNumber(leadNumber,'CMU Journey Restart');
                                        String msg = 'Dedupe has thrown an existing lead match. So journey has restarted please continue with ' +  opNumber;
                                        sDedupeJourneyStatusReason = 'Due to existing lead match, journey has got restarted';
                                        sSFCustomerDedupeFlag = 0;
                                        sDedupeJourneyStatus = 'Stopped';
                                        JourneyRestartHandler.JourneyRestart(oppId,applicantId,'Journey_Restart_Coborrower',msg);
                                        break;
                                    }else if(profileObj.Name == 'CMU' && (appList[0].Applicant_Type__c == System.Label.Borrower || appList[0].Applicant_Type__c == System.Label.coBorrower ||
                                    appList[0].Applicant_Type__c == Label.Guarantor || appList[0].Applicant_Type__c == Label.Beneficiary) && deupeResponse.Applicant__r.Opportunity__r.Product_Type__c == Label.Tractor) {
                                        
                                        String opNumber = HandleJourney_Utility.handleLoanApplictionNumber(leadNumber,'CMU Journey Restart');
                                        String msg = 'Dedupe has thrown an existing lead match. So journey has restarted please continue with ' +  opNumber;
                                        sDedupeJourneyStatusReason = 'Due to existing lead match, journey has got restarted';
                                        sSFCustomerDedupeFlag = 0;
                                        sDedupeJourneyStatus = 'Stopped';
                                        
                                        String journeyRestartType = 'Journey_Reject_NonBorrower_Tractor';

                                        JourneyRestartHandler.JourneyRestart(oppId, applicantId, journeyRestartType, msg);
                                        break;
                                    }else{
                                        sSFCustomerDedupeFlag = 0;
                                        sDedupeJourneyStatus = 'Stopped';
                                        System.debug('isPvExistingLeadsFound--' + isPvExistingLeadsFound);
                                        isPvExistingLeadsFound = isPvExistingLeadsFound + deupeResponse.Applicant__r.Opportunity__r.Name  + ' (' + deupeResponse.Applicant__r.Opportunity__r.Account.name + '),'; //CISP-5499
                                        continue;
                                        //CISP: 142
                                        //sDedupeJourneyStatusReason = 'There is an existing lead. Please ask the customer to withdraw '+ deupeResponse.Applicant__r.Opportunity__r.Name +' and re-trigger customer dedupe OR continue with the earlier application '+ deupeResponse.Applicant__r.Opportunity__r.Name + '.';
                                    }
                                   
                                }
                                else if(deupeResponse.Applicant__r.Opportunity__r.Sanction_Date__c != null && deupeResponse.Applicant__r.Opportunity__r.StageName == 'Credit Processing'){//CISP-6657 
                                    sSFCustomerDedupeFlag = 0;
                                    sDedupeJourneyStatus = 'Stopped';
                                    String LeadsFound = deupeResponse.Applicant__r.Opportunity__r.Name  + ' (' + deupeResponse.Applicant__r.Opportunity__r.Account.name + '),';
                                    sDedupeJourneyStatusReason = 'There is an existing lead '+ LeadsFound +' either withdraw '+ LeadsFound +' and retrigger dedupe or proceed with the '+ LeadsFound + '.';
                                    break;  
                                }
                                
                            } else if (deupeResponse.Applicant__r.Opportunity__r.Product_Type__c == 'Two Wheeler') { 
                                system.debug('when product type tw');
                                //CISP-3447 start
                                if(twStagesStop.contains(deupeResponse.Applicant__r.Opportunity__r.StageName) && appList[0].Applicant_Type__c == 'Borrower'){
                                    system.debug('when product type tw > Credit Processing');
                                    sSFCustomerDedupeFlag = 0;
                                    sDedupeJourneyStatus = 'Stopped';
                                    existingLeadTWBeforeCPStage = false;
                                    sDedupeJourneyStatusReason = '“'+deupeResponse.Applicant__r.Opportunity__r.Name+'” for the same applicant  “'+deupeResponse.Applicant__r.Name+'” already exists with “'+deupeResponse.Applicant__r.Opportunity__r.Agent_BL_code__c +'” at “'+deupeResponse.Applicant__r.Opportunity__r.StageName+'”. Hence, you are not allowed to proceed with this “Lead Number”.';
                                    break;
                                }else if(twStagesStop.contains(deupeResponse.Applicant__r.Opportunity__r.StageName) && appList[0].Applicant_Type__c == 'Co-borrower'){//CISP-6515
                                    system.debug('when product type tw > Credit Processing');
                                    sSFCustomerDedupeFlag = 0;
                                    sDedupeJourneyStatus = 'Stopped';
                                    existingLeadTWBeforeCPStage = false;
                                    sDedupeJourneyStatusReason = '“'+deupeResponse.Applicant__r.Opportunity__r.Name+'” for the same applicant  “'+deupeResponse.Applicant__r.Name+'” already exists with “'+deupeResponse.Applicant__r.Opportunity__r.Agent_BL_code__c +'” at “'+deupeResponse.Applicant__r.Opportunity__r.StageName+'”. Hence, you are not allowed to proceed with this “Lead Number”.';
                                    String opNumber = HandleJourney_Utility.handleLoanApplictionNumber(leadNumber,'CMU Journey Restart');
                                    String restartMessage = sDedupeJourneyStatusReason + ' Please continue with restarted lead ' + opNumber;
                                    String response = JourneyRestartHandler.JourneyRestart(oppId,applicantId,'CMU_reject_Co_Borrower',restartMessage);
                                    break;
                                }else if(deupeResponse.Applicant__r.Opportunity__r.JourneyStopScenarioFound__c == true){//CISP-4588
                                    sSFCustomerDedupeFlag = 0;
                                    sDedupeJourneyStatus = 'Stopped';
                                    existingLeadTWBeforeCPStage = false;
                                    sDedupeJourneyStatusReason = 'There is an existing lead ' + deupeResponse.Applicant__r.Opportunity__r.Name + ' for ' + deupeResponse.Applicant__r.Name + ' at ' + deupeResponse.Applicant__r.Opportunity__r.Agent_BL_code__c + ' and for that lead, journey is stopped. Hence you cannot proceed with this lead.';
                                    break;//CISP-4588
                                }
                                else if(twStagesContinue.contains(deupeResponse.Applicant__r.Opportunity__r.StageName)){
                                    system.debug('when product type tw other than Credit Processing'+deupeResponse.Applicant__r.Opportunity__r.StageName);
                                    existingLeadIdForTW = deupeResponse.Applicant__r.Opportunity__c;
                                    //existingLeadNoForTW = deupeResponse.Applicant__r.Opportunity__r.Name;
                                    existingLeadNoForTW = existingLeadNoForTW + deupeResponse.Applicant__r.Opportunity__r.Name + ',';
                                    existingLeadTWBeforeCPStage = true;
                                    sDedupeJourneyStatus = 'Continued';
                                    sSFCustomerDedupeFlag = 0; //CISP-4651
                                    externalDedupeRecentLeadExists = true;
                                    //sDedupeJourneyStatusReason = existingLeadNoForTW+' for the same applicant already exists. Do you wish to proceed?';
                                    system.debug('applicantId---' + applicantId);
                                    //customerDedupeRevisedClass.updateApplicantRecord(applicantId);//CISP-4356
                                    continue;
                                }
                                 //Start CISP-2783
                                else if(deupeResponse.Applicant__r.Opportunity__r.Sanction_Date__c == null && deupeResponse.Applicant__r.Opportunity__r.StageName != 'Withdrawn'){
                                    sSFCustomerDedupeFlag = 0;
                                    sDedupeJourneyStatus = 'Stopped';
                                    sDedupeJourneyStatusReason = 'Please proceed with the earlier application or withdraw the previous application to proceed with the new application';
                                    break;
                                }
                                else if(deupeResponse.Applicant__r.Opportunity__r.Sanction_Date__c != null && deupeResponse.Customer_Code__c == null){
                                    sSFCustomerDedupeFlag = 0;
                                    sDedupeJourneyStatus = 'Stopped';
                                    sDedupeJourneyStatusReason = 'Please proceed with the previous application or withdraw the previous application to proceed with the current application';                    
                                    break;
                                }
                                else if(deupeResponse.Applicant__r.Opportunity__r.Sanction_Date__c != null && deupeResponse.Customer_Code__c != null && deupeResponse.Applicant__r.Opportunity__r.StageName != 'Withdrawn'){
                                    sSFCustomerDedupeFlag = 0;
                                    sDedupeJourneyStatus = 'Stopped';
                                    sDedupeJourneyStatusReason = 'Please ask the User to proceed with the previous application or withdraw the previous application to proceed with the current application';
                                    break;
                                } //End CISP-2783
                            }
                        }
                        //CISP-3447 start 
                        List<Opportunity> oppList = [Select Id from opportunity where Id in : leadIds];
                        if(!oppList.isEmpty()){
                            customerDedupeRevisedClass.withdrawnLeads(oppList);
                        }//CISP-3447 end 
                        system.debug('isPvExistingLeadsFound '+isPvExistingLeadsFound.Length());
                        if(isPvExistingLeadsFound.Length()>0){
                            system.debug('isPvExistingLeadsFound ' + isPvExistingLeadsFound);
                            isPvExistingLeadsFound = isPvExistingLeadsFound.substring(0,isPvExistingLeadsFound.length()-1);
                            sDedupeJourneyStatusReason = 'There is an existing lead '+ isPvExistingLeadsFound +' either withdraw '+ isPvExistingLeadsFound +' and retrigger dedupe or proceed with the '+ isPvExistingLeadsFound + '.';          //CISP_5499
                        }
                        if(existingLeadTWBeforeCPStage == true && sDedupeJourneyStatus == 'Continued'){
                            existingLeadNoForTW = existingLeadNoForTW.substring(0,existingLeadNoForTW.length()-1);
                            sDedupeJourneyStatusReason = existingLeadNoForTW+' for the same applicant already exists. Do you wish to proceed?';
                            system.debug('applicantId---' + applicantId);
                            customerDedupeRevisedClass.updateApplicantRecord(applicantId);//CISP-4356
                        }
                    }
                }
            }

            if(sDedupeJourneyStatus != 'Skipped' && sDedupeJourneyStatus != 'Stopped' && internalDedupeCustCodeExists == false  && externalDedupeCustCodeExists == false && externalDedupeRecentLeadExists == false) {
                //No Dedupe found Case
                sDedupeJourneyStatus = 'Continued';
                isNewCustomer= true; //CISP-5266
                sDedupeJourneyStatusReason = 'There are no matching code available for the applicant, hence journey will proceed as new customer'; //CISP-3447 (when dedupe response is successful and applicant is new customer)
                //sDedupeJourneyStatusReason = 'No Dedupe Found, Journey was proceeded as new customer';
            }

           
            //Create Dedupe Response Object
			Customer_Dedupe_Response__c custDedupeObj = new Customer_Dedupe_Response__c(SF_Cust_Dedupe__c=sSFCustomerDedupeFlag, PG_Cust_Dedupe__c= sPGCustomerDedupeFlag, CIC_No__c = cicNo, Applicant__c = applicantId, External_Dedupe_Status__c = sExternalDedupeStatus, Dedupe_Journey_Status__c = sDedupeJourneyStatus, Dedupe_Journey_Status_Reason__c = sDedupeJourneyStatusReason, Response__c = custDedupeResponse,IND_isNewCustomer__c=isNewCustomer); //CISP-5266
            if(Schema.sObjectType.Customer_Dedupe_Response__c.isCreateable() || Schema.sObjectType.Customer_Dedupe_Response__c.isUpdateable()) {
                upsert custDedupeObj;
            }
            
            if(existingOpt.Journey_Status__c == 'Stop'){
                existingOpt.JourneyStopScenarioFound__c = true;
                update existingOpt;
            }
            //Update Response
            validationResponse.dedupeJourneyStatus = sDedupeJourneyStatus;
            validationResponse.dedupeJourneyStatusReason = sDedupeJourneyStatusReason;
            validationResponse.SFCustomerDedupeFlag = sSFCustomerDedupeFlag;
            validationResponse.PGCustomerDedupeFlag = sPGCustomerDedupeFlag;
            validationResponse.internalDedupeCustCodeExists = internalDedupeCustCodeExists;
            validationResponse.externalDedupeCustCodeExists = externalDedupeCustCodeExists;
            validationResponse.externalDedupeRecentLeadExists = externalDedupeRecentLeadExists;
            validationResponse.cicNoSet = cicNoSet; //Inputs for Validate Recent Lead API for further check
            validationResponse.existingLeadIdForTW = existingLeadIdForTW;//CISP-3447
            validationResponse.existingLeadNoForTW = existingLeadNoForTW;//CISP-3447
            validationResponse.existingLeadTWBeforeCPStage = existingLeadTWBeforeCPStage;//CISP-3447

            if(custDedupeObj.id != null){
			 	validationResponse.customerDedupeResponseObjId = custDedupeObj.id;
            }

            System.debug('sDedupeJourneyStatus :: '+sDedupeJourneyStatus);
            System.debug('sDedupeJourneyStatusReason :: '+sDedupeJourneyStatusReason);
            System.debug('sSFCustomerDedupeFlag :: '+sSFCustomerDedupeFlag);
            System.debug('sSourceCICNo :: '+sSourceCICNo);
            System.debug('sExternalDedupeStatus :: '+sExternalDedupeStatus);
            System.debug('sDedupeCalloutStatus :: '+sDedupeCalloutStatus);
            System.debug('validationResponse:: '+ validationResponse);

            return JSON.serialize(validationResponse);
        } catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('Ind_CustomerDedupCtrl', 'validateCustDedupeResponseInSF', System.Label.Apex, ex);
            throw new AuraHandledException(ex.getStackTraceString());
        }
    }
    
    public class DedupeResponseWrapper {
        public Decimal SFCustomerDedupeFlag { get; set; }
        public Decimal PGCustomerDedupeFlag { get; set; }
        public Decimal externalDedupeAPIMaxAttempts { get; set; }
        Set<String> cicNoSet { get; set; }
        public Boolean isValid { get; set; }
        public Boolean internalDedupeCustCodeExists { get; set; }
        public Boolean externalDedupeCustCodeExists { get; set; }
        public Boolean externalDedupeRecentLeadExists { get; set; }
        public String dedupeJourneyStatus { get; set; }
        public String dedupeJourneyStatusReason { get; set; }
        public String customerDedupeResponseObjId { get; set; }
        public String message { get; set; }
        public String applicantType { get; set; }
        public String leadNumber { get; set; }
        public String customerName { get; set; }
        public String customerCode { get; set; }
        public String invalidCustomerCode { get; set; }
        public String response { get; set; }
        public string existingLeadIdForTW {get;set;}//CISP-3447
        public string existingLeadNoForTW {get;set;}//CISP-3447
        public Boolean existingLeadTWBeforeCPStage {get;set;}//CISP-3447
        public Boolean isStop {get;set;}//CISP-3447
        public String productType {get;set;} //CISP-3447
        public String vehicleType {get;set;} //CISP-3447
        public Boolean IsTWMatchLeadFound {get;set;} //CISP-4356
        public String IsTwFound{get;set;}//CISP-4356
        public string invalidCustomerCodeBySales {get;set;}
        public Boolean isCodeValidateBySalesUser{get;set;}
        public Boolean isCustomerDedupeSubmitted {get;set;}
    }
    
    //{ get; set; } added by Hemanth Thikka
    public class CustomerDetailsParser {
        public string Aadhaar_No{ get; set; }
        public string CustomerCodeVal{ get; set; }
        public string Customer_Name{ get; set; }
        public string Customer_Type{ get; set; }
        public string Date_of_Birth{ get; set; }
        public string Driving_License_Number{ get; set; }
        public string PAN_GIR_Number{ get; set; }
        public string Passport_Number{ get; set; }
        public string Voter_ID_Number{ get; set; }
        public string Rule_Matching_Fields{ get; set; }//CISP-3447
        public string Matched_Score{ get; set; }//CISP-3447
        public string Matched_Source{ get; set; }//CISP-3447
        public string Matched_Parameter_Value {get;set;}//CISP-3447

        
        public customerDetailsParser parse(String json){
			return (CustomerDetailsParser) System.JSON.deserialize(json, CustomerDetailsParser.class);
		}
    }

    /*
    * @Method:      changeCoborrower
    * @Created by:  Sanketkumar
    * @Description: Method to Inactive coborrower for Purging action.
    * @Param:       String - Applicant ID
    * @Return:      Boolean - UpdateStatus
    */
    @AuraEnabled
    public static Boolean inactivateCoBorrowerForPurging(String applicantId) {
        Boolean updateFlag = false;
        try{
            List<Applicant__c> applicantList = [SELECT ID, Opportunity__c, Name, Journey_Stage__c, Applicant_Type__c, In_Active_Applicant__c FROM Applicant__c where id =: applicantId WITH SECURITY_ENFORCED];

            if(!applicantList.isEmpty()) {
                applicantList[0].In_Active_Applicant__c = true;

                if (Schema.sObjectType.Applicant__c.isUpdateable()){
                    update applicantList;
                
                    Applicant__c newApplicant = applicantList[0].clone(false, false, false, true);
                    newApplicant.Journey_Stage__c = 'User Details';
                    newApplicant.In_Active_Applicant__c = false;
                    if (Schema.sObjectType.Applicant__c.isCreateable()){
                        System.debug('Log - NewApplicant:: '+newApplicant);
                        insert newApplicant;
                    }
                    updateFlag = true;
                }
            }
        } catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('LwcLOSGattingAndScreeningCntrl', 'changeCoborrower', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);        
        }
        return updateFlag;
    }
    
    /*
    * @Method:      getCustomerDedupeDetails
    * @Created by:  Sanketkumar
    * @Description: This method is to get inputs for Customer dedupe screen.
    * @Param:       Id - Applicant ID
    * @Return:      Applicant Record.
    */
    @AuraEnabled
    public static String getCustomerDedupeDetails(Id applicantId) {
        try{
            DedupeResponseWrapper dedupeResponse = new DedupeResponseWrapper();
            System_Constant_custom_metadata__mdt metadataCount = System_Constant_custom_metadata__mdt.getInstance('Customer_Dedupe_Attempts'); 
    
            Applicant__c appLicantObj =  [SELECT Id, Name,isCodeValidateBySalesUser__c, Applicant_Type__c,IsTWMatchLeadFound__c,IsTwFound__c, Opportunity__r.Lead_number__c,Opportunity__r.Product_Type__c, Opportunity__r.Vehicle_Type__c ,Opportunity__r.Is_Customer_Dedupe_Submit__c,(select id, SF_Cust_Dedupe__c, PG_Cust_Dedupe__c, Customer_Code__c, Invalid_Customer_Code__c,Invalid_Customer_Code_By_Sales_User__c, Dedupe_Journey_Status__c, Dedupe_Journey_Status_Reason__c, response__c from Customer_Dedupe_Response__r order by createdDate desc) FROM Applicant__c WHERE Id = :applicantId WITH SECURITY_ENFORCED limit 1];//CISP-3447 Added product and vehicle type 
    
            dedupeResponse.applicantType = appLicantObj.Applicant_Type__c;
            dedupeResponse.leadNumber = appLicantObj.Opportunity__r.Lead_number__c;
            dedupeResponse.customerName = appLicantObj.Name;
            dedupeResponse.externalDedupeAPIMaxAttempts = metadataCount.Number_Of_Attempts__c;
            dedupeResponse.productType = appLicantObj.Opportunity__r.Product_Type__c;
            dedupeResponse.vehicleType = appLicantObj.Opportunity__r.Vehicle_Type__c;
            dedupeResponse.IsTWMatchLeadFound = appLicantObj.IsTWMatchLeadFound__c;//CISP-4356
            dedupeResponse.IsTwFound = appLicantObj.IsTwFound__c;//CISP-4356
            dedupeResponse.isCodeValidateBySalesUser = appLicantObj.isCodeValidateBySalesUser__c;
            dedupeResponse.isCustomerDedupeSubmitted = appLicantObj.Opportunity__r.Is_Customer_Dedupe_Submit__c;//CISP-9068
            if(appLicantObj.Customer_Dedupe_Response__r.size() > 0) {
                dedupeResponse.customerDedupeResponseObjId = appLicantObj?.Customer_Dedupe_Response__r[0]?.id;
                dedupeResponse.customerCode = appLicantObj?.Customer_Dedupe_Response__r[0]?.Customer_Code__c;
                dedupeResponse.invalidCustomerCode = appLicantObj?.Customer_Dedupe_Response__r[0]?.Invalid_Customer_Code__c;
                dedupeResponse.SFCustomerDedupeFlag = appLicantObj?.Customer_Dedupe_Response__r[0]?.SF_Cust_Dedupe__c;
                dedupeResponse.PGCustomerDedupeFlag = appLicantObj?.Customer_Dedupe_Response__r[0]?.PG_Cust_Dedupe__c;
                dedupeResponse.response = appLicantObj?.Customer_Dedupe_Response__r[0]?.response__c;
                dedupeResponse.dedupeJourneyStatus = appLicantObj?.Customer_Dedupe_Response__r[0]?.Dedupe_Journey_Status__c;
                dedupeResponse.dedupeJourneyStatusReason = appLicantObj?.Customer_Dedupe_Response__r[0]?.Dedupe_Journey_Status_Reason__c;
                dedupeResponse.invalidCustomerCodeBySales = appLicantObj?.Customer_Dedupe_Response__r[0]?.Invalid_Customer_Code_By_Sales_User__c;
            }
    
            System.debug('validationResponse:: '+ dedupeResponse);
            return JSON.serialize(dedupeResponse);
        } catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('Ind_CustomerDedupCtrl', 'getCustomerDedupeDetails', System.Label.Apex, ex);
            throw new AuraHandledException(ex.getStackTraceString());
        }
    }
    //CISP-3447 start
    @AuraEnabled
    public static Boolean dedupeSubmitByCMU(String oppId){
        try {
            List<Opportunity> oppList = [Select Id ,Is_Customer_Dedupe_Submit__c from Opportunity where Id =: oppId limit 1];
            if(!oppList.isEmpty()){
                oppList[0].Is_Customer_Dedupe_Submit__c = true;
                update oppList;
                return true;
            }
            return false;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }//CISP-3447 start

    @AuraEnabled
    public static string validateRecentLeadCheck(String leadNo){
        try {
            DedupeResponseWrapper validationResponse = new DedupeResponseWrapper();
            String sDedupeJourneyStatusReason;
            String sDedupeJourneyStatus;
            Boolean externalDedupeRecentLeadExists  = false;
            string existingLeadIdForTW = ''; //CISP-3447
            string existingLeadNoForTW = '';//CISP-3447
            Boolean existingLeadTWBeforeCPStage = false;//CISP-3447
            Boolean isStop = false;

            List<Opportunity> oppList = [Select Id,Name,Lead_Number__c,StageName,Is_Revoked__c,Product_Type__c,Sanction_Date__c,Agent_BL_code__c from opportunity where Lead_Number__c =: leadNo limit 1];
            if(oppList.size()>0){
                    Set<String> sArchivedStages = new Set<String>{'Journey Restart', 'Journey Stop', 'Revoke', 'Rejected', 'Withdrawn'};
                    set<String> twStagesStop = new Set<String>{'Credit Processing','Post Sanction Checks and Documentation','Pre Disbursement Check','Disbursement Request Preparation'};
                    set<String> twStagesContinue = new set<String>{'Loan Initiation','Additional Details','Asset Details','Loan Details','Income Details','Final Terms','Offer Screen','Customer Code Addition','Insurance Details','Final Offer'};
                        //If matching record is not in any of the Post Sanction Stage - Journey Stop
                        if(sArchivedStages.contains(oppList[0].StageName)  || oppList[0].Is_Revoked__c){////CISP-2384 - Added is_revoked__C
                            externalDedupeRecentLeadExists = false;
                        }
                        if (oppList[0].Product_Type__c == 'Passenger Vehicles' || oppList[0].Product_Type__c == 'Tractor') {// CISP-2783
                            if(oppList[0].Sanction_Date__c == null){//CISP-3447
                                isStop = true;
                                sDedupeJourneyStatus = 'Stopped';
                                String oppNameAndBlCode = oppList[0].Name + '(' + oppList[0].Agent_BL_code__c + ')';
                                sDedupeJourneyStatusReason = 'There is an existing lead. Please ask the customer to withdraw '+ oppNameAndBlCode +' and re-trigger customer dedupe OR continue with the earlier application '+ oppNameAndBlCode + '.';
                            }
                            
                        } else if (oppList[0].Product_Type__c == 'Two Wheeler' ) { 
                            system.debug('when product type tw');
                            //CISP-3447 start
                            if(twStagesStop.contains(oppList[0].StageName)){
                                system.debug('when product type tw > Credit Processing');
                                isStop = true;
                                sDedupeJourneyStatus = 'Stopped';
                                sDedupeJourneyStatusReason = '“'+oppList[0].Name+'” for the same applicant already exists with “'+oppList[0].Agent_BL_code__c +'” at “'+oppList[0].StageName+'”. Hence, you are not allowed to proceed with this “Lead Number”.';
                            }
                            else if(twStagesContinue.contains(oppList[0].StageName)){
                                system.debug('when product type tw other than Credit Processing'+oppList[0].StageName);
                                isStop = true;
                                existingLeadIdForTW = oppList[0].Id;
                                existingLeadNoForTW = oppList[0].Name;
                                existingLeadTWBeforeCPStage = true;
                                sDedupeJourneyStatus = 'Continued';
                                sDedupeJourneyStatusReason = existingLeadNoForTW + '(' + oppList[0].Agent_BL_code__c + ') ' +' for the same applicant already exists. Do you wish to proceed?';
                            }
                             //Start CISP-2783
                            else if(oppList[0].Sanction_Date__c == null && oppList[0].StageName != 'Withdrawn'){
                                sDedupeJourneyStatus = 'Stopped';
                                isStop = true;
                                String oppNameAndBlCode = oppList[0].Name + '(' + oppList[0].Agent_BL_code__c + ')';
                                sDedupeJourneyStatusReason = 'Please proceed with the earlier application or withdraw the previous application ' + oppNameAndBlCode + 'to proceed with the new application';
                            }
                        }
            }
            validationResponse.dedupeJourneyStatus = sDedupeJourneyStatus;
            validationResponse.dedupeJourneyStatusReason = sDedupeJourneyStatusReason;
            validationResponse.externalDedupeRecentLeadExists = externalDedupeRecentLeadExists;
            validationResponse.existingLeadIdForTW = existingLeadIdForTW;//CISP-3447
            validationResponse.existingLeadNoForTW = existingLeadNoForTW;//CISP-3447
            validationResponse.existingLeadTWBeforeCPStage = existingLeadTWBeforeCPStage;//CISP-3447
            validationResponse.isStop = isStop;
            return JSON.serialize(validationResponse);
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public Class ReturnMessageWrapper{//CISP-3447 start 
        @AuraEnabled public Boolean isSuccess {get;set;}
        @AuraEnabled public String message {get;set;}
        @AuraEnabled public String cloneLoanApplicationId {get;set;}
        @AuraEnabled public String cloneBorrowerApplicantId {get;set;}
		@AuraEnabled public String cloneCoBorrowerApplicantId {get;set;}
    }
    @AuraEnabled
    public static List<Applicant__c> checkLeadvalidateByCMU(String leadId){
        try {
            List<Applicant__c>  appList = [select Id, Applicant_Type__c,Opportunity__c,Opportunity__r.stageName, Opportunity__r.Journey_Status__c,Opportunity__r.Journey_Restart_Reason__c, Opportunity__r.Journey_Stop_Reason__c,(select Id, response__c,Dedupe_Journey_Status_Reason__c from Customer_Dedupe_Response__r) from Applicant__c where Opportunity__c = :leadId WITH SECURITY_ENFORCED];
            if(!appList.isEmpty()){
                return appList;
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}