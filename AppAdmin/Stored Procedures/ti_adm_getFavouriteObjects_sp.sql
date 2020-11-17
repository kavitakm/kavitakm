--Exec [AppAdmin].[ti_adm_getFavouriteObjects_sp] 'sunitha@tesserinsights.com'  
CREATE  PROC [AppAdmin].[ti_adm_getFavouriteObjects_sp]   
 @userEmail   VARCHAR(100)  
AS               
BEGIN          
/******************************************************  
** Version               : 1.0                 
** Author                : Srimathi         
** Description           : Get list of favourite objects of a user         
** Date      : 02-17-2020             
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
FROM 
 appadmin.ti_adm_objectowner o  
 , appadmin.ti_adm_user_lu createdBy  
 , appadmin.ti_adm_user_lu updatedBy  
WHERE   
 o.CreatedBy = createdBy.UserID   
 AND o.LastUpdatedBy = updatedBy.UserID   
 AND o.CreatedBy = @UserID   
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
FROM    
 appadmin.ti_adm_objectowner o  
 , appadmin.ti_adm_ObjectAccessGrant g  
 , appadmin.ti_adm_user_lu createdBy  
 , appadmin.ti_adm_user_lu updatedBy  
WHERE   
 o.objectid = g.objectid  
 AND o.CreatedBy = createdBy.UserID   
 AND o.LastUpdatedBy = updatedBy.UserID   
 AND g.GrantToUser = @UserID   
 AND g.IsActive = 1  
 AND o.IsActive = 1  
 AND o.ObjectType in ('File','Table','Dataset','Report','Dashboard')  
 AND g.Favourite = 1  
END