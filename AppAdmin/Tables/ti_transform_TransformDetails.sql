CREATE TABLE [AppAdmin].[ti_transform_TransformDetails](
	[TransformId] [int] IDENTITY(1,1) NOT NULL,
	[TransformName] [varchar](100) NOT NULL,
	[RequestObject] [nvarchar](max) NULL,
	[OutputType] [varchar](100) NOT NULL,
	[OutputName] [varchar](100) NOT NULL,
	[SchemaName] [varchar](100) NULL,
	[CreatedDate] [date] NULL,
	[TransformQuery] [varchar](5000) NOT NULL,
	[Flag] [varchar](20) NOT NULL,
	[UserName] [varchar](100) NOT NULL,
	[Notes] [varchar](500) NULL,
	[Location] [varchar](2000) NULL,
	[TransactionType] [int] NULL,
	[StatisticsType] [int] NULL,
 CONSTRAINT [PK_ti_transform_TransformDetails] PRIMARY KEY CLUSTERED 
(
	[TransformId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]