@isTest
public class ScanUploadHttpBodyPartTest {
     @isTest
    public static void getBoundaryTest(){
        Test.startTest();
              ScanUploadHttpBodyPart bp1 = new ScanUploadHttpBodyPart();
              ScanUploadHttpBodyPart.getBoundary();
        Test.stopTest();
     }
    
    @isTest
    public static void GetContentTypeTest(){
        Test.startTest();
             ScanUploadHttpBodyPart.GetContentType();
        Test.stopTest();
    }
    
    @isTest
    public static void WriteBoundaryTest(){
        Test.startTest();
              ScanUploadHttpBodyPart.WriteBoundary();
        Test.stopTest();
    }
    
    @isTest
    public static void resolveMimeTypeTest1(){
        Test.startTest();
              ScanUploadHttpBodyPart.resolveMimeType('Aadhar.png');
        Test.stopTest();
    }
    
    @isTest
    public static void resolveMimeTypeTest2(){
        Test.startTest();
              ScanUploadHttpBodyPart.resolveMimeType('Aadhar.jpg');
        Test.stopTest();
    }
    
     @isTest
    public static void resolveMimeTypeTest3(){
        Test.startTest();
              ScanUploadHttpBodyPart.resolveMimeType('Aadhar.pgm');
        Test.stopTest();
    }
    
    @isTest
    public static void resolveMimeTypeTest4(){
        Test.startTest();
              ScanUploadHttpBodyPart.resolveMimeType('Aadhar.ppm');
        Test.stopTest();
    }
    
    @isTest
    public static void SafelyPadTest(){
        Test.startTest();
             ScanUploadHttpBodyPart.SafelyPad('test','testone=','testtwo');
        Test.stopTest();
    }
    
    @isTest
    public static void SafelyPad2Test(){
        Test.startTest();
             ScanUploadHttpBodyPart.SafelyPad2('res','resone','restwo');
        Test.stopTest();
    }
    
    @isTest
    public static void WriteBlobBodyParameterTest(){
        Test.startTest();
             ScanUploadHttpBodyPart.WriteBlobBodyParameter('test','testresult==','aadhar');
        Test.stopTest();
    }
    
    @isTest
    public static void WriteBlobBodyParameterTest1(){
        Test.startTest();
             ScanUploadHttpBodyPart.WriteBlobBodyParameter('test','testresult=','aadhar');
        Test.stopTest();
    }
    
    @isTest
    public static void WriteBodyParameterTest(){
        Test.startTest();
             ScanUploadHttpBodyPart.WriteBodyParameter('test','testresult');
        Test.stopTest();
    }
    
}