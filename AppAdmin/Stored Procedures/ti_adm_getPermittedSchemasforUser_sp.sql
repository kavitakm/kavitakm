/****** Object:  StoredProcedure [AppAdmin].[ti_adm_getPermittedSchemasforUser_sp]    Script Date: 01-Apr-21 3:48:22 PM ******/
--Exec [AppAdmin].[ti_adm_getPermittedSchemasforUser_sp_new] 'srimathi@tesserinsights.com','wr'

CREATE PROCEDURE  [AppAdmin].[ti_adm_getPermittedSchemasforUser_sp]                   
@UserEmail Varchar(150),
@readWrite Varchar(10)--rd/wr
AS
BEGIN
/**************************************************************************    
** Version                : 1.0     
** Author                 : Srimathi    
** Description            : Prepare a list of permitted schemas for the user
** Date					  : 23-Aug-2019    
  ** Date   Version   Changes  
**  
     ******* To be edited to allow impersonation after implementing MFA.  Uncomment the Execute as user and Revert statements ************
04-mar-2020   Sunitha added the userschema 
03-DEC-2020	  Srimathi	Removed EnterpriseData and User Schema from default schema list, to treat all schemas other than Sandbox as Enterprise Schema
29-MAR-2021   Srimathi	Default schema changed to Field1 column of ti_adm_user_lu instead of hardcoded 'Sandbox'

*******************************************************************************/ 
Declare @User varchar(50);
Select @User=substring(@userEmail,0,charindex('@',@userEmail))

--Default schemas
Select Name as schemaName, SCHEMA_ID(Name) SchemaID
From Sys.schemas s
	INNER JOIN [AppAdmin].[ti_adm_User_lu] u
	ON s.Name = u.Field1
	--Where Name in (@User,'sandbox','EnterpriseData')   Commented on 03-Dec-2020 by Srimathi to treat all schemas other than Sandbox as Enterprise Schema
WHERE 
	u.UserEmail = @UserEmail
	AND u.IsActive = 1

Union
--user object related schemas
Select  SchemaName, SCHEMA_ID(SchemaName) SchemaID
from AppAdmin.ti_adm_ObjectOwner o
where CreatedBy=[AppAdmin].[ti_adm_getUserID_fn](@UserEmail) and len(SchemaName)>0
UNION
--schemas for which he has read access
Select  SchemaName, SCHEMA_ID(SchemaName) SchemaID
from AppAdmin.ti_adm_ObjectOwner o
join AppAdmin.ti_adm_ObjectAccessGrant g 
	on o.objectID=g.objectID 
where g.GrantToUser=[AppAdmin].[ti_adm_getUserID_fn](@UserEmail)
	and o.IsActive=1 and @readWrite='rd' and len(SchemaName)>0



END

GO


