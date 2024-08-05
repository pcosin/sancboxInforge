@isTest
public class SendEmailPendingEvaluationTest {

    @testSetup
    static void setup() {
        // Find or create the Permission Set
        PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = 'LM_Manager' LIMIT 1];
        if (permSet == null) {
            permSet = new PermissionSet(Name = 'LM_Manager');
            insert permSet;
        }
        
        // Assign the current user to the Permission Set
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        System.runAs(currentUser) {
            PermissionSetAssignment permAssign = new PermissionSetAssignment(
                AssigneeId = currentUser.Id,
                PermissionSetId = permSet.Id
            );
            insert permAssign;
        }
        
        // Create Evaluations with status 'New' to bypass validation rule
        List<Evaluation__c> evals = new List<Evaluation__c>{
            new Evaluation__c(Name = 'Evaluation 1', Status__c = 'New'),
            new Evaluation__c(Name = 'Evaluation 2', Status__c = 'New')
        };
        insert evals;

        // Update the evaluations to 'Pending' status
        for (Evaluation__c eval : evals) {
            eval.Status__c = 'Pending';
        }
        update evals;
    }

    @isTest
    static void testSendEmailsBasedOnPermissionSet() {
        Test.startTest();
        
        // Get the initial email sent count
        Integer initialEmailCount = Limits.getEmailInvocations();
        
        // Create an instance of the class and call the method
        SendEmailPendingEvaluation emailSender = new SendEmailPendingEvaluation();
        emailSender.sendEmailsBasedOnPermissionSet();
        
        // Verify that emails were sent
        Integer finalEmailCount = Limits.getEmailInvocations();
        System.assertEquals(initialEmailCount + 1, finalEmailCount, 'Emails should have been sent');
        
        Test.stopTest();
    }
    
    @isTest
    static void testScheduledSendEmailPendingEvaluation() {
        Test.startTest();
        
        // Get the initial email sent count
        Integer initialEmailCount = Limits.getEmailInvocations();

        // Schedule the job
        String jobId = System.schedule('Test Scheduled Send Email', '0 0 12 * * ?', new ScheduledSendEmailPendingEvaluation());
        
        Test.stopTest();
    }
    
    @isTest
    static void testNoEvaluations() {
        // Remove all evaluations
        delete [SELECT Id FROM Evaluation__c];
        
        Test.startTest();
        
        // Get the initial email sent count
        Integer initialEmailCount = Limits.getEmailInvocations();
        
        // Create an instance of the class and call the method
        SendEmailPendingEvaluation emailSender = new SendEmailPendingEvaluation();
        emailSender.sendEmailsBasedOnPermissionSet();
        
        // Verify that no emails were sent
        Integer finalEmailCount = Limits.getEmailInvocations();
        System.assertEquals(initialEmailCount, finalEmailCount, 'No emails should have been sent');
        
        Test.stopTest();
    }
    
    @isTest
    static void testNoUsersWithPermissionSet() {
        // Remove all users with the permission set
        delete [SELECT Id FROM PermissionSetAssignment WHERE PermissionSet.Name = 'LM_Manager'];
        
        Test.startTest();
        
        // Get the initial email sent count
        Integer initialEmailCount = Limits.getEmailInvocations();
        
        // Create an instance of the class and call the method
        SendEmailPendingEvaluation emailSender = new SendEmailPendingEvaluation();
        emailSender.sendEmailsBasedOnPermissionSet();
        
        // Verify that no emails were sent
        Integer finalEmailCount = Limits.getEmailInvocations();
        System.assertEquals(initialEmailCount, finalEmailCount, 'No emails should have been sent');
        
        Test.stopTest();
    }
}