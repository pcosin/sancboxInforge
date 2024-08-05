public with sharing class TimeTrackSyncUtils {
    public static String timeTrack_ObjectApiName = 'Time_Entry__c';
    public static String timeTrack_FlagToSync_FieldApiName = 'Needs_Data_Sync__c';
    public static String timeTrack_ExternalId_FieldApiName = 'Nuage_TTDetail_ID__c';

    /**
     * Fields for the time track objects as values, with keys using in json request
     */

        public static Map<String, String> timeTrack_Name_Fields = new Map<String, String>{
        'id' => 'Id',
        'accountId' => 'Account__c',
        'caseId' => 'Case__c',
        'projectId' => 'Project__c',
        'taskId' => 'Task__c',
        'notes' => 'Notes__c',
        'startTimestampInSeconds' => 'Start_Timestamp__c',
        'endTimestampInSeconds' => 'End_Timestamp__c',
        'invoiceFlag' => 'Invoice_Flag__c',
        'username' => 'User_Full_Name__c',
        'timeWorked' => 'Time_Worked__c',
        'externalCaseId' => 'External_Case_ID__c',
        'externalTaskId' => 'External_Task_ID__c',
        'externalProjectId' => 'External_Project_ID__c',
        'externalAccountId' => 'External_Account_ID__c',
        'externalId' => 'Nuage_TTDetail_ID__c'
    };

    public TimeTrackSyncUtils() {
    }

    public static List<SObject> getTimeTrackDetails(Set<Id> detailsIds) {
        String idsString = String.join(new List<Id>(detailsIds), '\',\'');

        String query =
            'SELECT ' +
            String.join(timeTrack_Name_Fields.values(), ',') +
            ' FROM ' +
            timeTrack_ObjectApiName +
            ' WHERE Id IN (\'' +
            idsString +
            '\')';

        List<SObject> details = Database.query(query);

        return details;
    }

    public static List<SObject> getTimeTrackDetailsDeleted(Set<Id> detailsIds) {
        String idsString = String.join(new List<Id>(detailsIds), '\',\'');

        String query =
            'SELECT ' +
            String.join(timeTrack_Name_Fields.values(), ',') +
            ' FROM ' +
            timeTrack_ObjectApiName +
            ' WHERE Id IN (\'' +
            idsString +
            '\') AND  IsDeleted = true ALL ROWS';

        List<SObject> details = Database.query(query);

        return details;
    }

    //This method has the same logic as the field Nuage_Hours
    public static Decimal calculateRoundedHours(Decimal timeWorked) {
        Decimal decimalDifference = timeWorked - Math.floor(timeWorked);
        Decimal roundedTime = 0;
        if (decimalDifference == 0 || decimalDifference == 0.5) {
            roundedTime = timeWorked;
        } else if (decimalDifference < 0.5) {
            roundedTime = timeWorked + (0.5 - decimalDifference);
        } else {
            roundedTime = timeWorked + (Math.ceil(timeWorked) - timeWorked);
        }
        return roundedTime;
    }

    /**
     * Calculate the End date time by adding the start date time with the hours rounded
     *
     * @param startDateTime dftlytime__Start_Timestamp__c
     * @param hoursWorked dftlytime__Time_Worked__c
     * @return `End date time rounded`
     */
    public static DateTime calculateEndDateTime(
        DateTime startDateTime,
        Decimal hoursWorked
    ) {
        if (hoursWorked == null) {
            hoursWorked = 0;
        }
        Integer hourToseconds = 0;
        Decimal roundedHours = 0;

        roundedHours = calculateRoundedHours(hoursWorked);
        hourToseconds = (Integer) Math.round(roundedHours * 3600);

        Long milliseconds = hourToseconds * 1000L;
        Long dateTimeMilliseconds = startDateTime.getTime();

        dateTimeMilliseconds += milliseconds;

        DateTime endDateWithRoundedHours = DateTime.newInstance(
            dateTimeMilliseconds
        );

        return endDateWithRoundedHours;
    }

    /**
     * Update the External field from time track detail record, with the id returned from the other org
     *
     * @param idsWithExternalMap map of Id (time track detail ID), with value Id (external time track detail ID)
     */
    public static void updateTimeTrackDetailWithExternalId(
        Map<Id, Id> idsWithExternalMap
    ) {
        String idsString = String.join(
            new List<Id>(idsWithExternalMap.keySet()),
            '\',\''
        );

        String query =
            ' SELECT Id FROM ' +
            timeTrack_ObjectApiName +
            ' WHERE Id IN (\'' +
            idsString +
            '\')';

        List<SObject> records = Database.query(query);

        for (SObject record : records) {
            Id externalId = idsWithExternalMap.get(record.Id);

            if (externalId != null) {
                record.put(timeTrack_ExternalId_FieldApiName, externalId);
            }
        }
        update records;
    }

    /**
     * Returns true if it detects that there was any change in any field
     * @param newDetail time track detail after field chage
     * @param oldDetail time track detail before field change
     * @return  `Boolean` indicates if there is some change in any field
     */
    public static Boolean hasFieldsChanged(
        SObject newDetail,
        SObject oldDetail
    ) {
        for (String field : timeTrack_Name_Fields.values()) {
            if (
                newDetail.get(field) != oldDetail.get(field) &&
                field != timeTrack_Name_Fields.get('externalId')
            ) {
                return true;
            }
        }
        return false;
    }
}