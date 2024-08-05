trigger ChatterCommentToNuageTrigger on FeedComment(after insert) {
    Nuage_sync_params__c params = [
        SELECT Feed_Comment_trigger_disable__c
        FROM Nuage_sync_params__c
    ];

    if (params.Feed_Comment_trigger_disable__c) {
        params.Feed_Comment_trigger_disable__c = false;
        update params;
        return;
    }

    List<FeedComment> feedsToSync = new List<FeedComment>();
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

    Set<Id> itemsIds = new Set<Id>();
    for (FeedComment feedCommentObj : Trigger.New) {
        itemsIds.add(feedCommentObj.FeedItemId);
    }

    for (FeedComment feedCommentObj : Trigger.New) {
        if (
            casesIds.contains(feedCommentObj.ParentId) ||
            taskIds.contains(feedCommentObj.ParentId)
        ) {
            feedsToSync.add(feedCommentObj);
        }
    }

    if (feedsToSync.size() > 0) {
        System.enqueueJob(new ChatterCommentToNuageQueueable(feedsToSync));
    }

}