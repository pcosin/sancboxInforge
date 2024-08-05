public class ScheduledSendEmailPendingEvaluation implements Schedulable {
    public void execute(SchedulableContext sc) {
        SendEmailPendingEvaluation emailSender = new SendEmailPendingEvaluation();
		emailSender.sendEmailsBasedOnPermissionSet();
    }
}