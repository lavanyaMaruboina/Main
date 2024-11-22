import KycAddress1Pattern from '@salesforce/label/c.KycAddress1Pattern';
import KycAddress2Pattern from '@salesforce/label/c.KycAddress2Pattern';
import AddressValidation1 from '@salesforce/label/c.AddressValidation1';
import AddressValidation2 from '@salesforce/label/c.AddressValidation2';
import AddressValidation3 from '@salesforce/label/c.AddressValidation3';
import getStateMasterData from '@salesforce/apex/Utilities.getStateMasterData';
import AddressnotValid from '@salesforce/label/c.AddressnotValid';
import ProductType from '@salesforce/label/c.ProductType';
import LeadNumber from '@salesforce/label/c.LeadNumber';
import getCityStateMaster from '@salesforce/apex/Utilities.getCityStateMaster2';
import LeadDetails from '@salesforce/label/c.LeadDetails';
import AgentBranchName from '@salesforce/label/c.AgentBranchName';
import CustomerFirstName from '@salesforce/label/c.CustomerFirstName';
import CustomerLastName from '@salesforce/label/c.CustomerLastName';
import CustomerPhoneNumber from '@salesforce/label/c.CustomerPhoneNumber';
import WhatsAppNumber from '@salesforce/label/c.WhatsAppNumber';
import otpSend from'@salesforce/label/c.otpSend';
import validationMsgNoalreadyReg from '@salesforce/label/c.validationMsgNoalreadyReg';
import enterLoanAmount from '@salesforce/label/c.enterLoanAmount';
import bankAccountMandotory from '@salesforce/label/c.bankAccountMandotory';
import openNewBankAccountMsg from '@salesforce/label/c.openNewBankAccountMsg';
import incomeAmountMandatory from '@salesforce/label/c.incomeAmountMandatory';
import completeField from '@salesforce/label/c.completeField';
import otpSentSuccessfully from '@salesforce/label/c.otpSentSuccessfully';
import FailResponseApi from '@salesforce/label/c.FailResponseApi';
import allSectionsClosed from '@salesforce/label/c.All_sections_are_closed';
import ProvideKYContinue from '@salesforce/label/c.Please_provide_KYC_to_continue';
import getDistrictsByState from '@salesforce/apex/Utilities.getDistrictsByState';
import kycDetailsUploaded from '@salesforce/label/c.kycDetailsUploaded';
import captureImageRequired from '@salesforce/label/c.captureImageRequired';
import noRegisteredWhatsAppBanking from '@salesforce/label/c.noRegisteredWhatsAppBanking';
import consentInitialisationRequired from '@salesforce/label/c.consentInitialisationRequired';
import Pin_code_Pattern from '@salesforce/label/c.Pin_code_Pattern';
import bankDetailsSavedSuccessfully from '@salesforce/label/c.bankDetailsSavedSuccessfully';
import coborrowesNeedsTohaveBankAccount from '@salesforce/label/c.coborrowesNeedsTohaveBankAccount';
import enterIncomeLoanAmount from '@salesforce/label/c.enterIncomeLoanAmount';
import journeyNotProceed from '@salesforce/label/c.journeyNotProceed';
import selectVehicleNumber from '@salesforce/label/c.selectVehicleNumber';
import loanDetailsSavedSuccessfully from '@salesforce/label/c.loanDetailsSavedSuccessfully';
import Permnt_Same_as_Current from '@salesforce/label/c.Permnt_Same_as_Current';
import RetrySelfe from '@salesforce/label/c.RetrySelfe';
import Mobile_Number_Error_Msg from '@salesforce/label/c.Mobile_Number_Error_Msg';
import ExceptionMessage from '@salesforce/label/c.ExceptionMessage';
import lastNameError from '@salesforce/label/c.Last_Name_Error';
import Loanamount10000 from '@salesforce/label/c.Loanamount10000';
import Loanamount175000 from '@salesforce/label/c.Loanamount175000';
import LoanAmount200000000 from '@salesforce/label/c.LoanAmount200000000';
import LoanAmount50000 from '@salesforce/label/c.LoanAmount50000';
import Incomemessage from '@salesforce/label/c.Incomemessage';
import Income5000000 from '@salesforce/label/c.Income5000000';
import Income5000 from '@salesforce/label/c.Income5000';
import Retry_Exhausted from '@salesforce/label/c.Retry_Exhausted';
import getCurrentOppRecord from '@salesforce/apex/IND_RevokeController.getCurrentOppRecord';
import getDocumentsToCheckPan from '@salesforce/apex/IND_LWC_LoanDetailsCntrl.getDocumentsToCheckPan';

import checkCountOfContentDoc from '@salesforce/apex/LwcLOSLoanApplicationCntrl.checkCountOfContentDoc' // CISP-2887 || CISP-2882
import updateDocPermanentAddProof from '@salesforce/apex/LwcLOSLoanApplicationCntrl.updatePermanentProofOfAddressInDocuments';//CISP-2883
import createAddressDeclarationDocument from '@salesforce/apex/LwcLOSLoanApplicationCntrl.createAddressDeclarationDocument';
import updateCurrentPermanentProofOfAddressInDocument from '@salesforce/apex/LwcLOSLoanApplicationCntrl.updateCurrentPermanentProofOfAddressInDocument';
import isPANForm60DocumentPresent from '@salesforce/apex/LwcLOSLoanApplicationCntrl.isPANForm60DocumentPresent';
import isAllMandatoryDocUploaded from '@salesforce/apex/LwcLOSLoanApplicationCntrl.isAllMandatoryDocUploaded';
import createPersonAccWithCustCodeAssignment from '@salesforce/apex/LwcLOSLoanApplicationCntrl.createPersonAccWithCustCodeAssignment';
import checkIfBorrowerEarning from '@salesforce/apex/LwcLOSLoanApplicationCntrl.checkIfBorrowerEarning';
import deleteIncomeDetails from '@salesforce/apex/LwcLOSLoanApplicationCntrl.deleteIncomeDetailIfNoIncomeSource';//CISP-2555
import checkToggle from '@salesforce/apex/LwcLOSLoanApplicationCntrl.checkToggle';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getVehicleDetailsRecord from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getVehicleDetailsRecord'; //SFTRAC-31
import APP_ID_FIELD from '@salesforce/schema/Applicant__c.Id';
import APPLICANT_SUBSTAGE from '@salesforce/schema/Applicant__c.Journey_Stage__c'
import INCOME_SOURCE_AVAILABLE from '@salesforce/schema/Applicant__c.Income_source_available__c';
import DECLARED_INCOME from '@salesforce/schema/Applicant__c.Declared_income__c';
import DO_YOU_HAVE_A_BANK_ACCOUNT from '@salesforce/schema/Applicant__c.Do_you_have_a_bank_account__c';
import DO_YOU_HAVE_A_BANK_ACCOUNT_WITH_IBL from '@salesforce/schema/Applicant__c.Do_you_have_a_bank_account_with_IBL__c';
import WOULD_YOU_LIKE_TO_OPEN_A_BANK_ACCOUNT from '@salesforce/schema/Applicant__c.Would_you_like_to_open_a_bank_account__c';
import LITERACY_FIELD from '@salesforce/schema/Applicant__c.Literacy__c';

import OPP_ID_FIELD from '@salesforce/schema/Opportunity.Id';
import PRODUCT_TYPE_FIELD from '@salesforce/schema/Opportunity.Product_Type__c';
import LEAD_NUMBER_FIELD from '@salesforce/schema/Opportunity.Lead_number__c';
import APPLICANT_NAME_FIELD from '@salesforce/schema/Opportunity.Applicant_Name__c';
import LOAN_AMOUNT_OPP from '@salesforce/schema/Opportunity.Loan_amount__c';
import OPP_JOURNEY_STATUS from '@salesforce/schema/Opportunity.Journey_Status__c';
import STAGE_NAME from '@salesforce/schema/Opportunity.StageName';
import LAST_STAGE_NAME from '@salesforce/schema/Opportunity.LastStageName__c';
import OPP_ACCOUNT from '@salesforce/schema/Opportunity.AccountId';
import AGENT_BL_CODE_FIELD from '@salesforce/schema/Opportunity.Agent_BL_code__c';//CISP-15769
import getBeneficiarySHPercent from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getBeneficiarySHPercent';
import TOAST_CREATE_APPLICATION_ERROR_MSG from '@salesforce/label/c.Complete_Create_Application';
import getApplicantDetail from '@salesforce/apex/Demographic.getApplicantDetail';
import validateBeneficiaryCount from '@salesforce/apex/Demographic.validateBeneficiaryCount';
import Addition_Details_Capture from '@salesforce/label/c.Addition_Details_Capture';

import getPicklistValues from '@salesforce/apex/IND_AssetDetailsCntrl.getPicklistValues';
import Applicant_OBJECT from '@salesforce/schema/Applicant__c';
import isAllApplicantsIlliterate from '@salesforce/apex/LwcLOSLoanApplicationCntrl.isAllApplicantsIlliterate';
import AEPS_INFO from '@salesforce/schema/Applicant__c.AepS_Info__c';

