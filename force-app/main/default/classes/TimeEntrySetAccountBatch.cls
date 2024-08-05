global class TimeEntrySetAccountBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Case__c, Case__r.AccountId, Task__c, Task__r.PMT_Project__c, Project__c, Project__r.Invoice_Account__c, Task_Account__c FROM Time_Entry__c WHERE Account__c = NULL';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<	Time_Entry__c > TimeEntries){
        for (Time_Entry__c TimeEntry : TimeEntries) {
            if (TimeEntry.Case__c != NULL && TimeEntry.Case__r.AccountId != NULL) {
                TimeEntry.Account__c = TimeEntry.Case__r.AccountId;
            } else if (TimeEntry.Project__c != NULL && TimeEntry.Project__r.Invoice_Account__c != NULL) {
                TimeEntry.Account__c = TimeEntry.Project__r.Invoice_Account__c;
            } else if (TimeEntry.Task__c != NULL) {
                if (TimeEntry.Project__c == NULL) {
                    TimeEntry.Project__c = TimeEntry.Task__r.PMT_Project__c;
                }
                TimeEntry.Account__c = TimeEntry.Task_Account__c;
            }
        }
        update TimeEntries;
    }

    global void finish(Database.BatchableContext bc){

    }

}