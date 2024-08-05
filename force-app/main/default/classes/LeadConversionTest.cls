@isTest
public class LeadConversionTest {

    @isTest
    static void testLeadConversionSuccess() {
        // Crear una cuenta de prueba
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;

        // Crear un lead de prueba
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            Email = 'testlead@example.com',
            Status = 'Open - Not Contacted'
        );
        insert testLead;

        // Configurar la solicitud de conversión
        LeadConversion.LeadConversionRequest request = new LeadConversion.LeadConversionRequest();
        request.leadId = testLead.Id;
        request.accountId = testAccount.Id;
        request.convertedStatus = 'Qualified';

        // Llamar al método invocable
        List<LeadConversion.LeadConversionRequest> requests = new List<LeadConversion.LeadConversionRequest> { request };
        List<LeadConversion.LeadConversionResult> results = LeadConversion.convertLead(requests);

        // Verificar los resultados
        System.assertEquals(1, results.size());
        System.assertEquals(true, results[0].success);
        System.assertEquals('Lead convertido exitosamente', results[0].message);
        System.assertNotEquals(null, results[0].convertedLeadId);
        System.assertNotEquals(null, results[0].createdContactId);

        // Verificar que el lead fue convertido
        Lead convertedLead = [SELECT Id, IsConverted, ConvertedAccountId, ConvertedContactId FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(true, convertedLead.IsConverted);
        System.assertEquals(testAccount.Id, convertedLead.ConvertedAccountId);
        System.assertNotEquals(null, convertedLead.ConvertedContactId);
    }

    @isTest
    static void testLeadConversionException() {
        // Configurar la solicitud de conversión con datos faltantes
        LeadConversion.LeadConversionRequest request = new LeadConversion.LeadConversionRequest();
        request.leadId = null; // Lead ID faltante
        request.accountId = '001000000000000AAA'; // ID de cuenta no válido
        request.convertedStatus = 'Qualified';

        // Llamar al método invocable
        List<LeadConversion.LeadConversionRequest> requests = new List<LeadConversion.LeadConversionRequest> { request };
        List<LeadConversion.LeadConversionResult> results = LeadConversion.convertLead(requests);

        // Verificar los resultados
        System.assertEquals(1, results.size());
        System.assertEquals(false, results[0].success);
        System.assert(results[0].message.contains('Excepción'));
        System.assertEquals(null, results[0].convertedLeadId);
        System.assertEquals(null, results[0].createdContactId);
    }
}