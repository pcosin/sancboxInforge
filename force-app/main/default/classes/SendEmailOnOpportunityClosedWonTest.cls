@isTest
public class SendEmailOnOpportunityClosedWonTest {
    @isTest
    static void testSendEmailOnOpportunityClosedWon() {
        Account testAccount = new Account(Name='Test Account', Billing_Email_s__c='test@example.com');
        insert testAccount;

        Opportunity testOpportunity = new Opportunity(
            Name='Test Opportunity',
            StageName='Prospecting',
            CloseDate=Date.today().addMonths(1),
            AccountId=testAccount.Id
        );
        insert testOpportunity;

        testOpportunity.StageName = 'Closed Won';
        update testOpportunity;

    }
}
