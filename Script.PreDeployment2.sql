CREATE TABLE [AppAdmin].[ti_adm_FileDelimiters_lu](
	[DelimiterID] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[DelimiterName] [varchar](50) NULL,
	[DelimiterDisplayName] [varchar](10) NULL,
	[CreatedDate] [datetime] NULL,
	[LastUpdatedDate] [datetime] NULL,
	[CreatedBy] [varchar](200) NULL,
	[UpdatedBy] [varchar](200) NULL,
	[IsActive] [bit] NULL
) 

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


CREATE PROCEDURE [AppAdmin].[ti_adm_GetAllFileDelimiters_sp]
AS
BEGIN

	SELECT
	[DelimiterID],
	[DelimiterName],
	[DelimiterDisplayName]
	FROM
	[AppAdmin].[ti_adm_FileDelimiters_lu]
	WHERE
	[IsActive]=1;

END

--Update [AppAdmin].[ti_adm_RolePrivModule_lu] set IsActive =1
--update ti_adm_RolePrivModule_lu  to enable maskdata and viewMAskdata privilege
Update [AppAdmin].[ti_adm_RolePrivModule_lu] set IsActive =1
where RoleID in (
				Select RoleID from [AppAdmin].[ti_adm_Roles_lu] where RoleName  in ('SuperUser','Data Analyst','Data Explorer')
					and moduleComponentID in (Select ModuleComponentID from [AppAdmin].[ti_adm_ModuleComponent_lu]
											where Modulename ='Catalog' and moduleComponentName ='Table'))
				and PrivilegeID in (Select PrivilegeID from [AppAdmin].[ti_adm_Privilege_lu] where PrivilegeName in ( 'Mask Data','View Masked Data') )

--insert a new entry  for data explorer role for viewMaskedData previlege 
insert into [AppAdmin].[ti_adm_RolePrivModule_lu](RoleID,PrivilegeID,ModuleComponentID,CreatedBy,CreatedDate,UpdatedBy,UpdatedDate,IsActive)
select 2,14,1,11,getdate(),11,getdate(),1

----------------------------------
--ADd Column MessageDismiss as part of task411 &412
ALTER TABLE [AppAdmin].[ti_adm_EventMessage]
        ADD MessageDismiss Bit NULL 
 CONSTRAINT D_ti_adm_EventMessage_MessageDismiss
    DEFAULT (0)
WITH VALUES 






----------------------------------------------
