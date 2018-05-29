/*
http://www.doc88.com/p-5671528620905.html
https://wenku.baidu.com/view/106d3fb9900ef12d2af90242a8956bec0875a566.html
 */

drop database if exists mall_B14040417;

create database mall_B14040417
  character set utf8mb4
  collate utf8mb4_unicode_ci;
use mall_B14040417;

-- auto-generated definition
create table user
(
  id        int auto_increment
    primary key,
  phone     varchar(255)                  not null
  comment '手机号',
  real_name varchar(255)                  not null
  comment '真名',
  purchase  decimal(10, 2) default '0.00' not null
  comment '消费总额',
  address   varchar(255)                  not null
  comment '地址'
)
  engine = InnoDB;

-- auto-generated definition
create table store
(
  id         int auto_increment
    primary key,
  store_name varchar(255)                  not null
  comment '商户名称',
  sales      decimal(10, 2) default '0.00' null
  comment '营业额',
  address    varchar(255)                  not null
  comment '地址',
  phone      varchar(255)                  null
  comment '手机号'
)
  engine = InnoDB;

-- auto-generated definition
create table goods
(
  id          int auto_increment
    primary key,
  store_id    int            not null
  comment '对应商户id
	',
  goods_name  varchar(255)   not null
  comment '商品名',
  goods_price decimal(10, 2) not null
  comment '商品单价',
  constraint goods_store_id_fk
  foreign key (store_id) references store (id)
    ON DELETE CASCADE
)
  engine = InnoDB;

-- auto-generated definition
create table `order`
(
  id       int auto_increment
    primary key,
  store_id int                                                          not null
  comment '商户的id',
  user_id  int                                                          not null
  comment '客户的id',
  add_time timestamp default CURRENT_TIMESTAMP                          not null
  comment '订单生成的时间',
  status   enum ('待付款', '待发货', '待收货', '完成', '退货中', '已退货') default '待付款' not null
  comment '订单状态，是否已付款',
  constraint order_store_id_fk
  foreign key (store_id) references store (id)
    ON DELETE CASCADE,
  constraint order_user_id_fk
  foreign key (user_id) references user (id)
    ON DELETE CASCADE
)
  engine = InnoDB;

-- auto-generated definition
create table order_goods
(
  order_id int             not null,
  goods_id int             not null,
  count    int default '1' not null,
  primary key (order_id, goods_id),
  constraint order_goods_order_id_fk
  foreign key (order_id) references `order` (id)
    ON DELETE CASCADE,
  constraint order_goods_goods_id_fk
  foreign key (goods_id) references goods (id)
    ON DELETE CASCADE
)
  comment '订单中的商品列表'
  engine = InnoDB;


INSERT INTO `store` (`store_name`, `address`, `phone`) VALUES ('荣耀官方旗舰店', '广东, 深圳', '13123455922');
INSERT INTO `store` (`store_name`, `address`, `phone`) VALUES ('九牧王官方旗舰店', '福建, 厦门', '13123431917');
UPDATE `store` t
SET t.`phone` = '13123481480'
WHERE t.`id` = 2;


INSERT INTO `goods` (`store_id`, `goods_name`, `goods_price`)
VALUES (1, '【618狂欢】华为honor/荣耀 荣耀V10智能拍照商务手机官方旗舰店', '3299.00 ');
INSERT INTO `goods` (`store_id`, `goods_name`, `goods_price`) VALUES (1, '【6期免息】荣耀分布式路由器高速光纤无线别墅大户家用穿墙wifi', '899.00');
INSERT INTO `goods` (`store_id`, `goods_name`, `goods_price`) VALUES (2, '九牧王休闲裤男 夏季新款男裤青中年男士商务直筒宽松长裤子男装', '259.00');
INSERT INTO `goods` (`store_id`, `goods_name`, `goods_price`)
VALUES (2, '九牧王男装 2018夏季商务休闲翻领男士半袖短袖T恤男修身polo衫', '179.00');
UPDATE `goods` t
SET t.`goods_price` = '224.00'
WHERE t.`id` = 3;

INSERT INTO `user` (`phone`, `real_name`, `address`) VALUES ('13123463840', '漕宏博', '徐州市');
INSERT INTO `user` (`phone`, `real_name`, `address`) VALUES ('13123496158', '谢鸿才', '包头市');
INSERT INTO `user` (`phone`, `real_name`, `address`) VALUES ('13123474293', '钱致远', '保定市');
INSERT INTO `user` (`phone`, `real_name`, `address`) VALUES ('13123447668', '方志国', '泉州市');
UPDATE `user` t
SET t.`address` = '惠州市'
WHERE t.`id` = 3;

