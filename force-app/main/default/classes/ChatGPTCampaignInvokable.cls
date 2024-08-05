public with sharing class ChatGPTCampaignInvokable {
    @InvocableMethod(label='Generate ChatGPT Email Content')
    public static void generateChatGPTEmails(List<InputVariables> inputVariables) {
        ChatGPTCampaignBatch batch =  new ChatGPTCampaignBatch(inputVariables[0].recordId, inputVariables[0].prompt);
        if(!Test.isRunningTest()){
            Database.executeBatch(batch, 1);
        }else{
            Database.executeBatch(batch);

        }
    }

    public class InputVariables {
        @InvocableVariable
        public String recordId;

        @InvocableVariable
        public String prompt;
    }
}