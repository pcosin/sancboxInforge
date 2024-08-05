public with sharing class ChatterCommentToNuageQueueable implements Queueable, Database.AllowsCallouts {
    public List<FeedComment> feedComments;

    public ChatterCommentToNuageQueueable(List<FeedComment> feedComments) {
        this.feedComments = feedComments;
    }

    public void execute(QueueableContext context) {
        Map<ID, User> usersMap = new Map<ID, User>([SELECT Id, Name FROM User]);

        Set<Id> feedItemsIds = new Set<Id>();
        for (FeedComment fc : feedComments) {
            feedItemsIds.add(fc.FeedItemId);
        }
        Map<ID, Id> feedItemsMap = new Map<ID, Id>();
        List<Feed_Item_Sync__c> feedSyncList = [
            SELECT Id, Feed_Item_Id__c, External_Id__c
            FROM Feed_Item_Sync__c
            WHERE Feed_Item_Id__c IN :feedItemsIds
        ];
        for (Feed_Item_Sync__c fs : feedSyncList) {
            feedItemsMap.put(fs.Feed_Item_Id__c, fs.External_Id__c);
        }

        for (FeedComment feedCommentObj : feedComments) {
            FeedCommentWrapper fw = new FeedCommentWrapper();

            fw.parentId = feedCommentObj.ParentId;
            User userWhoCommented = usersMap.get(feedCommentObj.CreatedById);
            if (userWhoCommented != null) {
                fw.username = userWhoCommented.Name;
            }
            fw.body = feedCommentObj.CommentBody;

            fw.feedItemId = feedItemsMap.get(feedCommentObj.FeedItemId);

            String jsonBody = JSON.serialize(fw);

            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:Nuage/chatterComment/');
            req.setHeader('Content-Type', 'application/json');
            req.setMethod('POST');
            req.setBody(jsonBody);
            Http http = new Http();

            String idResponse;
            if (!Test.isRunningTest()) {
                HTTPResponse resp = http.send(req);
                System.debug(
                    'response:' + resp.getStatus() + ' ' + resp.getBody()
                );
            }
        }
    }

    public class FeedCommentWrapper {
        public String parentId;
        public String feedItemId;
        public String username;
        public String body;
    }
}