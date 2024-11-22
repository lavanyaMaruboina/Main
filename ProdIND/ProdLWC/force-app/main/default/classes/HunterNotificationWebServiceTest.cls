@isTest
public class HunterNotificationWebServiceTest {
    @isTest 
    public static void testMethod1(){
        
        HunterNotificationWebService.EventWrapper eventWrap1 = new HunterNotificationWebService.EventWrapper();
        eventWrap1.code = '11';
        
        HunterNotificationWebService.EventWrapper eventWrap2 = new HunterNotificationWebService.EventWrapper();
        eventWrap2.code = '12';
        
        HunterNotificationWebService.EventWrapper eventWrap3 = new HunterNotificationWebService.EventWrapper();
        eventWrap3.code = '11';
        
        HunterNotificationWebService.EventWrapper eventWrap4 = new HunterNotificationWebService.EventWrapper();
        eventWrap4.code = '12';
        
        List<HunterNotificationWebService.EventWrapper> EventWrapperList1 = new List<HunterNotificationWebService.EventWrapper>();
        EventWrapperList1.add(eventWrap1);
        EventWrapperList1.add(eventWrap2);
        
        List<HunterNotificationWebService.EventWrapper> EventWrapperList2 = new List<HunterNotificationWebService.EventWrapper>();
        EventWrapperList2.add(eventWrap3);
        EventWrapperList2.add(eventWrap4);
        
        HunterNotificationWebService.EventsWrapper multieventsWrap1 = new HunterNotificationWebService.EventsWrapper();
        multieventsWrap1.event =EventWrapperList1;
        
        HunterNotificationWebService.EventsWrapper multieventsWrap2 = new HunterNotificationWebService.EventsWrapper();
        multieventsWrap2.event =EventWrapperList2;
        
        List<HunterNotificationWebService.EventsWrapper> EventsWrapperList1 = new List<HunterNotificationWebService.EventsWrapper>();
        EventsWrapperList1.add(multieventsWrap1);
        EventsWrapperList1.add(multieventsWrap2);
        
        
        /*List<HunterNotificationWebService.EventsWrapper> multiEventsWrapperList = new List<HunterNotificationWebService.EventsWrapper>();
multiEventsWrapperList.add(EventsWrapperList1);
multiEventsWrapperList.add(EventsWrapperList2);*/
        
        HunterNotificationWebService.CaseManagementWrapper caseWrap = new HunterNotificationWebService.CaseManagementWrapper();
        caseWrap.events = EventsWrapperList1;
        
        HunterNotificationWebService.responseWrapper resWrap = new HunterNotificationWebService.responseWrapper();
        
        resWrap.submissionNotificationNo = '5736623';
        // resWrap.dateEventRaised = 2018-05-14T16:36:24+05:30;
        resWrap.submissionIdentifer = 'ABC_23';
        resWrap.versionNo = '1';
        // resWrap.dateOfSubmission = '2018-05-14T16:36:24+05:30';
        //resWrap.workStatusChangeDate ='2018-05-14T16:36:24+05:30';
        resWrap.workStatusType = '3';
        resWrap.workStatusDescription = 'test';
        // resWrap.fraudStatusChangeDate = '2018-05-14T16:36:24+05:30';
        resWrap.fraudStatusType = 'Suspect';
        resWrap.caseManagement = caseWrap;
        
        List<HunterNotificationWebService.responseWrapper> listRespWrap = new List<HunterNotificationWebService.responseWrapper>();
        listRespWrap.add(resWrap);
        
        HunterNotificationWebService.MessageWrapper messageWrap = new HunterNotificationWebService.MessageWrapper();
        messageWrap.workStatusNotification = listRespWrap;
        
        HunterNotificationWebService.Hunter2NotificationWrapper hunter2NotiWrap = new HunterNotificationWebService.Hunter2NotificationWrapper();
        hunter2NotiWrap.notificationType = 'WorkStatus';
        hunter2NotiWrap.message = messageWrap;
        
        HunterNotificationWebService.NotificationInputWrapper notiInputWrap = new HunterNotificationWebService.NotificationInputWrapper();
        notiInputWrap.hunter2Notification = hunter2NotiWrap;
        
        
        
        Test.startTest();
        
        String response = HunterNotificationWebService.getNotification(notiInputWrap);
        System.assertEquals(hunter2NotiWrap.notificationType,'WorkStatus');
        System.debug('response - '+response);  
        System.debug('response - '+response);
        Test.stopTest();
        
    }
    @isTest 
    public static void testMethod2(){
        
        HunterNotificationWebService.EventWrapper eventWrap1 = new HunterNotificationWebService.EventWrapper();
        eventWrap1.code = '11';
        
        HunterNotificationWebService.EventWrapper eventWrap2 = new HunterNotificationWebService.EventWrapper();
        eventWrap2.code = '12';
        
        HunterNotificationWebService.EventWrapper eventWrap3 = new HunterNotificationWebService.EventWrapper();
        eventWrap3.code = '11';
        
        HunterNotificationWebService.EventWrapper eventWrap4 = new HunterNotificationWebService.EventWrapper();
        eventWrap4.code = '12';
        
        List<HunterNotificationWebService.EventWrapper> EventWrapperList1 = new List<HunterNotificationWebService.EventWrapper>();
        EventWrapperList1.add(eventWrap1);
        EventWrapperList1.add(eventWrap2);
        
        List<HunterNotificationWebService.EventWrapper> EventWrapperList2 = new List<HunterNotificationWebService.EventWrapper>();
        EventWrapperList2.add(eventWrap3);
        EventWrapperList2.add(eventWrap4);
        
        HunterNotificationWebService.EventsWrapper multieventsWrap1 = new HunterNotificationWebService.EventsWrapper();
        multieventsWrap1.event =EventWrapperList1;
        
        HunterNotificationWebService.EventsWrapper multieventsWrap2 = new HunterNotificationWebService.EventsWrapper();
        multieventsWrap2.event =EventWrapperList2;
        
        List<HunterNotificationWebService.EventsWrapper> EventsWrapperList1 = new List<HunterNotificationWebService.EventsWrapper>();
        EventsWrapperList1.add(multieventsWrap1);
        EventsWrapperList1.add(multieventsWrap2);
    
        HunterNotificationWebService.CaseManagementWrapper caseWrap = new HunterNotificationWebService.CaseManagementWrapper();
        caseWrap.events = EventsWrapperList1;
        
        HunterNotificationWebService.Hunter2NotificationWrapper hunter2NotiWrap = new HunterNotificationWebService.Hunter2NotificationWrapper();
        hunter2NotiWrap.notificationType = '';
        
        HunterNotificationWebService.NotificationInputWrapper notiInputWrap = new HunterNotificationWebService.NotificationInputWrapper();
        notiInputWrap.hunter2Notification = hunter2NotiWrap;
        
        Test.startTest();
        
        String response = HunterNotificationWebService.getNotification(notiInputWrap);
        System.debug('response - '+response);
        Test.stopTest();
        
    }
}