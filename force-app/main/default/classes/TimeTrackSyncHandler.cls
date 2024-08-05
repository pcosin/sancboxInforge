public with sharing class TimeTrackSyncHandler {
    public TimeTrackSyncHandler() {
    }

    public static void afterInsert(List<SObject> details) {
        Set<Id> detailsToInsert = new Set<Id>();

        for (SObject detail : details) {
            Boolean needsToSync = (Boolean) detail.get(
                TimeTrackSyncUtils.timeTrack_FlagToSync_FieldApiName
            );

            if (needsToSync) {
                detailsToInsert.add(detail.Id);
            }
        }

        if (!detailsToInsert.isEmpty()) {
            System.enqueueJob(new TimeEntryToNuageQueueable(detailsToInsert));
        }
    }

    public static void afterUpdate(
        Map<Id, SObject> detailsOld,
        Map<Id, SObject> detailsNew
    ) {
        Set<Id> detailsToUpdate = new Set<Id>();
        for (Id detailId : detailsNew.keySet()) {
            SObject detailOld = detailsOld.get(detailId);
            SObject detailNew = detailsNew.get(detailId);
            Boolean needsToSync = (Boolean) detailNew.get(
                TimeTrackSyncUtils.timeTrack_FlagToSync_FieldApiName
            );

            if (
                needsToSync &&
                TimeTrackSyncUtils.hasFieldsChanged(detailNew, detailOld)
            ) {
                detailsToUpdate.add(detailId);
            }
        }

        System.debug('@detailsToUpdate: ' + detailsToUpdate);
        if (detailsToUpdate.size() > 0) {
            System.enqueueJob(new TimeEntryToNuageQueueable(detailsToUpdate));
        }
    }

    public static void afterDelete(List<SObject> details) {
        Set<Id> detailsToDelete = new Set<Id>();

        for (SObject detail : details) {
            Boolean needsToSync = (Boolean) detail.get(
                TimeTrackSyncUtils.timeTrack_FlagToSync_FieldApiName
            );

            if (needsToSync) {
                detailsToDelete.add(detail.Id);
            }
        }

        System.debug('@detailsToDelete: ' + detailsToDelete);

        if (detailsToDelete.size() > 0) {
            System.enqueueJob(
                new TimeEntryToNuageQueueable(detailsToDelete, 'DELETE')
            );
        }
    }
}