OPP_ID_FIELD
OPP_ACCOUNT
PRODUCT_TYPE_FIELD
LEAD_NUMBER_FIELD
APPLICANT_NAME_FIELD
STAGE_NAME
LAST_STAGE_NAME
export async function handleAepsChange(ref,evt){ref.aepsValue=evt.target.value;}
export function handleCoworkerHelper(ref) {
    if ((ref.productType == 'TW' || ref.productType == 'Tractor') && ref.firstNameValue != null && ref.lastNameValue != null && ref.phoneNoValue != null) {ref.dispatchEvent(new CustomEvent('changetocoborrower'));
        } else if ((ref.productType == 'PV' || ref.productType == 'Tractor') && (ref.checked == false || ref.doYouHaveBankAccount == false) ) { // if not earning  or bank account chec false
            ref.dispatchEvent(new CustomEvent('changetocoborrower'));            
        } else if (ref.productType == 'PV' || ref.productType == 'Tractor' ) { //CISP-2339 OR CISP-2384 - Added new if condition.
            ref.dispatchEvent(new CustomEvent('changetocoborrower'));
        } else {ref.successToast('Addition of Co-borrower is not allowed.','','error');}
}
export async function handleBeneOptions(ref){ //SFTRAC-78
    let fieldList = [];
    fieldList.push('Literacy__c');
    fieldList.push('Beneficial_Owner_Category__c');
    fieldList.push('Relationship_with_Entity__c');
    fieldList.push('Relationship_Type__c');
    let result = await getPicklistValues({'objectName' : Applicant_OBJECT.objectApiName, 'fieldList' : fieldList});
    ref.literacyFieldOptionValue = result.Literacy__c;
    ref.beneficialOwnerCategoryOptions = result.Beneficial_Owner_Category__c;
    ref.relationshipTypeOption = result.Relationship_Type__c;
    ref.relationshipTypeOptions = result.Relationship_Type__c;
    if(ref.loan.Entity_Type__c == 'Proprietorship' && ref.isTractor ){
        ref.beneficialOwnerCategoryOptions = result.Beneficial_Owner_Category__c.filter(option => option.value !== "Beneficial Owner cum Co-borrower");
    }
    let pvtpub = ['SHAREHOLDER','HOLDING COMPANY','SUBSIDIARY COMPANY','PROMOTER DIRECTOR','NOMINEE DIRECTOR','INDEPENDENT DIRECTOR','DIRECTOR - SINCE RESIGNED'];
    let bus = ['SHAREHOLDER','HOLDING COMPANY','SUBSIDIARY COMPANY','NOMINEE DIRECTOR','INDEPENDENT DIRECTOR','DIRECTOR - SINCE RESIGNED'];
    let coop = ['SHAREHOLDER','TRUSTEE','PROMOTER DIRECTOR','NOMINEE DIRECTOR','INDEPENDENT DIRECTOR','DIRECTOR - SINCE RESIGNED','OTHER'];
    let association = ['TRUSTEE','OTHER'];
    let proprietor = ['PROPRIETOR'];
    let partner = ['PARTNER'];
    let trust = ['TRUSTEE'];
    let other = ['OTHER'];
    let relOption = [];
    relOption = result.Relationship_with_Entity__c;
    if(relOption){
        if(ref.loan.Entity_Code__c == 11 ||ref.loan.Entity_Code__c == 12 ){
            ref.relationshipWithEntityOptions = relOption.filter((name) => pvtpub.includes(name.label));
        } else if(ref.loan.Entity_Code__c == 20){
            ref.relationshipWithEntityOptions = relOption.filter((name) => bus.includes(name.label));
        } else if(ref.loan.Entity_Code__c == 30){
            ref.relationshipWithEntityOptions = relOption.filter((name) => proprietor.includes(name.label));
        } else if (ref.loan.Entity_Code__c == 40){
            ref.relationshipWithEntityOptions = relOption.filter((name) => partner.includes(name.label));
        } else if (ref.loan.Entity_Code__c == 50){
            ref.relationshipWithEntityOptions = relOption.filter((name) => trust.includes(name.label));
        } else if (ref.loan.Entity_Code__c == 55 || ref.loan.Entity_Code__c == 80){
            ref.relationshipWithEntityOptions = relOption.filter((name) => other.includes(name.label));
        } else if (ref.loan.Entity_Code__c == 70){
            ref.relationshipWithEntityOptions = relOption.filter((name) => association.includes(name.label));
        } else if (ref.loan.Entity_Code__c == 60){
            ref.relationshipWithEntityOptions = relOption.filter((name) => coop.includes(name.label));
        }
    }
}
export function handleBeneShareholderPercent(ref){
    getBeneficiarySHPercent({loanAppId:ref.currentOppRecordId}).then(result=>{console.log('result------'+result)
    ref.totalSHPercent = result;});
}
export function shareHolderHelper(ref){
    let shareholderP = ref.template.querySelector('lightning-input[data-id=shareHolderPId]');
    let shareholderValue = shareholderP.value;
    ref.shareHolderPercent = shareholderValue;
    let totalPercent = Number(ref.shareHolderPercent) + Number(ref.totalSHPercent);
    if ((ref.loan.Entity_Code__c == 60 || ref.loan.Entity_Code__c == 70) && shareholderValue < 15) {
        shareholderP.setCustomValidity("Shareholder % cannot be less than 15% for this entity type");
    } else if ((ref.loan.Entity_Code__c == 30 || ref.loan.Entity_Code__c == 55) && shareholderValue < 100) {
        shareholderP.setCustomValidity("Shareholder % cannot be less than 100% for this entity type");
    } else if ((ref.loan.Entity_Code__c == 11 || ref.loan.Entity_Code__c == 12 || ref.loan.Entity_Code__c == 20 || ref.loan.Entity_Code__c == 40 || ref.loan.Entity_Code__c == 50) && shareholderValue < 10){
        shareholderP.setCustomValidity("Shareholder % cannot be less than 10% for this entity type");
    } else if (totalPercent > 100){
        shareholderP.setCustomValidity("Sum of all beneficiary Shareholder % cannot be more than 100");
    }
    else {
        shareholderP.setCustomValidity("");
    }
    shareholderP.reportValidity();        
} 
export function handleInputChange(ref, evt) {
    let name = evt.currentTarget.name; let value = evt.detail.value;
    let entityCodeMap = new Map([
        [ 'Pvt Ltd' , '11' ],
        [ 'Public Ltd' , '12' ],
        [ 'Business Entities Created by Statute', '20' ],
        [ 'Proprietorship' , '30' ],
        [ 'Partnership' , '40' ],
        [ 'Trust' , '50' ],
        [ 'HUF' , '55' ],
        [ 'Co-Operative Society' , '60' ],
        [ 'Assosiation of Persons' , '70' ],
        [ 'Govt' , '80']
      ]);
      let profileMap = new Map([
        [ 'SAL' , [{label : 'ACCOUNTANT',value : 'ACCOUNTANT'}, {label : 'BANK EMPLOYEE',value : 'BANK EMPLOYEE'}, {label : 'CONDUCTOR',value : 'CONDUCTOR'}, {label : 'CONTRACT WORKER',value : 'CONTRACT WORKER'}, {label : 'DAILY WAGES',value : 'DAILY WAGES'}, {label : 'DOCK AND MINE WORKER',value : 'DOCK AND MINE WORKER'}, {label : 'DRIVER',value : 'DRIVER'}, {label : 'EDITOR',value : 'EDITOR'}, {label : 'EMPLOYEE UNION OFFICE BEARER',value : 'EMPLOYEE UNION OFFICE BEARER'}, {label : 'EXECUTIVE',value : 'EXECUTIVE'}, {label : 'FITTER',value : 'FITTER'}, {label : 'GARAGE MECHANIC',value : 'GARAGE MECHANIC'}, {label : 'GARDENER',value : 'GARDENER'}, {label : 'GOLD SMITH',value : 'GOLD SMITH'}, {label : 'GOVERNMENT SERVANT',value : 'GOVERNMENT SERVANT'}, {label : 'HARDWARE ENGINEER',value : 'HARDWARE ENGINEER'}, {label : 'INTELLIGENCE PERSONNEL',value : 'INTELLIGENCE PERSONNEL'}, {label : 'JOB WORKER',value : 'JOB WORKER'}, {label : 'JOURNALIST',value : 'JOURNALIST'}, {label : 'JUDGE / MAGISTRATE',value : 'JUDGE / MAGISTRATE'}, {label : 'LAB TECHNICIAN',value : 'LAB TECHNICIAN'}, {label : 'LIBRARIAN',value : 'LIBRARIAN'}, {label : 'MANAGEMENT EXECUTIVE',value : 'MANAGEMENT EXECUTIVE'}, {label : 'MANAGER',value : 'MANAGER'}, {label : 'MEDICAL - REP',value : 'MEDICAL - REP'}, {label : 'MKTG EXEUCITVE/PVT COMPANY',value : 'MKTG EXEUCITVE/PVT COMPANY'}, {label : 'MUNICIPAL - CORPORATION',value : 'MUNICIPAL - CORPORATION'}, {label : 'NEWS REPORTER',value : 'NEWS REPORTER'}, {label : 'NON RESIDENT_NRI & NRE',value : 'NON RESIDENT_NRI & NRE'}, {label : 'NURSE',value : 'NURSE'}, {label : 'PENSIONER/WORKING',value : 'PENSIONER/WORKING'}, {label : 'PEON',value : 'PEON'}, {label : 'POLICE',value : 'POLICE'}, {label : 'SALES - EXEUCITVE',value : 'SALES - EXEUCITVE'}, {label : 'SOFTWARE ENGINEER',value : 'SOFTWARE ENGINEER'}, {label : 'SUPERVISOR',value : 'SUPERVISOR'}, {label : 'TEACHER / PROFESSOR',value : 'TEACHER / PROFESSOR'}, {label : 'TECHNICIAN',value : 'TECHNICIAN'}, {label : 'TELEPHONE OPERATOR/RECEPNST',value : 'TELEPHONE OPERATOR/RECEPNST'}, {label : 'WATCHMAN & SECURITY', value : 'WATCHMAN & SECURITY'}] ],
        [ 'SEP' , [{label : 'ADVOCATE',value : 'ADVOCATE'}, {label : 'CHARTERED ACCOUNTANT',value : 'CHARTERED ACCOUNTANT'}, {label : 'CLINIC',value : 'CLINIC'}, {label : 'DOCTOR',value : 'DOCTOR'}, {label : 'ENGINEER',value : 'ENGINEER'}, {label : 'LAWYER',value : 'LAWYER'}, {label : 'PHYSIOTHERAPIST',value : 'PHYSIOTHERAPIST'}, {label : 'RMP DOCTOR',value : 'RMP DOCTOR'}, {label : 'TAX CONSULTANT',value : 'TAX CONSULTANT'}] ],
        [ 'SENP', [{label : 'AGRICULTURE PRODUCE',value : 'AGRICULTURE PRODUCE'},{label : 'AGRICULTURIST',value : 'AGRICULTURIST'},{label : 'AQUACULTURE',value : 'AQUACULTURE'},{label : 'ASSOCIATION',value : 'ASSOCIATION'},{label : 'AUTO CONSULTANT',value : 'AUTO CONSULTANT'},{label : 'AUTO OWNER',value : 'AUTO OWNER'},{label : 'AUTOMOBILE ANCILLARY',value : 'AUTOMOBILE ANCILLARY'},{label : 'AUTOMOBILE DEALERS',value : 'AUTOMOBILE DEALERS'},{label : 'AUTOMOBILE MANUFACTURER',value : 'AUTOMOBILE MANUFACTURER'},{label : 'BAKERY',value : 'BAKERY'},{label : 'BAKERY & SMALL FOOD RETAILS',value : 'BAKERY & SMALL FOOD RETAILS'},{label : 'BAR OWNER',value : 'BAR OWNER'},{label : 'BEAUTY PARLOR',value : 'BEAUTY PARLOR'},{label : 'BED WORKER',value : 'BED WORKER'},{label : 'BIDI WORK',value : 'BIDI WORK'},{label : 'BLDG. CONTRACTOR',value : 'BLDG. CONTRACTOR'},{label : 'BLUE METAL',value : 'BLUE METAL'},{label : 'BOOK SHOP - RETAIL',value : 'BOOK SHOP - RETAIL'},{label : 'BRICKS - MFGR',value : 'BRICKS - MFGR'},{label : 'BROKER',value : 'BROKER'},{label : 'BUILDER',value : 'BUILDER'},{label : 'BUSINESS - MASALA POWER',value : 'BUSINESS - MASALA POWER'},{label : 'BUSINESS- STONE - SUPPLIER',value : 'BUSINESS- STONE - SUPPLIER'},{label : 'CABLE',value : 'CABLE'},{label : 'CANDLE -MFGRS',value : 'CANDLE -MFGRS'},{label : 'CANTEEN & MESS',value : 'CANTEEN & MESS'},{label : 'CARPENTER',value : 'CARPENTER'},{label : 'CATERING & PANDAL SERVICES',value : 'CATERING & PANDAL SERVICES'},{label : 'CEMENT',value : 'CEMENT'},{label : 'CERAMICS',value : 'CERAMICS'},{label : 'CHEMICALS AND DYES',value : 'CHEMICALS AND DYES'},{label : 'CHIT COMPANY',value : 'CHIT COMPANY'},{label : 'COAL MINING',value : 'COAL MINING'},{label : 'COFFEE AND TEA',value : 'COFFEE AND TEA'},{label : 'COLLECTION AGENCY',value : 'COLLECTION AGENCY'},{label : 'COMMISSION AGENCY',value : 'COMMISSION AGENCY'},{label : 'COMPUTER CENTRE',value : 'COMPUTER CENTRE'},{label : 'COMPUTER PERIPHERAL DEALER',value : 'COMPUTER PERIPHERAL DEALER'},{label : 'CONSTRUCTION ANXILLARY SERVICES / SUPPLIES',value : 'CONSTRUCTION ANXILLARY SERVICES / SUPPLIES'},{label : 'CONSTRUCTION COMPANY',value : 'CONSTRUCTION COMPANY'},{label : 'CONSTRUCTION EQUIPMENT LEASING',value : 'CONSTRUCTION EQUIPMENT LEASING'},{label : 'CONSULTANTS OPERATING FROM RESIDENCE',value : 'CONSULTANTS OPERATING FROM RESIDENCE'},{label : 'CONTRACTOR',value : 'CONTRACTOR'},{label : 'COOK',value : 'COOK'},{label : 'COOPERATIVE SOCIETY',value : 'COOPERATIVE SOCIETY'},{label : 'CYCLE - SHOP',value : 'CYCLE - SHOP'},{label : 'DAIRY FARMING',value : 'DAIRY FARMING'},{label : 'DEALER - PAINT',value : 'DEALER - PAINT'},{label : 'DECORATOR',value : 'DECORATOR'},{label : 'DIAMONDS, GEMS AND JEWELLERY',value : 'DIAMONDS, GEMS AND JEWELLERY'},{label : 'DRIVER',value : 'DRIVER'},{label : 'DRY CLEAR',value : 'DRY CLEAR'},{label : 'DYING UNIT',value : 'DYING UNIT'},{label : 'EARTH WORK',value : 'EARTH WORK'},{label : 'EDUCTIONAL INSTITUTION',value : 'EDUCTIONAL INSTITUTION'},{label : 'ELECTRICALS SHOP',value : 'ELECTRICALS SHOP'},{label : 'ELECTRICIAN',value : 'ELECTRICIAN'},{label : 'ELECTRONICS',value : 'ELECTRONICS'},{label : 'ENGINEERING & PLUMBING WORKS',value : 'ENGINEERING & PLUMBING WORKS'},{label : 'ENGINEERING GOODS',value : 'ENGINEERING GOODS'},{label : 'FABRICATION WORK BUSINESS',value : 'FABRICATION WORK BUSINESS'},{label : 'FANCY & GIFT SHOP_RETAIL',value : 'FANCY & GIFT SHOP_RETAIL'},{label : 'FEED BUSINESS',value : 'FEED BUSINESS'},{label : 'FERTILISERS',value : 'FERTILISERS'},{label : 'FILM PERSONALITY',value : 'FILM PERSONALITY'},{label : 'FINANCE CO',value : 'FINANCE CO'},{label : 'FINANCIAL SERVICES',value : 'FINANCIAL SERVICES'},{label : 'FISHER MAN',value : 'FISHER MAN'},{label : 'FISHING BUSINESS',value : 'FISHING BUSINESS'},{label : 'FLAT PROMOTER',value : 'FLAT PROMOTER'},{label : 'FLOWER STALL',value : 'FLOWER STALL'},{label : 'FOOD PRODUCTS',value : 'FOOD PRODUCTS'},{label : 'FOOTWEAR & LEATHER ARTICLES - RETAIL',value : 'FOOTWEAR & LEATHER ARTICLES - RETAIL'},{label : 'FRUITS AND VEGETABLES',value : 'FRUITS AND VEGETABLES'},{label : 'FURNITURE SHOP',value : 'FURNITURE SHOP'},{label : 'GAS AGENCY',value : 'GAS AGENCY'},{label : 'GENERAL STORES/KIRANA SHOP',value : 'GENERAL STORES/KIRANA SHOP'},{label : 'GOLDSMITH',value : 'GOLDSMITH'},{label : 'GRANITE',value : 'GRANITE'},{label : 'GROCERY SHOP',value : 'GROCERY SHOP'},{label : 'HANDLOOMS/POWERLOOMS',value : 'HANDLOOMS/POWERLOOMS'},{label : 'HARDWARE SHOP - RETAIL',value : 'HARDWARE SHOP - RETAIL'},{label : 'HINDU UNDIVIDED FAMILY',value : 'HINDU UNDIVIDED FAMILY'},{label : 'HOSPITAL',value : 'HOSPITAL'},{label : 'HOTEL AND RESTAURENT',value : 'HOTEL AND RESTAURENT'},{label : 'INTERIOR DESIGNER & DECROTORS',value : 'INTERIOR DESIGNER & DECROTORS'},{label : 'INTERNET CAFÉ',value : 'INTERNET CAFÉ'},{label : 'IRON AND STEEL',value : 'IRON AND STEEL'},{label : 'JEWELLER',value : 'JEWELLER'},{label : 'LAND DEVELOPER',value : 'LAND DEVELOPER'},{label : 'LANDLORD',value : 'LANDLORD'},{label : 'LEATHER',value : 'LEATHER'},{label : 'LIC AGENT',value : 'LIC AGENT'},{label : 'LIQUOR',value : 'LIQUOR'},{label : 'LIQUOR SHOP OWNER',value : 'LIQUOR SHOP OWNER'},{label : 'MARBLE',value : 'MARBLE'},{label : 'MECHANIC SHOP',value : 'MECHANIC SHOP'},{label : 'MEDICAL - TRANSCRIPTION',value : 'MEDICAL - TRANSCRIPTION'},{label : 'MEDICAL SHOP',value : 'MEDICAL SHOP'},{label : 'MOBILE SHOP - RETAIL',value : 'MOBILE SHOP - RETAIL'},{label : 'MONEY LENDER',value : 'MONEY LENDER'},{label : 'MUTUAL BENEFIT SOCIETY',value : 'MUTUAL BENEFIT SOCIETY'},{label : 'MUTUAL FUND',value : 'MUTUAL FUND'},{label : 'OIL AND PETROLEUM',value : 'OIL AND PETROLEUM'},{label : 'OPTICIANS',value : 'OPTICIANS'},{label : 'PAINT',value : 'PAINT'},{label : 'PAINTER',value : 'PAINTER'},{label : 'PAPER AND PACKAGING',value : 'PAPER AND PACKAGING'},{label : 'PARCEL AND COURIER',value : 'PARCEL AND COURIER'},{label : 'PETROL BUNK',value : 'PETROL BUNK'},{label : 'PHARMACEUTICALS',value : 'PHARMACEUTICALS'},{label : 'PHOTOGRAPHER',value : 'PHOTOGRAPHER'},{label : 'PLACEMENT AGENCY',value : 'PLACEMENT AGENCY'},{label : 'PLANTATION CO',value : 'PLANTATION CO'},{label : 'PLASTICS',value : 'PLASTICS'},{label : 'POLITICIAN',value : 'POLITICIAN'},{label : 'POULTRY FARMING',value : 'POULTRY FARMING'},{label : 'POWER INDUSTRY',value : 'POWER INDUSTRY'},{label : 'PREPARATION AND SPINNING OF WOOL',value : 'PREPARATION AND SPINNING OF WOOL'},{label : 'PRINTING PRESS (EXCEPT NEWSPAPER)',value : 'PRINTING PRESS (EXCEPT NEWSPAPER)'},{label : 'PRIVATE CABLE OPERATORS',value : 'PRIVATE CABLE OPERATORS'},{label : 'PROFESSIONAL ARTISTS',value : 'PROFESSIONAL ARTISTS'},{label : 'PUROHIT/PANDIT/ASTROLOGER',value : 'PUROHIT/PANDIT/ASTROLOGER'},{label : 'PVT TUTION',value : 'PVT TUTION'},{label : 'REAL ESTATE BROKER',value : 'REAL ESTATE BROKER'},{label : 'REPOSSESSION AGENCY',value : 'REPOSSESSION AGENCY'},{label : 'RICE - MERCHANT',value : 'RICE - MERCHANT'},{label : 'RICE & FLOUR MILL',value : 'RICE & FLOUR MILL'},{label : 'ROAD WORK',value : 'ROAD WORK'},{label : 'RUBBER',value : 'RUBBER'},{label : 'SALOON',value : 'SALOON'},{label : 'SAND QUARRYING',value : 'SAND QUARRYING'},{label : 'SEA FOOD',value : 'SEA FOOD'},{label : 'SEASONAL BUSINESS',value : 'SEASONAL BUSINESS'},{label : 'SECURITY AGENCY',value : 'SECURITY AGENCY'},{label : 'SHARE BROKERS',value : 'SHARE BROKERS'},{label : 'SHIPPING',value : 'SHIPPING'},{label : 'SMALL INVESTMENTS COMPANY',value : 'SMALL INVESTMENTS COMPANY'},{label : 'SPAREPARTS DEALER',value : 'SPAREPARTS DEALER'},{label : 'STALL - TEA/COFFEE/JUICE',value : 'STALL - TEA/COFFEE/JUICE'},{label : 'STAMP VENDOR',value : 'STAMP VENDOR'},{label : 'STATIONERY',value : 'STATIONERY'},{label : 'STD - ISD - PCO',value : 'STD - ISD - PCO'},{label : 'STUDIO, PHOTO LAB & VIDEOGRAPHY',value : 'STUDIO, PHOTO LAB & VIDEOGRAPHY'},{label : 'SUGAR',value : 'SUGAR'},{label : 'SUGAR MILL & DISTILLERY',value : 'SUGAR MILL & DISTILLERY'},{label : 'TAILOR/READYMADE GARMENTS',value : 'TAILOR/READYMADE GARMENTS'},{label : 'TAILORING SHOP',value : 'TAILORING SHOP'},{label : 'TELECOMMUNICATION',value : 'TELECOMMUNICATION'},{label : 'TENT- BUSINESS',value : 'TENT- BUSINESS'},{label : 'TEXTILES',value : 'TEXTILES'},{label : 'TIMBER DEPOT & SAW MILL',value : 'TIMBER DEPOT & SAW MILL'},{label : 'TIME SHARE COMPANY',value : 'TIME SHARE COMPANY'},{label : 'TOURISM',value : 'TOURISM'},{label : 'TOURS & TRAVELS',value : 'TOURS & TRAVELS'},{label : 'TRADING BUSINESS',value : 'TRADING BUSINESS'},{label : 'TRANSPORTER',value : 'TRANSPORTER'},{label : 'TRUST',value : 'TRUST'},{label : 'TUTORIAL / VOCATIONAL INSTITUTE',value : 'TUTORIAL / VOCATIONAL INSTITUTE'},{label : 'VIDEO PARLOR',value : 'VIDEO PARLOR'},{label : 'WATER SUPPLIER',value : 'WATER SUPPLIER'},{label : 'WINE SHOP OWNER',value : 'WINE SHOP OWNER'},{label : 'WOOD',value : 'WOOD'},{label : 'WORKSHOP',value : 'WORKSHOP'},{label : 'XRAY & MEDICAL LABS' , value : 'XRAY & MEDICAL LABS'}] ]
      ]);  
      
    switch (name) {
        case 'EntityTypeComboBox':
            ref.entityType = value;
            break;
        case 'ApplicationTypeInput': 
            ref.applicationTypeVal = value;
            break;
        case 'EntityName': 
            ref.loan.Entity_Name__c = value;
            break;    
        case 'EntityTypeNonInd': 
            ref.loan.Entity_Type__c = value;
            ref.loan.Entity_Code__c = entityCodeMap.get(value);
            break;
        case 'EntityCategory': 
            ref.loan.Entity_Category__c = value;
            ref.profileOptions = profileMap.get(value);
            break;
        case 'profile': 
            ref.loan.Profile__c = value;
            break;     
        case 'DateofIncorp': 
            ref.loan.Date_of_Incorporation__c = value;
            let currentDate = new Date();
            let dateToCompare = new Date(ref.loan.Date_of_Incorporation__c);
            let inputref = ref.template.querySelector('lightning-input[data-id=DateofIncorp]');
            if (dateToCompare > currentDate) {
                inputref.setCustomValidity('Please select valid date');
            } else {
                inputref.setCustomValidity('');
            }
            inputref.reportValidity();
            break;
        case 'ContactPersonName': 
            ref.loan.Contact_Person_Name__c = value;
            break;
        case 'LeadSource': 
            ref.loan.Lead_Source_Non_Ind__c = value;
            break;
        case 'ClassofActivity': 
            ref.loan.Class_of_Activity__c = value;
            break;
        case 'LoanType': 
            ref.loan.Loan_Type__c = value;
            break;
        case 'EvaluationType': 
            ref.loan.Evaluation_Type__c = value;
            break;
        case 'MajorIndustry': 
            ref.loan.Major_Industry__c = value;
            break;
        case 'MinorIndustry': 
            ref.loan.Minor_Industry__c = value;
            break;
        default:
            break;
    }}

