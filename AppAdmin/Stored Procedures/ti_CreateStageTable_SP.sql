--Exec AppAdmin.ti_CreateStageTable_SP 'DailySales_Incr.CSV','Sandbox/Input/',2199

CREATE PROCEDURE [AppAdmin].[ti_CreateStageTable_SP]
( @FileName varchar(max),
  @FilePath varchar(1000),
  @ObjectID  int
)
AS
BEGIN
 /* -----------------------------------------------------------------------------------------------   
* Version               1  
* Name                  AppAdmin.ti_CreateStageTable_SP
* Modified Date			
* Last Modifier			
* Purpose               Created PROC for getting the container name and create  corresponding stage table  for  the given object
* Changes  
*   Ver    DATE           By                           Description  
*   1      12-08-2020  Sunitha Menni 			  Initial Script
* --------------------------------------------------------------------------------------------------  
*/ 
BEGIN TRY

	DECLARE @FolderPath VARCHAR(max);	
	DECLARE @ContainerName VARCHAR(500);
	DECLARE @ErMsg VARCHAR(100)
	DECLARE @index1 INT;
	DECLARE @index2 INT;
	DECLARE  @ErrorMsg VARCHAR(2000);
	DECLARE @ObjectName varchar(1000);
	DECLARE @SchemaName varchar(100);
	DECLARE @StageTableName varchar(100);
	DECLARE @SQL nvarchar(max);

	SET @FileName = LTRIM(RTRIM(@FileName));
	SET @FilePath = LTRIM(RTRIM(@FilePath));
	

	SELECT -- @ContainerName=CASE WHEN ObjectLocation like '%/%' THEN TRIM(REPLACE(LEFT(ObjectLocation,CHARINDEX('/',ObjectLocation,2)),'/',''))
								--ELSE  ObjectLocation
								--END ,
		@ObjectName=ObjectName, @SchemaName=SchemaName
	FROM  [AppAdmin].[ti_adm_ObjectOwner]
	WHERE ObjectID=@ObjectID --AND IsActive=1
	SET @StageTableName=@SchemaName+'.'+@ObjectName+'_Stage'

	SET @index1 = CHARINDEX('/', @FilePath);
	--SET @index2 = CHARINDEX('/', @FilePath,@index1+1);
	
	--IF (@index1 = 0)
	--BEGIN
	--	SET @ErMsg = 'Could not find Seperator';
	--	Raiserror(@ErMsg,16,1);
	--END	
	SET @ContainerName = SUBSTRING(@FilePath, 1, @index1-1)
	SET @FolderPath=SUBSTRING(@FilePath,@index1+1,len(@FilePath))
	
	IF @FileName IS NOT NULL
	   SET @FileName=@FileName

SET @StageTableName=@SchemaName+'.'+@ObjectName+'_Stage'	
DECLARE @StageName varchar(100)
SET @StageName=@ObjectName+'_Stage'
print @StageName

SELECT lower(@ContainerName) As ContainerName,@FolderPath AS FolderPath,replace(@FileName,'.CSV','.csv') AS [FileName],@StageTableName AS StageTableName,
@SchemaName AS SchemaName,@ObjectName+'_Stage' AS StageName,@ObjectName AS TargetName

/*Create Intermediate Table for  incremental data loading - to help doing the merge*/

SET @SQL='IF NOT EXISTS (SELECT 1
           FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_SCHEMA = '''+@SchemaName+'''
           AND TABLE_NAME = '''+@StageName+''')
 BEGIN
     
	 SELECT * INTO '+@StageTableName+' FROM '+@SchemaName+'.'+@ObjectName+' WHERE 1=2
 END
 ELSE 
  TRUNCATE TABLE '+@StageTableName+';
;'

 EXECUTE sp_executesql  @SQL
 

END TRY 
BEGIN CATCH
		SET @ErrorMsg = Error_Message()
		 Raiserror(@ErrorMsg, 16,1);
END CATCH
  
END