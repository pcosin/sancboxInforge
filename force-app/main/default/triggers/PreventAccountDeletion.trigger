trigger PreventAccountDeletion on Account (before delete) {
    Set<Id> accountIds = Trigger.oldMap.keySet();
    List<Opportunity> opps = [SELECT Id, AccountId FROM Opportunity WHERE AccountId IN :accountIds AND StageName = 'Closed Won'];

    Map<Id, Integer> accountOppCountMap = new Map<Id, Integer>();
    for (Opportunity opp : opps) {
        if (!accountOppCountMap.containsKey(opp.AccountId)) {
            accountOppCountMap.put(opp.AccountId, 0);
        }
        accountOppCountMap.put(opp.AccountId, accountOppCountMap.get(opp.AccountId) + 1);
    }

    for (Account acc : Trigger.old) {
        if (accountOppCountMap.containsKey(acc.Id) && accountOppCountMap.get(acc.Id) > 0) {
            acc.addError('Cannot delete account with "Closed Won" opportunities.');
        }
    }
}