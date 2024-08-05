public with sharing class ubc_TimeEntryController {

    @AuraEnabled (cacheable=true)
    public static List<ProjectOrCaseWrapper> getAllProjectsAndCases() {
        List<ProjectOrCaseWrapper> projectAndCases = new List<ProjectOrCaseWrapper>();

        // List Cases
        List<Case> cases = [SELECT Id, Subject, Account_Name__c FROM Case];
        for (Case c : cases) {
            projectAndCases.add(new ProjectOrCaseWrapper(c.Id, c.Subject,c.Account_Name__c, 'Case'));
        }

        // List Projects
        List<inov8__PMT_Project__c> projects = [SELECT Id, Name, Invoice_Account__r.Name FROM inov8__PMT_Project__c];
        for (inov8__PMT_Project__c p : projects) {
            projectAndCases.add(new ProjectOrCaseWrapper(p.Id, p.Name, p.Invoice_Account__r.Name, 'Project'));
        }

        return projectAndCases;
    }

    public class ProjectOrCaseWrapper {
        @AuraEnabled
        public Id recordId { get; set; }
        @AuraEnabled
        public String recordName { get; set; }
        @AuraEnabled
        public String recordAccount { get; set; }
        @AuraEnabled
        public String recordType { get; set; }
    

        public ProjectOrCaseWrapper(Id id, String name, String account, String type) {
            recordId = id;
            recordName = name;
            recordAccount = account;
            recordType = type;
        }
    }
}