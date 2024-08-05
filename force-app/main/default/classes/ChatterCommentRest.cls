@RestResource(urlMapping='/chatterComment/*')
global with sharing class ChatterCommentRest {
    @HttpPost
    global static String doPost(
        String parentId,
        String feedItemId,
        String username,
        String body
    ) {
        Case caseSaved;
        inov8__PMT_Task__c taskSaved;
        FeedItem feedItemSaved;

        Nuage_sync_params__c params = [
            SELECT Inforge_User_Id__c, Feed_Comment_trigger_disable__c
            FROM Nuage_sync_params__c
        ];

        Boolean parentSync = false;

        try {
            caseSaved = [
                SELECT Id, OwnerId
                FROM Case
                WHERE Nuage_Case_ID__c = :parentId
            ];
            parentSync = true;
        } catch (Exception ex) {
            System.debug('Case is not synchronized');
        }

        try {
            taskSaved = [
                SELECT ID, inov8__Assigned_To1__c
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

        params.Feed_Comment_trigger_disable__c = true;
        update params;

        body = body.replaceAll('</p>', '\n');
        body = body.replaceAll('<[^>]+>', ' ');

        FeedComment fc = new FeedComment();
        fc.CommentBody =
            +'<html>' +
            username +
            ' commented: ' +
            body +
            '\n\n' +
            '</html>';
        fc.FeedItemId = feedItemId;
        insert fc;

        return fc.Id;
    }
}