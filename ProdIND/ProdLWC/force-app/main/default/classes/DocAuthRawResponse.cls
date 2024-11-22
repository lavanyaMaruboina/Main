/*------------------------------------------------------------
Author:        Santhosh Mothe
Company:       Persistent Systems
Description:   Doc auth response wrapper class
Inputs:        None 
History
Date            Author              Comments
-------------------------------------------------------------
1-10-2021      Santhosh Mothe      Created
------------------------------------------------------------*/
public class DocAuthRawResponse extends ParentAPIResponse {
 	public class Properties_W {
		public String scan;
		public String document_on_printed_paper;
		public String screenshot;
		public String photo_of_screen;
	}

	public List<Reports> reports;

	public class Properties_Z {
	}

	public class Visual_authenticity {
		public String result;
		public Breakdown_V breakdown;
	}

	public class Properties_X {
		public String missing_back;
		public String digital_document;
		public String punctured_document;
		public String corner_removed;
		public String watermarks_digital_text_overlay;
		public String abnormal_document_features;
		public String obscured_security_features;
		public String obscured_data_points;
	}

	public class Properties_Y {
		public String document_number;
	}

	public class Gender {
		public String result;
		public Properties_Z properties;
	}

	public class Data_validation {
		public String result;
		public Breakdown_Y breakdown;
	}

	public class Properties {
		public String first_name;
		public String last_name;
		public String issuing_country;
		public List<Document_numbers> document_numbers;
		public String document_type;
		public String date_of_birth;
		public String gender;
		public String issuing_date;
		public String address;
		public Address_lines address_lines;
	}

	public class Document_numbers {
		public String type;
		public String value;
	}

	public class Original_document_present {
		public String result;
		public Properties_W properties;
	}

	public class Address_lines {
		public String street_address;
		public Object city;
		public String postal_code;
		public Object state;
		public String country;
		public String country_code;
	}

	public class Data_comparison {
		public Object result;
		public Breakdown breakdown;
	}

	public class Breakdown {
		public Date_of_expiry date_of_expiry;
		public Date_of_expiry issuing_country;
		public Date_of_expiry document_type;
		public Date_of_expiry document_numbers;
		public Date_of_expiry gender;
		public Date_of_expiry date_of_birth;
		public Date_of_expiry last_name;
		public Date_of_expiry first_name;
	}

	public class Compromised_document {
		public String result;
	}

	public class Police_record {
		public Object result;
	}

	public class Document_numbers_Z {
		public Object result;
		public Properties_Y properties;
	}

	public class Reports {
		public String created_at;
		public List<Documents> documents;
		public String href;
		public String id;
		public String name;
		public Properties properties;
		public String result;
		public String status;
		public String sub_result;
		public String variant;
		public Breakdown_U breakdown;
	}

	public class Data_consistency {
		public Object result;
		public Breakdown_Z breakdown;
	}

	public class Date_of_expiry {
		public Object result;
		public Properties_Z properties;
	}

	public class Conclusive_document_quality {
		public String result;
		public Properties_X properties;
	}

	public class Breakdown_Z {
		public Date_of_expiry date_of_expiry;
		public Date_of_expiry document_type;
		public Date_of_expiry nationality;
		public Date_of_expiry issuing_country;
		public Date_of_expiry document_numbers;
		public Date_of_expiry gender;
		public Date_of_expiry date_of_birth;
		public Date_of_expiry last_name;
		public Date_of_expiry first_name;
	}

	public class Image_integrity {
		public String result;
		public Breakdown_X breakdown;
	}

	public class Breakdown_Y {
		public Gender gender;
		public Gender date_of_birth;
		public Date_of_expiry document_expiration;
		public Document_numbers_Z document_numbers;
		public Date_of_expiry expiry_date;
		public Date_of_expiry mrz;
	}

	public class Breakdown_X {
		public Conclusive_document_quality conclusive_document_quality;
		public Gender colour_picture;
		public Gender supported_document;
		public Gender image_quality;
	}

	public class Breakdown_W {
		public Gender minimum_accepted_age;
	}

	public class Documents {
		public String id;
	}

	public class Breakdown_V {
		public Gender other;
		public Original_document_present original_document_present;
		public Date_of_expiry digital_tampering;
		public Date_of_expiry fonts;
		public Date_of_expiry security_features;
		public Date_of_expiry template;
		public Gender face_detection;
		public Date_of_expiry picture_face_integrity;
	}

	public class Breakdown_U {
		public Data_comparison data_comparison;
		public Data_consistency data_consistency;
		public Data_validation data_validation;
		public Compromised_document compromised_document;
		public Image_integrity image_integrity;
		public Age_validation age_validation;
		public Police_record police_record;
		public Visual_authenticity visual_authenticity;
	}

	public class Age_validation {
		public String result;
		public Breakdown_W breakdown;
	}
}