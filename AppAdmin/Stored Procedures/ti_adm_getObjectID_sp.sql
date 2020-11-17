CREATE   PROC [AppAdmin].[ti_adm_getObjectID_sp]	   @objectName	   VARCHAR(200), 
   @ObjectType		 VARCHAR(100),
	@SchemaName		 VARCHAR(50),	
	@objectLocation  VARCHAR(200),
	@FileExt		 VARCHAR(50),
	@userEmail		 VARCHAR(100)
AS             
BEGIN        
/******************************************************
** Version               : 1.0               
** Author                : Sunitha        
** Description           : get the objectId based on objectNames        
** Date					 : 16-12-2019           
*******************************************************/ 
SELECT ObjectID 
FROM appadmin.ti_adm_objectowner 
WHERE objecttype=@objecttype
	AND objectName=@objectName
	AND (schemaName=@SchemaName OR schemaName is NULL)
	AND (objectlocation=@objectlocation OR objectlocation IS NULL)
	AND (FileExt=@FileExt OR FileExt IS NULL)
	AND isActive=1

END