CREATE TABLE [AppAdmin].[ti_adm_Roles_lu](
	[RoleID] [int] IDENTITY(1,1) NOT NULL,
	[RoleName] [varchar](200) NULL,
	[CreatedBy] [varchar](200) NULL,
	[CreatedDate] [date] NULL,
	[UpdatedBy] [varchar](200) NULL,
	[UpdatedDate] [date] NULL,
	[IsActive] [bit] NULL,
	[IsBaseRole] [bit] NULL,
	[BaseRoleID] [int] NULL,
 CONSTRAINT [PK_ti_adm_Roles_lu] PRIMARY KEY CLUSTERED 
(
	[RoleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [AppAdmin].[ti_adm_Roles_lu] ADD  CONSTRAINT [DF_ti_adm_Roles_lu_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [AppAdmin].[ti_adm_Roles_lu] ADD  CONSTRAINT [DF_ti_adm_Roles_lu_UpdatedDate]  DEFAULT (getdate()) FOR [UpdatedDate]
GO
ALTER TABLE [AppAdmin].[ti_adm_Roles_lu] ADD  CONSTRAINT [DF_ti_adm_Roles_lu_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [AppAdmin].[ti_adm_Roles_lu] ADD  DEFAULT ((0)) FOR [IsBaseRole]