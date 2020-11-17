--exec [AppAdmin].[ti_Integrate_InsertAPI_sp] 'HariniAPITest2','Test API2','Sandbox','harinitest','MiddleName','Gender,LastName','Harini Varadarajan','harini@fivepointfivesolutions.com'
CREATE   Proc [AppAdmin].[ti_Integrate_InsertAPI_sp]  
@APIName varchar(100),
@APIDescription varchar(500),
@Schema varchar(100),
@TableName varchar(100),
@InputCols varchar(MAX),
@OutputCols varchar(MAX),
--@UserName varchar(100), 
@UserEmail varchar(100)

As         
BEGIN    
/**************************************************************************    
** Version               : 1.0           
** Author                : Harini    
** Description           : Insert the API Details in SQL Server - used in Integrate screen    
** Date					 : 24-Sep-2019    
     
*******************************************************************************/ 
BEGIN TRY
  BEGIN TRANSACTION
   DECLARE @userid int;  
   DECLARE @Objectid int;
   	Declare @ErrMsg VARCHAR(1000);
    Declare @ErrSeverity VARCHAR(100);
   SELECT @userid = userid from appadmin.ti_adm_user_lu where useremail = @UserEmail and isactive=1;  
   SELECT @Objectid = [ObjectID] FROM [AppAdmin].[ti_adm_ObjectOwner] where [ObjectName] = @TableName and [SchemaName] = @Schema and isactive=1;
 --print @userid; 

	INSERT INTO [AppAdmin].[ti_adm_integrate]
	( 
	    ObjectID
		,APIName
		,APIDescription
		,InputColumns
		,OutputColumns
		,CreatedDate
		,CreatedBy		
		,LastUpdatedDate
		,LastUpdatedBy
		,IsActive
	) 
	Values
	(
	    @Objectid
		,@APIName
		,@APIDescription
		,@InputCols
		,@OutputCols
		,GetDate()
		,@userid		
		,GetDate()
		,@userid
		,1
	); 
	SELECT SCOPE_IDENTITY(); 
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