CREATE   PROCEDURE [AppAdmin].[ti_adm_RoleInsert_sp]    
  @RoleName nvarchar(100),    
  @CreatedBy int,    
  @Identity int OUT    
AS   
/**************************************************************************      
** Version                : 1.0       
** Author                 :       
** Description            : Insert the new Role  
** Date       :    
    
  
*******************************************************************************/  
--SET NOCOUNT ON  
Declare @ErrMsg VARCHAR(1000);  
Declare @ErrSeverity VARCHAR(100);  
BEGIN TRY  
BEGIN TRANSACTION   
Insert into [APPAdmin].[ti_adm_Roles_lu] (RoleName, CreatedBy,CreatedDate, IsActive, IsBaseRole) Values ( @RoleName, @CreatedBy, GetDate(), 1,0);     
SET @Identity = SCOPE_IDENTITY()
COMMIT TRANSACTION 
END TRY  
BEGIN CATCH  
  IF @@trancount>0  
 ROLLBACK TRANSACTION  
  SET @ErrMsg = ISNULL(LEFT(RTRIM(ERROR_MESSAGE()),1000),'')               
  SET @ErrSeverity=ERROR_SEVERITY()  
  RAISERROR(@ErrMsg,@Errseverity,1)  
END CATCH