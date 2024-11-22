public class CASAbankFormTriggerhandler
{
     public static void generateUniqueFormNumber(List<CASA_Bank_Form__c> newList){
            list<CASA_Bank_Form__c> lstCASAbank = new list<CASA_Bank_Form__c>();

            lstCASAbank = [select id,Saving_Account_opening_form_No__c from CASA_Bank_Form__c 
                            where Saving_Account_opening_form_No__c != '' order by Saving_Account_opening_form_No__c desc limit 1];
            
            Decimal uniqueNo = Decimal.valueof('3500000016');
            if(lstCASAbank.size() > 0){
                uniqueNo = Decimal.valueof(lstCASAbank[0].Saving_Account_opening_form_No__c);
            }

            for(CASA_Bank_Form__c item : newList){
                  uniqueNo++;
                item.Saving_Account_opening_form_No__c = string.valueof(uniqueNo);
              
            }
        
        }
}