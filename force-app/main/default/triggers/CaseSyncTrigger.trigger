trigger CaseSyncTrigger on Case (after insert, after update) {
    
    if(Trigger.isInsert){
        List<Case> caseToInsert = new List<Case>();
        for(Case c: Trigger.New){
            if(c.Sync_from_external__c == false && ( c.Parent_Account_Name__c	== 'The Nuage Group' ||  c.Account_Name__c == 'The Nuage Group') ){
                caseToInsert.add(c);
            }
        }
        System.enqueueJob(new SyncCaseToNuage(caseToInsert));
    }
      
    if(Trigger.isAfter && Trigger.isUpdate){
        List<Case> caseToUpdate = new List<Case>();
        for( Id caseId : Trigger.newMap.keySet()){
          if( (Trigger.oldMap.get(caseId).OwnerId != Trigger.newMap.get(caseId).OwnerId || 
            	Trigger.oldMap.get(caseId).QA__c != Trigger.newMap.get(caseId).QA__c ||
             	Trigger.oldMap.get(caseId).Status != Trigger.newMap.get(caseId).Status ||
                Trigger.oldMap.get(caseId).Subject != Trigger.newMap.get(caseId).Subject ||
             	Trigger.oldMap.get(caseId).Description != Trigger.newMap.get(caseId).Description ||
             	Trigger.oldMap.get(caseId).Estimated_max_time__c != Trigger.newMap.get(caseId).Estimated_max_time__c ||
             	Trigger.oldMap.get(caseId).AccountId != Trigger.newMap.get(caseId).AccountId ) &&
                Trigger.newMap.get(caseId).Sync_from_external__c == false &&
                (Trigger.newMap.get(caseId).Parent_Account_Name__c	== 'The Nuage Group' ||  Trigger.newMap.get(caseId).Account_Name__c == 'The Nuage Group')
            )
          {                           
             caseToUpdate.add(Trigger.newMap.get(caseId));
          }
        }
        
        System.enqueueJob(new SyncCaseToNuage(caseToUpdate));
    }
}