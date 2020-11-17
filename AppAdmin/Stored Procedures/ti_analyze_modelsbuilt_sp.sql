CREATE PROCEDURE [AppAdmin].[ti_analyze_modelsbuilt_sp]
@SchemaName VARCHAR(100),
@TableName VARCHAR(100),
@UserEmail VARCHAR(100)
AS
BEGIN

/**************************************************************************  
** Version                : 1.0     
** Author                 : Srimathi  
** Description            : List Regression Models that are built on a table
** Date					  : 25-Feb-2020  
  
*******************************************************************************/ 


DECLARE @objectid int;
DECLARE @userId int;

SELECT @objectid = [AppAdmin].[ti_adm_getObjectID_fn](@TableName,'TABLE',@SchemaName,'','')
SELECT @userId = [AppAdmin].[ti_adm_getUserID_fn](@UserEmail)



SELECT modelid, Tableobjectid, modelname, [I] AS independent , [D] as [dependent], CASE WHEN o.createdby = @userId THEN 1 ELSE 0 END as owner_flag
		FROM
		(
			SELECT modelid, objectid as TableObjectId, modelname, isnull(dep_ind_flag,'N') dep_ind_flag,
			string_agg(variable,',') within group(order by variable) as varlist
			FROM appadmin.ti_adm_regressionmodels  group by modelid,objectid, modelname, dep_ind_flag
		) AS SourceTable  
		PIVOT  
		(  
			max(varlist) FOR dep_ind_flag IN ([I], [D], [N])  
		) AS PivotTable
		INNER JOIN appadmin.ti_adm_ObjectOwner o 
		ON
			modelid = o.objectid 
			AND o.IsActive = 1
		WHERE

		Tableobjectid = @objectid

END