public class IND_KFSAPIRequest extends ParentAPIRequest{

    public String Deal_No = '';
    public String Source = '';
    public String Product = '';
    public String Maker_Id = '';

    public IND_KFSAPIRequest(Opportunity loanAppId, String dealId){
        if(loanAppId.Product_Type__c == 'Tractor'){
            List<Deal_Number__c> dealNumberList = new List<Deal_Number__c>();
            dealNumberList = [Select id,Deal_Number__c from Deal_Number__c Where id =: dealId LIMIT 1];
            if(dealNumberList.size() > 0){
                this.Deal_No = dealNumberList[0].Deal_Number__c;
            }else{
                this.Deal_No = '';
            }
        }else{
            this.Deal_No = loanAppId.Deal_Number__c;
        }
        this.Source = 'Salesforce';
        this.Product = loanAppId.Product_Type__c == 'Two Wheeler' ? 'H' : loanAppId.Product_Type__c == System.Label.Tractor ? 'T' : 'C';
        this.Maker_Id = IntegrationUtilities.getMakerId();
    }   

    public IND_KFSAPIRequest(RequestWrapper requestWrapper){

        this.Deal_No = requestWrapper.Deal_No;
        this.Source = 'Procredit';
        this.Product = requestWrapper.Product_Type;
        this.Maker_Id = requestWrapper.Maker_Id;
        //validate(System.Label.KfsStatement);
    }   

    public IND_KFSAPIRequest(String dealNo, Boolean fromProcredit, String processingRecordId){
        this.Deal_No = dealNo;
        if(fromProcredit){
            ProCredit_Deals__c pcd = [SELECT Maker_Id__c,Product_Type__c,Unique_Id__c FROM ProCredit_Deals__c WHERE Id=:processingRecordId];
            this.Source = 'Procredit';
            this.Product = pcd.Product_Type__c;
            this.Maker_Id = pcd.Maker_Id__c;
        }else{
            Opportunity opp = [SELECT Id,Product_Type__c FROM Opportunity WHERE Id=:processingRecordId];
            this.Source = 'Salesforce';
            this.Product =  opp.Product_Type__c == 'Two Wheeler' ? 'H' : opp.Product_Type__c == System.Label.Tractor ? 'T' : 'C';
            this.Maker_Id = IntegrationUtilities.getMakerId();
        }
    }

   /* public override boolean validate(String serviceName){
        if(String.isBlank(this.Deal_No)){
            throw new IND_Exception('Deal Number is required.');
        }
        if(String.isBlank(this.Source)){
            throw new IND_Exception('Source is required.');
        }
        if(String.isBlank(this.Product)){
            throw new IND_Exception('Product is required.');
        }
        if(String.isBlank(this.Maker_Id)){
            throw new IND_Exception('Maker Id is required.');
        }
        return true;
    }

    */
    public override Map<String,String> getHttpRequestHeaders(){
        //Map to store HTTP request header data
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
        //requestheadermap is used to fetch the request from client
    }
}