trigger SendEmailOnOpportunityClosedWon on Opportunity (after update) {
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

    for (Opportunity opp : Trigger.new) {
        Opportunity oldOpp = Trigger.oldMap.get(opp.Id);

        if (opp.StageName == 'Closed Won' && oldOpp.StageName != 'Closed Won') {
            Account acc = [SELECT Id, Billing_Email_s__c FROM Account WHERE Id = :opp.AccountId LIMIT 1];

            if (acc.Billing_Email_s__c != null) {
                // Configura el correo electrónico
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new List<String>{acc.Billing_Email_s__c});
                email.setSubject('Oportunidad Cerrada y Ganada');
                email.setPlainTextBody('La oportunidad con el ID ' + opp.Id + ' ha sido cerrada y ganada.');
                emails.add(email);
            }
        }
    }

    if (!emails.isEmpty()) {
        Messaging.sendEmail(emails);
    }
}