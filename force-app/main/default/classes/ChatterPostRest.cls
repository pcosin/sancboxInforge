@RestResource(urlMapping='/chatterPost/*')
global with sharing class ChatterPostRest {
    @HttpPost
    global static String doPost(
        String parentId,
        String username,
        String body,
        String externalId
    ) {
        Case caseSaved;
        inov8__PMT_Task__c taskSaved;

        Nuage_sync_params__c params = [
            SELECT Inforge_User_Id__c
            FROM Nuage_sync_params__c
        ];

        Boolean parentSync = false;

        try {
            caseSaved = [
                SELECT Id, OwnerId, QA__c
                FROM Case
                WHERE Nuage_Case_ID__c = :parentId
            ];
            parentSync = true;
        } catch (Exception ex) {
            System.debug('Case is not synchronized');
        }

        try {
            taskSaved = [
                SELECT ID, inov8__Assigned_To1__c, QA__c
                FROM inov8__PMT_Task__c
                WHERE Nuage_Task_ID__c = :parentId
            ];
            parentSync = true;
        } catch (Exception ex) {
            System.debug('Task is not synchronized');
        }

        if (!parentSync) {
            return null;
        }

        User userAdmin;
        try {
            userAdmin = [
                SELECT Id
                FROM User
                WHERE Id = :params.Inforge_User_Id__c
            ];
        } catch (Exception e) {
            System.debug('User Inforge Admin not found');
            return null;
        }

        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MentionSegmentInput mentionSegmentAssigned = new ConnectApi.MentionSegmentInput();
        ConnectApi.MentionSegmentInput mentionSegmentQA = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        ConnectApi.TextSegmentInput textSegmentBlank = new ConnectApi.TextSegmentInput();

        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        if (caseSaved != null) {
            mentionSegmentAssigned.Id = caseSaved.OwnerId;
            mentionSegmentQA.Id = caseSaved.QA__C;
            feedItemInput.subjectId = caseSaved.Id;
        }

        if (taskSaved != null) {
            mentionSegmentAssigned.id = taskSaved.inov8__Assigned_To1__c;
            mentionSegmentQA.Id = taskSaved.QA__C;
            feedItemInput.subjectId = taskSaved.Id;
        }

        //body = body.unescapeHtml4();
        body = body.replaceAll('</p>', '\n');
        body = body.replaceAll('<[^>]+>', ' ');
        textSegmentInput.text = username + ' commented: ' + body + '\n\n';

        textSegmentBlank.text = ' ';
        messageBodyInput.messageSegments.add(textSegmentInput);
        messageBodyInput.messageSegments.add(mentionSegmentAssigned);
        messageBodyInput.messageSegments.add(textSegmentBlank);
        messageBodyInput.messageSegments.add(mentionSegmentQA);

        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;

        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(
            Network.getNetworkId(),
            feedItemInput
        );

        Feed_Item_Sync__c newFeed = new Feed_Item_Sync__c(
            Feed_Item_Id__c = feedElement.Id,
            External_Id__c = externalId
        );
        insert newFeed;

        System.debug('Chatter post inserted: :' + feedElement.Id);
        return feedElement.Id;
    }
}