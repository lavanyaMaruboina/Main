global class HunterNotificationWebService {
    global class NotificationInputWrapper {
       webservice Hunter2NotificationWrapper hunter2Notification; 
    }
    global class Hunter2NotificationWrapper {
        webservice string notificationType;
        webservice MessageWrapper message;
    }
    global class MessageWrapper {
       webservice List<responseWrapper> workStatusNotification; 
    }
    
    global class responseWrapper {
        webservice string submissionNotificationNo;
        webservice datetime dateEventRaised;
        webservice string submissionIdentifer;
        webservice string versionNo;
        webservice datetime dateOfSubmission;
        webservice datetime workStatusChangeDate;
        webservice string workStatusType;
        webservice string workStatusDescription;
        webservice datetime fraudStatusChangeDate;
        webservice string fraudStatusType;
		webservice CaseManagementWrapper caseManagement;
    }
    global class CaseManagementWrapper {
        webservice List<EventsWrapper> events;
    }
    global class EventsWrapper {
        webservice List<EventWrapper> event;
    }
    global class EventWrapper {
        webservice String code;
    }
    webservice static string getNotification(NotificationInputWrapper notificationInput){
        if(!String.isBlank(notificationInput.hunter2Notification.notificationType)){
            System.debug('workStatusNotification.submissionNotificationNo>>'+NotificationInput.Hunter2Notification.NotificationType);
            return 'OK';
        }
        return 'Bad Response';
    }
    /*<impl:getNotification
			xmlns:impl="client webservice url">
			<NotificationInput>
				<Hunter2Notification
					xmlns="http://www.mclsoftware.co.uk">
					<NotificationType>WorkStatus</NotificationType>
					<Message>
						<WorkStatusNotification>
							<SubmissionNotificationNo>5736623</SubmissionNotificationNo>
							<DateEventRaised>2018-05-14T16:36:24+05:30</DateEventRaised>
							<SubmissionIdentifer>ABC_23</SubmissionIdentifer>
							<VersionNo>4</VersionNo>
							<DateOfSubmission>2016-07-13T00:00:00+05:30</DateOfSubmission>
							<WorkStatusChangeDate>2018-05-14T16:36:24+05:30</WorkStatusChangeDate>
							<WorkStatusType>3</WorkStatusType>
							<WorkStatusDescription>Worked</WorkStatusDescription>
							<FraudStatusChangeDate>2018-05-14T16:36:24+05:30</FraudStatusChangeDate>
							<FraudStatusType>5</FraudStatusType>
							<FraudStatusDescription>Suspect</FraudStatusDescription>
							<CaseManagement>
								<Events>
									<Event>
										<Code>NC14</Code>
									</Event>
								</Events>
							</CaseManagement>
						</WorkStatusNotification>
					</Message>
				</Hunter2Notification>
			</NotificationInput>
		</impl:getNotification>*/
}