// Create Queueble Job to perform similar logic:
// a. For accounts in which BillingAddress is not empty select all related Contacts
// b. Set to all Contacts Is Synced = false; Processed By Queue = true;
// c. Run created class using DevConsole.

public class QueuableJobClass implements Queueable {
  public void execute(QueueableContext context) {
    List<Account> getAccountsWithBillingAddress = [
      SELECT
        Id,
        Name,
        // BillingAddress = { BillingStreet, BillingCity, BillingState, BillingPostalCode };
        BillingStreet,
        (SELECT Name, id, Is_Synced__c, Processed_By_Queue__c FROM Contacts)
      FROM Account
      WHERE BillingStreet != NULL
    ];

    List<Contact> contactsForUpdate = [
      SELECT Name, id, Is_Synced__c, Processed_By_Queue__c
      FROM Contact
      WHERE AccountId IN :getAccountsWithBillingAddress
    ];
    for (Contact con : contactsForUpdate) {
      con.Is_Synced__c = false;
      con.Processed_By_Queue__c = true;
      System.debug(con);
    }

    update contactsForUpdate;
  }
}
