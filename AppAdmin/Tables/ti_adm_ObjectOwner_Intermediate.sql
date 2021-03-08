CREATE TABLE [AppAdmin].[ti_adm_ObjectOwner_Intermediate](
	[ObjectID] [bigint] IDENTITY(1,1) NOT NULL,
	[ObjectName] [varchar](50) NULL,
	[ObjectType] [varchar](50) NULL,
	[SchemaName] [varchar](50) NULL,
	[CreatedDate] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[IsActive] [bit] NULL,
	[UserEmail] [varchar](50) NULL
) ON [PRIMARY]