@isTest
private class ubc_TimeEntrySearchTasksTest {

    @isTest
    static void testGetTasksByProjectId() {
        
        // Create Account 1
        Account acc = new Account(Name = 'Test');
        insert acc;

        // Create Project 1
        inov8__PMT_Project__c testProject = new inov8__PMT_Project__c(
            Invoice_Account__c = acc.Id,
            Name = 'Test Project',
            inov8__Level_of_Effort__c = 'Medium',
            inov8__Portfolio__c = 'P2P',
            inov8__Initial_Start_Date__c = Date.today(),
            inov8__Initial_End_Date__c = Date.today().addMonths(1)
        );
        insert testProject;

        // Create Phase
        inov8__PMT_Phase__c ph = new inov8__PMT_Phase__c(
            inov8__Project__c = testProject.Id,
            Name = 'Test Phase'
        );
        insert ph;

        // Create Task 1
        inov8__PMT_Task__c testTask = new inov8__PMT_Task__c(
            PMT_Project__c = testProject.Id,
            Name = 'Test Task',
            Approved_Hours_Logged__c = 10,
            inov8__Assigned_To1__c = UserInfo.getUserId(),
            QA__c = UserInfo.getUserId(),
            inov8__Phase__c = ph.Id,
            inov8__Start_Date__c = Date.today(),
            inov8__Due_Date__c = Date.today().addMonths(1)
        );

        // Inserting the task
        insert testTask;

        // Call the method from your Apex class
        List<ubc_TimeEntrySearchTasks.TaskWrapper> result = ubc_TimeEntrySearchTasks.getTasksByProjectId(testProject.Id);

        // Positive Scenario: Verify that the correct number of tasks are returned
        System.assertEquals(1, result.size(), 'The number of tasks returned should be 1');

        // Positive Scenario: Verify the details of the first task
        System.assertEquals(testTask.Id, result[0].taskId, 'The task Id should match');
        System.assertEquals(testTask.Name, result[0].taskName, 'The task Name should match');
    }
}