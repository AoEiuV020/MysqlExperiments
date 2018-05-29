/*
https://wenku.baidu.com/view/28210e4c84868762cbaed519.html
https://wenku.baidu.com/view/99791711cdbff121dd36a32d7375a417876fc144.html
不明白该写些什么，感觉符合要求的话可以写成论文或者毕业设计了，但这只是一个小实验啊，
直接上er图和sql代码，
 */

drop database if exists trains_system;

create database trains_system
  character set utf8mb4
  collate utf8mb4_unicode_ci;
use trains_system;


/*
1. 信息需求
用户需要能查询到列车信息，票价信息，
管理员需要能查询到用户信息，
2. 功能需求
a. 对车次的查询，要包括车名、出发地、目的地、经过站点、开出时刻、到站时刻、票价，
  对于用户根据出发地、目的地的查询，要能查到经过这两个站点但不是始发站终点站的车次，
  因此应该另建一张表保存车次经过的每个站点，以及票价，
  对于出发地到目的地票价的计算可以通过从始发站到目的地的票价减始发站到出发地的票价得到，
b. 对订单的查询，要包括车次信息，用户信息，开出时刻、到站时刻、票价，
c. 用户可以购票下订单，
3. 安全需求
a. 用户只能查询车次，不能修改
b. 管理员可以添加车次，
c. 密码要加密保存，
 */


create table admin
(
  id       int auto_increment
    primary key,
  username varchar(255) not null
  comment '账号名',
  password int          not null
  comment '密码'
)
  engine = InnoDB;

create table user
(
  id        int auto_increment
    primary key,
  phone     varchar(255) not null
  comment '手机号',
  password  varchar(255) not null
  comment '密码',
  real_name varchar(255) not null
  comment '真实姓名'
)
  engine = InnoDB;

create table station
(
  id   int auto_increment
    primary key,
  name int null
  comment '站点名'
)
  engine = InnoDB;

create table trains
(
  id                   int auto_increment
    primary key,
  departure_station_id int            not null
  comment '始发站id',
  arrival_station_id   int            not null
  comment '终点站id',
  price                decimal(10, 2) not null
  comment '票价',
  departure_time       datetime       not null
  comment '出发时间',
  arrival_time         datetime       not null
  comment '到达时间',
  train_name           varchar(255)   not null
  comment '列车名'
)
  comment '车次'
  engine = InnoDB;


create table ticket
(
  id                   int auto_increment
    primary key,
  user_id              int            not null,
  trains_id            int            not null
  comment '车次id',
  departure_station_id int            not null
  comment '上车站点',
  arrival_station_id   int            null
  comment '下车站点',
  price                decimal(10, 2) not null
  comment '从始发站到终点站的票价',
  constraint ticket_user_id_fk
  foreign key (user_id) references user (id),
  constraint ticket_trains_id_fk
  foreign key (trains_id) references trains (id),
  constraint ticket_station_id_fk
  foreign key (departure_station_id) references station (id),
  constraint ticket_station_id_fk_2
  foreign key (arrival_station_id) references station (id)
)
  engine = InnoDB;

create index ticket_station_id_fk
  on ticket (departure_station_id);

create index ticket_station_id_fk_2
  on ticket (arrival_station_id);

create index ticket_trains_id_fk
  on ticket (trains_id);

create index ticket_user_id_fk
  on ticket (user_id);

create table process
(
  trains_id      int            not null
  comment '车次id',
  station_id     int            not null
  comment '站点id',
  arrival_time   datetime       not null
  comment '到站时间',
  departure_time datetime       not null
  comment '离开时间',
  price          decimal(10, 2) not null
  comment '从始发站到本站的票价',
  primary key (trains_id, station_id),
  constraint process_trains_id_fk
  foreign key (trains_id) references trains (id),
  constraint process_station_id_fk
  foreign key (station_id) references station (id)
)
  comment '车次经过的站点'
  engine = InnoDB;

create index process_station_id_fk
  on process (station_id);


drop database if exists trains_system;


/*
原本打算只在车次信息里存票价，后来发现这样做的话无法在用户购票时找到列车过程一段的价格，
后来改成在车次经过的每个站点记录一个票价，记录从始发站到该站的票价，两个票价减一下就能得到用户出发地到目的地的票价，
 */