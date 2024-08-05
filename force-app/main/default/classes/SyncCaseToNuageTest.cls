@isTest(SeeAllData=true)
public class SyncCaseToNuageTest {

    @isTest
    static void doTest(){        
        Account acc = new Account(Name = 'The Nuage Group');
        insert acc;
        
        List<Case> caseList = new List<Case>();
        for(Integer i = 0; i < 5; i++){
            Case c = new Case(Subject = 'Test Case ' + i, Status = 'New', Estimated_max_time__c = 8, Origin = 'Email', AccountId = acc.Id);
            caseList.add(c);
        }        
        insert caseList;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User testUser = new User();
        testUser.Email = 'johnsmith@testuser.com';
        testUser.Username = 'johnsmith@testuser.com';
        testUser.LastName = 'Smith';
        testUser.Alias = 'jsmith';
        testUser.ProfileId = p.Id;
        testUser.LanguageLocaleKey = 'en_US';
        testUser.LocaleSidKey = 'en_US';
        testUser.TimeZoneSidKey = 'America/Chicago';
        testUser.EmailEncodingKey = 'UTF-8';
        
        insert testUser;
        
        Nuage_sync_params__c params = [
            SELECT Default_Case_Owner__c
            FROM Nuage_sync_params__c
        ];
        
        params.Default_Case_Owner__c = testUser.Id;
    	update params;
        
        Test.startTest();
        SyncCaseToNuage sync = new SyncCaseToNuage(caseList);
        system.enqueueJob(sync);
        
        caseList[0].Subject = 'New Test Case for update';
        caseList[0].Nuage_Case_ID__c = caseList[0].Id;
        update caseList;
        
        CaseUpsert.doPost(caseList[0].Id, caseList[0].subject, caseList[0].accountId, caseList[0].Priority, caseList[0].Description, 'Test User', UserInfo.getUserId(), 'New', 'Email', 8);        
        Test.stopTest();
    }
}