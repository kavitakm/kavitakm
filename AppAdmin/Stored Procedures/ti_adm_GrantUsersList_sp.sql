

--exec  [AppAdmin].[ti_adm_GrantUsersList_sp] 'Sales','CreditUnion1','Table','','','Sunitha@tesserinsights.com',0
  
ALTER   Proc [AppAdmin].[ti_adm_GrantUsersList_sp]          
@SchemaName varchar(100), -- will be blank in case of file or transform  
@ObjectName varchar(100), -- Table or file or Transform name  
@ObjectType varchar(50),  
@ObjectLocation varchar(500),  
@FileExt varchar(10),
@UserEmail varchar(100),
@IsMasked bit
As           
BEGIN      
/**************************************************************************      
** Version               : 1.0             
** Author                : Harini      
** Description           : Get List of users with Grant permission on an object from [ti_adm_ObjectAccessGrant] Table  
** Date      : 25-Sep-2019  

7-Sep-2020	Srimathi	Subscription ID filter condition added
22-Dec-2020  Sunitha     Included IsMasked variable  and bringing the users based on Ismasked value
       
*******************************************************************************/      
--SET NOCOUNT ON  
  
DECLARE @ObjectID int;  
DECLARE @owner_id int;  
DECLARE @UserID int;

SELECT @userid = userid
FROM   appadmin.ti_adm_user_lu
WHERE  useremail = @useremail
    AND isactive = 1; 

  
 IF @ObjectType in ('Transform','Cleanse')  
  SELECT @ObjectId = OBJECTID, @owner_id = createdby FROM APPADMIN.ti_adm_ObjectOwner WHERE ObjectName = @ObjectName AND ObjectType = @ObjectType AND isactive = 1;  
 ELSE IF @ObjectType = 'File'  
  SELECT @ObjectId = OBJECTID, @owner_id = createdby  FROM APPADMIN.ti_adm_ObjectOwner WHERE ObjectName = @ObjectName AND ObjectLocation  = @ObjectLocation AND ObjectType ='File' AND FileExt = @FileExt AND isactive = 1;  
 ELSE   
  SELECT @ObjectId = OBJECTID, @owner_id = createdby  FROM APPADMIN.ti_adm_ObjectOwner WHERE ObjectName = @ObjectName AND SchemaName = @SchemaName AND ObjectType ='Table' AND isactive = 1;  
 If @IsMasked=1 -- If IsMAsked='true',select only the users which has the role of superuser and data analyst
 BEGIN
	SELECT   
	u.UserEmail, CASE WHEN g.GrantToUser IS NULL THEN 0 ELSE 1 END Granted  
	FROM [AppAdmin].[ti_adm_User_lu] as u   
	LEFT OUTER JOIN [AppAdmin].[ti_adm_ObjectAccessGrant] as g   
	ON u.UserID = g.GrantToUser AND g.IsActive = 1 AND g.ObjectID = @ObjectID 
	--JOIN [AppAdmin].[ti_adm_UserRole_lu]  ur on ur.UserID=u.UserID 
	JOIN [AppAdmin].[ti_adm_Roles_lu] r on r.RoleID=u.RoleID
	WHERE 
	u.isactive=1 
	and u.useremail != @UserEmail  
	and u.UserID <> @owner_id 
	--Added Subscription ID filter on 7-Sep-2020
	AND u.SubscriptionID = (select SubscriptionID from AppAdmin.TI_ADM_USER_LU WHERE UserEmail = @UserEmail AND isactive = 1)
	and r.RoleName in ('Data Analyst','SuperUser')
	ORDER BY u.UserEmail
  END
ELSE  -- If IsMAsked='false',list all the  users as like the previous output
BEGIN 
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
  
END  
GO


