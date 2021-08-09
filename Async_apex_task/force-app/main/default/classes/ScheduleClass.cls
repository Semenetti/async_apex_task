// Create Scheduled Job which runs every 30 minutes and call 2 created batches

public with sharing class ScheduleClass implements Schedulable {
  //Seconds Minutes Hours Day_of_month Month Day_of_week Optional_year
  public static String sch = '0 0 * * * ?';
  public static String sch2 = '0 30 * * * ?';
  ScheduleClass batch = new ScheduleClass();
  ScheduleClass batch2 = new ScheduleClass();
  String jobID = System.schedule('My batch Job', sch, batch);
  String jobID2 = System.schedule('My second batch Job', sch2, batch2);

  public void execute(SchedulableContext sc) {
    Database.executeBatch(new BatchJob());
  }
}
