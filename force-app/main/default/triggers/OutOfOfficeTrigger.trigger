trigger OutOfOfficeTrigger on OutOfOffice (after insert) {
    OutOfOfficeTriggerHandler.handleAfterInsert(Trigger.new);
}