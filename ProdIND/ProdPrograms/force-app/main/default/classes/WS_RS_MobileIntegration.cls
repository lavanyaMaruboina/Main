@RestResource(urlMapping='/imageupload')
global class WS_RS_MobileIntegration {
    @HttpPost
       global static statusrep fetchDetails(userdetails details ){
           statusrep response = new statusrep();
           List<Attachment> lstAttachmentsToBeInserted = new List<Attachment>();
    
              if(details.selfieImage != null && details.selfieImage != '')
                       {
                           Applicant__C apps = new Applicant__C();
                         Documents__c usd = new Documents__c();  
                           apps = [SELECT id,Name,(SELECT id,Name,Image__c FROM Documents__r) FROM Applicant__C where id = :details.applicant ];
                           details.selfieImage = String.valueOf(details.selfieImage).replace('\r\n', '');
                         usd.Image__c = '<!DOCTYPE html><html><body>' + ' <img src=' + 'data:image/jpeg;base64,' + details.selfieImage + '/>' + '</body></html>';
                           usd.name = details.name;
                           usd.Applicant__c = details.applicant;
                            usd.Opportunity_Relation__c = details.loanApplication;
                           insert usd;
                           Attachment a = new Attachment();
                           a.body = EncodingUtil.base64Decode(details.selfieImage);
                           a.name = details.name;
                           a.parentId = usd.id;
                           a.Description = 'Selfie Image';
                           a.ContentType = 'image/jpg';
                           lstAttachmentsToBeInserted.add(a);
                       }
            if(lstAttachmentsToBeInserted != null && lstAttachmentsToBeInserted.size() > 0)
                   {
                       insert lstAttachmentsToBeInserted;
                   }
            response.status = 'Success';
           
           return response;
       }
     global class userdetails  {  
       
           global String selfieImage;
           
           global String name;
           
           global String applicant;
         
          global String loanApplication;
         
       
       }

   global class statusrep{
       global string status;
   }

}