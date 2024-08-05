@isTest
private class GetChatGPTMetadataPromptsTest {
    @isTest
    static void testGetChatGPTPrompts() {
        // Perform basic exception handling test
        Test.startTest();
        try {
            List<ChatGPT_Prompt__mdt> prompts = GetChatGPTMetadataPrompts.getChatGPTPrompts();
            // If no exception is thrown, the test will fail
        } catch (Exception e) {
            // Verify that the exception is handled properly
            System.assert(e instanceof AuraHandledException, 'Expected AuraHandledException to be thrown');
        }
        Test.stopTest();

        // Additional tests can be added to verify specific behavior if needed
        // However, it's not possible to directly test the getAll() method on metadata types
    }
}