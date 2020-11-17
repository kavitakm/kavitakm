CREATE   PROC [AppAdmin].[ti_Transform_UpdateTransform_sp]        
  @TransformName	Varchar(150)  
 ,@RequestObject	Varchar(max)  
 ,@TransformQuery	Varchar(max)  
 ,@OutputType		varchar(10)  
 ,@OutputName		varchar(150)  
 ,@SchemaName		Varchar(150)  
 ,@Notes			Varchar(max)  
 ,@Location			Varchar(150)  
 ,@FileExt			VARCHAR(10)
 ,@TransactionType  Varchar(15)  
 ,@UserEmail        Varchar(150)        
AS         
BEGIN   

/**************************************************************************
**
** Version Control Information
** ---------------------------
**
**  Name                   : [AppAdmin].[ti_Transform_UpdateTransform_sp] 
**  Version                : 1       
**  Date Created		   :  
**  Type                   : Stored Procedure
**  Author                 : Dinesh
***************************************************************************     
** Description             : <Purpose of SP>
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
  
 SET @OBjectID =0;  
 SET @TargetOBjectID =0;        
 SET @UserID = 0;  
        
 SELECT @UserID = UserID from [AppAdmin].[ti_adm_User_lu] where IsActive =1  and UserEmail =@UserEmail ;  
 -- print @UserID
 SELECT @TargetOBjectID = ISNULL([AppAdmin].[ti_adm_getObjectID_fn](@OutputName, @OutputType, @SchemaName, @Location,@FileExt),0);

 /* Commented on 1/22/2020 by Srimathi to use Output Type, FileExt parameter and getObjectID function

 SELECT @TargetOBjectID = ObjectID from [AppAdmin].[ti_adm_ObjectOwner] where isactive =1 and SchemaName = @SchemaName 
 and ObjectName =@OutputName and ObjectLocation = @Location ;  
 */
 -- print @TargetOBjectID 
 Select @OBjectID = OBjectID from [AppAdmin].[ti_adm_ObjectOwner] where isactive =1 and ObjectName = @TransformName and ObjectType = @TransactionType  
  --print @OBjectID
 Update [AppAdmin].[ti_adm_transform] set TargetObjectId = @TargetOBjectID , TransformName  = @TransformName,  RequestObject = @RequestObject , TransformQuery = @TransformQuery, Notes = @Notes, to_be_validated = 0  where ObjectId = @OBjectID  
 --INSERT INTO [AppAdmin].[ti_adm_transform] (TargetObjectId, ObjectId , TransformName , RequestObject , TransformQuery , Notes)   
 --VALUES ( @TargetOBjectID , @OBjectID , @OutputName , @RequestObject, @TransformQuery,@Notes)  
      
 Select  @OBjectID ;
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