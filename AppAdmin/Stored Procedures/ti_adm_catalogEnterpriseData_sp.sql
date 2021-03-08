/****** Object:  StoredProcedure [AppAdmin].[ti_adm_catalogEnterpriseData_sp]    Script Date: 2/3/2021 11:49:06 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--exec [AppAdmin].[ti_adm_catalogEnterpriseData_sp]

CREATE procedure [AppAdmin].[ti_adm_catalogEnterpriseData_sp]
as
begin
DECLARE @schmName varchar(100);
DECLARE @tblName VARCHAR(100);
DECLARE @maxDate DATETIME;
DECLARE @lastUserUpdate DATETIME;
declare @lastsummarydate datetime;
DECLARE @userEmail VARCHAR(100);

	DECLARE enterprise_tables CURSOR FAST_FORWARD
	FOR
	SELECT name, schema_name(b.schema_id), a.last_user_update FROM sys.dm_db_index_usage_stats a, 
	sys.objects b, appadmin.ti_adm_lastjobrundate c WHERE a.object_id = b.object_id AND b.type= 'U' 
	AND schema_name(b.schema_id) NOT IN ('dbo','information_schema','sys','guest','appadmin','incorptax','brightwing') 
	AND a.last_user_update > c.lastjobrundate ORDER BY a.last_user_update;

	OPEN enterprise_tables;
	FETCH NEXT FROM enterprise_tables into @tblName, @schmName, @lastUserUpdate;
	SELECT @maxDate=c.lastjobrundate from appadmin.ti_adm_lastjobrundate c;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @lastsummarydate = max(a.lastupdatedDate) FROM APPADMIN.ti_adm_SummaryStatistics a 
		where a.objectid = (select max(objectid) FROM appadmin.ti_adm_objectowner where schemaname = @schmName and objectname = @tblName and isactive=1);
		SELECT @userEmail = userEmail FROM appadmin.ti_adm_user_lu WHERE userId = (SELECT TOP 1 LASTUPDATEDBY FROM APPADMIN.TI_ADM_OBJECTOWNER WHERE SCHEMANAME = @schmname AND OBJECTNAME = @tblName AND ISACTIVE = 1)
		SET @userEmail = ISNULL(@userEmail,'');
		IF @lastsummarydate <  @lastUserUpdate or @lastsummarydate is null
			EXEC [AppAdmin].[ti_analyze_AutoUnivariate_sp] @schmname, @tblname, @userEmail
		SET @maxDate = @lastUserUpdate 
		FETCH NEXT FROM enterprise_tables into @tblName, @schmName, @lastUserUpdate;
	END
	close enterprise_tables;
	DEALLOCATE enterprise_tables;
	update appadmin.ti_adm_lastjobrundate set lastjobrundate = @maxDate;
end
GO


