@isTest
public class PreventAccountDeletionTest {
    @isTest
    static void testPreventAccountDeletion() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', StageName = 'Closed Won', CloseDate = Date.today(), AccountId = acc.Id);
        insert opp;

        Test.startTest();
        try {
            delete acc;
            System.assert(false, 'Account with "Closed Won" opportunities should not be deleted.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Cannot delete account with "Closed Won" opportunities.'), 'Unexpected error message: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testAllowAccountDeletion() {
        // Create test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today(), AccountId = acc.Id);
        insert opp;

        Test.startTest();
        delete acc;
        Test.stopTest();

        Account deletedAcc = [SELECT Id FROM Account WHERE Id = :acc.Id LIMIT 1];
        System.assertEquals(null, deletedAcc, 'Account should be deleted.');
    }
}