export function handleGuarantor(ref) {
    console.log(' Dispatching the event : changetoguarantor');
    ref.dispatchEvent(new CustomEvent('changetoguarantor'));
}

export function openBankAccountHandlerhelper(ref,event){
    ref.openNewBankAccount = event.target.checked;
    if(!ref.openNewBankAccount){ref.disableAeps=true;ref.aepsValue=null;}    
    if(ref.openNewBankAccount){ref.disableAeps=false}
     if (!ref.doYouHaveBankAccount && !ref.doYouHaveBankAccountWithIBL && !ref.openNewBankAccount) {
        ref.template.querySelector('lightning-input.withIBLBankAccount').checked = false;
            if (ref.currenttab === ref.label.Borrower && !ref.isTractor){
                ref.successToast(ref.label.coBorrowerAdditionMandatory,'','Warning');//CISP-2500
            } else if(ref.currenttab === ref.label.CoBorrower && !ref.isTractor){
                ref.successToast(ref.label.coBorrowerAdditionMandatory,'','error');//CISP-2500
                return null;
            }
        } else if (!ref.doYouHaveBankAccount && !ref.doYouHaveBankAccountWithIBL && ref.openNewBankAccount) {
            ref.template.querySelector('lightning-input.withIBLBankAccount').checked = false;
            ref.disabledBankAccWithIBL=true;
        }
}

