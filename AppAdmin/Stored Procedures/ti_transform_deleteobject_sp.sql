CREATE    PROC [AppAdmin].[ti_transform_deleteobject_sp]
					@TransformId  Int					
AS
BEGIN
/**************************************************************************
**
** Version Control Information
** ---------------------------
**
**  Name                   : AppAdmin.ti_transform_deleteobject_sp
**  Version                : 1.0      
**  Date Created		   : 25-10-2019   
**  Type                   : Stored Procedure
**  Author                 : Sunitha
***************************************************************************     
** FileName                : ti_transform_deleteobject_sp.sql 
** Description             : <Purpose of SP>
** delete transform  for the given objectID             
**      
** Modification Hist:       
**            
** Date                           Name                                     Modification 
*****************************************************************************/
--SET NOCOUNT ON
BEGIN TRY
  BEGIN TRANSACTION
DECLARE @ErrMsg VARCHAR(1000);
  DECLARE @ErrSeverity VARCHAR(100);
UPDATE [AppAdmin].[ti_adm_ObjectOwner] 
SET IsActive=0 
WHERE ObjectId = @TransformId
COMMIT TRANSACTION
  END TRY 
  BEGIN CATCH
  IF @@trancount>0
	ROLLBACK TRANSACTION
  SET @ErrMsg =  ISNULL(LEFT(RTRIM(ERROR_MESSAGE()),1000),'')
  SET @ErrSeverity=ERROR_SEVERITY()
  RAISERROR(@ErrMsg,@Errseverity,1)
END CATCH
END