CREATE   PROCEDURE [AppAdmin].[ti_adm_DeleteUser_sp]    
@UserID int     
As     
BEGIN    
 BEGIN TRY
  BEGIN TRANSACTION  
   Declare @ErrMsg VARCHAR(1000);
   Declare @ErrSeverity VARCHAR(100); 
	Update [AppAdmin].[ti_adm_User_lu] Set IsActive = 0     
	Where UserID = @UserID    
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