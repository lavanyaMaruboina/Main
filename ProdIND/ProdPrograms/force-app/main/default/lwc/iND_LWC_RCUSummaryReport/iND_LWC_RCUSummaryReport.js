import { LightningElement,track,api,wire } from 'lwc';
import getRCUSummary from '@salesforce/apex/RCUSummaryReportController.getRCUSummary';
import getPDFprint from '@salesforce/apex/RCUSummaryReportController.getPDFprint';
import getRCUSamplerName from '@salesforce/apex/LWCLOSAssetVerificationCntrl.getRCUSamplerName';//SFTRAC-1451
export default class IND_LWC_RCUSummaryReport extends LightningElement {
    summaryReportObj;
    @track documents;
    @track files;
    @track vehicleDetails;
    @track coBorrower;
    @api recordId;
    @api hidePdfBtn;
    applicantName;
    dealNumber;
    branchLocation;
    loanAmount;
    address;
    reportedDate;
    Sourcing_Staff_name;
    Sourced_By;
    loanType;
    Sampled_Date;
    SamplerName;//SFTRAC-1451
    rcuAgencyName;//SFTRAC-1451
    overall_RCU_Verification_Status;
    overall_RCU_Verification_Remarks;
    overall_RCU_Agency_Verification_Status;
    overall_RCU_Agency_Verification_Remarks;
    overall_RCU_Agency_Sampling_Reason;//SFTRAC-1451
    @wire(getRCUSummary,{rcuCaseId:'$recordId'})
    summaryReport({data,error}){
        if(data){
            console.log('data'+data);
            this.summaryReportObj = data//JSON.parse(data);
            console.log('summaryReportObj '+this.summaryReportObj.applicant_name);
            this.applicantName = this.summaryReportObj.Applicant_Name;
            this.dealNumber = this.summaryReportObj.Deal_Number;
            this.branchLocation = this.summaryReportObj.Branch_Location;
            this.loanAmount = this.summaryReportObj.Loan_Amount;
            this.address = this.summaryReportObj.Address;
            this.Sampled_Date = this.summaryReportObj.Sampled_Date;
            this.reportedDate = this.summaryReportObj.Reported_Date;
            this.loanType = this.summaryReportObj.Loan_Type;
            this.overall_RCU_Verification_Status = this.summaryReportObj.overall_RCU_Verification_Status;
            this.documents = this.summaryReportObj.documents;
            this.overall_RCU_Verification_Remarks = this.summaryReportObj.overall_RCU_Verification_Remarks;
            this.overall_RCU_Agency_Verification_Status = this.summaryReportObj.overall_RCU_Agency_Verification_Status;
            this.overall_RCU_Agency_Verification_Remarks = this.summaryReportObj.overall_RCU_Agency_Verification_Remarks;
            this.Sourcing_Staff_name = this.summaryReportObj.Sourcing_Staff_name;
            this.Sourced_By = this.summaryReportObj.Sourced_By;
            //this.SamplerName = this.summaryReportObj.SamplerName; //SFTRAC-1451
            this.SamplerName = this.summaryReportObj.rcuAgencyName; //SFTRAC-1451
            this.verifierName = this.summaryReportObj.rcuAgencyName; //SFTRAC-1451
            this.overall_RCU_Agency_Sampling_Reason = this.summaryReportObj.overall_RCU_Agency_Sampling_Reason;//SFTRAC-1451
            this.files =JSON.parse(JSON.stringify(this.summaryReportObj.files));
            this.files.forEach(file => {
                file.src='data:image/jpeg;base64,'+file.fileData
            });
            this.vehicleDetails = this.summaryReportObj.vehicleDetails;
            this.coBorrower = this.summaryReportObj.Applicants;

            //SFTRAC-1451
            getRCUSamplerName({rcuCaseId:this.recordId})
            .then(result => {
                this.rcuAgencyName = result;
            })
            .catch(error => {
                console.log('Error in Summary getRCUSamplerName '+JSON.stringify(error))
            });
        }else if(error){
            console.log('Error in Summary '+JSON.stringify(error))
        }
    }

    handlePrint(event){
        window.open('/apex/generatePDF?Id='+this.recordId,'_self');
        /*getPDFprint({json:this.recordId}).then(response=>{
            console.log('Successful '+response[0]+' '+response[1]);
            window.open(response[1]);
        }).catch(error=>{
            error.log('Error '+JSON.stringify(error));
        })*/
    }
    createHeaders(keys,widthSize) {
		var result = [];
		for (var i = 0; i < keys.length; i += 1) {
			result.push({
				id: keys[i],
				name: keys[i],
				prompt: keys[i],
				width: widthSize,
				align: "center",
				padding: 0
			});
		}
		return result;
	}
}