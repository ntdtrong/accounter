create database manager;
use manager;
create table categories
(
id int primary key auto_increment,
name nvarchar(100)
);

create table daily
(
id int primary key auto_increment,
category_id int,
value int,
day int,
month int,
year int
);

create table monthly
(
id int primary key auto_increment,
category_id int,
value int,
day int,
month int,
year int
);

create table yearly
(
id int primary key auto_increment,
category_id int,
value int,
day int,
month int,
year int
);

create table details
(
id int primary key auto_increment,
dayly_id int,
category_id int,
value int,
description nvarchar(500),
day int,
month int,
year int
);

-- insert_details
DELIMITER $$
CREATE PROCEDURE insert_details
(
	category_id int,
	value int,
	description nvarchar(500),
	day int,
	month int,
	year int
)
BEGIN
	insert into details (category_id, value, description, day, month, year)
	values (category_id, value, description, day, month, year);

	call insert_daily(category_id, value, day, month, year);
	call insert_monthly(category_id, value, month, year);
	call insert_yearly(category_id, value, year);
	
END$$
DELIMITER ;

-- insert_daily
DELIMITER $$
CREATE PROCEDURE insert_daily
(
	p_category_id int,
	p_value int,
	p_day int,
	p_month int,
	p_year int
)
BEGIN
	DECLARE has INT default -1;
	DECLARE oldValue INT default -1;
	select daily.id, daily.value into has, oldValue from daily where 
	daily.category_id = p_category_id and 
	daily.day = p_day and
	daily.month = p_month and
	daily.year = p_year;
	
	if has = -1 then
		insert into daily (category_id, value, day, month, year)
		values (p_category_id, p_value, p_day, p_month, p_year);
	else
		update daily 
		set
			value = (oldValue + p_value)
		where id = has ;
	end if;

END$$
DELIMITER ;

-- insert_monthly
DELIMITER $$
CREATE PROCEDURE insert_monthly
(
	p_category_id int,
	p_value int,
	p_month int,
	p_year int
)
BEGIN
	DECLARE has INT default -1;
	DECLARE oldValue INT default -1;
	select id, value into has, oldValue from monthly where 
	category_id = p_category_id and 
	month = p_month and
	year = p_year;
	
	if has = -1 then
		insert into monthly (category_id, value, month, year)
		values (p_category_id, p_value, p_month, p_year);
	else
		update monthly 
		set
			value = (oldValue + p_value)
		where id = has ;
	end if;

END$$
DELIMITER ;

-- insert_yearly
DELIMITER $$
CREATE PROCEDURE insert_yearly
(
	p_category_id int,
	p_value int,
	p_year int
)
BEGIN
	DECLARE has INT default -1;
	DECLARE oldValue INT default -1;
	select id, value into has, oldValue from yearly where 
	category_id = p_category_id and 
	year = p_year;
	
	if has = -1 then
		insert into yearly (category_id, value, year)
		values (p_category_id, p_value, p_year);
	else
		update yearly 
		set
			value = (oldValue + p_value)
		where id = has ;
	end if;

END$$
DELIMITER ;


call insert_details(2, 100, 'nhau chieu', 10, 8, 2012);

select * from details;

select * from daily;

select * from monthly;

select * from yearly;

delete from daily where id >= 1;


