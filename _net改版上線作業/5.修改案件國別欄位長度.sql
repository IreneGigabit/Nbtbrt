--修改案件國別欄位長度
--交辦帳款異動記錄檔
alter table casetran_brt alter column country varchar(5)

--案件主檔,同步到總所sidbs，修改長度要先通知嘉彬修改,DSSDB會抓取案件主檔,修改長度要通知政哥同步修改
alter table dmt alter column prior_country varchar(5)
alter table dmt_log alter column prior_country varchar(5)
--重新執行view
exec sp_refreshview vdmt
exec sp_refreshview vdmtall
exec sp_refreshview vstep_dmt

--案件明細檔
alter table ndmt alter column zname_type varchar(5)
alter table ndmt_log alter column zname_type varchar(5)
--重新執行view
exec sp_refreshview vdmtall

--案件主檔(暫存檔)
alter table dmt_temp alter column prior_country varchar(5)
alter table dmt_temp alter column zname_type varchar(5)
alter table dmt_temp_log alter column prior_country varchar(5)
alter table dmt_temp_log alter column zname_type varchar(5)
--重新執行view
exec sp_refreshview vcase_dmt

--案件主檔(變更案暫存檔)
alter table dmt_temp_change alter column prior_country varchar(5)
alter table dmt_temp_change alter column zname_type varchar(5)

/*=============出口案=============================================*/
--案件主檔
alter table ext_log alter column country varchar(5)

--案件主檔(暫存檔)
alter table ext_temp alter column country varchar(5)
--重新執行view
exec sp_refreshview vcase_ext
exec sp_refreshview vcase_ext1

--出口案請款單記錄暫存檔
alter table are_temp alter column country varchar(5)
--重新執行view
exec sp_refreshview vartemp