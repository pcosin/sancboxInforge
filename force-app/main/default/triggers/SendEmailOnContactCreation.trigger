trigger SendEmailOnContactCreation on Contact (after insert) {
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

    Id templateId;
    try {
        templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'NewContactNotification' LIMIT 1].Id;
        System.debug('Email TemplateId found: ' + templateId);
    } catch (Exception e) {
        System.debug('Email Template not found: ' + e.getMessage());
        return;
    }

    for (Contact con : Trigger.new) {
        try {
            if (con.OwnerId != null) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateId(templateId);
                mail.setTargetObjectId(con.OwnerId);
                mail.setWhatId(con.Id);
                mail.setSaveAsActivity(true);

                // Agregar depuración para verificar la configuración del correo
                System.debug('Preparing to send email to: ' + [SELECT Email FROM User WHERE Id = :con.OwnerId].Email);

                emails.add(mail);
            } else {
                System.debug('OwnerId is null for Contact Id: ' + con.Id);
            }
        } catch (Exception e) {
            System.debug('Failed to create email message: ' + e.getMessage());
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
