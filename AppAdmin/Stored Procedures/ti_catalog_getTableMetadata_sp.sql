CREATE   PROC [AppAdmin].[ti_catalog_getTableMetadata_sp]
					@SchemaName Varchar(50),
					@TableName Varchar(50)							
					
AS
BEGIN
/**************************************************************************
**
** Version Control Information
** ---------------------------
**
**  Name                   : AppAdmin.ti_catalog_getTableMetadata_sp
**  Version                : 1.0      
**  Date Created		   : 25-10-2019   
**  Type                   : Stored Procedure
**  Author                 : Sunitha
***************************************************************************     
** FileName                : ti_catalog_getTableMetadata_sp.sql 
** Description             : <Purpose of SP>
** fetch Table details for the given schema and TableName                         
**      
** Input Parameters  : <List of Input Parameters>
@SchemaName Varchar(50),
@TableName Varchar(50)

** Modification Hist:       
**            
** Date                           Name                                     Modification 
*******************************************************************************/
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES 
		  WHERE TABLE_SCHEMA =@SchemaName AND 
		  TABLE_NAME=@TableName) 
	SELECT 1 
ELSE 
	SELECT 0

END