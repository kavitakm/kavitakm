CREATE   PROCEDURE [AppAdmin].[ti_Analyze_DeleteAnalysis_sp]
@SchemaName varchar(100),  
@TableName varchar(100),  
@Column1Name varchar(200),
@Column2Name varchar(200),
@Column3Name varchar(200),
@Column4Name varchar(200)
AS
BEGIN

/**************************************************************************  
** Version                : 1.0     
** Author                 : Srimathi  
** Description            : Delete Analysis - delete rows in ti_adm_summarystatistics
** Date					  : 26-Aug-2019  
  
*******************************************************************************/ 
--SET NOCOUNT ON
BEGIN TRY
  BEGIN TRANSACTION 
  Declare @ErrMsg VARCHAR(1000);
  Declare @ErrSeverity VARCHAR(100);
DELETE FROM [AppAdmin].[ti_adm_summarystatistics] 
WHERE OBJECTID = (SELECT OBJECTID FROM [AppAdmin].[ti_adm_ObjectOwner] WHERE SCHEMANAME = @SchemaName AND ObjectName = @TableName AND ObjectType = 'Table' and IsActive = 1)
AND COLUMN1NAME = @Column1Name 
AND ISNULL(COLUMN2NAME,'') = ISNULL(@Column2Name,'')
AND ISNULL(COLUMN3NAME,'') = ISNULL(@Column3Name,'')
AND ISNULL(COLUMN4NAME,'') = ISNULL(@Column4Name,'')
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