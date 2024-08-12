trigger PreventDuplicateAccounts on Account (before insert, before update) {
    
    //  Create a set to store the account names 
    Set<String> accountNames = new Set<String>();
    for (Account acct : Trigger.new) {
        accountNames.add(acct.Name.toLowerCase());
    }
    //  Query the existing accounts with the same names
    Map<String, Account> existingAccountsMap = new Map<String, Account>();
    for (Account acct : [SELECT Id, Name FROM Account WHERE Name IN :accountNames]) {
        existingAccountsMap.put(acct.Name.toLowerCase(), acct);
    }
    //  Check for duplicate accounts
    for (Account acct : Trigger.new) {
        String lowerCaseName = acct.Name.toLowerCase();
        if (existingAccountsMap.containsKey(lowerCaseName) && existingAccountsMap.get(lowerCaseName).Id != acct.Id) {
            acct.addError('Your Account already exists in system.');
        }
    }
}