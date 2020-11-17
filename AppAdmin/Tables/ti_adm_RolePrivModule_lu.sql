CREATE TABLE [AppAdmin].[ti_adm_RolePrivModule_lu](
	[RoleID] [int] NULL,
	[PrivilegeID] [int] NULL,
	[ModuleComponentID] [int] NULL,
	[CreatedBy] [varchar](200) NULL,
	[CreatedDate] [date] NULL,
	[UpdatedBy] [varchar](200) NULL,
	[UpdatedDate] [date] NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [AppAdmin].[ti_adm_RolePrivModule_lu]  WITH CHECK ADD  CONSTRAINT [FK_ti_adm_RolePrivModule_lu_ti_adm_ModuleComponent_lu] FOREIGN KEY([ModuleComponentID])
REFERENCES [AppAdmin].[ti_adm_ModuleComponent_lu] ([ModuleComponentID])
GO

ALTER TABLE [AppAdmin].[ti_adm_RolePrivModule_lu] CHECK CONSTRAINT [FK_ti_adm_RolePrivModule_lu_ti_adm_ModuleComponent_lu]
GO
ALTER TABLE [AppAdmin].[ti_adm_RolePrivModule_lu]  WITH CHECK ADD  CONSTRAINT [FK_ti_adm_RolePrivModule_lu_ti_adm_Privilege_lu] FOREIGN KEY([PrivilegeID])
REFERENCES [AppAdmin].[ti_adm_Privilege_lu] ([PrivilegeID])
GO

ALTER TABLE [AppAdmin].[ti_adm_RolePrivModule_lu] CHECK CONSTRAINT [FK_ti_adm_RolePrivModule_lu_ti_adm_Privilege_lu]
GO
ALTER TABLE [AppAdmin].[ti_adm_RolePrivModule_lu]  WITH CHECK ADD  CONSTRAINT [FK_ti_adm_RolePrivModule_lu_ti_adm_Roles_lu] FOREIGN KEY([RoleID])
REFERENCES [AppAdmin].[ti_adm_Roles_lu] ([RoleID])
GO

ALTER TABLE [AppAdmin].[ti_adm_RolePrivModule_lu] CHECK CONSTRAINT [FK_ti_adm_RolePrivModule_lu_ti_adm_Roles_lu]