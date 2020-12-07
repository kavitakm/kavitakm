CREATE TRIGGER [ddl_trig_database]   
ON DATABASE
FOR CREATE_TABLE 
AS  
BEGIN
DECLARE @id int;
DECLARE @obj_ID int;
DECLARE @tblname VARCHAR(100);
DECLARE @create_trig nvarchar(MAX);
DECLARE @schmname VARCHAR(100);
DECLARE @userEmail varchar(max);
	SET @userEmail = trim(EVENTDATA().value('(/EVENT_INSTANCE/LoginName)[1]','varchar(max)'))
	SET @schmname = trim(EVENTDATA().value('(/EVENT_INSTANCE/SchemaName)[1]','varchar(max)'))
	SET @tblname =  trim(EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]','varchar(max)'))
	
	SELECT @id  = USERID FROM APPADMIN.TI_ADM_USER_LU WHERE USEREMAIL=trim(EVENTDATA().value('(/EVENT_INSTANCE/LoginName)[1]','varchar(max)'))
	--insert into sandbox.test values(1,EVENTDATA().value('(/EVENT_INSTANCE/LoginName)[1]','varchar(max)'));
    --PRINT 'TEST'
	IF EVENTDATA().value('(/EVENT_INSTANCE/ObjectType)[1]','nvarchar(max)') = 'TABLE' AND EVENTDATA().value('(/EVENT_INSTANCE/SchemaName)[1]','nvarchar(max)') not in ('DBO','GUEST','INFORMATION_SCHEMA','SYS','APPADMIN','SANDBOX','INCORPTAX','BRIGHTWING')
	BEGIN
		--SET @create_trig = 'CREATE TRIGGER trg_' +  @schmname + '_' + @tblname + ' ON ' + @schmname +'.'+ @tblname + ' FOR INSERT, UPDATE, DELETE AS BEGIN ' + ' EXEC [AppAdmin].[ti_analyze_AutoUnivariate_sp] ''' + @schmname + ''', ''' + @tblname + ''', ''' + EVENTDATA().value('(/EVENT_INSTANCE/LoginName)[1]','varchar(max)') + ''' END'
		--EXECUTE sp_executesql @create_trig    
		INSERT INTO [AppAdmin].[ti_adm_ObjectOwner] (ObjectName, ObjectType, SchemaName, CreatedDate, LastUpdatedDate ,	IsActive , CreatedBy , LastUpdatedBy, ObjectLocation, FileExt, FileSize) values (EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]','nvarchar(max)') , 'Table', EVENTDATA().value('(/EVENT_INSTANCE/SchemaName)[1]','nvarchar(max)'), EVENTDATA().value('(/EVENT_INSTANCE/PostTime)[1]','datetime'),  EVENTDATA().value('(/EVENT_INSTANCE/PostTime)[1]','datetime'), 1, @id , @id,'','',0);       
		SET @obj_ID = SCOPE_IDENTITY();
		INSERT INTO APPADMIN.ti_adm_ObjectAccessGrant(OBJECTID, GrantToUser, CREATEDDATE, CREATEDBY, LastUpdatedDate, LastUpdatedBy, ISACTIVE, FAVOURITE) 
			SELECT @obj_ID, USERID, EVENTDATA().value('(/EVENT_INSTANCE/PostTime)[1]','datetime'), @id, EVENTDATA().value('(/EVENT_INSTANCE/PostTime)[1]','datetime'), @id, 1, 0
			FROM APPADMIN.TI_ADM_USER_LU WHERE ISACTIVE=1 and userid!=@id 
		--EXEC [AppAdmin].[ti_analyze_AutoUnivariate_sp] @schmname, @tblname, @userEmail
		
	END
END
GO

DISABLE TRIGGER [ddl_trig_database] ON DATABASE
GO

ENABLE TRIGGER [ddl_trig_database] ON DATABASE