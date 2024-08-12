public class Contac1 {
    public static void createNewContact(String firstName, String lastName, String email) {
       
       List<Contact> conListToInsert = new List<Contact>();
        
       Contact con = new Contact();
       
       con.FirstName = firstName;
       con.LastName = lastName;
       con.Email = email;
       conListToInsert.add(con);
       
       if(conListToInsert.size() > 0) {
           insert conListToInsert;
        }       
   }

}