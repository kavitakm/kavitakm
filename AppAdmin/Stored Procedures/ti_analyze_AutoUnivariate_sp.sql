CREATE     PROC [AppAdmin].[ti_analyze_AutoUnivariate_sp]          
     @SchemaName VARCHAR(100),@TableName VARCHAR(100)          
     ,@UserEmail VARCHAR(100)          
AS          
BEGIN          
/**************************************************************************        
**        
** Version Control Information        
** ---------------------------        
**        
**  Name                   : ti_analyze_AutoUnivariate_sp        
**  Version                : 1               
**  Date Created     : 11-09-2019           
**  Type                   : Stored Procedure        
**  Author                 : Sunitha        
***************************************************************************             
** Description             : <Purpose of SP>        
** Auto Anlaysis stored procedure for prediction                              
**              
** Modification Hist:               
**                    
** Date                           Name                                     Modification  
11-DEC-2020	Srimathi	Removed trim from column selection from information_schema.columns
*******************************************************************************/   
 --SET NOCOUNT ON  
BEGIN TRY  
  BEGIN TRANSACTION   
DECLARE @id INT=1;  
DECLARE @columnName nVARCHAR(100),@ColumnAlias VARCHAR(100);  
Declare @ErrMsg VARCHAR(1000);  
Declare @ErrSeverity VARCHAR(100);  
SET @ColumnAlias=@ColumnName;  
  
--temp table to store all the columns list for the given table  
IF OBJECT_ID('tempdb.dbo.#columnlist') IS NOT NULL  
 DROP TABLE #columnlist  
CREATE TABLE #columnlisttemp(id INT IDENTITY(1,1),columnName nVARCHAR(100))  
  
INSERT INTO #columnlisttemp(columnName)  
SELECT DISTINCT '[' + cols.COLUMN_NAME + ']' column_name  
FROM  INFORMATION_SCHEMA.COLUMNS cols     
INNER JOIN appadmin.ti_adm_objectowner o  
 ON o.SCHEMANAME = @SchemaName AND o.objectname = @tablename AND o.objecttype = 'Table' AND o.isactive = 1  
  
LEFT JOIN     
 (SELECT tab.Constraint_Type,Cons.COLUMN_NAME      
  FROM  INFORMATION_SCHEMA.TABLE_CONSTRAINTS Tab         
  INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE Cons  
 ON Cons.Constraint_Name = Tab.Constraint_Name AND cons.TABLE_SCHEMA = tab.TABLE_SCHEMA    
  WHERE Tab.Table_Name = @TableName AND tab.table_schema = @SchemaName  
  ) Tab   
 ON tab.column_name = cols.COLUMN_NAME    
WHERE Isnull(tab.Constraint_Type,'') NOT IN ('PRIMARY KEY', 'FOREIGN KEY')   
AND cols.data_type NOT IN ('geography','varbinary','uniqueidentifier')    
 AND cols.Table_Name = @TableName  AND cols.table_schema = @SchemaName  
  AND charindex('['+cols.column_name+']', ISNULL(o.maskedColumns,''))=0;   
 --select * from #columnlisttemp   
-- EXEC AppAdmin.ti_adm_analyze_loadSummaryStatistics_Univariate_sp @SchemaName,@TableName,@columnName,@columnAlias,@UserEmail  
 --Insert all the univariate records of a given table to ti_adm_summarystatistics table   
  
   select * from #columnlisttemp
WHILE @ID IS NOT NULL  
BEGIN  
  
 --The first select fetches data from the temporary table. The second select updates the @id. MIN returns null if no rows were selected.  
    SELECT  @columnName = columnName FROM #columnlisttemp where id=@id  
 set @columnAlias=@columnName  
 print @columnname  
 print 'univariate'  
    EXEC AppAdmin.ti_adm_analyze_loadSummaryStatistics_Univariate_sp @SchemaName,@TableName,@columnName,@columnAlias,@UserEmail    
    SELECT @id = MIN(id) FROM #columnlisttemp WHERE id > @id;  
END  
print 'univariate end'  
DROP TABLE #columnlisttemp;  
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