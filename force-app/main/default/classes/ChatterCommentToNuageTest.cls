@isTest
public with sharing class ChatterCommentToNuageTest {
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

    Nuage_sync_params__c params = new Nuage_sync_params__c(
      Feed_Comment_trigger_disable__c = false
    );

    insert params;

    Test.startTest();
    FeedItem testFeedItem = new FeedItem();
    testFeedItem.Body = 'chatter post test';
    testFeedItem.parentID = testCase.Id;
    insert testFeedItem;

    FeedComment testFeedComment = new FeedComment();
    testFeedComment.CommentBody = 'comment test';
    testFeedComment.FeedItemId = testFeedItem.Id;
    insert testFeedComment;
    Test.stopTest();
  }
}