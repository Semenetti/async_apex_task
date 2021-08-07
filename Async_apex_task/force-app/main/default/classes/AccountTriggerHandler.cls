public with sharing class AccountTriggerHandler {
  // For AccountTriggerHandler move task creation logic to future method; set Task.IsSynced = false
  @future
  public static void setTaskIsSyncedToFalse(String jsonString) {
    List<Account> newList = (List<Account>) Json.deserialize(
      jsonString,
      List<Account>.class
    );
    List<Task> tasks = [
      SELECT id, Is_Synced__c
      FROM task
      WHERE whatid IN :newList
    ];

    for (Task t : tasks) {
      t.Is_Synced__c = false;
    }
    update tasks;
  }

  // In AccountTriggerHandler create future method:
  // a. For accounts in which BillingAddress changed select all related Contacts
  // b. Set to all Contacts Is Synced = false; Processed By Future = true;
  @future
  public static void checkBillingAddress(
    String newTrigger,
    String oldTrigger,
    String oldMapTrigger
  ) {
    List<Account> newList = (List<Account>) Json.deserialize(
      newTrigger,
      List<Account>.class
    );
    List<Account> oldList = (List<Account>) Json.deserialize(
      oldTrigger,
      List<Account>.class
    );
    Map<id, Account> oldMapList = (Map<id, Account>) Json.deserialize(
      oldMapTrigger,
      Map<id, Account>.class
    );

    List<Account> accWithChangedAddress = new List<Account>();

    for (Account acc : newList) {
      Account oldAccount = oldMapList.get(acc.id);
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
      con.Processed_By_Future__c = true;
    }
    update relatedContacts;
  }

  // In AccountTriggerHandler call Queueble Job, which perform similar logic:
  // a. For accounts in which BillingAddress changed select all related Contacts
  // b. Set to all Contacts Is Synced = false; Processed By Queue = true;

  public static void checkByQueueable(
    List<Account> newList,
    List<Account> oldList,
    Map<id, Account> oldMapList
  ) {
    System.enqueueJob(
      new checkBillingAddressWithQueueable(newList, oldList, oldMapList)
    );
    // checkBillingAddressWithQueueable updateContacts = new checkBillingAddressWithQueueable(newList, oldList);
    // ID jobID = System.enqueueJob(updateContacts);
  }
}
