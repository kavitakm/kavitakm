CREATE   PROC [AppAdmin].[ti_catalog_getTablebySchema_sp]
			@SchemaName Varchar(50)
AS
BEGIN
/**************************************************************************
**
** Version Control Information
** ---------------------------
**
**  Name                   : AppAdmin.ti_catalog_getTablebySchema_sp
**  Version                : 1.0      
**  Date Created		   : 25-10-2019   
**  Type                   : Stored Procedure
**  Author                 : Sunitha
***************************************************************************     
** FileName                : ti_catalog_getTablebySchema_sp.sql 
** Description             : <Purpose of SP>
** retrive the list of all tables for the given schema                    
**      
** Input Parameters  : <List of Input Parameters>
** @SchemaName Varchar(50)
** Modification Hist:       
**            
** Date                           Name                                     Modification 
*******************************************************************************/
SELECT TABLE_NAME AS [Name] 
FROM information_schema.tables 
WHERE TABLE_TYPE='BASE TABLE'
	AND TABLE_SCHEMA = @SchemaName 
ORDER BY [Name];
END