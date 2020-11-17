CREATE TABLE [AppAdmin].[ti_adm_bivariateTest_statisticDetails](
	[ObjectID] [int] NULL,
	[Column1Name] [varchar](200) NULL,
	[Column1Type] [varchar](100) NULL,
	[column1Category] [varchar](100) NULL,
	[Column2Name] [varchar](100) NULL,
	[Column2Type] [varchar](100) NULL,
	[column2Category] [varchar](100) NULL,
	[PValue] [decimal](18, 5) NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [date] NULL,
	[UpdatedBy] [int] NULL,
	[UpdatedDate] [date] NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]