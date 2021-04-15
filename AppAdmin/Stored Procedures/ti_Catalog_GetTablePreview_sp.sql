--exec[AppAdmin].[ti_Catalog_GetTablePreview_sp]  'Sandbox','Advertising1','','ALL'        
        
CREATE PROC [AppAdmin].[ti_Catalog_GetTablePreview_sp]             
   @schemaName varchar(30)='dbo',            
   @TableName varchar(50),            
   @SearchText varchar(100),            
   @SearchColumn Varchar(50)               
AS                         
BEGIN                    
/**************************************************************************                    
** Version               : 1.0                           
** Author                : Dinesh                    
** Description           : Generate table data list stored in SQL Server - used in Catalog list page                    
** Date      : 03-March-2020                    
                     
*******************************************************************************/                    
DECLARE @RCountquery nvarchar(2000)          
DECLARE @query nvarchar(2000)            
DECLARE @columnName NVARCHAR(100)            
DECLARE @sql nvarchar(1000)    
DECLARE @Countsql nvarchar(1000)          
SET @sql ='';          
SET @Countsql ='';           
 IF (LEN(TRIM(@SearchText)) > 0 AND UPPER(@SearchColumn) ='ALL')        
        
BEGIN            
            
  DECLARE columns CURSOR FOR           
            
  SELECT COLUMN_NAME   FROM INFORMATION_SCHEMA.COLUMNS   WHERE TABLE_NAME= @TableName and TABLE_SCHEMA= @schemaName            
              
  OPEN columns            
  FETCH NEXT FROM columns            
  INTO @columnName            
          
  --select 'Start: ' + convert(varchar(30),getdate(),9);        
  WHILE @@FETCH_STATUS = 0            
            
  BEGIN            
    if (len(@sql) = 0)           
  SET @sql = @sql +'['+ @columnName +'] LIKE ''%' + @SearchText + '%'''         
 else         
  SET @sql = @sql +' OR ['+ @columnName +'] LIKE ''%' + @SearchText + '%'''         
   FETCH NEXT FROM columns            
   INTO @columnName                
            
  END            
        
  CLOSE columns;                
  DEALLOCATE columns;            
            
END             
--select 'After cursor: ' + convert(varchar(30),getdate(),9);        
if (Len(Trim(@SearchText)) > 0 and upper(@SearchColumn) <> 'ALL' )            
BEGIN            
  SET @sql = @sql + '[' + @SearchColumn + '] LIKE ''%' + @SearchText + '%'''            
END            
        
 Set @query = N'SELECT Top(20) *  FROM [' + @schemaName + '].['+ @TableName +'];'    
 Set @Countsql =   N'SELECT Count(*) as RCount  FROM [' + @schemaName + '].['+ @TableName +'];'    
if (len(@sql)>0)           
BEGIN          
       
          
 Set @query = N'SELECT Top(20) *  FROM [' + @schemaName + '].['+ @TableName +'] WHERE ' + @sql  +';'     
 Set @Countsql =   N'SELECT Count(*) as RCount FROM [' + @schemaName + '].['+ @TableName +'] WHERE ' + @sql  +';'            
END              
   set @query = @query + @Countsql    
 Execute sp_executesql @query   ;              
       
                       
End 
GO
