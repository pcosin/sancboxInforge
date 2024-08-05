@isTest
public with sharing class OutOfOfficeTriggerHandlerTest {
    @isTest
    static void testHandleAfterInsert() {
        OutOfOffice newOutOfOffice = new OutOfOffice();
        newOutOfOffice.UserId = UserInfo.getUserId();
        newOutOfOffice.StartDate = Date.today();
        newOutOfOffice.EndDate = Date.today().addDays(7);
        newOutOfOffice.Message = 'Out of office due to vacation.';

        Test.startTest();
        insert newOutOfOffice;
        Test.stopTest();

        List<Vacation_Request__c> createdRequests = [SELECT OwnerId, Start_Date__c, End_Date__c, Message__c, Name FROM Vacation_Request__c];
        
        System.assertEquals(1, createdRequests.size(), 'There should be exactly one Vacation Request created.');
    }
}