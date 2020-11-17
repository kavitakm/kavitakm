/****** Object:  UserDefinedTableType [AppAdmin].[ObjectList]    Script Date: 11/17/2020 1:38:37 PM ******/
CREATE TYPE [AppAdmin].[ObjectList] AS TABLE(
	[ObjectName] [varchar](200) NULL,
	[ObjectType] [varchar](50) NULL,
	[ObjectLocation] [varchar](1000) NULL,
	[Object_GUID] [uniqueidentifier] NULL,
	[Workspace_GUID] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[LastUpdatedDate] [datetime] NULL,
	[UserEmail] [varchar](200) NULL,
	[DatasetName] [varchar](500) NULL,
	[DatasetGUID] [uniqueidentifier] NULL
)