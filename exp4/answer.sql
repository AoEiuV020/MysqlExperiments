/*
https://blog.csdn.net/king_kgh/article/details/74800513
要先开启binlog功能，在Mysql配置修改并重启，
http://www.cnblogs.com/cobbliu/p/4311926.html
mysqlbinlog有编码问题，
https://blog.csdn.net/king_kgh/article/details/74890381
 */

reset master;
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

insert into salerecords (name, price, number)
  value ('瓜子', 0.10, 1314520);
insert into salerecords (name, price, number)
  value ('核桃', 1.11, 321456);
insert into salerecords (name, price, number)
  value ('开心果', 0.80, 654321);
select *
from salerecords;
show binlog events;

/*
mysqldump salesdb -rdump.sql -uroot -prootlocal
 */

show variables like 'log_bin';
insert into salerecords (name, price, number)
  value ('木瓜', 10.01, 2345);
select *
from salerecords;
select now();
show binlog events;

drop database salesdb;

create database salesdb
  character set utf8mb4
  collate utf8mb4_unicode_ci;
/*
mysql salesdb -uroot -prootlocal < dump.sql
 */
use salesdb;
select *
from salerecords;

flush logs;
/*
sudo mysqlbinlog --no-defaults  --start-position=1832  --stop-position=2155 /var/lib/mysql/mysql-bin.000001 |mysql -uroot -prootlocal

sudo mysqlbinlog --no-defaults --start-datetime='2018-05-15 18:50:08' --stop-datetime='2018-05-15 18:50:43' /var/lib/mysql/mysql-bin.000001 |mysql -uroot -prootlocal
sudo mysqlbinlog --no-defaults --stop-datetime='2018-05-15 18:27:57' /var/lib/mysql/mysql-bin.000001 |mysql -uroot -prootlocal
sudo mysqlbinlog --no-defaults --start-datetime='2018-05-15 18:27:51' /var/lib/mysql/mysql-bin.000001 |mysql -uroot -prootlocal
sudo mysqlbinlog --no-defaults /var/lib/mysql/mysql-bin.000001 |mysql -uroot -prootlocal
 */

create user 'zl'@'localhost'
  identified by 'zl';
grant select on *.* TO 'zl'@'localhost';
flush privileges;

revoke all privileges on *.* from 'zl'@'localhost';
grant select on salesdb.* TO 'zl'@'localhost';
flush privileges;


drop user 'zl'@'localhost';

/**
在题目2.3执行时，发现没有启用log_bin功能，
而且mysql5.6以上启用log_bin需要多一个server-id的配置，
最后正确启用然后重来，
在题目2.3执行时，总是报错“mysqlbinlog: [ERROR] unknown variable 'default-character-set=utf8mb4'”
最后给mysqlbinlog加上参数“--no-defaults”解决，
 */
