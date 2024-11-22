/*------------------------------------------------------------
Author:        Satyam More
Company:       Persistent Systems
Description:   Test class created to validate the IND_VahanVehicleReportRequest IND_VahanVehicleReportService IND_VahanVehicleReportResponse class
History
Date            Author              Comments
-------------------------------------------------------------
23-12-2021      Satyam More       Created
------------------------------------------------------------*/

@isTest(SeeAllData=false)
public class IND_VahanVehicleReportService_Test {
    
    @isTest
    public static void testVahanVehicleReportService(){
        
        try{   
            
            Profile p = [SELECT Id FROM Profile WHERE Name='IBL Counter Staff'];
            system.debug('p'+ p);
    		User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
					EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
					LocaleSidKey='en_US', ProfileId = p.Id,
					TimeZoneSidKey='America/Los_Angeles',MobilePhone='0123456789',Maker_Id__c='1002',

					UserName='standarduser4@testorg.com.psdev1');
            insert u;
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            String vahanVehicleReport = '{"leadId":"'+opp.Lead_number__c+'" ,"vehicleRegisterationNumber":"'+opp.Vehicle_Registration_Number__c+'"}';
            
            Continuation con = (Continuation)IntegrationEngine.doVahanVehicleReportCallout(vahanVehicleReport);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"f3U2xrqk3erkhq1xxOr+S8/57VD7sQmb49TNN+RvxQZ6Aundr1zSv6p381eT+1JELHhzHmsyPeLfU+9bBBr+XRUv0yby+IZMmUDrWTFm06W5aPPHWiePrNz87ITpUGmKEjd7c+RXBwQ44Bp7TIT/LKDxky0Xlj3RWfqWCU/ZRNnBfR1i4TDtP07jzBXZXZmVb2d1rGX9XdDqJoQovLnL7b/XGXgki3DTp65LAwEkn2znWVTTsdBaz00EoZmLFzylMBSq7viqj4I7GuX9EIgbktP2Je0BS9xpFx0YZfmQaJjGVxBYS1xegMpxAJhfODkdy8uYocKVXjQfr2HXqrXyc67e9OhSg39QLnVdbIjLXv574LQNtcHt0pKJTn4oRKeYNhR5y+n2JOWuILiPlpO+Rls6BojMOFXLU3Uhi7GBuZiRExr8UjMf9IXjN8x7sPaamL96h6MUift8qQgnacvGapaZNTHjLP2NKHB5sQjdyiS0gVpE6sdbD+fgoPMchVS7JadwHuBum9YuoZ94hOru3V5H2fmtqSkfxaJbHsvSqqmaiIrCHNi6HXlXmMu1ZA+ew7UVEc7yvnJEQQKMs1J/bs6jeetIxjanJiqxsyYWdT87eyuxKvOrOKrFois0aB0mK5sfzM0U1f6EtQW+oinCc8Im2DRyscNaE4gUG8ylC3XGd8nxJPVaEMWZSoIVi+Ncef0RHI4icHGKG2wvB1lbdtajdQDta1ehe4kHO4kU2IHgY4zlXe7L6Kb5mNqtoghtSuW8gim04FmQ9YNNBfD1wNt/ngJNRvgwA89cK+mvawC4/iBBUV1uHGHo2aBuN1bbtaYt/6XsjntcAigGyV74oSkm8S5l9zM/Fif3bMg/9W/G98gNSBl4WcOajmEY0GcRqErsUuF/k33Z46oKunxMRQE+eLhFvU+V8wCXbYILvpdG26wVVCf42VNYALlxyzmRKhXar+XcqxvCgZSOKT6DYU6xW6VY9qhxfEbAPWlpBd9F0S6EGAZ07YvxZ7Dx0eCoLGAJ4/eUXteK0EVht4iqgjCzbMiG2UY9sWngGC6fC4ew39xQhvCbU5YXZiSq2drPbC8nLfMZQNmQdBpvph07SqduGrr3rpSfjkUxBFq1irbDGQ3r4cmaYOba4l5jUH9YoGFJxhvmkCuBdwrwh2RmgC6honxjea8KE0tWlMIco6p/a6ERS4qEtwMurO54HKXxJnkRKEVAfDW1SGbZ4QjTEQwKbPBrbvZcT+LRdjQTZtc9cPhAKdt1McdjhnXscliby5leFv//v58mHxMoQdwyy5Qp20+rfLTOGdSq9EdcAG4ptxkXBONwynNoPnBUNJLyTOUPAIsn33Rpr4w+GnEgNfAINNzwF/ppB4CxyCLlQ2JEB24u2meWaGkaJ1NnsLzYyzaBRkeiDYVPhCqXk7cdIDTHJX61Bnkwr6W2cDHLg69COa/FW076hWUyga+bxFV315tudFsjkrR6VPMLMDy/eeGvO2j3D7iv6DHJ84kLQPa29Y6Sz6wfJjfFhHqrdHoigf8ptX8UJsiIxyxNp/1ClJNthOta5ehhqa1xRK/YsO+zLvHIwmUPam+sp9UY0E5GhSwHMB/h0ChfzferCKB7yu+QVDOozJpwF+VElhFRHSuICxPq4OVm/00GbHoZtXC5c2eYUeY/iSU2U+bLtl0ZU0PJGjdevunMP9JCYiSycd4wRilVHDhvpBs1P+2Hppve5kkhsueNZNAtSs1h6AfUjA=="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            
            String vahanVehicleReportCallOutResponse;
             system.runAs(u){
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            vahanVehicleReportCallOutResponse= (String)IntegrationEngine.processVahanVehicleReportResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
             }
            String responseExpected ='{"body":null,"response":{"status":"SUCCESS","respDesc":"VAHAN Report","content":[{"Wt_Laden":"NULL","Wheel_Base":"NULL","Vehicle_Place_of_Valuation":null,"Vehicle_Class":"M-Cycle/Scooter","Standing_Capacity":"NULL","Seating_Capacity":"NULL","Sale_Amount":"NULL","Registration_No":"PB91P0358","Registration_Date":"00:00.0","Purchase_Date":"NULL","Present_Address4":"NULL","Present_Address3":"NULL","Present_Address2":"NULL","Present_Address1":"B 3,264 NANDPUR  SAHNEWAL  41","Pan_Gir":"NULL","Owner_Sr_No":"1","Owner_Name":"JASKARANJOT SINGH","Owner_Contact_Number":null,"No_Of_Cylinders":"NULL","Manufacturer":"HERO MOTOCORP LTD","Maker_Model":"HF DELUXE (SELF-DRUM-CAST)","Insurer_Name":null,"Insurance_Number":null,"Ins_Issuance_Date":null,"Ins_Expiry_Date":null,"HorsePower":"NULL","Gross_Vehicle_Weight":"NULL","Fuel":"NULL","Fitness_Upto":"00:00.0","Father_name":"AVTAR SINGH","Engine_No":"HA11ESMHJ00299","Dealer":"FAMILIA AUTOS","Deal_No":"PLT01683H","Cubic_Capacity":"NULL","Color":"Grey Black","Chassis_No":"MBLHAW141MHJ00202","Body_Type":"SOLO WITH PILLION"}]}}';
            System.assertEquals(responseExpected, vahanVehicleReportCallOutResponse, 'SUCCESS');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'List has no rows for assignment to SObject');
        }
    }

    @isTest
    public static void testVahanVehicleReportService2(){
        
        try{   
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            String vahanVehicleReport = '{"leadId":"" ,"vehicleRegisterationNumber":"'+opp.Vehicle_Registration_Number__c+'"}';
            
            Continuation con = (Continuation)IntegrationEngine.doVahanVehicleReportCallout(vahanVehicleReport);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"f3U2xrqk3erkhq1xxOr+S8/57VD7sQmb49TNN+RvxQZ6Aundr1zSv6p381eT+1JELHhzHmsyPeLfU+9bBBr+XRUv0yby+IZMmUDrWTFm06W5aPPHWiePrNz87ITpUGmKEjd7c+RXBwQ44Bp7TIT/LKDxky0Xlj3RWfqWCU/ZRNnBfR1i4TDtP07jzBXZXZmVb2d1rGX9XdDqJoQovLnL7b/XGXgki3DTp65LAwEkn2znWVTTsdBaz00EoZmLFzylMBSq7viqj4I7GuX9EIgbktP2Je0BS9xpFx0YZfmQaJjGVxBYS1xegMpxAJhfODkdy8uYocKVXjQfr2HXqrXyc67e9OhSg39QLnVdbIjLXv574LQNtcHt0pKJTn4oRKeYNhR5y+n2JOWuILiPlpO+Rls6BojMOFXLU3Uhi7GBuZiRExr8UjMf9IXjN8x7sPaamL96h6MUift8qQgnacvGapaZNTHjLP2NKHB5sQjdyiS0gVpE6sdbD+fgoPMchVS7JadwHuBum9YuoZ94hOru3V5H2fmtqSkfxaJbHsvSqqmaiIrCHNi6HXlXmMu1ZA+ew7UVEc7yvnJEQQKMs1J/bs6jeetIxjanJiqxsyYWdT87eyuxKvOrOKrFois0aB0mK5sfzM0U1f6EtQW+oinCc8Im2DRyscNaE4gUG8ylC3XGd8nxJPVaEMWZSoIVi+Ncef0RHI4icHGKG2wvB1lbdtajdQDta1ehe4kHO4kU2IHgY4zlXe7L6Kb5mNqtoghtSuW8gim04FmQ9YNNBfD1wNt/ngJNRvgwA89cK+mvawC4/iBBUV1uHGHo2aBuN1bbtaYt/6XsjntcAigGyV74oSkm8S5l9zM/Fif3bMg/9W/G98gNSBl4WcOajmEY0GcRqErsUuF/k33Z46oKunxMRQE+eLhFvU+V8wCXbYILvpdG26wVVCf42VNYALlxyzmRKhXar+XcqxvCgZSOKT6DYU6xW6VY9qhxfEbAPWlpBd9F0S6EGAZ07YvxZ7Dx0eCoLGAJ4/eUXteK0EVht4iqgjCzbMiG2UY9sWngGC6fC4ew39xQhvCbU5YXZiSq2drPbC8nLfMZQNmQdBpvph07SqduGrr3rpSfjkUxBFq1irbDGQ3r4cmaYOba4l5jUH9YoGFJxhvmkCuBdwrwh2RmgC6honxjea8KE0tWlMIco6p/a6ERS4qEtwMurO54HKXxJnkRKEVAfDW1SGbZ4QjTEQwKbPBrbvZcT+LRdjQTZtc9cPhAKdt1McdjhnXscliby5leFv//v58mHxMoQdwyy5Qp20+rfLTOGdSq9EdcAG4ptxkXBONwynNoPnBUNJLyTOUPAIsn33Rpr4w+GnEgNfAINNzwF/ppB4CxyCLlQ2JEB24u2meWaGkaJ1NnsLzYyzaBRkeiDYVPhCqXk7cdIDTHJX61Bnkwr6W2cDHLg69COa/FW076hWUyga+bxFV315tudFsjkrR6VPMLMDy/eeGvO2j3D7iv6DHJ84kLQPa29Y6Sz6wfJjfFhHqrdHoigf8ptX8UJsiIxyxNp/1ClJNthOta5ehhqa1xRK/YsO+zLvHIwmUPam+sp9UY0E5GhSwHMB/h0ChfzferCKB7yu+QVDOozJpwF+VElhFRHSuICxPq4OVm/00GbHoZtXC5c2eYUeY/iSU2U+bLtl0ZU0PJGjdevunMP9JCYiSycd4wRilVHDhvpBs1P+2Hppve5kkhsueNZNAtSs1h6AfUjA=="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String vahanVehicleReportCallOutResponse= (String)IntegrationEngine.processVahanVehicleReportResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"response":{"status":"SUCCESS","respDesc":"VAHAN Report","content":[{"Wt_Laden":"NULL","Wheel_Base":"NULL","Vehicle_Class":"M-Cycle/Scooter","Standing_Capacity":"NULL","Seating_Capacity":"NULL","Sale_Amount":"NULL","Registration_No":"PB91P0358","Registration_Date":"00:00.0","Purchase_Date":"NULL","Present_Address4":"NULL","Present_Address3":"NULL","Present_Address2":"NULL","Present_Address1":"B 3,264 NANDPUR  SAHNEWAL  41","Pan_Gir":"NULL","Owner_Sr_No":"1","Owner_Name":"JASKARANJOT SINGH","No_Of_Cylinders":"NULL","Manufacturer":"HERO MOTOCORP LTD","Maker_Model":"HF DELUXE (SELF-DRUM-CAST)","HorsePower":"NULL","Gross_Vehicle_Weight":"NULL","Fuel":"NULL","Fitness_Upto":"00:00.0","Father_name":"AVTAR SINGH","Engine_No":"HA11ESMHJ00299","Dealer":"FAMILIA AUTOS","Deal_No":"PLT01683H","Cubic_Capacity":"NULL","Color":"Grey Black","Chassis_No":"MBLHAW141MHJ00202","Body_Type":"SOLO WITH PILLION"}]}}';
            System.assertEquals(responseExpected, vahanVehicleReportCallOutResponse, 'SUCCESS');
            
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),System.Label.LeadId, 'Exception');
        }
    }
    
    @isTest
    public static void testVahanVehicleReportService3(){
        
        try{   
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            String vahanVehicleReport = '{"leadId":"'+opp.Lead_number__c+'" ,"vehicleRegisterationNumber":""}';
            
            Continuation con = (Continuation)IntegrationEngine.doVahanVehicleReportCallout(vahanVehicleReport);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"f3U2xrqk3erkhq1xxOr+S8/57VD7sQmb49TNN+RvxQZ6Aundr1zSv6p381eT+1JELHhzHmsyPeLfU+9bBBr+XRUv0yby+IZMmUDrWTFm06W5aPPHWiePrNz87ITpUGmKEjd7c+RXBwQ44Bp7TIT/LKDxky0Xlj3RWfqWCU/ZRNnBfR1i4TDtP07jzBXZXZmVb2d1rGX9XdDqJoQovLnL7b/XGXgki3DTp65LAwEkn2znWVTTsdBaz00EoZmLFzylMBSq7viqj4I7GuX9EIgbktP2Je0BS9xpFx0YZfmQaJjGVxBYS1xegMpxAJhfODkdy8uYocKVXjQfr2HXqrXyc67e9OhSg39QLnVdbIjLXv574LQNtcHt0pKJTn4oRKeYNhR5y+n2JOWuILiPlpO+Rls6BojMOFXLU3Uhi7GBuZiRExr8UjMf9IXjN8x7sPaamL96h6MUift8qQgnacvGapaZNTHjLP2NKHB5sQjdyiS0gVpE6sdbD+fgoPMchVS7JadwHuBum9YuoZ94hOru3V5H2fmtqSkfxaJbHsvSqqmaiIrCHNi6HXlXmMu1ZA+ew7UVEc7yvnJEQQKMs1J/bs6jeetIxjanJiqxsyYWdT87eyuxKvOrOKrFois0aB0mK5sfzM0U1f6EtQW+oinCc8Im2DRyscNaE4gUG8ylC3XGd8nxJPVaEMWZSoIVi+Ncef0RHI4icHGKG2wvB1lbdtajdQDta1ehe4kHO4kU2IHgY4zlXe7L6Kb5mNqtoghtSuW8gim04FmQ9YNNBfD1wNt/ngJNRvgwA89cK+mvawC4/iBBUV1uHGHo2aBuN1bbtaYt/6XsjntcAigGyV74oSkm8S5l9zM/Fif3bMg/9W/G98gNSBl4WcOajmEY0GcRqErsUuF/k33Z46oKunxMRQE+eLhFvU+V8wCXbYILvpdG26wVVCf42VNYALlxyzmRKhXar+XcqxvCgZSOKT6DYU6xW6VY9qhxfEbAPWlpBd9F0S6EGAZ07YvxZ7Dx0eCoLGAJ4/eUXteK0EVht4iqgjCzbMiG2UY9sWngGC6fC4ew39xQhvCbU5YXZiSq2drPbC8nLfMZQNmQdBpvph07SqduGrr3rpSfjkUxBFq1irbDGQ3r4cmaYOba4l5jUH9YoGFJxhvmkCuBdwrwh2RmgC6honxjea8KE0tWlMIco6p/a6ERS4qEtwMurO54HKXxJnkRKEVAfDW1SGbZ4QjTEQwKbPBrbvZcT+LRdjQTZtc9cPhAKdt1McdjhnXscliby5leFv//v58mHxMoQdwyy5Qp20+rfLTOGdSq9EdcAG4ptxkXBONwynNoPnBUNJLyTOUPAIsn33Rpr4w+GnEgNfAINNzwF/ppB4CxyCLlQ2JEB24u2meWaGkaJ1NnsLzYyzaBRkeiDYVPhCqXk7cdIDTHJX61Bnkwr6W2cDHLg69COa/FW076hWUyga+bxFV315tudFsjkrR6VPMLMDy/eeGvO2j3D7iv6DHJ84kLQPa29Y6Sz6wfJjfFhHqrdHoigf8ptX8UJsiIxyxNp/1ClJNthOta5ehhqa1xRK/YsO+zLvHIwmUPam+sp9UY0E5GhSwHMB/h0ChfzferCKB7yu+QVDOozJpwF+VElhFRHSuICxPq4OVm/00GbHoZtXC5c2eYUeY/iSU2U+bLtl0ZU0PJGjdevunMP9JCYiSycd4wRilVHDhvpBs1P+2Hppve5kkhsueNZNAtSs1h6AfUjA=="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String vahanVehicleReportCallOutResponse= (String)IntegrationEngine.processVahanVehicleReportResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"response":{"status":"SUCCESS","respDesc":"VAHAN Report","content":[{"Wt_Laden":"NULL","Wheel_Base":"NULL","Vehicle_Class":"M-Cycle/Scooter","Standing_Capacity":"NULL","Seating_Capacity":"NULL","Sale_Amount":"NULL","Registration_No":"PB91P0358","Registration_Date":"00:00.0","Purchase_Date":"NULL","Present_Address4":"NULL","Present_Address3":"NULL","Present_Address2":"NULL","Present_Address1":"B 3,264 NANDPUR  SAHNEWAL  41","Pan_Gir":"NULL","Owner_Sr_No":"1","Owner_Name":"JASKARANJOT SINGH","No_Of_Cylinders":"NULL","Manufacturer":"HERO MOTOCORP LTD","Maker_Model":"HF DELUXE (SELF-DRUM-CAST)","HorsePower":"NULL","Gross_Vehicle_Weight":"NULL","Fuel":"NULL","Fitness_Upto":"00:00.0","Father_name":"AVTAR SINGH","Engine_No":"HA11ESMHJ00299","Dealer":"FAMILIA AUTOS","Deal_No":"PLT01683H","Cubic_Capacity":"NULL","Color":"Grey Black","Chassis_No":"MBLHAW141MHJ00202","Body_Type":"SOLO WITH PILLION"}]}}';
            System.assertEquals(responseExpected, vahanVehicleReportCallOutResponse, 'SUCCESS');
            
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),System.Label.VehicleRegistrationNumber, 'Exception');
        }
    }
    
    @isTest
    public static void testRes1(){
        
                Opportunity opgt1 = new Opportunity();
                opgt1.StageName = 'Qualification';
                opgt1.CloseDate = Date.newInstance(2021, 1, 11);
                opgt1.Name = 'testone';
                insert opgt1;
                
                Applicant__c apgt1 = new Applicant__c();
                apgt1.Opportunity__c = opgt1.Id;
                apgt1.Contact_number__c = '9743514830';
                apgt1.Applicant_Type__c = 'Borrower';
                insert apgt1;
        
                Income_Details__c idt1 = new Income_Details__c();
                idt1.Applicant__c = apgt1.Id;
                idt1.API_Transaction_Status__c = 'testapi';
                idt1.Bank_Account_Number__c = '32543409214';
                idt1.Client_Transaction_Id__c = 'testclient';
                idt1.Remarks__c = 'no comments';
                insert idt1;
            
                RequestWrapper rw1 = new RequestWrapper();
                rw1.applicantId = apgt1.Id;
                rw1.panNumber = apgt1.PAN_No__c;
                rw1.firstName = 'testone';
                rw1.lastName = 'testlast';
                rw1.dealNumber = 'testdl';
                rw1.dateOfBirth = '23061994';
                rw1.telephoneNumber = '9999999999';
                rw1.kycNo = '4635643';
                rw1.kycPassportFileNo = 'pt23556';
                rw1.kycGender = 'male';
                rw1.kycPassportNo = '232041';
                rw1.leadId = '676476368';
                rw1.email = 'test@gmail.com';
                rw1.income = '200000';
                rw1.aadhaarNo = '56678862431';
                rw1.dOB = Datetime.newInstance(1994, 6, 23, 12, 30, 0);
                rw1.vehicleRegisterationNumber = 'ap 26 1234';
                rw1.loanApplicationId = opgt1.Id;
                rw1.noOfCoborrowers = '8';
                rw1.vehicleType = 'TwoWheelers';
                rw1.CityId = '26';
                rw1.VariantCode = 'test123';
                rw1.customerCode = 'samplle123';
                rw1.oldDealNo = 'test453';
                rw1.nocNo = '45545667';
                rw1.product = 'testprd';
                rw1.category = 'motor';
                rw1.subCategory = 'testsub';
                rw1.applicantId = 'testapid';
                rw1.cicNo = '1234';
                rw1.emailTo = 'samplw@gmail.com';
                rw1.emailCC = 'testcc@gmail.com';
                rw1.emailSubject = 'testclass';
                rw1.emailBody = 'testbody';
                rw1.loanAmount = '1500000';
                rw1.loanDuration = '60';
                rw1.loanType = 'Personal';
                rw1.processingType = 'typeone';
                rw1.acceptancePolicy = 'test';
                rw1.uploadingScannedStatements = 'docs';
                rw1.yearMonthFrom = '6';
                rw1.yearMonthTo = '10';
                rw1.productType = 'vehicle';
                rw1.employmentType = 'permenant';
                rw1.employerName = 'dhoni';
                rw1.fileId = 'testfield';
                rw1.institutionId = '23';
                rw1.password = '12345';
                rw1.perfiosTransactionId = 'testper';
                rw1.uid = '134455';
                rw1.otp = '764345';
                rw1.txn = '4566633445';
                rw1.rnn = 'testrnn';
                rw1.applicantFirstName = 'mahi';
                rw1.applicantMiddleName = 'singh';
                rw1.applicantLastName = 'dhoni';
                rw1.name = 'name';
                rw1.destinationName = 'ap';
                rw1.destinationNames = 'ap';
                rw1.cinNo = 'testcin';
                rw1.applicationNo = '134355544655';
                rw1.vehicleId = 'v34566';
                rw1.age = '26';
                rw1.gender = 'male';
                rw1.insProduct = 'testprd';
                rw1.planCode = 'testplan';
                rw1.Fin_Amount = '50000';
                rw1.tenure = '36';
                rw1.dealNumber = 'Insurance Premium';
                rw1.Borrower_Type = 'Insurance Recommendation';
                rw1.Vehicle_Category = 'Insurance Recommendation';
                rw1.Variant = 'Insurance Recommendation';
                rw1.Fin_Amount = '1000';
                rw1.Balance_Available = '100';
                rw1.Agreement_Value = '10000';
                rw1.Motor_Expiry_Date = '2023-12-11';
                rw1.Motor_Premium = '1000';
                rw1.coBorrowerPanNumber = 'BTWSA3241J';
                rw1.coBorrowerDob = datetime.newInstance(1995, 9, 15, 12, 30, 0);
                rw1.coBorrowerIncome = '200000';
                rw1.coBorrowerCinNo = '3445666';
                rw1.contactNumber = '8888888888';
                rw1.otpForBorrower = '345643';
                rw1.flag = 'testflag';
                rw1.valuerCategory = 'tetsvaluer';
                rw1.placeOfInspection = 'city';
                rw1.locationOfVehicle = 'ap';
                rw1.city = 'nellore';
                rw1.state = 'ap';
                rw1.incomeDtlId = idt1.Id;
                rw1.gstType = 'testgst';
                rw1.itrType = 'testitr';
                rw1.bankType = 'national';
                rw1.GstNumber = 'g667438383883';
                rw1.kycDOB = Date.newInstance(1995, 9, 15);
                rw1.year = '2020';
                rw1.month = '6';
                rw1.stateCode = '29';
                rw1.color = 'red';
                rw1.owner = 'testowner';
                rw1.kilometer = '200';
                rw1.incomeDetailId = idt1.Id;
                rw1.incomeDetails = idt1;
                rw1.whatsappNo = '7777777777';
                rw1.reportType = 'Account';
                rw1.enachStatus = 'testenach';
                rw1.contentId = 'con1234';
                rw1.crmIrrRequested = 'testcrm123';
                rw1.exShowroomPrice = '40000';
                rw1.onRoadPrice = '70000';
                rw1.finalTermId = 'testfinal';
                rw1.fundingOnExShowroom = '4000';
                rw1.fundingOnORP = 'teston';
                rw1.currentScreen = 'testscreen';
                rw1.sumOfFundedInsurance = '40000';
                rw1.riskBand = 'testrisk';
                rw1.borrowerNIP = 'testnip';
                rw1.coBorrowerNIP = 'conip';
                rw1.borrowerPresentAddress = 'testadd';
                rw1.coBorrowerPresentAddress = 'testcoadd';
                rw1.emi = '1000';
                rw1.subProduct = 'testsub';
                rw1.thresholdNetIRR = 'testirr';
        
                Test.startTest();
                      IND_VahanVehicleReportRequest rr1 = new IND_VahanVehicleReportRequest(rw1,opgt1.Id);
                      Map<String,String> rr2 = rr1.getHttpRequestHeaders();
                Test.stopTest();
    }
    //Added by Prashant Dixit to cover IND_VahanVehicleReportService class
    @isTest
    public static void getVahanVehicleReportCallOutRequestTest(){
        
                Opportunity opp = new Opportunity();
                opp.StageName = 'Qualification';
                opp.CloseDate = Date.newInstance(2021, 1, 11);
                opp.Name = 'testone';
                insert opp;
                
                Applicant__c app = new Applicant__c();
                app.Opportunity__c = opp.Id;
                app.Contact_number__c = '9743514830';
                app.Applicant_Type__c = 'Borrower';
                insert app;
        
                Income_Details__c incmDet = new Income_Details__c();
                incmDet.Applicant__c = app.Id;
                incmDet.API_Transaction_Status__c = 'testapi';
                incmDet.Bank_Account_Number__c = '32543409214';
                incmDet.Client_Transaction_Id__c = 'testclient';
                incmDet.Remarks__c = 'no comments';
                insert incmDet;
            
                RequestWrapper reqWrap = new RequestWrapper();
                reqWrap.applicantId = app.Id;
                reqWrap.panNumber = app.PAN_No__c;
                reqWrap.firstName = 'testone';
                reqWrap.lastName = 'testlast';
                reqWrap.dealNumber = 'testdl';
                reqWrap.dateOfBirth = '23061994';
                reqWrap.telephoneNumber = '9999999999';
                reqWrap.kycNo = '4635643';
                reqWrap.kycPassportFileNo = 'pt23556';
                reqWrap.kycGender = 'male';
                reqWrap.kycPassportNo = '232041';
                reqWrap.leadId = '676476368';
                reqWrap.email = 'test@gmail.com';
                reqWrap.income = '200000';
                reqWrap.aadhaarNo = '56678862431';
                reqWrap.dOB = Datetime.newInstance(1994, 6, 23, 12, 30, 0);
                reqWrap.vehicleRegisterationNumber = 'ap 26 1234';
                reqWrap.loanApplicationId = opp.Id;
                reqWrap.noOfCoborrowers = '8';
                reqWrap.vehicleType = 'TwoWheelers';
                reqWrap.CityId = '26';
                reqWrap.VariantCode = 'test123';
                reqWrap.customerCode = 'samplle123';
                reqWrap.oldDealNo = 'test453';
                reqWrap.nocNo = '45545667';
                reqWrap.product = 'testprd';
                reqWrap.category = 'motor';
                reqWrap.subCategory = 'testsub';
                reqWrap.applicantId = 'testapid';
                reqWrap.cicNo = '1234';
                reqWrap.emailTo = 'samplw@gmail.com';
                reqWrap.emailCC = 'testcc@gmail.com';
                reqWrap.emailSubject = 'testclass';
                reqWrap.emailBody = 'testbody';
                reqWrap.loanAmount = '1500000';
                reqWrap.loanDuration = '60';
                reqWrap.loanType = 'Personal';
                reqWrap.processingType = 'typeone';
                reqWrap.acceptancePolicy = 'test';
                reqWrap.uploadingScannedStatements = 'docs';
                reqWrap.yearMonthFrom = '6';
                reqWrap.yearMonthTo = '10';
                reqWrap.productType = 'vehicle';
                reqWrap.employmentType = 'permenant';
                reqWrap.employerName = 'dhoni';
                reqWrap.fileId = 'testfield';
                reqWrap.institutionId = '23';
                reqWrap.password = '12345';
                reqWrap.perfiosTransactionId = 'testper';
                reqWrap.uid = '134455';
                reqWrap.otp = '764345';
                reqWrap.txn = '4566633445';
                reqWrap.rnn = 'testrnn';
                reqWrap.applicantFirstName = 'mahi';
                reqWrap.applicantMiddleName = 'singh';
                reqWrap.applicantLastName = 'dhoni';
                reqWrap.name = 'name';
                reqWrap.destinationName = 'ap';
                reqWrap.destinationNames = 'ap';
                reqWrap.cinNo = 'testcin';
                reqWrap.applicationNo = '134355544655';
                reqWrap.vehicleId = 'v34566';
                reqWrap.age = '26';
                reqWrap.gender = 'male';
                reqWrap.insProduct = 'testprd';
                reqWrap.planCode = 'testplan';
                reqWrap.Fin_Amount = '50000';
                reqWrap.tenure = '36';
                reqWrap.dealNumber = 'Insurance Premium';
                reqWrap.Borrower_Type = 'Insurance Recommendation';
                reqWrap.Vehicle_Category = 'Insurance Recommendation';
                reqWrap.Variant = 'Insurance Recommendation';
                reqWrap.Fin_Amount = '1000';
                reqWrap.Balance_Available = '100';
                reqWrap.Agreement_Value = '10000';
                reqWrap.Motor_Expiry_Date = '2023-12-11';
                reqWrap.Motor_Premium = '1000';
                reqWrap.coBorrowerPanNumber = 'BTWSA3241J';
                reqWrap.coBorrowerDob = datetime.newInstance(1995, 9, 15, 12, 30, 0);
                reqWrap.coBorrowerIncome = '200000';
                reqWrap.coBorrowerCinNo = '3445666';
                reqWrap.contactNumber = '8888888888';
                reqWrap.otpForBorrower = '345643';
                reqWrap.flag = 'testflag';
                reqWrap.valuerCategory = 'tetsvaluer';
                reqWrap.placeOfInspection = 'city';
                reqWrap.locationOfVehicle = 'ap';
                reqWrap.city = 'nellore';
                reqWrap.state = 'ap';
                reqWrap.incomeDtlId = incmDet.Id;
                reqWrap.gstType = 'testgst';
                reqWrap.itrType = 'testitr';
                reqWrap.bankType = 'national';
                reqWrap.GstNumber = 'g667438383883';
                reqWrap.kycDOB = Date.newInstance(1995, 9, 15);
                reqWrap.year = '2020';
                reqWrap.month = '6';
                reqWrap.stateCode = '29';
                reqWrap.color = 'red';
                reqWrap.owner = 'testowner';
                reqWrap.kilometer = '200';
                reqWrap.incomeDetailId = incmDet.Id;
                reqWrap.incomeDetails = incmDet;
                reqWrap.whatsappNo = '7777777777';
                reqWrap.reportType = 'Account';
                reqWrap.enachStatus = 'testenach';
                reqWrap.contentId = 'con1234';
                reqWrap.crmIrrRequested = 'testcrm123';
                reqWrap.exShowroomPrice = '40000';
                reqWrap.onRoadPrice = '70000';
                reqWrap.finalTermId = 'testfinal';
                reqWrap.fundingOnExShowroom = '4000';
                reqWrap.fundingOnORP = 'teston';
                reqWrap.currentScreen = 'testscreen';
                reqWrap.sumOfFundedInsurance = '40000';
                reqWrap.riskBand = 'testrisk';
                reqWrap.borrowerNIP = 'testnip';
                reqWrap.coBorrowerNIP = 'conip';
                reqWrap.borrowerPresentAddress = 'testadd';
                reqWrap.coBorrowerPresentAddress = 'testcoadd';
                reqWrap.emi = '1000';
                reqWrap.subProduct = 'testsub';
                reqWrap.thresholdNetIRR = 'testirr';
        
                Test.startTest();
                 try{
                      IND_VahanVehicleReportRequest result = IND_VahanVehicleReportService.getVahanVehicleReportCallOutRequest(reqWrap, opp.Id);
                      IND_VahanVehicleReportRequest resultEx = IND_VahanVehicleReportService.getVahanVehicleReportCallOutRequest(null, null);
                  }catch(Exception e){
                      String error = e.getMessage()+'   lineNumber=> ' +e.getLineNumber();
                 }
                Test.stopTest();
    }
}