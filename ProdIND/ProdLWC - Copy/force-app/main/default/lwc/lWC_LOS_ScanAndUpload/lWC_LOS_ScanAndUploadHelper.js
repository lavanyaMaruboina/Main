import firstNameError from '@salesforce/label/c.Name_Er';
import issueDateValidationMsg from '@salesforce/label/c.Name_Er';
import RegEx_Last_Name from '@salesforce/label/c.RegEx_Last_Name';
import RegEx_NonIndEntity_Alphabets	 from '@salesforce/label/c.RegEx_NonIndEntity_Alphabets';
import lastNameError from '@salesforce/label/c.Last_Name_Error';
import RegEx_Alphabets_Only from '@salesforce/label/c.RegEx_Alphabets_Only';
import RegEx_Number from '@salesforce/label/c.RegEx_Number';
import Mobile_Number_Error_Msg from '@salesforce/label/c.Mobile_Number_Error_Msg';
import Driving_Licence_Number from '@salesforce/label/c.Driving_Licence_Number';
import Aadhar_Pattern from '@salesforce/label/c.Aadhar_Pattern';
import Voter_Id_Pattern from '@salesforce/label/c.Voter_Id_Pattern';
import Pin_code_Pattern from '@salesforce/label/c.Pin_code_Pattern';
import Pan_Pattern from '@salesforce/label/c.Pan_Pattern';
import Pan_Pattern_NonIndividual from '@salesforce/label/c.Pan_Pattern_Non_individual';//SFTRAC-535
import Passport_Pattern from '@salesforce/label/c.Passport_Pattern';
import CIN_Pattern from '@salesforce/label/c.CIN_Pattern';
import GST_Pattern from '@salesforce/label/c.GST_Pattern';
import Last_Name_Pattern from '@salesforce/label/c.Last_Name_Pattern';
import KycAddress1Pattern from '@salesforce/label/c.KycAddress1Pattern';
import KycAddress2Pattern from '@salesforce/label/c.KycAddress2Pattern';
import Aadhar_Enrollment_Pattern from '@salesforce/label/c.Aadhar_Enrollment_Pattern';
import Age_Max from '@salesforce/label/c.Age_Max';
import Age_Min from '@salesforce/label/c.Age_Min';
import DrivingLicences from '@salesforce/label/c.DrivingLicences';
import PassportCard from '@salesforce/label/c.PassportCard';
import VoterIdCard from '@salesforce/label/c.VoterIdCard';
import GST_CERT from '@salesforce/label/c.GST_Cert';
import CIN_CERT from '@salesforce/label/c.CIN_Cert';
import KycNamePattern from '@salesforce/label/c.KycNamePattern';
import Form60DocumentType from '@salesforce/label/c.Form60DocumentType';
import currentUserId from '@salesforce/label/c.currentUserId';
import currentUserName from '@salesforce/label/c.currentUserName';
import currentUserEmailid from '@salesforce/label/c.currentUserEmailid';
import mode from '@salesforce/label/c.mode';
import currentApplicantid from '@salesforce/label/c.currentApplicantid';
import FrontUploadResponseMessage from '@salesforce/label/c.FrontUploadResponseMessage';
import BackUploadExhausted from '@salesforce/label/c.BackUploadExhausted';
import Expired from '@salesforce/label/c.Expired';
import Recapture_Kyc from '@salesforce/label/c.Recapture_Kyc';
import Salutations_List from '@salesforce/label/c.Salutations_List';
import KYC_Last_Name from '@salesforce/label/c.KYC_Last_Name';
import PanCards from '@salesforce/label/c.PanCards';
import AadhaarCard from '@salesforce/label/c.AadhaarCard';
import AddressValidation1 from '@salesforce/label/c.AddressValidation1';
import AddressValidation2 from '@salesforce/label/c.AddressValidation2';
import AddressValidation3 from '@salesforce/label/c.AddressValidation3';
import AddressnotValid from '@salesforce/label/c.AddressnotValid';
import ExceptionMessage from '@salesforce/label/c.ExceptionMessage';
import aadhaarSampleFront from '@salesforce/resourceUrl/AadhaarSampleFront';//CISP-12287
import aadhaarSampleBack from '@salesforce/resourceUrl/AadhaarSampleBack';//CISP-12287
import PanApprovedValue from '@salesforce/label/c.PanApprovedValue';
import LightningAlert from 'lightning/alert';//CISP-4560
const stateCity = (data, city, pincode)=>{
    if (data) {
        var   stateCityMap = new Map();
        data.forEach((state) => {
            if(state.Pincode_Starting_Max__c >= parseInt(pincode.substring(0, 2), 10) && state.Pincode__c<=parseInt(pincode.substring(0, 2), 10)){
                state.City_State_Masters__r.forEach((city => {
                    stateCityMap.set(
                        city.Name,
                        state.Name
                    );

                }));
            }
        });
        return stateCityMap.get(city);
    }
}
const City = (data, pincode) => {
    if (data) {
        var cityVal = [];
        data.forEach((state) => {
            if (state.Pincode_Starting_Max__c >= parseInt(pincode.substring(0, 2), 10) && state.Pincode__c <= parseInt(pincode.substring(0, 2), 10)) {
                if (state.City_State_Masters__r?.length > 0) {
                    state.City_State_Masters__r.forEach((city => {
                        cityVal.push({
                            label: city.Name,
                            value: city.Name
                        })

                    }));
                }
            }
        });
        return cityVal;
    }
}
const cityCheckMaster = (data, citydata, statedata) => {
    if (data && citydata && statedata) {
      let cityFound=false;
        data.forEach((state) => {
            if(state.Name ==statedata){
                if (state.City_State_Masters__r?.length > 0) {
                    state.City_State_Masters__r.forEach((city => {
                     if(city.Name ==citydata){
                        cityFound=true;
                     }
                    }));
                }
            }
        });
        return cityFound;
    }
}
export const customLabels = {
    firstNameError : firstNameError,
    issueDateValidationMsg : issueDateValidationMsg,
    RegEx_Last_Name : RegEx_Last_Name,
    lastNameError : lastNameError,
    RegEx_Alphabets_Only : RegEx_Alphabets_Only,
    RegEx_Number : RegEx_Number,
    Mobile_Number_Error_Msg : Mobile_Number_Error_Msg,
    Driving_Licence_Number : Driving_Licence_Number,
    Aadhar_Pattern : Aadhar_Pattern,
    Voter_Id_Pattern : Voter_Id_Pattern,
    Pin_code_Pattern : Pin_code_Pattern,
    Pan_Pattern : Pan_Pattern,
    Pan_Pattern_NonIndividual : Pan_Pattern_NonIndividual,//SFTRAC-535
    Passport_Pattern : Passport_Pattern,
    CIN_Pattern : CIN_Pattern,
    GST_Pattern : GST_Pattern,
    Last_Name_Pattern : Last_Name_Pattern,
    KycAddress1Pattern : KycAddress1Pattern,
    KycAddress2Pattern : KycAddress2Pattern,
    Aadhar_Enrollment_Pattern : Aadhar_Enrollment_Pattern,
    Age_Max : Age_Max,
    Age_Min : Age_Min,
    DrivingLicences : DrivingLicences,
    PassportCard : PassportCard,
    VoterIdCard : VoterIdCard,
    CIN_CERT : CIN_CERT,
    GST_CERT : GST_CERT, 
    KycNamePattern : KycNamePattern,
    Form60DocumentType : Form60DocumentType,
    currentUserId : currentUserId,
    currentUserName : currentUserName,
    currentUserEmailid : currentUserEmailid,
    mode : mode,
    currentApplicantid : currentApplicantid,
    FrontUploadResponseMessage : FrontUploadResponseMessage,
    BackUploadExhausted : BackUploadExhausted,
    Expired : Expired,
    Recapture_Kyc : Recapture_Kyc,
    Salutations_List : Salutations_List,
    KYC_Last_Name : KYC_Last_Name,
    PanCards: PanCards,
    AadhaarCard : AadhaarCard,
    AddressValidation1 : AddressValidation1,
    AddressValidation2 : AddressValidation2,
    AddressValidation3 :AddressValidation3,
    AddressnotValid : AddressnotValid,
    ExceptionMessage : ExceptionMessage,
    PanApprovedValue : PanApprovedValue,
}
export const customResource = {
    aadhaarSampleFront:aadhaarSampleFront,
    aadhaarSampleBack:aadhaarSampleBack
}

    //CISP-4560
    export const ageValidation =(dobval,appType,prodType)=>{
        const MaxAgeMessage= prodType =='Passenger Vehicles' ? '80' : prodType =='Two Wheeler'? '65': '' ;
        const minError='Age of the '+appType +' is less than 18 years. Please provide alternate KYC to continue the journey';
        const maxError='Age of the '+appType +' is greater than '+MaxAgeMessage+' years. Please provide alternate KYC to continue the journey';
        var dateObj = new Date();
        var dd = dateObj.getDate();
        var mm = dateObj.getMonth() + 1;
        var yyyy = dateObj.getFullYear();
        var  minage=(yyyy - 18) + '-' + mm + '-' + '28';
        var  maxAge = prodType =='Passenger Vehicles' ? (yyyy - 80) + '-' + mm + '-' + dd : prodType =='Two Wheeler'? (yyyy - 65) + '-' + mm + '-' + dd: '' ;
      if (new Date(dobval) < new Date(maxAge)) {
         alert(maxError,'error','Age Limit Error!');
        return true;
    }
    else if (new Date(dobval) > new Date(minage)) {
         alert(minError,'error','Age Limit Error!');
        return true;
    }
    return false; 
}
//CISP-4560
 async function alert(messages,themes,labels){
    await LightningAlert.open({
        message: messages,
        theme: themes, 
        label: labels,
    });
}

