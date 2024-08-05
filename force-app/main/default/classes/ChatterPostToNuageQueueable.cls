public with sharing class ChatterPostToNuageQueueable implements Queueable, Database.AllowsCallouts {
    public List<FeedItem> feedItems;

    public ChatterPostToNuageQueueable(List<FeedItem> feedItems) {
        this.feedItems = feedItems;
    }

    public void execute(QueueableContext context) {
        Map<ID, User> usersMap = new Map<ID, User>([SELECT Id, Name FROM User]);
        Map<Id, Id> feedItemIdMap = new Map<Id, Id>();

        for (FeedItem feedItemObj : feedItems) {
            FeedItemWrapper fw = new FeedItemWrapper();
            fw.parentId = feedItemObj.ParentId;
            User userWhoCommented = usersMap.get(feedItemObj.CreatedById);
            if (userWhoCommented != null) {
                fw.username = userWhoCommented.Name;
            }
            fw.body = feedItemObj.Body;
            fw.externalId = feedItemObj.Id;

            String jsonBody = JSON.serialize(fw);

            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:Nuage/chatterPost/');
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
                idResponse = resp.getBody().replaceAll('"', '');
            } else {
                idResponse = '0D57400000OVs0WCAT';
            }

            if (checkFeedItemID(idResponse)) {
                feedItemIdMap.put(feedItemObj.Id, idResponse);
            }
        }

        List<Feed_Item_Sync__c> fiList = new List<Feed_Item_Sync__c>();
        for (Id fId : feedItemIdMap.keySet()) {
            Feed_Item_Sync__c fy = new Feed_Item_Sync__c(
                Feed_Item_Id__c = fId,
                External_Id__c = feedItemIdMap.get(fId)
            );
            fiList.add(fy);
        }
        insert fiList;
    }

    public class FeedItemWrapper {
        public String parentId;
        public String username;
        public String body;
        public String externalId;
    }

    public boolean checkFeedItemID(String theId) {
        System.Type t = FeedItem.class;
        try {
            if (
                Pattern.compile('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}')
                    .matcher(theId)
                    .matches()
            ) {
                Id id = theId;
                sObject sObj = (sObject) t.newInstance();
                sObj.Id = id;
                return true;
            }
        } catch (Exception e) {
            System.debug('Invalid Id');
        }
        return false;
    }
}