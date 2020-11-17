--exec appadmin.ti_adm_GrantOrRevoke_sp 'sandbox','advertising','Table','','','Aravindh@tesserinsights.com,Gayatri@tesserinsights.com,Harini@tesserinsights.com','zeeshan@tesserinsights.com'

CREATE   Proc [AppAdmin].[ti_adm_GrantOrRevoke_sp]        
@SchemaName varchar(100), -- will be blank in case of file or transform
@ObjectName varchar(100), -- Table or file or Transform name
@ObjectType varchar(50),
@ObjectLocation varchar(500),
@FileExt varchar(10),
@UserEmails varchar(MAX), --user emails comma separated
@UserEmail varchar(100),
@Object_GUID UNIQUEIDENTIFIER = NULL

As         
BEGIN    
/**************************************************************************    
** Version               : 1.0           
** Author                : Srimathi    
** Description           : Insert into [ti_adm_ObjectAccessGrant] Table
** Date					 : 25-Sep-2019    
 Modification history
 19-12-2019  sunitha   Added default Favourite flag column value to zero  in ti_adm_ObjectAccessGrant table
 11-02-2020	 Srimathi  Used getObjectID_fn to fetch objectid
 16-09-2020	 Srimathi  Removed getObjectID_fn to include Object_GUID value check
*******************************************************************************/    

BEGIN TRY
--BEGIN TRANSACTION 
DECLARE @ObjectID int;
DECLARE @UserId int;
Declare @ErrMsg VARCHAR(1000);
Declare @ErrSeverity VARCHAR(100);

	--SELECT @ObjectId = [appadmin].[ti_adm_getObjectID_fn](@ObjectName, @ObjectType, @SchemaName, @ObjectLocation, @FileExt)
	
	SELECT  @ObjectID = ObjectID 
	FROM appadmin.ti_adm_objectowner 
	WHERE 
		ObjectType = @ObjectType 
		AND ObjectName = @ObjectName 
		AND ISNULL(SchemaName,'') = @SchemaName
		AND ISNULL(ObjectLocation,'') = @ObjectLocation
		AND ISNULL(FileExt,'') = @FileExt
		AND IsActive = 1 
		AND (@Object_GUID IS null OR Object_GUID = @Object_GUID)
	
	   

/*
	IF @ObjectType in ('Transform','Cleanse')
		SELECT @ObjectId = OBJECTID FROM APPADMIN.ti_adm_ObjectOwner WHERE ObjectName = @ObjectName AND ObjectType = @ObjectType AND isactive = 1;
	ELSE IF @ObjectType = 'File'
		SELECT @ObjectId = OBJECTID FROM APPADMIN.ti_adm_ObjectOwner WHERE ObjectName = @ObjectName AND ObjectLocation  = @ObjectLocation AND ObjectType ='File' AND FileExt = @FileExt AND isactive = 1;
	ELSE 
		SELECT @ObjectId = OBJECTID FROM APPADMIN.ti_adm_ObjectOwner WHERE ObjectName = @ObjectName AND SchemaName = @SchemaName AND ObjectType ='Table' AND isactive = 1;
*/
	SELECT @UserId = appadmin.ti_adm_getUserID_fn(@userEmail)
	
	IF object_id('tempdb.dbo.#temp') IS NOT NULL  
		DROP TABLE #temp;  
	CREATE TABLE #temp(UserId int, Emailid varchar(100));
	
	insert into #temp(Emailid) 
		SELECT trim(VALUE) 
		FROM string_split(@UserEmails,',');
	
	UPDATE #temp 
		SET UserId = a.UserId 
		FROM APPADMIN.TI_ADM_USER_LU a
		WHERE emailid = a.UserEmail and a.isactive = 1;
	
	DELETE FROM APPADMIN.ti_adm_ObjectAccessGrant 
		WHERE 
			ObjectID = @ObjectID 
			AND ISACTIVE = 1;
	
	INSERT INTO APPADMIN.ti_adm_ObjectAccessGrant
		(ObjectID,GrantToUser,CreatedDate,CreatedBy,LastUpdatedDate,LastUpdatedBy,IsActive,Favourite) 
		SELECT @ObjectID, t.userid, getdate(), @UserId, getdate(), @UserID, 1,0 FROM #temp t where t.userid is not null;
	
	DROP TABLE #temp;
	--COMMIT TRANSACTION;
END TRY
BEGIN CATCH
  --IF @@trancount>0
--	ROLLBACK TRANSACTION
  SET @ErrMsg = ISNULL(LEFT(RTRIM(ERROR_MESSAGE()),1000),'')             
  SET @ErrSeverity=ERROR_SEVERITY()
  RAISERROR(@ErrMsg,@Errseverity,1)
END CATCH             

END