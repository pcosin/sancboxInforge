//LeadConversion
public class LeadConversion {

    public class LeadConversionRequest {
        @InvocableVariable(required=true label='Lead ID' description='The ID of the lead to be converted')
        public String leadId;

        @InvocableVariable(required=true label='Account ID' description='The ID of the account associated with the lead')
        public String accountId;

        @InvocableVariable(required=true label = 'Converted Status' description='The status to be set for the converted lead')
        public String convertedStatus;
    }

    public class LeadConversionResult {
        @InvocableVariable
        public Boolean success;
        @InvocableVariable
        public String message;
        @InvocableVariable
        public String convertedLeadId;
        @InvocableVariable
        public String createdContactId;
    }

    @InvocableMethod
    public static List<LeadConversionResult> convertLead(List<LeadConversionRequest> requests) {
        List<LeadConversionResult> results = new List<LeadConversionResult>();

        for (LeadConversionRequest request : requests) {
            LeadConversionResult result = new LeadConversionResult();
            try {
                Database.LeadConvert lc = new Database.LeadConvert();
                lc.setLeadId(request.leadId);
                lc.setAccountId(request.accountId);
                lc.setConvertedStatus(request.convertedStatus);
                lc.setDoNotCreateOpportunity(TRUE); // No crear oportunidad

                Database.LeadConvertResult lcr = Database.convertLead(lc);

                if (lcr.isSuccess()) {
                    result.success = true;
                    result.message = 'Lead convertido exitosamente';
                    result.convertedLeadId = lcr.getLeadId();
                    result.createdContactId = lcr.getContactId();
                } else {
                    result.success = false;
                    result.message = 'Error al convertir el lead: ' + lcr.getErrors();
                }
            } catch (Exception e) {
                result.success = false;
                result.message = 'Excepción: ' + e.getMessage();
            }
            results.add(result);
        }
        return results;
    }
}