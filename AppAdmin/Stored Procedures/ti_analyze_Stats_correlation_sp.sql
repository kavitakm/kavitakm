CREATE PROCEDURE [AppAdmin].[ti_analyze_Stats_correlation_sp]
@schemaname VARCHAR(100),
@tablename VARCHAR(100),
@valuecolumn1 VARCHAR(100),
@valuecolumn2 VARCHAR(100)
AS
BEGIN

/**************************************************************************
**  Version                : 1.0       
**  Author                 : Srimathi
** Description             : Calculate Correlation Coefficient between two numeric columns of a table
** Date					   : 23-Aug-2019
 
*******************************************************************************/

DECLARE @str NVARCHAR(1000);
DECLARE @numerator numeric(38,5);
DECLARE @denominator1 numeric(38,5);
DECLARE @denominator2 numeric(38,5);
DECLARE @N	int;
DECLARE @R numeric(38,5);

	SET @str = 'SELECT @CT = COUNT(*) FROM ' + @schemaname + '.' + @tablename + ' WHERE ' + @valuecolumn1 + ' IS NOT NULL AND ' + @valuecolumn2 + ' IS NOT NULL';
	EXECUTE sp_executesql @str, N'@CT INT OUTPUT', @N OUTPUT;
	--PRINT @str;
	
	SET @str = 'SELECT @NUM = (CONVERT(NUMERIC(38,5),@N) * SUM(CONVERT(NUMERIC(38,5),' + @valuecolumn1 + ') * CONVERT(NUMERIC(38,5),' + @valuecolumn2 + '))) - (SUM(CONVERT(NUMERIC(38,5),'+ @valuecolumn1 + ')) * SUM(CONVERT(NUMERIC(38,5),' + @valuecolumn2 + '))),@DENSQ1 = (CONVERT(NUMERIC(38,5),@N) * SUM(SQUARE(CONVERT(NUMERIC(38,5),' + @valuecolumn1 + ')))) - SQUARE(SUM(CONVERT(NUMERIC(38,5),' + @valuecolumn1 + '))), @DENSQ2 = (CONVERT(NUMERIC(38,5),@N) * SUM(SQUARE(CONVERT(NUMERIC(38,5),' + @valuecolumn2 + ')))) - SQUARE(SUM(CONVERT(NUMERIC(38,5),' + @valuecolumn2 + '))) FROM ' + @schemaname + '.' + @tablename + ' WHERE ' + @valuecolumn1 + ' IS NOT NULL AND ' + @valuecolumn2 + ' IS NOT NULL';

	EXECUTE sp_executesql @str, N'@N int, @NUM NUMERIC(38,5) OUTPUT, @DENSQ1 NUMERIC(38,5) OUTPUT, @DENSQ2 NUMERIC(38,5) OUTPUT', @N, @numerator OUTPUT, @denominator1 OUTPUT, @denominator2 OUTPUT;
--print @str	
	SET @str = 'SELECT CASE WHEN @denominator1 <> 0 and @denominator2 <> 0 THEN CONVERT(NUMERIC(38,5),@Num / (SQRT(@denominator1) * sqrt(@denominator2))) ELSE NULL END AS CORRELATION'
	print @str;
	EXECUTE sp_executesql @str, N'@denominator1 NUMERIC(38,5), @denominator2 NUMERIC(38,5), @Num NUMERIC(38,5)', @denominator1, @denominator2, @Numerator
	
END