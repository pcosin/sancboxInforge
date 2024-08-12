public class Contact1Example {
public static void createNewAccount(String accountName, String phone, String website) {
        List<Account> accListToInsert = new List<Account>(); // Inicializa la lista de cuentas

        Account acc = new Account(); // Crea un nuevo objeto Account

        // Asigna los valores a las propiedades del objeto Account usando los parámetros del método
        acc.Name = accountName;
        acc.Phone = phone;
        acc.Website = website;

        // Añade la cuenta a la lista
        accListToInsert.add(acc);

        // Inserta la lista de cuentas en la base de datos si la lista no está vacía
        if (accListToInsert.size() > 0) {
            insert accListToInsert; // Realiza la operación DML para insertar las cuentas
        }
    }
}