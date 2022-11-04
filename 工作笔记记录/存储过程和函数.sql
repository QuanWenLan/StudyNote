CREATE TABLE `user_uuid_map` (
  `user_id` varchar(50) COLLATE utf8mb4_bin NOT NULL,
  `web_uuid` varchar(200) COLLATE utf8mb4_bin NOT NULL,
  PRIMARY KEY (`user_id`,`web_uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `user_home_log` (
  `user_id` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL,
  `time` datetime NOT NULL,
  `page` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL,
  `category1` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL,
  `category2` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL,
  `item_id` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL,
  `row_id` int(11) NOT NULL AUTO_INCREMENT,
  `prom_ref_id` int(11) DEFAULT NULL,
  `web_uuid` varchar(200) COLLATE utf8mb4_bin DEFAULT NULL,
  PRIMARY KEY (`row_id`)
) ENGINE=InnoDB AUTO_INCREMENT=19575 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;
-- 插入数据
INSERT INTO etwtp_hs.user_home_log (user_id,`time`,page,category1,category2,item_id,prom_ref_id,web_uuid) VALUES 
('20220507','2022-05-06 15:33:23','aboutpurchase',NULL,NULL,NULL,NULL,NULL)
,('20220506','2022-05-06 15:33:16','accountAndSetting',NULL,NULL,NULL,NULL,NULL)
,('vin002','2022-05-06 15:32:25','clientMessage',NULL,NULL,NULL,NULL,NULL)
,('admin','2022-05-06 14:08:05','login',NULL,NULL,NULL,NULL,NULL)
,('MarkMa','2022-05-06 11:08:50','clientMessage',NULL,NULL,NULL,NULL,NULL)
('20220508','2022-05-06 15:43:20','clientMessage',NULL,NULL,NULL,NULL,NULL)
;
/**
 * 1 DROP FUNCTION IF EXISTS generateUuid; 先删除
 * 2 DELIMITER //
 * 3 执行时，选中create 到 end
 * 4 再执行 DELIMITER ;
 */
/* 1 删除函数 generateUuid */ 
DROP FUNCTION IF EXISTS generateUuid;
/* 2 设置结束符为 // */ 
DELIMITER //
/* 3 删除函数 generateUuid */ 
CREATE FUNCTION generateUuid(str varchar(100), timeValue varchar(100)) 
  RETURNS varchar(3000) DETERMINISTIC 
  BEGIN 
	DECLARE uuid varchar(3000) DEFAULT '';
	DECLARE i int;
	DECLARE d int;
	SET d = unix_timestamp(timeValue);
 	set @str = str;
 	SET @len = char_length(@str);
 	SET i = 1;
 	WHILE (i <= @len) DO
 		SET @r = (rand() * 16 + d) % 16 | 0;
 		SET d = floor(d / 16); 
 		SET @curS = substring(@str, i, 1);
 		SET @needConvert = '';
 		IF @curS = 'x' THEN 
 			SET @needConvert = @r;
 			SET uuid = concat(uuid, lower(conv(@needConvert, 10, 36)));
 		ELSEIF @curS = 'y' THEN  
 			SET @needConvert = @r & 0x3 | 0x8;
 			SET uuid = concat(uuid, lower(conv(@needConvert, 10, 36)));
 		ELSE
 			SET @needConvert = concat(@needConvert, @curS);
 			SET uuid = concat(uuid, @needConvert);
 		END IF;
 		SET i = i + 1;
 	END WHILE;
 	RETURN uuid;
  END
//
/* 4 将结束符置为;*/ 
DELIMITER ;

SELECT generateUuid('xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx','2022-11-02 00:00:00');
SELECT lower(hex(10));
SELECT conv("7", 10, 36);
SELECT (rand() * 16 + 1000) % 16 | 0;
SELECT substring('xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx', 1,1); 



select date_add('1970-01-01 8:00:00',interval 1303191235 second);
select from_unixtime(1303191235);
select unix_timestamp('1970-1-1 6:00:00');  
select unix_timestamp('1970-1-1 8:00:01');
select unix_timestamp('1970-1-1 8:01:00');
SELECT CURRENT_TIMESTAMP();
select unix_timestamp();
select unix_timestamp(CURRENT_TIMESTAMP());
select unix_timestamp('2022-11-02 00:00:00') AS cur;

SELECT * FROM user_uuid_map ;
/**
 * 1 DROP FUNCTION IF EXISTS addUserUuidMapProcedure; 先删除
 * 2 DELIMITER //
 * 3 执行时，选中create 到 end
 * 4 再执行 DELIMITER ;
 * 5 调用 CALL addUserUuidMapProcedure();
 */
/* 1 如果存储过程存在则删除*/ 
DROP PROCEDURE IF EXISTS addUserUuidMapProcedure;
/* 2 设置结束符为 // */ 
DELIMITER // 
/* 3 创建存储过程 addUserUuidMapProcedure */ 
CREATE PROCEDURE addUserUuidMapProcedure()
	BEGIN
		DECLARE user_id_value varchar(50);
		DECLARE flag int DEFAULT 0;
		# 申明一个游标来记录 sql 的查询结果
		DECLARE user_id_list CURSOR FOR SELECT user_id FROM user_home_log GROUP BY user_id ;
		# 建立一个循环退出标志，当游标遍历完后将flag的值设置为1
		DECLARE CONTINUE handler FOR NOT FOUND SET flag = 1;
		# 打开游标
		OPEN user_id_list;
			# 将游标中的值赋给定义好的变量，实现循环
			FETCH user_id_list INTO user_id_value;
			WHILE flag <> 1 do 
				# 获取uuid
				SET @uuid = '';
				SELECT generateUuid('xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx','2022-11-02 00:00:00') INTO @uuid ;
				# 插入一条数据
				INSERT INTO user_uuid_map (`user_id`, `web_uuid`) VALUES (user_id_value, @uuid);
				# 游标往后移
				FETCH user_id_list INTO user_id_value;
			END WHILE ;
		CLOSE user_id_list;
	END //
/* 4 将结束符置为;*/ 
DELIMITER ;
/* 5 调用 */
CALL addUserUuidMapProcedure();