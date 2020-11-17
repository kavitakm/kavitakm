CREATE TABLE [AppAdmin].[ti_adm_User_lu](
	[UserID] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [varchar](100) NULL,
	[LastName] [varchar](100) NULL,
	[UserEmail] [varchar](100) NULL,
	[Department] [varchar](100) NULL,
	[RoleID] [int] NOT NULL,
	[SupervisorID] [int] NULL,
	[SubscriptionID] [int] NULL,
	[Field1] [varchar](100) NULL,
	[CreatedBy] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[UpdatedBy] [int] NULL,
	[UpdatedDate] [datetime] NULL,
	[IsActive] [bit] NULL,
	[TAI_Enabled] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]