--exec [AppAdmin].[ti_Integrate_UpdateAPIIsActive_sp] 1,'harini@fivepointfivesolutions.com'
CREATE   Proc [AppAdmin].[ti_Integrate_UpdateAPIIsActive_sp]        
@APIID int,
@UserEmail varchar(100)
As         
BEGIN    
/************************************************************************** 
**
** Version Control Information
** ---------------------------
**
**  Name                   : [AppAdmin].[ti_Integrate_UpdateAPIIsActive_sp] 
** Version				  : 1.0           
** Author                 : Harini    
** Description           : Update the API IsActive flag based on API ID in SQL Server - used in Integrate screen    
** Date					 : 24-Sep-2019 
** Modification Hist:       
**            
     
*******************************************************************************/ 
BEGIN TRY
  BEGIN TRANSACTION
    DECLARE @userid int; 
	Declare @ErrMsg VARCHAR(1000);
    Declare @ErrSeverity VARCHAR(100);
    SELECT @userid = userid from appadmin.ti_adm_user_lu where useremail = @UserEmail and isactive=1;  

 IF (@APIID > 0)                
 BEGIN    
	UPDATE [AppAdmin].[ti_adm_integrate] 
	SET IsActive = 0
		,LastUpdatedDate = GetDate()
		,LastUpdatedBy = @userid	
	WHERE ApiID = @APIID
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