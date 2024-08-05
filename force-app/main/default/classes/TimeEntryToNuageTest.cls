@isTest(SeeAllData=true)
public class TimeEntryToNuageTest {

    private class RestMock implements HttpCalloutMock {
        private String jsonResponse;

        public RestMock(String jsonResponse) {
            this.jsonResponse = jsonResponse;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json;charset=UTF-8');
            res.setBody(jsonResponse);
            res.setStatusCode(200);
            return res;
        }
    }

    private static SObject queryDetail(Id recordId) {
        try {
            String query =
                'SELECT ' +
                String.join(
                    TimeTrackSyncUtils.timeTrack_Name_Fields.values(),
                    ','
                ) +
                ' FROM ' +
                TimeTrackSyncUtils.timeTrack_ObjectApiName +
                ' WHERE Id = \'' +
                recordId +
                '\'';

            SObject record = Database.query(query);

            return record;
        } catch (Exception e) {
            return null;
        }
    }

    private static SObject createData() {
        Account testAccount = new Account(
            Name = 'The Nuage Group',
            Nuage_Account_ID__c = '0018a00001rQZMqAAO'
        );
        insert testAccount;

        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Estimated_max_time__c = 8,
            Origin = 'Email',
            Nuage_Case_ID__c = '50074000002mbMZAAY',
            AccountId = testAccount.Id
        );
        insert testCase;

        String timeTrack_ObjectApiName = TimeTrackSyncUtils.timeTrack_ObjectApiName;
        String timeTrack_Case_FieldApiName = TimeTrackSyncUtils.timeTrack_Name_Fields.get(
            'caseId'
        );
        String timeTrack_Notes_FieldApiName = TimeTrackSyncUtils.timeTrack_Name_Fields.get(
            'notes'
        );
        String timeTrack_Start_FieldApiName = TimeTrackSyncUtils.timeTrack_Name_Fields.get(
            'startTimestampInSeconds'
        );
        String timeTrack_End_FieldApiName = TimeTrackSyncUtils.timeTrack_Name_Fields.get(
            'endTimestampInSeconds'
        );

        SObject detailRecord = Schema.getGlobalDescribe()
            .get(timeTrack_ObjectApiName)
            .newSObject();

        detailRecord.put(timeTrack_Case_FieldApiName, testCase.Id);
        detailRecord.put(timeTrack_Notes_FieldApiName, 'Test notes');
        detailRecord.put(timeTrack_Start_FieldApiName, DateTime.now());
        detailRecord.put(
            timeTrack_End_FieldApiName,
            DateTime.now().addHours(1)
        );

        insert detailRecord;

        return detailRecord;
    }

    @IsTest
    static void insertTest() {
        SObject detailRecord = createData();

        String jsonResponse =
            '{ "response" : [{"success" : true, "id" : "a3kEm0000000JnRIAU",  "externalId" : "' +
            detailRecord.Id +
            '",  "error" : null}]}';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock(jsonResponse));
        Test.stopTest();

        detailRecord = queryDetail(detailRecord.Id);
        System.assertEquals(
            'a3kEm0000000JnRIAU',
            detailRecord.get(
                TimeTrackSyncUtils.timeTrack_ExternalId_FieldApiName
            )
        );
    }

    @IsTest
    static void updateTest() {
        SObject detailRecord = createData();

        String jsonResponse =
            '{ "response" : [{"success" : true, "id" : "a3kEm0000000JnRIAU",  "externalId" : "' +
            detailRecord.Id +
            '",  "error" : null}]}';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock(jsonResponse));
        Test.stopTest();

        detailRecord.put('Invoice_Flag__c', 'Cost');
        update detailRecord;

        detailRecord = queryDetail(detailRecord.Id);
        System.assertEquals(
            'Cost',
            detailRecord.get(
                TimeTrackSyncUtils.timeTrack_Name_Fields.get('invoiceFlag')
            )
        );
    }

    @IsTest
    static void deleteTest() {
        SObject detailRecord = createData();
        Id deletedId = detailRecord.Id;
        delete detailRecord;

        String jsonResponse =
            '{ "response" : [{"success" : true, "id" : "a3kEm0000000JnRIAU",  "externalId" : "' +
            deletedId +
            '",  "error" : null}]}';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock(jsonResponse));
        Test.stopTest();

        detailRecord = queryDetail(deletedId);
        System.assertEquals(detailRecord, null);
    }

    @isTest
    static void testSendEmailWithIds() {
        Nuage_sync_params__c params = [
            SELECT Email_Notification__c
            FROM Nuage_sync_params__c
        ];

        Set<Id> ids = new Set<Id>{ 'a1vUn000000UMpAIAW' };

        String message = 'This IDs have errors:';

        Test.startTest();

        TimeEntryToNuageQueueable.sendEmailWithIds(ids, message);

        Test.stopTest();
    }

    @isTest
    static void testCalculateRoundedHours() {
        Decimal[] testValues = new List<Decimal>{
            1.15,
            2.25,
            4,
            3.5,
            4.6,
            4.75
        };
        Decimal[] correctTestValues = new List<Decimal>{
            1.5,
            2.5,
            4,
            3.5,
            5,
            5
        };

        for (Integer i = 0; i < 6; i++) {
            Decimal expectedValue = TimeTrackSyncUtils.calculateRoundedHours(
                testValues[i]
            );
            System.assertEquals(expectedValue, correctTestValues[i]);
        }
    }

    @isTest
    static void testCalculateEndDateTime() {
        DateTime startDateTime = Datetime.newInstanceGmt(
            2023,
            10,
            30,
            12,
            0,
            0
        );
        DateTIme endDateTime = Datetime.newInstanceGmt(2023, 10, 30, 13, 30, 0);
        Decimal hoursWorked = 1.25;
        Datetime calculatedEndDateTime = TimeTrackSyncUtils.calculateEndDateTime(
            startDateTime,
            hoursWorked
        );
        System.assertEquals(endDateTime, calculatedEndDateTime);
    }
}