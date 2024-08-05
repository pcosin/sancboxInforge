global class TimeEntrySetAccountSchedulable implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new TimeEntrySetAccountBatch());
    }

}