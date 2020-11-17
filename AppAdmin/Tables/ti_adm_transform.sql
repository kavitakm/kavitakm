CREATE TABLE [AppAdmin].[ti_adm_transform](
	[TargetObjectId] [int] NOT NULL,
	[ObjectId] [int] NOT NULL,
	[TransformName] [varchar](100) NOT NULL,
	[RequestObject] [nvarchar](max) NULL,
	[TransformQuery] [varchar](max) NULL,
	[Notes] [varchar](500) NULL,
	[to_be_validated] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]