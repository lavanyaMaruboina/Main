/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is wrapper class for the Uidai Biometric Request
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
04-01-2022    Satyam More            Created
------------------------------------------------------------*/

public class IND_UidaiBiometricRequest extends ParentAPIRequest{
    
    public string UId  {get;set;}
    public string FingerPosition {get;set;}
    public string RdsId {get;set;}
    public string RdsVer {get;set;}
    public string DpId {get;set;}
    public string DC {get;set;}
    public  string MI {get;set;}
    public  string MC {get;set;}
    public Skey skey {get;set;}
public class Skey{
public  string CI{get;set;}
public  string Text{get;set;}

}
    public  string Hmac {get;set;}
    public  string Data {get;set;}
    
    // @Method:      IND_UidaiBiometricRequest
    // @Created by:  Satyam More
    // @Description: Contructor to initialize the details
    // @Param:       Object applicant Record
    // @Return:  
    public IND_UidaiBiometricRequest(Applicant__c app,String loanAppId){
        String pidblock = app.PID_Block__c ;
        Map<String,String> res = Utilities.pidblock(pidblock);
        String dData = res.get('ele_text2');
        String skeyData = res.get('ele_text1'); 
        String hmacData = res.get('Hmac'); 
        String dpId = res.get('dpId');
        String rdsId = res.get('rdsId');
        String rdsVer = res.get('rdsVer');
        String dc = res.get('dc');
        String mi = res.get('mi');
        String mcdata = res.get('mc');
        String udc = res.get('value');        
        String ci = res.get('ci');  
        
        this.Skey = new Skey();
        this.UId = app.Aadhar_No__c ;
        this.FingerPosition = 'RIGHT_INDEX';
        this.RdsId = rdsId ;
        this.RdsVer = rdsVer;
        this.DpId = dpId;
        this.DC = dc;
        this.MI = mi;
        this.MC = mcdata;
        this.Skey.CI = ci;
        this.Skey.Text = skeyData;
        this.Hmac = hmacData;
        this.Data = dData;
        
        validate(System.Label.UIDAIBiometric);
    }
    
    public override String xmlConvertedRequest(){
        String xmlrequestBody = prepareRequest();
        return xmlrequestBody;
    }
    
    // @Method:      prepareRequest
    // @Created by:  Satyam More
    // @Description: Method to validate the required input details
    // @Return:      xml request
    private String prepareRequest(){
        try{
            String request ='<BioMetricRequest>';
            request+='<UId>'+this.UId+'</UId>';
            request+='<FingerPosition>'+this.FingerPosition+'</FingerPosition>';
            request+='<RdsId>'+this.RdsId+'</RdsId>';
            request+='<RdsVer>'+this.RdsVer+'</RdsVer>';
            request+='<DpId>'+this.DpId+'</DpId>';
            request+='<DC>'+this.DC+'</DC>';
            request+='<MI>'+this.MI+'</MI>';
            request+='<MC>'+this.MC+'</MC>';
            request+= '<Skey>';
            request+='<CI>'+this.Skey.CI+'</CI>';
            request+='<Text>'+this.Skey.Text+'</Text>';
            request+= '</Skey>';
            request+='<Hmac>'+this.Hmac+'</Hmac>';
            request+='<Data>'+this.Data+'</Data>';
            request+= '</BioMetricRequest>';
            system.debug(request);
            return request;
        }catch(Exception ex){
            System.debug('Exception-->'+ex.getMessage() + ' Exception line number-->'+ ex.getLineNumber()); 
            throw ex;
        }
    }
    
    // @Method:      validate
    // @Created by:  Satyam More
    // @Description: Method to validate the required input details
    // @Param:       Service name
    // @Return:      True - If all the validations are passed.
    public override boolean validate(String serviceName){
        if(string.isBlank(this.FingerPosition)){
            throw new IND_Exception(System.Label.Lead_IDError);
        }
        if(string.isBlank(this.RdsId)){
            throw new IND_Exception(System.Label.Maker_IdError);
        }
        if(string.isBlank(this.UId)){
            throw new IND_Exception(System.Label.UIDAIAadhaar_ERR);
        }
        return true;
    }
    
    
    // @Method:      getHttpRequestHeaders
    // @Created by:  Satyam More
    // @Description: Method to get the HTTP request header data
    // @Param:       ''
    // @Return:      Header required to callout the service.
    public override Map<String,String> getHttpRequestHeaders(){
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }
    
    
}