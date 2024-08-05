@RestResource(urlMapping='/caseUpsert/*')
global with sharing class CaseUpsert {
    @HttpPost
    global static String doPost(
        String externalId,
        String subject,
        String accountId,
        String priority,
        String description,
        String owner,
        String ownerId,
        String status,
        String origin,
        Double estimatedHours
    ) {
        Case caseSaved;

        try {
            caseSaved = [
                SELECT Id
                FROM Case
                WHERE Nuage_Case_ID__c = :externalId
            ];
        } catch (Exception ex) {
            caseSaved = null;
        }

        Account accountSaved;
        try {
            accountSaved = [SELECT Id FROM Account WHERE Id = :accountId];
        } catch (Exception ex) {
            accountSaved = [
                SELECT Id
                FROM Account
                WHERE Name = 'The Nuage Group'
                LIMIT 1
            ];
        }

        Nuage_sync_params__c params = [
            SELECT Default_Case_Owner__c
            FROM Nuage_sync_params__c
        ];

        System.debug('caseSaved: ' + caseSaved);

        Case caseObj = new Case(
            AccountId = accountSaved.Id,
            Subject = subject,
            Priority = priority,
            Status = status,
            Origin = origin,
            Description = description,
            Nuage_Case_ID__c = externalId,
            Sync_from_external__c = true,
            Estimated_max_time__c = estimatedHours
        );

        if (caseSaved != null) {
            //Case is updated
            caseObj.Id = caseSaved.Id;
        } else {
            //Case in inserted with default owner in custom settings
            caseObj.OwnerId = params.Default_Case_Owner__c;
        }

        upsert caseObj;

        caseObj.Sync_from_external__c = false;
        update caseObj;

        return caseObj.Id;
    }
}