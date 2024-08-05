public with sharing class SyncCaseToNuage implements Queueable, Database.AllowsCallouts {

    public List<Case> caseList; 
    
    public SyncCaseToNuage(List<Case> caseList){
        this.caseList = caseList ;  
    }    
    
    public void execute(QueueableContext context) {
        Map<Id,Id> caseIdMap = new Map<Id,Id>();
        
        List<Account> accountsList = [SELECT Id, Nuage_Account_ID__c from Account WHERE Nuage_Account_ID__c != null];
        Map<Id,Id> accountsMap = new Map<Id,Id>();
        
        for(Account acc: accountsList){
            accountsMap.put(acc.Id, acc.Nuage_Account_ID__c);
        }
        
        for(Case caseObj : caseList){
            CaseWrapper cw = new CaseWrapper();
            cw.owner = caseObj.Owner_Name__c;
            cw.ownerId = caseObj.OwnerId;
            cw.externalId = caseObj.Id;
            cw.subject = caseObj.Subject;
            cw.description = caseObj.Description;
            cw.status = caseObj.Status;
            cw.priority = caseObj.Priority;
            cw.origin = caseObj.Origin;
            cw.estimatedHours = caseObj.Estimated_max_time__c;
            cw.accountOwner = caseObj.QA_Name__c;
            
            if(caseObj.AccountId != null) {
                cw.accountId = accountsMap.get(caseObj.AccountId);
            }
        
            String jsonBody = JSON.serialize(cw);
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:Nuage/caseUpsert/');
            req.setHeader('Content-Type', 'application/json');
            req.setMethod('POST');req.setBody(jsonBody);
            Http http = new Http();
            
            String idResponse;
            if(!Test.isRunningTest()){
            	HTTPResponse resp = http.send(req);
                System.debug('response:' + resp.getStatus() + ' ' + resp.getBody());                
                idResponse = resp.getBody().replaceAll('"', '');
            }else{
                idResponse = '50074000002loPdAAI';
            }
                        
            if(checkCaseID(idResponse)){
                caseIdMap.put(caseObj.Id, idResponse);
            }
        }
        
        List<Case> casesToUpdate = [SELECT Id FROM Case WHERE Id IN :caseIdMap.keyset()];
        for(Case c : casesToUpdate){
            c.Nuage_Case_ID__c = caseIdMap.get(c.Id);
        } 
        update casesToUpdate;
    }     
    
    public class CaseWrapper{    
        public String externalId;
        public String ownerId;
        public String owner;
        public String subject;
        public String description;
        public String status;
        public String priority;
        public String origin;
        public String accountId;
        public Double estimatedHours;
        public String accountOwner;
        
    }
    
    public boolean checkCaseID(String theId ){
        System.Type t = Case.class;
        try {
            if ( Pattern.compile( '[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}' ).matcher( theId ).matches() ){
                Id id = theId; 
                sObject sObj = (sObject) t.newInstance();      
                sObj.Id = id;
                return true;
            }
        } catch ( Exception e ){
           System.debug('Invalid Id');
        }
         return false;
    }
}