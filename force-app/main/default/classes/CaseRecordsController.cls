public with sharing class CaseRecordsController {
    //Get Case Records
      @AuraEnabled
      public static List<Case> getOpenCases(String userID, Boolean currentPeriod) {

       List<User> lstUsr = new List<User>([SELECT ContactId FROM USER WHERE Id =:userID ]);
       List<Contact> lstAcc = new List<Contact>([SELECT AccountId, Account.Billing_Period_Start_Date__c, Account.Billing_Period_End_Date__c FROM Contact WHERE Id=:lstUsr[0].ContactId]);
       List<Case> results = new List<Case>();
       if(currentPeriod){
        results = [
          SELECT Id,CaseNumber,Subject,Status,ContactEmail,Notes__c
          FROM Case 
          WHERE status != 'Closed' 
          AND status != 'Merged'  
          AND AccountId = :lstAcc[0].AccountId  
          AND CreatedDate >= :lstAcc[0].Account.Billing_Period_Start_Date__c  
          AND CreatedDate < :lstAcc[0].Account.Billing_Period_End_Date__c  Order by CreatedDate DESC];

        System.debug(JSON.serializePretty(results));
       }
       else{
          results = [SELECT Id,CaseNumber,Subject,Status,ContactEmail,Notes__c
                     FROM Case 
                     WHERE status != 'Closed' 
                     AND status != 'Merged'  
                     AND AccountId = :lstAcc[0].AccountId  Order by CreatedDate DESC];
          System.debug(JSON.serializePretty(results));
        }
        return results;
      }
  
      @AuraEnabled
      public static List<Case> getClosedCases(String userID, Boolean currentPeriod) {
      List<User> lstUsr = new List<User>([SELECT ContactId FROM USER WHERE Id =:userID ]);
       List<Contact> lstAcc = new List<Contact>([SELECT AccountId, Account.Billing_Period_Start_Date__c, Account.Billing_Period_End_Date__c FROM Contact WHERE Id=:lstUsr[0].ContactId]);
       List<Case> results = new List<Case>();
       if(currentPeriod){
        results = [SELECT Id,CaseNumber,Subject,Status,ContactEmail,Notes__c FROM Case WHERE AccountId = :lstAcc[0].AccountId AND  (status = 'Closed' OR status = 'Merged') AND ClosedDate > :lstAcc[0].Account.Billing_Period_Start_Date__c  AND ClosedDate < :lstAcc[0].Account.Billing_Period_End_Date__c  Order by CreatedDate DESC];
        System.debug(JSON.serializePretty(results));
       }
       else{
        results = [SELECT Id,CaseNumber,Subject,Status,ContactEmail,Notes__c FROM Case WHERE AccountId = :lstAcc[0].AccountId AND (status = 'Closed' OR status = 'Merged')  Order by CreatedDate DESC];
        System.debug(JSON.serializePretty(results));
      }
        return results;
        
      }
      @AuraEnabled
      public static List<Case> getFilterCases(String userID, String filterValue, String origin) {
        List<Case> results = new List<Case>();
        Date starDate = date.newinstance(2023, 1, 1);
        Date endDate = date.newinstance(2023, 12, 31);
        Boolean allTime = false;
        Boolean currentPeriod = false;
  
        switch on filterValue {
          when 'thisWeek' {     
            Date today = date.today();
            starDate = date.newInstance(today.year(), today.month(), today.toStartOfWeek().day());
            endDate = date.newInstance(today.year(), today.month(), today.day());
            allTime = false;
          }
          when 'lastWeek' {     
            Date today = date.today();
            Integer lastweek = today.toStartOfWeek().day() - 7;
            starDate = date.newInstance(today.year(), today.month(), lastweek);
            endDate = date.newInstance(today.year(), today.month(), lastweek + 6);
            allTime = false;
          }
          when 'thisMonth' {        
            Date today = date.today();
            starDate = date.newInstance(today.year(), today.month(), 1);
            endDate = date.newInstance(today.year(), today.month(), today.day());
            allTime = false;
          }
          when 'lastMonth' {        
            Date today = date.today();
            Integer days = 0;
            Integer month = today.month();
            Integer year = today.year();
            if(today.month() == 1){
              days = 31;
              month = 12;
              year = today.year() - 1;
            }
            if(today.month() == 3  || today.month() == 5 || today.month() == 7 || today.month() == 8 || today.month() == 10 || today.month() == 12){
              days = 31;
              month = today.month() - 1;
            }
            if(today.month() == 4 || today.month() == 6  || today.month() == 9 || today.month() == 11){
              days = 30;
              month = today.month() - 1;
            }
            if(today.month() == 2){
              days = 28;
              month = today.month() - 1;
            }
            starDate = date.newInstance(year, month , 1);
            endDate = date.newInstance(year, month , days);
            allTime = false;
          }
          when 'thisYear' {     
            Date today = date.today();
            starDate = date.newInstance(today.year(), 1, 1);
            endDate = date.newInstance(today.year(), today.month(), today.day());
            allTime = false;
          }
          when 'yesterday' {        
            Date today = date.today();
            starDate = date.newInstance(today.year(), today.month(), today.day() - 1);
            endDate = date.newInstance(today.year(), today.month(), today.day());
            allTime = false;
          }
          when 'today' {        
            Date today = date.today();
            starDate = date.newInstance(today.year(), today.month(), today.day());
            endDate = date.newInstance(today.year(), today.month(), today.day());
            allTime = false;
          }
          when 'allTime' {      
            allTime = true;
            currentPeriod = false;
          }
          when 'billingPeriod'{
            allTime = true;
            currentPeriod = true;
          }
          when 'fiscalQuarter'{
            allTime = false;
            List <Date> fiscalYearInfo = getFiscarlQuarter();
            starDate = date.newInstance(fiscalYearInfo[0].year(), fiscalYearInfo[0].month(), fiscalYearInfo[0].day());
            endDate = date.newInstance(fiscalYearInfo[1].year(), fiscalYearInfo[1].month(), fiscalYearInfo[1].day());

    
          }
          when 'lastQuarter'{
            allTime = false;
            List <Date> fiscalYearInfo = getFiscarlQuarter();
            if(fiscalYearInfo[0].month() == 1){
              starDate = date.newInstance(fiscalYearInfo[0].year() - 1 , 10, fiscalYearInfo[0].day());
              endDate = date.newInstance(fiscalYearInfo[1].year() - 1, 12, fiscalYearInfo[1].year());
            }
            else{
              starDate = date.newInstance(fiscalYearInfo[0].year(), fiscalYearInfo[0].month() - 3, fiscalYearInfo[0].day());
              endDate = date.newInstance(fiscalYearInfo[1].year(), fiscalYearInfo[1].month() - 3, fiscalYearInfo[1].day());
            }
            
          }
          
      }

      if(origin=='Open' && !allTime){
        results = getOpenFilterCases(userID, starDate, endDate);
      }
      else if (origin=='Closed' && !allTime) {
        results = getClosedFilterCases(userID, starDate, endDate);
      } 
      else if (allTime && origin=='Open') {
        results = getOpenCases(userID,currentPeriod);
      } 
      else if (allTime && origin=='Closed') {
        results = getClosedCases(userID,currentPeriod);
      } 
        
      System.debug(JSON.serializePretty(results));
      return results;
         
      }

      public static List<Case> getOpenFilterCases(String userID, Date starDate, Date endDate) {

        List<User> lstUsr = new List<User>([SELECT ContactId FROM USER WHERE Id =:userID ]);
        List<Contact> lstAcc = new List<Contact>([SELECT AccountId FROM Contact WHERE Id=:lstUsr[0].ContactId]);
        List<Case> results = new List<Case>();
         results = [SELECT Id,CaseNumber,Subject,Status,ContactEmail,Notes__c FROM Case WHERE status != 'Closed' AND status != 'Merged'  AND AccountId = :lstAcc[0].AccountId  AND CreatedDate > :starDate  AND CreatedDate < :endDate  Order by CreatedDate DESC];
         System.debug(JSON.serializePretty(results));
         return results;
         
      }

      public static List<Case> getClosedFilterCases(String userID,Date starDate, Date endDate) {

        List<User> lstUsr = new List<User>([SELECT ContactId FROM USER WHERE Id =:userID ]);
        List<Contact> lstAcc = new List<Contact>([SELECT AccountId FROM Contact WHERE Id=:lstUsr[0].ContactId]);
        List<Case> results = new List<Case>();
         results = [SELECT Id,CaseNumber,Subject,Status,ContactEmail,Notes__c FROM Case WHERE AccountId = :lstAcc[0].AccountId AND  (status = 'Closed' OR status = 'Merged') AND CreatedDate > :starDate  AND CreatedDate < :endDate  Order by CreatedDate DESC];
         System.debug(JSON.serializePretty(results));
         return results;
         
      }

      public static List<Date> getFiscarlQuarter() {

        Date currentYear = date.today();
        Date starDate = date.newinstance(2023, 1, 1);
        Date endDate = date.newinstance(2023, 12, 31);
        List<Date> data = new List<Date>();

        // List<Date> data = new List<Date>([SELECT Description,EndDate,Id,IsStandardYear,Name,PeriodId,PeriodLabelScheme,PeriodPrefix,QuarterLabelScheme,QuarterPrefix,StartDate,SystemModstamp,WeekLabelScheme,WeekStartDay,YearType FROM FiscalYearSettings WHERE Name=:String.valueOf(currentYear)]);
        // Date FiscalYearStart = data.StartDate;


        switch on currentYear.month() {
          when 1,2,3  {     
            starDate = date.newinstance(2023, 1, 1);
            endDate = date.newinstance(2023, 3, 31);
        
          }
          when 4,5,6  {     
            starDate = date.newinstance(2023, 4, 1);
            endDate = date.newinstance(2023, 6, 30);
          }
          when 7,8,9 {      
            starDate = date.newinstance(2023, 7, 1);
            endDate = date.newinstance(2023, 9, 31);
          }
          when 10,11,12 {       
            starDate = date.newinstance(2023, 10, 1);
            endDate = date.newinstance(2023, 12, 31);
          }
        }
        data.add(starDate);
        data.add(endDate);

         return data;
         
      }



  }