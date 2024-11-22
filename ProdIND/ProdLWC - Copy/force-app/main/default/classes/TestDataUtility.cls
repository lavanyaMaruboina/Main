/*
* @Author   : Kranthi Makkena
* Version   : Initial
* Date      : 25-11-2021    
* Description:  This class is a Factory class to create test data to be used for Test classes.
* Test Class Name : TestDataUtility 
*/

@isTest 
public class TestDataUtility {

    
    public static Opportunity createTestLoanApplication(boolean  isInsert){
        Opportunity opsd1 = new Opportunity();
                opsd1.StageName = 'Qualification';
                opsd1.CloseDate = Date.newInstance(2021, 1, 11);
                opsd1.Name = 'testone';
        if(isInsert){
            insert opsd1;
        }
        return opsd1;
    }
    public static ContentVersion createContentVersion(String header, Boolean isInsert){
        Blob bodyBlob=Blob.valueOf(header); 
        ContentVersion sampleImage = new ContentVersion(
            Title='IndusIndLogo', 
            PathOnClient ='IndusIndLogo.png',
            VersionData = bodyBlob, 
            origin = 'H'
        );
        if(isInsert){
            insert sampleImage;
        }
        return sampleImage;
    }
    
    public static System_Configuration__c createSequenceNumber(Boolean isInsert){
        //Custom Setting: System Configuration field for testing
        System_Configuration__c seqNumber = new System_Configuration__c(Name='test',Lead_Sequence_No__c='00001');
        if(isInsert){
            insert seqNumber;
        }
        return seqNumber;
    }
    
    public static Account createTestAccount(Boolean isInsert){
         Account acc = new Account(name='test acc');
        if(isInsert){
          insert acc;  
        }
        return acc;
    }
    
    public static Contact createTestContact(Boolean isInsert){
        Account acc = createTestAccount(true);
        Contact con = new Contact();
        con.Phone = '93252344';
        con.LastName = 'abc';
        con.AccountId = acc.Id;
        
        if(isInsert){
          insert con;  
        }
        return con;
    }
    

    public static Documents__c createTestDocument(Boolean isInsert){
         Opportunity opp=[select Id, Lead_Number__c,Loan_amount__c from Opportunity limit 1 ];
         Applicant__c applicant=createTestApplicant(false);
         applicant.Opportunity__c = opp.Id;
         insert applicant;
         Documents__c document = new Documents__c( Name= ' Document',
                                                     Applicant__c =applicant.id,
                                                     DocAuth_Passed__c = true,
                                                     Selfie_report_Pass__c = true,
                                                     Golden_Source_Pass__c = true,
                                                     Proof_of_Identity_POI__c = false,
                                                     Name_Mismatch_Percentage__c = 00,
                                                     Is_Photocopy__c=true,
                                                     Opportunity_Relation__c=opp.Id,
                                                     Document_Type__c='RC Document',
                                                     KYC_name__c = 'Nidhi', 
                                                     KYC_Address_Line_1__c = 'NAGAR',
                                                     KYC_Address_Line_2__c = 'Nagpur', 
                                                     KYC_Pin_Code__c = '440037', 
                                                     KYC_City__c = 'Mumbai', 
                                                     KYC_District__c = 'MAHARASHTRA',
                                                     KYC_State__c = 'MAHARASHTRA',
                                                     Current_Residential_Address_Proof__c = true,
                                                     Addresss_Type__c = 'Current Residential Address',
                                                     Name_Mismatch_Pass__c = true,
                                                 is_Active__c=true);
        if(isInsert){
            insert document;
        }
        return document;
    }
    
    public static Income_Details__c createTestIncomeDetails(boolean isInsert, Applicant__c applicant){
        Income_Details__c incomedetails = new Income_Details__c(Applicant__c =applicant.id, Perfios_Transaction_Id__c = '04022022111044173');
        if(isInsert){
            insert incomedetails;
        }
        return incomedetails;
    }
    public static Documents__c createTestKYCDocs(boolean isInsert, Applicant__c applicant, Opportunity opp){
        Documents__c doc = new Documents__c(Applicant__c =applicant.id, Name = 'testDocument',Document_Type__c = 'Aadhaar',
                                            Opportunity_Relation__c=opp.id,Is_Front__c = true,Document_Side__c ='Front',
                                            OTP_for_borrower__c='9999');
        if(isInsert){
            insert doc;
        }
        return doc;
    }
    
    public static Opportunity createTestOpportunityForOcr(Boolean isInsert){
        Account acc = createTestAccount(true);
        Opportunity opp = new Opportunity( Name= 'Opportunity',
                                          AccountId = acc.Id,
                                          StageName='Prospecting',
                                          CloseDate=System.today().addMonths(1),
                                          OTP_for_borrower__c='99999',
                                          Applicant_Name__c='ayu',
                                          Mfr_Expence_Reimburse__c=32, 
                                          Mfr_Expence_Reimburse_Amt__c='6700',
                                          Mfr_Expence_Reimburse_Type__c='yhh' ,
                                          Lead_Number__c='L-10122021-1685',
                                          Mfr_Incentive__c=98,
                                          Main_Dealer_Incentive_Amount__c=76,
                                          Sub_Dealer_Ancentive_Amount__c=8798,
                                          DSM_Incentive1__c=767,
                                          DSM_Incentive2__c=65 ,
                                          DSM_Name1__c='bhgb' ,
                                          DSM_Name2__c='hhg', 
                                          Dealer_Disc_to_Customer__c='878',
                                          Dealer_Expence_Reimburse_Type__c='hgfh',
                                          Gift_through_Dealer_Amount__c='866', 
                                          Required_Tenure__c=7,
                                          Non_Dealer_DSM_Name1__c='jhfgh',
                                          Non_Dealer_DSM_Name2__c='jhhf',
                                          Non_Dealer_DSM_Incentive1__c=776, 
                                          Non_Dealer_DSM_Incentive2__c=766,
                                          Required_ROI__c=5,
                                          Service_Charges__c='76',
                                          Parent_Deal_number__c='7878',
                                          Documentation_Charges__c='98',
                                          Stamping_Charges__c='87',
                                          Loan_amount__c='76777',
                                          Contact_number__c = '415.555.1212',
                                          Front_Upload_Attempts__c=0,
                                          Back_Upload_Attempts__c=0,
                                          Selfie_Retry_Attempts__c=2,
                                          Vehicle_Sub_Category__c='UOM',
                                          Vehicle_Details_Retry_Attempt__c=1
                                          );
        if(isInsert){
            insert opp;
        }
        return opp;
    }
    
    public static Documents__c createTestKYCDocsForOcrFront(boolean isInsert, Applicant__c applicant, Opportunity opp){
        Documents__c doc = new Documents__c(Applicant__c =applicant.id, Name = 'testDocument',Document_Type__c = 'Aadhaar',
                                            Opportunity_Relation__c=opp.id,Is_Front__c = true,Document_Side__c ='Front',
                                            OTP_for_borrower__c='9999');
        if(isInsert){
            insert doc;
        }
        return doc;
    }
    
    public static Documents__c createTestKYCDocsForOcrFront2(boolean isInsert, Applicant__c applicant, Opportunity opp){
        Documents__c doc = new Documents__c(Applicant__c =applicant.id, Name = 'testDocument',Document_Type__c = 'Passport',
                                            Opportunity_Relation__c=opp.id,Is_Front__c = true,Document_Side__c ='Front',
                                            OTP_for_borrower__c='9999');
        if(isInsert){
            insert doc;
        }
        return doc;
    }
    
    public static Documents__c createTestKYCDocsForOcrFront3(boolean isInsert, Applicant__c applicant, Opportunity opp){
        Documents__c doc = new Documents__c(Applicant__c =applicant.id, Name = 'testDocument',Document_Type__c = 'PAN',
                                            Opportunity_Relation__c=opp.id,Is_Front__c = true,Document_Side__c ='Front',
                                            OTP_for_borrower__c='9999');
        if(isInsert){
            insert doc;
        }
        return doc;
    }
    
    public static Documents__c createTestKYCDocsForOcrFront4(boolean isInsert, Applicant__c applicant, Opportunity opp){
        Documents__c doc = new Documents__c(Applicant__c =applicant.id, Name = 'testDocument',Document_Type__c = 'Driving Licence',
                                            Opportunity_Relation__c=opp.id,Is_Front__c = true,Document_Side__c ='Front',
                                            OTP_for_borrower__c='9999');
        if(isInsert){
            insert doc;
        }
        return doc;
    }
    
    public static Documents__c createTestKYCDocsForOcrFront5(boolean isInsert, Applicant__c applicant, Opportunity opp){
        Documents__c doc = new Documents__c(Applicant__c =applicant.id, Name = 'testDocument',Document_Type__c = 'Voter Id',
                                            Opportunity_Relation__c=opp.id,Is_Front__c = true,Document_Side__c ='Front',
                                            OTP_for_borrower__c='9999');
        if(isInsert){
            insert doc;
        }
        return doc;
    }
    
    public static Documents__c createTestKYCDocsForOcrFront6(boolean isInsert, Applicant__c applicant, Opportunity opp){
        Documents__c doc = new Documents__c(Applicant__c =applicant.id, Name = 'testDocument',Document_Type__c = '',
                                            Opportunity_Relation__c=opp.id,Is_Front__c = true,Document_Side__c ='Front',
                                            OTP_for_borrower__c='9999');
        if(isInsert){
            insert doc;
        }
        return doc;
    }
    
    
    public static Documents__c createTestKYCDocsForOcrBack(boolean isInsert, Applicant__c applicant, Opportunity opp){
        Documents__c doc = new Documents__c(Applicant__c =applicant.id, Name = 'testDocument',Document_Type__c = 'Aadhaar',
                                            Opportunity_Relation__c=opp.id,Is_Front__c = true,Document_Side__c ='Back',
                                            OTP_for_borrower__c='9999');
        if(isInsert){
            insert doc;
        }
        return doc;
    }
    
    public static Documents__c createTestKYCDocsForOcrBack2(boolean isInsert, Applicant__c applicant, Opportunity opp){
        Documents__c doc = new Documents__c(Applicant__c =applicant.id, Name = 'testDocument',Document_Type__c = 'Passport',
                                            Opportunity_Relation__c=opp.id,Is_Front__c = true,Document_Side__c ='Back',
                                            OTP_for_borrower__c='9999');
        if(isInsert){
            insert doc;
        }
        return doc;
    }
    
    
    public static Documents__c createTestKYCDocsForOcrBack3(boolean isInsert, Applicant__c applicant, Opportunity opp){
        Documents__c doc = new Documents__c(Applicant__c =applicant.id, Name = 'testDocument',Document_Type__c = 'Driving Licence',
                                            Opportunity_Relation__c=opp.id,Is_Front__c = true,Document_Side__c ='Back',
                                            OTP_for_borrower__c='9999');
        if(isInsert){
            insert doc;
        }
        return doc;
    }
    
    public static Documents__c createTestKYCDocsForOcrBack4(boolean isInsert, Applicant__c applicant, Opportunity opp){
        Documents__c doc = new Documents__c(Applicant__c =applicant.id, Name = 'testDocument',Document_Type__c = 'Voter Id',
                                            Opportunity_Relation__c=opp.id,Is_Front__c = true,Document_Side__c ='Back',
                                            OTP_for_borrower__c='9999');
        if(isInsert){
            insert doc;
        }
        return doc;
    }
    
    public static Documents__c createTestKYCDocsForOcrBack5(boolean isInsert, Applicant__c applicant, Opportunity opp){
        Documents__c doc = new Documents__c(Applicant__c =applicant.id, Name = 'testDocument',Document_Type__c = '',
                                            Opportunity_Relation__c=opp.id,Is_Front__c = true,Document_Side__c ='',
                                            OTP_for_borrower__c='9999');
        if(isInsert){
            insert doc;
        }
        return doc;
    }
    
     public static Documents__c createTestKYCDocsForImage(boolean isInsert){
         Opportunity opp = TestDataUtility.createTestOpportunity(false);
         Applicant__c applicant = TestDataUtility.createTestApplicantImage(false);
        Documents__c doc = new Documents__c(Applicant__c =applicant.id, Name = 'testDocument',Document_Type__c = '',Opportunity_Relation__c=opp.id);
        if(isInsert){
            insert doc;
        }
        return doc;
    }
    
        public static Documents__c createTestDLDocs(boolean isInsert, Applicant__c applicant, Opportunity opp){
        Documents__c doc = new Documents__c(Applicant__c =applicant.id, Name = 'testDocument',Document_Type__c = '4',
                                          KYC_No__c=Integrationutilities.getencryptedrequest('TN2020090003150',System.Label.privateKey,System.Label.ivkey) , KYC_DOB__c= Date.newInstance(1991, 06, 05 ), Opportunity_Relation__c=opp.id,Is_Front__c = true,Document_Side__c ='Front',
                                            OTP_for_borrower__c='9999');
        if(isInsert){
            insert doc;
        }
        return doc;
    }

    public static Documents__c createTestKYCDocForBre(boolean isInsert, Applicant__c applicant, Opportunity opp){
        Id kycRecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
        Documents__c doc = new Documents__c(Applicant__c =applicant.id, recordTypeId = kycRecordTypeId, Name = 'testDocument',Document_Type__c = '',
                                          KYC_No__c=Integrationutilities.getencryptedrequest('TN2020090003150',System.Label.privateKey,System.Label.ivkey) , KYC_DOB__c= Date.newInstance(1991, 06, 05 ), Opportunity_Relation__c=opp.id,
                                            OTP_for_borrower__c='9999', Proof_of_Identity_POI__c = true);
        if(isInsert){
            insert doc;
        }
        return doc;
    }

     public static Documents__c createTestAadhaarDocs(boolean isInsert, Applicant__c applicant, Opportunity opp){
        Documents__c doc = new Documents__c(Applicant__c =applicant.id, Name = 'testDocument',Document_Type__c = 'Aadhaar',
                                            KYC_No__c=Integrationutilities.getencryptedrequest('H1700617',System.Label.privateKey,System.Label.ivkey), Salutation__c = 'Mr.',
                                            Opportunity_Relation__c=opp.id,Is_Front__c = true,Document_Side__c ='Front',
                                            OTP_for_borrower__c='9999');
        if(isInsert){
            insert doc;
        }
        return doc;
    }
    public static Documents__c createTestKYCDocsForImageUpload(boolean isInsert, Applicant__c applicant, Opportunity opp){
        Documents__c doc = new Documents__c(Applicant__c =applicant.id, Name = 'testDocument',Document_Type__c = '',
                                            Opportunity_Relation__c=opp.id,Is_Front__c = true,Document_Side__c ='',
                                            OTP_for_borrower__c='9999');
        if(isInsert){
            insert doc;
        }
        return doc;
    
    }
    /*
     * @Method:      createInsuranceDetails
     * @Created by:  Haarika Chodisetti
     * @Description: creates a new InsuranceDetails__c  record
     * @Param:       isInsert (Boolean)
     *               opp (Opportunity)
     * @Return:      InsuranceDetails__c
     History
     Date            Author              Comments
     -------------------------------------------------------------
     07-09-2022      Haarika Chodisetti         Created
     ------------------------------------------------------------*/
    public static InsuranceDetails__c createInsuranceDetails(boolean isInsert,Opportunity opp){
        InsuranceDetails__c ins = new InsuranceDetails__c(Loan_Application__c =opp.id, Name = 'testDocument',Insurance_Plan__c = 'MOTOR');
        if(isInsert){
            insert ins;
        }
        return ins;
    }
      public static Documents__c createTestPPDocs(boolean isInsert, Applicant__c applicant, Opportunity opp){
        Documents__c doc = new Documents__c(Applicant__c =applicant.id, Name = 'testDocument',Document_Type__c = 'Passport',
                                            Passport_File_No__c = 'MA2072741184320',Passport_No__c='U6926433' ,
                                            KYC_DOB__c= Date.newInstance(1990, 02, 08 ),Gender__c='MALE',
                                            Opportunity_Relation__c=opp.id,Is_Front__c = true,Document_Side__c ='Front',
                                            KYC_Address_Line_1__c = 'Mumbai',KYC_Address_Line_2__c = 'Mumbai',Addresss_Type__c = 'Current Residential Address',
                                            KYC_City__c = 'Mumbai',KYC_District__c = 'Mumbai',KYC_Expiry_Date__c = Date.newInstance(2030, 02, 08 ),
                                            KYC_State__c = 'Maharastra',KYC_Pin_Code__c = '400012',KYC_Issuance_Date__c = Date.newInstance(2010, 02, 08 ),KYC_name__c = 'PAN',KYC_No__c = Integrationutilities.getencryptedrequest('987653234567',System.Label.privateKey,System.Label.ivkey),
                                            OTP_for_borrower__c='9999'); //Date.newInstance(1999, 05, 04 )
        if(isInsert){
            insert doc;
        }
        return doc;
    }
    
          public static Documents__c createTestPPDocsForInternalDedupe(boolean isInsert, Applicant__c applicant, Opportunity opp){
        Documents__c doc = new Documents__c(Applicant__c =applicant.id, Name = 'testDocument',Document_Type__c = 'Passport',
                                            Passport_File_No__c = 'MA2072741184320',Passport_No__c='241015538542' ,
                                            KYC_DOB__c= Date.newInstance(1990, 02, 08 ),Gender__c='MALE',
                                            Opportunity_Relation__c=opp.id,Is_Front__c = true,Document_Side__c ='Front',
                                            KYC_Address_Line_1__c = 'Mumbai',KYC_Address_Line_2__c = 'Mumbai',Addresss_Type__c = 'Current Residential Address',
                                            KYC_City__c = 'Mumbai',KYC_District__c = 'Mumbai',KYC_Expiry_Date__c = Date.newInstance(2030, 02, 08 ),
                                            KYC_State__c = 'Maharastra',KYC_Pin_Code__c = '400012',KYC_Issuance_Date__c = Date.newInstance(2010, 02, 08 ),KYC_name__c = 'PAN',KYC_No__c = Integrationutilities.getencryptedrequest('987653234567',System.Label.privateKey,System.Label.ivkey),
                                            OTP_for_borrower__c='9999'); //Date.newInstance(1999, 05, 04 )
        if(isInsert){
            insert doc;
        }
        return doc;
    }
    
          public static Documents__c createTestPPDocs2(boolean isInsert, Applicant__c applicant, Opportunity opp){
        Documents__c doc = new Documents__c(Applicant__c =applicant.id, Name = 'testDocument',Document_Type__c = 'Passport',
                                            Passport_File_No__c = 'MA2072741184320',Passport_No__c='U6926433' ,
                                            KYC_DOB__c= Date.newInstance(1990, 02, 08 ),Gender__c='Female',
                                            Opportunity_Relation__c=opp.id,Is_Front__c = true,Document_Side__c ='Front',
                                            KYC_Address_Line_1__c = 'Mumbai',KYC_Address_Line_2__c = 'Mumbai',Addresss_Type__c = 'Current Residential Address',
                                            KYC_City__c = 'Mumbai',KYC_District__c = 'Mumbai',KYC_Expiry_Date__c = Date.newInstance(2030, 02, 08 ),
                                            KYC_State__c = 'Maharastra',KYC_Pin_Code__c = '400012',KYC_Issuance_Date__c = Date.newInstance(2010, 02, 08 ),KYC_name__c = 'PAN',KYC_No__c = Integrationutilities.getencryptedrequest('987653234567',System.Label.privateKey,System.Label.ivkey),
                                            OTP_for_borrower__c='9999'); //Date.newInstance(1999, 05, 04 )
        if(isInsert){
            insert doc;
        }
        return doc;
    }
    
          public static Documents__c createTestPPDocs3(boolean isInsert, Applicant__c applicant, Opportunity opp){
        Documents__c doc = new Documents__c(Applicant__c =applicant.id, Name = 'testDocument',Document_Type__c = 'Passport',
                                            Passport_File_No__c = 'MA2072741184320',Passport_No__c='U6926433' ,
                                            KYC_DOB__c= Date.newInstance(1990, 02, 08 ),Gender__c='Transgender',
                                            Opportunity_Relation__c=opp.id,Is_Front__c = true,Document_Side__c ='Front',
                                            KYC_Address_Line_1__c = 'Mumbai',KYC_Address_Line_2__c = 'Mumbai',Addresss_Type__c = 'Current Residential Address',
                                            KYC_City__c = 'Mumbai',KYC_District__c = 'Mumbai',KYC_Expiry_Date__c = Date.newInstance(2030, 02, 08 ),
                                            KYC_State__c = 'Maharastra',KYC_Pin_Code__c = '400012',KYC_Issuance_Date__c = Date.newInstance(2010, 02, 08 ),KYC_name__c = 'PAN',KYC_No__c = Integrationutilities.getencryptedrequest('987653234567',System.Label.privateKey,System.Label.ivkey),
                                            OTP_for_borrower__c='9999'); //Date.newInstance(1999, 05, 04 )
        if(isInsert){
            insert doc;
        }
        return doc;
    }
    
     public static Documents__c createTestPPDocs4(boolean isInsert, Applicant__c applicant, Opportunity opp){
        Documents__c doc = new Documents__c(Applicant__c =applicant.id, Name = 'testDocument',Document_Type__c = 'Passport',
                                            Passport_File_No__c = '',Passport_No__c='U6926433' ,
                                            KYC_DOB__c= Date.newInstance(1990, 02, 08 ),Gender__c='MALE',
                                            Opportunity_Relation__c=opp.id,Is_Front__c = true,Document_Side__c ='Front',
                                            KYC_Address_Line_1__c = 'Mumbai',KYC_Address_Line_2__c = 'Mumbai',Addresss_Type__c = 'Current Residential Address',
                                            KYC_City__c = 'Mumbai',KYC_District__c = 'Mumbai',KYC_Expiry_Date__c = Date.newInstance(2030, 02, 08 ),
                                            KYC_State__c = 'Maharastra',KYC_Pin_Code__c = '400012',KYC_Issuance_Date__c = Date.newInstance(2010, 02, 08 ),KYC_name__c = 'PAN',KYC_No__c = Integrationutilities.getencryptedrequest('987653234567',System.Label.privateKey,System.Label.ivkey),
                                            OTP_for_borrower__c='9999'); //Date.newInstance(1999, 05, 04 )
        if(isInsert){
            insert doc;
        }
        return doc;
    }
    
     public static Documents__c createTestPPDocs5(boolean isInsert, Applicant__c applicant, Opportunity opp){
        Documents__c doc = new Documents__c(Applicant__c =applicant.id, Name = 'testDocument',Document_Type__c = 'Passport',
                                            Passport_File_No__c = 'MA2072741184320',Passport_No__c='' ,
                                            KYC_DOB__c= Date.newInstance(1990, 02, 08 ),Gender__c='MALE',
                                            Opportunity_Relation__c=opp.id,Is_Front__c = true,Document_Side__c ='Front',
                                            KYC_Address_Line_1__c = 'Mumbai',KYC_Address_Line_2__c = 'Mumbai',Addresss_Type__c = 'Current Residential Address',
                                            KYC_City__c = 'Mumbai',KYC_District__c = 'Mumbai',KYC_Expiry_Date__c = Date.newInstance(2030, 02, 08 ),
                                            KYC_State__c = 'Maharastra',KYC_Pin_Code__c = '400012',KYC_Issuance_Date__c = Date.newInstance(2010, 02, 08 ),KYC_name__c = 'PAN',KYC_No__c = Integrationutilities.getencryptedrequest('987653234567',System.Label.privateKey,System.Label.ivkey),
                                            OTP_for_borrower__c='9999'); //Date.newInstance(1999, 05, 04 )
        if(isInsert){
            insert doc;
        }
        return doc;
    }
    
