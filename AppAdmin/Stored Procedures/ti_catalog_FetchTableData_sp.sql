CREATE   PROC [AppAdmin].[ti_catalog_FetchTableData_sp]
					@SchemaName Varchar(50),
					@TableName Varchar(50)
AS
BEGIN

/**************************************************************************
**
** Version Control Information
** ---------------------------
**
**  Name                   : AppAdmin.ti_catalog_FetchTableData_sp
**  Version                : 1.0      
**  Date Created		   : 30-10-2019   
**  Type                   : Stored Procedure
**  Author                 : Sunitha
***************************************************************************     
** FileName                : ti_catalog_FetchTableData_sp.sql 
** Description             : <Purpose of SP>
** Retrive all records for the given schema and table                      
**      
** Input Parameters  : <List of Input Parameters>
@SchemaName Varchar(50),
@TableName Varchar(50)
** Modification Hist:       
**            
** Date                           Name                                 Modification 
06-oct-2020					Sunitha Menni							Modified the schema and Table name enclosed with square brackets to fix Bug#:76

*******************************************************************************/

DECLARE @str nvarchar(max);
SET @TableName=QUOTENAME(REPLACE(REPLACE(@TableName,'[',''),']',''));
SET @SchemaName=QUOTENAME(REPLACE(REPLACE(@SchemaName,'[',''),']',''));
SET @str='SELECT * FROM '+@SchemaName+'.'+@TableName
EXEC sp_executesql @str;
END