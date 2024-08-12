public class ContactHandlerClass {
    public static void sendEmailNotif(List<Contact> lstCont) { // Corregir el nombre del método aquí

        List<Messaging.SingleEmailMessage> lstEmail = new List<Messaging.SingleEmailMessage>(); // Cambiar el tipo a SingleEmailMessage

        for(Contact con : lstCont) {
            Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
            String[] toAddress = new String[]{'pcosin@gmail.com'};
            emailMsg.setToAddresses(toAddress);
            String emailSub = 'Welcome ' + 'Juan';
            emailMsg.setSubject(emailSub);    
            lstEmail.add(emailMsg);
        }
        Messaging.sendEmail(lstEmail);
    }
}