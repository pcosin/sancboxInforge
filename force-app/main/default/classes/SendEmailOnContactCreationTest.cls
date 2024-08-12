@isTest
public class SendEmailOnContactCreationTest {
    @isTest
    static void testSendEmailOnContactCreation() {
        // Crear un usuario de prueba
        User testUser = [SELECT Id, Email FROM User WHERE Username = 'testuser@example.com' LIMIT 1];

        // Crear un contacto de prueba
        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', OwnerId = testUser.Id);
        
        Test.startTest();
        insert con;
        Test.stopTest();

        // Verificar que se haya enviado un correo electrónico creando un EmailMessage
        List<EmailMessage> sentEmails = [SELECT Id, ToAddress, Subject, HtmlBody FROM EmailMessage WHERE Subject = 'A new contact was created'];
        System.assertEquals(1, sentEmails.size(), 'One email should have been sent.');
        System.assertEquals(testUser.Email, sentEmails[0].ToAddress, 'The email should have been sent to the contact owner.');
        System.assertEquals('A new contact was created', sentEmails[0].Subject, 'Email subject should match.');
    }
}