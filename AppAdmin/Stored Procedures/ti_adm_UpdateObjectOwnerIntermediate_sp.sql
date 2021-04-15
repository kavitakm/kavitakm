
 --exec [AppAdmin].[ti_adm_UpdateObjectOwnerIntermediate_sp] 1
CREATE   Proc [AppAdmin].[ti_adm_UpdateObjectOwnerIntermediate_sp]        
@ObjectID int,
@ObjectOwnerID int,
@CreatedBy int,
@SchemaName varchar(50)
As         
BEGIN    
/************************************************************************** 
**
** Version Control Information
** ---------------------------
**
**  Name                   : [AppAdmin].[ti_Integrate_UpdateAPIIsActive_sp] 
** Version				  : 1.0           
** Author                 : Dinesh    
** Description           : Update the ObjectOwner_Intermediate IsActive flag based on Object ID in SQL Server - used in Backend loaded tables object Trigger    
** Date					 : 25-Feb-2021 
** Modification Hist:       
**            
30-Mar-2021	Srimathi	Added GrantAccess insert statement, added objectownerid and createdby parameters     
*******************************************************************************/ 
BEGIN TRY
  BEGIN TRANSACTION
	Declare @ErrMsg VARCHAR(1000);
    Declare @ErrSeverity VARCHAR(100);

	
 IF (@ObjectID > 0)                
 BEGIN    
	UPDATE [AppAdmin].[ti_adm_ObjectOwner_Intermediate] 
	SET IsActive = 0
	WHERE ObjectID = @ObjectID

	INSERT INTO 
		APPADMIN.ti_adm_ObjectAccessGrant(OBJECTID, GrantToUser, CREATEDDATE, CREATEDBY, LastUpdatedDate, LastUpdatedBy, ISACTIVE, FAVOURITE) 
		SELECT @ObjectOwnerID, USERID, getdate(), @CreatedBy, getdate(), @CreatedBy, 1, 0
			FROM APPADMIN.TI_ADM_USER_LU 
			WHERE 
				ISACTIVE=1 
				and userid!=@CreatedBy
				and SubscriptionID = (select SubscriptionID from appadmin.ti_adm_User_lu where UserID=@CreatedBy)
				and @SchemaName <> (select field1 from appadmin.ti_adm_user_lu where userid = @createdby)

		
 END  
 COMMIT TRANSACTION
END TRY 
  BEGIN CATCH
  IF @@trancount>0
	ROLLBACK TRANSACTION
  SET @ErrMsg = ISNULL(LEFT(RTRIM(ERROR_MESSAGE()),1000),'')             
  SET @ErrSeverity=ERROR_SEVERITY()
  RAISERROR(@ErrMsg,@Errseverity,1)
END CATCH
 
          
End  
GO


