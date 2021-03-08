/****** Object:  StoredProcedure [AppAdmin].[ti_Transform_CreateTransform_sp]    Script Date: 08-Mar-21 3:35:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER   PROC [AppAdmin].[ti_Transform_CreateTransform_sp]        
  @TransformName Varchar(150)  
 ,@RequestObject Varchar(max)  
 ,@TransformQuery Varchar(max)  
 ,@OutputType varchar(10)  
 ,@OutputName varchar(150)  
 ,@SchemaName Varchar(150)  
 ,@Notes Varchar(max)  
 ,@Location Varchar(150) 
 ,@FileExt VARCHAR(10)
 ,@TransactionType Varchar(15)  
 ,@UserEmail Varchar(150)
 ,@LoadType Int
AS         
BEGIN        
 /**************************************************************************  
**  
** Version Control Information  
** ---------------------------  
**  
**  Name                   : [AppAdmin].[ti_Transform_CreateTransform_sp]   
**  Version                : 1         
**  Date Created     :    
**  Type                   : Stored Procedure  
**  Author                 : Dinesh  
** Description             : <Purpose of SP>  
**    
  
** Modification Hist: 
1/22/2020   Srimathi	Added FileExt parameter for output file
2/29/2020	Srimathi	Added favourite and TAI_Enabled flag in insert statement (Objectowner)
12/28/2020	Sunitha		Added LoadType in insert statement(Objectowner)
1/29/2020	Harini      Modified the insert statement(Objectowner) for Cleanse with the below changes:-
						a) Added favourite,TAI_Enabled,LoadType, 
						b) Corrected the BEGIN-END, 
						c) Changed value of ObjectName param from @OutputName to @TransformName
**              
*******************************************************************************/  
--SET NOCOUNT ON  
BEGIN TRY  
  BEGIN TRANSACTION  
 Declare @UserID int;  
 Declare @OBjectID int;  
 Declare @TargetOBjectID int;  
 Declare @ErrMsg VARCHAR(1000);  
    Declare @ErrSeverity VARCHAR(100);  
 SET @OBjectID =0;  
 SET @TargetOBjectID =0;        
 SET @UserID = 0;  
        
 SELECT @UserID = UserID from [AppAdmin].[ti_adm_User_lu] where IsActive =1  and UserEmail =@UserEmail ;  
 
  SELECT @TargetOBjectID = ISNULL([AppAdmin].[ti_adm_getObjectID_fn](@OutputName,@OutputType,@SchemaName, @Location,@FileExt),0);

 /* Commented on 1/22/2020 by Srimathi to use Output type, FileExt parameter and getObjectID function

 SELECT @TargetOBjectID = ObjectID from [AppAdmin].[ti_adm_ObjectOwner] where isactive =1 and SchemaName = @SchemaName 
 and ObjectName =@OutputName and ObjectLocation = @Location ;  */
  
 IF ( UPPER(@TransactionType) IN ('TRANSFORM','CLEANSE'))  
  BEGIN  
   IF UPPER(@TransactionType)='TRANSFORM'
	BEGIN
	   INSERT INTO [AppAdmin].[ti_adm_ObjectOwner] (ObjectName,ObjectType,SchemaName,ObjectLocation,CreatedDate,LastUpdatedDate,IsActive,FileExt,FileSize,createdBy,LastupdatedBy, favourite,TAI_Enabled,LoadType)  
	   VALUES( @TransformName, @TransactionType , '', '', getdate(), getdate(), 1, '', '', @UserID ,@UserID,0,0,@LoadType)  
	END  
   ELSE  
	BEGIN  
	   INSERT INTO [AppAdmin].[ti_adm_ObjectOwner] (ObjectName,ObjectType,SchemaName,ObjectLocation,CreatedDate,LastUpdatedDate,IsActive,FileExt,FileSize,createdBy,LastupdatedBy, favourite,TAI_Enabled,LoadType)  
	   VALUES( @TransformName, @TransactionType , '', '', getdate(), getdate(), 1, '', '', @UserID ,@UserID,0,0,@LoadType)  
	END  
  END
  
 SET @OBjectID =SCOPE_IDENTITY()  
   
 INSERT INTO [AppAdmin].[ti_adm_transform] (TargetObjectId, ObjectId , TransformName , RequestObject , TransformQuery , Notes, to_be_validated)   
 VALUES ( @TargetOBjectID , @OBjectID , @TransformName , @RequestObject, @TransformQuery,@Notes,0)  
    Select  @OBjectID ;   
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
GO


