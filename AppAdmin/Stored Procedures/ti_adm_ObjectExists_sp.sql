CREATE PROCEDURE  [AppAdmin].[ti_adm_ObjectExists_sp]                     
@ObjectName Varchar(200),              
@ObjectType Varchar(50),              
@SchemaName Varchar(50),                 
@ObjectLocation VARCHAR(200),  
@FileExt Varchar(10),  
@UserEmail Varchar(150)                 
               
AS                  
BEGIN 

  
DECLARE @tblname VARCHAR(100);
DECLARE @userid int;  
DECLARE @flag_str VARCHAR(50);  
DECLARE @flag_val int;
DECLARE @owner INT;
Declare @ObjectID int   
DECLARE @objectid_new int;  

	SET @flag_str ='New Object';  
	SET @flag_val=0;
	SELECT @userid = userid from appadmin.ti_adm_user_lu where useremail = @useremail and isactive=1;  
    IF EXISTS (SELECT 1 FROM [AppAdmin].[ti_adm_ObjectOwner] WHERE SchemaName = @SchemaName AND ObjectLocation = @ObjectLocation AND ObjectName = @ObjectName AND FileExt = @FileExt AND objectType = @ObjectType AND IsActive = 1)  
	BEGIN  
		SET @flag_str = 'Object owned by someone else';  
		SET @flag_val = 2;
		--print 'exists'

		SELECT @ObjectID = ObjectID, @owner = CreatedBy FROM [AppAdmin].[ti_adm_ObjectOwner] WHERE SchemaName = @SchemaName AND ObjectLocation = @ObjectLocation AND ObjectName = @ObjectName AND FileExt = @FileExt AND objectType = @ObjectType AND IsActive = 1  
		IF @OWNER = @USERID
		BEGIN
			SET @flag_str = 'Object owned by same user';
			SET @flag_val=1;
		END
	END
	SELECT @flag_val FlagValue, @flag_str FlagDescription

END