export async function handleNext(ref) {
    try{
        if(ref.tabcounter < 0){ref.tabcounter++;}//CISP-2378//CISP-2465
        if (ref.currentStep === ref.label.userDetails) {// CISP-2887 || CISP-2882
            let result = await checkCountOfContentDoc({ docId: ref.documentRecordId });
            if(!ref.isNonIndividualBorrower && !result  && ref.leadSource != 'D2C'){ref.iconButtonCaptureImage = false;ref.customerImageDisable = false;ref.imageUploadDisable = false;ref.isStepOne = true; ref.successToast('Error','Please upload customer image and click on Done button after upload','error'); return;}else{
            if(ref.currentStage==='Credit Processing' || (ref.currentStageName === 'Loan Initiation' && ref.lastStage !== 'Loan Initiation')){
               if(ref.isTractor && ref.isNonIndividualBorrower){
                ref.currentStep = ref.label.capturePANOrOtherKyc;
                ref.isStepFour = true;
                ref.isStepOne = false;}
                else{
                ref.currentStep = ref.label.captureCurrentResidentialAddress;ref.isStepTwo = true;ref.isStepOne = false;
                }
            } else {
            let firstNameInput = ref.template.querySelector('lightning-input[data-id=firstNameId]');
            let lastNameInput = ref.template.querySelector('lightning-input[data-id=lastNameId]');
            let phoneNoInput = ref.template.querySelector('lightning-input[data-id=phoneNumberId]');
            let agentBLCodeInput = ref.template.querySelector('.agentCss');
            let whatsAppNumberInput;
            if (ref.whatsAppNumberValue != '' || ref.whatsAppNumberValue != null) {
                if (ref.showCopiedWhatsAppNumber) {
                    whatsAppNumberInput = ref.template.querySelector('lightning-input[data-id=checkedWhatsAppNumberId]');
                } else {
                    whatsAppNumberInput = ref.template.querySelector('lightning-input[data-id=whatsAppNumberId]');
                }
                if (whatsAppNumberInput != null) {
                    whatsAppNumberInput.reportValidity();
                }}
            firstNameInput?.reportValidity();
            lastNameInput?.reportValidity();
            phoneNoInput.reportValidity();
            agentBLCodeInput.reportValidity();
            if (((firstNameInput?.validity?.valid == true && lastNameInput?.validity?.valid == true) || (ref.isNonIndividualBorrower && ref.isTractor)) && phoneNoInput.validity.valid == true && whatsAppNumberInput.validity.valid == true) {
                if (!ref.iconButton || (!ref.isNonIndividualBorrower && !ref.customerImageDisable && !ref.iconButtonCaptureImage ) || ( !ref.isNonIndividualBorrower && !ref.iconButtonCaptureUpload && !ref.imageUploadRedCross)) {
                    ref.successToast(ref.label.provideConsentUploadImage,'','error')
                    return null;
                }
                if(!ref.createApplicationDisable && ref.isNonIndividualBorrower){
                    ref.successToast(TOAST_CREATE_APPLICATION_ERROR_MSG,'','error');
                    return null;
                } //UAT Adhoc Bug fix change - Chaynnitt Agarwal
                const oppFields = {};//Updating opportunity record
                oppFields[OPP_ID_FIELD.fieldApiName] = ref.currentOppRecordId;
                oppFields[OPP_ACCOUNT.fieldApiName] = ref.agentBLCodeValue;
                oppFields[PRODUCT_TYPE_FIELD.fieldApiName] = ref.productType=='TW' ? 'Two Wheeler' : ref.productType=='Tractor' ? 'Tractor' : 'Passenger Vehicles';
                oppFields[LEAD_NUMBER_FIELD.fieldApiName] = ref.leadNumber;
                oppFields[AGENT_BL_CODE_FIELD.fieldApiName] = ref.agentBLCodeLabel;//CISP-15769
                if(ref.currenttab == ref.label.Borrower){oppFields[APPLICANT_NAME_FIELD.fieldApiName] = ref.firstNameValue + ' ' + ref.lastNameValue;}
                ref.updateRecordDetails(oppFields);
                const applicantsFields = {};//Updating Applicant record
                applicantsFields[APP_ID_FIELD.fieldApiName] = ref.applicantId;
                applicantsFields[APPLICANT_SUBSTAGE.fieldApiName] = (ref.isTractor && ref.isNonIndividualBorrower) ? ref.label.capturePANOrOtherKyc :  ref.label.captureCurrentResidentialAddress;
                ref.updateRecordDetails(applicantsFields).then(result => {
                        ref.successToast('Success',ref.label.detailsSaved,'success');
                        if(ref.isTractor && ref.isNonIndividualBorrower){
                            ref.currentStep = ref.label.capturePANOrOtherKyc;
                            ref.isStepFour = true;
                            ref.isStepOne = false;
                        }else{
                            ref.currentStep = ref.label.captureCurrentResidentialAddress;
                            ref.isStepTwo = true;
                            ref.isStepOne = false;
                        }
                        // const newApplicantEvent = new CustomEvent("newapplicantevent", {detail: {applicantId: ref.applicantId, applicantType: ref.currenttab}});
                        // ref.dispatchEvent(newApplicantEvent);
                    }).catch(error => {
                        ref.successToast('Error',error,'error');
                        return;}); } }}            
        } else if (ref.currentStep === ref.label.captureCurrentResidentialAddress) {
            if (ref.currentPermanentcheckBoxValue) {ref.currentStep = ref.label.capturePANOrOtherKyc;ref.isStepTwo = false;ref.isStepFour = true;
                updateDocPermanentAddProof ({recordId: ref.recordid}).then(response => {});//CISP-2883
            }else if(ref.checkBoxValue){let result = await createAddressDeclarationDocument({'loanAppId' : ref.recordid, 'applicantId' : ref.applicantId});if(result){ref.currentStep = ref.label.capturePermanentResidentialAddress;ref.isStepTwo = false;ref.isStepThreeV2 = true;ref.disableCurrentAddress=true;}else{ref.successToast('Error','Somethind went wrong!','error');return;}
            }else if (((!ref.checkBoxValue && (ref.aadharButton || ref.passportButton || ref.voterIdButton || ref.drivingLicenseButton))) || ref.leadSource === 'D2C') {ref.currentStep = ref.label.capturePermanentResidentialAddress;ref.isStepTwo = false;ref.isStepThree = true;
            } else if (!ref.homePageFlag) {ref.successToast(ref.label.uploadatleastOneDocument,'','error');return null;}
                const applicantsFields = {};
                applicantsFields[APP_ID_FIELD.fieldApiName] = ref.applicantId;
                applicantsFields[APPLICANT_SUBSTAGE.fieldApiName] = ref.currentPermanentcheckBoxValue ? ref.label.capturePANOrOtherKyc : ref.label.capturePermanentResidentialAddress; 
                ref.updateRecordDetails(applicantsFields);
                if(ref.checkBoxValue || !ref.currentPermanentcheckBoxValue){const oppFields = {};oppFields[OPP_ID_FIELD.fieldApiName] = ref.recordid;oppFields[OPP_JOURNEY_STATUS.fieldApiName] = 'Non STP';ref.updateRecordDetails(oppFields);}
        }else if (ref.currentStep === ref.label.capturePermanentResidentialAddress) {
                const applicantsFields = {};
                applicantsFields[APP_ID_FIELD.fieldApiName] = ref.applicantId;
                applicantsFields[APPLICANT_SUBSTAGE.fieldApiName] = ref.label.capturePANOrOtherKyc;
            if ((ref.checkBoxValue || ref.selectedValuePermanentAdd ) && !ref.aadharButton && !ref.passportButton && ref.voterIdButton == false && ref.drivingLicenseButton == false) {
                ref.journeyPopUP = true;
            } else if (ref.counter_current_kyc == 1 && ref.checkBoxValuePermanent && ref.counter_permanent_kyc == 0) {
                ref.currentStep = ref.label.capturePANOrOtherKyc;ref.isStepThree = false;ref.isStepThreeV2=false;ref.isStepFour = true;ref.updateRecordDetails(applicantsFields);
            } else if (ref.counter_current_kyc == 1 && ref.counter_permanent_kyc == 1) {
                ref.currentStep = ref.label.capturePANOrOtherKyc;ref.isStepThree = false;ref.isStepThreeV2=false;ref.isStepFour = true;ref.updateRecordDetails(applicantsFields);
            } else if ((ref.checkBoxValue ) && ref.counter_current_kyc == 0 && ref.nextFlagForThirdStep == false && ref.counter_permanent_kyc == 1) {
                ref.currentStep = ref.label.capturePANOrOtherKyc;ref.isStepThree = false;ref.isStepThreeV2=false;ref.isStepFour = true;ref.updateRecordDetails(applicantsFields);
            } else if (!ref.homePageFlag) {
                if(ref.leadSource === 'D2C') {ref.currentStep = ref.label.capturePANOrOtherKyc;ref.isStepThree = false;ref.isStepFour = true;
                }else if(ref.isStepThreeV2){ref.successToast('Aadhaar Biometric is mandatory.','','error');}else{ref.successToast(ref.label.uploadatleastOneDocument,'','error');}
                return null;}
        } else if (ref.currentStep === ref.label.capturePANOrOtherKyc) {let result = await isPANForm60DocumentPresent({'applicantId':ref.applicantId});updateCurrentPermanentProofOfAddressInDocument({appId: ref.applicantId}).then(res =>{console.log(res,'res')}).catch(err=>{console.log(err,'err')});if(ref.leadSource === 'D2C'){ref.goToCaptureDedupe();return null;}
            let response;
            if(ref.isNonIndividualBorrower && ref.isTractor){
                response = await isAllMandatoryDocUploaded({'loanApplicationId': ref.recordid,'applicantId':ref.applicantId});
            }
            if(result && ref.form60DocId != null && ref.counter_pan_kyc <= 2 && !ref.homePageFlag){ref.successToast('This proposal is not eligible for e-agreement','','warning');ref.goToCaptureDedupe();return null;}//CISP-133
            if ((result && ref.panDocId != null && ref.panButton == true && (ref.aadharButton == true || ref.passportButton == true || ref.voterIdButton == true || ref.drivingLicenseButton == true)) || (response && ref.isTractor && ref.isNonIndividualBorrower)) {
                ref.goToCaptureDedupe();        
            } else if (!response && ref.isTractor && ref.isNonIndividualBorrower) {
                ref.successToast('Please upload mandatory documents for borrower','','error');
                return null;
            } else if (result && ref.form60DocId != null && ref.panButton == true && ref.counter_pan_kyc > 2) {
                ref.goToCaptureDedupe();  
            }else if (result && ref.form60DocId != null && ref.counter_pan_kyc <= 2 && !ref.homePageFlag) {
                ref.successToast(ref.label.updateAtleast2documents,'','error');
                return null;
            } else if (!ref.homePageFlag) {
                ref.successToast(ref.label.updatePanForm60document,'','error');
                return null;
            }
        } else if (ref.currentStep === ref.label.captureDedupe) {
            let isSelected = ref.template.querySelector('c-l-W-C_-L-O-S_-Customer-Dedupe').customerSelectionCheckOnNextBtnClick();
            if (!isSelected) {return;} //If result returned false then next step will be change on popup modals ok btn action
            let isOptionSelected = ref.template.querySelector('c-l-W-C_-L-O-S_-Customer-Dedupe').withDrawLeadOnNextBtnClick();if (!isOptionSelected) {return;}
             if (!ref.currenttab || ref.currenttab == ref.label.Borrower) {//If result returned true then next step will change without any popup modal alert
                const applicantsFields = {};
                applicantsFields[APP_ID_FIELD.fieldApiName] = ref.applicantId;
                applicantsFields[APPLICANT_SUBSTAGE.fieldApiName] = ref.label.vehicleDedupes;
                await ref.updateRecordDetails(applicantsFields);
                ref.currentStep = ref.label.vehicleDedupes;
                ref.isStepFive = false;
                ref.isStepSix = true;
            } else if (ref.currenttab !== ref.label.Borrower) {
                const applicantsFields = {};
                applicantsFields[APP_ID_FIELD.fieldApiName] = ref.applicantId;
                applicantsFields[APPLICANT_SUBSTAGE.fieldApiName] = ref.label.DeclaredIncomeRequiredLoanAmount;
                await ref.updateRecordDetails(applicantsFields);
                ref.showLoanAmount = false;
                ref.currentStep = ref.label.DeclaredIncomeRequiredLoanAmount;
                ref.isStepFive = false;
                ref.isStepSeven = true;
            }
            createPersonAccWithCustCodeAssignment({applicantId: ref.applicantId, updateCustCode: true}).then(response => {
                if(response.status === 'error'){ref.successToast(response.message,'','error');
                }
            }).catch(error => {});
        } else if (ref.currentStep === ref.label.vehicleDedupes) {
            if(ref.currentStage!='Credit Processing' || (ref.currentStageName !== 'Loan Initiation' && ref.lastStage === 'Loan Initiation')){
            let isSelectedVehicleType;
            let isVerifiedVehicleType;
            console.log('++++isSelectedVehicleType1 ',isSelectedVehicleType);
            //SFTRAC-31 Starts
                if(ref.productType =='Tractor'){
                    //isSelectedVehicleType = ref.template.querySelector('c-l-W-C_-L-O-S_-Tractor-Vehicle-Dedupe').vehicleTypeSelected();
                    isVerifiedVehicleType = ref.template.querySelector('c-l-W-C_-L-O-S_-Tractor-Vehicle-Dedupe').vehicleTypeVerified();
                    console.log('++++isSelectedVehicleType11 ',isSelectedVehicleType);
                    await getVehicleDetailsRecord({loanApplicationId : ref.recordid}).then(response =>{ 
                        const vehicledetailsList = response.vehicledetailsList; 
                        if(vehicledetailsList && vehicledetailsList.length >0){
                            isSelectedVehicleType = true;
                        }else{
                            isSelectedVehicleType = false;          
                        }
                    }).catch(error => { 
                            console.log('vehicleTypeSelected getCurrentOppRecord Error:: ',error);
                    });
                }else{
                    isSelectedVehicleType = ref.template.querySelector('c-l-W-C_-L-O-S_-Vehicle-Dedupe').vehicleTypeSelected();
}
                console.log('++++isSelectedVehicleType22 ',isSelectedVehicleType);
            if (!isSelectedVehicleType && !ref.homePageFlag && ref.productType !='Tractor') {
                ref.successToast('Select vehicle type','','error');
                return null;}else if(!isSelectedVehicleType && ref.productType =='Tractor'){
                    console.log('++++ELSE isSelectedVehicleType ',isSelectedVehicleType);
                    ref.successToast('Please add atleast one Vehicle Details record to procced','','error');
                    return null;
                }else if(!isVerifiedVehicleType && ref.productType =='Tractor'){
                    ref.successToast('Please verify all vehicle detail records to proceed','','error');
                    return null;
                }
            if (ref.vehicleType !== undefined && ref.vehicleType !== 'New' && ref.productType !='Tractor') {
                //let isVehicleRegNumber = ref.template.querySelector('c-l-W-C_-L-O-S_-Vehicle-Dedupe').vehicleRegisterationNumber();
let isVehicleRegNumber;
                /*if(ref.productType =='Tractor'){
                    isVehicleRegNumber = ref.template.querySelector('c-l-W-C_-L-O-S_-Tractor-Vehicle-Dedupe').vehicleRegisterationNumber();
                }else{*/
                    isVehicleRegNumber = ref.template.querySelector('c-l-W-C_-L-O-S_-Vehicle-Dedupe').vehicleRegisterationNumber();
                //}
                if (!isVehicleRegNumber && !ref.homePageFlag) {
                ref.successToast(ref.label.selectVehicleNumber,'','error');
                    return null;
                } else if (isVehicleRegNumber == false) { ref.vehicleVerified = false;  ref.verifyButton = false;ref.verifyChecked = false;
                }
            }
            if (ref.productType != 'Tractor' && ref.verifyChecked == false && ref.vehicleType != 'New' && ref.vehicleType != undefined && !ref.homePageFlag) {
                ref.successToast(ref.label.verifyVehicleDedupe,'','error');
                return null;
            } else if (ref.vehicleType == undefined && !ref.homePageFlag) {
                ref.successToast(ref.label.verifyVehicleDedupeBeforeNextScreen,'','error');
                return null;  }}
        if (ref.vehicleType == 'New' || ref.vehicleVerified == true || ref.verifyButton == true) {
                let response = await getCurrentOppRecord({'loanApplicationId': ref.recordid});
                let isRevokedLoanApplication = false;
                if(response && response.length > 0 && response[0].Parent_Loan_Application__r && response[0].Parent_Loan_Application__r.Is_Revoked__c == true){
                    isRevokedLoanApplication = true;
                }
                if(isRevokedLoanApplication && ref.isTractor){
                    if(ref.currentStageName === 'Loan Initiation' && ref.lastStage === 'Loan Initiation' && ref.tabcounter >= 0 && ref.currentJourneyStage && ref.currentJourneyStage === ref.label.vehicleDedupes){
                        const oppFields = {};
                        oppFields[OPP_ID_FIELD.fieldApiName] = ref.recordid;
                        oppFields[STAGE_NAME.fieldApiName] = 'Asset Details';
                        oppFields[LAST_STAGE_NAME.fieldApiName] = 'Asset Details';
                        await ref.updateRecordDetails(oppFields)
                        const applicantsFields = {};
                        applicantsFields[APP_ID_FIELD.fieldApiName] = ref.applicantId;
                        applicantsFields[APPLICANT_SUBSTAGE.fieldApiName] = ref.label.gattingAndScreening;
                        await ref.updateRecordDetails(applicantsFields);
                        ref.successToast(ref.label.vehicleDedupeDetailsSaved,'','success');
                        window.location.reload();
                    }else{
                        ref.currentStep = ref.label.DeclaredIncomeRequiredLoanAmount;
                        ref.isStepSeven = true;
                        ref.isStepSix = false;
                    }
                }
                else{
                ref.currentStep = ref.label.DeclaredIncomeRequiredLoanAmount;
                ref.isStepSeven = true;
                ref.isStepSix = false;
                if(ref.currentStage!='Credit Processing' || (ref.currentStageName !== 'Loan Initiation' && ref.lastStage === 'Loan Initiation')){
                    ref.successToast(ref.label.vehicleDedupeDetailsSaved,'','success');
                const applicantsFields = {};
                applicantsFields[APP_ID_FIELD.fieldApiName] = ref.applicantId;
                applicantsFields[APPLICANT_SUBSTAGE.fieldApiName] = ref.label.DeclaredIncomeRequiredLoanAmount;
                ref.updateRecordDetails(applicantsFields); }
                }
            }
        } else if (ref.currentStep === ref.label.DeclaredIncomeRequiredLoanAmount) {
            checkIfBorrowerEarning({ loanApplicationId: ref.recordid}).then(response => {
                ref.isBorrowerEarning = response;
            }).catch(error => {});
            if(ref.currentStage==='Credit Processing' || (ref.currentStageName === 'Loan Initiation' && ref.lastStage !== 'Loan Initiation')) {
                ref.currentStep = ref.label.bankAccountCheck;ref.isStepSeven = false;ref.isStepEight = true;
                // if(ref.checked===false){deleteIncomeDetails({ loanApplicationId: ref.recordid}).then({});}//CISP-2555
            } else {
                let loanAmountInput = ref.template.querySelector('.loanAmt');
                if (loanAmountInput !== undefined && loanAmountInput !== null) {loanAmountInput.reportValidity();}
                let DeclaredAmountInput = ref.template.querySelector('.incomeDec');
                if (DeclaredAmountInput !== undefined && loanAmountInput !== null) { DeclaredAmountInput.reportValidity();}
                if(parseInt(ref.loanAmount) >= 1000000 && ref.currenttab == ref.label.Borrower && ref.leadSource != 'D2C'){ 
                    let resultofPan =  await getDocumentsToCheckPanValid(ref.currentOppRecordId);if(!resultofPan){ref.successToast('Error','Required Loan amount is >=10 Lakhs; hence, PAN is mandatory. Please withdraw this lead and create a new lead by uploading PAN or change the Loan amount','error');return null;}}
                if (ref.currenttab == ref.label.CoBorrower && ref.isBorrowerEarning === false && ref.checked === false && !ref.isTractor) {      
                    ref.successToast(ref.label.eitherBorrowerCoborrowerIncomeSourceAvail,'','error');}
            else if ((ref.currenttab == ref.label.Borrower && loanAmountInput.validity.valid == true && DeclaredAmountInput.validity.valid == true)
                || (ref.currenttab !== ref.label.Borrower && DeclaredAmountInput.validity.valid == true)) {
                    const oppFields ={};
                    oppFields[OPP_ID_FIELD.fieldApiName] = ref.currentOppRecordId;
                    oppFields[LOAN_AMOUNT_OPP.fieldApiName] = ref.loanAmount;
                    ref.updateRecordDetails(oppFields);                
                    const applicantsFields = {};
                    applicantsFields[APP_ID_FIELD.fieldApiName] = ref.applicantId;
                    applicantsFields[INCOME_SOURCE_AVAILABLE.fieldApiName] = ref.checked;
                    applicantsFields[DECLARED_INCOME.fieldApiName] = ref.declaredIncome;
                    applicantsFields[APPLICANT_SUBSTAGE.fieldApiName] = ref.label.bankAccountCheck;
                    ref.updateRecordDetails(applicantsFields)
                    .then(result => {
                        if (ref.checked) {
                            ref.successToast('Data Updated',ref.label.loanDetailsSavedSuccessfully,'success');
                        } else if (!ref.checked && ref.currenttab != ref.label.CoBorrower) {
                            ref.isCoBorrowerReq = true;  //ref.successToast(ref.label.coBorrowerAdditionMandatory,'','warning');//CISP-2500  
                        }
                        if (ref.currenttab === ref.label.Borrower) {
                            const evnt = new CustomEvent('borrowerincomesource', { detail: ref.checked });
                            ref.dispatchEvent(evnt);
                            ref.isBorrowerEarning === true;}
                        if(ref.isTractor && ref.isNonIndividualBorrower){
                            ref.disabledBankAcc = true;
                            ref.doYouHaveBankAccount = true;
                        }
                        ref.disableIncomeSourceAvailable=true;ref.isDisabledDeclaredIncome=true;ref.isDisabledLoanAmount=true;
                        ref.currentStep = ref.label.bankAccountCheck;ref.isStepSeven = false;ref.isStepEight = true;
                       // ref.updateRecordDetails(applicantsFields);
                        if(ref.checked===false){deleteIncomeDetails({ loanApplicationId: ref.recordid}).then({});}//CISP-2555
                    })
            } else if (!ref.homePageFlag) {
                ref.successToast(ref.label.enterIncomeLoanAmount,'','error');
                return null;}}
    } else if (ref.currentStep === ref.label.bankAccountCheck) {
        if(ref.currentStage==='Credit Processing' || (ref.currentStageName === 'Loan Initiation' && ref.lastStage !== 'Loan Initiation')) {
            ref.currentStep = ref.label.gattingAndScreening;
            ref.isStepEight = false;
            ref.isStepNine = true;} else {    
            const newBankAcct = ref.template.querySelector('[data-id="toggle3"]');
            if(!ref.isTractor){
                newBankAcct.setAttribute("checked", true);
                newBankAcct.setAttribute("unchecked", false);
            }
            const haveBankAccount = ref.template.querySelector('[data-id="toggle1"]');
            haveBankAccount.setAttribute("checked", true);
            haveBankAccount.setAttribute("unchecked", false);

            if(!ref.isNonIndividualBorrower && !ref.selectedLiteracyFieldOptionValue && ref.isTractor && ref.currentStageName === 'Loan Initiation' && ref.lastStage === 'Loan Initiation'){
                ref.successToast('Please fill all mandatory fields!','','error');
                return;
            }
            if(ref.productType == 'Tractor'){
                const literacyCombobox = ref.template.querySelector('lightning-combobox[data-id="Literacy"]');
                if(literacyCombobox && literacyCombobox.validity.valid !== true) {
                    literacyCombobox.reportValidity();
                    ref.successToast('Please fill all mandatory fields!','','error');
                    return;
                }
            }

            if (!haveBankAccount.checked && !ref.doYouHaveBankAccountWithIBL && (ref.isTractor || !newBankAcct?.checked)) {
                if ((ref.currenttab !== ref.label.Borrower) && !ref.homePageFlag) {
                checkToggle({leadApplicationId : ref.recordid}) .then(result => {
                    if(!result && !ref.isTractor) {
                    ref.template.querySelector('lightning-input.withIBLBankAccount').checked = false;
                    ref.successToast(ref.label.journeyNotProceed,'','error');
                    } else {
                        const applicantsFields = {};
                        applicantsFields[APP_ID_FIELD.fieldApiName] = ref.applicantId;
                        applicantsFields[DO_YOU_HAVE_A_BANK_ACCOUNT.fieldApiName] =ref.doYouHaveBankAccount;
                        applicantsFields[DO_YOU_HAVE_A_BANK_ACCOUNT_WITH_IBL.fieldApiName] = ref.doYouHaveBankAccountWithIBL;
                        applicantsFields[WOULD_YOU_LIKE_TO_OPEN_A_BANK_ACCOUNT.fieldApiName] = ref.openNewBankAccount;
                        if(ref.productType == 'Tractor'){ //SFTRAC-33
                            applicantsFields[LITERACY_FIELD.fieldApiName] = ref.selectedLiteracyFieldOptionValue;
                        }
                        applicantsFields[APPLICANT_SUBSTAGE.fieldApiName] = ref.label.gattingAndScreening;
                        ref.updateRecordDetails(applicantsFields) .then(() => {
                            ref.successToast('Data Updated','','success'); ref.currentStep = ref.label.gattingAndScreening; ref.isStepEight = false;ref.isStepNine = true;
                            if(ref.productType == 'Tractor'){ //SFTRAC-33
                                ref.disabledLiteracyField = true;
                            }
                            ref.currentStep = ref.label.gattingAndScreening;
                            ref.isStepEight = false;
                            ref.isStepNine = true;
                           // applicantsFields[APP_ID_FIELD.fieldApiName] = ref.applicantId;
                           // applicantsFields[APPLICANT_SUBSTAGE.fieldApiName] = ref.label.gattingAndScreening;
                          //  ref.updateRecordDetails(applicantsFields);
                            }) .catch((error) => {});} 
                    }) .catch(error => {});
                }else if (ref.currenttab === ref.label.Borrower) {
                    ref.isCoBorrowerReq = true;
                    if(!ref.isTractor){
                    ref.successToast(ref.label.coborrowerRequireAccount,'','Warning');}
                    const applicantsFields = {};
                    applicantsFields[APP_ID_FIELD.fieldApiName] = ref.applicantId;applicantsFields[DO_YOU_HAVE_A_BANK_ACCOUNT.fieldApiName] = ref.doYouHaveBankAccount; applicantsFields[DO_YOU_HAVE_A_BANK_ACCOUNT_WITH_IBL.fieldApiName] = ref.doYouHaveBankAccountWithIBL;applicantsFields[WOULD_YOU_LIKE_TO_OPEN_A_BANK_ACCOUNT.fieldApiName] = ref.openNewBankAccount;
                    if(ref.productType == 'Tractor'){ //SFTRAC-33
                        applicantsFields[LITERACY_FIELD.fieldApiName] = ref.selectedLiteracyFieldOptionValue;
                    }
                    applicantsFields[APPLICANT_SUBSTAGE.fieldApiName] = ref.label.gattingAndScreening; 
                    ref.updateRecordDetails(applicantsFields) .then((result) => {
                        if(ref.productType == 'Tractor'){ //SFTRAC-33
                            ref.disabledLiteracyField = true;
                        }
                    //applicantsFields[APP_ID_FIELD.fieldApiName] = ref.applicantId;
                   //applicantsFields[APPLICANT_SUBSTAGE.fieldApiName] = ref.label.gattingAndScreening;
                   // ref.updateRecordDetails(applicantsFields);
                    ref.currentStep = ref.label.gattingAndScreening;
                    ref.isStepEight = false;
                    ref.isStepNine = true;
                    
                    }) .catch((error) => {});// verifyCMU({ applicationID: ref.currentOppRecordId });
                }
            } else if ((haveBankAccount.checked === true  && !ref.doYouHaveBankAccountWithIBL && (ref.isTractor || newBankAcct?.checked === false)) || (haveBankAccount.checked === true && ref.doYouHaveBankAccountWithIBL && (ref.isTractor || newBankAcct?.checked === false)) || (haveBankAccount.checked === false && !ref.doYouHaveBankAccountWithIBL && (ref.isTractor || newBankAcct?.checked === true)) || 
                    (haveBankAccount.checked === true  && !ref.doYouHaveBankAccountWithIBL &&(ref.isTractor ||  newBankAcct?.checked === true))) {
                        if(!ref.isTractor && newBankAcct?.checked && (ref.aepsValue == null || ref.aepsValue == undefined)){
                            ref.successToast('Please fill AePS information!','','error');
                        }else{
                            updateApplicantDetails(ref);
                        }
                }
            }
        } else if (ref.currentStep === ref.label.gattingAndScreening) { }
    }catch(error){if(!ref.isTractor){ref.successToast('Error','Something went wrong!','error');}}
}

