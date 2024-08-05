@RestResource(urlMapping='/Project/*')
global with sharing class ProjectRest {
    @HttpPost
    global static String doPost(
        String name,
        String description,
        String startDate,
        String endDate,
        String accountId,
        String externalId,
        String status,
        String levelofEffort,
        String portfolio,
        String inistartDate,
        String iniendDate
    ) {
        Account accountSaved;
        try {
            accountSaved = [
                SELECT Id
                FROM Account
                WHERE Nuage_Account_ID__c = :accountId
            ];
        } catch (Exception ex) {
            System.debug('Account is not synchronized');
            return null;
        }

        inov8__PMT_Project__c projectSaved;

        try {
            projectSaved = [
                SELECT ID
                FROM inov8__PMT_Project__c
                WHERE Nuage_Project_ID__c = :externalId
            ];
        } catch (Exception ex) {
            projectSaved = null;
        }

        inov8__PMT_Project__c project = new inov8__PMT_Project__c(
            Name = name,
            inov8__Description__c = description,
            Invoice_Account__c = accountSaved.Id,
            Start_Date__c = date.parse(startDate),
            End_Date__c = date.parse(endDate),
            Nuage_Project_ID__c = externalId,
            inov8__Level_of_Effort__c = levelofEffort,
            inov8__Portfolio__c = portfolio,
            inov8__Initial_Start_Date__c = date.parse(inistartDate),
            inov8__Initial_End_Date__c = date.parse(iniendDate)
        );

        if (projectSaved != null) {
            project.Id = projectSaved.Id;
        }

        String idReturn = null;
        try {
            upsert project;
            idReturn = project.Id;
        } catch (Exception e) {
            System.debug('Error: ' + e);
        }
        return idReturn;
    }
}