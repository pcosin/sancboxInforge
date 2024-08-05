@RestResource(urlMapping='/Task/*')
global with sharing class TaskRest {
    @HttpPost
    global static String doPost(
        String name,
        String startDate,
        String endDate,
        String deadline,
        String status,
        String description,
        String phaseName,
        String projectId,
        String externalId,
        String type,
        String deploymentSteps,
        String userAceptanceCriteria,
        String uatRequired,
        String priority,
        String onHoldReason,
        string phase,
        Boolean disableSync
    ) {
        Map<String, String> statusMap = new Map<String, String>{
            'Not Started' => 'Open',
            'In Progress' => 'In Progress',
            'Ready' => 'Ready',
            'Ready for QA' => 'Ready for QA',
            'On Hold' => 'On Hold',
            'Completed' => 'Completed',
            'Closed, not Completed' => 'Archived',
            'Question/Assistance Needed' => 'Question/Assistance Needed',
            'Deployed to Prod' => 'Deployed to Prod'
        };

        if (projectId == null) {
            return null;
        }

        Nuage_sync_params__c params = [
            SELECT Default_Task_Owner__c, Default_QA__c
            FROM Nuage_sync_params__c
        ];

        inov8__PMT_Task__c taskSaved;
        try {
            taskSaved = [
                SELECT Id, Approved_Hours_Logged__c
                FROM inov8__PMT_Task__c
                WHERE Nuage_Task_Id__c = :externalId
            ];
        } catch (Exception e) {
            System.debug('Error: task is not syncronized. ' + e);
        }

        inov8__PMT_Task__c taskObj = new inov8__PMT_Task__c();
        taskObj.PMT_Project__c = projectId;
        taskObj.inov8__Description__c = description.replaceAll('\n', '<br/>');
        taskObj.Name = name;
        taskObj.Nuage_Task_Id__c = externalId;
        taskObj.Nuage_Phase_Name__c = phaseName;
        taskObj.Sync_from_external__c = true;
        taskObj.inov8__Status__c = statusMap.get(status) != null
            ? statusMap.get(status)
            : status;
        
        taskObj.Priority__c = priority;
        
        taskObj.inov8__On_Hold_Reason__c = onHoldReason;

        taskObj.inov8__Phase__c = phase;

        taskObj.Start_Time__c = Datetime.newInstance(
            long.valueOf(startDate)
        );
        taskObj.End_Time__c = Datetime.newInstance(
            long.valueOf(endDate)
        );
        
        if (deadline != null) {
         	taskObj.Deadline__c = Date.parse(deadline);   
        }
       
        taskObj.No_Longer_Assigned_To_Us__c = disableSync;

        if (taskSaved != null) {
            taskObj.Id = taskSaved.Id;
            if (
                taskSaved.Approved_Hours_Logged__c == null ||
                taskSaved.Approved_Hours_Logged__c == 0
            ) {
                taskObj.Approved_Hours_Logged__c = 2;
            } else {
                taskObj.Approved_Hours_Logged__c = taskSaved.Approved_Hours_Logged__c;
            }
        } else {
            taskObj.inov8__Assigned_To1__c = params.Default_Task_Owner__c;
            taskObj.QA__c = params.Default_QA__c;
        }

        //Assign default value in approved hours
        try {
            if (
                taskObj.Approved_Hours_Logged__c == null ||
                taskObj.Approved_Hours_Logged__c == 0
            ) {
                taskObj.Approved_Hours_Logged__c = 2;
            }

            upsert taskObj;
            taskObj.Sync_from_external__c = false;

            update taskObj;
            return taskObj.Id;
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            return null;
        }
    }
}