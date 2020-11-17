--select listprice, min(listprice), max(listprice) max_lp, count(*) over(partition by floor((max(listprice)-min(listprice))/10
--from AdventureWorksDW.dimproduct


CREATE PROCEDURE [AppAdmin].[ti_analyze_FrequencyDist_sp]
@schemaname VARCHAR(100),
@tablename VARCHAR(100),
@valuecolumn VARCHAR(100)
AS
BEGIN
/**************************************************************************
**  Version                : 1.0       
**  Author                 : Srimathi
** Description             : Data for histogram - frequency distribution with class intervals
** Date					   : 23-Aug-2019
02-Nov-2020	Srimathi	Enclose column name and tablename within square brackets

 
*******************************************************************************/

DECLARE @min FLOAT, @max FLOAT, @width INT, @width_rounded INT;
DECLARE @str NVARCHAR(2000);
DECLARE @lower_limit INT;
DECLARE @group INT;

SET @valuecolumn=QUOTENAME(REPLACE(REPLACE(@valuecolumn,'[',''),']',''));
SET @tablename=QUOTENAME(REPLACE(REPLACE(@tablename,'[',''),']',''));

	/*Finding the width*/
	SET @str = 'SELECT @class_width = FLOOR((MAX(' + @valuecolumn + ') - MIN(' + @valuecolumn + ') +2)/10) + 1 FROM ' + @schemaname + '.' + @tablename;
	EXECUTE sp_executesql @str, N'@class_width INT OUTPUT', @class_width = @width OUTPUT;
	
	/*Rounding the width*/
	SET @str = 'SELECT @width_round = (FLOOR(' + CONVERT(VARCHAR,@width) + ' / POWER(10,LEN(CONVERT(VARCHAR,' + CONVERT(VARCHAR,@width) + '))-1)) + 1 )* POWER(10,LEN(CONVERT(VARCHAR,' + CONVERT(VARCHAR,@width) + '))-1)'
	EXECUTE sp_executesql @str, N'@width_round INT OUTPUT', @width_round = @width_rounded OUTPUT;
	
	/*Finding lower limit of first class interval*/
	SET @str = 'SELECT @low = FLOOR(MIN(' + @valuecolumn + ')/' + CONVERT(varchar,@width_rounded) + ') * ' + CONVERT(varchar,@width_rounded) + ' FROM ' + @schemaname + '.' + @tablename
	EXECUTE sp_executesql @str, N'@low INT OUTPUT', @low = @lower_limit OUTPUT;
	
	/*Frequency distribution generation */
	SET @str = 'SELECT FLOOR(' + @valuecolumn + ' / ' + CONVERT(VARCHAR,@width_rounded) + ') * ' + CONVERT(VARCHAR,@width_rounded) + ' Lower,
	(FLOOR(' + @valuecolumn + ' / ' + CONVERT(VARCHAR,@width_rounded) + ') + 1) * ' + CONVERT(VARCHAR,@width_rounded) + ' upper, 
	COUNT(*) Frequency
	FROM ' + @schemaname + '.' + @tablename + ' GROUP BY FLOOR(' + @valuecolumn + ' / ' + CONVERT(VARCHAR,@width_rounded) + ') 
	ORDER BY FLOOR(' + @valuecolumn + ' / ' + CONVERT(VARCHAR,@width_rounded) + ')';
	
	EXECUTE sp_executesql @str;
	

END