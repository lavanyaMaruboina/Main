/**
* @author: Raj Gupta.
* @company: Persistent Systems
* @description:A BackToLoanAppLWCTest test class is use test BackToLoanApp
* History:
* 29/10/2012  Added by Raj for Initial . 
*/
@isTest
public class BackToLoanAppLWCTest { 

    @isTest
    public static void backToLoanAppTestAadhaar()
    {
         Test.startTest();
        string aadhaar = BackToLoanAppLWC.getMetadata('Aadhaar');
        System.assertEquals('KYC name;Aadhaar Enrollment Number;KYC DOB;KYC Address Line 1;Gender;KYC No.',aadhaar);   
       Test.stopTest();
       }

    @isTest
    public static void backToLoanAppTestVoterId()
    {
        Test.startTest();
        string voterId = BackToLoanAppLWC.getMetadata('Voter Id');
        System.assertEquals('KYC name;KYC NO.;KYC Address Line 1;Gender;KYC DOB;Age',voterId); 
    }
    @isTest
    public static void backToLoanAppTestdrivingLicence()
    {   Test.startTest();
        string drivingLicence = BackToLoanAppLWC.getMetadata('Driving Licence');
        System.assertEquals('KYC name;KYC NO.;KYC DOB;KYC Address Line 1',drivingLicence);
    }
    
    @isTest
    public static void backToLoanAppTestPassport()
    {    Test.startTest();
         string passport = BackToLoanAppLWC.getMetadata('Passport');
        System.assertEquals('Passport File No;First Name;Middle Name;Last Name;KYC DOB;Passport No;KYC Address Line 1',passport);
    }
     @isTest
    public static void backToLoanAppTestPan()
    {    Test.startTest();
         string pan = BackToLoanAppLWC.getMetadata('PAN');
        System.assertEquals('PAN No.;KYC name;KYC DOB',pan);  
    }
    
}