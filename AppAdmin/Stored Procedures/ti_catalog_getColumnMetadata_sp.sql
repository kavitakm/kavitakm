CREATE   PROC [AppAdmin].[ti_catalog_getColumnMetadata_sp]
					@SchemaName Varchar(50),
					@TableName Varchar(50)
					
AS
BEGIN
/**************************************************************************
**
** Version Control Information
** ---------------------------
**
**  Name                   : AppAdmin.ti_catalog_getColumnMetadata_sp
**  Version                : 1.0      
**  Date Created		   : 25-10-2019   
**  Type                   : Stored Procedure
**  Author                 : Sunitha
***************************************************************************     
** FileName                : ti_catalog_getColumnMetadata_sp.sql 
** Description             : <Purpose of SP>
** Fetch the column metadata for specified table                         
**      
** Input Parameters  : <List of Input Parameters>
	@SchemaName Varchar(50),
	@TableName Varchar(50)
** Modification Hist:       
**            
** Date                           Name                                     Modification 
*******************************************************************************/
SELECT  a.column_name
	, a.column_default
	, a.is_Nullable
	, a.data_type
	, CASE WHEN character_maximum_length = -1 THEN '4000' 
			ELSE convert(varchar(4),character_maximum_length)
	   END AS  character_maximum_length
    , CASE WHEN res.CONSTRAINT_TYPE = 'PRIMARY KEY' THEN 1 ELSE 0 END AS IsPrimaryKey
FROM INFORMATION_SCHEMA.COLUMNS a 
LEFT JOIN
(
SELECT
b.TABLE_SCHEMA,
b.TABLE_NAME,
c.COLUMN_NAME,
b.CONSTRAINT_TYPE
FROM
INFORMATION_SCHEMA.TABLE_CONSTRAINTS b
INNER JOIN
INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE c
ON (b.TABLE_NAME=c.TABLE_NAME AND b.CONSTRAINT_NAME=c.CONSTRAINT_NAME)
)res
ON (a.TABLE_SCHEMA= res.TABLE_SCHEMA AND a.TABLE_NAME=res.TABLE_NAME AND a.COLUMN_NAME=res.COLUMN_NAME)
WHERE a.table_name IN (SELECT name 
					 FROM sys.tables
					 WHERE TYPE ='U' AND a.table_schema = @SchemaName
							AND name =@TableName);
END