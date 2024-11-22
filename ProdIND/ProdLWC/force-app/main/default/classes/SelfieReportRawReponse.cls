public class SelfieReportRawReponse  extends ParentAPIResponse {

    
	public class Image_integrity {
		public Breakdown breakdown;
		public String result;
	}

	public class Breakdown_Z {
		public Face_comparison face_comparison;
		public Image_integrity image_integrity;
		public Face_comparison visual_authenticity;
	}

	public String created_at;
	public String download_uri;
	public Object form_uri;
	public String href;
	public String id;
	public Boolean paused;
	public Object redirect_uri;
	public List<String> report_type_groups;
	public List<Reports> reports;
	public String result;
	public String results_uri;
	public Boolean sandbox;
	public String status;
	public List<Properties> tags;
	public String type;
	public String version;

	public class Properties_Z {
		public Double score;
	}

	public class Face_comparison {
		public String result;
	}

	public class Breakdown {
		public Face_detected face_detected;
		public Face_detected source_integrity;
	}

	public class Reports {
		public Breakdown_Z breakdown;
		public String created_at;
		public List<Properties> documents;
		public String href;
		public String id;
		public String name;
		public Properties_Z properties;
		public String result;
		public String status;
		public Object sub_result;
		public String variant;
	}

	public class Face_detected {
		public Properties properties;
		public String result;
	}

	public class Properties {
	}

}