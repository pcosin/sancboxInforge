@isTest
public with sharing class ChatterPostToNuageTest {
  @IsTest
  static void methodName() {
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

    FeedItem testFeedItem = new FeedItem();
    testFeedItem.Body = 'chatter post test';
    testFeedItem.parentID = testCase.Id;
    insert testFeedItem;

    List<FeedItem> testFeedItemList = new List<FeedItem>();
    testFeedItemList.add(testFeedItem);
    Test.startTest();

    System.enqueueJob(new ChatterPostToNuageQueueable(testFeedItemList));
    Test.stopTest();
  }
}