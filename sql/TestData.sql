
INSERT INTO User_CT.EventType (Code,Description) VALUES ('1','Sleep');
INSERT INTO User_CT.EventType (Code,Description) VALUES ('2','Lights turned off');
INSERT INTO User_CT.EventType (Code,Description) VALUES ('3','Awakening');

INSERT INTO SQLUser.SleepStudy (DateRequested,StartDate,EndDate,RequestingID,RequestingFacility,MPIID,Status) VALUES ({d '2020-05-27'},{d '2020-06-01'},{d '2020-06-08'},'1','1','1','In Progress');

INSERT INTO SQLUser.SleepRecord (RecordDate,EventType,Study,TimeFrom,TimeTo) VALUES ({d '2020-06-01'},1,1,{t '15:00:00'},{t '17:00:00'});
INSERT INTO SQLUser.SleepRecord (RecordDate,EventType,Study,TimeFrom,TimeTo) VALUES ({d '2020-06-01'},1,1,{t '23:45:00'},{t '08:30:00'});
INSERT INTO SQLUser.SleepRecord (RecordDate,EventType,Study,TimeFrom,TimeTo) VALUES ({d '2020-06-02'},1,1,{t '23:00:00'},{t '09:00:00'});
INSERT INTO SQLUser.SleepRecord (RecordDate,EventType,Study,TimeFrom,TimeTo) VALUES ({d '2020-06-03'},1,1,{t '15:15:00'},{t '17:30:00'});
INSERT INTO SQLUser.SleepRecord (RecordDate,EventType,Study,TimeFrom,TimeTo) VALUES ({d '2020-06-04'},1,1,{t '01:15:00'},{t '11:30:00'});
INSERT INTO SQLUser.SleepRecord (RecordDate,EventType,Study,TimeFrom,TimeTo) VALUES ({d '2020-06-04'},1,1,{t '23:15:00'},{t '08:15:00'});
INSERT INTO SQLUser.SleepRecord (RecordDate,EventType,Study,TimeFrom,TimeTo) VALUES ({d '2020-06-05'},1,1,{t '14:15:00'},{t '16:00:00'});
INSERT INTO SQLUser.SleepRecord (RecordDate,EventType,Study,TimeFrom,TimeTo) VALUES ({d '2020-06-05'},1,1,{t '23:45:00'},{t '09:30:00'});
INSERT INTO SQLUser.SleepRecord (RecordDate,EventType,Study,TimeFrom,TimeTo) VALUES ({d '2020-06-06'},1,1,{t '12:45:00'},{t '13:30:00'});
INSERT INTO SQLUser.SleepRecord (RecordDate,EventType,Study,TimeFrom,TimeTo) VALUES ({d '2020-06-06'},1,1,{t '22:45:00'},{t '07:30:00'});
INSERT INTO SQLUser.SleepRecord (RecordDate,EventType,Study,TimeFrom,TimeTo) VALUES ({d '2020-06-07'},1,1,{t '14:30:00'},{t '16:15:00'});
INSERT INTO SQLUser.SleepRecord (RecordDate,EventType,Study,TimeFrom,TimeTo) VALUES ({d '2020-06-07'},1,1,{t '23:30:00'},{t '09:00:00'});