function updateApplicantDetails(ref){
    const applicantsFields = {};
    applicantsFields[APP_ID_FIELD.fieldApiName] = ref.applicantId;
    applicantsFields[DO_YOU_HAVE_A_BANK_ACCOUNT.fieldApiName] =ref.doYouHaveBankAccount;
    applicantsFields[DO_YOU_HAVE_A_BANK_ACCOUNT_WITH_IBL.fieldApiName] = ref.doYouHaveBankAccountWithIBL;
    applicantsFields[AEPS_INFO.fieldApiName] = ref.aepsValue;
    if(ref.productType == 'Tractor'){ //SFTRAC-33
        applicantsFields[LITERACY_FIELD.fieldApiName] = ref.selectedLiteracyFieldOptionValue;
    }
    else{
        applicantsFields[WOULD_YOU_LIKE_TO_OPEN_A_BANK_ACCOUNT.fieldApiName] = ref.openNewBankAccount;
    }
    applicantsFields[APPLICANT_SUBSTAGE.fieldApiName] = ref.label.gattingAndScreening;

    ref.updateRecordDetails(applicantsFields)
        .then(() => {
            
            ref.successToast('Data Updated',ref.label.bankDetailsSavedSuccessfully,'success');
            ref.disabledComboboxField = true;
            ref.currentStep = ref.label.gattingAndScreening;
            ref.isStepEight = false;
            ref.isStepNine = true;
            ref.isOpenNomineeDetialSection = false;
            let updateApplicant ={};
           // updateApplicant[APP_ID_FIELD.fieldApiName] = ref.applicantId;
           // updateApplicant[APPLICANT_SUBSTAGE.fieldApiName] = ref.label.gattingAndScreening;
            //ref.updateRecordDetails(updateApplicant);

            
        }).catch((error) => { 
            console.log('Inside Catch');
            ref.error = error; });
}