import UserNameFld from '@salesforce/schema/User.Name';
import userEmailFld from '@salesforce/schema/User.Email';
import Gender__c from '@salesforce/schema/Documents__c.Gender__c';
import Age__c from '@salesforce/schema/Documents__c.Age__c';
import KYC_State__c from '@salesforce/schema/Documents__c.KYC_State__c';
import KYC_City__c from '@salesforce/schema/Documents__c.KYC_City__c';
import KYC_District__c from '@salesforce/schema/Documents__c.KYC_District__c';
import Salutation__c from '@salesforce/schema/Documents__c.Salutation__c';
import DL_Type__c from '@salesforce/schema/Documents__c.DL_Type__c';
import Documents__c from '@salesforce/schema/Documents__c';
import First_Name__c from '@salesforce/schema/Documents__c.First_Name__c';
import Last_Name__c from '@salesforce/schema/Documents__c.Last_Name__c';
import Father_Name__c from '@salesforce/schema/Documents__c.Father_Name__c';
import KYC_DOB__c from '@salesforce/schema/Documents__c.KYC_DOB__c';
import Address__c from '@salesforce/schema/Documents__c.Address__c';
import KYC_Pin_Code__c from '@salesforce/schema/Documents__c.KYC_Pin_Code__c';
import Proof_of_Address_POA__c from '@salesforce/schema/Documents__c.Proof_of_Address_POA__c';
import Mobile_number__c from '@salesforce/schema/Documents__c.Mobile_number__c';
import Proof_of_Identity_POI__c from '@salesforce/schema/Documents__c.Proof_of_Identity_POI__c';
import Aadhaar_Enrollment_Number__c from '@salesforce/schema/Documents__c.Aadhaar_Enrollment_Number__c';
import PAN_acknowledgement_number__c from  '@salesforce/schema/Documents__c.PAN_acknowledgement_number__c';
import Estimated_annual_income__c from '@salesforce/schema/Documents__c.Estimated_annual_income__c';
import Amount_of_transaction__c from '@salesforce/schema/Documents__c.Amount_of_transaction__c';
import Date_of_transaction__c from '@salesforce/schema/Documents__c.Date_of_transaction__c';
import Number_of_persons_involved_in_the_transa__c from '@salesforce/schema/Documents__c.Number_of_persons_involved_in_the_transa__c';
import APP_ID_FIELD from '@salesforce/schema/Applicant__c.Id';
import AADHAR_NO_FIELD from '@salesforce/schema/Applicant__c.Aadhar_No__c';
import DOC_ID_FIELD from '@salesforce/schema/Documents__c.Id';
import DOCUMENT_NAME from '@salesforce/schema/Documents__c.Name';
import APPLICANT_TYPE from '@salesforce/schema/Applicant__c.Applicant_Type__c';//CISP-4560
import PRODUCT_TYPE from '@salesforce/schema/Applicant__c.Opportunity__r.Product_Type__c';//CISP-4560
import DocumentType from '@salesforce/schema/Documents__c.Document_Type__c';
import IsActive from '@salesforce/schema/Documents__c.is_Active__c';
import BMDSensorNo from '@salesforce/schema/User.BMD_Sensor_No__c';
import FORM_FACTOR from '@salesforce/client/formFactor';
import resendAadharBiometric from '@salesforce/apex/LwcLOSLoanApplicationCntrl.resendAadharBiometric';
import KYC_name from '@salesforce/schema/Documents__c.KYC_name__c';
import AadhaarSeedingStatus from '@salesforce/schema/Documents__c.AadhaarSeedingStatus__c';

