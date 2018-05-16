/*
https://wenku.baidu.com/view/2bc5343a26284b73f242336c1eb91a37f0113262.html?re=view
 */

drop database if exists enterprisedb;

create database enterprisedb
  character set utf8mb4
  collate utf8mb4_unicode_ci;

use enterprisedb;
create table employee
(
  id              int auto_increment
    primary key,
  name            varchar(255)    not null,
  sex             enum ('男', '女') not null,
  birthday        date            not null,
  department_name varchar(255)    not null,
  salary          decimal(10, 2)  not null
)
  engine = MyISAM
  AUTO_INCREMENT = 86001;

INSERT INTO `employee` (`name`, `sex`, `birthday`, `department_name`, `salary`)
VALUES ('夏修诚', '男', '1988-05-15', '规划部', 8800.00), ('刘君昊', '男', '1995-07-11', '总经理办公室', 15000.00),
  ('段兴修', '男', '1980-12-09', '人力资源部', 12000.00),
  ('于心思', '男', '1982-02-09', '保卫部', 6400.00), ('汪弘盛', '男', '1983-03-08', '生产技术部', 18000.00);

ALTER TABLE employee
  ENGINE = InnoDB;

select ENGINE
from information_schema.TABLES
where TABLE_NAME = 'employee';

/*
MyISAM不支持事务，而InnoDB支持。
InnoDB支持数据行锁定，MyISAM不支持行锁定，只支持锁定整个表。
InnoDB支持外键，MyISAM不支持。
InnoDB的主键范围更大，最大是MyISAM的2倍。
InnoDB不支持全文索引，而MyISAM支持。
MyISAM支持GIS数据，InnoDB不支持。
没有where的count(*)使用MyISAM要比InnoDB快得多。因为MyISAM内置了一个计数器，
 */

/*
员工号作为主键已经有索引了，
可能经常需要根据姓名搜索员工，所以建立姓名索引能有效提升检索速度，
 */
CREATE INDEX employee_name_index
  ON employee (name);

DROP INDEX employee_name_index
ON employee;

/*
视图中，为了区分每个人，员工的工号id必须选择，
我们一般都是叫名字，所以员工的名字也要加入，由于这是用于员工生日会的视图，所以生日birthday也要选择。
最后，男女生日会准备应该不同，所以也要选择员工的性别。
 */
create view partyview as
  select
    id,
    name,
    sex,
    birthday
  from employee;

select TABLE_TYPE from information_schema.TABLES where TABLE_NAME = 'partyview';

ALTER TABLE employee ADD level int NOT NULL DEFAULT 1;
UPDATE `enterprisedb`.`employee` t SET t.`level` = 2 WHERE t.`id` = 86003;
UPDATE `enterprisedb`.`employee` t SET t.`level` = 9 WHERE t.`id` = 86004;
UPDATE `enterprisedb`.`employee` t SET t.`level` = 10 WHERE t.`id` = 86002;
UPDATE `enterprisedb`.`employee` t SET t.`level` = 5 WHERE t.`id` = 86001;
UPDATE `enterprisedb`.`employee` t SET t.`level` = 15 WHERE t.`id` = 86005;

alter view partyview as
  select
    id,
    name,
    sex,
    birthday,
    level
  from employee;

drop view partyview;

drop database if exists enterprisedb;

/*
在题目1.2执行时，总出现Column ‘sex’ has duplicated value ‘?’ in ENUM问题，
后来发现是数据库没设置编码所导致的错误，
进行重建数据库时制定utf-8编码的修改后错误消除，
从而说明默认编码的数据库建表时不能带有中文；
 */
/*
掌握了创建指定引擎的数据库，及修改数据库的存储引擎的方法。
掌握了MySQL索引的创建、删除方法。掌握MySQL视图的创建，修改，删除方法。
 */
