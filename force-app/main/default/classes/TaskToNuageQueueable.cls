public with sharing class TaskToNuageQueueable implements Queueable, Database.AllowsCallouts {
    public List<inov8__PMT_Task__c> tasks;

    public TaskToNuageQueueable(
        List<inov8__PMT_Task__c> tasks
    ) {
        this.tasks = tasks;
    }

    public void execute(QueueableContext context) {
        Map<Id, Id> tasksIdMap = new Map<Id, Id>();
        List<inov8__PMT_Project__c> projectsList = [
            SELECT ID, Nuage_Project_ID__c
            FROM inov8__PMT_Project__c
            WHERE Nuage_Project_ID__c != NULL
        ];

        Map<Id, Id> projectsMap = new Map<Id, Id>();
        for (inov8__PMT_Project__c p : projectsList) {
            projectsMap.put(p.Id, p.Nuage_Project_ID__c);
        }

        Map<Id, User> inforgeUsers = new Map<Id, User>(
            [SELECT ID, Name FROM User WHERE IsActive = TRUE]
        );

        for (inov8__PMT_Task__c task : tasks) {
            TaksWrapper tw = new TaksWrapper();
            tw.externalId = task.Id;
            tw.name = task.Name;

            if (task.Start_Time__c != null) {
                Datetime startDateTime = task.Start_Time__c;
                tw.startDate = String.valueOf(startDateTime.getTime());
            }
            if (task.End_Time__c != null) {
                Datetime endDateTime = task.End_Time__c;
                tw.endDate = String.valueOf(endDateTime.getTime());
            }

            tw.status = task.inov8__Status__c;
            tw.description = task.inov8__Description__c;
            tw.phaseName = task.Nuage_Phase_Name__c != null
                ? task.Nuage_Phase_Name__c
                : 'Build';
            tw.projectId = projectsMap.get(task.PMT_Project__c);

            //User acceptance testing fields
            tw.type = task.Type__c;
            tw.deploymentSteps = task.Deployment_Steps__c;
            tw.sandboxName =  task.Sandbox_Name__c;
            tw.userAceptanceCriteria = task.User_Acceptance_Criteria__c;
            tw.uatRequired = task.UAT_Required__c;
            tw.priority = task.Priority__c;
            tw.onHoldReason = task.inov8__On_Hold_Reason__c;

            //Assigned to details
            tw.assignedToId = task.inov8__Assigned_To1__c;
            tw.assignedTo = inforgeUsers.get(task.inov8__Assigned_To1__c).Name;

            String jsonBody = JSON.serialize(tw);

            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:Nuage/PMTTask/');
            req.setHeader('Content-Type', 'application/json');
            req.setMethod('POST');
            req.setBody(jsonBody);
            Http http = new Http();

            HTTPResponse resp = http.send(req);
            System.debug('response:' + resp.getStatus() + ' ' + resp.getBody());
            String idResponse = resp.getBody().replace('"', '');
            boolean isValidId = idResponse instanceof Id ? true : false;
            if (isValidId) {
                tasksIdMap.put(task.Id, idResponse);
            }
        }

        List<inov8__PMT_Task__c> tasksToUpdate = [
            SELECT Id, Approved_Hours_Logged__c
            FROM inov8__PMT_Task__c
            WHERE Id IN :tasksIdMap.keyset()
        ];
        for (inov8__PMT_Task__c t : tasksToUpdate) {
            t.Nuage_Task_ID__c = tasksIdMap.get(t.Id);
            if (
                t.Approved_Hours_Logged__c == 0 ||
                t.Approved_Hours_Logged__c == null
            ) {
                t.Approved_Hours_Logged__c = 2;
            }
        }
        update tasksToUpdate;
    }

    public class TaksWrapper {
        public String name;
        public String startDate;
        public String endDate;
        public String status;
        public String description;
        public String phaseName;
        public String projectId;
        public String externalId;
        public String type;
        public String deploymentSteps;
        public String sandboxName;
        public String userAceptanceCriteria;
        public String uatRequired;
        public String priority;
        public String onHoldReason;
        public String assignedTo;
        public String assignedToId;
    }
}