/****** Object:  StoredProcedure [AppAdmin].[ti_analyze_GroupedBarChart_sp]    Script Date: 2/9/2021 6:24:25 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--exec [AppAdmin].[ti_analyze_GroupedBarChart_sp] 'sandbox','passenger','[Date]','[Gender]'  
--exec [AppAdmin].[ti_analyze_GroupedBarChart_sp] 'Sunitha','TestDataLoad','[STD_SLO]','[Supplies]'  
ALTER PROCEDURE [AppAdmin].[ti_analyze_GroupedBarChart_sp]  
@schemaname VARCHAR(100),  
@tablename VARCHAR(100),  
@column1Name VARCHAR(100),  
@column2Name VARCHAR(100)  
  
AS  
BEGIN  
/**************************************************************************  
**  Version                : 1.0         
**  Author                 : Srimathi  
** Description             : Pivot to show crosstab count in case of categorical - categorical combination (used in Analyze Page grouped bar chart)  
** Date        : 23-Aug-2019  
  
Date   Version   Change Descr    Author  
  
12/30/2019  1.1    Handled Null categories  Srimathi  
  
09-oct-2020  sunitha  Enclose Tablename and columnName  with square   
       brackets  to allow space or any secial characters  
  
18-Oct-2020 Srimathi  Handle NULL and empty string as 'Null' in case of char datatype  
29-Oct-2020 Sunitha  Convert date datatype  to varchar  for the  variable @Replace_Null_With2 to fix -Bug #120(Conversion failed when converting date and/or time from character string)  
30-oct-2020 Sunitha   Convert the datetime datatype to date for col2  
  
*******************************************************************************/  
  
DECLARE @cols NVARCHAR(MAX)  
DECLARE @query NVARCHAR(MAX)  
DECLARE @col1_dt varchar(100);  
DECLARE @col2_dt VARCHAR(100);  
DECLARE @Replace_Null_With1 VARCHAR(200);  
DECLARE @Replace_Null_With2 VARCHAR(200);  
--Tablename and column name to enclose with square brackets  
 SET @tablename=QUOTENAME(REPLACE(REPLACE(@tablename,'[',''),']',''));  
 SET @column1Name=QUOTENAME(REPLACE(REPLACE(@column1Name,'[',''),']',''));  
 SET @column2Name=QUOTENAME(REPLACE(REPLACE(@column2Name,'[',''),']',''));  
  
  
 SELECT @Col1_DT = DATA_TYPE   
  FROM INFORMATION_SCHEMA.COLUMNS   
  WHERE TABLE_SCHEMA = @SchemaName   
   AND TABLE_NAME = replace(replace(@tableName,'[',''),']','')    
   AND COLUMN_NAME = replace(replace(@Column1Name,'[',''),']','')      
 SELECT @Col2_DT = DATA_TYPE   
  FROM INFORMATION_SCHEMA.COLUMNS   
  WHERE TABLE_SCHEMA = @SchemaName   
   AND TABLE_NAME = replace(replace(@tableName,'[',''),']','')     
   AND COLUMN_NAME = replace(replace(@Column2Name,'[',''),']','')      
  
 IF @col1_dt in ('DATE','DATETIME','SMALLDATETIME','DATETIME2')  
  SET @Replace_Null_With1='ISNULL('  + @column1Name + ',''1900-01-01'')'  
 ELSE IF @col1_dt IN ('Money','Int','TinyInt','bigint','smallint','bit','numeric','small money','float','real','decimal')     
  SET @Replace_Null_With1 = 'Convert(varchar,ISNULL('  + @column1Name + ',''0''))'  
 ELSE  
  SET @Replace_Null_With1 = 'CONVERT(VARCHAR,ISNULL(CASE WHEN '  + @column1Name + ' = '''' THEN ''Null'' ELSE ' + @column1Name + ' END ,''Null''))'  
  
 if @col2_dt in ('DATE','DATETIME','SMALLDATETIME','DATETIME2')  
  SET @Replace_Null_With2 = 'CONVERT(DATE,ISNULL('  + @column2Name + ',''1900-01-01''))'  
 ELSE IF @col2_dt IN ('Money','Int','TinyInt','bigint','smallint','bit','numeric','small money','float','real','decimal')     
  SET @Replace_Null_With2 = 'Convert(varchar,ISNULL('  + @column2Name + ',''0'')) + '' '''  
 ELSE  
  SET @Replace_Null_With2 = 'ISNULL(CONVERT(VARCHAR,CASE WHEN '  + @column2Name + ' = '''' THEN ''Null'' ELSE ' + @column2Name + '+ '' '' END ),''Null'')'  
--convert the datetime data type to date as pivot is having too many datevalues if we consider time and causes truncation issue  
  
--SET @query = 'SELECT @cols = STUFF((SELECT DISTINCT '','' + QUOTENAME(' + @Replace_Null_With2 + ') FROM '  + @schemaname + '.'  + @tablename + ' FOR XML PATH(''''), TYPE).value(''.'', ''NVARCHAR(MAX)''),1,1,'''')';  
 SET @query = 'SELECT @cols = STUFF((SELECT DISTINCT '','' + QUOTENAME(' + @Replace_Null_With2 + ') FROM '  + @schemaname + '.'  + @tablename + ' FOR XML PATH(''''), TYPE).value(''.'', ''NVARCHAR(MAX)''),1,1,'''')';  
    --   Print @query  
 execute sp_executesql @query, N'@cols NVARCHAR(MAX) OUTPUT', @cols OUTPUT;  
 --convert the datetime data type to date      
 SET @query = ' SELECT * FROM   (  SELECT ' + @Replace_Null_With1 + ' ' + @column1Name + ', ' + @Replace_Null_With2 + ' ' + @column2Name + ' FROM ' + @schemaname + '.'  + @tablename + ' ) t PIVOT( COUNT( ' + @column2Name +')  FOR ' + @column2Name +' IN ('
 + @cols + ' )) AS pivot_table order by 1,2;'  
   --Print @query  
 execute(@query)  
  
END
GO


