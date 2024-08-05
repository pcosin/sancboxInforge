global class DataInvoiceGeneration {
    
    @InvocableMethod
    public static void generateData(List<Invoice__c> invoices){

        List<Id> invoiceIds = new List<Id>();
        Map<Id, Invoice__c> invoicesMap = new Map<Id, Invoice__c>();
        Map<Id, Decimal> totalInvoiceHoursMap = new Map<Id, Decimal>();
        Map<Id, Decimal> billableInvoiceHoursMap = new Map<Id, Decimal>();
        Map<Id, Decimal> billableInvoiceAmountMap = new Map<Id, Decimal>();
        Map<Id, Decimal> billedSeparatelyAmountMap = new Map<Id, Decimal>();
        Map<Id, Decimal> invoiceCostMap = new Map<Id, Decimal>();
        Map<Id, Decimal> lineNumberMap = new Map<Id, Decimal>();
        for (Invoice__c invoice : invoices) {
            invoiceIds.add(invoice.Id);
            invoicesMap.put(invoice.Id, invoice);
            totalInvoiceHoursMap.put(invoice.Id, 0);
            billableInvoiceHoursMap.put(invoice.Id, 0);
            billableInvoiceAmountMap.put(invoice.Id, 0);
            billedSeparatelyAmountMap.put(invoice.Id, 0);
            invoiceCostMap.put(invoice.Id, 0);
            lineNumberMap.put(invoice.Id, 0);
        }

        // 1- delete old invoice line items
        delete [SELECT Id FROM 	Invoice_Detail__c WHERE Invoice__c IN :invoiceIds];

        // 2- get all tt details for the invoices
        List<Time_Entry__c> TimeEntries = [SELECT Id, Invoice__c, Account__c, Account_Parent__c, Revenue__c, Cost__c, Parent_Account_Hourly_Rate__c, Account__r.Blended_Hourly_Rate__c, Nuage_Hours__c, Account__r.Fixed_Monthly_Revenue__c, Account__r.Name, Project__r.Name, Project__r.Billed_Separately__c, Project__r.Special_Hourly_Rate__c, Project__r.Monthly_Revenue__c, Time_Worked__c, Invoice_Flag__c FROM Time_Entry__c WHERE Time_Worked__c != NULL AND Invoice__c IN :invoiceIds];

        // 3- create the map needed to create the invoice details
        Map<String, List<Time_Entry__c>> invoiceDetailMap = new Map<String, List<Time_Entry__c>>();
        for (Time_Entry__c TimeEntry : TimeEntries) {
            String project = projectName(TimeEntry);
            String combination = TimeEntry.Invoice__c + ' - ' + TimeEntry.Account__c + ' - ' + project;
            List<Time_Entry__c> TimeEntriesTemp = invoiceDetailMap.get(combination);
            if (TimeEntriesTemp == null) {
                TimeEntriesTemp = new List<Time_Entry__c>();
            }
            TimeEntriesTemp.add(TimeEntry);
            invoiceDetailMap.put(combination, TimeEntriesTemp);
        }

        // 4- create the invoice details
        Map<String, Invoice_Detail__c> invoiceLineMap = new Map<String, Invoice_Detail__c>();
        List<Invoice_Detail__c> invoiceDetails = new List<Invoice_Detail__c>();
        for (String combination : invoiceDetailMap.keySet()) {
            List<Time_Entry__c> TimeEntriesTemp = invoiceDetailMap.get(combination);
            Time_Entry__c first = TimeEntriesTemp[0];
            Decimal lineNumber = lineNumberMap.get(first.Invoice__c);
            linenumber++;
            lineNumberMap.put(first.Invoice__c, lineNumber);

            String project = projectName(first);
            Invoice_Detail__c invoiceDetail = new Invoice_Detail__c(
                Account__c = first.Account__c,
                Invoice__c = first.Invoice__c,
                Project__c = first.Project__c,
                Line_Number__c = lineNumber,
                Description__c = project
            );
            Decimal totalHours = 0;
            Decimal billableHours = 0;
            Decimal billAmount = 0;
            Decimal cost = 0;
            for (Time_Entry__c EntryTemp : TimeEntriesTemp) {
                totalHours += EntryTemp.Time_Worked__c;
                cost += EntryTemp.Cost__c;
                if (EntryTemp.Invoice_Flag__c != 'Cost') {
                    Decimal EntryBillableHours = (EntryTemp.Account_Parent__c == 'The Nuage Group' || EntryTemp.Account__r.Name == 'The Nuage Group' ?  EntryTemp.Nuage_Hours__c : EntryTemp.Time_Worked__c);
                    Decimal hourlyRate = EntryTemp.Account__r.Blended_Hourly_Rate__c;
                    if (EntryTemp.Project__r.Special_Hourly_Rate__c != null) {
                        hourlyRate = EntryTemp.Project__r.Special_Hourly_Rate__c;
                    } else if (EntryTemp.Account_Parent__c == 'The Nuage Group') {
                        hourlyRate = EntryTemp.Parent_Account_Hourly_Rate__c;
                    }
                    billableHours += EntryBillableHours;
                    billAmount += (EntryBillableHours * hourlyRate);
                }
            }
            Decimal totalInvoiceHours = totalInvoiceHoursMap.get(first.Invoice__c);
            totalInvoiceHours += totalHours;
            totalInvoiceHoursMap.put(first.Invoice__c, totalInvoiceHours);
            Decimal billableInvoiceHours = billableInvoiceHoursMap.get(first.Invoice__c);
            billableInvoiceHours += billableHours;
            billableInvoiceHoursMap.put(first.Invoice__c, billableInvoiceHours);
            Decimal billableInvoiceAmount = billableInvoiceAmountMap.get(first.Invoice__c);
            billableInvoiceAmount += billAmount;
            billableInvoiceAmountMap.put(first.Invoice__c, billableInvoiceAmount);
            Decimal invoiceCost = invoiceCostMap.get(first.Invoice__c);
            invoiceCost += cost;
            invoiceCostMap.put(first.Invoice__c, invoiceCost);
            invoiceDetail.Bill_Amount__c = billAmount; // Invoice amount for Consulting companies (Nuages)
            if (first.Project__r.Billed_Separately__c) {
                invoiceDetail.Bill_Amount__c = first.Project__r.Monthly_Revenue__c;
                Decimal billedSeparatelyAmount = billedSeparatelyAmountMap.get(first.Invoice__c);
                billedSeparatelyAmount += first.Project__r.Monthly_Revenue__c; // Invoice amount for direct customer projects (always mark as billed separately)
                billedSeparatelyAmountMap.put(first.Invoice__c, billedSeparatelyAmount);
            } else if (first.Account__r.Fixed_Monthly_Revenue__c > 0) {
                invoiceDetail.Bill_Amount__c = first.Account__r.Fixed_Monthly_Revenue__c; // Invoice amount for managed services
            }
            invoiceDetail.Total_Billable_Hours__c = totalHours;
            invoiceDetail.Actual_Billable_Hours__c = billableHours;
            invoiceDetail.Cost__c = cost;
            invoiceDetails.add(invoiceDetail);
            invoiceLineMap.put(combination, invoiceDetail);
        }
        insert invoiceDetails;

        // 5- Match the tt details with invoice lines
        // Commented-out due to high resource consumption
        // for (dftlytime__dftly_Timesheet_Detail__c ttdetail : ttdetails) {
        //     String project = projectName(ttdetail);
        //     String combination = ttdetail.Invoice__c + ' - ' + ttDetail.dftlytime__Account__c + ' - ' + project;
        //     dftlytime__Invoice_Detail__c invoiceDetail = invoiceLineMap.get(combination);
        //     ttdetail.dftlytime__Billed_in_Invoice_Line_Number__c = invoiceDetail.Id;
        // }
        // update ttdetails;

        // 6- Calculate the invoice totals and set it as closed
        for (Invoice__c invoice : invoices) {
            invoice.Total_Billable_Hours__c = totalInvoiceHoursMap.get(invoice.Id);
            invoice.Actual_Billable_Hours__c = billableInvoiceHoursMap.get(invoice.Id);
            invoice.Cost__c = invoiceCostMap.get(invoice.Id);
            invoice.Invoice_Status__c = 'Closed';
            invoice.Invoice_Date__c= Date.today();
            if (!invoice.Total_Bill_Amount_fixed__c) {
                invoice.Total_Bill_Amount__c = (invoice.ARM_Hourly_Rate__c > 0 ? billableInvoiceAmountMap.get(invoice.Id) : invoice.Account_Fixed_Monthly_Revenue__c + billedSeparatelyAmountMap.get(invoice.Id));
            }
        }
        update invoices;
    }

    private static String projectName(Time_Entry__c TimeEntry) {
        return (TimeEntry.Project__r.Name == null ? TimeEntry.Account__r.Name + ' Support' : TimeEntry.Project__r.Name);
    }

}