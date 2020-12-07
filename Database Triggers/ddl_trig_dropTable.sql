CREATE TRIGGER [ddl_trig_dropTable]   
ON DATABASE
FOR DROP_TABLE 
AS  
BEGIN
/*
02-DEC-2020	Srimathi	Removed Sandbox check in IF - to handle backend deletion of tables in sandbox
*/
DECLARE @id int;
DECLARE @objectID int;
DECLARE @tblname VARCHAR(100);
DECLARE @schmname VARCHAR(100);
	SET @schmname = trim(EVENTDATA().value('(/EVENT_INSTANCE/SchemaName)[1]','varchar(max)'))
	SET @tblname =  trim(EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]','varchar(max)'))
	
	SELECT @id  = USERID FROM APPADMIN.TI_ADM_USER_LU WHERE USEREMAIL=trim(EVENTDATA().value('(/EVENT_INSTANCE/LoginName)[1]','varchar(max)'))
	SELECT @ObjectID = ObjectID FROM [AppAdmin].[ti_adm_ObjectOwner] WHERE ISNULL(SchemaName,'') = @SchmName AND ObjectName = @tblName and objectType = 'TABLE' AND IsActive = 1  ;
		
	--insert into sandbox.test values(1,EVENTDATA().value('(/EVENT_INSTANCE/LoginName)[1]','varchar(max)'));
    IF @ObjectID is not null and EVENTDATA().value('(/EVENT_INSTANCE/ObjectType)[1]','nvarchar(max)') = 'TABLE' AND EVENTDATA().value('(/EVENT_INSTANCE/SchemaName)[1]','nvarchar(max)') not in ('DBO','GUEST','INFORMATION_SCHEMA','SYS','APPADMIN','INCORPTAX','BRIGHTWING')
	BEGIN
		UPDATE APPADMIN.TI_ADM_TRANSFORM SET to_be_validated = 1 FROM appadmin.ti_adm_ObjectOwner o WHERE TI_ADM_TRANSFORM.ObjectId = o.ObjectID AND o.isactive = 1 AND CHARINDEX(@tblname, transformquery) > 0;
				
		DELETE APPADMIN.ti_adm_ObjectAccessGrant WHERE ObjectID in (select objectid from appadmin.ti_adm_ObjectOwner where schemaname = @schmname and objectname = @tblname and objecttype ='TABLE') ;
				
		DELETE APPADMIN.ti_adm_integrate WHERE OBJECTID in (select objectid from appadmin.ti_adm_ObjectOwner where schemaname = @schmname and objectname = @tblname and objecttype ='TABLE') ;

		DELETE APPADMIN.ti_adm_SummaryStatistics WHERE OBJECTID in (select objectid from appadmin.ti_adm_ObjectOwner where schemaname = @schmname and objectname = @tblname and objecttype ='TABLE') ;

		UPDATE appadmin.ti_adm_RegressionModels SET objectid = NULL WHERE OBJECTID = @ObjectID;

		DELETE APPADMIN.ti_adm_ObjectOwner WHERE SChemaname = @schmname and objectname = @tblname and objecttype ='TABLE';

	END
END	
GO
DISABLE TRIGGER [ddl_trig_dropTable] ON DATABASE
GO
ENABLE TRIGGER [ddl_trig_dropTable] ON DATABASE
GO