public with sharing class OutOfOfficeTriggerHandler {
    public static void handleAfterInsert(List<OutOfOffice> newOutOfOfficeList) {
        List<Vacation_Request__c> vacationRequests = new List<Vacation_Request__c>();
        Map<Id, String> userIdToName = new Map<Id, String>();

        // Collect all UserIds
        for (OutOfOffice ooo : newOutOfOfficeList) {
            userIdToName.put(ooo.UserId, null);
        }

        // Get user names
        for (User user : [SELECT Id, Name FROM User WHERE Id IN :userIdToName.keySet()]) {
            userIdToName.put(user.Id, user.Name);
        }

        // Create Vacation_Request__c records
        for (OutOfOffice ooo : newOutOfOfficeList) {
            Vacation_Request__c vr = new Vacation_Request__c();

            vr.OwnerId = ooo.UserId;
            vr.Start_Date__c = ooo.StartDate;
            vr.End_Date__c = ooo.EndDate;
            vr.Message__c = ooo.Message;
            vr.Name = userIdToName.get(ooo.UserId) + ' Vacation Request';

            vacationRequests.add(vr);
        }

        // Insert the records from Vacation_Request__c into the database
        if (!vacationRequests.isEmpty()) {
            insert vacationRequests;
        }
    }
}