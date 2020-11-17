CREATE TABLE [AppAdmin].[ti_adm_integrate](
	[APIID] [int] IDENTITY(1,1) NOT NULL,
	[ObjectID] [int] NOT NULL,
	[APIName] [varchar](50) NULL,
	[APIDescription] [varchar](500) NULL,
	[InputColumns] [varchar](max) NULL,
	[OutputColumns] [varchar](max) NULL,
	[CreatedDate] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[LastUpdatedDate] [datetime] NULL,
	[LastUpdatedBy] [int] NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_ti_adm_integrate] PRIMARY KEY CLUSTERED 
(
	[APIID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [AppAdmin].[ti_adm_integrate]  WITH CHECK ADD  CONSTRAINT [FK_ObjectID_ObjectOwner] FOREIGN KEY([ObjectID])
REFERENCES [AppAdmin].[ti_adm_ObjectOwner] ([ObjectID])
GO

ALTER TABLE [AppAdmin].[ti_adm_integrate] CHECK CONSTRAINT [FK_ObjectID_ObjectOwner]