CREATE TABLE [AppAdmin].[ti_adm_SummaryStatistics](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ObjectID] [int] NULL,
	[Column1Name] [varchar](200) NULL,
	[Column1Value] [nvarchar](4000) NULL,
	[Column1Alias] [varchar](200) NULL,
	[Column2Name] [varchar](200) NULL,
	[Column2Value] [nvarchar](4000) NULL,
	[Column2Alias] [varchar](200) NULL,
	[Column3Name] [varchar](200) NULL,
	[Column3Value] [nvarchar](4000) NULL,
	[Column3Alias] [varchar](200) NULL,
	[Column4Name] [varchar](200) NULL,
	[Column4Value] [nvarchar](4000) NULL,
	[Column4Alias] [varchar](200) NULL,
	[Count] [int] NULL,
	[Complete] [int] NULL,
	[Missing] [int] NULL,
	[NoOfUniqueValues] [int] NULL,
	[Mean] [decimal](20, 2) NULL,
	[Median] [decimal](20, 2) NULL,
	[Mode] [decimal](20, 2) NULL,
	[P0] [decimal](20, 2) NULL,
	[P25] [decimal](20, 2) NULL,
	[P50] [decimal](20, 2) NULL,
	[P75] [decimal](20, 2) NULL,
	[P100] [decimal](20, 2) NULL,
	[WeightedMean] [decimal](20, 2) NULL,
	[HarmonicMean] [decimal](20, 2) NULL,
	[QuadraticMean] [decimal](20, 2) NULL,
	[Sum] [decimal](20, 2) NULL,
	[Min] [decimal](20, 2) NULL,
	[Max] [decimal](20, 2) NULL,
	[SD] [decimal](20, 2) NULL,
	[Variance] [decimal](20, 2) NULL,
	[Correlation] [decimal](20, 2) NULL,
	[CreatedDate] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[LastUpdatedDate] [datetime] NULL,
	[LastUpdatedBy] [int] NULL,
	[IsActive] [bit] NULL,
PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [AppAdmin].[ti_adm_SummaryStatistics]  WITH CHECK ADD  CONSTRAINT [FK_ti_adm_SummaryStatistics] FOREIGN KEY([ObjectID])
REFERENCES [AppAdmin].[ti_adm_ObjectOwner] ([ObjectID])
GO

ALTER TABLE [AppAdmin].[ti_adm_SummaryStatistics] CHECK CONSTRAINT [FK_ti_adm_SummaryStatistics]