     public static Documents__c createTestPPDocs6(boolean isInsert, Applicant__c applicant, Opportunity opp){
        Documents__c doc = new Documents__c(Applicant__c =applicant.id, Name = 'testDocument',Document_Type__c = 'Passport',
                                            Passport_File_No__c = 'MA2072741184320',Passport_No__c='U6926433' ,
                                            KYC_DOB__c= Date.newInstance(1990, 02, 08 ),Gender__c='',
                                            Opportunity_Relation__c=opp.id,Is_Front__c = true,Document_Side__c ='Front',
                                            KYC_Address_Line_1__c = 'Mumbai',KYC_Address_Line_2__c = 'Mumbai',Addresss_Type__c = 'Current Residential Address',
                                            KYC_City__c = 'Mumbai',KYC_District__c = 'Mumbai',KYC_Expiry_Date__c = Date.newInstance(2030, 02, 08 ),
                                            KYC_State__c = 'Maharastra',KYC_Pin_Code__c = '400012',KYC_Issuance_Date__c = Date.newInstance(2010, 02, 08 ),KYC_name__c = 'PAN',KYC_No__c = Integrationutilities.getencryptedrequest('987653234567',System.Label.privateKey,System.Label.ivkey),
                                            OTP_for_borrower__c='9999'); //Date.newInstance(1999, 05, 04 )
        if(isInsert){
            insert doc;
        }
        return doc;
    }
    
     public static Documents__c createTestPPDocs7(boolean isInsert, Applicant__c applicant, Opportunity opp){
        Documents__c doc = new Documents__c(Applicant__c =applicant.id, Name = 'testDocument',Document_Type__c = 'Passport',
                                            Passport_File_No__c = 'MA2072741184320',Passport_No__c='U6926433' ,
                                            Gender__c='MALE',
                                            Opportunity_Relation__c=opp.id,Is_Front__c = true,Document_Side__c ='Front',
                                            KYC_Address_Line_1__c = 'Mumbai',KYC_Address_Line_2__c = 'Mumbai',Addresss_Type__c = 'Current Residential Address',
                                            KYC_City__c = 'Mumbai',KYC_District__c = 'Mumbai',KYC_Expiry_Date__c = Date.newInstance(2030, 02, 08 ),
                                            KYC_State__c = 'Maharastra',KYC_Pin_Code__c = '400012',KYC_Issuance_Date__c = Date.newInstance(2010, 02, 08 ),KYC_name__c = 'PAN',KYC_No__c = Integrationutilities.getencryptedrequest('987653234567',System.Label.privateKey,System.Label.ivkey),
                                            OTP_for_borrower__c='9999'); //Date.newInstance(1999, 05, 04 )
        if(isInsert){
            insert doc;
        }
        return doc;
    }
    
     public static Documents__c createTestVoterIdDocs(boolean isInsert, Applicant__c applicant, Opportunity opp){
        Documents__c doc = new Documents__c(Applicant__c =applicant.id, Name = 'testDocument',Document_Type__c ='Voter Id',
                                            Gender__c='MALE',KYC_No__c=Integrationutilities.getencryptedrequest('AR01002024213',System.Label.privateKey,System.Label.ivkey),
                                            Opportunity_Relation__c=opp.id,Is_Front__c = true,Document_Side__c ='Front',
                                            KYC_Address_Line_1__c = 'Mumbai',KYC_Address_Line_2__c = 'Mumbai',Addresss_Type__c = 'Current Residential Address',
                                            KYC_City__c = 'Mumbai',KYC_District__c = 'Mumbai',KYC_Expiry_Date__c = Date.newInstance(2030, 02, 08 ),
                                            KYC_State__c = 'Maharastra',KYC_Pin_Code__c = '400012',KYC_Issuance_Date__c = Date.newInstance(2010, 02, 08 ),KYC_name__c = 'PAN',
                                            OTP_for_borrower__c='9999'); //Date.newInstance(1999, 05, 04 )
        if(isInsert){
            insert doc;
        }
        return doc;
    }
    
     public static Documents__c createTestPanDocs(boolean isInsert, Applicant__c applicant, Opportunity opp){
        Documents__c doc = new Documents__c(Applicant__c =applicant.id, Name = 'testDocument',Document_Type__c ='Pan',
                                            Gender__c='MALE',PAN_No__c='fiNpj3KcPkWhivdQoug1hA==', KYC_DOB__c= Date.newInstance(1990, 07, 17 ),
                                            Opportunity_Relation__c=opp.id,Is_Front__c = true,Document_Side__c ='Front',
                                            KYC_Address_Line_1__c = 'Mumbai',KYC_Address_Line_2__c = 'Mumbai',Addresss_Type__c = 'Current Residential Address',
                                            KYC_City__c = 'Mumbai',KYC_District__c = 'Mumbai',KYC_Expiry_Date__c = Date.newInstance(2030, 02, 08 ),
                                            KYC_State__c = 'Maharastra',KYC_Pin_Code__c = '400012',KYC_Issuance_Date__c = Date.newInstance(2010, 02, 08 ),KYC_name__c = 'PAN',KYC_No__c = Integrationutilities.getencryptedrequest('987653234567',System.Label.privateKey,System.Label.ivkey),
                                            OTP_for_borrower__c='9999'); //Date.newInstance(1999, 05, 04 )
        if(isInsert){
            insert doc;
        }
        return doc;
    }
    
     public static Documents__c createTestPanDocsForInternalDedupe(boolean isInsert, Applicant__c applicant, Opportunity opp){
        Documents__c doc = new Documents__c(Applicant__c =applicant.id, Name = 'testDocument',Document_Type__c ='Pan',
                                            Gender__c='MALE',PAN_No__c='fiNpj3KcPkWhivdQoug1hA==', KYC_DOB__c= Date.newInstance(1990, 07, 17 ),
                                            Opportunity_Relation__c=opp.id,Is_Front__c = true,Document_Side__c ='Front',
                                            KYC_Address_Line_1__c = 'Mumbai',KYC_Address_Line_2__c = 'Mumbai',Addresss_Type__c = 'Current Residential Address',
                                            KYC_City__c = 'Mumbai',KYC_District__c = 'Mumbai',KYC_Expiry_Date__c = Date.newInstance(2030, 02, 08 ),
                                            KYC_State__c = 'Maharastra',KYC_Pin_Code__c = '400012',KYC_Issuance_Date__c = Date.newInstance(2010, 02, 08 ),KYC_name__c = 'PAN',KYC_No__c = Integrationutilities.getencryptedrequest('987653234567',System.Label.privateKey,System.Label.ivkey),
                                            OTP_for_borrower__c='9999'); //Date.newInstance(1999, 05, 04 )
        if(isInsert){
            insert doc;
        }
        return doc;
    }
    
    public static Documents__c createTestDocs2(boolean isInsert, Applicant__c applicant, Opportunity opp){
        Documents__c doc = new Documents__c(Applicant__c =applicant.id, Name = 'testDocument',Document_Type__c = 'Pan',
                                            KYC_DOB__c= Date.newInstance(1990, 07, 17 ),
                                            Opportunity_Relation__c=opp.id,Is_Front__c = true,Document_Side__c ='Front',
                                            KYC_Address_Line_1__c = 'Mumbai',KYC_Address_Line_2__c = 'Mumbai',Addresss_Type__c = 'Current Residential Address',
                                            KYC_City__c = 'Mumbai',KYC_District__c = 'Mumbai',KYC_Expiry_Date__c = Date.newInstance(2030, 02, 08 ),
                                            KYC_State__c = 'Maharastra',KYC_Pin_Code__c = '400012',KYC_Issuance_Date__c = Date.newInstance(2010, 02, 08 ),KYC_name__c = 'PAN',KYC_No__c = Integrationutilities.getencryptedrequest('987653234567',System.Label.privateKey,System.Label.ivkey),
                                            OTP_for_borrower__c='9999');
        if(isInsert){
            insert doc;
        }
        return doc;
    }
    
     public static Documents__c createTestVoterIdDocs2(boolean isInsert, Applicant__c applicant, Opportunity opp){
        Documents__c doc = new Documents__c(Applicant__c =applicant.id, Name = 'testDocument',Document_Type__c = 'Voter Id',
                                            Gender__c='MALE',KYC_No__c='',
                                            Opportunity_Relation__c=opp.id,Is_Front__c = true,Document_Side__c ='Front',
                                            KYC_Address_Line_1__c = 'Mumbai',KYC_Address_Line_2__c = 'Mumbai',Addresss_Type__c = 'Current Residential Address',
                                            KYC_City__c = 'Mumbai',KYC_District__c = 'Mumbai',KYC_Expiry_Date__c = Date.newInstance(2030, 02, 08 ),
                                            KYC_State__c = 'Maharastra',KYC_Pin_Code__c = '400012',KYC_Issuance_Date__c = Date.newInstance(2010, 02, 08 ),KYC_name__c = 'PAN',
                                            OTP_for_borrower__c='9999'); //Date.newInstance(1999, 05, 04 )
        if(isInsert){
            insert doc;
        }
        return doc;
    }
    public static Documents__c createTestKYCDocsForCIBIL(boolean isInsert, Applicant__c applicant, Opportunity opp){
        Documents__c doc = new Documents__c(Applicant__c =applicant.id, Name = 'testDocument',Document_Type__c = '',
                                            KYC_No__c=Integrationutilities.getencryptedrequest('234324234234',System.Label.privateKey,System.Label.ivkey),KYC_DOB__c= Date.newInstance(1991, 06, 05 ),Gender__c='Female',KYC_Address_Line_1__c='',KYC_Address_Line_2__c='ABCD',
                                            KYC_City__c='Mumbai',KYC_State__c='',KYC_Pin_Code__c='',Salutation__c='Mr.',KYC_name__c='',
                                            Opportunity_Relation__c=opp.id,Is_Front__c = true,Document_Side__c ='Back',
                                            OTP_for_borrower__c='9999');
        if(isInsert){
            insert doc;
        }
        return doc;
    }
    
    public static CIBIL_Details__c createCIBILDetails(boolean isInsert, Applicant__c applicant){
        CIBIL_Details__c cibilDetail = new CIBIL_Details__c(Applicant__c = applicant.Id, CIBIL_Report_URl__c='https://cfdservice.indusind.com/CIBIL_CIR_IDV_Report/transunion/viewreport',Equifax_Report_URl__c='https://cfdservice.indusind.com/CIBIL_CIR_IDV_Report/transunion/viewreport');
            
         if(isInsert){
            insert cibilDetail;
        }
        return cibilDetail;
    } 
    
  public static UserRole createUserRole(Boolean isInsert, String DevelopName, String Names){

        UserRole userRoleObj = new UserRole(DeveloperName = DevelopName, Name = Names);
        if(isInsert)
            insert userRoleObj;
        return userRoleObj;
    }


    /*
     * @Method:      createUserForVoterId
     * @Created by:
     * @Description: creates a new User record
     * @Param:       isInsert (Boolean)
     *               userRole (UserRole)
     * @Return:      User
     History
     Date            Author                     Comments
     -------------------------------------------------------------
                                                Created
     07-09-2022      Haarika Chodisetti         Added MobilePhone to escape insert failed error
     ------------------------------------------------------------*/
    public static User createUserForVoterId(Boolean isInsert,UserRole userRole){
        User user = new User(
     ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
     LastName = 'last',
     Email = 'testuser000@amamama.com',
     Username = 'testuser000@amamama.com' + System.currentTimeMillis(),
     CompanyName = 'TEST',
     Title = 'title',
     Alias = 'alias',
     TimeZoneSidKey = 'America/Los_Angeles',
     EmailEncodingKey = 'UTF-8',
     LanguageLocaleKey = 'en_US',
     LocaleSidKey = 'en_US',
     UserRoleId = userRole.Id,
     Maker_Id__c='100001',
     MobilePhone='1234567890',
     EmployeeNumber = '567567');
        if(isInsert){
           insert user;
        }
        return user;
    }
    
    public static User createIBCounterStaffUser(Boolean isInsert){
       Profile p = [SELECT Id FROM Profile WHERE Name='IBL Counter Staff'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
					EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
					LocaleSidKey='en_US', ProfileId = p.Id,MobilePhone = '9999999999',Maker_Id__c = '1001',
					TimeZoneSidKey='America/Los_Angeles',
					UserName='standarduser4@testorg.com.psdev1');
        if(isInsert){
            insert u; 
        }
           
        return u;
    }
          
    public static Opportunity createTestOpportunity211(Boolean isInsert){
        Opportunity opp = new Opportunity(Name= 'Opportunity',
                                          StageName='Prospecting',
                                          Vehicle_Sub_Category__c= 'UIM',
                                         Employee_Name__c='Ravi Kumar',
                                         Employee_No__c='9876543212',
                                          Deal_Number__c = 'TUT06226H',
                                          //Parent_Deal_number__c = 'TUT06226H'
                                         Agent_BL_code__c='MPP',
                                          Sub_Stage__c = 'Field Investigation',
                                          Loan_amount__c='400000',
                                          Product_Type__c = 'Two Wheeler',
                                          CloseDate=System.today().addMonths(1),
                                          OTP_for_borrower__c='99999',
                                          Applicant_Name__c='ayuyu',
                                          Mfr_Expence_Reimburse__c=32, 
                                          Mfr_Expence_Reimburse_Amt__c='6700',
                                          Mfr_Expence_Reimburse_Type__c='yhh' ,
                                          Mfr_Incentive__c=98,
                                          Main_Dealer_Incentive_Amount__c=76,
                                          Sub_Dealer_Ancentive_Amount__c=8798,
                                          DSM_Incentive1__c=767,
                                          DSM_Incentive2__c=65 ,
                                          DSM_Name1__c='bhgb' ,
                                          DSM_Name2__c='hhg', 
                                          Dealer_Disc_to_Customer__c='878',
                                          Dealer_Expence_Reimburse_Type__c='hgfh',
                                          Gift_through_Dealer_Amount__c='866', 
                                          Required_Tenure__c=7,
                                          Non_Dealer_DSM_Name1__c='jhfgh',
                                          Non_Dealer_DSM_Name2__c='jhhf',
                                          Non_Dealer_DSM_Incentive1__c=776, 
                                          Non_Dealer_DSM_Incentive2__c=766,
                                          Required_ROI__c=5,
                                          Service_Charges__c='76',
                                          Parent_Deal_number__c='7878',
                                          Documentation_Charges__c='98',
                                          Stamping_Charges__c='87',
                                          
                                          Contact_number__c = '415.555.1212',
                                          Front_Upload_Attempts__c=0,
                                          Back_Upload_Attempts__c=0,
                                          Selfie_Retry_Attempts__c=2,
                                          Vehicle_Type__c = 'New',
                                          Variant__c = 'SWIFTVDI6',
                                          Lead_Number__c='L-10122021-1685',
                                        //  Product_Type__c='Passenger Vehicles',
                                          Vehicle_Registration_Number__c = 'PY05J3039');
        if(isInsert){
            insert opp;
        }
        return opp;

    }
       
    public static Opportunity createTestOpportunity(Boolean isInsert){
        Opportunity opp = new Opportunity( Name= 'Opportunity',
                                          StageName='Prospecting',
                                          Vehicle_Sub_Category__c= 'UIM',
                                         Employee_Name__c='Ravi Kumar',
                                         Employee_No__c='9876543212',
                                          Deal_Number__c = 'TUT06226H',
                                          //Parent_Deal_number__c = 'TUT06226H'
                                         Agent_BL_code__c='MPP',
                                          Sub_Stage__c = 'Field Investigation',
                                          Loan_amount__c='400000',
                                          Product_Type__c = 'Two Wheeler',
                                          CloseDate=System.today().addMonths(1),
                                          OTP_for_borrower__c='99999',
                                          Applicant_Name__c='ayuyu',
                                          Mfr_Expence_Reimburse__c=32, 
                                          Mfr_Expence_Reimburse_Amt__c='6700',
                                          Mfr_Expence_Reimburse_Type__c='yhh' ,
                                          Mfr_Incentive__c=98,
                                          Main_Dealer_Incentive_Amount__c=76,
                                          Sub_Dealer_Ancentive_Amount__c=8798,
                                          DSM_Incentive1__c=767,
                                          DSM_Incentive2__c=65 ,
                                          DSM_Name1__c='bhgb' ,
                                          DSM_Name2__c='hhg', 
                                          Dealer_Disc_to_Customer__c='878',
                                          Dealer_Expence_Reimburse_Type__c='hgfh',
                                          Gift_through_Dealer_Amount__c='866', 
                                          Required_Tenure__c=7,
                                          Non_Dealer_DSM_Name1__c='jhfgh',
                                          Non_Dealer_DSM_Name2__c='jhhf',
                                          Non_Dealer_DSM_Incentive1__c=776, 
                                          Non_Dealer_DSM_Incentive2__c=766,
                                          Required_ROI__c=5,
                                          Service_Charges__c='76',
                                          Parent_Deal_number__c='7878',
                                          Documentation_Charges__c='98',
                                          Stamping_Charges__c='87',
                                          
                                          Contact_number__c = '415.555.1212',
                                          Front_Upload_Attempts__c=0,
                                          Back_Upload_Attempts__c=0,
                                          Selfie_Retry_Attempts__c=2,
                                          Vehicle_Type__c = 'New',
                                          Variant__c = 'SWIFTVDI6',
                                          Lead_Number__c='L-10122021-1685',
                                          //Product_Type__c='Passenger Vehicles',
                                          Vehicle_Registration_Number__c = 'PY05J3039');
        if(isInsert){
            insert opp;
        }
        return opp;
    }

    public static Opportunity createTestOpportunityforLTV(Boolean isInsert){
        Opportunity opp = new Opportunity( Name= 'Opportunity',
                                          StageName='Qualification',
                                          Vehicle_Sub_Category__c= 'UIM',
                                          Deal_Number__c = 'TUT06226H',
                                          //Parent_Deal_number__c = 'TUT06226H'
                                          LeadSource = 'DSA',
                                         Agent_BL_code__c='MPP',
                                          Sub_Stage__c = 'Field Investigation',
                                          Loan_amount__c='400000',
                                          Product_Type__c = 'Two Wheeler',
                                          CloseDate=System.today().addMonths(1),
                                          OTP_for_borrower__c='99999',
                                          Applicant_Name__c='ayuyu',
                                          Mfr_Expence_Reimburse__c=32,
                                          Mfr_Expence_Reimburse_Amt__c='6700',
                                          Mfr_Expence_Reimburse_Type__c='yhh' ,
                                          Mfr_Incentive__c=98,
                                          Main_Dealer_Incentive_Amount__c=76,
                                          Sub_Dealer_Ancentive_Amount__c=8798,
                                          Gift_through_Dealer_Amount__c='866',
                                          Required_Tenure__c=7,
                                          Required_ROI__c=5,
                                          Parent_Deal_number__c='7878',

                                          Contact_number__c = '415.555.1212',
                                          Front_Upload_Attempts__c=0,
                                          Back_Upload_Attempts__c=0,
                                          Selfie_Retry_Attempts__c=2,
                                          Vehicle_Type__c = 'New',
                                          Variant__c = 'SWIFTVDI6',
                                          Lead_Number__c='L-10122021-1685',
                                          //Product_Type__c='Passenger Vehicles',
                                          Vehicle_Registration_Number__c = 'PY05J3039');
        if(isInsert){
            insert opp;
        }
        return opp;
    }

    public static Opportunity createTestOpportunity2(Boolean isInsert){
        Opportunity opp = new Opportunity( Name= 'Opportunity',
                                          StageName='Prospecting',
                                          CloseDate=System.today().addMonths(1),
                                          OTP_for_borrower__c='99999',
                                          Applicant_Name__c='ayuyu',
                                          Mfr_Expence_Reimburse__c=32, 
                                          Mfr_Expence_Reimburse_Amt__c='6700',
                                          Mfr_Expence_Reimburse_Type__c='yhh' ,
                                          Mfr_Incentive__c=98,
                                          Main_Dealer_Incentive_Amount__c=76,
                                          Sub_Dealer_Ancentive_Amount__c=8798,
                                          DSM_Incentive1__c=767,
                                          DSM_Incentive2__c=65 ,
                                          DSM_Name1__c='bhgb' ,
                                          DSM_Name2__c='hhg', 
                                          Dealer_Disc_to_Customer__c='878',
                                          Dealer_Expence_Reimburse_Type__c='hgfh',
                                          Gift_through_Dealer_Amount__c='866', 
                                          Required_Tenure__c=7,
                                          Non_Dealer_DSM_Name1__c='jhfgh',
                                          Non_Dealer_DSM_Name2__c='jhhf',
                                          Non_Dealer_DSM_Incentive1__c=776, 
                                          Non_Dealer_DSM_Incentive2__c=766,
                                          Required_ROI__c=5,
                                          Service_Charges__c='76',
                                          Parent_Deal_number__c='7878',
                                          Documentation_Charges__c='98',
                                          Stamping_Charges__c='87',
                                          Loan_amount__c='400000',
                                          Contact_number__c = '415.555.1212',
                                          Front_Upload_Attempts__c=0,
                                          Back_Upload_Attempts__c=0,
                                          Selfie_Retry_Attempts__c=2,
                                          Vehicle_Type__c = 'New',
                                          Variant__c = 'SWIFTVDI6',
                                          Lead_Number__c='L-10122021-1685',
                                          Product_Type__c='Passenger Vehicles',
                                          Vehicle_Registration_Number__c = 'PY05J3039', 
                                          Vehicle_Sub_Category__c= 'UIM',
                                         Employee_Name__c='Ravi Kumar',
                                         Employee_No__c='9876543212',
                                         Deal_Number__c = '',
                                         Agent_BL_code__c='MPP');
        if(isInsert){
            insert opp;
        }
        return opp;
    }
       public static Opportunity createTestOpportunityForDealEligible(Boolean isInsert){
        Opportunity opp = new Opportunity( Name= 'Opportunity',
                                          StageName='Prospecting',
                                          CloseDate=System.today().addMonths(1),
                                          OTP_for_borrower__c='99999',
                                          Applicant_Name__c='ayuyu',
                                          Mfr_Expence_Reimburse__c=32, 
                                          Mfr_Expence_Reimburse_Amt__c='6700',
                                          Mfr_Expence_Reimburse_Type__c='yhh' ,
                                          Mfr_Incentive__c=98,
                                          Main_Dealer_Incentive_Amount__c=76,
                                          Sub_Dealer_Ancentive_Amount__c=8798,
                                          DSM_Incentive1__c=767,
                                          DSM_Incentive2__c=65 ,
                                          DSM_Name1__c='bhgb' ,
                                          DSM_Name2__c='hhg', 
                                          Dealer_Disc_to_Customer__c='878',
                                          Dealer_Expence_Reimburse_Type__c='hgfh',
                                          Gift_through_Dealer_Amount__c='866', 
                                          Required_Tenure__c=7,
                                          Non_Dealer_DSM_Name1__c='jhfgh',
                                          Non_Dealer_DSM_Name2__c='jhhf',
                                          Non_Dealer_DSM_Incentive1__c=776, 
                                          Non_Dealer_DSM_Incentive2__c=766,
                                          Required_ROI__c=5,
                                          Service_Charges__c='76',
                                          Parent_Deal_number__c='7878',
                                          Documentation_Charges__c='98',
                                          Stamping_Charges__c='87',
                                          Loan_amount__c='400000',
                                          Contact_number__c = '415.555.1212',
                                          Front_Upload_Attempts__c=0,
                                          Back_Upload_Attempts__c=0,
                                          Selfie_Retry_Attempts__c=2,
                                          Vehicle_Type__c = '1',
                                          Variant__c = 'SWIFTVDI6',
                                          Lead_Number__c='L-10122021-1685',
                                          Product_Type__c='',
                                          Vehicle_Registration_Number__c = 'PY05J3039', 
                                          Vehicle_Sub_Category__c= 'UIM');
        if(isInsert){
            insert opp;
        }
        return opp;
    }
    
