CREATE TABLE [AppAdmin].[ti_adm_Privilege_lu](
	[PrivilegeID] [int] IDENTITY(1,1) NOT NULL,
	[PrivilegeName] [varchar](200) NULL,
	[CreatedBy] [varchar](200) NULL,
	[CreatedDate] [date] NULL,
	[UpdatedBy] [varchar](200) NULL,
	[UpdatedDate] [date] NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_adm_Privilege_lu] PRIMARY KEY CLUSTERED 
(
	[PrivilegeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]