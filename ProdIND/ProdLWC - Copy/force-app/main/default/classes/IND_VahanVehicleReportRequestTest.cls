@isTest
public class IND_VahanVehicleReportRequestTest {

    @isTest
    public static void testValidRequest() {
        RequestWrapper testWrapper = new RequestWrapper();
        testWrapper.leadId = 'Lead123';
        testWrapper.vehicleRegisterationNumber = 'Reg456';

        IND_VahanVehicleReportRequest request = new IND_VahanVehicleReportRequest(testWrapper, 'LoanAppId789');

        Map<String, String> headers = request.getHttpRequestHeaders();
        System.assertNotEquals(null, headers, 'Headers should not be null');
        System.assert(headers.containsKey('Content-Type'), 'Headers should contain Content-Type');
        System.assertEquals('application/json', headers.get('Content-Type'), 'Content-Type should be application/json');
        System.assertEquals('Lead123', request.Lead_Id, 'Lead_Id should be Lead123');
        System.assertEquals('Reg456', request.Veh_Reg_No, 'Veh_Reg_No should be Reg456');
    }

    @isTest
    public static void testInvalidRequest_NoLeadId() {
        RequestWrapper testWrapper = new RequestWrapper();
        testWrapper.leadId = '';
        testWrapper.vehicleRegisterationNumber = 'Reg456';
        try {
            IND_VahanVehicleReportRequest request = new IND_VahanVehicleReportRequest(testWrapper, 'LoanAppId789');
            System.assert(false, 'Expected an exception to be thrown due to missing Lead_Id');
        } catch (IND_Exception e) {
            System.assertEquals(System.Label.LeadId, e.getMessage(), 'Exception message should be LeadId');
        }
    }

    @isTest
    public static void testInvalidRequest_NoVehicleRegNo() {
        RequestWrapper testWrapper = new RequestWrapper();
        testWrapper.leadId = 'Lead123';
        testWrapper.vehicleRegisterationNumber = '';
        try {
            IND_VahanVehicleReportRequest request = new IND_VahanVehicleReportRequest(testWrapper, 'LoanAppId789');
            System.assert(false, 'Expected an exception to be thrown due to missing VehicleRegistrationNumber');
        } catch (IND_Exception e) {
            System.assertEquals(System.Label.VehicleRegistrationNumber, e.getMessage(), 'Exception message should be VehicleRegistrationNumber');
        }
    }
}