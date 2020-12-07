CREATE  PROC [AppAdmin].[ti_adm_getFavouriteObjects_sp]   
 @userEmail   VARCHAR(100)  
AS               
BEGIN          
/******************************************************  
** Version               : 1.0                 
** Author                : Srimathi         
** Description           : Get list of favourite objects of a user         
** Date      : 02-17-2020     

04-DEC-2020	Srimathi	Added Object GUID and Workspace GUID in select output.  Made outer join with createdby, lastupdatedby aliases
*******************************************************/  
DECLARE @UserID int  
SELECT @UserId = appadmin.ti_adm_getUserID_fn(@userEmail)  
  
SELECT   
 o.ObjectID  
 , ObjectName  
 , schema_id(schemaname) SchemaID  
 , SchemaName  
 , ObjectType  
 , ObjectLocation  
 , FileExt  
 , createdBy.userEmail CreatedBy  
 , updatedBy.userEmail LastUpdatedBy
  , o.Favourite AS Favourite  
  , o.Object_GUID as Object_GUID
  , o.Workspace_GUID as Workspace_GUID
FROM 
 appadmin.ti_adm_objectowner o  
 LEFT JOIN [AppAdmin].[ti_adm_User_lu] createdBy 
		ON createdBy.UserID = o.CreatedBy  
 LEFT JOIN [AppAdmin].[ti_adm_User_lu] updatedBy 
		ON updatedBy.UserID=o.LastUpdatedBy 
 --, appadmin.ti_adm_user_lu createdBy  
 --, appadmin.ti_adm_user_lu updatedBy  
WHERE   
 --o.CreatedBy = createdBy.UserID   
 --AND o.LastUpdatedBy = updatedBy.UserID   
 --AND 
 o.CreatedBy = @UserID   
 AND o.IsActive = 1  
 AND o.ObjectType in ('File','Table','Dataset','Report','Dashboard')  
 AND o.Favourite = 1  
  
UNION  
  
SELECT   
 o.ObjectID  
 , ObjectName  
 , schema_id(schemaname) SchemaID  
 , SchemaName  
 , ObjectType  
 , ObjectLocation  
 , FileExt  
 , createdBy.userEmail CreatedBy  
 , updatedBy.userEmail LastUpdatedBy 
  , g.Favourite AS Favourite 
  , o.Object_GUID as Object_GUID
  , o.Workspace_GUID as Workspace_GUID
FROM    
 appadmin.ti_adm_objectowner o  
 inner join appadmin.ti_adm_ObjectAccessGrant g  
	on o.objectid = g.objectid  
 LEFT JOIN [AppAdmin].[ti_adm_User_lu] createdBy 
		ON createdBy.UserID = o.CreatedBy  
 LEFT JOIN [AppAdmin].[ti_adm_User_lu] updatedBy 
		ON updatedBy.UserID=o.LastUpdatedBy  
WHERE   
 
 --AND o.CreatedBy = createdBy.UserID   
 --AND o.LastUpdatedBy = updatedBy.UserID   
 g.GrantToUser = @UserID   
 AND g.IsActive = 1  
 AND o.IsActive = 1  
 AND o.ObjectType in ('File','Table','Dataset','Report','Dashboard')  
 AND g.Favourite = 1  
END  