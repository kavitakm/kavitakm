CREATE   PROCEDURE [AppAdmin].[ti_adm_RoleUpdate_sp]  
  @RoleName nvarchar(100),  
  @UpdatedBy int,  
  @RoleID int   
AS  
       
/**************************************************************************        
** Version                : 1.0           
** Author                 :         
** Description            : 
** Date					  : 
        
*******************************************************************************/ 
--SET NOCOUNT ON
BEGIN TRY
  BEGIN TRANSACTION 
  Declare @ErrMsg VARCHAR(1000);
  Declare @ErrSeverity VARCHAR(100);
Update [AppAdmin].[ti_adm_Roles_lu] set[RoleName] = @RoleName, UpdatedBy = @UpdatedBy, UpdatedDate = getdate() where RoleID = @RoleID  
COMMIT TRANSACTION
END TRY 
  BEGIN CATCH
  IF @@trancount>0
	ROLLBACK TRANSACTION
  SET @ErrMsg = ISNULL(LEFT(RTRIM(ERROR_MESSAGE()),1000),'')             
  SET @ErrSeverity=ERROR_SEVERITY()
  RAISERROR(@ErrMsg,@Errseverity,1)
END CATCH