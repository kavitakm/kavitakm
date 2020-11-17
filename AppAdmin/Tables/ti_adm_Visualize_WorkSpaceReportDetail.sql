CREATE TABLE [AppAdmin].[ti_adm_Visualize_WorkSpaceReportDetail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[WorkSpaceID] [varchar](100) NULL,
	[ReportID] [varchar](100) NULL,
	[ClientName] [varchar](200) NULL,
	[CreatedBy] [varchar](200) NULL,
	[CreatedDate] [date] NULL,
	[UpdatedBy] [varchar](200) NULL,
	[UpdatedDate] [date] NULL,
	[IsActive] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]