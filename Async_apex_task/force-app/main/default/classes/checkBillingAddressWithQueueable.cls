// In AccountTriggerHandler call Queueble Job, which perform similar logic:
// a. For accounts in which BillingAddress changed select all related Contacts
// b. Set to all Contacts Is Synced = false; Processed By Queue = true;

public with sharing class checkBillingAddressWithQueueable implements queueable {
  private List<Account> newAccounts;
  private List<Account> oldAccounts;
  private Map<id, Account> oldMapAccounts;

  public checkBillingAddressWithQueueable(
    List<Account> newAcc,
    List<Account> oldAcc,
    Map<id, Account> oldMapAcc
  ) {
    this.newAccounts = newAcc;
    this.oldAccounts = oldAcc;
    this.oldMapAccounts = oldMapAcc;
  }

  public void execute(QueueableContext context) {
    List<Account> accWithChangedAddress = new List<Account>();

    for (Account acc : newAccounts) {
      Account oldAccount = oldMapAccounts.get(acc.id);
      if (acc.BillingAddress != oldAccount.BillingAddress) {
        accWithChangedAddress.add(new Account(id = acc.id));
      }
    }

    List<Account> getRelatedContacts = [
      SELECT
        id,
        (SELECT Name, id, Is_Synced__c, Processed_By_Queue__c FROM Contacts)
      FROM Account
      WHERE Id IN :accWithChangedAddress
    ];

    for (Account acc : getRelatedContacts) {
      for (Contact con : acc.Contacts) {
        con.Is_Synced__c = false;
        con.Processed_By_Queue__c = true;
      }
    }

    update getRelatedContacts;
  }
}
