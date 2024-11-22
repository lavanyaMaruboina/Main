@isTest
public class SelfieReportRawReponseTest {
	@isTest
    public static void verifySelfieReportRawReponse(){
        SelfieReportRawReponse.Image_integrity resImage_integrity=new SelfieReportRawReponse.Image_integrity();
        System.assertEquals(resImage_integrity.breakdown, null);
         System.assertEquals(resImage_integrity.result, null);
        
        SelfieReportRawReponse.Breakdown_Z resBreakdown_Z=new SelfieReportRawReponse.Breakdown_Z();
        System.assertEquals(resBreakdown_Z.face_comparison, null);
         System.assertEquals(resBreakdown_Z.image_integrity, null);
        System.assertEquals(resBreakdown_Z.visual_authenticity, null);
        
        SelfieReportRawReponse.Face_comparison resFace_comparison=new SelfieReportRawReponse.Face_comparison();
        System.assertEquals(resFace_comparison.result, null);
        
        SelfieReportRawReponse.Properties_Z resProperties_Z=new SelfieReportRawReponse.Properties_Z();
         System.assertEquals(resProperties_Z.score, null);
        
        SelfieReportRawReponse.Breakdown resBreakdown=new SelfieReportRawReponse.Breakdown();
      		  System.assertEquals(resBreakdown.face_detected, null);
              System.assertEquals(resBreakdown.source_integrity, null);
        
        SelfieReportRawReponse.Face_detected resFace_detected=new SelfieReportRawReponse.Face_detected();
      		  System.assertEquals(resFace_detected.properties, null);
              System.assertEquals(resFace_detected.result, null);
        
        SelfieReportRawReponse.Reports resReports=new SelfieReportRawReponse.Reports();
      		  System.assertEquals(resReports.breakdown, null);
              System.assertEquals(resReports.created_at, null);
              System.assertEquals(resReports.documents, null);
              System.assertEquals(resReports.href, null);
        	  System.assertEquals(resReports.id, null);
              System.assertEquals(resReports.name, null);
              System.assertEquals(resReports.properties, null);
              System.assertEquals(resReports.result, null);
        	  System.assertEquals(resReports.status, null);
        	  System.assertEquals(resReports.sub_result, null);
        	  System.assertEquals(resReports.variant, null);
        
        SelfieReportRawReponse result=new SelfieReportRawReponse();
              System.assertEquals(result.created_at, null);
              System.assertEquals(result.download_uri, null);
              System.assertEquals(result.form_uri, null);
              System.assertEquals(result.href, null);
        	  System.assertEquals(result.id, null);
        	  System.assertEquals(result.paused, null);
              System.assertEquals(result.redirect_uri, null);
        	  System.assertEquals(result.report_type_groups, null);
              System.assertEquals(result.Reports, null);
              System.assertEquals(result.result, null);
              System.assertEquals(result.results_uri, null);
        	  System.assertEquals(result.sandbox, null);
        	  System.assertEquals(result.status, null);
        	  System.assertEquals(result.tags, null);
        	  System.assertEquals(result.type, null);
        	  System.assertEquals(result.version, null);
    }    
}