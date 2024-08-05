public class SendEmailPendingEvaluation {
	public void sendEmailsBasedOnPermissionSet() {
        // Get the Permission Set Id
        PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = 'LM_Manager'];
        
        if (permSet == null) {
            return; // If the Permission Set does not exist, do nothing
        }
        
        // Consult the users assigned to that Permission Set
        Map<Id, User> usersWithPermissionSet = new Map<Id, User>(
            [SELECT Id, Email FROM User WHERE Id IN (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId = :permSet.Id)]
        );
        
        if (usersWithPermissionSet.isEmpty()) {
            return; // If there are no users with the Permission Set, do nothing
        }
        
        // Check Evaluations logs with Status 'Pending'
        List<Evaluation__c> evaluations = [SELECT Id, Name FROM Evaluation__c WHERE Status__c = 'Pending'];
        
        // Verificar si hay registros de evaluations
        if (evaluations.isEmpty()) {
            return; // No registrations, no emails
        }
        
        // Get the organization's base URL
        String baseUrl = URL.getOrgDomainUrl().toExternalForm();
        
        // Build the body of the email in HTML format
        String emailBody = '<html><body>';
        emailBody += '<h1>Evaluations Pending</h1>';
        emailBody += '<table border="1">';
        emailBody += '<tr><th>Name</th><th>Link</th></tr>';
        
        for (Evaluation__c eval : evaluations) {
            emailBody += '<tr>';
            emailBody += '<td>' + eval.Name + '</td>';
            emailBody += '<td><a href="' + baseUrl + '/lightning/r/Evaluation__c/' + eval.Id + '/view">' + eval.Name + '</a></td>';
            emailBody += '</tr>';
        }
        
        emailBody += '</table>';
        emailBody += '</body></html>';
        
        // Create a list to store email messages
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        // Create an email message for each user
        for (User user : usersWithPermissionSet.values()) {
            if (user.Email != null) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] { user.Email });
                email.setSubject('Evaluations Pending');
                email.setHtmlBody(emailBody);
                emails.add(email);
            }
        }
        
        // Send the emails
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}