public with sharing class TimeEntryToNuageQueueable implements Queueable, Database.AllowsCallouts {
    public final String NUAGE_ENDPOINT = 'callout:Nuage/TimeEntry/';
    public Set<Id> detailsIds;
    public String operation;

    public TimeEntryToNuageQueueable(Set<Id> detailsIds) {
        this.detailsIds = detailsIds;
        this.operation = 'POST';
    }

    public TimeEntryToNuageQueueable(Set<Id> detailsIds, String operation) {
        this.detailsIds = detailsIds;
        this.operation = operation;
    }

    public void execute(QueueableContext context) {
        List<Map<String, Object>> payloadRequest = new List<Map<String, Object>>();

        if (this.operation == 'POST') {
            executePost();
        }

        if (this.operation == 'DELETE') {
            executeDelete();
        }
    }

    public void executePost() {
        List<Map<String, Object>> payloadRequest = new List<Map<String, Object>>();
        payloadRequest = createTTDetailWrapperPost(this.detailsIds);

        String jsonBody = JSON.serialize(payloadRequest);
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(NUAGE_ENDPOINT);
            req.setHeader('Content-Type', 'application/json');
            req.setMethod(this.operation);
            req.setBody(jsonBody);
            req.setTimeout(1 * 60 * 1000);
            Http http = new Http();
            HTTPResponse resp = http.send(req);

            System.debug('response:' + resp.getStatus() + ' ' + resp.getBody());

            TTDetailResponseListWrapper ttDetailsResponse = (TTDetailResponseListWrapper) JSON.deserialize(
                resp.getBody(),
                TTDetailResponseListWrapper.class
            );

            Map<Id, Id> ttdetailsMap = new Map<Id, Id>();
            Set<Id> recordsWithErrors = new Set<Id>();
            for (
                TTDetailResponseWrapper ttDetailresponse : ttDetailsResponse.response
            ) {
                if (ttDetailresponse.success) {
                    ttdetailsMap.put(
                        ttDetailresponse.externalId,
                        ttDetailresponse.id
                    );
                } else {
                    recordsWithErrors.add(ttDetailresponse.externalId);
                }
            }

            System.debug('idsWithExternalMap: ' + ttdetailsMap);
            TimeTrackSyncUtils.updateTimeTrackDetailWithExternalId(
                ttdetailsMap
            );

            if (!recordsWithErrors.isEmpty()) {
                sendEmailWithIds(
                    recordsWithErrors,
                    'Error in insert or update'
                );
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
            sendEmailWithIds(this.detailsIds, e.getMessage());
        }
    }

    public void executeDelete() {
        List<Map<String, Object>> payloadRequest = new List<Map<String, Object>>();
        payloadRequest = createTTDetailWrapperDelete(this.detailsIds);

        String jsonBody = JSON.serialize(payloadRequest);

        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(NUAGE_ENDPOINT);
            req.setHeader('Content-Type', 'application/json');
            req.setMethod(this.operation);
            req.setBody(jsonBody);
            req.setTimeout(1 * 60 * 1000);
            Http http = new Http();
            HTTPResponse resp = http.send(req);

            System.debug('response:' + resp.getStatus() + ' ' + resp.getBody());

            TTDetailResponseListWrapper ttDetailsResponse = (TTDetailResponseListWrapper) JSON.deserialize(
                resp.getBody(),
                TTDetailResponseListWrapper.class
            );

            Map<Id, Id> ttdetailsMap = new Map<Id, Id>();
            for (
                TTDetailResponseWrapper ttDetailresponse : ttDetailsResponse.response
            ) {
                if (ttDetailresponse.success) {
                    ttdetailsMap.put(
                        ttDetailresponse.externalId,
                        ttDetailresponse.id
                    );
                }
            }

            System.debug('Time track details deleted: ' + ttdetailsMap);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    public List<Map<String, Object>> createTTDetailWrapperPost(
        Set<Id> detailsIds
    ) {
        List<SObject> details = TimeTrackSyncUtils.getTimeTrackDetails(
            detailsIds
        );

        List<Account> accountsList = [
            SELECT Id, Nuage_Account_ID__c
            FROM Account
            WHERE Nuage_Account_ID__c != NULL
        ];
        Map<Id, Id> accountsMap = new Map<Id, Id>();

        for (Account acc : accountsList) {
            accountsMap.put(acc.Id, acc.Nuage_Account_ID__c);
        }

        List<Map<String, Object>> payloadRequest = new List<Map<String, Object>>();
        for (SObject detail : details) {
            Map<String, Object> payload = new Map<String, Object>();
            for (
                String keyMap : TimeTrackSyncUtils.timeTrack_Name_Fields.keySet()
            ) {
                String fieldName = TimeTrackSyncUtils.timeTrack_Name_Fields.get(
                    keyMap
                );

                if (keyMap == 'startTimestampInSeconds') {
                    DateTime dateTimeValue = (DateTime) detail.get(fieldName);
                    String startTimeStr = String.valueOf(
                        dateTimeValue.getTime()
                    );
                    payload.put(keyMap, startTimeStr);
                } else if (keyMap == 'endTimestampInSeconds') {
                    String startDate_fieldName = TimeTrackSyncUtils.timeTrack_Name_Fields.get(
                        'startTimestampInSeconds'
                    );
                    String timeWorked_fieldName = TimeTrackSyncUtils.timeTrack_Name_Fields.get(
                        'timeWorked'
                    );
                    DateTime endDateTimeValue = TimeTrackSyncUtils.calculateEndDateTime(
                        (DateTime) detail.get(startDate_fieldName),
                        (Decimal) detail.get(timeWorked_fieldName)
                    );
                    String endDateTimeValueStr = String.valueOf(
                        endDateTimeValue.getTime()
                    );
                    payload.put(keyMap, endDateTimeValueStr);
                } else if (keyMap == 'invoiceFlag') {
                    Boolean booleanValue = detail.get(fieldName) == 'Cost';
                    System.debug(booleanValue);
                    payload.put(keyMap, booleanValue);
                } else {
                    Object fieldValue = (Object) detail.get(fieldName);
                    payload.put(keyMap, fieldValue);
                }
            }
            system.debug(JSON.serializePretty(payload));

            payloadRequest.add(payload);
        }
        return payloadRequest;
    }

    public List<Map<String, Object>> createTTDetailWrapperDelete(
        Set<Id> detailsIds
    ) {
        List<SObject> details = TimeTrackSyncUtils.getTimeTrackDetailsDeleted(
            detailsIds
        );

        System.debug('details: ' + details);

        List<Map<String, Object>> payloadRequest = new List<Map<String, Object>>();

        String recordId_fieldName = TimeTrackSyncUtils.timeTrack_Name_Fields.get(
            'id'
        );
        String externalId_fieldName = TimeTrackSyncUtils.timeTrack_Name_Fields.get(
            'externalId'
        );

        for (SObject detail : details) {
            Map<String, Object> payload = new Map<String, Object>();

            Object idfieldValue = (Object) detail.get(recordId_fieldName);
            Object externalIdfieldValue = (Object) detail.get(
                externalId_fieldName
            );
            payload.put('id', idfieldValue);
            payload.put('externalId', externalIdfieldValue);

            payloadRequest.add(payload);
        }

        system.debug(JSON.serializePretty(payloadRequest));

        return payloadRequest;
    }

    public class TTDetailResponseWrapper {
        public Boolean success;
        public String id;
        public String externalId;
        public String error;
    }

    public class TTDetailResponseListWrapper {
        public List<TTDetailResponseWrapper> response;
    }

    public static void sendEmailWithIds(Set<Id> ids, String message) {
        Nuage_sync_params__c params = [
            SELECT Email_Notification__c
            FROM Nuage_sync_params__c
        ];

        List<String> idStrings = new List<String>();

        for (Id id : ids) {
            idStrings.add(
                id.getSObjectType().getDescribe().getName() + ': ' + id
            );
        }

        String emailBody = message + '\n\n' + String.join(idStrings, '\n');

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{ params.Email_Notification__c });
        email.setSubject(
            'Time Track Details not sended to Nuage because errors'
        );
        email.setPlainTextBody(emailBody);

        try {
            Messaging.SendEmailResult[] sendResults = Messaging.sendEmail(
                new List<Messaging.SingleEmailMessage>{ email }
            );

            for (Messaging.SendEmailResult result : sendResults) {
                if (result.isSuccess()) {
                    System.debug('Email sent successfully.');
                } else {
                    System.debug(
                        'Email sending failed. Error: ' +
                        result.getErrors()[0].getMessage()
                    );
                }
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
}