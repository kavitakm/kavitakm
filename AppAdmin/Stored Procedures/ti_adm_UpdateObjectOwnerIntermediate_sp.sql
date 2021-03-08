
 --exec [AppAdmin].[ti_adm_UpdateObjectOwnerIntermediate_sp] 1
Create   Proc [AppAdmin].[ti_adm_UpdateObjectOwnerIntermediate_sp]        
@ObjectID int
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