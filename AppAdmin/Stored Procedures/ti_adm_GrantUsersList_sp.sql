CREATE   Proc [AppAdmin].[ti_adm_GrantUsersList_sp]          
@SchemaName varchar(100), -- will be blank in case of file or transform  
@ObjectName varchar(100), -- Table or file or Transform name  
@ObjectType varchar(50),  
@ObjectLocation varchar(500),  
@FileExt varchar(10),
@UserEmail varchar(100)  
As           
BEGIN      
/**************************************************************************      
** Version               : 1.0             
** Author                : Harini      
** Description           : Get List of users with Grant permission on an object from [ti_adm_ObjectAccessGrant] Table  
** Date      : 25-Sep-2019  

7-Sep-2020	Srimathi	Subscription ID filter condition added
       
*******************************************************************************/      
--SET NOCOUNT ON  
  
DECLARE @ObjectID int;  
DECLARE @owner_id int;  

  
 IF @ObjectType in ('Transform','Cleanse')  
  SELECT @ObjectId = OBJECTID, @owner_id = createdby FROM APPADMIN.ti_adm_ObjectOwner WHERE ObjectName = @ObjectName AND ObjectType = @ObjectType AND isactive = 1;  
 ELSE IF @ObjectType = 'File'  
  SELECT @ObjectId = OBJECTID, @owner_id = createdby  FROM APPADMIN.ti_adm_ObjectOwner WHERE ObjectName = @ObjectName AND ObjectLocation  = @ObjectLocation AND ObjectType ='File' AND FileExt = @FileExt AND isactive = 1;  
 ELSE   
  SELECT @ObjectId = OBJECTID, @owner_id = createdby  FROM APPADMIN.ti_adm_ObjectOwner WHERE ObjectName = @ObjectName AND SchemaName = @SchemaName AND ObjectType ='Table' AND isactive = 1;  
   
 SELECT   
  u.UserEmail, CASE WHEN g.GrantToUser IS NULL THEN 0 ELSE 1 END Granted  
 FROM [AppAdmin].[ti_adm_User_lu] as u   
 LEFT OUTER JOIN [AppAdmin].[ti_adm_ObjectAccessGrant] as g   
  ON u.UserID = g.GrantToUser AND g.IsActive = 1 AND g.ObjectID = @ObjectID   
 WHERE 
	u.isactive=1 
	and u.useremail != @UserEmail  
	and u.UserID <> @owner_id 
	--Added Subscription ID filter on 7-Sep-2020
	AND u.SubscriptionID = (select SubscriptionID from AppAdmin.TI_ADM_USER_LU WHERE UserEmail = @UserEmail AND isactive = 1)
 ORDER BY u.UserEmail  
  
  
END