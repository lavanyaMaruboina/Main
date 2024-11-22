public class KFSCalloutMock implements HttpCalloutMock{
public HttpResponse mockResponse;
        
        public KFSCalloutMock(HttpResponse mockResponse) {
            this.mockResponse = mockResponse;
             //return mockResponse;
        }
        
        public HttpResponse respond(HttpRequest req) {
            return mockResponse;
        }
}