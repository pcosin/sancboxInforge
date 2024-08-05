public with sharing class ubc_TimeEntrySearchTasks {
    @AuraEnabled(cacheable=true)
    public static List<TaskWrapper> getTasksByProjectId(String projectId) {
        List<TaskWrapper> projectTasks = new List<TaskWrapper>();

        // Retrieve tasks related to the specified project
        List<inov8__PMT_Task__c> tasks = [SELECT Id, Name FROM inov8__PMT_Task__c WHERE PMT_Project__c = :projectId];
        
        for (inov8__PMT_Task__c t : tasks) {
            projectTasks.add(new TaskWrapper(t.Id, t.Name));
        }

        return projectTasks;
    }

    // Wrapper class for tasks
    public class TaskWrapper {
        @AuraEnabled
        public Id taskId { get; set; }
        @AuraEnabled
        public String taskName { get; set; }

        public TaskWrapper(Id id, String name) {
            taskId = id;
            taskName = name;
        }
    }
}