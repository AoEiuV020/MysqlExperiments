/*
https://dev.mysql.com/downloads/mysql/5.7.html#downloads
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
  department_name varchar(255)    not null
)
  AUTO_INCREMENT = 86001;

INSERT INTO `employee` (`name`, `sex`, `birthday`, `department_name`)
VALUES ('夏修诚', '男', '1988-05-15', '规划部'), ('刘君昊', '男', '1995-07-11', '总经理办公室'), ('段兴修', '男', '1980-12-09', '人力资源部'),
  ('于心思', '男', '1982-02-09', '保卫部'), ('汪弘盛', '男', '1983-03-08', '生产技术部'), ('周修谨', '男', '1993-10-19', '计划营销部'),
  ('廖孒凡', '女', '1990-12-31', '安全监察部'), ('易谷冬', '女', '1981-06-17', '财务部'), ('范梓婧', '女', '1989-04-05', '后勤部'),
  ('邓笑槐', '女', '1982-03-03', '宣传部');

select * from employee;

select * from employee where sex = '男';

select * from employee where birthday >= '1990-01-01';

delete from employee where id = 86005;

select * from employee;

UPDATE `enterprisedb`.`employee` t SET t.`sex` = '女', t.`department_name` = '规划部' WHERE t.`id` = 86003;

select * from employee;

drop database if exists enterprisedb;

/*
都是基本操作，没问题，
 */
/*
掌握了MySQL在Windows平台上的安装与卸载的方法，
掌握了数据库及表的创建、删除方法，掌握数据的插入，查询，修改，删除方法。
 */
