@isTest
private class TaskRestTest {
    @isTest
    static void testDoPost() {
        // Create test data

        Account nuage = new Account(
            Name = 'The Nuage Group',
            Hourly_rate__c = 2
        );
        insert nuage;

        inov8__PMT_Project__c p = new inov8__PMT_Project__c(
            Invoice_Account__c = nuage.Id,
            Name = 'Test Project',
            inov8__Level_of_Effort__c = 'Medium',
            inov8__Portfolio__c = 'P2P',
            inov8__Initial_Start_Date__c = Date.today(),
            inov8__Initial_End_Date__c = Date.today().addMonths(1)
        );
        insert p;

        inov8__PMT_Phase__c ph = new inov8__PMT_Phase__c(
            inov8__Project__c = p.Id,    
            Name = 'Test Phase'
        );
        insert ph;

        Nuage_sync_params__c params = new Nuage_sync_params__c(
            Default_Task_Owner__c = UserInfo.getUserId(),
            Default_QA__c = UserInfo.getUserId()
        );
        insert params;
        
        String externalId = 'TEST_EXTERNAL_ID';

        // Call the doPost method
        Test.startTest();
        String result = TaskRest.doPost(
            'Test Task',
            '1686254180049',
            '1686254280049',
            Date.today().format(),
            'Not Started',
            'Test Description',
            'Build',
            p.Id,
            externalId,
            'Development',
            'Steps',
            'Criteria',
            'Yes',
            'Medium',
            'onHoldReason',
            ph.Id,
            false
        );
        Test.stopTest();

        inov8__PMT_Task__c[] tasks = [
            SELECT
                Id,
                Approved_Hours_Logged__c,
                PMT_Project__c,
                inov8__Description__c,
                Name,
                Nuage_Task_Id__c,
                Sync_from_external__c,
                inov8__Status__c,
                Start_Time__c,
                End_Time__c,
                inov8__Assigned_To1__c,
                QA__c,
                inov8__Phase__c
                
            FROM inov8__PMT_Task__c
        ];

        //Test trigger update
        if (!tasks.isEmpty()) {
            // Si la lista no está vacía, procede a actualizar el primer elemento
            tasks[0].Name = 'Test task update';
            tasks[0].inov8__Status__c = 'Closed';
            tasks[0].inov8__Description__c = 'Test Description update';
            update tasks;
        } else {
            // Manejo de la situación cuando la lista está vacía
            System.debug('No se encontraron tareas para actualizar.');
        }
    }
}