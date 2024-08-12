trigger SendEmailOnAccountCreation on Account (after insert) {
    Id templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'NewAccountNotification' LIMIT 1].Id;
    System.debug('Email TemplateId found: ' + templateId);

    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

    for (Account acct : Trigger.new) {
        if (acct.OwnerId != null) {
            // Renderizar la plantilla con los datos de la cuenta
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(templateId, acct.OwnerId, acct.Id);
            mail.setTargetObjectId(acct.OwnerId);
            mail.setSaveAsActivity(false);
            emails.add(mail);
            System.debug('Preparing to send email for Account Id: ' + acct.Id);
        } else {
            System.debug('OwnerId is null for Account Id: ' + acct.Id);
        }
    }

    if (!emails.isEmpty()) {
        try {
            Messaging.sendEmail(emails);
            System.debug('Emails sent successfully.');
        } catch (Exception e) {
            System.debug('Failed to send email: ' + e.getMessage());
        }
    } else {
        System.debug('No emails to send.');
    }
}