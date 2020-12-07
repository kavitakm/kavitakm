/****** Object:  StoredProcedure [AppAdmin].[ti_Catalog_GetTableDataList_sp]    Script Date: 01-12-2020 17:45:16 ******/


----exec [AppAdmin].[ti_Catalog_GetTableDataList_sp] 1,10,'Sandbox','Border_Crossing_Data','3422','ALL'
--exec [AppAdmin].[ti_Catalog_GetTableDataList_sp] 1,10,'Sandbox','Border_Crossing_Data','','ALL'

CREATE PROC [AppAdmin].[ti_Catalog_GetTableDataList_sp]				@PageNumber int =1,    
	  @PageSize int =10 ,    
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
** Date      : 10-Dec-2019            
             
*******************************************************************************/            
DECLARE @RCountquery nvarchar(2000)  
DECLARE @query nvarchar(2000)    
DECLARE @columnName NVARCHAR(100)    
DECLARE @sql nvarchar(1000)  
SET @sql ='';   
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

--Set @RCountquery =N'Select Count(*) from [' + @schemaName + '].['+ @TableName +'] ;'    
Set @query = N'SELECT count(*) over() ct,*  FROM [' + @schemaName + '].['+ @TableName +'] ORDER BY (SELECT NULL)  OFFSET ' + CONVERT(VARCHAR,@PageSize) +' * ( ' +CONVERT(VARCHAR,@PageNumber) +' - 1) ROWS FETCH NEXT ' + CONVERT(VARCHAR,@PageSize) + ' ROWS ONLY;' 
if len(@sql)=0
	SELECT @SQL='1=1'
--print @query  
if (len(@sql)>0)   
BEGIN  
	--set @sql=@sql+ '1=1' 
	--Set @RCountquery =N'SELECT COUNT(*) FROM [' + @schemaName + '].['+ @TableName +'] WHERE ' + @sql  + ' ;'
	 
	Set @query = N'SELECT count(*) over() ct, *  FROM [' + @schemaName + '].['+ @TableName +'] WHERE ' + @sql  +' ORDER BY (SELECT NULL)  OFFSET ' + CONVERT(VARCHAR,@PageSize) +' * ( ' + CONVERT(VARCHAR,@PageNumber) +' - 1) ROWS FETCH NEXT ' + CONVERT(VARCHAR,@PageSize) + ' ROWS ONLY;'    
END      

--select 'After query generation: ' + convert(varchar(30),getdate(),9);
--Execute sp_executesql @RCountquery;    
--select 'After count query: ' + convert(varchar(30),getdate(),9);
--print @RCountquery
--print @query     
 Execute sp_executesql @query;      
 --select 'End: ' + convert(varchar(30),getdate(),9);
               
End 



