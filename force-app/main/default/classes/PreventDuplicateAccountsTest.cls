@isTest
public class PreventDuplicateAccountsTest {

    @isTest
    static void testInsertDuplicateAccount() {
        // Insert an account with a unique name
        Account acc1 = new Account(Name = 'Test Account');
        insert acc1;

        // Try to insert another account with the same name
        Account acc2 = new Account(Name = 'Test Account');
        Test.startTest();
        try {
            insert acc2;
            System.assert(false, 'Expected DMLException was not thrown');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Your Account already exists in system.'), 'Unexpected error message: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testInsertDuplicateAccountDifferentCase() {
        // Insert an account with a unique name
        Account acc1 = new Account(Name = 'Test Account');
        insert acc1;

        // Try to insert another account with the same name but different case
        Account acc2 = new Account(Name = 'test account');
        Test.startTest();
        try {
            insert acc2;
            System.assert(false, 'Expected DMLException was not thrown');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Your Account already exists in system.'), 'Unexpected error message: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testUpdateAccountToDuplicateName() {
        // Insert two accounts with unique names
        Account acc1 = new Account(Name = 'Account One');
        insert acc1;

        Account acc2 = new Account(Name = 'Account Two');
        insert acc2;

        // Try to update the second account to have the same name as the first account
        acc2.Name = 'Account One';
        Test.startTest();
        try {
            update acc2;
            System.assert(false, 'Expected DMLException was not thrown');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Your Account already exists in system.'), 'Unexpected error message: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testAllowUniqueAccountInsertion() {
        // Insert an account with a unique name
        Account acc1 = new Account(Name = 'Unique Account');
        Test.startTest();
        insert acc1;
        Test.stopTest();

        System.assertNotEquals(null, acc1.Id, 'Account was not inserted successfully.');
    }

    @isTest
    static void testAllowUniqueAccountUpdate() {
        // Insert an account with a unique name
        Account acc1 = new Account(Name = 'Initial Unique Account');
        insert acc1;

        // Update the account to another unique name
        acc1.Name = 'Updated Unique Account';
        Test.startTest();
        update acc1;
        Test.stopTest();

        System.assertEquals('Updated Unique Account', [SELECT Name FROM Account WHERE Id = :acc1.Id].Name);
    }
}