/*
 * 用户下订单，
 */
START TRANSACTION;
INSERT INTO `order` (`store_id`, `user_id`) VALUES (1, 1);
set @orderId = LAST_INSERT_ID();
INSERT INTO `order_goods` (`order_id`, `goods_id`) VALUES (@orderId, 1);
INSERT INTO `order_goods` (`order_id`, `goods_id`) VALUES (@orderId, 2);
commit;

/*
 * 用户付款，
 */
delimiter ;;
create procedure
  payed(in iOrderId int)
  begin
    select @cost := sum(goods_price)
    from `order`
      left join order_goods o on `order`.id = o.order_id
      left join goods g on o.goods_id = g.id
    where `order`.id = iOrderId;
    update user
    set purchase = purchase + @cost
    where id = (select user_id
                from `order`
                where id = iOrderId);
    UPDATE `order` t
    SET t.`status` = '待发货'
    WHERE t.`id` = iOrderId;
  end;
;;
delimiter ;
call payed(@orderId);

/*
 * 商家发货，
 */
delimiter ;;
create procedure
  sent(in iOrderId int)
  begin
    UPDATE `order` t
    SET t.`status` = '待收货'
    WHERE t.`id` = iOrderId;
  end;
;;
delimiter ;
call sent(@orderId);

/*
 * 用户确认收货，
 */
delimiter ;;
create procedure
  received(in iOrderId int)
  begin
    select @cost := sum(goods_price * count)
    from `order`
      left join order_goods o on `order`.id = o.order_id
      left join goods g on o.goods_id = g.id
    where `order`.id = iOrderId;
    update store
    set sales = sales + @cost
    where id = (select store_id
                from `order`
                where id = iOrderId);
    UPDATE `order` t
    SET t.`status` = '完成'
    WHERE t.`id` = iOrderId;
  end;
;;
delimiter ;
call received(@orderId);

/*
 * 用户选择退货，
 */
delimiter ;;
create procedure
  returning(in iOrderId int)
  begin
    select @cost := sum(goods_price * count)
    from `order`
      left join order_goods o on `order`.id = o.order_id
      left join goods g on o.goods_id = g.id
    where `order`.id = iOrderId;
    update user
    set purchase = purchase - @cost
    where id = (select user_id
                from `order`
                where id = iOrderId);
    update store
    set sales = sales - @cost
    where id = (select store_id
                from `order`
                where id = iOrderId);
    UPDATE `order` t
    SET t.`status` = '退货中'
    WHERE t.`id` = iOrderId;
  end;
;;
delimiter ;
call returning(@orderId);

/*
 * 商家收到退货，
 */
delimiter ;;
create procedure
  returned(in iOrderId int)
  begin
    UPDATE `order` t
    SET t.`status` = '已退货'
    WHERE t.`id` = iOrderId;
  end;
;;
delimiter ;
call returned(@orderId);

/*
 * 确认商户销售总额与订单中的一致，
 */
delimiter ;;
create procedure
  checkSales(in iStoreId int, out oCheck boolean)
  begin
    /* 总额相等就输出1, */
    set oCheck = (select sales = COALESCE(sum(goods_price * count), 0.00)
                  from store
                    left join `order` on store.id = `order`.store_id
                                         and `order`.status in ('完成')
                    left join order_goods o on `order`.id = o.order_id
                    left join goods g on o.goods_id = g.id
                  where store.id = iStoreId
                  group by store.id);
  end;
;;
delimiter ;
call checkSales(1, @sCheck);
select @sCheck;

/*
 * 确认用户消费总额与订单中的一致，
 */
delimiter ;;
create procedure
  checkPurchase(in iUserId int, out oCheck boolean)
  begin
    /* 总额相等就输出1, */
    set oCheck = (select purchase = COALESCE(sum(goods_price * count), 0.00)
                  from user
                    left join `order` on user.id = `order`.user_id
                                         and `order`.status in ('待发货', '待收货', '完成')
                    left join order_goods o on `order`.id = o.order_id
                    left join goods g on o.goods_id = g.id
                  where user.id = iUserId
                  group by user.id);
  end;
;;
delimiter ;
call checkPurchase(1, @sCheck);
select @sCheck;

/*
 * 一个月销售总额最多的商家，为了测试，先重新完成了一个订单，
 */
