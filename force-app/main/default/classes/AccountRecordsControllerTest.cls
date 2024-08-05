@IsTest
public with sharing class AccountRecordsControllerTest {
   
    @TestSetup
    static void makeData(){

        Account objAcc = new Account();
        objAcc.Name = 'BookNook';
        objAcc.Agreed_Monthly_Hours__c = 40;
        insert objAcc;

        Contact contact = new Contact();
        contact.FirstName = 'User';
        contact.LastName = 'test';
        contact.AccountId = objAcc.Id;

        insert contact;

        Profile prof = [select id from profile where name LIKE '%Customer%' LIMIT 1];

        User user = new User();
        user.firstName = 'test1';
        user.lastName = 'test2';
        user.ContactId = contact.Id;
        user.profileId = prof.id;
        user.username = 'testInforge@test.com';
        user.email = 'test@test.com';
        user.Alias = 'iadmi';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.EmailEncodingKey = 'UTF-8';
        user.LanguageLocaleKey = 'en_US';
        insert user;

    }

    @IsTest
    static void getAccountRecordsTest(){
    List<User> lstUs = new List<User>([SELECT Id FROM User WHERE username = 'testInforge@test.com']);
    List<Account> queryCase = AccountRecordsController.getHours(lstUs[0].Id);
       Test.startTest();
       System.assertEquals(40, queryCase[0].Agreed_Monthly_Hours__c, 'Account Were Not Created');
       Test.stopTest();
    }
}