export function findTabCount(lst,x){
    let count = 0;
    lst.forEach(element => {
        if(element.applicantType == x){
            count++;
        }
    });
    return count;
}

export const customLabels = {
    KycAddress1Pattern : KycAddress1Pattern,
    KycAddress2Pattern : KycAddress2Pattern,
    ProductType :ProductType,
    LeadNumber:LeadNumber,
    LeadDetails:LeadDetails,
    AgentBranchName:AgentBranchName,
    CustomerFirstName:CustomerFirstName,
    CustomerLastName:CustomerLastName,
    CustomerPhoneNumber:CustomerPhoneNumber,
    WhatsAppNumber:WhatsAppNumber,
    otpSend:otpSend,
    validationMsgNoalreadyReg:validationMsgNoalreadyReg,
    enterLoanAmount:enterLoanAmount,
    bankAccountMandotory:bankAccountMandotory,
    openNewBankAccountMsg:openNewBankAccountMsg,
    incomeAmountMandatory:incomeAmountMandatory,
    completeField:completeField,
    otpSentSuccessfully:otpSentSuccessfully,
    FailResponseApi:FailResponseApi,
    allSectionsClosed:allSectionsClosed,
    ProvideKYContinue:ProvideKYContinue,
    kycDetailsUploaded:kycDetailsUploaded,
    captureImageRequired:captureImageRequired,
    noRegisteredWhatsAppBanking:noRegisteredWhatsAppBanking,
    consentInitialisationRequired:consentInitialisationRequired,
    Pin_code_Pattern:Pin_code_Pattern,
    bankDetailsSavedSuccessfully:bankDetailsSavedSuccessfully,
    coborrowesNeedsTohaveBankAccount:coborrowesNeedsTohaveBankAccount,
    enterIncomeLoanAmount:enterIncomeLoanAmount,
    journeyNotProceed:journeyNotProceed,
    selectVehicleNumber:selectVehicleNumber,
    loanDetailsSavedSuccessfully:loanDetailsSavedSuccessfully,
    Permnt_Same_as_Current:Permnt_Same_as_Current,
    RetrySelfe:RetrySelfe,
    Mobile_Number_Error_Msg:Mobile_Number_Error_Msg,
    ExceptionMessage:ExceptionMessage,
    lastNameError:lastNameError,
    Loanamount10000:Loanamount10000,
    Loanamount175000:Loanamount175000,
    LoanAmount200000000:LoanAmount200000000,
    LoanAmount50000:LoanAmount50000,
    Incomemessage:Incomemessage,
    Income5000000:Income5000000,
    Income5000:Income5000
}

