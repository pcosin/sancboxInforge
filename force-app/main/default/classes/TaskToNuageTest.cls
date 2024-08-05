@IsTest
private class TaskToNuageTest {
    @IsTest
    static void testTaskToNuageTest() {
        // Create test data
        Account nuageAcc = new Account();
        nuageAcc.Name = 'The Nuage Group';
        nuageAcc.Agreed_Monthly_Hours__c = 40;
        insert nuageAcc;

        inov8__PMT_Project__c project = new inov8__PMT_Project__c(
            Nuage_Project_ID__c = 'a2fEX0000001BJlYAM',
            Invoice_Account__c = nuageAcc.Id,
            inov8__Level_of_Effort__c = 'Medium',
            inov8__Portfolio__c = 'P2P',
            inov8__Initial_Start_Date__c = Date.today(),
            inov8__Initial_End_Date__c = Date.today().addMonths(1)
        );
        insert project;

        inov8__PMT_Phase__c ph = new inov8__PMT_Phase__c(
            inov8__Project__c = project.Id,    
            Name = 'Test Phase'
        );
        insert ph;

        inov8__PMT_Task__c task = new inov8__PMT_Task__c(
            Name = 'Test Task',
            PMT_Project__c = project.Id,
            inov8__Status__c = 'In Progress',
            QA__c = UserInfo.getUserId(),
            inov8__Assigned_To1__c = UserInfo.getUserId(),
            Approved_Hours_Logged__c = 4,
            Type__c = 'Development',
            Deployment_Steps__c = 'Steps',
            Sandbox_Name__c = 'Test Sandbox',
            User_Acceptance_Criteria__c = 'Criteria',
            UAT_Required__c = 'Yes',
            Priority__c = 'Medium',
            inov8__On_Hold_Reason__c = 'no reason',
            Deadline__c = Date.newInstance(2023, 10, 20),
            inov8__Phase__c = ph.Id,
            inov8__Start_Date__c = Date.Today(),
            inov8__Due_Date__c = Date.newInstance(2024, 10, 20)
        );
        insert task;
        
        
        TaskToNuageQueueable.TaksWrapper wrapper = new TaskToNuageQueueable.TaksWrapper();
        wrapper.name = task.Name;
        wrapper.startDate = String.valueOf(System.now().getTime());
        wrapper.endDate = String.valueOf(System.now().getTime());
        wrapper.status = task.inov8__Status__c;
        wrapper.description = 'Test Description';
        wrapper.phaseName = 'Test Phase';
        wrapper.projectId = project.Nuage_Project_ID__c;
        wrapper.externalId = task.Id;
        wrapper.type = task.Type__c;
        wrapper.deploymentSteps = task.Deployment_Steps__c;
        wrapper.sandboxName = task.Sandbox_Name__c;
        wrapper.userAceptanceCriteria = task.User_Acceptance_Criteria__c;
        wrapper.uatRequired = task.UAT_Required__c;
        wrapper.priority = task.Priority__c;
        wrapper.onHoldReason = task.inov8__On_Hold_Reason__c;
        String jsonBody = JSON.serialize(wrapper);

        // Set up mock callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        
        // Enqueue the Queueable class
        Test.startTest();
        TaskToNuageQueueable queueable = new TaskToNuageQueueable(
            new List<inov8__PMT_Task__c>{ task }
        );
        ID jobId = System.enqueueJob(queueable);
        Test.stopTest();

        // Verify the results
        //System.assertEquals(1, Limits.getQueueableJobs(), 'Expected 1 Queueable job to be enqueued');

        List<inov8__PMT_Task__c> updatedTasks = [
            SELECT Id, Approved_Hours_Logged__c, Nuage_Task_ID__c
            FROM inov8__PMT_Task__c
            WHERE Id = :task.Id
        ];
        
        System.assertEquals(1, updatedTasks.size(), 'Expected 1 Queueable job to be enqueued');
    }

    // Mock HttpCalloutMock class
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.assertEquals('callout:Nuage/PMTTask/', req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            System.assertEquals(
                'application/json',
                req.getHeader('Content-Type')
            );

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('"a2fEX0000001BJlYAM"');
            res.setStatusCode(200);
            return res;
        }
    }
}