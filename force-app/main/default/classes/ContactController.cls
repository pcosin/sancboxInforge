public with sharing class ContactController {
    @AuraEnabled
    public static void createContact(Map<String, Object> contactData) {
        try {
            Contact newContact = new Contact();
            newContact.FirstName = (String)contactData.get('FirstName');
            newContact.LastName = (String)contactData.get('LastName');
            newContact.Phone = (String)contactData.get('Phone');
            newContact.Email = (String)contactData.get('Email');
            
            String accountName = (String)contactData.get('AccountName');
            if (String.isNotBlank(accountName)) {
                Account acc = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
                if (acc != null) {
                    newContact.AccountId = acc.Id;
                }
            }
            
            insert newContact;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}