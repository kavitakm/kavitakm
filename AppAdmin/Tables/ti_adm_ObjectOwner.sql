CREATE TABLE [AppAdmin].[ti_adm_ObjectOwner](
	[ObjectID] [int] IDENTITY(1,1) NOT NULL,
	[ObjectName] [varchar](200) NOT NULL,
	[ObjectType] [varchar](50) NULL,
	[SchemaName] [varchar](50) NULL,
	[ObjectLocation] [varchar](200) NULL,
	[CreatedDate] [datetime] NULL,
	[LastUpdatedDate] [datetime] NULL,
	[IsActive] [bit] NULL,
	[FileExt] [varchar](10) NULL,
	[FileSize] [int] NULL,
	[CreatedBy] [int] NULL,
	[LastUpdatedBy] [int] NULL,
	[maskedColumns] [varchar](max) NULL,
	[Favourite] [bit] NULL,
	[TAI_Enabled] [bit] NULL,
	[Object_GUID] [uniqueidentifier] NULL,
	[Workspace_GUID] [uniqueidentifier] NULL,
	[LoadType] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ObjectID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]