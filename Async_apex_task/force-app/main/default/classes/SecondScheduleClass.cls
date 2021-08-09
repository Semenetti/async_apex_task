public with sharing class SecondScheduleClass implements Schedulable {
  //Seconds Minutes Hours Day_of_month Month Day_of_week Optional_year
//   String sch = '0 0 * * * ?';
//   String sch2 = '0 30 * * * ?';
//   SecondScheduleClass firstBatch = new SecondScheduleClass();
//   SecondScheduleClass secondBatch = new SecondScheduleClass();
//   String jobID = System.schedule('My batch Job', sch, firstBatch);
//   String jobID2 = System.schedule('My second batch Job', sch2, secondBatch);

  public void execute(SchedulableContext sc) {
    Database.executeBatch(new IterableBatchClass());
    CronTrigger ct = [
      SELECT TimesTriggered, NextFireTime
      FROM CronTrigger
      WHERE id = :sc.getTriggerId()
    ];
    System.debug(ct);
  }
}