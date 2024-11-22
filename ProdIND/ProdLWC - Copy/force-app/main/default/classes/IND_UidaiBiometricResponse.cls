/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is wrapper class for the Uidai Biometric Response Wrapper
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
05-01-2022    Satyam More            Created
------------------------------------------------------------*/

public class IND_UidaiBiometricResponse extends ParentAPIResponse{
    public class Response {
		public String status{get;set;}
		public String respDesc{get;set;}
		public List<String> content{get;set;}
	}

	public Response response{get;set;}

	/*
	public class Response {
		public String status {get;set;} 
		public String respDesc {get;set;} 
		public Content content {get;set;} 

		public Response(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'status') {
							status = parser.getText();
						} else if (text == 'respDesc') {
							respDesc = parser.getText();
						} else if (text == 'content') {
							content = new Content(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Response consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public Response response {get;set;} 

	
	public class Content {
		public KycResponse kycResponse {get;set;} 

		public Content(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'kycResponse') {
							kycResponse = new KycResponse(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Content consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class TransactionInfo {
		public String Pan {get;set;} 
		public String Proc_Code {get;set;} 
		public String Transm_Date_time {get;set;} 
		public String Stan {get;set;} 
		public String Local_Trans_Time {get;set;} 
		public String Local_date {get;set;} 
		public String AcqId {get;set;} 
		public String RRN {get;set;} 
		public String ResponseCode {get;set;} 
		public String ResponseMsg {get;set;} 
		public String CA_Tid {get;set;} 
		public String CA_ID {get;set;} 
		public String CA_TA {get;set;} 

		public TransactionInfo(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'Pan') {
							Pan = parser.getText();
						} else if (text == 'Proc_Code') {
							Proc_Code = parser.getText();
						} else if (text == 'Transm_Date_time') {
							Transm_Date_time = parser.getText();
						} else if (text == 'Stan') {
							Stan = parser.getText();
						} else if (text == 'Local_Trans_Time') {
							Local_Trans_Time = parser.getText();
						} else if (text == 'Local_date') {
							Local_date = parser.getText();
						} else if (text == 'AcqId') {
							AcqId = parser.getText();
						} else if (text == 'RRN') {
							RRN = parser.getText();
						} else if (text == 'ResponseCode') {
							ResponseCode = parser.getText();
						} else if (text == 'ResponseMsg') {
							ResponseMsg = parser.getText();
						} else if (text == 'CA_Tid') {
							CA_Tid = parser.getText();
						} else if (text == 'CA_ID') {
							CA_ID = parser.getText();
						} else if (text == 'CA_TA') {
							CA_TA = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'TransactionInfo consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class KycResponse {
		public TransactionInfo TransactionInfo {get;set;} 
		public UidData UidData {get;set;} 
		public String txn {get;set;} 
		public String k_err {get;set;} // in json: k-err
		public String k_mesage {get;set;} // in json: k-mesage
		public String a_err {get;set;} // in json: a-err
		public String a_mesage {get;set;} // in json: a-mesage

		public KycResponse(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'TransactionInfo') {
							TransactionInfo = new TransactionInfo(parser);
						} else if (text == 'UidData') {
							UidData = new UidData(parser);
						} else if (text == 'txn') {
							txn = parser.getText();
						} else if (text == 'k-err') {
							k_err = parser.getText();
						} else if (text == 'k-mesage') {
							k_mesage = parser.getText();
						} else if (text == 'a-err') {
							a_err = parser.getText();
						} else if (text == 'a-mesage') {
							a_mesage = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'KycResponse consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class UidData {
		public String tkn {get;set;} 
		public String txn {get;set;} 
		public String uid {get;set;} 
		public String dob {get;set;} 
		public String gender {get;set;} 
		public String name {get;set;} 
		public Object email {get;set;} 
		public Object phone {get;set;} 
		public String dist {get;set;} 
		public Object house {get;set;} 
		public String lm {get;set;} 
		public Object co {get;set;} 
		public Object subdist {get;set;} 
		public Object po {get;set;} 
		public String loc {get;set;} 
		public String pc {get;set;} 
		public String state {get;set;} 
		public Object street {get;set;} 
		public String vtc {get;set;} 
		public String Pht {get;set;} 

		public UidData(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'tkn') {
							tkn = parser.getText();
						} else if (text == 'txn') {
							txn = parser.getText();
						} else if (text == 'uid') {
							uid = parser.getText();
						} else if (text == 'dob') {
							dob = parser.getText();
						} else if (text == 'gender') {
							gender = parser.getText();
						} else if (text == 'name') {
							name = parser.getText();
						} else if (text == 'email') {
							email = parser.readValueAs(Object.class);
						} else if (text == 'phone') {
							phone = parser.readValueAs(Object.class);
						} else if (text == 'dist') {
							dist = parser.getText();
						} else if (text == 'house') {
							house = parser.readValueAs(Object.class);
						} else if (text == 'lm') {
							lm = parser.getText();
						} else if (text == 'co') {
							co = parser.readValueAs(Object.class);
						} else if (text == 'subdist') {
							subdist = parser.readValueAs(Object.class);
						} else if (text == 'po') {
							po = parser.readValueAs(Object.class);
						} else if (text == 'loc') {
							loc = parser.getText();
						} else if (text == 'pc') {
							pc = parser.getText();
						} else if (text == 'state') {
							state = parser.getText();
						} else if (text == 'street') {
							street = parser.readValueAs(Object.class);
						} else if (text == 'vtc') {
							vtc = parser.getText();
						} else if (text == 'Pht') {
							Pht = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'UidData consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}*/
}