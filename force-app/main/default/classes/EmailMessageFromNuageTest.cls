@isTest
public with sharing class EmailMessageFromNuageTest {
  @IsTest
  static void doTest() {
    Account nuage = new Account(
      Name = 'The Nuage Group',
      Nuage_Account_ID__c = '0018a00001rQZMqAAO'
    );
    insert nuage;

    Case testCase = new Case(
      Subject = 'Test Case',
      Status = 'New',
      Estimated_max_time__c = 8,
      Origin = 'Email',
      Nuage_Case_ID__c = '50074000002mbMZAAY',
      AccountId = nuage.Id
    );
    insert testCase;

    Test.startTest();

    String response = EmailMessageFromNuage.doPost(
      'info@example.com',
      'Test Name',
      '<p>Hello World</p>',
      testCase.Id,
      testCase.Id,
      '3',
      'Test Examail',
      'Hello World',
      'test@example.com'
    );

    Test.stopTest();
  }
}