import PAN_No from '@salesforce/schema/Documents__c.PAN_No__c'
import doDLCallout from '@salesforce/apexContinuation/IntegrationEngine.doDLCallout';
import doVoterIdCallout from '@salesforce/apexContinuation/IntegrationEngine.doVoterIdCallout';
import doPPCallout from '@salesforce/apexContinuation/IntegrationEngine.doPPCallout';

import FATHER_NAME_FIELD from '@salesforce/schema/Documents__c.Father_Name__c';
import ESTIMATED_INCOME from '@salesforce/schema/Documents__c.Estimated_annual_income__c';
import PAN_ACK_NUMBER from '@salesforce/schema/Documents__c.PAN_acknowledgement_number__c';
import AMOUNT_OF_TRANSACTION from '@salesforce/schema/Documents__c.Amount_of_transaction__c';
import Golden_Source_Attempts from '@salesforce/schema/Documents__c.Golden_Source_Attempts__c'; 
import Front_Upload_Attempts from '@salesforce/schema/Documents__c.Front_Upload_Attempts__c'; 
import NUMBER_OF_PERSONS_IN_TRAN from '@salesforce/schema/Documents__c.Number_of_persons_involved_in_the_transa__c';
import checkIfPanNoIsSameOrNot from '@salesforce/apex/LwcLOSLoanApplicationCntrl.checkIfPanNoIsSameOrNot';//CISP-5264
import getCityStateMaster from '@salesforce/apex/Utilities.getCityStateMaster2';
import getDistrictsByState from '@salesforce/apex/Utilities.getDistrictsByState';
export function biometricOTPSelectAndUploadChange(thisvar){
    console.log('OUTPUT biometricOTPSelectAndUploadChange: ',);
    if (thisvar.selectedAadharOption==='Biometric/OTP') {
        thisvar.aadharFormOption = 'Biometric/OTP';thisvar.ScanAndUploadFlag = true;thisvar.templateScanManuallyOptions = true;thisvar.disableOCRButton = true;
        thisvar.disableUploadButtonAll = true; thisvar.cancelButton = true;} else if (thisvar.selectedAadharOption==='Scan and Upload') 
        {
        thisvar.aadharFormOption = 'Scan and Upload';thisvar.ScanAndUploadFlag = true;
        thisvar.disableOCRButton = false;
        thisvar.templateScanManuallyOptions = false; 
        thisvar.disableUploadButtonAll = false;
        thisvar.templateAadharNumberField = false;
        thisvar.templateOCRButton = false;
        thisvar.templateUploadAadhar = false;
        thisvar.templateFrontUpload = true;
        thisvar.templateBackUpload = true;
        thisvar.templateBiometricOTPOptions = false;
        thisvar.templateSubmitButton = false;
         thisvar.templateUploadButton = true;
         thisvar.cancelButton = true;
        if (FORM_FACTOR != 'Large') { thisvar.captureApp = true;  }  }
        else{
            thisvar.cancelButton = true;thisvar.disableSubmitButton = true;
        }//CISP-18956

}
export function manaulSelection(thisvar){
    thisvar.templateAadharNumberField = true;
    thisvar.disableAadharField = false;
    thisvar.disableOCRButton = true;
    thisvar.disableUploadButtonAll = true;
    thisvar.templateUploadButton = false;
    thisvar.templateOCRButton = false;
    thisvar.allFields = false;
    if (thisvar.aadharEntered != null) {  thisvar.templateBiometricOTPOptions = true; }
}
export function resendAadharBiometricData(docId){
    resendAadharBiometric({ docRecordId: docId })
      .then(result => {
        console.log('Result resendAadharBiometricData', result);
        return result;
      })
      .catch(error => {
        console.error('Error:', error);
    });
}
export function afterBioMetricFailure(thisvar){
    thisvar.modalPopUpToggleFlag = false;thisvar.allFields = false;
    thisvar.biometricCapture = false;thisvar.getBiometricDetails = false;thisvar.disableBioOtpOptions = true; thisvar.finalValue = 'OTP';thisvar.disableSubmitButton = false;
}
export function updatePanDetailsAfterCancelButton(thisvar){
    const docFields={};
    if(thisvar.documentRecordId){
        docFields[DOC_ID_FIELD.fieldApiName] = thisvar.documentRecordId;
        docFields[KYC_name.fieldApiName] = thisvar.kycName;
        if(thisvar.aadhaarSeedingStatus){docFields[AadhaarSeedingStatus.fieldApiName] = thisvar.aadhaarSeedingStatus;}
        docFields[PAN_No.fieldApiName] = thisvar.kycPanNo;
        docFields[Front_Upload_Attempts.fieldApiName] = 0;
        docFields[Golden_Source_Attempts.fieldApiName] = 0;//CISP-19203
        thisvar.updateRecordDetails(docFields);
    }
}
export {stateCity,City,cityCheckMaster,UserNameFld,userEmailFld,Gender__c,Age__c,KYC_State__c,KYC_City__c,KYC_District__c,Salutation__c,DL_Type__c,Documents__c,First_Name__c,Last_Name__c,Father_Name__c,KYC_DOB__c,Address__c,KYC_Pin_Code__c,Proof_of_Address_POA__c,Mobile_number__c,Proof_of_Identity_POI__c,Aadhaar_Enrollment_Number__c,PAN_acknowledgement_number__c,Estimated_annual_income__c,Amount_of_transaction__c,Date_of_transaction__c,Number_of_persons_involved_in_the_transa__c,APP_ID_FIELD,AADHAR_NO_FIELD,DOC_ID_FIELD,DOCUMENT_NAME,APPLICANT_TYPE,PRODUCT_TYPE,DocumentType,IsActive,BMDSensorNo};

