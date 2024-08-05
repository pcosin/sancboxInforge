@IsTest
public with sharing class TestSendEmailOpenCases {
    @IsTest
    static void testSendCaseReportsWithCases() {
        // Set up custom settings
        OpenCases_Settings__c settings = new OpenCases_Settings__c(Name = 'Default', Days_Limit__c = 7);
        insert settings;

        Account a = new Account(Name = 'Test Account');
        insert a;

        // Ensure the CreatedDate reflects the testing scenario
        Date testDate = Date.today().addDays(-9); // This simulates the date calculation

        Case openCase = new Case(
            Subject = 'Test Case',
            Origin = 'Email',
            AccountId = a.Id,
            Status = 'New',
            Case_Status__c = 'New',
            QA__c = UserInfo.getUserId(),
            CreatedDate = testDate
        );
        insert openCase;

        // Start the test execution
        Test.startTest();
        SendEmailOpenCases.sendCaseReports();
        Test.stopTest();
    }

    @IsTest
    static void testSendCaseReportsNoCases() {
        // Set up custom settings
        OpenCases_Settings__c settings = new OpenCases_Settings__c(Name = 'Default', Days_Limit__c = 10);
        insert settings;

        // No cases are created here, simulating a scenario with no applicable cases

        // Start the test execution
        Test.startTest();
        SendEmailOpenCases.sendCaseReports();
        Test.stopTest();
    }

    @IsTest
    static void testScheduledExecution() {
        Test.startTest();
        String cronExpr = '0 0 1 * * ?'; // Example CRON expression
        System.schedule('Test Schedule SendEmailOpenCases', cronExpr, new ScheduledSendEmailOpenCases());        
        Test.stopTest();
    }
}