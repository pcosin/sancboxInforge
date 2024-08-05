public with sharing class GetChatGPTMetadataPrompts {
    @AuraEnabled(cacheable=true)
    public static List<ChatGPT_Prompt__mdt> getChatGPTPrompts(){
		return ChatGPT_Prompt__mdt.getAll().values();  
    }
}