export async function checkIfPanNoIsSame(panNo,applicantId,leadId,thisvar){
    console.log('OUTPUT checkIfPanNoIsSame: ');
    await checkIfPanNoIsSameOrNot({ panNo: panNo , applicantId: applicantId, leadApplicationId : leadId })
      .then(result => {
        console.log('Result', result);
         if(result && result.length > 0 && result[0].samePanUploaded){thisvar.successToast('Error', `Please select different Pan. It is already uploaded for ${result[0].applicantType}`, 'error');thisvar.cancelYes();}
      })
      .catch(error => {
        console.error('Error:', error);
    });
}
export function uploadDoneConditions(ref) {
    if(ref.donefrontflagCustomerImage && ref.donebackflagCustomerImage){
        if(!ref.disableAadharBackButton && !ref.isBackImageApiPositiveResponse){ref.backUploadButton=false;}
        if(!ref.disableAadharFrontButton && !ref.isimageApiPositiveResponse){ref.frontUploadButton=false;}
        if(!ref.frontUploadExhaustedFlag){
            if(!ref.disableAadharFrontButton) {ref.disableAadharFrontButton=false;}
            ref.frontUploadRedCross=false;}
        if(!ref.backUploadExhaustedFlag) {ref.backUploadRedCross=false;}
        ref.disableRadioButtonPanForm60=true;
        ref.modalPopUpUpload=false;
        if(ref.type===ref.label.AadhaarCard) {ref.ScanAndUploadFlag=false;}
        ref.frontBackDocAuthUploadButtons=true;
        ref.templateBackUpload = true;
        ref.successToast('All Uploaded', 'Done', 'success');
    }else if(ref.doneflagAadharImage == true){
        ref.frontBackDocAuthUploadButtons=false;
        ref.disableUploadButtonAll=true;
        ref.templateOCRButton=true;
        ref.disableOCRButton=false;
        ref.cancelButton=true;
        ref.modalPopUpUpload=false;
    }else if (ref.donefrontflagCustomerImage == true && ref.type == ref.label.PanCards) {
        ref.panFlag=false;
        ref.form60Flag=false;
        ref.disableRadioButtonPanForm60=true;
        ref.frontBackDocAuthUploadButtons=true;
        ref.templateBackUpload=false;
        ref.cancelButton=false;
        ref.allFields=true;
        ref.templateExPanFields=false;
        ref.modalPopUpUpload=false;
        ref.frontUploadButton=false;
        ref.frontUploadRedCross=false;
        ref.successToast('All Uploaded', 'Done', 'success');
    }else if (ref.donefrontflagCustomerImage == true && ref.type == ref.label.Form60DocumentType) {
        ref.frontBackDocAuthUploadButtons=false;
        ref.cancelButton=true;
        ref.doneDisable1=false;
        ref.isForm60= true;ref.form60Flag=false;
        ref.disableUploadButtonAll=true;
        ref.modalPopUpUpload=false;
        ref.frontUploadButton=false;
        ref.frontUploadRedCross=false;
    } else if (ref.donefrontflagCustomerImage == true && ref.type == ref.label.GST_CERT) {
        ref.frontBackDocAuthUploadButtons=false;
        ref.cancelButton=true;
        ref.doneDisable1=false;
        ref.disableUploadButtonAll=true;
        ref.modalPopUpUpload=false;
        ref.allFields=false;ref.templateExPanFields=false;
        ref.frontUploadButton=false;
        ref.frontUploadRedCross=false;
    } else if (ref.donefrontflagCustomerImage == true && ref.type == ref.label.CIN_CERT) {
        ref.frontBackDocAuthUploadButtons=false;
        ref.cancelButton=true;
        ref.doneDisable1=false;
        ref.disableUploadButtonAll=true;
        ref.modalPopUpUpload=false;
        ref.allFields=false;ref.templateExPanFields=false;
        ref.frontUploadButton=false;
        ref.frontUploadRedCross=false;
    }else if (ref.doneflagAadharImage == false && ref.type == ref.label.AadhaarCard && ref.aadharFormOption == 'Biometric/OTP') {
        ref.cancelButton=true; ref.successToast('Warning!', 'Please upload Aadhar document', 'warning');
    }else if (ref.donefrontflagCustomerImage == true && ref.donebackflagCustomerImage == false
        && ![ ref.label.Form60DocumentType ,ref.label.PanCards ,ref.label.GST_CERT, ref.label.CIN_CERT].includes(ref.type)) {
        ref.cancelButton=true; ref.successToast('Warning!', 'Please upload KYC Back also', 'warning');
    }else if (ref.donefrontflagCustomerImage == false && ref.donebackflagCustomerImage == true
        && ref.type !== ref.label.Form60DocumentType && ref.type !== ref.label.PanCards) {
        ref.cancelButton=true; ref.successToast('Warning!', 'Please upload KYC Front also', 'warning');
    }else if (ref.donefrontflagCustomerImage == false && ref.type == ref.label.PanCards) {
        ref.cancelButton=true;ref.successToast('Warning!', 'Please upload PAN document', 'warning');
    }else if (ref.donefrontflagCustomerImage == false && ref.type == ref.label.Form60DocumentType) {
        ref.cancelButton=true; ref.successToast('Warning!', 'Please upload Form 60 document', 'warning');
    }else{
        ref.cancelButton=true; ref.successToast('Warning!', 'Please Upload KYC Front and Back', 'warning');
    }
    
}

