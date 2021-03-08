CREATE TRIGGER [ddl_trig_database]   
ON DATABASE
FOR CREATE_TABLE 
AS  
BEGIN
/*
3-DEC-2020	Srimathi	Added calling program name check to remove duplicates, and allow sandbox entries
14-DEC-2020	Srimathi	Added LoadType with value 1 to insert statement
*/
DECLARE @id int;
DECLARE @obj_ID int;
DECLARE @tblname VARCHAR(100);
DECLARE @create_trig nvarchar(MAX);
DECLARE @schmname VARCHAR(100);
declare @sessionid int;
DECLARE @userEmail varchar(max);
declare @prog varchar(100);
	SET @userEmail = trim(EVENTDATA().value('(/EVENT_INSTANCE/LoginName)[1]','varchar(max)'))
	SET @schmname = trim(EVENTDATA().value('(/EVENT_INSTANCE/SchemaName)[1]','varchar(max)'))
	SET @tblname =  trim(EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]','varchar(max)'))
	SET @sessionid = EVENTDATA().value('(/EVENT_INSTANCE/SPID)[1]','int')
	
	select @prog = [PROGRAM_NAME] from sys.dm_exec_sessions where session_id = @sessionid
	
	SELECT @id  = USERID FROM APPADMIN.TI_ADM_USER_LU WHERE USEREMAIL=trim(EVENTDATA().value('(/EVENT_INSTANCE/LoginName)[1]','varchar(max)'))
	--insert into sandbox.test values(1,EVENTDATA().value('(/EVENT_INSTANCE/LoginName)[1]','varchar(max)'));
    --PRINT 'TEST'
	IF EVENTDATA().value('(/EVENT_INSTANCE/ObjectType)[1]','nvarchar(max)') = 'TABLE' AND EVENTDATA().value('(/EVENT_INSTANCE/SchemaName)[1]','nvarchar(max)') not in ('DBO','GUEST','INFORMATION_SCHEMA','SYS','APPADMIN','INCORPTAX','BRIGHTWING') AND @prog != 'Core .Net SqlClient Data Provider'
	BEGIN

	     Insert into [AppAdmin].[ti_adm_ObjectOwner_Intermediate](ObjectName, ObjectType, SchemaName, CreatedDate,  CreatedBy,UserEmail,IsActive)
		 Values ( EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]','nvarchar(max)') , 'Table', EVENTDATA().value('(/EVENT_INSTANCE/SchemaName)[1]','nvarchar(max)'), EVENTDATA().value('(/EVENT_INSTANCE/PostTime)[1]','datetime'),  @id,trim(EVENTDATA().value('(/EVENT_INSTANCE/LoginName)[1]','varchar(max)')),1)

		----SET @create_trig = 'CREATE TRIGGER trg_' +  @schmname + '_' + @tblname + ' ON ' + @schmname +'.'+ @tblname + ' FOR INSERT, UPDATE, DELETE AS BEGIN ' + ' EXEC [AppAdmin].[ti_analyze_AutoUnivariate_sp] ''' + @schmname + ''', ''' + @tblname + ''', ''' + EVENTDATA().value('(/EVENT_INSTANCE/LoginName)[1]','varchar(max)') + ''' END'
		----EXECUTE sp_executesql @create_trig    
		--INSERT INTO [AppAdmin].[ti_adm_ObjectOwner] (ObjectName, ObjectType, SchemaName, CreatedDate, LastUpdatedDate ,	IsActive , CreatedBy , LastUpdatedBy, ObjectLocation, FileExt, FileSize, LoadType) values (EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]','nvarchar(max)') , 'Table', EVENTDATA().value('(/EVENT_INSTANCE/SchemaName)[1]','nvarchar(max)'), EVENTDATA().value('(/EVENT_INSTANCE/PostTime)[1]','datetime'),  EVENTDATA().value('(/EVENT_INSTANCE/PostTime)[1]','datetime'), 1, @id , @id,'','',0,1);       
		--SET @obj_ID = SCOPE_IDENTITY();
		--INSERT INTO APPADMIN.ti_adm_ObjectAccessGrant(OBJECTID, GrantToUser, CREATEDDATE, CREATEDBY, LastUpdatedDate, LastUpdatedBy, ISACTIVE, FAVOURITE) 
		--	SELECT @obj_ID, USERID, EVENTDATA().value('(/EVENT_INSTANCE/PostTime)[1]','datetime'), @id, EVENTDATA().value('(/EVENT_INSTANCE/PostTime)[1]','datetime'), @id, 1, 0
		--	FROM APPADMIN.TI_ADM_USER_LU WHERE ISACTIVE=1 and userid!=@id 
		----EXEC [AppAdmin].[ti_analyze_AutoUnivariate_sp] @schmname, @tblname, @userEmail
	
	END
END	
GO

ENABLE TRIGGER [ddl_trig_database] ON DATABASE
GO


