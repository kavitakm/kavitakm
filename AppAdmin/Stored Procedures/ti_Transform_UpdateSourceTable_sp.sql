CREATE  PROC [AppAdmin].[ti_Transform_UpdateSourceTable_sp]        
  @TransformID		int  
 ,@RequestObject	Varchar(max)  
 ,@TransformQuery	Varchar(max)  
 ,@UserEmail        Varchar(150)        
AS         
BEGIN   

/**************************************************************************
**
** Version Control Information
** ---------------------------
**
**  Name                   : [AppAdmin].[ti_Transform_UpdateSourceTable_sp] 
**  Version                : 1       
**  Date Created		   : 04-DEC-2020 
**  Type                   : Stored Procedure
**  Author                 : Srimathi
***************************************************************************     
** Description             : To update source table of a cleanse/transform and mark it valid
**  
** Modification Hist:       
**            
*******************************************************************************/
 --SET NOCOUNT ON
 BEGIN TRY
  BEGIN TRANSACTION
 DECLARE @UserID INT;  
 DECLARE @OBjectID INT;  
 DECLARE @TargetOBjectID INT;  
 DECLARE @ErrMsg VARCHAR(1000);
 DECLARE @ErrSeverity VARCHAR(100);
  
 SELECT @UserID=AppAdmin.ti_adm_getUserID_fn(@UserEmail);

 UPDATE appadmin.ti_adm_objectowner 
 SET 
	LastUpdatedBy = @userid
	, LastUpdatedDate = getdate()
 WHERE objectid = @transformID

 UPDATE [AppAdmin].[ti_adm_transform] 
 SET 
	RequestObject = @RequestObject
	, TransformQuery = @TransformQuery
	, to_be_validated = 0
 WHERE ObjectId = @transformID 

 Select @@ROWCOUNT as RowsAffected;
 COMMIT TRANSACTION
  END TRY 
  BEGIN CATCH
  IF @@trancount>0
	ROLLBACK TRANSACTION
  SET @ErrMsg =ISNULL(LEFT(RTRIM(ERROR_MESSAGE()),1000),'')            
  SET @ErrSeverity=ERROR_SEVERITY()
  RAISERROR(@ErrMsg,@Errseverity,1)
END CATCH
 End  