delimiter ;;
create procedure
  winnerStore(out oWinnerStoreId int)
  begin
    select
      @sId := store.id,
      COALESCE(sum(goods_price * count), 0.00) as monthEarn
    from store
      left join `order` on store.id = `order`.store_id
                           and `order`.add_time >= DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 1 MONTH)
                           and `order`.status in ('完成')
      left join order_goods o on `order`.id = o.order_id
      left join goods g on o.goods_id = g.id
    group by store.id
    order by monthEarn desc
    limit 1;
    set oWinnerStoreId = @sId;
  end;
;;
delimiter ;
call winnerStore(@winnerStoreId);
select @winnerStoreId;


/*
 * 商家所有商品中订单总金额最多的商品，
 */
delimiter ;;
create procedure
  winnerGoods(in iStoreId int, out oWinnerGoodsId int)
  begin
    select
      @gId := g.id,
      COALESCE(sum(goods_price * count), 0.00) as totalPrice
    from store
      left join `order` on store.id = `order`.store_id
                           and `order`.status in ('完成')
      left join order_goods o on `order`.id = o.order_id
      left join goods g on o.goods_id = g.id
    where store.id = iStoreId
    group by g.id
    ORDER BY totalPrice desc
    limit 1;
    set oWinnerGoodsId = @gId;
  end;
;;
delimiter ;
call winnerGoods(@winnerStoreId, @winnerGoodsId);
select @winnerGoodsId;

/*
 * 为了测试备份订单表先删除订单表数据，
 */
delete from `order`;
/*
 * 备份订单表，
 */
delimiter ;;
-- auto-generated definition
create table order_backup
(
  id       int auto_increment
    primary key,
  store_id int                                                          not null
  comment '商户的id',
  user_id  int                                                          not null
  comment '客户的id',
  add_time timestamp default CURRENT_TIMESTAMP                          not null
  comment '订单生成的时间',
  status   enum ('待付款', '待发货', '待收货', '完成', '退货中', '已退货') default '待付款' not null
  comment '订单状态，是否已付款',
  constraint order_backup_store_id_fk
  foreign key (store_id) references store (id)
    ON DELETE CASCADE,
  constraint order_backup_user_id_fk
  foreign key (store_id) references user (id)
    ON DELETE CASCADE
)
  engine = InnoDB;
create index order_backup_store_id_fk
  on `order_backup` (store_id);
;;
create trigger backupTrigger
  after insert
  on `order`
  for each row
  begin
    insert into order_backup value (NEW.id, NEW.store_id, NEW.user_id, NEW.add_time, NEW.status);
  end;
;;
delimiter ;
/*
 * 用户重新下订单，
 */
START TRANSACTION;
INSERT INTO `order` (`store_id`, `user_id`) VALUES (1, 1);
set @orderId = LAST_INSERT_ID();
INSERT INTO `order_goods` (`order_id`, `goods_id`) VALUES (@orderId, 3);
INSERT INTO `order_goods` (`order_id`, `goods_id`) VALUES (@orderId, 2);
commit;


/*
当订单表中数据过多时，查询效率低下，要考虑优化，
首先是合理建索引，比如如果需要根据订单创建时间查询订单，就可以给订单的创建时间字段建立索引加块查询效率，
  如果频繁统计特定商家的订单，可以考虑给订单的商家id建立索引加块查询效率，
然后是优化检索的sql语句，重点在于联表查询时是否确实用上了建立的索引，几种join方式是否选择正确，
另外还有缓存和锁的优化，合理配置缓存提高缓存命中率，以及确保不发生死锁的情况尽量使用行锁保证并发效率，
 */
/*
以在订单表中建立创建时间的索引为例，
 */
CREATE INDEX order_add_time_index
  ON `order` (add_time);

/*
定时通过mysqldump完整导出数据库数据，
开启log_bin功能以防万一恢复数据，
比如可以每天mysqldump导出数据库，并删除此前的log_bin日志以防日志过大，
发生灾难时通过mysqldump备份的数据库恢复到前一个正常备份，
再通过log_bin恢复到灾难发生前的正常数据，
 */
/*
# 备份数据库，
mysqldump mall_B14040417 -rdump.sql -uroot -prootlocal
# 恢复数据库，
mysql mall_B14040417 -uroot -prootlocal < dump.sql
# 恢复log_bin,
sudo mysqlbinlog --no-defaults  --start-position=1734  --stop-position=2026 /var/lib/mysql/mysql-bin.000001 |mysql -uroot -prootlocal mall_B14040417
 */

# drop database if exists mall_B14040417;
