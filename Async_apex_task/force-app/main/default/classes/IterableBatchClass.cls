// Create Batch Job which select all Сontacts with Is Synced = false
// a. Batch should copy from Account.BillingAddress to Contact.MailingAddress
// b. Set Contact.IsSynced__c = true;
// c. Update Account field Updated By Contact = true;
// d. Use Query Locator
// e. Create similar Batch and use Iterable

public class IterableBatchClass implements Database.Batchable<sObject>, Database.Stateful {
  public Iterable<SObject> start(Database.BatchableContext BC) {
    return new List<Contact>(
      [
        SELECT
          id,
          AccountId,
          Is_Synced__c,
          MailingStreet,
          MailingCity,
          MailingState,
          MailingPostalCode,
          MailingCountry,
          Account.BillingStreet,
          Account.BillingCity,
          Account.BillingState,
          Account.BillingPostalCode,
          Account.BillingCountry,
          Account.Updated_By_Contact__c
        FROM Contact
        WHERE Is_Synced__c = FALSE
      ]
    );
  }

  public void execute(Database.BatchableContext bc, List<Contact> contacts) {
    for (Contact con : contacts) {
      con.MailingStreet = con.Account.BillingStreet;
      con.MailingCity = con.Account.BillingCity;
      con.MailingState = con.Account.BillingState;
      con.MailingPostalCode = con.Account.BillingPostalCode;
      con.MailingCountry = con.Account.BillingCountry;

      con.Is_Synced__c = true;

      con.Account.Updated_By_Contact__c = true;
      System.debug(con);
    }

    update contacts;
  }

  public void finish(Database.BatchableContext bc) {
    System.debug('AnotherBatchClass done!');
  }
}
