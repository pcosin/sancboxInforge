trigger ChatterPostToNuageTrigger on FeedItem(after insert) {
    List<FeedItem> feedsToSync = new List<FeedItem>();
    List<String> casesIds = new List<String>();
    List<String> taskIds = new List<String>();
    List<Case> caseParentList = [
        SELECT Id, AccountId
        FROM Case
        WHERE Nuage_Case_ID__c != NULL
    ];

    List<inov8__PMT_Task__c> taskParentList = [
        SELECT ID, inov8__Phase__r.inov8__Project__r.OwnerId 
        FROM inov8__PMT_Task__c
        WHERE Nuage_Task_Id__c != NULL
    ];

    for (Case caseObj : caseParentList) {
        casesIds.add(caseObj.Id);
    }

    for (inov8__PMT_Task__c taskObj : taskParentList) {
        taskIds.add(taskObj.Id);
    }

    for (FeedItem feedItemObj : Trigger.New) {
        if (
            (casesIds.contains(feedItemObj.ParentId) ||
            taskIds.contains(feedItemObj.ParentId)) &&
            feedItemObj.Body.contains('#Nuage')
        ) {
            feedsToSync.add(feedItemObj);
        }
    }

    if (feedsToSync.size() > 0) {
        System.enqueueJob(new ChatterPostToNuageQueueable(feedsToSync));
    }
}