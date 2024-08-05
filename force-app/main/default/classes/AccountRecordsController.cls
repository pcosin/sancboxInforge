public with sharing class AccountRecordsController {
    @AuraEnabled
    public static List<Account> getHours(String UserId) {
    List<User> lstUsr = new List<User>([SELECT ContactId FROM USER WHERE Id =:userID ]);
    List<Contact> lstAcc = new List<Contact>([SELECT AccountId FROM Contact WHERE Id=:lstUsr[0].ContactId]);
    List<Account> results = [SELECT Agreed_Monthly_Hours__c, Hours_Worked_This_Month__c FROM Account WHERE Id = :lstAcc[0].AccountId];        
    
    return results;
      
    }
}