-- exec [AppAdmin].[ti_adm_GetVisualizeDataset_sp] 'Sandbox','tblEarth05'  
   
Create Proc [AppAdmin].[ti_adm_GetVisualizeDataset_sp]  
@SchemaName   VARCHAR(50),          
@TableName    VARCHAR(200)   
As  
Begin  
Select vobj.ObjectID,vobj.ObjectName,vobj.ObjectLocation,vobj.Object_GUID DatasetID, vobj.Workspace_GUID WorkspaceID from [AppAdmin].[ti_adm_visualize] v  
inner join [AppAdmin].[ti_adm_ObjectOwner] vobj on vobj.objectid = v.objectid   
inner join [AppAdmin].[ti_adm_ObjectOwner] Tobj on Tobj.ObjectId = v.predecessorid   
-- where predecessorid = 10345  
where Tobj.schemaname =@SchemaName and Tobj.objectName =@TableName and vobj.IsActive =1 and vobj.ObjectType ='Dataset' and vobj.ObjectName not like '%ti_%'  
End  