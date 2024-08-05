trigger TimeEntryToNuageTrigger on Time_Entry__c(
    after insert,
    after update,
    after delete
) {
    if (Trigger.isInsert) {
        TimeTrackSyncHandler.afterInsert(Trigger.new);
    }

    if (Trigger.isUpdate) {
        TimeTrackSyncHandler.afterUpdate(Trigger.oldMap, Trigger.newMap);
    }

    if (Trigger.isDelete) {
        TimeTrackSyncHandler.afterDelete(Trigger.old);
    }
}