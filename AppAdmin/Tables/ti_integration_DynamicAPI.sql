CREATE TABLE [AppAdmin].[ti_integration_DynamicAPI](
	[APIID] [int] IDENTITY(1,1) NOT NULL,
	[APIName] [varchar](50) NULL,
	[APIDescription] [varchar](300) NULL,
	[SchemaName] [varchar](50) NULL,
	[TableName] [varchar](500) NULL,
	[InputColumns] [varchar](max) NULL,
	[OutputColumns] [varchar](max) NULL,
	[UserName] [varchar](200) NULL,
	[CreatedDate] [datetime] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_ti_integration_DynamicAPI] PRIMARY KEY CLUSTERED 
(
	[APIID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]