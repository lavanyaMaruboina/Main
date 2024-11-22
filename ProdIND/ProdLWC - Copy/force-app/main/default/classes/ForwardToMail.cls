public class ForwardToMail {
    // @InvocableMethod(label='Send Email/SMS to role based user' description='Email/SMS will sent on Forward To Button Click')
            /**********************************************
     * @Commented By:  Rajat Jaiswal
     * @UserStory:  Feature 8.2.16 - ForwardTo
     * @Purpose: This method is used to sent the mail to the dedicated user having role in the account team same as the param passed in method.
     ***********************************************/
    public static String emailCallOut(String camId, String role) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

        CAM__c cam=[SELECT Id,Loan_Application__c, Loan_Application__r.AccountId FROM CAM__c WHERE id=:camId];
        //Opportunity opp = [SELECT ID, AccountId from Opportunity where id =:oppId];
        Id accountId = cam.Loan_Application__r.AccountId;
        system.debug('accountId::'+' '+accountId);

        List<AccountTeamMember> roleList = [SELECT ID ,TeamMemberRole, Level__c ,Account.id, User.Email, user.Name, UserId, user.IsActive FROM AccountTeamMember WHERE Account.id= :accountId AND TeamMemberRole=:role AND user.IsActive=TRUE]; //CISP-4176
        system.debug('roleList Name::'+' '+roleList);

        /*List<Committee_Deviation__mdt> lstcdm=[SELECT Id,DeveloperName,CCC_Above_Flag__c,Mandatory_Role__c,Non_Mandatory_Role__c from Committee_Deviation__mdt limit 100];
        System.debug('inside cdm==>'+lstcdm );

        String level;
        for(Committee_Deviation__mdt item : lstcdm){
            if(item.Mandatory_Role__c.Contains(role) || item.Non_Mandatory_Role__c.Contains(role)){
                System.debug('item=>'+item);
                level=item.DeveloperName;
                continue;
            }
        }   */
        EmailTemplate et = [select id,Subject,HtmlValue from EmailTemplate where developername='ForwordToEMail1']; //Email TemplateId developername is TemplateName.
        if(roleList.size() > 0) {
            List<OrgWideEmailAddress> orgWideEmail = new List<OrgWideEmailAddress>();
            orgWideEmail = [select id, DisplayName,Address from OrgWideEmailAddress WHERE Address ='cfd_payonline@indusind.com' LIMIT 1];
            for (AccountTeamMember roleMember : roleList) {
                System.debug(roleMember.UserId + ' === '+ roleMember.User.Email);
                Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id, roleMember.UserId, cam.Id);
                mail.setTargetObjectId(roleMember.UserId);		
                mail.setTemplateId(et.Id );
                mail.saveAsActivity = false;
                mail.setSubject(mail.getSubject());
                // String EmailTempHtml =  et.HTMLValue.Replace('{level}', level);
                // mail.setHtmlBody(EmailTempHtml);
                // if(orgWideEmail.size() > 0){
                //     mail.setOrgWideEmailAddressId(orgWideEmail[0].Id);
                //     mail.setReplyTo(orgWideEmail[0].Address); // change it with your mail address.
                // }else {
                //     mail.setReplyTo(UserInfo.getUserEmail());
                // }
                mail.setHtmlBody(mail.getHtmlBody());
                mails.add(mail); //adding email
            }
            
            if(!mails.isEmpty()) {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(mails); //Send email
                if (results[0].success) {
                    return 'Success';
                }else{
                    return 'Failed';
                }
            }
        }
        return 'Failed';
    }
        
    // Method to forword deviation email to respective user.
            /**********************************************
     * @Commented By:  Rajat Jaiswal
     * @UserStory:  Feature 8.2.15 - CAM and Approval Log
     * @Purpose: This method is used to send mails to for users to whom deviation is triggered in a particular cam.
     ***********************************************/
    @future
    public static void emailDeviationCallout(String camId) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

        List<Deviation__c> deviationList = [SELECT Id,Name,DeviationID__c,Deviation_Level__c,Role__c,Parent_CAM__c,Parent_CAM__r.Loan_Application__r.AccountId , EmployeeID__c,Deviation_Description__c
                                                FROM Deviation__c
                                                WHERE Parent_CAM__c=:camId 
                                                ];

        Id accountId = deviationList[0].Parent_CAM__r.Loan_Application__r.AccountId;
            
        List<AccountTeamMember> roleList = [SELECT ID ,TeamMemberRole, Level__c ,Account.id, User.Email, User.Name, UserId, User.IsActive 
                                            FROM AccountTeamMember 
                                            WHERE Account.id= :accountId AND user.IsActive=TRUE]; //CISP-4176

        EmailTemplate et = [select id,Subject,HtmlValue from EmailTemplate where developername='Deviation_EMail1']; //Email TemplateId developername is TemplateName.
        List<OrgWideEmailAddress> orgWideEmail = new List<OrgWideEmailAddress>();
        orgWideEmail = [select id, DisplayName,Address from OrgWideEmailAddress WHERE Address ='cfd_payonline@indusind.com' LIMIT 1];
        for (Deviation__c deviation : deviationList){
            for (AccountTeamMember roleMember : roleList){
                system.debug('deviation.Role__c ==>'+deviation.Role__c+' '+' roleMember.TeamMemberRole '+' '+roleMember.TeamMemberRole+' '+' deviation.Role__c '+' '+deviation.Role__c);

                if(deviation.Role__c != null && deviation.Role__c.contains(roleMember.TeamMemberRole)){
                    system.debug('Deviation Name::'+' '+deviation.Name+' '+'Deviation Level::'+' '+ deviation.Deviation_Level__c);

                    system.debug('Sending Email to ::'+roleMember.User.Email);
                    Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id, roleMember.UserId, deviation.Id);
                        mail.setTargetObjectId(roleMember.UserId);		
                        mail.setTemplateId(et.Id );
                        mail.saveAsActivity = false;
                        mail.setSubject(mail.getSubject());
                        // if(orgWideEmail.size() > 0){
                        //     mail.setOrgWideEmailAddressId(orgWideEmail[0].Id);
                        //     mail.setReplyTo(orgWideEmail[0].Address); // change it with your mail address.
                        // }else {
                        //     mail.setReplyTo(UserInfo.getUserEmail());
                        // }
                        mail.setHtmlBody(mail.getHtmlBody());
                        mails.add(mail); //adding email
                }
            }
        }  
            Messaging.sendEmail(mails); //Send email
    }
}