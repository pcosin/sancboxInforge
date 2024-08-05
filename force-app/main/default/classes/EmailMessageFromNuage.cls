@RestResource(urlMapping='/emailMessage/*')

global class EmailMessageFromNuage {

     @HttpPost
    global static String doPost(
         String fromAddress,   
         String fromName,
         String htmlBody,
         String parentId,
         String relatedToId,
         String status,
         String subject,
         String textBody,
    	 String toAddress){
             
        Case caseSaved = null;
        
        try{
    		caseSaved = [SELECT Id from Case WHERE Id = : parentId];
            
            if(caseSaved != null){
            EmailMessage emailMessage = new EmailMessage();
            emailMessage.status = '3';
            emailMessage.relatedToId = relatedToId; 
            emailMessage.ParentId = parentId;
            emailMessage.fromAddress = fromAddress;
            emailMessage.fromName = fromName;
            emailMessage.ToAddress = toAddress;
            emailMessage.Subject = subject;
            
            emailMessage.HtmlBody = htmlBody;
            insert emailMessage;
            
            return emailMessage.Id;
        }

        } catch(Exception ex){
            System.debug('Error: ' + ex.getMessage());
        }
             
        return null;
  
    }
}