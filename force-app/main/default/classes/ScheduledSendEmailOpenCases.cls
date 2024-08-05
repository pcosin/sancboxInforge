global with sharing class ScheduledSendEmailOpenCases implements Schedulable {
    global void execute(SchedulableContext sc) {
        SendEmailOpenCases.sendCaseReports();
    }
}