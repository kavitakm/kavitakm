--exec [AppAdmin].[ti_adm_favourite_sp] 
--'CPA_Accounting_Report','Report','','CPA','','Dinesh@tesserinsights.com',1
CREATE   PROC [AppAdmin].[ti_adm_favourite_sp]	   @objectName	   VARCHAR(200), 
   @ObjectType		 VARCHAR(100),
	@SchemaName		 VARCHAR(50),	
	@objectLocation  VARCHAR(200),
	@FileExt		 VARCHAR(50),
	@userEmail		 VARCHAR(100),
	@favFlag		 BIT 
AS             
BEGIN        
/******************************************************
** Version               : 1.0               
** Author                : Sunitha        
** Description           : to update the favourites flag in objectowner and objectAccessGrant table        
** Date					 : 16-12-2019           
*******************************************************/ 
DECLARE @UserId INT
DECLARE @OwnerofObject int
DECLARE @ObjectID int
--@userID
SELECT @UserId=userID
FROM AppAdmin.ti_adm_User_lu
WHERE UserEmail=@userEmail
--@ObjectID
SELECT @objectID=ObjectID 
FROM appadmin.ti_adm_objectowner 
WHERE objecttype=@objecttype
	AND objectName=@objectName
	AND (schemaName=@SchemaName OR schemaName is NULL)
	AND (objectlocation=@objectlocation OR objectlocation IS NULL)
	AND (FileExt=@FileExt OR FileExt IS NULL)
	AND isActive=1
--@OwnerofObject
SELECT @OwnerofObject=CreatedBy
FROM AppAdmin.ti_adm_ObjectOwner
where ObjectID=@ObjectID
--If the user is owner of the object then update objectowner table else accessgrant table
IF (@UserId=@OwnerofObject)
BEGIN
	UPDATE AppAdmin.ti_adm_ObjectOwner 
	SET Favourite=@favFlag
		,LastUpdatedBy=@UserId
		,LastUpdatedDate=getdate()
	WHERE objectID=@objectID
		AND IsActive=1
END
ELSE
 BEGIN
	UPDATE AppAdmin.ti_Adm_objectAccessGrant 
	SET Favourite=@favFlag
		,LastUpdatedBy=@UserId
		,LastUpdatedDate=getdate()
	WHERE objectID=@objectID
		AND IsActive=1
END

END