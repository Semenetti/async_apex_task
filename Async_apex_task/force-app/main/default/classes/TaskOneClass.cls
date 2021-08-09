// Create class with future method. Inside the method do the following:
// a. Select 150 Accounts from database.
// b. For accounts in which BillingAddress is not empty select all related Contacts
// c. Set to all Contacts Is Synced = false; Processed By Future = true;
// d. Run created class using DevConsole.

public with sharing class TaskOneClass {
  @future
  public static void getContacts() {
    for (
      Account a : [
        SELECT
          Id,
          Name,
          // BillingAddress = { BillingStreet, BillingCity, BillingState, BillingPostalCode };
          BillingStreet,
          (SELECT Name, id, Is_Synced__c, Processed_By_Future__c FROM Contacts)
        FROM Account
        LIMIT 150
      ]
    ) {
      if (a.BillingStreet != null) {
        for (Contact con : a.Contacts) {
          con.Is_Synced__c = false;
          con.Processed_By_Future__c = true;
          System.debug(con);
        }
      }
    }
  }
}
