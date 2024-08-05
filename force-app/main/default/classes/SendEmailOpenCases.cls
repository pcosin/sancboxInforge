public with sharing class SendEmailOpenCases {
    public static void sendCaseReports() {
        // Load the day limit from the custom setting
        OpenCases_Settings__c settings = OpenCases_Settings__c.getInstance(UserInfo.getUserId());
        Integer daysLimit = (settings != null && settings.Days_Limit__c != null) ? settings.Days_Limit__c.intValue() : 7;
        
        System.debug('daysLimit ' + daysLimit);

        // Get the current date minus the number of days in the limit
        Date dateLimit = Date.today().addDays(-daysLimit);

        Map<Id, List<Case>> casesByUser = fetchCasesByUser(dateLimit);

        Set<Id> userIds = casesByUser.keySet();
        System.debug('User IDs with Cases ' + userIds);

        Map<Id, User> usersByEmail = new Map<Id, User>([SELECT Id, Email FROM User WHERE Id IN :userIds]);

        String emailBody = '';
        Map<String, String> emailsToSend = new Map<String, String>();

        // Prepare the body of the email for each user
        for (Id ownerId : userIds) {
            List<Case> userCases = casesByUser.get(ownerId);
            if (userCases.isEmpty()) continue; // Skip if there are no cases
        
            User user = usersByEmail.get(ownerId);
            if (user != null && String.isNotBlank(user.Email)) {                
                emailBody = buildEmailBody(userCases);
                emailsToSend.put(user.Email, emailBody);
            }
        }

        if (!emailsToSend.isEmpty()) {
            for (String email : emailsToSend.keySet()) {
                String body = emailsToSend.get(email);
                System.debug('Email to: ' + email); // Show email address
                System.debug('Email body: ' + body); // Show the body of the email
                sendEmail(email, 'Summary of Open Cases', body); // Send the email
            }
        }
    }

    private static Map<Id, List<Case>> fetchCasesByUser(Date dateLimit) {
        List<Case> cases = [
            SELECT Id, Subject, QA_Name__c, QA__c, Owner.Name, Case_Status__c, Account_Name__c, CreatedDate
            FROM Case
            WHERE (Case_Status__c != 'Closed' AND Case_Status__c != 'Merged' AND Case_Status__c != 'To Delete' AND Case_Status__c != 'From Nuage')
            AND CreatedDate <= :dateLimit
        ];
        
        Map<Id, List<Case>> casesByPM = new Map<Id, List<Case>>();
        for (Case c : cases) {
            if (!casesByPM.containsKey(c.QA__c)) {
                casesByPM.put(c.QA__c, new List<Case>());
            }
            casesByPM.get(c.QA__c).add(c);
        }

        return casesByPM;
    }

    private static String buildEmailBody(List<Case> userCases) {
        String baseUrl = URL.getOrgDomainURL().toExternalForm();

        String body = '<h2>Summary of the cases not yet closed</h2>';
        body += '<p>Hello, I send you a summary of your cases that are not closed. Please, check if they do not have action items or if the client is not responsive. I appreciate your attention.</p>';
        body += '<table border="1">';
        body += '<tr><th>Case Subject</th><th>PM</th><th>Case Owner</th><th>Case Status</th><th>Time Open</th><th>Account Name</th></tr>';

        for (Case c : userCases) {
            Date caseDate = c.CreatedDate.date();
            Integer daysOpen = caseDate.daysBetween(Date.today());
            body += '<tr>';
            body += '<td><a href="' + baseUrl + '/lightning/r/Case/' + c.Id + '/view">' + c.Subject + '</a></td>';
            body += '<td>' + (c.QA_Name__c != null ? c.QA_Name__c : 'N/A') + '</td>';
            body += '<td>' + c.Owner.Name + '</td>';
            body += '<td>' + c.Case_Status__c + '</td>';
            body += '<td>' + daysOpen + ' days</td>';
            body += '<td>' + (c.Account_Name__c != null ? c.Account_Name__c : 'N/A') + '</td>';
            body += '</tr>';
        }
        body += '</table>';

        return body;
    }

    private static void sendEmail(String toAddress, String subject, String htmlBody) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { toAddress });
        mail.setSubject(subject);
        mail.setHtmlBody(htmlBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}