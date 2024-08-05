@isTest
private class DataInvoiceGenerationTest {

    @TestSetup
    static void makeData() {

        // Create account booknook
        Account booknook = new Account(Name='Doctors Now', Fixed_Monthly_Revenue__c=100);
        insert booknook;
        // Create account Nuage
        Account nuage = new Account(Name='The Nuage Group', Hourly_rate__c=2);
        insert nuage;
        // Create account Alliance
        Account alliance = new Account(Name='Alliance HCM', ParentId=nuage.Id);
        insert alliance;

        // Create Invoice attached to Nuage
        Invoice__c i = new Invoice__c(Name='Test', Invoice_Number__c='Test123', Billing_Account__c=nuage.Id);
        insert i;

        // Create case
        Case c = new Case(AccountId=alliance.Id, Origin='Email',Subject='Test');
        insert c;
        // Create Project
        inov8__PMT_Project__c p = new inov8__PMT_Project__c(Invoice_Account__c=booknook.Id, Name='Test Project', inov8__Level_of_Effort__c='Medium',inov8__Portfolio__c='P2P', inov8__Initial_Start_Date__c=Date.today(), inov8__Initial_End_Date__c=Date.today().addMonths(1));
        insert p;
        // Create Phase
        inov8__PMT_Phase__c ph = new inov8__PMT_Phase__c(inov8__Project__c=p.Id, Name='Test Phase');
        insert ph;
        // Create Task
        inov8__PMT_Task__c t = new inov8__PMT_Task__c(PMT_Project__c=p.Id, Name='Test Task', Approved_Hours_Logged__c=10, inov8__Assigned_To1__c=UserInfo.getUserId(), QA__c=UserInfo.getUserId(), inov8__Phase__c=ph.Id, inov8__Start_Date__c=Date.today(), inov8__Due_Date__c=Date.today().addMonths(1));
        insert t;
        // Create TT Detail attached to case assign it to Alliance, assign it to invoice
        Time_Entry__c te1 = new Time_Entry__c(
            Account__c=alliance.Id,
            End_Timestamp__c=datetime.now(),
            Start_Timestamp__c=DateTime.Now().AddDays(-1),
            Case__c=c.Id,
            Invoice__c=i.Id,
            Revenue__c=20,
            Cost__c=10,
            Notes__c='Test'
        );
        insert te1;
        // Create TT Deatil attached to task, mark it as Cost, assign it to invoice
        Time_Entry__c te2 = new Time_Entry__c(
            Account__c=booknook.Id,
            End_Timestamp__c=datetime.now(),
            Start_Timestamp__c=DateTime.Now().AddDays(-2),
            Invoice__c=i.Id,
            Task__c=t.Id,
            Project__c=p.Id,
            Invoice_Flag__c='Cost',
            Revenue__c=10,
            Cost__c=5,
            Notes__c='Test'
        );
        insert te2;
    }

    @isTest
    private static void testDataInvoiceGeneration(){

        List<Invoice__c> invoices = [SELECT Id, Billing_Account__c, Account_Fixed_Monthly_Revenue__c, Total_Bill_Amount_fixed__c, ARM_Hourly_Rate__c FROM Invoice__c];
        DataInvoiceGeneration.generateData(invoices);
    }
}