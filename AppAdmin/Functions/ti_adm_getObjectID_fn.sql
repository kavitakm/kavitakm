--select [AppAdmin].[ti_adm_getObjectID_fn]('CPA_Accounting_Report','Report','','CPA','','Dinesh@tesserinsights.com')
CREATE FUNCTION [AppAdmin].[ti_adm_getObjectID_fn]
( 
	@ObjectName	   VARCHAR(200), 
    @ObjectType		 VARCHAR(100),
	@SchemaName		 VARCHAR(50),	
	@ObjectLocation  VARCHAR(200),
	@FileExt		 VARCHAR(50)
)  
RETURNS INT  
/******************************************************
** Version               : 1.0               
** Author                : Sunitha        
** Description           :  get the objectID for the given objectName        
** Date					 : 16-12-2019 
*******************************************************/
BEGIN   
	RETURN 
		(SELECT  ObjectID 
		FROM appadmin.ti_adm_objectowner 
		WHERE 
			ObjectType = @ObjectType 
			AND ObjectName = @ObjectName 
			AND ISNULL(SchemaName,'') = @SchemaName
			AND ISNULL(ObjectLocation,'') = @ObjectLocation
			AND ISNULL(FileExt,'') = @FileExt
			AND IsActive=1 
		)
	   

END