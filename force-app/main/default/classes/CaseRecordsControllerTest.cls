@IsTest
public without sharing class CaseRecordsControllerTest {

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

        Case openCase = new Case(Subject = 'Test Case ', Status = 'New', Estimated_max_time__c = 8, Origin = 'Default', AccountId = objAcc.Id);
        insert openCase;

        Case closeCase = new Case(Subject = 'Test Case ', Status = 'Closed', Estimated_max_time__c = 8, Origin = 'Default', AccountId = objAcc.Id);
        insert closeCase;

    }
  
   @IsTest
    static  void getOpenCasesTest(){
    List<User> lstUs = new List<User>([SELECT Id FROM User WHERE username = 'testInforge@test.com']);
    List<Case> queryCase = CaseRecordsController.getOpenCases(lstUs[0].Id,false);
       Test.startTest();
       System.assertEquals('New', queryCase[0].Status, 'Case Were Not Created');
       Test.stopTest();
   }

   @IsTest
   static  void getClosedCasesTest(){
    List<User> lstUs = new List<User>([SELECT Id FROM User WHERE username = 'testInforge@test.com']);
    List<Case> queryCase = CaseRecordsController.getClosedCases(lstUs[0].Id,false);
    Test.startTest();
    System.assertEquals('Closed', queryCase[0].Status, 'Case Were Not Created');
    Test.stopTest();
   }

   @IsTest
   static  void getFilterOpenCasesTest(){
   List<User> lstUs = new List<User>([SELECT Id FROM User WHERE username = 'testInforge@test.com']);
   List<Case> queryCase = new List<Case>();
   List<String> filters = new List<String>();
   filters.add('allTime');
   filters.add('thisWeek');
   filters.add('lastWeek');
   filters.add('thisMonth');
   filters.add('lastMonth');
   filters.add('thisYear');
   filters.add('yesterday');
   filters.add('today');
   filters.add('billingPeriod');
   filters.add('fiscalQuarter');
   filters.add('lastQuarter');

   for (String filterValue : filters) {
    List<Case> result =  CaseRecordsController.getFilterCases(lstUs[0].Id, filterValue, 'Open');
    if (!result.isEmpty()) {
        queryCase.add(result[0]);
    }
   }
      Test.startTest();
      System.assertEquals('New', queryCase[0].Status, 'Case Were Not Created');
      Test.stopTest();
  }

   @IsTest
   static  void getFilterClosedCasesTest(){
    List<User> lstUs = new List<User>([SELECT Id FROM User WHERE username = 'testInforge@test.com']);
    List<Case> queryCase = new List<Case>();
    List<String> filters = new List<String>();
    filters.add('allTime');
    filters.add('thisWeek');
    filters.add('lastWeek');
    filters.add('thisMonth');
    filters.add('lastMonth');
    filters.add('thisYear');
    filters.add('yesterday');
    filters.add('today');
    filters.add('billingPeriod');
    for (String filterValue : filters) {
        List<Case> result =  CaseRecordsController.getFilterCases(lstUs[0].Id, filterValue, 'Closed');
        if (!result.isEmpty()) {
            queryCase.add(result[0]);
        }
       }
    Test.startTest();
    System.assertEquals('Closed', queryCase[0].Status, 'Case Were Not Created');
    Test.stopTest();
   }

}