trigger Contact_Trigger on Contact (after insert) {
    if (Trigger.isInsert && Trigger.isAfter) {
        ContactHandlerClass.sendEmailNotif(Trigger.new); // Asegúrate de que el nombre del método coincida
    }
}
