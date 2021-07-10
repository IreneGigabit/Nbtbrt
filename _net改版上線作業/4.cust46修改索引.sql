BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.Tmp_cust46
	(
	scode varchar(5) NOT NULL,
	custtype char(1) NOT NULL,
	cust_area char(1) NOT NULL,
	cust_seq int NOT NULL,
	id_no varchar(10) NOT NULL,
	apsqlno int NULL,
	apcust_no varchar(10) NOT NULL,
	ap_cname1 varchar(60) NULL,
	ap_cname2 varchar(60) NULL,
	ap_ename1 varchar(60) NULL,
	ap_ename2 varchar(60) NULL,
	ap_crep varchar(40) NULL,
	ap_erep varchar(80) NULL,
	pscode varchar(5) NULL,
	tscode varchar(5) NULL,
	pscode_name varchar(20) NULL,
	tscode_name varchar(20) NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.Tmp_cust46 SET (LOCK_ESCALATION = TABLE)
GO
IF EXISTS(SELECT * FROM dbo.cust46)
	 EXEC('INSERT INTO dbo.Tmp_cust46 (scode, custtype, cust_area, cust_seq, id_no, apsqlno, apcust_no, ap_cname1, ap_cname2, ap_ename1, ap_ename2, ap_crep, ap_erep, pscode, tscode, pscode_name, tscode_name)
		SELECT scode, custtype, cust_area, cust_seq, id_no, apsqlno, apcust_no, ap_cname1, ap_cname2, ap_ename1, ap_ename2, ap_crep, ap_erep, pscode, tscode, pscode_name, tscode_name FROM dbo.cust46 WITH (HOLDLOCK TABLOCKX)')
GO
DROP TABLE dbo.cust46
GO
EXECUTE sp_rename N'dbo.Tmp_cust46', N'cust46', 'OBJECT' 
GO
ALTER TABLE dbo.cust46 ADD CONSTRAINT
	PK_cust46 PRIMARY KEY CLUSTERED 
	(
	scode,
	custtype,
	cust_area,
	cust_seq,
	apcust_no
	) WITH( PAD_INDEX = OFF, FILLFACTOR = 90, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
COMMIT
