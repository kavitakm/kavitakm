CREATE TABLE [AppAdmin].[ti_adm_load_type_lu](
	[LoadTypeID] [int] IDENTITY(1,1) NOT NULL,
	[LoadTypeName] [varchar](50) NULL,
	[CreatedBy] [varchar](200) NULL,
	[CreatedDate] [date] NULL,
	[UpdatedBy] [varchar](200) NULL,
	[UpdatedDate] [date] NULL,
	[IsActive] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[LoadTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]