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
    // List<Account> accWithChangedAddress = [
    //   SELECT id, (SELECT id, AccountId FROM contacts)
    //   FROM newAccounts
    //   WHERE BillingAddress NOT IN (:oldAccounts)
    // ];

    // List<Contact> relatedContacts = [
    //   SELECT Name, id, Is_Synced__c, Processed_By_Queue__c
    //   FROM Contact
    //   WHERE AccountId IN :accWithChangedAddress
    // ];

    List<Account> accWithChangedAddress = new List<Account>();

    for (Account acc : newAccounts) {
      Account oldAccount = oldMapAccounts.get(acc.id);
      if (acc.BillingAddress != oldAccount.BillingAddress) {
        accWithChangedAddress.add(new Account(id = acc.id));
      }
    }

    List<Contact> relatedContacts = [
      SELECT Name, id, Is_Synced__c, Processed_By_Future__c
      FROM Contact
      WHERE AccountId IN :accWithChangedAddress
    ];

    for (Contact con : relatedContacts) {
      con.Is_Synced__c = false;
      con.Processed_By_Queue__c = true;
    }
    update relatedContacts;
  }
}