// SFTRAC-542 - START - Moved the same code from main Js to Helper only and replace ref. to ref.
export function dlApiRequestHelper(ref) {
    ref.kycDOB = ref.template.querySelector('lightning-input[data-id=kycDobId]').value;
    ref.kycNo = ref.template.querySelector('lightning-input[data-id=kycNoId]').value;
    var newDobFormat = ref.kycDOB.split("-").reverse().join(""); 
    let kycDlDetails = {
        'applicantId': ref.currentapplicationid,
        'dateOfBirth': newDobFormat,
        'dlNumber': ref.kycNo,
        'loanApplicationId': ref.currentoppid  };
    doDLCallout({ 'kycDlDetailRequest': JSON.stringify(kycDlDetails) }).then(result => {
        ref.isSpinnerMoving = false;
        const obj = JSON.parse(result);
        if (obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Status == 'Pass') {
            var responseData = obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Operations.Operation[0].Data.Response.RawResponse;
            responseData = responseData.replace('status-code', 'statuscode');
            responseData = responseData.replace('non-transport', 'nontransport');
            const parsedRespData = JSON.parse(responseData);
            if (parsedRespData.result.dl.statuscode==='103') {
                ref.successToast('Error', 'Incorrect Id Number', 'error');
            } else if (parsedRespData.result.dl.statuscode==='102') {
                ref.successToast('Error', 'Incorrect DOB', 'error'); }else{
                var fullName = parsedRespData.result.dl.result.name;
                var apiResFirstName = "";
                var apiResLastName = "";
                var expiryDateResp = "";
                if (fullName.split(" ").length > 1) {
                    apiResLastName = fullName.substring(fullName.lastIndexOf(" ") + 1);
                    apiResFirstName = fullName.substring(0, fullName.lastIndexOf(' '));
                }else{
                    apiResFirstName = fullName;
                }
                if (parsedRespData.result.dl.result.validity.transport !== "") {
                    expiryDateResp = parsedRespData.result.dl.result.validity.transport;
                } else if (parsedRespData.result.dl.result.validity.nontransport !== "") {
                    expiryDateResp = parsedRespData.result.dl.result.validity.nontransport;
                }
                let issueDate = parsedRespData.result.dl.result.issue_date.split("-").reverse().join("-");
                let expiryDate = expiryDateResp.substring(expiryDateResp.lastIndexOf(" ") + 1).split("-").reverse().join("-");
                ref.kycName = fullName == '' ? ref.kycName : fullName;
                ref.firstName = apiResFirstName == '' ? ref.firstName : apiResFirstName;
                ref.lastName = apiResLastName == '' ? ref.lastName : apiResLastName;
                ref.kycIssuanceDate = issueDate == '' ? ref.kycIssuanceDate : issueDate;
                ref.kycExpiryDate = expiryDate == '' ? ref.kycExpiryDate : expiryDate;
                let house = obj.ResponseData.House == 'null' ? '' : obj.ResponseData.House;
                let lm = obj.ResponseData.Landmark == 'null' ? '' : obj.ResponseData.Landmark;
                ref.kycAddress1 = house + ' ' + lm;
                let street = obj.ResponseData.Street == 'null' ? '' : obj.ResponseData.Street;
                let loc = obj.ResponseData.locality == 'null' ? '' : obj.ResponseData.locality;
                let vtc = obj.ResponseData.City == 'null' ? '' : obj.ResponseData.City;
                ref.kycAddress2 = street + ' ' + loc + ' ' + vtc;
                ref.handleGoldenSourceSuccess();
                ref.successToast(obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Operations.Operation[0].Status, 'Verified successfully', 'success');
            } }
        else if (obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Status == 'Fail') {
            ref.successToast(obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Status, obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Operations.Operation[0].Errors.Error[0].Message, 'error');
        }
    }).catch(error => {
        ref.isSpinnerMoving = false;
        ref.hanldeKindlyRetryMsg = true; }); 
}
export function voterIdApiRequestHelper(ref){
    ref.kycNo = ref.template.querySelector('lightning-input[data-id=kycNoId]').value;
    let allKycVoterIdData = {
        'applicantId': ref.currentapplicationid,
        'kycNo': ref.kycNo,
        'loanApplicationId': ref.currentoppid
    };
    doVoterIdCallout({ 'kycFieldsVoterIdString': JSON.stringify(allKycVoterIdData) }).then(result => {
        ref.isSpinnerMoving = false;
        const obj = JSON.parse(result);
        if (obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Status == 'Pass') {
            var responseData = obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Operations.Operation[0].Data.Response.RawResponse;
            const parsedRespData = JSON.parse(responseData);
            if (parsedRespData.result.status==='103') {
                ref.dispatchEvent(evt);
                ref.successToast('Incorrect Id Number', '', 'error');
            }else{
                var fullName = parsedRespData.result[0].name;
                var apiResFirstName = "";
                var apiResLastName = "";
                if (fullName.split(" ").length > 1) {
                    apiResFirstName = fullName.substring(0, fullName.lastIndexOf(' '));
                    apiResLastName = fullName.substring(fullName.lastIndexOf(" ") + 1);
                }else{
                    apiResFirstName = fullName;
                    apiResLastName = fullName; }
                ref.kycName = fullName == '' ? ref.kycName : fullName;
                ref.firstName = apiResFirstName == '' ? ref.firstName : apiResFirstName;
                ref.lastName = apiResLastName == '' ? ref.lastName : apiResLastName;
                ref.kycAge = parsedRespData.result[0].age == '' ? ref.kycAge : parsedRespData.result[0].age;
                ref.currentAddressData.KYC_Pin_Code__c = parsedRespData.result[0].pincode == '' ? ref.currentAddressData.KYC_Pin_Code__c : parsedRespData.result[0].pincode;
                ref.currentAddressData.KYC_State__c = parsedRespData.result[0].state == '' ? ref.currentAddressData.KYC_State__c : parsedRespData.result[0].state.toUpperCase();
                ref.kycAddress1 = parsedRespData.result[0].house_no == '' ? ref.kycAddress1 : parsedRespData.result[0].house_no;
                ref.kycAddress2 = parsedRespData.result[0].part_name == '' ? ref.kycAddress2 : parsedRespData.result[0].part_name;
                ref.currentAddressData.KYC_City__c = parsedRespData.result[0].pc_name == '' ? ref.currentAddressData.KYC_City__c : ref.stateMaster(parsedRespData.result[0].state.toUpperCase(), parsedRespData.result[0].pc_name.toUpperCase());
                let dob = parsedRespData.result[0].dob_derived.split("/").reverse().join("-");
                ref.kycDOB = dob == '' ? ref.kycDOB : dob;
                if (parsedRespData.result[0].gender==='F') {ref.kycGender = 'FEMALE';ref.kycSalutation='Ms.';
                } else if (parsedRespData.result[0].gender==='M') {ref.kycGender ='MALE';ref.kycSalutation='Mr.';}
                ref.handleGoldenSourceSuccess(); ref.setSalutationVal();
                ref.successToast(obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Status, 'Verified successfully', 'success');
            }
            ref.handleGoldenSourceSuccess();
            ref.successToast(obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Status, 'Verified successfully', 'success');  }
        else if (obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Status == 'Fail') {
            ref.successToast(obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Status, obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Operations.Operation[0].Errors.Error[0].Message, 'error');
        }
    }).catch(error => {
        ref.isSpinnerMoving = false;
        ref.hanldeKindlyRetryMsg = true;
    }); 
}
export function passportApiRequestHelper(ref){
    ref.kycPassportFileNo = ref.template.querySelector('lightning-input[data-id=passportFileNoId]').value;
        ref.firstName = ref.template.querySelector('lightning-input[data-id=firstNameId]').value;
        ref.lastName = ref.template.querySelector('lightning-input[data-id=lastNameId]').value;
        ref.kycGender = ref.template.querySelector('lightning-combobox[data-id=genderId]').value;
        ref.kycDOB = ref.template.querySelector('lightning-input[data-id=kycDobId]').value;
        ref.kycPassportNo = ref.template.querySelector('lightning-input[data-id=passportNoId]').value;
        var newDobFormat = ref.kycDOB.split("-").reverse().join("");
        let allKycPassportIdData = {
            'applicantId': ref.currentapplicationid,
            'kycPassportFileNo': ref.kycPassportFileNo,
            'firstName': ref.firstName,
            'lastName': ref.lastName,
            'kycGender': ref.kycGender,
            'dateOfBirth': newDobFormat,
            'kycPassportNo': ref.kycPassportNo,
            'kycDLType': ref.kycDLType,
            'loanApplicationId': ref.currentoppid
        };
        doPPCallout({ 'kycFieldsPassportIdString': JSON.stringify(allKycPassportIdData) }).then(result => {
            ref.isSpinnerMoving = false;
            const obj = JSON.parse(result);
            if (obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Status == 'Pass') {
                var respData = obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Operations.Operation[0].Data.Response.RawResponse;
                respData = respData.replace('passport-verification', 'passportverification');
                const parsedRespData = JSON.parse(respData);
                if (parsedRespData.result.passportverification.statusCode == "103") {
                    ref.successToast('Error', 'Incorrect DOB', 'Error');
                }
                if (parsedRespData.result.passportverification.statusCode == "102") {
                    ref.successToast('Error', 'Incorrect Id Number', 'Error');
                }else{
                    let fName = parsedRespData.result.passportverification.result.name.nameFromPassport;
                    ref.firstName = fName == '' ? ref.firstName : fName;
                    let lName = parsedRespData.result.passportverification.result.name.surnameFromPassport;
                    ref.lastName = lName == '' ? ref.lastName : lName;
                    ref.kycName = ref.firstName + ' ' + ref.lastName;
                    let issueDate = parsedRespData.result.passportverification.result.dateOfIssue.dispatchedOnFromSource.split("/").reverse().join("-");
                    ref.kycIssuanceDate = issueDate == '' ? ref.kycIssuanceDate : issueDate;
                    let passportNo = parsedRespData.result.passportverification.result.passportNumber.passportNumberFromSource;
                    ref.kycPassportNo = passportNo == '' ? ref.kycPassportNo : passportNo;
                    ref.handleGoldenSourceSuccess();
                    ref.successToast(obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Status, 'Verified successfully', 'success');
                }
            }else if (obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Status==='Fail') {
                ref.successToast(obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Status, obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Operations.Operation[0].Errors.Error[0].Message, 'Error');
            }
        }).catch(error => {
            ref.isSpinnerMoving = false;
            ref.hanldeKindlyRetryMsg = true;
        });
}
// SFTRAC-542 - End - Moved the same code from main Js to Helper only and replace ref. to ref.

