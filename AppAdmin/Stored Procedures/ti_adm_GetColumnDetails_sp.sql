CREATE PROCEDURE [AppAdmin].[ti_adm_GetColumnDetails_sp]
@SchemaName VARCHAR(50), @TableName VARCHAR(100)
AS
BEGIN
/**************************************************************************        
**        
** Version Control Information        
** ---------------------------        
**        
**  Name                   : ti_adm_GetColumnDetails_sp       
**  Version                : 1.1               
**  Date Created		   : 10-13-2020           
**  Type                   : Stored Procedure        
**  Author                 : Guru Kiran       
***************************************************************************         
** Description             : To fetch the list of column names and its data type created in the table.                                
**               
** Modification Hist:               
**                    
** Date                           Name                                     Modification 
10/14/2020                  attribute addition                      Added column positon and isprimarykey attributes


********************************************************************************/

SELECT
a.COLUMN_NAME AS ColumnName,
a.DATA_TYPE AS DataType,
a.ORDINAL_POSITION AS ColumnPosition,
CASE WHEN res.CONSTRAINT_TYPE = 'PRIMARY KEY' THEN 1 ELSE 0 END AS IsPrimaryKey
FROM 
INFORMATION_SCHEMA.COLUMNS a 
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
WHERE 
a.TABLE_SCHEMA=@SchemaName
AND a.TABLE_NAME = @TableName;


END