export function addressCheck(element,addressValue,minLength,addressLine){
    var address1Regex = /^(?=.{10,40}$)(^([A-Za-z0-9-_.,:;#\/']+[A-Za-z0-9-_.,:;#\/' ]*$)\2?(?!\2))+$/;
    var address2Regex = /^(?=.{3,40}$)(^([A-Za-z0-9-_.,:;#\/']+[A-Za-z0-9-_.,:;#\/' ]*$)\2?(?!\2))+$/;
    if (addressValue.length < minLength && addressLine==1) {
        element.setCustomValidity(AddressValidation3);
    } else if (addressValue.length < minLength && addressLine==2) {
        element.setCustomValidity(AddressValidation1);
    } else if (addressValue.length > 40) {
        element.setCustomValidity(AddressValidation2);
    } else if((!address1Regex.test(addressValue) && addressLine==1) || (!address2Regex.test(addressValue) && addressLine==2)){
        element.setCustomValidity(AddressnotValid);
    } else {
        element.setCustomValidity("");}element.reportValidity();
    }
    
export const stateData = () => {
    return getStateMasterData()
      .then(result => {
        console.log('Result', result);
        let data = result;let finalArrayTopush = [];
        if (data) {
            if (data.length > 0) {
                for(let index = 0; index < data.length; index++) {
                    let stateValue = {};stateValue.label = data[index].Name;stateValue.value = data[index].Name;stateValue.id = data[index].Id;stateValue.stateMinValue = data[index].Pincode__c;
    stateValue.stateMaxValue = data[index].Pincode_Starting_Max__c;
                    finalArrayTopush.push(stateValue);} console.log('OUTPUT ref.allStateData ',finalArrayTopush); }
            return finalArrayTopush;
        }
      })
      .catch(error => {
        console.error('Error:', error);
        return null;
    });
    
}

export const cityData = (state, city) =>{
    return getCityStateMaster({ stateName: state }).then(response => {
        let cityData = [];
        if (response && response.length > 0) {
            for(let index = 0; index < response.length; index++) {
                let cityObject = {};cityObject.label = response[index].Name;cityObject.value = response[index].Name;cityObject.id = response[index].Id;cityData.push(cityObject);
                }}
        return cityData;
        
    }).catch(error => {console.error('Error:', error);return null
        });
    }

export const districtData = (state) =>{
    console.log('OUTPUT state: ',state);
    return getDistrictsByState({ stateName:state }).then(response => {let cityData = []; console.log('Result', response);
        if (response && response.length > 0) { for (let index = 0; index < response.length; index++) {let cityObject = {};cityObject.label = response[index].Name;
         cityObject.value = response[index].Name; cityObject.id = response[index].Id;cityData.push(cityObject); }}
        return cityData;
    }).catch(error => {console.error('Error:', error);return null})
}
export const getDocumentsToCheckPanValid = (oppId) =>{
    return getDocumentsToCheckPan({ loanApplicationId: oppId })
      .then(result => {
        console.log('Result', JSON.parse(result));
        let data = JSON.parse(result);
        if(data?.borrowerPanAvailable){
            return true;
        }
        return false;
      })
      .catch(error => {
        console.error('Error:', error);return null;
    });
}

export async function onfinishHandler(ref){
    ref.isLoading = true;
    if(ref.isTractor && ref.isNonIndividualBorrower){
        try{
            let response = await validateBeneficiaryCount({opportunityId: ref.recordid});
            if(response && !response.isValid && response.beneficiaryCount != 0){
                const evt = new ShowToastEvent({title: "Error",message: `Addition of atleast ${response.beneficiaryCount}  beneficiaries are required!`,variant: 'error',});ref.dispatchEvent(evt);ref.isLoading = false;return;
            }
            let beneficaryCount = 0;
            let res = await getApplicantDetail({opportunityId: ref.recordid});
            for(let applicant of res){
                if(applicant.Applicant_Type__c == 'Beneficiary'){beneficaryCount++;}
                if((!applicant.Bureau_Pull_Message__c) || (applicant.Bureau_Pull_Match__c == false && applicant.Bureau_Pull_Message__c != Retry_Exhausted)){const evt = new ShowToastEvent({title: "Error",message: 'Please fill all details in all applicants tab before proceeding the journey',variant: 'error',});ref.dispatchEvent(evt);ref.isLoading = false;return;}
            }
            if(beneficaryCount == 0){
                const evt = new ShowToastEvent({title: "Error",message: 'Please add atleast one Beneficiary before proceeding the journey',variant: 'error',});ref.dispatchEvent(evt);ref.isLoading = false;return;
            }else{
                const evnt = new CustomEvent('additionaldetails', { detail: Addition_Details_Capture });ref.dispatchEvent(evnt);
                ref.isLoading = false;
            }
        }catch(error){
            ref.isLoading = false;
        }
    } else if(ref.isTractor && ref.isIndividual){
        let allApplicantsIlliterate = await isAllApplicantsIlliterate({loanApplicationId : ref.recordid});
        if(!allApplicantsIlliterate){
            const evnt = new CustomEvent('additionaldetails', { detail: Addition_Details_Capture });ref.dispatchEvent(evnt);
            ref.isLoading = false;
        }else{
            const evt = new ShowToastEvent({title: "Error",message: 'Borrower & All Co-Borrowers are Illiterate hence You can\'t move to next screen!',variant: 'error',});ref.dispatchEvent(evt);ref.isLoading = false;return;
        }
    }else{
        const evnt = new CustomEvent('additionaldetails', { detail: Addition_Details_Capture });ref.dispatchEvent(evnt);
        ref.isLoading = false;
    }
}

//SFTRAC-1849 start
export async function disableFieldTAFE(ref){
    console.log('+++++++++disableFieldTAFE 2');
    ref.disableFirsttName = ref.firstNameValue !='' ? true : false;
    ref.disableLastName = ref.lastNameValue !='' ? true : false;
   if(ref.leadNumber.includes('_C1') || ref.leadNumber.includes('-A')){
        ref.disablePhoneNumber = false;
    }else{
        ref.disablePhoneNumber = (ref.phoneNoValue !='') || (ref.phoneNoValue !=null) ? true : false;
    }
    ref.disableApplicationType = true;
    ref.disableEntityTypeVal = true;
}//SFTRAC-1849 end
//CISP-22671 start
export async function blCodeHide(ref){
    var newagentBLCodeOptions = [];
    if (ref.vehicleTypeval == 'Refinance') { //SFTRAC-489
        ref.applicationTypeVal = 'Refinance';
    } else {
        ref.applicationTypeVal = 'Tractor';
    }
    console.log(ref.vehicleTypeval,ref.productType);
    ref.agentBLCodeOptionsvalues.forEach((branch) => {
            let inactiveBL = ref.inActiveBLCodes && ref.inActiveBLCodes.Input_Labels__c ? ref.inActiveBLCodes.Input_Labels__c.split(';') : null;
            console.log(inactiveBL,'inactiveBL');
            if (ref.vehicleTypeval.slice(0, 1) == branch.label.slice(-1)) {
                if (inactiveBL != null && inactiveBL.length > 0) {
                    if (branch.label && !inactiveBL.includes(branch.label)) {
                        newagentBLCodeOptions.push(branch);
                    }
                } else {
                    newagentBLCodeOptions.push(branch);
                }
            } else if ((ref.vehicleTypeval == 'Used' || ref.vehicleTypeval == 'Refinance') && branch.label.slice(-1) == 'U') {
                if (inactiveBL != null && inactiveBL.length > 0) {
                    if (branch.label && !inactiveBL.includes(branch.label)) {
                        newagentBLCodeOptions.push(branch);
                    }
                } else {
                    newagentBLCodeOptions.push(branch);
                }
            }
    });
    ref.agentBLCodeOptions = newagentBLCodeOptions;
}//CISP-22671 end