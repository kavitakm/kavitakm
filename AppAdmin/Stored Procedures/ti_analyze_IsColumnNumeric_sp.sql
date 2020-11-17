CREATE   PROC [AppAdmin].[ti_analyze_IsColumnNumeric_sp]
					@SchemaName Varchar(50),
					@TableName Varchar(50),
					@ColumnName Varchar(50)
					
AS
BEGIN
/**************************************************************************
**
** Version Control Information
** ---------------------------
**
**  Name                   : AppAdmin.ti_analyze_IsColumnNumeric_sp
**  Version                : 1.0      
**  Date Created		   : 25-10-2019   
**  Type                   : Stored Procedure
**  Author                 : Sunitha
***************************************************************************     
** FileName                : ti_analyze_IsColumnNumeric_sp.sql 
** Description             : <Purpose of SP>
** check whether the column is numeric or not for the specified column of given table                      
**      
** Input Parameters  : <List of Input Parameters>
	@SchemaName Varchar(50),
	@TableName Varchar(50),
	@ColumnName Varchar(50)
** Modification Hist:       
**            
** Date                           Name                                     Modification 
*******************************************************************************/
DECLARE @str NVARCHAR(MAX);
SET @str='SELECT DISTINCT CASE WHEN '+@ColumnName+'  LIKE ''%[^0-9.]%'' THEN ''invalid'' 
					WHEN '+@ColumnName+' LIKE ''%.%.%'' THEN ''invalid''
					ELSE ''valid'' 
				END '+@ColumnName+ ' FROM '+@SchemaName+'.'+@TableName
EXEC sp_executesql @str;
END