CREATE TABLE [AppAdmin].[ti_adm_ModuleComponent_lu](
	[ModuleComponentID] [int] IDENTITY(1,1) NOT NULL,
	[ModuleName] [varchar](200) NULL,
	[ModuleComponentName] [varchar](200) NULL,
	[CreatedBy] [varchar](200) NULL,
	[CreatedDate] [date] NULL,
	[UpdatedBy] [varchar](200) NULL,
	[UpdatedDate] [date] NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_ti_adm_ModuleComponent_lu] PRIMARY KEY CLUSTERED 
(
	[ModuleComponentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [AppAdmin].[ti_adm_ModuleComponent_lu] ADD  CONSTRAINT [DF_ti_adm_ModuleComponent_lu_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [AppAdmin].[ti_adm_ModuleComponent_lu] ADD  CONSTRAINT [DF_ti_adm_lutModuleComponent_lu_UpdatedDate]  DEFAULT (getdate()) FOR [UpdatedDate]
GO
ALTER TABLE [AppAdmin].[ti_adm_ModuleComponent_lu] ADD  CONSTRAINT [DF_ti_adm_ModuleComponent_lu_IsActive]  DEFAULT ((1)) FOR [IsActive]