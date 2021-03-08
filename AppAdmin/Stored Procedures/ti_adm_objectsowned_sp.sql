/****** Object:  StoredProcedure [AppAdmin].[ti_adm_objectsowned_sp]    Script Date: 1/19/2021 8:05:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--Exec [AppAdmin].[ti_adm_objectsowned_sp] 'srimathi@tesserinsights.com'
ALTER   PROC [AppAdmin].[ti_adm_objectsowned_sp] 
	@userEmail		 VARCHAR(100)
AS     
BEGIN        
/******************************************************
** Version               : 1.0               
** Author                : Sunitha        
** Description           : get the list of objects owned by user
** Date					 : 19-01-2021      

Version		Date		ChangedBy	ChangeDescr
1.1			2/17/2020	Srimathi	Added schemaID, audit columns in output. Used ti_adm_getUserID_fn to fetch userid
1.2			1/19/2021	Guru		Added Workspace_GUID,Object_GUID.
*******************************************************/
DECLARE @UserID int
SELECT @UserId = appadmin.ti_adm_getUserID_fn(@userEmail)

SELECT 
	o.objectid ObjectID
	,ObjectName
	,SCHEMA_ID(o.schemaname) SchemaID
	,SchemaName
	,ObjectType
	,objectlocation
	,@userEmail createdBy
	,o.Object_GUID
	,o.Workspace_GUID
	,o.CreatedDate 
	,updatedBy.userEmail LastUpdatedBy

FROM 
	appadmin.ti_adm_objectowner o
	,appadmin.ti_adm_user_lu updatedBy
WHERE 
	o.LastUpdatedBy = updatedBy.UserID 
	AND o.CreatedBy = @UserID 
	AND o.IsActive=1
​
--UNION
--SELECT DISTINCT schemaName,objectname,ObjectType,objectlocation 
--FROM appadmin.ti_adm_objectowner O
--JOIN appadmin.ti_adm_objectaccessgrant G
--ON o.objectId=G.ObjectID
--WHERE  o.isActive=1 AND G.GranttoUser=@UserID 

END
