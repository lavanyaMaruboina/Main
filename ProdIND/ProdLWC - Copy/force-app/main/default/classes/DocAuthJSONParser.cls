/*------------------------------------------------------------
Author:        Manish Baldota
Company:       Persistent Systems
Description:   This handle the current and permananet residence FI components data retrival and storage
                
Test Class:    
History
Date            Author              Comments
-------------------------------------------------------------
12-17-2021      Manish Baldota       Created
------------------------------------------------------------*/
public with sharing class DocAuthJSONParser {
    public cls_reports[] reports;
	public class cls_reports {
		public String sub_result;	//caution
		public String variant;	//standard
		public cls_breakdown breakdown;
	}
	public class cls_breakdown {
		public cls_image_integrity image_integrity;
		public cls_visual_authenticity visual_authenticity;
	}
	public class cls_visual_authenticity{
		public String result;	//consider
		public cls_breakdown_visual_authenticity breakdown;
	}
	public class cls_breakdown_visual_authenticity{
		public cls_other other;
		public cls_face_detection face_detection;
		public cls_template template;
		public cls_digital_tampering digital_tampering;
		public cls_picture_face_integrity picture_face_integrity;
		public cls_original_document_present original_document_present;
		public cls_fonts fonts;
		public cls_security_features security_features;
	}
    public class cls_image_integrity {
		public String result;	//consider
		public cls_breakdown_image_integrity breakdown;
	}
	public class cls_breakdown_image_integrity {
		public cls_conclusive_document_quality conclusive_document_quality;
		public cls_colour_picture colour_picture;
		public cls_supported_document supported_document;
		public cls_image_quality image_quality;
	}
	public class cls_conclusive_document_quality {
		public String result;	//consider
		public cls_properties properties;
	}
	public class cls_other {
		public String result;	//clear
		public cls_properties properties;
	}
	public class cls_face_detection {
		public String result;	//clear
		public cls_properties properties;
	}
	public class cls_template {
		public String result;	//clear
		public cls_properties properties;
	}
	public class cls_digital_tampering {
		public String result;	//clear
		public cls_properties properties;
	}
	public class cls_picture_face_integrity {
		public String result;	//clear
		public cls_properties properties;
	}
	public class cls_original_document_present {
		public String result;	//clear
		public cls_properties properties;
	}
	public class cls_fonts {
		public String result;	//clear
		public cls_properties properties;
	}
	public class cls_security_features {
		public String result;	//clear
		public cls_properties properties;
	}
	public class cls_properties {
	}
	public class cls_colour_picture {
		public String result;	//clear
		public cls_properties properties;
	}
	public class cls_supported_document {
		public String result;	//clear
		public cls_properties properties;
	}
	public class cls_image_quality {
		public String result;	//clear
		public cls_properties properties;
	}	
    public static DocAuthJSONParser parse(String json){
		return (DocAuthJSONParser) System.JSON.deserialize(json, DocAuthJSONParser.class);
	}
	
}