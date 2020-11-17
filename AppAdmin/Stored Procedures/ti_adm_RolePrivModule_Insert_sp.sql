CREATE   PROCEDURE [AppAdmin].[ti_adm_RolePrivModule_Insert_sp]  
  @RoleID int,  
  @PrivilegeID int,  
  @ModuleComponentID int,  
  @CreatedBy int  
AS 
/**************************************************************************        
** Version                : 1.0           
** Author                 : Dinesh        
** Description            : 
** Date					  : 
        
*******************************************************************************/ 
--SET NOCOUNT ON
BEGIN TRY
  BEGIN TRANSACTION 
Declare @ErrMsg VARCHAR(1000);
Declare @ErrSeverity VARCHAR(100);
Insert into [APPAdmin].[ti_adm_RolePrivModule_lu]   
   (RoleID  
   , PrivilegeID  
   , ModuleComponentID  
   , CreatedBy  
   , CreatedDate  
   , IsActive)   
   Values   
   ( @RoleID  
   , @PrivilegeID  
   , @ModuleComponentID  
   , @CreatedBy  
   , GetDate()  
   , 1);   
 COMMIT TRANSACTION
END TRY 
  BEGIN CATCH
  IF @@trancount>0
	ROLLBACK TRANSACTION
  SET @ErrMsg = ISNULL(LEFT(RTRIM(ERROR_MESSAGE()),1000),'')             
  SET @ErrSeverity=ERROR_SEVERITY()
  RAISERROR(@ErrMsg,@Errseverity,1)
END CATCH