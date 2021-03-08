--exec [AppAdmin].[ti_adm_viewDependencies_sp] 'SalesData22_05','Table','Sandbox','','','dinesh@tesserinsights.com'
ALTER PROCEDURE  [AppAdmin].[ti_adm_viewDependencies_sp]                     
@ObjectName Varchar(200),              
@ObjectType Varchar(50),              
@SchemaName Varchar(50),              
@ObjectLocation VARCHAR(200),  
@FileExt Varchar(10),  
@UserEmail Varchar(150)                 
               
AS                  
BEGIN     
  
/**************************************************************************    
** Version                : 1.0     
** Author                 : Srimathi    
** Description            : View Dependencies of an object
** Date					  : 24-Oct-2019    
**History
** Sunitha   22-Dec-2020    updated the length of objectName to 100 
  

*******************************************************************************/    
DECLARE @userid int;  
Declare @ObjectID int;
DECLARE @tblname VARCHAR(100);
DECLARE @log VARCHAR(200);
DECLARE @str NVARCHAR(500);
 
	SET @tblname = '[' + @SchemaName + '].[' + @objectname + ']';
	SELECT @ObjectID = ObjectID FROM [AppAdmin].[ti_adm_ObjectOwner] WHERE SchemaName = @SchemaName AND ObjectLocation = @ObjectLocation AND ObjectName = @ObjectName AND fileext = @FileExt and objectType = @ObjectType AND IsActive = 1  ;

	IF OBJECT_ID('tempdb.dbo.#tmp') IS NOT NULL
		DROP TABLE #tmp
	CREATE TABLE #tmp(Objecttype VARCHAR(20), ObjectName VARCHAR(100))

	INSERT INTO #tmp 
	SELECT 'TRANSFORM', TRANSFORMNAME FROM APPADMIN.ti_adm_transform t INNER JOIN appadmin.ti_adm_ObjectOwner o  ON t.objectid = o.ObjectID 
	WHERE CHARINDEX(@tblname, t.TransformQuery) > 0 AND o.isactive = 1
	UNION
	SELECT 'INTEGRATE', APIName FROM APPADMIN.ti_adm_integrate 
	WHERE OBJECTID in (SELECT objectid FROM appadmin.ti_adm_ObjectOwner WHERE schemaname = @schemaname AND objectname = @objectname AND objecttype ='TABLE' AND ISACTIVE = 1) 
	UNION
	SELECT 'MODELS', ModelName FROM APPADMIN.ti_adm_RegressionModels 
	WHERE ObjectID in (SELECT objectid FROM appadmin.ti_adm_ObjectOwner WHERE schemaname = @schemaname AND objectname = @objectname AND objecttype ='TABLE' AND IsActive =1) ;

	SELECT * FROM #tmp;
	DROP TABLE #tmp;

END  
GO


