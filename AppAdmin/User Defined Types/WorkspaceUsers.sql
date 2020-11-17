/****** Object:  UserDefinedTableType [AppAdmin].[WorkspaceUsers]    Script Date: 11/17/2020 1:38:38 PM ******/
CREATE TYPE [AppAdmin].[WorkspaceUsers] AS TABLE(
	[WorkspaceID] [uniqueidentifier] NULL,
	[WorkspaceName] [varchar](100) NULL,
	[ReaderUserEmails] [varchar](max) NULL,
	[WriterUserEmails] [varchar](max) NULL
)