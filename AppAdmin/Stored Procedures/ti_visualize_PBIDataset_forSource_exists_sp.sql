CREATE      PROC [AppAdmin].[ti_visualize_PBIDataset_forSource_exists_sp]  
@ObjectName varchar(200),
@ObjectLocation varchar(200),
@ObjectType varchar(50), --File or Table
@FileExt varchar(10),
--DatasetObjectID UNIQUEIDENTIFIER,
@WorkspaceName varchar(200),
@WorkspaceID UNIQUEIDENTIFIER

 AS  
 BEGIN  
 /******************************************************
** Version               : 1.0               
** Author                : Srimathi        
** Description           : To check if Power BI Dataset exists for Tesser Object - ti_adm_visualise Table
** Date					 : 11-AUG-2020 

*******************************************************/ 

SELECT 
	PBI_Dataset.ObjectName as PBI_DatasetName,
	PBI_Dataset.object_GUID as PBI_Dataset_GUID,
	PBI_Dataset.ObjectLocation as PBI_Dataset_WorkspaceName,
	PBI_Dataset.workspace_GUID as PBI_Dataset_Workspace_GUID

FROM
	appadmin.ti_adm_visualize DT_Obj_Association
	INNER JOIN
	appadmin.ti_adm_objectowner PBI_Dataset 
		ON PBI_Dataset.objectid = DT_Obj_Association.ObjectId
	INNER JOIN
	appadmin.ti_adm_objectowner Tesser_Object
		ON Tesser_Object.ObjectID = DT_Obj_Association.Predecessorid
	

WHERE
	Tesser_Object.ObjectName = @ObjectName
	AND case when @ObjectType = 'File' then Tesser_Object.ObjectLocation else Tesser_Object.SchemaName end = @ObjectLocation
	AND case when @ObjectType = 'File' then Tesser_Object.FileExt else ' ' end = case when @ObjectType = 'File' then @FileExt else ' ' end
	AND PBI_Dataset.ObjectLocation = @WorkspaceName
	AND PBI_Dataset.Workspace_GUID = @WorkspaceID
	AND PBI_Dataset.IsActive=1
	AND Tesser_Object.IsActive = 1

END