@isTest
private class ProjectRestTest {
    @isTest
    static void testDoPost() {
        // Create test data
        Account testAccount = new Account(
            Name = 'Test Account',
            Nuage_Account_ID__c = 'TestAccount123'
        );
        insert testAccount;

        String name = 'Test Project';
        String description = 'Test project description';
        String startDate = '01/01/2023';
        String endDate = '01/02/2023';
        String accountId = testAccount.Nuage_Account_ID__c;
        String externalId = 'TestProject123';
        String status = 'Active';
        String levelofEffort = 'Medium';
        String portfolio = 'P2P';
        String inistartDate = '01/01/2023';
        String iniendDate = '01/01/2023';

        // Start test
        Test.startTest();

        // Call the method under test
        String projectId = ProjectRest.doPost(
            name,
            description,
            startDate,
            endDate,
            accountId,
            externalId,
            status,
            levelofEffort,
            portfolio,
            inistartDate,
            iniendDate
        );

        // Verify project upserted successfully
        System.assertNotEquals(
            null,
            projectId,
            'Project should be upserted successfully'
        );

        // Verify project details
        inov8__PMT_Project__c savedProject = [
            SELECT
                Name,
                inov8__Description__c,
                Invoice_Account__c,
                Start_Date__c,
                End_Date__c,
                Nuage_Project_ID__c,
                inov8__Level_of_Effort__c,
                inov8__Portfolio__c,
                inov8__Initial_Start_Date__c ,
                inov8__Initial_End_Date__c

            FROM inov8__PMT_Project__c
            WHERE Id = :projectId
        ];

        Test.stopTest();
    }
}