export function validatePanNumber(ref){
    let panNoElement = ref.template.querySelector('lightning-input[data-id=panNoId]');
    if(panNoElement){
        ref.kycPanNo = panNoElement.value;
        const panFouthChar = ref.kycPanNo?.charAt(3);
    
        if(panFouthChar.toUpperCase() != 'P' && (ref.isindividual || !ref.isNonIndividualBorrower || ref.entitytype == 'Proprietorship')){
            return true;
        }else if(ref.isNonIndividualBorrower){
            if((ref.entitytype == 'Pvt Ltd' || ref.entitytype == 'Public Ltd') && panFouthChar.toUpperCase() != 'C'){
                return true;
            }else if(ref.entityType == 'Partnership' && panFouthChar.toUpperCase() != 'F'){
                return true;
            }else if(ref.entitytype == 'HUF' && panFouthChar.toUpperCase() != 'H'){
                return true;
            }else if(ref.entitytype == 'Govt' && panFouthChar.toUpperCase() != 'G'){
                return true;
            }else if(ref.entitytype == 'Trust' && panFouthChar.toUpperCase() != 'T'){
                return true;
            }else if(ref.entitytype == 'Assosiation of Persons' && panFouthChar.toUpperCase() != 'A'){
                return true;
            }
        }
    }
    return false;
}
export const permanentAddressData = {};
export function handleBarrowerParmaAddress1(thisVar) {
    let address1 = thisVar.template.querySelector('lightning-input[data-id=kycAddressOneDataPId]');
    let addressL1 = address1.value;
    if (addressL1.length < 10) {
        address1.setCustomValidity(AddressValidation3);
    } else if (addressL1.length > 40) {
        address1.setCustomValidity(AddressValidation2);
    } else {
        address1.setCustomValidity("");
    }
    address1.reportValidity();
}
export function handleBarrowerParmaAddress2(thisVar) {
    let address2 = thisVar.template.querySelector('lightning-input[data-id=kycAdressTwoDataPId]');
    let addressL2 = address2.value;
    if (addressL2.length < 3) {
        address2.setCustomValidity(AddressValidation1);
    } else if (addressL2.length > 40) {
        address2.setCustomValidity(AddressValidation2);
    } else {
        address2.setCustomValidity("");
    }
    address2.reportValidity();
}
export function handleBarrowerParmaAddressPin(thisVar) {
    if (thisVar.kycPinCode && thisVar.kycPinCode.length >= 2) {
        if (parseInt(thisVar.kycPinCode.substring(0, 2)) < thisVar.minPermanentState || parseInt(thisVar.kycPinCode.substring(0, 2)) > thisVar.maxPermanentState) {
            let KycPinCodeDataIdInput = thisVar.template.querySelector('lightning-input[data-id=KycPinCodeDataPId]');
            KycPinCodeDataIdInput.setCustomValidity("Invalid pin code");
            KycPinCodeDataIdInput.reportValidity();
        } else {
            let KycPinCodeDataIdInput = thisVar.template.querySelector('lightning-input[data-id=KycPinCodeDataPId]');
            KycPinCodeDataIdInput.setCustomValidity("");
        }
    }
}
export function handleBarrowerParmaAddressCity(thisVar) {
}

