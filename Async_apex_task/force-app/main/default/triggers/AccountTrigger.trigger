trigger AccountTrigger on Account(
  before insert,
  before update,
  before delete,
  after insert,
  after update,
  after delete,
  after undelete
) {
  //Using JSON.Serialize method we can convert the account list to Json
  String jsonTriggerNew = json.serialize(Trigger.New);
  String jsonTriggerOld = json.serialize(Trigger.Old);
  String jsonTriggerOldMap = json.serialize(Trigger.OldMap);

  AccountTriggerHandler.setTaskIsSyncedToFalse(jsonTriggerNew);
  AccountTriggerHandler.checkBillingAddress(
    jsonTriggerNew,
    jsonTriggerOld,
    jsonTriggerOldMap
  );
  // AccountTriggerHandler.checkByQueueable(jsonTriggerNew, jsonTriggerOld);
  AccountTriggerHandler.checkByQueueable(Trigger.new, Trigger.old, Trigger.oldMap);
}
