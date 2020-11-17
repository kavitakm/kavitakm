-- Exec [AppAdmin].[ti_adm_GetSchemaId_sp]   'Sandbox'   
-- =============================================        
-- Author:      Aravindh        
-- Create date: 11-Feb-2020       
-- Description: Return Database schema id         
-- =============================================        
CREATE PROCEDURE  [AppAdmin].[ti_adm_GetSchemaId_sp]        
@SchemaName varchar(100)    
AS        
BEGIN        
	SELECT 
		schema_id 
	FROM sys.schemas 
	WHERE name=@SchemaName
      
END