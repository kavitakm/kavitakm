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