    public static Opportunity createTestOpportunityForDeal(Boolean isInsert){
        Opportunity opp = new Opportunity( Name= 'Opportunity',
                                          StageName='Prospecting',
                                          CloseDate=System.today().addMonths(1),
                                          OTP_for_borrower__c='99999',
                                          Applicant_Name__c='ayu',
                                          Mfr_Expence_Reimburse__c=32, 
                                          Mfr_Expence_Reimburse_Amt__c='6700',
                                          Mfr_Expence_Reimburse_Type__c='yhh' ,
                                          Mfr_Incentive__c=98,
                                          Main_Dealer_Incentive_Amount__c=76,
                                          Sub_Dealer_Ancentive_Amount__c=8798,
                                          DSM_Incentive1__c=767,
                                          DSM_Incentive2__c=65 ,
                                          DSM_Name1__c='bhgb' ,
                                          DSM_Name2__c='hhg', 
                                          Deal_Number__c='TUT06226H',
                                          Dealer_Disc_to_Customer__c='878',
                                          Dealer_Expence_Reimburse_Type__c='hgfh',
                                          Gift_through_Dealer_Amount__c='866', 
                                          Required_Tenure__c=7,
                                          Non_Dealer_DSM_Name1__c='jhfgh',
                                          Non_Dealer_DSM_Name2__c='jhhf',
                                          Non_Dealer_DSM_Incentive1__c=776, 
                                          Non_Dealer_DSM_Incentive2__c=766,
                                          Required_ROI__c=5,
                                          Service_Charges__c='76',
                                          Parent_Deal_number__c='7878',
                                          Documentation_Charges__c='98',
                                          Stamping_Charges__c='87',
                                          Loan_amount__c='76777',
                                          Product_Type__c='Two Wheeler',
                                          Contact_number__c = '415.555.1212',
                                          Front_Upload_Attempts__c=0,
                                          Back_Upload_Attempts__c=0,
                                          Selfie_Retry_Attempts__c=2,
                                          Vehicle_Type__c = '1',
                                          Variant__c = 'SWIFTVDI6',
                                          Lead_Number__c='L-10122021-1685',
                                          Customer_Deal_No__c = null );
        if(isInsert){
            insert opp;
        }
        return opp;
    }
    
        public static Opportunity createTestOpportunityForGatingScreening(Boolean isInsert){
        Opportunity opp = new Opportunity( Name= 'Opportunity',
                                          StageName='Prospecting',
                                          CloseDate=System.today().addMonths(1),
                                          OTP_for_borrower__c='99999',
                                          Applicant_Name__c='ayu',
                                          Mfr_Expence_Reimburse__c=32, 
                                          Mfr_Expence_Reimburse_Amt__c='6700',
                                          Mfr_Expence_Reimburse_Type__c='yhh' ,
                                          Mfr_Incentive__c=98,
                                          Main_Dealer_Incentive_Amount__c=76,
                                          Sub_Dealer_Ancentive_Amount__c=8798,
                                          DSM_Incentive1__c=767,
                                          DSM_Incentive2__c=65 ,
                                          DSM_Name1__c='bhgb' ,
                                          DSM_Name2__c='hhg', 
                                          Dealer_Disc_to_Customer__c='878',
                                          Dealer_Expence_Reimburse_Type__c='hgfh',
                                          Gift_through_Dealer_Amount__c='866', 
                                          Required_Tenure__c=7,
                                          Non_Dealer_DSM_Name1__c='jhfgh',
                                          Non_Dealer_DSM_Name2__c='jhhf',
                                          Non_Dealer_DSM_Incentive1__c=776, 
                                          Non_Dealer_DSM_Incentive2__c=766,
                                          Required_ROI__c=5,
                                          Service_Charges__c='76',
                                          Parent_Deal_number__c='7878',
                                          Documentation_Charges__c='98',
                                          Stamping_Charges__c='87',
                                          Loan_amount__c='76777',
                                          Product_Type__c='Two Wheeler',
                                          Contact_number__c = '415.555.1212',
                                          Front_Upload_Attempts__c=0,
                                          Back_Upload_Attempts__c=0,
                                          Selfie_Retry_Attempts__c=2,
                                          Vehicle_Type__c = 'New',
                                          Variant__c = 'SWIFTVDI6',
                                          Lead_Number__c='L-10122021-1685');
        if(isInsert){
            insert opp;
        }
        return opp;
    }
    
       public static Opportunity createTestOpportunityForGatingScreening2(Boolean isInsert){
        Opportunity opp = new Opportunity( Name= 'Opportunity',
                                          StageName='Prospecting',
                                          CloseDate=System.today().addMonths(1),
                                          OTP_for_borrower__c='99999',
                                          Applicant_Name__c='ayu',
                                          Mfr_Expence_Reimburse__c=32, 
                                          Mfr_Expence_Reimburse_Amt__c='6700',
                                          Mfr_Expence_Reimburse_Type__c='yhh' ,
                                          Mfr_Incentive__c=98,
                                          Main_Dealer_Incentive_Amount__c=76,
                                          Sub_Dealer_Ancentive_Amount__c=8798,
                                          DSM_Incentive1__c=767,
                                          DSM_Incentive2__c=65 ,
                                          DSM_Name1__c='bhgb' ,
                                          DSM_Name2__c='hhg', 
                                          Dealer_Disc_to_Customer__c='878',
                                          Dealer_Expence_Reimburse_Type__c='hgfh',
                                          Gift_through_Dealer_Amount__c='866', 
                                          Required_Tenure__c=7,
                                          Non_Dealer_DSM_Name1__c='jhfgh',
                                          Non_Dealer_DSM_Name2__c='jhhf',
                                          Non_Dealer_DSM_Incentive1__c=776, 
                                          Non_Dealer_DSM_Incentive2__c=766,
                                          Required_ROI__c=5,
                                          Service_Charges__c='76',
                                          Parent_Deal_number__c='7878',
                                          Documentation_Charges__c='98',
                                          Stamping_Charges__c='87',
                                          Loan_amount__c='76777',
                                          Product_Type__c='Two Wheeler',
                                          Contact_number__c = '415.555.1212',
                                          Front_Upload_Attempts__c=0,
                                          Back_Upload_Attempts__c=0,
                                          Selfie_Retry_Attempts__c=2,
                                          Vehicle_Type__c = 'New',
                                          Variant__c = 'SWIFTVDI6'
                                          );
        if(isInsert){
            insert opp;
        }
        return opp;
    }
    
            
    public static Opportunity createTestOpportunityforCarwalePricesAPI(Boolean isInsert){
        Opportunity opp = new Opportunity( Name= 'Opportunity',
                                          StageName='Prospecting',
                                          CloseDate=System.today().addMonths(1),
                                          OTP_for_borrower__c='99999',
                                          Applicant_Name__c='ayu',
                                          Mfr_Expence_Reimburse__c=32, 
                                          Mfr_Expence_Reimburse_Amt__c='6700',
                                          Mfr_Expence_Reimburse_Type__c='yhh' ,
                                          Mfr_Incentive__c=98,
                                          Main_Dealer_Incentive_Amount__c=76,
                                          Sub_Dealer_Ancentive_Amount__c=8798,
                                          DSM_Incentive1__c=767,
                                          DSM_Incentive2__c=65 ,
                                          DSM_Name1__c='bhgb' ,
                                          DSM_Name2__c='hhg', 
                                          Dealer_Disc_to_Customer__c='878',
                                          Dealer_Expence_Reimburse_Type__c='hgfh',
                                          Gift_through_Dealer_Amount__c='866', 
                                          Required_Tenure__c=7,
                                          Non_Dealer_DSM_Name1__c='jhfgh',
                                          Non_Dealer_DSM_Name2__c='jhhf',
                                          Non_Dealer_DSM_Incentive1__c=776, 
                                          Non_Dealer_DSM_Incentive2__c=766,
                                          Required_ROI__c=5,
                                          Service_Charges__c='76',
                                          Parent_Deal_number__c='7878',
                                          Documentation_Charges__c='98',
                                          Stamping_Charges__c='87',
                                          Loan_amount__c='76777',
                                          Product_Type__c='Two Wheeler',
                                          Contact_number__c = '415.555.1212',
                                          Front_Upload_Attempts__c=0,
                                          Back_Upload_Attempts__c=0,
                                          Selfie_Retry_Attempts__c=2,
                                          Vehicle_Type__c = '1',
                                          Variant__c = 'SWIFTVDI6',
                                          Lead_Number__c='');
        if(isInsert){
            insert opp;
        }
        return opp;
    }
    
    public static Opportunity createTestOpportunityforCarwalePricesAPI2(Boolean isInsert){
        Opportunity opp = new Opportunity( Name= 'Opportunity',
                                          StageName='Prospecting',
                                          CloseDate=System.today().addMonths(1),
                                          OTP_for_borrower__c='99999',
                                          Applicant_Name__c='ayu',
                                          Mfr_Expence_Reimburse__c=32, 
                                          Mfr_Expence_Reimburse_Amt__c='6700',
                                          Mfr_Expence_Reimburse_Type__c='yhh' ,
                                          Mfr_Incentive__c=98,
                                          Main_Dealer_Incentive_Amount__c=76,
                                          Sub_Dealer_Ancentive_Amount__c=8798,
                                          DSM_Incentive1__c=767,
                                          DSM_Incentive2__c=65 ,
                                          DSM_Name1__c='bhgb' ,
                                          DSM_Name2__c='hhg', 
                                          Dealer_Disc_to_Customer__c='878',
                                          Dealer_Expence_Reimburse_Type__c='hgfh',
                                          Gift_through_Dealer_Amount__c='866', 
                                          Required_Tenure__c=7,
                                          Non_Dealer_DSM_Name1__c='jhfgh',
                                          Non_Dealer_DSM_Name2__c='jhhf',
                                          Non_Dealer_DSM_Incentive1__c=776, 
                                          Non_Dealer_DSM_Incentive2__c=766,
                                          Required_ROI__c=5,
                                          Service_Charges__c='76',
                                          Parent_Deal_number__c='7878',
                                          Documentation_Charges__c='98',
                                          Stamping_Charges__c='87',
                                          Loan_amount__c='76777',
                                          Product_Type__c='Two Wheeler',
                                          Contact_number__c = '415.555.1212',
                                          Front_Upload_Attempts__c=0,
                                          Back_Upload_Attempts__c=0,
                                          Selfie_Retry_Attempts__c=2,
                                          Vehicle_Type__c = '1',
                                          Variant__c = 'SWIFTVDI6',
                                          Lead_Number__c='');
        if(isInsert){
            insert opp;
        }
        return opp;
    }
    
    public static Opportunity createTestOpportunityforVehicleDedupe(Boolean isInsert){
        Opportunity opp = new Opportunity( Name= 'Opportunity',
                                          StageName='Prospecting',
                                          CloseDate=System.today().addMonths(1),
                                          OTP_for_borrower__c='99999',
                                          Applicant_Name__c='ayu',
                                          Mfr_Expence_Reimburse__c=32, 
                                          Mfr_Expence_Reimburse_Amt__c='6700',
                                          Mfr_Expence_Reimburse_Type__c='yhh' ,
                                          Mfr_Incentive__c=98,
                                          Main_Dealer_Incentive_Amount__c=76,
                                          Sub_Dealer_Ancentive_Amount__c=8798,
                                          DSM_Incentive1__c=767,
                                          DSM_Incentive2__c=65 ,
                                          DSM_Name1__c='bhgb' ,
                                          DSM_Name2__c='hhg', 
                                          Dealer_Disc_to_Customer__c='878',
                                          Dealer_Expence_Reimburse_Type__c='hgfh',
                                          Gift_through_Dealer_Amount__c='866', 
                                          Required_Tenure__c=7,
                                          Non_Dealer_DSM_Name1__c='jhfgh',
                                          Non_Dealer_DSM_Name2__c='jhhf',
                                          Non_Dealer_DSM_Incentive1__c=776, 
                                          Non_Dealer_DSM_Incentive2__c=766,
                                          Required_ROI__c=5,
                                          Service_Charges__c='76',
                                          Documentation_Charges__c='98',
                                          Stamping_Charges__c='87',
                                          Loan_amount__c='400000',
                                          Product_Type__c='Two Wheeler',
                                          Contact_number__c = '415.555.1212',
                                          Front_Upload_Attempts__c=0,
                                          Back_Upload_Attempts__c=0,
                                          Selfie_Retry_Attempts__c=2,
                                          Vehicle_Type__c = '1',
                                          Variant__c = 'SWIFTVDI6',
                                          Lead_Number__c='L-10122021-1685',
                                          //Product_Type__c='C',
                                          Vehicle_Registration_Number__c = 'GJ13AM1688',
                                          Category__c = 'N',
                                          Customer_Code__c  = 'CW1330664',
                                          Parent_Deal_number__c = 'GRS00382T',
                                          Vehicle_Sub_Category__c= 'UEB');
        if(isInsert){
            insert opp;
        }
        return opp;
    }
    
    public static Opportunity createTestOpportunityforRunEmiEngineApi(Boolean isInsert){
        Opportunity opp = new Opportunity( Name= 'Opportunity',
                                          StageName='Prospecting',
                                          CloseDate=System.today().addMonths(1),
                                          OTP_for_borrower__c='99999',
                                          Applicant_Name__c='ayu',
                                          Mfr_Expence_Reimburse__c=32, 
                                          Mfr_Expence_Reimburse_Amt__c='6700',
                                          Mfr_Expence_Reimburse_Type__c='yhh' ,
                                          Mfr_Incentive__c=98,
                                          Main_Dealer_Incentive_Amount__c=76,
                                          Sub_Dealer_Ancentive_Amount__c=8798,
                                          DSM_Incentive1__c=767,
                                          DSM_Incentive2__c=65 ,
                                          DSM_Name1__c='bhgb' ,
                                          DSM_Name2__c='hhg', 
                                          Dealer_Disc_to_Customer__c='878',
                                          Dealer_Expence_Reimburse_Type__c='hgfh',
                                          Gift_through_Dealer_Amount__c='866', 
                                          Required_Tenure__c=7,
                                          Non_Dealer_DSM_Name1__c='jhfgh',
                                          Non_Dealer_DSM_Name2__c='jhhf',
                                          Non_Dealer_DSM_Incentive1__c=776, 
                                          Non_Dealer_DSM_Incentive2__c=766,
                                          Required_ROI__c=5,
                                          Service_Charges__c='76',
                                          Parent_Deal_number__c='7878',
                                          Documentation_Charges__c='98',
                                          Stamping_Charges__c='87',
                                          Loan_amount__c='76777',
                                          Product_Type__c='Two Wheeler',
                                          Contact_number__c = '415.555.1212',
                                          Front_Upload_Attempts__c=0,
                                          Back_Upload_Attempts__c=0,
                                          Selfie_Retry_Attempts__c=2,
                                          Lead_Number__c='AC123413_234321243');
        if(isInsert){
            insert opp;
        }
        return opp;
    }
     public static Opportunity createTestOpportunityForEligibleMaster(Boolean isInsert){
        Opportunity opp = new Opportunity( Name= 'Opportunity',
                                          StageName='Prospecting',
                                          CloseDate=System.today().addMonths(1),
                                          OTP_for_borrower__c='99999',
                                          Applicant_Name__c='ayu',
                                          Mfr_Expence_Reimburse__c=32, 
                                          Mfr_Expence_Reimburse_Amt__c='6700',
                                          Mfr_Expence_Reimburse_Type__c='yhh' ,
                                          Mfr_Incentive__c=98,
                                          Main_Dealer_Incentive_Amount__c=76,
                                          Sub_Dealer_Ancentive_Amount__c=8798,
                                          DSM_Incentive1__c=767,
                                          DSM_Incentive2__c=65 ,
                                          DSM_Name1__c='bhgb' ,
                                          DSM_Name2__c='hhg', 
                                          Dealer_Disc_to_Customer__c='878',
                                          Dealer_Expence_Reimburse_Type__c='hgfh',
                                          Gift_through_Dealer_Amount__c='866', 
                                          Required_Tenure__c=7,
                                          Non_Dealer_DSM_Name1__c='jhfgh',
                                          Non_Dealer_DSM_Name2__c='jhhf',
                                          Non_Dealer_DSM_Incentive1__c=776, 
                                          Non_Dealer_DSM_Incentive2__c=766,
                                          Required_ROI__c=5,
                                          Service_Charges__c='76',
                                          Parent_Deal_number__c='',
                                          Documentation_Charges__c='98',
                                          Stamping_Charges__c='87',
                                          Loan_amount__c='76777',
                                          Product_Type__c='Two Wheeler',
                                          Contact_number__c = '415.555.1212',
                                          Front_Upload_Attempts__c=0,
                                          Back_Upload_Attempts__c=0,
                                          Selfie_Retry_Attempts__c=2,
                                          Vehicle_Type__c = 'New',
                                          Variant__c = 'SWIFTVDI6',
                                          Lead_Number__c='L-10122021-1685');
        if(isInsert){
            insert opp;
        }
        return opp;
    }
 public static Applicant__c createTestApplicantForDSA(Boolean isInsert,Opportunity opp){

         Applicant__c app =new Applicant__c(Name='test',
                                           Contact_Number__c ='1234567891',
                                           Customer_First_Name__c='GOURAB',
                                           Customer_Last_Name__c='GOSWAMI',
                                           Whatsapp_number__c='1231231231',
                                           Consent_Received__c=true,
                                           Opportunity__c = opp.Id,
                                            Income_Ca__c='SAL',
                                            Profile__c = 'Software Engineer',
                                            Bureau_Pull_Attempts__c=1,
                                            Selfie_Retry_Attempts__c=2,
                                            Income_Source__c='Non-Earning',
                                            Income_source_available__c = true,
                                            Preferred_address_for_communication__c = 'Permanent Address',
                                            of_family_members_residing_with_you__c = '2',
                                            Residence_country__c = 'India',
                                            Who_will_repay_the_loan__c = 'Borrower',
                                            Marital_status__c = 'SINGP',
                                            Spouse_Name__c = 'Sameer',
                                            Father_s_name__c = 'Viraa',
                                            Mother_s_name__c = 'Neeta',
                                            Communication_language__c = 'Hindi',
                                            Customer_Qualification__c = 'Bachelor of Arts',
                                            Email_Id__c = 'riya@gmail.com',
                                            DocAuth_Application_Id__c = 'AC1241_24524353_g1',
                                            Applicant_Type__c ='Borrower',
                                            In_Active_Applicant__c = false,
                                            Office_PinCode__c = '302018',
                                            Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-4));



