CREATE   PROC [AppAdmin].[ti_transform_getColumnInfo_sp]
					@SchemaName Varchar(50),
					@TableName Varchar(50)
					
AS
BEGIN
/**************************************************************************
**
** Version Control Information
** ---------------------------
**
**  Name                   : AppAdmin.ti_transform_getColumnInfo_sp
**  Version                : 1.0      
**  Date Created		   : 25-10-2019   
**  Type                   : Stored Procedure
**  Author                 : Sunitha
***************************************************************************     
** FileName                : ti_transform_getColumnInfo_sp.sql 
** Description             : <Purpose of SP>
** Fetch the columnname and its datatype for specified table                         
**      
** Input Parameters  : <List of Input Parameters>
	@SchemaName Varchar(50),
	@TableName Varchar(50)
** Modification Hist:       
**            
** Date                           Name                                     Modification 
*******************************************************************************/

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA =@SchemaName 
	AND TABLE_NAME =@TableName
END