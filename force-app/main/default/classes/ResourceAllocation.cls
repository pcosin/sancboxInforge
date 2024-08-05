public with sharing class ResourceAllocation {
    
    @InvocableMethod(label='Set User Allocated Hours' description='Sets the hours allocated to customer and sales in the User record.' category= 'Time Entry')
    public static void setUserAllocatedHours() {

        // There is a chart on the user record that shows the hours by account for the last 30 days
        // The chart total number is lower or equal because the query counts 1 extra day
        // Why? I guess because the queries are GMT. That's just a guess 
        List<AggregateResult> clientHoursByUser = [SELECT User__c, SUM(Time_Worked__c) hours FROM Time_Entry__c WHERE Account_Name__c != 'One Global Property Management LLC' AND Account_Name__c != 'Inforge'
        AND User__r.IsActive = true AND Start_Date__c = LAST_N_DAYS:30 GROUP BY User__c];

        List<AggregateResult> salesHoursByUser = [SELECT User__c, SUM(Time_Worked__c) hours FROM Time_Entry__c WHERE Account_Name__c = 'Inforge' AND Task__r.Name = 'Sales & Marketing' AND Task__r.Project_Account__c = 'Inforge'
        AND User__r.IsActive = true AND Start_Date__c = LAST_N_DAYS:30 GROUP BY User__c];

        Map<Id,Decimal> mapUserClientAllocatedHours = new Map<Id,Decimal>();
        Map<Id,Decimal> mapUserSalesAllocatedHours = new Map<Id,Decimal>();
        List<Id> userIds = new List<Id>();

        for (AggregateResult clientHours : clientHoursByUser) {
            mapUserClientAllocatedHours.put((Id)clientHours.get('User__c'), (Decimal)clientHours.get('hours'));
            userIds.add((Id)clientHours.get('User__c'));
        }
        for (AggregateResult salesHours : salesHoursByUser) {
            String userId = (String)salesHours.get('User__c');
            mapUserSalesAllocatedHours.put(userId, (Decimal)salesHours.get('hours'));
            if (!userIds.contains(userId)) {
                userIds.add(userId);
            }
        }

        List<User> users = [SELECT Id FROM User WHERE Id IN :userIds];
        for (User u : users) {
            u.Monthly_Hours_Allocated_to_Customers__c = mapUserClientAllocatedHours.get(u.Id);
            u.Monthly_Hours_Allocated_to_Sales__c = mapUserSalesAllocatedHours.get(u.Id);
        }
        update users;
    }

}