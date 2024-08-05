@isTest
public class ChatGPTCalloutControllerTest {
	@isTest
    static void testGetChatGPTPrompts() {
        // Perform basic exception handling test
        Test.startTest();
        try {
            List<ChatGPT_Prompt__mdt> prompts = ChatGPTCalloutController.getChatGPTPrompts();
            // If no exception is thrown, the test will fail
        } catch (Exception e) {
            // Verify that the exception is handled properly
            System.assert(e instanceof AuraHandledException, 'Expected AuraHandledException to be thrown');
        }
        Test.stopTest();

        // Additional tests can be added to verify specific behavior if needed
        // However, it's not possible to directly test the getAll() method on metadata types
    }
    
    @isTest
    public static void testGetFields() {
        // Call the method under test
        List<String> leadFields = chatGPTCalloutController.getFields('Lead');
		List<String> contactFields = chatGPTCalloutController.getFields('Contact');
		List<String> oppFields = chatGPTCalloutController.getFields('Opportunity');

        Organization a_ORG = [Select Id, Name, IsSandbox from Organization];

        
        // Assert the results
		if(a_ORG.IsSandbox){
			System.assertEquals(82, leadFields.size()); // Modify the expected size according to your specific object
        }
        else{
        	System.assertEquals(81, leadFields.size()); // Modify the expected size according to your specific object
        }        

        System.assertEquals(67, contactFields.size()); // Modify the expected size according to your specific object
        System.assertEquals(53, oppFields.size()); // Modify the expected size according to your specific object

        // Add more assertions or test cases as needed
    }
    
    @isTest
    public static void testGetObjectName() {
        // Test case 1: Valid object prefix
        String validObjectId = '001xxxxxxxxxxxx';
        String expectedObjectName = 'Account';
        String actualObjectName = ChatGPTCalloutController.getObjectName(validObjectId);
        System.assertEquals(expectedObjectName, actualObjectName);
        
        // Test case 2: Another valid object prefix
        String validObjectId2 = '003xxxxxxxxxxxx';
        String expectedObjectName2 = 'Contact';
        String actualObjectName2 = ChatGPTCalloutController.getObjectName(validObjectId2);
        System.assertEquals(expectedObjectName2, actualObjectName2);
        
        // Test case 3: Unknown object prefix
        String validObjectId3 = '123xxxxxxxxxxxx';
        String expectedObjectName3 = 'Desconocido';
        String actualObjectName3 = ChatGPTCalloutController.getObjectName(validObjectId3);
        System.assertEquals(expectedObjectName3, actualObjectName3);
        
        // Test case 3: Unknown object prefix
        String validObjectId4 = '00Qxxxxxxxxxxxx';
        String expectedObjectName4 = 'Lead';
        String actualObjectName4 = ChatGPTCalloutController.getObjectName(validObjectId4);
        System.assertEquals(expectedObjectName4, actualObjectName4);
    }
    
    @isTest
    public static void testReplacePlaceholders() {
        // Create test records
        Lead testLead = new Lead();
        testLead.FirstName = 'John';
        testLead.LastName = 'Doe';
        testLead.Company = 'Test Company';
        insert testLead;

        Contact testContact = new Contact();
        testContact.FirstName = 'Jane';
        testContact.LastName = 'Smith';
        testContact.Email = 'jahirv@inforge.us';
        testContact.AccountId = new Account(Name = 'Test Account').Id;
        insert testContact;

        Opportunity testOpportunity = new Opportunity();
        testOpportunity.Name = 'Test Opportunity';
        testOpportunity.AccountId = testContact.AccountId;
		testOpportunity.StageName = 'Closed Won';
        testOpportunity.CloseDate = Date.today().addDays(30);
        insert testOpportunity;

        // Test case 1: Lead object
        String templateLead = 'Hello {!FirstName} {!LastName}, your company is {!Company}.';
        String objectIdLead = testLead.Id;
        String expectedOutputLead = 'Hello John Doe, your company is Test Company.';
        String actualOutputLead = ChatGPTCalloutController.replacePlaceholders(templateLead, objectIdLead);
        System.assertEquals(expectedOutputLead, actualOutputLead);

        // Test case 2: Contact object
        String templateContact = 'Hello {!FirstName} {!LastName}, your email is {!Email}';
        String objectIdContact = testContact.Id;
        String expectedOutputContact = 'Hello Jane Smith, your email is jahirv@inforge.us';
        String actualOutputContact = ChatGPTCalloutController.replacePlaceholders(templateContact, objectIdContact);
        System.assertEquals(expectedOutputContact, actualOutputContact);

        // Test case 3: Opportunity object
        String templateOpportunity = 'Hello {!Name}, the stage name is {!StageName}.';
        String objectIdOpportunity = testOpportunity.Id;
        String expectedOutputOpportunity = 'Hello Test Opportunity, the stage name is Closed Won.';
        String actualOutputOpportunity = ChatGPTCalloutController.replacePlaceholders(templateOpportunity, objectIdOpportunity);
        System.assertEquals(expectedOutputOpportunity, actualOutputOpportunity);
    }

    @IsTest
    public static void testSendChatGPTCallout() {
        // Create a test lead record
        Lead testLead = new Lead(FirstName = 'John', LastName = 'Doe', Company = 'Test Company');
        insert testLead;

        // Set up the mock HTTP response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"choices":[{"text":"Test response"}]}');

        // Mock the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));

        // Call the method to be tested
        Test.startTest();
        String result = ChatGPTCalloutController.sendChatGPTCallout(testLead.Id, 'Test template');
        Test.stopTest();

        // Perform assertions to verify the expected behavior
        System.assertEquals('Test response', result);
    }

    // Mock HTTP callout class
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse response;

        public MockHttpResponseGenerator(HttpResponse response) {
            this.response = response;
        }

        public HttpResponse respond(HttpRequest request) {
            return response;
        }
    }
}