         if(isInsert){
            insert app;
        }
        return app;
    }

    public static Applicant__c createTestApplicantService(Boolean isInsert){

         Applicant__c app =new Applicant__c(Name='test',
                                           Contact_Number__c ='1234567891',
                                           Customer_First_Name__c='GOURAB',
                                           Customer_Last_Name__c='GOSWAMI',
                                           Whatsapp_number__c='1231231231',
                                           Consent_Received__c=true,
                                           Opportunity__c = '00671000001E0PNAA0',
                                            Income_Ca__c='SAL',
                                            Profile__c = 'Software Engineer',
                                            Bureau_Pull_Attempts__c=1,
                                            Selfie_Retry_Attempts__c=2,
                                            Income_Source__c='Non-Earning',
                                            Income_source_available__c = true,
                                            Preferred_address_for_communication__c = 'Permanent Address',
                                            of_family_members_residing_with_you__c = '2',
                                            Residence_country__c = 'India',
                                            Who_will_repay_the_loan__c = 'Borrower',
                                            Marital_status__c = 'SINGP',
                                            Spouse_Name__c = 'Sameer',
                                            Father_s_name__c = 'Viraa',
                                            Mother_s_name__c = 'Neeta',
                                            Communication_language__c = 'Hindi',
                                            Customer_Qualification__c = 'B2',
                                            Email_Id__c = 'riya@gmail.com',
                                            DocAuth_Application_Id__c = 'AC1241_24524353_g1',
                                            Applicant_Type__c ='Borrower',
                                            Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-4));
        
                                    
                                            
         if(isInsert){
            insert app;
        }
        return app;
    }
    
    public static Applicant__c createTestApplicant(Boolean isInsert){
        
         Applicant__c app =new Applicant__c(Name='test',
                                           Contact_Number__c ='1234567891',
                                           Customer_First_Name__c='GOURAB',
                                           Customer_Last_Name__c='GOSWAMI',
                                           Whatsapp_number__c='1231231231',
                                           Consent_Received__c=true,
                                            Income_Ca__c='SAL',
                                            Profile__c = 'Software Engineer',
                                            Bureau_Pull_Attempts__c=1,
                                            Selfie_Retry_Attempts__c=2,
                                            Income_Source__c='Non-Earning',
                                            Income_source_available__c = true,
                                            Preferred_address_for_communication__c = 'Permanent Address',
                                            of_family_members_residing_with_you__c = '2',
                                            Residence_country__c = 'India',
                                            Who_will_repay_the_loan__c = 'Borrower',
                                            Marital_status__c = 'SINGP',
                                            Spouse_Name__c = 'Sameer',
                                            Father_s_name__c = 'Viraa',
                                            Mother_s_name__c = 'Neeta',
                                            Communication_language__c = 'Hindi',
                                            Customer_Qualification__c = 'B2',
                                            Email_Id__c = 'riya@gmail.com',
                                            PAN_No__c ='BNIPM6633A',
                                            DocAuth_Application_Id__c = 'AC1241_24524353_g1',
                                            Applicant_Type__c ='Borrower',
                                            Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-4));
        
                                    
                                            
         if(isInsert){
            insert app;
        }
        return app;
    }
    
    public static Applicant__c createTestApplicant2(Boolean isInsert){
        
         Applicant__c app =new Applicant__c(Name='test',
                                           Contact_Number__c ='1234567891',
                                           Customer_First_Name__c='GOURAB',
                                           Customer_Last_Name__c='GOSWAMI',
                                           Whatsapp_number__c='1231231231',
                                           Consent_Received__c=true,
                                            Income_Ca__c='SAL',
                                            Profile__c = 'Software Engineer',
                                            Bureau_Pull_Attempts__c=1,
                                            Selfie_Retry_Attempts__c=2,
                                            Income_Source__c='Non-Earning',
                                            Income_source_available__c = true,
                                            Preferred_address_for_communication__c =  'Permanent Address',
                                            of_family_members_residing_with_you__c = '2',
                                            Residence_country__c = 'India',
                                            Who_will_repay_the_loan__c = 'Borrower',
                                            Marital_status__c = 'SINGP',
                                            Spouse_Name__c = 'Sameer',
                                            Father_s_name__c = 'Viraa',
                                            Mother_s_name__c = 'Neeta',
                                            Communication_language__c = 'Hindi',
                                            Customer_Qualification__c = 'Bachelor of Arts',
                                            Email_Id__c = 'riya@gmail.com',
                                            DocAuth_Application_Id__c = '',
                                            
                                            Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-4));
        
                                    
                                            
         if(isInsert){
            insert app;
        }
        return app;
    }
    
     public static Applicant__c createTestApplicantAMLCheck(Boolean isInsert){
        
         Applicant__c app =new Applicant__c(Name='test',
                                           Contact_Number__c ='1234567891',
                                           Customer_First_Name__c='GOURAB',
                                           Customer_Last_Name__c='GOSWAMI',
                                           Whatsapp_number__c='1231231231',
                                           Consent_Received__c=true,
                                            Income_Ca__c='SAL',
                                            Profile__c = 'Software Engineer',
                                            Bureau_Pull_Attempts__c=1,
                                            Selfie_Retry_Attempts__c=2,
                                            Income_Source__c='Non-Earning',
                                            Income_source_available__c = true,
                                            Preferred_address_for_communication__c = 'Home',
                                            of_family_members_residing_with_you__c = '2',
                                            Residence_country__c = 'India',
                                            Who_will_repay_the_loan__c = 'Borrower',
                                            Marital_status__c = 'SINGP',
                                            Spouse_Name__c = 'Sameer',
                                            Father_s_name__c = 'Viraa',
                                            Mother_s_name__c = 'Neeta',
                                            Communication_language__c = 'Hindi',
                                            Customer_Qualification__c = 'Bachelor of Arts',
                                            Email_Id__c = 'riya@gmail.com',
                                            DocAuth_Application_Id__c = 'AC12313244_13423',
                                            
                                            Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-4));
        
                                    
                                            
         if(isInsert){
            insert app;
        }
        return app;
    }
    
    public static Applicant__c createTestApplicantImage(Boolean isInsert){
        
         Applicant__c app =new Applicant__c(Name='test',
                                           Contact_Number__c ='1234567891',
                                           Customer_First_Name__c='GOURAB',
                                           Customer_Last_Name__c='GOSWAMI',
                                           Whatsapp_number__c='1231231231',
                                           Consent_Received__c=true,
                                            Income_Ca__c='SAL',
                                            Profile__c = 'Software Engineer',
                                            Bureau_Pull_Attempts__c=1,
                                            Selfie_Retry_Attempts__c=2,
                                            Income_Source__c='Non-Earning',
                                            Income_source_available__c = true,
                                            Preferred_address_for_communication__c = 'Home',
                                            of_family_members_residing_with_you__c = '2',
                                            Residence_country__c = 'India',
                                            Who_will_repay_the_loan__c = 'Borrower',
                                            Marital_status__c = 'SINGP',
                                            Spouse_Name__c = 'Sameer',
                                            Father_s_name__c = 'Viraa',
                                            Mother_s_name__c = 'Neeta',
                                            Communication_language__c = 'Hindi',
                                            Customer_Qualification__c = 'Bachelor of Arts',
                                            Email_Id__c = 'riya@gmail.com',
                                            DocAuth_Application_Id__c = '',
                                            
                                            Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-4));
        
                                    
                                            
         if(isInsert){
            insert app;
        }
        return app;
    }
    
    
    public static Applicant__c createTestApplicantForDocAuth(Boolean isInsert){
        
         Applicant__c app =new Applicant__c(Name='test',
                                           Contact_Number__c ='1234567891',
                                           Customer_First_Name__c='GOURAB',
                                           Whatsapp_number__c='1231231231',
                                           Consent_Received__c=true,
                                            Income_Ca__c='SAL',
                                            Profile__c = 'Software Engineer',
                                            Bureau_Pull_Attempts__c=1,
                                            Selfie_Retry_Attempts__c=2,
                                            Income_Source__c='Non-Earning',
                                            Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-4));
                                            
         if(isInsert){
            insert app;
        }
        return app;
    }
    
    public static Applicant__c createTestApplicantForDocAuth2(Boolean isInsert){
        
         Applicant__c app =new Applicant__c(Name='test',
                                           Contact_Number__c ='1234567891',
                                           Customer_Last_Name__c='GOSWAMI',
                                           Whatsapp_number__c='1231231231',
                                           Consent_Received__c=true,
                                            Income_Ca__c='SAL',
                                            Profile__c = 'Software Engineer',
                                            Bureau_Pull_Attempts__c=1,
                                            Selfie_Retry_Attempts__c=2,
                                            Income_Source__c='Non-Earning',
                                            Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-4));
                                            
         if(isInsert){
            insert app;
        }
        return app;
    }
    
     public static Applicant__c createTestApplicantForGatingScreening(Boolean isInsert){
        
         Applicant__c app =new Applicant__c(Name='test',
                                           Contact_Number__c ='1234567891',
                                           Customer_First_Name__c='GOURAB',
                                           Whatsapp_number__c='1231231231',
                                           Consent_Received__c=true,
                                            Income_Ca__c='SAL',
                                            Profile__c = 'Software Engineer',
                                            Bureau_Pull_Attempts__c=1,
                                            Selfie_Retry_Attempts__c=2,
                                            Income_Source__c='Non-Earning',
                                            Declared_income__c=45000,
                                            Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-4));
                                            
         if(isInsert){
            insert app;
        }
        return app;
    }

         public static Applicant__c createTestApplicantForGatingScreening2(Boolean isInsert){
        
         Applicant__c app =new Applicant__c(Name='test',
                                           Contact_Number__c ='1234567891',
                                           Customer_First_Name__c='GOURAB',
                                           Whatsapp_number__c='1231231231',
                                           Consent_Received__c=true,
                                            Income_Ca__c='SAL',
                                            Profile__c = 'Software Engineer',
                                            Bureau_Pull_Attempts__c=1,
                                            Selfie_Retry_Attempts__c=2,
                                            Income_Source__c='Non-Earning',
                                            Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-4));
                                            
         if(isInsert){
            insert app;
        }
        return app;
    }
    
     public static Applicant__c createTestApplicantForGatingScreeningCoborrower(Boolean isInsert){
        
         Applicant__c app =new Applicant__c(Name='test',
                                           Contact_Number__c ='1234567891',
                                           Customer_First_Name__c='GOURAB',
                                           Whatsapp_number__c='1231231231',
                                           Consent_Received__c=true,
                                            Income_Ca__c='SAL',
                                            Profile__c = 'Software Engineer',
                                            Bureau_Pull_Attempts__c=1,
                                            Selfie_Retry_Attempts__c=2,
                                            Income_Source__c='Non-Earning',
                                            Declared_income__c=45000,
                                            Applicant_Type__c='Co-borrower',
                                            Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-4));
                                            
         if(isInsert){
            insert app;
        }
        return app;
    }

    
        public static Applicant__c createTestApplicantForPassport(Boolean isInsert){
        
         Applicant__c app =new Applicant__c(Name='test',
                                           Contact_Number__c ='1234567891',
                                           Customer_First_Name__c='Dwarakesh',
                                           Customer_Last_Name__c=' Rajagopalan',
                                           Whatsapp_number__c='1231231231',
                                           Consent_Received__c=true,
                                            Income_Ca__c='SAL',
                                            Profile__c = 'Software Engineer',
                                            Bureau_Pull_Attempts__c=1,
                                            Selfie_Retry_Attempts__c=2,
                                            Income_Source__c='Non-Earning',
                                            Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-4));
                                            
         if(isInsert){
            insert app;
        }
        return app;
    }
    
            public static Applicant__c createTestApplicantForPassport2(Boolean isInsert){
        
         Applicant__c app =new Applicant__c(Name='test',
                                           Contact_Number__c ='1234567891',
                                           Customer_First_Name__c='Dwarakesh',
                                           Whatsapp_number__c='1231231231',
                                           Consent_Received__c=true,
                                            Income_Ca__c='SAL',
                                            Profile__c = 'Software Engineer',
                                            Bureau_Pull_Attempts__c=1,
                                            Selfie_Retry_Attempts__c=2,
                                            Income_Source__c='Non-Earning',
                                            Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-4));
                                            
         if(isInsert){
            insert app;
        }
        return app;
    }
    
            public static Applicant__c createTestApplicantForPassport3(Boolean isInsert){
        
         Applicant__c app =new Applicant__c(Name='test',
                                           Contact_Number__c ='1234567891',
                                           Customer_Last_Name__c=' Rajagopalan',
                                           Whatsapp_number__c='1231231231',
                                           Consent_Received__c=true,
                                            Income_Ca__c='SAL',
                                            Profile__c = 'Software Engineer',
                                            Bureau_Pull_Attempts__c=1,
                                            Selfie_Retry_Attempts__c=2,
                                            Income_Source__c='Non-Earning',
                                            Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-4));
                                            
         if(isInsert){
            insert app;
        }
        return app;
    }
    
     public static Applicant__c createTestApplicantForVoterId(Boolean isInsert){
        
         Applicant__c app =new Applicant__c(Name='test',
                                           Contact_Number__c ='9402615811',
                                           Customer_First_Name__c='DREMA',
                                             Customer_Last_Name__c='TAWANG',
                                           Whatsapp_number__c='1231231231',
                                           Consent_Received__c=true,
                                            Income_Ca__c='SAL',
                                            Profile__c = 'Software Engineer',
                                            Bureau_Pull_Attempts__c=1,
                                            Selfie_Retry_Attempts__c=2,
                                            Income_Source__c='Non-Earning',
                                            Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-4));
                                            
         if(isInsert){
            insert app;
        }
        return app;
    }
    
     public static Applicant__c createTestApplicantForVoterId2(Boolean isInsert){
        
         Applicant__c app =new Applicant__c(Name='test',
                                            Customer_First_Name__c='DREMA',
                                             Customer_Last_Name__c='TAWANG',
                                           Whatsapp_number__c='1231231231',
                                           Consent_Received__c=true,
                                            Income_Ca__c='SAL',
                                            Profile__c = 'Software Engineer',
                                            Bureau_Pull_Attempts__c=1,
                                            Selfie_Retry_Attempts__c=2,
                                            Income_Source__c='Non-Earning',
                                            Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-4));
                                            
         if(isInsert){
            insert app;
        }
        return app;
    }
    
     public static Applicant__c createTestApplicantForSMS(Boolean isInsert){
        
         Applicant__c app =new Applicant__c(Name='test',
                                           Contact_Number__c ='3232323232',
                                           Customer_First_Name__c='GOURAB',
                                           Customer_Last_Name__c='GOSWAMI',
                                           Whatsapp_number__c='1231231231',
                                           Consent_Received__c=true,
                                            Income_Ca__c='SAL',
                                            Profile__c = 'Software Engineer',
                                            Bureau_Pull_Attempts__c=1,
                                            Selfie_Retry_Attempts__c=2,
                                            Income_Source__c='Non-Earning',
                                            Preferred_address_for_communication__c = 'Permanent Address',
                                            of_family_members_residing_with_you__c = '2',
                                            Residence_country__c = 'India',
                                            Who_will_repay_the_loan__c = 'Borrower',
                                            Marital_status__c = 'SINGP',
                                            Spouse_Name__c = 'Sameer',
                                            Father_s_name__c = 'Viraa',
                                            Mother_s_name__c = 'Neeta',
                                            Communication_language__c = 'Hindi',
                                            Customer_Qualification__c = 'B2',
                                            Email_Id__c = 'riya@gmail.com',
                                            OTP_for_borrower__c='9999',
                                            Loan_amount__c = 50000,
                                            Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-4));
                                            
         if(isInsert){
            insert app;
        }
        return app;
    }

    public static Applicant__c createTestApplicantForLTV(Boolean isInsert){

        Applicant__c app =new Applicant__c(Name='test',
                                           Contact_Number__c ='9876543456',
                                           Customer_First_Name__c='GOURAB',
                                           Customer_Last_Name__c='GOSWAMI',
                                           Whatsapp_number__c='1231231231',
                                           Consent_Received__c=true,
                                            Income_Ca__c='SAL',
                                            Profile__c = 'Software Engineer',
                                            Bureau_Pull_Attempts__c=1,
                                            Selfie_Retry_Attempts__c=2,
                                            Income_Source__c='Non-Earning',
                                            Preferred_address_for_communication__c = 'Permanent Address',
                                            of_family_members_residing_with_you__c = '2',
                                            Residence_country__c = 'India',
                                            Who_will_repay_the_loan__c = 'Borrower',
                                            Marital_status__c = 'SINGP',
                                            Spouse_Name__c = 'Sameer',
                                            Father_s_name__c = 'Viraa',
                                            Mother_s_name__c = 'Neeta',
                                            Communication_language__c = 'Hindi',
                                            Customer_Qualification__c = 'Bachelor of Arts',
                                            Email_Id__c = 'riya@gmail.com',
                                            OTP_for_borrower__c='9999',
                                            Loan_amount__c = 50000,
                                            Applicant_Type__c ='Borrower',
                                            Scorecard_Decision__c = 'Dark Green',
                                            Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-4));

        if (isInsert) {
            insert app;
        }
        return app;
    }
    public static Applicant__c createTestApplicantForOfferEngine(Boolean isInsert){

        Applicant__c app =new Applicant__c(Name='test',
                                           Contact_Number__c ='9876543456',
                                           Customer_First_Name__c='GOURAB',
                                           Customer_Last_Name__c='GOSWAMI',
                                           Whatsapp_number__c='1231231231',
                                           Consent_Received__c=true,
                                           Declared_income__c = 2000000,
                                            Income_Ca__c='SAL',
                                            Profile__c = 'Software Engineer',
                                            Bureau_Pull_Attempts__c=1,
                                            Selfie_Retry_Attempts__c=2,
                                            Income_Source__c='Non-Earning',
                                            Preferred_address_for_communication__c = 'Permanent Address',
                                            of_family_members_residing_with_you__c = '2',
                                            Residence_country__c = 'India',
                                            Who_will_repay_the_loan__c = 'Borrower',
                                            Marital_status__c = 'SINGP',
                                            Spouse_Name__c = 'Sameer',
                                            Father_s_name__c = 'Viraa',
                                            Mother_s_name__c = 'Neeta',
                                            Communication_language__c = 'Hindi',
                                            Customer_Qualification__c = 'Bachelor of Arts',
                                            Email_Id__c = 'riya@gmail.com',
                                            OTP_for_borrower__c='9999',
                                            Loan_amount__c = 50000,
                                            Applicant_Type__c ='Borrower',
                                            Scorecard_Decision__c = 'Dark Green',
                                            Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-4));

        if (isInsert) {
            insert app;
        }
        return app;
    }

     public static Applicant__c createTestApplicantForSMSnesl(Boolean isInsert){

         Applicant__c app =new Applicant__c(Name='test',
                                           Contact_Number__c ='9701498575',
                                           Customer_First_Name__c='GOURAB',
                                           Customer_Last_Name__c='GOSWAMI',
                                           Whatsapp_number__c='9701498522',
                                           Consent_Received__c=true,
                                            Income_Ca__c='SAL',
                                            Profile__c = 'Software Engineer',
                                            Bureau_Pull_Attempts__c=1,
                                            Selfie_Retry_Attempts__c=2,
                                            Income_Source__c='Non-Earning',
                                            Preferred_address_for_communication__c = 'Permanent Address',
                                            of_family_members_residing_with_you__c = '2',
                                            Residence_country__c = 'India',
                                            Who_will_repay_the_loan__c = 'Borrower',
                                            Marital_status__c = 'SINGP',
                                            Spouse_Name__c = 'Sameer',
                                            Father_s_name__c = 'Viraa',
                                            Mother_s_name__c = 'Neeta',
                                            Communication_language__c = 'Hindi',
                                            Customer_Qualification__c = 'B2',
                                            Email_Id__c = 'riya@gmail.com',
                                            OTP_for_borrower__c='9999',
                                            Loan_amount__c = 50000,
                                            Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-4));
                                            
         if(isInsert){
            insert app;
        }
        return app;
    }
    
