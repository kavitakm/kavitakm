CREATE   PROC [AppAdmin].[ti_catalog_dropTable_sp]
					@SchemaName Varchar(50),
					@TableName Varchar(50)
AS
BEGIN
/**************************************************************************
**
** Version Control Information
** ---------------------------
**
**  Name                   : AppAdmin.ti_catalog_dropTable_sp
**  Version                : 1.0      
**  Date Created		   : 30-10-2019   
**  Type                   : Stored Procedure
**  Author                 : Sunitha
***************************************************************************     
** Description             : <Purpose of SP>
** drop the table                    
**      
** Modification Hist:       
** Date                           Name                                     Modification

*******************************************************************************/
BEGIN TRY
  BEGIN TRANSACTION  
Declare @ErrMsg VARCHAR(1000);
Declare @ErrSeverity VARCHAR(100);
DECLARE @str nvarchar(max);

SET @str='DROP TABLE IF EXISTS '+@SchemaName+'.'+@TableName
EXEC sp_executesql @str;
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