export function handleBarrowerParmaAddressDistrict(thisVar) {
}

export function handleBarrowerParmaAddressState(thisVar) {
    for (let index = 0; index < thisVar.allStateData.length; index++) {
        if (thisVar.allStateData[index].value == thisVar.kycState) {
            thisVar.minPermanentState = thisVar.allStateData[index].stateMinValue;
            thisVar.maxPermanentState = thisVar.allStateData[index].stateMaxValue;
        }
    }
    thisVar.isLoading = true;
    getCityStateMaster({ stateName: thisVar.kycState }).then(response => {
        let cityData = [];
        if (response && response.length > 0) {
            for (let index = 0; index < response.length; index++) {
                let cityObject = {};
                cityObject.label = response[index].Name;
                cityObject.value = response[index].Name;
                cityObject.id = response[index].Id;
                cityData.push(cityObject);
            }
        }
        thisVar.permanentCityValue = cityData;
        thisVar.isLoading = false;
    }).catch(error => {
        const evt = new ShowToastEvent({
            title: 'Error',
            message: 'Error in getting City Details',
            variant: 'Error', });
            thisVar.dispatchEvent(evt);
    });

    thisVar.isLoading = true;
    getDistrictsByState({ stateName: thisVar.kycState}).then(response => {
        let cityData = [];
        if (response && response.length > 0) {
            for (let index = 0; index < response.length; index++) {
                let cityObject = {};
                cityObject.label = response[index].Name;
                cityObject.value = response[index].Name;
                cityObject.id = response[index].Id;
                cityData.push(cityObject);
            }
        }
        thisVar.permanentDistrictValue = cityData;
        thisVar.isLoading = false;
    }).catch(error => {
        thisVar.isLoading = false;
        const evt = new ShowToastEvent({
            title: 'Error',
            message: 'Error in getting District Details',
            variant: 'Error', });
            thisVar.dispatchEvent(evt);
    });
}