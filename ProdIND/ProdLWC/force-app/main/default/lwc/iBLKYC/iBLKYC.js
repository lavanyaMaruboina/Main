import { LightningElement, track, api } from 'lwc';

import getKYCDetails from '@salesforce/apex/ExternalCAMDataController.getKYCDetails';
import getRequestDetails_MTD from '@salesforce/apex/ViewCamController.getRequestDetails';
import AadhaarCard from '@salesforce/label/c.AadhaarCard';
import DrivingLicences from '@salesforce/label/c.DrivingLicences';
import PanCards from '@salesforce/label/c.PanCards';
import PassportCard from '@salesforce/label/c.PassportCard';
import VoterIdCard from '@salesforce/label/c.VoterIdCard';
import Signature from '@salesforce/label/c.Signature';
import CustomerImageDocumentType from '@salesforce/label/c.CustomerImageDocumentType';
import IBL_Community_Partners_URL from '@salesforce/label/c.IBL_Community_Partners_URL';

export default class iBLKYC extends LightningElement {
  @api recordId
  @api coborowwerId
  @track appNo;
  @track applicantId;
  @track coApplicantId;
    @track guarantorApplicantId;
  @track loanApplicationId;
  @track kycName;
  @track kycDOB;
  @track kycAddress;
  @track age;
  @track panNo;
  @track kycName;
  @track panInssuanceDate;
  @track aadharInssuanceDate;
  @track AdhaarNo;
  @track curResAddProof;
  @track perResAddProof;
  @track customerImageFileId;
  @track customerSignFileId;
  @track aadharFrontFileId;
  @track aadharBackFileId;
  @track panFrontFileId;
  @track baseUrl = 'https://' + location.host + '/';

  @track KYCDetails;
  residentialAddress;
  officialAddress;
  permanentAddress;
  mobileNo;
  otherResiProof;
  natureAgeProof;
  natureIdProof;
  natureResiProof;
  docTypeNameVsDocList = [];
  docmentMap;
  finalOutcome = [];

  connectedCallback() {
    try {
      this.docmentMap = new Map();
      if (this.recordId) {
        this.message = this.recordId.split('-');
        this.recordId = this.message[0];
        this.getRequestDetails();
      }
    } catch (error) {
      console.error(error);
    }
  }

  getRequestDetails() {
    getRequestDetails_MTD({ camId: this.recordId })
      .then(response => {
        if (response) {
          this.applicantId = response.applicantId;
          this.loanApplicationId = response.loanAppId;
          this.coApplicantId = response.coBorrowerApplicantId;
          this.guarantorApplicantId = response.guarantorApplicantId;
          this.getRelaedKYCDetails();
        }
      })
  }

