CREATE  PROC [AppAdmin].[ti_adm_SyncPBI_ObjectGrantAccess_sp]  
@workspaceUsersList appadmin.WorkspaceUsers readonly

AS  
BEGIN  

 /******************************************************
** Version               : 1.0               
** Author                : Srimathi
** Description           : PBI Object - Users access information in ti_adm_object_accessgrant
** Date					 : 13-Aug-2020

29-Sep-2020	Srimathi	Filter condition added to check if granttoUser is the owner or not.  Owner should not have an entry in GrantAccessTable
21-oct-2020 Sunitha     Added Transaction to the Stored Proc
04-DEC-2020	Srimathi	Replaced delete/insert with merge to retain favourite flag
11-DEC-2020	Srimathi	Modified merge to modify only powerbi objects
*******************************************************/ 
BEGIN TRY  
  BEGIN TRANSACTION   
Declare @ErrMsg VARCHAR(1000);  
Declare @ErrSeverity VARCHAR(100);  

IF OBJECT_ID('TempDB..#ObjectGrantList') IS NOT NULL  
 DROP TABLE #ObjectGrantList  
 SELECT * INTO #ObjectGrantList  
 FROM appadmin.ti_adm_ObjectAccessGrant where 1=0
    
/* Modified on 04-dec-2020 to replace delete and insert with MERGE statement to retain favourite flag value.
--Delete all existing acccess information for the listed workspaces
delete from appadmin.ti_adm_ObjectAccessGrant 
where 
	objectid in (
		select objectid from appadmin.ti_adm_objectowner 
		where workspace_GUID in(
			select workspaceID from @workspaceUsersList))
*/
insert into #ObjectGrantList  
SELECT obj.Objectid, users.UserID, getdate(), obj.createdby,getdate(), obj.createdby, 1,0, users.EditAccess
FROM 
	appadmin.ti_adm_objectowner obj
	INNER JOIN
	@workspaceUsersList wUsers
	ON obj.workspace_GUID = wUsers.workspaceID
	INNER JOIN
	(select userid, userEmail, 0 as editaccess from appadmin.ti_adm_user_lu user_reader WHERE isactive = 1
	UNION
	select userid, userEmail, 1 as editaccess from appadmin.ti_adm_user_lu user_writer where isactive = 1) users
	ON ( users.UserEmail in (SELECT trim(VALUE) 
		FROM string_split(wUsers.ReaderUserEmails,',')) AND users.EditAccess = 0)
		or
		( users.UserEmail in (SELECT trim(VALUE) 
		FROM string_split(wUsers.WriterUserEmails,',')) AND users.EditAccess = 1)
	 
	where
		obj.isactive = 1
		AND obj.objecttype in ('Dataset','Report','Dashboard')
		AND ISNULL(obj.CreatedBy,-1) <> users.UserID		--owner of object should not be added in accessgrant table

MERGE 
appadmin.ti_adm_objectaccessgrant 
	
as TARGET
USING #objectGrantList AS SOURCE 
ON (TARGET.Objectid = SOURCE.Objectid and TARGET.granttouser = SOURCE.granttouser) 
--When records are matched, update the records if there is any change
--WHEN MATCHED AND TARGET.favourite = 1 
--THEN UPDATE SET TARGET.ProductName = SOURCE.ProductName, TARGET.Rate = SOURCE.Rate 
--When no records are matched, insert the incoming records from source table to target table
WHEN NOT MATCHED BY TARGET 
THEN INSERT values (SOURCE.objectid, SOURCE.GRANTTOUSER, SOURCE.CREATEDDATE, SOURCE.CREATEDBY, SOURCE.LASTUPDATEDDATE, SOURCE.LASTUPDATEDBY, SOURCE.ISACTIVE, SOURCE.FAVOURITE, SOURCE.EDITACCESS)
--When there is a row that exists in target and same record does not exist in source then delete this record target
WHEN NOT MATCHED BY SOURCE and target.objectid in (select objectid from appadmin.ti_adm_objectowner where objecttype in ('Report','Dataset','Dashboard'))
THEN DELETE;   
COMMIT TRANSACTION  
END TRY   
  BEGIN CATCH  
  IF @@trancount>0  
 ROLLBACK TRANSACTION  
  SET @ErrMsg = ISNULL(LEFT(RTRIM(ERROR_MESSAGE()),1000),'')               
  SET @ErrSeverity=ERROR_SEVERITY()  
  RAISERROR(@ErrMsg,@Errseverity,1)  
END CATCH 
END