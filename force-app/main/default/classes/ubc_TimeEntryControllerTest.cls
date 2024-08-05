@isTest
public class ubc_TimeEntryControllerTest {

    @isTest
    static void testGetAllProjectsAndCases() {
        // Create Account 1
        Account acc = new Account(Name = 'Test');
        insert acc;

        // Create Account 2
        Account acc2 = new Account(Name = 'Test2');
        insert acc2;

        // Create Account 3

        Account acc3 = new Account(Name = 'Test3');
        insert acc3;

        // Create Case 1
        Case testCase = new Case(
            Subject = 'Test Case',
            AccountId = acc.Id 
        );
        insert testCase;

        // Create Case 2
        Case testCase2 = new Case(
            Subject = 'Test Case 2',
            AccountId = acc2.Id 
        );
        insert testCase2;

        // Create Case 3
        Case testCase3 = new Case(
            Subject = 'Test Case 3',
            AccountId = acc3.Id 
        );
        insert testCase3;

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

        // Create Project 1
        inov8__PMT_Project__c testProject2 = new inov8__PMT_Project__c(
            Invoice_Account__c = acc2.Id,
            Name = 'Test Project 2',
            inov8__Level_of_Effort__c = 'Medium',
            inov8__Portfolio__c = 'P2P',
            inov8__Initial_Start_Date__c = Date.today(),
            inov8__Initial_End_Date__c = Date.today().addMonths(1)
        );
        insert testProject2;

        // Create Project 1
        inov8__PMT_Project__c testProject3 = new inov8__PMT_Project__c(
            Invoice_Account__c = acc3.Id,
            Name = 'Test Project 3',
            inov8__Level_of_Effort__c = 'Medium',
            inov8__Portfolio__c = 'P2P',
            inov8__Initial_Start_Date__c = Date.today(),
            inov8__Initial_End_Date__c = Date.today().addMonths(1)
        );
        insert testProject3;

        Test.startTest();
        List<ubc_TimeEntryController.ProjectOrCaseWrapper> result = ubc_TimeEntryController.getAllProjectsAndCases();
        Test.stopTest();

    }

    @isTest
    static void testGetAllProjectsAndCases_NoData() {
        // Test scenario with no data, no cases, and no projects.

        Test.startTest();
        List<ubc_TimeEntryController.ProjectOrCaseWrapper> result = ubc_TimeEntryController.getAllProjectsAndCases();
        Test.stopTest();

    }
}