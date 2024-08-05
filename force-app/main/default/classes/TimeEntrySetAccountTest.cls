@isTest
private class TimeEntrySetAccountTest {
    
    public static String CRON_EXP = '0 0 0 15 3 ? 2099';
    
    @TestSetup
    static void makeData(){
        Account a = new Account(Name='Test');
        insert a;
        
        Case c = new Case(Subject='Test', Origin='Email', AccountId=a.Id, QA__c=UserInfo.getUserId());
        insert c;
        
        // Create Project
        inov8__PMT_Project__c p = new inov8__PMT_Project__c(Invoice_Account__c=a.Id, Name='Test Project', inov8__Level_of_Effort__c='Medium', inov8__Portfolio__c='P2P', inov8__Initial_Start_Date__c=Date.today(), inov8__Initial_End_Date__c=Date.today().addMonths(1));
        insert p;

        // Create Phase
        inov8__PMT_Phase__c ph = new inov8__PMT_Phase__c(inov8__Project__c=p.Id, Name='Test Phase');
        insert ph;

        // Create Task
        inov8__PMT_Task__c t = new inov8__PMT_Task__c(PMT_Project__c=p.Id, Name='Test Task', Approved_Hours_Logged__c=10, inov8__Assigned_To1__c=UserInfo.getUserId(), QA__c=UserInfo.getUserId(), inov8__Phase__c=ph.Id, inov8__Start_Date__c=Date.today(), inov8__Due_Date__c=Date.today().addMonths(1));
        insert t;  
        
        Time_Entry__c ttd1 = new Time_Entry__c(Case__c=c.Id, Name='Test');
        insert ttd1;
        Time_Entry__c ttd2 = new Time_Entry__c(Project__c=p.Id, Task__c=t.Id, Name='Test');
        insert ttd2;
        Time_Entry__c ttd3 = new Time_Entry__c(Task__c=t.Id, Name='Test');
        insert ttd3;
        
    }
    
    
    @isTest private static void testSetAccounts() {
        
        List<Time_Entry__c> timeentries = [SELECT Id, Case__c, Case__r.AccountId, Task__c, Task__r.PMT_Project__c, Project__c, Project__r.Invoice_Account__c, Task_Account__c FROM Time_Entry__c WHERE Account__c = NULL];

        Test.startTest();

        (new TimeEntrySetAccountBatch()).execute(null, timeentries);

        String jobId = System.schedule('ScheduledApexTest',
        CRON_EXP,
        new TimeEntrySetAccountSchedulable());

        Test.stopTest();
        
    }

}