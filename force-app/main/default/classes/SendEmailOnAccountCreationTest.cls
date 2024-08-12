@isTest
public class SendEmailOnAccountCreationTest {
    
    @TestSetup
    static void setupTestData(){
        // Create a test email template
        EmailTemplate testTemplate = new EmailTemplate(
            Name = 'Test New Account Notification',
            DeveloperName = 'NewAccountNotification',
            TemplateType = 'text',
            FolderId = UserInfo.getUserId(),
            Subject = 'New Account Created',
            Body = 'A new account has been created.'
        );
        insert testTemplate;
    }
    
    @isTest
    static void testSendEmailOnAccountCreation() {
        // Set up test data
        User testUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        Test.startTest();
        
        // Create a new account
        Account testAccount = new Account(
            Name = 'Test Account',
            OwnerId = testUser.Id
        );
        insert testAccount;
        
        // Verify that an email was sent
        Integer invocations = Limits.getEmailInvocations();
        System.assertEquals(1, invocations, 'Expected one email to be sent');
        
        Test.stopTest();
        
        // Verify debug logs
        System.assertNotEquals(null, [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'NewAccountNotification' LIMIT 1], 'Email template not found');
        
        // Here you could add more assertions if you need to verify the email content
    }
    
    @isTest
    static void testNoEmailSentWhenOwnerIdIsNull() {
        Test.startTest();
        
        // Create a new account without an owner
        Account testAccount = new Account(
            Name = 'Test Account Without Owner'
        );
        insert testAccount;
        
        // Verify that no email was sent
        Integer invocations = Limits.getEmailInvocations();
        System.assertEquals(0, invocations, 'No email was expected to be sent');
        
        Test.stopTest();
    }
}