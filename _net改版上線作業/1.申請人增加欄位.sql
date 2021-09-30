--備份dmt_ap
select * into dbo.dmt_ap_20210903 from dmt_ap
--dmt_ap增加排序欄位
BEGIN TRANSACTION
GO
ALTER TABLE dbo.dmt_ap ADD
	ap_sort varchar(2) NULL
GO
ALTER TABLE dbo.dmt_ap SET (LOCK_ESCALATION = TABLE)
GO
COMMIT

--備份dmt_ap_log
select * into dbo.dmt_ap_log_20210903 from dmt_ap_log
--dmt_ap_log增加排序欄位
BEGIN TRANSACTION
GO
ALTER TABLE dbo.dmt_ap_log ADD
	ap_sort varchar(2) NULL
GO
ALTER TABLE dbo.dmt_ap_log SET (LOCK_ESCALATION = TABLE)
GO
COMMIT

--備份dmt_temp_ap
select * into dbo.dmt_temp_ap_20210903 from dmt_temp_ap
--dmt_temp_ap增加排序欄位
BEGIN TRANSACTION
GO
ALTER TABLE dbo.dmt_temp_ap ADD
	ap_sort varchar(2) NULL
GO
ALTER TABLE dbo.dmt_temp_ap SET (LOCK_ESCALATION = TABLE)
GO
COMMIT

--備份dmt_temp_ap_log
select * into dbo.dmt_temp_ap_log_20210903 from dmt_temp_ap_log
--dmt_temp_ap_log增加排序欄位
BEGIN TRANSACTION
GO
ALTER TABLE dbo.dmt_temp_ap_log ADD
	ap_sort varchar(2) NULL
GO
ALTER TABLE dbo.dmt_temp_ap_log SET (LOCK_ESCALATION = TABLE)
GO
COMMIT

--重新執行view
SELECT DISTINCT 'EXEC sp_refreshview ' + name + '' 
FROM sys.objects so INNER JOIN sys.sql_dependencies sd 
ON so.object_id = sd.object_id 
WHERE type = 'V' 
AND sd.referenced_major_id = object_id('dmt_ap');

--重新執行view
SELECT DISTINCT 'EXEC sp_refreshview ' + name + '' 
FROM sys.objects so INNER JOIN sys.sql_dependencies sd 
ON so.object_id = sd.object_id 
WHERE type = 'V' 
AND sd.referenced_major_id = object_id('dmt_temp_ap');