public static Applicant__c createTestApplicantForUidaiBiometric(Boolean isInsert){
        
         Applicant__c app =new Applicant__c(Name='test',
                                           Contact_Number__c ='3232323232',
                                           Customer_First_Name__c='GOURAB',
                                           Customer_Last_Name__c='GOSWAMI',
                                           Whatsapp_number__c='1231231231',
                                           Consent_Received__c=true,
                                            Income_Ca__c='SAL',
                                            Profile__c = 'Software Engineer',
                                            Bureau_Pull_Attempts__c=1,
                                            Selfie_Retry_Attempts__c=2,
                                            Income_Source__c='Non-Earning',
                                            Preferred_address_for_communication__c = 'Permanent Address',
                                            of_family_members_residing_with_you__c = '2',
                                            Residence_country__c = 'India',
                                            Who_will_repay_the_loan__c = 'Borrower',
                                            Marital_status__c = 'SINGP',
                                            Spouse_Name__c = 'Sameer',
                                            Father_s_name__c = 'Viraa',
                                            Mother_s_name__c = 'Neeta',
                                            Communication_language__c = 'Hindi',
                                            Customer_Qualification__c = 'B2',
                                            Email_Id__c = 'riya@gmail.com',
                                            OTP_for_borrower__c='9999',
                                            PID_Block__c='<PidData><Resp errCode="0" errInfo="Image Capture Success" fCount="1" fType="1" iCount="-1" iType="-1" pCount="-1" pType="-1" nmPoints="-1" qScore="-1"/><DeviceInfo dpId="PRECISION.PB" rdsId="PRECISION.AND.001" rdsVer="1.2.3" dc="d8507b94-6000-439c-a17a-ddb1f5688474" mi="PB510" mc="MIIEGDCCAwCgAwIBAgIIX9XM7YVOAe0wDQYJKoZIhvcNAQELBQAwgewxNzA1BgNVBAMTLkRTIFBSRUNJU0lPTiBCSU9NRVRSSUMgSU5ESUEgUFJJVkFURSBMSU1JVEVEIDMxJjAkBgNVBDMTHU5PIDIyIEhBQklCVUxMQUggUk9BRCBUIE5BR0FSMRAwDgYDVQQJEwdDSEVOTkFJMRIwEAYDVQQIEwlUQU1JTE5BRFUxIjAgBgNVBAsTGVNPTFVUSU9OIERFVkVMT1BNRU5UIFRFQU0xMjAwBgNVBAoTKVBSRUNJU0lPTiBCSU9NRVRSSUMgSU5ESUEgUFJJVkFURSBMSU1JVEVEMQswCQYDVQQGEwJJTjAeFw0yMjAxMDUxMDQ3NDRaFw0yMjAyMDQxMDQ3NDRaMG4xMjAwBgNVBAoMKVByZWNpc2lvbiBCaW9tZXRyaWMgSW5kaWEgUHJpdmF0ZSBMaW1pdGVkMRIwEAYDVQQLDAlCaW9tZXRyaWMxEDAOBgNVBAcMB0NIRU5OQUkxEjAQBgNVBAMMCVByZWNpc2lvbjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALhS2PN+o+VaEALq32ZWSLYl4C63GdgzRmYY6DitnZ/CRVxSKQy1c2v0VnaLd7w5jTmJYrqp5BMEZoWxLf+M6EeowpRU8/0SmLUVR7NtdcTXI4obPK/dx93kVoV824UTvv0pc1HQmH95+oGKacePGYyo0HTNFGOLJTG4qSpFe/mBNf7EiwboLSWOoRBhk0bSrRhZ4/+N2iiGURxY3WTF7QkgR6teB89iHwdnuFmiJ32h8FxszwVYBvjjSDmCCKB7/DZkDP0mZhH6dwGroFIbxhxACdKalc8uxFVMj2pDnpU9LTeGEyscaYfuPZB8UqWWxK3eUfLXAW6qYO3foTjSDW8CAwEAAaM7MDkwCQYDVR0TBAIwADALBgNVHQ8EBAMCAYYwHwYDVR0jBBgwFoAUtTWwpFcL+TBx63TcMhe9Ih9zKGcwDQYJKoZIhvcNAQELBQADggEBAIETQlDPJMWFJVsh0En75hDlmefshHgvkck3xtwYP96gLKYyP8T4x3RhMF9fLdvmVtw3bjumVTqzEHPg6m3lHh/bqUErNwxLjsslwzSkqdANSOBPzRS1JLIxHBjINn4+SCn2p4KVDhZskJVvVBstp4Py8THqxQWeAatWRC9PWbY+EMrD7BQdnZTPPtKzzUsubGbYZgUPYhwgWvVBMSWApr9NQFp7dJ7M4xe2wQ0tkZ79DqTqBAUc/S3E1uX/B9AcNQ2YBWEVKgSAg0sAswR82PMMdrYJ1XvnvgkyxS6HG9FA9pSXDAAPBsZZD5nBlgtp961D1xk89zCNb36elca4tLU="><additional_info><Param name="srno" value="EAC9026AZRFE41912380"/><Param name="sysid" value=""/><Param name="ts" value="2022-01-07T13:23:32+05:30"/><Param name="Locking" value="N"/></additional_info></DeviceInfo><Skey ci="20221023">P2w5jft8aDBRkqeS0K6Pxf1ooOnLCiO6exguUxVRO94UVtN1Dy6prLC7u69HB0J+xyfC78OlHH4pi4z6hwYAXdRdHhE1LSXqs7E7Rmq0l/U3bu0t2xEtfSDesZyr9MHFUyn0MfMHP4Lr1MZbHAJw3ClhXKFAxO7JmETdAeGfM3MV8zysQiNRgab04yooKwRIUpm456djHpuOd+7Ego0IfDyTiF6zy4VMofnwnuu4ch0HcKsgfJVExXXykyqntPV4v2CRC1qKPMX4OUvmFdjs6fpPOGusWmHau63+c3mxq7Ng8HAzgvko8P8SlEievEXTChPBi84rbepS41CDo0Jlmg==</Skey><Hmac>sMkeckTATsnw6m5fovSNrgG+B1nv+lA9GwmzFurh8n/hQwZ6u1FY81xU7kP0QN/3</Hmac><Data type="X">MjAyMi0wMS0wN1QxMzoyMzozMV8ZRkx+c2OGqZrLSApGd8JMTpyh+919P27z8pPklRBS+cxUxZwcc6RtcLTntL24rJuXvfs1aEfBuYgbpolNuA4AiFNuyvrSrD35cpLQPj6LeboTG4JbctV5Qp9GAk+vSR0bG09sH9Ccgc8Qgl4gD2wTWED1HzJ/iJqCGPjdOyrjTQSCaT9XOVMZIU7w2dGbzyeQIwtmu8nDBMhEwneuHrddRgT/JMHnYrZukWWCrYSC/Alccmb6P6Pz0GhQiZsTkkvs/l/s66muoFBCRpjKqsQ0GmL9Mi4wDNPpFuQpmXBbEUhCj+EVW0gpEASZREpjetfSTxyxyosLEpc6U8JpHw6YSxP5GBejy1rEfQsM3zUgFiEjHlhFK8DZA8m1k9Gg5qX8+20csbnbIv6JmZBQP1x0C+msET6zh/RAIjTPl9gpUcBOj+F3adsg5BpftLNrSTIZyLlwa2C1x7E4DwVd/T/yzymf/BiY4ogEeHmlBL6Xh4DyqxvRNBKTcemlTVxDDeknuzV9uLHmbvAre5ArrUrAU/9QGUV8Lqt352WbrxGBI8vYWqo9S1tSrdCF+FwE4+jKyoaumU4urDOkX3Hmy2oMs0k13c1P2C2q7DLFNC28pAafjYOuBwhA7qvz//kChPrbhgqDgX0ZgNC9XxnTv0qV/uR/aPIMk3TtjQuLtQvTHr1AMEPdUqTbZA5RRT2y3YNqz36O3N49WAi4B0haGo5CcQatRkcWfiqdUtf/KTBbjKQMV8oXaI6x3uqKL38z81PX/JJ5avYGfXWQYyjbdnfjxvc63+lsSXzdewDuwDUoUDqIOD+t2fSj/AH487zSSA2rSmmeymITndU4Hk0G6TmAYPWaWU4oCx22Ys3nfby8yzxlhoF7o5sl3xJoFNH00BA9Q4OFKh7xuAR5SolfA0adj3Gy6ITRdzxNxAuilp3LSzK5kmYg+gB4FJ0lOFzMR0YpAmnG2Awnh28X2RfaONLp1rWOqgxl953haJjI5JezqmPwP5AgAAZDfIdWsO++/09x324D+e6X4gWdcq/oAXBnjrQ7VZD2UcR9fhfYVU+Bnr1AkbB3mrh3Kc1kuD+Vu/oQwS8l1bwJYnaHFM8ydvt/pkVg1XNUKo05UvOQwPItbYpYtCDUty1t+3qSSwvN40POzlBluNV9JvLlSo/ggykhDdR1hzlTnpMcyrqj8V0bpXj90/dPkfxLoa+xRx+ObEn/05i1AGDT9Zv10cTRUuKW0lVjjwHkXPF08Q9QalCvZjqyBkQJGJ6/ueZDTbKMH9h60d6MI6sMU1/XLeUf1n12JXF/MezGmxrmHzZ6+X+teLaU3skgKBwlGvHQ0Yq2lAoLl9jHS8+z09nP44jh5675d9u2u2JIa/S483AZD2/lvHPc8ArKbGQiNZ1aMs2j1JmHW+z42m5o1KiKzMpDvkggmPTEE7aUJBKOn/OyyMJw+u6qSPx+ZC1pExUeABeZ7EE80ww8axLzSRKg59P1kfDja3nHJBxCELPGGTTS+R3NpWQMpDH6JU8kk1z9POson/YJ5YWgJAm+kKC4ptq64rQKJDwmBVlQweWegy7fhLuibMLosU8hFdgj/r6VsArDBhcEIRG7JzjZQ+B5DgfV9HTMuzv1zldYLd142t81IKzZOWu7vDN5sjcbQNQQooJfAaqH/WyScDuNzjpvn6o/13kiO30JmnT/HbUf/hfAOzySjbqE59YEeI9Y1DqbGQ6tfwG6KA2+K9/p4uggj5t+NfiWqle6hqLfPA/1vry3Yjk7DLdaTP7gopZH+55Rbn5MAbK+nrVwtCVhYcZtTieJb+hrOwjZLYjkvasMCFcto0hBdEb2hdvyobjwswP2HZ7SlwnBPDVbCI17W8KH5p3PcfxkWKiDzngg95ap/YvJOQocgEOyU+HBvz/aG2ApqcVMV1YrH9I05cLz6maJC+J3x1CayAk4B6sw1TB5xlJWPfBGt46c+WvPi2kM5e9yEMVtNvxVzzBJh+JAReOcs3S/R1tEbcCk1h5t8FSjQYa0yKC0PuHv2C3k5kJCWntnQ5VQVjsmTsnF78m2o4EqRQ85TJObK/HKGrUrOWIL++W+OzrNDc/rPKTExi47VW48Di57kP4ne4VGkes0Ke8N60HGkZssSoSuhpKoYEejyhEqBYHLhRnoDTNNE5njH+aDwq+carkiiUAsDlopezlAoM20UKJTmUa+5a7le9wGfefkaV5QoEQNhU3I7xtFemy924LbXE3S26IuvW+IpY/mmOTQVCcprLA7ObO4ctS4b1JLCIGbTXjMpnEzJey+B1DBmjTnF4VxiD6O832k6whpke7/NxEBqO1weeqqrgP8t/4s9Ee8CQvjQknTGbLbtt55p/lqAMzMAS2TiKdugFYV/SGpoHxZ55A17uNkR1DJt48ywj2bVLfNUHUM7hebYQ9w3lYU+zzOVbD0YFVAAG3WwYEDHQSLliONo2icb5VvdrX47Y5M5ANEIOWuXnPMuYdX+YjFxEZ3EE2EOQLy9POMqunlPGx800R44UJplUv5k3QjI4xa7SsMsukEGBQ+JWbRV8dXbXbajtrHlg4CotlgZC0+w0NbeAXF9tqulPXfF81BDh02uQj9DS4VX/Hazw6w5pF+3JzCcJRbNOHLvS0ZzZAgQt4oefHsj46RQWjezxTl7KlEsGdfm7wdU7NLvnPh+nApwiSABtwfL2AQzdhEms2PMZuH+r9Ju8lmyqLVNZosICMvH1Z3V8kVSd4BLrsk9YrdFtM54FdGRS3ceKZVKpHrZ/1jOrWxI08wj3ksqV7kdGVJ2X30yrClP77hEPJGiKztM6GzJ3cA7rKl0vmMqQzxOJ6yITQiRkiT/SKmnS+HgTlPLOwkmdxwx70r4IBEKIfYfCmpV0uLNCnGdKnTXEaKFvW1z9ISIVDsMhSguISTb1cTimUVGBRr0oQZ1/yPg4aW/ghi+sPzbNbtBfMINEjfE8uTTeGmf2LMqVHLnyxyp9eNfVSvbVOaUy70vxZqNENM1aV1T+lgHknCznOSgPKBPcY7lXlp3gsp9HCvcrVAC0/pDwdNTgkpayPe5QurpL/mOGHKoEEQkfV27yuDiA9iUXaxF8tJo8DPoNECudxSDNPItUWHRxxGxm4lDeJ1qmA5FMXf+ccTgGNpha3YKTJawgs4Cnck/HBHISRnU5XEcH4C3i8FmGc0HdxasqUxdzpc1hr0FeWA57rF00vuDMccDiVTXgNJN/G6286K+vA17fXOewG8nQo03USqGewnQwEf2LPBkzNRZVg8Qsd1phkIMa3lIGssG9hAsL36th788IpnQH8sKMBTjhGg/RxsCZw0bc614EmLMUwe3FNgZR3/2bxnnouHLSJFc2fb1LpK4atJyziSPfL5thELkcPBgVDeIoSu2yihSvFN9fEt5KSokKTZ2kI7+RI806IFnPhIaaZKZHTF/6cEWYLqLzGi+1PHZu4n8wTZcO6AwcqKJGHh0g8O7T0K6XlNCZIzUJdwoVDGkvX0gsPOyN+l6QjZhViKio4WgZOUePMSrQzNjtblKSurKI4iFcoiCTHLsFgkoTO1/N1Ed6/8j39YUWFNcka7Y4mMYYW/yyYStuwm8oPEdfHVY3ltPHiRxg6NH0r5emJg86Y/OFIir+E2LvI2uMASsnkSBXJrkDfpwwjdJBpyxHeF7dEnHKLtG2BulNqgQlOiXhjhlMB6HQ082m0UA/pyCubLP/Bb6uL1/lAymAhweEaGfu286VGtG5Rr9PE5hyLiormEW4bSs2kF0FeWayy0IT8E47KaP4MfeL0Wl7RsS+gxxdmpeqS5TIC4Je1FaYdd+ROj3BIUXp/eVOklo1R+j2Awyn8XaLpCS/JVh6xqLL6bnkx5muzkg4oKCMDt0g/2RnZZOEFvYVqtf5gYBuMb9CNVT/rMWCKulotFarhjddg7uOpPjpTBZ33r5PfWHFFSxmyN8lVkyw04BQYjvDwf66u5ZaAG5UywDiIcLeuH6dYDl0rH1YAR2EGeRdLf1f93dDZtOJ5BqyUC6gnynXPMI1XnCVz6dhUFXuAxhQFu0IgPv3qJcPWE07pc5gyTyHdSCZE2WeCyQXHwBwzF5n1/obrbsz+PbC9uPAyLuuS+ZKOBdlcEKOaA4RMc7+5gqD2jpSWvAghk8wg3KRlZ4lTBYXC7LdP9k5k2EwhbT7m5Q/oke4zBAULt7a/bkFj7MIIkcUoTucTJH5XEW7GHM0mKy34sT0UoBbVHsPDGjmARlMfvNNDx3Nd3hFRv2R7lWfl9pXj0bZGZc6RvQ61/J/NZjjX8KdzXHjqruLanVV/k2tc6s9iL0+7Pc0Bdrheu/028L9Grk0UGEOFvsNbx5ikKuXl1HMWCYSIQOOlYRzspYszibRQ7ih0wUrBr+24dtJbpt7qbd/QlCLZhYn6WBifygbxSou3R4JUOwp8xQdg8nRsgX/I+l37zwECPpLCB5S19gGfkpAB9JO4Z3882dG0UQjCkx0RSLpuPO2pihvLK2s2gc4a/qOQGcVmKurT0XpDgv8TEUpJUcEuSFgnfo7POKTUSc1B6859mBF3fhlwg/jkfg+al27QGuc4b20pxRcy481R3qT8wxhxj1j+veBPJreXL6/84hClXSnl9b0iO821v8eksfcjFXna3tLJA+UpLxNxDTgdPVL40gvsPEQHUB+/m2IVZi8xTE6CjmkUH9whAQ4mDOaXd/uoP1O3Cu8WKobiJaChHzApF/3PR4A4GZR2W2QUAdZedrPxoiWsChKcdVSjiq2VPKHwVZ8ilY4+RKX7e8lospjNmlF+PnMGjDqjkYaZ9A5TLEyR1bdTTiwvxelOUwhLLMyIRW9tOYW/pTDonH5a7pFROu85YaoRnTJB0OwWvHvuqxj+nyVBMJVjh6uOimiVaScoiLtTfmx/3Z0pR53t46/voTcXB3NdjbcrI8j8h8ol6lbxxJ688wHZ6FK/PkIqn9B9ujRuORthxGU+LTIP0yxMP4Fx03Zo2RuVL34P+trPhZxPcTkQpeyIGfHDbTP86O2n5PN8MtF8wpTWVh4kTNdJS/nabnyT+Zk3yVjoxWRwU6vwkB2Ryzn3dZpWO1SPEt5YsxvCYX4RfODsr5pVIEzigQTYUqEkdcvF68d8xIXBt60xn4aQOgwkI5+k8hjktM1FQ3uLMXmxQCs77d/Jb+xEecV9qrhb7nTNn+UC7T9scIKAjfRJ0L3KyGPYQGL6ATIMjacbKN5sGzzMFMHwGLmyW0kAzZY8RKu6/9HXTe96hQiY8STqnQ34XtivGR2NC8H1wptY4jTMw5LUAUbxOD2Z/yyR/jPzfiUTrQZjub+k3DUDIrIUeU6l2E2jxQenzaTqSJFSlWJ+fxOyDnAZqlqCfF0xR7F6vfytHlZhPe/Wt2pJ0LoQ7c5y7u2BLhs6O0McBeV2LbXwLx5AmcoqLgMYWFyIuiiEy2hHJnvUaEXodDrR1BrrP3SJLEpFR7Gud4Euei+lWF0c5zH2161hD0ucigrHV2M4FHUaOWWK5LSFvZb8QtwTwqGYVgFeQYiAQsYhp+stQ1tD+iyY3ZBJ4K052TsBCfX71F3gF/43bx5r0OrCBV+Ol65KMgy8fLPTQsCBpjL9MNxvpBkQWnM+NviDPOEhHLlGIwCcAVsi0RYbT1sqtsAh3ZiZF0AsEZluC94AKGyMbr6yJIpacaoTqGoODv3rgluGAx9gT6MLYwfLQ+G1nh2jEHjK2NhUa9JlZphK8iV0bH6nQrpJEQ5GLgQJlAZWGb/r+ZFIfjhjOUsPc8bshq/lwdHPalfpkZ+mlEGMkjlDiKIeCs8jORiJHCtjh8MQuVztuE0h6NcTudK7HgoEJDDyT7Cdiz2qFAIEF5D646Z684iGkG8GrHk/9gmQv2FVEUe8/9/ytx99XI1MsLe/yqfqJ8PD/OYg+fCp6Wlopf5/46AqUEiyJr2aBINHY8Lq4HKZOojo1n02w3FbRYvpCW35qD0T60jWWR9bw5XjDXkCrGFugISSJD63gkeZwtofH9jsO+Fj/GAjBVBFmyPnA634Ei+xDgVbZ43th8B6g+TSwdEpHr+TIfnCo8EMin9WuHXlA3Af8ejyquCCA0+GvHDVN3U8al3EvHbV1hTBybBJWsPxwIUP2zYaftJh5spnt2a/hW3H5R3nMmVNhTWVTfCwjC9jnCWmQiBKGgroQpCKftxH8xtkPB1B1fl+xfGPFvCSDcF1RtiOu4tlo7/p7iY0IDfJbX7OzjIaByI8mJnHyHyGaJUnLEBl1mTwZVrS6jQUx/EYQRHLHWbJoxEMGaiaHWZ6nXcwvtPCTqxWp0K1RB6iIy6SGolA5epbm+uHVf4U1RRj1L0ovGvRMc1CwW2uvZ/jLu8zXkxGAJF0VWyvpBIdreVMCZmC39UVEDjTsDlH1OehvDwIh7AqcZfBjgvOShjQUZmKgFdbtmg3VsjTL8zq9PhZfEGK13H/lw9cUcAy+WUU1e6s2ZbFWdsWPm3uadUwES7LJFp/jsFtfSJbrscGi+4XWoj82VjACmrT8krqLVjQ4UYQijf9Su+uEy+84BqHWuFujJ8cxhVVCzlGgxwuT+wKa6pKYvO8r29FKziZNqhpdJOTyG3cBxHzTsegJ1cF6EWUr35s4NyK7GTux4n3YcmD/VRNCbwhuJZl/N/baP78zreyZyb9LJ/T73Z47HEAffNGbEMxBTg+GD2Y2Mf2AuUIPiTbV/IN64WELvJbjWuJ+MGOOazt0uaaCP8Boq/l3RniZyHBXMK7O/LehjvIYVTJcuKZFE6OYLqrxaKfDST/CPplYxX5XFT24ax7qg2k56CGNJJ3GE/Y/JaipeZ2xmWQnkxJB7/31vRSdj9Iu3WDzMrkT7cDkYB8BuUFRTfL84nsODKW+CAqWft8HQhEF/MC5hIrjav5XFh47HcDG6lcLyKJesDQCDclaEPBN+iMIElBpjFC/IKtNY16nySjBzXRX4CzbHrW855DisdqJbRE5jcuf4Z/D1LOsOLqXVVTmhFuFPO38VVZ5v14U+VPz91EFQrgdLv8UMhOZ5YMS4vbsrQVCcaoLcx97bspC4Al6SPasprFNvoW1+xYIFisZhv0USXjLVcA5feej3nElKeEUFYZ4m+of4a51WKVeOyacxPDMIzcawK5Ci6ugAAT6PPdkooQXFWrPPTaReaOhkrAFx/MQ+uuZOxIdvIzSYosDQWT4ZSMAXfUI7Rtq2FRZHG0h0l07jfGKdNeA/VwlmC8VCZxgoR5305ZGjClCrGS76FHd6PUquYOixfImK/30iDLH/u3Eg/5FhCYroOui6/aDujTUaOFdaXXlME6aeuh+7iLtI5+sU8rJTkOvBB6/JgnMBz19XHY/zX98SoJiwnAoamUEuI3bw+CbMk3lwhU+HCyj7tBGP2I1pQ5dCdp1xXIcPhfCg2CcdbMm4JbSzexxSxcvOODAJ5jT+DYVco0DI2qae/9aLrAZAHGJeozj8/FcvwdX30r35HD5h4B4xJQAWbtbP0gj0oHsHBJq5Q9AKasnpaaDbbCArEyRG3Govb1gYDQobwhCyEXdCzVtlvP5xCUUT89ey8GMvqLcRWDWFnDsq553UyBwDeV2Q8m+vZlKtVRpHJTace7P8dwpZgn90qpPOtYRfqpYdvavopZCQylKve8xm5+eX9uKJ9e98LuAvCwMipGEZJP2sesJ1IW7lG5BVC8od76tgWW0lUEkKyIODddjjOUPAudpseKnN93CaVkvygWchIM8SYqunfH13sTe/tlDUFtnAuld2WAOAzPKgg3vTqLstzvQTTnM41nDNQrxW7l/xNxi3wzkQsW3LD5MiPNAodqmob7PGVp1jKtI05A31VYN2NkYgIALbtowSwBN+xPMKVcyqhunoWTakjMwE5w1260Zj/13FtN6gumoMFKSSYq8IkBTebC15eRwuqGZs82Ldq2cUERUQv6SXEKLTVZLXq2YwJTfKChspomuZydJTWH+FLXXmbqniHBsEkC/lVVikdxX56GpkM5Sg8D3oqPz8+qaCoU83ACCZjHTC1a2id3ftLEW6CdHOArb7Dup21nw8hJzFxHyTeXsazaUTiyNwW9MnNNWSuL7GyRB7VCuCsqR/SrVbPNS57zDmgkpJX2XKTwB+m8Ny3D8DJhnu7NF8IUS7DMdifBkEKB9+Gi1m5L2+cAunGKQnVvHttDu+kr3ibCPMpLPPekPyhejZWGk1Lt3lDSxcMvGIBCg9m1d5PNZZCFB3E3dtygUCCKqw7wNh6WA5RzA9OLp3d+bExB4j/ecj3L54w3iWDZZuwbPyVr3gtQJXMkaZdUTyqKdOcs/3QUre9EoL/uZaUiH2BIvxFGylMJ89MCKhbNM2BoHv2Vf4K4qbGeQoUl1BFJ/2HlkaYle4biLSyhTJyFP+9fHxNfoEePUcP7u846kHGM1kmrprUh6PQs2tbxavhSWUa9D5iplc3DEjTqffwjKLuTqnuoVhTxDhy+h26yYlivkmucFxAoNjL0D+fUmwoxmDPJh5bR+dS+f8iEXxJEXHQGPmWaYruze41s6DUR7oZSWJCgER+fV1ghqR5if2RdJVMYwVQOC9PbKDOi3aPWaRJkqhr7fV1OFLnaFe8g3YIuF3D0K7vKg9sE1hnDohSxAzhWXjxXHdcRBvCzGBlBYURc8F2Mp3UNIIkL+ZfoPoJqxszcu98ksiQf5zWf12NkG5UvovXyNr1frvxm5RoC0VXXm9wjQh+BtfEnxzD3UibKzjkfn4Mqy6ZSWLTWZlL9s7FT4pGVQPvJGREHzdbNImAdBGJ6fDwn/SQog0D9pgoYTR/jwxgXCIsPahNv3tnHS7zde/j3347NhgdPoc+xTPwDVHoTozm+jjqmmLcbtctjeoR3a/bGTyC4uvLant8prGxuTg+xsGYmzOPxNkcbSfW/LXwjKM0K4R4GaUrssJ7sb1DfP99II6WEuaGuwwa1jI2eQOIsny2t405KVAKuFbLhJx35D3bE9s7czylxaGCPWtcTZd1XTap7TiPok6MkdUYv/mIi1Vx0/Poe/7L1pA3UA8B+oo/uYuIKAMT+7m3D7+qlOSldVhlfppkVkLs6S+1Tfxd6YAXQyNesmNNpo7Rat1Hje9KCeulsdKTiwKJPdrV+zOTbH4UoiabCllR/a3x+plZeIfrfaF3uep7o4sTT/gbgJ5DHFuVic4aHL+CIh3i1whQrkSU2EAO+/IQdUrf9qPDbMNYLkAbtnAHYSt30HdCNVB/T6pAGJxBylv6tgTYXAxRJ54W7SFWn1y7dKLmdhC1fwduabZ046rPYl9hAE618Reprn8UbfitOKhP9yQJ5nm+yrtJjCSdqN0dBoNHCyRH6FGIJgxuC7ho9Ck8ermzK6EcpZXqQxYtZftJG6reqT4SLdhfkC0eB3UhOhErzyCyD3HkWSMUpJ6l9ix7caH05MVWxqh9i3Rv3VJBVa6rJHQXuD3f/JkNI7nV87OlapS8zAMdHB9evCDwxL/IiLp4Rn6GTTUgqij2lndt4wGzgz0DKxgyxCe/hmlRGIVnV8TG1FPBbanoIiE772iTjxFzVv4lQpJ6CkquUqad/t9VyXPlcRR5XN3pIY6TaJBDq7BO3AG6s3KizGf85GFXyx7382Bh4v+8TfpPth4u4qhhZEBAvtbJm+carFUj1ZbD1gvm+wfZZH/18OsasNtoliAIolWEBg6lE4VhWhwXmOOSULjuYpqjrjlBhAUnv43Ucv/iUDqaM/kM+z7AUv5JwnnpI9nUQfQeK4ZIe9y+WmNrw5p89+HnAT1T+d4DdlSKSsjHuiH5+Qxy36Bhuk4XCbO9EdGZCRUpwY5A3gVSDh3dfE1WEli7VkTaw8bLQdb9D65iue6cgdWT0V79/Nt943c1UtZdnpF69DRqOIisuPZg0SAHSvlQoIW64+5O0IZNt5xfKiryAdCVXPim5tcx4D3hEDbBjStVrHZcZExMd5Sgf+6pXcupbBBlLMsxBv6QYrrlqWkIF62RVfD/NqZzMZYA3wv65/5qhyzXtg2+8SKm6F6fHlreQKjEsBp9NhQ5qWjWi3otZ4X4IV6NeC4JPdrXQZjS84PH29suuR9yOtXD+G9ReVVBaFF98940recltrZ01g8ucuZk7U0BEL/wrFCCiAPSQNXEspWjUG/xwiITTm12NIkSi/2h23YpvkFm86iaJhuTjpzuz7TvlB1dNrhedSOgwOZyFDFK1oqj527icRAkeYIrQerEAePyxmZnOf7ZtreF9uIm3dOyFQamZo0zQbSLaxyPFBhbi10I+o57xgO1UblUw2+WfVkm7C9SHaJO6bYNEePZlP7O7H6dwAVREPbgMhH+Pvwt/SSdLPQo29BHeLEbfX92CnoZ6HsatPyJP6BkFx306MX1cn83qRxTDaRJq/IgEwjDzHlE4mFVWils+/4j8sD/ANyQiCV5GEnNVQIXI4xZluCYklEsLXi2BFymJppWb1nTMvtzsnQV9lifSte51GgMzzviZapWLvfeg5ZBT7MQi4jF/nHHWkuXVy4YYBmsPYeE/tBcA6yNHfkAMSeIlRBBYTc6CPODk7vLbfaKZ3GISQWrgj8b2288mFd71rV3WI2Yn9IYmJY2poJp9S5hE9up3qRrM8NV9d42PcfuFWwOHpmqyQq6IbKDo+xRMNJz29sv6cDnX1eTdtt7Sxf8eiihTtsu+sJ0XWzO+UG4DWI4a7ZA+N56ydpOZj+wMhXzU8OjrxXXK9z9mUgDOUJT/TSV+Jxb502AXVUmb8zihtEi0vuWI7V1XDD9LFY1mtf6FLqdKFSpEmDXkf67ZMTVjXQX67V/s3PsI9PaWFwmM0I3iTXxw15fQLz2GsSZoTWTewDCcxNTUPNv9DJWbKO3VNYk+Hi1kYqoP0PEmbjo+jwVTIDg6noBhkjn6eb5ywvvY8LB2cGhXML4NHjHCwayVd4fP5p/ITs8fErSB7zTGK/j+dz+5ADQQ+5YUpEIOb+N4ABKeVqHmAzcl90d+6gETEBvv4dTWpIVS/rZLDP7KJTR5Jx7fOeuT68nANdMq+Z09kvxQ+H4jU6f35k5aWKiU4+/KptNYvNEraSXZU036+jzLQp6ckeV71bhoObRLZI654gBPZpqFTEDTbPf+LbVr6RrKzTVTCfPuNxayDsxT7acwPrGXdDctgC7WXkn+ZPo8JYg1+yyIYIG+2s0esD/ujE65Bu2L5cOxZkPcDQIBAg2mcYVifCjZK89XEaKbq9Ws0J80mBuBFQc+l2M6J3IDBaBJmrwJUoV/uVUfV1uyzuQibjsZNNi/EccO2iqcfzYcZDSecmYCSMY33kWCPmf6xr2x/+n4SDoRpSyDYbWvVnc6BnpNg7ecgcXYA4kyKXJFFPWok/TbhUj12hakr1gApZX9x3hr5NE77m9Yt8y54JROYWxXpbIYxxiRhCJFXxA6dsyL14UpuJJtXCWifTh2/zj1saTkRNHGM61iaq1Y+JRJs6ASAncmu0jssnDOJU6/PCaILsuGvxVoXmPn6NHrtI4Me5C61S1EQuhfCCHAW96vohL+DIzzn7lUKnib9cyMXB4xLbGjaiSBzE/AYZyFrHgFCZnMSXYo9UngUDbNJjs3DWgX25XB5vsmqJcvXtzTr90/80Rz+aXFCyds2xdiUaZ+UjW3KKGda4WiGEDcFGfeFOn3GOi7HFhtVlb0hn/tmNvTDUPyGVSvmK+yOJpKPUIu+PJQwgkVsfhtpPWjejaaxY+wD81m9QF/HdGSBfu6DWdSxXiRWmAgM2DV2zD4O12zYWCanuv2GXQNtrRN4QjlByNGsQyAOUFkhWI+lQZ7EmT2Vgf7O0jdD5wu9sPnd/VZcVwcMzqOaBRCs8VjGhYpXW0pikZqawU+wY3QaOHzcK8NbYnkqYaopjiIAWlBJ55zIesMuJXM4/NhjHmv3yI6SmXSNF0KE1WMUJg0cqBYtL7DLK29FgS5yuSokoSCxOB4u50DHpWTcQSYGWho/TKnJO/F6kyZIUdP3qlNxxSavp/vql29kUc2ZWGNv9W8eARa9RE7I1iNgl7H0VoD+wDHfbvq2bYsMtlNHom1qG1aY3eHHzwJk4D3z8ZJIKIpIC4z2NfWivCvPXhDjVDCMidVHdqqbq+e6vO7cNGivXD/hAtpAExjf39mkISmRA/fbLMbFmqldh+B8mRtq7W2ryWUHQc6FjFxBCmfEgsEhCNoPOdDn6OoQvs6LxCPNPqrICm9lBBvNPgfLAkFSEhmgNCEB7sWsnHxMEn9qrAWOPJx5QYBB9pfQ6azuVVhFV+okrrFBayeobCCPQD1FMPReeQmJqzK5z9igZqFgZ+e1BCZZcvaWW7D1FVn8Xp9Qi8s/ELhol239tfsTNAde7AaVSQF83/jLDyNfBOobn4hJnCAcc9IhE7NfEYIC1wxzXu0XEP3PkPzMFzDqW7QAaps+HuX5+frlqTYOuSNIsVCTdCafocL5Bplr44D7JQvhMMiCYRIrNuBP7RafUuLeoXgu3Y+9QM9jLOAyxSMD7HZc11/TTMnTpl5l1GKFbPl63AFH1UsZwyy7vVMFBxL9T7U1JtU3btulr5oaVPFK0U0rGUPxncx4x4W4XgpeK0OMyY3RHY0Ay75jwxUECNBmWrJXevX7N4Ck/M3T8+8iZyya2GRcqaHq00q/vxHOESbhpAnPqx4G/NjYqfp6TZzQzsA3TruhHij2kl0ARglyip6duwiMWQFkSjjhoT8z/II0+q69O1KlSie0NUDziDTMCcD1UXm00HxEO8Ra3cNKPTdshUBqzET9TQyEynq4IBHIAmhoDxsq0/Lg3YYUt3XIuearbjNd4M0p8McoKu18I4vCIszl2nBf2GPOGTcuqsMVDrGM/8Yp6VaZrw/T0qNCn5K3wJ5ULzYPZAZfDBryarkOXUJPQuzi9oQ6eP1zfyyF9mZbyQDPKmj4zbtbxhTlCtOpc6RwlFNmHsmyHF1sC6XQVKS0wiBNuB4OFdXUkHHp54Vsm3ahFha7knffF4GGG7A0IST5LK+DH+Qtz0+n6PbQ0/jCBn3WqALkjJWS3iQCK6N8wtOGv2pTxbRr4VlZsbHuKBqxyWiU9fHErR8aSkN9PkIO88l8YAbYVpBZlpXFDFGeKQ/8fmR/5XonrKqPoU6x4Z95PnXSL6j0YDpRAwYxyk8h8sc1z3ukqEY/JBoZWD0VwG+RYTZVNkwVA9usfCHYJnjZqSPSsSUTrKxqGWioIVLd3aEPN2B85lB5biqnjBljnbd4+GUPE8Ija+3P1Ggmj+fQr4/c3YfxRPEzT5TUrU8DphRBgSN8+clslQ86rCVcDozC1xuzcy25kd1d3bvlgFUEXpWHNeKxbwPjUW3aR4FOKxxxNLFr69qySkInNTsm0mqXRKkeTuBNJ8CgD3HInymkIjx2OCe76i9CPkBGQ6wVo+Rc5emtXhzAijVcJB1q7u8QRN7hYRqTH6QCBcOreBgxf9QvHsk8jP19wD1CSwSKJqCuULwM9MgJRIt5Xtmsg0I8vgCQJGmzWOuRJsSiq5k8IJrQqLJcYe0y37tG6JCVaAExTWNdN90mTKBtxCL7DAeGRoHv0ko7fnE0JCK075dFy+8/NONnMJs0IxLwxrkyD9j66FRc2EFaN5KeG2+90LKEJkSS/vtHsljBkBDGhGDXjjRyq+71bp/Jiki4BffASwPh1b+2dpNrnQjWMeX0bd0q0uHuoDOTBv7N0KHDeEhMRaAUBsHm+q8iI3GoWonRgY70vrE99gBIAXI5Ahx85cMxIToYXNKK84fKUGdgTGT0xpdZO5vpk9ygV7iHB7Jp3gEdzfVDn8StQS+L3TTLcJ3leQcfgAIo6B1Qxc6hcqOikkGQhiwt34w+PS4l0Tt2/qZ6RgAV2qB8NGJRiC1K4zWYUQ6bttBK8pykartkRpGbL1E1vRmOptAZOKHCUvWIncRMq+2OcItpLcmcJ4o9SHQTSW38oRCtz7jbho70kpNiNAoiMPXENWpuKz9SG7tXPuG3o3NylJBOSdgt7p8Ee1vovOCadAHkOna8OT7z6a1Fb51wQIjs0nhNYZlP67kbyZd2Lk0oJoQ8uCTioswrGM1m0FlfbR6OzRa/Me9F+A3RaKkNlk9LlQPGkRanv2pp/loBRVIAKYtrUehplGbOYbEjetkBPkho/QtEB0bpcbny53+vGPPy3nwer6k2SiXepJU4vpqeNOOo5EQhcAhX+bRSCIQjc5KrzHqsPAg8pirsu6gib0EzBBYvZXioqb4gOoUUxe+K3pQbpf7NArctrejUF5w07y7fMw0v7wVfjQYy6HE/rNEsnabVUFetCyugj0ZWGx2xOZIyIs8kesvmO71bqGt5I1YeIfbzU26Eq9R9BdGjxGHO7Z+zsjOIzxSSBdB/9SAKj7Q7DBw26Hvsk1E2SCb0LLt1Yh+Mh34Ksld6mkaH7VuPaDmZSefE1667vj3BsXH/edPr6WvJoiFMsmNas0nfLUiGKkvP3FwYmq+jk9+aOYYC6hJM+hFVy5GcWqVsuG5F0lO+0eHrNz3FqA+/urfOXKDbPvP2MkOPe0L6j3we+2G/sssRku+p5iBpkqrlkoGnwG57NFm8/o/G1MeDgwlHW6Uf/zu4SDArtry8oeS9F5twirWJ3YuvdKnvqOf9+iYEpsVodmfQvZNbrB/p1u+HK9TrRjAJjEfgpsYYkNms4Q0Bz0ec4CF3ALo2wdxd3tCADFE1HSDYrkk9M8LkbeKJOLILi9SH7+lITwh5cQK+LBvHn2C42TaT0JwGGpxpftiPRwvkyMPyjFvo0xr20LMJrri4J+JOPF48xQauL52gqFDB+lyyfw3FJsNw1xvyM1Rrqdn5H9lPmxrwDWB4ZtCVU/pVSh5MCoDvSbIP5icmtzw/+DCokR8gXldC1svtnfB43LGzwM6W6kbIX4BFwu6ajA2IUtXfgmdamTpBVPIPdlncNIxzS8qM04RPWHbZAeLRcbKxLj8MTuexxnZ0faRvViK9Ok5C+ArekkpuEiJAzSIjYMDQlRvZ3gjiFDDvSZoLaUcKRK7DkYJjPmVm0H11diiSzoFaDWihI7rxDCfZ718Vs31nzSHeFaENQZN2c5BQMZJ0/v5iGvV1xID9Ft3crbIaL5jKCMylZd1PS7IFGyjRc/lTRJq99yzcTQsqOUkcCn/FtDV/wVO55Vprvm1YsDD9DF7T5So1GMIYNz58cR4jRmq7CjcYREkfvyJ9mV3X10t/TVxyHg0tlv+OjcEx</Data></PidData>',
                                            Aadhar_No__c='363155436548',
                                            Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-4));
                                            
         if(isInsert){
            insert app;
        }
        return app;
    }    
    
    public static Applicant__c createTestApplicantForUidaiBiometric2(Boolean isInsert){
        
         Applicant__c app =new Applicant__c(Name='test',
                                           Contact_Number__c ='3232323232',
                                           Customer_First_Name__c='GOURAB',
                                           Customer_Last_Name__c='GOSWAMI',
                                           Whatsapp_number__c='1231231231',
                                           Consent_Received__c=true,
                                            Income_Ca__c='SAL',
                                            Profile__c = 'Software Engineer',
                                            Bureau_Pull_Attempts__c=1,
                                            Selfie_Retry_Attempts__c=2,
                                            Income_Source__c='Non-Earning',
                                            Preferred_address_for_communication__c = 'Permanent Address',
                                            of_family_members_residing_with_you__c = '2',
                                            Residence_country__c = 'India',
                                            Who_will_repay_the_loan__c = 'Borrower',
                                            Marital_status__c = 'SINGP',
                                            Spouse_Name__c = 'Sameer',
                                            Father_s_name__c = 'Viraa',
                                            Mother_s_name__c = 'Neeta',
                                            Communication_language__c = 'Hindi',
                                            Customer_Qualification__c = 'B2',
                                            Email_Id__c = 'riya@gmail.com',
                                            OTP_for_borrower__c='9999',
                                            PID_Block__c='<PidData><Resp errCode="0" errInfo="Image Capture Success" fCount="1" fType="1" iCount="-1" iType="-1" pCount="-1" pType="-1" nmPoints="-1" qScore="-1"/><DeviceInfo dpId="PRECISION.PB" rdsId="PRECISION.AND.001" rdsVer="1.2.3" dc="d8507b94-6000-439c-a17a-ddb1f5688474" mi="PB510" mc="MIIEGDCCAwCgAwIBAgIIX9XM7YVOAe0wDQYJKoZIhvcNAQELBQAwgewxNzA1BgNVBAMTLkRTIFBSRUNJU0lPTiBCSU9NRVRSSUMgSU5ESUEgUFJJVkFURSBMSU1JVEVEIDMxJjAkBgNVBDMTHU5PIDIyIEhBQklCVUxMQUggUk9BRCBUIE5BR0FSMRAwDgYDVQQJEwdDSEVOTkFJMRIwEAYDVQQIEwlUQU1JTE5BRFUxIjAgBgNVBAsTGVNPTFVUSU9OIERFVkVMT1BNRU5UIFRFQU0xMjAwBgNVBAoTKVBSRUNJU0lPTiBCSU9NRVRSSUMgSU5ESUEgUFJJVkFURSBMSU1JVEVEMQswCQYDVQQGEwJJTjAeFw0yMjAxMDUxMDQ3NDRaFw0yMjAyMDQxMDQ3NDRaMG4xMjAwBgNVBAoMKVByZWNpc2lvbiBCaW9tZXRyaWMgSW5kaWEgUHJpdmF0ZSBMaW1pdGVkMRIwEAYDVQQLDAlCaW9tZXRyaWMxEDAOBgNVBAcMB0NIRU5OQUkxEjAQBgNVBAMMCVByZWNpc2lvbjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALhS2PN+o+VaEALq32ZWSLYl4C63GdgzRmYY6DitnZ/CRVxSKQy1c2v0VnaLd7w5jTmJYrqp5BMEZoWxLf+M6EeowpRU8/0SmLUVR7NtdcTXI4obPK/dx93kVoV824UTvv0pc1HQmH95+oGKacePGYyo0HTNFGOLJTG4qSpFe/mBNf7EiwboLSWOoRBhk0bSrRhZ4/+N2iiGURxY3WTF7QkgR6teB89iHwdnuFmiJ32h8FxszwVYBvjjSDmCCKB7/DZkDP0mZhH6dwGroFIbxhxACdKalc8uxFVMj2pDnpU9LTeGEyscaYfuPZB8UqWWxK3eUfLXAW6qYO3foTjSDW8CAwEAAaM7MDkwCQYDVR0TBAIwADALBgNVHQ8EBAMCAYYwHwYDVR0jBBgwFoAUtTWwpFcL+TBx63TcMhe9Ih9zKGcwDQYJKoZIhvcNAQELBQADggEBAIETQlDPJMWFJVsh0En75hDlmefshHgvkck3xtwYP96gLKYyP8T4x3RhMF9fLdvmVtw3bjumVTqzEHPg6m3lHh/bqUErNwxLjsslwzSkqdANSOBPzRS1JLIxHBjINn4+SCn2p4KVDhZskJVvVBstp4Py8THqxQWeAatWRC9PWbY+EMrD7BQdnZTPPtKzzUsubGbYZgUPYhwgWvVBMSWApr9NQFp7dJ7M4xe2wQ0tkZ79DqTqBAUc/S3E1uX/B9AcNQ2YBWEVKgSAg0sAswR82PMMdrYJ1XvnvgkyxS6HG9FA9pSXDAAPBsZZD5nBlgtp961D1xk89zCNb36elca4tLU="><additional_info><Param name="srno" value="EAC9026AZRFE41912380"/><Param name="sysid" value=""/><Param name="ts" value="2022-01-06T10:54:06+05:30"/><Param name="Locking" value="N"/></additional_info></DeviceInfo><Skey ci="20221023">OtivOCWZutXDpEaJCFEGIzI/F1MFAiZMhYlpLcCU3w8evzJvW6vYO/SSZgFejftXI97HK6h/0BuUZWIqJnHpBIYyy0XnjbjSmilXTOl8iAA4lDgnWC2k+x4rybGwTE2kH2lYeuwxsmlBSS6a2UYHXi6IN2qvegO4791pPC7pn3BWY2gN8UTvv9mOXE1V6bBqXP2HqdYxrvSjE6OIVGiv5TO4+/bDjF9OmH+dHIXKUmIvRpEm7qOcyQm4q5C4CVqgywpX/42sHnUbemCGDohNUmG9iwohsoMT2nYl1gDqnrIe6nPBG84ndHmJ4aJ0NRssPg++jv9Nor1Iki9+4YNoqQ==</Skey><Hmac>Iuh5Fhf4rP75DcOZiAe21VTG0DV+GNogs7mt5k8ACO/fG7+q6VFcQwNoB1q/PQ7e</Hmac><Data type="X">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</Data></PidData>',
                                            Aadhar_No__c='',
                                            Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-4));
                                            
         if(isInsert){
            insert app;
        }
        return app;
    }    
    
    public static ContentVersion createContentVersionforOcrFront(String header, Boolean isInsert, Documents__c document){
        Blob bodyBlob=Blob.valueOf(header); 
            
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='SampleTitle', 
            PathOnClient ='SampleTitle.jpg',
            VersionData = bodyBlob, 
            origin = 'H',
            Document_Side_fileupload__c = 'Front'
        );
        insert contentVersion_1;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                        FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = document.id;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink;
        
        return contentVersion_1;
    }
    
    public static TriggerSwitch__c getTrigerSwitchData(Boolean isInsert){
        
        TriggerSwitch__c trgSwitch = new TriggerSwitch__c();
        trgSwitch.Name = 'IND_DocumentTrigger';
        trgSwitch.Active__c = true;
        if(isInsert){
            insert trgSwitch;
        }
        return trgSwitch;
    }

    
    public static Vehicle_Detail__c createTestVehicleDetail(Boolean isInsert){
        
        Opportunity opp = TestDataUtility.createTestOpportunity(true);
        Vehicle_Detail__c vehicleDetail = new Vehicle_Detail__c(Dealer_Sub_dealer_name__c = 'abc',
                                                                Loan_Application__c = opp.Id,
                                                                Executive_Contact_Number__c='8989898989', 
                                                                Executive_name__c='ABC',
                                                                Product__c = '',
                                                                Insurance_expiring_within_60_days__c=true,
                                                                City__c='Aadityana',
                                                                Manufacturer_Year_Month__c = '2019-09',
                                                                Variant_Code__c = 'SWIFTVDI6',
                                                                Eligible_Tenure__c = 30,                                                               
                                                                Eligible_Loan_Amount__c = 500000);
       // Retry_Count__c retryCount = TestDataUtility.createTestRetryCount(true);
        City_State_Master__c city = TestDataUtility.createTestCity(true);
       // ROI_Master__c roi =  TestDataUtility.createTestROI(true);
        if(isInsert){
            insert vehicleDetail;
        }
        return vehicleDetail;
    }
    
    /*public Static ROI_Master__c createTestROI(Boolean isInsert)
    {
     ROI_Master__c roi = new ROI_Master__c(Name = 'ROI', 
                                           Description__c='ROI',
                                           Max_Value__c = 4,
                                           Vehicle_Category__c = 'U',
                                           External_Id__c = '12345',
                                           Min_Value__c = 1);  
    if(isInsert){
            insert roi;
        }
        return roi;
    }*/

       public static Vehicle_Detail__c createTestVehicleDetailForIbb(Boolean isInsert,Opportunity opp){
        
       
        Vehicle_Detail__c vehicleDetail = new Vehicle_Detail__c(Loan_Application__c =opp.Id,
                                                                Manufacturer_Year_Month__c = '2017-01',
                                                                Variant__c = 'ALSTILELE',
                                                                City__c='Hyderabad',
                                                                State__c='Andhra Pradesh'
                                                              );
        if(isInsert){
            insert vehicleDetail;
        }
        return vehicleDetail;
    }

    
    public static Income_Details__c createTestIncomeDetails(Boolean isInsert) {
        Income_Details__c incomeObj = new Income_Details__c(Name= 'TestIncome');
        if(isInsert){
            insert incomeObj;
        }
        return incomeObj;
    }
    
     public static City_State_Master__c createTestCity(Boolean isInsert){
        City_State_Master__c city = new City_State_Master__c( Name= 'Aadityana',
                                          City_Code__c = '5', Carwale_ID__c=118
                                          );
        if(isInsert){
            insert city;
        }
        return city;
    }
    
    public Static Retry_Count__c createTestRetryCount(Boolean isInsert){
        Opportunity opp = TestDataUtility.createTestOpportunity(true);
        Retry_Count__c retryCount = new Retry_Count__c( 
                                                       Service_Name__c = 'CarwaleApi',
                                                       Count__c = 0,
                                                       Loan_Application_Id__c = opp.Id
                                                      );
        if(isInsert){
            insert retryCount;
        }
        return retryCount;
    }
    
    
    public static Vehicle_Detail__c createTestVehicleDetailForDealEligible(Boolean isInsert){
        Opportunity opp = TestDataUtility.createTestOpportunityForOcr(true);
        Vehicle_Detail__c vehicleDetailObject = new Vehicle_Detail__c(Loan_Application__c=opp.Id ,Product__c ='H'
                                          );
        if(isInsert){
            insert vehicleDetailObject;
        }
        return vehicleDetailObject;
    }
     public static Vehicle_Detail__c createTestVehicleDetailForDealEligible1(Boolean isInsert){
        Opportunity opp = TestDataUtility.createTestOpportunityForEligibleMaster(true);
        Vehicle_Detail__c vehicleDetailObject = new Vehicle_Detail__c(Loan_Application__c=opp.Id ,Product__c ='H'
                                          );
        if(isInsert){
            insert vehicleDetailObject;
        }
        return vehicleDetailObject;
    }
    
   public static Applicant__c createTestApplicantForMFCValuation(Boolean isInsert,Opportunity opp){
       // Opportunity opp = TestDataUtility.createTestOpportunity(true);
         Applicant__c app =new Applicant__c(Name='test',
                                           Contact_Number__c ='1234567891',
                                           Customer_First_Name__c='GOURAB',
                                           Customer_Last_Name__c='GOSWAMI',
                                           Email_Id__c = 'riya@gmail.com',
                                           Opportunity__c = opp.Id,
                                           DocAuth_Application_Id__c = '45678934',
                                           Whatsapp_number__c='1231231231',
                                           Consent_Received__c=true,
                                            Income_Ca__c='SAL',
                                            Profile__c = 'Software Engineer',
                                            Bureau_Pull_Attempts__c=1,
                                            Selfie_Retry_Attempts__c=2,
                                            Income_Source__c='Non-Earning',
                                            Preferred_address_for_communication__c = 'Residence Address',
                                            of_family_members_residing_with_you__c = '2',
                                            Residence_country__c = 'India',
                                            Who_will_repay_the_loan__c = 'Borrower',
                                            Marital_status__c = 'SINGP',
                                            Spouse_Name__c = 'Sameer',
                                            Father_s_name__c = 'Viraa',
                                            Mother_s_name__c = 'Neeta',
                                            Communication_language__c = 'Hindi',
                                            Customer_Qualification__c = 'B2',
                                            Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-4));
                                            
         if(isInsert){
            insert app;
        }
        return app;
    }  
    
 public static Vehicle_Detail__c createTestVehicleDetailForMFCValuation(Boolean isInsert,Opportunity opp){
        Vehicle_Detail__c vehicleDetailObject = new Vehicle_Detail__c(Loan_Application__c=opp.Id ,Product__c ='H',Purpose_of_purchase__c='Personal',Location_Of_Vehicle__c='Mumbai',
                                                                      Vehicle_Place_Of_Valuation__c='VIZIANAGARAM',Valuer_category__c='MFC',Valuer_code__c='2434',Valuer__c='B',
                                                                      Owner_Name__c='Javed An',Owner_Contact_Number__c='9876543234',City__c='',Make__c='M02',Model__c='BOLEPIKUP2',Variant__c='BOLEPIKUP',
                                                                      Vehicle_Registration_number__c='AP37Y3565',Vehicle_type__c='U',Engine_number__c='TBH1H79814',Chassis_number__c='MA1ZN2TBKH65317',State__c='MH');
        if(isInsert){
            insert vehicleDetailObject;
        }
        return vehicleDetailObject;
    }

    public static Vehicle_Detail__c createTestVehicleDetailForLTV(Boolean isInsert,Opportunity opp){
        Vehicle_Detail__c vehicleDetailObject = new Vehicle_Detail__c(Loan_Application__c=opp.Id ,Product__c ='H',Purpose_of_purchase__c='Personal',Location_Of_Vehicle__c='Mumbai',
                                                                      Vehicle_Place_Of_Valuation__c='VIZIANAGARAM',Valuer_category__c='MFC',Valuer_code__c='2434',Valuer__c='B',
                                                                      Owner_Name__c='Javed An',Owner_Contact_Number__c='9876543234',City__c='',Make__c='M02',Model__c='BOLEPIKUP2',Variant__c='BOLEPIKUP',
                                                                      Vehicle_Registration_number__c='AP37Y3565',Vehicle_type__c='U',Engine_number__c='TBH1H79814',Chassis_number__c='MA1ZN2TBKH65317',State__c='MH');
        if(isInsert){
            insert vehicleDetailObject;
        }
        return vehicleDetailObject;
    }

    public static Vehicle_Detail__c createTestVehicleDetailForMFCValuation2(Boolean isInsert,Opportunity opp){
        Vehicle_Detail__c vehicleDetailObject = new Vehicle_Detail__c(Loan_Application__c=opp.Id ,Product__c ='H',Purpose_of_purchase__c='Personal',Location_Of_Vehicle__c='C',
                                                                      Vehicle_Place_Of_Valuation__c='VIZIANAGARAM',Valuer_category__c='MFC',Valuer_code__c='2434',Valuer__c='B',
                                                                      Owner_Name__c='Javed An',Owner_Contact_Number__c='9876543234',City__c='Mumbai',Make__c='M02',Model__c='BOLEPIKUP2',Variant__c='BOLEPIKUP',
                                                                      Vehicle_Registration_number__c='AP37Y3565',Vehicle_type__c='U',Engine_number__c='TBH1H79814',Chassis_number__c='MA1ZN2TBKH65317',State__c='MH');
        if(isInsert){
            insert vehicleDetailObject;
        }
        return vehicleDetailObject;
    }
    
    
    public static Vehicle_Detail__c createTestVehicleDetailForMFCValuationState(Boolean isInsert,Opportunity opp){
        Vehicle_Detail__c vehicleDetailObject = new Vehicle_Detail__c(Loan_Application__c=opp.Id ,Product__c ='H',Purpose_of_purchase__c='Personal',Location_Of_Vehicle__c='Mumbai',
                                                                      Vehicle_Place_Of_Valuation__c='VIZIANAGARAM',Valuer_category__c='MFC',Valuer_code__c='2434',Valuer__c='B',
                                                                      Owner_Name__c='Javed An',Owner_Contact_Number__c='9876543234',City__c='Mumbai',Make__c='M02',Model__c='BOLEPIKUP2',Variant__c='BOLEPIKUP',
                                                                      Vehicle_Registration_number__c='AP37Y3565',Vehicle_type__c='U',Engine_number__c='TBH1H79814',Chassis_number__c='MA1ZN2TBKH65317',State__c='');
        if(isInsert){
            insert vehicleDetailObject;
        }
        return vehicleDetailObject;
    }
    
    public static Vehicle_Detail__c createTestVehicleDetailForMFCValuationState1(Boolean isInsert,Opportunity opp){
        Vehicle_Detail__c vehicleDetailObject = new Vehicle_Detail__c(Loan_Application__c=opp.Id ,Product__c ='H',Purpose_of_purchase__c='Personal',Location_Of_Vehicle__c='Mumbai',
                                                                      Vehicle_Place_Of_Valuation__c='VIZIANAGARAM',Valuer_category__c='MFC',Valuer_code__c='2434',Valuer__c='B',
                                                                      Owner_Name__c='Javed An',Owner_Contact_Number__c='9876543234',City__c='Mumbai',Make__c='M02',Model__c='BOLEPIKUP2',Variant__c='BOLEPIKUP',
                                                                      Vehicle_Registration_number__c='AP37Y3565',Vehicle_type__c='U',Engine_number__c='TBH1H79814',Chassis_number__c='MA1ZN2TBKH65317',State__c='MH');
        if(isInsert){
            insert vehicleDetailObject;
        }
        return vehicleDetailObject;
    }
    public static Vehicle_Detail__c createTestVehicleDetailForMFCValuationmodel(Boolean isInsert,Opportunity opp ){
        Vehicle_Detail__c vehicleDetailObject = new Vehicle_Detail__c(Loan_Application__c=opp.Id ,Product__c ='H',Purpose_of_purchase__c='Personal',Location_Of_Vehicle__c='Mumbai',
                                                                      Vehicle_Place_Of_Valuation__c='VIZIANAGARAM',Valuer_category__c='MFC',Valuer_code__c='2434',Valuer__c='B',
                                                                      Owner_Name__c='Javed An',Owner_Contact_Number__c='9876543234',City__c='Mumbai',Make__c='M02',Model__c='',Variant__c='BOLEPIKUP',
                                                                      Vehicle_Registration_number__c='AP37Y3565',Vehicle_type__c='U',Engine_number__c='TBH1H79814',Chassis_number__c='MA1ZN2TBKH65317',State__c='MH');
        if(isInsert){
            insert vehicleDetailObject;
        }
        return vehicleDetailObject;
    }
    
    public static Vehicle_Detail__c createTestVehicleDetailForMFCValuationVrntCode(Boolean isInsert,Opportunity opp){
        Vehicle_Detail__c vehicleDetailObject = new Vehicle_Detail__c(Loan_Application__c=opp.Id ,Product__c ='H',Purpose_of_purchase__c='Personal',Location_Of_Vehicle__c='Mumbai',
                                                                      Vehicle_Place_Of_Valuation__c='VIZIANAGARAM',Valuer_category__c='MFC',Valuer_code__c='2434',Valuer__c='B',
                                                                      Owner_Name__c='Javed An',Owner_Contact_Number__c='9876543234',City__c='Mumbai',Make__c='M02',Model__c='BOLEPIKUP2',Variant__c='',
                                                                      Vehicle_Registration_number__c='AP37Y3565',Vehicle_type__c='U',Engine_number__c='TBH1H79814',Chassis_number__c='MA1ZN2TBKH65317',State__c='MH');
        if(isInsert){
            insert vehicleDetailObject;
        }
        return vehicleDetailObject;
    }
    
     public static Vehicle_Detail__c createTestVehicleDetailForMFCValuationEngine(Boolean isInsert,Opportunity opp){
        Vehicle_Detail__c vehicleDetailObject = new Vehicle_Detail__c(Loan_Application__c=opp.Id ,Product__c ='H',Purpose_of_purchase__c='Personal',Location_Of_Vehicle__c='Mumbai',
                                                                      Vehicle_Place_Of_Valuation__c='VIZIANAGARAM',Valuer_category__c='MFC',Valuer_code__c='2434',Valuer__c='B',
                                                                      Owner_Name__c='Javed An',Owner_Contact_Number__c='9876543234',City__c='Mumbai',Make__c='M02',Model__c='BOLEPIKUP2',Variant__c='BOLEPIKUP',
                                                                      Vehicle_Registration_number__c='AP37Y3565',Vehicle_type__c='U',Engine_number__c='',Chassis_number__c='MA1ZN2TBKH65317',State__c='MH');
        if(isInsert){
            insert vehicleDetailObject;
        }
        return vehicleDetailObject;
    }
    
    public static Vehicle_Detail__c createTestVehicleDetailForMFCValuationChassis(Boolean isInsert,Opportunity opp){
        Vehicle_Detail__c vehicleDetailObject = new Vehicle_Detail__c(Loan_Application__c=opp.Id ,Product__c ='H',Purpose_of_purchase__c='Personal',Location_Of_Vehicle__c='Mumbai',
                                                                      Vehicle_Place_Of_Valuation__c='VIZIANAGARAM',Valuer_category__c='MFC',Valuer_code__c='2434',Valuer__c='B',
                                                                      Owner_Name__c='Javed An',Owner_Contact_Number__c='9876543234',City__c='Mumbai',Make__c='M02',Model__c='BOLEPIKUP2',Variant__c='BOLEPIKUP',
                                                                      Vehicle_Registration_number__c='AP37Y3565',Vehicle_type__c='U',Engine_number__c='TBH1H79814',Chassis_number__c='',State__c='MH');
        if(isInsert){
            insert vehicleDetailObject;
        }
        return vehicleDetailObject;
    }
    
    public static Vehicle_Detail__c createTestVehicleDetailForMFCValuationVehRegNo(Boolean isInsert,Opportunity opp){
        Vehicle_Detail__c vehicleDetailObject = new Vehicle_Detail__c(Loan_Application__c=opp.Id ,Product__c ='H',Purpose_of_purchase__c='Personal',Location_Of_Vehicle__c='Mumbai',
                                                                      Vehicle_Place_Of_Valuation__c='VIZIANAGARAM',Valuer_category__c='MFC',Valuer_code__c='2434',Valuer__c='B',
                                                                      Owner_Name__c='Javed An',Owner_Contact_Number__c='9876543234',City__c='Mumbai',Make__c='M02',Model__c='BOLEPIKUP2',Variant__c='BOLEPIKUP',
                                                                      Vehicle_Registration_number__c='',Vehicle_type__c='U',Engine_number__c='TBH1H79814',Chassis_number__c='MA1ZN2TBKH65317',State__c='MH');
        if(isInsert){
            insert vehicleDetailObject;
        }
        return vehicleDetailObject;
    }
    
    public static Vehicle_Detail__c createTestVehicleDetailForMFCValuationMake(Boolean isInsert,Opportunity opp){
        Vehicle_Detail__c vehicleDetailObject = new Vehicle_Detail__c(Loan_Application__c=opp.Id ,Product__c ='H',Purpose_of_purchase__c='Personal',Location_Of_Vehicle__c='Mumbai',
                                                                      Vehicle_Place_Of_Valuation__c='VIZIANAGARAM',Valuer_category__c='MFC',Valuer_code__c='2434',Valuer__c='B',
                                                                      Owner_Name__c='Javed An',Owner_Contact_Number__c='9876543234',City__c='Mumbai',Make__c='',Model__c='BOLEPIKUP2',Variant__c='BOLEPIKUP',
                                                                      Vehicle_Registration_number__c='AP37Y3565',Vehicle_type__c='U',Engine_number__c='TBH1H79814',Chassis_number__c='MA1ZN2TBKH65317',State__c='MH');
        if(isInsert){
            insert vehicleDetailObject;
        }
        return vehicleDetailObject;
    }

    
     public static Applicant__c createTestApplicantForCIBIL(Boolean isInsert, Opportunity opp){
        
         Applicant__c app =new Applicant__c(Name='test',
                                           Contact_Number__c ='1234567891',
                                           Customer_First_Name__c = '',
                                            Customer_Last_Name__c = '',
                                            Applicant_Type__c = '',
                                           // Opportunity__r.Lead_number__c = '',
                                            Loan_Amount__c = 0 ,
                                            Current_Same_As_Permanent__c = false,
                                            Is_Existing_Customer__c = true,
                                            Father_s_name__c = '',
                                            Mother_s_name__c = '',
                                            Spouse_Name__c = '',
                                            Email_Id__c = '',
                                            //Opportunity__r.Product_Type__c = '',
                                           Consent_Received__c=true,
                                            Income_Ca__c='SAL',
                                            Profile__c = 'Software Engineer',
                                            Bureau_Pull_Attempts__c=1,
                                            Selfie_Retry_Attempts__c=2,
                                            Income_Source__c='Non-Earning',
                                            Declared_income__c=45000,
                                            Opportunity__c = opp.Id,
                                            Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-4));
                                            
         if(isInsert){
            insert app;
        }
        return app;
    }
 public static Applicant__c createTestApplicantForCIBIL1(Boolean isInsert, Opportunity opp){
        
         Applicant__c app =new Applicant__c(Name='test',
                                           Contact_number__c ='1234567891',
                                           Customer_First_Name__c = 'Pooja',
                                            Customer_Last_Name__c = '',
                                            Applicant_Type__c = '',
                                            Loan_Amount__c = 0 ,
                                            Current_Same_As_Permanent__c = True,
                                            Is_Existing_Customer__c = False,
                                            Father_s_name__c = 'Ram',
                                            Mother_s_name__c = 'Seeta',
                                            Spouse_Name__c = 'Seema',
                                            Email_Id__c = 'pooja@gmail.com',
                                            Consent_Received__c=true,
                                            Income_Ca__c='SAL',
                                            Profile__c = 'Software Engineer',
                                            Bureau_Pull_Attempts__c=1,
                                            Selfie_Retry_Attempts__c=2,
                                            Income_Source__c='Non-Earning',
                                            Declared_income__c=45000,
                                            Opportunity__c = opp.Id,
                                            Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-4));
                                            
         if(isInsert){
            insert app;
        }
        return app;
    }
    
     public static Applicant__c createTestApplicantForCIBIL2(Boolean isInsert, Opportunity opp){
        
         Applicant__c app =new Applicant__c(Name='test',
                                           Contact_Number__c ='1234567891',
                                           Customer_First_Name__c = 'Pooja',
                                            Customer_Last_Name__c = 'Rao',
                                            Applicant_Type__c = 'Borrower',
                                            Loan_Amount__c = 300000,
                                            Current_Same_As_Permanent__c = True,
                                            Is_Existing_Customer__c = True,
                                            Father_s_name__c = '',
                                            Mother_s_name__c = 'Seeta',
                                            Spouse_Name__c = 'Seema',
                                            Email_Id__c = 'pooja@gmail.com',
                                            Consent_Received__c=true,
                                            Income_Ca__c='SAL',
                                            Profile__c = 'Software Engineer',
                                            Bureau_Pull_Attempts__c=1,
                                            Selfie_Retry_Attempts__c=2,
                                            Income_Source__c='Non-Earning',
                                            Declared_income__c=45000,
                                            Opportunity__c = opp.Id,
                                            Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-4));
                                            
         if(isInsert){
            insert app;
        }
        return app;
    }
    
    public static Customer_dedupe_response__c createCustomerDedupeResponse(Boolean isInsert, Applicant__c app){
        
        Customer_dedupe_response__c custDedupe = new Customer_dedupe_response__c(Applicant__c=app.Id,CIN_No__c='BBVLDSKDSM6783123');
             
        if(isInsert){
            insert custDedupe;
        }
        return custDedupe;
        
    }
    
     public static Customer_dedupe_response__c createCustomerDedupeResponse2(Boolean isInsert, Applicant__c app){
        
        Customer_dedupe_response__c custDedupe = new Customer_dedupe_response__c(Applicant__c=app.Id,CIN_No__c='');
             
        if(isInsert){
            insert custDedupe;
        }
        return custDedupe;
        
    }
    
    public static Applicant__c createTestApplicantForSMSAPI(Boolean isInsert){
        
         Applicant__c app =new Applicant__c(Name='test',
                                           Customer_First_Name__c='GOURAB',
                                           Customer_Last_Name__c='GOSWAMI',
                                           Whatsapp_number__c='1231231231',
                                           Consent_Received__c=true,
                                            Income_Ca__c='SAL',
                                            Profile__c = 'Software Engineer',
                                            Opportunity__c = 'L-10122021-1685',
                                            Bureau_Pull_Attempts__c=1,
                                            Selfie_Retry_Attempts__c=2,
                                            Income_Source__c='Non-Earning',
                                            Preferred_address_for_communication__c = 'Permanent Address',
                                            of_family_members_residing_with_you__c = '2',
                                            Residence_country__c = 'India',
                                            Who_will_repay_the_loan__c = 'Borrower',
                                            Marital_status__c = 'SINGP',
                                            Spouse_Name__c = 'Sameer',
                                            Father_s_name__c = 'Viraa',
                                            Mother_s_name__c = 'Neeta',
                                            Communication_language__c = 'Hindi',
                                            Customer_Qualification__c = 'Bachelor of Arts',
                                            Email_Id__c = 'riya@gmail.com',
                                            OTP_for_borrower__c='9999',
                                            Office_Address_Line_1__c = 'Nagar',
                                            Office_Address_Line_2__c = 'Narendra Nagar',
                                            Office_PinCode__c = '440037',
                                            Employer_Business_Name__c = 'Nidhi',
                                            Office_City__c = 'Mumbai',
                                            Office_District__c = 'MAHARASHTRA',
                                            Office_State__c = 'MAHARASHTRA',
                                            Contact_number__c = '9888777877',
                                            Is_this_current_residence_cum_office__c = true,
                                            Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-4));
                                            
         if(isInsert){
            insert app;
        }
        return app;
    }
    
    public static String createTestWrapperForApplicantService(){
        
        Ind_ApplicantService.ApplicantDetailsWrapper aws = new Ind_ApplicantService.ApplicantDetailsWrapper();
        aws.applicantId = 'a0U710000008SyPEAU';
        aws.name = 'nidhi';
        aws.street = 'Nagar';
        aws.addLine = 'Narendra Nagar';
        aws.pincode = '440037';
        aws.city = 'Mumbai';
        aws.district = 'MAHARASHTRA';
        aws.State ='MAHARASHTRA';
        aws.contactNumber = '9888777877';
        return JSON.serialize(aws);
    }
    
     public static Opportunity createTestApplicantcamp(Boolean isInsert){
        Opportunity opp = new Opportunity( Name= 'Opportunity',
                                          StageName='Prospecting',
                                          Vehicle_Sub_Category__c= 'UIM',
                                         Employee_Name__c='Ravi Kumar',
                                         Employee_No__c='9876543212',
                                          Deal_Number__c = 'TUT06226H',
                                          //Parent_Deal_number__c = 'TUT06226H'
                                         Agent_BL_code__c='MPP',
                                         
                                          CloseDate=System.today().addMonths(1),
                                          OTP_for_borrower__c='99999',
                                          Applicant_Name__c='ayuyu',
                                          Mfr_Expence_Reimburse__c=32, 
                                          Mfr_Expence_Reimburse_Amt__c='6700',
                                          Mfr_Expence_Reimburse_Type__c='yhh' ,
                                          Mfr_Incentive__c=98,
                                          Main_Dealer_Incentive_Amount__c=76,
                                          Sub_Dealer_Ancentive_Amount__c=8798,
                                          DSM_Incentive1__c=767,
                                          DSM_Incentive2__c=65 ,
                                          DSM_Name1__c='bhgb' ,
                                          DSM_Name2__c='hhg', 
                                          Dealer_Disc_to_Customer__c='878',
                                          Dealer_Expence_Reimburse_Type__c='hgfh',
                                          Gift_through_Dealer_Amount__c='866', 
                                          Required_Tenure__c=7,
                                          Non_Dealer_DSM_Name1__c='jhfgh',
                                          Non_Dealer_DSM_Name2__c='jhhf',
                                          Non_Dealer_DSM_Incentive1__c=776, 
                                          Non_Dealer_DSM_Incentive2__c=766,
                                          Required_ROI__c=5,
                                          Service_Charges__c='76',
                                         // Parent_Deal_number__c='7878',
                                          Documentation_Charges__c='98',
                                          Stamping_Charges__c='87',
                                          Loan_amount__c='400000',
                                          Contact_number__c = '415.555.1212',
                                          Front_Upload_Attempts__c=0,
                                          Back_Upload_Attempts__c=0,
                                          Selfie_Retry_Attempts__c=2,
                                          Vehicle_Type__c = 'New',
                                          Variant__c = 'SWIFTVDI6',
                                          //Lead_Number__c='L-10122021-1685',
                                          Product_Type__c='Passenger Vehicles',
                                          Vehicle_Registration_Number__c = 'PY05J3039');
        if(isInsert){
            insert opp;
        }
        return opp;
    }
    
    
     public static Opportunity createTestOpportunitydealmaster(Boolean isInsert){
        Opportunity opp = new Opportunity( Name= 'Opportunity',
                                          StageName='Prospecting',
                                          Vehicle_Sub_Category__c= 'UIM',
                                         Employee_Name__c='Ravi Kumar',
                                         Employee_No__c='9876543212',
                                          Deal_Number__c = 'TUT06226H',
                                          //Parent_Deal_number__c = 'TUT06226H'
                                         Agent_BL_code__c='MPP',
                                         
                                          CloseDate=System.today().addMonths(1),
                                          OTP_for_borrower__c='99999',
                                          Applicant_Name__c='ayuyu',
                                          Mfr_Expence_Reimburse__c=32, 
                                          Mfr_Expence_Reimburse_Amt__c='6700',
                                          Mfr_Expence_Reimburse_Type__c='yhh' ,
                                          Mfr_Incentive__c=98,
                                          Main_Dealer_Incentive_Amount__c=76,
                                          Sub_Dealer_Ancentive_Amount__c=8798,
                                          DSM_Incentive1__c=767,
                                          DSM_Incentive2__c=65 ,
                                          DSM_Name1__c='bhgb' ,
                                          DSM_Name2__c='hhg', 
                                          Dealer_Disc_to_Customer__c='878',
                                          Dealer_Expence_Reimburse_Type__c='hgfh',
                                          Gift_through_Dealer_Amount__c='866', 
                                          Required_Tenure__c=7,
                                          Non_Dealer_DSM_Name1__c='jhfgh',
                                          Non_Dealer_DSM_Name2__c='jhhf',
                                          Non_Dealer_DSM_Incentive1__c=776, 
                                          Non_Dealer_DSM_Incentive2__c=766,
                                          Required_ROI__c=5,
                                          Service_Charges__c='76',
                                         // Parent_Deal_number__c='7878',
                                          Documentation_Charges__c='98',
                                          Stamping_Charges__c='87',
                                          Loan_amount__c='400000',
                                          Contact_number__c = '415.555.1212',
                                          Front_Upload_Attempts__c=0,
                                          Back_Upload_Attempts__c=0,
                                          Selfie_Retry_Attempts__c=2,
                                          Vehicle_Type__c = 'New',
                                          Variant__c = 'SWIFTVDI6',
                                          Lead_Number__c='L-10122021-1685',
                                          Product_Type__c='Passenger Vehicles',
                                          Vehicle_Registration_Number__c = 'PY05J3039');
        if(isInsert){
            insert opp;
        }
        return opp;
    }
    
     public static Opportunity createTestOpportunityltv(Boolean isInsert){
        Opportunity opp = new Opportunity( Name= 'Opportunity',
                                          StageName='Prospecting',
                                          Vehicle_Sub_Category__c= 'UIM',
                                         Employee_Name__c='Ravi Kumar',
                                         Employee_No__c='9876543212',
                                          Deal_Number__c = 'TUT06226H',
                                          //Parent_Deal_number__c = 'TUT06226H'
                                         Agent_BL_code__c='MPP',
                                         
                                          CloseDate=System.today().addMonths(1),
                                          OTP_for_borrower__c='99999',
                                          Applicant_Name__c='ayuyu',
                                          Mfr_Expence_Reimburse__c=32, 
                                          Mfr_Expence_Reimburse_Amt__c='6700',
                                          Mfr_Expence_Reimburse_Type__c='yhh' ,
                                          Mfr_Incentive__c=98,
                                          Main_Dealer_Incentive_Amount__c=76,
                                          Sub_Dealer_Ancentive_Amount__c=8798,
                                          DSM_Incentive1__c=767,
                                          DSM_Incentive2__c=65 ,
                                          DSM_Name1__c='bhgb' ,
                                          DSM_Name2__c='hhg', 
                                          Dealer_Disc_to_Customer__c='878',
                                          Dealer_Expence_Reimburse_Type__c='hgfh',
                                          Gift_through_Dealer_Amount__c='866', 
                                          Required_Tenure__c=7,
                                          Non_Dealer_DSM_Name1__c='jhfgh',
                                          Non_Dealer_DSM_Name2__c='jhhf',
                                          Non_Dealer_DSM_Incentive1__c=776, 
                                          Non_Dealer_DSM_Incentive2__c=766,
                                          Required_ROI__c=5,
                                          Service_Charges__c='76',
                                         // Parent_Deal_number__c='7878',
                                          Documentation_Charges__c='98',
                                          Stamping_Charges__c='87',
                                          Loan_amount__c='400000',
                                          Contact_number__c = '415.555.1212',
                                          Front_Upload_Attempts__c=0,
                                          Back_Upload_Attempts__c=0,
                                          Selfie_Retry_Attempts__c=2,
                                          Vehicle_Type__c = 'New',
                                          Variant__c = 'SWIFTVDI6',
                                          //Lead_Number__c='L-10122021-1685',
                                          Product_Type__c='Passenger Vehicles',
                                          Vehicle_Registration_Number__c = 'PY05J3039');
        if(isInsert){
            insert opp;
        }
        return opp;
    }
     public static Documents__c createTestDocumentITR(Boolean isInsert, Applicant__c applicant, Opportunity opp){
         //Applicant__c applicant=createTestApplicant(true);
         Documents__c document = new Documents__c( Applicant__c =applicant.id,
                                                    Name= ' Test Document',
                                                     DocAuth_Passed__c = true,
                                                     KYC_DOB__c= Date.newInstance(1991, 06, 05 ),
                                                     PAN_No__c='AKPPC2739K',    
                                                     Selfie_report_Pass__c = true,
                                                     Golden_Source_Pass__c = true,
                                                     Proof_of_Identity_POI__c = false,
                                                     Name_Mismatch_Percentage__c = 00,
                                                     Is_Photocopy__c=true,
                                                     Opportunity_Relation__c=opp.Id,
                                                     Document_Type__c='PAN',
                                                     Name_Mismatch_Pass__c = true,
                                                 	is_Active__c=true);
        if(isInsert){
            insert document;
        }
        return document;
    }
    public static Income_Details__c createIncomeDetailsRecord(){        
        Income_Details__c incomeDetails = new Income_Details__c(Capture_Income_Method__c = 'Online via link',
                                                                Employer_Business_Name__c = 'Test',
                                                                Is_Salaried__c = false,
                                                                Is_Self_Employed__c = true,
                                                                Office_Address_Line_1__c = 'Nagar',
                                                                Office_Address_Line_2__c = 'Narendra Nagar',
                                                                Office_PinCode__c = '440037',
                                                                Office_City__c = 'Mumbai',
                                                                Office_District__c = 'MAHARASHTRA',
                                                                Office_State__c = 'MAHARASHTRA', 
                                                                Primary_Income_Source__c = true,
                                                                From_Month__c='2021-01',
                                                                To_Month__c='2021-08',
                                                                Income__c = 890,
                                                                Is_this_current_residence_cum_office__c = true);        
        return incomeDetails;
    }

    /*
     * @Method:      createTestEMI
     * @Created by:  Haarika Chodisetti
     * @Description: creates a new Existing_EMI__c  record
     * @Param:       isInsert (Boolean)
     * @Return:      Existing_EMI__c
     History
     Date            Author              Comments
     -------------------------------------------------------------
     07-09-2022      Haarika Chodisetti         Created
     ------------------------------------------------------------*/
    public static Existing_EMI__c createTestEMI(Boolean isInsert){
        Existing_EMI__c emi =new Existing_EMI__c(
                                         Loan_Type__c ='Personal Loan',
                                         Outstanding_Amount__c=50000,
                                         Upper_EMI_Limit__c=25000,
                                         Lower_EMI_Limit__c=15000,
                                         EMI__c=18000);

        if(isInsert){
           insert emi;
       }
       return emi;
   }
    /*
     * @Method:      createTestEMIwithApp
     * @Created by:  Haarika Chodisetti
     * @Description: creates a new Existing_EMI__c  record w.r.t the passed applicant
     * @Param:       isInsert (Boolean)
     *               applicant (Applicant__c)
     * @Return:      Existing_EMI__c
     History
     Date            Author              Comments
     -------------------------------------------------------------
     07-09-2022      Haarika Chodisetti         Created
     ------------------------------------------------------------*/
    public static Existing_EMI__c createTestEMIwithApp(Boolean isInsert, Applicant__c applicant){
        Existing_EMI__c emi =new Existing_EMI__c(
                                         Loan_Type__c ='Personal Loan',
                                         Outstanding_Amount__c=50000,
                                         Upper_EMI_Limit__c=25000,
                                         Lower_EMI_Limit__c=15000,
                                         EMI__c=18000,
        								 Applicant_Id__c = applicant.Id);



        if(isInsert){
           insert emi;
       }
       return emi;
   }

    /*
     * @Method:      createTestEMI
     * @Created by:  Haarika Chodisetti
     * @Description: creates a new Final_Term__c  record with Opportunity Id
     * @Param:       isInsert (Boolean)
     *               opp (Opportunity)
     * @Return:      Final_Term__c
     History
     Date            Author              Comments
     -------------------------------------------------------------
     07-09-2022      Haarika Chodisetti         Created
     ------------------------------------------------------------*/
    public static Final_Term__c createfinalTerm(Boolean isInsert, Opportunity opp){
        Final_Term__c finalTerm = new Final_Term__c(
            									Loan_Amount__c = '1000000',
            									Tenure__c = '60',
            									Net_IRR__c = 7,
            									EMI_Amount__c = 10000,
            									Loan_Application__c = opp.Id);
        if(isInsert){
           insert finalTerm;
       }
       return finalTerm;
    }
   public static Schemes__c createScheme(Boolean isInsert){
    Schemes__c schemeObject = new Schemes__c( Name= 'Platform launch',DocCharges__c=15,ServiceCharges__c=20, FromDate__c=System.today().addMonths(-1), ExistingCustomer__c=true);
       if(isInsert){
           insert schemeObject;
       }
       return schemeObject;
    }


