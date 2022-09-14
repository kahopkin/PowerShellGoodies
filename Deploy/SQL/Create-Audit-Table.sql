SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Audit](
    [Id] [varchar](50) NOT NULL,
    [OID] [varchar](50) NULL,
    [operationName] [varchar](250) NULL,
    [lastModifiedTime] [datetime2](7) NULL,
    [callerIpAddress] [varchar](250) NULL,
    [category] [varchar](250) NULL,
    [identityType] [varchar](250) NULL,
    [tenantId] [varchar](250) NULL,
    [upn] [varchar](250) NULL,
    [statusText] [nvarchar](250) NULL,
    [tlsVersion] [nvarchar](250) NULL,
    [ObjectKey] [nvarchar](500) NULL,
    [AccountName] [nvarchar](250) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
ALTER TABLE [dbo].[Audit] ADD PRIMARY KEY CLUSTERED
(
    [Id] ASC
)WITH (