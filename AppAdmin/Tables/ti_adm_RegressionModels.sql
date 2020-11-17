CREATE TABLE [AppAdmin].[ti_adm_RegressionModels](
	[ModelID] [int] NOT NULL,
	[ModelName] [varchar](100) NULL,
	[ObjectID] [int] NULL,
	[Variable] [varchar](100) NULL,
	[Dep_Ind_Flag] [char](1) NULL,
	[CoEfficient] [decimal](18, 6) NULL,
	[ModelVersion] [varchar](10) NULL,
	[rsquare] [decimal](18, 5) NULL
) ON [PRIMARY]