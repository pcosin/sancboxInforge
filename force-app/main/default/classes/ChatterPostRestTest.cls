@isTest(SeeAllData=true)
public with sharing class ChatterPostRestTest {
  @IsTest
  static void doTest() {
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
    User testUser = new User();
    testUser.Email = 'johnsmith@testuser.com';
    testUser.Username = 'johnsmith@testuser.com';
    testUser.LastName = 'Smith';
    testUser.Alias = 'jsmith';
    testUser.ProfileId = p.Id;
    testUser.LanguageLocaleKey = 'en_US';
    testUser.LocaleSidKey = 'en_US';
    testUser.TimeZoneSidKey = 'America/Chicago';
    testUser.EmailEncodingKey = 'UTF-8';

    insert testUser;

    Nuage_sync_params__c params = [
      SELECT Inforge_user_Id__c
      FROM Nuage_sync_params__c
    ];

    params.Inforge_user_Id__c = testUser.Id;
    update params;

    Account nuage = new Account(
      Name = 'Test Account',
      Nuage_Account_ID__c = '0018a00001rQZMqAAO'
    );
    insert nuage;

    Case testCase = new Case(
      Subject = 'Test Case',
      Status = 'New',
      Estimated_max_time__c = 8,
      Origin = 'Email',
      Nuage_Case_ID__c = '5008a00001wf8jMAAQ',
      AccountId = nuage.Id
    );
    insert testCase;

    Test.startTest();

    ChatterPostRest.doPost(
      '5008a00001wf8jMAAQ',
      'Test User',
      'Hello world',
      '0018a00001rQZMqAAO'
    );

    Test.stopTest();
  }
}