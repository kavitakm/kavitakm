-- exec [AppAdmin].[ti_Analyze_GetNumericColumns_sp]  '',''
CREATE PROCEDURE [AppAdmin].[ti_Analyze_GetNumericColumns_sp]          
@SchemaName varchar(100),            
@TableName varchar(100)      
AS          
BEGIN          
          
/**************************************************************************            
** Version                : 1.0               
** Author                 : Srimathi            
** Description            : List all numeric columns other than primary key/foreign key        
** Date       : 04-Sep-2019            
            
*******************************************************************************/           
      
      
--SELECT distinct cols.COLUMN_NAME, cols.DATA_TYPE  from       
-- INFORMATION_SCHEMA.COLUMNS cols LEFT OUTER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS Tab ON cols.TABLE_SCHEMA = tab.TABLE_SCHEMA and cols.TABLE_NAME = tab.TABLE_NAME      
-- left outer JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE Cons ON Cons.Constraint_Name = Tab.Constraint_Name AND cons.TABLE_SCHEMA = tab.TABLE_SCHEMA     
--  and  Cons.Table_Name = Tab.Table_Name and cols.column_name = cons.COLUMN_NAME       
-- WHERE Isnull(tab.Constraint_Type,'') not in ('PRIMARY KEY', 'FOREIGN KEY')    
--    AND cols.Table_Name = @TableName      
-- and cols.table_schema = @SchemaName      
-- and cols.data_type in ('Money','Int','TinyInt','bigint','smallint','bit','numeric','small money','float','real','decimal')     
  
SELECT DISTINCT cols.COLUMN_NAME, '['+cols.column_name+']' column_name_enclosed, cols.DATA_TYPE   FROM       
 INFORMATION_SCHEMA.COLUMNS cols   
 Left join   
 (SELECT tab.Constraint_Type,Cons.COLUMN_NAME    
   FROM  INFORMATION_SCHEMA.TABLE_CONSTRAINTS Tab       
   INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE Cons ON Cons.Constraint_Name = Tab.Constraint_Name AND cons.TABLE_SCHEMA = tab.TABLE_SCHEMA  
 WHERE Tab.Table_Name = @TableName and tab.table_schema = @SchemaName ) Tab on tab.column_name = cols.COLUMN_NAME  
 WHERE Isnull(tab.Constraint_Type,'') not in ('PRIMARY KEY', 'FOREIGN KEY')   
  and cols.Table_Name = @TableName   
  and cols.table_schema = @SchemaName  
 AND cols.data_type IN ('Money','Int','TinyInt','bigint','smallint','bit','numeric','small money','float','real','decimal','char','nchar','varchar','nvarchar') 
 order by cols.column_name
      
END