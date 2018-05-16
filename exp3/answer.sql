/*
http://www.doc88.com/p-6367672222799.html
 */

drop database if exists salesdb;

create database salesdb
  character set utf8mb4
  collate utf8mb4_unicode_ci;

use salesdb;
CREATE TABLE salerecords
(
  id     int PRIMARY KEY AUTO_INCREMENT,
  name   varchar(255),
  price  decimal(10, 2) NOT NULL,
  number int DEFAULT 0  NOT NULL
);

delimiter ;;
create procedure
  defaultInsert(in pId     int, in pName varchar(255), in pPrice decimal(10, 2),
                in pNumber int)
  begin
    insert into salerecords (id, name, price, number)
      value (pId, pName, pPrice, pNumber);
  end;
;;
delimiter ;
call defaultInsert(1, '苹果', 3.33, 2831);
call defaultInsert(2, '梨', 4.21, 1234);
call defaultInsert(3, '葡萄', 1.66, 4321);
select *
from salerecords;

delimiter ;;
create procedure
  insertHundred(in pName varchar(255))
  begin
    declare maxId int;
    declare nextId int;
    declare minPrice decimal(10, 2);
    declare nextPrice decimal(10, 2);
    declare randomNumber int;
    declare i int;
    select max(id)
    from salerecords
    into maxId;
    select min(price)
    from salerecords
    into minPrice;
    set i = 0;
    set nextId = IFNULL(maxId, 0) + 1;
    set nextPrice = IFNULL(minPrice, 0) + 1;
    while i < 100 do
      set randomNumber = floor(rand() * 10000);
      insert into salerecords (id, name, price, number)
        value (nextId, pName, nextPrice, randomNumber);
      set nextId = nextId + 1;
      set nextPrice = nextPrice + 1;
      set i = i + 1;
    end while;
  end;
;;
delimiter ;
call insertHundred('西瓜');
select *
from salerecords
limit 10;

delimiter ;;
create procedure
  deleteBetween(in minId int, in maxId int)
  begin
    delete from salerecords
    where id between minId and maxId
          and id % 2 = 0;
  end;
;;
delimiter ;
call deleteBetween(4, 10);
select *
from salerecords
limit 10;

delimiter ;;
create event insertEvent
  on schedule
    every 3 second
do
  insert into salerecords (name, price, number)
    value ('木瓜', 10.01, 2345);
;;
create event cleanEvent
  on schedule
    every 30 second
do
  truncate table salerecords;
;;
delimiter ;
set global event_scheduler = true;
select count(*)
from salerecords;

set global event_scheduler = false;
truncate table salerecords;
delimiter ;;
CREATE TABLE sale_backup
(
  id     int PRIMARY KEY AUTO_INCREMENT,
  name   varchar(255),
  price  decimal(10, 2) NOT NULL,
  number int DEFAULT 0  NOT NULL
);
;;
create trigger backupTrigger
  after insert
  on salerecords
  for each row
  begin
    insert into sale_backup value (NEW.id, NEW.name, NEW.price, NEW.number);
  end;
;;
delimiter ;
call insertHundred('西瓜');
select *
from sale_backup
limit 10;

drop trigger backupTrigger;
truncate table salerecords;
START TRANSACTION;
insert into salerecords (name, price, number)
  value ('瓜子', 0.10, 1314520);
insert into salerecords (name, price, number)
  value ('核桃', 1.11, 321456);
savepoint state;
insert into salerecords (name, price, number)
  value ('开心果', 0.80, 654321);
rollback to state;
commit;
select * from salerecords;

/*
共享锁【S锁】
又称读锁，若事务T对数据对象A加上S锁，则事务T可以读A但不能修改A，其他事务只能再对A加S锁，而不能加X锁，直到T释放A上的S锁。
这保证了其他事务可以读A，但在T释放A上的S锁之前不能对A做任何修改。
排他锁【X锁】
又称写锁。若事务T对数据对象A加上X锁，事务T可以读A也可以修改A，其他事务不能再对A加任何锁，直到T释放A上的锁。
这保证了其他事务在T释放A上的锁之前不能再读取和修改A。
 */

/*
mysql5.6以下版本判断是否支持分区功能，
 */
show variables like 'have_partitioning';
/*
mysql5.6以上版本判断是否支持分区功能，
 */
show plugins;

alter table salerecords
partition by range (id) (
partition p0 values less than (10),
partition p1 values less than (20),
partition p2 values less than (40),
partition p3 values less than (80),
partition p4 values less than (160)
);

truncate table salerecords;
call insertHundred('樱桃');
select
  PARTITION_NAME,
  TABLE_ROWS
from information_schema.PARTITIONS
where TABLE_NAME = 'salerecords';

alter table salerecords
partition by hash (id)
partitions 5;

truncate table salerecords;
call insertHundred('樱桃');
select
  PARTITION_NAME,
  TABLE_ROWS
from information_schema.PARTITIONS
where TABLE_NAME = 'salerecords';

alter table salerecords
  remove partitioning;
drop database if exists salesdb;

/*
在题目1.3执行时，出现语法错误，
后来发现是没有设置分隔符，
说明多行的操作比如存储过程，事件调度，触发器，都设置非默认的分隔符才行，
在题目3.1执行时，总是出现‘Duplicate entry '127' for key 'PRIMARY'’，
后来发现是前面的备份触发器没有关闭，当我清空了salerecords却没有清空sale_backup后插入数据时sale_backup的主键就会冲突，
停止触发器‘drop trigger backupTrigger;’就没事了，
在题目4.1执行时，我先判断当前mysql服务是否支持分区，
原本是打印变量'have_partitioning'判断，
但是mysql5.7不再支持这种方式判断，
改用‘show plugins;’打印插件列表看是否有‘partition’插件来判断，
结果显示确实支持分区功能，
*/
/*
掌握了创建MySQL存储过程的创建方法，掌握MySQL事件调度器的使用。
掌握了MySQL触发器的定义方法，MySQL的事务控制方法，回滚操作。
掌握了利用分区技术实现MySQL的数据存储方法。
 */
