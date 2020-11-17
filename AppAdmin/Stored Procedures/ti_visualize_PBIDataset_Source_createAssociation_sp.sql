Create      PROC [AppAdmin].[ti_visualize_PBIDataset_Source_createAssociation_sp]  
@DatasetName varchar(200),
@DatasetID UNIQUEIDENTIFIER,
@WorkspaceName varchar(200),
@WorkspaceID UNIQUEIDENTIFIER,
@ObjectName varchar(200),
@ObjectLocation varchar(200), --Schemaname in case of table, folder/container in case of file
@ObjectType varchar(50),
@FileExt varchar(10)

 AS  
 BEGIN  
 /******************************************************
** Version               : 1.0               
** Author                : Srimathi        
** Description           : Store PowerBI Dataset - Tesser Object relationship in ti_adm_visualize
** Date					 : 11-AUG-2020 

*******************************************************/ 
DECLARE @Dataset_Objectid int;
DECLARE @Source_Objectid int;

SELECT @Dataset_Objectid = objectid 
FROM appadmin.ti_adm_objectowner
WHERE 
	objectname = @DatasetName 
	AND OBJECTTYPE = 'DATASET'
	AND ISACTIVE = 1
	AND OBJECT_guid = @DatasetID
	AND ObjectLocation = @WorkspaceName
	and Workspace_GUID = @WorkspaceID

SELECT @SOURCE_Objectid = objectid 
FROM appadmin.ti_adm_objectowner
WHERE 
	objectname = @ObjectName 
	AND OBJECTTYPE in ('Table','File')
	AND ISACTIVE = 1
	AND case when @ObjectType = 'File' then ObjectLocation else SchemaName end = @ObjectLocation
	AND case when @ObjectType = 'File' then FileExt else ' ' end = case when @ObjectType = 'File' then @FileExt else ' ' end
	
IF not exists(select 1 from appadmin.ti_adm_visualize where objectid = @Dataset_Objectid and Predecessorid = @Source_Objectid)
	INSERT INTO APPADMIN.ti_adm_visualize(ObjectId, Predecessorid) values (@Dataset_Objectid, @Source_Objectid)

END