global class ChatGPTCampaignBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    Id campaignId = null;
    String unformattedPrompt = null;

    public ChatGPTCampaignBatch(Id campaignId, String unformattedPrompt) {
        this.campaignId = campaignId;
        this.unformattedPrompt = unformattedPrompt;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> fields = getFields();
        String query = 'SELECT ' + string.join(fields, ',') + ' FROM CampaignMember WHERE campaignId = '+ '\'' + this.campaignId + '\'';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<CampaignMember> members){
        String endpoint = 'https://api.openai.com/v1/completions';
        Open_IA__c customSetting = Open_IA__c.getInstance();
        String authorization = 'Bearer ' + customSetting.Chat_GPT_Token__c;
        System.debug('authorization: ' + authorization);

        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('model', 'text-davinci-003');
        requestBody.put('max_tokens', 280);
        requestBody.put('temperature', 0.5);
        requestBody.put('top_p', 1);
        requestBody.put('n', 1);
        requestBody.put('echo', false);
        requestBody.put('presence_penalty', 0);
        requestBody.put('frequency_penalty', 0);
        requestBody.put('best_of', 1);




        for (CampaignMember member : members) {

            String templateResult = replacePlaceholders(this.unformattedPrompt, member);
            requestBody.put('prompt', templateResult);
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
                String subject = getSubstringBetweenReferences(response, 'Email Subject: ', 'Email Body: ');
                System.debug('subject: ' + subject);
                String body = getSubstringBetweenReferences(response, 'Email Body: ', null);
                System.debug('body: ' + body);
                if (subject != '' && body != '') {
                    member.Body_OpenAI__c = body;
                    member.Subject_OpenAI__c = subject;
                } else {
                    System.debug('Error. Could not parse the email subject and body.');
                }

            } else {
                System.debug('Response Error: ' + httpResponse.getStatusCode() + ' ' + httpResponse.getStatus());
            }

        }
        update members;
    }

    global void finish(Database.BatchableContext bc){

    }

    private String replacePlaceholders(String template, CampaignMember campaignMember) {
        Map<String, Object> fieldValues = new Map<String, Object>();
        Map<String, Object> objectMap = campaignMember.getPopulatedFieldsAsMap();
        for (String field : objectMap.keySet()) {
            Object fieldValue = objectMap.get(field);
            if(fieldValue != null){
                fieldValues.put('{!' + String.valueOf(field) + '}', fieldValue);
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

    private List<string> getFields(){
        List<String> reqFields = new List<String>();
        Map <String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = gd.get('CampaignMember');
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

    private String getSubstringBetweenReferences(String main_string, String reference, String stopReference) {
        Integer referenceIndex = main_string.indexOf(reference);
        Integer stopReferenceIndex = (stopReference == null || stopReference == '' ? -1 : main_string.indexOf(stopReference));

        if (referenceIndex != -1 && stopReferenceIndex != -1) {
            // If both the reference and stopReference are found in the main_string
            return main_string.substring(referenceIndex + reference.length(), stopReferenceIndex);
        } else if (referenceIndex != -1) {
            // If only the reference is found, return the substring from the reference onwards
            return main_string.substring(referenceIndex + reference.length());
        } else {
            // If the reference is not found in the main_string, return an empty string or handle the error accordingly.
            // In this case, we'll return an empty string.
            return '';
        }
    }

}