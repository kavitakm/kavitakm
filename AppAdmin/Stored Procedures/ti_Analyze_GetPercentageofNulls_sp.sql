CREATE PROCEDURE [AppAdmin].[ti_Analyze_GetPercentageofNulls_sp]    
@SchemaName varchar(100),      
@TableName varchar(100),
@ColumnName varchar(100)
AS    
BEGIN    
    
/**************************************************************************      
** Version                : 1.0         
** Author                 : Srimathi      
** Description            : Send percentage of missing values in a column    
** Date					  : 04-Sep-2019      
      
*******************************************************************************/     

DECLARE @str NVARCHAR(MAX);
SET @str = 'SELECT CONVERT(FLOAT, ROUND(CONVERT(NUMERIC,(COUNT(*) - COUNT(' + @ColumnName + ')) * 100) / count(*),5)) nullpercentage FROM ' + @schemaname + '.' + @tablename ;
EXECUTE sp_executesql @str;
END