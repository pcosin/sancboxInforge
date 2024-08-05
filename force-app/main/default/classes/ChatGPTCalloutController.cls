public with sharing class ChatGPTCalloutController{


    @AuraEnabled(cacheable=true)
    public static String sendChatGPTCallout(String leadId,String template){
        String endpoint = 'https://api.openai.com/v1/completions';
        Open_IA__c customSetting = Open_IA__c.getInstance();
        String authorization = 'Bearer ' + customSetting.Chat_GPT_Token__c;
        System.debug('authorization: ' + authorization);

        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('model', 'text-davinci-003');
        

        String templateResult = replacePlaceholders(template, leadId);
        requestBody.put('prompt', templateResult);
        requestBody.put('max_tokens', 280);
        String requestBodyJson = JSON.serialize(requestBody);


        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setEndpoint(endpoint);
        httpRequest.setMethod('POST');
        httpRequest.setHeader('Content-Type', 'application/json');
        httpRequest.setHeader('Authorization', authorization);
        httpRequest.setTimeout(120000);
        httpRequest.setBody(requestBodyJson);


        HttpResponse httpResponse = new Http().send(httpRequest);
        if (httpResponse.getStatusCode() == 200) {
            String responseJson = httpResponse.getBody();
            Map<String, Object> jsonObject = (Map<String, Object>) JSON.deserializeUntyped(responseJson);
            List<Object> choices = (List<Object>) jsonObject.get('choices');
            Map<String, Object> choice = (Map<String, Object>) choices[0];
            String response = (String) choice.get('text');
            System.debug('response: ' + response);
            return response;


        } else {
            System.debug('Error en la solicitud: ' + httpResponse.getStatusCode() + ' ' + httpResponse.getStatus());
            return 'Error';
        }
    }


    public static String replacePlaceholders(String template, String objectId) {


        String objectName = getObjectName(objectId);
        List<String> fields = getFields(objectName);
        String query = 'SELECT ' + string.join(fields, ',') + ' FROM ' +objectName + ' WHERE Id = '+ '\'' + objectId + '\'';
        List<Object> listaObjetos = (List<Object>) Database.query(query);
        

        Map<String, Object> fieldValues = new Map<String, Object>();
        for (Object obj : listaObjetos) {
            Map<String, Object> objetoMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));
            
            for (String field : objetoMap.keySet()) {
                Object fieldValue = objetoMap.get(field);
                if(fieldValue != null){
                    fieldValues.put('{!' + String.valueOf(field) + '}', fieldValue);
                }

            }
        }
        
        List<String> templateArr = new List<String>();
        // Replace placeholders in the template
        System.debug('template ' + template);
        for (String placeholder : fieldValues.keySet()) {
            Object value = fieldValues.get(placeholder);
            // System.debug('value: ' + value + ' ' + 'placeholder: ' + placeholder);
            template = template.replace(placeholder, String.valueOf(value));
        }
        
        String regEx = '\\{![^}]+\\}';
        template = template.replaceAll(regEx, '');
        System.debug('template:' + template);

        return template;
    }

    public static String getObjectName(String objectId){
        String name = '';
        String nombreObjeto;
    
        String objetoPrefix = objectId.substring(0, 3);
        
        switch on objetoPrefix {
            when '001' {
                name = 'Account';
            }
            when '003' {
                name = 'Contact';
            }
            when '006' {
                name = 'Opportunity';
            }
            when '00Q'{
                name = 'Lead';
            }
            when else {
                name = 'Desconocido';
            }
        }
        return name;
    }

    public static List<string> getFields(String selectedObject){
        List<String> reqFields = new List<String>();
        Map <String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = gd.get(selectedObject);
        Schema.DescribeSObjectResult r = sobjType.getDescribe();
        Map<String, Schema.SObjectField> MapofField = r.fields.getMap();
        
        for(String fieldName : MapofField.keySet()) {
            Schema.SObjectField field = MapofField.get(fieldName);
            Schema.DescribeFieldResult F = field.getDescribe();
	        reqFields.add(fieldName);
        }
        System.debug(reqFields);
        return reqFields;
    }
    
    
	@AuraEnabled(cacheable=true) 
    public static List<ChatGPT_Prompt__mdt> getChatGPTPrompts(){
        List<ChatGPT_Prompt__mdt> chatGPTPrompts = [SELECT Id, MasterLabel, Prompt__c, Object__c FROM ChatGPT_Prompt__mdt];
		return chatGPTPrompts;  
    }
    
    
    @AuraEnabled(cacheable=true)
    public static void sendEmail(String body, String toSend, String subject){
        try{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {toSend};
            mail.setToAddresses(toAddresses);
            mail.setSubject(subject);
            mail.setHtmlBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    
    // @AuraEnabled(cacheable=true) 
    // public static List<EmailTemplate> getEmailTemplates(){
    //     List<EmailTemplate> emailTemplates = [SELECT Id, Name, Subject, HtmlValue, Body FROM EmailTemplate WHERE Folder.Name = 'Campaign Email Templates'];
    //     System.debug(emailTemplates);
    //     return emailTemplates;  
    // }
    
    // @AuraEnabled
    // public static List<String> prepareEmailToPreview(Id leadId, Id templateId, String resText) {
    //     List<String> subBod = new List<String>();
    //     Lead lead = [SELECT Id, FirstName, LastName, Email, chatGPTReponse__c FROM Lead WHERE Id = :leadId];
               
    //     lead.chatGPTReponse__c = resText;
    //     update lead;
        
    //     Messaging.SingleEmailMessage emailPrevVals = Messaging.renderStoredEmailTemplate(templateId, leadId, leadId);
        
    //     subBod.add(emailPrevVals.getSubject());
    //     subBod.add(emailPrevVals.getPlainTextBody());
    //     System.debug(emailPrevVals.getPlainTextBody());
    //     System.debug(subBod);
    //     return subBod;
    // }
    
    // @AuraEnabled
    // public static void SendEmailWithTemplate(Id leadId, Id templateId, String resText) {
    //     Lead lead = [SELECT Id, FirstName, LastName, Email, chatGPTReponse__c FROM Lead WHERE Id = :leadId];
    //     lead.chatGPTReponse__c = resText;
    //     update lead;
        
    //             System.debug(lead);

        
    //     List<String> adds = new List<String>();
    //     adds.add(lead.Email);
        
    //     Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    //     email.setTemplateId(templateId);
    //     email.setToAddresses(adds);
    //     email.setTargetObjectId(leadId); // Set the recipient to the Lead's ID
    //     // email.setWhatId(leadId); // Set the related record ID
	// 	email.setSaveAsActivity(false); // Set saveAsActivity flag to false
    //   	System.debug('this is email: ' + email);
    //     System.debug('this is new Messagin... ' + (new Messaging.SingleEmailMessage[]{email})[0].getSubject());        
	// 	Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
    //     System.debug('this is new Messagin... ' + (new Messaging.SingleEmailMessage[]{email})[0].getSubject());
    // }

}