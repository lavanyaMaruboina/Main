/**
 * @Class: LoanApplicationDataManagerTest
 * @Description: Test class for LoanApplicationDataManager
 * @author: Prashanth Kumar
 * */
@isTest
public class LoanApplicationDataManagerTest {
    
    @testSetup
    static void createTestData(){
        System_Configuration__c setting = new System_Configuration__c();
        setting.Name = 'System Configuration';
        setting.Application_Sequence_No__c = 00123;
        setting.Application_Date__c = Date.today();
        insert setting;
    }
    
	@isTest
    static void testCreateLoanApplication(){
        LoanApplicationDataManager.LoanApplication applicationWrapper = new LoanApplicationDataManager.LoanApplication();
        applicationWrapper.FirstName = 'firstname';
        applicationWrapper.LastName = 'lastname';
        applicationWrapper.Salutation = 'Mr.';
        applicationWrapper.MobileNumber = '9934567890';
        applicationWrapper.PANNumber = 'FGJKK0789G';
        applicationWrapper.EmailID = 'test@gmail.com';
        applicationWrapper.VehicleType = 'New';
        applicationWrapper.LeadSource = 'D2C';
        applicationWrapper.ProductType = 'Two wheeler';
        applicationWrapper.EmailIdStatus = 'valid';
        applicationWrapper.KYCNameAsPerPAN = 'firstname lastname';
        applicationWrapper.DedupeResponse = '{"JData":"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"}';
            
        //encrypt the request
        String encryptedRequest = IntegrationUtilities.getEncryptedRequest(JSON.serialize(applicationWrapper), System.Label.privateKey, System.Label.ivkey);
        String jdataRequest = '"JData":';                    
        String body='{'+jdataRequest + '"'+encryptedRequest+'"'+'}';
        
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/createLoanApplication/';
        request.httpMethod = 'POST';
        request.requestBody = blob.valueof(body);
        RestContext.request = request;
        RestResponse res = new RestResponse();
        RestContext.response= res;
        system.debug('res-->'+res);
        LoanApplicationDataManager.createLoanApplication();
        
    }
    
    @isTest
    static void testCreateLoanApplication1(){
        LoanApplicationDataManager.LoanApplication applicationWrapper = new LoanApplicationDataManager.LoanApplication();
        applicationWrapper.FirstName = 'firstname';
        applicationWrapper.LastName = 'lastname';
        applicationWrapper.Salutation = 'Mr.';
        applicationWrapper.MobileNumber = '9934567890';
        applicationWrapper.PANNumber = 'FGJKK0789G';
        applicationWrapper.EmailID = 'test@gmail.com';
        applicationWrapper.VehicleType = 'New';
        applicationWrapper.LeadSource = 'Droom';
        applicationWrapper.ProductType = 'Two wheeler';
        applicationWrapper.EmailIdStatus = 'valid';
        applicationWrapper.KYCNameAsPerPAN = 'firstname lastname';
        applicationWrapper.DedupeResponse = '{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5njlGHaPks5on6K8REtrd9S1O01ZQ/UWbR626e2qytqsuzqfk0T96e/l4s6P45JmDpqBcGDZr/bn2ttLFnSE4QmUDLa29FhaaLcM25a7mxttHwahVwoK+pq3Bfewou8cODzvlmrQKVbr3j5fuzbQMbbHUCNfZkzL3jihy9JoVqgmrd0+xlYoFy0ymov1veucaJ4bgriSl8SgqzvnucXHlVE82z2o/TXRcwqTgD7Grz2T6cVQzszhzTTdhEvKqvv6cCBZRw5Huc3ez6sPcOyVVm//jk4a1r7jrbQhoOZvWxiQ6MuORzVAeKvNOVm4wagkL2YvIomDvRYnz+yJbYjPFLaE/nyyDgl/AtaAIgMAKObCJKijMLIupeV4q/Yc/GW/dEWfHK63yIyOSUMGJvOoI51uaegKMx1HoDhN/pyd2kqEVQ1BG4b99uUSSM8f7vJUq1pM2UcooQ8THk3U1KF9XBkb4SXa8OqRnDf9RBEuoSUxgUZ9dXcI3QWdGtZCCGiUzCkcruuWV3H7pDqGtt4b3p/eksuS1F2zumsvVdIOwjQ0qXSzwPx9FJSjCzxz6YRxy59lmZ6U7qnt3l4D4tELmltk5syMCXR6QDaUiQ0kysXyhNoZJZMsRPU5jjr/Jtpxo3FMRoWWteF3T7XO7LTRq8C7sLatKgyPqH3VMcZq6Csbbwdx9f41gF6RZDWXjhf7hrRf7C3SHKYEUxtLbWARMqdPQ1ZT6iDUGh8dZgXXTRMatgaZjqRY6HEPGlvcQYWrJuDtDcYIQsUPn9lvP8T7yDQGRrMJAmKKmiJF1iHSTVsIhv9h+zBkot2HGRRMcAohsg9pTnOkjuoUispNFNr17gT5iNQToWd4rXdqnMS/OP85EQ=="}';
        //applicationWrapper.pincode = '500001';
        
        //encrypt the request
        String encryptedRequest = IntegrationUtilities.getEncryptedRequest(JSON.serialize(applicationWrapper), System.Label.privateKey, System.Label.ivkey);
        String jdataRequest = '"JData":';                    
        String body='{'+jdataRequest + '"'+encryptedRequest+'"'+'}';

        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/createLoanApplication/';
        request.httpMethod = 'POST';
        system.debug('Before request.requestBody -->'+blob.valueof(Json.serialize(applicationWrapper)));
        request.requestBody = blob.valueof(body);
        RestContext.request = request;
        RestResponse res = new RestResponse();
        RestContext.response= res;
        system.debug('res-->'+res);
        LoanApplicationDataManager.createLoanApplication();
    }
    
