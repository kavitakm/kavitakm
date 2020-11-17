CREATE TABLE [AppAdmin].[ti_adm_ObjectAccessGrant](
	[ObjectID] [int] NOT NULL,
	[GrantToUser] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[LastUpdatedDate] [datetime] NULL,
	[LastUpdatedBy] [int] NULL,
	[IsActive] [bit] NULL,
	[Favourite] [bit] NULL,
	[EditAccess] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [AppAdmin].[ti_adm_ObjectAccessGrant]  WITH CHECK ADD  CONSTRAINT [FK_GrantObjectID_ObjectOwner] FOREIGN KEY([ObjectID])
REFERENCES [AppAdmin].[ti_adm_ObjectOwner] ([ObjectID])
GO

ALTER TABLE [AppAdmin].[ti_adm_ObjectAccessGrant] CHECK CONSTRAINT [FK_GrantObjectID_ObjectOwner]
GO
ALTER TABLE [AppAdmin].[ti_adm_ObjectAccessGrant]  WITH CHECK ADD  CONSTRAINT [FK_GrantUser_UserLU] FOREIGN KEY([GrantToUser])
REFERENCES [AppAdmin].[ti_adm_User_lu] ([UserID])
GO

ALTER TABLE [AppAdmin].[ti_adm_ObjectAccessGrant] CHECK CONSTRAINT [FK_GrantUser_UserLU]