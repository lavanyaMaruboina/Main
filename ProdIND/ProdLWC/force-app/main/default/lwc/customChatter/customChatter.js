import { LightningElement,track,api } from 'lwc';
import getAllPreviousChat from '@salesforce/apex/iND_CustomFeedTractorController.getAllPreviousChat'; 
import updateCase from '@salesforce/apex/iND_CustomFeedTractorController.updateCase'; 
import CASE_COMMENT_OBJECT from "@salesforce/schema/CaseComment";
import CASE_COMMENT_BODY from '@salesforce/schema/CaseComment.CommentBody';
import CASE_Comment_IsPublished from '@salesforce/schema/CaseComment.IsPublished';
import COMMENT_PARENT_ID from '@salesforce/schema/CaseComment.ParentId';

import CASE_ID from "@salesforce/schema/Case.Id";
import CASE_OWNERID from "@salesforce/schema/Case.OwnerId";
import CASE_STATUS from '@salesforce/schema/Case.Status';
import { createRecord,updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from "lightning/platformShowToastEvent";


export default class CustomChatter extends LightningElement {

@track commentsData=[];
@track commentBody;
@api recordId;
@track createdById;

    async connectedCallback(){
    await getAllPreviousChat({caseId:this.recordId}).then(result =>{
        let tempdata=[];
        if(result.caseRecords){
        result.caseRecords.forEach(each=>{
            const originalDate = new Date(each.CreatedDate);
            const year = originalDate.getFullYear();
            const month = String(originalDate.getMonth()+1).padStart(2, '0');
            const day = String(originalDate.getDate()).padStart(2, '0');
            const hour = String(originalDate.getHours()>12 ? originalDate.getHours() - 12 : originalDate.getHours()).padStart(2, '0');
            const minute = String(originalDate.getMinutes()).padStart(2, '0');
            const ampm = originalDate.getHours() >= 12 ? 'PM' : 'AM';
            each.CreatedDate = `${day}/${month}/${year} ${hour}:${minute} ${ampm}`;
            tempdata.push(each);

        });  
            this.commentsData = tempdata;
        }
        this.createdById = result.createdbyId;
    })
    }

    commentHandler(event){
    this.commnetBody = event.target.value;
    }

    async handlePostClick(){
    this.commnetBody=this.commnetBody.replaceAll(/(<([^>]+)>)/gi,'');
    const fields = {};
    fields[COMMENT_PARENT_ID.fieldApiName] = this.recordId;
    fields[CASE_COMMENT_BODY.fieldApiName] = this.commnetBody;
    fields[CASE_Comment_IsPublished.fieldApiName] = true;
    const caseCommentRecordInput = { apiName: CASE_COMMENT_OBJECT.objectApiName, fields };

        await createRecord(caseCommentRecordInput)
        .then((caseCommentRecord) => {
            this.caseCommentId = caseCommentRecord.id;
            console.log('this.caseCommentId-->'+this.caseCommentId);
             updateCase({caseId: this.recordId, createdById: this.createdById})
            .then((response) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: "Case created for your concern!",
                        variant: "success",
                    }),
                );

                setTimeout(() => {
                    window.location.reload();
                }, 1000);  
            })
        })
        .catch((error) => {
            this.dispatchEvent(
            new ShowToastEvent({
                title: "Error creating record",
                message: error.body.message,
                variant: "error",
            }),
            );
        });

    }

}