USE javalab;
delete from department;
delete from patient;
delete from doctor;
delete from register_category;

insert into department values("100","内科","nk"),
("201","感染科","grk");

insert into patient values("001","病人1","123",100.0,"2018-06-03 23:53:17"),
("002","病人2","123",200.0,"2018-04-08 23:53:17"),
("003","病人3","123",200.0,"2018-05-08 23:53:17");

insert into doctor values("001","100","A医生","AYS","123",TRUE,"2009-06-08 23:53:17"),
("002","100","B医生","BYS","123",FALSE,"2018-06-02 23:53:17"),
("003","100","C医生","CYS","123",TRUE,"2009-06-03 23:53:17"),
("004","201","D医生","DYS","123",TRUE,"2009-06-04 23:53:17"),
("005","201","E医生","EYS","123",FALSE,"2009-06-05 23:53:17");

insert into register_category values("001","号种A","HZA","100",TRUE,3,200.0),
("002","号种B","HZB","100",FALSE,3,100.0),
("003","号种C","HZC","100",FALSE,3,50.0),
("004","号种D","HZD","201",FALSE,3,10.0),
("005","号种E","HZE","201",FALSE,3,2.0),
("006","号种F","HZF","201",FALSE,3,300.0);