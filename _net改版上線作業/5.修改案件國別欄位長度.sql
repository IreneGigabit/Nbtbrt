--�ק�ץ��O������
--���b�ڲ��ʰO����
alter table casetran_brt alter column country varchar(5)

--�ץ�D��,�P�B���`��sidbs�A�ק���׭n���q���űl�ק�,DSSDB�|����ץ�D��,�ק���׭n�q���F���P�B�ק�
alter table dmt alter column prior_country varchar(5)
alter table dmt_log alter column prior_country varchar(5)
--���s����view
exec sp_refreshview vdmt
exec sp_refreshview vdmtall
exec sp_refreshview vstep_dmt

--�ץ������
alter table ndmt alter column zname_type varchar(5)
alter table ndmt_log alter column zname_type varchar(5)
--���s����view
exec sp_refreshview vdmtall

--�ץ�D��(�Ȧs��)
alter table dmt_temp alter column prior_country varchar(5)
alter table dmt_temp alter column zname_type varchar(5)
alter table dmt_temp_log alter column prior_country varchar(5)
alter table dmt_temp_log alter column zname_type varchar(5)
--���s����view
exec sp_refreshview vcase_dmt

--�ץ�D��(�ܧ�׼Ȧs��)
alter table dmt_temp_change alter column prior_country varchar(5)
alter table dmt_temp_change alter column zname_type varchar(5)

/*=============�X�f��=============================================*/
--�ץ�D��
alter table ext_log alter column country varchar(5)

--�ץ�D��(�Ȧs��)
alter table ext_temp alter column country varchar(5)
--���s����view
exec sp_refreshview vcase_ext
exec sp_refreshview vcase_ext1

--�X�f�׽дڳ�O���Ȧs��
alter table are_temp alter column country varchar(5)
--���s����view
exec sp_refreshview vartemp