@isTest
public class ResourceAllocationTest {
    
    static testMethod void testSetUserAllocatedHours() {
        // Create test data for Users
        List<User> testUsers = new List<User>{
            new User(LastName = 'Testuser1',Username='testuser1@test.com.inforge', Email='testuser1@test.com', IsActive = true,
            Alias = 'tuser2',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id),
            new User(LastName = 'Testuser2',Username='testuser2@test.com.inforge', Email='testuser2@test.com',
            IsActive = true,
            Alias = 'tuser2',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id)
        };
        insert testUsers;

        Account newAccount = new Account();
        newAccount.Name = 'test';
        insert newAccount;

        Account inforgeAcc = new Account();
        inforgeAcc.Name = 'Inforge';
        insert inforgeAcc;

        inov8__PMT_Project__c project = new inov8__PMT_Project__c(
            Name = 'Test Project',
            Invoice_Account__c = inforgeAcc.Id,
            inov8__Level_of_Effort__c = 'Small'
        );
        insert project;

        inov8__PMT_Phase__c phase = new inov8__PMT_Phase__c(
            Name = 'Test Phase',
            inov8__Project__c = project.Id
        );
        insert phase;

        inov8__PMT_Task__c salesTask = new inov8__PMT_Task__c(
            Name = 'Sales Task',
            PMT_Project__c = project.Id,
            inov8__Phase__c = phase.Id,
            inov8__Assigned_To1__c= testUsers[0].Id
        );
        insert salesTask;

        // Create test data for Time Entries for Clients
        Time_Entry__c clientTime1 = new Time_Entry__c(
            User__c = testUsers[0].Id,
            Account__c = newAccount.Id,
            Start_Timestamp__c = System.now().addHours(-1),
            End_Timestamp__c = System.now()
        );
        Time_Entry__c clientTime2 = new Time_Entry__c(
            User__c = testUsers[1].Id,
            Account__c = newAccount.Id,
            Start_Timestamp__c = System.now().addHours(-1),
            End_Timestamp__c = System.now()
        );

        // Create test data for Time Entries for Sales
        Time_Entry__c salesTime1 = new Time_Entry__c(
            User__c = testUsers[0].Id,
            Account__c = inforgeAcc.Id,
            Task__c = salesTask.Id,
            Start_Timestamp__c = System.now().addHours(-1),
            End_Timestamp__c = System.now()
        );

        insert new List<Time_Entry__c>{clientTime1, clientTime2, salesTime1};

        Test.startTest();
        // Call the method to test
        ResourceAllocation.setUserAllocatedHours();
        Test.stopTest();

    }
}