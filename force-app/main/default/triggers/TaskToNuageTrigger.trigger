trigger TaskToNuageTrigger on inov8__PMT_Task__c(
    after insert,
    after update
) {
    Map<Id, inov8__PMT_Project__c> projectsMap = new Map<Id, inov8__PMT_Project__c>(
        [
            SELECT ID, Nuage_Project_ID__c
            FROM inov8__PMT_Project__c
            WHERE Nuage_Project_ID__c != NULL
        ]
    );

    if (Trigger.isInsert) {
        List<inov8__PMT_Task__c> tasksToInsert = new List<inov8__PMT_Task__c>();
        for (inov8__PMT_Task__c task : Trigger.New) {
            inov8__PMT_Project__c project = projectsMap.get(
                task.PMT_Project__c
            );
            if (task.Sync_from_external__c == false && project != null) {
                tasksToInsert.add(task);
            }
        }
        if (tasksToInsert.size() > 0) {
            System.enqueueJob(new TaskToNuageQueueable(tasksToInsert));
        }
    }

    if (Trigger.isUpdate) {
        List<inov8__PMT_Task__c> tasksToUpdate = new List<inov8__PMT_Task__c>();

        for (Id taskId : Trigger.newMap.keySet()) {
            inov8__PMT_Task__c oldTask = Trigger.oldMap
                .get(taskId);
                inov8__PMT_Task__c newTask = Trigger.newMap
                .get(taskId);

                inov8__PMT_Project__c project = projectsMap.get(
                newTask.PMT_Project__c
            );

            if (newTask.No_Longer_Assigned_To_Us__c) {
                continue;
            }

            if (
                newTask.Sync_from_external__c == false &&
                project != null &&
                (newTask.Name != oldTask.Name ||
                newTask.inov8__Status__c != oldTask.inov8__Status__c ||
                newTask.inov8__Assigned_To1__c != oldTask.inov8__Assigned_To1__c ||
                newTask.Priority__c !=
                oldTask.Priority__c ||
                newTask.inov8__Description__c != oldTask.inov8__Description__c ||
                newTask.Start_Time__c !=
                oldTask.Start_Time__c ||
                newTask.End_Time__c !=
                oldTask.End_Time__c ||
                newTask.Type__c != oldTask.Type__c ||
                newTask.Deployment_Steps__c != oldTask.Deployment_Steps__c ||
                newTask.Sandbox_Name__c != oldTask.Sandbox_Name__c||
                newTask.User_Acceptance_Criteria__c !=
                oldTask.User_Acceptance_Criteria__c ||
                newTask.UAT_Required__c != oldTask.UAT_Required__c ||
                newTask.inov8__On_Hold_Reason__c != oldTask.inov8__On_Hold_Reason__c)
            ) {
                tasksToUpdate.add(Trigger.newMap.get(taskId));
            }
        }

        if (tasksToUpdate.size() > 0) {
            System.enqueueJob(new TaskToNuageQueueable(tasksToUpdate));
        }
    }
}