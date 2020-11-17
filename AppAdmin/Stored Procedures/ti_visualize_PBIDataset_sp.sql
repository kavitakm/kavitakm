CREATE PROC [AppAdmin].[ti_visualize_PBIDataset_sp]  
@DatasetName varchar(200),
@DatasetID UNIQUEIDENTIFIER,
@WorkspaceName varchar(200),
@WorkspaceID UNIQUEIDENTIFIER,
@ObjectName varchar(200),
@ObjectLocation varchar(200), --Schemaname in case of table, folder/container in case of file
@ObjectType varchar(50),
@FileExt varchar(10),
@userEmail varchar(100)
 AS  
 BEGIN  
 /******************************************************
** Version               : 1.0               
** Author                : Srimathi        
** Description           : Store PowerBI Dataset - Tesser Object relationship in ti_adm_visualize
** Date					 : 11-AUG-2020 
** History
21-oct-2020 Sunitha     Added Transaction to the Stored Proc
*******************************************************/ 
BEGIN TRY  
  BEGIN TRANSACTION   
DECLARE @Dataset_Objectid int;
DECLARE @Source_Objectid int;
DECLARE @ErrMsg VARCHAR(1000);  
DECLARE @ErrSeverity VARCHAR(100); 

INSERT INTO AppAdmin.ti_adm_ObjectOwner  
   (objectName  
   , ObjectType  
   , ObjectLocation  
   , CreatedDate  
   , LastUpdatedDate  
   , IsActive  
   , CreatedBy  
   , LastUpdatedBy  
   ,Favourite
   ,Object_GUID
   ,Workspace_GUID
   )  
VALUES
	(@DatasetName
	, 'Dataset'
	, @WorkspaceName
	, getdate()
	, getdate()
	, 1  
	, (SELECT UserID FROM AppAdmin.ti_adm_User_lu WHERE userEmail=@UserEmail)  
	, (SELECT UserID FROM AppAdmin.ti_adm_User_lu WHERE userEmail=@UserEmail)  
	,0
	,@DatasetID
	,@WorkspaceID)




SET @Dataset_Objectid = SCOPE_IDENTITY()

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

	COMMIT TRANSACTION  
END TRY   
  BEGIN CATCH  
  IF @@trancount>0  
	ROLLBACK TRANSACTION  
  SET @ErrMsg = ISNULL(LEFT(RTRIM(ERROR_MESSAGE()),1000),'')               
  SET @ErrSeverity=ERROR_SEVERITY()  
  RAISERROR(@ErrMsg,@Errseverity,1)  
 END CATCH 
END