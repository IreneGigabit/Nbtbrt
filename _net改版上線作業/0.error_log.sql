SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[error_log](
	[sqlno] [int] IDENTITY(1,1) NOT NULL,
	[log_date] [datetime] NOT NULL,
	[log_uid] [varchar](30) NOT NULL,
	[syscode] [varchar](20) NOT NULL,
	[prgid] [varchar](15) NOT NULL,
	[MsgStr] [nvarchar](4000) NULL,
	[SQLstr] [nvarchar](max) NULL,
	[StackStr] [nvarchar](max) NULL,
 CONSTRAINT [PK_error_log] PRIMARY KEY CLUSTERED 
(
	[sqlno] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[error_log] ADD  CONSTRAINT [DF_error_log_log_date]  DEFAULT (getdate()) FOR [log_date]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'序號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'error_log', @level2type=N'COLUMN',@level2name=N'sqlno'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'錯誤發生日期時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'error_log', @level2type=N'COLUMN',@level2name=N'log_date'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'執行者' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'error_log', @level2type=N'COLUMN',@level2name=N'log_uid'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'系統代碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'error_log', @level2type=N'COLUMN',@level2name=N'syscode'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'功能代碼' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'error_log', @level2type=N'COLUMN',@level2name=N'prgid'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'錯誤訊息' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'error_log', @level2type=N'COLUMN',@level2name=N'MsgStr'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SQL指令' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'error_log', @level2type=N'COLUMN',@level2name=N'SQLstr'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'錯誤堆疊' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'error_log', @level2type=N'COLUMN',@level2name=N'StackStr'
GO


