public with sharing class PersonalDetailsforCAM {

    @AuraEnabled(Cacheable=true)
    public static Map<String,List<String>> getRecords(string opp){
        system.debug('opp'+opp);
        Applicant__c[] app=[SELECT Id,Name,Opportunity__c,Relationship_with_borrower__c,Profile__c,Customer_Code__c,Gender__c,Income_Ca__c,Entity__c,Marital_status__c,Applicant_Type__c From Applicant__c where Applicant_Type__c=:'Borrower' And Opportunity__c=:opp];
        Map<String,List<String>> Details= new Map<String,List<String>>();
        Map<String,String> newmap= new Map<String,String>();
        Map<String,String> newtmap= new Map<String,String>();
        system.debug('app'+app);
        if(app.size() > 0){
            newmap.put('Name',app[0].Name == null ? '' : app[0].Name);
            newmap.put('Relation With Borrower',app[0].Relationship_with_borrower__c== null ? '' : app[0].Relationship_with_borrower__c);
            newmap.put('Entity Type',app[0].Entity__c== null ? '' : app[0].Entity__c);
            newmap.put('Age (Birth /Incorporation)','-');
            newmap.put('Gender',app[0].Gender__c== null ? '' : app[0].Gender__c);
            newmap.put('Marital status',app[0].Marital_status__c== null ? '' : app[0].Marital_status__c);
            newmap.put('Profile', app[0].Profile__c== null ? '' : app[0].Profile__c);
            newmap.put('Category',app[0].Income_Ca__c== null ? '' : app[0].Income_Ca__c);
            newmap.put('Evaluation Type','-');
            newmap.put('Customer Code',app[0].Customer_Code__c== null ? '' : app[0].Customer_Code__c);
            newmap.put('Employer Type','');
            newmap.put('Share Holding(%)','');
        } else{
            newmap.put('Name','');
            newmap.put('Relation With Borrower','');
            newmap.put('Entity Type','');
            newmap.put('Age (Birth /Incorporation)','-');
            newmap.put('Gender','');
            newmap.put('Marital status','');
            newmap.put('Profile','' );
            newmap.put('Category','');
            newmap.put('Evaluation Type','-');
            newmap.put('Customer Code','');
            newmap.put('Employer Type','');
            newmap.put('Share Holding(%)','');
        }    
        Applicant__c[] app1=[SELECT Id,Name,Opportunity__c,Relationship_with_borrower__c,Entity__c,Customer_Code__c,Gender__c,Income_Ca__c,Profile__c,Applicant_Type__c,Marital_status__c From Applicant__c where Applicant_Type__c=:'Co-Borrower' And Opportunity__c=:opp];
        if(app1.size() > 0){
            newtmap.put('Name',app1[0].Name == null ? '' : app1[0].Name);
            newtmap.put('Relation With Borrower',app1[0].Relationship_with_borrower__c== null ? '' : app1[0].Relationship_with_borrower__c);
            newtmap.put('Entity Type',app1[0].Entity__c== null ? '' : app1[0].Entity__c);
            newtmap.put('Age (Birth /Incorporation)','-');
            newtmap.put('Gender',app1[0].Gender__c== null ? '' : app1[0].Gender__c);
            newtmap.put('Marital status',app1[0].Marital_status__c== null ? '' : app1[0].Marital_status__c);
            newtmap.put('Profile', app1[0].Profile__c== null ? '' : app1[0].Profile__c);
            newtmap.put('Category',app1[0].Income_Ca__c== null ? '' : app1[0].Income_Ca__c);
            newtmap.put('Evaluation Type','-');
            newtmap.put('Customer Code',app1[0].Customer_Code__c== null ? '' : app1[0].Customer_Code__c);
            newtmap.put('Employer Type','');
            newtmap.put('Share Holding(%)','');
        }     
        for(String key: newmap.keySet()){
            if(app.size() > 0){
                list<String> lst= new List<String>();
                lst.add(newmap.get(key));
                if(app1.size() > 0){
                    lst.add(newtmap.get(key));
                }else{
                    lst.add('');
                }
                Details.put(key,lst);
            }else{
                list<String> lst= new List<String>();
                lst.add('');
                lst.add('-');
                Details.put(key,lst);
            }
        }
        return Details;
    }
    
    @AuraEnabled(Cacheable=true)
    public static Map<String,Map<String,String>> fetchbankdetails(string opp,String app){
        system.debug('opp'+opp);
        Income_Details__c[] ic1=[select Id,Applicant__c,Name_of_Recipient_Banks__c,Name_of_Recipient_Banks__r.Name,Bank_Account_Number__c,Is_Income_Credited_In_Bank_Account__c,Applicant__r.Profile__c,Applicant__r.Income_Ca__c,Applicant__r.Total_Income__c,Applicant__r.Total_Income_ITR__c,Applicant__r.Total_Income_GST__c, name ,Do_You_File_ITR__c,Do_You_File_GST__c,Income__c,Name_of_Recipient_Bank__c,Profile__c,Profile__r.Name,
                                    Is_Salaried__c,Capture_Income_Method__c,Is_Self_Employed__c,ABB_to_be_considered__c,Remarks__c from Income_Details__c where Applicant__c=:app];
        system.debug('ic1 '+ic1);
        //Applicant__c[] details=[SELECT Id,Name,Opportunity__c,Name_of_Recipient_s_bank__c,Relationship_with_borrower__c,Profile__c,Customer_Code__c,Gender__c,Income_Ca__c,Entity__c,Marital_status__c,Applicant_Type__c From Applicant__c where Id=:app And Opportunity__c=:opp];
        //system.debug('details'+details);  
    
        Map<String,Map<String,String>> newt= new Map<String,Map<String,String>>();
        for(Income_Details__c i:ic1){
            Map<String,String> newmap= new Map<String,String>();
            //  List<Map<String,String>> newmaplist= new List<Map<String,String>>();
            newmap.put('Bank',i.Name_of_Recipient_Banks__c == null ? '' : i.Name_of_Recipient_Banks__r.Name);
            newmap.put('AccNo',i.Bank_Account_Number__c==null ? '' : i.Bank_Account_Number__c);
            newmap.put('ABB',i.ABB_to_be_considered__c == null ? '' : i.ABB_to_be_considered__c );
            newmap.put('IncomeRecordId',i.id);
            //newmaplist.add(newmap);
            newt.put(i.Name_of_Recipient_Banks__c,newmap);
        }
        return newt;
    }
    
    @AuraEnabled(Cacheable=true)
    public static Map<String,List<String>> FetchIncomes(string opp,string app,String bank){
        system.debug('opp'+opp);
        Applicant__c[] applicant=[SELECT Id,Name,Income_Ca__c,Profile__c,Opportunity__c,Total_Income__c,Total_Income_GST__c,Total_Income_ITR__c,Applicant_Type__c,Income_Details_Count__c From Applicant__c where Id=:app ];
        
        Income_Details__c[] ic1=[select Id,Applicant__c,Income_from_Perfios__c,Is_Income_Credited_In_Bank_Account__c,Name_of_Recipient_Banks__c,Applicant__r.Profile__c,Applicant__r.Income_Ca__c,Applicant__r.Total_Income__c,Applicant__r.Total_Income_ITR__c,Applicant__r.Total_Income_GST__c, name ,Do_You_File_ITR__c,Do_You_File_GST__c,Income__c,Name_of_Recipient_Bank__c,Profile__c,Profile__r.Name,
                                    Is_Salaried__c,Is_Self_Employed__c,Remarks__c,Checked_entered_income__c from Income_Details__c where Applicant__c=:app and Name_of_Recipient_Banks__c=:bank];
        system.debug('ic1 '+ic1);
        Map<String,List<String>> Details= new Map<String,List<String>>();
        List<String> income= new List<String>();
        List<String> income1= new List<String>();
        List<String> income2= new List<String>();
        List<String> file3= new List<String>();
        //added to get Income Id
        List<String> incomeIds= new List<String>();
        List<String> checkPerfiosList= new List<String>();
        decimal sum=0;
        decimal sum1=0;
        decimal sum2=0;
        for(Income_Details__c c:ic1){
            //added to get Income Id--start
            incomeIds.add(c.Id);
            Details.put('incomeId',incomeIds);
            checkPerfiosList.add(String.valueof(c.Checked_entered_income__c));
            Details.put('CheckedEnteredIncome',checkPerfiosList);
            //added to get Income Id--End
            if(c.Is_Salaried__c ==true  && c.Do_You_File_ITR__c==false){
                decimal num=c.Income__c/12;
                
                sum=sum+num.setScale(0);
                income.add(String.Valueof(num.setScale(0)));
                Details.put('salaried',income);
            }
            if(c.Do_You_File_ITR__c==true && c.Income__c!=null){
                decimal num=c.Income__c/12;
                sum1=sum1+num.setScale(0);
                income1.add(String.Valueof(num.setScale(0)));
                Details.put('ITR',income1);
            }
            if(c.Is_Salaried__c ==false && c.Is_Self_Employed__c==true && c.Do_You_File_GST__c==true){
                decimal num=c.Income__c/12;
                sum2=sum2+num.setScale(0);
                income2.add(String.Valueof(num.setScale(0)));
                Details.put('GST',income2);
            }
            if(c.Income_from_Perfios__c!=null){
                file3.add(string.valueof(c.Income_from_Perfios__c));
                Details.put('incomeperfios',file3);
            }
            
            
            
        }
        for(Applicant__c a:applicant){
            List<String> file= new List<String>();
            List<String> file1= new List<String>();
            List<String> file2= new List<String>();
            
            file.add(string.valueof(sum));
            Details.put('totalincome',file);
            
            file1.add(string.valueof(sum1));
            Details.put('totalitr',file1);
            
            file2.add(string.valueof(sum2));
            Details.put('totalgst',file2);
            
            
        }
        system.debug('app'+app);
        return Details;
    }
    
    
    @AuraEnabled(Cacheable=true)
    public static Map<String,List<Map<String,Map<String,String>>>> getincomedetailborrower(string opp,string app){
        system.debug('opp'+opp);
        Applicant__c[] applicant=[SELECT Id,Name,Income_Ca__c,Profile__c,Opportunity__c,Total_Income__c,Total_Income_GST__c,Total_Income_ITR__c,Applicant_Type__c,Income_Details_Count__c From Applicant__c where Id=:app ];
        
        Map<String,List<Map<String,Map<String,String>>>> newt= new Map<String,List<Map<String,Map<String,String>>>>();
        Income_Details__c[] ic1=[select Id,Income_Source_Status__c,Applicant__c,Income_from_Perfios__c,Is_Income_Credited_In_Bank_Account__c,Applicant__r.Profile__c,Applicant__r.Income_Ca__c,Applicant__r.Total_Income__c,Applicant__r.Total_Income_ITR__c,Applicant__r.Total_Income_GST__c, name ,Do_You_File_ITR__c,Do_You_File_GST__c,Income__c,Name_of_Recipient_Bank__c,Profile__c,Profile__r.Name,Profile__r.Category__c,
                                    Is_Salaried__c,Remarks__c from Income_Details__c where Applicant__c=:app];
        system.debug('ic1 '+ic1);
        List<Map<String,Map<String,String>>> sal= new List<Map<String,Map<String,String>>>();
        List<Map<String,Map<String,String>>> itr= new List<Map<String,Map<String,String>>>();
        List<Map<String,Map<String,String>>> gst= new List<Map<String,Map<String,String>>>();
        if(ic1.size()>0){
            for(Income_Details__c a: ic1){
                
                if(a.Is_Salaried__c == true && a.Do_You_File_ITR__c != true){
                    system.debug(a.Id);
                    
                    
                    Map<String,Map<String,String>> newtids= new Map<String,Map<String,String>>();
                    Map<String,String> newtmap=new Map<String,String>();
                    newtmap.put('ID',a.Applicant__c);
                    newtmap.put('Customer',a.Profile__r.Category__c== null ? '' : a.Profile__r.Category__c);
                    //newtmap.put('Evaluation','IP');
                    if(a.Income_Source_Status__c=='NIP'){
                        newtmap.put('Evaluation','NIP');
                    }else{
                        newtmap.put('Evaluation','IP');
                    }
                    newtmap.put('Profile',a.Profile__r.Name== null ? '' : a.Profile__r.Name);
                    newtmap.put('Income',a.Is_Income_Credited_In_Bank_Account__c? 'Yes' : 'No');
                    
                    if(a.Income__c!=null){
                        decimal num= a.Income__c/12;
                        Decimal rounded = num.setScale(0);
                        newtmap.put('source',String.valueof(rounded));
                        newtmap.put('AvgIncome',String.valueof(rounded));
                    }
                    newtids.put(String.valueof(a.Id),newtmap);
                    sal.add(newtids);
                    newt.put('Salaried',sal);
                }
                else if(a.Do_You_File_ITR__c == true){
                    system.debug(a.Id);
                    
                    Map<String,String> newtmap=new Map<String,String>();
                    Map<String,Map<String,String>> newtids= new Map<String,Map<String,String>>();
                    newtmap.put('ID',a.Applicant__c);
                    newtmap.put('Customer',a.Profile__r.Category__c== null ? '' : a.Profile__r.Category__c);
                    //newtmap.put('Evaluation','IP/NIP');
                    if(a.Income_Source_Status__c=='NIP'){
                        newtmap.put('Evaluation','NIP');
                    }else{
                        newtmap.put('Evaluation','IP');
                    }
                    newtmap.put('Profile',a.Profile__r.Name== null ? '' : a.Profile__r.Name);
                    if(a.Income__c!=null){
                        decimal num= a.Income__c/12;
                        Decimal rounded = num.setScale(0);
                        newtmap.put('source',String.valueof(rounded));
                        newtmap.put('AvgIncome',String.valueof(rounded));
                    }
                    // itr.put(newtmap);
                    newtids.put(String.valueof(a.Id),newtmap);
                    itr.add(newtids);
                    newt.put('ITR',itr);
                }
                else if(a.Is_Salaried__c != true && a.Do_You_File_GST__c == true){
                    system.debug(a.Id);
                    Map<String,String> newtmap=new Map<String,String>();
                    Map<String,Map<String,String>> newtids= new Map<String,Map<String,String>>();
                    newtmap.put('ID',a.Applicant__c);
                    newtmap.put('Customer',a.Profile__r.Category__c== null ? '' : a.Profile__r.Category__c);
                    //newtmap.put('Evaluation','IP');
                    if(a.Income_Source_Status__c=='NIP'){
                        newtmap.put('Evaluation','NIP');
                    }else{
                        newtmap.put('Evaluation','IP');
                    }
                    newtmap.put('Profile',a.Profile__r.Name== null ? '' : a.Profile__r.Name);
                    if(a.Income__c!=null){
                        decimal num= a.Income__c/12;
                        Decimal rounded = num.setScale(0);
                        newtmap.put('source',String.valueof(rounded));
                        newtmap.put('AvgIncome',String.valueof(rounded));
                    }
                    //gst.put(newtmap);
                    newtids.put(String.valueof(a.Id),newtmap);
                    
                    gst.add(newtids);
                    newt.put('GST',gst);
                }
            }
        }
        system.debug('newtitr gst' + newt.values());
        return newt;
    }
    
    
    @AuraEnabled(Cacheable=true)
    public static Map<String,List<Map<String,Map<String,String>>>> getincomedetailborrowerfields(string opp,string app){
        system.debug('opp'+opp);
        Applicant__c[] applicant=[SELECT Id,Name,Income_Ca__c,Profile__c,Opportunity__c,Total_Income__c,Total_Income_GST__c,Total_Income_ITR__c,Applicant_Type__c,Income_Details_Count__c From Applicant__c where Id=:app ];
        
        Map<String,List<Map<String,Map<String,String>>>>  newt= new Map<String,List<Map<String,Map<String,String>>>>();
        Income_Details__c[] ic1=[select Id,Applicant__c,Income_from_Perfios__c,Is_Income_Credited_In_Bank_Account__c,Applicant__r.Profile__c,Applicant__r.Income_Ca__c,Applicant__r.Total_Income__c,Applicant__r.Total_Income_ITR__c,Applicant__r.Total_Income_GST__c, name ,Do_You_File_ITR__c,Do_You_File_GST__c,Income__c,Name_of_Recipient_Bank__c,Profile__c,Profile__r.Name,
                                    Is_Salaried__c,Remarks__c from Income_Details__c where Applicant__c=:app];
        system.debug('ic1 '+ic1);
        List<Map<String,Map<String,String>>> sal= new List<Map<String,Map<String,String>>>();
        List<Map<String,Map<String,String>>> itr= new List<Map<String,Map<String,String>>>();
        List<Map<String,Map<String,String>>> gst= new List<Map<String,Map<String,String>>>();
        if(ic1.size()>0){
            for(Income_Details__c a: ic1){
                if(a.Is_Salaried__c == true){
                    system.debug(a.Id);
                    
                    
                    Map<String,Map<String,String>> newtids= new Map<String,Map<String,String>>();
                    Map<String,String> newtmap=new Map<String,String>();
                    newtmap.put('ID',a.Applicant__c);
                    newtmap.put('Customer',a.Applicant__r.Income_Ca__c== null ? '' : a.Applicant__r.Income_Ca__c);
                    newtmap.put('Evaluation','IP');
                    newtmap.put('Profile',a.Applicant__r.Profile__c== null ? '' : a.Applicant__r.Profile__c);
                    newtmap.put('Income',a.Is_Income_Credited_In_Bank_Account__c== null ? 'No' : 'Yes');
                    
                    if(a.Income__c!=null){
                        decimal num= a.Income__c/12;
                        Decimal rounded = num.setScale(0);
                        newtmap.put('source',String.valueof(a.Income__c));
                        newtmap.put('AvgIncome',String.valueof(rounded));
                    }
                    newtids.put(String.valueof(a.Id),newtmap);
                    sal.add(newtids);
                    newt.put('Salaried',sal);
                }
                else if(a.Is_Salaried__c != true && a.Do_You_File_ITR__c == true){
                    system.debug(a.Id);
                    
                    Map<String,String> newtmap=new Map<String,String>();
                    Map<String,Map<String,String>> newtids= new Map<String,Map<String,String>>();
                    newtmap.put('ID',a.Applicant__c);
                    newtmap.put('Customer',a.Applicant__r.Income_Ca__c== null ? '' : a.Applicant__r.Income_Ca__c);
                    newtmap.put('Evaluation','IP/NIP');
                    newtmap.put('Profile',a.Applicant__r.Profile__c== null ? '' : a.Applicant__r.Profile__c);
                    if(a.Income__c!=null){
                        newtmap.put('source',String.valueof(a.Income__c));
                        newtmap.put('AvgIncome',String.valueof(a.Income__c));
                    }
                    // itr.put(newtmap);
                    newtids.put(String.valueof(a.Id),newtmap);
                    itr.add(newtids);
                    newt.put('ITR',itr);
                }
                else if(a.Is_Salaried__c != true && a.Do_You_File_GST__c == true){
                    system.debug(a.Id);
                    Map<String,String> newtmap=new Map<String,String>();
                    Map<String,Map<String,String>> newtids= new Map<String,Map<String,String>>();
                    newtmap.put('ID',a.Applicant__c);
                    newtmap.put('Customer',a.Applicant__r.Income_Ca__c== null ? '' : a.Applicant__r.Income_Ca__c);
                    newtmap.put('Evaluation','IP');
                    newtmap.put('Profile',a.Applicant__r.Profile__c== null ? '' : a.Applicant__r.Profile__c);
                    if(a.Income__c!=null){
                        newtmap.put('source',String.valueof(a.Income__c));
                        newtmap.put('AvgIncome',String.valueof(a.Income__c));
                    }
                    //gst.put(newtmap);
                    newtids.put(String.valueof(a.Id),newtmap);
                    
                    gst.add(newtids);
                    newt.put('GST',gst);
                }
            }
        }
        
        system.debug('newtitr gst' + newt);
        return newt;
    }
    public class incomeDetailWrapper{
        @AuraEnabled public List<Income_Details__c> IncomeITR;
        @AuraEnabled public List<Income_Details__c> IncomeSalary;
        @AuraEnabled public List<Income_Details__c> IncomeGST;
        @AuraEnabled public Map<String,Income_Details__c> IncomeGSTval;
        @AuraEnabled public Map<String,Income_Details__c> Incomesalaried;
        @AuraEnabled public List<decimal> salaryincome;
        @AuraEnabled public List<decimal> GSTincome;
        @AuraEnabled public List<decimal> ITRincome;
        @AuraEnabled public Map<String,Id> incomeidrecord;
        @AuraEnabled public  String salremarks;
        @AuraEnabled public  String gstremarks;
        @AuraEnabled public  String itrremarks;
        @AuraEnabled public  String incomeId;
        @AuraEnabled public  String gstId;
        @AuraEnabled public  String itrId;
        @AuraEnabled public decimal incomefromperfiosSal;
        @AuraEnabled public decimal incomefromperfiosGST;
        @AuraEnabled public decimal incomefromperfiosITR;
        @AuraEnabled public decimal FIincome;
        @AuraEnabled public String checkedincome;
        }
    
    @AuraEnabled(Cacheable=true)
    public static incomeDetailWrapper Getincomerecords(string opp,string app){
        system.debug('opp'+opp);
        Applicant__c[] applicant=[SELECT Id,Name,Income_Ca__c,Profile__c,Opportunity__c,Total_Income__c,Total_Income_GST__c,Total_Income_ITR__c,Applicant_Type__c,Income_Details_Count__c From Applicant__c where Id=:app ];
        Income_Details__c[] incomedetails=[select Id,ABB_to_be_considered__c,Bank_Account_Number__c,Name_of_Recipient_Banks__c,Name_of_Recipient_Banks__r.Name,Applicant__c,Income_from_Perfios__c,Is_Income_Credited_In_Bank_Account__c,
        Applicant__r.Profile__c,Applicant__r.Income_Ca__c,Avg_Income__c,Applicant__r.Total_Income__c,Applicant__r.Total_Income_ITR__c,Capture_GST_Method__c,Capture_Income_Method__c,Capture_ITR_Method__c,
        Applicant__r.Total_Income_GST__c, name ,GST_No__c,Incomeproof__c,Do_You_File_ITR__c,Do_You_File_GST__c,Income__c,Profile__c,Profile__r.Name,Profile__r.Category__c,Primary_Income_Source__c, Applicant__r.Opportunity__r.LeadSource, //D2C Change
                                    Is_Salaried__c,Checked_entered_income__c,Client_Transaction_Id__c,Perfios_Transaction_Id__c,Remarks__c from Income_Details__c where Applicant__c=:app ORDER BY Primary_Income_Source__c,Income_from_Perfios__c] ;
        incomeDetailWrapper incomerecords= new incomeDetailWrapper();
        decimal perfiositr;
        decimal totalitr;
        Map<String,Income_Details__c> incomesal=new  Map<String,Income_Details__c>();
        Map<String,Income_Details__c> incomegst= new  Map<String,Income_Details__c>();
        List<Income_Details__c> incomeitr= new List<Income_Details__c>();
        MAP<String,String> details= new MAP<String,String>();
        MAP<String,String> abbdetails= new MAP<String,String>();
        if(incomedetails.size()>0){
            Case[] caseobj=[select Id,Applicant__c,Loan_Application__c from Case where Applicant__c=:app AND Loan_Application__c=:opp];
        Set<Id> ids= new Set<Id>();
        for(Case c: caseobj){
            ids.add(c.Id);
        }
        List<decimal> GSTvalues=new List<decimal>();
        List<decimal> ITRvalues=new List<decimal>();
        List<decimal> ITRvalues1=new List<decimal>();
        decimal incomefromfi;
        String remarksitr;
        String incId;
        String incitrId;
        String incgstId;
        String checked;
       
        Field_Investigation__c[] fiobj;
        if(ids.size()>0){
             fiobj=[select Id,Case__c,Income__c,Income_as_per_FI_Visit__c,Income_per_month__c,Income_per_month_property__c,Monthly_Income_as_per_FI_Visit__c,SENP_Agriculture_Income__c,
             SENP_Contractor_Income__c,SENP_Own_Shop_Income__c,SENP_Pension_Income__c,SENP_Rental_Income__c,SENP_Service_oriented_Income__c, SENP_Transporter_Income__c from  Field_Investigation__c where Case__c IN: ids];
        }
            for(Income_Details__c income:incomedetails){
                Income_Details__c salaried= new Income_Details__c();
                List<Income_Details__c> itrdetails=new List<Income_Details__c>();
                Income_Details__c gstdetails=new Income_Details__c();
                if(income.Is_Salaried__c==true && income.Do_You_File_ITR__c==false){
                    if(income.Client_Transaction_Id__c!=null || income.Perfios_Transaction_Id__c !=null){
                        incId =income.Id;
                    }
                    System.debug(income.Bank_Account_Number__c+''+salaried);
                    if(incomesal.containsKey(income.Bank_Account_Number__c)){
                        salaried= income;
                       // incomesal.put(income.Bank_Account_Number__c,salaried);
                    }else{
                        salaried= income;
                        if(income.Applicant__r.Opportunity__r.LeadSource == 'D2C' && income.Name_of_Recipient_Banks__r == null){ //D2C Change
                            salaried.Name_of_Recipient_Banks__r = new Bank_Masters__c(Name = '');
                            salaried.Bank_Account_Number__c = '';
                        }//EO_D2C Change
                        incomesal.put(income.Bank_Account_Number__c,salaried);
                    }
                }
                if(income.Do_You_File_ITR__c==true){
                    if(income.Client_Transaction_Id__c!=null || income.Perfios_Transaction_Id__c !=null){
                        incitrId =income.Id;
                        checked=String.valueof(income.Checked_entered_income__c);
                    }
                    if(income.Income_from_Perfios__c!=null){
                        perfiositr=income.Income_from_Perfios__c;
                        //incId =income.Id;
                    }
                    if(income.Remarks__c!=null){
                        remarksitr=income.Remarks__c;
                       // incId =income.Id;
                    }
                    incomeitr.add(income);
                    if(fiobj!=null && income.Primary_Income_Source__c==true && fiobj.size()>0){
                        for(Field_Investigation__c fi:fiobj){
                            if(ITRvalues1.size()>0){
                                break;
                            }else{
                                if(fi.Income__c!=null){
                                    ITRvalues1.add(fi.Income__c);
                                    incomefromfi=fi.Income__c;
                                }else if(fi.Income_as_per_FI_Visit__c!=null){
                                    ITRvalues1.add(fi.Income_as_per_FI_Visit__c);
                                    incomefromfi=fi.Income_as_per_FI_Visit__c;
                                }else if(fi.Income_per_month__c!=null){
                                    ITRvalues1.add(fi.Income_per_month__c);
                                    incomefromfi=fi.Income_per_month__c;
                                }else if(fi.Income_per_month_property__c!=null){
                                    ITRvalues1.add(fi.Income_per_month_property__c);
                                    incomefromfi=fi.Income_per_month_property__c;
                                }else if(fi.Monthly_Income_as_per_FI_Visit__c!=null){
                                    ITRvalues1.add(fi.Monthly_Income_as_per_FI_Visit__c);
                                    incomefromfi=fi.Monthly_Income_as_per_FI_Visit__c;
                                }else if(fi.SENP_Agriculture_Income__c!=null){
                                    ITRvalues1.add(fi.SENP_Agriculture_Income__c);
                                    incomefromfi=fi.SENP_Agriculture_Income__c;
                                }else if(fi.SENP_Contractor_Income__c!=null){
                                    ITRvalues1.add(fi.SENP_Contractor_Income__c);
                                    incomefromfi=fi.SENP_Contractor_Income__c;
                                }else if(fi.SENP_Own_Shop_Income__c!=null){
                                    ITRvalues1.add(fi.SENP_Own_Shop_Income__c);
                                    incomefromfi=fi.SENP_Own_Shop_Income__c;
                                }else if(fi.SENP_Pension_Income__c	!=null){
                                    ITRvalues1.add(fi.SENP_Pension_Income__c);
                                    incomefromfi=fi.SENP_Pension_Income__c;
                                }else if(fi.SENP_Rental_Income__c!=null){
                                    ITRvalues1.add(fi.SENP_Rental_Income__c);
                                    incomefromfi=fi.SENP_Rental_Income__c;
                                }else if(fi.SENP_Service_oriented_Income__c!=null){
                                    ITRvalues1.add(fi.SENP_Service_oriented_Income__c);
                                    incomefromfi=fi.SENP_Service_oriented_Income__c;
                                }
                                else if(fi.SENP_Transporter_Income__c!=null){
                                    ITRvalues1.add(fi.SENP_Transporter_Income__c);
                                    incomefromfi=fi.SENP_Transporter_Income__c;
                                }
                            }
                        }
                        if(ITRvalues1.isEmpty()){
                            decimal inc=income.Income__c/12;
                            decimal incval=inc.setScale(2);
                            ITRvalues.add(incval);
                            incomefromfi=incval;
                        }else{
                            for(decimal st:ITRvalues1){
                                ITRvalues.add(st);
                            }
                        }
                    }else{
                        decimal inc=income.Income__c/12;
                        decimal incval=inc.setScale(2);
                        ITRvalues.add(incval);
                    }
                }
                if(income.Do_You_File_GST__c==true){
                    if(incomegst.containsKey(income.GST_No__c)){
                        if(income.Client_Transaction_Id__c!=null || income.Perfios_Transaction_Id__c !=null){
                            incgstId =income.Id;
                        }
                        gstdetails=income;
                        //incomegst.put(income.GST_No__c,income);
                    }else{
                        gstdetails=income;
                        incomegst.put(income.GST_No__c,gstdetails);
                    }
                }
            }
            if(incomesal.size()>0){
            incomerecords.Incomesalaried=incomesal;
            }
            if(incomeitr.size()>0){
            incomerecords.IncomeITR=incomeitr;
            }
            incomerecords.ITRincome=ITRvalues;
            if(incomegst.size()>0){
            incomerecords.IncomeGSTval=incomegst;
            }
            
            incomerecords.incomefromperfiosITR=perfiositr;
            incomerecords.itrremarks=remarksitr;
            incomerecords.incomeId=incId;
            incomerecords.gstId=incgstId;
            incomerecords.itrId=incitrId;
            incomerecords.FIincome=incomefromfi;
            incomerecords.checkedincome=checked;
        }
        
        return incomerecords;
    }
    
    @AuraEnabled(Cacheable=true)
    public static incomeDetailWrapper Getincomerecordssalaried(string opp,string app,string bankno){
        system.debug('opp'+opp);
        Applicant__c[] applicant=[SELECT Id,Name,Income_Ca__c,Profile__c,Opportunity__c,Total_Income__c,Total_Income_GST__c,Total_Income_ITR__c,Applicant_Type__c,Income_Details_Count__c From Applicant__c where Id=:app ];
        Income_Details__c[] incomedetails=[select Id,ABB_to_be_considered__c,Bank_Account_Number__c,Name_of_Recipient_Banks__c,Name_of_Recipient_Banks__r.Name,Applicant__c,Income_from_Perfios__c,Is_Income_Credited_In_Bank_Account__c,
        Applicant__r.Profile__c,Applicant__r.Income_Ca__c,Avg_Income__c,Applicant__r.Total_Income__c,Applicant__r.Total_Income_ITR__c,Capture_GST_Method__c,Capture_Income_Method__c,Capture_ITR_Method__c,
        Applicant__r.Total_Income_GST__c, name ,GST_No__c,Incomeproof__c,Do_You_File_ITR__c,Do_You_File_GST__c,Income__c,Profile__c,Profile__r.Name,Profile__r.Category__c,Primary_Income_Source__c,
                                    Is_Salaried__c,Checked_entered_income__c,Client_Transaction_Id__c,Perfios_Transaction_Id__c,Remarks__c from Income_Details__c where Applicant__c=:app AND Bank_Account_Number__c=:bankno];
        Case[] caseobj=[select Id,Applicant__c,Loan_Application__c from Case where Applicant__c=:app AND Loan_Application__c=:opp];
        Set<Id> ids= new Set<Id>();
        decimal perfiossal;
        String checked;
        for(Case c: caseobj){
            ids.add(c.Id);
        }
        Field_Investigation__c[] fiobj;
        String remarksinc;
        String incId;
        if(ids.size()>0){
             fiobj=[select Id,Case__c,Income__c,Income_as_per_FI_Visit__c,Income_per_month__c,Income_per_month_property__c,Monthly_Income_as_per_FI_Visit__c,SENP_Agriculture_Income__c,
             SENP_Contractor_Income__c,SENP_Own_Shop_Income__c,SENP_Pension_Income__c,SENP_Rental_Income__c,SENP_Service_oriented_Income__c, SENP_Transporter_Income__c from  Field_Investigation__c where Case__c IN: ids];
        }
        decimal incomefromfi;
        incomeDetailWrapper incomerecords= new incomeDetailWrapper();
        List<Income_Details__c> incomesal=new List<Income_Details__c>();
        List<decimal> incomevalues=new List<decimal>();
        List<decimal> incomevalues1=new List<decimal>();
        if(incomedetails.size()>0){
            for(Income_Details__c income:incomedetails){
                
            if(income.Is_Salaried__c==true){
                incomesal.add(income);
                if(income.Client_Transaction_Id__c!=null || income.Perfios_Transaction_Id__c !=null){
                    incId =income.Id;
                    checked=String.valueof(income.Checked_entered_income__c);
                }
                if(income.Income_from_Perfios__c!=null){
                    perfiossal=income.Income_from_Perfios__c;
                   // incId=income.Id;
                }
                if(income.Remarks__c!=null){
                    remarksinc=income.Remarks__c;
                  //  incId =income.Id;
                }   
                if(fiobj!=null && income.Primary_Income_Source__c==true && fiobj.size()>0){
                    for(Field_Investigation__c fi:fiobj){
                        if(incomevalues1.size()>0){
                            break;
                        }else{
                            if(fi.Income__c!=null){
                                incomevalues1.add(fi.Income__c);
                                incomefromfi=fi.Income__c;
                            }else if(fi.Income_as_per_FI_Visit__c!=null){
                                incomevalues1.add(fi.Income_as_per_FI_Visit__c);
                                incomefromfi=fi.Income_as_per_FI_Visit__c;
                            }else if(fi.Income_per_month__c!=null){
                                incomevalues1.add(fi.Income_per_month__c);
                                incomefromfi=fi.Income_per_month__c;
                            }else if(fi.Income_per_month_property__c!=null){
                                incomevalues1.add(fi.Income_per_month_property__c);
                                incomefromfi=fi.Income_per_month_property__c;
                            }else if(fi.Monthly_Income_as_per_FI_Visit__c!=null){
                                incomevalues1.add(fi.Monthly_Income_as_per_FI_Visit__c);
                                incomefromfi=fi.Monthly_Income_as_per_FI_Visit__c;
                            }else if(fi.SENP_Agriculture_Income__c!=null){
                                incomevalues1.add(fi.SENP_Agriculture_Income__c);
                                incomefromfi=fi.SENP_Agriculture_Income__c;
                            }else if(fi.SENP_Contractor_Income__c!=null){
                                incomevalues1.add(fi.SENP_Contractor_Income__c);
                                incomefromfi=fi.SENP_Contractor_Income__c;
                            }else if(fi.SENP_Own_Shop_Income__c!=null){
                                incomevalues1.add(fi.SENP_Own_Shop_Income__c);
                                incomefromfi=fi.SENP_Own_Shop_Income__c;
                            }else if(fi.SENP_Pension_Income__c	!=null){
                                incomevalues1.add(fi.SENP_Pension_Income__c);
                                incomefromfi=fi.SENP_Pension_Income__c;
                            }else if(fi.SENP_Rental_Income__c!=null){
                                incomevalues1.add(fi.SENP_Rental_Income__c);
                                incomefromfi=fi.SENP_Rental_Income__c;
                            }else if(fi.SENP_Service_oriented_Income__c!=null){
                                incomevalues1.add(fi.SENP_Service_oriented_Income__c);
                                incomefromfi=fi.SENP_Service_oriented_Income__c;
                            }
                            else if(fi.SENP_Transporter_Income__c!=null){
                                incomevalues1.add(fi.SENP_Transporter_Income__c);
                                incomefromfi=fi.SENP_Transporter_Income__c;
                            }
                        }
                        
                    }
                    if(incomevalues1.isEmpty()){
                        decimal inc=income.Income__c/12;
                                decimal incval=inc.setScale(2);
                                incomevalues.add(incval);
                                incomefromfi=incval;
                    }else{
                        for(decimal st:incomevalues1){
                        incomevalues.add(st);
                    }
                    }
                }else{
                    decimal inc=income.Income__c/12;
                    decimal incval=inc.setScale(2);
                    incomevalues.add(incval);
                }
            }
            }
        incomerecords.IncomeSalary=incomesal;
        incomerecords.salaryincome=incomevalues;
        incomerecords.incomefromperfiosSal=perfiossal;
        incomerecords.salremarks=remarksinc;
        incomerecords.incomeId=incId;
        incomerecords.FIincome=incomefromfi;
        incomerecords.checkedincome=checked;
        }
        
        return incomerecords;
    }
    
    @AuraEnabled(Cacheable=true)
    public static incomeDetailWrapper GetincomerecordsGST(string opp,string app,string gstno){
        system.debug('opp'+opp);
        Applicant__c[] applicant=[SELECT Id,Name,Income_Ca__c,Profile__c,Opportunity__c,Total_Income__c,Total_Income_GST__c,Total_Income_ITR__c,Applicant_Type__c,Income_Details_Count__c From Applicant__c where Id=:app ];
        Income_Details__c[] incomedetails=[select Id,ABB_to_be_considered__c,Bank_Account_Number__c,Name_of_Recipient_Banks__c,Name_of_Recipient_Banks__r.Name,Applicant__c,Income_from_Perfios__c,Is_Income_Credited_In_Bank_Account__c,
        Applicant__r.Profile__c,Applicant__r.Income_Ca__c,Applicant__r.Total_Income__c,Applicant__r.Total_Income_ITR__c,Capture_GST_Method__c,Capture_Income_Method__c,Capture_ITR_Method__c,
        Applicant__r.Total_Income_GST__c, name ,GST_No__c,Avg_Income__c,Incomeproof__c,Do_You_File_ITR__c,Do_You_File_GST__c,Income__c,Profile__c,Profile__r.Name,Profile__r.Category__c,Primary_Income_Source__c,
                                    Is_Salaried__c,Checked_entered_income__c,Client_Transaction_Id__c,Perfios_Transaction_Id__c,Remarks__c from Income_Details__c where Applicant__c=:app AND GST_No__c=:gstno];
        Case[] caseobj=[select Id,Applicant__c,Loan_Application__c from Case where Applicant__c=:app AND Loan_Application__c=:opp];
        Set<Id> ids= new Set<Id>();
        for(Case c: caseobj){
            ids.add(c.Id);
        }
        String remarksgst;
        String incId;
        String checked;
        Field_Investigation__c[] fiobj;
        decimal perfiosgst;
        if(ids.size()>0){
             fiobj=[select Id,Case__c,Income__c,Income_as_per_FI_Visit__c,Income_per_month__c,Income_per_month_property__c,Monthly_Income_as_per_FI_Visit__c,SENP_Agriculture_Income__c,
             SENP_Contractor_Income__c,SENP_Own_Shop_Income__c,SENP_Pension_Income__c,SENP_Rental_Income__c,SENP_Service_oriented_Income__c, SENP_Transporter_Income__c from  Field_Investigation__c where Case__c IN: ids];
        }
        decimal incomefromfi;
        incomeDetailWrapper incomerecords= new incomeDetailWrapper();
        List<Income_Details__c> gstdetails=new List<Income_Details__c>();
        List<decimal> GSTvalues=new List<decimal>();
        List<decimal> GSTvalues1=new List<decimal>();
        if(incomedetails.size()>0){
            for(Income_Details__c income:incomedetails){
                if(income.Do_You_File_GST__c==true){
                        gstdetails.add(income);    
                        if(income.Client_Transaction_Id__c!=null || income.Perfios_Transaction_Id__c !=null){
                            incId =income.Id;
                            checked=String.valueof(income.Checked_entered_income__c);
                        }   
                        if(income.Income_from_Perfios__c!=null){
                            perfiosgst=income.Income_from_Perfios__c;
                           // incId =income.Id;
                        } 
                        if(income.Remarks__c!=null){
                            remarksgst=income.Remarks__c;
                           // incId =income.Id;
                        }   
                    if(fiobj!=null && income.Primary_Income_Source__c==true && fiobj.size()>0){
                        for(Field_Investigation__c fi:fiobj){
                            if(GSTvalues1.size()>0){
                                break;
                            }else{
                                if(fi.Income__c!=null){
                                    GSTvalues1.add(fi.Income__c);
                                    incomefromfi=fi.Income__c;
                                }else if(fi.Income_as_per_FI_Visit__c!=null){
                                    GSTvalues1.add(fi.Income_as_per_FI_Visit__c);
                                    incomefromfi=fi.Income_as_per_FI_Visit__c;
                                }else if(fi.Income_per_month__c!=null){
                                    GSTvalues1.add(fi.Income_per_month__c);
                                    incomefromfi=fi.Income_per_month__c;
                                }else if(fi.Income_per_month_property__c!=null){
                                    GSTvalues1.add(fi.Income_per_month_property__c);
                                    incomefromfi=fi.Income_per_month_property__c;
                                }else if(fi.Monthly_Income_as_per_FI_Visit__c!=null){
                                    GSTvalues1.add(fi.Monthly_Income_as_per_FI_Visit__c);
                                    incomefromfi=fi.Monthly_Income_as_per_FI_Visit__c;
                                }else if(fi.SENP_Agriculture_Income__c!=null){
                                    GSTvalues1.add(fi.SENP_Agriculture_Income__c);
                                    incomefromfi=fi.SENP_Agriculture_Income__c;
                                }else if(fi.SENP_Contractor_Income__c!=null){
                                    GSTvalues1.add(fi.SENP_Contractor_Income__c);
                                    incomefromfi=fi.SENP_Contractor_Income__c;
                                }else if(fi.SENP_Own_Shop_Income__c!=null){
                                    GSTvalues1.add(fi.SENP_Own_Shop_Income__c);
                                    incomefromfi=fi.SENP_Own_Shop_Income__c;
                                }else if(fi.SENP_Pension_Income__c	!=null){
                                    GSTvalues1.add(fi.SENP_Pension_Income__c);
                                    incomefromfi=fi.SENP_Pension_Income__c;
                                }else if(fi.SENP_Rental_Income__c!=null){
                                    GSTvalues1.add(fi.SENP_Rental_Income__c);
                                    incomefromfi=fi.SENP_Rental_Income__c;
                                }else if(fi.SENP_Service_oriented_Income__c!=null){
                                    GSTvalues1.add(fi.SENP_Service_oriented_Income__c);
                                    incomefromfi=fi.SENP_Service_oriented_Income__c;
                                }
                                else if(fi.SENP_Transporter_Income__c!=null){
                                    GSTvalues1.add(fi.SENP_Transporter_Income__c);
                                    incomefromfi=fi.SENP_Transporter_Income__c;
                                }else{
                                   
                                }
                            }
                        }
                        if(GSTvalues1.isEmpty()){
                            decimal inc=income.Income__c/12;
                                    decimal incval=inc.setScale(2);
                                    GSTvalues.add(incval);
                                    incomefromfi=incval;
                        }else{
                            for(decimal st:GSTvalues1){
                            GSTvalues.add(st);
                            }
                        }
                    }else{
                        decimal inc=income.Income__c/12;
                        decimal incval=inc.setScale(2);
                        GSTvalues.add(incval);
                    }
                }
            }
            incomerecords.IncomeGST=gstdetails;
        incomerecords.GSTincome=GSTvalues;
        incomerecords.incomefromperfiosGST=perfiosgst;
        incomerecords.gstremarks=remarksgst;
        incomerecords.incomeId=incId;
        incomerecords.FIincome=incomefromfi;
        incomerecords.checkedincome=checked;
        }
        
        return incomerecords;
    }
    
    @AuraEnabled(Cacheable=true)
    public static fiInfoWrapper getFiInfo(Id oppId){
        List<Field_Investigation__c> fiRecord = [SELECT Id, Crop_Net_income__c, Other_source_of_Income__c, Non_Agri_Income__c, Total_Agri_Income_for_Proposed_Tractor__c, Total_Agri_Income_for_Existing_Tractor__c, Total_Agri_Comm_Income_Existing_Tractor__c, Total_Agri_Comm_Income_Proposed_Tractor__c  from Field_Investigation__c where Case__r.Loan_Application__c =:oppId AND Case__r.Type = 'Current Residence FI' AND Case__r.Applicant__r.Applicant_Type__c = 'Borrower' LIMIT 1];
        List<AggregateResult> result = [SELECT SUM( Amount__c) totalExpense, Field_Investigation__r.Case__r.Loan_Application__c  from Total_Expense_and_investment__c where Type__c = 'Expense' AND Field_Investigation__r.Case__r.Loan_Application__c =:oppId AND Field_Investigation__r.Case__r.Applicant__r.Applicant_Type__c = 'Borrower'  group by Field_Investigation__r.Case__r.Loan_Application__c];
        fiInfoWrapper fiWrapper = new fiInfoWrapper();
        Integer allIncome = 0;
        if (!fiRecord.isEmpty()) {
            fiWrapper.cropNetIncome = fiRecord[0].Crop_Net_income__c != null ? Integer.valueOf(fiRecord[0].Crop_Net_income__c) : 0;
            allIncome += fiWrapper.cropNetIncome;
            fiWrapper.otherIncomeSource = fiRecord[0].Other_source_of_Income__c != null && String.valueOf(fiRecord[0].Other_source_of_Income__c).isNumeric() ? Integer.valueOf(fiRecord[0].Other_source_of_Income__c) : 0;
            allIncome += fiWrapper.otherIncomeSource;
            fiWrapper.nonAgriIncome = fiRecord[0].Non_Agri_Income__c != null ? Integer.valueOf(fiRecord[0].Non_Agri_Income__c) : 0;
            allIncome += fiWrapper.nonAgriIncome;
            fiWrapper.existingProposedTractorIncome = (fiRecord[0].Total_Agri_Income_for_Proposed_Tractor__c != null ? Integer.valueOf(fiRecord[0].Total_Agri_Income_for_Proposed_Tractor__c) : 0) +
                                                     (fiRecord[0].Total_Agri_Income_for_Existing_Tractor__c != null ? Integer.valueOf(fiRecord[0].Total_Agri_Income_for_Existing_Tractor__c) : 0) + 
                                                     (fiRecord[0].Total_Agri_Comm_Income_Existing_Tractor__c != null ? Integer.valueOf(fiRecord[0].Total_Agri_Comm_Income_Existing_Tractor__c) : 0) +
                                                     (fiRecord[0].Total_Agri_Comm_Income_Proposed_Tractor__c != null ? Integer.valueOf(fiRecord[0].Total_Agri_Comm_Income_Proposed_Tractor__c) : 0);
            allIncome += fiWrapper.existingProposedTractorIncome;
        }
        fiWrapper.totalExpense =  !result.isEmpty() && result[0].get('totalExpense') != null ? Integer.valueOf(result[0].get('totalExpense')) : 0;
        fiWrapper.netIncome = allIncome - fiWrapper.totalExpense ;
        
        System.debug(JSON.serializePretty(fiWrapper));
        return fiWrapper;
    }
    public class fiInfoWrapper {
        
        @AuraEnabled public Integer cropNetIncome {get;set;}
        @AuraEnabled public Integer otherIncomeSource {get;set;}
        @AuraEnabled public Integer existingProposedTractorIncome {get;set;}
        @AuraEnabled public Integer nonAgriIncome {get;set;}
        @AuraEnabled public Integer totalExpense {get;set;}
        @AuraEnabled public Integer netIncome {get;set;}
    }
    
    @AuraEnabled(Cacheable=true)
    public static Map<String,String> getincomeborrowerhome(string opp){
        system.debug('opp'+opp);
        // D2C_CHANGE - Raman, Added fields in query -> LeadSource,Is_Pre_Approved__c,
        Applicant__c[] app=[SELECT Id,Name,Income_Ca__c,Profile__c,Opportunity__r.Sub_Stage__c,Opportunity__c,Opportunity__r.Sanction_Status__c,Opportunity__r.Product_Type__c, Opportunity__r.Is_Pre_Approved__c, Opportunity__r.LeadSource, Applicant_Type__c,Income_Details_Count__c,In_Active_Applicant__c From Applicant__c where Opportunity__c=:opp and In_Active_Applicant__c=:false];
        system.debug('app'+app);
        Map<String,String> newt= new Map<String,String>();
        for(Applicant__c a:app){
            if(a.Applicant_Type__c=='Borrower'){
                newt.put('Borrower',String.valueOf(a.Id));
            }else if(a.Applicant_Type__c=='Co-borrower'){
                newt.put('Co-borrower',String.valueOf(a.Id));
            }else{
                newt.put('error',String.valueOf(a.Id));
            }
            if(a.Opportunity__r.Product_Type__c!='Two Wheeler' && a.Opportunity__r.Sanction_Status__c!='STP'){
                newt.put('journey','PV');
            }
            if(a.Opportunity__r.Sub_Stage__c!='Income'){
                newt.put('substage','income');
            }
             //CISP-2380
             if(a.Applicant_Type__c=='Borrower'){
                newt.put('BorrowerProfile',a.Profile__c);
            }else if(a.Applicant_Type__c=='Co-borrower'){
                newt.put('Co-borrowerProfile',a.Profile__c);
            }
            //CISP-2380
            //Added by Rohan for D2C
            if(a.Opportunity__r.LeadSource=='D2C' && !(a.Opportunity__r.Is_Pre_Approved__c==false && a.Opportunity__r.Sanction_Status__c=='Non-STP')){
                newt.put('D2C','ShowIncome');
            }
            
        }
        
        return newt;
    }
    @AuraEnabled(Cacheable=true)
    public static Boolean fetchavginc(string opp){
        List<Case> caseList;
        system.debug('opp'+opp);
        caseList = [select Id,OwnerId,Loan_Application__c from Case where Loan_Application__c =:opp and RecordType.DeveloperName ='FI'];
        system.debug('caseList'+caseList);
        
        Boolean newt;
        if(caseList.size()>0){
            newt=true;
        }else{
            newt=false;
        }
        
        return newt;
    }
    
    @AuraEnabled(Cacheable=true)
    public static String varientdetails(string opp){
        system.debug('opp'+opp);
        Opportunity loanDetailsList = [SELECT Id,Name,Loan_amount__c,Product_Type__c,Vehicle_Sub_Category__c,Vehicle_Type__c, LeadSource
                                        FROM Opportunity WHERE Id =: opp WITH SECURITY_ENFORCED LIMIT 1 ];
        String newt='';
        if(loanDetailsList!= null){
            newt= loanDetailsList.Vehicle_Type__c;
            system.debug('newtitr gst' + newt);
        }
        return newt;
    }
    
    
    public class LoanDetailWrapper{
        @AuraEnabled public Vehicle_Detail__c vechicalDetail;
        @AuraEnabled public String loanAmt;
        @AuraEnabled public String productTypestr;
        @AuraEnabled public String vehicleSubCategoryStr;
        @AuraEnabled public String vehicleTypeStr;
        @AuraEnabled public String citycode; 
        @AuraEnabled public String name; 
        @AuraEnabled public String applicantId;
        @AuraEnabled public String coapplicantId;
        @AuraEnabled public Decimal maxValue;
        @AuraEnabled public Decimal minValue;
        @AuraEnabled public Decimal gstPercentage;
        @AuraEnabled public String variantcode;
        @AuraEnabled public String leadSource;//D2C Changes Swapnil
        @AuraEnabled public Boolean isPA;//D2C Changes Raman
    }
    @AuraEnabled(Cacheable=true)
    public static LoanDetailWrapper getDetailsforLoan(String opportunityId) {
        system.debug('@@@ ' + opportunityId);   
        if(opportunityId != null){
            
            Opportunity loanDetailsList = [SELECT Id,Name,Loan_amount__c,Product_Type__c,lead_number__c,Vehicle_Sub_Category__c,Vehicle_Type__c, LeadSource, Is_Pre_Approved__c //D2C Changes Raman - Added LeadSource, Is_Pre_Approved__c
                                            FROM Opportunity WHERE Id =: opportunityId WITH SECURITY_ENFORCED LIMIT 1 ];
            List<Documents__C> docObjList = [select id, KYC_City__c from Documents__C where RecordType.Name = 'KYC Document' and Opportunity_Relation__c = :opportunityId and KYC_City__c != null WITH SECURITY_ENFORCED LIMIT 1];
            Vehicle_Detail__c vehicle=  [SELECT ID,Variant__c,Manufacturer_Year_Month__c,Loan_Application__c,Variant_Code__c,Insurance_expiring_within_60_days__c,City__c,Eligible_Tenure__c,Eligible_Loan_Amount__c 
                                            FROM Vehicle_Detail__c where Loan_Application__c=:opportunityId WITH SECURITY_ENFORCED LIMIT 1 ];
            LoanDetailWrapper loandetailsObj = new LoanDetailWrapper();
            Applicant__c[] app1= [select Id, name ,Applicant_Type__c from applicant__c where opportunity__c =:opportunityId and Applicant_Type__c =: 'Borrower'];
            Applicant__c[] app2= [select Id, name ,Applicant_Type__c from applicant__c where opportunity__c =:opportunityId and Applicant_Type__c =: 'Co-borrower'];
            if(loanDetailsList!=null && !docObjList.isEmpty() && vehicle!=null && app1!=null)
            {
                String cityName = docObjList[0].KYC_City__c;
                String vehicleCategoryCode; 
                List <City_State_Master__c> cityMasterList = [select Carwale_ID__c,City_Code__c from City_State_Master__c where Name =: cityName WITH SECURITY_ENFORCED LIMIT 1];                
                loandetailsObj.loanAmt = loanDetailsList.Loan_amount__c;
                loandetailsObj.productTypestr = loanDetailsList.Product_Type__c;
                loandetailsObj.vehicleSubCategoryStr = loanDetailsList.Vehicle_Sub_Category__c;
                loandetailsObj.vehicleTypeStr = loanDetailsList.Vehicle_Type__c;
                loandetailsObj.name = loanDetailsList.lead_number__c;
                loandetailsObj.leadSource = loanDetailsList.LeadSource;//D2C Changes Swapnil
                loandetailsObj.isPA = loanDetailsList.Is_Pre_Approved__c;//D2C Changes Raman
                if(!app1.isEmpty()){
                    loandetailsObj.applicantId=app1[0].Id;
                }
                if(!app2.isEmpty()){
                    loandetailsObj.coapplicantId=app2[0].Id;
                }
                
                List<Vehicle_Detail__c> vechicalList = new List<Vehicle_Detail__c>();
                if(loanDetailsList.Vehicle_Details__r != null)
                {
                    loandetailsObj.vechicalDetail = vehicle;  
                }
                if(!cityMasterList.isEmpty()){
                    loandetailsObj.citycode = String.valueof(cityMasterList[0].Carwale_ID__c);
                }
                String VariantName = vehicle.Variant__c;
                if(VariantName != null){
                    List<Product2> prodObjList =  [select Id, Variant_Code__c from Product2 where Name =: VariantName WITH SECURITY_ENFORCED LIMIT 1];
                    
                    if(!prodObjList.isEmpty()){
                        loandetailsObj.variantcode = prodObjList[0].Variant_Code__c;
                    }
                }
                return loandetailsObj;
            }
        }
        return null;
        
    }   
    @AuraEnabled(Cacheable=true)
    public static String getDetailsvarientcode(String opportunityId) {
        system.debug('@@@ ' + opportunityId);   
        if(opportunityId != null){
            String variantcode;
            Vehicle_Detail__c vehicle=  [SELECT ID,Variant__c,Loan_Application__c,Variant_Code__c 
                                            FROM Vehicle_Detail__c where Loan_Application__c=:opportunityId WITH SECURITY_ENFORCED LIMIT 1 ];
            system.debug('@@@ ' + vehicle);
            if(vehicle!=null)
            {
                String VarientName=vehicle.Variant__c;
                system.debug('@@@ ' + VarientName);
                if(VarientName != null){
                    List<Product2> prodObjList =  [select Id, Variant_Code__c,type__c from Product2 where Name =: VarientName AND type__c = 'Variant' WITH SECURITY_ENFORCED LIMIT 1];
                    system.debug('@@@ ' + prodObjList);
                    if(!prodObjList.isEmpty()){
                    variantcode = prodObjList[0].Variant_Code__c;
                        system.debug('@@@ ' + prodObjList);
                    return variantcode;
                    }
                }  
        }
    }
        return null;
        
    }   
    @AuraEnabled(Cacheable=true continuation=true)
    public static Map<String,String> getRecordsVarientnew(string opp, String vRecordId){
        system.debug('opp'+opp);
        Opportunity[] app=[SELECT Id,Name,Make__c,Model__c,Vehicle_Type__c,Product_Type__c,Total_Funded_Premium__c, Variant__c,Basic_Price__c,GST_Amount__c,Dealer_Disc_to_Customer__c,Discount_on_Basic_Price__c,Ex_showroom_price__c,Ex_showroom_price_carwale__c,RTO_Road_Tax__c,RTO_Road_Tax_New__c,Other_charges__c,
                            X1st_yr_Insurance_Premium__c, On_Road_price__c,On_Road_price_carwale__c, Funding_on_Ex_Showroom__c,Required_Loan_amount__c,Funding_on_ORP__c,Dealer_Quoted_On_Road_Price__c, FAME_Subsidy__c,Performance_Upgrade__c From Opportunity where Id=:opp]; //D2C Change, added Dealer_Quoted_On_Road_Price__c //OLA-140 & CISP-4778
        Applicant__c[] app1= [select Id, name ,Applicant_Type__c,opportunity__c from applicant__c where opportunity__c =:opp and Applicant_Type__c =: 'Borrower'];
        String vQuery = 'Select Id,Loan_Application__c,Base_Prices__c,Make__c,Model__c,Variant__c,Model_Code__c,Basic_Price__c,GST_Amount__c,X1st_yr_Insurance_Premium__c, Invoice_Price__c, Make_Code__c,Loan_Amount__c,Vehicle_SubType__c from Vehicle_Detail__c where Loan_Application__c=\'' + opp + '\' ';

        vQuery += (String.isNotBlank(vRecordId) ? 'AND Id = \'' + vRecordId + '\'' : ''); 
        Vehicle_Detail__c[] vehicledetails= Database.query(vQuery);//CISP-2952
        Final_Term__c[] Finalterm = [select id,Name,Dealer_Disc_to_Customer__c,Loan_Amount__c from Final_Term__c where Loan_Application__c=: opp AND Vehicle_Detail__c=:vRecordId];

        System_Constant_custom_metadata__mdt metadata = System_Constant_custom_metadata__mdt.getInstance('GstPercentage');
        Map<String,String> newmap= new Map<String,String>();
        Map<String,String> newtmap= new Map<String,String>();
        Decimal totalamount = app[0].Total_Funded_Premium__c;
        system.debug('app'+app);
        
        if(app.size() > 0 && vehicledetails.size()>0 && Finalterm.size()>0){
            if(app[0].Product_Type__c ==System.Label.Tractor){
                newmap.put('Id',vehicledetails[0].Id== null ? '':string.valueof(vehicledetails[0].Id));
                newmap.put('Make__c',vehicledetails[0].Make__c== null ? '':string.valueof(vehicledetails[0].Make__c));
                newmap.put('Model__c',vehicledetails[0].Model__c== null ? '':string.valueof(vehicledetails[0].Model__c));
                newmap.put('Variant__c',vehicledetails[0].Variant__c== null ? '':string.valueof(vehicledetails[0].Variant__c));
                newmap.put('Basic_Price__c',vehicledetails[0].Basic_Price__c== null ? '':string.valueof(vehicledetails[0].Basic_Price__c));
                newmap.put('Base_Prices__c',vehicledetails[0].Base_Prices__c== null ? '':string.valueof(vehicledetails[0].Base_Prices__c));
                newmap.put('GST_Amount__c',vehicledetails[0].GST_Amount__c== null ? '':string.valueof(vehicledetails[0].GST_Amount__c));
                newmap.put('X1st_yr_Insurance_Premium__c',vehicledetails[0].X1st_yr_Insurance_Premium__c== null ? '':string.valueof(vehicledetails[0].X1st_yr_Insurance_Premium__c));
                newmap.put('Model_Code__c', vehicledetails[0].Model_Code__c==null ? '':string.valueOf(vehicledetails[0].Model_Code__c));//CISP-2952
                newmap.put('Invoice_Price__c', vehicledetails[0].Invoice_Price__c==null ? '':string.valueOf(vehicledetails[0].Invoice_Price__c));
                newmap.put('Required_Loan_amount__c',vehicledetails[0].Loan_Amount__c== null ? '':string.valueof(vehicledetails[0].Loan_Amount__c));         
                newmap.put('Make_Code__c', vehicledetails[0].Make_Code__c==null ? '':string.valueOf(vehicledetails[0].Make_Code__c));
                newmap.put('Vehicle_SubType__c', vehicledetails[0].Vehicle_SubType__c==null ? '':string.valueOf(vehicledetails[0].Vehicle_SubType__c));        
            }else{
            newmap.put('Id',vehicledetails[0].Id== null ? '':string.valueof(vehicledetails[0].Id));
            newmap.put('Make__c',vehicledetails[0].Make__c== null ? '':string.valueof(vehicledetails[0].Make__c));
            newmap.put('Model__c',vehicledetails[0].Model__c== null ? '':string.valueof(vehicledetails[0].Model__c));
            newmap.put('Variant__c',vehicledetails[0].Variant__c== null ? '':string.valueof(vehicledetails[0].Variant__c));
            newmap.put('Basic_Price__c',app[0].Basic_Price__c== null ? '':string.valueof(app[0].Basic_Price__c));
            newmap.put('Base_Prices__c',vehicledetails[0].Base_Prices__c== null ? '':string.valueof(vehicledetails[0].Base_Prices__c));//CISP-2522
            newmap.put('Total_Funded_Premium__c',app[0].Total_Funded_Premium__c== null ? '':string.valueof(app[0].Total_Funded_Premium__c));//CISP-2522
            newmap.put('GST_Amount__c',app[0].GST_Amount__c== null ? '':string.valueof(app[0].GST_Amount__c));
            newmap.put('Discount_on_Basic_Price__c',string.valueof(app[0].Discount_on_Basic_Price__c));
            newmap.put('Ex_showroom_price__c',app[0].Ex_showroom_price__c== null ? '':string.valueof(app[0].Ex_showroom_price__c));
            newmap.put('Ex_showroom_price_carwale__c',app[0].Ex_showroom_price_carwale__c== null ? '':string.valueof(app[0].Ex_showroom_price_carwale__c));
            newmap.put('RTO_Road_Tax__c',app[0].RTO_Road_Tax__c== null ? '':string.valueof(app[0].RTO_Road_Tax__c));
            newmap.put('Other_charges__c', app[0].Other_charges__c== null ? '':string.valueof(app[0].Other_charges__c));
            newmap.put('X1st_yr_Insurance_Premium__c',app[0].X1st_yr_Insurance_Premium__c== null ? '':string.valueof(app[0].X1st_yr_Insurance_Premium__c));
            newmap.put('On_Road_price__c',app[0].On_Road_price__c== null ? '':string.valueof(app[0].On_Road_price__c));
            newmap.put('On_Road_price_carwale__c',app[0].On_Road_price_carwale__c== null ? '':string.valueof(app[0].On_Road_price_carwale__c));
            newmap.put('Funding_on_Ex_Showroom__c',app[0].Funding_on_Ex_Showroom__c== true ? 'True':string.valueof(app[0].Funding_on_Ex_Showroom__c));
            newmap.put('Funding_on_ORP__c',app[0].Funding_on_ORP__c== true ? 'True':string.valueof(app[0].Funding_on_ORP__c));
            newmap.put('Required_Loan_amount__c',Finalterm[0].Loan_Amount__c== null ? '':string.valueof(Integer.valueOf(Finalterm[0].Loan_Amount__c) + totalamount));          
            newmap.put('RTO_Road_Tax_New__c',app[0].RTO_Road_Tax_New__c== null ? '':string.valueof(app[0].RTO_Road_Tax_New__c));  
            newmap.put('GstPercentage__c', metadata.GstPercentage__c==null ? '':string.valueOf(metadata.GstPercentage__c));
            newmap.put('Product_Type__c',app[0].Product_Type__c== null ? '':string.valueof(app[0].Product_Type__c)); //CISP-4778
            newmap.put('Vehicle_Type__c',app[0].Vehicle_Type__c== null ? '':string.valueof(app[0].Vehicle_Type__c)); //CISP-4778
            newmap.put('Make_Code__c', vehicledetails[0].Make_Code__c==null ? '':string.valueOf(vehicledetails[0].Make_Code__c)); //CISP-4778
            newmap.put('Model_Code__c', vehicledetails[0].Model_Code__c==null ? '':string.valueOf(vehicledetails[0].Model_Code__c));//CISP-2952
            newmap.put('Dealer_Quoted_On_Road_Price__c', app[0].Dealer_Quoted_On_Road_Price__c==null ? '':string.valueOf(app[0].Dealer_Quoted_On_Road_Price__c));// D2C Change - Raman
            newmap.put('Performance_Upgrade__c', app[0].Performance_Upgrade__c==null ? '':string.valueOf(app[0].Performance_Upgrade__c));//OLA-140
            newmap.put('FAME_Subsidy__c', app[0].FAME_Subsidy__c==null ? '':string.valueOf(app[0].FAME_Subsidy__c));//OLA-140
          }
        } else{
            newmap.put('Make__c','');
            newmap.put('Model__c','');
            newmap.put('Variant__c','');
            newmap.put('Basic_Price__c','');
            newmap.put('Base_Prices__c','');//CISP-2522
            newmap.put('Total_Funded_Premium__c','');//CISP-2522
            newmap.put('GST_Amount__c','');
            newmap.put('Dealer_Disc_to_Customer__c','');
            newmap.put('Ex_showroom_price__c','' );
            newmap.put('Ex_showroom_price_carwale__c','');
            newmap.put('RTO_Road_Tax__c','');
            newmap.put('Other_charges__c', '');
            newmap.put('X1st_yr_Insurance_Premium__c','');
            newmap.put('On_Road_price__c','');
            newmap.put('On_Road_price_carwale__c','');
            newmap.put('Funding_on_Ex_Showroom__c','');
            newmap.put('Funding_on_ORP__c','');
            newmap.put('Required_Loan_amount__c','');
            newmap.put('RTO_Road_Tax_New__c','');
            newmap.put('GstPercentage__c', '');
            newmap.put('Model_Code__c','');//CISP-2952
            newmap.put('Dealer_Quoted_On_Road_Price__c', '');// D2C Change - Raman
            newmap.put('Make_Code__c','');//CISP-4778
            newmap.put('Vehicle_Type__c','');//CISP-4778
            newmap.put('Product_Type__c','');//CISP-4778
            newmap.put('Invoice_Price__c','');
            newmap.put('Vehicle_SubType__c','');
        }  
        if(app1.size() > 0){
            newmap.put('appId',app1[0].Id);
        }
        system.debug('newmap'+newmap);
        return newmap;
    }
    
    @AuraEnabled(Cacheable=true)
    public static Map<String,String> getRecordsVarientold(string opp){
        system.debug('opp'+opp);
        Opportunity[] app=[SELECT Id,Name,Make__c,Model__c,Variant__c,Basic_Price__c,GST_Amount__c,Dealer_Disc_to_Customer__c,Ex_showroom_price__c,Ex_showroom_price_carwale__c,RTO_Road_Tax__c,Other_charges__c,
                            X1st_yr_Insurance_Premium__c, On_Road_price__c,On_Road_price_carwale__c,Vehicle_Registration_Number__c,Vehicle_Sub_Category__c,
                            Vehicle_Type__c,Parent_Deal_number__c,Funding_on_Ex_Showroom__c,Required_Loan_amount__c From Opportunity where Id=:opp];
        Vehicle_Detail__c[] vehicledetails=[Select Id,Loan_Application__c,Make__c,Model__c,Variant__c,Base_Prices__c, Valuation_price__c,Insurance_declared_value__c,Grid_value__c,Selling_Price__c from Vehicle_Detail__c where Loan_Application__c=:opp];
    
        Map<String,String> newmap= new Map<String,String>();
        Map<String,String> newtmap= new Map<String,String>();
        system.debug('app'+app);
        if(app.size() > 0 && vehicledetails.size()>0){
            newmap.put('Vehicle_Registration_Number__c',app[0].Vehicle_Registration_Number__c== null ? '':app[0].Vehicle_Registration_Number__c);
            newmap.put('Vehicle_Type__c',app[0].Vehicle_Type__c== null ? '':app[0].Vehicle_Type__c);
            newmap.put('Vehicle_Sub_Category__c',app[0].Vehicle_Sub_Category__c== null ? '':app[0].Vehicle_Sub_Category__c);
            newmap.put('Parent_Deal_number__c',app[0].Parent_Deal_number__c== null ? '':app[0].Parent_Deal_number__c);
            newmap.put('Make__c',vehicledetails[0].Make__c== null ? '':vehicledetails[0].Make__c);
            newmap.put('Model__c',vehicledetails[0].Model__c== null ? '':vehicledetails[0].Model__c);
            newmap.put('Variant__c',vehicledetails[0].Variant__c== null ? '':vehicledetails[0].Variant__c);
            newmap.put('Valuation_price__c',vehicledetails[0].Valuation_price__c== null ? '':string.valueof(vehicledetails[0].Valuation_price__c));
            newmap.put('Insurance_declared_value__c',vehicledetails[0].Insurance_declared_value__c== null ? '':string.valueof(vehicledetails[0].Insurance_declared_value__c));
            newmap.put('Grid_value__c', vehicledetails[0].Grid_value__c== null ? '':string.valueof(vehicledetails[0].Grid_value__c));
            newmap.put('Selling_Price__c',vehicledetails[0].Selling_Price__c== null ? '':string.valueof(vehicledetails[0].Selling_Price__c));
            newmap.put('On_Road_price__c',app[0].On_Road_price__c== null ? '':string.valueof(app[0].On_Road_price__c));
        } else{
            newmap.put('Vehicle_Registration_Number__c','');
            newmap.put('Vehicle_Type__c','');
            newmap.put('Vehicle_Sub_Category__c','');
            newmap.put('Parent_Deal_number__c','');
            newmap.put('Make__c','');
            newmap.put('Model__c','');
            newmap.put('Variant__c','' );
            newmap.put('Valuation_price__c','');
            newmap.put('Insurance_declared_value__c','');
            newmap.put('Grid_value__c', '');
            newmap.put('Selling_Price__c','');
            newmap.put('On_Road_price__c','');
        }    
        system.debug('newmap'+newmap);
        return newmap;
    }

    /*SFTRAC-92 : Method to get Vehicle Details for Tractor : Used in LWC_incomedetailsVarient - Start*/
    @AuraEnabled(Cacheable=true)
    public static Map<String,String> getRecordsVarientForTractor(string opp, String vehicleRecordId){
        system.debug('opp>> getRecordsVarientForTractor'+opp);
        system.debug('vehicleRecordId>>getRecordsVarientForTractor'+vehicleRecordId) ;
        Opportunity[] app=[SELECT Id,Name,Make__c,Model__c,Variant__c,Basic_Price__c,GST_Amount__c,Dealer_Disc_to_Customer__c,Ex_showroom_price__c,Ex_showroom_price_carwale__c,RTO_Road_Tax__c,Other_charges__c,
                            X1st_yr_Insurance_Premium__c, On_Road_price__c,On_Road_price_carwale__c,Vehicle_Registration_Number__c,
                            Vehicle_Type__c,Parent_Deal_number__c,Funding_on_Ex_Showroom__c,Required_Loan_amount__c From Opportunity where Id=:opp];

        Vehicle_Detail__c[] vehicledetails=[Select Id,Loan_Application__c,Make__c,Model__c,Variant__c,Base_Prices__c, Valuation_price__c,Vehicle_SubCategory__c,Insurance_declared_value__c,Grid_value__c,Selling_Price__c,Basic_Price__c,GST_Amount__c,X1st_yr_Insurance_Premium__c, Invoice_Price__c, Loan_Amount__c,Vehicle_Registration_number__c,Parent_Deal_Number__c from Vehicle_Detail__c where Id=: vehicleRecordId];
    
        Map<String,String> newmap= new Map<String,String>();
        Map<String,String> newtmap= new Map<String,String>();
        system.debug('app'+app);
        if(app.size() > 0 && vehicledetails.size()>0){
            newmap.put('Vehicle_Registration_Number__c',vehicledetails[0].Vehicle_Registration_Number__c== null ? '':vehicledetails[0].Vehicle_Registration_Number__c);
            newmap.put('Vehicle_Type__c',app[0].Vehicle_Type__c== null ? '':app[0].Vehicle_Type__c);
            newmap.put('Vehicle_Sub_Category__c',vehicledetails[0].Vehicle_SubCategory__c== null ? '':vehicledetails[0].Vehicle_SubCategory__c);
            newmap.put('Parent_Deal_number__c',vehicledetails[0].Parent_Deal_number__c== null ? '':vehicledetails[0].Parent_Deal_number__c);
            newmap.put('Make__c',vehicledetails[0].Make__c== null ? '':vehicledetails[0].Make__c);
            newmap.put('Model__c',vehicledetails[0].Model__c== null ? '':vehicledetails[0].Model__c);
            newmap.put('Variant__c',vehicledetails[0].Variant__c== null ? '':vehicledetails[0].Variant__c);
            newmap.put('Valuation_price__c',vehicledetails[0].Valuation_Price__c== null ? '':string.valueof(vehicledetails[0].Valuation_price__c));
            newmap.put('Insurance_declared_value__c',vehicledetails[0].Insurance_declared_value__c== null ? '':string.valueof(vehicledetails[0].Insurance_declared_value__c));
            newmap.put('Grid_value__c', vehicledetails[0].Grid_value__c== null ? '':string.valueof(vehicledetails[0].Grid_value__c));
            newmap.put('Selling_Price__c',vehicledetails[0].Selling_Price__c== null ? '':string.valueof(vehicledetails[0].Selling_Price__c));
        } else{
            newmap.put('Vehicle_Registration_Number__c','');
            newmap.put('Vehicle_Type__c','');
            newmap.put('Vehicle_Sub_Category__c','');
            newmap.put('Parent_Deal_number__c','');
            newmap.put('Make__c','');
            newmap.put('Model__c','');
            newmap.put('Variant__c','' );
            newmap.put('Valuation_price__c','');
            newmap.put('Insurance_declared_value__c','');
            newmap.put('Grid_value__c', '');
            newmap.put('Selling_Price__c','');
        }    
        system.debug('newmap'+newmap);
        return newmap;
    }
    /*SFTRAC-92 : Method to get Vehicle Details for Tractor : Used in LWC_incomedetailsVarient- End*/

    /*SFTRAC-92 : Method to get Vehicle detail ids for Tractor : Used in Lwc_incomedetailsborrower - Start*/
    @AuraEnabled(Cacheable=true)
    public static List<Id> getVehicleDetailRecordIdsTF(string opp){
        system.debug('opp>>> '+opp);
        List<Id> vehicleIds = new List<Id>();
        if(opp != null){
            for(Vehicle_Detail__c vehicle : [SELECT Id FROM Vehicle_Detail__c WHERE Loan_Application__c =:opp ORDER BY CreatedDate ASC]){
                vehicleIds.add(vehicle.Id);
            }
        }
        return vehicleIds;
    }
    /*SFTRAC-92 : Method to get Vehicle detail ids for Tractor : Used in Lwc_incomedetailsborrower - End*/
    
    @AuraEnabled(Cacheable=true)
    public static Map<String,String> getRecordsLoanoffer(string opp){
        system.debug('opp'+opp);
        Opportunity[] app=[SELECT Id,Name,Make__c,Model__c,Variant__c,Loan_amount__c,Required_Tenure__c,CRM_IRR__c,Requested_CRM_IRR__c,EMI_Amount__c,Basic_Price__c,GST_Amount__c,Dealer_Disc_to_Customer__c,Ex_showroom_price__c,Ex_showroom_price_carwale__c,RTO_Road_Tax__c,Other_charges__c,
                            X1st_yr_Insurance_Premium__c, On_Road_price__c,On_Road_price_carwale__c,Vehicle_Registration_Number__c,Vehicle_Sub_Category__c,
                            Vehicle_Type__c,Parent_Deal_number__c,Valuation_price__c,Insurance_declared_value__c,Grid_value__c,Selling_Price__c,Funding_on_Ex_Showroom__c,Required_Loan_amount__c From Opportunity where Id=:opp];
        Map<String,String> newmap= new Map<String,String>();
        Map<String,String> newtmap= new Map<String,String>();
        system.debug('app'+app);
        if(app.size() > 0){
            newmap.put('Loan_amount__c',app[0].Loan_amount__c== null ? '':app[0].Loan_amount__c);
            newmap.put('Required_Tenure__c',String.valueof(app[0].Required_Tenure__c)== null ? '':String.valueof(app[0].Required_Tenure__c));
            newmap.put('CRM_IRR__c',String.valueof(app[0].CRM_IRR__c)== null ? '':String.valueof(app[0].CRM_IRR__c));
            newmap.put('Requested_CRM_IRR__c',app[0].Requested_CRM_IRR__c== null ? '':app[0].Requested_CRM_IRR__c);
            newmap.put('EMI_Amount__c',String.valueof(app[0].EMI_Amount__c)== null ? '':String.valueof(app[0].EMI_Amount__c));
        } else{
            newmap.put('Loan_amount__c','');
            newmap.put('Required_Tenure__c','');
            newmap.put('CRM_IRR__c','');
            newmap.put('Requested_CRM_IRR__c','');
            newmap.put('EMI_Amount__c','');
        }    
        system.debug('newmap'+newmap);
        return newmap;
    }
    
    
    // @Param:      String 
    // @Return:     String 
    @AuraEnabled(Cacheable=true)
    public static String loadOfferScreenData(String loanApplicationId){
        system.debug('loanid'+loanApplicationId);
        Final_Term__c finaltemrsObj = [SELECT id,CRM_IRR__c,Tenure__c,Loan_Amount__c,
                                        Loan_Application__c,Required_CRM_IRR__c,
                                        OfferengineMaxLoanAmount__c,
                                        OfferengineMinLoanAmount__c,
                                        OfferengineMaxTenure__c,
                                        OfferengineMinTenure__c,
                                        Advance_EMI__c,
                                        Holiday_period__c,
                                        EMI_Amount__c
                                        FROM Final_Term__c 
                                        WHERE Loan_Application__c=:loanApplicationId 
                                        LIMIT 1];
        
        loadOfferScreenDataWrapper ldscDataWrpObj = new loadOfferScreenDataWrapper();
        ldscDataWrpObj.crmIRR =finaltemrsObj.CRM_IRR__c;
        ldscDataWrpObj.requriedCRMIRR =finaltemrsObj.Required_CRM_IRR__c;
        ldscDataWrpObj.loanAmount= finaltemrsObj.Loan_Amount__c;
        ldscDataWrpObj.tenure =finaltemrsObj.Tenure__c;
        ldscDataWrpObj.emi = finaltemrsObj.EMI_Amount__c;
        ldscDataWrpObj.getrecordId = finaltemrsObj.Id;
        
        ldscDataWrpObj.minTenureSlider = finaltemrsObj.OfferengineMinTenure__c;
        ldscDataWrpObj.maxTenureSlider = finaltemrsObj.OfferengineMaxTenure__c;
        ldscDataWrpObj.maxLoanAmtSlider = finaltemrsObj.OfferengineMaxLoanAmount__c;
        ldscDataWrpObj.minLoanAmtSlider = finaltemrsObj.OfferengineMinLoanAmount__c;
        ldscDataWrpObj.advanceEmi = finaltemrsObj.Advance_EMI__c;
        ldscDataWrpObj.monitoriumDays = finaltemrsObj.Holiday_period__c;
        return JSON.serialize(ldscDataWrpObj);
    }
    
    // @Method:      validateTenureChange
    // @Created by:  Anji
    // @Description: Validate Tenure based on the year/month of Manufacturer
    // @Param:       tenure, vehicleSubCategory
    // @Return:      Boolean
    @AuraEnabled
    public static Boolean validateTenureChange(Integer tenure, String loanappID ){
        String vehicleSubCategory;
        String prdType;
        
        for(Opportunity oppObj :[SELECT Product_Type__c,Vehicle_Sub_Category__c  FROM opportunity 
                                    WHERE id =:loanappID
                                    WITH SECURITY_ENFORCED]){
                                        vehicleSubCategory = oppObj.Vehicle_Sub_Category__c;
                                        prdType = oppObj.Product_Type__c;
                                    }
        
        Boolean isValid;
        for(Asset assertObj:[SELECT Id,Vehicle_sub_category__c,Manufacturer_Month__c,Manufacturer_Year__c 
                                FROM Asset
                                WHERE Vehicle_sub_category__c = :vehicleSubCategory
                                WITH SECURITY_ENFORCED])
        {
            
            Integer  calYear = system.today().year() - Integer.valueof(assertObj.Manufacturer_Year__c);
            Integer calMnth = calYear*12;
            Integer ageOfvehicle = tenure+Integer.valueof(calMnth+assertObj.Manufacturer_Month__c);
            Integer convertyeartoMnt15 = 12*15; // convert year to months // CISP-4102 - changed 12 years to 15 years
            Integer convertYeartoMnt5 = 12*5; // convert year to months 
            
            //For PV, Required Tenure + Age of vehicle 
            //(calculated at backend basis Manufacturer Month/Year captured in Asset Details) < 12 years
            if( prdType =='Passenger Vehicles' && ageOfvehicle < convertyeartoMnt15 ){
                isValid = true;
                return isValid;
            }
            /*For 2W, Required Tenure + Age of vehicle 
    (calculated at backend basis Manufacturer Month/Year captured in Asset Details) < 5 years*/
            else if ( prdType == 'Two Wheeler' && ageOfvehicle < convertYeartoMnt5 ){
                isValid = true;
                return isValid;
            }
            else{
                isValid = false;
                return isValid;
            }
        }                     
        //validate if loadn amount is valid
        return false;
    }
    // @Method:      checkEligibleLoanAmt
    // @Created by:  Anji
    // @Description: 
    // @Param:       
    // @Return:      Boolean
    @AuraEnabled
    public static Vehicle_Detail__c getVechicleDetails(String loanApplicationId){
        Vehicle_Detail__c vechDetail;
        for(Vehicle_Detail__c vechDetailObj:[SELECT Eligible_Tenure__c,
                                                Loan_Application__r.Vehicle_Sub_Category__c,
                                                Loan_Application__r.Product_Type__c,Eligible_Loan_Amount__c 
                                                FROM Vehicle_Detail__c 
                                                WHERE Loan_Application__c=:loanApplicationId 
                                                WITH SECURITY_ENFORCED])
        {
            vechDetail = vechDetailObj;
        }
        return vechDetail;
    }
    
    @AuraEnabled
    public static Boolean checkEligibleLoanAmt(String loanappId, String loanAmt){
        Boolean iseligibleloanBln = true;
        Decimal loanAmtcurr = Decimal.valueof(loanAmt);
        for(Vehicle_Detail__c vechDetailObj:[SELECT Eligible_Tenure__c,
                                                Loan_Application__r.Vehicle_Sub_Category__c,
                                                Loan_Application__r.Product_Type__c,Eligible_Loan_Amount__c 
                                                FROM Vehicle_Detail__c 
                                                WHERE Loan_Application__c=:loanappId 
                                                WITH SECURITY_ENFORCED])
        {
            String getvechSubCat = vechDetailObj.Loan_Application__r.Vehicle_Sub_Category__c;
            String getprodcutType = vechDetailObj.Loan_Application__r.Product_Type__c;
            
            if(getvechSubCat == 'UIM' && getprodcutType == 'Passenger Vehicles' 
                && loanAmtcurr <= vechDetailObj.Eligible_Loan_Amount__c ){
                    iseligibleloanBln = false;
                    return iseligibleloanBln;
                }
            else if(getvechSubCat == 'UIM' && getprodcutType == 'Two Wheeler' 
                    && loanAmtcurr <= vechDetailObj.Eligible_Loan_Amount__c ){
                        iseligibleloanBln = false;
                        return iseligibleloanBln;
                    }
        }
        return iseligibleloanBln;
    }
    
    @AuraEnabled
    public static Boolean checkEligibleLoantenure(Integer tenure, String loanappId){
        Boolean iseliTenubln = true;
        for(Vehicle_Detail__c vechDetailObj:[SELECT Eligible_Tenure__c,
                                                Loan_Application__r.Vehicle_Sub_Category__c,
                                                Loan_Application__r.Product_Type__c,
                                                Eligible_Loan_Amount__c 
                                                FROM Vehicle_Detail__c 
                                                WHERE Loan_Application__c=:loanappId 
                                                WITH SECURITY_ENFORCED])
        {
            String getvechSubCat = vechDetailObj.Loan_Application__r.Vehicle_Sub_Category__c;
            String getprodcutType = vechDetailObj.Loan_Application__r.Product_Type__c;
            
            if( getvechSubCat == 'UIM' && getprodcutType == 'Passenger Vehicles' 
                && tenure <= vechDetailObj.Eligible_Tenure__c  ){
                    iseliTenubln = false;
                    return iseliTenubln;
                }
            else if(getvechSubCat == 'UIM' && getprodcutType == 'Two Wheeler' 
                    && tenure <= vechDetailObj.Eligible_Tenure__c ){
                        iseliTenubln = false;
                        return iseliTenubln;
                    }
        }
        return iseliTenubln;
    }  
    
    @AuraEnabled
    public static void saveOfferDetails(String loadjsonStr){
        loadOfferScreenDataWrapper loadofferScreenObj = (loadOfferScreenDataWrapper) JSON.deserialize(loadjsonStr, loadOfferScreenDataWrapper.class);
        
        List<Final_Term__c> finalTermsLstObj = new List<Final_Term__c>();
        for(Final_Term__c finalObj: [SELECT id,CRM_IRR__c,Tenure__c,Loan_Amount__c,Required_CRM_IRR__c,
                                        EMI_Amount__c
                                        FROM Final_Term__c 
                                        WHERE id=:loadofferScreenObj.getrecordId] )
        {
            finalObj.Required_CRM_IRR__c = loadofferScreenObj.requriedCRMIRR;
            finalObj.Tenure__c = loadofferScreenObj.tenure;
            finalObj.Loan_Amount__c = loadofferScreenObj.loanAmount;
            finalTermsLstObj.add(finalObj);
        }
        if( finalTermsLstObj.size() > 0 &&  Schema.sObjectType.Final_Term__c.isUpdateable()){
            update finalTermsLstObj;
        }
    }
    
    public class loadOfferScreenDataWrapper{
        @AuraEnabled public String getrecordId; 
        @AuraEnabled public Decimal crmIRR;
        @AuraEnabled public String requriedCRMIRR;
        @AuraEnabled public String netPayIns;
        @AuraEnabled public String netPayOut;
        @AuraEnabled public String grossIRROffered;
        @AuraEnabled public String netIRROffered;
        @AuraEnabled public String stopJourneyFlag;
        @AuraEnabled public string loanAmount;
        @AuraEnabled public String tenure;
        @AuraEnabled public Decimal emi;
        @AuraEnabled public Decimal maxTenureSlider;
        @AuraEnabled public Decimal minTenureSlider;
        @AuraEnabled public Decimal minLoanAmtSlider;
        @AuraEnabled public Decimal maxLoanAmtSlider;
        @AuraEnabled public Boolean advanceEmi;
        @AuraEnabled public String monitoriumDays;
        
    }
    
    
    /*
    * @Method:      getOfferScreenData
    * @Created by:  Raj Gupta
    * @Description: This method fetch data from previous modules.
    * @Param:       String - loan Applicantion ID
    * @Return:      data
    */
    @AuraEnabled
    public static String getOfferScreenData(String loanApplicationId) {
        try
        {
            //Null Check 
            if(loanApplicationId != null){
                ResponseWrapper responseJSON = new ResponseWrapper();
                Opportunity opp=[select id,	Required_Loan_amount__c,Required_Tenure__c, LeadSource from Opportunity where Id=: loanApplicationId WITH SECURITY_ENFORCED];//D2C Changes Swapnil - Added LeadSource
                responseJSON.tenure = opp.Required_Tenure__c;
                responseJSON.loanAmount = opp.Required_Loan_amount__c;
                String serializedResonponse = JSON.serialize(responseJSON);
                return serializedResonponse;   
            }
            return null;
        }
        catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_OfferScreenController', 'getOfferScreenData', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
            
        }
    }
    
    
    //Wrapper Class 
    public class ResponseWrapper {
        decimal tenure {get;set;} 
        Decimal loanAmount {get;set;}
        //constructor
        responseWrapper() {            
            this.tenure = 0;
            this.loanAmount = 0;
        }
    }
    
    
    
    @AuraEnabled
    public static void submitborrowerecords(String opp,String app,string abb){
        
        system.debug('@@##'+opp+'@@##'+app);
        List<Income_Details__c> updateapp= new List<Income_Details__c>();
        Income_Details__c[] details=[SELECT Id,Name,ABB_to_be_considered__c,applicant__c From Income_Details__c where applicant__c=:app]; 
        for(Income_Details__c i:details){
            i.ABB_to_be_considered__c= abb;
            updateapp.add(i);
        }
        update updateapp; 
    }   
    
    
    @AuraEnabled
    public static void Submithandleritr(String application,String income,boolean sal, boolean itr,boolean gst){
        set<Id> newt=new set<Id>();
        system.debug('@@##'+application+'@@##'+income);
        List<Applicant__c> updateapp= new List<Applicant__c>();
        Applicant__c[] app=[SELECT Id,Name,Income_Ca__c,Profile__c,Opportunity__c,Applicant_Type__c,Income_Details_Count__c,Remarks__c From Applicant__c where Opportunity__c =: application];
        for(Applicant__c a: app){
            newt.add(a.id);
        }
        List<Income_details__c> ic= new List<Income_details__c>();
        system.debug('@@##'+app);
        if(sal){
            ic=[SELECT Id,Name,Applicant__c,Is_Salaried__c,Remarks__c From Income_details__c where Applicant__c =: newt and Is_Salaried__c=:sal];
        }
        else if(itr){
            ic=[SELECT Id,Name,Applicant__c,Remarks__c,Do_You_File_ITR__c From Income_details__c where Applicant__c =: newt and Do_You_File_ITR__c=:itr and Is_Salaried__c=:sal];
        }
        else if(gst){
            ic=[SELECT Id,Name,Applicant__c,Remarks__c,Do_You_File_GST__c From Income_details__c where Applicant__c =: newt and Do_You_File_GST__c=:gst and Is_Salaried__c=:gst];
        }else{
            ic=[SELECT Id,Name,Applicant__c,Remarks__c,Do_You_File_GST__c From Income_details__c where Applicant__c =: newt];
        }
        for(Income_details__c i:ic){
            i.Remarks__c= income;
        }
        update ic; 
    }   
    
        @AuraEnabled
        public static Id retriveFiles(String incomeObjId){
            if(incomeObjId != null){
                system.debug('ret'+incomeObjId);    
                Income_Details__c[] contentDocumentList=[SELECT Id,Capture_Income_Method__c FROM Income_Details__c where Id=:incomeObjId  Limit 1];
                if(!contentDocumentList.isEmpty()){
                    ContentDocumentLink[] files = [SELECT Id,ContentDocumentId,ContentDocument.Title, ContentDocument.CreatedDate,LinkedEntityId
                    FROM ContentDocumentLink where LinkedEntityId =:contentDocumentList[0].Id];
    
                 if(!files.isEmpty()){
                     return files[0].ContentDocumentId;
                    }else{
                          return null;
                    }
                }else{
                    return null;
                }
            }else{
                return null;
            } 
        }
    
    @AuraEnabled(cacheable=true)
    public static Id retriveFilesitr(String applicationId,string app){
        system.debug('ret'+applicationId);
        Income_Details__c contentDocumentList=[SELECT Id,Capture_ITR_Method__c FROM Income_Details__c where Applicant__c=:app And Capture_ITR_Method__c!='' Limit 1];
    
        ContentDocumentLink[] files = [SELECT Id,ContentDocumentId,ContentDocument.Title, ContentDocument.CreatedDate,LinkedEntityId
                                        FROM ContentDocumentLink where LinkedEntityId =:contentDocumentList.Id];
        if(files.size()>0){
        return files[0].ContentDocumentId;
        }else{
            return null;
        }
        
    }
    
    @AuraEnabled(cacheable=true)
    public static Id retriveFilesgst(String applicationId,string app){
        system.debug('ret'+applicationId);
        Income_Details__c contentDocumentList=[SELECT Id,Capture_GST_Method__c FROM Income_Details__c where Applicant__c=:app And Capture_GST_Method__c!='' Limit 1];
    
        ContentDocumentLink[] files = [SELECT Id,ContentDocumentId,ContentDocument.Title, ContentDocument.CreatedDate,LinkedEntityId
                                        FROM ContentDocumentLink where LinkedEntityId =:contentDocumentList.Id];
        if(files.size()>0){
        return files[0].ContentDocumentId;
        }else{
            return null;
        }
        
    }
    
    
    }