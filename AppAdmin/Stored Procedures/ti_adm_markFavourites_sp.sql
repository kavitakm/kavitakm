CREATE PROCEDURE  [AppAdmin].[ti_adm_markFavourites_sp]                     
@ObjectName Varchar(200),              
@ObjectType Varchar(50),              
@SchemaName Varchar(50),              
@ObjectLocation VARCHAR(200),  
@FileExt Varchar(10),  
@UserEmail Varchar(150),
@Favourites_Flag bit
               
AS                  
BEGIN     
  
/**************************************************************************    
** Version                : 1.0     
** Author                 : Srimathi    
** Description            : Mark Favourites_flag to 1 or 0 in Object Owner / Grant Access table
** Date					  : 07/01/2020    
  

*******************************************************************************/    
Declare @ErrMsg VARCHAR(1000);  
Declare @ErrSeverity VARCHAR(100);  

BEGIN TRY  
	BEGIN TRANSACTION     
	
	-- Update Object Owner Table's favourite flag
	UPDATE AppAdmin.ti_adm_ObjectOwner 
	SET 
		Favourite = @Favourites_Flag
		, LastUpdatedDate = getdate()
		, LastUpdatedBy = [AppAdmin].[ti_adm_getUserID_fn](@UserEmail)
	WHERE 
		ObjectID = [AppAdmin].[ti_adm_getObjectID_fn](@ObjectName,@ObjectType,@SchemaName,@ObjectLocation,@FileExt)
		AND CreatedBy = [AppAdmin].[ti_adm_getUserID_fn](@UserEmail)
	
	-- Update Object Access Grant Table's favourite flag
	UPDATE AppAdmin.ti_adm_ObjectAccessGrant 
	SET 
		Favourite = @Favourites_Flag 
		, LastUpdatedDate = getdate()
		, LastUpdatedBy = [AppAdmin].[ti_adm_getUserID_fn](@UserEmail)
	WHERE 
		ObjectID = [AppAdmin].[ti_adm_getObjectID_fn](@ObjectName,@ObjectType,@SchemaName,@ObjectLocation,@FileExt)
		AND GrantToUser = [AppAdmin].[ti_adm_getUserID_fn](@UserEmail)
		AND IsActive = 1

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