//emi
public static Applicant__c createTestApplicantforEMI(Boolean isInsert){
    Opportunity oppEMI = TestDataUtility.createTestOpportunity(true);
        
    Applicant__c app =new Applicant__c(Name='EMI test',
                                      Contact_Number__c ='1234567891',
                                      Customer_First_Name__c='GOURAB',
                                      Customer_Last_Name__c='GOSWAMI',
                                      Whatsapp_number__c='1231231231',
                                      Consent_Received__c=true,
                                      Opportunity__c ='00671000001E0PNAA0',
                                       Income_Ca__c='SAL',
                                       Profile__c = 'Software Engineer',
                                       Bureau_Pull_Attempts__c=1,
                                       Selfie_Retry_Attempts__c=2,
                                       Income_Source__c='Non-Earning',
                                       Income_source_available__c = true,
                                       Preferred_address_for_communication__c = 'Home',
                                       of_family_members_residing_with_you__c = '2',
                                       Residence_country__c = 'India',
                                       Who_will_repay_the_loan__c = 'Borrower',
                                       Marital_status__c = 'SINGP',
                                       Spouse_Name__c = 'Sameer',
                                       Father_s_name__c = 'Viraa',
                                       Mother_s_name__c = 'Neeta',
                                       Communication_language__c = 'Hindi',
                                       Customer_Qualification__c = 'Bachelor of Arts',
                                       Email_Id__c = 'riya@gmail.com',
                                       DocAuth_Application_Id__c = 'AC1241_24524353_g1',
                                       Applicant_Type__c ='Borrower',
                                       Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-4));
   
                                
                                       
    if(isInsert){
       insert app;
   }
   return app;
}
    
    public static Benefi__c createTestBenMaster(Boolean isInsert){
        Benefi__c ben = new Benefi__c();
        ben.Dealer_Code__c = 'abc';
        ben.Ben_code__c = 'abc';
        ben.Name= 'abc';
        ben.Status_Flag__c= 'L';
        ben.Beneficiary__c = 'DLR';
        
       if(isInsert){
           insert ben;
       }
       return ben;
    }

    public static Case createTestCase(Boolean isInsert, Opportunity opp, Applicant__c applicant){
        Case cse =new Case(CMU_Accept__c = false, 
                            Loan_Application__c = opp.id, 
                            Applicant__c = applicant.Id,
                            Subject = 'OfficeFI',
                            Status = 'New');

        if(isInsert){
            insert cse;
        }
        return cse;
    }

    public static Field_Investigation__c createTestFieldInvestigation(Boolean isInsert, Case cse){
        Id residenceFIRecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Residence').getRecordTypeId();
        Field_Investigation__c fiRecord =new Field_Investigation__c(Case__c = cse.Id,
                                                Address_Line_1__c = 'Test area 1',
                                                Address_Line_2__c = 'Test area 2',
                                                City__c = 'Test city',
                                                Pin_Code__c = '234534',
                                                State__c = 'Test state',
                                                Landmark__c = 'Test landmark',
                                                Phone_Number__c = '0803453643',
                                                Mobile__c = '9342432564',
                                               // Name = 'Field Investigation Name',
                                                Product__c = 'Test product 2',
                                               // Residence_Type__c = 'Owned',
                                                RecordTypeId = residenceFIRecordTypeId);

        if(isInsert){
            insert fiRecord;
        }
        return fiRecord;
    }
    
    public static AccountTeamMember createAccountTeamMember(Boolean isInsert, String role) {
        Account acc = [select Id from Account LIMIT 1];
        AccountTeamMember atm = new AccountTeamMember(AccountId = acc.Id, UserId = UserInfo.getUserId(),
                                                     TeamMemberRole = role);
        if(isInsert) {
            insert atm;
        }
        return atm;
    }
    
    public static Case createCaseByRecordType(Boolean isInsert, String recordType) {
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        Case caseObj = new Case(RecordTypeId = caseRecordTypeId);
        if(isInsert) {
            insert caseObj;
        }
        return caseObj;
    }  
    
    public static User createUser(Boolean isInsert, String profileName){
        
      
        Profile p=getProfile(profileName);
        User userObj = new User(Alias = 'standt', Email='standarduser@testorg.com',
                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                    LocaleSidKey='en_US', ProfileId = p.Id,MobilePhone = '9701498575',Maker_Id__c='100001',
                    TimeZoneSidKey='America/Los_Angeles',
                    UserName='standarduser4@testorg.com.psdev1');
         if(isInsert) {
            insert userObj;
        }
        return    userObj; 
    }
    
    
    public static Profile getProfile(String profileName){
         return [SELECT Id FROM Profile WHERE Name =:profileName];
        
        
    }
    
    
    public  static RequestWrapper getRequestWrapper(){
        RequestWrapper requestWrapperObj =new RequestWrapper();
        Applicant__c applicant=createTestApplicant(true);
        requestWrapperObj.applicantId=String.valueOf(applicant.Id);
        requestWrapperObj.panNumber='ADIPS1045P';
        requestWrapperObj.firstName='TestFirstName';
        requestWrapperObj.lastName='TestLastName';
        requestWrapperObj.dlNumber='DLDAP28102993';
        requestWrapperObj.dateOfBirth='26/June/1982';
        requestWrapperObj.telephoneNumber='1234567890'; 
        //requestWrapperObj.borrowerPresentAddress='Test Address 1';
        //requestWrapperObj.coBorrowerPresentAddress='Test Address 1';
        //requestWrapperObj.coBorrowerNIP='TestNIP';
        //requestWrapperObj.borrowerNIP='Form60';
        return requestWrapperObj;
    }
    
    public static Opportunity createTestOpportunity1(Boolean isInsert){
        Opportunity opp = new Opportunity();
            opp.StageName = 'Qualification';
            opp.CloseDate = Date.newInstance(2021, 1, 11);            
            opp.Name = 'testone';
            
        if(isInsert){
            insert opp;
        }
        return opp;
    }
    public static Opportunity createTestOpportunity3(Boolean isInsert){
        Opportunity opp = new Opportunity();
            opp.StageName = 'Qualification';
            opp.CloseDate = Date.newInstance(2021, 1, 11);            
            opp.Name = 'testone';
            opp.Lead_number__c = '12345';
            
        if(isInsert){
            insert opp;
        }
        return opp;
    }
     public static Opportunity createTestOpportunity4(Boolean isInsert){
        Opportunity opp = new Opportunity();
            opp.StageName = 'Qualification';
            opp.CloseDate = Date.newInstance(2021, 1, 11);            
            opp.Name = 'testone';
            opp.Lead_number__c = '12345';
            opp.Product_Type__c = 'ALL';
            
        if(isInsert){
            insert opp;
        }
        return opp;
    }
     public static Applicant__c createTestApplicatnt1(Boolean isInsert){
        Applicant__c apgr1 = new Applicant__c();
        apgr1.Contact_number__c = '9743514830';
        apgr1.Applicant_Type__c = 'Borrower';
            
        if(isInsert){
            insert apgr1;
        }
        return apgr1;
    }
    public static Applicant__c createTestApplicatnt2(Boolean isInsert){
        Applicant__c apgr1 = new Applicant__c();
        apgr1.Contact_number__c = '9743514830';
        apgr1.Applicant_Type__c = 'Borrower';
        apgr1.Gender__c ='MALE';
            
        if(isInsert){
            insert apgr1;
        }
        return apgr1;
    }
     public static Applicant__c createTestApplicatnt3(Boolean isInsert){
        Applicant__c apgr1 = new Applicant__c();
        apgr1.Contact_number__c = '9743514830';
        apgr1.Applicant_Type__c = 'Borrower';
        apgr1.Gender__c ='MALE';
        apgr1.Income_Ca__c ='NE';
            
        if(isInsert){
            insert apgr1;
        }
        return apgr1;
    }
    public static Applicant__c createTestApplicatnt4(Boolean isInsert){
        Applicant__c apgr1 = new Applicant__c();
        apgr1.Contact_number__c = '9743514830';
        apgr1.Applicant_Type__c = 'Borrower';
        apgr1.Gender__c ='MALE';
        apgr1.Income_Ca__c ='NE';
        apgr1.Marital_status__c = 'MARR';
                
        if(isInsert){
            insert apgr1;
        }
        return apgr1;
    }
    public static Applicant__c createTestApplicatnt5(Boolean isInsert){
        Applicant__c apgr1 = new Applicant__c();
        apgr1.Contact_number__c = '9743514830';
        apgr1.Applicant_Type__c = 'Borrower';
        apgr1.Gender__c ='MALE';
        apgr1.Income_Ca__c ='NE';
        apgr1.Marital_status__c = 'MARR';
        apgr1.Residence_country__c = 'India';
                
        if(isInsert){
            insert apgr1;
        }
        return apgr1;
    }
    public static Applicant__c createTestApplicatnt6(Boolean isInsert){
        Applicant__c apgr1 = new Applicant__c();
        apgr1.Contact_number__c = '9743514830';
        apgr1.Applicant_Type__c = 'Borrower';
        apgr1.Gender__c ='MALE';
        apgr1.Income_Ca__c ='NE';
        apgr1.Marital_status__c = 'MARR';
        apgr1.Residence_country__c = 'India';
        apgr1.Profile__c = 'Un-Employed';
        if(isInsert){
            insert apgr1;
        }
        return apgr1;
    }
    public static Documents__c createTestDLDocs1(boolean isInsert, Applicant__c applicant, Opportunity opp){
        Documents__c doc = new Documents__c(Applicant__c =applicant.id, Name = 'testDocument',Opportunity_Relation__c=opp.id);
        if(isInsert){
            insert doc;
        }
        return doc;
    }
      public static Product2 createTestProduct2(Boolean isInsert){
        
           Product2 prd1 = new Product2();
                prd1.Asset_Category__c = 'te';
                prd1.Capacity_1__c = 1000.00;
                prd1.Capacity_2__c = 2000.00;
                prd1.Capacity_Units_1__c = 'test12';
                prd1.Capacity_Units_2__c = 'test13';
                prd1.Type__c = 'Make';
                prd1.External_Reference_Id__c = '58568568';
                prd1.Name = 'PASSENGER VEHICLES';
              
         if(isInsert){
            insert prd1;
        }
        return prd1;
    }

    public static Repayments__c createTestRepayments(boolean isInsert,Opportunity opp){
        Repayments__c repayment = new Repayments__c(Repayment_to_be_done_by__c='XYZ', /*Bank_Master__r.Name='', */IFSC_Code__c='HDFC0000001',
                                                    Account_Number__c='342342344567893', 
                                                    Created_Date__c=Date.newInstance(2022, 02, 08 ),
                                                    End_Date__c=Date.newInstance(2030, 02, 08 ), Frequency__c='Monthly',
                                                    EMI_Amount__c=4546, Loan_Application__c=opp.Id);
        if(isInsert){
            insert repayment;
        }
        return repayment;
    }
    
    public static Repayments__c createTestRepayments1(boolean isInsert,Opportunity opp){
        Repayments__c repayment1 = new Repayments__c(Repayment_to_be_done_by__c='ABC', IFSC_Code__c='HDFC0000001',
                                                    Account_Number__c='342342344567644', 
                                                    Created_Date__c=Date.newInstance(2022, 02, 08 ),
                                                    End_Date__c=Date.newInstance(2030, 02, 08 ), Frequency__c='As Presented',
                                                    EMI_Amount__c=4566, Loan_Application__c=opp.Id);
        if(isInsert){
            insert repayment1;
        }
        return repayment1;
    }

    public static Applicant__c createTestApplicantService(Boolean isInsert,Opportunity opp){
        
        Applicant__c app =new Applicant__c(Name='test',
                                          Contact_Number__c ='1234567891',
                                          Customer_First_Name__c='GOURAB',
                                          Customer_Last_Name__c='GOSWAMI',
                                          Whatsapp_number__c='1231231231',
                                          Consent_Received__c=true,
                                          Opportunity__c = opp.Id,
                                           Income_Ca__c='SAL',
                                           Profile__c = 'Software Engineer',
                                           Bureau_Pull_Attempts__c=1,
                                           Selfie_Retry_Attempts__c=2,
                                           Income_Source__c='Non-Earning',
                                           Income_source_available__c = true,
                                           Preferred_address_for_communication__c = 'Permanent Address',
                                           of_family_members_residing_with_you__c = '2',
                                           Residence_country__c = 'India',
                                           Who_will_repay_the_loan__c = 'Borrower',
                                           Marital_status__c = 'SINGP',
                                           Spouse_Name__c = 'Sameer',
                                           Father_s_name__c = 'Viraa',
                                           Mother_s_name__c = 'Neeta',
                                           Communication_language__c = 'Hindi',
                                           Customer_Qualification__c = 'B2',
                                           Email_Id__c = 'riya@gmail.com',
                                           DocAuth_Application_Id__c = 'AC1241_24524353_g1',
                                           Applicant_Type__c ='Borrower',
                                           In_Active_Applicant__c = false,
                                           Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-4));
       
                                   
                                           
        if(isInsert){
           insert app;
       }
       return app;
   }
    
   public static CASA_Bank_Form__c  createTestCASADetails(boolean isInsert, Opportunity opsd1,Applicant__c applicant){
        CASA_Bank_Form__c casadetails = new CASA_Bank_Form__c(
            Applicant__c =applicant.id,Loan_Application__c = opsd1.Id,
            Nominee_address__c = 'test',Nominee_available__c = true,
            Nominee_City__c = 'test',Nominee_DOB__c = System.today(),
            Nominee_name__c = 'test',Nominee_Pin_Code__c = 12345,
            Nominee_State__c = 'ANDAMAN NICOBAR ISLANDS', Relationship_with_borrower__c = 'test'
        );
        if(isInsert){
            insert casadetails;
        }
        return casadetails;
    }

    public static Finacle_City__c  createFinacle(boolean isInsert){
        Finacle_City__c finacle = new Finacle_City__c(
        Name = 'Alabama',
        City_Code__c = 'AL'
        );
        if(isInsert){
        insert finacle;
    }
    return finacle;
    }

    public static TeleVerification__c  createTestTeleverificationDetails(boolean isInsert, Opportunity opsd1,Applicant__c applicant,Case cse,Finacle_City__c finacle,Income_Details__c income){
        TeleVerification__c teledetails = new TeleVerification__c(
            Applicant__c =applicant.id,Loan_Application__c = opsd1.Id,
            Address_verified_with_KYC_CR__c = true,Address_verified_with_KYC_PR__c = true,
            Amount_paid__c = 10000,Attempts__c = 1,
            Case__c = cse.Id,Cheque_bounce_charges_informed__c = true,
            Customer_Informed_Provide_KYC_in_3Month__c = true, Did_you_get_any_receipt__c = true,
            Finacle_City__c = finacle.Id,Has_the_vehicle_been_delivered__c = true,
            Have_original_KYC_verified_atleast_once__c = true,Have_you_applied_for_a_loan__c = true,
            Income_Details__c = income.Id, Is_customer_having_an_Aadhar_Card__c = true,
            Is_customer_s_Mob_No_linked_to_Aadhar__c = true , Is_customer_using_Aadhar_Linked_Mob_No__c = true,
            Land_Mark__c = 'test' , Margin_Money_Paid__c = true,Money_asked_for_processing_Down_Payment__c = true,
            Name = 'Borrower',No_of_years_in_business_current_emplo__c = 10,Provide_Update_KYC_in_3_Months__c = true,
            Purpose_of_purchasing_the_vehicle__c = 'test',Remarks_in_RemarkSection__c = 'test',
            Remark__c = 'test',SA_account_opened_for__c = 'Borrower',To_Whom_Margin_Money_Paid__c = 'Dealer',
            TVR_assessment__c = 'High Risk',Who_will_be_the_end_user_of_the_product__c = 'Applicant'
        );
        if(isInsert){
            insert teledetails;
        }
        return teledetails;
    }

    public static Documents__c createTestCustDoc(boolean isInsert, Applicant__c applicant, Opportunity opp, Case cse){
        Documents__c doc = new Documents__c(Applicant__c =applicant.id, Name = 'testDocument',Document_Type__c = 'Passport',
                                            Passport_File_No__c = '',Passport_No__c='U6926433' ,Salutation__c= 'Mr.',PAN_No__c='AQSPV3101D',
                                            KYC_DOB__c= Date.newInstance(1990, 02, 08 ),Gender__c='MALE',
                                            Opportunity_Relation__c=opp.id,Is_Front__c = true,Document_Side__c ='Front',
                                            KYC_Address_Line_1__c = 'Mumbai',KYC_Address_Line_2__c = 'Mumbai',Addresss_Type__c = 'Current Residential Address',
                                            KYC_City__c = 'Mumbai',KYC_District__c = 'Mumbai',KYC_Expiry_Date__c = Date.newInstance(2030, 02, 08 ),
                                            KYC_State__c = 'Maharastra',KYC_Pin_Code__c = '400012',KYC_Issuance_Date__c = Date.newInstance(2010, 02, 08 ),KYC_name__c = 'VIBU S',KYC_No__c = Integrationutilities.getencryptedrequest('987653234567',System.Label.privateKey,System.Label.ivkey),
                                            OTP_for_borrower__c='9999', Case__c=cse.Id ); //Date.newInstance(1999, 05, 04 )
        if(isInsert){
            insert doc;
        }
        return doc;
    }
    //isWorking
    public static Deal_Number__c createDealNumber(boolean isInsert, Opportunity opp){
        Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
            dlNumberSetting.Name = System.Label.Tractor;
            dlNumberSetting.MDNField1__c ='AB';
            dlNumberSetting.MDNField2__c = 2.0;
            insert dlNumberSetting;
        
        
        Deal_Number__c dl=new Deal_Number__c();
        dl.Loan_Application__c = opp.Id;
            dl.DNField1__c = dlNumberSetting.MDNField1__c;
            dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c.round());
            //dl.Sub_Stage__c = 'test';
          if(isInsert){
            insert dl;
        }
        return dl;
    } 
}