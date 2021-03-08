/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/
INSERT INTO [AppAdmin].[ti_adm_FileDelimiters_lu]
(
	[DelimiterName],
	[DelimiterDisplayName],
	[CreatedDate],
	[LastUpdatedDate],
	[CreatedBy] ,
	[UpdatedBy] ,
	[IsActive]
)

VALUES
(',','Comma', CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,SYSTEM_USER,SYSTEM_USER,1),
(';','Semi Colon', CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,SYSTEM_USER,SYSTEM_USER,1),
('\t','Tab', CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,SYSTEM_USER,SYSTEM_USER,1),
('|','Pipe', CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,SYSTEM_USER,SYSTEM_USER,1);

GO


UPDATE [AppAdmin].[ti_adm_ObjectOwner] set FileDelimiterID =1 where ObjectType ='File';

GO
Update [AppAdmin].[ti_adm_RolePrivModule_lu] set IsActive =1
where RoleID in (
				Select RoleID from [AppAdmin].[ti_adm_Roles_lu] where RoleName  in ('SuperUser','Data Analyst','Data Explorer')
					and moduleComponentID in (Select ModuleComponentID from [AppAdmin].[ti_adm_ModuleComponent_lu]
											where Modulename ='Catalog' and moduleComponentName ='Table'))
				and PrivilegeID in (Select PrivilegeID from [AppAdmin].[ti_adm_Privilege_lu] where PrivilegeName in ( 'Mask Data','View Masked Data') )

--insert a new entry  for data explorer role for viewMaskedData previlege 
insert into [AppAdmin].[ti_adm_RolePrivModule_lu](RoleID,PrivilegeID,ModuleComponentID,CreatedBy,CreatedDate,UpdatedBy,UpdatedDate,IsActive)
select 2,14,1,11,getdate(),11,getdate(),1

GO

if (Select Count(*) from [AppAdmin].[ti_adm_User_lu] where UserEmail ='TesserPlatformSignIn@tesserinsights.com')=0
Begin
Insert into [AppAdmin].[ti_adm_User_lu](FirstName, LastName,UserEmail,Department,RoleId,SupervisorID,SubscriptionID,Field1,CreatedBy,CreatedDate,UpdatedBy,UpdatedDate,IsActive,TAI_Enabled)
Values('Tesser','Application','TesserPlatformSignIn@tesserinsights.com','APP',4,1,1,'',0,getdate(),0,getdate(),1,1)
End

Go