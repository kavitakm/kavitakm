CREATE TABLE [AppAdmin].[ti_adm_EventMessage](
	[MessageID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [varchar](50) NULL,
	[Event] [varchar](50) NULL,
	[Outcome] [varchar](100) NULL,
	[Notify] [bit] NULL,
	[ImpForMyActivity] [bit] NULL,
	[MessageSent] [bit] NULL,
	[MessageRead] [bit] NULL,
	[MessageJSON] [varchar](max) NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[LastUpdatedBy] [int] NULL,
	[LastUpdatedDate] [datetime] NULL,
	[UserEmail] [varchar](100) NULL,
	MessageDismiss Bit NULL Default(0)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [AppAdmin].[ti_adm_EventMessage] ADD  CONSTRAINT [DF_ti_adm_EventMessage_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [AppAdmin].[ti_adm_EventMessage] ADD  CONSTRAINT [DF_ti_adm_EventMessage_LastUpdatedDate]  DEFAULT (getdate()) FOR [LastUpdatedDate]