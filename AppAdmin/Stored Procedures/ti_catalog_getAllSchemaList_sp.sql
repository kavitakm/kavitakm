CREATE   PROC [AppAdmin].[ti_catalog_getAllSchemaList_sp]
AS
BEGIN
/**************************************************************************
**
** Version Control Information
** ---------------------------
**
**  Name                   : AppAdmin.ti_catalog_getAllSchemaList_sp
**  Version                : 1.0      
**  Date Created		   : 25-10-2019   
**  Type                   : Stored Procedure
**  Author                 : Sunitha
***************************************************************************     
** FileName                : ti_catalog_getAllSchemaList_sp.sql 
** Description             : <Purpose of SP>
** retrive the list of all schemas and their Ids                       
**      
** Input Parameters  : <List of Input Parameters>
** Modification Hist:       
**            
** Date                           Name                                     Modification 
*******************************************************************************/
SELECT DISTINCT schema_name(schema_id) AS schema_name
			 , schema_id 
FROM sys.tables AS [Tables] 
INNER JOIN sys.partitions AS [Partitions] 
	ON [Tables].[object_id] = [Partitions].[object_id] 
		AND [Partitions].index_id IN (0, 1) 
INNER JOIN information_schema.columns c
	ON [Tables].name = c.TABLE_NAME 
		AND [Tables].type = 'U'

END