   	@isTest
    static void testCreateLoanApplication2(){
        LoanApplicationDataManager.LoanApplication applicationWrapper = new LoanApplicationDataManager.LoanApplication();
        applicationWrapper.FirstName = 'firstname';
        applicationWrapper.LastName = 'lastname';
        applicationWrapper.Salutation = 'Mr.';
        applicationWrapper.MobileNumber = '9934567890';
        applicationWrapper.PANNumber = 'FGJKK0789G';
        applicationWrapper.EmailID = 'test@gmail.com';
        applicationWrapper.VehicleType = 'New';
        applicationWrapper.LeadSource = 'D2C';
        applicationWrapper.ProductType = 'Two wheeler';
        applicationWrapper.EmailIdStatus = 'valid';
        applicationWrapper.KYCNameAsPerPAN = 'firstname lastname';
        applicationWrapper.DedupeResponse = '{"JData":"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"}';
        
        //encrypt the request
        String encryptedRequest = IntegrationUtilities.getEncryptedRequest(JSON.serialize(applicationWrapper), System.Label.privateKey, System.Label.ivkey);
        String jdataRequest = '"JData":';                    
        String body='{'+jdataRequest + '"'+encryptedRequest+'"'+'}';

        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/createLoanApplication/';
        request.httpMethod = 'POST';
        system.debug('Before request.requestBody -->'+blob.valueof(Json.serialize(applicationWrapper)));
        request.requestBody = blob.valueof(body);
        RestContext.request = request;
        RestResponse res = new RestResponse();
        RestContext.response= res;
        system.debug('res-->'+res);
        LoanApplicationDataManager.createLoanApplication();
    }
    @isTest
    static void testCreateLoanApplication3(){
        LoanApplicationDataManager.LoanApplication applicationWrapper = new LoanApplicationDataManager.LoanApplication();
        applicationWrapper.FirstName = 'firstname';
        applicationWrapper.LastName = 'lastname';
        applicationWrapper.Salutation = 'Mr.';
        applicationWrapper.MobileNumber = '9934567890';
        applicationWrapper.PANNumber = 'FGJKK0789G';
        applicationWrapper.EmailID = 'test@gmail.com';
        applicationWrapper.VehicleType = 'New';
        applicationWrapper.LeadSource = 'D2C';
        applicationWrapper.ProductType = 'Two wheeler';
        applicationWrapper.EmailIdStatus = 'valid';
        applicationWrapper.KYCNameAsPerPAN = 'firstname lastname';
        applicationWrapper.DedupeResponse = null;
            
        //encrypt the request
        String encryptedRequest = IntegrationUtilities.getEncryptedRequest(JSON.serialize(applicationWrapper), System.Label.privateKey, System.Label.ivkey);
        String jdataRequest = '"JData":';                    
        String body='{'+jdataRequest + '"'+encryptedRequest+'"'+'}';

        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/createLoanApplication/';
        request.httpMethod = 'POST';
        request.requestBody = blob.valueof(body);
        RestContext.request = request;
        RestResponse res = new RestResponse();
        RestContext.response= res;
        system.debug('res-->'+res);
        LoanApplicationDataManager.createLoanApplication();
    }
    @isTest
    static void testCreateLoanApplication4(){
        LoanApplicationDataManager.LoanApplication applicationWrapper = new LoanApplicationDataManager.LoanApplication();
        applicationWrapper.FirstName = 'firstname';
        applicationWrapper.LastName = 'lastname';
        applicationWrapper.Salutation = 'Mr.';
        applicationWrapper.MobileNumber = '9934567890';
        applicationWrapper.PANNumber = 'FGJKK0789G';
        applicationWrapper.EmailID = 'test@gmail.com';
        applicationWrapper.VehicleType = 'New';
        applicationWrapper.LeadSource = 'D2C';
        applicationWrapper.ProductType = 'Two wheeler';
        applicationWrapper.EmailIdStatus = 'valid';
        applicationWrapper.KYCNameAsPerPAN = 'firstname lastname';
        applicationWrapper.DedupeResponse = '{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5njlGHaPks5on6K8REtrd9S1O01ZQ/UWbR626e2qytqsuzqfk0T96e/l4s6P45JmDpqBcGDZr/bn2ttLFnSE4QmUDLa29FhaaLcM25a7mxttHyAm/+xMkNBEqLS60gMb11et9K5MAh4ePjypg2OuUw5ulMS81o9y7yHTOjeo9M5MpEVGtROI87/AtAaOwdGDfTfZGIxfw3eZc6Oq/zXUTOm9Y705XsERp9lqSXjt0cwd2e9Y03HYg8QoO0Q0R647ZfFkl5OsZvcN2sq/bQkkkt6ZLigDbriOYTuO/20KAmNMhc6sXPAotPCslEBlxT1m1tigwtm7YvgDqaQCY5/Q4iXrHGZ935tsFiR8GYBQ0PNUShaNAThlT00DK0bp4PWeeUzDvnXuoumh0OMgEeSFDft/Q8A0rp5vIJt/+AuzOcTahj/Hf72YSdS/PAC6b+k++a9/j46Cx1JEEidCAnu1cvy8Le5Oz3Q4SWGbx5lkvYgdSD7mR4s6JldwZS49RcYiiyy0nX+N5e0WX+9j8Gr9qEhygw8vc8lc2jLRHqIq7hBiv9WITa/F5pl/rqOTabKHJEfY4+sZD8KF1/j5zVZr44dtvn431MnF8A15jsWdiKWAi/8faotQgdPcEnCXob3cxTcxfgRWACB9z+fiQ3bmGEW2Y1sCEpEBA3RDwjOfCN5w+Vz8hIZibZiz6oB41bJGDHxA54e9Spl4hQCqnfiy+PURJqFDwUf6bQHASHru0KxSCnrajA5CMOwGAcSv5/H00YEPktmJHAMDxRLOEhryZK4uzf6LPmL1H7G76q6NFTFlN+N0KcYmkqHRHxhULuUSX0zekmyHGDDPRHHAryfn9Hp7xW4CmNkS3/49yQ39WW2XkQbl7aZwchLMe4I5aJeFvB0DZ8Ii8tvF/35Hn5KHRHIx6A7Rn/rQkFo66kG+/WdEWbCtjSpe/LASDgyTET/YNfToBfpvgR4FEAH6fGbv5KairQncsYPVpz5ThgyiynaSSIsZKQ6AQ3ODhDpQPUVacUGoMJrkzL9DjJNb9Dxjv26ATAePgxlmw6rJKvQGR6VhHYtytMAiMAPF7gNNBUQr944ZwE0o1K4yCREF/j8Xjwddv41BgqfYEZ3tsr3oUtqihCkJV+qlbCWranEDXYcgA/kxDdvIrSqjDWMJfNTVmZNuj8alzjdDnDsAbZmLkiy80DoR0MzswZtzCpNDE/KXEFvHfIaOkaxF8TpfRh1u9B/R3jzcvoLCcHAjewlBudn1uN8ZD5jNLxl7gQ65Tm/AOFSU6YOke+y564tLyvMxb9lSGuLVQ901e3VtUjSkqFSatlfcdViT/LZ31A+9hPw1ekmlTGOy/vPkby4aZqMsepmkqG05EstQhy9fMjQlLPVh92N7CoCQXfBIvjFqYAgLtaX8EicSc4xyiXvdWBRMhjPj3MZqdPS0LYDtZRlJyDMZvwFqZK9els99RKmKF7ScYbxaCDI4mtcn9QVTlcApCL74N7T5hXui8tGYc/jpsCpBqxu12oEhw+PTZfKpvKnT6TS+X7NSPbZuz7jthTGQYIrBcv/QToya+w4Bq57DtlpWYYp+nHPLPaEM+7N0uaHUYrMixEawFiikdz8ywdCHXiKk+LzSSad6zoIjquB7SDZdFRXudTskNf14htvrFlp7ToKdvyK1b5C7ea0IR6BuKpjEw9Gk9fJEebsXoVdzsMhqKVke02NOTmRDWNxovx6lmSOlcdvbXemi6NQh1pKv+MahXcSgVcvreodVE024ZtsZsDmICmSAKPwlwrefszcRLwvYtnDuGT95JwoovptN4l2voGSw64qnVq76GM4APSdS0GoqCG0L64elZc+7eOJuEQZxCE8JwC+hGv/jOk8WYqMPhohGsrqoZgNA1I4e7WJHpwgvb2x8/zAskLUVhLaa376NlIxIKFw+LX+xcWbFOSBVzWm0wyfgkogB6ooViYeSqf1Vxwc45yhTpksgEl1KnJahyH/6erx7vYtqHTMbAJVdfkSfUUFikuWfp+TJU2qmpfD6eTl8qdzVgLfsQNMuXlcGaNwTi9f6/vhHx3XweMSZMgg7usP3Uh16+kLJxgzcsFgef555N/SEoP7IGhSHAbAuLn9LaWRx/sZ4xo5pjLNhhIu9MU/DOtW85wQL2NxqohW87HU19FQJyrr8JLthV6NC6IxT6RJ+y+Go8yJ7sb7YUDqJY+2/mrK2zQ33UnhPCY15MBfevbTfA1lRgZl6GA/Rl/4KLf/3Sw1UTri52IR5WqzB21xb8XlyAg9tFzkXty0k7yekcQ3PfkgcYGI9RnBkmVG2izPPeSiKxIuAozdUbhShP0jV1nv419gQ89nGVExPoOJ/FhCCU4pglQOeXdcZpgOLTLtPKGy8y8InJKZt9wpyGpCPLyHuHk+qCLxM5947/RQtKPKGpfd5y1j46SSBLPUUe4EjKTZ/Wgq6nKcfKMajcXTPhCF2h0mi7twok+4aXw13/uYdpFvFBINu4ciao3WI7tyB1z9s+GQr/pN7irI7cWKq+NT+jrgduVmPTeZDR1B8PRsydFqs6n1v+rrMbl/HE06VxOVKtaWOq3dUQvIF8AHt47lbx+Yn3PvnOr8qxlE+59J8TkSHPCdjvAucVF3OB68rI+BGlN/XF/lQA3r3sX3W4Qn7IP/bRSFBHt9wiEMJ19MTl8MQJR6k7NxTFj9mug5Dz3hN4l7fu25NYIrbXfgwdIECg51QNz8cYP/DMk+k+5AxdExr36RhHKseKD+yURkXrAbvR+ymimQIZ9oFF740goNn6lHNJzzHQG8Af/Aq9nVSyLuoHEh5LIs7ChbQHwgllD3G+qJARFHSvxTE+pHdz3AW81SQYu3DcBlZzdkKuyvIyqXPQvN+QisF42ip+AbWMVUG4jAWUDawXHxRCJkaZ+TwD+oVytAeUUf1q9bDm5EqcOpOeH8WIuiNriFIpN7YovXvf+oPzJdDht+qtWsWp/jsVNGllF1oHQL4jNUe3mg+0rQMmK72W6Alt2+f3ZaBfaDLRVS+VrRVcbilw3ioeO0ZRcfDIK7/4TwDKzrckLlnPvPvEAUFHPN4oCd2sPMhZladMpfx7lUz1OEnNn17zIeur9eX9x/GW9aqGGVCx5TDOA3OXAngHwz3PrrA60O+qlr2FLpDsdPut8R1dKCPBmfakTYE5+xf6criI8ZAYO8Qhs0deX+Zz1S10za3fz/B+/vWU/WSByfFxfWzJzUaC0whsTrtNOztXLn4/ld8HhvkCO/noTtsyLNDlOMBIg1+G65GUx7xruObtzUbjUT5xt+KgZWJnU1EtMadEEny54YL29a4GV/VE/ghNW/aka94+qaRlmTzM0YG6JIMPuICaLZwyYIWid6Gf02ndS9ar55cUMB4FZvp4kSyZC8dDMFyYrL2Tj9SUcXAFAB9TcMtzfLajnxcpZxOyFoGGPQk40YkAhiqG7NE+wFx+MjI7b9B63n3Qghx1LCiTIAFiX1pZW+fSz36V9lx39J9iziwS6JsYXiGaVyccTv4ZnhJxv5vuXk8GOnfSiPkbjGVVE+k7KYRb5vvTYyTAYnQz1YaWfEiImx0eSI2FoAfQk+X2r46ZNXjFZluKz+ts5PblowS9pL1A8THya4ufCNezjWU+PD5U2G+g3jqxFW3Le4hfBxchMrHs0tVK7LkSZ0c+W4i/B92ASPIOiO1mfPIpvB2eukDubFNCkSOTGVjY7eR2+5uGwxdCli5rQpjGwN0xpOU/p9uuP7o6C+CyKeR4fqVCjMVwiEjWmU0y+thzF4CI2KGxJNbOyY4vi3KmkammKoXKCzlUg1Vh7mkVgItZVCIXQw10Y99ifOlHC1EXq8/S+c0je9jIeoCrwaTNi9IYwV8jG+Z7v6RoHvgHFuR8RWZqOmmNVT5OQqr0ZyVS1qQ8gmfxM6TAo/Tz+L7rrdZCsrFNAiu9iJ8uRHke98uUwoHg74U6DDJKyyj82AaBIMMRYgY3Y/1D8Jl9bfPXw2WimdU+4am6p0ehsxWiy+dUZ5I36cR/DP13Fm6OtocwoZ7z2NI/cpoSp6cl1kZQXvOHdn0HxIZNdGL5he67aWDXLelqTfdWXO0v0+/YgT7qMZRq4hDFBPIqMG+CXPUqiwjdnWTLOaULh9mrW1A89HoumHSo3IZo8OWD9mkdSvniNAKWNn9PJAwFYCxFnAwo+NDlBWmsKRIEFLGaDwc6Kzx7z9I0OsKRThBYLQccrz0upbboWkXqpKAKYrEPwwKqQwYtlx0vUzAEISwytfSy8xjmmTpO5/o99CjK47Gj04duky/DAxCB+8WxfBGRrvPqCqnVoSPOEIevtZW3tWDNIrrFvowOjj5/snykIgJq7/y4LFIuMtpL87v+IdU+Hl85xl/4+YYBExKBajbYj+IFZzgNxMb05WEP9rMjCHX8OrhGSerfAOi4cPJJsc1Z1KyjHRqMvufKH5VpuV2D8ZtmgH9aeT/yTLeYDJdwezBTHQvB5IEvjOO/4pUT3M0yDwwxNLQWf0uvO2Bz0LnQtynBF4L1NHh//EFYzT2DjiZ7js7ZCrhpgqqXdzhldY6j0Utq//ApDoR++VUv9Qb9HgGEN7CYIgwvUibDfcHpB9TxLhmL27Ip72m1GqzB5Ii2r1HT3FyvOfAalezoEUpHbAo+rts+T/7anru25tOnDdzEehn1tku9i3r5vDfxHqRGKC8rnOk6Qhp5SMOciQNW/sD0kGoJPpayjauqm2HDgQEm2wVzMWtoK0tn1r4s/IrfT29h1lNR8Oq/REeb9maq0NJXHHkFbp/8odsWUuc2fGj0Mij6aP8mB8QRKE8H9xL8I/QIpS1Dk6jHjXj/xz4sWjaV17xhW6ml8zCqB3sadNbUZx+i5Enh5lEgmGIy5WQ0CRpTYQLJ/ndzsHJjZ0xLwy5buH8IaBqSJqKUQ19n6z4S3amGpoAC5h5nC9nl2u67ET7oQ848naIMxpDUXxGyjXbZoPbZciCuiNRQ7fIog5dt5iUFiBdn5zj+lpEWeMLwjwm/75aMK+1H7cGOV9SIJu0vGtmsy7mt1d87prOtyknnkk4hXNO1Y/ReRvZy1dRqpkb0oODTl1gHUyFGizcRZkdpsjXBSUYS7Q3vCSFtzpjSQMrELTq/4PMJ3w4CPzHX2vmTwL9msUyGOzItU5maVD/oa6U7s59PjJz+tovTMJdYbHn9LZR/xHS2VtXkb7REJy1Xy47hgA3CzpGTH++EAah4THBNhR6FTDnoDs6pTVWeW0pxRP4Bqn6vqxJ0qRGGAwGh6fY/jzEMSG0Ube2r6ja9C3vQwKYKczTTlczkdFDrfjgN+HZgUzj99y4uQzDqptKTGyiccUXsBiNNmqQLeb84WU053NIynEhAHnwiOf5+lYk2JqklmoiWNNaAVdln8D2SdMNCkdEYU7NMBRybr5u6glX93G5EBowzbWni+tQBVVP6zm0AROr3CadKVTHicYZmmyLfVNQ0/165Cf4VmgSDO2uNRTJyRTFRaE5lrByme5fnhR+KeUL9koipE+WkxF2GzQRa/C9+egl0KsMukrq+YZBjaG9tJlm4CDkUyakCA6636Y1cHuXr/ZOgp6OGmHLw0MkyXqGtGykOGI4GxlIwaeQT8Kjjqrtk+OZDUj8MPCOZLsSOgtu2CvHrFe5USQNinRGoHNmYZx4juyxIJOqC7L5vjBVuoBPsu6Hd/6ozIcEJzNvFF5g4XlyWAC4TQ9g2PQZk8wM9CW8ZJCuL67/E0FUchYNOJujj64WVWpJmK+bgvAbc4Dxzrfq/OBjuR/MIh/4OrxScWXvJ9mK6hTAAvV4ecuZBzN0KDVUU9AJq/HImyvMBkxTYgPXPCK3TzgQpgpap2wmKFaQHHwVBUJc6JgtDxuZQaXwxuWKjM7nQaVh+/znrCNzJw+AodWpOCfIamg+vgVT1fGOGu5UObP+yd5sIqn5IPNeCThL/GneFC6Lyhxe3NFgMjCDqcYw30kE16Ias2yiALcn+RhViBql2sn8ILrki4OhEBiCqYNBaMAiNutN9yAXwcGiXmCZmDQElC6R3fXaWSgl9bmTuF+YGRNOUu8O5KfYMFlhMuUD67F+KoxMdcQwx+jkp3IRfemzLZxB3LOKhilHB2MMbHrWfmwfOKr7UMMW6RsuCrLKt0W+9/zz177kR5AEV9o8l9sEaM9pjgC5ZgVrSfB/31N6jfFyqKYFwjA3iCRDlKg6lgei8zB9z615n8aLnxp6ZeKmG5r5uR9Gz2RNP0+UWcOwrYxloR7IrweXrAMKBqx4yCveIAMVK1zt7SuetmlZkOW0vgKKaoR3+QtaGKJ1wmqFNxnIRDp2gaf+RCW0FSWkSnUhN0KyiozgUAyKEffUz24MaaZgqHDe2l2IqHMYYPuZL1DodXXXTjaCwmTrMG+GH+a1MZ7ZQ6+0rnsD7YK7nPcbU5PdbN6ZS01/35ujH8gyHh6jKA41l7PBoXn7HzqqA0+mA767HSlU4vINQXzUpMLAQ3AZmwBl4jE9wxW7OfYbwrAU7eyAqRrtgJ/8lnjWuuzHSu7vinbryNcPlk5jHMhDniURAnUCL3W1RD0/4CbuGIqB8uESe75q4EsEPZ0hKOePhyUuk59NEHSkYYpdIFWlXclxNLmbxOAEc/8WxfDCqxTGekDBqU1QW3/Hak9cIpflIPyKSJtXIiHxCFs+DHXdFUwwwPGlLSocTPeu6H3ioJP9S64tfOAM1AUfNiH2otnxNNK33ClELl2kgv53Wj1SNbscbT6IZOdsFpPxi/IGyoY0v4OxwNO+DEuRQ5IMTgefVv5TvCb7/xHMWWYy6m0gPC7RW0UEV0jq391bwN7PhRwzl6PUlZxavSVZru8DYhnE4kQxur+LTbWqVw2VfFzVzhkS9kgLGecTX/qyDYmMZK0EkFeHeHSUCziaof1G3j0O1MHLJrwvqCMv8KM6TQAj+ZF8KpEBJM5hhn0j4vI0TbaZNKnr9WC5E8C9+fW4TMSYjhBguF20SSCTJ8aldHLuClDzm+YQwrdjwPTlIEJfghogIomiFO+zw1RzFKtHQIk9DYbRRBngXnQw6ZRuWzOgtSNpjjjXJm/5MoKjw4Zf9w=="}';

        //encrypt the request
        String encryptedRequest = IntegrationUtilities.getEncryptedRequest(JSON.serialize(applicationWrapper), System.Label.privateKey, System.Label.ivkey);
        String jdataRequest = '"JData":';                    
        String body='{'+jdataRequest + '"'+encryptedRequest+'"'+'}';

        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/createLoanApplication/';
        request.httpMethod = 'POST';
        system.debug('Before request.requestBody -->'+blob.valueof(Json.serialize(applicationWrapper)));
        request.requestBody = blob.valueof(body);
        RestContext.request = request;
        RestResponse res = new RestResponse();
        RestContext.response= res;
        system.debug('res-->'+res);
        LoanApplicationDataManager.createLoanApplication();
    }
    @isTest
    static void testCreateLoanApplicationPreApproved(){
        String orgId = UserInfo.getOrganizationId(); 
        String dateString =   
        String.valueof(Datetime.now()).replace(' ' ,'').replace(':','').replace('-','');  
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));  
        String uniqueName = orgId + dateString + randomInt;
        if(uniqueName.length() > 20 ){
            uniqueName = uniqueName.substring(0, 20);
        }
        System.debug(uniqueName);
        //create BE master record
        D2C_BE_Master__c beMaster = new D2C_BE_Master__c();
        beMaster.Pin_Code__c = 131302;
        beMaster.BL_Code__c = 'HDT';
        beMaster.Employee_Id__c = uniqueName;
        beMaster.Name = 'NANDLAL';
        beMaster.State__c = 'HARYANA';
        beMaster.Product_Type__c = 'Two wheeler';
        insert beMaster;
        
        //create a user record with matching employeeId as username.
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive']; 
        User u = new User(Alias = 'IBLBE', Email='NANDLAL1@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='NANDLAL', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Kolkata', UserName=uniqueName+'@testorg.com.test',EmployeeNumber = uniqueName, Maker_Id__c = '1001',MobilePhone='1234567890');
        insert u;
        
        LoanApplicationDataManager.LoanApplication applicationWrapper = new LoanApplicationDataManager.LoanApplication();
        applicationWrapper.FirstName = 'firstname';
        applicationWrapper.LastName = 'lastname';
        applicationWrapper.Salutation = 'Mr.';
        applicationWrapper.MobileNumber = '9934567890';
        applicationWrapper.PANNumber = 'FGJKK0789G';
        applicationWrapper.EmailID = 'test@gmail.com';
        applicationWrapper.VehicleType = 'New';
        applicationWrapper.LeadSource = 'D2C';
        applicationWrapper.ProductType = 'Two wheeler';
        applicationWrapper.EmailIdStatus = 'valid';
        applicationWrapper.KYCNameAsPerPAN = 'firstname lastname';
        applicationWrapper.DedupeResponse = '{"JData":"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"}';
		applicationWrapper.BeId = uniqueName;
        applicationWrapper.BeBranchCode = 'HDT';
        
        //encrypt the request
        String encryptedRequest = IntegrationUtilities.getEncryptedRequest(JSON.serialize(applicationWrapper), System.Label.privateKey, System.Label.ivkey);
        String jdataRequest = '"JData":';                    
        String body='{'+jdataRequest + '"'+encryptedRequest+'"'+'}';

        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/createLoanApplication/';
        request.httpMethod = 'POST';
        request.requestBody = blob.valueof(body);
        RestContext.request = request;
        RestResponse res = new RestResponse();
        RestContext.response= res;
        system.debug('res-->'+res);
        LoanApplicationDataManager.createLoanApplication();
    }
    @isTest
    static void testCreateAggregatorLoanApplication(){
        String orgId = UserInfo.getOrganizationId(); 
        String dateString =   
        String.valueof(Datetime.now()).replace(' ' ,'').replace(':','').replace('-','');  
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));  
        String uniqueName = orgId + dateString + randomInt;
        if(uniqueName.length() > 20 ){
            uniqueName = uniqueName.substring(0, 20);
        }
        System.debug(uniqueName);
        //create BE master record
        D2C_BE_Master__c beMaster = new D2C_BE_Master__c();
        beMaster.Pin_Code__c = 131302;
        beMaster.BL_Code__c = 'HDT';
        beMaster.Employee_Id__c = uniqueName;
        beMaster.Name = 'NANDLAL';
        beMaster.State__c = 'HARYANA';
        beMaster.Product_Type__c = 'Two wheeler';
        insert beMaster;
        
        //create a user record with matching employeeId as username.
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive']; 
        User u = new User(Alias = 'IBLBE', Email='NANDLAL1@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='NANDLAL', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='Asia/Kolkata', UserName=uniqueName+'@testorg.com.test',EmployeeNumber = uniqueName, Maker_Id__c = '1001',MobilePhone = '1234567890');
        insert u;
        
        LoanApplicationDataManager.LoanApplication applicationWrapper = new LoanApplicationDataManager.LoanApplication();
        applicationWrapper.FirstName = 'firstname';
        applicationWrapper.LastName = 'lastname';
        applicationWrapper.Salutation = 'Mr.';
        applicationWrapper.MobileNumber = '9934567890';
        applicationWrapper.PANNumber = 'FGJKK0789G';
        applicationWrapper.EmailID = 'test@gmail.com';
        applicationWrapper.VehicleType = 'New';
        applicationWrapper.LeadSource = 'Droom';
        applicationWrapper.ProductType = 'Two wheeler';
        applicationWrapper.EmailIdStatus = 'valid';
        applicationWrapper.KYCNameAsPerPAN = 'firstname lastname';
        applicationWrapper.DedupeResponse = '{"JData":"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"}';
		applicationWrapper.Pincode = '131302';
        
        //encrypt the request
        String encryptedRequest = IntegrationUtilities.getEncryptedRequest(JSON.serialize(applicationWrapper), System.Label.privateKey, System.Label.ivkey);
        String jdataRequest = '"JData":';                    
        String body='{'+jdataRequest + '"'+encryptedRequest+'"'+'}';

        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/createLoanApplication/';
        request.httpMethod = 'POST';
        request.requestBody = blob.valueof(body);
        RestContext.request = request;
        RestResponse res = new RestResponse();
        RestContext.response= res;
        system.debug('res-->'+res);
        LoanApplicationDataManager.createLoanApplication();
    }
 //CISP-7211
}