create database manager
go
use manager
go
create table categories
(
id int primary key identity(1,1),
name nvarchar(100)
)
go
create table daily
(
id int primary key identity(1,1),
category_id int,
value int,
day int,
month int,
year int
)
go

create table monthly
(
id int primary key identity(1,1),
category_id int,
value int,
month int,
year int
)
go
create table yearly
(
id int primary key identity(1,1),
category_id int,
value int,
year int
)

go
create table details
(
id int primary key identity(1,1),
category_id int,
value int,
description nvarchar(500),
day int,
month int,
year int
)
go


-- insert_details
CREATE PROCEDURE insert_details
(
	@category_id int,
	@value int,
	@description nvarchar(500),
	@day int,
	@month int,
	@year int
)
AS
BEGIN
	insert into details (category_id, value, description, day, month, year)
	values (@category_id, @value, @description, @day, @month, @year)

	exec insert_daily @category_id, @value, @day, @month, @year
	exec insert_monthly @category_id, @value, @month, @year
	exec insert_yearly @category_id, @value, @year
	
END
GO

-- update_details
CREATE PROCEDURE update_details
(
	@id int,
	@value int,
	@category_id int = 0,
	@description nvarchar(500) = null,
	@day int = 0,
	@month int = 0,
	@year int = 0
)
AS
BEGIN
	
	DECLARE @has INT
	DECLARE @_category_id INT
	DECLARE @_day INT
	DECLARE @_month INT
	DECLARE @_year INT
	DECLARE @_value INT
	DECLARE @change_value INT
	DECLARE @_description nvarchar(500)
	
	SET @has = -1

	select @has = id, @_category_id = category_id, @_value = value, @_day = day, @_month = month, @_year = year,
	@_description = description 
	from details where id = @id
	
	IF @has > -1
	BEGIN
		IF @category_id = 0
		BEGIN
			SET @category_id = @_category_id
		END

		IF @day = 0
		BEGIN
			SET @day = @_day
		END

		IF @month = 0
		BEGIN
			SET @month = @_month
		END

		IF @year = 0
		BEGIN
			SET @year = @_year
		END

		IF @description IS NULL
		BEGIN
			SET @description = @_description
		END

		SET @change_value = @value - @_value

		UPDATE details SET
		value = @value, day = @day, month = @month, year = @year, description = @description
		WHERE id = @id

		exec insert_daily @category_id, @change_value, @day, @month, @year
		exec insert_monthly @category_id, @change_value, @month, @year
		exec insert_yearly @category_id, @change_value, @year
	END
END
GO

-- insert_daily

CREATE PROCEDURE insert_daily
(
	@p_category_id int,
	@p_value int,
	@p_day int,
	@p_month int,
	@p_year int
)
AS
BEGIN
	DECLARE @has INT
	DECLARE @oldValue INT
	SET @has = -1
	SET @oldValue = -1
	select @has = id, @oldValue = value from daily where 
	daily.category_id = @p_category_id and 
	daily.day = @p_day and
	daily.month = @p_month and
	daily.year = @p_year
	
	if @has = -1
		BEGIN
			insert into daily (category_id, value, day, month, year)
			values (@p_category_id, @p_value, @p_day, @p_month, @p_year)
		END
	else
		BEGIN
			update daily 
			set
				value = (@oldValue + @p_value)
			where id = @has
		END
END
GO

-- insert_monthly

CREATE PROCEDURE insert_monthly
(
	@p_category_id int,
	@p_value int,
	@p_month int,
	@p_year int
)
AS
BEGIN
	DECLARE @has INT
	DECLARE @oldValue INT
	SET @has = -1
	SET @oldValue = -1
	select @has = id, @oldValue = value from monthly where 
	category_id = @p_category_id and 
	month = @p_month and
	year = @p_year
	
	if @has = -1
	BEGIN
		insert into monthly (category_id, value, month, year)
		values (@p_category_id, @p_value, @p_month, @p_year)
	END
	else
	BEGIN
		update monthly 
		set
			value = (@oldValue + @p_value)
		where id = @has ;
	END

END
GO

-- insert_yearly

CREATE PROCEDURE insert_yearly
(
	@p_category_id int,
	@p_value int,
	@p_year int
)
AS
BEGIN
	DECLARE @has INT
	DECLARE @oldValue INT
	SET @has = -1
	SET @oldValue = -1
	select @has = id, @oldValue = value from yearly where 
	category_id = @p_category_id and 
	year = @p_year
	
	if @has = -1
	BEGIN
		insert into yearly (category_id, value, year)
		values (@p_category_id, @p_value, @p_year)
	END
	else
	BEGIN
		update yearly 
		set
			value = (@oldValue + @p_value)
		where id = @has
	END
END
GO

--exec insert_details 2, 50, 'do xang', 1, 9, 2012
--go
--exec update_details 1, 100
--
--
--select * from details;
--
--select * from daily;
--
--select * from monthly;
--
--select * from yearly;

-- delete from monthly where id >= 1;


