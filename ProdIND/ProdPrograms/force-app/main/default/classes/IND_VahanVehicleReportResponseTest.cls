@isTest
public class IND_VahanVehicleReportResponseTest {

    @isTest
    public static void verifyIND_VahanVehicleReportResponse() {
        IND_VahanVehicleReportResponse.Response objResp = new IND_VahanVehicleReportResponse.Response();
        IND_VahanVehicleReportResponse.Content objContent = new IND_VahanVehicleReportResponse.Content();
        
        objContent.Deal_No = 'D123';
        objContent.Registration_No = 'R456';
        objContent.Engine_No = 'E789';
        objContent.Vehicle_Class = 'Sedan';
        objContent.Chassis_No = 'C012';
        objContent.Purchase_Date = '2024-01-01';
        objContent.Fitness_Upto = '2025-01-01';
        objContent.Registration_Date = '2024-01-15';
        objContent.Dealer = 'ABC Motors';
        objContent.Body_Type = 'Saloon';
        objContent.Owner_Sr_No = '001';
        objContent.Manufacturer = 'XYZ Ltd.';
        objContent.Maker_Model = 'Model X';
        objContent.Seating_Capacity = '5';
        objContent.Standing_Capacity = '0';
        objContent.Wt_Laden = '1500';
        objContent.Gross_Vehicle_Weight = '2000';
        objContent.Fuel = 'Petrol';
        objContent.Cubic_Capacity = '1500';
        objContent.Wheel_Base = '2500';
        objContent.Pan_Gir = 'PG1234';
        objContent.No_Of_Cylinders = '4';
        objContent.HorsePower = '100';
        objContent.Color = 'Red';
        objContent.Sale_Amount = '500000';
        objContent.Owner_Name = 'John Doe';
        objContent.Father_name = 'Robert Doe';
        objContent.Present_Address1 = '123 Street';
        objContent.Present_Address2 = 'City';
        objContent.Present_Address3 = 'State';
        objContent.Present_Address4 = 'Country';
        objContent.Insurance_Number = 'INS123456';
        objContent.Insurer_Name = 'Insurance Co.';
        objContent.Ins_Issuance_Date = '2024-01-01';
        objContent.Ins_Expiry_Date = '2025-01-01';
        objContent.Owner_Contact_Number = '1234567890';
        objContent.Vehicle_Place_of_Valuation = 'Place A';
        
        objResp.content = new List<IND_VahanVehicleReportResponse.Content>{objContent};
        objResp.respDesc = 'Success';
        objResp.status = '200';
        IND_VahanVehicleReportResponse result = new IND_VahanVehicleReportResponse();
        result.response = objResp;
        String jsonResponse = '{"content": [], "respDesc": "Success", "status": "200"}';

        // Call the parse method
        Test.startTest();
         IND_VahanVehicleReportResponse.parse(jsonResponse);
        Test.stopTest();
    }
}