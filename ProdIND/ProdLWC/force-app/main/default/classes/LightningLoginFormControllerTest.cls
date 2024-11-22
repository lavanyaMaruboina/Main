@IsTest(SeeAllData = true)
public with sharing class LightningLoginFormControllerTest {

 @IsTest
 static void LightningLoginFormControllerInstantiation() {
  LightningLoginFormController controller = new LightningLoginFormController();
  System.assertNotEquals(controller, null);
 }

 @IsTest
 static void testIsUsernamePasswordEnabled() {
  System.assertEquals(true, LightningLoginFormController.getIsUsernamePasswordEnabled());
 }

 @IsTest
 static void testIsSelfRegistrationEnabled() {
  System.assertEquals(false, LightningLoginFormController.getIsSelfRegistrationEnabled());
 }

 @IsTest
 static void testGetSelfRegistrationURL() {
  System.assertEquals(null, LightningLoginFormController.getSelfRegistrationUrl());
 }

 @IsTest
 static void testAuthConfig() {
  Auth.AuthConfiguration authConfig = LightningLoginFormController.getAuthConfig();
  System.assertNotEquals(null, authConfig);
 }
    
    @isTest
    public static void setExperienceIdTest(){
        Test.startTest();
             LightningLoginFormController.setExperienceId('testexId');
             LightningLoginFormController.setExperienceId(null);
        Test.stopTest();
    }
    
    @isTest
    public static void getForgotPasswordUrlTest(){
        Test.startTest();
             LightningLoginFormController.getForgotPasswordUrl();
        Test.stopTest();
    }
    
    @isTest
    public static void loginTest(){
        Test.startTest();
             LightningLoginFormController.login('test@gmail.com','12345','www.w3schools.com');
        Test.stopTest();
    }
}