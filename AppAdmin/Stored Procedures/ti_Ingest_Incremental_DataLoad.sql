  
CREATE PROC [AppAdmin].[ti_Ingest_Incremental_DataLoad]              
    @FilePath VARCHAR(100), @SchemaName VARCHAR(50),@TableName VARCHAR(200)    
AS              
BEGIN              
/**************************************************************************            
**            
** Version Control Information            
** ---------------------------            
**            
**  Name                   : ti_Ingest_Incremental_DataLoad           
**  Version                : 1                   
**  Date Created     : 25-08-2020               
**  Type                   : Stored Procedure            
**  Author                 : Aravindh           
***************************************************************************             
** Description             : To Perform Incremental Data Load based on the Load Type                                     
**                   
** Modification Hist:                   
**                        
** Date                           Name                                     Modification     
09-Nov-2020           Sunitha                  Hardcoded the decimal datatype length to (18,2)    
21-Dec-2020           Sunitha                  Included Error Logging in catch block    
20-Apr-2021           Bhuvana                  increased the Scale for decimal data type from 2 to 5 (18,2) to (18,5) - bug#1120  
    
    
********************************************************************************/            
    
BEGIN TRY     
 DECLARE @vFILEPATH VARCHAR(100), @vSCHEMANAME VARCHAR(50),@vTABLENAME VARCHAR(200)    
 DECLARE @result BIT ;     
 DECLARE @ErrMsg AS VARCHAR (1000);        
    DECLARE @ErrSeverity AS VARCHAR (100);      
    
 SET @vFILEPATH=@FilePath    
 SET @vSCHEMANAME=@SchemaName    
 SET @vTABLENAME=@TableName    
     
    
 DECLARE @TRUNCQUERY NVARCHAR(max)    
 DECLARE @BULKINSERT NVARCHAR(max)    
 DECLARE @TABLEDEF NVARCHAR(max)    
 DECLARE @PARAMLIST NVARCHAR(max)    
 DECLARE @COLUMNDEF VARCHAR(max)    
    
 DECLARE @TABLEDEF1 NVARCHAR(max)    
 DECLARE @PARAMS NVARCHAR(max)    
 DECLARE @COLUMNS VARCHAR(max)    
    
 DECLARE @T3TABLEDEF NVARCHAR(max)    
 DECLARE @T3PARAMS NVARCHAR(max)    
 DECLARE @T3COLUMNS VARCHAR(max)    
 DECLARE @DELETETARGET NVARCHAR(MAX)    
 DECLARE @T3PRIMARYKEYCOLUMNS VARCHAR(max)    
 DECLARE @LoadType INT    
    
 SELECT @LoadType= LoadType FROM AppAdmin.ti_adm_ObjectOwner WHERE ObjectName=@vTABLENAME AND SchemaName=@vSCHEMANAME  AND ObjectType='Table' and IsActive=1    
      
    
 IF (@LoadType=1)    
  BEGIN    
   SET @TRUNCQUERY =  N'TRUNCATE TABLE [' + @vSCHEMANAME + '].[' + @vTABLENAME + ']' ;   
    
   EXEC @result=sp_executesql @TRUNCQUERY    
  END    
        
    
 IF (@LoadType=3)    
  BEGIN    
   SET @T3TABLEDEF=N'SELECT @ColumnListOUT =     
    STRING_AGG( cast(    
    REPLACE( CONCAT(''['', COLUMN_NAME, '']'', '' '', DATA_TYPE, '' ('', CHARACTER_MAXIMUM_LENGTH, '')''), ''()'', '''') as NVARCHAR(MAX))    
    , '','')     
   FROM    
      INFORMATION_SCHEMA.COLUMNS    
   WHERE    
    TABLE_SCHEMA=@SCHNAME AND TABLE_NAME = @TBLNAME ';    
    
   SET @T3PARAMS = N'@SCHNAME VARCHAR(200), @TBLNAME VARCHAR(200), @COLUMNlISTOUT VARCHAR(max) OUTPUT'    
    
    
   DECLARE @PROPD VARCHAR(max)    
   EXEC @PROPD=sp_executesql @T3TABLEDEF , @T3PARAMS, @SCHNAME=@vSCHEMANAME, @TBLNAME = @vTABLENAME, @COLUMNLISTOUT = @T3COLUMNS OUTPUT;    
    
   --PRINT @T3COLUMNS    
    
   SET @T3TABLEDEF=N'SELECT @ColumnListOUT = ''ON '' + STRING_AGG(''il.'' + Col.Column_Name + ''=a.'' + Col.Column_Name,'' and '')    
       FROM     
       INFORMATION_SCHEMA.TABLE_CONSTRAINTS Tab INNER JOIN    
       INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE Col     
       ON     
       Col.Constraint_Name = Tab.Constraint_Name    
       AND Col.Table_Name = Tab.Table_Name    
       WHERE Constraint_Type = ''PRIMARY KEY''    
       AND Tab.TABLE_SCHEMA =  @SCHNAME    
       AND Col.Table_Name =  @TBLNAME'    
     
   SET @T3PARAMS = N'@SCHNAME VARCHAR(200), @TBLNAME VARCHAR(200), @COLUMNlISTOUT VARCHAR(max) OUTPUT'    
    
    
   DECLARE @PROPD1 VARCHAR(max)    
   EXEC @PROPD1=sp_executesql @T3TABLEDEF , @T3PARAMS, @SCHNAME=@vSCHEMANAME, @TBLNAME = @vTABLENAME, @COLUMNLISTOUT = @T3PRIMARYKEYCOLUMNS OUTPUT;    
    
   --PRINT @T3PRIMARYKEYCOLUMNS    
    
    
   SET @DELETETARGET= N'DELETE il    
   FROM (    
   SELECT *    
   FROM OPENROWSET (BULK ''' + @vFILEPATH + ''', DATA_SOURCE = ''TesserCredentialDS'',SINGLE_CLOB) as log_file    
   CROSS APPLY OPENJSON(BulkColumn)    
   WITH(    
   ' +  @T3COLUMNS + '    
   ) as log ) a    
   inner join [' + @vSCHEMANAME + '].[' + @vTABLENAME + '] as il ' +  @T3PRIMARYKEYCOLUMNS    
    
   --PRINT @DELETETARGET    
   EXEC sp_executesql @DELETETARGET    
  END    
    
    
  SET @TABLEDEF=N'SELECT @ColumnListOUT =     
   STRING_AGG( cast(    
   REPLACE( CONCAT(''['', COLUMN_NAME, '']'', '' '', CASE WHEN DATA_TYPE=''decimal'' THEN ''decimal(18,5)'' ELSE DATA_TYPE END, '' ('', CHARACTER_MAXIMUM_LENGTH, '')''), ''()'', '''') as NVARCHAR(MAX))    
   , '','')     
  FROM    
     INFORMATION_SCHEMA.COLUMNS    
  WHERE    
   TABLE_SCHEMA=@SCHNAME AND TABLE_NAME = @TBLNAME ';    
    
  SET @PARAMLIST = N'@SCHNAME VARCHAR(200),@TBLNAME VARCHAR(200), @COLUMNlISTOUT VARCHAR(max) OUTPUT'    
    
  SET @TABLEDEF1=N'SELECT @ColumnListOUT =     
   STRING_AGG( cast(    
   REPLACE( CONCAT(''['', COLUMN_NAME, '']'', '' '' ), ''()'', '''') as NVARCHAR(MAX))    
   , '','')     
  FROM    
     INFORMATION_SCHEMA.COLUMNS    
  WHERE    
   TABLE_SCHEMA=@SCHNAME AND TABLE_NAME = @TBLNAME ';    
    
  SET @PARAMS = N'@SCHNAME VARCHAR(200), @TBLNAME VARCHAR(200), @COLUMNlISTOUT VARCHAR(max) OUTPUT'    
    
    
    
   --PRINT @TABLEDEF    
  DECLARE @PROP VARCHAR(max)    
  EXEC @PROP=sp_executesql @TABLEDEF , @PARAMLIST, @SCHNAME=@vSCHEMANAME, @TBLNAME = @vTABLENAME, @COLUMNLISTOUT = @COLUMNDEF OUTPUT;    
    
    
  DECLARE @PROP1 VARCHAR(max)    
  EXEC @PROP1=sp_executesql @TABLEDEF1 , @PARAMS, @SCHNAME=@vSCHEMANAME, @TBLNAME = @vTABLENAME, @COLUMNLISTOUT = @COLUMNS OUTPUT;    
    
  --PRINT @COLUMNDEF    
  SET @BULKINSERT =  N'INSERT INTO [' + @vSCHEMANAME + '].[' + @vTABLENAME + ']'+   
  ' SELECT ' + @COLUMNS + ' FROM     
  OPENROWSET( BULK ''' + @vFILEPATH + ''', DATA_SOURCE = ''TesserCredentialDS'',SINGLE_CLOB) as a    
   CROSS APPLY OPENJSON(BulkColumn)    
    WITH ( '     
     + @COLUMNDEF +    
    ') as table1'    
  --print @BULKINSERT    
  EXEC sp_executesql @BULKINSERT    
      
END TRY    
    
BEGIN CATCH    
  SET @ErrMsg = ISNULL(LEFT(RTRIM(ERROR_MESSAGE()), 1000), '');        
        SET @ErrSeverity = ERROR_SEVERITY();        
        RAISERROR (@ErrMsg, @Errseverity, 1);        
    
END CATCH    
    
END    