  getRelaedKYCDetails() {
    let applicantId;
    if (this.message && this.message[1] == 'Borrower') {
      applicantId = this.applicantId;
    }
    if (this.message && this.message[1] == 'CoBorrower') {
      if(!this.coborowwerId){
        applicantId = this.coApplicantId;
      } else{
        applicantId = this.coborowwerId;
      }
    }
    if(this.message && this.message[1]=='Beneficiary'){
      applicantId = this.coborowwerId;
    }  
    if(this.message && this.message[1]=='Guarantor'){
        applicantId = this.guarantorApplicantId;
    }
    if (applicantId) {
      getKYCDetails({
        applicationID: applicantId
      }
      ).then(record => {
        this.KYCDetails = record;
        console.log('this.KYCDetails ==>> ',this.KYCDetails);
        if (this.KYCDetails) {
          this.residentialAddress = this.KYCDetails?.residentialAddress ? this.KYCDetails.residentialAddress : 'N/A';
          this.permanentAddress = this.KYCDetails?.permanentAddress ? this.KYCDetails.permanentAddress : 'N/A';
          this.officialAddress = this.KYCDetails?.officialAddress ? this.KYCDetails.officialAddress : 'N/A';
          this.otherResiProof = this.KYCDetails?.otherResiProof ? this.KYCDetails.otherResiProof : 'N/A';
          this.natureResiProof = this.KYCDetails?.natureResiProof ? this.KYCDetails.natureResiProof : 'N/A';
          this.natureAgeProof = this.KYCDetails?.natureAgeProof ? this.KYCDetails.natureAgeProof : 'N/A';
          this.natureIdProof = this.KYCDetails?.natureIdProof ? this.KYCDetails.natureIdProof : 'N/A';
          let kycDetailsList = [];
          this.KYCDetails.documentList.forEach(element => {
            this.appNo = !this.appNo ? element.Opportunity_Relation__r.Lead_number__c + '_' + element.Applicant__r.applicant_number__c : this.appNo;
            this.kycName = !this.kycName ? element.Applicant__r.Name : this.kycName;
            this.kycDOB = !this.kycDOB ? element.KYC_DOB__c : this.kycDOB;
            if (this.kycDOB != null) {
              let today = new Date();
              let dobDate = new Date(this.kycDOB);
              let age = today.getFullYear() - dobDate.getFullYear();
              if (today.getMonth() < dobDate.getMonth() || (today.getMonth() === dobDate.getMonth() && today.getDate() < dobDate.getDate())) {
                age--;
              }
              this.age = age;
            }
            this.mobileNo = !this.mobileNo ? element.Applicant__r.Contact_number__c : this.mobileNo;
            let kycDocObj = {};
            kycDocObj.docNameType = element.Document_Type__c === AadhaarCard ? 'Aadhaar' : element.Document_Type__c === DrivingLicences ? 'Driving Licence' : element.Document_Type__c === PassportCard ? 'Passport' : element.Document_Type__c === VoterIdCard ? 'Voter Id': element.Document_Type__c;
            kycDocObj.issuanceDate = element.KYC_Issuance_Date__c;
            kycDocObj.docNumber = element.Document_Type__c === AadhaarCard ? element.Aadhaar_Enrollment_Number__c : element.Document_Type__c === PanCards ? element.PAN_No__c : element.KYC_No__c;
            kycDetailsList.push(kycDocObj);
          });
          let documentKycTypeVsFileIdList = [];
          for (const key in this.KYCDetails.documentKycTypeVsFileIdMap) {
            const value = this.KYCDetails.documentKycTypeVsFileIdMap[key];
            documentKycTypeVsFileIdList.push({
              label: key,
              value: value
            })
          }
          console.log('documentKycTypeVsFileIdList',documentKycTypeVsFileIdList);
          let currentUrl = window.location.href;
          if (currentUrl && currentUrl.includes('/partners/')) {
            this.baseUrl = IBL_Community_Partners_URL;
          }
          documentKycTypeVsFileIdList.forEach(docType => {
            let kycDocObj = {};
            let docName = docType.label;
            let docNameType;
            let docBackOrfrontType;
            if (docName.includes('-')) {
              let result = docName.split('-');
              docNameType = result[0].trim();
              docBackOrfrontType = result[1].trim();              
            } else {
              docNameType = docName.trim();
            }
            docNameType = docNameType === AadhaarCard ? 'Aadhaar' : docNameType === DrivingLicences ? 'Driving Licence' : docNameType === PassportCard ? 'Passport' : docNameType === VoterIdCard ? 'Voter Id': docNameType;
            if (this.docTypeNameVsDocList.length > 0 && this.docTypeNameVsDocList.find(opt => opt.docTypeName === docNameType)) {
              kycDocObj = this.docTypeNameVsDocList.find(opt => opt.docTypeName === docNameType);
            }else if (docNameType === Signature && this.docTypeNameVsDocList.length > 0 && this.docTypeNameVsDocList.find(opt => opt.docTypeName === CustomerImageDocumentType)){
              kycDocObj = this.docTypeNameVsDocList.find(opt => opt.docTypeName === CustomerImageDocumentType);            
            }else if (docNameType === CustomerImageDocumentType && this.docTypeNameVsDocList.length > 0 && this.docTypeNameVsDocList.find(opt => opt.docTypeName === Signature)){
              kycDocObj = this.docTypeNameVsDocList.find(opt => opt.docTypeName === Signature);
            }
            kycDocObj.isApplicant = docNameType === CustomerImageDocumentType || docNameType === Signature;
            kycDocObj.notCustImage = !(docNameType === CustomerImageDocumentType || docNameType === Signature);
            kycDocObj.issuanceDate = kycDetailsList.find(opt => opt.docNameType === docNameType).issuanceDate;
            kycDocObj.docNumber = kycDetailsList.find(opt => opt.docNameType === docNameType).docNumber;
            if (docBackOrfrontType == 'Front') {
              kycDocObj.front = true;
              kycDocObj.noBackAndFront = false;
              kycDocObj.docTypeName = docNameType;
              kycDocObj.frontDocUrl = `${this.baseUrl}/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=${docType.value}`;
            } else if (docBackOrfrontType == 'Back') {
              kycDocObj.back = true;
              kycDocObj.noBackAndFront = false;
              kycDocObj.docTypeName = docNameType;
              kycDocObj.backDocUrl = `${this.baseUrl}/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=${docType.value}`;
            } else if(!(docNameType === CustomerImageDocumentType || docNameType === Signature)){
              kycDocObj.back = false;
              kycDocObj.front = false;
              kycDocObj.noBackAndFront = true;
              kycDocObj.docTypeName = docNameType;
              kycDocObj.docUrl = `${this.baseUrl}/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=${docType.value}`;
            }else if(docNameType === CustomerImageDocumentType || docNameType === Signature){
              kycDocObj.back = false;
              kycDocObj.front = false;
              kycDocObj.noBackAndFront = false;
              kycDocObj.noBackAndFront = false;
              kycDocObj.isCust = docNameType === CustomerImageDocumentType;
              kycDocObj.docTypeName = docNameType;
              if(docNameType === Signature){
                kycDocObj.signDocUrl = `${this.baseUrl}/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=${docType.value}`;
              }else
              kycDocObj.docUrl = `${this.baseUrl}/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=${docType.value}`;
            }
            this.docTypeNameVsDocList.push(kycDocObj);
          });
          console.log('## lkyc doc => ' + JSON.stringify(this.docTypeNameVsDocList));
          if(this.docTypeNameVsDocList.length >0 && this.docTypeNameVsDocList.find(opt => opt.docTypeName === CustomerImageDocumentType) && !this.docmentMap.has(CustomerImageDocumentType)){
            let arr = [];
            arr.push(this.docTypeNameVsDocList.find(opt => opt.docTypeName === CustomerImageDocumentType));
            this.docmentMap.set(CustomerImageDocumentType, arr);
          }
          this.docTypeNameVsDocList.forEach(documentType => {
            if (!this.docmentMap.has(documentType.docTypeName)) {
              let arr = [];
              arr.push(documentType);
              this.docmentMap.set(documentType.docTypeName, arr);
            }
          });
          console.log('## lkyc doc map  => ', this.docmentMap);
          for (let [key, value] of this.docmentMap) {
            this.finalOutcome = [...this.finalOutcome, { key: key, value: value }];
          }
          console.log('## lkyc finalOutcome map  => ', this.finalOutcome);
          
        }
      })
    }
  }
}