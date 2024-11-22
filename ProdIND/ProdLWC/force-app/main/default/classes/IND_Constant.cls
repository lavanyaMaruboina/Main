public class IND_Constant {
    public static final String DSA_DOCUMENTS='DSA Documents';
    public static final String NOT_AUTHORIZED= 'Not Authorized';
    public static final String Stage= 'Loan Initiation';
    public static final String TeamMemberRole= 'DSA';
    public static final String OpportunityAccessLevel= 'Edit';
    public static final Map<String, String> subStageMap = new Map<String, String>
    {'User Details' => 'Application in Progress', 'Capture current residential address' => 'Application in Progress', 'Capture permanent residential address' => 'Application in Progress',
        'Capture PAN or Other KYC' => 'Application in Progress','Capture Dedupe' => 'Application in Progress','Vehicle Dedupe' => 'Application in Progress','Declared Income/Required Loan Amount' => 'Application in Progress'
        ,'Bank Account Check' => 'Application in Progress',
        'View Application Details' => 'Credit Processing','CIBIL' => 'Credit Processing','Field Investigation' => 'Credit Processing','Credit Assessment' => 'Credit Processing','Income Details' => 'Credit Processing',
        'Valuation IDV'=>'Credit Processing','Final Terms'=>'Credit Processing','Insurance Details'=>'Credit Processing'
        ,'Exposure Analysis'=>'Credit Processing','Income'=>'Credit Processing','CAM and Approval Log'=>'Credit Processing','Risk Summary'=>'Credit Processing','Insurance'=>'Credit Processing',
        'Tele-verification <Post Sanction>'=>'Sanction','Vehicle Inspection and RC Check'=>'Sanction','Structured EMI'=>'Sanction','Sanction of Application'=>'Sanction','Deal Number & Customer Code Generation'=>'Sanction',
        'Security Mandate'=>'Document Collection in Progress','Additional Documents'=>'Document Collection in Progress','Invoice'=>'Document Collection in Progress',
        'IHM'=>'Document Collection in Progress','Loan Agreement'=>'Document Collection in Progress','Signing the e-Agreement'=>'Document Collection in Progress',
        'Repayment Mandate'=>'Document Collection in Progress','RTO, DPN, POA Documents Upload'=>'Document Collection in Progress','Pre-Disbursement Check'=>'Document Collection in Progress',
        'Initiate RCU'=>'Document Collection in Progress','RCU Manager'=>'Document Collection in Progress',
        'Payment Request'=>'Document Collection Completed','RC Upload'=>'Document Collection Completed','Business Payment Details'=>'Document Collection Completed','New/Used Vehicle Details'=>'Document Collection Completed',
        'Beneficiary Details'=>'Document Collection Completed'
        };
    }