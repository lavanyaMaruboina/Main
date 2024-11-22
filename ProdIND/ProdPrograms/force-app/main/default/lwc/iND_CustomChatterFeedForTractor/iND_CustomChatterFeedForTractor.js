import { LightningElement, track, api, wire } from 'lwc';
import getAccountId from '@salesforce/apex/iND_CustomFeedTractorController.getAccountId'; 
import createQueryCaseRecords from '@salesforce/apex/iND_CustomFeedTractorController.createQueryCaseRecords'; 
import getAllCasesRelatedToAccount from '@salesforce/apex/iND_CustomFeedTractorController.getAllCasesRelatedToAccount'; 
import getOrgBaseUrl from "@salesforce/apex/iND_CustomFeedTractorController.getOrgBaseUrl";

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { createRecord } from 'lightning/uiRecordApi';
import CASE_COMMENT_OBJECT from "@salesforce/schema/CaseComment";

import CASE_COMMENT_BODY from '@salesforce/schema/CaseComment.CommentBody';
import COMMENT_PARENT_ID from '@salesforce/schema/CaseComment.ParentId';



const columns = [
    { label: 'CaseNumber', fieldName: 'Case_Url', type:'url', typeAttributes: {label: { fieldName: 'CaseNumber' }, target: '_blank'}},
    { label: 'Owner', fieldName: 'Owner', type: 'String' },
    { label: 'CreatedDate', fieldName: 'CreatedDate', type: 'date' }
]; 

export default class IND_CustomChatterFeedForTractor extends LightningElement {
    @api recordId;
    @track isQuery = false;
    @track data = [];
    @track columns = columns;
    @track fetchField = ['TeamMemberRole', 'UserId', 'User.Name'];
    @track searchField = 'User.Name';
    @track filterField = ['AccountId']
    @track filterTerm = [];
    @track filterMultipleFieldName = 'TeamMemberRole';
    @track filterMultipleTerm = ['BE','RCU_M','CVO'];
    @track selectedUser;
    @track selectedUserId;
    @track accountId;
    @track caseId;
    @track queryAsked;
    @track caseCommentId;

    @wire(getOrgBaseUrl) baseUrl;

    async init(){
        console.log('recordId-->'+this.recordId);
        const currentDocmuentId = await getAccountId({'documentId': this.recordId});
        this.accountId = currentDocmuentId;
        this.filterTerm = [this.accountId];
        console.log('this.accountId-->'+this.accountId);
    }   

    async connectedCallback(){
        console.log('columns-->'+JSON.stringify(this.columns));
        await this.init();

        await getAllCasesRelatedToAccount({documentId:this.recordId})
            .then(response => {
                console.log('response-->'+JSON.stringify(response));
                if(response != null){
                    let fetechedData = [];
                    response.forEach(element => {
                        let newObj = {};
                        newObj.Id = element.Id;
                        newObj.CaseNumber = element.CaseNumber;
                        newObj.Case_Url = this.baseUrl.data + '/' + element.Id;
                        newObj.Owner = element.Owner.Name;
                        newObj.CreatedDate = element.CreatedDate;
                        fetechedData.push(newObj);
                    });
                    this.data = fetechedData;
                    console.log('this.data'+JSON.stringify(this.data));
                }
            })
            .catch(error => {
                console.log('error',error);
            });  
    }

    hideModalBox(){
        this.isQuery = false;
    }


    handleChangeQuery(event){
        this.queryAsked = event.target.value;
        console.log('this.queryAsked-->'+this.queryAsked);
    }

    handleClick(){
        this.isQuery = true;
    }

    selectHandler(event){
        this.selectedUser =  event.detail.selectedValueName;
        this.selectedUserId = event.detail.selectedValueId;
    }

    async createCaseAndCaseComment(){
        await createQueryCaseRecords({accountId: this.accountId, userId: this.selectedUserId, documentId: this.recordId, body:this.queryAsked})
            .then((caseRecord) => {
                if(caseRecord){
                    this.caseId = caseRecord.Id;
                    console.log('this.caseId-->'+this.caseId);
                                            this.dispatchEvent(
                            new ShowToastEvent({
                                title: "Success",
                                message: "Case created for your concern!",
                                variant: "success",
                            }),
                            );
                            this.isQuery = false;
                            setTimeout(() => {
                             window.location.reload();
                            }, 1000);
                                    }
                else{
                    this.isQuery = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Query Is Already Available",
                            message: "Query record is already available with this User",
                            variant: "info",
                        }),
                    );
                }
                
            })
            .catch((error) => {
                this.error = error;
                console.log('error-->',this.error);
                console.log('error-->'+this.error);
                this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error creating record",
                    message: error.body.message,
                    variant: "error",
                }),
                );
                this.isQuery = false;
            });
    }

    handleSubmit(){
        console.log('handleSubmit');
        this.createCaseAndCaseComment();
    }
}